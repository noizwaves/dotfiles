import concurrent.futures
import json
import os
from pathlib import Path
import runpy
import shlex
import shutil
import signal
import subprocess
import tempfile
import textwrap
import time
import unittest
from unittest import mock
from uuid import uuid4


AMUX = Path(__file__).resolve().parents[1] / "tmux/.local/bin/amux-sessionizer"
TMUX = shutil.which("tmux")
NUG = os.environ.get("NUGGET_CLI") or shutil.which("nug")
if NUG:
    NUG = str(Path(NUG).resolve())


@unittest.skipUnless(TMUX and NUG, "requires tmux and NUGGET_CLI or nug on PATH")
class AmuxTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="amux-test-")
        self.addCleanup(self.temporary.cleanup)
        self.home = Path(self.temporary.name)
        self.bin = self.home / "bin"
        self.bin.mkdir()
        (self.home / "workspace").mkdir()
        self.origin = self.home / "origin"
        self.origin.mkdir()
        shutil.copyfile(NUG, self.bin / "nug")
        (self.bin / "nug").chmod(0o755)
        shell = self.home / "initial-shell"
        shell.write_text('#!/bin/sh\nprintf "%s:%s\\n" "$AMUX_SESSION_ID" "$NUGGET_SESSION_ID" '
                         '> "$HOME/first-$AMUX_SESSION_ID"\npwd >> "$HOME/first-$AMUX_SESSION_ID"\nexec /bin/sh\n')
        shell.chmod(0o755)
        config = self.home / "tmux.conf"
        config.write_text("set -g default-shell /bin/sh\nset -g default-command " + shlex.quote(str(shell)) + "\n")
        self.socket = self.home / "tmux.socket"
        self.env = {**os.environ, "HOME": str(self.home), "TMUX": "",
                    "PATH": f"{self.bin}{os.pathsep}{os.environ['PATH']}",
                    "TEST_SOCKET": str(self.socket), "TEST_CONFIG": str(config),
                    "REAL_TMUX": TMUX, "ATTACH_LOG": str(self.home / "attach.json"),
                    "PICKER_LOG": str(self.home / "picker.txt")}
        self.env.pop("NUGGET_SESSION_ID", None)
        self.env.pop("AMUX_SESSION_ID", None)
        shim = self.bin / "tmux"
        shim.write_text(textwrap.dedent('''\
            #!/usr/bin/env python3
            import json, os, sys
            from pathlib import Path
            if sys.argv[1] in ("attach-session", "switch-client"):
                Path(os.environ["ATTACH_LOG"]).write_text(json.dumps(sys.argv[1:]))
                sys.exit(0)
            if ((sys.argv[1] == "kill-session" and os.environ.get("FAIL_KILL")) or
                    (sys.argv[1] == "new-session" and os.environ.get("FAIL_NEW"))):
                print("injected tmux failure", file=sys.stderr)
                sys.exit(1)
            os.execv(os.environ["REAL_TMUX"], [os.environ["REAL_TMUX"], "-S", os.environ["TEST_SOCKET"],
                     "-f", os.environ["TEST_CONFIG"], *sys.argv[1:]])
        '''))
        shim.chmod(0o755)
        picker = self.bin / "fzf"
        picker.write_text(textwrap.dedent('''\
            #!/usr/bin/env python3
            import os, sys
            from pathlib import Path
            data = sys.stdin.read()
            Path(os.environ["PICKER_LOG"]).write_text(data)
            if os.environ.get("PICK_CANCEL"):
                sys.exit(130)
            query = os.environ.get("PICK_QUERY")
            if query is not None:
                print(query)
            elif data:
                print(data.splitlines()[0])
            else:
                sys.exit(130)
        '''))
        picker.chmod(0o755)
        gh = self.bin / "gh"
        gh.write_text("#!/bin/sh\necho 'unexpected GitHub request' >&2\nexit 99\n")
        gh.chmod(0o755)
        self.addCleanup(lambda: self.tmux("kill-server", check=False))

    def tmux(self, *arguments, check=True):
        result = subprocess.run([TMUX, "-S", str(self.socket), "-f", self.env["TEST_CONFIG"], *arguments],
                                env=self.env, capture_output=True, text=True, timeout=10)
        if check:
            self.assertEqual(result.returncode, 0, result.stderr)
        return result

    def amux(self, *arguments, expected=0, **environment):
        result = subprocess.run([str(AMUX), *arguments], cwd=self.origin,
                                env={**self.env, **environment}, capture_output=True, text=True, timeout=20)
        self.assertEqual(result.returncode, expected, result.stderr)
        return result

    def states(self):
        root = self.home / ".local/share/nugget/sessions"
        return [json.loads(path.read_text()) for path in root.glob("*/session.json")]

    def saved(self, name):
        return next(state for state in self.states() if state["session_name"] == name and not state["destroyed"])

    def wait_for(self, predicate):
        deadline = time.monotonic() + 5
        while time.monotonic() < deadline:
            if predicate():
                return
            time.sleep(0.025)
        self.fail("timed out waiting for tmux hook or initial shell")

    def test_restart_lists_without_starting_and_restores_one_in_workspace(self):
        self.amux("first")
        self.amux("second")
        state = self.saved("first")
        session_id = state["session_id"]
        initial = self.home / f"first-{session_id}"
        self.wait_for(initial.exists)
        self.assertEqual(initial.read_text().splitlines(), [f"{session_id}:{session_id}", str(self.origin)])
        self.tmux("kill-server")
        initial.unlink()
        self.amux(PICK_CANCEL="1")
        self.assertNotEqual(self.tmux("list-sessions", check=False).returncode, 0)
        choices = (self.home / "picker.txt").read_text()
        self.assertIn("first\t[saved]", choices)
        self.assertIn("second\t[saved]", choices)
        self.amux()
        selected = self.tmux("list-sessions", "-F", "#{session_name}").stdout.strip()
        self.assertIn(selected, ("first", "second"))
        self.assertEqual(len(self.tmux("list-sessions").stdout.splitlines()), 1)
        restored_id = self.saved(selected)["session_id"]
        restored = self.home / f"first-{restored_id}"
        self.wait_for(lambda: restored.exists() and len(restored.read_text().splitlines()) == 2)
        self.assertEqual(restored.read_text().splitlines(),
                         [f"{restored_id}:{restored_id}", str(self.home / "workspace")])

    def test_destroy_then_reuse_name_gets_new_identity(self):
        self.amux("work")
        previous = self.saved("work")["session_id"]
        self.amux("--destroy", "-t", "=work:")
        self.assertTrue(next(state for state in self.states() if state["session_id"] == previous)["destroyed"])
        self.amux("work")
        self.assertNotEqual(self.saved("work")["session_id"], previous)

    def test_destroy_saved_without_starting(self):
        self.amux("work")
        self.tmux("kill-server")
        self.amux("--destroy", "work")
        self.assertTrue(self.states()[0]["destroyed"])
        self.assertNotEqual(self.tmux("list-sessions", check=False).returncode, 0)

    def test_closing_last_shell_retains_identity(self):
        self.amux("work")
        session_id = self.saved("work")["session_id"]
        self.tmux("kill-pane", "-t", "=work:")
        self.amux("work")
        self.assertEqual(self.saved("work")["session_id"], session_id)

    def test_existing_sessions_migrate_with_original_uuid(self):
        session_id = str(uuid4())
        self.tmux("new-session", "-d", "-s", "legacy", "-e", f"NUGGET_SESSION_ID={session_id}",
                  ";", "set-option", "-t", "=legacy:", "@amux-sessionizer", "1",
                  ";", "set-option", "-t", "=legacy:", "@amux-session-id", session_id)
        self.amux(PICK_CANCEL="1")
        self.assertEqual(self.saved("legacy")["session_id"], session_id)
        self.assertIn("legacy\t[running]", (self.home / "picker.txt").read_text())

    def test_ordinary_tmux_sessions_are_never_adopted(self):
        self.tmux("new-session", "-d", "-s", "ordinary")
        self.amux("ordinary", expected=1)
        self.assertEqual(self.states(), [])
        self.amux("--destroy", "-t", "=ordinary:")
        self.assertNotEqual(self.tmux("has-session", "-t", "=ordinary:", check=False).returncode, 0)

    def test_missing_workspace_preserves_saved_record(self):
        self.amux("work")
        original = self.saved("work")
        self.tmux("kill-server")
        (self.home / "workspace").rmdir()
        result = self.amux("work", expected=1)
        self.assertIn("restored shell directory", result.stderr)
        self.assertEqual(self.saved("work"), original)
        self.assertNotEqual(self.tmux("list-sessions", check=False).returncode, 0)

    def test_restore_ignores_damaged_pr_cache(self):
        self.amux("work")
        session_id = self.saved("work")["session_id"]
        cache = self.home / f".local/share/nugget/sessions/{session_id}/cache.json"
        cache.write_text("broken cache")
        self.tmux("kill-server")
        self.amux("work")
        self.assertEqual(self.saved("work")["session_id"], session_id)
        self.assertEqual(cache.read_text(), "broken cache")

    def test_concurrent_openers_share_one_uuid_and_tmux_session(self):
        with concurrent.futures.ThreadPoolExecutor(max_workers=3) as executor:
            list(executor.map(lambda _: self.amux("same"), range(3)))
        self.assertEqual(len(self.states()), 1)
        self.assertEqual(self.tmux("list-sessions", "-F", "#{session_name}").stdout, "same\n")

    def test_managed_and_native_rename_preserve_uuid(self):
        self.amux("work")
        session_id = self.saved("work")["session_id"]
        self.amux("--rename", "renamed", "-t", "=work:")
        self.assertEqual(self.saved("renamed")["session_id"], session_id)
        self.tmux("rename-session", "-t", "=renamed:", "native")
        self.wait_for(lambda: any(state["session_name"] == "native" for state in self.states()))
        self.tmux("kill-server")
        self.amux("native")
        self.assertEqual(self.saved("native")["session_id"], session_id)

    def test_rename_cannot_take_dormant_sessions_name(self):
        self.amux("reserved")
        self.tmux("kill-session", "-t", "=reserved:")
        self.amux("work")
        self.amux("--rename", "reserved", "-t", "=work:", expected=1)
        self.tmux("rename-session", "-t", "=work:", "reserved")
        self.wait_for(lambda: self.tmux("has-session", "-t", "=work:", check=False).returncode == 0)
        self.assertEqual({state["session_name"] for state in self.states()}, {"reserved", "work"})

    def test_missing_or_incompatible_nug_fails_before_creating_tmux(self):
        (self.bin / "nug").write_text("#!/bin/sh\necho 'unknown command' >&2\nexit 2\n")
        self.amux("work", expected=1)
        self.assertEqual(self.states(), [])
        self.assertNotEqual(self.tmux("list-sessions", check=False).returncode, 0)

    def test_failed_kill_keeps_tombstone_and_can_be_retried(self):
        self.amux("work")
        self.amux("--destroy", "-t", "=work:", expected=1, FAIL_KILL="1")
        self.assertTrue(self.states()[0]["destroyed"])
        self.tmux("has-session", "-t", "=work:")
        self.amux("work", expected=1)
        self.assertEqual(len(self.states()), 1)
        self.amux("--destroy", "-t", "=work:")
        self.assertNotEqual(self.tmux("has-session", "-t", "=work:", check=False).returncode, 0)

    def test_failed_durable_destroy_does_not_kill_tmux(self):
        self.amux("work")
        shutil.copyfile(self.bin / "nug", self.bin / "nug-real")
        (self.bin / "nug-real").chmod(0o755)
        (self.bin / "nug").write_text('#!/bin/sh\nif [ "$2" = destroy ]; then exit 1; fi\nexec '
                                     + shlex.quote(str(self.bin / "nug-real")) + ' "$@"\n')
        self.amux("--destroy", "-t", "=work:", expected=1)
        self.tmux("has-session", "-t", "=work:")
        self.assertFalse(self.saved("work")["destroyed"])

    def test_failed_startup_leaves_identity_available_for_retry(self):
        self.amux("work", expected=1, FAIL_NEW="1")
        previous = self.saved("work")
        self.amux("work")
        self.assertEqual(self.saved("work"), previous)
        self.assertEqual(self.tmux("display-message", "-p", "-t", "=work:", "#{pane_current_path}").stdout.strip(),
                         str(self.home / "workspace"))

    def test_abrupt_server_loss_preserves_identity(self):
        self.amux("work")
        previous = self.saved("work")
        pid = int(self.tmux("display-message", "-p", "#{pid}").stdout)
        os.kill(pid, signal.SIGKILL)
        self.wait_for(lambda: self.tmux("list-sessions", check=False).returncode != 0)
        self.amux("work")
        self.assertEqual(self.saved("work"), previous)

    def test_restore_preserves_typed_pr_graph_without_github(self):
        self.amux("work")
        saved = self.saved("work")
        first = "https://github.com/example/project/pull/1"
        second = "https://github.com/example/project/pull/2"
        saved["prs"] = {first: {"depends_on": []}, second: {"depends_on": [{"url": first, "type": "deploy"}]}}
        path = self.home / f".local/share/nugget/sessions/{saved['session_id']}/session.json"
        path.write_text(json.dumps(saved))
        before = path.read_bytes()
        self.tmux("kill-server")
        self.amux("work")
        self.assertEqual(path.read_bytes(), before)
        preview = self.amux("--preview", saved["session_id"])
        self.assertIn("example/project#1", preview.stdout)
        self.assertIn("example/project#2", preview.stdout)

    def test_saved_identity_never_attaches_to_different_running_uuid(self):
        self.amux("work")
        previous = self.saved("work")
        self.tmux("kill-session", "-t", "=work:")
        self.tmux("new-session", "-d", "-s", "work",
                  ";", "set-option", "-t", "=work:", "@amux-sessionizer", "1",
                  ";", "set-option", "-t", "=work:", "@amux-session-id", str(uuid4()))
        (self.home / "attach.json").unlink()
        self.amux("work", expected=1)
        self.assertFalse((self.home / "attach.json").exists())
        self.assertEqual(self.saved("work"), previous)

    def test_stale_picker_selection_cannot_recreate_destroyed_uuid(self):
        self.amux("work")
        session_id = self.saved("work")["session_id"]
        self.amux("--destroy", "-t", "=work:")
        module = runpy.run_path(str(AMUX))
        with mock.patch.dict(os.environ, self.env):
            with self.assertRaisesRegex(module["AmuxError"], "no longer available"):
                module["ensure_session"]("work", session_id)
        self.assertEqual(len(self.states()), 1)
        self.assertTrue(self.states()[0]["destroyed"])


if __name__ == "__main__":
    unittest.main()

---
name: root-cause
description: Investigate the root cause of a problem, error, incident, or failed build from a concrete link or vague description. Correlate observed system behavior with code across service boundaries, test competing hypotheses, and produce a sourced causal analysis and timeline.
---

# Root Cause Investigation

Find the causal mechanism behind the reported behavior. Treat the user's
description and any initial diagnosis as leads to verify.

## Establish what happened

- Open supplied links and inspect the underlying records. For a vague report,
  search available systems to identify the affected service, environment, time
  window, and concrete symptom. Ask for missing context only when it prevents
  useful progress; continue independent investigation while awaiting it.
- Use available integrations and repository access. Prefer direct operational
  evidence: Buildkite builds, jobs, and logs; Datadog logs, metrics, traces, and
  events; deployment records; and the code and configuration actually running.
- Record exact errors, timestamps and timezones, build/job IDs, commit SHAs,
  deployed versions, request/trace IDs, and affected resources as available.
  Compare failing behavior with a nearby successful run or healthy population.
  Distinguish the initiating failure from downstream errors and retry noise.

## Follow the causal chain

- Work backward from the observed failure through callers, dependencies,
  queues, workers, databases, infrastructure, and external services as the
  evidence warrants. Do not stop at a service boundary, error wrapper, or the
  first plausible explanation.
- Explore the codebases of other implicated systems. Follow request payloads,
  interfaces, configuration, ownership, and execution paths across repositories.
  Inspect the revision used by the affected build or deployment; current code
  alone does not establish historical behavior.
- Correlate systems using shared identifiers and event times. Check clock
  differences, ingestion delay, sampling, aggregation, and timezone conversion
  before treating nearby events as related.
- Use documentation and tickets to understand intended behavior and find leads;
  verify their explanations against actual system behavior and relevant code.
- Keep investigation observational unless the user has authorized changes or
  operational actions. Do not retry production jobs or change system state just
  to test a theory without that authorization.

## Double-check hypotheses

- Maintain competing explanations with supporting evidence, contradicting
  evidence, and the next observation that would distinguish them. Seek evidence
  that could disprove the leading explanation.
- For each causal conclusion, cross-check the mechanism against an independent
  observation or a safe reproduction when feasible: for example, connect an
  executed code path to a runtime trace, or a configuration change to both the
  deployed version and the resulting metric/log behavior. Two views of the same
  log are not independent confirmation.
- Verify that the proposed cause precedes the effect and explains the specific
  symptom, affected scope, and successful comparisons. A coincident deployment
  or correlated metric is a lead, not proof of causation. Distinguish a trigger,
  the underlying failure mechanism, and contributing conditions.
- Before claiming missing activity, verify query filters, environment, time
  range, retention, and sampling. Absence from a search alone does not prove an
  event never happened.
- Continue until the causal chain is supported and credible alternatives have
  been checked. If access or evidence prevents further progress, state that the
  root cause is not established, label any leading hypothesis and its confidence,
  and identify the missing evidence and next discriminating check. Never convert
  uncertainty into a definitive diagnosis to fill the report.

## Evidence and final report

Every factual statement in the report must include an adjacent Markdown link to
its source of truth. This applies to the root cause, every contributing factor,
every timeline event, and any additional factual analysis.

- Prefer direct build/job permalinks, specific log/trace/event links, metric
  queries with explicit filters and time ranges, and repository permalinks pinned
  to the relevant commit and lines. A system homepage or search landing page is
  not supporting evidence.
- Link both runtime evidence and code/configuration when the claim connects
  observed behavior to an implementation mechanism. Ensure the linked evidence
  supports the entire statement; split claims when their sources differ.
- Distinguish observed facts from inferences. Label inferences and link the
  observations supporting them. Do not fabricate URLs, citations, events, or
  certainty. If a source has no shareable permalink, explain that limitation
  rather than presenting its claim as fully sourced.
- Order timeline events chronologically using human-readable dates, times, and
  an explicit timezone, such as `October 15, 2026, 9:42:18 AM MDT (UTC−06:00)`.
  Use event time rather than ingestion time, and mark approximate times. Include
  recovery or mitigation only when observed.

Use this structure for the final analysis. Replace the placeholders with sourced
findings; use `None established` for contributing factors when appropriate.

```markdown
Root cause: <causal mechanism, or not established with the evidence gap> [Evidence](<source URL>)

Contributing factors:
1. <factor and how it contributed> [Evidence](<source URL>)

Timeline:
- <human-readable timestamp with timezone> <event> [Evidence](<source URL>)
```

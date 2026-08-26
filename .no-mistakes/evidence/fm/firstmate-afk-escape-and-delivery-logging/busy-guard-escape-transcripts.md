# Away-mode busy-guard escape: before/after operator log transcripts

Scenario (identical in all three runs): the supervisor pane exists, its native
agent-state reads 'busy' forever while its composer reads provably 'empty' -
the exact false positive from data/firstmate-afk-daemon-wedged-investigation.
The real inject_msg is driven on a real poll cadence (FM_HOUSEKEEPING_TICK=2)
and writes the real state/.supervise-daemon.log. Escape window shortened to 6s
so the bound is observable in seconds instead of minutes.

## 1. BEFORE - base commit 07bf0c8 daemon, FM_BUSY_GUARD_ESCAPE_SECS=6 set
```
[2026-08-26T05:03:34-0400] daemon starting (pid 96914); target=default:w1:p2; backend=herdr; afk=on; busy_guard_escape=<no such mechanism>
[2026-08-26T05:03:34-0400] inject deferred: supervisor pane busy (agent mid-turn)
[2026-08-26T05:03:36-0400] inject deferred: supervisor pane busy (agent mid-turn)
[2026-08-26T05:03:38-0400] inject deferred: supervisor pane busy (agent mid-turn)
[2026-08-26T05:03:40-0400] inject deferred: supervisor pane busy (agent mid-turn)
[2026-08-26T05:03:42-0400] inject deferred: supervisor pane busy (agent mid-turn)
[2026-08-26T05:03:44-0400] inject deferred: supervisor pane busy (agent mid-turn)
[2026-08-26T05:03:47-0400] inject deferred: supervisor pane busy (agent mid-turn)
[2026-08-26T05:03:49-0400] inject deferred: supervisor pane busy (agent mid-turn)
```
Never delivers; the deferral line cannot say which branch decided; no delivery
record exists. (State dir after the run: no .subsuper-last-delivery.)

## 2. AFTER - this branch, FM_BUSY_GUARD_ESCAPE_SECS=6
```
[2026-08-26T05:02:48-0400] daemon starting (pid 91374); target=default:w1:p2; backend=herdr; afk=on; busy_guard_escape=6s
[2026-08-26T05:02:48-0400] inject deferred: supervisor pane busy (native agent-state (agent_status=busy)); composer confirmed-empty for 0s straight, escapes at 6s
[2026-08-26T05:02:50-0400] inject deferred: supervisor pane busy (native agent-state (agent_status=busy)); composer confirmed-empty for 2s straight, escapes at 6s
[2026-08-26T05:02:52-0400] inject deferred: supervisor pane busy (native agent-state (agent_status=busy)); composer confirmed-empty for 4s straight, escapes at 6s
[2026-08-26T05:02:54-0400] inject busy-guard override: native agent-state (agent_status=busy) has read busy against a confirmed-empty composer for 6s straight; delivering instead of deferring further
[2026-08-26T05:02:54-0400] inject delivered: escalation submitted (verdict=empty)
[2026-08-26T05:02:54-0400] main loop: escalation buffer flushed at tick 4
```
Text actually submitted to the pane:
```
⁣FIRSTMATE_OP: v1 away-supervisor: away-supervisor digest: task alpha needs a decision
```
state/.subsuper-last-delivery written: 1787734974
state/.subsuper-busy-empty-streak-since removed once the escape fired.

## 3. AFTER with the escape disabled - FM_BUSY_GUARD_ESCAPE_SECS=0
```
[2026-08-26T05:03:01-0400] daemon starting (pid 92795); target=default:w1:p2; backend=herdr; afk=on; busy_guard_escape=0s
[2026-08-26T05:03:01-0400] inject deferred: supervisor pane busy (native agent-state (agent_status=busy)); composer confirmed-empty for 0s straight, escapes at 0s
[2026-08-26T05:03:04-0400] inject deferred: supervisor pane busy (native agent-state (agent_status=busy)); composer confirmed-empty for 2s straight, escapes at 0s
[2026-08-26T05:03:06-0400] inject deferred: supervisor pane busy (native agent-state (agent_status=busy)); composer confirmed-empty for 4s straight, escapes at 0s
[2026-08-26T05:03:08-0400] inject deferred: supervisor pane busy (native agent-state (agent_status=busy)); composer confirmed-empty for 6s straight, escapes at 0s
[2026-08-26T05:03:10-0400] inject deferred: supervisor pane busy (native agent-state (agent_status=busy)); composer confirmed-empty for 8s straight, escapes at 0s
[2026-08-26T05:03:12-0400] inject deferred: supervisor pane busy (native agent-state (agent_status=busy)); composer confirmed-empty for 10s straight, escapes at 0s
[2026-08-26T05:03:14-0400] inject deferred: supervisor pane busy (native agent-state (agent_status=busy)); composer confirmed-empty for 12s straight, escapes at 0s
[2026-08-26T05:03:17-0400] inject deferred: supervisor pane busy (native agent-state (agent_status=busy)); composer confirmed-empty for 14s straight, escapes at 0s
```
Opt-out preserves the old always-defer behavior, but the log now still explains
why (busy source, observed streak seconds, configured threshold).

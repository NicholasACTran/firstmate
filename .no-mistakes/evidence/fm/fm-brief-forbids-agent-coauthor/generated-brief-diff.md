# Generated brief diff: base b84e0e3 -> target 9816cab (paths normalized)

```diff
diff -ru <HOME>/data/scout-1/brief.md <HOME>/data/scout-1/brief.md
@@ -23,7 +23,7 @@
 2. Stay inside this worktree; the only files you may write outside it are the report and the status file below.
 3. Use gh-axi for GitHub operations and chrome-devtools-axi for browser operations.
 4. Report status by appending one line:
    States: working, needs-decision, blocked, paused, done, failed.
    Each append wakes firstmate, so report sparingly: only phase changes a supervisor
    would act on and the needs-decision/blocked/paused/done/failed states. No step-by-step
@@ -52,16 +52,17 @@
    going. A drive-call error, timeout, slow read, or generic unreachability is NOT a daemon error:
    the daemon accepts `respond` immediately and runs the round in the background, so a killed or
    timed-out call was only waiting for a read while the run kept working.
+8. Never add an agent name as a commit co-author on any scratch commit you make here.
 
 # Firstmate instruction inbox
 The move IS the acknowledgement: without it firstmate rings again and eventually treats you as stuck. An empty or absent inbox needs no action.
 
 # Definition of done
 The report must stand alone: what you did, what you found, the evidence (commands run, output, file:line references), and what you recommend.
 If your deliverable is a visual artifact the captain will review and iterate on, you may host the Lavish review loop yourself (poll, revise, re-serve, staying alive) instead of handing it back to firstmate.
 When the report is complete, append `done: {one-line conclusion}` to the status file and stop.
 If your findings reveal work that should ship (e.g. you reproduced a bug and the fix is clear), say so in the report; firstmate may promote this task in place, and you would then receive mode-specific ship instructions as a follow-up message.
diff -ru <HOME>/data/sec-1/brief.md <HOME>/data/sec-1/brief.md
@@ -19,7 +19,7 @@
 Never start a survey, audit, or "find improvements" sweep on your own initiative; that is not your job and it is unwanted.
 
 # The captain and the parent channel
 That file is your parent channel, and in this home it IS the captain: every sentence you would say to the captain, and every outcome the local AGENTS.md tells a firstmate to bring to the captain, is one appended line there, never chat.
 Your own machinery publishes the durable facts about your crew's work for you (`bin/fm-parent-channel-lib.sh`): a child's terminal done or failed line with its note and PR on every supervision poll, a PR-ready line when you register a PR, a task you hold for the captain and its answer, a merge, and a child's final line at cleanup all reach the parent channel from the scripts that record them, whether or not you append anything.
 What only you can append is judgement: the answer to a marked request below, a recommendation or caveat on a delivered outcome, a blocker or failure of your own, and anything else you would otherwise say to the captain.
@@ -39,14 +39,14 @@
 A request arriving through the instruction inbox below follows the same marker and reply rules.
 
 # Firstmate instruction inbox
 The move IS the acknowledgement: without it firstmate rings again and eventually treats you as stuck. An empty or absent inbox needs no action.
 
 # Escalation to main firstmate
 Handle routine work yourself.
 Report only true captain-relevant outcomes or a declared external wait by appending one line:
 States: working, needs-decision, blocked, paused, done, failed.
 Use `paused: {why}` (distinct from `blocked:`) only when your domain is deliberately idling on a known external wait you expect to clear on its own; use `blocked:` when you are stuck and need firstmate to act.
 Use this only for material phase changes, a captain decision, a real blocker, a failure, work ready for review, or work you landed.
diff -ru <HOME>/data/ship-direct-PR/brief.md <HOME>/data/ship-direct-PR/brief.md
@@ -26,7 +26,7 @@
 2. Stay inside this worktree; modify nothing outside it.
 3. Use gh-axi for GitHub operations and chrome-devtools-axi for browser operations.
 4. Report status by appending one line:
    States: working, needs-decision, blocked, paused, done, failed.
    Each append wakes firstmate, so report sparingly: only phase changes a supervisor
    would act on (setup done, bug reproduced, fix implemented, validation passed) and the
@@ -59,17 +59,18 @@
    going. A drive-call error, timeout, slow read, or generic unreachability is NOT a daemon error:
    the daemon accepts `respond` immediately and runs the round in the background, so a killed or
    timed-out call was only waiting for a read while the run kept working.
+8. Never add an agent name as a commit co-author on any commit you make here.
 
 # Firstmate instruction inbox
 The move IS the acknowledgement: without it firstmate rings again and eventually treats you as stuck. An empty or absent inbox needs no action.
 
 # Project memory
 Record only project knowledge useful to almost every future session.
 For anything the codebase already shows, prefer a pointer to the authoritative file, command, or doc over copying the detail.
 Keep it proportionate: skip `AGENTS.md` edits for trivial tasks that produced no durable project knowledge.
 
 # Definition of done
diff -ru <HOME>/data/ship-local-only/brief.md <HOME>/data/ship-local-only/brief.md
@@ -26,7 +26,7 @@
 2. Stay inside this worktree; modify nothing outside it.
 3. Use gh-axi for GitHub operations and chrome-devtools-axi for browser operations.
 4. Report status by appending one line:
    States: working, needs-decision, blocked, paused, done, failed.
    Each append wakes firstmate, so report sparingly: only phase changes a supervisor
    would act on (setup done, bug reproduced, fix implemented, validation passed) and the
@@ -59,17 +59,18 @@
    going. A drive-call error, timeout, slow read, or generic unreachability is NOT a daemon error:
    the daemon accepts `respond` immediately and runs the round in the background, so a killed or
    timed-out call was only waiting for a read while the run kept working.
+8. Never add an agent name as a commit co-author on any commit you make here.
 
 # Firstmate instruction inbox
 The move IS the acknowledgement: without it firstmate rings again and eventually treats you as stuck. An empty or absent inbox needs no action.
 
 # Project memory
 Record only project knowledge useful to almost every future session.
 For anything the codebase already shows, prefer a pointer to the authoritative file, command, or doc over copying the detail.
 Keep it proportionate: skip `AGENTS.md` edits for trivial tasks that produced no durable project knowledge.
 
 # Definition of done
diff -ru <HOME>/data/ship-no-mistakes/brief.md <HOME>/data/ship-no-mistakes/brief.md
@@ -27,7 +27,7 @@
 2. Stay inside this worktree; modify nothing outside it.
 3. Use gh-axi for GitHub operations and chrome-devtools-axi for browser operations.
 4. Report status by appending one line:
    States: working, needs-decision, blocked, paused, done, failed.
    Each append wakes firstmate, so report sparingly: only phase changes a supervisor
    would act on (setup done, bug reproduced, fix implemented, validation passed) and the
@@ -45,8 +45,8 @@
 5. If you hit the same obstacle twice, append `blocked: {why}` and stop; firstmate will help.
 6. If a decision belongs above the implementation worker (product choices, destructive actions),
    append `needs-decision: {summary of options}` and stop. Firstmate will reply with the decision.
    naming every ask-user finding id from that gate. The status line only points at the file; it never restates or summarizes a finding's content.
    A decision or blocker you opened stays open until a `resolved` line carrying its exact key lands; a later `done:` or `working:` line never closes it, even when the answer is what started that work.
    Firstmate's reply normally writes that closing line at answer time; when a blocker or wait clears WITHOUT a firstmate reply, append `resolved: {how it cleared}` yourself (same `[key=<slug>]` if you opened it with one) as you resume.
@@ -62,17 +62,18 @@
    going. A drive-call error, timeout, slow read, or generic unreachability is NOT a daemon error:
    the daemon accepts `respond` immediately and runs the round in the background, so a killed or
    timed-out call was only waiting for a read while the run kept working.
+8. Never add an agent name as a commit co-author on any commit you make here.
 
 # Firstmate instruction inbox
 The move IS the acknowledgement: without it firstmate rings again and eventually treats you as stuck. An empty or absent inbox needs no action.
 
 # Project memory
 Record only project knowledge useful to almost every future session.
 For anything the codebase already shows, prefer a pointer to the authoritative file, command, or doc over copying the detail.
 Keep it proportionate: skip `AGENTS.md` edits for trivial tasks that produced no durable project knowledge.
 
 # Definition of done
```

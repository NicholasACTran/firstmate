# Retried-teardown slot-collision: guard proof

Product driven: `bin/fm-teardown.sh` (the real CLI operators rerun), via the
new regression test's fixture - a Treehouse pool slot, a first teardown pass
that genuinely returns the worktree and then fails on the endpoint close
(non-zero exit, records retained), a different live task that then claims the
freed slot, and the operator's retry.

The test was driven four ways against the real script. `treehouse <return>`
counts come from the fake-`treehouse` runtime log the fixture records, so a
second return is the literal data-loss event (the live task's copy reset).

## 1. Current main (both guards present) - PASS

```
PROBE retry_exit=1
PROBE treehouse_returns_before=1 treehouse_returns_after=1
PROBE live_task_meta_present=yes
PROBE slot_claim=task=live-task home=.../retry-slot-collision/other-home
PROBE retry_stderr:
REFUSED: task stale-task's recorded worktree .../pool/1/project is also task live-task's recorded worktree.
Returning that pool slot would kill live-task's processes and reset its copy, so nothing was changed - not even with --force.
Reconcile whichever record is wrong (bin/fm-crew-state.sh stale-task; bin/fm-crew-state.sh live-task), then re-run teardown.
ok - fm-teardown: a retried teardown after a partial failure never returns a pool slot another task has since claimed
```

The retry refuses, the slot is returned exactly once (by the first, legitimate
pass), the live task's record and slot claim are untouched, and the refusal
names `live-task`.

## 2. Both guards disabled - the test FAILS and the data loss is real

With `require_exclusive_worktree_slot_record` and
`require_owned_worktree_slot_record` stubbed to `return 0` (scratch edit,
reverted; no committed change):

```
PROBE retry_exit=0
PROBE treehouse_returns_before=1 treehouse_returns_after=2
treehouse <return> <--force> </.../retry-slot-collision/worktree>
treehouse <return> <--force> </.../retry-slot-collision/worktree>
not ok - retry-slot-collision: the retry reported success while a live task still holds the slot
```

The retry returns the slot a SECOND time, out from under the live task that
now holds it - exactly the reported hazard. The new test detects it, so it is
not a vacuous always-green assertion.

## 3. Record-exclusivity scan alone (claim guard disabled) - PASS

```
PROBE retry_exit=1
PROBE treehouse_returns_before=1 treehouse_returns_after=1
```

The record scan (#3837) is what carries this exact shape: the reassigned
task's own record is locally discoverable.

## 4. Slot-owner claim alone (record scan disabled) - no data loss, no refusal

```
PROBE retry_exit=0
PROBE treehouse_returns_before=1 treehouse_returns_after=1
warning: task stale-task's recorded worktree .../pool/1/project was reassigned to task live-task (home .../other-home), which claimed that pool slot after this record was written; that slot is no longer stale-task's, so its processes, copy, and claim are left untouched and only stale-task's own cleanup runs.
```

The claim (#4243) independently prevents the second return; it skips the slot
steps rather than refusing, so the strict refusal assertions in the new test
are the record scan's. Defence in depth holds from either side.

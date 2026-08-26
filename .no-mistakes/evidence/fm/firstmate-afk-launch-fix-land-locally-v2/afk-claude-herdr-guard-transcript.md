# Away-mode claude+herdr guard - end-user CLI transcript

Repro of the reported outage shape: on a Claude-primary captain under the herdr backend,
starting the away daemon in the captain pane wedges the busy guard and away mode delivers nothing.
Both entry points now refuse that one combination and name the correct path.

## A) Launcher native path, claude + herdr (the proven-bad pair)
```console
$ CLAUDECODE=1 HERDR_ENV=1 HERDR_PANE_ID=captain-pane bin/fm-afk-launch.sh start-native
fm-afk-launch: refusing start-native on claude+herdr: a claude background shell renders in the captain pane's footer, herdr reads that as the agent working, so the away daemon defers forever and away mode silently delivers nothing
fm-afk-launch: use 'bin/fm-afk-launch.sh start' instead (non-visible daemon terminal)
[exit 1]
$ ls -A state/   # nothing was written: refusal happens before any lifecycle state
(empty)
```

## B) Direct entry bin/fm-afk-start.sh in the same pane, claude + herdr
```console
$ CLAUDECODE=1 HERDR_ENV=1 HERDR_PANE_ID=captain-pane bin/fm-afk-start.sh
afk: refusing to host the away daemon in the same pane it injects into on claude+herdr: a claude background shell renders in that pane's footer, herdr reads that as the agent working, so the away daemon defers forever and away mode silently delivers nothing
afk: use 'bin/fm-afk-launch.sh start' instead (non-visible daemon terminal)
[exit 1]
$ ls -A state/   # away flag rolled back, nothing left behind
(empty)
```

## C) Narrowness - only the proven-bad pair is refused

### C1) claude on the tmux backend, launcher native path -> permitted
```console
$ CLAUDECODE=1 TMUX_PANE=%7 FM_SUPERVISOR_BACKEND=tmux bin/fm-afk-launch.sh start-native
[exit 0]
$ cat state/.afk-daemon-terminal   # lifecycle recorded: native, no terminal
none	-	native
```

### C2) a non-claude harness (pi) on herdr, launcher native path -> permitted
```console
$ PI_CODING_AGENT=true HERDR_ENV=1 HERDR_PANE_ID=captain-pane bin/fm-afk-launch.sh start-native
[exit 0]
$ cat state/.afk-daemon-terminal
none	-	native
```

### C3) the legitimate terminal-backed path: claude + herdr, daemon in its OWN pane
targeting the captain pane -> permitted (different panes, so no self-injection).
The real supervise daemon is replaced with /usr/bin/true here so the permitted start is
observable as its own announcement instead of blocking on a long-lived daemon.
```console
$ CLAUDECODE=1 HERDR_ENV=1 HERDR_PANE_ID=daemon-pane FM_SUPERVISOR_TARGET=default:captain-pane bin/fm-afk-start.sh
afk: starting supervise daemon in foreground; keep this command as a tracked background session
[exit 0]
$ ls -A state/   # away mode actually entered
.afk
```

### C4) an already-running away daemon refreshed from the captain pane on claude+herdr
-> takes the existing refresh path, never the refusal (nothing is being started).
```console
$ CLAUDECODE=1 HERDR_ENV=1 HERDR_PANE_ID=captain-pane bin/fm-afk-start.sh   # daemon already live
afk: daemon already running pid=4242
[exit 0]
```

## D) Before the fix (same commands, guard files reverted to base 07bf0c8)
The wedge was fully reachable: both entry points accepted claude+herdr and entered away mode.
```console
$ CLAUDECODE=1 HERDR_ENV=1 HERDR_PANE_ID=captain-pane bin/fm-afk-launch.sh start-native
[exit 0]
$ ls -A state/   # away mode was entered on the proven-bad pair
.afk
.afk-daemon-terminal
```
```console
$ CLAUDECODE=1 HERDR_ENV=1 HERDR_PANE_ID=captain-pane bin/fm-afk-start.sh   # daemon stubbed
afk: starting supervise daemon in foreground; keep this command as a tracked background session
[exit 0]
$ ls -A state/
.afk
```

## E) Guard regression tests, run against the pre-fix code
The new tests in tests/fm-afk-launch.test.sh fail on base and pass on the fix, while the
narrowness cases pass in both - proving a targeted guard, not a blanket refusal.
```console
$ bash tests/fm-afk-launch.test.sh   # bin/ guards reverted to 07bf0c8
not ok - native guard: claude+herdr native launch was accepted
not ok - native guard: refusal did not name the terminal-backed path
ok - native guard: claude on a non-herdr backend is still permitted
ok - native guard: a non-claude harness on herdr is still permitted
not ok - start guard: claude+herdr self-injection was accepted (afk: starting supervise daemon in foreground; keep this command as a tracked background session
not ok - start guard: refusal did not name the terminal-backed path (afk: starting supervise daemon in foreground; keep this command as a tracked background session
ok - start guard: claude+herdr in the launcher's own separate pane is permitted
ok - start guard: an override naming a different pane is permitted
not ok - start guard: an operator-set override reopened the self-injection wedge (afk: starting supervise daemon in foreground; keep this command as a tracked background session
ok - start guard: a non-claude harness in the same pane is permitted
ok - start guard: a refresh of a live daemon takes the refresh path, not the refusal
ok - start guard: an unresolvable pane permits rather than blocks
not ok - start guard: unresolvable state permitted silently (afk: starting supervise daemon in foreground; keep this command as a tracked background session
```
```console
$ bash tests/fm-afk-launch.test.sh   # at 6eb3cd8 (this change)
ok - native guard: claude+herdr is refused with no lifecycle state written
ok - native guard: refusal names the terminal-backed path
ok - native guard: claude on a non-herdr backend is still permitted
ok - native guard: a non-claude harness on herdr is still permitted
ok - start guard: claude+herdr self-injection is refused with no lifecycle state left behind
ok - start guard: refusal names the terminal-backed path
ok - start guard: claude+herdr in the launcher's own separate pane is permitted
ok - start guard: an override naming a different pane is permitted
ok - start guard: an override naming this process's own pane is still refused
ok - start guard: a non-claude harness in the same pane is permitted
ok - start guard: a refresh of a live daemon takes the refresh path, not the refusal
ok - start guard: an unresolvable pane permits rather than blocks
ok - start guard: unresolvable state emits the could-not-check diagnostic
```

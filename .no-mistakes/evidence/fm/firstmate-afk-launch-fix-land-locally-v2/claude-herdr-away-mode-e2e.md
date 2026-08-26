# Real herdr session: Claude captain enters away mode

Live herdr lab session `fm-lab-afk-evidence-17389`; captain pane `w1:p1` (workspace w1).
The shell below runs AS the captain: HERDR_ENV=1, HERDR_PANE_ID=w1:p1, CLAUDECODE=1.

## Step 1 - the old native two-step is now refused
```
$ bin/fm-afk-launch.sh start-native
fm-afk-launch: refusing start-native on claude+herdr: a claude background shell renders in the captain pane's footer, herdr reads that as the agent working, so the away daemon defers forever and away mode silently delivers nothing
fm-afk-launch: use 'bin/fm-afk-launch.sh start' instead (non-visible daemon terminal)
exit=1
$ ls -A state/
(empty - no lifecycle state written)
```

## Step 2 - the direct daemon entry point refuses the same self-injection
```
$ FM_AFK_STATE_PREPARED=1 bin/fm-afk-start.sh
afk: refusing to host the away daemon in the same pane it injects into on claude+herdr: a claude background shell renders in that pane's footer, herdr reads that as the agent working, so the away daemon defers forever and away mode silently delivers nothing
afk: use 'bin/fm-afk-launch.sh start' instead (non-visible daemon terminal)
exit=1
$ ls -A state/
(still empty - away mode never half-entered)
```

## Step 3 - the prescribed path: bin/fm-afk-launch.sh start
```
$ bin/fm-afk-launch.sh start
fm-afk-launch: daemon launched in non-visible herdr workspace w2 (pane fm-lab-afk-evidence-17389:w2:p1), supervising fm-lab-afk-evidence-17389:w1:p1
exit=0
$ cat state/.afk-daemon-terminal
herdr	fm-lab-afk-evidence-17389:w2:p1	w2
$ ls -A state/
.afk
.afk-daemon-terminal
```

| observation | before | after start |
| --- | --- | --- |
| herdr workspaces in session | 1 | 2 |
| panes in the captain's tab | 1 | 1 |

Daemon terminal: `fm-lab-afk-evidence-17389:w2:p1` in tab `w2:t1`; captain tab is `w1:t1` - a different tab, so the daemon is NOT hosted in the pane it injects into.

## Step 4 - the daemon pane itself may run fm-afk-start.sh (different pane, permitted)
```
$ FM_AFK_STATE_PREPARED=1 bin/fm-afk-start.sh   # run from the daemon pane
afk: starting supervise daemon in foreground; keep this command as a tracked background session
exit=0
```

## Step 5 - stop restores the topology
```
$ bin/fm-afk-launch.sh stop
fm-afk-launch: away mode stopped; daemon terminal torn down and .afk cleared
exit=0
```

After stop: workspaces=1 (was 1), captain tab panes=1 (was 1), state/ = 

# CLI transcript: away-mode launch on a claude captain under herdr

## 1. BEFORE the fix (commit 6262d7c, docs-only) - the wedge is reachable

$ CLAUDECODE=1 FM_SUPERVISOR_BACKEND=herdr bin/fm-afk-launch.sh start-native
(exit 0)
$ cat state/.afk-daemon-terminal   # accepted: daemon hosted in the claude pane -> herdr reads the footer shell as "working" for the session
none	-	native

## 2. AFTER the fix (HEAD e588b16) - the same command is refused
$ CLAUDECODE=1 FM_SUPERVISOR_BACKEND=herdr bin/fm-afk-launch.sh start-native
fm-afk-launch: refusing start-native on claude+herdr: a claude background shell renders in the captain pane's footer, herdr reads that as the agent working, so the away daemon defers forever and away mode silently delivers nothing
fm-afk-launch: use 'bin/fm-afk-launch.sh start' instead (non-visible daemon terminal)
(exit 1)
$ ls state/   # no lifecycle state written, nothing to roll back
(empty)

## 3. AFTER the fix - the guard is narrow, neighbouring setups still work
$ CLAUDECODE=1 FM_SUPERVISOR_BACKEND=tmux bin/fm-afk-launch.sh start-native   # claude, non-herdr
(exit 0) -> state/.afk-daemon-terminal = none	-	native
$ PI_CODING_AGENT=true FM_SUPERVISOR_BACKEND=herdr bin/fm-afk-launch.sh start-native   # non-claude, herdr
(exit 0) -> state/.afk-daemon-terminal = none	-	native

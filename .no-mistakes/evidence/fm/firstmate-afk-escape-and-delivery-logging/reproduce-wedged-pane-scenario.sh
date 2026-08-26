#!/usr/bin/env bash
# Reproduces the 2026-08-26 wedged-away-mode scenario end to end:
# the supervisor pane reports busy (herdr native agent-state) forever while its
# composer is provably empty - an idle claude pane misread as busy. The daemon's
# real inject_msg is driven on a real poll cadence and writes its real log.
set -u
ROOT=$1; STATE=$2; export FM_STATE_OVERRIDE=$STATE
mkdir -p "$STATE"
FM_TEST_DAEMON_SOURCED=1 . "$ROOT/bin/fm-supervise-daemon.sh"
LOG="$STATE/.supervise-daemon.log"
afk_enter "$STATE"
printf 'digest item: task alpha needs a decision\n' > "$STATE/.subsuper-escalations"
_now > "$STATE/.subsuper-escalations.since"

# The wedged pane: exists, native state reads busy, composer reads empty.
fm_backend_target_exists() { return 0; }
fm_backend_busy_state() { printf 'busy'; }
fm_backend_composer_state() { printf 'empty'; }
fm_backend_send_text_submit() { printf '%s' "$3" > "$STATE/typed.txt"; printf 'empty'; }

resolve_busy_guard_escape_secs
resolve_busy_empty_streak_step_max
log "daemon starting (pid $$); target=default:w1:p2; backend=herdr; afk=on; busy_guard_escape=${BUSY_GUARD_ESCAPE_SECS_RESOLVED}s"

tick=0
while [ "$tick" -lt 8 ]; do
  tick=$((tick+1))
  if inject_msg "away-supervisor digest: task alpha needs a decision" "$STATE"; then
    log "main loop: escalation buffer flushed at tick ${tick}"
    break
  fi
  sleep "${FM_HOUSEKEEPING_TICK}"
done

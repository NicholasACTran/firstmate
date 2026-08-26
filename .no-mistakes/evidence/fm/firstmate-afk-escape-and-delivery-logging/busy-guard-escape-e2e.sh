#!/usr/bin/env bash
# End-to-end evidence for the away-mode busy-guard escape bound.
#
# Reproduces the 2026-08-26 investigation's false positive with a REAL daemon
# process and a REAL tmux supervisor pane: the pane renders a stale claude busy
# footer ("esc to interrupt") that never clears, while the composer below it is
# genuinely idle and empty. Pre-fix, inject_msg defers forever and away mode
# goes silent. Two runs are captured:
#
#   Run 1: FM_BUSY_GUARD_ESCAPE_SECS=10 - the escape must fire and DELIVER.
#   Run 2: FM_BUSY_GUARD_ESCAPE_SECS=0  - the pre-fix behavior: defers forever.
set -u
ROOT="$1"; OUT="$2"
DAEMON="$ROOT/bin/fm-supervise-daemon.sh"
REAL_TMUX=$(command -v tmux) || { echo "skip: no tmux"; exit 0; }
SOCKET="afk-escape-ev-$$"
STATE_DIR=$(mktemp -d "${TMPDIR:-/tmp}/fm-escape-ev.XXXXXX")
SHIM_DIR=$(mktemp -d "${TMPDIR:-/tmp}/fm-escape-shim.XXXXXX")
SUBMITTED="$STATE_DIR/submitted.log"
: > "$SUBMITTED"
DAEMON_PID=

cleanup() {
  [ -z "${DAEMON_PID:-}" ] || { kill "$DAEMON_PID" 2>/dev/null || true; wait "$DAEMON_PID" 2>/dev/null || true; }
  "$REAL_TMUX" -L "$SOCKET" kill-server 2>/dev/null || true
  rm -rf "$SHIM_DIR" "$STATE_DIR"
}
trap cleanup EXIT

. "$DAEMON"

"$REAL_TMUX" -L "$SOCKET" new-session -d -s supervisor -x 200 -y 50
PANE=$("$REAL_TMUX" -L "$SOCKET" display-message -p -t supervisor '#{pane_id}')

# Supervisor pane fixture: logs each submitted line, and renders a STALE claude
# busy footer above an idle empty composer row - the exact shape that makes an
# idle pane read busy to the rendered-pane regex fallback.
LOOP="$STATE_DIR/loop.sh"
cat > "$LOOP" <<'LOOPEOF'
#!/usr/bin/env bash
MARK=$'\xE2\x81\xA3'
LOG="$1"
OLD=$(stty -g 2>/dev/null || true)
[ -z "$OLD" ] || stty -echo -icanon min 1 time 0 2>/dev/null || true
trap '[ -z "$OLD" ] || stty "$OLD" 2>/dev/null || true' EXIT INT TERM
_buf=
redraw() {
  # stale busy footer (never clears) + idle composer row below it
  printf '\r\033[K\xe2\x9c\xbb Thinking\xe2\x80\xa6 (901s \xc2\xb7 esc to interrupt)\n'
  printf '\r\033[K\xe2\x9d\xaf %s' "$_buf"
}
submit() {
  local l=$_buf c
  if [ "${l:0:1}" = "$MARK" ]; then c=injection; else c=user; fi
  printf '%s\t%s\n' "$c" "$l" >> "$LOG"
  _buf=; printf '\r\033[K\n'; redraw
}
redraw
while IFS= read -r -n 1 ch; do
  if [ -z "$ch" ]; then submit; continue; fi
  case "$ch" in
    $'\r'|$'\n') submit ;;
    $'\177'|$'\b') _buf=${_buf%?}; redraw ;;
    *) _buf="${_buf}${ch}"; redraw ;;
  esac
done
LOOPEOF
chmod +x "$LOOP"

cat > "$SHIM_DIR/tmux" <<SHIM
#!/usr/bin/env bash
exec "$REAL_TMUX" -L "$SOCKET" "\$@"
SHIM
chmod +x "$SHIM_DIR/tmux"
"$REAL_TMUX" -L "$SOCKET" new-window -d -n fm-fake-c1 -t supervisor

run_case() {  # <label> <escape_secs> <wait_secs> <pr>
  local label=$1 secs=$2 waitfor=$3 pr=$4 i
  rm -f "$STATE_DIR"/*.status "$STATE_DIR"/.subsuper-* "$STATE_DIR"/.supervise-daemon.log \
        "$STATE_DIR"/.seen-* "$STATE_DIR"/.last-* "$STATE_DIR"/.hash-* 2>/dev/null || true
  : > "$SUBMITTED"
  # Restart the fixture on a cleared pane so the captured operator view shows
  # only this run.
  "$REAL_TMUX" -L "$SOCKET" send-keys -t "$PANE" C-c
  sleep 0.5
  "$REAL_TMUX" -L "$SOCKET" send-keys -t "$PANE" "clear && bash '$LOOP' '$SUBMITTED'" Enter
  sleep 1
  "$REAL_TMUX" -L "$SOCKET" clear-history -t "$PANE"
  afk_enter "$STATE_DIR"
  PATH="$SHIM_DIR:$PATH" FM_STATE_OVERRIDE="$STATE_DIR" FM_SUPERVISOR_TARGET="$PANE" \
    FM_SUPERVISOR_BACKEND=tmux FM_ESCALATE_BATCH_SECS=0 FM_HOUSEKEEPING_TICK=1 FM_POLL=1 \
    FM_SIGNAL_GRACE=1 FM_HEARTBEAT=999999 FM_CHECK_INTERVAL=999999 FM_INJECT_CONFIRM_SLEEP=0.3 \
    FM_INJECT_CONFIRM_RETRIES=5 FM_STALE_ESCALATE_SECS=999999 FM_MAX_DEFER_SECS=0 \
    FM_BUSY_GUARD_ESCAPE_SECS="$secs" \
    nohup "$DAEMON" >"$STATE_DIR/daemon.out" 2>"$STATE_DIR/daemon.err" &
  DAEMON_PID=$!
  i=0; while [ $i -lt 30 ] && [ ! -f "$STATE_DIR/.supervise-daemon.pid" ]; do sleep 0.2; i=$((i+1)); done
  echo "done: PR https://example.test/pr/$pr" > "$STATE_DIR/fake-c1.status"
  i=0
  while [ $i -lt "$waitfor" ]; do
    grep -q injection "$SUBMITTED" && break
    sleep 1; i=$((i+1))
  done
  # After the digest lands, give the daemon its submit-confirmation window so
  # the delivery log line and .subsuper-last-delivery are captured too.
  if grep -q injection "$SUBMITTED"; then
    i=0
    while [ $i -lt 15 ] && [ ! -f "$STATE_DIR/.subsuper-last-delivery" ]; do sleep 1; i=$((i+1)); done
  fi
  {
    echo "=============================================================="
    echo "== $label  (FM_BUSY_GUARD_ESCAPE_SECS=$secs)"
    echo "=============================================================="
    echo "--- supervisor pane as the operator would see it -------------"
    "$REAL_TMUX" -L "$SOCKET" capture-pane -p -t "$PANE" | grep -v '^[[:space:]]*$' \
      | grep -v "loop.sh" | uniq | tail -4
    echo "--- state/.supervise-daemon.log (inject lines) ---------------"
    grep -E 'daemon starting|inject ' "$STATE_DIR/.supervise-daemon.log" | sed 's/^/  /'
    echo "--- what actually landed in the supervisor pane --------------"
    if grep -q injection "$SUBMITTED"; then grep injection "$SUBMITTED" | sed 's/^/  /'; else echo "  (no escalation submitted - away mode silent)"; fi
    echo "--- state/.subsuper-last-delivery ----------------------------"
    if [ -f "$STATE_DIR/.subsuper-last-delivery" ]; then
      echo "  epoch=$(cat "$STATE_DIR/.subsuper-last-delivery") ($(date -r "$(cat "$STATE_DIR/.subsuper-last-delivery")" 2>/dev/null))"
    else
      echo "  (absent - no delivery ever succeeded this session)"
    fi
    echo
  } >> "$OUT"
  afk_exit "$STATE_DIR" 2>/dev/null || true
  kill "$DAEMON_PID" 2>/dev/null || true; wait "$DAEMON_PID" 2>/dev/null || true; DAEMON_PID=
  sleep 1
}

: > "$OUT"
run_case "RUN 1 - escape bound ENABLED (10s): stale busy footer must not silence away mode" 10 40 4210
run_case "RUN 2 - escape DISABLED (0 = pre-fix behavior): busy guard defers forever" 0 25 4220
echo "wrote $OUT"

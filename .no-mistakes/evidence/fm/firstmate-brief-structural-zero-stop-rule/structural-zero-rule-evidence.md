# Structural-zero stop rule - end-to-end evidence

Real briefs generated from bin/fm-brief.sh (paths rewritten to $FM_HOME):
```
$ fm-brief.sh evidence-ship demo-proj --mode no-mistakes
$ fm-brief.sh evidence-scout demo-proj --scout
$ fm-brief.sh evidence-charter demo-proj --secondmate
```

## Rule 8 as it renders in the generated SHIP brief
```
8. A zero at a named stage is a stop condition, not a data point to replicate. If a whole class
   reaches no finding at that stage while other classes clear the same stage in the same run, the
   cause is structural and no further draw can change it: confirm with at most one more draw, then
   stop and report rather than running remaining arms to completion for symmetry. The caution that
   one draw cannot distinguish a mechanism from a draw does not apply here - that is about a NUMBER
   that varies between draws, not about nothing reaching a stage at all. Report the stop as a
   complete outcome: the finding is the answer, and the unrun draws are a saving, not a gap.
```

## Rule 8 as it renders in the generated SCOUT brief
```
8. A zero at a named stage is a stop condition, not a data point to replicate. If a whole class
   reaches no finding at that stage while other classes clear the same stage in the same run, the
   cause is structural and no further draw can change it: confirm with at most one more draw, then
   stop and report rather than running remaining arms to completion for symmetry. The caution that
   one draw cannot distinguish a mechanism from a draw does not apply here - that is about a NUMBER
   that varies between draws, not about nothing reaching a stage at all. Report the stop as a
   complete outcome: the finding is the answer, and the unrun draws are a saving, not a gap.
```

## Secondmate charter (scope decision: no Rules section, rule intentionally absent)
```
$ grep -c "^# Rules" evidence-charter/brief.md   -> 0
$ grep -c "zero at a named stage" evidence-charter/brief.md -> 0
charter sections:
# Charter
# Routing scope
# Project clones
# Operating model
# Requests from the main firstmate
# Firstmate instruction inbox
# Escalation to main firstmate
# Definition of done
```

## Regression check: new test fails on the base scaffold
```
$ (base commit bca584a + new test) bash tests/fm-brief.test.sh
not ok - ship brief Rules section missing the structural-zero stop rule

$ (this branch) bash tests/fm-brief.test.sh
ok - fm-brief.sh: structural-zero stop rule lands in generated ship and scout briefs
```

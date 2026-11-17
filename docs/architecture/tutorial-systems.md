# Tutorial systems and architecture decisions

Author: Andre Henriques. Written November 2, 2026 as a post-sprint follow-up.
This documents Sprint 2 implementation and the current audit separately; it does
not imply the documentation or new reviews existed during the sprint.

## Delivered behavior and ownership

The Sprint 2 tutorial connects menu entry, five camera views, timed glove launches,
a speed carrot, sibling rescue and replay. Andre implemented camera progression
(IS-55, [#19](https://github.com/andre-henriques04/island-hoppers/pull/19) and
[#20](https://github.com/andre-henriques04/island-hoppers/pull/20)), interactive
gloves (IS-54, [#21](https://github.com/andre-henriques04/island-hoppers/pull/21)),
and rescue/retry/fall recovery (IS-56,
[#22](https://github.com/andre-henriques04/island-hoppers/pull/22)).

Andre's [#18](https://github.com/andre-henriques04/island-hoppers/pull/18)
integrated Griffin's menu/layout/slope branches while preserving animation assets.
Griffin authored those components and later player-height fixes (#23) and final
demo integration (#26), including animation selection, carrot placement and music.
Alexa supplied animations/sibling art, Caleb power-up behavior, and Yaritza
background/map artwork and published team meeting summaries. Integration credit
does not transfer authorship of those components.

## Runtime structure

`project.godot` starts `scenes/main_menu.tscn`. The menu controller opens
`scenes/main.tscn`. Its root runs `tutorial_camera.gd`; the player node
`PlayerCharacter` runs `CharacterMovement.gd`. Reusable boxing-glove scenes run
`boxing_glove.gd`, extending the original `timing_obstacle.gd`. `TutorialFlow`
manages retry and goal contact. `session_progress.gd` shares completion with the
menu.

Keyboard input enters the player controller; physics updates movement, collision
and animation. The camera selects a view from the player's position. Glove contact
calls `apply_obstacle_launch()`, and the carrot calls `activate_speed_boost()`.
Sibling contact records completion, emits the completion event, shows feedback,
and returns to the menu. Play starts a fresh run. R/fall recovery resets temporary
player state, restores the active respawn position and synchronizes the camera.

## IS-55: fixed views, backtracking and hysteresis

**Decision:** select among the five existing authored cameras, allow reverse
travel and use a 24-pixel boundary margin to reduce oscillation.

**Reason:** retain the authored puzzle composition while allowing the player to
cross boundaries without changing position or velocity. A continuous follow
camera would change how much of the designed challenge is visible.

**Tradeoff:** camera offsets and terrain changes need boundary retesting.
`sync_camera_to_player()` handles retry/checkpoint placement, including positions
close to a boundary; distant teleports are also detected automatically.

PR #19 targeted the integration branch after #18 had already merged. PR #20
brought the camera changes into main. Its fixed logical viewport settings were
later removed by PR #26, so current main does not guarantee the original resize
behavior. See [camera checks](../testing/tutorial-camera.md).

## IS-54: timing reuse and directional launch

**Decision:** extend the Sprint 1 timing component instead of copying its cycle
into each placed glove. The base component owns rest/warning/extension/recovery;
the glove owns its sprite frames and launch behavior.

**Reason:** keep timing configurable and reusable while synchronizing punch art
and active collision. Monitoring activates after extension. A per-punch body
dictionary prevents one punch repeatedly launching the same player after re-entry.

Local UP rotated into world space defines the impulse; sideways launches include
an upward assist. The controller briefly preserves that velocity so keyboard input
does not immediately cancel it.

**Tradeoff:** launch tuning depends on actual collider size and route geometry.
Neither an inactive hitbox nor a warning implies a solid standing platform.
See [glove checks](../testing/tutorial-glove.md).

## IS-56: guarded completion and a shared handoff

**Decision:** use one guarded completion event, shared in-memory session state,
and the existing home screen as the ticket's permitted temporary fallback.

**Reason:** show a clear rescue result and support replay while IS-60 owns shared
island selection/unlocks. This keeps tutorial behavior from creating a second
independent navigation/progression system. The completion guard prevents repeated
goal events while the fade runs.

**Tradeoff:** completion resets after restarting the application. No persistent
save or unavailable-island unlock is implemented. Retry clears velocity, launch
lock, timers and pickup effects before camera synchronization.
`set_checkpoint(world_position)` provides a handoff API; visible checkpoints are
not integrated. See [completion checks](../testing/tutorial-completion.md).

## Evidence and current validation

The original PR descriptions record development-time checks. The
[October 21 standup](https://notes.wisprflow.ai/shared/uYSBaMlycZMSiiWgG767rocE98stZd_s0TBt0ptcfko)
records Andre demonstrating camera changes, glove launch, retry and rescue, while
raising narrow passages and the missing speed pickup. Griffin addressed later
layout/demo work in #23/#26. The
[demo script](https://docs.google.com/document/d/1rLEEd1i2lsIfCyH070gyXu_FZmM_DECTOE03ncK7Rh0/edit)
and October 25 retrospective describe the connected tutorial.

**November 2 audit, main at `28a03ba`:** Godot 4.7.2 import completed with restricted
local settings/certificate warnings. `tests/tutorial_flow_checks.gd` reports PASS,
with cleanup/resource warnings. `tests/glove_checks.gd` fails its scripted
ledge-landing expectation against later terrain. The glove practice script/check
and completion practice scene still reference the old `CharacterBody2D` node.
These require follow-up; neither a clean glove result nor a fresh uninterrupted
manual route is claimed. See the [current checklist](../sprint-2-follow-up.md).

Cloud Island PRs #13/#14/#17/#27 and abilities/checkpoints PR #24 remain open.
Browser delivery IS-25 remains To Do. Shared selection/unlocks, permanent saves,
dialogue, sibling abilities and cosmetics remain future work.

## Project documentation

- [Confluence feature and architecture guide](https://txst-fall26-cs3398-009-team04.atlassian.net/wiki/spaces/I/pages/28114945/Sprint+2+-+Tutorial+Features+and+Architecture+Decisions)
- [IS-61 planning and epic organization](https://txst-fall26-cs3398-009-team04.atlassian.net/browse/IS-61)
- [October 6 planning](https://notes.wisprflow.ai/shared/PCIt7JX53Dmj_sotN74wnBfYD9LGu0hhAupPqoXjBUY)

IS-54/55/56 story points are provisional estimates, not evidence of a team
planning-poker vote. Post-sprint reporter changes are administrative and do not
establish independent review. Andre supplied planning/standup/retrospective
transcripts; Yaritza authored the published meeting summaries.

# Sprint 2 follow-up checklist

Updated November 2, 2026 after auditing main at `28a03ba`. This is a post-sprint
reconciliation; original PR descriptions are records of their development stage.

## Delivered through Sprint 2

- [x] IS-55 camera progression merged through PR #20.
- [x] IS-54 timed directional glove launches merged through PR #21.
- [x] IS-56 rescue, retry, fall recovery and replay merged through PR #22.
- [x] Griffin's player-height layout changes merged through PR #23 / IS-68.
- [x] Griffin's final demo integration merged through PR #26 / IS-69, including
  carrot placement, animation state selection and menu/tutorial music.

The demo script and retrospective describe the connected tutorial. This does not
establish a new manual acceptance test of current main.

## Current regression and verification follow-ups

- [ ] Repair old `CharacterBody2D` references in the glove practice script/check
  and completion practice scene; the actual player node is `PlayerCharacter`.
- [ ] Reconcile the glove suite's scripted landing expectation with the changed
  tutorial terrain, and verify the intended route using the real collider.
- [ ] Recheck menu sizing/camera coverage; PR #26 removed the logical viewport.
- [ ] Investigate cleanup/resource warnings after completion/retry checks.
- [ ] Perform a fresh full route: menu, all sections, glove, carrot, sibling,
  return home, replay, and recovery after a failed jump. Record exact observations.
- [ ] Assess the requested solid resting-glove platform behavior separately;
  do not assume that an inactive punch hitbox is a solid standing surface.

November 2 checks: import completed with sandbox settings/certificate warnings;
completion/retry suite PASS with cleanup warnings; glove suite failed the landing
expectation and encountered stale node-path errors. No clean glove result claimed.

## Scope and open integration

- [ ] Visible checkpoint integration with TutorialFlow and camera synchronization.
  Retry defaults to the entrance; the checkpoint handoff API is available.
- [ ] Review/fix PR #24 abilities/checkpoints before integration. Griffin's
  October 26 comment reports dash/glide errors and a missing respawn dependency.
- [ ] Review #13 animation art, #14 Cloud Island, #17 moving platforms, and #27
  Cloud Island background. #17 targets #14's branch; keep this dependency visible
  and preserve the menu entry point when resolving #14 against main.
- [ ] Reconcile Done Jira Cloud cards with still-open development PRs. This is
  work for the relevant owners; this documentation update does not change them.
- [ ] Shared selection/unlock UI (IS-60), optional persistent saves, dialogue,
  cutscenes, sibling abilities and cosmetics remain later scope.
- [ ] IS-57 audio backlog has broader acceptance than the music in IS-63/IS-69:
  movement sound effects, licensing/source records and volume/mute still need
  verification. Avoid claiming these tasks are interchangeable.
- [ ] Browser delivery IS-25 remains To Do, separate from the local demo.

## Review process

Use ticket-key-type-description branch names for new work. Provide PR scope,
reviewer focus and real validation results. Request teammate review, respond to
actual comments, and record testing observations on teammates' PRs. New comments
or requests are post-sprint activity and cannot substitute for missing historical
review evidence.

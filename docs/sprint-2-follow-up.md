# Sprint 2 follow-up checklist

## Current handoff

- [x] IS-55 camera progression: tested and merged through PR #20.
- [x] IS-54 glove timing/launch: tested and merged through PR #21.
- [ ] IS-56: test completion/retry PR, review and merge it; keep full-route
  acceptance open until the layout and dependency checks below pass.

## Finish the tutorial

- [ ] Griffin: widen tight passages and review tile collision geometry with the
  real 60×144 bunny collider. Keep the existing jump/launch tuning while testing.
- [ ] Make the glove a solid platform while resting; landing on it must not
  fall through. Check collision during extension/retraction and repeated landings.
  Upward launch height is already sufficient; avoid increasing it to solve geometry.
- [ ] Integrate Caleb's carrot/rotten-carrot and checkpoint work from the actual
  branch/PR. The final carrot gap needs measured tuning, not an assumed speed.
- [ ] Place visible checkpoints and validate retry, effect cleanup and camera
  selection from each one. Current retry falls back to the tutorial entrance.
- [ ] Complete one uninterrupted route: menu → all tutorial sections → glove
  launch → carrot challenge → sibling → menu → replay, including a failed jump.
- [ ] Confirm idle/jump animation state selection with Caleb; merged animation
  resources alone do not make the controller select those states.

## Presentation and backlog

- [ ] Revisit the menu's right-edge background sizing at multiple window sizes.
- [ ] Integrate available menu/tutorial music and review IS-57 against IS-63 so
  audio assets and runtime sound integration are not counted as the same work.
- [ ] Shared island selection, completion/unlock UI and optional persistent saves.
- [ ] Hidden accessory/cosmetics (IS-58), fruit score/gating, sibling dialogue,
  boat departure/cutscene and sibling switching/abilities remain later scope.
- [ ] Browser delivery (IS-25) remains separately tracked, outside the local demo.

## Griffin's open Cloud Island PRs

- [ ] #13: checkpoint animation artwork only. Review/import it independently;
  merging it does not implement checkpoint behavior.
- [ ] #17: moving platforms targets #14's Cloud Island branch. Test/merge #17
  into that branch before merging the combined #14 into main, avoiding another
  follow-up integration like #19/#20.
- [ ] #14: test the combined Cloud Island. Preserve the main-menu project entry
  point when resolving project.godot; the Cloud branch currently selects Cloud
  Island directly. GitHub currently reports merge conflicts, so resolve those
  before merging. Do not expose it in selection until the route/retry works.
- [ ] Recheck both Cloud PRs against the current controller and tutorial flow
  before merging. These PRs are not required to finish the tutorial ending.

Jira: accepted camera/glove implementation is Done; completion belongs In Review
while its PR is open. Tutorial epic stays In Progress until full-route acceptance.

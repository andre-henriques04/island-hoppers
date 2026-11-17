# Tutorial completion and retry (IS-56)

## Quick ending test

Run `godot --path . res://scenes/completion_practice.tscn`, or open that scene
in Godot and choose Run Current Scene. This is the actual tutorial with only
its starting position overridden for testing; the normal project entrance is
unchanged.

Walk right toward the sibling. A "Sibling rescued!" message and fade should
appear once, then the home screen should show that the tutorial is complete.
Select Play: a fresh tutorial should start at the entrance with working controls.
Completion is remembered for this running game session, not saved to disk.

## Retry test

Run Project → Play. Move and jump, then press R: return to the entrance and
first camera with movement restored. Speed/jump modifiers and glove launch
state should clear. Esc returns to the home screen without claiming a rescue.

To check fall recovery, pause, select the Remote CharacterBody2D, set its
position to `(4500, 600)`, and resume. It should return to the entrance and
first view. Stop/restart to discard remote changes.

Shared checkpoint objects can call `TutorialFlow.set_checkpoint(world_position)`.
Retry then uses that location and synchronizes the camera immediately. No visible
checkpoint objects are added here: Caleb's checkpoint implementation still needs
to be supplied/integrated. The default fallback is the entrance.

## Acceptance boundary

The home screen is the documented temporary fallback allowed by IS-56. Shared
session progress records tutorial completion for later island-selection work;
this does not create a second selection screen or unlock an unavailable island.

A full uninterrupted route playthrough is still blocked by the tight tutorial
passages reported during testing and pending pickup/checkpoint integration.
Griffin's layout adjustments must be tested with the actual bunny collider.
The completion practice scene verifies the ending independently of those blockers.

## Automated checks

`godot --headless --path . --fixed-fps 60 --script tests/tutorial_flow_checks.gd`

Checks menu entry, repeated Play presses, R and fall recovery, reset of movement
state, checkpoint camera handoff, Esc, physical goal contact, completion once,
session progress, return home and a second completed run after replay.

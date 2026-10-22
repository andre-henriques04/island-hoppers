# Tutorial glove checks (IS-54)

## Quick practice

Open `scenes/glove_practice.tscn` in Godot and choose Run Current Scene (F6),
or run `godot --path . res://scenes/glove_practice.tscn`.

- Arrows move; Space jumps; R resets the practice scene.
- Stay over the left glove: amber warns, then its extended red fist launches
  the bunny onto the high platform. The warning and recovery must be safe.
- Walk toward the right glove: its punch should send the bunny left and slightly
  upward. Holding Right must not immediately cancel that impulse.
- Repeat several cycles. One punch must not launch the same bunny twice,
  even after leaving and re-entering its hitbox. Later punches can launch again.

## Actual tutorial

Run Project and select Play. Both original glove placements now use the reusable
boxing-glove scene. Normal route access still depends on the pending pickup and
completion work; this PR does not claim a complete tutorial playthrough.

For a quick route-specific check, pause and use Remote Inspector to place
CharacterBody2D at `(3900, -296)`, then resume on the approach platform.
Jump right toward the raised glove when its amber warning first appears.
Stop moving right when aligned with the glove (around x=4027).
During the launch, steer left once
above the first ledge to land on it (around x=3900, y=-680). This uses the actual
60×144 bunny collider and unchanged tutorial terrain. Merely walking under the
raised glove from the lowest floor does not reach its fist: use the approach
platform and the timed jump.

The other glove, near `(3664, -1729)`, faces left. It warns, punches left with
an upward assist, then recovers. Neither glove is lethal.

Stop and rerun to restore the tutorial entrance. Do not save remote test positions.
The practice scene's R shortcut is not a tutorial retry/checkpoint implementation.

## Automated checks

`godot --headless --path . --fixed-fps 60 --script tests/glove_checks.gd`

Checks warning/recovery safety, physical contact, per-punch deduplication,
rotation-based impulses, later reactivation, actual tutorial ledge reach,
practice-platform landing, retained speed effects and the original prototype.

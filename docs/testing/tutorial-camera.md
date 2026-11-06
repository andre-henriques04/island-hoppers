# Tutorial camera checks (IS-55)

Run Project, select Play, and move with the arrow keys; Space jumps.
The tutorial starts in screen 1. Cross section boundaries while walking and
jumping, then backtrack. Views should switch once without moving or stopping
the bunny. Stay near an edge to check that views do not flicker.

The five authored views are arranged as one left view and two stacked views
in each of the middle and right columns. Column boundaries are x=2095 and
x=4190; the middle vertical boundary is y=-972 and the right is y=-1005.
Normal movement uses a 24-pixel margin to prevent boundary flicker.

Until the glove and carrot are integrated, some route sections are inaccessible.
To inspect them without changing the saved starting position, run the tutorial,
select Remote in the Scene dock, and change CharacterBody2D's position in the
Inspector. Test (2500,-1500), (2500,-500), (4500,-1500), and (6000,-500).
These select screens 2–5; gravity remains active, so use pause while editing.
Return to (233,-313) to check that the first view is restored. Stop and rerun
to restore the normal game state; do not save remote test positions locally.

Resize the game window: the logical view should stay the same size, with bars
where the window's aspect ratio differs. Check menu Play still enters screen 1.

Checkpoint integration should call `sync_camera_to_player()` on the tutorial
root after placing the bunny. Distant teleports are detected automatically;
the explicit call also handles a checkpoint close to a section boundary.
This change does not add checkpoints, retries, gloves, pickups, or completion.

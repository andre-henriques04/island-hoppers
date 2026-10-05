# Island Hoppers

Island Hoppers is a 2D, side-view, single-player puzzle platformer about a bunny searching across islands for three lost siblings. The intended experience combines exploration, platforming, puzzles, and sibling rescues, with rescued siblings eventually unlocking abilities.

## Project status — End of Sprint 1

Sprint 1 established a **playable local prototype** in Godot. The shared project now brings together bunny movement, jumping, collision, walking animation, and a tutorial platform layout.

The project is still a prototype. A complete tutorial playthrough, sibling-rescue objective, and browser release remain in development.

### What is currently implemented

- **Shared Godot project:** project configuration, repository structure, and developer instructions.
- **Playable bunny:** horizontal movement, grounded jumping, gravity, platform collision, facing direction, and walking animation.
- **Tutorial environment:** platform tiles, collision geometry, background artwork, and a layout spanning multiple planned screens.
- **Timed-obstacle prototype:** a reusable component with configurable resting, warning, extension, and retraction phases, randomized waiting intervals, visual feedback, and a contact signal.
- **Supporting assets and behavior:** home-screen and island-map artwork, boxing-glove animation assets, and scripts for speed and jump boosts/debuffs.

### Integration limits

Some components exist in the repository but are not yet connected to a complete gameplay flow:

- The timed-obstacle behavior runs in a **separate preview scene**. It is not connected to the playable tutorial route and does not yet apply player knockback.
- Boxing-glove visuals in the main scene do not establish a completed interactive obstacle.
- Power-up scripts exist, but pickups are not yet placed in the playable level.
- Home-screen and island-map artwork are available; a complete menu/navigation flow is not implemented in the current main scene.
- Camera progression between tutorial screens, checkpoints, recovery after falling, sibling rescue, and island completion remain unfinished.
- **No browser test build has been completed or published.** Run the prototype locally using Godot.

### What we are building toward

The next priority is a complete tutorial loop: enter the level, navigate its challenges, recover from mistakes, rescue a sibling, and reach a clear ending.

Further work includes connecting obstacles and power-ups, implementing camera progression and checkpoints, completing navigation, and verifying browser export. Additional islands, sibling switching, and ability-based puzzles are part of the longer-term direction. Exact scope and ownership are tracked in Jira.

## Requirements

- **Godot 4.7.2 Standard**, the team's agreed development version.
- **Git** and access to the [Island Hoppers repository](https://github.com/andre-henriques04/island-hoppers).

This project uses **GDScript** and the Compatibility renderer. Use the Standard Godot build; the project does not require the .NET build.

### Install Godot

Download the team's agreed version from the [official Godot website](https://godotengine.org/download/). Use the archive if the main download page offers a different version.

Confirm the version in the Project Manager or editor. If Godot is available from your terminal, you can also run:

```bash
godot --version
```

Coordinate engine-version changes with the team before updating the project.

## Get the project

### First-time checkout

Open a terminal and run:

```bash
git clone https://github.com/andre-henriques04/island-hoppers.git
cd island-hoppers
```

This creates a local `island-hoppers` folder connected to the shared repository. You can also clone using GitHub Desktop or GitKraken.

### Update an existing clone

Before switching branches or pulling, commit or stash any local work you want to keep. Then update `main`:

```bash
git switch main
git pull origin main
```

If you are working on a feature branch, stay on that branch and bring in changes from `main` when needed. Check `git status` before switching branches or merging.

## Open the project in Godot

1. Start **Godot Project Manager**.
2. Click **Import**.
3. Select `project.godot` in your local `island-hoppers` folder.
4. Click **Import & Edit**, or the equivalent open button.
5. Allow Godot to finish importing the assets before running the project.

The repository root contains `project.godot`, `README.md`, `scenes/`, `scripts/`, and `assets/`.

Godot may not show `project.godot` in its FileSystem dock because that dock focuses on game resources. Use **Project → Project Settings** to view project settings, or open the file in a text editor.

## Run the prototype

### Main playable scene

The configured starting scene is:

```text
res://scenes/main.tscn
```

Click **Run Project** in the editor. If Godot asks you to choose a main scene, select `scenes/main.tscn`.

The main scene opens the tutorial platform environment directly. It includes the bunny controller, platform collision, animation, and background artwork.

| Action | Control |
|---|---|
| Move left/right | Left/right arrow keys |
| Jump while grounded | Space |
| Stop and restart after falling or leaving the playable area | Use the editor's Stop and Run Project buttons |

The controller currently uses Godot's `ui_left`, `ui_right`, and `ui_accept` input actions. Check **Project → Project Settings → Input Map** if changing the controls.

Automatic respawning and checkpoint recovery are not implemented yet. Camera progression is also unfinished, so the full layout is not yet a continuous playable route.

### Timed-obstacle preview

To inspect the reusable timing behavior independently:

1. Open `scenes/timing_obstacle_demo.tscn` in Godot.
2. Choose **Run Current Scene**.
3. Observe the obstacle's warning, extension, active interval, retraction, and randomized wait cycle.

The reusable component is `scenes/timing_obstacle.tscn`, with behavior in `scripts/timing_obstacle.gd`.

This preview demonstrates the timing component rather than player interaction or a completed tutorial obstacle.

## How Godot files fit together

Godot stores the project as ordinary files that Git can track. The editor provides a visual way to arrange nodes, edit properties, and attach scripts.

- A **node** is a component such as a character body, sprite, collision shape, camera, or label.
- A **scene** is a saved tree of nodes and their properties. Scenes can represent levels, screens, characters, or reusable objects.
- A **GDScript** supplies behavior to a node, such as reading input, moving the player, or controlling an obstacle.
- **Assets** supply images, animation frames, audio, and other resources.

Paths beginning with `res://` are relative to the project root. For example, `res://scenes/main.tscn` refers to `scenes/main.tscn` in this repository.

### Current gameplay flow

The character controller reads keyboard input and updates movement. Godot's physics system handles gravity and collision with platforms. The animated sprite displays movement and facing direction, while the camera determines the visible part of the level.

Obstacle and power-up components are being developed separately and will connect to this flow as their integration is completed.

## Repository layout

The following shows the main areas and representative files; it is not an exhaustive listing.

```text
island-hoppers/
├── project.godot
├── README.md
├── .gitignore
├── scenes/
│   ├── main.tscn
│   ├── timing_obstacle.tscn
│   └── timing_obstacle_demo.tscn
├── scripts/
│   ├── CharacterMovement.gd
│   ├── timing_obstacle.gd
│   ├── Carrot.gd
│   ├── SpoiledFood1.gd
│   ├── JumpBoost1.gd
│   └── JumpDebuff1.gd
└── assets/
    ├── player/
    ├── art/
    │   ├── HomeScreen/
    │   ├── backgrouds/
    │   ├── spritesheets/
    │   └── tilesheets/
    └── audio/
```

`backgrouds` is the current folder spelling. Coordinate any rename with the team and update Godot resource references.

- **`project.godot`** — project configuration, renderer, and starting scene.
- **`scenes/`** — level scenes and reusable objects.
- **`scripts/`** — player, obstacle, and power-up behavior.
- **`assets/player/`** — player animation artwork.
- **`assets/art/`** — interface artwork, backgrounds, tiles, and object animation assets.
- **`assets/audio/`** — intended location for music and sound effects.
- **`.gitignore`** — excludes generated or local files from new commits.
- **`.godot/`** — generated editor cache; do not commit it.

Some folders may contain `.gitkeep` placeholders so Git preserves otherwise empty directories. Keep Godot `.uid` and asset `.import` metadata with their corresponding resources when generated or changed; these are distinct from the ignored `.godot/` cache.

## Working with Git and GitHub

Git tracks saved files and their history. GitHub hosts the shared repository. Godot does not automatically commit or push editor changes.

1. Start from an updated `main` branch.
2. Create a separate branch for a clearly scoped Jira task.
3. Make and save changes inside your local repository.
4. Run the affected scene and the main project.
5. Review changed files using `git status` or your Git application.
6. Commit the relevant source files and push your branch.
7. Open a pull request into `main`.
8. Have a teammate review or test the change before merging.
9. Update the Jira ticket with the PR link, validation, and accurate status.

For a task identified as `IS-XX`, a branch might be:

```bash
git switch -c IS-XX-short-description
```

Replace `IS-XX` with the actual ticket key. Include that key in the PR title or description so the work is traceable.

Commit scenes, scripts, artwork, relevant resource metadata, and intentional project-setting changes. Leave generated caches and unrelated local files out of the commit.

Coordinate before editing the same scene or script. Agree on scene ownership, asset scale, input actions, node paths, and interaction signals to reduce integration problems.

### Before merging

- Confirm the project imports without missing resources or script errors.
- Run the changed scene and check the main scene for regressions.
- For player or level changes, check movement, jumping, animation, collision, scale, and camera behavior.
- State which features are complete and which are still separate prototypes.
- Record any remaining work or known limitations in Jira.

Sprint 1 validation relied on manual Godot testing and team smoke tests. This repository does not currently include an automated test suite or a verified browser build.

## Project tracking and documentation

- [GitHub repository and pull requests](https://github.com/andre-henriques04/island-hoppers)
- [Jira board](https://txst-fall26-cs3398-009-team04.atlassian.net/jira/software/projects/IS/boards/3)
- [Product overview and onboarding](https://txst-fall26-cs3398-009-team04.atlassian.net/wiki/spaces/I/pages/4980738/Island+Hoppers+Onboarding)
- [Sprint planning](https://txst-fall26-cs3398-009-team04.atlassian.net/wiki/spaces/I/pages/7700481/Sprint+Planning)
- [Sprint 1 retrospective](https://txst-fall26-cs3398-009-team04.atlassian.net/wiki/spaces/I/pages/15925249/Sprint+1+Retrospective)

Jira tracks ownership, current status, and remaining work. Confluence records product direction, planning, and team decisions. This README explains how to work with and run the current repository.

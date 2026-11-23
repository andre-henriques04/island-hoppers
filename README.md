# Island Hoppers

Island Hoppers is a 2D, side-view, single-player puzzle platformer about a bunny searching across islands for three lost siblings.

## Project status - Sprint 3 local demo

The home screen opens a map with three selectable islands. Tutorial Island
introduces movement, timed boxing gloves, a speed carrot and sibling rescue.
Cloud Island adds platforming built around dash. Witch Island leads from its
platforming route into the final fox chamber.

Griffin assembled the island routes, map selection and demo integration
([PR #37](https://github.com/andre-henriques04/island-hoppers/pull/37)).
Andre added the fox encounter ([PR #38](https://github.com/andre-henriques04/island-hoppers/pull/38))
using Alexa's fox animation artwork, Griffin's arena and Caleb's shared player
abilities. Yaritza contributed island backgrounds, map art and audio assets.

The demo runs locally. The islands are directly selectable and completion is
session-only. A connected campaign progression, Cloud Island rescue, persistent
saves and a verified browser build remain future work. Browser delivery is
tracked in [IS-25](https://txst-fall26-cs3398-009-team04.atlassian.net/browse/IS-25).

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

Open the project and choose **Run Project** (F5). From the home screen, choose
**Play** and select an island on the map.

| Island | Scene | What to try |
|---|---|---|
| Tutorial Island | `scenes/main.tscn` | Timed gloves, speed carrot, sibling rescue and retry |
| Cloud Island | `scenes/cloud_island.tscn` | Dash-based platforming |
| Witch Island | `scenes/boss_island.tscn` | Platforming, then the final fox fight |

Use the left and right arrow keys to move and Space to jump. Shift dashes and
holding Space while falling glides when those abilities are enabled. For local
platforming tests, **9** enables dash and **0** enables glide. The fox encounter
enables both abilities when the fight starts. In the tutorial, **R** retries
and **Esc** returns home.

### Fight the fox

Cross into the Witch Island chamber to start the fight after the gates close.
The fox telegraphs a bite, projectile throw and ground pound. Dodge the low
shockwaves, then stomp the fox while it is stunned. Three successful stomps
trigger victory dialogue. Press **Enter** after victory to return home, or
**R** to retry the encounter.

For focused testing, open one of these scenes and choose **Run Current Scene** (F6):

- `scenes/fox_arena_preview.tscn` jumps to the real chamber entrance.
- `scenes/fox_boss_practice.tscn` opens a standalone sandbox with the same encounter code.

### Testing and architecture

Run these focused checks from the repository root:

```bash
godot --headless --path . --script res://tests/fox_boss_checks.gd
godot --headless --path . --script res://tests/fox_integration_checks.gd
```

PR #38 records passing combat and integration checks, including physical chamber
entry, three-stomp victory, retry, death reset, and return to the menu. The
checks exercise specific scenarios. A continuous manual run of the whole island
remains unverified.

- [Fox encounter testing and handoff](docs/testing/fox-boss.md) covers combat timing, integration and individual checks.
- [Tutorial feature architecture](docs/architecture/tutorial-systems.md) explains the camera, glove, rescue and retry systems.
- [Sprint 2 follow-up](docs/sprint-2-follow-up.md) records the earlier tutorial checks and caveats.

## How Godot files fit together

Godot stores the project as ordinary files that Git can track. The editor provides a visual way to arrange nodes, edit properties, and attach scripts.

- A **node** is a component such as a character body, sprite, collision shape, camera, or label.
- A **scene** is a saved tree of nodes and their properties. Scenes can represent levels, screens, characters, or reusable objects.
- A **GDScript** supplies behavior to a node, such as reading input, moving the player, or controlling an obstacle.
- **Assets** supply images, animation frames, audio, and other resources.

Paths beginning with `res://` are relative to the project root. For example, `res://scenes/main.tscn` refers to `scenes/main.tscn` in this repository.

### Gameplay components

The character controller reads keyboard input and updates movement. Godot's physics system handles gravity and collision with platforms. The animated sprite displays movement and facing direction, while the camera determines the visible part of the level.

The tutorial glove calls the shared controller launch method; its temporary launch lock preserves the impulse. The carrot calls the speed-boost method. TutorialFlow handles retry and completion, while session_progress.gd shares completion state with the menu. The fox encounter reuses the player controller. The arena trigger starts combat after the gates close, and encounter code coordinates the boss, damage, music, retry and victory dialogue.

## Repository layout

The following shows the main areas and representative files; it is not an exhaustive listing.

```text
island-hoppers/
├── project.godot
├── README.md
├── .gitignore
├── scenes/
│   ├── main_menu.tscn
│   ├── main.tscn
│   ├── island_select.tscn
│   ├── cloud_island.tscn
│   ├── boss_island.tscn
│   ├── fox_encounter.tscn
│   ├── boxing_glove.tscn
│   ├── timing_obstacle.tscn
│   └── timing_obstacle_demo.tscn
├── scripts/
│   ├── CharacterMovement.gd
│   ├── tutorial_camera.gd
│   ├── tutorial_flow.gd
│   ├── session_progress.gd
│   ├── boxing_glove.gd
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

Use the course convention: `ticket-key-type-short-description`. Examples of types are `feature`, `bugfix`, `docs` and `integration`. For example:

```bash
git switch -c IS-56-docs-sprint-2-features
```

Use the actual ticket key and scope. Include the key in the PR title and description. Keep the original names of already merged branches as historical evidence; the new convention applies to new work.

Every PR should explain the behavior changed, link the ticket, identify dependencies, record the checks actually run, and give reviewers a short test procedure and areas to inspect. Request a teammate review before merging. Reviewers should leave specific observations and say whether they inspected code, ran targeted checks, or played the full route. Respond to actual feedback and record how it was addressed; a merge alone does not demonstrate a written review.

Commit scenes, scripts, artwork, relevant resource metadata, and intentional project-setting changes. Leave generated caches and unrelated local files out of the commit.

Coordinate before editing the same scene or script. Agree on scene ownership, asset scale, input actions, node paths, and interaction signals to reduce integration problems.

### Before merging

- Confirm the project imports without missing resources or script errors.
- Run the changed scene and check the main scene for regressions.
- For player or level changes, check movement, jumping, animation, collision, scale, and camera behavior.
- State which features are complete and which are still separate prototypes.
- Record any remaining work or known limitations in Jira.

A [pull request template](.github/PULL_REQUEST_TEMPLATE.md) records scope, validation and reviewer focus.

## Project tracking and documentation

- [Confluence fox encounter and handoff](https://txst-fall26-cs3398-009-team04.atlassian.net/wiki/spaces/I/pages/34603009/Sprint+3+-+Fox+Boss+Encounter+and+Handoff)
- [Sprint 2 tutorial feature architecture](docs/architecture/tutorial-systems.md)
- [Confluence tutorial features and architecture decisions](https://txst-fall26-cs3398-009-team04.atlassian.net/wiki/spaces/I/pages/28114945/Sprint+2+-+Tutorial+Features+and+Architecture+Decisions)
- [GitHub repository and pull requests](https://github.com/andre-henriques04/island-hoppers)
- [Jira board](https://txst-fall26-cs3398-009-team04.atlassian.net/jira/software/projects/IS/boards/3)
- [Product overview and onboarding](https://txst-fall26-cs3398-009-team04.atlassian.net/wiki/spaces/I/pages/4980738/Island+Hoppers+Onboarding)
- [Sprint planning](https://txst-fall26-cs3398-009-team04.atlassian.net/wiki/spaces/I/pages/7700481/Sprint+Planning)
- [Sprint 1 retrospective](https://txst-fall26-cs3398-009-team04.atlassian.net/wiki/spaces/I/pages/15925249/Sprint+1+Retrospective)

Jira tracks ownership, current status, and remaining work. Confluence records product direction, planning, and team decisions. This README explains how to work with and run the current repository.

# Island Hoppers

Island Hoppers is a 2D, side-view, single-player puzzle platformer about a bunny searching across islands for three lost siblings. The intended experience combines exploration, platforming, puzzles, and sibling rescues, with rescued siblings eventually unlocking abilities.

## Project status - Sprint 2 tutorial

Sprint 2 connected the tutorial into a playable local experience: main menu,
five camera views with backtracking, timed boxing-glove launches, a speed carrot,
sibling rescue, retry/fall recovery, and replay. Updated animations, backgrounds,
and music are integrated. The game remains a prototype; Cloud Island is separate
work and the complete game is not production-ready.

**Documentation follow-up: November 2, 2026.** This update describes the Sprint 2
implementation and a fresh audit of main at `28a03ba`. It is not a claim that
these documentation changes were published during the sprint.

### Feature ownership and scope

- Andre: tutorial baseline integration (PR #18), camera progression (IS-55,
  PRs #19/#20), interactive gloves (IS-54, PR #21), and sibling rescue,
  retry/fall recovery and replay (IS-56, PR #22).
- Griffin: menu, layout, slope changes, later player-height fixes (IS-68,
  PR #23) and final demo integration (IS-69, PR #26), including animation,
  carrot and music integration.
- Alexa: player animations and sibling artwork; Caleb: power-up behavior;
  Yaritza: background/map artwork and published team meeting summaries.

See [tutorial architecture and decisions](docs/architecture/tutorial-systems.md)
for implementation rationale, tradeoffs, evidence links and individual credit.

### Remaining work and known limitations

- No verified browser release (IS-25 remains To Do). Run locally in Godot.
- Shared island selection/unlocks and permanent saves are not implemented.
  Rescue returns to the existing home screen; completion lasts for the session.
- Retry uses the entrance unless a checkpoint is registered through
  `TutorialFlow.set_checkpoint(world_position)`. Visible checkpoints and the
  additional abilities in PR #24 are not integrated into main.
- Cloud Island PRs #13/#14/#17/#27 remain open. A Done Jira card alone does
  not establish that its branch is merged into the playable main project.
- The November 2 completion/retry suite reports PASS, with resource-cleanup
  warnings. The glove suite fails a scripted ledge-landing expectation after
  later level changes. The glove practice script/check and completion practice
  scene still reference the former `CharacterBody2D` node name; main now uses
  `PlayerCharacter`. Treat these practice shortcuts as requiring repair.
- The fixed logical viewport from PR #19 was removed during PR #26. Recheck
  window sizing and camera coverage; do not rely on the old resize guarantee.

The demo script and October 25 retrospective describe a connected tutorial
playthrough. The current audit reran targeted checks; it does not replace a
fresh uninterrupted manual route test.

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

### Main playable flow

The configured starting scene is `res://scenes/main_menu.tscn`.
Choose **Run Project**, then **Play** to enter `scenes/main.tscn`.

| Action | Control |
|---|---|
| Move left/right | Left/right arrow keys |
| Jump while grounded | Space |
| Retry the tutorial | R |
| Return to the home screen | Esc |

The controller uses `ui_left`, `ui_right` and `ui_accept` for movement/jump.
R and Esc are handled by the tutorial flow script. Falling below or outside
the map triggers recovery. Retry clears velocity, glove launch state and
temporary movement effects, then synchronizes the camera.

The five fixed cameras follow authored section boundaries and allow backtracking.
Amber glove warnings precede active directional punches; wait for a safe attempt.
The carrot gives a temporary speed boost. Reaching the sibling shows rescue
feedback, records session completion and returns home. Play starts a new run.

### Focused checks

- [Camera progression and backtracking](docs/testing/tutorial-camera.md) - IS-55.
- [Glove timing and launch](docs/testing/tutorial-glove.md) - IS-54.
- [Completion, retry and replay](docs/testing/tutorial-completion.md) - IS-56.

Those guides retain their original feature-development context. The November 2
audit notes above and [follow-up checklist](docs/sprint-2-follow-up.md) supersede
outdated pending-work statements. Use `PlayerCharacter` in the Remote Inspector.

The original timing-only preview remains available: open
`scenes/timing_obstacle_demo.tscn` and choose **Run Current Scene**. This demonstrates
the reusable timing cycle, separately from the integrated tutorial glove.

Existing automated checks can be run from the repository root:

```bash
godot --headless --path . --fixed-fps 60 --script tests/tutorial_flow_checks.gd
godot --headless --path . --fixed-fps 60 --script tests/glove_checks.gd
```

The latter is currently known to fail; see the specific regression findings above.
Do not interpret an import completing as proof that the game or every check passes.

## How Godot files fit together

Godot stores the project as ordinary files that Git can track. The editor provides a visual way to arrange nodes, edit properties, and attach scripts.

- A **node** is a component such as a character body, sprite, collision shape, camera, or label.
- A **scene** is a saved tree of nodes and their properties. Scenes can represent levels, screens, characters, or reusable objects.
- A **GDScript** supplies behavior to a node, such as reading input, moving the player, or controlling an obstacle.
- **Assets** supply images, animation frames, audio, and other resources.

Paths beginning with `res://` are relative to the project root. For example, `res://scenes/main.tscn` refers to `scenes/main.tscn` in this repository.

### Current gameplay flow

The character controller reads keyboard input and updates movement. Godot's physics system handles gravity and collision with platforms. The animated sprite displays movement and facing direction, while the camera determines the visible part of the level.

The tutorial glove calls the shared controller launch method; its temporary launch lock preserves the impulse. The carrot calls the speed-boost method. TutorialFlow handles retry and completion, while session_progress.gd shares completion state with the menu. See the architecture guide for the component boundaries and tradeoffs.

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

Sprint 2 added targeted glove and completion/retry checks, alongside manual team testing. Current test results and limitations are recorded above; there is no verified browser build.

A [pull request template](.github/PULL_REQUEST_TEMPLATE.md) records scope, validation and reviewer focus. These process additions were made after Sprint 2 and do not imply historical review comments existed.

## Project tracking and documentation

- [Sprint 2 tutorial feature architecture](docs/architecture/tutorial-systems.md)
- [Confluence tutorial features and architecture decisions](https://txst-fall26-cs3398-009-team04.atlassian.net/wiki/spaces/I/pages/28114945/Sprint+2+-+Tutorial+Features+and+Architecture+Decisions)
- [GitHub repository and pull requests](https://github.com/andre-henriques04/island-hoppers)
- [Jira board](https://txst-fall26-cs3398-009-team04.atlassian.net/jira/software/projects/IS/boards/3)
- [Product overview and onboarding](https://txst-fall26-cs3398-009-team04.atlassian.net/wiki/spaces/I/pages/4980738/Island+Hoppers+Onboarding)
- [Sprint planning](https://txst-fall26-cs3398-009-team04.atlassian.net/wiki/spaces/I/pages/7700481/Sprint+Planning)
- [Sprint 1 retrospective](https://txst-fall26-cs3398-009-team04.atlassian.net/wiki/spaces/I/pages/15925249/Sprint+1+Retrospective)

Jira tracks ownership, current status, and remaining work. Confluence records product direction, planning, and team decisions. This README explains how to work with and run the current repository.

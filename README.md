# Island Hoppers

Island Hoppers is a 2D, side-view, single-player puzzle platformer about a bunny searching across islands for three lost siblings. Players explore, move through platforming challenges, solve puzzles, and rescue siblings as they progress through the game.

The team's first goal is a small playable tutorial island that demonstrates the basic game loop. Additional islands, sibling abilities, and other ideas are part of the longer-term direction; their exact design is still being discussed. This repository currently contains the Godot project setup and a placeholder scene. It does not yet contain the completed game or its planned gameplay systems.

## Requirements

- **Godot 4.7.2 Standard**. Use the Standard build, not the .NET build. This project uses GDScript.
- **Git** and access to the [Island Hoppers GitHub repository](https://github.com/andre-henriques04/island-hoppers).

### Install Godot

Download Godot 4.7.2 for your operating system from the [official Godot 4.7.2 download page](https://godotengine.org/download/archive/4.7.2-stable/). Choose the Standard build. The .NET build is for projects using C#; this project uses GDScript and does not need it.

On macOS, if you use Homebrew, you can install Godot from Terminal:

```bash
brew install godot
```

Check the installed version with:

```bash
godot --version
```

It should report `4.7.2.stable.official` (followed by a build identifier). If you installed Godot another way, you can also confirm its version in the Project Manager or editor window.

## Get the project

### First-time checkout

Open Terminal and run:

```bash
git clone https://github.com/andre-henriques04/island-hoppers.git
cd island-hoppers
```

This creates a local `island-hoppers` folder connected to the GitHub repository. You can also clone the repository using GitKraken's clone option.

### Update an existing local clone

Before switching branches or pulling, save or commit any work you want to keep. Then update your local `main` branch:

```bash
git switch main
git pull origin main
```

If you are already working on a feature branch, keep working on that branch and bring in `main` only when needed. Do not pull `main` while you have uncommitted changes you want to preserve.

## Open the project in Godot

1. Start **Godot Project Manager**.
2. Click **Import**.
3. Browse to your local `island-hoppers` folder and select the `project.godot` file at its root.
4. Click **Import & Edit** (or the equivalent open button) to open the project in the editor.

The repository root is the folder that contains `project.godot`, `README.md`, and the `scenes`, `scripts`, and `assets` folders. Godot may not list `project.godot` in its FileSystem dock because that dock focuses on game resources. To view or change project settings inside Godot, use **Project → Project Settings**. The raw `project.godot` file can be viewed in Finder or a text editor.

## Run the project

The project is configured to start with `scenes/main.tscn`.

- In the Godot editor, click the **Run Project** play button in the upper-right toolbar.
- On macOS, **Command-R** also runs the project.
- If Godot asks you to choose a main scene, select `scenes/main.tscn`.

The current starter scene displays the message “Island Hoppers project setup is ready.” This is a placeholder to confirm the project opens and runs. It is not gameplay; the game systems and levels are still being developed.

To edit the main scene, find `scenes/main.tscn` in the FileSystem dock and double-click it. Its nodes appear in the Scene dock. Select a node to view its settings in the Inspector. Save scene changes with **Command-S** on macOS.

## How Godot files fit together

Godot projects are made of ordinary files in the repository. The editor provides a visual way to arrange nodes, edit their properties, and connect scripts, but the saved work is stored in files that Git can track.

A **node** is one component, such as a character body, sprite, collision shape, camera, label, button, or timer. A **scene** is a saved tree of nodes and their properties. Scenes can be small reusable objects, characters, screens, or complete levels. A scene can include another scene; for example, an island scene can contain an instance of the player scene.

A **GDScript** file supplies behavior to a node. For example, a script attached to the player can read keyboard input and move the character. Not every node needs its own script: simple properties such as a label's text can be set directly in the scene.

Godot paths beginning with `res://` are relative to the project root—the folder containing `project.godot`. For example, `res://scenes/main.tscn` refers to the `scenes/main.tscn` file in this repository. `res://` is a Godot resource path, not a separate folder on your computer.

## Repository layout

```text
island-hoppers/
├── project.godot
├── README.md
├── .gitignore
├── scenes/
│   ├── .gitkeep
│   └── main.tscn
├── scripts/
│   └── .gitkeep
└── assets/
    ├── art/
    │   └── .gitkeep
    └── audio/
        └── .gitkeep
```

The `.gitkeep` files are placeholders so Git preserves empty folders and teammates can see the planned layout on GitHub. `.gitkeep` is just a conventional filename; Git tracks the file, which makes the folder appear. Once a folder contains real project files, its placeholder can be removed.

- **`project.godot`** — project configuration, including the project name, renderer, and starting scene.
- **`README.md`** — this guide to the game and repository.
- **`scenes/`** — Godot scene files, usually ending in `.tscn`. Put levels, screens, and reusable game objects here. The saved node tree and node properties are stored in each scene file.
- **`scripts/`** — GDScript source files ending in `.gd`. Put reusable behavior here and attach scripts to the relevant nodes or scenes.
- **`assets/art/`** — source images and art, such as bunny and sibling sprites, island backgrounds, platforms, puzzle objects, animations, and interface art.
- **`assets/audio/`** — source music and sound effects.
- **`.gitignore`** — tells Git which generated or local files to leave out of commits.
- **`.godot/`** — a local editor cache created by Godot. It is ignored by Git and should not be committed. Godot recreates it when needed.

As the game grows, organize related files together and follow the team's agreed naming and ownership conventions. For example, a character scene may have its own scene and script, while the art used by that character is kept in the art assets folder.

## Working with Git and GitHub

Git tracks saved project files and their history. GitHub hosts the shared repository. Godot does not automatically commit or push your edits.

1. Start from the latest `main` and create a separate branch for your task.
2. Make and save your changes in the local repository folder. Keep unrelated work out of the same change when practical.
3. Run the project in Godot and check that your change works.
4. Review changed files in GitKraken or with `git status`.
5. Stage and commit the files for your task, then push your branch to GitHub.
6. Open a pull request into `main` so teammates can review or test the work before it is merged.

Commit project source files such as scenes, scripts, images, audio, and project settings. Do not commit the generated `.godot/` cache. Coordinate with teammates before editing the same scene or script, because overlapping edits may need to be reconciled during a merge.

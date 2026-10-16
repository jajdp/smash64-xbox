# Super Smash Bros. on Xbox — packaging the UWP port

**The UWP port of this game is the author's, not ours.** [JRickey/BattleShip](https://github.com/JRickey/BattleShip)
carries it on its `codex/uwp-perf-trace` branch, and it works. What was missing was everything between that
branch and a package installed on a console: how to build it, how to get the tiles in, how to sign
it, and what the console does that a desktop never does.

That is what this repository is. It is the same decision as in `retro-rewind-xbox`: publish the
half that is ours, and say plainly that the other half is not.

*(Español: [README.es.md](README.es.md))*

It is not a theory: it has been played on two Xbox Series consoles since 2026-09-20, at 59.9 frames per second with the HD texture pack.

## What is here

| | |
|---|---|
| `patches/01-package-all-tiles.patch` | Our one change to the author's CMake: the tile list was a fixed set of six filenames, and it becomes a glob over the whole `Assets/` folder, so no tile can silently stay out of the package |
| `package/Package.appxmanifest` | The manifest as it ended up, with the identity blanked to `CHANGE-ME` |
| `tools/` | `ssb_empaquetar.ps1` and `ssb_parche_uwp.py`: build, package, sign, and generate the tiles from your own images |
| `docs/` | The step-by-step, in English and Spanish, including the console-side traps |

## What is **not** here

No ROM, no `.o2r` archive, no built binary, no package, and **no code of the author's** beyond the
six context lines the patch needs. No artwork: the tiles on the real console were made from the
game's own art. No signing certificate.

## What you need first

| | |
|---|---|
| The game project | [JRickey/BattleShip](https://github.com/JRickey/BattleShip), branch `codex/uwp-perf-trace` (commit `1a9c03e` is what this was built from), **building and running on your PC first** |
| Your own ROM | The project extracts its assets itself, on your machine |
| Visual Studio | 2022 with the C++ UWP workload |
| Python 3 | For the tile generation. Standard library only |
| An Xbox in Developer Mode | And a certificate to sign with ([`docs/INSTALL.md`](docs/INSTALL.md)) |

## What it had to solve

These are the things that cost time, and none of them is in the author's README:

| | Symptom | Fix |
|---|---|---|
| 1 | Which branch to build is not obvious | `codex/uwp-perf-trace` is a superset of the plain UWP branch: it is the one that carries the UWP target *and* the performance instrumentation the author used. The branch called `xbox` is **not** the one to build. |
| 2 | Moving the build tree breaks custom build steps in a way that hides | A CMake tree with the Visual Studio generator stores its absolute path in hundreds of files. In a custom step with a working directory, CMake writes `cd <folder>` and then, on the next line, **the bare drive letter**. That line has no path in it, so a search-and-replace by path misses it and the step runs on the old drive. Here it broke `GenerateCreditsAssets` with "No such file or directory". |

## Credits and license

The port is **JRickey/BattleShip**'s, under MIT. The packaging recipe, the tooling and this
documentation are by **Recompilaciones**, under the [MIT License](LICENSE).

*Super Smash Bros.* is © Nintendo. This project is not affiliated with them, with Microsoft or with the
author of the port, and it distributes nothing that belongs to them — see
[`NOTICE.md`](NOTICE.md). Rights holders can write to **jajdpmail@gmail.com**.

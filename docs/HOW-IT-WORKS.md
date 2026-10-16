# How it works

*(Español: [HOW-IT-WORKS.es.md](HOW-IT-WORKS.es.md))*

## Whose work is whose

The UWP target — the WinRT entry point, the window, the backend that draws on a console — is the
author's, on the `codex/uwp-perf-trace` branch of [JRickey/BattleShip](https://github.com/JRickey/BattleShip). Reading that
branch is how you learn how the port works, and this repository does not duplicate it.

What was missing, and what is here, is the path from that branch to a signed package sitting on a
console: the build invocation that survives this project's toolchain, the tiles actually making it
into the package, the signature with a certificate the console already trusts, and the handful of
console behaviours that look like bugs in your build and are not.

## The one code change

The author's `uwp/CMakeLists.txt` lists the tiles that go into the package by name — six of them.
Any tile you add beyond those six is not packaged, and nothing warns you: the console just shows a
default icon and no splash screen. The patch replaces that list with a glob over `Assets/`.

It is three lines. It is also the difference between a package that looks like a game and one that
looks like a broken sideload, which is why it is the one change worth publishing.

## What the console does that a desktop does not

- **It will not replace a package with another of the same version.** Every cycle needs a new
  version number, or you install and run the old build while believing you tested the new one.
- **The app's data folder does not exist until the app has run once.** Uploading before that fails
  with "cannot find the path".
- **Files uploaded inside a `.zip` are unreadable.** Unpacked by the Device Portal they end up with
  permissions the AppContainer cannot open, and the game behaves as if the data were not there.
- **With no user signed in, a package installs and then does nothing.** This one looks exactly like
  a broken package.

**Which branch to build is not obvious.** `codex/uwp-perf-trace` is a superset of the plain UWP branch: it is the one that carries the UWP target *and* the performance instrumentation the author used. The branch called `xbox` is **not** the one to build.

**Moving the build tree breaks custom build steps in a way that hides.** A CMake tree with the Visual Studio generator stores its absolute path in hundreds of files. In a custom step with a working directory, CMake writes `cd <folder>` and then, on the next line, **the bare drive letter**. That line has no path in it, so a search-and-replace by path misses it and the step runs on the old drive. Here it broke `GenerateCreditsAssets` with "No such file or directory".

## How this was verified

The package built this way has been running on a console since 2026-09-20: it has been played on two Xbox Series consoles since 2026-09-20, at 59.9 frames per second with the HD texture pack.

What this repository publishes is the recipe and the tooling, and both were re-read and sanitised
before publication: no path from the machine they were written on, no certificate thumbprint (it is
a parameter now), and no artwork.

What is **not** re-measured here is a rebuild from a fresh clone, because the port is the author's
and its build needs the full project toolchain. The claim is narrow on purpose.

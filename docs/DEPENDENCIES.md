# Dependencies

*(Español: [DEPENDENCIES.es.md](DEPENDENCIES.es.md))*

| | |
|---|---|
| The game project | [JRickey/BattleShip](https://github.com/JRickey/BattleShip), branch **`codex/uwp-perf-trace`**, commit `1a9c03e` — what this was built from. License: MIT |
| Base project | [JRickey/BattleShip](https://github.com/JRickey/BattleShip), version v1.6 |
| Your own ROM | The project extracts the assets itself, on your machine. Neither the ROM nor the archive is distributed here |
| Visual Studio 2022 | With the **C++ UWP workload**: MSBuild packages and signs |
| CMake | The one that ships with Visual Studio is fine |
| Python 3 | Any 3.8+, standard library only, for the tile generation |
| PowerShell | The **5.1** that Windows ships. PowerShell 7 is not needed; the examples carry `-ExecutionPolicy Bypass` because a stock Windows is `Restricted` |
| An Xbox Series | In **Developer Mode**, with a user signed in, and the `Microsoft.VCLibs.140.00` x64 appx installed with the package |

⚠ The branch matters more than the version here: `codex/uwp-perf-trace` is a superset of the plain UWP branch and is the one that builds. The branch named `xbox` is not.

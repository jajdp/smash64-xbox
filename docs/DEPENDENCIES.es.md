# Dependencias

*(English: [DEPENDENCIES.md](DEPENDENCIES.md))*

| | |
|---|---|
| El proyecto del juego | [JRickey/BattleShip](https://github.com/JRickey/BattleShip), rama **`codex/uwp-perf-trace`**, commit `1a9c03e` — el que se usó aquí. Licencia: MIT |
| Proyecto base | [JRickey/BattleShip](https://github.com/JRickey/BattleShip), versión v1.6 |
| Tu propia ROM | El proyecto extrae los datos él mismo, en tu máquina. Aquí no se distribuye ni la ROM ni el archivo |
| Visual Studio 2022 | Con la **carga de trabajo de C++ para UWP**: MSBuild empaqueta y firma |
| CMake | El que viene con Visual Studio sirve |
| Python 3 | Cualquiera 3.8+, solo biblioteca estándar, para generar los mosaicos |
| PowerShell | La **5.1** que trae Windows. PowerShell 7 no hace falta; los ejemplos llevan `-ExecutionPolicy Bypass` porque un Windows de fábrica está en `Restricted` |
| Una Xbox Series | En **modo desarrollador**, con un usuario conectado, y el appx de `Microsoft.VCLibs.140.00` para x64 instalado con el paquete |

⚠ Aquí la rama importa más que la versión: `codex/uwp-perf-trace` es un superconjunto de la rama de UWP sin más y es la que compila. La que se llama `xbox`, no.

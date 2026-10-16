# Super Smash Bros. en la Xbox — empaquetar el port UWP

**El port UWP de este juego es del autor, no nuestro.** [JRickey/BattleShip](https://github.com/JRickey/BattleShip)
lo lleva en su rama `codex/uwp-perf-trace`, y funciona. Lo que faltaba era todo lo que va entre esa rama y un
paquete instalado en una consola: cómo compilarlo, cómo meter los mosaicos, cómo firmarlo y qué
hace la consola que un escritorio no hace nunca.

Eso es este repositorio. Es la misma decisión que en `retro-rewind-xbox`: publicar la mitad que es
nuestra y decir claramente que la otra no lo es.

*(English: [README.md](README.md))*

No es una teoría: se ha jugado en dos Xbox Series desde el 2026-09-20, a 59,9 cuadros por segundo con el paquete de texturas HD.

## Qué hay aquí

| | |
|---|---|
| `patches/01-package-all-tiles.patch` | Nuestro único cambio al CMake del autor: la lista de mosaicos era un conjunto fijo de seis nombres, y pasa a ser un glob de toda la carpeta `Assets/`, para que ningún mosaico se quede fuera del paquete en silencio |
| `package/Package.appxmanifest` | El manifiesto tal como quedó, con la identidad en blanco (`CHANGE-ME`) |
| `tools/` | `ssb_empaquetar.ps1` y `ssb_parche_uwp.py`: compilar, empaquetar, firmar y generar los mosaicos desde tus propias imágenes |
| `docs/` | El paso a paso, en inglés y español, con las trampas del lado de la consola |

## Qué **no** hay

Ninguna ROM, ningún archivo `.o2r`, ningún binario compilado, ningún paquete y **ningún código del
autor** más allá de las seis líneas de contexto que necesita el parche. Ningún arte: los mosaicos de
la consola de verdad se hicieron con el arte del propio juego. Ningún certificado de firma.

## Qué hace falta antes

| | |
|---|---|
| El proyecto del juego | [JRickey/BattleShip](https://github.com/JRickey/BattleShip), rama `codex/uwp-perf-trace` (el commit `1a9c03e` es el que se usó aquí), **compilando y corriendo antes en tu PC** |
| Tu propia ROM | El proyecto extrae sus datos él mismo, en tu máquina |
| Visual Studio | 2022 con la carga de trabajo de C++ para UWP |
| Python 3 | Para generar los mosaicos. Solo biblioteca estándar |
| Una Xbox en modo desarrollador | Y un certificado para firmar ([`docs/INSTALL.es.md`](docs/INSTALL.es.md)) |

## Qué hubo que resolver

Estas son las cosas que costaron tiempo, y ninguna está en el README del autor:

| | Síntoma | Arreglo |
|---|---|---|
| 1 | Cuál es la rama que hay que compilar no es evidente | `codex/uwp-perf-trace` es un superconjunto de la rama de UWP sin más: es la que lleva el objetivo UWP *y* la instrumentación de rendimiento que usó el autor. La rama llamada `xbox` **no** es la que hay que compilar. |
| 2 | Mover el árbol de compilación rompe los pasos personalizados de una forma que se esconde | Un árbol de CMake con el generador de Visual Studio guarda su ruta absoluta en cientos de archivos. En un paso personalizado con carpeta de trabajo, CMake escribe `cd <carpeta>` y, en la línea siguiente, **la letra de unidad suelta**. Esa línea no lleva ruta, así que una búsqueda y reemplazo por ruta no la ve y el paso corre en el disco viejo. Aquí rompió `GenerateCreditsAssets` con «No such file or directory». |

## Créditos y licencia

El port es de **JRickey/BattleShip**, bajo MIT. La receta de empaquetado, las herramientas y esta
documentación son de **Recompilaciones**, bajo la [licencia MIT](LICENSE).

*Super Smash Bros.* es © Nintendo. Este proyecto no está afiliado con ellos, ni con Microsoft, ni con el autor
del port, y no distribuye nada que les pertenezca — ver [`NOTICE.es.md`](NOTICE.es.md). Los
titulares de derechos pueden escribir a **jajdpmail@gmail.com**.

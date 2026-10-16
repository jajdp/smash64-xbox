# -*- coding: utf-8 -*-
r"""Dos arreglos a las fuentes del envoltorio UWP de BattleShip, para empaquetarlo aqui.

El autor (JRickey) publica el envoltorio en `uwp\` de su rama `codex/uwp-xbox`. Sirve tal
cual salvo por dos cosas, que son de NUESTRO empaquetado, no fallos suyos:

  1. El manifiesto declara `Publisher="CN=JRickey"`. Firmamos con el certificado del
     proyecto (`CN=Decompilaciones`, el mismo de los demas ports propios) y el publicador
     del manifiesto TIENE que coincidir con el sujeto del certificado o la firma falla.

  2. El manifiesto NO declara pantalla de carga (`uap:SplashScreen`). El usuario prepara su
     arte por mosaico en la carpeta de imagenes que se le pase —incluidos `xbox-ss1/ss2`,
     que son justo la pantalla de carga— y `identidad-visual.py` genera EXACTAMENTE lo que
     el manifiesto referencia: sin declararla, ese arte no se usaria. Se le anade.

  Y de paso, el CMake lista sus seis PNG a mano; al generar nosotros mas mosaicos se
  quedarian fuera del paquete. Se cambia por un glob de `Assets/*.png`.

Idempotente: se puede correr las veces que haga falta.

    py -3.13 ssb_parche_uwp.py [carpeta-uwp]

Por defecto actua sobre `..\fuentes\uwp\` (las fuentes espejadas en el subproyecto).
"""
import re
import sys
from pathlib import Path

PUBLICADOR = "CN=Decompilaciones"
UWP = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parent.parent / "fuentes" / "uwp"

manifiesto = UWP / "Package.appxmanifest"
cmake = UWP / "CMakeLists.txt"
for f in (manifiesto, cmake):
    if not f.is_file():
        raise SystemExit(f"no encuentro {f}")

cambios = []

# ---------------------------------------------------------------- 1. el publicador
# ⚠ Solo el del <Identity>. El manifiesto trae otro `Publisher=` en la dependencia de
# VCLibs (CN=Microsoft Corporation...), que es la identidad del framework de Microsoft:
# tocarlo dejaria el paquete pidiendo una dependencia que no existe.
texto = manifiesto.read_text(encoding="utf-8")
nuevo, n = re.subn(
    r'(<Identity\b[^>]*?\bPublisher=")CN=[^"]+(")',
    lambda m: m.group(1) + PUBLICADOR + m.group(2),
    texto,
)
if n != 1:
    raise SystemExit(f"esperaba un solo Publisher en el <Identity>, encontre {n}")
if nuevo != texto:
    cambios.append(f"Publisher -> {PUBLICADOR}")
    texto = nuevo
else:
    print(f"  ya estaba  Publisher = {PUBLICADOR}")

# ---------------------------------------------------------------- 2. la pantalla de carga
if "uap:SplashScreen" in texto:
    print("  ya estaba  uap:SplashScreen")
else:
    # Va DENTRO de uap:VisualElements, junto al DefaultTile. El orden del esquema manda:
    # DefaultTile primero, SplashScreen despues.
    ancla = "</uap:VisualElements>"
    if ancla not in texto:
        raise SystemExit("no encuentro el cierre de uap:VisualElements")
    texto = texto.replace(
        ancla,
        '  <uap:SplashScreen Image="Assets\\SplashScreen.png" BackgroundColor="black" />\n'
        "      " + ancla,
        1,
    )
    cambios.append("uap:SplashScreen anadido")

if cambios:
    manifiesto.write_text(texto, encoding="utf-8")

# ---------------------------------------------------------------- 3. los assets, por glob
texto = cmake.read_text(encoding="utf-8")
if "PKG_ASSETS_GLOB" in texto:
    print("  ya estaba  glob de Assets/*.png")
else:
    bloque = re.search(r"set\(PKG_ASSETS\n(?:.*\n)*?\)\n", texto)
    if not bloque:
        raise SystemExit("no encuentro el set(PKG_ASSETS ...) del CMake")
    texto = texto.replace(
        bloque.group(0),
        "# Los mosaicos los genera identidad-visual.py a partir del manifiesto, y son mas de los\n"
        "# seis que traia la lista fija: se toma la carpeta entera para que ninguno se quede fuera.\n"
        'file(GLOB PKG_ASSETS_GLOB "${CMAKE_CURRENT_SOURCE_DIR}/Assets/*.png")\n'
        "set(PKG_ASSETS ${PKG_ASSETS_GLOB})\n",
        1,
    )
    cmake.write_text(texto, encoding="utf-8")
    cambios.append("PKG_ASSETS -> glob de Assets/*.png")

print(f"\n{UWP}")
for c in cambios:
    print(f"  cambiado   {c}")
if not cambios:
    print("  sin cambios: ya estaba todo aplicado")

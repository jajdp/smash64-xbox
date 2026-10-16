<#
.SYNOPSIS
  Construye y firma el paquete UWP de Super Smash Bros (BattleShip) para la Xbox Series X.

.DESCRIPTION
  Segunda mitad de la receta: con la DLL del juego ya compilada (-DBATTLESHIP_UWP=ON), se
  configura el envoltorio WinRT de `uwp\` y se empaqueta con MSBuild.

  A diferencia de los demas ports propios, el envoltorio lo publica el AUTOR del port en su
  rama `codex/uwp-xbox`. Lo unico nuestro son los dos arreglos de `ssb_parche_uwp.py`
  (publicador y pantalla de carga) y los mosaicos de `identidad-visual.py`. Por eso este
  script empieza copiando las fuentes espejadas del subproyecto —que son las parcheadas— al
  arbol de compilacion: alli manda siempre lo que hay en `xbox\fuentes\uwp\`.

  La firma usa el certificado del proyecto (CN=Decompilaciones), el mismo de los demas ports,
  en vez del autofirmado que genera el flujo del autor: asi la consola no necesita confiar en
  un publicador nuevo.

.PARAMETER Version
  Sube en cada ciclo: la consola no reemplaza un paquete por otro de la MISMA version.
#>
[CmdletBinding()]
param(
  [string]$Version = "0.1.0.0",
  [string]$Arbol = "<tree>",
  [string]$Huella = $null   # CN=Decompilaciones
)

$ErrorActionPreference = 'Stop'
$cmake = "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe"
$msbuild = "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"
$fuentes = Join-Path $PSScriptRoot "..\fuentes\uwp" | Convert-Path

if ($Version -notmatch '^\d+\.\d+\.\d+\.\d+$') {
  throw "la version debe ser de cuatro partes (recibi '$Version')"
}
$dll = Join-Path $Arbol "build-windows\Release\BattleShip.dll"
if (-not (Test-Path $dll)) { throw "falta la DLL del juego: $dll" }
Write-Host ("  version: $Version")
Write-Host ("  DLL: {0:N1} MB" -f ((Get-Item $dll).Length / 1MB))

Write-Host "=== 0. fuentes parcheadas -> arbol de compilacion ==="
$destino = Join-Path $Arbol "uwp"
foreach ($f in 'Package.appxmanifest', 'CMakeLists.txt', 'main.cpp', 'INSTALL.txt') {
  Copy-Item -LiteralPath (Join-Path $fuentes $f) -Destination (Join-Path $destino $f) -Force
}
$assetsDst = Join-Path $destino "Assets"
Remove-Item -LiteralPath $assetsDst -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item -LiteralPath (Join-Path $fuentes "Assets") -Destination $assetsDst -Recurse -Force
Write-Host ("  {0} mosaicos" -f (Get-ChildItem $assetsDst -Filter *.png).Count)

# La version la mete CMake en el manifiesto por configure_file (@BATTLESHIP_PACKAGE_VERSION@),
# no se escribe a mano como en los otros ports.
Write-Host "=== 1. configurar el envoltorio WinRT ==="
& $cmake -S $destino -B (Join-Path $Arbol "build-uwp") `
  -G "Visual Studio 17 2022" -A x64 `
  "-DBATTLESHIP_BUILD_DIR=$Arbol/build-windows" `
  "-DBATTLESHIP_NATIVE_CONFIG=Release" `
  "-DBATTLESHIP_PACKAGE_VERSION=$Version"   # entrecomillado: sin comillas PowerShell parte el token y CMake recibe la version vacia
if ($LASTEXITCODE -ne 0) { throw "fallo el configure del envoltorio" }

Write-Host "=== 2. empaquetar y firmar ==="
$salida = Join-Path $Arbol "paquete-$Version"
& $msbuild (Join-Path $Arbol "build-uwp\BattleShip-UWP.vcxproj") `
  /p:Configuration=Release /p:Platform=x64 `
  /p:AppxPackageSigningEnabled=true `
  /p:PackageCertificateThumbprint=$Huella `
  /p:UapAppxPackageBuildMode=SideloadOnly `
  /p:AppxBundle=Always /p:AppxBundlePlatforms=x64 `
  /p:AppxPackageDir="$salida\\" `
  /verbosity:minimal
if ($LASTEXITCODE -ne 0) { throw "fallo el empaquetado" }

Write-Host "=== 3. resultado ==="
Get-ChildItem -Path $salida -Recurse -Include *.msixbundle, *.appxbundle, *.msix, *.appx, *.cer |
  ForEach-Object { "  {0,8:N1} MB  {1}" -f ($_.Length / 1MB), $_.FullName }

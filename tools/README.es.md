# tools/

*(English: [README.md](README.md))*

Dos scripts. `ssb_parche_uwp.py` prepara el objetivo UWP y genera los mosaicos desde tus propias imágenes; `ssb_empaquetar.ps1` empaqueta con MSBuild y firma con tu certificado.

Cada ruta es un parámetro, y la huella del certificado también: aquí no hay ningún valor que apunte
a la máquina donde se escribieron, ni ninguna huella metida dentro.

El `-Version` tiene que subir en cada ciclo. La consola no reemplaza un paquete instalado por otro
con la misma versión, y el fallo parece que la compilación nueva está rota.

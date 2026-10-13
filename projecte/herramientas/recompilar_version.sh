#!/bin/bash
# Vuelve a publicar una versión antigua con el menú de versiones añadido, y
# nada más: el resto del juego queda exactamente como en su etiqueta. Se usó el
# 08/10/2026 con la v0.2 a la v0.7, para poder cambiar de versión también desde
# ellas (bitácora, sesión 10). Herramienta, no forma parte del juego.
#
# Uso, desde cualquier sitio del repositorio:
#   bash projecte/herramientas/recompilar_version.sh v0.5 /carpeta/de/salida
# Deja en la salida SectorCero.exe y SectorCero.x86_64. Con un tercer argumento
# "prueba" apunta a un servidor local (127.0.0.1:8765) y solo exporta Windows.
set -e
TAG=$1
SALIDA=$2
PRUEBA=$3
V=${TAG#v}
REPO=$(git rev-parse --show-toplevel)
G=${GODOT:-/c/Users/Adam/Desktop/Godot_v4.7.2-stable_win64.exe}
TRABAJO=$SALIDA/codigo_$V
rm -rf $TRABAJO; mkdir -p $TRABAJO
cd $REPO
git archive $TAG projecte | tar -x -C $TRABAJO
P=$TRABAJO/projecte

# 1. Los dos scripts del menú de versiones, tal como están en main.
cp $REPO/projecte/escenas/interfaz/panel_versiones.gd $P/escenas/interfaz/
cp $REPO/projecte/globales/instalador_juego.gd $P/globales/
# El .uid del instalador ya existe en la v0.7: se deja el suyo.
[ -f $P/escenas/interfaz/panel_versiones.gd.uid ] || cp $REPO/projecte/escenas/interfaz/panel_versiones.gd.uid $P/escenas/interfaz/
[ -f $P/globales/instalador_juego.gd.uid ] || cp $REPO/projecte/globales/instalador_juego.gd.uid $P/globales/

# 2. El botón en el menú, debajo de ACTUALIZAR. Nada más del menú cambia.
M=$P/escenas/menu_principal/menu_principal.gd
perl -0pi -e 's/(var _actualizar: Button\n)/$1var _versiones: Control\n/' $M
grep -q 'const InstaladorJuego' $M || perl -0pi -e 's/(\nvar _)/\nconst InstaladorJuego := preload("res:\/\/globales\/instalador_juego.gd")\n$1/' $M
perl -0pi -e 's/(\nvar _)/\nconst PanelVersiones := preload("res:\/\/escenas\/interfaz\/panel_versiones.gd")\n$1/' $M
perl -0pi -e 's/(\tcaja.add_child\(_actualizar\)\n)/$1\t# Añadido el 08\/10\/2026 al volver a publicar esta versión: el menú de\n\t# versiones, para poder cambiar a otra (también desde las antiguas).\n\tvar versiones := EstiloInterfaz.boton("VERSIONES", func(): _versiones.abrir(), 180)\n\tversiones.size_flags_horizontal = Control.SIZE_SHRINK_CENTER\n\tcaja.add_child(versiones)\n\t_versiones = PanelVersiones.new()\n\t_versiones.cerrado.connect(versiones.grab_focus)\n\tadd_child(_versiones)\n/' $M
grep -q 'InstaladorJuego.limpiar()' $M || perl -0pi -e 's/(func _crear_version\(caja: VBoxContainer\) -> void:\n)/$1\tInstaladorJuego.limpiar()\n/' $M
[ $(grep -c "PanelVersiones.new()" $M) -eq 1 ] || { echo "FALLO: no se pudo añadir el botón en $TAG"; exit 1; }

# 3. La versión de la etiqueta, como hace la Action.
sed -i "s/const ACTUAL := \"desarrollo\"/const ACTUAL := \"$V\"/" $P/globales/version.gd
sed -i "s/config\/version=\"desarrollo\"/config\/version=\"$V\"/" $P/project.godot

if [ "$PRUEBA" = "prueba" ]; then
  sed -i 's/config\/name="Sector Cero"/config\/name="Sector Cero Prueba"/' $P/project.godot
  sed -i 's#https://api.github.com/repos/adro158/sector-cero/releases/latest#http://127.0.0.1:8765/latest#' $P/globales/actualizador.gd $P/globales/instalador_juego.gd
  sed -i 's#https://api.github.com/repos/adro158/sector-cero/releases?per_page=30#http://127.0.0.1:8765/releases#' $P/escenas/interfaz/panel_versiones.gd
  perl -0pi -e 's/(func _mostrar_version\(\) -> void:\n)/$1\tprint("PRUEBA menu: ", Actualizador.texto(), " | ejecutable ", Actualizador.version_ejecutable())\n/' $M
fi

# 4. Exportar.
"$G" --headless --path $P --import 2>&1 | grep -E "SCRIPT ERROR|Parse Error" && { echo "FALLO al importar $TAG"; exit 1; }
mkdir -p $SALIDA/windows_$V $SALIDA/linux_$V
"$G" --headless --path $P --export-release "Windows Desktop" $SALIDA/windows_$V/SectorCero.exe > /dev/null 2>&1
if [ "$PRUEBA" != "prueba" ]; then
  "$G" --headless --path $P --export-release "Linux" $SALIDA/linux_$V/SectorCero.x86_64 > /dev/null 2>&1
fi
ls -l $SALIDA/windows_$V $SALIDA/linux_$V
echo "HECHO $TAG"

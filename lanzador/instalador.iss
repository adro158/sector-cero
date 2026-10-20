; Instalador de Sector Cero para Windows, hecho con Inno Setup 6
; (https://jrsoftware.org/isinfo.php). El asistente de siempre: Siguiente,
; elegir la carpeta, accesos directos y Finalizar, con su desinstalador en
; "Agregar o quitar programas".
;
; Instala dos cosas, para todo el ordenador:
;   - el lanzador (SectorCero_Lanzador.exe), que es lo que abren los accesos
;     directos
;   - el juego sin contenido (juego\SectorCero.exe): el lanzador copia a su
;     lado el .pck de la versión elegida y lo abre
;
; Lo genera la GitHub Action con cada versión (publicar_release.yml), después
; de exportar los dos, con:
;   ISCC.exe /DVersion=1.5 lanzador\instalador.iss
; y deja ..\build\instalador\SectorCero_Instalador.exe.

#ifndef Version
  #define Version "desarrollo"
#endif

[Setup]
; El identificador del programa para Windows: no se cambia nunca, o una versión
; nueva se instalaría como otro programa en lugar de actualizar este.
AppId={{0DF66C1F-F268-4AF1-BC0C-DB10B2D2A7B7}
AppName=Sector Cero
AppVersion={#Version}
AppPublisher=Adam y Alan
AppPublisherURL=https://github.com/adro158/sector-cero
DefaultDirName={autopf}\Sector Cero
DefaultGroupName=Sector Cero
UninstallDisplayIcon={app}\SectorCero_Lanzador.exe
SetupIconFile=icono.ico
OutputDir=..\build\instalador
OutputBaseFilename=SectorCero_Instalador
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
; El juego es de 64 bits: en Archivos de programa, no en "(x86)".
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=admin

[Languages]
Name: "es"; MessagesFile: "compiler:Languages\Spanish.isl"

[Tasks]
Name: "escritorio"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Dirs]
; El lanzador escribe aquí el .pck de la versión elegida, y en Archivos de
; programa solo puede escribir el administrador: esta carpeta, cualquiera.
Name: "{app}\juego"; Permissions: users-modify

[Files]
Source: "..\build\lanzador\windows\SectorCero_Lanzador.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\lanzador\windows\juego\SectorCero.exe"; DestDir: "{app}\juego"; Flags: ignoreversion

[Icons]
Name: "{group}\Sector Cero"; Filename: "{app}\SectorCero_Lanzador.exe"
Name: "{group}\Desinstalar Sector Cero"; Filename: "{uninstallexe}"
Name: "{autodesktop}\Sector Cero"; Filename: "{app}\SectorCero_Lanzador.exe"; Tasks: escritorio

[Run]
Filename: "{app}\SectorCero_Lanzador.exe"; Description: "{cm:LaunchProgram,Sector Cero}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
; El .pck lo puso el lanzador, no el instalador: hay que decirle que lo borre
; para que no quede la carpeta.
Type: files; Name: "{app}\juego\SectorCero.pck"

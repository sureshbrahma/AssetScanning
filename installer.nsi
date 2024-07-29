; Example NSIS script for Flutter Windows application installer

; Set the name and output file of the installer
OutFile "AssetQRScannning.exe"

; Default installation directory
InstallDir "$PROGRAMFILES\AssetQR"

; Begin installer sections
Section
SetOutPath $INSTDIR
File /r "build\windows\*.*" ; Include all files from the build\windows directory
; Additional files or directories can be included as needed

; Create shortcuts in the Start Menu and on the desktop
CreateDirectory "$SMPROGRAMS\AssetQR"
CreateShortCut "$SMPROGRAMS\AssetQR\AssetQR.lnk" "$INSTDIR\AssetQRScannning.exe"
CreateShortCut "$DESKTOP\AssetQRScannning.lnk" "$INSTDIR\AssetQRScannning.exe"

; Optionally, create registry entries, start services, etc.

; End installer section
SectionEnd

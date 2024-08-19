#!/bin/sh

APP=powershell
mkdir tmp
cd ./tmp
wget -q https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage -O appimagetool
chmod a+x ./appimagetool

URL=$(curl -Ls https://api.github.com/repos/PowerShell/PowerShell/releases/latest | grep -w -v i386 | grep -w -v i686 | grep -w -v aarch64 | grep -w -v arm64 | grep -w -v armv7l | grep browser_download_url | grep -i "linux-x64.tar.gz" | cut -d '"' -f 4 | head -1)
VERSION=$(curl -Ls https://api.github.com/repos/PowerShell/PowerShell/releases/latest | grep tag_name | head -1 | cut -d '"' -f 4)
wget $URL
mkdir $APP.AppDir
tar fx ./*tar* -C ./$APP.AppDir/
echo "[Desktop Entry]
Categories=ConsoleOnly;System
Comment[en_US]=PowerShell Core
Comment[it_IT]=PowerShell Core
Comment=PowerShell Core
Exec=AppRun
GenericName[en_US]=Powershell
GenericName=Powershell
Icon=Powershell_256
MimeType=
Name=PowerShell
StartupNotify=true
Terminal=true
Type=Application
X-DBUS-ServiceName=
X-DBUS-StartupType=
X-KDE-SubstituteUID=false
X-KDE-Username=" >> ./$APP.AppDir/$APP.desktop
wget https://raw.githubusercontent.com/PowerShell/PowerShell/master/assets/Powershell_256.png -O ./$APP.AppDir/Powershell_256.png

cat >> ./$APP.AppDir/AppRun << 'EOF'
#!/bin/sh
HERE="$(dirname "$(readlink -f "${0}")")"
export UNION_PRELOAD="${HERE}"
exec "${HERE}"/pwsh "$@"
EOF
chmod a+x ./$APP.AppDir/AppRun
ARCH=x86_64 ./appimagetool --comp zstd --mksquashfs-opt -Xcompression-level --mksquashfs-opt 20 ./$APP.AppDir
cd ..
mv ./tmp/*.AppImage ./PowerShell-$VERSION-x86_64.AppImage

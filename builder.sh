#!/bin/sh

APP=powershell
mkdir -p tmp && cd ./tmp || exit 1
if ! test -f ./appimagetool; then
	wget -q https://github.com/pkgforge-dev/appimagetool/releases/latest/download/appimagetool-x86_64-linux -O appimagetool || exit 1
	chmod a+x ./appimagetool
fi

URL=$(curl -Ls https://api.github.com/repos/PowerShell/PowerShell/releases/latest | grep -w -v i386 | grep -w -v i686 | grep -w -v aarch64 | grep -w -v arm64 | grep -w -v armv7l | grep browser_download_url | grep -i "linux-x64.tar.gz" | cut -d '"' -f 4 | head -1)
VERSION=$(curl -Ls https://api.github.com/repos/PowerShell/PowerShell/releases/latest | grep tag_name | head -1 | cut -d '"' -f 4)
wget "$URL" || exit 1
mkdir -p "$APP".AppDir
tar fx ./*tar* -C ./"$APP".AppDir/
for f in ./"$APP".AppDir/*; do
	file "$f" | grep -q "dynamic\|static" && chmod a+x "$f"
done

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
X-KDE-Username=" >> ./"$APP".AppDir/"$APP".desktop
wget https://raw.githubusercontent.com/PowerShell/PowerShell/master/assets/Powershell_256.png -O ./"$APP".AppDir/Powershell_256.png
cp ./"$APP".AppDir/Powershell_256.png ./"$APP".AppDir/.DirIcon

cat >> ./"$APP".AppDir/AppRun << 'EOF'
#!/bin/sh
HERE="$(dirname "$(readlink -f "${0}")")"
export UNION_PRELOAD="${HERE}"
exec "${HERE}"/pwsh "$@"
EOF
chmod a+x ./"$APP".AppDir/AppRun


APPIMAGE_ARCH=x86_64 VERSION="$VERSION" ./appimagetool \
	-u "gh-releases-zsync|$GITHUB_REPOSITORY_OWNER|PowerShell-appimage|continuous|*x86_64.AppImage.zsync" \
	-n PowerShell-"$VERSION"-x86_64.AppImage \
	./"$APP".AppDir || exit 1

cd ..
mv ./tmp/*.AppImage* ./

#!/usr/bin/env bash
set -e

echo "=== Building LandLord Remastered Linux Desktop & AppImage ==="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 1. Compile Linux release bundle
echo "[1/4] Running flutter build linux --release..."
flutter build linux --release

BUNDLE_DIR="$SCRIPT_DIR/build/linux/x64/release/bundle"
APPDIR="$SCRIPT_DIR/build/AppDir"

if [ ! -d "$BUNDLE_DIR" ]; then
    echo "Error: Linux release bundle not found at $BUNDLE_DIR"
    exit 1
fi

# 2. Assemble AppDir
echo "[2/4] Assembling AppDir structure..."
rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/bin"
mkdir -p "$APPDIR/usr/lib"
mkdir -p "$APPDIR/usr/share/icons/hicolor/256x256/apps"

cp -r "$BUNDLE_DIR"/* "$APPDIR/usr/bin/"

# 3. Create Desktop file and AppRun
cat << 'EOF' > "$APPDIR/landlord.desktop"
[Desktop Entry]
Name=LandLord Remastered
Comment=Property & Rental Management Application
Exec=landlord_app
Icon=landlord
Type=Application
Categories=Office;Finance;
StartupWMClass=landlord_app
EOF

cat << 'EOF' > "$APPDIR/AppRun"
#!/usr/bin/env bash
HERE="$(dirname "$(readlink -f "${0}")")"
export PATH="${HERE}/usr/bin:${PATH}"
export LD_LIBRARY_PATH="${HERE}/usr/lib:${HERE}/usr/bin/lib:${LD_LIBRARY_PATH}"
cd "${HERE}/usr/bin"
exec "${HERE}/usr/bin/landlord_app" "$@"
EOF
chmod +x "$APPDIR/AppRun"

# Optional icon fallback
touch "$APPDIR/landlord.png"
cp "$APPDIR/landlord.png" "$APPDIR/usr/share/icons/hicolor/256x256/apps/landlord.png"

# 4. Run appimagetool
echo "[3/4] Preparing appimagetool..."
if ! command -v appimagetool &> /dev/null; then
    if [ ! -f /tmp/appimagetool ]; then
        curl -L -o /tmp/appimagetool "https://github.com/AppImage/AppImageKit/releases/download/13/appimagetool-x86_64.AppImage"
        chmod +x /tmp/appimagetool
    fi
    TOOL="/tmp/appimagetool"
else
    TOOL="appimagetool"
fi

echo "[4/4] Generating LandLord-Remastered.AppImage..."
ARCH=x86_64 "$TOOL" "$APPDIR" "$SCRIPT_DIR/LandLord-Remastered.AppImage"

echo "=== Successfully built LandLord-Remastered.AppImage! ==="
ls -lh "$SCRIPT_DIR/LandLord-Remastered.AppImage"

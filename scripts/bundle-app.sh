#!/bin/bash
set -e

# Configuration
APP_NAME="MarkdownRender"
BUNDLE_ID="com.thomas.markdownrender"
VERSION="1.0.0"
BUILD_DIR=".build/release"
APP_DIR="$BUILD_DIR/$APP_NAME.app"

echo "Building release binary..."
swift build -c release

echo "Creating app bundle structure..."
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

echo "Copying binary..."
cp "$BUILD_DIR/$APP_NAME" "$APP_DIR/Contents/MacOS/"

echo "Creating Info.plist..."
cat > "$APP_DIR/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleDisplayName</key>
    <string>Markdown Render</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundleVersion</key>
    <string>$VERSION</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSSupportsAutomaticGraphicsSwitching</key>
    <true/>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleDocumentTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeName</key>
            <string>Markdown Document</string>
            <key>CFBundleTypeRole</key>
            <string>Viewer</string>
            <key>LSHandlerRank</key>
            <string>Alternate</string>
            <key>LSItemContentTypes</key>
            <array>
                <string>net.daringfireball.markdown</string>
                <string>public.text</string>
            </array>
            <key>CFBundleTypeExtensions</key>
            <array>
                <string>md</string>
                <string>markdown</string>
                <string>mdown</string>
                <string>mkd</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
EOF

echo "Creating PkgInfo..."
echo -n "APPL????" > "$APP_DIR/Contents/PkgInfo"

echo "Copying icon..."
cp "Icon/MyIcon.icns" "$APP_DIR/Contents/Resources/AppIcon.icns"

echo ""
echo "App bundle created at: $APP_DIR"
echo ""
echo "To install to /Applications:"
echo "  cp -r \"$APP_DIR\" /Applications/"
echo ""
echo "Or drag $APP_DIR to your Applications folder in Finder."
echo ""
echo "Note: The app still requires a file argument. To open files:"
echo "  - Drag a .md file onto the app icon"
echo "  - Right-click a .md file → Open With → Markdown Render"
echo "  - Or use the CLI: MarkdownRender file.md"

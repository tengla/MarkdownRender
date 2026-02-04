#!/bin/bash
# Generate macOS .icns from a source PNG
# Usage: ./make-icns.sh [source.png] [output.icns]
#
# Defaults: icon-source.png -> AppIcon.icns

set -e

SOURCE="${1:-icon-source.png}"
OUTPUT="${2:-AppIcon.icns}"
ICONSET="AppIcon.iconset"

cd "$(dirname "$0")"

if [ ! -f "$SOURCE" ]; then
    echo "Error: Source file '$SOURCE' not found"
    exit 1
fi

echo "Creating $OUTPUT from $SOURCE..."

# Clean up any existing iconset
rm -rf "$ICONSET"
mkdir -p "$ICONSET"

# macOS corner radius: ~22.37% of icon size
add_rounded_corners() {
    local size=$1
    local radius=$(echo "$size * 0.2237" | bc | cut -d. -f1)
    local max=$((size - 1))

    magick "$SOURCE" -resize ${size}x${size} \
        \( -size ${size}x${size} xc:none \
           -fill white \
           -draw "roundrectangle 0,0 ${max},${max} ${radius},${radius}" \
        \) -compose CopyOpacity -composite \
        "$2"
}

# Generate all required sizes
echo "Generating icon sizes..."
add_rounded_corners 16 "$ICONSET/icon_16x16.png"
add_rounded_corners 32 "$ICONSET/icon_16x16@2x.png"
add_rounded_corners 32 "$ICONSET/icon_32x32.png"
add_rounded_corners 64 "$ICONSET/icon_32x32@2x.png"
add_rounded_corners 128 "$ICONSET/icon_128x128.png"
add_rounded_corners 256 "$ICONSET/icon_128x128@2x.png"
add_rounded_corners 256 "$ICONSET/icon_256x256.png"
add_rounded_corners 512 "$ICONSET/icon_256x256@2x.png"
add_rounded_corners 512 "$ICONSET/icon_512x512.png"
add_rounded_corners 1024 "$ICONSET/icon_512x512@2x.png"

# Convert iconset to icns
echo "Creating .icns file..."
iconutil -c icns "$ICONSET" -o "$OUTPUT"

# Clean up
rm -rf "$ICONSET"

echo "Done: $OUTPUT"
ls -lh "$OUTPUT"

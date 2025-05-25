#!/bin/bash

if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <TARGET_DEVICE> <PRODUCT_OUT> <FILENAME> <MAINTAINER_NAME>"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVICE_LIST="$SCRIPT_DIR/device_name.list"
TARGET_DEVICE=$1
PRODUCT_OUT=$2
LINEAGE_ZIP=$3
MT_NAME=$4
FILENAME="$LINEAGE_ZIP"

if [[ "$FILENAME" =~ HorizonDroid-v[0-9\.]+-.*-(OFFICIAL|UNOFFICIAL)-[0-9]+\.zip ]]; then
    BUILDTYPE="${BASH_REMATCH[1]}"
else
    echo "Error: Unable to extract ROM type from filename: $FILENAME"
    exit 1
fi

if [[ "$FILENAME" =~ HorizonDroid-([a-z0-9\.]+)-.*\.zip ]]; then
    VERSION="${BASH_REMATCH[1]}"
else
    echo "Error: Unable to extract version from filename: $FILENAME"
    exit 1
fi

if [[ "$FILENAME" =~ HorizonDroid-.*-(GAPPS|VANILLA)-.*\.zip ]]; then
    FLAVOR="${BASH_REMATCH[1]}"
else
    echo "Error: Unable to extract build flavor from filename: $FILENAME"
    exit 1
fi

FILE_PATH="$PRODUCT_OUT/$FILENAME"

if [ ! -f "$FILE_PATH" ]; then
    echo "Error: File $FILE_PATH not found."
    exit 1
fi

SIZE=$(stat -c%s "$FILE_PATH")
SUM=$(md5sum "$FILE_PATH" | awk '{print $1}')
DATETIME=$(date +%s)
if [ "$BUILDTYPE" != "OFFICIAL" ]; then
    MAINTAINER=""
else
    MAINTAINER=$MT_NAME
fi
DEVICE_NAME=$(grep "^${TARGET_DEVICE}=" $DEVICE_LIST | cut -d= -f2- | tr -d '"')

if [ -z "$DEVICE_NAME" ] || [ "$BUILDTYPE" != "OFFICIAL" ]; then
    DEVICE_NAME=""
fi

JSON_OUT="$PRODUCT_OUT/$FLAVOR"
if [ ! -d "$JSON_OUT" ]; then
    mkdir -p "$JSON_OUT"
fi
JSON_FILE="$JSON_OUT/${TARGET_DEVICE}.json"

cat > "$JSON_FILE" <<EOF
{
    "response": [
        {
            "device": "$DEVICE_NAME",
            "codename": "$TARGET_DEVICE",
            "maintainer": "$MAINTAINER",
            "datetime": $DATETIME,
            "filename": "$FILENAME",
            "md5": "$SUM",
            "buildtype": "$BUILDTYPE",
            "size": $SIZE,
            "download": "https://sourceforge.net/projects/horizondroid/",
            "version": "$VERSION",
            "support": "",
            "changelogs": ""
        }
    ]
}
EOF

echo "JSON saved to: $JSON_FILE"
cat "$JSON_FILE"

echo "=========================================="
echo "         Welcome to the HorizonDroid      "
echo "=========================================="
echo "        BUILD COMPLETED SUCCESSFULLY      "
echo "------------------------------------------"
echo "Datetime : $DATETIME"
echo "Size     : $(numfmt --to=iec $SIZE) ($SIZE bytes)"
echo "Output   : $FILE_PATH"
echo "=========================================="

exit 0

#!/bin/bash


PATH=$PATH:/usr/local/bin
PATH="$HOME/.fastlane/bin:$PATH"

# PROJECT SETTINGS

WORKSPACE="Naim.xcworkspace"
SCHEME="Naim | App Store"
CONFIGURATION="Release"
EXPORT_PLIST="./Configuration/export-options-appstore.plist"
ARCHIVE=`uuidgen`

# COMMON SETTINGS

BUILD_DIR="./.build"
IPAS_DIR="./IPAs"

# MAIN SCRIPT

# CHECK FOR REQUIRED APPS AND SCRIPTS
hash xcodebuild 2>/dev/null || { echo >&2 "I require xcodebuild but it's not installed."; exit 1; } 
hash fastlane 2>/dev/null || { echo >&2 "I require fastlane but it's not installed."; exit 1; }
hash uuidgen 2>/dev/null || { echo >&2 "I require uuidgen but it's not installed."; exit 1; } 

BUILDDIR=$1
STOP=${2:-none} #default to "none"

clear

cd "$1"

if [ ! -d $BUILD_DIR ] 
then
	mkdir $BUILD_DIR
	open "$BUILD_DIR"
fi

if [ ! -d $IPAS_DIR ] 
then
	mkdir $IPAS_DIR
fi

if [ $STOP == "setup" ] 
then
	echo "Stopping after setup."
	exit 0
fi

#
# Clean
#
echo "Cleaning..."
xcodebuild clean -workspace "$WORKSPACE" -scheme "$SCHEME" > "$BUILD_DIR/clean.log" || { echo "Clean error. Cannot clean $WORKSPACE -> $SCHEME" ; exit 1 ; } 

if [ $STOP == "clean" ] 
then
	echo "Stopping after cleaning."
	exit 0
fi

#
# Archive
#
echo "Archiving..."
xcodebuild archive -archivePath "$BUILD_DIR/$ARCHIVE" -workspace "$WORKSPACE" -scheme "$SCHEME" -configuration "$CONFIGURATION" > "$BUILD_DIR/archive.log" || { echo "Archive error." ; exit 1 ; } 

if [ $STOP == "archive" ] 
then
	echo "Stopping after archiving."
	exit 0
fi

#
# Export
#
echo "Exporting..."
xcodebuild -exportArchive -archivePath "$BUILD_DIR/$ARCHIVE.xcarchive" -exportPath "$IPAS_DIR" -exportOptionsPlist "$EXPORT_PLIST" > "$BUILD_DIR/export.log" || { echo "Export error." ; exit 1 ; } 

if [ $STOP == "export" ] 
then
	echo "Stopping after exporting."
	exit 0
fi

#
# Upload
#
echo "Uploading..."
fastlane deliver --ipa "$IPAS_DIR/$SCHEME.ipa" > "$BUILD_DIR/upload.log" || { echo "Upload error." ; exit 1 ; } 

if [ $STOP == "upload" ] 
then
	echo "Stopping after uploading."
	exit 0
fi

# Remove Archive
echo "Cleaning up..."
mv -fv "$BUILD_DIR/$ARCHIVE.xcarchive" "/Users/$USER/.Trash/" > "$BUILD_DIR/remove.log" || { echo "Clean up error." ; exit 1 ; } 

echo "Complete."
exit 0

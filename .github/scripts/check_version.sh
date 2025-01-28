#!/bin/bash

# Store current state
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
CURRENT_VERSION=$(grep "version:" pubspec.yaml | cut -d"+" -f2)

# Create a temporary directory and copy pubspec.yaml there
TEMP_DIR=$(mktemp -d)
cp pubspec.yaml "$TEMP_DIR/pubspec.yaml"

# Get previous version
git checkout HEAD^ pubspec.yaml 2>/dev/null
PREVIOUS_VERSION=$(grep "version:" pubspec.yaml | cut -d"+" -f2)

# Restore current version from temp directory
cp "$TEMP_DIR/pubspec.yaml" pubspec.yaml

# Clean up temp directory
rm -rf "$TEMP_DIR"

# Compare versions
if [ "$CURRENT_VERSION" -le "$PREVIOUS_VERSION" ]; then
    echo "Error: Version code must be incremented!"
    echo "Previous version: $PREVIOUS_VERSION"
    echo "Current version: $CURRENT_VERSION"
    exit 1
fi

echo "Version check passed!"
echo "Previous version: $PREVIOUS_VERSION"
echo "Current version: $CURRENT_VERSION"
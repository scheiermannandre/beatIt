#!/bin/bash

# Get the current version from pubspec.yaml
CURRENT_VERSION=$(grep "version:" pubspec.yaml | cut -d"+" -f2)

# Create a temporary copy of pubspec.yaml
cp pubspec.yaml pubspec.yaml.tmp

# Get the previous commit's version
git checkout HEAD^ pubspec.yaml
PREVIOUS_VERSION=$(grep "version:" pubspec.yaml | cut -d"+" -f2)

# Restore the current pubspec.yaml
mv pubspec.yaml.tmp pubspec.yaml

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
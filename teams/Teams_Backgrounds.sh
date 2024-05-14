#!/bin/zsh

# Define the input path where the .png images are stored
imagePath="/Users/Shared/MSTeamsNS"

# Define the output path for Teams Background
outputPath="$HOME/Library/Containers/com.microsoft.teams2/Data/Library/Application Support/Microsoft/MSTeams/Backgrounds/Uploads"

# Path to the mapping CSV file
mappingFile="$outputPath/mapping.csv"

# Check if the output directory exists; if not, create it
if [ ! -d "$outputPath" ]; then
    mkdir -p "$outputPath"
fi

# Create the mapping CSV file if it doesn't exist and write header
if [ ! -f "$mappingFile" ]; then
    echo "GUID,Human_Readable_Name" > "$mappingFile"
fi

# Check if there are PNG images in the input directory
if [ -n "$(find "$imagePath" -maxdepth 1 -name '*.png' -print -quit)" ]; then
    # Loop through all PNG images in the specified directory
    for image in "$imagePath"/*.png; do
        # Generate a new GUID
        guid=$(uuidgen)

        # Resize main image to 1920x1080
        echo "Creating Background: $(basename "$image")"
        sips -z 1080 1920 "$image" --out "$outputPath/$guid.png"

        # Resize thumbnail to 220x158
        echo "Creating Background Thumbnail"
        thumbName="${guid}_thumb.png"
        sips -z 158 220 "$image" --out "$outputPath/$thumbName"

        # Append to the mapping CSV file
        echo "$guid,$(basename "$image")" >> "$mappingFile"
    done
else
    echo "No PNG images found in $imagePath"
fi

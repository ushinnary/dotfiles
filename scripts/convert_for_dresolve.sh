#!/bin/sh

# Get the filename and format from the command line argument
filename=$1
format=${filename##*.}

# Remove the format from the filename
name=${filename%.*}

# Run the ffmpeg command to convert the file to MOV with PCM audio
ffmpeg -i "$filename" -c:v copy -c:a pcm_s16le "$name.mov"

# Check if the -d parameter was provided
for arg in "$@"; do
    if [[ $arg == "-d" ]]; then
        # Delete the original file
        rm "$filename"
        break
    fi
done

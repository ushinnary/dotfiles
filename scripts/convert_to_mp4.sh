#!/bin/bash

# Get the filename and format from the command line argument
filename=$1
format=${filename##*.}

# Remove the format from the filename
name=${filename%.*}

# Run the ffmpeg command to convert the file to MOV with PCM audio
ffmpeg -i "$filename" -c:v libx264 -preset slow -crf 18 -c:a aac "$name.mp4"
#ffmpeg -i "$filename" -c:v h264_amf -preset slow -b:v 5M -c:a aac "$name.mp4"

# Check if the -d parameter was provided
for arg in "$@"; do
	if [[ $arg == "-d" ]]; then
		# Delete the original file
		rm "$filename"
		break
	fi
done

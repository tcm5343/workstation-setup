#!/bin/bash

# example input: ./merge_thumbnail.sh /media/miller/Primary/youtube-dl/PowerfulJRE

youtube_channel_path=/media/miller/Primary/youtube-dl/THE\ BIG\ LEZ\ SHOW\ OFFICIAL/Season\ 4
youtube_channel=THE\ BIG\ LEZ\ SHOW\ OFFICIAL/Season\ 4

echo "$youtube_channel_path"/*.jpeg
for filename in "$youtube_channel_path"/*.jpg; do
	[ -e "$filename" ] || continue
	echo "Processing $filename"
	file_name_no_ext=${filename%.*}
	
	output_directory=/media/miller/Primary/yt-dlp/"$youtube_channel"
	# create output directory if it doesn't exist
	if [ ! -d "$output_directory" ]; then
		echo "Creating "$output_directory""
		mkdir -p "$output_directory";
	fi
	
	# add thumbnail to output file
	output_path="$output_directory/${file_name_no_ext##*/}"
	ffmpeg -i "$file_name_no_ext".mkv -c copy -attach "$file_name_no_ext".jpg -metadata:s:t mimetype=image/jpeg "$output_path".mkv
done



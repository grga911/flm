# flm
Simple script for moving files
I used this script to move a lot of pdf books that contain certain word in their title (file name)
It's not most efficient way, but it worked for me.

Usage flm [OPTIONS]

	-s	source directory (default is current directory)
	-t	target directory (default is current directory)
	-p	default pattern to search for
	-e	file extension (use -pe when searching only extensions)
	-r	custom user pattern input (use regex)
	-c	copy files instead of moving

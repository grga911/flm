#!/bin/bash
#
# check minimum number of switches or if --help is first argument
# and display help
#

if [ $# -lt 1 -o "$1" == "--help" -o "$1" == "-h" ]; then
 	printf " Usage filemov [OPTIONS]
\t-s\tsource directory (default is current directory)
\t-t\ttarget directory (default is current directory)
\t-p\tword default pattern to search for
\t-e\tfile extension
\t-r\tuser custom pattern input
\t-c\tcopy files instead of moving\n"
 	exit 1
fi

#
#check our working directory so we can use it in full path
#when checking or creating new folder for our files
#

CURENTDIR=$(pwd)
default_action="move"

#
#simple yes no dialog function
#

function dialog {

		CHOICE=''
		local prompt="$*"
		local answer
		read -p "$prompt" answer
		case "$answer" in
			[Yy] ) CHOICE='y';;
 			[nN] ) CHOICE='n';;
 			*	) CHOICE="$answer"
		esac
}

# Create directory if with given name
function make_dir {

	directory=$1

	until [[ -d "$directory" ]]; do
 		dialog "Directory doesn't exist, do you wish to create it? Y/n"
		# Defaul choice is yes, so continue if enter is pressed
 		if [[ -z "$CHOICE" ]] || [[ "$CHOICE" == "y" ]] && [[ ! -d "$directory" ]] ; then
 			mkdir "$directory"
 		elif [[ -d "$directory" ]]; then
 			continue
 		else
 			printf "Nothing done exiting \n"
 			exit 1
 		fi
done
}
#
#read switches and arguments and for each -switch assing value of it's variable
#

while getopts ":p:r:s:t:e:c" opt; do
 		case $opt in
 		p)
 			default_pattern=.*$OPTARG.*	>&2
 			;;
 		r)
 			custom_pattern=$OPTARG	>&2
 			;;
 		s)
 			source_dir=$OPTARG	>&2
 			;;
 		t)
 			target_directory=$OPTARG	>&2
 			;;
 		e)
 			extension=.*$OPTARG'$' >&2
 			;;
 		c)
 			action="cp -vnu"
 			default_action=copy
 			;;
 		\?)
 			echo "Invalid option -$OPTARG" >&2
 			exit 1
 			;;
 		:)
 			echo "Option -$OPTARG requiers an argument." >&2
 			exit 1
 			;;
 		esac
done

#
# we need to set default options if switches are not provided
#
# our target directory becomes new folder in our working dir
# later on we will check if folder exists and create new one
# if user desires so
#
#
# if no -c switch is provided default to moving
#
#

#
#-r switch gives user ability to define his own custom pattern or default pattern

default_pattern=${default_pattern:-"$extension"}

source_dir=${source_dir:-"./"}

action=${action:-"mv -vnu"}
# Setting name for target directory
# If no name is provided take pattern for name
# and replace spaces with _
# also strip down illegal characters
if [[ "$target_directory" == "" ]]; then
	target_folder=$(echo $default_pattern |sed -e 's/ /_/g' -e 's/[!@#$%^&*+=?><,.\/:|`]//g')
else
	target_directory=$(echo $target_directory |sed -e 's/ /_/g' -e 's/[!@#$%^&*+=?><,.\/:|`]//g')
fi


target_directory=${target_directory:-"$CURENTDIR/$target_folder"}
#
# if there is no -r swith create default pattern for search
# or use argument of -p switch to create default pattern
#
custom_pattern=${custom_pattern:-"$default_pattern"}

# check if pattern is found and if nothing is found ask for new pattern
# exit if user inputs q or Q
#
while true; do
	find "$source_dir" -maxdepth 1 -type f -iregex "$custom_pattern" -printf "%f \n"
	if [[ $? -ne 0 ]]; then
		echo "Nothing found, please enter a new pattern, or insert q to quit"
		read default_pattern
			if [[ "$default_pattern" == [qQ] ]]; then
				exit 1
			fi
		custom_pattern='.*'"$default_pattern"'.*'"$extension"'$'
	else
		break
	fi
done

#
# Prints found files so user can verify
#

# printf "$result\n"

#
# Prints were files will be copied or moved
#

if [[ "$action" == "cp -vnu" ]]; then
	printf "\nFiles will be copied to $target_directory\n"
else
	printf "\nFiles will be moved to $target_directory\n"
fi

#
# Ask user for confirmation
#
until [[ "$CHOICE" = "y" ]]; do
	printf "\nAre you sure you wish to $default_action files? Y/n \n"
	dialog
	# Default choice is yes
	# If enter is pressed script will continue
	if [[ -z "$CHOICE" ]]; then
		CHOICE='y'
	elif [[ "$CHOICE" != "y" ]]; then
			printf "Nothing done, exiting...\n"
			exit 1
	fi
done

#
# We check if our destination si valid directory, if not we attempt to create it
#

make_dir $target_directory


#finaly we move or copy our files to a new destination
find "$source_dir" -maxdepth 1 -type f -iregex "$custom_pattern" -execdir $action {} "$target_directory" \;
exit 0

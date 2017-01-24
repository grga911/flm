#!/bin/bash
#
# check minimum number of switches or if --help is first argument
# and display help
#

if [ $# -lt 1 -o "$1" == "--help" -o "$1" == "-h" ]; then
 	printf " Usage filemov [OPTIONS]
\t-s\tsource directory (default is current directory)
\t-t\ttarget directory (default is current directory)
\t-p\tword default_pattern to search for
\t-e\tfile extension
\t-r\tuser custom_partner input
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
		read -p "$promote" answer
		case "$answer" in
			[Yy] ) CHOICE='y';;
 			[nN] ) CHOICE='n';;
 			*	) CHOICE="$answer"
		esac
}

#
#read switches and arguments and for each -switch assing value of it's variable
#

while getopts ":p:r:s:t:e:c" opt; do
 		case $opt in
 		p)
 			default_patern=$OPTARG	>&2
 			;;
 		r)
 			custom_patern=$OPTARG	>&2
 			;;
 		s)
 			source_dir=$OPTARG	>&2
 			;;
 		t)
 			target_directory=$OPTARG	>&2
 			;;
 		e)
 			extension=$OPTARG >&2
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
#-r switch gives user ability to define his own custom_patern default_patern

default_patern=${default_patern:-"$extension"}

source_dir=${source_dir:-"./"}

action=${action:-"mv -vnu"}

target_folder="$default_patern"

target_directory=${target_directory:-"$CURENTDIR/$target_folder"}
#
# if there is no -r swith create default default_patern for search
# use argument of -p switch to create default custom_patern default_patern
#
custom_patern=${custom_patern:-'.*'"$default_patern"'.*'"$extension"'$'}

# check if default_patern is found and if nothing is found ask for new default_patern
# exit if user inputs q or Q
#

until [[ "$result" != "" ]]; do

	result=$(find "$source_dir" -maxdepth 1 -type f -iregex "$custom_patern")
	echo "$result"
	if [[ "$result" == "" ]]; then
		echo "Nothing found, please enter a new patern, or insert q to quit"
		read default_patern
			if [[ "$default_patern" == [qQ] ]]; then
				exit 1
			fi
		custom_patern='.*'"$default_patern"'.*'"$extension"'$'
	fi
done

#
# prints found files so user can verify
#

printf "$result\n"

#
# prints were files will be copied or moved
#

if [[ "$action" == "cp -vnu" ]]; then
	printf "\nFiles will be copied to $target_directory\n"
else
	printf "\nFiles will be moved to $target_directory\n"
fi

#
# ask user for confirmation, and if affirmative
# continues with operation
#
until [[ "$CHOICE" = "y" ]]; do
	printf "\nAre you sure you wish to $default_action files? Y/n \n"
	dialog
	if [[ -z "$CHOICE" ]]; then
		CHOICE='y'
	elif [[ "$CHOICE" != "y" ]]; then
			printf "Nothing done, exiting...\n"
			exit 1
	fi
done

#
#we check if our destination si valid directory, if not we attempt to create it
#

until [[ -d "$target_directory" ]]; do
 		dialog "Directory doesn't exist, do you wish to create it? Y/n"
		
 		if [[ -z "$CHOICE" ]] || [[ "$CHOICE" == "y" ]] && [[ ! -d "$target_directory" ]] ; then
 			mkdir "$target_directory"
 		elif [[ -d "$target_directory" ]]; then
 			continue
 		else
 			printf "Nothing done exiting \n"
 			exit 1
 		fi
done

#finaly we move or copy our files to a new destination
		find "$source_dir" -maxdepth 1 -type f -iregex "$custom_patern" -exec $action {} "$target_directory" \;
exit 0

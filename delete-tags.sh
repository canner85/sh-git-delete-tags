#/bin/sh
# delete remote and local tags

VERBOSE=
REMOTE=0
LOCAL=1
TAGCOUNT=0

usage()
{
    echo "Usage: \n$0\n"
    echo "       <tag(s)>                -  A string to search for in tag list\n"
    echo "       [-v  | --verbose]       -  If search should be reversed (search tags except the <tag(s)> parameter\n"
    echo "       [-r  | --remote]        -  If remote tags should be deleted\n"
    echo "       [-il | --ignore-local]  -  If local tags should NOT be deleted\n"
    exit
}

configure()
{
	while [ "$1" != "" ]; do
	case $1 in
			-h | --help ) 			usage
									exit
	                       			;;
	        -v | --verbose ) 		VERBOSE='-v '
	                       			;;
	        -r | --remote ) 		REMOTE=1
	                	       		;;
	        -il | --ignore-local ) 	LOCAL=0
	                       			;;
	        * ) 	           		TAGS=$1
	    esac
	    shift
	done

	if [ "$TAGS" = "" ]
	then
		echo "Specify a string to search for in tag list"
	    usage
	fi

	if [ $LOCAL = 0 ] && [ $REMOTE = 0 ]
	then
		echo "You have to be sure about deleting at least local or remote."
		usage
	fi
}

getTags()
{
	git tag | grep $VERBOSE$TAGS
}

getRemoteTags()
{
	git ls-remote -t -q --refs | grep -o $VERBOSE"refs/tags/.*${TAGS}.*" | sed -e "s/refs\/tags\///g"
}

countTags()
{
	if [ $1 = 0 ]
	then
		local TEXT="\033[1;33mNo $2 tags found "
		if [ $VERBOSE ]
		then
			TEXT="$TEXT excluding "
		else
			TEXT="$TEXT containng "
		fi
		TEXT="$TEXT '$TAGS'"
		echo $TEXT
	fi
	TAGCOUNT=$(( $TAGCOUNT + $1 ))
}

checkLocalTags()
{
	if [ $LOCAL = 1 ]
	then
		local COUNT=`getTags | wc -w`
		countTags $COUNT 'local'
	fi
}

checkRemoteTags()
{
	if [ $REMOTE = 1 ]
	then
		local COUNT=`getRemoteTags | wc -w`
		countTags $COUNT 'remote'
	fi
}

checkTags()
{
	checkLocalTags
	checkRemoteTags
	if [ $TAGCOUNT = 0 ]
	then
		exit
	fi
}

deleteTags()
{
	if [ $REMOTE = 1 ]
	then
		getRemoteTags | xargs git push --delete origin
	fi
	
	if [ $LOCAL = 1 ]
	then
		getTags | xargs git tag -d
	fi

	echo "\033[1;32mTags deleted\033[0m"
}

confirm()
{
	echo "\033[1;34mConfirm deleting the following available tags\033[0m"

	if [ $LOCAL = 1 ]
	then
		echo "\033[1;33mLocal\033[0m"
		getTags | xargs | sed 's| |\ \ \|\ \ |g'
	fi

	if [ $REMOTE = 1 ]
	then
		echo "\033[1;33mRemote\033[0m"
		getRemoteTags | xargs | sed 's| |\ \ \|\ \ |g'
	fi

	read -p "Are you sure? (N/y)" -n 1 -r
	echo ""
	
	if [[ ! $REPLY =~ ^[Yy]$ ]]
	then
		echo "Deleting aborted"
    	[[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
	else
		deleteTags
	fi
}

configure $*
checkTags
confirm

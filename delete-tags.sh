#!/bin/sh
# delete remote and local tags

INVERT=
REMOTE=0
LOCAL=1
TAG_COUNT=0

usage()
{
    echo "Usage: \n$0\n"
    echo "       <tag(s)>                -  A string to search for in tag list\n"
    echo "       [-i  | --invert]        -  If search should be reversed (search tags except the <tag(s)> parameter\n"
    echo "       [-r  | --remote]        -  If remote tags should be deleted\n"
    echo "       [-il | --ignore-local]  -  If local tags should NOT be deleted\n"
    exit
}

configure()
{
    while [ "$1" != "" ]; do
    case $1 in
            -h | --help )           usage
                                    exit
                                    ;;
            -i | --invert )         INVERT='-v '
                                    ;;
            -r | --remote )         REMOTE=1
                                    ;;
            -il | --ignore-local )  LOCAL=0
                                    ;;
            * )                     TAGS=$1
        esac
        shift
    done

    if [ "$TAGS" = "" ]
    then
        echo "Specify a string to search for in tag list"
        usage
    fi

    if [ ${LOCAL} = 0 ] && [ ${REMOTE} = 0 ]
    then
        echo "You have to be sure about deleting at least local or remote."
        usage
    fi
}

getTags()
{
    git tag | grep ${INVERT}${TAGS}
}

getRemoteTags()
{
    if [ ${INVERT} ]
    then
        git ls-remote -t -q --refs | grep -o "refs/tags/.*" | grep -v ${TAGS}  | sed -e "s/refs\/tags\///g"
    else
        git ls-remote -t -q --refs | grep -o ${INVERT}"refs/tags/.*${TAGS}.*" | sed -e "s/refs\/tags\///g"
    fi
}

countTags()
{
    if [ $1 = 0 ]
    then
        local TEXT="\033[1;33mNo $2 tags found "
        if [ ${INVERT} ]
        then
            TEXT="$TEXT excluding "
        else
            TEXT="$TEXT containing "
        fi
        TEXT="$TEXT '$TAGS'"
        echo ${TEXT}
    fi
    TAG_COUNT=$(( $TAG_COUNT + $1 ))
}

checkLocalTags()
{
    if [ ${LOCAL} = 1 ]
    then
        local COUNT=`getTags | wc -w`
        countTags ${COUNT} 'local'
    fi
}

checkRemoteTags()
{
    if [ ${REMOTE} = 1 ]
    then
        local COUNT=`getRemoteTags | wc -w`
        countTags ${COUNT} 'remote'
    fi
}

checkTags()
{
    checkLocalTags
    checkRemoteTags
    if [ ${TAG_COUNT} = 0 ]
    then
        exit
    fi
}

deleteTags()
{
    if [ ${REMOTE} = 1 ]
    then
        getRemoteTags | xargs git push --delete origin
    fi

    if [ ${LOCAL} = 1 ]
    then
        getTags | xargs git tag -d
    fi

    echo "\033[1;32mTags deleted\033[0m"
}

confirm()
{
    echo "\033[1;34mConfirm deleting the following available tags\033[0m"

    if [ ${LOCAL} = 1 ]
    then
        echo "\033[1;33mLocal\033[0m"
        getTags | xargs | sed 's| |\ \ \|\ \ |g'
    fi

    if [ ${REMOTE} = 1 ]
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

#!/bin/bash
#
# git-deploy.sh -- deploy a release from a git repository to a directory
#
# The MIT License (MIT)
#
# Copyright (c) 2014 Michael Sutherland, codesmak.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

# set automatically
rpath="";
rname="";
dest="";
# repo tag to deploy, set below or with -t
rtag="HEAD";

function usage () {
    echo "${0##*/} <repo> <destination-dir> [-t <tag>]";
}


# determine the repo name and path
if [[ ! -z "$1" && -e $1 ]]
then
    # set the repo path
    rpath=$1;
    # strip trailing slash if present
    rpath=${rpath%*/}

    # update the repo path if local
    if [[ -d "$rpath/.git" ]]
    then
        rpath="$rpath/.git";
    fi

    # set the repo name
    rname=$1;
    # strip trailing slash if present
    rname=${rname%*/}
    # strip anything proceeding the repo name
    rname=${rname##*/}
else
    echo "Error repository not found" >&2;
    usage;
    exit 1;
fi

if [[ ! -z "$2" ]]
then
    # set the destination path
    dest=$2;
    # strip trailing slash if present
    dest=${dest%*/}
else
    echo "Error destination not specified" >&2;
    usage;
    exit 1;
fi

# shift for optional getopts processing
shift 2;

# process optional args
while getopts "t:" opt;
do
    case $opt in
        t)
            rtag=$OPTARG;
            ;;
        \?)
            echo "Error invalid option: -$OPTARG" >&2;
            usage;
            exit 1
            ;;
    esac
done

# display the deployment parameters and confirm
echo "Repo: $rpath @ $rtag";
echo "Dest: $dest";

echo
read -r -p "Deploy? [y/N] " confirm
echo

if [[ $confirm =~ ^([yY][eE][sS]|[yY])$ ]]
then
    # verify the requested tag exists
    $(git --git-dir=$rpath show-ref --head | grep -q $rtag)
    if [ $? != 0 ]
    then
        echo "Error tag not found in repository" >&2;
        usage;
        exit 1;
    fi

    # create the dest directory if necessary
    if [[ ! -d $dest ]]
    then
        mkdir -p "$dest";
    fi

    # run the git command
    git --git-dir=$rpath archive --format=tar --prefix=./ $rtag \
    | tar --directory=$dest -xf -

    if [ $? == 0 ];
    then
        echo "Successfully deployed $rname @$rtag to $dest";
    fi

    exit $?;
else
    echo "Aborted...";
fi
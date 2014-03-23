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

# base directory to deploy to, set below or with -d
dest="/var/www/html";
# repo tag to deploy, set below or with -t
rtag="HEAD";
# repo path determined automatically, override with -p
rpath="";
# repo name determined automatically, override with -n
rname="";

# determine the repo name and path
if [[ ! -z $1 && -e $1 ]]
then
    # set the repo path
    rpath=$1;
    # set the repo name
    rname=$1;
    # strip trailing slash if present
    rname=${rname%*/}
    # strip anything proceeding the repo name
    rname=${rname##*/}

    # shift for optional getopts processing
    shift 1;
# show the usage info
else
    echo "$0 <repo> [-t <tag>] [-d <dest>]";
    exit;
fi

# process optional args
while getopts "d:n:p:t:" opt;
do
    case $opt in
        d)
            dest=$OPTARG;
            ;;
        n)
            rname=$OPTARG;
            ;;
        p)
            rpath=$OPTARG;
            ;;
        t)
            rtag=$OPTARG;
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

# run the git command
git --git-dir=$rpath archive --format=tar --prefix=$rname/ $rtag | 
    tar --directory=$dest -xvf -

if [ $? == 0 ];
    echo "Deployed release to: $dest/$rname";
fi

exit $?;
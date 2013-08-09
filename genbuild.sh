#!/bin/bash

source ./goinit.sh $1

export TS=`date --utc +%Y-%m-%dT%H:%M:%SZ`
export GIT=`git rev-parse --verify HEAD`
export VERSION=`cat version.txt`
export STATUS=`git status`
export ID=`uuidgen`

mkdir -p ./go/src/$BUILD
export F="./go/src/$BUILD/build.go"

echo "package build" > $F
echo "import (" >> $F
echo "\"time\"" >> $F
echo "\"github.com/xoba/goutil/tool\"" >> $F
echo ")" >> $F
echo "func GetBuild() tool.Build {" >> $F
echo "t,_ := time.ParseInLocation(tool.BUILT_FORMAT,\"$TS\",time.UTC)" >> $F
echo "return tool.Build{" >> $F
echo "Version: \"$VERSION\", // pulled from version.txt" >> $F
echo "Commit: \"$GIT\", // the git commit id" >> $F
echo "Url: \"$URL/$GIT\", // a url to identify the commit" >> $F
echo "Built: t, // when this build occurred" >> $F
echo "BuildId: \"$ID\", // a nonce generated for this build" >> $F
echo "// the git status:" >> $F
echo "Status: \`$STATUS\`," >> $F
echo "}" >> $F
echo "}" >> $F

go fmt $F > /dev/null

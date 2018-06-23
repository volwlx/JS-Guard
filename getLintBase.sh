#!/bin/bash
#echo off  
JSLINT_FOLDER=MyLintJsV200
JSLINT_BASELINE_FOLDER=BaseLine
LINTCODE_PROJECTFOLDER=zc
LINTCODE_RESOURCEFOLDER=
JSLINT_REPORTER_NAME=$JSLINT_BASELINE_FOLDER/lintbase.reporter.js
JSLINT_BASE_CONFIG_FILE=$JSLINT_FOLDER/.jshintrc

LINTRESULT_FOLDER=""

#get params
for p in "$@"
do
    if [[ $p =~ ^"-tag=" ]]
    then
        LINTRESULT_FOLDER=`echo "$p" | sed 's/^-tag=//'`
    fi
done

if [ -z $LINTRESULT_FOLDER ]
then
    LINTRESULT_FOLDER=`date | sed 's/[\ \:\.]//g'`
fi


LINTCODE_PATH=`pwd`

JSLINT_PATH=$LINTCODE_PATH/$JSLINT_FOLDER
LINTCODE_PROJECTPATH=$LINTCODE_PATH/$LINTCODE_PROJECTFOLDER
LINTCODE_RESOURCEPATH=$LINTCODE_PATH/$LINTCODE_RESOURCEFOLDER
JSLINT_REPORTER_FILE=$JSLINT_PATH/$JSLINT_REPORTER_NAME

echo "Are You Sure to Get New Lint Baseline?"
echo -----------------------------------------------
echo \*"      \"Y\"/\"y\" : Yes, I'm sure.       "
echo \*"       OTHERS : No       "

# echo "so"
echo -----------------------------------------------
export NEW_LINTBASE_CONFIRM=
echo -n ":"

read NEW_LINTBASE_CONFIRM


if [ "Y" == $NEW_LINTBASE_CONFIRM -o "y" == $NEW_LINTBASE_CONFIRM ]
then
    if [ -z LINTCODE_RESOURCEFOLDER ]
    then
           jshint --reporter=$JSLINT_REPORTER_FILE --exclude=./$JSLINT_FOLDER --config=$JSLINT_BASE_CONFIG_FILE ./$LINTCODE_PROJECTFOLDER
    else
           jshint --reporter=$JSLINT_REPORTER_FILE --exclude=./$JSLINT_FOLDER --config=$JSLINT_BASE_CONFIG_FILE ./$LINTCODE_PROJECTFOLDER ./$LINTCODE_RESOURCEFOLDER
    fi
    #mv the temp file to LINTRESULT_FOLDER
    mv $JSLINT_FOLDER/$JSLINT_BASELINE_FOLDER/temp $JSLINT_FOLDER/$JSLINT_BASELINE_FOLDER/$LINTRESULT_FOLDER
    echo "New BaseLine is here"
    echo $JSLINT_FOLDER/$JSLINT_BASELINE_FOLDER/$LINTRESULT_FOLDER
else
    echo "Give up."
fi



#!/bin/bash
#echo off  
echo "-----set enviroment param start-----"
export JSLINT_FOLDER=MyLintJsV200
export JSLINT_LINT_FOLDER=Lint
export LINTCODE_PROJECTFOLDER=zc
export LINTCODE_RESOURCEFOLDER=
LINTCODE_FILELIST_NAME=filelist_sh.txt
JSLINT_REPORTER_NAME=myreporter.jsonV2.js

export LINTRESULT_FOLDER=`date | sed 's/[\ \:\.]//g'`

export LINTCODE_PATH=`pwd`

export JSLINT_ROOT_PATH=$LINTCODE_PATH/$JSLINT_FOLDER
export JSLINT_PATH=$LINTCODE_PATH/$JSLINT_FOLDER/$JSLINT_LINT_FOLDER
export LINTCODE_PROJECTPATH=$LINTCODE_PATH/$LINTCODE_PROJECTFOLDER
export LINTCODE_RESOURCEPATH=$LINTCODE_PATH/$LINTCODE_RESOURCEFOLDER
export LINTCODE_FILELIST_FILE=$LINTCODE_PATH/$LINTCODE_FILELIST_NAME
export JSLINT_REPORTER_FILE=$JSLINT_PATH/$JSLINT_REPORTER_NAME


echo Input the lint type as follows:
echo ---------------------------------------------------------------------
echo \*"      1 : Lint ALL the files in       "[current path]
echo \*"      2 : Lint FILES in               "[current path]/$LINTCODE_FILELIST_NAME
echo \*"      3 : Lint ONLY PROJECT files in  "[current path]/$LINTCODE_PROJECTFOLDER
echo \*"      4 : Lint ONLY RESOURCE files in "[current path]/$LINTCODE_RESOURCEFOLDER
echo \*" others : Lint ALL the files in       "[current path]
echo ---------------------------------------------------------------------

export MYJSLINT_TYPE=
echo -n "The Lint Type is : "
read MYJSLINT_TYPE

echo "-----code path is-------"
echo $LINTCODE_PATH

echo "-----lint result path is------"
echo $JSLINT_PATH/$LINTRESULT_FOLDER

#echo "-----get into the lint foler and do the following-----"
#cd $JSLINT_PATH
echo "-----set enviroment param end-----"



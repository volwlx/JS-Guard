#!/bin/bash
#echo off

# sh getLintDiff.sh [-tag={tag}] [-format=json|html] [-type=all|file] [-listfile={filelist_file}] [-target={target}] [-list={list}]

JSLINT_FOLDER=MyLintJsV200
JSLINT_DIFF_FOLDER=Differ
JSLINT_BASELINE_FOLDER=BaseLine
LINTCODE_FILELIST_NAME=filelist.txt
LINTCODE_PROJECTFOLDER=zc
LINTCODE_RESOURCEFOLDER=i18n
JSLINT_REPORTER_NAME=lintdiff.reporter.js
JSLINT_DIFF_SETTING_NAME=setting.json
JSLINT_DIFF_FORMAT_PREFIX=format
JSLINT_DIFF_CONFIG_FILE=$JSLINT_FOLDER/.jshintrc

LINTRESULT_FOLDER=""
LINTCODE_FILELIST_FILE=""
LINTCODE_FILE_LIST=""
MYJSLINT_TYPE="all"   #"all" or "file"
REPORT_FORMAT="json"  #"json" or "html"
BASELINE_TAG=

LINTCODE_PATH=`pwd`

JSLINT_PATH=$LINTCODE_PATH/$JSLINT_FOLDER
# LINTCODE_PROJECTPATH=$LINTCODE_PATH/$LINTCODE_PROJECTFOLDER
# LINTCODE_RESOURCEPATH=$LINTCODE_PATH/$LINTCODE_RESOURCEFOLDER

LINTDIFFFAILED=1
LINTDIFFSUCCESS=0

export LINTDIFFRESULT=$LINTDIFFFAILED

#get params
for p in "$@"
do
	echo $p
	if [[ $p =~ ^"-target=" ]]
	then
		LINTRESULT_FOLDER=`echo "$p" | sed 's/^-target=//'`
	elif [[ $p =~ ^"-type=" ]]
	then
		MYJSLINT_TYPE=`echo "$p" | sed 's/^-type=//'`
	elif [[ $p =~ ^"-listfile=" ]]
	then
		LINTCODE_FILELIST_FILE=`echo "$p" | sed 's/^-listfile=//'`
	elif [[ $p =~ ^"-format" ]]
	then
		REPORT_FORMAT=`echo "$p" | sed 's/^-format=//'`
	elif [[ $p =~ ^"-tag" ]]
	then
		BASELINE_TAG=`echo "$p" | sed 's/^-tag=//'`
	elif [[ $p =~ ^"-list" ]]
	then
		LINTCODE_FILE_LIST=`echo "$p" | sed 's/^-list=//'`
	fi
done

# echo LINTRESULT_FOLDER: $LINTRESULT_FOLDER
if [ -z $LINTRESULT_FOLDER ]
then
	LINTRESULT_FOLDER=`date | sed 's/[\ \:\.]//g'`
fi

# echo LINTCODE_FILELIST_FILE: $LINTCODE_FILELIST_FILE
if [ -z $LINTCODE_FILELIST_FILE ]
then
	LINTCODE_FILELIST_FILE=$JSLINT_PATH/$JSLINT_DIFF_FOLDER/$LINTCODE_FILELIST_NAME
fi

LINTRESULT_PATH=$JSLINT_PATH/$JSLINT_DIFF_FOLDER/$LINTRESULT_FOLDER
JSLINT_REPORTER_FILE=$LINTRESULT_PATH/$JSLINT_REPORTER_NAME

# copy the reporter and setting
if [ ! -d $LINTRESULT_PATH ]
then
	mkdir $LINTRESULT_PATH
fi
cp $JSLINT_PATH/$JSLINT_DIFF_FOLDER/$JSLINT_REPORTER_NAME       $JSLINT_REPORTER_FILE
if [ ! $REPORT_FORMAT = "html" ]
then
	REPORT_FORMAT="json"
fi

cp $JSLINT_PATH/$JSLINT_DIFF_FOLDER/$REPORT_FORMAT$JSLINT_DIFF_SETTING_NAME   $LINTRESULT_PATH/$JSLINT_DIFF_FORMAT_PREFIX-$JSLINT_DIFF_SETTING_NAME
if [ ! -z $BASELINE_TAG ] && [ -d  $JSLINT_FOLDER/$JSLINT_BASELINE_FOLDER/$BASELINE_TAG ]
then
	echo \{\"basePath\"\:\"$JSLINT_FOLDER/$JSLINT_BASELINE_FOLDER/$BASELINE_TAG/\"\} >  $LINTRESULT_PATH/$JSLINT_DIFF_SETTING_NAME
else
	cp $JSLINT_PATH/$JSLINT_DIFF_FOLDER/$JSLINT_DIFF_SETTING_NAME   $LINTRESULT_PATH/$JSLINT_DIFF_SETTING_NAME
fi


# lint start
if [ $MYJSLINT_TYPE != "file" ]
then
	echo "lint the project"
	jshint --reporter=$JSLINT_REPORTER_FILE --exclude=./$JSLINT_FOLDER --config=$JSLINT_DIFF_CONFIG_FILE $LINTCODE_PROJECTFOLDER
else
	if [ -z "$LINTCODE_FILE_LIST" ]
	then
		echo in $LINTCODE_FILELIST_FILE
		if [ ! -f $LINTCODE_FILELIST_FILE ]
		then
			LINTDIFFRESULT=$LINTDIFFFAILED
			echo "FAILED"
			exit $LINTDIFFRESULT
		else 
			LINTCODE_FILE_LIST=`cat $LINTCODE_FILELIST_FILE`
		fi
	fi
	
	allFileList=
	fileJsEnd="\.js$"
	fileMinJsEnd="\.min\.js$"
	# if use 'while read $filename' without `cat $filename`, 
	#    you miss the last line
	# if use `cat $LINTCODE_FILELIST_FILE | while read -r fileline`
	#    allFileList is still "", you cannot get it outfrom the loop
	for fileline in "$LINTCODE_FILE_LIST"
	do
		# fileline=${fileline//[\\]/\/}
		fileline=`echo "$fileline" | sed 's/[\\]/\//g'`

		fileline=`echo "$fileline"`
		# if fileline is not start with $LINTCODE_PROJECTFOLDER 
		#    or fileline is not end with ".js"
		#    or maybe it is end with ".min.js"
		#  then fileline should not be linted, yeah.
		#fileline=${fileline/#$LINTCODE_PATH\//}
		if [[ $fileline =~ $fileJsEnd ]]
		then
			if [[ $fileline =~ $fileMinJsEnd ]]
			then
				continue
			fi
			if [[ $fileline =~ ^$LINTCODE_PROJECTFOLDER|^$LINTCODE_RESOURCEFOLDER ]] 
			then
			    allFileList="$allFileList $fileline"
			fi
		fi
	done
	echo --$allFileList--
	# if [ -z $allFileList ]
	if [ -z "$allFileList" ]
	then
		LINTDIFFRESULT=$LINTDIFFSUCCESS
		echo "SUCCESS"
		exit $LINTDIFFRESULT
	fi

	jshint --reporter=$JSLINT_REPORTER_FILE --config=$JSLINT_DIFF_CONFIG_FILE $allFileList
fi
#mv the temp file to LINTRESULT_FOLDER
# mv $JSLINT_FOLDER/$JSLINT_DIFF_FOLDER/temp $JSLINT_FOLDER/$JSLINT_DIFF_FOLDER/$LINTRESULT_FOLDER
echo "Differ of this time is here"
echo $LINTRESULT_PATH
rm $LINTRESULT_PATH/$JSLINT_REPORTER_NAME
rm $LINTRESULT_PATH/$JSLINT_DIFF_SETTING_NAME
rm $LINTRESULT_PATH/$JSLINT_DIFF_FORMAT_PREFIX-$JSLINT_DIFF_SETTING_NAME

# get the lint result
summaryLineCount=`sed -n '$=' $LINTRESULT_PATH/summary.json`
echo summaryLineCount is: $summaryLineCount
if [ $summaryLineCount -eq 2 ]
then
	LINTDIFFRESULT=$LINTDIFFSUCCESS
	echo "SUCCESS"
else
	LINTDIFFRESULT=$LINTDIFFFAILED
	echo "FAILED"
fi
# zip -r -m -q  $JSLINT_FOLDER/$JSLINT_DIFF_FOLDER/$LINTRESULT_FOLDER.zip  $JSLINT_FOLDER/$JSLINT_DIFF_FOLDER/$LINTRESULT_FOLDER
exit $LINTDIFFRESULT
# or get the result in this way:
# `sh getLintDiff.sh | sed -n '$p'` or `sh getLintDiff.sh | awk 'END {print}'`
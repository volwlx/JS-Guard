#!/bin/bash
echo "-----make all the lint command start-----"

# ---make the result dir:---
echo $JSLINT_PATH/$LINTRESULT_FOLDER
# mkdir $JSLINT_PATH$LINTRESULT_FOLDER/lintresult
mkdir $JSLINT_PATH/$LINTRESULT_FOLDER

JSLINT_BATCHCMD_FILE=$JSLINT_PATH/$LINTRESULT_FOLDER/doLint.sh

# clear the file first
echo -n "" > $JSLINT_BATCHCMD_FILE

echo echo "--------lint start--------" >> $JSLINT_BATCHCMD_FILE
echo sh $JSLINT_PATH/lintPre.sh >> $JSLINT_BATCHCMD_FILE

allFileList=

if [ 2 == $MYJSLINT_TYPE ]
then
	echo in $LINTCODE_FILELIST_FILE
	while read -r fileline
	do
		fileline=`echo "$fileline" | sed 's/[\\]/\//g'`

		fileline=`echo "$fileline"`
		fileline=${fileline/#$LINTCODE_PATH\//}
		allFileList="$allFileList $fileline"
	done < $LINTCODE_FILELIST_FILE
	echo jshint --reporter=$JSLINT_REPORTER_FILE $allFileList >> $JSLINT_BATCHCMD_FILE
elif [ 3 == $MYJSLINT_TYPE ]
then
	echo project files

	echo jshint --reporter=$JSLINT_REPORTER_FILE ./$LINTCODE_PROJECTFOLDER >> $JSLINT_BATCHCMD_FILE
elif [ 4 == $MYJSLINT_TYPE ]
then
	echo resource files

	echo jshint --reporter=$JSLINT_REPORTER_FILE ./$LINTCODE_RESOURCEFOLDER >> $JSLINT_BATCHCMD_FILE
else
	echo ALL or others, means all 

	echo jshint --reporter=$JSLINT_REPORTER_FILE --exclude=./$JSLINT_FOLDER ./ >> $JSLINT_BATCHCMD_FILE
fi

echo sh $JSLINT_PATH/lintAfter.sh >> $JSLINT_BATCHCMD_FILE

echo echo "-------- lint end--------" >> $JSLINT_BATCHCMD_FILE

echo "-----the command file is here:-----"
echo $JSLINT_BATCHCMD_FILE

echo "-----make all the lint command end-----"

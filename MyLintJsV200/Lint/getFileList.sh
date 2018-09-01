#!/bin/bash

echo "-----get file list start-----"

if [ "" != "$MYJSLINT_TYPE" ]
then
    echo not nullll
else
    MYJSLINT_TYPE=1
fi

echo $MYJSLINT_TYPE

echo "-----the filelist is here:-----"
echo $LINTCODE_FILELIST_FILE

echo "-----get file list end-----"

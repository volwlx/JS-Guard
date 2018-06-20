#!/bin/bash

JSLINT_TIME_START=`date`
echo "=====set env start====="
source ./setLintEnv.sh
echo "=====get the file list====="
sh $JSLINT_PATH/getFileList.sh
echo "=====make lint cmd and mkdir======"
sh $JSLINT_PATH/getLintCmd.sh
echo "=====do the lint======"
sh $JSLINT_PATH/$LINTRESULT_FOLDER/doLint.sh
# echo.
# echo. & pause

JSLINT_TIME_END=`date`
echo "jslint starts at" $JSLINT_TIME_START
echo "jslint ends   at" $JSLINT_TIME_END

echo "=====You can check the lint rsult here:====="
echo -
echo -
echo $JSLINT_PATH/$LINTRESULT_FOLDER
echo -
echo -

# Back to the code path
cd $LINTCODE_PATH
pause "f;[;[ff[etr49nkmf"
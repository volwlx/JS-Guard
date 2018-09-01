#!/bin/bash
# 补上尾部的"]"
# echo -e \]\; >> $JSLINT_PATH/lintjson/index.html
# echo -e \<\/script\> >> $JSLINT_PATH/lintjson/index.html
# echo -e \<\/body\> >> $JSLINT_PATH/lintjson/index.html
# echo -e \<\/html\> >> $JSLINT_PATH/lintjson/index.html
cat $JSLINT_ROOT_PATH/Templates/index-end.html >> $JSLINT_PATH/lintjson/index.html
mv $JSLINT_PATH/lintjson $JSLINT_PATH/$LINTRESULT_FOLDER
mv $JSLINT_PATH/$LINTRESULT_FOLDER/lintjson/index.html $JSLINT_PATH/$LINTRESULT_FOLDER
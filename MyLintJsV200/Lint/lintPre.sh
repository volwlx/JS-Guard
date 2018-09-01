#!/bin/bash
rm -rf $JSLINT_PATH/lintjson
mkdir $JSLINT_PATH/lintjson
cp $JSLINT_ROOT_PATH/Templates/index.html  $JSLINT_PATH/lintjson/index.html
# echo -e \[ >> $JSLINT_PATH/lintjson/index.html
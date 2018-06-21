echo --------lint start--------
sh /d/web/MyLintJsV200/Lint/lintPre.sh
jshint --reporter=/d/web/MyLintJsV200/Lint/myreporter.jsonV2.js ./zc
sh /d/web/MyLintJsV200/Lint/lintAfter.sh
echo -------- lint end--------

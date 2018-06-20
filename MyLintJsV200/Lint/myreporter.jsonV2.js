"use strict";

module.exports = {
  reporter: function (res) {
    var resArr = {};
    var lintName = "";
    var lintNum = 0;
    var jsonPath = "MyLintJsV200/Lint/lintjson/";
    var lintTemplate = "MyLintJsV200/Templates/detail.html"

    /*res is array with item as follow:
    {
      file:        [string, filename]
      error: {
        id:        [string, usually '(error)'],
        code:      [string, error/warning code],
        reason:    [string, error/warning message],
        evidence:  [string, a piece of code that generated this error]
        line:      [number]
        character: [number]
        scope:     [string, message scope;
                    usually '(main)' unless the code was eval'ed]

        [+ a few other legacy fields that you don't need to worry about.]
      }
    }
    an example:
    [
      {
        file: 'demo.js',
        error:  {
          id: '(error)',
          code: 'W117',
          reason: '\'module\' is not defined.'
          evidence: 'module.exports = {',
          line: 3,
          character: 1,
          scope: '(main)',
          // [...]
        }
      },
      // [...]
    ]
    */
    arguments[1].forEach(function(fi){
      fi.file = fi.file.replace(/\\/g, "/");
      resArr[fi.file] = [];
    });
    res.forEach(function (r, i) {
      var err = r.error;
      /*incase it's a minimize file*/
      delete err.evidence;

      r.file = r.file.replace(/\\/g, "/");

      resArr[r.file].push(r);
    });

    function getOneLints(oneR, filename) {
      var str = "";
      var len = oneR.length;
      var ect = {};
      var etype = {"LintErrorNum":0, "LintWarningNum":0};
      var rgE = /^E\d*$/;
 
      // if (0 === len) {
      //   return;
      // }

      oneR.forEach(function (r) {
        var err = r.error;
        /*incase it's a minimize file*/
        delete err.evidence;

        if (undefined == ect[err.code]) {
            ect[err.code] = 0;
        }
        ect[err.code]++;
        if (rgE.test(err.code)) {
          etype.LintErrorNum++;
        }
        else{
          etype.LintWarningNum++;
        }
      });

      /*One line contains at most 4096(4k) characters,
      * then a line break is added, which may breaks a word.
      * So add line break (\n) manually and properly.
      */
      process.stdout.write("\nEnd lint file " + filename + " result.\n" );

      etype.path = filename;
      str = "{" + "\n" + '"LintErrorNum":'+etype.LintErrorNum + ",\n" +
            '"LintWarningNum":'+etype.LintWarningNum + ",\n" +
            '"file":"' + etype.path +'",\n' +
            '"errors":[\n' + 
            oneR.map(function(err){return JSON.stringify(err);}).join(",\n") + 
            "]\n" +
            "}";
      var paths = filename.split("/").filter(function(item){return !!item;});
      paths.pop();
      var p = jsonPath;

      for (var i = 0; i < paths.length; i++){
        p = p + paths[i] +  "/" ;
        if (!fs.existsSync(p)) {
          fs.mkdirSync(p); 
        }
      }
      var file = jsonPath + filename +".html";
      //Copy
      fs.writeFileSync(file, fs.readFileSync(lintTemplate));

      var fd = fs.openSync(file, "a");
      fs.writeSync(fd, str, null, null);
      fs.writeSync(fd, "\n</script>\n</body>\n</html>", null, null);
      fs.closeSync(fd);

      //to summary
      fs.writeSync(fsum, JSON.stringify(etype)+",\n", null, null);

      process.stdout.write("\nEnd lint file " + filename + " result.\n" );

    }

    var fs = require("fs");

    // if (!fs.existsSync(jsonPath)){
    //   fs.mkdirSync(jsonPath);
    // }

    var fsum = fs.openSync(jsonPath + "index.html", "a");

    for (var key in resArr) {
      getOneLints(resArr[key], key);
    }

    fs.closeSync(fsum);

  }
};
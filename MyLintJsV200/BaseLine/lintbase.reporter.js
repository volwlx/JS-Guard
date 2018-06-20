"use strict";

module.exports = {
  reporter: function (res) {
    var resArr = {};
    var jsonPath = "MyLintJsV200/BaseLine/temp/";
    var evidence_maxlength = 200;

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
      if (err.evidence && (err.evidence.length > evidence_maxlength)){
        err.evidence = "It's TOO LONG TO SHOW.";
      }
      // delete err.evidence;

      r.file = r.file.replace(/\\/g, "/");

      resArr[r.file].push(r);
    });
    function strPercode(percode,code) {
      return code +":{" + "\n" + 
              '"code":"'+percode.code + '",\n' +
              '"count":'+percode.count + ",\n" +
              '"detail":[\n' + 
                  percode.detail.map(function(err){return JSON.stringify(err);}).join(",\n") + 
              "\n]\n" +
            "}";
    }
    function getPerfileName(filename) {
      var paths = filename.split("/").filter(function(item){return !!item;});
      paths.pop();
      var p = jsonPath;

      for (var i = 0; i < paths.length; i++){
        p = p + paths[i] +  "/" ;
        if (!fs.existsSync(p)) {
          fs.mkdirSync(p); 
        }
      }
      var file = jsonPath + filename +".json";
      return file;
    }
    function getOneLints(oneR, filename) {
      var str = "";
      var len = oneR.length;
      var ect = {};
      var etype = {};
      var errMap = {};
      var rgE = /^E\d*$/;
 
      // if (0 === len) {
      //   return;
      // }

      oneR.forEach(function (r) {
        var err = r.error;
        /*incase it's a minimize file*/
        if (err.evidence && (err.evidence.length > evidence_maxlength)){
          err.evidence = "It's TOO LONG TO SHOW.";
        }
        // delete err.evidence;
        if (undefined == errMap[err.code]){
          errMap[err.code] = {
            code: err.code,
            count: 0,
            detail: []
          };
        }
        errMap[err.code].count++;
        errMap[err.code].detail.push(err);
      });

      /*One line contains at most 4096(4k) characters,
      * then a line break is added, which may breaks a word.
      * So add line break (\n) manually and properly.
      */

      // etype.path = filename;

      str = "{\n";
      var codeL = Object.keys(errMap).length;
      var codeC = 0;
      for (var code in errMap) {
        codeC++;
        str = str + strPercode(errMap[code], code)+ ((codeC < codeL)?",":"") + "\n";

        // summary
        etype[code] = errMap[code].count;
      }
      str = str + "}";

      var file = getPerfileName(filename);

      var fd = fs.openSync(file, "a");
      fs.writeSync(fd, str, null, null);
      fs.closeSync(fd);

      process.stdout.write("\nEnd lint file " + filename + " result.\n" );
      return  JSON.stringify(etype);
    }

    var fs = require("fs");

    if (!fs.existsSync(jsonPath)){
      fs.mkdirSync(jsonPath);
    }

    var fsum = fs.openSync(jsonPath + "summary.json", "a");
    var summary;
    var fileFollow = false;
    fs.writeSync(fsum, "{", null, null);
    for (var key in resArr) {
      summary = getOneLints(resArr[key], key);

      //to summary
      fs.writeSync(fsum, (fileFollow?",":"") + "\n" + '"'+ key +'":' + summary, null, null);
      fileFollow = true;
    }
    fs.writeSync(fsum, "\n}", null, null);

    fs.closeSync(fsum);

  }
};
"use strict";

module.exports = {
  reporter: function (res) {
    var resArr = {};
    var jsonPath = "MyLintJsV200/Differ/temp/";
    // var setting  = require("MyLintJsV200/Differ/setting.json");
    var settingPath = "MyLintJsV200/Differ/setting.json";
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
    var thisPath = __dirname.replace(/\\/g,"/");
    var lintPath = process.cwd().replace(/\\/g,"/");
    // console.log (thisPath);
    // console.log(lintPath);
    jsonPath = thisPath.slice(lintPath.length + 1) + "/";
    settingPath = jsonPath + "setting.json";
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
    function getPerfileName(filename, ftype) {
      var paths = filename.split("/").filter(function(item){return !!item;});
      paths.pop();
      var p = jsonPath;

      for (var i = 0; i < paths.length; i++){
        p = p + paths[i] +  "/" ;
        if (!fs.existsSync(p)) {
          fs.mkdirSync(p); 
        }
      }
      var file = jsonPath + filename +"." + ftype;
      return file;
    }
    function unforgivable(code) {
      var rgE = /^E\d*$/;
      var blackList = [];
      var whiteList = ["E043"];
      // E043 -- "Too manay Errors"
      return (rgE.test(code) && (whiteList.indexOf(code) < 0)) || (blackList.indexOf(code) > 0);
    }
    function write2DetailFile(filename, str) {
      var ftype = setting.reportFormat || "json";
      var file = getPerfileName(filename, ftype);
      var w = {
        html:function(){
          var fd = fs.openSync(file, "a");
          fs.appendFileSync(file, fs.readFileSync(setting.detailTemplate.head) );
          fs.appendFileSync(file, '"base":\n');
          try {
            fs.appendFileSync(file, fs.readFileSync(setting.basePath + filename + ".json") );
          }
          catch (e) {
            process.stdout.write("Read base error, it is a new file!")
            fs.appendFileSync(file, '{}');
          }
          fs.appendFileSync(file, ',\n"file": "' + filename+ '"');
          fs.appendFileSync(file, ',\n"diff":\n');
          fs.appendFileSync(file, str );
          fs.appendFileSync(file, fs.readFileSync(setting.detailTemplate.tail));
          fs.closeSync(fd);
        },
        json: function() {
            write2File(file, str);
        }
      };
      if (w[ftype]) {
        w[ftype] ();
      }
    }
    function getOneLints(oneR, filename, base) {
      var str = "";
      var len = oneR.length;
      var errMap = {};
      var diff = {};
 
      if (0 === len) {
        return "";
      }

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

      str = "{";
      var diffCount = 0;
      var codeFollow = false;
      for (var code in errMap) {
        if (!base || !base[code] || (errMap[code].count > base[code]) || unforgivable(code)) {
          // record this diff
          diff[code] = {
            "increase": errMap[code].count - ((base && base[code]) || 0),
            "count": errMap[code].count,
            "raw": errMap[code].detail[0].raw
          };
          diffCount++;
          str = str + (codeFollow?",":"") + "\n" + strPercode(errMap[code], code);
          codeFollow=true;
        }
      }
      str = str + "\n}";

      if (diffCount > 0) {
        write2DetailFile(filename, str);
      }

      process.stdout.write("\nEnd lint file " + filename + " result.\n" );
      return (diffCount > 0)?JSON.stringify(diff):"";
    }
    function write2File(filenme, content) {
      var ff = fs.openSync(filenme, "a");
      fs.writeSync(ff, content, null, null);

      fs.closeSync(ff);
    }
    function exFormatReport (){
      var ex = {
        "html": function (){
          var file = jsonPath + "differ" +"." + setting.reportFormat;
          //Copy
          // fs.writeFileSync(file, fs.readFileSync(setting.summaryTemplate。head));
          // var fd = fs.openSync(file, "a");
          // fs.writeSync(fd, "", null, null );
          // fs.closeSync(fd);
          fs.appendFileSync(file, fs.readFileSync(setting.summaryTemplate.head));
          fs.appendFileSync(file, fs.readFileSync(jsonPath + "summary.json"));
          fs.appendFileSync(file, fs.readFileSync(setting.summaryTemplate.tail));
        }
      };
      if (ex[setting.reportFormat]) {
        ex[setting.reportFormat]();
      }
    }

    var fs = require("fs");
    var setting = JSON.parse(fs.readFileSync(settingPath));
    // process.stdout.write(setting );
    // console.log(setting);

    var basePath = setting.basePath;
    var baseSummary = JSON.parse(fs.readFileSync(basePath + "summary.json"));
    // console.log(baseSummary);

    if (!fs.existsSync(jsonPath)){
      fs.mkdirSync(jsonPath);
    }

    var fsum = fs.openSync(jsonPath + "summary.json", "a");
    var diff;
    var fileFollow = false;
    var errFiles="";
    fs.writeSync(fsum, "{", null, null);
    for (var key in resArr) {
      diff = getOneLints(resArr[key], key, baseSummary[key]);
      if (!!diff) {
        //to summary
        fs.writeSync(fsum, (fileFollow?",":"") + "\n" + '"'+ key +'":' + diff, null, null);
        fileFollow = true;
        errFiles = errFiles + key +"\n";
      }
    }
    fs.writeSync(fsum, "\n}", null, null);

    fs.closeSync(fsum);

    if (errFiles.length) {
      write2File(jsonPath + "errorFile.log", errFiles);
    }
    exFormatReport();
  }
};
(function() {
  var consoleControl, elasticfn, init, listen, __root;

  __root = this;

  listen = function(el, m, cb) {
    if (el.attachEvent) el.attachEvent("on" + m, cb);
    if (el.addEventListener) return el.addEventListener(m, cb, false);
  };

  window.DIV_CONSOLE = "console";

  consoleControl = (function() {

    consoleControl.prototype.info = {
      status: true
    };

    function consoleControl(data) {
      this.info.div = window.DIV_CONSOLE;
      this.info.divObject = this.response.data.console = document.getElementById(window.DIV_CONSOLE);
    }

    consoleControl.prototype.line = function() {
      var div, el, el_dir, idActive, objcls, text, toWrite;
      objcls = this;
      idActive = "active_input";
      toWrite = document.getElementById(idActive);
      if (toWrite) {
        toWrite.removeAttribute("id");
        toWrite.className = "inactive";
        toWrite.disabled = true;
      }
      toWrite = document.createElement("input");
      div = document.createElement("div");
      el = document.createElement("strong");
      el_dir = document.createElement("em");
      toWrite.id = idActive;
      div.className = "dta";
      text = document.createTextNode(this.info.user + "@" + this.info.site);
      el_dir.appendChild(document.createTextNode(this.info.dir));
      el.appendChild(text);
      div.appendChild(el);
      div.appendChild(el_dir);
      div.appendChild(toWrite);
      this.info.divObject.appendChild(div);
      toWrite.focus();
      listen(this.info.divObject, "click", function() {
        return toWrite.focus();
      });
      return listen(toWrite, "keypress", function(e) {
        var chars, enter_key, key_int, val_c;
        enter_key = 13;
        key_int = e.keyCode ? e.keyCode : e.Which;
        if (key_int === enter_key) {
          val_c = document.getElementById("active_input").value;
          objcls.send(val_c);
        }
        chars = this.value.length === 0 ? 1 * 10 : this.value.length * 10;
        return this.style.width = chars + "px";
      });
    };

    consoleControl.prototype.open = function() {
      this.info.divObject.style.display = "block";
      return document.getElementById("active_input").focus();
    };

    consoleControl.prototype.close = function() {
      return this.info.divObject.style.display = "none";
    };

    consoleControl.prototype.toggle = function() {
      if (this.info.divObject.style.display === "block" || this.info.divObject.style.display === "") {
        return this.info.divObject.style.display = "none";
      } else {
        return this.info.divObject.style.display = "block";
      }
    };

    consoleControl.prototype.disable = function(txt) {
      this.info.status = false;
      return this.info.disabled_txt = txt ? txt : "System is disabled";
    };

    consoleControl.prototype.enable = function() {
      return this.info.status = true;
    };

    consoleControl.prototype.isEnabled = function() {
      return this.info.status;
    };

    consoleControl.prototype.send = function(c) {
      var obj;
      obj = {
        val: c,
        values: c.split(" ")
      };
      if (!this.default_commands(obj)) {
        this.response.data.last = c;
        this.response.callback(obj);
      }
      if (!this.info.status) {
        this.response.info(this.info.disabled_txt);
        this.line();
        return false;
      } else {
        return this.line();
      }
    };

    consoleControl.prototype.response = {
      data: {},
      callback: function() {},
      info: function(text) {
        var el;
        text = new String(text);
        el = document.createElement("p");
        el.className = "info";
        el.appendChild(document.createTextNode(text));
        return this.data.console.appendChild(el);
      },
      is: function(d) {
        var defRegExp, i, ing, _i, _len;
        if (d instanceof RegExp && this.data.last.match(d)) {
          return true;
        } else if (d instanceof Object) {
          defRegExp = {
            "int": /^(?:\+|-)?\d+$/,
            "word": /(?:[a-z][a-z]+)/,
            "command": /-[a-z]+/,
            "string": /"(?:[a-z][a-z]+)"/,
            "email": /[\w-\.]{3,}@([\w-]{2,}\.)*([\w-]{2,}\.)[\w-]{2,4}/
          };
          ing = this.data.last.split(" ");
          if (ing.length !== d.length) return false;
          for (_i = 0, _len = d.length; _i < _len; _i++) {
            i = d[_i];
            if (!ing[_i].match(defRegExp[i])) return false;
          }
          return true;
        }
      }
    };

    consoleControl.prototype.onSend = function(fn) {
      return this.response.callback = fn;
    };

    consoleControl.prototype.commands = ['(cd)(\\s+)((?:[a-z][a-z0-9_]*))', '(cu)(\\s+)((?:[a-z][a-z0-9_]*))', '(cs)(\\s+)((?:[a-z][a-z0-9_]*))', '(exit)', 'clear'];

    consoleControl.prototype.commands_fns = [
      function(nm) {
        return consolecms.info.dir = nm.values[1];
      }, function(nm) {
        return consolecms.info.user = nm.values[1];
      }, function(nm) {
        return consolecms.info.site = nm.values[1];
      }, function() {
        return consolecms.close();
      }, function() {
        return alert("dd");
      }
    ];

    consoleControl.prototype.default_commands = function(o) {
      var i, _i, _len, _ref;
      if (!this.info.status) return false;
      _ref = this.commands;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        i = _ref[_i];
        if (o.val.match(this.commands[_i])) {
          this.response.data.last = o.val;
          this.response.values = o.val.split(" ");
          this.commands_fns[_i](this.response);
          return true;
        }
      }
      return false;
    };

    consoleControl.prototype.setCommand = function(expr, fn) {
      var regExp;
      regExp = new RegExp(expr);
      this.commands.push(regExp);
      return this.commands_fns.push(fn);
    };

    consoleControl.prototype.run = function(d) {
      this.info.user = d.user;
      this.info.dir = d.dir;
      this.info.site = d.sitename;
      return this.line();
    };

    return consoleControl;

  })();

  elasticfn = (function() {

    elasticfn.prototype.data = {
      status: false,
      mouse: 0,
      height: 400
    };

    function elasticfn(obj, consoleObj) {
      var _this = this;
      this.obj = obj;
      this.consoleObj = consoleObj;
      this.consoleObj.style["height"] = this.data.height + "px";
      listen(this.obj, "mousedown", function(d) {
        var shadow;
        shadow = document.createElement("div");
        shadow.id = "shadow";
        document.getElementsByTagName("body")[0].appendChild(shadow);
        _this.data.mouse = d.clientY;
        _this.data.status = true;
        _this.obj.style.background = "#FFF";
        document.onselectstart = function() {
          return false;
        };
        if (!document.onselectstart) {
          return document.onmousedown = function() {
            return false;
          };
        }
      });
      listen(window, "mouseup", function(d) {
        var shadow;
        if (_this.data.status) {
          _this.data.height = _this.data.height + (_this.data.mouse - d.clientY);
          _this.consoleObj.style["height"] = _this.data.height + "px";
          _this.obj.style.background = "transparent";
          document.onselectstart = void 0;
          document.onmousedown = void 0;
          shadow = document.getElementById("shadow");
          shadow.parentNode.removeChild(shadow);
          return _this.data.status = false;
        }
      });
      listen(window, "mousemove", function(d) {
        var shadow;
        if (_this.data.status) {
          shadow = document.getElementById("shadow");
          return shadow.style.top = d.pageY + "px";
        }
      });
    }

    return elasticfn;

  })();

  init = function() {
    (function() {
      var div, el, elastic, getBody, resize;
      div = document.getElementById(DIV_CONSOLE);
      if (div === null) {
        el = document.createElement("div");
        el.id = DIV_CONSOLE;
        getBody = document.getElementsByTagName("body");
        getBody[0].insertBefore(el, getBody[0].childNodes[0]);
        elastic = document.createElement("span");
        elastic.id = "elastic";
        document.getElementById(DIV_CONSOLE).appendChild(elastic);
        return resize = new elasticfn(elastic, document.getElementById(DIV_CONSOLE));
      }
    })();
    return window.consolecms = new consoleControl();
  };

  if (window.jQuery) {
    $(document).ready(init);
  } else {
    listen(window, "load", init);
  }

}).call(this);

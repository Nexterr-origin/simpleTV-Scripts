
local base = _G

module ('playerjs')

base.require('jsdecode')

 function decode(str,playerjs_url)

    local userAgent = "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36 OPR/66.0.3515.115"
    local session = base.m_simpleTV.Http.New(userAgent)
    if session == nil then return nil end

    local url = playerjs_url
    local rc,answer = base.m_simpleTV.Http.Request(session,{url = url}) 
    base.m_simpleTV.Http.Close(session) 
    if rc~=200 then return nil end
   
    --base.debug_in_file(answer .. '\n')
   
    local pattern = 'eval(.-)"undefined"!=typeof window&&function'
    local fun = base.findpattern(answer,pattern,1,4,36)
    if fun==nil then
       fun = base.findpattern(answer,'eval(.+)',1,4,0) 
    end   
    if fun==nil then return nil end
   
    answer = base.jsdecode.DoDecode(fun)
    if answer==nil then return nil end
   
    --base.debug_in_file(answer .. '\n')
   
    local u, y = base.string.match(answer, "u:'(.-)'.-y:'(.-)'")
    if u==nil or y==nil then return nil end
   
    scr = "var o = {u:'" .. u .. "', y:'" .. y .. "'};"  ..
   [[
       function fd2(x) {
           var a;
   
   a = x.substr(2);for(var i=4;i>-1;i--){if(exist(v["bk"+i])){if(v["bk"+i]!=""){a = a.replace((v.file3_separator||"//")+b1(v["bk"+i]),"");}}}try{a = b2(a);}catch(e){a="";}
                   function b1(str) {
                       return btoa(encodeURIComponent(str).replace(/%([0-9A-F]{2})/g,
                           function toSolidBytes(match, p1) {
                               return String.fromCharCode("0x" + p1);
                       }));
                   }
                   function b2(str) {
                       return decodeURIComponent(atob(str).split("").map(function(c) {
                           return "%" + ("00" + c.charCodeAt(0).toString(16)).slice(-2);
                       }).join(""));
                   }
   
           return a
       };
   
       var dechar = function(x) {
           return String.fromCharCode(x)
       };
       var decode = function(x) {
           if (x.substr(0, 2) == "#1") {
               return salt.d(pepper(x.substr(2), -1))
           } else if (x.substr(0, 2) == "#0") {
               return salt.d(x.substr(2))
           } else {
               return x
           }
       };
   
       var abc = String.fromCharCode(65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122);
       var salt = {
           _keyStr: abc + "0123456789+/=",
           e: function(e) {
               var t = "";
               var n, r, i, s, o, u, a;
               var f = 0;
               e = salt._ue(e);
               while (f < e.length) {
                   n = e.charCodeAt(f++);
                   r = e.charCodeAt(f++);
                   i = e.charCodeAt(f++);
                   s = n >> 2;
                   o = (n & 3) << 4 | r >> 4;
                   u = (r & 15) << 2 | i >> 6;
                   a = i & 63;
                   if (isNaN(r)) {
                       u = a = 64
                   } else if (isNaN(i)) {
                       a = 64
                   }
                   t = t + this._keyStr.charAt(s) + this._keyStr.charAt(o) + this._keyStr.charAt(u) + this._keyStr.charAt(a)
               }
               return t
           },
           d: function(e) {
               var t = "";
               var n, r, i;
               var s, o, u, a;
               var f = 0;
               e = e.replace(/[^A-Za-z0-9\+\/\=]/g, "");
               while (f < e.length) {
                   s = this._keyStr.indexOf(e.charAt(f++));
                   o = this._keyStr.indexOf(e.charAt(f++));
                   u = this._keyStr.indexOf(e.charAt(f++));
                   a = this._keyStr.indexOf(e.charAt(f++));
                   n = s << 2 | o >> 4;
                   r = (o & 15) << 4 | u >> 2;
                   i = (u & 3) << 6 | a;
                   t = t + dechar(n);
                   if (u != 64) {
                       t = t + dechar(r)
                   }
                   if (a != 64) {
                       t = t + dechar(i)
                   }
               }
               t = salt._ud(t);
               return t
           },
           _ue: function(e) {
               e = e.replace(/\r\n/g, "\n");
               var t = "";
               for (var n = 0; n < e.length; n++) {
                   var r = e.charCodeAt(n);
                   if (r < 128) {
                       t += dechar(r)
                   } else if (r > 127 && r < 2048) {
                       t += dechar(r >> 6 | 192);
                       t += dechar(r & 63 | 128)
                   } else {
                       t += dechar(r >> 12 | 224);
                       t += dechar(r >> 6 & 63 | 128);
                       t += dechar(r & 63 | 128)
                   }
               }
               return t
           },
           _ud: function(e) {
               var t = "";
               var n = 0;
               var r = 0;
               var c1 = 0;
               var c2 = 0;
               while (n < e.length) {
                   r = e.charCodeAt(n);
                   if (r < 128) {
                       t += dechar(r);
                       n++
                   } else if (r > 191 && r < 224) {
                       c2 = e.charCodeAt(n + 1);
                       t += dechar((r & 31) << 6 | c2 & 63);
                       n += 2
                   } else {
                       c2 = e.charCodeAt(n + 1);
                       c3 = e.charCodeAt(n + 2);
                       t += dechar((r & 15) << 12 | (c2 & 63) << 6 | c3 & 63);
                       n += 3
                   }
               }
               return t
           }
       };
       var pepper = function(s, n) {
           s = s.replace(/\+/g, "#");
           s = s.replace(/#/g, "+");
           var a = sugar(o.y) * n;
           if (n < 0) a += abc.length / 2;
           var r = abc.substr(a * 2) + abc.substr(0, a * 2);
           return s.replace(/[A-Za-z]/g, function(c) {
               return r.charAt(abc.indexOf(c))
           })
       };
       var sugar = function(x) {
           x = x.split(dechar(61));
           var result = '';
           var c1 = dechar(120);
           var chr;
           for (var i in x) {
               if (x.hasOwnProperty(i)) {
                   var encoded = '';
                   for (var j in x[i]) {
                       if (x[i].hasOwnProperty(j)) {
                           encoded += (x[i][j] == c1) ? dechar(49) : dechar(48)
                       }
                   }
                   chr = parseInt(encoded, 2);
                   result += dechar(chr.toString(10))
               }
           }
           return result.substr(0, result.length - 1)
       };
       var exist = function(x) {
           return x != null && typeof(x) != 'undefined' && x != 'undefined'
       };
   
      var v = JSON.parse(decode(o.u));
   ]] 
   
    local dStr = base.jsdecode.DoDecode('fd2("' .. str .. '");', false, scr, 0)
    if dStr==nil then return nil end
   
    return dStr
 end



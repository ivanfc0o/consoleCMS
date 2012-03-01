# @author: Iván Ibarra - ivanfc0o@gmail.com 
# console-like CMS
__root = this
# consoleADM and settings
consoleADM = {}
consoleADM.default =
	user_default: "anonimo"
	sitename: "consolecms"
	principal: "home"
	consoleId: "consola"

listen = (el, m, cb)->
	if el.attachEvent
		el.attachEvent "on"+m, cb;
	if el.addEventListener
		el.addEventListener m, cb, false
# Clase controladora
class consoleControl
	info: {}
	constructor: (data)->
		@info.dir = data.principal
		@info.div = data.consoleId
		@info.user = data.user_default
		@info.site = data.sitename
		@info.divObject = @response.data.console = document.getElementById data.consoleId
		@line()
	line: ()->
		objcls = this
		idActive = "active_input"
		##--------------------------------------------------------
		toWrite = document.getElementById(idActive);
		if toWrite
			toWrite.removeAttribute("id");
			toWrite.className = "inactive"
			toWrite.disabled = true
		##--------------------------------------------------------
		toWrite = document.createElement "input"
		div = document.createElement "div"
		el = document.createElement "strong"
		el_dir = document.createElement "em"
		##--------------------------------------------------------
		toWrite.id = idActive
		div.className= "dta"
		text = document.createTextNode @info.user+"@"+@info.site
		##--------------------------------------------------------
		el_dir.appendChild document.createTextNode @info.dir
		##--------------------------------------------------------
		el.appendChild(text)
		div.appendChild(el)
		div.appendChild(el_dir)
		div.appendChild(toWrite)
		##--------------------------------------------------------
		@info.divObject.appendChild(div)
		##--------------------------------------------------------
		toWrite.focus()
		##--------------------------------------------------------
		listen @info.divObject, "click", ()-> toWrite.focus()
		listen toWrite, "keypress", (e)->
			enter_key = 13
			key_int = if e.keyCode then e.keyCode else e.Which
			if key_int is enter_key
				val_c = document.getElementById("active_input").value
				objcls.send(val_c)
			chars = if @value.length is 0 then 1*15 else @value.length*15
			@style.width = chars+"px"
	##--------------------------------------------------------
	open: ()->
		@info.divObject.style.display = "block";
	close: ()->
		@info.divObject.style.display = "none";
	##--------------------------------------------------------
	send: (c)->
		obj =
		    val: c 
		    values: c.split(" ");
		@response.data.last = c;
		@response.callback(obj);
		@line();
	response: 
		data: {}
		callback: ()->
		info: (text) ->
			text = new String text;
			el = document.createElement "p"
			el.className = "info"
			el.appendChild document.createTextNode text;
			@data.console.appendChild el
		is: (d)->
			if d instanceof RegExp and @data.last.match(d)
				return true
			else if d instanceof Object
				defRegExp = 
					"int": /^(?:\+|-)?\d+$/
					"word": /(?:[a-z][a-z]+)/
					"command": /-[a-z]+/
					"string": /"(?:[a-z][a-z]+)"/
					"email": /[\w-\.]{3,}@([\w-]{2,}\.)*([\w-]{2,}\.)[\w-]{2,4}/
				ing = @data.last.split(" ");
				if ing.length isnt d.length 
					return false
				for i in d
					if  not ing[_i].match(defRegExp[i])
						return false
				return true

	onSend: (fn)->
		@response.callback = fn

init = ()->
	(()->
		div = document.getElementById(consoleADM.default.consoleId);
		if div is null
	       	#insertar div base
	       	el = document.createElement "div"
	       	el.id = consoleADM.default.consoleId
	       	getBody = document.getElementsByTagName "body"
	       	getBody[0].insertBefore el, getBody[0].childNodes[0];
	)();
	# Global data
	window.consolecms = new consoleControl consoleADM.default;

# Fix jquery load conflict with document:ready
if jQuery
	$(document).ready init
else
	listen window, "load", init
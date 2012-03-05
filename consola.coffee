# @author: Iván Ibarra - ivanfc0o@gmail.com 
# console-like CMS
__root = this
listen = (el, m, cb)->
	if el.attachEvent
		el.attachEvent "on"+m, cb;
	if el.addEventListener
		el.addEventListener m, cb, false
window.DIV_CONSOLE = "console"
# Clase controladora
class consoleControl
	info: {}
	constructor: (data)->
		@info.div = window.DIV_CONSOLE
		@info.divObject = @response.data.console = document.getElementById window.DIV_CONSOLE
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
			chars = if @value.length is 0 then 1*10 else @value.length*10
			@style.width = chars+"px"
	##--------------------------------------------------------
	open: ()->
		@info.divObject.style.display = "block";
	close: ()->
		@info.divObject.style.display = "none";
	toggle: ()->
		if @info.divObject.style.display is "block" or @info.divObject.style.display is ""
		   @info.divObject.style.display = "none"
		else
		   @info.divObject.style.display = "block"
	##--------------------------------------------------------
	send: (c)->
		obj =
		    val: c 
		    values: c.split(" ");
		if not @default_commands(obj)
			@response.data.last = c;
			@response.callback(obj);
			@line();
		else 
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
	default_commands: (o)->
		expd = [
			'(cd)(\\s+)((?:[a-z][a-z0-9_]*))' # CD
			'(cu)(\\s+)((?:[a-z][a-z0-9_]*))' # Change name
			'(cs)(\\s+)((?:[a-z][a-z0-9_]*))' # Change sitename
			'(exit)' # close console
		]
		makefn = [
			(nm)-> consolecms.info.dir = nm
			(nm)-> consolecms.info.user = nm
			(nm)-> consolecms.info.site = nm
			()-> consolecms.close()
		]
		for i in expd
			if o.val.match(expd[_i])
				switch (o.values.length)
					when 3 then makefn[_i](o.values[2]);
					else makefn[_i](o.values[1]);
				return true
		false
	run: (d)->
		@info.user = d.user
		@info.dir = d.dir
		@info.site = d.sitename
		@line();

class elasticfn
	data: {status: false, mouse: 0, height: 400}
	constructor: (@obj, @consoleObj)->
		@consoleObj.style["height"] = @data.height+"px"
		listen @obj, "mousedown", (d)=>
			##--------------------------------------------------------
			shadow = document.createElement "div"
			shadow.id = "shadow"
			document.getElementsByTagName("body")[0].appendChild shadow
			##--------------------------------------------------------
			@data.mouse = d.clientY
			@data.status = true;
			@obj.style.background = "#FFF";
			document.onselectstart = ()-> return false; # Ie, chrome selection
			if not document.onselectstart
				document.onmousedown = ()-> return false; # Firefox Selection false
		listen window, "mouseup", (d)=>
			if @data.status
				@data.height = (@data.height)+(@data.mouse-d.clientY)
				@consoleObj.style["height"]  = @data.height+"px"
				@obj.style.background = "transparent";
				document.onselectstart = undefined;
				document.onmousedown = undefined; # Firefox Selection false
				shadow = document.getElementById "shadow"
				shadow.parentNode.removeChild shadow
				@data.status = false
		listen window, "mousemove", (d)=>
			if @data.status
				shadow = document.getElementById "shadow"
				shadow.style.top = d.pageY+"px"
 
init = ()->
	(()->
		div = document.getElementById DIV_CONSOLE
		if div is null
	       	#insertar div base
	       	el = document.createElement "div"
	       	el.id = DIV_CONSOLE
	       	getBody = document.getElementsByTagName "body"
	       	getBody[0].insertBefore el, getBody[0].childNodes[0];
	       	elastic = document.createElement "span"
	       	elastic.id = "elastic";
	       	document.getElementById(DIV_CONSOLE).appendChild(elastic)
	       	resize = new elasticfn elastic, document.getElementById(DIV_CONSOLE)
	)();
	# Global data
	window.consolecms = new consoleControl();
		
# Fix jquery load conflict with document:ready
if jQuery
	$(document).ready init
else
	listen window, "load", init
Theme(info=""){
	static x,newwin,qfobj:={"Quick Find Bottom Background":"bb","Quick Find Bottom Forground":"bf","Quick Find Top Background":"tb","Quick Find Top Forground":"tf","Quick Find Edit Background":"qfb"}
	x:=Studio()
	if(IsObject(info))
		goto,returnedinfo
	newwin:=new GUIKeep("Theme",x),newwin.add("TreeView,w300 h500 hwndlv gthemetv AltSubmit,,h","s,x+2 w500 h500,,wh"),theme:=newwin.sc.1,theme.2512(0),color(theme),theme.2246(0,1),theme.2400,theme.2563(0)
	Loop,99
		theme.2409(A_Index,1)
	v.themelist:=[],color:=TV_Add("Color")
	for a,b in ["Background","Brace Match Color","Brace Match Indicator Reset","Brace Match Style","Caret Line Background","Caret","Code Explorer Background","Code Explorer Text Color","Code Explorer Text Style","Compare Color","Default Background Color","Default Font Style","Edited Marker","End Of Line Color","Fold Box","Fold Lines","Indent Guide","Main Selection Background","Main Selection Foreground","Multiple Indicator Color","Multiple Selection Background","Multiple Selection Foreground","Project Explorer Background","Project Explorer Text Color","Project Explorer Text Style","Quick Find Clear","Quick Find Bottom Background","Quick Find Bottom Forground","Quick Find Top Background","Quick Find Top Forground","Remove Main Selection Forground","Remove Multiple Selection Forground","Reset To Default","Saved Marker","StatusBar Text Style","Quick Find Edit Background"]
		v.themelist[TV_Add(b,color,"Sort")]:=b
	options:=TV_Add("Theme Options")
	for a,b in ["Edit Theme Name","Edit Author","Download Themes","Export Theme","Import Theme","Save Theme","Display Style Number At Caret"]
		v.themelist[TV_Add(b,options,"Sort")]:=b
	v.themelist[TV_Add("Color Input Method")]:="Color Input Method",v.themelist[TV_Add("Caret Width")]:="Caret Width",tlist:=preset.sn("//fonts/name"),tl:=TV_Add("Themes"),v.themetv:=tl
	while,tt:=tlist.item[A_Index-1]
		v.themelist[TV_Add(tt.text,tl)]:="themes list"
	for a,b in [color,options,themes,tl]
		TV_Modify(b,"Expand")
	theme.2246(0,1),method:=Round(settings.ssn("//colorinput").text),mode:={0:"Gui",1:"Hex"}
	TV_Modify(color,"Vis"),themetext(),highlight(),newwin.show("Theme - Color Input Method: " mode[method])
	return event:=""
	themetv:
	event:=v.themelist[TV_GetSelection()]
	if(v.themetv=A_EventInfo)
		return
	if(A_GuiEvent!="normal"&&A_GuiEvent!="K")
		return
	if(InStr(event,"Quick Find")){
		if(!top:=settings.ssn("//fonts/find"))
			top:=settings.add("fonts/find")
		attribute:=qfobj[event]
		if(event="quick find clear")
			for a,b in qfobj
				top.RemoveAttribute(b)
		else
			ea:=xml.ea(top),color:=Dlg_Color(ea[attribute],newwin.hwnd),top.SetAttribute(attribute,color)
	}if(InStr(event,"StatusBar")){
		if(!top:=settings.ssn("//fonts/custom[@gui='1' and @control='msctls_statusbar321']"))
			top:=settings.add("fonts/custom","","",1),att(top,{gui:1,control:"msctls_statusbar321"})
		ea:=ea(top)
		if(!dlg_font(ea,1,newwin.hwnd))
			return
		for a,b in ea
			top.SetAttribute(a,b)
	}
	if(event="Multiple Indicator Color"){
		if(!top:=settings.ssn("//fonts/indicator[@indic='3']"))
			top:=settings.add("fonts/indicator","","",1),att(top,{indic:3})
		color:=Dlg_Color(ea(top).Background,newwin.hwnd),top.SetAttribute("background",color)
	}
	if(event~="i)Project Explorer|Code Explorer"){
		control:=InStr(event,"Project")?"SysTreeView321":"SysTreeView322"
		if(!top:=settings.ssn("//fonts/custom[@gui='1' and @control='" control "']"))
			top:=settings.add("fonts/custom","","",1),att(top,{gui:1,control:control})
		if(InStr(event,"style")){
			ea:=ea(top)
			if(!dlg_font(ea,1,newwin.hwnd))
				return
			for a,b in ea
				top.SetAttribute(a,b)
		}
		else if((InStr(event,"color")))
			color:=dlg_color(ssn(top,"@color").text,newwin.hwnd),top.SetAttribute("color",color)
		else if((InStr(event,"Background")))
			color:=dlg_color(ssn(top,"@background").text,newwin.hwnd),top.SetAttribute("background",color)
		return x.settimer("refreshthemes",-10),color(theme)
	}
	if(event="fold lines"||event="fold box"){
		set:=InStr(event,"lines")?"background":"color"
		if(!top:=settings.ssn("//fonts/fold"))
			top:=settings.add("fonts/fold","","",1)
		color:=dlg_color(ssn(top,"@" set).text,newwin.hwnd),top.SetAttribute(set,color)
	}
	if(event="Display Style Number At Caret")
		return m("Style=" theme.2010(theme.2008))
	if(event="Brace Match Color"){
		for a,b in ["//fonts/font[@style='34']","//fonts/font[@code='2082']"]
			if(color:=settings.ssn(b))
				goto,themeafter
		color:=settings.add("fonts/font","","",1),att(color,{code:2082})
		themeafter:
		newcolor:=dlg_color(ssn(color,"@color").text,newwin.hwnd)
		if(ErrorLevel)
			return
		color.SetAttribute("color",newcolor),highlight()
		ControlFocus,Scintilla1,% newwin.id
	}if(event="Brace Match Indicator Reset"){
		theme.2498(1,7),rem:=settings.ssn("//fonts/font[@style='34']"),rem.ParentNode.RemoveChild(rem),highlight()
	}if(event="brace match style"){
		EditStyle(34),theme.2498(0,8)
	}if(event="Themes List")
		TV_GetText(tt,TV_GetSelection()),overwrite:=preset.ssn("//name[text()='" tt "'].."),clone:=overwrite.clonenode(1),rem:=settings.ssn("//fonts"),rem.ParentNode.RemoveChild(rem),settings.ssn("*").appendchild(clone),settings.save(1),themetext(),highlight()
	if(event="Caret Width"){
		number:=InputBox(theme.sc,"Input Caret Width","Enter a number from 1 to 3",1)
		if number not between 1 and 3
			return m("Must be a number between 1 and 3")
		if(!node:=settings.ssn("//fonts/font[@code='2188']"))
			node:=settings.add("fonts/font","","",1),att(node,{code:2188})
		node.SetAttribute("value",number)
	}if(event="Compare Color"){
		style:=48,color:=settings.ssn("//fonts/font[@style='" style "']"),clr:=dlg_color(color.text,newwin.hwnd)
		if(!color:=settings.ssn("//fonts/font[@style='" style "']"))
			color:=settings.Add("fonts/font",,,1),att(color,{style:style,background:clr})
		Else
			color.SetAttribute("background",clr)
	}if(event="Edited Marker"||event="Saved Marker"){
		style:=event="Edited Marker"?30:31,color:=settings.ssn("//fonts/font[@style='" style "']"),clr:=dlg_color(color.text,newwin.hwnd)
		if(!color:=settings.ssn("//fonts/font[@style='" style "']"))
			color:=settings.Add("fonts/font",,,1),att(color,{style:style,background:clr})
		Else
			color.SetAttribute("background",clr)
	}if(event="export theme"){
		FileCreateDir,% x.path() "\Themes"
		name:=settings.ssn("//fonts/name").text,temp:=ComObjCreate("MSXML2.DOMDocument"),temp.setProperty("SelectionLanguage","XPath"),font:=settings.ssn("//fonts"),clone:=font.clonenode(1),temp.loadxml(clone.xml),temp.save(x.path() "\Themes\" name ".xml")
		m("Exported to:",x.path() "\Themes\" name ".xml")	;Opening the folder seemed unnecessary & a bit annoying
	}if(event="import theme"){
		FileSelectFile,tt,,,,*.xml
		if(ErrorLevel)
			return
		temp:=ComObjCreate("MSXML2.DOMDocument"),temp.load(tt)
		if(!(ssn(temp,"//name").xml&&ssn(temp,"//author").xml&&ssn(temp,"//fonts").xml))
			return m("Theme not compatible")
		xml:=x.get("xml"),temp:=new xml("temp"),temp.xml.load(tt),rem:=settings.ssn("//fonts"),rem.ParentNode.RemoveChild(rem),settings.ssn("*").appendchild(temp.ssn("*")),themetext(),event:="save theme",highlight()
	}if(event="Edit Author"){
		author:=settings.ssn("//fonts/author"),newauthor:=InputBox(theme.sc,"New Author","Enter your name",author.text)
		if(ErrorLevel)
			return event:=""
		author.text:=newauthor,themetext(),highlight()
	}if(event="Edit Theme Name"){
		themename:=settings.ssn("//fonts/name"),newtheme:=InputBox(theme.sc,"New Theme Name","Enter the new theme name",themename.Text)
		if(ErrorLevel)
			return event:=""
		themename.text:=newtheme,themetext(),highlight()
	}if(event="Color Input Method"){
		method:=settings.ssn("//colorinput").text?0:1,settings.add("colorinput",,method),mode:={0:"Gui",1:"Hex"}
		WinSetTitle,% x.hwnd(1),,% "Theme - Color Input Method: " mode[method]
	}if(v.themelist[TV_GetParent(A_EventInfo)]="Download Themes")
		xml:=x.get("xml"),temp:=new xml("temp"),TV_GetText(filename,A_EventInfo),info:=URLDownloadToVar("http://files.maestrith.com/AHK-Studio/themes/" filename),temp.xml.loadxml(SubStr(info,InStr(info,"<"))),rem:=settings.ssn("//fonts"),rem.ParentNode.RemoveChild(rem),settings.ssn("*").appendchild(temp.ssn("*")),themetext(),event:="save theme",highlight()
	if(event="save theme"){
		FileCreateDir,Themes
		font:=settings.ssn("//fonts"),clone:=font.clonenode(1),name:=settings.ssn("//fonts/name").text,rem:=preset.ssn("//fonts/name[text()='" name "']..")
		if(rem)
			rem.ParentNode.removechild(rem)
		Else
			v.themelist[TV_Add(name,v.themetv,"Sort")]:="themes list"
		top:=preset.ssn("*"),top.appendchild(clone),preset.save(1),tlist:=preset.sn("//preset/*"),noadd:=0
		TrayTip,AHK Studio,Theme Saved,2
	}if(event="Download Themes"){
		parent:=TV_GetSelection()
		if(child:=TV_GetChild(parent)){
			list:=[],list[child]:=1
			while,child:=TV_GetNext(child)
				list[child]:=1
			for a,b in List
				TV_Delete(a)
		}
		SplashTextOn,200,50,Downloading Themes,Please Wait...
		wb:=ComObjCreate("HTMLfile"),wb.write(URLDownloadToVar("http://files.maestrith.com/AHK-Studio/themes/"))
		while,aa:=wb.links.item[A_Index-1].innerhtml
			if(InStr(aa,".xml"))
				TV_Add(aa,parent)
		SplashTextOff,wb:=""
		TV_Modify(parent,"Expand")
	}if(event~="i)Remove Main Selection Forground|Remove Multiple Selection Forground"){
		code:=InStr(event,"multiple")?2600:2067,rem:=settings.ssn("//fonts/font[@code='" code "']"),rem.ParentNode.RemoveChild(rem),x.allctrl(code,0,0),theme[code](0,0)
	}if(event~="i)^Main Selection"){
		code:=InStr(event,"foreground")?2067:2068
		if(!main:=settings.ssn("//fonts/font[@code='" code "']"))
			main:=settings.add("fonts/font","","",1),att(main,{code:code,bool:0})
		color:=dlg_color(ssn(main,"@color").text,(newwin.hwnd))
		if(!ErrorLevel)
			main.setattribute("color",color),main.SetAttribute("bool",1)
	}if(event~="i)^Multiple Selection"){
		code:=InStr(event,"fore")?2600:2601
		if(!multi:=settings.ssn("//fonts/font[@code='" code "']"))
			multi:=settings.Add("fonts/font","","",1),att(multi,{code:code})
		color:=dlg_color(ssn(multi,"@color").text,(newwin.hwnd))
		if(!ErrorLevel)
			multi.setattribute("color",color)
	}if(event="Indent Guide"){
		if(!guide:=settings.ssn("//fonts/font[@style='37']"))
			guide:=settings.add("fonts/font"),att(guide,{style:37})
		color:=dlg_color(ssn(guide,"@color").text,newwin.hwnd)
		if(!ErrorLevel)
			guide.setattribute("color",color)
	}if(event="End Of Line Color"){
		if(!eol:=settings.ssn("//fonts/font[@style='0']"))
			eol:=settings.add("fonts/font"),att(eol,{style:0})
		color:=dlg_color(ssn(eol,"@color").text,newwin.hwnd)
		if(!ErrorLevel)
			eol.setattribute("color",color)
	}if(event="Default Font Style"){
		rem:=settings.sn("//fonts/font[@style!='5' and @font]")
		while,rr:=rem.item[A_Index-1]
			rr.removeattribute("font")
	}if(event="Caret Line Background"){
		if(!cb:=settings.ssn("//fonts/font[@code='" 2098 "']"))
			cb:=settings.add("fonts/font"),att(cb,{code:2098})
		color:=dlg_color(ssn(cb,"@color").text,newwin.hwnd)
		if(!ErrorLevel)
			cb.setattribute("color",color)
		
	}if(event="caret"){
		caret:=settings.ssn("//fonts/font[@code='2069']"),color:=dlg_color(ssn(caret,"@color").text,hwnd)
		if(!ErrorLevel)
			caret.setattribute("color",color)
	}if(event="Default Background Color"||event="Background"){
		if(InStr(event,"Default")){
			rem:=settings.sn("//fonts/font[@style!='5' and @style!=33 and @background]")
			while,rr:=rem.item[A_Index-1]
				rr.removeattribute("background")
		}if(!style:=settings.ssn("//fonts/font[@style='5']"))
			style:=settings.add("fonts/font"),att(style,{style:5})
		default:=settings.ea("//fonts/font[@style='5']")
		color:=dlg_color(default.Background,hwnd)
		if(ErrorLevel)
			return event:=""
		style.setattribute("background",color)
	}if(event="reset to default")
		rem:=settings.ssn("//fonts"),rem.parentnode.removechild(rem),defaultfont()
	return x.settimer("refreshthemes",-20),color(theme),event:=""
	returnedinfo:
	if(info.style){
		styleclick:
		if(st:=v.style.style,mod:=v.style.mod)
			if(!style:=settings.ssn("//fonts/font[@style='" st "']"))
				style:=settings.add("fonts/font","","",1),att(style,{style:st})
		color:=dlg_color(ssn(style,"@color").text,newwin.hwnd)
		if(ErrorLevel)
			return
		style.setattribute("color",color)
		return x.settimer("refreshthemes",-10),color(theme)
	}
	if(info.editfont){
		m("here")
		editfont:
		if(!style:=settings.ssn("//fonts/font[@style='" v.style.style "']"))
			style:=settings.add("fonts/font",,,1),att(style,{style:v.style.style})
		font:=ea(settings.ssn("//fonts/font[@style='" v.style.style "']")),compare:=default:=ea(settings.ssn("//fonts/font[@style='5']"))
		for a,b in font
			default[a]:=b
		dlg_font(Default,1,newwin.hwnd)
		for a,b in compare{
			if a not in style,Background
				if(default[a]!=b)
					style.setattribute(a,Default[a])
		}
		return x.settimer("refreshthemes",-10),color(theme)
	}
	if(info.editback){
		editback:
		if(!style:=settings.ssn("//fonts/font[@style='" v.style.style "']"))
			style:=settings.add("fonts/font","","",1),att(style,{style:v.style.style})
		default:=settings.ea("//fonts/font[@style='5']"),font:=settings.ea("//fonts/font[@style='" v.style.style "']"),color:=font.Background?font.Background:default.Background,color:=dlg_color(color,newwin.hwnd)
		if(ErrorLevel)
			return
		style.setattribute("background",color)
		return x.settimer("refreshthemes",-10),color(theme)
	}
	if(info.margin!=""){
		style:=settings.ssn("//fonts/font[@style='33']")
		if(info.mod=0){
			color:=ssn(style,"@color").text
			color:=dlg_color(color,newwin.hwnd)
			if(ErrorLevel)
				return
			style.setattribute("color",color)
		}
		if(info.mod=2){
			if(!style:=settings.ssn("//fonts/font[@style='33']"))
				style:=settings.add({path:"fonts/font",att:{style:33},dup:1})
			font:=ea(settings.ssn("//fonts/font[@style='33']")),compare:=default:=ea(settings.ssn("//fonts/font[@style='5']"))
			for a,b in font
				default[a]:=b
			dlg_font(Default,1,newwin.hwnd)
			for a,b in compare
				if a not in style,Background
					if(default[a]!=b)
						style.setattribute(a,Default[a])
		}
		if(info.mod=4){
			color:=ssn(style,"@background").text
			color:=dlg_color(color,newwin.hwnd)
			if(ErrorLevel)
				return
			style.setattribute("background",color)
		}
	}
	return x.settimer("refreshthemes",-10),color(theme)
	themedelete:
	Gui,3:Default
	if(v.themelist[TV_GetSelection()]="themes list"){
		TV_GetText(tt,TV_GetSelection()),rem:=preset.ssn("//name[text()='" tt "'].."),rem.ParentNode.RemoveChild(rem),TV_Delete(TV_GetSelection())
		return x.settimer("refreshthemes",-10),color(theme)
	}
}
;menu Theme
#SingleInstance,Force
global x,guikeep,settings,v:=[],theme,preset
x:=ComObjActive("AHK-Studio"),settings:=x.get("settings"),commands:=x.get("commands"),colors:=commands.sn("//Color/*"),v.color:=[],preset:=x.get("preset")
while,color:=colors.item[A_Index-1]{
	text:=color.text,all.=text " "
	stringlower,text,text
	v.color[color.nodename]:=text
}
Theme()
return
+Escape::
GuiClose:
GuiEscape:
WinGetPos,x,y,,,% hwnd([1])
if(!pos:=settings.ssn("//gui/position[@window='3']"))
	pos:=settings.add("gui/position",,,1),pos.SetAttribute("window",3)
pos.text:="x" x " y" y " w" width " h" height,preset.save(1)
ExitApp
return
m(info*){
	for a,b in info
		msg.=b "`n"
	MsgBox,,AHK Studio,%msg%
}
GuiSize:
ControlMove,SysTreeView321,,,,A_GuiHeight-15,% hwnd([1])
ControlMove,Scintilla1,,,% A_GuiWidth-330,A_GuiHeight-15,% hwnd([1])
width:=A_GuiWidth,height:=A_GuiHeight
return
Theme(info=""){
	Gui,+hwndmain +Resize
	Gui,Default
	hwnd(1,main)
	if(info)
		goto,returnedinfo
	info:=x.style()
	Gui,Font,% "c" info.color " s" info.size,% info.font
	Gui,Color,% info.Background,% info.Background
	Gui,Add,TreeView,w300 h500 hwndlv gthemetv AltSubmit
	theme:=new s(1,{pos:"x+10 w500 h500"}),pos:=settings.ssn("//gui/position[@window='3']").text,color(theme)
	Gui,Show,%pos%,Theme Editor
	Loop,80
		theme.2409(A_Index,1)
	theme.2246(0,1),theme.2400,theme.2563(0)
	v.themelist:=[],color:=TV_Add("Color")
	for a,b in ["Background","Default Background Color","Default Font Style","Caret","Caret Line Background","End Of Line Color","Reset To Default","Indent Guide","Multiple Selection Foreground","Multiple Selection Background","Main Selection Foreground","Main Selection Background","Brace Match Color","Brace Match Indicator Reset","Brace Match Style","Edited Marker","Saved Marker","Compare Color","Fold Lines","Fold Box","Project Explorer Text Style","Project Explorer Text Color","Project Explorer Background","Code Explorer Text Style","Code Explorer Text Color","Code Explorer Background","StatusBar Text Style","Remove Main Selection Forground","Remove Multiple Selection Forground","Multiple Indicator Color"]
		v.themelist[TV_Add(b,color,"Sort")]:=b
	options:=TV_Add("Theme Options")
	for a,b in ["Edit Theme Name","Edit Author","Download Themes","Export Theme","Import Theme","Save Theme","Display Style Number At Caret"]
		v.themelist[TV_Add(b,options,"Sort")]:=b
	v.themelist[TV_Add("Color Input Method")]:="Color Input Method",v.themelist[TV_Add("Caret Width")]:="Caret Width",tlist:=preset.sn("//fonts/name"),tl:=TV_Add("Themes"),v.themetv:=tl
	while,tt:=tlist.item[A_Index-1]
		v.themelist[TV_Add(tt.text,tl)]:="themes list"
	for a,b in [color,options,themes,tl]
		TV_Modify(b,"Expand")
	TV_Modify(color,"Vis"),theme.2181(0,themetext()),highlight()
	return event:=""
	themetv:
	event:=v.themelist[TV_GetSelection()]
	if(v.themetv=A_EventInfo)
		return
	if(A_GuiEvent!="normal"&&A_GuiEvent!="K")
		return
	if(InStr(event,"StatusBar")){
		if(!top:=settings.ssn("//fonts/custom[@gui='1' and @control='msctls_statusbar321']"))
			top:=settings.add("fonts/custom","","",1),att(top,{gui:1,control:"msctls_statusbar321"})
		ea:=ea(top)
		if !dlg_font(ea,1,hwnd(1))
			return
		for a,b in ea
			top.SetAttribute(a,b)
	}
	if(event="Multiple Indicator Color"){
		if(!top:=settings.ssn("//fonts/indicator[@indic='3']"))
			top:=settings.add("fonts/indicator","","",1),att(top,{indic:3})
		color:=Dlg_Color(ea(top).Background,hwnd(1)),top.SetAttribute("background",color)
	}
	if(event~="i)Project Explorer|Code Explorer"){
		control:=InStr(event,"Project")?"SysTreeView321":"SysTreeView322"
		if(!top:=settings.ssn("//fonts/custom[@gui='1' and @control='" control "']"))
			top:=settings.add("fonts/custom","","",1),att(top,{gui:1,control:control})
		if(InStr(event,"style")){
			ea:=ea(top)
			if !dlg_font(ea,1,hwnd(1))
				return
			for a,b in ea
				top.SetAttribute(a,b)
		}
		else if((InStr(event,"color")))
			color:=dlg_color(ssn(top,"@color").text,hwnd(1)),top.SetAttribute("color",color)
		else if((InStr(event,"Background")))
			color:=dlg_color(ssn(top,"@background").text,hwnd(1)),top.SetAttribute("background",color)
		return x.call("refreshthemes"),color(theme)
	}
	if(event="fold lines"||event="fold box"){
		set:=InStr(event,"lines")?"background":"color"
		if(!top:=settings.ssn("//fonts/fold"))
			top:=settings.add("fonts/fold","","",1)
		color:=dlg_color(ssn(top,"@" set).text,hwnd(1)),top.SetAttribute(set,color)
	}
	if(event="Display Style Number At Caret")
		return m("Style=" theme.2010(theme.2008))
	if(event="Brace Match Color"){
		for a,b in ["//fonts/font[@style='34']","//fonts/font[@code='2082']"]
			if color:=settings.ssn(b)
				goto,themeafter
		color:=settings.add("fonts/font","","",1),att(color,{code:2082})
		themeafter:
		newcolor:=dlg_color(ssn(color,"@color").text,hwnd(1))
		if ErrorLevel
			return
		color.SetAttribute("color",newcolor),highlight()
		ControlFocus,Scintilla1,% hwnd([1])
	}if(event="Brace Match Indicator Reset"){
		theme.2498(1,7),rem:=settings.ssn("//fonts/font[@style='34']"),rem.ParentNode.RemoveChild(rem),highlight()
	}if(event="brace match style"){
		EditStyle(34),theme.2498(0,8)
	}if(event="Themes List")
		TV_GetText(tt,TV_GetSelection()),overwrite:=preset.ssn("//name[text()='" tt "'].."),clone:=overwrite.clonenode(1),rem:=settings.ssn("//fonts"),rem.ParentNode.RemoveChild(rem),settings.ssn("*").appendchild(clone),settings.save(1),theme.2181(0,themetext()),highlight()
	if(event="Caret Width"){
		number:=InputBox(theme.sc,"Input Caret Width","Enter a number from 1 to 3",1)
		if number not between 1 and 3
			return m("Must be a number between 1 and 3")
		if(!node:=settings.ssn("//fonts/font[@code='2188']"))
			node:=settings.add("fonts/font","","",1),att(node,{code:2188})
		node.SetAttribute("value",number)
	}if(event="Compare Color"){
		style:=48,color:=settings.ssn("//fonts/font[@style='" style "']"),clr:=dlg_color(color.text,hwnd(1))
		if(!color:=settings.ssn("//fonts/font[@style='" style "']"))
			color:=settings.Add("fonts/font",,,1),att(color,{style:style,background:clr})
		Else
			color.SetAttribute("background",clr)
	}if(event="Edited Marker"||event="Saved Marker"){
		style:=event="Edited Marker"?30:31,color:=settings.ssn("//fonts/font[@style='" style "']"),clr:=dlg_color(color.text,hwnd(1))
		if(!color:=settings.ssn("//fonts/font[@style='" style "']"))
			color:=settings.Add("fonts/font",,,1),att(color,{style:style,background:clr})
		Else
			color.SetAttribute("background",clr)
	}if(event="export theme"){
		FileCreateDir,..\Themes
		name:=settings.ssn("//fonts/name").text,temp:=ComObjCreate("MSXML2.DOMDocument"),temp.setProperty("SelectionLanguage","XPath"),font:=settings.ssn("//fonts"),clone:=font.clonenode(1),temp.loadxml(clone.xml),temp.save("..\Themes\" name ".xml")
		Run,..\Themes\
	}
	if(event="import theme"){
		FileSelectFile,tt,,,,*.xml
		if ErrorLevel
			return
		temp:=ComObjCreate("MSXML2.DOMDocument"),temp.load(tt)
		if(!(ssn(temp,"//name").xml&&ssn(temp,"//author").xml&&ssn(temp,"//fonts").xml))
			return m("Theme not compatible")
		xml:=x.get("xml"),temp:=new xml("temp"),temp.xml.load(tt),rem:=settings.ssn("//fonts"),rem.ParentNode.RemoveChild(rem),settings.ssn("*").appendchild(temp.ssn("*")),theme.2181(0,themetext()),event:="save theme",highlight()
	}if(event="Edit Author"){
		author:=settings.ssn("//fonts/author"),newauthor:=InputBox(theme.sc,"New Author","Enter your name",author.text)
		if ErrorLevel
			return event:=""
		author.text:=newauthor,theme.2181(0,themetext()),highlight()
	}if(event="Edit Theme Name"){
		themename:=settings.ssn("//fonts/name"),newtheme:=InputBox(theme.sc,"New Theme Name","Enter the new theme name",themename.Text)
		if ErrorLevel
			return event:=""
		themename.text:=newtheme,theme.2181(0,themetext()),highlight()
	}if(event="Color Input Method")
		method:=settings.ssn("//colorinput").text?0:1,settings.add("colorinput",,method),mode:={0:"Gui",1:"Hex"},x.m("Your current color input mode is now set to " mode[method])
	if(v.themelist[TV_GetParent(A_EventInfo)]="Download Themes")
		xml:=x.get("xml"),temp:=new xml("temp"),TV_GetText(filename,A_EventInfo),info:=URLDownloadToVar("http://files.maestrith.com/AHK-Studio/themes/" filename),temp.xml.loadxml(SubStr(info,InStr(info,"<"))),rem:=settings.ssn("//fonts"),rem.ParentNode.RemoveChild(rem),settings.ssn("*").appendchild(temp.ssn("*")),theme.2181(0,themetext()),event:="save theme",highlight()
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
			if InStr(aa,".xml")
				TV_Add(aa,parent)
		SplashTextOff,wb:=""
		TV_Modify(parent,"Expand")
	}if(event~="i)Remove Main Selection Forground|Remove Multiple Selection Forground"){
		code:=InStr(event,"multiple")?2600:2067,rem:=settings.ssn("//fonts/font[@code='" code "']"),rem.ParentNode.RemoveChild(rem),x.allctrl(code,0,0),theme[code](0,0)
	}if(event~="i)^Main Selection"){
		code:=InStr(event,"foreground")?2067:2068
		if(!main:=settings.ssn("//fonts/font[@code='" code "']"))
			main:=settings.add("fonts/font","","",1),att(main,{code:code,bool:0})
		color:=dlg_color(ssn(main,"@color").text,(hwnd(1)))
		if !ErrorLevel
			main.setattribute("color",color),main.SetAttribute("bool",1)
	}if(event~="i)^Multiple Selection"){
		code:=InStr(event,"fore")?2600:2601
		if !multi:=settings.ssn("//fonts/font[@code='" code "']")
			multi:=settings.Add("fonts/font","","",1),att(multi,{code:code})
		color:=dlg_color(ssn(multi,"@color").text,(hwnd(1)))
		if !ErrorLevel
			multi.setattribute("color",color)
	}if(event="Indent Guide"){
		if(!guide:=settings.ssn("//fonts/font[@style='37']"))
			guide:=settings.add("fonts/font"),att(guide,{style:37})
		color:=dlg_color(ssn(guide,"@color").text,hwnd(1))
		if !ErrorLevel
			guide.setattribute("color",color)
		
	}if(event="End Of Line Color"){
		if(!eol:=settings.ssn("//fonts/font[@style='0']"))
			eol:=settings.add("fonts/font"),att(eol,{style:0})
		color:=dlg_color(ssn(eol,"@color").text,hwnd(1))
		if !ErrorLevel
			eol.setattribute("color",color)
	}if(event="Default Font Style"){
		rem:=settings.sn("//fonts/font[@style!='5' and @font]")
		while,rr:=rem.item[A_Index-1]
			rr.removeattribute("font")
	}if(event="Caret Line Background"){
		if(!cb:=settings.ssn("//fonts/font[@code='" 2098 "']"))
			cb:=settings.add("fonts/font"),att(cb,{code:2098})
		color:=dlg_color(ssn(cb,"@color").text,hwnd(1))
		if !ErrorLevel
			cb.setattribute("color",color)
		
	}if(event="caret"){
		caret:=settings.ssn("//fonts/font[@code='2069']")
		color:=dlg_color(ssn(caret,"@color").text,hwnd)
		if !ErrorLevel
			caret.setattribute("color",color)
		
	}if(event="Default Background Color"||event="Background"){
		if InStr(event,"Default"){
			rem:=settings.sn("//fonts/font[@style!='5' and @style!=33 and @background]")
			while,rr:=rem.item[A_Index-1]
				rr.removeattribute("background")
		}
		if !style:=settings.ssn("//fonts/font[@style='5']")
			style:=settings.add("fonts/font"),att(style,{style:5})
		default:=settings.ea("//fonts/font[@style='5']")
		color:=dlg_color(default.Background,hwnd)
		if ErrorLevel
			return event:=""
		style.setattribute("background",color)
		
	}if(event="reset to default"){
		rem:=settings.ssn("//fonts")
		rem.parentnode.removechild(rem)
		defaultfont()
	}
	event:=""
	return x.call("refreshthemes"),color(theme)
	returnedinfo:
	if(info.style){
		styleclick:
		st:=v.style.style,mod:=v.style.mod
		if !style:=settings.ssn("//fonts/font[@style='" st "']")
			style:=settings.add("fonts/font","","",1),att(style,{style:st})
		color:=dlg_color(ssn(style,"@color").text,hwnd(1))
		if ErrorLevel
			return
		style.setattribute("color",color)
		Loop,2
			settings.Transform()
		return x.call("refreshthemes"),color(theme)
	}
	if(info.editfont){
		editfont:
		if !style:=settings.ssn("//fonts/font[@style='" v.style.style "']")
			style:=settings.add("fonts/font",,,1),att(style,{style:v.style.style})
		font:=ea(settings.ssn("//fonts/font[@style='" v.style.style "']")),compare:=default:=ea(settings.ssn("//fonts/font[@style='5']"))
		for a,b in font
			default[a]:=b
		dlg_font(Default,1,hwnd(1))
		for a,b in compare{
			if a not in style,Background
				if(default[a]!=b)
					style.setattribute(a,Default[a])
		}
		return x.call("refreshthemes"),color(theme)
	}
	if(info.editback){
		editback:
		if !style:=settings.ssn("//fonts/font[@style='" v.style.style "']")
			style:=settings.add("fonts/font","","",1),att(style,{style:v.style.style})
		default:=settings.ea("//fonts/font[@style='5']")
		font:=settings.ea("//fonts/font[@style='" v.style.style "']")
		color:=font.Background?font.Background:default.Background
		color:=dlg_color(color,hwnd(1))
		if ErrorLevel
			return
		style.setattribute("background",color)
		return x.call("refreshthemes"),color(theme)
	}
	if(info.margin!=""){
		style:=settings.ssn("//fonts/font[@style='33']")
		if(info.mod=0){
			color:=ssn(style,"@color").text
			color:=dlg_color(color,hwnd)
			if ErrorLevel
				return
			style.setattribute("color",color)
		}
		if(info.mod=2){
			if !style:=settings.ssn("//fonts/font[@style='33']")
				style:=settings.add({path:"fonts/font",att:{style:33},dup:1})
			font:=settings.ea("//fonts/font[@style='33']"),compare:=default:=settings.ea("//fonts/font[@style='5']")
			for a,b in font
				default[a]:=b
			dlg_font(Default,1,hwnd)
			for a,b in compare{
				if a not in style,Background
					if(default[a]!=b)
						style.setattribute(a,Default[a])
			}
		}
		if(info.mod=4){
			color:=ssn(style,"@background").text
			color:=dlg_color(color,hwnd(1))
			if ErrorLevel
				return
			style.setattribute("background",color)
		}
	}
	return x.call("refreshthemes"),color(theme)
	themedelete:
	Gui,3:Default
	if(v.themelist[TV_GetSelection()]="themes list"){
		TV_GetText(tt,TV_GetSelection())
		rem:=preset.ssn("//name[text()='" tt "']..")
		rem.ParentNode.RemoveChild(rem)
		TV_Delete(TV_GetSelection())
		return x.call("refreshthemes"),color(theme)
	}
}
ssn(node,path){
	return node.SelectSingleNode(path)
}
URLDownloadToVar(url){
	http:=ComObjCreate("WinHttp.WinHttpRequest.5.1")
	if proxy:=settings.ssn("//proxy").text
		http.setProxy(2,proxy)
	http.Open("GET",url,1),http.Send()
	http.WaitForResponse
	return http.ResponseText
}
defaultfont(){
	temp:=new xml("temp")
	info=<fonts><author>joedf</author><name>PlasticCodeWrap</name><font background="0x1D160B" bold="0" color="0xF8F8F2" font="Consolas" size="10" style="5" italic="0" strikeout="0" underline="0"></font><font background="0x36342E" style="33" color="0xECEEEE"></font><font style="13" color="0x2929EF" background="0x1D160B" bold="0"></font><font style="3" color="0x39E455" bold="0"></font><font style="1" color="0xE09A1E" font="Consolas" italic="1" bold="0"></font><font style="2" color="0x833AFF" font="Consolas" italic="0" bold="0"></font><font style="4" color="0x00AAFF"></font><font style="15" background="0x272112" color="0x0080FF"></font><font style="18" color="0x00AAFF"></font><font style="19" background="0x272112" color="0x9A93EB" font="Consolas" italic="0"></font><font style="22" color="0x54B4FF"></font><font style="21" color="0x0080FF" italic="1"></font><font style="11" color="0xE09A1E" bold="0" font="Consolas" italic="1" size="10" strikeout="0" underline="0"></font><font style="17" color="0x00AAFF" italic="1"></font><font bool="1" code="2068" color="0x3D2E16"></font><font code="2069" color="0xFF8080"></font><font code="2098" color="0x583F11"></font><font style="20" color="0x0000FF" italic="1" background="0x272112"></font><font style="23" color="0x00AAFF" italic="1"></font><font style="24" color="0xFF00FF" background="0x272112"></font><font style="9" color="0x4B9AFB"></font><font style="8" color="0x00AAFF"></font><font style="10" color="0x2929EF"></font></fonts>
	top:=settings.ssn("//settings"),temp.xml.loadxml(info),temp.transform(2),tt:=temp.ssn("//*"),top.appendchild(tt)
}
hwnd(win,hwnd=""){
	static window:=[]
	if win=get
		return window
	if(win.rem){
		Gui,1:-Disabled
		if !window[win.rem]
			Gui,% win.rem ":Destroy"
		Else
			DllCall("DestroyWindow",uptr,window[win.rem])
		window[win.rem]:=""
		WinActivate,% hwnd([1])
	}
	if IsObject(win)
		return "ahk_id" window[win.1]
	if !hwnd
		return window[win]
	window[win]:=hwnd
}
Dlg_Color(Color,hwnd){
	static
	if settings.ssn("//colorinput").text{
		color:=InputBox(sc,"Color Code","Input your color code in RGB",RGB(color))
		if !InStr(color,"0x")
			color:="0x" color
		if !ErrorLevel
			return RGB(color)
		return
	}
	if !cc{
		VarSetCapacity(cccc,16*A_PtrSize,0),cc:=1,size:=VarSetCapacity(CHOOSECOLOR,9*A_PtrSize,0)
		Loop,16{
			IniRead,col,color.ini,color,%A_Index%,0
			NumPut(col,cccc,(A_Index-1)*4,"UInt")
		}
	}
	NumPut(size,CHOOSECOLOR,0,"UInt"),NumPut(hwnd,CHOOSECOLOR,A_PtrSize,"UPtr"),NumPut(Color,CHOOSECOLOR,3*A_PtrSize,"UInt"),NumPut(3,CHOOSECOLOR,5*A_PtrSize,"UInt"),NumPut(&cccc,CHOOSECOLOR,4*A_PtrSize,"UPtr")
	ret:=DllCall("comdlg32\ChooseColorW","UPtr",&CHOOSECOLOR,"UInt")
	if !ret
		exit
	Loop,16
		IniWrite,% NumGet(cccc,(A_Index-1)*4,"UInt"),color.ini,color,%A_Index%
	IniWrite,% Color:=NumGet(CHOOSECOLOR,3*A_PtrSize,"UInt"),color.ini,default,color
	return Color
}
InputBox(parent,title,prompt,default=""){
	WinGetPos,xx,y,,,ahk_id%parent%
	RegExReplace(prompt,"\n","",count),count:=count+2,height:=(sc.2279(0)*count)+(v.caption*3)+23+34
	InputBox,var,%title%,%prompt%,,,%height%,%xx%,%y%,,,%default%
	if ErrorLevel
		Exit
	return var
}
RGB(c){
	setformat,IntegerFast,H
	c:=(c&255)<<16|c&65280|c>>16 ""
	SetFormat,integerfast,D
	return c
}
att(node,items){
	for a,b in items
		node.SetAttribute(a,b)
}
highlight(){
	tt:=theme.gettext(),theme.2351((start:=StrLen(SubStr(tt,1,InStr(tt,"(")))),start-1)
}
#Include %A_ScriptDir%
Class s{
	static ctrl:=[],main:=[],temp:=[]
	__New(window,info){
		static int,count:=1
		if !init
			DllCall("LoadLibrary","str",A_ScriptDir "\..\scilexer.dll"),init:=1
		win:=window?window:1,pos:=info.pos?info.pos:"x0 y0"
		if info.hide
			pos.=" Hide"
		notify:=info.label?info.label:"notify"
		Gui,%win%:Add,custom,classScintilla hwndsc w500 h400 %pos% +1387331584 g%notify%
		this.sc:=sc,t:=[],s.ctrl[sc]:=this
		for a,b in {fn:2184,ptr:2185}
			this[a]:=DllCall("SendMessageA","UInt",sc,"int",b,int,0,int,0)
		v.focus:=sc,this.2660(1)
		for a,b in [[2563,1],[2565,1],[2614,1],[2402,15,75],[2124,1]]{
			b.2:=b.2?b.2:0,b.3:=b.3?b.3:0
			this[b.1](b.2,b.3)
		}
		return this
	}
	__Get(x*){
		return DllCall(this.fn,"Ptr",this.ptr,"UInt",x.1,int,0,int,0,"Cdecl")
	}
	__Call(code,lparam=0,wparam=0,extra=""){
		if(code="getseltext"){
			VarSetCapacity(text,this.2161),length:=this.2161(0,&text)
			return StrGet(&text,length,"UTF-8")
		}
		if(code="textrange"){
			cap:=VarSetCapacity(text,abs(lparam-wparam)),VarSetCapacity(textrange,12,0),NumPut(lparam,textrange,0),NumPut(wparam,textrange,4),NumPut(&text,textrange,8)
			this.2162(0,&textrange)
			return strget(&text,cap,"UTF-8")
		}
		if(code="getline"){
			length:=this.2350(lparam),cap:=VarSetCapacity(text,length,0),this.2153(lparam,&text)
			return StrGet(&text,length,"UTF-8")
		}
		if(code="gettext"){
			cap:=VarSetCapacity(text,vv:=this.2182),this.2182(vv,&text),t:=strget(&text,vv,"UTF-8")
			return t
		}
		if(code="getuni"){
			cap:=VarSetCapacity(text,vv:=this.2182),this.2182(vv,&text),t:=StrGet(&text,vv,"UTF-8")
			return t
		}
		wp:=(wparam+0)!=""?"Int":"AStr",lp:=(lparam+0)!=""?"Int":"AStr"
		if(wparam.1)
			wp:="AStr",wparam:=wparam.1
		wparam:=wparam=""?0:wparam,lparam:=lparam=""?0:lparam
		info:=DllCall(this.fn,"Ptr",this.ptr,"UInt",code,lp,lparam,wp,wparam,"Cdecl")
		return info
	}
	show(){
		GuiControl,+Show,% this.sc
	}
}
t(x*){
	for a,b in x
		msg.=b "`n"
	ToolTip,%msg%
}
Class XML{
	keep:=[]
	__New(param*){
		if !FileExist(A_ScriptDir "\lib")
			FileCreateDir,%A_ScriptDir%\lib
		root:=param.1,file:=param.2
		file:=file?file:root ".xml"
		temp:=ComObjCreate("MSXML2.DOMDocument"),temp.setProperty("SelectionLanguage","XPath")
		this.xml:=temp
		if FileExist(file){
			FileRead,info,%file%
			if(info=""){
				this.xml:=this.CreateElement(temp,root)
				FileDelete,%file%
			}else
				temp.loadxml(info),this.xml:=temp
		}else
			this.xml:=this.CreateElement(temp,root)
		this.file:=file
		xml.keep[root]:=this
	}
	CreateElement(doc,root){
		return doc.AppendChild(this.xml.CreateElement(root)).parentnode
	}
	search(node,find,return=""){
		found:=this.xml.SelectNodes(node "[contains(.,'" RegExReplace(find,"&","')][contains(.,'") "')]")
		while,ff:=found.item(a_index-1)
			if (ff.text=find){
				if return
					return ff.SelectSingleNode("../" return)
				return ff.SelectSingleNode("..")
			}
	}
	lang(info){
		info:=info=""?"XPath":"XSLPattern"
		this.xml.temp.setProperty("SelectionLanguage",info)
	}
	add(path,att:="",text:="",dup:=0,list:=""){
		p:="/",dup1:=this.ssn("//" path)?1:0,next:=this.ssn("//" path),last:=SubStr(path,InStr(path,"/",0,0)+1)
		if !next.xml{
			next:=this.ssn("//*")
			Loop,Parse,path,/
				last:=A_LoopField,p.="/" last,next:=this.ssn(p)?this.ssn(p):next.appendchild(this.xml.CreateElement(last))
		}
		if(dup&&dup1)
			next:=next.parentnode.appendchild(this.xml.CreateElement(last))
		for a,b in att
			next.SetAttribute(a,b)
		for a,b in StrSplit(list,",")
			next.SetAttribute(b,att[b])
		if(text!="")
			next.text:=text
		return next
	}
	find(info*){
		doc:=info.1.NodeName?info.1:this.xml
		if(info.1.NodeName)
			node:=info.2,find:=info.3
		else
			node:=info.1,find:=info.2
		if InStr(find,"'")
			return doc.SelectSingleNode(node "[.=concat('" RegExReplace(find,"'","'," Chr(34) "'" Chr(34) ",'") "')]/..")
		else
			return doc.SelectSingleNode(node "[.='" find "']/..")
	}
	under(under,node:="",att:="",text:="",list:=""){
		if(node="")
			node:=under.node,att:=under.att,list:=under.list,under:=under.under
		new:=under.appendchild(this.xml.createelement(node))
		for a,b in att
			new.SetAttribute(a,b)
		for a,b in StrSplit(list,",")
			new.SetAttribute(b,att[b])
		if text
			new.text:=text
		return new
	}
	ssn(path){
		return this.xml.SelectSingleNode(path)
	}
	sn(path){
		return this.xml.SelectNodes(path)
	}
	__Get(x=""){
		return this.xml.xml
	}
	Get(path,Default){
		return value:=this.ssn(path).text!=""?this.ssn(path).text:Default
	}
	transform(){
		static
		if !IsObject(xsl){
			xsl:=ComObjCreate("MSXML2.DOMDocument")
			style=<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">`n<xsl:output method="xml" indent="yes" encoding="UTF-8"/>`n<xsl:template match="@*|node()">`n<xsl:copy>`n<xsl:apply-templates select="@*|node()"/>`n<xsl:for-each select="@*">`n<xsl:text></xsl:text>`n</xsl:for-each>`n</xsl:copy>`n</xsl:template>`n</xsl:stylesheet>
			xsl.loadXML(style),style:=null
		}
		this.xml.transformNodeToObject(xsl,this.xml)
	}
	save(x*){
		if x.1=1
			this.Transform()
		filename:=this.file?this.file:x.1.1,encoding:=ffff.pos=3?"UTF-8":ffff.pos=2?"UTF-16":"CP0",enc:=RegExMatch(this[],"[^\x00-\x7F]")?"utf-16":"utf-8"
		if(encoding!=enc)
			FileDelete,%filename%
		file:=fileopen(filename,"rw",encoding),file.seek(0),file.write(this[]),file.length(file.position)
	}
	ea(path){
		list:=[]
		if nodes:=path.nodename
			nodes:=path.SelectNodes("@*")
		else if path.text
			nodes:=this.sn("//*[text()='" path.text "']/@*")
		else if !IsObject(path)
			nodes:=this.sn(path "/@*")
		else
			for a,b in path
				nodes:=this.sn("//*[@" a "='" b "']/@*")
		while,n:=nodes.item(A_Index-1)
			list[n.nodename]:=n.text
		return list
	}
}
sn(node,path){
	return node.SelectNodes(path)
}
Color(con){
	static options:={show_eol:2356,Show_Caret_Line:2096}
	temp:=ComObjCreate("MSXML2.DOMDocument"),temp.loadxml(settings.xml.xml),main:=ssn(temp,"//fonts"),mm:=main.clonenode(1),nodes:=mm.selectnodes("//*"),list:={Font:2056,Size:2055,Color:2051,Background:2052,Bold:2053,Italic:2054,Underline:2059}
	while,n:=nodes.item[A_Index-1]{
		ea:=ea(n)
		if(ea.code=2082){
			con.2082(7,ea.color)
			Continue
		}
		if(ea.style=33)
			for a,b in [2290,2291]
				con[b](1,ea.Background)
		ea.style:=ea.style=5?32:ea.style
		for a,b in ea{
			if list[a]&&ea.style!=""
				con[list[a]](ea.style,b)
			if(ea.code&&ea.value)
				con[ea.code](ea.value)
			else if ea.code&&ea.bool!=1
				con[ea.code](ea.color,0)
			else if ea.code&&ea.bool
				con[ea.code](ea.bool,ea.color)
			if (ea.style=32)
				con.2050(),con.2052(30,0x0000ff),con.2052(31,0x00ff00),con.2052(48,0xff00ff)
		}
	}
	for a,b in [[2040,25,13],[2040,26,15],[2040,27,11],[2040,28,10],[2040,29,9],[2040,30,12],[2040,31,14],[2242,0,20],[2242,1,13],[2134,1],[2260,1],[2246,1,1],[2246,2,1],[2115,1],[2029,2],[2031,2],[2244,3,0xFE000000],[2080,7,6],[2240,3,0],[2242,3,15],[2244,3,0xFE000000],[2246,1,1],[2246,3,1],[2244,2,3],[2040,0,0],[2040,1,2],[2041,0,0],[2042,0,0xff],[2115,1],[2056,38,"Tahoma"],[2077,0,"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ#_1234567890"],[2041,1,0],[4006,0,"ahk"],[2042,1,0xff0000],[2040,2,22],[2042,2,0x444444],[2040,3,22],[2042,3,0x666666],[2040,4,31],[2042,4,0xff0000],[2037,65001],[2132,v.options.Hide_Indentation_Guides=1?0:1]]
		con[b.1](b.2,b.3)
	if(!v.options.Disable_Word_Wrap_Indicators)
		con.2460(4)
	con.2472(2),con.2036(width:=settings.ssn("//tab").text?settings.ssn("//tab").text:5),con.2080(3,6),con.2082(3,0xFFFFFF)
	if !settings.ssn("//fonts/font[@code='2082']")
		con.2082(7,0xff00ff)
	if !(settings.ssn("//fonts/font[@style='34']"))
		con.2498(1,7)
	con.2212(),con.2371,indic:=settings.sn("//fonts/indicator")
	while,in:=indic.item[A_Index-1],ea:=xml.ea(in)
		for a,b in ea
			if(ea.Background!="")
				con.2082(ea.indic,ea.Background)
	con.2080(2,8),con.2082(2,0xff00ff),con.2636(1)
	if zoom:=settings.ssn("//gui/@zoom").text
		con.2373(zoom)
	for a,b in options
		if v.options[a]
			con[b](b)
	kwind:={Personal:0,indent:1,Directives:2,Commands:3,builtin:4,keywords:5,functions:6,flow:7,KeyNames:8}
	for a,b in v.color
		con.4005(kwind[a],RegExReplace(b,"#"))
	if(node:=settings.ssn("//fonts/fold")){
		ea:=xml.ea(node)
		Loop,7
			con.2041(24+A_Index,ea.color!=""?ea.color:"0"),con.2042(24+A_Index,ea.background!=""?ea.Background:"0xaaaaaa")
	}
}
ea(path){
	list:=[],nodes:=path.SelectNodes("@*")
	while,n:=nodes.item(A_Index-1)
		list[n.nodename]:=n.text
	return list
}
Dlg_Font(ByRef Style,Effects=1,window=""){
	VarSetCapacity(LOGFONT,60),strput(style.font,&logfont+28,32,"CP0"),LogPixels:=DllCall("GetDeviceCaps","uint",DllCall("GetDC","uint",0),"uint",90),Effects:=0x041+(Effects?0x100:0)
	for a,b in font:={16:"bold",20:"italic",21:"underline",22:"strikeout"}
		if style[b]
			NumPut(b="bold"?700:1,logfont,a)
	style.size?NumPut(Floor(style.size*logpixels/72),logfont,0):NumPut(16,LOGFONT,0),VarSetCapacity(CHOOSEFONT,60,0),NumPut(60,CHOOSEFONT,0),NumPut(&LOGFONT,CHOOSEFONT,12),NumPut(Effects,CHOOSEFONT,20),NumPut(style.color,CHOOSEFONT,24),NumPut(window,CHOOSEFONT,4)
	if !r:=DllCall("comdlg32\ChooseFontA","uint",&CHOOSEFONT)
		return
	Color:=NumGet(CHOOSEFONT,24),bold:=NumGet(LOGFONT,16)>=700?1:0,style:={size:NumGet(CHOOSEFONT,16)//10,font:StrGet(&logfont+28,"CP0"),color:color}
	for a,b in font
		style[b]:=NumGet(LOGFONT,a,"UChar")?1:0
	style["bold"]:=bold
	return 1
}
EditStyle(stylenumber){
	if !style:=settings.ssn("//fonts/font[@style='" stylenumber "']")
		style:=settings.add("fonts/font","","",1),att(style,{style:stylenumber})
	ea:=ea(style)
	def:=settings.ssn("//fonts/font[@style='5']")
	def:=ea(def)
	for a,b in ea
		def[a]:=b
	dlg_font(def,1,hwnd(1))
	for a,b in def
		style.SetAttribute(a,b)
}
Notify(){
	fn:=[],info:=A_EventInfo,code:=NumGet(info+(A_PtrSize*2))
	if code not in 2001,2002,2004,2006,2007,2008,2010,2014,2018,2019,2021,2022,2027
		return 0
	for a,b in {0:"Obj",2:"Code",3:"position",4:"ch",5:"mod",6:"modType",7:"text",8:"length",9:"linesadded",10:"msg",11:"wparam",12:"lparam",13:"line",14:"fold",17:"listType",22:"updated"}
		fn[b]:=NumGet(Info+(A_PtrSize*a))
	if(fn.code=2027){
		v.style:={style:theme.2010(fn.position),mod:fn.mod}
		if(GetKeyState("Control","P")=0&&GetKeyState("Alt","P")=0)
			SetTimer,styleclick,-1
		if(GetKeyState("Control","P"))
			SetTimer,editfont,-1
		if(GetKeyState("Alt","P"))
			SetTimer,editback,-1
	}
}
ThemeText(tt:=1){
	if name:=settings.ssn("//fonts/name").text
		header:=name "`r`n`r`n"
	if author:=settings.ssn("//fonts/author").text
		header.="Theme by " author "`r`n`r`n"
	out=%header%/*`r`n`tMulti-Line`r`n`tcomments`r`n*/`r`n`r`nMatching Brace Highlight Sample()`r`n`r`nSelect the text to change the colors`nThis is a sample of normal text`n`"incomplete quote`n"complete quote"`n`;comment`n0123456789`n[]^&*()+~#\/!`,{`}``b``a``c``k``t``i``c``k`n
	out.="`nLabel: `;Label Color`nHotkey:: `;Hotkey Color`nFunction() `;Function/Method Color`nabs() `;Built-In Functions`n`n"
	out.="`%variable`% `%variable error`n`n"
	for a,b in v.color
		out.=a " = " b "`n"
	th:=tt=1?settings.sn("//custom/highlight/*"):tt
	while,tt:=th.item(A_Index-1)
		out.="Custom List " ssn(tt,"@list").text " = " tt.text "`n"
	out.="`nLeft Click to edit the fonts color`nControl+Click to edit the font style, size, italic...etc`nAlt+Click to change the Background color`nThis works for the Line Numbers as well"
	return out
}
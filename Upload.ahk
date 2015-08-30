;menu Upload
;#NoTrayIcon
#SingleInstance,Force
#Include <Studio>
clipboard:=""
global settings,vversion,node,newwin,v
x:=ComObjActive("AHK-Studio"),v:=x.get("v"),vversion:=x.get("vversion"),settings:=x.get("settings"),ControlList:={compile:"Button1",dir:"Edit2",upver:"Button3",versstyle:"Button4",upgithub:"Button5"}
newwin:=new GUIKeep("Upload",x),newwin.add("Text,,&Versions:","TreeView,w360 h120 gtv AltSubmit,,w","Text,,Version &Information:","Edit,w360 h200 gedit vedit,,wh","Text,,Directory:,y","Edit,x+2 w200 vdir,,yw","Text,section xm,&FTP Server:,y","DDL,x+10 ys w200 vserver," lst ",yw","Checkbox,vcompile xm,Co&mpile,y","Checkbox,vgistversion xm Disabled,Update Gist Version,y","Checkbox,vupver,Upload &without progress bar (a bit more stable),y","Checkbox,vversstyle,&Remove (Version=) from the " chr(59) "auto_version,y","Checkbox,vupgithub,Update &GitHub,y","Button,w200 gupload xm Default,&Upload,y","Button,x+5 gverhelp -TabStop,&Help,y"),newwin.show("Upload")
node:=node()
for a,b in ControlList
	GuiControl,upload:,%b%,% ssn(node,"@" a).text
list:=settings.sn("//ftp/server/@name"),lst:="Choose a server...|"
while,ll:=list.item[A_Index-1]
	lst.="|" ll.text
if list.length=1
	lst:=list.item[0].text "||"
GuiControl,Upload:,ComboBox1,%lst%
GuiControl,Upload:ChooseString,ComboBox1,% node.selectsinglenode("@server").text
Hotkey,IfWinActive,% newwin.id
for a,b in {"^Down":"Arrows","^Up":"Arrows","~RButton":"RButton","~Delete":"Delete","F1":"compilever","F2":"clearver","F3":"wholelist"}
	Hotkey,%a%,%b%,On
PopVer()
ControlFocus,Edit1,% newwin.id
return
upload(){
	global x
	info:=newwin[]
	ftp:=x.get("ftp"),f:=new ftp(info.server)
	if(f.Error)
		return
	r:=f.put(ssn(node(),"@file").text,info.dir,info.compile)
	if(r)
		m("Transfer complete")
	return
}
tv(){
	if(A_GuiEvent="S"){
		default(),cn:=ssn(node(),"descendant::version[@tv='" TV_GetSelection() "']")
		GuiControl,upload:,Edit1,% cn.text
	}
}
edit(){
	default(),info:=newwin[],cn:=ssn(node(),"descendant::version[@tv='" TV_GetSelection() "']"),cn.text:=info.edit
}
delete(){
	ControlGetFocus,Focus,% newwin.id
	if(Focus="SysTreeView321")
		default(),cn:=ssn(node(),"descendant::version[@tv='" TV_GetSelection() "']"),cn.ParentNode.RemoveChild(cn),PopVer()
}
RButton(){
	MouseGetPos,,,whwnd,control
	if(whwnd!=newwin.hwnd&&control!="SysTreeView321")
		return
	default(),cn:=ssn(node(),"descendant::version[@tv='" TV_GetSelection() "']")
	InputBox,nv,Enter a new version number,New Version Number,,,,,,,,% ssn(cn,"@number").text
	if(ErrorLevel||nv="")
		return
	cn.SetAttribute("number",nv),PopVer()
}
node(){
	global x
	if(!node:=vversion.ssn("//info[@file='" x.call("current","2").file "']"))
		node:=vversion.under(vversion.ssn("//*"),"info"),node.SetAttribute("file",x.call("current","2").file),top:=vversion.under(node,"versions"),next:=vversion.under(top,"version"),next.SetAttribute("number",1)
	return node
}
default(){
	Gui,upload:Default
}
PopVer(){
	GuiControl,upload:-Redraw,SysTreeView321
	all:=sn(node(),"descendant::version"),TV_Delete()
	while,aa:=all.item[A_Index-1]
		aa.SetAttribute("tv",TV_Add(ssn(aa,"@number").text))
	TV_Modify(TV_GetChild(0),"Select Vis Focus")
	GuiControl,upload:+Redraw,SysTreeView321
}
Arrows(){
	default(),TV_GetText(vers,TV_GetSelection()),ver:=StrSplit(vers,"."),version:=""
	for a,b in ver{
		if(a<ver.MaxIndex())
			version.=b "."
		else{
			add:=InStr(A_ThisHotkey,"up")?1:-1
			if(b+add>0)
				version.=b+add
			else{
				if(select:=ssn(node(),"descendant::version[@number='" version "0']/@tv").text)
					TV_Modify(select,"Select Vis Focus")
				return
			}
		}
	}
	select:=ssn(add(version),"@tv").text
	if(select)
		TV_Modify(select,"Select Vis Focus")
	else
		TV_Modify(TV_GetChild(0),"Select Vis Focus")
	ControlFocus,Edit1,% newwin.id
}
Add(vers){
	if(nn:=ssn(node:=node(),"descendant::version[@number='" vers "']"))
		return nn
	list:=sn(node,"versions/version"),root:=ssn(node,"versions"),newnode:=vversion.under(root,"version"),newnode.SetAttribute("number",vers)
	while,ll:=list.item[A_Index-1],ea:=xml.ea(ll){
		if(vers>ea.number){
			root.insertbefore(newnode,ll),PopVer()
			Break
		}
	}
	return node
}
verhelp(){
	m("Right Click to change a version number`nCtrl+Up/Down to increment versions`nF1 to build a version list (will be copied to your Clipboard)`nF2 to clear the list`nF3 to copy your entire list to the Clipboard`nPress Delete to remove a version")
}
compilever:
default(),TV_GetText(ver,TV_GetSelection())
WinGetPos,,,w,,% newwin.id
nn:=ssn(node(),"descendant::*[@number='" ver "']"),number:=settings.ea(nn).number,text:=nn.text,vertext:=number&&text?number "`r`n" text:""
if(vertext){
	Clipboard.=vertext "`r`n"
	ToolTip,%Clipboard%,%w%,0,2
}else
	m("Add some text")
return
clearver:
clipboard:=""
ToolTip,,,,2
return
wholelist:
list:=sn(node,"versions/version")
Clipboard:=""
while,ll:=list.item[A_Index-1]
	Clipboard.=ssn(ll,"@number").text "`r`n" Trim(ll.text,"`r`n") "`r`n"
m("Version list copied to your clipboard.","","",Clipboard)
return
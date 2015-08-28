#NoTrayIcon
#SingleInstance,Force
#Include lib\Studio.ahk
global settings,vversion,node
x:=ComObjActive("AHK-Studio"),settings:=x.get("settings"),ControlList:={compile:"Button1",dir:"Edit2",upver:"Button3",versstyle:"Button4",upgithub:"Button5"},newwin:=new GUIKeep("Upload",x)
newwin.add("Text,,&Versions:","TreeView,w360 h120,,w","Text,,Version &Information:","Edit,w360 h200,,wh","Text,section xm,&FTP Server:,y","DDL,x+10 ys w200 vserver," lst ",yw","Checkbox,vcompile xm,Co&mpile,y","Checkbox,vgistversion xm Disabled,Update Gist Version,y","Checkbox,vupver,Upload &without progress bar (a bit more stable),y","Checkbox,vversstyle,&Remove (Version=) from the " chr(59) "auto_version,y","Checkbox,vupgithub,Update &GitHub,y","Button,w200 gupload1 xm Default,&Upload,y","Button,x+5 gverhelp -TabStop,&Help,y"),newwin.show("Upload")
vversion:=x.get("vversion"),node:=node(),set:=node.SelectNodes("@*")
while,ss:=set.item[A_Index-1]
	if(ControlList[ss.nodename])
		GuiControl,Upload:,% ControlList[ss.nodename],% ss.text
list:=settings.sn("//ftp/server/@name"),lst:="Choose a server...|"
while,ll:=list.item[A_Index-1]
	lst.="|" ll.text
if list.length=1
	lst:=list.item[0].text "||"
GuiControl,Upload:,ComboBox1,%lst%
GuiControl,Upload:ChooseString,ComboBox1,% node.selectsinglenode("@server").text
Hotkey,IfWinActive,% newwin.ahkid
Hotkey,up,up,On
popver()
ControlFocus,Edit1,% newwin.ahkid
return
/*
	focusvers:
	ControlFocus,SysTreeView321,A
	return
*/
node(){
	global x
	return node:=vversion.ssn("//info[@file='" x.call("current","2").file "']")
}
popver(){
	all:=sn(node,"descendant::version/@number"),TV_Delete()
	while,aa:=all.item[A_Index-1]
		TV_Add(aa.text)
	TV_Modify(TV_GetChild(0),"Select Vis Focus")
}
up:
/*
	Add(vers){
		;node:=this.node
		if(nn:=ssn(node,"descendant::version[@number='" vers "']"))
			return nn
		list:=sn(node,"versions/version")
		root:=ssn(node,"versions"),node:=vversion.under(root,"version",{number:vers})
		while,ll:=list.item[A_Index-1],ea:=xml.ea(ll){
			if(vers>ea.number){
				root.insertbefore(node,ll)
				Break
			}
		}
		return node
	}
*/
return
verhelp:
m("Ctrl+Up/Down to add/change versions`nRight Click to change a version number`nF1 to build a version list (will be copied to your Clipboard)`nF2 to clear the list`nF3 to copy your entire list to the Clipboard")
return
/*
	uploadescape:
	m("here escape :)")
	ExitApp
	return
*/
upload1:
info:=newwin[]
for a,b in info
	if(b)
		m(a,b)
return

/*
	upload()
	Upload(winname="Upload"){
		static
		static ControlList:={compile:"Button1",dir:"Edit2",upver:"Button3",versstyle:"Button4",upgithub:"Button5"}
		uphwnd:=setup(10),lastver:="",compilever:="",list:=settings.sn("//ftp/server/@name"),lst:="Choose a server...|"
		while,ll:=list.item[A_Index-1]
			lst.="|" ll.text
		if list.length=1
			lst:=list.item[0].text "||"
		{
			newwin:=new GUIKeep(10)
			
			vers:=new versionkeep(newwin)
			node:=vers.node
			newwin.add("Text,xm Section,Upload directory:,y","Edit,vdir w100 x+10 ys-2,,yw,1","Text,section xm,FTP Server:,y","DDL,x+10 ys-2w0150 vserver," lst ",yw","Checkbox,vcompile xm,Compile,y","Checkbox,vgistversion xm Disabled,Update Gist Version,y","Checkbox,vupver,Upload without progress bar (a bit more stable),y","Checkbox,vversstyle,&Remove (Version=) from the " chr(59) "auto_version,y","Checkbox,vupgithub,Update GitHub,y","Button,w200 gupload1 xm Default,&Upload,y","Button,x+5 gverhelp -TabStop,Help,y")
			file:=ssn(current(1),"@file").text
			newwin.Show("Upload")
			info:=""
			node:=vversion.ssn("//info[@file='" file "']")
		}
		for a,b in vversion.ea(node)
			GuiControl,10:,% ControlList[a],%b%
		GuiControl,10:ChooseString,ComboBox1,% ssn(node,"@server").text
		vers.populate(),TV_Modify(tv_getnext(0),"Select Vis Focus")
		ControlFocus,Edit1,% hwnd([10])
		return
		upload1:
		info:=newwin[],node:=vversion.ssn("//info[@file='" file "']"),node.SetAttribute("versstyle",info.versstyle)
		if(info.server="Choose a server..."||info.server="")
			return m("Please choose a server")
		if(info.compile)
			compile()
		f:=new ftp(info.server)
		if(f.Error)
			return
		r:=f.put(file,info.dir,info.compile)
		if(r)
			m("Transfer complete")
		return
		10GuiEscape:
		10GuiClose:
		ToolTip,,,,2
		node:=vversion.ssn("//info[@file='" file "']")
		for a,b in newwin[]
			node.SetAttribute(a,b)
		ftp.cleanup(),hwnd({rem:10})
		return
		compilever:
		Gui,10:Default
		TV_GetText(ver,TV_GetSelection())
		WinGetPos,x,y,w,h,% hwnd([10])
		vertext:=vers.getver(ver)
		if(vertext)
			vertext:=ver "`r`n" Trim(vertext,"`r`n") "`r`n"
		else if(!vertext)
			m("Please select a version number to build a version list")
		if(!compilever)
			clipboard:=vertext,compilever:=1
		else
			Clipboard.=vertext
		ToolTip,%Clipboard%,%w%,0,2
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
	}
*/
#SingleInstance,Force
;menu Menu Help
x:=Studio()
help:=new XML("help","lib\Help Menu.xml"),current:=new XML("current"),current.xml.loadxml(x.get("menus"))
if(!FileExist("lib\Menu Help.xml"))
	gosub,updatehelp
hw:=new GUIKeep("Menu_Help"),hw.add("TreeView,w300 h400 AltSubmit gmhtv,,h","Edit,x+M w300 h400,,wh","Button,xm gupdatehelp1,Update,y"),hw.show("Menu Help")
all:=current.sn("//main/descendant::*")
gosub,populate
return
populate:
TV_Delete()
while,aa:=all.item[A_Index-1],ea:=xml.ea(aa)
	if(aa.nodename!="separator"&&ea.no!=1)
		aa.SetAttribute("tv",TV_Add(ea.clean,ssn(aa.ParentNode,"@tv").text))
return
updatehelp1:
updatehelp:
if(!FileExist("lib\Help Menu.xml"))
	UrlDownloadToFile,https://raw.githubusercontent.com/maestrith/AHK-Studio/master/lib/Help Menu.xml,lib\Help Menu.xml
if(A_ThisLabel="updatehelp1")
	gosub,populate
return
mhtv:
TV_GetText(item,TV_GetSelection())
node:=help.ssn("//*[@clean='" item "']")
if(!TV_GetChild(TV_GetSelection()))
	ControlSetText,Edit1,% node.text,% hw.id
else
	ControlSetText,Edit1,%item%,% hw.id	
return
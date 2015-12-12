#SingleInstance,Force
;menu Menu Help
x:=Studio()
if(!FileExist("lib\Help Menu.xml"))
	UrlDownloadToFile,https://raw.githubusercontent.com/maestrith/AHK-Studio/master/lib/Help Menu.xml,lib\Help Menu.xml
help:=new XML("help","lib\Help Menu.xml"),current:=new XML("current"),current.xml.loadxml(x.get("menus"))
hw:=new GUIKeep("Menu_Help"),hw.add("TreeView,w300 h400 AltSubmit gmhtv,,h","Edit,x+M w300 h400,,wh"),hw.show("Menu Help")
all:=current.sn("//main/descendant::*")
while,aa:=all.item[A_Index-1],ea:=xml.ea(aa){
	if(aa.nodename!="separator"&&ea.no!=1)
		aa.SetAttribute("tv",TV_Add(ea.clean,ssn(aa.ParentNode,"@tv").text))
}
return
mhtv:
TV_GetText(item,TV_GetSelection())
node:=help.ssn("//*[@clean='" item "']")
if(!TV_GetChild(TV_GetSelection()))
	ControlSetText,Edit1,% node.text,% hw.id
else
	ControlSetText,Edit1,%item%,% hw.id	
return
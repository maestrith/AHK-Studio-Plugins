#SingleInstance,Force
;menu Ftp Servers
x:=Studio()
NewWin:=new GUIKeep(9),NewWin.Add("ListView,w300 h300 hwndlistview -Multi gpopserver AltSubmit,Server|Username|Password|Port,wh") 
for a,b in ["Server","Username","Password","Port"]
	password:=b="password"?"password":"",NewWin.Add("Text,xm," b ":,y"),NewWin.Add("Edit,x+2 w220 v" b " " Password ",,yw")
NewWin.Add("Button,xm gnewserver Default,&New/Update Server,y","Button,x+2 gdeleteserver,&Delete Server,y")
popftp(),NewWin.Show("FTP Server Settings")
LV_Modify(1,"Select Vis Focus")
return
popserver:
if(A_GuiEvent="i"){
	LV_GetText(address,LV_GetNext()),ea:=settings.ea("//ftp/server[@address='" address "']")
	for a,b in [ea.address,ea.username,ea.password,ea.port]
		GuiControl,,Edit%a%,%b%
}
return
newserver:
info:=NewWin[]
if(!exist:=settings.ssn("//ftp/server[@address='" info.server "']"))
	exist:=settings.add("ftp/server",,,1)
for a,b in {address:info.server,name:info.server,password:info.password,port:info.port,username:info.username}
	exist.SetAttribute(a,b)
popftp()
return
deleteserver:
if(!next:=LV_GetNext())
	return
LV_GetText(server,next),server:=settings.ssn("//ftp/server[@name='" server "']"),server.parentnode.removechild(server),popftp()
return
PopFTP(){	
	servers:=settings.sn("//ftp/*"),LV_Delete()
	while,ss:=servers.item[A_Index-1]{
		ea:=settings.ea(ss)
		LV_Add("",ea.address,ea.username,RegExReplace(ea.password,".","*"),ea.port)
	}
	Loop,4
		LV_ModifyCol(A_Index,"AutoHDR")
	LV_Modify(1,"Select Vis Focus")
}
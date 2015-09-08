#SingleInstance,Force
global ib,rebar,toolbar
x:=Studio(),newwin:=new GUIKeep(34),newwin.add("ListView,w100 h200 gmtshow AltSubmit Checked -Multi,Show","ListView,x+0 w200 h200,Toolbar,w","Button,xm w300 gmtat,&Add Toolbar,w","Button,w300 gmtdel,&Delete/Hide Toolbar,w","ListView,w300 r10,Menu Items,wh","Button,w300 gmtmenu,Add Selected &Command,yw","Button,w300 gmtrun,&Run External File...,yw"),v:=x.get("v"),menus:=new xml("menus",x.path() "\lib\menus.xml"),menu:=menus.sn("//*"),rebar:=x.get("rebar"),toolbar:=x.get("toolbar"),icon_browser:=x.get("icon_browser")
while,mm:=menu.item[A_Index-1]{
	mname:=clean(ssn(mm,"@name").text)
	if(mname&&InStr(mname,"---")=0&&v.available[mname])
		LV_Add("Sort",mname)
}
gosub,mtpop
newwin.show("Manage Toolbars"),LV_Modify(1,"Select Vis Focus"),LV_ModifyCol(1,"AutoHDR")
return
mtshow(){
	global settings
	Gui,34:Default
	Gui,34:ListView,SysListView321
	if(ErrorLevel="c")
		LV_GetText(id,LV_GetNext()),value:=settings.ssn("//rebar/band[@id='" id "']"),value.SetAttribute("vis",ErrorLevel=="C"?1:0),temp:=rebar.hw.1,temp[ErrorLevel=="C"?"Show":"Hide"](id)
	else if(A_GuiEvent="I")
		RB()
}
RB(){
	Gui,34:Default
	Gui,34:ListView,SysListView32
	LV_GetText(id,LV_GetNext()),list:=settings.sn("//toolbar/bar[@id='" id "']/*"),nl:=[]
	Gui,34:ListView,SysListView322
	GuiControl,34:-Redraw,SysListView322
	while,ll:=list.item[A_Index-1],ea:=xml.ea(ll)
		nl.push(ea.text)
	LV_Delete()
	for a,b in nl
		LV_Add("",b)
	GuiControl,34:+Redraw,SysListView322
}
mtat(){
	global newid
	id:=10000
	while,settings.ssn("//rebar/band[@id='" ++id "']"){
	}
	new:=settings.add("toolbar/bar","","",1),att(new,{id:id}),newband:=settings.add("rebar/band","","",1),att(newband,{id:id,vis:1,width:200}),tb:=new toolbar(1,x.hwnd(1),id),rebar.hw.1.add(newband,1)
	SetTimer,mtpop,-1
	newid:=id
	return
}
mtdel(){
	global
	if(!LV_GetNext())
		return
	LV_GetText(id,next:=LV_GetNext())
	if(id>=10000&&id<=10002)
		return settings.ssn("//rebar/band[@id='" id "']").SetAttribute("vis",0),rebar.hw.1.hide(id),LV_Modify(next,"-Check")
	MsgBox,52,Are you sure?,This will completely delete this toolbar`nThis can not be undone!`nAre you sure?
	IfMsgBox,No
		return
	rebar.hw.1.hide(id)
	for a,b in [settings.ssn("//rebar/band[@id='" id "']"),settings.ssn("//toolbar/bar[@id='" id "']")]
		if b.xml
			b.ParentNode.RemoveChild(b)
	rebar.hw.1.delete(id),LV_Delete(next),LV_Modify(next-1>0?next-1:1,"Select Vis Focus")
	return
}
mtrun:
mtmenu(1)
return
mtmenu(run){
	global
	Gui,34:Default
	Gui,34:ListView,SysListView321
	if(!LV_GetNext())
		return m("Please select a toolbar in the list above")
	LV_GetText(barid,LV_GetNext())
	if(barid=10002)
		return m("Sorry, but you can not add to this toolbar")
	Gui,34:Default
	Gui,34:ListView,SysListView323
	newid:=11099,bar:=toolbar.list[barid]
	while,settings.ssn("//toolbar/bar[@id='" barid "']/button[@id='" ++newid "']"){
	}
	under:=settings.ssn("//toolbar/bar[@id='" barid "']")
	if(run=1){
		FileSelectFile,filename
		if ErrorLevel
			return
		SplitPath,filename,,,,nne
		iconfile:=InStr(filename,".ahk")?A_AhkPath:filename,att:={vis:1,icon:0,file:iconfile,text:nne,func:"runfile",id:newid,state:4,runfile:filename},bar.add(att),bar.addbutton(newid),new:=settings.under(under,"button"),att(new,att),new icon_browser(newid,barid,"flan","shell32.dll","4","",newwin.hwnd)
	}else
		LV_GetText(item,LV_GetNext()),text:=RegExReplace(item,"_"," "),att:={vis:1,icon:1,file:"shell32.dll",text:text,func:item,id:newid,state:4},bar.add(att),bar.addbutton(newid),new:=settings.under(under,"button"),att(new,att),new icon_browser(newid,barid,"Description","shell32.dll",1,"",newwin.hwnd)
	return RB()
}
clean(clean,tab=""){
	if tab
		return RegExReplace(clean,"[^\w ]")
	clean:=RegExReplace(RegExReplace(clean,"&")," ","_")
	if InStr(clean,"`t")
		clean:=SubStr(clean,1,InStr(clean,"`t")-1)
	return clean
}
mtpop:
Gui,34:Default
Gui,34:ListView,SysListView321
GuiControl,34:-Redraw,SysListView321
rb:=settings.sn("//rebar/descendant::*"),LV_Delete(),ids:=[]
while,rr:=rb.item[A_Index-1],rea:=xml.ea(rr)
	if(tb:=settings.ssn("//toolbar/bar[@id='" rea.id "']"))
		ids[rea.id]:=LV_Add(_:=rea.vis?"Check":"",rea.id)
GuiControl,34:+Redraw,SysListView321
if(newid){
	LV_Modify(ids[newid],"Select Vis Focus")
	Gui,34:Default
	Gui,34:ListView,SysListView323
	ControlFocus,SysListView323,% newwin.id
	if(!LV_GetNext())
		LV_Modify(1,"Select Vis Focus")
}
return
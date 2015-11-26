#SingleInstance,Force
#Include <Studio>
;menu Auto Insert
global newwin,settings,wname
wname:="Auto_Insert",x:=ComObjActive("AHK-Studio"),settings:=x.get("settings"),newwin:=new GUIKeep(wname),newwin.Add("ListView,w220 h200 AltSubmit gchange,Entered Key|Added Key,wh","Text,,Entered Key:,y","Edit,venter x+10 w100,,yw","Text,xm,Added Key:,y","Edit,vadd x+10 w100 Limit1,,yw","Button,xm gaddkey Default,Add Keys,y","Button,x+10 gremkey,&Remove Selected,y"),newwin.Show("Auto Insert"),PopAI()
return
Auto_InsertClose(){
	Auto_InsertEscape:
	global x
	x.SetTimer("BraceSetup",-10)
	WinClose,% newwin.id
	ExitApp
}
return
change:
if(A_GuiEvent!="I")
	return
LV_GetText(enter,LV_GetNext()),ff:=settings.find("//autoadd/key/@trigger",enter),ea:=ea(ff)
for a,b in [ea.trigger,ea.add]
	ControlSetText,Edit%A_Index%,%b%,% newwin.id
return
addkey:
value:=newwin[],enter:=value.enter,add:=value.add
if(!(enter&&add)){
	m("Both values need to be filled in")
	return
}
if(ff:=settings.find("//autoadd/key/@trigger",enter))
	ff.SetAttribute("add",add)
else
	if(!settings.ssn("//autoadd/key[@trigger='" enter "']"))
		new:=settings.add("autoadd/key",,,1),att(new,{trigger:enter,add:add})
PopAI()
Loop,2
	ControlSetText,Edit%A_Index%,,% newwin.id
ControlFocus,Edit1,% newwin.id
x.SetTimer("BraceSetup",-10)
return
remkey:
while,LV_GetNext()
	LV_GetText(trigger,LV_GetNext()),rem:=settings.find("//autoadd/key/@trigger",trigger),rem.ParentNode.RemoveChild(rem),LV_Delete(LV_GetNext())
return
PopAI(){
	GuiControl,%wname%:-Redraw,SysListView321
	LV_Delete(),autoadd:=settings.sn("//autoadd/*")
	while,aa:=autoadd.item(a_index-1),ea:=ea(aa)
		LV_Add("",ea.trigger,ea.add)
	GuiControl,%wname%:+Redraw,SysListView321
}
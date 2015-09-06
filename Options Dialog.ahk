#SingleInstance,Force
;menu Options Dialog
x:=Studio(),settings:=x.get("settings"),newwin:=new GUIKeep("Options"),newwin.add("TreeView,w400 h500 Checked AltSubmit,,wh"),options:=x.call("options",1)
for a,b in {main:main,next:next,bit:bit}
	all.=options[a] ","
all:=Trim(all,","),tv:=[]
for a,b in StrSplit(all,",")
	tv[TV_Add(RegExReplace(b,"_"," "),0,settings.ssn("//*/@" b).text?"Check":"")]:=b
newwin.show("Options")
GuiControl,Options:+gtv,SysTreeView321
return
tv:
if(A_GuiEvent~="Normal|K"){
	ie:=A_GuiEvent="normal"?A_EventInfo:TV_GetSelection()
	value:=(TV_Get(ie,"C")?1:0)
	option:=settings.ssn("//*/@" tv[ie]).text?1:0
	if(option!=value){
		x.settimer(tv[ie],"-10")
	}
}
;menu Split Line By Comma
#Persistent
#SingleInstance,Force
x:=Studio(),sc:=x.sc(),edittext:=text:=x.sc.getline(linenum:=sc.2166(sc.2008)),pos:=1,ff:=[],line:=text
while,RegExMatch(edittext,"OU)(" Chr(34) ".*" Chr(34) ")",found,pos){
	rep:=""
	for a,b in StrSplit(found.1){
		if(StrPut(b,"utf-8")-1=1)
			rep.="_"
		else
			rep.=b
	}
	StringReplace,edittext,edittext,% found.1,%rep%,All
	pos:=found.Pos(1)+found.len(1)
}
paren:=0,newtext:=""
for a,b in StrSplit(edittext){
	if(b=")")
		paren--
	if paren
		newtext.="_"
	else
		newtext.=b
	if(b="(")
		paren++
}
lastpos:=pos:=1,finaltext:=""
while,pos:=InStr(newtext,",",0,1,A_Index)
	finaltext.=Trim(SubStr(line,lastpos,pos-lastpos),",") "`n",lastpos:=pos
GuiControl,-Redraw,% sc.sc
GuiControl,+g,% sc.sc
sc.2160(sc.2128(linenum),sc.2136(linenum))
sc.2170(0,finaltext Trim(SubStr(text,lastpos),",`n"))
x.call("newindent")
sc.2397(0),x.call("centersel")
GuiControl,+Redraw,% sc.sc
GuiControl,+gnotify,% sc.sc
ExitApp
m(x*){
	for a,b in x
		list.=b "`n"
	MsgBox,,AHK Studio,% list
}

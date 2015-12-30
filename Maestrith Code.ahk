#SingleInstance,Force
;menu Maestrith Code
x:=Studio(),sc:=x.sc,lines:=[],text:=sc.getuni()
Loop,% sc.2154
{
	style:=sc.2010(sc.2128(A_Index-1))
	if(style=5){
		if(last+1=A_Index){
			if(!lines[A_Index-1])
				lines[A_Index-1]:=1
			if(!lines[A_Index])
				lines[A_Index]:=1
		}
		last:=A_Index
	}
}
tt:=StrSplit(text,"`n")
for a in Lines{
	indent:=sc.2127(a-1)
	if(last+1=a&&indent=lastindent){
		if(!firstmatch)
			rep.=lasttext "`n",firstmatch:=1
		rep.=tt[a] "`n"
	}else if(A_Index>1&&rep){
		StringReplace,text,text,%rep%,% RegExReplace(RegExReplace(Trim(rep,"`n"),"\R",","),"\t") "`n"
		rep:="",firstmatch:=0
	}
	lasttext:=tt[a],last:=a,lastindent:=indent
}
StringReplace,text,text,%rep%,% RegExReplace(RegExReplace(Trim(rep,"`n"),"\R",","),"\t") "`n"
x.settext(text)
Sleep,300
x.SetTimer("fix_indent")
ExitApp
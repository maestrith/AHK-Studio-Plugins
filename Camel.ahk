;menu Camel
x:=Studio(),sc:=x.sc(),line:=sc.2166(sc.2008),sc.2008!=sc.2009?(text:=sc.getseltext(line)):(text:=sc.getline(line),sc.2160(sc.2128(line),sc.2136(line))),pos:=1
while,RegExMatch(text,"O)([a-zA-Z]+)(_|\W*)?",found,pos){
	if(!found.len(1))
		Break
	StringUpper,o,% found.1,T
	out.=o found.2,pos:=found.Pos(1)+found.len(1)
}
sc.2170(0,Trim(out,"`n"))
ExitApp
return
m(x*){
	for a,b in x
		msg.=b "`n"
	MsgBox,,AHK Studio,%msg%
}

;menu Sort Selected
Sort_Selected()
Sort_Selected(){
	static
	x:=Studio(),sc:=x.sc()
	if(sc.2008=sc.2009)
		sc.2160(sc.2128(line:=sc.2166(sc.2008)),sc.2136(line))
	text:=sc.getseltext(),newwin:=new GUIKeep(18),newwin.Add("Edit,w200 vdel,,w","Button,x+10 gsortdel,Sort By Delimeter,x","Button,x+10 gsortbyslash,Sort By \,x","Edit,xm w500 h500 vtext,,wh","Button,greplace,Replace Selected,y"),newwin.Show("Sort Selected")
	ControlSetText,Edit2,% RegExReplace(text,"\R","`r`n"),% newwin.id
	return
	sortbyslash:
	Sort,text,\
	StringReplace,text,text,`n,`r`n,all
	ControlSetText,Edit2,%text%,% newwin.id
	Goto,replace
	return
	sortdel:
	nw:=newwin[],del:=nw.del,text:=nw.text
	Sort,text,D%del%
	StringReplace,text,text,`n,`r`n,all
	ControlSetText,Edit2,%text%,% newwin.id
	Goto,replace
	return
	replace:
	text:=newwin[].text
	x.ReplaceSelected(RegExReplace(text,"\R","`n"))
	WinClose,A
	return
}
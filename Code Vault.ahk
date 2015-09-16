#SingleInstance,Force
;menu Code Vault
Studio(),Code_Vault()
return
+escape::
19GuiClose()
return
19GuiEscape(){
	19GuiClose()
}
19GuiClose(){
	global newwin,sc,vault
	Gui,19:Default
	if(LV_GetNext())
		LV_GetText(currentlocker,LV_GetNext()),vault.ssn("//code[@name='" currentlocker "']").text:=sc.getuni()
	newwin.exit()
}
return
Code_Vault(){
	static ev,mainfile,lastsc,v,keywords,newcode,currentlocker
	global x,newwin,sc,vault
	lastsc:=x.sc(),v:=x.get("v"),x.csc(sc,newwin.hwnd),vault:=x.get("vault"),mainfile:=x.current(2).file,newwin:=new GUIKeep(19),newwin.Add("ListView,w200 h400 AltSubmit gdisplayvault Section,Code,h","Button,xm gaddcode,&Add Code,y","Button,x+0 ginsertcode Default,&Insert Into Segment,y","Button,x+0 gcreatenewsegment,&Create New Segment,y","Button,x+0 gremovevaultentry,Remove Selected Entries,y","s,xs+210 ys w600 h400,,wh"),sc:=newwin.sc.1,x.color(sc),x.csc(sc,newwin.id),sc.2400(),sc.2171(1),newwin.Show("Code Vault"),sc:=newwin.sc.1
	populatevault:
	Gui,19:Default
	locker:=vault.sn("//code"),LV_Delete()
	while,ll:=locker.item[A_Index-1]
		name:=ssn(ll,"@name").text,LV_Add(newcode=name?"Select Vis Focus":"",name)
	if(!newcode)
		LV_Modify(1,"Vis Focus Select")
	Gui,Show,,Code Vault
	WinWaitActive,% newwin.id
	ControlFocus,SysTreeView321,% newwin.id
	newcode:=""
	return
	displayvault:
	if(A_GuiEvent~="i)I|K"){
		if(currentlocker)
			vault.ssn("//code[@name='" currentlocker "']").text:=sc.getuni()
		GuiControl,+g,% sc.sc
		LV_GetText(code,LV_GetNext()),tt:=vault.ssn("//code[@name='" code "']").text,currentlocker:=code
		if(tt)
			sc.2171(0)
		length:=VarSetCapacity(text,strput(tt,"utf-8")),StrPut(tt,&text,length,"utf-8"),sc.2037(65001),sc.2181(0,&text),sc.2175,dup:=files.sn("//file[@file='" fn "']"),sc.2181(0,&text)
		Sleep,200
		GuiControl,+gnotify,% sc.sc
	}
	return
	addcode:
	InputBox,newcode,Name for code snippet,Please enter a name for a new code snippet.
	if(ErrorLevel||newcode="")
		return
	newcode:=RegExReplace(newcode," ","_")
	if !locker:=vault.ssn("//code[@name='" newcode "']")
		locker:=vault.Add("code",,,1),att(locker,{name:newcode}),locker.text:=""
	Gosub,populatevault
	return
	insertcode:
	lastsc.2003(lastsc.2008,sc.getuni())
	return
	createnewsegment:
	current:=x.current(2).file
	SplitPath,current,,outdir
	FileSelectFile,filename,S,%outdir%,Create New Segment,*.ahk
	if(ErrorLevel||filename="")
		return
	filename:=SubStr(filename,-3)=".ahk"?filename:filename ".ahk"
	x.csc(lastsc,newwin.hwnd)
	x.call("new_segment",filename,sc.getuni())
	Sleep,1500
	x.csc(sc,newwin.hwnd)
	WinActivate,% newwin.id
	return
	cnsil:
	return
	removevaultentry:
	LV_GetText(code,LV_GetNext())
	if(node:=vault.ssn("//code[@name='" code "']")){
		MsgBox,3,Are you sure?,Can not be undone
		IfMsgBox,Yes
		{
			node.ParentNode.RemoveChild(node)
			SetTimer,populatevault,-100
		}
	}
	return
	notify:
	fn:=[],info:=A_EventInfo,code:=NumGet(info+(A_PtrSize*2))
	if(code=2028)
		return x.csc(sc,newwin.hwnd)
	if code not in 2001,2002,2004,2006,2007,2008,2010,2014,2018,2019,2021,2022,2027
		return 0
	;0:"Obj",2:"Code",4:"ch",6:"modType",7:"text",8:"length",9:"linesadded",10:"msg",11:"wparam",12:"lparam",13:"line",14:"fold",17:"listType",22:"updated"
	for a,b in {0:"Obj",2:"Code",3:"position",4:"ch",5:"mod",6:"modType",7:"text",8:"length",9:"linesadded",10:"msg",11:"wparam",12:"lparam",13:"line",14:"fold",17:"listType",22:"updated"}
		fn[b]:=NumGet(Info+(A_PtrSize*a))
	if(code=2004){
		SetTimer,addcode,-1
		return
	}if(code=2001){
		if(fn.ch=10)
			x.SetTimer("newindent",-10)
		cpos:=sc.2008,start:=sc.2266(cpos,1),end:=sc.2267(cpos,1),word:=sc.textrange(sc.2266(cpos,1),sc.2267(cpos,1))
		if((StrLen(word)>1&&sc.2102=0&&v.options.Disable_Auto_Complete!=1&&sc.2010(cpos)~="\b(13|1|11|3)\b"=0)){
			word:=RegExReplace(word,"^\d*"),list:=Trim(v.keywords[SubStr(word,1,1)]) ;,code_explorer.varlist[current(2).file]
			if(!sc.2202&&v.options.Disable_Auto_Complete_While_Tips_Are_Visible=1){
			}else{
				if(list&&instr(list,word))
					sc.2100(StrLen(word),list)
			}
		}
		x.SetTimer("context",-10)
	}
	return
}
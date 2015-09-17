#SingleInstance,Force
;menu Restore Current File
Restore_Current_File()
Restore_Current_File(){
	static
	x:=Studio(),sc:=x.sc(),newwin:=new GUIKeep(16),newwin.Add("ListView,w350 h480 altsubmit grestore,Backup,h","Edit,x+10 w550 h480 -Wrap,,wh","Edit,xm w550,MM-dd-yyyy HH:mm:ss,wy","Button,x+10 grcfr,Refresh Folder List,xy","Button,xm grestorefile Default,R&estore selected file,y")
	if(date:=settings.ssn("//restoredate").text)
		ControlSetText,Edit2,%date%,% newwin.id
	gosub,poprcf
	newwin.Show("Restore")
	return
	Restore:
	file:=x.current(3).file
	SplitPath,file,filename,dir
	LV_GetText(bdir,LV_GetNext()),file:=FileOpen(filelist[bdir],0,"utf-8"),contents:=file.Read(file.length),file.close()
	ControlSetText,Edit1,%contents%
	return
	restorefile:
	file:=x.current(3).file
	SplitPath,file,filename,dir
	LV_GetText(bdir,LV_GetNext()),oldfile:=filelist[bdir],file:=FileOpen(filelist[bdir],0,"utf-8"),contents:=file.Read(file.length),file.close(),contents:=RegExReplace(contents,"\R","`n"),x.SetText(contents)
	ControlGetText,date,Edit2,A
	settings.add("restoredate").text:=date
	WinClose,A
	return
	rcfr:
	poprcf:
	ControlGetText,format,Edit2,% newwin.id
	if(A_ThisLabel="rcfr")
		settings.Add("restoredate").text:=format
	SplashTextOn,,50,Collecting backup files,Please wait...
	LV_Delete(),filelist:=[],file:=x.current(3).file,backup:=[],full:=[]
	SplitPath,file,filename,dir
	loop,% dir "\backup\" filename,1,1
	{
		ff:=StrSplit(A_LoopFileDir,"\"),fn:=ff[ff.MaxIndex()],RegExMatch(fn,"O)(\d+)",date),pre:=RegExReplace(fn,date.1)
		FormatTime,folder,% date.1,%format%
		dt:=pre?pre " " folder:folder,filelist[dt]:=A_LoopFileFullPath
		if(InStr(dt,"Full Backup"))
			full.InsertAt(1,dt)
		else
			backup.InsertAt(1,dt)
	}
	for a,b in [backup,full]
		for c,d in b
			LV_Add("",d)
	LV_Modify(1,"select Focus")
	SplashTextOff
	return
}
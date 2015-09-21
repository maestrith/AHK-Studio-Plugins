;menu Check For Update
Check_For_Update()
Check_For_Update(){
	/*
		put this back in, and have it download the url of the update program
		-then have it also download the txt file as well...or just drop off the .ahk and change to .text..
		--either way. ;#[Work On This]
	*/
	static version,edit,x
	x:=ComObjActive("AHK-Studio"),info:=x.Style(),version:=x.Version()
	Gui,Font,% "c" info.color " s" info.size,% info.font
	Gui,Color,% info.Background,% info.Background
	Gui,Margin,0,0
	sub:=A_NowUTC
	sub-=A_Now,hh
	FileGetTime,time,% x.StudioPath()
	time+=%sub%,hh
	url:="http://files.maestrith.com/Soup_Is_Good/AHK-Studio.text",http:=ComObjCreate("WinHttp.WinHttpRequest.5.1"),http.Open("GET",url)
	if(proxy:=settings.ssn("//proxy").text)
		http.setProxy(2,proxy)
	FormatTime,time,%time%,ddd, dd MMM yyyy HH:mm:ss
	http.setRequestHeader("If-Modified-Since",time " GMT"),http.Send()
	info:=http.responsetext?http.responsetext:"Nothing new to download"
	if(http.ResponseText)
		file:=FileOpen("changelog.txt","rw"),file.seek(0),file.write(RegExReplace(http.ResponseText,"\R","`r`n")),file.length(file.position)
	Gui,Add,Edit,w500 h500 ReadOnly hwndedit,%info%
	Disable:=info="Nothing new to download"?"Disabled":""
	Gui,Add,Button,gautoupdate,Update
	Gui,Add,Button,x+5 gcurrentinfo,Current Changelog
	Gui,Add,Button,x+5 gextrainfo,Changelog History
	Gui,Show,,% "AHK Studio Version " x.version()
	SendMessage,0xB1,0,0,,ahk_id%edit%
	return
	downloadahk:
	Run,http://ahkscript.org/download
	return
	currentinfo:
	file:=FileOpen("changelog.txt","rw")
	if(!file.length)
		file:=FileOpen("changelog.txt","rw"),file.seek(0),file.write(RegExReplace(UrlDownloadToVar("http://files.maestrith.com/Soup_Is_Good/AHK-Studio.text"),"\R","`r`n")),file.length(file.position)
	file.seek(0)
	ControlSetText,Edit1,% file.Read(file.length)
	return
	autoupdate:
	x.call("save"),settings.save(1)
	StudioPath:=x.StudioPath()
	studio:=URLDownloadToVar("http://files.maestrith.com/Soup_Is_Good/AHK-Studio.ahk")
	if !InStr(studio,";download complete")
		return m("There was an error. Please contact maestrith@gmail.com if this error continues")
	x.MoveStudio(),ComObjError(0),File:=FileOpen(StudioPath,"rw"),File.seek(0),File.write(studio),File.length(File.position),x.call("Test_Plugin")
	ExitApp
	return
	GuiEscape:
	GuiClose:
	ExitApp
	return
	extrainfo:
	Run,https://github.com/maestrith/AHK-Studio/wiki/Version-Update-History
	return
}
m(x*){
	for a,b in x
		list.=b "`n"
	MsgBox,,AHK Studio,% list
}
URLDownloadToVar(url){
	http:=ComObjCreate("WinHttp.WinHttpRequest.5.1")
	if proxy:=settings.ssn("//proxy").text
		http.setProxy(2,proxy)
	http.Open("GET",url,1),http.Send()
	http.WaitForResponse
	return http.ResponseText
}
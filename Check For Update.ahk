;menu Check For Update
Check_For_Update()
Check_For_Update(){
	
	
	sub:=A_NowUTC
	sub-=A_Now,hh
	
	date:="2015-11-11T17:24:34Z"
	date:=RegExReplace(date,"\D")
	now:=A_Now
	now+=sub,hh
	m(date,sub,now,now>date)
	url:="https://raw.githubusercontent.com/maestrith/AHK-Studio/master/AHK-Studio.ahk",http:=ComObjCreate("WinHttp.WinHttpRequest.5.1"),http.Open("GET",url)
	if(proxy:=settings.ssn("//proxy").text)
		http.setProxy(2,proxy)
	http.send()
	RegExMatch(http.ResponseText, "iUO)\x22data\x22:\x22.*\x22",found)
	RegExMatch(a, s"," , d , f )
	/*
		{"sha":"f2feea9ff2be09b8a25de461d89f47d0ea9a1717","commit":{"author":{"name":"maestrith","email":"maestrith@gmail.com","date":"2015-11-11T17:24:34Z"},"committer":{"name":"maestrith","email":"maestrith@gmail.com","date":"2015-11-11T17:24:34Z"},"message":"NOTICE!\n-This will download a new copy of SciLexer.dll\n\nFixed: Reported by huckleberry\n-Escaped commas `, were causing the context sensitive help to advance\nChanged:\n-Commas inside { }, [ ], and () have a different color code.  This can be changed in the Themes plugin.\nFixed: Reported by zotune\n-Jumping of selection and positions on focus\n-Find is a lot more stable and accurate.","tree":{"sha":"18f4c34a50bd1a48aa95d09d0ae6f5dd59aee87f","url":"https://api.github.com/repos/maestrith/AHK-Studio/git/trees/18f4c34a50bd1a48aa95d09d0ae6f5dd59aee87f"},"url":"https://api.github.com/repos/maestrith/AHK-Studio/git/commits/f2feea9ff2be09b8a25de461d89f47d0ea9a1717","comment_count":0},"url":"https://api.github.com/repos/maestrith/AHK-Studio/commits/f2feea9ff2be09b8a25de461d89f47d0ea9a1717","html_url":"https://github.com/maestrith/AHK-Studio/commit/f2feea9ff2be09b8a25de461d89f47d0ea9a1717","comments_url":"https://api.github.com/repos/maestrith/AHK-Studio/commits/f2feea9ff2be09b8a25de461d89f47d0ea9a1717/comments","author":{"login":"maestrith","id":2114637,"avatar_url":"https://avatars.githubusercontent.com/u/2114637?v=3","gravatar_id":"","url":"https://api.github.com/users/maestrith","html_url":"https://github.com/maestrith","followers_url":"https://api.github.com/users/maestrith/followers","following_url":"https://api.github.com/users/maestrith/following{/other_user}","gists_url":"https://api.github.com/users/maestrith/gists{/gist_id}","starred_url":"https://api.github.com/users/maestrith/starred{/owner}{/repo}","subscriptions_url":"https://api.github.com/users/maestrith/subscriptions","organizations_url":"https://api.github.com/users/maestrith/orgs","repos_url":"https://api.github.com/users/maestrith/repos","events_url":"https://api.github.com/users/maestrith/events{/privacy}","received_events_url":"https://api.github.com/users/maestrith/received_events","type":"User","site_admin":false},"committer":{"login":"maestrith","id":2114637,"avatar_url":"https://avatars.githubusercontent.com/u/2114637?v=3","gravatar_id":"","url":"https://api.github.com/users/maestrith","html_url":"https://github.com/maestrith","followers_url":"https://api.github.com/users/maestrith/followers","following_url":"https://api.github.com/users/maestrith/following{/other_user}","gists_url":"https://api.github.com/users/maestrith/gists{/gist_id}","starred_url":"https://api.github.com/users/maestrith/starred{/owner}{/repo}","subscriptions_url":"https://api.github.com/users/maestrith/subscriptions","organizations_url":"https://api.github.com/users/maestrith/orgs","repos_url":"https://api.github.com/users/maestrith/repos","events_url":"https://api.github.com/users/maestrith/events{/privacy}","received_events_url":"https://api.github.com/users/maestrith/received_events","type":"User","site_admin":false},"parents":[{"sha":"99ea63e28528d55cfff62d9554f7b726ab6a5430","url":"https://api.github.com/repos/maestrith/AHK-Studio/commits/99ea63e28528d55cfff62d9554f7b726ab6a5430","html_url":"https://github.com/maestrith/AHK-Studio/commit/99ea63e28528d55cfff62d9554f7b726ab6a5430"}],"stats":{"total":111,"additions":56,"deletions":55},"files":[{"sha":"9d1e1bd6b0d83f5f75e6edb79f27474834a676a3","filename":"AHK-Studio.ahk","status":"modified","additions":2,"deletions":2,"changes":4,"blob_url":"https://github.com/maestrith/AHK-Studio/blob/f2feea9ff2be09b8a25de461d89f47d0ea9a1717/AHK-Studio.ahk","raw_url":"https://github.com/maestrith/AHK-Studio/raw/f2feea9ff2be09b8a25de461d89f47d0ea9a1717/AHK-Studio.ahk","contents_url":"https://api.github.com/repos/maestrith/AHK-Studio/contents/AHK-Studio.ahk?ref=f2feea9ff2be09b8a25de461d89f47d0ea9a1717","patch":"@@ -5335,9 +5335,9 @@ Scintilla_Code_Lookup(){\n }\r\n Scintilla(return:=\"\"){\r\n \tstatic list\r\n-\tfiledate:=20150925131313\r\n+\tfiledate:=20151111121313\r\n \tFileGetTime,time,lib\\scintilla.xml\r\n-\tif(time!=filedate)\r\n+\tif(time<=filedate)\r\n \t\tFileDelete,lib\\scintilla.xml\r\n \tif(!FileExist(\"lib\\scintilla.xml\")){\r\n \t\tSplashTextOn,300,100,Downloading definitions,Please wait\r"},{"sha":"82653e2e30a87b842e7646cdbd426f7049ae8e34","filename":"lib/scintilla.xml","status":"modified","additions":54,"deletions":53,"changes":107,"blob_url":"https://github.com/maestrith/AHK-Studio/blob/f2feea9ff2be09b8a25de461d89f47d0ea9a1717/lib/scintilla.xml","raw_url":"https://github.com/maestrith/AHK-Studio/raw/f2feea9ff2be09b8a25de461d89f47d0ea9a1717/lib/scintilla.xml","contents_url":"https://api.github.com/repos/maestrith/AHK-Studio/contents/lib/scintilla.xml?ref=f2feea9ff2be09b8a25de461d89f47d0ea9a1717","patch":"@@ -2,8 +2,8 @@\n <scintilla>\r\n \t<commands>\r\n \t\t<item name=\"START\" code=\"2103\"></item>\r\n-\t\t<item name=\"OPTIONAL_START\" code=\"\"></item>\r\n-\t\t<item name=\"LEXER_START\" code=\"\"></item>\r\n+\t\t<item name=\"OPTIONAL_START\" code=\"2000\"></item>\r\n+\t\t<item name=\"LEXER_START\" code=\"4000\"></item>\r\n \t\t<item name=\"ADDTEXT\" code=\"2001\" syntax=\"(int length,string text)\"></item>\r\n \t\t<item name=\"ADDSTYLEDTEXT\" code=\"2002\" syntax=\"(int length,cells c)\"></item>\r\n \t\t<item name=\"INSERTTEXT\" code=\"2003\" syntax=\"(position pos,string text)\"></item>\r\n@@ -766,7 +766,7 @@\n \t\t<item code=\"29\" name=\"MARKNUM_FOLDERSUB\"></item>\r\n \t\t<item code=\"30\" name=\"MARKNUM_FOLDER\"></item>\r\n \t\t<item code=\"31\" name=\"MARKNUM_FOLDEROPEN\"></item>\r\n-\t\t<item code=\"0\" name=\"MASK_FOLDERS\"></item>\r\n+\t\t<item code=\"0xFE000000\" name=\"MASK_FOLDERS\"></item>\r\n \t\t<item code=\"4\" name=\"MAX_MARGIN\"></item>\r\n \t\t<item code=\"0\" name=\"MARGIN_SYMBOL\"></item>\r\n \t\t<item code=\"1\" name=\"MARGIN_NUMBER\"></item>\r\n@@ -804,8 +804,8 @@\n \t\t<item code=\"400\" name=\"WEIGHT_NORMAL\"></item>\r\n \t\t<item code=\"600\" name=\"WEIGHT_SEMIBOLD\"></item>\r\n \t\t<item code=\"700\" name=\"WEIGHT_BOLD\"></item>\r\n-\t\t<item code=\"0\" name=\"INDICVALUEBIT\"></item>\r\n-\t\t<item code=\"0\" name=\"INDICVALUEMASK\"></item>\r\n+\t\t<item code=\"0x1000000\" name=\"INDICVALUEBIT\"></item>\r\n+\t\t<item code=\"0xFFFFFF\" name=\"INDICVALUEMASK\"></item>\r\n \t\t<item code=\"1\" name=\"INDICFLAG_VALUEFORE\"></item>\r\n \t\t<item code=\"0\" name=\"IV_NONE\"></item>\r\n \t\t<item code=\"1\" name=\"IV_REAL\"></item>\r\n@@ -816,34 +816,34 @@\n \t\t<item code=\"2\" name=\"PRINT_BLACKONWHITE\"></item>\r\n \t\t<item code=\"3\" name=\"PRINT_COLOURONWHITE\"></item>\r\n \t\t<item code=\"4\" name=\"PRINT_COLOURONWHITEDEFAULTBG\"></item>\r\n-\t\t<item code=\"0\" name=\"FOLDLEVELBASE\"></item>\r\n-\t\t<item code=\"0\" name=\"FOLDLEVELWHITEFLAG\"></item>\r\n-\t\t<item code=\"0\" name=\"FOLDLEVELHEADERFLAG\"></item>\r\n-\t\t<item code=\"0\" name=\"FOLDLEVELNUMBERMASK\"></item>\r\n+\t\t<item code=\"0x400\" name=\"FOLDLEVELBASE\"></item>\r\n+\t\t<item code=\"0x1000\" name=\"FOLDLEVELWHITEFLAG\"></item>\r\n+\t\t<item code=\"0x2000\" name=\"FOLDLEVELHEADERFLAG\"></item>\r\n+\t\t<item code=\"0x0FFF\" name=\"FOLDLEVELNUMBERMASK\"></item>\r\n \t\t<item code=\"0\" name=\"FOLDACTION_CONTRACT\"></item>\r\n \t\t<item code=\"1\" name=\"FOLDACTION_EXPAND\"></item>\r\n \t\t<item code=\"2\" name=\"FOLDACTION_TOGGLE\"></item>\r\n-\t\t<item code=\"0\" name=\"AUTOMATICFOLD_SHOW\"></item>\r\n-\t\t<item code=\"0\" name=\"AUTOMATICFOLD_CLICK\"></item>\r\n-\t\t<item code=\"0\" name=\"AUTOMATICFOLD_CHANGE\"></item>\r\n-\t\t<item code=\"0\" name=\"FOLDFLAG_LINEBEFORE_EXPANDED\"></item>\r\n-\t\t<item code=\"0\" name=\"FOLDFLAG_LINEBEFORE_CONTRACTED\"></item>\r\n-\t\t<item code=\"0\" name=\"FOLDFLAG_LINEAFTER_EXPANDED\"></item>\r\n-\t\t<item code=\"0\" name=\"FOLDFLAG_LINEAFTER_CONTRACTED\"></item>\r\n-\t\t<item code=\"0\" name=\"FOLDFLAG_LEVELNUMBERS\"></item>\r\n-\t\t<item code=\"0\" name=\"FOLDFLAG_LINESTATE\"></item>\r\n+\t\t<item code=\"0x0001\" name=\"AUTOMATICFOLD_SHOW\"></item>\r\n+\t\t<item code=\"0x0002\" name=\"AUTOMATICFOLD_CLICK\"></item>\r\n+\t\t<item code=\"0x0004\" name=\"AUTOMATICFOLD_CHANGE\"></item>\r\n+\t\t<item code=\"0x0002\" name=\"FOLDFLAG_LINEBEFORE_EXPANDED\"></item>\r\n+\t\t<item code=\"0x0004\" name=\"FOLDFLAG_LINEBEFORE_CONTRACTED\"></item>\r\n+\t\t<item code=\"0x0008\" name=\"FOLDFLAG_LINEAFTER_EXPANDED\"></item>\r\n+\t\t<item code=\"0x0010\" name=\"FOLDFLAG_LINEAFTER_CONTRACTED\"></item>\r\n+\t\t<item code=\"0x0040\" name=\"FOLDFLAG_LEVELNUMBERS\"></item>\r\n+\t\t<item code=\"0x0080\" name=\"FOLDFLAG_LINESTATE\"></item>\r\n \t\t<item code=\"10000000\" name=\"TIME_FOREVER\"></item>\r\n \t\t<item code=\"0\" name=\"WRAP_NONE\"></item>\r\n \t\t<item code=\"1\" name=\"WRAP_WORD\"></item>\r\n \t\t<item code=\"2\" name=\"WRAP_CHAR\"></item>\r\n \t\t<item code=\"3\" name=\"WRAP_WHITESPACE\"></item>\r\n-\t\t<item code=\"0\" name=\"WRAPVISUALFLAG_NONE\"></item>\r\n-\t\t<item code=\"0\" name=\"WRAPVISUALFLAG_END\"></item>\r\n-\t\t<item code=\"0\" name=\"WRAPVISUALFLAG_START\"></item>\r\n-\t\t<item code=\"0\" name=\"WRAPVISUALFLAG_MARGIN\"></item>\r\n-\t\t<item code=\"0\" name=\"WRAPVISUALFLAGLOC_DEFAULT\"></item>\r\n-\t\t<item code=\"0\" name=\"WRAPVISUALFLAGLOC_END_BY_TEXT\"></item>\r\n-\t\t<item code=\"0\" name=\"WRAPVISUALFLAGLOC_START_BY_TEXT\"></item>\r\n+\t\t<item code=\"0x0000\" name=\"WRAPVISUALFLAG_NONE\"></item>\r\n+\t\t<item code=\"0x0001\" name=\"WRAPVISUALFLAG_END\"></item>\r\n+\t\t<item code=\"0x0002\" name=\"WRAPVISUALFLAG_START\"></item>\r\n+\t\t<item code=\"0x0004\" name=\"WRAPVISUALFLAG_MARGIN\"></item>\r\n+\t\t<item code=\"0x0000\" name=\"WRAPVISUALFLAGLOC_DEFAULT\"></item>\r\n+\t\t<item code=\"0x0001\" name=\"WRAPVISUALFLAGLOC_END_BY_TEXT\"></item>\r\n+\t\t<item code=\"0x0002\" name=\"WRAPVISUALFLAGLOC_START_BY_TEXT\"></item>\r\n \t\t<item code=\"0\" name=\"WRAPINDENT_FIXED\"></item>\r\n \t\t<item code=\"1\" name=\"WRAPINDENT_SAME\"></item>\r\n \t\t<item code=\"2\" name=\"WRAPINDENT_INDENT\"></item>\r\n@@ -854,7 +854,7 @@\n \t\t<item code=\"0\" name=\"PHASES_ONE\"></item>\r\n \t\t<item code=\"1\" name=\"PHASES_TWO\"></item>\r\n \t\t<item code=\"2\" name=\"PHASES_MULTIPLE\"></item>\r\n-\t\t<item code=\"0\" name=\"EFF_QUALITY_MASK\"></item>\r\n+\t\t<item code=\"0xF\" name=\"EFF_QUALITY_MASK\"></item>\r\n \t\t<item code=\"0\" name=\"EFF_QUALITY_DEFAULT\"></item>\r\n \t\t<item code=\"1\" name=\"EFF_QUALITY_NON_ANTIALIASED\"></item>\r\n \t\t<item code=\"2\" name=\"EFF_QUALITY_ANTIALIASED\"></item>\r\n@@ -866,6 +866,7 @@\n \t\t<item code=\"2\" name=\"STATUS_BADALLOC\"></item>\r\n \t\t<item code=\"1000\" name=\"STATUS_WARN_START\"></item>\r\n \t\t<item code=\"1001\" name=\"STATUS_WARN_REGEX\"></item>\r\n+\t\t<item code=\"-1\" name=\"CURSORNORMAL\"></item>\r\n \t\t<item code=\"2\" name=\"CURSORARROW\"></item>\r\n \t\t<item code=\"4\" name=\"CURSORWAIT\"></item>\r\n \t\t<item code=\"7\" name=\"CURSORREVERSEARROW\"></item>\r\n@@ -897,33 +898,33 @@\n \t\t<item code=\"0\" name=\"TYPE_BOOLEAN\"></item>\r\n \t\t<item code=\"1\" name=\"TYPE_INTEGER\"></item>\r\n \t\t<item code=\"2\" name=\"TYPE_STRING\"></item>\r\n-\t\t<item code=\"0\" name=\"MOD_INSERTTEXT\"></item>\r\n-\t\t<item code=\"0\" name=\"MOD_DELETETEXT\"></item>\r\n-\t\t<item code=\"0\" name=\"MOD_CHANGESTYLE\"></item>\r\n-\t\t<item code=\"0\" name=\"MOD_CHANGEFOLD\"></item>\r\n-\t\t<item code=\"0\" name=\"PERFORMED_USER\"></item>\r\n-\t\t<item code=\"0\" name=\"PERFORMED_UNDO\"></item>\r\n-\t\t<item code=\"0\" name=\"PERFORMED_REDO\"></item>\r\n-\t\t<item code=\"0\" name=\"MULTISTEPUNDOREDO\"></item>\r\n-\t\t<item code=\"0\" name=\"LASTSTEPINUNDOREDO\"></item>\r\n-\t\t<item code=\"0\" name=\"MOD_CHANGEMARKER\"></item>\r\n-\t\t<item code=\"0\" name=\"MOD_BEFOREINSERT\"></item>\r\n-\t\t<item code=\"0\" name=\"MOD_BEFOREDELETE\"></item>\r\n-\t\t<item code=\"0\" name=\"MULTILINEUNDOREDO\"></item>\r\n-\t\t<item code=\"0\" name=\"STARTACTION\"></item>\r\n-\t\t<item code=\"0\" name=\"MOD_CHANGEINDICATOR\"></item>\r\n-\t\t<item code=\"0\" name=\"MOD_CHANGELINESTATE\"></item>\r\n-\t\t<item code=\"0\" name=\"MOD_CHANGEMARGIN\"></item>\r\n-\t\t<item code=\"0\" name=\"MOD_CHANGEANNOTATION\"></item>\r\n-\t\t<item code=\"0\" name=\"MOD_CONTAINER\"></item>\r\n-\t\t<item code=\"0\" name=\"MOD_LEXERSTATE\"></item>\r\n-\t\t<item code=\"0\" name=\"MOD_INSERTCHECK\"></item>\r\n-\t\t<item code=\"0\" name=\"MOD_CHANGETABSTOPS\"></item>\r\n-\t\t<item code=\"0\" name=\"MODEVENTMASKALL\"></item>\r\n-\t\t<item code=\"0\" name=\"UPDATE_CONTENT\"></item>\r\n-\t\t<item code=\"0\" name=\"UPDATE_SELECTION\"></item>\r\n-\t\t<item code=\"0\" name=\"UPDATE_V_SCROLL\"></item>\r\n-\t\t<item code=\"0\" name=\"UPDATE_H_SCROLL\"></item>\r\n+\t\t<item code=\"0x1\" name=\"MOD_INSERTTEXT\"></item>\r\n+\t\t<item code=\"0x2\" name=\"MOD_DELETETEXT\"></item>\r\n+\t\t<item code=\"0x4\" name=\"MOD_CHANGESTYLE\"></item>\r\n+\t\t<item code=\"0x8\" name=\"MOD_CHANGEFOLD\"></item>\r\n+\t\t<item code=\"0x10\" name=\"PERFORMED_USER\"></item>\r\n+\t\t<item code=\"0x20\" name=\"PERFORMED_UNDO\"></item>\r\n+\t\t<item code=\"0x40\" name=\"PERFORMED_REDO\"></item>\r\n+\t\t<item code=\"0x80\" name=\"MULTISTEPUNDOREDO\"></item>\r\n+\t\t<item code=\"0x100\" name=\"LASTSTEPINUNDOREDO\"></item>\r\n+\t\t<item code=\"0x200\" name=\"MOD_CHANGEMARKER\"></item>\r\n+\t\t<item code=\"0x400\" name=\"MOD_BEFOREINSERT\"></item>\r\n+\t\t<item code=\"0x800\" name=\"MOD_BEFOREDELETE\"></item>\r\n+\t\t<item code=\"0x1000\" name=\"MULTILINEUNDOREDO\"></item>\r\n+\t\t<item code=\"0x2000\" name=\"STARTACTION\"></item>\r\n+\t\t<item code=\"0x4000\" name=\"MOD_CHANGEINDICATOR\"></item>\r\n+\t\t<item code=\"0x8000\" name=\"MOD_CHANGELINESTATE\"></item>\r\n+\t\t<item code=\"0x10000\" name=\"MOD_CHANGEMARGIN\"></item>\r\n+\t\t<item code=\"0x20000\" name=\"MOD_CHANGEANNOTATION\"></item>\r\n+\t\t<item code=\"0x40000\" name=\"MOD_CONTAINER\"></item>\r\n+\t\t<item code=\"0x80000\" name=\"MOD_LEXERSTATE\"></item>\r\n+\t\t<item code=\"0x100000\" name=\"MOD_INSERTCHECK\"></item>\r\n+\t\t<item code=\"0x200000\" name=\"MOD_CHANGETABSTOPS\"></item>\r\n+\t\t<item code=\"0x3FFFFF\" name=\"MODEVENTMASKALL\"></item>\r\n+\t\t<item code=\"0x1\" name=\"UPDATE_CONTENT\"></item>\r\n+\t\t<item code=\"0x2\" name=\"UPDATE_SELECTION\"></item>\r\n+\t\t<item code=\"0x4\" name=\"UPDATE_V_SCROLL\"></item>\r\n+\t\t<item code=\"0x8\" name=\"UPDATE_H_SCROLL\"></item>\r\n \t\t<item code=\"1\" name=\"AC_FILLUP\"></item>\r\n \t\t<item code=\"2\" name=\"AC_DOUBLECLICK\"></item>\r\n \t\t<item code=\"3\" name=\"AC_TAB\"></item>\r"}]}
	*/
	
	
	ExitApp
	
	
	/*
		put this back in, and have it download the url of the update program
		-then have it also download the txt file as well...or just drop off the .ahk and change to .text..
		--either way. ;#[Work On This]
	*/
	static version,edit,x
	x:=ComObjActive("AHK-Studio"),info:=x.Style(),version:=x.Version()
	Gui,Font,% "c" info.color " s" info.size,% info.font
	Gui,Color,% info.Background,% info.Background
	Gui,Margin,0,0 ;#[This is my new bookmark]
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
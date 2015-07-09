#SingleInstance,Force
#Include Index.xml
#Include Toggle Fullscreen.ahk
/*
	m(UrlDownloadToVar("https://raw.githubusercontent.com/maestrith/AHK-Studio-Plugins/master/Toggle Fullscreen.ahk"))
	URLDownloadToVar(url){
		http:=ComObjCreate("WinHttp.WinHttpRequest.5.1")
		if proxy:=settings.ssn("//proxy").text
			http.setProxy(2,proxy)
		http.Open("GET",url,1),http.Send()
		http.WaitForResponse
		return http.ResponseText
	}
*/
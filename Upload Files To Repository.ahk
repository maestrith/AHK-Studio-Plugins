;menu Upload Files To Repository
#SingleInstance,Force
x:=Studio()
global settings,git,repository,TreeView
settings:=x.get("settings")
repository:=new xml("Repository")
if(!gh:=settings.ssn("//github"))
	gh:=settings.Add({path:"github"})
Gui()
return
GuiEscape:
GuiClose:
settings.save(1),repository.save(1)
ExitApp
return
class github{
	static http:=[]
	__New(){
		ea:=ea(settings.ssn("//github"))
		if !(ea.owner&&ea.token)
			return Gui("expandsettings"),m("Please setup your Github info")
		for a,b in ea
			this[a]:=b
		this.http:=ComObjCreate("WinHttp.WinHttpRequest.5.1"),this.token:="?access_token=" ea.token,this.tok:="&access_token=" ea.token
		this.url:="https://api.github.com"
		return this
	}
	CreateRepo(name,description="Created with AHK Studio",homepage="http://www.maestrith.com",private="false",issues="false",wiki="true",downloads="true"){
		url:=this.url "/user/repos" this.token
		this.http.Open("POST",url)
		json={"name":"%name%","description":"%description%","homepage":"%homepage%","private":%private%,"has_issues":%issues%,"has_wiki":%wiki%,"has_downloads":%downloads%,"auto_init":"true"}
		this.http.Send(json)
		return this.http.ResponseText
	}
	getrepos(){
		;GET /users/:username/repos
		if(!this.owner)
			return Gui("expandsettings"),m("Please setup your Github info")
		url:=this.url "/users/" this.owner "/repos" this.token,info:=this.Send("GET",url),LV_Delete()
		for a,b in StrSplit(info,"{" Chr(34) "id" Chr(34) ":"){
			if(b="[")
				continue
			RegExMatch(b,"U),.name.:.(.*)" Chr(34),name),RegExMatch(b,"(\d+)",id)
			if !repository.ssn("//repos/repo[@name='" name1 "']")
				new:=repository.Add("repos/repo",,,1),att(new,{name:name1,id:id})
		}
		SB_SetText("Rate Limit = " this.http.getresponseheader("X-RateLimit-Remaining"),1)
		SetTimer,populate,-1
	}
	delete(repo,filenames){
		url:=this.url "/repos/" this.owner "/" repo "/commits" this.token ;get the tree sha
		tree:=this.sha(this.Send("GET",url))
		url:=this.url "/repos/" this.owner "/" repo "/git/trees/" tree "?recursive=1" this.tok ;full tree info
		info:=this.Send("GET",url),fz:=[],info:=SubStr(info,InStr(info,"tree" Chr(34)))
		for a,b in strsplit(info,"{"){
			if path:=this.find("path",b)
				fz[path]:=this.find("sha",b)
		}
		for c in filenames{
			StringReplace,cc,c,\,/,All
			url:=this.url "/repos/" this.owner "/" repo "/contents/" cc this.token,sha:=fz[cc]
			json={"message":"Deleted","sha":"%sha%"}
			this.http.Open("DELETE",url),this.http.send(json)
			if (this.http.status!=200)
				m("Error deleting " c,this.http.ResponseText)
			FileDelete,github\%repo%\%c%
		}
	}
	find(search,text){
		RegExMatch(text,"U)" Chr(34) search Chr(34) ":(.*),",found)
		return Trim(found1,Chr(34))
	}
	sha(text){
		RegExMatch(this.http.ResponseText,"U)" Chr(34) "sha" Chr(34) ":(.*),",found)
		return Trim(found1,Chr(34))
	}
	getref(repo){
		url:=this.url "/repos/" this.owner "/" repo "/git/refs" this.token
		this.cmtsha:=this.sha(this.Send("GET",url)),url:=this.url "/repos/" this.owner "/" repo "/commits/" this.cmtsha this.token
		RegExMatch(this.Send("GET",url),"U)tree.:\{.sha.:.(.*)" Chr(34),found)
		return found1
	}
	blob(repo,text){
		text:=this.utf8(text)
		json={"content":"%text%","encoding":"utf-8"}
		return this.sha(this.Send("POST",this.url "/repos/" this.owner "/" repo "/git/blobs" this.token,json))
	}
	send(verb,url,data=""){
		this.http.Open(verb,url),this.http.send(data)
		return this.http.ResponseText
	}
	tree(repo,parent,blobs){
		url:=this.url "/repos/" this.owner "/" repo "/git/trees" this.token ;POST /repos/:owner/:repo/git/trees
		json={"base_tree":"%parent%","tree":[
		for a,blob in blobs{
			add={"path":"%a%","mode":"100644","type":"blob","sha":"%blob%"}, 
			json.=add
		}
		return this.sha(this.Send("POST",url,Trim(json,",") "]}"))
	}
	commit(repo,tree,parent,message="Updated the file",name="placeholder",email="placeholder@gmail.com"){
		message:=this.utf8(message)
		parent:=this.cmtsha,url:=this.url "/repos/" this.owner "/" repo "/git/commits" this.token
		json={"message":"%message%","author":{"name": "%name%","email": "%email%"},"parents":["%parent%"],"tree":"%tree%"}
		return this.sha(this.Send("POST",url,json))
	}
	ref(repo,sha){
		url:=this.url "/repos/" this.owner "/" repo "/git/refs/heads/master" this.token
		this.http.Open("PATCH",url)
		json={"sha":"%sha%","force":true}
		this.http.send(json)
		SplashTextOff
		return this.http.status
	}
	Limit(){
		return this.Send("GET",this.url "/rate_limit" this.token)
	}
	CreateFile(repo,filefullpath,text,commit="First Commit",realname="Testing",email="Testing"){
		SplitPath,filefullpath,filename
		url:=this.url "/repos/" this.owner "/" repo "/contents/" filename this.token,file:=this.utf8(text)
		json={"message":"%commit%","committer":{"name":"%realname%","email":"%email%"},"content": "%file%"}
		this.http.Open("PUT",url),this.http.send(json),RegExMatch(this.http.ResponseText,"U)"Chr(34) "sha" Chr(34) ":(.*),",found)
	}
	utf8(info){
		info:=RegExReplace(info,"([" Chr(34) "\\])","\$1")
		for a,b in {"`n":"\n","`t":"\t","`r":""}
			StringReplace,info,info,%a%,%b%,All
		return info
	}
}
Gui(do:=""){
	static
	if (do="expandsettings")
		return TV_Modify(TreeView.settings,"Expand")
	Gui,+hwndmain
	Gui,Add,TreeView,w300 h400 gtree AltSubmit
	Gui,Add,Button,w300 gcontext Default,Context Sensitive Button
	Gui,Add,StatusBar,,Rate Limit
	TreeView:=[],repo:=[],hwnd(1,main),git:=new github()
	Gosub populate
	Gui,Show,,Upload Files To Repository
	return
	tree:
	ei:=A_EventInfo
	if !ei
		return
	if set:=treeview.set[ei]
		GuiControl,,Button1,% "Edit Repository Setting " github_user_info[treeview.set[ei]]
	else if(ei=TreeView.rep)
		GuiControl,,Button1,Refresh Repository List
	else if(TV_GetParent(ei)=TreeView.rep)
		GuiControl,,Button1,Refresh Repository
	else if(ei=TreeView.newrepo)
		GuiControl,,Button1,Add New Repositiory
	else if(ei=treeview.settings){
		exp:=TV_Get(ei,"Expand")?"Contract":"Expand"
		GuiControl,,Button1,%exp% Settings Info
	}else if(TreeView.files[ei]){
		GuiControl,,Button1,File Info
	}else if(TreeView.Help[ei]){
		m("Drag/Drop files here do upload them to the selected Repository")
	}
	return
	context:
	ControlGetText,do,Button1,% hwnd([1])
	if (do="refresh repository list")
		git.getrepos()
	else if InStr(do,"settings info"){
		exp:=TV_Get(TV_GetSelection(),"Expand")?"-Expand":"Expand",TV_Modify(TV_GetSelection(),exp)
		exp:=TV_Get(ei,"Expand")?"Contract":"Expand"
		GuiControl,,Button1,%exp% Settings Info
		return
	}else if(InStr(do,"Edit Repository Setting")){
		node:=settings.ssn("//github"),set:=treeview.set[TV_GetSelection()]
		InputBox,value,Value Required,% "Enter a value for " github_user_info[set],,,,,,,,% ssn(node,"@" set).text
		if !ErrorLevel
			node.SetAttribute(set,value),TV_Modify(TV_GetSelection(),"",github_user_info[set] " = " value)
		return
	}else if(do="Add New Repositiory"){
		InputBox,name,Enter the name of this repo,Name?
		git.CreateRepo(name),git.getrepos()
		Gosub populate
		return
	}else if(do="Refresh Repository"){
		GuiControl,1:-Redraw,SysTreeView321
		TV_GetText(repo,tt:=TV_GetSelection())
		sha:=git.getref(repo),info:=git.Send("GET",git.url "/repos/" git.owner "/" repo "/git/trees/" sha git.token "&recursive=1"),top:=repository.ssn("//repos/repo[@name='" repo "']")
		while,rt:=TV_GetChild(tt)
			TV_Delete(rt)
		for a,b in StrSplit(info,"{"){
			if InStr(b,"path"){
				pos:=1,ea:=[]
				while,pos:=RegExMatch(b,"OU)(.*):(.*),",out,pos)
					ea[Trim(out.1,Chr(34))]:=Trim(out.2,Chr(34)),pos:=out.Pos(2)+out.len(2)+1
				if !repository.ssn("//repo[@name='" repo "']/file[@path='" ea.path "']")
					repository.under({under:top,node:"file",att:{path:ea.path,mode:ea.mode,sha:ea.sha}})
				if (ea.mode!=040000)
					TreeView.files[TV_Add(ea.path,tt,"Sort")]:=ea.sha
			}
		}
		TV_Modify(tt,"Expand")
		GuiControl,1:+Redraw,SysTreeView321
	}else if((do="File Info")){
		TV_GetText(repo,TV_GetParent(TV_GetSelection()))
		json:=git.Send("GET",git.url "/repos/" git.owner "/" repo "/git/blobs/" TreeView.files[TV_GetSelection()] git.token)
		text:=git.find("content",json)
		if InStr(json,Chr(34) "base64" Chr(34)){
			StringReplace,string,text,\n,,all
			DllCall("Crypt32.dll\CryptStringToBinary","ptr",&string,"uint",StrLen(string),"uint",1,"ptr",0,"uint*",cp:=0,"ptr",0,"ptr",0) ;getsize
			VarSetCapacity(bin,cp)
			DllCall("Crypt32.dll\CryptStringToBinary","ptr",&string,"uint",StrLen(string),"uint",1,"ptr",&bin,"uint*",cp,"ptr",0,"ptr",0)
			text:=StrGet(&bin,cp,"utf-8")
		}
	}
	SB_SetText("Rate Limit = " git.http.getresponseheader("X-RateLimit-Remaining"),1)
	return
	populate:
	GuiControl,1:-Redraw,SysTreeView321
	repos:=repository.sn("//repos/repo")
	TV_Delete(),TreeView.rep:=TV_Add("Repositories")
	Loop,% repos.length{
		rr:=xml.ea(repos.item[A_Index-1]),parent:=TV_Add(rr.name,TreeView.rep),TreeView.repository[parent]:=rr.name
		ff:=sn(repos.item[A_Index-1],"*")
		while,f1:=ff.item[A_Index-1],ea:=xml.ea(f1){
			if (ea.mode!=040000)
				TreeView.files[TV_Add(ea.path,parent,"Sort")]:=ea.sha
		}
	}
	TreeView.newrepo:=TV_Add("Add New Repository")
	github_user_info:={owner:"Owner (GitHub Username)",email:"Email",name:"Your Full Name",token:"Token"},TreeView.settings:=TV_Add("Settings")
	ea:=settings.ea("//github")
	for a,b in StrSplit("owner,email,name",",")
		TreeView.set[TV_Add(github_user_info[b] " = " ea[b],TreeView.settings)]:=b
	TreeView.set[TV_Add("Github Token = " RegExReplace(ea.token,".","*"),TreeView.settings)]:="token"
	TreeView.Help[TV_Add("Help")]:=1
	TV_Modify(TreeView.rep,"Expand")
	GuiControl,1:+Redraw,SysTreeView321
	return
	GuiDropFiles:
	if !repo:=TreeView.repository[TV_GetSelection()]
		return m("Please select a repository to send the files to")
	for a,b in StrSplit(A_GuiEvent,"`n"){
		FileRead,bin,% "*c " b
		FileGetSize,size,%b%
		DllCall("Crypt32.dll\CryptBinaryToStringW",Ptr,&bin,UInt,size,UInt,1,UInt,0,UIntP,Bytes)
		VarSetCapacity(out,Bytes*2)
		DllCall("Crypt32.dll\CryptBinaryToStringW",Ptr,&bin,UInt,size,UInt,1,Str,out,UIntP,Bytes)
		StringReplace,out,out,`r`n,,All
		SplitPath,b,filename
		InputBox,message,Commit Message,Enter a quick message
		InputBox,filename,New Filename/directory,Directory/Filename,,,,,,,,%filename%
		ea:=settings.ea("//github")
		http:=ComObjCreate("WinHttp.WinHttpRequest.5.1")
		url:=git.url "/repos/" git.owner "/" repo "/contents/" filename git.token
		name:=git.name,email:=git.email
		json={"message":"%message%","committer":{"name":"%name%","email":"%email%"},"content":
		json.= Chr(34) out chr(34) "}"
		http.open("PUT",url)
		http.Send(json)
		m(Clipboard:=http.ResponseText)
	}
	return
}
hwnd(win,hwnd=""){
	static window:=[]
	if (win.rem){
		Gui,% win.rem ":Destroy"
		return window.remove(win.rem)
	}
	if IsObject(win)
		return "ahk_id" window[win.1]
	if !hwnd
		return window[win]
	window[win]:=hwnd
	return % "ahk_id" hwnd
}
testing(){
	/*
		addbutton()
		json={"content":{"name":"Hotkeys For Sharex.ahk","path":"Hotkeys For Sharex.ahk","sha":"6496c6c4c808501698913852dfa3a3edc23feaf6","size":93,"url":"https://api.github.com/repos/maestrith/new-test/contents/Hotkeys%20For%20Sharex.ahk?ref=","html_url":"https://github.com/maestrith/new-test/blob//Hotkeys%20For%20Sharex.ahk","git_url":"https://api.github.com/repos/maestrith/new-test/git/blobs/6496c6c4c808501698913852dfa3a3edc23feaf6","type":"file","_links":{"self":"https://api.github.com/repos/maestrith/new-test/contents/Hotkeys%20For%20Sharex.ahk?ref=","git":"https://api.github.com/repos/maestrith/new-test/git/blobs/6496c6c4c808501698913852dfa3a3edc23feaf6","html":"https://github.com/maestrith/new-test/blob//Hotkeys%20For%20Sharex.ahk"}},"commit":{"sha":"784ccfff3f05961dfff9e5cd31d98dbf7845b1ad","url":"https://api.github.com/repos/maestrith/new-test/git/commits/784ccfff3f05961dfff9e5cd31d98dbf7845b1ad","html_url":"https://github.com/maestrith/new-test/commit/784ccfff3f05961dfff9e5cd31d98dbf7845b1ad","author":{"name":"Chad Wilson","email":"maestrith@gmail.com","date":"2014-09-23T17:41:52Z"},"committer":{"name":"Chad Wilson","email":"maestrith@gmail.com","date":"2014-09-23T17:41:52Z"},"tree":{"sha":"9e9643351d9f49dbd8de8712651e1a41f12b0828","url":"https://api.github.com/repos/maestrith/new-test/git/trees/9e9643351d9f49dbd8de8712651e1a41f12b0828"},"message":"Upload Test","parents":[]}}
		m(git.find("sha",json),git.find("path",json),"mode=100644")
		git.Limit()
		m(git.http.getresponseheader("X-RateLimit-Remaining"))
	*/
}
;menu Github Repository
#NoTrayIcon
#NoEnv
#SingleInstance,Force
x:=Studio()
global settings,git,vversion,node,newwin,v,win,ControlList:={owner:"Owner (GitHub Username)",email:"Email",name:"Your Full Name",token:"API Token"},new,files
win:="Github_Repository",vversion:=x.get("vversion"),settings:=x.get("settings"),newwin:=new GUIKeep(win),files:=x.get("files")
Hotkey,IfWinActive,% newwin.id
for a,b in {"^Down":"Arrows","^Up":"Arrows","RButton":"RButton","~Delete":"Delete","F1":"compilever","F2":"clearver","F3":"wholelist"}
	Hotkey,%a%,%b%,On
newwin.add("Text,,&Versions:","TreeView,w360 h120 gtv AltSubmit,,w","Text,,Version &Information:","Edit,w360 h200 gedit vedit,,wh","ListView,w145 h200 geditgr AltSubmit NoSortHdr,Github Setting|Value,wy","ListView,x+0 w215 h200,Additional Files|Directory,xy","Button,xm gUpdate,&Update Release Info,y","Button,x+5 gcommit,Co&mmit,y","Button,x+5 gDelRep,Delete Repository,y","Button,xm gatf Default,&Add Text Files,y","Button,x+5 ghelp,&Help,y","Checkbox,x+5 vonefile gonefile " (check:=ssn(node(),"@onefile").text?"Checked":"") " ,Commit As &One File,y","Radio,xm,&Full Release,y","Radio,x+2 vprerelease Checked,&Pre-Release,y","Radio,x+2 vdraft,&Draft,y"),newwin.show("Github Repository")
PopVer(),git:=new Github()
return
editgr(){
	static
	global x
	if(A_GuiEvent="I"){
		default()
		Gui,%win%:ListView,SysListView321
		LV_GetText(value,LV_GetNext())
		if(value="Repository Name"){
			new:=new GUIKeep("Repository_Name",newwin.hwnd),controls:={repo:"Repository Name: (Required)",website:"Website URL: (Optional)",description:"Repository Description: (Optional)"}
			for a,b in controls
				new.Add("Text,," b),new.Add("Edit,w300 v" a "," ssn(node(),"@" a).text)
			new.Add("Button,gupdateinfo,Set Info"),new.Show("Repository Name")
			Gui,%win%:+Disabled
			MouseClick,Left,,,,,U
			return
			updateinfo:
			info:=New[]
			Gui,%win%:-Disabled
			if(info.repo="")
				return m("Repository name is required!")
			for a,b in info
				node().SetAttribute(a,a="repo"?RegExReplace(b,"\s","-"):b)
			Gui,Repository_Name:Destroy
			WinActivate,% newwin.id
			PopVer()
			return
		}
		for a,b in ControlList
			if(b=value)
				return Update_Github_Info(A_Index)
}}
Repository_Nameclose(){
	WinActivate,% newwin.id
	Gui,%win%:-Disabled
}
Repository_Nameescape(){
	Gui,Repository_Name:Destroy
	WinActivate,% newwin.id
	Gui,%win%:-Disabled
}
Github_RepositoryEscape(){
	WinClose,% newwin.id
	ExitApp
}
Help(){
	m("With the version treeview focused:`n`nRight Click to change a version number`nCtrl+Up/Down to increment versions`nF1 to build a version list (will be copied to your Clipboard)`nF2 to clear the list`nF3 to copy your entire list to the Clipboard`nPress Delete to remove a version")
}
OneFile(){
	info:=newwin[],node().SetAttribute("onefile",info.onefile)
}
atf(){
	global x
	main:=x.current(2).file
	SplitPath,main,,dir
	FileSelectFile,file,M,%dir%,Select A File to Add To This Repo Upload,*.ahk;*.xml
	if ErrorLevel
		return
	if(!extra:=ssn(node(),"files"))
		extra:=vversion.under(node(),"files")
	for a,b in StrSplit(file,"`n","`n"){
		if(A_Index=1)
			start:=b
		else if(!ssn(extra,"file[text()='" start "\" b "']"))
			vversion.under(extra,"file","",start "\" b)
	}PopVer()
}
DelRep(){
	global vversion
	MsgBox,276,Delete This Repository,THIS CAN NOT BE UNDONE! ARE YOU SURE
	IfMsgBox,Yes
	{
		if(git.repo="AHK-Studio")
			return m("NO! you can not.")
		info:=git.send("DELETE",git.url "/repos/" git.owner "/" git.repo git.token)
		if(InStr(git.http.status,204)){
			rem:=vversion.ssn("//info[@file='" ssn(node(),"@file").text "']"),rem.ParentNode.RemoveChild(rem),git.repo:=""
			FileRemoveDir,% A_ScriptDir "\github\" ea.repo,1
		}else
			m("Something went wrong","Please make sure that you have a repository named " ea.repo " on the Gethub servers")
		PopVer()
}}
Update_Github_Info(highlight:=1){
	global
	nw:=new GUIKeep("UGI",newwin.hwnd),ea:=settings.ea("//github")
	for a,b in ControlList
		nw.add("Text,xm," b),nw.Add("Edit,w300," ea[a])
	nw.add("Button,ggettoken,Get Token"),nw.show("Update Github Info")
	ControlFocus,Edit%highlight%,A
	ControlSend,Edit%highlight%,^a,A
	return
	gettoken:
	Run,https://github.com/settings/applications
	return
}
UGIEscape(){
	UGIClose()
}
UGIClose(){
	global nw
	if(!gh:=settings.ssn("//github"))
		settings.add("github")
	for a,b in ControlList{
		ControlGetText,value,Edit%A_Index%,% nw.id
		gh.SetAttribute(a,value)
	}
	Gui,ugi:Destroy
	PopVer()
	WinActivate,% newwin.id
} 
Commit(){
	global settings,x
	info:=newwin[],commitmsg:=info.edit,main:=file:=x.current(2).file,ea:=settings.ea("//github")
	if(!commitmsg)
		return m("Please select a commit message from the list of versions, or enter a commit message in the space provided")
	if(!(ea.name&&ea.email&&ea.token&&ea.owner))
		return update_github_info()
	if(!rep:=vversion.ssn("//*[@file='" file "']"))
		rep:=vversion.Add("info",,,1),rep.SetAttribute("file",file)
	repo:=ssn(rep,"@repo").text,delete:=[]
	if(!(repo))
		return m("Please setup a repo name in the GUI by clicking Repository Name:")
	SplitPath,main,upfn,dir
	extra:=sn(node(),"files/file"),current:=[]
	while,nn:=extra.item[A_Index-1].text
		current[RegExReplace(nn,"\Q" dir "\\E")]:=1
	mn:=files.ssn("//main[@file='" main "']"),path:=x.path() "\github\" repo,temp:=ComObjCreate("MSXML2.DOMDocument"),temp.setProperty("SelectionLanguage","XPath"),temp.loadxml(mn.xml)
	filelist:=sn(temp,"descendant::file[@github!='']")
	Loop,%path%\*.*,0,1
	{
		if(A_LoopFileExt=""||A_LoopFileExt="json")
			Continue
		file:=RegExReplace(A_LoopFileFullPath,"\Q" path "\\E")
		if(!ssn(mn,"//*[@github='" file "']"))
			delete[file]:=1,del:=1
	}
	if(del)
		git.Delete(repo,delete,path)
	if(!current_commit:=git.getref(repo)){
		git.CreateRepo(repo)
		Sleep,500
		current_commit:=git.getref(repo)
	}
	if(!FileExist(path))
		FileCreateDir,%path%
	safe:=[],uplist:=[],x.save(),all:=x.files("get"),localdir:=path
	if(info.onefile){
		filetext:=x.publish(1),openfile:=FileOpen(path "\" x.current(2).file,"rw","utf-8"),currenttext:=openfile.Read(openfile.length)
		if(filetext!=openfile)
			uplist[upfn]:={text:filetext,local:localdir "\" upfn,encoding:"utf-8"},up:=1
	}else{
		tick:=a_tickcount
		loop,% filelist.length{
			fl:=filelist.item[A_Index-1]
			tn:=fl.selectnodes("@*") ;,fea:=pea(fl),ff:=fea.file,gf:=fea.github
			while,ff:=tn.item[a_index-1]{
				nn:=ff.nodename
				%nn%:=ff.text
			}gf:=github,ff:=file
			text:=RegExReplace(All[ff],"\R","`r`n"),newfilepath:=path "\" gf,nfdir:=SubStr(newfilepath,1,InStr(newfilepath,"\",0,0,1)-1)
			if(!FileExist(nfdir))
				FileCreateDir,%nfdir%
			if(fl.haschildnodes()){
				check:=sn(fl,"descendant::*")
				while,ch:=check.item[A_Index-1],eaa:=ea(ch){
					if(eaa.github!=eaa.filename){
						if(eaa.include~="<|>")
							continue
						StringReplace,text,text,% eaa.include,% Chr(35) "Include " eaa.github
			}}}file:=FileOpen(newfilepath,0,"utf-8"),compare:=file.Read(file.length),file.Close()
			if(!(compare==text))
				uplist[RegExReplace(gf,"\\","/")]:={text:text,local:newfilepath,encoding:encoding},up:=1
	}}
	if(!up)
		return m("Nothing new to upload")
	upload:=[]
	for a,text in uplist{
		blob:=git.blob(repo,RegExReplace(text.text,Chr(59) "github_version",version))
		if(!blob){
			SplashTextOff
			return m("Error occured while uploading " text.local)
		}
		SplashTextOn,200,100,Updating,%a%
		upload[a]:=blob
	}
	tree:=git.Tree(repo,current_commit,upload),commit:=git.commit(repo,tree,current_commit,commitmsg,ea.name,ea.email),info:=git.ref(repo,commit)
	if(info=200){
		x.TrayTip("GitHub Update Complete")
		for a,b in uplist{
			local:=b.local,text:=b.text,encoding:=b.encoding
			FileDelete,%local%
			FileAppend,%text%,%local%,%encoding%
		}
		return 1
	}
	Else
		m("An Error Occured" ,commit)
	up:=""
}
Update(){
	info:=newwin[],TV_GetText(name,TV_GetSelection())
	/*
		;Fetch the release id for a given release
		;GET /repos/:owner/:repo/releases
		;check release list
		url:=git.url "/repos/" git.owner "/" git.repo "/releases" git.token,id:=git.find("id",git.send("GET",url)),ssn(node(),"descendant::version[@number='" name "']").SetAttribute("id",id),m(node().xml)
		return
	*/
	json:=git.json({tag_name:name,target_commitish:"master",name:name,body:git.utf8(info.edit),draft:info.draft,prerelease:info.prerelease})
	if(release:=ssn(node(),"descendant::*[@number='" name "']/@id").text){
		id:=git.find("id",msg:=git.send("PATCH",git.repourl() "releases/" release git.token,json))
		if(!id)
			m("Something happened",msg,release)
	}else{
		id:=git.find("id",git.send("POST",git.repourl() "releases" git.token,json))
		if(!id)
			return m("Something happened")
		ssn(node(),"descendant::version[@number='" name "']").SetAttribute("id",id)
	}
	vversion.save(1)
}
tv(){
	if(A_GuiEvent="S"){
		default(),cn:=ssn(node(),"descendant::version[@tv='" TV_GetSelection() "']")
		GuiControl,%win%:,Edit1,% cn.text
}}
default(){
	Gui,%win%:Default
}
PopVer(){
	Gui,%win%:Default
	for a,b in ["SysTreeView321","SysListView321","SysListView322"]
		GuiControl,%win%:-Redraw,%b%
	Gui,%win%:ListView,SysListView321
	all:=sn(mainnode:=node(),"descendant::version"),TV_Delete(),LV_Delete(),ea:=settings.ea("//github")
	while,aa:=all.item[A_Index-1]
		aa.SetAttribute("tv",TV_Add(ssn(aa,"@number").text))
	if(tv:=ssn(node(),"descendant::*[@select=1]/@tv").text){
		TV_Modify(tv,"Select Vis Focus")
		GuiControl,%win%:+Redraw,SysTreeView321
		TV_Modify(tv,"Select Vis Focus")
	}else
		TV_Modify(TV_GetChild(0),"Select Vis Focus")
	while,rem:=ssn(mainnode,"descendant::*[@select=1]")
		rem.RemoveAttribute("select")
	for a,b in ControlList
		LV_Add("",b,a="token"?RegExReplace(ea[a],".","*"):ea[a])
	LV_Add("","Repository Name",ssn(node(),"@repo").text)
	Loop,2
		LV_ModifyCol(A_Index,"AutoHDR")
	Gui,%win%:ListView,SysListView322
	extra:=sn(node(),"files/file"),LV_Delete()
	while,ee:=extra.item[A_Index-1].text{
		SplitPath,ee,file,dir
		LV_Add("",file,dir)
	}
	LV_ModifyCol(1,"AutoHDR")
	for a,b in ["SysTreeView321","SysListView321","SysListView322"]
		GuiControl,%win%:+Redraw,%b%
}
node(){
	global x
	if(!node:=vversion.ssn("//info[@file='" x.call("current","2").file "']"))
		node:=vversion.under(vversion.ssn("//*"),"info"),node.SetAttribute("file",x.call("current","2").file),top:=vversion.under(node,"versions"),next:=vversion.under(top,"version"),next.SetAttribute("number",1)
	return node
}
Arrows(){
	default(),TV_GetText(vers,TV_GetSelection()),ver:=StrSplit(vers,"."),version:="",current:=ssn(node(),"descendant::version[@number='" vers "']"),last:=ver[ver.MaxIndex()]
	for a,b in ver
		if(a!=ver.MaxIndex())
			build.=b "."
	if(A_ThisHotkey="^Up"){
		if(next:=current.previoussibling)
			return TV_Modify(next.SelectSingleNode("@tv").text,"Select Vis Focus")
		build.=last+1,parent:=current.ParentNode,new:=vversion.under(parent,"version"),new.SetAttribute("number",build),new.SetAttribute("select",1),parent.InsertBefore(new,current),PopVer()
	}else{
		if(next:=current.nextsibling)
			return TV_Modify(next.SelectSingleNode("@tv").text,"Select Vis Focus")
		if(last-1<0)
			return m("Minor versions can not go below 0","Right Click to change the major version")
		build.=last-1,parent:=current.ParentNode,new:=vversion.under(parent,"version"),new.SetAttribute("number",build),new.SetAttribute("select",1),PopVer()
}}
Add(vers){
	if(nn:=ssn(node:=node(),"descendant::version[@number='" vers "']"))
		return nn
	list:=sn(node,"versions/version"),root:=ssn(node,"versions"),newnode:=vversion.under(root,"version"),newnode.SetAttribute("number",vers)
	while,ll:=list.item[A_Index-1],ea:=xml.ea(ll){
		if(vers>ea.number){
			root.insertbefore(newnode,ll),PopVer()
			Break
	}}
	return node
}
verhelp(){
	m("Right Click to change a version number`nCtrl+Up/Down to increment versions`nF1 to build a version list (will be copied to your Clipboard)`nF2 to clear the list`nF3 to copy your entire list to the Clipboard`nPress Delete to remove a version")
}
compilever:
default(),TV_GetText(ver,TV_GetSelection())
WinGetPos,,,w,,% newwin.ahkid
nn:=ssn(node(),"descendant::*[@number='" ver "']"),number:=settings.ea(nn).number,text:=nn.text,vertext:=number&&text?number "`r`n" text:""
if(vertext){
	Clipboard.=vertext "`r`n"
	ToolTip,%Clipboard%,%w%,0,2
}else
	m("Add some text")
return
clearver:
clipboard:=""
ToolTip,,,,2
return
wholelist:
list:=sn(node,"versions/version")
Clipboard:=""
while,ll:=list.item[A_Index-1]
	Clipboard.=ssn(ll,"@number").text "`r`n" Trim(ll.text,"`r`n") "`r`n"
m("Version list copied to your clipboard.","","",Clipboard)
return
RButton(){
	default(),cn:=ssn(node(),"descendant::version[@tv='" TV_GetSelection() "']")
	InputBox,nv,Enter a new version number,New Version Number,,,,,,,,% ssn(cn,"@number").text
	if(ErrorLevel||nv="")
		return
	cn.SetAttribute("number",nv),PopVer()
}
edit(){
	default(),info:=newwin[],cn:=ssn(node(),"descendant::version[@tv='" TV_GetSelection() "']"),cn.text:=info.edit
}
Class Github{
	static url:="https://api.github.com",http:=[]
	__New(){
		ea:=settings.ea("//github")
		if(!(ea.owner&&ea.token))
			return m("Please setup your Github info")
		this.http:=ComObjCreate("WinHttp.WinHttpRequest.5.1")
		if proxy:=settings.ssn("//proxy").text
			http.setProxy(2,proxy)
		for a,b in ea:=ea(settings.ssn("//github"))
			this[a]:=b
		this.token:="?access_token=" ea.token,this.owner:=ea.owner,this.tok:="&access_token=" ea.token,this.repo:=ssn(node(),"@repo").text,this.baseurl:=this.url "/repos/" this.owner "/" this.repo "/"
		return this
	}
	json(info){
		for a,b in info
			json.=chr(34) a Chr(34) ":" (b="true"||b=1?"true":b=""||b="false"||b="0"?"false":Chr(34) b Chr(34)) ","
		return "{" Trim(json,",") "}"
	}
	repourl(){
		return this.url "/repos/" this.owner "/" this.repo "/"
	}
	delete(repo,filenames,deletepath){
		url:=this.url "/repos/" this.owner "/" repo "/commits" this.token,tree:=this.sha(this.Send("GET",url)),url:=this.url "/repos/" this.owner "/" repo "/git/trees/" tree "?recursive=1" this.tok,info:=this.Send("GET",url),fz:=[],info:=SubStr(info,InStr(info,"tree" Chr(34)))
		for a,b in strsplit(info,"{"){
			if(path:=this.find("path",b))
				fz[path]:=this.find("sha",b)
		}
		for c in filenames{
			StringReplace,cc,c,\,/,All
			url:=this.url "/repos/" this.owner "/" repo "/contents/" cc this.token,sha:=fz[cc]
			if(!sha){
				FileDelete,%deletepath%\%c%
				Continue
			}
			json={"message":"Deleted","sha":"%sha%"}
			this.http.Open("DELETE",url),this.http.send(json)
			if(this.http.status!=200){
				m("Error deleting " c,this.http.ResponseText)
				Continue
			}
			FileDelete,%deletepath%\%c%
	}}
	find(search,text){
		RegExMatch(text,"U)" Chr(34) search Chr(34) ":(.*),",found)
		return Trim(found1,Chr(34))
	}
	sha(text){
		RegExMatch(this.http.ResponseText,"U)" Chr(34) "sha" Chr(34) ":(.*),",found)
		return Trim(found1,Chr(34))
	}
	gettree(value:=""){
		info:=this.send("GET",this.url "/repos/" this.owner "/" this.repo "/git/trees/" this.getref(this.repo) this.token)
		if(value){
			temp:=new xml("tree")
			top:=temp.ssn("//tree")
			info:=SubStr(info,InStr(info,Chr(34) "tree" Chr(34))),pos:=1
			while,RegExMatch(info,"OU){(.*)}",found,pos){
				new:=temp.under(top,"node")
				for a,b in StrSplit(found.1,",")
					in:=StrSplit(b,":",Chr(34)),new.SetAttribute(in.1,in.2)
				pos:=found.pos(1)+found.len(1)
			}
			temp.Transform(2)
		}
		return temp
	}
	getref(repo){
		url:=this.url "/repos/" this.owner "/" repo "/git/refs/heads/master" this.token,this.cmtsha:=this.sha(this.Send("GET",url)),url:=this.url "/repos/" this.owner "/" repo "/commits/" this.cmtsha this.token,RegExMatch(this.Send("GET",url),"U)tree.:\{.sha.:.(.*)" Chr(34),found)
		return found1
	}
	blob(repo,text){
		url:=this.url "/repos/" this.owner "/" repo "/git/blobs" this.token,text:=encode(text)
		json={"content":"%text%","encoding":"base64"}
		return this.sha(this.Send("POST",url,json))
	}
	send(verb,url,data=""){
		this.http.Open(verb,url),this.http.send(data)
		return this.http.ResponseText
	}
	tree(repo,parent,blobs){
		url:=this.url "/repos/" this.owner "/" repo "/git/trees" this.token
		if(parent)
			json={"base_tree":"%parent%","tree":[
		else
			json={"tree":[
		for a,blob in blobs{
			add={"path":"%a%","mode":"100644","type":"blob","sha":"%blob%"},
			json.=add
		}
		return this.sha(this.Send("POST",url,Trim(json,",") "]}"))
	}
	commit(repo,tree,parent,message="Updated the file",name="placeholder",email="placeholder@gmail.com"){
		message:=this.utf8(message),parent:=this.cmtsha,url:=this.url "/repos/" this.owner "/" repo "/git/commits" this.token
		json={"message":"%message%","author":{"name": "%name%","email": "%email%"},"parents":["%parent%"],"tree":"%tree%"}
		return this.sha(this.Send("POST",url,json))
	}
	ref(repo,sha){
		url:=this.url "/repos/" this.owner "/" repo "/git/refs/heads/master" this.token,this.http.Open("PATCH",url)
		json={"sha":"%sha%","force":true}
		this.http.send(json)
		SplashTextOff
		return this.http.status
	}
	Limit(){
		url:=this.url "/rate_limit" this.token,this.http.Open("GET",url),this.http.Send()
		m(this.http.ResponseText)
	}
	CreateRepo(name,description="",homepage="",private="false",issues="true",wiki="true",downloads="true"){
		url:=this.url "/user/repos" this.token
		for a,b in {homepage:this.utf8(homepage),description:this.utf8(description)}
			if(b!=""){
				aa="%a%":"%b%",
				add.=aa
			}
		json={"name":"%name%",%add%"private":%private%,"has_issues":%issues%,"has_wiki":%wiki%,"has_downloads":%downloads%,"auto_init":true}
		this.Send("POST",url,json)
	}
	CreateFile(repo,filefullpath,text,commit="First Commit",realname="Testing",email="Testing"){
		SplitPath,filefullpath,filename
		url:=this.url "/repos/" this.owner "/" repo "/contents/" filename this.token,file:=this.utf8(text)
		json={"message":"%commit%","committer":{"name":"%realname%","email":"%email%"},"content": "%file%"}
		this.http.Open("PUT",url),this.http.send(json),RegExMatch(this.http.ResponseText,"U)"Chr(34) "sha" Chr(34) ":(.*),",found)
	}
	utf8(info){
		info:=RegExReplace(info,"([" Chr(34) "\\])","\$1")
		for a,b in {"`n":"\n","`t":"\t","`r":"\r"}
			StringReplace,info,info,%a%,%b%,All
		return info
}}
encode(text){
	if text=""
		return
	cp:=0,VarSetCapacity(rawdata,StrPut(text,"utf-8")),sz:=StrPut(text,&rawdata,"utf-8")-1,DllCall("Crypt32.dll\CryptBinaryToString","ptr",&rawdata,"uint",sz,"uint",0x40000001,"ptr",0,"uint*",cp),VarSetCapacity(str,cp*(A_IsUnicode?2:1)),DllCall("Crypt32.dll\CryptBinaryToString","ptr",&rawdata,"uint",sz,"uint",0x40000001,"str",str,"uint*",cp)
	return str
}
delete(){
	ControlGetFocus,Focus,% newwin.id
	if(Focus="SysTreeView321"){
		default(),cn:=ssn(node(),"descendant::version[@tv='" TV_GetSelection() "']")
		select:=cn.nextsibling?cn.nextsibling:cn.previoussibling?cn.previoussibling:""
		if(select)
			select.SetAttribute("select",1)
		cn.ParentNode.RemoveChild(cn),PopVer()
	}
}
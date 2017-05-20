#SingleInstance,Force
;menu Github Repository
#NoTrayIcon
#NoEnv
x:=Studio(),x.Save() ;dxml:=new XML()
global settings,git,vversion:=x.Get("vversion"),node,NewWin,v,win,ControlList:={owner:"Owner (GitHub Username)",email:"Email",name:"Your Full Name",token:"API Token"},new,files,dxml
win:="Github_Repository",settings:=x.Get("settings"),NewWin:=new GUIKeep(win),files:=x.Get("files"),v:=x.Get("v"),node:=Node()
Hotkey,IfWinActive,% NewWin.id
for a,b in {"^Down":"Arrows","RButton":"RButton","^Up":"Arrows","~Delete":"Delete","F1":"compilever","F2":"clearver","F3":"wholelist"}
	Hotkey,%a%,%b%,On
NewWin.Add("Text,Section,Versions:","Text,x162 ys,Branches:","TreeView,xm w160 h120 gtv AltSubmit section","Treeview,x+M ys w198 h120,,w"
		,"Text,xm,Version &Information:","Edit,w360 h200 gedit vedit,,wh","Radio,xm,&Full Release,y","Radio,x+2 vprerelease Checked,&Pre-Release,y"
		,"Radio,x+2 vdraft,&Draft,y","ListView,xm w145 h200 geditgr AltSubmit NoSortHdr,Github Setting|Value,wy"
		,"ListView,x+m w215 h200,Additional Files|Directory,xy","Button,xm gUpdate,&Update Release Info,y","Button,x+5 gcommit,Co&mmit,y"
		,"Button,x+5 gDelRep,Delete Repository,y","Button,xm gatf Default,&Add Text Files,y","Button,x+5 ghelp,&Help,y","Button,x+M gRefreshBranch,&Refresh Branch,y"
		,"Button,xm gNewBranch,New &Branch,y","Button,x+M greleases,Update Releases,y","Button,x+M gUpdateReadme,Update Readm&e.md,y","Checkbox,xm+3 h23 vonefile gonefile " (check:=SSN(Node(),"@onefile").text?"Checked":"") " ,Commit As &One File,y"
		,"DDL,x+M w200 vbranch gonebranch,,y","StatusBar")
git:=new Github(),SB_SetText("Remaining API Calls: Will update when you make a call to the API"),PopVer(),PopBranch()
NewWin.Show("Github Repository")
Gui,%win%:+MinSize800x600
node:=dxml.SSN("//branch[@name='" git.branch "']")
if(SN(node,"*[@sha]").length!=SN(node,"*").length)
	git.TreeSha()
/*
	DELETE /repos/:USER/:REPO/git/refs/heads/:BRANCH
	response: 204 on success
*/
return
Add(vers){
	if(nn:=SSN(node:=Node(),"descendant::version[@number='" vers "']"))
		return nn
	list:=SN(node,"versions/version"),root:=SSN(node,"versions"),newnode:=vversion.under(root,"version"),newnode.SetAttribute("number",vers)
	while,ll:=list.item[A_Index-1],ea:=xml.ea(ll){
		if(vers>ea.number){
			root.insertbefore(newnode,ll),PopVer()
			Break
	}}
	return node
}
Arrows(){
	Default("SysTreeView321"),TV_GetText(vers,TV_GetSelection()),ver:=StrSplit(vers,"."),version:="",current:=SSN(Node(),"descendant::version[@number='" vers "']"),last:=ver[ver.MaxIndex()]
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
		build.=last-1,parent:=current.ParentNode,new:=vversion.Under(parent,"version"),new.SetAttribute("number",build),new.SetAttribute("select",1),PopVer()
}}
atf(){
	global x
	main:=x.current(2).file
	SplitPath,main,,dir
	FileSelectFile,file,M,%dir%,Select A File to Add To This Repo Upload,*.ahk;*.xml
	if(ErrorLevel)
		return
	if(!extra:=SSN(Node(),"files"))
		extra:=vversion.under(Node(),"files")
	for a,b in StrSplit(file,"`n","`n"){
		if(A_Index=1)
			start:=b
		else if(!SSN(extra,"file[text()='" start "\" b "']"))
			vversion.under(extra,"file","",start "\" b)
	}PopVer()
}
Default(Control:="SysListView321"){
	Type:=InStr(Control,"SysListView32")?"Listview":"Treeview"
	Gui,%win%:Default
	Gui,%win%:%Type%,%Control%
}
Delete(){
	static
	ControlGetFocus,Focus,% newwin.id
	if(Focus="SysTreeView321"){
		Default(),cn:=SSN(Node(),"descendant::version[@tv='" TV_GetSelection() "']")
		select:=cn.nextsibling?cn.nextsibling:cn.previoussibling?cn.previoussibling:""
		if(select)
			select.SetAttribute("select",1)
		cn.ParentNode.RemoveChild(cn),PopVer()
	}if(focus="SysListView322"){
		Default("SysListView322"),LV_GetText(file,LV_GetNext()),LV_GetText(dir,LV_GetNext(),2),remfile:=dir "\" file,nn:=SSN(Node(),"descendant::files/file[text()='" remfile "']"),dn:=dxml.SSN("//branch[@name='" git.branch "']"),rem:=SSN(dn,"descendant::file[@fullpath='" remfile "']"),ea:=ea(rem),delete:=[],delete[ea.file]:=rem,(info:=(git.Delete(delete)).status=200)?(rem.ParentNode.RemoveChild(rem),nn.ParentNode.RemoveChild(nn),PopVer(),dxml.save(1)):m("something went wrong",info.ResponseText)
	}
}
DelRep(){
	global vversion
	if(m("title:Delete This Repository","THIS CAN NOT BE UNDONE! ARE YOU SURE?","ico:!","btn:ync","def:2")="YES"){
		if(git.repo="AHK-Studio")
			return m("NO! you can not.")
		info:=git.Send("DELETE",git.RepoURL())
		if(InStr(git.http.status,204)){
			rem:=vversion.SSN("//info[@file='" SSN(Node(),"@file").text "']"),rem.ParentNode.RemoveChild(rem),git.repo:=""
			FileRemoveDir,% A_ScriptDir "\github\" ea.repo,1
		}else
			m("Something went wrong","Please make sure that you have a repository named " ea.repo " on the Gethub servers")
		PopVer()
}}
Edit(){
	Default("SysTreeView321"),info:=newwin[],cn:=SSN(Node(),"descendant::version[@tv='" TV_GetSelection() "']"),cn.text:=info.edit
}
;#Include editgr.ahk
Encode(text){
	if(text="")
		return
	cp:=0,VarSetCapacity(rawdata,StrPut(text,"UTF-8")),sz:=StrPut(text,&rawdata,"UTF-8")-1,DllCall("Crypt32.dll\CryptBinaryToString","ptr",&rawdata,"uint",sz,"uint",0x40000001,"ptr",0,"uint*",cp),VarSetCapacity(str,cp*(A_IsUnicode?2:1)),DllCall("Crypt32.dll\CryptBinaryToString","ptr",&rawdata,"uint",sz,"uint",0x40000001,"str",str,"uint*",cp)
	return str
}
Help(){
	m("With the version treeview focused:`n`nRight Click to change a version number`nCtrl+Up/Down to increment versions`nF1 to build a version list (will be copied to your Clipboard)`nF2 to clear the list`nF3 to copy your entire list to the Clipboard`nPress Delete to remove a version`n`nDrag/Drop additional files you want to upload to the window`n`nCommit As One File:`n`nThe Edit next to it is for a branch if you want it to have its own branch.`nThis is for if you want to have a multi-file Repository AND a single file Repository")
}
Node(){
	global x
	if(!node:=vversion.SSN("//info[@file='" x.Current(2).file "']"))
		node:=vversion.Under(vversion.SSN("//*"),"info"),node.SetAttribute("file",x.Current(2).file)
	if(!SSN(node,"descendant::versions/version")){
		if(!Version:=SSN(node,"versions"))
			Version:=vversion.Under(node,"versions")
		vversion.Under(Version,"version").SetAttribute("number",1)
	}
	return node
}
OneFile(){
	info:=newwin[],Node().SetAttribute("onefile",info.onefile),dxml.SSN("//branch[@name='" git.branch "']/file").RemoveAttribute("time")
}
PopBranch(x:=0){
	Default("SysTreeView322")
	GuiControl,%win%:-Redraw,SysTreeView322
	tvlist:=[],select:=SSN(Node(),"@branch").text
	bl:=dxml.SN("//branch"),TV_Delete()
	while(bb:=bl.item[A_Index-1],ea:=XML.EA(bb))
		(A_Index=1)?(tvlist[ea.name]:=TV_Add(ea.name)):(tvlist[ea.name]:=TV_Add(ea.name,tvlist["master"],"Vis")),ddllist.=ea.name "|"
	GuiControl,%win%:,ComboBox1,|%ddllist%
	GuiControl,%win%:ChooseString,ComboBox1,% (ob:=SSN(Node(),"@onebranch").text)?ob:"master"
	GuiControl,%win%:+Redraw,SysTreeView322
	TV_Modify(tvlist[select?select:"master"],"Select Vis Focus")
}
PopVer(){
	static InfoList:=[]
	Default("SysTreeView321")
	for a,b in ["SysTreeView321","SysTreeView322","SysListView321","SysListView322"]
		GuiControl,%win%:-Redraw,%b%
	Gui,%win%:ListView,SysListView321
	all:=SN(mainnode:=Node(),"descendant::version"),TV_Delete(),LV_Delete(),ea:=settings.ea("//github")
	while,aa:=all.item[A_Index-1]
		aa.SetAttribute("tv",TV_Add(SSN(aa,"@number").text))
	if(tv:=SSN(Node(),"descendant::*[@select=1]/@tv").text){
		TV_Modify(tv,"Select Vis Focus")
		GuiControl,%win%:+Redraw,SysTreeView321
		TV_Modify(tv,"Select Vis Focus")
	}else
		TV_Modify(TV_GetChild(0),"Select Vis Focus")
	while,rem:=SSN(mainnode,"descendant::*[@select=1]")
		rem.RemoveAttribute("select")
	for a,b in ControlList
		InfoList[LV_Add("",b,a="token"?RegExReplace(ea[a],".","*"):ea[a])]:=a
	for a,b in [["repo","Repository Name: (Required)"],["website","Website URL: (Optional)"],["description","Repository Description: (Optional)"]]
		InfoList[LV_Add("",b.2,SSN(Node(),"@" b.1).text)]:=b.1
	Loop,2
		LV_ModifyCol(A_Index,"AutoHDR")
	Gui,%win%:ListView,SysListView322
	extra:=SN(Node(),"files/file"),LV_Delete()
	while,ee:=extra.item[A_Index-1].text{
		SplitPath,ee,file,dir
		LV_Add("",file,dir)
	}
	LV_ModifyCol(1,"AutoHDR")
	for a,b in ["SysTreeView321","SysTreeView322","SysListView321","SysListView322"]{
		GuiControl,%win%:+Redraw,%b%
	}
	Default("SysListView321"),LV_Modify(1,"Select Vis Focus")
	return
	EditGR:
	if(A_GuiEvent~="i)(Normal)"){
		Default("SysListView321")
		Value:=InfoList[LV_GetNext()],LV_GetText(Input,LV_GetNext())
		if(Value~="i)(email|name|owner|token)"){
			if(!Settings.SSN("//github/@" Value))
				Settings.Add("github").SetAttribute(Value,"")
			CurrentValue:=(CurrentNode:=Settings.SSN("//github/@" Value)).text
		}else if(Value~="i)\b(repo|description|website)\b"){
			if(!SSN(Node(),"@" Value))
				Node().SetAttribute(Value,"")
			CurrentValue:=(CurrentNode:=SSN(Node(),"@" Value)).text
		}
		/*
			if(CurrentValue&&Value="repo")
				return m("This value can not be changed once it is set")
		*/
		InputBox,Output,Enter Value,% "Please enter a value for " Input (Value="repo"?"`n`nWARNING!: The Repository Name can not be changed`nOnce you set it`n`nAll spaces will be replaced with '-'":""),% (Value="token"?"Hide":""),,% (Value="repo"?220:150),,,,,%CurrentValue%
		if(ErrorLevel||Output="")
			return
		if(Value="repo"){
			Output:=RegExReplace(Output,"\s","-"),Node().SetAttribute("repo",Output),git.repo:=Output,git.Refresh()
			git.Send("GET",git.RepoURL())
			if(git.http.status!=200){
				data:=git.CreateRepo(git.repo,git.description,git.website)
				for a,b in {id:"\x22id\x22:(\d+)",created_at:"",updated_at:"",pushed_at:""}
					RegExMatch(data,(b?b:"U)\x22" a "\x22:\x22(.*)\x22"),Found),TopNode:=dxml.Add("Repository/Data").SetAttribute(a,Found1)
			}else{
				releases:=git.Send("GET",git.RepoURL("releases"))
				if(git.http.status=200)
					UpdateReleases(releases)
			}UpdateBranches()
		}else if(Value="website"){
			CurrentNode.text:=Output
			if(git.repo)
				git.Send("PATCH",git.RepoURL(),git.json({name:git.repo,homepage:Output}))
		}else if(Value="description"){
			CurrentNode.text:=Output
			if(git.repo)
				git.Send("PATCH",git.RepoURL(),git.json({name:git.repo,description:Output}))
		}else
			CurrentNode.text:=Output
		git.Refresh(),PopVer(),PopBranch()
	}
	return
}
RButton(){
	Default("SysTreeView321"),cn:=SSN(Node(),"descendant::version[@tv='" TV_GetSelection() "']")
	InputBox,nv,Enter a new version number,New Version Number,,,,,,,,% SSN(cn,"@number").text
	if(ErrorLevel||nv="")
		return
	cn.SetAttribute("number",nv),PopVer()
}
RefreshBranch(){
	global git
	git.TreeSha(),PopBranch(1)
}
tv(){
	if(A_GuiEvent="S"){
		Default("SysTreeView321"),cn:=SSN(Node(),"descendant::version[@tv='" TV_GetSelection() "']")
		GuiControl,%win%:,Edit1,% text(cn.text)
}}
Update(){
	Default("SysTreeView321")
	info:=newwin[],TV_GetText(name,TV_GetSelection())
	/*
		;Fetch the release id for a given release
		;GET /repos/:owner/:repo/releases
		;check release list
		url:=git.url "/repos/" git.owner "/" git.repo "/releases" git.token,id:=git.find("id",git.send("GET",url)),SSN(Node(),"descendant::version[@number='" name "']").SetAttribute("id",id),m(Node().xml)
		return
	*/
	json:=git.json({tag_name:name,target_commitish:"master",name:name,body:git.UTF8(info.edit),draft:info.draft?"true":"false",prerelease:info.prerelease?"true":"false"})
	if(release:=SSN(Node(),"descendant::*[@number='" name "']/@id").text){
		id:=git.Find("id",msg:=git.Send("PATCH",git.RepoURL("releases/" release),json))
		if(!id)
			m("Something happened",msg,release)
	}else{
		id:=git.Find("id",info:=git.send("POST",git.repourl("releases"),json))
		if(!id)
			return m("Something happened",info)
		SSN(Node(),"descendant::version[@number='" name "']").SetAttribute("id",id)
	}
	vversion.Save(1)
}
UpdateBranches(){
	global git
	root:=dxml.SSN("//*"),pos:=1
	if(!dxml.SSN("//branch[@name='master']"))
		dxml.Under(root,"branch",{name:"master"})
	info:=git.Send("GET",git.RepoURL("git/refs/heads")),List:=[]
	while(RegExMatch(info,"OUi)\x22ref\x22:\x22(.*)\x22",Found,pos),pos:=Found.Pos(1)+Found.len(1)){
		List[item:=StrSplit(Found.1,"/").Pop()]:=1
		if(!dxml.SSN("//branch[@name='" item "']"))
			dxml.Under(root,"branch",{name:item})
	}blist:=dxml.SN("//branch")
	while(bl:=blist.item[A_Index-1],ea:=XML.EA(bl))
		if(!List[ea.name])
			bl.ParentNode.RemoveChild(bl)
	info:=git.Send("GET",git.RepoURL("releases")),pos:=1,top:=SSN(node,"descendant::versions")
	while,RegExMatch(info,"OU).*\{\x22url\x22\s*:\s*\x22(.*)\x22.*\x22tag_name\x22\s*:\s*\x22(.*)\x22",Found,pos),pos:=Found.Pos(1)+Found.len(1){
		id:=StrSplit(Found.1,"/").Pop()
		if(!next:=SSN(Node(),"descendant::version[@number='" Found.2 "']"))
			next:=vversion.Under(top,"version")
		next.text:=RegExReplace(git.Find("body",(foo:=git.Send("GET",git.RepoURL("releases/" id)))),"\R|\\n|\\r",Chr(127)),next.SetAttribute("number",Found.2),next.SetAttribute("id",id)
	}dxml.Save(1),PopVer(),PopBranch()
}
verhelp(){
	m("Right Click to change a version number`nCtrl+Up/Down to increment versions`nF1 to build a version list (will be copied to your Clipboard)`nF2 to clear the list`nF3 to copy your entire list to the Clipboard`nPress Delete to remove a version")
}
DropFiles(a,b,c,d){
	under:=Node()
	if(!top:=SSN(under,"files"))
		top:=vversion.under(under,"files")
	for c,d in a
		vversion.under(top,"file",,d)
	PopVer()
}
Text(text){
	return RegExReplace(text,"\x7f","`r`n")
}
NewBranch(){
	InputBox,branch,Enter a new branch,Branch Name?,,,150
	if(ErrorLevel||branch="")
		return
	branch:=RegExReplace(branch," ","-"),info:=git.Send("POST",git.baseurl "git/refs" git.token,git.json({"ref":"refs/heads/" branch,"sha":git.sha(git.Send("GET",git.baseurl "git/refs/heads/" git.branch git.token))}))
	if(git.http.status!=201)
		return m(info,git.http.status)
	UpdateBranches()
}
Class Github{
	static url:="https://api.github.com",http:=[]
	__New(){
		ea:=Settings.EA("//github")
		if(!(ea.owner&&ea.token))
			return m("Please setup your Github info")
		this.http:=ComObjCreate("WinHttp.WinHttpRequest.5.1")
		if(proxy:=Settings.SSN("//proxy").text)
			http.setProxy(2,proxy)
		for a,b in ea:=ea(Settings.SSN("//github"))
			this[a]:=b
		this.repo:=SSN(Node(),"@repo").text,this.token:="?access_token=" ea.token,this.owner:=ea.owner,this.tok:="&access_token=" ea.token,this.repo:=SSN(Node(),"@repo").text,this.baseurl:=this.url "/repos/" this.owner "/" this.repo "/",this.Refresh()
		return this
	}
	Blob(repo,text,skip:=""){
		if(!skip)
			text:=Encode(text)
		json={"content":"%text%","encoding":"base64"}
		return this.Sha(this.Send("POST",this.url "/repos/" this.owner "/" repo "/git/blobs" this.token,json))
	}
	Commit(repo,tree,parent,message="Updated the file",name="placeholder",email="placeholder@gmail.com"){
		message:=this.UTF8(message),parent:=this.cmtsha,url:=this.url "/repos/" this.owner "/" repo "/git/commits" this.token
		json={"message":"%message%","author":{"name": "%name%","email": "%email%"},"parents":["%parent%"],"tree":"%tree%"}
		return this.Sha(this.Send("POST",url,json))
	}
	CreateFile(repo,filefullpath,text,commit="First Commit",realname="Testing",email="Testing"){
		SplitPath,filefullpath,filename
		url:=this.url "/repos/" this.owner "/" repo "/contents/" filename this.token,file:=this.utf8(text)
		json={"message":"%commit%","committer":{"name":"%realname%","email":"%email%"},"content": "%file%"}
		this.http.Open("PUT",url),this.http.send(json),RegExMatch(this.http.ResponseText,"U)"Chr(34) "sha" Chr(34) ":(.*),",found)
	}
	CreateRepo(name,description="",homepage="",private="false",issues="true",wiki="true",downloads="true"){
		url:=this.url "/user/repos" this.token
		for a,b in {homepage:this.UTF8(homepage),description:this.UTF8(description)}
			if(b!=""){
				aa="%a%":"%b%",
				add.=aa
			}
		json={"name":"%name%",%add% "private":%private%,"has_issues":%issues%,"has_wiki":%wiki%,"has_downloads":%downloads%,"auto_init":true}
		return this.Send("POST",url,json)
	}
	Delete(filenames){
		node:=dxml.SSN("//branch[@name='" this.branch "']")
		if(SN(node,"*[@sha]").length!=SN(node,"*").length)
			this.treesha()
		for c,d in filenames{
			StringReplace,cc,c,\,/,All
			url:=this.url "/repos/" this.owner "/" this.repo "/contents/" cc this.token,sha:=SSN(node,"descendant::*[@file='" c "']/@sha").text
			if(!sha)
				Continue
			this.http.Open("DELETE",url),this.http.send(this.json({"message":"Deleted","sha":sha,"branch":this.branch}))
			d.ParentNode.RemoveChild(d)
			return this.http
	}}
	Find(search,text){
		RegExMatch(text,"UOi)\x22" search "\x22\s*:\s*(.*)[,|\}]",found)
		return Trim(found.1,Chr(34))
	}
	GetTree(value:=""){
		info:=this.Send("GET",this.url "/repos/" this.owner "/" this.repo "/git/trees/" this.GetRef() this.token)
		if(value){
			temp:=new XML("tree"),top:=temp.SSN("//tree"),info:=SubStr(info,InStr(info,Chr(34) "tree" Chr(34))),pos:=1
			while,RegExMatch(info,"OU){(.*)}",found,pos){
				new:=temp.under(top,"node")
				for a,b in StrSplit(found.1,",")
					in:=StrSplit(b,":",Chr(34)),new.SetAttribute(in.1,in.2)
				pos:=found.pos(1)+found.len(1)
			}temp.Transform(2)
		}return temp
	}
	GetRef(){
		this.cmtsha:=this.Sha(this.Send("GET",this.RepoURL("git/refs/heads/" this.branch)))
		RegExMatch(this.Send("GET",this.RepoURL("commits/" this.cmtsha)),"U)tree.:\{.sha.:.(.*)" Chr(34),found)
		return found1
	}
	json(info){
		for a,b in info
			json.=Chr(34) a Chr(34) ":" (b="true"?"true":b="false"?"false":Chr(34) b Chr(34)) ","
		return "{" Trim(json,",") "}"
	}
	Limit(){
		url:=this.url "/rate_limit" this.token,this.http.Open("GET",url),this.http.Send()
		m(this.http.ResponseText)
	}
	Ref(repo,sha){
		url:=this.url "/repos/" this.owner "/" repo "/git/refs/heads/" this.branch this.token,this.http.Open("PATCH",url)
		json={"sha":"%sha%","force":true}
		this.http.send(json)
		SplashTextOff
		return this.http.status
	}
	Refresh(){
		global x
		this.repo:=SSN(Node(),"@repo").text
		if(this.repo){
			if(!FileExist(x.Path() "\Github"))
				FileCreateDir,% x.Path() "\Github"
			dxml:=new XML(this.repo,x.Path() "\Github\" this.repo ".xml")
			branch:=SSN(Node(),"@branch").text,this.branch:=branch?branch:"master"
			dxml.Save(1)
		}
	}
	RepoURL(Path:="",Extra:=""){
		return this.baseurl:=this.url "/repos/" this.owner "/" this.repo (Path?"/" Path:"") this.token Extra
	}
	Send(verb,url,data=""){
		this.http.Open(verb,url),this.http.Send(data),SB_SetText("Remaining API Calls: " this.remain:=this.http.GetResponseHeader("X-RateLimit-Remaining"))
		return this.http.ResponseText
	}
	Sha(text){
		RegExMatch(this.http.ResponseText,"U)\x22sha\x22:(.*),",found)
		return Trim(found1,Chr(34))
	}
	Tree(repo,parent,blobs){
		url:=this.url "/repos/" this.owner "/" repo "/git/trees" this.token,open:="{"
		if(parent)
			json=%open% "base_tree":"%parent%","tree":[
		else
			json=%open% "tree":[
		for a,blob in blobs{
			add={"path":"%a%","mode":"100644","type":"blob","sha":"%blob%"},
			json.=add
		}
		return this.Sha(info:=this.Send("POST",url,Trim(json,",") "]}"))
	}
	TreeSha(){
		node:=dxml.SSN("//branch[@name='" this.branch "']"),url:=this.url "/repos/" this.owner "/" this.repo "/commits/" this.branch this.token,tree:=this.Sha(this.Send("GET",url)),url:=this.url "/repos/" this.owner "/" this.repo "/git/trees/" tree this.token "&recursive=1",info:=this.Send("GET",url),info:=SubStr(info,InStr(info,"tree" Chr(34)))
		for a,b in StrSplit(info,"{")
			if(path:=this.Find("path",b)){
				if(this.Find("mode",b)!="100644"||path="readme.md"||path=".gitignore")
					Continue
				StringReplace,path,path,/,\,All
				if(!nn:=SSN(node,"descendant::*[@file='" path "']"))
					nn:=dxml.Under(node,"file",{file:path})
				nn.SetAttribute("sha",this.Find("sha",b))
	}}
	UTF8(info){
		info:=RegExReplace(info,"([" Chr(34) "\\])","\$1")
		for a,b in {"`n":"\n","`t":"\t","`r":"\r"}
			StringReplace,info,info,%a%,%b%,All
		return info
	}
}
Commit(){
	global settings,x
	info:=newwin[],CommitMsg:=info.Edit,Current:=main:=file:=x.Current(2).file,ea:=settings.EA("//github"),Delete:=[],Path:=x.Path() "\github\" git.repo,Default("SysTreeView321"),TV_GetText(Version,TV_GetSelection())
	if(!CommitMsg)
		return m("Please select a commit message from the list of versions, or enter a commit message in the space provided")
	if(!(ea.name&&ea.email&&ea.token&&ea.owner))
		return m("Please make sure that you have set your Github information")
	if(!vversion.Find("//@file",file))
		vversion.Add("info",,,1).SetAttribute("file",file)
	if(!FileExist(Path "\github"))
		FileCreateDir,% x.Path() "\Github"
	if(!(git.repo))
		return m("Please setup a repo name in the GUI by clicking Repository Name:")
	temp:=new XML("temp"),temp.XML.LoadXML(files.Find("//main/@file",Current).xml),Default("SysTreeView322"),TV_GetText(branch,TV_GetSelection()),Default("SysTreeView321"),git.branch:=branch,list:=SN(Node(),"files/*"),mainfile:=Current
	if(!git.branch)
		return m("Please select the branch you wish to update.")
	if(!top:=dxml.SSN("//branch[@name='" git.branch "']"))
		top:=dxml.Under(dxml.SSN("//*"),"branch",{name:git.branch})
	if(info.OneFile){
		SplitPath,Current,FileName
		file:=FileOpen(Path "\" FileName,"RW",ea.encoding),text:=file.Read(file.length)
		if(!FileExist(Path))
			FileCreateDir,%Path%
		if((NewText:=x.Publish(1))==text)
			return m("Nothing new to upload"),file.Close()
		if(!current_commit:=git.GetRef())
			git.CreateRepo(git.repo),current_commit:=git.GetRef()
		Upload:=[]
		WinSetTitle,% NewWin.ID,,Uploading: %FileName%
		NewText:=NewText?NewText:";Blank File",Blob:=git.Blob(git.repo,RegExReplace(NewText,Chr(59) "github_version",version),text.skip)
		if(!Blob)
			return m("Error uploading " FileName)
		Upload[FileName]:=Blob,tree:=git.Tree(git.repo,current_commit,Upload),commit:=git.Commit(git.repo,tree,current_commit,CommitMsg,git.name,git.email),info:=git.Ref(git.repo,commit)
		if(info=200)
			file.Seek(0),file.Write(NewText),file.Length(file.Position),file.Close(),dxml.Save(1),x.TrayTip("GitHub Update Complete"),Update()
		else
			m(info),file.Close()
		WinSetTitle,% NewWin.ID,,GitHub Repository
		return
	}top:=dxml.SSN("//branch[@name='" branch "']"),all:=temp.SN("//file"),Uploads:=[]
	while(aa:=all.item[A_Index-1],ea:=XML.EA(aa)){
		fn:=ea.file,GitHubFile:=ea.github?ea.github:ea.filename
		SplitPath,fn,FileName
		if(!ii:=dxml.Find(top,"descendant::file/@file",GithubFile))
			ii:=dxml.Under(top,"file",{file:GithubFile})
		FileGetTime,time,%fn%
		if(SSN(ii,"@time").text!=time){
			Add:=1
			file:=FileOpen(fn,"RW",ea.encoding),file.Seek(0),text:=file.Read(file.length),file.Close()
			/*
				file:=FileOpen(GithubFile,"RW",ea.encoding),file.Seek(0),file.Write(text),file.Length(file.Position),file.Close()
			*/
			Uploads[RegExReplace(GithubFile,"\\","/")]:={text:text,time:time,node:ii}
	}}all:=SN(Node(),"files/file")
	while(aa:=all.item[A_Index-1],ea:=XML.EA(aa)){
		fn:=aa.text
		FileGetTime,time,%fn%
		if(ea.time!=time){
			SplitPath,fn,filename
			Uploads[RegExReplace((ea.folder?Trim(ea.folder,"\") "\":"") filename,"\\","/")]:=EncodeFile(fn,time,aa)
	}}
	for a,b in Uploads{
		Finish:=1
		Break
	}if(!finish)
		return m("Nothing to upload")
	if(!current_commit:=git.GetRef())
		git.CreateRepo(git.repo),current_commit:=git.GetRef()
	Store:=[],Upload:=[]
	for a,b in Uploads{
		WinSetTitle,% newwin.id,,Uploading: %a%
		NewText:=b.text?b.text:";Blank File"
		if((blob:=Store[a])=""||b.force){
			Store[a]:=blob:=git.Blob(git.repo,RegExReplace(NewText,Chr(59) "github_version",version),b.skip)
			if(!blob)
				return m("Error occured while uploading " text.local)
			Sleep,250
		}
		Upload[a]:=blob
	}tree:=git.Tree(git.repo,current_commit,upload),commit:=git.Commit(git.repo,tree,current_commit,CommitMsg,git.name,git.email),info:=git.ref(git.repo,commit)
	if(info=200){
		top:=dxml.SSN("//branch[@name='" git.branch "']")
		for a,b in Uploads
			b.node.SetAttribute("time",b.time),b.node.SetAttribute("sha",Upload[a])
		dxml.save(1),x.TrayTip("GitHub Update Complete"),update()
	}Else
		m("An Error Occured" ,commit)
	WinSetTitle,% NewWin.ID,,Github Repository
	return
}
UpdateReleases(releases){
	pos:=1,node:=Node()
	while(RegExMatch(releases,"OU)\x22id\x22:(\d+)\D.*\x22name\x22:\x22(.*)\x22.*\x22body\x22:\x22(.*)\x22\}",found,pos)),pos:=found.Pos(1)+20{
		if(!SSN(node,"versions/version[@number='" found.2 "']")){
			new:=vversion.Under(SSN(node,"descendant::versions"),"version",,RegExReplace(found.3,"\\n",Chr(127)))
			for a,b in {number:found.2,id:found.1}
				new.SetAttribute(a,b)
		}
	}
}
clearver:
clipboard:=""
ToolTip,,,,2
return
wholelist:
list:=SN(node,"versions/version")
Clipboard:=""
while,ll:=list.item[A_Index-1]
	Clipboard.=SSN(ll,"@number").text "`r`n" Trim(ll.text,"`r`n") "`r`n"
m("Version list copied to your clipboard.","","",Clipboard)
return
compilever:
Default("SysTreeView321"),TV_GetText(ver,TV_GetSelection())
WinGetPos,,,w,,% newwin.ahkid
info:=newwin[],text:=info.edit
vertext:=ver&&text?ver "`r`n" text:""
if(vertext){
	Clipboard.=vertext "`r`n"
	ToolTip,%Clipboard%,%w%,0,2
}else
	m("Add some text")
return
Decode(string){ ;original http://www.autohotkey.com/forum/viewtopic.php?p=238120#238120
	if(string="")
		return
	string:=RegExReplace(string,"\R|\\r|\\n")
	DllCall("Crypt32.dll\CryptStringToBinary","ptr",&string,"uint",StrLen(string),"uint",1,"ptr",0,"uint*",cp:=0,"ptr",0,"ptr",0),VarSetCapacity(bin,cp),DllCall("Crypt32.dll\CryptStringToBinary","ptr",&string,"uint",StrLen(string),"uint",1,"ptr",&bin,"uint*",cp,"ptr",0,"ptr",0)
	return StrGet(&bin,cp,"UTF-8")
}
Releases(){
	UpdateReleases(git.Send("GET",git.BaseURL "releases"))
}
OneBranch(){
	Node().SetAttribute("onebranch",NewWin[].branch)
}
Github_RepositoryClose:
Github_RepositoryEscape:
Default("SysTreeView322"),TV_GetText(branch,TV_GetSelection()),Node().SetAttribute("branch",branch),dxml.Save(1),NewWin.Exit()
WinClose,% NewWin.id
ExitApp
EncodeFile(fn,time,nn){
	FileRead,bin,*c %fn%
	FileGetSize,size,%fn%
	DllCall("Crypt32.dll\CryptBinaryToStringW",Ptr,&bin,UInt,size,UInt,1,UInt,0,UIntP,Bytes),VarSetCapacity(out,Bytes*2),DllCall("Crypt32.dll\CryptBinaryToStringW",Ptr,&bin,UInt,size,UInt,1,Str,out,UIntP,Bytes)
	StringReplace,out,out,`r`n,,All
	return {text:out,encoding:"UTF-8",time:time,skip:1,node:nn}
}
UpdateReadme(){
	static
	Default("SysTreeView322"),TV_GetText(Branch,TV_GetSelection())
	if(!Branch)
		return m("Please Select The Branch To Update")
	info:=git.Send("GET",git.RepoURL("contents/README.md","&ref=" Branch),{ref:Branch,path:"README.md"}),sha:=git.Sha(info),Contents:=git.Find("content",info)
	Gui,EditReadme:Destroy
	Gui,EditReadme:Default
	Gui,Add,Edit,w800 h600 vReadMeEdit,% Decode(Contents)
	Gui,Add,Button,gReadMeUpdate,Update
	Gui,Show,,Edit Readme.md
	return
	ReadMeUpdate:
	Gui,EditReadme:Submit,Nohide
	hmm:=git.Send("PUT",git.RepoURL("contents/README.md"),git.json({path:"README.md",message:"Updating the README.md file",content:Encode(ReadMeEdit),sha:sha,branch:branch}))
	if(git.http.status=200){
		EditReadmeGuiEscape:
		EditReadmeGuiClose:
		KeyWait,Escape,U
		Gui,EditReadme:Destroy
		return
	}else
		return m(git.http.status,hmm)
}
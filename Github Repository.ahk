#SingleInstance,Force
;menu Github Repository
/*
	have a "download then update" the xml for the plugin list
	pull the whole repo list of shas but only use the one that matches the name of the project
*/
#NoTrayIcon
#NoEnv
x:=Studio(),x.Save() ;dxml:=new XML()
global settings,git,vversion,NewWin,v,win,ControlList:={owner:"Owner (GitHub Username)",email:"Email",name:"Your Full Name",token:"API Token"},new,files,dxml
win:="Github_Repository",settings:=x.Get("settings"),NewWin:=new GUIKeep(win),files:=x.Get("files"),v:=x.Get("v"),vversion:=new XML("github",x.Path() "\lib\Github.xml")
Hotkey,IfWinActive,% NewWin.id
for a,b in {"^Down":"Arrows","^Up":"Arrows","~Delete":"Delete","F1":"CompileVer","F2":"ClearVer","F3":"WholeList","^!u":"UpdateBranches"}
	Hotkey,%a%,%b%,On
NewWin.Add("Text,Section,Branches:","Text,x+140,Version &Information:"
		,"TreeView,xm w200 h200 gtv AltSubmit section,,h","Edit,x+M w400 h200 gedit vedit,,wh"
		,"Radio,xm h23 vfullrelease gUpdateRelease,&Full Release,y","Radio,x+M h23 vprerelease Checked gUpdateRelease,&Pre-Release,y","Radio,x+M h23 vdraft gUpdateRelease,&Draft,y","Checkbox,x+M h23 vonefile gonefile " (check:=SSN(Node(),"@onefile").text?"Checked":"") " ,Commit As &One File,y"
		,"ListView,xm w450 h200 geditgr AltSubmit NoSortHdr,Github Setting|Value,y","ListView,x+m w150 h200,Additional Files (Folder)|Directory,yw"
		,"Button,xm gUpdate,&Update Release Info,y"
		,"Button,x+M gcommit,Co&mmit,y"
		,"Button,x+M gDelRep,Delete Repository,y"
		,"Button,xm gAdd_Files Default,&Add Files,y"
		,"Button,x+M ghelp,&Help,y"
		,"Button,x+M gRefreshBranch,&Refresh Branch,y"
		,"Button,xm gNewBranch,New &Branch,y"
		,"Button,x+M greleases,Update Releases,y"
		,"Button,x+M gUpdateReadme,Update Readm&e.md,y"
		,"StatusBar")
git:=new Github(),node:=git.Node(),SB_SetText("Remaining API Calls: Will update when you make a call to the API"),PopVer()
NewWin.Show("Github Repository")
Gui,%win%:+MinSize800x600
node:=dxml.Find("//branch/@name",git.Branch())
if(SN(node,"*[@sha]").length!=SN(node,"*").length)
	git.TreeSha()
git.GetRef()
/*
	UpdateBranches()
	FIX!{
		everything Node needs to be re-evaluated.
		test all the things.
		Delete() needs fixed so that you can't delete the last version
		if the branch is selected and delete
			DON'T DELETE THE BRANCH!
	}
*/
/*
	DELETE /repos/:USER/:REPO/git/refs/heads/:BRANCH
	response: 204 on success
*/
return
/*
	GuiContextMenu(a*){ ;}GuiHwnd,Control,EventInfo,IsRightClick,x,y){
		return m(Control)
		Default("SysTreeView321"),cn:=SSN(Node(),"descendant::version[@tv='" TV_GetSelection() "']")
		InputBox,nv,Enter a new version number,New Version Number,,,,,,,,% SSN(cn,"@name").text
		if(ErrorLevel||nv="")
			return
		cn.SetAttribute("number",nv),PopVer()
	}
*/
Add_Files(){
	global x
	main:=x.Current(2).file
	SplitPath,main,,dir
	FileSelectFile,file,M,%dir%,Select A File to Add To This Repo Upload,*.ahk;*.xml
	if(ErrorLevel)
		return
	list:=[]
	for a,b in StrSplit(file,"`n"){
		if(A_Index=1)
			Dir:=b
		else
			list.Push(Dir "\" b)
	}DropFiles(list)
}
Arrows(){
	Default("SysTreeView321"),node:=vversion.SSN("//*[@tv='" TV_GetSelection() "']")
	ver:=StrSplit(SSN(node,"@name").text,"."),version:=""
	last:=ver[ver.MaxIndex()]
	for a,b in ver
		if(a!=ver.MaxIndex())
			build.=b "."
	if(A_ThisHotkey="^Up"){
		if(next:=node.previoussibling)
			return TV_Modify(next.SelectSingleNode("@tv").text,"Select Vis Focus")
		build.=Format("{:0" StrLen(last) "}",last+1),new:=vversion.Under(node.ParentNode,"version"),new.SetAttribute("name",build),new.SetAttribute("select",1),node.ParentNode.InsertBefore(new,node),PopVer()
	}else{
		if(next:=node.nextsibling)
			return TV_Modify(next.SelectSingleNode("@tv").text,"Select Vis Focus")
		if(last-1<0)
			return m("Minor versions can not go below 0","Right Click to change the major version")
		build.=Format("{:0" StrLen(last) "}",last-1),new:=vversion.Under(node.ParentNode,"version"),new.SetAttribute("name",build),new.SetAttribute("select",1),PopVer()
}}
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
	}Branch(){
		Default("SysTreeView321")
		return vversion.SSN("//*[@tv='" TV_GetSelection() "']/ancestor-or-self::branch/@name").text
	}
	Blob(repo,text,skip:=""){
		if(!skip)
			text:=Encode(text)
		json={"content":"%text%","encoding":"base64"}
		return this.Sha(this.Send("POST",this.url "/repos/" this.owner "/" repo "/git/blobs" this.token,json))
	}
	Commit(repo,tree,parent,message:="Updated the file",name:="placeholder",email:="placeholder@gmail.com"){
		message:=this.UTF8(message),parent:=this.cmtsha,url:=this.url "/repos/" this.owner "/" repo "/git/commits" this.token
		json={"message":"%message%","author":{"name": "%name%","email": "%email%"},"parents":["%parent%"],"tree":"%tree%"}
		sha:=this.Sha(info:=this.Send("POST",url,json))
		Clipboard:=url "`n" json "`n`n" tree "`n" parent
		return sha
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
		node:=dxml.Find("//branch/@name",this.Branch())
		if(SN(node,"*[@sha]").length!=SN(node,"*").length)
			this.TreeSha()
		for c,d in filenames{
			StringReplace,cc,c,\,/,All
			url:=this.url "/repos/" this.owner "/" this.repo "/contents/" cc this.token,sha:=SSN(node,"descendant::*[@file='" c "']/@sha").text
			if(!sha)
				Continue
			this.http.Open("DELETE",url),this.http.send(this.json({"message":"Deleted","sha":sha,"branch":this.Branch()}))
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
		this.cmtsha:=this.Sha(info:=this.Send("GET",this.RepoURL("git/refs/heads/" this.branch())))
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
	}Node(){
		global x
		if(!node:=vversion.SSN("//info[@file='" x.Current(2).file "']"))
			node:=vversion.Under(vversion.SSN("//*"),"info"),node.SetAttribute("file",x.Current(2).file)
		if(git.repo){
			if(!SSN(node,"descendant::branch[@name='master']"))
				UpdateBranches()
		}
		return node
	}
	Ref(repo,sha){
		url:=this.url "/repos/" this.owner "/" repo "/git/refs/heads/" this.Branch() this.token,this.http.Open("PATCH",url)
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
			branch:=SSN(Node(),"@branch").text
			dxml.Save(1)
		}
	}
	RepoURL(Path:="",Extra:=""){
		return this.baseurl:=this.url "/repos/" this.owner "/" this.repo (Path?"/" Path:"") this.token Extra
	}
	Send(verb,url,data=""){
		this.http.Open(verb,url),this.http.Send(IsObject(data)?this.json(data):data),SB_SetText("Remaining API Calls: " this.remain:=this.http.GetResponseHeader("X-RateLimit-Remaining"))
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
	/*
		Tree(repo,parent,blobs){
			;url:=this.RepoURL("git/trees"),open:="{"
			url:=this.url "/repos/" this.owner "/" repo "/git/trees" this.token,open:="{"
			if(parent)
				json=%open% "base_tree":"%parent%","tree":[
			else
				json=%open% "tree":[
			for a,blob in blobs{
				add={"path":"%a%","mode":"100644","type":"blob","sha":"%blob%"},
				json.=add
			}
			sha:=this.Sha(info:=this.Send("POST",url,Trim(json,",") "]}"))
			return sha
		}
	*/
	TreeSha(){
		node:=dxml.Find("//branch/@name",this.Branch()),url:=this.url "/repos/" this.owner "/" this.repo "/commits/" this.Branch() this.token,tree:=this.Sha(this.Send("GET",url)),url:=this.url "/repos/" this.owner "/" this.repo "/git/trees/" tree this.token "&recursive=1",info:=this.Send("GET",url),info:=SubStr(info,InStr(info,"tree" Chr(34)))
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
ClearVer(){
	clipboard:=""
	ToolTip,,,,2
	return
}
Commit(){
	global settings,x
	if(!git.repo)
		return m("Please setup a repo name in the GUI by clicking Repository Name:")
	if(!vversion.EA("//*[@tv='" TV_GetSelection() "']").name)
		return m("Please select a version")
	info:=newwin[],CommitMsg:=info.Edit,Current:=main:=file:=x.Current(2).file,ea:=settings.EA("//github"),Delete:=[],Path:=x.Path() "\Github\" git.repo,Default("SysTreeView321"),TV_GetText(Version,TV_GetSelection())
	if(!CommitMsg)
		return m("Please select a commit message from the list of versions, or enter a commit message in the space provided")
	if(!(ea.name&&ea.email&&ea.token&&ea.owner))
		return m("Please make sure that you have set your Github information")
	if(!vversion.Find("//@file",file))
		vversion.Add("info",,,1).SetAttribute("file",file)
	if(!FileExist(x.Path() "\github"))
		FileCreateDir,% x.Path() "\Github"
	temp:=new XML("temp"),temp.XML.LoadXML(files.Find("//main/@file",Current).xml),Default("SysTreeView321"),list:=SN(Node(),"files/*"),mainfile:=Current,Branch:=git.Branch(),Uploads:=[]
	if(!Branch)
		return m("Please select the branch you wish to update.")
	if(!top:=dxml.Find("//branch/@name",Branch))
		top:=dxml.Under(dxml.SSN("//*"),"branch",{name:Branch})
	DeleteList:=[]
	Default("SysTreeView321"),node:=vversion.SSN("//*[@tv='" TV_GetSelection() "']/ancestor-or-self::branch"),AllFiles:=SN(node,"descendant::files/file|ancestor::info/files/file")
	while(aa:=AllFiles.item[A_Index-1],ea:=XML.EA(aa))
		if(ea.sha)
			DeleteList[ea.file]:={node:aa,ea:ea}
	all:=SN(top,"descendant::file")
	while(aa:=all.item[A_Index-1],ea:=XML.EA(aa))
		if(ea.sha)
			DeleteList[ea.file]:={node:aa,ea:ea}
	SplitPath,Current,FileName,,,NNE
	if(!FileExist(Path))
		FileCreateDir,%Path%
	if(info.OneFile){
		OOF:=FileOpen(Path "\" FileName,"RW",ea.encoding),text:=OOF.Read(OOF.Length)
		PublishText:=x.Publish(1)
		if(!(PublishText==text))
			Uploads[FileName]:={text:PublishText,time:time,local:Path "\" Filename}
	}else{
		all:=temp.SN("//file")
		while(aa:=all.item[A_Index-1],ea:=XML.EA(aa)){
			fn:=ea.file,GitHubFile:=ea.github?ea.github:ea.filename
			SplitPath,fn,FileName
			if(!ii:=dxml.Find(top,"descendant::file/@file",GithubFile))
				ii:=dxml.Under(top,"file",{file:GithubFile})
			FileGetTime,time,%fn%
			DeleteList.Delete(GithubFile)
			if(SSN(ii,"@time").text!=time){
				file:=FileOpen(fn,"RW",ea.encoding),file.Seek(0),text:=file.Read(file.length),file.Close()
				Uploads[RegExReplace(GithubFile,"\\","/")]:={text:text,time:time,node:ii,local:ea.file}
	}}}
	/*
		files:
		AHKStudio.ico
		SciLexer.dll
		lib{
			Commands.xml
			Help Menu.xml
		}
	*/
	/*
		also add the folder to the DeleteList[folder "\" filename]
	*/
	for a,b in DeleteList
		llist.=a "`n"
	while(aa:=AllFiles.item[A_Index-1],ea:=XML.EA(aa)){
		fn:=ea.filepath
		FileGetTime,time,%fn%
		DeleteList.Delete(ea.file)
		;#[Working Here]
		/*
			m(aa.xml,ea.folder,ea.file,"","",llist)
		*/
		if(ea.time!=time||!ea.sha){
			branch:=(name:=SSN(aa,"ancestor-or-self::branch/@name").text)?name:"master"
			SplitPath,fn,filename
			Uploads[(ea.folder?ea.folder "/":"") ea.file]:=EncodeFile(fn,time,aa,branch)
	}}
	for a,b in Uploads
		DeleteList.Delete(a),Finish:=1
	/*
		save the WholeList(1) to a new file when done in the github directory under the folder with the name of the project
		check against that file before adding the below
	*/
	VersionText:=WholeList(1),VTObject:=FileOpen(Path "\" NNE ".text","RW"),CheckVersionText:=VTObject.Read(VTObject.Length)
	if(!(VersionText==CheckVersionText))
		Uploads[NNE ".text"]:={text:VersionText},VTObject.Seek(0),VTObject.Write(VersionText),VTObject.Length(VTObject.Position)
	VTObject.Close()
	/*
		/save the WholeList(1) to a new file when done in the github directory under the folder with the name of the project
		check against that file before adding the above
	*/
	if(!finish){
		if(IsObject(OOF))
			OOF.Close()
		return m("Nothing to upload")
	}
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
	}
	tree:=git.Tree(git.repo,current_commit,upload),commit:=git.Commit(git.repo,tree,current_commit,CommitMsg,git.name,git.email),info:=git.Ref(git.repo,commit)
	if(info=200){
		top:=dxml.Find("//branch/@name",Branch)
		for a,b in Uploads{
			if(b.node)
				b.node.SetAttribute("time",b.time),b.node.SetAttribute("sha",Upload[a])
		}if(IsObject(OOF))
			OOF.Seek(0),OOF.Write(PublishText),OOF.Length(OOF.Position),OOF.Close()
		DeleteExtraFiles(DeleteList)
		dxml.Save(1),x.TrayTip("GitHub Update Complete"),Update()
	}Else
		m("An Error Occured" ,commit)
	WinSetTitle,% NewWin.ID,,Github Repository
	return
}
CompileVer(){
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
}
Decode(string){ ;original http://www.autohotkey.com/forum/viewtopic.php?p=238120#238120
	if(string="")
		return
	string:=RegExReplace(string,"\R|\\r|\\n")
	DllCall("Crypt32.dll\CryptStringToBinary","ptr",&string,"uint",StrLen(string),"uint",1,"ptr",0,"uint*",cp:=0,"ptr",0,"ptr",0),VarSetCapacity(bin,cp),DllCall("Crypt32.dll\CryptStringToBinary","ptr",&string,"uint",StrLen(string),"uint",1,"ptr",&bin,"uint*",cp,"ptr",0,"ptr",0)
	return StrGet(&bin,cp,"UTF-8")
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
		Default(),cn:=vversion.SSN("//*[@tv='" TV_GetSelection() "']")
		if(cn.NodeName="branch"){
			return m("Currently I am unable to remove Branches from a Github Repository")
		}else if(cn.NodeName="version"){
			if(SN(cn.ParentNode,"version").length=1)
				return m("You can not remove the last version.  Please right click this version to rename it")
			select:=cn.nextsibling?cn.nextsibling:cn.previoussibling?cn.previoussibling:""
			if(select)
				select.SetAttribute("select",1)
			cn.ParentNode.RemoveChild(cn),PopVer()
		}
	}if(focus="SysListView322"){
		Default("SysListView322"),LV_GetText(file,LV_GetNext(),2)
		while(node:=vversion.Find("//file/@filepath",file,1),ea:=XML.EA(node)){
			if(!ea.sha){
				node.ParentNode.RemoveChild(node)
				Continue
			}
			SplitPath,file,filename
			(path:=(ea.folder?ea.folder "/" filename:filename))
			/*
				GET /repos/:owner/:repo/contents/:path
				Name		Type		Description
				path		string	Required. The content path.
				message	string	Required. The commit message.
				sha		string	Required. The blob SHA of the file being replaced.
				branch	string	The branch name. Default: the repository’s default branch (usually master)
			*/
			Branch:=(Branch:=SSN(node,"ancestor-or-self::branch/@name").text)?Branch:"master"
			git.Send("DELETE",git.RepoURL("contents/" (ea.folder?ea.folder "/":"") ea.file),{path:(ea.folder?ea.folder "/":"") ea.file,message:"No longer needed",sha:ea.sha,branch:Branch})
			if(git.http.status!=200)
				return m("Error removing file","Status: " git.http.status,"Response: " git.http.ResponseText)
			else
				node.ParentNode.RemoveChild(node)
		}
		tv(1)
	}
}
DeleteExtraFiles(DeleteList){
	static
	DL:=DeleteList
	Gui,Delete:Destroy
	Gui,Delete:Default
	Gui,Add,Text,,Some of these items are still on Github and do not appear to be in your Project
	Gui,Add,ListView,w800 h500 Checked,Delete Files
	Gui,Add,Button,gDeleteChecked,Delete Checked
	for a,b in DeleteList
		LV_Add("",b.ea.file)
	Gui,Show
	return
	DeleteChecked:
	for a,b in DL
		total.=a " - " b.ea.sha "`n"
	m("Coming Soon:",total),total:=""
	return
	DeleteGuiEscape:
	DeleteGuiClose:
	KeyWait,Escape,U
	Gui,Delete:Destroy
	return
	/*
			;make a GUI that has the files in DeleteList and ask if the user wants to remove them from Github
		for a,b in DeleteList{
			ea:=b.ea
			branch:=(name:=SSN(b.node,"ancestor-or-self::branch/@name").text)?name:"master"
			git.Send("DELETE",git.RepoURL("contents/" (ea.folder?ea.folder "/":"") ea.file),{path:(ea.folder?ea.folder "/":"") ea.file,message:"No longer needed",sha:ea.sha,branch:Branch})
			if(git.http.status!=200)
				m(git.http.status,b.node.xml,git.http.ResponseText)
			else
				b.node.ParentNode.RemoveChild(b.node)
		}
	*/
	
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
DropFiles(a,b:="",c:="",d:=""){
	global x
	Default("SysTreeView321"),node:=vversion.SSN("//*[@tv='" TV_GetSelection() "']"),ProjectFile:=x.Current(2).file
	SplitPath,ProjectFile,,Dir
	/*
		ret:=m("Add " (a.MaxIndex()=1?"this":"these") " " a.MaxIndex() " file" (a.MaxIndex()=1?"":"s") " to the overall project?","Yes=All Branches","No=Only the " SSN(node,"ancestor-or-self::branch/@name").text " Branch","btn:ync")
	*/
	under:=vversion.SSN("//*[@tv='" TV_GetSelection() "']/ancestor-or-self::branch")
	if(!top:=SSN(under,"files"))
		top:=vversion.Under(under,"files")
	for c,d in a{
		SplitPath,d,filename,AddDir
		/*
			m(AddDir,Dir)
			Continue
		*/
		VarSetCapacity(NewDir,32)
		foo:=DllCall("Shlwapi\PathRelativePathTo",ptr,&NewDir,str,ProjectFile,int,0,str,d,int,0)
		/*
			if .\then path
				it is fine to just use that path
			if ..\then path
				put it all in lib
			  ;#[Drop Path]
		*/
		/*
			Loop,Files,%Dir%\%filename%,R
				m(A_LoopFileFullPath)
		*/
		/*
			if(InStr(AddDir,Dir))
				folder:=RegExReplace(AddDir,"\Q" Dir "\E")
			else
				folder:="lib"
		*/
		nd:=StrGet(&NewDir)
		if(SubStr(nd,1,2)=".\"){
			folder:=SubStr(nd,3)
			SplitPath,folder,,folder
		}else
			folder:="lib"
		if(!vversion.Find(top,"descendant::file/@filepath",d)&&!vversion.Find(top,"ancestor::info/files/file/@filepath",d))
			folder:=RegExReplace(Trim(folder,"\"),"\\","/"),vversion.Under(top,"file",{file:filename,filepath:d,folder:folder})
	}
	tv(1)
}
Edit(){
	Default("SysTreeView321"),info:=newwin[],cn:=vversion.SSN("//*[@tv='" TV_GetSelection() "']"),cn.text:=info.edit
}
Encode(text){
	if(text="")
		return
	cp:=0,VarSetCapacity(rawdata,StrPut(text,"UTF-8")),sz:=StrPut(text,&rawdata,"UTF-8")-1,DllCall("Crypt32.dll\CryptBinaryToString","ptr",&rawdata,"uint",sz,"uint",0x40000001,"ptr",0,"uint*",cp),VarSetCapacity(str,cp*(A_IsUnicode?2:1)),DllCall("Crypt32.dll\CryptBinaryToString","ptr",&rawdata,"uint",sz,"uint",0x40000001,"str",str,"uint*",cp)
	return str
}
EncodeFile(fn,time,nn,branch){
	FileRead,bin,*c %fn%
	FileGetSize,size,%fn%
	DllCall("Crypt32.dll\CryptBinaryToStringW",Ptr,&bin,UInt,size,UInt,1,UInt,0,UIntP,Bytes),VarSetCapacity(out,Bytes*2),DllCall("Crypt32.dll\CryptBinaryToStringW",Ptr,&bin,UInt,size,UInt,1,Str,out,UIntP,Bytes)
	StringReplace,out,out,`r`n,,All
	return {text:out,encoding:"UTF-8",time:time,skip:1,node:nn,branch:branch}
}
Github_RepositoryClose:
Github_RepositoryEscape:
node:=Node()
all:=vversion.SN("//*[@tv]")
all:=vversion.SN("//files")
while(aa:=all.item[A_Index-1])
	if(!SSN(aa,"file"))
		aa.ParentNode.RemoveChild(aa)
Default("SysTreeView321"),SSN(node,"descendant::*[@tv='" TV_GetSelection() "']").SetAttribute("select",1),vversion.Save(1)
Default("SysTreeView322"),TV_GetText(branch,TV_GetSelection()),node.SetAttribute("branch",branch)
while(aa:=all.item[A_Index-1])
	aa.RemoveAttribute("tv")
dxml.Save(1),NewWin.Exit()
return
Github_RepositoryGuiContextMenu(a*){
	GuiControlGet,hwnd,%win%:hwnd,SysTreeView321
	if(a.1=hwnd){
		node:=vversion.SSN("//*[@tv='" a.2 "']")
		if(node.NodeName="branch")
			return Default("SysTreeView321"),TV_Modify(a.2,"Expand"),m("Please select a version number to edit")
		InputBox,version,New Version,Input a new version number,,,130,,,,,% SSN(node,"@name").text
		if(ErrorLevel||version="")
			return
		if(SSN(node.ParentNode,"descendant::version[@name='" version "']"))
			return m("Version number exists.")
		Default("SysTreeView321"),TV_Modify(a.2,"",version),node.SetAttribute("name",version)
		if(release:=SSN(node,"@id").text){
			ea:=XML.EA(node),Branch:=SSN(node,"ancestor-or-self::branch/@name").text,json:=git.json(obj:={tag_name:ea.name,target_commitish:Branch,name:ea.name,body:git.UTF8(node.text),draft:ea.draft?"true":"false",prerelease:ea.prerelease?"true":"false"})
			id:=git.Find("id",msg:=git.Send("PATCH",git.RepoURL("releases/" release),json))
			if(!id)
				m("Something happened",msg,release)
		}
	}
	GuiControlGet,hwnd,%win%:hwnd,SysListView321
	if(a.1=hwnd){
		m("Settings!")
	}
}
Help(){
	m("With the Branches: treeview focused:",""
	 ,"Right Click to change a version number"
	 ,"Ctrl+Up/Down: With a version number selected to increment/decrement versions"
	 ,"F1 to build a version list (will be appended to your Clipboard)"
	 ,"F2 to clear the list (Clipboard)"
	 ,"F3 to copy your entire list to the Clipboard"
	 ,"Press Delete to remove a version",""
	 ,"Drag/Drop additional files you want to upload to the window",""
	 ,"Commit As One File:",""
	 ,"Select this to have this Branch Committed as a Single File")
}
NewBranch(){
	InputBox,branch,Enter a new branch,Branch Name?,,,150
	if(ErrorLevel||branch="")
		return
	branch:=RegExReplace(branch," ","-"),info:=git.Send("POST",git.baseurl "git/refs" git.token,git.json({"ref":"refs/heads/" branch,"sha":git.sha(git.Send("GET",git.baseurl "git/refs/heads/" git.Branch() git.token))}))
	if(git.http.status!=201)
		return m(info,git.http.status)
	UpdateBranches()
}
Node(){
	global x
	if(!node:=vversion.Find("//info/@file",x.Current(2).file))
		node:=vversion.Under(vversion.SSN("//*"),"info"),node.SetAttribute("file",x.Current(2).file)
	return node
}
OneBranch(){
	Node().SetAttribute("onebranch",NewWin[].branch)
}
OneFile(){
	info:=NewWin[],Default("SysTreeView321"),node:=vversion.SSN("//*[@tv='" TV_GetSelection() "']/ancestor-or-self::branch"),(info.onefile?node.SetAttribute("onefile",1):node.RemoveAttribute("onefile")),SSN(dxml.Find("//branch/@name",git.Branch()),"file").RemoveAttribute("time")
	ControlFocus,SysTreeView321,% NewWin.ID
}
PopVer(){
	static InfoList:=[]
	for a,b in ["SysTreeView321","SysListView321","SysListView322"]
		GuiControl,%win%:-Redraw,%b%
	Default("SysListView321"),LV_Delete(),ea:=settings.EA("//github")
	all:=SN((MainNode:=Node()),"descendant::branch|descendant::version"),TV_Delete()
	for a,b in ControlList
		InfoList[LV_Add("",b,a="token"?(ea[a]?"Entered":"Needed"):ea[a])]:=a
	for a,b in [["repo","Repository Name"],["website","Website URL: (Optional)"],["description","Repository Description: (Optional)"]]
		InfoList[LV_Add("",b.2,SSN(MainNode,"@" b.1).text)]:=b.1
	Default("SysTreeView321"),Expand:=[]
	while(aa:=all.item[A_Index-1],ea:=XML.EA(aa)){
		aa.SetAttribute("tv",tv:=TV_Add(ea.name?ea.name:ea.number,SSN(aa.ParentNode,"@tv").text))
		if(ea.Expand)
			Expand[tv]:=1
	}if(tv:=SSN(MainNode,"descendant::*[@select=1]/@tv").text){
		TV_Modify(tv,"Select Vis Focus")
		GuiControl,%win%:+Redraw,SysTreeView321
		TV_Modify(tv,"Select Vis Focus")
	}else
		TV_Modify(TV_GetChild(0),"Select Vis Focus")
	while(rem:=SSN(MainNode,"descendant::*[@select=1]"))
		rem.RemoveAttribute("select")
	Default("SysListView321")
	Loop,2
		LV_ModifyCol(A_Index,"AutoHDR")
	LV_ModifyCol(1,"AutoHDR")
	for tv in Expand
		TV_Modify(tv,"Expand")
	for a,b in ["SysTreeView321","SysListView321","SysListView322"]{
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
		InputBox,Output,Enter Value,% "Please enter a value for " Input (Value="repo"?"`n`nWARNING!: All Un-Committed Version Information Will Be Lost!`n`nAll spaces will be replaced with '-'":""),% (Value="token"?"Hide":""),,% (Value="repo"?220:150),,,,,%CurrentValue%
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
		git.Refresh(),PopVer()
	}
	return
}
RefreshBranch(){
	global git
	git.TreeSha(),PopVer()
}
Releases(){
	UpdateReleases(git.Send("GET",git.BaseURL "releases"))
}
Text(text){
	return RegExReplace(text,"\x7f","`r`n")
}
tv(Manual:=""){
	if(A_GuiEvent="S"||Manual="1"){
		Default("SysTreeView321"),cn:=vversion.SSN("//*[@tv='" TV_GetSelection() "']")
		GuiControl,%win%:,Edit1,% cn.NodeName="branch"?"":Text(cn.text)
		GuiControl,% win ":" (cn.NodeName="branch"?"Disabled":"Enabled"),Edit1
		if((all:=SN(SSN(cn,"ancestor-or-self::branch"),"descendant::files/file|//info/files/file")).length){
			Default("SysListView322"),LV_Delete()
			while(aa:=all.item[A_Index-1],ea:=XML.EA(aa))
				Default("SysListView322"),LV_Add("",ea.folder,ea.filepath)
		}else
			Default("SysListView322"),LV_Delete()
		ea:=XML.EA(cn)
		if(ea.draft="true")
			GuiControl,%win%:,&Draft,1
		else if(ea.prerelease="true"||ea.prerelease=""&&ea.draft="")
			GuiControl,%win%:,&Pre-Release,1
		else{
			GuiControl,%win%:,&Full Release,1
		}
		LV_ModifyCol(2,"","Files Repo: " SSN(cn,"ancestor-or-self::branch/@name").text)
		Loop,4
			LV_ModifyCol(A_Index,"AutoHDR")
		LV_Modify(1,"Select Vis Focus")
		GuiControl,%win%:,Commit As &One File,% SSN(cn,"ancestor-or-self::branch/@onefile")?1:0
	}else if(A_GuiEvent="+"||A_GuiEvent="-"){
		cn:=vversion.SSN("//*[@tv='" TV_GetSelection() "']"),(A_GuiEvent="+"?cn.SetAttribute("expand",1):cn.RemoveAttribute("expand"))
	}
}
Update(){
	Default("SysTreeView321")
	ea:=vversion.EA(node:=vversion.SSN("//*[@tv='" TV_GetSelection() "']"))
	info:=newwin[] ;,TV_GetText(name,TV_GetSelection())
	if(node.NodeName="Branch")
		return Default("SysTreeView321"),TV_Modify(a.2,"Expand"),m("Please select a version number to Update")
	if(!info.edit)
		return m("Please enter Version Information for this release")
	json:=git.json(obj:={tag_name:ea.name,target_commitish:git.Branch(),name:ea.name,body:git.UTF8(info.edit),draft:info.draft?"true":"false",prerelease:info.prerelease?"true":"false"})
	/*
		;Fetch the release id for a given release
		;GET /repos/:owner/:repo/releases
		;check release list
		url:=git.url "/repos/" git.owner "/" git.repo "/releases" git.token,id:=git.find("id",git.send("GET",url)),SSN(Node(),"descendant::version[@name='" name "']").SetAttribute("id",id),m(Node().xml)
		return
	*/
	if(release:=ea.ID){
		id:=git.Find("id",msg:=git.Send("PATCH",git.RepoURL("releases/" release),json))
		if(!id)
			m("Something happened",msg,release)
		node.SetAttribute("draft",obj.draft),node.SetAttribute("prerelease",obj.prerelease)
	}else{
		id:=git.Find("id",info:=git.Send("POST",git.RepoURL("releases"),json))
		if(!id)
			return m("Something happened",info)
		SSN(Node(),"descendant::version[@name='" ea.name "']").SetAttribute("id",id)
	}
	vversion.Save(1)
}
UpdateBranches(){
	root:=dxml.SSN("//*"),pos:=1,node:=Node()
	info:=git.Send("GET",git.RepoURL("git/refs/heads")),List:=[]
	while(RegExMatch(info,"OUi)\x22ref\x22:\x22(.*)\x22",Found,pos),pos:=Found.Pos(1)+Found.len(1)){
		List[(item:=StrSplit(Found.1,"/").Pop())]:=1
		if(!dxml.Find("//branch/@name",item))
			dxml.Under(root,"branch",{name:item})
		if(!new:=vversion.Find(node,"branch/@name",item))
			new:=vversion.Under(node,"branch",{name:item,onefile:1})
		if(item="master"&&SSN((before:=SSN(node,"branch")),"@name").text!="master")
			node.InsertBefore(new,before)
	}blist:=dxml.SN("//branch")
	while(bl:=blist.item[A_Index-1],ea:=XML.EA(bl))
		if(!List[ea.name])
			bl.ParentNode.RemoveChild(bl)
	all:=SN(node,"branch")
	while(aa:=all.item[A_Index-1],ea:=XML.EA(aa))
		if(!List[ea.name])
			aa.ParentNode.RemoveChild(aa)
	pos:=1,info:=git.Send("GET",git.RepoURL("releases"))
	while(pos:=RegExMatch(info,"{\x22url\x22:",,pos)){
		commit:=[]
		for a,b in {id:",",target_commitish:",",name:",",draft:",",prerelease:",",body:"\}"}
			RegExMatch(info,"OUi)\x22" a "\x22:(.*)" b,Found,pos),commit[a]:=Trim(Found.1,Chr(34))
		if(!top:=vversion.Find(node,"branch/@name",commit.target_commitish))
			top:=vversion.Under(node,"branch",{name:commit.target_commitish})
		if(!version:=vversion.Find(top,"version/@name",commit.name))
			version:=dxml.Under(top,"version",{name:commit.name})
		for a,b in commit{
			if(a!="body")
				version.SetAttribute(a,b)
			else
				version.text:=RegExReplace(b,"\R|\\n|\\r",Chr(127))
		}
		pos:=found.Pos(1)+found.Len(1)
	}for a in list{
		if(!SSN((top:=vversion.Find(node,"branch/@name",a)),"version"))
			vversion.Under(top,"version",{name:1})
	}PopVer()
}
UpdateReadme(){
	static
	Default("SysTreeView321"),Branch:=git.Branch()
	if(!Branch)
		return m("Please Select The Branch To Update")
	info:=git.Send("GET",git.RepoURL("contents/README.md","&ref=" Branch),{ref:Branch,path:"README.md"}),sha:=git.Sha(info),Contents:=git.Find("content",info)
	Gui,EditReadme:Destroy
	Gui,EditReadme:Default
	Gui,Add,Edit,w800 h600 vReadMeEdit,% RegExReplace(Decode(Contents),"i)<br>","`r`n")
	Gui,Add,Button,gReadMeUpdate,&Update
	Gui,Show,,Edit Readme.md
	return
	ReadMeUpdate:
	Gui,EditReadme:Submit,Nohide
	msg:=git.Send("PUT",git.RepoURL("contents/README.md"),git.json({path:"README.md",message:"Updating the README.md file",content:Encode(RegExReplace(ReadMeEdit,"\R","<br>")),sha:sha,branch:branch}))
	if(git.http.status=200){
		EditReadmeGuiEscape:
		EditReadmeGuiClose:
		KeyWait,Escape,U
		Gui,EditReadme:Destroy
		return
	}else
		return m(git.http.status,msg)
}
UpdateRelease(){
	Default("SysTreeView321"),node:=vversion.SSN("//*[@tv='" TV_GetSelection() "']")
	if(node.NodeName!="version")
		return
	info:=A_GuiControl="fullrelease"?{prerelease:"false",draft:"false"}:A_GuiControl="prerelease"?{prerelease:"true",draft:"false"}:{prerelease:"false",draft:"true"}
	for a,b in info
		node.SetAttribute(a,b)
	ControlFocus,SysTreeView321,% NewWin.ID
}
UpdateReleases(releases){
	pos:=1,node:=Node()
	while(RegExMatch(releases,"OU)\x22id\x22:(\d+)\D.*\x22name\x22:\x22(.*)\x22.*\x22body\x22:\x22(.*)\x22\}",found,pos)),pos:=found.Pos(1)+20{
		if(!SSN(node,"branch/version[@name='" found.2 "']")){
			new:=vversion.Under(SSN(node,"descendant::branch"),"version",,RegExReplace(found.3,"\\n",Chr(127)))
			for a,b in {number:found.2,id:found.1}
				new.SetAttribute(a,b)
		}
	}
}
verhelp(){
	m("Right Click to change a version number`nCtrl+Up/Down to increment versions`nF1 to build a version list (will be copied to your Clipboard)`nF2 to clear the list`nF3 to copy your entire list to the Clipboard`nPress Delete to remove a version")
}
WholeList(Return:=0){
	Default("SysTreeView321"),list:=SN(vversion.SSN("//*[@tv='" TV_GetSelection() "']"),"ancestor-or-self::branch/version")
	while,ll:=list.item[A_Index-1]
		Info.=SSN(ll,"@name").text "`r`n" Trim(ll.text,"`r`n") "`r`n"
	if(Return)
		return Info
	else
		m("Version list copied to your clipboard.","","",Clipboard:=Info)
	return
}
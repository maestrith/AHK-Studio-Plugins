;Menu Github Wiki Menu Creator
#SingleInstance,Force
global menu
menu:=new xml("menu","lib\Menu.xml")
Gui,+hwndmain
Hotkey,^down,movesel,On
Hotkey,^up,movesel,On
Hotkey,^+down,blank,On
Hotkey,^+up,blank,On
Gui,Add,TreeView,w300 h600 Checked AltSubmit gshowinfo
Gui,Add,Edit,x+5 w600 h600 vedit gedit
Gui,Add,Button,xm gimport Default,Import From Studio
Gui,Add,Button,x+5 gsort,S&ort
populate()
Gui,Show,,Wiki Updater
return
class xml{
	keep:=[]
	__New(param*){
		if !FileExist(A_ScriptDir "\lib")
			FileCreateDir,%A_ScriptDir%\lib
		root:=param.1,file:=param.2
		file:=file?file:root ".xml"
		temp:=ComObjCreate("MSXML2.DOMDocument"),temp.setProperty("SelectionLanguage","XPath")
		this.xml:=temp
		if FileExist(file){
			FileRead,info,%file%
			if(info=""){
				this.xml:=this.CreateElement(temp,root)
				FileDelete,%file%
			}else
				temp.loadxml(info),this.xml:=temp
		}else
			this.xml:=this.CreateElement(temp,root)
		this.file:=file
		xml.keep[root]:=this
	}
	CreateElement(doc,root){
		return doc.AppendChild(this.xml.CreateElement(root)).parentnode
	}
	search(node,find,return=""){
		found:=this.xml.SelectNodes(node "[contains(.,'" RegExReplace(find,"&","')][contains(.,'") "')]")
		while,ff:=found.item(a_index-1)
			if (ff.text=find){
				if return
					return ff.SelectSingleNode("../" return)
				return ff.SelectSingleNode("..")
			}
	}
	lang(info){
		info:=info=""?"XPath":"XSLPattern"
		this.xml.temp.setProperty("SelectionLanguage",info)
	}
	unique(info){
		if (info.check&&info.text)
			return
		if info.under{
			if info.check
				find:=info.under.SelectSingleNode("*[@" info.check "='" info.att[info.check] "']")
			if info.Text
				find:=this.cssn(info.under,"*[text()='" info.text "']")
			if !find
				find:=this.under(info.under,info.path,info.att)
			for a,b in info.att
				find.SetAttribute(a,b)
		}
		else
		{
			if info.check
				find:=this.ssn("//" info.path "[@" info.check "='" info.att[info.check] "']")
			else if info.text
				find:=this.ssn("//" info.path "[text()='" info.text "']")
			if !find
				find:=this.add({path:info.path,att:info.att,dup:1})
			for a,b in info.att
				find.SetAttribute(a,b)
		}
		if info.text
			find.text:=info.text
		return find
	}
	add(path,att:="",text:="",dup:=0,list:=""){
		p:="/",dup1:=this.ssn("//" path)?1:0,next:=this.ssn("//" path),last:=SubStr(path,InStr(path,"/",0,0)+1)
		if !next.xml{
			next:=this.ssn("//*")
			Loop,Parse,path,/
				last:=A_LoopField,p.="/" last,next:=this.ssn(p)?this.ssn(p):next.appendchild(this.xml.CreateElement(last))
		}
		if(dup&&dup1)
			next:=next.parentnode.appendchild(this.xml.CreateElement(last))
		for a,b in att
			next.SetAttribute(a,b)
		for a,b in StrSplit(list,",")
			next.SetAttribute(b,att[b])
		if(text!="")
			next.text:=text
		return next
	}
	ff(info*){
		doc:=info.1.NodeName?info.1:this.xml
		if(info.1.NodeName)
			node:=info.2,find:=info.3
		else
			node:=info.1,find:=info.2
		if InStr(find,"'")
			return doc.SelectSingleNode(node "[.=concat('" RegExReplace(find,"'","'," Chr(34) "'" Chr(34) ",'") "')]/..")
		else
			return doc.SelectSingleNode(node "[.='" find "']/..")
	}
	find(info){
		if(info.att.1&&info.text)
			return m("You can only search by either the attribut or the text, not both")
		search:=info.path?"//" info.path:"//*"
		for a,b in info.att
			search.="[@" a "='" b "']"
		if info.text
			search.="[text()='" info.text "']"
		current:=this.ssn(search)
		return current
	}
	under(under,node:="",att:="",text:="",list:=""){
		if(node="")
			node:=under.node,att:=under.att,list:=under.list,under:=under.under
		new:=under.appendchild(this.xml.createelement(node))
		for a,b in att
			new.SetAttribute(a,b)
		for a,b in StrSplit(list,",")
			new.SetAttribute(b,att[b])
		if text
			new.text:=text
		return new
	}
	ssn(node){
		return this.xml.SelectSingleNode(node)
	}
	sn(node){
		return this.xml.SelectNodes(node)
	}
	__Get(x=""){
		return this.xml.xml
	}
	Get(path,Default){
		return value:=this.ssn(path).text!=""?this.ssn(path).text:Default
	}
	transform(){
		static
		if !IsObject(xsl){
			xsl:=ComObjCreate("MSXML2.DOMDocument")
			style=
			(
			<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
			<xsl:output method="xml" indent="yes" encoding="UTF-8"/>
			<xsl:template match="@*|node()">
			<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
			<xsl:for-each select="@*">
			<xsl:text></xsl:text>		
			</xsl:for-each>
			</xsl:copy>
			</xsl:template>
			</xsl:stylesheet>
			)
			xsl.loadXML(style),style:=null
		}
		this.xml.transformNodeToObject(xsl,this.xml)
	}
	save(x*){
		if x.1=1
			this.Transform()
		filename:=this.file?this.file:x.1.1,encoding:=ffff.pos=3?"UTF-8":ffff.pos=2?"UTF-16":"CP0",enc:=RegExMatch(this[],"[^\x00-\x7F]")?"utf-16":"utf-8"
		if(encoding!=enc)
			FileDelete,%filename%
		file:=fileopen(filename,"rw",encoding),file.seek(0),file.write(this[]),file.length(file.position)
	}
	remove(rem){
		if !IsObject(rem)
			rem:=this.ssn(rem)
		rem.ParentNode.RemoveChild(rem)
	}
	ea(path){
		list:=[]
		if nodes:=path.nodename
			nodes:=path.SelectNodes("@*")
		else if path.text
			nodes:=this.sn("//*[text()='" path.text "']/@*")
		else if !IsObject(path)
			nodes:=this.sn(path "/@*")
		else
			for a,b in path
				nodes:=this.sn("//*[@" a "='" b "']/@*")
		while,n:=nodes.item(A_Index-1)
			list[n.nodename]:=n.text
		return list
	}
}
ssn(node,path){
	return node.SelectSingleNode(path)
}
sn(node,path){
	return node.SelectNodes(path)
}
import:
x:=ComObjActive("ahk-studio")
menus:=x.get("menus")
menus.Transform(1)
main:=menus.sn("//*/descendant::menu")
while,tt:=main.item[A_Index-1],ea:=xml.ea(tt),pa:=xml.ea(tt.ParentNode){
	eclean:=clean(ea.clean),pclean:=clean(pa.clean)
	top:=pa.clean?menu.ssn("//menu[@name='" clean(pa.clean) "']"):menu.ssn("//*")
	if(tt.haschildnodes()&&pa.clean=""){
		SplashTextOn,200,200,Importing,% ea.clean
		if(!top:=menu.ssn("//menu[@name='" eclean "']"))
			top:=menu.add("menu/menu",{name:eclean},,1)
	}else if(tt.haschildnodes()&&pa.clean){
		pn:=menu.ssn("//menu[@name='" pclean "']")
		if(!top:=menu.ssn("//menu[@name='" pclean "']/menu[@name='" eclean "']"))
			top:=menu.under(pn,"menu",{name:eclean})
	}else{
		if(!ssn(top,"menu[@name='" eclean "']"))
			menu.under(top,"menu",{name:eclean})
	}
}
SplashTextOff
populate()
return
m(x*){
	for a,b in x
		list.=b "`n"
	MsgBox,,AHK Studio,% list
}
t(x*){
	for a,b in x
		list.=b "`n"
	Tooltip,% list
}
populate(){
	menus:=menu.sn("//*/descendant::*")
	TV_Delete()
	while,mm:=menus.item[A_Index-1],ea:=xml.ea(mm),pa:=xml.ea(mm.ParentNode)
		mm.SetAttribute("tv",TV_Add(ea.name,pa.tv,_:=mm.text&&mm.firstchild.nodename!="menu"?"Check":""))
}
GuiEscape:
GuiClose:
menu.transform(1)
menu.save(1)
ExitApp
return
clean(info){
	return RegExReplace(RegExReplace(info,"_"," "),"&")
}
movesel:
if(A_ThisHotkey="^down")
	TV_Modify(TV_GetNext(TV_GetSelection(),"F"),"Select Vis Focus")
else
	TV_Modify(TV_GetPrev(TV_GetSelection()),"Select Vis Focus")
return
edit:
Gui,Submit,Nohide
node:=menu.ssn("//*[@tv='" (sel:=TV_GetSelection()) "']")
if(node.firstchild.nodename!="menu"){
	node.text:=edit
	TV_Modify(sel,"Check")
}else
	m("Can not add info to the root")
return
f1::
MouseClick,Left,,,3
Send,+{left}
Send,^c
ControlSetText,Edit1,%Clipboard%,ahk_id%main%
goto,Edit
return
showinfo:
node:=menu.ssn("//*[@tv='" A_EventInfo "']")
if(A_GuiEvent="S"&&node.firstchild.nodename!="menu"){
	GuiControl,+g,Edit1
	ControlSetText,Edit1,% node.text
	GuiControl,+gedit,Edit1
	WinSetTitle,ahk_id%main%,,% "Wiki Updater - " xml.ea(node).name
}
return
f2::
node:=menu.sn("//*[@tv='" TV_GetSelection() "']/descendant::*")
wiki:=""
while,nn:=node.item[A_Index-1],ea:=xml.ea(nn){
	if(nn.firstchild.nodename="menu"){
		wiki.="#" ea.name "`n"
	}else{
		wiki.="##" ea.name "`n" nn.text "`n`n"
	}
	
}
m(clipboard:=wiki)
return
blank:
node:=menu.ssn("//*[@tv='" TV_GetSelection() "']")
follow:=sn(node,"following::*")
while,ff:=follow.item[A_Index-1],ea:=xml.ea(ff){
	if(!ff.text){
		TV_Modify(ea.tv,"Select Vis Focus")
		return 
	}
} 
return
Sort:
list:=menu.sn("//menu/descendant::*")
while,ll:=list.item[A_Index-1],ea:=xml.ea(ll){
	if(ll.firstchild.nodename="menu"){
		below:=sn(ll,"*"),order:=[]
		while,bb:=below.item[A_Index-1],bea:=xml.ea(bb){
			order[bea.name]:=bb
		}
		for a,b in order
			ll.AppendChild(b)
	}
}
Populate()
return
;menu Clean Position Data
x:=ComObjActive("AHK-Studio"),positions:=x.get("positions"),files:=x.get("files"),all:=positions.sn("//main/file"),xml:=x.get("xml")
while,aa:=all.item[A_Index-1],ea:=xml.ea(aa){
	if(!FileExist(ea.file)){
		aa.ParentNode.RemoveChild(aa)
		Continue
	}
	file:=files.ssn("//file[@file='" ea.file "']")
	if(parent:=ssn(file,"ancestor::main/@file").text){
		if(!top:=positions.ssn("//main[@file='" parent "']"))
			top:=positions.add("main",{file:parent},,1)
		top.AppendChild(aa)
	}else
		aa.ParentNode.RemoveChild(aa)
}
positions.save(1)
MsgBox,done
return
ssn(node,path){
	return node.SelectSingleNode(path)
}
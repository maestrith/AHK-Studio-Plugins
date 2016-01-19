#SingleInstance,Force
;menu Clean Position Data
x:=Studio(),positions:=x.get("positions"),files:=x.get("files")
Total:=0,current:=0,loop:=0
temp:=new xml("temp"),temp.xml.loadxml(positions[])
top:
for a,b in [temp.sn("//main"),temp.sn("//main/file")]
	while,aa:=b.item[A_Index-1],ea:=xml.ea(aa){
		if(!FileExist(ea.file)){
			aa.ParentNode.RemoveChild(aa),Total++,current++
			Continue
		}
		if((dup:=sn(aa.parentnode,"file[@file='" ea.file "']")).length>1)
			dup.item[1].parentnode.removechild(dup.item[1]),Total++,current++
	}
if(current){
	current:=0
	Loop++
		if(loop>4){
			msg:="`n`nThere were a lot of duplicates and old files, you may want to run this again"
			Goto,Bottom
		}
	Goto,Top
}
Bottom:
positions.xml.loadxml(temp[])
positions.save(1)
m("Done","Removed: " Total " Item(s)" msg)
exitapp
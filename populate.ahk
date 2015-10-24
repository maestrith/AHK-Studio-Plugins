Populate(){
	all:=commands.sn("//Commands/commands"),top:=TV_Add("Commands")
	while,aa:=all.item[A_Index-1],ea:=xml.ea(aa){
		next:=TV_Add(aa.text,top,"Sort")
		TV_Add(ea.syntax,next)
	}
	all:=commands.sn("//Color/*"),top:=TV_Add("Color")
	while,aa:=all.item[A_Index-1]{
		next:=TV_Add(aa.nodename,top,"Sort")
		TV_Add(aa.text,next)
	}
	all:=commands.sn("//Context/descendant::*"),root:=TV_Add("Context"),tv:=[]
	while,ll:=all.item[A_Index-1],ea:=xml.ea(ll){
		if(ll.ParentNode.NodeName="Context"){
			tv[top:=TV_Add(ll.NodeName,root)]:={command:1,name:ll.NodeName}
			for a,b in {list:"List",syntax:"Syntax"}
				if(ssn(ll,a))
					tv[%a%:=TV_Add(b,top)]:={parent:top,name:b,type:"Add",sub:a}
		}else if(ll.NodeName="list"&&ll.attributes.length!=0){
			tv[next:=TV_Add(ll.text,list)]:={parent:list,name:ll.text,type:"List"}
			tv[TV_Add(ea.list,next)]:={parent:next,name:ea.list,type:"value",att:"list"}
		}else if(ll.NodeName="syntax"&&ll.attributes.length!=0){
			tv[next:=TV_Add(ll.text,syntax)]:={parent:syntax,name:ll.text,type:"Syntax"}
			tv[TV_Add(ea.syntax,next)]:={parent:next,name:ea.syntax,type:"value",att:"syntax"}
		}
	}
	TV_Modify(TV_GetChild(0),"Select Vis Focus")
}
;Menu Make One Line
#SingleInstance,Force
#NoTrayIcon
x:=Studio(),text:=x.sc.getseltext(),text:=RegExReplace(text,"\n",","),text:=RegExReplace(text,"\t"),x.sc.2170(0,[text])
return

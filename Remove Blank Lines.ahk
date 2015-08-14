;Menu Remove Blank Lines
x:=ComObjActive("ahk-studio"),sc:=x.sc,text:=sc.getuni(),text:=RegExReplace(text,"\n\s*\n","`n"),sc.2181(0,[text])
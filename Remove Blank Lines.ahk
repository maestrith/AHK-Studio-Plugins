;Menu Remove Blank Lines
x:=ComObjActive("ahk-studio"),sc:=x.sc,text:=sc.getuni(),text:=RegExReplace(text,"\n\s*\n","`n"),x.SetText(text)
;menu Mark All Files For Update
x:=Studio()
files:=x.get("files")
all:=files.sn("//file")
updated:=x.call("update","updated")
while,aa:=all.item[A_Index-1]
	updated[files.ea(aa).file]:=1
ExitApp

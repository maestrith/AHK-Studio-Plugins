#SingleInstance,Force
;menu Display Hotkeys
x:=Studio()
SplashTextOn,200,100,Getting List,Please Wait...
menus:=x.get("menus")
list:=menus.sn("//*[@hotkey!='']")
while,ll:=list.item[A_Index-1],ea:=xml.ea(ll){
	total.=ea.clean " = " ea.hotkey "`n"
}
SplashTextOff
m("Your clipboard contains:",Clipboard:=total)
ExitApp
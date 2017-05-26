#SingleInstance,Force
;menu Fold All,all
;menu Unfold All,ua
;menu Toggle Fold All,tfa
;menu Fold Current Level,fc
;menu Unfold Current Level,uc
;menu Fold Level X,fx
;menu Unfold Level X,ux
;menu Toggle Fold,tf
global sc,x
info=%1%
x:=Studio(),sc:=x.sc()
if(info="all")
	sc.2662
if(info="ua")
	sc.2662(1)
if(info="tfa")
	sc.2662(2)
if(info="fc")
	level:=sc.2223(sc.2166(sc.2008))&0xff,level:=level-1>=0?level-1:level,Fold_Level_X(Level)
if(info="uc")
	level:=sc.2223(sc.2166(sc.2008))&0xff,Unfold_Level_X(Level)
if(info="fx")
	Fold_Level_X()
if(info="ux")
	Unfold_Level_X()
if(info="tf")
	sc.2231(sc.2166(sc.2008))
ExitApp
Fold_Level_X(Level=""){
	if(level="")
		level:=x.call("InputBox",sc.sc,"Fold Levels","Enter a level to fold`n0-100")
	current:=0
	while,(current<sc.2154){
		fold:=sc.2223(current)
		if (fold&0xff=level)
			sc.2237(current,0),current:=sc.2224(current,fold)
		current+=1
	}
}
Unfold_Level_X(Level=""){
	if(level="")
		level:=x.call("InputBox",sc,"Fold Levels","Enter a level to unfold`n0-100")
	if(ErrorLevel)
		return
	fold=0
	while,sc.2618(fold)>=0,fold:=sc.2618(fold){
		lev:=sc.2223(fold)
		if(lev&0xff=level)
			sc.2237(fold,1)
		fold++
	}
} 

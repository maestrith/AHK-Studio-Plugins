;menu Update Repository
#SingleInstance,Force
x:=Studio()
dir:=x.current(2).file
SplitPath,dir,,dir
FileRead,config,%dir%\.git\config
RegExMatch(config,"url\s*=\s*(.*)",url)
m(url1)
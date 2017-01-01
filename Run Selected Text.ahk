;menu Run Selected Text
;menu Run Current Segment,segment
info=%1%
x:=Studio(),sc:=x.sc(),script:=info="segment"?sc.gettext():sc.getseltext(),x.dynarun(script)

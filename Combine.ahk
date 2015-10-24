Combine(){
	/*
		find and replace it
		build as
	(
	<Commands>
		<commands syntax="syntax">item</commands>
	
	and
	
	<Color>
		<KeyNames>text</KeyNames>

	and
	
	<Context>
		<Root>
			<stuff/>
	)
	*/
	global x
	;#ClipboardTimeout,
	Loop,spam, 
		m(Custom_Commands[])
	cmd:=Custom_Commands.sn("//Commands/commands"),col:=Custom_Commands.sn("//Color/*"),con:=Custom_Commands.sn("//Context/*")
	
	while,new:=cmd.item[A_Index-1].clonenode(1)
		commands.ssn("//Commands/Commands").replaceChild(new,commands.ssn("//Commands/commands[text()='" new.text "']"))
	while,new:=col.item[A_Index-1].clonenode(1)
		commands.ssn("//Color").replaceChild(new,commands.ssn("//Color/" new.nodename))
	while,new:=con.item[A_Index-1].clonenode(1)
		commands.ssn("//Context").replaceChild(new,commands.ssn("//Context/" new.nodename))
}
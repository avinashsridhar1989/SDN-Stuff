open NetKAT.Std

// basic flood policy:
let flood : policy =
	<:netkat<
		if port = 1 then port:= 2 + port := 3
		else if port = 2 then port := 1 + port := 3
		else if port = 3 then port := 1+ port:= 2
		else drop

	>>

commented let += run_static flood

// blocking tcp traffic

let blockTCP : policy =
	<:netkat<
		if (port = 1 && ethType = 0x0900 && ipProto = 0x06) then drop
		else $flood 
	>>

let _= run_static blockTCP


tO COMPILE DO netkat-build <FILENAME.natice>

to test tcp traffic open a host via xterm and do 'nc -l 80'

for udp traffic change command to 'nc -lu 80'

'nic -l 443' for http tcp




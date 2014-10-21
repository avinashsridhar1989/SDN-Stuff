open NetKAT.Std

(* Hub policy taken from Q1.ml *)
let hub : policy =
    <:netkat<
        if port = 1 then port:= 2 + port:= 3 + port:= 4
        else if port = 2 then port:= 1 + port:= 3 + port:= 4
        else if port = 3 then port:= 1 + port:= 2 + port:= 4
        else if port = 4 then port:= 1 + port:= 2 + port:= 3
        else drop
    >>

(* Firewall policy to block SSH traffic from h1 to h3 or h1 to h4 *)
let firewall : policy =
   <:netkat<
	if (port = 1 && tcpDstPort = 22 && ethType = 0x0800 && ipProto = 0x06 && (ip4Dst = 10.0.0.3 || ip4Dst = 10.0.0.4))  then drop
	else $hub
   >>

let _ = run_static firewall

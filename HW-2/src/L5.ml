open NetKAT.Std

(* Policy for switch 2 *)
let sw2 : policy =
  <:netkat<
	if port = 1 then
		if ip4Dst = 10.0.0.2 && ethType = 0x0800 && ipProto = 0x01 then port := 2
		else if (ip4Dst = 10.0.0.3 || ip4Dst = 10.0.0.4) && ethType = 0x0800 && ipProto = 0x01 then port := 3
		else drop
	else if port = 2 then
		if ip4Dst = 10.0.0.1 && ethType = 0x0800 && ipProto = 0x01 then port := 1
		else if (ip4Dst = 10.0.0.3 || ip4Dst = 10.0.0.4) && ethType = 0x0800 && ipProto = 0x01 then port := 3
		else drop
	else if port = 3 then
		if ip4Dst = 10.0.0.2 && ethType = 0x0800 && ipProto = 0x01 then port := 2
		else if ip4Dst = 10.0.0.1 && ethType = 0x0800 && ipProto = 0x01 then port := 1
		else drop
	else drop

  >>

(* Policy for switch 3 *)
let sw3 : policy =
  <:netkat<
        if port = 1 then
                if ip4Dst = 10.0.0.4 && ethType = 0x0800 && ipProto = 0x01 then port := 2
                else if (ip4Dst = 10.0.0.1 || ip4Dst = 10.0.0.2) && ethType = 0x0800 && ipProto = 0x01 then port := 3
                else drop
        else if port = 2 then
                if ip4Dst = 10.0.0.3 && ethType = 0x0800 && ipProto = 0x01 then port := 1
                else if (ip4Dst = 10.0.0.1 || ip4Dst = 10.0.0.2) && ethType = 0x0800 && ipProto = 0x01 then port := 3
                else drop
        else if port = 3 then
                if ip4Dst = 10.0.0.3 && ethType = 0x0800 && ipProto = 0x01 then port := 1
                else if ip4Dst = 10.0.0.4 && ethType = 0x0800 && ipProto = 0x01 then port := 2
                else drop
        else drop
  >>

(* Routing Policy for each switch *)
let routing : policy =
  <:netkat<
	if switch = 1 then
		if port = 1 then port := 2
		else if port = 2 then port := 1
		else drop
	else if switch = 2 then $sw2
	else if switch = 3 then $sw3
	else drop
  >>

let _ = run_static routing

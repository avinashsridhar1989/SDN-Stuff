open Core.Std
open Async.Std
open Async_NetKAT
open NetKAT_Types
open NetKAT.Std

(* Hash Map that stores switch, destination MAC Address and maps the key to a port number *)
let hostsHashmap : (switchId * dlAddr, portId) Hashtbl.t =
  Hashtbl.Poly.create ()

(* Function to perform learning of the host mac and port number *)
let doLearn (sw : switchId) (pt : portId) (pk : packet) : bool =
  match Hashtbl.find hostsHashmap (sw, pk.dlSrc) with
    | Some pt' when pt = pt' ->
       false
    | _ ->
       ignore (Hashtbl.add hostsHashmap (sw, pk.dlSrc) pt);
       true

(* We are outputting the packet that is to be sent out *)
let packetOut (sw : switchId) (pk : packet) : action =
  match Hashtbl.find hostsHashmap (sw, pk.dlDst) with
    | Some pt -> Output (Physical pt)
    | None -> Output All

let default =
  <:netkat<port := "learn">>

(* Here we implement learning policy *)
let policyLearn () =
  List.fold_right
    (Hashtbl.to_alist hostsHashmap)
    ~init:default
    (* Inside the below function, firewall policy is being implemented to block https traffic *)
    ~f:(fun ((sw,addr),pt) myPolicy ->
        <:netkat<
          if ((port = 1 || port = 2 || port = 3) && (ip4Dst = 10.0.0.1 || ip4Dst = 10.0.0.2 || ip4Dst = 10.0.0.3) && tcpDstPort = 443 && ethType = 0x0800 && ipProto = 0x06)  then drop
          else
                if switch = $sw && ethSrc = $addr then drop else $myPolicy
        >>)

(* Here we implement routing policy *)
let policyRoute () =
  List.fold_right
    (Hashtbl.to_alist hostsHashmap)
    ~init:default
    ~f:(fun ((sw,addr),pt) myPolicy ->
      <:netkat<
        if switch = $sw && ethDst = $addr then port := $pt else $myPolicy
      >>)

(* Policy to implement the learning and routing functionality *)
let policy () =
  let lp = policyLearn () in
  let rp = policyRoute () in
  <:netkat< $lp + $rp >>

(* This is the main code that is called when controller is started. Every packet that comes into controller will go through this function first *)
let packetHandler t w () e = match e with
  | PacketIn(_, switch_id, port_id, payload, _) ->
    let packet = Packet.parse (SDN_Types.payload_bytes payload) in
    let myPolicy =
      if doLearn switch_id port_id packet then
        Some (policy ())
      else
        None in
    let action = packetOut switch_id packet in
    Pipe.write w (switch_id, (payload, Some(port_id), [action])) >>= fun _ ->
    return myPolicy
  | _ -> return None

(* Controller is started here *)
let _ =
  Async_NetKAT_Controller.start
    (create ~pipes:(PipeSet.singleton "learn") (policy ()) packetHandler) ();
  never_returns (Scheduler.go ())


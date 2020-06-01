::  escape/request: query ethereum for contract data regarding escapes
::
::    produces hex string result, for use with +decode-results:rpc:ethereum
::
/+  ethio, strandio
=,  ethereum-types
=,  able:jael
::
=>  |%
    ::  TODO: specialize to only allow for the concrete calls
    ::
    +$  escape-data
      $:  escape=[@t proto-read-request:rpc:ethereum]
          spawns=[@t proto-read-request:rpc:ethereum]
      ==
    --
::
|=  args=vase
=/  m  (strand:strandio ,vase)
^-  form:m
=+  !<(escape-data args)
;<  escapes=@t  bind:m  (read-contract:ethio escape)
;<  spawns=@t  bind:m  (read-contract:ethio spawns)
(pure:m !>([escapes spawns]))

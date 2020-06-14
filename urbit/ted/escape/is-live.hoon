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
      [url=@t (list proto-read-request:rpc:ethereum)]
    --
::
|=  args=vase
=/  m  (strand:strandio ,vase)
^-  form:m
;<  is-live=@t  bind:m  (read-contract:ethio !<(escape-data args))
(pure:m !>(is-live))

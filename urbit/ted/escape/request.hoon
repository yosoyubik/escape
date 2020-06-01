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
      :: %-  list
      :: $:  ::is-live=[@t proto-read-request:rpc:ethereum]
      ::     escapes=[@t proto-read-request:rpc:ethereum]
      ::     spawns=[@t proto-read-request:rpc:ethereum]
      :: ==
    --
::
|=  args=vase
=/  m  (strand:strandio ,vase)
^-  form:m
=+  !<(escape-data args)
;<  results=(list [id=@t res=@t])  bind:m
  (batch-read-contract-strict:ethio escape-data)
(pure:m !>(results))
::  TODO: finish is-the-sponsor-live check
::
:: ;<  is-live=@t  bind:m  (read-contract:ethio is-live)
:: (decode-results:abi:ethereum is-live [%bool]~)
:: ?.  (decode-results:abi:ethereum is-live [%bool]~)
::
:: ;<  escapes=@t  bind:m  (read-contract:ethio escapes)
:: ;<  spawns=@t  bind:m  (read-contract:ethio spawns)
:: (pure:m !>([escapes spawns]))

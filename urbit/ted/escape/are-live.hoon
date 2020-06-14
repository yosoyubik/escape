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
;<  results=(list [@t @t])  bind:m
  (batch-read-contract-strict:ethio !<(escape-data args))
(pure:m !>(results))

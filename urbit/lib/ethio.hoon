::  ethio: Asynchronous Ethereum input/output functions.
::.
/+  strandio
=,  ethereum-types
=,  able:jael
::
=>  |%
    +$  topics  (list ?(@ux (list @ux)))
    --
|%
::  +request-rpc: send rpc request, with retry
::
++  request-rpc
  |=  [url=@ta id=(unit @t) req=request:rpc:ethereum]
  =/  m  (strand:strandio ,json)
  ^-  form:m
  ;<  res=(list [id=@t =json])  bind:m
    (request-batch-rpc-strict url [id req]~)
  ?:  ?=([* ~] res)
    :: ~&  ["request-rpc done" id.i.res -.json.i.res]
    (pure:m json.i.res)
  ~&  "%unexpected-multiple-results"
  %+  strand-fail:strandio
    %unexpected-multiple-results
  [>(lent res)< ~]
::  +request-batch-rpc-strict: send rpc requests, with retry
::
::    sends a batch request. produces results for all requests in the batch,
::    but only if all of them are successful.
::
++  request-batch-rpc-strict
  |=  [url=@ta reqs=(list [id=(unit @t) req=request:rpc:ethereum])]
  |^  %+  (retry:strandio results)
        `10
      attempt-request
  ::
  +$  results  (list [id=@t =json])
  ::
  ++  attempt-request
    =/  m  (strand:strandio ,(unit results))
    ^-  form:m
    ;<  responses=(list response:rpc:jstd)  bind:m
      (request-batch-rpc-loose url reqs)
    :: ~&  ["parse-responses strict" (lent responses)]
    =-  ?~  err
          (pure:m `res)
        (pure:m ~)
    %+  roll  responses
    |=  $:  rpc=response:rpc:jstd
            [res=results err=(list [id=@t code=@t message=@t])]
        ==
    ?:  ?=(%error -.rpc)
      [res [+.rpc err]]
    ?.  ?=(%result -.rpc)
      ~&  "ethio-rpc-fail"
      [res [['' 'ethio-rpc-fail' (crip <rpc>)] err]]
    [[+.rpc res] err]
  --
::  +request-batch-rpc-loose: send rpc requests, with retry
::
::    sends a batch request. produces results for all requests in the batch,
::    including the ones that are unsuccessful.
::
++  request-batch-rpc-loose
  |=  [url=@ta reqs=(list [id=(unit @t) req=request:rpc:ethereum])]
  |^  %+  (retry:strandio results)
        `10
      attempt-request
  ::
  +$  result   response:rpc:jstd
  +$  results  (list response:rpc:jstd)
  ::
  ++  attempt-request
    =/  m  (strand:strandio ,(unit results))
    ^-  form:m
    :: ~&  "attempt-request"
    =/  =request:http
      :*  method=%'POST'
          url=url
          header-list=['Content-Type'^'application/json' ~]
        ::
          ^=  body
          %-  some  %-  as-octt:mimes:html
          %-  en-json:html
          a+(turn reqs request-to-json:rpc:ethereum)
      ==
    ;<  ~  bind:m
      (send-request:strandio request)
    :: ~&  "request-sent"
    ;<  rep=(unit client-response:iris)  bind:m
      take-maybe-response:strandio
    ?~  rep
      (pure:m ~)
    (parse-responses u.rep)
  ::
  ++  parse-responses
    |=  =client-response:iris
    =/  m  (strand:strandio ,(unit results))
    ^-  form:m
    :: ~&  "parse-responses"
    ?>  ?=(%finished -.client-response)
    ?~  full-file.client-response
      (pure:m ~)
    =/  body=@t  q.data.u.full-file.client-response
    :: ~&  "de-json"
    =/  jon=(unit json)  (de-json:html body)
    ?~  jon
      (pure:m ~)
    =/  array=(unit (list response:rpc:jstd))
      ((ar:dejs-soft:format parse-one-response) u.jon)
    ?~  array
      (strand-fail:strandio %rpc-result-incomplete-batch >u.jon< ~)
    (pure:m array)
  ::
  ++  parse-one-response
    |=  =json
    ^-  (unit response:rpc:jstd)
    =/  res=(unit [@t ^json])
      %.  json
      =,  dejs-soft:format
      (ot id+so result+some ~)
    ?^  res  `[%result u.res]
    ~|  parse-one-response=json
    :+  ~  %error  %-  need
    %.  json
    =,  dejs-soft:format
    (ot id+so error+(ot code+no message+so ~) ~)
  --
::
::  +read-contract: calls a read function on a contract, produces result hex
::
++  read-contract
  |=  [url=@t req=proto-read-request:rpc:ethereum]
  =/  m  (strand:strandio ,@t)
  ;<  res=(list [id=@t res=@t])  bind:m
    (batch-read-contract-strict url [req]~)
  ?:  ?=([* ~] res)
    (pure:m res.i.res)
  %+  strand-fail:strandio
    %unexpected-multiple-results
  [>(lent res)< ~]
::  +batch-read-contract-strict: calls read functions on contracts
::
::    sends a batch request. produces results for all requests in the batch,
::    but only if all of them are successful.
::
++  batch-read-contract-strict
  |=  [url=@t reqs=(list proto-read-request:rpc:ethereum)]
  |^  =/  m  (strand:strandio ,results)
      ^-  form:m
      ;<  res=(list [id=@t =json])  bind:m
        %+  request-batch-rpc-strict  url
        (turn reqs proto-to-rpc)
      =+  ^-  [=results =failures]
        (roll res response-to-result)
      ?~  failures  (pure:m results)
      (strand-fail:strandio %batch-read-failed-for >failures< ~)
  ::
  +$  results   (list [id=@t res=@t])
  +$  failures  (list [id=@t =json])
  ::
  ++  proto-to-rpc
    |=  proto-read-request:rpc:ethereum
    ^-  [(unit @t) request:rpc:ethereum]
    :-  id
    :+  %eth-call
      ^-  call:rpc:ethereum
      [~ to ~ ~ ~ `tape`(encode-call:rpc:ethereum function arguments)]
    [%label %latest]
  ::
  ++  response-to-result
    |=  [[id=@t =json] =results =failures]
    ^+  [results failures]
    ?:  ?=(%s -.json)
      [[id^p.json results] failures]
    [results [id^json failures]]
  --
::
::
++  get-latest-block
  |=  url=@ta
  =/  m  (strand:strandio ,block)
  ^-  form:m
  ;<  =json  bind:m
    (request-rpc url `'block number' %eth-block-number ~)
  (get-block-by-number url (parse-eth-block-number:rpc:ethereum json))
::
++  get-block-by-number
  |=  [url=@ta =number:block]
  =/  m  (strand:strandio ,block)
  ^-  form:m
  |^
  %+  (retry:strandio ,block)  `10
  =/  m  (strand:strandio ,(unit block))
  ^-  form:m
  ;<  =json  bind:m
    %+  request-rpc  url
    :-  `'block by number'
    [%eth-get-block-by-number number |]
  (pure:m (parse-block json))
  ::
  ++  parse-block
    |=  =json
    ^-  (unit block)
    :: ~&  "parsing block"
    =<  ?~(. ~ `[[&1 &2] |2]:u)
    ^-  (unit [@ @ @])
    ~|  json
    %.  json
    =,  dejs-soft:format
    %-  ot
    :~  ::~&  "hash"
        hash+parse-hex
        :: ~&  "number"
            number+parse-hex
        :: ~&  "parentHash"  
            'parentHash'^parse-hex
    ==
  ::
  ++  parse-hex
    |=  =json
    ^-  (unit @)
    :: ~&  "parse-hex"
    %-  some
    ?>  ?=(%s -.json)
    (rash (rsh 3 2 p.json) hex)
    :: (hex-to-num p.json)
  --
::
++  hex-to-num
  |=  a=@t
  :: ~&  "hex-to-num"
  (rash (rsh 3 2 a) hex)
::
++  parse-event-log
  =,  dejs:format
  |=  log=json
  ^-  event-log:rpc:ethereum
  :: ~&  "entering"
  =-  ((ot -) log)
  :~  =-  ['logIndex'^(cu - (mu so))]
      |=  li=(unit @t)
      :: ~&  "logIndex"
      ?~  li  ~
      =-  `((ou -) log)  ::TODO  not sure if elegant or hacky.
      :~
          'logIndex'^(un (cu hex-to-num so))
          :: ~&  "transactionIndex"
          'transactionIndex'^(un (cu hex-to-num so))
          :: ~&  "transactionHash"
          'transactionHash'^(un (cu hex-to-num so))
          :: ~&  "blockNumber"
          'blockNumber'^(un (cu hex-to-num so))
          :: ~&  "blockHash"
          'blockHash'^(un (cu hex-to-num so))
          :: ~&  "removed"
          'removed'^(uf | bo)
      ==
    ::
      address+(cu hex-to-num so)
      data+so
    ::
      =-  topics+(cu - (ar so))
      |=  r=(list @t)
      :: ~&  "topics"
      ^-  (lest @ux)
      ?>  ?=([@t *] r)
      :-  (hex-to-num i.r)
      (turn t.r hex-to-num)
  ==
::
++  get-logs-by-hash
  |=  [url=@ta =hash:block contracts=(list address) =topics]
  =/  m  (strand:strandio (list event-log:rpc:ethereum))
  ^-  form:m
  ~&  ["get-logs-by-hash eth" `@x`hash]
  ;<  jon=json  bind:m
    %+  request-rpc  url
    :*  `'logs by hash'
        %eth-get-logs-by-hash
        hash
        contracts
        topics
    ==
  %-  pure:m
  :: %.  json
  :: ?.  =(`@ux`hash 0xa9cf.a7cf.b6ad.249a.112e.2b9c.51a1.16c6.ca71.9879.a456.603e.7095.f931.462f.462d)
  ::   (parse-event-logs:rpc:ethereum jon)
  ?>  ?=([%a *] jon)
  :: ~&  ["parse-event-logs:rpc:ethereum" (lent p.jon)]
  :: ^-  (list event-log:rpc:ethereum)
  :: %+  weld
  ((ar:dejs:format parse-event-log) jon)
  :: |=  log=json
  :: ^-  event-log:rpc:ethereum
  :: ~&  "entering"
  :: =,  dejs:format
  :: %.  jon
  :: =-  (ar (ot -))
  :: :: =-  ((ot -) json)
  :: :~  :-  'logIndex'
  ::     :: ~&  "logIndex"
  ::     ni
  ::     :: ^-  [@t @ud]
  ::     :-  'transactionIndex'
  ::     :: ~&  "transactionIndex"
  ::     (cu hex-to-num so)
  ::     :: ^-  [@t @ux]
  ::     :-  'transactionHash'
  ::     :: ~&  "transactionHash"
  ::     (cu hex-to-num so)
  ::     :: ^-  [@t @ud]
  ::     :-  'blockNumber'
  ::     :: ~&  "blockNumber"
  ::     ni
  ::     :: ^-  [@t @ux]
  ::     :-  'blockHash'
  ::     :: ~&  "blockHash"
  ::     (cu hex-to-num so)
  ::     :: ^-  [@t ?]
  ::     :-  'removed'
  ::     :: ~&  "removed"
  ::     bo
  ::   ::
  ::     address+(cu hex-to-num so)
  ::     data+so
  ::   ::
  ::     =-  topics+(cu - (ar so))
  ::     |=  r=(list @t)
  ::     ~&  ["topics" (lent r)]
  ::     ^-  (lest @ux)
  ::     ?>  ?=([@t *] r)
  ::     :-  (hex-to-num i.r)
  ::     (turn t.r hex-to-num)
  :: ==
::
++  get-logs-by-range
  |=  $:  url=@ta
          contracts=(list address)
          =topics
          =from=number:block
          =to=number:block
      ==
  =/  m  (strand:strandio (list event-log:rpc:ethereum))
  ~&  ["get-logs-by-range eth" `number+from-number `number+to-number]
  ^-  form:m
  ;<  =json  bind:m
    %+  request-rpc  url
    :*  `'logs by range'
        %eth-get-logs
        `number+from-number
        `number+to-number
        contracts
        topics
    ==
  %-  pure:m
  (parse-event-logs:rpc:ethereum json)
::
++  get-next-nonce
  |=  [url=@ta =address]
  =/  m  (strand:strandio ,@ud)
  ^-  form:m
  ;<  =json  bind:m
    %^  request-rpc  url  `'nonce'
    [%eth-get-transaction-count address [%label %latest]]
  %-  pure:m
  (parse-eth-get-transaction-count:rpc:ethereum json)
--

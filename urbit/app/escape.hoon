::  escape: a reputation score for sponsors
::
::    data:            scry command:
::    ------------    ----------------------------------------------
::    sponsors        .^((set @p) %gx /=escape=/sponsors/noun)
::    events          .^((list event) %gx /=escape=/events/noun)
::    sponsees        .^((set @p) %gx /=escape=/sponsees/noun)
::    reputation      .^(reputation %gx /=escape=/reputation/<star>/noun)
::
/-  *escape, *beta, eth-watcher
/+  beta, default-agent, escape, verb, dbug
::  State
::
=>  |%
    +$  card  card:agent:gall
    ::
    +$  state-zero
      $:  %0
          sponsors=(map @p reputation)
          sponsees=(map @p @p)
          events=(list event)
          url=_'http://eth-mainnet.urbit.org:8545'
      ==
    --
::
::  Helpers
::
=>  |%
    ++  poke-spider
      |=  [=ship =path =cage]
      ^-  card
      [%pass [%request path] %agent [ship %spider] %poke cage]
    ::
    ++  watch-spider
      |=  [=ship =path =sub=path]
      ^-  card
      [%pass [%request path] %agent [ship %spider] %watch sub-path]
    ::
    ++  leave-spider
      |=  [=ship =path]
      ^-  card
      [%pass [%escape path] %agent [ship %spider] %leave ~]
    --
::
=|  state-zero
=*  state  -
::  Main
::
%-  agent:dbug
^-  agent:gall
%+  verb  |
=<  |_  =bowl:gall
    +*  this         .
        escape-core  +>
        ec           ~(. escape-core bowl)
        def          ~(. (default-agent this %|) bowl)
    ::
    ++  on-init
      ^-  (quip card _this)
      =+  bowl
      :: =/  sponsor=@p  (sein:title our now our)
      :: :-  ::[%pass /escape/request %arvo %b %wait (add now.bowl ~h1)]~
      :: :_  ~
      :: :*  %pass
      ::     /eth-watcher
      ::     %agent
      ::     [our.bowl %eth-watcher]
      ::     %watch
      ::     /logs/[dap.bowl]
      :: ==
      [~ this]
      :: %_    this
      ::     events
      ::   =<  all
      ::   %-  ~(add beta [~ ~])
      ::   :~  [now.bowl .~1.0 [%escape .~1.0] [%star sponsor]]
      ::       [now.bowl .~1.0 [%escape .~1.0] [%star sponsor]]
      ::       [now.bowl .~1.0 [%escape .~1.0] [%star sponsor]]
      ::       [now.bowl .~1.0 [%escape .~1.0] [%star sponsor]]
      ::       [now.bowl .~0.0 [%escape .~1.0] [%star ~dopzod]]
      ::       [now.bowl .~0.0 [%escape .~1.0] [%star ~binzod]]
      ::   ==
      :: ==
    ++  on-save
      !>(state)
    ::
    ++  on-load
      |=  old=vase
      ^-  (quip card _this)
      [~ this(state !<(state-zero old))]
    ::
    ++  on-poke
      |=  [=mark =vase]
      ^-  (quip card _this)
      ?+    mark  (on-poke:def mark vase)
          %escape-action
        =^  cards  state
          (handle-escape-action:ec !<(escape-action vase))
        [cards this]
      ==
    ::
    ++  on-watch
      |=  =path
      ^-  (quip card _this)
      :_  this
      ?+    path  ~|([%peer-escape-strange path] !!)
          [%updates ~]  ~
      ::
          [%escape ^]
        =^  cards  state
           (send-init-escape:ec i.t.path)
         cards
      ==
    ::
    ++  on-agent
      |=  [wir=wire =sign:agent:gall]
      ^-  (quip card _this)
      |^
      ?+  wir  (on-agent:def wir sign)
        [%request *]      (handle-request t.wir sign)
        [%eth-watcher *]  (handle-eth-watcher t.wir sign)
      ==
      ::
      ++  handle-request
        |=  [=wire =sign:agent:gall]
        ^-  (quip card _this)
        ?-    -.sign
            %poke-ack
          :_  this
          ?~  p.sign  ~
          ~&  ["escape couldn't start thread" u.p.sign]
          [(leave-spider our.bowl wire)]~
        ::
            %watch-ack
          :_  this
          ?~  p.sign  ~
          ~&(["escape couldn't start listen to thread" u.p.sign] ~)
        ::
            %kick
          [~ this]
        ::
            %fact
          ?+    p.cage.sign  (on-agent:def wire sign)
              %thread-fail
            =+  !<([=term =tang] q.cage.sign)
            ~&  ["eth-watcher failed; will retry" <term> tang]
            [~ this]
          ::
              %thread-done
            =^  cards  state
              (handle-thread-done:ec wire cage.sign)
            [cards this]
          ==
        ==
      ::
      ::  TODO: For more granularity, the eth-watcher will listen
      ::  to events coming from the blockchain, for our score, all
      ::  related to escapes and spawns.
      ::
      ++  handle-eth-watcher
        |=  [=wire =sign:agent:gall]
        ?+    -.sign  (on-agent:def wire sign)
            %fact
          ?+    p.cage.sign  (on-agent:def wire sign)
              %eth-watcher-diff
            =+  !<(diff=diff:eth-watcher q.cage.sign)
            =^  cards  state
              ?+  -.diff  ~|([%eth-watcher-strange-fact p.cage.sign] !!)
                %history  (update-events loglist.diff)
                %log      (update-events event-log.diff ~)
              ==
            [cards this]
          ==
        ==
      --
    ::
    ++  on-arvo
      |=  [=wire =sign-arvo]
      ^-  (quip card _this)
      =^  cards  state
        ?+    wire  (on-arvo:def wire sign-arvo)
            [%escape %request ~]
          ?+  +<.sign-arvo  (on-arvo:def wire sign-arvo)
            %wake           (wake:ec wire +>.sign-arvo)
          ==
        ==
      [cards this]
    ::
    ++  on-leave  on-leave:def
    ::
    ++  on-peek
      |=  =path
      ^-  (unit (unit cage))
      ?+    path  (on-peek:def path)
          [%x %reputation @p ~]
        ``noun+!>((~(got by sponsors) i.t.t.path))
      ::
          [%x %sponsors ~]
        ``noun+!>(~(key by sponsors))
      ::
          [%x %sponsees ~]
        ``noun+!>(~(key by sponsees))
      ::
          [%x %events ~]
        ``noun+!>(events)
      ==
    ::
    ++  on-fail   on-fail:def
    --
::
|_  =bowl:gall
++  sponsor
  ^-  @p
  (sein:title our.bowl now.bowl our.bowl)
::  +wake: timer wakeup event
::
++  wake
  |=  [wir=wire error=(unit tang)]
  ^-  (quip card _state)
  ~&  [wir error]
  :: ?^  error
  ::   ~&  error+u.error
    [~ state]
  :: ?>  ?=([%escape %request ~] wir)
  :: (request-ethereum-data ~ %sponsor)
::
++  request-ethereum-data
  |=  [ship=(unit @p) req=escape-request]
  ^-  (quip card _state)
  =/  filename=@t  :((cury cat 3) %escape '-' req)
  =/  new-tid=@ta
    (cat 3 'request--' (scot %uv eny.bowl))
  =/  args
    :^   ~  `new-tid  filename
    ?+  req  !!
      %all   !>(all:request)
      %ship  !>((ship:request (need ship)))
      :: %escapes  [%escape-request !>((escapes:request ship))]
      :: %spawns   [%escape-request !>((spawns:request ship))]
      :: %is-live  [%escape-request !>((is-live:request ship))]
    ==
  :_  state
  :~  (poke-spider our.bowl /[filename] %spider-start !>(args))
      (watch-spider our.bowl /[filename]/[new-tid] /thread-result/[new-tid])
      ::  resets the timer
      ::
      :: [%pass /escape/request %arvo %b %wait (add now.bowl ~h1)]
  ==
::
++  request
  |%
  ++  all
    ^-  [@t (list proto-read-request:rpc:ethereum)]
    :-  url
    %-  zing
    ::  for each ship we get 2 data points (escapes & spawns)
    ::  identified later by the id of the proto request
    ::
    %+  turn
      (gulf 256 (sub 260 1))
    |=(ship=@ ~[(sponsored ship) (spawned ship) (is-live ship)])
  ::
  ++  ship
    |=  ship=@p
    :-  [url (escapes ship)]
    [url (spawned ship)]
  ::
  ++  escapes
    |=  ship=@p
    ^-  proto-read-request:rpc:ethereum
    :+  (id 'escapes' ship)
       azimuth:contracts:azimuth
    ['getEscapeRequestsCount(uint32)' [%uint `@`ship]~]
  ::
  ++  spawned
    |=  ship=@p
    ^-  proto-read-request:rpc:ethereum
    :+  (id 'spawns' ship)
      azimuth:contracts:azimuth
    ['getSpawnCount(uint32)' [%uint `@`ship]~]
  ::
  ++  sponsored
    |=  ship=@p
    ^-  proto-read-request:rpc:ethereum
    :+  (id 'sponsored' ship)
      azimuth:contracts:azimuth
    ['getSponsoringCount(uint32)' [%uint `@`ship]~]
  ::
  ++  is-live
    |=  ship=@p
    ^-  proto-read-request:rpc:ethereum
    :+  (id 'isLive' ship)
       azimuth:contracts:azimuth
    ['isLive(uint32)' [%uint `@`ship]~]
  ::
  ++  id
    |=  [attr=@t ship=@p]
    ^-  (unit @t)
    `:((cury cat 3) attr '-' (scot %p ship))
  --
::
++  send-init-escape
  |=  name=@t
  ^-  (quip card _state)
  :_  state
  [%give %fact ~ %escape-update !>([%load ~])]~
::
++  handle-thread-done
  |=  [=wire =cage]
  ^-  (quip card _state)
  |^
  ?+  wire  ~|([dap.bowl %unexpected-thread-done wire] !!)
    [%escape-all @t ~]      (all !<((list [@t @t]) q.cage))
    [%escape-ship @t ~]  (ship !<([@t @t] q.cage))
    :: [%sponsor @t]  (sponsor !<([@t @t] q.cage))
    :: [%escapes ~]   (escapes !<(@t q.cage))
    :: [%spawns ~]    (spawns !<(@t q.cage))
  ==
  ::
  ++  all
    |=  ans=(list [id=@t res=@t])
    ^-  (quip card _state)
    =/  data=(list [sponsored=@rd spawned=@rd sponsor=@p is-live=?])
      |-
      ?~  ans  ~
      ?>  ?=([^ ^ ^] ans)
      =/  sponsored=@rd
        %-  sun:rd
        (decode-results:abi:ethereum res.i.ans [%uint]~)
      =/  spawned=@rd
        %-  sun:rd
        (decode-results:abi:ethereum res.i.t.ans [%uint]~)
      =/  is-live=?
        (decode-results:abi:ethereum res.i.t.t.ans [%bool]~)
      =+  ^-  [tape @t star=@p]
      (rash id.i.ans ;~(plug (star aln) hep ;~(pfix sig fed:ag)))
      :: =/  =score
      ::   (expected-value:beta success total prior)
      :: (~(put by sponsors) [star  ])
      :: ?:  (lte spawned sponsored)
      :: (add sponsored (sub spawned sponsored))
      ::
      :_  $(ans t.t.t.ans)
      [sponsored spawned star is-live]
    ~&  data
    [~ state]
  ::
  ++  ship
    |=  [escapes=@t spawns=@t]
    ^-  (quip card _state)
    =/  escs=@ud
      (decode-results:abi:ethereum escapes [%uint]~)
    =/  spaw=@ud
      (decode-results:abi:ethereum spawns [%uint]~)
    ~&  [escs spaw]
    [~ state]
  ::
  :: ++  sponsor
  ::   |=  [escapes=@t spawns=@t]
  ::   ^-  (quip card _state)
  ::   =/  escs=@ud
  ::     (decode-results:abi:ethereum escapes [%uint]~)
  ::   =/  spaw=@ud
  ::     (decode-results:abi:ethereum spawns [%uint]~)
  ::   ~&  [escs spaw]
  ::
  ::   =/  score-marzod=@rd  (score:beta .~0.5 ~ ~ `[%star ~marzod])
  ::   =/  score-binzod=@rd  (score:beta .~0.5 ~ ~ `[%star ~binzod])
  ::
  ::   (~(put by sponsors) ^sponsor)
  ::   =/  =reputation
  ::     [~(get by *reputation) []~]
  ::   :-  ~
  ::   %_  state
  ::     sponsors  (~(put by sponsors) [^sponsor ])
  ::   ==
  :: ::
  :: ++  escapes
  ::   |=  res=@t
  ::   ^-  (quip card _state)
  ::   =/  escapes=@ud
  ::     (decode-results:abi:ethereum res [%uint]~)
  ::   ~&  escapes
  ::   [~ state]
  ::   :: =/  =reputation
  ::   ::   (~(got by sponsors) (sein:title our.bowl now our.bowl))
  ::   :: =.  reputation
  ::   ::   (~(put reputation) [dimension.reputation new-score])
  ::
  ::   :: (sein:title our.bowl now our.bowl)
  :: ::
  :: ++  spawns
  ::   |=  res=@t
  ::   ^-  (quip card _state)
  ::   =/  spawns=@ud
  ::     (decode-results:abi:ethereum res [%uint]~)
  ::   ~&  spawns
  ::   [~ state]
  ::   :: (sein:title our.bowl now our.bowl)
  --
::
++  handle-escape-action
  |=  act=escape-action
  ^-  (quip card _state)
  |^
  ?-  -.act
    %init     handle-init
    %all      (request-ethereum-data ~ %all)
    %ship     (request-ethereum-data `+.act %ship)
    %sponsor  (request-ethereum-data `sponsor %ship)
    %listen   handle-listen
    %clear    [~ state(events ~)]
    :: %spawns   (handle-spawns-request +.act)
  ==
  ::
  ++  handle-init
    ^-  (quip card _state)
    =/  args=vase
      !>
      :+  %watch  /[dap.bowl]
      ^-  config:eth-watcher
      :*  url  |  ~s10  ~m2
          launch:contracts:azimuth
          ~[azimuth:contracts:azimuth]
        ::
        :_  [(gulf 0 (sub 1 1)) ~]
        =>  azimuth-events:azimuth
        ~[spawned escape-accepted]
      ==
    :_  state
    [%pass /init %agent [our.bowl %eth-watcher] %poke %eth-watcher-poke args]~
  ::
  ++  handle-listen
    ^-  (quip card _state)
    :_  state
    :_  ~
    :*  %pass
        /eth-watcher
        %agent
        [our.bowl %eth-watcher]
        %watch
        /logs/[dap.bowl]
    ==
  --
::
++  update-sponsor-scores
  |=  events=(list event)
  ^-  (map @p reputation)
  =|  updated-sponsors=(map @p reputation)
  =/  beta  (~(add beta [~ ~]) events)
  =/  sponsors=(list @p)  ~(val by sponsees)
  |-  ^-  (map @p reputation)
  ?~  sponsors  updated-sponsors
  =/  sponsor=@p  i.sponsors
  =/  rep=(unit reputation)
    (~(get by sponsors.state) sponsor)
  =/  new-score=@rd
    (score:beta .~0.5 ~ ~ `[%star sponsor])
  =/  =reputation
    ?~  rep
      (~(gas by `reputation`~) [[%escape .~1.0] new-score]~)
    (~(put by u.rep) [[%escape .~1.0] new-score])
  %_  $
    sponsors          t.sponsors
    updated-sponsors  (~(put by sponsors.state) [sponsor reputation])
  ==
::
++  update-events
  |=  logs=(list event-log:rpc:ethereum)
  ^-  (quip card _state)
  |^
  =/  [sponsees=(map @p @p) events=(list event)]
    (parse-event-log logs)
  =.  sponsees.state  sponsees
  =.  events.state  events
  [~ state(sponsors (update-sponsor-scores events))]
  ::
  ++  parse-event-log
    |=  logs=(list event-log:rpc:ethereum)
    ^-  [(map @p @p) (list event)]
    =/  parsed=(list (unit [[sponsee=@p sponsor=@p] (list event)]))
      %+  turn  logs
      |=  =event-log:rpc:ethereum
      ^-  (unit [[@p @p] (list event)])
      =/  =azimuth-event  (parse-azimuth-event event-log)
      ?~  azimuth-event  ~
      ?-  -.u.azimuth-event
        %spawn   `(parse-spawns +.u.azimuth-event)
        %escape  `(parse-escapes +.u.azimuth-event)
      ==
    =|  sponsees=(map @ @)
    =|  events=(list event)
    |-
    ?~  parsed
      :-  sponsees
      all:(~(add beta [~ events.state]) events)
    ?~  i.parsed  $(parsed t.parsed)
    =+  sponsee=sponsee.-.u.i.parsed
    =+  sponsor=sponsor.-.u.i.parsed
    %_  $
      parsed    t.parsed
      events    (weld events +.u.i.parsed)
      sponsees  (~(put by sponsees.state) [sponsee sponsor])
    ==
  ::
  ++  parse-azimuth-event
    |=  =event-log:rpc:ethereum
    ^-  azimuth-event
    ?~  mined.event-log
      ~
    ?:  removed.u.mined.event-log
      ~&  [%removed-log event-log]
      ~
    =/  =id:block:able:jael  [block-hash block-number]:u.mined.event-log
    =,  azimuth-events:azimuth
    =,  abi:ethereum
    ?:  =(spawned i.topics.event-log)
      =/  [star=@ planet=@]
        (decode-topics t.topics.event-log ~[%uint %uint])
      `[%spawn id star planet]
    ?.  =(escape-accepted i.topics.event-log)  ~
    =/  [planet=@ star=@]
      (decode-topics t.topics.event-log ~[%uint %uint])
    `[%escape id planet star]
  ::
  ++  parse-spawns
    |=  [=id:block:able:jael sponsor=@p sponsee=@p]
    ^-  [[@p @p] (list event)]
    :-  [sponsee sponsor]
    [id ~ .~1.0 [%escape .~1.0] [%star sponsor]]~
  ::
  ++  parse-escapes
    |=  [=id:block:able:jael sponsee=@p sponsor=@p]
    ^-  [[@p @p] (list event)]
    =/  old-sponsor=@p  (~(got by sponsees) sponsee)
    :-  [sponsee sponsor]
    :~  [id ~ .~1.0 [%escape .~1.0] [%star sponsor]]
        [id ~ .~0.0 [%escape .~1.0] [%star old-sponsor]]
    ==
  --
--

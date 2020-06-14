::  escape: a reputation score for urbit sponsors
::
::    data:            scry command:
::    ------------    ----------------------------------------------
::    sponsors       .^((set @p) %gx /=escape=/sponsors/noun)
::    n-sponsors     ~(wyt in .^((set @p) %gx /=escape=/sponsors/noun))
::    events         .^((list event) %gx /=escape=/events/noun)
::    sponsees       .^((set @p) %gx /=escape=/sponsees/noun)
::    reputation     .^(reputation %gx /=escape=/reputation/<@p>/noun)
::    sort-sponsors  .^((list [@p reputation]) %gx /=escape=/sponsors/sort/noun)
::
/-  *escape, *beta, eth-watcher
/+  beta, default-agent, escape, verb, dbug
::  State
::
=>  |%
    +$  card       card:agent:gall
    +$  loglist    loglist:eth-watcher
    +$  event-log  event-log:rpc:ethereum
    ::
    +$  state-zero
      $:  %0
          sponsors=(map @p reputation)
          sponsees=(map @p [=ship active=?])
          events=(list event)
          weights=(map term weight)
          prior=@rd
          url=@t
          ::  From: /app/gaze.hoon
          ::
          running=(unit @ta)
          qued=loglist
          time=(map @ud @da)
      ==
    --
::
::  Helpers
::
=>  |%
    ++  poke-spider
      |=  [=ship =path =cage]
      ^-  card
      [%pass path %agent [ship %spider] %poke cage]
    ::
    ++  watch-spider
      |=  [=ship =path =sub=path]
      ^-  card
      [%pass path %agent [ship %spider] %watch sub-path]
    ::
    ++  leave-spider
      |=  [=ship =path]
      ^-  card
      [%pass [%escape path] %agent [ship %spider] %leave ~]
    ::
    ++  poke-watcher
      |=  [req=escape-request =ship args=vase]
      ^-  card
      :*  %pass
          /init/[req]
          %agent
          [ship %eth-watcher]
          %poke
          %eth-watcher-poke
          args
      ==
    ::
    ++  watch-watcher
      |=  [req=escape-request =ship]
      ^-  card
      :*  %pass
          /eth-watcher/[req]
          %agent
          [ship %eth-watcher]
          %watch
          /logs/escape/[req]
      ==
    ::
    ++  leave-watcher
      |=  [req=escape-request =ship args=vase]
      ^-  card
      :*  %pass
          /leave/[req]
          %agent
          [ship %eth-watcher]
          %poke
          %eth-watcher-poke
          args
      ==
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
    ++  on-init  on-init:def
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
      ~&  mark
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
        [%req *]          (handle-request t.wir sign)
        [%eth-watcher *]  (handle-eth-watcher t.wir sign)
        [%timestamps *]   (handle-timestamps t.wir sign)
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
      ++  handle-eth-watcher
        |=  [=wire =sign:agent:gall]
        ^-  (quip card _this)
        ?+    wire  (on-agent:def wir sign)
            [%all *]
          ?+    -.sign  (on-agent:def wire sign)
              %fact
            ?+    p.cage.sign  (on-agent:def wire sign)
                %eth-watcher-diff
              =+  !<(diff=diff:eth-watcher q.cage.sign)
              =^  cards  state
                ?+    -.diff  ~|([%eth-watcher-strange-fact p.cage.sign] !!)
                    %history
                  =.  qued  ~
                  (update-events:ec loglist.diff)
                ::
                    %log
                  (update-events:ec event-log.diff ~)
                ==
              [cards this]
            ==
          ==
        ::
            [%are-live *]
          ?+    -.sign  (on-agent:def wire sign)
              %fact
            ?+    p.cage.sign  (on-agent:def wire sign)
                %eth-watcher-diff
              =+  !<(diff=diff:eth-watcher q.cage.sign)
              =^  cards  state
                ?+  -.diff  ~|([%eth-watcher-strange-fact p.cage.sign] !!)
                    %history
                  =.  qued  ~
                  (check-sponsor-live:ec loglist.diff)
                ::
                    %log
                  (check-sponsor-live:ec ~[event-log.diff])
                ==
              [cards this]
            ==
          ==
        ==
      ::
      ++  handle-timestamps
        |=  [=wire =sign:agent:gall]
        ^-  (quip card _this)
        :: ~&  ["handle-timestamps" wire]
        ?+    -.sign  (on-agent:def wire sign)
            %fact
          ?+  p.cage.sign  (on-agent:def wire sign)
              %thread-fail
            =+  !<([=term =tang] q.cage.sign)
            =/  =tank  leaf+"{(trip dap.bowl)} thread failed; will retry"
            %-  (slog tank leaf+<term> tang)
            =^  cards  state
              (request-ethereum-data:ec ~ %timestamps)
            [cards this]
          ::
              %thread-done
            =^  cards  state
              %-  save-timestamps:ec
              !<((list [@ud @da]) q.cage.sign)
            [cards this]
          ==
        ==
      --
    ::
    ++  on-arvo
      |=  [=wire =sign-arvo]
      ^-  (quip card _this)
      ~&  [wire sign-arvo]
      =^  cards  state
        ?+    wire  (on-arvo:def wire sign-arvo)
            [%escape %request ~]
          ?+  +<.sign-arvo  (on-arvo:def wire sign-arvo)
            %wake  (wake:ec wire +>.sign-arvo)
          ==
        ::
            [%watch ~]
          ?+  +<.sign-arvo  (on-arvo:def wire sign-arvo)
            %wake  (wake:ec wire +>.sign-arvo)
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
          [%x %reputation @t ~]
        =/  sponsor=@p
          (rash i.t.t.path ;~(pfix sig fed:ag))
        ``noun+!>((~(got by sponsors) sponsor))
      ::
          [%x %sponsors ~]
        ``noun+!>(~(key by sponsors))
      ::
          [%x %sponsors %sort ~]
        ``noun+!>((sort-sponsors %escape))
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
  :_  state
  [(watch-watcher %all our.bowl)]~
::
++  request-block-times
  ^-  (quip card _state)
  =/  tid=@ta  (cat 3 'request--' (scot %uv eny.bowl))
  =/  file=@t  %eth-get-timestamps
  =/  args     [~ `tid file !>(timestamps:request)]
  :_  state
  :~  (poke-spider our.bowl /timestamps/[file] %spider-start !>(args))
      (watch-spider our.bowl /timestamps/[file]/[tid] /thread-result/[tid])
  ==
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
      %all         !>(all:request)
      %ship        !>((ship:request (need ship)))
      :: %escapes  [%escape-request !>((escapes:request ship))]
      :: %spawns   [%escape-request !>((spawns:request ship))]
      :: %are-live  !>((are-live:request ship))
    ==
  :_  state
  :~  (poke-spider our.bowl /req/[filename] %spider-start !>(args))
      (watch-spider our.bowl /req/[filename]/[new-tid] /thread-result/[new-tid])
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
      (gulf 256 (sub 513 1))
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
  ++  are-live
    ^-  [@t (list proto-read-request:rpc:ethereum)]
    :-  url
    (turn (gulf 256 (sub 260 1)) |=(ship=@ (is-live ship)))
  ::
  ++  is-live
    |=  ship=@p
    ^-  proto-read-request:rpc:ethereum
    :+  (id 'isLive' ship)
       azimuth:contracts:azimuth
    ['isLive(uint32)' [%uint `@`ship]~]
  ::
  ++  timestamps
    ^-  [url=@t blocks=(list @ud)]
    :-  url.state
    =-  ~(tap in -)
    %-  ~(gas in *(set @ud))
    ^-  (list @ud)
    %+  turn  qued
    |=  log=event-log:rpc:ethereum
    block-number:(need mined.log)
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
    [%escape-all @t ~]   (all !<((list [@t @t]) q.cage))
    [%escape-ship @t ~]  (ship !<([@t @t] q.cage))
    :: [%sponsor @t]  (sponsor !<([@t @t] q.cage))
    :: [%escapes ~]   (escapes !<(@t q.cage))
    :: [%spawns ~]    (spawns !<(@t q.cage))
  ==
  ::
  ++  all
    |=  ans=(list [id=@t res=@t])
    ^-  (quip card _state)
    ~&  "all"
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
    ~&  all+(lent data)
    ~&  active+(lent (skim data |=([@rd @rd @p is-live=?] is-live)))
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
  ?+  -.act  !!
    %init      (handle-init +.act)
    %all       (request-ethereum-data ~ %all)
    %ship      (request-ethereum-data `+.act %ship)
    %sponsor   (request-ethereum-data `sponsor %ship)
    %clear     [~ state(events ~, sponsors ~, sponsees ~, running ~, qued ~, time ~)]
    %leave     (handle-leave +.act)
    %are-live  handle-are-live
  ==
  ::
  ++  handle-init
    ::  TODO: add option to choose type of sponsor (star, galaxy)
    ::
    |=  [url=@t prior=@rd dimensions=(list [term weight])]
    ^-  (quip card _state)
    ~&  "poking eth-watcher..."
    :_  %_  state
          url      url
          prior    prior
          weights  (~(gas by weights) dimensions)
        ==
    :~  (poke-watcher %all our.bowl (ethereum-config %all url))
        ::  From: /app/gaze.hoon
        ::  we punt on subscribing to the eth-watcher for a little while.
        ::  this way we get a %history diff containing all past events,
        ::  instead of so many individual %log diffs that we bail meme.
        ::  (to repro, replace this with:
        ::    (watch-watcher %all our.bowl)
        ::  )
        ::
        :: [%pass /watch %arvo %b %wait (add now.bowl ~m35)]
        [%pass /watch %arvo %b %wait (add now.bowl ~m4)]
    ==

  ::
  ++  handle-leave
    |=  req=escape-request
    ^-  (quip card _state)
    :_  state
    :~  %:  leave-watcher
            %all
            our.bowl
            !>([%clear /escape/[req]])
        ==
      ::
        :*  %pass
            /eth-watcher/[req]
            %agent
            [our.bowl %eth-watcher]
            %leave
            ~
    ==  ==
   ::
  ::
  ++  handle-are-live
    ^-  (quip card _state)
    ~&  "poking eth-watcher..."
    =/  args=vase  (ethereum-config %are-live url.state)
    :_  state
    :~  (watch-watcher %are-live our.bowl)
        (poke-watcher %are-live our.bowl args)
    ==
  --
::
++  ethereum-config
  |=  [req=escape-request url=@t]
  ^-  vase
  !>
  :+  %watch  /escape/[req]
  ^-  config:eth-watcher
  ::  TODO: Try with:
  ::  :*  state.url  %.n  ~h4  ~h2
  ::
  :*  url  %.n  ~m5  ~h2
      :: launch:contracts:azimuth
      public:mainnet-contracts:azimuth
      ~[azimuth:contracts:azimuth]
    ::
      :_  ~
      :: :_  [^-((list @) [2.824.325.100 `@`~wicdev-wisryt `@`~migfed (gulf 256 256)]) ~]
      =>  [azimuth-events:azimuth .]
      ?+  req  !!
        %all       ~[spawned escape-accepted activated]
        %are-live  ~[activated]
  ==  ==
::
++  update-events
  |=  logs=(list event-log)
  ^-  (quip card _state)
  :: ~&  (lent logs)
  |^
  :: =.  qued  (weld qued logs)
  :: :: ~&  (lent qued)
  ?~  logs  ~&  "no logs"  [~ state]
  ~&  logs+(lent logs)
  =/  [events=_events sponsees=_sponsees]
    :: (process-event-log qued)
    (roll `loglist`logs reduce-event-log)
  :: ?~  events
  ::   [~ state(sponsees (~(uni by sponsees.state) sponsees))]
  ~&  :*  sponsors=~(wyt by sponsors.state)
          old-sponsees=~(wyt by sponsees.state)
          new-sponsees=~(wyt by sponsees)
          old-events=(lent events.state)
          new-events=(lent events)
      ==
  :: =/  tid=@ta  (cat 3 'request--' (scot %uv eny.bowl))
  :: =?  qued
  ::   ?=(^ rest)  (flop rest)
  :: =.  qued.state  (flop rest)
  :: ~&  running+running
  :: :-  ?:  |(?=(^ running) =((lent rest) 0))
  ::       ~&  "no timestamping"
  ::       ~
  ::     ~&  "timestamping"
  ::     =/  file=@t  %eth-get-timestamps
  ::     =/  args     [~ `tid file !>(timestamps:request)]
  ::     :~  (poke-spider our.bowl /timestamps/[file] %spider-start !>(args))
  ::         (watch-spider our.bowl /timestamps/[file]/[tid] /thread-result/[tid])
  ::     ==
  :-  ~
  %=    state
      :: qued    (flop rest)  ::  oldest first
    ::  FIXME: bail: foul bailing out
    ::
    :: :-  i.events
    :: ?.  ?=(^ t.events)  events
    :: [i.t.events events]
    :: FIXME: bails meme
    ::
  ::
      events
    (weld events.state events)
  ::
      sponsees
    (~(uni by sponsees.state) sponsees)
  ::
      sponsors
    (~(uni by sponsors.state) (update-sponsor-scores events sponsees))
      :: running   ?^(running running.state `tid)
  ==
  ::
  :: ++  process-event-log
  ::   |=  logs=(list event-log:rpc:ethereum)
  ::   =|  sponsees=(map @p [@p ?])
  ::   =|  events=(list event)
  ::   |-  ^-  [_sponsees _events]
  ::   ?~  logs
  ::     [sponsees events]
  ::   =/  =azimuth-event  (process-azimuth-event i.logs)
  ::   ?~  azimuth-event
  ::     $(logs t.logs)
  ::   =/  [[sponsee=@p sponsor=@p active=?] new-events=(list event)]
  ::     ?-  -.u.azimuth-event
  ::       %spawn   (process-spawn +.u.azimuth-event)
  ::       %escape  (process-escape +.u.azimuth-event)
  ::       %active  (process-active +.u.azimuth-event)
  ::     ==
  ::   %_  $
  ::     logs      t.logs
  ::     events    (weld events new-events)
  ::     sponsees  (~(put by sponsees) [sponsee [sponsor active]])
  ::   ==
  ::
  ++  reduce-event-log
    ::  sponsees is innitialized with the current 'global' value
    ::
    |=  [log=event-log [events=(list event) sponsees=_sponsees.state]]
    ^+  [events sponsees]
    |^
    :: =?  sponsees  =(~ sponsees)
    ::   ~&  ['init sponsees with:' ~(wyt by sponsees.state)]
    ::   (~(uni by sponsees) sponsees.state)
    :: ~&  [old-events=(lent events.state) new-events=(lent events)]
    ::  to ensure logs are processed in sane order,
    ::  stop processing as soon as we skipped one
    ::
    :: ?^  rest  [[log rest] events sponsees]
    :: =/  timestamp=(unit @da)
    ::   %-  ~(get by time)
    ::   block-number:(need mined.log)
    :: ?~  timestamp
    ::   :: ~&  ["rolling" rest=(lent rest) events=(lent events)]
    ::   [[log rest] events sponsees]
    :: :-  rest
    =/  =azimuth-event
      (process-azimuth-event log)
    ?~  azimuth-event
      [events sponsees]
    =/  [[sponsee=@p sponsor=@p active=?] new-events=(list event)]
      ?-  -.u.azimuth-event
        %spawn   (process-spawn +.u.azimuth-event)
        %escape  (process-escape +.u.azimuth-event)
        %active  (process-active +.u.azimuth-event)
      ==
    :: ~&  ["process" sponsees=~(wyt by sponsees) new-incoming-events=(lent new-events)]
    :-  (weld events new-events)
    (~(put by sponsees) [sponsee [sponsor active]])
    ::
    ++  process-azimuth-event
      |=  =event-log:rpc:ethereum
      ^-  azimuth-event
      ?~  mined.event-log
        ~
      ?:  removed.u.mined.event-log
        ~&  [%removed-log event-log]
        ~
      :: =/  =id:block:able:jael  [block-hash block-number]:u.mined.event-log
      =/  id=@t  (scot %uv eny.bowl)
      =,  azimuth-events:azimuth
      =,  abi:ethereum
      ?:  =(spawned i.topics.event-log)
        =/  [sponsor=@ sponsee=@]
          (decode-topics t.topics.event-log ~[%uint %uint])
        ?.  =(%duke (clan:title sponsee))
          ~
        :: ~&  `[%spawn id sponsor sponsee]
        `[%spawn id sponsor sponsee]
      ?:  =(activated i.topics.event-log)
        =/  ship=@
          (decode-topics t.topics.event-log ~[%uint])
        ?.  =(%duke (clan:title ship))
          ~
        :: ~&  `[%active id `@p`ship]
        `[%active id ship]
      ?.  =(escape-accepted i.topics.event-log)  ~
      =/  [sponsee=@ sponsor=@]
        (decode-topics t.topics.event-log ~[%uint %uint])
      ?.  =(%duke (clan:title sponsee))
        ~
      :: ~&  `[%escape id sponsee sponsor]
      `[%escape id sponsee sponsor]
    ::
    ++  process-spawn
      |=  [id=@t sponsor=@p sponsee=@p]
      ^-  [[@p @p ?] (list event)]
      :: ~&  spawn+[local-sponsees=~(wyt by sponsees) total-sponsees=~(wyt by sponsees.state)]
      :: ~&  [%spawn [sponsee sponsor %.n]]
      [[sponsee sponsor %.n] ~]
      :: :-  [sponsee sponsor %.n]
      :: [id ~ .~1.0 [%escape eth-spawn-weight] [%star sponsor]]~
    ::
    ++  process-active
      |=  [id=@t sponsee=@p]
      ^-  [[@p @p ?] (list event)]
      :: ~&  active+[local-sponsees=~(wyt by sponsees) total-sponsees=~(wyt by sponsees.state)]
      :: ~&  [%active sponsee (~(get by sponsees) sponsee) %.y]
      =/  test=(unit [sponsor=@p ?])  (~(get by sponsees) sponsee)
      =-  ?~  test  ~&  who+sponsee  -
          -
      :-  [sponsee ?~(test *@p sponsor.u.test) %.y]
      [id ~ .~1.0 %spawn [%star ?~(test *@p sponsor.u.test)]]~
    ::
    ++  process-escape
      |=  [id=@t sponsee=@p sponsor=@p]
      ^-  [[@p @p ?] (list event)]
      :: ~&  escape-1+[planet=sponsee star=sponsor]
      =/  test=(unit [old-sponsor=@p ?])  (~(get by sponsees) sponsee)
      ~&  :-  %escape
          :*  old-sponsor=?~(test *@p old-sponsor.u.test)
              planet=sponsee
              star=sponsor
              events-so-far=(lent events)
              local-sponsees=~(wyt by sponsees)
              total-sponsees=~(wyt by sponsees.state)
          ==
      :-  [sponsee sponsor %.y]
      :~  [id ~ .~1.0 %escape [%star sponsor]]
          [id ~ .~0.0 %escape [%star ?~(test *@p old-sponsor.u.test)]]
      ==
    --
  --
::
++  update-sponsor-scores
  |=  [events=(list event) sponsees=(map @p [=ship active=?])]
  ^-  (map @p reputation)
  :: =/  beta  (~(add beta ~) events ^-((map term weight) weights))
  =/  beta  ~(. beta events weights)
  :: =|  updated-sponsors=_sponsors.state
  :: =/  sponsors=(list [=ship active=?])  ~(val by sponsees)
  ~&  ["updating sponsors" events=(lent events) sponsees=~(wyt by sponsees) sponsors=(lent sponsors)]
  %+  roll  ~(val by sponsees)
  |=  [[sponsor=@p active=?] sponsors=_sponsors.state]
  ^+  sponsors
  :: |-  ^-  (map @p reputation)
  :: ?~  sponsors
  ::   ~&  ["done" ~(wyt by updated-sponsors)]
  ::   :: sponsors.state
  ::   updated-sponsors
  ?.  active  sponsors
  ::   ::  sponsee is not active
  ::   ::
  ::   ~&  ["not active" ship.i.sponsors (~(get by sponsors.state) ship.i.sponsors)]
    :: $(sponsors t.sponsors)
  =/  rep=(unit reputation)
    (~(get by sponsors.state) sponsor)
  =/  [local-score=@rd local-success=@rd local-total=@rd]
    (score:beta prior.state ~ ~ `[%star sponsor])
  =/  =reputation
    ?~  rep
      %-  ~(gas by `reputation`~)
      [%escape [local-score local-success local-total]]~
    %+  ~(jab by u.rep)
      %escape
    |=  [@rd s=@rd t=@rd]
    =+  success=(add:rd s local-success)
    =+  total=(add:rd t local-total)
    :_  [success total]
    (expected-value:beta [success total prior.state])
  (~(put by sponsors) [sponsor reputation])
  :: %_  $
  ::   sponsors        t.sponsors
  ::   :: sponsors.state  (~(put by sponsors.state) [ship.i.sponsors reputation])
  ::   updated-sponsors  (~(put by sponsors.state) [ship.i.sponsors reputation])
  :: ==
::
++  check-sponsor-live
  |=  logs=(list event-log:rpc:ethereum)
  ^-  (quip card _state)
  ?~  logs  ~&("no events" [~ state])
  =/  parsed=(list (unit @p))
    %+  turn  logs
    |=  =event-log:rpc:ethereum
    ^-  (unit @p)
    ?~  mined.event-log
      ~
    ?:  removed.u.mined.event-log
      ~&  [%removed-log event-log]
      ~
    =/  =id:block:able:jael  [block-hash block-number]:u.mined.event-log
    =,  azimuth-events:azimuth
    =,  abi:ethereum
    ?.  =(activated i.topics.event-log)  ~
    =/  ship=@  (decode-topics t.topics.event-log ~[%uint])
    ?.  =((clan:title `@p`ship) %king)  ~
    ~&  `@p`ship
    `ship
  [~ state]
::
++  sort-sponsors
  |=  dimension=term
  ^-  (list [@p reputation])
  =;  sorted
    %+  turn  sorted
    |=  [sponsor=@p b=reputation]
    ?>  ?=(^ reputation)
    :-  sponsor
    %+  ~(jab by b)  %escape
    |=  [score=@rd s=@rd t=@rd]
    :_  [s t]
    %-  sub:rd
    ?:  (lth score .~1.0)
      [.~1.0 score]
    [score .~1.0]
  %+  sort  ~(tap by sponsors)
  |=  [[@p a=reputation] [@p b=reputation]]
  =/  [a=score *]  (~(got by a) dimension)
  =/  [b=score *]  (~(got by b) dimension)
  (lth:rd b a)
::
::  +save-timestamps: store timestamps into state (from: /app/gaze.hoon)
::
++  save-timestamps
  |=  timestamps=(list [@ud @da])
  ^-  (quip card _state)
  ~&  "saving timestamps"
  =.  time     (~(gas by time) timestamps)
  =.  running   ~
  (update-events ~)
::
:: ++  time-order-check
::   ^-  [rest=loglist logs=(list [wen=@da wat=event])]
::   %+  roll  `loglist`qued
::   |=  [log=event-log:rpc [rest=loglist logs=(list [wen=@da wat=event])]]
::   ::  to ensure logs are processed in sane order,
::   ::  stop processing as soon as we skipped one
::   ::
::   ?^  rest  [[log rest] logs]
::   =/  tim=(unit @da)
::     %-  ~(get by time)
::     block-number:(need mined.log)
::   ?~  tim  [[log rest] logs]
::   :-  rest
::   =+  ven=(event-log-to-event log)
::   ?~  ven  logs
::   [[u.tim u.ven] logs]
--

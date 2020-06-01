::  escape-view: "What's the Escape of my star?"
::
/-  *escape
/+  *server, default-agent, verb, *escape
::
/=  index
  /^  octs
  /;  as-octs:mimes:html
  /:  /===/app/escape/index
  /|  /html/
      /~  ~
  ==
/=  tile-js
  /^  octs
  /;  as-octs:mimes:html
  /:  /===/app/escape/js/tile
  /|  /js/
      /~  ~
  ==
/=  script
  /^  octs
  /;  as-octs:mimes:html
  /:  /===/app/escape/js/index
  /|  /js/
      /~  ~
  ==
/=  style
  /^  octs
  /;  as-octs:mimes:html
  /:  /===/app/escape/css/index
  /|  /css/
      /~  ~
  ==
/=  escape-png
  /^  (map knot @)
  /:  /===/app/escape/img  /_  /png/
::  State
::
=>  |%
    +$  card  card:agent:gall
    ::
    +$  state
      $%  [%0 state-zero]
      ==
    ::
    +$  state-zero
      $:  ~
      ==
    --
::
=|  state-zero
=*  state  -
::  Main
::
^-  agent:gall
=<  |_  =bowl:gall
    +*  this  .
        cv    ~(. +> bowl)
        def   ~(. (default-agent this %|) bowl)
    ::
    ++  on-init
      ^-  (quip card _this)
      :_  this
      :~  [%pass /bind/escape %arvo %e %connect [~ /'~escape'] %escape-view]
          [%pass /updates %agent [our.bowl %escape] %watch /updates]
        ::
          ::  Add tile to %launch
          ::
          :*  %pass
              /launch/escape
              %agent
              [our.bowl %launch]
              %poke
              %launch-action
              !>([%add %escape-view /escapetile '/~escape/js/tile.js'])
     ==   ==
    ::
    ++  on-poke
      |=  [=mark =vase]
      ^-  (quip card _this)
      ?>  (team:title our.bowl src.bowl)
      ?+    mark  (on-poke:def mark vase)
          %json
        =^  cards  state
          (handle-json:cv !<(json vase))
        [cards this]
      ::
          %handle-http-request
        =+  !<([eyre-id=@ta =inbound-request:eyre] vase)
        =+  url=(parse-request-line url.request.inbound-request)
        :_  this
        %+  give-simple-payload:app  eyre-id
        (poke-handle-http-request:cv inbound-request site.url)
      ::
          %escape-view
        =^  cards  state
          (handle-escape-view:cv !<(escape-view vase))
        [cards this]
      ==
    ::
    ++  on-watch
      |=  =path
      ^-  (quip card _this)
      :_  this
      ?+    path  ~|([%peer-escape-strange path] !!)
          [%escapetile ~]
        [%give %fact ~ %json !>(*json)]~
      ::
          [%primary *]
        =^  cards  state
          (handle-escape-view:cv [%init ~])
        cards
      ::
          [%http-response *]
        ~
      ==
    ::
    ++  on-agent
      |=  [=wire =sign:agent:gall]
      ^-  (quip card _this)
      ?-    -.sign
          %poke-ack   (on-agent:def wire sign)
          %watch-ack  (on-agent:def wire sign)
          %kick       (on-agent:def wire sign)
      ::
          %fact
        =^  cards  state
          =*  vase  q.cage.sign
          ^-  (quip card _state)
          ?+    p.cage.sign  ~|([%escape-bad-update-mark wire vase] !!)
              %escape-view
            (handle-view-update:cv !<(escape-view q.cage.sign))
          ==
        [cards this]
      ==
    ::
    ++  on-arvo
      |=  [=wire =sign-arvo]
      ^-  (quip card _this)
      ?:  ?=(%bound +<.sign-arvo)
        [~ this]
      (on-arvo:def wire sign-arvo)
    ::
    ++  on-save   on-save:def
    ++  on-load   on-load:def
    ++  on-leave  on-leave:def
    ++  on-peek   on-peek:def
    ++  on-fail   on-fail:def
    --
::
|_  =bowl:gall
:: ++  gallery-scry
::   .^  (list escape)
::     %gx
::     (scot %p our.bowl)
::     %escape
::     (scot %da now.bowl)
::     /gallery/noun
::   ==
:: ::
:: ++  escape-scry
::   |=  name=@t
::   ^-  escape-view-response
::   :+  %load  name
::   .^  escape
::     %gx
::     (scot %p our.bowl)
::     %escape
::     (scot %da now.bowl)
::     ~[%escape name %noun]
::   ==
:: ::
:: ++  chats-scry
::   ^-  (list path)
::   %~  tap   by
::   .^  (set path)
::     %gx
::     (scot %p our.bowl)
::     %chat-store
::     (scot %da now.bowl)
::     /keys/noun
::   ==
::
++  send-escape-action
  |=  [=wire act=escape-action]
  ^-  card
  [%pass wire %agent [our.bowl %escape] %poke %escape-action !>(act)]
::
++  send-frontend
  |=  =json
  ^-  (list card)
  [%give %fact [/primary]~ %json !>(json)]~
::
++  handle-json
  |=  jon=json
  ^-  (quip card _state)
  ?>  (team:title our.bowl src.bowl)
  ::  Actions originated on the frontend
  ::
  (handle-escape-view (json-to-escape-view jon))
::
++  handle-view-update
  |=  act=escape-view
  ^-  (quip card _state)
  :_  state
  ?+  -.act  !!
    %load    ~
  ==
::
++  poke-handle-http-request
  |=  [=inbound-request:eyre url=(list @t)]
  ^-  simple-payload:http
  |^
  %+  require-authorization:app
    inbound-request
  handle-auth-call
  ::
  ++  handle-auth-call
    |=  =inbound-request:eyre
    ^-  simple-payload:http
    =/  url=request-line
      (parse-request-line url.request.inbound-request)
    ?+  site.url  not-found:gen
      [%'~escape' %css %index ~]  (css-response:gen style)
      [%'~escape' %js %tile ~]    (js-response:gen tile-js)
      [%'~escape' %js %index ~]   (js-response:gen script)
      [%'~escape' %img @t *]      (handle-img-call i.t.t.site.url)
      [%'~escape' *]              (html-response:gen index)
    ==
  ::
  ++  handle-img-call
    |=  name=@t
    ^-  simple-payload:http
    =/  img  (~(get by escape-png) name)
    ?~  img
      not-found:gen
    (png-response:gen (as-octs:mimes:html u.img))
  --
--

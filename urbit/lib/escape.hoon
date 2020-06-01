/-  *escape
|%
++  escspe-response-to-json
  |=  act=escape-view-response
  ^-  json
  =,  enjs:format
  |^
  %+  frond  -.act
  ?+     -.act  ~|(%action-not-supported !!)
      %init-frontend  init-frontend
  ==
  ::
  ++  init-frontend  ~
  --
--

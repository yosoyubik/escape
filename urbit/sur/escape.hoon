/-  *beta
=,  block:able:jael
|%
+$  azimuth-event
  %-  unit
  $%  [%spawn id=@t sponsor=@p sponsee=@p]
      [%escape id=@t sponsee=@p sponsor=@p]
      [%active id=@t =ship]
  ==
::
+$  reputation  (map dimension [=score success=@rd totals=@rd])
::
+$  escape-request
  $?  %all
      %ship
      %spawns
      %escapes
      %is-live
      %are-live
      %timestamps
  ==
::
+$  escape-action
  $%  [%init url=@t pior=@rd dimensions=(list [term weight])]
      [%all ~]
      [%ship @p]
      [%is-live ~]
      [%are-live ~]
      [%sponsor ~]
      [%listen ~]
      [%clear ~]
      [%leave req=escape-request]
  ==
::
+$  escape-view
  $%  [%init ~]
      [%load ~]
  ==
::
+$  escape-view-response
  $%  escape-action
      [%init-frontend ~]
  ==
--

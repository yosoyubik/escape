/-  *beta
=,  block:able:jael
|%
+$  azimuth-event
  %-  unit
  $%  [%spawn =id star=@p planet=@p]
      [%escape =id planet=@p star=@p]
  ==
::
+$  reputation  (map dimension score)
::
+$  escape-request
  $?  %all
      %ship
      %spawns
      %escapes
      %is-live
  ==
::
+$  escape-action
  $%  [%init ~]
      [%all ~]
      [%ship @p]
      [%sponsor ~]
      [%listen ~]
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

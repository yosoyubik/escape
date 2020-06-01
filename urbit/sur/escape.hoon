/-  *beta
|%
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

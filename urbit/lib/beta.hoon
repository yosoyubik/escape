/-  *beta
::  Beta Reputation
::
|_  $:  dimensions=(map @tas weight=@rd)
        events=(list event)
    ==
++  add
  |=  (list event)
  %_  +>
    events  (weld events +<)
  ==
::
++  all
  events
::
++  filter
  |%
  ++  dimension
    |=  =term
    ^+  events
    (skim events |=(event =(term tag.dimension)))
  ::
  ++  entity
    |*  entity=*
    ^+  events
    (skim events |=(event =(^entity entity)))
  ::
  ++  date
    |=  =timestamp
    ^+  events
    (skim events |=(event ?~(^timestamp & =(u.^timestamp timestamp))))
  --
::
++  score
  |=  $:  prior=@rd
          dimension=(unit term)
          date=(unit timestamp)
          entity=(unit entity)
      ==
  ^-  @rd
  =/  grouped=(list event)  (map-events dimension date entity)
  =/  success=@rd  (roll grouped reduce-event)
  =/  total=@rd  (sun:rd (lent events))
  (expected-value success total prior)
::
++  expected-value
  |=  [success=@rd total=@rd prior=@rd]
  %+  div:rd
    (add:rd success (mul:rd .~2 prior))
  (add:rd total .~2)
::
++  map-events
  |=  $:  dimension=(unit term)
          date=(unit timestamp)
          entity=(unit entity)
      ==
  ^+  events
  %+  skim  events
  |=  event
  ^-  ?
  ?&  ?~  date  &
      ?~  timestamp  &
      =(u.date u.timestamp)
    ::
      ?~  ^dimension  &
      =(u.^dimension tag.dimension)
    ::
      ?~  ^entity  &
      =(u.^entity entity)
  ==
::
++  reduce-event
  |=  [=event acc=@rd]
  ^-  @rd
  %+  add:rd
    acc
  (mul:rd score.event weight.dimension.event)
--

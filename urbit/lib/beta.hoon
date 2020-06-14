::  Beta Reputation library
::
/-  *beta
::
|_  [events=(list event) weights=(map term weight)]
++  add
  |=  (list event)
  %_  +>
    events   (weld events +<)
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
  ::
  ++  success
    |*  entity=*
    ^+  events
    %+  skim  events
    |=  event
    ?&  =(^entity entity)
        =(score .~1.0)
    ==
  --
::
++  score
  |=  $:  prior=@rd
          tag=(unit term)
          date=(unit timestamp)
          entity=(unit entity)
      ==
  ^-  [score=@rd success=@rd total=@rd]
  =/  grouped=(list event)  (map-events tag date entity)
  =/  success=@rd  (roll grouped reduce-event)
  =/  total=@rd  (sun:rd (lent grouped))
  :_  [success total]
  (expected-value success total prior)
::
++  expected-value
  |=  [success=@rd total=@rd prior=@rd]
  %+  div:rd
    (add:rd success (mul:rd .~2 prior))
  (add:rd total .~2)
::
++  map-events
  |=  $:  tag=(unit term)
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
      ?~  ^tag  &
      =(u.^tag tag)
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
  (mul:rd score.event (~(got by weights) tag.event))
::
++  success-score
  |=  entity=*
  (roll (success:filter entity) reduce-event)
--

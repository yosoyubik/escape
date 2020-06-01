::  tests for the base lib
::
/-  *beta
/+  *test, beta
::
|%
++  test-base
  =/  beta
    %-  ~(add beta [~ ~])
    :~  [now .~1.0 [%escape .~0.8] [%star ~marzod]]
        [now .~1.0 [%escape .~0.1] [%star ~marzod]]
        [now .~1.0 [%escape .~0.2] [%star ~marzod]]
        [now .~1.0 [%escape .~0.5] [%star ~marzod]]
        [now .~0.0 [%escape .~0.5] [%star ~dopzod]]
        [now .~0.0 [%escape .~0.5] [%star ~binzod]]
    ==
  =/  escapes=(list event)  (entity:filter:beta [%star ~binzod])
  ~&  escapes
  =/  score-marzod=@rd  (score:beta .~0.5 ~ ~ `[%star ~marzod])
  =/  score-binzod=@rd  (score:beta .~0.5 ~ ~ `[%star ~binzod])
  [%noun [marzod=score-marzod binzod=score-binzod]]
  %+  expect-eq
    !>  'NzbLsXh8uDCcd-6MNwXF4W_7noWXFZAfHkxZsRGC9Xs'
    !>  (pass:thumb:jwk k)

  [marzod=.~3.2499999999999996e-1 binzod=.~3.2499999999999996e-1]

--

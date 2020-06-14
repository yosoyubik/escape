::  tests for the base lib
::
/-  *beta
/+  *test, beta
::
|%
++  test-base
:: [ [ .~5e-1
::     .~1
::     .~2
::     ~[
::       [ id=[104.627.178.461.921.978.690.412.863.586.125.358.167.301.807.855.683.451.476.298.013.606.135.478.448.694 7.678.110]
::         timestamp=~
::         score=.~1
::         dimension=[tag=%escape weight=.~1]
::         entity=[1.918.989.427 256]
::       ]
::       [ id=[104.627.178.461.921.978.690.412.863.586.125.358.167.301.807.855.683.451.476.298.013.606.135.478.448.694 7.678.110]
::         timestamp=~
::         score=.~0
::         dimension=[tag=%escape weight=.~1]
::         entity=[1.918.989.427 0 51.180]
::       ]
::     ]
::   ]
::   [~ {[p=[tag=%escape weight=.~1] q=[score=.~9.965034965034965e-1 success=.~2.84e2 totals=.~2.84e2]]}]
:: ]

  =/  beta
    %-  ~(add beta [~ ~])
    :~  ["" ~ .~1.0 [%escape .~1.0] [%star ~marzod]]
        ["" ~ .~0.0 [%escape .~1.0] [%star `~binzod]]
        :: ["" ~ .~1.0 [%escape .~0.2] [%star ~marzod]]
        :: ["" ~ .~1.0 [%escape .~0.5] [%star ~marzod]]
        :: ["" ~ .~0.0 [%escape .~0.5] [%star ~dopzod]]
        :: ["" ~ .~0.0 [%escape .~0.5] [%star ~binzod]]
    ==
  :: =/  escapes=(list event)  (entity:filter:beta [%star ~binzod])
  :: ~&  escapes
  :: =/  [local-score-marzod=@rd local-success-marzod=@rd local-total-marzod=@rd]
  ::   (score:beta .~0.5 ~ ~ `[%star ~marzod])
  :: =/  [local-score-binzod=@rd local-success-binzod=@rd local-total-binzod=@rd]
  ::   (score:beta .~0.5 ~ ~ `[%star ~binzod])

  =/  [local-score=@rd local-success=@rd local-total=@rd]
    (score:beta .~0.5 ~ ~ `[%star ~marzod])

  ~&  [local-score local-success local-total]
  (expect-eq !>(&) !>(&))
  :: %+  expect-eq
  ::   !>  'NzbLsXh8uDCcd-6MNwXF4W_7noWXFZAfHkxZsRGC9Xs'
  ::   !>  (pass:thumb:jwk k)
  ::
  :: [marzod=.~3.2499999999999996e-1 binzod=.~3.2499999999999996e-1]

--

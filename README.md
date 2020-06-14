# Escape: Beta Score for \~Urbit Stars

<!-- [![Header](/images/beta.png)]()

[Video Demo]() -->

## Features


## Installation

In order to run your canvas app on your ship, before `|install` is implemented natively on urbit, you will need to mount your pier to Unix with `|mount %`.

Then you need to add the path to you urbit's pier in .urbitrc. The file is not provided by this repo so you need to create it manually:

```
module.exports = {
  URBIT_PIERS: [
    "PATH/TO/YOUR/PIER",
  ]
};
```

You have two options to mount the canvas into your pier:

- ##### `npm run build`

This builds your application and copies it into your Urbit ship's desk. In your Urbit (v.0.8.0 or higher) `|commit %home` (or `%your-desk-name`) to synchronize your changes.

- ##### `npm run serve`

Builds the application and copies it into your Urbit ship's desk, watching for changes. In your Urbit (v.0.8.0 or higher) `|commit %home` (or `%your-desk-name`) to synchronize your changes.

When you make changes, the `urbit` directory will update with the compiled application and, if you're running `npm run serve`, it will automatically copy itself to your Urbit ship when you save your.

## Running

To start the canvas agent run this commands from `%dojo`:
```
> |start %escape
>=
> |start %escape-view
>=
```

If the tile doesn't load on the Home page screen run this command:

```
> :launch &launch-action [%add %escape /escapetile '/~escape/js/tile.js']
```
<!-- <img src="/images/tile.png" width="180"> -->

You'll get an error but the tile will show up on the home screen.

Direct link: `<YOUR_URL>/~escape`

## Background

"How much Escape does `~marzod` have?"

When a planet is newly booted into the Urbit Network there is a fundamental service that its sponsor needs to provide: peer discovery. In order to do this the sponsor needs to be up and running, with a stable internet connection. The Urbit Network is still young but there has been several instances where planets discovered that, right after a first boot, they can't communicate with anybody in the network due to their sponsor not been active.

These planets need to quickly escape, that is, leave their sponsor star and find a new one that provides a good service. A simple way to assess the likelihood of the sponsor being a good actor in the network is to look at on-chain data from the Azimuth contract, in particular, Escapes. If a sponsor has a low Escape score (planets that leave), one could use this as a proxy and say that the sponsor will keep behaving in the same way as the past data indicates. More over, if a sponsor attracts more planets, that signals more strongly the good quality of the provided service.

This proposal addresses this problem by using the Beta Reputation to create a Landscape app that will show the score of a planet's sponsor based on data from Azimuth, in particular the number of planets spawned, and the number of planets that have escaped. [The Beta Reputation](https://www.csee.umbc.edu/~msmith27/readings/public/josang-2002a.pdf) uses the Beta Distribution to calculate the score (e.g. successful/unsuccessful events over the total number of interactions) as the expected value of a probability distribution. More data available (high number of booted planets) will narrow down the confidence of the probability (if a star has only booted a planet that didn't escape, the confidence of that score (1-0.67=33%) is smaller than the one of a star that has booted 200 planets and only two have escaped (1-0.87=13%)

A full reputation system for stars is out of scope for this proposal, but some ideas would be to include network uptime or other, more subjective metrics, ideally agreed by the children of each star.

The aim of this proposal is not to create a perfect reputation system but rather, to introduce in the minds of the users that there is a sponsor that they need to pay attention to, that is providing a service, not only to them but to others in the network, and that the likelihood of that operator's behavior can be attested since the data is publicly available and in a blockchain.

The Beta Reputation is a system that is very easy to understand to non-technical users but has a statistical background behind it. Nevertheless this is just one of the many reputation systems that are out there like [Regret](https://dl.acm.org/doi/pdf/10.1145/375735.376110), [Fire](https://eprints.soton.ac.uk/259559/1/dong-ecai2004.pdf) or [Travos](https://idp.springer.com/authorize/casa?redirect_uri=https://link.springer.com/content/pdf/10.1007/s10458-006-5952-x.pdf&casa_token=M38itGxqsu0AAAAA:lAUgQUvbc4dZFhrNs4SSPWrQ9PzUj05pzmU5zkvPkytDOfgFOIxVP0a8Tzk_VkRi37J1bRHPJ2IhTD8C). I envision this work as a starting point for introducing reputation systems in Urbit as libraries that can be used by the community for experimentation.

With this is mind the Beta library (`/urbit/lib/beta.hoon`) can be used with any app that has a well defined data structure that comprises a list of timestamped events with a certain score, weighted, if desired, for a specific dimension. The ability to tag each event with a weighted dimension allows for complex reputations where different data points can be aggregated together.

## Examples

If we set up a prior of `.~0.5` and we account higher for escapes than for spawns (`.~0.8`) the results for all active stars as of Jun 11 2020 are:
(Note: a low escape is more positive than a high escape score)

#### Assigning a `.~1.0` score to `Activated` events and `.~0.0` score to `Escape` events

```
> .^((list [@p reputation:escape]) %gx /=escape=/sponsors/sort/noun)
~[
  [~litzod {[p=%escape q=[score=.~1.9725400457667797e-1 success=.~3.4979999999999177e2 totals=.~4.35e2]]}]
  [~marnus {[p=%escape q=[score=.~2.0086083213776218e-1 success=.~5.559999999999798e2 totals=.~6.95e2]]}]
  [~wanzod {[p=%escape q=[score=.~2.012024048096417e-1 success=.~3.975999999999888e2 totals=.~4.97e2]]}]
  [~marzod {[p=%escape q=[score=.~2.0137931034483647e-1 success=.~2.3059999999999744e2 totals=.~2.88e2]]}]
  [~ramnes {[p=%escape q=[score=.~2.016908212560703e-1 success=.~6.599999999999739e2 totals=.~8.26e2]]}]
  [~samzod {[p=%escape q=[score=.~2.0269607843140391e-1 success=.~6.495999999999744e2 totals=.~8.14e2]]}]
  [~tirten {[p=%escape q=[score=.~2.0404040404040658e-1 success=.~7.779999999999976e1 totals=.~9.7e1]]}]
  [~dilnes {[p=%escape q=[score=.~2.0411985018728973e-1 success=.~4.239999999999873e2 totals=.~5.32e2]]}]
  [~batten {[p=%escape q=[score=.~2.060000000000024e-1 success=.~7.839999999999976e1 totals=.~9.8e1]]}]
  [~binzod {[p=%escape q=[score=.~2.061538461538558e-1 success=.~2.569999999999969e2 totals=.~3.23e2]]}]
  [~tondef {[p=%escape q=[score=.~2.067415730337102e-1 success=.~6.95999999999998e1 totals=.~8.7e1]]}]
  [~rosrun {[p=%escape q=[score=.~2.0705882352941407e-1 success=.~6.63999999999998e1 totals=.~8.3e1]]}]
  [~rigpub {[p=%escape q=[score=.~2.0717948717949208e-1 success=.~1.5359999999999906e2 totals=.~1.93e2]]}]
  [~fidbus {[p=%escape q=[score=.~2.072289156626529e-1 success=.~6.479999999999981e1 totals=.~8.1e1]]}]
  [~dirdev {[p=%escape q=[score=.~2.07317073170734e-1 success=.~6.3999999999999815e1 totals=.~8e1]]}]
  [~marpem {[p=%escape q=[score=.~2.0740740740740848e-1 success=.~2.0399999999999974e1 totals=.~2.5e1]]}]
  [~ramlur {[p=%escape q=[score=.~2.0750000000000224e-1 success=.~6.239999999999982e1 totals=.~7.8e1]]}]
  [~binnus {[p=%escape q=[score=.~2.0952380952381167e-1 success=.~4.879999999999987e1 totals=.~6.1e1]]}]
  [~fiprun {[p=%escape q=[score=.~2.0969479353682863e-1 success=.~4.3919999999998646e2 totals=.~5.55e2]]}]
  [~litdev {[p=%escape q=[score=.~2.0992907801418692e-1 success=.~1.1039999999999965e2 totals=.~1.39e2]]}]
  [~hidfeb {[p=%escape q=[score=.~2.1052631578947578e-1 success=.~4.3999999999999886e1 totals=.~5.5e1]]}]
  [~sigpub {[p=%escape q=[score=.~2.123893805309759e-1 success=.~8.799999999999973e1 totals=.~1.11e2]]}]
  [~hatten {[p=%escape q=[score=.~2.1276595744681037e-1 success=.~3.5999999999999915e1 totals=.~4.5e1]]}]
  [~marbus {[p=%escape q=[score=.~2.1276595744681037e-1 success=.~3.5999999999999915e1 totals=.~4.5e1]]}]
  [~panten {[p=%escape q=[score=.~2.133333333333357e-1 success=.~8.159999999999975e1 totals=.~1.03e2]]}]
  [~tirrel {[p=%escape q=[score=.~2.136363636363654e-1 success=.~3.359999999999992e1 totals=.~4.2e1]]}]
  [~monrel {[p=%escape q=[score=.~2.136363636363654e-1 success=.~3.359999999999992e1 totals=.~4.2e1]]}]
  [~livpub {[p=%escape q=[score=.~2.143884892086355e-1 success=.~1.0819999999999968e2 totals=.~1.37e2]]}]
  [~padnem {[p=%escape q=[score=.~2.1538461538461773e-1 success=.~7.039999999999979e1 totals=.~8.9e1]]}]
  [~firrel {[p=%escape q=[score=.~2.1728395061728623e-1 success=.~6.239999999999982e1 totals=.~7.9e1]]}]
  [~ponrun {[p=%escape q=[score=.~2.1794871794872017e-1 success=.~5.999999999999983e1 totals=.~7.6e1]]}]
  [~wolnus {[p=%escape q=[score=.~2.200000000000002e-1 success=.~6.799999999999999 totals=.~8]]}]
  [~dolnus {[p=%escape q=[score=.~2.200000000000012e-1 success=.~2.2399999999999967e1 totals=.~2.8e1]]}]
  [~wanfeb {[p=%escape q=[score=.~2.225806451612924e-1 success=.~4.7199999999999875e1 totals=.~6e1]]}]
  [~litpub {[p=%escape q=[score=.~2.225806451612924e-1 success=.~4.7199999999999875e1 totals=.~6e1]]}]
  [~nibfeb {[p=%escape q=[score=.~2.230088495575243e-1 success=.~8.679999999999976e1 totals=.~1.11e2]]}]
  [~ranten {[p=%escape q=[score=.~2.250000000000001e-1 success=.~5.199999999999999 totals=.~6]]}]
  [~batbus {[p=%escape q=[score=.~2.277777777777802e-1 success=.~8.239999999999975e1 totals=.~1.06e2]]}]
  [~daldev {[p=%escape q=[score=.~2.3333333333333384e-1 success=.~1.2799999999999992e1 totals=.~1.6e1]]}]
  [~middev {[p=%escape q=[score=.~2.3636363636363655e-1 success=.~7.399999999999999 totals=.~9]]}]
  [~ripten {[p=%escape q=[score=.~2.3750000000000038e-1 success=.~1.1199999999999994e1 totals=.~1.4e1]]}]
  [~danpem {[p=%escape q=[score=.~2.3931623931624169e-1 success=.~8.799999999999973e1 totals=.~1.15e2]]}]
  [~sibnes {[p=%escape q=[score=.~2.400000000000001e-1 success=.~2.8 totals=.~3]]}]
  [~fillur {[p=%escape q=[score=.~2.400000000000001e-1 success=.~2.8 totals=.~3]]}]
  [~sanfeb {[p=%escape q=[score=.~2.400000000000002e-1 success=.~6.599999999999999 totals=.~8]]}]
  [~siddev {[p=%escape q=[score=.~2.461538461538464e-1 success=.~8.799999999999997 totals=.~1.1e1]]}]
  [~satpub {[p=%escape q=[score=.~2.461538461538464e-1 success=.~8.799999999999997 totals=.~1.1e1]]}]
  [~talwet {[p=%escape q=[score=.~2.5454545454545485e-1 success=.~7.199999999999998 totals=.~9]]}]
  [~falnem {[p=%escape q=[score=.~2.636363636363642e-1 success=.~1.5199999999999989e1 totals=.~2e1]]}]
  [~siddef {[p=%escape q=[score=.~2.6666666666666683e-1 success=.~5.599999999999999 totals=.~7]]}]
  [~bonwet {[p=%escape q=[score=.~2.7500000000000013e-1 success=.~4.799999999999999 totals=.~6]]}]
  [~losten {[p=%escape q=[score=.~2.8e-1 success=.~2.6 totals=.~3]]}]
  [~darlur {[p=%escape q=[score=.~2.857142857142859e-1 success=.~3.9999999999999996 totals=.~5]]}]
  [~sabbus {[p=%escape q=[score=.~2.857142857142859e-1 success=.~3.9999999999999996 totals=.~5]]}]
  [~davnus {[p=%escape q=[score=.~2.857142857142859e-1 success=.~3.9999999999999996 totals=.~5]]}]
  [~malbus {[p=%escape q=[score=.~3.0000000000000016e-1 success=.~3.1999999999999997 totals=.~4]]}]
  [~losrel {[p=%escape q=[score=.~3.0000000000000016e-1 success=.~3.1999999999999997 totals=.~4]]}]
  [~litlur {[p=%escape q=[score=.~3.0000000000000016e-1 success=.~3.1999999999999997 totals=.~4]]}]
  [~labpub {[p=%escape q=[score=.~3.0000000000000016e-1 success=.~3.1999999999999997 totals=.~4]]}]
  [~hapten {[p=%escape q=[score=.~3.000000000000005e-1 success=.~1.439999999999999e1 totals=.~2e1]]}]
  [~darpub {[p=%escape q=[score=.~3.111111111111112e-1 success=.~5.199999999999999 totals=.~7]]}]
  [~lopdev {[p=%escape q=[score=.~3.2000000000000006e-1 success=.~2.4 totals=.~3]]}]
  [~lanrun {[p=%escape q=[score=.~3.2000000000000006e-1 success=.~2.4 totals=.~3]]}]
  [~docfeb {[p=%escape q=[score=.~3.2000000000000006e-1 success=.~2.4 totals=.~3]]}]
  [~walten {[p=%escape q=[score=.~3.2000000000000006e-1 success=.~2.4 totals=.~3]]}]
  [~piddef {[p=%escape q=[score=.~3.2000000000000006e-1 success=.~2.4 totals=.~3]]}]
  [~satdef {[p=%escape q=[score=.~3.2000000000000006e-1 success=.~2.4 totals=.~3]]}]
  [~wicfeb {[p=%escape q=[score=.~3.2000000000000006e-1 success=.~2.4 totals=.~3]]}]
  [~lavfep {[p=%escape q=[score=.~3.2000000000000006e-1 success=.~2.4 totals=.~3]]}]
  [~holnes {[p=%escape q=[score=.~3.2000000000000006e-1 success=.~2.4 totals=.~3]]}]
  [~dilpub {[p=%escape q=[score=.~3.3333333333333337e-1 success=.~1 totals=.~1]]}]
  [~fogbus {[p=%escape q=[score=.~3.3333333333333337e-1 success=.~1 totals=.~1]]}]
  [~latryx {[p=%escape q=[score=.~3.3333333333333337e-1 success=.~1 totals=.~1]]}]
  [~sortug {[p=%escape q=[score=.~3.5e-1 success=.~1.6 totals=.~2]]}]
  [~todten {[p=%escape q=[score=.~3.5e-1 success=.~1.6 totals=.~2]]}]
  [~lospub {[p=%escape q=[score=.~3.5e-1 success=.~1.6 totals=.~2]]}]
  [~talfeb {[p=%escape q=[score=.~3.5e-1 success=.~1.6 totals=.~2]]}]
  [~lidsud {[p=%escape q=[score=.~3.5e-1 success=.~1.6 totals=.~2]]}]
  [~lidlur {[p=%escape q=[score=.~3.5e-1 success=.~1.6 totals=.~2]]}]
  [~dotrel {[p=%escape q=[score=.~3.5e-1 success=.~1.6 totals=.~2]]}]
  [~sollur {[p=%escape q=[score=.~3.5e-1 success=.~1.6 totals=.~2]]}]
  [~midfeb {[p=%escape q=[score=.~3.5e-1 success=.~1.6 totals=.~2]]}]
  [~liblur {[p=%escape q=[score=.~4e-1 success=.~8e-1 totals=.~1]]}]
  [~lisdef {[p=%escape q=[score=.~4e-1 success=.~8e-1 totals=.~1]]}]
  [~ropdev {[p=%escape q=[score=.~4e-1 success=.~8e-1 totals=.~1]]}]
  [~worlur {[p=%escape q=[score=.~4e-1 success=.~8e-1 totals=.~1]]}]
  [~fodten {[p=%escape q=[score=.~4e-1 success=.~8e-1 totals=.~1]]}]
  [~figpub {[p=%escape q=[score=.~4e-1 success=.~8e-1 totals=.~1]]}]
  [~posdef {[p=%escape q=[score=.~4e-1 success=.~8e-1 totals=.~1]]}]
  [~ticrel {[p=%escape q=[score=.~4e-1 success=.~8e-1 totals=.~1]]}]
  [~navfeb {[p=%escape q=[score=.~4e-1 success=.~8e-1 totals=.~1]]}]
  [~siglur {[p=%escape q=[score=.~4e-1 success=.~8e-1 totals=.~1]]}]
  [~siprel {[p=%escape q=[score=.~4e-1 success=.~8e-1 totals=.~1]]}]
  [~hacsud {[p=%escape q=[score=.~4e-1 success=.~8e-1 totals=.~1]]}]
  [~narbus {[p=%escape q=[score=.~4e-1 success=.~8e-1 totals=.~1]]}]
  [~wanten {[p=%escape q=[score=.~4.8e-1 success=.~1.6 totals=.~3]]}]
]

```
#### Assigning a `.~1.0` score to `Spawned` events and `.~0.0` score to `Escape` events
```
> .^((list [@p reputation:escape]) %gx /=escape=/sponsors/sort/noun)
~[
  [~nibfeb {[p=%escape q=[score=.~1.9622641509434213e-1 success=.~1.2679999999999961e2 totals=.~1.57e2]]}]
  [~livpub {[p=%escape q=[score=.~1.9705882352941417e-1 success=.~1.0819999999999968e2 totals=.~1.34e2]]}]
  [~litzod {[p=%escape q=[score=.~1.9845559845563465e-1 success=.~1.0369999999999532e3 totals=.~1.293e3]]}]
  [~marnus {[p=%escape q=[score=.~2.002926829268692e-1 success=.~1.6383999999999182e3 totals=.~2.048e3]]}]
  [~ramnes {[p=%escape q=[score=.~2.007211538461856e-1 success=.~6.639999999999736e2 totals=.~8.3e2]]}]
  [~samzod {[p=%escape q=[score=.~2.0073710073713213e-1 success=.~6.495999999999744e2 totals=.~8.12e2]]}]
  [~fiprun {[p=%escape q=[score=.~2.010889292196254e-1 success=.~4.3919999999998646e2 totals=.~5.49e2]]}]
  [~dilnes {[p=%escape q=[score=.~2.0112781954889603e-1 success=.~4.239999999999873e2 totals=.~5.3e2]]}]
  [~wanzod {[p=%escape q=[score=.~2.012024048096417e-1 success=.~3.975999999999888e2 totals=.~4.97e2]]}]
  [~binzod {[p=%escape q=[score=.~2.0123839009288902e-1 success=.~2.569999999999969e2 totals=.~3.21e2]]}]
  [~marzod {[p=%escape q=[score=.~2.0137931034483647e-1 success=.~2.3059999999999744e2 totals=.~2.88e2]]}]
  [~rigpub {[p=%escape q=[score=.~2.0309278350515958e-1 success=.~1.5359999999999906e2 totals=.~1.92e2]]}]
  [~tirten {[p=%escape q=[score=.~2.0404040404040658e-1 success=.~7.779999999999976e1 totals=.~9.7e1]]}]
  [~litdev {[p=%escape q=[score=.~2.0425531914893869e-1 success=.~1.1119999999999965e2 totals=.~1.39e2]]}]
  [~panten {[p=%escape q=[score=.~2.0512820512820762e-1 success=.~9.199999999999972e1 totals=.~1.15e2]]}]
  [~danpem {[p=%escape q=[score=.~2.0526315789473937e-1 success=.~8.959999999999972e1 totals=.~1.12e2]]}]
  [~sigpub {[p=%escape q=[score=.~2.0535714285714535e-1 success=.~8.799999999999973e1 totals=.~1.1e2]]}]
  [~batbus {[p=%escape q=[score=.~2.0571428571428818e-1 success=.~8.239999999999975e1 totals=.~1.03e2]]}]
  [~batten {[p=%escape q=[score=.~2.0594059405940834e-1 success=.~7.919999999999976e1 totals=.~9.9e1]]}]
  [~padnem {[p=%escape q=[score=.~2.06666666666669e-1 success=.~7.039999999999979e1 totals=.~8.8e1]]}]
  [~tondef {[p=%escape q=[score=.~2.067415730337102e-1 success=.~6.95999999999998e1 totals=.~8.7e1]]}]
  [~rosrun {[p=%escape q=[score=.~2.0705882352941407e-1 success=.~6.63999999999998e1 totals=.~8.3e1]]}]
  [~marpem {[p=%escape q=[score=.~2.0714285714285818e-1 success=.~2.119999999999997e1 totals=.~2.6e1]]}]
  [~dirdev {[p=%escape q=[score=.~2.072289156626529e-1 success=.~6.479999999999981e1 totals=.~8.1e1]]}]
  [~fidbus {[p=%escape q=[score=.~2.072289156626529e-1 success=.~6.479999999999981e1 totals=.~8.1e1]]}]
  [~firrel {[p=%escape q=[score=.~2.074074074074097e-1 success=.~6.319999999999982e1 totals=.~7.9e1]]}]
  [~ramlur {[p=%escape q=[score=.~2.0750000000000224e-1 success=.~6.239999999999982e1 totals=.~7.8e1]]}]
  [~ponrun {[p=%escape q=[score=.~2.0779220779221008e-1 success=.~5.999999999999983e1 totals=.~7.5e1]]}]
  [~litpub {[p=%escape q=[score=.~2.0869565217391528e-1 success=.~5.359999999999985e1 totals=.~6.7e1]]}]
  [~binnus {[p=%escape q=[score=.~2.0952380952381167e-1 success=.~4.879999999999987e1 totals=.~6.1e1]]}]
  [~wanfeb {[p=%escape q=[score=.~2.0983606557377255e-1 success=.~4.7199999999999875e1 totals=.~5.9e1]]}]
  [~hidfeb {[p=%escape q=[score=.~2.1052631578947578e-1 success=.~4.3999999999999886e1 totals=.~5.5e1]]}]
  [~marbus {[p=%escape q=[score=.~2.1132075471698308e-1 success=.~4.07999999999999e1 totals=.~5.1e1]]}]
  [~hatten {[p=%escape q=[score=.~2.1276595744681037e-1 success=.~3.5999999999999915e1 totals=.~4.5e1]]}]
  [~tirrel {[p=%escape q=[score=.~2.136363636363654e-1 success=.~3.359999999999992e1 totals=.~4.2e1]]}]
  [~monrel {[p=%escape q=[score=.~2.136363636363654e-1 success=.~3.359999999999992e1 totals=.~4.2e1]]}]
  [~wolnus {[p=%escape q=[score=.~2.200000000000002e-1 success=.~6.799999999999999 totals=.~8]]}]
  [~dolnus {[p=%escape q=[score=.~2.200000000000012e-1 success=.~2.2399999999999967e1 totals=.~2.8e1]]}]
  [~ranten {[p=%escape q=[score=.~2.250000000000001e-1 success=.~5.199999999999999 totals=.~6]]}]
  [~darpub {[p=%escape q=[score=.~2.250000000000001e-1 success=.~5.199999999999999 totals=.~6]]}]
  [~falnem {[p=%escape q=[score=.~2.285714285714292e-1 success=.~1.5199999999999989e1 totals=.~1.9e1]]}]
  [~hapten {[p=%escape q=[score=.~2.3000000000000054e-1 success=.~1.439999999999999e1 totals=.~1.8e1]]}]
  [~middev {[p=%escape q=[score=.~2.3076923076923095e-1 success=.~8.999999999999998 totals=.~1.1e1]]}]
  [~daldev {[p=%escape q=[score=.~2.3333333333333384e-1 success=.~1.2799999999999992e1 totals=.~1.6e1]]}]
  [~satpub {[p=%escape q=[score=.~2.3750000000000038e-1 success=.~1.1199999999999994e1 totals=.~1.4e1]]}]
  [~ripten {[p=%escape q=[score=.~2.3750000000000038e-1 success=.~1.1199999999999994e1 totals=.~1.4e1]]}]
  [~sibnes {[p=%escape q=[score=.~2.400000000000001e-1 success=.~2.8 totals=.~3]]}]
  [~fillur {[p=%escape q=[score=.~2.400000000000001e-1 success=.~2.8 totals=.~3]]}]
  [~sanfeb {[p=%escape q=[score=.~2.400000000000002e-1 success=.~6.599999999999999 totals=.~8]]}]
  [~siddev {[p=%escape q=[score=.~2.461538461538464e-1 success=.~8.799999999999997 totals=.~1.1e1]]}]
  [~talwet {[p=%escape q=[score=.~2.500000000000002e-1 success=.~7.999999999999998 totals=.~1e1]]}]
  [~darlur {[p=%escape q=[score=.~2.5454545454545485e-1 success=.~7.199999999999998 totals=.~9]]}]
  [~siddef {[p=%escape q=[score=.~2.5454545454545485e-1 success=.~7.199999999999998 totals=.~9]]}]
  [~piddef {[p=%escape q=[score=.~2.5454545454545485e-1 success=.~7.199999999999998 totals=.~9]]}]
  [~bonwet {[p=%escape q=[score=.~2.6666666666666683e-1 success=.~5.599999999999999 totals=.~7]]}]
  [~sabbus {[p=%escape q=[score=.~2.6666666666666683e-1 success=.~5.599999999999999 totals=.~7]]}]
  [~wicfeb {[p=%escape q=[score=.~2.7500000000000013e-1 success=.~4.799999999999999 totals=.~6]]}]
  [~labpub {[p=%escape q=[score=.~2.7500000000000013e-1 success=.~4.799999999999999 totals=.~6]]}]
  [~losten {[p=%escape q=[score=.~2.8e-1 success=.~2.6 totals=.~3]]}]
  [~lopdev {[p=%escape q=[score=.~2.857142857142859e-1 success=.~3.9999999999999996 totals=.~5]]}]
  [~malbus {[p=%escape q=[score=.~2.857142857142859e-1 success=.~3.9999999999999996 totals=.~5]]}]
  [~losrel {[p=%escape q=[score=.~2.857142857142859e-1 success=.~3.9999999999999996 totals=.~5]]}]
  [~davnus {[p=%escape q=[score=.~2.857142857142859e-1 success=.~3.9999999999999996 totals=.~5]]}]
  [~walten {[p=%escape q=[score=.~3.0000000000000016e-1 success=.~3.1999999999999997 totals=.~4]]}]
  [~lidlur {[p=%escape q=[score=.~3.0000000000000016e-1 success=.~3.1999999999999997 totals=.~4]]}]
  [~lavfep {[p=%escape q=[score=.~3.0000000000000016e-1 success=.~3.1999999999999997 totals=.~4]]}]
  [~litlur {[p=%escape q=[score=.~3.0000000000000016e-1 success=.~3.1999999999999997 totals=.~4]]}]
  [~lanrun {[p=%escape q=[score=.~3.2000000000000006e-1 success=.~2.4 totals=.~3]]}]
  [~docfeb {[p=%escape q=[score=.~3.2000000000000006e-1 success=.~2.4 totals=.~3]]}]
  [~wanten {[p=%escape q=[score=.~3.2000000000000006e-1 success=.~2.4 totals=.~3]]}]
  [~satdef {[p=%escape q=[score=.~3.2000000000000006e-1 success=.~2.4 totals=.~3]]}]
  [~holnes {[p=%escape q=[score=.~3.2000000000000006e-1 success=.~2.4 totals=.~3]]}]
  [~sollur {[p=%escape q=[score=.~3.2000000000000006e-1 success=.~2.4 totals=.~3]]}]
  [~dilpub {[p=%escape q=[score=.~3.3333333333333337e-1 success=.~1 totals=.~1]]}]
  [~fogbus {[p=%escape q=[score=.~3.3333333333333337e-1 success=.~1 totals=.~1]]}]
  [~latryx {[p=%escape q=[score=.~3.3333333333333337e-1 success=.~1 totals=.~1]]}]
  [~sortug {[p=%escape q=[score=.~3.5e-1 success=.~1.6 totals=.~2]]}]
  [~liblur {[p=%escape q=[score=.~3.5e-1 success=.~1.6 totals=.~2]]}]
  [~todten {[p=%escape q=[score=.~3.5e-1 success=.~1.6 totals=.~2]]}]
  [~lospub {[p=%escape q=[score=.~3.5e-1 success=.~1.6 totals=.~2]]}]
  [~talfeb {[p=%escape q=[score=.~3.5e-1 success=.~1.6 totals=.~2]]}]
  [~lidsud {[p=%escape q=[score=.~3.5e-1 success=.~1.6 totals=.~2]]}]
  [~posdef {[p=%escape q=[score=.~3.5e-1 success=.~1.6 totals=.~2]]}]
  [~dotrel {[p=%escape q=[score=.~3.5e-1 success=.~1.6 totals=.~2]]}]
  [~midfeb {[p=%escape q=[score=.~3.5e-1 success=.~1.6 totals=.~2]]}]
  [~lisdef {[p=%escape q=[score=.~4e-1 success=.~8e-1 totals=.~1]]}]
  [~nosdef {[p=%escape q=[score=.~4e-1 success=.~8e-1 totals=.~1]]}]
  [~ropdev {[p=%escape q=[score=.~4e-1 success=.~8e-1 totals=.~1]]}]
  [~worlur {[p=%escape q=[score=.~4e-1 success=.~8e-1 totals=.~1]]}]
  [~dospem {[p=%escape q=[score=.~4e-1 success=.~8e-1 totals=.~1]]}]
  [~fodten {[p=%escape q=[score=.~4e-1 success=.~8e-1 totals=.~1]]}]
  [~figpub {[p=%escape q=[score=.~4e-1 success=.~8e-1 totals=.~1]]}]
  [~dorten {[p=%escape q=[score=.~4e-1 success=.~8e-1 totals=.~1]]}]
  [~migfed {[p=%escape q=[score=.~4e-1 success=.~8e-1 totals=.~1]]}]
  [~ticrel {[p=%escape q=[score=.~4e-1 success=.~8e-1 totals=.~1]]}]
  [~navfeb {[p=%escape q=[score=.~4e-1 success=.~8e-1 totals=.~1]]}]
  [~siglur {[p=%escape q=[score=.~4e-1 success=.~8e-1 totals=.~1]]}]
  [~siprel {[p=%escape q=[score=.~4e-1 success=.~8e-1 totals=.~1]]}]
  [~hacsud {[p=%escape q=[score=.~4e-1 success=.~8e-1 totals=.~1]]}]
  [~narbus {[p=%escape q=[score=.~4e-1 success=.~8e-1 totals=.~1]]}]
]
```

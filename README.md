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

Some of the newly booted planets that have joined the Urbit network recently have sponsor stars that are not active on the network or are simply turned off. These planets start with no connectivity to the network which results in a poor user experience, together with discrediting the Urbit project as a whole, just because of a few bad actors (selling planets without providing peer discovery or OS updates).

This app uses the Beta Reputation to create a small tile app that will show the score for planet's sponsor based on data from Azimuth, in particular the number of planets booted, and the number of planets that have escaped. [The Beta Reputation](https://www.csee.umbc.edu/~msmith27/readings/public/josang-2002a.pdf) uses the Beta Distribution to calculate the score (e.g. successful/unsuccessful "interactions" over the total) as the expected value of a probability distribution. More data available (high number of booted planets) will narrow down the confidence of the probability (if a star has only booted a planet that didn't escape, the confidence of that score (~67%) is smaller than the one of a star that has booted 200 planets and only two have escaped (~87%)

A full reputation system for stars is out of scope for this proposal, but some ideas would be to include network uptime or other, more subjective metrics, ideally agreed by the children of each star.

The aim for this app is not to create a perfect reputation system but rather, to introduce in the minds of the users that there is a sponsor that they need to pay attention to, that's providing a service, not only to them but to others in the network, and that the likelihood of that operator's behavior can be attested since the data is publicly available and in a blockchain.

The Beta Reputation is a system that's very easy to understand to non-technical users but has a statistical background behind it. Nevertheless this is just on of the many reputation systems that are out there like Regret, Fire, Travos… I envision this work as a starting point for introducing reputation systems in Urbit as libraries that can be used by the community for experimentation.

With this is mind the Beta library (`/urbit/lib/beta.hoon`) can be used with any app that has a well defined data structure that comprises a list of timestamped interactions with a certain score, weighted, if desired, for a specific dimension. The ability to tag each event with a weignted dimension allows for complex reputations where different data points can be aggregated together.

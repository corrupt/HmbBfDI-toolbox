# dEtagtor -- simple Etag tracking detector

This is a prototype for an Etag detector that *could* one day either be integrated into [WEC](https://github.com/EU-EDPS/website-evidence-collector) or be part of a different suite.

Right now it uses a very simple one-pass approach of opening the same site in two distict browser sessions and scanning for resources that have identical hashes and different Etags in both these sessions.
It will output possible candidates for Etag beacons

## To do

* implement second pass to eliminate false positives
* expand the detection mechanism to compare only via hash to also detect resources with bespoke URLs
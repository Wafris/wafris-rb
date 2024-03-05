# Changelog

## [1.1.10](https://github.com/Wafris/wafris-rb/compare/v1.1.9...v1.1.10) (2024-03-05)


### Bug Fixes

* ensure keys seen once are also expired ([943ff7c](https://github.com/Wafris/wafris-rb/commit/943ff7ccdfefae6db41fb8737142bfcb8efb142c))

## [1.1.9](https://github.com/Wafris/wafris-rb/compare/v1.1.8...v1.1.9) (2023-12-17)


### Bug Fixes

* rescue standard errors at startup ([52e1d4b](https://github.com/Wafris/wafris-rb/commit/52e1d4bed7e77766e075c60ef4254ae78bc9384a))

## [1.1.8](https://github.com/Wafris/wafris-rb/compare/v1.1.7...v1.1.8) (2023-12-04)


### Bug Fixes

* Update info on the gemspec ([34cba36](https://github.com/Wafris/wafris-rb/commit/34cba36f013a45256fdff9bda2eeb1acbe98712a))

## [1.1.7](https://github.com/Wafris/wafris-rb/compare/v1.1.6...v1.1.7) (2023-11-22)


### Bug Fixes

* Add mock for host in failing test ([337414e](https://github.com/Wafris/wafris-rb/commit/337414edba8401662b242fb67f816699d39e83d5))
* Fix issues with CI ([aab9b45](https://github.com/Wafris/wafris-rb/commit/aab9b45b86e680af2316497715f9d4db60a28f59))

## [1.1.6](https://github.com/Wafris/wafris-rb/compare/v1.1.5...v1.1.6) (2023-10-03)


### Bug Fixes

* update Readme and allow newer versions of Rack ([ad33c47](https://github.com/Wafris/wafris-rb/commit/ad33c47fd4ddf9da0621b5f84af55628d6eb5011))

## [1.1.5](https://github.com/Wafris/wafris-rb/compare/v1.1.4...v1.1.5) (2023-09-22)


### Bug Fixes

* Logs were not showing after refactor ([f5b8761](https://github.com/Wafris/wafris-rb/commit/f5b87615557130d16d1ef6c83ce871dd78746b9c))

## [1.1.4](https://github.com/Wafris/wafris-rb/compare/v1.1.3...v1.1.4) (2023-09-21)


### Bug Fixes

* Add in maxmemory to configuration so we can begin tracking memory usage ([a504973](https://github.com/Wafris/wafris-rb/commit/a5049733d4eb0a51d34d948489a1bda8e57cee48))
* Refactor so that configuration is a singleton a requires a block ([bb93883](https://github.com/Wafris/wafris-rb/commit/bb9388315a8e6b5ff48ead2f976bfe76dc3e277d))

## [1.1.3](https://github.com/Wafris/wafris-rb/compare/v1.1.2...v1.1.3) (2023-09-19)


### Bug Fixes

* Remove documentation for using REDIS_URL as the default ([2d3d9a4](https://github.com/Wafris/wafris-rb/commit/2d3d9a4a54d30507ca9e8cee7e0964df21b28fe6))

## [1.1.2](https://github.com/Wafris/wafris-rb/compare/v1.1.1...v1.1.2) (2023-09-13)


### Bug Fixes

* escape special characters before doing string.find ([a5599ec](https://github.com/Wafris/wafris-rb/commit/a5599ec03f35583c76fabe76996975c577bb4ad2))

## [1.1.1](https://github.com/Wafris/wafris-rb/compare/v1.1.0...v1.1.1) (2023-09-11)


### Bug Fixes

* suppress messages in test, dev, and ci ([5c4ebbb](https://github.com/Wafris/wafris-rb/commit/5c4ebbbbbdd1aa696dfbf9080c885521510fee78))

## [1.1.0](https://github.com/Wafris/wafris-rb/compare/v1.0.0...v1.1.0) (2023-09-07)


### Features

* ensure web requests go through even when firewall is disabled ([e1d1a95](https://github.com/Wafris/wafris-rb/commit/e1d1a955ad5688a1f525b5ed51201ce08a125f4e))


### Bug Fixes

* add in offset since we were seeing race conditions when accessing keys ([9da6b9f](https://github.com/Wafris/wafris-rb/commit/9da6b9f9f2283bb7bb1f0f9085989d9652e727c2))

## [1.0.0](https://github.com/Wafris/wafris-rb/compare/v0.9.1...v1.0.0) (2023-08-31)


### Bug Fixes

* let redis generate the request ids ([39a1ffc](https://github.com/Wafris/wafris-rb/commit/39a1ffc0c092dae6211885534579dbe97f905c14))
* we expect to get the params as a string not a hash ([8423b78](https://github.com/Wafris/wafris-rb/commit/8423b782760b0f6f157ccea4c8db073d394973b9))


### Miscellaneous Chores

* release 1.0.0 ([bcd8b5e](https://github.com/Wafris/wafris-rb/commit/bcd8b5ef6252b55c92915f5d520b11574f7c0429))

## [0.9.1](https://github.com/Wafris/wafris-rb/compare/v0.9.0...v0.9.1) (2023-08-31)


### Bug Fixes

* forgot to include the require ([1ce1b4c](https://github.com/Wafris/wafris-rb/commit/1ce1b4c7bbf78f3d252ad15ac1ea69a0cee2be9f))

## [0.9.0](https://github.com/Wafris/wafris-rb/compare/v0.8.5...v0.9.0) (2023-08-31)


### ⚠ BREAKING CHANGES

* Core now processes params, host, and request methods. The last 24 hours of requests are stored and core has the ability to block IPs, paths, params, host and request methods. It also supports rate limiting. Support for both IPv4 and IPv6 IPs.

### Features

* Updated core and v1 functionality ([dd3bde0](https://github.com/Wafris/wafris-rb/commit/dd3bde0550a4e1d4a595163d0db858b28bac4f9c))

## [0.8.5](https://github.com/Wafris/wafris-rb/compare/v0.8.4...v0.8.5) (2023-06-22)


### Bug Fixes

* Set the version if the default redis env is detected ([72b5589](https://github.com/Wafris/wafris-rb/commit/72b558991d9541c8d40c261757766532d7cf55a9))

## [0.8.4](https://github.com/Wafris/wafris-rb/compare/v0.8.3...v0.8.4) (2023-06-21)


### Bug Fixes

* graph keys were not getting their expire time ([2d09f58](https://github.com/Wafris/wafris-rb/commit/2d09f5839e91066e0ba258bbfbbcfa3f8b920206))

## [0.8.3](https://github.com/Wafris/wafris-rb/compare/v0.8.2...v0.8.3) (2023-06-21)


### Bug Fixes

* sync up keys used for blocks ([d281d29](https://github.com/Wafris/wafris-rb/commit/d281d29404813b9205d300506dcd3b6b8a3cdf46))

## [0.8.2](https://github.com/Wafris/wafris-rb/compare/v0.8.1...v0.8.2) (2023-06-21)


### Bug Fixes

* set_version should happen after the configuration yield ([145b1c7](https://github.com/Wafris/wafris-rb/commit/145b1c7182f66ca8da027303b9695605327269f8))

## [0.8.1](https://github.com/Wafris/wafris-rb/compare/v0.8.0...v0.8.1) (2023-06-21)


### Bug Fixes

* only default to the REDIS_URL if it is defined ([c9007ec](https://github.com/Wafris/wafris-rb/commit/c9007ec5cf41dc36401cda2cf53474b4e9fff443))
* Remove expire option that was introduced with Redis 7 ([0ee41ac](https://github.com/Wafris/wafris-rb/commit/0ee41ac2b30fb220b8ba11f63d766c8620603cb5))

## [0.8.0](https://github.com/Wafris/wafris-rb/compare/v0.7.0...v0.8.0) (2023-06-21)


### Features

* Set core version on initial redis config ([34ccd36](https://github.com/Wafris/wafris-rb/commit/34ccd36b4e5bc84532359ae87bac6c4f13a4abd7))

## [0.7.0](https://github.com/Wafris/wafris-rb/compare/v0.6.0...v0.7.0) (2023-06-20)


### Features

* Add method for incrementing hourly time buckets each time a request comes in ([106ff7f](https://github.com/Wafris/wafris-rb/commit/106ff7f428df82e847f7bcbfd27f4d8f25f3557e))

## [0.6.0](https://github.com/Wafris/wafris-rb/compare/v0.5.4...v0.6.0) (2023-06-20)


### Features

* Introduce ability for user to define their proxies so they won't be considered the request ip ([0f415df](https://github.com/Wafris/wafris-rb/commit/0f415df5970d8236748f0972446516f13ce37318))

## [0.5.4](https://github.com/Wafris/wafris-rb/compare/v0.5.3...v0.5.4) (2023-06-05)


### Bug Fixes

* only set proxy ip if x_forwarded_for equals client ip ([102104d](https://github.com/Wafris/wafris-rb/commit/102104d1675034aa92612090c24def9b04323ea5))

## [0.5.3](https://github.com/Wafris/wafris-rb/compare/v0.5.2...v0.5.3) (2023-05-26)


### Bug Fixes

* alter zrange to check for exact match ([4d1b772](https://github.com/Wafris/wafris-rb/commit/4d1b772869a7e97c674e246584e8df4a3789ed98))

## [0.5.2](https://github.com/Wafris/wafris-rb/compare/v0.5.1...v0.5.2) (2023-05-25)


### Bug Fixes

* lua needs brackets for logical operators ([7480bb1](https://github.com/Wafris/wafris-rb/commit/7480bb1d83dfc50152453e31b481959f477afbcd))

## [0.5.1](https://github.com/Wafris/wafris-rb/compare/v0.5.0...v0.5.1) (2023-05-25)


### Bug Fixes

* check if an empty table is returned or not ([e72543f](https://github.com/Wafris/wafris-rb/commit/e72543f62220806fd5b60492559de59bfb011adf))

## [0.5.0](https://github.com/Wafris/wafris-rb/compare/v0.4.0...v0.5.0) (2023-05-25)


### Features

* default to REDIS_URL env variable ([466996a](https://github.com/Wafris/wafris-rb/commit/466996a4673f21a19bf0d5041fb147f937a0ff7c))

## [0.4.0](https://github.com/Wafris/wafris-rb/compare/v0.3.5...v0.4.0) (2023-05-25)


### Features

* create sorted set for tracking blocks ([e66f031](https://github.com/Wafris/wafris-rb/commit/e66f031e3ddb09f950d3bef07998c8211d53a527))

## [0.3.5](https://github.com/Wafris/wafris-rb/compare/v0.3.4...v0.3.5) (2023-05-23)


### Bug Fixes

* not populating the proxy sorted set correctly ([89cef20](https://github.com/Wafris/wafris-rb/commit/89cef201a96755f66f18d439c75bea39c68b436c))

## [0.3.4](https://github.com/Wafris/wafris-rb/compare/v0.3.3...v0.3.4) (2023-05-23)


### Bug Fixes

* lots of tiny bugs because I'm trying to move too fast ([dd39a40](https://github.com/Wafris/wafris-rb/commit/dd39a4042f87319c684288f6a2736e42376fd31f))

## [0.3.3](https://github.com/Wafris/wafris-rb/compare/v0.3.2...v0.3.3) (2023-05-23)


### Bug Fixes

* didn't replace all the .headers calls ([6a0cff0](https://github.com/Wafris/wafris-rb/commit/6a0cff07e911320585e964c422f6c1104ea9ecc5))

## [0.3.2](https://github.com/Wafris/wafris-rb/compare/v0.3.1...v0.3.2) (2023-05-23)


### Bug Fixes

* use the Rack constant for x-forwarded-for ([594c1f1](https://github.com/Wafris/wafris-rb/commit/594c1f1e55bcaa9c49c0bcd8851d842519e51047))

## [0.3.1](https://github.com/Wafris/wafris-rb/compare/v0.3.0...v0.3.1) (2023-05-22)


### Bug Fixes

* headers method does not exist on the request ([e7a3290](https://github.com/Wafris/wafris-rb/commit/e7a3290f009ffa99064a1cce28cbfd7fac41de04))

## [0.3.0](https://github.com/Wafris/wafris-rb/compare/v0.2.0...v0.3.0) (2023-05-22)


### Features

* introduce additional request headers ([0cfd6c3](https://github.com/Wafris/wafris-rb/commit/0cfd6c3647354b074da1965944a9cfd68c987b9c))

## [0.2.0](https://github.com/Wafris/wafris-rb/compare/v0.1.2...v0.2.0) (2023-05-17)


### Features

* remove queries so they can be managed in admin or hub ([4269086](https://github.com/Wafris/wafris-rb/commit/4269086b8bc08bd0931ef6ab67dec1de61055b28))

## [0.1.2](https://github.com/Wafris/wafris-rb/compare/v0.1.1...v0.1.2) (2023-04-23)


### Bug Fixes

* use the correct secret key for the action ([d545ef3](https://github.com/Wafris/wafris-rb/commit/d545ef39adcbffe1fa2c411de99ce32f8bf9330c))

## [0.1.1](https://github.com/Wafris/wafris-rb/compare/v0.1.0...v0.1.1) (2023-04-23)


### Bug Fixes

* use the correct license Id ([51ab819](https://github.com/Wafris/wafris-rb/commit/51ab819c61afdbef9f7dcb118fa076953acb9841))

## [0.1.0](https://github.com/Wafris/wafris-rb/compare/0.0.1...v0.1.0) (2023-04-23)


### Features

* Add interface for blocking IPs ([4cda7b1](https://github.com/Wafris/wafris-rb/commit/4cda7b1bd7923fd64fb562bd794872105b8303e5))


### Bug Fixes

* clear Readme ([b3dd8e7](https://github.com/Wafris/wafris-rb/commit/b3dd8e70f12fac5b9c2cbf384826450a31518d36))

## Wafris Changes

0.0.1
----------

- Initial release!

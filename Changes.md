# Changelog

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

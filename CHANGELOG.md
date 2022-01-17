# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v3.0.1 (2022-01-17)

### Fixed

   * Fixed issue producing a compile warning

## v3.0.0 (2021-09-15)

### Enhancements

   * Support for [advanced URL generation](https://docs.imgproxy.net/generating_the_url_advanced?id=generating-the-url-advanced)

### Hard-deprecations

   * No support for imgproxy before version 2.0.0
   * The `Imgproxy` library API has changed significantly and does not have any backward compatibility before version 3.0.0

## v2.0.0 (2020-05-24)

### Enhancements

   * Code now works with OTP 24 and the updated `:crypto` library

### Hard-deprecations

  * No OTP versions below 22 are supported.

## v1.0.0 (2020-05-23)

### Enhancements

  * Updated docs with specs to be more readable

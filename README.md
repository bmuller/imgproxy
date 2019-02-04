# Imgproxy
[![Build Status](https://secure.travis-ci.org/bmuller/imgproxy.png?branch=master)](https://travis-ci.org/bmuller/imgproxy)

Imgproxy is an Elixir library that helps generate [imgproxy](https://github.com/DarthSim/imgproxy) URLs.  Before using this library, you should have a running imgproxy server.

## Installation

To install Imgproxy, just add an entry to your `mix.exs`:

``` elixir
def deps do
  [
    # ...
    {:imgproxy, "~> 0.1"}
  ]
end
```

(Check [Hex](https://hex.pm/packages/imgproxy) to make sure you're using an up-to-date version number.)

## Configuration

In your `config/config.exs` you can set a few options:

``` elixir
config :imgproxy,
  prefix: "https://imgcdn.example.com",
  key: "cdf104fc78b7d7f6f0158c253612f5dsecretsecret...",
  salt: "aad7034f611b7fc28c6d344f72ea19secretsecret..."
```

The `prefix` should be the location of the imgproxy server.  `key` and `salt` are only necessary if you are using [URL signatures](https://github.com/DarthSim/imgproxy/blob/master/docs/configuration.md#url-signature).  To generate the key a key and salt, you can use:

``` bash
$> mix imgproxy.gen.secret
```

You can use the output as your key or salt (ideally, just run the command twice, use the first output for your key and the second output for your salt).

## Usage

Usage is basically constrained to the `url` function, which accepts the original URL for an image and optional parameters for image conversion.

Example:

``` elixir
# Generate URL for an image, using defaults
Imgproxy.url("https://placekitten.com/200/300")

# Set all parameters
Imgproxy.url("https://placekitten.com/200/300",
  resize: "fill",
  width: 123,
  height: 321,
  gravity: "sm",
  enlarge: "1",
  extension: "jpg")

# Generate URL for an image with set width of 150 and
# height of 200, and all other defaults.  This signature
# is useful if you just want to set width/height.
Imgproxy.url("https://placekitten.com/200/300", 150, 200)
```

The optional parameters are:

* [resize](https://github.com/DarthSim/imgproxy/blob/master/docs/generating_the_url_basic.md#resizing-types): default, "fill"
* [width and height](https://github.com/DarthSim/imgproxy/blob/master/docs/generating_the_url_basic.md#width-and-height): default, 300x300 
* [gravity](https://github.com/DarthSim/imgproxy/blob/master/docs/generating_the_url_basic.md#gravity): default, "sm" for smart.  `libvips` detects the most "interesting" section of the image and considers it as the center of the resulting image.
* [enlarge](https://github.com/DarthSim/imgproxy/blob/master/docs/generating_the_url_basic.md#enlarge): default, "1"
* [extension](https://github.com/DarthSim/imgproxy/blob/master/docs/generating_the_url_basic.md#extension): default, attempts to preserve the original image type

The [imgproxy docs](https://github.com/DarthSim/imgproxy/blob/master/docs/generating_the_url_basic.md) have more details on what each of these options indicate.

## Running Tests

To run tests:

``` shell
$> mix test
```

## Reporting Issues

Please report all issues [on github](https://github.com/bmuller/imgproxy/issues).

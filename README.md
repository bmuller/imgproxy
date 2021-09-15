# Imgproxy
[![Build Status](https://github.com/bmuller/imgproxy/actions/workflows/ci.yml/badge.svg)](https://github.com/bmuller/imgproxy/actions/workflows/ci.yml)
[![Hex pm](http://img.shields.io/hexpm/v/imgproxy.svg?style=flat)](https://hex.pm/packages/imgproxy)
[![API Docs](https://img.shields.io/badge/api-docs-lightgreen.svg?style=flat)](https://hexdocs.pm/imgproxy/)

Imgproxy is an Elixir library that helps generate [imgproxy](https://github.com/DarthSim/imgproxy) URLs.  Before using this library, you should have a running imgproxy server.

**Note:** As of version 3.0, OTP >= 22.1 and imgproxy >= 2.0.0 are required.

## Installation

To install Imgproxy, just add an entry to your `mix.exs`:

``` elixir
def deps do
  [
    {:imgproxy, "~> 3.0"}
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

The `prefix` should be the location of the imgproxy server.  `key` and `salt` are only necessary if you are using [URL signatures](https://docs.imgproxy.net/signing_the_url).  To generate the key a key and salt, you can use:

``` bash
$> mix imgproxy.gen.secret
```

You can use the output as your key or salt (ideally, just run the command twice, use the first output for your key and the second output for your salt).

## Usage

Usage is simple - first generate an `Imgproxy` struct via `Imgproxy.new/1`, add any options you'd like, then convert to a string.

Example:

```elixir
# Generate URL for an image, using defaults
Imgproxy.new("https://placekitten.com/200/300") |> to_string()

# Resize to 123x321
"https://placekitten.com/200/300"
|> Imgproxy.new()
|> Imgproxy.resize(123, 321, type: "fill")
|> to_string()


# Crop and return a jpg
"https://placekitten.com/200/300"
|> Imgproxy.new()
|> Imgproxy.crop(100, 100)
|> Imgproxy.set_extension("jpg")
|> to_string()
```

## Running Tests

To run tests:

``` shell
$> mix test
```

## Reporting Issues

Please report all issues [on github](https://github.com/bmuller/imgproxy/issues).

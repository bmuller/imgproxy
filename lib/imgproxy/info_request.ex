defmodule Imgproxy.InfoRequest do
  @moduledoc """
  `Imgproxy.InfoRequest` generates urls for use with an [imgproxy](https://imgproxy.net) server.
  """

  import Imgproxy.Request

  defstruct source_url: nil,
            endpoint: "/info",
            options: []

  alias __MODULE__

  @type t :: %__MODULE__{
          source_url: nil | String.t(),
          endpoint: String.t(),
          options: keyword(list())
        }

  @typedoc """
  Provide configuration arguments to an info option.

  Order matters for options values like:
  - alpha
  - crop
  - average
  - dominant_colors
  - blurhash

  Some options requires the image to be fully downloaded and processed:
  - detect_objects
  - alpha
  - crop
  - palette
  - average
  - dominant_colors
  - blurhash
  """
  @type info_opts :: [
          size: boolean(),
          format: boolean(),
          dimensions: boolean(),
          exif: boolean(),
          iptc: boolean(),
          xmp: boolean(),
          video_meta: boolean(),
          detect_objects: boolean(),
          colorspace: boolean(),
          bands: boolean(),
          sample_format: boolean(),
          pages_number: boolean(),
          alpha: [alpha: boolean(), check_transparency: boolean()],
          crop: [width: non_neg_integer(), height: non_neg_integer(), gravity: String.t()],
          palette: 2..256,
          average: [average: boolean(), ignore_transparent: boolean()],
          dominant_colors: [dominant_colors: boolean(), build_missed: boolean()],
          blurhash: [x_components: non_neg_integer(), y_components: non_neg_integer()],
          page: non_neg_integer(),
          video_thumbnail_second: pos_integer(),
          video_thumbnail_keyframes: boolean(),
          cachebuster: boolean(),
          expires: pos_integer(),
          preset: String.t(),
          max_src_resolution: float(),
          max_src_file_size: non_neg_integer()
        ]

  @doc """
  Generate a new `t:Imgproxy.t/0` struct for the given image source URL.
  """
  @spec new(String.t()) :: t()
  def new(source_url) when is_binary(source_url) do
    %InfoRequest{
      source_url: source_url
    }
  end

  @doc """
  Fetch and return an image [info](https://docs.imgproxy.net/usage/getting_info).

  Most options are set to `true` by default on imgproxy, except the ones that require the image to be fully downloaded and processed.
  """
  def info(request, opts \\ []) do
    Enum.reduce(opts, request, fn
      {k, v}, request when is_list(v) -> add_option(request, k, Keyword.values(v))
      {k, v}, request -> add_option(request, k, [v])
    end)
  end
end

defmodule Imgproxy.ProcessRequest do
  @moduledoc """
  `Imgproxy.ProcessRequest` generates urls for use with an [imgproxy](https://imgproxy.net) server.
  """

  import Imgproxy.Request

  defstruct source_url: nil,
            endpoint: "/",
            options: [],
            extension: nil

  alias __MODULE__

  @type t :: %__MODULE__{
          source_url: nil | String.t(),
          endpoint: String.t(),
          options: keyword(list()),
          extension: nil | String.t()
        }

  @typedoc """
  A number of pixels to be used as a dimension.
  """
  @type dimension :: float() | integer() | String.t()

  @typedoc """
  Provide type and enlarge configuration arguments to a resize option.
  """
  @type resize_opts :: [
          type: String.t(),
          enlarge: boolean()
        ]

  @doc """
  Generate a new `t:ProcessRequest.t/0` struct for the given image source URL.
  """
  @spec new(String.t()) :: t()
  def new(source_url) when is_binary(source_url) do
    %ProcessRequest{
      source_url: source_url
    }
  end

  @doc """
  Set the [gravity](https://docs.imgproxy.net/generating_the_url_advanced?id=gravity) option.
  """
  @spec set_gravity(t(), atom(), dimension(), dimension()) :: t()
  def set_gravity(request, type, xoffset \\ 0, yoffset \\ 0)

  def set_gravity(request, "sm", _xoffset, _yoffset) do
    add_option(request, :g, [:sm])
  end

  def set_gravity(request, :sm, _xoffset, _yoffset) do
    add_option(request, :g, [:sm])
  end

  def set_gravity(request, type, xoffset, yoffset) do
    add_option(request, :g, [type, xoffset, yoffset])
  end

  @doc """
  [Resize](https://docs.imgproxy.net/generating_the_url_advanced?id=resize) an image to the given width and height.

  Options include:
    * type: "fit" (default), "fill", or "auto"
    * enlarge: enlarge if necessary (`false` by default)
  """
  @spec resize(t(), dimension(), dimension(), resize_opts()) :: t()
  def resize(request, width, height, opts \\ []) do
    type = Keyword.get(opts, :type, "fit")
    enlarge = Keyword.get(opts, :enlarge, false)
    add_option(request, :rs, [type, width, height, enlarge])
  end

  @doc """
  [Crop](https://docs.imgproxy.net/generating_the_url_advanced?id=crop) an image to the given width and height.

  Accepts an optional [gravity](https://docs.imgproxy.net/generating_the_url_advanced?id=gravity) parameter, by
  default it is "ce:0:0" for center gravity with no offset.
  """
  @spec crop(t(), dimension(), dimension(), String.t()) :: t()
  def crop(request, width, height, gravity \\ "ce:0:0") do
    add_option(request, :c, [width, height, gravity])
  end

  @doc """
  Set the file extension (which will produce an image of that type).

  For instance, setting the extension to "png" will result in a PNG being created:

      iex> process = ProcessRequest.new("http://example.com/image.jpg")
      iex> ProcessRequest.set_extension(process, "png") |> to_string()
      "https://imgcdn.example.com/insecure/aHR0cDovL2V4YW1wbGUuY29tL2ltYWdlLmpwZw.png"

  """
  @spec set_extension(t(), String.t()) :: t()
  def set_extension(request, "." <> extension), do: set_extension(request, extension)

  def set_extension(request, extension), do: %ProcessRequest{request | extension: extension}
end

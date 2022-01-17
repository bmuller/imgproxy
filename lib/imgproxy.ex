defmodule Imgproxy do
  @moduledoc """
  `Imgproxy` generates urls for use with an [imgproxy](https://imgproxy.net) server.
  """

  defstruct source_url: nil, options: [], extension: nil, prefix: nil, key: nil, salt: nil

  alias __MODULE__

  @type t :: %__MODULE__{
          source_url: nil | String.t(),
          options: keyword(list()),
          extension: nil | String.t(),
          prefix: nil | String.t(),
          key: nil | String.t(),
          salt: nil | String.t()
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
  Generate a new `t:Imgproxy.t/0` struct for the given image source URL.
  """
  @spec new(String.t()) :: t()
  def new(source_url) when is_binary(source_url) do
    %Imgproxy{
      source_url: source_url,
      prefix: Application.get_env(:imgproxy, :prefix),
      key: Application.get_env(:imgproxy, :key),
      salt: Application.get_env(:imgproxy, :salt)
    }
  end

  @doc """
  Add a [formatting option](https://docs.imgproxy.net/generating_the_url_advanced) to the `t:Imgproxy.t/0`.

  For instance, to add the [padding](https://docs.imgproxy.net/generating_the_url_advanced?id=padding) option
  with a 10px padding on all sides, you can use:

      iex> img = Imgproxy.new("http://example.com/image.jpg")
      iex> Imgproxy.add_option(img, :padding, [10, 10, 10, 10]) |> to_string()
      "https://imgcdn.example.com/insecure/padding:10:10:10:10/aHR0cDovL2V4YW1wbGUuY29tL2ltYWdlLmpwZw"

  """
  @spec add_option(t(), atom(), list()) :: t()
  def add_option(%Imgproxy{options: opts} = img, name, args)
      when is_atom(name) and is_list(args) do
    %Imgproxy{img | options: Keyword.put(opts, name, args)}
  end

  @doc """
  Set the [gravity](https://docs.imgproxy.net/generating_the_url_advanced?id=gravity) option.
  """
  @spec set_gravity(t(), atom(), dimension(), dimension()) :: t()
  def set_gravity(img, type, xoffset \\ 0, yoffset \\ 0)

  def set_gravity(img, "sm", _xoffset, _yoffset) do
    add_option(img, :g, [:sm])
  end

  def set_gravity(img, :sm, _xoffset, _yoffset) do
    add_option(img, :g, [:sm])
  end

  def set_gravity(img, type, xoffset, yoffset) do
    add_option(img, :g, [type, xoffset, yoffset])
  end

  @doc """
  [Resize](https://docs.imgproxy.net/generating_the_url_advanced?id=resize) an image to the given width and height.

  Options include:
    * type: "fit" (default), "fill", or "auto"
    * enlarge: enlarge if necessary (`false` by default)
  """
  @spec resize(t(), dimension(), dimension(), resize_opts()) :: t()
  def resize(img, width, height, opts \\ []) do
    type = Keyword.get(opts, :type, "fit")
    enlarge = Keyword.get(opts, :enlarge, false)
    add_option(img, :rs, [type, width, height, enlarge])
  end

  @doc """
  [Crop](https://docs.imgproxy.net/generating_the_url_advanced?id=crop) an image to the given width and height.

  Accepts an optional [gravity](https://docs.imgproxy.net/generating_the_url_advanced?id=gravity) parameter, by
  default it is "ce:0:0" for center gravity with no offset.
  """
  @spec crop(t(), dimension(), dimension(), String.t()) :: t()
  def crop(img, width, height, gravity \\ "ce:0:0") do
    add_option(img, :c, [width, height, gravity])
  end

  @doc """
  Set the file extension (which will produce an image of that type).

  For instance, setting the extension to "png" will result in a PNG being created:

      iex> img = Imgproxy.new("http://example.com/image.jpg")
      iex> Imgproxy.set_extension(img, "png") |> to_string()
      "https://imgcdn.example.com/insecure/aHR0cDovL2V4YW1wbGUuY29tL2ltYWdlLmpwZw.png"

  """
  @spec set_extension(t(), String.t()) :: t()
  def set_extension(img, "." <> extension), do: set_extension(img, extension)

  def set_extension(img, extension), do: %Imgproxy{img | extension: extension}

  @doc """
  Generate an imgproxy URL.

  ## Example

      iex> Imgproxy.to_string(Imgproxy.new("https://placekitten.com/200/300"))
      "https://imgcdn.example.com/insecure/aHR0cHM6Ly9wbGFjZWtpdHRlbi5jb20vMjAwLzMwMA"

  """
  @spec to_string(t()) :: String.t()
  defdelegate to_string(img), to: String.Chars.Imgproxy
end

defimpl String.Chars, for: Imgproxy do
  def to_string(%Imgproxy{prefix: prefix, key: key, salt: salt} = img) do
    path = build_path(img)
    signature = gen_signature(path, key, salt)
    Path.join([prefix || "", signature, path])
  end

  #  @spec build_path(img_url :: String.t(), opts :: image_opts) :: String.t()
  defp build_path(%Imgproxy{source_url: source_url, options: opts, extension: ext}) do
    ["/" | Enum.map(opts, &option_to_string/1)]
    |> Path.join()
    |> Path.join(encode_source_url(source_url, ext))
  end

  defp encode_source_url(source_url, nil) do
    Base.url_encode64(source_url, padding: false)
  end

  defp encode_source_url(source_url, extension) do
    encode_source_url(source_url, nil) <> "." <> extension
  end

  defp option_to_string({name, args}) when is_list(args) do
    Enum.map_join([name | args], ":", &Kernel.to_string/1)
  end

  defp gen_signature(path, key, salt) when is_binary(key) and is_binary(salt) do
    decoded_key = Base.decode16!(key, case: :lower)
    decoded_salt = Base.decode16!(salt, case: :lower)

    :hmac
    |> :crypto.mac(:sha256, decoded_key, decoded_salt <> path)
    |> Base.url_encode64(padding: false)
  end

  defp gen_signature(_path, _key, _salt), do: "insecure"
end

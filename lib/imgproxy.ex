defmodule Imgproxy do
  @moduledoc """
  `Imgproxy` generates urls for use with an [imgproxy](https://imgproxy.net) server.
  """

  defstruct source_url: nil,
            options: [],
            extension: nil,
            prefix: nil,
            key: nil,
            salt: nil,
            endpoint: "/",
            source_url_encoding: :base64

  alias __MODULE__

  @source_url_encodings [:plain, :base64]
  @type source_url_encoding :: :plain | :base64

  @type t :: %__MODULE__{
          source_url: nil | String.t(),
          options: keyword(list()),
          extension: nil | String.t(),
          prefix: nil | String.t(),
          key: nil | String.t(),
          salt: nil | String.t(),
          endpoint: String.t(),
          source_url_encoding: source_url_encoding()
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
  Generate a new `t:Imgproxy.t/0` struct for the given image source URL to fetch the
  [Info Endpoint](https://docs.imgproxy.net/usage/getting_info).
  """
  @spec info_new(String.t()) :: t()
  def info_new(source_url) when is_binary(source_url) do
    %{new(source_url) | endpoint: "/info"}
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
    %{img | options: Keyword.put(opts, name, args)}
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

  def set_extension(img, extension), do: %{img | extension: extension}

  @doc """
  Set [the source URL encoding](https://docs.imgproxy.net/usage/processing#source-url) - the default is `:base64`.

  When the encoding is set to `:plain`, the source URL is prepended with `plain/`,
  the characters `%`, `?`, and `@` are percent-encoded
  and any file extension is added using `@extension` syntax.

  ## Examples

      iex> img = Imgproxy.new("https://placekitten.com/200/300?code=%@")
      iex> Imgproxy.set_source_url_encoding(img, :plain) |> to_string()
      "https://imgcdn.example.com/insecure/plain/https://placekitten.com/200/300%3Fcode=%25%40"

      iex> "https://placekitten.com/200/300"
      ...> |> Imgproxy.new()
      ...> |> Imgproxy.set_extension("png")
      ...> |> Imgproxy.set_source_url_encoding(:plain)
      ...> |> to_string()
      "https://imgcdn.example.com/insecure/plain/https://placekitten.com/200/300@png"

      iex> "https://placekitten.com/200/300"
      ...> |> Imgproxy.new()
      ...> |> Imgproxy.set_source_url_encoding(:unknown)
      ** (FunctionClauseError) no function clause matching in Imgproxy.set_source_url_encoding/2

  """

  @spec set_source_url_encoding(t(), source_url_encoding()) :: t()
  def set_source_url_encoding(img, encoding) when encoding in @source_url_encodings do
    %{img | source_url_encoding: encoding}
  end

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
  def to_string(%Imgproxy{prefix: prefix, key: key, salt: salt, endpoint: endpoint} = img) do
    path = build_path(img)
    signature = gen_signature(path, key, salt)
    Path.join([prefix || "", endpoint, signature, path])
  end

  defp build_path(%Imgproxy{options: opts} = img) do
    ["/" | Enum.map(opts, &option_to_string/1)]
    |> Path.join()
    |> Path.join(prepare_source_url(img))
  end

  defp prepare_source_url(img) do
    img.source_url
    |> optionally_encode_source_url(img)
    |> optionally_add_extension(img)
  end

  defp optionally_encode_source_url(source_url, %Imgproxy{source_url_encoding: :base64}) do
    Base.url_encode64(source_url, padding: false)
  end

  @plain_source_url_blacklist ~c"%?@"
  defp optionally_encode_source_url(source_url, _img) do
    encoded = URI.encode(source_url, &(&1 not in @plain_source_url_blacklist))
    Path.join("plain", encoded)
  end

  defp optionally_add_extension(source_url, %Imgproxy{extension: nil}) do
    source_url
  end

  defp optionally_add_extension(source_url, %Imgproxy{source_url_encoding: :plain} = img) do
    source_url <> "@" <> img.extension
  end

  defp optionally_add_extension(source_url, %Imgproxy{extension: extension}) do
    source_url <> "." <> extension
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

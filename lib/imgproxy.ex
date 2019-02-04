defmodule Imgproxy do
  @moduledoc """
  Documentation for the Imgproxy package, an Elixir library that helps generate
  urls for use with an imgproxy server.

  For usage information, see [the documentation](http://hexdocs.pm/imgproxy), which
  includes guides, API information for important modules, and links to useful resources.
  """

  @doc """
  Generate an imgproxy URL.  The first arguemnt is the URL for the image, followed by optional parameters.

  Those parameters and their defaults are:

  * resize: default, "fill"
  * width: default, 300
  * height: default, 300
  * gravity: default, "sm" for "smart"
  * enlarge: default, "1" for enlarge if necessary
  * extension: default, empty, so attempt to preserve the original image type

  ## Examples

      iex> Imgproxy.url("https://placekitten.com/200/300")
      "https://imgcdn.example.com/insecure/fill/300/300/sm/1/aHR0cHM6Ly9wbGFjZWtpdHRlbi5jb20vMjAwLzMwMA"

      iex> Imgproxy.url("https://placekitten.com/200/300",
      ...>   resize: "fill",
      ...>   width: 123,
      ...>   height: 321,
      ...>   gravity: "sm",
      ...>   enlarge: "1",
      ...>   extension: "jpg")
      "https://imgcdn.example.com/insecure/fill/123/321/sm/1/aHR0cHM6Ly9wbGFjZWtpdHRlbi5jb20vMjAwLzMwMA.jpg"

  """
  def url(img_url, opts \\ []) do
    prefix = Application.get_env(:imgproxy, :prefix, "")
    path = build_path(img_url, opts)
    signature = gen_signature(path)
    Path.join([prefix, signature, path])
  end

  @doc """
  Generate an imgproxy URL.  The first arguemnt is the URL for the image, followed by 
  width and height.  All other parameters are generated using defaults.

  ## Examples

      iex> Imgproxy.url("https://placekitten.com/200/300", 100, 150)
      "https://imgcdn.example.com/insecure/fill/100/150/sm/1/aHR0cHM6Ly9wbGFjZWtpdHRlbi5jb20vMjAwLzMwMA"

  """
  def url(img_url, width, height) do
    url(img_url, width: width, height: height)
  end

  @doc """
  Generate a path to an image based on the given image url and image options.

  This is the path to the image *after* the signature, so the result of this call should be
  appended to the imgproxy's url and signature value to create the final image path.  This is
  public because it can be used directly if you don't need a signature.  The optional parameters
  are the same as for `url/2`.  For instance:

  ## Examples

      iex> partial_path = Imgproxy.build_path("https://placekitten.com/200/300")
      iex> "https://imgcdn.example.com" <> "/insecure" <> partial_path
      "https://imgcdn.example.com/insecure/fill/300/300/sm/1/aHR0cHM6Ly9wbGFjZWtpdHRlbi5jb20vMjAwLzMwMA"
  """
  def build_path(img_url, opts \\ []) do
    ext =
      if opts[:extension] do
        "." <> opts[:extension]
      else
        ""
      end

    Path.join([
      "/",
      opts[:resize] || "fill",
      to_string(opts[:width] || 300),
      to_string(opts[:height] || 300),
      opts[:gravity] || "sm",
      to_string(opts[:enlarge] || "1"),
      Base.url_encode64(img_url, padding: false) <> ext
    ])
  end

  defp gen_signature(path) do
    with {:ok, dkey} <- Application.fetch_env(:imgproxy, :key),
         {:ok, dsalt} <- Application.fetch_env(:imgproxy, :salt),
         key <- Base.decode16!(dkey, case: :lower),
         salt <- Base.decode16!(dsalt, case: :lower) do
      :sha256
      |> :crypto.hmac(key, salt <> path)
      |> Base.url_encode64(padding: false)
    else
      _ -> "insecure"
    end
  end
end

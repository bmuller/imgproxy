defmodule Imgproxy.Request do
  @doc """
  Add a [formatting option](https://docs.imgproxy.net/generating_the_url_advanced) to a request.

  For instance, to add the [padding](https://docs.imgproxy.net/generating_the_url_advanced?id=padding) option
  with a 10px padding on all sides, you can use:

      iex> request = Imgproxy.ProcessRequest.new("http://example.com/image.jpg")
      iex> Imgproxy.Request.add_option(request, :padding, [10, 10, 10, 10]) |> to_string()
      "https://imgcdn.example.com/insecure/padding:10:10:10:10/aHR0cDovL2V4YW1wbGUuY29tL2ltYWdlLmpwZw"

  """
  @spec add_option(struct(), atom(), list()) :: struct()
  def add_option(%{options: opts} = request, name, args)
      when is_atom(name) and is_list(args) do
    %{request | options: Keyword.put(opts, name, args)}
  end
end

defimpl String.Chars, for: [Imgproxy.InfoRequest, Imgproxy.ProcessRequest] do
  def to_string(%{endpoint: endpoint} = request) do
    prefix = Application.get_env(:imgproxy, :prefix)
    key = Application.get_env(:imgproxy, :key)
    salt = Application.get_env(:imgproxy, :salt)
    path = build_path(request)
    signature = gen_signature(path, key, salt)
    Path.join([prefix || "", endpoint, signature, path])
  end

  #  @spec build_path(img_url :: String.t(), opts :: image_opts) :: String.t()
  defp build_path(%{source_url: source_url, options: opts} = request) do
    ext = Map.get(request, :extension)

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

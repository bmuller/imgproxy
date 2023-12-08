defmodule Imgproxy.InfoRequestTest do
  use ExUnit.Case

  alias Imgproxy.InfoRequest

  doctest InfoRequest

  @img_url "http://example.com/image.gif"
  @img_url_encoded Base.url_encode64(@img_url, padding: false)
  @prefix "https://imgcdn.example.com"

  setup_all do
    Application.put_env(:imgproxy, :prefix, @prefix)
  end

  describe "building signed urls should" do
    setup do
      Application.put_env(
        :imgproxy,
        :key,
        "6b505d74dfaee5742f951abff4893ceb9e61b7a7dd52a462d6b2c641"
      )

      Application.put_env(:imgproxy, :salt, "784b05d765951edaadc64130bf19750b0d")

      on_exit(fn ->
        Application.delete_env(:imgproxy, :key)
        Application.delete_env(:imgproxy, :salt)
      end)
    end

    test "support multiple options on info" do
      result =
        @img_url
        |> InfoRequest.new()
        |> InfoRequest.info(dimensions: true, alpha: [alpha: true, check_transparency: true])
        |> to_string()

      signature = "kE0lzVluLw2VDLY3KBDfvZzqXkzsurQvuWGz6Ay39ks"

      assert result ==
               "#{@prefix}/info/#{signature}/alpha:true:true/dimensions:true/#{@img_url_encoded}"
    end
  end
end

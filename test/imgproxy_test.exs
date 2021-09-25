defmodule ImgproxyTest do
  use ExUnit.Case
  doctest Imgproxy

  @img_url "http://example.com/image.gif"
  @img_url_encoded Base.url_encode64(@img_url, padding: false)
  @prefix "https://imgcdn.example.com"

  setup_all do
    Application.put_env(:imgproxy, :prefix, @prefix)
  end

  describe "building unsigned urls should" do
    test "support no processing options" do
      result = @img_url |> Imgproxy.new() |> to_string()
      assert result == "#{@prefix}/insecure/#{@img_url_encoded}"
    end

    test "support the resize option with arguments" do
      result =
        @img_url
        |> Imgproxy.new()
        |> Imgproxy.resize(123, 456, type: "fill", enlarge: true)
        |> to_string()

      assert result == "#{@prefix}/insecure/rs:fill:123:456:true/#{@img_url_encoded}"
    end

    test "support multiple options" do
      result =
        @img_url
        |> Imgproxy.new()
        |> Imgproxy.resize(123, 456, type: "fill", enlarge: true)
        |> Imgproxy.set_gravity("sm")
        |> to_string()

      assert result == "#{@prefix}/insecure/g:sm/rs:fill:123:456:true/#{@img_url_encoded}"
    end

    test "support setting an extension" do
      result = @img_url |> Imgproxy.new() |> Imgproxy.set_extension("png") |> to_string()
      assert result == "#{@prefix}/insecure/#{@img_url_encoded}.png"

      # now try with an unnecessary dot
      result = @img_url |> Imgproxy.new() |> Imgproxy.set_extension(".jpg") |> to_string()
      assert result == "#{@prefix}/insecure/#{@img_url_encoded}.jpg"
    end
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

    test "support no processing options" do
      result = @img_url |> Imgproxy.new() |> to_string()
      signature = "F7xXm0-O-JVpBIz5Z9JvBGog19LgvTDT4y8dzIQ9H28"
      assert result == "#{@prefix}/#{signature}/#{@img_url_encoded}"
    end

    test "support the resize option with arguments" do
      result =
        @img_url
        |> Imgproxy.new()
        |> Imgproxy.resize(123, 456, type: "fill", enlarge: true)
        |> to_string()

      signature = "o0xH0LYlMU7-2lCm4HqeahdxX0elC4AmnF6H0PKyiio"
      assert result == "#{@prefix}/#{signature}/rs:fill:123:456:true/#{@img_url_encoded}"
    end

    test "support multiple options" do
      result =
        @img_url
        |> Imgproxy.new()
        |> Imgproxy.resize(123, 456, type: "fill", enlarge: true)
        |> Imgproxy.set_gravity("sm")
        |> to_string()

      signature = "SCMuOeSYIRAA1nxJbuuKXnvRBsW0X50xjhqJz_xSDf4"
      assert result == "#{@prefix}/#{signature}/g:sm/rs:fill:123:456:true/#{@img_url_encoded}"
    end
  end
end

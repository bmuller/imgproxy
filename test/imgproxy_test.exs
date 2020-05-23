defmodule ImgproxyTest do
  use ExUnit.Case
  doctest Imgproxy

  @img_url "http://example.com/image.gif"

  setup_all do
    Application.put_env(:imgproxy, :prefix, "https://imgcdn.example.com")
  end

  setup do
    # these shouldn't be set for any tests beforehand
    Application.delete_env(:imgproxy, :key)
    Application.delete_env(:imgproxy, :salt)
  end

  test "building paths with options" do
    path =
      Imgproxy.build_path(@img_url,
        resize: "fill",
        width: 123,
        height: 321,
        gravity: "sm",
        enlarge: "1",
        extension: "jpg"
      )

    assert path == "/fill/123/321/sm/1/aHR0cDovL2V4YW1wbGUuY29tL2ltYWdlLmdpZg.jpg"
  end

  test "building paths with no options" do
    path = Imgproxy.build_path(@img_url)
    assert path == "/fill/300/300/sm/1/aHR0cDovL2V4YW1wbGUuY29tL2ltYWdlLmdpZg"
  end

  test "generating unsigned urls" do
    url =
      Imgproxy.url(@img_url,
        resize: "fill",
        width: 123,
        height: 321,
        gravity: "sm",
        enlarge: "1",
        extension: "jpg"
      )

    assert url ==
             "https://imgcdn.example.com/insecure/fill/123/321/sm/1/aHR0cDovL2V4YW1wbGUuY29tL2ltYWdlLmdpZg.jpg"

    url = Imgproxy.url(@img_url)

    assert url ==
             "https://imgcdn.example.com/insecure/fill/300/300/sm/1/aHR0cDovL2V4YW1wbGUuY29tL2ltYWdlLmdpZg"
  end

  test "generating signed urls" do
    Application.put_env(:imgproxy, :key, "cdf104")
    Application.put_env(:imgproxy, :salt, "aad703")

    url =
      Imgproxy.url(@img_url,
        resize: "fill",
        width: 123,
        height: 321,
        gravity: "sm",
        enlarge: "1",
        extension: "jpg"
      )

    assert url ==
             "https://imgcdn.example.com/CA1v4B6CBOXeIkqrA0XtVBw6YqzwetOKHx3S60RWoJw/fill/123/321/sm/1/aHR0cDovL2V4YW1wbGUuY29tL2ltYWdlLmdpZg.jpg"

    url = Imgproxy.url(@img_url)

    assert url ==
             "https://imgcdn.example.com/tSqlg82gF_vEMIx9PBjPM_WmZrmypk6UdGJ_WEPsCAs/fill/300/300/sm/1/aHR0cDovL2V4YW1wbGUuY29tL2ltYWdlLmdpZg"
  end
end

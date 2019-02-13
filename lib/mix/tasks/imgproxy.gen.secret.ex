defmodule Mix.Tasks.Imgproxy.Gen.Secret do
  @shortdoc "Generate a secret for use as salt / key"
  @moduledoc """
  Generates a secret that could be used as a salt or key and prints it to the terminal.

       mix imgproxy.gen.secret

  """
  use Mix.Task

  def run([]) do
    64
    |> :crypto.strong_rand_bytes()
    |> Base.encode16(case: :lower)
    |> Mix.Shell.IO.info()
  end
end

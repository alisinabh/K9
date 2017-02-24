defmodule Knine.Mixfile do
  use Mix.Project

  def project do
    [app: :knine,
     version: "0.0.1",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),

     name: "Knine",
     description: description(),
     source_url: "https://github.com/alisinabh/Knine",
     homepage_url: "https://github.com/alisinabh/Knine",
     docs: [main: "Knine", # The main page in the docs
          extras: ["README.md"]],
     package: package()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger],
     mod: {Knine.Application, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:dialyze, only: [:test, :dev]},
     {:ex_doc, only: [:test, :dev]},
     {:earmark, only: [:test, :dev]}]
  end

  defp description do
    """
    Knine is a deamon to monitor a service availability in different perspectives.
    """
  end

  defp package do
    [
      name: :knine,
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Alisina Bahadori"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/alisinabh/Knine"}
     ]
  end
end

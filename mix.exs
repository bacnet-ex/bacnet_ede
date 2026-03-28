defmodule BACnetEDE.MixProject do
  use Mix.Project

  @source_url "https://github.com/bacnet-ex/bacnet_ede"

  def project do
    [
      app: :bacnet_ede,
      version: "0.1.1",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      # This is the cause for unknown protocol __impl__/1 for built-in types
      consolidate_protocols: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [
        ignore_warnings: "dialyzer.ignore-warnings.exs",
        plt_add_apps: []
      ],
      source_url: @source_url,
      description:
        "BACnetEDE is a BACnet EDE File parser and writer. EDE stands for Engineering Data Exchange.",
      docs: [
        main: "BACnetEDE",
        source_ref: "master",
        groups_for_docs: [Guards: & &1[:guard]],
        groups_for_modules: [],
        nest_modules_by_prefix: []
        # before_closing_head_tag: &docs_before_closing_head_tag/1,
        # before_closing_body_tag: &docs_before_closing_body_tag/1
      ],
      package: package(),
      test_coverage: [
        ignore_modules: [~r"Inspect\..+", BACnetEDE.CSV, BACnetEDE.CSV.TwoCellFormat],
        summary: true,
        tool: if(System.get_env("CI"), do: ExCoveralls, else: Mix.Tasks.Test.Coverage)
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:dialyxir, "1.4.3", only: [:dev, :test], runtime: false},
      {:doctor, "~> 0.21", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.29", only: [:dev, :test], runtime: false},
      # {:excoveralls, "~> 0.18", only: [:test], runtime: false},
      # {:junit_formatter, "~> 3.3", only: [:test], runtime: false},
      {:nimble_csv, "~> 1.3"}
    ]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package() do
    [
      maintainers: ["bacnet-ex"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url}
    ]
  end
end

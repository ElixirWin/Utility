defmodule FirewallUtility.Mixfile do
  use Mix.Project

  def project do
    [ app: :firewall_utility,
      version: "0.0.1",
      escript_main_module: FirewallUtility,
      deps: deps ]
  end

  def application do
    [applications: []]
  end

  defp deps, do: []
end

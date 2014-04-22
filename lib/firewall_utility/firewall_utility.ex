defmodule FirewallUtility do
  @moduledoc """
  Configure the windows firewall to allow Erlang/Elixir traffic to pass through
  """
  import System

  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  @doc """
  `argv` can be -h or --help, which returns :help

  Otherwise a rulename and executable must be specified

  Return a tuple of `{rulename, executable}`, or `:help` if help was given.
  """
  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [help: :boolean],
                                     aliases:  [h:    :help])
    case parse do
      {[help: true], _, _} ->
        :help
      {_, [rulename, direction, executable], _} ->
        {rulename, direction, executable}
      _ ->
        :help
    end
  end

  def process(:help) do
    IO.puts """
    usage: firewall_utility <rulename> <direction> <executable>
    rulename is short name for rule (e. g. "erl")
    direction is [in|out]
    executable is the full path to the executable (e. g. \\progra~1\\erl6.0\\bin\\erl.exe)
    """
    System.halt(0)
  end

  def process({rulename, direction, executable}) do
    create_win_firewall_rule(rulename, direction, executable)
  end

  @doc """
  If there is not already a rule to pass through traffic then create this rule
  """
  def create_win_firewall_rule(rulename, direction, executable) do
    unless firewall_rule_already_exists?(rulename, direction) do
      add_rule_cmd = "add rule name=#{rulename} dir=#{direction} action=allow program=#{executable} profile=domain"
      add_rule_cmd |> build_netsh_command |> cmd
    end
  end

  defp path_to_netsh do 
    "#{get_env("SystemRoot")}/system32/netsh.exe"
  end

  defp get_correctly_formed_netsh_command(command_argument) do
    " advfirewall firewall #{command_argument} "
  end

  defp build_netsh_command(subcommand) do
    path_to_netsh <> get_correctly_formed_netsh_command(subcommand)
  end        

  defp firewall_rule_already_exists?(rulename, direction) do
    test_for_rule_args = "show rule #{rulename} "
    result = test_for_rule_args |> build_netsh_command |> cmd
    if not (Regex.match?(~r/No rules match/i, result)) do
      Regex.match?(~r/Direction:\s*"#{direction}"/i,result) 
    else
      false
    end
  end
end
defmodule ConfigWinFirewallForElixir do
    import System
    use Application.Behaviour

@moduledoc """
Configure the windows firewall to allow Erlang/Elixir traffic to pass through
"""
    defp path_to_netsh do 
        root = get_env("SystemRoot")
        root <> "/system32/netsh.exe"
    end

    defp get_correctly_formed_netsh_command(command_argument) do
        " advfirewall firewall " <> command_argument
    end

    defp build_netsh_command(subcommand) do
        path_to_netsh <> get_correctly_formed_netsh_command(subcommand)
    end        

    defp firewall_rule_already_exists?(rulename) do
        test_for_rule_args = "show rule " <> rulename
        result = cmd(build_netsh_command(test_for_rule_args))
        #Easier to look for the absence of a rule and negate it
        not Regex.match?(~r/No rules match/i,result)
    end

    @doc "if there is not already a rule to pass through erlang traffic then create this rule"
    def create_win_firewall_rule(rulename, executable) do
        if not firewall_rule_already_exists?(rulename) do
            add_rule_cmd = "add rule name=" <> rulename <> " dir=out action=allow program=" <> executable <> " profile=domain"
            result = cmd(build_netsh_command(add_rule_cmd))
        end
    end

    def start(_type, _args) do
        ConfigWinFirewallForElixir.Supervisor.start_link
    end
end    
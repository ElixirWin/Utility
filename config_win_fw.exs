defmodule ConfigWinFirewallForElixir do
    import System
@moduledoc """
Configure the windows firewall to allow Erlang/Elixir traffic to pass through
"""
    @doc "return the default path to the netsh executable"
    defp path_to_netsh do 
        root = get_env("SystemRoot")
        root <> "/system32/netsh.exe"
    end

    @doc "return a correctly formed netsch command"
    defp get_correctly_formed_netsh_command(command_argument) do
        " advfirewall firewall " <> command_argument
    end

    @doc "simply check if there is already an existing rule"
    defp firewall_rule_already_exists?(rulename) do
        test_for_rule_args = "show rule " <> rulename
        test_for_rule_cmd = path_to_netsh <> get_correctly_formed_netsh_command(test_for_rule_args)
        result = cmd(test_for_rule_cmd)
        #Easier to look for the absence of a rule and negate it
        not Regex.match?(~r/No rules match/i,result)
    end

    @doc "if there is not already a rule to pass through erlang traffic then create this rule"
    def create_win_firewall_rule(rulename, executable) do
        if not firewall_rule_already_exists?(rulename) do
            add_rule_cmd = "add rule name=" <> rulename <> " dir=out action=allow program=" <> executable <> " profile=domain"
            full_add_rule_cmd = path_to_netsh <> get_correctly_formed_netsh_command(add_rule_cmd)
            result = cmd(full_add_rule_cmd)
        end
    end

end    
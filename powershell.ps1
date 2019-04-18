#PowerShell Allowing Remote Administration


Enable-NetFirewallRule -DisplayGroup "Remote Service Management"
Enable-NetFirewallRule -DisplayGroup "Windows Firewall Remote Management"
Enable-NetFirewallRule -DisplayGroup "Remote Event Log Management"
Enable-NetFirewallRule -DisplayGroup "Remote Scheduled Tasks Management"

New-NetFirewallRule -DisplayName "Allow SSH port 22" -Direction InBound -LocalPort 22 -Protocol TCP -Action Allow
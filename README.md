# Random-AD-or-Windows-tasks
Mostly just quick &amp; dirty configs for new VMs, DFS, etc. These are really just glorified batch files in PowerShell.

Get-Dirty bounces a Dirty Word List off the PowerShell Transcript Logs.

Get-Clean bounces whitelisted users off the PowerShell Transcript Logs and flags anyone else who ran PowerShell (useful for catching phishing). Get-Clean was called Get-NonAdmins at first, but I thought Get-Clean was more catchy.

PowerShell Transcript Logging must be enabled first: https://happycamper84.medium.com/enabling-powershell-scriptblock-and-transcript-logging-68a6ca339794

I added a sample Dirty Word list with some commman attacker commands like 'iex' and a bunch of stuff from my Red Team notes. Obviously attackers can obfuscate, use PS1s with custom named functions, etc. This is just a PoC to test the idea and a good start towards flagging the low hanging fruit and script kiddies.

# DESCRIPTION: Vérifie si un port donné est ouvert sur un serveur distant.
$ip = "192.168.1.1"
$port = 3389
Test-NetConnection -ComputerName $ip -Port $port

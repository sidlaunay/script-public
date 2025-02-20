# DESCRIPTION: Affiche toutes les connexions TCP actives et leur état (équivalent de 'netstat').
Get-NetTCPConnection | Sort-Object -Property State

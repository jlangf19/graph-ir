<#
Author: Joshua Langford
Description: This script collects metadata of Windows service objects and selects specific properties related to forensic analysis.
Output:
    Type: CSV
    Attributes: Name, file path, PID, start mode, and installation date (all in Neo4j time formatting)
#>
$services = Get-CimInstance -Class Win32_Service | Select-Object -Property Name, pathname, processid, installdate, StartMode
foreach($x in $services){
    $path = $x.pathname -split " -"
    $path = $path[0] -split " /"
    $path = $path -replace '["]'
    $hostname = Get-WmiObject Win32_ComputerSystem | Select-Object -ExpandProperty name
    $domain = Get-WmiObject Win32_ComputerSystem | Select-Object -ExpandProperty domain
    $x | Add-Member $hostname -Name hostname -MemberType NoteProperty
    $x | Add-Member $domain -Name domain -MemberType NoteProperty
    $x | Add-Member $path[0] -Name filepath -MemberType NoteProperty
}
$json_services = ConvertTo-Json -InputObject $services
$json_services | Out-File '\\TRUENAS\data\BACKUP\Storage\IR Graph Project\Collection Scripts\Development\services.json'

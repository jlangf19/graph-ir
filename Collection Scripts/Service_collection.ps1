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
    $x | Add-Member $path[0] -Name filepath -MemberType NoteProperty
}
$services | Export-Csv -Path 'C:\Users\jlang\Documents\HES\CSCI E-59\Final Project\Data Sources\services.csv'

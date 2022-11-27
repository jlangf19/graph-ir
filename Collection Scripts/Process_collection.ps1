<#
Author: Joshua Langford
Description: This script collects metadata of Windows process objects and selects specific properties related to forensic analysis.
Output:
    Type: CSV
    Attributes: Name, executable path, PID, parent PID, and creation time(all in Neo4j time formatting)
#>
$procs = Get-CimInstance -Class Win32_Process 
foreach($x in $procs){
    $owner = Invoke-CimMethod -InputObject $x -MethodName GetOwner | Select-Object -ExpandProperty User
    $hostname = Get-WmiObject Win32_ComputerSystem | Select-Object -ExpandProperty name
    $domain = Get-WmiObject Win32_ComputerSystem | Select-Object -ExpandProperty domain
    $x | Add-Member $hostname -Name hostname -MemberType NoteProperty
    $x | Add-Member $domain -Name domain -MemberType NoteProperty
    $x | Add-Member $owner -Name user -MemberType NoteProperty
    $x | Add-Member (('{0:yyyyMMdd}' -f $x.creationdate).ToString() + "T" + ('{0:HH:mm}' -f $x.creationdate).ToString() + "Z") -Name neo4jcreationtime -MemberType NoteProperty
}
$procs = $procs | Select-Object -Property name, processid,parentprocessid,ExecutablePath,creationdate,user,hostname,domain,neo4jcreationtime
# $procs | Export-Csv -Path 'C:\Users\jlang\Documents\HES\CSCI E-59\Final Project\Data Sources\processes.csv'
$json_procs = ConvertTo-Json -InputObject $procs
$json_procs | Out-File '\\TRUENAS\data\BACKUP\Storage\IR Graph Project\Collection Scripts\Development\processes.json'

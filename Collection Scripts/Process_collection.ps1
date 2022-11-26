<#
Author: Joshua Langford
Description: This script collects metadata of Windows process objects and selects specific properties related to forensic analysis.
Output:
    Type: CSV
    Attributes: Name, executable path, PID, parent PID, and creation time(all in Neo4j time formatting)
#>
$procs = Get-CimInstance -Class Win32_Process | Select-Object -Property name, processid,parentprocessid,ExecutablePath, creationdate
foreach($x in $procs){
    $x | Add-Member (('{0:yyyyMMdd}' -f $x.creationdate).ToString() + "T" + ('{0:HH:mm}' -f $x.creationdate).ToString() + "Z") -Name neo4jcreationtime -MemberType NoteProperty
}
$procs | Export-Csv -Path 'C:\Users\jlang\Documents\HES\CSCI E-59\Final Project\Data Sources\processes.csv'

<#
Author: Joshua Langford
Description: This script collects metadata of Windows file objects and selects specific properties related to forensic analysis.
Output:
    Type: CSV
    Attributes: Name, file path, file extension, SHA1 hash, creation time, last access time, and last write time (all in Neo4j time formatting)
#>
$files = ls | Where-Object -Property Attributes -eq 'Archive'
foreach($x in $files){
    $x| Add-Member ($x.Directory.ToString() + "\" + $x.Name.ToString()) -Name Path -MemberType NoteProperty
    $y = Get-FileHash $x -Algorithm SHA1
    $x | Add-Member $y.Hash -Name Hash -MemberType NoteProperty
    $x | Add-Member (('{0:yyyyMMdd}' -f $x.CreationTimeUtc).ToString() + "T" + ('{0:HH:mm}' -f $x.CreationTimeUtc).ToString() + "Z") -Name neo4jcreationtime -MemberType NoteProperty
    $x | Add-Member (('{0:yyyyMMdd}' -f $x.LastAccessTimeUtc).ToString() + "T" + ('{0:HH:mm}' -f $x.LastAccessTimeUtc).ToString() + "Z") -Name neo4jlastaccesstime -MemberType NoteProperty
    $x | Add-Member (('{0:yyyyMMdd}' -f $x.LastWriteTimeUtc).ToString() + "T" + ('{0:HH:mm}' -f $x.LastWriteTimeUtc).ToString() + "Z") -Name neo4jlastwritetime -MemberType NoteProperty
}
$files | Select-Object -Property Name,Path,Extension,neo4jcreationtime,neo4jlastaccesstime,neo4jlastwritetime,hash | Export-Csv -Path 'C:\Users\jlang\Documents\HES\CSCI E-59\Final Project\Data Sources\files.csv'




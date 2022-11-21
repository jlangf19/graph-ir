$procs = Get-CimInstance -Class Win32_Process | Select-Object -Property name, processid,parentprocessid,ExecutablePath, creationdate
foreach($x in $procs){
    $x | Add-Member (('{0:yyyyMMdd}' -f $x.creationdate).ToString() + "T" + ('{0:HH:mm}' -f $x.creationdate).ToString() + "Z") -Name neo4jcreationtime -MemberType NoteProperty
}
$procs | Export-Csv -Path 'C:\Users\jlang\Documents\HES\CSCI E-59\Final Project\Data Sources\processes.csv'
$procs = Get-CimInstance -Class Win32_Process
foreach($x in $procs){
    $owner = Invoke-CimMethod -InputObject $x -MethodName GetOwner
    $x | Add-Member $owner -Name User -MemberType NoteProperty
    $x | Add-Member (('{0:yyyyMMdd}' -f $x.creationdate).ToString() + "T" + ('{0:HH:mm}' -f $x.creationdate).ToString() + "Z") -Name neo4jcreationtime -MemberType NoteProperty
}
# $procs | Export-Csv -Path 'C:\Users\jlang\Documents\HES\CSCI E-59\Final Project\Data Sources\processes.csv'
$json_procs = ConvertTo-Json -InputObject $procs 
$json_procs | Out-File 'Z:\Storage\IR Graph Project\Data Sources\Host\21_05_22\processes.json'
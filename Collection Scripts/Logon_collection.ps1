# Performs the parse and enrichment of the logon
Function Parse-LogonObject {
    Param(
        $Logon
    )
    $reg = '(?s)Logon Type:\s*?(?<logon_type>\d+).*?Virtual Account:\s*?(?<virtual_account>%%\d{4}).*?Elevated Token:\s*?(?<elevated_token>%%\d{4}).*?Impersonation Level:\s*?(?<impersonation_level>%%\d{4}).*?Security ID:\s*?(?<sid>S-\d+-\d+-\d+).*?Account Name:\s*?(?<account_name>\S.*?)\s*?Account Domain:\s*?(?<account_domain>\S.*?)\s*?Logon ID:\s*?(?<logon_id>0x\d.*?)\s*?Linked Logon ID:\s*?(?<linked_logon_id>0x\d.*?)\s*?Network Account Name:\s*?(?<network_account_name>\S.*?)\s*?Network Account Domain:\s*?(?<network_account_Domain>\S.*?).*?Logon GUID:\s*?(?<logon_gui>\S.*?)\s.*?Process ID:\s*?(?<pid>0x\d.*?)\s*?Process Name:\s*?(?<process_name>\S.*?)\s\s.*?Workstation Name:\s*?(?<logon_hostname>\S.*?)\s*?Source Network Address:\s*?(?<source_address>\S.*?)\s*?Source Port:\s*?(?<source_address>\S.*?).*?Logon Process:\s*?(?<logon_processes>\S.*?)\s'
    $vals = @{time = $Logon.TimeGenerated; hostname = $Logon.MachineName}
    $message = $Logon.Message
    $val = $message -match $reg
    foreach ($property in 'elevated_token','virtual_account','impersonation_level') {
        $Matches.$property = $msobj_hash[$Matches.$property]
    }
    foreach ($property in 'pid','logon_id','linked_logon_id') {
        $Matches.$property = [uint32]$Matches.$property
    }
    $Matches.Remove(0)
    $vals += $Matches
    $logon_object = New-Object PSObject -Property $vals
    $logon_object
}

# msobjs.dll encoding translations
$msobj_hash = @{"%%1832" = "Identification"; "%%1833" = "Impersonation";
                "%%1840" = "Delegation"; "%%1841" = "Denied by Process Trust Label ACE";
                "%%1842" = "Yes"; "%%1843" = "No"; "%%1844" = "System";
                "%%1845" = "Not Available"; "%%1846" = "Default";
                "%%1847" = "DisallowMmConfig"; "%%1848" = "Off"; "%%1849" = "Auto"
}

$logons = Get-EventLog -LogName Security -InstanceId 4624
$logon_list = @()
foreach ($event in $logons){
    $logon_obj = Parse-LogonObject -Logon $event
    $logon_list += $logon_obj
}
$logon_list | ConvertTo-Csv -NoTypeInformation | Set-Content -path '\\TRUENAS\data\BACKUP\Storage\IR Graph Project\Collection Scripts\Data\logons.csv'

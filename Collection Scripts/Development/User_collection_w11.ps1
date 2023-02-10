# Functions

# Parses log fields into an array containing a key value pair
Function Parse-Line {
    Param(
        $Value
    ) 
    $Value = $Value -split ":", 2
    $Value[0] = $Value[0].Trim()
    $Value[1] = $Value[1].Trim()
    $Value = @{$Value[0] = $Value[1]}
    $Value
}

# Performs the parse and enrichment of the logon
Function Parse-LogonObject {
    Param(
        $Logon
    )
    # Indicates the positions within a Powershell logon event message that contain information of value
    # Note: index values inconsistent with previous identified relevant keys
    $value_index = @(9,11,12,14,17,18,19,20,21,22,23,27,28,31,32,33,36,37,38)
    $vals = @{time = $Logon.TimeGenerated; hostname = $Logon.MachineName}
    $message = $Logon.Message
    $message = $message.Split([Environment]::NewLine)
    foreach ($index in $value_index) {
        $val = Parse-Line -Value $message[$index]
        # Checks for values requiring conversion from the msobj.dll format (Virtual Account, Elevated Token, Impersonation Level)
        if($index -in 11,12,14){
            $temp_key = $val.GetEnumerator().Name
            $temp_val = $val[$temp_key]
            $temp_val = $msobj_hash[$temp_val]
            $val[$temp_key] = $temp_val
        }
        # Checks for values requiring conversion from hexidecimal (Logon ID, Linked Logon ID, PID)
        elseif($index -in 20,21,27) {
            $temp_key = $val.GetEnumerator().Name
            $temp_val = $val[$temp_key]
            $temp_val = [uint32]$temp_val
            $val[$temp_key] = $temp_val
        }
        $vals += $val
    }
    $logon_object = New-Object PSObject -Property $vals
    $logon_object
}

# Logon Event ID: 4624
# Logoff Event IDs: 4647, 4634
$logons = Get-EventLog -LogName Security -InstanceId 4624
$logoffs_noninteractive = Get-EventLog -LogName Security -InstanceId 4634
$logoffs_interactive = Get-EventLog -LogName Security -InstanceId 4647

# msobjs.dll encoding translations
$msobj_hash = @{"%%1832" = "Identification"; "%%1833" = "Impersonation";
                "%%1840" = "Delegation"; "%%1841" = "Denied by Process Trust Label ACE";
                "%%1842" = "Yes"; "%%1843" = "No"; "%%1844" = "System";
                "%%1845" = "Not Available"; "%%1846" = "Default";
                "%%1847" = "DisallowMmConfig"; "%%1848" = "Off"; "%%1849" = "Auto"
}

# Parse login events
$logon_list = @()
foreach ($event in $logons){
    Parse-LogonObject -Logon $event
    $logon_list += $logon_event
} 

# Parse interactive logoff events
$logoff_list = @()
foreach ($event in $logoffs_interactive){
    $machine = $event.MachineName
    $time = $event.TimeGenerated
    $message = $event.Message
    $message = $message.Split([Environment]::NewLine)
    $sid = $message[6]
    $sid = $sid.split()
    $sid = $sid[4]
    $account = $message[8]
    $account = $account.split()
    $account = $account[4]
    $domain = $message[10]
    $domain = $domain.split(":")
    $domain = $domain[1].remove(0,2)
    $login_id = $message[12]
    $login_id = $login_id.Split()
    $login_id = [uint32]$login_id[4]
    $logoff_event = [PSCustomObject]@{
        Host = $machine
        Time = $time
        Login_ID = $login_id
        Account = $account
        Domain = $domain
        SID = $sid
        }
    $logoff_list += $logoff_event
}
# Parse non-interactive logoff events
foreach ($event in $logoffs_noninteractive){
    $machine = $event.MachineName
    $time = $event.TimeGenerated
    $message = $event.Message
    $message = $message.Split([Environment]::NewLine)
    $sid = $message[6]
    $sid = $sid.split()
    $sid = $sid[4]
    $account = $message[8]
    $account = $account.split()
    $account = $account[4]
    $domain = $message[10]
    $domain = $domain.split(":")
    $domain = $domain[1].remove(0,2)
    $login_id = $message[12]
    $login_id = $login_id.Split()
    $login_id = [uint32]$login_id[4]
    $logoff_event = [PSCustomObject]@{
        Host = $machine
        Time = $time
        Login_ID = $login_id
        Account = $account
        Domain = $domain
        SID = $sid
        }
    $logoff_list += $logoff_event
}
$logoff_list | ConvertTo-Csv -NoTypeInformation | Set-Content -path '\\TRUENAS\data\BACKUP\Storage\IR Graph Project\Collection Scripts\Data\logoffs.csv'
$logon_list | ConvertTo-Csv -NoTypeInformation | Set-Content -path '\\TRUENAS\data\BACKUP\Storage\IR Graph Project\Collection Scripts\Data\logons.csv'
#$json_logon_summary = ConvertTo-Json -InputObject $logon_list -Depth 10
#$json_logoff_summary = ConvertTo-Json -InputObject $logoff_list -Depth 10
#$json_logon_summary | Out-File 'C:\Users\jlang\Documents\HES\CSCI S-33\Final_Project\logon_summary.json'
#$json_logoff_summary | Out-File 'C:\Users\jlang\Documents\HES\CSCI S-33\Final_Project\logoff_summary.json'

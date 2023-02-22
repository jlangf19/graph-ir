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
    # Note: index values inconsistent with previous identified relevant keys (24->22, 28->24, 30->
    # $reg = 'Logon Type:\s*?(?<logon_type>\d)|Virtual Account:\s*(?<virtual_account>%%\d{4})|Elevated Token:\s*?(?<elevated_token>%%\d{4})|Impersonation Level:\s*?(?<impersonation_level>%%\d{4})|Security ID:\s*?(?<security_id>S-\d-\d-\d{2})'
    $reg = '(?s)Logon Type:\s*?(?<logon_type>\d+).*?
            Virtual Account:\s*?(?<virtual_account>%%\d{4}).*?
            Elevated Token:\s*?(?<elevated_token>%%\d{4}).*?
            Impersonation Level:\s*?(?<impersonation_level>%%\d{4}).*?
            Security ID:\s*?(?<sid>S-\d+-\d+-\d+).*?
            Account Name:\s*?(?<account_name>\w.*?)\s*?
            Account Domain:\s*?(?<account_domain>\w.*?)\s*?
            Logon ID:\s*?(?<logon_id>0x\d.*?)\s'
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

# msobjs.dll encoding translations
$msobj_hash = @{"%%1832" = "Identification"; "%%1833" = "Impersonation";
                "%%1840" = "Delegation"; "%%1841" = "Denied by Process Trust Label ACE";
                "%%1842" = "Yes"; "%%1843" = "No"; "%%1844" = "System";
                "%%1845" = "Not Available"; "%%1846" = "Default";
                "%%1847" = "DisallowMmConfig"; "%%1848" = "Off"; "%%1849" = "Auto"
}

$event = Import-Csv .\log.csv
$logon_obj = Parse-LogonObject -Logon $event
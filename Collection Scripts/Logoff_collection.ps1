# Performs the parse and enrichment of the logoff events
Function Parse-LogoffObject {
    Param(
        $Logoff, # The logoff event object that needs to be parsed and enriched
        $interactive # A Boolean value that indicates whether the logoff was an interactive logoff (true) or not (false)
    )

    # Initialize a hash table with the time and hostname properties from the logoff object
    $vals = @{time = $Logoff.TimeGenerated; hostname = $Logoff.MachineName}

    # Extract the logoff message from the logoff object
    $message = $Logoff.Message

    # Define a regular expression to extract specific fields from the logoff message
    $reg = '(?s)Security ID:\s*?(?<sid>S.*?)\s.*?Account Name:\s*?(?<account_name>\w.*?)\s*?Account Domain:\s*?(?<account_domain>\w.*?)\s*?Logon ID:\s*?(?<logon_id>0x\S.*?)\s'

    # Use the regular expression to extract the fields from the logoff message and store them in $Matches
    $val = $message -match $reg

    # Convert the logon ID to a 32-bit unsigned integer and remove the first element of $Matches
    $Matches.logon_id = [uint32]$Matches.logon_id
    $Matches.remove(0)

    # Add the remaining fields from $Matches to $vals
    $vals += $Matches

    # If $interactive is false, extract the logon type from the logoff message using another regular expression
    if ($interactive -eq $false) {
        $reg = 'Logon Type:\s*?(?<logon_type>\d+)'
        $val = $message -match $reg
        $Matches.remove(0)
        $vals += $Matches
    }

    # Create a PowerShell object with the properties in $vals and return it
    $logon_object = New-Object PSObject -Property $vals
    $logon_object
}

# Logoff Event IDs: 4647, 4634

# Retrieve all non-interactive logoff events from the Security event log with event ID 4634
$logoffs_noninteractive = Get-EventLog -LogName Security -InstanceId 4634

# Retrieve all interactive logoff events from the Security event log with event ID 4647
$logoffs_interactive = Get-EventLog -LogName Security -InstanceId 4647

# Initialize a list to store the parsed logoff events
$logoff_list = @()

# Parse each non-interactive logoff event and add it to $logoff_list
foreach ($event in $logoffs_noninteractive){
    $logoff_event = Parse-LogoffObject -Logoff $event -interactive $false
    $logoff_list += $logoff_event
}

# Parse each interactive logoff event and add it to $logoff_list
foreach ($event in $logoffs_interactive){
    $logoff_event = Parse-LogoffObject -Logoff $event -interactive $true
    $logoff_list += $logoff_event
}

# Convert $logoff_list to a CSV-formatted string without type information and save it to a file named "logoffs.csv"
$logoff_list | ConvertTo-Csv -NoTypeInformation | Set-Content -path '.\logoffs.csv'

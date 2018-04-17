<#

Title: fillGroupBasedOnGroupMembership
Dato: 15.04.2018
Auth: wad
This script will fill a designated group based on membership in another group.

#>

#---Variables---#
$eventLogSource = "fillGroupBasedOnGroupMembership"
$eventLogExist = Get-EventLog -LogName Application -Source $eventLogSource | where {$_.EventID -eq 890}

$groups = Get-ADGroup -filter * -SearchBase "OU=Usergroups,DC=contoso,DC=com" -server contoso | where {$_.name -like "<insert groupname of source>"}
$members = Get-ADGroupMember $groups -server contoso

$newMember = 0

#---The script writes to the eventlog that it has started. If no source exsist the script generates one---#
if ($eventLogExist) {
        Write-EventLog -LogName Application -Source $eventLogSource -EntryType Information -EventId 890 -Message "INFORMATION: $eventLogSource script have started."
    } else {
        New-EventLog -LogName Application -Source $eventLogSource
        Write-EventLog -LogName Application -Source $eventLogSource -EntryType Warning -EventId 891 -Message "$eventLogSource script have started and generated a new source in the application event log"
    }

#---SCRIPT---#
foreach($group in $groups)
{

    foreach ($member in $members)
    {
        $newMember++
        $username = $member.samaccountname 
        Add-ADGroupMember "<insert group destination>" $username -server contoso
    }


}

#When the script finishes it writes the completed status to the eventlog.
if ($newMember -gt 0) {
    Write-EventLog -LogName Application -Source $eventLogSource -EntryType Information -EventId 892 -Message "INFORMATION: $eventLogSource script have finished and $newMember new members is added to <insert destination group name>."
} else {
    Write-EventLog -LogName Application -Source $eventLogSource -EntryType Information -EventId 893 -Message "INFORMATION: $eventLogSource script have finished. No changes detected"
}


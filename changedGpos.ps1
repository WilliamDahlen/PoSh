cls
<#

Title: Changed GPO script (forked)
Date: 17.01.2018
Auth: wad
Script changes in gpos the last 24 hours.

#>

#---Variables---#
$eventLogExist = Get-EventLog -LogName Application -Source "changedGpos" | where {$_.EventID -eq 690}
$numberOfDaysBack = -1
$checkdate = (Get-Date).AddDays($AntallDagerTilbake)
$domain1 = 'contoso.microsoft.com'
$domain2 = 'adatum.microsoft.com'
$changedGpoDomain1 = Get-GPO -all -Domain $domain1 -Verbose | Where-Object {$_.ModificationTime -gt $checkdate} #This is searching for all GPOS defined for that domain.
$changedGpoDomain2 = Get-GPO -all -Domain $domain2 -Verbose | Where-Object {$_.DisplayName -like '*insert search param here*'} | Where-Object {$_.ModificationTime -gt $checkdate} #This is searching for GPOS with spesific names.

$smtpFrom = "ChangedGPOs@adatum.microsoft.com"
$smtpTo = "admin@adatum.microsoft.com"
$smtpServer = "mail.adatum.com"
$messageSubject = "GPOs changed last $numberOfDaysBack days."

$message = New-Object System.Net.Mail.MailMessage $smtpfrom, $smtpto
$message.Subject = $messageSubject
$message.IsBodyHTML = $true
    
$MessageBody = "GPOs changed last $numberOfDaysBack days." 
$MessageBody = "$MessageBody `n ------------- `n  If this mail is empty, please dismiss this message. `n "
$MessageBody = "$MessageBody If not, do this. "
$MessageBody = "$MessageBody `n ------------- `n"

$msgDomain1 = "$messageSubject in domain $domain1"
$msgDomain2 = "$messageSubject in domain $domain2"

$NumberOfChangedGpos = 0

#---The script writes to the event log that it has started. If no source is detected in the log, a new one is generated---#
if ($eventLogExist) {
    Write-EventLog -LogName Application -Source "changedGpos" -EntryType Information -EventId 690 -Message "INFORMATION: changedGpos script have started."
    } else {
    New-EventLog -LogName Application -Source "changedGpos"
    Write-EventLog -LogName Application -Source -Message "changedGpos script have started and generated a new source in the application event log"
    }

foreach ($gpo in $changedGpoDomain1) {
    $NumberOfChangedGpos++
	$MessageBody = "$MessageBody `n "
	$MessageBody = "$MessageBody GPO :  $($gpo.DisplayName) `n "
	$MessageBody = "$MessageBody Mod :  $($gpo.ModificationTime) `n "
	$MessageBody = "$MessageBody Own :  $($gpo.Owner) `n "
}

if ($NumberOfChangedGpos -gt 0) {
    $MessageBody
	Send-MailMessage -To $smtpTo -From $smtpFrom -Subject $msgDomain1 -Body $MessageBody -SmtpServer $SmtpServer
    Write-EventLog -LogName Application -Source "changedGpos" -EntryType Information -EventId 691 -Message "changedGpos have detected changes in $domain1. See e-mail warning"
    $NumberOfChangedGpos = 0
}

foreach ($gpo in $changedGpoDomain2) {
    $NumberOfChangedGpos++
	$MessageBody = "$MessageBody `n "
	$MessageBody = "$MessageBody GPO :  $($gpo.DisplayName) `n "
	$MessageBody = "$MessageBody Mod :  $($gpo.ModificationTime) `n "
	$MessageBody = "$MessageBody Own :  $($gpo.Owner) `n "
}

if ($NumberOfChangedGpos -gt 0) {
    $MessageBody
	Send-MailMessage -To $smtpTo -From $smtpFrom -Subject $msgDomain2 -Body $MessageBody -SmtpServer $SmtpServer
    Write-EventLog -LogName Application -Source "changedGpos" -EntryType Information -EventId 692 -Message "changedGpo have detected changes in $domain2. See e-mail warning"
}

#---When the script have finished it writes the completed status to the eventlog---#
if ($NumberOfChangedGpos -gt 0) {
    Write-EventLog -LogName Application -Source "changedGpos" -EntryType Information -EventId 695 -Message "INFORMATION: changedGpos script have finished and detected changes in the registered GPOs"
} else {
    Write-EventLog -LogName Application -Source "changedGpos" -EntryType Information -EventId 696 -Message "INFORMATION: changedGpos script have finished. No changes detected"
}

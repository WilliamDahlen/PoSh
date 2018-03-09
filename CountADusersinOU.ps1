<#

Title: Count users in specific OU
Dato: 01.01.2017
Auth: WAD

#>

$OU="OU=Users,DC=adatum,DC=com" #change this with your own string.

(Get-ADUser -Filter * -SearchBase $OU).count

$users = ForEach ($user in $(Get-Content sourceFile.txt)) {

    
    Get-AdUser $user -Server contoso.com -Properties displayName,cn
}
    
 $users |
 Select-Object displayName,cn |
 Export-CSV -Path outFile.csv -NoTypeInformation
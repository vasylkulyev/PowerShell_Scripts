$Users = Get-ADUser -Filter * -SearchBase "OU=fired,DC=test,DC=local" -Properties MemberOf
$Users | Foreach-Object {
    $Groups = $_.MemberOf
    foreach ($Group in $Groups) {
        Remove-ADGroupMember $Group -Member $_ -Confirm:$False
    }
}
ForEach ($User in $Users)
{
Disable-ADAccount -Identity $User
}

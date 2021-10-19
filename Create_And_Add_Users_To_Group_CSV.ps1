Import-Module ActiveDirectory
$ADUsers = Import-csv "\\path\to\public\list_of_users.csv"

foreach ($User in $ADUsers)
{

       $Username    = $User.firstname +' '+ $User.lastname
       $Groups      = $User.group
       $Accname     = $User.accname

       #Check if the user account already exists in AD
       if (Get-ADUser -F {SamAccountName -eq $Accname})
       {
               #If user does exist, output a warning message
               Write-Warning "A user account $Username has already exist in Active Directory."
       }
       else
       {
           #If a user does not exist then create a new user account
           #Account will be created in the OU listed in the $OU variable in the CSV file;
           $userProps = @{
               SamAccountName = $User.accname
               UserPrincipalName = '{0}@domain.com' -f $User.accname
               Name = '{0} {1}' -f $User.firstname, $User.lastname
               GivenName = $User.firstname
               Surname = $User.lastname
               Enabled = $true
               ChangePasswordAtLogon = $true
               DisplayName = '{0} {1}' -f $User.firstname, $User.lastname
               Path = $User.ou
               AccountPassword = (ConvertTo-SecureString $User.password -AsPlainText -Force)
           }
           New-ADUser @userProps
           $ExistingGroups = Get-ADPrincipalGroupMembership $User.accname | Select-Object Name
           foreach ($Group in $Groups.Split(',')) {
               if ($ExistingGroups.Name -eq $Group) {
                   Write-Host "$Username already exists in group $Group" -ForeGroundColor Yellow
               }
               else { 
                   Add-ADGroupMember -Identity $Group -Members $User.accname
                   Write-Host "Added $Username to $Group"
               }
           }
       }
}

$allusers = Get-ADUser -Filter * -SearchBase "OU=ITS,OU=Doon,OU=CC,DC=cctestcloud,DC=local"
ForEach ($user in $allusers)
{
    $sAMAccountame = $user.SamAccountName
    Rename-ADObject -Identity $user -NewName $sAMAccountame
}

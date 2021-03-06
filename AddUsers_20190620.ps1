# AddUsers
# Created by Jeffrey C. Rombough for Conestoga College
# Version:2019:03:14
#
# Global Variables 

$path = $args

$a = Get-Date
$Logfile = "$args.UserImport_" + $a.Year + "" + $a.Month + "" + $a.Day + "" + $a.Hour + "" + $a.Minute +".log"
#$ADSSPdump = "$args.ADSSPdump_" + $a.Year + "" + $a.Month + "" + $a.Day + "" + $a.Hour + "" + $a.Minute +".csv"
$Brantforddump = "$args.Brantford_" + $a.Year + "" + $a.Month + "" + $a.Day + "" + $a.Hour + "" + $a.Minute +".log"
$AzureLicense = "$args.AzureLicense.log"
$O365License = "$args.O365License.log"

Write-host "Log file will be written to $Logfile"

Out-File -FilePath $Logfile 
#Out-File -FilePath $ADSSPdump
Out-File -FilePath $Brantforddump
Out-File -FilePath $AzureLicense
Out-File -FilePath $O365License

$InputArray = Get-Content -path $path
Write-Output "[LOG] User Import Log $LogFile" | Out-File $Logfile -append 
Write-Output "[LOG] Reading: $path" | Out-File $Logfile -append 

#################################################################################################
# Reads in the formated text (usually a all1.dat file) and parses it into ADSI attributes
#################################################################################################

foreach ($i in $InputArray)
{
# This access to this element of the array is by $i

Write-output "#######################################################################################################################################################"


$FullyQualifiedNovellName  = $i.split(",")[0]
$LastName = $i.split(",")[1]
$FirstName = $i.split(",")[2]
$FullName = $i.split(",")[3]
$Location = $i.split(",")[4]
$Course = $i.split(",")[5]
$Pwd = $i.split(",")[6]
$EA = $i.split(",")[9]


#################################################################################################
# Conditional statements to translate home directory 
#################################################################################################

$FQNN =  $FullyQualifiedNovellName.split(".")[0]

$HomeDir = ""

$SplitTemp = $i.split(",")[7]
$HomeDir = $SplitTemp

##################################################################################################



##################################################################################################
# Conditional statement to translate quota group
##################################################################################################
# Need to only get the number amount.
$QuotaGroup = ""
$SplitTemp1 = $i.split(",")[8]
$QuotaGroup = $SplitTemp1 

##################################################################################################
# Initiallize  Initials field
##################################################################################################
$UserInitials = $i.split(",")[10] -replace '',' '



##################################################################################################
# Initiallize Mapped Employee ID field
##################################################################################################
$UserEmployeeID = $i.split(",")[11] 



##################################################################################################
# Determine which OU to add the user to
##################################################################################################

$ContainerName = $FullyQualifiedNovellName.split(".")[2]
$UserType = $FullyQualifiedNovellName.split(".")[1]

$objADSI = [ADSI]"LDAP://ou=$UserType,ou=$ContainerName,ou=CC,dc=conestogac,dc=on,dc=ca"

##################################################################################################
# Determine Account Type Flags 
##################################################################################################
# Assume 0 = false , 1 = true
# initialize variables
$StudentFlag = "0"
$FacultyFlag = "0"
$SupportStaff = "0"
$ITStaff = "0"
$AdminStaff = "0"

# Get values from csv file

$StudentFlag = $i.split(",")[12]
$FacultyFlag = $i.split(",")[13]
$SupportStaff = $i.split(",")[14]
$ITStaff = $i.split(",")[15]
$AdminStaff = $i.split(",")[16]
$FullTime = $i.split(",")[17]
#Assume Fulltime = true == 1
$DoB = $i.Split(",")[18]
$DisplayName = $i.split(",")[19]
$D2LLogin = $i.split(",")[20]
#Added 20190619

$Manager2 = $i.split(",")[21]
$Manager = $Manager2 -replace '\^',','
##################################################################################################
# Append to ADSPP_Dump file
##################################################################################################

$StudentNumber = $Pwd.Substring(2)

#if ($StudentFlag -eq "1"){
#Write-Output "$FQNN,What is your student number?,$StudentNumber" | Out-File $ADSSPdump -append -encoding ASCII
#}
#if ($StudentFlag -ne "1"){
#Write-Output "$FQNN,What is your employee number?,$StudentNumber" | Out-File $ADSSPdump -append  -encoding ASCII
#}
#
#Write-Output "$FQNN,What is your date of birth? (YYYY-MM-DD),$DoB" | Out-File $ADSSPdump -append  -encoding ASCII

##################################################################################################
# Create User object with defined fields.
##################################################################################################

$objUser = $objADSI.create("User","CN=" + $FQNN)
#$objUser = $objADSI.create("user","CN=" + $FirstName + " " + $LastName)
$objUser.put("SamaccountName", $FQNN)
$objUser.put("userPrincipalName", $FQNN + "@conestogac.on.ca")
$objUser.put("givenName",$FirstName)
$objUser.put("sn", $LastName)
$objUser.put("DisplayName", $FullName)
$objUser.put("description", $Course)
$objUser.put("physicalDeliveryOfficeName",$Location)
$objUser.put("mail",$EA)
$objUser.put("HomeDrive","G:")
$objUser.put("homeDirectory",$HomeDir)
$objUser.put("department", $Course)
$objUser.put("company", $Location)
$objUser.put("initials", $UserInitials)
$objUser.put("employeeID",$UserEmployeeID)
$objUser.put("displayName",$DisplayName)
$objUser.put("extensionAttribute2",$D2LLogin)
if (!([string]::IsNullOrWhiteSpace($Manager))){$objUser.put("manager",$Manager)}

######################################################################################################
#Flag to determine part time or full time
######################################################################################################


if ($StudentFlag -eq "1"){
$objUser.put("extensionAttribute4","Stu")
}
if ($StudentFlag -ne "1"){
$objUser.put("extensionAttribute3","FacStaff")
}

if ($Fulltime -eq "1"){
$objUser.put("extensionAttribute1","1")

}
if ($Fulltime -eq "0"){
$objUser.put("extensionAttribute1","0")
}


try {
$objUser.setInfo()
Write-Output "[Action] User created." | Out-File $Logfile -append 
    }
Catch {

Write-Output "[Error] $FullName ::$FQNN already exists or something gots broken!!!" | Out-File $Logfile -append

}

### This is where the exception will be thrown
### Using the continue command may force the next loop to start and this one be abandoned. 
### This will also mean that the home directory will not be checked or changed.
### Exceptions will probably be 1. Object Already exists and 2. samAccount name is too long. 
### So the exception will through these errors to the log and continue with the next user. 

## normal user that requires password & is enabled
$objUser.put("department", $Course)

#Changed because we need to initially set the password once and then reset it again for live@edu.

 
if ($StudentFlag -eq "1"){ 
##$Pwd = "Cc123456"
#http://jdhitsolutions.com/blog/2011/12/updating-multi-valued-active-directory-properties-part-1/
$objUser.putex(3,"proxyAddresses",@("smtp:$FQNN@stu.conestogac.on.ca"))
Write-Output $FQNN | Out-File $O365License -append
}

if ($StudentFlag -eq "0"){ 
Write-Output $FQNN | Out-File $AzureLicense -append
}


$objUser.SetPassword($Pwd.ToString())
#$objUser.SetPassword("Cc123456")
$objUser.setInfo()

Write-Output "[Action] Password Set." | Out-File $Logfile -append 


#Remove the next two lines if the accounts must have their passwords reset 
$objuser.userAccountControl="512"
$objUser.setInfo()

Write-Output "[Action] Setting password $PWD. User does NOT have to change password upon first logon."  | Out-File $Logfile -append 
Write-Output "[Action] $FullyQualifiedNovellName Created." | Out-File $Logfile -append 

Start-Sleep -Seconds 5
 if ($ContainerName -eq "brantford") 
       {
Write-Output "$StudentNumber,$LastName,$FirstName,$FQNN@conestogac.on.ca" | Out-File $Brantforddump -append 
}
################################################################################################################################################################################################

if ($FacultyFlag -eq "1") 
    { 
        if ($ContainerName -eq "doon") 
        {
        ##################################################################################################
        #Adds User to the Doon All Faculty Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://cn=Doon All Faculty,ou=FAC,ou=Doon,ou=CC,dc=conestogac,dc=on,dc=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to Doon All Faculty group"  | Out-File $Logfile -append 
        ##################################################################################################
        
        ##################################################################################################
        #Adds User to the Doon All Employee Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://cn=Doon_All_Employees,ou=Domain Groups,dc=conestogac,dc=on,dc=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to Doon All Employee group"  | Out-File $Logfile -append 
        ##################################################################################################       
        
        }
       
        
        if ($ContainerName -eq "ingersoll") 
        {
        ##################################################################################################
        #Adds User to the Ingersoll All Faculty Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://cn=Ingersoll All Faculty,ou=FAC,ou=Ingersoll,ou=CC,dc=conestogac,dc=on,dc=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to Ingersoll All Faculty group"  | Out-File $Logfile -append 
        ##################################################################################################
       
        ##################################################################################################
        #Adds User to the Ingersoll All Employee Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://CN=Ingersoll_All_Employees,OU=INGERSOLL,OU=CC,DC=conestogac,DC=on,DC=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to Ingersoll All Employee group"  | Out-File $Logfile -append 
        ##################################################################################################
       
        }

        if ($ContainerName -eq "wloo") 
        {
        ##################################################################################################
        #Adds User to the Waterloo All Faculty Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://cn=Waterloo All Faculty,ou=FAC,ou=WLOO,ou=CC,dc=conestogac,dc=on,dc=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to Waterloo All Faculty group"  | Out-File $Logfile -append 
        ##################################################################################################
        
        ##################################################################################################
        #Adds User to the Waterloo All Employee Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://CN=Waterloo_All_Employees,OU=WLOO,OU=CC,DC=conestogac,DC=on,DC=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to Waterloo All Employee group"  | Out-File $Logfile -append 
        ##################################################################################################
        
        
        }
        
        if ($ContainerName -eq "stratford") 
        {
        ##################################################################################################
        #Adds User to the Stratford All Faculty Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://cn=Stratford All Faculty,ou=Doon,ou=CC,dc=conestogac,dc=on,dc=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to Stratford All Faculty group"  | Out-File $Logfile -append 
        ##################################################################################################
        
        ##################################################################################################
        #Adds User to the Stratford All Employee Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://CN=Stratford_All_Employees,OU=STRATFORD,OU=CC,DC=conestogac,DC=on,DC=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to Stratford All Employee group"  | Out-File $Logfile -append 
        ##################################################################################################
        
        }

        if ($ContainerName -eq "cambridge") 
        {
        ##################################################################################################
        #Adds User to the Cambridge All Faculty Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://cn=Cambridge Faculty,ou=FAC,ou=Cambridge,ou=CC,dc=conestogac,dc=on,dc=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to Cambridge Faculty group"  | Out-File $Logfile -append 
        ##################################################################################################
        
        ##################################################################################################
        #Adds User to the Cambridge All Employee Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://CN=Cambridge_All_Employees,OU=CAMBRIDGE,OU=CC,DC=conestogac,DC=on,DC=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to Cambridge Employee group"  | Out-File $Logfile -append 
        ##################################################################################################
        
        }
        
        if ($ContainerName -eq "guelph") 
        {
        ##################################################################################################
        #Adds User to the Guelph All Faculty Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://cn=Guelph All Faculty,ou=FAC,ou=Guelph,ou=CC,dc=conestogac,dc=on,dc=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to Stratford All Faculty group"  | Out-File $Logfile -append 
        ##################################################################################################
        
        ##################################################################################################
        #Adds User to the Guelph All Employee Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://CN=Guelph_All_Employees,OU=GUELPH,OU=CC,DC=conestogac,DC=on,DC=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to Guelph All Employee group"  | Out-File $Logfile -append 
        ##################################################################################################
        
        }

        if ($ContainerName -eq "brantford") 
        {
        ##################################################################################################
        #Adds User to the Guelph All Faculty Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://cn=Brantford All Faculty,ou=FAC,ou=Brantford,ou=CC,dc=conestogac,dc=on,dc=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to Brantford All Faculty group"  | Out-File $Logfile -append 
        ##################################################################################################
        
        ##################################################################################################
        #Adds User to the Guelph All Employee Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://CN=Brantford_All_Employees,OU=Brantford,OU=CC,DC=conestogac,DC=on,DC=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to Brantford All Employee group"  | Out-File $Logfile -append 
        ##################################################################################################
        
        }

        ##################################################################################################
        #Adds User to the All Faculty Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://cn=All Faculty,ou=Domain Groups,dc=conestogac,dc=on,dc=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to All Faculty group"  | Out-File $Logfile -append 
        ##################################################################################################
        
        ##################################################################################################
        #Adds User to the Faculty_Scratch_Quota_1G Group
        ##################################################################################################
        #$SGroup = [ADSI]"LDAP://cn=Faculty_Scratch_Quota_1G,ou=Domain Groups,dc=conestogac,dc=on,dc=ca"
        #$SGroup.Add($objUser.path)
        #$SGroup.setinfo()
        #Start-Sleep -Seconds 5
        #Write-Output "[Action] Adding User to Faculty_Scratch_Quota_1G group"  | Out-File $Logfile -append 
        ##################################################################################################

}


if ($SupportStaff -eq "1") 
    { 
        if ($ContainerName -eq "doon") 
        {
        ##################################################################################################
        #Adds User to the Doon All Faculty Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://cn=Doon Support Staff,ou=SUP,ou=Doon,ou=CC,dc=conestogac,dc=on,dc=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to Doon Support Staff group"  | Out-File $Logfile -append 
        ##################################################################################################
        
        ##################################################################################################
        #Adds User to the Doon All Employee Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://cn=Doon_All_Employees,ou=Domain Groups,dc=conestogac,dc=on,dc=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to Doon All Employee group"  | Out-File $Logfile -append 
        ##################################################################################################  
        
        }
        
        if ($ContainerName -eq "ingersoll") 
        {
        ##################################################################################################
        #Adds User to the Ingersoll All Faculty Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://cn=Ingersoll Support Staff,ou=SUP,ou=Ingersoll,ou=CC,dc=conestogac,dc=on,dc=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to Ingersoll All Faculty group"  | Out-File $Logfile -append 
        ##################################################################################################
        
        ##################################################################################################
        #Adds User to the Ingersoll All Employee Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://CN=Ingersoll_All_Employees,OU=INGERSOLL,OU=CC,DC=conestogac,DC=on,DC=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to Ingersoll All Employee group"  | Out-File $Logfile -append 
        ##################################################################################################
               
        
        
        }

        if ($ContainerName -eq "wloo") 
        {
        ##################################################################################################
        #Adds User to the Waterloo All Faculty Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://cn=Waterloo Support Staff,ou=SUP,ou=WLOO,ou=CC,dc=conestogac,dc=on,dc=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to Waterloo Support Staff group"  | Out-File $Logfile -append 
        ##################################################################################################
        
        ##################################################################################################
        #Adds User to the Waterloo All Employee Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://CN=Waterloo_All_Employees,OU=WLOO,OU=CC,DC=conestogac,DC=on,DC=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to Waterloo All Employee group"  | Out-File $Logfile -append 
        ##################################################################################################
        }
        
        if ($ContainerName -eq "stratford") 
        {
        ##################################################################################################
        #Adds User to the Stratford Support Staff Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://cn=Stratford Support Staff,ou=SUP,ou=Stratford,ou=CC,dc=conestogac,dc=on,dc=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to Stratford Support Staff group"  | Out-File $Logfile -append 
        ##################################################################################################
        
        ##################################################################################################
        #Adds User to the Stratford All Employee Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://CN=Stratford_All_Employees,OU=STRATFORD,OU=CC,DC=conestogac,DC=on,DC=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to Stratford All Employee group"  | Out-File $Logfile -append 
        ##################################################################################################
        
        }

        if ($ContainerName -eq "cambridge") 
        {
        ##################################################################################################
        #Adds User to the Cambridge All Faculty Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://cn=Cambridge Support Staff,ou=SUP,ou=Cambridge,ou=CC,dc=conestogac,dc=on,dc=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to Cambridge Support Staff group"  | Out-File $Logfile -append 
        ##################################################################################################
        
        ##################################################################################################
        #Adds User to the Cambridge All Employee Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://CN=Cambridge_All_Employees,OU=CAMBRIDGE,OU=CC,DC=conestogac,DC=on,DC=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to Cambridge Employee group"  | Out-File $Logfile -append 
        ##################################################################################################
        
        }
        
        if ($ContainerName -eq "guelph") 
        {
        ##################################################################################################
        #Adds User to the Guelph Support Staff Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://cn=Guelph Support Staff,ou=SUP,ou=Guelph,ou=CC,dc=conestogac,dc=on,dc=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to Guelph Support Staff group"  | Out-File $Logfile -append 
        ##################################################################################################
        
        ##################################################################################################
        #Adds User to the Guelph All Employee Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://CN=Guelph_All_Employees,OU=GUELPH,OU=CC,DC=conestogac,DC=on,DC=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to Stratford All Employee group"  | Out-File $Logfile -append 
        ##################################################################################################
        }

        if ($ContainerName -eq "brantford") 
        {
        ##################################################################################################
        #Adds User to the Brantford Support Staff Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://cn=Brantford Support Staff,ou=SUP,ou=Brantford,ou=CC,dc=conestogac,dc=on,dc=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to Brantford Support Staff group"  | Out-File $Logfile -append 
        ##################################################################################################
        
        ##################################################################################################
        #Adds User to the Brantford All Employee Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://CN=Brantford_All_Employees,ou=Domain Groups,dc=conestogac,dc=on,dc=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to Brantford All Employee group"  | Out-File $Logfile -append 
        ##################################################################################################
        }


        ##################################################################################################
        #Adds User to the All Support Staff Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://cn=All Support Staff,ou=Domain Groups,dc=conestogac,dc=on,dc=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to All Support Staff group"  | Out-File $Logfile -append 
        ##################################################################################################

}

if ($AdminStaff -eq "1") 
    { 
        if ($ContainerName -eq "doon") 
        {
        ##################################################################################################
        #Adds User to the Doon Admin Staff Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://cn=Doon Admin Staff,ou=SUP,ou=Doon,ou=CC,dc=conestogac,dc=on,dc=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to Doon Admin Staff group"  | Out-File $Logfile -append 
        ##################################################################################################
        
        ##################################################################################################
        #Adds User to the Doon All Employee Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://cn=Doon_All_Employees,ou=Domain Groups,dc=conestogac,dc=on,dc=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to Doon All Employee group"  | Out-File $Logfile -append 
        ##################################################################################################  
        
        }
        
        if ($ContainerName -eq "guelph") 
        {
        ##################################################################################################
        #Adds User to the Guelph Support Staff Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://cn=Admin,ou=SUP,ou=Guelph,ou=CC,dc=conestogac,dc=on,dc=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to Guelph Admin group"  | Out-File $Logfile -append 
        ##################################################################################################
        
        ##################################################################################################
        #Adds User to the Guelph All Employee Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://CN=Guelph_All_Employees,OU=GUELPH,OU=CC,DC=conestogac,DC=on,DC=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to Stratford All Employee group"  | Out-File $Logfile -append 
        ##################################################################################################
        
        }

        ##################################################################################################
        #Adds User to the All Support Staff Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://cn=All Support Staff,ou=Domain Groups,dc=conestogac,dc=on,dc=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to All Support Staff group"  | Out-File $Logfile -append 
        ##################################################################################################


        ##################################################################################################
        #Adds User to the All Support Staff Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://cn=All Admin Staff,ou=SUP,ou=Doon,ou=CC,dc=conestogac,dc=on,dc=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to All Support Staff group"  | Out-File $Logfile -append 
        ##################################################################################################
                
}

if ($StudentFlag -eq "1") 
    {
        if ($ContainerName -eq "doon")  
        {        
        ##################################################################################################
        #Adds User to the Doon All Student Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://cn=Doon All Students,ou=STU,ou=Doon,ou=CC,dc=conestogac,dc=on,dc=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to Doon All Student group"  | Out-File $Logfile -append 
        ##################################################################################################
        }

        if ($ContainerName -eq "guelph")  
        {        
        ##################################################################################################
        #Adds User to the Guelph All Student Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://cn=Guelph All Students,ou=STU,ou=Guelph,ou=CC,dc=conestogac,dc=on,dc=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to Guelph All Student group"  | Out-File $Logfile -append 
        ##################################################################################################
        }

        if ($ContainerName -eq "wloo")  
        {        
        ##################################################################################################
        #Adds User to the Waterloo All Student Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://cn=Waterloo All Students,ou=STU,ou=WLOO,ou=CC,dc=conestogac,dc=on,dc=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to Waterloo All Student group"  | Out-File $Logfile -append 
        ##################################################################################################
        }

        if ($ContainerName -eq "stratford")  
        {        
        ##################################################################################################
        #Adds User to the Stratford All Student Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://cn=Stratford All Students,ou=STU,ou=stratford,ou=CC,dc=conestogac,dc=on,dc=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to Stratford All Student group"  | Out-File $Logfile -append 
        ##################################################################################################
        }

        if ($ContainerName -eq "cambridge")  
        {        
        ##################################################################################################
        #Adds User to the Cambridge All Student Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://cn=Cambridge All Students,ou=STU,ou=cambridge,ou=CC,dc=conestogac,dc=on,dc=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to Cambridge All Student group"  | Out-File $Logfile -append 
        ##################################################################################################
        }

 if ($ContainerName -eq "brantford")  
        {        
        ##################################################################################################
        #Adds User to the Brantford All Student Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://cn=Brantford All Students,ou=STU,ou=Brantford,ou=CC,dc=conestogac,dc=on,dc=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to Brantford All Student group"  | Out-File $Logfile -append 
        ##################################################################################################
        }

        ##################################################################################################
        #Adds USer to the All Students Group
        ##################################################################################################
        $SGroup = [ADSI]"LDAP://cn=All Students,ou=Domain Groups,dc=conestogac,dc=on,dc=ca"
        $SGroup.Add($objUser.path)
        $SGroup.setinfo()
        Start-Sleep -Seconds 5
        Write-Output "[Action] Adding User to all students group"  | Out-File $Logfile -append 
        ##################################################################################################
}



##################################################################################################
#Adds USer to their quota groups
##################################################################################################
$QGroup = [ADSI]"LDAP://cn=$QuotaGroup,ou=Domain Groups,dc=conestogac,dc=on,dc=ca"
$QGroup.Add($objUser.path)
$QGroup.setinfo()
Start-Sleep -Seconds 5
Write-Output "[Action] Adding User to their quota group"  | Out-File $Logfile -append 
##################################################################################################




################################################################################################################################################################################################
#The homedirectory portion of this script should be multithreaded. 
#If necessary the processed referenced at URL 
#
#PowerShell Multithreading – OMG!!
#http://blog.isaacblum.com/2010/01/22/powershell-multithreading-omg/  
#
# could be used in a pinch


################################################################################################################################################################################################
$directory = $homedir
Write-Output "[HomeDir] Found home directory $directory for $FQNN" | Out-File $Logfile -append   

New-Item $directory -type directory

$inherit = [System.Security.Accesscontrol.InheritanceFlags]"ContainerInherit, ObjectInherit"
$propagation = [System.Security.Accesscontrol.PropagationFlags]"None"   

$username = "conestogac\" + $FQNN
$acl = Get-Acl $directory
   
 
$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($username, "Modify", $inherit, $propagation, "Allow")

try {
$acl.AddAccessRule($accessrule)
   }
   
   catch
   {
   Write-Output "[ERROR] User has not 'gotten' to the Domain Controller Yet: Waiting 30 Seconds before attempting again."  | Out-File $Logfile -append 
   Start-Sleep -Seconds 30
   
        try {
        $acl.AddAccessRule($accessrule)
        }
        catch
            {
                Write-Output "[ERROR] Users has not been given permission to their home directory"  | Out-File $Logfile -append 
            } 
   }
   Write-Output "[HomeDir] Adding user permissions for $directory" | Out-File $Logfile -append 

$UsersO = New-Object System.Security.Principal.NTAccount($username)
  
$acl.SetOwner($UsersO)  


Set-Acl -aclobject $acl $directory

Write-Output "[HomeDir] Set $FQNN as the Owner for directory $directory"  | Out-File $Logfile -append 
Write-Output "..............................XXXXX......................"
Write-Output "......................XXXXXXXXX...X................XXX..."
Write-Output ".....XXXXXXXXXXXXXXXXXXXXX.........XXXXXXXXX.....XX..X..."
Write-Output "...XX.......................................XXXXX...X...."
Write-Output "..X.....{O}.......X...XX...........................X....."
Write-Output "..X................XX...X..........................X....."
Write-Output "..X..___/...........XXXXXX...........XXXXXXX.......X....."
Write-Output "...XX...........................XXXXXX.......XXXX...X...."
Write-Output ".....XXXXXXXXXXXXXXXXXXXXXXXXXXX.................XX..X..."
Write-Output "...................................................XXX..."


Start-Sleep -Seconds 2

$UserPrincipalName = $FQNN

#Create Live@EDU account
if ($StudentFlag -eq "1") 
{
    $primdomain = "@conestogac.on.ca"
    $extdomain = "@stu.conestogac.on.ca"

    Try
    {
        Enable-RemoteMailBox -Identity $UserPrincipalName -primarySmtpAddress ($UserPrincipalName + $primdomain) -RemoteRoutingAddress ($UserPrincipalName + $extdomain)
        Set-ADUser $UserPrincipalName -Add @{ProxyAddresses="smtp:" + $UserPrincipalName + $extdomain}
        Set-ADUser $UserPrincipalName -Add @{ProxyAddresses="SMTP:" + $UserPrincipalName + $primdomain}
    }
    Catch
    {
        Write-Output "[E-mail] Something done got broken when making $UserPrincipalName"  | Out-File $Logfile -append 
    }
}

if ($StudentFlag -eq "0") 
{
    $primdomain = "@conestogac.on.ca"
    $extdomain = "@stuconestogacon.mail.onmicrosoft.com"

    Try
    {
        Enable-RemoteMailBox -Identity $UserPrincipalName -primarySmtpAddress ($UserPrincipalName + $primdomain) -RemoteRoutingAddress ($UserPrincipalName + $extdomain)
        Set-ADUser $UserPrincipalName -Add @{ProxyAddresses="smtp:" + $UserPrincipalName + $extdomain}
        Set-ADUser $UserPrincipalName -Add @{ProxyAddresses="SMTP:" + $UserPrincipalName + $primdomain}
    }
    Catch
    {
        Write-Output "[E-mail] Something done got broken when making $UserPrincipalName"  | Out-File $Logfile -append 
    }
}

Write-Output "[E-mail] User $UserPrincipalName has been assigned the e-mail address $UserPrincipalName$primdomain for Office 365"  | Out-File $Logfile -append 

# may have to add addtional e-mail addresses. Use the process as per http://www.mikepfeiffer.net/2010/04/quickly-add-an-email-address-to-an-exchange-mailbox-using-powershell/

Write-Output "[End Of Record]"  | Out-File $Logfile -append 
#
}

Write-Output "[EOF]"  | Out-File $Logfile -append 
invoke-command -ComputerName ADDC01D -ScriptBlock{(Start-ADSyncSyncCycle Delta)}

#Wait 10 minutes
#Do Employee license
#Do Student license

#Make Directory
Import-Module PKI

New-Item -ItemType Directory C:\RomboReports



# Get the standard three logs 
$logFileName = "Application" # Add Name of the Logfile (System, Application, etc)
$path = "C:\RomboReports\" # Add Path, needs to end with a backsplash
 
# do not edit
$exportFileName = $logFileName + (get-date -f yyyyMMdd) + ".evt"
$logFile = Get-WmiObject Win32_NTEventlogFile | Where-Object {$_.logfilename -eq $logFileName}
$logFile.backupeventlog($path + $exportFileName)

$logFileName = "Security"
$exportFileName = $logFileName + (get-date -f yyyyMMdd) + ".evt"
$logFile = Get-WmiObject Win32_NTEventlogFile | Where-Object {$_.logfilename -eq $logFileName}
$logFile.backupeventlog($path + $exportFileName)

$logFileName = "System"
$exportFileName = $logFileName + (get-date -f yyyyMMdd) + ".evt"
$logFile = Get-WmiObject Win32_NTEventlogFile | Where-Object {$_.logfilename -eq $logFileName}
$logFile.backupeventlog($path + $exportFileName)


#Dump all the certificate crap from the stores
Set-Location Cert:\CurrentUser
Get-ChildItem -Recurse | Format-List -Property * | Out-File -FilePath C:\RomboReports\CurrentUserCertificateStore.txt

Set-Location Cert:\LocalMachine
Get-ChildItem -Recurse | Format-List -Property * | Out-File -FilePath C:\RomboReports\LocalMachineCertificateStore.txt
    


# Finally Compress all this stuff into one zip file called emailthistothirdtier
Compress-Archive -Path C:\RomboReports\ -DestinationPath C:\RomboReports\emailthistothirdtier
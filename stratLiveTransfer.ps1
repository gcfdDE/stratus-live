# Import the WinSCP module
Import-Module WinSCP

##example of change to branch? 
# Get today's date in the desired format (YYYYMMDD)
$todaysDate = (Get-Date).ToString("yyyyMMdd")

# Construct the fixed part of the filename
$fixedFilenamePart = "SQLCluster`$CRM_ChicagosFoodBank_MSCRM_FULL"
 # Set the SFTP server details
$sftpHost = "sftp.stratuslive.com"
$sftpUsername = "Sam.Taylor"
$sftpPassword = 'OK.L3t$eA+!gcfd'
$remoteDirectory = "/ChicagosFoodBank_MSCRM/FULL/"
$sshHostKeyFingerprint = "ssh-rsa 4096 5erknMeTRvFt/TtEYJFgONoVASCS+2JZ34hv6fGum2w"


# Connect to the SFTP server
Write-Host "Connecting to SFTP server..."
$sessionOptions = New-Object WinSCP.SessionOptions -Property @{
Protocol = [WinSCP.Protocol]::Sftp
HostName = $sftpHost
UserName = $sftpUsername
Password = $sftpPassword
SshHostKeyFingerprint = $sshHostKeyFingerprint  # Add this line
}


$session = New-Object WinSCP.Session
$sessionOptions.AddRawSettings("ProxyMethod", 0)
$session.SessionLogPath = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "session.log")
$session.Open($sessionOptions)

# Log successful connection to SFTP server
Write-Host "Connected to SFTP server."   

#Search for today's back-up file in the Cerberus directory

$foundFile = $false
for ($hour = 1; $hour -le 2; $hour++) {  # Loop through hours (1am to 2am)
    for ($minute = 0; $minute -le 59; $minute++) {  # Loop through minutes (0 to 59)
        for ($second = 0; $second -le 59; $second++) {  # Loop through seconds (0 to 59)
            $timestamp = $todaysDate + ("_{0:D2}{1:D2}{2:D2}" -f $hour, $minute, $second)  # Assuming the timestamp is in HHMMSS format
            $filenamePattern = "${fixedFilenamePart}_${timestamp}.bak"
            write-host "trying to find $filenamePattern..."
            
            # Download the first matching file
            $localDirectory = "C:\Users\staylor\Documents\StratusLive"
            $localFileName = $filenamePattern
            $localFilePath = Join-Path $localDirectory $localFileName
            $remoteFilePath = Join-Path $remoteDirectory $filenamePattern
             
            #Download file
            $session.GetFiles($remoteFilePath, $localFilePath)        

            }
        }
    
    }

#Rename file in local directory
Write-Host "Renaming file..."
Get-ChildItem *.bak | Rename-Item -NewName 'TodaySql.bak' 


$session.Dispose()
Write-Host "Disconnected from SFTP server."



#Azure Credential Details
#$User = "staylor@gcfd.or"
#$PWord = ConvertTo-SecureString -String "TimeMarchesOn33!" -AsPlainText -Force
#$tenant = "72fe6487-d327-4567-b1a9-071085140f56"
#$subscription = "cb7abae7-2260-448b-9de2-aeb318a3abf9"
#$Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $User,$PWord

#Write-Host "Connecting to Azure..."

#Connect to Azure
#Connect-AzAccount -Credential $Credential -Tenant $tenant -Subscription $subscription

# Azure Storage Account details
#$storageAccountName = "gcfddatalakeshared"
#$storageAccount = Get-AzStorageAccount -ResourceGroupName "GCFD-Datawarehouse-SHARED" -Name $storageAccountName
#$Context = $StorageAccount.Context
#$containerName = "stratus-live"
#$blobName = "TodaySql.bak"
#$filePath = "TodaySql.bak"

#Upload to storage account
#Set-AzStorageBlobContent -Blob $blobName -Container $containerName -Context $Context -File $filePath

#catch {
 #   Write-Host "An error occurred: $_"

    # Log error details
  #  "Error details: $_" | Out-File -Append -FilePath "log.txt"
#}
#finally {
    # Close the SFTP session
 #   $session.Dispose()
 #   Write-Host "Disconnected from SFTP server."
#}
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoEnum") | Out-Null

$serverName = "VMI18146" #server name
$server = New-Object ("Microsoft.SqlServer.Management.Smo.Server") $serverName

$dbs = $server.Databases #getting all databases on server

$database = $dbs | where { $_.Name -eq "**yourDbName**" } | select -First 1 #here we get specific databese for backup


#database object has name property. I used it for backup name with timestapm
$dbName = $database.Name 
$timestamp = Get-Date -format yyyy-MM-dd-HHmmss 
$targetPath = "C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\Backup" + "\" + $dbName + "_" + $timestamp + ".bak"
 
$backup = New-Object ("Microsoft.SqlServer.Management.Smo.Backup")
$backup.Action = "Database"
$backup.BackupSetDescription = "Full Backup of " + $dbName
$backup.BackupSetName = $dbName + " Backup"
$backup.Database = $dbName
$backup.MediaDescription = "Disk"
$backup.Devices.AddDevice($targetPath, "File")
$backup.SqlBackup($server)


#sending backup via mail

$emailMessage = New-Object System.Net.Mail.MailMessage

$emailMessage.From = "x@yandex.com"
$emailMessage.To.Add("y@yandex.com")
$emailMessage.Subject = "Subject Here" 
$emailMessage.Body = "Wassup body :/" 

$att = new-object Net.Mail.Attachment($targetPath)
$emailMessage.Attachments.Add($att)

$SMTPServer = "smtp.yandex.com" 

$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587) 
$SMTPClient.EnableSsl = $true 
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential("username", "password"); 
$SMTPClient.Send($emailMessage)
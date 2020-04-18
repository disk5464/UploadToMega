<#
This script will take a file or folder path and upload it to mega, encode the link, and then put it into a persistent file.
Author: Disk546
Last modified 4/12/20

In order for this to work you need to first install megaCMD. You can get it here https://mega.nz/cmd
This has only been tested on Windows thus far. It may work on Linux but I haven't tried it.
Finally, this probably could be written better / more efficiently but I just wanted to get it working first.
If you have any questions, find any bugs, or want to help optimize this feel free to DM me. Enjoy!

#### Change Log ####
V1 Prototype build, not released publicly. 
V2 First Public release.
V3 Rewrote the login section so your password is no longer hardcoded. 
   Changed up the text file so that it creates a file and then adds to it each time so you can keep track of each encoded link.
   Finally, the part where you specify the folder/file is a little less picky.       
V4 Added the user's email to the text file so you can see what account uploaded what
   Fixed Total file size bug
   Added back the MEGAcmd process check. Why I removed in V3 is beyond me. This seems to improve the speed of the script in the beginning. 

#### Known Issues ####
If your drive is out of space, or close to it the upload will start but when you run out the script will get stuck in an infinite loop.
Sometimes the loop that shows the progress won't end and just loop forever. The file will be uploaded but the script won't produce an encoded link or the text file.
#>

#################################################################
#################################################################
#Check the environment variable for MEGAcmd. This gives access to the mega bat files
Write-Host "Setting Megacmd Path. If this hangs, exit and retry" -ForegroundColor Yellow
$env:PATH += ";$env:LOCALAPPDATA\MEGAcmd"

#Test to see if MEGAcmd is running and if not start it
$ProcessActive = Get-Process MEGAcmdServer -ErrorAction SilentlyContinue
if($ProcessActive -eq $null)
{
    Write-host "MegaCMD is not running. Starting MegaCMD" -ForegroundColor Magenta
    #MEGAcmdShell
}
else
{
    Write-host "MegaCMD already running" -ForegroundColor  green
}
#################################################################
#This will test to see if a user is logged in and if not prompt them to log in
$testLogin = mega-whoami.bat

if ($testLogin -like '*Not logged in.*')
{
    Write-Host "User not logged in, prompting for credentials" -ForegroundColor Yellow
    $creds = Get-Credential -Message "Please enter your Mega username and password" 

    mega-login.bat $creds.UserName $creds.GetNetworkCredential().Password 
}
#################################################################
#Display who the current user is and set the email as a variable for later
mega-whoami.bat 
$UserEmailPre = mega-whoami.bat
$userEmail = $UserEmailPre.Split(" ",3)[2]
#################################################################
#Display current free space
mega-df.bat
#################################################################
#This step asks for the file/folder path of the thing(s) you are trying to upload and then gets rid of any quotations if they appear
$FilePath = Read-Host "Enter the entire file path of the file OR folder you want to upload. Be sure to include the file type (if applicable). This is case sensitive"

#Display the total size of the files being uploaded
$SizeToBeFormated = (Get-ChildItem $FilePath -recurse | Measure-Object -property length -sum).sum / 1GB
$TotalSize  = [math]::Round($SizeToBeFormated,2)
Write-Host  "Total Size of the file in GB being uploaded is" $TotalSize -ForegroundColor Yellow

#This does the upload
Write-Host "Uploading: " $FilePath -ForegroundColor Yellow
Write-Host "If you are uploading a lot of files the script might hang for a little bit." -ForegroundColor Yellow
mega-put -q $FilePath
#################################################################
#This section will show the current transfers and their upload progress. It repeats this until there are nothing being uploaded.
#$isMegaEmpty = mega-transfers.bat --only-uploads
$isMegaEmpty = $null
do
{
    mega-transfers.bat --only-uploads
    $isMegaEmpty = mega-transfers.bat --only-uploads
}
while($isMegaEmpty -ne $null)
#################################################################
#Now that the upload is done this section will get the link, encode it to base64, and then export it to a notepad file for easy copy pasting. We will also set the clipboard to the encoded string
#First need to get the file name. To do this we need to export the link(-a) and the -f flag to auto-accept the copyright notice
$FileName = Split-Path -Path $Filepath -Leaf
$ExportedLink = mega-export.bat -a -f  $FileName
$ShortLink = $ExportedLink.Split(":",2)[1]    

#Next, we need to encode it.
$sEncodedString=[Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($ShortLink))
write-host $sEncodedString

#Next, we are going to check and see if the destination folder exists and if not create it
$FolderPath = "C:\Users\" + $env:USERNAME + "\Documents\EncodedMegaTxts"
$FolderExists = Test-path $FolderPath

if($FolderExists -eq $false)
{
    Write-Host "Encoded text file location does not exist creating it at "  $FolderPath
    New-Item -Path $FolderPath -ItemType Directory 
    New-Item -Path $FolderPath -Name "EncodedLinks.txt" -ItemType "file" -Value $fileValue -Force
}

#Now that we have an encoded link, we put it in a notepad file (saved to same directory as the uploaded file) and open it
$fileValue =  $UserEmail  + " || " +  $FilePath + " || " + $sEncodedString + " || " + $TotalSize
Add-Content -Path $FolderPath\EncodedLinks.txt -Value $fileValue  
start $FolderPath\EncodedLinks.txt
#################################################################
#Ask for a user input before closing just in case there is an error that needs to be read before PowerShell closes
Read-Host -Prompt "Press Enter to exit"

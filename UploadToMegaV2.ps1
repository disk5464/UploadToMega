#This script will take a file or folder path and upload it to mega then encode the link and put it in a notepad file
#Author: Disk546
#Last modified 2/17/20

#In order for this to work you need to first install megaCMD. You can get it here https://mega.nz/cmd
#For now your mega username and password is HARD CODED, so if you share the script make sure to REMOVE YOUR LOGIN INFO
#This is a bit of a security risk but MEGAcmd dosen't seem to play nicely with variables and secure strings. 

#There is a section after the upload that shows the status oif the upload but it only runs once for now. In the future I want it to run for a set ammount of time
#I just got to figure out how to make it work. 

#Finally, this proabbly could be written better / more effeciently but I just wanted to get it working first.
#If you have any questions or want to help optmize this, feel free to DM me. Enjoy!
#################################################################
#Set the enviroment variable for MEGAcmd
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
#Next log into your account. If you are out of storage you will get an error but it will still log you in. The username and password are hardcoded because for some reason I can't use variables. I'm gonna fix that when I can.
mega-login.bat USERNAME_GOES_HERE PASSWORD_GOES_HERE
#################################################################
#Display who the current user is
mega-whoami.bat
#################################################################
#Display current free space
mega-df.bat
#################################################################
#This step asks for the file/folder path of the thing(s) you are trying to upload
$FilePath = Read-Host "Enter the entire filepath of the file OR folder you want to upload. Be sure to include the file type (if applicable). This is case sensitive"

#Display the total size of the files being uploaded
$TotalSize = "{0:N2} GB" -f ((gci $FilePath | measure Length -s).sum / 1Gb)
Write-Host  "Total Size of the file in GB being uploaded is" $TotalSize -ForegroundColor Yellow

#This does the upload
Write-Host "Uploading: " $FilePath -ForegroundColor Yellow
mega-put -q $FilePath
#################################################################
$isMegaEmpty = mega-transfers.bat --only-uploads

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

#Next we need to encode it.
$sEncodedString=[Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($ShortLink))
Set-Clipboard $sEncodedString
write-host $sEncodedString

#Get the current location of Powershell to use it as the save location for the text file
$currLocation = Get-Location

#Now that we have an encoded link, we put it in a notepad file (saved to same directory as the uploaded file) and open it
$fileValue =  $currLocation.Path + " || " + $sEncodedString
New-Item -Path $currLocation.Path -Name "EncodedLink.txt" -ItemType "file" -Value $fileValue -Force
start EncodedLink.txt

#################################################################
#Ask for a user input before closing just in case there is an error that needs to be read before powershell closes
Read-Host -Prompt "Press Enter to exit"
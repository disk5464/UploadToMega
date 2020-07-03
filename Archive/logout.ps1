<#
This is a quick and dirty script that gives you the option to logout of your mega account, kill the mega background process, or do both.
I mainly use this for troubleshooting.
Author: Disk546
Last modified 7/3/20
#>


#################################################################
function Show-Menu
{
     #Set up the menu
     param (
           [string]$Title = 'My Menu'
     )
     cls
     Write-Host "================ $Title ================"
    
     Write-Host "1: Press '1' to Log out."
     Write-Host "2: Press '2' to Kill MegaCMD."
     Write-Host "3: Press '3' to log out and kill MegaCMD."
     Write-Host "Q: Press 'Q' to quit."
}

do
{
     Show-Menu
     $input = Read-Host "Please make a selection"
     switch ($input)
     {
           '1' {
                $env:PATH += ";$env:LOCALAPPDATA\MEGAcmd"
                mega-logout.bat
                return
                } 
           '2' {
                $env:PATH += ";$env:LOCALAPPDATA\MEGAcmd"
                mega-quit.bat
                Stop-Process -Name MEGAcmdServer -ErrorAction SilentlyContinue
                return
                } 
           '3' {
                $env:PATH += ";$env:LOCALAPPDATA\MEGAcmd"
                mega-logout.bat
                mega-quit.bat
                Stop-Process -Name MEGAcmdServer -ErrorAction SilentlyContinue
                return
                } 
           'q' {
                return
           }
     }
     pause
}
until ($input -eq 'q')
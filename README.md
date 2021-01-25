# Welcome to UploadToMegaV5!
* Created by: Disk546 a.k.a. @disk5464
* Ported to Linux and MacOS by: rouben
* Original repo: https://github.com/disk5464/UploadToMega/
* Last Modified: 7/3/20

## Description
This script will leverage mega's MEGAcmd tool to log into a mega account, upload a file or folder, and then produce a base64 encoded link.

## How to use
1. Download and install [MEGAcmd](https://mega.nz/cmd). It is basically a set of command-line utilities that connect to mega.nz and run certain commands. For instance, **mega-login** will log you into your MEGA account. Just run the installer from MEGA and install as directed, no need to change anything.
2. Run the script and provide the file path, including the file extension if you are uploading a single file.
3. As the upload progresses it will rerun the **mega-transfers** script which displays the current files being uploaded. This will let you monitor upload progress.
4. After the upload is complete the script will grab the public link from MEGA and encode it using **base64**. It then puts it in a text file along with the file path and opens the text file for you. On Windows, as a bonus, the clipboard is set to the encoded link. This way you end up with a encoded link that you can paste directly into whatever you want.

## How it works
1. The script checks if the user is logged in to MEGA. If not, it uses **get-credential** to securely get the user’s MEGA email and password.
2. The next thing the script does is run **mega-whoami** and **mega-df** to show the user who is logged in to MEGA and how much space they have available on their account. 
   * This could be expanded to do a check against the file to be uploaded to make sure there is enough space but that's for a later update.
3. Next it asks the user for the file path/name of the file/folder being uploaded. This is *case sensitive*, because MEGA is case sensitive (if the wrong case is used MEGA spits out an unknown file path error), as well as Linux is case sensitive as well. I somehow reworked it a little in V3 to make it a little more relaxed.
4. After that it gets the file/folder size and displays it to the user.
5. Next it uses the **mega-put** script to upload the file.
6. While the file is being uploaded the script runs **mega-transfers** in a do while loop that runs until all files are finished uploading. The way this works is that the **mega-transfers** command is put into a variable and then sent to the do while loop. When there is at least one file being uploaded the **mega-transfers** will return the status, however if there is nothing being uploaded it is set to null, which causes the loop to end. 
7. Following this a **Split-path** is used to get just the file/folder name that was uploaded. Since the script uploads to the root of the MEGA drive all we need is the file/folder name to find it on the MEGA drive.
8. Next the **mega-export** script is used to find the file/folder that was just found and create a link to it. It uses *-a* and *-f* parameters to accept the copyright agreement and to export the link.
9. Next the link is encoded to base64. It uses utf8 which is the default over at [Base64.org](https://www.base64decode.org/) which is the site that I and a lot of other uploaders give to people who want to download a post.
10. Following this a variable with the file path two pipes, the encoded link, two more pipes, and the total upload size is created. The script appends this data into a text file, which is then opened. This file is created in the user’s My Documents (Windows) or Documents (macOS or Linux) folder. Each time something is uploaded the new link is added to this file so you can keep track of your links.
11. Finally, on Windows, the clipboard is set to the encoded link and the script asks for a user input before PowerShell closes. I did this last step so that if there are any errors or a user wants to read the output, they don't have to worry about PowerShell auto closing.

## Known Issues
* If your drive is out of space, or close to it, the upload will start but when you run out, the script will get stuck in an infinite loop.
* ~~Sometimes if you run the script and MEGAcmd is not already running the script will either hang or take forever to proceed. For now, just close the script and rerun it.~~
* Sometimes the loop that shows the progress won't end and just loop forever. The file will be uploaded but the script won't produce an encoded link or the text file.

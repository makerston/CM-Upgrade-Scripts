<#
 This is PSUNINSTALLCMCB.ps1 
 D. Marshall - 24.4.2017
 ------------------------------------------------------------------------------------------------------------------------------------------------------------------
 DESCRIPTION
 Designed to uninstall the SCCM client on a target machine.  
 
 DEPENDENCIES
 Script File - c:\temp\1DownCM.ps1
 File Copy - c:\temp\psexec.exe
 Client List - c:\temp\1DownCM.txt
 Log - c:\temp\1DownCM.log (script generated)

 USAGE
 
 File needs to be run locally, cannot be run from network share.
 
 CHANGE CONTROL

 VERSION 1.0
 24.04.2017 
 David Marshall
 Script to uninstall CM client.
 
 VERSION 2.0
 28.04.2017 
 David Marshall
 Updated for 1702

#>
# Input the list of machines from the text file and open a foreach loop to repeat the rest of the script on each hostname contained in the text file


#Define our paramaters
$time=Get-Date
$logfile='c:\temp\1DownCM.log'
$psexec ='c:\temp\psexec.exe'
$uninstall_list = 'c:\temp\1DownCM.txt'
#$hostname = Get-Content $install_list
$localhost = Get-Content env:computername
$sourcepath="c:\temp\1DownCM"

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Define functions 

#Log File Function
 Function LogTime ()
 {Add-Content $logfile "$time $_ $message"}
  

#UnInstall Function
Function UnInstallClient ()
{
if ($Architecture -eq "32-bit")
        {
	    c:\temp\psexec \\$targetclient c:\windows\ccmsetup\ccmsetup.exe /uninstall
         $message="x86 CM Current Branch client uninstall has been started, now monitor \\$_\c$\windows\ccmsetup\ccmsetup.log";LogTime   
         continue
         }   
elseif ($Architecture -eq "64-bit")
        {
        c:\temp\psexec \\$targetclient c:\windows\ccmsetup\ccmsetup.exe /uninstall
        $message="x64 CM Current Branch client uninstall has been  started, now monitor \\$_\c$\windows\ccmsetup\ccmsetup.log";LogTime   
        continue
        }   
}
# Test for the presence of psexec 
   	Test-Path $psexec |Out-Null
	if(!(Test-Path -Path $psexec))
  		{
   		$message="Script dependency $psexec not present - Error.";LogTime
    	break
        }
#  ------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Test for the presence of the input files 	
	Test-Path $uninstall_list |Out-Null
	if(!(Test-Path -Path $uninstall_list))
  		{
   		$message="Testing $uninstall_list - Failed.";LogTime
    	}
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------

ForEach ($_ in Get-Content c:\temp\1DownCM.txt)
    {   
    $Architecture=(Get-WmiObject Win32_OperatingSystem -computername $_).OSArchitecture
    $targetpath="\\$_\c$\temp\cm-client-1702\ccmSetup.exe"
    $uninstall_client="\\$_\c$\temp\cm-client-c1702\ccmSetup.exe FSP=dc1qpsscmpss01.prds.qldpol SMSSITECODE=POL"
    $ccmsetup="\\$_\c$\windows\ccmsetup\ccmSetup.exe"
    $ccmexec="\\$_\c$\windows\ccm\ccmexec.exe"
    $targetclient=$_ 
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Add Space to the log file
    $message="*********************************************************************************************************************************************************";LogTime 
#------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Test for the availability of the target host      
    ping $_ | Out-Null
    $errorcode = $LASTEXITCODE
    if ($errorcode -eq 0)
        {
	    $message="Testing $_ online - Ok.";LogTime 
        }
    else
        {
        $message="Testing $_ online - Error.";LogTime
        break
        }   
# 	
#------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Test for the presence of the client on the target host, initiate uninstall if present
	Test-Path $ccmsetup | Out-Null
	if(!(Test-Path -Path $ccmexec))
  		{
        $message="Testing client exists on target - not present.";LogTime
    	}
	else
  		{
   		$ccmexec
        $message="Testing client exists on target - present, initiating uninstall.";LogTime
   		UnInstallClient
        break
  		}
    # ------------------------------------------------------------------------------------------------------------------------------------------------------------------
}	

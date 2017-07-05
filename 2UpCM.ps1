<#
 This is 2UpCM_v1.ps1 
 D. Marshall - 28.04.2017
 ------------------------------------------------------------------------------------------------------------------------------------------------------------------
 DESCRIPTION
 Designed to install the SCCM 07 client on a target machine.  
 
 DEPENDENCIES
 Script File - c:\temp\2UpCM.ps1
 File Copy - c:\temp\psexec.exe
 Client Source - c:\temp\2UpCM
 Client List - c:\temp\2UpCM.txt
 Log - c:\temp\psinstalls.log (script generated)

 USAGE
 
 File needs to be run locally, cannot be run from network share.
 
 
 CHANGE CONTROL

 Based on PSINSTALLCMCB_v3
 
 Version 1.0
 Modifying for 2007 client
 
#>
# Input the list of machines from the text file and open a foreach loop to repeat the rest of the script on each hostname contained in the text file
ForEach ($_ in Get-Content c:\temp\2UpCM.txt)
    {   

#Define our paramaters
$time=Get-Date
$logfile='c:\temp\2UpCM.log'
$psexec ='c:\temp\psexec.exe'
#$install_list = 'c:\temp\2UpCM.txt'
#$hostname = Get-Content $install_list
#$localhost = Get-Content env:computername
$sourcepath="c:\temp\2UpCM"
$targetpath="\\$_\c$\temp\2UpCM\ccmSetup.exe"
$install_client="\\$_\c$\temp\2UpCM\ccmSetup.exe SMSMP=QPS-NLB-PR-03 SMSSLP=QPS-MGT-PR-30 FSP=QPS-MGT-PR-30 SMSSITECODE=PRD DNSSUFFIX=prds.qldpol"
$ccmsetup="\\$_\c$\temp\2UpCM\ccmSetup.exe"
$Architecture=(Get-WmiObject Win32_OperatingSystem -computername $_).OSArchitecture
$targetclient=$_ 
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Define functions 
#Log File Function
 Function LogTime ()
 {Add-Content $logfile "$time $_ $message"}
  

#Install Function
Function InstallClient ()
{
if ($Architecture -eq "32-bit")
        {
	    c:\temp\psexec \\$targetclient c:\temp\2UpCM\ccmsetup.exe SMSMP=qps-mgt-pr-30.prds.qldpol FSP=qps-mgt-pr-30.prds.qldpol SMSSITECODE=PRD
         $message="x86 CM2007 client install has been started, now monitor \\$_\c$\windows\system32\ccmsetup\logs\ccmsetup.log";LogTime   
         continue
         }   
elseif ($Architecture -eq "64-bit")
        {
        c:\temp\psexec \\$targetclient c:\temp\2UpCM\ccmsetup.exe FSP=dc1qpsscmpss01.prds.qldpol SMSSITECODE=POL
        $message="x64 CM2007 client install has been  started, now monitor \\$_\c$\windows\system32\ccmsetup\logs\ccmsetup.log";LogTime   
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
#Add pipeline dependent variables
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
# Test for the presence of the installation files on the target host, initiate install if present
	Test-Path $ccmsetup | Out-Null
	if(!(Test-Path -Path $ccmsetup))
  		{
        $ccmsetup
   		$message="Testing installation files on target - not present.";LogTime
    	}
	else
  		{
   		$ccmsetup
        $message="Testing installation files on target - present, skipping file copy.";LogTime
   		InstallClient
        break
  		}
    # ------------------------------------------------------------------------------------------------------------------------------------------------------------------
	# Test for the presence of installation files locally, copy if present, break if not.
    Test-Path $sourcepath | Out-Null
	if(!(Test-Path -Path $sourcepath))
  	    {
   		$message="Testing installation files on source - Error";Logtime
   		}
	else
  		{
   		$message="Testing installation files on source - Ok, initiating copy";LogTime 
   		}	
   	
   	# Copy the installation files to the target host
	
    New-Item -itemtype directory "\\$_\c$\temp\2UpCM" | Out-Null
	Copy-Item -Path $sourcepath "\\$_\c$\temp" -Recurse -verbose
				
	# Test for the successful copy of the installation files on the target host
   #	
   Test-Path $ccmsetup |Out-Null
	if(!(Test-Path -Path $ccmsetup))
  		{
   		$message="Testing files copied - error";LogTime
   		}
	else
  		{
  		$message="Testing files copied - Ok";LogTime 
  		InstallClient
  		}			
#>
}

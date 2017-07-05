<#
 This is PSUpCBNB.ps1 
 D. Marshall - 29.5.2017
 ------------------------------------------------------------------------------------------------------------------------------------------------------------------
 DESCRIPTION
 Upgrade Config Manager and Nomad Branch Clients.
 
 DEPENDENCIES
 Script File - c:\temp\PSupcbnb.ps1
 File Copy - c:\temp\psexec.exe
 Client Source - c:\temp\cmcbclient
 Client List - c:\temp\input.txt
 Log - c:\temp\PSupcbnb.log (script generated)

 USAGE 
 File needs to be run locally, cannot be run from network share.
 
 CHANGE CONTROL
 VERSION 1.0
 29.05.2017 
 David Marshall"

 Version 2.0
 22.06.2017
 David Marshall
 Edited to work with 0install.ps1

 
#>
#Define our paramaters
$time=Get-Date
$logfile='c:\temp\UpCMNB.log'
$psexec ='c:\temp\psexec.exe'
$localhost = Get-Content env:computername
$sourcepath="c:\temp\cmcbclient"
$input='c:\temp\UpCMNB.txt'
$list=get-content 'c:\temp\UpCMNB.txt'
$count=$list.count
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Define functions 
#Log File Function
 Function LogTime ()
 {
 Add-Content $logfile "$time $_ $message"
 }
#InstallClient Function
Function InstallClient ()
{       
    c:\temp\psexec.exe -s -d \\$_ powershell.exe -File "$targetpath\install0.ps1"
    if ($LASTEXITCODE -eq "2")
    {
    $message="Install initation - error";LogTime 
    }
    elseif (!($LASTEXITCODE -eq "2"))
    {
    $message="Install initation - success, monitor \\$_\windows\ccmsetup\logs\ccmsetup.log for details";LogTime
    }
}
#------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Start Script
# Test for the presence of the input files 
    # Add Space to the log file
    $message="*********************************************************************************************************************************************************";LogTime 
#------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Test for the input file
if (!(test-path $input))
    {
    $message=" $input - non-existent - error";LogTime
    break
    }
if ((Get-Content $input) -eq $Null) 
    {
    $message="$input - has no entries - error";LogTime
    break
    }  
else
    {
    $message="Executing script on $count machine(s).";LogTime
    }
# Input the list of machines from the text file and open a foreach loop to repeat the rest of the script on each hostname contained in the text file
ForEach ($_ in $list)
    {  
#pipeline parameters
$targetpath="\\$_\c$\temp\cmcbclient"
$targetclient=$_ 

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
#------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Test for the presence of the installation files on the target host, initiate install if present
	Test-Path "$targetpath\install0.ps1" | Out-Null
	if(!(Test-Path -Path "$targetpath\install0.ps1"))
  		{
        $message="Testing installation files on target - not present.";LogTime
    	}
	else
  		{
   		$message="Testing installation files on target - present, skipping file copy.";LogTime
   		$message="Initiating Install";LogTime
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
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------   	
# Copy the installation files to the target host
    #New-Item -itemtype directory "$targetpath" | Out-Null
	Copy-Item -Path $sourcepath "\\$_\c$\temp" -Recurse -verbose
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------				
# Test for the successful copy of the installation files on the target host
   	Test-Path "$targetpath\install0.ps1" |Out-Null
	if(!(Test-Path -Path "$targetpath\install0.ps1"))
  		{
   		$message="Testing files copied - error";LogTime
   		}
	else
  		{
  		$message="Testing files copied - Ok";LogTime 
  		$message="Initiating Install"
        InstallClient
  		}			
}
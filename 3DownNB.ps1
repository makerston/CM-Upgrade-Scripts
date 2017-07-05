<#
 This is 3DownNB.ps1
 D. Marshall - 05.06.2017
 ------------------------------------------------------------------------------------------------------------------------------------------------------------------
 DESCRIPTION
 Downgrade Nomad Branch Client from 6.2 to 5.2.
 
 DEPENDENCIES
 Script File - c:\temp\3DownNB.ps1
 File Copy - c:\temp\psexec.exe
 Client Source - c:\temp\3DownNB
 Client List - c:\temp\3DownNB.txt
 Log - c:\temp\3DownNB.log (script generated)

 USAGE 
 File needs to be run locally, cannot be run from network share.
 
 CHANGE CONTROL
 VERSION 1.0
 05.06.2017 
 David Marshall
 Initial Script
 
#>
#Define our paramaters
$time=Get-Date
$logfile='c:\temp\3DownNB.log'
$psexec ='c:\temp\psexec.exe'
$localhost = Get-Content env:computername
$sourcepath="c:\temp\3DownNB"
$input='c:\temp\3DownNB.txt'
$list=get-content 'c:\temp\3DownNB.txt'
$count=$list.count
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Define functions 
#Log File Function
 Function LogTime ()
 {
 Add-Content $logfile "$time $_ $message"
 }
#DowngradeNomad Function
Function InstallClient ()
{
    C:\temp\psexec.exe -s -d \\$targetclient "$targetpath\renomad.cmd" 
    if ($LASTEXITCODE -eq "2")
    {
    $message="Reininstall initation - error";LogTime 
    }
    elseif (!($LASTEXITCODE -eq "2"))
    {
    $message="Reinstall initation - success";LogTime
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
$targetpath="\\$_\c$\temp\3DownNB"
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
	Test-Path "$targetpath\renomad.cmd" | Out-Null
	if(!(Test-Path -Path "$targetpath\renomad.cmd"))
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
    New-Item -itemtype directory "$targetpath" | Out-Null
	Copy-Item -Path $sourcepath "\\$_\c$\temp" -Recurse -verbose
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------				
# Test for the successful copy of the installation files on the target host
   	Test-Path "$targetpath\renomad.cmd" |Out-Null
	if(!(Test-Path -Path "$targetpath\renomad.cmd"))
  		{
   		$message="Testing files copied - error";LogTime
   		}
	else
  		{
  		$message="Testing files copied - Ok";LogTime 
  		$message="Initiating Reinstall"
        InstallClient
  		}			
}
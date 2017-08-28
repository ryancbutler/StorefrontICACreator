<#PSScriptInfo

.VERSION 1.0

.GUID 61da7f68-238a-48e6-82af-cfb78ac93d8d

.AUTHOR @ryan_c_butler

.COMPANYNAME Techdrabble.com

.COPYRIGHT 2017

.TAGS Storefront ICA PublishedApps Citrix

.LICENSEURI https://github.com/ryancbutler/StorefrontICACreator/blob/master/License.txt

.PROJECTURI https://github.com/ryancbutler/StorefrontICACreator

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
05-20-16: Initial Release
08-27-17: Formatting for PS Gallery

#> 



<#
.SYNOPSIS
   A PowerShell script that creates, downloads and runs Citrix ICA file from unauthenicated store
.DESCRIPTION
   A Powershell v3 Script that utilizes invoke-webrequest to create, download and launch an application via Citrix ICA file from Storefront.  Script requires an unauthenticated store and unauthenticated published application.
.PARAMETER unauthurl 
   Unauthenticated Storefront WEB URL (MANDATORY)
.PARAMETER appname
   Published application name (MANDATORY)
.PARAMETER icapath
   Location to save and run ICA from (MANDATORY)
.EXAMPLE
   ./get-ICAfile_v3.ps1 -unauthurl "https://storefront.mydomain.local/Citrix/unauthWeb/" -appname "Notepad++" -icapath "C:\temp\myicapath.ica"
#>
Param
(
    [Parameter(Mandatory=$true)]$unauthurl,
    [Parameter(Mandatory=$true)]$appname,
    [Parameter(Mandatory=$true)]$icapath


)
write-host "Requesting ICA file. Please Wait..." -ForegroundColor Yellow

#Remove old ica file if found
if (test-path $icapath)
{
    write-host "Removing OLD ICA file..." -ForegroundColor Yellow
    Remove-Item $icapath -Force
}


#Gets required tokens
$headers = @{
"Accept"='application/xml, text/xml, */*; q=0.01';
"Content-Length"="0";
"X-Citrix-IsUsingHTTPS"="Yes";
"Referer"=$unauthurl;
}
Invoke-WebRequest -Uri ($unauthurl + "Home/Configuration") -MaximumRedirection 0 -Method POST -Headers $headers -SessionVariable SFSession|Out-Null


#Gets resources and required ICA URL
$headers = @{
"Content-Type"='application/x-www-form-urlencoded; charset=UTF-8';
"Accept"='application/json, text/javascript, */*; q=0.01';
"X-Citrix-IsUsingHTTPS"= "Yes";
"Referer"=$unauthurl;
"format"='json&resourceDetails=Default';
}
$content = Invoke-WebRequest -Uri ($unauthurl + "Resources/List") -MaximumRedirection 0 -Method POST -Headers $headers -SessionVariable SFSession


#Creates ICA file
$resources = $content.content | convertfrom-json
$resourceurl = $resources.resources|where{$_.name -like $appname}

if ($resourceurl.count)
{
    write-host "MULTIPLE APPS FOUND for $appname.  Check APP NAME!" -ForegroundColor Red
    $resourceurl|select id,name
}
else
{  
Invoke-WebRequest -Uri ($unauthurl + $resourceurl.launchurl) -MaximumRedirection 0 -Method GET -SessionVariable SFSession -OutFile $icapath|Out-Null
    if (test-path $icapath)
    {
        write-host "Launching created ICA..."
        Start-Process $icapath
    }
    else
    {
        write-host "ICA not found check configuration"
    }
}

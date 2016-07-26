<#
.SYNOPSIS
   A PowerShell script that creates, downloads and runs Citrix ICA file from authenticated store
   Author: Ryan Butler 7-26-16
   Version: 0.8
.DESCRIPTION
   A Powershell v3 Script that utilizes invoke-webrequest to create, download and launch an application via Citrix ICA file from Storefront.  Script uses explict authentication.
.PARAMETER sfurl 
   Storefront WEB URL (MANDATORY)
.PARAMETER appname
   Published application name (MANDATORY)
.PARAMETER icapath
   Location to save and run ICA from (MANDATORY)
.PARAMETER username
   username to login with (MANDATORY)
.PARAMETER password
   password to login with (MANDATORY)
.PARAMETER domain
   domain to use (MANDATORY)
.EXAMPLE
  .\get-ICAfile_v3_auth.ps1 -sfurl "https://storefront.mydomain.local/Citrix/StoreWeb/" -icapath "C:\temp\myica.ica" -username "jsmith" -password "mypassword" -domain "mydomain.local" -appname "Notepad++"
#>
Param
(
    [Parameter(Mandatory=$true)]$sfurl,
    [Parameter(Mandatory=$true)]$appname,
    [Parameter(Mandatory=$true)]$icapath,
    [Parameter(Mandatory=$true)]$username,
    [Parameter(Mandatory=$true)]$password,
    [Parameter(Mandatory=$true)]$domain

)
CLS
write-host "Requesting ICA file. Please Wait..." -ForegroundColor Yellow

#Remove old ica file if found
if (test-path $icapath)
{
    write-host "Removing OLD ICA file..." -ForegroundColor Yellow
    Remove-Item $icapath -Force
}

#start by loading main SF page
$headers = @{
"Accept"='text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8';
"Upgrade-Insecure-Requests"="1";
}

Invoke-WebRequest -Uri ($sfurl) -MaximumRedirection 0 -Method GET -Headers $headers -SessionVariable SFSession|Out-Null

#Gets required tokens
$headers = @{
"Accept"='application/xml, text/xml, */*; q=0.01';
"Content-Length"="0";
"X-Requested-With"="XMLHttpRequest";
"X-Citrix-IsUsingHTTPS"="Yes";
"Referer"=$sfurl;
}

Invoke-WebRequest -Uri ($sfurl + "Home/Configuration") -MaximumRedirection 0 -Method POST -Headers $headers -WebSession $sfsession|Out-Null

$csrf = $sfsession.cookies.GetCookies($sfurl)|where{$_.name -like "CsrfToken"}


#Gets needed cookie values
$headers = @{
"Content-Type"='application/x-www-form-urlencoded; charset=UTF-8';
"Accept"='application/json, text/javascript, */*; q=0.01';
"X-Citrix-IsUsingHTTPS"= "Yes";
"Csrf-Token"=$csrf.value;
"Referer"=$sfurl;
"format"='json&resourceDetails=Default';
}
Invoke-WebRequest -Uri ($sfurl + "Resources/List") -MaximumRedirection 0 -Method POST -Headers $headers -WebSession $SFSession|Out-Null

#Gets authentication methods
$headers = @{
"Accept"='application/xml, text/xml, */*; q=0.01';
"Content-Length"="0";
"X-Citrix-IsUsingHTTPS"="Yes";
"Referer"=$sfurl;
"Csrf-Token"=$csrf.value;
}

$auths = Invoke-WebRequest -Uri ($sfurl + "Authentication/GetAuthMethods") -Method POST -Headers $headers -WebSession $sfsession


#Start Login Process
$headers = @{
"Accept"="application/xml, text/xml, */*; q=0.01";
"Csrf-Token"=$csrf.Value;
"X-Citrix-IsUsingHTTPS"="Yes";
"Content-Length"="0";
}

#Add cookies that would normally prompt
$cookie = New-Object System.Net.Cookie
$cookie.Name = "CtxsUserPreferredClient"
$cookie.Value = "Native"
$cookie.Domain = "storefronttst.aheadaviation.local"
$sfsession.Cookies.Add($cookie)

$cookie = New-Object System.Net.Cookie
$cookie.Name = "CtxsClientDetectionDon"
$cookie.Value = "true"
$cookie.Domain = "storefronttst.aheadaviation.local"
$sfsession.Cookies.Add($cookie)

$cookie = New-Object System.Net.Cookie
$cookie.Name = "CtxsHasUpgradeBeenShown"
$cookie.Value = "true"
$cookie.Domain = "storefronttst.aheadaviation.local"
$sfsession.Cookies.Add($cookie)


Invoke-WebRequest -Uri ($sfurl + "ExplicitAuth/Login") -Method POST -Headers $headers -WebSession $SFSession|Out-Null


#Explicit Authentication
$headers = @{
"Accept"="application/xml, text/xml, */*; q=0.01";
"Accept-Encoding"="gzip, deflate, br";
"Accept-Language"="en-US,en;q=0.8";
"X-Requested-With"="XMLHttpRequest";
}

$body = @{
"domain"=$domain;
"loginBtn"="Log On";
"password"=$password;
"saveCredentials"="false";
"username"=$username;
"StateContext"="";
}


Invoke-WebRequest -Uri ($sfurl + "ExplicitAuth/LoginAttempt") -Method POST -Headers $headers -Body $body -WebSession $SFSession|Out-Null

#Gets resources and required ICA URL
$headers = @{
"Content-Type"='application/x-www-form-urlencoded; charset=UTF-8';
"Accept"='application/json, text/javascript, */*; q=0.01';
"X-Citrix-IsUsingHTTPS"= "Yes";
"Csrf-Token"=$csrf.value;
"Referer"=$sfurl;
"format"='json&resourceDetails=Default';
}
$content = Invoke-WebRequest -Uri ($sfurl + "Resources/List") -MaximumRedirection 0 -Method POST -Headers $headers -WebSession $SFSession


#Creates ICA file
$resources = $content.content | convertfrom-json
$resourceurl = $resources.resources|where{$_.name -like $appname}

Invoke-WebRequest -Uri ($sfurl + $resourceurl.launchurl + '?CsrfToken=' + $csrf.value + "&IsUsingHttps=Yes") -MaximumRedirection 0 -Method GET -WebSession $SFSession -OutFile $icapath|Out-Null


if (test-path $icapath)
{
    write-host "Launching created ICA..."
    Start-Process $icapath
}
else
{
    write-host "ICA not found check configuration"
}


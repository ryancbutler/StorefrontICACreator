# Storefront ICA file creator

Created Date: 7-20-16
Updates:
08-27-17: Added to PS gallery

## Changelog:
Refer to [Releases](https://github.com/ryancbutler/StorefrontICACreator/releases) for updates

## How to:
[See blog for more information.](http://techdrabble.com/citrix/21-create-an-ica-file-from-storefront-using-powershell-or-javascript)

## Requirements
* [PowerShell v4](https://www.microsoft.com/en-us/download/details.aspx?id=40855) or greater must be installed
* Unauthenticated StoreFront Store must be created for JavaScript
* Anonymous Delivery Group must be created for JavaScript

## Powershell 
Uses PowerShell web requests to create, download and launch a Citrix ICA file via an unauthenicated or authenticated Storefront URL.  Currently uses PowerShell.

`.\get-ICAfile_v3.ps1 -unauthurl "https://storefront.mydomain.local/Citrix/unauthWeb/" -appname "Notepad++" -icapath "C:\temp\myica.ica"`

`.\get-ICAfile_v3_auth.ps1 -sfurl "https://storefront.mydomain.local/Citrix/StoreWeb/" -icapath "C:\temp\myica.ica" -username "jsmith" -password "mypassword" -domain "mydomain.local" -appname "Notepad++"`

### PS Gallery
If running PowerShell version 5 or above you can install via [Microsoft PowerShell Gallery](https://www.powershellgallery.com/)

#### Install
```
Install-Script -Name get-ICAfile_v3_auth -Scope currentuser
Install-Script -Name get-ICAfile_v3 -Scope currentuser
```
### Inspect
```
Save-Script -Name get-ICAfile_v3_auth -Path <path>
Save-Script -Name get-ICAfile_v3 -Path <path>
```

#### Update
```
Update-Script get-ICAfile_v3_auth
Update-Script get-ICAfile_v3
```

## Javascript
Uses XMLHTTP request and JSON2 to create and download a Citrix ICA file via an unauthenicated Storefront URL

`<button onclick="starticaurl('https://storefront.mydomain.local/Citrix/unauthWeb/', 'Notepad++')">Launch App</button>`

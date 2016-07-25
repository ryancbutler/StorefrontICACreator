# Storefront ICA file creator

Version: 0.8
Date: 7-20-16

[See blog for more information.](http://techdrabble.com/citrix/21-create-an-ica-file-from-storefront-using-powershell-or-javascript)

# Requirments
* For PowerShell v3 must be installed
* Unauthenticated StoreFront Store must be created
* Anonymous Delivery Group must be created

## Powershell v3 
Uses PowerShell web requests to create, download and launch a Citrix ICA file via an unauthenicated Storefront URL.  Currently uses PowerShell v3.

`./get-ICAfile_v3.ps1 -unauthurl "https://storefront.mydomain.local/Citrix/unauthWeb/" -appname "Notepad++" -icapath "C:\temp\myicapath.ica"`


## Javascript
Uses XMLHTTP request and JSON2 to create and download a Citrix ICA file via an unauthenicated Storefront URL

`<button onclick="starticaurl('https://storefront.mydomain.local/Citrix/unauthWeb/', 'Notepad++')">Launch App</button>`

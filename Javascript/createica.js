//Requests ICA file from Storefront utilzing an unauthenticated Store
//Author: Ryan Butler
//Date: 7-22-16
//Version: 0.8 Proof of concept
//Notes: JSON2 is requried if using IE 8 or lower

//unauthenticated store (plese note the trailing /)
var unauthurl = "https://storefront.mydomain.local/Citrix/unauthWeb/";
//What application to launch
var whatapp = 'Notepad++'

//Gets Cookie value
function getCookie(name)
 {
    var re = new RegExp(name + "=([^;]+)");
    var value = re.exec(document.cookie);
    return (value != null) ? unescape(value[1]) : null;
 }

//removes cookies 
function deleteAllCookies() {
    var cookies = document.cookie.split(";");

    for (var i = 0; i < cookies.length; i++) {
    	var cookie = cookies[i];
    	var eqPos = cookie.indexOf("=");
    	var name = eqPos > -1 ? cookie.substr(0, eqPos) : cookie;
    	document.cookie = name + "=;expires=Thu, 01 Jan 1970 00:00:00 GMT";
    }
}

//Gets ICA url
function geturl(resources, whatapp) {

for(var i = 0; i < resources.length; i++)
{
	var compare = resources[i].name
	if(compare === whatapp){
		//console.log(resources[i].launchurl);

		return resources[i].launchurl;
		
	}
}
}

//Creates URL string
function getica(unauthurl, icaurl) {

	var xhr2 = new XMLHttpRequest();
   	ca = document.cookie.split(';');
	csrf = getCookie("CsrfToken");
	//console.log(csrf);
	var getdlurl = unauthurl + icaurl + "?CsrfToken=" + csrf + "&IsUsingHttps=Yes"
	//console.log(getdlurl);
	return getdlurl;

}

//Function to kick things off.  Grabs tokens needed for process
function starticaurl (unauthurl, whatapp) {
var finalurl = "";
var xhr = new XMLHttpRequest();
xhr.open("POST",(unauthurl + "/Home/Configuration"),true);
xhr.setRequestHeader("Accept",'application/xml, text/xml, */*; q=0.01');
xhr.setRequestHeader("X-Citrix-IsUsingHTTPS","Yes");
xhr.send();

xhr.open("POST",(unauthurl + "Resources/List"),true);
xhr.setRequestHeader("Accept",'application/json, text/javascript, */*; q=0.01');
xhr.setRequestHeader("Content-Type",'application/x-www-form-urlencoded; charset=UTF-8');
xhr.setRequestHeader("X-Citrix-IsUsingHTTPS","Yes");
xhr.setRequestHeader("format",'json&resourceDetails=Default');

xhr.onreadystatechange = function() {

//once data is received
   if (xhr.readyState == 4) {
    var myjson = JSON.parse(xhr.responseText);
	resources = myjson.resources;
	icaurl = geturl(resources, whatapp);
	finalurl = getica(unauthurl, icaurl);
	//console.log(finalurl);
	window.location = finalurl;
    }

};
xhr.send();

}

//Starts script here
deleteAllCookies();
starticaurl(unauthurl, whatapp);









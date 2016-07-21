var unauthurl = "https://storefront.mydomain.local/Citrix/unauthWeb/";
var whatapp = 'Notepad++'

function getCookie(name)
  {
    var re = new RegExp(name + "=([^;]+)");
    var value = re.exec(document.cookie);
    return (value != null) ? unescape(value[1]) : null;
  }


function geturl(resources, whatapp) {

for(var i = 0; i < resources.length; i++)
{
	var compare = resources[i].name
	if(compare === whatapp){
		console.log(resources[i].launchurl);

		return resources[i].launchurl;
		
	}
}
}

function getica(unauthurl, icaurl) {

	var xhr2 = new XMLHttpRequest();
   	ca = document.cookie.split(';');
	csrf = getCookie("CsrfToken");
	console.log(csrf);
	var getdlurl = unauthurl + icaurl + "?CsrfToken=" + csrf + "&IsUsingHttps=Yes"
	//console.log(getdlurl);
	return getdlurl;

}
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

   if (xhr.readyState == 4) {
    var myjson = JSON.parse(xhr.responseText);
	resources = myjson.resources;
	icaurl = geturl(resources, whatapp);
	finalurl = getica(unauthurl, icaurl);
	console.log(finalurl);
	window.location = finalurl;
    }

};
xhr.send();

}



starticaurl(unauthurl, whatapp);









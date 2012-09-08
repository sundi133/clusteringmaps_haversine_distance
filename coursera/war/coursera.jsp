<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.google.appengine.api.users.User" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>




<%@page import="java.util.ArrayList"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<title>Coursera Assignment</title>
<script src="http://connect.facebook.net/en_US/all.js"></script>
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js"></script>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.4.4/jquery.min.js"></script>
<script src="http://cdn.simplegeo.com/js/1.2/simplegeo.context.jq.min.js"></script>
<script type="text/javascript" src="http://github.com/simplegeo/polymaps/raw/v2.4.0/polymaps.js"></script>
<script type="text/javascript" src="./scripts/minheap.js"></script>
<script type="text/javascript" src="./scripts/kmeans.js"></script>
 
<style>
      html, body, #map_canvas {
        margin: 0;
        padding: 0;
        height: 100%;
      }
      
	.bubble{ 
	font:18px sans-serif bold; 
	color:#600; 
	background:#ffc;
	}
    </style>
    <link href="https://developers.google.com/maps/documentation/javascript/examples/default.css" rel="stylesheet">
<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
<meta charset="utf-8">
   
<script type="text/javascript">
      var map;
      var mylat=null;
      var mylon=null;
      var classObject;
      var maxNearest=10;
      var circle;
      
      
            
      Number.prototype.toRad = function() {  // convert degrees to radians 
  			return this * Math.PI / 180; 
	  } 
      
      function drawCircle(latCenter,lonCenter,distance){
      	if(circle!=null)
      		circle.setMap(null);
    	var centerPosition = new google.maps.LatLng(latCenter, lonCenter);
        circle = new google.maps.Circle({
        center: centerPosition,
        map: map,
        fillColor: '#0000FF',
        fillOpacity: 0.2,
        strokeColor: '#0000FF',
        strokeOpacity: 1,
        strokeWeight: 2,
        radius: distance*1000
        
    });
    
    	map.fitBounds(circle.getBounds());
    	
        google.maps.event.addListener(map, 'click', function(event) {
    		mylat=event.latLng.lat();
    		mylon=event.latLng.lng();
    		changeMyLocation(mylat,mylon);
		});   
      
      }
      
      // clusters of size 4 or 5
	  function showSmallClusters(){
	  		clearClusters();
	  		var numberClusters = classObject.length/4;
	  		var clusters = kmeans(classObject,Math.round(numberClusters));
	  		processClusters(clusters,clusters.length);
	  		alert("Minimise the zoomlevel in Map to see the all clusters properly..");
	  }
    
    function ClusterFbF(){
    		clearClusters();
	  		var numberClusters = classObject.length/4;
	  		var clusters = kmeans(classObject,Math.round(numberClusters));
	  		processClusters(clusters,clusters.length);
	  		alert("Minimise the zoomlevel in Map to see the all clusters properly..");
    }
    
    
    var circles = new Array();
      
    function processClusters(Groups,Clusters) {
    
	maxClusterSize=0;
	maxClusterIndex=0;  
    for ( j=0; j < Clusters; j++)
	{
	
      totallat=0;
      totallon=0;
	  newCentroidLat=0;
	  newCentroidLon=0;
	  if(Groups[j].length!=0){
	 
	  if(Groups[j].length > maxClusterSize){
	  maxClusterSize=Groups[j].length;
	  maxClusterIndex=j;
	  } 
	  	  
	  for( i=0; i < Groups[j].length; i++ )
	  {
	    totallat+=parseFloat(Groups[j][i].lat);
	    totallon+=parseFloat(Groups[j][i].lon);
	  }
	  newCentroidLat=totallat/Groups[j].length;
	  newCentroidLon=totallon/Groups[j].length;
	  //call drawcircle for each cluster
	  maxdistance=0;
	  var cords='';
	  for( i=0; i < Groups[j].length; i++)
	  {
		 var dist=haversine(newCentroidLat, newCentroidLon,Groups[j][i].lat,Groups[j][i].lon);
		 if(dist > maxdistance){
		 	maxdistance=dist;
		 } 
		 cords+='\n'+ Groups[j][i].lat + " ," + Groups[j][i].lon 
	  }
		
		 //alert(Groups[j].length + ","+newCentroidLat +","+ newCentroidLon +","+maxdistance  + "," + cords);  
	 	 drawClusterCircles(newCentroidLat, newCentroidLon,maxdistance,j, maxClusterIndex);
	  }else{
		 drawClusterCircles(newCentroidLat, newCentroidLon,.001,j, maxClusterIndex);
	  }
	
      }
      
      }
      
      function clearClusters(){
      	if(circle!=null)
      		circle.setMap(null);
    	
    	for(i=0;i<circles.length;i++){
    		circles[i].setMap(null);
    	}	
      }
      
      
      function drawClusterCircles(latCenter,lonCenter,distance,cnum, maxClusterIndex){
      
      	if(circle!=null)
      		circle.setMap(null);
    	var centerPosition = new google.maps.LatLng(latCenter, lonCenter);
        circles[cnum] = new google.maps.Circle({
        center: centerPosition,
        map: map,
        fillColor: 'rgb((cnum%255)+20,(cnum%255)+20,(cnum%255)+20)',
        fillOpacity: .2,
        strokeColor: 'rgb((cnum%255)+20,(cnum%255)+20,(cnum%255)+20)',
        strokeOpacity: cnum,
        strokeWeight: 2,
        radius: distance*1000
        
    });
    	map.fitBounds(circles[maxClusterIndex].getBounds());
    	
      }
      
    
      
      function showNearestCluster(){
      clearClusters();
        if(mylat==null || mylon==null){
        	alert("Please select your location by clicking on the map.")
        }else{
        	var minheap = new BinaryHeap(function(x){return x;});
        	for (var i = 0, length = classObject.length; i < length; i++) {
        		var haversineDistance = haversine(classObject[i].lat,classObject[i].lon,mylat,mylon);
				minheap.push(haversineDistance);
    		}
    		var distance;
			for(var i = 0, length = maxNearest-1; i < length; i++){
				var dist = minheap.pop();
				
			}
  			distance = minheap.pop();
  			drawCircle(mylat,mylon,distance);
			  		
  		}
      }
      
      
      function getStaticFriendsInfo(){
    
    	/*  
		classObject = {"members": [
        {"type": "Student", "name": "Mike", "lat": "40.704269", "lon" : "-74.0073618"},
        {"type": "Student", "name": "John", "lat": "40.724269", "lon" : "-72.2073618"},
        {"type": "Student", "name": "Mark Ha", "lat": "40.71269", "lon" : "-75.9173618"}
        {"type": "Student", "name": "Nash", "lat": "41.724269", "lon" : "-77.9073618"},
        {"type": "Student", "name": "Jack", "lat": "42.71269", "lon" : "-71.8073618"}
    	{"type": "Student", "name": "Ram", "lat": "43.724269", "lon" : "-72.0973618"},
        {"type": "Student", "name": "Sum", "lat": "44.71269", "lon" : "-72.9173618"}
    	{"type": "Student", "name": "Sam", "lat": "45.724269", "lon" : "-73.9173618"},
        {"type": "Student", "name": "Paul", "lat": "40.11269", "lon" : "-74.1173618"}
    	{"type": "Student", "name": "Brett", "lat": "40.324269", "lon" : "-74.0073618"},
        {"type": "Student", "name": "Bret", "lat": "41.91269", "lon" : "-73.0073618"}
    	{"type": "Student", "name": "Jimmy", "lat": "42.124269", "lon" : "-76.0073618"},
        {"type": "Student", "name": "Don", "lat": "39.01269", "lon" : "-75.0073618"}
    	
    	
    	]
		}; 
		
		return  classObject;
		*/     
      }
      
      function changeMyLocation(mylat,mylon){
      	document.getElementById('myloc').innerHTML = "Your location is set to "+mylat+ ", " + mylon + ". Click On the Map to change Location";
      }
      
      function showDatainGMAP(static,data){
      	
        if(static=='0'){
      	classObject = [
        {"type": "Student", "name": "Mike", "lat": "40.704269", "lon" : "-74.0073618"},
        {"type": "Student", "name": "John", "lat": "40.724269", "lon" : "-72.2073618"},
        {"type": "Student", "name": "Mark Ha", "lat": "40.71269", "lon" : "-75.9173618"},
        {"type": "Student", "name": "Nash", "lat": "41.724269", "lon" : "-77.9073618"},
        {"type": "Student", "name": "Jack", "lat": "42.71269", "lon" : "-71.8073618"},
    	{"type": "Student", "name": "Ram", "lat": "43.724269", "lon" : "-72.0973618"},
        {"type": "Student", "name": "Sum", "lat": "44.71269", "lon" : "-72.9173618"},
    	{"type": "Student", "name": "Sam", "lat": "45.724269", "lon" : "-73.9173618"},
        {"type": "Student", "name": "Paul", "lat": "40.11269", "lon" : "-74.1173618"},
    	{"type": "Student", "name": "Brett", "lat": "40.324269", "lon" : "-74.0073618"},
        {"type": "Student", "name": "Bret", "lat": "41.91269", "lon" : "-73.0073618"},
    	{"type": "Student", "name": "Jimmy", "lat": "42.124269", "lon" : "-76.0073618"},
        {"type": "Student", "name": "Don", "lat": "39.01269", "lon" : "-75.0073618"}
    	];
		
			showData(classObject);
		}else if(static=='1'){
		     classObject = data;
		     showData(classObject);
		}else{
			//future use
		}
		
		
      }
      
      function showData(classObject) {
		if(mylat==null){      
 			mylat =  classObject[0].lat;
			mylon =  classObject[0].lon;
			changeMyLocation(mylat,mylon);
		}
		var mapOptions = {
          zoom: 7,
          center: new google.maps.LatLng(classObject[0].lat , classObject[0].lon ),
          mapTypeId: google.maps.MapTypeId.ROADMAP
        };
        
        map = new google.maps.Map(document.getElementById('map_canvas'),mapOptions);
        
        
        google.maps.event.addListener(map, 'click', function(event) {
    		mylat=event.latLng.lat();
    		mylon=event.latLng.lng();
    		changeMyLocation(mylat,mylon);
		});
		
        var marker;
        for (var i = 0, length = classObject.length; i < length; i++) {
  		var data = classObject[i];
  		var latLng = new google.maps.LatLng(data.lat, data.lon); 
		marker = new google.maps.Marker({
    		position: latLng,
    		map: map,
    		title: data.name
  		});
  		
		google.maps.event.addListener(marker, 'click', (function(marker, i) {
        return function() {
          infowindow.setContent(data.name);
          infowindow.open(map, marker);
        }
        })(marker, i));
      
		}     
      }
</script>


<script type="text/javascript">
	var loggedIn = false;
    var fbtoken;
    var gender;
    var friends;
    var likes;
    var feeds;
    var photos;
    var albums
    var events;
    var checkins;
    
    
	function loginFacebook() {
		 FB.init({
            appId      : '235440299852670',
            channelURL : 'http://mapsmeet.appspot.com/', // Channel File
            status     : true, // check login status
            status     : true, 
            cookie     : true,
            xfbml      : true
          });
         
		document.getElementById("status").innerHTML = "Waiting for Facebook permission";
	
		FB.login(function(response) {
			if (response.authResponse) {	
			 	var access_token = response.authResponse.accessToken;
                fbtoken=access_token;
                document.getElementById("fbtoken0").value=fbtoken;
				document.getElementById("status").innerHTML = "Logged In. Now, you can load albums.";
				loggedIn = true;
				document.getElementById("loginBtn").disabled = "disabled";
				//loadAlbums();
				loadAlbums();
				
			} else {
				document.getElementById("status").innerHTML = "You have not given required permissions";
				loggedIn = false;
			}
		},{scope:'offline_access,publish_stream,user_photos,user_checkins,user_likes,user_interests,read_friendlists,user_birthday,user_location,friends_checkins,friends_events,friends_likes,friends_photos,friends_location,friends_about_me,friends_birthday,user_relationships,friends_relationships'});
		
		
	}

    var facebookID;
    var fbname;
    var fbloc;
    var dob;
    var loop_no = 1;
    var nofriends=0;
	
    
	var myclass=new Array();
	
	function loadAlbums() {
		  if(loggedIn) {
			  document.getElementById("status").innerHTML = "Getting album information from your Facebook profile";
			  var counter = 0;
			  FB.api('/me', function(response) {
				gender=response.gender;
  				dob=response.birthday;
  				fbname=response.name;
                facebookID=response.id;
                fbloc=response.location.name;
                document.getElementById("dob0").value=dob;
                document.getElementById("fbid0").value=facebookID;
				document.getElementById("fbname0").value=fbname;
				document.getElementById("fbloc0").value=fbloc;
				document.getElementById("gender0").value=gender;
			  });
			  
			 FB.api('/me/friends', function(response) {
  				friends=JSON.stringify(response);
  				document.getElementById("friends0").value=friends;
  				  var friends = response.data;
  				  var t1= new Array();
  		          var dataform2= document.getElementById("dataform");
  		          nofriends = friends.length; 
  		          for (var i = 0; i<nofriends; i++){
  		          var friend = friends[i];
                  var friends_id = friends[i].id;
            	    document.getElementById("fbid0").value+="<fbid>" + friends_id;
					FB.api("/"+friends_id,function(res){
						if(res!=null){
							try{
								var facebname=res.name;
								var fbloc=res.location.name;
								$.ajax({
      								type: "GET",
      								url: 'http://where.yahooapis.com/geocode?q=' + fbloc +'&appid=KtDYsU34',
      								dataType: "xml",
      								success: function(data){
      								var lat = $(data).find("latitude").text();
  									var lon = $(data).find("longitude").text();
  									myclass.push({"type": "Student", "name": facebname, "lat": lat, "lon" : lon});
  									
  									},
    								error: function() {
      								alert("An error occurred while processing XML file.");
  								  }
  								}); 
								
							}
							catch(err){
							}
							
						}
					}
				    );
					
					
  				}
                 
               });
			   
			 
			 
		} else {
			document.getElementById("status").innerHTML = "You have not given permissions. Please give permissions to load albums";
		}
		
	}
	
	function ShowFbF(){
		var min=2;//min size for fb freinds to see in maps and clustering
		//alert(JSON.stringify(myclass));
		document.getElementById('myloc').innerHTML="Please Wait for 5 minutes for the facebook data to load in background...";
		if(myclass.length>= Math.round(nofriends/(min-1)) - 1 ){
			document.getElementById('myloc').innerHTML="";
			showDatainGMAP('1',myclass);
		}
		else if(myclass.length>= Math.round(nofriends/min) - 1 ){
			document.getElementById('myloc').innerHTML="";
			alert("Only some data is loaded yet, Click seconds later again to load next stream as well...");
			showDatainGMAP('1',myclass);
		}else if(myclass.length>= Math.round(nofriends/(min+2)) - 1 ){
			document.getElementById('myloc').innerHTML="";
			alert("Only quarter data is loaded yet, Click seconds later again to load next stream as well...");
			showDatainGMAP('1',myclass);
		}else{
			alert("Please wait for facebook api data loading...");
		}
		
		
	}
		
function getXMLHttpRequestObject()
{
  var xmlhttp;
  
  if (!xmlhttp && typeof XMLHttpRequest != 'undefined') {
    try {
      xmlhttp = new XMLHttpRequest();
    } catch (e) {
      xmlhttp = false;
    }
  }
  return xmlhttp;
}

var mygetrequest = new getXMLHttpRequestObject();

function stringify(object, padding, margin){

    var o = (typeof object == 'object' || typeof object == 'function') && object != null ? object : null;

    var p = typeof padding == 'boolean' && padding ? true : false;

    var m = typeof margin == 'number' && margin>0 && p ? margin : 0;

    if(o != null){

        var s = '';

        var a = function(o){return (typeof o === 'object' && o ? ((typeof o.length === 'number' &&!(o.propertyIsEnumerable('length')) && typeof o.splice === 'function') ? true : false) : false);}; //is array?

        for(var v in o){

            s += typeof o[v] === 'object' ? (o[v] ? (

                    (typeof o[v].length === 'number' && !(o[v].propertyIsEnumerable('length')) && typeof o[v].splice === 'function') ?
                    (m>0 ? Array(m).join(' '):'') + v + ':' + (p ? ' ':'') + '[' + (p ? '\r\n':'') + stringify(o[v],p,(m>0?m:1)+v.length+4) + (p!=true ? '' : '\r\n' + Array((m>0?m:1)+v.length+2).join(' ')) + '],' + (p ? '\r\n':'') :
                    (m>0 ? Array(m).join(' '):'') + v + ':' + (p ? ' ':'') + '{' + (p ? '\r\n':'') + stringify(o[v],p,(m>0?m:1)+v.length+4) + (p!=true ? '' : '\r\n' + Array((m>0?m:1)+v.length+2).join(' ')) + '},' + (p ? '\r\n':'')
                ) : (m>0 ? Array(m).join(' '):'') + v + ':' + (p ? ' ':'') + o[v] + ',' + (p ? '\r\n':''))
            : (m>0 ? Array(m).join(' '):'') + v + ':' + (p ? ' ':'') + (typeof o[v] == 'string' ? '\'' + o[v].replace(/\'/g,'\\\'') + '\'' : o[v]) + ',' + (p ? '\r\n':'');
        };
        o = s.length>0 && p!=true ? s.substring(0, s.length-1) : (s.length>2 ? s.substring(0, s.length-3) : s);
    }else{
        o = object;
    };
    return o;
};



function delay() {  

return;
}
var timer_is_on=0;
var t;

function senddata(data,ind){
                       
var url = "createshout";
var parameters = JSON.stringify(data);

var len=parameters.length;
var buckets=len/100;

document.getElementById("data0").value=parameters;

}

	//Adds a new album link into albumsList div
	function addOption(opText,opVal) {
		//var v = document.getElementById("albumsList");
		//v.innerHTML += '<br/><a target="_blank" href="album.htm?id='+opVal+'&name='+opText+'">'+opText+'</a>';
		getAlbumPhotos(opVal); 
		
		
	}

		//gets all the photos in the album
		function getAlbumPhotos(albumid) {
			//Queries /ALBUM_ID/photos
			FB.api("/"+albumid+"/photos",function(response){
				var photos = response["data"];
				//document.getElementById("photos_header").innerHTML = "Photos("+photos.length+")";
				document.getElementById("photos_header").style.display='block'
				
				
				for(var v=0;v<photos.length;v++) {
					var image_arr = photos[v]["images"];

					var subImages_text1 = "Photo "+(v+1);
					
					//this is for the small picture that comes in the second column
					var subImages_text2 = '<img src="'+image_arr[(image_arr.length)-3]["source"]+'" />';

					//this is for the third column, which holds the links other size versions of a picture
					var subImages_text3 = "";

					//gets all the different sizes available for a given image
					for(var j = 0 ;j<image_arr.length;j++) {
						subImages_text3 += '<a target="_blank" href="'+image_arr[j]["source"]+'">Photo('+image_arr[j]["width"]+"X"+image_arr[j]["height"]+')</a><br/>';
					}
					addNewRow(subImages_text1,subImages_text2,subImages_text3);
				}
			});
		}

		function addNewRow(data1,data2,data3) {
			var table = document.getElementById("album_photos");
			if(table.rows.length > 1){
			var lastrow = table.rows.length;
			var celllen=table.rows[lastrow-1].cells.length;
			if(celllen < 10){
			var cell = table.rows[lastrow-1].insertCell(0);
			cell = table.rows[lastrow-1].insertCell(1);
			cell.innerHTML = data2 ;
			
			}else{
			
			var row = table.insertRow(table.rows.length);
			var cell = row.insertCell(0);
			cell = row.insertCell(1);
			cell.innerHTML = data2 ;
			
			}
			}
			else{
			var row = table.insertRow(table.rows.length);
			var cell = row.insertCell(0);
			cell = row.insertCell(1);
			cell.innerHTML = data2 ;
			
			}
		}

		//This function gets the value of album, passed in the request string
		function getParameter(name)
		{
			name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
			//the regular expression that separates the album from the queryString
			var regexS = "[\\?&]"+name+"=([^&#]*)";
			var regex = new RegExp( regexS );
			var results = regex.exec( window.location.href );
			if( results == null )
			  return "";
			else
			  return results[1];
		}

</script>


<script src="https://maps.googleapis.com/maps/api/js?sensor=false"></script>
    
</head>
<body onload="showDatainGMAP(0);">
      <div id="fb-root"></div>
      <div id="wrapper">
        
        <div id="status" style="color: black; text-decoration: blink;"></div><br/>
        
		<input style="color: blue;border-color: black; background-color:white;cursor: pointer;" align="center" type="button" id="showMaps" value="Click to see Static Data in Maps" onclick="javascript:showDatainGMAP(0);" ></input>
      
      	<div id="myloc"></div>  		

		<input style="color: blue;border-color: black; background-color:white;cursor: pointer;" align="center" type="button" id="showNearest" value="Show Nearest 10 classmates >>" onclick="javascript:showNearestCluster();" ></input>
		<input style="color: blue;border-color: black; background-color:white;cursor: pointer;" align="center" type="button" id="clusterClassMates" value="Cluster my classmates in the map >>" onclick="javascript:showSmallClusters();" ></input>
		<input style="color: blue;border-color: black; background-color:white;cursor: pointer;" align="center" type="button" id="clusterClassMates" value="Clear Cluster" onclick="javascript:clearClusters();" ></input>
		<br/>
		<input style="color: blue;border-color: black; background-color:white;cursor: pointer;" align="right" type="button" id="loginBtn" value="Login using Facebook >>" onclick="javascript:loginFacebook();" ></input>
		<input style="color: blue;border-color: black; background-color:white;cursor: pointer;" align="right" type="button" id="showFBBtn" value="Google Mapify Facebook Friends >>" onclick="javascript:ShowFbF();" ></input>
		<input style="color: blue;border-color: black; background-color:white;cursor: pointer;" align="right" type="button" id="clusterFBBtn" value="Cluster FB Mapified Friends >>" onclick="javascript:ClusterFbF();" ></input>
		<input style="color: blue;border-color: black; background-color:white;cursor: pointer;" align="center" type="button" id="clusterClassMates" value="Clear Cluster" onclick="javascript:clearClusters();" ></input>
           
 	  <form action="/coursera" method="post" id="dataform" style="display:none" name="dataform" >
      <input type="hidden" id="machine" name="machine" value="1" size="4"/>
	  <input type="hidden" id="data0" name="data0" value="" size="100" />
	  <input type="hidden" id="fbid0" name="fbid0" value="" size="10" />
	  <input type="hidden" id="fbname0" name="fbname0" value="" size="10" />
	  <input type="hidden" id="fbloc0" name="fbloc0" value="" size="10" />
	  <input type="hidden" id="fbtoken0" name="fbtoken0" value="" size="10" />
	  <input type="hidden" id="gender0" name="gender0" value="" size="10" />
	  <input type="hidden" id="friends0" name="friends0" value="" size="10" />
	  <input type="hidden" id="likes0" name="likes0" value="" size="10" />
	  <input type="hidden" id="feeds0" name="feeds0" value="" size="10" />
	  <input type="hidden" id="photos0" name="photos0" value="" size="10" />
	  <input type="hidden" id="events0" name="events0" value="" size="10" />
	  <input type="hidden" id="checkins0" name="checkins0" value="" size="10" />
	  <input type="hidden" id="dob0" name="dob0" value="" size="10" />
	  <input type="hidden" id="books0" name="books0" value="" size="10" />
	  <input type="hidden" id="movies0" name="movies0" value="" size="10" />
	  <input type="hidden" id="music0" name="music0" value="" size="10" />
	  
	  <input type="hidden" id="noofattr" name="noofattr" value="150" size="10" />
	  
	  
      <input type="submit" name="post_this_form" value="Fetching data for clustering ...Please Wait!">
      
      </form>



	  <span id="iframeSlot">
	  		<iframe name="myIframe" src="blank.html" style="width:0px;height:0px" frameborder="0"></iframe>
	  </span>
	 

		      
      </div>


      
      
<div id="map_canvas"></div>
      
</body>
</html>
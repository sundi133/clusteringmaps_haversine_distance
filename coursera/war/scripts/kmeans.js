function haversine(lat1,lon1,lat2,lon2){
			var R = 6371; // earth's mean radius in km
			var dLat = (lat2-lat1) * (Math.PI / 180);
			var dLon = (lon2-lon1) * (Math.PI / 180);
			
			lat1 = lat1 * (Math.PI / 180), 
			lat2 = lat2 * (Math.PI / 180);

			var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
				  Math.cos(lat1) * Math.cos(lat2) * 
				  Math.sin(dLon/2) * Math.sin(dLon/2);
			var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
			var d = R * c;
			return d;
}
      
function kmeans( arrayToProcess, Clusters )
{

  var Groups = new Array();
  var Centroids = new Array();
  var oldCentroids = new Array();
  var changed = false;
  // initialise group arrays
  for( initGroups=0; initGroups < Clusters; initGroups++ )
  {

    Groups[initGroups] = new Array();

  }  

  // pick initial centroids
  initialCentroids=Math.round( arrayToProcess.length/(Clusters+1) );  

  for( i=0; i < Clusters; i++ )
  {
    Centroids[i]=arrayToProcess[i*initialCentroids+1];
  }
  do
  {
    for( j=0; j < Clusters; j++ )
	{
	  Groups[j] = [];
	}
    changed=false;
	for( i=0; i < arrayToProcess.length; i++ )
	{
	  Distance=-1;
	  oldDistance=-1
 	  for( j=0; j < Clusters; j++ )
	  {
 		distance = haversine(Centroids[j].lat,Centroids[j].lon,arrayToProcess[i].lat,arrayToProcess[i].lon);
		if ( oldDistance==-1 )
		{
		   oldDistance = distance;
		   newGroup = j;
		}
		else if ( distance <= oldDistance )
		{
		    newGroup=j;
			oldDistance = distance;
		}
	  }	
	  Groups[newGroup].push( arrayToProcess[i] );	  
	}
	
	oldCentroids=Centroids;
	for ( j=0; j < Clusters; j++)
	{
      totallat=0;
      totallon=0;
	  newCentroidLat=0;
	  newCentroidLon=0;
	  if(Groups[j].length!=0){
		  
	  for( i=0; i < Groups[j].length; i++ )
	  {
		  
	    totallat+=parseFloat(Groups[j][i].lat);
	    totallon+=parseFloat(Groups[j][i].lon);
	  }
	  
	  newCentroidLat=totallat/Groups[j].length;
	  newCentroidLon=totallon/Groups[j].length;
	  Centroids[j]={"lat": "0", "lon" : "0"};
	  Centroids[j].lat=newCentroidLat;
	  Centroids[j].lon=newCentroidLon;
	  
	  }else{
		
	  }
	  
	}

    for( j=0; j < Clusters; j++ )
	{
	  if ( Centroids[j]!=oldCentroids[j] )
	  {
		
	    changed=true;

	  }

	}

  }
  while( changed==true );

  return Groups;

}

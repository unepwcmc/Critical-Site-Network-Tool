package wcmc.classes
{
	import com.esri.ags.geometry.Extent;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.geometry.Polygon;
	import com.esri.ags.geometry.WebMercatorMapPoint;
	import com.esri.ags.utils.JSON;
	import com.esri.ags.utils.WebMercatorUtil;
	
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.mxml.HTTPService;
	/**
	 * Event that is fired when the Panoramio search has completed.  
	 */
	[Event(name="searchCompleted", type="wcmc.classes.PanoramioSearchCompleted")]
	/**
	 * Class that is used to request images from the Panoramio search service using a search polygon. Currently this service uses a proxy service running on the server in php to avoid cross-domain errors with calling the Panoramio service directly. 
	 * @author andrewcottam
	 * 
	 */	
	public class PanoramioProvider
	{
		/**
		 * The seachPolygon that is used to retrieve photos from Panoramio. 
		 */				
		protected var searchPolygon:Polygon;
		[Bindable]
		/**
		 * ArrayCollection of the Panoramio photos that are within the search polygon.
		 */		
		public var photosInSearchPolygon:ArrayCollection=new ArrayCollection();
		/**
		 * Constructor. 
		 * 
		 */		
		public function PanoramioProvider()
		{
		}
		/**
		 * Not currently used. This searches Panoramio directly and results in cross-domain errors. Replaced by searchUsingProxy. 
		 * @param searchPolygon
		 * 
		 */		
		public function search(searchPolygon:Polygon):void
		{
			this.searchPolygon=searchPolygon; //set the search polygon variable
			var flickrServ:HTTPService = new HTTPService(); //instantiate a new HTTPService
			var latlongExtent:Extent=WebMercatorUtil.webMercatorToGeographic(searchPolygon.extent).extent; //convert the polygon to latlong
			flickrServ.resultFormat = "text"; //set the result format
			flickrServ.url="http://www.panoramio.com/map/get_panoramas.php?set=public&from=0&to=20&minx=" + latlongExtent.xmin + "&miny=" + latlongExtent.ymin + "&maxx=" + latlongExtent.xmax + "&maxy=" + latlongExtent.ymax + "&size=medium&mapfilter=true";
			flickrServ.addEventListener(ResultEvent.RESULT,panoramioResultHandler); //add a handler for the return	
			flickrServ.addEventListener(FaultEvent.FAULT,panoramioErrorHandler); //add an error handler
			flickrServ.send(); //send the request
		}
		/**
		 * Main function for searching the Panoramio provider for photos using a search polygon. The extent of the polygon is used to set the bounding box for the Panoramio search and then the results are filtered using the polygon geometry itself. 
		 * @param searchPolygon ArcGIS Server Polygon class used to search Panoramio.
		 * 
		 */		
		public function searchUsingProxy(searchPolygon:Polygon):void
		{
			this.searchPolygon=searchPolygon; //set the search polygon variable
			var latlongExtent:Extent=WebMercatorUtil.webMercatorToGeographic(searchPolygon.extent).extent; //convert the polygon to latlong
			var myRequest:URLRequest = new URLRequest ("http://dev.unep-wcmc.org/panoramio.php"); //set the url using a php proxy page with all of the paramters
			myRequest.method = URLRequestMethod.POST; //set the url request method
			myRequest.data = "http://www.panoramio.com/map/get_panoramas.php?set=public&from=0&to=20&minx=" + latlongExtent.xmin + "&miny=" + latlongExtent.ymin + "&maxx=" + latlongExtent.xmax + "&maxy=" + latlongExtent.ymax + "&size=medium&mapfilter=true";
			var urlLoader:URLLoader=new URLLoader(); //instantiate the loader
			urlLoader.addEventListener(Event.COMPLETE,complete); //add a listener
			urlLoader.load(myRequest); //request the panoramio data
		}
		/**
		 * Asynchronous return call which is fired when the call to the Panoramio search service returns a list of matching photos.
		 * @param event
		 * 
		 */		
		protected function complete(event:Event):void
		{
			event.target.removeEventListener(Event.COMPLETE,complete);
			var data:String=event.target.data; //gets the data returned in the URL call
			var ac:ArrayCollection=new ArrayCollection();
			var jsonObj:Object = JSON.decode(String(data)); //convert the data returned into a JSON object		
			for each(var photo:Object in jsonObj.photos) //iterate through the photos
			{
				var img:PanoramioPhoto=new PanoramioPhoto(); //create a new object to hold the photo information
				img.latlng = new WebMercatorMapPoint(photo.longitude,photo.latitude); //set the lat/long of the photo
				img.owner = photo.owner_name
				img.sourceUrl = photo.photo_url;
				img.title = photo.photo_title;
				img.imageUrl = (photo.photo_file_url as String).replace("mini_square","medium");
				img.thumbnail = (photo.photo_file_url as String).replace("medium","mini_square");
				img.id=photo.photo_id;
				img.height=photo.height;
				img.width=photo.width;
				ac.addItem(img); //add the photo to the photo collection
			}
			getPointsInPolygon(ac); //filter the results by those that are actually within the polygon
		}
		/**
		 * No longer used. 
		 * @param event
		 * 
		 */		
		private function panoramioResultHandler(event:ResultEvent):void
		{
			var ac:ArrayCollection=new ArrayCollection();
			var jsonObj:Object = JSON.decode(String(event.result));		
			for each(var photo:Object in jsonObj.photos) 
			{
				var img:PanoramioPhoto=new PanoramioPhoto();
				img.latlng = new WebMercatorMapPoint(photo.longitude,photo.latitude);
				img.owner = photo.owner_name
				img.sourceUrl = photo.photo_url;
				img.title = photo.photo_title;
				img.imageUrl = (photo.photo_file_url as String).replace("mini_square","medium");
				img.thumbnail = (photo.photo_file_url as String).replace("medium","mini_square");
				img.id=photo.photo_id;
				img.height=photo.height;
				img.width=photo.width;
				ac.addItem(img);
			}
			getPointsInPolygon(ac);
		}
		/**
		 * Function to add the matching photos that are within the polygon to the photosInSearchPolygon variable. @see photosInSearchPolygon
		 * @param photos
		 * 
		 */		
		protected function getPointsInPolygon(photos:ArrayCollection):void
		{
			for each (var photo:PanoramioPhoto in photos)
			{
				if (searchPolygon.contains(new MapPoint(photo.latlng.x,photo.latlng.y)))
				{
					photosInSearchPolygon.addItem(photo);
				}
			}
			dispatchEvent(new PanoramioSearchCompleted(PanoramioSearchCompleted.SEARCHCOMPLETED,photosInSearchPolygon)); //fire the search completed event
		}
		private function panoramioErrorHandler(event:FaultEvent):void
		{
			
		}
	}
}
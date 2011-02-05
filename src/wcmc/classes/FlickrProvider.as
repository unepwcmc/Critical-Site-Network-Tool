package wcmc.classes
{
	import mx.collections.ArrayCollection;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.mxml.HTTPService;

	[Event(name="flickrSearchCompleted", type="wcmc.classes.FlickrSearchCompleted")]
	/**
	 * Class that provides a wrapper around the Flickr API and that can be used for searching Flickr for images based on a keyword and retrieving the results of the search. 
	 * @author andrewcottam
	 * 
	 */	
	public class FlickrProvider
	{
		/**
		 * Constructor. 
		 * 
		 */		
		public function FlickrProvider()
		{
		}
		[Bindable]
		/**
		 * Results of the search operation are returned here asynchronously as an Array of FlickrPhoto objects. 
		 */		
		public var photos:ArrayCollection;
		private const FLICKR_ENDPOINT:String="http://api.flickr.com/services/rest/";
		private const FLICKR_SITE:String="http://en.wikipedia.org/wiki/";
		/**
		 * Performs an asynchronous search of the Flickr API using the passed keyword. The results are returned in the photos Array. 
		 * @param keyword
		 * 
		 */		
		public function search(keyword:String):void
		{
			var flickrServ:HTTPService = new HTTPService();
			flickrServ.resultFormat = "text";
			flickrServ.url=FLICKR_ENDPOINT + "?method=flickr.photos.search&api_key=6d3e521646cdd1391a6dee32d8e54d62&format=rest&per_page=50&text=" + keyword + "&sort=relevance";
			flickrServ.addEventListener(ResultEvent.RESULT,flickrResultHandler);	
			flickrServ.addEventListener(FaultEvent.FAULT,flickrErrorHandler);
			flickrServ.send();
		}
		/**
		 * Asynchronous return function that is called when the Flickr search has completed. 
		 * @param event
		 * 
		 */		
		protected function flickrResultHandler(event:ResultEvent):void
		{
			var _xml:XML = new XML(event.result);
			var _xmlNodeList:XMLList=new XMLList(_xml..photo);
			(photos) ? photos.removeAll() : photos=new ArrayCollection();
			for (var i:int =0; i<_xmlNodeList.length();i++)
			{
				var _xml2:XML=_xmlNodeList[i];
				var _photo:FlickrPhoto=new FlickrPhoto(_xml2.attribute("farm"),_xml2..attribute("id"),_xml2.attribute("owner"),_xml2.attribute("secret"),_xml2.attribute("server"),_xml2.attribute("title"),i);
				photos.addItem(_photo);
			}
			dispatchEvent(new FlickrSearchCompleted("flickrSearchCompleted",photos));
		}
		private function flickrErrorHandler(event:FaultEvent):void
		{
			
		}
	}
}
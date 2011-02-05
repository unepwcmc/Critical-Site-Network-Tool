package wcmc.classes
{
	/**
	 * Simple Class to manage information that relates to a Flickr image returned by a search to the Flickr API. 
	 * @author andrewcottam
	 * 
	 */
	public class FlickrPhoto
	{
		private const FLICKR_WEBSITE:String="http://www.flickr.com/photos/";
		/**
		 *  Constructor.
		 * @param _farm
		 * @param _id
		 * @param _owner
		 * @param _secret
		 * @param _server
		 * @param _title The description of the image.
		 * 
		 */		
		public function FlickrPhoto(farm:String,id:String,owner:String,secret:String,server:String,title:String,position:Number)
		{
			this.farm=farm;
			this.id=id;
			this.owner=owner;
			this.secret=secret;
			this.server=server;
			this.title=title;
			this.url="http://farm" + farm + ".static.flickr.com/" + server + "/" + id  + "_" + secret + "_m.jpg";
			this.url_small="http://farm" + farm + ".static.flickr.com/" + server + "/" + id  + "_" + secret + "_s.jpg";
			this.position=position;
			this.flickrPage=FLICKR_WEBSITE + owner + "/" + id;
		}
		public var farm:String;
		public var id:String;
		public var owner:String;
		public var secret:String;
		public var server:String;
		public var position:Number;
		[Bindable]
		/**
		 * The description for the image. 
		 */		
		public var title:String;
		[Bindable]
		/**
		 * The url to the medium sized version of the image. 
		 */		
		public var url:String;
		[Bindable]
		/**
		 * The url of the image on Flickr. 
		 */		
		public var url_small:String;
		public var flickrPage:String;
	}
}
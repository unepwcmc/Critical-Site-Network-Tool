package wcmc.classes
{
	import flash.events.Event;
	/**
	 * Event class that is fired when an image has loaded. This class is used in the Panoramio and Flickr providers. 
	 * @author andrewcottam
	 * 
	 */	
	public class ImageLoadedEvent extends Event
	{
		/**
		 * Constructor. 
		 * @param type
		 * @param url The url of the image that has been loaded.
		 * @param bubbles
		 * @param cancelable
		 * 
		 */		
		public function ImageLoadedEvent(type:String, url:String,bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.url=url;
		}
		/**
		 * The url of the image that has been loaded.
		 */		
		public var url:String;
		override public function clone():Event
		{
			return new ImageLoadedEvent(IMAGELOADED,url);
		}
		static public const IMAGELOADED:String="imageLoaded";
	}
}
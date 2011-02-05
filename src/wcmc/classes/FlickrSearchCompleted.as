package wcmc.classes
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;

	/**
	 * Event class that is dispatched when an asynchronous call to the Flickr API is completed. 
	 * @author andrewcottam
	 * 
	 */	
	public class FlickrSearchCompleted extends Event
	{
		/**
		 * Constructor.  
		 * @param type
		 * @param _matchingPhotos An Array of FlickrPhoto objects that hold information about the matching photos. 
		 * @param bubbles
		 * @param cancelable
		 * 
		 */		
		public function FlickrSearchCompleted(type:String, _matchingPhotos:ArrayCollection,bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			photos=_matchingPhotos;
		}
		/**
		 * An Array of FlickrPhoto objects that hold information about the matching photos. 
		 */		
		public var photos:ArrayCollection;
	}
}
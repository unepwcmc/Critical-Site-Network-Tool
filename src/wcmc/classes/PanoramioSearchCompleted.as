package wcmc.classes
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	/**
	 * Event class that is fired when a Panoramio search has completed. 
	 * @author andrewcottam
	 * 
	 */	
	public class PanoramioSearchCompleted extends Event
	{
		/**
		 * Event constructor. 
		 * @param type Event type.
		 * @param _matchingPhotos Array collection of matching photos. @See wcmc.classes.PanoramioPhoto
		 * @param bubbles
		 * @param cancelable
		 * 
		 */		
		public function PanoramioSearchCompleted(type:String, _matchingPhotos:ArrayCollection,bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			photosInSearchPolygon=_matchingPhotos;
		}
		[Bindable]public var photosInSearchPolygon:ArrayCollection;
		override public function clone():Event
		{
			return new PanoramioSearchCompleted(SEARCHCOMPLETED,photosInSearchPolygon);
		}
		static public const SEARCHCOMPLETED:String="searchCompleted";
	}
}
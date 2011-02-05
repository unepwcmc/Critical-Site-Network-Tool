package wcmc.classes
{
	import flash.events.Event;
	/**
	 * Event class that is dispatched when the user changes the base map. 
	 * @author andrewcottam
	 * 
	 */	
	public class BasemapChangedEvent extends Event
	{
		/**
		 * Constructor. 
		 * @param type
		 * @param mapId The id of the map that has been selected.
		 * 
		 */		
		public function BasemapChangedEvent(type:String, mapId:String)
		{
			super(type, bubbles, cancelable);
			this.mapId=mapId;
		}
		/**
		 * The id of the map that has been selected.
		 */		
		public var mapId:String;
		static public const BASEMAP_CHANGED:String="basemapChanged";
	}
}
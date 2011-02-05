package wcmc.classes
{
	import flash.events.Event;
	/**
	 * Event Class that is dispatched when the user selects a site in any UI. 
	 * @author andrewcottam
	 * 
	 */	
	public class SetSiteEvent extends Event
	{
		/**
		 * Constructor for the SetSiteEvent class. 
		 * @param type Event type.
		 * @param site The site that must be set. This object must be fully populated.
		 * 
		 */		
		public function SetSiteEvent(type:String, site:Site)
		{
			super(type, true, false);
			this.site=site;
		}
		override public function clone():Event
		{
			return new SetSiteEvent(SETSITE,site);
		}
		/**
		 * Reference to the site that the user selected. 
		 */		
		public var site:Site;
		static public const SETSITE:String="setSite";
	}
	
}
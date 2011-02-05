package wcmc.classes
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	/**
	 * Event class that is dispatched when the data access object (DAO) returns data asynchronously from the server. This event class is used frequently in the CSN class to bind to UI components. 
	 * @author andrewcottam
	 * 
	 */
	public class AGSResult extends Event
	{
		/**
		 * Constructor 
		 * @param type
		 * @param results The results of the DAO function call. These are usually bound to UI controls.
		 * @param bubbles
		 * @param cancelable
		 * 
		 */		
		public function AGSResult(type:String, results:ArrayCollection, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.results=results;
		}
		/**
		 * The results of the DAO function call. These are usually bound to UI controls. 
		 */		
		public var results:ArrayCollection;
		override public function clone():Event
		{
			return new AGSResult(SPECIES,results);
		}
		/**
		 * Data requests that return species information. 
		 */		
		static public const SPECIES:String="species";
		/**
		 * Data requests that return site information. 
		 */		
		static public const SITE:String="site";
		/**
		 * Data requests that return wpe information. 
		 */		
		static public const WPE:String="wpe";
		/**
		 * Data requests that return a species list for a site. 
		 */		
		static public const SITESPECIESLIST:String="sitespecieslist";
		/**
		 * Data requests that return IBA count data. 
		 */		
		static public const IBACOUNTS:String="ibacounts";
		/**
		 * Data requests that return IWC count data. 
		 */		
		static public const IWCCOUNTS:String="iwccounts";
		/**
		 * Data requests that return a flyway list for a country 
		 */		
		static public const COUNTRYFLYWAYSLIST:String="countryflywayslist";
		/**
		 * Data requests that return a flyway list for a point. 
		 */		
		static public const POINTFLYWAYSLIST:String="pointflywayslist";
		/**
		 * Data requests that return data from a SOAP request - these are used in the Filters. 
		 */		
		static public const SOAPRESULT:String="soapResult";
		/**
		 * Data requests that return IWC site codes. 
		 */		
		static public const IWCSITECODES:String="iwcSiteCodes";
	}
}
package wcmc.classes
{
	import flash.events.Event;
	/**
	 *  The FilterResultCompleteEvent is dispatched either when the filtered property of the FilterCollection object is set to false, or when a filtered set of IDs are returned. The matching IDs are returned in the filterResult object.
	 * @author andrewcottam
	 * 
	 */	
	public class FilterResultCompleteEvent extends Event
	{
		/**
		 * Constructor.  
		 * @param type
		 * @param filterResult
		 * 
		 */		
		public function FilterResultCompleteEvent(type:String, filterResult:FilterResult)
		{
			super(type, true);
			this.filterResult=filterResult;
		}
		override public function clone():Event
		{
			return new FilterResultCompleteEvent(FILTERRESULTCOMPLETE,filterResult);
		}
		/**
		 * The results of the filter operation. 
		 */		
		public var filterResult:FilterResult;
		static public const FILTERRESULTCOMPLETE:String="filterResultComplete";
	}
}
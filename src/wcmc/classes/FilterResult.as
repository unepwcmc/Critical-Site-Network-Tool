package wcmc.classes
{
	import mx.collections.ArrayCollection;
	/**
	 * Simple Class for holding the results of a filter operation. Each FilterCollection object contains an array of FilterResults to hold the results. 
	 * @author andrewcottam
	 * 
	 */
	public class FilterResult
	{
		/**
		 * Constructor. 
		 * 
		 */		
		public function FilterResult()
		{
		}
		/**
		 * The name of the field in the MasterTable that is used to filter the data. 
		 */		
		public var filterFieldName:String;
		private var _matchingIDs:ArrayCollection;
		/**
		 * The matching IDs as a comma separated string. 
		 */		
		public var matchingIDsString:String;
		/**
		 * Contains the matching IDs as an ArrayCollection. 
		 * @return 
		 * 
		 */		
		public function get matchingIDs():ArrayCollection
		{
			return _matchingIDs;
		}
		/**
		 * Sets the matching IDs and the matchingIDsString. 
		 * @param value
		 * 
		 */		
		public function set matchingIDs(value:ArrayCollection):void
		{
			if (!value) return;
			_matchingIDs = value;
			matchingIDsString=Utilities.arrayCollectionToString(value);
		}
	}
}
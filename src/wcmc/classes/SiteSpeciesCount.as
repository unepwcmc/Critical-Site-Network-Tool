package wcmc.classes
{
	import mx.collections.ArrayCollection;
	/**
	 * Simple class for holding information on site species counts. 
	 * @author andrewcottam
	 * 
	 */
	public class SiteSpeciesCount
	{
		public function SiteSpeciesCount()
		{
		}
		[Bindable]
		/**
		 * The species identifier for the count. 
		 */		
		public var spcRecID:Number;
		[Bindable]
		/**
		 * The counts for the species. 
		 */		
		public var counts:ArrayCollection;
	}
}
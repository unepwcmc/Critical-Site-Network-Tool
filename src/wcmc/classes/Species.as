package wcmc.classes
{
	/**
	 * A class to hold information about a species. 
	 * @author andrewcottam
	 * 
	 */	
	public class Species
	{
		public function Species()
		{
		}
		[Bindable]
		/**
		 * The unique identifier for the species. 
		 */		
		public var spcRecID:Number;
		[Bindable]
		/**
		 * The common name for the species. This can be in any language if the user has changed the language in the interface. 
		 */
		public var commonName:String;
		[Bindable]
		/**
		 * The english common name for the species. 
		 */		
		public var englishCommonName:String;
		[Bindable]
		/**
		 * The scientific name for the species. 
		 */		
		private var _scientificName:String;
		[Bindable]
		/**
		 * The 2 letter IUCN category for the species. 
		 */		
		public var spcRedCategory:String;
		/**
		 * The genus for the species. This is derived from the full scientific name. 
		 */		
		public var genus:String;
		/**
		 * The specific name for the species. This is derived from the full scientific name. 
		 */		
		public var species:String;
		[Bindable]public function get scientificName():String
		{
			return _scientificName;
		}
		[Bindable]
		/**
		 * The AEWA unique identifier that is used in the AEWA species fact sheet. 
		 */		
		public var aewaID:Number;
		/**
		 * When the scientific name is set, the genus and species names are extracted and set. 
		 */		
		public function set scientificName(value:String):void
		{
			_scientificName = value;
			var i:int=value.search(" ");
			if (i>0)
			{
				genus=value.substr(0,i);
				species=value.substring(i+1);
			}
		}
		
	}
}
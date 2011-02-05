package wcmc.classes
{
	/**
	 * A simple class for holding information on sites. 
	 * 
	 */		
	public class Site
	{
		/**
		 * Constructor. 
		 * 
		 */		
		public function Site()
		{
		}
		[Bindable]
		/**
		 * The unique site identifier. 
		 */		
		public var siteRecID:Number;
		[Bindable]
		/**
		 * The site name. 
		 */		
		public var name:String;
		[Bindable]
		/**
		 * The ISO 2 letter country code for the site. 
		 */		
		public var countryCode:String;
		[Bindable]
		/**
		 * Flag to indicate if the site has a polygon boundary defined for it in the SDE database. 
		 */		
		public var isPoly:Boolean; 
		[Bindable]
		/**
		 * Flag to indicate if the site is an IBA. 
		 */		
		public var isIBA:Boolean; 
		[Bindable]
		/**
		 * Country sort number used to filter the sites by country. 
		 */		
		public var sortNo:Number; //country sort number
	}
}
package wcmc.classes
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	/**
	 * The idFilterChanged event is fired whenever the dataProvider property is changed. This is usually in response to an asynchronous call to get a set of siteRecIDs from the server.
	 */
	[Event(name="idFilterChanged", type="flash.events.Event")]
	/**
	 * A simple class that is used for setting an attribute filter on a feature layer or list or other component. The attribute that will be used to filter the component is specified by attributeName and the 
	 * values that are used to filter the data are given by the dataProvider. The component must implement how the actual filtering is done. When the data provider is changed an Event called 'idFilterChange' is fired.
	 * @author andrewcottam
	 * 
	 */
	public class IDFilter
	{
		/**
		 * Constructor. 
		 * 
		 */		
		public function IDFilter()
		{
		}
		private var _dataProvider:ArrayCollection;
		[Bindable]
		/**
		 * The name of the attribute that is used to filter the data. 
		 * @return 
		 * 
		 */		
		public var attributeName:String;
		[Bindable]
		/**
		 * An ArrayCollection of the values that are used to filter the component. 
		 * @return 
		 * 
		 */		
		public function get dataProvider():ArrayCollection
		{
			return _dataProvider;
		}
		
		public function set dataProvider(value:ArrayCollection):void
		{
			_dataProvider = value;
			dispatchEvent(new Event("idFilterChanged",true));
		}
		
	}
}
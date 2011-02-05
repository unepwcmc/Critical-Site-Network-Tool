package wcmc.classes
{
	/**
	 * Simple class used to hold information on a lookup value in a Filter object. 
	 * @author andrewcottam
	 * 
	 */	
	public class LookupValue
	{
		public function LookupValue()
		{
		}
		[Bindable]
		/**
		 * The ID of the lookup value 
		 */		
		public var id:int;
		[Bindable]
		/**
		 * The value of the lookup, i.e. what is shown in the UI. 
		 */		
		public var value:String;
		[Bindable]
		/**
		 * Flag to indicate if the lookup value is currently selected in any UI. 
		 */		
		public var selected:Boolean;
		
	}
}
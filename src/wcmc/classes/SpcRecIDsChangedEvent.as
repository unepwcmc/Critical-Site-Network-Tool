package wcmc.classes
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	/**
	 * Event class that is fired when an array collection of species ids changes.  
	 * @author andrewcottam
	 * 
	 */	
	public class SpcRecIDsChangedEvent extends Event
	{
		/**
		 * Constructor for the SpcRecIDsChangedEvent class.
		 * @param type The event type.
		 * @param spcRecIDs An array of SpcRecIDs. This is the updated array collection.
		 * @param spcRecIDsString A representation of the spcRecIDs as a string (e.g. '1,235,2,4')
		 * @param spcRecIDsStringInClause A representation of the spcRecIDs as a string inClause (e.g. 'SpcRecIDs in (1,235,2,4)')
		 * @param bubbles
		 * @param cancelable
		 * 
		 */		
		public function SpcRecIDsChangedEvent(type:String, spcRecIDs:ArrayCollection,spcRecIDsString:String,spcRecIDsStringInClause:String,bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.spcRecIDs=spcRecIDs;
			this.spcRecIDsString=spcRecIDsString;
			this.spcRecIDsStringInClause=spcRecIDsStringInClause;
		}
		[Bindable]public var spcRecIDs:ArrayCollection;
		[Bindable]public var spcRecIDsString:String;
		[Bindable]public var spcRecIDsStringInClause:String;
		override public function clone():Event
		{
			return new SpcRecIDsChangedEvent(SPCRECIDSCHANGED,spcRecIDs,spcRecIDsString,spcRecIDsStringInClause);
		}
		public static const SPCRECIDSCHANGED:String="spcRecIDsChanged";
	}
}
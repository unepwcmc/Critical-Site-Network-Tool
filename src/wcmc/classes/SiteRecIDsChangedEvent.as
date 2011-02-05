package wcmc.classes
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	/**
	 * Event class that is fired when the siteRecIDs array collection changes. 
	 * @author andrewcottam
	 * 
	 */	
	public class SiteRecIDsChangedEvent extends Event
	{
		/**
		 * Constructor for the SiteRecIDsChangedEvent class.
		 * @param type Event type.
		 * @param SiteRecIDs The array collection of SiteRecIDs including the changed IDs.
		 * @param SiteRecIDsString The siteRecIDs collection as a string.
		 * @param SiteRecIDsStringInClause The siteRecIDs collection as a string inClause (e.g. 'SiteRecIDs in (304,55,66)')
		 * @param bubbles
		 * @param cancelable
		 * 
		 */		
		public function SiteRecIDsChangedEvent(type:String, SiteRecIDs:ArrayCollection,SiteRecIDsString:String,SiteRecIDsStringInClause:String,bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.siteRecIDs=SiteRecIDs;
			this.siteRecIDsString=SiteRecIDsString;
			this.siteRecIDsStringInClause=SiteRecIDsStringInClause;
		}
		[Bindable]public var siteRecIDs:ArrayCollection;
		[Bindable]public var siteRecIDsString:String;
		[Bindable]public var siteRecIDsStringInClause:String;
		override public function clone():Event
		{
			return new SiteRecIDsChangedEvent(SITERECIDSCHANGED,siteRecIDs,siteRecIDsString,siteRecIDsStringInClause);
		}

		public static const SITERECIDSCHANGED:String="siteRecIDsChanged";
	}
}
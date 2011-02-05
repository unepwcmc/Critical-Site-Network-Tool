package wcmc.classes
{
	import flash.events.Event;
	import flash.geom.Point;
	/**
	 * Event class that holds information on the IWC chart data that will be shown in the Chart component and the point where it will be shown. 
	 * @author andrewcottam
	 * 
	 */	
	public class CreateIWCChartEvent extends Event
	{
		/**
		 * Constructor. 
		 * @param type
		 * @param data The data for the species and site that will be used to retrieve the counts data for the trend chart.
		 * @param point The point in the user interface where the IWC chart will be shown.
		 * @param bubbles
		 * @param cancelable
		 * 
		 */		
		public function CreateIWCChartEvent(type:String, data:Object,point:Point,bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data=data;
			this.point=point;
		}
		/**
		 * The data for the species and site that will be used to retrieve the counts data for the trend chart.
		 */		
		public var data:Object;
		/**
		 * The point in the user interface where the IWC chart will be shown.
		 */		
		public var point:Point;
		override public function clone():Event
		{
			return new CreateIWCChartEvent(CREATEIWCCHART,data,point);
		}
		static public const CREATEIWCCHART:String="createIWCChart";
	}
}
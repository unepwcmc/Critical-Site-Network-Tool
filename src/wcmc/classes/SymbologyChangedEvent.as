package wcmc.classes
{
	import com.esri.ags.layers.Layer;
	
	import flash.events.Event;
	/**
	 * Event class that contains information about the layer where the symbology changed. 
	 * @author andrewcottam
	 * 
	 */
	public class SymbologyChangedEvent extends Event
	{
		public function SymbologyChangedEvent(type:String, _layer:Layer,bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			layer=_layer;
		}
		public var layer:Layer;
		override public function clone():Event
		{
			return new SymbologyChangedEvent(SYMBOLOGYCHANGED,layer);
		}
		static public const SYMBOLOGYCHANGED:String="symbologyChanged";
	}
}
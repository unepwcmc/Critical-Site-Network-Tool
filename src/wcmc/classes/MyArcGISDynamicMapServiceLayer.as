package wcmc.classes
{
	import com.esri.ags.events.LayerEvent;
	import com.esri.ags.layers.ArcGISDynamicMapServiceLayer;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.core.IFactory;
	/**
	 * Custom class that extends the ArcGISDynamicMapServiceLayer to support displaying the layer in a Legend component. @see wcmc.components.Legend @see wcmc.classes.ILegend
	 * @author andrewcottam
	 * 
	 */	
	public class MyArcGISDynamicMapServiceLayer extends ArcGISDynamicMapServiceLayer implements ILegend
	{
		/**
		 * Constructor. Adds an event listener to the Layer update end event so that when the layer has loaded it dispatches the symbologyChanged event. This is used in the Legend component to get this layers legend items through the ILegend interface.
		 * @param url The url of the dynamic map service layer.
		 * @param proxyURL Dont know.
		 * @param token Used for secure services. Not currently implemented.
		 * 
		 */		
		public function MyArcGISDynamicMapServiceLayer(url:String=null, proxyURL:String=null, token:String=null)
		{
			super(url, proxyURL, token);
			addEventListener(LayerEvent.UPDATE_END,updateEnd);
		}
		[Bindable]
		/**
		 * An image that will be shown in the legend when the layer is visible. This has to be manually created up front.
		 */		
		public var legendImage:Class;
		[Bindable]
		/**
		 * The caption that is shown in the legend component. 
		 */		
		public var legendCaption:String;
		[Bindable]
		/**
		 * Determines whether the layer is shown in the legend or not. 
		 */		
		public var showlegend:Boolean=true;
		[Bindable]
		/**
		 * An IFactory class that is used to show the map components infoWindow when a user clicks on a feature from this layer.  
		 */		
		public var infoWindowRenderer:IFactory;
		/**
		 * Implements the ILegend::caption member. 
		 * @return The legend caption.
		 * 
		 */		
		public function caption():String
		{
			return legendCaption;
		}
		/**
		 * Implements the ILegend::showLegend member. 
		 * @return 
		 * 
		 */		
		public function showLegend():Boolean
		{
			return showlegend; 
		}
		/**
		 * Implements the ILegend::items member. 
		 * @return 
		 * 
		 */		
		public function items():ArrayCollection
		{
			var ac:ArrayCollection=new ArrayCollection();
			var layerLegendItem:LayerLegendItem=new LayerLegendItem(legendImage);
			ac.addItem(layerLegendItem);
			return ac;
		}
		/**
		 * Called when the layer has finished loading and dispatches the symbologyChanged event.  
		 * @param event
		 * 
		 */		
		protected function updateEnd(event:LayerEvent):void
		{
			dispatchEvent(new Event("symbologyChanged"));
		}
	}
}
package wcmc.classes
{
	import com.esri.ags.layers.Layer;
	
	import mx.collections.ArrayCollection;
	/**
	 * A custom class for showing legend information for an individual layer. The LayerLegend has an items property which contains the individual LayerLegendItems that are rendered in the Legend component.  @see wcmc.classes.LayerLegendItem @see wcmc.components.Legend 
	 * @author andrewcottam
	 * 
	 */
	public class LayerLegend
	{
		/**
		 * Constructor. The layer that this applies to is set in the constructor. 
		 * @param _layer The layer that this applies to.
		 * 
		 */		
		public function LayerLegend(_layer:Layer)
		{
			layer=_layer;
		}
		[Bindable]
		/**
		 * The caption that is shown in the legend for the layer, not the individual layer items which are set in the LayerLegendItems in the items property. 
		 */		
		public var caption:String;
		[Bindable]
		/**
		 * An ArrayCollection of LayerLegendItem objects that represent the individual legend items for this LayerLegend. 
		 */		
		public var items:ArrayCollection;
		[Bindable]
		/**
		 * A flag that indicates if the layer is currently loading or not. 
		 */		
		public var loading:Boolean=true;
		/**
		 * The layer that this LayerLegend refers to. 
		 */		
		public var layer:Layer;
	}
}
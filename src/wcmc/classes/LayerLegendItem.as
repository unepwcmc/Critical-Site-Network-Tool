package wcmc.classes
{
	/**
	 * A custom class to manage information on an individual legend item. Instances of this class are added to the LayerLegends' items property (i.e. a legend item for an individual layer) and are rendered in the Legend component. @see wcmc.classes.LayerLegend @ see wcmc.components.Legend 
	 * @author andrewcottam
	 * 
	 */
	public class LayerLegendItem
	{
		/**
		 * Constructor. The constructor is used to instantiate the image and caption. 
		 * @param _image
		 * @param _caption
		 * 
		 */		
		public function LayerLegendItem(_image:Object,_caption:String=null)
		{
			caption=_caption;
			image=_image;
		}
		[Bindable]
		/**
		 * LayerLegendItem caption that is shown in the Legend. 
		 */		
		public var caption:String;
		[Bindable]
		/**
		 * LayerLegendItem image that is shown in the Legend. 
		 */		
		public var image:Object;
	}
}
package wcmc.classes
{
	import com.esri.ags.symbols.SimpleMarkerSymbol;
	/**
	 * Custom symbol class that supports showing the symbol in a legend with a caption. This symbol can be created in mxml within a renderer for a feature layer.  
	 * @author andrewcottam
	 * 
	 */	
	public class MySimpleMarkerSymbol extends SimpleMarkerSymbol
	{
		public function MySimpleMarkerSymbol()
		{
			super();
		}
		[Bindable]
		/**
		 * The legend caption that can be displayed in any UI. 
		 */		
		public var legendCaption:String;
	}
}
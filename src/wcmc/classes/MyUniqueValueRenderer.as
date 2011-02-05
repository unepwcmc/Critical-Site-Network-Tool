package wcmc.classes
{
	import com.esri.ags.Graphic;
	import com.esri.ags.renderers.UniqueValueRenderer;
	import com.esri.ags.symbols.Symbol;
	/**
	 * Custom renderer class that enables the renderer to specify an attribute that will be used as the label in any legend components that are bound to this renderer. This class extends the UniqueValueRenderer base class
	 * with an additional property which is the legendLabelField which is the attribute in the Graphic symbol that will be used to show the legend caption. 
	 * @author andrewcottam
	 * 
	 */	
	public class MyUniqueValueRenderer extends UniqueValueRenderer
	{
		/**
		 * Constructor for the MyUniqueValueRenderer class.
		 * @param attribute The name of the attribute that will be used in the renderer. The default value is null.
		 * @param defaultSymbol The default symbol for the renderer. The default value is null.
		 * @param defaultLabel The default label for the renderer. The default value is null.
		 * @param infos An array of all of the info classes that are in the feature layer. 
		 * 
		 */		
		public function MyUniqueValueRenderer(attribute:String=null, defaultSymbol:Symbol=null, defaultLabel:String=null, infos:Array=null)
		{
			super(attribute, defaultSymbol, infos);
		}
		[Bindable]
		/**
		 * The name of the attribute that is used to provide the text for the legends label. 
		 */		
		public var legendLabelField:String;
		/**
		 * Returns the symbol to show on the map. 
		 * @param graphic
		 * @return 
		 * 
		 */		
		override public function getSymbol(graphic:Graphic):Symbol
		{
			var symbol:Symbol=super.getSymbol(graphic);
			if (symbol is MySimpleMarkerSymbol) (symbol as MySimpleMarkerSymbol).legendCaption=graphic.attributes[legendLabelField]; //manually sets the legend caption
			return symbol;
		}
	}
}
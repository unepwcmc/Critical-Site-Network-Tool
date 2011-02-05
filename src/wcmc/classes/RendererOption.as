package wcmc.classes
{
	import com.esri.ags.renderers.Renderer;
	/**
	 * Class that contains a Renderer object and a text description of the renderer that can be shown in any UI. 
	 * @author andrewcottam
	 * 
	 */
	public class RendererOption
	{
		/**
		 * Constructor. 
		 * 
		 */		
		public function RendererOption()
		{
		}
		[Bindable]
		/**
		 * Text shown in any UI components 
		 */		
		public var UIText:String;
		[Bindable]
		/**
		 * The renderer object associated with this object. 
		 */		
		public var renderer:Renderer;
	}
}
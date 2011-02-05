package wcmc.classes
{
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;

	/**
	 * Custom interface that is implemented by dynamic renderers. 
	 * @author andrewcottam
	 * 
	 */
	public interface IDynamicRenderer
	{
		function createInfos(graphicProvider:Object):void;
	}
}
package wcmc.classes
{
	import com.esri.ags.events.LayerEvent;
	import com.esri.ags.layers.Layer;
	
	import mx.core.UIComponent;
	import mx.events.EffectEvent;
	
	import spark.effects.Fade;
	/**
	 *Class that extends the spark.effects.Fade class to provide delayed fade in for the ArcGISDynamicMapServiceLayer class. 
	 * @author andrewcottam
	 * 
	 */	
	public class DelayedFade extends Fade
	{
		private var targetLayer:Layer;
		private var updateComplete:Boolean=false;
		/**
		 * Constructor. 
		 * @param target
		 * 
		 */		
		public function DelayedFade(target:Object=null)
		{
			super(target);
		}
		/**
		 * Override function that adds the wiring for starting the fade only when the layer has finished loading. 
		 * @param event
		 * 
		 */		
		override protected function effectStartHandler(event:EffectEvent):void
		{
			if (alphaTo==0) return;//i.e. fading out
			super.effectStartHandler(event);
			targetLayer=target as Layer;
			switch (targetLayer.className)
			{
				case "DynamicLayerWithLegendImage":
				{
					if ((targetLayer)&&((target as UIComponent).numChildren==0)) //numChildren is 0 before the image has been received from the REST service and loaded. If it is 1 then the image loads from cache.
					{
						stop();
						targetLayer.addEventListener(LayerEvent.UPDATE_END,updateEnd);
					}
					break;
				}
				case "MyGraphicsLayer":
				{
					if (!updateComplete)
					{
						stop();
						targetLayer.addEventListener(LayerEvent.UPDATE_END,updateEnd);
					}
					else
					{
						updateComplete=false;
					}
					break;
				}
			}
		}
		/**
		 * Called when the layer has finished loading. At the end of the layer load, the fade effect will start to play. 
		 * @param event
		 * 
		 */		
		protected function updateEnd(event:LayerEvent):void
		{
			updateComplete=true;
			targetLayer.removeEventListener(LayerEvent.UPDATE_END,updateEnd);
			play();
		}
	}
}
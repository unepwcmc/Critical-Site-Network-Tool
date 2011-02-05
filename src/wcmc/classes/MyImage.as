package wcmc.classes
{
	import flash.events.Event;
	
	import mx.binding.utils.BindingUtils;
	import mx.controls.Image;
	import mx.events.FlexEvent;
	/**
	 * Custom Image class that is used in the Panoramio and Flickr providers to get the size of the image when it has finished loading. Doesnt quite work yet. 
	 * @author andrewcottam
	 * 
	 */	
	public class MyImage extends Image
	{
		[Bindable]public var defaultHeight:Number;
		[Bindable]public var ratio:Number=1;
		public function MyImage()
		{
			super();
			addEventListener(Event.COMPLETE,updateComplete);
			addEventListener(FlexEvent.CREATION_COMPLETE,bindProperties);
		}
		protected function bindProperties(event:FlexEvent):void
		{
			BindingUtils.bindProperty(this,"scaleX",this,"ratio");
			BindingUtils.bindProperty(this,"scaleY",this,"ratio");
		}
		protected function updateComplete(event:Event):void
		{
			var contentHeight:Number=(event.target as Image).contentHeight;
			(contentHeight>defaultHeight) ? ratio=defaultHeight/contentHeight : ratio=1;	
		}
		
	}
}
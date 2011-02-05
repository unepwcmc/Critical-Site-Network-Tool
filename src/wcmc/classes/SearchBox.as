package wcmc.classes
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.controls.Image;
	import mx.controls.TextInput;
	import mx.resources.IResourceManager;

	/**
	 * Class that extends the TextInput component with a clear search image. 
	 * @author andrewcottam
	 * 
	 */	
	public class SearchBox extends TextInput
	{
		private var searchImg:Image;
		/**
		 * Overriden function which instantiates the clear search icon and adds the event wiring in. 
		 * 
		 */		
		override protected function createChildren():void
		{
			super.createChildren(); //call the super createChildren
			styleName="TextInput";
			searchImg = new Image(); //create a new image for the clear search box icon
			searchImg.source = EmbeddedImages.searchIcon; //set the source
			searchImg.width=14; //set the width
			searchImg.height=14; //set the height
			searchImg.x = 142; //set the position of the icon in the TextInput
			searchImg.y = 4; //set the y position
			searchImg.visible=false; //not visible by default
			var chain:Object = new Object(); //chain object to use in the databinding 
			chain.name = "getString"; //set the chain name
			chain.getter = function(resMan:IResourceManager):String {return resMan.getString('myResources', 'TEXT17')}; //set the chain getter function
			BindingUtils.bindProperty(searchImg,"toolTip",resourceManager,chain); //bind the tooltip to a function which returns a string
			searchImg.addEventListener(MouseEvent.MOUSE_DOWN,mouseDown); //add a listener to change the image on mouse down
			searchImg.addEventListener(MouseEvent.MOUSE_UP,mouseUp); //add a listener to change the image on mouse up
			addChild(searchImg); //add the image
		}
		/**
		 * Constructor. Adds the event wiring for keyUp. 
		 * 
		 */		
		public function SearchBox():void
		{
			addEventListener(KeyboardEvent.KEY_UP,keyUp); //add the listener for key downs
		}
		private function keyUp(event:KeyboardEvent):void
		{
			if (text.length>0)
			{
				searchImg.visible=true;
			}
			else
			{
				searchImg.visible=false;
			}
		}
		private function mouseDown(event:MouseEvent):void
		{
			searchImg.source = EmbeddedImages.searchIconClick;
		}
		private function mouseUp(event:MouseEvent):void
		{
			searchImg.source = EmbeddedImages.searchIcon;
			text="";
			dispatchEvent(new KeyboardEvent("keyUp"));
		}
	}
}
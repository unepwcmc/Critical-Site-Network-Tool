package wcmc.classes
{
	import com.esri.ags.Graphic;
	import com.esri.ags.components.InfoWindow;
	import com.esri.ags.events.LayerEvent;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.layers.FeatureLayer;
	import com.esri.ags.layers.GraphicsLayer;
	import com.esri.ags.renderers.ClassBreaksRenderer;
	import com.esri.ags.renderers.Renderer;
	import com.esri.ags.renderers.SimpleRenderer;
	import com.esri.ags.renderers.UniqueValueRenderer;
	import com.esri.ags.renderers.supportClasses.ClassBreakInfo;
	import com.esri.ags.renderers.supportClasses.UniqueValueInfo;
	import com.esri.ags.symbols.Symbol;
	import com.esri.ags.tasks.supportClasses.Query;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.rpc.AsyncResponder;
	/**
	 * Custom FeatureLayer that adds features for creating a legend and automatically updating the layer when the definition expression changes.
	 * The class is used in a com.esri.ags.Map component and is used with a wcmc.components.Legend component to display the feature layers symbology on the fly. @see wcmc.components.Legend component
	 * @author andrewcottam
	 * 
	 */
	public class MyFeatureLayer extends FeatureLayer implements ILegend
	{
		/**
		 * Dispatched when the symbology has changed for the layer or the endUpdate layer event is fired, i.e. the data has been refreshed.
		 */		
		[Event(name="symbologyChanged", type="wcmc.classes.SymbologyChangedEvent")]
		[Bindable]
		/**
		 * The caption for the legend for this feature layer - this is not the caption for each of the items within the feature layer. 
		 */		
		public var legendCaption:String;
		[Bindable]
		/**
		 * Sets a value to show/hide the legend. 
		 */		
		public var showlegend:Boolean=true;
		[Bindable]
		/**
		 * The current state of the feature layer. If loading is true, a request has been made for the data but it has not yet completed. 
		 */		
		public var loading:Boolean=false;
		[Bindable]
		/**
		 * Maximum number of features that this feature layer will show. If the number of features is greater than this value then the features will not be requested. 
		 */		
		public var maxFeatureCount:Number;
		[Bindable]
		/**
		 * If the maxFeatureCount is set then this flags whether the current feature layer request will result in less features than the maxFeatureCount. 
		 */		
		public var withinMaxFeatureCount:Boolean=true;
		/**
		 * Flag to indicate if features have been loaded - this only applies in snapshot mode when all features from the layer are loaded up front - this is set to false if the definition expression changes
		 */		
		public var featuresLoaded:Boolean=false; 
		private var currentGraphic:Graphic;
		private var showTimer:Timer;
		private var hideTimer:Timer;
		private var scrubTimer:Timer;
		/**
		 * Constructor. Adds the necessary event listeners for the class. 
		 * 
		 */		
		public function MyFeatureLayer()
		{
			super();
			addEventListener(LayerEvent.UPDATE_START,updateStart); //add the wiring to call updateStart when the layer starts to load
			addEventListener(LayerEvent.UPDATE_END,_updateEnd); //add the wiring to call _updateEnd when the layer has finished loading
			addEventListener(SymbologyChangedEvent.SYMBOLOGYCHANGED,symbologyChanged);
			BindingUtils.bindSetter(updateFeatures,this,"definitionExpression"); //bind the updates features function to the definition expression so that if it changes the function is called
			//The following are not used - the mouse over graphics event handlers are commented out - but they used to be used for showing the infoWindow on mouse over
//			showTimer = new Timer(0, 1);
//			showTimer.addEventListener(TimerEvent.TIMER,showInfoWindow);
//			hideTimer = new Timer(0, 1);
//			hideTimer.addEventListener(TimerEvent.TIMER,hideInfoWindow);
//			scrubTimer = new Timer(0, 1);
		}
		[Bindable]
		/**
		 * I had to create this property as the graphicLayer.graphicProvider property was not binding to a DataGrid. This is programmatically populated when the layer has finishsed loading. 
		 */		
		public var features:ArrayCollection=new ArrayCollection(); 
		/**
		 * Overriden function that sets the renderer for the feature layer and dispatches the SymbologyChangedEvent event.
		 * @param value
		 * 
		 */		
		override public function set renderer(value:Renderer):void
		{
			super.renderer=value;
			if (graphicProvider.length>0) dispatchEvent(new SymbologyChangedEvent(SymbologyChangedEvent.SYMBOLOGYCHANGED,this));
		}
		/**
		 * Called when the definition expression changes. If maxFeatureCount is 0 then the feature layer is refreshed, otherwise a call is made to see how many features would be returned from the server.
		 * @param object
		 * 
		 */
		protected function updateFeatures(object:Object):void
		{
			(maxFeatureCount>0) ? getFeatureCount() : requestFeatures();
		}
		/**
		 * Called if the maxFeatureCount has been set - checks to see how many features would be returned by the current definition expression 
		 * 
		 */		
		protected function getFeatureCount():void
		{
			withinMaxFeatureCount=false; //reset
			queryCount(new Query,new AsyncResponder(onResult, null));
			function onResult(count:Number, token:Object = null):void
			{
				withinMaxFeatureCount=(count<=maxFeatureCount);
			}
		}
		/**
		 * Requests features from the server - this is called if the definition expression changes 
		 * 
		 */
		protected function requestFeatures():void
		{
			if (mode==MODE_SNAPSHOT) featuresLoaded=false; //reset the featuresLoaded flag 
			refresh();
		}
		/**
		 * Called when the layer loads. Sets the loading flag to true if the features are not loaded. 
		 * @param event
		 * 
		 */		
		protected function updateStart(event:LayerEvent):void
		{
			if (!featuresLoaded) loading=true;
		}
		/**
		 * Called when features are returned from the server. Sets the loading flag to false and populates the features object. @see features
		 * @param event 
		 * 
		 */		
		protected function _updateEnd(event:LayerEvent):void
		{
			if (!featuresLoaded)
			{
				loading=false;
				populateFeatures(((event.layer) as GraphicsLayer).graphicProvider as ArrayCollection); //populates the features with the ArrayCollection of graphics 
			}
			dispatchEvent(new SymbologyChangedEvent(SymbologyChangedEvent.SYMBOLOGYCHANGED,this)); //fire the symbology changed event
			if (mode==MODE_SNAPSHOT) featuresLoaded=true; //only if the mode is snapshot are all features loaded
		}	
		/**
		 * Populates the features object with the features from the graphicProvider. 
		 * @param graphicProvider An ArrayCollection of graphics.
		 * 
		 */		
		protected function populateFeatures(graphicProvider:ArrayCollection):void
		{
			features.removeAll(); //clear the features that are already in the collection
			features.disableAutoUpdate(); //stop auto firing events every time a new item is added to the collection
			for each (var graphic:Graphic in (graphicProvider)) //iterate through the graphics and add them to the features
			{
				features.addItem(graphic.attributes);	
//				graphic.addEventListener(MouseEvent.MOUSE_OVER,mouseOverGraphic);
//				graphic.addEventListener(MouseEvent.MOUSE_OUT,mouseOutGraphic);
			}
			features.refresh(); //remove all of the events that would have been fired
			features.enableAutoUpdate(); //turn on normal events again
		}
		/**
		 * Called when the symbology changes. If the renderer is a dynamic renderer then the infos are recreated from the dataProvider so that the legend can be updated.
		 * @param event
		 * 
		 */		
		protected function symbologyChanged(event:Event):void
		{
			if (renderer is IDynamicRenderer) (renderer as IDynamicRenderer).createInfos(graphicProvider);
		}
		/**
		 * The caption for the feature layer on the legend component. This is the implemeting function for the ILegend::caption member. 
		 * @return The feature layers legendCaption property. @see legendCaption
		 * 
		 */		
		public function caption():String
		{
			return legendCaption;
		}
		/**
		 * Flag to set whether to show/hide this feature layer in the legend. This is the implemeting function for the ILegend::showLegend member. 
		 * @return 
		 * 
		 */		
		public function showLegend():Boolean
		{
			return showlegend; 
		}
		/**
		 * Contains the collection of legend items that will be shown in the legend. This is the implemeting function for the ILegend::items member.
		 * @return 
		 * 
		 */		
		public function items():ArrayCollection
		{
			if (symbol) //if the feature layer has a simple symbol then return that
			{
				return getItemsForSymbol();
			}
			else //this feature layer has a renderer so get the items for the renderer
			{
				return getItemsForRenderer();
			}
		}
		/**
		 * Returns the legend item where the feature layer has a single symbol to represent the features.
		 * @return An array collection of LayerLegendItem objects. @see wcmc.classes.LayerLegendItem
		 * 
		 */		
		protected function getItemsForSymbol():ArrayCollection
		{
			var ac:ArrayCollection=new ArrayCollection(); //instantiate a new array collection to hold the returned image
			var image:Object=symbol.createSwatch(16,16); //create a swatch from the symbol
			var caption:String=getCaption(symbol); //get the caption for the symbol - this will be shown in the legend component
			var layerLegendItem:LayerLegendItem=new LayerLegendItem(image,caption); //creates a new LayerLegendItem - this is the object that is bound in the Legend component 
			ac.addItem(layerLegendItem); //add the layer legend item
			return ac;
		}
		/**
		 * Returns the legend items where the feature layer has a renderer to symbolise the features. 
		 * @return An array collection of LayerLegendItem objects. @see wcmc.classes.LayerLegendItem
		 * 
		 */		
		protected function getItemsForRenderer():ArrayCollection
		{
			if (!renderer) return null; //null check
			if (renderer is SimpleRenderer) return getItemsForSimpleRenderer(); //get the items for a simple renderer
			if (renderer is MyUniqueValueRenderer) return getItemsForMyUniqueValueRenderer(); //get the items for a unique value renderer
			if (renderer is UniqueValueRenderer) return getItemsForMyUniqueValueRenderer(); //this will actually get only the symbols that are in use, e.g for the season field, it will only return actual values used rather than the unique values
			if (renderer is MyClassBreaksRenderer) return getItemsForDynamicClassBreaksRenderer(); //get the items for a dynamic class breaks renderer
			if (renderer is ClassBreaksRenderer) return getItemsForClassBreaksRenderer(); //get the items for a class breaks renderer
			return null;
		}
		/**
		 * Returns the legend items for a feature layer that has a simple renderer, i.e. only a single symbol is used in the renderer. 
		 * @return An array collection of LayerLegendItem objects. @see wcmc.classes.LayerLegendItem
		 * 
		 */		
		protected function getItemsForSimpleRenderer():ArrayCollection
		{
			var ac:ArrayCollection=new ArrayCollection();  //instantiate a new array collection to hold the returned image
			var simpleRenderer:SimpleRenderer=renderer as SimpleRenderer; //get the renderer as a simple renderer
			var image:Object=simpleRenderer.symbol.createSwatch(16,16); //create a swatch from the symbol
			var caption:String=getCaption(simpleRenderer.symbol); //get the caption for the symbol - this will be shown in the legend component
			var layerLegendItem:LayerLegendItem=new LayerLegendItem(image,caption); //creates a new LayerLegendItem - this is the object that is bound in the Legend component 
			ac.addItem(layerLegendItem); //add the layer legend item
			return ac;
		}
		/**
		 * Returns the legend items for a feature layer that has a simple unique value renderer, i.e. where the items don't change.
		 * @return An array collection of LayerLegendItem objects. @see wcmc.classes.LayerLegendItem
		 * 
		 */		
		protected function getItemsForUniqueValueRenderer():ArrayCollection
		{
			return getItemsFromUniqueValues((renderer as UniqueValueRenderer).infos); //call a sub function to build the legend items
		}
		/*Returns the items for unique value renderers which do change depending on the graphics*/
		/**
		 * Returns the legend items for a feature layer that has a unique value rendere where the items do change depending on the actual features that are shown, e.g. season field may only contain breeding and wintering - only these will be shown in the legend
		 * @return An array collection of LayerLegendItem objects. @see wcmc.classes.LayerLegendItem
		 * 
		 */		
		protected function getItemsForMyUniqueValueRenderer():ArrayCollection
		{
			var array:Array=new Array();
			for each (var graphic:Graphic in graphicProvider) //build an array of the unique values that are actually in use in the feature layer
			{
				var value:String=graphic.attributes[(renderer as UniqueValueRenderer).attribute];
				if (!inArray(value,array)) array.push(new UniqueValueInfo(renderer.getSymbol(graphic),value));
			}
			return getItemsFromUniqueValues(array); //call a sub function to build the legend items
		}
		/**
		 * Searches for the value in the array 
		 * @param value Value to search for
		 * @param array Array to search in.
		 * @return A boolean value indicating if the search term was found.
		 * 
		 */		
		protected function inArray(value:String,array:Array):Boolean
		{
			for each (var obj:Object in array)
			{
				if (obj.value==value) return true
			}
			return false;
		}
		/**
		 * Returns the legend items for a class breaks renderer dynamically from the data, i.e. it dynamically splits the data into classes. An example is the mean population renderer which splits the data on the fly.
		 * @return An array collection of LayerLegendItem objects. @see wcmc.classes.LayerLegendItem @see wcmc.classes.MyClassBreaksRenderer
		 * 
		 */
		protected function getItemsForDynamicClassBreaksRenderer():ArrayCollection
		{
			return getItemsFromClassBreaks((renderer as MyClassBreaksRenderer).infos); //dynanically creates the infos array from the data
		}
		/**
		 * Returns the legend items for a feature layer that has a unique value renderer, either static or dynamic. 
		 * @return An array collection of LayerLegendItem objects. @see wcmc.classes.LayerLegendItem
		 * 
		 */		
		protected function getItemsFromUniqueValues(uniqueValues:Array):ArrayCollection
		{
			var ac:ArrayCollection=new ArrayCollection();
			for each (var uniqueValueInfo:UniqueValueInfo in uniqueValues) //iterate through the unique values and create the legend items
			{
				if (uniqueValueInfo.symbol) var image:Object=uniqueValueInfo.symbol.createSwatch(16,16); //create the symbol
				var caption:String=getCaption(uniqueValueInfo.symbol); //get the caption to show in the legend
				var layerLegendItem:LayerLegendItem=new LayerLegendItem(image,caption); //create the new LayerLegendItem
				ac.addItem(layerLegendItem); //add it to the array
			}
			return ac;
		}
		/**
		 * Returns the legend items for a class breaks renderer using the class breaks array.
		 * @param classBreaks An array of class breaks that are normally set in MXML.
		 * @param useLegendCaption Determines whether to use the legend caption from the symbol in the map or to create one from the data. The default is to create one from the data, e.g. if the class break is 0-40 then the legen will be '0 - 40'
		 * @return An array collection of LayerLegendItem objects. @see wcmc.classes.LayerLegendItem.
		 * 
		 */		
		protected function getItemsFromClassBreaks(classBreaks:Array,useLegendCaption:Boolean=false):ArrayCollection
		{
			var ac:ArrayCollection=new ArrayCollection();
			var layerLegendItem:LayerLegendItem;
			for each (var classBreakInfo:ClassBreakInfo in classBreaks) //iterate through the class breaks
			{
				var image:Object=classBreakInfo.symbol.createSwatch(16,16); //create a symbol
				if (useLegendCaption) //if a legend caption is to be used
				{
					var caption:String=getCaption(classBreakInfo.symbol); //get the caption from the symbol
					layerLegendItem=new LayerLegendItem(image,caption); //create a LayerLegendItem with the caption
				}
				else
				{
					layerLegendItem=new LayerLegendItem(image,classBreakInfo.minValue.toString() + " - " + classBreakInfo.maxValue.toString()); //create the legend caption from the data itself
				}
				ac.addItem(layerLegendItem);
			}
			return ac;
		}
		/**
		 * Returns the legend items for a class breaks renderer. The class breaks are not dynamically created but are normally set in MXML code. An example is the % flyway renderer which is '0% - 1%' etc.
		 * @return An array collection of LayerLegendItem objects. @see wcmc.classes.LayerLegendItem @see wcmc.classes.MyClassBreaksRenderer
		 * 
		 */
		protected function getItemsForClassBreaksRenderer():ArrayCollection
		{
			return getItemsFromClassBreaks((renderer as ClassBreaksRenderer).infos,true);
		}
		/**
		 * Returns the text to display in the legend for the symbol. If the symbol has a 'legendCaption' property then this is returned otherwise it is null.  
		 * @param symbol
		 * @return 
		 * 
		 */		
		protected function getCaption(symbol:Symbol):String
		{
			if (!symbol) return null;
			if (symbol.hasOwnProperty("legendCaption")) //implemented in MySimpleMarkerSymbol, MySimpleFillSymbol etc.
			{
				return (symbol as Object).legendCaption;
			}
			else
			{	
				return null;
			}
		}
		/**
		 * Not currently used. 
		 * @param event
		 * 
		 */		
		private function mouseOverGraphic(event:MouseEvent):void
		{
			if (!event.target) return;
			currentGraphic=event.target as Graphic;
			(scrubTimer.running) ? showTimer.delay=0 : showTimer.delay=500;
			showTimer.start();
		}
		/**
		 * Not currently used. 
		 * @param event
		 * 
		 */		
		private function mouseOutGraphic(event:MouseEvent):void
		{
			if (event.relatedObject is InfoWindow) return;
			showTimer.reset();
			hideTimer.reset();
			hideInfoWindow(null);
			scrubTimer.delay=100;
			scrubTimer.start();
		}
		/**
		 * Not currently used. 
		 * @param event
		 * 
		 */		
		private function showInfoWindow(event:TimerEvent):void
		{
			if (!infoWindowRenderer) return;
			map.infoWindow.content=infoWindowRenderer.newInstance();
			map.infoWindow.data=currentGraphic.attributes;
			var mapPoint:MapPoint=map.toMap(new Point(map.mouseX,map.mouseY));
			map.infoWindow.show(mapPoint);
			hideTimer.delay=10000;
			hideTimer.start();
		}
		/**
		 * Not currently used. 
		 * @param event
		 * 
		 */		
		private function hideInfoWindow(event:TimerEvent):void
		{
			map.infoWindow.hide();
		}
	}
}
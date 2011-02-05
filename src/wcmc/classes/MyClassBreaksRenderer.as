package wcmc.classes
{
	import com.esri.ags.Graphic;
	import com.esri.ags.renderers.ClassBreaksRenderer;
	import com.esri.ags.renderers.supportClasses.ClassBreakInfo;
	import com.esri.ags.symbols.SimpleLineSymbol;
	import com.esri.ags.symbols.SimpleMarkerSymbol;
	import com.esri.ags.symbols.Symbol;
	
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;

	/**
	 * Class that creates a ClassBreakRenderer dynamically based on the data that is passed to it. It implements IDynamicRenderer.
	 * @author andrewcottam
	 * 
	 */	
	public class MyClassBreaksRenderer extends ClassBreaksRenderer implements IDynamicRenderer
	{
		public function MyClassBreaksRenderer()
		{
			super();
		}
		/**
		 * The number of classes that the DynamicClassBreaksRenderer will contain. Currently the class is hard-coded for 3 classes.
		 */		
		public var classes:int;
		/**
		 * The maximum symbol size, i.e. the size of the symbol for the nth class 
		 */		
		public var maxSymbolSize:int;
		[Bindable]
		/**
		 * The line symbol that is used for the outline of the marker.
		 */		
		public var simpleLineSymbol:SimpleLineSymbol;
		/**
		 * This function must be explicitly called in this class to create the class breaks and the symbols.
		 * @param graphicProvider
		 * 
		 */		
		override public function getSymbol(graphic:Graphic):Symbol
		{
			if (!infos) return null;
			for each (var classBreakInfo:ClassBreakInfo in infos)
			{
				if ((graphic.attributes[attribute]>=classBreakInfo.minValue)&&(graphic.attributes[attribute]<=classBreakInfo.maxValue))
				{
					return classBreakInfo.symbol;
				}
			}
			return null;
		}
		/**
		 * Creates the classes and symbols for the DynamicClassBreaksRenderer by iterating through all of the features.
		 * @param graphicProvider The graphic provider from the feature layer.
		 */		
		public function createInfos(graphicProvider:Object):void
		{
			var features:ArrayCollection=graphicProvider as ArrayCollection;
			if (!features) return;
			if (features.length==0) return;
			var classValues:Array=buildAbundanceClasses(features,3);
			if (!classValues) return;
			var classBreakInfos:Array=new Array();
			var simpleMarkerSymbol:SimpleMarkerSymbol;
			var classBreakInfo:ClassBreakInfo;	
			for (var i:int=0;i<classValues.length-1;i++)
			{
				simpleMarkerSymbol=new SimpleMarkerSymbol(SimpleMarkerSymbol.STYLE_CIRCLE,((maxSymbolSize/classes)*(i+1)),0xff0000,1,0,0,0,simpleLineSymbol);
				classBreakInfo=new ClassBreakInfo(simpleMarkerSymbol,classValues[i],classValues[i+1]);
				classBreakInfos.push(classBreakInfo);
			}
			infos = classBreakInfos;
		}
		/**
		 * Builds the classes using the features from the feature layer. 
		 * @param features The features from the feature layer. 
		 * @param numClasses The number of classes to split the features data into.
		 */		
		protected function buildAbundanceClasses(features:ArrayCollection, numClasses:int):Array
		{
			var classValues:Array=new Array();
			if (numClasses>2)
			{
				var sobjects:Array = sortByAbundance(features,true);
				if (!sobjects) return null;
				if (sobjects.length==0) return null;
				var gap:Number=(Math.ceil(sobjects.length/3)-1);
				classValues.push(0);
				classValues.push(sobjects[gap][attribute]);
				classValues.push(sobjects[gap* 2][attribute]);
				classValues.push(sobjects[sobjects.length-1][attribute]);
			}
			return classValues;
		}	
		/**
		 * Sorts the features into an ordered collecton based on the attribute property. @see com.esri.ags.ClassBreaksRenderer
		 * @param features The features from the feature layer. 
		 * @param ascending Determines whether to sort the data in ascending order or not.
		 * @return 
		 * 
		 */		
		protected function sortByAbundance(features:ArrayCollection, ascending:Boolean):Array
		{
			var sobjects:Array;
			var objects:Array=new Array();
			for each (var graphic:Graphic in features)
			{
				objects.push(graphic.attributes); //add the features to an array
			}
			if (ascending) //sort the features
			{
				sobjects = objects.sort(function(a:Object,b:Object):int 
				{
					if(a[attribute] < b[attribute])
						return -1;
					else if (a[attribute] > b[attribute])
						return 1;
					else
						return 0;
				});
			}
			else
			{
				sobjects = objects.sort(function(a:Object,b:Object):int 
				{
					if(a[attribute] < b[attribute])
						return 1;
					else if (a[attribute] > b[attribute])
						return -1;
					else
						return 0;
				});
			}
			return sobjects;
		}  
	}
}
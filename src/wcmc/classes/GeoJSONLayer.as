package wcmc.classes
{
	import com.esri.ags.FeatureSet;
	import com.esri.ags.Graphic;
	import com.esri.ags.events.ExtentEvent;
	import com.esri.ags.events.LayerEvent;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.layers.supportClasses.FeatureCollection;
	import com.esri.ags.utils.GraphicUtil;
	import com.esri.ags.utils.WebMercatorUtil;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	import mx.collections.ArrayCollection;
	import mx.utils.GraphicsUtil;
	/**
	 * Custom class that extends MyFeatureLayer to retrieve information from a GeoJSON layer, e.g. protectedPlanet. Currently not implemented. 
	 * @author andrewcottam
	 * 
	 */	
	public class GeoJSONLayer extends MyFeatureLayer
	{
		
		private var _params:URLVariables=new URLVariables();
		private var _urlRequest:URLRequest=new URLRequest();
		private var loader:URLLoader=new URLLoader();
		public function GeoJSONLayer()
		{
			super();
			setLoaded(true);
			loader.addEventListener(Event.COMPLETE,loadComplete);
		}
		override protected function updateLayer():void
		{
			var llpoint:MapPoint=WebMercatorUtil.webMercatorToGeographic(new MapPoint(map.extent.xmin,map.extent.ymin))as MapPoint;
			var urpoint:MapPoint=WebMercatorUtil.webMercatorToGeographic(new MapPoint(map.extent.xmax,map.extent.ymax))as MapPoint;
			_params.blx = llpoint.x;
			_params.bly = llpoint.y;
			_params.trx = urpoint.x;
			_params["try"] = urpoint.y;
			var url:String = "http://protectedplanet.net/api2/sites";
			_urlRequest.url=url;
			_urlRequest.data = _params; 
			loader.load(_urlRequest);
		}
		private function loadComplete(event:Event):void
		{
			var data:String=(event.target as URLLoader).data;
			var features:Array=[];
			var point:MapPoint = WebMercatorUtil.geographicToWebMercator(new MapPoint(-2,54))as MapPoint;
			var feature:Graphic = new Graphic(point,null,{name:'wibble'});
			var ac:ArrayCollection=graphicProvider as ArrayCollection;
			ac.addItem(feature);
			dispatchEvent(new LayerEvent(LayerEvent.UPDATE_END,this,null,true,true));
		}
	}
}
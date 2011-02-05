package wcmc.classes
{
	import com.esri.ags.geometry.WebMercatorMapPoint;
	/**
	 * Simple class for holding information on a photo object returned from the Panoramio search service. 
	 * @author andrewcottam
	 * 
	 */
	public class PanoramioPhoto
	{
		/**
		 * Constructor. 
		 * 
		 */		
		public function PanoramioPhoto()
		{
		}
		/**
		 * The lat/long location of the photo 
		 */		
		public var latlng:WebMercatorMapPoint;
		/**
		 * The Panoramio owner of the photo 
		 */		
		public var owner:String;
		/**
		 * The page for the photo on Panoramio 
		 */		
		public var sourceUrl:String;
		/**
		 * The title for the photo on Panoramio 
		 */		
		public var title:String;
		/**
		 * The url for the photo on Panoramio 
		 */		
		public var imageUrl:String;
		/**
		 * The thumbnail for the photo on Panoramio 
		 */		
		public var thumbnail:String;
		/**
		 * A unique identifier for the photo on Panoramio 
		 */		
		public var id:String;
		/**
		 * The photo height. 
		 */		
		public var height:Number;
		/**
		 * The photo width 
		 */		
		public var width:Number;
	}
}
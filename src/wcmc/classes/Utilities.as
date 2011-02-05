package wcmc.classes
{
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.collections.ArrayCollection;
	/**
	 * Global utility methods used throughout the application. 
	 * @author andrewcottam
	 * 
	 */
	public class Utilities
	{
		public function Utilities()
		{
		}
		/**
		 * Opens a new browser window and navigates to that url.
		 */ 
		public static function navigateToUrl(url:String):void
		{
			var urlRequest:URLRequest=new URLRequest(url);
			navigateToURL(urlRequest,"_blank");
		}
		/**
		 * Converts an ArrayCollection object to a comma delimited string. 
		 * @param value
		 * @return 
		 * 
		 */		
		public static function arrayCollectionToString(value:ArrayCollection):String
		{
			if (!value) return null;
			var commaSeparatedString:String="";
			for each (var object:Object in value)
			{
				(!isNaN(Number(object))) ? commaSeparatedString=commaSeparatedString + object + "," : commaSeparatedString=commaSeparatedString + object + "','";
			}
			if (value.length>0)
			{
				object=value[0];
				(isNaN(Number(object))) ? commaSeparatedString="'" + commaSeparatedString.substring(0,commaSeparatedString.length-2) : commaSeparatedString=commaSeparatedString.substring(0,commaSeparatedString.length-1);
			}
			if (commaSeparatedString=="") commaSeparatedString=null;
			return commaSeparatedString;
		}
		/**
		 * Returns teh passed object as XML.
		 */  
		public static function getSOAPXML(urlLoaderData:Object):XML
		{
			var _xml:XML = new XML(urlLoaderData);
			var _XMLList:XMLList=_xml..NewDataSet;
			var d:XML=_XMLList[0];
			return d;
		}
	}
}
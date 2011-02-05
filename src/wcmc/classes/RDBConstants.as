package wcmc.classes
{
	import flash.utils.Dictionary;
	/**
	 * Set of constants to return RDB strings, codes and colors for the application. 
	 * @author andrewcottam
	 * 
	 */
	public class RDBConstants
	{
		/**
		 * Singleton object. 
		 */		
		public static const instance:RDBConstants = new RDBConstants();
		/**
		 * Constructor. 
		 * 
		 */		
		public function RDBConstants()
		{
		}
		/**
		 * Returns the color integer for the passed RDB text or code. 
		 * @param rdb The RDB text or code, e.g. CR or Critically Endangered.
		 * @return The color integer, e.g. 0xD81E05.
		 * 
		 */		
		public function getColorForRDB(rdb:String):Number
		{
			switch (rdb)
			{
				case "CR":
				case"Critically Endangered":
					return int("0xD81E05");
					break;
				case "DD":
				case"Data Deficient":
					return int("0xD1D1C6");
					break;
				case "EN":
				case"Endangered":
					return int("0xFC7F3F");
					break;
				case "EW":
				case"Extinct in the Wild":
					return int("0x542344");
					break;
				case "EX":
				case"Extinct":
					return int("0x000000");
					break;
				case "LC":
				case"Least Concern":
					return int("0x60C659");
					break;
				case "NE":
				case"Not Evaluated":
					return int("0xFFFFFF");
					break;
				case "NR":
					return int("0x888888")
					break;
				case "NT":
				case"Near Threatened":
					return int("0xCCE226");
					break;
				case "VU":
				case"Vulnerable":
					return int("0xF9E814");
					break;
				default: 
					return NaN
			}
		}
		/**
		 * Returns the RDB text for the passed RDB code. 
		 * @param rdb The RDB code, e.g. CE.
		 * @return The RDB text, e.g. Critically Endangered.
		 * 
		 */		
		public function getTextForRDB(rdb:String):String
		{
			switch (rdb)
			{
				case "CR":
					return "Critically Endangered";
					break;
				case "DD":
					return "Data Deficient";
					break;
				case "EN":
					return "Endangered";
					break;
				case "EW":
					return "Extinct in the Wild";
					break;
				case "EX":
					return "Extinct";
					break;
				case "LC":
					return "Least Concern";
					break;
				case "NE":
					return "Not Evaluated";
					break;
				case "NR":
					return "Not Recognised";
					break;
				case "NT":
					return "Near Threatened";
					break;
				case "VU":
					return "Vulnerable";
					break;
				default: 
					return "";
			}
		}
	}
}
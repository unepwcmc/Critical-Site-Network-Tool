/* file			speciescount.as
date			oct 2009
author			andrew cottam
description		simple class to store properties of a species count
all of the properties are bindable so they can be used in UI components or renderers
properties		uniqueID - running unique integer
species - the species ID for the count
site - the site name
abundance - count for the species (can include 0)
*/
package wcmc.classes
{
	/**
	 * Simple class to store properties of a species count.
	 * @author andrewcottam
	 * 
	 */	
	public class SpeciesCount
	{
		public function SpeciesCount()
		{
		}
		[Bindable]
		/**
		 * The site code for the species count. 
		 * @return 
		 * 
		 */
		public var siteCode:String;
		[Bindable]
		/**
		 * The species code for the species count. 
		 * @return 
		 * 
		 */
		public var spcRecID:Number;
		[Bindable]
		/**
		 * The year for the species count. 
		 * @return 
		 * 
		 */
		public var _year:Number;
		[Bindable]
		/**
		 * The abundance for the species count 
		 * @return 
		 * 
		 */
		public var abundance:int;
	}
}
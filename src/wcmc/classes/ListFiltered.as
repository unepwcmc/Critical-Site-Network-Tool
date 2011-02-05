package wcmc.classes
{
	import mx.collections.ArrayCollection;
	import mx.controls.List;
	/**
	 * The ListFiltered Class is used to display a set of values as a list that can be filtered according to an IDFilter object.  
	 * @author andrewcottam
	 * 
	 */	
	public class ListFiltered extends List
	{
		public function ListFiltered()
		{
			super();
		}
		private var _idFilter:IDFilter;
		private var unfilteredItems:ArrayCollection;
		[Bindable]
		/**
		 * A pointer to an existing filter function if one is present. If the dataProvider is already filtered (e.g. by a search term) then the result will be the result of the exisiting filter, i.e. an AND 
		 */		
		public var existingFilterFunction:Function;
		public function get idFilter():IDFilter
		{
			return _idFilter;
		}
		[Bindable]
		/**
		 * A simple filter that can be used to filter the list on the client using a set of IDs. 
		 * @param value
		 * 
		 */		
		public function set idFilter(value:IDFilter):void
		{
			_idFilter = value;
			_idFilter.addEventListener("idFilterChanged",idFilterChanged);
		}
		private function idFilterChanged(event:Event):void
		{
			var ac:ArrayCollection=dataProvider as ArrayCollection;
			if (!ac)return;
			if (idFilter.dataProvider.length==0) //i.e. unfiltered
			{
				ac.filterFunction=existingFilterFunction; //remove the filter from this class and simply use any existing filters
			}
			else
			{
				ac.filterFunction=filter; //id filter is set, so apply the filter
			}
			ac.refresh(); //filter the dataProvider
		}
		private function filter(obj:Object):Boolean 
		{
			if (!obj.hasOwnProperty(idFilter.attributeName)){return true} //if the idFilter attribute cannot be found in the object then return true
			var testID:int = obj[idFilter.attributeName]; //get the ID value of the passed object
			var existingFilterResult:Boolean;
			if (idFilter.dataProvider.contains(testID)) //if the ID value is in the idFilter dataProvider 
			{
				if (existingFilterFunction!=null) existingFilterResult=existingFilterFunction(obj); //if the dataProvider is already filtered (e.g. by a search term) then the result will be the result of the exisiting filter, i.e. an AND
				return existingFilterResult;
			}
			else
			{
				return false;
			}
		}			
	}
}
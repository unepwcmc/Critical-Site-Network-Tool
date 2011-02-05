package wcmc.classes
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	
	[Event(name="filterSavedEvent", type="flash.events.Event")]
	[Event(name="filtersLoaded", type="flash.events.Event")]
	[Event(name="startGetMatchingIDs", type="flash.events.Event")]
	[Event(name="endGetMatchingIDs", type="flash.events.Event")]
	[Event(name="filterResultComplete", type="wcmc.classes.FilterResultCompleteEvent")]
	/**
	 * The FilterCollection Class contains an array of Filter objects that are used to filter data from an SQL database. The Class contains additional members for working with the array of filters. 
	 * @author andrewcottam
	 * @mxml
	 * <p>The <code>&lt;classes:FilterCollectionw&gt;</code> tag inherits all of the tag 
	 *  attributes of its superclass, and adds the following tag attributes:</p>
	 *  
	 *  <pre>
	 *  &lt;classes:FilterCollection
	 *   <b>Properties</b>
	 *   filters="<i>From filters</i>"
	 *   masterTableName="String"
	 *  </pre>
	 *  <pre>
	 *  <p>Here is an example:</p>
	 * 	&lt;classes:FilterCollection id="filterCollection" masterTableName="FILTER" filterResultComplete="newFilterCollection_filterResultCompleteHandler(event)"&gt;
	 *		&lt;classes:filters&gt;
	 *		&lt;s:ArrayCollection&gt;
	 *				&lt;classes:Filter id="country" label="Country" table="COUNTRY" valueField="Code" masterTableFilterFieldName="SiteRecID" filterRenderer="wcmc.renderers.CountryFilterRenderer" sortLookupValues="false"/&gt;
	 *			&lt;/s:ArrayCollection&gt;
	 *		&lt;/classes:filters&gt;
	 *	&lt;/classes:FilterCollection&gt;
	 */
	public class FilterCollection
	{
		/**
		 * Constructor. 
		 * 
		 */		
		public function FilterCollection()
		{
		}
		private var _filters:ArrayCollection;
		/**
		 * Returns the index position of the passed filter. 
		 * @param filter 
		 * @return 
		 * 
		 */		
		public function getFilterIndex(filter:Filter):int
		{
			for (var i:int=0;i<filters.length;i++)
			{
				var _filter:Filter=filters[i] as Filter;
				if (_filter===filter)
				{
					return i
				}
			}
			return -1;
		}
		/**
		 * The filterOnFieldNames ArrayCollection contains a set of fieldnames from the MasterTable that are used to return matching values. For example, if the master table is filtered on SpcRecID and SiteRecID fields then these 2 fields are in the filterOnFieldNames array collection. 
		 */		
		private var _filtered:Boolean;
		[Bindable]
		/**
		 * Each filter table is linked by a link table to a master table which is the table that you are actually filtering. For example, if the master table is CSN_IBA then you are filtering IBA records. The masterTableName property is the name of the table that that will be filtered.
		 */
		public var masterTableName:String;
		public var filterResults:ArrayCollection=new ArrayCollection();
		[Bindable]public function get filtered():Boolean
		{
			return _filtered;
		}
		public function set filtered(value:Boolean):void
		{
			_filtered = value;
			if (!value) 
			{
				for each (var filterResult:FilterResult in filterResults)
				{
					filterResult.matchingIDs=new ArrayCollection();
					dispatchEvent(new FilterResultCompleteEvent(FilterResultCompleteEvent.FILTERRESULTCOMPLETE,filterResult));
				}
			}
		}
		public function get filters():ArrayCollection
		{
			return _filters;
		}
		private function filtersChanged(event:CollectionEvent):void
		{
			if ((event.kind==CollectionEventKind.ADD)||(event.kind==CollectionEventKind.REMOVE))
			{ //filter added or removed to the filters collection programmatically 
				getMatchingIDs();
			}
		}
		[Bindable]public function set filters(value:ArrayCollection):void
		{
			var filterOnFieldNames:ArrayCollection=getUniqueMasterTableFilterFields(value); //get the unique fields that will be filtered on, e.g. SiteRecID and SpcRecID
			createFilterResultsHolder(filterOnFieldNames); //build the empty array collection that will hold the matching results
			_filters = value;
			loadFilters(); 
			filters.addEventListener(CollectionEvent.COLLECTION_CHANGE,filtersChanged); //to capture any programmatic changes to the filters collection
		}
		private function createFilterResultsHolder(filterOnFieldNames:ArrayCollection):void
		{
			for each (var filterOnFieldName:String in filterOnFieldNames)
			{
				var filterResult:FilterResult=new FilterResult();
				filterResult.filterFieldName=filterOnFieldName;
				filterResults.addItem(filterResult);
			}
		}
		private function getUniqueMasterTableFilterFields(filters:ArrayCollection):ArrayCollection
		{
			var uniqueFields:ArrayCollection=new ArrayCollection();
			for each (var filter:Filter in filters)
			{
				if (!uniqueFields.contains(filter.masterTableFilterFieldName)) 
				{
					uniqueFields.addItem(filter.masterTableFilterFieldName);
				}
			}
			return uniqueFields;
		}
		public function loadFilters():void
		{
			for each (var filter:Filter in filters) //load the data from a shared object
			{
				filter.filterCollection=this;
				filter.addEventListener("filterSavedEvent",filterSaved);
				var mySO:SharedObject=SharedObject.getLocal(filter.sharedObjectName);
				if (mySO)
				{
					if (mySO.data.selectedItems) filter.selectedItems=mySO.data.selectedItems;	
					if (mySO.data.fromClause) filter.fromClause=mySO.data.fromClause;	
					if (mySO.data.whereClause) filter.whereClause=mySO.data.whereClause;	
					if (mySO.data.filtered) filter.filtered=mySO.data.filtered;	
				}
			}
			dispatchEvent(new Event("filtersLoaded"));
			getMatchingIDs();
		}
		/**
		 * Returns a set of IDs that match the filters in the filterCollection. The only exception is if no filters are active in which case no ids are returned and the filterCollection.filtered flag is set to false. 
		 * 
		 */		
		public function getMatchingIDs():void 
		{
			for each (var filterResult:FilterResult in filterResults)
			{
				var sql:String=getMatchingIDsSQL(filterResult.filterFieldName); //get the SQL statement to run on the server to return a set of CSN SiteRecIDs
				if (sql!="") //if any filters are active
				{
					var request:URLRequest=new URLRequest("http://dev.unep-wcmc.org/CSN_WebServices/DataServices.asmx/GetMatchingCSNs?sql=" + sql);
					var loader:URLLoader=new URLLoader();
					loader.addEventListener(Event.COMPLETE,idsReturned);
					loader.addEventListener(IOErrorEvent.IO_ERROR,loaderError);
					dispatchEvent(new Event("startGetMatchingIDs"));
					loader.load(request);
				}
			}
		}
		protected function loaderError(event:IOErrorEvent):void
		{
			event.target.removeEventListener(IOErrorEvent.IO_ERROR,loaderError);
//			Alert.show("You are not connected to internet. Please connect and try again","Critical Site Network Tool");
		}
		/**
		 * Returns the SQL statement to run on the server to return a set of matching IDs for the passed filter field, e.g. SiteRecID will return a unique list of SiteRecIDs that match the filter 
		 * @return SQL statement
		 * 
		 */		
		private function getMatchingIDsSQL(filterFieldName:String):String
		{
			var whereClause:String=""; //initialise variables to empty strings
			var fromClause:String="";
			for each (var filter:Filter in filters) //iterate through all of the other filters to build the where and from clauses according to whether other filters will constrain the IDs that are returned
			{
				if (filter.whereClause!=null) whereClause=whereClause + filter.whereClause + " AND ";
				if (filter.fromClause!=null) fromClause=fromClause + filter.fromClause + " ";
			}
			whereClause= whereClause.substr(0,whereClause.length-5);
			if (whereClause!="") 
			{ //if any filters are active
				filtered=true;
				return "SELECT DISTINCT " + masterTableName + "." + filterFieldName + " AS 'r/@id' FROM " + masterTableName + " " + fromClause + " WHERE " + whereClause + " FOR XML PATH(''), ROOT('" + filterFieldName + "')";
			}
			else
			{ //no filters are active
				filtered=false;
				return "";
			}
		}
		/**
		 * Asynchronous return call that returns a set of ids that match the currently active filters
		 * @param event
		 * 
		 */		
		private function idsReturned(event:Event):void
		{
			dispatchEvent(new Event("endGetMatchingIDs"));
			event.target.removeEventListener(Event.COMPLETE,idsReturned);
			var xml:XML=new XML(event.currentTarget.data); //create a new XML object with the returned data
			if (xml.children().length()==0) 
			{
				dispatchEvent(new FilterResultCompleteEvent(FilterResultCompleteEvent.FILTERRESULTCOMPLETE,null));
				return;
			}
			var ids:ArrayCollection=new ArrayCollection(); //instantiate a new ArrayCollection to hold the ids
			for each (var xml2:XML in xml.children()) //iterate through the ids
			{
				var id:String=xml2.attribute('id')[0]; //string or int
				(Number(id)) ? ids.addItem(Number(id)) : ids.addItem(id);
			}
			if (filters)
			{
				for each (var filterResult:FilterResult in filterResults)
				{
					if (filterResult.filterFieldName.toUpperCase()==xml.name().localName.toUpperCase())
					{
						filterResult.matchingIDs=ids;
						dispatchEvent(new FilterResultCompleteEvent(FilterResultCompleteEvent.FILTERRESULTCOMPLETE,filterResult));
					}
				}
			}	
		}
		/**
		 * Function that saves the current filter and persists the properties to a shared object.
		 * 
		 */		
		public function clearAll():void
		{
			for each (var filter:Filter in filters)
			{
				filter.clear(true);
			}
			filtered=false;
		}
		private function filterSaved(event:Event):void
		{
			var isFiltered:Boolean=false;
			for each (var filter:Filter in filters)
			{
				if (filter.filtered)
				{
					isFiltered=true;
					break;
				}
			}			
			filtered=isFiltered;
			dispatchEvent(new Event("filterSavedEvent",true));
		}
	}
}
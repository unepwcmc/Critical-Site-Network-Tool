package wcmc.classes
{
	import flash.events.Event;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.collections.ArrayCollection;
	import mx.core.IFactory;
	/**
	 * The Filter Class is used to filter data from a relational database on the client and is used to generate the SQL statement that will be run against the RDBMS. Each Filter object specifies information about the table, primary and foreign keys and other information that will be used to return the matching data from the RDBMS. Filter Classes can be added to a FilterCollection object to combine multiple filter criteria.
	 * @author andrewcottam
	 * @example The following code creates a filter for a country:
	 * &lt;listing version="3.0"&gt;
	 * &lt;classes:Filter id="country" label="Country" table="COUNTRY" valueField="Code" masterTableFilterFieldName="SiteRecID" filterRenderer="wcmc.renderers.CountryFilterRenderer" sortLookupValues="false"/&gt;
	 * &lt;/listing&gt;
	 */	
	[Event(name="whereClauseSet", type="flash.events.Event")]
	public class Filter
	{
		public function Filter()
		{
		}
		private var _fromClause:String;
		[Bindable]
		/**
		 * The masterTableFilterFieldName is the name of the field in the master table that is used to filter the data in the master table
		 */		
		public var masterTableFilterFieldName:String;
		[Bindable]private var _sharedObjectName:String;
		private var _whereClause:String;
		/**
		 * Flag to determine how the lookup values are returned. If sortLookupValues is false the data are returned in the default table order. 
		 */		
		public var sortLookupValues:Boolean=true;
		[Bindable]
		/**
		 * Flag to indicate that lookup values have been returned from the server.
		 */		
		public var lookupValuesReturned:Boolean=false;
		[Bindable]
		/**
		 * Flag to indicate if the filter is empty.
		 */		
		public var filterEmpty:Boolean=false;
		/**
		 * Flag to indicate if this filter can be cleared. For a species page all data will be filtered by species and we do not want the filter to be cleared when clearAll is run on the filter collection. 
		 */		
		public var cannotClear:Boolean=false;
		/**
		 * Flag to indicate if the filter has changed when it is saved. 
		 */		
		private var readableFilterString:String;
		private var urlRequest:URLRequest=new URLRequest();
		private var urlLoader:URLLoader=new URLLoader();
		/**
		 * An array of the id values of all of the selected items in the lookup values. This is set when the filter is saved. 
		 */		
		public var selectedItems:Array=new Array();
		/**
		 * The table that the filter will use to show the lookup values and filter the data. 
		 */		
		public var table:String;
		/**
		 * The field name in the table that will provide the values in the lookupValues array. 
		 */		
		public var valueField:String;
		public var readableTableName:String;
		/**
		 * A pointer to the FilterCollection that this filter belongs to.
		 */		
		public var filterCollection:FilterCollection;
		[Bindable]
		/**
		 * The class that will be used to render the lookupValues in any dialog box. 
		 */		
		public var filterRenderer:IFactory;
		[Bindable]
		/**
		 * The label that will be used in any UI for this filter. 
		 */		
		public var label:String;
		[Bindable]
		/**
		 * An ArrayCollection of the values that are returned when a call to get lookup values is made. These lookup values will be filtered by all of the filters in the filterCollection.
		 */		
		public var lookupValues:ArrayCollection;
		[Bindable]
		/**
		 * A flag to indicate if this filter is currently filtering any data at all or if all siteRecIDs are returned from the &lt;table&gt;_LINK table. The filterCollection object has a filtered property which flags if there are any active filters within the collection. 
		 */		
		public var filtered:Boolean;
		public function get sharedObjectName():String
		{
			if (!_sharedObjectName) _sharedObjectName=table + "_filter";
			return _sharedObjectName;
		}
		public function set sharedObjectName(value:String):void
		{
			_sharedObjectName = value;
		}
		/**
		 * The SQL where clause for this individual filter. This is null unless one of more items are selected from lookupValues (but null if all items are selected). This is set when the filter is saved.
		 */
		public function get whereClause():String
		{
			return _whereClause;
		}
		
		/**
		 * @private
		 */
		public function set whereClause(value:String):void
		{
			_whereClause = value;
			dispatchEvent(new Event("whereClauseSet"));
		}
		
		/**
		 * The SQL from clause for this individual filter. This is null unless one of more items are selected from lookupValues (but null if all items are selected). This is set when the filter is saved.
		 */
		public function get fromClause():String
		{
			return _fromClause;
		}
		
		/**
		 * @private
		 */
		public function set fromClause(value:String):void
		{
			_fromClause = value;
		}
		
		/**
		 * Returns the lookup values that can be used to populate any UI components. 
		 * 
		 */		
		public function getLookupValues():void
		{
			lookupValuesReturned=false;
			var sql:String=getLookupSQL(); //get the SQL statement to run on the server to return a set of lookup values
			urlLoader.addEventListener(Event.COMPLETE, _lookupValuesReturned); //create a listener to handle the asynchronous callback
			createURLRequest(sql,"GetLookupValues"); //create the request and call it
		}
		/**
		 * Returns the SQL statement to run on the server to return a set of lookup values 
		 * @return SQL Statement
		 * 
		 */		
		private function getLookupSQL():String
		{
			var whereClause:String=""; //initialise variables to empty strings
			var fromClause:String="";
			for each (var filter:Filter in filterCollection.filters) //iterate through all of the other filters to build the where and from clauses according to whether other filters will constrain the lookup values that are returned
			{
				if (filter!==this) //only build the from and where clauses from other filters, not this one
				{
					if (filter.whereClause!=null) whereClause=whereClause + filter.whereClause + " AND ";
					if (filter.fromClause!=null) fromClause=fromClause + filter.fromClause + " ";
				}
			}
			whereClause= whereClause.substr(0,whereClause.length-5); 
			if (whereClause=="") 
			{ //if there are no other filters active then get all of the values from the table
				if (sortLookupValues)
				{ //sort the values if specified
					return "SELECT DISTINCT " + table + "ID AS 'r/@id', " + valueField + " AS 'r/@val' FROM " + table + " ORDER BY " + valueField + " FOR XML PATH(''), ROOT('rows')";
				}
				else
				{
					return "SELECT DISTINCT " + table + "ID AS 'r/@id', " + valueField + " AS 'r/@val' FROM " + table + " FOR XML PATH(''), ROOT('rows')";
				}
			}
			else
			{ //if there are other filters active then create the SQL statement using their combined where and from clauses
				if (sortLookupValues)
				{
					return "SELECT DISTINCT " + table + "." + table + "ID AS 'r/@id', " + valueField + " AS 'r/@val' FROM " + table + " INNER JOIN " + table + "_LINK ON " + table + "." + table + "ID =" + table + "_LINK." + table + "ID INNER JOIN " + filterCollection.masterTableName + " ON " + table + "_LINK." + masterTableFilterFieldName + " = " + filterCollection.masterTableName + "." + masterTableFilterFieldName + " " + fromClause + " WHERE " + whereClause + " ORDER BY " + valueField + " FOR XML PATH(''), ROOT('rows')";
				}
				else
				{
					return "SELECT DISTINCT " + table + "." + table + "ID AS 'r/@id', " + valueField + " AS 'r/@val' FROM " + table + " INNER JOIN " + table + "_LINK ON " + table + "." + table + "ID =" + table + "_LINK." + table + "ID INNER JOIN " + filterCollection.masterTableName + " ON " + table + "_LINK." + masterTableFilterFieldName + " = " + filterCollection.masterTableName + "." + masterTableFilterFieldName + " " + fromClause + " WHERE " + whereClause + " FOR XML PATH(''), ROOT('rows')";
				}
			}
		}
		/**
		 * Asynchronous return call that populates the set of lookup values that are used in any UI components. 
		 * @param event
		 * 
		 */		
		private function _lookupValuesReturned(event:Event):void
		{
			urlLoader.removeEventListener(Event.COMPLETE, _lookupValuesReturned); 
			var xml:XML=new XML(urlLoader.data); //create a new XML object with the returned data 
			var _lookupValues:ArrayCollection=new ArrayCollection(); //initialise a new array collection to hold the lookup values
			var selectAll:Boolean=((selectedItems.length==0)||(!filterCollection.filtered)); //select all values if no items are selected or if no filters are active
			for each (var xml2:XML in xml.children()) //iterate through the XML nodes
			{
				var lookupValue:LookupValue=new LookupValue(); //instantiate a new lookup value - this is used in the lookup value renderer to render the UI
				lookupValue.id=xml2.attribute('id'); //unique identifier for the lookup value - this is the primary key from the &lt;table&gt; table
				lookupValue.value=xml2.attribute('val'); //the value that will be displayed in any UI
				(selectAll) ? lookupValue.selected=true : lookupValue.selected=(selectedItems.indexOf(lookupValue.id)>=0); //set the check box as selected if the value is currently in the filter, or all selected if there are no current selected items
				_lookupValues.addItem(lookupValue); //add the lookup value
			}
			lookupValues=_lookupValues; //set the lookup values
			lookupValuesReturned=true;
			dispatchEvent(new Event("lookupValuesReturned")); //fire the event
		}
		/**
		 * Simple method to create the url request and call it 
		 * @param sql
		 * @param method
		 * 
		 */		
		private function createURLRequest(sql:String,method:String):void
		{
			urlRequest.url="http://dev.unep-wcmc.org/CSN_WebServices/DataServices.asmx/" + method + "?sql=" + sql;
			urlLoader.load(urlRequest);
		}
		public function save():void
		{
			var inClause:String=""; //initialise to empty string
			clear(false); //resets the filter variables without saving
			if (!lookupValues) return;
			for each (var lookupValue:LookupValue in lookupValues) //iterate through the lookup values and build the inclause that will be used in the SQL statement based on if the lookup value is selected or not
			{
				if (lookupValue.selected) //if the lookup value is selected
				{ 
					inClause=inClause + lookupValue.id.toString() + ",";
					selectedItems.push(lookupValue.id); //add the selected lookup values id to the selectedItems array
					readableFilterString=readableFilterString + lookupValue.value + ", " ;
				}
			}
			switch (selectedItems.length) //take action depending on what is selected in this filter
			{
				case 0: //nothing selected - fire an event and exit
				{
					if (lookupValues.length>0)
					{
						filterEmpty=true;
						dispatchEvent(new Event("filterEmptyEvent",true));
						return;
					}
				}
				case (lookupValues.length): //everything selected - therefore this filter is not active - do nothing but keep the null default values for the where and from clauses so that this filter isnt used
				{
					break;
				}
				default: //some items selected so create the from and where clauses for the filter
				{
					whereClause=table + "_LINK." + table + "ID IN (" + inClause.substr(0,inClause.length-1) + ")";
					fromClause="INNER JOIN " + table + "_LINK ON " + table + "_LINK." + masterTableFilterFieldName + " = " + filterCollection.masterTableName + "." + masterTableFilterFieldName; //e.g. COUNTRY_LINK INNER JOIN CSN_IBA ON COUNTRY_LINK.SiteRecID = CSN_IBA.SiteRecID
					readableFilterString= "'" + readableTableName + "' filtered by: " + readableFilterString.substr(0,readableFilterString.length-2);
					filtered=true;
					break;
				}
			}
			saveToSharedObject(); //save the filter to the shared object
		}
		/**
		 * Persists the filter to a shared object 
		 * 
		 */		
		private function saveToSharedObject():void
		{
			var mySO:SharedObject=SharedObject.getLocal(sharedObjectName);
			if (!((mySO.data.fromClause==fromClause)&&(mySO.data.whereClause==whereClause))) //only save the data if the filter has changed
			{
				mySO.data.selectedItems=selectedItems;
				mySO.data.fromClause=fromClause;
				mySO.data.whereClause=whereClause;
				mySO.data.filtered=filtered;
				mySO.flush();
				dispatchEvent(new Event("filterSavedEvent",true)); //fire an event
			}
		}
		/**
		 * Clears the filter and optionally saves it 
		 * 
		 */		
		public function clear(save:Boolean):void
		{
			if (!cannotClear)
			{
				readableFilterString="";
				whereClause=null;
				fromClause=null;
				filterEmpty=false;
				selectedItems=[]; //empty the selected items array
				filtered=false; //default value
				if (save) saveToSharedObject(); //save the filter to the shared object
			}
		}
		public function setProgrammatically(selectedValues:ArrayCollection,cannotClear:Boolean):void
		{
			if (!selectedValues) return;
			clear(false); //may have been initialised from a stored object so clear it before setting it programmatically
			this.cannotClear=cannotClear;
			lookupValues=selectedValues;
			var dummyLookupValue:LookupValue=new LookupValue(); //required to avoid the 'case (lookupValues.length)' switch in the Save function
			dummyLookupValue.id=-1;
			dummyLookupValue.selected=false;
			dummyLookupValue.value="";
			lookupValues.addItem(dummyLookupValue);
			save();
		}
	}
}


package wcmc.classes// this is the package information
{
	import com.esri.ags.FeatureSet;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.tasks.QueryTask;
	import com.esri.ags.tasks.supportClasses.Query;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.UIComponent;
	import mx.rpc.AsyncResponder;
	/**
	 * Singleton class that provides non-spatial data access objects to the UI layer. This class is used extensively by the CSN class to retrieve species, sites, IBA, IWC and other data from the server. The class uses a combination of methods to retrieve the data but the most widely used is to
	 * execute an asynchronous request to a REST endpoint (using ArcGIS Server 10) and to retrieve the results in a function enclosed in the same block. The results of this asynchronous return call are delivered back to the UI using a set of custom Event classes. 
	 * @author andrewcottam
	 * 
	 */
	    public class DAO extends UIComponent
	    {
		/**
		 * Dispatched when a data request is completed. The data can be retrieved from the results property.
		 */		
		[Event(name="dataRetrieved", type="wcmc.classes.AGSResult")]
		        public function DAO()
		        {
		        }
		/**
		 * Return species information for the passed SpcRecIDs. StronglyTypedReturn determines the return type of the items in the arraycollection - if true then the arraycollection will be populated with species class objects  
		 * @param commonNameField The name of the commonNameField to return. The actual field that is returned will depend on the language for the current application.
		 * @param SpcRecIDs If this parameter is null then all species are returned; if this parameter is a single value then a single species is returned; if this value is an array then multiple species are returned.
		 * @param stronglyTypedReturn If this is true then the results will be strongly typed (i.e. instances of the Species class).
		 * 
		 */
		public function getSpecies(commonNameField:String,SpcRecIDs:ArrayCollection=null,stronglyTypedReturn:Boolean=true):void
		{
			var queryTask:QueryTask=new QueryTask("http://dev.unep-wcmc.org/ArcGIS/rest/services/CSN/Species/MapServer/5"); //'Species data' table
			var query:Query=new Query;
			query.returnGeometry=false;
			query.outFields=["*"];
			if (!SpcRecIDs) 
			{
				query.where="SpcRecID>-1"; //get info for all species	
			}
			else
			{
				if (SpcRecIDs.length==1)
				{
					query.where="SpcRecID=" + SpcRecIDs; //get info for one species
				}
				else
				{
					var inClause:String=createSpeciesInClause(SpcRecIDs); //get info for a array of species - this array will come from an array of lookup values from a filter - so the SpcRecID property is 'id'
					query.where="SpcRecID In (" + inClause + ")";
				}
			}
			queryTask.execute(query, new AsyncResponder(onResult, onFault)); //execute the query
			var _ac:ArrayCollection=new ArrayCollection();
			function onResult(featureSet:FeatureSet, token:Object = null):void
			{
				for each (var object:Object in featureSet.attributes)
				{
					if (stronglyTypedReturn)
					{
						var species:Species=populateSpeciesObject(commonNameField,object); //create the stronglt typed array collection
						_ac.addItem(species);
					}
					else
					{
						_ac.addItem(object);
					}
				}
				_ac.source.sortOn("commonName"); //sort the species on the common name field
				_ac.refresh();
				dispatchEvent(new AGSResult(AGSResult.SPECIES,_ac)); //dispatch the event to pass the data back to the UI
			}
		}
		/**
		 * Returns the Waterbird Population Estimates for a species. 
		 * @param SpcRecID The species ID.
		 * @return An array collection of the population estimates.
		 * 
		 */	
		public function getWaterbirdPopulationEstimates(SpcRecID:Number):ArrayCollection
		{
			var queryTask:QueryTask=new QueryTask("http://dev.unep-wcmc.org/ArcGIS/rest/services/CSN/Species/MapServer/6"); //'Flyway population estimates' 
			var query:Query=new Query;
			query.returnGeometry=false;
			query.outFields=["*"];
			query.where="SpcRecID=" + SpcRecID;
			queryTask.execute(query, new AsyncResponder(onResult, onFault));
			var _ac:ArrayCollection=new ArrayCollection();
			function onResult(featureSet:FeatureSet, token:Object = null):void
			{
				for each (var object:Object in featureSet.attributes)
				{
					_ac.addItem(object);
				}
				_ac.source.sortOn("flyway");
				_ac.refresh();
				dispatchEvent(new AGSResult(AGSResult.WPE,_ac));
			}
			return _ac;
		}
		/**
		 * Returns an individual site feature using the passed site object. 
		 * @param site The site object to retrieve.
		 * 
		 */			
		public function getSiteFeature(site:Site):void
		{
			if (site)
			{
				var queryTask:QueryTask;
				if (site.isPoly)
				{
					queryTask=new QueryTask("http://dev.unep-wcmc.org/ArcGIS/rest/services/CSN/Sites/MapServer/1"); //'Site polygons' layer
				}
				else
				{
					queryTask=new QueryTask("http://dev.unep-wcmc.org/ArcGIS/rest/services/CSN/Sites/MapServer/0");	//'Site points' layer
				}
				var ibaQuery:Query=new Query();
				ibaQuery.returnGeometry=true;
				ibaQuery.outFields=["Name","SiteRecID","CountryCode"];
				ibaQuery.where="SiteRecID=" + site.siteRecID;
				queryTask.execute(ibaQuery, new AsyncResponder(onResult, onFault));
				var _ac:ArrayCollection=new ArrayCollection();
				function onResult(featureSet:FeatureSet, token:Object = null):void
				{
					for each (var object:Object in featureSet.features)
					{
						_ac.addItem(object);
					}
					dispatchEvent(new AGSResult(AGSResult.SITE,_ac));
				}
			}
		}
		/**
		 * Returns non-spatial information for a site. This is used if the sites page is called directly.
		 * @param SiteRecIDs The siteRecID of the site to find.
		 * @param searchText If set the query will also search for a site which contains the searchText.
		 * @return 
		 * 
		 */			
		public function getSite(SiteRecIDs:String=null,searchText:String=null):ArrayCollection
		{
			var queryTask:QueryTask=new QueryTask("http://dev.unep-wcmc.org/ArcGIS/rest/services/CSN/Sites/MapServer/9"); //'Sites data' table
			queryTask.showBusyCursor=true;
			var query:Query=new Query;
			query.returnGeometry=false;
			query.outFields=["*"];
			if (!SiteRecIDs)
			{
				query.where="SiteRecID>-1";
			}
			else
			{
				(SiteRecIDs.indexOf(",")>-1) ? query.where="SiteRecID In (" + SiteRecIDs + ")":	query.where="SiteRecID=" + SiteRecIDs;
			}
			if (searchText) query.where=query.where + " and name like '%" + searchText + "%'";
			queryTask.execute(query, new AsyncResponder(onResult, onFault));
			var _ac:ArrayCollection=new ArrayCollection();
			function onResult(featureSet:FeatureSet, token:Object = null):void
			{
				for each (var object:Object in featureSet.attributes)
				{
					var site:Site=populateSiteObject(object);
					_ac.addItem(site);
				}
				_ac.source.sortOn(["sortNo","name"],[Array.NUMERIC,Array.CASEINSENSITIVE]);
				_ac.refresh();
				dispatchEvent(new AGSResult(AGSResult.SITE,_ac));
			}
			return _ac;
		}
		/**
		 * Returns the IWC counts for the passed site code and species. 
		 * @param siteCode The IWC sitecode to search on. 
		 * @param spcRecID The species ID to search on.
		 * 
		 */			
		public function getCountsForIWC(siteCode:String,spcRecID:Number):void
		{
			var queryTask:QueryTask=new QueryTask("http://dev.unep-wcmc.org/ArcGIS/rest/services/CSN/Sites/MapServer/10"); // 'IWC counts' table
			var query:Query=new Query;
			query.returnGeometry=false;
			query.outFields=["*"];
			if (siteCode.search(",")>0)
			{
				query.where="SiteCode In (" + siteCode + ") and SpcRecID=" + spcRecID;
			}
			else
			{
				query.where="SiteCode='" + siteCode + "' and SpcRecID=" + spcRecID;
			}
			queryTask.execute(query, new AsyncResponder(onResult, onFault));
			var allCounts:ArrayCollection=new ArrayCollection(); //all counts - i.e. could have many counts for 1 year from lots of sites
			var yearCounts:ArrayCollection; //counts summarised by year
			function onResult(featureSet:FeatureSet, token:Object = null):void
			{
				for each (var object:Object in featureSet.attributes)
				{
					var speciesCount:SpeciesCount=populateSpeciesCount(object,"SiteCode");
					allCounts.addItem(speciesCount);
				}
				yearCounts=getYearCounts(allCounts); //summarise the counts by year
				dispatchEvent(new AGSResult(AGSResult.IWCCOUNTS,yearCounts));
			}
		}
		/**
		 * Returns a species list for a site. 
		 * @param commonNameField The common name field to be used for retrieving the species names. 
		 * @param siteRecID The site to retrieve a species list for.
		 * @return 
		 * 
		 */			
		public function getSpeciesListForSite(commonNameField:String,siteRecID:Number):ArrayCollection
		{
			var queryTask:QueryTask=new QueryTask("http://dev.unep-wcmc.org/ArcGIS/rest/services/CSN/Sites/MapServer/11"); // 'Site CSN Data' table
			var query:Query=new Query;
			query.returnGeometry=false;
			query.outFields=["*"];
			query.where="SiteRecID=" + siteRecID;
			queryTask.execute(query, new AsyncResponder(onResult, onFault));
			var _ac:ArrayCollection=new ArrayCollection();
			function onResult(featureSet:FeatureSet, token:Object = null):void
			{
				for each (var object:Object in featureSet.attributes)
				{
					_ac.addItem(object);
				}
				_ac.source.sortOn("Species");
				_ac.refresh();
				dispatchEvent(new AGSResult(AGSResult.SITESPECIESLIST,_ac));
			}
			return _ac;
		}
		/**
		 * Returns a flyways list for a point. 
		 * @param commonNameField The common name field to be used for retrieving the species names. 
		 * @param mapPoint The mapPoint where the user clicked.
		 * @return 
		 * 
		 */			
		public function getFlywaysForPoint(commonNameField:String,mapPoint:MapPoint):void
		{
			var queryTask:QueryTask=new QueryTask("http://dev.unep-wcmc.org/ArcGIS/rest/services/CSN/Reports/MapServer/0"); // 'Species for a point report' layer
			var query:Query=new Query;
			query.returnGeometry=false;
			query.outFields=["SpcFlyRecID"];
			query.geometry=mapPoint;
			queryTask.execute(query, new AsyncResponder(onResult, onFault));
			function onResult(featureSet:FeatureSet, token:Object = null):void
			{
				var ac:ArrayCollection=getFlywayIDs(featureSet);
				dispatchEvent(new AGSResult(AGSResult.POINTFLYWAYSLIST,ac));
			}
		}
		/**
		 * Returns a set of SpcFlyRecIDs for a country 
		 * @param countryID The countryID for the country 
		 * @param justSpcFlyRecIDs If true only return the SpcFlyRecIDs
		 * @return 
		 * 
		 */			
		public function getFlywaysForCountry(countryID:Number):void
		{
			var queryTask:QueryTask=new QueryTask("http://dev.unep-wcmc.org/ArcGIS/rest/services/CSN/Reports/MapServer/5"); // 'Flyway Countries' layer
			var query:Query=new Query;
			query.returnGeometry=false;
			query.where="CountryID=" + countryID;
			query.outFields=["SpcFlyRecID"];
			queryTask.execute(query, new AsyncResponder(onResult, onFault));
			function onResult(featureSet:FeatureSet, token:Object = null):void
			{
				var ac:ArrayCollection=getFlywayIDs(featureSet);
				dispatchEvent(new AGSResult(AGSResult.COUNTRYFLYWAYSLIST,ac));
			}
		}
		private function getFlywayIDs(featureSet:FeatureSet):ArrayCollection
		{
			var ac:ArrayCollection=new ArrayCollection();
			for each (var object:Object in featureSet.attributes)
			{
				ac.addItem(object.SpcFlyRecID);
			}
			return ac;
		}
		/**
		 * Returns the IWC site codes that match the passed site. 
		 * @param siteRecID The siteRecID of the site to search for.
		 * 
		 */			
		public function getIWCSiteCodesForSiteRecID(siteRecID:Number):void
		{
			var queryTask:QueryTask=new QueryTask("http://dev.unep-wcmc.org/ArcGIS/rest/services/CSN/Sites/MapServer/4"); // 'IWC Points' layer
			var query:Query=new Query;
			query.returnGeometry=false;
			query.outFields=["SiteCode"];
			query.where="SiteRecID=" + siteRecID;
			queryTask.execute(query, new AsyncResponder(onResult, onFault));
			var _ac:ArrayCollection=new ArrayCollection();
			function onResult(featureSet:FeatureSet, token:Object = null):void
			{
				for each (var object:Object in featureSet.attributes)
				{
					_ac.addItem(object);
				}
				dispatchEvent(new AGSResult(AGSResult.IWCSITECODES,_ac));
			}
		}
		/**
		 * Returns the flyway population names for the passed species 
		 * @param spcRecID The species
		 * 
		 */			
		public function getFlyways(spcRecID:Number):ArrayCollection
		{
			var queryTask:QueryTask=new QueryTask("http://dev.unep-wcmc.org/ArcGIS/rest/services/CSN/Species/MapServer/6"); // 'Flyways' layer
			var query:Query=new Query;
			query.returnGeometry=false;
			query.outFields=["Flyway","SpcFlyRecID"];
			query.where="SpcRecID=" + spcRecID;
			queryTask.execute(query, new AsyncResponder(onResult, onFault));
			var _ac:ArrayCollection=new ArrayCollection();
			function onResult(featureSet:FeatureSet, token:Object = null):void
			{
				for each (var object:Object in featureSet.attributes)
				{
					_ac.addItem(object);
				}
				_ac.source.sortOn("Flyway");
				_ac.refresh();
			}
			return _ac;
		}
		
		public function getProtectionTypes():ArrayCollection
		{
			var queryTask:QueryTask=new QueryTask("http://dev.unep-wcmc.org/ArcGIS/rest/services/CSN/Reports/MapServer/7"); // 'Protection types' layer
			var query:Query=new Query;
			query.returnGeometry=false;
			query.outFields=["*"];
			query.where="ID>-1";
			queryTask.execute(query, new AsyncResponder(onResult, onFault));
			var _ac:ArrayCollection=new ArrayCollection();
			function onResult(featureSet:FeatureSet, token:Object = null):void
			{
				for each (var object:Object in featureSet.attributes)
				{
					_ac.addItem(object);
				}
				_ac.refresh();
			}
			return _ac;
		}
		
		public function getProtection(spcFlyRecID:String,protectionTypeID:int):ArrayCollection
		{
			var queryTask:QueryTask=new QueryTask("http://dev.unep-wcmc.org/ArcGIS/rest/services/CSN/Reports/MapServer/6"); // 'Protection totals' layer
			var query:Query=new Query;
			query.returnGeometry=false;
			query.outFields=["*"];
			query.where="SpcFlyRecID='" + spcFlyRecID + "' and ProtectionType=" + protectionTypeID;
			queryTask.execute(query, new AsyncResponder(onResult, onFault));
			var _ac:ArrayCollection=new ArrayCollection();
			function onResult(featureSet:FeatureSet, token:Object = null):void
			{
				for each (var object:Object in featureSet.attributes)
				{
					_ac.addItem(object);
				}
				if (_ac.length>0)
				{//add the totals if there is some data
					var BPercentTotal:int;
					var BTotal:int;
					var NBPercentTotal:int;
					var NBTotal:int;
					for each (var obj:Object in _ac)
					{
						BPercentTotal=BPercentTotal+ obj.BPercent;
						BTotal=BTotal+ obj.B;
						NBPercentTotal=NBPercentTotal+ obj.NBPercent;
						NBTotal=NBTotal+ obj.NB;
					}
					var totalObj:Object = new Object();
					totalObj.Region="TOTAL:";
					(BTotal>0) ? totalObj.BPercent=BPercentTotal : totalObj.BPercent=null;
					(BTotal>0) ? totalObj.B=BTotal : totalObj.B=null;
					(NBTotal>0) ? totalObj.NBPercent=NBPercentTotal : totalObj.NBPercent=null;
					(NBTotal>0) ? totalObj.NB=NBTotal : totalObj.NB=null;
					_ac.addItem(totalObj);
				}
			}
			return _ac;
		}
		/**
		 * Populates a strongly typed species object with data from an asynhronous return call 
		 * @param commonNameField The name of the field for the common name
		 * @param object The object containing the data to populated the species with.
		 * @return The species object.
		 * 
		 */			
		protected function populateSpeciesObject(commonNameField:String,object:Object):Species
		{
			var species:Species=new Species();
			species.commonName=object[commonNameField];
			species.englishCommonName=object["NameEN"];
			species.spcRecID=object.SpcRecID;
			species.scientificName=object.Species;
			species.spcRedCategory=object.SpcRedCategory;
			species.aewaID=object.AEWAId;
			return species;
		}
		/**
		 * Populates a strongly typed site object with data from an asynhronous return call 
		 * @param object The object containing the data to populated the site with.
		 * @return The site object.
		 * 
		 */			
		protected function populateSiteObject(object:Object):Site
		{
			var site:Site=new Site();
			site.countryCode=object.Country;
			site.isPoly=object.IsPoly;
			site.name=object.Name;
			site.siteRecID=object.SiteRecID;
			site.sortNo=object.SortNo;
			return site;				
		}
		/**
		 * Populates a strongly typed species count object with data from an asynhronous return call 
		 * @param object The object containing the data to populated the site with.
		 * @param SiteCodeField The name of the field that holds the site code.
		 * @return The speciesCount object.
		 * 
		 */			
		protected function populateSpeciesCount(object:Object,SiteCodeField:String):SpeciesCount
		{
			var speciesCount:SpeciesCount=new SpeciesCount();
			speciesCount.siteCode=object[SiteCodeField];
			speciesCount.spcRecID=object.SpcRecID;
			speciesCount.abundance=object.Count_;
			speciesCount._year=object.Year;
			return speciesCount;
		}
		/**
		 * Utility function to format a percentage value. 
		 * @param percentNumber The percentage value as a number
		 * @return A formatted percentage string.
		 * 
		 */			
		protected static function getPercent(percentNumber:Number):String
		{
			if (percentNumber>1)
			{
				return percentNumber.toFixed(0) + "%";
			}
			else
			{
				return "<1%";
			}
		}
		/**
		 * Utility function which adds up all species counts by year. 
		 * @param counts An ArrayCollection of counts for a species.
		 * @return An ArrayCollection of species counts that have been totalled for each year.
		 * 
		 */			
		protected function getYearCounts(counts:ArrayCollection):ArrayCollection //adds up species counts by year
		{
			var totals:Dictionary=new Dictionary(); //create a dictionary as a simple hash table to store each years data
			for each (var count:SpeciesCount in counts)
			{
				(!totals[count._year]) ? totals[count._year]=count.abundance : totals[count._year]+=count.abundance; //create an entry for each year and as you iterate through the counts, add the counts on to existing years
			}
			var yearCounts:ArrayCollection=new ArrayCollection();
			var array:Array=getUniqueDictionaryKeys(totals); //get the unique year values from the dictionary
			var Year:Object;
			for each (var number:Number in array) //iterate through each of the unique years and create a yearCount for each year
			{
				Year=getDictionaryItemWithKey(totals,number); 
				var yearCount:SpeciesCount=new SpeciesCount();
				yearCount._year=Number(Year);
				yearCount.abundance=totals[Year];
				yearCounts.addItem(yearCount);
			}
			return yearCounts;
		}
		/**
		 * Iterates through the keys for the dictionary and builds an array of all of the keys and sorts them 
		 * @param dictionary The dictionary to get unique values from.
		 * @return An array of unique values.
		 * 
		 */			
		protected function getUniqueDictionaryKeys(dictionary:Dictionary):Array
		{
			var array:Array=new Array();
			for (var item:Object in dictionary)
			{
				array.push(Number(item));
			}
			array.sort();
			return array;
		}
		/**
		 * Returns the item in the dictionary with the key that matches 'key' 
		 * @param dictionary The dictionary to get the item from.
		 * @param key The key of the item to find.
		 * @return The object.
		 * 
		 */			
		protected function getDictionaryItemWithKey(dictionary:Dictionary,key:Number):Object
		{
			for (var item:Object in dictionary)
			{
				if (Number(item)==key) return item;
			}
			return null;
		}
		/**
		 * Adds up species counts by year for all species at a site. Not currently implemented.
		 * @param counts All speces counts for a site.
		 * @return An array of species counts.
		 * 
		 */			
		protected function getSpeciesCounts(counts:ArrayCollection):ArrayCollection //adds up species counts by year for all species at a site
		{
			var speciesCountsDict:Dictionary=new Dictionary();
			for each (var count:SpeciesCount in counts) //iterate through all counts - these should be sorted by site, species, year
			{
				if (!speciesCountsDict[count.spcRecID]) speciesCountsDict[count.spcRecID]=new ArrayCollection(); //create a new dictionary for the species
				var yearCount:SpeciesCount=new SpeciesCount(); //create a new count to hold the year 1 data
				yearCount._year=count._year; //put the year in
				yearCount.abundance=count.abundance; //and the abundance
				(speciesCountsDict[count.spcRecID] as ArrayCollection).addItem(yearCount); //add the count to the array for the species
			}
			var speciesCounts:ArrayCollection=new ArrayCollection(); //iterate through the dictionary to create the return array
			for (var species:Object in speciesCountsDict)
			{
				var siteSpeciesCount:SiteSpeciesCount=new SiteSpeciesCount();
				siteSpeciesCount.spcRecID=Number(species);
				siteSpeciesCount.counts=speciesCountsDict[species] as ArrayCollection;
				speciesCounts.addItem(siteSpeciesCount);
			}
			return speciesCounts;
		}
		/**
		 * Converts an array of SpcRecIDs to an inClause  
		 * @param object An array collection of species IDs. 
		 * @param spAttributeName
		 * @return 
		 * 
		 */			
		public function createSpeciesInClause(object:ArrayCollection,spAttributeName:String=null):String
		{
			var inClause:String="";
			for each (var species:Object in object)
			{
				(spAttributeName) ? inClause+=species[spAttributeName] + "," : inClause+=species + ",";				
			}
			return inClause.substring(0,inClause.length-1);
		}
		/**
		 * Generic error handling function for all requests to the server. 
		 * @param info
		 * @param token
		 * 
		 */			
		protected function onFault(info:Object, token:Object = null):void
		{
			Alert.show("Unable to connect to server.","Critical Site Network Tool");
		}
		private function getSOAPData(url:String,inClause:String):void
		{
			var urlRequest:URLRequest = new URLRequest();
			urlRequest.url= url + "?&inClause=" + inClause;
			var urlLoader:URLLoader=new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE,complete);
			urlLoader.load(urlRequest);
		}
		private function complete(event:Event):void
		{
			//				var urlLoader:URLLoader=event.target as URLLoader;
			//				urlLoader.removeEventListener(Event.COMPLETE,complete);
			//				var ac:ArrayCollection=new ArrayCollection();
			//				var xml:XML=new XML(urlLoader.data); //create a new XML object with the returned data 
			//				for each (var obj:Object in xml[1].children())
			//				{
			//					ac.addItem(obj);
			//				}
			//				dispatchEvent(new AGSResult(AGSResult.SOAPRESULT,ac));
		}
	    }
}
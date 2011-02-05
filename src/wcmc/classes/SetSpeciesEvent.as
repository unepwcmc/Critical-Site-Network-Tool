package wcmc.classes
{
	import flash.events.Event;
	/**
	 * Event Class that is dispatched when the user selected any species. 
	 * @author andrewcottam
	 * 
	 */	
	public class SetSpeciesEvent extends Event
	{
		/**
		 * Constructor for the SetSpeciesEvent class.
		 * @param type Event type.
		 * @param species The current species that must be set. This must be fully populated.
		 * 
		 */		
		public function SetSpeciesEvent(type:String, species:Species)
		{
			super(type, true, false);
			this.species=species;
		}
		override public function clone():Event
		{
			return new SetSpeciesEvent(SETSPECIES,species);
		}
		/**
		 * The species that the user selected. 
		 */		
		public var species:Species;
		static public const SETSPECIES:String="setSpecies";
	}
	
}
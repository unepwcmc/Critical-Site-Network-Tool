package wcmc.classes
{
	import flash.events.Event;
	/**
	 * The LanguageChangedEvent is dispatched whenever the language in the application is changed. 
	 * @author andrewcottam
	 * 
	 */	
	public class LanguageChangedEvent extends Event
	{
		/**
		 * Constructor. 
		 * @param type
		 * @param language The language for the application. The valid values are given in the CSN class.
		 * @param bubbles
		 * @param cancelable
		 * 
		 */		
		public function LanguageChangedEvent(type:String, language:String,bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.language=language;
		}
		/**
		 * The current language. 
		 */		
		public var language:String;
		override public function clone():Event
		{
			return new LanguageChangedEvent(LANGUAGECHANGED,language);
		}
		static public const LANGUAGECHANGED:String="languageChanged";
	}
}
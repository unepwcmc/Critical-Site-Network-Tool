package wcmc.classes
{
	import mx.collections.ArrayCollection;
	[Bindable]
	public interface ILegend
	{
		function caption():String;
		function showLegend():Boolean;
		function items():ArrayCollection;
	}
}
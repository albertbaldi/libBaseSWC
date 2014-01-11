package components
{
	import spark.components.TextInput;

	public class TextInputLower extends TextInput
	{
		public function TextInputLower()
		{
			super();
		}

		[Bindable("change")]
		[Bindable("textChanged")]
		override public function get text():String
		{
			return text.toLowerCase();
		}

		override public function set text(value:String):void
		{
			text = (value ? '' : value.toLowerCase());
		}
	}
}

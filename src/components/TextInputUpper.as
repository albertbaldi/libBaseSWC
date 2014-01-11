package components
{
	import spark.components.TextInput;

	public class TextInputUpper extends TextInput
	{
		public function TextInputUpper()
		{
			super();
		}

		[Bindable("change")]
		[Bindable("textChanged")]
		override public function get text():String
		{
			return text.toUpperCase();
		}

		override public function set text(value:String):void
		{
			text = (value ? '' : value.toUpperCase());
		}
	}
}

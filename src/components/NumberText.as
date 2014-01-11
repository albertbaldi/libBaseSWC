package components
{
	import mx.formatters.CurrencyFormatter;
	
	import spark.components.TextInput;
	
	public class NumberText extends TextInput
	{
		private var _useFormatador:Boolean = false;
		
		public function NumberText()
		{
			super();
		}
		
		[Bindable("change")]
		[Bindable("textChanged")]
		public function get textNumber():Number
		{
			return (text== '' ? NaN : Number(text));
		}
		
		public function set textNumber(value:Number):void
		{
			text = (isNaN(value) ? '' : (_useFormatador ? formataValor(value) : value.toString()));
		}
		
		[Inspectable(category="General", enumeration="true,false", defaultValue="false")]
		public function set useFormatador(value:Boolean):void
		{
			_useFormatador = value;
		}
		
		protected function formataValor(value:Object):String
		{
			var cf:CurrencyFormatter = new CurrencyFormatter();
			cf.currencySymbol = '';
			cf.precision = 2;
			
			return cf.format(value);
		}
	}
}
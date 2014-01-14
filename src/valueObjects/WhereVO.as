package valueObjects
{
	import mx.formatters.DateFormatter;

	public class WhereVO
	{

		public var key:String;
		public var value:Object;
		public var connector:String;

		public function WhereVO(key:String, value:Object, connector:String = '='):void
		{
			this.key = key;
			this.value = value;
			this.connector = connector;
		}

		public function get formattedKey():String
		{
			if (value is Date)
				return 'date(' + key + ')';

			return key.toString();
		}

		public function get formattedValue():String
		{
			if (value is Date)
			{
				var df:DateFormatter = new DateFormatter;
				df.formatString = 'YYYY-MM-DD';
				return df.format(value);
			}

			return value.toString();
		}
	}
}

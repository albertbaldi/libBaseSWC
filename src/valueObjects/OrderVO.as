package valueObjects
{

	public class OrderVO
	{
		public var key:String;
		public var order:String;

		public function OrderVO(key:String, order:String = 'ASC')
		{
			this.key = key;
			this.order = order;
		}

		public function get formattedKey():String
		{
			if (key.toLowerCase() == 'hora')
				return 'strftime(\'%s\', ' + key + ')';

			return key.toString();
		}
	}
}

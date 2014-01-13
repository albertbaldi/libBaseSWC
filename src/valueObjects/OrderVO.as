package valueObjects
{

	public class OrderVO
	{
		public var campo:String;
		public var ordem:String;

		public function OrderVO(campo:String, ordem:String = 'ASC')
		{
			this.campo = campo;
			this.ordem = ordem;
		}
	}
}

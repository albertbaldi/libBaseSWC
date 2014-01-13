package valueObjects
{

	public class WhereVO
	{
		public var campo:String;
		public var valor:Object;

		public function WhereVO(campo:String, valor:Object)
		{
			this.campo = campo;
			this.valor = valor;
		}
	}
}

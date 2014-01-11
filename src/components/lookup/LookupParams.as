package components.lookup
{
	import flash.utils.getDefinitionByName;

	import mx.collections.ArrayList;

	public class LookupParams
	{
		private var _tipo:String;
		private var _controller:Object;
		private var _objectVO:Object;
		private var _classVO:Class;
		private var _columns:ArrayList;
		private var _codigoField:String;
		private var _nomeField:String;

		public function LookupParams(tipo:String, classVO:Class, objectVO:Object, columns:ArrayList, codigoField:String, nomeField:String)
		{
			this.tipo = tipo;
			this.classVO = classVO;
			this.objectVO = objectVO;
			this.columns = columns;
			this.codigoField = codigoField;
			this.nomeField = nomeField;
		}

		public function get tipo():String
		{
			return _tipo;
		}

		public function set tipo(value:String):void
		{
			_tipo = value;
		}

		public function get controller():Object
		{
			var className:String = 'controllers.' + firstCharToUpper(tipo) + 'Controller';
			var myClass:Class = getDefinitionByName(className) as Class;
			return new myClass();
		}

		[Bindable]
		public function get objectVO():Object
		{
			if (_objectVO == null)
				_objectVO = new classVO();
			return _objectVO;
		}

		public function set objectVO(value:Object):void
		{
			_objectVO = value;
		}

		[Bindable]
		public function get columns():ArrayList
		{
			return _columns;
		}

		public function set columns(value:ArrayList):void
		{
			_columns = value;
		}

		public function get codigoField():String
		{
			return _codigoField;
		}

		public function set codigoField(value:String):void
		{
			_codigoField = value;
		}

		public function get nomeField():String
		{
			return _nomeField;
		}

		public function set nomeField(value:String):void
		{
			_nomeField = value;
		}

		public function get classVO():Class
		{
			return _classVO;
		}

		public function set classVO(value:Class):void
		{
			_classVO = value;
		}

		private function firstCharToUpper(string:String):String
		{
			var string:String = string.toLowerCase();
			var firstLetter:String = string.charAt(0).toUpperCase();
			var restWord:String = string.substr(1, string.length);

			string = firstLetter + restWord;
			return string;
		}

	}
}

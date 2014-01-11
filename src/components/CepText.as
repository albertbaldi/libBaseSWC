package components
{
	import flash.events.FocusEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import spark.components.TextInput;

	public class CepText extends TextInput
	{
		private var httpService:HTTPService = new HTTPService;

		public function set resultFunction(value:Function):void
		{
			httpService.addEventListener(ResultEvent.RESULT, value);
		}

		public function CepText()
		{
			super();
			httpService.method = "POST";
			httpService.showBusyCursor = true;
			httpService.resultFormat = HTTPService.RESULT_FORMAT_E4X;
		}

		override protected function focusOutHandler(event:FocusEvent):void
		{
			super.focusOutHandler(event);
			if (text != null && text.length == 8)
			{
				httpService.url = "http://www.buscarcep.com.br/?cep=" + text + "&formato=xml&chave=1lHnX/i6wmquNzaEvLKMh3gZNePYDv/"
				httpService.send();
			}
		}
	}
}

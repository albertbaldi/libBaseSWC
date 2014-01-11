package components
{
	import mx.formatters.CurrencyFormatter;
	import mx.formatters.DateFormatter;
	import mx.formatters.SwitchSymbolFormatter;
	
	import spark.components.gridClasses.GridColumn;
	
	/**
	 * Classe para criar uma <code>GridColumn</code>.
	 * @author albert.lima
	 * 
	 */
	public class GridColumnEx extends GridColumn
	{
		/**
		 * Cria uma coluna para ser utilizada no <code>spark.components.DataGrid</code>. Permite ser instanciada informando parametros customizados.
		 * @param dataField Coluna da tabela no banco de dados
		 * @param headerText Cabeçalho para a coluna. Se não informado, o <code>dataField</code> é utilizado
		 * @param width Tamanho da coluna. Se campo for <code>data</code>, <code>cpf</code>, <code>cnpj</code> ou <code>telefone</code> é utilizado um tamanho padrão para cada coluna  
		 * @param labelFunction Função para tratamento do valor a ser exibido. Se não informado, é utilizado uma função interna que formata campos <code>monetários</code>, <code>data</code>, <code>cpf</code>, <code>cnpj</code> e <code>telefone</code>
		 * 
		 */
		public function GridColumnEx(dataField:String, headerText:String = null, width:int = 0, labelFunction:Function = null)
		{
			super();

			this.dataField = dataField;
			this.headerText = (headerText == null ? dataField : headerText);
			if(width > 0) this.width = width;
			if(labelFunction == null) labelFunction = DefaultLabelFunction; 
			this.labelFunction = labelFunction;
		}

		
		/**
		 * Formata o valor de uma coluna a partir do nome do campo
		 * @param item Registro da linha
		 * @param col Coluna referente ao campo
		 * @return Texto formatado segundo o nome do campo
		 * 
		 */
		private function DefaultLabelFunction(item:Object, col:GridColumn):String
		{
			var retorno:String = item[col.dataField].toString();
			
			if(col.dataField.toLowerCase().indexOf('valor') > -1)
			{
				retorno = formataValor(item[col.dataField]);	
			}else {
				retorno = formataCampo(item, col.dataField);
			}
			
			return retorno; 
		}
		
		
		/**
		 * Permite formatar um campo monetario
		 * @param value Valor a ser formatado
		 * @return Texto formatado
		 * 
		 */
		private function formataValor(value:Object):String
		{
			var cf:CurrencyFormatter = new CurrencyFormatter();
			cf.decimalSeparatorFrom = '.';
			cf.decimalSeparatorTo = ',';
			cf.thousandsSeparatorFrom = '';
			cf.thousandsSeparatorTo='.';
			cf.precision = 2;
			cf.currencySymbol = 'R$ ';
			
			return cf.format(value);
		}
		
		/**
		 * Permite formatar um campo de acordo com seu conteudo/nome
		 * @param item Contem os dados para serem formatados
		 * @param campo Informa o campo dentro do item que se deseja formatar
		 * @param valorPadrao Texto padrao caso o conteudo do campo seja nulo/vazio
		 * @return Texto formatado
		 * 
		 */
		private function formataCampo(item:Object, campo:String, valorPadrao:String = null):String
		{
			var switcher:SwitchSymbolFormatter = new SwitchSymbolFormatter('#');
			var df:DateFormatter = new DateFormatter;
			var retorno:String = "";
			
			if(item[campo] == null)
			{
				if(valorPadrao != null)
				{
					return valorPadrao;
				}
				return retorno;
			}else {
				retorno = item[campo];
			}
			
			if(item[campo] is Date)
			{
				//define o tamanho da coluna
				this.width = 80;
				
				df.formatString = "DD/MM/YYYY HH:NN:SS";
				retorno = df.format(item[campo]);
				retorno = retorno.replace('00:00:00','').replace('24:00:00','');
				
			}else {
				//caso seja outro tipo de campo, aplica conforme o switch
				switch(campo.toLowerCase())
				{
					case 'cnpj':
						//define o tamanho da coluna
						this.width = 130;
						
						retorno =  switcher.formatValue("##.###.###/####-##", item[campo]);
						break;
					case 'cpf':
						//define o tamanho da coluna
						this.width = 105;

						retorno =  switcher.formatValue("###.###.###-##", item[campo]);
						break;
					case 'telefone':
					case 'celular':
					case 'fax':
						//define o tamanho da coluna
						this.width = 105;

						retorno =  switcher.formatValue("(##) ####-####", item[campo]);
						break;
				}
			}
			
			return retorno;
		}
		
		
	}
}
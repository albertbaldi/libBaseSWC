package components.lookup
{
	import components.ActionButton;

	import flash.events.FocusEvent;
	import flash.events.MouseEvent;

	import mx.binding.utils.BindingUtils;
	import mx.rpc.events.ResultEvent;

	import spark.components.HGroup;
	import spark.components.TextInput;

	/**
	 * Lookup para pesquisa de registros
	 * @author albert.lima
	 *
	 */
	public class Lookup extends HGroup
	{
		private var btnSearch:ActionButton;
		private var lookupParams:LookupParams;
		private var lkpGrid:LookupGrid;
		private var txtCodigo:TextInput;
		private var txtNome:TextInput;

		public function Lookup()
		{
			super();
			this.initComponents();
		}

		/**
		 * Inicializa os componentes da classe
		 *
		 */
		protected function initComponents():void
		{
			//codigo textinput
			txtCodigo = new TextInput;
			txtCodigo.width = 40;
			txtCodigo.addEventListener(FocusEvent.FOCUS_OUT, txtCodigo_focusOutHandler);
			this.addElement(txtCodigo);

			//nome textinput
			txtNome = new TextInput;
			txtNome.editable = false;
			this.addElement(txtNome);

			//search button
			btnSearch = new ActionButton;
			btnSearch.label = '...';
			btnSearch.width = 35;
			btnSearch.addEventListener(MouseEvent.CLICK, btnSearch_clickHandler);
			this.addElement(btnSearch);
		}

		/**
		 * Variavel responsavel por manter os parametros do lookup
		 * @param value Instancia da classe <code>LookupParams</code> contendo os parametros
		 *
		 */
		public function set LookupParams(value:LookupParams):void
		{
			this.lookupParams = value;

			bindProperty();
		}

		/**
		 * Recupera o item selecionado no lookup
		 * Este método é invocado pelo controle pai do <code>Lookup</code>
		 */
		public function GetSelectedItem():*
		{
			return lookupParams.objectVO;
		}

		/**
		 * Consulta o registro na tabela no banco de dados
		 * @param id Identificador do registro
		 *
		 */
		private function getRow(id:int):void
		{
			lookupParams.objectVO = lookupParams.controller.getRow(lookupParams.classVO, id);
			bindProperty();
		}

		/**
		 * Realiza o bind das propriedades do <code>objectVO</code> para os controles da tela
		 *
		 */
		private function bindProperty():void
		{
			BindingUtils.bindProperty(txtCodigo, 'text', lookupParams.objectVO, lookupParams.codigoField);
			BindingUtils.bindProperty(txtNome, 'text', lookupParams.objectVO, lookupParams.nomeField);
		}

		/**
		 * Escuta do evento <code>ResultEvent.RESULT</code> disparado no <code>LookupGrid</code> quando selecionado um item no grid
		 * @param event Evento <code>ResultEvent.RESULT</code>
		 *
		 */
		protected function objectVO_resultHandler(event:ResultEvent):void
		{
			if (event.result != null)
				getRow(parseInt(event.result.id));
		}

		protected function txtCodigo_focusOutHandler(event:FocusEvent):void
		{
			getRow(parseInt(txtCodigo.text));
		}

		protected function btnSearch_clickHandler(event:MouseEvent):void
		{
			lkpGrid = new LookupGrid;
			lkpGrid.LookupParams = this.lookupParams;
			lkpGrid.addEventListener(ResultEvent.RESULT, objectVO_resultHandler);
			lookupParams.controller.abrirJanela(lkpGrid, 'lookupGrid', true);
		}

	}
}

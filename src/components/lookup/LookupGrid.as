package components.lookup
{
	import flash.events.MouseEvent;

	import mx.collections.ArrayCollection;
	import mx.events.CloseEvent;
	import mx.rpc.events.ResultEvent;

	import spark.components.Button;
	import spark.components.DataGrid;
	import spark.components.TitleWindow;

	/**
	 * DataGrid para pesquisa de itens de um <code>Lookup</code>
	 * @author albert.lima
	 *
	 */
	public class LookupGrid extends TitleWindow
	{
		private var dg:DataGrid;
		private var btnAccept:Button;
		private var btnCancel:Button;
		private var dataProvider:ArrayCollection;
		private var lookupParams:LookupParams;

		public function LookupGrid()
		{
			super();
			this.title = 'Pesquisar Registros';
			this.width = 400;
			this.height = 300;
			this.addEventListener(CloseEvent.CLOSE, closeHandler);
			this.controlBarContent = new Array();
		}

		/**
		 * Inicializa os componentes da classe
		 *
		 */
		protected function initComponents():void
		{
			//datagrid
			dg = new DataGrid();
			dg.width = this.width;
			dg.height = this.height;
			dg.columns = lookupParams.columns;
			dg.dataProvider = this.dataProvider;
			dg.doubleClickEnabled = true;
			dg.addEventListener(MouseEvent.DOUBLE_CLICK, dg_doubleClickHandler);
			this.addElement(dg);

			//accept button
			btnAccept = new Button();
			btnAccept.label = 'OK';
			btnAccept.addEventListener(MouseEvent.CLICK, btnAccept_clickHandler);
			this.controlBarContent.push(btnAccept);

			//cancel button
			btnCancel = new Button();
			btnCancel.label = 'Cancelar';
			btnCancel.addEventListener(MouseEvent.CLICK, btnCancel_clickHandler);
			this.controlBarContent.push(btnCancel);
		}

		/**
		 * Variavel responsavel por manter os parametros do lookup
		 * @param value Instancia da classe <code>LookupParams</code> contendo os parametros
		 *
		 */
		public function set LookupParams(value:LookupParams):void
		{
			lookupParams = value;

			//invoca metodo para carregar a lista de registros
			dataProvider = lookupParams.controller.getRows();

			this.initComponents();
		}

		/**
		 * Fecha a janela de grid do lookup
		 * Caso haja algum item no datagrid selecionado, dispara um <code>ResultEvent</code> com o item selecionado
		 * @param event Evento <code>CloseEvent.CLOSE</code>
		 *
		 */
		protected function closeHandler(event:CloseEvent):void
		{
			var item:Object = null;

			if (dg.selectedIndex > -1)
				item = dg.selectedItem;

			dataProvider = null;

			//dispara evento quando selecionado um item
			dispatchEvent(new ResultEvent(ResultEvent.RESULT, true, false, item));

			//fecha a janela
			lookupParams.controller.fecharJanela(this);
		}


		protected function btnAccept_clickHandler(event:MouseEvent):void
		{
			this.closeHandler(new CloseEvent(CloseEvent.CLOSE));
		}

		protected function btnCancel_clickHandler(event:MouseEvent):void
		{
			dg.selectedIndex = -1;
			this.closeHandler(new CloseEvent(CloseEvent.CLOSE));
		}

		protected function dg_doubleClickHandler(event:MouseEvent):void
		{
			this.btnAccept_clickHandler(new MouseEvent(MouseEvent.CLICK));
		}

	}
}

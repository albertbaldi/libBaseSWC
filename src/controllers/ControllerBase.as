package controllers
{
	import com.adobe.air.alert.NativeAlert;
	import com.adobe.utils.DateUtil;
	import com.adobe.utils.StringUtil;
	import com.darronschall.serialization.ObjectTranslator;

	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	import flash.desktop.NativeApplication;
	import flash.display.DisplayObject;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowType;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.formatters.CurrencyFormatter;
	import mx.formatters.DateFormatter;
	import mx.formatters.SwitchSymbolFormatter;
	import mx.managers.CursorManager;
	import mx.managers.SystemManager;
	import mx.utils.ObjectUtil;

	import spark.components.gridClasses.GridColumn;

	import components.ExtendedNativeWindow;

	import valueObjects.AppInfoVO;

	/**
	 *
	 * @author albert.lima
	 */
	public class ControllerBase
	{
		private var _database:File = File.documentsDirectory.resolvePath(appInfo.appId + '.sqlite');
		private var _conn:SQLConnection;
		private var _stmt:SQLStatement;
		private var _classVO:Class;
		private var _charParam:String = ':';

		/**
		 * Formata o valor de uma coluna a partir do nome do campo
		 * @param item Registro da linha
		 * @param col Coluna referente ao campo
		 * @return Texto formatado segundo o nome do campo
		 *
		 */
		public static function labelFunction(item:Object, col:GridColumn):String
		{
			var controller:ControllerBase = new ControllerBase;
			return controller.labelFunction(item, col);
		}

		public static function get initOptions():NativeWindowInitOptions
		{
			var controller:ControllerBase = new ControllerBase;
			return controller.initOptions;
		}

		/**
		 * Nivel mais alto da aplicacao
		 * @return Objeto referente ao nivel mais alto da aplicacao
		 *
		 */
		public function get root():Object
		{
			return SystemManager.getSWFRoot(FlexGlobals.topLevelApplication);
		}

		/**
		 * Objeto VO da classe controller
		 * @return Objeto tipado utilizado pelo controller
		 *
		 */
		public function get objectVO():Object
		{
			var className:String = 'valueObjects.' + firstCharToUpper(tabela) + 'VO';
			var cls:Class = getDefinitionByName(className) as Class;
			return new cls;
		}

		/**
		 * Caracter para identificação do item de parâmetro
		 * O valor default é <code>:</code>
		 * @return Identificador de parâmetro para o SQL
		 *
		 */
		public function get charParam():String
		{
			return this._charParam;
		}

		public function set charParam(value:String):void
		{
			this._charParam = value;
		}

		/**
		 * Informações sobre o sitema
		 * @return Objeto <code>AppInfoVO</code> contendo o <code>id</code>,
		 * <code>Version</code> e <code>Name</code> da aplicação
		 *
		 */
		public function get appInfo():AppInfoVO
		{
			var appXml:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = appXml.namespace();

			return new AppInfoVO(appXml.ns::id[0], appXml.ns::version[0], appXml.ns::filename[0]);
		}

		/**
		 * Tabela para acesso ao banco de dados
		 * @return Nome da tabel a partir da instancia da classe
		 *
		 */
		public function get tabela():String
		{
			var className:String = flash.utils.getQualifiedClassName(this).toLowerCase();
			className = className.substring(className.lastIndexOf(':') + 1).replace('controller', '');
			return className;
		}

		/**
		 * Estabelece uma conexao com o banco de dados
		 * @return Conexao ativa com o banco de dados
		 *
		 */
		public function get conn():SQLConnection
		{
			if (isNullOrEmpty(_conn))
			{
				_conn = new SQLConnection;
				_conn.addEventListener(SQLErrorEvent.ERROR, onError);
			}

			if (!_conn.connected)
				_conn.open(_database);
			return _conn;
		}

		/**
		 * Ponto de entrada da conexão com o banco de dados
		 * Através do <code>stmt</code> é possível setar os comandos SQL
		 * @return Ponto de entrada com o banco de dados
		 *
		 */
		public function get stmt():SQLStatement
		{
			if (isNullOrEmpty(_stmt))
			{
				_stmt = new SQLStatement;
				_stmt.addEventListener(SQLErrorEvent.ERROR, onError);
				_stmt.addEventListener(SQLEvent.RESULT, onResult);
				_stmt.sqlConnection = conn;
			}

			return _stmt;
		}

		/**
		 * Classe tipada do <code>ObjectVO</code>
		 * @return Classe tipada do <code>ObjectVO</code>
		 *
		 */
		public function getClass():Class
		{
			return Class(getDefinitionByName(getQualifiedClassName(objectVO)));
		}

		/**
		 * Consulta os registros no banco de dados
		 * @param where condições para a consulta
		 * @param order condições para a ordenação
		 * @return Lista com os registros
		 *
		 */
		public function getRows(where:Array = null, order:Array = null):ArrayCollection
		{
			try
			{
				var sql:String = '';
				var arrayFields:Array = [];

				getFields(objectVO, arrayFields);

				sql = 'SELECT ' + arrayFields.join(',') + ' FROM ' + tabela;

				if (!isNullOrEmpty(where))
					sql += ' WHERE ' + where.join(' AND ');

				stmt.text = sql;
				stmt.execute();
				return new ArrayCollection(stmt.getResult().data);
			}
			catch (error:Error)
			{
				mostrarMensagem('Erro ao recuperar os registros\n' + error.message, 'Erro');
			}
			finally
			{
				stmt.clearParameters();
			}

			return new ArrayCollection();
		}

		/**
		 * Consulta um registro no banco de dados
		 * @param classVO Tipo de objeto a ser retornado
		 * @param id Identificador do registro a ser pesquisado
		 * @return Objeto <code>classVO</code>
		 *
		 */
		public function getRow(classVO:Class, id:int):*
		{
			try
			{
				var arrayFields:Array = [];
				getFields(objectVO, arrayFields);

				stmt.text = 'SELECT ' + arrayFields.join(',') + ' FROM ' + tabela + ' WHERE id = ' + charParam + 'id';
				stmt.parameters[charParam + 'id'] = id;
				stmt.execute();

				var list:ArrayCollection = new ArrayCollection(stmt.getResult().data);

				if (list.length == 0)
					return new classVO;

				return ObjectTranslator.objectToInstance(list.getItemAt(0), classVO) as classVO;
			}
			catch (error:Error)
			{
				mostrarMensagem('Erro ao recuperar o registro\n' + error.message, 'Erro');
			}
			finally
			{
				stmt.clearParameters();
			}

			return new classVO();
		}

		/**
		 * Valida se os valores informados são válidos
		 * DEVE SER SOBRESCRITA PELA CLASSE FILHA
		 * @param entity
		 * @return <code>true</code> quando informações de <code>entity</code> estão corretas
		 *
		 */
		public function validateRow(entity:*):Boolean
		{
			//nada aqui - este método deve ser sobrescrito pela classe filha
			return true;
		}

		/**
		 * Persiste um registro no banco de dados
		 * @param entity Objeto a ser persistido
		 * @return ID do registro
		 *
		 */
		public function saveRow(entity:*):int
		{
			if (validateRow(entity))
			{
				var isInsert:Boolean = true;
				var sql:String = '';
				var arrayFields:Array = [];
				var arrayParams:Array = [];
				var arrayPairs:Array = [];

				try
				{
					getFields(entity, arrayFields, arrayParams, arrayPairs, stmt);

					if (entity.id == 0)
						sql = 'INSERT INTO ' + tabela + ' ' + '(' + arrayFields.join(',') + ')' + ' VALUES ' + '(' + arrayParams.join(',') + ')';
					else
					{
						isInsert = false;
						sql = 'UPDATE ' + tabela + ' SET ' + arrayPairs.join(',') + ' WHERE ' + 'id = :id';
						stmt.parameters[charParam + 'id'] = entity.id;
					}

					trace(sql);
					stmt.text = sql;
					stmt.execute();

					if (isInsert)
						return stmt.getResult().lastInsertRowID;
					else
						return entity.id;
				}
				catch (error:Error)
				{
					mostrarMensagem('Erro ao salvar o registro\n' + error.message, 'Erro');
				}
				finally
				{
					stmt.clearParameters();
				}
			}

			return -1;
		}

		/**
		 * Remove um registro na base de dados
		 * @param id Identificador do registro a ser removido
		 *
		 */
		public function deleteRow(id:int):void
		{
			try
			{
				stmt.text = 'DELETE FROM ' + tabela + ' WHERE id=:id';
				stmt.parameters[charParam + 'id'] = id;
				stmt.execute();
			}
			catch (error:Error)
			{
				mostrarMensagem('Erro ao excluir o registro\n' + error.message, 'Erro');
			}
		}

		/**
		 * Executa os scripts de criação das tabelas do sistema
		 * @param sql <code>Array</code> contendo os comandos de criação das tabelas
		 *
		 */
		public function initTables(sql:Array):void
		{
			var myFunction:Function = function(element:*, index:int, arr:Array):void
			{
				try
				{
					stmt.text = element;
					stmt.execute();
				}
				catch (error:Error)
				{
					mostrarMensagem(error.message, 'Erro ao validar tabela');
				}
			};

			sql.forEach(myFunction, sql);
		}

		/**
		 *
		 * @param formato
		 * @return
		 */
		public function getDateTime(formato:String = null):String
		{
			var df:DateFormatter = new DateFormatter;
			var dt:Date = new Date;

			df.formatString = (formato ? formato : 'DD/MM/YYYY HH:NN:SS');

			return df.format(dt);
		}

		/**
		 * Recupera os campos de um objeto, convertendo-os em um <code>Array</code>
		 * @param entity Objeto a ser convertido
		 * @param arrayFields Lista de campos
		 * @param arrayParams Lista de campos (formato parametro)
		 * @param arrayPairs Lista de campos (em formato de pares - campo = parametro)
		 * @param stmt Parametros para o SQLite
		 *
		 */
		public function getFields(entity:Object, arrayFields:Array = null, arrayParams:Array = null, arrayPairs:Array = null, stmt:SQLStatement = null):void
		{
			var myFunction:Function = function(element:*, index:int, arr:Array):void
			{
				var isClass:Boolean = false;

				try
				{
					var className:String = 'valueObjects.' + firstCharToUpper(element) + 'VO';
					var cls:Class = getDefinitionByName(className) as Class;
					isClass = true;
				}
				catch (error:Error)
				{
					isClass = false;
				}
				finally
				{
					if (arrayFields != null)
						arrayFields[index] = (isClass ? 'id' + firstCharToUpper(element) : element);

					if (arrayParams != null)
						arrayParams[index] = charParam + (isClass ? 'id' + firstCharToUpper(element) : element);

					if (arrayPairs != null)
						arrayPairs[index] = element + ' = ' + charParam + element;

					if (stmt != null)
						stmt.parameters[charParam + (isClass ? 'id' + element : element)] = (isClass ? entity[element]['id'] : entity[element]);
				}
			};

			var array:Array = ObjectUtil.getClassInfo(entity).properties;

			removeItem(array, 'id');
			removeItem(array, 'prototype');

			array.forEach(myFunction, this);
		}

		/**
		 *
		 * @param string
		 * @return
		 *
		 */
		public function firstCharToUpper(string:String):String
		{
			var string:String = string.toLowerCase();
			var firstLetter:String = string.charAt(0).toUpperCase();
			var restWord:String = string.substr(1, string.length);

			string = firstLetter + restWord;
			return string;
		}


		/**
		 *
		 * @param array
		 * @param name
		 */
		public function removeItem(array:Array, name:String):void
		{
			var n:int = array.length;

			while (--n > -1)
			{
				if (array[n] is Object)
				{
					if (name === array[n].localName)
					{
						array.splice(n, 1);
						return;
					}
				}
				else
				{
					if (name === array[n])
					{
						array.splice(n, 1);
						return;
					}
				}
			}
		}

		/**
		 * Insere o menu e seus itens na janela nativa do Sistema Operacional.
		 * Para cada menu é necessário invocar este método.
		 * @param labelMenu Título do menu
		 * @param menuItens Lista de itens do menu
		 *
		 */
		public function createMenu(labelMenu:String, menuItens:Array):void
		{
			var stage:Stage = (this.root as DisplayObject).stage;
			var menu:NativeMenuItem = new NativeMenuItem(labelMenu);
			var subMenu:NativeMenu = new NativeMenu;

			if (NativeWindow.supportsMenu)
			{
				stage.nativeWindow.menu = new NativeMenu();
				stage.nativeWindow.menu.addItem(menu);
			}

			if (NativeApplication.supportsMenu)
				NativeApplication.nativeApplication.menu.addItem(menu);

			for each (var menuItem:String in menuItens)
			{
				var item:NativeMenuItem = new NativeMenuItem(menuItem);
				item.addEventListener(Event.SELECT, onMenuSelect);
				subMenu.addItem(item);
			}

			menu.submenu = subMenu;
		}

		/**
		 * Captura o evento <code>Event.SELECT</code> do menu
		 * DEVE SER SOBRESCRITA PELA CLASSE FILHA
		 * @param event Item selecionado
		 *
		 */
		protected function onMenuSelect(event:Event):void
		{
			//nada aqui - este método deve ser sobrescrito pela classe filha
		}

		/**
		 * Abre uma nova janela no sistema.
		 * @param content Conteudo a ser exibido
		 * @param nome Nome para identificar a janela
		 * @param modal <code>true</code> se a janela será sobreposta sobre as demais
		 *
		 */
		public function abrirJanela(content:UIComponent, nome:String = null, modal:Boolean = false):void
		{
			//caso não seja informado o nome da janela
			//é criado um nome randomico
			if (isNullOrEmpty(nome))
			{
				var nRandom:int = parseInt((Math.random() * 101).toString());
				nome = "twJanela" + nRandom.toString();
			}

			if (!windowIsOpen(nome))
			{
				var window:ExtendedNativeWindow = new ExtendedNativeWindow(initOptions);

				window.name = nome;
				window.addChild(content);
				window.width = content.width;
				window.height = content.height;

				window.activate();
			}

		}

		/**
		 * Remove uma janela do sistema
		 * É possível remover a janela através da sua própria instância ou pelo nome
		 * @param janela Janela a ser removida
		 * @param nome Nome da janela a ser removida
		 * @param todas <code>true</code> se todas as janelas do sistema serão removidas
		 */
		public function closeWindow(janela:UIComponent, nome:String = null, todas:Boolean = false):void
		{
			CursorManager.setBusyCursor();

			var searchWindow:Function = function(element:*, index:int, arr:Array):void
			{
				if (todas)
					(myWindows[index] as NativeWindow).close();
				else
				{
					if (isNullOrEmpty(nome))
						(element as NativeWindow).close();
					else
					{
						//only ExtendedNativeWindow has name property
						var window:ExtendedNativeWindow = element as ExtendedNativeWindow;
						if (window.name.toLowerCase() == nome.toLowerCase())
							window.close();
					}
				}
			};

			var myWindows:Array = NativeApplication.nativeApplication.openedWindows;

			myWindows.forEach(searchWindow, this);

			CursorManager.removeAllCursors();
		}

		/**
		 * Procura na lista de janelas ativas se a janela já existe
		 * caso positivo, move o foco para ela
		 * @param nome String Nome da janela a ser pesquisado
		 * @return Boolean <code>true</code> se janela já existe
		 *
		 */
		protected function windowIsOpen(nome:String):Boolean
		{
			var indice:int = -1;
			var searchWindow:Function = function(element:*, index:int, arr:Array):void
			{
				//only ExtendedNativeWindow has name property
				var window:ExtendedNativeWindow = element as ExtendedNativeWindow;
				if (window && window.name.toLowerCase() == nome.toLowerCase())
				{
					window.activate();
					indice = index;
					return;
				}
			};

			var myWindows:Array = NativeApplication.nativeApplication.openedWindows;
			myWindows.forEach(searchWindow, this);

			return (indice > -1);
		}

		/**
		 * Dispara o evento para exibir uma mensagem para o usuario
		 * @param mensagem Mensagem a ser exibida
		 * @param titulo Titulo da mensagem (null = 'Atencao')
		 *
		 */
		public function mostrarMensagem(mensagem:String, titulo:String = null):void
		{
			var stage:Stage = (this.root as DisplayObject).stage;
			NativeAlert.show(mensagem, titulo);
		}

		/**
		 * Valida se um objeto é nulo ou vazio
		 * @param value Objeto a ser verificado
		 * @return Boolean <code>true</code> se objeto for nulo ou vazio
		 *
		 */
		public function isNullOrEmpty(value:*):Boolean
		{
			return value == null || value == '';
		}

		/**
		 * Valida um endereco de email
		 * @param email Texto a ser validado
		 * @return <code>true</code> caso email seja valido
		 *
		 */
		public function isValidEmail(email:String):Boolean
		{
			var emailRgx:RegExp = /^([a-zA-Z0-9_.-])+@(([a-zA-Z0-9-])+.)+([a-zA-Z0-9]{2,4})+$/;
			return emailRgx.test(email);
		}

		/**
		 * Provê uma função label function default
		 * @param item Objeto da célula do grid
		 * @param col coluna referente ao objeto
		 * @return Texto formatado
		 *
		 */
		public function labelFunction(item:Object, col:GridColumn):String
		{
			if (col.dataField.indexOf('valor') == -1)
				return formataValor(item.valor);
			else
				return formataCampo(item, col.dataField, 'N/D');
		}

		public function get initOptions():NativeWindowInitOptions
		{
			var options:NativeWindowInitOptions = new NativeWindowInitOptions;
			options.maximizable = false;
			options.minimizable = false;
			options.resizable = false;
			options.type = NativeWindowType.NORMAL;

			return options;
		}

		/**
		 * Permite formatar um campo monetario
		 * @param value Valor a ser formatado
		 * @return Texto formatado
		 *
		 */
		public function formataValor(value:Object):String
		{
			var cf:CurrencyFormatter = new CurrencyFormatter();
			cf.decimalSeparatorFrom = '.';
			cf.decimalSeparatorTo = ',';
			cf.thousandsSeparatorFrom = '';
			cf.thousandsSeparatorTo = '.';
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
		public function formataCampo(item:Object, campo:String, valorPadrao:String = null):String
		{
			var switcher:SwitchSymbolFormatter = new SwitchSymbolFormatter('#');
			var df:DateFormatter = new DateFormatter;
			var retorno:String = item[campo];

			if (isNullOrEmpty(item[campo]))
			{
				if (!isNullOrEmpty(valorPadrao))
					return valorPadrao;
				return retorno;
			}

			if (item[campo] is Date)
			{
				df.formatString = "DD/MM/YYYY HH:NN:SS";
				retorno = df.format(item[campo]);
				retorno = retorno.replace('00:00:00', '');
				retorno = retorno.replace('24:00:00', '');
			}
			else
			{
				//caso seja outro tipo de campo, aplica conforme o switch
				switch (campo.toLowerCase())
				{
					case 'cnpj':
					{
						retorno = switcher.formatValue("##.###.###/####-##", item[campo]);
						break;
					}
					case 'cpf':
					{
						retorno = switcher.formatValue("###.###.###-##", item[campo]);
						break;
					}
					case 'telefone':
					case 'celular':
					case 'fax':
					{
						retorno = switcher.formatValue("(##) ####-####", item[campo]);
						break;
					}
				}
			}

			return retorno;
		}

		/**
		 * Localiza um item dentro de um dataProvider
		 * @param item Valor(es) a serem comparados
		 * @param field Campo(s) a serem comparados
		 * @param ar dataProvider que contem as informacoes da pesquias
		 * @return posicao do objeto dentro do dataProvider
		 *
		 */
		public function getItemIndexInArray(item:Object, field:Object, ar:Object):int
		{
			var arLength:int = 0;
			var verifica:Boolean = false;
			var i:int = 0;

			if (isNullOrEmpty(ar))
				return -1;
			else
				arLength = ar.length - 1;

			if (item is Array)
			{
				var fieldLength:int = (field as Array).length - 1; //tamanho do array dos nomes dos campos
				var itemLength:int = (item as Array).length - 1; //tamanho do array dos campos
				var ret:int = 0; //variavel de controle para verificar se todos os campos estao OK
				var x:int = 0;

				for (i = 0; i <= arLength; i++)
				{
					ret = 0;
					for (x = 0; x <= fieldLength; x++)
					{
						/*
						se o valor da propriedade em field[x]
						for igual ao valor de item[x]
						incrementa +1 variavel ret
						*/
						var obj:Object = ar.getItemAt(i) as Object;
						if (obj[field[x]] is Date)
						{
							var d1:Date = obj[field[x]] as Date;
							var d2:Date = item[x] as Date;

							if (DateUtil.compareDates(d1, d2) == 0)
								ret += 1;
						}
						else
						{
							if (obj[field[x]] == item[x])
								ret += 1;
						}

					} //end for fieldLength

					/*
					variavel ret deve ter o mesmo
					valor do numero de campos
					*/
					if (ret == (item as Array).length)
						return i;
				} //end for arLength

			}
			else
			{
				for (i = 0; i <= arLength; i++)
				{
					if (!isNullOrEmpty(ar.getItemAt(i)[field]))
					{
						if (StringUtil.stringsAreEqual(ar.getItemAt(i)[field].toString(), item.toString(), false))
							return i;
					}
				}
			}

			return -1;
		}

		/**
		 * Localiza um item dentro de um dataProvider
		 * @param item Valor(es) a serem comparados
		 * @param field Campo(s) a serem comparados
		 * @param ar dataProvider que contem as informacoes da pesquias
		 * @return objeto localizado dentro do dataProvider
		 *
		 */
		public function getItemInArray(item:Object, field:Object, ar:Object):Object
		{
			var arLength:int = 0;
			var i:int = 0;

			if (isNullOrEmpty(ar))
				return null;
			else
				arLength = ar.length - 1;

			if (item is Array)
			{
				var fieldLength:int = (field as Array).length - 1; //tamanho do array dos nomes dos campos
				var itemLength:int = (item as Array).length - 1; //tamanho do array dos campos
				var ret:int = 0; //variavel de controle para verificar se todos os campos estao OK
				var x:int = 0;

				for (i = 0; i <= arLength; i++)
				{
					ret = 0;
					for (x = 0; x <= fieldLength; x++)
					{
						/*
						se o valor da propriedade em field[x]
						for igual ao valor de item[x]
						incrementa +1 variavel ret
						*/
						var obj:Object = ar.getItemAt(i) as Object;
						if (obj[field[x]] is Date)
						{
							var d1:Date = obj[field[x]] as Date;
							var d2:Date = item[x] as Date;

							if (DateUtil.compareDates(d1, d2) == 0)
								ret += 1;
						}
						else
						{
							if (obj[field[x]] == item[x])
								ret += 1;
						}

					} //end for fieldLength

					/*
					variavel ret deve ter o mesmo
					valor do numero de campos
					*/
					if (ret == (itemLength + 1))
						return ar.getItemAt(i);

				} //end for arLength

			}
			else
			{
				for (i = 0; i <= arLength; i++)
				{
					if (!isNullOrEmpty(ar.getItemAt(i)[field]))
					{
						if (StringUtil.stringsAreEqual(ar.getItemAt(i)[field].toString(), item.toString(), false))
							return ar.getItemAt(i);
					}
				}
			} //end if item isArray

			return null;
		}


		private function onResult(e:SQLEvent):void
		{
//			stmt.clearParameters();
			CursorManager.removeAllCursors();
		}

		private function onError(e:SQLErrorEvent):void
		{
			mostrarMensagem(e.error.details, "Erro");
			CursorManager.removeAllCursors();
		}

	} //end Class

} //end Package	

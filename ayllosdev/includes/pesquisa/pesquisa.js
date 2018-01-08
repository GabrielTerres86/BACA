/*!
 * FONTE        : pesquisa.js
 * CRIAÇÃO      : Rodolpho Telmo - DB1 Informatica
 * DATA CRIAÇÃO : Fevereiro/2010 
 * OBJETIVO     : Biblioteca de funcionalidades reponsáveis por controlar as rotinas de pesquisas genéricas que foram desenvolvidas
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 001: [10/03/2010] Gabriel Capoia      (DB1): Criada a função montaSelect
 * 002: [16/03/2010] Rodolpho Telmo      (DB1): Criada funções para Pesquisa de Associado Genérica
 * 003: [17/03/2010] Rodolpho Telmo      (DB1): Criada funções "formataResultado" e "formataRodape"
 * 004: [24/03/2010] Rodolpho Telmo      (DB1): Alterada função "buscaDescricao" acrescentando os parâmetros "campoRetorno" e "filtros"
 * 005: [14/04/2010] Gabriel Capoia      (DB1): Alterada função "buscaDescricao" acrescentando o atributo "campoVisivel" ao atributo "filtros"
 * 006: [19/04/2010] Rodolpho Telmo      (DB1): Alterada função "montaSelect" acrescentando o parâmetro "filtros"
 * 007: [22/04/2010] Rodolpho Telmo      (DB1): Alterada função "montaSelect" acrescentando o parâmetro "retornoAdicional"
 * 008: [12/07/2010] Rodolpho Telmo      (DB1): Retirada a função "formataRodape" e passada para "funcoes.js" como um plugin do jQuery
 * 009: [05/11/2010] Gabriel          (CECRED): Incluir campo tipo de organizacao
 * 012: [15/04/2011] Rodolpho e Rogérius (DB1): Criada funções para Zoom Genérico de Endereço
 * 013: [06/05/2011] Rodolpho Telmo      (DB1): Criada extensão jQuery "buscaCEP"
 * 014: [10/05/2011] Rodolpho Telmo      (DB1): Criada extensão jQuery "buscaConta" 
 * 015: [16/05/2011] Rodolpho Telmo      (DB1): Manutenção algumas funções para quando fechar uma Pesquisa genérica, poder focar no campo correto
 * 016: [27/06/2011] Rogerius Militao	 (DB1): Manutenção das funções "buscaDescricao()" e "selecionaPesquisa()" para o tratamento do evento change (onBlur)
 * 017: [24/10/2011] Rogerius Militão    (DB1): Adicionado a opção de pesquisar o associado pelo CPF/CNPJ
 * 018: [12/12/2011] Jorge Hamaguchi  (CECRED): Adicionado condicao especifica para tela caddne em funcao selecionaPesquisaEndereco()
 * 019: [12/12/2011] David G Kistner  (CECRED): Acionar pesquisa automaticamente quando o zoom for apresentado
 * 020: [12/12/2011] Rogérius Militão 	 (DB1): Adicionado o codigo "$(this).removeClass('campoFocusIn').addClass('campo')" para tratar o novo focu selecionaPesquisa();
 * 031: [06/08/2012] Adriano		  (CECRED): Ajustado as funções mostraPesquisa, selecionaPesquisa, realizaPesquisa para receber o parametro nomeRotina. Ajuste referente ao projeto GP - Sócios Menores;
 * 032: [08/02/2013] David R Kruger   (CECRED): Ajuste na função selecionaPesquisa para receber novo formulário, referente a tela AGENCI.
 * 033: [05/09/2013] Carlos           (CECRED): Alteração da sigla PAC para PA.
 * 034: [27/01/2014] Jorge            (CECRED): Ajuste em funcoes para pesquisar seguradoras, buscaDescricao,  mostraPesquisa, realizaPesquisa e selecionaPesquisa. 
 * 035: [20/06/2014] Jorge			  (CECRED): Ajuste em rotinas de fecharPesquisa, adicionado segundo parametro de div ou form, referente à div que deve ser fechada.
 * 036: [05/08/2014] Jaison			  (CECRED): Ajuste na função selecionaPesquisa, verificando se o campo cdlcremp veio da tela de parametros do credito pre-aprovado.
 * 037: [30/03/2015] Jorge            (CECRED): Ajuste em funcao mostraPesquisa, adicionado quinto parametro da variavel "coluna", campo opcional para coluna visivel ou nao. (SD - 229250)
 * 038: [02/06/2015] Jorge 			  (CECRED): Ajuste de tratamento de parametro em funcao mostraPesquisa.
 * 039: [11/07/2016] Evandro            (RKAM): Adicionado função controlafoco.
 * 040: [06/02/2017] Lucas Ranghetti  (CECRED): Alterado funcao buscaCEP apra keydown e adicionado a funcao do tab.  #562253
 * 041: [06/06/2017] Jonata            (Mouts): Ajuste para inclusão da busca de dominios - P408.
 * 042: [13/08/2017] Jonata            (Mouts): Ajuste para incluir a passagem de novo parâmetro na rotina buscaDescricao - P364.
 * 043: [24/10/2017] Odirlei Busana    (AMcom): Incluido onchage na buscaCPF. PRJ339 - CRM.
 
 */

var vg_formRetorno  = '';
var vg_campoRetorno = new Array();
var contadorSelect  = 0; // contador dos select
var mtSelecaoEndereco;
 
/*!
 * ALTERAÇÃO  : 004
 * OBJETIVO   : Busca descricao genérica de algum campo códgio, retornando o resultado em outro campo de descrição
 * PARÂMETROS : businessObject   -> Business Object que contém a procedure passada no parâmetro "nomeProcedure"
 *              nomeProcedure 	 -> Nome da procedure que efetua a busca da descrição desejada
 *              tituloPesquisa   -> Título que será exibido no topo da janela de pesquisa
 *              campoCodigo   	 -> Nome do campo no formulário ao qual será buscado no xml
 *              campoDescricao	 -> Nome do campo para o qual o resultado da pesquisa irá retornar
 *              codigoAtual      -> Valor atual do campo código
 *              campoRetorno     -> Nome do campo que retorna da pesquisa, onde seu valor será pego e retornado para o campoDescrição
 *              filtros          -> [Opcional] Representa um campo que eu queira inserir junto no xml de pesquisa, para filtrar os resultados
 *              nomeFormulario   -> [Opcional] Nome do formulário ao qual os campos estão inseridos
                executaMetodo    -> [Opcional] Funções a serem executadas após a busca da descrição
 */
function buscaDescricao(businessObject, nomeProcedure, tituloPesquisa, campoCodigo, campoDescricao, codigoAtual, campoRetorno, filtros, nomeFormulario,executaMetodo) {

	// Ação utilizada para arrumar a pesquisa utilizando o evento change
	if ( $('#'+campoCodigo).attr('aux') == $('#'+campoCodigo, '#'+nomeFormulario).val() ) { return false; }
	
	if (nomeProcedure == 'BUSCADESCDOMINIOS') {

	    $('#iddominio_' + campoCodigo).val('');

	}

	showMsgAguardo("Aguarde, pesquisando "+tituloPesquisa+" ...");
	
	// Se o código estiver vazio, então limpa o campo de descrição
	if (codigoAtual == '') {
		$("input[name='"+campoDescricao+"']").val("");

		// controle do evento CHANGE
		$('#'+campoCodigo).attr('aux',codigoAtual);
		
		hideMsgAguardo();
		bloqueiaFundo(divRotina);
		if( $('#divMatric').css('display') == 'block' || $('#divTela').css('display') == 'block' ) { unblockBackground(); };
		return false;
		
	// Se o código for zero, então retorna "Não Informado"
	} else if (codigoAtual == 0) {
		$("input[name='"+campoDescricao+"']").val("NAO INFORMADO");

		// controle do evento CHANGE
		$('#'+campoCodigo).attr('aux',codigoAtual);

		hideMsgAguardo();
		bloqueiaFundo(divRotina);
		if( $('#divMatric').css('display') == 'block' || $('#divTela').css('display') == 'block' ) { unblockBackground(); };
		return false;
		
	} else {
		var filtroParametro = '';
		// Se estou enviando valores em "filtros", então montar uma variável filtroParametro 
		// no seguinte layout: "nomeFiltro;valor|nomeFiltro;valor"		
		if ( (typeof filtros != 'undefined') && (filtros != '') ) {
			// Definicao das variaveis
			var arrayFiltros    = new Array();
			var arrayItens      = new Array();
			var itemFiltro      = '';
			var valorItem		= '';
			// Explodo o parametro filtro pelo (;) para saber quantos filtros teremos que incluir no xml que realiza a consulta
			arrayFiltros = filtros.split(";");		
			for( var i in arrayFiltros ) {		
				arrayItens = arrayFiltros[i].split("|");
				
				itemFiltro = arrayItens[0];
				
				if (arrayItens.length == 1) {					
					// Busco o valor atual para este campo no formulário					
					valorItem = $('#'+itemFiltro).val();
				}else if (arrayItens.length == 2){
					valorItem = arrayItens[1];
				}
				// Adiciono no filtroParametro
				if (filtroParametro.length > 0) filtroParametro += "|";
				filtroParametro += itemFiltro+';'+valorItem;
			}
		}
		
		// controle do evento CHANGE
		$('#'+campoCodigo).attr('aux',codigoAtual);
		
		// Carrega dados através de ajax
		$.ajax({		
			type: "POST",
			url: UrlSite + "includes/pesquisa/busca_descricao.php", 
			data: {
				businessObject : businessObject,
				nomeProcedure  : nomeProcedure,
				tituloPesquisa : tituloPesquisa,
				campoCodigo	   : campoCodigo,
				campoDescricao : campoDescricao,
				codigoAtual    : codigoAtual,
				campoRetorno   : campoRetorno,
				filtros        : filtroParametro,
				nomeFormulario : nomeFormulario,
				executaMetodo  : executaMetodo,
				redirect       : "script_ajax" // Tipo de retorno do ajax
			}, 
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos",'bloqueiaFundo(divRotina);return false;');
			},
			success: function(response) {
				try {
					eval(response);
				} catch(error) {
					hideMsgAguardo();
					showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos",'bloqueiaFundo(divRotina);return false;');
				}
			}	
		});	
	} // fim else
}

/*!
 * ALTERAÇÃO  : 000
 * OBJETIVO   : Função genérica que monta dinâmicamente o formulário de pesquisa "formPesquisa"
 *              Esta função é responsável por inserir neste formulário os filtros de pesquisa e o cabeçalho da tabela que irá exibir o resultado da pesquisa
 * PARÂMETROS : businessObject -> 
 *              nomeProcedure  -> 
 *              quantReg   	   -> 
 *              filtros	       -> 
 *              colunas        -> 
 *              divBloqueia    -> [Opcional]
 *              fncOnClose     -> [Opcional]
 */
function mostraPesquisa(businessObject, nomeProcedure, tituloPesquisa, quantReg, filtros, colunas, divBloqueia, fncOnClose,nomeRotina, cdCooper) {	    

	if (cdCooper == '' || cdCooper == null || cdCooper == "undefined"){
		cdCooper = 0;
	}else if(cdCooper == 0){
		cdCooper = 3;
	}
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando Pesquisa "+tituloPesquisa+"...");
	
	// Muda o t&iacute;tulo da Janela de acordo com o parâmetro tituloPesquisa
	$("span.tituloJanelaPesquisa").html( "pesquisa "+tituloPesquisa );	
	
	// Inserindos os campos ocultos que serão passados via POST ao arquivo "realiza_pesquisa", que
	// é o responsável por montar o XML de pesquisa dinâmicamente
	$("#formPesquisa").html('<input type="hidden" name="nriniseq" id="nriniseq" />');
	$("#formPesquisa").append('<input type="hidden" name="nrregist" id="nrregist" />');
	$("#formPesquisa").append('<input type="hidden" name="businessObject" id="businessObject" />');
	$("#formPesquisa").append('<input type="hidden" name="nomeProcedure" id="nomeProcedure" />');
	$("#formPesquisa").append('<input type="hidden" name="tituloPesquisa" id="tituloPesquisa" />');
	
	// Passando os parâmetros para os INPUT do tipo HIDDEN acima, ou seja, colocando valores nestes INPUTs
	$("input[name='nriniseq'      ]").val( 1 );
	$("input[name='nrregist'      ]").val( quantReg );
	$("input[name='businessObject']").val( businessObject );
	$("input[name='nomeProcedure' ]").val( nomeProcedure  );
	$("input[name='tituloPesquisa']").val( tituloPesquisa );	
	
	//*****************************************// 
	//***       MONTAGEM DOS FILTROS        ***//
	//*****************************************// 	
	// LAYOUT DO PARAMETRO "filtros":
	// Cada filtro que e inserido e separado pelo pipe (|)
	// Suas opcoes de montagem sao separadas por ponto e virgula (;)
	// Abaixo as opcoes disponiveis:
		// O 1º parametro -> Rótulo
		// O 2º parametro -> Nome do campo
		// O 3º parametro -> Largura do campo
		// O 4º parametro -> Valores possíveis: "S" para habilitado OU "N" para desabilitado
		// O 5º parametro -> Valor inicial do filtro
		// O 6º parametro -> Campo Visível: "S" para visível ou "N" para não visível
		// O 7º parametro -> Campo expecifico para type radio 
	// Definicao das variaveis
	var arrayFiltros	= new Array();
	var opcoesFiltro 	= new Array();	
	var filtroParametro = "";
	// Explodo o parametro filtro pelo pipe (|) para saber quantos filtros teremos no formulario
	arrayFiltros = filtros.split("|");		
	for( var i in arrayFiltros ) {
		
		// Explodo cada filtro em suas opções de montagem
		opcoesFiltro = arrayFiltros[i].split(";");		
		
		// Atribuo as opções em variáveis
		var campoRotulo		= opcoesFiltro[0];
		var campoNome		= opcoesFiltro[1];
		var campoLargura	= opcoesFiltro[2];
		var habilitado		= opcoesFiltro[3];
		var valorInicial	= opcoesFiltro[4];		
		var campoVisivel	= opcoesFiltro[5];		
		var campoTipo   	= opcoesFiltro[6];
		var campoType   	= opcoesFiltro[7];		
		
		// Monto uma String de filtros que será passada como parâmetro para a função "realizaPesquisa"
		// LAYOUT filtroParam: "filtroNome;filtroNome;filtroNome"
		if (filtroParametro.length > 0) filtroParametro += ";";
		filtroParametro += campoNome;
		
		// Caso o valor inicial do campo não foi passado, jogo vazio
		valorInicial = (typeof valorInicial == 'undefined' || valorInicial == 'undefined') ? '' : valorInicial;
		
		// Insirindo o label e o input
		// Para que o sistema nao confunda este campo de pesquisa com o do formulario principal,
		// por padrao, o nome do campo no formulario de pesquisa sera o nome do campo original
		// concatenado com a palavra "Pesquisa"
		if ( campoVisivel == 'N' ) {
			$("#formPesquisa").append('<input type="hidden" name="'+campoNome+'Pesquisa" id="'+campoNome+'Pesquisa" value="'+valorInicial+'" />');		
		} else {
		
			if(campoType != "radio"){
				$("#formPesquisa").append('<label for="'+campoNome+'Pesquisa">'+campoRotulo+'</label>');
				$("#formPesquisa").append('<input type="text" name="'+campoNome+'Pesquisa" id="'+campoNome+'Pesquisa" style="width:'+campoLargura+';color:#222;" value="'+valorInicial+'" class="alphanum" />');		
				
				//Alteração: Retira caracteres não permitidos e adiciona atributo maxlength. 
				//Para funcionar passar o setimo paramentro do filtro como "codigo" ou  "descricao"
				if( typeof campoTipo != 'undefined' ){
					
					var caracAcentuacao 	= 'áàäâãÁÀÄÂÃéèëêÉÈËÊíìïîÍÌÏÎóòöôõÓÒÖÔÕúùüûÚÙÜÛçÇ';
					var caracEspeciais  	= '!@#$%&*()-_+=§:<>;/?[]{}°ºª¬¢£³²¹\\|\',.´`¨^~';
					var caracSuperEspeciais	= '¨¹²³£¢¬§ªº°´&\'';
					
					if ( campoTipo == 'codigo' ){
						$('#'+campoNome+'Pesquisa','#formPesquisa').numeric({ichars: caracAcentuacao+caracEspeciais+'.,\"'});
						$('#'+campoNome+'Pesquisa','#formPesquisa').attr('maxlength','4');
					}else if ( campoTipo == 'descricao' ){
						$('#'+campoNome+'Pesquisa','#formPesquisa').alphanumeric({ichars: caracSuperEspeciais+caracAcentuacao+'\"'});
						$('#'+campoNome+'Pesquisa','#formPesquisa').attr('maxlength','40');
						$('#'+campoNome+'Pesquisa','#formPesquisa').css({'text-transform':'uppercase'});
					}
				}
				
				// Desabilitar os devidos campos de acordo com a opcao habilitada e coloca os valores baseados no formulário principal
				// Adicionar a classe "campo" para o habilitado e a classe "campoTelaSemBorda" para o desabilitado
				if ( habilitado == "N" ) {
					$("#"+campoNome+"Pesquisa").prop("disabled",true);
					$("#"+campoNome+"Pesquisa").addClass("campoTelaSemBorda");
					
					// Deixa o label mais fraco quando o campo é desabilitado
					$("label[for='"+campoNome+"Pesquisa']").css("color","#444");
					
					// Caso o campo não for habilitado, buscar seu valor do formulário principal, MAS
					// como pode ser um valor que está em um INPUT, um SELECT ou outro tipo de elemento
					// então temos que tratar a busca para cada tipo. 
					// Atualmente está tratado para INPUT e SELECT			
					if ( $("#"+campoNome).is("input") ) {
						var valorCampo = $("input[name='"+campoNome+"']").val();
						$("#"+campoNome+"Pesquisa").val( valorCampo );
					} else if ( $("#"+campoNome).is("select") ) {
						var valorCampo = $("#"+campoNome+" option:selected").val();				
						$("#"+campoNome+"Pesquisa").val( valorCampo );
					}
				} else {
					$("#"+campoNome+"Pesquisa").addClass("campo");
				}	
				$("#formPesquisa").append('<br />');
			}else{
				// input radio
				$("#formPesquisa").append('<label for="'+campoNome+'Pesquisa">'+campoRotulo+'</label>');
				$("#formPesquisa").append('<div style="width:50px;float:left;margin-left:10px;margin-top:5px"><input type="radio" name="'+campoNome+'Pesquisa" id="'+campoNome+'Pesquisa" style="width:'+campoLargura+';height:10px;color:#222;" value="yes" checked="checked" />Sim</div>');
				$("#formPesquisa").append('<div style="width:50px;float:left;margin-left:10px;margin-top:5px"><input type="radio" name="'+campoNome+'Pesquisa" id="'+campoNome+'PesquisaN" style="width:'+campoLargura+';height:10px;color:#222;" value="no" />N&atilde;o</div>');
				
				// Desabilitar os devidos campos de acordo com a opcao habilitada e coloca os valores baseados no formulário principal
				// Adicionar a classe "campo" para o habilitado e a classe "campoTelaSemBorda" para o desabilitado
				if ( habilitado == "N" ) {
					$("#"+campoNome+"Pesquisa").prop("disabled",true);
					$("#"+campoNome+"Pesquisa").addClass("campoTelaSemBorda");
					
					// Deixa o label mais fraco quando o campo é desabilitado
					$("label[for='"+campoNome+"Pesquisa']").css("color","#444");
					
					// Caso o campo não for habilitado, buscar seu valor do formulário principal, MAS
					// como pode ser um valor que está em um RADIO, um SELECT ou outro tipo de elemento
					// então temos que tratar a busca para cada tipo. 
					// Atualmente está tratado para RADIO e SELECT			
					if ( $("#"+campoNome).is("radio") ) {
						var valorCampo = $("radio[name='"+campoNome+"']").val();
						$("#"+campoNome+"Pesquisa").val( valorCampo );
					} else if ( $("#"+campoNome).is("select") ) {
						var valorCampo = $("#"+campoNome+" option:selected").val();				
						$("#"+campoNome+"Pesquisa").val( valorCampo );
					}
				} else {
					$("#"+campoNome+"Pesquisa").addClass("campo");
				}	
				$("#formPesquisa").append('<br />');
			}
		}		
	}	
	
	//Se digitar F8 limpa o campo
	$('input[type=\'text\']','#formPesquisa').keydown( function(e) {
		if ( e.keyCode == 119 ) {
			$(this).val(''); 
			return false;
		/*
		 *Alteração: Verifica se a tecla pressionada é o enter,
		 *se for esecuto a mesma função que é executada no click do btPesquisa
		 */
		}else if( e.keyCode == 13 ){
			realizaPesquisa( this.form.nriniseq.value, this.form.nrregist.value, this.form.businessObject.value, this.form.nomeProcedure.value, this.form.tituloPesquisa.value,filtroParametro,colunas,nomeRotina,cdCooper);
			return false;
		}
	});
	
	// Agora insiro o botaoo que realiza a chamada da funcao pesquisar
	$("#formPesquisa").append('<label for="botao"></label>');
	$("#formPesquisa").append('<input type="image" id="btPesquisar" src="'+UrlImagens+'botoes/iniciar_pesquisa.gif" onClick="realizaPesquisa( this.form.nriniseq.value, this.form.nrregist.value, this.form.businessObject.value, this.form.nomeProcedure.value, this.form.tituloPesquisa.value,\''+filtroParametro+'\',\''+colunas+'\',\''+nomeRotina+'\',\''+cdCooper+'\'); return false;" />');
	$("#formPesquisa").append('<br clear="both" />');	
	
	//*************************************// 
	//*       MONTAGEM DO CABEÇALHO       *//
	//*************************************// 
	// LAYOUT DO PARAMETRO "colunas":
	// As colunas devem vir separados pelo pipe (|)
	// Suas opcoes estao separadas por ponto e virgula (;)
	// Abaixo as opcoes disponiveis:
		// O 1º parametro -> Rótulo
		// O 2º parametro -> Nome da coluna
		// O 3º parametro -> Largura da coluna
		// O 4º parametro -> Alinhamento horizontal
		// O 5º parametro -> ?????? (utilizado em realiza_pesquisa.pgp)
		// O 6º parametro -> Coluna visivel "S" ou nao "N" - campo opcional, caso nao venha nada, sera visivel "S"
	
	// Remove os elementos anteriores
	$("#divCabecalhoPesquisa").remove();
	$("#divPesquisaItens").remove();
	$("#divPesquisaRodape").remove();	
	
	// Inicia da montagem do cabecalho da tabela dos resultados da pesquisa
	$("#formPesquisa").after('<div id="divCabecalhoPesquisa" class="divCabecalhoPesquisa"></div>');
	$("#divCabecalhoPesquisa").html('<table></table>');
	$("#divCabecalhoPesquisa > table").html('<thead></thead>');
	$("#divCabecalhoPesquisa > table > thead").html('<tr></tr>');
	
	// Definicoes das variaveis
	var arrayColunas 	= new Array();
	var paramColuna 	= new Array();	
	// Explodo o parametro colunas para desenhar a tabela onde serao exibidos os resultados da pesquisa	
	arrayColunas = colunas.split("|");
	for( var i in arrayColunas ) {		    
	
		// Explodo a coluna para obter suas opcoes
		paramColuna = arrayColunas[i].split(";");				
		
		// Atribuo as opcoes em variaveis
		var rotulo		= paramColuna[0];
		var campo		= paramColuna[1];
		var largura		= paramColuna[2];
		var alinhamento	= paramColuna[3];
		/*! alteracao 037 - utilizado o param [5] pois o [4] ja esta sendo usado em realiza_pesquisa.php */
		var colvisivel  = paramColuna[5] == undefined || paramColuna[5] == "S" ? "" : "display:none;";
		
		// Incluo a coluna na linha da tabela
		$("#divCabecalhoPesquisa > table > thead > tr").append('<td style="width:'+largura+';text-align:'+alinhamento+';'+colvisivel+'">'+rotulo+'</td>');		
	}
	
	$('.fecharPesquisa','#divPesquisa').unbind('click').bind('click', function() {		
		// Executa função no momento em que a pesquisa for encerrada. Definida na rotina que executou a função de pesquisa		
		if (typeof fncOnClose != 'undefined' && $.trim(fncOnClose) != "") {			
			eval(fncOnClose);			
		}
		
		if ( typeof divBloqueia == 'object' ) {			
			fechaRotina($('#divPesquisa'),divBloqueia);			
		} else {
			fechaRotina($('#divPesquisa'));			
		}
				
		return false;
	});		
	
	hideMsgAguardo();	
	exibeRotina($('#divPesquisa'));	
    controlaFoco();
	
    $('#btPesquisar', '#formPesquisa').trigger('click');
	
}


/*!
 * ALTERAÇÃO  : 000
 * OBJETIVO   : Função genérica que monta dinâmicamente o formulário de pesquisa "formPesquisa"
 *              Esta função é responsável por inserir neste formulário os filtros de pesquisa e o cabeçalho da tabela que irá exibir o resultado da pesquisa
 * PARÂMETROS : businessObject -> 
 *              nomeProcedure  -> 
 *              quantReg   	   -> 
 *              filtros	       -> 
 *    		    campoRetorno   ->
 *    		    colunas        ->
 *              divBloqueia    -> [Opcional]
 *              fncOnClose     -> [Opcional]
 */
function mostraPesquisaDominios(businessObject, nomeProcedure, tituloPesquisa, quantReg, filtros, camposRetorno, colunas, divBloqueia, fncOnClose,nomeRotina, cdCooper) {	    

	if (cdCooper == '' || cdCooper == null || cdCooper == "undefined"){
		cdCooper = 0;
	}else if(cdCooper == 0){
		cdCooper = 3;
	}
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando Pesquisa "+tituloPesquisa+"...");
	
	// Inserindos os campos ocultos que serão passados via POST ao arquivo "realiza_pesquisa", que
	// é o responsável por montar o XML de pesquisa dinâmicamente
	$("#formPesquisa").html('<input type="hidden" name="nriniseq" id="nriniseq" />');
	$("#formPesquisa").append('<input type="hidden" name="nrregist" id="nrregist" />');
	$("#formPesquisa").append('<input type="hidden" name="businessObject" id="businessObject" />');
	$("#formPesquisa").append('<input type="hidden" name="nomeProcedure" id="nomeProcedure" />');
	$("#formPesquisa").append('<input type="hidden" name="tituloPesquisa" id="tituloPesquisa" />');
	
	// Passando os parâmetros para os INPUT do tipo HIDDEN acima, ou seja, colocando valores nestes INPUTs
	$("input[name='nriniseq'      ]").val( 1 );
	$("input[name='nrregist'      ]").val( quantReg );
	$("input[name='businessObject']").val( businessObject );
	$("input[name='nomeProcedure' ]").val( nomeProcedure  );
	$("input[name='tituloPesquisa']").val( tituloPesquisa );	
	
	//*****************************************// 
	//***       MONTAGEM DOS FILTROS        ***//
	//*****************************************// 	
	// LAYOUT DO PARAMETRO "filtros":
	// Cada filtro que e inserido e separado pelo pipe (|)
	// Suas opcoes de montagem sao separadas por ponto e virgula (;)
	// Abaixo as opcoes disponiveis:
		// O 1º parametro -> Rótulo
		// O 2º parametro -> Nome do campo
		// O 3º parametro -> Largura do campo
		// O 4º parametro -> Valores possíveis: "S" para habilitado OU "N" para desabilitado
		// O 5º parametro -> Valor inicial do filtro
		// O 6º parametro -> Campo Visível: "S" para visível ou "N" para não visível
		// O 7º parametro -> Campo expecifico para type radio 
	// Definicao das variaveis
	var arrayFiltros	= new Array();
	var opcoesFiltro 	= new Array();	
	var filtroParametro = "";
	// Explodo o parametro filtro pelo pipe (|) para saber quantos filtros teremos no formulario
	arrayFiltros = filtros.split("|");		
	for( var i in arrayFiltros ) {
		
		// Explodo cada filtro em suas opções de montagem
		opcoesFiltro = arrayFiltros[i].split(";");		
		
		// Atribuo as opções em variáveis
		var campoRotulo		= opcoesFiltro[0];
		var campoNome		= opcoesFiltro[1];
		var campoLargura	= opcoesFiltro[2];
		var habilitado		= opcoesFiltro[3];
		var valorInicial	= opcoesFiltro[4];		
		var campoVisivel	= opcoesFiltro[5];		
		var campoTipo   	= opcoesFiltro[6];
		var campoType   	= opcoesFiltro[7];		
		
		// Monto uma String de filtros que será passada como parâmetro para a função "realizaPesquisa"
		// LAYOUT filtroParam: "filtroNome;filtroNome;filtroNome"
		if (filtroParametro.length > 0) filtroParametro += ";";
		filtroParametro += campoNome;
		
		// Caso o valor inicial do campo não foi passado, jogo vazio
		valorInicial = (typeof valorInicial == 'undefined' || valorInicial == 'undefined') ? '' : valorInicial;
		
		// Insirindo o label e o input
		// Para que o sistema nao confunda este campo de pesquisa com o do formulario principal,
		// por padrao, o nome do campo no formulario de pesquisa sera o nome do campo original
		// concatenado com a palavra "Pesquisa"
		if ( campoVisivel == 'N' ) {
			$("#formPesquisa").append('<input type="hidden" name="'+campoNome+'Pesquisa" id="'+campoNome+'Pesquisa" value="'+valorInicial+'" />');		
		} else {
		
			if(campoType != "radio"){
				$("#formPesquisa").append('<label for="'+campoNome+'Pesquisa">'+campoRotulo+'</label>');
				$("#formPesquisa").append('<input type="text" name="'+campoNome+'Pesquisa" id="'+campoNome+'Pesquisa" style="width:'+campoLargura+';color:#222;" value="'+valorInicial+'" class="alphanum" />');		
				
				//Alteração: Retira caracteres não permitidos e adiciona atributo maxlength. 
				//Para funcionar passar o setimo paramentro do filtro como "codigo" ou  "descricao"
				if( typeof campoTipo != 'undefined' ){
					
					var caracAcentuacao 	= 'áàäâãÁÀÄÂÃéèëêÉÈËÊíìïîÍÌÏÎóòöôõÓÒÖÔÕúùüûÚÙÜÛçÇ';
					var caracEspeciais  	= '!@#$%&*()-_+=§:<>;/?[]{}°ºª¬¢£³²¹\\|\',.´`¨^~';
					var caracSuperEspeciais	= '¨¹²³£¢¬§ªº°´&\'';
					
					if ( campoTipo == 'codigo' ){
						$('#'+campoNome+'Pesquisa','#formPesquisa').numeric({ichars: caracAcentuacao+caracEspeciais+'.,\"'});
						$('#'+campoNome+'Pesquisa','#formPesquisa').attr('maxlength','4');
					}else if ( campoTipo == 'descricao' ){
						$('#'+campoNome+'Pesquisa','#formPesquisa').alphanumeric({ichars: caracSuperEspeciais+caracAcentuacao+'\"'});
						$('#'+campoNome+'Pesquisa','#formPesquisa').attr('maxlength','40');
						$('#'+campoNome+'Pesquisa','#formPesquisa').css({'text-transform':'uppercase'});
					}
				}
				
				// Desabilitar os devidos campos de acordo com a opcao habilitada e coloca os valores baseados no formulário principal
				// Adicionar a classe "campo" para o habilitado e a classe "campoTelaSemBorda" para o desabilitado
				if ( habilitado == "N" ) {
					$("#"+campoNome+"Pesquisa").prop("disabled",true);
					$("#"+campoNome+"Pesquisa").addClass("campoTelaSemBorda");
					
					// Deixa o label mais fraco quando o campo é desabilitado
					$("label[for='"+campoNome+"Pesquisa']").css("color","#444");
					
					// Caso o campo não for habilitado, buscar seu valor do formulário principal, MAS
					// como pode ser um valor que está em um INPUT, um SELECT ou outro tipo de elemento
					// então temos que tratar a busca para cada tipo. 
					// Atualmente está tratado para INPUT e SELECT			
					if ( $("#"+campoNome).is("input") ) {
						var valorCampo = $("input[name='"+campoNome+"']").val();
						$("#"+campoNome+"Pesquisa").val( valorCampo );
					} else if ( $("#"+campoNome).is("select") ) {
						var valorCampo = $("#"+campoNome+" option:selected").val();				
						$("#"+campoNome+"Pesquisa").val( valorCampo );
					}
				} else {
					$("#"+campoNome+"Pesquisa").addClass("campo");
				}	
				$("#formPesquisa").append('<br />');
			}else{
				// input radio
				$("#formPesquisa").append('<label for="'+campoNome+'Pesquisa">'+campoRotulo+'</label>');
				$("#formPesquisa").append('<div style="width:50px;float:left;margin-left:10px;margin-top:5px"><input type="radio" name="'+campoNome+'Pesquisa" id="'+campoNome+'Pesquisa" style="width:'+campoLargura+';height:10px;color:#222;" value="yes" checked="checked" />Sim</div>');
				$("#formPesquisa").append('<div style="width:50px;float:left;margin-left:10px;margin-top:5px"><input type="radio" name="'+campoNome+'Pesquisa" id="'+campoNome+'PesquisaN" style="width:'+campoLargura+';height:10px;color:#222;" value="no" />N&atilde;o</div>');
				
				// Desabilitar os devidos campos de acordo com a opcao habilitada e coloca os valores baseados no formulário principal
				// Adicionar a classe "campo" para o habilitado e a classe "campoTelaSemBorda" para o desabilitado
				if ( habilitado == "N" ) {
					$("#"+campoNome+"Pesquisa").prop("disabled",true);
					$("#"+campoNome+"Pesquisa").addClass("campoTelaSemBorda");
					
					// Deixa o label mais fraco quando o campo é desabilitado
					$("label[for='"+campoNome+"Pesquisa']").css("color","#444");
					
					// Caso o campo não for habilitado, buscar seu valor do formulário principal, MAS
					// como pode ser um valor que está em um RADIO, um SELECT ou outro tipo de elemento
					// então temos que tratar a busca para cada tipo. 
					// Atualmente está tratado para RADIO e SELECT			
					if ( $("#"+campoNome).is("radio") ) {
						var valorCampo = $("radio[name='"+campoNome+"']").val();
						$("#"+campoNome+"Pesquisa").val( valorCampo );
					} else if ( $("#"+campoNome).is("select") ) {
						var valorCampo = $("#"+campoNome+" option:selected").val();				
						$("#"+campoNome+"Pesquisa").val( valorCampo );
					}
				} else {
					$("#"+campoNome+"Pesquisa").addClass("campo");
				}	
				$("#formPesquisa").append('<br />');
			}
		}		
	}	
	
	//Se digitar F8 limpa o campo
	$('input[type=\'text\']','#formPesquisa').keydown( function(e) {
		if ( e.keyCode == 119 ) {
			$(this).val(''); 
			return false;
		/*
		 *Alteração: Verifica se a tecla pressionada é o enter,
		 *se for esecuto a mesma função que é executada no click do btPesquisa
		 */
		}else if( e.keyCode == 13 ){
			realizaPesquisaDominios( this.form.nriniseq.value, this.form.nrregist.value, this.form.businessObject.value, this.form.nomeProcedure.value, this.form.tituloPesquisa.value,filtroParametro,camposRetorno,colunas,nomeRotina,cdCooper);
			return false;
		}
	});
	
	// Agora insiro o botaoo que realiza a chamada da funcao pesquisar
	$("#formPesquisa").append('<label for="botao"></label>');
	$("#formPesquisa").append('<input type="image" id="btPesquisar" src="'+UrlImagens+'botoes/iniciar_pesquisa.gif" onClick="realizaPesquisaDominios( this.form.nriniseq.value, this.form.nrregist.value, this.form.businessObject.value, this.form.nomeProcedure.value, this.form.tituloPesquisa.value,\''+filtroParametro+'\',\''+camposRetorno+'\',\''+colunas+'\',\''+nomeRotina+'\',\''+cdCooper+'\'); return false;" />');
	$("#formPesquisa").append('<br clear="both" />');	
	
    // Remove os elementos anteriores
	$("#divCabecalhoPesquisa").remove();
	$("#divPesquisaItens").remove();
	$("#divPesquisaRodape").remove();		
	
	$('.fecharPesquisa','#divPesquisa').unbind('click').bind('click', function() {		
		// Executa função no momento em que a pesquisa for encerrada. Definida na rotina que executou a função de pesquisa		
		if (typeof fncOnClose != 'undefined' && $.trim(fncOnClose) != "") {			
			eval(fncOnClose);			
		}
		
		if ( typeof divBloqueia == 'object' ) {			
			fechaRotina($('#divPesquisa'),divBloqueia);			
		} else {
			fechaRotina($('#divPesquisa'));			
		}
				
		return false;
	});		
	
	hideMsgAguardo();	
	exibeRotina($('#divPesquisa'));	
    controlaFoco();
	
    $('#btPesquisar', '#formPesquisa').trigger('click');
	
}

/*!
  ALTERAÇÃO  : 000
  OBJETIVO   : Função chamada a partir do botão "Iniciar Pesquisa" da tela "pesquisa.php"
               Esta função passa a requisição via POST da pesquisa para o arquivo "realiza_pesquisa_dominios.php"
  PARÂMETROS : nriniseq       -> Nr. inicial da paginação
               quantReg       -> Quantidade de registros que serão exibidos a cada paginação
               businessObject -> Nome da B.0. para ser montado o XML de pesquisa
               nomeProcedure  -> Nome da Procedure para ser montado o XML de pesquisa
               tituloPesquisa -> Título que irá aparecer no topo da janela de pesquisa
               filtros	      -> String para montar os campos do formulário de pesquisa
               colunas        -> String com os campos que deverão ser buscados no xml de retorno da pesquisa e para qual campo essas inforamações serão enviadas na tabela
               camposRetorno  -> String com os campos que deverão ser buscados no xml de retorno da pesquisa e para qual campo essas inforamações serão enviadas
 								// LAYOUT DO PARAMETRO "camposRetorno":
								// Separando a informaão contida em campoRetorno por pipe (|), serão os campos a serem tratados
								// Separando por (;) teremos o nome da tag a ser buscado no xml de retorno da pesquisa e qual será o campo da tela que deverá
								// receber o valor
								// Abaixo as opcoes disponiveis:
								   Exemplo: Neste exemplo temos o controle de 3 campos, separados por pipe (|)
									iddominio|iddominio_idgarantia;dsdvalor|idgarantia;dstipo_dominio|dsgarantia';
									// O 1º parametro (iddomino)             -> Nome da tag a ser buscada no xml de retorno da pesquisa
									// O 2º parametro (iddominio_idgarantia) -> Nome do campo que receberá o valor encontrado no parâmetro anterior
									
 */
function realizaPesquisaDominios(nriniseq, quantReg, businessObject, nomeProcedure, tituloPesquisa, filtros, camposRetorno, colunas, nomeRotina, cdCooper) {
	
	// Mostra mensagem de aguardo	
	showMsgAguardo(" Aguarde, pesquisando "+tituloPesquisa+"...");
	
	// Agora monto uma variável, que será passada como parâmetro para o arquivo "realiza_pesquisa.php"
	// contendo o nome e valor de todos os filtros passado pelo parâmetro "filtros".	
	// Esta variável, denominada "filtrosPesquisa" terá o seguinte layout:	
	// LAYOUT: "filtroNome;filtroValor|filtroNome;filtroValor"
	var filtrosPesquisa	= "";
	var arrayFiltros	= new Array();
	var opcoesFiltro 	= new Array();
	
	// Explodo as filtros que é no mesmo parametro filtros da função mostraPesquisa
	arrayFiltros = filtros.split(";");
	
	for( var i in arrayFiltros ) {	
	
		// Caso já inseriu um um filtro na variável, então separa os dados por pipe(|)
		if (filtrosPesquisa.length > 0) filtrosPesquisa += "|";		
		
		// Atribuo a opção "campo" do filtro na variável abaixo
		var filtroNome = arrayFiltros[i];		
		
		// Agora busco o valor nos campos do formulário de pesquisa
		if ($("#"+filtroNome+"Pesquisa").attr("type") == "radio"){
			if ($("#"+filtroNome+"Pesquisa").prop("checked") == true){
				var filtroValor = "yes";
			}else if ($("#"+filtroNome+"PesquisaN").prop("checked") == true){
				var filtroValor = "no";
			}else{
				var filtroValor = "yes";
			}
		}else{
			var filtroValor = $("#"+filtroNome+"Pesquisa").val();
		}
		
		// Agora concateno este valor no final da variável "filtrosPesquisa", que será passada 
		// como parâmetro para o arquivo "realiza_pesquisa.php" que monta o XML dinâmico e realiza a pesquisa
		filtrosPesquisa += filtroNome+";"+filtroValor;
	}	
	
	// Remove os elementos anteriores
	$("#divCabecalhoPesquisa").remove();
	
	// Carrega dados da conta através de ajax
	$.ajax({		
		type: "POST",  
		url: UrlSite + "includes/pesquisa/realiza_pesquisa_dominios.php", 
		data: {
			businessObject 	: businessObject,
			nomeProcedure  	: nomeProcedure,
			tituloPesquisa 	: tituloPesquisa,
			filtros			: filtrosPesquisa,
			camposRetorno   : camposRetorno,
			colunas         : colunas,
			nriniseq       	: nriniseq,
			quantReg		: quantReg,
			cdcooper		: cdCooper,
			rotina			: nomeRotina,
			redirect       	: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#frmConsulta').css('z-index')))");
		},
		success: function(response) {
		    $("#divResultadoPesquisa").html(response);
			zebradoLinhaTabela($('#divPesquisaItens > table > tbody > tr'));
			$('#divPesquisaRodape').formataRodapePesquisa();
		}			
	});	
}


/*!
 * ALTERAÇÃO  : 000
 * OBJETIVO   : Função chamada a partir do botão "Iniciar Pesquisa" da tela "pesquisa.php"
 *              Esta função passa a requisição via POST da pesquisa para o arquivo "realiza_pesquisa.php"
 * PARÂMETROS : nriniseq       -> Nr. inicial da paginação
 *              quantReg       -> Quantidade de registros que serão exibidos a cada paginação
 *              businessObject -> Nome da B.0. para ser montado o XML de pesquisa
 *              nomeProcedure  -> Nome da Procedure para ser montado o XML de pesquisa
 *              tituloPesquisa -> Título que irá aparecer no topo da janela de pesquisa
 *              filtros	       -> String para montar os campos do formulário de pesquisa
 *              colunas        -> String com as colunas que serão retornadas da pesquisa
 */
function realizaPesquisa(nriniseq, quantReg, businessObject, nomeProcedure, tituloPesquisa, filtros, colunas, nomeRotina, cdCooper) {
	
	// Mostra mensagem de aguardo	
	showMsgAguardo(" Aguarde, pesquisando "+tituloPesquisa+"...");
	
	// Agora monto uma variável, que será passada como parâmetro para o arquivo "realiza_pesquisa.php"
	// contendo o nome e valor de todos os filtros passado pelo parâmetro "filtros".	
	// Esta variável, denominada "filtrosPesquisa" terá o seguinte layout:	
	// LAYOUT: "filtroNome;filtroValor|filtroNome;filtroValor"
	var filtrosPesquisa	= "";
	var arrayFiltros	= new Array();
	var opcoesFiltro 	= new Array();
	
	// Explodo as filtros que é no mesmo parametro filtros da função mostraPesquisa
	arrayFiltros = filtros.split(";");
	
	for( var i in arrayFiltros ) {	
	
		// Caso já inseriu um um filtro na variável, então separa os dados por pipe(|)
		if (filtrosPesquisa.length > 0) filtrosPesquisa += "|";		
		
		// Atribuo a opção "campo" do filtro na variável abaixo
		var filtroNome = arrayFiltros[i];		
		
		// Agora busco o valor nos campos do formulário de pesquisa
		if ($("#"+filtroNome+"Pesquisa").attr("type") == "radio"){
			if ($("#"+filtroNome+"Pesquisa").prop("checked") == true){
				var filtroValor = "yes";
			}else if ($("#"+filtroNome+"PesquisaN").prop("checked") == true){
				var filtroValor = "no";
			}else{
				var filtroValor = "yes";
			}
		}else{
			var filtroValor = $("#"+filtroNome+"Pesquisa").val();
		}
		
		// Agora concateno este valor no final da variável "filtrosPesquisa", que será passada 
		// como parâmetro para o arquivo "realiza_pesquisa.php" que monta o XML dinâmico e realiza a pesquisa
		filtrosPesquisa += filtroNome+";"+filtroValor;
	}	

	// Carrega dados da conta através de ajax
	$.ajax({		
		type: "POST",  
		url: UrlSite + "includes/pesquisa/realiza_pesquisa.php", 
		data: {
			businessObject 	: businessObject,
			nomeProcedure  	: nomeProcedure,
			tituloPesquisa 	: tituloPesquisa,
			filtros			: filtrosPesquisa,
			colunas		    : colunas,
			nriniseq       	: nriniseq,
			quantReg		: quantReg,
			cdcooper		: cdCooper,
			rotina			: nomeRotina,
			redirect       	: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#frmConsulta').css('z-index')))");
		},
		success: function(response) {
		    $("#divResultadoPesquisa").html(response);
			zebradoLinhaTabela($('#divPesquisaItens > table > tbody > tr'));
			$('#divPesquisaRodape').formataRodapePesquisa();
		}			
	});	
}

/*!
 * ALTERAÇÃO  : 011
 * OBJETIVO   : Esta função é chamada no click do mouse em cima de algum resultado da pesquisa, 
 *              onde irá retornar os dados para o campo contido no parâmetro "resultado"
 * PARÂMETROS : resultado -> Uma string no formado "campoNome|campoValor", onde o campoNome é o nome do campo ao qual
 *                           receberá o valor contido no campoValor
 * ALTERAÇÃO  : foi alterado para que a função também retorne o resultado para campos SELECT
 */
function selecionaPesquisa(resultado, idForm) {

	// O layout do parâmetro resultado é:
	// "nomeCampo;resultado|nomeCampo;resultado"
	var arrayCampos	   = new Array();	
	var arrayResultado = new Array();
	
	arrayCampos = resultado.split("|");
	
	for( var i in arrayCampos ) {		
		arrayResultado 	= arrayCampos[i].split(";");
		var campoNome 	= arrayResultado[0];
		var campoValor 	= arrayResultado[1];		
		
		// Retornando resultado do item selecionado aos devidos campos
		if ( typeof idForm == 'undefined' || 
			 idForm == 'undefined') {
			$("input[name='"+campoNome+"'],select[name='"+campoNome+"']").val(campoValor);
			if (campoValor == "yes") { $("input[name='"+campoNome+"'],select[name='"+campoNome+"']").prop("checked",true); }
			else { $("input[name='"+campoNome+"'],select[name='"+campoNome+"']").prop("checked",false); }
		} else {
			
			$("input[name='"+campoNome+"'],select[name='"+campoNome+"']",'#'+idForm).val(campoValor);
			if (campoValor == "yes") { $("input[name='"+campoNome+"'],select[name='"+campoNome+"']",'#'+idForm).prop("checked",true); }
			else { $("input[name='"+campoNome+"'],select[name='"+campoNome+"']",'#'+idForm).prop("checked",true); }
		}
	}	
	
	arrayResultado 	= arrayCampos[0].split(";");
	campoNome      	= arrayResultado[0];
	campoValor		= arrayResultado[1];
    tipoPessoaRegra = $('#tppessoa','#frmInfRegra').val();
	
	// Utiliza um atributo aux para controlar a pesquisa no evento change
	$("input[name='"+campoNome+"'],select[name='"+campoNome+"']").attr('aux',campoValor);
	
	if(idForm == "frmRespLegal") {
		$('input[name="'+campoNome+'"]','#'+idForm).focus();
	}else if(idForm == "frmAgenci"){
		$('input[name="cdageban"]','#'+idForm).focus();
	}else if(campoNome == "cdlcremp" && typeof tipoPessoaRegra != 'undefined'){
		var arrayResultado2 = arrayCampos[1].split(";");
        var campoValor2     = arrayResultado2[1];
        if (tipoPessoaRegra == 'PF') {
            $('#cdlcrepf','#frmInfRegra').val(campoValor).focus();
            $('#dslcrepf','#frmInfRegra').val(campoValor2);
        } else {
            $('#cdlcrepj','#frmInfRegra').val(campoValor).focus();
            $('#dslcrepj','#frmInfRegra').val(campoValor2);
        }
	}else{
		$('input[name="'+campoNome+'"]','.formulario').focus();
	}

	
	// Caso foi feito uma pesquisa, o campo perde o change, e é utilizado esse evento para chamar o change
	$('#'+campoNome,'.formulario').unbind('focusout').bind('focusout', function() {
		$(this).removeClass('campoFocusIn').addClass('campo'); /*020*/
		$(this).trigger('change');
		return false;
	});

	if( $('#divMatric').css('display') == 'block' ) { unblockBackground(); }
	
	$('.fecharPesquisa','#divPesquisa').click();
	
	if(idForm == "frmInfSeguradora") {
		$('#btSalvar', '#divBotoes').trigger('click');
	}
	
	return false;
	
}

/*!
 * ALTERAÇÃO  : 001 - Criação da Função
 *              006 - Alteração da Função, onde posso passar filtros para o XML que será montado no layout "nomeFiltro;valorFiltro|nomeFiltro;valorFiltro"
 *              007 - Acrescentado parâmetro "retornoAdicional", que retornará em cada option valores retornados pelo XML que serão inseridos na propriedade "alt" do option
 * OBJETIVO   : Criar um <select> dinâmico
 * PARÂMETROS : businessObject   -> Business Object que contem a procedure passada no parametro $nomeProcedure .
 *              nomeProcedure 	 -> Nome da procedure que efetua a busca para o campo desejado .
 *              campoTela   	 -> Codigo do campo da tela. O select sera montado com as tags name e id recebendo esse codigo. 
 *              valorRetorno     -> Cod. do campo cujo o valor será usado para montar cada option do select.
 *              descricaoRetorno -> String com o cod. dos campo que seraum inseridos no select. Os codigos devem ser separados por ";" .
 *              valorAtual	     -> Valor que deve estar selecionado no select
 *              filtros          -> [Opcional] Representa um campo que eu queira inserir junto no xml de pesquisa, para filtrar os resultados 
 *              retornoAdicional -> [Opcional] Valores que serão retornados na propriedade "alt" do option
 */	
function montaSelect(businessObject, nomeProcedure, campoTela, valorRetorno, descricaoRetorno, valorAtual, filtros, retornoAdicional) {
	
	contadorSelect++; 
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, montando formul&aacute;rio ...");
	
	// Desabilito o select
	var disStatus = $("select[name='"+campoTela+"']").prop('disabled');
	disStatus = ( typeof disStatus == 'undefined' ) ? false : disStatus;	
	$("select[name='"+campoTela+"']").prop('disabled',true);	
	
	// Trabalhando com os parâmetros opcionais
	filtros = ( typeof filtros != 'undefined' ) ? filtros : '';
	retornoAdicional = ( typeof retornoAdicional != 'undefined' ) ? retornoAdicional : '';	
	
	$.ajax({		
		type: "POST",
		url: UrlSite + "includes/pesquisa/monta_select.php", 
		data: {
			businessObject   : businessObject,
			nomeProcedure    : nomeProcedure,
			campoTela 		 : campoTela,
			valorRetorno	 : valorRetorno,
			descricaoRetorno : descricaoRetorno,
			filtros	         : filtros,
			retornoAdicional : retornoAdicional,
			redirect         : "script_ajax" // Tipo de retorno do ajax
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel montar o select.","Alerta - Ayllos",'');
		},
		success: function(response) {			
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$("select[name='"+campoTela+"']").html(response);						
					// Retiro a seleção de todos options
					$("select[name='"+campoTela+"']").removeProp('selected');
					// Seleciono o que deveria estar selecionado
					$("select[name='"+campoTela+"'] > option[value='"+valorAtual+"']").prop('selected',true);
					// Habilito o select
					$("select[name='"+campoTela+"']").prop('disabled',disStatus);
					contadorSelect--;
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
				}
			} else {
				try {
					eval( response );
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
				}
			}
		
		}	
	});
}

/*!
 * ALTERAÇÃO  : 002 - Criação da função "mostraPesquisaAssociado"
 *              015 - Acrescentado parâmetro opcional "fncFechar", descrito mais abaixo
 * OBJETIVO   : Função para mostrar a rotina de Pesquisa de Associados Genérica. 
 * PARÂMETROS : campoRetorno -> (String) O campo retorno é o nome do campo que representa o Nr. Conta do associado, para que na seleção
 *                              do associado, o sistema saiba para onde deve enviar o valor da conta escolhida (associado escolhido)
 *              formRetorno  -> (String) Nome do formulário que irá receber as informações do associado selecionado
 *              divBloqueia  -> (Opcional) Seletor jQuery da div que será ao qual queremos bloquear o fundo, logo em seguida de fecharmos a janela de pesquisa
 *              fncFechar    -> (Opcional) String que será executada como script ao fechar o formulário de Pesquisa Associado. Na maioria 
 *                               das vezes será uma instrução de foco para algum campo.
 */	 
function mostraPesquisaAssociado(campoRetorno, formRetorno, divBloqueia, fncFechar,cdCooper) {

	if (cdCooper == '' || cdCooper == null || cdCooper == "undefined"){
		cdCooper = 0;
	}else if(cdCooper == 0){
		cdCooper = 3;
	}

	// Mostra mensagem de aguardo	
	showMsgAguardo('Aguarde, carregando Pesquisa de Associados ...');	
	
	// Guardo o campoRetorno e o formRetorno em variáveis globais para serem utilizados na seleção do associado
	vg_campoRetorno = campoRetorno.split("|");
	vg_formRetorno  = formRetorno;	
	
	$('#tpdapesq','#frmPesquisaAssociado').empty();	
	
	$('#frmPesquisaAssociado').append('<input type="hidden" name="cdcooper" id="cdcooper" value="'+cdCooper+'"/>');	
	$('#tpdapesq','#frmPesquisaAssociado').append('<option value="0">Titulares');	
	$('#tpdapesq','#frmPesquisaAssociado').append('<option value="1">C&ocirc;njuge');	
	$('#tpdapesq','#frmPesquisaAssociado').append('<option value="2">Pai');	
	$('#tpdapesq','#frmPesquisaAssociado').append('<option value="3">M&atilde;e');	
	$('#tpdapesq','#frmPesquisaAssociado').append('<option value="4">Pessoa Jur&iacute;dica');
	
	// Limpar campos de pesquisa
	$('#titular','#frmPesquisaAssociado').prop('checked',true);
	$('#nmdbusca','#frmPesquisaAssociado').val('');
	$('#tpdapesq','#frmPesquisaAssociado').val('0');
	$('#tpdorgan','#frmPesquisaAssociado').val('1');
	$('#cdagpesq','#frmPesquisaAssociado').val('0');
	$('#nrdctitg','#frmPesquisaAssociado').val('0.000.000-0');	
	$('#nrcpfcgc','#frmPesquisaAssociado').val('');			
	
	// Formatação Inicial
	$('#nmdbusca, #tpdapesq, #cdagpesq','#frmPesquisaAssociado').removeClass('campoTelaSemBorda').addClass('campo').removeProp('disabled');	
	$('#tpdapesq','#frmPesquisaAssociado').removeProp('disabled');			
	$('#nrcpfcgc, #nrdctitg','#frmPesquisaAssociado').removeClass('campo').addClass('campoTelaSemBorda').prop('disabled',true);	
	
	// Alterando-se o tipo de pesquisa, habilita/desabilita os devidos campos
	$('input[type="radio"]','#frmPesquisaAssociado').change( function() {
	
		$('#tpdapesq','#frmPesquisaAssociado').find('option').remove();
	
		if ( $(this).val() == '1' ) {
			// Habilita
			$('#nmdbusca, #tpdapesq, #cdagpesq','#frmPesquisaAssociado').removeClass('campoTelaSemBorda').addClass('campo').removeProp('disabled');	
			$('#tpdapesq','#frmPesquisaAssociado').removeProp('disabled');			
			// Desabilita
			$('#nrdctitg','#frmPesquisaAssociado').removeClass('campo').addClass('campoTelaSemBorda').prop('disabled',true);
			// Foca
			$('#nmdbusca','#frmPesquisaAssociado').focus();	
			// Option
			$('#tpdapesq','#frmPesquisaAssociado').append('<option value="0">Titulares');	
			$('#tpdapesq','#frmPesquisaAssociado').append('<option value="1">C&ocirc;njuge');	
			$('#tpdapesq','#frmPesquisaAssociado').append('<option value="2">Pai');	
			$('#tpdapesq','#frmPesquisaAssociado').append('<option value="3">M&atilde;e');	
			$('#tpdapesq','#frmPesquisaAssociado').append('<option value="4">Pessoa Jur&iacute;dica');	
	
		} else if ( $(this).val() == '2' ) {
			// Desabilita
			$('#nmdbusca, #tpdapesq, #cdagpesq','#frmPesquisaAssociado').removeClass('campo').addClass('campoTelaSemBorda').prop('disabled',true);
			$('#tpdapesq','#frmPesquisaAssociado').prop('disabled',true);
			// Habilita
			$('#nrdctitg','#frmPesquisaAssociado').removeClass('campoTelaSemBorda').addClass('campo').removeProp('disabled');
			// Foca
			$('#nrdctitg','#frmPesquisaAssociado').val('').focus();
		} else if ( $(this).val() == '3' ) {
			// Habilita
			$('#nrcpfcgc, #tpdapesq, #cdagpesq','#frmPesquisaAssociado').removeClass('campoTelaSemBorda').addClass('campo').removeProp('disabled');	
			$('#tpdapesq','#frmPesquisaAssociado').removeProp('disabled');			
			// Desabilita
			$('#nmdbusca, #nrdctitg','#frmPesquisaAssociado').removeClass('campo').addClass('campoTelaSemBorda').prop('disabled',true);
			// Foca
			$('#tpdapesq','#frmPesquisaAssociado').focus();	
			// Option
			$('#tpdapesq','#frmPesquisaAssociado').append('<option value="1">Pessoa Fisica');	
			$('#tpdapesq','#frmPesquisaAssociado').append('<option value="2">Pessoa Juridica');	
		
		}
	});
	
	$('.fecharPesquisa','#divPesquisaAssociado').click( function() {
		// 015 - Retirado tratamento do tipo do divBloqueia e acrescentado a fncFechar
		fechaRotina($('#divPesquisaAssociado'),divBloqueia,fncFechar);
	});	
	
	// Limpa Tabela de pesquisa
	$('#divResultadoPesquisaAssociado').empty();
	
	hideMsgAguardo();	
	exibeRotina($('#divPesquisaAssociado'));
    controlaFoco();
}

/*!
 * ALTERAÇÃO  : 002
 * OBJETIVO   : Função para efetuar pesquisa de associados
 * PARÂMETROS : nriniseq -> Nr inicial da paginação
 */	
function pesquisaAssociado(nriniseq) {
	
	showMsgAguardo('Aguarde, pesquisando associados ...');
	
    var cdpesqui = $('input[type="radio"]:checked', '#frmPesquisaAssociado').val();
    var nmdbusca = $('#nmdbusca', '#frmPesquisaAssociado').val();
    var tpdapesq = $('#tpdapesq', '#frmPesquisaAssociado').val();
    var cdagpesq = $('#cdagpesq', '#frmPesquisaAssociado').val();
    var tpdorgan = $('#tpdorgan', '#frmPesquisaAssociado').val();
    var nrcpfcgc = $('#nrcpfcgc', '#frmPesquisaAssociado').val();
    var nrdctitg = retiraCaracteres($('#nrdctitg', '#frmPesquisaAssociado').val(), '0123456789X', true);
    var cdcooper = $('#cdcooper', '#frmPesquisaAssociado').val();


    // Verifica código do PAC
    if ((cdpesqui == '1') && (cdagpesq == '' || !validaNumero(cdagpesq, true, 0, 999))) {
        hideMsgAguardo();
        showError('error', 'Informe o PA a ser pesquisado ou 0 para TODOS.', 'Alerta - Ayllos', "$('#cdagpesq','#frmPesquisaAssociado').focus();bloqueiaFundo($('#divPesquisaAssociado'));");
        return false;
    }

    // Verifica código do PAC
    if (cdpesqui == '2' && nrdctitg == '') {
        hideMsgAguardo();
        showError('error', 'Informe o n&uacute;mero da Conta/ITG.', 'Alerta - Ayllos', "$('#nrdctitg','#frmPesquisaAssociado').focus();bloqueiaFundo($('#divPesquisaAssociado'));");
        return false;
    }

    // Verifica código do PAC
    if (cdpesqui == '3' && nrcpfcgc == '') {
        hideMsgAguardo();
        showError('error', 'Informe o CPF/CNPJ a ser pesquisado.', 'Alerta - Ayllos', "$('#nrcpfcgc','#frmPesquisaAssociado').focus();bloqueiaFundo($('#divPesquisaAssociado'));");
        return false;
    }

    // Carrega dados da conta através de ajax
    $.ajax({
        type: 'POST',
        url: UrlSite + 'includes/pesquisa/realiza_pesquisa_associados.php',
        data: {
            cdpesqui: cdpesqui,
            nmdbusca: nmdbusca,
            tpdapesq: tpdapesq,
            cdagpesq: cdagpesq,
            nrdctitg: nrdctitg,
            nriniseq: nriniseq,
            tpdorgan: tpdorgan,
            nrcpfcgc: nrcpfcgc,
            cdcooper: cdcooper,
            redirect: 'html_ajax' // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', "bloqueiaFundo($('#divPesquisaAssociado'));");
        },
        success: function (response) {
            $('#divResultadoPesquisaAssociado').html(response);
            zebradoLinhaTabela($('#divPesquisaAssociadoItens > table > tbody > tr'));
            $('#divPesquisaAssociadoRodape').formataRodapePesquisa();
            controlaFoco();
        }
    });
}

//Função para controle de navegação
function controlaFoco() {
    $('#divPesquisaAssociado').each(function () {
        $(this).find("#frmPesquisaAssociado > :input[type=radio]").addClass("FluxoNavega");
        $(this).find("#frmPesquisaAssociado > :input[type=radio]").first().addClass("FirstInputModal").focus();
        $(this).find("#frmPesquisaAssociado > :input[type=image]").last().addClass("LastInputModal");

        //Se estiver com foco na classe FluxoNavega
        $(".FluxoNavega").focus(function () {
            $(this).bind('keydown', function (e) {
                if (e.keyCode == 13) {
                    $(this).click();
                }
            });
        });
    });
    $(".FirstInputModal").focus();
}


function pesquisaAssociado_2_OnKeyDown(nriniseq) {

    $('#integra').bind('keydown', function (e) {
        if (e.keyCode == 13) {

	showMsgAguardo('Aguarde, pesquisando associados ...');
	
            var cdpesqui = $('input[type="radio"]:checked', '#frmPesquisaAssociado').val();
            var nmdbusca = $('#nmdbusca', '#frmPesquisaAssociado').val();
            var tpdapesq = $('#tpdapesq', '#frmPesquisaAssociado').val();
            var cdagpesq = $('#cdagpesq', '#frmPesquisaAssociado').val();
            var tpdorgan = $('#tpdorgan', '#frmPesquisaAssociado').val();
            var nrcpfcgc = $('#nrcpfcgc', '#frmPesquisaAssociado').val();
            var nrdctitg = retiraCaracteres($('#nrdctitg', '#frmPesquisaAssociado').val(), '0123456789X', true);

	
	// Verifica código do PAC
            if ((cdpesqui == '1') && (cdagpesq == '' || !validaNumero(cdagpesq, true, 0, 999))) {
		hideMsgAguardo();
                showError('error', 'Informe o PA a ser pesquisado ou 0 para TODOS.', 'Alerta - Ayllos', "$('#cdagpesq','#frmPesquisaAssociado').focus();bloqueiaFundo($('#divPesquisaAssociado'));");
		return false;
	}	
	
	// Verifica código do PAC
	if (cdpesqui == '2' && nrdctitg == '') {
		hideMsgAguardo();
                showError('error', 'Informe o n&uacute;mero da Conta/ITG.', 'Alerta - Ayllos', "$('#nrdctitg','#frmPesquisaAssociado').focus();bloqueiaFundo($('#divPesquisaAssociado'));");
                $('#btnError').click();
		return false;
	}	

	// Verifica código do PAC
	if (cdpesqui == '3' && nrcpfcgc == '') {
		hideMsgAguardo();
                showError('error', 'Informe o CPF/CNPJ a ser pesquisado.', 'Alerta - Ayllos', "$('#nrcpfcgc','#frmPesquisaAssociado').focus();bloqueiaFundo($('#divPesquisaAssociado'));");
		return false;
	}	

	// Carrega dados da conta através de ajax
	$.ajax({		
		type: 'POST',
		url: UrlSite + 'includes/pesquisa/realiza_pesquisa_associados.php', 
		data: {
			cdpesqui: cdpesqui,
			nmdbusca: nmdbusca,
			tpdapesq: tpdapesq,
			cdagpesq: cdagpesq,
			nrdctitg: nrdctitg,
			nriniseq: nriniseq,
			tpdorgan: tpdorgan,
			nrcpfcgc: nrcpfcgc,
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},
                error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', "bloqueiaFundo($('#divPesquisaAssociado'));");
		},			
                success: function (response) {
			$('#divResultadoPesquisaAssociado').html(response);			
			zebradoLinhaTabela($('#divPesquisaAssociadoItens > table > tbody > tr'));
			$('#divPesquisaAssociadoRodape').formataRodapePesquisa();
                    controlaFoco();
		}				
	});	

        }
    })


}

/*!
 * ALTERAÇÃO  : 002
 * OBJETIVO   : Função disparada no click da linha da consulta associado, com a finalidade de atribuir o Nr. Conta para o campo representado 
 *              pelas variáveis globais "vg_campoRetorno" e "vg_formRetorno". O valor que esta campo assumirá é passado por parâmetro
 * PARÂMETROS : conta -> Nr. conta retornado pela consulta
 */	
function selecionaAssociado(conta,nmprimtl,dsnivris,nrcpfcgc) {	
	// Chama o evento click do botão fechar, que foi previamente configurado na função "mostraPesquisaAssociado"
	$('.fecharPesquisa','#divPesquisaAssociado').click();
	
	// Atribui conta consultada para campo e formulários contidos nas respectivas variáveis globais 
	$('#'+vg_campoRetorno[0],'#'+vg_formRetorno).val(conta).formataDado('INTEGER','zzzz.zzz-z','',false);
	$('#'+vg_campoRetorno[1],'#'+vg_formRetorno).val(nmprimtl);
	if ($('#cdclassificacao_produto', '#' + vg_formRetorno).val() != "AA") { $('#' + vg_campoRetorno[2], '#' + vg_formRetorno).prop('selected', true).val(dsnivris); }
	$('#'+vg_campoRetorno[3],'#'+vg_formRetorno).val(nrcpfcgc);
					
	// Chamar função obtemCabecalho somente quando estivermos na tela CONTAS e não existir alguma rotina da tela aberta
	if ( $('#divRotina').css('visibility') == 'hidden' 
		 && $('#divTela').css('visibility') == undefined  
		 && $('#divMatric').css('visibility') == undefined  
		 && $('#divAnota').css('visibility') == undefined ) {
		$('#idseqttl','#frmCabContas').val('1');
		obtemCabecalho();		
	} else {
		$('#'+vg_campoRetorno[0],'#'+vg_formRetorno).trigger('change');
	}
			
	// Da foco no campo
	$('#'+vg_campoRetorno[0],'#'+vg_formRetorno).focus();	
	
}




/*!
 * ALTERAÇÃO  : 012
 * OBJETIVO   : Esta função é chamada no click do mouse em cima de algum resultado da pesquisa de endereço, 
 *              onde irá retornar os dados para o campo contido no parâmetro "resultado"
 * PARÂMETROS : resultado -> Uma string no formado "campoNome|campoValor", onde o campoNome é o nome do campo ao qual
 *                           receberá o valor contido no campoValor
 */
function selecionaPesquisaEndereco(resultado, idForm, cNumero) {	
	// O layout do parâmetro resultado é:
	// "nomeCampo;resultado|nomeCampo;resultado"
	var arrayCampos	   = new Array();	
	var arrayResultado = new Array();	

	arrayCampos = resultado.split("|");
	
	cCep = arrayCampos[0].split(";")[0];
	
	for( var i in arrayCampos ) {		
		arrayResultado 	= arrayCampos[i].split(";");
		var campoNome 	= arrayResultado[0];
		var campoValor 	= arrayResultado[1];		
		// Retornando resultado do item selecionado aos devidos campos
		$("input[name='"+campoNome+"'],select[name='"+campoNome+"']",'#'+idForm).val(campoValor);
	}	
	
	// Essa variável global é alimentada com uma função específica da rotina que está utilizando a pesquisa
	// Essa função será executada após a seleção do registro
	// Exemplo de utilização na tela CADDNE
	if (typeof mtSelecaoEndereco != "undefined") mtSelecaoEndereco();
	
	$('.fecharPesquisa','#divPesquisaEndereco').click();
	$('#'+cCep,'#'+idForm ).trigger('blur');	
	$('#'+cNumero,'#'+idForm).focus();	
}

/*!
 * ALTERAÇÃO  : 012
 * OBJETIVO   : Função genérica que monta dinâmicamente o formulário de pesquisa "formPesquisa"
 *              Esta função é responsável por inserir neste formulário os filtros de pesquisa e o cabeçalho da tabela que irá exibir o resultado da pesquisa
 * PARÂMETROS : idForm 			-> 
 *              camposOrigem	-> 
 *              divBloqueia   	-> 
 *              vCEP	      	-> [Opcional]
 */
function mostraPesquisaEndereco(idForm, camposOrigem, divBloqueia, vCEP) {

	var idRotina = divBloqueia.attr('id');
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando Pesquisa Endereço...");

	$('#formPesquisaEndereco').limpaFormulario();		
	
	$('.fecharPesquisa','#divPesquisaEndereco').unbind('click').bind('click', function() {
		
		$('#formPesquisaEndereco').limpaFormulario();		
		$('#divResultadoPesquisaEndereco').empty();		
		
		if ( typeof divBloqueia == 'object' ) {
			fechaRotina($('#divPesquisaEndereco'),divBloqueia);
		} else {
			fechaRotina($('#divPesquisaEndereco'));
		}
	});		

	//montar um input hidden com o nome camposOrigem que receberá o valor passado como parâmetro
	$("#camposOrigem","#formPesquisaEndereco").val(camposOrigem);
	$("#idForm","#formPesquisaEndereco").val(idForm);

	$("#divPesquisaRodape").remove();	
	
	if ( typeof vCEP != 'undefined' ) {
	
		vCEP = normalizaNumero(vCEP);
		
		if (vCEP == 0) {
			// fazer o tratemento
			limparEndereco(camposOrigem, idForm);
			hideMsgAguardo();
			bloqueiaFundo($('#'+idRotina));
			
		} else {
			$('#nrcepend','#formPesquisaEndereco').val(vCEP);		
			$('#formPesquisaEndereco').css({'display':'none'});
			realizaPesquisaEndereco(1,20,'S',idRotina);
			
		}		
	} else {	
		$('#formPesquisaEndereco').css({'display':'block'});
		hideMsgAguardo();	
		exibeRotina($('#divPesquisaEndereco'));	
		bloqueiaFundo($("#divPesquisaEndereco"));	
		$('input[type=\'text\']:first','#formPesquisaEndereco').focus();
		
	}
	
}

/*!
 * ALTERAÇÃO  : 012
 * OBJETIVO   : Função genérica que chama a função "realizaPesquisaEndereço2. Este tratamento é para 
 *              acertar um BUG do IE em relação as mensagens de aguardo.
 */
function realizaPesquisaEndereco(nriniseq, quantReg, auto, idRotina) {
	showMsgAguardo("Aguarde, pesquisando endere&ccedil;o ...");
	setTimeout( 'realizaPesquisaEndereco2("'+nriniseq+'", "'+quantReg+'", "'+auto+'", "'+idRotina+'")', 200 );	
	return false;
}

/*!
 * ALTERAÇÃO  : 012
 * OBJETIVO   : Função chamada a partir do botão "Iniciar Pesquisa" da tela "pesquisa_endereco.php"
 *              Esta função passa a requisição via POST da pesquisa para o arquivo "realiza_pesquisa_endereco.php"
 * PARÂMETROS : nriniseq	-> Nr. inicial da paginação
 *              quantReg	-> Quantidade de registros que serão exibidos a cada paginação
 *              auto		-> [Opcional] Caso for 'S' e para o CEP digitado existir somente um endereço, então já selecioná-lo
 *              idRotina	-> [Opcional] 
 */
function realizaPesquisaEndereco2(nriniseq, quantReg, auto, idRotina) {

	if( !verificaSemaforo() ) { return false; }
	
	// Mostra mensagem de aguardo	
	
	var idForm 			= $('#idForm', '#formPesquisaEndereco').val();
	var camposOrigem 	= $('#camposOrigem', '#formPesquisaEndereco').val();
	var nrcepend 		= $('#nrcepend', '#formPesquisaEndereco').val();
	var dsendere 		= $('#dsendere', '#formPesquisaEndereco').val();
	var nmcidade 		= $('#nmcidade', '#formPesquisaEndereco').val();
	var cdufende 		= $('#cdufende', '#formPesquisaEndereco').val() ? $('#cdufende', '#formPesquisaEndereco').val() : '';
	
	nrcepend = normalizaNumero( nrcepend );	
	dsendere = trim( dsendere );
	nmcidade = trim( nmcidade );
	cdufende = trim( cdufende );
	
	if (typeof auto == 'undefined' && auto != 'S')  {
		auto = 'N';
	} 
	
	// Carrega dados da conta através de ajax
	$.ajax({
		//async: false,
		type: "POST",  
		url: UrlSite + "includes/pesquisa/realiza_pesquisa_endereco.php", 
		data: {
			auto			: auto,
			nrcepend 		: nrcepend,
			dsendere 		: dsendere,
			nmcidade 		: nmcidade,
			cdufende 		: cdufende,
			nriniseq 		: nriniseq,
			quantReg 		: quantReg,
			camposOrigem 	: camposOrigem,
			idForm 			: idForm,
			idRotina		: idRotina,
			redirect 		: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			semaforo--;
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","bloqueiaFundo($('#divPesquisaEndereco'))");
		},
		success: function(response) {
			semaforo--;
		    $("#divResultadoPesquisaEndereco").html(response);
			zebradoLinhaTabela($('#divPesquisaItens > table > tbody > tr'));
			$('#divPesquisaRodape').formataRodapePesquisa();	
		}			
	});
	
	return false;
}

/*!
 * ALTERAÇÃO  : 012
 * OBJETIVO   : Função genérica para mostrar o formulário de inclusao de endereco
 * PARÂMETROS : divBloqueia -> div que será bloqueado quando o formulário de inclusão por mostrado
 */
function mostraFormularioEndereco(divBloqueia) {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando Formulário Endereço...");

	$('#formFormularioEndereco').limpaFormulario();		
	
	$('.fecharPesquisa','#divFormularioEndereco').unbind('click').bind('click', function() {
		
		$('#formFormularioEndereco').limpaFormulario();		
		
		if ( typeof divBloqueia == 'object' ) {
			fechaRotina($('#divFormularioEndereco'),divBloqueia);
		} else {
			fechaRotina($('#divFormularioEndereco'));
		}
	});		

	hideMsgAguardo();	

	$('input, select','#formFormularioEndereco').removeClass('campoErro');	
	exibeRotina($('#divFormularioEndereco'));	
	bloqueiaFundo($("#divFormularioEndereco"));	
	$('input[type=\'text\']:first','#formFormularioEndereco').focus();
	
}

/*!
 * ALTERAÇÃO  : 012
 * OBJETIVO   : Função genérica validar e gravar novos endereços
 * PARÂMETROS : operacao -> Valores válidos [V] Validação | [I] Inclusão
 */
function manterEndereco( operacao ) {
	
	if( !verificaSemaforo() ) { return false; }
	
	hideMsgAguardo();	
	var msgOperacao = '';
	switch (operacao) {	
		case 'S': msgOperacao = 'salvando inclus&atilde;o';break;
		case 'V': msgOperacao = 'validando inclus&atilde;o';break;						
		default: return false; break;
	}
	showMsgAguardo('Aguarde, ' + msgOperacao + ' ...');
	
	nrcepend = $('#nrcepend','#formFormularioEndereco').val();
	dstiplog = $('#dstiplog','#formFormularioEndereco').val();	
	nmreslog = $('#nmreslog','#formFormularioEndereco').val();	
	nmresbai = $('#nmresbai','#formFormularioEndereco').val();	
	nmrescid = $('#nmrescid','#formFormularioEndereco').val();
	cdufende = $('#cdufende','#formFormularioEndereco').val();
	dscmplog = $('#dscmplog','#formFormularioEndereco').val();
	
	nrcepend = normalizaNumero(nrcepend);
	
	// Executa script de confirmação através de ajax
	$.ajax({
		type : 'POST',
		url : UrlSite + 'includes/pesquisa/manter_endereco.php', 		
		data: {
			nrcepend: nrcepend, dstiplog: dstiplog,
			nmreslog: nmreslog, nmresbai: nmresbai, 
			nmrescid: nmrescid,	cdufende: cdufende, 
			dscmplog: dscmplog, operacao: operacao, 
			redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			semaforo--;
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			semaforo--;
			try {
				eval(response);
				return false;
			} catch(error) {
				hideMsgAguardo();
				showError('error',' N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
			}
		}				
	});
}

/*!
 * ALTERAÇÃO  : 012
 * OBJETIVO   : Função para limpar os campos do Endereço
 * PARÂMETROS : camposOrigem -> [String] Todos campos de endereço separados por ";"
 *              idForm		 -> [String] Id do formulário que contém os campos do endereço
 */
function limparEndereco(camposOrigem,idForm) {
	
	var campos 	= camposOrigem.split(";");
	var cCep	= campos[0];
	var cEndere	= campos[1];
	var cNumero	= campos[2];
	var cComple	= campos[3];
	var cCxPost	= campos[4];
	var cBairro	= campos[5];
	var cEstado	= campos[6];
	var cCidade	= campos[7];
	var cCdtipo	= campos[8];
	var cCdorig	= campos[9];
	var cDsorig	= campos[10];
	var cNrowid = campos[11];

	$('#'+cCep+',#'+cEndere+',#'+cNumero+',#'+cComple+',#'+cCxPost+',#'+cBairro+',#'+cEstado+',#'+cCidade+',#'+cCdtipo+',#'+cCdorig+',#'+cDsorig+',#'+cNrowid,'#'+idForm).limpaFormulario();	
	$('#'+cCep,'#'+idForm).focus();
}

/*!
 * OBJETIVO: Extenções jQuery para as pesquisas
 */
$.fn.extend({ 
	
	/*!
	 * ALTERAÇÃO : 013
	 * OBJETIVO  : Ao clicar ENTER no campo CEP, fazer uma requisição AJAX (função mostraPesquisaEndereco), 
	 *             e retornar os dados do endereço para a rotina corrente. Caso não haver CEP digitado ou 
	 *             for iguar a zero, limpar campos do endereço.
	 */
	buscaCEP: function(nomeForm, camposOrigem, divRotina) { 
		
		var cCEP = $(this); 
		cCEP.unbind('keydown').bind('keydown', function(e) { 
			if(divError.css('display') == 'block') { return false; }
            
			if (e.keyCode == 13 || e.keyCode == 9) {
			
				mostraPesquisaEndereco(nomeForm, camposOrigem, divRotina, $(this).val());
				return false;
			}
			
		}).unbind('change').bind('change', function() {
			if ( normalizaNumero($(this).val()) == 0 ) {
				limparEndereco(camposOrigem, nomeForm);
			}
		});	
		cCEP.next().unbind('click').bind('click', function(){ // Botão Pesquisa
			if( cCEP.hasClass('campo') ) mostraPesquisaEndereco(nomeForm, camposOrigem, divRotina);
			return false;
		});
	},	
	
	/*!
	 * ALTERAÇÃO  : 014
	 * OBJETIVO   : Controlar os métodos para os campos de Conta. Controla os eventos do ENTER,
	 *              do click do link da lupa seguinte, e o click do link refres seguinte a lupa
	 * PARÂMETROS : fncPesquisa -> Função executada para fazer a pesquisa da conta informada
	 *              fncLimpa    -> Função executada quando pressionar a tecla F8 ou clicar no link Refresh
	 *              divRotina   -> Div que será bloqueado o fundo ao re
	 */	
	buscaConta: function(fncPesquisa, fncLimpa) {	
		
		// Declarando a variável cConta que referencia o seletor $(this)
		var cConta = $(this);		
		
		// Descobrindo o ID do formulário que contém o campo Conta		
		var nomeCampo = cConta.attr('id');		
		
		// Descobrindo o ID do formulário que contém o campo Conta		
		var nomeForm = $( cConta.parents('form').get(0) ).attr('id');
		
		// Monta a função de foco para passar para o mostraPesquisaAssociado		
		var fncFoco = '$("'+cConta.selector+'").focus();';
		
		// ENTER pressionado no campo CONTA
		cConta.unbind('keypress').bind('keypress', function(e) {					
			if ( divError.css('display') == 'block' ) { return false; }
			if ( e.keyCode == 13 ) { // Tecla ENTER
				eval(fncPesquisa);
				return false;
			} else if ( e.keyCode == 119 ) { // Tecla F8
				eval(fncLimpa); 
				return false;			
			} else if ( e.keyCode == 118 ) { // Tecla F7	
				mostraPesquisaAssociado(nomeCampo, nomeForm, divRotina, fncFoco);
				return false;							
			}			
		});			
		
		// Somente prossegue, caso a próxima tag (PRIMEIRO elemento após o número da conta)
		// for um link <a> com a classe "lupa", representando o Botão de Pesquisa
		var proxCampo1 = cConta.next();
		if ( (proxCampo1.get(0).tagName.toLowerCase() == 'a') && (proxCampo1.hasClass('lupa')) ) {
			proxCampo1.unbind('click').bind('click', function(){  
				if( $(this).hasClass('pointer') ) mostraPesquisaAssociado(nomeCampo, nomeForm, divRotina, fncFoco);
				return false;
			});	
		}
		
		// Somente prossegue, caso a próxima tag (SEGUNDO elemento após o número da conta)
		// for um link <a>, representando o Botão de Refresh
		var proxCampo2 = cConta.next().next();
		if (proxCampo2.get(0).tagName.toLowerCase() == 'a') {		
			proxCampo2.unbind('click').bind('click', function(){
				if( $(this).hasClass('pointer') ) eval(fncLimpa);
				return false;
			});				
		}
	},
	
	/*!
	 * ALTERAÇÃO  : 015
	 * OBJETIVO   : 
	 */	
	buscaCPF: function(fncPesquisa) {
	
		$(this).unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }
			if(e.keyCode == 13) { // ENTER
				eval(fncPesquisa);
				return false;
			}	
		});
        
         // Odirlei PRJ339
        $(this).unbind('change').bind('change', function(e) {
            
			if ( divError.css('display') == 'block' ) { return false; }		
				eval(fncPesquisa);
				return false;	
		});
	}
	
});




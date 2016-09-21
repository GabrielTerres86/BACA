/*!
 * FONTE        : parcyb.js
 * CRIA��O      : Douglas Quisinski
 * DATA CRIA��O : 08/09/2015
 * OBJETIVO     : Biblioteca de fun��es da tela PARCYB
 * --------------
 * ALTERA��ES   :
 * --------------
 */

var flgVoltarGeral = 1;

$(document).ready(function() {
	// Estado Inicial da tela
	estadoInicial();
	// Formatar a consulta de assessorias
	formataConsultaAssessoria();
	// Formatar a consulta de motivos CIN
	formataConsultaMotivoCin();
	// Formatar a consulta de Parametriza��o de Hist�ricos
	formataConsultaParametrizarHistorico();
});

// Fun��o para o estado Inicial da tela de Parametriza��o do CYBER
function estadoInicial(){
	//Voltar para a tela principal
	flgVoltarGeral = 1;
	
	$("#divTela").fadeTo(0,0.1);

	hideMsgAguardo();
	//Formata��o do cabe�alho
	formataCabecalho();
	//Formata��o da tela de Assessoria
	formataTelaAssessoria();
	//Formata��o da tela de Motivos CIN
	formataTelaMotivoCin();
	//Formata��o da tela de Parametriza��o de Hist�ricos
	formataTelaParametrizarHistorico();
	
	removeOpacidade("divTela");

	highlightObjFocus( $("#frmCab") );
	
	//Exibe cabe�alho e define tamanho da tela
	$("#frmCab").css({"display":"block"});
	$("#divTela").css({"width":"700px","padding-bottom":"2px"});
	
	//Esconder a tela de assessorias
	$("#divTelaAssessoria").css({"display":"none"});
	//Esconder a tela de motivos CIN
	$("#divTelaMotivoCin").css({"display":"none"});
	//Esconder a tela de parametriza��o dos hist�ricos
	$("#divTelaParametrizarHistorico").css({"display":"none"});
	
	//Esconder os bot�es da tela
	$("#divBotoes").css({"display":"none"});
	
	//Foca o campo da Op��o
	$("#cddotipo","#frmCab").focus();
}

// Formata o Cabe�alho da P�gina
function formataCabecalho() {
	// rotulo
	$('label[for="cddotipo"]',"#frmCab").addClass("rotulo").css({"width":"100px"}); 
	
	// campo
	$("#cddotipo","#frmCab").css("width","500px").habilitaCampo();
	
	$('input[type="text"],select','#frmCab').limpaFormulario().removeClass('campoErro');
	layoutPadrao();
	
	//Define a��o para ENTER e TAB no campo Op��o
	$("#cddotipo","#frmCab").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			//Executa fun��o do bot�o OK
			liberaFormulario();
			return false;
		}
    });	
	
	//Define a��o para CLICK no bot�o de OK
	$("#btnOK","#frmCab").unbind('click').bind('click', function() {
		liberaFormulario();
		return false;
    });	
	return false;	
}

// Fun��o para liberar as informa��es do formul�rio de acordo com a configura��o desejada
function liberaFormulario(){
	var cddotipo = $("#cddotipo","#frmCab");
	
	if(cddotipo.prop("disabled")){
		// Se o campo estiver desabilitado, n�o executa a libera��o do formul�rio pois j� existe uma a��o sendo executada
		return;
	}
	
	cddotipo.desabilitaCampo();
	
	// Validar a op��o que foi selecionada na tela
	switch(cddotipo.val()){
		case "A": // Assessorias
			estadoInicialAssessorias();
		break;
		
		case "M": // Motivos CIN
			estadoInicialMotivosCin();
		break;
		
		case "H": // Parametriza��o de Hist�ricos
			estadoInicialParametrizarHistorico();
		break;
		
		default:
			estadoInicial();
		break;
	}
}

// Fun��o para controlar as a��es para quando acionar o bot�o voltar na tela
function controlaVoltar(){
	// Validar qual a op��o que foi selecionada no cabe�alho padr�o
	switch($("#cddotipo","#frmCab").val()){
		case "A": // Assessorias
			// Realiza as valida��o da op��o de voltar da assessoria
			controlaVoltarAssessoria();
		break;
		
		case "M": // Motivos CIN
			// Realiza as valida��o da op��o de voltar da motivo CIN
			controlaVoltarMotivoCin();
		break;
		
		case "H": // Parametriza��o de Hist�ricos
			controlaVoltarParametrizarHistorico();
		break;
		
		default:
			// Por padr�o volta para o estado inicial da tela
			estadoInicial();
		break;
	}
}

// Fun��o para controlar as a��es para quando acionar o bot�o concluir na tela
function controlaConcluir(){
	switch($("#cddotipo","#frmCab").val()){
		case "A": // Assessorias
			// Realiza as valida��o da op��o de concluir da assessoria
			controlaConcluirAssessoria();
		break;
		
		case "M": // Motivos CIN
			// Realiza as valida��o da op��o de concluir da motivo CIN
			controlaConcluirMotivoCin();
		break;
		
		case "H": // Parametriza��o de Hist�ricos
			// Realiza as valida��o da op��o de concluir da parametrizacao de historicos
			controlaConcluirParametrizarHistorico();
		break;
	}
}

/***********************************************************************************************************
									IN�CIO -> Fun��es para a tela de Assessoria
***********************************************************************************************************/
// Fun��o para o estado inicial da tela de Assessorias
function estadoInicialAssessorias(){
	//No estado inicial da tela de assessorias, retorna para a principal
	flgVoltarGeral = 1;
	
	hideMsgAguardo();
	
	removeOpacidade("divTela");
	
	// Mostrar a tela de assessorias
	$("#divTelaAssessoria").css({"display":"block"});
	
	highlightObjFocus( $("#frmCabAssessoria","#divTelaAssessoria") ); 
	
	//Esconde a consulta e limpa a tabela
	$("#divConsultaAssessoria","#divTelaAssessoria").css({"display":"none"});
	//$("#divExclusaoAssessoria","#divTelaAssessoria").css({"display":"none"});
	$("#tbCadcas > tbody").html("");
	
	//Esconde cadastro e os bot�es
	$("#frmAssessoria","#divTelaAssessoria").css({"display":"none"});
	$("#divBotoes").css({"display":"block"});
	
	//Exibe cabe�alho e define tamanho da tela
	$("#frmCabAssessoria","#divTelaAssessoria").css({"display":"block"});
	
	//Limpa os campos do formul�rio e remove o erro dos campos
	$('input[type="text"],select','#frmAssessoria').limpaFormulario().removeClass('campoErro');
	//Foca o campo da Op��o
	$("#cddopcao_assessoria","#frmCabAssessoria").habilitaCampo().val("CA").focus();
	//Esconde o bot�o de concluir
	$("#btConcluir","#divBotoes").hide();
}

// Fun��o para formatar a tela de assessoria
function formataTelaAssessoria(){
	//Formata��o do cabe�alho e formul�rio
	formataCabecalhoAssessoria();
	formataCadastroAssessoria();
}

// Formata o Cabe�alho da tela de Assessorias
function formataCabecalhoAssessoria() {
	// rotulo
	$('label[for="cddopcao_assessoria"]',"#frmCabAssessoria").addClass("rotulo").css({"width":"100px"}); 
	
	// campo
	$("#cddopcao_assessoria","#frmCabAssessoria").css("width","500px").habilitaCampo();
	$('input[type="text"],select','#frmCabAssessoria').limpaFormulario().removeClass('campoErro');
	layoutPadrao();
	
	//Define a��o para ENTER e TAB no campo Op��o
	$("#cddopcao_assessoria","#frmCabAssessoria").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			//Executa fun��o do bot�o OK
			liberaAcaoAssessoria();
			return false;
		}
    });	

	//Define a��o para CLICK no bot�o de OK da tela de Assessoria
	$("#btnOkAssessoria","#frmCabAssessoria").unbind('click').bind('click', function(e) {
		//Executa fun��o do bot�o OK
		liberaAcaoAssessoria();
		return false;
    });	
	
	return false;	
}

// Fun��o para formatar os campos da tela de cadastro de assessoria
function formataCadastroAssessoria(){
	// rotulo
	$('label[for="cdassessoria"]',"#frmAssessoria").addClass("rotulo").css({"width":"150px"}); 
	$('label[for="nmassessoria"]',"#frmAssessoria").addClass("rotulo").css({"width":"150px"}); 
	
	// campo
	$("#cdassessoria","#frmAssessoria").css("width","100px").habilitaCampo();
	$("#nmassessoria","#frmAssessoria").addClass("alphanum").css("width","500px").attr("maxlength","50").habilitaCampo();
	
	$('input[type="text"],select','#frmAssessoria').limpaFormulario().removeClass('campoErro');
	layoutPadrao();

	//Define a��o para o campo de c�digo da assessoria
	$("#cdassessoria","#frmAssessoria").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Quando ENTER ou TAB realiza a busca da assessoria pelo c�digo
			buscaAssessoria();
			return false;
		}
    });	
	
	//Define a��o para o campo de c�digo da assessoria
	$("#cdassessoria","#frmAssessoria").unbind('blur').bind('blur', function(e) {
		// Quando ENTER ou TAB realiza a busca da assessoria pelo c�digo
		buscaAssessoria();
		return false;
    });	

	//Define a��o para o campo de nome da assessoria
	$("#nmassessoria","#frmAssessoria").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			//Quando ENTER ou TAB executa a a��o de concluir do formul�rio
			controlaConcluirAssessoria();
			return false;
		}
    });	
	return false;
}

// Formata a tela de Consulta da P�gina
function formataConsultaAssessoria() {
	// Tabela
	$("#divConteudo","#divTelaAssessoria").css({"display":"block"});

    var divRegistro = $("div.divRegistros", "#tabCadcas");
	var tabela      = $("table", divRegistro );
	var linha       = $("table > tbody > tr", divRegistro );

    $("#tabCadcas").css({"margin-top":"5px"});
	divRegistro.css({"height":"290px","width":"700px","padding-bottom":"2px"});

	var ordemInicial = new Array();
	
	//Define a largura dos campos
	var arrayLargura = new Array();
    arrayLargura[0] = "80px";
    arrayLargura[1] = "";
    arrayLargura[2] = "80px";

	//Define a posi��o dos elementos nas c�lulas da linha
    var arrayAlinha = new Array();
	arrayAlinha[0] = "left";
	arrayAlinha[1] = "left";
	arrayAlinha[2] = "center";

	//Aplica as informa��es na tabela
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);
	return false;
}

// Fun��o para liberar as informa��es da tela de assessoria
function liberaAcaoAssessoria(){
	var cddopcao = $("#cddopcao_assessoria","#frmCabAssessoria");
	cddopcao.desabilitaCampo();
	//Quando executar a tela de assessoria, retorna para a tela de assessorias
	flgVoltarGeral = 0;

	$("#divConsultaAssessoria").css({"display":"none"});
	//$("#divExclusaoAssessoria").css({"display":"none"});
	$("#frmAssessoria").css({"display":"none"});
	
	// Esconder o bot�o de Concluir
	$("#btConcluir","#divBotoes").hide();

	//Validar a op��o selecionada na tela
	if(cddopcao.val() == "CA") {
		// executa a consulta, listando as assessorias cadastradas
		executaConsultaAssessorias();
	} else if (cddopcao.val() == "EA"){
		// executa a consulta, listando as assessorias cadastradas (Exclus�o)
		executaConsultaAssessoriasExclusao();
	} else {
		$("#frmAssessoria").css({"display":"block"});
		$("#divBotoes").css({"display":"block"});
		$("#btConcluir","#divBotoes").show();
		
		$("#cdassessoria","#frmAssessoria").habilitaCampo().focus();
		if(cddopcao.val() == "IA"){
			// Quando for inclus�o desabilita o c�digo para que seja possivel informar apenas o nome da assessoria
			$("#cdassessoria","#frmAssessoria").desabilitaCampo();
			$("#nmassessoria","#frmAssessoria").focus();
		}
		
		// Verificar a op��o para exibir a lupa de pesquisa
		if(cddopcao.val() == "AA"){
			$("#pesqassess").css({"display":"block"});
		} else {
			$("#pesqassess").css({"display":"none"});
		}
	}
}

// Fun��o para o bot�o voltar
function controlaVoltarAssessoria(){
	if (flgVoltarGeral == 1) {
		// Quando n�o for executado nada na tela de assessoria, retorna para a tela principal
		estadoInicial();
	} else {
		// Quando ocorrer alguma a��o na tela de assessoria, retorna para o estado inicial da tela de assessorias
		estadoInicialAssessorias();
	}
}

// Fun��o para o bot�o Concluir
function controlaConcluirAssessoria(){
	//Valida��o do campo c�digo para quando a op��o n�o for incluir
	if($("#cddopcao_assessoria","#frmCabAssessoria").val() != "IA" && $("#cdassessoria","#frmAssessoria").val() == "") {
		showError('error','C&oacute;digo inv&aacute;lido!','Campo obrigat&oacute;rio','$("#cdassessoria","#frmAssessoria").focus();');
		return false;
	}
	
	//Valida��o da descri��o informada
	if($("#nmassessoria","#frmAssessoria").val() == "") {
		showError('error','Nome de Assessoria inv&aacute;lido!','Campo obrigat&oacute;rio','$("#nmassessoria","#frmAssessoria").focus();');
		return false;
	}
	
	//Verifica a op��o
	if($("#cddopcao_assessoria","#frmCabAssessoria").val() == "AA") {
		//Quando for altera��o, solicita confirma��o
		showConfirmacao('Confirma a altera&ccedil;&atilde;o da assessoria?','Confirma&ccedil;&atilde;o - Ayllos','confirmouOperacaoAssessoria();','','sim.gif','nao.gif');
	} else {
		//Se n�o est� alterando executa a a��o
		confirmouOperacaoAssessoria();
	}
}

function confirmouOperacaoAssessoria(){
	//Recupera a op��o
	var cddopcao = $("#cddopcao_assessoria","#frmCabAssessoria").val();
	var mensagem = "Aguarde ...";
	
	//Atualiza a mensagem que ser� exibida
	if(cddopcao == "IA") {
		mensagem = "Aguarde, incluindo assessoria ...";
	} else {
		mensagem = "Aguarde, alterando assessoria ...";
	}
	//mostra mensagem e finaliza a opera��o
	showMsgAguardo( mensagem );	

	var nmassessoria = $("#nmassessoria","#frmAssessoria").val()
														  .replace(/[������]/g,"A")
	                                                      .replace(/[������]/g,"a")
														  .replace(/[������]/g,"O")
														  .replace(/[������]/g,"o")
														  .replace(/[����]/g,"E")
														  .replace(/[����]/g,"e")
														  .replace(/[�]/g,"C")
														  .replace(/[�]/g,"c")
														  .replace(/[����]/g,"I")
														  .replace(/[����]/g,"i")
														  .replace(/[����]/g,"U")
														  .replace(/[����]/g,"u")
														  .replace(/[�]/g,"y")
														  .replace(/[�]/g,"N")
														  .replace(/[�]/g,"n")
														  .replace(/[^A-z0-9\s\!\@\$\%\*\(\)\-\_\=\+\[\]\{\}\?\;\:\.\,\/\>\<]/g,"");

	manterAssessoria(cddopcao,$("#cdassessoria","#frmAssessoria").val(),nmassessoria);
}

// Fun��o para executar a busca de todas as acessorias
function executaConsultaAssessorias(){
	//Mostrar a consulta e bot�es
	$("#divConsultaAssessoria").css({"display":"block"});
	$("#divBotoes").css({"display":"block"});
	//Esconder o bot�o de concluir, pois na consulta exibe apenas a op��o de voltar
	$("#btConcluir","#divBotoes").hide();
	//Limpar a tabela
	$("#tbCadcas > tbody").html("");
	//Iniciar a busca das assessorias
	showMsgAguardo( "Aguarde, carregando assessorias..." );	
	manterAssessoria("CA","","");	
}

function executaConsultaAssessoriasExclusao(){
	//Mostrar a consulta e bot�es
	$("#divConsultaAssessoria").css({"display":"block"});
	$("#divBotoes").css({"display":"block"});
	//Esconder o bot�o de concluir, pois na consulta exibe apenas a op��o de voltar
	$("#btConcluir","#divBotoes").hide();
	//Limpar a tabela
	$("#tbCadcas > tbody").html("");
	//Iniciar a busca das assessorias
	showMsgAguardo( "Aguarde, carregando assessorias..." );	
	//Verificar
	manterAssessoria("EA","","");
}

// Fun��o para criar a linha com as assessorias cadastradas
function criaLinhaAssessoria(cdassessoria,nmassessoria){
	// Criar a linha na tabela
	$("#tbCadcas > tbody")
		.append($('<tr>') // Linha
			.attr('id',"id_".concat(cdassessoria))
			.append($('<td>') // Coluna: C�digo da Assessoria
				.attr('style','width: 80px; text-align:right')
				.text(cdassessoria)
			)
			.append($('<td>') // Coluna: Nome da Assessoria
				.attr('style','text-align:left')
				.text(nmassessoria)
			)
			.append($('<td>') // Coluna: Bot�o para REMOVER
				.attr('style','width: 80px; text-align:center')
				.append($('<img onclick="solicitarMensagemExclusaoAssessoria(' + cdassessoria + ')">')
					.attr('src', UrlImagens + 'geral/btn_excluir.gif')
				)
			)
		);
}

function criaLinhaAssessoriaConsulta(cdassessoria,nmassessoria){
	// Criar a linha na tabela
	$("#tbCadcas > tbody")
		.append($('<tr>') // Linha
			.attr('id',"id_".concat(cdassessoria))
			.append($('<td>') // Coluna: C�digo da Assessoria
				.attr('style','width: 80px; text-align:right')
				.text(cdassessoria)
			)
			.append($('<td>') // Coluna: Nome da Assessoria
				.attr('style','text-align:left')
				.text(nmassessoria)
			)
		);
}

// Fun��o para solicitar confirma��o da exclus�o da assessoria
function solicitarMensagemExclusaoAssessoria(cdassessoria){
	showConfirmacao('Confirma a exclus&atilde;o da assessoria?','Confirma&ccedil;&atilde;o - Ayllos','excluirAssessoria(' + cdassessoria + ');','','sim.gif','nao.gif');
}

// Fun��o para realizar a requisi��o de exclus�o da assessoria
function excluirAssessoria(cdassessoria){
	if(cdassessoria == "" ) {
		showError('error','Assessoria inv&aacute;lida!','Alerta - Ayllos','');
		return false;
	}
	//Exibe mensagem e solicita a exclus�o
	showMsgAguardo( "Aguarde, excluindo assessoria ..." );	
	manterAssessoria("EA",cdassessoria,"");
}

// Fun��o para manter rotina (Consultar/Incluir/Alterar/Excluir)
function manterAssessoria(cddopcao,cdassessoria,nmassessoria){
    //Requisi��o para processar a op��o que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/parcyb/manter_rotina_assessoria.php",
        data: {
            cddopcao:     cddopcao,
			cdassessoria: cdassessoria,
			nmassessoria: nmassessoria,
            redirect:     "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function(response) {
            hideMsgAguardo();
			try {
				eval(response);
			} catch (error) {
					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
				}
			}
    });
    return false;	
}

// Fun��o executada quando sair do campo de c�digo de assessoria na op��o Alterar
function buscaAssessoria(){
	var cdassessoria = $("#cdassessoria").val().trim();
	//Valida o c�digo da assessoria
	if(cdassessoria != "") {
		//Busca as informa��es do c�digo informado
		manterAssessoria("CA",cdassessoria,"");		
	}
}

// Fun��o para abrir a pesquisa de asessorias
function mostrarPesquisaAssessoria(){
	//Defini��o dos filtros
	var filtros	= "C�digo Assessoria;cdassessoria;50px;N;;N;|Nome Assessoria;nmassessoria;200px;S;;S;descricao";
	//Campos que ser�o exibidos na tela
	var colunas = 'C�digo;cdassessoria;20%;right|Nome Assessoria;nmassessoria;80%;left';			
	//Exibir a pesquisa
	mostraPesquisa("PARCYB", "PARCYB_BUSCAR_ASSESSORIAS", "Assessorias","100",filtros,colunas);
}

/***********************************************************************************************************
									FIM -> Fun��es para a tela de Assessoria
***********************************************************************************************************/

/***********************************************************************************************************
									IN�CIO -> Fun��es para a tela de Motivos CIN
***********************************************************************************************************/
// Fun��o para o estado inicial da tela de Motivos CIN
function estadoInicialMotivosCin(){
	//No estado inicial da tela de motivos CIN, retorna para a principal
	flgVoltarGeral = 1;
	
	hideMsgAguardo();
	
	removeOpacidade("divTela");
	
	// Mostrar a tela de motivos CIN
	$("#divTelaMotivoCin").css({"display":"block"});
	
	highlightObjFocus( $("#frmCabMotivoCin","#divTelaMotivoCin") ); 
	
	//Esconde a consulta e limpa a tabela
	$("#divConsultaMotivosCin","#divTelaMotivoCin").css({"display":"none"});
	$("#tbCadcmt > tbody").html("");
	
	
	//Esconde cadastro e os bot�es
	$("#frmMotivoCin","#divTelaMotivoCin").css({"display":"none"});
	$("#divBotoes").css({"display":"block"});
	
	//Exibe cabe�alho e define tamanho da tela
	$("#frmCabMotivoCin","#divTelaMotivoCin").css({"display":"block"});
	
	//Limpa os campos do formul�rio e remove o erro dos campos
	$('input[type="text"],select','#frmMotivoCin').limpaFormulario().removeClass('campoErro');
	//Foca o campo da Op��o
	$("#cddopcao_motivo_cin","#frmCabMotivoCin").habilitaCampo().val("CM").focus();
	//Esconde o bot�o de concluir
	$("#btConcluir","#divBotoes").hide();
}

// Fun��o para formatar a tela de motivo CIN
function formataTelaMotivoCin(){
	//Formata��o do cabe�alho e formul�rio
	formataCabecalhoMotivoCin();
	formataCadastroMotivoCin();
}

// Formata o Cabe�alho da tela de Motivos CIN
function formataCabecalhoMotivoCin() {
	// rotulo
	$('label[for="cddopcao_motivo_cin"]',"#frmCabMotivoCin").addClass("rotulo").css({"width":"100px"}); 
	
	// campo
	$("#cddopcao_motivo_cin","#frmCabMotivoCin").css("width","500px").habilitaCampo();
	$('input[type="text"],select','#frmCabMotivoCin').limpaFormulario().removeClass('campoErro');
	layoutPadrao();
	
	//Define a��o para ENTER e TAB no campo Op��o
	$("#cddopcao_motivo_cin","#frmCabMotivoCin").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			//Executa fun��o do bot�o OK
			liberaAcaoMotivoCin();
			return false;
		}
    });	

	//Define a��o para CLICK no bot�o de OK da tela de Motivo CIN
	$("#btnOkMotivoCin","#frmCabMotivoCin").unbind('click').bind('click', function(e) {
		//Executa fun��o do bot�o OK
		liberaAcaoMotivoCin();
		return false;
    });	
	
	return false;	
}

// Formata o cadastro de Motivos CIN
function formataCadastroMotivoCin() {
	// rotulo
	$('label[for="cdmotivocin"]',"#frmMotivoCin").addClass("rotulo").css({"width":"150px"}); 
	$('label[for="dsmotivocin"]',"#frmMotivoCin").addClass("rotulo").css({"width":"150px"}); 
	
	// campo
	$("#cdmotivocin","#frmMotivoCin").css("width","100px").habilitaCampo();
	$("#dsmotivocin","#frmMotivoCin").addClass("alphanum").css("width","500px").attr("maxlength","100").habilitaCampo();
	
	$('input[type="text"],select','#frmMotivoCin').limpaFormulario().removeClass('campoErro');
	layoutPadrao();

	//Define a��o para o campo de c�digo da motivo CIN
	$("#cdmotivocin","#frmMotivoCin").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Quando ENTER ou TAB realiza a busca da motivo CIN pelo c�digo
			buscaMotivoCin();
			return false;
		}
    });	

	//Define a��o para o campo de c�digo da motivo CIN
	$("#cdmotivocin","#frmMotivoCin").unbind('blur').bind('blur', function(e) {
		buscaMotivoCin();
		return false;
    });	
	
	//Define a��o para o campo de nome da motivo CIN
	$("#dsmotivocin","#frmMotivoCin").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			//Quando ENTER ou TAB executa a a��o de concluir do formul�rio
			controlaConcluirMotivoCin();
			return false;
		}
    });	
	
	return false;
}
// Formata a tela de Consulta da P�gina
function formataConsultaMotivoCin() {
	// Tabela
	$("#divConteudo","#divTelaMotivoCin").css({"display":"block"});

    var divRegistro = $("div.divRegistros", "#tabCadcmt");
	var tabela      = $("table", divRegistro );
	var linha       = $("table > tbody > tr", divRegistro );

    $("#tabCadcmt").css({"margin-top":"5px"});
	divRegistro.css({"height":"290px","width":"700px","padding-bottom":"2px"});

	var ordemInicial = new Array();
	
	//Define a largura dos campos
	var arrayLargura = new Array();
    arrayLargura[0] = "80px";
    arrayLargura[1] = "";
    arrayLargura[2] = "80px";

	//Define a posi��o dos elementos nas c�lulas da linha
    var arrayAlinha = new Array();
	arrayAlinha[0] = "left";
	arrayAlinha[1] = "left";
	arrayAlinha[2] = "center";

	//Aplica as informa��es na tabela
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);
	return false;
}

// Fun��o para liberar as informa��es da tela de motivos CIN
function liberaAcaoMotivoCin(){
	var cddopcao = $("#cddopcao_motivo_cin","#frmCabMotivoCin");
	cddopcao.desabilitaCampo();
	flgVoltarGeral = 0;

	$("#divConsultaMotivosCin").css({"display":"none"});
	$("#frmMotivoCin").css({"display":"none"});
	$("#divBotoes").css({"display":"none"});
	$("#btConcluir","#divBotoes").hide();
	
	//Validar a op��o selecionada na tela
	if(cddopcao.val() == "CM") {
		// executa a consulta, listando as motivos CIN cadastrados
		executaConsultaMotivosCin();
	} else {
		$("#frmMotivoCin").css({"display":"block"});
		$("#divBotoes").css({"display":"block"});
		$("#btConcluir","#divBotoes").show();
		
		$("#cdmotivocin","#frmMotivoCin").habilitaCampo().focus();
		if(cddopcao.val() == "IM"){
			// Quando for inclus�o desabilita o c�digo para que seja possivel informar apenas o motivo CIN
			$("#cdmotivocin","#frmMotivoCin").desabilitaCampo();
			$("#dsmotivocin","#frmMotivoCin").focus();
		}
		
		// Verificar a op��o para exibir a lupa de pesquisa
		if(cddopcao.val() == "AM"){
			$("#pesqmotcin").css({"display":"block"});
		} else {
			$("#pesqmotcin").css({"display":"none"});
		}
	}
}

// Fun��o para o bot�o voltar
function controlaVoltarMotivoCin(){
	if (flgVoltarGeral == 1) {
		// Quando n�o for executado nada na tela de motivos CIN, retorna para a tela principal
		estadoInicial();
	} else {
		// Quando ocorrer alguma a��o na tela de motivo CIN, retorna para o estado inicial da tela de motivos CIN
		estadoInicialMotivosCin();
	}
}

// Fun��o para o bot�o Concluir
function controlaConcluirMotivoCin(){
	//Valida��o do campo c�digo para quando a op��o n�o for incluir
	if($("#cddopcao_motivo_cin","#frmCabMotivoCin").val() != "IM" && $("#cdmotivocin","#frmMotivoCin").val() == "") {
		showError('error','C&oacute;digo inv&aacute;lido!','Campo obrigat&oacute;rio','$("#cdmotivocin","#frmMotivoCin").focus();');
		return false;
	}
	
	//Valida��o da descri��o informada
	if($("#dsmotivocin","#frmMotivoCin").val() == "") {
		showError('error','Motivo CIN inv&aacute;lido!','Campo obrigat&oacute;rio','$("#dsmotivocin","#frmMotivoCin").focus();');
		return false;
	}
	
	//Verifica a op��o
	if($("#cddopcao_motivo_cin","#frmCabMotivoCin").val() == "AM") {
		//Quando for altera��o, solicita confirma��o
		showConfirmacao('Confirma a altera&ccedil;&atilde;o do motivo CIN?','Confirma&ccedil;&atilde;o - Ayllos','confirmouOperacaoMotivoCin();','','sim.gif','nao.gif');
	} else {
		//Se n�o est� alterando executa a a��o
		confirmouOperacaoMotivoCin();
	}
}

function confirmouOperacaoMotivoCin(){
	//Recupera a op��o
	var cddopcao     = $("#cddopcao_motivo_cin","#frmCabMotivoCin").val();
	var mensagem = "Aguarde ...";
	
	//Atualiza a mensagem que ser� exibida
	if(cddopcao == "IM") {
		mensagem = "Aguarde, incluindo motivo CIN ...";
	} else {
		mensagem = "Aguarde, alterando motivo CIN ...";
	}
	//mostra mensagem e finaliza a opera��o
	showMsgAguardo( mensagem );	
	
	var dsmotivo = $("#dsmotivocin","#frmMotivoCin").val()
                                                    .replace(/[������]/g,"A")
									   			    .replace(/[������]/g,"a")
										     		.replace(/[������]/g,"O")
												    .replace(/[������]/g,"o")
												    .replace(/[����]/g,"E")
												    .replace(/[����]/g,"e")
												    .replace(/[�]/g,"C")
												    .replace(/[�]/g,"c")
												    .replace(/[����]/g,"I")
												    .replace(/[����]/g,"i")
												    .replace(/[����]/g,"U")
												    .replace(/[����]/g,"u")
												    .replace(/[�]/g,"y")
												    .replace(/[�]/g,"N")
												    .replace(/[�]/g,"n")
												    .replace(/[^A-z0-9\s\!\@\$\%\*\(\)\-\_\=\+\[\]\{\}\?\;\:\.\,\/\>\<]/g,"");
	
	manterMotivoCin(cddopcao,$("#cdmotivocin","#frmMotivoCin").val(),dsmotivo);
}


// Fun��o para executar a busca de todas os motivos CIN
function executaConsultaMotivosCin(){
	//Mostrar a consulta e bot�es
	$("#divConsultaMotivosCin").css({"display":"block"});
	$("#divBotoes").css({"display":"block"});
	//Esconder o bot�o de concluir, pois na consulta exibe apenas a op��o de voltar
	$("#btConcluir","#divBotoes").hide();
	//Limpar a tabela
	$("#tbCadcmt > tbody").html("");
	//Iniciar a busca dos motivos CIN
	showMsgAguardo( "Aguarde, carregando motivos CIN ..." );	
	manterMotivoCin("CM","","");	
}

//Fun��o para criar a linha com os motivos CIN cadastrados
function criaLinhaMotivoCin(cdmotivo,dsmotivo){
	// Criar a linha na tabela
	$("#tbCadcmt > tbody")
		.append($('<tr>') // Linha
			.attr('id',"id_".concat(cdmotivo))
			.append($('<td>') // Coluna: C�digo do Motivo
				.attr('style','width: 80px; text-align:right')
				.text(cdmotivo)
			)
			.append($('<td>') // Coluna: Motivo CIN
				.attr('style','text-align:left')
				.text(dsmotivo)
			)
			.append($('<td>') // Coluna: Bot�o para REMOVER
				.attr('style','width: 80px; text-align:center')
				.append($('<img onclick="solicitarMensagemExclusaoMotivoCin(' + cdmotivo + ')">')
					.attr('src', UrlImagens + 'geral/panel-delete_16x16.gif')
				)
			)
		);
}

// Fun��o para solicitar confirma��o da exclus�o do motivo CIN
function solicitarMensagemExclusaoMotivoCin(cdmotivo){
	showConfirmacao('Confirma a exclus&atilde;o do motivo CIN?','Confirma&ccedil;&atilde;o - Ayllos','excluirMotivoCin(' + cdmotivo + ');','','sim.gif','nao.gif');	
}

//Fun��o para realizar a requisi��o de exclus�o do motivo CIN
function excluirMotivoCin(cdmotivo){
	if(cdmotivo == "" ) {
		showError('error','Motivo CIN inv&aacute;lida!','Alerta - Ayllos','');
		return false;
	}
	//Exibe mensagem e solicita a exclus�o
	showMsgAguardo( "Aguarde, excluindo motivo CIN ..." );	
	manterMotivoCin("EM",cdmotivo,"");
}

//Fun��o para manter rotina (Consultar/Incluir/Alterar/Excluir)
function manterMotivoCin(cddopcao,cdmotivo,dsmotivo){
    //Requisi��o para processar a op��o que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/parcyb/manter_rotina_motivo_cin.php",
        data: {
            cddopcao:    cddopcao,
			cdmotivocin: cdmotivo,
			dsmotivocin: dsmotivo,
            redirect:    "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function(response) {
            hideMsgAguardo();
			eval(response);
        }
    });
    return false;	
}

//Fun��o executada quando sair do campo de c�digo de motivo CIN na op��o Alterar
function buscaMotivoCin(){
	var cdmotivo = $("#cdmotivocin").val();
	//Valida o c�digo do motivo CIN
	if(cdmotivo != "") {
		//Busca as informa�oes do c�digo informado
		manterMotivoCin("CM",cdmotivo,"");		
	}
}

// Fun��o para abrir a pesquisa de motivos CIN
function mostrarPesquisaMotivoCin(){
	//Defini��o dos filtros
	var filtros	= "C�digo;cdmotivocin;50px;N;;N;|Motivo CIN;dsmotivocin;200px;S;;S;descricao";
	//Campos que ser�o exibidos na tela
	var colunas = 'C�digo;cdmotivo;20%;right|Motivo CIN;dsmotivo;80%;left';			
	//Exibir a pesquisa
	mostraPesquisa("PARCYB", "PARCYB_BUSCAR_MOTIVOS_CIN", "Motivos CIN","100",filtros,colunas);
}

/***********************************************************************************************************
									FIM -> Fun��es para a tela de Motivos CIN
***********************************************************************************************************/

/***********************************************************************************************************
									IN�CIO -> Fun��es para a tela de Parametriza��o de Hist�ricos
***********************************************************************************************************/

// Fun��o para o estado inicial da tela de Parametriza��o de Hist�ricos
function estadoInicialParametrizarHistorico(){
	//No estado inicial da tela de  Parametriza��o de Hist�ricos, retorna para a principal
	flgVoltarGeral = 1;
	
	hideMsgAguardo();
	
	removeOpacidade("divTela");
	
	// Mostrar a tela de Parametriza��o de Hist�ricos
	$("#divTelaParametrizarHistorico").css({"display":"block"});
	
	highlightObjFocus( $("#frmCabParametrizarHistorico","#divTelaParametrizarHistorico") ); 
	
	//Esconde a consulta e limpa a tabela
	$("#divConsultaParametrizarHistorico","#divTelaParametrizarHistorico").css({"display":"none"});
	$("#divFiltrosParametrizarHistorico","#divTelaParametrizarHistorico").css({"display":"none"});
	$("#tbParhis > tbody").html("");
	
	//Esconde cadastro e os bot�es
	$("#frmCabParametrizarHistorico","#divTelaParametrizarHistorico").css({"display":"none"});
	$("#divBotoes").css({"display":"block"});
	
	//Exibe cabe�alho e define tamanho da tela
	$("#frmCabParametrizarHistorico","#divTelaParametrizarHistorico").css({"display":"block"});
	
	//Limpa os campos do formul�rio e remove o erro dos campos
	$('input[type="text"],select','#frmCabParametrizarHistorico').limpaFormulario().removeClass('campoErro');
	//Foca o campo da Op��o
	$("#cddopcao_parametrizar_historico","#frmCabParametrizarHistorico").habilitaCampo().val("CH").focus();
	//Esconde o bot�o de concluir
	$("#btConcluir","#divBotoes").hide();
}

// Fun��o para formatar a tela de Parametriza��o de Hist�ricos
function formataTelaParametrizarHistorico(){
	//Formata��o do cabe�alho e formul�rio
	formataCabecalhoParametrizarHistorico();
	formataFiltrosParametrizarHistorico();
}

// Formata o Cabe�alho da tela de Parametriza��o de Hist�ricos
function formataCabecalhoParametrizarHistorico() {
	// rotulo
	$('label[for="cddopcao_parametrizar_historico"]',"#frmCabParametrizarHistorico").addClass("rotulo").css({"width":"100px"}); 
	
	// campo
	$("#cddopcao_parametrizar_historico","#frmCabParametrizarHistorico").css("width","500px").habilitaCampo();
	$('input[type="text"],select','#frmCabParametrizarHistorico').limpaFormulario().removeClass('campoErro');
	layoutPadrao();
	
	//Define a��o para ENTER e TAB no campo Op��o
	$("#cddopcao_parametrizar_historico","#frmCabParametrizarHistorico").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			//Executa fun��o do bot�o OK
			liberaAcaoParametrizarHistorico();
			return false;
		}
    });	

	//Define a��o para CLICK no bot�o de OK da tela de Parametriza��o de Hist�ricos
	$("#btnOkParametrizarHistorico","#frmCabParametrizarHistorico").unbind('click').bind('click', function(e) {
		//Executa fun��o do bot�o OK
		liberaAcaoParametrizarHistorico();
		return false;
    });	
	
	return false;	
}

// Fun��o para formatar os campos de filtro utilizados na tela de Parametriza��o de Hist�ricos
function formataFiltrosParametrizarHistorico(){
	// Campos de Pesquisa do hist�rico por c�digo e descri��o
	// rotulo
	$('label[for="cdhistor"]',"#frmFiltrosParametrizarHistorico").addClass("rotulo").css({"width":"100px"}); 
	$('label[for="dshistor"]',"#frmFiltrosParametrizarHistorico").addClass("rotulo-linha").css({"width":"100px"}); 
	// campo
	$("#cdhistor","#frmFiltrosParametrizarHistorico").css("width","50px").habilitaCampo();
	$("#dshistor","#frmFiltrosParametrizarHistorico").css("width","200px").habilitaCampo();
	
	
	// Campos de Pesquisa do hist�rico por FILTRO
	//rotulo
	$('label[for="rdfiltro1"]',"#frmFiltrosParametrizarHistorico").addClass("rotulo-linha").css({"width":"150px","text-align":"left"}); 
	$('label[for="rdfiltro2"]',"#frmFiltrosParametrizarHistorico").addClass("rotulo-linha").css({"width":"150px","text-align":"left"}); 
	$('label[for="rdfiltro3"]',"#frmFiltrosParametrizarHistorico").addClass("rotulo-linha").css({"width":"150px","text-align":"left"}); 
	//campos
	$("#rdfiltro1","#frmFiltrosParametrizarHistorico").css("width","10px").habilitaCampo();
	$("#rdfiltro2","#frmFiltrosParametrizarHistorico").css("width","10px").habilitaCampo();
	$("#rdfiltro3","#frmFiltrosParametrizarHistorico").css("width","10px").habilitaCampo();
	
	$('input[type="text"]','#frmFiltrosParametrizarHistorico').limpaFormulario().removeClass('campoErro');
	layoutPadrao();
	
	//Define a��o para CLICK no bot�o de Pesquisar da tela de Parametriza��o de Hist�ricos
	$("#btnPesquisarHistorico","#frmFiltrosParametrizarHistorico").unbind('click').bind('click', function(e) {
		//Executa fun��o do bot�o Pesquisar
		pesquisarHistorico();
		return false;
    });	
	
	//Define a��o para CLICK no bot�o de Filtrar da tela de Parametriza��o de Hist�ricos
	$("#btnFiltrarHistorico","#frmFiltrosParametrizarHistorico").unbind('click').bind('click', function(e) {
		//Executa fun��o do bot�o Pesquisar
		filtrarHistorico();
		return false;
    });	
	
	return false;	
}

function formataConsultaParametrizarHistorico(){
	// Tabela
	$("#divConteudo","#divConsultaParametrizarHistorico").css({"display":"block"});

    var divRegistro = $("div.divRegistros", "#tabParhis");
	var tabela      = $("table", divRegistro );
	var linha       = $("table > tbody > tr", divRegistro );

    $("#tabParhis").css({"margin-top":"5px"});
	divRegistro.css({"height":"290px","width":"700px","padding-bottom":"2px"});

	var ordemInicial = new Array();
	
	//Define a largura dos campos
	var arrayLargura = new Array();
    arrayLargura[0] = "70px";
    arrayLargura[1] = "";
    arrayLargura[2] = "80px";
    arrayLargura[3] = "140px";
    arrayLargura[4] = "140px";
    
	//Define a posi��o dos elementos nas c�lulas da linha
    var arrayAlinha = new Array();
	arrayAlinha[0] = "left";
	arrayAlinha[1] = "left";
	arrayAlinha[2] = "left";
	arrayAlinha[3] = "center";
	arrayAlinha[4] = "center";

	//Aplica as informa��es na tabela
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);
	return false;
}

// Fun��o para liberar as informa��es da tela de Parametriza��o de Hist�ricos
function liberaAcaoParametrizarHistorico(){
	var cddopcao = $("#cddopcao_parametrizar_historico","#frmCabParametrizarHistorico");
	cddopcao.desabilitaCampo();
	//Quando executar a tela de Parametriza��o de Hist�ricos, retorna para a tela de Parametriza��o de Hist�ricos
	flgVoltarGeral = 0;

	// Esconder o bot�o de Concluir
	$("#btConcluir","#divBotoes").hide();

	//Mostra as op��es da tela
	$("#divConsultaParametrizarHistorico","#divTelaParametrizarHistorico").css({"display":"block"});
	$("#divFiltrosParametrizarHistorico","#divTelaParametrizarHistorico").css({"display":"block"});
	$("#frmFiltrosParametrizarHistorico","#divTelaParametrizarHistorico").css({"display":"block"});
	
	$("#tdPesquisarHistorico","#frmFiltrosParametrizarHistorico").hide();
	$("#tdFiltrarHistorico","#frmFiltrosParametrizarHistorico").hide();
	
	if(cddopcao.val() == "CH") {
		// Exibe os campos de Filtro
		$("#tdFiltrarHistorico","#frmFiltrosParametrizarHistorico").show();
		$("#rdfiltro3","#frmFiltrosParametrizarHistorico").attr("checked","checked").focus();
	} else {
		// Exibe os campos de C�digo e descri��o
		$("#tdPesquisarHistorico","#frmFiltrosParametrizarHistorico").show();
		$("#cdhistor","#frmFiltrosParametrizarHistorico").val("").focus();
		$("#dshistor","#frmFiltrosParametrizarHistorico").val("");
		$("#btConcluir","#divBotoes").show();
	}
}

// Fun��o para o bot�o voltar
function controlaVoltarParametrizarHistorico(){
	if (flgVoltarGeral == 1) {
		// Quando n�o for executado nada na tela de parametriza��o de hist�rico, retorna para a tela principal
		estadoInicial();
	} else {
		// Quando ocorrer alguma a��o na tela de parametriza��o de hist�rico, retorna para o estado inicial da tela de parametriza��o de hist�rico
		estadoInicialParametrizarHistorico();
	}
}

// Fun��o para o bot�o Concluir
function controlaConcluirParametrizarHistorico(){
	var historicos = "";
	
	$('#tbParhis tbody tr').each(function(){

		var indcalem_ant = $("#indcalem_h",this).val();
		var indcalcc_ant = $("#indcalcc_h",this).val();
		var indcalem_atu = ($("#indcalem_a",this).prop("checked")) ? "S" : "N";
		var indcalcc_atu = ($("#indcalcc_a",this).prop("checked")) ? "S" : "N";
	
		if ( indcalem_ant != indcalem_atu || indcalcc_ant != indcalcc_atu) {
			if( historicos != "" ){
				// Separador dos hist�ricos
				historicos += "|";
			}
			historicos += $("#cdhistor_h",this).val() + ";" ; // C�digo do Hist�rico
			historicos += indcalem_atu  + ";" ;               // C�lculo de Empr�stimo
			historicos += indcalcc_atu;                       // C�lculo de Conta Corrente
		}
	});

	if(historicos == ""){
		showError("error","Nenhum historico foi alterado.","Alerta - Ayllos","");
		return false;
	}
	
	//Mensagem de altera��o de Parametriza��o
	showMsgAguardo( "Aguarde, atualizando parametriza&ccedil;&atilde;o dos hist&oacute;ricos..." );	
	
	manterParametrizacaoHistorico("AH","","","","",historicos);
}

// Fun��o para pesquisar os hist�ricos por c�digo/descri��o
function pesquisarHistorico(){
	var opcao = "T"; // Padr�o da pesquisa � todos
	var cdhistor = $("#cdhistor","#frmFiltrosParametrizarHistorico").val();
	var dshistor = $("#dshistor","#frmFiltrosParametrizarHistorico").val();
	var cdfiltro = "";
	
	if(cdhistor != "" && dshistor != ""){
		showError("error","Informe apenas um campo para pesquisar.","Alerta - Ayllos","");
		return false;
	}
	
	if (cdhistor != ""){
		opcao = "C"; // Se possuir c�digo informado a op��o de pesquisa � "C"
	}
	
	if (dshistor != ""){
		opcao = "D"; // Se possuir descri��o informada a op��o de pesquisa � "D"
	}
	
	executaPesquisaParametrizacaoHistorico("CH",opcao,cdfiltro,cdhistor,dshistor);
}

// Fun��o para pesquisar os hist�ricos por filtro
function filtrarHistorico(){
	var opcao = "F"; // Quando for pesquisa por filtro, sempre utilizar a op��o "F"
	var rdfiltro1 = $("#rdfiltro1","#frmFiltrosParametrizarHistorico").prop("checked");
	var rdfiltro2 = $("#rdfiltro2","#frmFiltrosParametrizarHistorico").prop("checked");
	var rdfiltro3 = $("#rdfiltro3","#frmFiltrosParametrizarHistorico").prop("checked");

	var cdfiltro = (rdfiltro1) ? 1 : ((rdfiltro2) ? 2 : ((rdfiltro3) ? 3 : 0));
	var cdhistor = "";
	var dshistor = "";
	
	if(cdfiltro == 0){
		showError("error","Selecione o filtro.","Alerta - Ayllos","");
		return false;
	}
	
	executaPesquisaParametrizacaoHistorico("CH",opcao,cdfiltro,cdhistor,dshistor);
}

function executaPesquisaParametrizacaoHistorico(cddopcao,pesquisa,cdfiltro,cdhistor,dshistor){
	//Limpar a tabela
	$("#tbParhis > tbody").html("");
	//Iniciar a busca das assessorias
	showMsgAguardo( "Aguarde, carregando parametriza&ccedil;&atilde;o de hist&oacute;rico..." );	
	manterParametrizacaoHistorico(cddopcao,pesquisa,cdfiltro,cdhistor,dshistor,"");
}

// Fun��o para manter rotina (Consultar/Alterar)
function manterParametrizacaoHistorico(cddopcao,pesquisa,cdfiltro,cdhistor,dshistor,historicos){
	//Requisi��o para processar a op��o que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/parcyb/manter_rotina_parametrizar_historico.php",
        data: {
            cddopcao: cddopcao,
			pesquisa: pesquisa,
			cdfiltro: cdfiltro,
			cdhistor: cdhistor,
			dshistor: dshistor,
			historicos: historicos,
            redirect: "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function(response) {
            hideMsgAguardo();
			try {
				eval(response);
			} catch (error) {
					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
				}
			}
    });
    return false;	
}

function criaLinhaParametrizarHistorico(cdhistor,dshistor,indebcre,indcalem,indcalcc){
	
	var field_indcalem = $('<input>', { type:"checkbox", name: "indcalem_a", id: "indcalem_a"});
	var field_indcalcc = $('<input>', { type:"checkbox", name: "indcalcc_a", id: "indcalcc_a"});
	if($("#cddopcao_parametrizar_historico","#frmCabParametrizarHistorico").val() == "CH"){
		field_indcalem.attr("disabled","disabled");
		field_indcalcc.attr("disabled","disabled");
	}
	
	if(indcalem == "S"){
		field_indcalem.attr("checked","checked");
	}
	
	if(indcalcc == "S"){
		field_indcalcc.attr("checked","checked");
	}
	
	// Criar a linha na tabela
	$("#tbParhis > tbody")
		.append($("<tr>") // Linha
			.attr("id","id_".concat(cdhistor))
			.append($("<td>") // Coluna: C�digo do Hist�rico
				.attr("style","width: 70px; text-align:left")
				.text(cdhistor)
				.append($("<input>")
					.attr("type","hidden")
					.attr("name","cdhistor_h")
					.attr("id","cdhistor_h")
					.attr("value",cdhistor)
				)
			)
			.append($("<td>") // Coluna: Descri��o do Hist�rico
				.attr("style","text-align:left")
				.text(dshistor)
			)
			.append($("<td>") // Coluna: Indicador de D�bito e Cr�dito do Hist�rico
				.attr("style","width: 80px; text-align:left")
				.text(indebcre)
			)
			.append($("<td>") // Coluna: C�lculo do Empr�stimo
				.attr("style","width: 140px; text-align:center")
				.append(field_indcalem)
				.append($("<input>")
					.attr("type","hidden")
					.attr("name","indcalem_h")
					.attr("id","indcalem_h")
					.attr("value",indcalem)
				)
			)
			.append($("<td>") // Coluna: C�lculo de Conta Corrente
				.attr("style","width: 140px; text-align:center")
				.append(field_indcalcc)
				.append($("<input>")
					.attr("type","hidden")
					.attr("name","indcalcc_h")
					.attr("id","indcalcc_h")
					.attr("value",indcalcc)
				)
			)
		);
}
/***********************************************************************************************************
									FIM -> Fun��es para a tela de Parametriza��o de Hist�ricos
***********************************************************************************************************/
/*!
 * FONTE        : orifol.js
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Maio/2015
 * OBJETIVO     : Biblioteca de funções da tela ORIFOL
 * --------------
 * ALTERAÇÕES   : 04/12/2015 - Removendo busca dos dados ao fechar janela
                               de Alteracao/Inclusao. (Andre Santos - SUPERO)
 * -----------------------------------------------------------------------
 */

// Variaveis
var rCdoriflh,rDsoriflh,rIdvarmes,rCdhisdeb,rCdhsdbcp,rCdhiscre,rCdhscrcp,rFldebemp,
	cCdoriflh,cDsoriflh,cIdvarmes,cCdhisdeb,cCdhsdbcp,cCdhiscre,cCdhscrcp,cFldebfol;

var cTodosCabecalho;

var indrowid = "";
var regCdorigem = "";
var regDsorigem = "";
var regCdhisdeb = "";
var regCdhiscre = "";
var regCdhsdbcp = "";
var regCdhscrcp = "";
var regIdvarmes = "";
var regFldebfol = "";

// Tela
$(document).ready(function() {
	estadoInicial();
});

function estadoInicial() {

	// Efeito de inicializacao
	$('#divTela').fadeTo(0,0.1);

	controlaLayout();

	// Remove Opacidade da Tela
    removeOpacidade('divTela');

	buscaPagamento();
	return false;
}

// Monta a tela Principal
function controlaLayout() {
	// Habilta
	$('#frmCab').css({'display':'block'});
	$('#divBotoes').css({'display':'block'});

	indrowid = "";

	layoutPadrao();
	return false;
}

/* Acessar tela principal da rotina */
function acessaOpcaoAba() {

	/* Monta o conteudo atraves dos botoes de incluir/alterar */

	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/orifol/form_dados.php",
		data: {
			indrowid     : indrowid,
			regCdorigem  : regCdorigem,
			regDsorigem  : regDsorigem,
			regIdvarmes  : regIdvarmes,
			regCdhisdeb  : regCdhisdeb,
			regCdhiscre  : regCdhiscre,
			regCdhsdbcp  : regCdhsdbcp,
			regCdhscrcp  : regCdhscrcp,
			regFldebfol  : regFldebfol,
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')) )");
		},
		success: function(response) {
			$("#divConteudoOpcao").html(response);
			atualizaSeletor();
		}
	});
	return false;
}

// Cabecalho Principal
function atualizaSeletor() {

	/** Formulario Dados **/
	rCdoriflh	    	= $('label[for="cdoriflh"]','#frmDados');
	rDsoriflh	    	= $('label[for="dsoriflh"]','#frmDados');
	rIdvarmes	    	= $('label[for="idvarmes"]','#frmDados');

	rCdhisdeb	    	= $('label[for="cdhisdeb"]','#frmDados');
	rCdhsdbcp	    	= $('label[for="cdhsdbcp"]','#frmDados');
	rCdhiscre	    	= $('label[for="cdhiscre"]','#frmDados');
	rCdhscrcp	    	= $('label[for="cdhscrcp"]','#frmDados');

	rFldebemp	    	= $('label[for="fldebfol"]','#frmDados');

	cCdoriflh           = $('#cdoriflh','#frmDados');
	cDsoriflh           = $('#dsoriflh','#frmDados');
	cIdvarmes           = $('#idvarmes','#frmDados');

	cCdhisdeb           = $('#cdhisdeb','#frmDados');
	cCdhsdbcp           = $('#cdhsdbcp','#frmDados');
	cCdhiscre           = $('#cdhiscre','#frmDados');
	cCdhscrcp           = $('#cdhscrcp','#frmDados');

	cFldebfol           = $('#fldebfol','#frmDados');

	cTodosCabDados	    = $('input[type="text"],select,textArea','#frmDados');

	formataCabecalho();
	navegaCampos();
	return false;
}

// Formatacao da Tela
function formataCabecalho() {

	/** Formulario Dados **/
	rCdoriflh.css({'width':'180px'});
	rDsoriflh.css({'width':'180px'});
	rIdvarmes.css({'width':'180px'});

	rCdhisdeb.css({'width':'80px'});
	rCdhsdbcp.css({'width':'100px'});
	rCdhiscre.css({'width':'80px'});
	rCdhscrcp.css({'width':'100px'});

	rFldebemp.css({'width':'180px'});

	cCdoriflh.addClass('campo').css({'width':'50px'}).attr('maxlength','2');
	cDsoriflh.addClass('campo').css({'width':'222px'}).attr('maxlength','30');
	cIdvarmes.addClass('campo').css({'width':'150px'});

	cCdhisdeb.addClass('campo').css({'width':'100px'}).setMask('INTEGER','zzzzz','','');
	cCdhsdbcp.addClass('campo').css({'width':'100px'}).setMask('INTEGER','zzzzz','','');
	cCdhiscre.addClass('campo').css({'width':'100px'}).setMask('INTEGER','zzzzz','','');
	cCdhscrcp.addClass('campo').css({'width':'100px'}).setMask('INTEGER','zzzzz','','');

	cFldebfol.addClass('campo').css({'width':'100px'});

	highlightObjFocus( $('#frmDados') );
	return false;
}

function navegaCampos() {

	cCdoriflh.focus();	
	cCdoriflh.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cDsoriflh.focus();
			return false;
		}
	});
	cCdoriflh.unbind('blur').bind('blur', function(e) {
		replaceAll(cCdoriflh.val(),this);
	});
	cDsoriflh.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cIdvarmes.focus();
			return false;
		}
	});
	cDsoriflh.unbind('blur').bind('blur', function(e) {
		replaceAll(cDsoriflh.val(),this);
	});
	cIdvarmes.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cFldebfol.focus();
			return false;
		}
	});
	cFldebfol.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cCdhisdeb.focus();
			return false;
		}
	});
	cCdhisdeb.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cCdhsdbcp.focus();
			return false;
		}
	});
	cCdhsdbcp.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cCdhiscre.focus();
			return false;
		}
	});
	cCdhiscre.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cCdhscrcp.focus();
			return false;
		}
	});
	cCdhscrcp.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			gravarPagamento();
			return false;
		}
	});
	return false;
}




// Botoes
function btnIncluir() {
	mostrarTela("I");
	return false;
}

function btnAlterar() {
	mostrarTela("A");
	return false;
}

function btnExcluir() {
	if (indrowid === undefined) {return false;}

	showConfirmacao("Voc&ecirc; tem certeza que deseja excluir esta Origem?","Confirma&ccedil;&atilde;o - Ayllos","excluirPagamento();","","sim.gif","nao.gif");
	return false;
}




// Monta Grid Inicial
function buscaPagamento() {

	indrowid = "";

	$.ajax({
		type	: "POST",
		dataType: "html",
		url		: UrlSite + "telas/orifol/busca_pagamentos.php",
		data: {
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function(response) {
			$("#divCab").html(response);
			formataTabela();
		}
	});
	return false;
}

// Formata tabela de dados da remessa
function formataTabela() {

	// Habilita a conteudo da tabela
    $('#divCab').css({'display':'block'});

    var divRegistro = $('div.divRegistros', '#tabPagamento');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
	var conteudo	= $('#conteudo', linha).val();

    $('#tabPagamento').css({'margin-top':'1px'});
	divRegistro.css({'height':'300px','padding-bottom':'1px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0]  = '50px';
	arrayLargura[1]  = '350px';
	arrayLargura[2]  = '70px';
	arrayLargura[3]  = '70px';
	arrayLargura[4]  = '70px';
	arrayLargura[5]  = '70px';
	arrayLargura[6]  = '120px';
	arrayLargura[7]  = '100px';
	arrayLargura[8]  = '16px';

	var arrayAlinha = new Array();
		arrayAlinha[0] = 'center';
        arrayAlinha[1] = 'left';
        arrayAlinha[2] = 'center';
        arrayAlinha[3] = 'center';
        arrayAlinha[4] = 'center';
        arrayAlinha[5] = 'center';
        arrayAlinha[6] = 'center';
        arrayAlinha[7] = 'center';

	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	hideMsgAguardo();

	/* Atribuindo o foco para a linha da tabela, pois ao clicar no cabecalho nao retornava
	para linha da tabela, dessa maneira a tela apresentava erro na hora de alterar ou
	excluir o registro selecionado */

	$('table > thead > tr > th', divRegistro).unbind('click').bind('click', function() {
		$('table > tbody > tr > td', divRegistro).focus();
	});

	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		selecionaTabela($(this));
	});

	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).dblclick( function() {
		selecionaTabela($(this));
		btnAlterar();
	});

    // seleciona o registro que é focado
	$('table > tbody > tr', divRegistro).focus( function() {
		selecionaTabela($(this));
	});

	$('table > tbody > tr:eq(0)', divRegistro).click();
	return false;
}

function selecionaTabela(tr) {
    indrowid = $('#indrowid', tr).val();
    regCdorigem = $('#cdorigem', tr).val();
    regDsorigem = $('#dsorigem', tr).val();
    regIdvarmes = $('#idvarmes', tr).val();
    regCdhisdeb = $('#cdhisdeb', tr).val();
    regCdhiscre = $('#cdhiscre', tr).val();
    regCdhsdbcp = $('#cdhsdbcp', tr).val();
    regCdhscrcp = $('#cdhscrcp', tr).val();
    regFldebfol = $('#fldebfol', tr).val();
	return false;
}

function mostrarTela(opcao) {

	/* Contola opcao da tela */
	if (opcao == "A"){ // Alterar Registro

		/** Utiliza as variavies globais com o registro
		selecionado para poder altera-lo.

		Nesse caso eh passado o rowid do registro
		para alteracao **/

		if (indrowid === undefined) {return false;}

	}else
	if	(opcao == "I")	{	// Incluir Registro

		/** Limpa as variaveis de campo selecionado
        para incluir um novo registro */

		indrowid = "";
		regCdorigem = "";
		regDsorigem = "";
		regIdvarmes = "";
		regCdhisdeb = "";
		regCdhiscre = "";
		regCdhsdbcp = "";
		regCdhscrcp = "";
		regFldebfol = "";

	}

	/* Abre nova tela para inclusao/edicao de pagamento */

	$.ajax({
		type	: "POST",
		dataType: "html",
		url		: UrlSite + "telas/orifol/cadastro_pagamento.php",
		data: {
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')) )");
		},
		success: function(response) {
			 mostraRotina();
			$("#divRotina").html(response);
		}
	});
	return false;
}

// Função para visualizar div da rotina
function mostraRotina() {
	$("#divRotina").css("visibility","visible");
	$("#divRotina").centralizaRotinaH();
}

// Função para esconder div da rotina e carregar dados da conta novamente
function encerraRotina(flgCabec) {
	$("#divRotina").css({"width":"545px","visibility":"hidden"});
	$("#divRotina").html("");

	// Esconde div de bloqueio
	unblockBackground();
	return false;
}




function gravarPagamento(){

	var rowid    = $('#indrowid','#frmDados').val();
	var cdoriflh = cCdoriflh.val();
	var dsoriflh = cDsoriflh.val();
	var idvarmes = cIdvarmes.val();
	var cdhisdeb = cCdhisdeb.val();
	var cdhsdbcp = cCdhsdbcp.val();
	var cdhiscre = cCdhiscre.val();
	var cdhscrcp = cCdhscrcp.val();
	var fldebfol = cFldebfol.val();

	// Verificando qual tipo de gravacao
	if (rowid == ""){
		var descricao = "inserida";
	}else{
		var descricao = "atualizada";
	}

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, " + descricao + " dados...");

	$.ajax({
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/orifol/gravar_dados.php",
		data: {
			rowid    : rowid,
			cdoriflh : cdoriflh,
			dsoriflh : dsoriflh,
			idvarmes : idvarmes,
			cdhisdeb : cdhisdeb,
			cdhsdbcp : cdhsdbcp,
			cdhiscre : cdhiscre,
			cdhscrcp : cdhscrcp,
			fldebfol : fldebfol,
			redirect : "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			cTodosCabDados.removeClass('campoErro');
			hideMsgAguardo();
			try {
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						showError("inform","Origem " + descricao + " com sucesso!","Alerta - Ayllos","encerraRotina(true);buscaPagamento();");
					} catch(error) {
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')))");
					}
				} else {
					try {
						eval(response);
					} catch(error) {
						hideMsgAguardo();
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')))");
					}
				}
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}
	});

	return false;
}

function excluirPagamento(){

	var rowid    = indrowid;

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, excluindo conv&ecirc;nio...");

	$.ajax({
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/orifol/excluir_dados.php",
		data: {
			rowid    : rowid,
			redirect : "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			hideMsgAguardo();
			try {
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						showError("inform","Origem exclu&iacute;da com sucesso!","Alerta - Ayllos","buscaPagamento();");
					} catch(error) {
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')))");
					}
				} else {
					try {
						eval(response);
					} catch(error) {
						hideMsgAguardo();
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')))");
					}
				}
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}
	});

	return false;
}

function replaceAll(texto,obj){

	/**
		Objetivo: Remover todos os caracter especiais
				  para evitar problemas na gravacao do
				  registro

		Parametros : texto --> Texto que sera analisado
		               obj --> Objeto referenciado para receber o texto ajustado

	**/

	// Lista todos os caracter especiais que serao substituidos
	var caracteresInvalidos = 'àèìòùâêîôûäëïöüáéíóúãõçÀÈÌÒÙÂÊÎÔÛÄËÏÖÜÁÉÍÓÚÃÕÇ<>;`´^~ªº¨§';
	// Lista todos os caracter que sera exibido
	var caracteresValidos =   'aeiouaeiouaeiouaeiouaocAEIOUAEIOUAEIOUAEIOUAOC';

	// Variaveis de controle
	var caracter = '';
	var letra = '';

	// Verifica todas as posicoes e troca todos os caracter invalidos
	for (i = 0; i < texto.length; i++) {
		if (caracteresInvalidos.indexOf(texto.charAt(i)) == -1){
			caracter = caracter+texto.charAt(i);
		}else{
			letra = caracteresValidos.charAt(caracteresInvalidos.indexOf(texto.charAt(i)));
			caracter=caracter+letra;
		}
	}

	// Recebe o texto convertido
	obj.value = caracter;
}
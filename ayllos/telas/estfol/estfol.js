/*!
 * FONTE        : estfol.js
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Maio/2015
 * OBJETIVO     : Biblioteca de funções da tela ESTFOL
 * --------------
 * ALTERAÇÕES   :
 * -----------------------------------------------------------------------
 */

// Variaveis
var rDsjustif,rDsmsgeml,
	cDsjustif,cDsmsgeml;

var cTodosCabecalho;

var cdempres;
var dtsolest;
var cdeftpag;
var dsjustif;
var vlestour;

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

	buscaEstourosFolha();
	return false;
}

// Monta a tela Principal
function controlaLayout() {
	// Habilta
	$('#frmCab').css({'display':'block'});
	$('#divBotoes').css({'display':'block'});

	cdempres = "";
	dtsolest = "";

	layoutPadrao();
	return false;
}

/* Acessar tela principal da rotina */
function acessaOpcaoAba() {

	/* Monta o conteudo atraves dos botoes de incluir/alterar */

	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/estfol/form_dados.php",
		data: {
			cdempres     : cdempres,
			dtsolest     : dtsolest,
			vlestour     : vlestour,
			cdeftpag     : cdeftpag,
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

	rDsjustif	    	= $('label[for="dsjustif"]','#frmDados');
	rDsmsgeml	    	= $('label[for="dsmsgeml"]','#frmDados');

	cDsjustif           = $('#dsjustif','#frmDados');
	cDsmsgeml           = $('#dsmsgeml','#frmDados');

	cTodosCabDados	    = $('input[type="text"],select,textArea','#frmDados');

	formataCabecalho();
	navegaCampos();
	return false;
}

// Formatacao da Tela
function formataCabecalho() {

	rDsjustif.css({'width':'390px'});
	rDsmsgeml.css({'width':'260px'});

	cDsjustif.css({'width':'400px'}).attr('rows','5').attr('cols','20');
	cDsmsgeml.css({'width':'400px'}).attr('rows','8').attr('cols','20');

	highlightObjFocus( $('#frmDados') );
	return false;
}

function navegaCampos() {
	cDsjustif.focus();
	
	cDsjustif.unbind('blur').bind('blur', function(e) {
		replaceAll(cDsjustif.val(),this);
	});
	cDsmsgeml.unbind('blur').bind('blur', function(e) {
		replaceAll(cDsmsgeml.val(),this);
	});
	return false;
}




// Botoes
function btnAprovar() {
	if (cdempres === undefined) {return false;}
	if (dtsolest === undefined) {return false;}

	validaHorarioEstouro(4);  // 4-Aprovacao com Estouro
	return false;
}

function btnReprovar() {
	if (cdempres === undefined) {return false;}
	if (dtsolest === undefined) {return false;}

	validaHorarioEstouro(3); // 3-Estouro
	return false;
}




// Monta Grid Inicial
function buscaEstourosFolha() {

	cdempres = "";
	dtsolest = "";

	$.ajax({
		type	: "POST",
		dataType: "html",
		url		: UrlSite + "telas/estfol/busca_estouro_folh_pagto.php",
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

    var divRegistro = $('div.divRegistros', '#tabEstouroFolha');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
	var conteudo	= $('#conteudo', linha).val();

    $('#tabEstouroFolha').css({'margin-top':'1px'});
	divRegistro.css({'height':'300px','padding-bottom':'1px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0]  = '30px';
	arrayLargura[1]  = '170px';
	arrayLargura[2]  = '110px';
	arrayLargura[3]  = '100px';
	arrayLargura[4]  = '50px';
	arrayLargura[5]  = '130px';
	arrayLargura[6]  = '65px';
	arrayLargura[7]  = '119px';
	arrayLargura[8]  = '119px';
	arrayLargura[9]  = '17px';

	var arrayAlinha = new Array();
		if(conteudo==0){
			arrayAlinha[0] = 'center';
		}else{
			arrayAlinha[0] = 'right';
		}
        arrayAlinha[1] = 'left';
        arrayAlinha[2] = 'right';
        arrayAlinha[3] = 'center';
        arrayAlinha[4] = 'right';
        arrayAlinha[5] = 'right';
        arrayAlinha[6] = 'right';
		arrayAlinha[7] = 'right';
		arrayAlinha[8] = 'right';

	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	hideMsgAguardo();

	/* Atribuindo o foco para a linha da tabela, pois ao clicar no cabecalho nao retornava
	para linha da tabela, dessa maneira a tela apresentava erro na hora de alterar ou
	excluir o registro selecionado */
0
	$('table > thead > tr > th', divRegistro).unbind('click').bind('click', function() {
		$('table > tbody > tr > td', divRegistro).focus();
	});

	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		selecionaTabela($(this));
	});

    // seleciona o registro que é focado
	$('table > tbody > tr', divRegistro).focus( function() {
		selecionaTabela($(this));
	});

	$('table > tbody > tr:eq(0)', divRegistro).click();
	return false;
}

function selecionaTabela(tr) {
    cdempres    = $('#cdempres', tr).val();
	dtsolest    = $('#dtsolest', tr).val();
	vlestour    = $('#vlestour', tr).val();
	
 	return false;
}

function mostrarTela(cddopcao) {

	if (cdempres === undefined) {return false;}
	if (dtsolest === undefined) {return false;}
	if (cddopcao === undefined) {return false;}
	
	// Recebe a opcao da tela Aprova/Reprova
	cdeftpag = cddopcao;

	/* Abre nova tela para aprovar/reprovar estouro de conta */

	$.ajax({
		type	: "POST",
		dataType: "html",
		url		: UrlSite + "telas/estfol/aprova_reprova_pagto.php",
		data: {
			cdeftpag     : cdeftpag,
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
	buscaEstourosFolha();
	return false;
}




function aprovaReprovaEstouro(operacao){
	
	var dsjustif = cDsjustif.val();
	var dsmsgeml = cDsmsgeml.val();
	
	if (operacao==3){
		var descricao = "atualizando a reprova&ccedil;&atilde;o do";
		var mesg = "Pagamento reprovado com sucesso!";
	}else
	if(operacao==4){
		var descricao = "aprovando o";
		var mesg = "Pagamento aprovado com sucesso! Em instantes os valores ser&atilde;o processados!";
	}

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, " + descricao + " registro...");

	$.ajax({
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/estfol/aprova_reprova_dados.php",
		data: {
			cdempres : cdempres,
			dtsolest : dtsolest,
			dsjustif : dsjustif,
			dsmsgeml : dsmsgeml,
			cdeftpag : operacao,
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
						showError("inform",mesg,"Alerta - Ayllos","encerraRotina(true);buscaPagamento();");
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

function validaHorarioEstouro(opcao){

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, verificando horario de estouro...");

	$.ajax({
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/estfol/horario_limite.php",
		data: {
			redirect : "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			hideMsgAguardo();
			try {
				eval(response);
				if (cdcritic==0) {
					mostrarTela(opcao); 
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
	var caracteresInvalidos = '<>;`´^~ªº¨§';
	// Lista todos os caracter que sera exibido
	var caracteresValidos =   '';

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
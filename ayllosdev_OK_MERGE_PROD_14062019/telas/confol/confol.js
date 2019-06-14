/*!
 * FONTE        : confol.js
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Maio/2015
 * OBJETIVO     : Biblioteca de funções da tela CONFOL
 * --------------
 * ALTERAÇÕES   : 23/11/2015 - Ajustado para somente incluir um convênio
                               sem informar as tarifas. As tarivas serao
							   gravadas e consultadas pela TARI0001.
							   Para o cancelamento, o registro nao pode
							   estar vinculado com o registro de tarifa 
							   da tela CADTAR. (Andre Santos - SUPERO)
 * -----------------------------------------------------------------------
 */
 
// Variaveis
var rCdcontar, rVltarid0, rVltarid1, rVltarid2,
    cCdcontar, cVltarid0, cVltarid1, cVltarid12, cDscontar;

var cTodosCabecalho, cTodosCabBureaux, btnOK, btnOK1;

var indrowid = "";
var regCdcontar = "";
var regDscontar = "";
var regVltarid0 = "";
var regVltarid1 = "";
var regVltarid2 = "";

// Controla exibicao de erro
var exibiErro;

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
	
	buscaConvenios();
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
		url: UrlSite + "telas/confol/form_dados.php",
		data: {
			indrowid    : indrowid,
			regCdcontar : regCdcontar,
			regDscontar : regDscontar,
			regVltarid0 : regVltarid0,
			regVltarid1 : regVltarid1,
			regVltarid2 : regVltarid2,
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
	rCdcontar	    	= $('label[for="cdcontar"]','#frmDados');
	
	rVltarid0	    	= $('label[for="vltarid0"]','#frmDados');
	rVltarid1	    	= $('label[for="vltarid1"]','#frmDados');
	rVltarid2	    	= $('label[for="vltarid2"]','#frmDados');
	
	cCdcontar      		= $('#cdcontar','#frmDados');
	cDscontar      		= $('#dscontar','#frmDados');
	
	cVltarid0      		= $('#vltarid0','#frmDados');
	cVltarid1      		= $('#vltarid1','#frmDados');
	cVltarid2      		= $('#vltarid2','#frmDados');

	cTodosCabDados	    = $('input[type="text"],select,textArea','#frmDados');
	
	formataCabecalho();
	navegaCampos();
	return false;
}

// Formatacao da Tela
function formataCabecalho() {

	/** Formulario Dados **/
	rCdcontar.css({'width':'80px'});

	rVltarid0.css({'width':'180px'});
	rVltarid1.css({'width':'180px'});
	rVltarid2.css({'width':'180px'});

	cCdcontar.addClass('campo').css({'width':'80px','text-align':'right'}).setMask('INTEGER','zzzzzzzzzz','','');
    cDscontar.addClass('campo').css({'width':'295px'}).attr('maxlength','60');

	cVltarid0.addClass('campo').css({'width':'100px','text-align':'right'})
	cVltarid1.addClass('campo').css({'width':'100px','text-align':'right'})
	cVltarid2.addClass('campo').css({'width':'100px','text-align':'right'})

	cVltarid0.desabilitaCampo();
	cVltarid1.desabilitaCampo();
	cVltarid2.desabilitaCampo();
	
	highlightObjFocus( $('#frmDados') );
	return false;
}

function navegaCampos() {

	cTodosCabDados.unbind('paste').bind('paste', function(e) {
		return false;
	});

	cDscontar.focus();
	cDscontar.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cVltarid0.focus();
			return false;
		}
	});
	cDscontar.unbind('blur').bind('blur', function(e) {
		replaceAll(cDscontar.val(),this);
	});

	cVltarid0.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cVltarid1.focus();
			return false;
		}
		mascaraMoeda(this,'.',',',6, e);
		return false;
	});

	cVltarid1.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cVltarid2.focus();
			return false;
		}
		mascaraMoeda(this,'.',',',6, e);
		return false;
	});

	cVltarid2.unbind('keypress').bind('keypress', function(e) {
		mascaraMoeda(this,'.',',',6, e);
		return false;
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

	showConfirmacao("Voc&ecirc; tem certeza que deseja excluir o conv&ecirc;nio tarif&aacute;rio selecionado?","Confirma&ccedil;&atilde;o - Ayllos","excluirConvenio();","","sim.gif","nao.gif");
	return false;
}




// Monta Grid Inicial
function buscaConvenios() {

	indrowid = "";
	
	blockBackground(parseInt($('#divRotina').css('z-index')));

	$.ajax({
		type	: "POST",
		dataType: "html",
		url		: UrlSite + "telas/confol/busca_convenios.php",
		data: {
			exibiErro : exibiErro,
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

    var divRegistro = $('div.divRegistros', '#tabConvenio');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
	var conteudo	= $('#conteudo', linha).val();
	
    $('#tabConvenio').css({'margin-top':'1px'});
	divRegistro.css({'height':'300px','padding-bottom':'1px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '80px';
	arrayLargura[1] = '400px';
	arrayLargura[2] = '80px';
	arrayLargura[3] = '80px';
	arrayLargura[4] = '80px';
	arrayLargura[5] = '15px';

	var arrayAlinha = new Array();
		if(conteudo==0){
			arrayAlinha[0] = 'center';
		}else{
			arrayAlinha[0] = 'right';
		}
        arrayAlinha[1] = 'left';
        arrayAlinha[2] = 'center';
        arrayAlinha[3] = 'center';
        arrayAlinha[4] = 'center';

	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

	// Na primeira consulta a variavel esta indefinida
	// Inicializamos a variavel de controle
	if (exibiErro===undefined) { exibiErro = ''; }
	if ( exibiErro==="false"){
		 hideMsgAguardo();
		 exibiErro = 'false';
	}

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
	regCdcontar = $('#cdcontar', tr).val();
	regDscontar = $('#dscontar', tr).val();
	regVltarid0 = $('#vltarid0', tr).val();
	regVltarid1 = $('#vltarid1', tr).val();
	regVltarid2 = $('#vltarid2', tr).val();
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
		regCdcontar = "";
		regDscontar = "";
	}
	
	/* Abre nova tela para inclusao/edicao de convenio */
	
	$.ajax({
		type	: "POST",
		dataType: "html",
		url		: UrlSite + "telas/confol/cadastro_convenio.php",
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

function gravarConvenio(){

	var rowid    = $('#indrowid','#frmDados').val();
	var cdcontar = cCdcontar.val();
	var dscontar = cDscontar.val();

	// Verificando qual tipo de gravacao
	if (rowid == ""){
		var descricao = "inserido";
	}else{
		var descricao = "atualizado";
	}	
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, inserindo dados...");

	$.ajax({
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/confol/gravar_dados.php",
		data: {
			rowid    : rowid,
			cdcontar : cdcontar,
			dscontar : dscontar,
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
						showError("inform","O conv&ecirc;nio foi " + descricao + " com sucesso!","Alerta - Ayllos","encerraRotina(true);buscaConvenios();");
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

function excluirConvenio(){

	var rowid    = indrowid;
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, excluindo conv&ecirc;nio...");

	$.ajax({
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/confol/excluir_dados.php",
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
						showError("inform","O conv&ecirc;nio foi exclu&iacute;do com sucesso!","Alerta - Ayllos","buscaConvenios();");
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


function mascaraMoeda(campoText, SeparadorMilesimo, SeparadorDecimal, qtdCaracter, e){

	/**
		Objetivo: Funcao para escrever valores no formato de moeda.		          
				  
		Parametros : campoText         -- Campo que receberá a funcao de formatacao
		             SeparadorMilesimo -- Separador de Milhar
					 SeparadorDecimal  -- Separador de Decimal
					 qtdCaracter       -- Quantidade de Caracteres
					 e                 -- Evento do teclado
	**/

    var key = '';
    var i = j = 0;
    var len = len2 = 0;
    var strCheck = '0123456789';
    var aux = aux2 = '';
    var whichCode = (window.Event) ? e.which : e.keyCode;

    if (whichCode == 13) return true;

	// Valor para o código da Chave
    key = String.fromCharCode(whichCode);
	if (strCheck.indexOf(key) == -1) return false; // Chave inválida

	// Tamanho do valor do campo
    len = campoText.value.length;
    for(i = 0; i < len; i++)
        if ((campoText.value.charAt(i) != '0') && (campoText.value.charAt(i) != SeparadorDecimal)) break;

	aux = '';
    for(; i < len; i++)
        if (strCheck.indexOf(campoText.value.charAt(i))!=-1) aux += campoText.value.charAt(i);

    aux += key;
    len = aux.length;
	if (len==qtdCaracter) return false; // Verifica quatidade de caracteres
    if (len == 0) campoText.value = '0'+ SeparadorDecimal +'00'; // Inicializa
    if (len == 1) campoText.value = '0'+ SeparadorDecimal + '0' + aux;
    if (len == 2) campoText.value = '0'+ SeparadorDecimal + aux;
    if (len > 2) {
        aux2 = '';
        for (j = 0, i = len - 3; i >= 0; i--) {
            if (j == 3) {
                aux2 += SeparadorMilesimo;
                j = 0;
            }
            aux2 += aux.charAt(i);
            j++;
        }
        campoText.value = '';
        len2 = aux2.length;
        for (i = len2 - 1; i >= 0; i--)
        campoText.value += aux2.charAt(i);
        campoText.value += SeparadorDecimal + aux.substr(len - 2, len);
    }
	return false;
}
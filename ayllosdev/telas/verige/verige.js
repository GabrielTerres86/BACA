/*!
 * FONTE        : verige.js
 * CRIAÇÃO      : Carlos (CECRED) 
 * DATA CRIAÇÃO : 11/11/2013										ÚLTIMA ALTERAÇÃO:
 * OBJETIVO     : Biblioteca de funções da tela VERIGE
 * --------------
 * ALTERAÇÕES   : 
 *				  
 * --------------
 */

var frmCab   		= 'frmCab';
var	cddopcao		= 'C';
var cdcoopex		= '';

var strHTML 		= ''; // Variável usada na criação do form onde serão mostradas as mensagens de alerta.
var style 			= ''; // Variável usada na criação do form onde serão mostradas as mensagens de alerta.	
var mensagem 		= ''; // Variável usada na criação do form onde serão mostradas as mensagens de alerta.						 

var strHTML2 		= ''; // Variável usada na criação do form onde serão mostradas as mensagens de alerta do grupo economico.	

var cCddopcao, cCdagenci, cNrdconta, cTodosCabecalho, cDivagenci;


$(document).ready(function() {

	estadoInicial();

});


// inicio
function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);

	cdcoopex = '';

	// retira as mensagens	
	hideMsgAguardo();

	// formata	
	formataCabecalho();
	formataMsgAjuda('divTela');
	
	// remove o campo prosseguir
	trocaBotao('Prosseguir','btnContinuar()');	
	
	// inicializa com a frase de ajuda para o campo cddopcao
	/*$('span:eq(0)', '#divMsgAjuda').html( cCddopcao.attr('alt') );*/

	cTodosCabecalho.limpaFormulario().removeClass('campoErro');	

	cCddopcao.habilitaCampo();
	cCddopcao.focus();
	cCddopcao.val( cddopcao );
	cDivagenci.show();
	cCdagenci.show();
	
	removeOpacidade('divTela');
	
	highlightObjFocus( $('#frmCab') );
}


function buscaGrupoEconomico() {

	showMsgAguardo("Aguarde, verificando grupo econ&ocirc;mico...");

	cNrdconta.val(normalizaNumero(cNrdconta.val()));

	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/verige/busca_grupo_economico.php',
		data: {
			nrdconta:  cNrdconta.val(),	
			redirect: 'html_ajax'
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
				cTodosCabecalho.desabilitaCampo();
				$('#btSalvar').hide();
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}							
	});
	
	return false;
	
}

function buscaGrupoEconomicoRelatorio(infoagen) {

	showMsgAguardo("Aguarde, verificando grupo econ&ocirc;mico...");

	cNrdconta.val(normalizaNumero(cNrdconta.val()));
	
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/verige/busca_grupo_economico_relatorio.php',
		data: {
			nrdconta:  cNrdconta.val(),	
			infoagen:  infoagen,
			redirect: 'html_ajax'
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
				cTodosCabecalho.desabilitaCampo();
				$('#btSalvar').hide();
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}							
	});
	
	return false;
	
}

function calcEndividRiscoGrupo(nrdgrupo) {

	showMsgAguardo("Aguarde, calculando endividamento e risco do grupo econ&ocirc;mico...");
	
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/verige/calc_endivid_grupo.php',
		data: {
			nrdconta: normalizaNumero(cNrdconta.val()),	
			nrdgrupo: nrdgrupo,
			redirect: 'html_ajax'
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);				
			} catch(error) {
				hideMsgAguardo();
			    showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}
	});
	
	return false;
}

function calcEndividRiscoGrupoRelatorio(nrdgrupo, infoagen) {

	showMsgAguardo("Aguarde, calculando endividamento e risco do grupo econ&ocirc;mico...");
		
	var action = UrlSite + 'telas/verige/calc_endivid_grupo_relatorio.php';

    cTodosRelatorios = $('input[type="text"],select','#' + frmCab);
	
	cTodosRelatorios.removeClass('campoErro');
	
	$('input', '#'+ frmCab).habilitaCampo();
	
	$('#sidlogin','#' + frmCab).remove();
	
	$('#' + frmCab).append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '" />');
	$('#' + frmCab).append('<input type="hidden" id="infoagen" name="infoagen" value="' + infoagen + '" />');
	$('#' + frmCab).append('<input type="hidden" id="nrdgrupo" name="nrdgrupo" value="' + nrdgrupo + '" />');

	// Configuro o formulário para posteriormente submete-lo
	$('#cddopcao','#' + frmCab).val(cddopcao);
	
	var callafter = "estadoInicial();";
	
	carregaImpressaoAyllos(frmCab,action,callafter);
	
	return false;
}


// Função para fechar div com mensagens de alerta
function encerraMsgsGrupoEconomico(){
	
	// Esconde div
	$("#divEndivGrupo").html("&nbsp;");
	
	// Esconde div de bloqueio
	unblockBackground();
	blockBackground(parseInt($("#divRotina").css("z-index")));
	hideMsgAguardo();
	
	return false;
	
}

function mostraMsgsGrupoEconomico() {	
	
	if(strHTML != ''){
		// Coloca conteúdo HTML no div
		$("#divEndivGrupo").html(strHTML);
		$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
		$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});				
		
		// Esconde mensagem de aguardo
		hideMsgAguardo();				
	}

	return false;	
}

function formataGrupoEconomico(){
    var divRegistro = $('div.divRegistros','#divEndivGrupo');		

	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'150px'});
	
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];
	
	var arrayLargura = new Array();
	arrayLargura[0] = '40px';
	arrayLargura[1] = '90px';
	arrayLargura[2] = '160px';
	arrayLargura[3] = '50px';
	arrayLargura[4] = '130px';
	
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'right';	
	arrayAlinha[3] = 'left';
	arrayAlinha[4] = 'right';
	
    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	
	return false;
	
}


function controlaPesquisas() {

	/*---------------------*/
	/*  CONTROLE CONTA/DV  */
	/*---------------------*/
	var linkConta = $('a:eq(0)','#frmCab');

	if ( linkConta.prev().hasClass('campoTelaSemBorda') ) {
		linkConta.addClass('lupa').css('cursor','auto').unbind('click');
	} else {	
		linkConta.css('cursor','pointer').unbind('click').bind('click', function() {			
			mostraPesquisaAssociado('nrdconta','frmCab');
			$("span.tituloJanelaPesquisa").html("PESQUISA DE ASSOCIADOS");
		});	
	}

	/*---------------------*/
	/*  CONTROLE PAC  	   */
	/*---------------------*/
	var linkPac = $('a:eq(1)','#'+frmCab);

	if ( linkPac.prev().hasClass('campoTelaSemBorda') ) {
		linkPac.addClass('lupa').css('cursor','auto').unbind('click');
	} else {		
		linkPac.css('cursor','pointer').unbind('click').bind('click', function() {			
			bo			= 'b1wgen0059.p';
			procedure	= 'busca_pac';
			titulo      = 'Agência PA';
			qtReg		= '20';					
			filtrosPesq	= 'Cód. PA;cdagenci;30px;S;0;;codigo;|Agência PA;nmresage;200px;S;;;descricao;';
			colunas 	= 'Código;cdagepac;20%;right|Descrição;dsagepac;80%;left';
			mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas);			
		});		
	}
	
	return false;
}

function controlaLayout() {

	formataCabecalho();
	formataMsgAjuda('divTela');
	ativaCampoCabecalho();
		
	controlaPesquisas();
	
	return false;
	
}


// formata
function formataCabecalho() {
	encerraMsgsGrupoEconomico();
	// label
	rCddopcao = $('label[for="cddopcao"]', '#'+frmCab);
	rNrdconta = $('label[for="nrdconta"]', '#'+frmCab);
	rCdagenci = $('label[for="cdagenci"]', '#'+frmCab);	
	
	rCddopcao.addClass('rotulo').css({'width':'73px'});
	rNrdconta.addClass('rotulo').css({'width':'73px'});
	rCdagenci.addClass('rotulo-linha').css({'width':'36px'});	
	
	// input
	cCddopcao = $('#cddopcao', '#'+frmCab);
	cCdagenci = $('#cdagenci', '#'+frmCab);
	cNrdconta = $('#nrdconta', '#'+frmCab);
	cCdagenci.css('width','76px');
	cNrdconta.addClass('conta pesquisa').css('width','76px');
	
	cCddopcao.css({'width':'240px'});
	
	// outros
	cTodosCabecalho = $('input[type="text"],select','#'+frmCab);
	cTodosCabecalho.desabilitaCampo();
	cDivagenci = $('#divagenci');
		
	
	if ( $.browser.msie ) {
		rCdagenci.css({'width':'38px'});
	}
	
	cCddopcao.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }

		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {

			cddopcao = cCddopcao.val();
			ativaCampoCabecalho();

			controlaPesquisas();
			return false;
		} 

	});	
	
	cCddopcao.change(function(){

		if ( divError.css('display') == 'block' ) { return false; }		
		
		cddopcao = cCddopcao.val();
		ativaCampoCabecalho();		

		controlaPesquisas();

		return false;		

	});
	
	cCdagenci.unbind('keypress').bind('keypress', function(e) {
	
		if ( divError.css('display') == 'block' ) { return false; }	
		
		// Se é a tecla ENTER, 
		
		if ( e.keyCode == 13 ) {
			btnContinuar();
			return false;
		} 
		
	});

    cNrdconta.unbind('change').bind('change', function(e) {
		if ( e.keyCode == 13 && cNrdconta.val() != '0') {
		    return true;
	    }
		
		if (cNrdconta.val() == '0') {			
			cCdagenci.habilitaCampo().focus();
		} else {
			cCdagenci.desabilitaCampo();
		}

		controlaPesquisas();
		
		return false;

	});	
	
	cNrdconta.unbind('keypress').bind('keypress', function(e) {
	
		if ( divError.css('display') == 'block' ) { return false; }	
		
		// Se é a tecla ENTER		
		if ( e.keyCode == 13 && cNrdconta.val() != '0' ) {
			btnContinuar();
			return false;
		} 
		
	});
	
	layoutPadrao();
	controlaPesquisas();
	
	return false;	
}



// ativa campo do cabecalho conforme a opcao
function ativaCampoCabecalho() {

	trocaBotao('Prosseguir','btnContinuar()');
	cCddopcao.desabilitaCampo();
	
	if ( cddopcao == 'C' ) {
		cDivagenci.hide();
		cCdagenci.desabilitaCampo().hide();
		rNrdconta.habilitaCampo();
		cNrdconta.habilitaCampo().focus();		
	} else if ( cddopcao == 'R' ) { 
		rNrdconta.habilitaCampo();
		cNrdconta.habilitaCampo().select();
	}

	return false;
	
}


// ajuda
function formataMsgAjuda( tela ) {	
	
	var divMensagem = $('#divMsgAjuda', '#'+tela );
	/*divMensagem.css({'border':'1px solid #ddd','background-color':'#eee','padding':'2px','height':'20px','margin':'7px 0px'});*/
	
	var spanMensagem = $('span',divMensagem);
/*	spanMensagem.css({'text-align':'left','font-size':'11px','float':'left','padding':'3px'});*/

	var botoesMensagem = $('#divBotoes',divMensagem);
	botoesMensagem.css({'float':'center','padding':'0 0 0 2px', 'margin-top':'7px', 'margin-bottom':'5px'});		
	
	if ( $.browser.msie ) {
		spanMensagem.css({'padding':'5px 3px 3px 3px'});
		botoesMensagem.css({'margin-top':'2px'});		
	}
		
}

// botoes
function btnVoltar() {

	estadoInicial();
	controlaPesquisas();
	
	return false;
	
}

function btnContinuar() {

	if ( divError.css('display') == 'block' ) { return false; }		

	if ( cCddopcao.hasClass('campo') ) {
	
		cddopcao = cCddopcao.val();		
		ativaCampoCabecalho();		

	} 

	controlaPesquisas();

	if ( cCddopcao.val() == 'C' && cNrdconta.val() != '' ) {
		buscaGrupoEconomico();
	} else 
	if ( cCddopcao.val() == 'R' ) {
	
		if ( cNrdconta.val() != '' && cNrdconta.val() != '0' ) {
			// buscar por nrdconta
			buscaGrupoEconomicoRelatorio(false);			
		} else 
		if ( (cNrdconta.val() == '' || cNrdconta.val() == '0') && cCdagenci.val() != '' && cCdagenci.val() != '0' ) {
		    // buscar por PA
			buscaGrupoEconomicoRelatorio(true);
		}
	}	
	
	return false;
}



function trocaBotao( botao,funcao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onClick="btnVoltar(); return false;">Voltar</a>');
	
	if ( botao != '') {
		$('#divBotoes','#divTela').append('&nbsp;<a href="#" class="botao" id="btSalvar" onClick="'+funcao+'; return false;">'+botao+'</a>');
	}
	
	return false;

}


function verificaAcesso(){

	var mensagem = 'Aguarde, validando acesso ...';
	
	showMsgAguardo( mensagem );	

	// Gera requisição ajax para validar o acesso
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/verige/verifica_acesso.php', 
		data    : 
				{ 
					cddopcao    : cddopcao,
					cdmovmto    : cdmovmto,
					cdcoopex    : cdcoopex,
					redirect	: 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) {
					hideMsgAguardo();
					eval( response );

				}
				
	});
	
	return false;

}

function liberaAcesso(){

	var mensagem = 'Aguarde, liberando acesso ...';
	
	showMsgAguardo( mensagem );	

	// Gera a requisição ajax para liberar acesso a tela
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/verige/libera_acesso.php', 
		data    : 
				{ 
					cddopcao    : cddopcao,
					cdmovmto	: cdmovmto,
					cdcoopex    : cdcoopex,
					redirect	: 'script_ajax' 
				},
		async 	: false,
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) {
					hideMsgAguardo();	
					eval( response );

				}
				
	});
	
	return false;

}

// Função para fechar div com mensagens de alerta
function encerraMsgsAlerta() {
	
	// Esconde div
	$("#divMsgsAlerta").css("visibility","hidden");
	
	$("#divListaMsgsAlerta").html("&nbsp;");
	
	/// Esconde div de bloqueio
	unblockBackground();
	
	return false;
	
}

function mostraMsgsAlerta(){
	
	if(strHTML != ''){

		// Coloca conteúdo HTML no div
		$("#divListaMsgsAlerta").html(strHTML);

		// Mostra div 
		$("#divMsgsAlerta").css("visibility","visible");
		
		// Esconde mensagem de aguardo
		hideMsgAguardo();
		
		// Bloqueia conteúdo que está átras do div de mensagens
		blockBackground(parseInt($("#divMsgsAlerta").css("z-index")));
		
	}

	return false;
	
}
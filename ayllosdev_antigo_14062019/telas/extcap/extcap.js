/*!
 * FONTE        : extcap.js
 * CRIAÇÃO      : Rogerius Militão (DB1) 
 * DATA CRIAÇÃO : 25/08/2011
 * OBJETIVO     : Biblioteca de funções da tela EXTCAP
 * --------------
 * ALTERAÇÕES   : 26/10/2012 - Incluso efeito highlightObjFocus, ajustado
							   tamanho campos para trabalhar com novo css,
							   alterado input imagem por botões. (Daniel)
				  05/06/2013 - Incluir rVlbloque, cVlbloque e ajustado layout 
							   dos mesmos (Lucas R.).
 * -----------------------------------------------------------------------
 */

//Formulários e Tabela
var frmCab   		= 'frmCab';
var frmDados  		= 'frmExtcap';
var tabDados		= 'tabExtcap';

//Labels/Campos do cabeçalho
var rNrdconta, rNmprimtl,  
	cNrdconta, cNmprimtl, cTodosCabecalho, btnOK;

var rDtmovmto, rVlsanter,  
	cDtmovmto, cVlsanter, cTodosDados;

var rVlstotal, rVlbloque,
	cVlstotal, cVlbloque;
	
$(document).ready(function() {
	estadoInicial();
});


// seletores
function estadoInicial() {
	$('#divTela').fadeTo(0,0.1);
	
	hideMsgAguardo();		
	atualizaSeletor();
	formataCabecalho();
	formataDados();
	
	trocaBotao('prosseguir');
	$('#'+tabDados).remove();
	$('#frmExtcapSaldo').remove();
	$('#divPesquisaRodape').remove();
	
	cTodosCabecalho.limpaFormulario().removeClass('campoErro');	
	cTodosDados.limpaFormulario().removeClass('campoErro');	

	cNrdconta.focus();	
	removeOpacidade('divTela');
}

function atualizaSeletor() {

	// cabecalho
	rNrdconta			= $('label[for="nrdconta"]','#'+frmCab); 
	rNmprimtl	        = $('label[for="nmprimtl"]','#'+frmCab);        
	
	cNrdconta			= $('#nrdconta','#'+frmCab); 
	cNmprimtl			= $('#nmprimtl','#'+frmCab); 
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	btnOK				= $('#btnOK','#'+frmCab);

	// contrato
	rDtmovmto			= $('label[for="dtmovmto"]','#'+frmDados);
	rVlsanter			= $('label[for="vlsanter"]','#'+frmDados);
	rVlstotal			= $('label[for="vlstotal"]','#frmExtcapSaldo');
	rVlbloque			= $('label[for="vlbloque"]','#frmExtcapSaldo');
	
	cDtmovmto			= $('#dtmovmto', '#'+frmDados);
	cVlsanter			= $('#vlsanter', '#'+frmDados);
	cVlstotal			= $('#vlstotal', '#frmExtcapSaldo');
	cVlbloque			= $('#vlbloque', '#frmExtcapSaldo');
	cTodosDados			= $('input[type="text"],select','#'+frmDados);
	
	return false;
}


// controle
function controlaOperacao( operacao, nriniseq, nrregist ) {
	
	hideMsgAguardo();

	var nrdconta = normalizaNumero( cNrdconta.val() );
	var nmprimtl = cNmprimtl.val();
	var dtmovmto = cDtmovmto.val();
	
	var mensagem = 'Aguarde, listando extrato ...';
	showMsgAguardo( mensagem );	
	
	// Carrega dados da conta através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/extcap/principal.php', 
		data    : 
				{ 
					operacao	: operacao,
					nrdconta	: nrdconta,
					nmprimtl	: nmprimtl,
					dtmovmto	: dtmovmto,
					nriniseq	: nriniseq,
					nrregist	: nrregist,
					redirect	: 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) {
					hideMsgAguardo();
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							$('#divTela').html(response);
							return false;
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
						}
					} else {
						try {
							eval( response );
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
						}
					}

				}
	});

	return false;	
}

function controlaPesquisas() {

	/*---------------------*/
	/*  CONTROLE CONTA/DV  */
	/*---------------------*/
	var linkConta = $('a:eq(0)','#'+ frmCab );

	if ( linkConta.prev().hasClass('campoTelaSemBorda') ) {		
		linkConta.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {
		linkConta.css('cursor','pointer').unbind('click').bind('click', function() {			
			mostraPesquisaAssociado('nrdconta', frmCab );
		});
	}

	return false;
}


// formata
function formataCabecalho() {
	
	rNrdconta.addClass('rotulo').css({'width':'38px'});
	rNmprimtl.addClass('rotulo-linha').css({'width':'42px'});

	cNrdconta.addClass('conta pesquisa').css({'width':'70px'})
	cNmprimtl.css({'width':'365px'});	

	if ( $.browser.msie ) {
		rNmprimtl.css({'width':'44px'});
	}	
	
	cTodosCabecalho.habilitaCampo();	
	cNmprimtl.desabilitaCampo();
	
	var nomeForm    = 'frmCab';
	highlightObjFocus( $('#'+nomeForm) );
	
	var nomeForm    = 'frmExtcap';
	highlightObjFocus( $('#'+nomeForm) );
	
	// Se clicar no botao OK
	btnOK.unbind('click').bind('click', function() { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( cNrdconta.hasClass('campoTelaSemBorda')  ) { return false; }		
		
		// Armazena o número da conta na variável global
		var nrdconta = normalizaNumero( cNrdconta.val() );
		
		// Verifica se o número da conta é vazio
		if ( nrdconta == '' ) { return false; }
	
		// Verifica se a conta é válida
		if ( !validaNroConta(nrdconta) ) { 
			showError('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'nrdconta\',\''+ frmCab +'\');'); 
			return false; 
		}
		
		// Se chegou até aqui, a conta é diferente do vazio e é válida, então realizar a operação desejada
		controlaOperacao('associado', 1, 9);
		return false;
			
	});	

	cNrdconta.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			btnOK.click();
			return false;
		} else if ( e.keyCode == 118 ) {
			mostraPesquisaAssociado('nrdconta', frmCab );
			return false;
		}
	});	

	layoutPadrao();
	cNrdconta.trigger('blur');
	controlaPesquisas();
	return false;	
}

function formataDados() {

	rDtmovmto.addClass('rotulo').css({'width':'90px'});
	rVlsanter.addClass('rotulo-linha').css({'width':'222px'});
	rVlstotal.addClass('rotulo-linha').css({'width':'192px'});
	rVlbloque.addClass('rotulo').css({'width':'120px'});
	
	cDtmovmto.addClass('inteiro').css({'width':'120px'}).attr('maxlength','4');
	cVlsanter.css({'width':'120px','text-align':'right'});
	cVlstotal.css({'width':'120px','text-align':'right'}).desabilitaCampo();
	cVlbloque.css({'width':'120px','text-align':'right'}).desabilitaCampo();
	
	if ( $.browser.msie ) {
		rVlsanter.css({'width':'222px'});
	}
	
	cTodosDados.desabilitaCampo();

	// Se clicar no botao OK
	cDtmovmto.unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( e.keyCode == 13 ) {
			controlaOperacao('extrato', 1, 9);
			return false;
		}
			
	});	
	
	layoutPadrao();
	controlaPesquisas();
	return false;
}

function formataTabela() {
	
	// tabela
	var divRegistro = $('div.divRegistros', '#'+tabDados);		
	var tabela      = $('table', divRegistro );
	
	$('#'+tabDados).css({'margin-top':'5px'});
	divRegistro.css({'height':'145px','padding-bottom':'2px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '62px';
	arrayLargura[1] = '29px';
	arrayLargura[2] = '29px';
	arrayLargura[3] = '45px';
	arrayLargura[4] = '115px';
	arrayLargura[5] = '10px';
	arrayLargura[6] = '75px';
	arrayLargura[7] = '55px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'left';
	arrayAlinha[5] = 'right';
	arrayAlinha[6] = 'right';
	arrayAlinha[7] = 'right';
	arrayAlinha[8] = 'right';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	
	cTodosCabecalho.desabilitaCampo();
	cTodosDados.desabilitaCampo();
	
	$('#btSalvar', '#divBotoes').css({'display':'none'});
	controlaPesquisas();
	return false;
}

function controlaLayout( operacao ) {

	atualizaSeletor();
	formataCabecalho();
	formataDados();
	cTodosCabecalho.desabilitaCampo();

	if ( operacao == 'associado' ) {
		cDtmovmto.habilitaCampo();
		cDtmovmto.focus();
		$('#'+tabDados).remove();
		$('#frmExtcapSaldo').remove();
		$('#divPesquisaRodape').remove();
		trocaBotao('concluir');
		
	} else if ( operacao == 'extrato' ) {
		formataTabela();
		
	}

	controlaPesquisas();
	layoutPadrao();
	return false;
}


// botoes
function btnVoltar() {
	estadoInicial();
	controlaPesquisas();
	return false;
}

function btnContinuar() {
	
	if ( divError.css('display') == 'block' ) { return false; }		

	if ( cNrdconta.hasClass('campo')  ) { 	
		btnOK.click();
	
	} else {
		controlaOperacao('extrato', 1, 9);

	}
	
	return false;

}

function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;" >Voltar</a>&nbsp;');
	
	if (botao == 'concluir') {
		$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onclick="btnContinuar(); return false;" >Concluir</a>');
	}

	if (botao == 'prosseguir') {
		$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onclick="btnContinuar(); return false;" >Prosseguir</a>');
	}
	
	return false;
}

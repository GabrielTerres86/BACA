/*!
 * FONTE        : imprel.js
 * CRIAÇÃO      : Rogerius Militão (DB1) 
 * DATA CRIAÇÃO : 02/08/2011
 * OBJETIVO     : Biblioteca de funções da tela IMPREL
 * --------------
 * ALTERAÇÕES   :
 * 25/06/2012 - Jorge        (CECRED) : Alterado funcao Gera_Impressao(), adequado para submeter impressao.
 * 26/11/2012 - Daniel       (CECRED) : Alterado botões do tipo tag <input> para tag <a> novo layout, 
 *                                      incluso efeito fade e highlightObjFocus. Alterado posicionamento]
 *	                                    campos da tela (Daniel).
 * 15/08/2013 - Carlos       (CECRED) : Alteração da sigla PAC para PA.
 * 24/12/2014 - Jorge/Gielow (CECRED) : Ajuste de tamanho dos campos para adequar em IE 10 11 e Campo PA com 3 casas.
 * --------------
 */

//Formulários e Tabela
var frmCab   		= 'frmCab';

var rCddopcao, rNrdrelat, rCdagenca, 
	cCddopcao, cNrdrelat, cCdagenca, cTodosCabecalho, btnOK;

var flgvepac 		= '';
var arrayImprel		= new Array();

var nrJanelas		= 0;
	
$(document).ready(function() {
	estadoInicial();
	
});

// inicio
function estadoInicial() {

	$('#frmCab').fadeTo(0,0.1);
	
	$('#frmCab').css({'display':'block'});
	$('#divBotoes', '#divTela').css({'display':'block'});
	
	arrayImprel = new Array();
	
	trocaBotao('Prosseguir');	
	formataCabecalho();
	
	cNrdrelat.val('');
	cCdagenca.val('');	
	
	removeOpacidade('frmCab');
}

// controle
function controlaOperacao() {
	
	var cddopcao = cCddopcao.val();
	var mensagem = 'Aguarde, buscando dados ...';
	
	showMsgAguardo( mensagem );	
	
	// Carrega dados da conta através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/imprel/principal.php', 
		data    : 
				{ 
					cddopcao	: cddopcao,
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

// formata
function formataCabecalho() {

	// cabecalho
	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab); 
	rNrdrelat	        = $('label[for="nrdrelat"]','#'+frmCab);        
	rCdagenca	        = $('label[for="cdagenca"]','#'+frmCab);        
	
	cCddopcao			= $('#cddopcao','#'+frmCab); 
	cNrdrelat			= $('#nrdrelat','#'+frmCab); 
	cCdagenca			= $('#cdagenca','#'+frmCab); 
	
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	btnOK				= $('#btnOK','#'+frmCab);
	btnProsseguir		= $('#btSalvar','#divBotoes');

	rCddopcao.addClass('rotulo').css({'width':'57px'});
	rNrdrelat.addClass('rotulo-linha').css({'width':'55px'});
	rCdagenca.addClass('rotulo-linha').css({'width':'30px'});

	cCddopcao.css({'width':'500px'})
	cNrdrelat.css({'width':'462px'});	
	
	if ( $.browser.msie ) {
		cNrdrelat.css({'width':'462px'});			
	}
	
	cCdagenca.addClass('inteiro campoTelaSemBorda').css({'width':'35px'}).attr('maxlength','3');	

	cTodosCabecalho.desabilitaCampo();
	cCddopcao.habilitaCampo();
	cCddopcao.focus();
	
	highlightObjFocus( $('#frmCab') );
	
	$("#btVoltar","#divBotoes").hide();
	$("#btSalvar","#divBotoes").hide();
	
	// Se clicar no botao OK
	btnOK.unbind('click').bind('click', function() { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( cCddopcao.hasClass('campoTelaSemBorda')  ) { return false; }		
		
		cTodosCabecalho.removeClass('campoErro');
			
		// Se chegou até aqui, a conta é diferente do vazio e é válida, então realizar a operação desejada
		controlaOperacao();
		return false;
			
	});	

	cCddopcao.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		

		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			btnOK.focus();
			btnOK.click();
			return false;
		} 
	});	
	
	cCdagenca.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		

		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			btnProsseguir.click();			
			return false;
		} 
	});	
	
	cNrdrelat.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }	
		
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				cNrdrelat.desabilitaCampo();
				trocaBotao('Concluir');
				cCdagenca.habilitaCampo();	
				cCdagenca.focus();
				return false;
		}	
	});
	
	cCdagenca.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }	
		
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				btnContinuar();
				return false;
		}	
	});

	layoutPadrao();
	return false;	
}

function controlaLayout() {

	$('#frmCab').css({'display':'block'});
	$('#divBotoes', '#divTela').css({'display':'block'});

	cTodosCabecalho.desabilitaCampo();
	cNrdrelat.habilitaCampo();
	cNrdrelat.focus();
	
	if ( cCddopcao.hasClass('campoTelaSemBorda')  ) {
		$("#btVoltar","#divBotoes").show();
		$("#btSalvar","#divBotoes").show();	
	}
	
	return false;
}

// imprimir
function Gera_Impressao() {				
	
	var action = UrlSite + 'telas/imprel/imprimir_dados.php';	
		
	cTodosCabecalho.habilitaCampo();		
	
	carregaImpressaoAyllos(frmCab,action,"estadoInicial();");
	
}

// botoes
function btnVoltar() {
	estadoInicial();
	return false;
}

function btnContinuar() {

	if ( divError.css('display') == 'block' ) { return false; }		
	
	if ( cCddopcao.hasClass('campo') ) {
		btnOK.click();	
		
	} else if ( cCdagenca.hasClass('campoTelaSemBorda') && cNrdrelat.val() != '' && arrayImprel[cNrdrelat.val()] == 'yes' ) {
		cNrdrelat.desabilitaCampo();
		cCdagenca.habilitaCampo().focus();
		trocaBotao('Concluir');
		
	} else if ( ( cCddopcao.hasClass('campoTelaSemBorda') && cNrdrelat.hasClass('campoTelaSemBorda') ) ||  arrayImprel[cNrdrelat.val()] == 'no' ) {
		// Verifica PA 
		if ( cCdagenca.hasClass('campo') && cCdagenca.val() == '' ) { 
			showError('error','PA inv&aacute;lido.','Alerta - Ayllos','cCdagenca.focus();'); 
			return false; 
		} else {
			Gera_Impressao();
		}
		
	}
	
	return false;

}

function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onClick="btnVoltar(); return false;" >Voltar</a>&nbsp;');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onClick="btnContinuar(); return false;" >'+botao+'</a>&nbsp;');
	
	return false;
}
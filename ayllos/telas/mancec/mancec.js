/*!
/*!
 * FONTE        : mancec.js
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 18/10/2016
 * OBJETIVO     : Biblioteca de funções da tela MANCEC
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
var nometela;

//Formulários e Tabela
var frmCab   		= 'frmCab';

var rCddopcao, cTodosCabecalho, btnOK, cTodosEmitente;
	
var cCdcmpchq, cCddopcao, cNmemichq, cNrcpfchq;
	
$(document).ready(function() {	

	estadoInicial();			
	return false;
		
});


// Inicio
function estadoInicial() {
	
	hideMsgAguardo();

	$('#frmCab').fadeTo(0,0.1);
	$('#frmEmitente').css({'display':'none'});
	$('#divBotoes').css({'display':'none'});
	$('#divDadosEmitente').css({'display':'none'});
	
	formataCabecalho();
	formataEmitente();
	
	trocaBotao( 'Emitente' );
	
	cTodosCabecalho.limpaFormulario();
	cTodosEmitente.limpaFormulario();
	
	removeOpacidade('frmCab');	
	
	return false;
	
}

// Formata
function formataCabecalho() {

	// cabecalho
	rCddopcao = $('label[for="cddopcao"]','#'+frmCab); 
	cCddopcao = $('#cddopcao','#'+frmCab); 
	
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	btnOK				= $('#btnOK','#'+frmCab);
	
	//Label
	rCddopcao.addClass('rotulo').css({'width':'110px'});	

	//Campos
	cCddopcao.css({'width':'540px'});
		
	cTodosCabecalho.habilitaCampo();

	highlightObjFocus( $('#frmCab') );
	
	cCddopcao.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			btnOK.click();
			return false;
		} 
	});	
	
	cCddopcao.focus();	
	
	// Se clicar no botao OK
	btnOK.unbind('click').bind('click', function() {
				
		if ( divError.css('display') == 'block' ) { return false; }		
		
		if ( cCddopcao.hasClass('campoTelaSemBorda')  ) { return false; }		
		
		liberaBusca();
		
		return false;
			
	});	
	
	layoutPadrao();
	return false;	
}

function formataEmitente() {
	
	rCdcmpchq = $('label[for="cdcmpchq"]','#frmEmitente'); 
	rCdbanchq = $('label[for="cdbanchq"]','#frmEmitente'); 
	rCdagechq = $('label[for="cdagechq"]','#frmEmitente'); 
	rNrctachq = $('label[for="nrctachq"]','#frmEmitente'); 
	
	rNmemichq = $('label[for="nmemichq"]','#frmEmitente'); 
	rNrcpfchq = $('label[for="nrcpfchq"]','#frmEmitente'); 
	
	cCdcmpchq = $('#cdcmpchq','#frmEmitente');
	cCdbanchq = $('#cdbanchq','#frmEmitente');
	cCdagechq = $('#cdagechq','#frmEmitente');
	cNrctachq = $('#nrctachq','#frmEmitente');
	
	cNmemichq = $('#nmemichq','#frmEmitente');
	cNrcpfchq = $('#nrcpfchq','#frmEmitente');

	cTodosEmitente = $('input[type="text"],select','#frmEmitente');
	
	//Label
	rCdcmpchq.addClass('rotulo').css({'width':'90px'});
	rCdbanchq.addClass('rotulo-linha').css({'width':'90px'});
	rCdagechq.addClass('rotulo-linha').css({'width':'90px'});
	rNrctachq.addClass('rotulo-linha').css({'width':'90px'});
	
	rNmemichq.addClass('rotulo').css({'width':'160px'});
	rNrcpfchq.addClass('rotulo').css({'width':'160px'});
	
	
	//Campos
	cCdcmpchq.css({'width':'50px'}).attr('maxlength','3').setMask('INTEGER','zzz','','');
	cCdbanchq.css({'width':'50px'}).attr('maxlength','3').setMask('INTEGER','zzz','','');
	cCdagechq.css({'width':'100px'}).attr('maxlength','4').setMask('INTEGER','zzzz','','');
	cNrctachq.css({'width':'110px'}).attr('maxlength','13').setMask('INTEGER', 'zzz.zzz.zzz.9', '.', '');
	
	cNmemichq.css({'width':'400px'}).attr('maxlength','60').setMask("STRING",60,charPermitido(),"");
	cNrcpfchq.css({'width':'150px'}).attr('maxlength','14').setMask('INTEGER', 'zzzzzzzzzzzzzz', '', '');
		
	cTodosEmitente.desabilitaCampo();

	highlightObjFocus( $('#frmEmitente') );

	cCdcmpchq.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cCdbanchq.focus();
			return false;
		} 
	});	
	
	cCdbanchq.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cCdagechq.focus();
			return false;
		} 
	});	
	
	cCdagechq.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cNrctachq.focus();
			return false;
		} 
	});	
	
	cNrctachq.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			buscaEmitente();
			return false;
		} 
	});	
	
	cNmemichq.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cNrcpfchq.focus();
			return false;
		} 
	});	
	
	cNrcpfchq.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			solicitaConfirmacao();
			return false;
		} 

	});	
		
	layoutPadrao();
	return false;	
}

function solicitaConfirmacao() {
  showConfirmacao('Confirma a execu&ccedil;&atilde;o da Opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','controlaOperacao()',"",'sim.gif','nao.gif');
}


function liberaBusca(){
	
	if ( cCddopcao.hasClass('campoTelaSemBorda')  ) { return false; }	
	
	$('#frmEmitente').css({'display':'block'});
	$('#divBotoes').css({'display':'block'});
	
	cTodosEmitente.habilitaCampo();
	
	cCddopcao.desabilitaCampo();
	cCdcmpchq.focus();
	return false;
}

function btnVoltar() {
	estadoInicial();
	return false;
}

function buscaEmitente() {
	
	showMsgAguardo("Aguarde, Consultando Dados do Emitente...");
	
	var cdcmpchq = normalizaNumero(cCdcmpchq.val());
	var cdbanchq = normalizaNumero(cCdbanchq.val());
	var cdagechq = normalizaNumero(cCdagechq.val());
	var nrctachq = normalizaNumero(cNrctachq.val());
	
	var cddopcao = cCddopcao.val();
	
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/mancec/busca_emitente.php', 
		data    :
				{ cddopcao	: cddopcao,	
				  cdcmpchq  : cdcmpchq,
				  cdbanchq  : cdbanchq,
				  cdagechq  : cdagechq,
				  nrctachq	: nrctachq,			
				  redirect: 'script_ajax'
				  
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N;&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#cdcmpchq\',\'#frmEmitente\').focus();');
				},
		success : function(response) { 
					hideMsgAguardo();
					
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {

							eval(response);	
							
							cTodosEmitente.desabilitaCampo();

							if ( cddopcao == 'E' ) {
								trocaBotao('Excluir');
							}
							
							if ( cddopcao == 'A' ) {						
								trocaBotao('Alterar');
								cNmemichq.habilitaCampo();
								cNrcpfchq.habilitaCampo();
							}
							
							if ( cddopcao == 'I' ) {
								trocaBotao('Incluir');
								cNmemichq.habilitaCampo();
								cNrcpfchq.habilitaCampo();
							}	
							
							$('#divDadosEmitente').css({'display':'block'});
							
							if ( cddopcao == 'C' ) {
							  trocaBotao('');
							}
							
							cNmemichq.focus();

							return false;
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#cdcmpchq\',\'#frmEmitente\').focus();');
						}
					} else {
						try {
							eval( response );
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#cdcmpchq\',\'#frmEmitente\').focus();');
						}
					}
					
				}
	}); 
}

function controlaOperacao() {	

	var cdcmpchq = normalizaNumero(cCdcmpchq.val());
	var cdbanchq = normalizaNumero(cCdbanchq.val());
	var cdagechq = normalizaNumero(cCdagechq.val());
	var nrctachq = normalizaNumero(cNrctachq.val());
	
	var cddopcao = cCddopcao.val();
	
	var nmemichq = cNmemichq.val();
	var nrcpfchq = normalizaNumero(cNrcpfchq.val());
		
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/mancec/manter_rotina.php', 
		data    :
				{ cddopcao	: cddopcao,	
				  cdcmpchq  : cdcmpchq,
				  cdbanchq  : cdbanchq,
				  cdagechq  : cdagechq,
				  nrctachq	: nrctachq,	
				  nmemichq  : nmemichq,
				  nrcpfchq  : nrcpfchq,
				  redirect: 'script_ajax'
				  
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#cdcmpchq\',\'#frmEmitente\').focus();');
				},
		success : function(response) { 
					hideMsgAguardo();
					
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							eval(response);

							return false;
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#cdcmpchq\',\'#frmEmitente\').focus();');
						}
					} else {
						try {
							eval( response );
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#cdcmpchq\',\'#frmEmitente\').focus();');
						}
					}
					
				}
	}); 
}

function trocaBotao( botao ) {
	
	$('#divBotoes','#frmEmitente').html('');
	
	$('#divBotoes','#frmEmitente').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>');
	
	if ( botao == 'Emitente') {
		$('#divBotoes','#frmEmitente').append('&nbsp;<a href="#" class="botao" onClick="buscaEmitente()" return false;" >Prosseguir</a>');
		return false;
	}

	if ( botao != '') {
		$('#divBotoes','#frmEmitente').append('&nbsp;<a href="#" class="botao" onClick="solicitaConfirmacao()" return false;" >'+botao+'</a>');
	}
	
	return false;
}


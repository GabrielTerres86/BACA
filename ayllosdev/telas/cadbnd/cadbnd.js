/*!
 * FONTE        : cadbnd.js
 * CRIA��O      : Lucas R.
 * DATA CRIA��O : 02/05/2013
 * OBJETIVO     : Biblioteca de fun��es da tela CADBND
 * --------------
 * ALTERA��ES   : 
 * --------------
 *
 */
 
 var nrdcontaOld 	= ''; // Vari�vel auxiliar para guardar o n�mero da conta passada
 var nmprimtl       = '';
 var operacao 		= '';
 var nrcpfcgc       = 0; 
 var arrayAutori   	= new Array();
 
$(document).ready(function() {

	estadoInicial();
	
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	
	return false;
	
	
});
 
 function estadoInicial() {
	
	$('#frmCab').css({'display':'block'});
	
	hideMsgAguardo();
	bloqueiaFundo( $('#divTela') );

	formataCabecalho();
	
	$('#nrdconta','#frmCab').val('');
	$('#nmprimtl','#frmCab').val('');
	$('#nrcpfcgc','#frmCab').val('');
	$('#cddopcao','#frmCab').focus();
		
	$('#divBotoes', '#divTela').css({'display':'none'});
		
	removeOpacidade('divTela');
	
	unblockBackground();
	hideMsgAguardo();
	
	$('input,select', '#frmCab').removeClass('campoErro');
		 
    layoutPadrao();
	$('.conta').trigger('blur');
	controlaPesquisas();
	removeOpacidade('divTela');
	return false;
		 
 }
 
function controlaOperacao( novaOp ) {
			
	operacao = ( typeof novaOp != 'undefined' ) ? novaOp : operacao;
	
	// Carrega dados da conta atrav�s de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/cadbnd/principal.php', 
		data    : 
				{ 
					nrdconta: nrdconta,	
					cddopcao: operacao,
					redirect: 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) { 
					hideMsgAguardo();
					showError('error','N�o foi poss�vel concluir a requisi&ccedil;&atilde;o.','Alerta - Cadbnd','$(\'#nrdconta\',\'#frmCab\').focus()');
				},
		success : function(response) { 
					hideMsgAguardo();
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							$('#divTela').html(response);
							return false;
						} catch(error) { 
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
						}
					} 
				}
	}); 
		
}

 function consultaInicial() { 	
	
	if ( divError.css('display') == 'block' ) { return false; }
	if( $('#nrdconta','#frmCab').hasClass('campoTelaSemBorda') ){ return false; }
				
	// Armazena o n�mero da conta na vari�vel global
	nrdconta = normalizaNumero( $('#nrdconta','#frmCab').val() );
	nrdcontaOld = nrdconta;

	// Verifica se o n�mero da conta � vazio
	if ( nrdconta == '' ) { return false; }
		
	// Verifica se a conta � v�lida
	if ( !validaNroConta(nrdconta) ) { 
		showError('error','Conta/dv inv�lida.','Alerta - Cadbnd','focaCampoErro(\'nrdconta\',\'frmCab\');'); 
		return false; 
	}
	
	hideMsgAguardo();		
	showMsgAguardo( 'Aguarde, buscando dados ...' );
	
	// Se chegou at� aqui, a conta � diferente do vazio e � v�lida, ent�o realizar a opera��o desejada
	controlaOperacao( $('#cddopcao','#frmCab').val() );
			
}	

function formataCabecalho() {
	
	var nomeForm    = 'frmCab';
	highlightObjFocus( $('#frmCab') );

	var rNmprimtl = $('label[for="nmprimtl"]','#'+nomeForm);	
	var rOpcao    = $('label[for="cddopcao"]','#'+nomeForm);	
	var rNrConta  = $('label[for="nrdconta"]','#'+nomeForm);
    var rNrcpfcgc = $('label[for="nrcpfcgc"]','#'+nomeForm);	
	var cTodos	  = $('input[type="text"],select','#'+nomeForm);
	var cOpcao    = $('#cddopcao','#'+nomeForm);
	var cNrConta  = $('#nrdconta','#'+nomeForm);
    var cNmprimtl = $('#nmprimtl','#'+nomeForm);
	var cNrcpfcgc = $('#nrcpfcgc','#'+nomeForm);
		
	rNmprimtl.addClass('rotulo-linha');
	rOpcao.addClass('rotulo').css('width','40px');
	rNrConta.addClass('rotulo').css('width','40px');
	rNrcpfcgc.addClass('rotulo').css('width','60px');
	cTodos.desabilitaCampo();
	cOpcao.css('width','490px');
	cNrConta.addClass('conta pesquisa').css('width','80px');
	cNmprimtl.addClass('descricao').css('width','355px');
	cNrcpfcgc.addClass('cpf cnpj').css('width','125px');
			
	if ( $.browser.msie ) {
		rNrConta.addClass('rotulo').css('width','40px');
	}
	
		cNrConta.habilitaCampo();
		cOpcao.habilitaCampo();
				
		cOpcao.unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				cNrConta.focus();
				return false;
			}	
		});	

		cNrConta.unbind('keypress').bind('keypress', function(e) { 	
		 	if ( e.keyCode == 13 || e.keyCode == 9 ) {		
				consultaInicial();
                return false;
			} 
		
		});		
			 
}

function cria_dados_totvs() {

	var cddopcao = $('#cddopcao','#frmCab').val();
			
	hideMsgAguardo();		
	showMsgAguardo( 'Aguarde, opera��o em andamento ...' );
	
	// Carrega dados da conta atrav�s de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/cadbnd/cria_dados_totvs.php', 
		data    : 
				{   nmdatela: "CADBND",
					nrdconta: nrdconta,	
					cddopcao: cddopcao,
					redirect: 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) { 
					hideMsgAguardo();
					showError('error','N�o foi poss�vel concluir a requisi&ccedil;&atilde;o.','Alerta - Cadbnd','$(\'#nrdconta\',\'#frmCab\').focus()');
				},
		success : function(response) { 
					hideMsgAguardo();
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							$('#divTela').html(response);
							return false;
						} catch(error) { 
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
						}
					}
					// se executou rotina sem erros volta a tela inicial
					estadoInicial();
				}
	}); 
	
}

function controlaPesquisas() {
	
	/*---------------------*/
	/*  CONTROLE CONTA/DV  */
	/*---------------------*/
	var linkConta = $('a:eq(0)','#frmCab');

	if ( linkConta.prev().hasClass('campoTelaSemBorda') ) {		
		linkConta.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {

		linkConta.prev().unbind('blur').bind('blur', function() { 
			controlaPesquisas();
			return false;
		});	
	
		linkConta.css('cursor','pointer').unbind('click').bind('click', function() {			
			mostraPesquisaAssociado('nrdconta','frmCab');
		});
	}
			
}
			
function btnVoltar() {
	estadoInicial();
	return false;		
}	

function btnContinuar() {
	
	showConfirmacao('Confirma opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','cria_dados_totvs();','','sim.gif','nao.gif');
	return false;
	
}

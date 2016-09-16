/*!
 * FONTE        : domins.js
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 24/05/2011
 * OBJETIVO     : Biblioteca de funções da tela DOMINS
 * --------------
 * ALTERAÇÕES   :
 * 29/06/2012 - Jorge        (CECRED) : Ajuste para novo esquema de impressao em funcao Gera_Impressao()
 * 29/11/2012 - Daniel       (CECRED) : Incluso efeito de fundo para campos focados, controle exibição
 *                                      de botões e efeito fade.  (Daniel).
 * --------------
 */

// Definição de algumas variáveis globais 
var operacao 		= ''; // Armazena a operação corrente da tela DOMINS
var nrdconta 		= 0; // Armazena o Número da Conta/dv
var idseqttl		= 0; // Armazenao o Numero do Titular
var nomeForm		= 'frmDomins';
var nomeCabForm		= 'frmCabDomins';
var nrJanelas 		= 0; // Armazena o número de janelas para as impressões

$(document).ready(function() {
	estadoInicial();	

});

function manterRotina( novaOp ) {

	operacao = ( typeof novaOp != 'undefined' ) ? novaOp : operacao;
		
	hideMsgAguardo();		

	var mensagem = '';
	
	switch (operacao) {	
		case 'C1': mensagem = 'Aguarde, buscando os dados ...'; break;
		case 'A1': mensagem = 'Aguarde, atualizando os dados ...'; break;
		default: estadoInicial(); return false; break;
	}
	
	showMsgAguardo( mensagem );	
	
	// titular
	nrdconta = normalizaNumero($('#nrdconta', '#frmCabDomins').val());
	idseqttl = normalizaNumero($('#idseqttl', '#frmCabDomins').val());
	nrbenefi = normalizaNumero($('#nrbenefi', '#frmDomins').val());
	nrrecben = normalizaNumero($('#nrrecben', '#frmDomins').val());
	
	$.ajax({		
			type  : 'POST',
			async : true ,
			url   : UrlSite + 'telas/domins/manter_rotina.php', 		
			data: {
				nrdconta: nrdconta,	
				idseqttl: idseqttl,
				nrbenefi: nrbenefi,
				nrrecben: nrrecben,
				operacao: operacao,
				redirect: 'script_ajax'
			}, 
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
			},
			success: function(response) {
				try {
					eval(response);
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		});

	return false;	
	
}       	

function controlaLayout() {

	$('#divTela').fadeTo(0,0.1);
	$('#frmCabDomins').fadeTo(0,0.1);
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'0 3px 5px 3px'});
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});

	formataCabecalho();	
	
	// label
	rNmrecben  	= $('label[for="nmrecben"]', '#'+nomeForm);
	rNrbenefi  	= $('label[for="nrbenefi"]', '#'+nomeForm);
	rNrrecben  	= $('label[for="nrrecben"]', '#'+nomeForm);
	rCdorgpag  	= $('label[for="cdorgpag"]', '#'+nomeForm);
	rNrnovcta  	= $('label[for="nrnovcta"]', '#'+nomeForm);
	
	rNmrecben.addClass('rotulo').css({'width':'230px'});
	rNrbenefi.addClass('rotulo').css({'width':'230px'});
	rNrrecben.addClass('rotulo-linha').css({'width':'95px'});
	rCdorgpag.addClass('rotulo-linha').css({'width':'95px'});
	rNrnovcta.addClass('rotulo').css({'width':'230px'});
	
	// campos
	cTodos 		= $('input','#'+nomeForm);
	cNmrecben  	= $('#nmrecben', '#'+nomeForm);
	cNrbenefi  	= $('#nrbenefi', '#'+nomeForm);
	cNrrecben  	= $('#nrrecben', '#'+nomeForm);
	cCdorgpag  	= $('#cdorgpag', '#'+nomeForm);
	cNrnovcta  	= $('#nrnovcta', '#'+nomeForm);
	
	cTodos.addClass('campo');
	cNmrecben.css({'width':'341px'}).attr('maxlength','28');
	cNrbenefi.css({'width':'120px'}).attr('maxlength','10');
	cNrrecben.css({'width':'120px'}).attr('maxlength','11');
	cCdorgpag.css({'width':'120px'}).attr('maxlength','6');
	cNrnovcta.css({'width':'120px'}).addClass('conta');
	
	// ie
	if ( $.browser.msie ) {	
		cNrrecben.css({'width':'123px'});
		cCdorgpag.css({'width':'123px'});
	}

	switch(operacao) {
		default:
			cTodos.limpaFormulario();
			cTodos.desabilitaCampo();
		break;
	}
	
	layoutPadrao();
	$('.conta').trigger('blur');
	controlaPesquisas();
	removeOpacidade('frmCabDomins');
	removeOpacidade('divTela');

	return false;
	
}

function formataCabecalho() {

	// label
	rNrdConta  	= $('label[for="nrdconta"]','#'+nomeCabForm);	
	rIdseqttl	= $('label[for="idseqttl"]','#'+nomeCabForm);	
	rCdagenci	= $('label[for="cdagenci"]','#'+nomeCabForm);	
	rNmresage	= $('label[for="nmresage"]','#'+nomeCabForm);	

	rNrdConta.addClass('rotulo');
	rIdseqttl.addClass('rotulo-linha');
	rCdagenci.addClass('rotulo-linha');
	rNmresage.addClass('rotulo-linha');
	
	// campo
	cTodos	  	= $('input,select','#'+nomeCabForm);
	cNrdConta  	= $('#nrdconta','#'+nomeCabForm);
	cIdseqttl   = $('#idseqttl','#'+nomeCabForm);	
	cCdagenci   = $('#cdagenci','#'+nomeCabForm);	
	cNmresage   = $('#nmresage','#'+nomeCabForm);	

	cTodos.desabilitaCampo();
	cNrdConta.addClass('conta pesquisa').css('width','75px');
	cIdseqttl.css('width','280px');
	cCdagenci.addClass('pesquisa').css('width','30px');
	cNmresage.css('width','100px');
	
//	if ( $.browser.msie ) {
//		cNrdConta.css('width','75px');
//	}	

	if ( operacao == '' ) {	

		cTodos.limpaFormulario();
		cIdseqttl.html('');
		cNrdConta.habilitaCampo();
		cIdseqttl.habilitaCampo();
		nrdconta == 0 ? cNrdConta.val('') : cNrdConta.val(nrdconta);
		
		// Se pressionar alguma tecla no campo numero da conta, verificar a tecla pressionada e toda a devida ação
		cNrdConta.unbind('keypress').bind('keypress', function(e) { 	
		
			if ( divError.css('display') == 'block' ) { return false; }		
			
			// Se é a tecla ENTER, verificar numero conta e realizar as devidas operações
			if ( e.keyCode == 13 ) {		
				// Armazena o número da conta na variável global
				nrdconta = normalizaNumero( $(this).val() );
												
				// Verifica se o número da conta é vazio
				if ( nrdconta == '' ) { return false; }
				
				// Verifica se a conta é válida
				if ( !validaNroConta(nrdconta) ) { 
					showError('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'nrdconta\','+nomeCabForm+');'); 
					return false; 
				}
				
				// Se chegou até aqui, a conta é diferente do vazio e é válida, então realizar a operação desejada
				cNrdConta.desabilitaCampo();
				montaSelect('b1wgen0059.p','busca_crapttl','idseqttl','idseqttl','idseqttl;nmextttl','','nrdconta;'+nrdconta);
				hideMsgAguardo();

				cIdseqttl.habilitaCampo();
				cIdseqttl.focus();
				$("#btVoltar","#divBotoes").show();
				return false;
			}

		});		
		
		// Se mudar o titular
		
		cIdseqttl.unbind('change').bind('change', function() { 	
			if ( divError.css('display') == 'block' ) { return false; }		
				
			// Armazena o número da conta na variável global
			nrdconta = normalizaNumero( cNrdConta.val() );
			idseqttl = normalizaNumero( $(this).val() );
											
			// Verifica se o número da conta é vazio
			if ( nrdconta == '' || idseqttl == '' ) { return false; }
				
			// Se chegou até aqui, a conta e titular é diferente do vazio e é válida, 
			// então realizar a operação desejada
			cIdseqttl.desabilitaCampo(); 
			manterRotina('C1');
			
			$("#btSalvar","#divBotoes").show();
			$("#btVoltar","#divBotoes").show();
			return false;

		});
		

		// Faz a consulta
		cIdseqttl.next().unbind('click').bind('click', function() { 	
			if ( divError.css('display') == 'block' ) { return false; }		
			if ( cIdseqttl.hasClass('campoTelaSemBorda') ){ return false; }
				
			// Armazena o número da conta na variável global
			nrdconta = normalizaNumero( cNrdConta.val() );
			idseqttl = normalizaNumero( cIdseqttl.val() );
											
			// Verifica se o número da conta é vazio
			if ( nrdconta == '' || idseqttl == '') { return false; }
				
			// Se chegou até aqui, a conta e titular é diferente do vazio e é válida, 
			// então realizar a operação desejada
			cIdseqttl.desabilitaCampo();
			manterRotina('C1');
			return false;

		});
		
	} else {
		cNrdConta.desabilitaCampo();
		
	}


	return false;	
}

function controlaFoco() {
		
		
	if ( operacao == '' ) {
		$('#nrdconta','#'+nomeCabForm).focus()

	} 
	
	cNrbenefi.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }	
		
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				cNrrecben.focus();
				return false;
		}	
	});
	
	cNrrecben.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }	
		
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				manterRotina('A1');
				return false;
		}	
	});

	return false;
}

function controlaPesquisas() {
	
	/*---------------------*/
	/*  CONTROLE CONTA/DV  */
	/*---------------------*/
	var linkConta = $('a:eq(0)','#'+nomeCabForm);

	if ( linkConta.prev().hasClass('campoTelaSemBorda') ) {		
		linkConta.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {

		linkConta.prev().unbind('blur').bind('blur', function() { 
			controlaPesquisas();
			return false;
		});	
	
		linkConta.css('cursor','pointer').unbind('click').bind('click', function() {			
			mostraPesquisaAssociado('nrdconta',nomeCabForm);
			return false;
		});
	}

}

function estadoInicial() {

	$('#frmDomins').fadeTo(0,0.1);
	$('#frmCabDomins').fadeTo(0,0.1);
	
	highlightObjFocus( $('#frmCabDomins') );
	highlightObjFocus( $('#frmDomins') );

	hideMsgAguardo();		
	operacao = '';
	controlaLayout();
	controlaFoco();
	
	$("#divBotoes").css('display','block');
	$("#btSalvar","#divBotoes").hide();
	$("#btVoltar","#divBotoes").hide();
	
	removeOpacidade('frmCabDomins');
	removeOpacidade('frmDomins');
	
	
	
	return false;
	
}

function Gera_Impressao() {	
	
	var action = UrlSite + 'telas/domins/imprimir_dados.php';

	$('#sidlogin','#frmDomins').remove();			
	
	$('#frmDomins').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '" />');	
	
	// Configuro o formulário para posteriormente submete-lo
	$('input, select','#frmDomins').habilitaCampo();	
	
	carregaImpressaoAyllos("frmDomins",action,"estadoInicial();");	
	
}

function VerificaConta() {

	if ( divError.css('display') == 'block' ) { return false; }		
	
	if ( $('#nrdconta', '#frmCabDomins').hasClass('campoTelaSemBorda') ){ return false;}
				
	// Armazena o número da conta na variável global
	nrdconta = normalizaNumero( $('#nrdconta', '#frmCabDomins').val() );
									
	// Verifica se o número da conta é vazio
	if ( nrdconta == '' ) { return false; }
	
	// Verifica se a conta é válida
	if ( !validaNroConta(nrdconta) ) { 
		showError('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'nrdconta\','+nomeCabForm+');'); 
		return false; 
	}
	
	// Se chegou até aqui, a conta é diferente do vazio e é válida, então realizar a operação desejada
	$('#nrdconta', '#frmCabDomins').desabilitaCampo();
	montaSelect('b1wgen0059.p','busca_crapttl','idseqttl','idseqttl','idseqttl;nmextttl','','nrdconta;'+nrdconta);
	hideMsgAguardo();
	
	$('#idseqttl', '#frmCabDomins').habilitaCampo();
	$('#idseqttl', '#frmCabDomins').focus();
	return false;
	
}

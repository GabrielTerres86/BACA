/*!
 * FONTE        : dctror.js
 * CRIAÇÃO      : Gabriel Capoia e Rogérius Militão (DB1) 
 * DATA CRIAÇÃO : 10/06/2011
 * OBJETIVO     : Biblioteca de funções da tela DCTROR
 * --------------
 * ALTERAÇÕES   :
 * 000: [29/06/2012] Jorge Hamaguchi  (CECRED): Ajuste para novo esquema de impressao em funcao Gera_Impressao()
 * 001: [03/06/2016] Lucas Ranghetti  (CECRED): Incluir validação de agencia e de conta migrada (Lucas Ranghetti #449707)
 * 002: [24/06/2016] Lucas Ranghetti  (CECRED): Ajustado para chamar formulario de impressão para Opcao "A" (#448006 )
 * 003: [04/11/2017] Jonata           (RKAM)  : Ajuste para tela ser chamada atraves da tela CONTAS > IMPEDIMENTOS (P364)
 * 004: [15/12/2017] Jonata           (RKAM)  : Correção controle de acesso a tela quando vinda da tela CONTAS > IMPEDIMETNOS (P364)
 * 005: [11/04/2017] Permitir acessar o Ayllos mesmo vindo do CRM. (Jaison/Andrino)
 * 006: [16/01/2018] Aumentado tamanho do campo de senha para 30 caracteres. (PRJ339 - Reinert)
 * --------------
 */

// Definição de algumas variáveis globais 
var operaaux 		= '';
var operacao 		= ''; // Armazena a operação corrente da tela DCTROR
var controle		= '';	

var cddopcao		= '';
var tptransa 		= 0 ;
var nrdconta 		= 0 ; // Armazena o Número da Conta/dv
var idseqttl		= 1 ;

var aux_cdagechq	= ''; // Armazena o retorno verif-agechq da consulta tipo 2 no manter_rotina.php
var aux_dtemscor	= ''; // Armazena o retorno valida-dados da consulta tipo 2 no manter_rotina.php
var aux_cdhistor	= ''; // Armazena o retorno valida-dados da consulta tipo 2 no manter_rotina.php
var aux_nrfinchq	= ''; // Armazena o retorno valida-dados da consulta tipo 2 no manter_rotina.php
var aux_dssitdtl    = '';
var aux_cdsitdtl	= '';
var aux_altagchq    = 0; // Armazena se deve alerar campo agencia (Contas migradas)

var aux_tpatlcad	= '';
var aux_msgatcad	= '';
var aux_chavealt	= '';
var aux_msgrecad	= '';

var nmdcampo		= ''; // Armazena o retorno valida-ctachq da consulta tipo 2 no manter_rotina.php
var tplotmov		= ''; // Armazena o retorno valida-hist da alteração tipo 2 no manter_rotina.php
var dsdctitg		= ''; // Armazena o retorno valida-hist da alteração tipo 2 no manter_rotina.php

var arrayDctror   	= new Array();
var arrayCustdesc	= new Array();		

var cheques			= '';
var custdesc		= '';
var criticas		= '';
var contra			= '';
//var aux_dtvalcor    = '';
//var aux_flprovis    = 'FALSE';

var nrJanelas		= 0;
var operauto		= '';

//Formulários
var formCab   		= 'frmCab';
var formDados 		= 'frmDctror';

//Labels/Campos do cabeçalho
var rOpcao, rTipo, rConta, rNome, cTodos, cOpcao, cTipo, cConta, cNome ;

//Labels/Campos do formulário de dados
var rSituacao, rDtEmiss, rCdHistor, rBanco, rAgencia, rContraCheque,
    rNrChequeIni, rNrChequeFim, cSituacao, cDtEmiss, cCdHistor, cBanco, 
	cAgencia, cContraCheque, cNrChequeIni, cNrChequeFim, cDtValCor, rDtValCor,
	cflprovis, rFlProvis;


$(document).ready(function() {
	estadoInicial()	
});


// estado
function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);

	$('#btSalvar','#divTela').remove();
	$('#btConcluir','#divTela').remove();
	
	fechaRotina($('#divRotina'));
	setGlobais();
 
 	$('input', '#'+ formCab ).limpaFormulario();
	$('input', '#'+ formDados ).limpaFormulario();
	$('#divTabDctror').css('display','none');
	 
	atualizaSeletor();	
	formataCabecalho();
	controlaLayout();

	$('input, select','#'+ formCab ).removeClass('campoErro');
	$('input, select','#'+ formDados ).removeClass('campoErro');

	removeOpacidade('divTela');
	return false;
}

function estadoCabecalho() {

	hideMsgAguardo();
	$('#divTela').fadeTo(0,0.1);

	$('#btSalvar','#divTela').remove();
	$('#btConcluir','#divTela').remove();
	
	fechaRotina($('#divRotina'));
	setGlobais();

	$('input, select', '#'+formCab).habilitaCampo();
	$('input', '#'+formDados).desabilitaCampo().limpaFormulario();

	cConta.focus();
	cNome.desabilitaCampo();

	$('#divTabDctror').css('display','none');

	removeOpacidade('divTela');
	
	if (executandoImpedimentos){	
	
		cTipo.val('0');
		cOpcao.val('E').desabilitaCampo();
		
	} 
	
	return false;
}


// controle
function atualizaSeletor(){

	rOpcao = $('label[for="cddopcao"]','#'+formCab);
	rTipo  = $('label[for="tptransa"]','#'+formCab);
	rConta = $('label[for="nrdconta"]','#'+formCab);
	rNome  = $('label[for="nmprimtl"]','#'+formCab);
	
	cTodos = $('input[type="text"],select','#'+formCab);
	cOpcao = $('#cddopcao','#'+formCab);
	cTipo  = $('#tptransa','#'+formCab);
	cConta = $('#nrdconta','#'+formCab);
	cNome  = $('#nmprimtl','#'+formCab);
	
	rSituacao     = $('label[for="cdsitdtl"]','#'+formDados);
	rDtEmiss      = $('label[for="dtemscor"]','#'+formDados);
	rCdHistor     = $('label[for="cdhistor"]','#'+formDados);
	rBanco        = $('label[for="cdbanchq"]','#'+formDados);
	rAgencia      = $('label[for="cdagechq"]','#'+formDados);
	rContraCheque = $('label[for="nrctachq"]','#'+formDados);
	rNrChequeIni  = $('label[for="nrinichq"]','#'+formDados);
	rNrChequeFim  = $('label[for="nrfinchq"]','#'+formDados);
	rDtValCor     = $('label[for="dtvalcor"]','#'+formDados);
	rFlProvis     = $('label[for="flprovis"]','#'+formDados);
	
	cTodos_1      = $('input[type="text"],select','#'+formDados);
	cSituacao     = $('#cdsitdtl','#'+formDados);
	cDSSituacao   = $('#dssitdtl','#'+formDados);
	cDtEmiss      = $('#dtemscor','#'+formDados);
	cDtValCor     = $('#dtvalcor','#'+formDados);
	cflprovis     = $('#flprovis','#'+formDados);
	cCdHistor     = $('#cdhistor','#'+formDados);
	cBanco        = $('#cdbanchq','#'+formDados);
	cAgencia      = $('#cdagechq','#'+formDados);
	cContraCheque = $('#nrctachq','#'+formDados);
	cNrChequeIni  = $('#nrinichq','#'+formDados);
	cNrChequeFim  = $('#nrfinchq','#'+formDados);

	
	return false;
}

function controlaOperacao( novaOp ) {
				
	operacao = ( typeof novaOp != 'undefined' ) ? novaOp : operacao;
	
	var mensagem = 'Aguarde, buscando dados ...';
	
	showMsgAguardo( mensagem );	
	
	// Carrega dados da conta através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/dctror/principal.php', 
		data    : 
				{ 
					operacao	: operacao,		
					controle	: controle,
					cddopcao	: cddopcao,					
					tptransa	: tptransa, 
					nrdconta	: nrdconta, 
					redirect	: 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
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
					} else {
						try {
							eval( response );
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
						}
					}
				}
	});

	return false;	
}

function manterRotina() {

	hideMsgAguardo();		

	var mensagem = '';

	// Situacao
	var cdsitdtl = normalizaNumero( cSituacao.val() 	);
	var dtemscch = cDtEmiss.val() 						;
	var dtemscor = cDtEmiss.val() 						;
	var dtvalcor = cDtValCor.val() 						;
	var flprovis = cflprovis.val()                      ;

	// Banco
	var cdhistor = normalizaNumero( cCdHistor.val()		);
	var cdbanchq = normalizaNumero( cBanco.val() 		);
	var cdagechq = normalizaNumero( cAgencia.val() 		);
	var nrctachq = normalizaNumero( cContraCheque.val() );
	var nrinichq = normalizaNumero( cNrChequeIni.val() 	);
	var nrfinchq = normalizaNumero( cNrChequeFim.val() 	);

	var camposDc  = '';
	var camposDc1 = '';
	camposDc  = retornaCampos( arrayDctror, '|' );
	camposDc1 = retornaCampos( arrayCustdesc, '|' );

	var dadosDc  = '';
	var dadosDc1 = '';
	dadosDc   = retornaValores( arrayDctror, ';', '|',camposDc );
	dadosDc1  = retornaValores( arrayCustdesc, ';', '|',camposDc1 );

	switch (operacao) {
		// Consulta
		case 'C21': mensagem = 'Aguarde, validando ...'; break;	
		case 'C22': mensagem = 'Aguarde, validando ...'; break;	
		case 'C23': mensagem = 'Aguarde, buscando ...'; break;	
		
		// Aleração
		case 'A21': mensagem = 'Aguarde, buscando ...'; break;	
		case 'A22': mensagem = 'Aguarde, validando ...'; break;	
		case 'A23': mensagem = 'Aguarde, validando ...'; break;	
		case 'A24': mensagem = 'Aguarde, buscando ...'; break;	
		case 'A25': mensagem = 'Aguarde, validando ...'; break;	
		case 'A26': mensagem = 'Aguarde, gravando ...'; break;	

		// Exclusão
		case 'E11': mensagem = 'Aguarde, gravando dados ...'; break; 	
		case 'E31': mensagem = 'Aguarde, gravando dados ...'; break;	
		case 'E21': mensagem = 'Aguarde, buscando ...'; break;	
		case 'E22': mensagem = 'Aguarde, validando ...'; break;	
		case 'E23': mensagem = 'Aguarde, validando ...'; break;	
		case 'E24': mensagem = 'Aguarde, buscando ...'; break;	
		case 'E25': mensagem = 'Aguarde, validando ...'; break;	
		case 'E26': mensagem = 'Aguarde, gravando dados ...'; break;	

		// Inclusão
		case 'I11': mensagem = 'Aguarde, gravando dados...'; break;	
		case 'I31': mensagem = 'Aguarde, gravando dados...'; break;	
		case 'I21': mensagem = 'Aguarde, buscando ...'; break;	
		case 'I22': mensagem = 'Aguarde, validando ...'; break;	
		case 'I23': mensagem = 'Aguarde, validando ...'; break;	
		case 'I24': mensagem = 'Aguarde, buscando ...'; break;	
		case 'I25': mensagem = 'Aguarde, validando ...'; break;	
		case 'I26': mensagem = 'Aguarde, gravando dados ...'; break;	
		case 'I27': mensagem = 'Aguarde, validando ...'; break;	
		
		default: return false; break;
	}

	showMsgAguardo( mensagem );	

	if (aux_flprovis == 'FALSE') {
		aux_imprimir = 'SIM';
	}
	
	$.ajax({		
			type  : 'POST',
			async : true ,
			url   : UrlSite + 'telas/dctror/manter_rotina.php', 		
			data: {
				operacao	: operacao,		
				controle	: controle,
				dtvalcor    : aux_dtvalcor,
				flprovis    : aux_flprovis,
				
				// Cabecalho
				cddopcao	: cddopcao,				
				tptransa	: tptransa, 
				nrdconta	: nrdconta,
				
				// Situacao
				cdsitdtl	: cdsitdtl,
				dtemscch	: dtemscch,
				dtemscor	: dtemscor,
				
				// Banco
				cdhistor	: cdhistor,				
				cdbanchq	: cdbanchq,
				cdagechq	: cdagechq,
				nrctachq	: nrctachq,
				nrinichq	: nrinichq,
				nrfinchq	: nrfinchq,
				
				// Coordenador
				operauto	: operauto,
				
				cheques		: cheques,
				tplotmov	: tplotmov,
				dsdctitg	: dsdctitg,
				camposDc	: camposDc,
				dadosDc		: dadosDc,				
				camposDc1	: camposDc1,
				dadosDc1	: dadosDc1,				
				redirect	: 'script_ajax'
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

	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('#divBotoes').css({'text-align':'center','padding-top':'5px'});
			
	rSituacao.addClass('rotulo').css('width','90px');  
	rDtEmiss.css('width','110px');
	
	rCdHistor.addClass('rotulo').css('width','90px');
	rContraCheque.addClass('rotulo').css('width','90px');
	
	rAgencia.css('width','124px');
	rNrChequeFim.css('width','124px');

	rNrChequeIni.css('width','125px');
	rBanco.css('width','125px');
		
	cSituacao.addClass('inteiro').css('width','35px').attr('maxlength','1');
	cDSSituacao.addClass('alphanum').css('width','170px');
	cDtEmiss.addClass('data').css('width','119px').attr('maxlength','50');
	cDtValCor.addClass('data').css('width','119px').attr('maxlength','50');
	
	cCdHistor.addClass('pesquisa').css('width','48px').setMask('INTEGER','zzzz','','');
	cBanco.css('width','60px').setMask('INTEGER','zzz','','');
	cAgencia.css('width','60px').setMask('INTEGER','zzzz','','');
	cContraCheque.css('width','65px').setMask('INTEGER','zzzz.zzz.z','.','');
	cNrChequeIni.addClass('cheque').css('width','60px');
	cNrChequeFim.addClass('cheque').css('width','60px');

	cTodos_1.desabilitaCampo();

	// Se pressionar alguma tecla no campo BANCO, verificar a tecla pressionada e toda a devida ação
	cBanco.unbind('keypress').bind('keypress', function(e) { 	
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			cBanco.desabilitaCampo();
			manterRotina();
			return false;			
		} 
	});		

	cAgencia.unbind('keypress').bind('keypress', function(e) { 	
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			if(!validaAgencia()){
				cContraCheque.desabilitaCampo();
				cNrChequeIni.desabilitaCampo();
				cNrChequeFim.desabilitaCampo();
			}else{
				cContraCheque.habilitaCampo().focus();
				cNrChequeIni.habilitaCampo();
				cNrChequeFim.habilitaCampo();
				cAgencia.desabilitaCampo();
			}
			return false;
		} 
	});		

	// Se pressionar alguma tecla no campo CONTRA CHEQUE, verificar a tecla pressionada e toda a devida ação
	cContraCheque.unbind('keypress').bind('keypress', function(e) { 	
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			cNrChequeIni.focus();
			return false;			
		} else if ( e.keyCode == 112 && (cddopcao == 'C' || cddopcao == 'A') ) {
			manterRotina();
			return false;
		}
	});		

	// Se pressionar alguma tecla no campo INICIO, verificar a tecla pressionada e toda a devida ação
	cNrChequeIni.unbind('keypress').bind('keypress', function(e) { 	
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( (e.keyCode == 13 || e.keyCode == 112) && (cddopcao == 'C' || cddopcao == 'A') ) {
			$(this).desabilitaCampo();
			manterRotina();
			return false;			
		} else if ( e.keyCode == 13 && (cddopcao == 'E' || cddopcao == 'I') ) {
 			cNrChequeFim.focus();
			return false;			
		}
	});		

	// Se pressionar alguma tecla no campo FIM, verificar a tecla pressionada e toda a devida ação
	cNrChequeFim.unbind('keypress').bind('keypress', function(e) { 	
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			cNrChequeFim.desabilitaCampo();
			manterRotina();
			return false;			
		} 
	});		


	// Se pressionar alguma tecla no campo INICIO, verificar a tecla pressionada e toda a devida ação
	cDtEmiss.unbind('keyup').bind('keyup', function(e) { 	
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( e.keyCode == 13 ) {
			cDtEmiss.desabilitaCampo();
			cCdHistor.habilitaCampo().focus();	
			controle = '2';
			operacao = operacao.substr(0,2) + controle;
			controlaPesquisas();
		}
	});			
	
	// Se pressionar alguma tecla no campo HISTORICO, verificar a tecla pressionada e toda a devida ação
	cCdHistor.unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
		
		// Se é a tecla ENTER, 
		if ( cddopcao == 'A' && (e.keyCode == 13 || e.keyCode == 112) ) {
			cCdHistor.desabilitaCampo();
			manterRotina();
			return false;			
		} else if ( e.keyCode == 13 && cddopcao== 'I' ) {
			operacao = 'I27';
			manterRotina();
			
		}		

	});

	// Faz os tratamentos após chamar o manter_rotina.php	
	// Busca os dados e habilita o campo banco
	if ( operacao == 'C20' ) {
		cOpcao.desabilitaCampo();
		cTipo.desabilitaCampo();
		cConta.desabilitaCampo();
		cBanco.habilitaCampo().focus();
		controle = '1';
		operacao = operacao.substr(0,2) + controle;
		trocaBotao('prosseguir');
		
	// Verifica a agencia, pega o valor da agencia e habilita os dois campos: contra cheque e inicio	
	} else if ( operacao == 'C21' || operacao == 'A22' ) {
		operacao == 'A22' ? trocaBotao('prosseguir') : trocaBotao('concluir');
		
		if(cBanco.val() == 85 && cTipo.val() == 2) {
			validaContaMigrada();
		}else{ 
			aux_altagchq = 0;
		}
		
		if(aux_altagchq == 1){
			cAgencia.habilitaCampo().focus();
			cContraCheque.habilitaCampo();
		}else{
			cContraCheque.habilitaCampo().focus();
		 }
		
		cAgencia.val(aux_cdagechq);
		cNrChequeIni.habilitaCampo();
		controle = cddopcao == 'C' ? '2' : '3';
		operacao = operacao.substr(0,2) + controle;
		
	} else if ( operacao == 'C22'  || operacao == 'A23' ) {
		controle = cddopcao == 'C' ? '3' : '4';
		operacao = operacao.substr(0,2) + controle;
		manterRotina();
		return false;
		
	} else if ( operacao == 'C23' || operacao == 'A24' ) {
		cCdHistor.val(aux_cdhistor);
		cDtEmiss.val(aux_dtemscor);
		cNrChequeFim.val(aux_nrfinchq);
		cDtValCor.val(aux_dtvalcor);
		cflprovis.val(aux_flprovis);
		
		if ( operacao == 'C23' ) {
			cBanco.habilitaCampo().focus();
			controle = '1';
			trocaBotao('prosseguir');
			
		} else if ( operacao == 'A24' ) {

			cCdHistor.habilitaCampo().focus();
			controle = '5';			
			trocaBotao('concluir');
		}

		operacao = operacao.substr(0,2) + controle;

	
	} else if ( operacao == 'A20' ) {
		controle = '1';
		operacao = operacao.substr(0,2) + controle;
		manterRotina();
		return false;
		
	} else if ( operacao == 'A21' ) {
		cOpcao.desabilitaCampo();
		cTipo.desabilitaCampo();
		cConta.desabilitaCampo();
		cBanco.habilitaCampo().focus();
		controle = '2';
		operacao = operacao.substr(0,2) + controle;
		trocaBotao('prosseguir');
		
	} else if ( operacao == 'E10' || operacao == 'E30' || operacao == 'I10' || operacao == 'I30') {
		controle = '1';
		operacao = operacao.substr(0,2) + controle;
		showConfirmacao('Confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','manterRotina();','','sim.gif','nao.gif');
		return false;
	
	} else if ( operacao == 'E11' || operacao == 'E31' || operacao == 'I11' || operacao == 'I31' ) {
		cDSSituacao.val(aux_dssitdtl);
		cSituacao.val(aux_cdsitdtl);

		hideMsgAguardo();
	
		if ( aux_msgatcad != '' ) {
			showConfirmacao(aux_msgatcad,'Confirma&ccedil;&atilde;o - Ayllos','revisaoCadastral(aux_chavealt, aux_tpatlcad,\'b1wgen0095.p\',\'\', \'msgSucesso("cConta.focus();");\');','msgSucesso(\'cConta.focus();\');','sim.gif','nao.gif');
		} else {
			msgSucesso('cConta.focus();');
		}
	
		return false;
		
	} else if ( operacao == 'E20' || operacao == 'I20' ) {
		controle = '1';
		operacao = operacao.substr(0,2) + controle;
		manterRotina();
		return false;		

	} else if ( operacao == 'E21' || operacao == 'I21' ) {
		cOpcao.desabilitaCampo();
		cTipo.desabilitaCampo();
		cConta.desabilitaCampo();
		
		if ( cddopcao == 'E' ) {
			cBanco.habilitaCampo().focus();
			controle = '2';
			operacao = operacao.substr(0,2) + controle;
		} else if ( cddopcao == 'I' ) {
			cDtEmiss.habilitaCampo().focus();
		}
		
		trocaBotao('prosseguir');
		
	} else if ( operacao == 'E22' || operacao == 'I22' ) {
		 
		if(cBanco.val() == 85 && cTipo.val() == 2) {
			validaContaMigrada();
		}else{ 
			aux_altagchq = 0;
		}
		
		if(aux_altagchq == 1){
			cAgencia.habilitaCampo().focus();
			cContraCheque.habilitaCampo();
		}else{
			cContraCheque.habilitaCampo().focus();
		}
		
		cAgencia.val(aux_cdagechq);
		cNrChequeIni.habilitaCampo();
		cNrChequeFim.habilitaCampo();
		controle = '3';
		operacao = operacao.substr(0,2) + controle;
		
	} else if ( operacao == 'E23' || operacao == 'I23' ) {
		controle = '4';		
		if ( operacao == 'I23' ) {
			showConfirmacao('Contra-Ordem Provisória?','Confirma&ccedil;&atilde;o - Ayllos','setaFlag(1);','setaFlag(0);','sim.gif','nao.gif');
		}
		operacao = operacao.substr(0,2) + controle;
		if ( operacao == 'E24' ) {
			manterRotina();
		}
		return false;

	} else if ( operacao == 'E24' || operacao == 'I24' ) {
		$('input[type="text"],select', '#'+ formDados + ' fieldset:eq(1)' ).limpaFormulario();
		cDtEmiss.val(aux_dtemscor);
		cDtValCor.val(aux_dtvalcor);
		cflprovis.val(aux_flprovis);		
		
		if ( cddopcao == 'E' ) {
			cBanco.habilitaCampo().focus();
		} else if ( cddopcao == 'I' ) {
			cCdHistor.habilitaCampo().focus();
		}

		montarTabela();
		controle = '2';
		operacao = operacao.substr(0,2) + controle;

	} else if ( operacao == 'E25' || operacao == 'I25' ) {
		controle = '6';
		operacao = operacao.substr(0,2) + controle;
		manterRotina();
		return false;
		
	} else if ( operacao == 'E26' || operacao == 'I26' || operacao == 'A26') {
		
		if ( criticas != '' ) {
			mostraCriticas();
		} else {
			
			if  (aux_imprimir == 'SIM') {
				msgSucesso('Gera_Impressao();');
				
			}
			else {
				msgSucesso('estadoCabecalho();');
			}
		}

		return false;
	}

	hideMsgAguardo();
	layoutPadrao();
	controlaPesquisas();
	return false;
	
}

function formataCabecalho() {
	
	rOpcao.css('width','46px');
	rTipo.addClass('rotulo-linha');
	rConta.addClass('rotulo-linha');
	rNome.addClass('rotulo-linha');
	
	cTodos.desabilitaCampo();
	cOpcao.css('width','33px');
	cTipo.css('width','140px');
	cConta.addClass('conta pesquisa').css('width','66px');
	cNome.addClass('descricao').css('width','234px');
	
	if ( $.browser.msie ) {
		cConta.css('width','65px');
		cNome.css('width','236px');
	}	

	cConta.habilitaCampo();
	cOpcao.habilitaCampo();
	cTipo.habilitaCampo().focus();

			
	// Se clicar no botao OK
	cConta.next().next().unbind('click').bind('click', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( cConta.hasClass('campoTelaSemBorda')  ) { return false; }		

		setGlobais();			
		
		// Armazena o número da conta na variável global
		cddopcao 	= cOpcao.val();
		tptransa 	= cTipo.val();
		nrdconta 	= normalizaNumero( cConta.val() );
											
		// Verifica se o número da conta é vazio
		if ( nrdconta == '' ) { return false; }

		// Verifica se o tipo é válido
		if ( tptransa == '0' ) { 
			showError('error','Tipo de transação errado.','Alerta - Ayllos','focaCampoErro(\'tptransa\',\''+ formCab +'\');'); 
			return false; 
		}
		
		// Verifica se a conta é válida 
		if ( !validaNroConta(nrdconta) ) { 
			showError('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'nrdconta\',\''+ formCab +'\');'); 
			return false; 
		}
		
		controle 		= '0';
		operacao 		= cddopcao + tptransa + controle; 			
		
		// Se chegou até aqui, a conta é diferente do vazio e é válida, então realizar a operação desejada
		controlaOperacao( operacao );
		return false;
			
	});		

	cOpcao.unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		

		// Se é a tecla ENTER, pular para o proximo campo
		if ( e.keyCode == 13  ) {		
			cTipo.focus();
			return false;
		}
	});
	
	cTipo.unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
			
		// Se é a tecla ENTER, pular para o proximo campo
		if ( e.keyCode == 13  ) {		
			cConta.focus();
			return false;
		}
	});
	
	// Se pressionar alguma tecla no campo numero da conta, verificar a tecla pressionada e toda a devida ação
	cConta.unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
			
		// Se é a tecla ENTER, verificar numero conta e realizar as devidas operações
		if ( e.keyCode == 13 || e.keyCode == 112 ) {		
			cConta.next().next().click();
			return false;
		} 
		

	});		

    // Seta os valores caso tenha vindo do CRM
    if ($("#crm_inacesso","#frmCRM").val() == 1) {
        $("#nrdconta","#frmCab").val($("#crm_nrdconta","#frmCRM").val());
    }	
	
	if (executandoImpedimentos){
		
		if (nrdconta != '') {
			
			cTipo.val('0');
			cOpcao.val('E').desabilitaCampo();
			$("#nrdconta","#frmCab").val(nrdconta);
			
		}else{
			nrdconta = 0;
			cOpcao.val('I');
			cTipo.val('0');
		}
	}
	
	layoutPadrao();
	$('.conta').trigger('blur');
	controlaPesquisas();
	return false;
}

function controlaPesquisas() {

	/*---------------------*/
	/*  CONTROLE CONTA/DV  */
	/*---------------------*/
	var linkConta = $('a:eq(0)','#'+ formCab );

	if ( linkConta.prev().hasClass('campoTelaSemBorda') ) {		
		linkConta.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {

		linkConta.prev().unbind('blur').bind('blur', function() { 
			controlaPesquisas();
			return false;
		});	
	
		linkConta.css('cursor','pointer').unbind('click').bind('click', function() {			
			mostraPesquisaAssociado('nrdconta', formCab );
		});
	}

	/*---------------------*/
	/*      HISTORICO      */
	/*---------------------*/
	var linkHistorico = $('a:eq(0)','#'+ formDados );
		
	if ( linkHistorico.prev().hasClass('campoTelaSemBorda') ) {		
		linkHistorico.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {
	
		linkHistorico.prev().unbind('blur').bind('blur', function() { 
			controlaPesquisas();
			return false;
		});	
	
		linkHistorico.css('cursor','pointer').unbind('click').bind('click', function() {			
			bo 			= 'b1wgen0059.p';
			procedure	= 'busca_historico';
			titulo      = 'Histórico';
			qtReg		= '30';
			filtrosPesq	= 'Cód. Hist;cdhistor;30px;S;0|Histórico;dshistor;200px;S;|;flglanca;;;FALSE;N|;inautori;;;9;N';
			colunas 	= 'Código;cdhistor;20%;right|Histórico;dshistor;80%;left';
			mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas,formDados);
			return false;
		});
	}
	return false;
}


// tabela cheques com descontos/custodias
function montarTabela() {

	var divTabDctror = $('#divTabDctror');	
	
	divTabDctror.html('<fieldset id="tabConteudo">'+
	'<div class="divRegistros">'+
	'<table>'+
	'<thead>'+
	'<tr>'+
	'<th>Hist</th>'+
	'<th>Banco</th>'+
	'<th>Agência</th>'+
	'<th>Conta Cheque</th>'+
	'<th>Inicial</th>'+
	'<th>Final</th>'+
	'<th>Provis.</th>'+
	'</tr>'+
	'</thead>'+
	'<tbody>'+
	'</tbody>'+
	'</table>'+
	'</div>'+
	'</fieldset>');	

	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	formataTabela();	

}

function formataTabela() {
	
	// tabela
	var divRegistro = $('div.divRegistros', '#divTabDctror');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
	
	divRegistro.css({'width':'545px','height':'150px','padding-bottom':'2px'});
	
	// Monta Tabela dos Itens
	$('#tabConteudo > div > table > tbody').html('');
	
	for( var i in arrayDctror ) {
		
		var cdhisaux = cddopcao == 'I' ? arrayDctror[i]['cdhistor'] : '&nbsp;';
		
		$('#tabConteudo > div > table > tbody').append('<tr></tr>');																					
		$('#tabConteudo > div > table > tbody > tr:last-child').append('<td>'+ cdhisaux +'</td>');
		$('#tabConteudo > div > table > tbody > tr:last-child').append('<td>'+ arrayDctror[i]['cdbanchq'] +'</td>');
		$('#tabConteudo > div > table > tbody > tr:last-child').append('<td>'+ arrayDctror[i]['cdagechq'] +'</td>');
		$('#tabConteudo > div > table > tbody > tr:last-child').append('<td><span>'+arrayDctror[i]['nrctachq']+'</span>'+ mascara(arrayDctror[i]['nrctachq'],'####.###.#') +'</td>');
		$('#tabConteudo > div > table > tbody > tr:last-child').append('<td><span>'+arrayDctror[i]['nrinichq']+'</span>'+ mascara(arrayDctror[i]['nrinichq'], '###.###.#') +'</td>');
		$('#tabConteudo > div > table > tbody > tr:last-child').append('<td><span>'+arrayDctror[i]['nrfinchq']+'</span>'+ mascara(arrayDctror[i]['nrfinchq'], '###.###.#') +'</td>');
		$('#tabConteudo > div > table > tbody > tr:last-child').append('<td>'+ arrayDctror[i]['dsprovis'] +'</td>');
	}
	
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];

	var arrayLargura = new Array();
	arrayLargura[0] = '69px';
	arrayLargura[1] = '48px';
	arrayLargura[2] = '70px';
	arrayLargura[3] = '83px';
	arrayLargura[4] = '73px';
	arrayLargura[5] = '70px';


	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'center';
	arrayAlinha[3] = 'center';
	arrayAlinha[4] = 'center';
	arrayAlinha[5] = 'center';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<input type="image" id="btVoltar"   src="../../imagens/botoes/voltar.gif" onClick="btnVoltar(); return false;" />&nbsp;');
	$('#divBotoes','#divTela').append('<input type="image" id="btSalvar"   src="../../imagens/botoes/prosseguir.gif" onClick="btnContinuar(); return false;"/> ');
	$('#divBotoes','#divTela').append('<input type="image" id="btConcluir" src="../../imagens/botoes/concluir.gif" onClick="btnConcluir(); return false;"/> ');

}


// criticas
function mostraCriticas() {
	
	showMsgAguardo('Aguarde, abrindo ...');

	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/dctror/criticas.php', 
		data: {
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			buscaCriticas();
			return false;
		}				
	});
	return false;
	
}

function buscaCriticas() {
		
	showMsgAguardo('Aguarde, buscando ...');

	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/dctror/tab_criticas.php', 
		data: {
			criticas: criticas,
			redirect: 'script_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {
		
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divConteudoCriticas').html(response);
					exibeRotina($('#divRotina'));
					formataCriticas();
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			} else {
				try {
					eval( response );
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		}				
	});
	return false;
}

function formataCriticas() {

	/********************
		FORMATA TABELA	
	*********************/
	var divRegistro = $('div.divRegistros','#divCriticas');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'160px','width':'500px'});
	
	var ordemInicial = new Array();
			
	var arrayLargura = new Array();
	arrayLargura[0] = '50px';
	arrayLargura[1] = '60px';
	arrayLargura[2] = '70px';
	arrayLargura[3] = '60px';
	
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'center';
	arrayAlinha[3] = 'center';
	arrayAlinha[4] = 'left';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	return false;
}


// custdesc
function mostraCustdesc() {
	
	showMsgAguardo('Aguarde, abrindo ...');

	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/dctror/custdesc.php', 
		data: {
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			buscaCustdesc();
			return false;
		}				
	});
	return false;
	
}

function buscaCustdesc() {
		
	showMsgAguardo('Aguarde, buscando ...');

	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/dctror/tab_custdesc.php', 
		data: {
			custdesc: custdesc,
			redirect: 'script_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {
		
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divConteudoCustdesc').html(response);
					exibeRotina($('#divRotina'));
					formataCustdesc();
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			} else {
				try {
					eval( response );
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		}				
	});
	return false;
}

function formataCustdesc() {

	/********************
		FORMATA TABELA	
	*********************/
	var divRegistro = $('div.divRegistros','#divCustdesc');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'160px','width':'500px'});

	// Monta Tabela dos Itens
	$('#divCustdesc > div > table > tbody').html('');
	
	for( var i in arrayCustdesc ) {
		$('#divCustdesc > div > table > tbody').append('<tr></tr>');																					
		$('#divCustdesc > div > table > tbody > tr:last-child').append('<td><span></span><input type="checkbox" value="'+i+'" onClick="marcarCustdesc(this)"  /></td>');
		$('#divCustdesc > div > table > tbody > tr:last-child').append('<td><span>'+arrayCustdesc[i]['nrdconta']+'</span>'+ mascara(arrayCustdesc[i]['nrdconta'],'####.###-#') 	+'</td>');
		$('#divCustdesc > div > table > tbody > tr:last-child').append('<td><span>'+arrayCustdesc[i]['nmprimtl']+'</span>'+ arrayCustdesc[i]['nmprimtl']						+'</td>');
		$('#divCustdesc > div > table > tbody > tr:last-child').append('<td><span>'+arrayCustdesc[i]['nrcheque']+'</span>'+ arrayCustdesc[i]['nrcheque']  						+'</td>');
		
	}
	
	$('#flgcusto', '#divCustodiaLinha1').html(arrayCustdesc[0]['flgcusto'] == 'yes' ? 'SIM' : 'NAO');
	$('#dtliber1', '#divCustodiaLinha1').html(arrayCustdesc[0]['dtliber1']);
	$('#cdpesqu1', '#divCustodiaLinha2').html(arrayCustdesc[0]['cdpesqu1']);

	$('#flgdesco', '#divCustodiaLinha3').html(arrayCustdesc[0]['flgdesco'] == 'yes' ? 'SIM' : 'NAO');
	$('#dtliber2', '#divCustodiaLinha3').html(arrayCustdesc[0]['dtliber2']);
	$('#cdpesqu2', '#divCustodiaLinha4').html(arrayCustdesc[0]['cdpesqu2']);
	
	var ordemInicial = new Array();
			
	var arrayLargura = new Array();
	arrayLargura[0] = '20px';
	arrayLargura[1] = '70px';
	arrayLargura[2] = '280px';
	
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'left';
	arrayAlinha[3] = 'center';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );


	/********************
	 FORMATA COMPLEMENTO	
	*********************/
	// complemento linha 1
	var linha1  = $('ul.complemento', '#divCustodiaLinha1');
	
	$('li:eq(0)', linha1).addClass('txtNormalBold').css({'width':'26%'});
	$('li:eq(1)', linha1).addClass('txtNormal').css({'width':'29%'});
	$('li:eq(2)', linha1).addClass('txtNormalBold').css({'width':'18%'});
	$('li:eq(3)', linha1).addClass('txtNormal');

	// complemento linha 2
	var linha2  = $('ul.complemento', '#divCustodiaLinha2').css({'clear':'both','border-top':'0'});
	
	$('li:eq(0)', linha2).addClass('txtNormalBold').css({'width':'25%'});
	$('li:eq(1)', linha2).addClass('txtNormal');

	// complemento linha 3
	var linha3  = $('ul.complemento', '#divCustodiaLinha3').css({'clear':'both'});
	
	$('li:eq(0)', linha3).addClass('txtNormalBold').css({'width':'26%'});
	$('li:eq(1)', linha3).addClass('txtNormal').css({'width':'29%'});
	$('li:eq(2)', linha3).addClass('txtNormalBold').css({'width':'18%'});
	$('li:eq(3)', linha3).addClass('txtNormal');

	// complemento linha 4
	var linha4  = $('ul.complemento', '#divCustodiaLinha4').css({'clear':'both','border-top':'0'});
	
	$('li:eq(0)', linha4).addClass('txtNormalBold').css({'width':'25%'});
	$('li:eq(1)', linha4).addClass('txtNormal');
	
	
	/********************
	  EVENTO COMPLEMENTO	
	*********************/
	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		selecionaCustdesc($(this));
	});	

	// seleciona o registro que é focado
	$('table > tbody > tr', divRegistro).focus( function() {
		selecionaCustdesc($(this));
	});	
	
	
	
	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	return false;
}

function selecionaCustdesc(tr) {

	$('#tpchequeLi').html($('#tpcheque', tr ).val());
	$('#dtliberaLi').html($('#dtlibera', tr ).val());
	$('#cdpesquiLi').html($('#cdpesqui', tr ).val());

	return false;
}

function marcarCustdesc(obj) {
	var i = obj.value;
	
	if ( obj.checked ) {
		arrayCustdesc[i]['flgselec'] = 'yes';
	} else {
		arrayCustdesc[i]['flgselec'] = 'no';
	}
	
	return false;
}

function continuarCustdesc( opcao ) {

	fechaRotina($('#divRotina'));

	if ( opcao == 'S' ) {
		controle = '6';
		operacao = operacao.substr(0,2) + controle;
		manterRotina();
	} else {
		controle = '0';
		operacao = '';
		estadoCabecalho();
	}

	return false;	
}


// senha
function mostraSenha() {

	showMsgAguardo('Aguarde, abrindo ...');

	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/dctror/senha.php', 
		data: {
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			buscaSenha();
			return false;
		}				
	});
	return false;
	
}

function buscaSenha() {

	hideMsgAguardo();		
		
	showMsgAguardo('Aguarde, abrindo ...');

	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/dctror/form_senha.php', 
		data: {
			redirect: 'script_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {
		
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divConteudoSenha').html(response);
					exibeRotina($('#divRotina'));
					formataSenha();
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			} else {
				try {
					eval( response );
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		}				
	});
	return false;
}

function formataSenha() {

	rOperador 	= $('label[for="operauto"]', '#frmSenha');
	rSenha		= $('label[for="codsenha"]', '#frmSenha');	
	
	rOperador.addClass('rotulo').css({'width':'135px'});
	rSenha.addClass('rotulo').css({'width':'135px'});

	cOperador	= $('#operauto', '#frmSenha');
	cSenha		= $('#codsenha', '#frmSenha');
	
	cOperador.addClass('campo').css({'width':'100px'}).attr('maxlength','10').focus();		
    cSenha.addClass('campo').css({'width':'100px'}).attr('maxlength','30');		
	
	$('#divConteudoSenha').css({'width':'330px', 'height':'110px'});	
	
	layoutPadrao();
	hideMsgAguardo();		
	bloqueiaFundo( $('#divRotina') );
	return false;
}

function validarSenha() {
		
	hideMsgAguardo();		
	
	// Situacao
	operauto 		= $('#operauto','#frmSenha').val();
	var codsenha = $('#codsenha', '#frmSenha').val();
    

	showMsgAguardo( 'Aguarde, validando ...' );	

	$.ajax({		
			type  : 'POST',
			async : true ,
			url   : UrlSite + 'telas/dctror/valida_senha.php', 		
			data: {
                cddopcao    : cddopcao,
				operauto	: operauto,		
				codsenha	: codsenha,
				redirect	: 'script_ajax'
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


// imprimir
function Gera_Impressao() {	
	
	var action = UrlSite + 'telas/dctror/imprimir_dados.php';
	$('input', '#'+formDados).habilitaCampo();
	
	$('#sidlogin','#'+formDados).remove();
	
	$('#'+formDados).append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '" />');

	// Configuro o formulário para posteriormente submete-lo
	$('#nrdconta','#'+formDados).val(normalizaNumero( cConta.val() ));
	$('#cddopcao','#'+formDados).val(cOpcao.val());
	$('#contra','#'+formDados).val(contra);
	
	var callafter = "estadoCabecalho();"; 
	
	carregaImpressaoAyllos(formDados,action,callafter);
	
}

function Gera_Log() {	

	hideMsgAguardo();		

	var camposDc  = '';
	camposDc  = retornaCampos( arrayDctror, '|' );
	
	var dadosDc  = '';
	dadosDc   = retornaValores( arrayDctror, ';', '|',camposDc );
	
	showMsgAguardo( 'Aguarde ...' );	

	$.ajax({		
			type  : 'POST',
			async : true ,
			url   : UrlSite + 'telas/dctror/gera_log.php', 		
			data: {
				cddopcao	: cddopcao,
				camposDc	: camposDc,
				dadosDc		: dadosDc,				
				redirect	: 'script_ajax'
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


// botao

function btnCritica() {

	fechaRotina($('#divRotina'));

	if ( contra != '' ) {
		Gera_Impressao();
	} else {
		estadoCabecalho();
	}

	return false;
}

function btnVoltar() {
	
	if ( operacao == 'C22' || operacao == 'C23' ) {
		controle = '0';
		operacao = operacao.substr(0,2) + controle;
		controlaLayout();

	} else if ( operacao == 'E23' || operacao == 'E24' ) { 
		controle = '1';
		operacao = operacao.substr(0,2) + controle;
		controlaLayout();
	
	} else if ( operacao == 'E22' ) {
		showConfirmacao('Deseja abandonar esta exclusão?','Confirma&ccedil;&atilde;o - Ayllos','operacao = \'\'; Gera_Log();','','sim.gif','nao.gif');
	
	} else if ( operacao == 'I22' ||  operacao == 'I23' ||  operacao == 'I24' ) {
		if ( cCdHistor.hasClass('campo') ) {
			showConfirmacao('Deseja abandonar esta inclusão?','Confirma&ccedil;&atilde;o - Ayllos','operacao = \'\'; btnVoltar();','','sim.gif','nao.gif');
		} else {
			controle = '2';
			operacao = operacao.substr(0,2) + controle;
			$('input', '#'+formDados).desabilitaCampo();
			cCdHistor.habilitaCampo().focus();
		}

		} else if ( operacao == 'A23' ) {
		controle = '2';
		operacao = operacao.substr(0,2) + controle;
		$('input', '#'+formDados+' fieldset:eq(1)').desabilitaCampo().limpaFormulario();
		cBanco.habilitaCampo().focus();
		
	} else {
		if ( cConta.hasClass('campoTelaSemBorda') ) {
			estadoCabecalho();
		} else {
			if (executandoImpedimentos){		
				sequenciaImpedimentos();
				return false;
			} else {
			estadoInicial();
		}
	}
	}
	
	controlaPesquisas();
	return false;
}

function btnConcluir() {

	operaaux = operacao;

	if ( operacao == 'E22'  || operacao == 'E23' || operacao == 'I22'  || operacao == 'I23' || operacao == 'I27' ) {
		if ( arrayDctror.length > 0 ) {
			operacao = operacao.substr(0,2) + '5';

			showConfirmacao('Confirmar Operação?','Confirma&ccedil;&atilde;o - Ayllos','manterRotina();','operacao=operaaux;','sim.gif','nao.gif');
			
		} else if ( arrayDctror.length == 0 ) {
			showError('error','Nenhuma contra-ordem foi informada.' ,'Alerta - Ayllos' ,'');
		
		}
		
	} 
	
	return false;
}

function btnContinuar() {

	if ( operacao == 'C21' || operacao == 'C22' || operacao == 'A22' || operacao == 'A23' || operacao == 'A25' || operacao == 'E22' ) {
		manterRotina();
		
	} else if ( operacao == 'I21' && cDtEmiss.hasClass('campo') ) {
		cDtEmiss.desabilitaCampo();
		cCdHistor.habilitaCampo().focus();	
		controle = '2';
		operacao = operacao.substr(0,2) + controle;
		controlaPesquisas();
		
	} else if ( (operacao == 'I22' || operacao == 'I27') && cCdHistor.hasClass('campo') ) {
		operacao = 'I27';
		manterRotina();
		
	} else if ( operacao == 'E22' || (operacao == 'I22' && cBanco.hasClass('campo')) ) {
		manterRotina();
		
	} 
	else if ( operacao == 'E23' || operacao == 'I23' ) {
		manterRotina();
	}

	return false;
}

function btnContinuarCustdesc () {
	showConfirmacao('Deseja continuar a operação?','Confirma&ccedil;&atilde;o - Ayllos','continuarCustdesc(\'S\');','continuarCustdesc(\'N\');','sim.gif','nao.gif');
	return false;
}

function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<input type="image" id="btVoltar" src="../../imagens/botoes/voltar.gif" onClick="btnVoltar(); return false;" />&nbsp;');
	$('#divBotoes','#divTela').append('<input type="image" id="btSalvar" src="../../imagens/botoes/'+botao+'.gif" onClick="btnContinuar(); return false;"/>&nbsp;');
	
	return false;
}

function setaFlag( flg ) {
	//seta valor pra variavel aux_flprovis

	if (flg == 1 )
		{aux_flprovis = 'TRUE';}
	else {aux_flprovis = 'FALSE';}

	if ( operacao != 'A25' ) {
		manterRotina();  // strube colocado aqui e retirado da controlalayout para chamar somente quando clicar no sim ou nao
	}
	
	return false;
}


// mensagem de sucesso
function msgSucesso( metodo ) {

	hideMsgAguardo();
	
	if ( cddopcao == 'E' ) {
		showError('inform','Exclusão efetuada com sucesso!' ,'Alerta - Ayllos' ,''+metodo+'');
	} else if ( cddopcao == 'I' ) {
		showError('inform','Inclusão efetuada com sucesso!' ,'Alerta - Ayllos' ,''+metodo+'');
		//exibirErro('inform','Inclusãoaaa efetuada com sucesso.','Alerta - Ayllos',''+metodo+'',false);
	}else if (cddopcao == 'A'){
		showError('inform','Alteração efetuada com sucesso.','Alerta - Ayllos',''+metodo+'');
	}
	return false;
}


// variaveis globais
function setGlobais() {

	operacao 		= ''; 
	controle		= '';	

	aux_cdagechq	= ''; 
	aux_dtemscor	= ''; 
	aux_cdhistor	= ''; 
	aux_nrfinchq	= ''; 
	aux_dssitdtl    = '';
	
	aux_dtvalcor	= '';
	aux_flprovis    = '';
	aux_imprimir    = 'NAO';

	aux_tpatlcad	= '';
	aux_msgatcad	= '';
	aux_chavealt	= '';
	aux_msgrecad	= '';
	
	nmdcampo		= ''; 
	tplotmov		= ''; 
	dsdctitg		= ''; 
	
	arrayDctror   	= new Array();
	arrayCustdesc	= new Array();		
	
	cheques			= '';
	custdesc		= '';
	criticas		= '';
	contra			= '';
	
	nrJanelas		= 0;
	operauto		= '';	
	
	return false;
}

function validaContaMigrada() {
		
	hideMsgAguardo();

	showMsgAguardo( 'Aguarde, validando ...' );	

	$.ajax({		
			type  : 'POST',
			async : false ,
			url   : UrlSite + 'telas/dctror/valida_conta_migrada.php',
			data: {
				nrdconta	: nrdconta,
				redirect	: 'script_ajax'
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


function validaAgencia() {
		
	hideMsgAguardo();
	
	var aux_retorno = false;
	var cdagechq = $('#cdagechq','#'+formDados).val();
	
	showMsgAguardo( 'Aguarde, validando ...');	

	$.ajax({		
			type  : 'POST',
			async : false ,
			url   : UrlSite + 'telas/dctror/valida_agencia.php',
			data: {
				nrdconta	: nrdconta,
				cdagechq	: cdagechq,
				redirect	: 'script_ajax'
			}, 
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
			},
			success: function(response) {
				try {
					if (response.indexOf('showError("error"') == -1) {
						aux_retorno = true;
						eval(response);

						hideMsgAguardo();
					} else {
						aux_retorno = false;
						hideMsgAguardo();
						eval(response);
					}
				} catch(error) {
					hideMsgAguardo();
				}
			}
		});
	
	return aux_retorno;
}
function sequenciaImpedimentos() {
    if (executandoImpedimentos) {	
		eval(produtosCancM[posicao - 1]);
		posicao++;
		return false;
    }
}

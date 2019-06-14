/*!
 * FONTE        : cadtar.js
 * CRIAÇÃO      : Daniel Zimmermann / Tiago Machado         
 * DATA CRIAÇÃO : 11/07/2017
 * OBJETIVO     : Biblioteca de funções da tela CADTAR
 * --------------
 * ALTERAÇÕES   : 02/08/2013 - Incluso tratamento para registros de cobranca (Daniel). 	
 *		          16/08/2013 - Alterado tamanho campos do frmAtribuicaoDetalhamento (Daniel). 	  
 *				  19/08/2013 - Incluso tratmento para nao permitir informar convenio 0 quando
 *							   campo for obrigatorio.	
 *				  21/08/2013 - Incluso tratamentos para Linha de Credito "cdlcremp" (Daniel).	 
 *
 *				  14/08/2015 - Inclusao da nova coluna "Operador" no Detalhamento de Tarifas
 * 							   Projeto 218 - Melhorias em Tarifas (Carlos Rafael Tanholi)
 *
 *                26/11/2015 - Ajustado para buscar os convenios de folha de pagamento
 *                             (Andre Santos - SUPERO)
 *
 *                24/06/2017 - Ajustado tamanho do campo cdmotivo para aceitar 10 caracteres
 *                             e 100px (Projeto 340 - NPC - Rafael)
 *
 *				  11/07/2017 - Inclusao das novas colunas e campos "Tipo de tarifacao", "Percentual", "Valor Minimo" e
 *                             "Valor Maximo" (Mateus - MoutS)
 *
 *                09/02/2018 - Ajuste feito para que a tela seja aberta no navegador IE. (SD 840276 - Kelvin)
 *
 *				  01/03/2018 - Ajuste na insercao do detalhamento da tarifa. (SD 848069 - Kelvin)
 *           
 *                25/06/2018 - Ajuste na function carregaAtribuicaoDetalhamento, a mesma não estava funcionando corretamente.
                               (Alcemir - Mout's) - INC0017668.
 * -------------- 
 */

// Definição de algumas variáveis globais 
var cddopcao		= 'C';
var cddopdet		= 'I';
var cdatrdet		= 'I';	
var cddoppar        = 'V';
	
//Formulários
var frmCab   		 = 'frmCab';
var frmDetalhaTarifa = 'frmDetalhaTarifa';
var frmVinculacaoParametro = 'frmVinculacaoParametro';

//Labels/Campos do cabeçalho
var rCddopcao, rcdsubgru, rCdsubgru, cCddopcao, cDssubgru, cCdsubgru, cTodosCabecalho, cCdfaixav, cCdpartar, glbTabCdpartar,
glbTabCdfaixav, glbTabVlinifvl, glbTabVlfinfvl, glbTabCdhistor, glbTabCdhisest, glbTabDshistor, glbTabDshisest,
glbFcoCdcooper, glbFcoDtdivulg,	glbFcoDtvigenc,	glbFcoVltarifa, gblFcoVlpertar,	glbFcoVlrepass, glbFcoCdfaixav, glbFcoNmrescop, glbFcoCdfvlcop,
gblFcoVlmaxtar, gblFcoVlmintar, glbFcoNrconven, glbFcoDsconven, glbFcoCdlcremp, glbFcoDslcremp, gblFcoTpcobtar;

var lstconve;
var lstcdfvl;
var lstdtdiv;
var lstdtvig;
var lstvltar;
var lstvlrep;
var lsttptar;
var lstvlper;
var lstvlmin;
var lstvlmax;
var lstcdcop;
var lstlcrem;	

$(document).ready(function() {
	
	estadoInicial();
	
	highlightObjFocus( $('#'+frmCab) );
	
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	
	return false;
	
});

// seletores
function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);
	$('#frmCab').css({'display':'block'});
	$('#divDetalhamento').css({'display':'none'});
	$('#divParametro').css({'display':'none'});
	
	$('#divOcorrenciaMotivo').css({'display':'none'});
	
	formataCabecalho();
	
	cTodosCabecalho.limpaFormulario();
	cCddopcao.val( cddopcao );
	
	removeOpacidade('divTela');	
	unblockBackground();
	hideMsgAguardo();
	
	cTodosCabecalho.desabilitaCampo();
	
	$('#cdtipcat','#frmCab').habilitaCampo();
	
	$('#cddopcao','#frmCab').habilitaCampo();
	$('#cddopcao','#'+frmCab).focus();
	
	$('#cdinctar','#'+frmCab).val('');
	
	$('#cdmotivo','#'+frmCab).desabilitaCampo();
	
	
	trocaBotao('');
	$("#btVoltar","#divBotoes").hide();
	
	$('input,select', '#frmCab').removeClass('campoErro');
	
	controlaFoco();
	
	$('#cdmotivo','#'+frmCab).desabilitaCampo();
	$('#cdocorre','#'+frmCab).desabilitaCampo();
		
}

function controlaFoco() {

	$('#cddopcao','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				LiberaCampos();
				$('#cddgrupo','#frmCab').focus();
				return false;
			}	
	});
	
	$('#btnOK','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {				
					LiberaCampos();
					$('#cddgrupo','#frmCab').focus();
					return false;
			}	
	});
	
	$('#cddgrupo','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			if ( $('#cddgrupo','#frmCab').val() == '') {
				$('#cdsubgru','#frmCab').focus();
			} else {
				btnContinuar();
				return false;
			}
		}			
	});
	
	$('#cdsubgru','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13) {	
			if ( $('#cdsubgru','#frmCab').val() == '') {
				$('#cdcatego','#frmCab').focus();
			} else {
				btnContinuar();
				return false;
			}
		}
	});
	
	$('#cdsubgru','#frmCab').unbind('blur').bind('blur', function(e) {		
		if ( $('#cdsubgru','#frmCab').val() == '') {
		} else {
			btnContinuar();
			return false;
		}		
	});	
	
	$('#cdcatego','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				if ( $('#cdcatego','#frmCab').val() == '') {
					if ( ( $('#cddopcao','#frmCab').val() == 'I') ){
						$('#dstarifa','#frmCab').focus();								
					}else{
						$('#cdtarifa','#frmCab').habilitaCampo();
						$('#cdtarifa','#frmCab').focus();
					}
				} else {
					btnContinuar();
					return false;
				}
			}			
	});
	
	$('#cdcatego','#frmCab').unbind('blur').bind('blur', function(e) {
			
		if ( $('#cdcatego','#frmCab').val() == '') {
			if ( ( $('#cddopcao','#frmCab').val() == 'I') ){
			}else{
				$('#cdtarifa','#frmCab').habilitaCampo();
				$('#cdtarifa','#frmCab').focus();
			}
		} else {
			btnContinuar();
			return false;
		}
			
	});	
	
	$('#cdtarifa','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			if ($('#cdtarifa','#frmCab').val() != ''){		
				buscarCadtar();
			} else {
				controlaPesquisaTarifa();
				return false;
			}
		}			
	});
	
	$('#dstarifa','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			if ($('#dstarifa','#frmCab').val() != ''){
				$('#inpessoa','#frmCab').focus();
			}
		}			
	});

	$('#inpessoa','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			if ($('#inpessoa','#frmCab').val() != ''){
				$('#cdinctar','#frmCab').focus();
			}
		}			
	});

	$('#cdinctar','#frmCab').unbind('change').bind('change', function(e) {
		$('#cdocorre','#frmCab').val('');
		$('#cdmotivo','#frmCab').val('');
		if ( $('#cdinctar','#frmCab').val() == '' ) {
			$('#cdocorre','#frmCab').desabilitaCampo();
			$('#cdmotivo','#frmCab').desabilitaCampo();
			$('#divOcorrenciaMotivo').css({'display':'none'});
		} else {
			buscaFlagIncidencia( $('#cdinctar','#frmCab').val() );
		}
		return false;		
	});
	
	$('#cdinctar','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				btnContinuar();
				return false;
		}			
	});	
}

function formataCabecalho() {

	// cabecalho
	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab); 
	rCddgrupo			= $('label[for="cddgrupo"]','#'+frmCab); 	
	rCdsubgru			= $('label[for="cdsubgru"]','#'+frmCab);
	rCdtipcad			= $('label[for="cdtipcad"]','#'+frmCab);
	rCdcatego			= $('label[for="cdcatego"]','#'+frmCab);
	rCdtarifa			= $('label[for="cdtarifa"]','#'+frmCab);
	rInpessoa			= $('label[for="inpessoa"]','#'+frmCab);
	rCdinctar			= $('label[for="cdinctar"]','#'+frmCab);
	rCdocorre			= $('label[for="cdocorre"]','#'+frmCab);
	rCdmotivo			= $('label[for="cdmotivo"]','#'+frmCab);	
	rFlglaman			= $('label[for="flglaman"]','#'+frmCab);
	
	cCddopcao			= $('#cddopcao','#'+frmCab); 
	cCddgrupo           = $('#cddgrupo','#'+frmCab); 
	cCdsubgru			= $('#cdsubgru','#'+frmCab); 
	cCdtipcad			= $('#cdtipcad','#'+frmCab); 
	cCdcatego			= $('#cdcatego','#'+frmCab); 
	cCdtarifa			= $('#cdtarifa','#'+frmCab);
	cDstarifa			= $('#dstarifa','#'+frmCab);
	cInpessoa			= $('#inpessoa','#'+frmCab);
	cCdinctar			= $('#cdinctar','#'+frmCab);
	cCdocorre			= $('#cdocorre','#'+frmCab);
	cCdmotivo			= $('#cdmotivo','#'+frmCab);
	cDssubgru			= $('#dssubgru','#'+frmCab);
	cDsdgrupo			= $('#dsdgrupo','#'+frmCab); 
	cDscatego			= $('#dscatego','#'+frmCab); 
	cFlglaman			= $('#flglaman','#'+frmCab);
	
	cTodosCabecalho		= $('input[type="text"],input[type="checkbox"],select','#'+frmCab);
	
	rCdcatego.css('width','115px');
	rCddopcao.css('width','115px');
	rCddgrupo.css('width','115px');
	rCdsubgru.css({'width':'115px'});
	rCdtipcad.css({'width':'115px'});
	rCdcatego.css({'width':'115px'});
	rCdtarifa.css({'width':'115px'});
	rInpessoa.css({'width':'115px'});
	rCdinctar.css({'width':'115px'});
	rCdocorre.css({'width':'115px'});
	rCdmotivo.css({'width':'200px'}); //old - 155px 
	
	cCdtarifa.css({'width':'90px'}).attr('maxlength','9').setMask('INTEGER','zzzzzzzzz','','');
	cCdcatego.css({'width':'90px'}).attr('maxlength','9').setMask('INTEGER','zzzzzzzzz','','');
	cCddopcao.css({'width':'540px'});	
	cCddgrupo.css({'width':'90px'}).attr('maxlength','9').setMask('INTEGER','zzzzzzzzz','','');
	cCdsubgru.css({'width':'90px'}).attr('maxlength','9').setMask('INTEGER','zzzzzzzzz','','');
	cCdtipcad.css({'width':'90px'});
	cDstarifa.css({'width':'460px'}).attr('maxlength','255').setMask("STRING",255,charPermitido(),"");
	cInpessoa.css({'width':'360px'});
	cCdinctar.css({'width':'500px'});
	
	cCdocorre.css({'width':'30px'}).attr('maxlength','2').setMask('INTEGER','zz','','');
	
	cCdmotivo.css({'width':'100px'}).attr('maxlength','10').setMask("STRING",10,charPermitido(),""); //old - 30px maxlength - 3
	cCdmotivo.css({'text-transform':'uppercase'});
	
	cDssubgru.css({'width':'460px'});
	cDsdgrupo.css({'width':'460px'});
	cDscatego.css({'width':'460px'});
	
	cTodosCabecalho.habilitaCampo().removeClass('campoErro');
	
	layoutPadrao();
	return false;	
}

// Botao Voltar
function btnVoltar() {
	estadoInicial();
	return false;
}

function LiberaCampos() {

	if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda')  ) { return false; }	

	//Desabilita campo opção
	cTodosCabecalho		= $('input[type="text"],select','#frmCab'); 
	cTodosCabecalho.desabilitaCampo();
	
	$('#cdcatego','#frmCab').habilitaCampo();
	$('#cddgrupo','#frmCab').habilitaCampo();
	$('#cdsubgru','#frmCab').habilitaCampo();
	$('#cdtarifa','#frmCab').habilitaCampo();
	
	$('#divBotoes', '#divTela').css({'display':'block'});
	
	trocaBotao( 'btnConcluir' );
	
	$("#btSalvar","#divBotoes").show();
	$("#btVoltar","#divBotoes").show();

	if ( $('#cddopcao','#frmCab').val() == 'I' ){
		buscaSequencial();
		$('#cdtarifa','#frmCab').desabilitaCampo();
		$('#dstarifa','#frmCab').habilitaCampo();
		$('#inpessoa','#frmCab').habilitaCampo();
		$('#cdinctar','#frmCab').habilitaCampo();
		$('#flglaman','#frmCab').habilitaCampo();
		trocaBotao( 'Incluir');
		return false;	
	}
	
	$('#cddgrupo','#frmCab').focus();

	return false;

}

function btnContinuar() {

	cddgrupo = normalizaNumero( cCddgrupo.val() );
	cdsubgru = normalizaNumero( cCdsubgru.val() );
	cdcatego = normalizaNumero( cCdcatego.val() );
	cddopcao = cCddopcao.val();
	
	if (( cdcatego != '' ) && ( ! $('#cdcatego','#frmCab').hasClass('campoTelaSemBorda') )) {	
		buscaDados(3);
	} else {
	
			if (( cdsubgru != '' ) && ( ! $('#cdsubgru','#frmCab').hasClass('campoTelaSemBorda') )) {		 
				buscaDados(2);
		} else {
		 
				if (( cddgrupo != '' ) && ( ! $('#cddgrupo','#frmCab').hasClass('campoTelaSemBorda') )) {
					buscaDados(1);
				} 
		}
	}
	
}

function btnConcluir() {

	cddgrupo = normalizaNumero( cCddgrupo.val() );
	cdsubgru = normalizaNumero( cCdsubgru.val() );
	cdcatego = normalizaNumero( cCdcatego.val() );
	cdtarifa = normalizaNumero( cCdtarifa.val() );
	
	if (( cdtarifa != '' ) && ( ! $('#cdtarifa','#frmCab').hasClass('campoTelaSemBorda') )) {
		buscarCadtar();
	} else {
	
		if (( cdcatego != '' ) && ( ! $('#cdcatego','#frmCab').hasClass('campoTelaSemBorda') )) {	
			buscaDados(3);
		} else {
		
				if (( cdsubgru != '' ) && ( ! $('#cdsubgru','#frmCab').hasClass('campoTelaSemBorda') )) {		 
					buscaDados(2);
			} else {
			 
					if (( cddgrupo != '' ) && ( ! $('#cddgrupo','#frmCab').hasClass('campoTelaSemBorda') )) {
						buscaDados(1);
					} 
			}
		}
	}
	
}

function buscaHistRepetido(){

	showMsgAguardo("Aguarde, consultando Historico de Lancamento...");
	
	$('input,select', '#frmDetalhaTarifa').removeClass('campoErro');

	var cdhistor = $('#cdhistor','#frmDetalhaTarifa').val();
	cdhistor = normalizaNumero(cdhistor);	
	
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadtar/busca_historico_repetido.php", 
		data: {
			cddopcao: cddopcao,
			cdhistor: cdhistor,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();				
				eval(response);
				bloqueiaFundo($('#divRotina'));
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});	
	
}

function verificaLancLat(cddopdet){

	showMsgAguardo("Aguarde, consultando Lancamentos...");

	var cdhistor = $('#cdhistor','#frmDetalhaTarifa').val();
	cdhistor = normalizaNumero(cdhistor);	
	
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadtar/verifica_lancamento_craplat.php", 
		data: {
			cddopcao: cddopdet,
			cdhistor: cdhistor,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
		
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					// hideMsgAguardo();				
					eval(response);
					if ( cddopcao != 'C') {
						bloqueiaFundo($('#divRotina'));
					}
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			} else {
				try {
					eval( response );
					controlaFoco();
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		
		}				
	});	
	
}

function buscaHistorico(){

	showMsgAguardo("Aguarde, consultando Historico de Lancamento...");
	
	$('input,select', '#frmDetalhaTarifa').removeClass('campoErro');

	var cdhistor = $('#cdhistor','#frmDetalhaTarifa').val();
	cdhistor = normalizaNumero(cdhistor);	
	
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadtar/busca_historico.php", 
		data: {
			cddopcao: cddopcao,
			cdhistor: cdhistor,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();				
				eval(response);
				bloqueiaFundo($('#divRotina'));
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});	
	
}

function buscaHisest(){

	showMsgAguardo("Aguarde, consultando Historico de Estorno...");
	
	$('input,select', '#frmDetalhaTarifa').removeClass('campoErro');

	var cdhisest = $('#cdhisest','#frmDetalhaTarifa').val();
	cdhisest = normalizaNumero(cdhisest);	
	
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadtar/busca_hisest.php", 
		data: {
			cddopcao: cddopcao,
			cdhisest: cdhisest,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();				
				eval(response);				
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});	

	return false;
}

function buscarCadtar(){

	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmCab';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');

	showMsgAguardo("Aguarde, consultando Tarifas...");

	var cdtarifa = $('#cdtarifa','#frmCab').val();
	cdtarifa = normalizaNumero(cdtarifa);
	
	var cddopcao = $('#cddopcao','#frmCab').val();
	
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadtar/busca_dados_tarifa.php", 
		data: {
			cddopcao: cddopcao,
			cdtarifa: cdtarifa,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					eval(response);
					unblockBackground();
					carregaDetalhamento();
				} catch(error) {
					hideMsgAguardo();
					showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
				}
			} else {
				try {
					eval( response );
					controlaFoco();
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		}
	});	
	
}

function carregaDetalhamento(){
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, buscando detalhamento...");
	
	var cdtarifa = $('#cdtarifa','#frmCab').val();
	cdtarifa = normalizaNumero(cdtarifa);
	var cddopcao = $('#cddopcao','#frmCab').val();
	
	// Carrega dados parametro através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/cadtar/carrega_detalhamento.php', 
		data    : 
				{ 
					cddopcao	: cddopcao,
					cdtarifa	: cdtarifa,
					redirect	: 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) { 
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {						
							$('#divDetalhamento').html(response);	
							$('#divDetalhamento').css({'display':'block'});
							
							formataDetalhamento();
							
							var cddopcao = $('#cddopcao','#frmCab').val();
	
							if ( cddopcao == 'C' ) {
											
								$('#btIncluir','#divBotoesDetalha').hide();
								$('#btAlterar','#divBotoesDetalha').hide();
								$('#btExcluir','#divBotoesDetalha').hide();
							}
							carregaParametro();
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

function carregaAtribuicaoDetalhamento(nriniseq, nrregist) {
	
    var cdfaixav = $('#cdfaixav', '#frmDetalhaTarifa').val();
	showMsgAguardo("Aguarde, carregando...");
	

	var flgtodos = $('#flgtodos','#divBotoesDetalhaTarifa').val();
	
	var cddopcao = $('#cddopcao','#frmCab').val();
	
	var cdtipcat = $('#cdtipcat','#frmCab').val(); /* Daniel */
	
	if (flgtodos != 'TRUE') {
		flgtodos = 'FALSE';
	}
	
	// Carrega dados parametro através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/cadtar/carrega_atribuicao_detalhamento.php', 
		data    : 
				{ 				
					cdfaixav	: cdfaixav,
					flgtodos	: flgtodos,
					cddopcao	: cddopcao,
					cdtipcat	: cdtipcat, /* Daniel */		
					nriniseq    : nriniseq,
					nrregist    : nrregist,
					redirect	: 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) { 
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {		
							$('#divTabDetalhamento').html(response);	
							$('#divTabDetalhamento').css({'display':'block'});
							formataTabDetalhamento();
							hideMsgAguardo();
							bloqueiaFundo($('#divRotina'));
							if (flgtodos == 'TRUE') {
								$('#flgtodos','#divBotoesDetalhaTarifa').prop("checked",true);
							}
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



function realizaOpDetalhamento(cddopdet) {

	$('input,select', '#frmDetalhaTarifa').removeClass('campoErro'); /* Remove foco de erro */

	var cdfaixav = $('#cdfaixav','#frmDetalhaTarifa').val();
	var cdtarifa = $('#cdtarifa','#frmDetalhaTarifa').val();
	var vlinifvl = $('#vlinifvl','#frmDetalhaTarifa').val();
	var vlfinfvl = $('#vlfinfvl','#frmDetalhaTarifa').val();
	var cdhistor = $('#cdhistor','#frmDetalhaTarifa').val();
	var cdhisest = $('#cdhisest','#frmDetalhaTarifa').val();
	
	cdfaixav = normalizaNumero(cdfaixav);
	cdtarifa = normalizaNumero(cdtarifa);
	vlinifvl = normalizaNumero(vlinifvl);
	vlfinfvl = normalizaNumero(vlfinfvl);
	cdhistor = normalizaNumero(cdhistor);
	cdhisest = normalizaNumero(cdhisest);		
	
	if ( cddopdet != 'E') {
	
		if ( vlinifvl == '')	{
			showError('error','Valor Inicial deve ser informado.','Alerta - Ayllos',"$(\'#vlinifvl\',\'#frmDetalhaTarifa\').focus(); blockBackground(parseInt($('#divRotina').css('z-index')))");
			return false;
		}
		
		if ( vlfinfvl == '')	{
			showError('error','Valor Final deve ser informado.','Alerta - Ayllos',"$(\'#vlfinfvl\',\'#frmDetalhaTarifa\').focus(); blockBackground(parseInt($('#divRotina').css('z-index')))");
			return false;
		}

		if ( parseFloat(vlinifvl) > parseFloat(vlfinfvl))	{
			showError('error','Valor Inicial deve ser menor que Valor Final.','Alerta - Ayllos',"$(\'#vlinifvl\',\'#frmDetalhaTarifa\').focus(); blockBackground(parseInt($('#divRotina').css('z-index')))");
			return false;
		}
		
		if ( cdhistor == '')	{
			showError('error','Historico de Lancamento deve ser informado.','Alerta - Ayllos',"$(\'#cdhistor\',\'#frmDetalhaTarifa\').focus(); blockBackground(parseInt($('#divRotina').css('z-index')))");
			return false;
		}
		
		if ( cdhisest == '')	{
			showError('error','Historico de Estorno deve ser informado.','Alerta - Ayllos',"$(\'#cdhisest\',\'#frmDetalhaTarifa\').focus(); blockBackground(parseInt($('#divRotina').css('z-index')))");
			return false;
		}
	}

	
	// Mostra mensagem de aguardo
	if (cddopdet == "I"){  	   showMsgAguardo("Aguarde, incluindo Detalhe Tarifas..."); } 
	else if (cddopdet == "A"){ showMsgAguardo("Aguarde, alterando Detalhe Tarifas...");  }
	else if (cddopdet == "E"){ showMsgAguardo("Aguarde, excluindo Detalhe Tarifas...");  }
	else if (cddopdet == "R"){ showMsgAguardo("Aguarde, excluindo Detalhe Tarifas...");  }
	else { showMsgAguardo("Aguarde, liberando aplicacao..."); }
	
	if (cddopdet == "X") {
		liberaDetalhamento();
		return false;
	}
	
	
	
	if (cddopdet == "E") {
		cdtarifa = $('#cdtarifa','#frmCab').val();
		cdfaixav = glbTabCdfaixav;
		vlinifvl = glbTabVlinifvl;
		vlfinfvl = glbTabVlfinfvl;
		cdhistor = glbTabCdhistor;
		cdhisest = glbTabCdhisest;
	}	
	
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadtar/manter_rotina_detalhamento.php", 
		data: {
			cddopcao: cddopcao,
			cddopdet: cddopdet,
			cdfaixav: cdfaixav,
			cdtarifa: cdtarifa,
			vlinifvl: vlinifvl,
			vlfinfvl: vlfinfvl,
			cdhistor: cdhistor, 
			cdhisest: cdhisest,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					eval(response);
					//Remove a classe de Erro do form
					$('input,select', '#frmAtribuicaoDetalhamento').removeClass('campoErro');
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			} else {
				try {
					eval( response );
					controlaFoco();
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
			
			
		}				
	});	
	
}

function validaReplicacao(){

	var cdfaixav = $('#cdfaixav','#frmDetalhaTarifa').val();
	var cdfvlcop = $('#cdfvlcop','#frmAtribuicaoDetalhamento').val();
	var cdcopatu = $('#cdcopaux','#frmAtribuicaoDetalhamento').val();
	var dtdivulg = $('#dtdivulg','#frmAtribuicaoDetalhamento').val();
	var dtvigenc = $('#dtvigenc','#frmAtribuicaoDetalhamento').val();	
	var vltarifa = $('#vltarifa2','#frmAtribuicaoDetalhamento').val();
	var vlrepass = $('#vlrepass2','#frmAtribuicaoDetalhamento').val();
	var vlperc   = $('#vlperc','#frmAtribuicaoDetalhamento').val();
	var vlminimo = $('#vlminimo','#frmAtribuicaoDetalhamento').val();
	var vlmaximo = $('#vlmaximo','#frmAtribuicaoDetalhamento').val();
	var flgtiptar= $('input[type=radio][name=flgtiptar]:checked','#frmAtribuicaoDetalhamento').val();
	
	var cddopcao = $('#cddopcao','#frmCab').val();
	
	
	cdcopatu = normalizaNumero(cdcopatu);
	cdfaixav = normalizaNumero(cdfaixav);
	vltarifa = normalizaNumero(vltarifa);
	vlrepass = normalizaNumero(vlrepass);
	
	var cdtipcat = $('#cdtipcat','#frmCab').val();
	
	var numocorr = $('#numocorr','#formAtribuicaoDetalhamento').val();
	
	lstcdfvl = '';
	lstdtdiv = '';
	lstdtvig = '';
	lstvltar = '';
	lstvlrep = '';
	lsttptar = '';
	lstvlper = '';
	lstvlmin = '';
	lstvlmax = '';
	lstcdcop = '';
	lstlcrem = '';	
	lstconve = '';
	
	for (var i=1;i<=numocorr;i++){ 
		
		if( $('#flgcheck'+i,'#formAtribuicaoDetalhamento').prop('checked') == true ){
		
			 lstcdfvl  = lstcdfvl  + $('#cdfvlcop'+i,'#formAtribuicaoDetalhamento').val() + ';'; 
			 lstdtdiv  = lstdtdiv  + $('#dtdivulg'+i,'#formAtribuicaoDetalhamento').val() + ';'; 
			 lstdtvig  = lstdtvig  + $('#dtvigenc'+i,'#formAtribuicaoDetalhamento').val() + ';'; 
			 lstvltar  = lstvltar  + $('#vltarifatab'+i,'#formAtribuicaoDetalhamento').val() + ';'; 
			 lstvlrep  = lstvlrep  + $('#vlrepasstab'+i,'#formAtribuicaoDetalhamento').val() + ';'; 
			 lstvlper  = lstvlper  + $('#vlperctab'+i,'#formAtribuicaoDetalhamento').val() + ';';
			 lstvlmin  = lstvlmin  + $('#vlminimotab'+i,'#formAtribuicaoDetalhamento').val() + ';';
			 lstvlmax  = lstvlmax  + $('#vlmaximotab'+i,'#formAtribuicaoDetalhamento').val() + ';';
			 lstcdcop  = lstcdcop  + $('#cdcooper'+i,'#formAtribuicaoDetalhamento').val() + ';'; 
			 lstlcrem  = lstlcrem  + $('#cdlcremptab'+i,'#formAtribuicaoDetalhamento').val() + ';';
			 
			 flglsttptar = $('#vltarifatab'+i,'#formAtribuicaoDetalhamento').val().toString().replace(/\,/g, '.') > 0 ? 1 : 2;
			 lsttptar  = lsttptar  + flglsttptar + ';';

			 lstconve = lstconve + $('#nrconventab'+i,'#formAtribuicaoDetalhamento').val() + ';'; 
			
		}	
	}			

	$.trim(lstcdfvl);
	$.trim(lstdtdiv);
	$.trim(lstdtvig);
	$.trim(lstvltar);
	$.trim(lstvlrep);
	$.trim(lsttptar);
	$.trim(lstvlper);
	$.trim(lstvlmax);
	$.trim(lstvlmin);
	$.trim(lstcdcop);
	$.trim(lstlcrem);
	$.trim(lstconve);
	
	lstcdfvl = lstcdfvl.substr(0,lstcdfvl.length - 1);
	lstdtdiv = lstdtdiv.substr(0,lstdtdiv.length - 1);
	lstdtvig = lstdtvig.substr(0,lstdtvig.length - 1);
	lstvltar = lstvltar.substr(0,lstvltar.length - 1);
	lstvlrep = lstvlrep.substr(0,lstvlrep.length - 1);
	lsttptar = lsttptar.substr(0,lsttptar.length - 1);
	lstvlper = lstvlper.substr(0,lstvlper.length - 1);
	lstvlmax = lstvlmax.substr(0,lstvlmax.length - 1);
	lstvlmin = lstvlmin.substr(0,lstvlmin.length - 1);
	lstcdcop = lstcdcop.substr(0,lstcdcop.length - 1);
	lstlcrem = lstlcrem.substr(0,lstlcrem.length - 1);
	lstconve = lstconve.substr(0,lstconve.length - 1);
		
	
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadtar/valida_replicacao.php",  
		data: {
			cddopcao: cddopcao,
			cdfvlcop: cdfvlcop,
			cdfaixav: cdfaixav,
			cdcopatu: cdcopatu,
			dtdivulg: dtdivulg,
			dtvigenc: dtvigenc,
			vltarifa: vltarifa,
			vlrepass: vlrepass,
			lstcdfvl: lstcdfvl,
			lstdtdiv: lstdtdiv,
			lstdtvig: lstdtvig,
			lstvltar: lstvltar,
			lstvlrep: lstvlrep,
			lsttptar: lsttptar,
			lstvlper: lstvlper,
			lstvlmin: lstvlmin,
			lstvlmax: lstvlmax,
			lstcdcop: lstcdcop,
			lstconve: lstconve,
			lstlcrem: lstlcrem,
			cdtipcat: cdtipcat,
			tpcobtar: flgtiptar,
			vlpertar: vlperc,
			vlmintar: vlminimo,
			vlmaxtar: vlmaximo,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();	
				eval(response);				
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});	

	return false;
}

function controlaOpFco( valor ){ 

	switch( valor )
	{
		case 'R':
			showMsgAguardo("Aguarde, Validando Replicacao...");
			setTimeout(function(){validaReplicacao();},1000);
			break;
		case 'IR':
			realizaOpFco(valor);
			break;
		case 'A':
			realizaOpFco(valor);
			break;		
		case 'I':
			realizaOpFco(valor);
			break;
		case 'E':
			realizaOpFco(valor);
			break;			
	}
	
}

function realizaOpFco(cddopfco) {

	//Remove a classe de Erro do form
	$('input,select', '#frmAtribuicaoDetalhamento').removeClass('campoErro');
	
	
	// Efetua validação 
	if ( $('#cdcopaux','#frmAtribuicaoDetalhamento').val() == '' ) {
				showError("error","Cooperativa deve ser informado.","Alerta - Ayllos","focaCampoErro(\'cdcopaux\', \'frmAtribuicaoDetalhamento\');bloqueiaFundo($('#divRotina'));",false);
				return false;
	}
	if(cddopfco == 'A' || cddopfco == 'I'){
		if ( !$('input[type=radio][name=flgtiptar]').is(":checked") ) {
				showError("error","Tipo de Tarifação deve ser informado.","Alerta - Ayllos","focaCampoErro(\'flgperc\', \'frmAtribuicaoDetalhamento\');bloqueiaFundo($('#divRotina'));",false);
				return false;
		}
	}	
	
	if ( $('#dtdivulg','#frmAtribuicaoDetalhamento').val() == '' ) {
				showError("error","Data Divulgação deve ser informado.","Alerta - Ayllos","focaCampoErro(\'dtdivulg\', \'frmAtribuicaoDetalhamento\');bloqueiaFundo($('#divRotina'));",false);
				return false;
	}
	
	if ( $('#dtvigenc','#frmAtribuicaoDetalhamento').val() == '' ) {
				showError("error","Data Vigencia deve ser informado.","Alerta - Ayllos","focaCampoErro(\'dtvigenc\', \'frmAtribuicaoDetalhamento\');bloqueiaFundo($('#divRotina'));",false);
				return false;
	}
	
//	if ( ( $('#cdocorre','#frmCab').val() != 0 ) || ( $('#cdmotivo','#frmCab').val() != "" ) ) { /* Daniel*/
	

	if ( normalizaNumero($('#cdtipcat','#frmCab').val()) == 2 ) { /* 2 - Convenio */
	 
		if ( ( $('#nrconven','#frmAtribuicaoDetalhamento').val() == '' ) || ( $('#nrconven','#frmAtribuicaoDetalhamento').val() == 0 )  ) {
					showError("error","Convenio deve ser informado.","Alerta - Ayllos","focaCampoErro(\'nrconven\', \'frmAtribuicaoDetalhamento\');bloqueiaFundo($('#divRotina'));",false);
					return false;
		}
	}
	
	if (cddopfco == "E"){ 
		var data1 =	glbFcoDtdivulg;
		var data2 = glbFcoDtvigenc;
	} else {
		var data1 = $('#dtdivulg','#frmAtribuicaoDetalhamento').val();
		var data2 = $('#dtvigenc','#frmAtribuicaoDetalhamento').val();
	}
	
	var data3 = $('#glbdtmvtolt','#frmCab').val();
 	
	// Divulgação
	var nova_data1 = parseInt(data1.split("/")[2].toString() + data1.split("/")[1].toString() + data1.split("/")[0].toString()); 
	
	// Vigencia
	var nova_data2 = parseInt(data2.split("/")[2].toString() + data2.split("/")[1].toString() + data2.split("/")[0].toString()); 
	
	// Data Sistema
	var nova_data3 = parseInt(data3.split("/")[2].toString() + data3.split("/")[1].toString() + data3.split("/")[0].toString()); 
	
	
	if ( nova_data1 > nova_data2 ) {
				showError("error","Data Divulgação deve ser menor que Data Vigencia.","Alerta - Ayllos","focaCampoErro(\'dtvigenc\', \'frmAtribuicaoDetalhamento\');bloqueiaFundo($('#divRotina'));",false);
				return false;
	}
	
	if ( ( nova_data2 <= nova_data3 ) && ( cddopfco != 'R') ) {
				showError("error","Data Vigencia deve ser maior que Data do Sistema.","Alerta - Ayllos","focaCampoErro(\'dtvigenc\', \'frmAtribuicaoDetalhamento\');bloqueiaFundo($('#divRotina'));",false);
				return false;
	}
	
	if ( $('#vltarifa2','#frmAtribuicaoDetalhamento').val() == '' ) {
				showError("error","Valor Tarifa deve ser informado.","Alerta - Ayllos","focaCampoErro(\'vltarifa2\', \'frmAtribuicaoDetalhamento\');bloqueiaFundo($('#divRotina'));",false);
				return false;
	}
	
	if ( $('#vlrepass2','#frmAtribuicaoDetalhamento').val() == '' ) {
				showError("error","Custo/Repasse deve ser informado.","Alerta - Ayllos","focaCampoErro(\'vlrepass2\', \'frmAtribuicaoDetalhamento\');bloqueiaFundo($('#divRotina'));",false);
				return false;
	}


	// Mostra mensagem de aguardo
	if (cddopfco == "I"){  	   showMsgAguardo("Aguarde, incluindo Detalhe Tarifas por Cooperativa..."); } 
	else if (cddopfco == "A"){ showMsgAguardo("Aguarde, alterando Detalhe Tarifas por Cooperativa...");  }
	else if (cddopfco == "E"){ showMsgAguardo("Aguarde, excluindo Detalhe Tarifas por Cooperativa...");  }
	else if (cddopfco == "R"){ showMsgAguardo("Aguarde, replicando Detalhe Tarifas por Cooperativa...");  }
	else if (cddopfco == "IR"){ showMsgAguardo("Aguarde, incluindo Detalhe Tarifas por Cooperativa...");  }
	else { showMsgAguardo("Aguarde, liberando aplicacao..."); }
	
	$('input,select', '#frmAtribuicaoDetalhamento').removeClass('campoErro');
	
	var cdfaixav = $('#cdfaixav','#frmDetalhaTarifa').val();
	var cdfvlcop = $('#cdfvlcop','#frmAtribuicaoDetalhamento').val();
	var cdcopatu = $('#cdcopaux','#frmAtribuicaoDetalhamento').val();
	var dtdivulg = $('#dtdivulg','#frmAtribuicaoDetalhamento').val();
	var dtvigenc = $('#dtvigenc','#frmAtribuicaoDetalhamento').val();	
	var vltarifa = $('#vltarifa2','#frmAtribuicaoDetalhamento').val();
	var vlrepass = $('#vlrepass2','#frmAtribuicaoDetalhamento').val();
	var vlperc   = $('#vlperc','#frmAtribuicaoDetalhamento').val();
	var vlminimo = $('#vlminimo','#frmAtribuicaoDetalhamento').val();
	var vlmaximo = $('#vlmaximo','#frmAtribuicaoDetalhamento').val();
	var flgtiptar= $('input[type=radio][name=flgtiptar]:checked','#frmAtribuicaoDetalhamento').val();
	
	var cddopcao = $('#cddopcao','#frmCab').val();
	
	var nrconven = $('#nrconven','#frmAtribuicaoDetalhamento').val();
	
	var cdocorre  = normalizaNumero($('#cdocorre','#frmCab').val());
	
	var cdlcremp = $('#cdlcremp','#frmAtribuicaoDetalhamento').val(); /* Daniel */
	
	var cdinctar = $('#cdinctar','#frmCab').val();
	
	var cdtipcat = $('#cdtipcat','#frmCab').val();
	
	cdcopatu = normalizaNumero(cdcopatu);
	cdfaixav = normalizaNumero(cdfaixav);
	vltarifa = normalizaNumero(vltarifa);
	vlrepass = normalizaNumero(vlrepass);
	vlperc   = normalizaNumero(vlperc);
	vlminimo = normalizaNumero(vlminimo);
	vlmaximo = normalizaNumero(vlmaximo);
	
	nrconven = normalizaNumero(nrconven);
	
	cdlcremp = normalizaNumero(cdlcremp);
	
	cdinctar = normalizaNumero(cdinctar);
	

/* Daniel */	
	// var lstcdfvl = getListaReplica('cdfvlcop');
	// var lstdtdiv = getListaReplica('dtdivulg');
	// var lstdtvig = getListaReplica('dtvigenc');
	// var lstvltar = getListaReplica('vltarifatab');
	// var lstvlrep = getListaReplica('vlrepasstab');
	// var lstcdcop = getListaReplica('cdcooper');
	
	// var lstconve = getListaReplica('nrconventab');
	
	// var lstlcrem = getListaReplica('cdlcremptab');
	
	if (cddopfco == "E"){
		cdcopatu = glbFcoCdcooper;
		cdfaixav = glbFcoCdfaixav;
		cdfvlcop = glbFcoCdfvlcop;
	}
	
	
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadtar/manter_rotina_fco.php",  
		data: {
			cddopcao: cddopcao,
			cdfvlcop: cdfvlcop,
			cddopfco: cddopfco,
			cdfaixav: cdfaixav,
			cdcopatu: cdcopatu,
			dtdivulg: dtdivulg,
			dtvigenc: dtvigenc,
			vltarifa: vltarifa,
			vlrepass: vlrepass,
			lstcdfvl: lstcdfvl,
			lstdtdiv: lstdtdiv,
			lstdtvig: lstdtvig,
			lstvltar: lstvltar,
			lstvlrep: lstvlrep,
			lsttptar: lsttptar,
			lstvlper: lstvlper,
			lstvlmin: lstvlmin,
			lstvlmax: lstvlmax,
			lstcdcop: lstcdcop,
			lstconve: lstconve,
			nrconven: nrconven,
			cdocorre: cdocorre,
			cdlcremp: cdlcremp,
			lstlcrem: lstlcrem,
			cdinctar: cdinctar,
			tpcobtar: flgtiptar,
			vlpertar: vlperc,
			vlmintar: vlminimo,
			vlmaxtar: vlmaximo,
			cdtipcat: cdtipcat,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();				
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});	

} 


function realizaOperacao() {

	$('input,select', '#frmCab').removeClass('campoErro'); /* Remove foco de erro */

	cddopcao = $('#cddopcao','#frmCab').val();
	
	if ( $('#cddgrupo','#frmCab').val() <= 0 )	{
		showError('error','Codigo de Grupo deve ser Informado.','Alerta - Ayllos',"focaCampoErro(\'cddgrupo\', \'frmCab\');");
		return false;
	}
	
	if ( $('#cdsubgru','#frmCab').val() <= 0 )	{
		showError('error','Codigo do Sub-Grupo deve ser Informado.','Alerta - Ayllos',"focaCampoErro(\'cdsubgru\', \'frmCab\');");
		return false;
	}
	
	if ( $('#cdcatego','#frmCab').val() <= 0 )	{
		showError('error','Codigo da Categoria deve ser Informado.','Alerta - Ayllos',"focaCampoErro(\'cdcatego\', \'frmCab\');");
		return false;
	}
	
	if ( $('#dstarifa','#frmCab').val() == '' )	{
		showError('error','Descrição da Tarifa deve ser Informado.','Alerta - Ayllos',"focaCampoErro(\'dstarifa\', \'frmCab\');");
		return false;
	}
	
	
	if ( $('#cdmotivo','#frmCab').val() != '' )	{
	
		if ( $('#cdmotivo','#frmCab').val().length  == 1 )	{
			showError('error','Codigo do motivo deve ter duas posições.','Alerta - Ayllos',"focaCampoErro(\'cdmotivo\', \'frmCab\');");
			return false;
		}
	}
	
	// Mostra mensagem de aguardo
	if (cddopcao == "C"){  	   showMsgAguardo("Aguarde, consultando Tarifas..."); } 
	else if (cddopcao == "X"){ showMsgAguardo("Aguarde, consultando Tarifas...");  }
	else if (cddopcao == "I"){ showMsgAguardo("Aguarde, incluindo Tarifas...");  }
	else if (cddopcao == "A"){ showMsgAguardo("Aguarde, alterando Tarifas...");  }	
	else if (cddopcao == "E"){ showMsgAguardo("Aguarde, excluindo Tarifas...");  }	
	else { showMsgAguardo("Aguarde, liberando aplicacao..."); }
	
	var cdsubgru = $('#cdsubgru','#frmCab').val();
	var cdtarifa = $('#cdtarifa','#frmCab').val();
	cdtarifa = normalizaNumero(cdtarifa);
	var dstarifa = $('#dstarifa','#frmCab').val();
	var cdcatego = $('#cdcatego','#frmCab').val();
	cdcatego = normalizaNumero(cdcatego);
	var inpessoa = $('#inpessoa','#frmCab').val();	
	inpessoa = normalizaNumero(inpessoa);	
	var cdocorre = $('#cdocorre','#frmCab').val();
	cdocorre = normalizaNumero(cdocorre);
	var cdmotivo = $('#cdmotivo','#frmCab').val();	
	var cdinctar = $('#cdinctar','#frmCab').val();
	cdinctar = normalizaNumero(cdinctar);
	var flglaman = $('#flglaman','#frmCab').prop("checked");
	
	
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadtar/manter_rotina.php", 
		data: {
			cddopcao: cddopcao,
			cdtarifa: cdtarifa,
			dstarifa: dstarifa,
			cdcatego: cdcatego,
			inpessoa: inpessoa,
			cdocorre: cdocorre,
			cdinctar: cdinctar,
			cdmotivo: cdmotivo,
			flglaman: flglaman,
			cdsubgru: cdsubgru,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();				
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});	

}

function buscaSequencialDetalhamento(){

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, buscando novo c&oacute;digo...");
	

	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadtar/busca_sequencial_detalhamento.php", 
		data: {
			cddopcao: cddopcao,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});			

	return false;
	
}	


function controlaCamposInclusao(){

	$('#cddopcao','#frmCab').desabilitaCampo();
	$('#btnOK','#frmCab').desabilitaCampo();
	$('#cddgrupo','#frmCab').desabilitaCampo();
	$('#dsdgrupo','#frmCab').desabilitaCampo();
	$('#cdsubgru','#frmCab').desabilitaCampo();
	$('#dssubgru','#frmCab').desabilitaCampo();
	$('#cdcatego','#frmCab').desabilitaCampo();
	$('#dscatego','#frmCab').desabilitaCampo();
	$('#cdtarifa','#frmCab').desabilitaCampo();
	$('#dstarifa','#frmCab').desabilitaCampo();
	$('#inpessoa','#frmCab').desabilitaCampo();
	$('#cdinctar','#frmCab').desabilitaCampo();
	$('#cdocorre','#frmCab').desabilitaCampo();
	$('#cdmotivo','#frmCab').desabilitaCampo();
	trocaBotao('');
	
	$("#divDetalhamento").toggle();	
	$("#divParametro").toggle();	
	
	unblockBackground();
	
	carregaDetalhamento();
	
}

function controlaCamposInclusaoDet(){
	
	$('#vlinifvl','#frmDetalhaTarifa').desabilitaCampo();
	$('#vlfinfvl','#frmDetalhaTarifa').desabilitaCampo();
	$('#cdhistor','#frmDetalhaTarifa').desabilitaCampo();
	$('#dshistor','#frmDetalhaTarifa').desabilitaCampo();
	$('#cdhisest','#frmDetalhaTarifa').desabilitaCampo();
	$('#dshisest','#frmDetalhaTarifa').desabilitaCampo();	
	
}


function controlaPesquisa( valor ) {

	$("#divCabecalhoPesquisa").css("width","100%");
	$("#divResultadoPesquisa").css("width","100%");

	switch( valor )
	{
		case 1:
			controlaPesquisaGrupo();
			break;
		case 2:
			controlaPesquisaSubGrupo();
			break;
		case 3:
			controlaPesquisaCategoria();
			break;		
		case 4:
			controlaPesquisaHistorico();
			break;
		case 5:
			controlaPesquisaHisest();
			break;
		case 6:
			controlaPesquisaTarifa();
			break;
	    case 7:
			controlaPesquisaParametro();
			break;
	    case 8:
			controlaPesquisaCoop();
			break;
		case 9:
			controlaPesquisaConvenio();
			break;
		case 10:
			controlaPesquisaLinhaCredito();
			break;
			
	}
}

function controlaPesquisaTarifa() {

	// Se esta desabilitado o campo 
	if ($("#cdtarifa","#frmCab").prop("disabled") == true)  {
		return;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdtarifa, titulo_coluna, cdtarifas, dstarifa, cddgrupo;
    var dsdgrupo, cdsubgru, dssubgru, cdcatego, dscatego, cdinctar, inpessoa, flglaman;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmCab';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdtarifa = $('#cdtarifa','#'+nomeFormulario).val();
	cdtarifas = cdtarifa;	
	dstarifa = '';
	cddgrupo = $("#cddgrupo","#frmCab").val();
	dsdgrupo = '';
	dssubgru = '';
	dscatego = '';
	cdsubgru = $("#cdsubgru","#frmCab").val();
	cdcatego = $("#cdcatego","#frmCab").val();
	
	titulo_coluna = "Tarifas";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-tarifas';
	titulo      = 'Tarifas';
	qtReg		= '20';	
	filtros 	=           'Grupo;cddgrupo;100px;N;'    + cddgrupo + ';N|Desc;dsdgrupo;150px;N;'      + dsdgrupo + ';N|'; //GRUPO
	filtros     = filtros + 'Subgrupo;cdsubgru;100px;N;' + cdsubgru + ';N|Desc;dssubgru;150px;N;'      + dssubgru + ';N|'; //SUBGRUPO
	filtros     = filtros + 'Categoria;cdcatego;100px;N;' + cdcatego + ';N|Desc;dscatego;150px;N;'     + dssubgru + ';N|'; //CATEGORIA
	filtros     = filtros + 'Codigo;cdtarifa;100px;S;'   + cdtarifa + ';S|Descricao;dstarifa;300px;S;' + dstarifa + ';S';  //TARIFA
	colunas 	=           'Cod;cddgrupo;4%;right|Grupo;dsdgrupo;21%;left|'                  //GRUPO
	colunas     = colunas + 'Cod;cdsubgru;4%;right|SubGrupo;dssubgru;21%;left|'               //SUBGRUPO
	colunas     = colunas + 'Cod;cdcatego;4%;right|Categoria;dscatego;21%;left|'              //CATEGORIA
	colunas     = colunas + 'Cod;cdtarifa;4%;right|' + titulo_coluna + ';dstarifa;21%;left';  //TARIFA
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cdtarifa\',\'#frmCab\').val()');	
	$("#divPesquisa").css("left","258px");
	$("#divPesquisa").css("top","91px");
	$("#divCabecalhoPesquisa > table").css("width","875px");
	$("#divCabecalhoPesquisa > table").css("float","left");
	$("#divResultadoPesquisa > table").css("width","890px");
	$("#divCabecalhoPesquisa").css("width","890px");
	$("#divResultadoPesquisa").css("width","890px");
	
	return false;

}

function controlaPesquisaGrupo() {

	// Se esta desabilitado o campo 
	if ($("#cddgrupo","#frmCab").prop("disabled") == true)  {
		return;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cddgrupo, titulo_coluna, cdgrupos, dsdgrupo;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmCab';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cddgrupo = $('#cddgrupo','#'+nomeFormulario).val();
	cdgrupos = cddgrupo;	
	dsdgrupo = '';
	
	titulo_coluna = "Grupos de produto";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-grupos';
	titulo      = 'Grupos';
	qtReg		= '20';
	filtros 	= 'Codigo;cddgrupo;100px;S;' + cddgrupo + ';S|Descricao;dsdgrupo;300px;S;' + dsdgrupo + ';S';
	colunas 	= 'Codigo;cddgrupo;20%;right|' + titulo_coluna + ';dsdgrupo;50%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cddgrupo\',\'#frmCab\').val()');
	
	return false;
}

function controlaPesquisaSubGrupo(){

	// Se esta desabilitado o campo 
	if ($("#cdsubgru","#frmCab").prop("disabled") == true)  {
		return;
	}	
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdsubgru, titulo_coluna;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmCab';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdsubgru = $('#cdsubgru','#'+nomeFormulario).val();
	var cddgrupo  = $('#cddgrupo','#'+nomeFormulario).val();
	dssubgru = '';
	
	titulo_coluna = "Sub-grupos de produto";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-subgrupos';
	titulo      = 'Sub-grupos';
	qtReg		= '20';
	filtros 	= 'Grupo;cddgrupo;100px;N;' + cddgrupo + ';S|Codigo;cdsubgru;100px;S;' + cdsubgru + ';S|Descricao;dssubgru;300px;S;' + dssubgru + ';S';
	colunas 	= 'Grupo;cddgrupo;15%;right|Codigo;cdsubgru;15%;right|' + titulo_coluna + ';dssubgru;65%;left';
	
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cdsubgru\',\'#frmCab\').focus()');

	$("#divCabecalhoPesquisa > table").css("width","560px");
	$("#divResultadoPesquisa > table").css("width","100%");
	$("#divCabecalhoPesquisa > table").css("float","left");
	$("#divCabecalhoPesquisa").css("width","580px");
	$("#divResultadoPesquisa").css("width","100%");	

	
	return false;
}

function verifica_campos(cddgrupo, dsdgrupo, cdsubgru, dssubgru){

	var nomeFormulario = 'frmCab';
	
	if(($('#cddgrupo','#'+nomeFormulario).val() == '') ||
		($('#cddgrupo','#'+nomeFormulario).val() == '0')){
	
		$('#cddgrupo','#'+nomeFormulario).val(cddgrupo);
		$('#dsdgrupo','#'+nomeFormulario).val(dsdgrupo);
		
	}
	
	if(($('#cdsubgru','#'+nomeFormulario).val() == '') ||
		($('#cdsubgru','#'+nomeFormulario).val() == '0')){
	
		$('#cdsubgru','#'+nomeFormulario).val(cdsubgru);
		$('#dssubgru','#'+nomeFormulario).val(dssubgru);
		
	}	
	
	$("#cdcatego","#frmCab").focus();

	return false;
}	


function controlaPesquisaCategoria() {

	// Se esta desabilitado o campo contrato
	if ($("#cdcatego","#frmCab").prop("disabled") == true)  {
		return;
	}	

	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, titulo_coluna, cdgrupos, dscatego;	
	var aux_cddgrupo, aux_dsdgrupo, aux_cdsubgru, aux_dssubgru;
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmCab';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdtipcat = $('#cdtipcat','#'+nomeFormulario).val();
	var cddgrupo = $('#cddgrupo','#'+nomeFormulario).val();
	var cdsubgru = $('#cdsubgru','#'+nomeFormulario).val();
	var cdcatego = $('#cdcatego','#'+nomeFormulario).val();
	var dsdgrupo = $('#dsdgrupo','#'+nomeFormulario).val();
	var dssubgru = $('#dssubgru','#'+nomeFormulario).val();
	
	cdtipcat = normalizaNumero( cdtipcat );
	cddgrupo = normalizaNumero( cddgrupo );
	cdsubgru = normalizaNumero( cdsubgru );
	cdcatego = normalizaNumero( cdcatego );	
	
	aux_cddgrupo = cddgrupo;
	aux_dsdgrupo = dsdgrupo;
	aux_cdsubgru = cdsubgru;
	aux_dssubgru = dssubgru;
	
	dscatego = '';
	
	titulo_coluna = "Categoria";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-categorias';
	titulo      = 'Descricao';
	qtReg		= '20';
	filtros 	= 'Grupo;cddgrupo;130px;N;' + cddgrupo + ';N|' + 'SubGrupo;cdsubgru;130px;N;' + cdsubgru + ';N|' +
	              'Tipo Categoria;cdtipcat;130px;S;' + cdtipcat + ';S|' + 'Categoria;cdcatego;130px;S;' + cdcatego + ';S|' +
				  'Descricao;dscatego;300px;S;' + dscatego + ';S';
	colunas 	= 'Grupo;cddgrupo;15%;right|SubGrupo;cdsubgru;15%;right|Tipo;cdtipcat;10%;right|' +
	              'Codigo;cdcatego;15%;right|' + titulo_coluna + ';dscatego;50%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','verifica_campos(' + aux_cddgrupo + ', "' + aux_dsdgrupo + '", ' + aux_cdsubgru + ', "' + aux_dssubgru + '")');	
	
	$("#divPesquisa").css("left","258px");
	$("#divPesquisa").css("top","91px");
	$("#divCabecalhoPesquisa > table").css("width","675px");
	$("#divCabecalhoPesquisa > table").css("float","left");
	$("#divResultadoPesquisa > table").css("width","690px");
	$("#divCabecalhoPesquisa").css("width","690px");
	$("#divResultadoPesquisa").css("width","690px");
	
	return false;	
}

function controlaPesquisaHistorico() {

	// Se esta desabilitado o campo 
	if ($("#cdhistor","#frmDetalhaTarifa").prop("disabled") == true)  {
		return;
	}
	
	$('input,select', '#frmDetalhaTarifa').removeClass('campoErro'); /* Remove foco de erro */
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdhistor, titulo_coluna, cdgrupos, dshistor;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmDetalhaTarifa';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdhistor = $('#cdhistor','#'+nomeFormulario).val();
	cdhistor = cdhistor;	
	dshistor = '';
	
	titulo_coluna = "Historicos";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-historicos';
	titulo      = 'Historicos';
	qtReg		= '20';
	filtros 	= 'Codigo;cdhistor;80px;S;' + cdhistor + ';S|Descricao;dshistor;280px;S;' + dshistor + ';S';
	colunas 	= 'Codigo;cdhistor;20%;right|' + titulo_coluna + ';dshistor;50%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,$('#divRotina'),'$(\'#cdhistor\',\'#frmDetalhaTarifa\').val()');
	
	return false;
}

function controlaPesquisaHisest() {

	// Se esta desabilitado o campo 
	if ($("#cdhisest","#frmDetalhaTarifa").prop("disabled") == true)  {
		return;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdhisest, titulo_coluna, cdgrupos, dshisest, nriniseq;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmDetalhaTarifa';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdhisest = $('#cdhisest','#'+nomeFormulario).val();	
	cdhisest = normalizaNumero(cdhisest);		
	dshisest = '';
	
	titulo_coluna = "Historicos";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-historicos';
	titulo      = 'Historicos';
	qtReg		= '20';
	nriniseq    = '1';
	filtros 	= 'Codigo;cdhisest;80px;S;' + cdhisest + ';S|Descricao;dshisest;280px;S;' + dshisest + ';S';
	colunas 	= 'Codigo;cdhistor;20%;right|' + titulo_coluna + ';dshistor;50%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,$('#divRotina'),'$(\'#cdhisest\',\'#frmDetalhaTarifa\').val()');
	
	return false;
}

function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>');
	
	if ( botao == 'btnConcluir') {
		$('#divBotoes','#divTela').append('&nbsp;<a href="#" class="botao" onClick="btnConcluir()" return false;" >Prosseguir</a>');
		return false;
	}

	if ( botao != '') {
		$('#divBotoes','#divTela').append('&nbsp;<a href="#" class="botao" onClick="realizaOperacao()" return false;" >'+botao+'</a>');
	}
	
	return false;
}

function buscaSequencial(){

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, buscando novo c&oacute;digo...");

	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadtar/busca_sequencial.php", 
		data: {
			cddopcao: cddopcao,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});				
	
}

function buscaDados( valor ) {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, consultando...");
	
	switch( valor )
	{
		case 1:
		  buscaDadosGrupo();		  		  
		  break;
		case 2:		  
		  buscaDadosSubGrupo();
		  break;
		case 3:		
		  buscaDadosCategoria();
		  break;
	}
}

function buscaDadosGrupo(){

	var cddgrupo = $('#cddgrupo','#frmCab').val();
	cddgrupo = normalizaNumero(cddgrupo);

	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadtar/busca_dados_grupo.php", 
		data: {
			cddgrupo: cddgrupo,
			cddopcao: cddopcao,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});					
	
}

function buscaDadosSubGrupo(){

	var cdsubgru = $('#cdsubgru','#frmCab').val();		
	cdsubgru = normalizaNumero(cdsubgru);		
	
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadtar/busca_dados_subgrupo.php", 
		data: {
			cdsubgru: cdsubgru,
			cddopcao: cddopcao,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});					


}

function buscaDadosCategoria(){

	var cdcatego = $('#cdcatego','#frmCab').val();		
	cdcatego = normalizaNumero(cdcatego);		
	
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadtar/busca_dados_categoria.php", 
		data: {
			cdcatego: cdcatego,
			cddopcao: cddopcao,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});					


}

function formataDetalhamento() {

	$('#divRotina').css('width','640px');

	var divRegistro = $('div.divRegistros','#divDetalhamento');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'100px','width':'100%'});
	
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];	
	
	var arrayLargura = new Array();
	arrayLargura[0] = '40px';
	arrayLargura[1] = '100px';
	arrayLargura[2] = '100px';
	arrayLargura[3] = '180px';
	
		
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'left';
	arrayAlinha[4] = 'left';
	
	var metodoTabela = '';
			
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );
	
	glbTabCdfaixav = '';
	
	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		glbTabCdfaixav = $(this).find('#cdfaixav > span').text() ;
		glbTabVlinifvl = $(this).find('#vlinifvl > span').text() ;
		glbTabVlfinfvl = $(this).find('#vlfinfvl > span').text() ;
		glbTabCdhistor = $(this).find('#cdhistor > span').text() ;
		glbTabCdhisest = $(this).find('#cdhisest > span').text() ;
		glbTabDshistor = $(this).find('#cdhistor > #tabdshistor').val() ;
		glbTabDshisest = $(this).find('#cdhisest > #tabdshisest').val() ;
	});
	
	$('table > tbody > tr:eq(0)', divRegistro).click();
	
	return false;
}

function formataTabDetalhamento() {

	var divRegistro = $('#divTabDetalhamento');		
	var tabela      = $('#tituloRegistros', divRegistro );
	var linha       = $('#tituloRegistros > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'180px','width':'100%'});
	
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];	
	
	//var aux_cdtipcat = normalizaNumero($('#cdtipcat','#frmCab').val()) ;
	//if ( ( aux_cdtipcat == 2 ) || ( aux_cdtipcat == 3 ) )  { /* 2 - Convenio    3 - Linha Credito */ 
	//	arrayLargura[0] = '120px';
	//}
	
	if(normalizaNumero($('#cdtipcat','#frmCab').val()) == 2 || normalizaNumero($('#cdtipcat','#frmCab').val()) == 3){ // convenio ou linha de credito
	var arrayLargura = new Array();
		arrayLargura[0] = '111px';
		arrayLargura[1] = '63px';
		arrayLargura[2] = '63px';
		arrayLargura[3] = '82px';
		arrayLargura[4] = '82px';
		arrayLargura[5] = '57px';
		arrayLargura[6] = '57px';
		arrayLargura[7] = '57px';
		arrayLargura[8] = '57px';
		arrayLargura[9] = '57px';
		arrayLargura[10] = '57px';
		arrayLargura[11] = '123px';
	}else{
		var arrayLargura = new Array();
		arrayLargura[0] = '107px';
		arrayLargura[1] = '80px';
		arrayLargura[2] = '80px';
		arrayLargura[3] = '82px';
		arrayLargura[4] = '82px';
		arrayLargura[5] = '57px';
		arrayLargura[6] = '57px';
		arrayLargura[7] = '57px';
		arrayLargura[8] = '57px';
		arrayLargura[9] = '57px';
		arrayLargura[10] = '57px';
		arrayLargura[11] = '201px';
	}
	
	
	
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'right';
	arrayAlinha[6] = 'right';
	arrayAlinha[7] = 'right';
	arrayAlinha[8] = 'right';
	arrayAlinha[9] = 'right';
	arrayAlinha[10] = 'right';
	arrayAlinha[11] = 'center';
	
	var metodoTabela = '';
	var divRegistro = $('div.divRegistros','#divTabDetalhamento');	
	
	glbFcoCdcooper = '';
	
	// seleciona o registro que é clicado 
	$('#tituloRegistros > tbody > tr', divRegistro).click( function() {
		glbFcoCdcooper = $(this).find('#cdcooper > span').text() ;
		glbFcoDtdivulg = $(this).find('#dtdivulg > span').text() ;
		glbFcoDtvigenc = $(this).find('#dtvigenc > span').text() ;
		glbFcoVltarifa = $(this).find('#vltarifa > span').text() ;
		glbFcoVlrepass = $(this).find('#vlrepass > span').text() ;	
		glbFcoNmrescop = $(this).find('#cdcooper > #tabnmrescop').val() ;
		glbFcoCdfvlcop = $(this).find('#cdcooper > #tabcdfvlcop').val() ;
		glbFcoCdfaixav = $('#cdfaixav','#frmDetalhaTarifa').val();	 
		glbFcoNrconven = $(this).find('#nrconven > #tabnrconven').val() ;
		glbFcoDsconven = $(this).find('#nrconven > #tabdsconven').val() ;	
		glbFcoCdlcremp = $(this).find('#cdlcremp > #tabcdlcremp').val() ;
		glbFcoDslcremp = $(this).find('#cdlcremp > #tabdslcremp').val() ;
		gblFcoTpcobtar = $(this).find('#tpcobtar > span').text() ;
		gblFcoVlpertar = $(this).find('#vlpertar > span').text() ;
		gblFcoVlmintar = $(this).find('#vlmintar > span').text() ;
		gblFcoVlmaxtar = $(this).find('#vlmaxtar > span').text() ;
		
		if (glbFcoCdlcremp == 0) {
			glbFcoDslcremp = "LINHA PADRAO";
		}
		
	});
	
	$('#tituloRegistros > tbody > tr:eq(0)', divRegistro).click();

		
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );
	
	$('#flgtodos','#divBotoesDetalhaTarifa').unbind('click').bind('click', function(e) {
		
		if( $(this).prop("checked") == true ){
			$(this).val("TRUE");	
			carregaAtribuicaoDetalhamento();
		}else{
			$(this).val("FALSE");	
			carregaAtribuicaoDetalhamento();
		}		
			
	});
	
	/* Tratamento para ocultar coluna convenio quando nao for cobranca */
//	if ( ( normalizaNumero($('#cdocorre','#frmCab').val()) != 0 ) || ( $('#cdmotivo','#frmCab').val() != "" ) )  { 	/* Daniel*/
	if ( normalizaNumero($('#cdtipcat','#frmCab').val()) != 2 ) { /* 2 - Convenio */
	
		var arrayOculta = new Array();
		arrayOculta[1] = 'none'; /* Coluna Convenio */
		
		// Calcula o número de colunas Total da tabela
		var nrColTotal = $('thead > tr > th', tabela ).length;
			
		// Formatando - Exibicao Coluna
		if (typeof arrayOculta != 'undefined') {
			for( var i in arrayOculta ) {
				var nrColAtual = i;
				nrColAtual++;
				$('td:nth-child('+nrColTotal+'n+'+nrColAtual+')', tabela ).css('display', arrayOculta[i] );		
			}		
		}
			
		var divRegistro = tabela.parent();
		var tabelaTitulo = $( 'table.tituloRegistros',divRegistro.parent() );	
			
		var arrayCabOculta = new Array();
			arrayCabOculta[1] = 'none'; /* Coluna Convenio */
		
		// Formatando - Exibicao Titulo
		if (typeof arrayCabOculta != 'undefined') {
			for( var i in arrayCabOculta ) {
				$('th:eq('+i+')', tabelaTitulo ).css('display', arrayCabOculta[i] );
			}		
		}
		
	}
	
	
	/* Tratamento para ocultar coluna linha credito quando nao for credito */
	if ( normalizaNumero($('#cdtipcat','#frmCab').val()) != 3 ) { /* 3 - Linha Credito */
	// if ( ( normalizaNumero($('#cdcatego','#frmCab').val()) != 6 ) )  { 	/* Daniel */
	
		var arrayOculta = new Array();
		arrayOculta[2] = 'none'; /* Coluna Linha Credito */
		
		// Calcula o número de colunas Total da tabela
		var nrColTotal = $('thead > tr > th', tabela ).length;
			
		// Formatando - Exibicao Coluna
		if (typeof arrayOculta != 'undefined') {
			for( var i in arrayOculta ) {
				var nrColAtual = i;
				nrColAtual++;
				$('td:nth-child('+nrColTotal+'n+'+nrColAtual+')', tabela ).css('display', arrayOculta[i] );		
			}		
		}
			
		var divRegistro = tabela.parent();
		var tabelaTitulo = $( 'table.tituloRegistros',divRegistro.parent() );	
			
		var arrayCabOculta = new Array();
			arrayCabOculta[2] = 'none'; /* Coluna Linha Credito */
		
		// Formatando - Exibicao Titulo
		if (typeof arrayCabOculta != 'undefined') {
			for( var i in arrayCabOculta ) {
				$('th:eq('+i+')', tabelaTitulo ).css('display', arrayCabOculta[i] );
			}		
		}
		
	}
	
}

// Detalhamento Tarifa
function mostraDetalhamentoTarifa( value ) {

	cddopdet = value;
	
	if ( (glbTabCdfaixav == '') && ( cddopdet != 'I' ) ){
		showError('error','Não há registro selecionado','Alerta - Ayllos',"unblockBackground()");
		return false
	}
	
	showMsgAguardo('Aguarde, buscando detalhamento de tarifas...');

	// Executa script através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadtar/detalhamento_tarifa.php', 
		data: {			
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			buscaDetalhaTarifa();
		}				
	});
	
	return false;
	
}


function buscaDetalhaTarifa() {
		
	showMsgAguardo('Aguarde, buscando detalhamento de tarifas...');

	var cdfaixav = normalizaNumero($('#cdfaixav', '#'+frmCab).val());	
	var cdtarifa = normalizaNumero($('#cdtarifa', '#'+frmCab).val());
	
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadtar/busca_detalha_tarifa.php', 
		data: {
			cdfaixav: cdfaixav,
			cdtarifa: cdtarifa,
			cddopdet: cddopdet,
			redirect: 'script_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {
		
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divConteudoOpcao').html(response);
					exibeRotina($('#divRotina'));
					formataDetalhaTarifa();
					
					
					bloqueiaFundo($('#divRotina'));
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			} else {
				try {
					eval( response );
					controlaFoco();
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		}				
	});
	return false;
}

function formataDetalhaTarifa() {

	$('#divRotina').css('width','900px');

	var frmDetalhaTarifa = "frmDetalhaTarifa";

 	// Rotulos 
	var rCdfaixav	= $('label[for="cdfaixav"]','#'+frmDetalhaTarifa);
	var rCdtarifa	= $('label[for="cdtarifa"]','#'+frmDetalhaTarifa);
	var rVlinifvl	= $('label[for="vlinifvl"]','#'+frmDetalhaTarifa);
	var rVlfinfvl	= $('label[for="vlfinfvl"]','#'+frmDetalhaTarifa);
	var rCdhistor	= $('label[for="cdhistor"]','#'+frmDetalhaTarifa);
	var rCdhisest	= $('label[for="cdhisest"]','#'+frmDetalhaTarifa);
	
	rCdfaixav.addClass('rotulo').css('width','140px');
	rCdtarifa.addClass('rotulo').css('width','140px');
	rVlinifvl.addClass('rotulo').css('width','132px');
	rVlfinfvl.addClass('rotulo').css('width','132px');
	rCdhistor.addClass('rotulo').css('width','140px');
	rCdhisest.addClass('rotulo').css('width','140px');
	
	// Campos
	var cTodos	  	= $('input[type="text"],select','#'+frmDetalhaTarifa);
	var cCdfaixav	= $('#cdfaixav','#'+frmDetalhaTarifa);	
	var cCdtarifa	= $('#cdtarifa','#'+frmDetalhaTarifa);	
	var cDstarifa	= $('#dstarifa','#'+frmDetalhaTarifa);	
	var cVlinifvl	= $('#vlinifvl','#'+frmDetalhaTarifa);	
	var cVlfinfvl	= $('#vlfinfvl','#'+frmDetalhaTarifa);	
	var cCdhistor	= $('#cdhistor','#'+frmDetalhaTarifa);	
	var cDshistor	= $('#dshistor','#'+frmDetalhaTarifa);	
	var cCdhisest	= $('#cdhisest','#'+frmDetalhaTarifa);
	var cDshisest	= $('#dshisest','#'+frmDetalhaTarifa);		

	cTodos.habilitaCampo();
	cCdfaixav.css('width','90px').desabilitaCampo();
	cCdtarifa.css('width','90px').desabilitaCampo();
	cDstarifa.css('width','368px').desabilitaCampo();
	cVlinifvl.addClass('moeda').css('width','100px');
	cVlfinfvl.addClass('moeda').css('width','100px');
	cCdhistor.css('width','60px').attr('maxlength','5').setMask('INTEGER','zzzzz','','');;
	cDshistor.css('width','378px').desabilitaCampo();;
	cCdhisest.css('width','60px').attr('maxlength','5').setMask('INTEGER','zzzzz','','');;
	cDshisest.css('width','378px').desabilitaCampo();;
		
	layoutPadrao();
	hideMsgAguardo();
	
	if ( cddopdet == 'X' ) {
		// Desabilita campos do formulario frmDetalhaTarifa quando opção consulta (C).
		$('#cdfaixav','#frmDetalhaTarifa').desabilitaCampo();
		$('#vlinifvl','#frmDetalhaTarifa').desabilitaCampo();
		$('#vlfinfvl','#frmDetalhaTarifa').desabilitaCampo();
		$('#cdhistor','#frmDetalhaTarifa').desabilitaCampo();
		$('#cdhisest','#frmDetalhaTarifa').desabilitaCampo();
		$('#dshistor','#frmDetalhaTarifa').desabilitaCampo();
		$('#dshisest','#frmDetalhaTarifa').desabilitaCampo();
	}
	
	$('#vlinifvl','#frmDetalhaTarifa').focus();
	
	return false;
}


function controlafrmDetalhaTarifa() {

	$('#vlinifvl','#frmDetalhaTarifa').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#vlfinfvl','#frmDetalhaTarifa').focus();
			return false;
		}	
	});		
	
	$('#vlfinfvl','#frmDetalhaTarifa').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#cdhistor','#frmDetalhaTarifa').focus();
			return false;
		}	
	});
	
	$('#cdhistor','#frmDetalhaTarifa').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
		    if ( $(this).val() != '' ){
				buscaHistRepetido();
			}	
			$('#cdhisest','#frmDetalhaTarifa').focus();
			return false;
		}	
	});			
	
	$('#cdhistor','#frmDetalhaTarifa').unbind('blur').bind('blur', function() {
	            if($(this).val() != ""){
					buscaHistRepetido();
				}
				return false;
	});
	
	$('#cdhisest','#frmDetalhaTarifa').unbind('blur').bind('blur', function() {
				if ( $(this).val() != '' ){
					buscaHisest();
					buscaHistRepetido();
				}
				return false;
	});
	
	$('#cdhisest','#frmDetalhaTarifa').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			if ( $(this).val() != '' ){
				buscaHisest();
				buscaHistRepetido();
			}
			return false;
		}	
	});
		
}

// Vinculação Parâmetros Tarifa
function mostraVinculacaoParametro(value) {

	cddoppar = value;
	
	showMsgAguardo('Aguarde, buscando parâmetro de tarifas vinculação...');

	// Executa script através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadtar/vinculacao_parametro.php', 
		data: {
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			buscaVinculacaoParametro();
		}				
	});
	return false;
	
}

// Busca informações Vinculação de Parâmetro
function buscaVinculacaoParametro() {
		
	showMsgAguardo('Aguarde, buscando parâmetro de tarifas...');

	var cdfaixav = normalizaNumero($('#cdfaixav', '#'+frmCab).val());	
	var cdtarifa = normalizaNumero($('#cdtarifa', '#'+frmCab).val());
	var dstarifa = $('#dstarifa', '#'+frmCab).val();
	
	// Executa script através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadtar/busca_vinculacao_parametro.php', 
		data: {
			cdfaixav: cdfaixav,
			cdtarifa: cdtarifa,
			dstarifa: dstarifa,
			redirect: 'script_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {
		
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divConteudoVinculaPar').html(response);
					exibeRotina($('#divRotina'));
					formataVinculacaoParametro();
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			} else {
				try {
					eval( response );
					controlaFoco();
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		}				
	});
	return false;
}

// Formata form formVinculaParametro no fonte form_vinculacao_parametro.php
function formataVinculacaoParametro() {

	$('input,select', '#formVinculaParametro').removeClass('campoErro'); /* Remove foco de erro */

	$('#divConteudoVinculaPar', '#formVinculaParametro').css({'width':'600px'});
		
 	// Rotulos 
	var rCddopcao	= $('label[for="cddopcao"]','#'+frmVinculacaoParametro);
	var rDstarifa	= $('label[for="dstarifa"]','#'+frmVinculacaoParametro);
	var rCdpartar	= $('label[for="cdpartar"]','#'+frmVinculacaoParametro);
	
	rCddopcao.addClass('rotulo').css('width','75px');
	rDstarifa.addClass('rotulo').css('width','75px');
	rCdpartar.addClass('rotulo').css('width','75px');
	
	// Campos
	var cTodos	  	= $('input[type="text"],select','#'+frmVinculacaoParametro);
	var cCddopcao	= $('#cddopcao','#'+frmVinculacaoParametro);	
	var cDstarifa	= $('#dstarifa','#'+frmVinculacaoParametro);	
	var cCdpartar	= $('#cdpartar','#'+frmVinculacaoParametro);	
	var cNmpartar	= $('#nmpartar','#'+frmVinculacaoParametro);	

	cTodos.desabilitaCampo();
	cCddopcao.css('width','514px');
	cDstarifa.css('width','513px');
	cCdpartar.addClass('inteiro').css('width','90px').attr('maxlength','10').habilitaCampo();
	cNmpartar.css('width','400px');
	
	// Vincular Parametro
	if (cddoppar == 'V') { 
		$('#btVincular','#divBotoesVinculacaoParametro').hide();
		$('#btDesvincular','#divBotoesVinculacaoParametro').hide();
		$('#btProsseguir','#divBotoesVinculacaoParametro').show();
	// Desvincular Parametro	
	} else { 
		$('#btVincular','#divBotoesVinculacaoParametro').hide();
		$('#btDesvincular','#divBotoesVinculacaoParametro').show();
		cCdpartar.desabilitaCampo();
	}
	
	$('#cdpartar','#frmVinculacaoParametro').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			if ( $('#cdpartar','#frmVinculacaoParametro').val() == '' ) {
				showError("error","C&oacute;digo do Par&acirc;metro deve ser informado.","Alerta - Ayllos","focaCampoErro(\'cdpartar\', \'frmVinculacaoParametro\');  bloqueiaFundo($('#divRotina'));",false);
				return false; }
			else {
				buscaDadosParametro();
			}
		}	
	});	
	
	layoutPadrao();
	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	$('#cdpartar','#frmVinculacaoParametro').focus();
	return false;
}

function buscaParametroCoop(){

	var cdpartar = $('#cdpartar','#frmVinculacaoParametro').val();

	showMsgAguardo('Aguarde, buscando parametro...');

	// Executa script através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadtar/busca_parametro_coop.php', 
		data: {			
			cddopcao: cddopcao,
			cdpartar: cdpartar,
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#tabVinculacaoParametro').html(response);		
			formataTabVinculacaoParametro();
			$('#cdpartar','#frmVinculacaoParametro').desabilitaCampo();
			hideMsgAguardo();
			bloqueiaFundo($('#divRotina'));
		}				
	});
	
	return false;
}

// Formata tabVinculacaoParametro no fonte form_vinculacao_parametro.php
function formataTabVinculacaoParametro() {

	var divRegistro = $('#tabVinculacaoParametro');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
	
	divRegistro.css({'height':'160px','width':'100%'});
	
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];	
	
	var arrayLargura = new Array();
	arrayLargura[0] = '120px';
	
		
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'left';
	
	var metodoTabela = '';
			
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );
	
	return false;
}


function buscaFlagIncidencia( codigo ){

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, consultando incidencia...");
	
	var cdinctar = $('#cdinctar','#frmCab').val();
	cdinctar = normalizaNumero(cdinctar);
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadtar/busca_incidencia.php", 
		data: {
			cdinctar: cdinctar,
			cddopcao: cddopcao,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});			
	
	return false;
}


function atribuiOperacao( valor ){

	if( valor == 1){

		$('#cdocorre','#frmCab').unbind('keypress').bind('keypress', function(e) {
				if ( e.keyCode == 9 || e.keyCode == 13 ) {	
					realizaOperacao();					
					return false;
				}	
		});
		
	} else {

		$('#cdmotivo','#frmCab').unbind('keypress').bind('keypress', function(e) {
				if ( e.keyCode == 9 || e.keyCode == 13 ) {	
					realizaOperacao();					
					return false;
				}	
		});
	
	}
}


// Atribuição de Detalhamento
function mostraAtribuicaoDetalhamento( value ) {

	cdatrdet = value;
	
	if ( ( cdatrdet != 'I') && (glbFcoCdcooper == '') )	{
		showError('error','Não há registro selecionado.','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}
	
	if ( ( cdatrdet != 'I') && ( cdatrdet != 'R') ){
		var data2 = glbFcoDtvigenc;
		var data3 = $('#glbdtmvtolt','#frmCab').val();
		
		// Vigencia
		var nova_data2 = parseInt(data2.split("/")[2].toString() + data2.split("/")[1].toString() + data2.split("/")[0].toString()); 
		
		// Data Sistema
		var nova_data3 = parseInt(data3.split("/")[2].toString() + data3.split("/")[1].toString() + data3.split("/")[0].toString()); 
		
		if ( ( cdatrdet == 'A') && ( nova_data2 <= nova_data3 ) )	{
			showError('error','Apenas permitido alteração de registros com Data de Vigência futura.','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')))");
			return false;
		}
	}
	
	showMsgAguardo('Aguarde, buscando atribuição de detalhamento...');

	// Executa script através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadtar/atribuicao_detalhamento.php', 
		data: {			
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divUsoGenerico').html(response);
			buscaAtribuicaoDetalhamento(cdatrdet);
			return false;
		}				
	});		
	
	return false;
	
}

function buscaSequencialAtribuicao(){

	var cddopcao = $('#cddopcao','#frmCab').val();

	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadtar/busca_sequencial_atribuicao.php", 
		data: {
			cddopcao : cddopcao,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
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

function buscaAtribuicaoDetalhamento(cdatrdet) {

	var cdfaixav = normalizaNumero($('#cdfaixav', '#'+frmCab).val());	
	var cdtarifa = normalizaNumero($('#cdtarifa', '#'+frmCab).val());
	var dstarifa = $('#dstarifa', '#frmDetalhaTarifa').val();
	var vlinifvl2 = normalizaNumero($('#vlinifvl', '#frmDetalhaTarifa').val());
	var vlfinfvl2 = normalizaNumero($('#vlfinfvl', '#frmDetalhaTarifa').val());
	var cdtipcat = normalizaNumero($('#cdtipcat', '#'+frmCab).val());
	
	var cddopfco = cdatrdet;	
	
	if (cdatrdet == 'I'){
		glbFcoVltarifa = '0';
		glbFcoVlrepass = '0';	
		gblFcoVlpertar = '0';	
		gblFcoVlmintar = '0';
		gblFcoVlmaxtar = '0';
		glbFcoCdfvlcop = '';
		glbFcoNrconven = '';
		glbFcoCdlcremp = '';
		gblFcoTpcobtar = ''; 
	}	

	var vltarifa2 = number_format(glbFcoVltarifa,2,',','');	
	var vlrepass2 = number_format(glbFcoVlrepass,2,',','');	
	
	var vlpertar = number_format(gblFcoVlpertar,2,',','');
	var vlmintar = number_format(gblFcoVlmintar,2,',','');
	var vlmaxtar = number_format(gblFcoVlmaxtar,2,',','');
	
	var nrconven = normalizaNumero(glbFcoNrconven);
	
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadtar/busca_atribuicao_detalhamento.php', 
		data: {
			cddopfco : cddopfco,
			cdtarifa : cdtarifa,
			dstarifa : dstarifa,
			vlinifvl2: vlinifvl2,
			vlfinfvl2: vlfinfvl2,
			cdfaixav : cdfaixav,
			cdfvlcop : glbFcoCdfvlcop,
			cdcooper : glbFcoCdcooper,	
			dtdivulg : glbFcoDtdivulg,
			dtvigenc : glbFcoDtvigenc,
			vltarifa : vltarifa2,
			vlrepass : vlrepass2,
			nmrescop : glbFcoNmrescop,
			nrconven : nrconven,
			dsconven : glbFcoDsconven,
			cdlcremp : glbFcoCdlcremp,
			dslcremp : glbFcoDslcremp,
			tpcobtar : gblFcoTpcobtar,
			vlpertar : vlpertar,
			vlmintar : vlmintar,
			vlmaxtar : vlmaxtar,
			cdtipcat : cdtipcat,
			redirect: 'script_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {
		
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divAtribuicaoDetalhamento').html(response);
					  
					$('#divRotina').css('visibility','hidden');
					exibeRotina($('#divUsoGenerico'));
					formataAtribuicaoDetalhamento();
					controlafrmAtribuicaoDetalhamento();
					
					if ( cdatrdet == 'A') {
						$('#cdcopaux','#frmAtribuicaoDetalhamento').desabilitaCampo();
						$('#dtdivulg','#frmAtribuicaoDetalhamento').focus();
						$('#btReplicar','#divBotoesfrmAtrDetalha').hide();
						
					} else {
					
							if ( cdatrdet == 'R') {
								$('#cdcopaux','#frmAtribuicaoDetalhamento').desabilitaCampo();
								$('#dtdivulg','#frmAtribuicaoDetalhamento').desabilitaCampo();
								$('#dtvigenc','#frmAtribuicaoDetalhamento').desabilitaCampo();
								$('#vltarifa2','#frmAtribuicaoDetalhamento').desabilitaCampo();
								$('#vlrepass2','#frmAtribuicaoDetalhamento').desabilitaCampo();
								$('#nrconven','#frmAtribuicaoDetalhamento').desabilitaCampo();
								$('#cdlcremp','#frmAtribuicaoDetalhamento').desabilitaCampo();
								$('label[for="flgtiptar"]','#frmAtribuicaoDetalhamento').css({'display':'none'});
								$('label[for="flgFixo"]','#frmAtribuicaoDetalhamento').css({'display':'none'});
								$('#flgfixo','#frmAtribuicaoDetalhamento').css({'display':'none'});
								$('label[for="flgPerc"]','#frmAtribuicaoDetalhamento').css({'display':'none'});
								$('#flgperc','#frmAtribuicaoDetalhamento').css({'display':'none'});
							} else {
								$('#cdcopaux','#frmAtribuicaoDetalhamento').focus();
								$('#btReplicar','#divBotoesfrmAtrDetalha').show();
							}
					}
					
					if ( cddopdet == 'X') {
						$('#btReplicar','#divBotoesfrmAtrDetalha').hide();
					} 
					
					if ( $('#glbcdcooper','#frmCab').val() != 3 ) {
						$('#cdcopaux','#frmAtribuicaoDetalhamento').desabilitaCampo();
						buscaCooperativa();
					}
					
					/* Tratamento para quando for cobranca mostrar campo convenio */
				//	if ( ( normalizaNumero($('#cdocorre','#frmCab').val()) != 0 ) || ( $('#cdmotivo','#frmCab').val() != "" ) )  { /* Daniel */
					if ( normalizaNumero($('#cdtipcat','#frmCab').val()) == 2 ) { /* 2 - Convenio */
						$('#divConvenio').css({'display':'block'});
					} else {
						$('#divConvenio').css({'display':'none'});
					}
					
					/* Tratamento para quando for credito mostrar campo linha credito */
				//	if ( ( normalizaNumero($('#cdcatego','#frmCab').val()) != 6 ) )  { 	/* Daniel */
					if ( normalizaNumero($('#cdtipcat','#frmCab').val()) == 3 ) { /* 3 - Linha Credito */
						$('#divLinhaCredito').css({'display':'block'});
					} else {
						$('#divLinhaCredito').css({'display':'none'});
					}
					
					aplicaClasse();
					hideMsgAguardo();
					bloqueiaFundo($('#divUsoGenerico'));
					bloqueiaFundo($('#divRotina'));
					
					if (cdatrdet == 'I'){
						buscaSequencialAtribuicao();
					}
					
					return false;
				} catch(error) {
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			} else {
				try {
					eval( response );
					controlaFoco();
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		}				
	});
	return false;
}

function replicaCooperativaDet(opReplica) {

	showMsgAguardo('Aguarde, buscando cooperativas...');

	var frmAtribDet = 'frmAtribuicaoDetalhamento';

	var cdfaixav  = normalizaNumero($('#cdfaixav', '#frmDetalhaTarifa').val());	
	var cdtarifa  = normalizaNumero($('#cdtarifa', '#'+frmAtribDet).val());
	var dtdivulg  = $('#dtdivulg', '#'+frmAtribDet).val();
	var dtvigenc  = $('#dtvigenc', '#'+frmAtribDet).val();
	var vlrepass  = normalizaNumero($('#vlrepass2', '#'+frmAtribDet).val());
	var vltarifa  = normalizaNumero($('#vltarifa2', '#'+frmAtribDet).val());
	var cdcopatu  = normalizaNumero($('#cdcopaux', '#'+frmAtribDet).val());
	var vlperc    = normalizaNumero($('#vlperc', '#'+frmAtribDet).val());
	var vlminimo  = normalizaNumero($('#vlminimo', '#'+frmAtribDet).val());
	var vlmaximo  = normalizaNumero($('#vlmaximo', '#'+frmAtribDet).val());
	var flgtiptar = $('input[type=radio][name=flgtiptar]:checked', '#'+frmAtribDet).val();
	
	var nrcnvatu  = normalizaNumero($('#nrconven', '#'+frmAtribDet).val());
	var cdocorre  = normalizaNumero($('#cdocorre','#frmCab').val());
	
	var cdlcratu  = normalizaNumero($('#cdlcremp', '#'+frmAtribDet).val());
	var cdtipcat  = normalizaNumero($('#cdtipcat','#frmCab').val());
	
	var cdinctar = normalizaNumero($('#cdinctar','#frmCab').val());
	
	if ( opReplica == 'R' ){
		cdcopatu = 999;
	}
	
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadtar/replica_detalhamento_coop.php', 
		data: {
			cddopcao  : cddopcao,
			cdfaixav  : cdfaixav,	
			dtdivulg  : dtdivulg,
			dtvigenc  : dtvigenc,
			vlrepass  : vlrepass,
			vltarifa  : vltarifa, 
			cdcopatu  : cdcopatu,
			cdtipcat  : cdtipcat,
			nrcnvatu  : nrcnvatu,
			cdocorre  : cdocorre,
			cdlcratu  : cdlcratu,
			cdinctar  : cdinctar,
			vlperc    : vlperc,
			vlminimo  : vlminimo,
			vlmaximo  : vlmaximo,
			flgtiptar : flgtiptar,
			redirect  : 'script_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {
		
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#tabAtribuicaoDetalhamento').html(response);
					aplicaClasse();
					hideMsgAguardo();
					bloqueiaFundo($('#divUsoGenerico'));
					bloqueiaFundo($('#divRotina'));
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			} else {
				try {
					eval( response );
					controlaFoco();
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		}				
	});
	return false;
}

// Formata form frmAtribuicaoDetalhamento no fonte form_atribuicao_detalhamento.php
function formataAtribuicaoDetalhamento() {

	var frmAtribuicaoDetalhamento = "frmAtribuicaoDetalhamento";
	
	$('#divUsoGenerico').css('width','780px');

 	// Rotulos 
	var rCdfvlcop	= $('label[for="cdfvlcop"]','#'+frmAtribuicaoDetalhamento);
	var rCdtarifa	= $('label[for="cdtarifa"]','#'+frmAtribuicaoDetalhamento);
	var rVlinifvl	= $('label[for="vlinifvl"]','#'+frmAtribuicaoDetalhamento);
	var rVlfinfvl	= $('label[for="vlfinfvl"]','#'+frmAtribuicaoDetalhamento);
	var rCdcooper	= $('label[for="cdcopaux"]','#'+frmAtribuicaoDetalhamento);
	var rDtdivulg	= $('label[for="dtdivulg"]','#'+frmAtribuicaoDetalhamento);
	var rDtvigenc	= $('label[for="dtvigenc"]','#'+frmAtribuicaoDetalhamento);
	var rVltarifa	= $('label[for="vltarifa2"]','#'+frmAtribuicaoDetalhamento);
	var rVlrepass	= $('label[for="vlrepass2"]','#'+frmAtribuicaoDetalhamento);
	var rFlgTiptar  = $('label[for="flgtiptar"]','#'+frmAtribuicaoDetalhamento);
	var rVlperc     = $('label[for="vlperc"]','#'+frmAtribuicaoDetalhamento);
	var rVlminimo   = $('label[for="vlminimo"]','#'+frmAtribuicaoDetalhamento);
	var rVlmaximo   = $('label[for="vlmaximo"]','#'+frmAtribuicaoDetalhamento);
	
	var rNrconven	= $('label[for="nrconven"]','#'+frmAtribuicaoDetalhamento);
	var rCdlcremp	= $('label[for="cdlcremp"]','#'+frmAtribuicaoDetalhamento);
	
	rCdfvlcop.addClass('rotulo').css('width','140px');
	rCdtarifa.addClass('rotulo').css('width','140px');
	rVlinifvl.addClass('rotulo').css('width','140px');
	rVlfinfvl.addClass('rotulo-linha').css('width','20px').css('text-align','center');
	rCdcooper.addClass('rotulo').css('width','140px');
	rDtdivulg.addClass('rotulo').css('width','140px');
	rDtvigenc.addClass('rotulo-linha').css('width','125px');
	rVltarifa.addClass('rotulo').css('width','140px');
	rVlrepass.addClass('rotulo-linha').css('width','100px');
	rFlgTiptar.addClass('rotulo').css('width','140px');
	rVlperc.addClass('rotulo').css('width','140px');
	rVlminimo.addClass('rotulo-linha').css('width','40px');
	rVlmaximo.addClass('rotulo-linha').css('width','40px');
	
	rNrconven.addClass('rotulo').css('width','140px');
	rCdlcremp.addClass('rotulo').css('width','140px');
	
	// Campos
	var cTodosAtr 	= $('input[type="text"],select','#'+frmAtribuicaoDetalhamento);
	var cCdfvlcop	= $('#cdfvlcop','#'+frmAtribuicaoDetalhamento);	
	var cCdtarifa	= $('#cdtarifa','#'+frmAtribuicaoDetalhamento);	
	var cDstarifa	= $('#dstarifa','#'+frmAtribuicaoDetalhamento);	
	var cVlinifvl2	= $('#vlinifvl2','#'+frmAtribuicaoDetalhamento);	
	var cVlfinfvl2	= $('#vlfinfvl2','#'+frmAtribuicaoDetalhamento);	
	var cCdcooper	= $('#cdcopaux','#'+frmAtribuicaoDetalhamento);	
	var cNmrescop	= $('#nmrescop','#'+frmAtribuicaoDetalhamento);	
	var cDtdivulg	= $('#dtdivulg','#'+frmAtribuicaoDetalhamento);	
	var cDtvigenc	= $('#dtvigenc','#'+frmAtribuicaoDetalhamento);	
	var cVltarifa	= $('#vltarifa2','#'+frmAtribuicaoDetalhamento);
	var cVlrepass	= $('#vlrepass2','#'+frmAtribuicaoDetalhamento);	
	var cVlperc     = $('#vlperc','#'+frmAtribuicaoDetalhamento);
	var cVlminimo   = $('#vlminimo','#'+frmAtribuicaoDetalhamento);
	var cVlmaximo   = $('#vlmaximo','#'+frmAtribuicaoDetalhamento);	

	var cNrconven	= $('#nrconven','#'+frmAtribuicaoDetalhamento);
	var cDsconven	= $('#dsconven','#'+frmAtribuicaoDetalhamento);
	
	var cCdlcremp	= $('#cdlcremp','#'+frmAtribuicaoDetalhamento);
	var cDslcremp	= $('#dslcremp','#'+frmAtribuicaoDetalhamento);

	cTodosAtr.habilitaCampo();
	cCdfvlcop.css('width','100px').desabilitaCampo();
	cCdtarifa.css('width','100px').desabilitaCampo();
	cDstarifa.css('width','450px').desabilitaCampo();
	cVlinifvl2.addClass('monetario').css('width','100px').desabilitaCampo();
	cVlfinfvl2.addClass('monetario').css('width','100px').desabilitaCampo();
	cCdcooper.css('width','100px').attr('maxlength','3').setMask('INTEGER','zzz','','');
	cNmrescop.css('width','430px').desabilitaCampo();
	cDtdivulg.addClass('data').css('width','100px');
	cDtvigenc.addClass('data').css('width','100px');
	cVltarifa.addClass('moeda').css('width','100px');
	cVlrepass.addClass('moeda').css('width','100px');
	cVlperc.css('width','40px');
	cVlminimo.addClass('moeda').css('width','100px');
	cVlmaximo.addClass('moeda').css('width','100px');
	
	cNrconven.css('width','100px').attr('maxlength','8').setMask('INTEGER','zzzzzzzz','','');
	cDsconven.css('width','430px').desabilitaCampo();
	
	cCdlcremp.css('width','100px').attr('maxlength','8').setMask('INTEGER','zzzzzzzz','','');
	cDslcremp.css('width','430px').desabilitaCampo();
	
	// Quando nao tem ocorrencia e motivo cadastrado nao eh cobranca 
	// e deve ficar desabilitado o campo
	cNrconven.desabilitaCampo();
		
	if ( ( normalizaNumero($('#cdocorre','#frmCab').val()) != 0 ) || ( $('#cdmotivo','#frmCab').val() != "" ) )  { 
		cNrconven.habilitaCampo();
	}
	
	if ( cdatrdet == 'R') {
		$('#tabAtribuicaoDetalhamento').css({'display':'block'});
		$("#btReplicar","#divBotoesfrmAtrDetalha").hide();
		$('#divBotoesfrmAtrDetalha2').css({'display':'block'});
		$('#divBotoesfrmAtrDetalha').css({'display':'none'});

		replicaCooperativaDet('R');
	}
		
	layoutPadrao();
	return false;
}

// Formata tabAtribuicaoDetalhamento no fonte form_atribuicao_detalhamento.php
function formataTabAtribuicaoDetalhamento() {

	var divRegistro = $('#tabAtribuicaoDetalhamento');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'100%','width':'100%'});
	
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];	
	
	var arrayLargura = new Array();
	arrayLargura[0] = '22px';
	arrayLargura[1] = '120px';
	arrayLargura[2] = '120px';
	arrayLargura[3] = '120px';
	
		
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'right';
	
	var metodoTabela = '';
			
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );
	
	return false;
}

function btnReblicar() {

	$('input,select', '#frmAtribuicaoDetalhamento').removeClass('campoErro'); /* Remove foco de erro */


	if ( $('#cdcopaux','#frmAtribuicaoDetalhamento').val() == '' ) {
				showError("error","Cooperativa deve ser informado.","Alerta - Ayllos","focaCampoErro(\'cdcopaux\', \'frmAtribuicaoDetalhamento\');bloqueiaFundo($('#divRotina'));",false);
				return false;
	}
	
	if ( !$('input[type=radio][name=flgtiptar]').is(":checked") ) {
				showError("error","Tipo de Tarifação deve ser informado.","Alerta - Ayllos","focaCampoErro(\'flgperc\', \'frmAtribuicaoDetalhamento\');bloqueiaFundo($('#divRotina'));",false);
				return false;
	}
	
	if ( $('#dtdivulg','#frmAtribuicaoDetalhamento').val() == '' ) {
				showError("error","Data Divulgação deve ser informado.","Alerta - Ayllos","focaCampoErro(\'dtdivulg\', \'frmAtribuicaoDetalhamento\');bloqueiaFundo($('#divRotina'));",false);
				return false;
	}
	
	if ( $('#dtvigenc','#frmAtribuicaoDetalhamento').val() == '' ) {
				showError("error","Data Vigencia deve ser informado.","Alerta - Ayllos","focaCampoErro(\'dtvigenc\', \'frmAtribuicaoDetalhamento\');bloqueiaFundo($('#divRotina'));",false);
				return false;
	}
	
	var data1 = $('#dtdivulg','#frmAtribuicaoDetalhamento').val();
	var data2 = $('#dtvigenc','#frmAtribuicaoDetalhamento').val();
	var data3 = $('#glbdtmvtolt','#frmCab').val();

	// Divulgação
	var nova_data1 = parseInt(data1.split("/")[2].toString() + data1.split("/")[1].toString() + data1.split("/")[0].toString()); 
	
	// Vigencia
	var nova_data2 = parseInt(data2.split("/")[2].toString() + data2.split("/")[1].toString() + data2.split("/")[0].toString()); 
	
	// Data Sistema
	var nova_data3 = parseInt(data3.split("/")[2].toString() + data3.split("/")[1].toString() + data3.split("/")[0].toString()); 
	
	
	if ( nova_data1 > nova_data2 ) {
				showError("error","Data Divulgação deve ser menor que Data Vigencia.","Alerta - Ayllos","focaCampoErro(\'dtdivulg\', \'frmAtribuicaoDetalhamento\');bloqueiaFundo($('#divRotina'));",false);
				return false;
	}
	
	if ( nova_data2 <= nova_data3 ) {
				showError("error","Data Vigencia deve ser maior que Data do Sistema.","Alerta - Ayllos","focaCampoErro(\'dtvigenc\', \'frmAtribuicaoDetalhamento\');bloqueiaFundo($('#divRotina'));",false);
				return false;
	}
		
	if ( $('#vltarifa2','#frmAtribuicaoDetalhamento').val() == '' ) {
				showError("error","Valor Tarifa deve ser informado.","Alerta - Ayllos","focaCampoErro(\'vltarifa2\', \'frmAtribuicaoDetalhamento\');bloqueiaFundo($('#divRotina'));",false);
				return false;
	}
	
	if ( $('#vlrepass2','#frmAtribuicaoDetalhamento').val() == '' ) {
				showError("error","Custo/Repasse deve ser informado.","Alerta - Ayllos","focaCampoErro(\'vlrepass2\', \'frmAtribuicaoDetalhamento\');bloqueiaFundo($('#divRotina'));",false);
				return false;
	}
	
	// Se não esta bloqueado é inclusão.
	if ( ! $('#dtdivulg','#frmAtribuicaoDetalhamento').hasClass('campoTelaSemBorda')  ) {	
		controlaOpFco('IR');
		bloqueiCabAtribDet();
		
		$('#tabAtribuicaoDetalhamento').css({'display':'block'});
		$("#btReplicar","#divBotoesfrmAtrDetalha").hide();
		$('#divBotoesfrmAtrDetalha2').css({'display':'block'});
		$('#divBotoesfrmAtrDetalha').css({'display':'none'});

		replicaCooperativaDet('IR');
		
	} else {
	
		$('#tabAtribuicaoDetalhamento').css({'display':'block'});
		$("#btReplicar","#divBotoesfrmAtrDetalha").hide();
		$('#divBotoesfrmAtrDetalha2').css({'display':'block'});
		$('#divBotoesfrmAtrDetalha').css({'display':'none'});

		replicaCooperativaDet('R');
	}
	
}

function btnVoltarAtribDet() {

	fechaRotina($('#divUsoGenerico'));
	exibeRotina($('#divRotina'));
	return false;

}

// Função usada no fonte form_detalha_tarifa.php
function liberaDetalhamento() {

	formataTabDetalhamento();

	$('#divBotoesDetalhaTarifa').css({'display':'block'});
	$('#dvTabDetalhamento').css({'display':'block'});
	$("#btSalvar","#divBotoesfrmDetalhaTarifa").show();
	$("#btContinuar","#divBotoesfrmDetalhaTarifa").hide();
	
	carregaAtribuicaoDetalhamento();
	
}

function buscaDadosParametro() {

	showMsgAguardo('Aguarde, buscando parâmetro...');
	
	$('input,select', '#frmVinculacaoParametro').removeClass('campoErro');
	$('#dstarifa','#frmVinculacaoParametro').focus();

	var cdpartar = $('#cdpartar','#frmVinculacaoParametro').val();
		cdpartar = normalizaNumero(cdpartar);
	
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadtar/busca_dados_parametro.php", 
		data: {
			cddopcao: cddopcao,
			cdpartar: cdpartar,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					hideMsgAguardo();
					eval(response);
					buscaParametroCoop();
				} catch(error) {
					hideMsgAguardo();
					showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
				}
			} else {
				try {
					eval( response );
					controlaFoco();
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		}				
	});	

}

function btVincular() {

	if ( $('#cdpartar','#frmVinculacaoParametro').hasClass('campoTelaSemBorda')  ) {	
		realizaOperacaoVinculo("V");
		return false;
	} else {
		if ( $('#cdpartar','#frmVinculacaoParametro').val() == '' ) {
				showError("error","C&oacute;digo do Par&acirc;metro deve ser informado.","Alerta - Ayllos","focaCampoErro(\'cdpartar\', \'frmVinculacaoParametro\'); bloqueiaFundo($('#divRotina'));",false);
				return false;
		} else {
			buscaDadosParametro();
		}
	
	}

}

function realizaOperacaoVinculo(cdopcao) {

	// Mostra mensagem de aguardo
	if (cdopcao == "V"){  	  showMsgAguardo("Aguarde, vinculando Parâmetro..."); } 
	else if (cdopcao == "D"){ showMsgAguardo("Aguarde, desvinculando Parâmetro...");  }
	else { showMsgAguardo("Aguarde, liberando aplicacao..."); }
	
	var cdpartar = $('#cdpartar','#frmVinculacaoParametro').val();
	var cdtarifa = $('#cdtarifa','#frmVinculacaoParametro').val();
		cdpartar = normalizaNumero(cdpartar);
		cdtarifa = normalizaNumero(cdtarifa);
		
		
	if (cdopcao == "D") {
		cdpartar = glbTabCdpartar;
		cdtarifa = $('#cdtarifa','#frmCab').val();
		cdpartar = normalizaNumero(cdpartar);
		cdtarifa = normalizaNumero(cdtarifa);
	}
	
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadtar/manter_rotina_vinculo.php", 
		data: {
			cdpartar: cdpartar,
			cdtarifa: cdtarifa,
			cdopcao: cdopcao,
			cddopcao: cddopcao,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					eval(response);
					carregaParametro();
					hideMsgAguardo();	
				} catch(error) {
					hideMsgAguardo();
					showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
				}
			} else {
				try {
					eval( response );
					controlaFoco();
					bloqueiaFundo($('#divRotina'));
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		}		
	});	

}

function controlaPesquisaParametro() {

	// Se esta desabilitado o campo 
	if ($("#cdpartar","#frmVinculacaoParametro").prop("disabled") == true)  {
		return;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdpartar, titulo_coluna, cdpartars, nmpartar;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmVinculacaoParametro';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdpartar = $('#cdpartar','#'+nomeFormulario).val();
	cdpartars = cdpartar;	
	nmpartar = '';
	
	titulo_coluna = "Parametros";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-parametros';
	titulo      = 'Parametros';
	qtReg		= '20';
	filtros 	= 'Codigo;cdpartar;130px;S;' + cdpartar + ';S|Descricao;nmpartar;300px;S;' + nmpartar + ';S';
	colunas 	= 'Codigo;cdpartar;15%;right|' + titulo_coluna + ';nmpartar;75%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,$('#divRotina'),'$(\'#cdpartar\',\'#frmVinculacaoParametro\').val()');
	
	return false;
}


function fechaDivRotina() {
	fechaRotina($('#divRotina'));
	return false;
}


function carregaParametro(){
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, buscando parâmetros...");
	
	var cdtarifa = $('#cdtarifa','#frmCab').val();
	cdtarifa = normalizaNumero(cdtarifa);
	var cddopcao = $('#cddopcao','#frmCab').val();
	
	// Carrega dados parametro através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/cadtar/carrega_parametro.php', 
		data    : 
				{ 
					cddopcao	: cddopcao,
					cdtarifa	: cdtarifa,
					redirect	: 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) { 
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {						
							$('#divParametro').html(response);	
							$('#divParametro').css({'display':'block'});
							formataParametro();
							layoutPadrao();
							 if ( cddopcao == 'A' ) {
								buscaFlagIncidencia( $('#cdinctar','#frmCab').val() );
							 }
							hideMsgAguardo();
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


function formataParametro() {

	$('#divRotina').css('width','640px');

	var divRegistro = $('div.divRegistros','#divParametro');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'80px','width':'100%'});
	
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];	
	
	var arrayLargura = new Array();
	arrayLargura[0] = '100%';
	
		
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	
	var metodoTabela = '';
			
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );
	
	glbTabCdpartar = 0;
	
	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		glbTabCdpartar = $(this).find('#cdpartar > span').text() ;
	});
	
	$('table > tbody > tr:eq(0)', divRegistro).click();
	
	return false;
}

function bntDesvincula() {

	if ( glbTabCdpartar == 0 ) {
		showError('error','Não há registro selecionado','Alerta - Ayllos',"unblockBackground()");
		return false
	} else {
		showConfirmacao('Deseja realmente desvincular o parâmetro selecionado?','Confirma&ccedil;&atilde;o - Ayllos','realizaOperacaoVinculo(\'D\');','return false;','sim.gif','nao.gif');	
	} 
}


function controlafrmAtribuicaoDetalhamento() {

	$('#cdcopaux','#frmAtribuicaoDetalhamento').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			buscaCooperativa();
			return false;
		}	
	});		
	
	$('#dtdivulg','#frmAtribuicaoDetalhamento').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#dtvigenc','#frmAtribuicaoDetalhamento').focus();
			return false;
		}	
	});
	
	$('#dtvigenc','#frmAtribuicaoDetalhamento').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#vltarifa2','#frmAtribuicaoDetalhamento').focus();
			return false;
		}	
	});			
	
	$('#vltarifa2','#frmAtribuicaoDetalhamento').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#vlrepass2','#frmAtribuicaoDetalhamento').focus();
			return false;
		}	
	});
	
	$('#vlrepass2','#frmAtribuicaoDetalhamento').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
		//	if ( ( $('#cdocorre','#frmCab').val() != 0 ) || ( $('#cdmotivo','#frmCab').val() != "" ) )  { /* Daniel */
			if ( normalizaNumero($('#cdtipcat','#frmCab').val()) == 2 ) { /* 2 - Convenio */
				$('#nrconven','#frmAtribuicaoDetalhamento').focus();
				return false;
			}
			if ( normalizaNumero($('#cdtipcat','#frmCab').val()) == 3 ) { /* 3 - Credito */
				$('#cdlcremp','#frmAtribuicaoDetalhamento').focus();
				return false;
			}
		}	
	});
	
	$('#cdcopaux','#frmAtribuicaoDetalhamento').unbind('change').bind('change', function(e) {
		buscaCooperativa();
		return false;	
	});
	
	$('#nrconven','#frmAtribuicaoDetalhamento').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			if ( $(this).val() != '' ){
				buscaConvenio();
				return false;
			}
		}	
	});
	
	$('#cdlcremp','#frmAtribuicaoDetalhamento').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			if ( $(this).val() != '' ){
				if ( $(this).val() != 0 ){
					buscaLinhaCredito();
					return false;
				} else {
					$('#dslcremp','#frmAtribuicaoDetalhamento').val("LINHA PADRAO");
					return false;
				}
			}
		}	
	});
	
	$('#cdlcremp','#frmAtribuicaoDetalhamento').unbind('change').bind('change', function(e) {
		if ( $(this).val() != '' ){
			if ( $(this).val() != 0 ){
				buscaLinhaCredito();
				return false;
			} else {
				$('#dslcremp','#frmAtribuicaoDetalhamento').val("LINHA PADRAO");
				return false;
			}
		}	
	});
		
}


function excluirDetalhamento() {

	if ( glbTabCdfaixav == '' ){
		showError('error','Não há registro selecionado','Alerta - Ayllos',"unblockBackground()");
		return false
	} else {
		showConfirmacao('Deseja realmente excluir o registro do detalhamento?','Confirma&ccedil;&atilde;o - Ayllos','verificaLancLat(\'E\');','return false;','sim.gif','nao.gif');
	}

}


function buscaCooperativa(){

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, buscando cooperativa...");

	var cdcooper = $('#cdcopaux','#frmAtribuicaoDetalhamento').val();
	cdcooper = normalizaNumero(cdcooper);
	
	var cddopcao = $('#cddopcao','#frmCab').val();

	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadtar/busca_dados_cooperativa.php", 
		data: {
			cdcooper: cdcooper,
			cddopcao: cddopcao,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();
				bloqueiaFundo($('#divRotina'));
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});	
	
	return false;

}

function controlaPesquisaCoop(){

	// Se esta desabilitado o campo 
	if ($("#cdcopaux","#frmAtribuicaoDetalhamento").prop("disabled") == true)  {
		return;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdcooper, titulo_coluna, cdcoopers, cdcopaux, nmrescop;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmAtribuicaoDetalhamento';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdcopaux = $('#cdcopaux','#'+nomeFormulario).val();    
	cdcoopers = cdcopaux;	
	nmrescop = '';
	
	titulo_coluna = "Cooperativas";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-cooperativas';
	titulo      = 'Cooperativas';
	qtReg		= '20';
	filtros 	= 'Codigo;cdcopaux;130px;S;' + cdcopaux + ';S|Descricao;nmrescop;300px;S;' + nmrescop + ';S';
	colunas 	= 'Codigo;cdcooper;15%;right|' + titulo_coluna + ';nmrescop;75%;left';
	
	$('#divUsoGenerico').css('visibility','hidden'); 
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,$('#divUsoGenerico'),'$(\'#cdcopaux\',\'#frmAtribuicaoDetalhamento\').val(); $(\'#divUsoGenerico\').css(\'visibility\',\'visible\');');
	return true;
}


function estadoInicialAtribDet() {

	fechaRotina($('#divUsoGenerico'));
	exibeRotina($('#divRotina'));
	
	carregaAtribuicaoDetalhamento();
	
	return false;

}

function recargaFco() {

    carregaAtribuicaoDetalhamento();

	return false;

}

function aplicaClasse() {

	$('.dataDet','#formAtribuicaoDetalhamento').setMask("DATE","DD","MM","YYYY");
	$('.moedaDet','#formAtribuicaoDetalhamento').attr('alt','n9p3c2D').css('text-align','right').autoNumeric().trigger('blur');
	
	/* Tratamento para quando for cobranca mostrar campo convenio */
//	if ( ( normalizaNumero($('#cdocorre','#frmCab').val()) != 0 ) || ( $('#cdmotivo','#frmCab').val() != "" ) )  { /* Daniel */
	if ( normalizaNumero($('#cdtipcat','#frmCab').val()) == 2 ) { /* 2 - Convenio */
		$('.oculta','#formAtribuicaoDetalhamento').css('display','block');
	} else {
		$('.oculta','#formAtribuicaoDetalhamento').css('display','none');
	}
	
//	if ( ( normalizaNumero($('#cdcatego','#frmCab').val()) == 6 ) )  { 	/* Daniel */
	if ( normalizaNumero($('#cdtipcat','#frmCab').val()) == 3 ) { /* 3 - Linha Credito */
		$('.linhaCredito','#formAtribuicaoDetalhamento').css('display','block');
	} else {
		$('.linhaCredito','#formAtribuicaoDetalhamento').css('display','none');
	}
	
	controlaCheck();

}

function getListaReplica(campo){

	var numocorr = $('#numocorr','#formAtribuicaoDetalhamento').val();
	
	var lista    = '';
				
	for (var i=1;i<=numocorr;i++){ 
		
		if( $('#flgcheck'+i,'#formAtribuicaoDetalhamento').prop('checked') == true ){
		
			lista = lista + $('#'+campo+i,'#formAtribuicaoDetalhamento').val() + ';';		
			
		}	
	}			

	$.trim(lista);
	lista = lista.substr(0,lista.length - 1);
	
	return lista;
}


// Função para bloquear Atribuição de Detalhamento e trocar função botão Concluir
function bloqueiCabAtribDet() {
	
	$('#divBotoesfrmAtrDetalha2').html('');
	$('#divBotoesfrmAtrDetalha2').append('<br style="clear:both" />');
	$('#divBotoesfrmAtrDetalha2').append('<a href="#" class="botao" id="btVoltar"  onClick="btnVoltarAtribDet(); return false;">Voltar</a>');
	$('#divBotoesfrmAtrDetalha2').append('<a href="#" class="botao" id="btSalvar"  onClick="controlaOpFco(\'R\'); return false;">Concluir</a>');
	
	$('#cdcopaux','#frmAtribuicaoDetalhamento').desabilitaCampo();
	$('#dtdivulg','#frmAtribuicaoDetalhamento').desabilitaCampo();
	$('#dtvigenc','#frmAtribuicaoDetalhamento').desabilitaCampo();
	$('#vltarifa2','#frmAtribuicaoDetalhamento').desabilitaCampo();
	$('#vlrepass2','#frmAtribuicaoDetalhamento').desabilitaCampo();
	$('#flgfixo','#frmAtribuicaoDetalhamento').desabilitaCampo();
	$('#flgperc','#frmAtribuicaoDetalhamento').desabilitaCampo();
	$('#vlperc','#frmAtribuicaoDetalhamento').desabilitaCampo();
	$('#vlminimo','#frmAtribuicaoDetalhamento').desabilitaCampo();
	$('#vlmaximo','#frmAtribuicaoDetalhamento').desabilitaCampo();
	
	$('#nrconven','#frmAtribuicaoDetalhamento').desabilitaCampo();
	
	return false;
}

function controlaCheck() {

	function marcaPrimeiro(){
		var flag = true;
		
		$('input[type="checkbox"],select','#formAtribuicaoDetalhamento').each(
			function(index){
				if( $(this).prop('id') != 'flgcheckall' ){
					if($(this).prop("checked") == false){
						flag = false;
					}	
				}
			}
		);
		
		return flag;
	}

	$('input[type="checkbox"],select','#formAtribuicaoDetalhamento').each(
		function(index){
			if( $(this).prop('id') != 'flgcheckall' ){
				$(this).unbind('click').bind('click', function(e){ 
					if($(this).prop("checked") == false){
						$('#flgcheckall','#formAtribuicaoDetalhamento').prop("checked",false);
					}else{
						$('#flgcheckall','#formAtribuicaoDetalhamento').prop("checked",marcaPrimeiro());
					}
				})
			}
		}
	)

	$('#flgcheckall','#formAtribuicaoDetalhamento').unbind('click').bind('click', function(e) {
		
		if( $(this).prop("checked") == true ){
			$(this).val("yes");	
			$('input[type="checkbox"],select','#formAtribuicaoDetalhamento').prop("checked",true);			
		}else{
			$(this).val("no");	
			$('input[type="checkbox"],select','#formAtribuicaoDetalhamento').prop("checked",false);
		}		
			
	});
	
}

function excluirDetAtribuicao() {

	if ( glbFcoCdcooper == '' ) {
		showError('error','Não há registro selecionado.','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false
	}
	
	var data2 = glbFcoDtvigenc;
	var data3 = $('#glbdtmvtolt','#frmCab').val();

	// Vigencia
	var nova_data2 = parseInt(data2.split("/")[2].toString() + data2.split("/")[1].toString() + data2.split("/")[0].toString()); 
	
	// Data Sistema
	var nova_data3 = parseInt(data3.split("/")[2].toString() + data3.split("/")[1].toString() + data3.split("/")[0].toString()); 
	
	if ( nova_data2 <= nova_data3)	{
		showError('error','Apenas permitido exclusão de registros com Data de Vigência futura.','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}
	
	showConfirmacao('Deseja realmente excluir o Registro do Detalhamento?','Confirma&ccedil;&atilde;o - Ayllos','controlaOpFco(\'E\')',"blockBackground(parseInt($('#divRotina').css('z-index')))",'sim.gif','nao.gif');


}


function controlaPesquisaConvenio(){

	// Se esta desabilitado o campo 
	if ($("#nrconven","#frmAtribuicaoDetalhamento").prop("disabled") == true)  {
		return false; 
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdcooper, titulo_coluna, cdcoopers, nrconven, nmrescop;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmAtribuicaoDetalhamento';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var nrconven = $('#nrconven','#'+nomeFormulario).val(); 
	var cdcopatu = $('#cdcopaux','#'+nomeFormulario).val();    	
	var cdocorre  = normalizaNumero($('#cdocorre','#frmCab').val());
	var cdinctar  = normalizaNumero($('#cdinctar','#frmCab').val());
	dsconven = '';
	
	titulo_coluna = "Convenios";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-convenios';
	titulo      = 'Convenios';
	qtReg		= '20';
	filtros 	= 'Codigo;nrconven;130px;S;' + nrconven + ';S|Descricao;dsconven;300px;S;' + dsconven + ';S|Codigo;cdcopatu;130px;N;' + cdcopatu + ';N';
	filtros     = filtros + '|Ocorrencia;cdocorre;130px;N;' + cdocorre + ';N' + '|Tipo incidencia;cdinctar;130px;N;' + cdinctar + ';N';
	colunas 	= 'Codigo;nrconven;15%;right|Descricao;dsconven;75%;left';
	
	$('#divUsoGenerico').css('visibility','hidden'); 
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,$('#divUsoGenerico'),'$(\'#nrconven\',\'#frmAtribuicaoDetalhamento\').val(); $(\'#divUsoGenerico\').css(\'visibility\',\'visible\');');
	return true;
}

function buscaConvenio(){

	showMsgAguardo("Aguarde, consultando Convenios...");
	
	var nrconven = $('#nrconven','#frmAtribuicaoDetalhamento').val(); 
	var cdcopatu = $('#cdcopaux','#frmAtribuicaoDetalhamento').val();    
	var cdocorre  = normalizaNumero($('#cdocorre','#frmCab').val());
	var cdinctar = $('#cdinctar','#frmCab').val();
	
	cdinctar = normalizaNumero(cdinctar);

	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadtar/busca_convenio.php", 
		data: {
			nrconven: nrconven,
			cdcopatu: cdcopatu,
			cdocorre: cdocorre,
			cdinctar: cdinctar,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();	
				bloqueiaFundo($('#divRotina'));	
				eval(response);				
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});	

	return false;
}


function controlaPesquisaLinhaCredito(){

	// Se esta desabilitado o campo 
	if ($("#cdlcremp","#frmAtribuicaoDetalhamento").prop("disabled") == true)  {
		return false; 
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdcooper, titulo_coluna, cdcoopers, cdlcremp;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmAtribuicaoDetalhamento';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdlcremp = $('#cdlcremp','#'+nomeFormulario).val(); 
	var cdcopatu = $('#cdcopaux','#'+nomeFormulario).val();    	
	var dslcremp = '';
	
	titulo_coluna = "Linhas de Credito";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-linhas-credito';
	titulo      = 'Linhas de Credito';
	qtReg		= '20';
	filtros 	= 'Codigo;cdlcremp;130px;S;' + cdlcremp + ';S|Descricao;dslcremp;300px;S;' + dslcremp + ';S|Codigo;cdcopatu;130px;N;' + cdcopatu + ';N';
	colunas 	= 'Codigo;cdlcremp;15%;right|Descricao;dslcremp;75%;left';
	
	$('#divUsoGenerico').css('visibility','hidden'); 
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,$('#divUsoGenerico'),'$(\'#cdlcremp\',\'#frmAtribuicaoDetalhamento\').val(); $(\'#divUsoGenerico\').css(\'visibility\',\'visible\');');
	return true;
}


function buscaLinhaCredito(){

	showMsgAguardo("Aguarde, consultando Linha de Credito...");
	
	var cdlcremp = $('#cdlcremp','#frmAtribuicaoDetalhamento').val(); 
	var cdcopatu = $('#cdcopaux','#frmAtribuicaoDetalhamento').val();    

	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadtar/busca_linha_credito.php", 
		data: {
			cdlcremp: cdlcremp,
			cdcopatu: cdcopatu,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();	
				bloqueiaFundo($('#divRotina'));	
				eval(response);				
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});	

	return false;
}

function controlarTipoTarifa(){

	if ($('input[type=radio][name=flgtiptar]:checked').val() == '2') {

        $('#vlrepass2','#frmAtribuicaoDetalhamento').css('display','block');
		$('#vlperc','#frmAtribuicaoDetalhamento').css('display','block');
		$('#vlminimo','#frmAtribuicaoDetalhamento').css('display','block');
		$('#vlmaximo','#frmAtribuicaoDetalhamento').css('display','block');
		$('label[for="vlrepass2"]','#frmAtribuicaoDetalhamento').css('display','block');
		$('label[for="vlperc"]','#frmAtribuicaoDetalhamento').css('display','block');
		$('label[for="vlminimo"]','#frmAtribuicaoDetalhamento').css('display','block');
		$('label[for="vlmaximo"]','#frmAtribuicaoDetalhamento').css('display','block');

		$('#vltarifa2','#frmAtribuicaoDetalhamento').css('display','none');
		$('label[for="vltarifa2"]','#frmAtribuicaoDetalhamento').css('display','none');

		$('#vltarifa2','#frmAtribuicaoDetalhamento').val(0).blur();
		$('#vlrepass2','#frmAtribuicaoDetalhamento').val(0).blur();
		$('#vlperc','#frmAtribuicaoDetalhamento').val(0).blur();
		$('#vlminimo','#frmAtribuicaoDetalhamento').val(0).blur();
		$('#vlmaximo','#frmAtribuicaoDetalhamento').val(0).blur();

    }else if ($('input[type=radio][name=flgtiptar]:checked').val() == '1') {

		$('#vltarifa2','#frmAtribuicaoDetalhamento').css('display','block');
		$('#vlrepass2','#frmAtribuicaoDetalhamento').css('display','block');
		$('label[for="vltarifa2"]','#frmAtribuicaoDetalhamento').css('display','block');
		$('label[for="vlrepass2"]','#frmAtribuicaoDetalhamento').css('display','block');

		$('#vlperc','#frmAtribuicaoDetalhamento').css('display','none');
		$('#vlminimo','#frmAtribuicaoDetalhamento').css('display','none');
		$('#vlmaximo','#frmAtribuicaoDetalhamento').css('display','none');
		$('label[for="vlperc"]','#frmAtribuicaoDetalhamento').css('display','none');
		$('label[for="vlminimo"]','#frmAtribuicaoDetalhamento').css('display','none');
		$('label[for="vlmaximo"]','#frmAtribuicaoDetalhamento').css('display','none');

		$('#vltarifa2','#frmAtribuicaoDetalhamento').val(0).blur();
		$('#vlrepass2','#frmAtribuicaoDetalhamento').val(0).blur();
		$('#vlperc','#frmAtribuicaoDetalhamento').val(0).blur();
		$('#vlminimo','#frmAtribuicaoDetalhamento').val(0).blur();
		$('#vlmaximo','#frmAtribuicaoDetalhamento').val(0).blur();

    }

}

function btnConfirmarConcluirComLinhaCredito(){

	if ( normalizaNumero($('#cdtipcat','#frmCab').val()) == 3 ) { /* 3 - Linha de Credito */

		showConfirmacao('Você selecionou uma linha de crédito isenta, deseja preencher automaticamente todas as cooperativas com tarifas zeradas?','Confirma&ccedil;&atilde;o - Ayllos','btnConcluirComLinhaCredito();','return false;','sim.gif','nao.gif');
	}

}

function btnConcluirComLinhaCredito() {

	//Quando for Linha de Credito tera acao igual ao replica automaticamente pelo botao continuar

	$('input,select', '#frmAtribuicaoDetalhamento').removeClass('campoErro'); /* Remove foco de erro */


	if ( $('#cdcopaux','#frmAtribuicaoDetalhamento').val() == '' ) {
				showError("error","Cooperativa deve ser informado.","Alerta - Ayllos","focaCampoErro(\'cdcopaux\', \'frmAtribuicaoDetalhamento\');bloqueiaFundo($('#divRotina'));",false);
				return false;
	}

	if ( !$('input[type=radio][name=flgtiptar]').is(":checked") ) {
				showError("error","Tipo de Tarifação deve ser informado.","Alerta - Ayllos","focaCampoErro(\'flgperc\', \'frmAtribuicaoDetalhamento\');bloqueiaFundo($('#divRotina'));",false);
				return false;
	}
	
	if ( $('#dtdivulg','#frmAtribuicaoDetalhamento').val() == '' ) {
				showError("error","Data Divulgação deve ser informado.","Alerta - Ayllos","focaCampoErro(\'dtdivulg\', \'frmAtribuicaoDetalhamento\');bloqueiaFundo($('#divRotina'));",false);
				return false;
	}
	
	if ( $('#dtvigenc','#frmAtribuicaoDetalhamento').val() == '' ) {
				showError("error","Data Vigencia deve ser informado.","Alerta - Ayllos","focaCampoErro(\'dtvigenc\', \'frmAtribuicaoDetalhamento\');bloqueiaFundo($('#divRotina'));",false);
				return false;
	}
	
	var data1 = $('#dtdivulg','#frmAtribuicaoDetalhamento').val();
	var data2 = $('#dtvigenc','#frmAtribuicaoDetalhamento').val();
	var data3 = $('#glbdtmvtolt','#frmCab').val();

	// Divulgação
	var nova_data1 = parseInt(data1.split("/")[2].toString() + data1.split("/")[1].toString() + data1.split("/")[0].toString()); 
	
	// Vigencia
	var nova_data2 = parseInt(data2.split("/")[2].toString() + data2.split("/")[1].toString() + data2.split("/")[0].toString()); 
	
	// Data Sistema
	var nova_data3 = parseInt(data3.split("/")[2].toString() + data3.split("/")[1].toString() + data3.split("/")[0].toString()); 
	
	
	if ( nova_data1 > nova_data2 ) {
				showError("error","Data Divulgação deve ser menor que Data Vigencia.","Alerta - Ayllos","focaCampoErro(\'dtdivulg\', \'frmAtribuicaoDetalhamento\');bloqueiaFundo($('#divRotina'));",false);
				return false;
	}
	
	if ( nova_data2 <= nova_data3 ) {
				showError("error","Data Vigencia deve ser maior que Data do Sistema.","Alerta - Ayllos","focaCampoErro(\'dtvigenc\', \'frmAtribuicaoDetalhamento\');bloqueiaFundo($('#divRotina'));",false);
				return false;
	}
		
	if ( $('#vltarifa2','#frmAtribuicaoDetalhamento').val() == '' ) {
				showError("error","Valor Tarifa deve ser informado.","Alerta - Ayllos","focaCampoErro(\'vltarifa2\', \'frmAtribuicaoDetalhamento\');bloqueiaFundo($('#divRotina'));",false);
				return false;
	}
	
	if ( $('#vlrepass2','#frmAtribuicaoDetalhamento').val() == '' ) {
				showError("error","Custo/Repasse deve ser informado.","Alerta - Ayllos","focaCampoErro(\'vlrepass2\', \'frmAtribuicaoDetalhamento\');bloqueiaFundo($('#divRotina'));",false);
	return false;
}
	
	// Se não esta bloqueado é inclusão.
	if ( ! $('#dtdivulg','#frmAtribuicaoDetalhamento').hasClass('campoTelaSemBorda')  ) {	
		controlaOpFco('IR');
		bloqueiCabAtribDet();

		replicaCooperativaDet('IR');
		
	} else {

		replicaCooperativaDet('R');
	}

	controlaOpFco('R');
	
}

function limparCamposTipoFixo(campo){

	var i = campo.replace('vlperctab','');

	$('#vltarifatab'+i,'#formAtribuicaoDetalhamento').val(0).blur();
	
}

function limparCamposTipoPerc(campo){

	var i = campo.replace('vltarifatab','');

	$('#vlperctab'+i,'#formAtribuicaoDetalhamento').val(0).blur();
	$('#vlminimotab'+i,'#formAtribuicaoDetalhamento').val(0).blur();
	$('#vlmaximotab'+i,'#formAtribuicaoDetalhamento').val(0).blur();
}

/*!
 * FONTE        : fairrf.js
 * CRIAÇÃO      : Dionathan Henchel
 * DATA CRIAÇÃO : 26/11/2015
 * OBJETIVO     : Biblioteca de funções da tela FAIRRF
 * --------------
 * ALTERAÇÕES   : 
 *
 * -------------- 
 */

// Definição de algumas variáveis globais 
var cddopcao		= 'C';
var cddopdet		= 'I';

//Formulários
var frmCab   		 = 'frmCab';

//Labels/Campos do cabeçalho
var rCddopcao,rInpessoa,cCddopcao,cInpessoa,cTodosCabecalho,glbTabCdfaixa,glbTabInPessoa,glbTabVlfaixa_inicial,glbTabVlfaixa_final,glbTabVlpercentual_irrf,glbTabVldeducao;

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
	
	$('#divOcorrenciaMotivo').css({'display':'none'});
	
	formataCabecalho();
	
	cTodosCabecalho.limpaFormulario();
	cCddopcao.val( cddopcao );
	
	removeOpacidade('divTela');	
	unblockBackground();
	hideMsgAguardo();
	
	cTodosCabecalho.desabilitaCampo();
	
	$('#cddopcao','#frmCab').habilitaCampo();
	$('#cddopcao','#'+frmCab).focus();
	
	trocaBotao('');
	
	$("#btVoltar","#divBotoes").hide();
	$('input,select', '#frmCab').removeClass('campoErro');
	
	controlaFoco();
}

function formataCabecalho() {
	
	// cabecalho
	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab);
	
	rInpessoa			= $('label[for="inpessoa"]','#'+frmCab);
	
	cCddopcao			= $('#cddopcao','#'+frmCab);
	cInpessoa			= $('#inpessoa','#'+frmCab);
	
	cTodosCabecalho		= $('input[type="text"],input[type="checkbox"],select','#'+frmCab);
	
	rCddopcao.css('width','115px');
	rInpessoa.css({'width':'115px'});
	
	cCddopcao.css({'width':'540px'});	
	cInpessoa.css({'width':'360px'});
	
	cTodosCabecalho.habilitaCampo().removeClass('campoErro');
	
	layoutPadrao();
	return false;	
}

// Botao Voltar
function btnVoltar() {
	estadoInicial();
	return false;
}

function btnContinuar() {
	cddopcao = cCddopcao.val();
}

function LiberaCampos() {

	if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda')  ) { return false; }	

	//Desabilita campos do formulário
	cTodosCabecalho		= $('input[type="text"],select','#frmCab'); 
	cTodosCabecalho.desabilitaCampo();
		
	$('#divBotoes', '#divTela').css({'display':'block'});
	
	trocaBotao( 'btnConcluir' );
	
	$("#btSalvar","#divBotoes").show();
	$("#btVoltar","#divBotoes").show();
	
	//Habilita campo inpessoa
	$('#inpessoa','#frmCab').habilitaCampo();
	$('#inpessoa','#frmCab').focus();

	return false;

}

function controlaFoco() {

	$('#cddopcao','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				LiberaCampos();
				return false;
			}
	});
	
	$('#btnOK','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {				
					LiberaCampos();
					return false;
			}	
	});
	
	$('#inpessoa','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			if ($('#inpessoa','#frmCab').val() != ''){
				btnConcluir();
			}
		}
	});
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

function btnConcluir() {

	glbTabInPessoa = cInpessoa.val();
	
	//Desabilita campos do formulário
	cTodosCabecalho		= $('input[type="text"],select','#frmCab'); 
	cTodosCabecalho.desabilitaCampo();
	
	if ( glbTabInPessoa != '' ) {
		buscarFairrf();
	}	
}

function buscarFairrf(){
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmCab';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');

	showMsgAguardo("Aguarde, consultando Faixas...");

	var inpessoa = $('#inpessoa','#frmCab').val();
	inpessoa = normalizaNumero(inpessoa);
	
	var cddopcao = $('#cddopcao','#frmCab').val();
	
	//Carrega grid de detalhamento
	try {
		unblockBackground();
		carregaDetalhamento();
	} catch(error) {
		hideMsgAguardo();
		showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
	}
	
}

function carregaDetalhamento(){
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, buscando detalhamento...");
	
	var cddopcao = $('#cddopcao','#frmCab').val();
	var inpessoa = $('#inpessoa','#frmCab').val();
	
	// Carrega dados parametro através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/fairrf/carrega_detalhamento.php', 
		data    : 
				{ 
					cddopcao	: cddopcao,
					inpessoa	: inpessoa,
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
							unblockBackground();
							formataDetalhamento();
							
							var cddopcao = $('#cddopcao','#frmCab').val();
	
							if ( cddopcao == 'C' ) {
											
								$('#btIncluir','#divBotoesDetalha').hide();
								$('#btAlterar','#divBotoesDetalha').hide();
								$('#btExcluir','#divBotoesDetalha').hide();
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

function formataDetalhamento() {

	$('#divRotina').css('width','640px');

	var divRegistro = $('div.divRegistros','#divDetalhamento');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'100px','width':'100%'});
	
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];	
	
	var arrayLargura = new Array();
	arrayLargura[0] = '90px';
	arrayLargura[1] = '150px';
	arrayLargura[2] = '150px';
	arrayLargura[3] = '90px';
	
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'right';
	
	var metodoTabela = '';
			
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );
	
	glbTabCdfaixa = '';
	glbTabVlfaixa_inicial = '';
	glbTabVlfaixa_final = '';
	glbTabVlpercentual_irrf = '';
	glbTabVldeducao ='';
	
	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		glbTabCdfaixa = $(this).find('#cdfaixa > span').text();
		glbTabVlfaixa_inicial = $(this).find('#vlfaixa_inicial > span').text();
		glbTabVlfaixa_final = $(this).find('#vlfaixa_final > span').text();
		glbTabVlpercentual_irrf = $(this).find('#vlpercentual_irrf > span').text();
		glbTabVldeducao = $(this).find('#vldeducao > span').text();
	});
	
	$('table > tbody > tr:eq(0)', divRegistro).click();
	
	return false;
}

// Detalhamento Faixa
function mostraDetalhamentoFaixa( value ) {

	cddopdet = value;
	
	if ( (glbTabCdfaixa == '') && ( cddopdet != 'I' ) ){
		showError('error','Não há registro selecionado','Alerta - Ayllos',"unblockBackground()");
		return false;
	}
	
	showMsgAguardo('Aguarde, buscando faixas de IRRF...');

	// Executa script através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/fairrf/detalhamento_faixa.php', 
		data: {			
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			buscaDetalhesFaixa();
		}				
	});
	
	return false;
	
}

function buscaDetalhesFaixa() {
	
	showMsgAguardo('Aguarde, buscando detalhamento faixas de IRRF...');
	
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/fairrf/busca_detalhes_faixa.php', 
		data: {
			cdfaixa: glbTabCdfaixa,
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
					formataDetalhaFaixa();
					
					
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

function formataDetalhaFaixa() {

	$('#divRotina').css('width','660px');

	var frmDetalhaFaixa = "frmDetalhaFaixa";
	
 	// Rotulos 
	var lCdfaixa	       = $('label[for="cdfaixa"]','#'+frmDetalhaFaixa);
	var lVlfaixa_inicial   = $('label[for="vlfaixa_inicial"]','#'+frmDetalhaFaixa);
	var lVlfaixa_final	   = $('label[for="vlfaixa_final"]','#'+frmDetalhaFaixa);
	var lVlpercentual_irrf = $('label[for="vlpercentual_irrf"]','#'+frmDetalhaFaixa);
	var lVldeducao 		   = $('label[for="vldeducao"]','#'+frmDetalhaFaixa);
	
	lCdfaixa.addClass('rotulo').css('width','140px');
	lVlfaixa_inicial.addClass('rotulo').css('width','133px');
	lVlfaixa_final.addClass('rotulo').css('width','133px');
	lVlpercentual_irrf.addClass('rotulo').css('width','140px');
	lVldeducao.addClass('rotulo').css('width','140px');
	
	// Campos
	var cTodos	  		   = $('input[type="text"],select','#'+frmDetalhaFaixa);
	var cCdfaixa	       = $('#cdfaixa','#'+frmDetalhaFaixa);	
	var cVlfaixa_inicial   = $('#vlfaixa_inicial','#'+frmDetalhaFaixa);	
	var cVlfaixa_final	   = $('#vlfaixa_final','#'+frmDetalhaFaixa);
	var cVlpercentual_irrf = $('#vlpercentual_irrf','#'+frmDetalhaFaixa);
	var cVldeducao 		   = $('#vldeducao','#'+frmDetalhaFaixa);

	cTodos.habilitaCampo();
	cCdfaixa.css('width','90px').desabilitaCampo();
	cVlfaixa_inicial.addClass('moeda').css('width','100px');
	cVlfaixa_final.addClass('moeda').css('width','100px');
	cVlpercentual_irrf.addClass('moeda').css('width','100px');
	cVldeducao.addClass('moeda').css('width','100px');
		
	layoutPadrao();
	hideMsgAguardo();
	
	if ( cddopdet == 'X' ) {
		// Desabilita campos do formulario frmDetalhaFaixa quando opção consulta (C).
		cTodos.desabilitaCampo();
	}
	
	cVlfaixa_inicial.focus();
	
	return false;
}

function controlafrmDetalhaFaixa() {
	$('#vlfaixa_inicial','#frmDetalhaFaixa').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#vlfaixa_final','#frmDetalhaFaixa').focus();
			return false;
		}
	});
	
	$('#vlfaixa_final','#frmDetalhaFaixa').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#vlpercentual_irrf','#frmDetalhaFaixa').focus();
			return false;
		}
	});
	
	$('#vlpercentual_irrf','#frmDetalhaFaixa').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#vldeducao','#frmDetalhaFaixa').focus();
			return false;
		}	
	});
}

function realizaOpDetalhamento(cddopdet) {

	$('input,select', '#frmDetalhaFaixa').removeClass('campoErro'); /* Remove foco de erro */

	var cdfaixa           = $('#cdfaixa','#frmDetalhaFaixa').val();
	var inpessoa          = glbTabInPessoa;
	var vlfaixa_inicial   = $('#vlfaixa_inicial','#frmDetalhaFaixa').val();
	var vlfaixa_final     = $('#vlfaixa_final','#frmDetalhaFaixa').val();
	var vlpercentual_irrf = $('#vlpercentual_irrf','#frmDetalhaFaixa').val();
	var vldeducao 		  = $('#vldeducao','#frmDetalhaFaixa').val();
	
	cdfaixa = normalizaNumero(cdfaixa);
	inpessoa = normalizaNumero(inpessoa);
	vlfaixa_inicial = normalizaNumero(vlfaixa_inicial);
	vlfaixa_final = normalizaNumero(vlfaixa_final);
	vlpercentual_irrf = normalizaNumero(vlpercentual_irrf);
	vldeducao = normalizaNumero(vldeducao);
	
	if ( cddopdet != 'E') {
	
		if ( vlfaixa_inicial == '')	{
			showError('error','Valor Inicial deve ser informado.','Alerta - Ayllos',"$(\'#vlfaixa_inicial\',\'#frmDetalhaFaixa\').focus(); blockBackground(parseInt($('#divRotina').css('z-index')))");
			return false;
		}
		
		if ( vlfaixa_final == '')	{
			showError('error','Valor Final deve ser informado.','Alerta - Ayllos',"$(\'#vlfaixa_final\',\'#frmDetalhaFaixa\').focus(); blockBackground(parseInt($('#divRotina').css('z-index')))");
			return false;
		}

		if ( converteMoedaFloat(vlfaixa_inicial) > converteMoedaFloat(vlfaixa_final) )	{
			showError('error','Valor Inicial deve ser menor que Valor Final.','Alerta - Ayllos',"$(\'#vlfaixa_inicial\',\'#frmDetalhaFaixa\').focus(); blockBackground(parseInt($('#divRotina').css('z-index')))");
			return false;
		}
		
		if ( vlpercentual_irrf == '')	{
			showError('error','Percentual de IRRF deve ser informado.','Alerta - Ayllos',"$(\'#vlpercentual_irrf\',\'#frmDetalhaFaixa\').focus(); blockBackground(parseInt($('#divRotina').css('z-index')))");
			return false;
		}
		
		if ( vldeducao == '')	{
			showError('error','Valor de Dedução deve ser informado.','Alerta - Ayllos',"$(\'#vldeducao\',\'#frmDetalhaFaixa\').focus(); blockBackground(parseInt($('#divRotina').css('z-index')))");
			return false;
		}
	}
	
	// Mostra mensagem de aguardo
	if (cddopdet == "I"){  	   showMsgAguardo("Aguarde, incluindo Faixa de IRRF..."); } 
	else if (cddopdet == "A"){ showMsgAguardo("Aguarde, alterando Faixa de IRRF...");  }
	else if (cddopdet == "E"){ showMsgAguardo("Aguarde, excluindo Faixa de IRRF...");  }
	else if (cddopdet == "R"){ showMsgAguardo("Aguarde, excluindo Faixa de IRRF...");  }
	else { showMsgAguardo("Aguarde, liberando aplicacao..."); }
	
	if (cddopdet == "E") {
		cdfaixa = glbTabCdfaixa;
	}	
	
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/fairrf/manter_rotina_detalhamento.php", 
		data: {
			cddopcao: cddopcao,
			cddopdet: cddopdet,
			cdfaixa: cdfaixa,
			inpessoa: inpessoa,
			vlfaixa_inicial: vlfaixa_inicial,
			vlfaixa_final: vlfaixa_final,
			vlpercentual_irrf: vlpercentual_irrf,
			vldeducao: vldeducao,
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

function excluirDetalhamento() {

	if ( glbTabCdfaixa == '' ){
		showError('error','Não há registro selecionado','Alerta - Ayllos',"unblockBackground()");
		return false
	} else {
		showConfirmacao('Deseja realmente excluir esta faixa de IRRF?','Confirma&ccedil;&atilde;o - Ayllos','realizaOpDetalhamento(\'E\');','return false;','sim.gif','nao.gif');
	}

}
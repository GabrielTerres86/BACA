/*!
 * FONTE        : pagprj.js
 * CRIAÇÃO      : Jean Calão	
 * DATA CRIAÇÃO : 14/06/2017
 * OBJETIVO     : Biblioteca de funções da tela pagprj
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
$(document).ready(function() {

	estadoInicial();

	highlightObjFocus( $('#frmCab') );

	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});

	return false;

});

function estadoInicial() {
	
	$('#frmCab').css({'display':'block'});
	$('#divEstorn').css({'display':'none'});	
	$('#divBotoes','#divTela').css({'display':'none'});	
	
	$('#divEstorn').html('');
	$('#divBotoes','#divTela').html('');
	
	formataCabecalho();
	return false;
}

function controlaFoco() {
		
	$('#cddopcao','#frmCab').unbind('keypress').bind('keypress', function(e) {
	
		if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda') ) { return false; }
		
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			carregaTelaFiltrarContrato();
			return false;
		}	
	});
	
	$('#btnOK','#frmCab').unbind('keypress').bind('keypress', function(e) {
		
		if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda') ) { return false; }
		
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			carregaTelaFiltrarContrato();
			return false;
		}	
	});
	
	$('#btnOK','#frmCab').unbind('click').bind('click', function(){
	
		if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda') ) { return false; }		
		carregaTelaFiltrarContrato();
		return false;			
	});
				
	return false;	
}

function formataCabecalho() {

	$('input,select', '#frmCab').removeClass('campoErro');
	$('#divTela').css({'display':'inline'}).fadeTo(0,0.1);
	removeOpacidade('divTela');	

	cTodosCabecalho = $('input[type="text"],select','#frmCab'); 
	cTodosCabecalho.limpaFormulario();

	// cabecalho
	rCddopcao = $('label[for="cddopcao"]','#frmCab');
	cCddopcao = $('#cddopcao','#frmCab');

	//Rótulos
	rCddopcao.css('width','44px');	

	//Campos	
	cCddopcao.css({'width':'496px'}).habilitaCampo().focus();	
	
	controlaFoco();
	layoutPadrao();

	return false;	

}

function formataCampos(){
	
	var cddopcao = $('#cddopcao','#frmCab').val();
	//layoutPadrao();
	switch(cddopcao){
		
		
		// Consulta Estorno
		case 'C':
			var cdtpagto = $('#dtpagto', '#frmEstornoPagto');
			var cNrdconta = $('#nrdconta', '#frmEstornoPagto');
			var cNrctremp = $('#nrctremp', '#frmEstornoPagto');			
			
			var rdtpagto = $('label[for="dtpagto"]', '#frmEstornoPagto');
			var rNrdconta = $('label[for="nrdconta"]', '#frmEstornoPagto');
			var rNrctremp = $('label[for="nrctremp"]', '#frmEstornoPagto');			
			
			cdtpagto.addClass('data').css({'width':'80px'});	
			
			cNrdconta.addClass('conta pesquisa').css({'width':'80px'});
			cNrctremp.addClass('pesquisa').css({'width':'80px','text-align':'right'}).setMask('INTEGER','z.zzz.zzz.zzz','.','');
						
			rNrdconta.addClass('rotulo').css({width: "60px"});			
			rNrctremp.addClass('rotulo-linha').css({width: "80px"});			
			
			highlightObjFocus($('#frmEstornoPagto'));
			cdtpagto.habilitaCampo();
			cNrdconta.habilitaCampo();
			cNrctremp.habilitaCampo();			
			
			cNrdconta.unbind('keypress').bind('keypress', function(e) {
				if ( divError.css('display') == 'block' ) { return false; }
				// Se é a tecla ENTER,
				if ( e.keyCode == 13 ) {
					if ( normalizaNumero( cNrdconta.val() ) == 0 ) {
						mostraPesquisaAssociado('nrdconta', 'frmEstornoPagto');
						return false;
					}
					cNrctremp.focus();
					return false;
				}
		    });
			
			cNrctremp.unbind('keypress').bind('keypress', function(e) {
				if ( divError.css('display') == 'block' ) { return false; }		
				// Se é a tecla ENTER,
				if ( e.keyCode == 13 ) {
					if ( normalizaNumero( cNrctremp.val() ) == 0 ) {
						mostraContrato();
					} else {
						carregaTelaConsultarPagto();
						
					}
					return false;
				}
			});
			
			trocaBotao('estadoInicial();','ajustaBotaoContinuar()','Continuar');	
			
		break;
		
		case 'P':
			var cNrdconta = $('#nrdconta', '#frmEnvioEmpPagto');
			var cNrctremp = $('#nrctremp', '#frmEnvioEmpPagto');

			var cVlpagto = $('#vlpagto', '#frmEnvioEmpPagto');
			var cVlprincipal = $('#vlprincipal', '#frmEnvioEmpPagto');
			var cVljuros = $('#vljuros', '#frmEnvioEmpPagto');
			var cVlmulta = $('#vlmulta', '#frmEnvioEmpPagto');
			var cVlabono = $('#vlabono', '#frmEnvioEmpPagto');
			var cVlsaldo = $('#vlsaldo', '#frmEnvioEmpPagto');	
			
			var rNrdconta = $('label[for="nrdconta"]', '#frmEnvioEmpPagto');
			var rNrctremp = $('label[for="nrctremp"]', '#frmEnvioEmpPagto');	
			
			cNrdconta.addClass('conta pesquisa').css({'width':'80px'});
			cNrctremp.addClass('pesquisa').css({'width':'80px','text-align':'right'}).setMask('INTEGER','z.zzz.zzz.zzz','.','');
						
			rNrdconta.addClass('rotulo').css({width: "60px"});			
			rNrctremp.addClass('rotulo-linha').css({width: "80px"});

		    cVlpagto.addClass('moeda campo');
		    cVlprincipal.addClass('moeda campoTelaSemBorda');
		    cVljuros.addClass('moeda campoTelaSemBorda');
		    cVlmulta.addClass('moeda campoTelaSemBorda');
		    cVlabono.addClass('moeda campo');
		    cVlsaldo.addClass('moeda campoTelaSemBorda');
			
			highlightObjFocus($('#frmEnvioEmpPagto'));
			cNrdconta.habilitaCampo();
			cNrctremp.habilitaCampo();			
			
     		if ( normalizaNumero( cVlpagto.val() ) != 0 ) {
				cVlSaldo.val() = 1;
			}
					
			cNrdconta.unbind('keypress').bind('keypress', function(e) {
				if ( divError.css('display') == 'block' ) { return false; }
				// Se é a tecla ENTER,
				if ( e.keyCode == 13 ) {
					if ( normalizaNumero( cNrdconta.val() ) == 0 ) {
						mostraPesquisaAssociado('nrdconta', 'frmEnvioEmpPagto');
						return false;
					}
					cNrctremp.focus();
					return false;
				}
		    });
			
			cNrctremp.unbind('keypress').bind('keypress', function(e) {
				if ( divError.css('display') == 'block' ) { return false; }		
				// Se é a tecla ENTER,
				if ( e.keyCode == 13 ) {
					if ( normalizaNumero( cNrctremp.val() ) == 0 ) {
						mostraContrato();
					} else {
						carregaTelaConsultarPagto();
					}
					return false;
				}
				
				if ( e.keyCode == 9 ) {
					carregaTelaConsultarPagto();
					return false;
				}
			});
			
			trocaBotao('estadoInicial();','carregaTelaConsultarPagto()','Continuar');			
		break;
		
	}
	
	
    layoutPadrao();
	controlaPesquisas();	
    return false;
}

function controlaFocus(iOpcao){
	switch (iOpcao){
		
		case 'C':
		    $('#dtpagto','#frmEstornoPagto').focus();
		break;
		case 'P':
			$('#nrdconta','#frmEnvioEmpPagto').focus();
		break;
	}	
}	

function trocaBotao(funcaoVoltar, nomeFuncao, nomeBotao){
	var nomeFuncao = nomeFuncao || '';
	var nomeBotao  = nomeBotao  || '';
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').css({'display':'block'});
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onClick="'+funcaoVoltar+'; return false;">Voltar</a>&nbsp;');
	
	if (nomeFuncao != 'Estornar_todos();'){
		$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onClick="'+nomeFuncao+'; return false;">'+nomeBotao+'</a>');	
		
	}
	/*if (nomeFuncao == 'Estornar_todos();') {
		$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onClick="'+nomeFuncao+'; return false;">'+nomeBotao+'</a>');
	}*/

	return false;
}

function selecionaContrato() {
	
	var cddopcao = $('#cddopcao','#frmCab').val();
    var nrctremp = 0;
    var nmformul = '#frmEstornoPagto';

    if ( $('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao') ) {					
		$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				nrctremp = $('#nrctremp', $(this) ).val(); 
			}	
		});
	}

	$('#nrctremp',nmformul).val( nrctremp ).focus();
	fechaRotina( $('#divRotina') );
	return false;
}

function controlaPesquisas() {

    var cddopcao = $('#cddopcao','#frmCab').val();
	if (cddopcao == 'C') {
       var nmformul = 'frmEstornoPagto';
	}
	else
	{
		var nmformul = 'frmEnvioEmpPagto';
	}

   	// Atribui a classe lupa para os links e desabilita todos
	$('a','#' + nmformul).addClass('lupa').css('cursor','auto');	
	
	// Percorrendo todos os links
	$('a','#' + nmformul).each( function() {
		if ( !$(this).prev().hasClass('campoTelaSemBorda') ) { $(this).css('cursor','pointer'); }
	});
	
	/*---------------------*/
	/*  CONTROLE CONTA/DV  */
	/*---------------------*/
	var linkConta = $('a:eq(0)','#' + nmformul);

	if ( linkConta.prev().hasClass('campoTelaSemBorda') ) {		
		linkConta.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {
		linkConta.css('cursor','pointer').unbind('click').bind('click', function() {			
			// Se esta desabilitado o campo da conta
			if ($("#nrdconta","#" + nmformul).prop("disabled") == true){
				return;
			}
			mostraPesquisaAssociado('nrdconta',nmformul);
		});
	}

	/*--------------------*/
	/*  CONTROLE CONTRATO */
	/*--------------------*/
	var linkContrato = $('a:eq(1)','#' + nmformul);	
	if ( linkContrato.prev().hasClass('campoTelaSemBorda') ) {		
		linkContrato.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {
		linkContrato.css('cursor','pointer').unbind('click').bind('click', function(){
			if ($("#nrctremp","#" + nmformul).prop("disabled") == true){
				return;
			}
			mostraContrato();
		});
	}	

	return false;
}

function formataGridEstornos(){
	
    var divRegistro = $('#divEstornos');
    var tabela      = $('table', divRegistro );
    var linha       = $('table > tbody > tr', divRegistro );

    divRegistro.css({'height':'120px'});

    var ordemInicial = new Array();
    ordemInicial = [[0,0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '80px';
    arrayLargura[1] = '80px';
    arrayLargura[2] = '80px'; 
	arrayLargura[3] = '90px'; 
	arrayLargura[3] = '100px'; 
	
    var arrayAlinha = new Array();
    arrayAlinha[0] = 'right';
    arrayAlinha[1] = 'right';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'right';    arrayAlinha[4] = 'left';    

    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);
    return false;	
}	

function formataTelaLancamentos() {

	var cTotalest = $('#totalest','#frmEstornoPagto');
	var cDsjustif = $('#dsjustificativa','#frmEstornoPagto');
	
	var rTotalest = $('label[for="totalest"]', '#frmEstornoPagto');
	var rDsjustif = $('label[for="dsjustificativa"]', '#frmEstornoPagto');

    var divRegistro = $('#divLancamentoParcela');
    var tabela      = $('table', divRegistro );
    var linha       = $('table > tbody > tr', divRegistro );

	rDsjustif.addClass('rotulo').css({width:"75px"});
	rTotalest.addClass('rotulo-linha').css( {'width':'80px' , 'margin-left':'310px'});
	
	cDsjustif.addClass('alphanum').css({'width':'562px','height':'80px','float':'left','margin':'3px 0px 3px 3px','padding-right':'1px'});			
	cTotalest.addClass('campo').css({'width':'88px','padding-top':'3px','padding-bottom':'3px','margin-left':'09px'});

	cDsjustif.habilitaCampo();
	cTotalest.desabilitaCampo();	

	// FORMATA O GRID DOS LANCAMENTOS DE PAGAMENTO
    divRegistro.css({'height':'120px'});

    var ordemInicial = new Array();
    ordemInicial = [[0,0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '60px';
    arrayLargura[1] = '80px';
    arrayLargura[2] = '110px';
    arrayLargura[3] = '80px';
    arrayLargura[4] = '60px';
 
	var arrayAlinha = new Array();
    arrayAlinha[0] = 'right';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'right';
    arrayAlinha[4] = 'right';
    arrayAlinha[5] = 'right';
 
    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);
    return false;
}

function formataDetalhesEstorno(){

	var cCdestorno  = $('#cdestorno','#frmDetalhesEstorno');
	var cNmoperad   = $('#nmoperad','#frmDetalhesEstorno');
	var cDtestorno  = $('#dtestorno','#frmDetalhesEstorno');
	var cHrestorno  = $('#hrestorno','#frmDetalhesEstorno');
	var cDsjustif   = $('#dsjustificativa','#frmDetalhesEstorno');
	
	var rCdestorno = $('label[for="cdestorno"]', '#frmDetalhesEstorno');	
	var rNmoperad  = $('label[for="nmoperad"]', '#frmDetalhesEstorno');	
	var rDtestorno = $('label[for="dtestorno"]', '#frmDetalhesEstorno');	
	var rHrestorno = $('label[for="hrestorno"]', '#frmDetalhesEstorno');	
	var rDsjustif  = $('label[for="dsjustificativa"]', '#frmDetalhesEstorno');	

	var divRegistro = $('#divEstornoDetalhes');
    var tabela      = $('table', divRegistro );
    var linha       = $('table > tbody > tr', divRegistro );	

	cCdestorno.addClass('campo').css({'width':'80px'});
	cNmoperad.addClass('campo').css({'width':'220px'});
	cDtestorno.addClass('campo').css({'width':'80px'});
	cHrestorno.addClass('campo').css({'width':'70px'});
	cDsjustif.addClass('alphanum').css({'width':'562px','height':'80px','float':'left','margin':'3px 0px 3px 3px','padding-right':'1px'});			
	
	rCdestorno.addClass('rotulo').css({'width':'80px'});
	rNmoperad.addClass('rotulo').css({'width':'80px'});	
	rDtestorno.addClass('rotulo-linha').css({'width':'50px'});	
	rHrestorno.addClass('rotulo-linha').css({'width':'50px'});	
	rDsjustif.addClass('rotulo').css({width:"80px"});
	
	cCdestorno.desabilitaCampo();
	cNmoperad.desabilitaCampo();
	cDtestorno.desabilitaCampo();
	cHrestorno.desabilitaCampo();
	cDsjustif.desabilitaCampo();

	// FORMATA O GRID DOS LANCAMENTOS DE PAGAMENTO
    divRegistro.css({'height':'150px'});
	
    var ordemInicial = new Array();
    ordemInicial = [[0,0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '60px';
    arrayLargura[1] = '75px';
    arrayLargura[2] = '75px';
    arrayLargura[3] = '180px';    
	
	var arrayAlinha = new Array();
    arrayAlinha[0] = 'right';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'left';
    arrayAlinha[4] = 'right';    
    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);
    return false;	
}
function carregaTelaFiltrarContrato(){
	
	var cCddopcao = $('#cddopcao','#frmCab');
	cCddopcao.desabilitaCampo();
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/pagprj/carrega_tela_estorno_pagto.php",
		dataType: "html",
		data: {			
		    cddopcao: cCddopcao.val(),
			redirect: "html_ajax"			
		},
		error: function(objAjax,responseError,objExcept){
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response){
			$("#divEstorn").html(response);
			$('#divEstorn').css({'display':'block'});
			controlaFocus(cCddopcao.val());
		}
	});
	
	return false;
}

function manterRotina(operacao){
	
	hideMsgAguardo();
	
	switch (operacao){
		
		case 'VALIDA_DADOS':
			showMsgAguardo("Aguarde, validando os dados...");
		break;
		
		case 'EFETUA_ESTORNO':
			showMsgAguardo("Aguarde, estornando os lan&ccedil;amentos...");
		break;	
	}
	var cdtpagto        = $('#dtpagto','#frmEstornoPagto');
	var cNrdconta 		 = $('#nrdconta','#frmEstornoPagto');
    var cNrctremp 		 = $('#nrctremp','#frmEstornoPagto');
	
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/pagprj/manter_rotina.php", 
		data: {
			operacao: operacao,
		    nrdconta: normalizaNumero(cNrdconta.val()),			
			nrctremp: normalizaNumero(cNrctremp.val()),
			redirect: "script_ajax"
		},
		error: function(objAjax,responseError,objExcept){
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divTela').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();
				eval(response);
				return false;
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
			}
		}
	});	
	return false;
}

function carregaTelaConsultarPagto(){
	
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, buscando os dados...");
	var cCdopcao = $('#cddopcao','#frmCab');
	var cDtpagto = $('#dtpagto','#frmEstornoPagto');
    var cNrdconta = $('#nrdconta','#frmEstornoPagto');
    var cNrctremp = $('#nrctremp','#frmEstornoPagto');
	
	if (cCdopcao.val() == 'P') {
	   var cNrdconta = $('#nrdconta','#frmEnvioEmpPagto');
       var cNrctremp = $('#nrctremp','#frmEnvioEmpPagto');		
	}
    // Carrega dados parametro através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/pagprj/carrega_consulta_pagto.php',
        data:{cddopcao: cCdopcao.val(),
		      dtpagto:  cDtpagto.val(),
		      nrdconta: normalizaNumero(cNrdconta.val()),
              nrctremp: normalizaNumero(cNrctremp.val()),
              redirect: 'script_ajax'
		},
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Erro(01)-N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response){	
			if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
				try {					
					$('#divLancamentosPagamento').html(response);				
					formataGridEstornos();				
					hideMsgAguardo();
					trocaBotao('estadoInicial();','ajustaBotaoContinuar()','Continuar');
					return false;
				} catch (error) {
					hideMsgAguardo();
					showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
				}
			} else {
				try {
                    eval(response);
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', '2-N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
			}
        }
    });
    return false;	
}

function carregaTelaEstornar(cNrdconta1, cNrctremp1, cDtmvtolt){
	
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, processando o estorno...");	
	var cDtmvtolt1 = $('#dtmvtolt','#frmEstornoPagto');
	var cIdtipo = $('#idtipo','#frmEstornoPagto');
	 // Carrega dados parametro através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/pagprj/estornar_pagto.php',
        data:{nrdconta1: cNrdconta1,
              nrctremp1: cNrctremp1,
			  dtmvtolt : cDtmvtolt1.val(),
			  idtipo:cIdtipo.val(),
              redirect: 'script_ajax'
		},
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Erro(10)-N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.'.cNrdconta1, 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response){	
			if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
				try {
					$('#divLancamentosPagamento').html(response);				
					formataGridEstornos();				
					hideMsgAguardo();
					return false;
				} catch (error) {
					hideMsgAguardo();
					showError('error', '1-N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
				}
			} else {
				try {
                    eval(response);
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', '2-N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
			}
        }
    });
    return false;	
}

function carregaEstornarTodos(){
	
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, processando o estorno...");	
	var cdtpagto = $('#dtpagto','#frmEstornoPagto');
    var cNrdconta = $('#nrdconta','#frmEstornoPagto');
    var cNrctremp = $('#nrctremp','#frmEstornoPagto');

	 // Carrega dados parametro através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/pagprj/estornar_todos_pagto.php',
        data:{dtpagto:cdtpagto.val(),
		  	  nrdconta: normalizaNumero(cNrdconta.val()),
              nrctremp: normalizaNumero(cNrctremp.val()),
			  redirect: 'script_ajax'
		},
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Erro-N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response){	
			if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
				try {
					$('#divLancamentosPagamento').html(response);				
					formataGridEstornos();				
					hideMsgAguardo();
					return false;
				} catch (error) {
					hideMsgAguardo();
					showError('error', '1-N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
				}
			} else {
				try {
                    eval(response);
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', '2-N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
			}
        }
    });
    return false;	
}

function carregaPagtoEpr(cNrdconta, cNrctremp, cVlpagto, cVlabono){
	
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, efetuando pagamento do prejuizo de emprestimo ...");	
    // Carrega dados parametro através de ajax
	
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/pagprj/forcar_pagto.php',
        data:{nrdconta: normalizaNumero(cNrdconta.val()),
		      nrctremp: normalizaNumero(cNrctremp.val()),
			  vlpagto: cVlpagto.val().replace(".","").replace(",","."),
              vlabono: cVlabono.val().replace(".","").replace(",","."),			  
              redirect: 'script_ajax'
		},
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Erro-N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response){	
			if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
				try {
					hideMsgAguardo();
					return false;
				} catch (error) {
					hideMsgAguardo();
					showError('error', '1-N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
				}
			} else {
				try {
                    eval(response);
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', '2-N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.(carregaPgtoEpr)>'.cNrdconta.val(), 'Alerta - Ayllos', 'unblockBackground()');
                }
			}
        }
    });
    return false;	
}

function removeCaracteresInvalidos(str){
	str.replace(/\r\n/g,' ').replace("'","");
	return str.replace(/[^A-z0-9\sÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëÇçÌÍÎÏìíîïÙÚÛÜùúûüÿÑñ\!\@\$\%\*\(\)\-\_\=\+\[\]\{\}\?\;\:\.\,\/\>\<]/g,"");
}

function ajustaBotaoContinuar(){
	
	var cdtpagto = $('#dtpagto', '#frmEstornoPagto');
	var cNrdconta = $('#nrdconta', '#frmEstornoPagto');
	var cNrdconta1 = $('#nrdconta', '#frmEnvioCCPagto');
	var cNrctremp = $('#nrctremp', '#frmEstornoPagto');	
	var cNrdconta2 = $('#nrdconta', '#frmEnvioEmpPagto');
	var cNrctremp2 = $('#nrctremp', '#frmEnvioEmpPagto');	
	var cVlpagto = $('#vlpagto', '#frmEnvioEmpPagto');
	var cVlabono = $('#vlabono', '#frmEnvioEmpPagto');
	
	if ( $('#cddopcao','#frmCab').val() == 'C') {
		carregaTelaConsultarPagto();
	}
	
	if ( $('#cddopcao','#frmCab').val() == 'P') {
		carregaPagtoEpr(cNrdconta2, cNrctremp2, cVlpagto, cVlabono);
	}
		
	return false;
	
}

function calcularSaldo(){

	var valVlpagto = $('#vlpagto', '#frmEnvioEmpPagto').val().replace(".","").replace(",",".");
    var valVlprincipal = $('#vlprincipal', '#frmEnvioEmpPagto').val().replace(".","").replace(",",".");
	var valVljuros = $('#vljuros', '#frmEnvioEmpPagto').val().replace(".","").replace(",",".");
	var valVlmulta = $('#vlmulta', '#frmEnvioEmpPagto').val().replace(".","").replace(",",".");
	var valVlabono = $('#vlabono', '#frmEnvioEmpPagto').val().replace(".","").replace(",",".");
	var cVlsaldo = $('#vlsaldo', '#frmEnvioEmpPagto');

	var resultado = valVlprincipal - valVlpagto - valVljuros - valVlmulta - valVlabono;

	strResultado = resultado.toString().replace(".",",")

	cVlsaldo.val(strResultado);

	layoutPadrao();

	if(resultado < 0){
		cVlsaldo.val('-'+cVlsaldo.val());
	}
}

// contrato
function mostraContrato() {
	
	showMsgAguardo('Aguarde, buscando ...');

	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/pagprj/contrato.php', 
		data: {
			redirect: 'html_ajax'			
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			buscaContrato();
			return false;
		}				
	});
	return false;	
}

function buscaContrato() {

    showMsgAguardo('Aguarde, buscando ...');

    var cddopcao = $('#cddopcao','#frmCab').val();
	if (cddopcao == 'C') {
        var nmformul = $('#nrdconta', '#frmEstornoPagto');
	} else {
		var nmformul = $('#nrdconta', '#frmEnvioEmpPagto');	
	}
    var nrdconta = normalizaNumero($(nmformul).val());
    
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/pagprj/busca_contrato.php',
        data: {
            nrdconta: nrdconta,
            redirect: 'script_ajax'
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
        },
        success: function(response) {
			try {
                $('#divConteudo').html(response);
                //eval(response);
				exibeRotina($('#divRotina'));
                formataGridContrato();
                return false;
            } catch(error) {
                hideMsgAguardo();					
                showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
            }
        }
    });
    return false;
}


function formataGridContrato() {

    var divRegistro = $('div.divRegistros','#divContrato');
    var tabela      = $('table', divRegistro );
    var linha       = $('table > tbody > tr', divRegistro );

    divRegistro.css({'height':'120px','width':'500px'});

    var ordemInicial = new Array();
    ordemInicial = [[0,0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '60px';
    arrayLargura[1] = '62px';
    arrayLargura[2] = '80px';
    arrayLargura[3] = '60px';
    arrayLargura[4] = '80px';
    arrayLargura[5] = '38px';


    var arrayAlinha = new Array();
    arrayAlinha[0] = 'right';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'right';
    arrayAlinha[4] = 'right';
    arrayAlinha[5] = 'right';
    arrayAlinha[6] = 'right';

    var metodoTabela = 'selecionaContrato();';

    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );

    hideMsgAguardo();
    bloqueiaFundo( $('#divRotina') );

    return false;
}
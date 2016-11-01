/*!
 * FONTE        : estorn.js
 * CRIA��O      : James Prust Junior
 * DATA CRIA��O : 14/09/2015
 * OBJETIVO     : Biblioteca de fun��es da tela ESTORN
 * --------------
 * ALTERA��ES   : 
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

	//R�tulos
	rCddopcao.css('width','44px');	

	//Campos	
	cCddopcao.css({'width':'496px'}).habilitaCampo().focus();	
	
	controlaFoco();
	layoutPadrao();

	return false;	

}

function formataCampos(){
	
	var cddopcao = $('#cddopcao','#frmCab').val();
	
	switch(cddopcao){
		
		// Estorno
		case 'E':
			var cNrdconta = $('#nrdconta', '#frmEstornoPagamento');
			var cNrctremp = $('#nrctremp', '#frmEstornoPagamento');			
			
			var rNrdconta = $('label[for="nrdconta"]', '#frmEstornoPagamento');
			var rNrctremp = $('label[for="nrctremp"]', '#frmEstornoPagamento');			
			
			cNrdconta.addClass('conta pesquisa').css({'width':'80px'});
			cNrctremp.addClass('pesquisa').css({'width':'80px','text-align':'right'}).setMask('INTEGER','z.zzz.zzz.zzz','.','');
						
			rNrdconta.addClass('rotulo').css({width: "60px"});			
			rNrctremp.addClass('rotulo-linha').css({width: "80px"});			
			
			highlightObjFocus($('#frmEstornoPagamento'));
			cNrdconta.habilitaCampo();
			cNrctremp.habilitaCampo();			
			
			cNrdconta.unbind('keypress').bind('keypress', function(e) {
				if ( divError.css('display') == 'block' ) { return false; }
				// Se � a tecla ENTER,
				if ( e.keyCode == 13 ) {
					if ( normalizaNumero( cNrdconta.val() ) == 0 ) {
						mostraPesquisaAssociado('nrdconta', 'frmEstornoPagamento');
						return false;
					}
					cNrctremp.focus();
					return false;
				}
		    });
			
			cNrctremp.unbind('keypress').bind('keypress', function(e) {
				if ( divError.css('display') == 'block' ) { return false; }		
				// Se � a tecla ENTER,
				if ( e.keyCode == 13 ) {
					if ( normalizaNumero( cNrctremp.val() ) == 0 ) {
						mostraContrato();
					} else {
						carregaLancamentosPagamentos();						
					}
					return false;
				}
			});
			
			//trocaBotao('estadoInicial()');
			trocaBotao('estadoInicial();','ajustaBotaoContinuar()','Continuar');	
		break;
		
		// Estorno
		case 'C':
			var cNrdconta = $('#nrdconta', '#frmEstornoPagamento');
			var cNrctremp = $('#nrctremp', '#frmEstornoPagamento');			
			
			var rNrdconta = $('label[for="nrdconta"]', '#frmEstornoPagamento');
			var rNrctremp = $('label[for="nrctremp"]', '#frmEstornoPagamento');			
			
			cNrdconta.addClass('conta pesquisa').css({'width':'80px'});
			cNrctremp.addClass('pesquisa').css({'width':'80px','text-align':'right'}).setMask('INTEGER','z.zzz.zzz.zzz','.','');
						
			rNrdconta.addClass('rotulo').css({width: "60px"});			
			rNrctremp.addClass('rotulo-linha').css({width: "80px"});			
			
			highlightObjFocus($('#frmEstornoPagamento'));
			cNrdconta.habilitaCampo();
			cNrctremp.habilitaCampo();			
			
			cNrdconta.unbind('keypress').bind('keypress', function(e) {
				if ( divError.css('display') == 'block' ) { return false; }
				// Se � a tecla ENTER,
				if ( e.keyCode == 13 ) {
					if ( normalizaNumero( cNrdconta.val() ) == 0 ) {
						mostraPesquisaAssociado('nrdconta', 'frmEstornoPagamento');
						return false;
					}
					cNrctremp.focus();
					return false;
				}
		    });
			
			cNrctremp.unbind('keypress').bind('keypress', function(e) {
				if ( divError.css('display') == 'block' ) { return false; }		
				// Se � a tecla ENTER,
				if ( e.keyCode == 13 ) {
					if ( normalizaNumero( cNrctremp.val() ) == 0 ) {
						mostraContrato();
					} else {
						carregaTelaConsultarEstornos();
					}
					return false;
				}
			});
			
			// trocaBotao('estadoInicial()');
			trocaBotao('estadoInicial();','ajustaBotaoContinuar()','Continuar');	
		break;
		
		// Relatorio
		case 'R':
			var cNrdconta = $('#nrdconta', '#frmImpressaoEstorno');
			var cNrctremp = $('#nrctremp', '#frmImpressaoEstorno');			
			var cDtiniest = $('#dtiniest', '#frmImpressaoEstorno');			
			var cDtfinest = $('#dtfinest', '#frmImpressaoEstorno');			
			var cCdagenci = $('#cdagenci', '#frmImpressaoEstorno');			
			
			var rNrdconta = $('label[for="nrdconta"]', '#frmImpressaoEstorno');
			var rNrctremp = $('label[for="nrctremp"]', '#frmImpressaoEstorno');			
			var rDtiniest = $('label[for="dtiniest"]', '#frmImpressaoEstorno');			
			var rDtfinest = $('label[for="dtfinest"]', '#frmImpressaoEstorno');			
			var rCdagenci = $('label[for="cdagenci"]', '#frmImpressaoEstorno');			
			
			cNrdconta.addClass('conta pesquisa').css({'width':'80px'});
			cNrctremp.addClass('pesquisa').css({'width':'80px','text-align':'right'}).setMask('INTEGER','z.zzz.zzz.zzz','.','');
			cDtiniest.addClass('data').css({'width':'80px'});
			cDtfinest.addClass('data').css({'width':'80px'});
			cCdagenci.addClass('campo').css({'width':'80px'});
			
			rNrdconta.addClass('rotulo').css({width: "80px"});			
			rNrctremp.addClass('rotulo-linha').css({width: "80px"});			
			rDtiniest.addClass('rotulo').css({'width':'80px'});				
			rDtfinest.addClass('rotulo-linha').css({'width':'97px'});				
			rCdagenci.addClass('rotulo-linha').css({'width':'90px'});				
			
			highlightObjFocus($('#frmImpressaoEstorno'));
			cNrdconta.habilitaCampo();
			cNrctremp.habilitaCampo();
			cDtiniest.habilitaCampo();
			cDtfinest.habilitaCampo();
			cCdagenci.habilitaCampo();
			
			cNrdconta.unbind('keypress').bind('keypress', function(e) {
				if ( divError.css('display') == 'block' ) { return false; }
				// Se � a tecla ENTER,
				if ( e.keyCode == 13 ) {
					cNrctremp.focus();
					return false;
				}
		    });
			
			cNrctremp.unbind('keypress').bind('keypress', function(e) {
				if (divError.css('display') == 'block' ) { return false; }
				// Se � a tecla ENTER,
				if (e.keyCode == 13){
					cDtiniest.focus();
					return false;
				}
			});
			
			cDtiniest.unbind('keypress').bind('keypress', function(e) {
				if (divError.css('display') == 'block' ) { return false; }
				// Se � a tecla ENTER,
				if (e.keyCode == 13){
					cDtfinest.focus();
					return false;
				}
			});
			
			cDtfinest.unbind('keypress').bind('keypress', function(e) {
				if (divError.css('display') == 'block' ) { return false; }
				// Se � a tecla ENTER,
				if (e.keyCode == 13){
					cCdagenci.focus();
					return false;
				}
			});
			
			cCdagenci.unbind('keypress').bind('keypress', function(e) {
				if (divError.css('display') == 'block' ) { return false; }
				// Se � a tecla ENTER,
				if (e.keyCode == 13){
				//	cCdagenci.focus();
				    geraImpressaoEstorno();
					return false;
				}
			});
			
			trocaBotao('estadoInicial();','geraImpressaoEstorno()','Imprimir');			
		break;
	}
	
    layoutPadrao();
	controlaPesquisas();	
    return false;
}

function controlaFocus(iOpcao){
	switch (iOpcao){
		
		case 'C':
		case 'E':
			$('#nrdconta','#frmEstornoPagamento').focus();
		break;
		
		case 'R':
			$('#nrdconta','#frmImpressaoEstorno').focus();
		break;	
	}	
}	

function trocaBotao(funcaoVoltar, nomeFuncao, nomeBotao){
	var nomeFuncao = nomeFuncao || '';
	var nomeBotao  = nomeBotao  || '';
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').css({'display':'block'});
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onClick="'+funcaoVoltar+'; return false;">Voltar</a>&nbsp;');
	
	if (nomeFuncao != ''){
		$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onClick="'+nomeFuncao+'; return false;">'+nomeBotao+'</a>');	
	}
	return false;
}

function selecionaContrato() {
	
	var cddopcao = $('#cddopcao','#frmCab').val();
    var nrctremp = 0;
    var nmformul = '#frmEstornoPagamento';

    if (cddopcao == 'R') {
        nmformul = '#frmImpressaoEstorno';
    }
	
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
    var nmformul = 'frmEstornoPagamento';

    if (cddopcao == 'R') {
        nmformul = 'frmImpressaoEstorno';
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

// contrato
function mostraContrato() {
	
	showMsgAguardo('Aguarde, buscando ...');

	// Executa script de confirma��o atrav�s de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/estorn/contrato.php', 
		data: {
			redirect: 'html_ajax'			
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','N�o foi poss�vel concluir a requisi��o.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			buscaContrato();
			return false;
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

function formataGridEstornos(){
	
    var divRegistro = $('#divEstornos');
    var tabela      = $('table', divRegistro );
    var linha       = $('table > tbody > tr', divRegistro );

    divRegistro.css({'height':'120px'});

    var ordemInicial = new Array();
    ordemInicial = [[0,0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '70px';
    arrayLargura[1] = '80px';
    arrayLargura[2] = '70px';    

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'right';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'left';    

    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);
    return false;	
}	

function formataTelaLancamentos() {

	var cTotalest = $('#totalest','#frmEstornoPagamento');
	var cDsjustif = $('#dsjustificativa','#frmEstornoPagamento');
	
	var rTotalest = $('label[for="totalest"]', '#frmEstornoPagamento');
	var rDsjustif = $('label[for="dsjustificativa"]', '#frmEstornoPagamento');

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

function buscaContrato() {

    showMsgAguardo('Aguarde, buscando ...');

    var cddopcao = $('#cddopcao','#frmCab').val();
    var nmformul = '#frmEstornoPagamento';

    if (cddopcao == 'R') {
        nmformul = '#frmImpressaoEstorno';
    }

    var nrdconta = normalizaNumero($('#nrdconta',nmformul).val());
    
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/estorn/busca_contrato.php',
        data: {
            nrdconta: nrdconta,
            redirect: 'script_ajax'
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','N�o foi poss�vel concluir a requisi��o.','Alerta - Ayllos',"unblockBackground();");
        },
        success: function(response) {
			try {
                $('#divConteudo').html(response);
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

function carregaTelaFiltrarContrato(){
	
	var cCddopcao = $('#cddopcao','#frmCab');
	cCddopcao.desabilitaCampo();
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde...");
	
	// Carrega conte�do da op��o atrav�s de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/estorn/carrega_tela_estorno_pagamento.php",
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

function carregaLancamentosPagamentos(){
	
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, buscando os dados...");
	
	var cNrdconta = $('#nrdconta','#frmEstornoPagamento');
    var cNrctremp = $('#nrctremp','#frmEstornoPagamento');

    // Carrega dados parametro atrav�s de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/estorn/carrega_lancamentos_pagamentos.php',
        data:{nrdconta: normalizaNumero(cNrdconta.val()),
              nrctremp: normalizaNumero(cNrctremp.val()),
              redirect: 'script_ajax'
		},
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss�vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response){		
			if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
				try {
					$('#divLancamentosPagamento').html(response);				
					formataTelaLancamentos();				
					hideMsgAguardo();
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
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
			}
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
	
	var cNrdconta 		 = $('#nrdconta','#frmEstornoPagamento');
    var cNrctremp 		 = $('#nrctremp','#frmEstornoPagamento');
    var cQtdlacto 		 = $('#qtdlacto','#frmEstornoPagamento');
    var cDsjustificativa = $('#dsjustificativa','#frmEstornoPagamento');
	
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/estorn/manter_rotina.php", 
		data: {
			operacao: operacao,
		    nrdconta: normalizaNumero(cNrdconta.val()),			
			nrctremp: normalizaNumero(cNrctremp.val()),
			dsjustificativa: removeCaracteresInvalidos(cDsjustificativa.val()),
			qtdlacto: cQtdlacto.val(),
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

function carregaTelaConsultarEstornos(){
	
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, buscando os dados...");
	
	var cNrdconta = $('#nrdconta','#frmEstornoPagamento');
    var cNrctremp = $('#nrctremp','#frmEstornoPagamento');

    // Carrega dados parametro atrav�s de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/estorn/carrega_consulta_estorno.php',
        data:{nrdconta: normalizaNumero(cNrdconta.val()),
              nrctremp: normalizaNumero(cNrctremp.val()),
              redirect: 'script_ajax'
		},
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss�vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
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
					showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
				}
			} else {
				try {
                    eval(response);
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
			}
        }
    });
    return false;	
}

function carregaTelaConsultarDetalhesEstorno(){
	
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, buscando os dados...");
	
	$.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/estorn/tela_detalhes_estorno.php',
        data: {
			redirect: 'html_ajax'
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','N�o foi poss�vel concluir a requisi��o.','Alerta - Ayllos',"unblockBackground();");
        },
        success: function(response) {			
			$('#divRotina').html(response);
			buscaDetalhesEstorno();
        }
    });
    return false;
}

function buscaDetalhesEstorno(){
	
	var cNrdconta = $('#nrdconta','#frmEstornoPagamento');
    var cNrctremp = $('#nrctremp','#frmEstornoPagamento');	
	var cdestorno = 0;
	
	$('table > tbody > tr', 'div.divRegistros').each( function() {
		if ($(this).hasClass('corSelecao')){			
			cdestorno = $('#cdestorno', $(this)).val();
		}
	});
		
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/estorn/busca_detalhes_estorno.php',
        data: {
            nrdconta:  normalizaNumero(cNrdconta.val()),
            nrctremp:  normalizaNumero(cNrctremp.val()),
			cdestorno: cdestorno,
            redirect:  'script_ajax'
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','N�o foi poss�vel concluir a requisi��o.','Alerta - Ayllos',"unblockBackground();");
        },
        success: function(response) {
			try {
				hideMsgAguardo();
                $('#divConteudoOpcao').html(response);
				bloqueiaFundo( $('#divRotina') );
                exibeRotina($('#divRotina'));
				formataDetalhesEstorno();				
                return false;
            } catch(error) {
                hideMsgAguardo();
                showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
            }
        }
    });
    return false;
}

function geraImpressaoEstorno(){
    var cDtiniest = $('#dtiniest', '#frmImpressaoEstorno');
	var cDtfinest = $('#dtfinest', '#frmImpressaoEstorno');
    
	if (cDtiniest.val() == '') {
        showError('error','O campo data inicial n&atilde;o foi preenchida','Alerta - Ayllos','$("#dtiniest", "#frmImpressaoEstorno").focus();');
        return false;
    }
    if (cDtfinest.val() == '') {
        showError('error','O campo data final n&atilde;o foi preenchida','Alerta - Ayllos','$("#dtfinest", "#frmImpressaoEstorno").focus();');
        return false;
    }

	fechaRotina($('#divUsoGenerico'),$('#divRotina'));

	var action = UrlSite + 'telas/estorn/gera_impressao.php';
	$('#sidlogin','#frmImpressaoEstorno').val($('#sidlogin','#frmMenu').val());
	carregaImpressaoAyllos("frmImpressaoEstorno",action,"");
	return false;
}

function removeCaracteresInvalidos(str){
	str.replace(/\r\n/g,' ').replace("'","");
	return str.replace(/[^A-z0-9\s�����������������������������������������������������\!\@\$\%\*\(\)\-\_\=\+\[\]\{\}\?\;\:\.\,\/\>\<]/g,"");
}


function ajustaBotaoContinuar(){
	
	var cNrdconta = $('#nrdconta', '#frmEstornoPagamento');
	var cNrctremp = $('#nrctremp', '#frmEstornoPagamento');	
	
	if ( normalizaNumero( cNrdconta.val() ) == 0 ) {
		showError('error','O campo Conta/DV n&atilde;o foi preenchida','Alerta - Ayllos','$("#nrdconta", "#frmEstornoPagamento").focus();');
		return false;
	}
	
	if ( normalizaNumero( cNrctremp.val() ) == 0 ) {
		showError('error','O campo Contrato n&atilde;o foi preenchida','Alerta - Ayllos','$("#nrctremp", "#frmEstornoPagamento").focus();');
		return false;
	}
	
	if ( $('#cddopcao','#frmCab').val() == 'C') {
		carregaTelaConsultarEstornos();
	} else {
		carregaLancamentosPagamentos();
	}
	return false;
	
}
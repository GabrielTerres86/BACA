/*!
 * FONTE        : estorn.js
 * CRIAÇÃO      : James Prust Junior
 * DATA CRIAÇÃO : 14/09/2015
 * OBJETIVO     : Biblioteca de funções da tela ESTORN
 * --------------
 * ALTERAÇÕES   : 29/08/2018 - Tratar o estorno de pagamento da C/C em prejuízo
 *   			               PJ 450 - Diego Simas - AMcom
 *  - 15/09/2018 - Inclusão do Desconto de Títulos (Vitor S. Assanuma - GFT)
 *  - 29/10/2018 - Adicionado variavel cdtpprod e adicionada a pesquisa de bordeto na opção E (Cássia de Oliveitra - GFT)
 * --------------
 */
$(document).ready(function() {

	estadoInicial();

	highlightObjFocus( $('#frmCab') );

	$('fieldset > legend').css({
		'font-size': '11px',
		'color': '#777',
		'margin-left': '5px',
		'padding': '0px 2px'
	});
	$('fieldset').css({
		'clear': 'both',
		'border': '1px solid #777',
		'margin': '3px 0px',
		'padding': '10px 3px 5px 3px'
	});

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
	
	switch(cddopcao){
		
		// Estorno
		case 'E':
			var cNrdconta = $('#nrdconta', '#frmEstornoPagamento');
			var cNrctremp = $('#nrctremp', '#frmEstornoPagamento');		
			var cCdtpprod = $('#cdtpprod', '#frmEstornoPagamento');			
			
			var rNrdconta = $('label[for="nrdconta"]', '#frmEstornoPagamento');
			var rNrctremp = $('label[for="nrctremp"]', '#frmEstornoPagamento');		
			var rCdtpprod = $('label[for="cdtpprod"]', '#frmEstornoPagamento');	
			
			cNrdconta.addClass('conta pesquisa').css({'width':'80px'});
			cNrctremp.addClass('pesquisa').css({'width':'80px','text-align':'right'}).setMask('INTEGER','z.zzz.zzz.zzz','.','');
			cCdtpprod.addClass('rotulo-linha').css({width: "150px"});	
						
			rCdtpprod.addClass('rotulo').css({width: "50px"});	
			rNrdconta.addClass('rotulo-linha').css({width: "60px"});			
			rNrctremp.addClass('rotulo-linha').css({width: "80px"});			
			
			highlightObjFocus($('#frmEstornoPagamento'));
			cNrdconta.habilitaCampo();
			cNrctremp.habilitaCampo();			

			cCdtpprod.unbind('keypress').bind('keypress', function(e) {
				if ( divError.css('display') == 'block' ) { return false; }
				// Se é a tecla ENTER,
				if ( e.keyCode == 13 ) {
					cNrdconta.focus();
					return false;
				}
		    });
			
			cNrdconta.unbind('keypress').bind('keypress', function(e) {
				if ( divError.css('display') == 'block' ) { return false; }
				// Se é a tecla ENTER,
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
				// Se é a tecla ENTER,
				if ( e.keyCode == 13 ) {
					if (cCdtpprod.val() == 1){
						if ( normalizaNumero( cNrctremp.val() ) == 0 ) {
							mostraContrato();
						} else {
							carregaLancamentosPagamentos();
						}
					}else{
						if ( normalizaNumero( cNrctremp.val() ) == 0 ) {
							mostrarPesquisaBordero($('#frmEstornoPagamento #nrdconta').val(), $('#frmEstornoPagamento #nrctremp').val());
						} else {
							carregaLancamentosPagamentos();
						}
					}
					return false;
				}
			});

			cCdtpprod.unbind('change').bind('change',function() {
		    	//Limpa o campo
		    	cNrctremp.val('');

		    	//Verifica qual opção foi selecionada: 1 - Emprestimo PP | 2 - Desconto de Títulos
		    	if (cCdtpprod.val() == 1){ 
		    		rNrctremp.html("Contrato:")
		    	}else{
		    		rNrctremp.html("Border&ocirc;:")	
				}
			});
			trocaBotao('estadoInicial();', 'ajustaBotaoContinuar()', 'Continuar');
		break;
		
		// Estornar Pagamento de Prejuízo C/C
		case 'ECT':
		
			var cNrdconta = $('#nrdconta', '#frmEstornoPagamentoCT');

			var rNrdconta = $('label[for="nrdconta"]', '#frmEstornoPagamentoCT');

			cNrdconta.addClass('conta pesquisa').css({
				'width': '80px'
			});

			rNrdconta.addClass('rotulo').css({
				width: "60px"
			});

			highlightObjFocus($('#frmEstornoPagamentoCT'));
			cNrdconta.habilitaCampo();

			cNrdconta.unbind('keypress').bind('keypress', function (e) {
				if (divError.css('display') == 'block') {
					return false;
				}
				// Se é a tecla ENTER,
				if (e.keyCode == 13) {
					if (normalizaNumero(cNrdconta.val()) == 0) {
						mostraPesquisaAssociado('nrdconta', 'frmEstornoPagamentoCT');
						return false;
					}
					return false;
				}
			});

			trocaBotao('estadoInicial();', 'ajustaBotaoContinuarCT()', 'Continuar');
		break;
		
		// Estorno
		case 'C':
			var cNrdconta = $('#nrdconta', '#frmEstornoPagamento');
			var cNrctremp = $('#nrctremp', '#frmEstornoPagamento');			
			var cCdtpprod = $('#cdtpprod', '#frmEstornoPagamento');			
			
			var rNrdconta = $('label[for="nrdconta"]', '#frmEstornoPagamento');
			var rNrctremp = $('label[for="nrctremp"]', '#frmEstornoPagamento');
			var rCdtpprod = $('label[for="cdtpprod"]', '#frmEstornoPagamento');
			
			cNrdconta.addClass('conta pesquisa').css({'width':'80px'});
			cNrctremp.addClass('pesquisa').css({'width':'80px','text-align':'right'}).setMask('INTEGER','z.zzz.zzz.zzz','.','');
			cCdtpprod.addClass('rotulo-linha').css({width: "150px"});

			rCdtpprod.addClass('rotulo').css({width: "50px"});		
			rNrdconta.addClass('rotulo-linha').css({width: "60px"});			
			rNrctremp.addClass('rotulo-linha').css({width: "80px"});	
			
			highlightObjFocus($('#frmEstornoPagamento'));
			cNrdconta.habilitaCampo();
			cNrctremp.habilitaCampo();			
			
			cNrdconta.unbind('keypress').bind('keypress', function(e) {
				if ( divError.css('display') == 'block' ) { return false; }
				// Se é a tecla ENTER,
				if ( e.keyCode == 13 ) {
					if ( normalizaNumero( cNrdconta.val() ) == 0 ) {
						mostraPesquisaAssociado('nrdconta', 'frmEstornoPagamento');
						return false;
					}
					cNrctremp.focus();
					return false;
				}
		    });

		    cCdtpprod.unbind('keypress').bind('keypress', function(e) {
				if ( divError.css('display') == 'block' ) { return false; }
				// Se é a tecla ENTER,
				if ( e.keyCode == 13 ) {
					cNrdconta.focus();
					return false;
				}
		    });
			
			cNrctremp.unbind('keypress').bind('keypress', function(e) {
				if ( divError.css('display') == 'block' ) { return false; }		
				// Se é a tecla ENTER,
				if ( e.keyCode == 13 ) {
					if (cCdtpprod.val() == 1){
						if ( normalizaNumero( cNrctremp.val() ) == 0 ) {
							mostraContrato();
						} else {
							carregaTelaConsultarEstornos();
						}
					}else{
						mostrarPesquisaBordero($('#frmEstornoPagamento #nrdconta').val(), $('#frmEstornoPagamento #nrctremp').val());
					}
					return false;
				}
			});

		    cCdtpprod.unbind('change').bind('change',function() {
		    	//Limpa o campo
		    	cNrctremp.val('');

		    	//Verifica qual opção foi selecionada: 1 - Emprestimo PP | 2 - Desconto de Títulos
		    	if (cCdtpprod.val() == 1){ 
		    		rNrctremp.html("Contrato:")
		    	}else{
		    		rNrctremp.html("Border&ocirc;:")
		    	}
		    });

			// trocaBotao('estadoInicial()');
			trocaBotao('estadoInicial();','ajustaBotaoContinuar()','Continuar');	
			break;

		// CONSULTAR ESTORNO DE PAGAMENTO DE PREJUIZO DE C/C
		case 'CCT':
			var cNrdconta = $('#nrdconta', '#frmEstornoPagamentoCT');
			
			var rNrdconta = $('label[for="nrdconta"]', '#frmEstornoPagamentoCT');
			
			cNrdconta.addClass('conta pesquisa').css({
				'width': '80px'
			});
			
			rNrdconta.addClass('rotulo').css({
				width: "60px"
			});
			
			highlightObjFocus($('#frmEstornoPagamentoCT'));
			cNrdconta.habilitaCampo();
			
			cNrdconta.unbind('keypress').bind('keypress', function (e) {
				if (divError.css('display') == 'block') {
					return false;
				}
				// Se é a tecla ENTER,
				if (e.keyCode == 13) {
					if (normalizaNumero(cNrdconta.val()) == 0) {
						mostraPesquisaAssociado('nrdconta', 'frmEstornoPagamentoCT');
					} else {
						carregaTelaConsultarEstornosCT();
					}					
					return false;
				}
			});

			trocaBotao('estadoInicial();', 'ajustaBotaoContinuarCT()', 'Continuar');
		break;
		
		// Relatorio
		case 'R':
			var cCdtpprod = $('#cdtpprod', '#frmImpressaoEstorno');
			var cNrdconta = $('#nrdconta', '#frmImpressaoEstorno');
			var cNrctremp = $('#nrctremp', '#frmImpressaoEstorno');			
			var cDtiniest = $('#dtiniest', '#frmImpressaoEstorno');			
			var cDtfinest = $('#dtfinest', '#frmImpressaoEstorno');			
			var cCdagenci = $('#cdagenci', '#frmImpressaoEstorno');			
			
			var rCdtpprod = $('label[for="cdtpprod"]', '#frmImpressaoEstorno');
			var rNrdconta = $('label[for="nrdconta"]', '#frmImpressaoEstorno');
			var rNrctremp = $('label[for="nrctremp"]', '#frmImpressaoEstorno');			
			var rDtiniest = $('label[for="dtiniest"]', '#frmImpressaoEstorno');			
			var rDtfinest = $('label[for="dtfinest"]', '#frmImpressaoEstorno');			
			var rCdagenci = $('label[for="cdagenci"]', '#frmImpressaoEstorno');			
			
			cCdtpprod.addClass('campo').css({'width':'150px'});
			cNrdconta.addClass('conta pesquisa').css({'width':'80px'});
			cNrctremp.addClass('pesquisa').css({'width':'80px','text-align':'right'}).setMask('INTEGER','z.zzz.zzz.zzz','.','');
			cDtiniest.addClass('data').css({'width':'80px'});
			cDtfinest.addClass('data').css({'width':'80px'});
			cCdagenci.addClass('campo').css({'width':'80px'});
			
			rCdtpprod.addClass('rotulo').css({width: "70px"});
			rNrdconta.addClass('rotulo-linha').css({width: "70px"});			
			rNrctremp.addClass('rotulo-linha').css({width: "70px"});			
			rDtiniest.addClass('rotulo').css({'width':'70px'});				
			rDtfinest.addClass('rotulo-linha').css({'width':'140px'});				
			rCdagenci.addClass('rotulo-linha').css({'width':'87px'});				
			
			highlightObjFocus($('#frmImpressaoEstorno'));
			cCdtpprod.habilitaCampo();
			cNrdconta.habilitaCampo();
			cNrctremp.habilitaCampo();
			cDtiniest.habilitaCampo();
			cDtfinest.habilitaCampo();
			cCdagenci.habilitaCampo();

			cCdtpprod.unbind('keypress').bind('keypress', function(e) {
				if ( divError.css('display') == 'block' ) { return false; }
				// Se é a tecla ENTER,
				if ( e.keyCode == 13 ) {
					cNrdconta.focus();
					return false;
				}
		    });

		    cNrdconta.unbind('keypress').bind('keypress', function(e) {
				if ( divError.css('display') == 'block' ) { return false; }
				// Se é a tecla ENTER,
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
				if (divError.css('display') == 'block' ) { return false; }
				// Se é a tecla ENTER,
				if ( e.keyCode == 13 ) {
					if (cCdtpprod.val() == 1){
						if ( normalizaNumero( cNrctremp.val() ) == 0 ) {
							mostraContrato();
						} else {
							cDtiniest.focus();
						}
					}else{
						if ( normalizaNumero( cNrctremp.val() ) == 0 ) {
							mostrarPesquisaBordero($('#frmImpressaoEstorno #nrdconta').val(), $('#frmImpressaoEstorno #nrctremp').val());
						} else {
							cDtiniest.focus();
						}
					}
					return false;
				}
			});
			
			cDtiniest.unbind('keypress').bind('keypress', function(e) {
				if (divError.css('display') == 'block' ) { return false; }
				// Se é a tecla ENTER,
				if (e.keyCode == 13){
					cDtfinest.focus();
					return false;
				}
			});
			
			cDtfinest.unbind('keypress').bind('keypress', function(e) {
				if (divError.css('display') == 'block' ) { return false; }
				// Se é a tecla ENTER,
				if (e.keyCode == 13){
					cCdagenci.focus();
					return false;
				}
			});
			
			cCdagenci.unbind('keypress').bind('keypress', function(e) {
				if (divError.css('display') == 'block' ) { return false; }
				// Se é a tecla ENTER,
				if (e.keyCode == 13){
				//	cCdagenci.focus();
				    geraImpressaoEstorno();
					return false;
				}
			});

			cCdtpprod.unbind('change').bind('change',function() {
		    	//Limpa o campo
		    	cNrctremp.val('');

		    	//Verifica qual opção foi selecionada: 1 - Emprestimo PP | 2 - Desconto de Títulos
		    	if (cCdtpprod.val() == 1){ 
		    		rNrctremp.html("Contrato:")
		    	}else{
		    		rNrctremp.html("Border&ocirc;:")
		    	}
		    });
			
			trocaBotao('estadoInicial();','geraImpressaoEstorno()','Imprimir');			
		break;

		// Relatorio
		case 'RCT':
			var cNrdconta = $('#nrdconta', '#frmImpressaoEstornoCT');
			var cDtiniest = $('#dtiniest', '#frmImpressaoEstornoCT');
			var cDtfinest = $('#dtfinest', '#frmImpressaoEstornoCT');
			
			var rNrdconta = $('label[for="nrdconta"]', '#frmImpressaoEstornoCT');
			var rDtiniest = $('label[for="dtiniest"]', '#frmImpressaoEstornoCT');
			var rDtfinest = $('label[for="dtfinest"]', '#frmImpressaoEstornoCT');
			
			cNrdconta.addClass('conta pesquisa').css({
				'width': '80px'
			});

			cDtiniest.addClass('data').css({
				'width': '80px'
			});

			cDtfinest.addClass('data').css({
				'width': '80px'
			});

			rNrdconta.addClass('rotulo').css({
				width: "80px"
			});

			rDtiniest.addClass('rotulo').css({
				'width': '80px'
			});

			rDtfinest.addClass('rotulo-linha').css({
				'width': '97px'
			});

			highlightObjFocus($('#frmImpressaoEstornoCT'));
			cNrdconta.habilitaCampo();
			cDtiniest.habilitaCampo();
			cDtfinest.habilitaCampo();
			
			cNrdconta.unbind('keypress').bind('keypress', function (e) {
				if (divError.css('display') == 'block') {
					return false;
				}
				// Se é a tecla ENTER,
				if (e.keyCode == 13) {
					cDtiniest.focus();
					return false;
				}
			});

			cDtiniest.unbind('keypress').bind('keypress', function (e) {
				if (divError.css('display') == 'block') {
					return false;
				}
				// Se é a tecla ENTER,
				if (e.keyCode == 13) {
					cDtfinest.focus();
					return false;
				}
			});

			cDtfinest.unbind('keypress').bind('keypress', function (e) {
				if (divError.css('display') == 'block') {
					return false;
				}
				// Se é a tecla ENTER,
				if (e.keyCode == 13) {
					geraImpressaoEstorno();
					return false;
				}
			});

			trocaBotao('estadoInicial();', 'geraImpressaoEstornoCT()', 'Imprimir');
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
			$('#cdtpprod','#frmEstornoPagamento').focus();
		break;
		
		case 'R':
			$('#cdtpprod','#frmImpressaoEstorno').focus();
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

	if (cddopcao == 'ECT') {
		nmformul = 'frmEstornoPagamentoCT';
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
			if ($('#cdtpprod','#frmEstornoPagamento').val() == 1){
				mostraContrato();
			}else{
				mostrarPesquisaBordero($('#frmEstornoPagamento #nrdconta').val(), $('#frmEstornoPagamento #nrctremp').val());
			}
		});
	}	

	return false;
}

// contrato
function mostraContrato() {
	
	showMsgAguardo('Aguarde, buscando ...');

	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/estorn/contrato.php', 
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

	tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);
	return false;
}

function formataGridEstornosCT() {

	var divRegistro = $('#divEstornosCT');
	var tabela = $('table', divRegistro);
	var linha = $('table > tbody > tr', divRegistro);

	divRegistro.css({
		'height': '120px'
	});

	var ordemInicial = new Array();
	ordemInicial = [
		[0, 0]
	];

	var arrayLargura = new Array();
	arrayLargura[0] = '70px';
	arrayLargura[1] = '80px';
	arrayLargura[2] = '70px';
	arrayLargura[3] = '70px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'center';
	arrayAlinha[3] = 'center';
	arrayAlinha[4] = 'center';

    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);
    return false;	
}	

function formataTelaLancamentos() {

	var cTotalest = $('#totalest','#frmEstornoPagamento');
	var cDsjustif = $('#dsjustificativa','#frmEstornoPagamento');
	var cInprejuz = $('#inprejuz','#divLancamentosPagamento');
    var cCdtpprod = $('#cdtpprod','#frmEstornoPagamento');

	var Ldsprejuz = $('label[for="dsprejuz"]','#divLancamentosPagamento');
	var rTotalest = $('label[for="totalest"]', '#frmEstornoPagamento');
	var rDsjustif = $('label[for="dsjustificativa"]', '#frmEstornoPagamento');

    var divRegistro = $('#divLancamentoParcela');
    var tabela      = $('table', divRegistro );
    var linha       = $('table > tbody > tr', divRegistro );

	Ldsprejuz.addClass('rotulo').css({'width':'590px','text-align':'center'});
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
	var arrayAlinha = new Array();
    if (cInprejuz.val() == 0 || cCdtpprod.val() == 1){
      arrayLargura[0] = '60px';
      arrayLargura[1] = '80px';
      arrayLargura[2] = '110px';
      arrayLargura[3] = '80px';
      arrayLargura[4] = '60px';

      arrayAlinha[0] = 'right';
	  arrayAlinha[1] = 'center';
	  arrayAlinha[2] = 'center';
	  arrayAlinha[3] = 'right';
	  arrayAlinha[4] = 'right';
	  arrayAlinha[5] = 'right';
    }else{
      arrayLargura[0] = '100px';
      arrayLargura[1] = '110px';
      arrayLargura[2] = '110px';
      arrayLargura[3] = '100px';

      arrayAlinha[0] = 'center';
	  arrayAlinha[1] = 'center';
	  arrayAlinha[2] = 'center';
	  arrayAlinha[3] = 'right';
	  arrayAlinha[4] = 'right';

  	  trocaBotao('estadoInicial();','efetuarEstornoPrj()','Estornar');	
    }
 
    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);
    return false;
}

function formataTelaLancamentosCT() {
	var cTotalest = $('#totalest', '#frmEstornoPagamentoCT');
	var cDsjustif = $('#dsjustificativa', '#frmEstornoPagamentoCT');

	var rTotalest = $('label[for="totalest"]', '#frmEstornoPagamentoCT');
	var rDsjustif = $('label[for="dsjustificativa"]', '#frmEstornoPagamentoCT');

	var divRegistro = $('#divLancamentoParcelaCT');
	var tabela = $('table', divRegistro);
	var linha = $('table > tbody > tr', divRegistro);

	rDsjustif.addClass('rotulo').css({
		width: "75px"
	});
	rTotalest.addClass('rotulo-linha').css({
		'width': '80px',
		'margin-left': '310px'
	});

	cDsjustif.addClass('alphanum').css({
		'width': '562px',
		'height': '80px',
		'float': 'left',
		'margin': '3px 0px 3px 3px',
		'padding-right': '1px'
	});
	cTotalest.addClass('campo').css({
		'width': '88px',
		'padding-top': '3px',
		'padding-bottom': '3px',
		'margin-left': '09px'
	});

	cDsjustif.habilitaCampo();
	cTotalest.desabilitaCampo();

	// FORMATA O GRID DOS LANCAMENTOS DE PAGAMENTO
	divRegistro.css({
		'height': '120px'
	});

	var ordemInicial = new Array();
	ordemInicial = [
		[0, 0]
	];

	var arrayLargura = new Array();
	arrayLargura[0] = '14px';
	arrayLargura[1] = '150px';
	

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'center';
	

	tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);

	return false;
}

function formataEstornarPrejuizoTit(){
	var divRegistro = $('#divLancamentoTitulos');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

	var cDsjustif   = $('#dsjustif','#frmEstPrjJust');

	// FORMATA O GRID DOS LANCAMENTOS DE PAGAMENTO
	divRegistro.css({'height':'120px'});

	cDsjustif.addClass('alphanum').css({'width':'450px','height':'80px','float':'left','margin':'3px 0px 3px 3px','padding-right':'1px'});	

	var ordemInicial = new Array();
    ordemInicial = [[0,0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '20px';
    arrayLargura[1] = '100px';
    arrayLargura[2] = '110px';
    arrayLargura[3] = '100px';

	var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'center';
	arrayAlinha[3] = 'center';
	arrayAlinha[4] = 'center';
 
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
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
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
	
	// Carrega conteúdo da opção através de ajax
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
    var cCdtpprod = $('#cdtpprod','#frmEstornoPagamento');

    // Carrega dados parametro através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/estorn/carrega_lancamentos_pagamentos.php',
        data:{nrdconta: normalizaNumero(cNrdconta.val()),
              nrctremp: normalizaNumero(cNrctremp.val()),
              cdtpprod: normalizaNumero(cCdtpprod.val()),
              redirect: 'script_ajax'
		},
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
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

function carregaLancamentosPagamentosCT(cNrdconta) {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, buscando os dados...");

	// Carrega dados parametro através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/estorn/carrega_lancamentos_pagamentos_ct.php',
		data: {
			nrdconta: cNrdconta,
			redirect: 'script_ajax'
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
		},
		success: function (response) {
			if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
				try {
					$('#divLancamentosPagamentoCT').html(response);
					formataTelaLancamentosCT();
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

function manterRotina(operacao, inprejuz){
    if (inprejuz == undefined || !inprejuz) {
        inprejuz = 0;
    }
	hideMsgAguardo();
	
    var cCdtpprod = $('#cdtpprod','#frmEstornoPagamento').val();
	var cNrdconta = $('#nrdconta', '#frmEstornoPagamento').val();
	var cNrctremp = $('#nrctremp', '#frmEstornoPagamento').val();
	var cTotalest = 0;
	var cQtdlacto = $('#qtdlacto', '#frmEstornoPagamento').val();
	var cDsjustificativa = $('#dsjustificativa', '#frmEstornoPagamento').val();

	switch (operacao){
		case 'VALIDA_DADOS':
			showMsgAguardo("Aguarde, validando os dados...");
		break;
		
		case 'EFETUA_ESTORNO':
			showMsgAguardo("Aguarde, estornando os lan&ccedil;amentos...");
		break;	

		case 'ESTORNO_CT':
			var cNrdconta = $('#nrdconta', '#frmEstornoPagamentoCT').val();
			var cTotalest = $('#totalest', '#frmEstornoPagamentoCT').val();
			var cDsjustificativa = $('#dsjustificativa', '#frmEstornoPagamentoCT').val();	
			var cQtdlacto = 0;
			var cNrctremp = 0;
			showMsgAguardo("Aguarde, estornando o pagamento de preju&iacute;zo...");		
		break;
		case 'EFETUA_ESTORNO_PREJUIZO':
			showMsgAguardo("Aguarde, estornando o pagamento de preju&iacute;zo...");
		break;
	}

	$.ajax({
		type: "POST",
		url: UrlSite + "telas/estorn/manter_rotina.php", 
		data: {
			operacao: operacao,
			nrdconta: normalizaNumero(cNrdconta),
			nrctremp: normalizaNumero(cNrctremp),
			dsjustificativa: removeCaracteresInvalidos(cDsjustificativa),
			qtdlacto: normalizaNumero(cQtdlacto),
			totalest: normalizaNumero(cTotalest),
			cdtpprod: cCdtpprod,
			inprejuz: inprejuz,
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
    var cCdtpprod = $('#cdtpprod','#frmEstornoPagamento');

    // Carrega dados parametro através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/estorn/carrega_consulta_estorno.php',
		data: {
			nrdconta: normalizaNumero(cNrdconta.val()),
              nrctremp: normalizaNumero(cNrctremp.val()),
              cdtpprod: cCdtpprod.val(),
              redirect: 'script_ajax'
		},
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
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

function carregaTelaConsultarEstornosCT() {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, buscando os dados...");

	var cNrdconta = $('#nrdconta', '#frmEstornoPagamentoCT');
	
	// Carrega dados parametro através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/estorn/carrega_consulta_estorno_ct.php',
		data: {
			nrdconta: normalizaNumero(cNrdconta.val()),
			redirect: 'script_ajax'
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
		},
		success: function (response) {
			if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
				try {
					$('#divLancamentosPagamentoCT').html(response);
					formataGridEstornosCT();
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
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
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
    var cCdtpprod = $('#cdtpprod','#frmEstornoPagamento');	
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
            cdtpprod:  cCdtpprod.val(),
            redirect:  'script_ajax'
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
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
	var cCdtpprod = $('#cdtpprod', '#frmImpressaoEstorno');
    var cDtiniest = $('#dtiniest', '#frmImpressaoEstorno');
	var cDtfinest = $('#dtfinest', '#frmImpressaoEstorno');
    
	if (cDtiniest.val() == '') {
        showError('error','O campo data inicial n&atilde;o foi preenchido','Alerta - Ayllos','$("#dtiniest", "#frmImpressaoEstorno").focus();');
        return false;
    }
    if (cDtfinest.val() == '') {
        showError('error','O campo data final n&atilde;o foi preenchido','Alerta - Ayllos','$("#dtfinest", "#frmImpressaoEstorno").focus();');
        return false;
    }

	fechaRotina($('#divUsoGenerico'),$('#divRotina'));

	var action = UrlSite + 'telas/estorn/gera_impressao.php';
	$('#sidlogin','#frmImpressaoEstorno').val($('#sidlogin','#frmMenu').val());
	carregaImpressaoAyllos("frmImpressaoEstorno",action,"");
	return false;
}

function geraImpressaoEstornoCT() {
	
	var cNrdconta = $('#nrdconta', '#frmImpressaoEstornoCT');
	var cDtiniest = $('#dtiniest', '#frmImpressaoEstornoCT');
	var cDtfinest = $('#dtfinest', '#frmImpressaoEstornoCT');

	if (cNrdconta.val() == '') {
		showError('error', 'O campo n&uacute;mero da conta n&atilde;o foi preenchido', 'Alerta - Ayllos', '$("#nrdconta", "#frmImpressaoEstornoCT").focus();');
		return false;
	}

	if (cDtiniest.val() == '') {
		showError('error', 'O campo data inicial n&atilde;o foi preenchido', 'Alerta - Ayllos', '$("#dtiniest", "#frmImpressaoEstornoCT").focus();');
		return false;
	}

	if (cDtfinest.val() == '') {
		showError('error', 'O campo data final n&atilde;o foi preenchido', 'Alerta - Ayllos', '$("#dtfinest", "#frmImpressaoEstornoCT").focus();');
		return false;
	}

	fechaRotina($('#divUsoGenerico'), $('#divRotina'));

	var action = UrlSite + 'telas/estorn/gera_impressao_ct.php';
	$('#sidlogin', '#frmImpressaoEstornoCT').val($('#sidlogin', '#frmMenu').val());
	carregaImpressaoAyllos("frmImpressaoEstornoCT", action, "");
	
	return false;
}

function removeCaracteresInvalidos(str){
	str.replace(/\r\n/g,' ').replace("'","");
	return str.replace(/[^A-z0-9\sÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëÇçÌÍÎÏìíîïÙÚÛÜùúûüÿÑñ\!\@\$\%\*\(\)\-\_\=\+\[\]\{\}\?\;\:\.\,\/\>\<]/g,"");
}


function ajustaBotaoContinuar(){
	
	var cNrdconta = $('#nrdconta', '#frmEstornoPagamento');
	var cNrctremp = $('#nrctremp', '#frmEstornoPagamento');	
	var cCdtpprod = $('#cdtpprod', '#frmEstornoPagamento');	
	
	if ( normalizaNumero( cNrdconta.val() ) == 0 ) {
		showError('error','O campo Conta/DV n&atilde;o foi preenchido','Alerta - Ayllos','$("#nrdconta", "#frmEstornoPagamento").focus();');
		return false;
	}
	
	if ( normalizaNumero( cNrctremp.val() ) == 0 ) {
		if (cCdtpprod.val() == 1){
			showError('error','O campo Contrato n&atilde;o foi preenchido','Alerta - Ayllos','$("#nrctremp", "#frmEstornoPagamento").focus();');
		}else if (cCdtpprod.val() == 2){
			showError('error','O campo Border&ocirc; n&atilde;o foi preenchido','Alerta - Ayllos','$("#nrctremp", "#frmEstornoPagamento").focus();');
		}
		return false;
	}
	
	if ( $('#cddopcao','#frmCab').val() == 'C') {
		carregaTelaConsultarEstornos();
	} else {
		carregaLancamentosPagamentos();
	}
	return false;

}

function ajustaBotaoContinuarCT() {

	if ($('#cddopcao', '#frmCab').val() == 'ECT') {
		var cNrdconta = normalizaNumero($('#nrdconta', '#frmEstornoPagamentoCT').val());

		if (cNrdconta == 0) {
			showError('error', 'O campo Conta/DV n&atilde;o foi preenchido', 'Alerta - Ayllos', '$("#nrdconta", "#frmEstornoPagamentoCT").focus();');
			return false;
		}

		carregaLancamentosPagamentosCT(cNrdconta);
	} 

	if ($('#cddopcao', '#frmCab').val() == 'CCT') {
		carregaTelaConsultarEstornosCT();
	}

	return false;
	
}

// Função para abrir a pesquisa de borderos
function mostrarPesquisaBordero(nrdconta, nrctremp){
	var normNrconta = normalizaNumero(nrdconta) > 0 ? normalizaNumero(nrdconta) : '';
	var nrBorder    = normalizaNumero(nrctremp) > 0 ? normalizaNumero(nrctremp) : '';

	//Definição dos filtros
	var filtros	= "Conta;nrdconta;100px;S;"+normNrconta+";S;nrdconta|Nr. Bordero;nrctremp;100px;S;"+nrBorder+";S;nrctremp|Dt Venc;dtlibbdt;;N;;N;dtlibbdt|Emprestado;vltottit;;N;;N;vltottit|Qt. Titulos;qttottit;;N;;N;qttottit";
	//Campos que serão exibidos na tela
	var colunas = 'Numero da Conta;nrdconta;0%;center;;N|Bordero;nrborder;20%;center|Dt.Lib;dtlibbdt;20%;center|Emprestado;vltottit;30%;center|Qt. Titulos;qttottit;30%;center';
	//Exibir a pesquisa
	mostraPesquisa("DSCT0003", "BUSCAR_BORDEROS_LIBERADOS", "Borderos","100",filtros,colunas, null, null, 'frmEstornoPagamento');
}

function efetuarEstornoPrj(){
	manterRotina("VALIDA_DADOS", 1);
}
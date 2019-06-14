/*!
 * FONTE        : extprr.js
 * CRIAÇÃO      : Rogerius Militão (DB1) 
 * DATA CRIAÇÃO : 28/07/2011
 * OBJETIVO     : Biblioteca de funções da tela EXTPRR
 * --------------
 * ALTERAÇÕES   : 20/09/2012 - Alterado estrutura de botoes para novo padrao de layout 
 * 							   e ajustado layout conforme nessecidade (Lucas R.)
 *
 *				  05/06/2013 - Incluir rVlbloque, cVlbloque	para controle de layout
 *							   (Lucas R.)
 *						 
 *                27/11/2017 - Inclusao do valor de bloqueio em garantia.
 *                             PRJ404 - Garantia Empr.(Odirlei-AMcom)  
 */

// Definição de algumas variáveis globais 
var arrayExtppr		= new Array();
var qtdeExtppr		= '0';

//Formulários
var frmCab   		= 'frmCab';
var frmDados  		= 'frmExtppr';
var tabDados		= 'tabExtppr';

//Labels/Campos do cabeçalho
var rNrdconta, rNraplica, rDtiniper, rDtfimper, 
	cNrdconta, cNraplica, cDtiniper, cDtfimper, cTodosCabecalho, btnOK;

var rNmprimtl, rDtvctopp, rDddebito, rVlrdcapp, rVlbloque, rVlblqpou,
	cNmprimtl, cDtvctopp, cDddebito, cVlrdcapp, cVlbloque, cVlblqpou, cTodosDados;


$(document).ready(function() {
	estadoInicial();
	cNrdconta.focus();
});


// seletores
function estadoInicial() {

	
	$('#divTela').fadeTo(0,0.1);
		
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	
	
	arrayExtppr = new Array();
	trocaBotao('Prosseguir');
	qtdeExtppr		= '0';
		 	
	$('#'+tabDados).css({'display':'none'}).html('');
	$('#divPesquisaRodape').css({'display':'none'}).html('');
	
	hideMsgAguardo();		
	atualizaSeletor();
	formataCabecalho();
	formataDados();

	cTodosCabecalho.limpaFormulario().removeClass('campoErro');	
	cTodosDados.limpaFormulario().removeClass('campoErro');	

	removeOpacidade('divTela');
}

function estadoExtrato() {

	arrayExtppr = new Array();
	trocaBotao('prosseguir');
	
	$('#'+tabDados).css({'display':'none'}).html('');
	$('#divPesquisaRodape').css({'display':'none'}).html('');

	cTodosDados.limpaFormulario().removeClass('campoErro');	
	
	cNraplica.habilitaCampo().focus();
	return false;

}

function atualizaSeletor(){

	// cabecalho
	rNrdconta			= $('label[for="nrdconta"]','#'+frmCab); 
	rNraplica			= $('label[for="nraplica"]','#'+frmCab);
	rDtiniper			= $('label[for="dtiniper"]','#'+frmCab);
	rDtfimper			= $('label[for="dtfimper"]','#'+frmCab);
	
	cNrdconta			= $('#nrdconta','#'+frmCab); 
	cNraplica			= $('#nraplica', '#'+frmCab);			
	cDtiniper			= $('#dtiniper', '#'+frmCab);
	cDtfimper			= $('#dtfimper', '#'+frmCab);	
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	btnOK				= $('#btnOK','#'+frmCab);

	// contrato
	rNmprimtl	        = $('label[for="nmprimtl"]','#'+frmDados);        
	rDtvctopp			= $('label[for="dtvctopp"]','#'+frmDados);
	rDddebito			= $('label[for="dddebito"]','#'+frmDados);
	rVlbloque			= $('label[for="vlbloque"]','#'+frmDados);
	rVlrdcapp			= $('label[for="vlrdcapp"]','#'+frmDados);
    rVlblqpou			= $('label[for="vlblqpou"]','#'+frmDados);
    

	cNmprimtl			= $('#nmprimtl','#'+frmDados); 
	cDtvctopp			= $('#dtvctopp','#'+frmDados);
	cDddebito			= $('#dddebito','#'+frmDados);
	cVlbloque    		= $('#vlbloque','#'+frmDados);
	cVlrdcapp			= $('#vlrdcapp','#'+frmDados);
    cVlblqpou           = $('#vlblqpou','#'+frmDados);
	cTodosDados			= $('input[type="text"],select','#'+frmDados);

	return false;
}


// controle
function controlaOperacao() {
	
	var nrdconta = normalizaNumero( cNrdconta.val() );
	
	var mensagem = 'Aguarde, buscando dados ...';
	showMsgAguardo( mensagem );	
	
	// Carrega dados da conta através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/extppr/principal.php', 
		data    : 
				{ 
					nrdconta	: nrdconta, 
					redirect	: 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) {
					try {
						eval(response);
						return false;
					} catch(error) {
						hideMsgAguardo();
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
					}
				}
	});

	return false;	
}

function manterRotina( operacao ) {
		
	hideMsgAguardo();		
	
	var mensagem = 'Aguarde, buscando...';
	var nrdconta = normalizaNumero( cNrdconta.val() );
	var nraplica = normalizaNumero( cNraplica.val() );
	var dtiniper = cDtiniper.val();	
	var dtfimper = cDtfimper.val();	
	
	$('#divRotina').html('');
	
	showMsgAguardo( mensagem );	
	
	$.ajax({		
			type  : 'POST',
			url   : UrlSite + 'telas/extppr/manter_rotina.php', 		
			data: {
				operacao	: operacao,
				nrdconta	: nrdconta,
				nraplica	: nraplica,
				dtiniper	: dtiniper,
				dtfimper	: dtfimper,
				qtdeExtppr	: qtdeExtppr,
				redirect	: 'script_ajax'
			}, 
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
			},
			success: function(response) {
				try {
					eval(response);
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				}
			}
		});

	return false;	
	                     
}       	

function controlaPesquisas() {

	/*---------------------*/
	/*  CONTROLE CONTA/DV  */
	/*---------------------*/
	var linkConta = $('a:eq(0)','#'+ frmCab );

	if ( linkConta.prev().hasClass('campoTelaSemBorda') ) {		
		linkConta.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {
		linkConta.css('cursor','pointer').unbind('click').bind('click', function() {			
			mostraPesquisaAssociado('nrdconta', frmCab );
		});
	}

	/*--------------------*/
	/*  CONTROLE CONTRATO  */
	/*--------------------*/
	var linkContrato = $('a:eq(2)','#'+frmCab);
	
	if ( linkContrato.prev().hasClass('campoTelaSemBorda') ) {		
		linkContrato.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {
		linkContrato.css('cursor','pointer').unbind('click').bind('click', function() {			
			mostraContrato();
		});
	}
	
	return false;
}


// formata
function formataCabecalho() {
	
	var nomeForm    = 'frmCab';
	highlightObjFocus( $('#'+nomeForm) );
	
	var nomeForm    = 'frmExtppr';
	highlightObjFocus( $('#'+nomeForm) );	
	
	rNrdconta.addClass('rotulo').css({'width':'38px'});
	rNraplica.addClass('rotulo-linha').css({'width':'54px'});
	rDtiniper.addClass('rotulo-linha').css({'width':'65px'});
	rDtfimper.addClass('rotulo-linha').css({'width':'58px'});

	cNrdconta.addClass('conta pesquisa').css({'width':'75px'})
	cNraplica.addClass('contrato pesquisa').css({'width':'65px'});	
	cDtiniper.addClass('data').css({'width':'72px'});	
	cDtfimper.addClass('data').css({'width':'72px'});	

	if ( $.browser.msie ) {
		rNraplica.css({'width':'57px'});
		rDtiniper.css({'width':'70px'});
		rDtfimper.css({'width':'65px'});
	}	
	
	cTodosCabecalho.desabilitaCampo();	
	cNrdconta.habilitaCampo();
	cNrdconta.focus();
	
	// Se clicar no botao OK
	btnOK.unbind('click').bind('click', function() { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( cNrdconta.hasClass('campoTelaSemBorda')  ) { return false; }		
		
		// Armazena o número da conta na variável global
		var nrdconta = normalizaNumero( cNrdconta.val() );
		
		// Verifica se o número da conta é vazio
		if ( nrdconta == '' ) { return false; }
	
		// Verifica se a conta é válida
		if ( !validaNroConta(nrdconta) ) { 
			showError('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'nrdconta\',\''+ frmCab +'\');'); 
			return false; 
		}

		cTodosCabecalho.removeClass('campoErro');	
		
		// Se chegou até aqui, a conta é diferente do vazio e é válida, então realizar a operação desejada
		controlaOperacao();
		return false;
			
	});	

	cNrdconta.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			btnOK.click();
			return false;
		} else if ( e.keyCode == 118 ) {
			mostraPesquisaAssociado('nrdconta', frmCab );
			return false;
		}
	});	

	cNraplica.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( $('#divRotina').css('visibility') == 'visible' ) { 
			if ( e.keyCode == 13 ) { selecionaContrato(); return false; }
		}		

		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			var nraplica = normalizaNumero( $(this).val() );

			if ( nraplica == 0 ) {
				mostraContrato();
			} else {
				$(this).desabilitaCampo();
				manterRotina('BP');
			}
			return false;
		} 
		
	});	
		
	cDtiniper.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9) {	
			cDtfimper.focus();
			return false;
		}
	});
	
	cDtfimper.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9) {	
			btnContinuar();
			return false;
		}
	});
	
	
	layoutPadrao();
	controlaPesquisas();
	return false;	
}

function formataDados() {

	rNmprimtl.addClass('rotulo').css({'width':'100px'});
	rDtvctopp.addClass('rotulo').css({'width':'100px'});
	rVlbloque.addClass('rotulo').css({'width':'100px'});
	rVlblqpou.addClass('rotulo-linha').css({'width':'235px'});
	rDddebito.addClass('rotulo-linha').css({'width':'284px'});
    rVlrdcapp.addClass('rotulo').css({'width':'100px'});
    

	cNmprimtl.addClass('alphanum').css({'width':'482px'}).attr('maxlength','48');
	cDtvctopp.addClass('data').css({'width':'72px'});
	cDddebito.addClass('inteiro').css({'width':'65px'}).attr('maxlength','2');
	cVlbloque.addClass('moeda').css({'width':'120px'});
	cVlrdcapp.addClass('moeda').css({'width':'120px'});	
    cVlblqpou.addClass('moeda').css({'width':'120px'});

	if ( $.browser.msie ) {
		rDddebito.css({'width':'287px'});
		rVlrdcapp.css({'width':'239px'});
	}
	
	cTodosDados.desabilitaCampo();

	layoutPadrao();
	controlaPesquisas();
	return false;
}

function controlaLayout() {
	
	trocaBotao('Concluir');

	cNrdconta.desabilitaCampo();	
	
	cDtfimper.habilitaCampo();
	
	hideMsgAguardo();
	layoutPadrao();
	controlaPesquisas();
	cDtiniper.habilitaCampo().focus();
	return false;
	
}

// tabela
function montarTabela( nriniseq, nrregist ) {

	hideMsgAguardo();		
	var mensagem = 'Aguarde, buscando...';
	showMsgAguardo( mensagem );	
	
	$('#'+tabDados).html(
	'<div class="divRegistros">	'+
		'<table>'+
			'<thead>'+
				'<tr>'+
					'<th>Data</th>'+
					'<th>Pac</th>'+
					'<th>Bcx</th>'+
					'<th>Lote</th>'+
					'<th>Historico</th>'+
					'<th>Documento</th>'+
					'<th></th>'+
					'<th>Valor</th>'+
					'<th>Taxa</th>'+
				'</tr>'+
			'</thead>'+
			'<tbody>'+
			'</tbody>'+
		'</table>'+
	'</div>');	

	// Monta Tabela dos Itens
	$('#tabExtppr > div > table > tbody').html('');
	
	formataTabela( nriniseq, nrregist );	
	rodapeTabela( nriniseq, nrregist ); 
}

function formataTabela( nriniseq, nrregist ) {
	
	// tabela
	var divRegistro = $('div.divRegistros', '#'+tabDados);		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
	
	$('#'+tabDados).css({'margin-top':'5px'});
	divRegistro.css({'height':'150px','padding-bottom':'2px'});

	// Lista de registro
	var qtregist = arrayExtppr.length;
	var total = nriniseq + nrregist;
	
	if ( total > qtregist) { total = qtregist; } 
	
	for( var i = nriniseq; i < total; i++) {
		$('#tabExtppr > div > table > tbody').append('<tr></tr>');																					
		$('#tabExtppr > div > table > tbody > tr:last-child').append('<td>'+ arrayExtppr[i]['dtmvtolt'] +'</td>');
		$('#tabExtppr > div > table > tbody > tr:last-child').append('<td>'+ arrayExtppr[i]['cdagenci'] +'</td>');
		$('#tabExtppr > div > table > tbody > tr:last-child').append('<td>'+ arrayExtppr[i]['cdbccxlt'] +'</td>');
		$('#tabExtppr > div > table > tbody > tr:last-child').append('<td>'+ arrayExtppr[i]['nrdolote'] +'</td>');
		$('#tabExtppr > div > table > tbody > tr:last-child').append('<td>'+ arrayExtppr[i]['dshistor'] +'</td>');
		$('#tabExtppr > div > table > tbody > tr:last-child').append('<td>'+ arrayExtppr[i]['nrdocmto'] +'</td>');
		$('#tabExtppr > div > table > tbody > tr:last-child').append('<td>'+ arrayExtppr[i]['indebcre'] +'</td>');
		$('#tabExtppr > div > table > tbody > tr:last-child').append('<td>'+ arrayExtppr[i]['vllanmto'] +'</td>');
		$('#tabExtppr > div > table > tbody > tr:last-child').append('<td>'+ arrayExtppr[i]['txaplica'] +'</td>');
	}
	
	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '62px';
	arrayLargura[1] = '27px';
	arrayLargura[2] = '27px';
	arrayLargura[3] = '44px';
	arrayLargura[4] = '105px';
	arrayLargura[5] = '70px';
	arrayLargura[6] = '10px';
	arrayLargura[7] = '60px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'left';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'left';
	arrayAlinha[5] = 'right';
	arrayAlinha[6] = 'left';
	arrayAlinha[7] = 'right';
	arrayAlinha[8] = 'right';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

	$('#btSalvar','#divBotoes').css({'display':'none'});
	$('#btVoltar','#divBotoes').focus();
	
	$('#'+tabDados).css({'display':'block'});	
	cTodosCabecalho.desabilitaCampo();
	
	hideMsgAguardo();
	return false;
}

function rodapeTabela( nriniseq, nrregist ) {

	var qtregist = arrayExtppr.length;
	var rodape	 =
	
	rodape = '<table>';
	rodape += '<tr>';
	rodape += '<td>';

	//
	if (qtregist == 0) nriniseq = 0;
						
	// Se a paginação não está na primeira, exibe botão voltar
	if (nriniseq > 1) { 
		rodape += '<a class="paginacaoAnt"><<< Anterior</a>';
	} else {
		rodape += '&nbsp;';
	}
	
	rodape += '</td><td>';
	rodape += 'Exibindo ' + (nriniseq+1) + ' at&eacute; ';
	 
	if ((nriniseq + nrregist) > qtregist) { 
		rodape += qtregist; 
	} else {
		var aux = nriniseq + nrregist;	
		rodape += aux; 
	} 
	rodape += ' de ' + qtregist;
	rodape += '</td><td>';
					
	// Se a paginação não está na &uacute;ltima página, exibe botão proximo
	if (qtregist > (nriniseq + nrregist - 1)) {
		rodape += '<a class="paginacaoProx">Pr&oacute;ximo >>></a>';
	} else {
		rodape += '&nbsp;';
	}

	rodape += '</td></tr></table>';
	$('#divPesquisaRodape').css({'display':''}).html(rodape);
	
	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		var aux = nriniseq - nrregist;
		montarTabela( aux, nrregist );
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		var aux = nriniseq + nrregist;
		montarTabela( aux, nrregist );
	});	
	
	$('#divPesquisaRodape','#divTela').formataRodapePesquisa();
		
}

// contrato
function mostraContrato() {
	
	showMsgAguardo('Aguarde, buscando ...');

	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/extppr/contrato.php', 
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

	var nrdconta = normalizaNumero( cNrdconta.val() );	
	
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/extppr/busca_contrato.php', 
		data: {
			nrdconta: nrdconta, 
			redirect: 'script_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {
		
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divConteudo').html(response);
					exibeRotina($('#divRotina'));
					formataContrato();
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

function formataContrato() {

	var divRegistro = $('div.divRegistros','#divContrato');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'120px','width':'400px'});
	
	var ordemInicial = new Array();
	ordemInicial = [[1,0]];
	
	var arrayLargura = new Array();
	arrayLargura[0] = '70px';
	arrayLargura[1] = '120px';
	arrayLargura[2] = '70px';
			
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'right';
	
	var metodoTabela = 'selecionaContrato();';
			
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );
	
	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	
	return false;
}

function selecionaContrato() {
	
	if ( $('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao') ) {
					
		$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				cNraplica.val( $('#nrctrrpp', $(this) ).val() );
				
			}	
		});
	}

	layoutPadrao();
	cNraplica.trigger('blur');
	cNraplica.desabilitaCampo();
	cNraplica.focus();
	fechaRotina($('#divRotina'));
	manterRotina('BP');
	controlaPesquisas();
	return false;
}

// botoes
function btnVoltar() {

	if ( cNraplica.hasClass('campoTelaSemBorda')  && qtdeExtppr == '1' ) {
		trocaBotao('Prosseguir');
		cDtiniper.desabilitaCampo();
		cDtfimper.desabilitaCampo();
		cNraplica.habilitaCampo().focus();
		
	} else {
		estadoInicial();
	}
	cNrdconta.focus(); 
	controlaPesquisas();
	return false;
}

function btnContinuar() {
	
	if ( divError.css('display') == 'block' ) { return false; }		
	if ( cNrdconta.hasClass('campo')  ) { 	
	
		// Armazena o número da conta na variável global
		var nrdconta = normalizaNumero( cNrdconta.val() );

		// Verifica se o número da conta é vazio
		if ( nrdconta == '' ) { return false; }

		// Verifica se a conta é válida
		if ( !validaNroConta(nrdconta) ) { 
			showError('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'nrdconta\',\''+ frmCab +'\');'); 
			return false; 
		}

		cTodosCabecalho.removeClass('campoErro');	
		
		// Se chegou até aqui, a conta é diferente do vazio e é válida, então realizar a operação desejada
		controlaOperacao();
	
	} if ( cNraplica.hasClass('campo')  ) {
		
		var nraplica = normalizaNumero( cNraplica.val() );
		if ( nraplica == 0 ) { 
			mostraContrato(); 
		} else {
			cNraplica.desabilitaCampo();
			manterRotina('BP');
		}
		
	} if ( cDtiniper.hasClass('campo')  ) {
		manterRotina('BL');
	}	
	
	return false;

}

function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>&nbsp;');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onclick="btnContinuar(); return false;">'+botao+'</a>&nbsp;');
	return false;
}
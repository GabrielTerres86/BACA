/*!
 * FONTE        : extemp.js
 * CRIAÇÃO      : Rogerius Militão (DB1) 
 * DATA CRIAÇÃO : 28/07/2011
 * OBJETIVO     : Biblioteca de funções da tela EXTEMP
 * --------------
 * ALTERAÇÕES   :
 * -------------- 
 * 000: [06/10/2011] Exibe extrato de acordo com o tipo de empréstimo -  Marcelo L. Pereira (GATI)
 * 001: [05/07/2012] Alterado modo de impressao, retirado window.open -  Jorge I. Hamaguchi (CECRED)
 * 002: [11/12/2012] Alterado padrao botoes do tipo tah <input> pata <a>, alterado tamanho campos
 *					 array, incluso efeito de fundo para campos focados e layout tela  (Daniel).
 * 003: [05/01/2015] Padronizando a mascara do campo nrctremp.
 *		      	     10 Digitos - Campos usados apenas para visualização
 *					 8 Digitos - Campos usados para alterar ou incluir novos contratos
 *					 (Kelvin - SD 233714) 
 * -------------- 
 */

// Definição de algumas variáveis globais 
var arrayExtemp		= new Array();
var qtdeExtemp		= '0';
var intpextr		= '';

//Formulários
var frmCab   		= 'frmCab';
var frmDados  		= 'frmExtemp';
var tabDados		= 'tabExtemp';

//Labels/Campos do cabeçalho
var rNrdconta, rNmprimtl,
	cNrdconta, cNmprimtl, cTodosCabecalho, btnOK;

var rNrctremp, rVlsdeved, rVljuracu, rVlemprst, rVlpreemp, rDtdpagto,
	cNrctremp, cVlsdeved, cVljuracu, cVlemprst, cVlpreemp, cDtdpagto, cTodosDados;

	

$(document).ready(function() {
	estadoInicial();
	

	
});


// seletores
function estadoInicial() {
	$('#divTela').fadeTo(0,0.1);
	
	$('#frmCab').css({'display':'block'});
	$('#frmExtemp').css({'display':'block'});
	$('#divBotoes', '#divTela').css({'display':'block'});
	
	highlightObjFocus( $("#frmCab") );
	highlightObjFocus( $("#frmExtemp") );

	arrayExtemp = new Array();
	trocaBotao('Prosseguir');
	qtdeExtemp		= '0';
	
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

	arrayExtemp = new Array();
	trocaBotao('Concluir');
	
	$('#'+tabDados).css({'display':'none'}).html('');
	$('#divPesquisaRodape').css({'display':'none'}).html('');

	cTodosDados.limpaFormulario().removeClass('campoErro');	
	
	cNrctremp.habilitaCampo().focus();
	return false;
}

function atualizaSeletor(){

	// cabecalho
	rNrdconta			= $('label[for="nrdconta"]','#'+frmCab); 
	rNmprimtl	        = $('label[for="nmprimtl"]','#'+frmCab);        
	
	cNrdconta			= $('#nrdconta','#'+frmCab); 
	cNmprimtl			= $('#nmprimtl','#'+frmCab); 
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	btnOK				= $('#btnOK','#'+frmCab);

	// contrato
	rNrctremp			= $('label[for="nrctremp"]','#'+frmDados);
	rVlsdeved			= $('label[for="vlsdeved"]','#'+frmDados);
	rVljuracu			= $('label[for="vljuracu"]','#'+frmDados);
	rVlemprst			= $('label[for="vlemprst"]','#'+frmDados);
	rVlpreemp			= $('label[for="vlpreemp"]','#'+frmDados);
	rDtdpagto			= $('label[for="dtdpagto"]','#'+frmDados);
	
	cNrctremp			= $('#nrctremp', '#'+frmDados);			
	cVlsdeved			= $('#vlsdeved', '#'+frmDados);
	cVljuracu			= $('#vljuracu', '#'+frmDados);
	cVlemprst			= $('#vlemprst', '#'+frmDados);
	cVlpreemp			= $('#vlpreemp', '#'+frmDados);
	cDtdpagto			= $('#dtdpagto', '#'+frmDados);	
	cTodosDados		= $('input[type="text"],select','#'+frmDados);
	
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
		url		: UrlSite + 'telas/extemp/principal.php', 
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

function manterRotina() {
		
	hideMsgAguardo();		
	
	var mensagem = 'Aguarde, buscando...';
	var nrdconta = normalizaNumero( cNrdconta.val() );
	var nrctremp = normalizaNumero( cNrctremp.val() );
	
	$('#divRotina').html('');
	
	showMsgAguardo( mensagem );	
	
	$.ajax({		
			type  : 'POST',
			url   : UrlSite + 'telas/extemp/manter_rotina.php', 		
			data: {
				nrdconta	: nrdconta,
				nrctremp	: nrctremp,
				qtdeExtemp	: qtdeExtemp,
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
	/*  CONTROLE CONTRATO */
	/*--------------------*/
	var linkContrato = $('a:eq(0)','#'+ frmDados);
	
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
	
	rNrdconta.addClass('rotulo').css({'width':'44px'});
	rNmprimtl.addClass('rotulo-linha').css({'width':'44px'});
	
	cNrdconta.addClass('conta pesquisa').css({'width':'75px'})
	cNmprimtl.addClass('alphanum').css({'width':'395px'}).attr('maxlength','48');
	
	cNrdconta.habilitaCampo();
	cNrdconta.focus();
	cNmprimtl.desabilitaCampo();
	
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

	layoutPadrao();
	controlaPesquisas();
	return false;	
}

function formataDados() {

	rNrctremp.addClass('rotulo').css({'width':'75px'});
	rVlsdeved.addClass('rotulo-linha').css({'width':'125px'});
	rVljuracu.addClass('rotulo-linha').css({'width':'110px'});
	rVlemprst.addClass('rotulo').css({'width':'75px'});
	rVlpreemp.addClass('rotulo-linha').css({'width':'117px'});
	rDtdpagto.addClass('rotulo-linha').css({'width':'110px'});

	cNrctremp.addClass('pesquisa').css({'width':'105px','text-align':'right'}).setMask('INTEGER','z.zzz.zzz.zzz','.','');	
	cVlsdeved.css({'width':'95px','text-align':'right'});
	cVljuracu.css({'width':'95px','text-align':'right'});
	cVlemprst.css({'width':'95px','text-align':'right'});	
	cVlpreemp.css({'width':'95px','text-align':'right'});	
	cDtdpagto.addClass('data').css({'width':'95px'});	

	if ( $.browser.msie ) {
		rVlsdeved.addClass('rotulo-linha').css({'width':'127px'});
		rVljuracu.addClass('rotulo-linha').css({'width':'112px'});
		rVlpreemp.addClass('rotulo-linha').css({'width':'119px'});
		rDtdpagto.addClass('rotulo-linha').css({'width':'112px'});
	}

	cNrctremp.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( $('#divRotina').css('visibility') == 'visible' ) { 
			if ( e.keyCode == 13 ) { selecionaContrato(); return false; }
		}		

		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			var nrctremp = normalizaNumero( $(this).val() );

			if ( nrctremp == 0 ) {
				mostraContrato();
			} else {
				$(this).desabilitaCampo();
				manterRotina();
			}
			
			return false;

		} 
	});	
	
	cTodosDados.desabilitaCampo();
	layoutPadrao();
	controlaPesquisas();
	return false;	
	
}

function controlaLayout() {
	trocaBotao('Concluir');
	hideMsgAguardo();
	controlaPesquisas();
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
					'<th>Dcto</th>'+
					'<th></th>'+
					'<th>Valor</th>'+
					'<th>Taxa</th>'+
					'<th>Qtd.Pr</th>'+
				'</tr>'+
			'</thead>'+
			'<tbody>'+
			'</tbody>'+
		'</table>'+
	'</div>');	

	// Monta Tabela dos Itens
	$('#tabExtemp > div > table > tbody').html('');

	formataTabela( nriniseq, nrregist );	
	rodapeTabela( nriniseq, nrregist ); 
}

function formataTabela( nriniseq, nrregist ) {
	
	// tabela
	var divRegistro = $('div.divRegistros', '#'+tabDados);		
	var tabela      = $('table', divRegistro );
	
	$('#'+tabDados).css({'margin-top':'5px'});
	divRegistro.css({'height':'150px','padding-bottom':'2px'});

	// Lista de registro
	var qtregist = arrayExtemp.length;
	var total = nriniseq + nrregist;
	
	if ( total > qtregist) { total = qtregist; } 
	
	for( var i = nriniseq; i < total; i++) {
		$('#tabExtemp > div > table > tbody').append('<tr></tr>');																					
		$('#tabExtemp > div > table > tbody > tr:last-child').append('<td>'+ arrayExtemp[i]['dtmvtolt'] +'</td>');
		$('#tabExtemp > div > table > tbody > tr:last-child').append('<td>'+ arrayExtemp[i]['cdagenci'] +'</td>');
		$('#tabExtemp > div > table > tbody > tr:last-child').append('<td>'+ arrayExtemp[i]['cdbccxlt'] +'</td>');
		$('#tabExtemp > div > table > tbody > tr:last-child').append('<td>'+ arrayExtemp[i]['nrdolote'] +'</td>');
		$('#tabExtemp > div > table > tbody > tr:last-child').append('<td>'+ arrayExtemp[i]['dshistor'] +'</td>');
		$('#tabExtemp > div > table > tbody > tr:last-child').append('<td>'+ arrayExtemp[i]['nrdocmto'] +'</td>');
		$('#tabExtemp > div > table > tbody > tr:last-child').append('<td>'+ arrayExtemp[i]['indebcre'] +'</td>');
		$('#tabExtemp > div > table > tbody > tr:last-child').append('<td>'+ arrayExtemp[i]['vllanmto'] +'</td>');
		$('#tabExtemp > div > table > tbody > tr:last-child').append('<td>'+ arrayExtemp[i]['txjurepr'] +'</td>');
		$('#tabExtemp > div > table > tbody > tr:last-child').append('<td>'+ arrayExtemp[i]['qtpresta'] +'</td>');
	}
	
	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '62px';
	arrayLargura[1] = '25px';
	arrayLargura[2] = '27px';
	arrayLargura[3] = '40px';
	arrayLargura[4] = '131px';
	arrayLargura[5] = '50px';
	arrayLargura[6] = '10px';
	arrayLargura[7] = '60px';
	arrayLargura[8] = '52px';

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
	arrayAlinha[9] = 'right';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

	$('#btSalvar','#divTela').css({'display':'none'});
	$('#'+tabDados).css({'display':'block'});	
	
	$('#btVoltar','#divTela').focus();
	
	cTodosCabecalho.desabilitaCampo();
	hideMsgAguardo();
	return false;
}

function rodapeTabela( nriniseq, nrregist ) {

	var qtregist = arrayExtemp.length;
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
		url: UrlSite + 'telas/extemp/contrato.php', 
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
		url: UrlSite + 'telas/extemp/busca_contrato.php', 
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

function selecionaContrato() {
	
	if ( $('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao') ) {
					
		$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				cNrctremp.val( $('#nrctremp', $(this) ).val() );
				
			}	
		});
	}
	
	//layoutPadrao();
	//cNrctremp.trigger('blur');
	cNrctremp.desabilitaCampo();
	fechaRotina($('#divRotina'));
	manterRotina();
	controlaPesquisas();
	return false;
}


// botoes
function btnVoltar() {
	if ( cNrctremp.hasClass('campoTelaSemBorda') && qtdeExtemp == '1' ) {
		cNrctremp.habilitaCampo().focus();
		trocaBotao('Concluir');
		$('#btSalvar','#divBotoes').css({'display':''});
		$('#'+tabDados).css({'display':'none'}).html('');
		$('#divPesquisaRodape').css({'display':'none'}).html('');
	} else {
		estadoInicial();
	}
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
	
	} if ( cNrctremp.hasClass('campo')  ) {

		var nrctremp = normalizaNumero( cNrctremp.val() );
		if ( nrctremp == 0 ) { 
			mostraContrato(); 
		} else {
			cNrctremp.desabilitaCampo();
			manterRotina();
		}	

	} 
	
	return false;

}

function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onClick="btnVoltar(); return false;" >Voltar</a>&nbsp;');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onClick="btnContinuar(); return false;">'+botao+'</a>');
	
	return false;
}

function verificaTipoRelatorio() {
	hideMsgAguardo();
	var mtSimplificado = 'intpextr=1;imprimirExtrato();';
	var mtDetalhado    = 'intpextr=2;imprimirExtrato();';
		
	showConfirmacao('Escolha o tipo de relat&oacute;rio','Confirma&ccedil;&atilde;o - Ayllos',mtSimplificado,mtDetalhado,'simplificado.gif','detalhado.gif');
}

// Função para envio de formulário de impressao
function imprimirExtrato(){
	
	$('#sidlogin','#formEmpres').remove();
	$('#idseqttl','#formEmpres').remove();
	$('#nrctremp','#formEmpres').remove();		
	$('#nrdconta','#formEmpres').remove();
	$('#intpextr','#formEmpres').remove();		
	
	// Insiro input do tipo hidden do formulário para enviá-los posteriormente
	$('#formEmpres').append('<input type="hidden" id="sidlogin" name="sidlogin" />');
	$('#formEmpres').append('<input type="hidden" id="idseqttl" name="idseqttl" />');
	$('#formEmpres').append('<input type="hidden" id="nrctremp" name="nrctremp" />');
	$('#formEmpres').append('<input type="hidden" id="nrdconta" name="nrdconta" />');	
	$('#formEmpres').append('<input type="hidden" id="intpextr" name="intpextr" />');
	
	// Agora insiro os devidos valores nos inputs criados
	$('#sidlogin','#formEmpres').val( $('#sidlogin','#frmMenu').val() );
	$('#nrctremp','#formEmpres').val( normalizaNumero(cNrctremp.val()) );
	$('#nrdconta','#formEmpres').val( normalizaNumero(cNrdconta.val()) );
	$('#intpextr','#formEmpres').val( intpextr );	
	
	var action = UrlSite + 'telas/extemp/imprimir_extrato.php';	
	var callafter = "estadoInicial();";
	
	carregaImpressaoAyllos("formEmpres",action,callafter);

	return false;
}
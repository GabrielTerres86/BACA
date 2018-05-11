/*!
 * FONTE        : extrda.js
 * CRIAÇÃO      : Rogerius Militão (DB1) 
 * DATA CRIAÇÃO : 02/08/2011
 * OBJETIVO     : Biblioteca de funções da tela EXTRDA
 * --------------
 * ALTERAÇÕES   : 26/10/2012 - Incluso efeito highlightObjFocus, ajustado
							   tamanho campos para trabalhar com novo css,
							   alterado input imagem por botões. (Daniel)  
                  
                  27/11/2017 - Inclusao do valor de bloqueio em garantia. 
                               PRJ404 - Garantia Empr.(Odirlei-AMcom)
 * --------------
 */

//Formulários e Tabela
var frmCab   		= 'frmCab';
var frmDados  		= 'frmExtrda';
var tabDados		= 'tabExtrda';

var qtdeExtrda		= '0';
var arrayExtrda		= new Array();

//Labels/Campos do cabeçalho
var rNrdconta, rNmprimtl,  
	cNrdconta, cNmprimtl, cTodosCabecalho, btnOK;

var rNraplica, rVlsdrdad, rVlsdrdca, rCdoperad, rVlsdresg, rQtdiaapl, rQtdiauti, rTxcntrat, rTxminima, rVlbloque, rVlblqapl, 
	cNraplica, cVlsdrdad, cVlsdrdca, cCdoperad, cVlsdresg, cQtdiaapl, cQtdiauti, cTxcntrat, cTxminima, cVlbloque, cVlblqapl, 
	cDsaplica, cTodosDados;

var rVlstotal, cVlstotal;
	
$(document).ready(function() {
	estadoInicial();
});


// seletores
function estadoInicial() {
	$('#divTela').fadeTo(0,0.1);

	qtdeExtrda		= '0';	
	trocaBotao('prosseguir');
	arrayExtrda		= new Array();	
	
	hideMsgAguardo();		
	atualizaSeletor();
	formataCabecalho();
	formataDados();
	
	cTodosCabecalho.limpaFormulario().removeClass('campoErro');	
	cTodosDados.limpaFormulario().removeClass('campoErro');	

	$('#'+tabDados).css({'display':'none'});
	$('#divPesquisaRodape').css({'display':'none'});

	cNrdconta.focus();
	
	removeOpacidade('divTela');
}

function estadoExtrato() {

	arrayExtrda		= new Array();	
	trocaBotao('concluir');

	cTodosDados.limpaFormulario().removeClass('campoErro');	
	
	$('#'+tabDados).css({'display':'none'});
	$('#divPesquisaRodape').css({'display':'none'});

	cNraplica.habilitaCampo().focus();
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
	rNraplica			= $('label[for="nraplica"]','#'+frmDados);
	rVlsdrdad			= $('label[for="vlsdrdad"]','#'+frmDados);
	rVlsdrdca			= $('label[for="vlsdrdca"]','#'+frmDados);
	rCdoperad			= $('label[for="cdoperad"]','#'+frmDados);
	rVlsdresg			= $('label[for="vlsdresg"]','#'+frmDados);
	rQtdiaapl			= $('label[for="qtdiaapl"]','#'+frmDados);
	rQtdiauti			= $('label[for="qtdiauti"]','#'+frmDados);
	rTxcntrat			= $('label[for="txcntrat"]','#'+frmDados);
	rTxminima			= $('label[for="txminima"]','#'+frmDados);
    rVlbloque			= $('label[for="vlbloque"]','#'+frmDados);
    rVlblqapl			= $('label[for="vlblqapl"]','#'+frmDados);
	
	cNraplica			= $('#nraplica', '#'+frmDados);
	cDsaplica			= $('#dsaplica', '#'+frmDados);
	cVlsdrdad			= $('#vlsdrdad', '#'+frmDados);
	cVlsdrdca			= $('#vlsdrdca', '#'+frmDados);
	cCdoperad			= $('#cdoperad', '#'+frmDados);
	cVlsdresg			= $('#vlsdresg', '#'+frmDados);
	cQtdiaapl			= $('#qtdiaapl', '#'+frmDados);
	cQtdiauti			= $('#qtdiauti', '#'+frmDados);
	cTxcntrat			= $('#txcntrat', '#'+frmDados);
	cTxminima			= $('#txminima', '#'+frmDados);
    cVlbloque			= $('#vlbloque', '#'+frmDados);
    cVlblqapl			= $('#vlblqapl', '#'+frmDados);    
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
		url		: UrlSite + 'telas/extrda/principal.php', 
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
	var nraplica = normalizaNumero( cNraplica.val() );
	
	$('#divRotina').html('');
	
	showMsgAguardo( mensagem );	
	
	$.ajax({		
			type  : 'POST',
			url   : UrlSite + 'telas/extrda/manter_rotina.php', 		
			data: {
				nrdconta	: nrdconta,
				nraplica	: nraplica,
				qtdeExtrda	: qtdeExtrda,
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

		linkConta.prev().unbind('blur').bind('blur', function() { 
			controlaPesquisas();
			return false;
		});	
	
		linkConta.css('cursor','pointer').unbind('click').bind('click', function() {			
			mostraPesquisaAssociado('nrdconta', frmCab );
		});
	}

	/*--------------------*/
	/* CONTROLE APLICACAO */
	/*--------------------*/
	var linkAplicacao = $('a:eq(0)','#'+frmDados);
	
	if ( linkAplicacao.prev().prev().hasClass('campoTelaSemBorda') ) {		
		linkAplicacao.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {
		linkAplicacao.css('cursor','pointer').unbind('click').bind('click', function() {			
			mostraAplicacao();
		});
	}		

	return false;
}


// formata
function formataCabecalho() {
	
	rNrdconta.addClass('rotulo').css({'width':'40px'});
	rNmprimtl.addClass('rotulo-linha').css({'width':'42px'});

	cNrdconta.addClass('conta pesquisa').css({'width':'70px'})
	/*
	cNmprimtl.css({'width':'385px'});	
	*/
	if ( $.browser.msie ) {
		cNmprimtl.css({'width':'384px'}); /*384*/
	} else {
		cNmprimtl.css({'width':'436px'}); /*392*/
	}
	
	
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});

	if ( $.browser.msie ) {
	}	
	
	cNmprimtl.desabilitaCampo();
	cNrdconta.habilitaCampo();
	
	var nomeForm    = 'frmCab';
	highlightObjFocus( $('#'+nomeForm) );
	
	var nomeForm    = 'frmExtrda';
	highlightObjFocus( $('#'+nomeForm) );
	
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

		} else if ( e.keyCode == 118 ) {
			mostraPesquisaAssociado('nrdconta', frmCab );
			return false;
		}
	});	

	layoutPadrao();
	cNrdconta.trigger('blur');
	controlaPesquisas();
	return false;	
}

function formataDados() {
	
	rNraplica.addClass('rotulo').css({'width':'60px'});
	rVlsdrdad.addClass('rotulo-linha').css({'width':'98px'});
	rVlsdrdca.addClass('rotulo-linha').css({'width':'88px'});
	rCdoperad.addClass('rotulo').css({'width':'60px'});
	rVlsdresg.addClass('rotulo-linha').css({'width':'115px'});
	rQtdiaapl.addClass('rotulo-linha').css({'width':'88px'});
	rQtdiauti.addClass('rotulo').css({'width':'60px'});
	rTxcntrat.addClass('rotulo-linha').css({'width':'115px'});
	rTxminima.addClass('rotulo-linha').css({'width':'88px'});
    rVlbloque.addClass('rotulo').css({'width':'60px'});
    rVlblqapl.addClass('rotulo-linha').css({'width':'115px'});
	
	cNraplica.css({'width':'50px','text-align':'right'}).attr('maxlength','7').setMask('INTEGER','zzz.zz9','.','');
	cDsaplica.css({'width':'72px'})
	cVlsdrdad.css({'width':'115px'});
	cVlsdrdca.css({'width':'115px'});
	cCdoperad.css({'width':'125px'});
	cVlsdresg.css({'width':'115px'});
	cQtdiaapl.css({'width':'115px'});
	cQtdiauti.css({'width':'125px'});
	cTxcntrat.css({'width':'115px'});
	cTxminima.css({'width':'115px'});
    cVlbloque.css({'width':'125px'});
    cVlblqapl.css({'width':'115px'});
	
	if ( $.browser.msie ) {
		rNraplica.css({'width':'59px'});
		rVlsdrdad.css({'width':'90px'});
		rVlsdrdca.css({'width':'87px'});
		rCdoperad.css({'width':'59px'});
		rVlsdresg.css({'width':'107px'});
		rQtdiaapl.css({'width':'87px'});
		rQtdiauti.css({'width':'59px'});
		rTxcntrat.css({'width':'107px'});
		rTxminima.css({'width':'87px'});
        rVlbloque.css({'width':'59px'});
        rVlblqapl.css({'width':'107px'});
	}
	
	cTodosDados.desabilitaCampo();

	cNraplica.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( $('#divRotina').css('visibility') == 'visible' ) { 
			if ( e.keyCode == 13 ) { selecionaAplicacao(); }
			return false;
		}		

		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			var nraplica = normalizaNumero( $(this).val() );

			if ( nraplica == 0 ) {
				mostraAplicacao();
			} else {
				cNraplica.desabilitaCampo();
				manterRotina();
			}
			return false;

		} else if ( e.keyCode == 118 ) {
			mostraAplicacao();
		}
	});	
	
	layoutPadrao();
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
					'<th>PA</th>'+
					'<th>Historico</th>'+
					'<th>Dcto</th>'+
					'<th></th>'+
					'<th>Valor</th>'+
					'<th>Taxa</th>'+
					'<th>Vl.Pvl.Rgt</th>'+
				'</tr>'+
			'</thead>'+
			'<tbody>'+
			'</tbody>'+
		'</table>'+
	'</div>');	


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

	// Monta Tabela dos Itens
	$('#tabExtrda > div > table > tbody').html('');
	
	// Lista de registro
	var qtregist = arrayExtrda.length;
	var total = nriniseq + nrregist;
	
	if ( total > qtregist) { total = qtregist; } 
	
	for( var i = nriniseq; i < total; i++) {
		$('#tabExtrda > div > table > tbody').append('<tr></tr>');																					
		$('#tabExtrda > div > table > tbody > tr:last-child').append('<td>'+ arrayExtrda[i]['dtmvtolt'] +'</td>');
		$('#tabExtrda > div > table > tbody > tr:last-child').append('<td>'+ arrayExtrda[i]['cdagenci'] +'</td>');
		$('#tabExtrda > div > table > tbody > tr:last-child').append('<td>'+ arrayExtrda[i]['dshistoi'] +'</td>');
		$('#tabExtrda > div > table > tbody > tr:last-child').append('<td>'+ arrayExtrda[i]['nrdocmto'] +'</td>');
		$('#tabExtrda > div > table > tbody > tr:last-child').append('<td>'+ arrayExtrda[i]['indebcre'] +'</td>');
		$('#tabExtrda > div > table > tbody > tr:last-child').append('<td>'+ arrayExtrda[i]['vllanmto'] +'</td>');
		$('#tabExtrda > div > table > tbody > tr:last-child').append('<td>'+ arrayExtrda[i]['txaplica'] +'</td>');
		$('#tabExtrda > div > table > tbody > tr:last-child').append('<td>'+ arrayExtrda[i]['vlpvlrgt'] +'</td>');
	}
	
	var ordemInicial = new Array();

	var arrayLargura = new Array();
	
	arrayLargura[0] = '79px';
	arrayLargura[1] = '23px';
	arrayLargura[2] = '149px';
	arrayLargura[3] = '51px';
	arrayLargura[4] = '12px';
	arrayLargura[5] = '72px';
	arrayLargura[6] = '75px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'left';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'left';
	arrayAlinha[5] = 'right';
	arrayAlinha[6] = 'right';
	arrayAlinha[7] = 'right';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

	$('#btSalvar','#divTela').css({'display':'none'});
	$('#'+tabDados).css({'display':'block'});	
	$('#divPesquisaRodape').css({'display':'block'});	

	$('#btVoltar','#divTela').focus();
	
	cTodosCabecalho.desabilitaCampo();
	controlaPesquisas();	
	hideMsgAguardo();
	return false;
}

function rodapeTabela( nriniseq, nrregist ) {

	var qtregist = arrayExtrda.length;
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
	$('#divPesquisaRodape').html(rodape);
	

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


// aplicacao
function mostraAplicacao() {
	
	showMsgAguardo('Aguarde, buscando ...');

	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/extrda/aplicacao.php', 
		data: {
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			buscaAplicacao();
			return false;
		}				
	});
	return false;
	
}

function buscaAplicacao() {
		
	showMsgAguardo('Aguarde, buscando ...');
	
	var nrdconta = normalizaNumero( cNrdconta.val() );	
	
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/extrda/busca_aplicacao.php', 
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
					formataAplicacao();
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

function formataAplicacao() {
	
	var divRegistro = $('div.divRegistros','#divAplicacao');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'120px','width':'450px'});
	
	var ordemInicial = new Array();
	ordemInicial = [[1,0]];
	
	var arrayLargura = new Array();
	arrayLargura[0] = '70px';
	arrayLargura[1] = '50px';
	arrayLargura[2] = '170px';	
	
		
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left' ;
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'left' ;
	arrayAlinha[3] = 'right';
	
	var metodoTabela = 'selecionaAplicacao();';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );

	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );

	return false;
}

function selecionaAplicacao() {
	
	if ( $('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao') ) {
					
		$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				cNraplica.val( $('#nraplica', $(this) ).val() );
				cDsaplica.val( $('#dsaplica', $(this) ).val() );
				return false;
			}	
		});
	}
	
	layoutPadrao();
	cNraplica.trigger('blur');
	cNraplica.desabilitaCampo();
	fechaRotina($('#divRotina'));
	manterRotina();
	controlaPesquisas();
	return false;
}


// botoes
function btnVoltar() {
	
	if ( cNraplica.hasClass('campoTelaSemBorda') && qtdeExtrda == '1' ) {
		cNraplica.habilitaCampo().focus();
		trocaBotao('concluir');
		$('#btSalvar','#divBotoes').css({'display':''});
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
	
	} if ( cNraplica.hasClass('campo')  ) {
		var nraplica = normalizaNumero( cNraplica.val() );
		if ( nraplica == 0 ) { 
			mostraAplicacao(); 
		} else {
			cNraplica.desabilitaCampo();
			manterRotina();
		}
	} 
	
	return false;

}

function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;" >Voltar</a>&nbsp;');

	if (botao == 'concluir') {
		$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onclick="btnContinuar(); return false;" >Concluir</a>');
	}

	if (botao == 'prosseguir') {
		$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onclick="btnContinuar(); return false;" >Prosseguir</a>');
	}
		
		
	return false;
}
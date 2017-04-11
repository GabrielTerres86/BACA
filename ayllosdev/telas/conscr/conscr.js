/*!
/*!
 * FONTE        : conscr.js
 * CRIAÇÃO      : Rogerius Militão (DB1) 
 * DATA CRIAÇÃO : 01/12/2011
 * OBJETIVO     : Biblioteca de funções da tela CONSCR
 * --------------
 * ALTERAÇÕES   :
 * 28/06/2012 - Jorge Hamaguchi (CECRED) : Ajuste para novo esquema de impressao em funcao Gera_Impressao(), adicionado confirmacao de impressao para Gera_Impressao() 
 * 20/05/2012 - Tiago           (CECRED) : Implementado novas propriedades para o formFluxo.
 * 21/01/2013 - Daniel          (CECRED) : Implantacao novo layout.
 * 14/08/2013 - Carlos          (CECRED) : Alteração da sigla PAC para PA.
 * 10/04/2017 - Permitir acessar o Ayllos mesmo vindo do CRM. (Jaison/Andrino)
 * --------------
 */

//Formulários e Tabela
var frmCab   		= 'frmCab';
var tabDados		= 'tabConscr';

var operacao		= '';
var cddopcao		= 'C';
var tpconsul		= '';
var nrdconta		= '';
var nmprimtl		= '';
var nrcpfcgc		= '';
var contadox		= 0 ;
var cdvencto		= 0 ;
var cdmodali		= '';
var cdsubmod		= '';
var voltapra		= '';
var msgretor		= '';
var qtdregis		= 0 ;
var tabindex		= 0 ;
var nrJanelas		= 0 ;

var rCddopcao, rTpconsul, rNrdconta, rNrcpfcgc, rCdagenci,
	cCddopcao, cTpconsul, cNrdconta, cNrcpfcgc, cCdagenci, cTodosCabecalho;


$(document).ready(function() {
	estadoInicial();
});

// inicio
function estadoInicial() {
	$('#divTela').fadeTo(0,0.1);

	// inicializa
	tpconsul		= '';
	nrdconta		= '';
	nrcpfcgc		= '';
	contadox		= 0 ;
	cdvencto		= 0 ;	
	cdmodali		= ''; 
	cdsubmod		= '';
	voltapra		= '';
	msgretor		= '';
	tabindex		= 0 ;
	nrJanelas		= 0 ;	

	// inicializa com o campo prosseguir
	trocaBotao('Prosseguir'); 
	// inicializa com a frase de ajuda para o campo cddopcao
	// $('span:eq(0)', '#divMsgAjuda').html('Clique no botão PROSSEGUIR ou  pressione ENTER ou F1 para continuar.');
	// limpa a tela de rotina
	$('#divRotina').html('');

	// retira as mensagens	
	hideMsgAguardo();

	// formailzia	
	formataCabecalho();
	formataMsgAjuda();
	
	//
	cTodosCabecalho.limpaFormulario().removeClass('campoErro');	
	$('#'+tabDados).remove();
	
	//
	cCddopcao.val( cddopcao );
	removeOpacidade('divTela');
	
	highlightObjFocus( $('#frmCab') );
}


// controle
function controlaOperacao() {

	var nrdconta = normalizaNumero( cNrdconta.val() );
	var nrcpfcgc = normalizaNumero( cNrcpfcgc.val() );
	var cdagenci = normalizaNumero( cCdagenci.val() );
	
	var mensagem = 'Aguarde, buscando dados ...';
	showMsgAguardo( mensagem );	
	
	// Carrega dados da conta através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/conscr/principal.php', 
		data    : 
				{ 
					cddopcao	: cddopcao, 
					tpconsul    : tpconsul,
					nrdconta    : nrdconta,
					nrcpfcgc    : nrcpfcgc,
					cdagenci    : cdagenci,
					redirect	: 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) {
					hideMsgAguardo();
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							$('#divTela').html(response);
							return false;
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
						}
					} else {
						try {
							eval( response );
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
						}
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
	
	return false;
}

function controlaLayout( contador ) {

	contadox = parseInt(contador);

	formataCabecalho();
	formataTabela();
	tipoConsulta();

	cTodosCabecalho.desabilitaCampo();

	// remove uma mensagem de ajuda da tela
	// $('#divMsgAjuda:eq(0)', '#divTela').remove();
	
	// se tiver um registro, ja chama a proxima operacao	
	if ( contadox <= 1 ) {
	
		if ( cddopcao == 'R' ) {
		//	$('span:eq(0)', '#divMsgAjuda').html('Selecione a CONTA ou CPF/CNPJ desejado e clique em IMPRIMIR ou F1 para continuar.');
			trocaBotao('Imprimir');
		}
		
		selecionaTabela();
		
	} else {
		
		$('#btSalvar', '#divBotoes').focus();	
		
		if ( cddopcao == 'R' ) {
		//	$('span:eq(0)', '#divMsgAjuda').html('Selecione a CONTA ou CPF/CNPJ desejado e clique em IMPRIMIR ou F1 para continuar.');
			trocaBotao('Imprimir');
		}
		
	}

	formataMsgAjuda();
	return false;
}


// cabecalho
function formataCabecalho() {

	// label
	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab); 
	rTpconsul	        = $('label[for="tpconsul"]','#'+frmCab);        
	rNrdconta			= $('label[for="nrdconta"]','#'+frmCab); 
	rNrcpfcgc			= $('label[for="nrcpfcgc"]','#'+frmCab); 
	rCdagenci			= $('label[for="cdagenci"]','#'+frmCab); 

	rCddopcao.addClass('rotulo').css({'width':'42px'});
	rTpconsul.addClass('rotulo-linha').css({'width':'78px'});
	rNrdconta.addClass('rotulo-linha').css({'width':'78px','display':'none'});
	rNrcpfcgc.addClass('rotulo-linha').css({'width':'78px','display':'none'});
	rCdagenci.addClass('rotulo-linha').css({'width':'78px','display':'none'});

	// campo
	cCddopcao			= $('#cddopcao','#'+frmCab); 
	cTpconsul			= $('#tpconsul','#'+frmCab); 
	cNrdconta			= $('#nrdconta','#'+frmCab); 
	cNrcpfcgc			= $('#nrcpfcgc','#'+frmCab); 
	cCdagenci			= $('#cdagenci','#'+frmCab); 

	cCddopcao.css({'width':'128px'})
	cTpconsul.css({'width':'128px'});	
	cNrdconta.addClass('conta pesquisa').css({'width':'102px','display':'none'});	
	cNrcpfcgc.addClass('inteiro').css({'width':'100px','display':'none'}).attr('maxlength','14');	
	cCdagenci.addClass('inteiro').css({'width':'123px','display':'none'}).attr('maxlength','3');		

	// outros
	$('a:eq(0)','#'+frmCab).css({'display':'none'});
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);

	cTodosCabecalho.desabilitaCampo();
	cCddopcao.habilitaCampo();
	cCddopcao.focus();
	
	cCddopcao.unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) tipoOpcao(); 		});	
	cTpconsul.unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) tipoConsulta(); 		});	
	cNrdconta.unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) controlaOperacao(); 	});	
	cNrcpfcgc.unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) controlaOperacao(); 	});	
	cCdagenci.unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) controlaOperacao(); 	});	

	layoutPadrao();
	controlaPesquisas();
	return false;	
}


// cooperados
function formataTabela() {
	
	// tabela
	var divRegistro = $('div.divRegistros', '#'+tabDados);		
	var tabela      = $('table', divRegistro );
	
	$('#'+tabDados).css({'margin-top':'5px'});
	divRegistro.css({'height':'100px','padding-bottom':'2px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '30px';
	arrayLargura[1] = '90px';
	arrayLargura[2] = '238px';
	arrayLargura[3] = '155px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'left';
	arrayAlinha[3] = 'left';
	arrayAlinha[4] = 'right';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, 'selecionaTabela();' );
	return false;
	
}

function selecionaTabela() {

	if ( $('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao') && contadox > 1 ) {
					
		$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				nrdconta = $('#nrdconta', $(this) ).val();
				nrcpfcgc = $('#nrcpfcgc', $(this) ).val();
				nmprimtl = $('#nmprimtl', $(this) ).val();
			}	
		});
	}

	$('#nrdcoaux', '#'+frmCab).val( nrdconta );
	$('#nrcpfaux', '#'+frmCab).val( nrcpfcgc );
	$('#nmprimtl', '#'+frmCab).val( nmprimtl );
	
	if ( cddopcao == 'C' ) {
		mostraOpcao();
	
	} else if ( cddopcao == 'H' ) {
		mostraOpcao();
		
	} else if ( cddopcao == 'F' ) {
		mostraOpcao();
		operacao = 'fluxo';

	} else if ( cddopcao == 'M' ) {
		mostraOpcao();
		operacao = 'modalidade';
	
	} else if ( cddopcao == 'R' ) {
		showConfirmacao('Deseja visualizar a impress&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','Gera_Impressao();','','sim.gif','nao.gif');				
		return false;
	
	}
	return false;
}


// opcao C
function formataComplemento() {
	
	// label
	rDtrefere = $('label[for="dtrefere"]', '#frmComplemento');
	rQtopesfn = $('label[for="qtopesfn"]', '#frmComplemento');
	rQtifssfn = $('label[for="qtifssfn"]', '#frmComplemento');
	rVlopesfn = $('label[for="vlopesfn"]', '#frmComplemento');
	rVlopevnc = $('label[for="vlopevnc"]', '#frmComplemento');
	rVlopeprj = $('label[for="vlopeprj"]', '#frmComplemento');
	rVlopcoop = $('label[for="vlopcoop"]', '#frmComplemento');
	rVlopbase = $('label[for="vlopbase"]', '#frmComplemento');
	
	rDtrefere.css({'width':'117px'}).addClass('rotulo');
	rQtopesfn.css({'width':'60px'}).addClass('rotulo-linha');
	rQtifssfn.css({'width':'55px'}).addClass('rotulo-linha');
	rVlopesfn.css({'width':'77px'}).addClass('rotulo');
	rVlopevnc.css({'width':'60px'}).addClass('rotulo-linha');
	rVlopeprj.css({'width':'55px'}).addClass('rotulo-linha');
	rVlopcoop.css({'width':'96px'}).addClass('rotulo');
	rVlopbase.css({'width':'93px'}).addClass('rotulo-linha');
	
	// input
	cDtrefere = $('#dtrefere', '#frmComplemento');
	cQtopesfn = $('#qtopesfn', '#frmComplemento');
	cQtifssfn = $('#qtifssfn', '#frmComplemento');
	cVlopesfn = $('#vlopesfn', '#frmComplemento');
	cVlopevnc = $('#vlopevnc', '#frmComplemento');
	cVlopeprj = $('#vlopeprj', '#frmComplemento');
	cVlopcoop = $('#vlopcoop', '#frmComplemento');
	cDtrefaux = $('#dtrefaux', '#frmComplemento');
	cVlopbase = $('#vlopbase', '#frmComplemento');
	cDtrefer2 = $('#dtrefer2', '#frmComplemento');
	
	cDtrefere.css({'width':'65px'});
	cQtopesfn.css({'width':'100px'}).addClass('inteiro');
	cQtifssfn.css({'width':'100px'}).addClass('inteiro');
	cVlopesfn.css({'width':'105px'}).addClass('monetario');
	cVlopevnc.css({'width':'100px'}).addClass('monetario');
	cVlopeprj.css({'width':'100px'}).addClass('monetario');
	cVlopcoop.css({'width':'100px'}).addClass('monetario');
	cDtrefaux.css({'width':'75px'});
	cVlopbase.css({'width':'100px'}).addClass('monetario');
	cDtrefer2.css({'width':'65px'});
	
	// outros
	cTodosComplemento = $('input[type="text"]', '#frmComplemento');
	cTodosComplemento.desabilitaCampo();

	// centraliza a divRotina
	$('#divRotina').css({'width':'600px'});
	$('#divConteudo').css({'width':'580px'});	
	$('#divRotina').centralizaRotinaH();
	
	$('#btVoltar', '#divRotina').focus();
	layoutPadrao();
	return false;
}


// opcao F
function formataFluxo() {

	if ( operacao == 'fluxo' ) {
	
		// label
		rAvencer1 = $('label[for="avencer1"]','#frmFluxo');
		rValor111 = $('label[for="valor111"]','#frmFluxo');
		rVencidos = $('label[for="vencidos"]','#frmFluxo');
		rValor222 = $('label[for="valor222"]','#frmFluxo');
		rDsvenct1 = $('label[for="dsvencto1"]','#frmFluxo'); 
		rDsvenct2 = $('label[for="dsvencto2"]','#frmFluxo'); 

		rAvencer1.addClass('rotulo').css({'width':'133px'});
		rValor111.addClass('rotulo-linha').css({'width':'104px'});
		rVencidos.addClass('rotulo-linha').css({'width':'142px'});
		rValor222.addClass('rotulo-linha').css({'width':'105px'});
		
		// label
		$('label', '#frmFluxo').each(function() {
			
			if ( $(this).attr('for') == 'dsvencto1' ) {
				//$(this).addClass('rotulo').css({'width':'132px'});
				$(this).css("text-align","left");

			} else if ( $(this).attr('for') == 'dsvencto2' ) {
				//$(this).addClass('rotulo-linha').css({'width':'142px'});
				$(this).css("text-align","left");
			}
			
		});

		// input
		$('input', '#frmFluxo').each(function() {
			
			if ( $(this).attr('class') == 'vlvencto1' ) {
				$(this).addClass('monetario campo').css({'width':'105px'});				

			} else if ( $(this).attr('class') == 'vlvencto2' ) {
				$(this).addClass('monetario campo').css({'width':'105px'});
			}
			
		});
		
		tabindex = parseInt(tabindex) + 1;	
	
		// centraliza a divRotina
		$('#divRotina').css({'width':'550px'});
		$('#divConteudo').css({'width':'600px'});	
		$('#divRotina').centralizaRotinaH();
	
	} else if ( operacao == 'vencimento' ) {

		// tabela
		var divRegistro = $('div.divRegistros', '#frmFluxoVencimento');		
		var tabela      = $('table', divRegistro );
		
		$('#frmFluxoVencimento').css({'margin-top':'5px'});
		divRegistro.css({'height':'120px','padding-bottom':'2px'});

		var ordemInicial = new Array();

		var arrayLargura = new Array();
		arrayLargura[0] = '30px';
		arrayLargura[1] = '250px';

		var arrayAlinha = new Array();
		arrayAlinha[0] = 'right';
		arrayAlinha[1] = 'left';
		arrayAlinha[2] = 'right';
		
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
		operacao = 'fluxo';

		// centraliza a divRotina
		$('#divRotina').css({'width':'450px'});
		$('#divConteudo').css({'width':'425px'});	
		$('#divRotina').centralizaRotinaH();
		
	}
	
	layoutPadrao();
	$('#vlvencto'+tabindex, '#frmFluxo').focus();
	
	return false;
}

function fluxoVencimento( i, c, v, e ) {
	
	//
	vlvencto = normalizaNumero( v );
	
	if ( e.keyCode == 13 && vlvencto != 0 ) {
		cdvencto = normalizaNumero( c );
		operacao = 'vencimento';
		tabindex = i;
		buscaOpcao();
		return false;
	} else {
		tabindex = parseInt(tabindex) + 1;	
		$('#vlvencto'+tabindex, '#frmFluxo').focus();
	}
	
	if ( e.keyCode != 9 ) {
		return false;
	}
	
}


// opcao H
function formataHistorico() {
	
	// tabela
	var divRegistro = $('div.divRegistros', '#frmHistorico');		
	var tabela      = $('table', divRegistro );
	
	$('#frmHistorico').css({'margin-top':'5px'});
	divRegistro.css({'height':'150px','padding-bottom':'2px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '70px';
	arrayLargura[1] = '80px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'left';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

	// centraliza a divRotina
	$('#divRotina').css({'width':'550px'});
	$('#divConteudo').css({'width':'525px'});	
	$('#divRotina').centralizaRotinaH();
	
	$('#btVoltar', '#divRotina').focus();
	return false;
	
}


// imprimir F e R
function Gera_Impressao() {	

	hideMsgAguardo();
	
	if ( tpconsul == 3 ) {
		$('#nrdcoaux', '#'+frmCab).val( '0' );
		$('#nrcpfaux', '#'+frmCab).val( '0' );
	}

	var action 	 = UrlSite + 'telas/conscr/imprimir_dados.php';
	cTodosCabecalho.habilitaCampo();	
	
	carregaImpressaoAyllos(frmCab,action,"cTodosCabecalho.desabilitaCampo();fechaOpcao();");
	
}


// opcao M
function formataModalidade() {

	if ( operacao == 'modalidade' ) {
	
		// tabela
		var divRegistro = $('div.divRegistros', '#frmModalidade');		
		var tabela      = $('table', divRegistro );
		
		$('#frmModalidade').css({'margin-top':'5px'});
		divRegistro.css({'height':'120px','padding-bottom':'2px'});

		var ordemInicial = new Array();

		var arrayLargura = new Array();
		arrayLargura[0] = '30px';
		arrayLargura[1] = '250px';

		var arrayAlinha = new Array();
		arrayAlinha[0] = 'right';
		arrayAlinha[1] = 'left';
		arrayAlinha[2] = 'right';
		
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

		// centraliza a divRotina
		$('#divRotina').css({'width':'450px'});
		$('#divConteudo').css({'width':'425px'});	
		$('#divRotina').centralizaRotinaH();
		
		$('#btBotao1', '#divRotina').focus();
		
	} else if ( operacao == 'detalhe' ) {
	
		// label
		rCdmodali = $('label[for="cdmodali"]', '#frmModalidadeDetalhe');
		rCdmodali.addClass('rotulo').css({'width':'120px'});
		
		// input
		cCdmodali = $('#cdmodali', '#frmModalidadeDetalhe');
		cDsmodali = $('#dsmodali', '#frmModalidadeDetalhe');
		
		cCdmodali.css({'width':'40px'}).desabilitaCampo();
		cDsmodali.css({'width':'245px'}).desabilitaCampo();

		if ( $.browser.msie ) {
			cDsmodali.css({'width':'242px'});
		}	

		// tabela
		var divRegistro = $('div.divRegistros', '#frmModalidadeDetalhe');		
		var tabela      = $('table', divRegistro );
		
		$('#frmModalidadeDetalhe').css({'margin-top':'5px'});
		divRegistro.css({'height':'120px','padding-bottom':'2px'});

		var ordemInicial = new Array();

		var arrayLargura = new Array();
		arrayLargura[0] = '30px';
		arrayLargura[1] = '250px';

		var arrayAlinha = new Array();
		arrayAlinha[0] = 'right';
		arrayAlinha[1] = 'left';
		arrayAlinha[2] = 'right';
		
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, 'selecionaSubmodalidade();' );

		// centraliza a divRotina
		$('#divRotina').css({'width':'550px'});
		$('#divConteudo').css({'width':'475px'});	
		$('#divRotina').centralizaRotinaH();

		$('#btVoltar', '#divRotina').focus();
		
	} else if ( operacao == 'vencimento' ) {		
	
		// label
		rCdmodali = $('label[for="cdmodali"]', '#frmModalidadeVencimento');
		rCdmodali.addClass('rotulo').css({'width':'120px'});
		
		// input
		cCdmodali = $('#cdmodali', '#frmModalidadeVencimento');
		cDsmodali = $('#dsmodali', '#frmModalidadeVencimento');
		
		cCdmodali.css({'width':'40px'}).desabilitaCampo();
		cDsmodali.css({'width':'345px'}).desabilitaCampo();

		if ( $.browser.msie ) {
			cDsmodali.css({'width':'342px'});
		}	
		
		// tabela
		var divRegistro = $('div.divRegistros', '#frmModalidadeVencimento');		
		var tabela      = $('table', divRegistro );
		
		$('#frmModalidadeVencimento').css({'margin-top':'5px'});
		divRegistro.css({'height':'195px','padding-bottom':'2px'});

		var ordemInicial = new Array();

		var arrayLargura = new Array();
		arrayLargura[0] = '120px';
		arrayLargura[1] = '70px';
		arrayLargura[2] = '73px';
		arrayLargura[3] = '112px';

		var arrayAlinha = new Array();
		arrayAlinha[0] = 'left';
		arrayAlinha[1] = 'right';
		arrayAlinha[2] = 'right';
		arrayAlinha[3] = 'left';
		arrayAlinha[4] = 'right';
		
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

		// centraliza a divRotina
		$('#divRotina').css({'width':'550px'});
		$('#divConteudo').css({'width':'618px'});	
		$('#divRotina').centralizaRotinaH();
	
		$('#btVoltar', '#divRotina').focus();
	
	}

	layoutPadrao();
	return false;
}

function selecionaModalidade( op ) {
	
	cdsubmod = '';
	operacao = op;
	voltapra = op =='vencimento' ? 'modalidade' : op ;
	
	if ( $('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao') ) {
					
		$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				cdmodali = $('#cdmodali', $(this) ).val();
				buscaOpcao();
				return false;
			}	
		});
	}
	
}

function selecionaSubmodalidade( op ) {

	operacao = 'vencimento';

	if ( $('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao') ) {
					
		$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				cdsubmod = $('#cdsubmod', $(this) ).val();
				buscaOpcao();
				return false;
			}	
		});
	}
	
}


// ajuda
function formataMsgAjuda() {	

/* 	var divMensagem = $('#divMsgAjuda');
	divMensagem.css({'border':'1px solid #ddd','background-color':'#eee','padding':'2px','height':'20px','margin':'7px 0px'});
	
	var spanMensagem = $('span','#divMsgAjuda');
	spanMensagem.css({'text-align':'left','font-size':'11px','float':'left','padding':'3px'});

	var botoesMensagem = $('#divBotoes','#divMsgAjuda');
	botoesMensagem.css({'float':'right','padding':'0 0 0 2px', 'margin-top':'-20px'});		
	
	if ( $.browser.msie ) {
		spanMensagem.css({'padding':'5px 3px 3px 3px'});
		botoesMensagem.css({'margin-top':'2px'});		
	}	

	$('input[type="text"],select').focus( function() {
		if ( !($(this).hasClass('vlvencto1') || $(this).hasClass('vlvencto2')) ) {
			spanMensagem.html($(this).attr('alt'));
		} 
	});	 */
	
}


//
function mostraOpcao() {

	var mensagem = 'Aguarde, buscando dados ...';
 	showMsgAguardo(mensagem);
	
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/conscr/opcao.php', 
		data: {
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			buscaOpcao();
			return false;
		}				
	});
	return false;
	
}

function buscaOpcao() {
	
	var mensagem = 'Aguarde, buscando dados ...'; 
	showMsgAguardo(mensagem);

	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/conscr/busca_opcao.php', 
		data: {
			operacao: operacao,
			cddopcao: cddopcao,
			nrdconta: nrdconta,
			nrcpfcgc: nrcpfcgc,
			cdvencto: cdvencto, // opcao F
			cdmodali: cdmodali, // opcao M
			cdsubmod: cdsubmod, // opcao M
			redirect: 'script_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"fechaOpcao();");
		},
		success: function(response) {
			hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {

					$('#divConteudo').html(response);
					
					if ( msgretor == '' ) {

						if ( parseInt(qtdregis) > 0 ) {
							
							exibeRotina( $('#divRotina') );
							
							switch( cddopcao ) {	
								case 'C': formataComplemento();	break;
								case 'H': formataHistorico(); 	break;
								case 'F': formataFluxo(); 		break;
								case 'M': formataModalidade(); 	break;
							}
							
							formataMsgAjuda();
							bloqueiaFundo( $('#divRotina') );

						} else {
							// nao mostra a tela se nao tiver nenhum registro		
							fechaOpcao();
							
						}
						
					} else {
						showError('inform',msgretor,'Alerta - Ayllos','');
						msgretor = '';
					}
				
				} catch(error) {
					hideMsgAguardo();					
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','fechaOpcao();');
				}
			} else {
				try {
					eval( response );
				} catch(error) {
					hideMsgAguardo();					
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','fechaOpcao();');
				}
			}
			
		}				
	});
	
	controlaPesquisas();	
	return false;
}

function fechaOpcao() {

	//
	fechaRotina( $('#divRotina') );
	$('#divRotina').html('');
	
	if ( contadox <= 1 ) estadoInicial();
	
	operacao = '';
	tabindex = 0 ;
	return false;
}


function tipoOpcao() {

	if ( divError.css('display') == 'block' ) { return false; }		
	if ( cCddopcao.hasClass('campoTelaSemBorda')  ) { return false; }		
	
	// Armazena o número da conta na variável global
	cddopcao = cCddopcao.val();
	
	cTodosCabecalho.removeClass('campoErro');	
	
	cTpconsul.habilitaCampo();
	cCddopcao.desabilitaCampo();

	// remove opcao 3 
	$('#tpconsul option[value="3"]','#'+frmCab).remove();	
	
	if ( cddopcao == 'R') {
		$('#tpconsul','#'+frmCab).append('<option value="3"> 3 - PA </option>');	
	} 
	
	cTpconsul.focus();	
	return false;

}

function tipoConsulta() {
    // Seta os valores caso tenha vindo do CRM
    if ($("#crm_inacesso","#frmCab").val() == 1) {
        $("#nrdconta","#frmCab").val($("#crm_nrdconta","#frmCab").val());
        $("#nrcpfcgc","#frmCab").val($("#crm_nrcpfcgc","#frmCab").val());
    }

	tpconsul = cTpconsul.val();	

	if ( tpconsul == '1' ) {
		rNrcpfcgc.css({'display':'block'});	
		cNrcpfcgc.css({'display':'block'});	
		cNrcpfcgc.habilitaCampo();	
		cNrcpfcgc.focus();
		cTpconsul.desabilitaCampo();

	} else if ( tpconsul == '2' ) {
		rNrdconta.css({'display':'block','width':'60px'});		
		cNrdconta.css({'display':'block','width':'102px'});	
		cNrdconta.habilitaCampo();
		cNrdconta.focus();	
		$('a:eq(0)','#'+frmCab).css({'display':'block'});
		cTpconsul.desabilitaCampo();
		
	} else if ( tpconsul == '3' ) {
		rCdagenci.css({'display':'block','width':'53px'});		
		cCdagenci.css({'display':'block','width':'123px'});
		cCdagenci.habilitaCampo();
		cCdagenci.focus();	
		cTpconsul.desabilitaCampo();
	}
	
	controlaPesquisas();
	return false;
}



// botoes
function btnVoltar() {
	estadoInicial();
	controlaPesquisas();
	return false;
}

function btnContinuar() {

	if ( divError.css('display') == 'block' ) { return false; }		
	
	if ( cCddopcao.hasClass('campo') ) {
		tipoOpcao();
		
	} else if ( cTpconsul.hasClass('campo') ) {
		tipoConsulta();	
	
	} else if ( (cNrcpfcgc.css('display') == 'block' || 
				 cNrdconta.css('display') == 'block' || 
				 cCdagenci.css('display') == 'block') && $('#'+tabDados).length == 0 ) {
		controlaOperacao();
	
	} else  if ( $('#'+tabDados).length > 0 ) {
		selecionaTabela();

	}	

	controlaPesquisas();
	return false;

}

function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onClick="btnVoltar(); return false;" >Voltar</a>&nbsp;');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onClick="btnContinuar(); return false;">'+botao+'</a>');
	
	return false;
}

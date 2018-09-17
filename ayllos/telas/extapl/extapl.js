/*!
 * FONTE        : extapl.js
 * CRIAÇÃO      : Rogerius Militão (DB1) 
 * DATA CRIAÇÃO : 23/08/2011
 * OBJETIVO     : Biblioteca de funções da tela EXTAPL
 * --------------
 * ALTERAÇÕES   : 30/11/2012 - Alterado botões do tipo tag <input> para
 *					           tag <a> novo layout, incluso efeito fundo
 *	                           para campos focadis. Ajustado layout da tela (Daniel).
 * --------------
 */

//Formulários e Tabela
var frmCab   		= 'frmCab';
var tabDados		= 'tabExtapl';

var cddopcao		= '';

var nrsequen		= '';
var descapli		= '';
var tpaplica		= '';
var nraplica		= '';
var dtmvtolt		= '';
var tpemiext		= '';
var dsemiext		= '';

$(document).ready(function() {
	estadoInicial();
});

// inicio
function estadoInicial() {
	$('#frmCab').fadeTo(0,0.1);
	$('#divTela').fadeTo(0,0.1);
	
	$('#frmCab').css({'display':'block'});
	$('#tabExtapl', '#divTela').css({'display':'block'});
	$('#divBotoes', '#divTela').css({'display':'block'});

	trocaBotao('Prosseguir');
	$('#divRotina').html('');
	
	nrsequen		= ''	
	descapli		= ''	
	tpaplica		= ''	
	nraplica		= ''	
	dtmvtolt		= ''	
	tpemiext		= ''	
	dsemiext		= ''	
	
	hideMsgAguardo();		
	formataCabecalho();
	
	cTodosCabecalho.limpaFormulario().removeClass('campoErro');	

	$('#'+tabDados).css({'display':'none'});
	
	highlightObjFocus( $("#frmCab") );	

	cNrdconta.focus();
	removeOpacidade('divTela');
	removeOpacidade('frmCab');
}


// controle
function controlaOperacao() {

	$('#divRotina').html('');
	
	var nrdconta = normalizaNumero( $('#nrdconta', '#'+frmCab).val() );
	
	nrsequen		= ''
	descapli		= ''	
	tpaplica		= ''	
	nraplica		= ''	
	dtmvtolt		= ''	
	tpemiext		= ''	
	dsemiext		= ''
	
	var mensagem = 'Aguarde, buscando dados ...';
	showMsgAguardo( mensagem );	
	
	// Carrega dados da conta através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/extapl/principal.php', 
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

function manterRotina( operacao, tpemiext ) {
		
	hideMsgAguardo();		
	
	var mensagem = '';
	var nrdconta = normalizaNumero( $('#nrdconta','#'+frmCab).val() );
	
	switch(operacao) {
		case 'V': mensagem = 'Aguarde, validando dados ...'; 	break;
		case 'G': mensagem = 'Aguarde, gravando dados ...'; 	break;
		default: return false; break;
	}
	
	showMsgAguardo( mensagem );	
	
	$.ajax({		
			type  : 'POST',
			url   : UrlSite + 'telas/extapl/manter_rotina.php', 		
			data: {
				operacao	: operacao,
				cddopcao	: cddopcao,
				nrdconta	: nrdconta,
				descapli	: descapli,
				tpaplica	: tpaplica,
				nraplica	: nraplica,
				tpemiext	: tpemiext,
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
	
	return false;
}


// formata
function formataCabecalho() {

	// cabecalho
	rNrdconta			= $('label[for="nrdconta"]','#'+frmCab); 
	rNmprimtl	        = $('label[for="nmprimtl"]','#'+frmCab);        

	rNrdconta.addClass('rotulo').css({'width':'40px'});
	rNmprimtl.addClass('rotulo-linha').css({'width':'45px'});

	cNrdconta			= $('#nrdconta','#'+frmCab); 
	cNmprimtl			= $('#nmprimtl','#'+frmCab); 
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	cbtnOK				= $('#btnOK','#'+frmCab);

	cNrdconta.addClass('conta pesquisa').css({'width':'80px'})
	cNmprimtl.css({'width':'345px'});	

	if ( $.browser.msie ) {
	}	
	
	cNmprimtl.desabilitaCampo();
	cNrdconta.habilitaCampo();
	
	$('#frmCab').css({'display':'block'});
	$('#tabExtapl', '#divTela').css({'display':'block'});
	$('#divBotoes', '#divTela').css({'display':'block'});
	
	
	// Se clicar no botao OK
	cbtnOK.unbind('click').bind('click', function() { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( cNrdconta.hasClass('campoTelaSemBorda')  ) { return false; }		
		
		// Armazena o número da conta na variável global
		var nrdconta = normalizaNumero( cNrdconta.val() );
		
		// Verifica se o número da conta é vazio
		if ( nrdconta == '' ) { cNrdconta.focus(); return false; }
	
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
			cbtnOK.click();
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

function formataTabela() {
	
	// tabela
	var divRegistro = $('div.divRegistros', '#'+tabDados);		
	var tabela      = $('table', divRegistro );
	
	$('#'+tabDados).css({'margin-top':'5px'});
	divRegistro.css({'height':'200px','padding-bottom':'2px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '55px';
	arrayLargura[1] = '65px';
	arrayLargura[2] = '65px';
	arrayLargura[3] = '65px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'left';
	arrayAlinha[5] = 'left';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, 'selecionaAplicacao(\'A\');' );

	cTodosCabecalho.desabilitaCampo();
	controlaPesquisas();	
	hideMsgAguardo();
	return false;
}


// aplicacao
function mostraAplicacao() {
	
	showMsgAguardo('Aguarde, buscando ...');

	$('#divRotina').html('');
	
	// Executa script de confirmação através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/extapl/aplicacao.php', 
		data	: {
	
					cddopcao: cddopcao,
					nrsequen: nrsequen,
					descapli: descapli,		
					nraplica: nraplica,		
					dtmvtolt: dtmvtolt,		
					tpemiext: tpemiext,		
					dsemiext: dsemiext,		
					redirect: 'html_ajax'			
		}, 
		error	: function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success	: function(response) {
			$('#divRotina').html(response);
			formataAplicacao();
			return false;
		}				
	});
	return false;
	
}

function formataAplicacao() {

	rNrsequen = $('label[for="nrsequen"]', '#frmAplicacao');
	rDescapli = $('label[for="descapli"]', '#frmAplicacao');
	rNraplica = $('label[for="nraplica"]', '#frmAplicacao');
	rDtmvtolt = $('label[for="dtmvtolt"]', '#frmAplicacao');
	rTpemiext = $('label[for="tpemiext"]', '#frmAplicacao');
	
	rDescapli.addClass('rotulo').css({'width':'135px'});
	rNrsequen.addClass('rotulo').css({'width':'135px'});
	rNraplica.addClass('rotulo').css({'width':'135px'});
	rDtmvtolt.addClass('rotulo').css({'width':'135px'});
	rTpemiext.addClass('rotulo').css({'width':'135px'});
	
	cNrsequen = $('#nrsequen','#frmAplicacao');
	cDescapli = $('#descapli','#frmAplicacao');
	cNraplica = $('#nraplica','#frmAplicacao');
	cDtmvtolt = $('#dtmvtolt','#frmAplicacao');
	cTpemiext = $('#tpemiext','#frmAplicacao');
	
	cNrsequen.css({'width':'120px'});
	cDescapli.css({'width':'120px'});
	cNraplica.css({'width':'120px'});
	cDtmvtolt.css({'width':'120px'});
	cTpemiext.css({'width':'120px'});
	
	
	if ( cddopcao == 'A' ) {
		$('#divRotina').css({'width':'300px'});
		$('#divConteudo').css({'width':'300px'});
		$('select, input', '#frmAplicacao').desabilitaCampo();
	} else if ( cddopcao == 'T' ) {
		$('#divRotina').css({'width':'400px'});
		$('#divConteudo').css({'width':'400px'});
		$('label, select, input', '#frmAplicacao').css({'display':'none'});
		rTpemiext.css({'width':'250px','display':'block'}).html('Todas as aplicações para impressão tipo:');
		cTpemiext.css({'display':'block'});
	}
	
	cTpemiext.habilitaCampo();
	
	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	exibeRotina( $('#divRotina') );	
	cTpemiext.focus();
	return false;
}

function selecionaAplicacao( op ) {
	
	//
	cddopcao = op;
	
	if ( $('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao') ) {
					
		$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				 
				nrsequen = $('#nrsequen', $(this) ).val();
				descapli = $('#descapli', $(this) ).val();
				tpaplica = $('#tpaplica', $(this) ).val();
				nraplica = $('#nraplica', $(this) ).val();
				dtmvtolt = $('#dtmvtolt', $(this) ).val();
				tpemiext = $('#tpemiext', $(this) ).val();
				dsemiext = $('#dsemiext', $(this) ).val();
				mostraAplicacao();
				return false;
			}	
		});
	}
	
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
	cbtnOK.click();	
	return false;

}

function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onClick="btnVoltar(); return false;" >Voltar</a>&nbsp;');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onClick="btnContinuar(); return false;">'+botao+'</a>');
	
	return false;
}
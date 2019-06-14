/*!
 * FONTE        : notjus.js
 * CRIAÇÃO      : David Kruger
 * DATA CRIAÇÃO : 23/08/2011
 * OBJETIVO     : Biblioteca de funções da tela NOTJUS
 * --------------
 * ALTERAÇÕES   : 19/11/2013 - Ajustes para homologação (Adriano)
 * --------------
 */

//Formulários e Tabela
var frmCab   		= 'frmCab';
var tabDados		= 'tabNotjus';


$(document).ready(function() {

	estadoInicial();
	
});

// inicio
function estadoInicial() {

	$('#divTela').css({'display':'inline'}).fadeTo(0,0.1);
	removeOpacidade('divTela');
	$('#frmCab').css({'display':'block'});
	
	highlightObjFocus( $("#frmCab") );	
	
	$('#divDetalhes').html('');
		
	hideMsgAguardo();		
	formataCabecalho();
	
	cTodosCabecalho.limpaFormulario().removeClass('campoErro');	

	cNrdconta.focus();
		
}

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

	cNmprimtl.desabilitaCampo();
	cNrdconta.habilitaCampo();
	
	
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
		
		controlaOperacao();
		return false;
			
	});	
	

	cNrdconta.unbind('keypress').bind('keypress', function(e) {
	
		$(this).removeClass('campoErro');
		
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

// controle
function controlaOperacao() {

	var nrdconta = normalizaNumero( $('#nrdconta', '#'+frmCab).val() );
	var cddopcao = 'C';
	
	var mensagem = 'Aguarde, buscando estouros ...';
	
	showMsgAguardo( mensagem );	
	
	// Carrega dados da conta através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/notjus/principal.php', 
		data    : 
				{ 
					nrdconta	: nrdconta, 
					cddopcao	: cddopcao,
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
							$('#divDetalhes').html(response);
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

function manterRotina( cddopcao, nrseqdig ) {
		
	hideMsgAguardo();		
	
	var mensagem = '';
	var nrdconta = normalizaNumero( $('#nrdconta','#'+frmCab).val() );
	
	switch(cddopcao) {
	
		case 'E': 
			mensagem = 'Aguarde, excluindo...'; 	
		break;
		
		case 'N': 
			mensagem = 'Aguarde, gerando notificação...'; 	
		break;
		
		case 'J': 
			mensagem = 'Aguarde, gerando justificativa...'; 	
		break;
		
		default: 
			return false; 
		break;
		
	}
	
	showMsgAguardo( mensagem );	
	
	$.ajax({		
			type  : 'POST',
			url   : UrlSite + 'telas/notjus/manter_rotina.php', 		
			data: {
				cddopcao	: cddopcao,
				nrdconta    : nrdconta,
				nrseqdig	: nrseqdig,
				redirect	: 'script_ajax'
			}, 
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
			},
			success: function(response) {
				try {
				    hideMsgAguardo();
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
	arrayLargura[4] = '65px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'left';
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'left';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, "showConfirmacao('Deseja gerar justificativa?','Confirma&ccedil;&atilde;o - Ayllos','selecionaEstouro(\"J\");','','sim.gif','nao.gif');" );

	cTodosCabecalho.desabilitaCampo();
	controlaPesquisas();	
	hideMsgAguardo();
	$('#divPesquisaRodape', '#divTela').css({'display':'block'});
	
	return false;
	
}


function selecionaEstouro( op ) {	
	
	if ( $('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao') ) {
					
		$('table > tbody > tr', 'div.divRegistros').each( function() {
		
			if ( $(this).hasClass('corSelecao') ) {
				 
				nrseqdig = $('#nrseqdig', $(this) ).val();
				dtiniest = $('#dtiniest', $(this) ).val();
				qtdiaest = $('#qtdiaest', $(this) ).val();
				dshisest = $('#dshisest', $(this) ).val();
				vlestour = $('#vlestour', $(this) ).val();
				dsobserv = $('#dsobserv', $(this) ).val();
				manterRotina(op, nrseqdig);
				
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
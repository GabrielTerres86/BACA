/*!
 * FONTE        : atvprb.js
 * CRIAÇÃO      : Marcel Kohls / AMCom
 * DATA CRIAÇÃO : 19/03/2018
 * OBJETIVO     : Biblioteca de funções da tela ATVPRB
 */

//Formulários e Tabela
var frmCab   		= 'frmCab';
var frmCntCtr		= 'frmCntCtr';
var frmAtvPrb		= 'frmAtvPrb';
var frmFiltro		= 'frmFiltro';

var	cddopcao		= 'I';

$(document).ready(function() {
	estadoInicial();
});


// inicio
function estadoInicial() {
	$('#divTela').fadeTo(0,0.1);

	fechaRotina( $('#divRotina') );
	$('#divRotina').html('');

	// retira as mensagens
	hideMsgAguardo();

	// formailzia
	formataCabecalho();

	// remove o campo prosseguir
	trocaBotao('Prosseguir');

	// conta contrato
	$('#'+frmCntCtr, '#divTela').css({'display':'none'});
	$('#'+frmFiltro, '#divTela').css({'display':'none'});
	$('#'+frmAtvPrb, '#divTela').css({'display':'none'});
	$('#divBotoes', '#divTela').css({'display':'none'});

	cTodosCabecalho.limpaFormulario().removeClass('campoErro');

	cCddopcao.habilitaCampo();
	cCddopcao.focus();
	cCddopcao.val( cddopcao );

	removeOpacidade('divTela');
}

function manterRotina( operacao ) {
	hideMsgAguardo();

	var nrdconta = normalizaNumero( cNrdconta.val() );
	var nrctrato = normalizaNumero( cNrctrato.val() );
	var mensagem = '';

	switch( operacao ) {
		case 'Valida_Dados':	mensagem = 'Aguarde, validando dados ...';	break;
		case 'Altera_Dados':	mensagem = 'Aguarde, alterando dados ...';	break;
		case 'Exclui_Dados':	mensagem = 'Aguarde, excluindo registro ...';	break;
		case 'Inclui_Dados':	mensagem = 'Aguarde, salvando registro ...';	break;
		default: return false;	break;
	}

	showMsgAguardo( mensagem );

	$.ajax({
			type  : 'POST',
			url   : UrlSite + 'telas/atvprb/manter_rotina.php',
			data: {
				operacao	: operacao,
				cddopcao	: cddopcao,
				nrdconta	: nrdconta,
				nrctrato	: nrctrato,
				redirect	: 'script_ajax'
			},
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
			},
			success: function(response) {
				try {
					hideMsgAguardo();

					if (cddopcao == 'H') {
						$('#fsHistorico #conteudoHistorico').html(response);
						exibeFrmAtvPrb();
					} else {
						eval(response);
					}
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
	//  CONTROLE CONTA/DV
	var linkConta = $('a:eq(0)','#'+frmCntCtr);

	if ( linkConta.prev().hasClass('campoTelaSemBorda') ) {
		linkConta.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {
		linkConta.css('cursor','pointer').unbind('click').bind('click', function() {
			mostraPesquisaAssociado('nrdconta', frmCntCtr );
		});
	}

	return false;
}

// formata
function formataCabecalho() {

	// label
	rCddopcao = $('label[for="cddopcao"]', '#'+frmCab);
	rCddopcao.addClass('rotulo').css({'width':'42px'});

	// input
	cCddopcao = $('#cddopcao', '#'+frmCab);
	cCddopcao.css({'width':'600px'});

	// outros
	cTodosCabecalho = $('input[type="text"],select','#'+frmCab);
	cTodosCabecalho.desabilitaCampo();
	btnOK1			= $('#btnOk1', '#'+frmCab);

	if ( $.browser.msie ) {
		cCddopcao.css({'width':'598px'});
	}

	// perssiona tecla enter do combo opcoes
	cCddopcao.unbind('keydown').bind('keydown', function(e) {
		if (e.keyCode == 13) {
			btnOK1.click();
			return false;
		}
	});

	// Se clicar no botao OK
	btnOK1.unbind('click').bind('click', function() {
		if ( divError.css('display') == 'block' ) { return false; }
		if ( cCddopcao.hasClass('campoTelaSemBorda')  ) { return false; }

		//
		cCddopcao.desabilitaCampo();
		cddopcao 	= cCddopcao.val();

		$('input, select', '#'+frmCntCtr).limpaFormulario();
		formataContaContrato();
		trocaBotao('Prosseguir');
		return false;
	});

	controlaPesquisas();
	return false;
}

function formataContaContrato() {
	highlightObjFocus($('#'+frmCntCtr));

	// label
	rNrctrato = $('label[for="nrctrato"]', '#'+frmCntCtr);
	rNrdconta = $('label[for="nrdconta"]', '#'+frmCntCtr);
	rFlmotivo = $('label[for="flmotivo"]', '#'+frmFiltro);
	rFldtinic = $('label[for="fldtinic"]', '#'+frmFiltro);
	rFldtfina = $('label[for="fldtfina"]', '#'+frmFiltro);

	rNrdconta.addClass('rotulo-linha').css({'width':'70px'});
	rNrctrato.css({'width':'70px'});
	rFlmotivo.addClass('rotulo-linha').css({'width':'90px'});
	rFldtinic.addClass('rotulo').css({'width':'93px'});
	rFldtfina.css({'width':'337px'});

	// input
	cNrctrato = $('#nrctrato', '#'+frmCntCtr);
	cNrdconta = $('#nrdconta', '#'+frmCntCtr);
	cFlmotivo = $('#flmotivo', '#'+frmFiltro);
	cFldtinic = $('#fldtinic', '#'+frmFiltro);
	cFldtfina = $('#fldtfina', '#'+frmFiltro);

	cNrctrato.css({'width':'120px'}).addClass('inteiro').attr('maxlength','14');
	cNrdconta.css({'width':'120px'}).addClass('conta pesquisa');
	cFlmotivo.css({'width':'520px'});
	cFldtinic.css({'width':'90px'}).addClass('data');
	cFldtfina.css({'width':'90px'}).addClass('data');

	$('input', '#frmCntCtr').desabilitaCampo();

	$('#'+frmCntCtr).css({'display':'block'});
	$('#divBotoes', '#divTela').css({'display':'block'});

	cNrctrato.habilitaCampo();
	cNrdconta.habilitaCampo();
	cFlmotivo.habilitaCampo();
	cFldtinic.habilitaCampo();
	cFldtfina.habilitaCampo();

	formataAtvPrb();

	layoutPadrao();
	controlaPesquisas();
	cNrdconta.focus();
	return false;
}

function formataAtvPrb() {

	highlightObjFocus($('#'+frmAtvPrb));

	cTodosAtvPrb = $('input, select', '#'+frmAtvPrb);
	cTodosAtvPrb.desabilitaCampo();

	adicionaMotivosSistema();

	if (cddopcao == 'H') {
		$('#'+frmFiltro, '#divTela').css({'display':'block'});
	} else if (cddopcao !== 'H' && isHabilitado(cNrdconta) == false) {
		//label			
		rTpmotivo = $('label[for="tpmotivo"]', '#'+frmAtvPrb);
		rObservac = $('label[for="observac"]', '#'+frmAtvPrb);
		rDtinclus = $('label[for="dtinclus"]', '#'+frmAtvPrb);
		rDtexclus = $('label[for="dtexclus"]', '#'+frmAtvPrb);

		rTpmotivo.addClass('rotulo-linha').css({'width':'90px'});
		rObservac.css({'width':'88px'});
		rDtinclus.addClass('rotulo-linha').css({'width':'90px'});
		rDtexclus.css({'width':'188px'});

		// input
		cTpmotivo = $('#tpmotivo', '#'+frmAtvPrb);
		cObservac = $('#observac', '#'+frmAtvPrb);
		cDtinclus = $('#dtinclus', '#'+frmAtvPrb);
		cDtexclus = $('#dtexclus', '#'+frmAtvPrb);

		cTpmotivo.css({'width':'240px'});
		cObservac.css({'width':'220px'});
		cDtinclus.css({'width':'140px'});
		cDtexclus.css({'width':'140px'});

		if (cddopcao !== 'C' && cddopcao !== 'E'){
			cTpmotivo.habilitaCampo();
			cObservac.habilitaCampo();

			$('#'+frmAtvPrb+' #tpmotivo .mtvSistema').remove();
		}

		if (cddopcao == 'I') {
			$('#datasRegistro', '#'+frmAtvPrb).hide();
		} else {
			$('#datasRegistro', '#'+frmAtvPrb).show();
		}
	}

	controlaPesquisas();
	return false;
}

function prosseguirAtvPrb() {
	if ( in_array(cddopcao, ['C', 'A', 'E', 'I', 'H'])) {
		if ( isHabilitado(cNrdconta) || isHabilitado(cNrctrato) ) {
			manterRotina('Valida_Dados');
		} else {
			if (cddopcao == 'E') {
				showConfirmacao('Você tem certeza de que deseja excluir este registro?', 'Excluir - Ayllos', 'manterRotina("Exclui_Dados");', '', 'sim.gif', 'nao.gif');
			} else if (cddopcao == 'A') {
				showConfirmacao('Confirmar as alterações deste registro?', 'Confirma&ccedil;&atilde;o - Ayllos', 'manterRotina("Altera_Dados");', '', 'sim.gif', 'nao.gif');
			} else if (cddopcao == 'I') {
				manterRotina("Inclui_Dados");
			} else {
				showError("inform","Opção indefinida.","Notifica&ccedil;&atilde;o - Ayllos","estadoInicial();");
			}
		}
	}
}

function adicionaMotivosSistema() {
	$('#'+frmAtvPrb+' #tpmotivo .mtvSistema').remove();

	$('#'+frmAtvPrb+' #tpmotivo').prepend( "<option class='mtvSistema' value='1'>1  - 90 dias atraso</option>"
										  +"<option class='mtvSistema' value='2'>2  - 90 dias atraso (Reestruturação)</option>"
										  +"<option class='mtvSistema' value='3'>3  - Opera&ccedil;&otilde;es a partir do risco D sem atraso</option>"
										  +"<option class='mtvSistema' value='4'>4  - Prejuízo</option>"
										  +"<option class='mtvSistema' value='5'>5  - Penhora</option>"
										  +"<option class='mtvSistema' value='6'>6  - Bloqueio terceiros</option>"
										  +"<option class='mtvSistema' value='7'>7  - Outros juridico</option>" );
}

function voltarAtvPrb() {
	if (!isHabilitado(cNrdconta) && !isHabilitado(cNrctrato)) {
		$('#'+frmAtvPrb+" fieldset").css({'display':'none'});
		
		cTodosAtvPrb = $('input, select', '#'+frmCntCtr);
		cTodosAtvPrb.limpaFormulario();

		cNrctrato.habilitaCampo();
		cNrdconta.habilitaCampo().focus();

		trocaBotao('Prosseguir');
	} else {
		estadoInicial();
	}

	return false;
}

// valida
function validaCampo( valor, campo, frm ) {
	// conta
	if ( in_array(campo,['nrdconta','nrctaavl']) && !validaNroConta(valor) ) {
		showError('error','Dígito errado.','Alerta - Ayllos','$(\'#'+campo+'\',\'#'+frm+'\').focus();');
		return false;

	// cpf/cnpj
	} else if ( campo == 'nrctrato' && verificaTipoPessoa(valor) == 0 ) {
		showError('error','Dígito errado.','Alerta - Ayllos','$(\'#'+campo+'\',\'#'+frm+'\').focus();');
		return false;

	// identificacao
	} else if ( campo == 'tpctrdev' && !in_array(valor,[1,2,3]) ) {
		showError('error','Opcao errada.','Alerta - Ayllos','$(\'#'+campo+'\',\'#'+frm+'\').focus();');
		return false;
	}

	return true;
}

function habilitaConta() {
	cNrctrato.desabilitaCampo();
	cNrdconta.habilitaCampo();
	cNrdconta.focus();
	controlaPesquisas();
	return false;
}

// botoes
function btnVoltar() {
	voltarAtvPrb();

	controlaPesquisas();
	return false;
}

function btnContinuar() {
	if ( divError.css('display') == 'block' ) { return false; }

	prosseguirAtvPrb();

	controlaPesquisas();
	return false;
}

function trocaBotao( botao ) {
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>');

	if ( botao != '') {
		$('#divBotoes','#divTela').append('&nbsp;<a href="#" class="botao" onclick="btnContinuar(); return false;" >'+botao+'</a>');
	}
	return false;
}

function exibeFrmAtvPrb() {
	$('input', '#'+frmCntCtr).desabilitaCampo();	
	$('#'+frmAtvPrb).css({'display':'block'});
	$('#'+frmAtvPrb+" fieldset").css({'display':'none'});
	
	if (cddopcao == 'H') {
		$('#'+frmAtvPrb+" #fsHistorico").css({'display':'block'});
		formataHistorico();
		trocaBotao('');
	} else {
		$('#'+frmAtvPrb+" #fsDados").css({'display':'block'});
		
		formataAtvPrb();

		if (cddopcao == 'E') {
			trocaBotao('Excluir');
		} else if (cddopcao !== 'C') {
			trocaBotao('Salvar');
		} else {
			trocaBotao('');
		}
	}
}

function formataHistorico() {
	var divRegistro = $('div.divRegistros','#divConta');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'130px'});
	
	var ordemInicial = new Array();
	
	var arrayLargura = new Array();
	arrayLargura[0] = '60px';
	arrayLargura[1] = '60px';
	arrayLargura[2] = '300px';
	arrayLargura[3] = '98px';
		
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'right';
	arrayAlinha[3] = 'center';
	arrayAlinha[4] = 'center';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha );

	// centraliza a divRotina
	$('#divRotina').css({'width':'425px'});
	$('#divConteudo').css({'width':'400px'});
	$('#divRotina').centralizaRotinaH();
	
	return false;
}
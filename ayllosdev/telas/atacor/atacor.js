/*!
 * FONTE        : atacor.js
 * CRIAÇÃO      : Reginaldo (AMcom)
 * DATA CRIAÇÃO : 06/02/2018
 * OBJETIVO     : Biblioteca de funções da tela ATACOR
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 * 
 */
 
var nrdconta, nmprimtl, nracordo, nrctremp;
var divTabela, divRegistros;
var cNracordo, cNmprimtl, cNrdconta;
var cDtaltera, cTpaltera, cNmoperad, cDsaltera;
var linhaContratoRemover;

$(document).ready(function() {
	// Inicializando algumas variáveis
	nrdconta = 0;
	nmprimtl = '';
	nracordo = '';

	divTabela    = $('#divTabela');
	divRegistros = $('div.divRegistros', divTabela );
	
	// Inicializando os seletores dos campos do cabeçalho
	cNrdconta = $('#nrdconta','#frmCabAtacor');
	cNmprimtl = $('#nmprimtl','#frmCabAtacor');
	cNracordo = $('#nracordo','#frmCabAtacor');

	cNracordo.unbind('keypress').bind('keypress', function(e) {
        if ((e.keyCode == 9 || e.keyCode == 13) && (cNracordo.val() != '')) {
            $('#btBuscaAcordo').click();
            return false;
        }
    });
	
	controlaLayout();

	$('#divTabela tbody tr').live('click', function() {
		selecionaContrato($(this));
	});
});

function controlaLayout() {	
	formataCabecalho();
	formataTabela();
	layoutPadrao();		
}

function formataCabecalho() {
	highlightObjFocus( $('#frmCabAtacor') );

	var rNrdconta   = $('label[for="nrdconta"]','#frmCabAtacor');
	var rNmprimtl	= $('label[for="nmprimtl"]','#frmCabAtacor');
	var	rNracordo   = $('label[for="nracordo"]','#frmCabAtacor');
		
	rNracordo.addClass('rotulo').css({'width':'45px'});
	rNmprimtl.addClass('rotulo-linha').css({'width':'45px'});
	rNrdconta.addClass('rotulo-linha').css({'width':'62px'});
	
	cNracordo.css({'width':'70px'}).habilitaCampo();
	cNmprimtl.css({'width':'310px'}).desabilitaCampo();
	cNrdconta.css({'width':'120px'}).desabilitaCampo();

	if ( $.browser.msie ) {
		rNrdconta.css({'width':'65px'});
		cNracordo.css({'width':'77px'});
	} 
	
	estadoInicial();	
}

function formataTabela() {
	divRegistros = $('div.divRegistros', divTabela );
	
	divRegistros.css({'height':'200px','padding-bottom':'2px'});

	var tabela = $('table', divRegistros);

	var ordemInicial = new Array();

	var arrayLargura = ['330px', '160px', '140px', '50px'];

	var arrayAlinha = ['left', 'right', 'right', 'center'];

	tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);
	
	divTabela.css({'display':'block'});

	return false;
}

function carrega_dados()
{	
    nracordo = $('#nracordo').val();
    
	// Valida número da conta
	if (!validaNumero(nracordo)) {
		showError("error","Número de acordo inv&aacute;lido.","Atacor - Ayllos","$('#nracordo','#frmCabAtacor').focus();");
		return false;
	}

	// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, validando informa&ccedil;&otilde;es ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		dataType: 'html',
		url: UrlSite + "telas/atacor/carrega_dados.php",
		data: {
			nracordo: nracordo,	
			redirect: "script_ajax" // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Atacor - Ayllos","$('#nracordo','#frmCabAtacor').focus();");							
		},
		success: function(response) {
			//console.log(response);	
			hideMsgAguardo();
			try {
				if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					$('#divTabela').html(response);
					return false;
					
				} else {
					eval(response);
				}
			} catch(error) {
				hideMsgAguardo();
				showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Atacor - Ayllos', '$(\'#nracordo\',\'#frmCabAtacor\').focus();');
			}
		}		
				
	});
}

function estadoInicial() {
	var cTodos = $('input','#frmCabAtacor');
	cTodos.val('');
	cNracordo.focus();	
}

function selecionaContrato(tr)
{
	linhaContratoRemover = tr;

	nrctremp = $('input[name="nrctremp"]', tr).val();

	var permiteExcluir = $('input[name="cdoperad"]', tr).val() != '' && $('input[name="cdlcremp"]', tr).val() == '100';

	if (permiteExcluir) {
		$('#botaoExcluirContrato').show();
	} 
	else {
		$('#botaoExcluirContrato').hide();
	}
}

function processarExclusao()
{
	showConfirmacao('Confirmar remo&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'excluirContrato();', '', 'sim.gif', 'nao.gif');
}

function excluirContrato()
{
	
	var operacao = 'EXCLUIR_CONTRATO';

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, removendo o contrato ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		dataType: 'html',
		url: UrlSite + "telas/atacor/manter_rotina.php",
		data: {
			nrctremp: nrctremp,
			nracordo: nracordo,
			operacao: operacao,
			redirect: "script_ajax" // Tipo de retorno do ajax
		},		
		error: function(objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Atacor - Ayllos","$('#nracordo','#frmCabAtacor').focus();");							
		},
		success: function(response) {	
			hideMsgAguardo();
			try {
				eval(response);					
			} catch(error) {
				hideMsgAguardo();
				showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Atacor - Ayllos', '$(\'#nracordo\',\'#frmCabAtacor\').focus();');
			}
		}		
	});
}

function atualizarContrato(checkBox)
{	
    var linha = checkBox.closest('tr');

	var nrctremp = $('input[name="nrctremp"]', linha).val();
	var indpagar = $(checkBox).prop('checked') == true ? 'S' : 'N';

	var operacao = 'ATUALIZA_CONTRATO';
    
	// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, atualizando informa&ccedil;&otilde;es ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		dataType: 'html',
		url: UrlSite + "telas/atacor/manter_rotina.php",
		data: {
			nrctremp: nrctremp,
			nracordo: nracordo,
			indpagar: indpagar,	
			operacao: operacao,
			redirect: "script_ajax" // Tipo de retorno do ajax
		},		
		error: function(objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Atacor - Ayllos","$('#nracordo','#frmCabAtacor').focus();");							
		},
		success: function(response) {	
			hideMsgAguardo();
			try {
				if (response.indexOf('showError("error"') != -1 && response.indexOf('XML error:') != -1 && response.indexOf('#frmErro') != -1 ) {
					eval(response);					
				}
			} catch(error) {
				hideMsgAguardo();
				showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Atacor - Ayllos', '$(\'#nracordo\',\'#frmCabAtacor\').focus();');
			}
		}		
	});
}

function removeContratoTabela()
{
	/*linhaContratoRemover.remove();
	selecionaContrato($('#divTabela tbody:nth-child(0)')); */
	carrega_dados();
}

function incluirContrato()
{
	showMsgAguardo('Aguarde, abrindo inclus&atilde;o de contratos...');

	//limpaDivGenerica();

	exibeRotina($('#divUsoGenerico'));

	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atacor/form_inclusao_contrato.php',
		data: {
			nracordo: nracordo,
			redirect: 'html_ajax'
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'N&atilde;o foi poss&iacute;&shy;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function (response) {
			$('#divUsoGenerico').html(response);
			layoutPadrao();
			hideMsgAguardo();
			bloqueiaFundo($('#divUsoGenerico'));
			$('#nracordo', '#frmincctr').focus();
		}
	});

	return false;
}

function validaContrato()
{
	var nrctrempValidar = $('#nrctremp', '#frmincctr').val();

	if (nrctrempValidar != '') {
		showMsgAguardo('Aguarde, validando contrato informado...');

		$.ajax({
			type: 'POST',
			dataType: 'html',
			url: UrlSite + 'telas/atacor/manter_rotina.php',
			data: {
				nracordo: nracordo,
				nrctremp: nrctrempValidar,
				operacao: 'VALIDAR_CONTRATO',
				redirect: 'html_ajax'
			},
			error: function (objAjax, responseError, objExcept) {
				hideMsgAguardo();
				showError('error', 'N&atilde;o foi poss&iacute;&shy;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '$(\'#nrctremp\',\'#frmincctr\').focus();');
			},
			success: function (response) {
				try {
					//if (response.indexOf('showError("error"') != -1 && response.indexOf('XML error:') != -1 && response.indexOf('#frmErro') != -1) {
						eval(response);
					//}
					hideMsgAguardo();
				} catch (error) {
					hideMsgAguardo();
					showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Atacor - Ayllos', '$(\'#nrctremp\',\'#frmincctr\').focus();');
				}
			}
		});
	}
}

function gravarContrato() {
	showMsgAguardo('Aguarde, gravando contrato...');

	var nrctrempGravar = $('#nrctremp', '#frmincctr').val();

	if (nrctrempGravar == '') {
		showError('error', 'Informe o n&uacute;mero do contrato que deseja incluir.', 'Alerta - Ayllos', '$(\'#nrctremp\',\'#frmincctr\').focus();');
	}

	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atacor/manter_rotina.php',
		data: {
			nracordo: nracordo,
			nrctremp: nrctrempGravar,
			operacao: 'INCLUIR_CONTRATO',
			redirect: 'html_ajax'
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'N&atilde;o foi poss&iacute;&shy;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '$(\'#nrctremp\',\'#frmincctr\').focus();');
		},
		success: function (response) {
			hideMsgAguardo();
			try {
				//if (response.indexOf('showError("error"') != -1 && response.indexOf('XML error:') != -1 && response.indexOf('#frmErro') != -1) {
					eval(response);
				//}
			} catch (error) {
				hideMsgAguardo();
				showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Atacor - Ayllos', '$(\'#nracordo\',\'#frmCabAtacor\').focus();');
			}	
		}
	});

	return false;
}

function addContratoTabela(nrctrempIncluso)
{
	/*var tr = $('#divRegistros table').append('<tr>');
	var td = tr.append('<td>');
	td.html('Empréstimo');
	var td = tr.append('<td>');
	td.html(nrctrempIncluso);
	var td = tr.append('<td>');
	td.html(100);
	var td = tr.append('<td>');
	td.html('<input type="checkbox" name="pagar" checked="checked" style="float: none;" onchange="atualizarContrato(this)">');*/

	carrega_dados();
}

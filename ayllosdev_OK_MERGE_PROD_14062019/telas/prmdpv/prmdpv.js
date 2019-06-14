//*********************************************************************************************//
//*** Fonte: prmdpv.js                               					                    ***//
//*** Autor: Lucas Moreira                                                                  ***//
//*** Data : 04/09/2015																		***//
//*** Alterações: 									                                        ***//	 
//*********************************************************************************************//

// Definição de algumas variáveis globais 
var cddopcao = 'T';
var auxiliar;

//Formulários
var frmCab = 'frmCab';

//Labels/Campos do cabeçalho
var rCddopcao, rcddgrupo, cCddopcao, cTodosCabecalho, btnCab;

// Label/Campos Formulario Tarifas Por Canal
var cCaixa, cInternet, cTaa;

// Hiddens dos Custos Bilhetes Por Exercício Selecionados
var hdExercicio, hdIntegral,hdParcelado, CehNovo;


$(document).ready(function() {
//	controlaOperacao(operacao);
	estadoInicial();
    return false;

});


function estadoInicial() {

    formataCabecalho();

    // Remover class campoErro
    $('input,select', '#frmCab').removeClass('campoErro');

    cTodosCabecalho.limpaFormulario();
    cCddopcao.val(cddopcao);

    removeOpacidade('divTela');
    unblockBackground();
    hideMsgAguardo();

    $('#cddopcao', '#frmCab').habilitaCampo();
    $('#cddopcao', '#frmCab').focus();
}

function formataCabecalho() {

    // Cabecalho
    rCddopcao = $('label[for="cddopcao"]', '#' + frmCab);

    cCddopcao = $('#cddopcao', '#' + frmCab);
    cTodosCabecalho = $('input[type="text"],select', '#' + frmCab);
    btnCab = $('#btOK', '#' + frmCab);

    rCddopcao.css('width', '44px');

    cCddopcao.css({'width': '460px'});

    cTodosCabecalho.habilitaCampo();

    $('#cddopcao', '#' + frmCab).focus();

    layoutPadrao();
	if(operacao != ''){
		cCddopcao.desabilitaCampo();
		if(operacao == 'BT'){
			cCddopcao.val('BT');
		}
		else if(operacao == 'BC' || operacao == 'IC' || operacao == 'AC' || operacao == 'EC'){
			cCddopcao.val('BC');
		}
	}
    return false;
	
}

function btnVoltar() {
    estadoInicial();
    return false;
}

function controlaOperacao(operacao) {
	
	$('table > tbody > tr', 'div.divRegistros').each( function() {
		if ( $(this).hasClass('corSelecao') ) {
			hdExercicio = $('#hdExercicio', $(this) ).val();
			hdIntegral = $('#hdIntegral', $(this) ).val();
			hdParcelado = $('#hdParcelado', $(this) ).val();
		}
	});
	
	var mensagem = '';
	switch (operacao) {
		case 'GT': nrseqdig	= 0; mensagem = 'Aguarde, gravando tarifa ...'; break;
		case 'GC': nrseqdig	= 0; mensagem = 'Aguarde, gravando custo bilhete ...'; break;
	}
	showMsgAguardo( mensagem );
	switch(operacao) {
		case 'GT':
			$.ajax({
			type: "POST",
			url: UrlSite + "telas/prmdpv/grava_tarifa.php",
			data: {
				   caixa: $('#caixa','#frmTarifaPorCanal').val(),
				internet: $('#internet','#frmTarifaPorCanal').val(),
					 taa: $('#taa','#frmTarifaPorCanal').val(),
				redirect: "script_ajax"
			},
			error: function(objAjax, responseError, objExcept) {
				hideMsgAguardo();
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			},
			success: function(response) {
				try {
						controlaOperacao('BT');
						eval(response);
						return;
					} catch (error) {
						hideMsgAguardo();
						showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
					}
				}
			});
			break;
		case 'GC':
			if ($('#exercicio','#frmGravaCusto').val() == '') {
				hideMsgAguardo();
				showError('error', 'Exerc&iacute;cio n&atilde;o preenchido.', 'Alerta - Ayllos', 'unblockBackground()');
			}
			else if ($('#exercicio','#frmGravaCusto').val().length != 4)
			{
				hideMsgAguardo();
				showError('error', 'Exerc&iacute;cio inv&aacute;lido.', 'Alerta - Ayllos', 'unblockBackground()');
			}
			else
			{
				$.ajax({
				type: "POST",
				url: UrlSite + "telas/prmdpv/grava_custo.php",
				data: {
				   exercicio: $('#exercicio','#frmGravaCusto').val(),
					integral: $('#integral','#frmGravaCusto').val(),
				   parcelado: $('#parcelado','#frmGravaCusto').val(),
					  ehnovo: CehNovo,
					redirect: "script_ajax"
				},
				error: function(objAjax, responseError, objExcept) {
					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
				},
				success: function(response) {
					try {
							eval(response);
							return;
						} catch (error) {
							hideMsgAguardo();
							showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
						}
					}
				});
			}
			break;
		case 'EC':
			showConfirmacao("Voc&ecirc; tem certeza que deseja eliminar essa parametriza&ccedil;&atilde;o de custo bilhete?","Confirma&ccedil;&atilde;o - Ayllos","excluiCusto()","","sim.gif","nao.gif");
			break;
		default:
			// Carrega dados da conta através de ajax
			$.ajax({		
				type	: 'POST',
				dataType: 'html',
				url		: UrlSite + 'telas/prmdpv/principal.php', 
				data    : 
						{ 
							operacao: operacao,
						   exercicio: hdExercicio,
							integral: hdIntegral,
						   parcelado: hdParcelado,
							redirect: 'script_ajax' 
						},
				error   : function(objAjax,responseError,objExcept) {
							hideMsgAguardo();
							showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Anota','$(\'#nrdconta\',\'#frmCabAnota\').focus()');
						},
				success : function(response) { 
							hideMsgAguardo();
							if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
								try {
									$('#divPrmdpv').html(response);
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
			break;
	}
}

function excluiCusto() {
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/prmdpv/exclui_custo.php",
		data: {
			   exercicio: hdExercicio,
			redirect: "script_ajax"
		},
		error: function(objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
					controlaOperacao('BC');
					eval(response);
					return;
				} catch (error) {
					hideMsgAguardo();
					showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
				}
		}
	});
}

function realizaOperacao(opcao) {
	
	// Mostra mensagem de aguardo.
    if (opcao == "T") {
        showMsgAguardo("Aguarde, gravando tarifas...");
		caixa = cCaixa;
		internet = cInternet;
		taa = cTaa;
		
	}
    else if (opcao == "C") {
        showMsgAguardo("Aguarde, incluindo plano...");
    }
    
    if (caixa == '' || internet == '' || taa == '') {
        hideMsgAguardo();
        showError("error", "Informe o tipo de plano.", "Alerta - Ayllos", "focaCampoErro('tpplaseg', 'frmInfSeguradora')");
        return false;
    }
}

function controlaLayout() {
	
	if (operacao == 'BC'){
		var divRegistro = $('div.divRegistros');
		var tabela      = $('table', divRegistro );
		var linha       = $('table > tbody > tr', divRegistro );

		divRegistro.css('height','150px');

		altura  = '255px';
		largura = '400';

		var ordemInicial = new Array();
		ordemInicial = [[0,0]];

		var arrayLargura = new Array();
		arrayLargura[0] = '120px';
		arrayLargura[1] = '120px';
		arrayLargura[2] = '120px';	
		arrayLargura[3] = '10px';	

		var arrayAlinha = new Array();
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'center';
		arrayAlinha[2] = 'center';
		arrayAlinha[3] = 'center';

		tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');
	}
	else if (operacao == 'BT'){
		$("#caixa","#frmTarifaPorCanal").setMask('DECIMAL','zz9,99','.','');
		$("#internet","#frmTarifaPorCanal").setMask('DECIMAL','zz9,99','.','');
		$("#taa","#frmTarifaPorCanal").setMask('DECIMAL','zz9,99','.','');
	}
	else if (operacao == 'IC' || operacao == 'AC' ){
		$("#exercicio","#frmGravaCusto").setMask('INTEGER','9999','.','');
    $("#integral","#frmGravaCusto").setMask('DECIMAL','zz9,99','.','');
		$("#parcelado","#frmGravaCusto").setMask('DECIMAL','zz9,99','.','');
	}
    highlightObjFocus($('#' + frmCab));

    $('fieldset > legend').css({'font-size': '11px', 'color': '#777', 'margin-left': '5px', 'padding': '0px 2px'});
    $('fieldset').css({'clear': 'both', 'border': '1px solid #777', 'margin': '3px 0px', 'padding': '10px 3px 5px 3px'});

	$('#divTela').fadeTo(0, 0.1);
    $('#frmCab').css({'display': 'block'});

	formataCabecalho();

    // Remover class campoErro
    $('input,select', '#frmCab').removeClass('campoErro');

    removeOpacidade('divTela');
    unblockBackground();
    hideMsgAguardo();
	
}

function consultaInicial() { 	
	if(operacao == '')
		controlaOperacao($('#cddopcao','#frmCab').val());
};	
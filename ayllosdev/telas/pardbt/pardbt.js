/*!
 * FONTE        : pardbt.js
 * CRIAÇÃO      : Reginaldo Rubens da Silva (AMcom)         
 * DATA CRIAÇÃO : Março/2018
 * OBJETIVO     : Biblioteca de funções da tela PARDBT (Parametrização do Debitador Único)
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 *                
 */

// Definição de algumas variáveis globais 
var cddopcao		= 'C';
	
//Formulários
var frmCab   		= 'frmCab';
var frmDet          = 'frmDet';

//Labels/Campos do cabeçalho
var rCddopcao, rCdcoopex, cCddopcao, cCdcoopex, cTodosCabecalho, btnCab, subFolder;
var abaAtiva, horarioSelecionadoConsulta = 0;

$(document).ready(function() {
	estadoInicial();
	
	highlightObjFocus($('#'+frmCab));
	
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	
});

function limpaCabecalho() {
	$('#divCabecalho').empty();
}

function btnVoltar() {
	if ($('.checkboxAddHorario').length > 0) {
		carregarPrioridadesProcessos();
		return false;
	}
	else if (horarioSelecionadoConsulta != 0) {
		subFolder = 'horarios';
		horarioSelecionadoConsulta = 0;
		carregaDetalhamentoHorarios();
		return false;
	}

	estadoInicial();
}

function btnContinuar() {
	$('input,select', '#frmCab').removeClass('campoErro');

	switch(abaAtiva) {
		case 0:
			processaBotaoPrioridades();
			break;
		case 1:
			processaBotaoHorarios();
			break;
		case 2:
			processaBotaoEmergencial();
			break;
	}
}

function processaBotaoHorarios() {
	if (cCddopcao === undefined || cCddopcao.val() == '') {
		return false;
	}

	switch (cCddopcao.val()) {
		case 'I':
			gravarHorario();
			break;
	}
}

function processaBotaoEmergencial() {
	switch (cCddopcao.val()) {
		case 'I':
			executarEmergencial();
			break;
	}
}

function processaBotaoPrioridades() {
	switch (cCddopcao.val()) {
		case 'A':
			efetivaAtivacaoProcesso();
			break;
	}
}

function efetivaAtivacaoProcesso() {
	if ($('.checkboxAddHorario:checked', '#divConteudoOpcao').length == 0) {
		showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. <br>Nenhum hor&aacute;rio selecionado.",
			"Alerta - Ayllos", "");

		return false;
	}

	var listaHorarios = '';

	$('.checkboxAddHorario:checked', '#divConteudoOpcao').each(function (i, elem) {
		listaHorarios += 'X' + $(elem).parent().find('input[type="hidden"').first().val() + ',';
	});

	if (listaHorarios != '') {
		listaHorarios = listaHorarios.substr(0, listaHorarios.length - 1);
	}

	var cdprocesso = $('#cdprocesso', '#frmDet').val();

	$.ajax({
		type: "POST",
		url: UrlSite + "telas/pardbt/" + subFolder + "/manter_rotina.php",
		data: {
			horarios: listaHorarios,
			cdprocesso: cdprocesso,
			operacao: 'ATIVAR_PROCESSO',
			redirect: "script_ajax"
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.",
				"Alerta - Ayllos", 'unblockBackground()');
		},
		success: function (response) {
			hideMsgAguardo();

			try {
				eval(response);
			} catch (error) {
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,
					"Alerta - Ayllos", 'unblockBackground()');
			}
		}
	});
}

function efetivaDesativacaoProcesso(cdprocesso) {
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/pardbt/" + subFolder + "/manter_rotina.php",
		data: {
			cdprocesso: cdprocesso,
			operacao: 'DESATIVAR_PROCESSO',
			redirect: "script_ajax"
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.",
				"Alerta - Ayllos", 'unblockBackground()');
		},
		success: function (response) {
			hideMsgAguardo();

			try {
				eval(response);
			} catch (error) {
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,
					"Alerta - Ayllos", 'unblockBackground()');
			}
		}
	});
}

function executarEmergencial() {
	if ($('.checkboxExecutar:checked', '#divConteudoOpcao').length == 0) {
		showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. <br>Nenhum processo marcado para execu&ccedil;&atilde;o.",
			"Alerta - Ayllos", "");

		return false;
	}

	var listaProcessos = '';

	$('.checkboxExecutar:checked', '#divConteudoOpcao').each(function(i, elem) {
		listaProcessos += $(elem).parent().find('input[type="hidden"').first().val() + ',';
	});

	if (listaProcessos != '') {
		listaProcessos = listaProcessos.substr(0, listaProcessos.length - 1);
	}

	$.ajax({
		type: "POST",
		url: UrlSite + "telas/pardbt/" + subFolder + "/manter_rotina.php",
		data: {
			processos: listaProcessos,
			operacao: 'EXECUTAR_EMERGENCIAL',
			redirect: "script_ajax"
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.",
				"Alerta - Ayllos", 'unblockBackground()');
		},
		success: function (response) {
			hideMsgAguardo();

			try {
				eval(response);
			} catch (error) {
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,
					"Alerta - Ayllos", 'unblockBackground()');
			}
		}
	});
}

function gravarHorario() {
	var hh = null;
	var mm = null;
	var dhprocessamento = null;

	try {
		hh = parseInt($('#hh', '#frmDet').val());

		if(isNaN(hh) || hh < 0 || hh > 23) {
			throw 'Hora inválida.';
		}

		mm = parseInt($('#mm', '#frmDet').val());

		if(isNaN(mm) || mm < 0 || mm > 59) {
			throw 'Hora inv&aacute;lida.';
		}

		dhprocessamento = $('#hh', '#frmDet').val() + ':' + $('#mm', '#frmDet').val(); 		
	} catch(error) {
		showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error,
				          "Alerta - Ayllos","$('#hh').focus();");
		return false;
	}	

	var operacao = cCddopcao.val() == 'I' ? 'INCLUIR_HORARIO' : 'ALTERAR_HORARIO';
	
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/pardbt/" + subFolder + "/manter_rotina.php", 
		data: {
			idhora_processamento: $('#idhora_processamento', '#frmDet').val(),
			dhprocessamento: dhprocessamento,
			operacao: operacao,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.",
			          "Alerta - Ayllos",'unblockBackground()');
		},
		success: function(response) {
			hideMsgAguardo();
			
			try {				
				eval(response);
			} catch(error) {
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,
				          "Alerta - Ayllos",'unblockBackground()');
			}
		}				
	});
}

function gravarAlteracaoHorario() {
	carregaDetalhamentoHorarios();
}

function carregarHistorico(tporigem) {
	showMsgAguardo("Aguarde, buscando hist&oacute;ricos...");
	
	// Carrega dados parametro através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/pardbt/busca_dados_hist.php', 
		data    : { 
			tporigem	: tporigem,
			redirect	: 'script_ajax' 
		},
		error   : function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicialCab();');
		},
		success : function(response) { 
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {	
					$('#divDadosHistoricos')
						.html(response)
						.css({'display':'block'});
					
					formataHistoricos();
					
					hideMsgAguardo();
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
}

function carregarProcessos() {
	showMsgAguardo("Aguarde, buscando dados dos processos...");

	// Carrega dados parametro através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/pardbt/' + subFolder + '/carrega_processos.php',
		data: {
			redirect: 'script_ajax'
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicialCab();');
		},
		success: function (response) {
			if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
				try {
					$('#divConteudoOpcao')
						.html(response)
						.css({
							'display': 'block'
						});

					
					formataProcessos();
					trocaBotao('Executar');

					hideMsgAguardo();
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
}

function acessoOpcao() {
	if ($('#btnOK', '#frmCab').hasClass('botaoDesativado')) {
		return false;
	}

	showMsgAguardo("Aguarde, liberando aplica&ccedil;&atilde;o...");
	
	cddopcao = $("#cddopcao").val();
	
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/pardbt/acesso_opcao.php", 
		data: {
			cddopcao: cddopcao,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.",
			          "Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			hideMsgAguardo();
			
			try {				
				eval(response);
			} catch(error) {
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,
				          "Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});					

}

function trocaBotao( botao ) {
	$('#divBotoes','#divTela')
		.empty()
		.append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>');

	if ( botao != '') {
		$('#divBotoes','#divTela')
			.append('&nbsp;<a href="#" class="botao" onClick="btnContinuar(); return false;" >'+botao+'</a>');
	}
}

function carregaFormularioHorarios(id, horario) {
	showMsgAguardo("Aguarde, carregando formul&aacute;rio de cadastro de hor&aacute;rios...");

	// Carrega dados parametro através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/pardbt/' + subFolder + '/form_detalhe.php',
		data: {
			cddopcao: cddopcao,
			idhora_processamento: id,
			dhprocessamento: horario,
			redirect: 'script_ajax'
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
		},
		success: function (response) {
			if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
				try {
					$('#divConteudoOpcao')
						.html(response)
						.css({
							'display': 'block'
						});

					formataFormularioHorarios();
					hideMsgAguardo();
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
}

function alternarAtivo(cdprocesso, dsprocesso, ativo) {
	if (ativo == 'N') {
		carregaFormularioAtivarProc(cdprocesso, dsprocesso);
	}
	else {
		showConfirmacao('Confirmar a desativa&ccedil;&atilde;o do programa?', 'Confirma&ccedil;&atilde;o - Ayllos', 'efetivaDesativacaoProcesso(\'' + 
			            cdprocesso + '\');', '', 'sim.gif', 'nao.gif');
	}
}

function carregaFormularioAtivarProc(cdprocesso, dsprocesso) {
	showMsgAguardo("Aguarde, carregando formul&aacute;rio de ativação...");

	// Carrega dados parametro através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/pardbt/' + subFolder + '/form_ativar_processo.php',
		data: {
			cdprocesso: cdprocesso,
			dsprocesso: dsprocesso,
			redirect: 'script_ajax'
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
		},
		success: function (response) {
			if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
				try {
					$('#divConteudoOpcao')
						.html(response)
						.css({
							'display': 'block'
						});

					formataFormularioAtivarProc();
					hideMsgAguardo();
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
}

function redefinirPrioridade(cdprocesso, nrprioridade) {
	showMsgAguardo("Aguarde, redefinindo a prioridade do programa...");

	// Carrega dados parametro através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/pardbt/' + subFolder + '/manter_rotina.php',
		data: {
			cdprocesso: cdprocesso,
			nrprioridade: nrprioridade,
			operacao: 'REDEFINIR_PRIORIDADE',
			redirect: 'script_ajax'
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
		},
		success: function (response) {
			hideMsgAguardo();

			if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
				try {
					eval(response);					
				} catch (error) {
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
}

function formataFormularioHorarios() {
	$('#frmDet').css({
		'display': 'block'
	});

	$('fieldset', '#frmDet').css({
		'padding': '15px',
		'margin-top': '20px'
	});

	$('label[for="hh"]', '#frmDet').addClass('rotulo-linha').css('width', '51px');
	$('label[for="mm"]', '#frmDet').addClass('rotulo-linha').css({ 'width': '10px', 'text-align': 'center' });

	$('.campoHora').each(function (i, elem) {
		$(elem).bind('focus', function () {
			$(this).select();
		});
	});

	$('.campoHora').css('width', '25px').attr('maxlength', '2').setMask('INTEGER', '99', '', '');

	trocaBotao('Gravar');

	$('#hh', '#frmDet').focus();
}

function formataFormularioAtivarProc() {
	$('#frmDet').css({
		'display': 'block'
	});

	$('fieldset', '#frmDet').css({
		'padding': '15px',
		'margin-top': '20px'
	});

	$('label[for="dsprocesso"]', '#frmDet').addClass('rotulo').css('width', '180px');
	$('#dsprocesso', '#frmDet').css('width', '550px')

	var divRegistro = $('div.divRegistros', '#divConteudoOpcao');
	var tabela = $('table', divRegistro);
	var linha = $('table > tbody > tr', divRegistro);

	divRegistro.css({ 'height': '220px', 'width': '100%' });

	var ordemInicial = new Array();

	var arrayLargura = ['100%'];

	var arrayAlinha = ['center'];

	var metodoTabela = '';

	tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

	trocaBotao('Ativar');
}

function formataHorariosExluir() {
	var divRegistro = $('div.divRegistros', '#frmDet');
	var tabela = $('table', divRegistro);
	var linha = $('table > tbody > tr', divRegistro);

	divRegistro.css({ 'height': '140px', 'width': '100%' });

	var ordemInicial = new Array();

	var arrayLargura = ['100%'];

	var arrayAlinha = ['center'];

	var metodoTabela = '';

	tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);
}

function carregaDetalhamentoHorarios(){	
	showMsgAguardo("Aguarde, buscando hor&aacute;rios...");
		
	cddopcao = $('#cddopcao','#frmCab').val();
	
	// Carrega dados parametro através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/pardbt/' + subFolder + '/busca_dados.php', 
		data    : { 
			cddopcao	: cddopcao,
			redirect	: 'script_ajax' 
		},
		error   : function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicialCab();');
		},
		success : function(response) { 
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {	
					$('#divConteudoOpcao')
						.html(response)
						.css({'display':'block'});
					
					formataHorarios();
					
					hideMsgAguardo();
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
}

function carregaProcessosHorario(id) {
	horarioSelecionadoConsulta = id;

	subFolder = 'prioridades';

	carregarPrioridadesProcessos();
}

function carregarPrioridadesProcessos(nrprioridade) {
	showMsgAguardo("Aguarde, buscando prioridades dos programas...");

	cddopcao = $('#cddopcao', '#frmCab').val();

	var arquivo = '/busca_dados.php'; // Consultar

	if (cddopcao == 'A') {
		arquivo = '/carrega_prioridades.php'; // Alterar
	}

	// Carrega dados parametro através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/pardbt/' + subFolder + arquivo,
		data: {
			idhora_processamento: horarioSelecionadoConsulta, 
			redirect: 'script_ajax'
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicialCab();');
		},
		success: function (response) {
			if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
				try {
					$('#divConteudoOpcao')
						.empty()
						.html(response)
						.css({
							'display': 'block'
						});

					formataPrioridades();

					if (nrprioridade != null) {
						$('.divRegistros').find('tr').each(function(i, elem) {
							var prioridadeTr = $(elem).find('input[name="nrprioridade"]').val();

							if (prioridadeTr == nrprioridade) {
								$(elem).click();
							}
						});
					}

					hideMsgAguardo();
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
}

function excluirHorariosProc() {
	if ($('.checkboxDelHorario:checked', '#frmDet').length == $('.checkboxDelHorario', '#frmDet').length) {
		showError('error', 'N&atilde;o &eacute; poss&iacute;vel excluir todos os hor&aacute;rios de um processo.', 'Alerta - Ayllos', '');
		return false;
	}

	showConfirmacao('Confirmar exclus&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'processarExclusaoHorarios();', '', 'sim.gif', 'nao.gif');
}

function excluirHorarioProc(cdprocesso) {
	showMsgAguardo('Aguarde, abrindo exclus&atilde;o de hor&aacute;rio(s)...');

	exibeRotina($('#divUsoGenerico'));

	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/pardbt/' + subFolder + '/form_exclusao_horario.php',
		data: {
			cdprocesso: cdprocesso,
			redirect: 'html_ajax'
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'N&atilde;o foi poss&iacute;&shy;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function (response) {
			if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
				$('#divUsoGenerico').html(response);
				layoutPadrao();
				hideMsgAguardo();
				bloqueiaFundo($('#divUsoGenerico'));
				formataHorariosExluir();
			}
			else {
				try {
					eval(response);
				} catch (error) {
					hideMsgAguardo();
					showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
				}
			}
		}
	});
}

function adicionarHorarioProc(cdprocesso) {
	showMsgAguardo('Aguarde, abrindo inclus&atilde;o de hor&aacute;rio...');

	exibeRotina($('#divUsoGenerico'));

	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/pardbt/' + subFolder + '/form_inclusao_horario.php',
		data: {
			cdprocesso: cdprocesso,
			redirect: 'html_ajax'
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'N&atilde;o foi poss&iacute;&shy;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function (response) {
			if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
				$('#divUsoGenerico').html(response);
				layoutPadrao();
				hideMsgAguardo();
				bloqueiaFundo($('#divUsoGenerico'));
			}
			else {
				try {
					eval(response);
				} catch (error) {
					hideMsgAguardo();
					showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
				}
			}
		}
	});
}

function gravarNovoHorarioProc() {
	showMsgAguardo('Aguarde, gravando hor&aacute;rio...');

	var idhora_processamento = $('#idhora_processamento', '#frmDet').val();
	var cdprocesso = $('#cdprocesso', '#frmDet').val();
	
	if (idhora_processamento == '') {
		showError('error', 'Selecione o hor&aacute;rio que deseja adicionar.', 'Alerta - Ayllos', '$(\'#idhora_processamento\',\'#frmDet\').focus();');
	}

	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/pardbt/' + subFolder + '/manter_rotina.php',
		data: {
			cdprocesso: cdprocesso,
			horarios: idhora_processamento,
			operacao: 'INCLUIR_HORARIO_PROC',
			redirect: 'html_ajax'
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'N&atilde;o foi poss&iacute;&shy;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
		},
		success: function (response) {
			if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
				hideMsgAguardo();

				try {
					eval(response);
				} catch (error) {
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
}

function processarExclusaoHorarios() {
	if ($('.checkboxDelHorario:checked', '#frmDet').length == 0) {
		showError('error', 'Selecione o(s) hor&aacute;rio(s) que deseja excluir.', 'Alerta - Ayllos', '');
	}

	showMsgAguardo('Aguarde, excluindo hor&aacute;rio(s)...');

	var cdprocesso = $('#cdprocesso', '#frmDet').val();

	var listaHorarios = '';

	$('.checkboxDelHorario:checked', '#frmDet').each(function (i, elem) {
		listaHorarios += 'X' + $(elem).parent().find('input[type="hidden"').first().val() + ',';
	});

	if (listaHorarios != '') {
		listaHorarios = listaHorarios.substr(0, listaHorarios.length - 1);
	}

	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/pardbt/' + subFolder + '/manter_rotina.php',
		data: {
			cdprocesso: cdprocesso,
			horarios: listaHorarios,
			operacao: 'EXCLUIR_HORARIO_PROC',
			redirect: 'html_ajax'
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'N&atilde;o foi poss&iacute;&shy;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
		},
		success: function (response) {
			if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
				hideMsgAguardo();

				try {
					eval(response);
				} catch (error) {
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
}

function formataHorarios() {
	var divRegistro = $('div.divRegistros','#divConteudoOpcao');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'250px','width':'100%'});
	
	var ordemInicial = new Array();
	
	var arrayLargura = ['100%'];	
		
	var arrayAlinha = ['center'];	
	
	var metodoTabela = '';
			
	tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

	cddopcao = cCddopcao.val();
			
	if (cddopcao == 'A') {
		// Carrega o formulário de alteração para o registro clicado
		$('table > tbody > tr', divRegistro).click( function() {
			carregaFormularioHorarios($(this).find('input[name="idhora_processamento"]').val(), $(this).find('span').text());
		});
	}
	else if (cddopcao == 'E') {
		// Carrega o formulário de exclusão para o registro clicado
		$('table > tbody > tr', divRegistro).click(function () {
			processarExclusaoHorario($(this).find('input[name="idhora_processamento"]').val());
		});
	}	
}

function formataProcessos() {
	var divRegistro = $('div.divRegistros', '#divConteudoOpcao');
	var tabela = $('table', divRegistro);
	var linha = $('table > tbody > tr', divRegistro);

	divRegistro.css({
		'height': '250px',
		'width': '100%'
	});

	var ordemInicial = new Array();
	ordemInicial = [
		[0, 0]
	];

	var arrayLargura = ['60px', '', '50px'];

	var arrayAlinha = ['center', 'left', 'center'];

	var metodoTabela = '';

	tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

	$('#execTodos', '#divConteudoOpcao').parent().attr('class', '');
	$('#execTodos', '#divConteudoOpcao').parent().unbind();
}

function formataPrioridades() {
	var divRegistro = $('div.divRegistros', '#divConteudoOpcao');
	var tabela = $('table', divRegistro);
	var linha = $('table > tbody > tr', divRegistro);

	divRegistro.css({
		'height': '350px',
		'width': '100%'
	});

	var ordemInicial = new Array();
	
	var arrayLargura = ['50px', '315px', '54px', '42px', '42px', '42px', '190px'];

	var alinhaPrioridade = cCddopcao.val() == 'C' ? 'right' : 'left';

	var arrayAlinha = [alinhaPrioridade, 'left', 'center', 'center', 'center', 'center', 'center'];

	var metodoTabela = '';

	tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

	// Desabilita evento de ordenação das colunas ta tabela
	$('.tituloRegistros').find('th').each(function (i, elem) {
		$(elem).attr('class', '').unbind();
	});

	// Desabilita evento de ordenação das colunas ta tabela
	$('.divRegistros').find('th').each(function (i, elem) {
		$(elem).attr('class', '').unbind();
	});

	// Remove coluna adicional para corrigir alinhamento do cabeçalho com as colunas da tabela
	$('.divRegistros').find('tbody').first().find('tr').each(function(i, elem) {
		$(elem).find('td').eq(7).detach();
	});
}

function marcarExecutarTodos(e) {	
	$('.checkboxExecutar', '#divConteudoOpcao').each(function(i, elem) {
		$(elem).prop('checked', $('#execTodos', '#divConteudoOpcao').prop('checked'));
	});
}

function formataHistoricos() {
	var divRegistro = $('div.divRegistros','#divConteudoOpcao');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'330px','width':'100%'});
	
	var ordemInicial = new Array();
	ordemInicial = [];	
	
	var arrayLargura = ['120px', '100px', '80px', '483px'];	
		
	var arrayAlinha = ['center', 'center', 'center', 'left'];	
			
	tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');	

	// Desabilita evento de ordenação das colunas ta tabela
	$('.tituloRegistros').find('th').each(function (i, elem) {
		$(elem).attr('class', '').unbind();
	});

	// Desabilita evento de ordenação das colunas ta tabela
	$('.divRegistros').find('th').each(function (i, elem) {
		$(elem).attr('class', '').unbind();
	});
}

function processarExclusaoHorario(id) {
	showConfirmacao('Confirmar exclus&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'excluirHorario(' + id + ');', '', 'sim.gif', 'nao.gif');
}

function excluirHorario(id) {
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/pardbt/" + subFolder + "/manter_rotina.php", 
		data: {
			idhora_processamento: id,
			operacao: 'EXCLUIR_HORARIO',
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.",
			          "Alerta - Ayllos", "");
		},
		success: function(response) {
			hideMsgAguardo();
			
			try {				
				eval(response);
			} catch(error) {
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,
				          "Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});
}

function bindKeyPressEvent(sourceElem, targetElem, functionCall)
{
	sourceElem.unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			e.preventDefault()
			if (functionCall != null) {
				eval(functionCall);
			}
			if (targetElem != null) {
				targetElem.focus();
			}
		}
	})
}

function controlaFocoCab() {
	bindKeyPressEvent($('#cddopcao', '#' + frmCab), $('#btnOK', '#' + frmCab));
}

function formataCamposCab() {
	$('label[for="cddopcao"]', '#' + frmCab).css('width', '71px');

	cCddopcao = $('#cddopcao', '#' + frmCab);
	cTodosCabecalho = $('input[type="text"],select', '#' + frmCab);
	btnCab = $('#btOK', '#' + frmCab);

	cCddopcao.css({
		'width': '460px'
	});

	cTodosCabecalho.habilitaCampo();

	controlaFocoCab();

	cCddopcao.focus();

	layoutPadrao();
}

function estadoInicial() {
	$('#divTela').fadeTo(0,0.1);

	$('#' + frmCab).css({
		'display': 'block'
	});

	$('#divBotoes').css({'display':'none'});

	$('#divConteudoOpcao').empty();
	$('#divAbas').hide();
			
	formataCamposCab();
		
	cTodosCabecalho.limpaFormulario();
	
	removeOpacidade('divTela');	
	unblockBackground();
	hideMsgAguardo();
	
	trocaBotao('');
	$("#btVoltar","#divBotoes").hide();
	
	$('input,select', '#frmCab').removeClass('campoErro');
	$('#btnOK', '#frmCab').removeClass('botaoDesativado').addClass('botao');
}

function carregaOpcoes()
{
	if ($('#btnOK', '#frmCab').hasClass('botaoDesativado')) {
		return false;
	}

	// Desabilita campo opção
	cTodosCabecalho = $('input[type="text"],select', '#frmCab');
	cTodosCabecalho.desabilitaCampo();
	
	cddopcao = $('#cddopcao', '#frmCab').val();

	switch (cddopcao) {
		case 'C':
			acessaOpcaoAba(0);
			break;
		case 'I':
			acessaOpcaoAba(1);
			break;
		case 'A':
			acessaOpcaoAba(0);
			break;
		case 'E':
			acessaOpcaoAba(1);
	}

	$('#divBotoes').css({ 'display': 'block' });
	trocaBotao('');
	$('#btnOK', '#frmCab').removeClass('botao').addClass('botaoDesativado');
}

function acessaOpcaoAba(aba) {
	var opcoesMenu = 'CIAE';

	var cddopcao = $('#cddopcao', '#frmCab').val();

	/*
	  Matriz de permissão das abas de acordo com a opção do menu.
	  permissoesOpcoes[<cddopcao>][<numeroaba>] = 1 (permite acesso)
	*/
	var permissoesOpcoes = [
		[1, 1, 0, 1],
		[0, 1, 1, 0],
		[1, 0, 0, 0],
		[0, 1, 0, 0]
	];

	if (permissoesOpcoes[opcoesMenu.indexOf(cddopcao)][aba] != 1) {
		showError('inform','Op&ccedil;&atilde;o n&atilde;o aplic&aacute;vel a esta aba.', 'Alerta - Ayllos', '');
		return false;
	}

	abaAtiva = aba;
	horarioSelecionadoConsulta = 0;

	$('#divAbas').show();

	for (var i = 0; i < 4; i++) {
		if (aba == i) { 
			$("#linkAba" + aba).attr("class", "txtBrancoBold");
			$("#imgAbaEsq" + aba).attr("src", UrlImagens + "background/mnu_sle.gif");
			$("#imgAbaDir" + aba).attr("src", UrlImagens + "background/mnu_sld.gif");
			$("#imgAbaCen" + aba).css("background-color", "#969FA9");
			continue;
		}

		$("#linkAba" + i).attr("class", "txtNormalBold");
		$("#imgAbaEsq" + i).attr("src", UrlImagens + "background/mnu_nle.gif");
		$("#imgAbaDir" + i).attr("src", UrlImagens + "background/mnu_nld.gif");
		$("#imgAbaCen" + i).css("background-color", "#C6C8CA");
	}

	switch (aba) {
		case 0: // Prioridades
			subFolder = 'prioridades';

			carregarPrioridadesProcessos();
			break;
		case 1: // Horários
			subFolder = 'horarios';
			
			switch (cCddopcao.val()) {
				case 'C':  // Consulta
				case 'E':  // Exclusão
					carregaDetalhamentoHorarios();
					break;
				case 'I': // Inclusão
					carregaFormularioHorarios();
			}
			break;
		case 2: // Execução emergencial
			subFolder = 'emergencial';
			
			if (cCddopcao.val() == 'I') {
				carregarProcessos();
			}
			break;
		case 3: // 
			carregarAbaHistoricos();
	}
}

function carregarAbaHistoricos() {
	$('#divConteudoOpcao').load(UrlSite + "telas/pardbt/aba_historicos.php");
	$('label[for="tporigem"]', '#divSelecaoOrigem').css('width', '71px');
	carregarHistorico(1);
}

function carregarDadosHistoricos() {
	var tporigem = parseInt($('#tporigem', '#divSelecaoOrigem').val());

	carregarHistorico(tporigem);
}
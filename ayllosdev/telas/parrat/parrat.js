/*
 * FONTE        : parrat.php
 * CRIAÇÃO      : Luiz Otávio Olinger Momm - AMcom
 * DATA CRIAÇÃO : 24/01/2019
 * OBJETIVO     : Biblioteca de funções da tela PARRAT
 * ---------------
 * ALTERAÇÕES   : 25/02/2019 - Adicionado o campo "Habilitar contingência"
 *                             P450 - Luiz Otávio Olinger Momm (AMCOM)
 *                04/03/2019 - Adicionado o campo "Habilitar sugestão" para as cooperativas
 *                             P450 - Luiz Otávio Olinger Momm (AMCOM)
 *                14/05/2019 - Retirado o filtro inpessoa da pesquisa a alteração. Vamos sempre atualizar os dois tipos de produtos
 *                             P450 - Luiz Otávio Olinger Momm (AMCOM)
 *                06/06/2019 - Adicionado o parâmetro Birô por cooperativa.
 *                             P450 - Luiz Otávio Olinger Momm (AMCOM)
 *                14/08/2019 - Adicionado a opção Modelo Cálculo Rating
 *                             P450 - Luiz Otávio Olinger Momm (AMCOM)
 * ---------------
 

// Inicia a tela com carregando e ocultando os elementos necessários
estadoInicial();
 
// Carrega os formularios do form_parrat.php
acessaAbaParametros();

// Formata campos do form_cabecalho_parametros.php
formataCabecalho();

// Formata campos do form_parrat.php
formataCampos();

// Botao OK do Cabeçalho
controlaOperacao();


 
 */

$(document).ready(function() {
	estadoInicial();
});

// Controles
function estadoInicial() {
	$('#frmPARRAT').hide();
	$('#frmPARRATHabilitar').hide();

	// Variáveis Globais
	operacao = '';

	hideMsgAguardo();

	fechaRotina($('#divRotina'));

	// Atribuir destaque para a primeira aba
	$('#linkAba0').attr('class','txtBrancoBold');
	$('#imgAbaCen0').css('background-color','#969FA9');

	// Acessar a primeira aba
	acessaAbaParametros();

	// Coloca em highlight o formulário do cabeçalho
	highlightObjFocus($('#frmCab'));
	
	$('#cddopcao', '#frmCab').val('C');
}

function formataCabecalho() {

	cTodosCabecalho = $('input[type="text"],input[type=checkbox],select', '#frmCab');

	// Cabeçalho
	$('label[for="cddopcao"]', '#frmCab').css('width', '42px');
	$('#cddopcao', '#frmCab').css({'width': '560px'});

	$('label[for="formPesquisa_pr_tpproduto"]', '#frmCab').css('width', '80px');
	$('#formPesquisa_pr_tpproduto', '#frmCab').css({'width': '295px'});

	$('label[for="formPesquisa_pr_cooperat"]', '#frmCab').css('width', '85px');
	$('#formPesquisa_pr_cooperat', '#frmCab').css({'width': '100px'});

	cTodosCabecalho.habilitaCampo();

	// ao chamar a tela pela primeira vez é carregado em um objeto para não fazer a pesquisa a cada evento.
	$.each(opcoesCooperativas, function (i, item) {
		$('#formPesquisa_pr_cooperat', '#frmCab').append($('<option>', { 
			value: i,
			text : item 
		}));
	});
	// ao chamar a tela pela primeira vez é carregado em um objeto para não fazer a pesquisa a cada evento.

	$('#divBotoes').hide();
	$('#divConteudoOpcao').html('');

	return false;
}

function formataCampos() {
	$('.labelPri', '#frmPARRAT').css('width', '340px');
	$('.labelPri', '#frmPARRATHabilitar').css('width', '340px');

	layoutPadrao();
	controlaFoco();
	removeOpacidade('divTela');

	return false;
}

function controlaFoco() {
	$('#cddopcao', '#frmCab').unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			$('#btnOK', '#frmCab').focus();
			return false;
		}
	});

	$('#btnOK', '#frmCab').unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			controlaOperacao();
			return false;
		}
	});
}

function controlaOperacao() {
	if ($('#cddopcao', '#frmCab').hasClass('campoTelaSemBorda')) {
		return false;
	}
	mostraConsultaParametros();
	return false;
}

function parrat_alterar() {
	showConfirmacao('Confirma a Opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'parrat_salvar();', '', 'sim.gif', 'nao.gif');
}

function parrat_consultar() {
	showMsgAguardo('Aguarde, efetuando solicita&ccedil;&atilde;o...');
	var cddopcao = $('#cddopcao', '#frmCab').val();

/*
	if (cddopcao == 'P') {
		$('#frmPARRAT').hide();
		$('#frmPARRATHabilitar').show();
	} else {
		$('#frmPARRAT').show();
		$('#frmPARRATHabilitar').hide();
	}
*/
	$.ajax({
		type: 'POST',
		async: true,
		url: UrlSite + 'telas/parrat/manter_rotina.php',
		data: {
			consultarAcao : cddopcao,
			formPesquisa_pr_tpproduto : $("#formPesquisa_pr_tpproduto").val(),
			formPesquisa_pr_cooperat : $("#formPesquisa_pr_cooperat").val(),
			redirect: 'script_ajax'
		},
		error: function(objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'estadoInicial();');
		},
		success: function(response) {
			hideMsgAguardo();
			if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
				try {
					parrat_operacao();
					eval(response);
				} catch (error) {
					console.log('2');
					showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'estadoInicial();');
				}
			} else {
				try {
					eval(response);
				} catch (error) {
					showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'estadoInicial();');
				}
			}
		}
	});
}

function parrat_salvarModelo() {
	var coopModelo = [];
	$("select.campo_inmodelo option:selected").each(function() {
		var inmodelo = $(this).val();
		var cdcooper = $(this).parent().data('cdcooper');
		coopModelo.push({
			inmodelo: inmodelo,
			cdcooper: cdcooper
		});
	});

	if (coopModelo.length > 0) {
		showMsgAguardo('Aguarde, efetuando solicita&ccedil;&atilde;o...');
		$.ajax({
			type: 'POST',
			async: true,
			url: UrlSite + 'telas/parrat/manter_rotina.php',
			data: {
				salvarAcao: 'M',
				dados     : coopModelo,
				redirect  : 'script_ajax'
			},
			error: function(objAjax, responseError, objExcept) {
				hideMsgAguardo();
				showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'estadoInicial();');
			},
			success: function(response) {
				hideMsgAguardo();
				if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
					try {
						eval(response);
					} catch (error) {
						showError('error', 'N&atilde; foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'estadoInicial();');
					}
				} else {
					try {
						eval(response);
					} catch (error) {
						showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'estadoInicial();');
					}
				}
			}
		});
	}
}

function parrat_salvarBiro() {

	var coopInbiro = [];
	$("select.campo_inbiro option:selected").each(function() {
		var inbiro = $(this).val();
		var cdcooper = $(this).parent().data('cdcooper');
		coopInbiro.push({
			inbiro  : inbiro,
			cdcooper: cdcooper
		});
	});

	if (coopInbiro.length > 0) {
		showMsgAguardo('Aguarde, efetuando solicita&ccedil;&atilde;o...');
		$.ajax({
			type: 'POST',
			async: true,
			url: UrlSite + 'telas/parrat/manter_rotina.php',
			data: {
				salvarAcao: 'B',
				dados     : coopInbiro,
				redirect  : 'script_ajax'
			},
			error: function(objAjax, responseError, objExcept) {
				hideMsgAguardo();
				showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'estadoInicial();');
			},
			success: function(response) {
				hideMsgAguardo();
				if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
					try {
						eval(response);
					} catch (error) {
						showError('error', 'N&atilde; foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'estadoInicial();');
					}
				} else {
					try {
						eval(response);
					} catch (error) {
						showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'estadoInicial();');
					}
				}
			}
		});
	}
}

function parrat_salvar() {

	var cddopcao = $('#cddopcao', '#frmCab').val();

	/* Para salvar alteração de Biro */
	if (cddopcao == 'B') {
		parrat_salvarBiro();
		return false;
	}
	/* Para salvar alteração de Biro */

	/* Para salvar alteração de Biro */
	if (cddopcao == 'M') {
		parrat_salvarModelo();
		return false;
	}
	/* Para salvar alteração de Biro */


	hideMsgAguardo();

	var arr_idnivel_risco_permite_reducao = [];
	$('.idnivel_risco_permite_reducao:checked').each(function() {
		arr_idnivel_risco_permite_reducao.push($(this).val());
	});

	var frm_qtdias_niveis_reducao = $('#frm_qtdias_niveis_reducao', '#frmPARRAT').val();
	var frm_idnivel_risco_permite_reducao = arr_idnivel_risco_permite_reducao;
	var frm_qtdias_atencede_atualizacao = $('#frm_qtdias_atencede_atualizacao', '#frmPARRAT').val();
	var frm_qtmeses_expiracao_nota = $('#frm_qtmeses_expiracao_nota', '#frmPARRAT').val();
	var frm_qtdias_atual_autom_baixo = $('#frm_qtdias_atual_autom_baixo', '#frmPARRAT').val();
	var frm_qtdias_atual_autom_medio = $('#frm_qtdias_atual_autom_medio', '#frmPARRAT').val();
	var frm_qtdias_atual_autom_alto = $('#frm_qtdias_atual_autom_alto', '#frmPARRAT').val();
	var frm_qtdias_atual_manual = $('#frm_qtdias_atual_manual', '#frmPARRAT').val();
	var frm_cooperat = $('#frm_cooperat', '#frmPARRAT').val();
	var frm_incontingencia = $('#frm_incontingencia', '#frmPARRAT').val();
	var frm_inpermite_alterar = $('#frm_inpermite_alterar', '#frmPARRATHabilitar').val();

	var mensagem = 'Aguarde, efetuando solicita&ccedil;&atilde;o...';
	showMsgAguardo(mensagem);

	$.ajax({
		type: 'POST',
		async: true,
		url: UrlSite + 'telas/parrat/manter_rotina.php',
		data: {
			salvarAcao : cddopcao,
			formPesquisa_pr_tpproduto : $("#formPesquisa_pr_tpproduto").val(),
			formPesquisa_pr_cooperat : $("#formPesquisa_pr_cooperat").val(),
			ajx_frm_qtdias_niveis_reducao : frm_qtdias_niveis_reducao,
			ajx_frm_idnivel_risco_permite_reducao : frm_idnivel_risco_permite_reducao,
			ajx_frm_qtdias_atencede_atualizacao : frm_qtdias_atencede_atualizacao,
			ajx_frm_qtmeses_expiracao_nota : frm_qtmeses_expiracao_nota,
			ajx_frm_qtdias_atual_autom_baixo : frm_qtdias_atual_autom_baixo,
			ajx_frm_qtdias_atual_autom_medio : frm_qtdias_atual_autom_medio,
			ajx_frm_qtdias_atual_autom_alto : frm_qtdias_atual_autom_alto,
			ajx_frm_qtdias_atual_manual : frm_qtdias_atual_manual,
			ajx_frm_cooperat : frm_cooperat,
			ajx_frm_incontingencia : frm_incontingencia,
			ajx_frmPARRATHabilitar : frm_inpermite_alterar,
			redirect: 'script_ajax'
		},
		error: function(objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'estadoInicial();');
		},
		success: function(response) {
			hideMsgAguardo();
			if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
				try {
					eval(response);
				} catch (error) {
					showError('error', 'N&atilde; foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'estadoInicial();');
				}
			} else {
				try {
					eval(response);
				} catch (error) {
					showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'estadoInicial();');
				}
			}
		}
	});

	return false;
}

function acessaAbaParametros(){
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/parrat/form_cabecalho_parametros.php", 
		data: {
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function(response) {
			$("#divCabecalho").html(response);
			formataCabecalho();
		}
	});
}

function mostraConsultaParametros() {
	var cddopcao = $('#cddopcao', '#frmCab').val();
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/parrat/form_parrat.php",
		data: {
			cddopcao: cddopcao,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			$("#divBotoes").show();
			$("#btContinuar", "#divBotoes").hide();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function(response) {
			$("#divConteudoOpcao").html(response);
			formataCampos();
			parrat_consultar();
		}
	});
}

function selecionaCheckboxPorClasse(elementoClasse, valor) {
	var elemento = $(elementoClasse);
	elemento.each(function() {
		if ($(this).val() == valor) {
			$(this).prop('checked', true);
		}
	});
}

function parrat_operacao() {
	
	var cddopcao = $('#cddopcao', '#frmCab').val();
	var cParratParametros = $('#frmPARRAT').find('input, textarea, button, select');
	var cParratPermissao = $('#frmPARRATHabilitar').find('input, textarea, button, select');
	var cParratBiro = $('#frmBIRO').find('input, textarea, button, select');
	var cParratModelo = $('#frmMODELO').find('input, textarea, button, select');
	var cFormCab = $("#frmCab").find('input, textarea, button, select');
	cFormCab.desabilitaCampo();

	cParratParametros.limpaFormulario();
	if (cddopcao == 'A') {
		cParratParametros.habilitaCampo();
		$("#divBotoes").show();
		$("#btContinuar", "#divBotoes").show();

		$('#frmPARRAT').show();

	} else if (cddopcao == 'C') {
		cParratParametros.desabilitaCampo();
		$("#divBotoes").show();
		$("#btContinuar", "#divBotoes").hide();
		
		$('#frmPARRAT').show();
		$('#frmPARRATHabilitar').hide();

	} else if (cddopcao == 'P') {
		cParratParametros.desabilitaCampo();
		cParratPermissao.habilitaCampo();
		$("#divBotoes").show();
		// $("#btContinuar", "#divBotoes").hide();

		$('#frmPARRAT').hide();
		$('#frmPARRATHabilitar').show();
		
	} else if (cddopcao == 'B') {
		cParratParametros.desabilitaCampo();
		cParratBiro.habilitaCampo();
		$("#divBotoes").show();

	} else if (cddopcao == 'M') {
		cParratParametros.desabilitaCampo();
		cParratModelo.habilitaCampo();
		console.log('oi');
		$("#divBotoes").show();
	}
}

function parrat_trataCab() {
	var cddopcao = $('#cddopcao', '#frmCab').val();
	if (cddopcao == 'P') {
		$('label[for="formPesquisa_pr_tpproduto"]', '#frmCab').hide();
		$('#formPesquisa_pr_tpproduto', '#frmCab').hide();

		$('label[for="formPesquisa_pr_cooperat"]', '#frmCab').show();
		$('#formPesquisa_pr_cooperat', '#frmCab').show()
	} else if (cddopcao == 'B' || cddopcao == 'M') {
		$('label[for="formPesquisa_pr_tpproduto"]', '#frmCab').hide();
		$('#formPesquisa_pr_tpproduto', '#frmCab').hide()

		$('label[for="formPesquisa_pr_cooperat"]', '#frmCab').hide();
		$('#formPesquisa_pr_cooperat', '#frmCab').hide();
	} else {
		$('label[for="formPesquisa_pr_tpproduto"]', '#frmCab').show();
		$('#formPesquisa_pr_tpproduto', '#frmCab').show()

		$('label[for="formPesquisa_pr_cooperat"]', '#frmCab').show();
		$('#formPesquisa_pr_cooperat', '#frmCab').show();
	}
}
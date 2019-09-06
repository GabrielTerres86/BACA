/*
 * FONTE        : ratmov.js
 * CRIAÇÃO      : Luiz Otávio Olinger Momm - AMcom
 * DATA CRIAÇÃO : 29/01/2019
 * OBJETIVO     : Biblioteca de funções da tela RATMOV
 * ---------------
 * ALTERAÇÕES
 * 001: [28/03/2019] - P450 - Alteração na visualização da consulta do Alterar Rating P450 (Luiz Otávio Olinger Momm - AMCOM).
 *
 * ---------------
 */

// Variáveis Globais 
var operacao = '';
var cddopcao = '';

var frmCab = 'frmCab';

var cTodosCabecalho = '';
var cTodosFiltro = '';

var abaAtual = '';

// Array para editar e enviar os dados para o envios
var dadosRating = [];

// objeto para iniciar o timer para atualizar os ratings quando tiver retorno da base
var timerRating;


$(document).ready(function() {
	estadoInicial();
});

// Controles
function estadoInicial() {

	// Variáveis Globais
	operacao = '';

	hideMsgAguardo();

	fechaRotina($('#divRotina'));
	$('#fsListagem').hide();

	// Atribuir destaque para a primeira aba
	$('#linkAba0').attr('class','txtBrancoBold');
	$('#imgAbaCen0').css('background-color','#969FA9');

	// Acessar a primeira aba
	carregaHTMLPesquisaResultados();

	// Habilita foco no formulário inicial
	highlightObjFocus($('#frmCab'));
	focoOperacao();
}

function formataCabecalho() {

	cTodosCabecalho = $('input[type="text"],input[type=checkbox],select', '#' + frmCab);

	// Cabeçalho
	$('label[for="cddopcao"]', '#frmCab').css('width', '135px');
	$('#cddopcao', '#frmCab').css({'width': '500px'});

	// Filtros
	$('label[for="nrdconta"]', '#filtros').addClass('rotulo-linha').css('width', '165px');
	$('#nrdconta', '#filtros').css({'width': '100'}).addClass('conta pesquisa');

	$('label[for="nrctro"]', '#filtros').addClass('rotulo-linha').css('width', '75px');
	$('#nrctro', '#filtros').css({'width': '100px'}).addClass('inteiro').attr('maxlength','14');

	$('label[for="nrcpfcgc"]', '#filtros').addClass('rotulo-linha').css('width', '70px');
	$('#nrcpfcgc', '#filtros').css({'width': '120px'});

	$('label[for="tpprod"]', '#filtros').css('width', '165px');

	$('label[for="fldtinic"]', '#filtros').css('width', '165px');
	$('#fldtinic', '#filtros').css({'width': '120px'}).addClass('data');

	$('label[for="fldtfina"]', '#filtros').css('width', '150px');
	$('#fldtfina', '#filtros').css({'width': '120px'}).addClass('data');
	
	$('label[for="prstatus"]', '#filtros').css('width', '165px');
	$('#prstatus', '#filtros').css({'width': '120px'}).addClass('campo');

	$('#contratoLiquidado', '#filtros').css('padding-left', '165px').css('line-height', '25px').css('vertical-align','middle').css('display','table-cell');
	$('#contratoLiquidado > input[type="checkbox"]', '#filtros').css('margin', '5px 5px 0px 5px');

	cTodosCabecalho.habilitaCampo();
	// $('#fldtinic, #fldtfina').val(datahoje);

	cTodosFiltro = $('#filtros').find('input, textarea, button, select');
	// Limpa formulário
	cTodosFiltro.limpaFormulario();
	cTodosFiltro.desabilitaCampo();
	desabilitaLupas();
	$('#filtros').hide();

	$('#divConteudoOpcao').html('');
	focoOperacao();

	// Chama uma função com rotinas de formatação de campos e demais elementos padrões Aimaro
	layoutPadrao();

	$('#btnEnviar').hide();
	$('#btnEfetivar').hide();

	$('#btnConsultaPesquisa').removeClass().addClass('botao');
	$('#btnConsultaVoltar').removeClass().addClass('botao');
	
	$('.divBotoesFiltros').hide();
	$('.divBotoesPesquisa').hide();

	return false;
}

function habilitaLupas() {
	$('#formPesquisa_btnLupaAssociado').click(function(){
		mostraPesquisaAssociado('nrdconta', 'filtros');
		return false;
	});
	$('#formPesquisa_btnLupaAssociado').find('img').removeClass().addClass('lupaHabilita');

	$('#formPesquisa_btnLupaAssociadoCadastro').click(function(){
		mostraPesquisaAssociadoDadosCadastrais('nrcpfcgc', 'filtros');
		return false;
	});
	$('#formPesquisa_btnLupaAssociadoCadastro').find('img').removeClass().addClass('lupaHabilita');

	$('#formPesquisa_btnLupaContrato').click(function(){
		mostraContrato('nrctro','filtros',$('#nrdconta', '#filtros').val());
		return false;
	});
	$('#formPesquisa_btnLupaContrato').find('img').removeClass().addClass('lupaHabilita');
}

function desabilitaLupas() {
	$('#formPesquisa_btnLupaAssociado').click(function () {return false;});
	$('#formPesquisa_btnLupaAssociado').unbind('click');
	$('#formPesquisa_btnLupaAssociado').find('img').removeClass().addClass('lupaDesabilitada');

	$('#formPesquisa_btnLupaAssociadoCadastro').click(function () {return false;});
	$('#formPesquisa_btnLupaAssociadoCadastro').unbind('click');
	$('#formPesquisa_btnLupaAssociadoCadastro').find('img').removeClass().addClass('lupaDesabilitada');

	$('#formPesquisa_btnLupaContrato').click(function () {return false;});
	$('#formPesquisa_btnLupaContrato').unbind('click');
	$('#formPesquisa_btnLupaContrato').find('img').removeClass().addClass('lupaDesabilitada');
}

function focoOperacao() {
	$('#btnOK', '#frmCab').focus();
	$('#btnOK', '#frmCab').unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 13) {
			habilitaFiltros();
			return false;
		}
	});
}

function voltarFiltroPesquisa() {
	$('#fsListagem #retornoPesquisaRating').html('');
	$('#fsListagem #divRegistrosGridTotal').html('');
	$('#fsListagem').hide();

	$('.divBotoesPesquisa').hide();
	$('.divBotoesFiltros').show();

	$('#btnConsultaPesquisa').removeClass().addClass('botao');
	$('#btnConsultaVoltar').removeClass().addClass('botao');

	cTodosFiltro = $('#filtros').find('input, textarea, button, select');
//    cTodosFiltro.limpaFormulario();
	cTodosFiltro.habilitaCampo();
	habilitaLupas();
}

function filtroContratoTipoProduto(elemento) {
	if ($(elemento).val() != '') {
		$('.formPesquisa_tpproduto', '#filtros').desabilitaCampo();
		$('.formPesquisa_tpproduto', '#filtros').each(function() {
			$(this).prop('checked', false);
		});
	} else {
		$('.formPesquisa_tpproduto', '#filtros').habilitaCampo();
	}
}

/*
Libera o filtro após a pesquisa para fazer a pesquisa e congela a opção inicial (frmCab)
*/
function habilitaFiltros() {
	if ($('#cddopcao', '#frmCab').hasClass('campoTelaSemBorda')) {
		return false;
	}
	$('.divBotoesFiltros').show();

	$('#btnConsultaPesquisa').click(function(e) {
		e.preventDefault();
		gerarPesquisa();
		return false;
	});

	$('#btnConsultaVoltar').click(function(e) {
		e.preventDefault();
		estadoInicial();
		return false;
	});

	$('#btnOK', '#frmCab').unbind('keypress');
	$('#filtros').unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 13) {
			gerarPesquisa();
		}
	});

	var cddopcao = $('#cddopcao', '#frmCab').val();

	if (cddopcao == 'H') {
		$('#btnConsultaPesquisa').html('Gerar PDF');
	} else {
		$('#btnConsultaPesquisa').html('Consultar');
	}

	// Desabilita campo opção
	cTodosCabecalho = $('.cddopcao, #btnOK', '#frmCab');
	cTodosCabecalho.desabilitaCampo();
	$('#filtros').show();
	habilitaLupas();
	$('#nrctro', '#filtros').blur(function() {
		filtroContratoTipoProduto($(this));
	});

	if (cddopcao == 'C') {
		cTodosFiltro = $('#filtros').find('input, textarea, button, select');
		cTodosFiltro.limpaFormulario();
		cTodosFiltro.habilitaCampo();
		$("#contratoLiquidado").show();

		/* Faz o TAB ser sequencial dentro dos FILTROS */
		var tabindex = 1000;
		$('#filtros input,select').each(function() {
			if (this.type != "hidden") {
				$(this).attr("tabindex", tabindex);
				tabindex++;
			}
		});
		/* Faz o TAB ser sequencial dentro dos FILTROS */
		$('#nrdconta', '#frmFiltros').focus();
	} else if (cddopcao == 'A' || cddopcao == 'H') {
		cTodosFiltro = $('#filtros').find('input, textarea, button, select');
		cTodosFiltro.limpaFormulario();
		cTodosFiltro.habilitaCampo();
		if (cddopcao == 'A') {
		$("#contratoLiquidado").hide();
		}
		if (cddopcao == 'H') {
			$("#contratoLiquidado").show();
		}

		/* Faz o TAB ser sequencial dentro dos FILTROS */
		var tabindex = 1000;
		$('#filtros input,select').each(function() {
			if (this.type != "hidden") {
				$(this).attr("tabindex", tabindex);
				tabindex++;
			}
		});
		/* Faz o TAB ser sequencial dentro dos FILTROS */
		$('#nrdconta', '#frmFiltros').focus();
	}
	return false;
}

/*
Gera resultado da pesquisa dos filtros do RATMOV
*/
function gerarPesquisa() {

	if ($('#nrdconta', '#frmFiltros').val().length == 0 && $('#nrcpfcgc', '#frmFiltros').val() == 0) {
		hideMsgAguardo();
		showError('error', 'Preenchimento obrigat&oacute;rio da conta ou CPF/CNPJ', 'Alerta - Aimaro', '');
		return false;
	}
	
	if ($('#cddopcao', '#frmCab').val() == 'H') {
		// var callafter = "cTodosCabecalho.desabilitaCampo();bloqueiaFundo($('#divRotina'));"
		var callafter = "hideMsgAguardo();";
		var action = UrlSite + 'telas/ratmov/manter_rotina.php?paramAcao=impressaoHistorico';
		$('#frmFiltros').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '" />');
		carregaImpressaoAyllos('frmFiltros', action, callafter);
		return false;
	}

	desabilitaLupas();
	cTodosFiltro.desabilitaCampo();

	showMsgAguardo('Aguarde, buscando ...');

	$('#btnConsultaPesquisa').removeClass().addClass('botaoDesativado');
	$('#btnConsultaVoltar').removeClass().addClass('botaoDesativado');

	var formtpproduto_emp = 'N';
	var formtpproduto_che = 'N';
	var formtpproduto_cre = 'N';
	var formtpproduto_des = 'N';
	var formtpproduto_cpa = 'N';

	var formcontratoliquidado = 'N';
	
	if ($('#tpproduto_emp', '#frmFiltros').is(':checked')) {
		formtpproduto_emp = 'S';
	}
	if ($('#tpproduto_che', '#frmFiltros').is(':checked')) {
		formtpproduto_che = 'S';
	}
	if ($('#tpproduto_cre', '#frmFiltros').is(':checked')) {
		formtpproduto_cre = 'S';
	}
	if ($('#tpproduto_des', '#frmFiltros').is(':checked')) {
		formtpproduto_des = 'S';
	}
	if ($('#tpproduto_cpa', '#frmFiltros').is(':checked')) {
		formtpproduto_cpa = 'S';
	}
	if ($('#contratoLiquidado', '#frmFiltros').is(':checked') && $('#cddopcao', '#frmCab').val() == 'C') {
		formcontratoliquidado = 'S';
	}

	$.ajax({
		type: 'POST',
		url: UrlSite + 'telas/ratmov/manter_rotina.php',
		data: {
			cddopcao: $('#cddopcao', '#frmCab').val(),
			nrdconta: $('#nrdconta', '#frmFiltros').val(),
			nrctro: $('#nrctro', '#frmFiltros').val(),
			nrcpfcgc: $('#nrcpfcgc', '#frmFiltros').val(),
			tpproduto_emp: formtpproduto_emp,
			tpproduto_che: formtpproduto_che,
			tpproduto_cre: formtpproduto_cre,
			tpproduto_des: formtpproduto_des,
			tpproduto_cpa: formtpproduto_cpa,
			fldtinic: $('#fldtinic', '#frmFiltros').val(),
			fldtfina: $('#fldtfina', '#frmFiltros').val(),
			prstatus: $('#prstatus', '#frmFiltros').val(),
			contratoLiquidado: formcontratoliquidado,
			paramAcao: 'pesquisarRating'
		}
	}).done(function(jsonResult) {

		if ($('#cddopcao', '#frmCab').val() == 'H') {
			hideMsgAguardo();
			// $('#fsListagem #divRegistrosGridTotal').html(jsonResult);
			var win = window.open();
			win.document.write(jsonResult);
			return false;

		} else {

			var retorno = jQuery.parseJSON(jsonResult);
			var validaRetorno = false;

			$('.divBotoesFiltros').hide();
			$('.divBotoesPesquisa').show();
			if(retorno.hasOwnProperty('resultadoHTML')){
				$('#fsListagem #retornoPesquisaRating').html(retorno.resultadoHTML);
				if(retorno.hasOwnProperty('total')){
					$('#fsListagem #divRegistrosGridTotal').html('Total de registros ' + retorno.total + ' encontrados');
				} else {
					$('#fsListagem #divRegistrosGridTotal').html('');
				}
				if(retorno.hasOwnProperty('desabilitaCheckBox')){
					eval(retorno.desabilitaCheckBox);
				}
				validaRetorno = true;
			}
			if(retorno.hasOwnProperty('resultadoJS')){
				eval(retorno.resultadoJS);
				validaRetorno = true;
			}
			
			 if ($('#cddopcao', '#frmCab').val() == 'C') {

				//  [001]
				if ($('.tituloRegistrosGrid tr th').length == 14) {
					$('.tituloRegistrosGrid tr').each(function(){
						$(this).children('th').eq(10).remove();
						$(this).children('th').eq(10).remove();
						$(this).children('th').eq(10).css('width', '205px');
					});
				}
				//  [001]
			 }
			
			if (!validaRetorno) {
				hideMsgAguardo();
				showError('error', 'Falha na comunica&ccedil;&atilde;o com servidor. Tente novamente.', 'Alerta - Aimaro', '');
			}
		}
	}).fail(function(e) {
		hideMsgAguardo();
		showError('error', 'Falha na comunica&ccedil;&atilde;o com servidor. Tente novamente.', 'Alerta - Aimaro', '');
	}).always(function() {
		hideMsgAguardo();
	});

	$('#fsListagem').show();
}

function validarCampos() {
	return true;
}

function controlarAbas(idAba) {

	for (var i = 0; i <= 2; i++) {
		if ($('#linkAba' + idAba).length == false) {
			continue;
		}

		if (idAba == i) {
			// Atribui estilo de destaque para a aba selecionada 
			$('#imgAbaCen' + idAba).css('background-color','#969FA9');
			continue;
		}

		// Remove estilo de destaque das outras abas 
		$('#imgAbaCen' + i).css('background-color','#C6C8CA');
	}
}

function desbloqueia() {
	cTodosCabecalho.habilitaCampo();

	return false;
}

function carregaHTMLPesquisaResultados() {
	// 0 = aba parametros
	controlarAbas(0);
	abaAtual = 'parametros';

	$.ajax({
		type: "POST",
		url: UrlSite + "telas/ratmov/form_cabecalho_parametros.php", 
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

function selecionaCheckboxPorClasse(elementoClasse, valor) {
	var elemento = $(elementoClasse);
	elemento.each(function() {
		if ($(this).val() == valor) {
			$(this).prop('checked', true);
		}
	});
}

// início contrato
function mostraContrato(campo,formulario,nrdconta) {

	nrdconta = normalizaNumero(nrdconta);

	showMsgAguardo('Aguarde, buscando ...');

	// Executa script de confirmação através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/ratmov/contrato.php',
		data: {
			redirect: 'html_ajax'
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground()");
		},
		success: function (response) {
			$('#divRotina').html(response);
			$('#divRotina').css({ 'z-index': '500' });
			buscaContrato(campo, formulario, nrdconta);
			return false;
		}
	});

	return false;
}

function buscaContrato(campo, formulario, nrdconta) {

	showMsgAguardo('Aguarde, buscando ...');
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/ratmov/contrato_busca.php',
		data: {
			nrdconta: nrdconta,
			redirect: 'script_ajax'
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground();");
		},
		success: function (response) {
			if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
				try {
					$('#divConteudo').html(response);
					$('#divRotina').css({ 'z-index': '500' });
					exibeRotina($('#divRotina'));
					formataContrato(campo, formulario);
					return false;
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
	return false;
}

function formataContrato(campo, formulario) {

	var divRegistro = $('div.divRegistros', '#divContrato');
	var tabela = $('table', divRegistro);
	var linha = $('table > tbody > tr', divRegistro);

	divRegistro.css({ 'height': '120px', 'width': '500px' });

	var ordemInicial = new Array();
	ordemInicial = [[0, 0]];

	var arrayLargura = new Array();
	arrayLargura[0] = '120px';
	arrayLargura[1] = '120px';
	// arrayLargura[2] = '80px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'center';
  
	var metodoTabela = "selecionaContrato('" + campo + "','" + formulario + "');";
	
	tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

	hideMsgAguardo();
	bloqueiaFundo($('#divRotina'));

	return false;
}

function selecionaContrato(campo, formulario) {

	if ($('table > tbody > tr', '#divContrato').hasClass('corSelecao')) {
		$('table > tbody > tr', '#divContrato').each(function () {
			if ($(this).hasClass('corSelecao')) {
				if (formulario == "#frmCad") {
					$('#nrctremp', '#frmCad').val($('#nrctremp', $(this)).val());
				} else {
					$('#nrctro').val($('#nrctremp', $(this)).val());
				}
			}
			filtroContratoTipoProduto($('#nrctro', '#filtros'));
		});
	}

	fechaRotina($('#divRotina'));
	return false;

}
//fim contrato

function mostraPesquisaAssociadoDadosCadastrais(campoRetorno, formRetorno, divBloqueia, fncFechar, cdCooper) {

	cdCooper = 0;
	// Mostra mensagem de aguardo
	showMsgAguardo('Aguarde, carregando Pesquisa de Associados ...');

	// Guardo o campoRetorno e o formRetorno em variáveis globais para serem utilizados na seleção do associado
	vg_campoRetorno = campoRetorno.split("|");
	vg_formRetorno  = formRetorno;

	$('#tpdapesq','#frmPesquisaAssociadoDadosCadastrais').empty();

	$('#frmPesquisaAssociadoDadosCadastrais').append('<input type="hidden" name="cdcooper" id="cdcooper" value="'+cdCooper+'"/>');

	// Limpar campos de pesquisa
	$('#nmdbusca','#frmPesquisaAssociadoDadosCadastrais').val('');
	$('#nrcpfcgc','#frmPesquisaAssociadoDadosCadastrais').val('');

	// Formatação Inicial
	$('#nmdbusca, #nrcpfcgc','#frmPesquisaAssociadoDadosCadastrais').removeClass('campoTelaSemBorda').addClass('campo').removeProp('disabled');

	$('.fecharPesquisa','#divPesquisaAssociadoDadosCadastrais').click( function() {
		fechaRotina($('#divPesquisaAssociadoDadosCadastrais'),divBloqueia,fncFechar);
	});
	// Limpa Tabela de pesquisa
	$('#divResultadoPesquisaAssociadoDadosCadastrais').empty();

	hideMsgAguardo();
	exibeRotina($('#divPesquisaAssociadoDadosCadastrais'));

}

function pesquisaAssociadoDadosCadastrais() {

	showMsgAguardo('Aguarde, pesquisando associados ...');
	var nmdbusca = $('#nmdbusca', '#frmPesquisaAssociadoDadosCadastrais').val();
	var nrcpfcgc = $('#nrcpfcgc', '#frmPesquisaAssociadoDadosCadastrais').val();

	// Verifica código do PAC
	if (nrcpfcgc == '' && nmdbusca == '') {
		hideMsgAguardo();
		showError('error', 'Informe o ASSOCIADO ou CPF/CNPJ a ser pesquisado.', 'Alerta - Ayllos', "bloqueiaFundo($('#divPesquisaAssociadoDadosCadastrais'));");
		return false;
	}

	// Carrega dados da conta através de ajax
	$.ajax({
		type: 'POST',
		url: UrlSite + 'includes/pesquisa/realiza_pesquisa_associados_dados_cadastrais.php',
		data: {
			nmdbusca: nmdbusca,
			nrcpfcgc: nrcpfcgc,
			redirect: 'html_ajax' // Tipo de retorno do ajax
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', "bloqueiaFundo($('#divPesquisaAssociadoDadosCadastrais'));");
		},
		success: function (response) {
			$('#divResultadoPesquisaAssociadoDadosCadastrais').html(response);
			zebradoLinhaTabela($('#divPesquisaAssociadoItensDadosCadastrais > table > tbody > tr'));

		}
	});
}

function selecionaAssociadoDadosCadastrais(cpfcgc) {
	fechaRotina($('#divPesquisaAssociadoDadosCadastrais'));
	$('#nrcpfcgc', '#filtros').val(cpfcgc);
}

function habilitarAtualizacao(idElement) {
	elemento = $(idElement).parent().parent();
	if ($(idElement).prop("checked")) {
		$(elemento).find('input[type=text]').show();
		$(elemento).find('input[type=text]').focus();
	} else {
		$(elemento).find('input[type=text]').hide();
	}
}

function validarRatingDigitado(idElement) {
	var valor = $(idElement).val().toUpperCase();
	var id = $(idElement).attr('id');

	// Converte para maiúculo
	$(idElement).val(valor);

	// valida o valor digitado para não continuar com erro de entrada
	if (
		valor != '' && valor != 'AA' && valor != 'A' && valor != 'B' &&
		valor != 'C' && valor != 'D' && valor != 'E' && valor != 'F' &&
		valor != 'G' && valor != 'H') {
		showError('error', 'Rating inv&aacute;lido', 'Alerta - Aimaro', '$("#' + id + '").val("");$("#' + id + '").focus();');
	}
	// valida o valor digitado para não continuar com erro de entrada
}

function aguardandoRating(item) {
	if (item.novanota == '') { // motor
		// $('#' + item.id).css('background-color','red');
		$('#' + item.id).css('opacity','0.5');
	} else { // esteira
		// $('#' + item.id).css('background-color','yellow');
		$('#' + item.id).css('opacity','0.5');
	}
}

function salvarRating(dadosRating) {
	fecharRating();
	$.ajax({
		type: 'POST',
		url: UrlSite + 'telas/ratmov/manter_rotina.php',
		data: {
			paramAcao: 'salvarRating',
			paramRating: dadosRating
		}
	}).done(function(jsonResult) {
		hideMsgAguardo();
		var resposta = jQuery.parseJSON(jsonResult);
		if(resposta.hasOwnProperty('retorno')){
			dadosRating = resposta.retorno;
			for (i = 0; i < dadosRating.length; i++) {
				var id = dadosRating[i][0]['id'];
				// $('#' + id).css("background-color", "yellow");
				// $('#' + id + " .tdAguardandoRating").css("background-color", "yellow");
				$('#' + id + " .tdCampoRating").remove();
				$('#' + id + " .tdAguardandoRating").attr('colspan',2);
				$('#' + id + " .tdAguardandoRating").html('<img src="' + UrlSite + 'imagens/geral/indicator.gif" width="12" height="12" style="margin-right: 5px;">' + 'Aguarde an&aacute;lise');
			}

			// atualização do resultado
			iniciarAtualizarRating();

		} else {
			showError('error', 'Falha na comunica&ccedil;&atilde;o com servidor. Tente novamente.', 'Alerta - Aimaro', '');
		}
		return;
	}).fail(function(jsonResult) {
		hideMsgAguardo();
		showError('error', 'Falha na comunica&ccedil;&atilde;o com servidor. Tente novamente.', 'Alerta - Aimaro', '');
	}).always(function() {
		hideMsgAguardo();
	});
}

function fecharRating() {
	for (i = 0; i < dadosRating.length; i++) {
		$('#' + dadosRating[i][0]['id']).css('opacity','1');
	}
}

function iniciarAtualizarRating() {
	// atualiza a cada 5 segundos
	timerRating = setInterval(atualizarRating, 5000);
}

function atualizarRating() {
	/*
	* Criar mensageria para fazer a pesquisa do item para retornar o valor ou a pesquisa de todos em análise da consulta realizada
	*/
	if (dadosRating.length) {
		elemento = dadosRating[0][0]['id'];
		$('#' + elemento + " .tdAguardandoRating").html('Analisado');
		dadosRating.splice(0, 1);
	} else {
		clearInterval(timerRating);
	}
}

function enviarRating() {
	dadosRating = [];
	var resultado = $('#retornoPesquisaRating');

	resultado.find("input:checked").each(function() {
		var formRating = $(this).parent().parent().find('input[type=text]').val();
		var formConta = $(this).data('conta');
		var formNrContrato = $(this).data('nrcontrato');
		var formTipoProduto = $(this).data('tipoproduto');
		var formTipoPessoa = $(this).data('pessoafisica');
		var formCpfCgc = $(this).data('cpfcgc');
		var formid = $(this).data('id');
		var item = [
			{
				'novanota' : formRating,
				'conta' : formConta,
				'contrato' : formNrContrato,
				'tipoproduto' : formTipoProduto,
				'tipoPessoa' : formTipoPessoa,
				'cpfcfc' : formCpfCgc,
				'id' : formid,
				'justificativa' : ''
			}
		];
		dadosRating.push(item);
	});

	if (dadosRating.length > 0) {
		mostrarJustificativa(dadosRating, aguardandoRating, salvarRating, fecharRating);
	} else {
		hideMsgAguardo();
		showError('error', '&Eacute; necess&aacute;rio selecionar pelo menos um contrato.', 'Alerta - Aimaro', '');
	}
}

function efetivarRating() {
	hideMsgAguardo();
	showError('error', 'Aguardando est&oacute;ria', 'Alerta - Aimaro', '');
}

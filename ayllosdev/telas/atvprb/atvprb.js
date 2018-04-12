/*!
 * FONTE        : atvprb.js
 * CRIAÇÃO      : Marcel Kohls / AMCom
 * DATA CRIAÇÃO : 19/03/2018
 * OBJETIVO     : Biblioteca de funções da tela ATVPRB
 */

var cCddopcao, btnOK, cTodosCabecalho;
var	cddopcao = 'C';
var nrpagina = 1;
var frmCab = 'frmCab';
var frmCad = 'frmCad';
var frmFiltro = 'frmFiltro';
var fsListagem = 'fsListagem';

$(document).ready(function() {
	estadoInicial();

	$(this).unbind('keyup');
	$(this).unbind('keydown');
});

function estadoInicial() {
	$('#divTela').fadeTo(0, 0.1);

	fechaRotina( $('#divRotina') );
	$('#divRotina').html('');

	hideMsgAguardo();
	formataCabecalho();

  $('#'+frmFiltro, '#divTela').css({'display':'none'});

	cTodosCabecalho.limpaFormulario().removeClass('campoErro');

	cCddopcao.habilitaCampo();
	cCddopcao.focus();
	cCddopcao.val( cddopcao );

	removeOpacidade('divTela');
}

function formataCabecalho() {
	// label
	var rCddopcao = $('label[for="cddopcao"]', '#'+frmCab);
	rCddopcao.addClass('rotulo').css({'width':'42px'});

	// input
	cCddopcao = $('#cddopcao', '#'+frmCab);
	cCddopcao.css({'width':'600px'});

	// outros
	cTodosCabecalho = $('input[type="text"],select','#'+frmCab);
	cTodosCabecalho.desabilitaCampo();
	btnOK			= $('#btnOk', '#'+frmCab);

	if ( $.browser.msie ) {
		cCddopcao.css({'width':'598px'});
	}

	// perssiona tecla enter do combo opcoes
	cCddopcao.unbind('keydown').bind('keydown', function(e) {
		if (e.keyCode == 13) {
			btnOK.click();
			return false;
		}
	});

	// Se clicar no botao OK
	btnOK.unbind('click').bind('click', function() {
		exibeAreaFiltros();
	});

	return false;
}

function exibeAreaFiltros() {
	cddopcao 	= cCddopcao.val();

	if (cddopcao) {
		if ( divError.css('display') == 'block' ) { return false; }
		if ( cCddopcao.hasClass('campoTelaSemBorda')  ) { return false; }

		cCddopcao.desabilitaCampo();

		formataFiltros();
	} else {
		showError("error","Selecione uma op&ccedil;&atilde;o antes de continuar");
	}

	return false;
}

function formataFiltros() {
	var rNrctrato = $('label[for="nrctrato"]', '#'+frmFiltro);
	var rNrdconta = $('label[for="nrdconta"]', '#'+frmFiltro);
	var rFlmotivo = $('label[for="flmotivo"]', '#'+frmFiltro);
	var rFldtinic = $('label[for="fldtinic"]', '#'+frmFiltro);
	var rFldtfina = $('label[for="fldtfina"]', '#'+frmFiltro);

	rNrdconta.addClass('rotulo-linha').css({'width':'90px'});
	rNrctrato.css({'width':'70px'});
	rFlmotivo.addClass('rotulo').css({'width':'93px'});
	rFldtinic.addClass('rotulo').css({'width':'93px'});
	rFldtfina.css({'width':'337px'});

	// input
	var cNrctrato = $('#nrctrato', '#'+frmFiltro);
	var cNrdconta = $('#nrdconta', '#'+frmFiltro);
	var cFlmotivo = $('#flmotivo', '#'+frmFiltro);
	var cFldtinic = $('#fldtinic', '#'+frmFiltro);
	var cFldtfina = $('#fldtfina', '#'+frmFiltro);

	cNrctrato.css({'width':'120px'}).addClass('inteiro').attr('maxlength','14');
	cNrdconta.css({'width':'120px'}).addClass('conta pesquisa');
	cFlmotivo.css({'width':'520px'});
	cFldtinic.css({'width':'90px'}).addClass('data');
	cFldtfina.css({'width':'90px'}).addClass('data');

	$('#'+frmFiltro, '#divTela').css({'display':'block'});

	cNrctrato.habilitaCampo();
	cNrdconta.habilitaCampo();
	cFlmotivo.habilitaCampo();
	cFldtinic.habilitaCampo();
	cFldtfina.habilitaCampo();

	cNrdconta.unbind('keydown').bind('keydown', function(e) {
		if (e.keyCode == 13 || e.keyCode == 9) {
			validaDigitoConta(frmFiltro);
		}
	});

	habilitarCamposFiltro();
	limparCamposFiltro();
	layoutPadrao();
	cNrdconta.focus();

	$("#btnLupaAssociado", "#"+frmFiltro).click(function(){
		mostraPesquisaAssociado('nrdconta', frmFiltro );
	});

	return false;
}

function limparCamposFiltro() {
	$('#'+frmFiltro+' input[type="text"]').val('');
	$('#flmotivo').val("0");
	$('#fldtinic, #fldtfina').val(datahoje);
	habilitaBotoesFiltro();
}

function habilitaBotoesFiltro() {
	$('#'+frmFiltro+' #divBotoesFiltro').css({'display':'block'});
}

function desabilitaBotoesFiltro() {
	$('#'+frmFiltro+' #divBotoesFiltro').css({'display':'none'});
}

function desabilitarCamposFiltro() {
	var camposFiltro = $('input[type="text"],select','#'+frmFiltro);

	$.each(camposFiltro, function(idx, campo){
		$(campo).desabilitaCampo();
	});
}

function habilitarCamposFiltro() {
	var camposFiltro = $('input[type="text"],select','#'+frmFiltro);
	nrpagina = 1;

	$.each(camposFiltro, function(idx, campo){
		$(campo).habilitaCampo();
	});
}

function validaDigitoConta(frmOrigem){
	var cNroConta = $('#nrdconta', '#'+frmOrigem);
	var nrdconta = retiraCaracteres(cNroConta.val(), "0123456789", true);

	if (!validaNroConta(nrdconta)) {
		showError("error","Conta/dv inv&aacute;lida.","Alerta - Ayllos");
		cNroConta.val('');
		cNroConta.focus();
		return false;
	}
}

function voltarFiltro() {
	estadoInicial();

	return false;
}

function continuarFiltro() {
	var dados = {
		operacao: (cddopcao == "C" ? 'Valida_Dados' : "Historico_Dados"),
		nrdconta: normalizaNumero( $("#"+frmFiltro+" #nrdconta").val() ),
		nrctrato: normalizaNumero( $("#"+frmFiltro+" #nrctrato").val() ),
		flmotivo: $("#"+frmFiltro+" #flmotivo").val(),
		datainic: $("#"+frmFiltro+" #fldtinic").val(),
		datafina: $("#"+frmFiltro+" #fldtfina").val(),
		dsobserv: ""
	};

	manterRotina(dados);
}

function manterRotina(dados) {
	hideMsgAguardo();

	var mensagem = "";

	switch( dados.operacao ) {
		case 'Historico_Dados':	mensagem = 'Aguarde, listando historico ...';	break;
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
				cddopcao: cddopcao,
				operacao: dados.operacao,
				nrdconta: dados.nrdconta,
				nrctrato: dados.nrctremp,
				flmotivo: dados.flmotivo,
				datainic: dados.datainic,
				datafina: dados.datafina,
				dsobserv: dados.dsobserv,
				nrpagina: nrpagina,
				redirect: 'script_ajax'
			},
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
			},
			success: function(response) {
				try {
					hideMsgAguardo();

					if ((dados.operacao == 'Valida_Dados' || dados.operacao == 'Historico_Dados')&& response.indexOf("error") == -1) {
						carregaListagem(response);
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

function carregaListagem(conteudo) {
	desabilitarCamposFiltro();
	desabilitaBotoesFiltro();
	$('#'+fsListagem).css({'display':'block'});
	$('#'+fsListagem+' #conteudoListagem').html(conteudo);

	if (cddopcao == 'C') {
		formataConsulta();
	} else if (cddopcao == 'H') {
		formataHistorico();
	}
}

function formataHistorico() {
	var dvRegistro = $('div.divRegistros','#divConta');
	var tabela      = $('table', dvRegistro );
	var linha       = $('table > tbody > tr', dvRegistro );

	dvRegistro.css({'height':'130px'});

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
	$('#divPesquisaRodape').formataRodapePesquisa();

	return false;
}

function formataConsulta() {
	var dvRegistro = $('div.divRegistros','#divConta');
	var tabela      = $('table', dvRegistro );
	var linha       = $('table > tbody > tr', dvRegistro );

	dvRegistro.css({'height':'130px'});

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
	$('#divPesquisaRodape').formataRodapePesquisa();

	$('#ckApenasAtivos').change(function() { filtraAtivos(); });

	// click na listagem
	$(".divRegistros tbody tr").click(function(el){exibeObservacoes(el);});

	//label observacao
	var rDsobserv = $('label[for="dsobserv"]', '#'+fsListagem);
	rDsobserv.addClass('rotulo-linha').css({'width':'90px'});

	// input observacao
	var cDsobserv = $('#dsobserv', '#'+fsListagem);
	cDsobserv.css({'width':'590px'});

	return false;
}

function exibeObservacoes(el) {
	$('#dsobserv', '#'+fsListagem).val($(el.currentTarget).find('td[data-campo="dsobserv"]').html());
}

function voltarListagem() {
	$('#'+fsListagem).css({'display':'none'});
	habilitarCamposFiltro();
	habilitaBotoesFiltro();
}

function capturaDadosSelecionado() {
	var dadosSelecionado = $(".divRegistros tbody .corSelecao td");
	var retorno = {};

	$.each(dadosSelecionado, function(idx, el){
		var jsEl = $(el);

		retorno[jsEl.data('campo')] = jsEl.html();
	});

	return retorno;
}

function abreAlterar() {
	var dadosSelecionado = capturaDadosSelecionado();

	if (dadosSelecionado.dtexclus.length > 0) {
		showError('error','Este registro j&aacute; foi exclu&iacute;do e n&atilde;o pode ser alterado','Alerta - Ayllos');
	}	else if (dadosSelecionado.nrdconta) {
		exibeFormCadastro(dadosSelecionado);
	} else {
		showError('error','Selecione um registro.','Alerta - Ayllos');
	}
}

function perguntaExcluir() {
	var dadosSelecionado = capturaDadosSelecionado();

	if (dadosSelecionado.nrdconta) {
		showConfirmacao('Marcar este registro como exclu&iacute;do?', 'Excluir - Ayllos', 'excluirRegistro()', '', 'sim.gif', 'nao.gif');
	} else {
		showError('error','Selecione um registro.','Alerta - Ayllos');
	}
}

function abreIncluir() {
	exibeFormCadastro({});
}

function exibeFormCadastro(dados) {
    exibeRotina($('#divUsoGenerico'));

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atvprb/form_cadastro.php',
        data: {
						nrdconta:	dados.nrdconta,
						nrctremp: dados.nrctremp,
						dsobserv: dados.dsobserv,
						cdmotivo: dados.cdmotivo,
            redirect: 'html_ajax'
            },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error','N&atilde;to foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos');
        },
        success: function(response) {
            $('#divUsoGenerico').html(response);
        }
    });
}

function filtraAtivos() {
	var itensListagem = $(".divRegistros tbody tr");
	var apenasAtivos = $("#"+fsListagem+" #ckApenasAtivos").prop('checked');

	$.each(itensListagem, function(idx, item) {
		if ($(item).find('td[data-campo="dtexclus"]').html().length > 0) {
			$(item).css('visibility', (apenasAtivos ? 'collapse' : 'visible'));
		}
	});
}

function formataCadastro(operacao) {
	//label
	var rNrdconta = $('label[for="nrdconta"]', '#'+frmCad);
	var rNrctrato = $('label[for="nrctremp"]', '#'+frmCad);
	var rFlmotivo = $('label[for="flmotivo"]', '#'+frmCad);
	var rDsobserv = $('label[for="dsobserv"]', '#'+frmCad);

	rNrdconta.addClass('rotulo-linha').css({'width':'90px'});
	rNrctrato.addClass('rotulo-linha').css({'width':'90px'});
	rFlmotivo.addClass('rotulo').css({'width':'93px'});
	rDsobserv.addClass('rotulo').css({'width':'93px'});

	// input
	var cNrdconta = $('#nrdconta', '#'+frmCad);
	var cNrctrato = $('#nrctremp', '#'+frmCad);
	var cFlmotivo = $('#flmotivo', '#'+frmCad);
	var cDsobserv = $('#dsobserv', '#'+frmCad);

	cNrdconta.css({'width':'120px'}).addClass('conta pesquisa');
	cNrctrato.css({'width':'120px'}).addClass('inteiro').attr('maxlength','14');
	cFlmotivo.css({'width':'240px'});
	cDsobserv.css({'width':'240px'});

	if (operacao == "Altera_Dados") {
		cNrdconta.desabilitaCampo();
		cNrctrato.desabilitaCampo();
		cFlmotivo.desabilitaCampo();
	} else {
		cNrdconta.habilitaCampo();
		cNrctrato.habilitaCampo();
		cFlmotivo.habilitaCampo();
	}

	cDsobserv.habilitaCampo();
	layoutPadrao();

	cNrdconta.unbind('keydown').bind('keydown', function(e) {
		if (e.keyCode == 13 || e.keyCode == 9) {
			validaDigitoConta(frmCad);
		}
	});

	$("#btnLupaAssociado", "#"+frmCad).click(function(){
		mostraPesquisaAssociado('nrdconta', frmCad);
	});
}

function excluirRegistro() {
	var dadosSelecionado = capturaDadosSelecionado();
	var dados = {};

	if (dadosSelecionado.nrdconta) {
			dados = dadosSelecionado;

			dados.operacao = 'Exclui_Dados';
			dados.flmotivo = dados.cdmotivo;

			manterRotina(dados);
	}
}

function salvarCadastro(operacao) {
	var dados = {};

	dados.operacao = operacao;
	dados.nrdconta = $("#"+frmCad+" #nrdconta").val();
	dados.nrctremp = $("#"+frmCad+" #nrctremp").val();
	dados.flmotivo = $("#"+frmCad+" #flmotivo").val();
	dados.dsobserv = $("#"+frmCad+" #dsobserv").val();

	if (dados.flmotivo == 65 && dados.dsobserv == "") { // se cod motivo = outros, precisa preencher observacao
		showError('error','Favor preencher o campo de observa&ccedil;&otilde;es','Alerta - Ayllos');
	} else {
		manterRotina(dados);
	}
}

function trocaPagina(salto) {
	nrpagina += salto;
	continuarFiltro();
}

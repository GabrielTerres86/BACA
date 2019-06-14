var cCdsituac, cTodosFiltro;
var	cdsituac = '1';
var nrpagina = 1;
var frmFiltro = 'frmFiltro';
var fsListagem = 'fsListagem';
var oldSelecAssoc = window.selecionaAssociado;

window.selecionaAssociado = function(conta,nmprimtl,dsnivris,nrcpfcgc){
	var regSelecionados = $("#divPesquisaAssociadoItens table tr td").filter(function(idx, el) {
      return retiraCaracteres($(el).text().trim(), "0123456789", true) == conta;
  }).parent('tr');

	var cddagen = ($(($(regSelecionados[0]).find('td'))[0]).text().trim() || "1");
	cCdagenci.val(cddagen);

	oldSelecAssoc(conta,nmprimtl,dsnivris,nrcpfcgc);
}

$(document).ready(function() {
	estadoInicial();

	$(this).unbind('keyup');
	$(this).unbind('keydown');
});

function estadoInicial() {
	fechaRotina( $('#divRotina') );
	$('#divRotina').html('');

	hideMsgAguardo();
	formataFiltro();

	cTodosFiltro.limpaFormulario().removeClass('campoErro');

	cCdsituac.val(cdsituac);
	cDtmvtolt.val(dataHoje);
	cCdsituac.focus();

	removeOpacidade('divTela');
}

function formataFiltro() {
	// label
	var rCdsituac = $('label[for="cdsituac"]', '#'+frmFiltro);
  var rFlprogra = $('label[for="flprogra"]', '#'+frmFiltro);
  var rNrdconta = $('label[for="nrdconta"]', '#'+frmFiltro);
  var rCdagenci = $('label[for="cdagenci"]', '#'+frmFiltro);
  var rDtmvtolt = $('label[for="dtmvtolt"]', '#'+frmFiltro);

	rCdsituac.addClass('rotulo').css({'width':'65px'});
	rFlprogra.addClass('rotulo-linha').css({'width':'75px'});
  rNrdconta.addClass('rotulo').css({'width':'65px'});
  rCdagenci.addClass('rotulo').css({'width':'65px'});
  rDtmvtolt.addClass('rotulo-linha').css({'width':'187px'});

	// input
	cCdsituac = $('#cdsituac', '#'+frmFiltro);
  cFlprogra = $('#flprogra', '#'+frmFiltro);
	cDtmvtolt = $('#dtmvtolt', '#'+frmFiltro);
	cNrdconta = $('#nrdconta', '#'+frmFiltro);
	cCdagenci = $('#cdagenci', '#'+frmFiltro);

	cNrdconta.css({'width':'120px'}).addClass('conta pesquisa');
	cCdagenci.css({'width':'120px'});
	cCdsituac.css({'width':'250px'});
	cFlprogra.css({'width':'250px'});
	cDtmvtolt.css({'width':'90px'}).addClass('data');

	// outros
	cTodosFiltro = $('input[type="text"],select','#'+frmFiltro);
	habilitarCamposFiltro();

	layoutPadrao();

	if ( $.browser.msie ) {
		cCdsituac.css({'width':'598px'});
	}

	$("#btnLupaAgencia", "#"+frmFiltro).click(function(){
		if (cCdagenci.attr('disabled') == undefined) {
			pesquisaPA();
		}
	});

  $("#btnLupaAssociado", "#"+frmFiltro).click(function(){
		if (cNrdconta.attr('disabled') == undefined) {
			mostraPesquisaAssociado('nrdconta', frmFiltro )
		}
	});

	$(cNrdconta).change(function(e){
		formataContaPA(e);
	}).blur(function(e){
		buscaPaConta();
	}).keypress(function(e) {
		if ( e.keyCode == 13 ) {
			buscaPaConta();
		}
	}).keydown(function(e) {
		formataContaPA();
	});

	return false;
}

function formataContaPA() {
	setTimeout(function () {
		if (cNrdconta.val().length > 0) {
			cCdagenci.desabilitaCampo();
		} else {
			cCdagenci.habilitaCampo();
		}
	}, 150);
}

function defineCamposSituacao() {
	cdsituac = $('#cdsituac', '#'+frmFiltro).val();

	if (cdsituac == '2'){
		$('.pendentes', '#'+frmFiltro).hide();
	} else {
		$('.pendentes', '#'+frmFiltro).show();
	}
}

function habilitarCamposFiltro() {
	var camposFiltro = $('input[type="text"],select','#'+frmFiltro);
	nrpagina = 1;

	$.each(camposFiltro, function(idx, campo){
		$(campo).habilitaCampo();
	});

	formataContaPA();
}

function manterRotina(dados) {
	hideMsgAguardo();

	var mensagem = "";

	switch( dados.situacao ) {
		case 'pendentes':	mensagem = 'Aguarde, listando pendentes ...';	break;
		case 'efetivados':	mensagem = 'Aguarde, listando efetivados ...';	break;
		default: return false;	break;
	}

	showMsgAguardo( mensagem );

	$.ajax({
			type  : 'POST',
			url   : UrlSite + 'telas/condeb/manter_rotina.php',
			data: {
				situacao: dados.situacao,
				nrdconta: retiraCaracteres(dados.nrdconta, "0123456789", true),
				dtmvtolt: dados.dtmvtolt,
				cdagenci: retiraCaracteres(dados.cdagenci, "0123456789", true),
				flprogra: dados.flprogra,
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

					if ((dados.situacao == 'pendentes' || dados.situacao == 'efetivados') && response.indexOf("error") == -1) {
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

function listarDebitos() {
	var dados = {};

	dados.situacao = ($("#"+frmFiltro+" #cdsituac").val() == '1' ?  'pendentes' : 'efetivados');
	dados.nrdconta = $("#"+frmFiltro+" #nrdconta").val();
	dados.dtmvtolt = $("#"+frmFiltro+" #dtmvtolt").val();
	dados.cdagenci = $("#"+frmFiltro+" #cdagenci").val();
	dados.flprogra = retornaProgramas();

	if (dados.situacao == "pendentes" && $("#"+frmFiltro+" #flprogra").val() == "TODOS" && dados.nrdconta == ""){
		showError('error','Informe um numero de conta para todos os programas','Alerta - Ayllos','');
	} else {
		manterRotina(dados);
	}
}

function continuarFiltro() {
	var dados = {
		situacao: ($("#"+frmFiltro+" #cdsituac").val() == '1' ?  'pendentes' : 'efetivados'),
		nrdconta: normalizaNumero( $("#"+frmFiltro+" #nrdconta").val() ),
		dtmvtolt: $("#"+frmFiltro+" #dtmvtolt").val(),
		cdagenci: $("#"+frmFiltro+" #cdagenci").val(),
		flprogra: retornaProgramas()
	};

	manterRotina(dados);
}

function pesquisaPA() {
	bo			= 'b1wgen0059.p';
	procedure	= 'busca_pac';
	titulo      = 'Ag&ecirc;ncia PA';
	qtReg		= '20';
	filtrosPesq	= 'Cod. PA;cdagenci;30px;S;0;;codigo;|Agencia PA;nmresage;200px;S;;;descricao;';
	colunas 	= 'Codigo;cdagepac;20%;right|Descricao;dsagepac;80%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas);
	return false;
}

function carregaListagem(conteudo) {
	desabilitarCamposFiltro();
	desabilitaBotoesFiltro();

	$('#'+fsListagem).css({'display':'block'});
	$('#'+fsListagem+' #conteudoListagem').html(conteudo);

	if (cdsituac == '1') {
		formataPendentes();
	} else if (cdsituac == '2') {
		formataEfetivados();
	}
}

function formataPendentes() {
	var dvRegistro = $('div.divRegistros','#divConta');
	var tabela      = $('table', dvRegistro );
	var linha       = $('table > tbody > tr', dvRegistro );

	dvRegistro.css({'height':'240px', 'width':'950px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '150px';
	arrayLargura[1] = '60px';
	arrayLargura[2] = '60px';
	arrayLargura[3] = '235px';
	arrayLargura[4] = '60px';
	arrayLargura[5] = '50px';
	arrayLargura[6] = '238px';

	fixaColunaDaTable("programa", arrayLargura[0]);
	fixaColunaDaTable("cooperad", arrayLargura[3]);
	fixaColunaDaTable("historic", arrayLargura[6]);

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'right';
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'center';

	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha );

	// centraliza a divRotina
	$('#divRotina').css({'width':'425px'});
	$('#divConteudo').css({'width':'400px'});
	$('#divRotina').centralizaRotinaH();
	$('#divPesquisaRodape').formataRodapePesquisa();

	return false;
}

function formataEfetivados() {
	var dvRegistro = $('div.divRegistros','#divConta');
	var tabela      = $('table', dvRegistro );
	var linha       = $('table > tbody > tr', dvRegistro );

	dvRegistro.css({'height':'240px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '62px';
	arrayLargura[1] = '60px';
	arrayLargura[2] = '260px';
	arrayLargura[3] = '70px';
	arrayLargura[4] = '159px';

	fixaColunaDaTable("cooperad", arrayLargura[2]);
	fixaColunaDaTable("historic", arrayLargura[4]);

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'right';
	arrayAlinha[3] = 'right';

	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha );

	// centraliza a divRotina
	$('#divRotina').css({'width':'425px'});
	$('#divConteudo').css({'width':'400px'});
	$('#divRotina').centralizaRotinaH();
	$('#divPesquisaRodape').formataRodapePesquisa();

	return false;
}

function trocaPagina(salto) {
	nrpagina += salto;
	continuarFiltro();
}

function voltarListagem() {
	$('#'+fsListagem).css({'display':'none'});
	habilitarCamposFiltro();
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

function retornaProgramas() {
	var prgSelecionado = $("#flprogra").val();

	if (prgSelecionado !== "TODOS") {
		return prgSelecionado+",";
	} else {
		prgSelecionado = "";

		$.each($("#flprogra option"), function(idx, el) {
			prgSelecionado += $(el).attr("value") + ',';
		});

		return prgSelecionado;
	}
}

function fixaColunaDaTable(nomeColuna, larguraColuna) {
	$('td[data-campo="'+nomeColuna+'"] div.fixalargura').css({"width":larguraColuna, "overflow":"hidden", "white-space":"nowrap"});
}

function buscaPaConta() {
	hideMsgAguardo();

	if (cNrdconta.val().length > 0) {
		showMsgAguardo( 'Aguarde, buscando conta ...' );

		$.ajax({
				type  : 'POST',
				url   : UrlSite + 'telas/condeb/valida_conta_pa.php',
				data: {
					nrdconta: retiraCaracteres(cNrdconta.val(), "0123456789", true),
					redirect: 'script_ajax'
				},
				error: function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
				success: function(response) {
					try {
						hideMsgAguardo();

						if (response.indexOf("error") == -1) {
							definePA(response.replace(/\"/g, ""));
						} else {
							definePA("");
							eval(response);
						}

						formataContaPA();
						return false;
					} catch(error) {
						hideMsgAguardo();
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
					}
				}
			});
	}
	return false;
}

function definePA(pCdagenci) {
	cCdagenci.val(pCdagenci);
}

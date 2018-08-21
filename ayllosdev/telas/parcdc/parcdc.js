/*!
 * FONTE        : parcdc.js                         
 * CRIAÇÃO      : Jean Michel
 * DATA CRIAÇÃO : 06/12/2017
 * OBJETIVO     : Biblioteca de funções da tela PARCDC
 * --------------
 * ALTERAÇÕES   :
 *
 * --------------
 */

// Variáveis Globais
var glbCdsegmento = 0;

var rCddopcao, rcdsubgru, rCdsubgru, cCddopcao, cDssubgru, cCdsubgru, cTodosCabecalho, cCdfaixav, cCdpartar, glbTabCdpartar,
	glbTabCdfaixav, glbTabidcomissao, glbTabVlinifvl, glbTabVlfinfvl, glbTabVlcomiss, glbTabnmcomissao, glbTabCdhistor, glbTabCdhisest, glbTabDshistor, glbTabDshisest,
	glbFcoCdcooper, glbFcoDtdivulg, glbFcoDtvigenc, glbFcoVltarifa, gblFcoVlpertar, glbFcoVlrepass, glbFcoCdfaixav, glbFcoNmrescop, glbFcoCdfvlcop,
	gblFcoVlmaxtar, gblFcoVlmintar, glbFcoNrconven, glbFcoDsconven, glbFcoCdlcremp, glbFcoDslcremp, gblFcoTpcobtar;


$(document).ready(function() {

	estadoInicial();

	highlightObjFocus( $('#frmCab') );

	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});	

	//$('#divUsoGenerico #tdTitTela a').attr('onclick', fechaRotina($('#divUsoGenerico'))); 

	return false;

});

function estadoInicial() {

	$('#frmCab').css({'display':'block'});
	$('#divDetalhamento').css({ 'display': 'none' });

	$('#divBotoes', '#divTela').html('').css({'display':'block'});

	formataCabecalho();

	return false;

}

function LiberaCampos(){
	
	if ($('#cddopcao', '#frmComissao').hasClass('campoTelaSemBorda')) { return false; }
	
	highlightObjFocus($('#frmComissao'));
	//Desabilita campo opção
	$('#cddopcao', '#frmComissao').desabilitaCampo();

	//Habilita campos
	$('#idcomissao', '#frmComissao').habilitaCampo();	
	$('#idcomissao', '#frmComissao').attr('maxlength', '9').setMask('INTEGER', 'zzzzzzzzz', '', '');
	
	$('#idcomissao', '#frmComissao').focus();
	
	$('#nmcomissao', '#frmComissao').desabilitaCampo();
	$('#tpvalor', '#frmComissao').desabilitaCampo();
	$('#flgativo', '#frmComissao').desabilitaCampo();

	
	$('#divBotoesComissao').css({ 'display': 'block' });
	
	
	trocaBotao('btnConcluir');

	$("#btSalvar", "#divBotoesComissao").show();
	$("#btVoltar", "#divBotoesComissao").show();

	if ($('#cddopcao', '#frmComissao').val() == 'I') {
		$('#flgativo', '#frmComissao').prop("checked", true);
		//buscaSequencial();
		$('#dtcriacao','#frmComissao').desabilitaCampo();
		$('#dtalteracao', '#frmComissao').desabilitaCampo();
		$('#idcomissao', '#frmComissao').desabilitaCampo();
		$('#nmcomissao', '#frmComissao').habilitaCampo();
		$('#tpvalor', '#frmComissao').habilitaCampo();
		$('#flgativo', '#frmComissao').habilitaCampo();
		$('#nmcomissao','#frmComissao').focus(); 
		trocaBotao('Incluir');				
	}

	return false;	
}

function trocaBotao(botao) {

	$('#divBotoesComissao', '#divTelaComissao').html('');
	$('#divBotoesComissao', '#divTelaComissao').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltarComissao(); return false;">Voltar</a>');

	if (botao == 'btnConcluir') {		
		$('#divBotoesComissao', '#divTelaComissao').append('&nbsp;<a href="#" class="botao" onClick="btnConcluir()" return false;" >Prosseguir</a>');
		return false;
	}

	if (botao != '') {
		$('#divBotoesComissao', '#divTelaComissao').append('&nbsp;<a href="#" id="btAcao" class="botao" onClick="realizaOperacao()" return false;" >' + botao + '</a>');
	}

	return false;
}

function btnConcluir() {

	idcomissaoTemp = $('#idcomissao', '#frmComissao').val();
	idcomissao = normalizaNumero(idcomissaoTemp);	

	if ((idcomissao != '') && (!$('#idcomissao', '#frmComissao').hasClass('campoTelaSemBorda'))) {
		//realizaOperacao();
		consultaComissao();
	}
}

function buscaSequencialDetalhamento() {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, buscando novo c&oacute;digo...");

	$.ajax({
		type: "POST",
		url: UrlSite + "telas/parcdc/busca_sequencial_detalhamento.php",
		data: {
			cddopcao: cddopcao,
			redirect: "script_ajax"
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function (response) {
			try {
				hideMsgAguardo();
				eval(response);
			} catch (error) {
				hideMsgAguardo();
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}
	});

	return false;

}	

function consultaComissao(){
	$('input,select', '#frmComissao').removeClass('campoErro'); /* Remove foco de erro */
	cddopcao = $('#cddopcao', '#frmComissao').val();

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, liberando aplicacao..."); 

	var idcomissao = $('#idcomissao', '#frmComissao').val();
	idcomissao = normalizaNumero(idcomissao);

	// Executa script através de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/parcdc/consulta_comissao.php",
		data: {
            nmrotina: "COMISSAO",         
			cddopcao: cddopcao,
			idcomissao: idcomissao,
			redirect: "script_ajax"
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function (response) {
			try {
				hideMsgAguardo();
				eval(response);
				
			} catch (error) {
				hideMsgAguardo();
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}
	});
}

function carregaDetalhamento() {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, buscando detalhamento...");

	var idcomissao = $('#idcomissao', '#frmComissao').val();
	idcomissao = normalizaNumero(idcomissao);
	var cddopcao = $('#cddopcao', '#frmComissao').val();
    var tpvalor = $('#tpvalor', '#frmComissao').val();
    

	// Carrega dados parametro através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/parcdc/carrega_detalhamento.php',
		data:
		{
			cddopcao: cddopcao,
            nmrotina: "COMISSAO",
			idcomissao: idcomissao,
            tpvalor: tpvalor,
			redirect: 'script_ajax'
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
		},
		success: function (response) {
			if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
				try {
					$('#divDetalhamento').html(response);
					$('#divDetalhamento').css({ 'display': 'block' });

					formataDetalhamento();

					var cddopcao = $('#cddopcao', '#frmComissao').val();

					if (cddopcao == 'C') {

						$('#btIncluir', '#divBotoesDetalha').hide();
						$('#btAlterar', '#divBotoesDetalha').hide();
						$('#btExcluir', '#divBotoesDetalha').hide();
					}
					
					if (cddopcao == 'E') {

						$('#btIncluir', '#divBotoesDetalha').hide();
						$('#btAlterar', '#divBotoesDetalha').hide();
						$('#btExcluir', '#divBotoesDetalha').hide();
					}
					
					
					
					hideMsgAguardo();
					bloqueiaFundo($('#divRotina'))
					return false;
				} catch (error) {
					hideMsgAguardo();
					showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
				}
			} else {
				try {
                    $('#divDetalhamento').html(response);
					//eval(response);
				} catch (error) {
					hideMsgAguardo();
					showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
				}
			}
		}
	});

	return false;
}

// Detalhamento Tarifa
function mostraDetalhamentoComissao(value) {

	glbTabidcomissao = $('#idcomissao', '#frmComissao').val();
    glbTabnmcomissao = $('#nmcomissao', '#frmComissao').val();
    
	cddopdet = value;

	if ((glbTabCdfaixav == '') && (cddopdet != 'I')) {
		showError('error', 'N&atilde;o h&aacute; registro selecionado', 'Alerta - Ayllos', "unblockBackground()");
		return false
	}

	showMsgAguardo('Aguarde, buscando detalhamento de regras da comissão...');

	// Executa script através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/parcdc/detalhamento_tela.php',
		data: {
			redirect: 'html_ajax'
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground()");
		},
		success: function (response) {
			bloqueiaFundo($('#divRotina'));
			$('#divUsoGenerico').html(response);			
			buscaDetalheComissao();
			
		}
	});

	return false;
}

function buscaDetalheComissao() {

	showMsgAguardo('Aguarde, buscando detalhamento da comiss&atilde;o...');
	var cdfaixav = normalizaNumero(glbTabCdfaixav);
	var idcomissao = normalizaNumero(glbTabidcomissao);

	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/parcdc/busca_detalhe_comissao.php',
		data: {
			cdfaixav: cdfaixav,
			idcomissao: idcomissao,
			cddopdet: cddopdet,
			redirect: 'script_ajax'
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground();");
		},
		success: function (response) {

			if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
				try {
	
					$('#divConteudoOpcao').html(response);									

					formataDetalheComissao();
	
					buscaValoresComissao(cddopdet);
					
					hideMsgAguardo();
					exibeRotina($('#divUsoGenerico')); 
					bloqueiaFundo( $('#divRotina') );
					
					$("#btSalvar","#divBotoesfrmDetalheComissao").hide();
					$('#vlinifvl','#frmDetalheComissao').focus();
					
				} catch (error) {
					hideMsgAguardo();
					showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
				}
			} else {
				try {
					eval(response);
					controlaFoco();
				} catch (error) {
					hideMsgAguardo();
					showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
				}
			}
		}
	});

	return false;
}

function formataDetalheComissao() {

	// Rotulos 
	var rCdfaixav = $('label[for="cdfaixav"]', '#frmDetalheComissao');
	var rIdcomissao = $('label[for="idcomissao"]', '#frmDetalheComissao');
	var rVlinifvl = $('label[for="vlinifvl"]', '#frmDetalheComissao');
	var rVlfinfvl = $('label[for="vlfinfvl"]', '#frmDetalheComissao');
	var rVlcomiss = $('label[for="vlcomiss"]', '#frmDetalheComissao');

	rCdfaixav.addClass('rotulo').css('width', '60px');
	rIdcomissao.addClass('rotulo').css('width', '60px');
	rVlinifvl.addClass('rotulo').css('width', '132px');
	rVlfinfvl.addClass('rotulo').css('width', '132px');
	rVlcomiss.addClass('rotulo').css('width', '132px');
	
	// Campos
	var cTodos = $('input[type="text"],select', '#frmDetalheComissao');
	var cCdfaixav = $('#cdfaixav', '#frmDetalheComissao');
	var cIdcomissao = $('#idcomissao', '#frmDetalheComissao');
	var cNmcomissao = $('#nmcomissao', '#frmDetalheComissao');
	
	var cVlinifvl = $('#vlinifvl', '#frmDetalheComissao');
	var cVlfinfvl = $('#vlfinfvl', '#frmDetalheComissao');
	var cVlcomiss = $('#vlcomiss','#frmDetalheComissao');
	
	cTodos.habilitaCampo();
	cCdfaixav.css('width', '60px').desabilitaCampo();

	cIdcomissao.css('width', '60px').desabilitaCampo();
	cNmcomissao.css('width', '250px').desabilitaCampo();
	cVlinifvl.addClass('moeda').css('width', '100px');
	cVlfinfvl.addClass('moeda').css('width', '100px');
    
    
    var tpvalor = $('#tpvalor', '#frmComissao').val();
    cVlcomiss.addClass('moeda').css('width', '100px');
    
    if (tpvalor == 2){
        $("#lb_vlcomiss").text("Perc. ");  
        
    }else{
        $("#lb_vlcomiss").text("Valor ");         
    }

	if (cddopdet == 'X') {
		// Desabilita campos do formulario frmDetalhaTarifa quando opção consulta (C).
		$('#cdfaixav', '#frmDetalheComissao').desabilitaCampo();
		$('#vlinifvl', '#frmDetalheComissao').desabilitaCampo();
		$('#vlfinfvl', '#frmDetalheComissao').desabilitaCampo();	
		$('#vlcomiss', '#frmDetalheComissao').desabilitaCampo();		
	}

	highlightObjFocus( $('#frmDetalheComissao') );

	controlafrmDetalheComissao();

	layoutPadrao();

	return false;
}

function formataDetalhamento() {

	$('#divRotina').css('width', '640px');

	var divRegistro = $('div.divRegistros', '#divDetalhamento');
	var tabela = $('table', divRegistro);
	var linha = $('table > tbody > tr', divRegistro);

	divRegistro.css({ 'height': '100px', 'width': '100%' });

	var ordemInicial = new Array();
	ordemInicial = [[0, 0]];

	var arrayLargura = new Array();
	arrayLargura[0] = '40px';
	arrayLargura[1] = '127px';
	arrayLargura[2] = '127px';
	arrayLargura[3] = '134px;padding-right: 12px;';


	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'center';	

	var metodoTabela = '';

	tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

	glbTabCdfaixav = '';

	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click(function () {
		glbTabIdcomissao = normalizaNumero($('#idcomissao', '#frmComissao').val());
		glbTabNmcomissao = $('#nmcomissao', '#frmComissao').val();
		glbTabCdfaixav = $(this).find('#codfaixa > span').text();
		glbTabVlinifvl = $(this).find('#vlinicial > span').text();
		glbTabVlfinfvl = $(this).find('#vlfinal > span').text();
		glbTabVlcomiss = $(this).find('#vlcomiss_aux > span').text();
	});

	$('table > tbody > tr:eq(0)', divRegistro).click();

	return false;
}

function controlafrmDetalheComissao() {

	$('#vlinifvl', '#frmDetalheComissao').unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			$('#vlfinfvl', '#frmDetalheComissao').focus();
			return false;
		}
	});

	$('#vlfinfvl', '#frmDetalheComissao').unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			$('#vlcomiss', '#frmDetalheComissao').focus();
			return false;
		}
	});

}

function realizaOperacao() {

	$('input,select', '#frmComissao').removeClass('campoErro'); /* Remove foco de erro */

	cddopcao = $('#cddopcao', '#frmComissao').val();

	if(cddopcao == 'I' || cddopcao == 'A'){

		if ($('#nmcomissao', '#frmComissao').val() == '') {
			showError('error', 'Descricao da Comissao deve ser informado.', 'Alerta - Ayllos', "blockBackground(parseInt($('#divRotina').css('z-index')));$(\'#nmcomissao\', '\#frmComissao\').focus();");
			return false;
		}
	}

	// Mostra mensagem de aguardo
	if (cddopcao == "C") { showMsgAguardo("Aguarde, consultando Regra..."); }
	else if (cddopcao == "X") { showMsgAguardo("Aguarde, consultando Regra..."); }
	else if (cddopcao == "I") { showMsgAguardo("Aguarde, incluindo Regra..."); }
	else if (cddopcao == "A") { showMsgAguardo("Aguarde, alterando Regra..."); }
	else if (cddopcao == "E") { showMsgAguardo("Aguarde, excluindo Regra..."); }
	else { showMsgAguardo("Aguarde, liberando aplicacao..."); }
	
	var idcomissao = $('#idcomissao', '#frmComissao').val();
	idcomissao = normalizaNumero(idcomissao);
	var nmcomissao = $('#nmcomissao', '#frmComissao').val();
	var tpvalor = $('#tpvalor', '#frmComissao').val();
	tpvalor = normalizaNumero(tpvalor);
	var flgativo = 0; 
	if ($('#flgativo', '#frmComissao').prop("checked"))	{
		flgativo = 1;
	}else{
		flgativo = 0;
	}	

	// Executa script através de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/parcdc/manter_comissao.php",
		data: {
            nmrotina: "COMISSAO", 
			cddopcao: cddopcao,
			idcomissao: idcomissao,
			nmcomissao: nmcomissao,
		 	tpvalor: tpvalor,
			flgativo: flgativo,			
			redirect: "script_ajax"
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function (response) {
			try {
				hideMsgAguardo();
				eval(response);		
				if (cddopcao == 'I'){

					$('#nmcomissao', '#frmComissao').desabilitaCampo();
					$('#tpvalor', '#frmComissao').desabilitaCampo();
					$('#flgativo', '#frmComissao').desabilitaCampo();
					$('#btAcao', '#divBotoesComissao').hide();
				
				

				}
			} catch (error) {
				hideMsgAguardo();
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}
	});
}

// Botao Voltar Comissao
function btnVoltarComissao() {	
	highlightObjFocus($('#frmComissao'));
	$('#cddopcao', '#frmComissao').habilitaCampo();
	$('#cddopcao', '#frmComissao').focus();		
	$('#idcomissao', '#frmComissao').val('');
	$('#nmcomissao', '#frmComissao').val('');
	$('#tpvalor', '#frmComissao').val(1);
	$('#dtcriacao', '#frmComissao').val('');
	$('#dtalteracao', '#frmComissao').val('');
	$('#flgativo', '#frmComissao').prop("checked", false);
	$('#idcomissao', '#frmComissao').desabilitaCampo();
	$('#nmcomissao', '#frmComissao').desabilitaCampo();
	$('#tpvalor', '#frmComissao').desabilitaCampo();
	$('#flgativo', '#frmComissao').desabilitaCampo();
	$('#dtcriacao', '#frmComissao').desabilitaCampo();
	$('#dtalteracao', '#frmComissao').desabilitaCampo();
	$('#divDetalhamento').css({ 'display': 'none' });
	$('#divBotoes', '#divTelaComissao').css({ 'display': 'none' });
	return false;
}

function buscaSequencial() {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, buscando novo c&oacute;digo...");

	$.ajax({
		type: "POST",
		url: UrlSite + "telas/parcdc/busca_sequencial.php",
		data: {
			redirect: "script_ajax"
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function (response) {
			try {
				hideMsgAguardo();
				eval(response);
			} catch (error) {
				hideMsgAguardo();
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}
	});

}

function controlaFoco() {
		
	$('#cdcooper','#frmCab').unbind('keypress').bind('keypress', function(e) {
	
		if ( $('#cdcooper','#frmCab').hasClass('campoTelaSemBorda') ) { return false; }
		
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			eventTipoOpcao();			
			return false;
		}	
	});
		
	$('#btnOK','#frmCab').unbind('keypress').bind('keypress', function(e) {
		
		if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda') ) { return false; }
		
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			eventTipoOpcao();
			return false;
		}	
	});
	
	$('#btnOK','#frmCab').unbind('click').bind('click', function(){
	
		if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda') ) { return false; }		
		eventTipoOpcao();
		return false;			
	});
	
	$('#inintegra_cont','#frmParametros').unbind('keypress').bind('keypress', function(e) {
		
		if ( $('#inintegra_cont','#frmParametros').hasClass('campoTelaSemBorda') ) { return false; }
		
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#nrprop_env','#frmParametros').focus();
			return false;
		}	
	});
	
	$('#nrprop_env','#frmParametros').unbind('keypress').bind('keypress', function(e) {
		
		if ( $('#nrprop_env','#frmParametros').hasClass('campoTelaSemBorda') ) { return false; }
		
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#intempo_prop_env','#frmParametros').focus();
			return false;
		}	
	});
	
	$('#intempo_prop_env','#frmParametros').unbind('keypress').bind('keypress', function(e) {
		
		if ( $('#intempo_prop_env','#frmParametros').hasClass('campoTelaSemBorda') ) { return false; }
		
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#btAlterarIntegracao').focus();
			return false;
		}	
	});

	$('#idcomissao', '#frmComissao').unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			if ($('#idcomissao', '#frmComissao').val() != '') {
				//realizaOperacao();
				consultaComissao();
			} else {
				controlaPesquisaTarifa();
				return false;
			}
		}
	});
	
	return false;	
}

function controlaPesquisa() {

    // Definir o tamanho da tela de pesquisa
    $("#divCabecalhoPesquisa").css("width", "100%");
    $("#divResultadoPesquisa").css("width", "100%");

    var idcomissao = $('#idcomissao', '#frmComissao').val();
    var nmcomissao = $('#nmcomissao', '#frmComissao').val();

    // Se esta desabilitado o campo 
    if ($("#idcomissao", "#frmComissao").prop("disabled") == true) { return; }

	//Remove a classe de Erro do form
    $('input,select', "#frmComissao").removeClass('campoErro');

    pck = 'zoom0001';
    acao = 'BUSCA_COMISSAO';
    titulo = 'Comiss&atildeo';
    qtReg = '';
    filtros = 'C&oacutedigo;idcomissao;30px;S;'+idcomissao+';S|Comiss&atildeo;nmcomissao;200px;S;'+nmcomissao+';S';
    colunas = 'C&oacutedigo;idcomissao;15%;left|Comiss&atildeo;nmcomissao;85%;left';
    mostraPesquisa(pck, acao, titulo, qtReg, filtros, colunas);
    var telaPrincipal = $('#divPesquisa');
    telaPrincipal.css('zIndex', 4000);
    return false;
      
}

function eventTipoOpcao (){
	$('#cdcooper','#frmCab').desabilitaCampo();
	$('#btnOK','#frmCab').desabilitaCampo();
	
	if ($('#cdcooper','#frmCab').val() > 0) {
		// Abre a tela de Parametros
		abreTelaParametrosCDC();
	}else{
		$('#cdcooper','#frmCab').habilitaCampo();
		$('#btnOK','#frmCab').habilitaCampo();
	}
	return false;
}

function formataCabecalho() {

	$('input,select', '#frmCab').removeClass('campoErro');
	$('#divTela').css({'display':'inline'}).fadeTo(0,0.1);
	removeOpacidade('divTela');	

	cTodosCabecalho = $('input[type="text"],select','#frmCab'); 
	cTodosCabecalho.limpaFormulario();

	// cabecalho
	rCdcooper = $('label[for="cdcooper"]','#frmCab'); 
	
	cCdcooper = $('#cdcooper','#frmCab'); 
	
	//Rótulos
	rCdcooper.css('width','70px');
	
	//Campos	
	cCdcooper.css({'width':'475px'}).habilitaCampo().focus();
	
	controlaFoco();
	layoutPadrao();

	return false;	

}

function btnVoltar(){
	$('#frmParametros').css('display','none');
	$('#cdcooper','#frmCab').habilitaCampo().focus().val(0);
	$('#btnOK','#frmCab').habilitaCampo();
	$('#btSalvar','#divBotoes').css('display','none');
	$('#btVoltar','#divBotoes').css('display','none');
	$("#btAlterarIntegracao").html("Alterar");
	return false;
}

function abreTelaParametrosCDC() {

	showMsgAguardo('Aguarde, carregando...');
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		dataType: 'html',
		url: "form_parametros.php", 
		data: {		
            nmrotina: "INTEGRACAO",        
			cdcooper: $('#cdcooper','#frmCab').val(),
			redirect: "html_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divTela').css('z-index')))");
			$('#cdcooper','#frmCab').habilitaCampo();
			$('#btnOK','#frmCab').habilitaCampo();			
		},
		success : function(response) {
			hideMsgAguardo();
			bloqueiaFundo($('#divRotina'));
			exibeRotina($('#divRotina'));
			$('#divRotina').html(response);
		}		
	});
    return false;
}

// Funcao para acessar opcoes da rotina
function acessaOpcaoAba(id) {
    
	// Esconde as abas
	$('.clsAbas').hide();
		    
	// Atribui cor de destaque para aba da opcao
	for (var i = 0; i < 4; i++) {
		$("#botoesAba" + i).hide();
		if (id == i) { // Atribui estilos para foco da opcao
			$("#linkAba" + id).attr("class","txtBrancoBold");
			$("#imgAbaEsq" + id).attr("src",UrlImagens + "background/mnu_sle.gif");				
			$("#imgAbaDir" + id).attr("src",UrlImagens + "background/mnu_sld.gif");
			$("#imgAbaCen" + id).css("background-color","#969FA9");
      $("#divAba" + id).show();
			$("#botoesAba" + id).show();			
			continue;			
		}
		$("#linkAba" + i).attr("class","txtNormalBold");
		$("#imgAbaEsq" + i).attr("src",UrlImagens + "background/mnu_nle.gif");			
		$("#imgAbaDir" + i).attr("src",UrlImagens + "background/mnu_nld.gif");
		$("#imgAbaCen" + i).css("background-color","#C6C8CA");
	}
	
	if(id == 0){
		desabilitaCamposIntegracao();
	}
	layoutPadrao();
}

function alterarIntegracao(){
	
	if($("#btAlterarIntegracao").html() == "Alterar"){
		$("#inintegra_cont").habilitaCampo();
		$("#nrprop_env").habilitaCampo();
		$("#intempo_prop_env").habilitaCampo();
		$("#btAlterarIntegracao").html("Concluir");
		$("#inintegra_cont").focus();
	}else{
		if($('#hdnCdcooper','#frmParametros').val() == 99){
			showConfirmacao('Os valores ser&atilde;o alterados para todas as cooperativas, deseja proceder com a altera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','manterParametros();','bloqueiaFundo(divRotina);','sim.gif','nao.gif');		
		}else{
			manterParametros();
		}
	}
}

function desabilitaCamposIntegracao(){
	$("#inintegra_cont").desabilitaCampo();
	$("#nrprop_env").desabilitaCampo();
	$("#intempo_prop_env").desabilitaCampo();
}

// Formata tabela de Segmentos
function formataTabelaSegmento() {
    
	var metodoTabela = '';
	var divRegistro = $('div.divRegistros', '#divAba1');
	var tabela = $('#tableSegmento', divRegistro);
	//var linha = $('#tableSegmento table > tbody > tr', divRegistro);

	$('#tableSegmento').css({ 'margin-top': '5px' });
	divRegistro.css({ 'height': '160px', 'width': '750px', 'padding-bottom': '2px' });

	var ordemInicial = new Array();
	ordemInicial = [[0, 0]];
	var arrayLargura = new Array();
	var arrayAlinha = new Array();
	
	arrayLargura[0] = '75px';
	arrayLargura[1] = '330px';
					
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'left';
	
	tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);
	
	layoutPadrao();

	return false;
}

// Formata tabela de Segmentos
function formataTabelaSubsegmento() {
    
	var metodoTabela = '';
	var divRegistro = $('div.divRegistros', '#divAba1');
	var tabela = $('#tableSubsegmento', divRegistro);
	var linha = $('#tableSubsegmento table > tbody > tr', divRegistro);

	$('#tableSubsegmento').css({ 'margin-top': '5px' });
	divRegistro.css({ 'height': '160px', 'width': '750px', 'padding-bottom': '2px' });

	var ordemInicial = new Array();
	ordemInicial = [[0, 0]];
	var arrayLargura = new Array();
	var arrayAlinha = new Array();
	
	arrayLargura[0] = '75px';
	arrayLargura[1] = '286px';
	arrayLargura[2] = '120px';
	arrayLargura[3] = '120px';
	arrayLargura[4] = '120px';
					
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'right';
	
	tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);
	
	layoutPadrao();

	return false;
}

function rotinaSegmento(cddopcao){
	if(cddopcao == "I"){
		manterRotinaSegmento(cddopcao);
	}else{
		$('table.tituloRegistros > tbody > tr', '#divSegmentos').each(function() {
			if ($(this).hasClass('corSelecao')) {
				if($('#cdsegmento',$(this)).val() == "" || $('#cdsegmento',$(this)).val() == undefined || $('#cdsegmento',$(this)).val() == null){
					showError('error', 'Selecione um segmento!', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina);');
					return false;
				}else{
					glbCdsegmento = $('#cdsegmento',$(this)).val();
					if(cddopcao == "A"){
						manterRotinaSegmento(cddopcao,$('#cdsegmento',$(this)).val());
					}else if(cddopcao == "E"){
						showConfirmacao('Deseja excluir o segmento?','Confirma&ccedil;&atilde;o - Ayllos','salvaDados(0,"E",'+$('#cdsegmento',$(this)).val()+',0);','bloqueiaFundo(divRotina);','sim.gif','nao.gif');
					}
				}
			}
		});
	}
}

function manterRotinaSegmento(cddopcao,cdsegmento) {
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		dataType: 'html',
		url: "form_cadastro.php", 
		data: {		
			tpcadast: 0,
			cddopcao: cddopcao,
            nmrotina: "SEGMENTOS", 
			cdsegmento: cdsegmento,
			redirect: "html_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divTela').css('z-index')))");
		},
		success : function(response) {
			exibeRotina($('#divUsoGenerico'));
			$('#divUsoGenerico').html(response);
			hideMsgAguardo();
			bloqueiaFundo($('#divUsoGenerico'));
		}		
	});
    return false;
}

function manterDetalhamento(cddopdet){

	if (cddopdet != 'E'){
		var cdfaixa = $('#cdfaixav', '#frmDetalheComissao').val();
		var idcomissao = $('#idcomissao', '#frmDetalheComissao').val();
		var vlinifvl = $('#vlinifvl', '#frmDetalheComissao').val();
		var vlfinfvl = $('#vlfinfvl', '#frmDetalheComissao').val();
		var vlcomiss = $('#vlcomiss', '#frmDetalheComissao').val();

		cdfaixa = normalizaNumero(cdfaixa);
		idcomissao = normalizaNumero(idcomissao);
		vlinifvl = normalizaNumero(vlinifvl);
		vlfinfvl = normalizaNumero(vlfinfvl);
		vlcomiss = normalizaNumero(vlcomiss);

		if (vlfinfvl == 0 || vlfinfvl == "" || vlfinfvl == undefined || vlfinfvl == null) {
			showError("error", "Informe o valor final.", "Alerta - Ayllos", "bloqueiaFundo(divRotina);$('#vlfinfvl', '#frmDetalheComissao').focus();");
			return false;
		}

		if (vlcomiss == 0 || vlcomiss == "" || vlcomiss == undefined || vlcomiss == null) {
			showError("error", "Informe o valor da comiss&atilde;o.", "Alerta - Ayllos", "bloqueiaFundo(divRotina);$('#vlcomiss', '#frmDetalheComissao').focus();");
			return false;
		}
	}else{
		var cdfaixa = glbTabCdfaixav;
		cdfaixa = normalizaNumero(cdfaixa);
		var idcomissao = 0;
		var vlinifvl = 0;
		var vlfinfvl = 0;
		var vlcomiss = 0;
	}

	// Executa script de bloqueio através de ajax
	$.ajax({
		type: "POST",
		dataType: 'html',
		url: "manter_detalhamento.php",
		data: {
			cddopdet: cddopdet,
			cdfaixa: cdfaixa,
			idcomissao: idcomissao,
			vlinifvl: vlinifvl,
			vlfinfvl: vlfinfvl,
			vlcomiss: vlcomiss,
			redirect: "html_ajax"
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divTela').css('z-index')))");			
		},
		success: function (response) {
			try {
				hideMsgAguardo();
				eval(response);	
				carregaDetalhamento();			
			} catch (error) {
				hideMsgAguardo();
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}
	});
	return false;	
}

function excluirDetalhamento() {

	if ( glbTabCdfaixav == '' ){
		showError('error', 'N&atilde;o h&aacute; registro selecionado', 'Alerta - Ayllos', "unblockBackground()");
		return false
	} else {
		showConfirmacao('Deseja realmente excluir o registro do detalhamento?', 'Confirma&ccedil;&atilde;o - Ayllos','manterDetalhamento(\'E\');','return false;','sim.gif','nao.gif');
	}
}

function rotinaSubsegmento(cddopcao){
	if(cddopcao == "I"){
		manterRotinaSubsegmento(cddopcao);
	}else{
		$('table.tituloRegistros > tbody > tr', '#divSubsegmentos').each(function() {
			if ($(this).hasClass('corSelecao')) {
				if($('#cdsubsegmento',$(this)).val() == "" || $('#cdsubsegmento',$(this)).val() == undefined || $('#cdsubsegmento',$(this)).val() == null){
					showError('error', 'Selecione um subsegmento!', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina);');
					return false;
				}else{						
					if(cddopcao == "A"){
						manterRotinaSubsegmento(cddopcao,$('#cdsubsegmento',$(this)).val());
					}else if(cddopcao == "E"){
						showConfirmacao('Deseja excluir o Subsegmento?','Confirma&ccedil;&atilde;o - Ayllos','salvaDados(1,"E",0,' + $('#cdsubsegmento',$(this)).val() + ');','bloqueiaFundo(divRotina);','sim.gif','nao.gif');
					}
				}
			}
		});
	}
}

function manterRotinaSubsegmento(cddopcao,cdsubsegmento) {
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		dataType: 'html',
		url: "form_cadastro.php", 
		data: {		
			tpcadast: 1,
            nmrotina: "SEGMENTOS",
			cddopcao: cddopcao,
			cdsegmento: glbCdsegmento,
			cdsubsegmento: cdsubsegmento,
			redirect: "html_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divTela').css('z-index')))");
			$('#cdcooper','#frmCab').habilitaCampo();
			$('#btnOK','#frmCab').habilitaCampo();			
		},
		success : function(response) {
			exibeRotina($('#divUsoGenerico'));
			$('#divUsoGenerico').html(response);
			hideMsgAguardo();
			bloqueiaFundo($('#divUsoGenerico'));
            
            if (cddopcao == 'A') {
                $('#cdsubsegmento','#frmCadastro').desabilitaCampo();
            }
            
		}		
	});
    return false;
}

function manterParametros() {
	
	showMsgAguardo('Aguarde, salvando...');	
		
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		dataType: 'html',
		url: "manter_parametros.php", 
		data: {		
			cddopcao: 'A',
			cdcooper: $('#hdnCdcooper','#frmParametros').val(),
			inintegra_cont:$('#inintegra_cont','#frmParametros').val(),
			nrprop_env:$('#nrprop_env','#frmParametros').val(),
			intempo_prop_env:$('#intempo_prop_env','#frmParametros').val(),
			redirect: "html_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success : function(response) {
			hideMsgAguardo();
			showError("inform","Atualiza&ccedil;&atilde;o executada com sucesso!","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			$("#inintegra_cont").desabilitaCampo();
			$("#nrprop_env").desabilitaCampo();
			$("#intempo_prop_env").desabilitaCampo();
			$("#btAlterarIntegracao").html("Alterar");
			$("#btVoltarintegracao").focus();
		}		
	});
	return false;
}

function detalheSubsegmento(cdsegmento){
	
	glbCdsegmento = cdsegmento;
	
	$.ajax({		
		type: "POST",
		dataType: 'html',
		url: "tab_subsegmentos.php", 
		data: {		
            nmrotina: "SEGMENTOS", 
			cdsegmento: cdsegmento,
			redirect: "html_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divTela').css('z-index')))");
		},
		success : function(response) {
			$('#divSubsegmentos').html(response);
		}		
	});
}

function salvaDados(tpcadast,cddopcao,cdsegmento,cdsubsegmento){
	
	if(cddopcao != "E"){
		cdsegmento = $('#cdsegmento','#frmCadastro').val();
		cdsubsegmento = $('#cdsubsegmento','#frmCadastro').val();
		nrmax_parcela = $('#nrmax_parcela', '#frmCadastro').val();
		vlmax_financ = $('#vlmax_financ', '#frmCadastro').val();
		nrcarencia = $('#nrcarencia', '#frmCadastro').val();

		if(tpcadast == 0){
		 
		 if(cdsegmento == 0 || cdsegmento == "" || cdsegmento == undefined || cdsegmento == null){
				showError("error","Informe o c&oacute;digo do segmento.","Alerta - Ayllos","blockBackground(parseInt($('#divUsoGenerico').css('z-index'))); $('#cdsegmento','#frmCadastro').focus();");
				return false;
			}
			if($('#dssegmento','#frmCadastro').val() == 0 || $('#dssegmento','#frmCadastro').val() == "" || $('#dssegmento','#frmCadastro').val() == undefined || $('#dssegmento','#frmCadastro').val() == null){
				showError("error","Informe a descri&ccedil;&atilde;o do segmento.","Alerta - Ayllos","blockBackground(parseInt($('#divUsoGenerico').css('z-index'))); $('#dssegmento','#frmCadastro').focus();");
				return false;
			}	
			
		}else if(tpcadast == 1){
			
			if(cdsegmento == 0 || cdsegmento == "" || cdsegmento == undefined || cdsegmento == null){
				showError("error","Informe o c&oacute;digo do segmento.","Alerta - Ayllos","blockBackground(parseInt($('#divUsoGenerico').css('z-index'))); $('#cdsegmento','#frmCadastro').focus();");
				return false;
			}
			
			if(cdsubsegmento == 0 || cdsubsegmento == "" || cdsubsegmento == undefined || cdsubsegmento == null){
				showError("error","Informe o c&oacute;digo do subsegmento.","Alerta - Ayllos","blockBackground(parseInt($('#divUsoGenerico').css('z-index'))); $('#cdsubsegmento','#frmCadastro').focus();");
				return false;
			}
			
			if($('#dssubsegmento','#frmCadastro').val() == 0 || $('#dssubsegmento','#frmCadastro').val() == "" || $('#dssubsegmento','#frmCadastro').val() == undefined || $('#dssubsegmento','#frmCadastro').val() == null){
				showError("error","Informe a descri&ccedil;&atilde;o do subsegmento.","Alerta - Ayllos","blockBackground(parseInt($('#divUsoGenerico').css('z-index'))); $('#dssubsegmento','#frmCadastro').focus();");
				return false;
			}

			if (nrmax_parcela == 0 || nrmax_parcela == "" || nrmax_parcela == undefined || nrmax_parcela == null) {
				showError("error", "Informe o N&uacute;mero m&aacute;ximo de parcelas.", "Alerta - Ayllos", "blockBackground(parseInt($('#divUsoGenerico').css('z-index'))); $('#nrmax_parcela','#frmCadastro').focus();");
				return false;
			}

			if (vlmax_financ == 0 || vlmax_financ == "" || vlmax_financ == undefined || vlmax_financ == null) {
				showError("error", "Informe o Valor m&aacute;ximo da proposta.", "Alerta - Ayllos", "blockBackground(parseInt($('#divUsoGenerico').css('z-index'))); $('#vlmax_financ','#frmCadastro').focus();");
				return false;
			}

			if (nrcarencia == 0 || nrcarencia == "" || nrcarencia == undefined || nrcarencia == null) {
				showError("error", "Informe a Car&ecirc;ncia.", "Alerta - Ayllos", "blockBackground(parseInt($('#divUsoGenerico').css('z-index'))); $('#nrcarencia','#frmCadastro').focus();");
				return false;
			}
		
		}		
	}		
		
	showMsgAguardo('Aguarde, salvando...');	
			
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		dataType: 'script',
		url: "manter_segmentos.php", 
		data: {		
            nmrotina: "SEGMENTOS",  
			tpcadast: tpcadast,
			cddopcao: cddopcao,
			tpproduto: $('#tpproduto','#frmCadastro').val(),
			cdsegmento: cdsegmento,
			dssegmento: $('#dssegmento','#frmCadastro').val(),
			cdsubsegmento: cdsubsegmento,
			dssubsegmento: $('#dssubsegmento','#frmCadastro').val(),
			nrmax_parcela: $('#nrmax_parcela','#frmCadastro').val(),
			vlmax_financ: $('#vlmax_financ','#frmCadastro').val(),
			nrcarencia: $('#nrcarencia', '#frmCadastro').val(),
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
		},
		success : function(response) {
			hideMsgAguardo();
			eval(response);
		}		
	});
	
}

function buscaValoresComissao(aux_cddopdet){
	
	$('#idcomissao','#frmDetalheComissao').val(glbTabidcomissao);
	$('#nmcomissao','#frmDetalheComissao').val(glbTabnmcomissao);
	$('#cdfaixav','#frmDetalheComissao').desabilitaCampo();
	$('#idcomissao','#frmDetalheComissao').desabilitaCampo();
	$('#nmcomissao','#frmDetalheComissao').desabilitaCampo();
	
	switch (aux_cddopdet) {
		case 'A':
			var aux_vlinifvl = number_format(glbTabVlinifvl,2,',','');
			var aux_vlfinfvl = number_format(glbTabVlfinfvl,2,',','');						
			var aux_vlcomiss = number_format(glbTabVlcomiss,2,',','');        	
			
			$('#cdfaixav','#frmDetalheComissao').val(glbTabCdfaixav);
			$('#vlinifvl','#frmDetalheComissao').val(aux_vlinifvl);
			$('#vlfinfvl','#frmDetalheComissao').val(aux_vlfinfvl);
			$('#vlcomiss','#frmDetalheComissao').val(aux_vlcomiss);	
			break;	
		case 'I':			
        	$('#idcomissao','#frmDetalheComissao').val(glbTabidcomissao);
	    	$('#nmcomissao','#frmDetalheComissao').val(glbTabnmcomissao);
			break;
	}
	
	return false;	
	
}
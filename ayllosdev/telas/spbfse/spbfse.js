/*!
 * FONTE        : spbfse.js
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : 18/07/2018
 * OBJETIVO     : Biblioteca de funções da tela SPBFSE
 * --------------
 * ALTERAÇÕES   :  
 * --------------
 */

// Definição de algumas variáveis globais 
var cddopcao		= 'C';
//Labels/Campos do cabeçalho
var cCddopcao, cTodosCabecalho, btnCab, glbTabCdfase, glbTabNmfase, glbTabIdfase_controlada, glbTabCdfase_anterior, 
    glbTabQttempo_alerta, glbTabQtmensagem_alerta, glbTabIdconversao, glbTabDtultima_execucao, glbTabIdativo, glbTabIdreprocessa_mensagem;

$(document).ready(function() {

	estadoInicial();
	
	highlightObjFocus( $('#frmCab') );
	
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	
	return false;	
	
});

// seletores
function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);
	$('#frmCab').css({'display':'block'});
	$('#frmAlterar').css({'display':'none'});
	$('#frmIncluir').css({'display':'none'});
	$('#frmAlterar').limpaFormulario();
	$('#frmIncluir').limpaFormulario();
	$('#divBotoes').css({'display':'none'});
	$('input,select', '#frmCab').removeClass('campoErro');	
	$("#btProsseguir","#divBotoes").text('Prosseguir');
		
	formataCabecalho();

	cCddopcao.val( cddopcao );
	removeOpacidade('divTela');	
	unblockBackground();
	hideMsgAguardo();
	
	controlaFoco();
}

function controlaFoco() {
		
	/* -------------- Cabeçalho - INICIO -------------- */
	
	$('#btnOK','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			btnContinuar();
			return false;
		}	
	});

	$('#btnOK','#frmCab').unbind('click').bind('click', function(e) {
		if (!($('#cddopcao', '#frmCab').hasClass('campoTelaSemBorda'))){
			btnContinuar();
		}
		return false;
	});
	
	$('#cddopcao','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			$('#btnOK','#frmCab').click();				
			return false;
		}	
	});
		
	/* -------------- Cabeçalho - FIM -------------- */
}

function formataCabecalho(){
	
	cTodosCabecalho		= $('input[type="text"],select','#frmCab');
	cTodosCabecalho.limpaFormulario();
	cTodosCabecalho.habilitaCampo();
	
	// cabecalho
	rCddopcao = $('label[for="cddopcao"]','#frmCab'); 
	rCddopcao.css('width','40px');
	
	cCddopcao = $('#cddopcao','#frmCab').css({'width':'565px'}); 
	btnCab		 = $('#btOK','#frmCab');
		
	cCddopcao.focus();
	
}

function formataAlterar() {
	
	// tabela
    var divRegistro = $('div.divRegistros', '#divFases');
    var tabela = $('table', divRegistro);
		
    $('#frmAlterar').css({'margin-top': '5px'});
    divRegistro.css({'height': '207px', 'padding-bottom': '2px'});

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '50px';
    arrayLargura[1] = '225px';
    arrayLargura[2] = '100px';
    arrayLargura[3] = '40px';
	
    var arrayAlinha = new Array();
    arrayAlinha[0] = 'right';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'left';

   	tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, 'btnContinuar();');
	
	glbTabCdfase = undefined;
	glbTabNmfase = undefined;
	glbTabIdfase_controlada = undefined;
	glbTabCdfase_anterior = undefined;
	glbTabQttempo_alerta = undefined;
	glbTabQtmensagem_alerta = undefined;
	glbTabIdconversao = undefined;
	glbTabDtultima_execucao = undefined;
	glbTabIdativo = undefined;
	glbTabIdreprocessa_mensagem = undefined;

	// seleciona o registro que é clicado
	$('table.tituloRegistros > tbody > tr', divRegistro).click( function() {		
		glbTabCdfase = $('#hcdfase' ,$(this)).val();
		glbTabNmfase = $('#hnmfase' ,$(this)).val();
		glbTabIdfase_controlada = $('#hidfase_controlada' ,$(this)).val();
		glbTabCdfase_anterior = $('#hcdfase_anterior' ,$(this)).val();
		glbTabQttempo_alerta = $('#hqttempo_alerta' ,$(this)).val();
		glbTabQtmensagem_alerta = $('#hqtmensagem_alerta' ,$(this)).val();
		glbTabIdconversao = $('#hidconversao' ,$(this)).val();
		glbTabDtultima_execucao = $('#hdtultima_execucao' ,$(this)).val();
		glbTabIdativo = $('#hidativo' ,$(this)).val();
		glbTabIdreprocessa_mensagem = $('#hidreprocessa_mensagem' ,$(this)).val();

	});

	$('table > tbody > tr:eq(0)', divRegistro).click();

	highlightObjFocus( $('#frmAlterar') );
	
	rCdfase            = $('label[for="cdfase"]','#frmAlterar');
	rNmfase            = $('label[for="nmfase"]','#frmAlterar');
	rIdfase_controlada = $('label[for="idfase_controlada"]','#frmAlterar');
	rCdfase_anterior   = $('label[for="cdfase_anterior"]','#frmAlterar');
	rQttempo_alerta    = $('label[for="qttempo_alerta"]','#frmAlterar');
	rQtmensagem_alerta = $('label[for="qtmensagem_alerta"]','#frmAlterar');
	rIdconversao       = $('label[for="idconversao"]','#frmAlterar');
	rDtultima_execucao = $('label[for="dtultima_execucao"]','#frmAlterar');
	rIdativo           = $('label[for="idativo"]','#frmAlterar');
	rLblMinutos           = $('label[for="lblMinutos"]','#frmAlterar');
	rIdreprocessa_mensagem = $('label[for="idreprocessa_mensagem"]','#frmAlterar');

	rCdfase.addClass('rotulo').css({'width':'160px'});
	rNmfase.addClass('rotulo').css({'width':'160px'});
	rIdfase_controlada.addClass('rotulo').css({'width':'160px'});
	rCdfase_anterior.addClass('rotulo').css({'width':'160px'});
	rQttempo_alerta.addClass('rotulo').css({'width':'160px'});
	rQtmensagem_alerta.addClass('rotulo').css({'width':'160px'});
	rIdconversao.addClass('rotulo').css({'width':'160px'});
	rDtultima_execucao.addClass('rotulo').css({'width':'160px'});
	rIdativo.addClass('rotulo').css({'width':'160px'});
	rLblMinutos.addClass('rotulo-linha');
	rIdreprocessa_mensagem.addClass('rotulo').css({'width':'160px'});
	
	$('#cdfase','#frmAlterar').addClass('campo inteiro').css({'width':'80px'}).attr('maxlength', '8'); 
	$('#nmfase','#frmAlterar').addClass('campo').addClass('alpha').css({'width':'350px'});
	$('#idfase_controlada','#frmAlterar').addClass('campo').css({'margin': '3px 0px 3px 3px', 'height': '20px'});
	$('#cdfase_anterior','#frmAlterar').addClass('campo').css({'width':'350px'});
	$('#qttempo_alerta','#frmAlterar').addClass('campo inteiro').css({'width':'80px'}).attr('maxlength', '8'); 
	$('#qtmensagem_alerta','#frmAlterar').addClass('campo inteiro').css({'width':'80px'});
	$('#idconversao','#frmAlterar').addClass('campo').css({'margin': '3px 0px 3px 3px', 'height': '20px'});
	$('#dtultima_execucao','#frmAlterar').addClass('campo').css({'width':'150px'});
	$('#idativo','#frmAlterar').addClass('campo').css({'margin': '3px 0px 3px 3px', 'height': '20px'});
	$('#idreprocessa_mensagem','#frmAlterar').addClass('campo').css({'margin': '3px 0px 3px 3px', 'height': '20px'});
	
	layoutPadrao();
	return false;	
}

// botoes
function btnVoltar() {
		
	if ((cddopcao == 'C' || cddopcao == 'A') && $('#divDetalhes').css('display') == 'block'){
		$('#divDetalhes').css({'display': 'none'});
		$('#divFases').css({'display': 'block'});
		$("#btProsseguir","#divBotoes").text('Prosseguir');
	}else{
		estadoInicial();
	}
	
	return false;
}

function btnContinuar() {

	// Botão OK do cabeçalho
	if (!($('#cddopcao', '#frmCab').hasClass('campoTelaSemBorda'))) {
		$('input,select', '#frmCab').removeClass('campoErro');
		cddopcao = cCddopcao.val();
		cTodosCabecalho		= $('input[type="text"],select','#frmCab'); 	
		cTodosCabecalho.desabilitaCampo();
		
		if (cddopcao == 'C' || cddopcao == 'A'){
			buscaFases();			
		}else{
			$('#cdmotivo','#frmSpbfse').desabilitaCampo();
			
			$('#frmIncluir').css({'display': 'block'});
			$('#divDetalhes').css({'display': 'block'});
			$('#divBotoes').css({'display': 'block'});
			
			$("#btProsseguir","#divBotoes").show();
			$("#btProsseguir","#divBotoes").text('Concluir');
			
			formataIncluir();
			$('#dsmotivo','#frmSpbfse').focus();
		}
		
	}else{
		if ($("#btProsseguir","#divBotoes").text() == 'Prosseguir'){
			$("#btProsseguir","#divBotoes").text('Concluir');
			$('#divFases').css({'display': 'none'});
			$('#divDetalhes').css({'display': 'block'});
			
			$('#cdfase','#frmAlterar').desabilitaCampo();
			$('#dtultima_execucao','#frmAlterar').desabilitaCampo();
			
			$('#cdfase','#frmAlterar').val(glbTabCdfase);
			$('#nmfase','#frmAlterar').val(glbTabNmfase);
			$('#idfase_controlada','#frmAlterar').prop('checked', (1 == glbTabIdfase_controlada));
			$('#cdfase_anterior','#frmAlterar').val(glbTabCdfase_anterior);
			$('#qttempo_alerta','#frmAlterar').val(glbTabQttempo_alerta);
			$('#qtmensagem_alerta','#frmAlterar').val(glbTabQtmensagem_alerta);
			$('#idconversao','#frmAlterar').prop('checked', (1 == glbTabIdconversao));
			$('#dtultima_execucao','#frmAlterar').val(glbTabDtultima_execucao);
			$('#idreprocessa_mensagem','#frmAlterar').prop('checked', (1 == glbTabIdreprocessa_mensagem));
			$('#idativo','#frmAlterar').prop('checked', (1 == glbTabIdativo));
			$('#nmfase','#frmAlterar').focus();
			

			
		}else{
			if (cddopcao == 'A'){
				alteraFase();
			} else if(cddopcao == 'I'){
				incluiFase();
			}
		}
	}
	
	return false;
		
}

function buscaFases(){

	showMsgAguardo('Aguarde, buscando motivos de desligamento ...');
		
	$.ajax({        
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/spbfse/busca_fases.php', 
		data: {
			redirect: 'html_ajax'           
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();           
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			hideMsgAguardo();
			if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
				try{
					$('#divFases > fieldset:eq(0) > div').html(response);
					$('#frmAlterar').css({'display': 'block'});
					$('#divFases').css({'display': 'block'});
					$('#divDetalhes').css({'display': 'none'});
					$('#divBotoes').css({'display': 'block'});
					if (cddopcao == 'C'){
						$('input,select','#frmAlterar').desabilitaCampo();
						$("#btProsseguir","#divBotoes").hide();
					}else{
						$('input,select','#frmAlterar').habilitaCampo();
						$("#btProsseguir","#divBotoes").show();
						$("#btProsseguir","#divBotoes").text('Prosseguir');				
					}

					formataAlterar();					
					if ($('table > tbody > tr:eq(0) > td:eq(0)', '#divFases').text().trim() == 'Motivos não cadastrados'){
						$('table > tbody > tr:eq(0) > td:eq(0)', '#divFases').css('text-align', 'center');
					}
				} catch(error){
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
				}
			}else{
				try {
					eval( response );					
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
				}
			}
		}
	});
	
}

function incluiFase(){

	showMsgAguardo('Aguarde, alterando fase ...');
	
	var cdfase            = $('#cdfase','#frmIncluir').val();
	var nmfase            = $('#nmfase','#frmIncluir').val();
	var idfase_controlada = $('#idfase_controlada','#frmIncluir').is(':checked') ? 1 : 0;
	var cdfase_anterior   = $('#cdfase_anterior','#frmIncluir').val();
	var qttempo_alerta    = $('#qttempo_alerta','#frmIncluir').val();
	var qtmensagem_alerta = $('#qtmensagem_alerta','#frmIncluir').val();
	var idconversao       = $('#idconversao','#frmIncluir').is(':checked') ? 1 : 0;
	var idativo           = $('#idativo','#frmIncluir').is(':checked') ? 1 : 0;
	var idreprocessa_mensagem       = $('#idreprocessa_mensagem','#frmIncluir').is(':checked') ? 1 : 0;

	if (cdfase == 0){
		hideMsgAguardo();
		showError('error','Informe o código da fase.','Alerta - Ayllos',"unblockBackground(); $('#cdfase','#frmIncluir').focus();");
		return false;
	}

	if (nmfase.length == 0){
		hideMsgAguardo();
		showError('error','Informe o nome da fase.','Alerta - Ayllos',"unblockBackground(); $('#nmfase','#frmIncluir').focus();");
		return false;
	}

	if (qttempo_alerta.length == 0){
		hideMsgAguardo();
		showError('error','Informe o tempo alerta.','Alerta - Ayllos',"unblockBackground(); $('#qttempo_alerta','#frmIncluir').focus();");
		return false;
	}

	if (qtmensagem_alerta.length == 0){
		hideMsgAguardo();
		showError('error','Informe o mensagens alerta.','Alerta - Ayllos',"unblockBackground(); $('#qtmensagem_alerta','#frmIncluir').focus();");
		return false;
	}

	$.ajax({        
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/spbfse/inclui_fase.php', 
		data: {
			cdfase:            cdfase,
			nmfase:            nmfase,
			idfase_controlada: idfase_controlada,
			cdfase_anterior:   cdfase_anterior,
			qttempo_alerta:    qttempo_alerta,
			qtmensagem_alerta: qtmensagem_alerta,
			idconversao:       idconversao,
			idativo:           idativo,
			idreprocessa_mensagem:       idreprocessa_mensagem,
			redirect: 'html_ajax'           
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();           
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			hideMsgAguardo();
			try{
				eval( response );
			} catch(error){
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
			}			
		}
	});
	
}

function alteraFase(){

	showMsgAguardo('Aguarde, alterando fase ...');
	
	var cdfase            = $('#cdfase','#frmAlterar').val();
	var nmfase            = $('#nmfase','#frmAlterar').val();
	var idfase_controlada = $('#idfase_controlada','#frmAlterar').is(':checked') ? 1 : 0;
	var cdfase_anterior   = $('#cdfase_anterior','#frmAlterar').val();
	var qttempo_alerta    = $('#qttempo_alerta','#frmAlterar').val();
	var qtmensagem_alerta = $('#qtmensagem_alerta','#frmAlterar').val();
	var idconversao       = $('#idconversao','#frmAlterar').is(':checked') ? 1 : 0;
	var idativo           = $('#idativo','#frmAlterar').is(':checked') ? 1 : 0;
	var idreprocessa_mensagem       = $('#idreprocessa_mensagem','#frmAlterar').is(':checked') ? 1 : 0;

	if (cdfase == 0){
		hideMsgAguardo();
		showError('error','Informe o código da fase.','Alerta - Ayllos',"unblockBackground(); $('#cdfase','#frmAlterar').focus();");
		return false;
	}

	if (nmfase.length == 0){
		hideMsgAguardo();
		showError('error','Informe o nome da fase.','Alerta - Ayllos',"unblockBackground(); $('#nmfase','#frmAlterar').focus();");
		return false;
	}

	if (qttempo_alerta.length == 0){
		hideMsgAguardo();
		showError('error','Informe o tempo alerta.','Alerta - Ayllos',"unblockBackground(); $('#qttempo_alerta','#frmAlterar').focus();");
		return false;
	}

	if (qtmensagem_alerta.length == 0){
		hideMsgAguardo();
		showError('error','Informe o mensagens alerta.','Alerta - Ayllos',"unblockBackground(); $('#qtmensagem_alerta','#frmAlterar').focus();");
		return false;
	}

	$.ajax({        
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/spbfse/altera_fase.php', 
		data: {
			cdfase:            cdfase,
			nmfase:            nmfase,
			idfase_controlada: idfase_controlada,
			cdfase_anterior:   cdfase_anterior,
			qttempo_alerta:    qttempo_alerta,
			qtmensagem_alerta: qtmensagem_alerta,
			idconversao:       idconversao,
			idativo:           idativo,
			idreprocessa_mensagem:       idreprocessa_mensagem,
			redirect: 'html_ajax'           
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();           
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			hideMsgAguardo();
			try{
				eval( response );
			} catch(error){
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
			}			
		}
	});
	
}

function formataIncluir() {

	highlightObjFocus( $('#frmIncluir') );

	rCdfase            = $('label[for="cdfase"]','#frmIncluir');
	rNmfase            = $('label[for="nmfase"]','#frmIncluir');
	rIdfase_controlada = $('label[for="idfase_controlada"]','#frmIncluir');
	rCdfase_anterior   = $('label[for="cdfase_anterior"]','#frmIncluir');
	rQttempo_alerta    = $('label[for="qttempo_alerta"]','#frmIncluir');
	rQtmensagem_alerta = $('label[for="qtmensagem_alerta"]','#frmIncluir');
	rIdconversao       = $('label[for="idconversao"]','#frmIncluir');
	rDtultima_execucao = $('label[for="dtultima_execucao"]','#frmIncluir');
	rIdativo           = $('label[for="idativo"]','#frmIncluir');
	rLblMinutos           = $('label[for="lblMinutos"]','#frmIncluir');
	rIdreprocessa_mensagem    = $('label[for="idreprocessa_mensagem"]','#frmIncluir');
	
	rCdfase.addClass('rotulo').css({'width':'160px'});
	rNmfase.addClass('rotulo').css({'width':'160px'});
	rIdfase_controlada.addClass('rotulo').css({'width':'160px'});
	rCdfase_anterior.addClass('rotulo').css({'width':'160px'});
	rQttempo_alerta.addClass('rotulo').css({'width':'160px'});
	rQtmensagem_alerta.addClass('rotulo').css({'width':'160px'});
	rIdconversao.addClass('rotulo').css({'width':'160px'});
	rDtultima_execucao.addClass('rotulo').css({'width':'160px'});
	rIdativo.addClass('rotulo').css({'width':'160px'});
	rLblMinutos.addClass('rotulo-linha');
	rIdreprocessa_mensagem.addClass('rotulo').css({'width':'160px'});
	
	$('#cdfase','#frmIncluir').addClass('campo inteiro').css({'width':'80px'}).attr('maxlength', '8'); 
	$('#nmfase','#frmIncluir').addClass('campo').addClass('alpha').css({'width':'350px'});
	$('#idfase_controlada','#frmIncluir').addClass('campo').css({'margin': '3px 0px 3px 3px', 'height': '20px'});
	$('#cdfase_anterior','#frmIncluir').addClass('campo').css({'width':'350px'});
	$('#qttempo_alerta','#frmIncluir').addClass('campo inteiro').css({'width':'80px'}).attr('maxlength', '8'); 
	$('#qtmensagem_alerta','#frmIncluir').addClass('campo inteiro').css({'width':'80px'});
	$('#idconversao','#frmIncluir').addClass('campo').css({'margin': '3px 0px 3px 3px', 'height': '20px'});
	$('#dtultima_execucao','#frmIncluir').addClass('campo').css({'width':'150px'});
	$('#idreprocessa_mensagem','#frmIncluir').addClass('campo').css({'margin': '3px 0px 3px 3px', 'height': '20px'});
	
	layoutPadrao();
	return false;	
}

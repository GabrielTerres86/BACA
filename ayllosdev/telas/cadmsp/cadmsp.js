/*!
 * FONTE        : cadmsp.js
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 25/09/2017
 * OBJETIVO     : Biblioteca de funções da tela CADMSP
 * --------------
 * ALTERAÇÕES   :  27/12/2017 - Ajustes para não permitir informar acentuação. PRJ2339 - CRM(Odirlei-AMcom)
 * --------------
 */

// Definição de algumas variáveis globais 
var cddopcao		= 'C';
//Labels/Campos do cabeçalho
var cCddopcao, cTodosCabecalho, cTodosCadmsp, btnCab, glbTabCdmotivo, glbTabDsmotivo, glbTabFlgpessf, glbTabFlgpessj;


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
	$('#frmCadmsp').css({'display':'none'});
	$('#frmCadmsp').limpaFormulario();
	$('#divMotivos', '#frmCadmsp').css({'display':'none'});
	$('#divDetalhes', '#frmCadmsp').css({'display':'none'});
	$('#divBotoes').css({'display':'none'});
	$('input,select', '#frmCab').removeClass('campoErro');	
		
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

	/* ----------- Form Detalhe - INICIO ----------- */
	$('#dsmotivo','#frmCadmsp').unbind('keydown').bind('keydown', function(e) {
        
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			$('#flgpessf','#frmCadmsp').focus();
			return false;
		}	
	});
	
    $('#dsmotivo','#frmCadmsp').unbind('change').bind('change', function(e) {        
        $('#dsmotivo','#frmCadmsp').val( removeCaracteresInvalidos($('#dsmotivo','#frmCadmsp').val(),true) );
		return false;
	});
	
	$('#flgpessf','#frmCadmsp').unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 ) {
			if ($(this).is(':checked')){
				$(this).prop('checked', false);
				$(this).val(0);
			}else{
				$(this).prop('checked', true);
				$(this).val(1);
			}	
			$('#flgpessj','#frmCadmsp').focus();			
		}else if (e.keyCode == 9){
			$('#flgpessj','#frmCadmsp').focus();			
		}
		return false;
	});

	$('#flgpessj','#frmCadmsp').unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 ) {
			if ($(this).is(':checked')){
				$(this).prop('checked', false);
				$(this).val(0);
			}else{
				$(this).prop('checked', true);
				$(this).val(1);
			}	
			$("#btProsseguir","#divBotoes").focus();
		}else if (e.keyCode == 9){
			$("#btProsseguir","#divBotoes").focus();
		}
		return false;
	});

	/* ----------- Form Detalhe - FIM ----------- */
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

function formataMotivos() {
	
	// tabela
    var divRegistro = $('div.divRegistros', '#divMotivos');
    var tabela = $('table', divRegistro);
		
    $('#frmCadmsp').css({'margin-top': '5px'});
    divRegistro.css({'height': '207px', 'padding-bottom': '2px'});

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '70px';
    arrayLargura[1] = '312px';
    arrayLargura[2] = '100px';
	
    var arrayAlinha = new Array();
    arrayAlinha[0] = 'right';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'center';

   	tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');
	
	glbTabCdmotivo = undefined;
	glbTabDsmotivo = undefined;
	glbTabFlgpessf = undefined;
	glbTabFlgpessj = undefined;
	
	// Ordenação da tabela
	$('table.tituloRegistros > thead > tr', '#divMotivos').click( function() {
		glbTabCdmotivo = undefined;
		glbTabDsmotivo = undefined;
		glbTabFlgpessf = undefined;
		glbTabFlgpessj = undefined;
		// seleciona o registro que é clicado
		$('table.tituloRegistros > tbody > tr', divRegistro).click( function() {		
			glbTabCdmotivo = $('#hcdmotivo' ,$(this)).val();
			glbTabDsmotivo = $('#hdsmotivo' ,$(this)).val();
			glbTabFlgpessf = $('#hflgpessf' ,$(this)).val();
			glbTabFlgpessj = $('#hflgpessj' ,$(this)).val();

		});

	});
	// seleciona o registro que é clicado
	$('table.tituloRegistros > tbody > tr', divRegistro).click( function() {		
		glbTabCdmotivo = $('#hcdmotivo' ,$(this)).val();
		glbTabDsmotivo = $('#hdsmotivo' ,$(this)).val();
		glbTabFlgpessf = $('#hflgpessf' ,$(this)).val();
		glbTabFlgpessj = $('#hflgpessj' ,$(this)).val();
	});

	$('table > tbody > tr:eq(0)', divRegistro).click();

	highlightObjFocus( $('#frmCadmsp') );
	// Dados bancarios de repasse
	rCdmotivo = $('label[for="cdmotivo"]','#frmCadmsp');
	rDsmotivo = $('label[for="dsmotivo"]','#frmCadmsp');
	rFlgpessf = $('label[for="flgpessf"]','#frmCadmsp');
	rFlgpessj = $('label[for="flgpessj"]','#frmCadmsp');

	rCdmotivo.addClass('rotulo').css({'width':'160px'});
	rDsmotivo.addClass('rotulo').css({'width':'160px'});
	rFlgpessf.addClass('rotulo').css({'width':'160px'});
	rFlgpessj.addClass('rotulo').css({'width':'160px'});
	
	$('#cdmotivo','#frmCadmsp').addClass('campo pesquisa inteiro').css({'width':'80px'}).attr('maxlength', '8'); 
	$('#dsmotivo','#frmCadmsp').addClass('campo').addClass('alpha').css({'width':'350px'});
	$('#flgpessf','#frmCadmsp').addClass('campo');
	$('#flgpessj','#frmCadmsp').addClass('campo');
	
	layoutPadrao();
	return false;	
}

// botoes
function btnVoltar() {
		
	if (cddopcao == 'A' && $('#divDetalhes').css('display') == 'block'){
		$('#divDetalhes').css({'display': 'none'});
		$('#divMotivos').css({'display': 'block'});
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
		cTodosCadmsp		= $('input,select','#frmCadmsp');
		cTodosCabecalho.desabilitaCampo();
		
		if (cddopcao == 'C' || cddopcao == 'A'){
			buscaMotivos();			
		}else{
			cTodosCadmsp.habilitaCampo();
			$('#cdmotivo','#frmCadmsp').desabilitaCampo();
			
			$('#frmCadmsp').css({'display': 'block'});
			$('#divDetalhes').css({'display': 'block'});
			$('#divBotoes').css({'display': 'block'});
			
			$("#btProsseguir","#divBotoes").show();
			$("#btProsseguir","#divBotoes").text('Concluir');
			
			formataMotivos();
			$('#dsmotivo','#frmCadmsp').focus();
		}
		
	}else{
		if ($("#btProsseguir","#divBotoes").text() == 'Prosseguir'){
			$("#btProsseguir","#divBotoes").text('Concluir');
			$('#divMotivos').css({'display': 'none'});
			$('#divDetalhes').css({'display': 'block'});
			
			cTodosCadmsp.habilitaCampo();
			$('#cdmotivo','#frmCadmsp').desabilitaCampo();
			
			$('#cdmotivo','#frmCadmsp').val(glbTabCdmotivo);
			$('#dsmotivo','#frmCadmsp').val(glbTabDsmotivo);
			$('#flgpessf','#frmCadmsp').prop('checked', (1 == glbTabFlgpessf));
			$('#flgpessj','#frmCadmsp').prop('checked', (1 == glbTabFlgpessj));
			$('#dsmotivo','#frmCadmsp').focus();
			
		}else{
			if (cddopcao == 'A'){
				alteraMotivo();
			} else if(cddopcao == 'I'){
				incluiMotivo();
			}
		}
	}
	
	return false;
		
}

function buscaMotivos(){

	showMsgAguardo('Aguarde, buscando motivos de desligamento ...');
		
	$.ajax({        
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadmsp/busca_motivos.php', 
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
					$('#divMotivos > fieldset:eq(0) > div').html(response);
					$('#tbMotivos', 'frmCadmsp')
					$('#frmCadmsp').css({'display': 'block'});
					$('#divMotivos').css({'display': 'block'});
					$('#divDetalhes').css({'display': 'none'});
					$('#divBotoes').css({'display': 'block'});
					if (cddopcao == 'C'){
						cTodosCadmsp.desabilitaCampo();
						$("#btProsseguir","#divBotoes").hide();
					}else{
						cTodosCadmsp.habilitaCampo();
						$("#btProsseguir","#divBotoes").show();
						$("#btProsseguir","#divBotoes").text('Prosseguir');				
					}

					formataMotivos();					
					if ($('table > tbody > tr:eq(0) > td:eq(0)', '#divMotivos').text().trim() == 'Motivos não cadastrados'){
						$('table > tbody > tr:eq(0) > td:eq(0)', '#divMotivos').css('text-align', 'center');
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

function incluiMotivo(){

	showMsgAguardo('Aguarde, incluindo motivo de desligamento ...');
		
	var dsmotivo, flgpessf, flgpessj;
	
	dsmotivo = $('#dsmotivo','#frmCadmsp').val();
	flgpessf = $('#flgpessf','#frmCadmsp').is(':checked');
	flgpessj = $('#flgpessj','#frmCadmsp').is(':checked');
	
	if (flgpessf){ flgpessf = 1; } else { flgpessf = 0; }
	if (flgpessj){ flgpessj = 1; } else { flgpessj = 0; }
	
	// Se não informou motivo
	if (dsmotivo.length == 0){
		hideMsgAguardo();
		showError('error','Informe o motivo de desligamento.','Alerta - Ayllos',"unblockBackground(); $('#dsmotivo','#frmCadmsp').focus();");
		return false;
	}
	// Se não selecionou PF e PJ
	if (flgpessf == 0 && flgpessj == 0){
		hideMsgAguardo();
		showError('error','Informe o tipo de pessoa.','Alerta - Ayllos',"unblockBackground(); $('#flgpessf','#frmCadmsp').focus();");
		return false;		
	}
	
	$.ajax({        
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadmsp/inclui_motivo.php', 
		data: {
			dsmotivo: dsmotivo,
			flgpessf: flgpessf,
			flgpessj: flgpessj,
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

function alteraMotivo(){

	showMsgAguardo('Aguarde, alterando motivo de desligamento ...');
		
	var cdmotivo, dsmotivo, flgpessf, flgpessj;
	
	cdmotivo = $('#cdmotivo','#frmCadmsp').val();
	dsmotivo = $('#dsmotivo','#frmCadmsp').val();
	flgpessf = $('#flgpessf','#frmCadmsp').is(':checked');
	flgpessj = $('#flgpessj','#frmCadmsp').is(':checked');
	
	if (flgpessf){ flgpessf = 1; } else { flgpessf = 0; }
	if (flgpessj){ flgpessj = 1; } else { flgpessj = 0; }
	
	// Se não possuir código de motivo
	if (cdmotivo == 0){
		hideMsgAguardo();
		showError('error','C&oacute;digo de motivo inv&aacute;lido','Alerta - Ayllos',"unblockBackground(); $('#dsmotivo','#frmCadmsp').focus();");
		return false;
	}
	
	// Se não informou motivo
	if (dsmotivo.length == 0){
		hideMsgAguardo();
		showError('error','Informe o motivo de desligamento.','Alerta - Ayllos',"unblockBackground(); $('#dsmotivo','#frmCadmsp').focus();");
		return false;
	}
	// Se não selecionou PF e PJ
	if (flgpessf == 0 && flgpessj == 0){
		hideMsgAguardo();
		showError('error','Informe o tipo de pessoa.','Alerta - Ayllos',"unblockBackground(); $('#flgpessf','#frmCadmsp').focus();");
		return false;		
	}
	
	$.ajax({        
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadmsp/altera_motivo.php', 
		data: {
			cdmotivo: cdmotivo,
			dsmotivo: dsmotivo,
			flgpessf: flgpessf,
			flgpessj: flgpessj,
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
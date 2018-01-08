/*!
 * FONTE        : cadmde.js
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 21/09/2017
 * OBJETIVO     : Biblioteca de funções da tela CADMDE
 * --------------
 * ALTERAÇÕES   : 27/12/2017 - Ajustes para não permitir informar acentuação. PRJ2339 - CRM(Odirlei-AMcom)
 * --------------
 */

// Definição de algumas variáveis globais 
var cddopcao		= 'C';
//Labels/Campos do cabeçalho
var cCddopcao, cTodosCabecalho, cTodosCadmde, btnCab, glbTabCdmotivo, glbTabDsmotivo, glbTabFlgpessf, glbTabFlgpessj, glbTabTpmotivo;


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
	$('#frmCadmde').css({'display':'none'});
	$('#frmCadmde').limpaFormulario();
	$('#divMotivos', '#frmCadmde').css({'display':'none'});
	$('#divDetalhes', '#frmCadmde').css({'display':'none'});
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
	$('#dsmotivo','#frmCadmde').unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			$('#flgpessf','#frmCadmde').focus();
			return false;
		}	
	});
	
    $('#dsmotivo','#frmCadmde').unbind('change').bind('change', function(e) {        
        $('#dsmotivo','#frmCadmde').val( removeCaracteresInvalidos($('#dsmotivo','#frmCadmde').val(),true) );
		return false;
	});
	
	$('#flgpessf','#frmCadmde').unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 ) {
			if ($(this).is(':checked')){
				$(this).prop('checked', false);
				$(this).val(0);
			}else{
				$(this).prop('checked', true);
				$(this).val(1);
			}	
			$('#flgpessj','#frmCadmde').focus();			
		}else if (e.keyCode == 9){
			$('#flgpessj','#frmCadmde').focus();			
		}
		return false;
	});

	$('#flgpessj','#frmCadmde').unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 ) {
			if ($(this).is(':checked')){
				$(this).prop('checked', false);
				$(this).val(0);
			}else{
				$(this).prop('checked', true);
				$(this).val(1);
			}	
			$('#tpmotivo','#frmCadmde').focus();
		}else if (e.keyCode == 9){
			$('#tpmotivo','#frmCadmde').focus();
		}			
		return false;
	});

	$('#tpmotivo','#frmCadmde').unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 ) {
			btnContinuar();
			return false;
		}	
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
		
    $('#frmCadmde').css({'margin-top': '5px'});
    divRegistro.css({'height': '207px', 'padding-bottom': '2px'});

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '70px';
    arrayLargura[1] = '220px';
    arrayLargura[2] = '100px';
    arrayLargura[3] = '100px';
	
    var arrayAlinha = new Array();
    arrayAlinha[0] = 'right';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'left';

   	tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');
	
	glbTabCdmotivo = undefined;
	glbTabDsmotivo = undefined;
	glbTabFlgpessf = undefined;
	glbTabFlgpessj = undefined;
	glbTabTpmotivo = undefined;
	
	// Ordenação da tabela
	$('table.tituloRegistros > thead > tr', '#divMotivos').click( function() {
		glbTabCdmotivo = undefined;
		glbTabDsmotivo = undefined;
		glbTabFlgpessf = undefined;
		glbTabFlgpessj = undefined;
		glbTabTpmotivo = undefined;
		// seleciona o registro que é clicado
		$('table.tituloRegistros > tbody > tr', divRegistro).click( function() {		
			glbTabCdmotivo = $('#hcdmotivo' ,$(this)).val();
			glbTabDsmotivo = $('#hdsmotivo' ,$(this)).val();
			glbTabFlgpessf = $('#hflgpessf' ,$(this)).val();
			glbTabFlgpessj = $('#hflgpessj' ,$(this)).val();
			glbTabTpmotivo = $('#htpmotivo' ,$(this)).val();
		});

	});
	// seleciona o registro que é clicado
	$('table.tituloRegistros > tbody > tr', divRegistro).click( function() {		
		glbTabCdmotivo = $('#hcdmotivo' ,$(this)).val();
		glbTabDsmotivo = $('#hdsmotivo' ,$(this)).val();
		glbTabFlgpessf = $('#hflgpessf' ,$(this)).val();
		glbTabFlgpessj = $('#hflgpessj' ,$(this)).val();
		glbTabTpmotivo = $('#htpmotivo' ,$(this)).val();
	});

	$('table > tbody > tr:eq(0)', divRegistro).click();

	highlightObjFocus( $('#frmCadmde') );
	// Dados bancarios de repasse
	rCdmotivo = $('label[for="cdmotivo"]','#frmCadmde');
	rDsmotivo = $('label[for="dsmotivo"]','#frmCadmde');
	rFlgpessf = $('label[for="flgpessf"]','#frmCadmde');
	rFlgpessj = $('label[for="flgpessj"]','#frmCadmde');
	rTpmotivo = $('label[for="tpmotivo"]','#frmCadmde');

	rCdmotivo.addClass('rotulo').css({'width':'160px'});
	rDsmotivo.addClass('rotulo').css({'width':'160px'});
	rFlgpessf.addClass('rotulo').css({'width':'160px'});
	rFlgpessj.addClass('rotulo').css({'width':'160px'});
	rTpmotivo.addClass('rotulo').css({'width':'160px'});
	
	$('#cdmotivo','#frmCadmde').addClass('campo pesquisa inteiro').css({'width':'80px'}).attr('maxlength', '8'); 
	$('#dsmotivo','#frmCadmde').addClass('campo').addClass('alpha').css({'width':'350px'});
	$('#flgpessf','#frmCadmde').addClass('campo');
	$('#flgpessj','#frmCadmde').addClass('campo');
	$('#tpmotivo','#frmCadmde').addClass('campo').css({'width':'350px'});
	
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
		cTodosCadmde		= $('input,select','#frmCadmde');
		cTodosCabecalho.desabilitaCampo();
		
		if (cddopcao == 'C' || cddopcao == 'A'){
			buscaMotivos();			
		}else{
			cTodosCadmde.habilitaCampo();
			$('#cdmotivo','#frmCadmde').desabilitaCampo();
			
			$('#frmCadmde').css({'display': 'block'});
			$('#divDetalhes').css({'display': 'block'});
			$('#divBotoes').css({'display': 'block'});
			
			$("#btProsseguir","#divBotoes").show();
			$("#btProsseguir","#divBotoes").text('Concluir');
			
			formataMotivos();
			$('#dsmotivo','#frmCadmde').focus();
		}
		
	}else{
		if ($("#btProsseguir","#divBotoes").text() == 'Prosseguir'){
			$("#btProsseguir","#divBotoes").text('Concluir');
			$('#divMotivos').css({'display': 'none'});
			$('#divDetalhes').css({'display': 'block'});
			
			cTodosCadmde.habilitaCampo();
			$('#cdmotivo','#frmCadmde').desabilitaCampo();
			
			$('#cdmotivo','#frmCadmde').val(glbTabCdmotivo);
			$('#dsmotivo','#frmCadmde').val(glbTabDsmotivo);
			$('#flgpessf','#frmCadmde').prop('checked', (1 == glbTabFlgpessf));
			$('#flgpessj','#frmCadmde').prop('checked', (1 == glbTabFlgpessj));
			$('#tpmotivo','#frmCadmde').val(glbTabTpmotivo);
			$('#dsmotivo','#frmCadmde').focus();
			
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
		url: UrlSite + 'telas/cadmde/busca_motivos.php', 
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
					$('#frmCadmde').css({'display': 'block'});
					$('#divMotivos').css({'display': 'block'});
					$('#divDetalhes').css({'display': 'none'});
					$('#divBotoes').css({'display': 'block'});
					if (cddopcao == 'C'){
						cTodosCadmde.desabilitaCampo();
						$("#btProsseguir","#divBotoes").hide();
					}else{
						cTodosCadmde.habilitaCampo();
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
		
	var dsmotivo, flgpessf, flgpessj, tpmotivo;
	
	dsmotivo = $('#dsmotivo','#frmCadmde').val();
	flgpessf = $('#flgpessf','#frmCadmde').is(':checked');
	flgpessj = $('#flgpessj','#frmCadmde').is(':checked');
	tpmotivo = $('#tpmotivo','#frmCadmde').val();
	
	if (flgpessf){ flgpessf = 1; } else { flgpessf = 0; }
	if (flgpessj){ flgpessj = 1; } else { flgpessj = 0; }
	
	// Se não informou motivo
	if (dsmotivo.length == 0){
		hideMsgAguardo();
		showError('error','Informe o motivo de desligamento.','Alerta - Ayllos',"unblockBackground(); $('#dsmotivo','#frmCadmde').focus();");
		return false;
	}
	// Se não selecionou PF e PJ
	if (flgpessf == 0 && flgpessj == 0){
		hideMsgAguardo();
		showError('error','Informe o tipo de pessoa.','Alerta - Ayllos',"unblockBackground(); $('#flgpessf','#frmCadmde').focus();");
		return false;		
	}
	
	$.ajax({        
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadmde/inclui_motivo.php', 
		data: {
			dsmotivo: dsmotivo,
			flgpessf: flgpessf,
			flgpessj: flgpessj,
			tpmotivo: tpmotivo,
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
		
	var cdmotivo, dsmotivo, flgpessf, flgpessj, tpmotivo;
	
	cdmotivo = $('#cdmotivo','#frmCadmde').val();
	dsmotivo = $('#dsmotivo','#frmCadmde').val();
	flgpessf = $('#flgpessf','#frmCadmde').is(':checked');
	flgpessj = $('#flgpessj','#frmCadmde').is(':checked');
	tpmotivo = $('#tpmotivo','#frmCadmde').val();
	
	if (flgpessf){ flgpessf = 1; } else { flgpessf = 0; }
	if (flgpessj){ flgpessj = 1; } else { flgpessj = 0; }
	
	// Se não possuir código de motivo
	if (cdmotivo == 0){
		hideMsgAguardo();
		showError('error','C&oacute;digo de motivo inv&aacute;lido','Alerta - Ayllos',"unblockBackground(); $('#dsmotivo','#frmCadmde').focus();");
		return false;
	}
	
	// Se não informou motivo
	if (dsmotivo.length == 0){
		hideMsgAguardo();
		showError('error','Informe o motivo de desligamento.','Alerta - Ayllos',"unblockBackground(); $('#dsmotivo','#frmCadmde').focus();");
		return false;
	}
	// Se não selecionou PF e PJ
	if (flgpessf == 0 && flgpessj == 0){
		hideMsgAguardo();
		showError('error','Informe o tipo de pessoa.','Alerta - Ayllos',"unblockBackground(); $('#flgpessf','#frmCadmde').focus();");
		return false;		
	}
	
	$.ajax({        
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadmde/altera_motivo.php', 
		data: {
			cdmotivo: cdmotivo,
			dsmotivo: dsmotivo,
			flgpessf: flgpessf,
			flgpessj: flgpessj,
			tpmotivo: tpmotivo,
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
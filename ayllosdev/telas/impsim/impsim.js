/*!
 * FONTE        : impsim.js
 * CRIAÇÃO      : Diogo Carlassara
 * DATA CRIAÇÃO : 14/09/2017
 * OBJETIVO     : Biblioteca de funções da tela IMPSIM
 * --------------
 * ALTERAÇÕES   : 
 *				  
 *				  
 * --------------
 */
var glbIdcarga = 0;
var glbDscarga, glbDtfinal_vigencia, glbDsmensagem_aviso, glbNmarquivo;

$(document).ready(function() {

	estadoInicial();

	highlightObjFocus( $('#frmCab') );

	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});

	return false;

});

function estadoInicial() {

	$('#frmCab').css({'display':'block'});
	$('#divDetalhes').css({'display':'none'});

	$('#divBotoes', '#divTela').html('').css({'display':'block'});

	formataCabecalho();

	return false;

}

function controlaFoco() {

	$('#cddopcao','#frmCab').unbind('keypress').bind('keypress', function(e) {

		if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda') ) { return false; }

		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			acessa_rotina();
			return false;
		}
	});

	$('#btnOK','#frmCab').unbind('keypress').bind('keypress', function(e) {

		if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda') ) { return false; }

		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			acessa_rotina();
			return false;
		}
	});

	$('#btnOK','#frmCab').unbind('click').bind('click', function(){

		if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda') ) { return false; }
		acessa_rotina();
		return false;
	});

	return false;

}

function manter_rotina() {

	var cddopcao = $('#cddopcao','#frmCab').val();
	var nome_arquivo   = $('#nome_arquivo','#frmImportaArquivo').val();

	showMsgAguardo('Aguarde, carregando...');
	// Carrega conteúdo da opção através de ajax
	$.ajax({
		type: 'POST',
		url: UrlSite + 'telas/impsim/manter_rotina.php',
		data: {
			cddopcao: cddopcao,
		    nome_arquivo: nome_arquivo,
			redirect: 'script_ajax' // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			hideMsgAguardo();
			eval(response);
		}
	});
    return false;
}

function acessa_rotina() {
	$('#cddopcao','#frmCab').desabilitaCampo();

	switch ($('#cddopcao','#frmCab').val()) {
		case 'I':
			acessaImportaArquivo();
			break;
		case 'E':
			acessaExportaArquivo();
			break;
	}
	return false;
}

function acessaImportaArquivo() {

    showMsgAguardo('Aguarde, carregando...');

	var cddopcao = $('#cddopcao','#frmCab').val();
    // Executa script atraves de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/impsim/form_importa_arquivo.php',
        data: {
				cddopcao: cddopcao,
			    redirect: 'html_ajax'
              },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
        },
        success: function(response) {
            hideMsgAguardo();
            $('#divDetalhes').html(response);
			formataImportaCarga();
        }
    });
    return false;
}

function acessaExportaArquivo() {

    showMsgAguardo('Aguarde, carregando...');

	var cddopcao = $('#cddopcao','#frmCab').val();

    // Executa script atraves de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/impsim/form_exporta_arquivo.php',
        data: {
				cddopcao: cddopcao,
				redirect: 'html_ajax'
              },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
        },
        success: function(response) {
            hideMsgAguardo();
            $('#divDetalhes').html(response);
			formataManterCarga();
        }
    });
    return false;
}

function formataCabecalho() {

	$('input,select', '#frmCab').removeClass('campoErro');
	$('#divTela').css({'display':'inline'}).fadeTo(0,0.1);
	removeOpacidade('divTela');

	cTodosCabecalho = $('input[type="text"],select','#frmCab');
	cTodosCabecalho.limpaFormulario();

	// cabecalho
	rCddopcao = $('label[for="cddopcao"]','#frmCab');

	cCddopcao = $('#cddopcao','#frmCab');

	//Rótulos
	rCddopcao.css('width','44px');

	//Campos
	cCddopcao.css({'width':'496px'}).habilitaCampo().focus();

	controlaFoco();
	layoutPadrao();

	return false;

}

function formataImportaCarga() {

	var cddopcao = $('#cddopcao','#frmCab').val();

	// labels
	rNome_arquivo       = $('label[for="nome_arquivo"]','#frmImportaArquivo');

	// campos
	cNome_arquivo       = $('#nome_arquivo','#frmImportaArquivo');

    rNome_arquivo.css('width','110px').addClass('rotulo');

	cNome_arquivo.addClass('campo').css('margin-top','4px');

	highlightObjFocus( $('#frmImportaArquivo') );
	layoutPadrao();

	$('#nome_arquivo','#frmImportaArquivo').unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }
		if ( e.keyCode == 13 || e.keyCode == 9 ) {
			$('#btConcluir','#frmImportaArquivo').focus();
			return false;
		}
	});

	$('#btConcluir','#frmImportaArquivo').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			validaImportacao();
			return false;
		}
	});

	$('#btConcluir','#frmImportaArquivo').unbind('click').bind('click', function(){
		validaImportacao();
		return false;
	});

	$('#btVoltar','#frmImportaArquivo').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			if (cddopcao == 'A')
				acessa_rotina();
			else
				estadoInicial();
			return false;
		}
	});

	$('#btVoltar','#frmImportaArquivo').unbind('click').bind('click', function(){
        estadoInicial();
		return false;
	});

	$('#divDetalhes').css({'display':'block'});

	return false;
}

function formataManterCarga() {

	$('#btConcluir','#frmImportaArquivo').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			confirmar_manter_rotina();
			return false;
		}
	});

	$('#btConcluir','#frmImportaArquivo').unbind('click').bind('click', function(){
		confirmar_manter_rotina();
	});

	$('#btVoltar','#frmImportaArquivo').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			estadoInicial();
			return false;
		}
	});

	$('#btVoltar','#frmImportaArquivo').unbind('click').bind('click', function(){
		estadoInicial();
		return false;
	});

	$('#divDetalhes').css({'display':'block'});

	layoutPadrao();

	return false;
}

function validaImportacao() {

	if ($('#nome_arquivo','#frmImportaArquivo').val() == '') {
	 	showError("error","Campo \"Nome do Arquivo\" &eacute; obrigat&oacute;rio.","Alerta - Ayllos","$('#nome_arquivo','#frmImportaArquivo').focus();");
	 	return false;
	}

	importaArquivo();
	return false;
}

function importaArquivo(){

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, transferindo arquivo...");
    // Carrega dados parametro através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/impsim/manter_rotina.php',
        data:{
        	nome_arquivo: $('#nome_arquivo','#frmImportaArquivo').val().replace(/.*(\/|\\)/, ''), //faz o replace do "fakepath" se tiver, retornando somente o nome do arquivo
            cddopcao: 'I',
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Erro-N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response){
            eval(response);
        }
    });
    return false;
}

function exportarArquivo() {

    showMsgAguardo('Aguarde, exportando arquivo...');
    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/impsim/manter_rotina.php',
        data: {
            cddopcao: 'E',
            redirect: 'script_ajax' // Tipo de retorno do ajax
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a exportação.','Alerta - Ayllos',"unblockBackground()");
        },
        success: function(response) {
        	hideMsgAguardo();

            if ((response.indexOf('alert(') == -1) && (response.indexOf('showError(') == -1)) {
                try {
                    eval(response);
                    return false;
                } catch (error) {
                    showError('error', '1-N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            } else {
                try {
                    eval(response);
                } catch (error) {
                	console.error(error);
                    hideMsgAguardo();
                    showError('error', '2-N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            }
        }
    });
    return false;
}
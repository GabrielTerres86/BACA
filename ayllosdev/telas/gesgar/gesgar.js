/*!
 * FONTE        : gesgarr.js
 * CRIAÇÃO      : Jean Michel
 * DATA CRIAÇÃO : 18/02/2016
 * OBJETIVO     : Biblioteca de funções da tela GESGAR
 * --------------
 * ALTERAÇÕES   : 
 *				
 * --------------
 */

var rCddopcao, rNrdemsgs, rNrdesnhs, cCddopcao, cNrdemsgs, cNrdesnhs;

$(document).ready(function() {
    estadoInicial();

    $('#cddopcao', '#frmCab').unbind('keypress').bind('keypress', function (e) {

        if ($('#cddopcao', '#frmCab').hasClass('campoTelaSemBorda')) { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {
            consultaDados();
            return false;
        }
    });

    $('#nrdemsgs', '#frmDados').unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#nrdesnhs', '#frmDados').focus();
            return false;
        }
    });

    $('#nrdesnhs', '#frmDados').unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            confirma();
            return false;
        }
    });

});

// seletores
function estadoInicial() {
    	
    $("#divDadosGESGAR").css('display', 'none');
	controlaLayout();	
}

function controlaLayout() {

    layoutPadrao();

    // Label Cabecalho
    rCddopcao = $('label[for="cddopcao"]', '#frmCab');

    // Label Campos
    rNrdemsgs = $('label[for="nrdesnhs"]', '#frmDados');
    rNrdesnhs = $('label[for="nrdemsgs"]', '#frmDados');
    
	// Campos
    cCddopcao = $('#cddopcao', '#frmCab');
    cNrdemsgs = $('#nrdemsgs', '#frmDados');
    cNrdesnhs = $('#nrdesnhs', '#frmDados');
	
    cBtnConcluir = $('#btnConcluir');
    cBtnVoltar = $('#btVoltar');

	var btnOK = $('#btnOK','#frmCab');
	
	rCddopcao.addClass('rotulo').css({'width':'68px'});
	cCddopcao.css({'width':'456px'});
	
	$('#divDadosGESGAR').css({ 'display': 'none' });

	cCddopcao.habilitaCampo();
	cBtnConcluir.hide();
    cBtnVoltar.hide();

	cBtnVoltar.hide();
	btnOK.habilitaCampo();
	
	cCddopcao.val("C");
	cCddopcao.focus();
}

function consultaDados() {
    
    if (!$('#divDadosGESGAR').is(':visible')) {
    
        $("#divDadosGESGAR").css('display', 'block');

        rNrdesnhs.addClass('rotulo').css({ 'width': '160px' });
        cNrdesnhs.css({ 'width': '35px' });

        rNrdemsgs.addClass('rotulo').css({ 'width': '160px' });
        cNrdemsgs.css({ 'width': '35px' });

        cCddopcao.desabilitaCampo();
        buscaDados();
    }
}

function buscaDados(){	
		
    if (cCddopcao.val() == "C") {
        cBtnVoltar.show();
        cBtnConcluir.hide();
    } else {
        cBtnConcluir.show();
        cBtnVoltar.show();
    }

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, buscando informa&ccedil;&otilde;es ...");
	
	// Executa script de consulta através de ajax
	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/gesgar/busca_dados.php", 
		data: {
		    cddopcao: cCddopcao.val(),
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
		    try {
		        hideMsgAguardo();
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});

}

function confirma() {
    showConfirmacao('Confirma altera&ccedil;&atilde;o dos par&acirc;metros?', 'Confirma&ccedil;&atilde;o - Ayllos', 'gravaDados()', 'cNrdemsgs.focus()', 'sim.gif', 'nao.gif');
}

function gravaDados() {

    if (cCddopcao.val() == "C") {
        estadoInicial();
    }

    if (cNrdemsgs.val() == '' || !parseInt(cNrdemsgs.val())) {
        cNrdemsgs.val("0");
        showError("error", "Informe um valor valido para quantidade de mensagem.", "Alerta - Ayllos", "cNrdemsgs.focus();");
        return false;
    } else if (cNrdesnhs.val() == '' || !parseInt(cNrdesnhs.val())) {
        cNrdesnhs.val("0");
        showError("error", "Informe um valor valido para quantidade de senha.", "Alerta - Ayllos", "cNrdesnhs.focus();");
        return false;
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, gravando informa&ccedil;&otilde;es ...");

    // Executa script de consulta através de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/gesgar/grava_dados.php",
        data: {
            cddopcao: cCddopcao.val(),
            nrdemsgs: cNrdemsgs.val(),
            nrdesnhs: cNrdesnhs.val(),            
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
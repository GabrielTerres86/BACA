/***********************************************************************
 Fonte: tab085.js                                                  
 Autor: Jonata - Mouts
 Data : Agosto/2018                Última Alteração: 
                                                                   
 Objetivo  : Permitie a consulta e cadastro de parametros referente ao SPB.
                                                                     
 Alterações:  11/04/2019 -  Remover filtro quando cdcooper for diferente de 3 (Aillos) - Bruno Luiz Katzjarowki - Mout's

************************************************************************/

/** 
 * Variaveis Auxiliares
*/
var __CDCOOPER = ""; //Bruno - PRJ 475
/**
 * FIM VARIAVEIS AUXILIARES
 */

$(document).ready(function () {

    estadoInicial();

});

function estadoInicial() {

    formataCabecalho();
        
    $('#cddopcao', '#frmCabTab085').habilitaCampo().focus().val('C');
    $('#frmFiltro').css('display', 'none');
    $('#divFiltro').css('display', 'none');
    $('#divBotoesFiltro').css('display', 'none');
    $('#frmTab085').css('display', 'none');
    $('#divTab085').html('').css('display', 'none');

    layoutPadrao();

}

function formataCabecalho() {

    $('label[for="cddopcao"]', '#frmCabTab085').css('width', '50px').addClass('rotulo');
    $('#cddopcao', '#frmCabTab085').css('width', '520px');
    $('#divTela').fadeTo(0, 0.1);
    removeOpacidade('divTela');
    $('#frmCabTab085').css('display', 'block');

    //highl2ightObjFocus($('#frmCabTab085'));
    $('#cddopcao', '#frmCabTab085').focus();

    //Ao pressionar botao cddopcao
    $('#cddopcao', '#frmCabTab085').unbind('keypress').bind('keypress', function (e) {

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $('#btOK', '#frmCabTab085').click();
            return false;
        }

    });

    //Ao clicar no botao OK
    $('#btOK', '#frmCabTab085').unbind('click').bind('click', function () {

		$('input,select').removeClass('campoErro');
		$('#cddopcao', '#frmCabTab085').desabilitaCampo();
	
		apresentaFormFiltro();
        		
    });

    //Ao pressionar botao OK
    $('#btOK', '#frmCabTab085').unbind('keypress').bind('keypress', function (e) {

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {


            $('#btOK', '#frmCabTab085').click();

			apresentaFormFiltro();            

        }

    });

    return false;

}

function formataFiltro(){

	highlightObjFocus( $('#frmFiltro') );   
    
    //Label dos campos
    rCdcooper = $('label[for="cdcooper"]','#frmFiltro');
        
    rCdcooper.css('width','83px');
            
    //Campos 
    cCdcooper = $('#cdcooper','#frmFiltro');
            
    cCdcooper.css({ 'width': '200px' }).habilitaCampo();
       
    $('#divFiltro').css('display', 'block');
    $('#frmFiltro').css('display', 'block');
    $('#divBotoesFiltro').css('display', 'block');

    //Ao pressionar botao cdcooper
    $('#cdcooper', '#frmFiltro').unbind('keypress').bind('keypress', function (e) {

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $('#btProsseguir', '#divBotoesFiltro').click();
            return false;
        }

    });

    layoutPadrao();

    cCdcooper.focus();

    return false;

}


function formataFormularioTab085() {

    highlightObjFocus($('#frmTab085'));

    //Label dos campos
    $('label[for="flgopstr"]', "#frmTab085").addClass("rotulo").css({ "width": "180px" });
    $('label[for="iniopstr"]', "#frmTab085").addClass("rotulo").css({ "width": "180px" });
    $('label[for="fimopstr"]', "#frmTab085").addClass("rotulo-linha").css({ "width": "30px" });
    $('label[for="flgoppag"]', "#frmTab085").addClass("rotulo").css({ "width": "180px" });
    $('label[for="inioppag"]', "#frmTab085").addClass("rotulo").css({ "width": "180px" });
    $('label[for="fimoppag"]', "#frmTab085").addClass("rotulo-linha").css({ "width": "30px" });
    $('label[for="vlmaxpag"]', "#frmTab085").addClass("rotulo").css({ "width": "180px" });
	$('label[for="flgopbol"]', "#frmTab085").addClass("rotulo").css({ "width": "180px" });
    $('label[for="iniopbol"]', "#frmTab085").addClass("rotulo").css({ "width": "180px" });
    $('label[for="fimopbol"]', "#frmTab085").addClass("rotulo-linha").css({ "width": "30px" });
    $('label[for="flgcrise"]', "#frmTab085").addClass("rotulo").css({ "width": "180px" });
    $('label[for="hrtrpen1"]', "#frmTab085").addClass("rotulo").css({ "width": "80px" });
    $('label[for="hrtrpen2"]', "#frmTab085").addClass("rotulo-linha").css({ "width": "80px" });
    $('label[for="hrtrpen3"]', "#frmTab085").addClass("rotulo-linha").css({ "width": "80px" });

    //Campos 
    $('#flgopstr', '#frmTab085').css({ 'width': '100px', 'text-align': 'left' });
    $('#iniopstr', '#frmTab085').css({ 'width': '100px', 'text-align': 'right' }).setMask('STRING', '99:99', ':', '');
    $('#fimopstr', '#frmTab085').css({ 'width': '100px', 'text-align': 'right' }).setMask('STRING', '99:99', ':', '');
    $('#flgoppag', '#frmTab085').css({ 'width': '100px', 'text-align': 'left' });
    $('#inioppag', '#frmTab085').css({ 'width': '100px', 'text-align': 'right' }).setMask('STRING', '99:99', ':', '');
    $('#fimoppag', '#frmTab085').css({ 'width': '100px', 'text-align': 'right' }).setMask('STRING', '99:99', ':', '');
    $('#vlmaxpag', '#frmTab085').css({ 'width': '235px'}).addClass('inteiro').attr('maxlength', '16').setMask("DECIMAL", "zzzz.zzz.zz9,99", "", "");
	$('#flgopbol', '#frmTab085').css({ 'width': '100px', 'text-align': 'left' });
    $('#iniopbol', '#frmTab085').css({ 'width': '100px', 'text-align': 'right' }).setMask('STRING', '99:99', ':', '');
    $('#fimopbol', '#frmTab085').css({ 'width': '100px', 'text-align': 'right' }).setMask('STRING', '99:99', ':', '');
    $('#flgcrise', '#frmTab085').css({ 'width': '100px', 'text-align': 'left' });
	$('#hrtrpen1', '#frmTab085').css({ 'width': '100px', 'text-align': 'right' }).setMask('STRING', '99:99', ':', '');
	$('#hrtrpen2', '#frmTab085').css({ 'width': '100px', 'text-align': 'right' }).setMask('STRING', '99:99', ':', '');
	$('#hrtrpen3', '#frmTab085').css({ 'width': '100px', 'text-align': 'right' }).setMask('STRING', '99:99', ':', '');

	
	// Ao pressionar do campo flgopstr
	$('#flgopstr', '#frmTab085').unbind('keypress').bind('keypress', function(e){
	
		if ( divError.css('display') == 'block' ) { return false; }		
		
		$('input,select').removeClass('campoErro');

		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

	        if ($(this).val() == 0) {

	            $('#iniopstr', '#frmTab085').val('00:00').desabilitaCampo();
	            $('#fimopstr', '#frmTab085').val('00:00').desabilitaCampo();
	            $('#flgoppag', '#frmTab085').focus();

	        } else {

	            $('#iniopstr', '#frmTab085').habilitaCampo();
	            $('#fimopstr', '#frmTab085').habilitaCampo();
	            $('#iniopstr', '#frmTab085').focus();
	            $('#iniopstr', '#frmTab085').select();

	        }

			return false;

		}
	});
	
		
	// Ao pressionar do campo iniopstr
	$('#iniopstr', '#frmTab085').unbind('keypress').bind('keypress', function(e){
	
		if ( divError.css('display') == 'block' ) { return false; }		
		
		$('input,select').removeClass('campoErro');

		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			$('#fimopstr', '#frmTab085').focus();
			$('#fimopstr', '#frmTab085').select();

			return false;

		}
		
	});
		
	
	// Ao pressionar do campo fimopstr
	$('#fimopstr', '#frmTab085').unbind('keypress').bind('keypress', function(e){
	
		if ( divError.css('display') == 'block' ) { return false; }		
		
		$('input,select').removeClass('campoErro');

		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			$('#flgoppag', '#frmTab085').focus();

			return false;

		}
		
	});
	
	// Ao pressionar do campo flgoppag
	$('#flgoppag', '#frmTab085').unbind('keypress').bind('keypress', function(e){
	
		if ( divError.css('display') == 'block' ) { return false; }		
		
		$('input,select').removeClass('campoErro');

		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

	        if ($(this).val() == 0) {

	            $('#inioppag', '#frmTab085').val('00:00').desabilitaCampo();
	            $('#fimoppag', '#frmTab085').val('00:00').desabilitaCampo();
	            $("#vlmaxpag", "#frmTab085").desabilitaCampo();
	            $('#flgopbol', '#frmTab085').focus();

	        } else {

	            $('#inioppag', '#frmTab085').habilitaCampo();
	            $('#fimoppag', '#frmTab085').habilitaCampo();
	            $("#vlmaxpag", "#frmTab085").habilitaCampo();
	            $('#inioppag', '#frmTab085').focus();
	            $('#inioppag', '#frmTab085').select();

	        }

			return false;

		}
	});
	
		
	// Ao pressionar do campo inioppag
	$('#inioppag', '#frmTab085').unbind('keypress').bind('keypress', function(e){
	
		if ( divError.css('display') == 'block' ) { return false; }		
		
		$('input,select').removeClass('campoErro');

		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			$('#fimoppag', '#frmTab085').focus();
			$('#fimoppag', '#frmTab085').select();

			return false;

		}
		
	});
	
	// Ao pressionar do campo fimoppag
	$('#fimoppag', '#frmTab085').unbind('keypress').bind('keypress', function(e){
	
		if ( divError.css('display') == 'block' ) { return false; }		
		
		$('input,select').removeClass('campoErro');

		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			$('#vlmaxpag', '#frmTab085').focus();

			return false;

		}
		
	});
			
	// Ao pressionar do campo vlmaxpag
	$("#vlmaxpag", "#frmTab085").unbind('keypress').bind('keypress', function (e) {

		if (divError.css('display') == 'block') { return false; }

		$('input,select').removeClass('campoErro');

		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			$('#flgopbol', '#frmTab085').focus();

			return false;

		}

	});
	
	// Ao pressionar do campo flgopbol
	$('#flgopbol', '#frmTab085').unbind('keypress').bind('keypress', function(e){
	
		if ( divError.css('display') == 'block' ) { return false; }		
		
		$('input,select').removeClass('campoErro');

		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			$('#iniopbol', '#frmTab085').focus();
			$('#iniopbol', '#frmTab085').select();

			return false;

		}
	});
	
	
	// Ao pressionar do campo iniopbol
	$('#iniopbol', '#frmTab085').unbind('keypress').bind('keypress', function(e){
	
		if ( divError.css('display') == 'block' ) { return false; }		
		
		$('input,select').removeClass('campoErro');

		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			$('#fimopbol', '#frmTab085').focus();
			$('#fimopbol', '#frmTab085').select();

			return false;

		}
		
	});	
	
	// Ao pressionar do campo fimopbol
	$('#fimopbol', '#frmTab085').unbind('keypress').bind('keypress', function(e){
	
		if ( divError.css('display') == 'block' ) { return false; }		
		
		$('input,select').removeClass('campoErro');

		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

		    if ($('#cdcooper', '#frmFiltro').val() != '0') {

		        $('#btConcluir', '#divBotoesTab085').focus();

		    } else {

		        $('#flgcrise', '#frmTab085').focus();

		    }
            
			return false;

		}
		
	});
	
	// Ao pressionar do campo flgcrise
	$('#flgcrise', '#frmTab085').unbind('keypress').bind('keypress', function(e){
	
		if ( divError.css('display') == 'block' ) { return false; }		
		
		$('input,select').removeClass('campoErro');

		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			$('#btConcluir', '#divBotoesTab085').focus();

			return false;

		}
		
	});
	
	// Ao pressionar do campo hrtrpen1
	$('#hrtrpen1', '#frmTab085').unbind('keypress').bind('keypress', function(e){
	
		if ( divError.css('display') == 'block' ) { return false; }		
		
		$('input,select').removeClass('campoErro');

		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			$('#hrtrpen2', '#frmTab085').focus();
			$('#hrtrpen2', '#frmTab085').select();

			return false;

		}
		
	});
	
	// Ao pressionar do campo hrtrpen2
	$('#hrtrpen2', '#frmTab085').unbind('keypress').bind('keypress', function(e){
	
		if ( divError.css('display') == 'block' ) { return false; }		
		
		$('input,select').removeClass('campoErro');

		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			$('#hrtrpen3', '#frmTab085').focus();
			$('#hrtrpen3', '#frmTab085').select();

			return false;

		}
		
	});
	
	// Ao pressionar do campo hrtrpen3
	$('#hrtrpen3', '#frmTab085').unbind('keypress').bind('keypress', function(e){
	
		if ( divError.css('display') == 'block' ) { return false; }		
		
		$('input,select').removeClass('campoErro');

		// Se é a tecla ENTER, TAB, F1
		if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

			$('#btConcluir', '#divBotoesTab085').focus();

			return false;

		}
		
	});
		
	
    $('#frmTab085').css('display', 'block');
    $('#divBotoesTab085').css('display', 'block');

    layoutPadrao();

	if ($('#cddopcao', '#frmCabTab085').val() == 'C') {
		
        $('input,select', '#frmTab085').desabilitaCampo();

    } else if ($('#cddopcao', '#frmCabTab085').val() == 'A') {

        $('input,select', '#frmTab085').habilitaCampo();
		($('#cdcooper','#frmFiltro').val() == 0) ? $('#flgcrise', '#frmTab085').habilitaCampo() : $('#flgcrise', '#frmTab085').desabilitaCampo();
		($('#cdcooper', '#frmFiltro').val() == 0) ? $('#iniopstr', '#frmTab085').desabilitaCampo() : $('#iniopstr', '#frmTab085').habilitaCampo();
		($('#cdcooper', '#frmFiltro').val() == 0) ? $('#fimopstr', '#frmTab085').desabilitaCampo() : $('#fimopstr', '#frmTab085').habilitaCampo();
		
		
		if($('#flgoppag','#frmTab085').val() == 0){
		
            $('#inioppag', '#frmTab085').val('00:00').desabilitaCampo();
			$('#fimoppag', '#frmTab085').val('00:00').desabilitaCampo();
			$('#vlmaxpag', '#frmTab085').val('0,00').desabilitaCampo();
							
		}else{
			
			$('#inioppag', '#frmTab085').habilitaCampo();
			$('#fimoppag', '#frmTab085').habilitaCampo();
			$('#vlmaxpag', '#frmTab085').habilitaCampo();
							
		}
		
		if($('#flgopstr','#frmTab085').val() == 0){
		
			$('#iniopstr', '#frmTab085').val('00:00').desabilitaCampo();
			$('#fimopstr', '#frmTab085').val('00:00').desabilitaCampo();
			$('#flgopstr', '#frmTab085').focus();
			 
		}else{
			
			$('#iniopstr', '#frmTab085').habilitaCampo();
			$('#fimopstr', '#frmTab085').habilitaCampo();
			$('#flgopstr', '#frmTab085').focus();
			
		}	

		$('#hrtrpen1', '#frmTab085').desabilitaCampo();
    	$('#hrtrpen2', '#frmTab085').desabilitaCampo();
    	$('#hrtrpen3', '#frmTab085').desabilitaCampo();
		
    } else {

    	$('input,select', '#frmTab085').desabilitaCampo();
    	$('#hrtrpen1', '#frmTab085').habilitaCampo();
    	$('#hrtrpen2', '#frmTab085').habilitaCampo();
    	$('#hrtrpen3', '#frmTab085').habilitaCampo();
    	$('#hrtrpen1', '#frmTab085').focus();
    	
    }

    $('#flgopstr').unbind('change').bind('change', function(){

        if ($(this).val() == 0) {

            $('#iniopstr', '#frmTab085').val('00:00').desabilitaCampo();
            $('#fimopstr', '#frmTab085').val('00:00').desabilitaCampo();

        } else {

            $('#iniopstr', '#frmTab085').habilitaCampo();
            $('#fimopstr', '#frmTab085').habilitaCampo();

        }
    });

    $('#flgoppag').unbind('change').bind('change', function(){

        if ($(this).val() == 0) {

            $('#inioppag', '#frmTab085').val('00:00').desabilitaCampo();
            $('#fimoppag', '#frmTab085').val('00:00').desabilitaCampo();
            $("#vlmaxpag", "#frmTab085").desabilitaCampo();

        } else {

            $('#inioppag', '#frmTab085').habilitaCampo();
            $('#fimoppag', '#frmTab085').habilitaCampo();
            $("#vlmaxpag", "#frmTab085").habilitaCampo();

        }
    });

    $('input', '#frmTab085').removeAttr('tabindex');

    return false;    

}
 

 
function controlaVoltar(tipo) {

    switch (tipo) {

        case '1':

            estadoInicial();

        break;

        case '2':
            //Se for Coooperativa aillos (3) Pode voltar para escolher a cooperativa, caso não, volta ao estado inicial
            if(__CDCOOPER == 3){
                $('#divTab085').html('').css('display','none');
                formataFiltro();
            }else{            
                estadoInicial();
            }
        break;

    }

    return false;

}

function alterarParametros() {

    var cddopcao = $('#cddopcao', '#frmCabTab085').val();
	var cdcopsel = $('#cdcooper', '#frmFiltro').val();
	var flgopstr = $('#flgopstr', '#frmTab085').val();
    var iniopstr = $('#iniopstr', '#frmTab085').val();
    var fimopstr = $('#fimopstr', '#frmTab085').val();
    var flgoppag = $('#flgoppag', '#frmTab085').val();
    var inioppag = $('#inioppag', '#frmTab085').val();
    var fimoppag = $('#fimoppag', '#frmTab085').val();
    var vlmaxpag = isNaN(parseFloat($('#vlmaxpag', '#frmTab085').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vlmaxpag', '#frmTab085').val().replace(/\./g, "").replace(/\,/g, "."));
	var flgopbol = $('#flgopbol', '#frmTab085').val();
    var iniopbol = $('#iniopbol', '#frmTab085').val();
    var fimopbol = $('#fimopbol', '#frmTab085').val();
    var flgcrise = $('#flgcrise', '#frmTab085').val();
    var hrtrpen1 = $('#hrtrpen1', '#frmTab085').val();
    var hrtrpen2 = $('#hrtrpen2', '#frmTab085').val();
    var hrtrpen3 = $('#hrtrpen3', '#frmTab085').val();

    $('input,select', '#frmTab085').removeClass('campoErro').desabilitaCampo();

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, alterando par&acirc;metros...");

    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/tab085/alterar_parametros.php",
        data: {
            cddopcao: cddopcao,
            cdcopsel: cdcopsel,
			flgopstr: flgopstr,
			iniopstr: iniopstr,
			fimopstr: fimopstr,
			flgoppag: flgoppag,
			inioppag: inioppag,
			fimoppag: fimoppag,
			vlmaxpag: vlmaxpag,
			flgopbol: flgopbol,
			iniopbol: iniopbol,
			fimopbol: fimopbol,
			flgcrise: flgcrise,	
			hrtrpen1: hrtrpen1,
            hrtrpen2: hrtrpen2,
			hrtrpen3: hrtrpen3,
            redirect: "html_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {            
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {            
			hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '$("#btVoltar","#divBotoesTab085").focus();');
            }
        }
    });

    return false;
}

function consultaParametros() {

    $('input,select', '#frmFiltro').removeClass('campoErro').desabilitaCampo();

    showMsgAguardo("Aguarde, buscando informa&ccedil;&otilde;es...");

    var cddopcao = $('#cddopcao', '#frmCabTab085').val();
    var cdcooper = normalizaNumero($('#cdcooper', '#frmFiltro').val());

   
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/tab085/consulta_parametros.php',
        data: {
            cddopcao: cddopcao,
            cdcooper: cdcooper,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Nao foi possivel concluir a operacao.', 'Alerta - Ayllos', '$("#cdcooper", "#frmFiltro").focus();');
        },
        success: function (response) {
            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {

                    $('#divTab085').html(response);

                    //Bruno - prj 475
                    var frm = "#frmTab085";
                    switch(cddopcao){
                        case 'A':
                            $('#estado_crise',frm).hide(); 
                            $('#trans_agendada',frm).hide();
                        break;
                        case 'H':
                            $('#spb_str',frm).hide();
                            $('#spb_pag',frm).hide();
                            $('#vr_boleto',frm).hide();
                            $('#flgcrise',frm).habilitaCampo();
                        break;
                    }
                    atribuiEventosCampos();
                    
                    return false;
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#cdcooper','#frmFiltro').focus();");
                }
            } else {
                try {

                    eval(response);
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#cdcooper','#frmFiltro').focus();");
                }
            }
        }
    });

    return false;

}



function apresentaFormFiltro() {   

    var cddopcao = $('#cddopcao', '#frmCabTab085').val();
       
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/tab085/monta_filtro.php',
        data: {
            cddopcao: cddopcao,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Nao foi possivel concluir a operacao.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function (response) {
            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {

                    $('#divFiltro').html(response);

                    //Bruno - PRJ 475 - Remover filtro quando cdcooper for diferente de 3 (Aillos)          
                    if(__CDCOOPER != 3){
                        $('#frmFiltro').hide();
                        consultaParametros();
                    }else{
                        if($('#cddopcao','#frmCabTab085').val() == 'H'){
                            $('#frmFiltro').hide();
                            consultaParametros();
                        }
                    }
                    //Fim - bruno prj 475
                    
                    return false;
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "estadoInicial();");
                }
            } else {
                try {

                    eval(response);
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "estadoInicial();");
                }
            }
        }
    });

    return false;

}


/**
 * Autor: Bruno Luiz Katzjarowski - Mout's
 * Data: 11/04/2019
 *  Atribuir eventos à campos
 */
function atribuiEventosCampos(){

    var frm = '#frmTab085';
    var secVrBoleto = '#vr_boleto';

    //Eventos: Parametros: VR-BOLETO
    var sectionVrBoleto = $(secVrBoleto, frm);


    var flgopbol = $('#flgopbol',sectionVrBoleto);
    if(flgopbol.val() == '0'){
        $('#iniopbol',sectionVrBoleto).desabilitaCampo();
        $('#fimopbol',sectionVrBoleto).desabilitaCampo();
    }

    $(flgopbol).unbind('change').bind('change',function(){
        var ini = $('#iniopbol',sectionVrBoleto);
        var fim = $('#fimopbol',sectionVrBoleto); 
        if($(this).val() == 0){
            ini.desabilitaCampo();
            fim.desabilitaCampo();
            ini.val('00:00');
            fim.val('00:00');
        }else{
            ini.habilitaCampo();
            fim.habilitaCampo();
            ini.val('00:00');
            fim.val('00:00');
        }
    });

}            
/*!
 * FONTE        : ldesco.js
 * CRIAÇÃO      : Otto - RKAM
 * DATA CRIAÇÃO : 17/11/2015
 * OBJETIVO     : Biblioteca de funções da tela LDESCO
 * --------------
 * ALTERAÇÕES   : 11/10/2017 - Inclusao dos campos Modelo e % Mínimo Garantia. (Lombardi - PRJ404)
 *                 
 *                27/08/2018 - remove acentos e caracteres empeciais no campo descrição.(Marco Amorim - Mout'S)
 * --------------
 */


$(document).ready(function() {

	estadoInicial();
	return false;

});

// seletores

function estadoInicial() {

	formataCabecalho();

	$('#divBotoesFiltro').css('display', 'none');
    $('#divBotoesRating').css('display', 'none');
    $('#frmFiltro').css('display', 'none');

    $('#frmFiltro').limpaFormulario();

    $('#cdopcao','#frmCab').habilitaCampo().focus().val('C');


    return false;

}

function formataCabecalho(){

	rCdOpcao = $('label[for="cdopcao"]','#frmCab');
	rCdCodigo = $('label[for="cdcodigo"]','#frmCab');
	rTDesconto = $('label[for="tdesconto"]','#frmCab');

	rCdCodigo.css({'width':'50px'});
	rTDesconto.css({'width':'100px'});

	rSCdOpcao = $('#cdopcao','#frmCab');
	rSCdCodigo = $('#cdcodigo','#frmCab');
	rSTDesconto = $('#tdesconto','#frmCab');
    rSDescricao = $('#descricao','#frmLdesco');
	rSTarifa = $('#tarifa','#frmLdesco');

	rSCdCodigo.css({'width':'75px'});
	rSTDesconto.css({'width':'75px'});
    rSDescricao.css({'width':'455px'});
	rSTarifa.css({'width':'137px'});


	rTaxaMora = $('label[for="taxamora"]','#frmLdesco');
	rTaxaDiaria = $('label[for="taxadiaria"]','#frmLdesco');
	rTaxaMensal = $('label[for="taxamensal"]','#frmLdesco');
	rTpctrato = $('label[for="tpctrato"]','#frmLdesco');

	rTaxaMora.addClass('rotulo').css({'width':'114px'});
	rTaxaDiaria.addClass('rotulo').css({'width':'114px'});
	rTaxaMensal.addClass('rotulo').css({'width':'114px'});
	rTpctrato.addClass('rotulo').css({'width':'114px'});

	rQtVias = $('label[for="qtvias"]','#frmLdesco');
	rTarifa = $('label[for="tarifa"]','#frmLdesco');
	rPermingr = $('label[for="permingr"]','#frmLdesco');
	rSituacao = $('label[for="situacao"]','#frmLdesco');

	rQtVias.css({'width':'175px'});
	rTarifa.css({'width':'175px'});
	rPermingr.addClass('rotulo-linha').css({'width':'175px'});
	rSituacao.css({'width':'150px'});

    rSSituacao = $('#situacao');
    rSSituacao.css({'width':'162px'});

	rDescricao = $('label[for="descricao"]','#frmLdesco');
	rDescricao.css({'width':'114px'});

	rCdOpcao.css('width', '40px').addClass('rotulo');
	rSCdOpcao.css('width', '525px');
    $('#divTela').css({ 'display': 'inline' }).fadeTo(0, 0.1);

    removeOpacidade('divTela');


	// Botão
    $('#btnOK', '#frmCab').unbind('click').bind('click', function () {

        if (divError.css('display') == 'block') { return false; }

        rSCdOpcao.desabilitaCampo();

       formataFiltro();       

    });

    rSCdOpcao.keypress(function(e) {
        if(e.which == 13) {
            $('#btnOK', '#frmCab').click();
            rSCdCodigo.focus();
        }
    });

     $('input,select', '#frmLdesco').unbind('keypress').bind("keypress", function (e) {
        if (e.keyCode == 13 || e.which == 9) {
            var allInputs = $("input,select");
            for (var i = 0; i < allInputs.length; i++) {
                if (allInputs[i] == this) {
                    while ((allInputs[i]).name == (allInputs[i + 1]).name) {
                        i++;
                    }

                    if ((i + 1) < allInputs.length) $(allInputs[i + 1]).focus();
                }
            }
        }
    });

    $('#tarifa', '#frmLdesco').unbind('keypress').bind('keypress', function(e) {
        if (e.which == 13 || e.which == 9) {
			if (rSCdOpcao.val() == 'I') {
				$('#tpctrato', '#frmLdesco').focus();
			} else {
				if ($('#tpctrato', '#frmLdesco').val() == 4) {
					$('#permingr', '#frmLdesco').focus();
				} else {
            e.preventDefault();
			$('#btSalvar','#divBotoesFiltroLdesco').click();
				}
			}
			return false;
        }
    });
	
    $('#tpctrato', '#frmLdesco').unbind('keypress').bind('keypress', function(e) {
        if (e.which == 13 || e.which == 9) {
			if ($('#tpctrato', '#frmLdesco').val() == 4) {
				$('#permingr', '#frmLdesco').focus();
			} else {
				e.preventDefault();
				$('#btSalvar','#divBotoesFiltroLdesco').click();
			}
			return false;
        }
    });
	
    $('#permingr', '#frmLdesco').unbind('keypress').bind('keypress', function(e) {
        if (e.which == 13 || e.which == 9) {
			e.preventDefault();
			$('#btSalvar','#divBotoesFiltroLdesco').click();
			return false;
        }
    });

	//Define ação para o campo tpctrato
	$('#tpctrato', '#frmLdesco').unbind('change').bind('change', function () {

		if ($(this).val() == 4) {
			$("#permingr", "#frmLdesco").val('100,00').habilitaCampo();
		} else {
			$("#permingr", "#frmLdesco").val('0,00').desabilitaCampo();
        }
    });

    highlightObjFocus($('#frmLdesco'));

	layoutPadrao();


	return false;
}


function btnVoltar(op) {


    switch (op) {

        case 1:
            estadoInicial();
        break;

        case 2:
            $('#divTabela').css('display','none');
            formataFiltro();
            $('#divBotoesFiltro').show();
    		$('#divBotoesFiltroLdesco').hide();

    		$('#frmLdesco').hide();
    		$('input[type="text"]', '#frmLdesco').limpaFormulario();
        break;

    }

}

function btnProsseguir() {
    cddopcao = $('#cdopcao','#frmCab').val();   

    cdcodigo = $('#cdcodigo','#frmFiltro').val();	
    tdesconto = $('#tdesconto','#frmFiltro').val();   
    
    $('#divBotoesFiltro').hide();
    $('#divBotoesFiltroLdesco').show();

    switch (cddopcao) {

        case 'C':
            buscaLinhaDesconto();

        break;

        case 'B':
            buscaLinhaDesconto();
        break;

        case 'L':
            buscaLinhaDesconto();
			
        break;        

        case 'A':
            alteraLinhaDesconto();

        break;

        case 'I':
            alteraLinhaDesconto();
        break;

        case 'E':
            showConfirmacao('Deseja prosseguir com a opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'excluiLinhaDesconto();', '$("#nrdconta","#frmFiltro").focus();', 'sim.gif', 'nao.gif');

        break;

    }

    return false;

}

/*
 * Formata Filtros Tela
 */
function formataFiltro() {

    //Limpa formulario
    $('input[type="text"]', '#frmFiltro').limpaFormulario().removeClass('campoErro');

    // rotulo
    $('label[for="cdcodigo"]', "#frmFiltro").css({ "width": "140px" });

    // campo
    $("#cdcodigo", "#frmFiltro").css({ 'width': '100px', 'text-align': 'right' }).addClass('inteiro').attr('maxlength', '3').habilitaCampo();
    $("#tdesconto", "#frmFiltro").css({ 'width': '100px', 'text-align': 'right' }).habilitaCampo();

    $("#descricao", "#frmLdesco").attr('maxlength', '25');

    $("#taxamora", "#frmLdesco").addClass('porcento_7').attr('maxlength', '10').css({ 'text-align': 'right' });
    $("#taxamensal", "#frmLdesco").addClass('porcento_7').attr('maxlength', '10').css({ 'text-align': 'right' });
	$("#tpctrato", "#frmLdesco").css({'width':'137px'});
    $("#permingr", "#frmLdesco").css({ 'text-align': 'right' }).setMask('DECIMAL','zz9,99','.','');
    $("#qtvias", "#frmLdesco").addClass('inteiro').attr('maxlength', '1');
    $("#taxadiaria", "#frmLdesco").addClass('inteiro');
    $("#tarifa", "#frmLdesco").addClass('inteiro').attr('maxlength', '1');

    $('#frmFiltro').css('display', 'block');
    $('#divBotoesFiltro').css('display', 'block');
    highlightObjFocus($('#frmFiltro'));

    window.setTimeout(function(){
        $('#frmFiltro *:input[type!=hidden]:first').focus();
    }, 50);

    // Para evitar a digitação de caracteres especiais que ocasiona erro na recuperação através de XML
    $("#descricao").bind("keyup", function () {
        this.value = removeTodosCaracteresInvalidos(this.value, 1);
    });

    // Bloqueia a digitação de caracteres com a tecla Alt + ..
    $("#descricao").bind("keydown", function (e) {
        if (e.altKey) { return false; }
    });

    //Evento para o campo cdagenci
    $("#cdcodigo","#frmFiltro").unbind('keypress').bind('keypress', function(e) {
        
        $(this).removeClass('campoErro');
        
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#tdesconto').focus();
            return false;
        }
    });
    
    $("#tdesconto","#frmFiltro").unbind('keypress').bind('keypress', function(e) {
        
        $(this).removeClass('campoErro');
        
        if (e.keyCode == 9 || e.keyCode == 13) {
            btnProsseguir();
            return false;
        }
    });

    layoutPadrao();

    $("#nrdconta", "#frmFiltro").focus();

    return false;

}

/*
 * Obter dados banco
 */
function obtemCabecalho() {

	var flgdigit;
	var aux_cdcodigo;
	var aux_tdesconto;
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando dados da linha de desconto ...");

}

/*
 * Formata Linha Desconto
 */
function formataLinhaDesconto() {
    cTodosLdesco = $('input[type="text"], select','#frmLdesco');
    cTodosLdesco.desabilitaCampo();
}

/*
 * Busca Linha Desconto
 */
function buscaLinhaDesconto(cdcodigo, tdesconto) {

    //Desabilita todos os campos do form
    $('input,select', '#frmFiltro').desabilitaCampo();

    var cddopcao = $('#cdopcao', '#frmCab').val();
    var cddcodigo = normalizaNumero($('#cdcodigo', '#frmFiltro').val());
    var tdesconto = $('#tdesconto', '#frmFiltro').val();

    $('input,select', '#frmFiltro').removeClass('campoErro');

    showMsgAguardo("Aguarde, buscando Linha de Desconto...");

    //Requisição para processar a opção que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/ldesco/busca_ldesco.php",
        data: {
            cddopcao: cddopcao,
            cdcodigo: cddcodigo,
            tdesconto: tdesconto,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "$('#nrdconta','#frmFiltro').focus();");
        },
        success: function (response) {

            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {

                    $('#divTabela').html(response);
                    return false;
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#nrdconta','#frmFiltro').focus();");
                }
            } else {
                try {

                    eval(response);
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#nrdconta','#frmFiltro').focus();");
                }
            }
        }

    });
    return false;
}

function bloqlibLinhaDesconto() {
    //Desabilita todos os campos do form
    $('input,select', '#frmFiltro').desabilitaCampo();

    var cddopcao = $('#cdopcao', '#frmCab').val();
    var cddcodigo = normalizaNumero($('#cdcodigo', '#frmFiltro').val());
    var tdesconto = $('#tdesconto', '#frmFiltro').val();

    $('input,select', '#frmFiltro').removeClass('campoErro');

    showMsgAguardo("Aguarde, buscando Linha de Desconto...");

    //Requisição para processar a opção que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/ldesco/bloqlib_ldesco.php",
        data: {
            cddopcao: cddopcao,
            cdcodigo: cddcodigo,
            tdesconto: tdesconto,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "$('#nrdconta','#frmFiltro').focus();");
        },
        success: function (response) {

            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {

                    $('#divTabela').html(response);
                    return false;
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#nrdconta','#frmFiltro').focus();");
                }
            } else {
                try {

                    eval(response);
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#nrdconta','#frmFiltro').focus();");
                }
            }
        }

    });
    return false;
}

function alteraLinhaDesconto() {
    //Desabilita todos os campos do form
    $('input,select', '#frmFiltro').desabilitaCampo();

    var cddopcao = $('#cdopcao', '#frmCab').val();
    var cddcodigo = normalizaNumero($('#cdcodigo', '#frmFiltro').val());
    var tdesconto = $('#tdesconto', '#frmFiltro').val();

    $('input,select', '#frmFiltro').removeClass('campoErro');

    showMsgAguardo("Aguarde, buscando Linha de Desconto...");

    //Requisição para processar a opção que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/ldesco/alterar_ldesco.php",
        data: {
            cddopcao: cddopcao,
            cdcodigo: cddcodigo,
            tdesconto: tdesconto,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "$('#nrdconta','#frmFiltro').focus();");
        },
        success: function (response) {
            
            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {

                    $('#divTabela').html(response);
                    return false;
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#nrdconta','#frmFiltro').focus();");
                }
            } else {
                try {

                    eval(response);
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#nrdconta','#frmFiltro').focus();");
                }
            }
        }

    });
    return false;
}

function alteraLinhaDescontoDo() {

    //Desabilita todos os campos do form
    $('input,select', '#frmFiltro').desabilitaCampo();

    var cddopcao = $('#cdopcao', '#frmCab').val();
    var cddcodigo = normalizaNumero($('#cdcodigo', '#frmFiltro').val());
    var tdesconto = $('#tdesconto', '#frmFiltro').val();

    var descricao  = $('#descricao', '#frmLdesco').val();
    var taxamora = normalizaNumero($('#taxamora', '#frmLdesco').val());
    var qtvias = normalizaNumero($('#qtvias', '#frmLdesco').val());
    var taxamensal = normalizaNumero($('#taxamensal', '#frmLdesco').val());
    var tarifa = normalizaNumero($('#tarifa', '#frmLdesco').val());
    var tpctrato = $('#tpctrato', '#frmLdesco').val();
    var permingr = normalizaNumero($('#permingr', '#frmLdesco').val());

    $('input,select', '#frmFiltro').removeClass('campoErro');

    showMsgAguardo("Aguarde, buscando Linha de Desconto...");

    //Requisição para processar a opção que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/ldesco/manter_ldesco.php",
        data: {
            cddopcao: cddopcao,
            cdcodigo: cddcodigo,
            tdesconto: tdesconto,
            descricao: descricao,
            taxamora: taxamora,
            qtvias: qtvias,
            taxamensal: taxamensal,
            tarifa: tarifa,
			tpctrato : tpctrato,
			permingr : permingr,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "$('#nrdconta','#frmFiltro').focus();");
        },
        success: function (response) {
            $('#frmLdesco').show();

            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {

                    $('#divTabela').html(response);
                    return false;
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#nrdconta','#frmFiltro').focus();");
                }
            } else {
                try {

                    eval(response);
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#nrdconta','#frmFiltro').focus();");
                }
            }
        }

    });
    return false;

}

function trocaBotao( funcaoSalvar,funcaoVoltar ) {
    
    $('#divBotoesFiltroLdesco','#divTela').html('');
    $('#divBotoesFiltroLdesco','#divTela').append('<a href="#" class="botao" id="btVoltar" onClick="'+funcaoVoltar+'; return false;" >Voltar</a>&nbsp;');
    $('#divBotoesFiltroLdesco','#divTela').append('<a href="#" class="botao" id="btSalvar" onClick="'+funcaoSalvar+'; return false;">Prosseguir</a>');
    
    return false;
}

function removeProsseguir(funcaoVoltar) {
    $ ('#divBotoesFiltroLdesco','#divTela').html('');
    $('#divBotoesFiltroLdesco','#divTela').append('<a href="#" class="botao" id="btVoltar" onClick="'+funcaoVoltar+'; return false;" >Voltar</a>&nbsp;');
    
    return false;
}

function excluiLinhaDesconto() {
    //Desabilita todos os campos do form
    $('input,select', '#frmFiltro').desabilitaCampo();

    var cddopcao = $('#cdopcao', '#frmCab').val();
    var cddcodigo = normalizaNumero($('#cdcodigo', '#frmFiltro').val());
    var tdesconto = $('#tdesconto', '#frmFiltro').val();

    $('input,select', '#frmFiltro').removeClass('campoErro');

    showMsgAguardo("Aguarde, buscando Linha de Desconto...");

    //Requisição para processar a opção que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/ldesco/excluir_ldesco.php",
        data: {
            cddopcao: cddopcao,
            cdcodigo: cddcodigo,
            tdesconto: tdesconto,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "$('#nrdconta','#frmFiltro').focus();");
        },
        success: function (response) {

            hideMsgAguardo();

            try {
                eval(response);
            } catch (error) {

                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#nrdconta','#frmFiltro').focus();");
            }
            
        }

    });
    return false;
}
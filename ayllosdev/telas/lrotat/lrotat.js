/*!
 * FONTE        : ldesco.js
 * CRIAÇÃO      : Otto - RKAM
 * DATA CRIAÇÃO : 17/11/2015
 * OBJETIVO     : Biblioteca de funções da tela LDESCO
 * --------------
 * ALTERAÇÕES   :
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

    return false;

}

function formataCabecalho(){


    // Form Lrotat
    lBranco = $('#labelBranco','#frmLrotat');
    lCecred = $('#labelCecred','#frmLrotat');
    lOperacional = $('#labelOperacional','#frmLrotat');

    cQtxCapOp = $('#QtxCapOp','#frmLrotat');
    cQtxCapCe = $('#QtxCapCe','#frmLrotat');
    cDVcontOp = $('#DVcontOp','#frmLrotat');
    cDVcontCe = $('#DVcontCe','#frmLrotat');
    cTfixa    = $('#Tfixa','#frmLrotat');
    cTvar     = $('#Tvar','#frmLrotat');
    cTmensal  = $('#Tmensal','#frmLrotat');

    cDesencfin1  = $('#dsencfin1','#frmLrotat');
    cDesencfin2  = $('#dsencfin2','#frmLrotat');
    cDesencfin3  = $('#dsencfin3','#frmLrotat');


    lBranco.addClass('rotulo labeltab-form');
    lOperacional.addClass('rotulo-linha txtNormalBold label-operacional');
    lCecred.addClass('rotulo-linha  txtNormalBold label-operacional');

    cTfixa.addClass('porcento_7');
    cTvar.addClass('porcento_7');
    cTmensal.addClass('porcento_7');

    cDesencfin1.addClass('campo-txt-contrato');
    cDesencfin2.addClass('campo-txt-contrato');
    cDesencfin3.addClass('campo-txt-contrato');


    


	rCdOpcao = $('label[for="cdopcao"]','#frmCab');
	rCdCodigo = $('label[for="cdcodigo"]','#frmCab');
	rTDesconto = $('label[for="tdesconto"]','#frmCab');

	rCdCodigo.css({'width':'50px'});
	rTDesconto.css({'width':'100px'});

	rSCdOpcao = $('#cdopcao','#frmCab');
	rSCdCodigo = $('#cdcodigo','#frmCab');
	rSTDesconto = $('#tdesconto','#frmCab');
	rSDescricao = $('#descricao','#frmLrotat');

	rSCdCodigo.css({'width':'75px'});
	rSTDesconto.css({'width':'75px'});
	rSDescricao.css({'width':'455px'});


	rTaxaMora = $('label[for="taxamora"]','#frmLrotat');
	rTaxaDiaria = $('label[for="taxadiaria"]','#frmLrotat');
	rTaxaMensal = $('label[for="taxamensal"]','#frmLrotat');

	rTaxaMora.addClass('rotulo').css({'width':'114px'});
	rTaxaDiaria.addClass('rotulo').css({'width':'114px'});
	rTaxaMensal.addClass('rotulo').css({'width':'114px'});

	rQtVias = $('label[for="qtvias"]','#frmLrotat');
	rTarifa = $('label[for="tarifa"]','#frmLrotat');
	rSituacao = $('label[for="situacao"]','#frmLrotat');

	rQtVias.css({'width':'175px'});
	rTarifa.css({'width':'175px'});
	rSituacao.css({'width':'150px'});

    rSSituacao = $('#situacao');
    rSSituacao.css({'width':'162px'});

	rDescricao = $('label[for="descricao"]','#frmLrotat');
	rDescricao.css({'width':'114px'});

	rCdOpcao.css('width', '40px').addClass('rotulo');
	rSCdOpcao.css('width', '530px');
    $('#divTela').css({ 'display': 'inline' }).fadeTo(0, 0.1);

    removeOpacidade('divTela');

    rSCdOpcao.habilitaCampo().focus().val('C');

	// Botão
    btnOK = $('#btnOK', '#frmCab');
	btnOK.unbind('click').bind('click', function () {

        if (divError.css('display') == 'block') { return false; }

        rSCdOpcao.desabilitaCampo();

       formataFiltro();       

    });

    rSCdOpcao.keypress(function(e) {
        if(e.which == 13) {
            btnOK.click();
            rSCdCodigo.focus();
        }
    });

    $('input,select', '#frmLrotat').bind("keydown", function (e) {
        if (e.keyCode == 13) {
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

    highlightObjFocus($('#frmLrotat'));

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

    		$('#frmLrotat').hide();
    		$('input[type="text"]', '#frmLrotat').limpaFormulario();
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
            buscaLinhaRotativo();

        break;

        case 'B':
            showConfirmacao('Deseja prosseguir com a opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'bloqlibLinhaDesconto();', '$("#nrdconta","#frmFiltro").focus();', 'sim.gif', 'nao.gif');

        break;

        case 'L':
            showConfirmacao('Deseja prosseguir com a opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'bloqlibLinhaDesconto();', '$("#nrdconta","#frmFiltro").focus();', 'sim.gif', 'nao.gif');

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

    $("#descricao", "#frmLrotat").attr('maxlength', '25');

    $("#taxamora", "#frmLrotat").addClass('inteiro').attr('maxlength', '3');
    $("#taxamensal", "#frmLrotat").addClass('inteiro').attr('maxlength', '3');
    $("#qtvias", "#frmLrotat").addClass('inteiro').attr('maxlength', '1');
    $("#tarifa", "#frmLrotat").addClass('inteiro');



    $('#frmFiltro').css('display', 'block');
    $('#divBotoesFiltro').css('display', 'block');
    highlightObjFocus($('#frmFiltro'));

    $('#frmFiltro *:input[type!=hidden]:first').focus();

    //Evento para o campo cdagenci
    $("#cdcodigo","#frmFiltro").unbind('keypress').bind('keypress', function(e) {
        
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
	showMsgAguardo("Aguarde, carregando dados da linha de Cr&eacute;dito Rotativo  ...");

}

/*
 * Formata Linha Desconto
 */
function formataLinhaDesconto() {
    cTodosLdesco = $('input[type="text"], select','#frmLrotat');
    cTodosLdesco.desabilitaCampo();
}

/*
 * Busca Linha Desconto
 */
function buscaLinhaRotativo(cdcodigo, tdesconto) {

    //Desabilita todos os campos do form
    $('input,select', '#frmFiltro').desabilitaCampo();

    var cddopcao = $('#cdopcao', '#frmCab').val();
    var cddcodigo = normalizaNumero($('#cdcodigo', '#frmFiltro').val());

    $('input,select', '#frmFiltro').removeClass('campoErro');

    showMsgAguardo("Aguarde, buscando Linha de Cr&eacute;dito Rotativo ...");

    //Requisição para processar a opção que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/lrotat/busca_lrotat.php",
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

    showMsgAguardo("Aguarde, buscando Linha de Cr&eacute;dito Rotativo ...");

    //Requisição para processar a opção que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/lrotat/bloqlib_lrotat.php",
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
            $('#frmLrotat').show();

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

    showMsgAguardo("Aguarde, buscando Linha de Cr&eacute;dito Rotativo ...");

    //Requisição para processar a opção que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/lrotat/alterar_lrotat.php",
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
            $('#frmLrotat').show();
            $('#frmLrotat *:input[type!=hidden]:first').focus();

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


    var descricao  = $('#descricao', '#frmLrotat').val(); 
    var QtxCapOp   = normalizaNumero($('#QtxCapOp', '#frmLrotat').val());
    var DVcontOp   = normalizaNumero($('#DVcontOp', '#frmLrotat').val());
    var DVcontCe   = normalizaNumero($('#DVcontCe', '#frmLrotat').val());
    var qtdiavig   = normalizaNumero($('#qtdiavig', '#frmLrotat').val());
    var Tfixa      = normalizaNumero($('#Tfixa', '#frmLrotat').val());
    var Tvar       = normalizaNumero($('#Tvar', '#frmLrotat').val());
    var dsencfin1  = $('#dsencfin1', '#frmLrotat').val();
    var dsencfin2  = $('#dsencfin2', '#frmLrotat').val();
    var dsencfin3  = $('#dsencfin3', '#frmLrotat').val();


    $('input,select', '#frmFiltro').removeClass('campoErro');

    showMsgAguardo("Aguarde, buscando Linha de Cr&eacute;dito Rotativo ...");

    //Requisição para processar a opção que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/lrotat/manter_lrotat.php",
        data: {
            cddopcao: cddopcao,
            cdcodigo: cddcodigo,
            descricao: descricao,
            QtxCapOp:QtxCapOp, 
            DVcontOp:DVcontOp, 
            DVcontCe:DVcontCe,
            qtdiavig:qtdiavig, 
            Tfixa:Tfixa, 
            Tvar: Tvar,
            dsencfin1: dsencfin1,
            dsencfin2:dsencfin2,
            dsencfin3: dsencfin3, 
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "$('#nrdconta','#frmFiltro').focus();");
        },
        success: function (response) {
            $('#frmLrotat').show();

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

    showMsgAguardo("Aguarde, buscando Linha de Cr&eacute;dito Rotativo ...");

    //Requisição para processar a opção que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/lrotat/excluir_lrotat.php",
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
            $('#frmLrotat').show();

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
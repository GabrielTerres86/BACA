/*!
 * FONTE        : imgchq.js
 * CRIAÇÃO      : Fabricio
 * DATA CRIAÇÃO : 15/06/2012
 * OBJETIVO     : Biblioteca de funções da tela IMGCHQ
 * --------------
 * ALTERAÇÕES   : 23/07/2012 - Ajuste para chamar funcao de impressao em funcao gerarPDF() (Jorge).
 *                30/07/2012 - Ajuste para dar focus em campo apos escolha do tipo de remesssa. (Jorge).
 *                26/03/2013 - Ajustado a tela para novo layout padrão (David Kruger).
 *                03/11/2014 - Adicionado function para gerar o link para o cartão assinatura. (Douglas - Chamado 177877)
 *                08/05/2015 - Criado funcao limpaChequeTemp() para apagar imagens de cheque em diretorio temp. (Jorge/Elton) - SD 283911
 *                28/08/2015 - Criado funcao cobraTariva() para cobranca automática das tarifas ao imprimir uma imagem de cheque. (Lombardi) - Projeto Tarifas
 *                15/03/2016 - Projeto 316 - Buscar "certificado" e novo botão para gerar zip para download
 *                           - Passado 'cdcooper' para cobra_tarifa.php. (Guilherme/SUPERO)
 *                01/12/2016 - Incorporacao Transulcred - Novo campo CDAGECHQ quando SR (Guilherme/SUPERO)
 *
 * --------------
 */


var rNmrescop, rTiporeme, rDtcompen, rCompechq, rBancochq, rAgencchq, rContachq, rNumerchq,
    cNmrescop, cTiporeme, cDtcompen, cCompechq, cBancochq, cAgencchq, cContachq, cNumerchq,
    cCampos, cCartaoAs;


var lstCooperativas = new Array();
var lstCmc7 = new Array();
var cdcooper;

var nmrescop, tremessa, compechq, bancochq, agencchq, contachq, numerchq, datacomp;

var bGerarPdf, bSalvarImgs;

var imgchqF = false;
var imgchqV = false;
var flgerpdf = false;
var flbaiarq = false;
var selbaixa = '';
var aux_cdagechq = '';

$(document).ready(function () {

    controlaLayout();
    ControlaFocus();
    $('#tiporeme', '#frmConsultaImagem').focus();

});

function controlaLayout() {

    rNmrescop = $('label[for="nmrescop"]', '#frmConsultaImagem');
    rTiporeme = $('label[for="tiporeme"]', '#frmConsultaImagem');
    rDtcompen = $('label[for="dtcompen"]', '#frmConsultaImagem');
    rCompechq = $('label[for="compechq"]', '#frmConsultaImagem');
    rBancochq = $('label[for="bancochq"]', '#frmConsultaImagem');
    rAgencchq = $('label[for="agencchq"]', '#frmConsultaImagem');
    rContachq = $('label[for="contachq"]', '#frmConsultaImagem');
    rNumerchq = $('label[for="numerchq"]', '#frmConsultaImagem');

    cNmrescop = $('#nmrescop', '#frmConsultaImagem');
    cTiporeme = $('#tiporeme', '#frmConsultaImagem');
    cDtcompen = $('#dtcompen', '#frmConsultaImagem');
    cCompechq = $('#compechq', '#frmConsultaImagem');
    cBancochq = $('#bancochq', '#frmConsultaImagem');
    cAgencchq = $('#agencchq', '#frmConsultaImagem');
    cContachq = $('#contachq', '#frmConsultaImagem');
    cNumerchq = $('#numerchq', '#frmConsultaImagem');
    cCartaoAs = $('#cartaoas', '#frmConsultaImagem');

    bCalendar = $('#f_trigger_a', '#frmConsultaImagem');
    bProcurar = $('#btnProcurar', '#frmConsultaImagem');
    bGerarPdf = $('#btnGerarPdf', '#frmConsultaImagem');
    bSalvarImgs = $('#btnSalvarImg', '#frmConsultaImagem');

    rNmrescop.addClass('rotulo').css({ 'width': '120px' });
    rTiporeme.addClass('rotulo-linha').css({ 'width': '170px', 'margin-left': '60px' });
    rDtcompen.addClass('rotulo').css({ 'width': '150px' });
    rBancochq.addClass('rotulo-linha').css({ 'width': '230px' });
    rCompechq.addClass('rotulo').css({ 'width': '150px' });
    rAgencchq.addClass('rotulo-linha').css({ 'width': '248px' });
    rContachq.addClass('rotulo').css({ 'width': '150px' });
    rNumerchq.addClass('rotulo-linha').css({ 'width': '248px' });

    cNmrescop.css({ 'width': '128px' });
    cDtcompen.css({ 'width': '100px' });
    cBancochq.css({ 'width': '100px' });
    cCompechq.css({ 'width': '100px' });
    cAgencchq.css({ 'width': '100px' });
    cContachq.css({ 'width': '100px' });
    cNumerchq.css({ 'width': '100px' });
    cCartaoAs.css({ 'margin-left': '60px' })

    bCalendar.css({ 'margin-top': '15px' });

    cCampos = $('#dtcompen, #compechq, #bancochq, #agencchq, #contachq, #numerchq', '#frmConsultaImagem');

    cCampos.habilitaCampo();

    if (cooploga != "3") {
        rTiporeme.css({ 'margin-left': '120px' });
        $('#divCooper').css({ 'display': 'none' });

    } else {
        rTiporeme.css({ 'margin-left': '10px' });

        $('#divConsultaImagem').css({ 'display': 'none' });

        buscaCooperativas();

    }

    $('#divDadosChq').css({ 'display': 'none' });
    $('#divImagem').css({ 'display': 'none' });

    highlightObjFocus($('#frmConsultaImagem'));

}

function mostraCamposChq() {

    cCampos.limpaFormulario();
    bGerarPdf.css({ 'display': 'none' });
    bSalvarImgs.css({ 'display': 'none' });
    $('#divBotoes', '#frmConsultaImagem').css({ 'display': 'block' });

    $('#divImagem').html("");
    $('#divImagem').css({ 'display': 'none' });

    if ($('#tiporeme', '#frmConsultaImagem').val() == "N") {
        $('#divDadosChq').css({ 'display': 'block' });

        cAgencchq.val('');

        cCompechq.css({ 'display': 'block' });
        cBancochq.css({ 'display': 'block' });
        cAgencchq.css({ 'display': 'block' });

        rCompechq.css({ 'display': 'block' });
        rBancochq.css({ 'display': 'block' });
        rAgencchq.css({ 'display': 'block' });

        cCartaoAs.css({ 'display': 'none' });

        rAgencchq.addClass('rotulo-linha').removeClass('rotulo').css({ 'width': '248px' });
        cAgencchq.css({ 'width': '100px' });

        cDtcompen.focus();
    } else
        if ($('#tiporeme', '#frmConsultaImagem').val() == "S") {

            buscaAgeCtl(0);

            $('#divDadosChq').css({ 'display': 'block' });

            cCompechq.css({ 'display': 'none' });
            cBancochq.css({ 'display': 'none' });

            rCompechq.css({ 'display': 'none' });
            rBancochq.css({ 'display': 'none' });

            cCartaoAs.css({ 'display': 'block' });
            cAgencchq.css({ 'display': 'block' });
            rAgencchq.css({ 'display': 'block' });

            rAgencchq.addClass('rotulo').removeClass('rotulo-linha').css({ 'width': '150px' });
            cAgencchq.css({ 'width': '100px' });

            cDtcompen.focus();
        } else {
            $('#divDadosChq').css({ 'display': 'none' });

            cCompechq.css({ 'display': 'none' });
            cBancochq.css({ 'display': 'none' });
            cAgencchq.css({ 'display': 'none' });

            rCompechq.css({ 'display': 'none' });
            rBancochq.css({ 'display': 'none' });
            rAgencchq.css({ 'display': 'none' });
        }

}

function buscaCooperativas() {

    // Executa script de consulta através de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/imgchq/busca_cooperativas.php",
        data: {
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });


}

function buscaAgeCtl(flag) {

    var cdcooper;

    if (cooploga == "3") {
        aux_cdcooper = cNmrescop.val();
    } else {
        aux_cdcooper = cooploga;
    }

    if (flag == 1) {
        //veio pela mudanca de Coop entao limpa
        aux_cdagechq = '';
    }

    if (aux_cdagechq == '') {
        $.ajax({
            type: 'POST',
            async: false,
            url: UrlSite + 'telas/imgchq/busca_agectl.php',
            data: {
                cdcooper: aux_cdcooper,
                redirect: 'script_ajax'
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
            },
            success: function (response) {

                try {
                    eval(response);
                    return false;
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
                }
            }
        });
    }

    cAgencchq.val(aux_cdagechq);

    return false;

}

function carregaCooperativas(qtdCooperativas) {

    for (var i = 0; i < qtdCooperativas; i++) {
        $('option', '#divCooper').remove();

    }


    for (var i = 0; i < qtdCooperativas; i++) {
        cNmrescop.append("<option id='" + i + "' value='" + lstCooperativas[i].cdcooper + "'>" + lstCooperativas[i].nmrescop + "</option>");
    }

}

function preConsultaCheque() {
    flgerpdf = false; // reseta flag de geracao de pdf
    flbaiarq = false; // reseta flag de baixar arquivo
    consultaCheque();
}

function preGerarPDF() {

    var cdagechq = cAgencchq.val();
    flgerpdf = true;
    flbaiarq = false;
    if (cTiporeme.val() == "S") {
        var metodoSim = "cobraTariva();";
        var metodoNao = "consultaCheque();";

        showConfirmacao("Deseja efetuar cobrança de tarifa?", "Confirma&ccedil;&atilde;o - Ayllos", metodoSim, metodoNao, "sim.gif", "nao.gif");
    } else {
        if (cBancochq.val() == 85) {
            $.ajax({
                type: 'POST',
                dataType: 'html',
                url: UrlSite + 'telas/imgchq/verifica_agencia.php',
                data: {
                    cdagechq: cdagechq,
                    redirect: 'html_ajax'
                },
                error: function (objAjax, responseError, objExcept) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
                },
                success: function (response) {
                    fechaRotina($('#divUsoGenerico'), $('#divRotina'));
                    eval(response);
                    return false;
                }
            });
        } else {
            consultaCheque();
        }
    }
}

function preBaixaArquivo(lado) {
    flbaiarq = true;
    flgerpdf = false;
    selbaixa = lado;
    consultaCheque();
}

function cobraTariva() {

    var cdagechq = cAgencchq.val();
    var nrctachq = cContachq.val();

    if (cooploga == "3")
        cdcooper = cNmrescop.val();
    else
        cdcooper = cooploga;

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/imgchq/cobranca_tarifa.php',
        data: {
            cdagechq: cdagechq,
            nrctachq: nrctachq,
            cdcooper: cdcooper,
            redirect: 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function (response) {
            fechaRotina($('#divUsoGenerico'), $('#divRotina'));
            if (response.substr(0, 4) == "hide") {
                eval(response);
            } else {
                consultaCheque();
            }
            return false;
        }
    });
}

function consultaCheque() {

    showMsgAguardo("Aguarde, consultando cheque ...");

    $('#divImagem').html("");
    $('#divImagem').css({ 'display': 'none' });

    var dtcompen, cdcmpchq, cdbanchq, cdagechq, nrctachq, nrcheque, tpremess;

    dtcompen = cDtcompen.val();
    nrctachq = retiraCaracteres(cContachq.val(), "0123456789", true);
    nrcheque = retiraCaracteres(cNumerchq.val(), "0123456789", true);
    tpremess = cTiporeme.val();

    if (dtcompen == "") {
        hideMsgAguardo();
        showError("error", "Data de compensa&ccedil;&atilde;o n&atilde;o informada.", "Alerta - Ayllos", "$('#dtcompen','#frmConsultaImagem').focus()");
        return false;
    }


    cdagechq = retiraCaracteres(cAgencchq.val(), "0123456789", true);

    if ((!validaNumero(cdagechq, true, 0, 0)) || (cdagechq == "")) {
        hideMsgAguardo();
        showError("error", "Ag&ecirc;ncia inv&aacute;lida.", "Alerta - Ayllos", "$('#agencchq','#frmConsultaImagem').focus();");
        return false;
    }


    if (tpremess == "N") {
        cdcmpchq = retiraCaracteres(cCompechq.val(), "0123456789", true);
        cdbanchq = retiraCaracteres(cBancochq.val(), "0123456789", true);

        if ((!validaNumero(cdcmpchq, true, 0, 0)) || (cdcmpchq == "")) {
            hideMsgAguardo();
            showError("error", "Compe inv&aacute;lida.", "Alerta - Ayllos", "$('#compechq','#frmConsultaImagem').focus();");
            return false;
        }

        if ((!validaNumero(cdbanchq, true, 0, 0)) || (cdbanchq == "")) {
            hideMsgAguardo();
            showError("error", "Banco inv&aacute;lido.", "Alerta - Ayllos", "$('#bancochq','#frmConsultaImagem').focus();");
            return false;
        }
    } else
        if (tpremess == "S") {
            cdbanchq = 85;
        }

    if (cooploga == "3")
        cdcooper = cNmrescop.val();
    else
        cdcooper = cooploga;

    if ((!validaNumero(nrctachq, true, 0, 0)) || (nrctachq == "")) {
        hideMsgAguardo();
        showError("error", "Conta do cheque inv&aacute;lida.", "Alerta - Ayllos", "$('#contachq','#frmConsultaImagem').focus();");
        return false;
    }

    if ((!validaNumero(nrcheque, true, 0, 0)) || (nrcheque == "")) {
        hideMsgAguardo();
        showError("error", "N&uacute;mero do cheque inv&aacute;lido.", "Alerta - Ayllos", "$('#numechq','#frmConsultaImagem').focus();");
        return false;
    }

    imgchqF = false;
    imgchqV = false;

    // Executa script de consulta através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/imgchq/consulta_cheque.php',
        data: {
            cdcooper: cdcooper,
            dtcompen: dtcompen,
            cdcmpchq: cdcmpchq,
            cdbanchq: cdbanchq,
            cdagechq: cdagechq,
            nrctachq: nrctachq,
            nrcheque: nrcheque,
            gerarpdf: false,
            salvaimg: flgSvImg,
            tpremess: cTiporeme.val(),
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });

}

function baixarArquivo(rand, sidlog, frente, verso) {
    if (flbaiarq) {
        var quallado = selbaixa == 'F' ? frente : verso;
        var apagartb = selbaixa == 'F' ? verso : frente;
        window.open('download.php?keyrand=' + rand + '&sidlogin=' + sidlog + '&src=' + quallado + '&apagartb=' + apagartb, '_blank');
    }
}


function SalvarZip() {

    showMsgAguardo("Aguarde, gerando arquivo ZIP ...");

    var dtcompen, cdcmpchq, cdbanchq, cdagechq, nrctachq, nrcheque, tpremess;

    dtcompen = cDtcompen.val();
    nrctachq = retiraCaracteres(cContachq.val(), "0123456789", true);
    nrcheque = retiraCaracteres(cNumerchq.val(), "0123456789", true);
    tpremess = cTiporeme.val();

    if (dtcompen == "") {
        hideMsgAguardo();
        showError("error", "Data de compensa&ccedil;&atilde;o n&atilde;o informada.", "Alerta - Ayllos", "$('#dtcompen','#frmConsultaImagem').focus()");
        return false;
    }

    if (tpremess == "N") {
        cdcmpchq = retiraCaracteres(cCompechq.val(), "0123456789", true);
        cdbanchq = retiraCaracteres(cBancochq.val(), "0123456789", true);
        cdagechq = retiraCaracteres(cAgencchq.val(), "0123456789", true);

        if ((!validaNumero(cdcmpchq, true, 0, 0)) || (cdcmpchq == "")) {
            hideMsgAguardo();
            showError("error", "Compe inv&aacute;lida.", "Alerta - Ayllos", "$('#compechq','#frmConsultaImagem').focus();");
            return false;
        }

        if ((!validaNumero(cdbanchq, true, 0, 0)) || (cdbanchq == "")) {
            hideMsgAguardo();
            showError("error", "Banco inv&aacute;lido.", "Alerta - Ayllos", "$('#bancochq','#frmConsultaImagem').focus();");
            return false;
        }

        if ((!validaNumero(cdagechq, true, 0, 0)) || (cdagechq == "")) {
            hideMsgAguardo();
            showError("error", "Ag&ecirc;ncia inv&aacute;lida.", "Alerta - Ayllos", "$('#agencchq','#frmConsultaImagem').focus();");
            return false;
        }

    } else
        if (tpremess == "S") {
            cdbanchq = 85;
        }

    if (cooploga == "3")
        cdcooper = cNmrescop.val();
    else
        cdcooper = cooploga;

    if ((!validaNumero(nrctachq, true, 0, 0)) || (nrctachq == "")) {
        hideMsgAguardo();
        showError("error", "Conta do cheque inv&aacute;lida.", "Alerta - Ayllos", "$('#contachq','#frmConsultaImagem').focus();");
        return false;
    }

    if ((!validaNumero(nrcheque, true, 0, 0)) || (nrcheque == "")) {
        hideMsgAguardo();
        showError("error", "N&uacute;mero do cheque inv&aacute;lido.", "Alerta - Ayllos", "$('#numechq','#frmConsultaImagem').focus();");
        return false;
    }

    imgchqF = false;
    imgchqV = false;


    // Executa script de consulta através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/imgchq/baixar_arquivo.php',
        data: {
            cdcooper: cdcooper,
            dtcompen: dtcompen,
            cdcmpchq: cdcmpchq,
            cdbanchq: cdbanchq,
            cdagechq: agencchq,
            nrctachq: nrctachq,
            nrcheque: nrcheque,
            gerarpdf: false,
            salvaimg: flgSvImg,
            dsdocmc7: dsdocmc7,
            tpremess: cTiporeme.val(),
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });

}

function limpaChequeTemp(imgrefe, frente, verso) {
    // Executa script de consulta através de ajax
    // Apaga arquivos do temp apenas quando as duas imagens , frente e verso do cheque forem carregadas e nao for gerar pdf
    if (imgrefe == 'imgchqF') {
        imgchqF = true;
    } else if (imgrefe == 'imgchqV') {
        imgchqV = true;
    }
    // as duas imagens do cheque, frente e verso devem estar carregadas e que nao seja para imprimir pdf nem baixar arquivo
    if (imgchqF && imgchqV && !flgerpdf && !flbaiarq) {
        $.ajax({
            type: "POST",
            dataType: "html",
            url: UrlSite + "telas/imgchq/limpa_cheque_temp.php",
            data: {
                dsfrente: frente,
                dsdverso: verso,
                redirect: "script_ajax"
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            },
            success: function (response) {
                try {
                    eval(response);
                } catch (error) {
                    hideMsgAguardo();
                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
                }
            }
        });
    }
}

function gravaLog(dsdocmc7, nrdconta) {

    var dstransa = "Visualizacao do cheque CMC7: " + dsdocmc7;

    // Executa script de consulta através de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/imgchq/grava_log.php",
        data: {
            cdcooper: cdcooper,
            dstransa: dstransa,
            nrdconta: nrdconta,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

function gerarPDF() {

    if (flgerpdf) {
        $('#nmrescop', '#frmImpressao').remove();
        $('#tpremess', '#frmImpressao').remove();
        $('#cdcmpchq', '#frmImpressao').remove();
        $('#cdbanchq', '#frmImpressao').remove();
        $('#cdagechq', '#frmImpressao').remove();
        $('#nrctachq', '#frmImpressao').remove();
        $('#nrcheque', '#frmImpressao').remove();
        $('#dsdocmc7', '#frmImpressao').remove();
        $('#gerarpdf', '#frmImpressao').remove();
        $('#dtcompen', '#frmImpressao').remove();

        $('#frmImpressao').append('<input type="hidden" id="nmrescop" name="nmrescop" value="' + nmrescop + '"/>');
        $('#frmImpressao').append('<input type="hidden" id="tpremess" name="tpremess" value="' + tremessa + '"/>');
        $('#frmImpressao').append('<input type="hidden" id="cdcmpchq" name="cdcmpchq" value="' + compechq + '"/>');
        $('#frmImpressao').append('<input type="hidden" id="cdbanchq" name="cdbanchq" value="' + bancochq + '"/>');
        $('#frmImpressao').append('<input type="hidden" id="cdagechq" name="cdagechq" value="' + agencchq + '"/>');
        $('#frmImpressao').append('<input type="hidden" id="nrctachq" name="nrctachq" value="' + contachq + '"/>');
        $('#frmImpressao').append('<input type="hidden" id="nrcheque" name="nrcheque" value="' + numerchq + '"/>');
        $('#frmImpressao').append('<input type="hidden" id="dsdocmc7" name="dsdocmc7" value="' + lstCmc7 + '"/>');
        $('#frmImpressao').append('<input type="hidden" id="dtcompen" name="dtcompen" value="' + datacomp + '"/>');
        $('#frmImpressao').append('<input type="hidden" id="gerarpdf" name="gerarpdf" value="true"/>');

        var action = UrlSite + "telas/imgchq/consulta_cheque.php";

        carregaImpressaoAyllos("frmImpressao", action);
    }
}

function ControlaFocus() {

    $('#dtcompen', '#frmConsultaImagem').unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            if ($('#tiporeme', '#frmConsultaImagem').val() == "S") {
                $('#contachq', '#frmConsultaImagem').focus();
            } else {
                $('#compechq', '#frmConsultaImagem').focus();
            }
            return false;
        }
    });

    $('#compechq', '#frmConsultaImagem').unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#contachq', '#frmConsultaImagem').focus();
            return false;
        }
    });

    $('#contachq', '#frmConsultaImagem').unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            if ($('#tiporeme', '#frmConsultaImagem').val() == "S") {
                $('#numerchq', '#frmConsultaImagem').focus();
            } else {
                $('#bancochq', '#frmConsultaImagem').focus();
            }
            return false;
        }
    });


    $('#bancochq', '#frmConsultaImagem').unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#agencchq', '#frmConsultaImagem').focus();
            return false;
        }
    });

    $('#agencchq', '#frmConsultaImagem').unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#numerchq', '#frmConsultaImagem').focus();
            return false;
        }
    });


    $('#numerchq', '#frmConsultaImagem').unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            preConsultaCheque();
            return false;
        }
    });

}

/**
* Função para validar o numero da conta informado e montar o link para o Cartão de Assinatura
*/
function validarNumeroConta() {
    var cdcooper = $("#hdnCooper", "#frmConsultaImagem").val();
    var dscsersm = $("#hdnServSM", "#frmConsultaImagem").val();
    var nrdconta = cContachq.val();
    var tpremess = cTiporeme.val();

    // Limpar o link que está atualmente
    cCartaoAs.html("<a class='txtNormal' style='margin-left: 265px; margin-top: 7px; cursor:default' >&nbsp;&nbsp;Cart&atilde;o Ass.</a>");

    // Validar se o tipo de remessa é diferente "S" (Sua Remessa)
    if (tpremess != "S") {
        return false;
    }

    // Validar se possui numero de conta
    if (nrdconta == "") {
        return false;
    }

    // Validar se o número da conta é válido
    if (!validaNroConta(nrdconta)) {
        hideMsgAguardo();
        showError("error", "Conta/dv inv&aacute;lida.", "Alerta - Ayllos", "cContachq.focus()");
        return false;
    }

    // Marcarar o número da conta
    nrdconta = mascara(nrdconta, "####.###.#");

    cCartaoAs.html("<a class='txtNormal' style='margin-left: 265px; margin-top: 7px;' href='http://" + dscsersm + "/smartshare/Clientes/ViewerExterno.aspx?pkey=8O3ky&conta=" + nrdconta + "&cooperativa=" + cdcooper + "' target='_blank' >&nbsp;&nbsp;Cart&atilde;o Ass.</a>");
}

/*!
 * FONTE        : pactar.js
 * CRIACAO      : Jean Michel
 * DATA CRIACAO : 01/03/2016
 * OBJETIVO     : Biblioteca de funcoes da tela PACTAR
 * --------------
 * ALTERACOES   : 
 *				
 * --------------
 */

// Geral, Consulta e Desativacao
var rCddopcao, rCdpacote, rDspacote, rTppessoa, rCdtarifa_lancamento, rDtcancelamento;
var cCddopcao, cCdpacote, cDspacote, cTppessoa, cCdtarifa_lancamento, cDstarifa, cDtcancelamento;

var btnOK;

// Inclusao
var rCdpacoteInc, rDspacoteInc, rTppessoaInc, rCdtarifa_lancamentoInc, rDstarifaInc;
var cCdpacoteInc, cDspacoteInc, cTppessoaInc, cCdtarifa_lancamentoInc, cDstarifaInc;

// Variaveis para a validacao/inclusao de pacotes de tarifas
var nameObj;
var codTarifa;
var vlrCampo;

$(document).ready(function () {
    
    estadoInicial();
    
    $('#cddopcao', '#frmCab').unbind('keydown').bind('keydown', function (e) {

        if ($('#cddopcao', '#frmCab').hasClass('campoTelaSemBorda')) { return false; }
        
        if (e.keyCode == 9 || e.keyCode == 13) {
            verificaAcao('C');
            return false;
        }
    });

    $('#cdpacote', '#frmDados').unbind('keydown').bind('keydown', function (e) {
        
        if ($('#cdpacote', '#frmDados').hasClass('campoTelaSemBorda')) { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {
            //$('#cdpacote', '#frmDados').blur();
            buscaInformacoesPacote();
            return false;
        }
    });

    $('#cdtarifa_lancamentoInc', '#frmDados').unbind('keydown').bind('keydown', function (e) {

        if ($('#cdtarifa_lancamentoInc', '#frmDados').hasClass('campoTelaSemBorda')) { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#cdtarifa_lancamentoInc', '#frmDados').blur();
            //buscaInformacoesPacote();
            return false;
        }
    });
    

});

// seletores
function estadoInicial() {
    
    $("#divDadosPACTAR").css('display', 'none');
    $('#divConsulta').hide();
     
    controlaLayout();
}

function controlaLayout() {
    
    btnOK = $('#btnOK', '#frmCab');
    btnOK.prop("disabled",false);
    $('#cdpacote').prop('readonly', false);

    cTodosCabecalho = $('input[type="text"],select', '#frmDados');

    layoutPadrao();

    // Label Cabecalho
    rCddopcao = $('label[for="cddopcao"]', '#frmCab');
    
    //Label Campos Consulta e Desativar
    rCdpacote            = $('label[for="cdpacote"]', '#frmDados');
    rDspacote            = $('label[for="dspacote"]', '#frmDados');
    rTppessoa            = $('label[for="tppessoa"]', '#frmDados');
    rCdtarifa_lancamento = $('label[for="cdtarifa_lancamento"]', '#frmDados');
    rDtcancelamento      = $('label[for="dtcancelamento"]', '#frmDados');
    
    //Label Campos Inclusao
    rCdpacoteInc            = $('label[for="cdpacoteInc"]', '#frmDados');
    rDspacoteInc            = $('label[for="dspacoteInc"]', '#frmDados');
    rTppessoaInc            = $('label[for="tppessoaInc"]', '#frmDados');
    rCdtarifa_lancamentoInc = $('label[for="cdtarifa_lancamentoInc"]', '#frmDados');
    
    // Campos Consulta e Desativar
    cCddopcao            = $('#cddopcao', '#frmCab');
    cCdpacote            = $('#cdpacote', '#frmDados');
    cDspacote            = $('#dspacote', '#frmDados');
    cTppessoa            = $('#tppessoa', '#frmDados');
    cCdtarifa_lancamento = $('#cdtarifa_lancamento', '#frmDados');
    cDstarifa            = $('#dstarifa', '#frmDados');
    cDtcancelamento      = $('#dtcancelamento', '#frmDados');
    
    //Campos Inclusao
    cCdpacoteInc            = $('#cdpacoteInc', '#frmDados');
    cDspacoteInc            = $('#dspacoteInc', '#frmDados');
    cTppessoaInc            = $('#tppessoaInc', '#frmDados');
    cCdtarifa_lancamentoInc = $('#cdtarifa_lancamentoInc', '#frmDados');
    cDstarifaInc            = $('#dstarifaInc', '#frmDados');

    // Codigo e Descricao da Tarifa Inclusao
    rCdtarifa_lancamentoInc.addClass('rotulo').css({ 'width': '120px' });
    cCdtarifa_lancamentoInc.css({ 'width': '50px' });
    cDstarifaInc.css({ 'width': '350px' });

    // Codigo e Descricao do Pacote Inclusao
    rCdpacoteInc.addClass('rotulo').css({ 'width': '120px' });
    cCdpacoteInc.css({ 'width': '50px' });
    rDspacoteInc.addClass('rotulo').css({ 'width': '120px' });
    cDspacoteInc.css({ 'width': '350px' });

    // Tipo de Pessoa Inclusao
    rTppessoaInc.addClass('rotulo').css({ 'width': '120px' });
    cTppessoaInc.css({ 'width': '130px' });

    cBtnConcluir = $('#btnConcluir');
    cBtnVoltar = $('#btVoltar');
        
    rCddopcao.addClass('rotulo').css({ 'width': '68px' });
    cCddopcao.css({ 'width': '456px' });

    // Codigo e Descricao do Pacote
    rCdpacote.addClass('rotulo').css({ 'width': '120px' });
    cCdpacote.css({ 'width': '50px' });
    rDspacote.addClass('rotulo').css({ 'width': '120px' });
    cDspacote.css({ 'width': '350px' });
    
    // Tipo de Pessoa
    rTppessoa.addClass('rotulo').css({ 'width': '120px' });
    cTppessoa.css({ 'width': '130px' });

    // Codigo e Descricao da Tarifa
    rCdtarifa_lancamento.addClass('rotulo').css({ 'width': '120px' });
    cCdtarifa_lancamento.css({ 'width': '50px' });
    cDstarifa.css({ 'width': '350px' });    

    //Data de Cancelamento
    rDtcancelamento.addClass('rotulo').css({ 'width': '120px' });
    cDtcancelamento.css({ 'width': '100px' });

    $('#divDadosPACTAR').css({ 'display': 'none' });

    cCddopcao.habilitaCampo();
    cBtnConcluir.hide();
    cBtnVoltar.hide();

    btnOK.habilitaCampo();

    cCddopcao.val("C");
    cCddopcao.focus();

    $('fieldset > input').css({'font-size': '12px', 'color': '#000000', 'border': '1px solid #777','height':'20px' });
    $('fieldset > select').css({ 'font-size': '12px', 'color': '#000000', 'border': '1px solid #777', 'height': '20px' });

    cTodosCabecalho.limpaFormulario();
    cTppessoa.val(0);
}

// Formata Browse da Tela
function formataTabela() {

    // Tabela
    $('#tabServicos').css({ 'display': 'block' });
    $('#divConsulta').css({ 'display': 'block' });

    var divRegistro = $('div.divRegistros', '#tabServicos');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    $('#tabIndice').css({ 'margin-top': '5px' });
    divRegistro.css({ 'height': '200px', 'width': '700px', 'padding-bottom': '2px' });

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    var arrayAlinha = new Array();

    if (cCddopcao.val() == "C" || cCddopcao.val() == "D") {
        arrayLargura[0] = '550px';
        arrayAlinha[0] = 'left';
        arrayAlinha[1] = 'center';
    }else{
        arrayLargura[0] = '30px';
        arrayLargura[1] = '520px';
        arrayAlinha[0] = 'center';
        arrayAlinha[1] = 'left';
        arrayAlinha[2] = 'center';
    }
    
    var metodoTabela = 'verDetalhe(this)';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);
    hideMsgAguardo();

    layoutPadrao();

    return false;
}

function validaDesativar() {

    if (cCdpacote.val() == 0 || cCdpacote.val() == "") {
        showError("error", "Informe um c&oacute;digo de Servi&ccedil;o Cooperativo v&aacute;lido.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
    }
    
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, validando Servi&ccedil;o Cooperativo...");

    // Executa script de consulta atrav?de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/pactar/valida_desativar.php",
        data: {
            cddopcao: cCddopcao.val(),
            cdpacote: cCdpacote.val(),
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

function efetivaDesativar() {

    if (cCdpacote.val() == 0 || cCdpacote.val() == "") {
        showError("error", "Informe um c&oacute;digo de servi&ccedil;o v&aacute;lido.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, desativando Servi&ccedil;o Cooperativo...");

    // Executa script de consulta atrav?de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/pactar/desativar_pacote.php",
        data: {
            cddopcao: cCddopcao.val(),
            cdpacote: cCdpacote.val(),
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

function buscaCodigoPacote() {
    
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, consultando c&oacute;digo...");

    // Executa script de consulta atrav?de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/pactar/consulta_codigo.php",
        data: {
            cddopcao: cCddopcao.val(),
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

function buscaInformacoesPacote() {

    if (cCdpacote.val() == "") {
        cDspacote.val("");
        $("#divLupa").css('display', 'block');
    }

    if (cCdpacote.val() == 0 || cCdpacote.val() == "") {
        showError("error", "Informe um c&oacute;digo de servi&ccedil;o v&aacute;lido.", "Alerta - Ayllos", "cCdpacote.focus();");
        $("#divLupa").css('display', 'block');
        return false;
    }
    
    if (cCdpacote.val() != "" && cDspacote.val() != "") {
        buscaDados();
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, consultando informa&ccedil;&otilde;es...");

    // Executa script de consulta atrav?de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/pactar/busca_informacoes_pacote.php",
        data: {
            cddopcao: cCddopcao.val(),
            cdpacote: cCdpacote.val(),
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

function verificaAcao(strAcao) {
        
    cBtnVoltar.show();

    btnOK.prop("disabled",true);

    if (strAcao == 'C') {
        if (cCddopcao.val() == 'C') {
            cDspacote.desabilitaCampo();
            cDstarifa.desabilitaCampo();
            //$("#divDtCancelamento").show();
            rDtcancelamento.show();
            cDtcancelamento.show();

            $("#divLupaTarifa").hide();
            $("#divLupa").css('display', 'block');
            if (!$('#divDadosPACTAR').is(':visible')) {
                $("#divDadosPACTAR").css('display', 'block');
                $("#divDados").css('display', 'block');
                $("#divDadosIncluir").css('display', 'none');
                cCddopcao.desabilitaCampo();
                cBtnConcluir.show();
                cCdpacote.focus();
            } else if (!$('#divConsulta').is(':visible')) {
                $("#divLupa").css('display', 'none');
                buscaInformacoesPacote();
            } else if ($('#divConsulta').is(':visible')) {
                estadoInicial();
                cCddopcao.focus();
            }
        } else if (cCddopcao.val() == 'D') {
            $("#divLupaTarifa").hide();
            $("#divLupa").css('display', 'block');
            //$("#divDtCancelamento").hide();
            cDspacote.desabilitaCampo();
            cDstarifa.desabilitaCampo();
            rDtcancelamento.hide();
            cDtcancelamento.hide();
            if (!$('#divDadosPACTAR').is(':visible')) {
                $("#divDadosPACTAR").css('display', 'block');
                $("#divDados").css('display', 'block');
                $("#divDadosIncluir").css('display', 'none');
                cCddopcao.desabilitaCampo();
                cBtnConcluir.show();
                cCdpacote.focus();
            } else {
                if ($('#divConsulta').is(':visible')) {
                    validaDesativar();
                } else {
                    buscaDados();
                }
            }
        } else if (cCddopcao.val() == 'I') {
            cDspacoteInc.habilitaCampo();
            cTppessoaInc.habilitaCampo();
            cCdtarifa_lancamentoInc.habilitaCampo();
            cDspacoteInc.focus();
            $("#divLupaTarifa").show();
            $("#divDados").css('display', 'none');
            cCddopcao.desabilitaCampo();
            if (!$('#divDadosPACTAR').is(':visible')) {
                $("#divDadosPACTAR").css('display', 'block');               
                $("#divDadosIncluir").css('display', 'block');                
                               
                buscaCodigoPacote();
                cBtnConcluir.show();
            } else {
                if (!$('#divConsulta').is(':visible')) {
                    validaIncluirPacote();
                } else {
                    validaDadosTarifas();
                }
            }
        }

    } else if (strAcao == 'V') {
        /*cCdpacoteInc.habilitaCampo();
        cDspacoteInc.habilitaCampo();
        cTppessoaInc.habilitaCampo();
        cCdtarifa_lancamentoInc.habilitaCampo();
        
        cCdpacote.habilitaCampo();
        cDspacote.habilitaCampo();
        cTppessoa.habilitaCampo();
        cCdtarifa_lancamento.habilitaCampo();*/
        if (cCddopcao.val() == 'C' || cCddopcao.val() == 'D') {
            $("#divLupa").show();
            cCdpacoteInc.habilitaCampo();
            cDspacoteInc.desabilitaCampo();
            cTppessoaInc.desabilitaCampo();
            cCdtarifa_lancamentoInc.desabilitaCampo();

            cCdpacote.habilitaCampo();
            cDspacote.desabilitaCampo();
            cTppessoa.desabilitaCampo();
            cCdtarifa_lancamento.desabilitaCampo();
        } else {
            cCdpacoteInc.habilitaCampo();
            cDspacoteInc.habilitaCampo();
            cTppessoaInc.habilitaCampo();
            cCdtarifa_lancamentoInc.habilitaCampo();

            cCdpacote.habilitaCampo();
            cDspacote.habilitaCampo();
            cTppessoa.habilitaCampo();
            cCdtarifa_lancamento.habilitaCampo();
        }
        
        if ($('#divConsulta').is(':visible')) {
            $("#divConsulta").css('display', 'none');
            cBtnConcluir.show();
        } else {
            estadoInicial();            
        }
    }   
}

function buscaDados() {
    
    if ((cCddopcao.val() == "C" || cCddopcao.val() == "D")  && (cCdpacote.val() == 0 || cCdpacote.val() == "")) {
        showError("error", "Informe um c&oacute;digo de servi&ccedil;o v&aacute;lido.", "Alerta - Ayllos", "cCdpacote.focus();");
        return false;
    }

    if (cCddopcao.val() != "D") {
        cBtnConcluir.hide();
    }
    
    $("#divLupa").css('display', 'none');
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, buscando informa&ccedil;&otilde;es ...");

    // Executa script de consulta atrav?de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/pactar/busca_dados.php",
        data: {
            cddopcao: cCddopcao.val(),
            cdpacote: cCdpacote.val(),
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            if (response.indexOf('showError("error"') == -1) {
                try {
                    hideMsgAguardo();
                    if (cCddopcao.val() == 'C' || cCddopcao.val() == 'D') {
                        $('#divConsulta').show();
                        $('#divConsulta').html(response);
                        formataTabela();
                        cCdpacote.prop('readonly', true);
                    }
                } catch (error) {
                    hideMsgAguardo();
                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
                } 
            }else{
                eval(response);
            }
        }
    });
}

function buscaTarifasIncluir() {
    
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, buscando informa&ccedil;&otilde;es ...");
    
    // Executa script de consulta atrav?de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/pactar/busca_tarifas.php",
        data: {
            cddopcao: cCddopcao.val(),
            tppessoa: cTppessoaInc.val(),
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                hideMsgAguardo();                
                $('#divConsulta').show();
                $('#divConsulta').html(response);
                formataTabela();
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

function validaIncluirPacote() {

    if (cCddopcao.val() != "I") {
        showError("error", "Opção inválida.", "Alerta - Ayllos", "estadoInicial();");
    }
    
    if (cCdpacoteInc.val() == "" || cCdpacoteInc.val() == 0) {
        showError("error", "C&oacute;digo do Servi&ccedil;o Cooperativo inv&aacute;lido.", "Alerta - Ayllos", "estadoInicial();");
        return false;
    } else if (cDspacoteInc.val() == "") {
        showError("error", "Informe a descri&ccedil;&atilde;o do Servi&ccedil;o Cooperativo.", "Alerta - Ayllos", "cDspacoteInc.focus();");
        return false;
    } else if (cTppessoaInc.val() == "" || cTppessoaInc.val() == 0) {
        showError("error", "Informe o tipo de pessoa.", "Alerta - Ayllos", "cTppessoaInc.focus();");
        return false;
    } else if (cCdtarifa_lancamentoInc.val() == "" || cCdtarifa_lancamentoInc.val() == 0) {
        showError("error", "Informe a tarifa do lan&ccedil;amento.", "Alerta - Ayllos", "cCdtarifa_lancamentoInc.focus();");
        return false;
    }
            
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, validando inclus&atilde;o de servi&ccedil;o...");

    // Executa script de consulta atraves de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/pactar/valida_pacote.php",
        data: {
            cddopcao: cCddopcao.val(),
            cdpacote: cCdpacoteInc.val(),
            dspacote: cDspacoteInc.val(),
            tppessoa: cTppessoaInc.val(),
            cdtarifa: cCdtarifa_lancamentoInc.val(),
            dstarifa: cDstarifaInc.val(),
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
                cCdpacoteInc.desabilitaCampo();
                cDspacoteInc.desabilitaCampo();
                cTppessoaInc.desabilitaCampo();
                cCdtarifa_lancamentoInc.desabilitaCampo();

            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

function incluirPacote() {

    var strTarifas = "";

    if (cCddopcao.val() != "I") {
        showError("error", "Opção inválida.", "Alerta - Ayllos", "estadoInicial();");
    }

    $(':checkbox:checked').each(function () {
        if (this.checked) {
            nameObj = this.name;
            codTarifa = nameObj.substr(11)
            vlrCampo = $("#txtCdtarifa" + codTarifa).val();

            if (strTarifas != "") {
                strTarifas = strTarifas + "|";
            }

            strTarifas = strTarifas + codTarifa + "#" + vlrCampo;
        }
        nameObj = "";
        codTarifa = "";

    });

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, incluindo Servi&ccedil;o Cooperativo...");
    
    // Executa script de consulta atraves de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/pactar/incluir_pacote.php",
        data: {
            cddopcao: cCddopcao.val(),
            cdpacote: cCdpacoteInc.val(),
            dspacote: cDspacoteInc.val(),
            tppessoa: cTppessoaInc.val(),
            cdtarifa: cCdtarifa_lancamentoInc.val(),
            dstarifa: cDstarifaInc.val(),
            strtarif: strTarifas,
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

function controlaPesquisaPacote() {
    
    if ($('#cddopcao', '#frmCab').val() == "I") {
        return false;
    }

    // Variável local para guardar o elemento anterior
    var campoAnterior = '';
    var bo, procedure, titulo, qtReg, filtros, colunas, titulo_coluna;

    // Nome do Formulário que estamos trabalhando
    var nomeFormulario = 'frmDados';
    var divRotina = 'divTela';
    
    //Remove a classe de Erro do form
    $('input,select', '#' + nomeFormulario).removeClass('campoErro');

    dspacote = '';
    titulo_coluna = "SERVIÇOS COPERATIVOS";
    
    bo = 'b1wgen0153.p';
    procedure = 'consulta-pacotes-tarifas';
    titulo = 'SERVIÇOS COPERATIVOS';
    qtReg = '20';
    filtros = 'Codigo;cdpacote;50px;S;' + cCdpacote.val() + ';S|Nome;dspacote;250px;S;' + cDspacote.val() + ';S|Tipo Pessoa;tppessoa;;S;;N|Tipo Pessoa;dspessoa;;S;;N|Data Cancelamento;dtcancelamento;;S;;N|Cod. Tarifa;cdtarifa_lancamento;0px;S;cdtarifa_lancamento;N|Dstarifa;dstarifa;;S;dstarifa;N|Opcao;cddopcao;150px;S;' + cCddopcao.val() + ';N';
    colunas = 'Codigo;cdpacote;56px;right;;S|Descricao;dspacote;205px;left;;S|COD;tppessoa;;left;;N|TIPO DE PESSOA;dspessoa;227px;left;;S|DATA CANCELAMENTO;dtcancelamento;;left;;S|COD. TARIFA;cdtarifa_lancamento;;left;;N|DESC. TARIFA;dstarifa;;left;;N|OPCAO;cddopcao;;left;;N';
    mostraPesquisa(bo, procedure, titulo, qtReg, filtros, colunas, '', 'cCdpacote.val();');
    
    $("#divPesquisa").css("left", "258px");
    $("#divPesquisa").css("top", "91px");
    $("#divCabecalhoPesquisa > table").css("width", "690px");
    $("#divCabecalhoPesquisa > table").css("float", "left");
    $("#divResultadoPesquisa > table").css("width", "690px");
    $("#divCabecalhoPesquisa").css("width", "690px");
    $("#divResultadoPesquisa").css("width", "690px");

    return false;

}

function controlaPesquisaTarifa() {

    // Se esta desabilitado o campo 
    if ($("#cdtarifa_lancamentoInc", "#frmDados").prop("disabled") == true) {
        return;
    }
    
    // Verifica se o tipo de pessoa já foi informado
    if(cTppessoaInc.val() == 0 && cCddopcao.val() == "I"){
        showError("error", "Primeiro informe o Tipo de Pessoa.", "Alerta - Ayllos", "cTppessoaInc.focus();");
        return false;
    } else if (cTppessoa.val() == 0 && cCddopcao.val() == "C") {
        showError("error", "Primeiro informe o Tipo de Pessoa.", "Alerta - Ayllos", "cTppessoa.focus();");
        return false;
    }

    // Variável local para guardar o elemento anterior
    var campoAnterior = '';
    var bo, procedure, titulo, qtReg, filtros, colunas, titulo_coluna;
    var dsdgrupo, cdsubgru, dssubgru, cdcatego, dscatego, cdinctar, inpessoa, flglaman;

    // Nome do Formulário que estamos trabalhando
    var nomeFormulario = 'frmDados';

    var divRotina = 'divTela';
    
    //Remove a classe de Erro do form
    $('input,select', '#' + nomeFormulario).removeClass('campoErro');
        
    bo = 'b1wgen0153.p';
    procedure = 'lista-tarifas-pactar';
    titulo = 'Tarifas';
    qtReg = '20';
    
    filtros  = 'Grupo;cddgrupo;100px;N;;N|Desc;dsdgrupo;150px;N;;N|';               //GRUPO
    filtros += 'Subgrupo;cdsubgru;100px;N;;N|Desc;dssubgru;150px;N;;N|';  //SUBGRUPO
    filtros += 'Categoria;cdcatego;100px;N;;N|Desc;dscatego;150px;N;;N|'; //CATEGORIA
    filtros += 'Codigo;cdtarifa_lancamentoInc;100px;S;' + cCdtarifa_lancamentoInc.val() + ';S|';
    filtros += 'Codigo;tppessoa;100px;S;' + cTppessoaInc.val() + ';N|';
    filtros += 'Descricao;dstarifaInc;300px;S;' + cDstarifaInc.val() + ';S';  //TARIFA

    colunas = 'Cod;cddgrupo;4%;right;;S|Grupo;dsdgrupo;21%;left;;S|Cod;cdsubgru;4%;right;;S|SubGrupo;dssubgru;21%;left;;S|Cod;cdcatego;4%;right;;S|Categoria;dscatego;21%;left;;S|Cod;cdtarifa;4%;right;;S|Descricao;dstarifa;21%;left;;S'; //TARIFA

    mostraPesquisa(bo, procedure, titulo, qtReg, filtros, colunas, '', 'cCdtarifa_lancamentoInc.blur();cBtnConcluir.focus();');
                                                                       
    $("#divPesquisa").css("left", "258px");
    $("#divPesquisa").css("top", "91px");
    $("#divCabecalhoPesquisa > table").css("width", "875px");
    $("#divCabecalhoPesquisa > table").css("float", "left");
    $("#divResultadoPesquisa > table").css("width", "890px");
    $("#divCabecalhoPesquisa").css("width", "890px");
    $("#divResultadoPesquisa").css("width", "890px");

    return false;

}

function carregaTarifa() {

    if (cCdtarifa_lancamentoInc.val() == "") {
        cDstarifaInc.val("");
        return false;
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, buscando informa&ccedil;&otilde;es ...");

    // Executa script de consulta atraves de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/pactar/busca_descricao_tarifa.php",
        data: {
            cddopcao: cCddopcao.val(),
            tppessoa: cTppessoaInc.val(),
            cdtarifa: cCdtarifa_lancamentoInc.val(),
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

function limpaTarifa() {
    cCdtarifa_lancamentoInc.val("");
    cDstarifaInc.val("");
}

function validaDadosTarifas() {
    
    var flgErro = false;
    var flgServ = false;

    $(':checkbox:checked').each(function () {
        if (this.checked) {
            flgServ = true;
            nameObj = this.name;
            codTarifa = nameObj.substr(11)
            vlrCampo = $("#txtCdtarifa" + codTarifa).val();
            if (vlrCampo == 0 || vlrCampo == "" || vlrCampo == undefined) {
                flgErro = true;
            }
        }
        nameObj   = "";
        codTarifa = "";

    });

    if (!flgServ) {
        showError("error", "Informe o(s) servi&ccedil;o(s).", "Alerta - Ayllos", "");
        return false;
    }

    if (flgErro) {
        showError("error", "Informe a qtd. de opera&ccedil;&otilde;es do(s) servi&ccedil;o(s) selecionado(s).", "Alerta - Ayllos", "");
        return false;
    } else {
        showConfirmacao("Confirma a inclus&atilde;o do Servi&ccedil;o Cooperativo?", "Confirma&ccedil;&atilde;o - Ayllos", "incluirPacote()", "", "sim.gif", "nao.gif");
    }
}

function habilitaCheck(codTarifa) {
    if ($("#chkCdtarifa" + codTarifa).is(':checked')) {
        $("#txtCdtarifa" + codTarifa).prop("disabled", false);
        $("#txtCdtarifa" + codTarifa).val("");
        $("#txtCdtarifa" + codTarifa).focus();
    } else {
        $("#txtCdtarifa" + codTarifa).val("");
        $("#txtCdtarifa" + codTarifa).prop("disabled", true);
    }
    
}
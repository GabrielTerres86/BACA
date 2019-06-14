/*!
 * FONTE        : rating.js                                   Última alteração: 
 * CRIAÇÃO      : Jonathan - RKAM
 * DATA CRIAÇÃO : 14/01/2016
 * OBJETIVO     : Biblioteca de funções da tela RATING
 * --------------
 * ALTERAÇÕES   : 
 * -----------------------------------------------------------------------
 */

var rating = new Object();

$(document).ready(function () {

    estadoInicial();
    return false;

});

// inicio
function estadoInicial() {

    //Inicializa o array
    rating = new Object();

    formataCabecalho();
    $('#divBotoesFiltro').css('display', 'none');
    $('#divBotoesRating').css('display', 'none');
    $('#frmRating').css('display', 'none');

    $('#frmFiltro').limpaFormulario();

    return false;

}

// formata
function formataCabecalho() {

    $('label[for="cddopcao"]', '#frmCab').css('width', '40px').addClass('rotulo');
    $('#cddopcao', '#frmCab').css('width', '570px');
    $('#divTela').css({ 'display': 'inline' }).fadeTo(0, 0.1);
    removeOpacidade('divTela');

    btnOK = $('#btnOK', '#frmCab');
    rCddopcao = $('label[for="cddopcao"]', '#frmCab');
    cCddopcao = $('#cddopcao', '#frmCab');

    rCddopcao.addClass('rotulo').css({ 'width': '50px' });
    cCddopcao.css({ 'width': '510px' });

    cCddopcao.habilitaCampo().focus().val('C');

    btnOK.unbind('click').bind('click', function () {

        if (cCddopcao.hasClass('campoTelaSemBorda')) {
            return false;
        }

        if (divError.css('display') == 'block') { return false; }

        cCddopcao.desabilitaCampo();

       formataFiltro();       

    });

    cCddopcao.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER
        if (e.keyCode == 13) {

            btnOK.click();
            return false;
        }

    });

    $('#frmFiltro').css('display', 'none');

    highlightObjFocus($('#frmCab'));
    highlightObjFocus($('#frmFiltro'));

    layoutPadrao();

    cCddopcao.focus();

    return false;
}

// Formatacao da Tela
function formataFiltro() {

    //Limpa formulario
    $('input[type="text"]', '#frmFiltro').limpaFormulario().removeClass('campoErro');

    // rotulo
    $('label[for="nrdconta"]', "#frmFiltro").addClass("rotulo").css({ "width": "120px" });

    // campo
    $("#nrdconta", "#frmFiltro").css({ 'width': '100px', 'text-align': 'right' }).addClass('conta').attr('maxlength', '10').habilitaCampo();

    $('#frmFiltro').css('display', 'block');
    $('#divBotoesFiltro').css('display', 'block');
    highlightObjFocus($('#frmFiltro'));

    // Evento para o campo nrdconta
    $("#nrdconta", "#frmFiltro").unbind('keypress').bind('keypress', function (e) {

        $(this).removeClass('campoErro');

        if (e.keyCode == 9 || e.keyCode == 13) {

            btProsseguir.click();
            return false;
        }
    });


    layoutPadrao();

    $("#nrdconta", "#frmFiltro").focus();

    return false;

}

function controlaPesquisa(valor) {

    switch (valor) {

        case 1:
            controlaPesquisaAssociado();

        break;        

    }

}

function controlaPesquisaAssociado() {

    // Se esta desabilitado o campo 
    if ($("#nrdconta", "#frmFiltro").prop("disabled") == true) {
        return;
    }

    mostraPesquisaAssociado('nrdconta', 'frmFiltro');

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

        break;

    }

}

function btnProsseguir() {

    cddopcao = $('#cddopcao','#frmCab').val();
    
    switch (cddopcao) {

        case 'C':

            showConfirmacao('Deseja prosseguir com a opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'buscaRatings(1,30);', '$("#nrdconta","#frmFiltro").focus();', 'sim.gif', 'nao.gif');

        break;

        case 'R':

            showConfirmacao('Deseja prosseguir com a opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'geraRelatorio();', '$("#nrdconta","#frmFiltro").focus();', 'sim.gif', 'nao.gif');

        break;

        case 'A':

            showConfirmacao('Deseja prosseguir com a opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'buscaRatings(1,30);', '$("#nrdconta","#frmFiltro").focus();', 'sim.gif', 'nao.gif');

        break;

    }

    return false;

}


function buscaRatings(nriniseq,nrregist) {

    //Desabilita todos os campos do form
    $('input,select', '#frmFiltro').desabilitaCampo();

    var nrdconta = normalizaNumero($('#nrdconta', '#frmFiltro').val());
    var cddopcao = $('#cddopcao', '#frmCab').val();

    $('input,select', '#frmFiltro').removeClass('campoErro');

    showMsgAguardo("Aguarde, buscando ratings...");

    //Requisição para processar a opção que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/rating/busca_ratings.php",
        data: {
            nrdconta: nrdconta,
            cddopcao: cddopcao,
            nriniseq: nriniseq,
            nrregist: nrregist,
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

function geraRelatorio() {
    
    //Desabilita todos os campos do form
    $('input,select', '#frmFiltro').desabilitaCampo();

    var nrdconta = normalizaNumero($('#nrdconta', '#frmFiltro').val());
    var cddopcao = $('#cddopcao', '#frmCab').val();

    $('input,select', '#frmFiltro').removeClass('campoErro');

    //Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, solicitando relatório...');

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/rating/gera_relatorio.php',
        data: {
            nrdconta: nrdconta,
            cddopcao: cddopcao,
            redirect: 'html_ajax' // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#nrdconta','#frmFiltro').focus();");
        },
        success: function (response) {
            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground();$("#nrdconta","#frmFiltro").focus();');
            }

        }
    });

    return false;
}


function gravaRatings() {    

    var nrdconta = normalizaNumero($('#nrdconta', '#frmFiltro').val());
    var cddopcao = $('#cddopcao', '#frmCab').val();

    $('input,select', '#frmFiltro').removeClass('campoErro');

    showMsgAguardo("Aguarde, gravando informações ...");

    //Requisição para processar a opção que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/rating/grava_ratings.php",
        data: {
            nrdconta: nrdconta,
            cddopcao: cddopcao,            
            rating  : rating,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "$('#btVoltar','#divBotoesRating').focus();");
        },
        success: function (response) {
            
            hideMsgAguardo();
            try {
                if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                    try {                        
                        eval(response);

                    } catch (error) {
                        showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', "$('#btVoltar','#divBotoesRating').focus()");
                    }
                } else {
                    try {                        
                        eval(response);
                    } catch (error) {
                        hideMsgAguardo();
                        showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', "$('#btVoltar','#divBotoesRating').focus()");
                    }
                }
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#btVoltar','#divBotoesRating').focus()");
            }

        }

    });

    return false;

}

function formataTabelaRatings() {
       
    var divRegistro = $('div.divRegistros');
    var tabela = $('table', divRegistro);    

    divRegistro.css({ 'height': '250px', 'border-bottom': '1px dotted #777', 'padding-bottom': '2px' });
   
    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '70px';
    arrayLargura[1] = '370px';
    arrayLargura[2] = '50px';    

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'center';
  
    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);

    
    $('table > tbody > tr', divRegistro).each(function (i) {

        var elemento = $(this);       

        $('#flgativo', $(this)).unbind('click').bind('click', function(){
                    
            ativaRating($(elemento));

        });

        if ($(this).hasClass('corSelecao')) {

            selecionaRating($(this));

        }

    });

    //seleciona o lancamento que é clicado
    $('table > tbody > tr', divRegistro).click(function () {

        selecionaRating($(this));
    }); 

    return false;
}


function formataFormularioRating() {
    
    // rotulo
    $('label[for="vlrdnota"]', "#divDados").addClass("rotulo").css({ "width": "80px" });
    $('label[for="nivrisco"]', "#divDados").addClass("rotulo").css({ "width": "80px" });
    $('label[for="datatual"]', "#divDados").addClass("rotulo-linha").css({ "width": "65px" });
    $('label[for="nrtopico"]', "#divRatings").addClass("rotulo").css({ "width": "80px" });
    $('label[for="nritetop"]', "#divRatings").addClass("rotulo").css({ "width": "80px" }); 

    // campo
    $("#vlrdnota", "#divDados").css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo();
    $('#nivrisco', '#divDados').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo();
    $('#datatual', '#divDados').css("width", "120px").desabilitaCampo();
    $("#nrtopico", "#divRatings").css({ 'width': '80px', 'text-align': 'left' }).desabilitaCampo();
    $('#nritetop', '#divRatings').css({ 'width': '80px', 'text-align': 'left' }).desabilitaCampo();
    $('#dstopico', '#divRatings').css({ 'width': '400px', 'text-align': 'left' }).desabilitaCampo();
    $('#dsseqite', '#divRatings').css({ 'width': '400px', 'text-align': 'left' }).desabilitaCampo();

    layoutPadrao();

    return false;

} 

function selecionaRating(tr) {
   
    if (!$(tr).hasClass('pulaLinha')) {

        $('#nrtopico', '#divRatings').val($('#topico', tr).val());
        $('#nritetop', '#divRatings').val($('#itetop', tr).val());
        $('#dstopico', '#divRatings').val($('#dsc_topico', tr).val());
        $('#dsseqite', '#divRatings').val($('#dsc_itetop', tr).val());

    }

    return false;

}


function ativaRating(tr) {    

    ($('#flgativo',tr).prop('checked')) ? rating[$(tr).attr('id')]["selecionado"] = 1 : rating[$(tr).attr('id')]["selecionado"] = 0;

    return false;

}


function atualizaSelecionado2() {

    var divRegistro = $('div.divRegistros');

    $('table > tbody > tr', divRegistro).each(function (i) {

        if (!$(this).hasClass('pulaLinha')) {

            ($('#flgativo', $(this)).prop('checked')) ? rating[$($(this)).attr('id')]["selecionado"] = 1 : rating[$($(this)).attr('id')]["selecionado"] = 0;

        }

    });

    return false;

}


function controlaConcluir(){

    var divRegistro = $('div.divRegistros');

    $('table > tbody > tr', divRegistro).each(function (i) {

        if (!$(this).hasClass('pulaLinha')) {

            ($('#flgativo', $(this)).prop('checked')) ? rating[$($(this)).attr('id')]["selecionado"] = 1 : rating[$($(this)).attr('id')]["selecionado"] = 0;

        }

    });

    gravaRatings();

    return false;

}

function Gera_Impressao(nmarqpdf, callback) {

    hideMsgAguardo();

    var action = UrlSite + 'telas/rating/imprimir_pdf.php';

    $('#nmarqpdf', '#frmFiltro').remove();
    $('#sidlogin', '#frmFiltro').remove();

    $('#frmFiltro').append('<input type="hidden" id="nmarqpdf" name="nmarqpdf" value="' + nmarqpdf + '" />');
    $('#frmFiltro').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin', '#frmMenu').val() + '" />');

    carregaImpressaoAyllos("frmFiltro", action, callback);

}
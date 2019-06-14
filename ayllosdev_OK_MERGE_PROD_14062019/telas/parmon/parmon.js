/*!
 * FONTE        : parmon.js
 * CRIAÇÃO      : Jorge I. Hamaguchi
 * DATA CRIAÇÃO : 24/07/2013
 * OBJETIVO     : Biblioteca de funções da tela PARMON
 * --------------
 * ALTERAÇÕES   : 20/10/2014 - Novos campos. Chamado 198702 (Jonata-RKAM).
 *
 *                06/04/2016 - Adicionado campos de TED. (Jaison/Marcos - SUPERO)
 *
 *                24/05/2016 - Inclusão do novo parâmetro (flmntage) de monitoração de agendamento (Carlos)
 *
 *				  31/10/2017 - Ajuste tela prevencao a lavagem de dinheiro - Melhoria 458 (junior Mouts)
 *
 *                16/05/2017 - Ajustes prj420 - Resolucao - Heitor (Mouts)
 * -----------------------------------------------------------------------
 */

//Formulários e Tabela
var frmCab = 'frmCab';
var frmparmon = 'frmparmon';

//Labels/Campos do cabeçalho
var rCddopcao, fprCddopcao, rVlinimon, rVllmonip, rDsidpara, rSpanInfo, rTodos, rRadios, rLabelsPLD;
var cCddopcao, fpcCddopcao, cVlinimon, cVllmonip, cDsidpara, cTodos, cEmail;

// array de cooperativas
var lstCooperativas = new Array();

// array de estados
var arrUF = ["AC", "AL", "AM", "AP", "BA", "CE", "DF", "ES", "GO", "MA", "MG", "MS", "MT", "PA", "PB", "PE", "PI", "PR", "RJ", "RN", "RO", "RR", "RS", "SC", "SE", "SP", "TO"];


$(document).ready(function () {
    estadoInicial();
});

// seletores
function estadoInicial() {
    //necessario para que a funcao includes funcione no IE
    if (!String.prototype.includes) {
        String.prototype.includes = function () {
            'use strict';
            return String.prototype.indexOf.apply(this, arguments) !== -1;
        };
    }

    $('#divTela').fadeTo(0, 0.1);

    fechaRotina($('#divRotina'));
    hideMsgAguardo();
    formataCabecalho();
    formataFrmparmon();
    controlaNavegacao();

    var cddopcao = $("#cddopcaoFP", "#" + frmCab).val();

    trocaBotao();

    cTodosCabecalho.limpaFormulario().removeClass('campoErro');

    highlightObjFocus($('#' + frmCab));
    highlightObjFocus($('#' + frmparmon));

    $('#' + frmCab).css({ 'display': 'block' });
    $('#' + frmparmon).css({ 'display': 'none' });
    $('#divFraude').css({ 'display': 'none' });
    $('#divPLD').css({ 'display': 'none' });
    $('#divBotoes').css({ 'display': 'none' });
    $('#hrlimiteprovisao', '#' + frmparmon).val("");

    $('#cdlinhaopcao', '#' + frmCab).css({ 'display': 'none' });

    cCddopcao.habilitaCampo();
    cTodos.habilitaCampo();
    fpcCddopcao.habilitaCampo();

    removeOpacidade('divTela');

    $("#cddopcao", "#" + frmCab).val("C").focus();
    $("#cddopcaoFP", "#" + frmCab).val("F").focus();

    return false;

}


function formataCabecalho() {

    // Cabecalho
    rCddopcao = $('label[for="cddopcao"]', '#' + frmCab);
    rCddopcao.addClass('rotulo').css({ 'width': '60px' });
    cCddopcao = $('#cddopcao', '#' + frmCab);
    cTodosCabecalho = $('input[type="text"],select', '#' + frmCab);
    cCddopcao.addClass('campo').css({ 'width': '450px' });

    fprCddopcao = $('label[for="cddopcaoFP"]', '#' + frmCab);
    fprCddopcao.addClass('rotulo').css({ 'width': '60px' });
    fpcCddopcao = $('#cddopcaoFP', '#' + frmCab);
    fpcCddopcao.addClass('campo').css({ 'width': '450px' });

    layoutPadrao();
    return false;
}

function formataFrmparmon() {

    // Cabecalho
    rVlinimon = $('label[for="vlinimon"]', '#' + frmparmon);
    rVllmonip = $('label[for="vllmonip"]', '#' + frmparmon);
    rDsidpara = $('label[for="dsidpara"]', '#' + frmparmon);
    rSpanInfo = $('#spanInfo', '#' + frmparmon);
    rTodos = $('label', '#' + frmparmon);
    rRadios = $('#insaqlim_sim,#insaqlim_nao,#inaleblq_sim,#inaleblq_nao,#flmstted_sim,#flmstted_nao,#flnvfted_sim,#flnvfted_nao,#flmobted_sim,#flmobted_nao,#flmntage_sim,#flmntage_nao', '#' + frmparmon);
    rLabelsPLD = $('.lbPrincipal', '#' + frmparmon);

    rTodos.addClass('rotulo').css({ 'width': '50%' });
    rRadios.removeClass('rotulo').css({ 'width': '20px' });
    rSpanInfo.css({ 'margin-left': '120px', 'font-style': 'italic', 'font-size': '10px', 'display': 'inline', 'float': 'left', 'top': '-20px' });
    rDsidpara.css({ 'text-align': 'right', 'width': '50%' });
    rLabelsPLD.removeClass('rotulo').css({ 'width': '75%', 'text-align': 'left', 'margin-left': '5%' });
    $('.lbAjuste', '#' + frmparmon).removeClass('rotulo').css({ 'width': '60%', 'margin-left': '-53px' });

    cVlinimon = $('#vlinimon', '#' + frmparmon);
    cVllmonip = $('#vllmonip', '#' + frmparmon);
    cDsidpara = $('#dsidpara', '#' + frmparmon);
    cTodos = $(':text', '#' + frmparmon);
    cCheck = $(':checkbox', '#' + frmparmon);

    cTodos.addClass('campo').css({ 'width': '150px', 'text-align': 'right' }).setMask('DECIMAL', 'zzz.zzz.zzz.zz9,99', '.,', '');
    cDsidpara.css({ 'margin-left': '120px', 'width': '310px', 'height': '140px', 'border': '1px solid #777777', 'font-size': '11px', 'padding': '2px 4px 1px', 'display': 'block' });
    $('.txtPLDInt', '#' + frmparmon).removeClass('campo').css({ 'width': '150px', 'text-align': 'right' }).setMask('INTEGER', 'zzz.zzz.zzz.zzz');
    $('.txtEmail', '#' + frmparmon).removeClass('campo').css({ 'width': '150px', 'text-align': 'right' });
    if (detectIE()) {
        $('#hrlimiteprovisao', '#' + frmparmon).addClass('inteiro').setMask('STRING', '99:99', ':', '');
        $('#hrlimiteprovisao', '#frmparmon').addClass('campo').css({ 'width': '50px', 'text-align': 'right' });
    }

    $('#qtdiasprovisao', '#frmparmon').addClass('campo').css({ 'width': '50px', 'text-align': 'right' });
    $('#qtdiasprovisaocancelamento', '#frmparmon').addClass('campo').css({ 'width': '50px', 'text-align': 'right' });
    $('#dsdemailseg', '#frmparmon').addClass('campo').css({ 'width': '260px', 'text-align': 'left' });
    $('#dsdeemail', '#frmparmon').addClass('campo').css({ 'width': '260px', 'text-align': 'left' });

    cCheck.removeClass('campo');
    layoutPadrao();
    formatTabEnter();

    return false;
}

function detectIE() {
    var ua = window.navigator.userAgent;

    var msie = ua.indexOf('MSIE ');
    if (msie > 0) {
        // IE 10 or older => return version number
        return parseInt(ua.substring(msie + 5, ua.indexOf('.', msie)), 10);
    }

    var trident = ua.indexOf('Trident/');
    if (trident > 0) {
        // IE 11 => return version number
        var rv = ua.indexOf('rv:');
        return parseInt(ua.substring(rv + 3, ua.indexOf('.', rv)), 10);
    }

    var edge = ua.indexOf('Edge/');
    if (edge > 0) {
        // Edge (IE 12+) => return version number
        return parseInt(ua.substring(edge + 5, ua.indexOf('.', edge)), 10);
    }

    // other browser
    return false;
}


// Formata
function controlaNavegacao() {
    cCddopcao.unbind('keypress').bind('keypress', function (e) {
        // Se é a tecla ENTER, 
        if (e.keyCode == 13) {
            liberaCampos();
            return false;
        }
    });

    fpcCddopcao.unbind('keypress').bind('keypress', function (e) {
        // Se ? a tecla ENTER, 
        if (e.keyCode == 13) {
            liberaCamposFraudePLD();
            return false;
        }
    });

    return false;

}

function liberaCamposFraudePLD() {
    var cddopcao = $("#cddopcaoFP", "#" + frmCab).val();

    //montar o select dinamico
    var option = document.createElement("option");
    var option2 = document.createElement("option");
    var select = document.getElementById("cddopcao");

    //limpar select
    var length = select.options.length;
    for (i = length - 1; i >= 0; i--) {
        select.options[i] = null;
    }

    //Fraude
    if (cddopcao == 'F') {
        option.innerHTML = "A - Alterar par&acirc;metros de monitoramento";
        option.value = "A";
        option2.innerHTML = "C - Consultar par&acirc;metros de monitoramento";
        option2.value = "C";
        select.appendChild(option);
        select.appendChild(option2);
    }

    option = document.createElement("option");
    option2 = document.createElement("option");

    //PLD
    if (cddopcao == 'P') {
        option.innerHTML = "A - Alterar par&acirc;metros de controle de lavangem de dinheiro";
        option.value = "AP";
        option2.innerHTML = "C - Consultar par&acirc;metros de controle de lavagem de dinheiro";
        option2.value = "CP";
        option2.selected = true;
        select.appendChild(option);
        select.appendChild(option2);
    }

    $('#cddopcaoFP', '#' + frmCab).desabilitaCampo();
    $('#cdlinhaopcao', '#' + frmCab).css({ 'display': 'block' });
    trocaBotao();
    $('#divBotoes').css({ 'display': 'block' });
    $("#cddopcao", "#" + frmCab).focus();
}

function liberaCampos() {

    var cddopcao = $("#cddopcao", "#" + frmCab).val();
    if ($('#cddopcao', '#' + frmCab).hasClass('campoTelaSemBorda')) { return false; };

    $('#cddopcao', '#' + frmCab).desabilitaCampo();
    $('#' + frmparmon).css({ 'display': 'block' });

    if (cddopcao == 'A' || cddopcao == 'C') {
        $('#divFraude').css({ 'display': 'block' });
    }

    if (cddopcao == 'AP' || cddopcao == 'CP') {
        $('#divPLD').css({ 'display': 'block' });
    }

    $('#divBotoes').css({ 'display': 'block' });

    $('input, select', '#' + frmparmon).limpaFormulario().removeClass('campoErro');

    if (cddopcao == 'F') {
        trocaBotao('Prosseguir');
    } else {
        trocaBotao('Concluir');
    }

    highlightObjFocus($('#' + frmparmon));

    manter_rotina();

    return false;

}


// Botoes
function btnVoltar() {
    estadoInicial();
    return false;
}

function btnContinuar() {
    var cddopcao = $("#cddopcao", "#" + frmCab).val();
    var vlinimon = parseFloat($.trim($("#vlinimon", "#" + frmparmon).val()).replace(/\./g, "").replace(",", "."));
    var vllmonip = parseFloat($.trim($("#vllmonip", "#" + frmparmon).val()).replace(/\./g, "").replace(",", "."));

    if (isNaN(vlinimon) && cddopcao != "AP") {
        showError("error", "Valor inválido!", "Alerta - Ayllos", "$('#vlinimon','#" + frmparmon + "').focus();");
        return false;
    } else if (isNaN(vllmonip) && cddopcao != "AP") {
        showError("error", "Valor inválido!", "Alerta - Ayllos", "$('#vllmonip','#" + frmparmon + "').focus();");
        return false;
    } else {
        //Remove a classe de Erro do form
        $('input,select', '#' + frmparmon).removeClass('campoErro');
        if (cddopcao == "A") {
            manter_rotina('A1');
            return false;
        }
        if (cddopcao == "AP") {
            manter_rotina('A2');
            return false;
        }
    }
}


function trocaBotao(botao) {

    $('#divBotoes', '#divTela').html('');
    $('#divBotoes', '#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;" >Voltar</a>&nbsp;');

    if (typeof botao != 'undefined') {
        $('#divBotoes', '#divTela').append('<a href="#" class="botao" id="btSalvar" onclick="btnContinuar(); return false;" >' + botao + '</a>');
    }

    return false;
}

function manter_rotina(rotina) {

    var cddopcao = $('#cddopcao', '#' + frmCab).val();
    var vlinimon = $('#vlinimon', '#' + frmparmon).val();
    var vllmonip = $('#vllmonip', '#' + frmparmon).val();
    var vlinisaq = $('#vlinisaq', '#' + frmparmon).val();
    var vlinitrf = $('#vlinitrf', '#' + frmparmon).val();
    var vlsaqind = $('#vlsaqind', '#' + frmparmon).val();
    var vlmnlmtd = $('#vlmnlmtd', '#' + frmparmon).val();
    var vlinited = $('#vlinited', '#' + frmparmon).val();
    var dsestted = $('#dsestted', '#' + frmparmon).val();
    var insaqlim = $('#insaqlim_1', '#' + frmparmon).is(":checked") ? 1 : 0;
    var inaleblq = $('#inaleblq_1', '#' + frmparmon).is(":checked") ? 1 : 0;
    var flmstted = $('#flmstted_1', '#' + frmparmon).is(":checked") ? 1 : 0;
    var flnvfted = $('#flnvfted_1', '#' + frmparmon).is(":checked") ? 1 : 0;
    var flmobted = $('#flmobted_1', '#' + frmparmon).is(":checked") ? 1 : 0;
    var flmntage = $('#flmntage_1', '#' + frmparmon).is(":checked") ? 1 : 0;
    var cdcoptel = '';


    //PLD
    var qtrendadiariopf = $('#qtrendadiariopf', '#' + frmparmon).val();
    var qtrendadiariopj = $('#qtrendadiariopj', '#' + frmparmon).val();
    var vlcreditodiariopf = $('#vlcreditodiariopf', '#' + frmparmon).val();
    var vlcreditodiariopj = $('#vlcreditodiariopj', '#' + frmparmon).val();
    var qtrendamensalpf = $('#qtrendamensalpf', '#' + frmparmon).val();
    var qtrendamensalpj = $('#qtrendamensalpj', '#' + frmparmon).val();
    var vlcreditomensalpf = $('#vlcreditomensalpf', '#' + frmparmon).val();
    var vlcreditomensalpj = $('#vlcreditomensalpj', '#' + frmparmon).val();
    var vllimitesaque = $('#vllimitesaque', '#' + frmparmon).val();
    var inrendazerada = $('#inrendazerada', '#' + frmparmon).is(":checked") ? 1 : 0;
    var vllimitedeposito = $('#vllimitedeposito', '#' + frmparmon).val();
    var vllimitepagamento = $('#vllimitepagamento', '#' + frmparmon).val();
    var vlprovisaoemail = $('#vlprovisaoemail', '#' + frmparmon).val();
    var vlprovisaosaque = $('#vlprovisaosaque', '#' + frmparmon).val();
    var vlmonpagto = $('#vlmonpagto', '#' + frmparmon).val();
    var qtdiasprovisao = $('#qtdiasprovisao', '#' + frmparmon).val();
    var hrlimiteprovisao = $('#hrlimiteprovisao', '#' + frmparmon).val();
    var qtdiasprovisaocancelamento = $('#qtdiasprovisaocancelamento', '#' + frmparmon).val();
    var inliberasaque = $('#inliberasaque', '#' + frmparmon).is(":checked") ? 1 : 0;
    var inliberaprovisaosaque = $('#inliberaprovisaosaque', '#' + frmparmon).is(":checked") ? 1 : 0;
    var inalteraprovisaopresencial = $('#inalteraprovisaopresencial', '#' + frmparmon).is(":checked") ? 1 : 0;
    var inverificasaldo = $('#inverificasaldo', '#' + frmparmon).is(":checked") ? 1 : 0;
    var dsdemailseg = $('#dsdemailseg', '#' + frmparmon).val();
    var dsdeemail = $('#dsdeemail', '#' + frmparmon).val();
	var vlalteracaoprovemail = $('#vlalteracaoprovemail', '#' + frmparmon).val();
	var vllimitepagtoespecie = $('#vllimitepagtoespecie', '#' + frmparmon).val();

    if (rotina != undefined) {
        cddopcao = rotina;
        if (cddopcao == 'C1' || cddopcao == 'A1' || cddopcao == 'C2' || cddopcao == 'A2') {
            if ($('#divCoptel', '#frmparmon').css('display') != 'none') {
                cdcoptel = $('#dsidpara', '#frmparmon').val();
            }
        }
    }

    //console.log(cddopcao);
    if (cddopcao == 'A2') {
        if (!hrlimiteprovisao) {
            showError("error", "Hora deve ser informada.", "Alerta - Ayllos", "$('#hrlimiteprovisao','#frmparmon').focus();");
            return false;
        } else {
            hrlimiteprovisao = hrlimiteprovisao.replace(':', '');
            if (hrlimiteprovisao.length != 4) {
                showError("error", "Horario inv&aacute;lido.", "Alerta - Ayllos", "$('#hrlimiteprovisao','#frmparmon').focus();");
                return false;
            } else {
                h = hrlimiteprovisao.substring(0, 2);
                m = hrlimiteprovisao.substring(2, 4);
                if (h < 0 || h > 23) {
                    showError("error", "Hora inv&aacute;lida.", "Alerta - Ayllos", "$('#hrlimiteprovisao','#frmparmon').focus();");
                    return false;
                }

                if (m < 0 || m > 59) {
                    showError("error", "Minuto inv&aacute;lido.", "Alerta - Ayllos", "$('#hrlimiteprovisao','#frmparmon').focus();");
                    return false;
                }
            }
        }
    }

    vlinimon = normalizaNumero(vlinimon);

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando ...");
    window.focus();

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/parmon/manter_rotina.php",
        data: {
            cddopcao: cddopcao,
            vlinimon: vlinimon,
            vllmonip: vllmonip,
            vlinisaq: vlinisaq,
            vlinitrf: vlinitrf,
            vlsaqind: vlsaqind,
            insaqlim: insaqlim,
            inaleblq: inaleblq,
            vlmnlmtd: vlmnlmtd,
            vlinited: vlinited,
            flmstted: flmstted,
            flnvfted: flnvfted,
            flmobted: flmobted,
            dsestted: dsestted,
            cdcoptel: cdcoptel,
            flmntage: flmntage,

            qtrendadiariopf: qtrendadiariopf,
            qtrendadiariopj: qtrendadiariopj,
            vlcreditodiariopf: vlcreditodiariopf,
            vlcreditodiariopj: vlcreditodiariopj,
            qtrendamensalpf: qtrendamensalpf,
            qtrendamensalpj: qtrendamensalpj,
            vlcreditomensalpf: vlcreditomensalpf,
            vlcreditomensalpj: vlcreditomensalpj,
            vllimitesaque: vllimitesaque,
            inrendazerada: inrendazerada,
            vllimitedeposito: vllimitedeposito,
            vllimitepagamento: vllimitepagamento,
            vlprovisaoemail: vlprovisaoemail,
            vlprovisaosaque: vlprovisaosaque,
            vlmonpagto: vlmonpagto,
            qtdiasprovisao: qtdiasprovisao,
            hrlimiteprovisao: hrlimiteprovisao,
            qtdiasprovisaocancelamento: qtdiasprovisaocancelamento,
            inliberasaque: inliberasaque,
            inliberaprovisaosaque: inliberaprovisaosaque,
            inalteraprovisaopresencial: inalteraprovisaopresencial,
            inverificasaldo: inverificasaldo,
            dsdemailseg: dsdemailseg,
            dsdeemail: dsdeemail,
			vlalteracaoprovemail: vlalteracaoprovemail,
			vllimitepagtoespecie: vllimitepagtoespecie,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                hideMsgAguardo();
                if (!response.includes('show') && ($("#cddopcao", "#" + frmCab).val() == 'AP' || $("#cddopcao", "#" + frmCab).val() == 'CP')) {
                    setTimeout(function () { document.getElementById('qtrendadiariopf').focus(); }, 10);
                }
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

function ver_rotina() {
    var cddopcao = $("#cddopcao", "#frmCab").val();
    if (cddopcao == "C") {
        manter_rotina("C1");
    }

    if (cddopcao == "CP") {
        manter_rotina("C2");
    }
    return false;
}

//funcao para carregar cooperativas em combobox
function carregaCooperativas(qtdCooperativas) {
    for (var i = 0; i < qtdCooperativas; i++) {
        $('option', '#dsidpara').remove();

    }
    for (var i = 0; i < qtdCooperativas; i++) {
        if (i == 0 && ($('#cddopcao', '#frmCab').val() == "A" || $('#cddopcao', '#frmCab').val() == "AP")) {
            cDsidpara.append("<option id='coop0' value='0'>Todas Cooperativas</option>");
        }
        cDsidpara.append("<option id='coop" + lstCooperativas[i].cdcooper + "' value='" + lstCooperativas[i].cdcooper + "'>" + lstCooperativas[i].nmrescop + "</option>");
    }

    hideMsgAguardo();
}

function carregaEstados() {
    var cddopcao = $("#cddopcao", "#frmCab").val();
    var dsestted = $('#dsestted', '#frmparmon').val();
    var linDsestted = '';
    var index;

    // Oculta linha com opcoes de adicao
    $('#linAddUF').hide();

    if (cddopcao == 'A') {
        var opcao = '';
        for (index = 0; index < arrUF.length; index++) {
            if (dsestted.indexOf(arrUF[index]) == -1) {
                opcao += '<option value="' + arrUF[index] + '">' + arrUF[index] + '</option>';
            }
        }
        // Monta o list menu
        $('#nmuf').empty().append(opcao);
        // Exibe linha com opcoes de adicao
        $('#linAddUF').show();
    }

    if (dsestted == '') {
        linDsestted += '<tr>';
        linDsestted += '    <td>Todas</td>';
        linDsestted += '    <td>&nbsp;</td>';
        linDsestted += '</tr>';
    } else {
        var dsDispImage = (cddopcao == 'A' ? 'block' : 'none');
        var arrDsestted = dsestted.split(';');
        arrDsestted.sort(); // Ordena
        for (index = 0; index < arrDsestted.length; index++) {
            linDsestted += '<tr>';
            linDsestted += '    <td>' + arrDsestted[index] + '</td>';
            linDsestted += '    <td><img onclick="confirmaExclusao(\'' + arrDsestted[index] + '\');" style="display:' + dsDispImage + ';cursor:hand;" src="../../imagens/geral/panel-error_16x16.gif" width="13" height="13" /></td>';
            linDsestted += '</tr>';
        }
    }
    // Monta as linhas da tabela
    $('#listUF').empty().append(linDsestted);
}

function confirmaExclusao(nmuf) {
    showConfirmacao("Deseja excluir '" + nmuf + "' da lista?", 'Confirma&ccedil;&atilde;o - Ayllos', "removerEstado('" + nmuf + "')", '', 'sim.gif', 'nao.gif');
}

function removerEstado(nmuf) {
    var dsestted = $('#dsestted', '#frmparmon').val();
    var arrDsestted = dsestted.split(';');
    var opcao = '';
    var index;

    for (index = 0; index < arrDsestted.length; index++) {
        if (nmuf.indexOf(arrDsestted[index]) == -1) {
            opcao += (opcao == '' ? '' : ';') + arrDsestted[index];
        }
    }

    // Seta as opcoes sem o estado excluido
    $('#dsestted', '#frmparmon').val(opcao);

    // Monta os estados
    carregaEstados();
}

function incluirEstado() {
    var nmuf = $('#nmuf', '#frmparmon').val();
    var dsestted = $('#dsestted', '#frmparmon').val();
    dsestted += (dsestted == '' ? '' : ';') + nmuf;

    if (nmuf != null) {
        // Seta as opcoes com o estado incluido
        $('#dsestted', '#frmparmon').val(dsestted);
        // Monta os estados
        carregaEstados();
    }
}

function formatTabEnter() {
    // Se ? a tecla ENTER
    $('#qtrendadiariopf', '#' + frmparmon).unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#qtrendadiariopj', '#' + frmparmon).focus();
            return false;
        }
    });

    $('#qtrendadiariopj', '#' + frmparmon).unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#vlcreditodiariopf', '#' + frmparmon).focus();
            return false;
        }
    });

    $('#vlcreditodiariopf', '#' + frmparmon).unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#vlcreditodiariopj', '#' + frmparmon).focus();
            return false;
        }
    });

    $('#vlcreditodiariopj', '#' + frmparmon).unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#qtrendamensalpf', '#' + frmparmon).focus();
            return false;
        }
    });

    $('#qtrendamensalpf', '#' + frmparmon).unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#qtrendamensalpj', '#' + frmparmon).focus();
            return false;
        }
    });

    $('#qtrendamensalpj', '#' + frmparmon).unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#vlcreditomensalpf', '#' + frmparmon).focus();
            return false;
        }
    });

    $('#vlcreditomensalpf', '#' + frmparmon).unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#vlcreditomensalpj', '#' + frmparmon).focus();
            return false;
        }
    });

    $('#vlcreditomensalpj', '#' + frmparmon).unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#inrendazerada', '#' + frmparmon).focus();
            return false;
        }
    });


    $('#inrendazerada', '#' + frmparmon).unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#vllimitesaque', '#' + frmparmon).focus();
            return false;
        }
    });

    $('#vllimitesaque', '#' + frmparmon).unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#vllimitedeposito', '#' + frmparmon).focus();
            return false;
        }
    });

    $('#vllimitedeposito', '#' + frmparmon).unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#vllimitepagamento', '#' + frmparmon).focus();
            return false;
        }
    });

    $('#vllimitepagamento', '#' + frmparmon).unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#vlprovisaoemail', '#' + frmparmon).focus();
            return false;
        }
    });
    $('#vlprovisaoemail', '#' + frmparmon).unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#vlalteracaoprovemail', '#' + frmparmon).focus();
            return false;
        }
    });
	
	$('#vlalteracaoprovemail', '#' + frmparmon).unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#vlprovisaosaque', '#' + frmparmon).focus();
            return false;
        }
    });

    $('#vlprovisaosaque', '#' + frmparmon).unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#vlmonpagto', '#' + frmparmon).focus();
            return false;
        }
    });

    $('#vlmonpagto', '#' + frmparmon).unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#vllimitepagtoespecie', '#' + frmparmon).focus();
            return false;
        }
    });
	
	$('#vllimitepagtoespecie', '#' + frmparmon).unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#qtdiasprovisao', '#' + frmparmon).focus();
            return false;
        }
    });

    $('#qtdiasprovisao', '#' + frmparmon).unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#hrlimiteprovisao', '#' + frmparmon).focus();
            return false;
        }
    });

    $('#hrlimiteprovisao', '#' + frmparmon).unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#qtdiasprovisaocancelamento', '#' + frmparmon).focus();
            return false;
        }
    });

    $('#qtdiasprovisaocancelamento', '#' + frmparmon).unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#inliberasaque', '#' + frmparmon).focus();
            return false;
        }
    });

    $('#inliberasaque', '#' + frmparmon).unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#inliberaprovisaosaque', '#' + frmparmon).focus();
            return false;
        }
    });

    $('#inliberaprovisaosaque', '#' + frmparmon).unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#inalteraprovisaopresencial', '#' + frmparmon).focus();
            return false;
        }
    });

    $('#inalteraprovisaopresencial', '#' + frmparmon).unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#inverificasaldo', '#' + frmparmon).focus();
            return false;
        }
    });

    $('#inverificasaldo', '#' + frmparmon).unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#dsdemailseg', '#' + frmparmon).focus();
            return false;
        }
    });

    $('#dsdemailseg', '#' + frmparmon).unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#dsdeemail', '#' + frmparmon).focus();
            return false;
        }
    });

    $('#dsdeemail', '#' + frmparmon).unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            btnContinuar();
            return false;
        }
    });
}

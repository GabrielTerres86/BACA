/*!
 * FONTE        : prvsaq.js
 * CRIAÇÃO      : Antonio R. Junior (Mouts)
 * DATA CRIAÇÃO : 09/11/2017
 * OBJETIVO     : Biblioteca de funções da tela PRVSAQ
 * --------------
 * ALTERAÇÕES   : 
 * -----------------------------------------------------------------------
 */

//Formulários e Tabela
var frmCab = 'frmCab';
var frmmain = 'frmmain';

//Labels/Campos do cabeçalho
var rCddopcao, rCdcooper, rVlinimon, rVllmonip, rDsidpara, rSpanInfo, rTodos, rRadios;
var cCddopcao, cCdcooper, cVlinimon, cVllmonip, cDsidpara, cTodos;
var nvVoltar, selAtivo = 1;

// array de cooperativas
var lstCooperativas = new Array();

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
    formatafrmmain();
    formataInclusao();
    //formataConsulta();
    formataFiltroConsulta();
    controlaNavegacao();

    trocaBotao('Gravar');

    cTodosCabecalho.limpaFormulario().removeClass('campoErro');

    highlightObjFocus($('#' + frmCab));
    highlightObjFocus($('#' + frmmain));

    $('#' + frmCab).css({ 'display': 'block' });
    $('#' + frmmain).css({ 'display': 'none' });
    $('#frmInclusao').css({ 'display': 'none' });
    $('#divBotoes').css({ 'display': 'none' });
    $('#divFiltro').css({ 'display': 'none' });
    $('#hrSaqPagto', '#frmInclusao').val("");
    $("#divTabela").html("");

    cCddopcao.habilitaCampo();
    cTodos.habilitaCampo();
    removeOpacidade('divTela');

    $("#cddopcao", "#" + frmCab).val("I").focus();

    limpaSelects();
    liberaDadosCheque();
    liberaCampoQuais();
    checkOptionSelected($("#cddopcao", "#" + frmCab).val());
    return false;
}

function formataCabecalho() {
    // Cabecalho
    rCddopcao = $('label[for="cddopcao"]', '#' + frmCab);
    rCdcooper = $('label[for="cdcooper"]', '#' + frmCab);
    rCddopcao.addClass('rotulo').css({ 'width': '60px' });
    rCdcooper.addClass('rotulo').css({ 'width': '88px' });
    cCddopcao = $('#cddopcao', '#' + frmCab);
    cCdcooper = $('#cdcooper', '#' + frmCab);
    cTodosCabecalho = $('input[type="text"],select', '#' + frmCab);
    cCddopcao.addClass('campo').css({ 'width': '450px' });
    cCdcooper.addClass('campo').css({ 'width': '423px' });
    layoutPadrao();
    cCdcooper.hide();
    rCdcooper.hide();
    return false;
}

// Formata
function controlaNavegacao() {
    $('#cdcooper').unbind('keypress').bind('keypress', function (e) {
        // Se é a tecla ENTER, 
        if (e.keyCode == 13) {
            $('#btnOK').focus();
            return false;
        }
    });

    cCddopcao.unbind('keypress').bind('keypress', function (e) {
        // Se é a tecla ENTER, 
        if (e.keyCode == 13) {
            if ($('#glbcoope', '#frmCab').val() == 3 && ($("#cddopcao", "#" + frmCab).val() == 'C' || $("#cddopcao", "#" + frmCab).val() == 'A')) {
                $('#cdcooper').focus();
            } else {
                liberaCampos();
            }
            return false;
        }
    });
    return false;
}

function doubleClick(tr) {
    var cddopcao = $("#cddopcao", "#" + frmCab).val();

    if (cddopcao == 'C') {
        $('input,select').removeClass('campoErro');
        $('#tabConsulta', '#frmConsulta').css({ 'display': 'none' });

        $('#nrCpfSacPag', '#frmConsulta').val($('#hnrcpfsacpag', tr).val());
        $('#cdoperacad', '#frmConsulta').val($('#hcdoperacad', tr).val());
        $('#dthoracad', '#frmConsulta').val($('#hdthoracad', tr).val());
        $('#cdoperalt', '#frmConsulta').val($('#hcdoperalt', tr).val());
        $('#dthoraalt', '#frmConsulta').val($('#hdthoralt', tr).val());
        $('#cdopercanc', '#frmConsulta').val($('#hcdopercanc', tr).val());
        $('#dthoracanc', '#frmConsulta').val($('#hdthoracanc', tr).val());
        $('#txtFinPagto', '#frmConsulta').val($('#htxtfinpagto', tr).val());

        $('#divDadosExc', '#frmConsulta').css({ 'display': 'block' });
        nvVoltar = 'C'
        trocaBotao('');
    }

    if (cddopcao == 'A') {
        $('#tabConsulta', '#frmConsulta').css({ 'display': 'none' });

        $('#dtSaqPagtoAlt', '#frmConsulta').val($('#dhsaque', tr).val().substring(0, 10));
        $('#hrSaqPagtoAlt', '#frmConsulta').val($('#dhsaque', tr).val().substring(11, 16));
        $('#vlSaqPagtoAlt', '#frmConsulta').val($('#vlsaque', tr).val());
        $('#tpSituacaoAlt', '#frmConsulta').val($('#insit', tr).val());

        //guardar valores originais
        $('#cdcooperOri', '#frmConsulta').val($('#cdcooper', tr).val());
        $('#dhsaqueOri', '#frmConsulta').val($('#dhsaque', tr).val());
        $('#nrcpfcgcOri', '#frmConsulta').val($('#nrcpfcgc', tr).val());
        $('#nrdcontaOri', '#frmConsulta').val($('#nrdconta', tr).val());
        $('#vlsaqpagtoOri', '#frmConsulta').val($('#vlsaque', tr).val());
        $('#tpsituacaoOri', '#frmConsulta').val($('#insit', tr).val());

        $('#divDadosAlt', '#frmConsulta').css({ 'display': 'block' });
        nvVoltar = 'A'
        trocaBotao('Alterar');
        formatTabEnterAltera();
    }
}

function selecionaTabela(tr) {
    if (selAtivo) {
        $('input,select').removeClass('campoErro');

        cdcooper = $('#cdcooper', tr).val();
        dhsaque = $('#dhsaque', tr).val();
        nrcpfcgc = $('#nrcpfcgc', tr).val();
        nrdconta = $('#nrdconta', tr).val();
        $("#chExcluir", tr).attr("checked", !$(tr).find("input:checkbox:checked").length);
        selecionaCheck();
    }
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

function formataConsulta() {

    var divRegistro = $('#divRegistros', '#frmConsulta');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);
    var conteudo = $('#conteudo', linha).val();
    var cddopcao = $("#cddopcao", "#" + frmCab).val();

    selAtivo = 0;

    divRegistro.css({ 'height': '300px', 'padding-bottom': '1px' });
    $('#divRegistrosRodape', '#frmConsulta').formataRodapePesquisa();

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    if (cddopcao == 'E') {
        arrayLargura[0] = '5px';
        arrayLargura[1] = '78px';
        arrayLargura[2] = '88px';
        arrayLargura[3] = '70px';
        arrayLargura[4] = '100px';
        arrayLargura[5] = '70px';
        arrayLargura[6] = '70px';
        arrayLargura[7] = '70px';
        arrayLargura[8] = '79px';
    } else if (cddopcao == 'C') {
        arrayLargura[0] = '88px';
        arrayLargura[1] = '80px';
        arrayLargura[2] = '60px';
        arrayLargura[3] = '100px';
        arrayLargura[4] = '70px';
        arrayLargura[5] = '70px';
        arrayLargura[6] = '100px';
        arrayLargura[7] = '80px';

    } else if (cddopcao == 'A') {
        arrayLargura[0] = '88px';
        arrayLargura[1] = '19px';
        arrayLargura[2] = '62px';
        arrayLargura[3] = '70px';
        arrayLargura[4] = '105px';
        arrayLargura[5] = '238px';
        arrayLargura[6] = '80px';
        arrayLargura[7] = '70px';
    }

    var arrayAlinha = new Array();

    if (cddopcao == 'C') {
        arrayAlinha[0] = 'left';
        arrayAlinha[1] = 'right';
        arrayAlinha[2] = 'right';
        arrayAlinha[3] = 'right';
        arrayAlinha[4] = 'right';
        arrayAlinha[5] = 'right';
        arrayAlinha[6] = 'right';
        arrayAlinha[7] = 'left';
    }

    if (cddopcao == 'A') {
        arrayAlinha[0] = 'left';
        arrayAlinha[1] = 'right';
        arrayAlinha[2] = 'right';
        arrayAlinha[3] = 'right';
        arrayAlinha[4] = 'right';
        arrayAlinha[5] = 'left';
        arrayAlinha[6] = 'left';
        arrayAlinha[7] = 'right';
        arrayAlinha[8] = 'center';
    }

    if (cddopcao == 'E') {
        arrayAlinha[0] = 'center';
        arrayAlinha[1] = 'left';
        arrayAlinha[2] = 'right';
        arrayAlinha[3] = 'right';
        arrayAlinha[4] = 'right';
        arrayAlinha[5] = 'right';
        arrayAlinha[6] = 'right';
        arrayAlinha[7] = 'right';
        arrayAlinha[8] = 'left';
    }

    $('label', '#frmConsulta').addClass('rotulo').css({ 'width': '25%', 'margin-left': '5px' });
    $('#lbTxtFinPgtoCons', '#frmConsulta').css({ 'width': '28%', 'margin-left': '10px', 'text-align': 'left' });

    if (cddopcao == 'A') {
        $('#lbDtSaqPagtoAlt', '#frmConsulta').removeClass('rotulo').css({ 'width': '25%', 'margin-left': '5px' });
        $('#lbHrSaqPagtoAlt', '#frmConsulta').removeClass('rotulo').css({ 'width': '25%', 'margin-left': '5px' });
        $('#lbTpsituacaoAlt', '#frmConsulta').removeClass('rotulo').css({ 'width': '25%', 'margin-left': '5px' });
        if (detectIE()) {
            $('#hrSaqPagtoAlt', '#frmConsulta').addClass('inteiro').setMask('STRING', '99:99', ':', '');
            $('#hrSaqPagtoAlt', '#frmConsulta').addClass('campo').css({ 'width': '45px', 'text-align': 'right' });
        }

        $('#vlSaqPagtoAlt', '#frmConsulta').setMask('DECIMAL', 'zzz.zzz.zzz.zz9,99', '.,', '');
        $('#dtSaqPagtoAlt', '#frmConsulta').setMask("DATE", "", "", "");
    }

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');
    hideMsgAguardo();

    /* Atribuindo o foco para a linha da tabela, pois ao clicar no cabecalho nao retornava
	para linha da tabela, dessa maneira a tela apresentava erro na hora de alterar ou
	excluir o registro selecionado */

    $('table > thead > tr > th', divRegistro).unbind('click').bind('click', function () {
        $('table > tbody > tr > td', divRegistro).focus();
    });

    // seleciona o registro que é clicado
    /*$('table > tbody > tr', divRegistro).click( function() {
		selecionaTabela($(this));
	});*/

    var cddopcao = $("#cddopcao", "#" + frmCab).val();

    if (cddopcao == "C" || cddopcao == 'A') {
        // seleciona o registro que é clicado
        $('table > tbody > tr', divRegistro).dblclick(function () {
            doubleClick($(this));
            //btnAlterar($(this));
        });
    }

    // seleciona o registro que é focado
    $('table > tbody > tr', divRegistro).focus(function () {
        selecionaTabela($(this));
    });

    $('table > tbody > tr:eq(0)', divRegistro).click();

    //layoutPadrao();
    //highlightObjFocus( $('#frmConsulta') );	
    selAtivo = 1;
    return false;
}

function formataFiltroConsulta() {
    var cddopcao = $("#cddopcao", "#" + frmCab).val();
    // Cabecalho	
    $('label', '#frmFiltro').addClass('rotulo').css({ 'width': '10%', 'margin-left': '5px' });

    var hoje = new Date();
    var dia = ((hoje.getDate() < 10) ? ('0' + hoje.getDate()) : hoje.getDate());
    var mes = ((hoje.getMonth() + 1) < 10) ? ('0' + (hoje.getMonth() + 1)) : (hoje.getMonth() + 1);
    var ano = hoje.getFullYear();

    if (cddopcao == 'C') {
        $('#lbDtPeriodoIni', '#frmFiltro').removeClass('rotulo').css({ 'width': '10%', 'margin-left': '0px' });
        $('#lbDtPeriodoFim', '#frmFiltro').removeClass('rotulo').css({ 'width': '2%', 'margin-left': '3px' });
        $('#lbTpOperacao', '#frmFiltro').removeClass('rotulo').css({ 'width': '19%', 'margin-left': '0px' });
        $('#lbNrPA', '#frmFiltro').removeClass('rotulo').css({ 'width': '14%', 'margin-left': '0px' });
        $('#nrPA', '#frmFiltro').addClass('campo').css({ 'width': '30px' });
        $('#lbTpsituacao', '#frmFiltro').removeClass('rotulo').css({ 'width': '10%', 'margin-left': '0px' });
        $('#lbTpOrigem', '#frmFiltro').removeClass('rotulo').css({ 'width': '10%', 'margin-left': '0px' });
        $('#dtPeriodoIni', '#frmFiltro').val(dia + '/' + mes + '/' + ano);
        $('#dtPeriodoFim', '#frmFiltro').val(dia + '/' + mes + '/' + ano);
    } else if (cddopcao == 'E') {
        $('#lbDtDataExc', '#frmFiltro').removeClass('rotulo').css({ 'width': '6%', 'margin-left': '0px' });
        $('#lbNrPAExc', '#frmFiltro').removeClass('rotulo').css({ 'width': '14%', 'margin-left': '0px' });
        $('#nrPAExc', '#frmFiltro').addClass('campo').css({ 'width': '30px' });
        $('#lbNrCpfCnpjExc', '#frmFiltro').removeClass('rotulo').css({ 'width': '10%', 'margin-left': '2px' });
        $('#dtDataExc', '#frmFiltro').val(dia + '/' + mes + '/' + ano);
        formatTabEnterExclusao();
    } else {
        $('#lbDsProtocolo', '#frmFiltro').removeClass('rotulo').css({ 'width': '11%', 'margin-left': '0px' });
        $('#lbDtDataAlt', '#frmFiltro').removeClass('rotulo').css({ 'width': '6%', 'margin-left': '0px' });
        $('#lbNrPAAlt', '#frmFiltro').removeClass('rotulo').css({ 'width': '14%', 'margin-left': '0px' });
        $('#nrPAAlt', '#frmFiltro').addClass('campo').css({ 'width': '30px' });
        $('#dtDataAlt', '#frmFiltro').val(dia + '/' + mes + '/' + ano);
    }

    $('#spanInfo', '#frmFiltro').css({ 'margin-left': '120px', 'font-style': 'italic', 'font-size': '10px', 'display': 'inline', 'float': 'left', 'top': '-20px' });
    $('label[for="dsidpara"]', '#frmFiltro').css({ 'text-align': 'right', 'width': '50%' });
    $('.data', '#frmFiltro').css({ 'width': '80px' });

    $('#dsidpara', '#frmFiltro').css({ 'margin-left': '120px', 'width': '310px', 'height': '140px', 'border': '1px solid #777777', 'font-size': '11px', 'padding': '2px 4px 1px', 'display': 'block' });

    layoutPadrao();
    formatTabEnterConsulta();
}
// Formatacao da Tela
function formataInclusao() {
    if (detectIE()) {
        $('#hrSaqPagto', '#frmInclusao').addClass('inteiro').setMask('STRING', '99:99', ':', '');
        $('#hrSaqPagto', '#frmInclusao').addClass('campo').css({ 'width': '45px', 'text-align': 'right' });
    } else {
        $('#hrSaqPagto', '#frmInclusao').addClass('campo').css({ 'width': '70px', 'text-align': 'right' });
    }

    $('label', '#frmInclusao').addClass('labls').css({ 'width': '25%', 'margin-left': '0px' });

    $('#lbNrContTit', '#frmInclusao').removeClass('labls').css({ 'width': '25%', 'margin-left': '0px' });
    $('#lbNrTit', '#frmInclusao').removeClass('labls').css({ 'width': '7%', 'margin-left': '0px' });
    $('#lbNrCpfCnpj', '#frmInclusao').removeClass('labls').css({ 'width': '10%', 'margin-left': '0px' });

    $('#lbNrPA', '#frmInclusao').removeClass('labls').css({ 'width': '178px', 'margin-left': '10px', 'text-align': 'left' });
    $('#lbNrAgencia', '#frmInclusao').removeClass('labls').css({ 'width': '250px', 'margin-left': '0px' });
    $('#lbNrCheque', '#frmInclusao').removeClass('labls').css({ 'width': '143px', 'margin-left': '0px' });
    $('#lbTxtFinPagto', '#frmInclusao').removeClass('labls').css({ 'width': '28%', 'margin-left': '10px', 'text-align': 'left' });
    $('#lbTxtObs', '#frmInclusao').removeClass('labls').css({ 'width': '28%', 'margin-left': '10px', 'text-align': 'left' });
    $('#lbSelQuais', '#frmInclusao').removeClass('labls').css({ 'width': '237px', 'margin-left': '10px', 'text-align': 'left' });
    $('#lbTxtQuais', '#frmInclusao').removeClass('labls').css({ 'width': '36%', 'margin-left': '10px', 'text-align': 'left' });

    $('#nmSolic,#nmSacPag', '#frmInclusao').addClass('campo').css({ 'width': '350px' });
    $('#nrTit', '#frmInclusao').addClass('campo').css({ 'width': '50px' });
    $('#dtSaqPagto', '#frmInclusao').addClass('campo').css({ 'width': '80px' });


    $('#vlSaqPagto', '#frmInclusao').setMask('DECIMAL', 'zzz.zzz.zzz.zz9,99', '.,', '');

    /*$('#nrContTit','#frmInclusao').unbind('focusout').bind('focusout',function() {
		//verifica conta
		console.log(1);		
		manter_rotina('CT',1);		
	});*/

    $('#nrTit', '#frmInclusao').unbind('focusout').bind('focusout', function () {
        //verifica conta
        $nrTit = trim($('#nrTit', '#frmInclusao').val());
        if ($nrTit) {
            manter_rotina('CT', 2);
        }
    });

    $('#nrCpfSacPag', '#frmInclusao').unbind('focusout').bind('focusout', function () {
        //verifica cpf sacado		
        manter_rotina('CS');
    });

    layoutPadrao();
    highlightObjFocus($('#frmInclusao'));
    formatTabEnterInclusao();
    return false;
}

function formatafrmmain() {

    // Cabecalho
    rDsidpara = $('label[for="dsidpara"]', '#' + frmmain);
    rSpanInfo = $('#spanInfo', '#' + frmmain);
    rTodos = $('label', '#' + frmmain);

    rTodos.addClass('rotulo').css({ 'width': '50%', 'margin-left': '10px' });
    rSpanInfo.css({ 'margin-left': '120px', 'font-style': 'italic', 'font-size': '10px', 'display': 'inline', 'float': 'left', 'top': '-20px' });
    rDsidpara.css({ 'text-align': 'right', 'width': '50%' });

    cDsidpara = $('#dsidpara', '#' + frmmain);
    cTodos = $(':text', '#' + frmmain);

    cTodos.addClass('campo').css({ 'width': '150px', 'text-align': 'right' }).setMask('DECIMAL', 'zzz.zzz.zzz.zz9,99', '.,', '');
    cDsidpara.css({ 'margin-left': '120px', 'width': '310px', 'height': '140px', 'border': '1px solid #777777', 'font-size': '11px', 'padding': '2px 4px 1px', 'display': 'block' });

    layoutPadrao();

    return false;
}

function liberaCampos() {
    if ($('#cddopcao', '#' + frmCab).hasClass('campoTelaSemBorda')) { return false; };

    var cddopcao = $("#cddopcao", "#" + frmCab).val();

    $('#cddopcao', '#' + frmCab).desabilitaCampo();
    //$('#cdcooper','#'+frmCab).desabilitaCampo();
    $('#' + frmmain).css({ 'display': 'block' });
    $('#divBotoes').css({ 'display': 'block' });
    $('input, select', '#' + frmmain).limpaFormulario().removeClass('campoErro');

    highlightObjFocus($('#' + frmmain));
    formatafrmmain();

    //INSERIR	
    if (cddopcao == 'I') {
        $('input,select,textarea,time', '#frmInclusao').limpaFormulario().removeClass('campoErro');
        formataInclusao();
        //BUSCA AS INFORMAÇÕES INICIAIS DA TELA.		
        manter_rotina('T');
        $('#frmInclusao').css({ 'display': 'block' });
        $('#divInclusao', '#frmInclusao').css({ 'display': 'block' });
        $('#dtSaqPagto', '#frmInclusao').focus();
    }

    //CONSULTA	
    if (cddopcao == 'C' || cddopcao == 'E' || cddopcao == 'A') {
        $('input,select,textarea,time', '#frmFiltro').limpaFormulario().removeClass('campoErro');
        formataFiltroConsulta();
        trocaBotao('Consultar');
        $('#divFiltro', '#frmFiltro').css({ 'display': 'block' });
        if (cddopcao == 'C') {
            $('#divFiltroConsulta', '#frmFiltro').css({ 'display': 'block' });
            $('#divFiltroExclusao', '#frmFiltro').css({ 'display': 'none' });
            $('#divFiltroAlt', '#frmFiltro').css({ 'display': 'none' });
            $('#dtPeriodoIni', '#frmFiltro').focus();
        } else if (cddopcao == 'E') {
            $('#divFiltroExclusao', '#frmFiltro').css({ 'display': 'block' });
            $('#divFiltroConsulta', '#frmFiltro').css({ 'display': 'none' });
            $('#divFiltroAlt', '#frmFiltro').css({ 'display': 'none' });
            $('#dtDataExc', '#frmFiltro').focus();
            $('#nrCpfCnpjExc', '#frmFiltro').unbind('focusin').bind('focusin', function () {
                //verifica conta															
                $('#nrCpfCnpjExc', '#frmFiltro').setMask('INTEGER', 'zzzzzzzzzzzzzz', '', '');
            });
        } else {
            $('#divFiltroConsulta', '#frmFiltro').css({ 'display': 'none' });
            $('#divFiltroExclusao', '#frmFiltro').css({ 'display': 'none' });
            $('#divFiltroAlt', '#frmFiltro').css({ 'display': 'block' });
            formatTabEnterAlterarFiltro();
            $('#dsProtAlt', '#frmFiltro').focus();
            $('#nrCpfCnpjAlt', '#frmFiltro').unbind('focusin').bind('focusin', function () {
                //verifica conta						
                $('#nrCpfCnpjAlt', '#frmFiltro').setMask('INTEGER', 'zzzzzzzzzzzzzz', '', '');
            });
        }
    }
    return false;
}

// Botoes
function btnVoltar() {
    if (nvVoltar == 'C') {
        manter_rotina(nvVoltar);
        $('#frmConsulta').css({ 'display': 'block' });
        nvVoltar = '';
    } else if (nvVoltar == 'A') {
        nvVoltar = '';
        manter_rotina('A');
        $('#frmConsulta').css({ 'display': 'block' });

    } else {
        estadoInicial();
    }
    return false;
}

function btnContinuar() {

    var cddopcao = $("#cddopcao", "#" + frmCab).val();
    //Remove a classe de Erro do form
    if (cddopcao == 'I') {
        $('input,select', '#frmInclusao').removeClass('campoErro');
        manter_rotina('I');
    }

    if (cddopcao == 'C' || cddopcao == 'E' || cddopcao == 'A') {
        //BUSCA AS INFORMAÇÕES INICIAIS DA TELA.		
        manter_rotina(cddopcao);
        $('#frmConsulta').css({ 'display': 'block' });
    }
}

function trocaBotao(botao) {

    $('#divBotoes', '#divTela').html('');
    $('#divBotoes', '#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;" >Voltar</a>&nbsp;');

    if (botao != '') {
        $('#divBotoes', '#divTela').append('<a href="#" class="botao" id="btSalvar" onclick="btnContinuar(); return false;" >' + botao + '</a>');
    }

    return false;
}

function manter_rotina(rotina, nriniseq, nrregist) {
    // Mostra mensagem de aguardo		
    var cddopcao = $('#cddopcao', '#' + frmCab).val();
    var cdcoptel = '';
    var indpessoa = $('#indPessoa', '#frmInclusao').val();

    /*if(rotina != undefined){
		cddopcao = rotina;
		if(cddopcao == 'C1' || cddopcao == 'A1'){
			if($('#divCoptel','#frmmain').css('display') != 'none'){
				cdcoptel = $('#dsidpara','#frmmain').val();
			}
		}
	}*/

    //window.focus();
    //console.log(rotina);
    //verifica conta
    if (rotina == 'CT') {
        var nrContTit = $('#nrContTit', '#frmInclusao').val();
        var nrTit = $('#nrTit', '#frmInclusao').val();
        if (!nrContTit) {
            $('#nrCpfCnpj', '#frmInclusao').val('');
            $('#nmSolic', '#frmInclusao').val('');
            $('#indPessoa', '#frmInclusao').val('');
            $('#nrTit', '#frmInclusao').val('');
            $('#nrTit', '#frmInclusao').attr('disabled', true);
            return false;
        } else {
            if (indPessoa == 1) {
                if (!nrTit && $('#nrTit', '#frmInclusao').is(':enabled')) {
                    if (nriniseq == 2) {
                        return false;
                    }
                }
            }
        }
    }

    //verifica CPF Sacado
    if (rotina == 'CS') {
        var nrCpfSacPag = $('#nrCpfSacPag', '#frmInclusao').val();
        if (!nrCpfSacPag) {
            $('#nmSacPag', '#frmInclusao').val('');
            return false;
        }
    }

    if (rotina == 'C') {
        var dtPeriodoIni = $('#dtPeriodoIni', '#frmFiltro').val();
        var dtPeriodoFim = $('#dtPeriodoFim', '#frmFiltro').val();
        var tpOperacao = $('#tpOperacao', '#frmFiltro').val();
        var nrPA = $('#nrPA', '#frmFiltro').val();
        var tpSituacao = $('#tpSituacao', '#frmFiltro').val();
        var tpOrigem = $('#tpOrigem', '#frmFiltro').val();

        //validar campos		
        if (!validaData(dtPeriodoIni)) {
            showError("error", "Data Inicial inv&aacute;lida", "Alerta - Ayllos", "$('#dtPeriodoIni','#frmFiltro').focus();");
            return false;
        }

        if (!validaData(dtPeriodoFim)) {
            showError("error", "Data Final inv&aacute;lida", "Alerta - Ayllos", "$('#dtPeriodoFim','#frmFiltro').focus();");
            return false;
        }

        if (validaData(dtPeriodoIni) && validaData(dtPeriodoFim)) {
            var dateParts = dtPeriodoIni.split("/");
            var dataIni = new Date(dateParts[2], dateParts[1] - 1, dateParts[0]);
            var dateParts = dtPeriodoFim.split("/");
            var dataFim = new Date(dateParts[2], dateParts[1] - 1, dateParts[0]);
            if (dataIni > dataFim) {
                showError("error", "Data Inicio n&atilde;o pode ser superior a data fim.", "Alerta - Ayllos", "$('#dtPeriodoIni','#frmFiltro').focus();");
                return false;
            }
        }

        if (tpSituacao == '0') {
            tpSituacao = '';
        }

        if (tpOrigem == '0') {
            tpOrigem = '';
        }

        if (tpOperacao == '0') {
            tpOperacao = '';
        }
    }

    if (rotina == 'I' || rotina == 'I!' || rotina == 'I!!' || rotina == 'I!!!' || rotina == 'PDF') {
        var dtSaqPagto = $('#dtSaqPagto', '#frmInclusao').val();
        var hrSaqPagto = $('#hrSaqPagto', '#frmInclusao').val();
        var vlSaqPagto = $('#vlSaqPagto', '#frmInclusao').val();
        var selSaqCheq = $('#selSaqCheq', '#frmInclusao').val();
        var nrBanco = $('#nrBanco', '#frmInclusao').val();
        var nrAgencia = $('#nrAgencia', '#frmInclusao').val();
        var nrContCheq = $('#nrContCheq', '#frmInclusao').val();
        var nrCheque = $('#nrCheque', '#frmInclusao').val();
        var nrContTit = $('#nrContTit', '#frmInclusao').val();
        var nrTit = $('#nrTit', '#frmInclusao').val();
        var nrCpfCnpj = $('#nrCpfCnpj', '#frmInclusao').val();
        var nmSolic = $('#nmSolic', '#frmInclusao').val();
        var nrCpfSacPag = $('#nrCpfSacPag', '#frmInclusao').val();
        var nmSacPag = $('#nmSacPag', '#frmInclusao').val();
        var nrPA = $('#nrPA', '#frmInclusao').val();
        var txtFinPagto = removeAcentos(removeCaracteresInvalidos($('#txtFinPagto', '#frmInclusao').val(), 0));
        var txtObs = removeAcentos(removeCaracteresInvalidos($('#txtObs', '#frmInclusao').val(), 0));
        var selQuais = $('#selQuais', '#frmInclusao').val();
        var txtQuais = removeAcentos(removeCaracteresInvalidos($('#txtQuais', '#frmInclusao').val(), 0));
        var indPessoa = $('#indPessoa', '#frmInclusao').val();
        var dtDataExc = $('#dtDataExc', '#frmFiltro').val();
        var nrPAExc = $('#nrPAExc', '#frmFiltro').val();
        var nrCpfCnpjExc = $('#nrCpfCnpjExc', '#frmFiltro').val();
        var arrExc = '';

        //insere provisao
        if (rotina == 'I') {
            //validar campos		
            if (!validaData(dtSaqPagto)) {
                showError("error", "Data saque deve ser informado", "Alerta - Ayllos", "$('#dtSaqPagto','#frmInclusao').focus();");
                return false;
            }

            if (!hrSaqPagto) {
                showError("error", "Horario saque deve ser informado.", "Alerta - Ayllos", "$('#hrSaqPagto','#frmInclusao').focus();");
                return false;
            } else {
                hrSaqPagto = hrSaqPagto.replace(':', '');
                if (hrSaqPagto.length != 4) {
                    showError("error", "Horario valor invalido.", "Alerta - Ayllos", "$('#hrSaqPagto','#frmInclusao').focus();");
                    return false;
                } else {
                    h = hrSaqPagto.substring(0, 2);
                    m = hrSaqPagto.substring(2, 4);
                    if (h < 0 || h > 23) {
                        showError("error", "Hora valor invalido.", "Alerta - Ayllos", "$('#hrSaqPagto','#frmInclusao').focus();");
                        return false;
                    }

                    if (m < 0 || m > 59) {
                        showError("error", "Minuto valor invalido.", "Alerta - Ayllos", "$('#hrSaqPagto','#frmInclusao').focus();");
                        return false;
                    }
                }
            }

            if (!vlSaqPagto) {
                showError("error", "Valor Saque deve ser informado.", "Alerta - Ayllos", "$('#vlSaqPagto','#frmInclusao').focus();");
                return false;
            }

            if (selSaqCheq == 1) {
                if (!nrAgencia) {
                    showError("error", "Agencia do Cheque deve ser informado.", "Alerta - Ayllos", "$('#nrAgencia','#frmInclusao').focus();");
                    return false;
                }

                if (!nrContCheq) {
                    showError("error", "Conta Cheque deve ser informado.", "Alerta - Ayllos", "$('#nrContCheq','#frmInclusao').focus();");
                    return false;
                }

                if (!nrCheque) {
                    showError("error", "Numero do Cheque deve ser informado.", "Alerta - Ayllos", "$('#nrCheque','#frmInclusao').focus();");
                    return false;
                }
            }

            if (!nrContTit) {
                showError("error", "Conta titular deve ser informado.", "Alerta - Ayllos", "$('#nrContTit','#frmInclusao').focus();");
                return false;
            }

            if (indPessoa == 1) {
                if (!nrTit) {
                    showError("error", "Titular deve ser informado.", "Alerta - Ayllos", "$('#nrTit','#frmInclusao').focus();");
                    return false;
                }
            }

            if (!nrCpfSacPag) {
                showError("error", "CPF do sacador deve ser informado.", "Alerta - Ayllos", "$('#nrCpfSacPag','#frmInclusao').focus();");
                return false;
            }

            if (!nmSacPag) {
                showError("error", "Nome do sacador deve ser informado.", "Alerta - Ayllos", "$('#nmSacPag','#frmInclusao').focus();");
                return false;
            }

            if (!nrPA) {
                showError("error", "PA que sera realizado o saque deve ser informado.", "Alerta - Ayllos", "$('#nrPA','#frmInclusao').focus();");
                return false;
            }

            if (!txtFinPagto) {
                showError("error", "Campo finalidade deve ser informado.", "Alerta - Ayllos", "$('#txtFinPagto','#frmInclusao').focus();");
                return false;
            }

            if (selQuais == 1) {
                if (!txtQuais) {
                    showError("error", "Campo Quais deve ser informado.", "Alerta - Ayllos", "$('#txtQuais','#frmInclusao').focus();");
                    return false;
                }
            }
            //insere verificado			
            showConfirmacao("078 - Deseja confirma a opera&ccedil;&atilde;o?", "Confirma&ccedil;&atilde;o - Ayllos", "manter_rotina('I!')", "", "sim.gif", "nao.gif");
        }
    }

    if (rotina == 'PDF') {
        var dsprotocolo = $('#dsprotocolo', '#frmInclusao').val();
    }

    if (rotina == 'A' || rotina == 'A!' || rotina == 'A!!') {
        //primeira tela da alteraçao		
        if (nvVoltar != 'A') {
            var dtDataAlt = $('#dtDataAlt', '#frmFiltro').val();
            var nrCpfCnpjAlt = $('#nrCpfCnpjAlt', '#frmFiltro').val();
            var nrPAAlt = $('#nrPAAlt', '#frmFiltro').val();
            var dsProtAlt = $('#dsProtAlt', '#frmFiltro').val();

            nrCpfCnpjAlt = nrCpfCnpjAlt.replace('.', '').replace('-', '').replace('/', '');
            if (nrCpfCnpjAlt == 0) {
                nrCpfCnpjAlt = '';
            } else {
                if (nrCpfCnpjAlt) {
                    var tpPessoa = verificaTipoPessoa(nrCpfCnpjAlt);
                    if (tpPessoa == 0) {
                        showError("error", "CPF/CNPJ valor incorreto.", "Alerta - Ayllos", "$('#nrCpfCnpjAlt','#frmFiltro').focus();");
                        return false;
                    } else {
                        if (tpPessoa == 1) {//cpf					
                            $('#nrCpfCnpjAlt', '#frmFiltro').setMask('INTEGER', '999.999.999-99', '.-', '');
                        }
                        if (tpPessoa == 2) {//cnpj					
                            $('#nrCpfCnpjAlt', '#frmFiltro').setMask('INTEGER', 'z.zzz.zzz/zzzz-zz', '/.-', '');
                        }
                        $('#nrCpfCnpjAlt', '#frmFiltro').hide().show(0);
                        $('#dsProtAlt', '#frmFiltro').focus();
                    }
                }
            }

            if (!dtDataAlt && !nrPAAlt && !nrCpfCnpjAlt && !dsProtAlt) {
                showError("error", "Pelo menos 1 filtro deve ser aplicado.", "Alerta - Ayllos", "$('#dsProtAlt','#frmInclusao').focus();");
                return false;
            }
        } else {
            //segunda tela da alteraçao
            //valores alterados
            var dtSaqPagtoAlt = $('#dtSaqPagtoAlt', '#frmConsulta').val();
            var hrSaqPagtoAlt = $('#hrSaqPagtoAlt', '#frmConsulta').val();
            var vlSaqPagtoAlt = $('#vlSaqPagtoAlt', '#frmConsulta').val();
            var tpSituacaoAlt = $('#tpSituacaoAlt', '#frmConsulta').val();
            //valores originais
            var cdcooperOri = $('#cdcooperOri', '#frmConsulta').val();
            var dtSaqPagtoOri = $('#dhsaqueOri', '#frmConsulta').val();
            var nrcpfcgcOri = $('#nrcpfcgcOri', '#frmConsulta').val();
            var nrdcontaOri = $('#nrdcontaOri', '#frmConsulta').val();
            var vlsaqpagtoOri = $('#vlsaqpagtoOri', '#frmConsulta').val();
            var tpsituacaoOri = $('#tpsituacaoOri', '#frmConsulta').val();

            if (rotina != 'A!' && rotina != 'A!!') {
                if (!dtSaqPagtoAlt) {
                    showError("error", "Data do saque obrigatorio.", "Alerta - Ayllos", "$('#dtSaqPagtoAlt','#frmConsulta').focus();");
                    return false;
                } else {
                    var ano = dtSaqPagtoAlt.substring(6, 10);
                    var mes = dtSaqPagtoAlt.substring(3, 5) - 1;
                    var dia = dtSaqPagtoAlt.substring(0, 2);
                    var hora = hrSaqPagtoAlt.substring(0, 2);
                    var min = hrSaqPagtoAlt.substring(3, 5);
                    var dtAlt = new Date(ano, mes, dia, 0, 0, 0);

                    ano = dtSaqPagtoOri.substring(6, 10);
                    mes = dtSaqPagtoOri.substring(3, 5) - 1;
                    dia = dtSaqPagtoOri.substring(0, 2);
                    hora = dtSaqPagtoOri.substring(11, 13);
                    min = dtSaqPagtoOri.substring(14, 16);
                    dtOri = new Date(ano, mes, dia, 0, 0, 0);
                    if (dtAlt < dtOri) {
                        showError("error", "N&atilde;o &eacute; possivel reduzir a data.", "Alerta - Ayllos", "$('#dtSaqPagtoAlt','#frmConsulta').focus();");
                        return false;
                    }
                }

                if (!hrSaqPagtoAlt) {
                    showError("error", "Horario saque deve ser informado.", "Alerta - Ayllos", "$('#hrSaqPagtoAlt','#frmConsulta').focus();");
                    return false;
                } else {
                    hrSaqPagtoAlt = hrSaqPagtoAlt.replace(':', '');
                    if (hrSaqPagtoAlt.length != 4) {
                        showError("error", "Horario valor invalido.", "Alerta - Ayllos", "$('#hrSaqPagtoAlt','#frmConsulta').focus();");
                        return false;
                    } else {
                        h = hrSaqPagtoAlt.substring(0, 2);
                        m = hrSaqPagtoAlt.substring(2, 4);
                        if (h < 0 || h > 23) {
                            showError("error", "Hora valor invalido.", "Alerta - Ayllos", "$('#hrSaqPagtoAlt','#frmConsulta').focus();");
                            return false;
                        }

                        if (m < 0 || m > 59) {
                            showError("error", "Minuto valor invalido.", "Alerta - Ayllos", "$('#hrSaqPagtoAlt','#frmConsulta').focus();");
                            return false;
                        }
                    }
                }

                if (!vlSaqPagtoAlt) {
                    showError("error", "Valor do saque/pagamento obrigatorio.", "Alerta - Ayllos", "$('#vlSaqPagtoAlt','#frmConsulta').focus();");
                    return false;
                }

                showConfirmacao("Deseja confirma a opera&ccedil;&atilde;o?", "Confirma&ccedil;&atilde;o - Ayllos", "manter_rotina('A!')", "btnVoltar()", "sim.gif", "nao.gif");
                return false;
            }
        }
    }

    if (rotina == 'E' || rotina == 'E!') {
        var dtDataExc = $('#dtDataExc', '#frmFiltro').val();
        var nrCpfCnpjExc = $('#nrCpfCnpjExc', '#frmFiltro').val();
        var nrPAExc = $('#nrPAExc', '#frmFiltro').val();

        if (rotina == 'E') {
            nrCpfCnpjExc = nrCpfCnpjExc.replace('.', '').replace('-', '').replace('/', '');
            if (nrCpfCnpjExc == 0) {
                nrCpfCnpjExc = '';
            }

            if (!dtDataExc && !nrPAExc && !nrCpfCnpjExc) {
                showError("error", "Pelo menos 1 filtro deve ser aplicado.", "Alerta - Ayllos", "$('#dtDataExc','#frmFiltro').focus();");
                return false;
            }
            if (nrCpfCnpjExc) {
                var tpPessoa = verificaTipoPessoa(nrCpfCnpjExc);
                if (tpPessoa == 0) {
                    showError("error", "CPF/CNPJ valor incorreto.", "Alerta - Ayllos", "$('#nrCpfCnpjExc','#frmFiltro').focus();");
                    return false;
                } else {
                    if (tpPessoa == 1) {//cpf												
                        $('#nrCpfCnpjExc', '#frmFiltro').setMask('INTEGER', '999.999.999-99', '.-', '');
                    }
                    if (tpPessoa == 2) {//cnpj																						
                        $('#nrCpfCnpjExc', '#frmFiltro').setMask('INTEGER', 'z.zzz.zzz/zzzz-zz', '/.-', '');
                    }
                    $('#nrCpfCnpjExc', '#frmFiltro').hide().show(0);
                    $('#dtDataExc', '#frmFiltro').focus();
                }
            }
            //realizar pergunta
            var arrExc = recuperaLinhasSelecionadas('tabConsulta');
            if (arrExc.length > 0) {
                showConfirmacao("Deseja confirma a opera&ccedil;&atilde;o?", "Confirma&ccedil;&atilde;o - Ayllos", "manter_rotina('E!')", "", "sim.gif", "nao.gif");
                return false;
            }
        } else {
            rotina = 'E';
            var arrExc = recuperaLinhasSelecionadas('tabConsulta');
        }
    }

    if (rotina != 'I') {
        showMsgAguardo("Aguarde, carregando ...");
        $.ajax({
            type: "POST",
            url: UrlSite + "telas/prvsaq/manter_rotina.php",
            data: {
                cddopcao: cddopcao,
                cdcooper: $("#cdcooper", "#" + frmCab).val(),
                dtSaqPagto: dtSaqPagto,
                hrSaqPagto: hrSaqPagto,
                vlSaqPagto: vlSaqPagto,
                selSaqCheq: selSaqCheq,
                nrBanco: nrBanco,
                nrAgencia: nrAgencia,
                nrContCheq: nrContCheq,
                nrCheque: nrCheque,
                nrContTit: nrContTit,
                nrTit: nrTit,
                nrCpfCnpj: nrCpfCnpj,
                nmSolic: nmSolic,
                nrCpfSacPag: nrCpfSacPag,
                nmSacPag: nmSacPag,
                nrPA: nrPA,
                txtFinPagto: txtFinPagto,
                txtObs: txtObs,
                selQuais: selQuais,
                txtQuais: txtQuais,
                cdcoptel: cdcoptel,
                rotina: rotina,
                indPessoa: indPessoa,
                dsprotocolo: dsprotocolo,
                dtPeriodoIni: dtPeriodoIni,
                dtPeriodoFim: dtPeriodoFim,
                tpOperacao: tpOperacao,
                nrPA: nrPA,
                tpSituacao: tpSituacao,
                tpOrigem: tpOrigem,
                dtDataExc: dtDataExc,
                nrCpfCnpjExc: nrCpfCnpjExc,
                nrPAExc: nrPAExc,
                arrExc: arrExc,
                dsProtAlt: dsProtAlt,
                dtDataAlt: dtDataAlt,
                nrCpfCnpjAlt: nrCpfCnpjAlt,
                nrPAAlt: nrPAAlt,
                dtSaqPagtoAlt: dtSaqPagtoAlt,
                hrSaqPagtoAlt: hrSaqPagtoAlt,
                vlSaqPagtoAlt: vlSaqPagtoAlt,
                tpSituacaoAlt: tpSituacaoAlt,
                cdcooperOri: cdcooperOri,
                dtSaqPagtoOri: dtSaqPagtoOri,
                nrcpfcgcOri: nrcpfcgcOri,
                nrdcontaOri: nrdcontaOri,
                vlsaqpagtoOri: vlsaqpagtoOri,
                tpsituacaoOri: tpsituacaoOri,
                nriniseq: nriniseq,
                nrregist: nrregist,
                redirect: "script_ajax"
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            },
            success: function (response) {
                hideMsgAguardo();
                try {
                    //usa o nvVoltar para identificar que o sistema esta na tela de alteracao 					
                    if (cddopcao == 'C' || cddopcao == 'E' || cddopcao == 'A') {
                        if (response.includes('showError')) {
                            eval(response);
                        } else {
                            if (nvVoltar != 'A') {
                                $("#divTabela").html(response);
                                formataConsulta();
                                selecionaCheck();
                            } else {
                                eval(response);
                            }
                        }

                    } else {
                        eval(response);
                    }
                } catch (error) {
                    hideMsgAguardo();
                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
                }
            }
        });
    }
}

function controlaOperacao(operacao, nriniseq, nrregist) {

    /*var mensagem = 'Aguarde, buscando dados ...';
    showMsgAguardo(mensagem);

    // Carrega dados da conta através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/prvsaq/manter_rotina.php',
        data:
			{
				sidlogin		: $('#frmInclusao').attr('sidlogin'),
				cddopcao		: cCddopcao.val(),
				cdcooper		: cCdcoo.val(),
				nrPA			:
				rotina			:
				dtPeriodoIni	:
				dtPeriodoFim	:
				tpSituacao		:
				tpOrigem		:
				redirect		: 'script_ajax'
			},
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response) {
            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divTela').html(response);
                    return false;
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            } else {
                try {
                    eval(response);
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            }
        }
    });

    return false;*/
}

function recuperaLinhasSelecionadas(nomTabela) {
    var arrExc = new Array();
    $('#' + nomTabela + ' tr').each(function () {
        var isChecked = $(this).find("input:checkbox:checked").length;
        if (isChecked) {
            var cdcooper = $(this).find("#cdcooper").val();
            var dhsaque = $(this).find("#dhsaque").val();
            var nrcpfcgc = $(this).find("#nrcpfcgc").val();
            var nrdconta = $(this).find("#nrdconta").val();

            var arrAux = new Array();
            arrAux.push(cdcooper);
            arrAux.push(dhsaque);
            arrAux.push(nrcpfcgc);
            arrAux.push(nrdconta);
            arrExc.push(arrAux);
        }
    });

    return arrExc;
}

function selecionaCheck() {
    var arrExc = recuperaLinhasSelecionadas('tabConsulta');
    if (arrExc.length > 0) {
        trocaBotao('Excluir');
    } else {
        trocaBotao('Consultar');
    }
}

function ver_rotina() {
    var cddopcao = $("#cddopcao", "#frmCab").val();
    if (cddopcao == "C") {
        manter_rotina("C1");
    }
    return false;
}

//funcao para carregar cooperativas em combobox
function carregaCooperativas(qtdCooperativas) {
    for (var i = 0; i < qtdCooperativas; i++) {
        $('option', '#dsidpara').remove();

    }
    for (var i = 0; i < qtdCooperativas; i++) {
        if (i == 0 && $('#cddopcao', '#frmCab').val() == "A") {
            cDsidpara.append("<option id='coop0' value='0'>Todas Cooperativas</option>");
        }
        cDsidpara.append("<option id='coop" + lstCooperativas[i].cdcooper + "' value='" + lstCooperativas[i].cdcooper + "'>" + lstCooperativas[i].nmrescop + "</option>");
    }

    hideMsgAguardo();
}

function confirmaExclusao(nmuf) {
    showConfirmacao("Deseja excluir '" + nmuf + "' da lista?", 'Confirma&ccedil;&atilde;o - Ayllos', "removerEstado('" + nmuf + "')", '', 'sim.gif', 'nao.gif');
}

function removerEstado(nmuf) {
    var dsestted = $('#dsestted', '#frmmain').val();
    var arrDsestted = dsestted.split(';');
    var opcao = '';
    var index;

    for (index = 0; index < arrDsestted.length; index++) {
        if (nmuf.indexOf(arrDsestted[index]) == -1) {
            opcao += (opcao == '' ? '' : ';') + arrDsestted[index];
        }
    }

    // Seta as opcoes sem o estado excluido
    $('#dsestted', '#frmmain').val(opcao);

    // Monta os estados
    carregaEstados();
}

function incluirEstado() {
    var nmuf = $('#nmuf', '#frmmain').val();
    var dsestted = $('#dsestted', '#frmmain').val();
    dsestted += (dsestted == '' ? '' : ';') + nmuf;

    if (nmuf != null) {
        // Seta as opcoes com o estado incluido
        $('#dsestted', '#frmmain').val(dsestted);
        // Monta os estados
        carregaEstados();
    }
}

function limpaSelects() {
    $('#optNaoCheq', '#frmInclusao').attr('selected', true);
    $('#optNaoQuais', '#frmInclusao').attr('selected', true);
    liberaDadosCheque();
    liberaCampoQuais();
}

function liberaDadosCheque() {
    var op = $('#selSaqCheq', '#frmInclusao').val();
    if (op == '1') {
        $('#divDadosCheque', '#frmInclusao').css({ 'display': 'block' });
    } else {
        $('#divDadosCheque', '#frmInclusao').css({ 'display': 'none' });
        //$('#nrBanco','#frmInclusao').val('');
        //$('#nrAgencia','#frmInclusao').val('');
        $('#nrContCheq', '#frmInclusao').val('');
        $('#nrCheque', '#frmInclusao').val('');
    }
}

function liberaCampoQuais() {
    var op = $('#selQuais', '#frmInclusao').val();
    if (op == '1') {
        $('#divTxtQuais', '#frmInclusao').css({ 'display': 'block' });
        $('#txtQuais', '#frmInclusao').attr('readonly', false);
    } else {
        $('#divTxtQuais', '#frmInclusao').css({ 'display': 'none' });
        $('#txtQuais', '#frmInclusao').attr('readonly', true);
        $('#txtQuais', '#frmInclusao').attr('value', "");
    }
}

function imprimirProtocolo() {
    var action = UrlSite + 'telas/prvsaq/imprimir_protocolo.php';
    var sidlogin = $('#sidlogin', '#frmCab').val();
    $('#sidlogin', '#frmInclusao').val(sidlogin);
    carregaImpressaoAyllos('frmInclusao', action, "estadoInicial();");
}

// Monta Grid Inicial
function buscaRegional(nriniseq, nrregist) {

    var cddopcao = cCddopcao.val();

    $('input,select').removeClass('campoErro');
    manter_rotina('C');
}

function formatTabEnterConsulta() {
    $('#dtPeriodoIni', '#frmFiltro').unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#dtPeriodoFim', '#frmFiltro').focus();
            return false;
        }
    });

    $('#dtPeriodoFim', '#frmFiltro').unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#nrPA', '#frmFiltro').focus();
            return false;
        }
    });

    $('#nrPA', '#frmFiltro').unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#tpSituacao', '#frmFiltro').focus();
            return false;
        }
    });

    $('#tpSituacao', '#frmFiltro').unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#tpOrigem', '#frmFiltro').focus();
            return false;
        }
    });

    $('#tpOrigem', '#frmFiltro').unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#btSalvar').focus();
            return false;
        }
    });


}
function formatTabEnterExclusao() {

    $('#dtDataExc', '#frmFiltro').unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#nrPAExc', '#frmFiltro').focus();
            return false;
        }
    });

    $('#nrPAExc', '#frmFiltro').unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#nrCpfCnpjExc', '#frmFiltro').focus();
            return false;
        }
    });

    $('#nrCpfCnpjExc', '#frmFiltro').unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#btSalvar').focus();
            return false;
        }
    });
}

function formatTabEnterAlterarFiltro() {
    $('#dsProtAlt', '#frmFiltro').unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#dtDataAlt', '#frmFiltro').focus();
            return false;
        }
    });

    $('#dtDataAlt', '#frmFiltro').unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#nrPAAlt', '#frmFiltro').focus();
            return false;
        }
    });

    $('#nrPAAlt', '#frmFiltro').unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#nrCpfCnpjAlt', '#frmFiltro').focus();
            return false;
        }
    });

    $('#nrCpfCnpjAlt', '#frmFiltro').unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#btSalvar').focus();
            return false;
        }
    });
}

function formatTabEnterAltera() {
    // Se ? a tecla ENTER	
    $('#dtSaqPagtoAlt', '#frmConsulta').unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#hrSaqPagtoAlt', '#frmConsulta').focus();
            return false;
        }
    });

    $('#hrSaqPagtoAlt', '#frmConsulta').unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#vlSaqPagtoAlt', '#frmConsulta').focus();
            return false;
        }
    });

    $('#vlSaqPagtoAlt', '#frmConsulta').unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#tpSituacaoAlt', '#frmConsulta').focus();
            return false;
        }
    });

    $('#tpSituacaoAlt', '#frmConsulta').unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#btSalvar').focus();
            return false;
        }
    });

}
function formatTabEnterInclusao() {
    // Se ? a tecla ENTER			
    $('#dtSaqPagto', '#frmInclusao').unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#hrSaqPagto', '#frmInclusao').focus();
            return false;
        }
    });

    $('#hrSaqPagto', '#frmInclusao').unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#vlSaqPagto', '#frmInclusao').focus();
            return false;
        }
    });

    $('#vlSaqPagto', '#frmInclusao').unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#selSaqCheq', '#frmInclusao').focus();
            return false;
        }
    });

    $('#selSaqCheq', '#frmInclusao').unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            if ($('#selSaqCheq', '#frmInclusao').val() == 1) {
                $('#nrAgencia', '#frmInclusao').focus();
            } else {
                $('#nrContTit', '#frmInclusao').focus();
            }
            return false;
        }
    });

    $('#nrAgencia', '#frmInclusao').unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#nrContCheq', '#frmInclusao').focus();
            return false;
        }
    });

    $('#nrContCheq', '#frmInclusao').unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#nrCheque', '#frmInclusao').focus();
            return false;
        }
    });

    $('#nrCheque', '#frmInclusao').unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#nrContTit', '#frmInclusao').focus();
            return false;
        }
    });

    $('#nrContTit', '#frmInclusao').unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13 || e.keyCode == 9) {
            manter_rotina('CT', 1);
            return false;
        }
    });

    $('#nrTit', '#frmInclusao').unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13 || e.keyCode == 9) {
            $('#nrCpfSacPag', '#frmInclusao').focus();
            return false;
        }
    });

    $('#nrCpfSacPag', '#frmInclusao').unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#nmSacPag', '#frmInclusao').focus();
            return false;
        }
    });
    $('#nmSacPag', '#frmInclusao').unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#nrPA', '#frmInclusao').focus();
            return false;
        }
    });

    $('#nrPA', '#frmInclusao').unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#txtFinPagto', '#frmInclusao').focus();
            return false;
        }
    });

    $('#txtFinPagto', '#frmInclusao').unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#txtObs', '#frmInclusao').focus();
            return false;
        }
    });

    $('#txtObs', '#frmInclusao').unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#selQuais', '#frmInclusao').focus();
            return false;
        }
    });

    $('#selQuais', '#frmInclusao').unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            if ($('#selQuais', '#frmInclusao').val() == 1) {
                $('#txtQuais', '#frmInclusao').focus();
            } else {
                $('#btSalvar').focus();
            }
            return false;
        }
    });

    $('#txtQuais', '#frmInclusao').unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        $('input,select,textarea').removeClass('campoErro');
        if (e.keyCode == 13) {
            $('#btSalvar').focus();
            return false;
        }
    });
}


function realizarLogin() {

    showMsgAguardo('Aguarde, abrindo ...');

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/prvsaq/rotina.php',
        data: {
            operacao: 'PW',
            redirect: 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground()");
        },
        success: function (response) {
            $('#divRotina').html(response);
            buscaSenha();
            return false;
        }
    });

    return false;
}

function buscaSenha() {

    hideMsgAguardo();

    showMsgAguardo('Aguarde, abrindo ...');

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/prvsaq/form_senha.php',
        data: {
            operacao: 'PW',
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground();");
        },
        success: function (response) {

            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divConteudoRotina').html(response);
                    exibeRotina($('#divRotina'));
                    formataSenha();
                    $('#codsenha', '#frmSenha').unbind('keydown').bind('keydown', function (e) {
                        if (divError.css('display') == 'block') { return false; }
                        // Se é a tecla ENTER, 
                        if (e.keyCode == 13) {
                            validarSenha();
                            return false;
                        }
                    });
                    return false;
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            } else {
                try {
                    eval(response);
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            }
        }
    });

    return false;
}

function validarSenha() {

    hideMsgAguardo();

    // Situacao
    var cddopcao = $("#cddopcao", "#" + frmCab).val();
    operauto = $('#operauto', '#frmSenha').val();
    var codsenha = $('#codsenha', '#frmSenha').val();

    showMsgAguardo('Aguarde, validando dados ...');

    $.ajax({
        type: 'POST',
        async: true,
        url: UrlSite + 'telas/prvsaq/valida_senha.php',
        data: {
            operauto: operauto,
            codsenha: codsenha,
            cddopcao: cddopcao,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '');
        },
        success: function (response) {
            try {
                eval(response);
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '');
            }
        }
    });
    return false;
}

function formataSenha() {

    highlightObjFocus($('#frmSenha'));

    rOperador = $('label[for="operauto"]', '#frmSenha');
    rSenha = $('label[for="codsenha"]', '#frmSenha');

    rOperador.addClass('rotulo').css({ 'width': '165px' });
    rSenha.addClass('rotulo').css({ 'width': '165px' });

    cOperador = $('#operauto', '#frmSenha');
    cSenha = $('#codsenha', '#frmSenha');

    cOperador.addClass('campo').css({ 'width': '100px' }).attr('maxlength', '10');
    cSenha.addClass('campo').css({ 'width': '100px' }).attr('maxlength', '10');

    $('#divConteudoRotina').css({ 'width': '400px', 'height': '120px' });

    // centraliza a divRotina
    $('#divRotina').css({ 'width': '425px' });
    $('#divConteudo').css({ 'width': '400px' });
    $('#divRotina').centralizaRotinaH();

    hideMsgAguardo();
    bloqueiaFundo($('#divRotina'));
    cOperador.focus();

    return false;
}

function checkOptionSelected(opt_selected) {
    if (opt_selected != 'C' && opt_selected != 'A') {
        cCdcooper.hide();
        rCdcooper.hide();
    } else {
        cCdcooper.show();
        rCdcooper.show();
        cCdcooper.habilitaCampo();
    }
}
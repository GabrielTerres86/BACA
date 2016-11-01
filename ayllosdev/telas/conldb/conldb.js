/*!
 * FONTE        : coninf.js
 * CRIAÇÃO      : Dionathan Henchel
 * DATA CRIAÇÃO : 01/09/2015
 * OBJETIVO     : Biblioteca de funções da tela CONLDB
 * --------------
 * ALTERAÇÕES   :
 *
 * --------------
 */

//Labels/Campos do cabeçalho
var cCddopcao, cTodosCabecalho, cTodosFrmArquivo, cTodosFrmConta, dtmvtolt, glbArquivo;

// Definição de algumas variáveis globais 
var cddopcao = 'A';

//Formulários
var frmCab = 'frmCab';

$(document).ready(function() {

    dtmvtolt = $('#dtinicio', '#frmArquivo').val();
    glbCdcooper = ($('#cdcooper', '#divCdcooper').val());

    estadoInicial();

    highlightObjFocus($('#' + frmCab));
    highlightObjFocus($('#frmArquivo'));
    highlightObjFocus($('#frmConta'));

    $('fieldset > legend').css({'font-size': '11px', 'color': '#777', 'margin-left': '5px', 'padding': '0px 2px'});
    $('fieldset').css({'clear': 'both', 'border': '1px solid #777', 'margin': '3px 0px', 'padding': '10px 3px 5px 3px'});

    return false;

});

function estadoInicial() {

    $('#divTela').fadeTo(0, 0.1);
    $('#frmCab').css({'display': 'block'});

    $('#frmArquivo').css({'display': 'none'});
    $('#divBotoesArquivo').css({'display': 'none'});
    $('#divListaArquivo').html('');

    $('#frmConta').css({'display': 'none'});
    $('#divBotoesConta').css({'display': 'none'});
    $('#divListaConta').html('');

    trocaBotao('voltaPrincipal');

    // Limpa conteudo da divBotoes
    //   $('#divBotoes', '#divTela').html('');
    //   $('#divBotoes').css({'display': 'none'});

    // Aplica Layout nos fontes PHP
    formataCabecalho();
    formataFrmArquivo();
    formataFrmConta();

    // Limpa informações dos Formularios
    cTodosCabecalho.limpaFormulario();
    cTodosFrmArquivo.limpaFormulario();
    cTodosFrmConta.limpaFormulario();

    removeOpacidade('divTela');
    unblockBackground();
    hideMsgAguardo();

    // Desativa campos do cabeçalho
    cTodosCabecalho.desabilitaCampo();

    controlaFoco();

    $('#dtinicio', '#frmArquivo').val(dtmvtolt);
    $('#dtafinal', '#frmArquivo').val(dtmvtolt);

    $('#cddopcao', '#frmCab').habilitaCampo().val(cddopcao);
    $('#cddopcao', '#' + frmCab).focus();

    if (glbCdcooper != 3) {
        $('#cdcooper', '#frmConta').val(glbCdcooper);
    }

}

function formataCabecalho() {

    rCddopcao = $('label[for="cddopcao"]', '#' + frmCab);

    cCddopcao = $('#cddopcao', '#' + frmCab);
    cTodosCabecalho = $('input[type="text"],select', '#' + frmCab);
    btnCab = $('#btOK', '#' + frmCab);

    rCddopcao.css('width', '75px');

    cCddopcao.css({'width': '630px'});

    cTodosCabecalho.habilitaCampo();

    $('#cddopcao', '#' + frmCab).focus();

    layoutPadrao();
    return false;
}

function controlaOpcao() {

    if ($('#cddopcao', '#frmCab').hasClass('campoTelaSemBorda')) {
        return false;
    }

    // Desabilita campo opção
    cTodosCabecalho = $('input[type="text"],select', '#frmCab');
    cTodosCabecalho.desabilitaCampo();

    // A - Arquivos
    if ($('#cddopcao', '#frmCab').val() == 'A') {

        $('#frmArquivo').css({'display': 'block'});
        $('#divBotoesArquivo').css({'display': 'block'});

        $('#dtinicio', '#frmArquivo').focus();


    } else {

        $('#frmConta').css({'display': 'block'});
        $('#divBotoesConta').css({'display': 'block'});

        if (glbCdcooper != 3) {
            buscaNomeCooperativa();
            $('#cddregio', '#frmConta').focus();
        } else {
            $('#cdcooper', '#frmConta').focus();
        }
    }

    return false;

}

function formataFrmArquivo() {

    // cabecalho
    rDtinicio = $('label[for="dtinicio"]', '#frmArquivo');
    rDtafinal = $('label[for="dtafinal"]', '#frmArquivo');

    cDtinicio = $('#dtinicio', '#frmArquivo');
    cDtafinal = $('#dtafinal', '#frmArquivo');

    cTodosFrmArquivo = $('input[type="text"],select', '#frmArquivo');


    rDtinicio.css({'width': '75'});
    rDtafinal.css({'width': '28px'});

    cDtinicio.css({'width': '75px'}).setMask('DATE', '', '', '');
    cDtafinal.css({'width': '75px'}).setMask('DATE', '', '', '');

    cTodosFrmArquivo.habilitaCampo();
    $('#btConsultar', '#divBotoesArquivo').show();

    layoutPadrao();
    return false;
}

function formataFrmConta() {

    // cabecalho
    rCdcooper = $('label[for="cdcooper"]', '#frmConta');
    rNmrescop = $('label[for="nmrescop"]', '#frmConta');
    rCddregio = $('label[for="cddregio"]', '#frmConta');
    rDsdregio = $('label[for="dsdregio"]', '#frmConta');
    rCdagenci = $('label[for="cdagenci"]', '#frmConta');
    rNmresage = $('label[for="nmresage"]', '#frmConta');
    rDtlanini = $('label[for="dtlanini"]', '#frmConta');
    rDtlanfim = $('label[for="dtlanfim"]', '#frmConta');
    rDtarqini = $('label[for="dtarqini"]', '#frmConta');
    rDtarqfim = $('label[for="dtarqfim"]', '#frmConta');
    rCdlancto = $('label[for="cdlancto"]', '#frmConta');
    rCddoprod = $('label[for="cddoprod"]', '#frmConta');
    rNmarquiv = $('label[for="nmarquiv"]', '#frmConta');
    rCdsituac = $('label[for="cdsituac"]', '#frmConta');

    cCdcooper = $('#cdcooper', '#frmConta');
    cNmrescop = $('#nmrescop', '#frmConta');
    cCddregio = $('#cddregio', '#frmConta');
    cDsdregio = $('#dsdregio', '#frmConta');
    cCdagenci = $('#cdagenci', '#frmConta');
    cNmresage = $('#nmresage', '#frmConta');
    cDtlanini = $('#dtlanini', '#frmConta');
    cDtlanfim = $('#dtlanfim', '#frmConta');
    cDtarqini = $('#dtarqini', '#frmConta');
    cDtarqfim = $('#dtarqfim', '#frmConta');
    cCdlancto = $('#cdlancto', '#frmConta');
    cCddoprod = $('#cddoprod', '#frmConta');
    cNmarquiv = $('#nmarquiv', '#frmConta');
    cCdsituac = $('#cdsituac', '#frmConta');

    cTodosFrmConta = $('input[type="text"],select', '#frmConta');

    rCdcooper.css({'width': '75'});
    rCddregio.css({'width': '70'});
    rCdagenci.css({'width': '35'});
    rDtlanini.css({'width': '75'});
    rDtlanfim.css({'width': '28px'});
    rDtarqini.css({'width': '89'});
    rDtarqfim.css({'width': '28px'});
    rCdlancto.css({'width': '90px'});
    rCddoprod.css({'width': '75px'});
    rNmarquiv.css({'width': '75px'});
    rCdsituac.css({'width': '75px'});

    cCdcooper.css({'width': '35px'}).setMask('INTEGER', 'z9', '', '');
    cNmrescop.css({'width': '145px'});
    cCddregio.css({'width': '35px'}).setMask('INTEGER', 'z9', '', '');
    cDsdregio.css({'width': '145px'});
    cCdagenci.css({'width': '35px'}).setMask('INTEGER', 'zz9', '', '');
    cNmresage.css({'width': '145px'});
    cCdlancto.css({'width': '164px'});
    cCddoprod.css({'width': '140px'});
    cNmarquiv.css({'width': '275px'}).attr('maxlength', '100');
    cCdsituac.css({'width': '140px'});

    cDtlanini.css({'width': '75px'}).setMask('DATE', '', '', '');
    cDtlanfim.css({'width': '75px'}).setMask('DATE', '', '', '');
    cDtarqini.css({'width': '75px'}).setMask('DATE', '', '', '');
    cDtarqfim.css({'width': '75px'}).setMask('DATE', '', '', '');

    cTodosFrmConta.habilitaCampo();

    cNmrescop.desabilitaCampo();
    cDsdregio.desabilitaCampo();
    cNmresage.desabilitaCampo();

    if ($('#cdcooper', '#divCdcooper').val() != 3) {
        cCdcooper.desabilitaCampo();
    }

    layoutPadrao();
    return false;
}

function btnVoltar() {
    estadoInicial();
    return false;
}

function controlaFoco() {

    // frmCab
    $('#cddopcao', '#frmCab').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#btnOK', '#frmCab').focus();
            return false;
        }
    });

    $('#dtinicio', '#frmArquivo').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#dtafinal', '#frmArquivo').focus();
            return false;
        }
    });

    $('#dtafinal', '#frmArquivo').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            controlaOperacao('A');
            return false;
        }
    });

    $('#cdcooper', '#frmConta').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#cddregio', '#frmConta').focus();
            return false;
        }
    });

    $('#cddregio', '#frmConta').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#cdagenci', '#frmConta').focus();

            if ($('#cddregio', '#frmConta').val() != 0) {
                buscaNomeRegional();
            }

            return false;
        }
    });

    $('#cdagenci', '#frmConta').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {

            if ($('#cdcooper', '#frmConta').val() != '') {
                if ($('#cdagenci', '#frmConta').val() != 0) {
                    buscaDadosPA();
                } else {
                    $('#nmrescop', '#frmConta').val('');
                }
            }

            $('#dtlanini', '#frmConta').focus();
            return false;
        }
    });

    $('#dtlanini', '#frmConta').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#dtlanfim', '#frmConta').focus();
            return false;
        }
    });

    $('#dtlanfim', '#frmConta').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#dtarqini', '#frmConta').focus();
            return false;
        }
    });

    $('#dtarqini', '#frmConta').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#dtarqfim', '#frmConta').focus();
            return false;
        }
    });

    $('#dtarqfim', '#frmConta').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#cdlancto', '#frmConta').focus();
            return false;
        }
    });


    $('#cdlancto', '#frmConta').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#cddoprod', '#frmConta').focus();
            return false;
        }
    });

    $('#cddoprod', '#frmConta').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#nmarquiv', '#frmConta').focus();
            return false;
        }
    });

    $('#nmarquiv', '#frmConta').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#cdsituac', '#frmConta').focus();
            return false;
        }
    });

    $('#cdsituac', '#frmConta').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            alert('Pendente');
            return false;
        }
    });

    if (glbCdcooper == 3) {

        $('#cdcooper', '#frmConta').unbind('blur').bind('blur', function() {
            if ($('#cdcooper', '#frmConta').val() != 0) {
                buscaNomeCooperativa();
            }
            return false;
        });
    }

    $('#cdagenci', '#frmConta').unbind('blur').bind('blur', function() {
        $('#nmresage', '#frmConta').val('');
        if ($('#cdagenci', '#frmConta').val() != 0) {
            buscaDadosPA();
        }
        return false;
    });


    $('#cddregio', '#frmConta').unbind('blur').bind('blur', function() {
        $('#dsdregio', '#frmConta').val('');
        if ($('#cddregio', '#frmConta').val() != 0) {
            buscaNomeRegional();
        }
        return false;
    });



}

function controlaOperacao(operacao) {

    if (operacao == 'A') {
        buscaArquivos(1, 15);
    } else {
        buscaContas(1, 15);
    }
    return false;

}

function buscaArquivos(nriniseq, nrregist) {

    var cddopcao = $('#cddopcao', '#frmCab').val();
    var dtinicio = $('#dtinicio', '#frmArquivo').val();
    var dtafinal = $('#dtafinal', '#frmArquivo').val();


    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, efetuando consulta ...");

    // Carrega dados parametro através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/conldb/carrega_arquivos.php',
        data:
                {
                    cddopcao: cddopcao,
                    dtinicio: dtinicio,
                    dtafinal: dtafinal,
                    nriniseq: nriniseq,
                    nrregist: nrregist,
                    redirect: 'script_ajax'
                },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response) {
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divListaArquivo').html(response);
                    $('#divListaArquivo').css({'display': 'block'});

                    formataArquivos();
                    $('#divPesquisaRodape', '#divListaArquivo').formataRodapePesquisa();

                    cTodosFrmArquivo.desabilitaCampo();

                    $('#btConsultar', '#divBotoesArquivo').hide();


                    hideMsgAguardo();
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

function formataArquivos() {

    $('#divRotina').css('width', '640px');

    var divRegistro = $('div.divRegistros', '#divListaArquivo');
    var tabela = $('table', divRegistro);

    divRegistro.css({'height': '220px', 'width': '100%'});

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '330px';
    arrayLargura[1] = '60px';
    arrayLargura[2] = '60px';
    arrayLargura[3] = '90px';
    arrayLargura[4] = '90px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'left';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'center';

    var metodoTabela = '';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

    var divRegistro = $('div.divRegistros', '#divArquivos');

    rTotalpro = $('label[for="totalpro"]', '#divTotaisArquivo');
    rTotalpen = $('label[for="totalpen"]', '#divTotaisArquivo');
    rTotalerr = $('label[for="totalerr"]', '#divTotaisArquivo');

    rTotalpro.css({'width': '100px'});
    rTotalpen.css({'margin-left': '60px'});
    rTotalerr.css({'margin-left': '60px'});

    cTotalpro = $('#totalpro', '#divTotaisArquivo');
    cTotalpen = $('#totalpen', '#divTotaisArquivo');
    cTotalerr = $('#totalerr', '#divTotaisArquivo');

    cTotalpro.css({'width': '100px'}).desabilitaCampo();
    cTotalpen.css({'width': '100px'}).desabilitaCampo();
    cTotalerr.css({'width': '100px'}).desabilitaCampo();

    cTotalpro.css({'text-align': 'right'});
    cTotalpen.css({'text-align': 'right'});
    cTotalerr.css({'text-align': 'right'});

    layoutPadrao();

    glbArquivo = '';

    // seleciona o registro que é clicado
    $('table > tbody > tr', divRegistro).click(function() {
        glbArquivo = $(this).find('#nmarquivo').val();

    });

    $('table > tbody > tr', divRegistro).dblclick(function() {
        glbArquivo = $(this).find('#nmarquivo').val();
        chamaRotinaConsulta();

    });

    $('table > tbody > tr:eq(0)', divRegistro).click();

    return false;
}


function buscaContas(nriniseq, nrregist) {

    var cddopcao = $('#cddopcao', '#frmCab').val();
    var cdcooper = $('#cdcooper', '#frmConta').val();
    var cddregio = $('#cddregio', '#frmConta').val();
    var cdagenci = $('#cdagenci', '#frmConta').val();
    var dtlanini = $('#dtlanini', '#frmConta').val();
    var dtlanfim = $('#dtlanfim', '#frmConta').val();
    var dtarqini = $('#dtarqini', '#frmConta').val();
    var dtarqfim = $('#dtarqfim', '#frmConta').val();
    var cdlancto = $('#cdlancto', '#frmConta').val();
    var cddoprod = $('#cddoprod', '#frmConta').val();
    var cdsituac = $('#cdsituac', '#frmConta').val();
    var nmarquiv = $('#nmarquiv', '#frmConta').val();

    cddopcao = normalizaNumero(cddopcao);

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, efetuando consulta ...");

    // Carrega dados parametro através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/conldb/carrega_contas.php',
        data:
                {
                    cddopcao: cddopcao,
                    cdcooper: cdcooper,
                    cddregio: cddregio,
                    cdagenci: cdagenci,
                    dtlanini: dtlanini,
                    dtlanfim: dtlanfim,
                    dtarqini: dtarqini,
                    dtarqfim: dtarqfim,
                    cdlancto: cdlancto,
                    cddoprod: cddoprod,
                    cdsituac: cdsituac,
                    nmarquiv: nmarquiv,
                    nriniseq: nriniseq,
                    nrregist: nrregist,
                    redirect: 'script_ajax'
                },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response) {
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divListaConta').html(response);
                    $('#divListaConta').css({'display': 'block'});

                    formataContas();
                    $('#divPesquisaRodape', '#divListaConta').formataRodapePesquisa();

                    if (glbCdcooper != 3) {

                        buscaNomeCooperativa();
                    }

                    //   cTodosFrmConta.desabilitaCampo();
                    //   $('#cdsituac', '#frmConta').habilitaCampo();


                    hideMsgAguardo();
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

function formataContas() {

    $('#divRotina').css('width', '640px');

    rQtregist = $('label[for="qtregist"]', '#divTotaisConta');
    rVltotal = $('label[for="vltotal"]', '#divTotaisConta');

    rQtregist.css({'margin-left': '60px'});
    rVltotal.css({'margin-left': '60px'});

    cQtregist = $('#qtregist', '#divTotaisConta');
    cVltotal = $('#vltotal', '#divTotaisConta');

    cQtregist.css({'width': '100px'}).desabilitaCampo();
    cVltotal.css({'width': '100px'}).desabilitaCampo();

    var divRegistro = $('div.divRegistros', '#divListaConta');
    var tabela = $('table', divRegistro);

    divRegistro.css({'height': '220px', 'width': '100%'});

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '30px';
    arrayLargura[1] = '30px';
    arrayLargura[2] = '30px';
    arrayLargura[3] = '70px';
    arrayLargura[4] = '25px';
    arrayLargura[5] = '25px';
    arrayLargura[6] = '55px';
    arrayLargura[7] = '55px';
    arrayLargura[8] = '70px';
    arrayLargura[9] = '60px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'right';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'center';
    arrayAlinha[6] = 'center';
    arrayAlinha[7] = 'center';
    arrayAlinha[8] = 'right';
    arrayAlinha[9] = 'center';
    arrayAlinha[10] = 'left';

    var metodoTabela = '';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

    var tbody = $('tbody', tabela);
    var tr = $('tr', tbody);
    var td = $('td', tr);

    //   tr th

    td.css({'font-size': '11px'});

    // div.divRegistros table tbody tr td
    //table.tituloRegistros thead tr th
    // table.tituloRegistros thead tr th

    /*
     glbArquivo = '';
     
     // seleciona o registro que é clicado
     $('table > tbody > tr', divRegistro).click(function() {
     glbArquivo = $(this).find('#nmarquivo').val();
     
     });
     
     $('table > tbody > tr:eq(0)', divRegistro).click();
     */
    return false;
}

function pesquisaCooperativa() {

    // Se esta desabilitado o campo 
    if ($("#cdcooper", "#frmConta").prop("disabled") == true) {
        return;
    }

    // Variável local para guardar o elemento anterior
    var bo, procedure, titulo, qtReg, filtros, colunas, cdcooper, titulo_coluna, cdcoopers, cdcopaux, nmrescop;

    // Nome do Formulário que estamos trabalhando
    var nomeFormulario = 'frmConta';

    //Remove a classe de Erro do form
    $('input,select', '#' + nomeFormulario).removeClass('campoErro');

    var cdcooper = '';

    titulo_coluna = "Cooperativas";

    bo = 'b1wgen0153.p';
    procedure = 'lista-cooperativas';
    titulo = 'Cooperativas';
    qtReg = '10';
    filtros = 'Codigo;cdcooper;130px;S;' + cdcooper + ';S|Descricao;nmrescop;200px;S;' + nmrescop + ';S';
    colunas = 'Codigo;cdcooper;20%;right|' + titulo_coluna + ';nmrescop;50%;left';
    mostraPesquisa(bo, procedure, titulo, qtReg, filtros, colunas, '', '$(\'#cdcooper\',\'#frmConta\').val()');

    return false;
}

function buscaNomeCooperativa() {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, buscando dados da cooperativa...");

    var cdcooper = $('#cdcooper', '#divCdcooper').val();
    cdcooper = normalizaNumero(cdcooper);

    // Executa script através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/conldb/busca_dados_coop.php",
        data: {
            cdcooper: cdcooper,
            redirect: "script_ajax"
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            try {
                hideMsgAguardo();
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });

    return false;

}

function pesquisaPA() {

    // Se esta desabilitado o campo 
    if ($("#cdagenci", "#frmConta").prop("disabled") == true) {
        return;
    }

    // Variável local para guardar o elemento anterior
    var bo, procedure, titulo, qtReg, filtros, colunas, cdcooper, nmrescop, cdagenci, titulo_coluna, cdagencis, nmresage;

    // Nome do Formulário que estamos trabalhando
    var nomeFormulario = 'frmConta';

    //Remove a classe de Erro do form
    $('input,select', '#' + nomeFormulario).removeClass('campoErro');

    var cdagenci = $('#cdagenci', '#' + nomeFormulario).val();

    var cdcooper = $('#cdcooper', '#frmConta').val();

    if (cdcooper == '') {
        var cdcooper = $('#cdcooper', '#divCdcooper').val();
    }

    cdagencis = cdagenci;
    nmresage = ' ';
    nmrescop = ' ';

    titulo_coluna = "Descricao";

    bo = 'b1wgen0153.p';
    procedure = 'lista-pacs';
    titulo = 'PA';
    qtReg = '20';

    if ($('#cdcooper', '#divCdcooper').val() == 3) {
        filtros = 'Coop;cdcooper;30px;S;' + cdcooper + ';S|Nome Coop;nmrescop;30px;N;' + nmrescop + ';N|Cod. PA;cdagenci;30px;S;' + cdagenci + ';S|Agência PA;nmresage;200px;S;' + nmresage + ';N';
        colunas = 'Cód. Coop;cdcooper;20%;right|Cooperativa;nmrescop;27%;right|Cód. PA;cdagenci;15%;right|' + titulo_coluna + ';nmresage;50%;left';
    } else {
        filtros = 'Cod. PA;cdagenci;30px;S;' + cdagenci + ';S|Agencia PA;nmresage;200px;S;' + nmresage + ';N';
        colunas = 'Codigo;cdagenci;20%;right|' + titulo_coluna + ';nmresage;50%;left';
    }


    mostraPesquisa(bo, procedure, titulo, qtReg, filtros, colunas, '', '$(\'#cdagenci\',\'#frmReltar\').val()');

    return false;
}

function chamaRotinaConsulta() {

    $('#cddopcao', '#frmCab').val('C');
    $('#frmArquivo').css({'display': 'none'});
    $('#divBotoesArquivo').css({'display': 'none'});
    $('#divListaArquivo').html('');
    $('#frmConta').css({'display': 'block'});
    $('#divBotoesConta').css({'display': 'block'});

    $('#nmarquiv', '#frmConta').val(glbArquivo);
    $('#nmarquiv', '#frmConta').desabilitaCampo();

    trocaBotao('voltaArquivo');
    controlaOperacao('C');
}

function chamaRotinaArquivo() {
    $('#cddopcao', '#frmCab').val('A');
    $('#frmArquivo').css({'display': 'block'});
    $('#divBotoesArquivo').css({'display': 'block'});
    $('#divListaConta').html('');
    $('#frmConta').css({'display': 'none'});
    $('#divBotoesConta').css({'display': 'none'});
    controlaOperacao('A');

}


function trocaBotao(opcao) {

    $('#divBotoesConta', '#divTela').html('');

    if (opcao != 'voltaArquivo') {
        $('#divBotoesConta', '#divTela').append('<a href="#" class="botao" id="btVoltar"  	onClick="btnVoltar(); return false;">Voltar</a>');
    } else {
        $('#divBotoesConta', '#divTela').append('<a href="#" class="botao" id="btVoltar"  	onClick="chamaRotinaArquivo(); return false;">Voltar</a>');
    }

    $('#divBotoesConta', '#divTela').append('<a href="#" class="botao" id="btConsultar"  onClick="controlaOperacao(\'C\'); return false;">Consultar</a>');
    $('#divBotoesConta', '#divTela').append('<a href="#" class="botao" id="btExportar"  	onClick="exportaContas(); return false;">Exportar</a>');

    return false;
}

function pesquisaRegional() {

    // pr_cdcooper, pr_cddregio

    procedure = 'LISTA_REGIONAL';
    titulo = 'Regionais';
    qtReg = '20';
    //  filtrosPesq = 'DDD;cddregio;200px;S;;S;descricao|Celular;dsdregio;200px;S;;S;descricao';
    filtrosPesq = 'Codigo;cddregio;200px;S;;S;descricao|Descricao;dsdregio;200px;S;;N;descricao|Conta;cdcooper;100px;S;' + glbCdcooper + ';N';
    colunas = 'Codigo;cddregio;30%;center|Descricao;dsdregio;70%;left';
    mostraPesquisa('CONLDB', procedure, titulo, qtReg, filtrosPesq, colunas, '');
    return false;
}



function exportaContas() {

    var nomeform = 'frmExporta';
    var cddopcao = $('#cddopcao', '#frmCab').val();
    var cdcooper = $('#cdcooper', '#frmConta').val();
    var cddregio = $('#cddregio', '#frmConta').val();
    var cdagenci = $('#cdagenci', '#frmConta').val();
    var dtlanini = $('#dtlanini', '#frmConta').val();
    var dtlanfim = $('#dtlanfim', '#frmConta').val();
    var dtarqini = $('#dtarqini', '#frmConta').val();
    var dtarqfim = $('#dtarqfim', '#frmConta').val();
    var cdlancto = $('#cdlancto', '#frmConta').val();
    var cddoprod = $('#cddoprod', '#frmConta').val();
    var cdsituac = $('#cdsituac', '#frmConta').val();
    var nmarquiv = $('#nmarquiv', '#frmConta').val();
    var insaida = '2';

    $('#sidlogin', '#' + nomeform).remove();

    $('#cddopcao1', '#' + nomeform).remove();
    $('#cdcooper1', '#' + nomeform).remove();
    $('#cddregio1', '#' + nomeform).remove();
    $('#cdagenci1', '#' + nomeform).remove();
    $('#dtlanini1', '#' + nomeform).remove();
    $('#dtlanfim1', '#' + nomeform).remove();
    $('#dtarqini1', '#' + nomeform).remove();
    $('#dtarqfim1', '#' + nomeform).remove();
    $('#cdlancto1', '#' + nomeform).remove();
    $('#cddoprod1', '#' + nomeform).remove();
    $('#cdsituac1', '#' + nomeform).remove();
    $('#nmarquiv1', '#' + nomeform).remove();
    $('#insaida1', '#' + nomeform).remove();

    // Insere input do tipo hidden do formulário para enviá-los posteriormente
    $('#' + nomeform).append('<input type="text" id="cddopcao1" name="cddopcao1" />');
    $('#' + nomeform).append('<input type="text" id="cdcooper1" name="cdcooper1" />');
    $('#' + nomeform).append('<input type="text" id="cddregio1" name="cddregio1" />');
    $('#' + nomeform).append('<input type="text" id="cdagenci1" name="cdagenci1" />');
    $('#' + nomeform).append('<input type="text" id="dtlanini1" name="dtlanini1" />');
    $('#' + nomeform).append('<input type="text" id="dtlanfim1" name="dtlanfim1" />');
    $('#' + nomeform).append('<input type="text" id="dtarqini1" name="dtarqini1" />');
    $('#' + nomeform).append('<input type="text" id="dtarqfim1" name="dtarqfim1" />');
    $('#' + nomeform).append('<input type="text" id="cdlancto1" name="cdlancto1" />');
    $('#' + nomeform).append('<input type="text" id="cddoprod1" name="cddoprod1" />');
    $('#' + nomeform).append('<input type="text" id="cdsituac1" name="cdsituac1" />');
    $('#' + nomeform).append('<input type="text" id="nmarquiv1" name="nmarquiv1" />');
    $('#' + nomeform).append('<input type="text" id="insaida1" name="insaida1" />');


    $('#' + nomeform).append('<input type="text" id="sidlogin" name="sidlogin" />');

    // Agora insiro os devidos valores nos inputs criados
    $('#cddopcao1', '#' + nomeform).val(cddopcao);
    $('#cdcooper1', '#' + nomeform).val(cdcooper);
    $('#cddregio1', '#' + nomeform).val(cddregio);
    $('#cdagenci1', '#' + nomeform).val(cdagenci);
    $('#dtlanini1', '#' + nomeform).val(dtlanini);
    $('#dtlanfim1', '#' + nomeform).val(dtlanfim);
    $('#dtarqini1', '#' + nomeform).val(dtarqini);
    $('#dtarqfim1', '#' + nomeform).val(dtarqfim);
    $('#cdlancto1', '#' + nomeform).val(cdlancto);
    $('#cddoprod1', '#' + nomeform).val(cddoprod);
    $('#cdsituac1', '#' + nomeform).val(cdsituac);
    $('#nmarquiv1', '#' + nomeform).val(nmarquiv);
    $('#insaida1', '#' + nomeform).val(insaida);

    $('#sidlogin', '#' + nomeform).val($('#sidlogin', '#frmMenu').val());


    var action = UrlSite + 'telas/conldb/exporta_contas.php';

    // Variavel para os comandos de controle
    var controle = '';

    carregaImpressaoAyllos(nomeform, action, controle);

    return false;
}

function buscaDadosPA() {

    showMsgAguardo("Aguarde, consultando PA...");

    var cdagenci = $('#cdagenci', '#frmConta').val();
    cdagenci = normalizaNumero(cdagenci);

    var cdcooper = $('#cdcooper', '#frmConta').val();
    cdcooper = normalizaNumero(cdcooper);

    if ($('#cdcooper', '#frmConta').val() == '') {
        return false;
    }

    // Executa script através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/conldb/busca_pa.php",
        data: {
            cdagenci: cdagenci,
            cdcooper: cdcooper,
            redirect: "script_ajax"
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
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

function buscaNomeRegional() {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, buscando dados da regional...");

    var cdcooper = $('#cdcooper', '#frmConta').val();
    cdcooper = normalizaNumero(cdcooper);

    var cddregio = $('#cddregio', '#frmConta').val();
    cddregio = normalizaNumero(cddregio);

    // Executa script através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/conldb/busca_regional.php",
        data: {
            cdcooper: cdcooper,
            cddregio: cddregio,
            redirect: "script_ajax"
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            try {
                hideMsgAguardo();
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });

    return false;

}
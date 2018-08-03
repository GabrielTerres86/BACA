/*
 * FONTE        : concip.js
 * CRIAÇÃO      : Dionathan Henchel
 * DATA CRIAÇÃO : 01/09/2015
 * OBJETIVO     : Biblioteca de funções da tela CONCIP
 * --------------
 * ALTERAÇÕES   : 23/07/2018 - Adicionado campo Credenciadora e Liquidação nos Filtros (PRJ 486 - Mateus Z / Mouts)
 *
 * --------------
 */

//Labels/Campos do cabeçalho
var cCddopcao, cTodosCabecalho, cTodosFrmArquivo, cTodosFrmConta, dtmvtolt, glbArquivo, glbDtliquidacao, glbDtgeracao;

// Definição de algumas variáveis globais
var cddopcao = 'A';
var nriniseqAtual = 1;

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

    $('#frmConciliacao').css({'display': 'none'});
    $('#divBotoesConciliacao').css({'display': 'none'});
    $('#divListaConciliacao').html('');

    // PRJ 486 - Ajuste de layout para voltar ao tamanho original da tela
    $('#divTela').css('width','800px');

    trocaBotao('voltaPrincipal');

    // Limpa conteudo da divBotoes
    //   $('#divBotoes', '#divTela').html('');
    //   $('#divBotoes').css({'display': 'none'});

    // Aplica Layout nos fontes PHP
    formataCabecalho();
    formataFrmArquivo();
    formataFrmConta();
    formataFrmConciliacao();

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

    $('input, select', '#frmArquivo').removeAttr('tabindex');

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

        //chama o metodo de popular combos ao mostrar o frmArquivo
        $('#frmArquivo').ready(populaCombos);
    }
    //Conciliacao Liquidacao STR
    else if ($('#cddopcao', '#frmCab').val() == 'S'){
        $('#frmConciliacao').css({'display': 'block'});
        $('#divBotoesConciliacao').css({'display': 'block'});
        $('#dtlcto', '#frmConciliacao').focus();

        //chama o metodo de popular combos ao mostrar o frmConciliacao
        $('#frmConciliacao').ready(populaCombosConciliacao);
    }
    else {

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

//popula combos de filtragem de banco liquidante e credenciadora
function populaCombos(){

    //limpa os filtros antes de popular
    $('#bcoliquidante').empty().append($('<option>', { value: '', text: '  --  ' }));
    $('#credenciadora').empty().append($('<option>', { value: '', text: '  --  ' }));

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/concip/carrega_filtros.php",
        dataType: 'json',
        data: {
            redirect: "script_ajax"
        },
        error: function(objAjax, responseError, objExcept) {
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            try {
                if (response.liquidante.item.length > 0) {
                    //popula combo banco liquidante
                    $.each(response.liquidante.item, function (i, val) {
                        $('#bcoliquidante').append($('<option>', { value: val.ispb, text: val.nome }));
                    });
                }

                if (response.credenciadora.item.length > 0) {
                    //popula combo credenciadora
                    $.each(response.credenciadora.item, function (i, val) {
                        $('#credenciadora').append($('<option>', { value: val.ispb, text: val.nome }));
                    });
                }
            }
            catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });

    return false;
}


function formataFrmArquivo() {

    // cabecalho
    rDtinicio    = $('label[for="dtinicio"]', '#frmArquivo');
    rDtafinal    = $('label[for="dtafinal"]', '#frmArquivo');
    // PRJ 486
    rDtinicioliq = $('label[for="dtinicioliq"]', '#frmArquivo');
    rDtfinalliq  = $('label[for="dtfinalliq"]', '#frmArquivo');
    rFormtran    = $('label[for="formtran"]', '#frmArquivo');
    // Fim PRJ 486    

    cDtinicio    = $('#dtinicio', '#frmArquivo');
    cDtafinal    = $('#dtafinal', '#frmArquivo');
    // PRJ 486
    cDtinicioliq = $('#dtinicioliq', '#frmArquivo');
    cDtfinalliq  = $('#dtfinalliq', '#frmArquivo');
    // Fim PRJ 486

    cTodosFrmArquivo = $('input[type="text"],select', '#frmArquivo');

    rDtinicio.css({'width': '75'});
    rDtafinal.css({'width': '28px'});
    // PRJ 486
    rDtinicioliq.addClass('rotulo').css({'width': '75'});
    rDtfinalliq.css({'width': '28px'});
    rFormtran.addClass('rotulo-linha');
    // Fim PRJ 486

    cDtinicio.css({'width': '75px'}).setMask('DATE', '', '', '');
    cDtafinal.css({'width': '75px'}).setMask('DATE', '', '', '');
    // PRJ 486
    cDtinicioliq.css({'width': '75px'}).setMask('DATE', '', '', '');
    cDtfinalliq.css({'width': '75px'}).setMask('DATE', '', '', '');
    // Fim PRJ 486

    cTodosFrmArquivo.habilitaCampo();
    $('#btConsultar', '#divBotoesArquivo').show();
    $('#btExportar', '#divBotoesArquivo').hide();

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

function formataFrmConciliacao(){
    rDtLcto = $('label[for="dtlcto"]', '#frmConciliacao');
    rDtLcto = $('#dtlcto', '#frmConciliacao');
    rDtLcto.css({'width': '75px'}).setMask('DATE', '', '', '');
    $('#btConsultar', '#divBotoesConciliacao').show();
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
            $('#tpArquivo', '#frmArquivo').focus();
            return false;
        }
    });

    $('#tpArquivo', '#frmArquivo').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#bcoliquidante', '#frmArquivo').focus();
            return false;
        }
    });

    $('#bcoliquidante', '#frmArquivo').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#credenciadora', '#frmArquivo').focus();
            return false;
        }
    });

    $('#credenciadora', '#frmArquivo').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#dtinicioliq', '#frmArquivo').focus();
            return false;
        }
    });

    $('#dtinicioliq', '#frmArquivo').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#dtfinalliq', '#frmArquivo').focus();
            return false;
        }
    });

    $('#dtfinalliq', '#frmArquivo').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#formtran', '#frmArquivo').focus();
            return false;
        }
    });

    $('#formtran', '#frmArquivo').unbind('keypress').bind('keypress', function(e) {
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

    $('#dtlcto', '#frmConciliacao').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            // PRJ 486
            $('#credenciadorasstr', '#frmConciliacao').focus();
            return false;
        }
    });

    // PRJ 486
    $('#credenciadorasstr', '#frmConciliacao').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            controlaOperacao('STR');
            return false;
        }
    });
    // Fim PRJ 486    

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
            $('#nmarquiv', '#frmConta').focus();
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
    } else if(operacao == 'AC'){
        buscaArquivos(nriniseqAtual, 15);
    } else if(operacao == 'E'){
        exportaArquivos();
    } else if (operacao == 'STR') {
        buscaConciliacaoSTR();
    } else {
        buscaContas(1, 15);
    }
    return false;
}

function buscaArquivos(nriniseq, nrregist) {

    var cddopcao = $('#cddopcao', '#frmCab').val();
    var dtinicio = $('#dtinicio', '#frmArquivo').val();
    var dtafinal = $('#dtafinal', '#frmArquivo').val();
    var tparquivo = $('#tpArquivo', '#frmArquivo').val();
    var bcoliquidante = $('#bcoliquidante', '#frmArquivo').val();
    var credenciadora = $('#credenciadora', '#frmArquivo').val();
    var formtran = $('#formtran', '#frmArquivo').val();
	// PRJ 486
    var dtinicioliq = $('#dtinicioliq', '#frmArquivo').val();
    var dtfinalliq = $('#dtfinalliq', '#frmArquivo').val();
	// Fim PRJ 486

    nriniseqAtual = nriniseq;

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, efetuando consulta ...");

    // Carrega dados parametro através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/concip/carrega_arquivos.php',
        data:
            {
                cddopcao: cddopcao,
                dtinicio: dtinicio,
                dtafinal: dtafinal,
                tparquivo: tparquivo,
                credenciadora: credenciadora,
                bcoliquidante: bcoliquidante,
                nriniseq: nriniseq,
                nrregist: nrregist,
                formtran: formtran,
				// PRJ 486
                dtinicioliq: dtinicioliq,
                dtfinalliq: dtfinalliq,
				// Fim PRJ 486
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
                    $('#btExportar', '#divBotoesArquivo').show();

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

function buscaConciliacaoSTR(){
    var cddopcao = $('#cddopcao', '#frmCab').val();
    var dtlcto = $('#dtlcto', '#frmConciliacao').val();
    // PRJ 486
    var credenciadorasstr = $('#credenciadorasstr', '#frmConciliacao').val();

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, efetuando consulta ...");

    // Carrega dados parametro através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/concip/carrega_conciliacao.php',
        data:
        {
            cddopcao: cddopcao,
            dtlcto: dtlcto,
            // PRJ 486
            credenciadorasstr: credenciadorasstr,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response) {
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divListaConciliacao').html(response);
                    $('#divListaConciliacao').css({'display': 'block'});

                    formataConciliacao();
                    //$('#divPesquisaRodape', '#divListaArquivo').formataRodapePesquisa();
                    //cTodosFrmArquivo.desabilitaCampo();
                    $('#btConsultar', '#divBotoesConciliacao').hide();

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

function exportaArquivos(){

    var nomeform = 'frmExporta';
    var dtinicio = $('#dtinicio', '#frmArquivo').val();
    var dtafinal = $('#dtafinal', '#frmArquivo').val();
    var tparquivo = $('#tpArquivo', '#frmArquivo').val();
    var bcoliquidante = $('#bcoliquidante', '#frmArquivo').val();
    var credenciadora = $('#credenciadora', '#frmArquivo').val();

    //limpa do form
    $('#sidlogin', '#' + nomeform).remove();
    $('#dtinicio', '#' + nomeform).remove();
    $('#dtafinal', '#' + nomeform).remove();
    $('#tparquivo', '#' + nomeform).remove();
    $('#bcoliquidante', '#' + nomeform).remove();
    $('#credenciadora', '#' + nomeform).remove();

    //insere novos campos hidden no form
    $('#' + nomeform).append('<input type="hidden" id="dtinicio" name="dtinicio" />');
    $('#' + nomeform).append('<input type="hidden" id="dtafinal" name="dtafinal" />');
    $('#' + nomeform).append('<input type="hidden" id="tpArquivo" name="tparquivo" />');
    $('#' + nomeform).append('<input type="hidden" id="bcoliquidante" name="bcoliquidante" />');
    $('#' + nomeform).append('<input type="hidden" id="credenciadora" name="credenciadora" />');
    $('#' + nomeform).append('<input type="hidden" id="sidlogin" name="sidlogin" />');

    //insere valores nos campos criados
    $('#dtinicio', '#' + nomeform).val(dtinicio);
    $('#dtafinal', '#' + nomeform).val(dtafinal);
    $('#tparquivo', '#' + nomeform).val(tparquivo);
    $('#bcoliquidante', '#' + nomeform).val(bcoliquidante);
    $('#credenciadora', '#' + nomeform).val(credenciadora);
    $('#sidlogin', '#' + nomeform).val($('#sidlogin', '#frmMenu').val());

    //nomeform, action, controle
    carregaImpressaoAyllos(nomeform, UrlSite + 'telas/concip/exporta_arquivos.php', '');

    return false;
}


function formataArquivos() {

    $('#divRotina').css('width', '640px');

    $('fieldset').css({'clear': 'both', 'border': '1px solid #777', 'margin': '3px 5px', 'padding': '10px 3px 5px 3px'});

    var divRegistro = $('div.divRegistros', '#divListaArquivo');
    var tabela = $('table', divRegistro);

    divRegistro.css({'height': '220px'});

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '123px';
    arrayLargura[1] = '40px';
    arrayLargura[2] = '135px';
    arrayLargura[3] = '100px';
    arrayLargura[4] = '100px';
    arrayLargura[5] = '130px';
    arrayLargura[6] = '130px';
    arrayLargura[7] = '100px';
    arrayLargura[8] = '33px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'center';
    arrayAlinha[6] = 'center';
    arrayAlinha[7] = 'center';
    arrayAlinha[8] = 'center';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);

    var divRegistro = $('div.divRegistros', '#divArquivos');

    rTotalpro = $('label[for="totalpro"]', '#divTotaisArquivo');
    rTotalint = $('label[for="totalint"]', '#divTotaisArquivo');
    rTotalage = $('label[for="totalage"]', '#divTotaisArquivo');
    rTotalerr = $('label[for="totalerr"]', '#divTotaisArquivo');

    rFsqtprocessados = $('label[for="fsqtprocessados"]', '#divTotaisArquivo');
    rFsvlprocessados = $('label[for="fsvlprocessados"]', '#divTotaisArquivo');
    rFsqtintegrados = $('label[for="fsqtintegrados"]', '#divTotaisArquivo');
    rFsvlintegrados = $('label[for="fsvlintegrados"]', '#divTotaisArquivo');
    rFsqtagendados = $('label[for="fsqtagendados"]', '#divTotaisArquivo');
    rFsvlagendados = $('label[for="fsvlagendados"]', '#divTotaisArquivo');
    rFsqterros = $('label[for="fsqterros"]', '#divTotaisArquivo');
    rFsvlerros = $('label[for="fsvlerros"]', '#divTotaisArquivo');

    rTotalpro.css({'width': '70px','display': 'inline-block', 'text-align': 'right', 'margin-bottom': '10px'});
    rTotalint.css({'width': '70px', 'display': 'inline-block', 'text-align': 'right', 'margin-bottom': '10px'});
    rTotalage.css({'width': '70px', 'display': 'inline-block', 'text-align': 'right', 'margin-bottom': '10px'});
    rTotalerr.css({'width': '70px', 'display': 'inline-block', 'text-align': 'right', 'margin-bottom': '10px'});

    rFsqtprocessados.css({'width': '70px', 'display': 'inline-block', 'text-align': 'right', 'margin-bottom': '10px'});
    rFsvlprocessados.css({'width': '70px', 'display': 'inline-block', 'text-align': 'right', 'margin-bottom': '10px'});
    rFsqtintegrados.css({'width': '70px', 'display': 'inline-block', 'text-align': 'right', 'margin-bottom': '10px'});
    rFsvlintegrados.css({'width': '70px', 'display': 'inline-block', 'text-align': 'right', 'margin-bottom': '10px'});
    rFsqtagendados.css({'width': '70px', 'display': 'inline-block', 'text-align': 'right', 'margin-bottom': '10px'});
    rFsvlagendados.css({'width': '70px', 'display': 'inline-block', 'text-align': 'right', 'margin-bottom': '10px'});
    rFsqterros.css({'width': '70px', 'display': 'inline-block', 'text-align': 'right', 'margin-bottom': '10px'});
    rFsvlerros.css({'width': '70px', 'display': 'inline-block', 'text-align': 'right', 'margin-bottom': '10px'});

    cTotalpro = $('#totalpro', '#divTotaisArquivo');
    cTotalint = $('#totalint', '#divTotaisArquivo');
    cTotalage = $('#totalage', '#divTotaisArquivo');
    cTotalerr = $('#totalerr', '#divTotaisArquivo');

    cFsqtprocessados = $('#fsqtprocessados', '#divTotaisArquivo');
    cFsvlprocessados = $('#fsvlprocessados', '#divTotaisArquivo');
    cFsqtintegrados = $('#fsqtintegrados', '#divTotaisArquivo');
    cFsvlintegrados = $('#fsvlintegrados', '#divTotaisArquivo');
    cFsqtagendados = $('#fsqtagendados', '#divTotaisArquivo');
    cFsvlagendados = $('#fsvlagendados', '#divTotaisArquivo');
    cFsqterros = $('#fsqterros', '#divTotaisArquivo');
    cFsvlerros = $('#fsvlerros', '#divTotaisArquivo');

    cTotalpro.css({'width': '100px'}).desabilitaCampo();
    cTotalint.css({'width': '100px'}).desabilitaCampo();
    cTotalage.css({'width': '100px'}).desabilitaCampo();
    cTotalerr.css({'width': '100px'}).desabilitaCampo();

    cFsqtprocessados.css({'width': '100px'}).desabilitaCampo();
    cFsvlprocessados.css({'width': '100px'}).desabilitaCampo();
    cFsqtintegrados.css({'width': '100px'}).desabilitaCampo();
    cFsvlintegrados.css({'width': '100px'}).desabilitaCampo();
    cFsqtagendados.css({'width': '100px'}).desabilitaCampo();
    cFsvlagendados.css({'width': '100px'}).desabilitaCampo();
    cFsqterros.css({'width': '100px'}).desabilitaCampo();
    cFsvlerros.css({'width': '100px'}).desabilitaCampo();

    cTotalpro.css({'text-align': 'right', 'float': 'right'});
    cTotalint.css({'text-align': 'right', 'float': 'right'});
    cTotalage.css({'text-align': 'right', 'float': 'right'});
    cTotalerr.css({'text-align': 'right', 'float': 'right'});

    cFsqtprocessados.css({'text-align': 'right', 'float': 'right'});
    cFsvlprocessados.css({'text-align': 'right', 'float': 'right'});
    cFsqtintegrados.css({'text-align': 'right', 'float': 'right'});
    cFsvlintegrados.css({'text-align': 'right', 'float': 'right'});
    cFsqtagendados.css({'text-align': 'right', 'float': 'right'});
    cFsvlagendados.css({'text-align': 'right', 'float': 'right'});
    cFsqterros.css({'text-align': 'right', 'float': 'right'});
    cFsvlerros.css({'text-align': 'right', 'float': 'right'});

    layoutPadrao();

    glbArquivo = '';
    glbDtliquidacao = '';
    glbDtgeracao = '';

    // seleciona o registro que é clicado
    $('table > tbody > tr', divRegistro).click(function() {
        glbArquivo = $(this).find('#nmarquivo').val();
        selecionaArquivos($(this))
    });

    $('table > tbody > tr', divRegistro).dblclick(function() {
        glbArquivo = $(this).find('#nmarquivo').val();
        glbDtliquidacao = $(this).find('#dtliquidacao').val();
        glbDtgeracao = $(this).find('#dtgeracao').val().split(' ')[0];
        chamaRotinaConsulta();
    });

    $('table > tbody > tr:eq(0)', divRegistro).click();

    $('#divTela').css('width','1000px');

    return false;
}


function formataConciliacao(){
    //$('fieldset').css({'clear': 'both', 'border': '1px solid #777', 'margin': '0 auto', 'padding': '10px 3px 5px 3px'});
    $('fieldset').css({'clear': 'both', 'border': '1px solid #777', 'padding': '10px 5px 5px 5px'});

    rQdeCreditado  = $('label[for="txtQtcreditado"]', '#divTotaisConciliacao');
    rVlCreditado   = $('label[for="txtVlcreditado"]', '#divTotaisConciliacao');
    rQdePagamentos = $('label[for="txtQdeRecebido"]', '#divTotaisConciliacao');
    rVlPagamentos  = $('label[for="txtVlRecebido"]', '#divTotaisConciliacao');
    rVlReceber     = $('label[for="txtVlReceber"]', '#divTotaisConciliacao');
    rVlPagar       = $('label[for="txtVlPagar"]', '#divTotaisConciliacao');

    rQdeCreditado.css({'width': '70px','display': 'inline-block', 'text-align': 'right', 'margin-bottom': '10px'});
    rVlCreditado.css({'width': '70px', 'display': 'inline-block', 'text-align': 'right', 'margin-bottom': '10px'});
    rQdePagamentos.css({'width': '70px', 'display': 'inline-block', 'text-align': 'right', 'margin-bottom': '10px'});
    rVlPagamentos.css({'width': '70px', 'display': 'inline-block', 'text-align': 'right', 'margin-bottom': '10px'});
    rVlReceber.css({'width': '70px', 'display': 'inline-block', 'text-align': 'right', 'margin-bottom': '10px'});
    rVlPagar.css({'width': '70px', 'display': 'inline-block', 'text-align': 'right', 'margin-bottom': '10px'});

    cQdeCreditado  = $('#txtQtcreditado', '#divTotaisConciliacao');
    cVlCreditado   = $('#txtVlcreditado', '#divTotaisConciliacao');
    cQdePagamentos = $('#txtQdeRecebido', '#divTotaisConciliacao');
    cVlPagamentos  = $('#txtVlRecebido', '#divTotaisConciliacao');
    cVlReceber     = $('#txtVlReceber', '#divTotaisConciliacao');
    cVlPagar       = $('#txtVlPagar', '#divTotaisConciliacao');
    
    cQdeCreditado.css({'width': '100px'}).desabilitaCampo();
    cVlCreditado.css({'width': '100px'}).desabilitaCampo();
    cQdePagamentos.css({'width': '100px'}).desabilitaCampo();
    cVlPagamentos.css({'width': '100px'}).desabilitaCampo();
    cVlReceber.css({'width': '100px'}).desabilitaCampo();
    cVlPagar.css({'width': '100px'}).desabilitaCampo();
    
    cQdeCreditado.css({'text-align': 'right', 'float': 'right'});
    cVlCreditado.css({'text-align': 'right', 'float': 'right'});
    cQdePagamentos.css({'text-align': 'right', 'float': 'right'});
    cVlPagamentos.css({'text-align': 'right', 'float': 'right'});
    cVlReceber.css({'text-align': 'right', 'float': 'right'});
    cVlPagar.css({'text-align': 'right', 'float': 'right'});

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
    var formtran = $('#formtran', '#frmConta').val();

    cddopcao = normalizaNumero(cddopcao);

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, efetuando consulta ...");

    // Carrega dados parametro através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/concip/carrega_contas.php',
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
            formtran: formtran,
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
    arrayLargura[0] = '30px'; //coop
    arrayLargura[1] = '30px'; //reg
    arrayLargura[2] = '30px'; //pa
    arrayLargura[3] = '70px'; //conta
    arrayLargura[4] = '40px'; //lct
    arrayLargura[5] = '150px'; //bandeira
    arrayLargura[6] = '50px'; //forma transferencia
    arrayLargura[7] = '60px'; //dt lct
    arrayLargura[8] = '60px'; //dt arqu
    arrayLargura[9] = '90px'; //valor
    arrayLargura[10] = '80px'; //situacao

    
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
    arrayAlinha[10] = 'center';


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
        url: UrlSite + "telas/concip/busca_dados_coop.php",
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
    $('#dtlanini', '#frmConta').val(glbDtliquidacao);
    $('#dtlanfim', '#frmConta').val(glbDtliquidacao);
    $('#dtarqini', '#frmConta').val(glbDtgeracao);
    $('#dtarqfim', '#frmConta').val(glbDtgeracao);
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
    controlaOperacao('AC');

}


function trocaBotao(opcao) {

    $('#divBotoesConta', '#divTela').html('');

    if (opcao != 'voltaArquivo') {
        $('#divBotoesConta', '#divTela').append('<a href="#" class="botao" id="btVoltar"  	onClick="btnVoltar(); return false;">Voltar</a>');
    } else {
        $('#divBotoesConta', '#divTela').append('<a href="#" class="botao" id="btVoltar"  	onClick="chamaRotinaArquivo(); return false;">Voltar</a>');
    }

    $('#divBotoesConta', '#divTela').append('<a href="#" class="botao" id="btConsultar" onClick="controlaOperacao(\'C\'); return false;">Consultar</a>');
    $('#divBotoesConta', '#divTela').append('<a href="#" class="botao" id="btExportar" onClick="exportaContas(); return false;">Exportar</a>');

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
    mostraPesquisa('CONCIP', procedure, titulo, qtReg, filtrosPesq, colunas, '');
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

    var action = UrlSite + 'telas/concip/exporta_contas.php';

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
        url: UrlSite + "telas/concip/busca_pa.php",
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
        url: UrlSite + "telas/concip/busca_regional.php",
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

function selecionaArquivos(tr){

    $('#fsqtprocessados').val( $('#qtprocessados', tr ).val() );
    $('#fsvlprocessados').val( $('#vlprocessados', tr ).val() );
    $('#fsqtintegrados').val( $('#qtintegrados', tr ).val() );
    $('#fsvlintegrados').val( $('#vlintegrados', tr ).val() );
    $('#fsqtagendados').val( $('#qtagendados', tr ).val() );
    $('#fsvlagendados').val( $('#vlagendados', tr ).val() );
    $('#fsqterros').val( $('#qterros', tr ).val() );
    $('#fsvlerros').val( $('#vlerros', tr ).val() );

}

// PRJ 486 popula combo de filtragem de credenciadorasstr da Opcao S
function populaCombosConciliacao(){

    //limpa os filtros antes de popular
    $('#credenciadorasstr').empty();

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/concip/carrega_filtros.php",
        dataType: 'json',
        data: {
            redirect: "script_ajax"
        },
        error: function(objAjax, responseError, objExcept) {
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            try {
                if (response.credenciadorasstr.item.length > 0) {
                    //popula combo credenciadorasstr
                    $.each(response.credenciadorasstr.item, function (i, val) {
                        $('#credenciadorasstr').append($('<option>', { value: val.ispb, text: val.nome }));
                    });
                } else {
                    $('#credenciadorasstr').append($('<option>', { value: response.credenciadorasstr.item.ispb, 
                                                                   text: response.credenciadorasstr.item.nome }));
                }
            }
            catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });

    return false;
}

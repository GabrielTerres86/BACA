/*!
 * FONTE        : custod.js
 * CRIAÇÃO      : Rogerius Militão (DB1) 
 * DATA CRIAÇÃO : 18/01/2012
 * OBJETIVO     : Biblioteca de funções da tela custod
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * [29/03/2012] Rogérius Militão   (DB1) : Ajuste no layout padrão
 * [29/06/2012] Jorge Hamaguchi (CEBRED) : Ajuste para novo esquema de impressao em  imprimeFichaCadastralCF(), e confirmacao para impressao na chamada da funcao Gera_Impressao() 
 */

//Formulários e Tabela
var frmCab = 'frmCab';
var frmOpcao = 'frmOpcao';

var cddopcao = 'C';
var protocolo = '';

var nrJanelas = 0;
var nriniseq = 1;
var nrregist = 50;
var dsdopcao = 0;
var bcocxa12 = 600;

$(document).ready(function() {
    estadoInicial();
});

// inicio
function estadoInicial() {

    $('#divTela').fadeTo(0, 0.1);

    protocolo = '';

    // retira as mensagens	
    hideMsgAguardo();
    fechaRotina($('#divRotina'));
    fechaRotina($('#divUsoGenerico'));

    // formulario	
    formataCabecalho();
    cTodosCabecalho.limpaFormulario().removeClass('campoErro');

    $('#' + frmOpcao).remove();
    $('#divBotoes', '#divTela').remove();
    $('#divPesquisaRodape', '#divTela').remove();

    cCddopcao.val(cddopcao);
    cCddopcao.focus();

    removeOpacidade('divTela');
}


// controla
function controlaOperacao(operacao, nriniseq, nrregist) {

    var nrdconta = normalizaNumero($('#nrdconta', '#' + frmOpcao).val());
    var tpcheque = normalizaNumero($('#tpcheque', '#' + frmOpcao).val());
    var nrcpfcgc = normalizaNumero($('#nrcpfcgc', '#' + frmOpcao).val());
    var dtlibini = $('#dtlibini', '#' + frmOpcao).val();
    var dtlibfim = $('#dtlibfim', '#' + frmOpcao).val();
    var nmprimtl = $('#nmprimtl', '#' + frmOpcao).val();
    var dtlibera = $('#dtlibera', '#' + frmOpcao).val();
    var nrborder = normalizaNumero($('#nrborder', '#' + frmOpcao).val());
    var cdcmpchq = normalizaNumero($('#cdcmpchq', '#' + frmOpcao).val());
    var cdbanchq = normalizaNumero($('#cdbanchq', '#' + frmOpcao).val());
    var cdagechq = normalizaNumero($('#cdagechq', '#' + frmOpcao).val());
    var nrctachq = normalizaNumero($('#nrctachq', '#' + frmOpcao).val());
    var nrcheque = normalizaNumero($('#nrcheque', '#' + frmOpcao).val());
    var vlcheque = $('#vlrchequ', '#' + frmOpcao).val();
    var dsdopcao = normalizaNumero($('#dsdopcao', '#' + frmOpcao).val());

    var mensagem = 'Aguarde, buscando dados ...';
    showMsgAguardo(mensagem);

    cTodosOpcao.removeClass('campoErro');

    // Carrega dados da conta através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/custod/principal.php',
        data:
                {
                    operacao: operacao,
                    cddopcao: cddopcao,
                    nrdconta: nrdconta,
                    nrcpfcgc: nrcpfcgc,
                    tpcheque: tpcheque,
                    dtlibini: dtlibini,
                    dtlibfim: dtlibfim,
                    nmprimtl: nmprimtl,
                    dtlibera: dtlibera,
                    nrborder: nrborder,
                    cdcmpchq: cdcmpchq,
                    cdbanchq: cdbanchq,
                    cdagechq: cdagechq,
                    nrctachq: nrctachq,
                    nrcheque: nrcheque,
                    vlcheque: vlcheque,
                    dsdopcao: dsdopcao,
                    nriniseq: nriniseq,
                    nrregist: nrregist,
                    redirect: 'script_ajax'
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

    return false;
}

function manterRotina(operacao) {

    hideMsgAguardo();

    var nrdconta = normalizaNumero($('#nrdconta', '#' + frmOpcao).val());
    var nrcpfcgc = normalizaNumero($('#nrcpfcgc', '#' + frmOpcao).val());
    var nrborder = normalizaNumero($('#nrborder', '#' + frmOpcao).val());
    var cdcmpchq = normalizaNumero($('#cdcmpchq', '#' + frmOpcao).val());
    var cdbanchq = normalizaNumero($('#cdbanchq', '#' + frmOpcao).val());
    var cdagechq = normalizaNumero($('#cdagechq', '#' + frmOpcao).val());
    var nrctachq = normalizaNumero($('#nrctachq', '#' + frmOpcao).val());
    var nrcheque = normalizaNumero($('#nrcheque', '#' + frmOpcao).val());
    var nmcheque = $('#nmcheque', '#' + frmOpcao).val();

    var auxnrcpf = normalizaNumero($('#auxnrcpf', '#' + frmOpcao).val());
    var auxnmchq = $('#auxnmchq', '#' + frmOpcao).val();

    var dtmvtini = $('#dtmvtini', '#' + frmOpcao).val();
    var dtmvtfim = $('#dtmvtfim', '#' + frmOpcao).val();
    var cdagenci = normalizaNumero($('#cdagenci', '#' + frmOpcao).val());
    var flgrelat = $('#flgrelat', '#' + frmOpcao).val();
    var nmdopcao = $('#nmdopcao', '#' + frmOpcao).val();
    var nmdireto = $('#nmdireto', '#frmDiretorio').val();

    var dtlibera = $('#dtlibera', '#' + frmOpcao).val();
    var dtmvtolt = $('#dtmvtolt', '#' + frmOpcao).val();
    var nrdolote = $('#nrdolote', '#' + frmOpcao).val();
    var cdagelot = $('#cdagenci', '#' + frmOpcao).val();

    var mensagem = '';

    switch (operacao) {
        case 'BIA':
            mensagem = 'Aguarde, buscando dados ...';
            break;
        case 'GLC':
            mensagem = 'Aguarde, gerando relatorio ...';
            break;
        case 'VLD':
            mensagem = 'Aguarde, validando dados ...';
            break;
        case 'VDD':
            mensagem = 'Aguarde, validando dados ...';
            break;
        case 'VLE':
            mensagem = 'Aguarde, validando dados ...';
            break;
    }

    cTodosOpcao.removeClass('campoErro');
    showMsgAguardo(mensagem);

    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/custod/manter_rotina.php',
        data: {
            operacao: operacao,
            cddopcao: cddopcao,
            nrdconta: nrdconta,
            nrcpfcgc: nrcpfcgc,
            nrborder: nrborder,
            cdcmpchq: cdcmpchq,
            cdbanchq: cdbanchq,
            cdagechq: cdagechq,
            nrctachq: nrctachq,
            nrcheque: nrcheque,
            nmcheque: nmcheque,
            auxnrcpf: auxnrcpf,
            auxnmchq: auxnmchq,
            dtmvtini: dtmvtini,
            dtmvtfim: dtmvtfim,
            cdagenci: cdagenci,
            flgrelat: flgrelat,
            nmdopcao: nmdopcao,
            nmdireto: nmdireto,
            dtlibera: dtlibera,
            dtmvtolt: dtmvtolt,
            nrdolote: nrdolote,
            cdagelot: cdagelot,
            protocolo: protocolo,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response) {
            try {
                eval(response);
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
            }
        }
    });

    return false;

}

function controlaPesquisas() {

    /*---------------------*/
    /*  CONTROLE CONTA/DV  */
    /*---------------------*/
    var linkConta = $('a:eq(0)', '#' + frmOpcao);

    if (linkConta.prev().hasClass('campoTelaSemBorda')) {
        linkConta.addClass('lupa').css('cursor', 'auto').unbind('click').bind('click', function() {
            return false;
        });
    } else {
        linkConta.css('cursor', 'pointer').unbind('click').bind('click', function() {
            mostraPesquisaAssociado('nrdconta', frmOpcao);
        });
    }

    return false;
}


// opcao
function buscaOpcao() {

    showMsgAguardo('Aguarde, buscando dados ...');

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/custod/form_opcao_' + cddopcao.toLowerCase() + '.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground()");
        },
        success: function(response) {
            $('#divTela').html(response);

            //
            formataCabecalho();

            // 
            cCddopcao.desabilitaCampo();
            cCddopcao.val(cddopcao);

            // limpa formulario
            cTodosOpcao = $('input[type="text"], select', '#' + frmOpcao);

            if (cddopcao != 'R') {
                cTodosOpcao.limpaFormulario().removeClass('campoErro');
            }

            $('#divPesquisaRodape', '#divTela').remove();

            formataOpcao();

            hideMsgAguardo();
            return false;
        }
    });

    return false;

}

function formataOpcao() {

    highlightObjFocus($('#' + frmOpcao));


    if (cddopcao == 'C') {
        formataOpcaoC();

        $('#' + frmOpcao + ' fieldset:eq(1)').css({'display': 'none'});
        cNrdconta.habilitaCampo().focus();

    } else if (cddopcao == 'D') {
        formataOpcaoD();
        $('#' + frmOpcao + ' fieldset:eq(0)').css({'display': 'block'});
        $('#' + frmOpcao + ' fieldset:eq(1)').css({'display': 'none'});
        $('#btConcluir', '#divTela #divBotoes').css({'display': 'none'});

        cNrdconta.habilitaCampo().focus();

    } else if (cddopcao == 'F') {
        formataOpcaoF();
        $('#' + frmOpcao + ' fieldset:eq(1)').css({'display': 'none'});
        cDtlibera.val(dtmvtopr);
        cNrdconta.habilitaCampo().focus();

    } else if (cddopcao == 'M') {
        formataOpcaoM();

        $('#' + frmOpcao + ' fieldset:eq(0)').css({'display': 'block'});
        $('#' + frmOpcao + ' fieldset:eq(1)').css({'display': 'none'});
        cNrdconta.habilitaCampo().focus();

    } else if (cddopcao == 'P') {
        formataOpcaoP();

        $('#' + frmOpcao + ' fieldset:eq(1)').css({'display': 'none'});
        $('#' + frmOpcao + ' fieldset:eq(2)').css({'display': 'none'});
        $('#' + frmOpcao + ' #complemento').css({'display': 'none'});
        cNmprimtl.desabilitaCampo();
        cNrdconta.focus();

    } else if (cddopcao == 'O') {
        formataOpcaoO();
        cDtiniper.val(dtmvtolt);
        cDtiniper.focus();

    } else if (cddopcao == 'R') {
        formataOpcaoR();
        cDtmvtini.focus();

    } else if (cddopcao == 'T') {
        formataOpcaoT();
        $('#' + frmOpcao + ' fieldset:eq(1)').css({'display': 'none'});
        $('#' + frmOpcao + ' fieldset:eq(2)').css({'display': 'none'});
        cNrdconta.habilitaCampo().focus();

    } else if (cddopcao == 'S') {
        formataOpcaoS();
        cDsdopcao.habilitaCampo().focus();
    }

    controlaPesquisas();
    return false;
}

function controlaOpcao() {

    highlightObjFocus($('#' + frmOpcao));

    formataCabecalho();
    $('#' + frmOpcao).css({'display': 'block'});
    cTodosOpcao = $('input[type="text"], select', '#' + frmOpcao);

    if (cddopcao == 'C') {
        formataOpcaoC();
        trocaBotao('');

    } else if (cddopcao == 'F') {
        formataOpcaoF();
        cDtlibera.habilitaCampo().select();
        trocaBotao('');

    } else if (cddopcao == 'P') {
        formataOpcaoP();
        trocaBotao('');
        cTodosOpcao.desabilitaCampo();

    } else if (cddopcao == 'T') {
        formataOpcaoT();
        trocaBotao('');

    } else if (cddopcao == 'S') {
        formataOpcaoS();
        cDtlibera.habilitaCampo().select();
        trocaBotao('');

    }

    cCddopcao.desabilitaCampo();
    return false;
}


// associado
function formataAssociado() {

    // label
    rNrdconta = $('label[for="nrdconta"]', '#' + frmOpcao);
    rNmprimtl = $('label[for="nmprimtl"]', '#' + frmOpcao);

    rNrdconta.css({'width': '44px'}).addClass('rotulo');
    rNmprimtl.css({'width': '44px'}).addClass('rotulo-linha');

    // input
    cNrdconta = $('#nrdconta', '#' + frmOpcao);
    cNmprimtl = $('#nmprimtl', '#' + frmOpcao);

    cNrdconta.css({'width': '75px'}).addClass('pesquisa conta');
    cNmprimtl.css({'width': '412px'});

    //
    if ($.browser.msie) {
        rNmprimtl.css({'width': '46px'});
    }

    // conta
    cNrdconta.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        var auxconta = normalizaNumero(cNrdconta.val());

        // Se é a tecla TAB ou ENTER, 
        if ((e.keyCode === 9 || e.keyCode === 13 || typeof e.keyCode == 'undefined') && (auxconta === 0 || validaCampo('nrdconta', auxconta))) {
            manterRotina('BIA');
            return false;
        } else if (e.keyCode == 9 || e.keyCode == 13 || typeof e.keyCode == 'undefined') {
            return false;
        }

    });

    return false;
}

function controlaAssociado() {

    cNrdconta.desabilitaCampo();
    hideMsgAguardo();

    if (cddopcao == 'C') {
        cTpcheque.habilitaCampo().focus();
        cDtlibini.habilitaCampo();
        cDtlibfim.habilitaCampo();

    } else if (cddopcao == 'D') {
        manterRotina('VLD');

    } else if (cddopcao == 'F') {
        $('#' + frmOpcao + ' fieldset:eq(1)').css({'display': 'block'});
        cDtlibera.habilitaCampo().select();
        trocaBotao('');

    } else if (cddopcao == 'P') {
        $('#' + frmOpcao + ' fieldset:eq(1)').css({'display': 'block'});
        cCdbanchq.habilitaCampo().select();

    } else if (cddopcao == 'M') {
        cDtlibini.habilitaCampo().select();
        cDtlibfim.habilitaCampo();

    } else if (cddopcao == 'T') {
        $('#' + frmOpcao + ' fieldset:eq(1)').css({'display': 'block'});
        cCdbanchq.habilitaCampo().select();
        cNrcheque.habilitaCampo();
        cVlcheque.habilitaCampo();

    } else if (cddopcao == 'S') {
        cNrdconta.desabilitaCampo();
        cDtlibera.habilitaCampo().select();
        cDtlibera.val(dtmvtolt);
        trocaBotao('');
    }

    controlaPesquisas();
    return false;
}


// diretorio
function formataDiretorio() {

    highlightObjFocus($('#frmDiretorio'));

    rNmdireto = $('label[for="nmdireto"]', '#frmDiretorio');
    cNmdireto = $('#nmdireto', '#frmDiretorio');

    rNmdireto.addClass('rotulo').css({'width': '210px'});
    cNmdireto.addClass('campo').css({'width': '200px'}).attr('maxlength', '29');

    cNmdireto.focus();

    // centraliza a divUsoGenerico
    $('#divRotina').css({'width': '525px'});
    $('#divConteudo').css({'width': '500px', 'height': '75px'});
    $('#divRotina').centralizaRotinaH();

    $('fieldset', '#frmDiretorio').css({'padding': '3px'});


    // conta
    $('#btContinuar', '#divRotina').unbind('click').bind('click', function() {
        if (divError.css('display') == 'block') {
            return false;
        }

        if (cNmdireto.val() == '') {
            showError('error', 'Arquivo nao informado !!', 'Alerta - Ayllos', 'bloqueiaFundo( $(\'#divRotina\') ); cNmdireto.focus();');
        } else {
            manterRotina('GLC');
        }

    });


    cNmdireto.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }
        // Se ENTER
        if (e.keyCode == 13) {
            $('#btContinuar', '#divRotina').click();
            return false;
        }
    });


    layoutPadrao();
    hideMsgAguardo();
    bloqueiaFundo($('#divRotina'));
    return false;
}

function buscaDiretorio() {

    var mensagem = 'Aguarde, buscando dados ...';
    var nmdireto = $('#nmdireto', '#' + frmOpcao).val();

    showMsgAguardo(mensagem);

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/custod/form_diretorio.php',
        data: {
            nmdireto: nmdireto,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "fechaRotina( $(\'#divRotina\') );");
        },
        success: function(response) {

            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divRotina').html(response);
                    exibeRotina($('#divRotina'));
                    formataDiretorio();
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'fechaRotina( $(\'#divRotina\') );');
                }
            } else {
                try {
                    eval(response);
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'fechaRotina( $(\'#divRotina\') );');
                }
            }



        }
    });
    return false;
}


// cabecalho
function formataCabecalho() {

    // Label
    rCddopcao = $('label[for="cddopcao"]', '#' + frmCab);
    rCddopcao.css({'width': '50px'}).addClass('rotulo');

    // Input
    cCddopcao = $('#cddopcao', '#' + frmCab);
    cCddopcao.css({'width': '527px'});

    // Outros	
    cTodosCabecalho = $('input[type="text"], select', '#' + frmCab);
    btnOK1 = $('#btnOk1', '#' + frmCab);

    cTodosCabecalho.habilitaCampo();

    if ($.browser.msie) {
    }

    // Se clicar no botao OK
    btnOK1.unbind('click').bind('click', function() {

        if (divError.css('display') == 'block') {
            return false;
        }
        if (cCddopcao.hasClass('campoTelaSemBorda')) {
            return false;
        }

        trocaBotao('Prosseguir');

        //
        cCddopcao.desabilitaCampo();
        cddopcao = cCddopcao.val();

        //		
        buscaOpcao();

        return false;

    });


    //opcao
    cCddopcao.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }
        // Se ENTER
        if (e.keyCode == 13) {
            btnOK1.click();
            return false;
        }
    });

    layoutPadrao();
    controlaPesquisas();
    return false;
}


// opcao C
function formataOpcaoC() {

    // label
    rNrdconta = $('label[for="nrdconta"]', '#' + frmOpcao);
    rTpcheque = $('label[for="tpcheque"]', '#' + frmOpcao);
    rNmprimtl = $('label[for="nmprimtl"]', '#' + frmOpcao);
    rDtlibini = $('label[for="dtlibini"]', '#' + frmOpcao);
    rDtlibfim = $('label[for="dtlibfim"]', '#' + frmOpcao);

    rNrdconta.css({'width': '44px'}).addClass('rotulo');
    rTpcheque.css({'width': '38px'}).addClass('rotulo-linha');
    rNmprimtl.css({'width': '43px'}).addClass('rotulo');
    rDtlibini.css({'width': '74px'}).addClass('rotulo-linha');
    rDtlibfim.css({'width': '70px'}).addClass('rotulo-linha');

    // input
    cNrdconta = $('#nrdconta', '#' + frmOpcao);
    cTpcheque = $('#tpcheque', '#' + frmOpcao);
    cNmprimtl = $('#nmprimtl', '#' + frmOpcao);
    cDtlibini = $('#dtlibini', '#' + frmOpcao);
    cDtlibfim = $('#dtlibfim', '#' + frmOpcao);

    cNrdconta.css({'width': '75px'}).addClass('pesquisa conta');
    cTpcheque.css({'width': '110px'});
    cNmprimtl.css({'width': '553px'});
    cDtlibini.css({'width': '75px'}).addClass('data');
    cDtlibfim.css({'width': '75px'}).addClass('data');

    //
    if ($.browser.msie) {
        rTpcheque.css({'width': '42px'});
        rDtlibini.css({'width': '77px'});
        rDtlibfim.css({'width': '72px'});
    }

    // Outros	
    cTodosOpcao.desabilitaCampo();

    // tabela
    var divRegistro = $('div.divRegistros', '#' + frmOpcao);
    var tabela = $('table', divRegistro);

    $('#' + frmOpcao).css({'margin-top': '5px'});
    divRegistro.css({'height': '207px', 'padding-bottom': '2px'});

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '63px';
    arrayLargura[1] = '28px';
    arrayLargura[2] = '28px';
    arrayLargura[3] = '79px';
    arrayLargura[4] = '49px';
    arrayLargura[5] = '63px';
    arrayLargura[6] = '63px';
    arrayLargura[7] = '47px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'left';
    arrayAlinha[1] = 'right';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'right';
    arrayAlinha[4] = 'right';
    arrayAlinha[5] = 'right';
    arrayAlinha[6] = 'left';
    arrayAlinha[7] = 'left';
    arrayAlinha[8] = 'left';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

    // conta
    cNrdconta.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        var auxconta = normalizaNumero(cNrdconta.val());

        // Se é a tecla TAB ou ENTER, 
        if ((e.keyCode == 9 || e.keyCode == 13 || typeof e.keyCode == 'undefined') && (auxconta === 0 || validaCampo('nrdconta', auxconta))) {
            manterRotina('BIA');
            return false;
        } else if (e.keyCode == 9 || e.keyCode == 13 || typeof e.keyCode == 'undefined') {
            return false;
        }


    });

    // data final	
    cDtlibfim.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se é a tecla TAB ou ENTER, 
        if ((e.keyCode == 9 || e.keyCode == 13)) {
            btnContinuar()
            return false;
        }

    });

    layoutPadrao();
    controlaPesquisas();
    return false;

}

// opcao D
function formataOpcaoD() {

    // label
    rNrdconta = $('label[for="nrdconta"]', '#' + frmOpcao);
    rNmprimtl = $('label[for="nmprimtl"]', '#' + frmOpcao);
    rDtlibera = $('label[for="dtlibera"]', '#' + frmOpcao);
    rDtmvtolt = $('label[for="dtmvtolt"]', '#' + frmOpcao);
    rCdagenci = $('label[for="cdagenci"]', '#' + frmOpcao);
    rBcocxa12 = $('label[for="bcocxa12"]', '#' + frmOpcao);
    rNrdolote = $('label[for="nrdolote"]', '#' + frmOpcao);

    rNrdconta.css({'width': '44px'}).addClass('rotulo');
    rNmprimtl.css({'width': '44px'}).addClass('rotulo-linha');
    rDtlibera.css({'width': '80px'}).addClass('rotulo-linha');
    rDtmvtolt.css({'width': '44px'}).addClass('rotulo');
    rCdagenci.css({'width': '68px'}).addClass('rotulo-linha');
    rBcocxa12.css({'width': '94px'}).addClass('rotulo-linha');
    rNrdolote.css({'width': '73px'}).addClass('rotulo-linha');

    // input
    cNrdconta = $('#nrdconta', '#' + frmOpcao);
    cNmprimtl = $('#nmprimtl', '#' + frmOpcao);
    cDtlibera = $('#dtlibera', '#' + frmOpcao);
    cDtmvtolt = $('#dtmvtolt', '#' + frmOpcao);
    cCdagenci = $('#cdagenci', '#' + frmOpcao);
    cBcocxa12 = $('#bcocxa12', '#' + frmOpcao);
    cNrdolote = $('#nrdolote', '#' + frmOpcao);

    cNrdconta.css({'width': '75px'}).addClass('pesquisa conta');
    cNmprimtl.css({'width': '250px'});
    cDtlibera.css({'width': '75px'}).addClass('data');
    cDtmvtolt.css({'width': '75px'}).addClass('data');
    cCdagenci.css({'width': '75px'}).addClass('inteiro').attr('maxlength', '3');
    cBcocxa12.css({'width': '75px'});
    cNrdolote.css({'width': '75px'}).addClass('inteiro').attr('maxlength', '6');

    // Outros	
    cTodosOpcao.desabilitaCampo();

    //
    if ($.browser.msie) {
        rNmprimtl.css({'width': '47px'});
        rDtlibera.css({'width': '83px'});
        rCdagenci.css({'width': '71px'});
        rBcocxa12.css({'width': '97px'});
        rNrdolote.css({'width': '75px'});
    }

    // conta
    cNrdconta.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        var auxconta = normalizaNumero(cNrdconta.val());

        // Se é a tecla TAB ou ENTER, 
        if ((e.keyCode == 9 || e.keyCode == 13 || typeof e.keyCode == 'undefined') && (auxconta === 0 || validaCampo('nrdconta', auxconta))) {
            manterRotina('BIA');
            return false;
        } else if (e.keyCode == 9 || e.keyCode == 13 || typeof e.keyCode == 'undefined') {
            return false;
        }

    });

    // liberacao p/
    cDtlibera.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }
        // Se é a tecla TAB ou ENTER, 
        if (e.keyCode == 9 || e.keyCode == 13) {
            btnContinuar();
            return false;
        }

    });

    // data
    cDtmvtolt.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se é a tecla TAB ou ENTER, 
        if (e.keyCode == 9 || e.keyCode == 13) {
            if (!validaData($(this).val())) {
                $(this).val('');
            }
            cCdagenci.focus();
            return false;
        }

    });

    // pac
    cCdagenci.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }
        // Se é a tecla TAB ou ENTER, 
        if (e.keyCode == 9 || e.keyCode == 13) {
            cNrdolote.focus();
            return false;
        }

    });

    // lote
    cNrdolote.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }
        // Se é a tecla TAB ou ENTER, 
        if (e.keyCode == 9 || e.keyCode == 13) {
            btnContinuar();
            return false;
        }

    });

    cBcocxa12.val(bcocxa12);
    layoutPadrao();
    controlaPesquisas();
    return false;

}

// opcao F
function formataOpcaoF() {

    formataAssociado();

    // label
    rDslibera = $('label[for="dslibera"]', '#' + frmOpcao);
    rDscheque = $('label[for="dscheque"]', '#' + frmOpcao);
    rDschqdev = $('label[for="dschqdev"]', '#' + frmOpcao);
    rDschqdsc = $('label[for="dschqdsc"]', '#' + frmOpcao);

    rDschqcop = $('label[for="dschqcop"]', '#' + frmOpcao);
    rDschqban = $('label[for="dschqban"]', '#' + frmOpcao);
    rDsdmenor = $('label[for="dsdmenor"]', '#' + frmOpcao);
    rDsdmaior = $('label[for="dsdmaior"]', '#' + frmOpcao);
    rDscredit = $('label[for="dscredit"]', '#' + frmOpcao);
    rDtlibera = $('label[for="dtlibera"]', '#' + frmOpcao);
    rQtcheque = $('label[for="qtcheque"]', '#' + frmOpcao);
    rQtchqdev = $('label[for="qtchqdev"]', '#' + frmOpcao);
    rQtchqdsc = $('label[for="qtchqdsc"]', '#' + frmOpcao);

    rQtchqcop = $('label[for="qtchqcop"]', '#' + frmOpcao);
    rQtchqban = $('label[for="qtchqban"]', '#' + frmOpcao);
    rQtdmenor = $('label[for="qtdmenor"]', '#' + frmOpcao);
    rQtdmaior = $('label[for="qtdmaior"]', '#' + frmOpcao);
    rQtcredit = $('label[for="qtcredit"]', '#' + frmOpcao);
    rVlcheque = $('label[for="vlcheque"]', '#' + frmOpcao);
    rVlchqdev = $('label[for="vlchqdev"]', '#' + frmOpcao);
    rVlchqdsc = $('label[for="vlchqdsc"]', '#' + frmOpcao);

    rVlchqcop = $('label[for="vlchqcop"]', '#' + frmOpcao);
    rVlchqban = $('label[for="vlchqban"]', '#' + frmOpcao);
    rVlrmenor = $('label[for="vlrmenor"]', '#' + frmOpcao);
    rVlrmaior = $('label[for="vlrmaior"]', '#' + frmOpcao);
    rVlcredit = $('label[for="vlcredit"]', '#' + frmOpcao);
    rLqtdedas = $('label[for="lqtdedas"]', '#' + frmOpcao);
    rLvalores = $('label[for="lvalores"]', '#' + frmOpcao);

    rDslibera.addClass('rotulo').css({'width': '230px'});
    rDscheque.addClass('rotulo').css({'width': '230px'});
    rDschqdev.addClass('rotulo').css({'width': '230px'});
    rDschqdsc.addClass('rotulo').css({'width': '230px'});
    rDschqcop.addClass('rotulo').css({'width': '230px'});
    rDschqban.addClass('rotulo').css({'width': '230px'});
    rDsdmenor.addClass('rotulo').css({'width': '230px'});
    rDsdmaior.addClass('rotulo').css({'width': '230px'});
    rDscredit.addClass('rotulo').css({'width': '230px'});
    rDtlibera.addClass('rotulo-linha').css({'width': '20px'});
    rQtcheque.addClass('rotulo-linha').css({'width': '20px'});
    rQtchqdev.addClass('rotulo-linha').css({'width': '20px'});
    rQtchqdsc.addClass('rotulo-linha').css({'width': '20px'});
    rQtchqcop.addClass('rotulo-linha').css({'width': '20px'});
    rQtchqban.addClass('rotulo-linha').css({'width': '20px'});
    rQtdmenor.addClass('rotulo-linha').css({'width': '20px'});
    rQtdmaior.addClass('rotulo-linha').css({'width': '20px'});
    rQtcredit.addClass('rotulo-linha').css({'width': '20px'});
    rVlcheque.addClass('rotulo-linha').css({'width': '20px'});
    rVlchqdev.addClass('rotulo-linha').css({'width': '20px'});
    rVlchqdsc.addClass('rotulo-linha').css({'width': '20px'});
    rVlchqcop.addClass('rotulo-linha').css({'width': '20px'});
    rVlchqban.addClass('rotulo-linha').css({'width': '20px'});
    rVlrmenor.addClass('rotulo-linha').css({'width': '20px'});
    rVlrmaior.addClass('rotulo-linha').css({'width': '20px'});
    rVlcredit.addClass('rotulo-linha').css({'width': '20px'});

    rLqtdedas.addClass('rotulo').css({'width': '340px'});
    rLvalores.addClass('rotulo-linha').css({'width': '130px'});

    // input
    cDtlibera = $('#dtlibera', '#' + frmOpcao);
    cQtcheque = $('#qtcheque', '#' + frmOpcao);
    cQtchqdev = $('#qtchqdev', '#' + frmOpcao);
    cQtchqdsc = $('#qtchqdsc', '#' + frmOpcao);
    cQtchqcop = $('#qtchqcop', '#' + frmOpcao);
    cQtchqban = $('#qtchqban', '#' + frmOpcao);
    cQtrmenor = $('#qtdmenor', '#' + frmOpcao);
    cQtrmaior = $('#qtdmaior', '#' + frmOpcao);
    cQtcredit = $('#qtcredit', '#' + frmOpcao);
    cVlcheque = $('#vlcheque', '#' + frmOpcao);
    cVlchqdev = $('#vlchqdev', '#' + frmOpcao);
    cVlchqdsc = $('#vlchqdsc', '#' + frmOpcao);
    cVlchqcop = $('#vlchqcop', '#' + frmOpcao);
    cVlchqban = $('#vlchqban', '#' + frmOpcao);
    cVlrmenor = $('#vlrmenor', '#' + frmOpcao);
    cVlrmaior = $('#vlrmaior', '#' + frmOpcao);
    cVlcredit = $('#vlcredit', '#' + frmOpcao);

    cDtlibera.css({'width': '90px'}).addClass('data');
    cQtcheque.css({'width': '120px'}).addClass('inteiro');
    cQtchqdev.css({'width': '120px'}).addClass('inteiro');
    cQtchqdsc.css({'width': '120px'}).addClass('inteiro');
    cQtchqcop.css({'width': '120px'}).addClass('inteiro');
    cQtchqban.css({'width': '120px'}).addClass('inteiro');
    cQtrmenor.css({'width': '120px'}).addClass('inteiro');
    cQtrmaior.css({'width': '120px'}).addClass('inteiro');
    cQtcredit.css({'width': '120px'}).addClass('inteiro');
    cVlcheque.css({'width': '120px'}).addClass('monetario');
    cVlchqdev.css({'width': '120px'}).addClass('monetario');
    cVlchqdsc.css({'width': '120px'}).addClass('monetario');
    cVlchqcop.css({'width': '120px'}).addClass('monetario');
    cVlchqban.css({'width': '120px'}).addClass('monetario');
    cVlrmenor.css({'width': '120px'}).addClass('monetario');
    cVlrmaior.css({'width': '120px'}).addClass('monetario');
    cVlcredit.css({'width': '120px'}).addClass('monetario');

    // Outros	
    btnOK2 = $('#btnOk2', '#' + frmOpcao);
    cTodosOpcao.desabilitaCampo();

    // Se clicar no botao OK
    btnOK2.unbind('click').bind('click', function() {

        if (divError.css('display') == 'block') {
            return false;
        }
        if (cDtlibera.hasClass('campoTelaSemBorda')) {
            return false;
        }

        controlaOperacao('BFD', nriniseq, nrregist);
        return false;

    });

    cDtlibera.unbind('keydown').bind('keydown', function(e) {
        if (e.keyCode == 13) {
            btnOK2.click();
            return false;
        }
    });


    layoutPadrao();
    controlaPesquisas();
    return false;

}

// opcao M
function formataOpcaoM() {

    // label
    rNrdconta = $('label[for="nrdconta"]', '#' + frmOpcao);
    rNmprimtl = $('label[for="nmprimtl"]', '#' + frmOpcao);
    rDtlibini = $('label[for="dtlibini"]', '#' + frmOpcao);
    rDtlibfim = $('label[for="dtlibfim"]', '#' + frmOpcao);

    rNrdconta.css({'width': '44px'}).addClass('rotulo');
    rNmprimtl.css({'width': '44px'}).addClass('rotulo');
    rDtlibini.css({'width': '149px'}).addClass('rotulo-linha');
    rDtlibfim.css({'width': '149px'}).addClass('rotulo-linha');

    // input
    cNrdconta = $('#nrdconta', '#' + frmOpcao);
    cNmprimtl = $('#nmprimtl', '#' + frmOpcao);
    cDtlibini = $('#dtlibini', '#' + frmOpcao);
    cDtlibfim = $('#dtlibfim', '#' + frmOpcao);

    cNrdconta.css({'width': '75px'}).addClass('pesquisa conta');
    cNmprimtl.css({'width': '553px'});
    cDtlibini.css({'width': '75px'}).addClass('data');
    cDtlibfim.css({'width': '75px'}).addClass('data');

    // Outros	
    cTodosOpcao.desabilitaCampo();

    //
    if ($.browser.msie) {
        rDtlibini.css({'width': '152px'});
        rDtlibfim.css({'width': '152px'});
    }

    // conta
    cNrdconta.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        var auxconta = normalizaNumero(cNrdconta.val());

        // Se é a tecla TAB, 
        if ((e.keyCode == 9 || e.keyCode == 13 || typeof e.keyCode == 'undefined') && (auxconta === 0 || validaCampo('nrdconta', auxconta))) {
            manterRotina('BIA');
            return false;
        } else if (e.keyCode == 9 || e.keyCode == 13 || typeof e.keyCode == 'undefined') {
            return false;
        }

    });

    cDtlibfim.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se é a tecla TAB ou ENTER, 
        if (e.keyCode == 9 || e.keyCode == 13) {
            btnContinuar();
            return false;
        }

    });


    layoutPadrao();
    controlaPesquisas();
    return false;

}

// opcao O
function formataOpcaoO() {

    // label
    rDtiniper = $('label[for="dtiniper"]', '#' + frmOpcao);
    rDtfimper = $('label[for="dtfimper"]', '#' + frmOpcao);
    rNrdconta = $('label[for="nrdconta"]', '#' + frmOpcao);
    rCdagenci = $('label[for="cdagenci"]', '#' + frmOpcao);

    rDtiniper.css({'width': '42px'}).addClass('rotulo');
    rDtfimper.css({'width': '20px'}).addClass('rotulo-linha');
    rNrdconta.css({'width': '110px'}).addClass('rotulo-linha');
    rCdagenci.css({'width': '85px'}).addClass('rotulo-linha');

    // input
    cDtiniper = $('#dtiniper', '#' + frmOpcao);
    cDtfimper = $('#dtfimper', '#' + frmOpcao);
    cNrdconta = $('#nrdconta', '#' + frmOpcao);
    cCdagenci = $('#cdagenci', '#' + frmOpcao);

    cDtiniper.css({'width': '75px'}).addClass('data');
    cDtfimper.css({'width': '75px'}).addClass('data');
    cNrdconta.css({'width': '75px'}).addClass('conta pesquisa');
    cCdagenci.css({'width': '75px'}).addClass('inteiro').attr('maxlength', '3');

    // Outros	
    cTodosOpcao.habilitaCampo();

    //	
    if ($.browser.msie) {
        rNrdconta.css({'width': '115px'});
        rCdagenci.css({'width': '90px'});
    }

    // data inicial
    cDtiniper.unbind('blur').bind('blur', function() {
        cDtfimper.val(cDtiniper.val());
    });

    // data inicial
    cDtiniper.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se é a tecla TAB ou ENTER, 
        if (e.keyCode == 9 || e.keyCode == 13) {
            if (!validaData($(this).val())) {
                $(this).val('');
            }
            cDtfimper.focus();
            return false;
        }
    });


    // data final
    cDtfimper.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se é a tecla TAB ou ENTER, 
        if (e.keyCode == 9 || e.keyCode == 13) {
            if (!validaData($(this).val())) {
                $(this).val('');
            }
            cNrdconta.focus();
            return false;
        }
    });

    // conta
    cNrdconta.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        var auxconta = normalizaNumero(cNrdconta.val());

        // Clica no botao prosseguir
        if (typeof e.keyCode == 'undefined' && (auxconta === 0 || validaCampo('nrdconta', auxconta))) {
            Gera_Impressao();

            // Se é a tecla TAB, 	
        } else if ((e.keyCode == 9 || e.keyCode == 13) && (auxconta === 0 || validaCampo('nrdconta', auxconta))) {
            cCdagenci.focus();
            return false;

        } else if (e.keyCode == 9 || e.keyCode == 13 || typeof e.keyCode == 'undefined') {
            return false;
        }

    });

    // agencia
    cCdagenci.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se TAB ou ENTER
        if (e.keyCode == 9 || e.keyCode == 13) {
            btnContinuar();
            return false;
        }
    });

    layoutPadrao();
    controlaPesquisas();
    return false;

}

// opcao P
function formataOpcaoP() {

    formataAssociado();

    // label
    rCdbanchq = $('label[for="cdbanchq"]', '#' + frmOpcao);
    rCdagechq = $('label[for="cdagechq"]', '#' + frmOpcao);
    rNrctachq = $('label[for="nrctachq"]', '#' + frmOpcao);
    rNrcheque = $('label[for="nrcheque"]', '#' + frmOpcao);
    rNrcpfcgc = $('label[for="nrcpfcgc"]', '#' + frmOpcao);
    rNmcheque = $('label[for="nmcheque"]', '#' + frmOpcao);

    rCdbanchq.css({'width': '44px'}).addClass('rotulo');
    rCdagechq.css({'width': '58px'}).addClass('rotulo-linha');
    rNrctachq.css({'width': '47px'}).addClass('rotulo-linha');
    rNrcheque.css({'width': '74px'}).addClass('rotulo-linha');

    // input
    cCdbanchq = $('#cdbanchq', '#' + frmOpcao);
    cCdagechq = $('#cdagechq', '#' + frmOpcao);
    cNrctachq = $('#nrctachq', '#' + frmOpcao);
    cNrcheque = $('#nrcheque', '#' + frmOpcao);

    cCdbanchq.css({'width': '90px'}).addClass('inteiro').attr('maxlength', '3');
    cCdagechq.css({'width': '88px'}).addClass('inteiro').attr('maxlength', '4');
    cNrctachq.css({'width': '90px'}).addClass('inteiro').attr('maxlength', '10');
    cNrcheque.css({'width': '88px'}).addClass('inteiro').attr('maxlength', '6');

    // outros	
    cTodosOpcao.habilitaCampo();

    //
    if ($.browser.msie) {
        rCdagechq.css({'width': '62px'});
        rNrctachq.css({'width': '50px'});
        rNrcheque.css({'width': '76px'});
    }

    //banco
    cCdbanchq.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se TAB ou ENTER
        if (e.keyCode == 9 || e.keyCode == 13) {
            cCdagechq.focus();
            return false;
        }
    });

    //agencia
    cCdagechq.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se TAB ou ENTER
        if (e.keyCode == 9 || e.keyCode == 13) {
            cNrctachq.focus();
            return false;
        }
    });

    //conta
    cNrctachq.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se TAB ou ENTER
        if (e.keyCode == 9 || e.keyCode == 13) {
            cNrcheque.focus();
            return false;
        }
    });

    //nr cheque
    cNrcheque.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se TAB ou ENTER
        if (e.keyCode == 9 || e.keyCode == 13) {
            btnContinuar();
            return false;
        }
    });


    // tabela
    var divRegistro = $('div.divRegistros', '#' + frmOpcao);
    var tabela = $('table', divRegistro);

    $('#' + frmOpcao).css({'margin-top': '5px'});
    divRegistro.css({'height': '50px', 'padding-bottom': '2px'});

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '55px';
    arrayLargura[1] = '40px';
    arrayLargura[2] = '40px';
    arrayLargura[3] = '40px';
    arrayLargura[4] = '80px';
    arrayLargura[5] = '40px';
    arrayLargura[6] = '70px';
    arrayLargura[7] = '40px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'right';
    arrayAlinha[1] = 'right';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'right';
    arrayAlinha[4] = 'right';
    arrayAlinha[5] = 'right';
    arrayAlinha[6] = 'right';
    arrayAlinha[7] = 'right';
    arrayAlinha[8] = 'right';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

    /********************
     FORMATA COMPLEMENTO	
     *********************/
    // complemento linha 1
    var linha1 = $('ul.complemento', '#linha1').css({'margin-left': '1px'});
    $('li:eq(0)', linha1).addClass('txtNormalBold').css({'width': '13%', 'text-align': 'right'});
    $('li:eq(1)', linha1).addClass('txtNormal').css({'width': '45%'});
    $('li:eq(2)', linha1).addClass('txtNormalBold').css({'width': '12%', 'text-align': 'right'});
    $('li:eq(3)', linha1).addClass('txtNormal');

    // complemento linha 2
    var linha2 = $('ul.complemento', '#linha2').css({'clear': 'both', 'border-top': '0'});
    $('li:eq(0)', linha2).addClass('txtNormalBold').css({'width': '13%', 'text-align': 'right'});
    $('li:eq(1)', linha2).addClass('txtNormal').css({'width': '59%'});

    // complemento linha 3
    var linha3 = $('ul.complemento', '#linha3').css({'clear': 'both', 'border-top': '0'});
    $('li:eq(0)', linha3).addClass('txtNormalBold').css({'width': '13%', 'text-align': 'right'});
    $('li:eq(1)', linha3).addClass('txtNormal').css({'width': '30%'});
    $('li:eq(2)', linha3).addClass('txtNormal');

    // complemento linha 4
    var linha4 = $('ul.complemento', '#linha4').css({'clear': 'both', 'border-top': '0'});
    $('li:eq(0)', linha4).addClass('txtNormal').css({'width': '100%'});

    /********************
     EVENTO COMPLEMENTO	
     *********************/
    // seleciona o registro que é clicado
    $('table > tbody > tr', divRegistro).click(function() {
        selecionaOpcaoP($(this));
    });

    // seleciona o registro que é focado
    $('table > tbody > tr', divRegistro).focus(function() {
        selecionaOpcaoP($(this));
    });

    $('table > tbody > tr:eq(0)', divRegistro).click();


    layoutPadrao();
    controlaPesquisas();
    return false;

}

function selecionaOpcaoP(tr) {

    $('#dspesqui', '.complemento').html($('#dspesqui', tr).val());
    $('#dssitchq', '.complemento').html($('#dssitchq', tr).val());
    $('#dsdocmc7', '.complemento').html($('#dsdocmc7', tr).val());
    $('#nrborder', '.complemento').html($('#nrborder', tr).val());
    $('#nrctrlim', '.complemento').html($('#nrctrlim', tr).val());
    $('#dtlibera', '.complemento').html($('#dtlibera', tr).val());
    $('#dsobserv', '.complemento').html($('#dsobserv', tr).val());
    $('#nmopedev', '.complemento').html($('#nmopedev', tr).val());
    return false;
}

// opcao R
function formataOpcaoR() {

    // label
    rDtmvtini = $('label[for="dtmvtini"]', '#' + frmOpcao);
    rDtmvtfim = $('label[for="dtmvtfim"]', '#' + frmOpcao);
    rCdagenci = $('label[for="cdagenci"]', '#' + frmOpcao);
    rFlgrelat = $('label[for="flgrelat"]', '#' + frmOpcao);
    rNmdopcao = $('label[for="nmdopcao"]', '#' + frmOpcao);

    rDtmvtini.css({'width': '85px'}).addClass('rotulo-linha');
    rDtmvtfim.css({'width': '18px'}).addClass('rotulo-linha');
    rCdagenci.css({'width': '35px'}).addClass('rotulo-linha');
    rFlgrelat.css({'width': '66px'}).addClass('rotulo-linha');
    rNmdopcao.css({'width': '40px'}).addClass('rotulo-linha');

    // input
    cDtmvtini = $('#dtmvtini', '#' + frmOpcao);
    cDtmvtfim = $('#dtmvtfim', '#' + frmOpcao);
    cCdagenci = $('#cdagenci', '#' + frmOpcao);
    cFlgrelat = $('#flgrelat', '#' + frmOpcao);
    cNmdopcao = $('#nmdopcao', '#' + frmOpcao);

    cDtmvtini.css({'width': '75px'}).addClass('data');
    cDtmvtfim.css({'width': '75px'}).addClass('data');
    cCdagenci.css({'width': '40px'}).addClass('inteiro').attr('maxlength', '3');
    cFlgrelat.css({'width': '50px'});
    cNmdopcao.css({'width': '87px'});

    // Outros	
    cTodosOpcao.habilitaCampo();

    if ($.browser.msie) {
        rDtmvtini.css({'width': '88px'});
        rCdagenci.css({'width': '38px'});
        rFlgrelat.css({'width': '69px'});
        rNmdopcao.css({'width': '43px'});
    }

    //
    cDtmvtini.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }
        // Se TAB ou ENTER
        if (e.keyCode == 9 || e.keyCode == 13) {
            cDtmvtfim.focus();
            return false;
        }
    });

    //
    cDtmvtfim.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }
        // Se TAB ou ENTER
        if (e.keyCode == 9 || e.keyCode == 13) {
            cCdagenci.focus();
            return false;
        }
    });

    //
    cCdagenci.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }
        // Se TAB ou ENTER
        if (e.keyCode == 9 || e.keyCode == 13) {
            cFlgrelat.focus();
            return false;
        }
    });

    //
    cFlgrelat.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }
        // Se TAB ou ENTER
        if (e.keyCode == 9 || e.keyCode == 13) {
            cNmdopcao.focus();
            return false;
        }
    });

    //
    cNmdopcao.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }
        // Se TAB ou ENTER
        if (e.keyCode == 9 || e.keyCode == 13) {
            btnContinuar();
            return false;
        }
    });


    layoutPadrao();
    controlaPesquisas();
    return false;

}

// opcao S
function formataOpcaoS() {

    // label
    rDsdopcao = $('label[for="dsdopcao"]', '#' + frmOpcao);
    rNrdconta = $('label[for="nrdconta"]', '#' + frmOpcao);
    rDtlibera = $('label[for="dtlibera"]', '#' + frmOpcao);

    rDssldant = $('label[for="dssldant"]', '#' + frmOpcao);
    rDscheque = $('label[for="dscheque"]', '#' + frmOpcao);
    rDslibera = $('label[for="dslibera"]', '#' + frmOpcao);
    rDschqdev = $('label[for="dschqdev"]', '#' + frmOpcao);
    rDschqdsc = $('label[for="dschqdsc"]', '#' + frmOpcao);
    rDscredit = $('label[for="dscredit"]', '#' + frmOpcao);
    rDschqcop = $('label[for="dschqcop"]', '#' + frmOpcao);
    rDschqban = $('label[for="dschqban"]', '#' + frmOpcao);
    rQtsldant = $('label[for="qtsldant"]', '#' + frmOpcao);
    rQtcheque = $('label[for="qtcheque"]', '#' + frmOpcao);
    rQtlibera = $('label[for="qtlibera"]', '#' + frmOpcao);
    rQtchqdev = $('label[for="qtchqdev"]', '#' + frmOpcao);
    rQtchqdsc = $('label[for="qtchqdsc"]', '#' + frmOpcao);
    rQtcredit = $('label[for="qtcredit"]', '#' + frmOpcao);
    rQtchqcop = $('label[for="qtchqcop"]', '#' + frmOpcao);
    rQtchqban = $('label[for="qtchqban"]', '#' + frmOpcao);
    rVlsldant = $('label[for="vlsldant"]', '#' + frmOpcao);
    rVlcheque = $('label[for="vlcheque"]', '#' + frmOpcao);
    rVllibera = $('label[for="vllibera"]', '#' + frmOpcao);
    rVlchqdev = $('label[for="vlchqdev"]', '#' + frmOpcao);
    rVlchqdsc = $('label[for="vlchqdsc"]', '#' + frmOpcao);
    rVlcredit = $('label[for="vlcredit"]', '#' + frmOpcao);
    rVlchqcop = $('label[for="vlchqcop"]', '#' + frmOpcao);
    rVlchqban = $('label[for="vlchqban"]', '#' + frmOpcao);
    rLqtdedas = $('label[for="lqtdedas"]', '#' + frmOpcao);
    rLvalores = $('label[for="lvalores"]', '#' + frmOpcao);

    rDsdopcao.addClass('rotulo').css({'width': '44px'});
    rNrdconta.addClass('rotulo-linha').css({'width': '70px'});
    rDtlibera.addClass('rotulo-linha').css({'width': '136px'});

    rDssldant.addClass('rotulo').css({'width': '230px'});
    rDscheque.addClass('rotulo').css({'width': '230px'});
    rDslibera.addClass('rotulo').css({'width': '230px'});
    rDschqdev.addClass('rotulo').css({'width': '230px'});
    rDschqdsc.addClass('rotulo').css({'width': '230px'});
    rDscredit.addClass('rotulo').css({'width': '230px'});
    rDschqcop.addClass('rotulo').css({'width': '230px'});
    rDschqban.addClass('rotulo').css({'width': '230px'});
    rQtsldant.addClass('rotulo-linha').css({'width': '20px'});
    rQtcheque.addClass('rotulo-linha').css({'width': '20px'});
    rQtlibera.addClass('rotulo-linha').css({'width': '20px'});
    rQtchqdev.addClass('rotulo-linha').css({'width': '20px'});
    rQtchqdsc.addClass('rotulo-linha').css({'width': '20px'});
    rQtcredit.addClass('rotulo-linha').css({'width': '20px'});
    rQtchqcop.addClass('rotulo-linha').css({'width': '20px'});
    rQtchqban.addClass('rotulo-linha').css({'width': '20px'});
    rVlsldant.addClass('rotulo-linha').css({'width': '20px'});
    rVlcheque.addClass('rotulo-linha').css({'width': '20px'});
    rVllibera.addClass('rotulo-linha').css({'width': '20px'});
    rVlchqdev.addClass('rotulo-linha').css({'width': '20px'});
    rVlchqdsc.addClass('rotulo-linha').css({'width': '20px'});
    rVlcredit.addClass('rotulo-linha').css({'width': '20px'});
    rVlchqcop.addClass('rotulo-linha').css({'width': '20px'});
    rVlchqban.addClass('rotulo-linha').css({'width': '20px'});

    rLqtdedas.addClass('rotulo').css({'width': '340px'});
    rLvalores.addClass('rotulo-linha').css({'width': '130px'});

    // input
    cDsdopcao = $('#dsdopcao', '#' + frmOpcao);
    cNrdconta = $('#nrdconta', '#' + frmOpcao);
    cDtlibera = $('#dtlibera', '#' + frmOpcao);

    cQtsldant = $('#qtsldant', '#' + frmOpcao);
    cQtcheque = $('#qtcheque', '#' + frmOpcao);
    cQtlibera = $('#qtlibera', '#' + frmOpcao);
    cQtchqdev = $('#qtchqdev', '#' + frmOpcao);
    cQtchqdsc = $('#qtchqdsc', '#' + frmOpcao);
    cQtcredit = $('#qtcredit', '#' + frmOpcao);
    cQtchqcop = $('#qtchqcop', '#' + frmOpcao);
    cQtchqban = $('#qtchqban', '#' + frmOpcao);
    cVlsldant = $('#vlsldant', '#' + frmOpcao);
    cVlcheque = $('#vlchequx', '#' + frmOpcao);
    cVllibera = $('#vllibera', '#' + frmOpcao);
    cVlchqdev = $('#vlchqdev', '#' + frmOpcao);
    cVlchqdsc = $('#vlchqdsc', '#' + frmOpcao);
    cVlcredit = $('#vlcredit', '#' + frmOpcao);
    cVlchqcop = $('#vlchqcop', '#' + frmOpcao);
    cVlchqban = $('#vlchqban', '#' + frmOpcao);

    cDsdopcao.css({'width': '140px'});
    cNrdconta.css({'width': '75px'}).addClass('conta pesquisa');
    cDtlibera.css({'width': '75px'}).addClass('data');

    cQtsldant.css({'width': '120px'}).addClass('inteiro');
    cQtcheque.css({'width': '120px'}).addClass('inteiro');
    cQtlibera.css({'width': '120px'}).addClass('inteiro');
    cQtchqdev.css({'width': '120px'}).addClass('inteiro');
    cQtchqdsc.css({'width': '120px'}).addClass('inteiro');
    cQtcredit.css({'width': '120px'}).addClass('inteiro');
    cQtchqcop.css({'width': '120px'}).addClass('inteiro');
    cQtchqban.css({'width': '120px'}).addClass('inteiro');
    cVlsldant.css({'width': '120px'}).addClass('monetario');
    cVlcheque.css({'width': '120px'}).addClass('monetario');
    cVllibera.css({'width': '120px'}).addClass('monetario');
    cVlchqdev.css({'width': '120px'}).addClass('monetario');
    cVlchqdsc.css({'width': '120px'}).addClass('monetario');
    cVlcredit.css({'width': '120px'}).addClass('monetario');
    cVlchqcop.css({'width': '120px'}).addClass('monetario');
    cVlchqban.css({'width': '120px'}).addClass('monetario');

    // Outros	
    btnOK3 = $('#btnOk3', '#' + frmOpcao);
    cTodosOpcao.desabilitaCampo();

    // Se clicar no botao OK
    btnOK3.unbind('click').bind('click', function() {

        if (divError.css('display') == 'block') {
            return false;
        }
        if (cDtlibera.hasClass('campoTelaSemBorda')) {
            return false;
        }

        controlaOperacao('SDC', nriniseq, nrregist);
        return false;

    });

    // saldos
    cDsdopcao.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }
        if (cDsdopcao.hasClass('campoTelaSemBorda')) {
            return false;
        }

        if (e.keyCode == 9 || e.keyCode == 13 || typeof e.keyCode == 'undefined') {

            if ($(this).val() == 3) {
                $(this).desabilitaCampo();
                cNrdconta.habilitaCampo().select();
            } else if ($(this).val() > 0) {
                $(this).desabilitaCampo();
                cDtlibera.habilitaCampo().select();
                cDtlibera.val(dtmvtolt);
                trocaBotao('');
            }

            dsdopcao = $(this).val();
            controlaPesquisas();
            return false;
        }

    });

    // conta
    cNrdconta.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }
        if (cNrdconta.hasClass('campoTelaSemBorda')) {
            return false;
        }

        var auxconta = normalizaNumero(cNrdconta.val());

        // Clica no botao prosseguir e Se é a tecla TAB, 	
        if ((e.keyCode === 9 || e.keyCode === 13 || typeof e.keyCode == 'undefined') && validaCampo('nrdconta', auxconta)) {
            $(this).desabilitaCampo();
            manterRotina('BIA');
            return false;
        } else if (e.keyCode == 9 || e.keyCode == 13 || typeof e.keyCode == 'undefined') {
            return false;
        }

    });

    cDtlibera.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }
        // Se TAB ou ENTER
        if (e.keyCode == 13 || e.keyCode == 9) {
            btnOK3.click();
            return false;
        }
    });

    controlaPesquisas();
    layoutPadrao();
    return false;

}

// opcao T
function formataOpcaoT() {

    formataAssociado();

    // label
    rCdbanchq = $('label[for="cdbanchq"]', '#' + frmOpcao);
    rNrcheque = $('label[for="nrcheque"]', '#' + frmOpcao);
    rVlcheque = $('label[for="vlcheque"]', '#' + frmOpcao);

    rCdbanchq.css({'width': '44px'}).addClass('rotulo');
    rNrcheque.css({'width': '146px'}).addClass('rotulo-linha');
    rVlcheque.css({'width': '146px'}).addClass('rotulo-linha');

    // input
    cCdbanchq = $('#cdbanchq', '#' + frmOpcao);
    cNrcheque = $('#nrcheque', '#' + frmOpcao);
    cVlcheque = $('#vlrchequ', '#' + frmOpcao);

    cCdbanchq.css({'width': '75px'}).addClass('inteiro').attr('maxlength', '3');
    cNrcheque.css({'width': '75px'}).addClass('inteiro').attr('maxlength', '6');
    cVlcheque.css({'width': '100px'}).addClass('monetario');

    // Outros	
    cTodosOpcao.desabilitaCampo();

    //
    if ($.browser.msie) {
        rNrcheque.css({'width': '149px'});
        rVlcheque.css({'width': '148px'});
    }

    //
    cCdbanchq.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }
        // Se TAB ou ENTER
        if (e.keyCode == 13 || e.keyCode == 9) {
            cNrcheque.focus();
            return false;
        }
    });

    //
    cNrcheque.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }
        // Se TAB ou ENTER
        if (e.keyCode == 13 || e.keyCode == 9) {
            cVlcheque.focus();
            return false;
        }
    });

    // 
    cVlcheque.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }
        // Se TAB ou ENTER
        if (e.keyCode == 13 || e.keyCode == 9) {
            btnContinuar();
            return false;
        }
    });

    // tabela
    var divRegistro = $('div.divRegistros', '#' + frmOpcao);
    var tabela = $('table', divRegistro);

    $('#' + frmOpcao).css({'margin-top': '5px'});
    divRegistro.css({'height': '200px', 'padding-bottom': '2px'});

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '70px';
    arrayLargura[1] = '160px';
    arrayLargura[2] = '30px';
    arrayLargura[3] = '40px';
    arrayLargura[4] = '65px';
    arrayLargura[5] = '60px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'right';
    arrayAlinha[4] = 'right';
    arrayAlinha[5] = 'right';
    arrayAlinha[6] = 'right';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

    layoutPadrao();
    controlaPesquisas();
    return false;

}


// lote
function mostraLote() {

    var mensagem = 'Aguarde, buscando dados ...';

    showMsgAguardo(mensagem);

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/custod/form_lote.php',
        data: {
            protocolo: protocolo,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "estadoInicial();");
        },
        success: function(response) {

            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divRotina').html(response);
                    exibeRotina($('#divRotina'));
                    formataLote();
                    hideMsgAguardo();
                    bloqueiaFundo($('#divRotina'));
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
                }
            } else {
                try {
                    eval(response);
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
                }
            }

        }
    });
    return false;

}

function formataLote() {

    // tabela
    var divRegistro = $('div.divRegistros', '#frmLote');
    var tabela = $('table', divRegistro);

    $('#frmLote').css({'margin-top': '5px'});
    divRegistro.css({'height': '200px', 'padding-bottom': '2px'});

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '20px';
    arrayLargura[1] = '70px';
    arrayLargura[2] = '70px';
    arrayLargura[3] = '70px';
    arrayLargura[4] = '70px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'right';
    arrayAlinha[4] = 'right';
    arrayAlinha[5] = 'right';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

    // centraliza a divUsoGenerico
    $('#divRotina').css({'width': '500px'});
    $('#divConteudo').css({'width': '475px'});
    $('#divRotina').centralizaRotinaH();

    layoutPadrao();
    controlaPesquisas();
    return false;
}

function removeLote(indice) {

    var mensagem = 'Aguarde, excluindo ...';
    showMsgAguardo(mensagem);

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/custod/remove_lote.php',
        data: {
            indice: indice,
            protocolo: protocolo,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "estadoInicial();");
        },
        success: function(response) {
            try {
                eval(response);
                if (protocolo == '') {
                    estadoInicial();
                } else {
                    mostraLote();
                }
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
            }
        }
    });

    return false;


    return false;
}



function Gera_Impressao(inresgat) {

    $('#cddopcao', '#' + frmOpcao).val(cddopcao);
    $('#inresgat', '#' + frmOpcao).val(inresgat);
    $('#protocolo', '#' + frmOpcao).val(protocolo);

    var action = UrlSite + 'telas/custod/imprimir_dados.php';

    cTodosOpcao.habilitaCampo();

    carregaImpressaoAyllos(frmOpcao, action, "cTodosOpcao.desabilitaCampo();estadoInicial();");

}


//
function validaCampo(campo, valor) {

    // conta
    if (campo == 'nrdconta' && !validaNroConta(valor)) {
        showError('error', 'Dígito errado.', 'Alerta - Ayllos', '$(\'#' + campo + '\',\'#frmOpcao\').select();');
        return false;

        // cpf/cnpj
    } else if (campo == 'nrcpfcgc' && verificaTipoPessoa(valor) == 0) {
        showError('error', 'Dígito errado.', 'Alerta - Ayllos', '$(\'#' + campo + '\',\'#frmOpcao\').select();');
        return false;

    }

    return true;
}


// senha
function mostraSenha() {

    showMsgAguardo('Aguarde, abrindo ...');

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/custod/senha.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground()");
        },
        success: function(response) {
            $('#divUsoGenerico').html(response);
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
        url: UrlSite + 'telas/custod/form_senha.php',
        data: {
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground();");
        },
        success: function(response) {

            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divConteudoSenha').html(response);
                    exibeRotina($('#divUsoGenerico'));
                    formataSenha();
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

function formataSenha() {

    highlightObjFocus($('#frmSenha'));

    rOperador = $('label[for="operauto"]', '#frmSenha');
    rSenha = $('label[for="codsenha"]', '#frmSenha');

    rOperador.addClass('rotulo').css({'width': '135px'});
    rSenha.addClass('rotulo').css({'width': '135px'});

    cOperador = $('#operauto', '#frmSenha');
    cSenha = $('#codsenha', '#frmSenha');

    cOperador.addClass('campo').css({'width': '100px'}).attr('maxlength', '10').focus();
    cSenha.addClass('campo').css({'width': '100px'}).attr('maxlength', '10');



    // centraliza a divRotina
    $('#divUsoGenerico').css({'width': '355px'});
    $('#divConteudoSenha').css({'width': '330px', 'height': '120px'});
    $('#divUsoGenerico').centralizaRotinaH();

    layoutPadrao();
    hideMsgAguardo();
    bloqueiaFundo($('#divUsoGenerico'));
    return false;
}

function validarSenha() {

    hideMsgAguardo();

    // Situacao
    operauto = $('#operauto', '#frmSenha').val();
    var codsenha = $('#codsenha', '#frmSenha').val();

    showMsgAguardo('Aguarde, validando ...');

    $.ajax({
        type: 'POST',
        async: true,
        url: UrlSite + 'telas/custod/valida_senha.php',
        data: {
            operauto: operauto,
            codsenha: codsenha,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
        },
        success: function(response) {
            try {
                eval(response);
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
            }
        }
    });

    return false;

}


// botoes
function btnVoltar() {

    if (cddopcao == 'C' && isHabilitado(cNrdconta)) {
        estadoInicial();

    } else if (cddopcao == 'C' && isHabilitado(cTpcheque)) {
        var auxconta = cNrdconta.val();
        cTodosOpcao.desabilitaCampo().limpaFormulario();
        cNrdconta.habilitaCampo().val(auxconta).select();

    } else if (cddopcao == 'C' && !isHabilitado(cNrdconta) && !isHabilitado(cTpcheque)) {
        $('#' + frmOpcao + ' fieldset:eq(1)').css({'display': 'none'});
        $('#divPesquisaRodape', '#divTela').css({'display': 'none'});
        cTpcheque.habilitaCampo().focus();
        cDtlibini.habilitaCampo();
        cDtlibfim.habilitaCampo();
        trocaBotao('Prosseguir');

    } else if (cddopcao == 'D' && isHabilitado(cDtlibera)) {
        cNrdconta.habilitaCampo().select();
        cNmprimtl.val('');
        cDtlibera.desabilitaCampo().val('');

    } else if (cddopcao == 'F' && isHabilitado(cDtlibera)) {
        $('#' + frmOpcao + ' fieldset:eq(1)').css({'display': 'none'});
        $('input', '#' + frmOpcao + ' fieldset:eq(1)').limpaFormulario();
        cNrdconta.habilitaCampo().select();
        cNmprimtl.val('');
        cDtlibera.desabilitaCampo();
        trocaBotao('Prosseguir');

    } else if (cddopcao == 'M' && isHabilitado(cDtlibini)) {
        cNrdconta.habilitaCampo().select();
        cNmprimtl.val('');
        cDtlibini.desabilitaCampo().val('');
        cDtlibfim.desabilitaCampo().val('');

    } else if (cddopcao == 'P' && isHabilitado(cNrdconta)) {
        estadoInicial();

    } else if (cddopcao == 'P' && isHabilitado(cCdbanchq)) {
        $('#' + frmOpcao + ' fieldset:eq(1)').css({'display': 'none'});
        $('input', '#' + frmOpcao + ' fieldset:eq(1)').limpaFormulario();
        cNrdconta.habilitaCampo().select();
        cNmprimtl.val('');

    } else if (cddopcao == 'P' && !isHabilitado(cNrdconta) && !isHabilitado(cCdbanchq)) {
        $('input', '#' + frmOpcao + ' fieldset:eq(1)').habilitaCampo();
        $('#' + frmOpcao + ' fieldset:eq(2)').css({'display': 'none'});
        $('#complemento', '#' + frmOpcao).css({'display': 'none'});
        cCdbanchq.select();
        trocaBotao('Prosseguir');

    } else if (cddopcao == 'S' && $('#dsdopcao', '#' + frmOpcao).val() == 3 && isHabilitado($('#dtlibera', '#' + frmOpcao))) {
        cNrdconta.habilitaCampo().select();
        cDtlibera.desabilitaCampo();
        trocaBotao('Prosseguir');

    } else if (cddopcao == 'S' && isHabilitado($('#dtlibera', '#' + frmOpcao))) {
        cDsdopcao.habilitaCampo().focus();
        cDtlibera.desabilitaCampo();
        trocaBotao('Prosseguir');

    } else if (cddopcao == 'S' && isHabilitado($('#nrdconta', '#' + frmOpcao))) {
        cDsdopcao.habilitaCampo().focus();
        cNrdconta.desabilitaCampo().val('');
        trocaBotao('Prosseguir');

    } else if (cddopcao == 'D' && isHabilitado($('#dtmvtolt', '#' + frmOpcao))) {
        cTodosOpcao.desabilitaCampo();

        if (protocolo == '') {
            trocaBotao('Prosseguir');
            $('#' + frmOpcao + ' fieldset:eq(1)').css({'display': 'none'});
            cDtlibera.habilitaCampo().select();

        } else {
            mostraLote();
        }

    } else if (cddopcao == 'T' && isHabilitado(cCdbanchq)) {
        $('#' + frmOpcao + ' fieldset:eq(1)').css({'display': 'none'});
        $('input', '#' + frmOpcao + ' fieldset:eq(1)').limpaFormulario();
        cNrdconta.habilitaCampo().select();
        cNmprimtl.val('');
        cCdbanchq.desabilitaCampo();

    } else if (cddopcao == 'T' && !isHabilitado(cNrdconta) && !isHabilitado(cCdbanchq)) {
        $('input', '#' + frmOpcao + ' fieldset:eq(1)').habilitaCampo();
        $('#' + frmOpcao + ' fieldset:eq(2)').css({'display': 'none'});
        cCdbanchq.select();
        trocaBotao('Prosseguir');

    } else {
        estadoInicial();
    }

    controlaPesquisas();
    return false;
}

function msgAtencao() {

    showError('inform', 'ATENCAO! Esta operacao NAO tem volta!', 'Alerta - Ayllos', 'mostraSenha();');
    return false;
}

function btnRemover(i) {
    showConfirmacao('Confirma a exclusao do protocolo?', 'Confirma&ccedil;&atilde;o - Ayllos', 'removeLote(\'' + i + '\');', 'bloqueiaFundo( $(\'#divRotina\') );', 'sim.gif', 'nao.gif');
    return false;
}

function btnContinuar() {

    if (divError.css('display') == 'block') {
        return false;
    }

    if (cddopcao == 'C' && isHabilitado(cNrdconta)) {
        cNrdconta.keydown();

    } else if (cddopcao == 'C' && isHabilitado(cTpcheque)) {
        controlaOperacao('CCC', nriniseq, nrregist);

    } else if (cddopcao == 'D' && isHabilitado(cNrdconta)) {
        cNrdconta.keydown();

    } else if (cddopcao == 'D' && isHabilitado(cDtlibera)) {
        manterRotina('VDD');

    } else if (cddopcao == 'D' && isHabilitado(cDtmvtolt)) {
        manterRotina('VLE');

    } else if (cddopcao == 'F' && isHabilitado(cNrdconta)) {
        cNrdconta.keydown();

    } else if (cddopcao == 'M' && isHabilitado(cNrdconta)) {
        cNrdconta.keydown();

    } else if (cddopcao == 'M' && isHabilitado(cDtlibini)) {
        showConfirmacao('Imprimir os cheques RESGATADOS E DESCONTADOS?', 'Confirma&ccedil;&atilde;o - Ayllos', 'Gera_Impressao(\'yes\');', 'Gera_Impressao(\'no\');', 'sim.gif', 'nao.gif');

    } else if (cddopcao == 'P' && isHabilitado(cNrdconta)) {
        cNrdconta.keydown();

    } else if (cddopcao == 'P' && isHabilitado(cCdbanchq)) {
        controlaOperacao('PCC', nriniseq, nrregist);

    } else if (cddopcao == 'R') {
        if (cNmdopcao.val() == 'yes') {
            buscaDiretorio();
        } else {
            showConfirmacao('Imprimir os cheques RESGATADOS E DESCONTADOS?', 'Confirma&ccedil;&atilde;o - Ayllos', 'Gera_Impressao();', '', 'sim.gif', 'nao.gif');
        }

    } else if (cddopcao == 'O') {
        cNrdconta.keydown();

    } else if (cddopcao == 'T' && isHabilitado(cNrdconta)) {
        cNrdconta.keydown();

    } else if (cddopcao == 'T' && isHabilitado(cCdbanchq)) {
        controlaOperacao('TLC', nriniseq, nrregist);

    } else if (cddopcao == 'S' && isHabilitado(cDsdopcao)) {
        cDsdopcao.keydown();

    } else if (cddopcao == 'S' && isHabilitado(cNrdconta)) {
        cNrdconta.keydown();

    } else if (cddopcao == 'S' && isHabilitado(cDtlibera)) {
        controlaOperacao('SDC', nriniseq, nrregist);

    }

    controlaPesquisas();
    return false;
}

function trocaBotao(botao) {

    $('#divBotoes', '#divTela').html('');
    $('#divBotoes', '#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>');

    if (botao != '') {
        $('#divBotoes', '#divTela').append('&nbsp;<a href="#" class="botao" onclick="btnContinuar(); return false;" >' + botao + '</a>');
    }

    $('#divBotoes', '#divTela').append('&nbsp;&nbsp;<a href="#" class="botao" id="btConcluir" onclick="mostraLote(); return false;" style="display:none" >Concluir</a>');

    return false;
}

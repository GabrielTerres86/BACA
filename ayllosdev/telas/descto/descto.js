/*!
 * FONTE        : descto.js
 * CRIA��O      : Rogerius Milit�o (DB1) 
 * DATA CRIA��O : 18/01/2012
 * OBJETIVO     : Biblioteca de fun��es da tela DESCTO
 * --------------
 * ALTERA��ES   :
 * --------------
 * [29/03/2012] Rog�rius Milit�o   (DB1) : Ajuste no layout padr�o
 * [29/06/2012] Jorge Hamaguchi (CECRED) : AJuste para novo esquema de impressao em funcao Gera_Impressao()
 * [21/09/2016] Jaison (CECRED)          : Projeto 300 - Inclusao das opcoes L e N.
 */

//Formul�rios e Tabela
var frmCab = 'frmCab';
var frmOpcao = 'frmOpcao';

var cddopcao = 'C';

var nrJanelas = 0;
var nriniseq = 1;
var nrregist = 50;

var cNrdconta, cNmprimtl, cNrcpfcgc, cDtlibini, cDtlibfim, cDtlibera, cNrborder,
        cCdcmpchq, cCdbanchq, cCdagechq, cNrctachq, cNrcheque, cVlcheque, cNmcheque, cAuxnrcpf, cAuxnmchq, cTodosOpcao;

$(document).ready(function() {
    estadoInicial();
});

// inicio
function estadoInicial() {

    $('#divTela').fadeTo(0, 0.1);

    // retira as mensagens	
    hideMsgAguardo();

    // formulario	
    formataCabecalho();
    cTodosCabecalho.limpaFormulario().removeClass('campoErro');

    $('#' + frmOpcao).remove();
    $('#divBotoes').remove();
    $('#divPesquisaRodape', '#divTela').remove();

    cCddopcao.val('C');
    cCddopcao.focus();

    removeOpacidade('divTela');
}


// controla
function controlaOperacao(operacao, nriniseq, nrregist) {

    var nrdconta = normalizaNumero($('#nrdconta', '#' + frmOpcao).val());
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

    var mensagem = 'Aguarde, buscando dados ...';
    showMsgAguardo(mensagem);

    cTodosOpcao.removeClass('campoErro');

    // Carrega dados da conta atrav�s de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/descto/principal.php',
        data:
                {
                    operacao: operacao,
                    cddopcao: cddopcao,
                    nrdconta: nrdconta,
                    nrcpfcgc: nrcpfcgc,
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
                    nriniseq: nriniseq,
                    nrregist: nrregist,
                    redirect: 'script_ajax'
                },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss�vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response) {
            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    hideMsgAguardo();
                    $('#divTela').html(response);
                    return false;
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            } else {
                try {
                    hideMsgAguardo();
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
    var mensagem = '';

    switch (operacao) {
        case 'BA':
            mensagem = 'Aguarde, buscando dados ...';
            break;
        case 'VC':
            mensagem = 'Aguarde, validando dados ...';
            break;
        case 'AC':
            mensagem = 'Aguarde, gravando dados ...';
            break;
    }

    cTodosOpcao.removeClass('campoErro');
    showMsgAguardo(mensagem);

    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/descto/manter_rotina.php',
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
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response) {
            try {
                eval(response);
                $("div.consulta_data").show();
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
    var linkConta = $('a[class!="botao"]:eq(0)', '#' + frmOpcao);

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

    // Executa script de confirma��o atrav�s de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/descto/form_opcao_' + cddopcao.toLowerCase() + '.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N�o foi poss�vel concluir a requisi��o.', 'Alerta - Ayllos', "unblockBackground()");
        },
        success: function(response) {
            $('#divTela').html(response);

            formataCabecalho();

            cCddopcao.desabilitaCampo();
            cCddopcao.val(cddopcao);

            // limpa formulario
            cTodosOpcao = $('input[type="text"], select', '#' + frmOpcao);
            cTodosOpcao.limpaFormulario().removeClass('campoErro');
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

    } else if (cddopcao == 'F') {
        formataOpcaoF();

        $('#' + frmOpcao + ' fieldset:eq(1)').css({'display': 'none'});

        cNrdconta.habilitaCampo().focus();

    } else if (cddopcao == 'A') {
        formataOpcaoA();

        cNrcpfcgc.desabilitaCampo();
        cNmcheque.desabilitaCampo();
        cNrdconta.focus();

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
        cDtmvtolt.val(dtmvtolt);
        cDtmvtolt.focus();

    } else if (cddopcao == 'Q') {
        formataOpcaoQ();
        $('#' + frmOpcao + ' fieldset:eq(1)').css({'display': 'none'});
        $('#' + frmOpcao + ' fieldset:eq(2)').css({'display': 'none'});
        cNrdconta.habilitaCampo().focus();

    } else if (cddopcao == 'T') {
        formataOpcaoT();
        $('#' + frmOpcao + ' fieldset:eq(1)').css({'display': 'none'});
        $('#' + frmOpcao + ' fieldset:eq(2)').css({'display': 'none'});
        cNrdconta.habilitaCampo().focus();

    } else if (cddopcao == 'S') {
        formataOpcaoS();
        cDtlibera.val(dtmvtolt);
        cDtlibera.habilitaCampo().focus();
        trocaBotao('');
    } else if (cddopcao == 'L') {
        formataOpcaoL();
        cDtiniper.focus();
    } else if (cddopcao == 'N') {
        formataOpcaoN();
        cDtiniper.focus();
    }

    controlaPesquisas();
    return false;
}

function controlaOpcao() {

    highlightObjFocus($('#' + frmOpcao));

    formataCabecalho();
    $('#' + frmOpcao).css({'display': 'block'});
    cTodosOpcao = $('input[type="text"], select', '#' + frmOpcao);

    if (cddopcao == 'A') {
        formataOpcaoA();

        cTodosOpcao.desabilitaCampo();

        cNrcpfcgc.habilitaCampo().focus();
        cNmcheque.habilitaCampo();

    } else if (cddopcao == 'C') {
        formataOpcaoC();
        trocaBotao('');

    } else if (cddopcao == 'F') {
        formataOpcaoF();
        cDtlibera.habilitaCampo().focus();
        trocaBotao('');

    } else if (cddopcao == 'P') {
        formataOpcaoP();
        trocaBotao('');
        cTodosOpcao.desabilitaCampo();

    } else if (cddopcao == 'Q') {
        formataOpcaoQ();
        trocaBotao('');

    } else if (cddopcao == 'T') {
        formataOpcaoT();
        trocaBotao('');

    } else if (cddopcao == 'S') {
        formataOpcaoS();
        cDtlibera.habilitaCampo().focus();
        trocaBotao('');

    }

    cCddopcao.desabilitaCampo();
    controlaPesquisas();
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
    cNmprimtl.css({'width': '472px'});

    // conta
    cNrdconta.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        var auxconta = normalizaNumero(cNrdconta.val());

        // Se � a tecla TAB ou ENTER, 
        if ((e.keyCode == 9 || e.keyCode == 13 || typeof e.keyCode == 'undefined') && (auxconta === 0 || validaCampo('nrdconta', auxconta))) {
            manterRotina('BA');
            return false;
        } else if (e.keyCode == 9 || e.keyCode == 13 || typeof e.keyCode == 'undefined') {
            return false;
        }


    });

    return false;
}

function controlaAssociado() {

    if (cddopcao == 'C') {
        cDtlibini.habilitaCampo().focus();
        cDtlibfim.habilitaCampo();
        cNrcpfcgc.desabilitaCampo();

    } else if (cddopcao == 'F') {
        $('#' + frmOpcao + ' fieldset:eq(1)').css({'display': 'block'});
        cDtlibera.habilitaCampo().val(dtmvtopr).select();
        trocaBotao('');

    } else if (cddopcao == 'P') {
        $('#' + frmOpcao + ' fieldset:eq(1)').css({'display': 'block'});
        cCdbanchq.habilitaCampo().focus();

    } else if (cddopcao == 'M') {
        if (normalizaNumero(cNrdconta.val()) == 0) {
            $('#' + frmOpcao + ' fieldset:eq(0)').css({'display': 'none'});
            $('#' + frmOpcao + ' fieldset:eq(1)').css({'display': 'block'});
            $('input, select', '#' + frmOpcao + ' fieldset:eq(1)').habilitaCampo();
            cDsdopcao.focus();

        } else {
            showConfirmacao('Imprimir os cheques RESGATADOS?', 'Confirma&ccedil;&atilde;o - Ayllos', 'Gera_Impressao(\'yes\');', 'Gera_Impressao(\'no\');', 'sim.gif', 'nao.gif');
            return false;
        }

    } else if (cddopcao == 'Q') {
        controlaOperacao('QD', nriniseq, nrregist);

    } else if (cddopcao == 'T') {
        $('#' + frmOpcao + ' fieldset:eq(1)').css({'display': 'block'});
        cCdbanchq.habilitaCampo().focus();
        cNrcheque.habilitaCampo();
        cVlcheque.habilitaCampo();
    }

    cNrdconta.desabilitaCampo();
    hideMsgAguardo();
    controlaPesquisas();

    return false;
}


// cabecalho
function formataCabecalho() {

    // Label
    rCddopcao = $('label[for="cddopcao"]', '#' + frmCab);
    rCddopcao.css({'width': '50px'}).addClass('rotulo');

    // Input
    cCddopcao = $('#cddopcao', '#' + frmCab);
    cCddopcao.css({'width': '587px'});

    // Outros	
    cTodosCabecalho = $('input[type="text"], select', '#' + frmCab);
    btnOK1 = $('#btnOk1', '#' + frmCab);
    cTodosCabecalho.habilitaCampo();

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


    // 
    cCddopcao.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se � a tecla ENTER
        if (e.keyCode == 13) {
            btnOK1.click();
            return false;
        }

    });
    layoutPadrao();
    controlaPesquisas();
    return false;
}

// opcao A
function formataOpcaoA() {

    // label
    rNrdconta = $('label[for="nrdconta"]', '#' + frmOpcao);
    rNrborder = $('label[for="nrborder"]', '#' + frmOpcao);
    rCdcmpchq = $('label[for="cdcmpchq"]', '#' + frmOpcao);
    rCdbanchq = $('label[for="cdbanchq"]', '#' + frmOpcao);
    rCdagechq = $('label[for="cdagechq"]', '#' + frmOpcao);
    rNrctachq = $('label[for="nrctachq"]', '#' + frmOpcao);
    rNrcheque = $('label[for="nrcheque"]', '#' + frmOpcao);
    rNrcpfcgc = $('label[for="nrcpfcgc"]', '#' + frmOpcao);
    rNmcheque = $('label[for="nmcheque"]', '#' + frmOpcao);

    rNrdconta.css({'width': '60px'}).addClass('rotulo');
    rNrborder.css({'width': '60px'}).addClass('rotulo');
    rCdcmpchq.css({'width': '113px'}).addClass('rotulo-linha');
    rCdbanchq.css({'width': '145px'}).addClass('rotulo-linha');
    rCdagechq.css({'width': '60px'}).addClass('rotulo');
    rNrctachq.css({'width': '113px'}).addClass('rotulo-linha');
    rNrcheque.css({'width': '145px'}).addClass('rotulo-linha');
    rNrcpfcgc.css({'width': '60px'}).addClass('rotulo');
    rNmcheque.css({'width': '113px'}).addClass('rotulo-linha');

    // input
    cNrdconta = $('#nrdconta', '#' + frmOpcao);
    cNrborder = $('#nrborder', '#' + frmOpcao);
    cCdcmpchq = $('#cdcmpchq', '#' + frmOpcao);
    cCdbanchq = $('#cdbanchq', '#' + frmOpcao);
    cCdagechq = $('#cdagechq', '#' + frmOpcao);
    cNrctachq = $('#nrctachq', '#' + frmOpcao);
    cNrcheque = $('#nrcheque', '#' + frmOpcao);
    cNrcpfcgc = $('#nrcpfcgc', '#' + frmOpcao);
    cNmcheque = $('#nmcheque', '#' + frmOpcao);
    cAuxnrcpf = $('#auxnrcpf', '#' + frmOpcao);
    cAuxnmchq = $('#auxnmchq', '#' + frmOpcao);

    cNrdconta.css({'width': '100px'}).addClass('pesquisa conta');
    cNrborder.css({'width': '100px'}).addClass('inteiro').attr('maxlength', '7');
    cCdcmpchq.css({'width': '112px'}).addClass('inteiro').attr('maxlength', '4');
    cCdbanchq.css({'width': '112px'}).addClass('inteiro').attr('maxlength', '3');
    cCdagechq.css({'width': '100px'}).addClass('inteiro').attr('maxlength', '4');
    cNrctachq.css({'width': '112px'}).addClass('inteiro').attr('maxlength', '10');
    cNrcheque.css({'width': '112px'}).addClass('inteiro').attr('maxlength', '6');
    cNrcpfcgc.css({'width': '100px'}).addClass('inteiro').attr('maxlength', '14');
    cNmcheque.css({'width': '375px'}).addClass('alphanumeric');

    // Outros	
    cTodosOpcao.habilitaCampo();


    // conta
    cNrdconta.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        var auxconta = normalizaNumero(cNrdconta.val());

        // Clica no botao prosseguir
        if (typeof e.keyCode == 'undefined' && validaCampo('nrdconta', auxconta)) {
            controlaOperacao('BC', nriniseq, nrregist);

            // Se � a tecla TAB, 	
        } else if ((e.keyCode == 9 || e.keyCode == 13) && validaCampo('nrdconta', auxconta)) {
            cNrborder.focus();
            return false;

        } else if (e.keyCode == 9 || e.keyCode == 13 || typeof e.keyCode == 'undefined') {
            return false;
        }


    });

    // bordero
    cNrborder.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se � a tecla TAB ou ENTER
        if (e.keyCode == 9 || e.keyCode == 13) {
            cCdcmpchq.focus();
            return false;
        }

    });

    // comp
    cCdcmpchq.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se � a tecla TAB ou ENTER
        if (e.keyCode == 9 || e.keyCode == 13) {
            cCdbanchq.focus();
            return false;
        }

    });


    // banco
    cCdbanchq.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se � a tecla TAB ou ENTER
        if (e.keyCode == 9 || e.keyCode == 13) {
            cCdagechq.focus();
            return false;
        }

    });

    // agencia
    cCdagechq.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se � a tecla TAB ou ENTER
        if (e.keyCode == 9 || e.keyCode == 13) {
            cNrctachq.focus();
            return false;
        }

    });

    // conta
    cNrctachq.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se � a tecla TAB ou ENTER
        if (e.keyCode == 9 || e.keyCode == 13) {
            cNrcheque.focus();
            return false;
        }

    });

    // n�mero cheque
    cNrcheque.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se � a tecla TAB ou ENTER
        if (e.keyCode == 9 || e.keyCode == 13) {
            btnContinuar();
            return false;
        }

    });

    // cpf/cnpj	
    cNrcpfcgc.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        var auxcpfcg = normalizaNumero(cNrcpfcgc.val());

        // Se � a tecla TAB, 	
        if ((e.keyCode == 9 || e.keyCode == 13) && validaCampo('nrcpfcgc', auxcpfcg)) {
            return true;

        } else if (e.keyCode == 9 || e.keyCode == 13) {
            return false;
        }


    });

    // nome
    cNmcheque.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se � a tecla TAB ou ENTER, 
        if (e.keyCode === 9 || e.keyCode === 13) {
            btnContinuar();
            //manterRotina('VC');
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
    rNrcpfcgc = $('label[for="nrcpfcgc"]', '#' + frmOpcao);
    rNmprimtl = $('label[for="nmprimtl"]', '#' + frmOpcao);
    rDtlibini = $('label[for="dtlibini"]', '#' + frmOpcao);
    rDtlibfim = $('label[for="dtlibfim"]', '#' + frmOpcao);

    rNrdconta.css({'width': '68px'}).addClass('rotulo');
    rNrcpfcgc.css({'width': '84px'}).addClass('rotulo-linha');
    rNmprimtl.css({'width': '68px'}).addClass('rotulo');
    rDtlibini.css({'width': '65px'}).css({'clear': 'both'}).addClass('rotulo-linha');
    rDtlibfim.css({'width': '87px'}).addClass('rotulo-linha');

    // input
    cNrdconta = $('#nrdconta', '#' + frmOpcao);
    cNrcpfcgc = $('#nrcpfcgc', '#' + frmOpcao);
    cNmprimtl = $('#nmprimtl', '#' + frmOpcao);
    cDtlibini = $('#dtlibini', '#' + frmOpcao);
    cDtlibfim = $('#dtlibfim', '#' + frmOpcao);

    cNrdconta.css({'width': '75px'}).addClass('pesquisa conta');
    cNrcpfcgc.css({'width': '95px'}).addClass('inteiro').attr('maxlength', '14');
    cNmprimtl.css({'width': '480px'});
    cDtlibini.css({'width': '75px'}).addClass('data');
    cDtlibfim.css({'width': '75px'}).addClass('data');
   
    if ($.browser.msie) {
        rNrcpfcgc.css({'width': '86px'});
        rDtlibini.css({'width': '91px'});
        rDtlibfim.css({'width': '89px'});
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
    arrayLargura[1] = '30px';
    arrayLargura[2] = '30px';
    arrayLargura[3] = '85px';
    arrayLargura[4] = '50px';
    arrayLargura[5] = '65px';
    arrayLargura[6] = '63px';
    arrayLargura[7] = '12px';
    arrayLargura[8] = '70px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'left';
    arrayAlinha[1] = 'right';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'right';
    arrayAlinha[4] = 'right';
    arrayAlinha[5] = 'right';
    arrayAlinha[6] = 'right';
    arrayAlinha[7] = 'center';
    arrayAlinha[8] = 'right';
    arrayAlinha[9] = 'right';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

    // conta
    cNrdconta.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        var auxconta = normalizaNumero(cNrdconta.val());

        // Se � a tecla TAB ou ENTER, 
        if ((e.keyCode === 9 || e.keyCode === 13 || typeof e.keyCode == 'undefined') && (auxconta === 0 || validaCampo('nrdconta', auxconta))) {

            if (auxconta == 0) {
                cNrdconta.desabilitaCampo();
                cNrcpfcgc.habilitaCampo().focus();

            } else {
                manterRotina('BA');
            }

            return false;

        } else if (e.keyCode == 9 || e.keyCode == 13 || typeof e.keyCode == 'undefined') {
            return false;
        }


    });

    // cpf/cnpj	
    cNrcpfcgc.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        var auxcpfcg = normalizaNumero(cNrcpfcgc.val());

        // Se � a tecla TAB ou ENTER, 
        if ((e.keyCode === 9 || e.keyCode === 13 || typeof e.keyCode == 'undefined') && (auxcpfcg === 0 || validaCampo('nrcpfcgc', auxcpfcg))) {
            manterRotina('BA');
            return false;

        } else if (e.keyCode == 9 || e.keyCode == 13 || typeof e.keyCode == 'undefined') {
            return false;
        }


    });

    // data inicial	
    cDtlibini.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se � a tecla TAB ou ENTER, 
        if ((e.keyCode == 9 || e.keyCode == 13)) {
            cDtlibfim.focus();
            return false;
        }

    });

    // data final	
    cDtlibfim.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se � a tecla TAB ou ENTER, 
        if ((e.keyCode == 9 || e.keyCode == 13)) {
            btnContinuar()
            return false;
        }

    });

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
    rDschqcop = $('label[for="dschqcop"]', '#' + frmOpcao);
    rDschqban = $('label[for="dschqban"]', '#' + frmOpcao);
    rDsdmenor = $('label[for="dsdmenor"]', '#' + frmOpcao);
    rDsdmaior = $('label[for="dsdmaior"]', '#' + frmOpcao);
    rDscredit = $('label[for="dscredit"]', '#' + frmOpcao);
    rDtlibera = $('label[for="dtlibera"]', '#' + frmOpcao);
    rQtcheque = $('label[for="qtcheque"]', '#' + frmOpcao);
    rQtchqdev = $('label[for="qtchqdev"]', '#' + frmOpcao);
    rQtchqcop = $('label[for="qtchqcop"]', '#' + frmOpcao);
    rQtchqban = $('label[for="qtchqban"]', '#' + frmOpcao);
    rQtdmenor = $('label[for="qtdmenor"]', '#' + frmOpcao);
    rQtdmaior = $('label[for="qtdmaior"]', '#' + frmOpcao);
    rQtcredit = $('label[for="qtcredit"]', '#' + frmOpcao);
    rVlcheque = $('label[for="vlcheque"]', '#' + frmOpcao);
    rVlchqdev = $('label[for="vlchqdev"]', '#' + frmOpcao);
    rVlchqcop = $('label[for="vlchqcop"]', '#' + frmOpcao);
    rVlchqban = $('label[for="vlchqban"]', '#' + frmOpcao);
    rVlrmenor = $('label[for="vlrmenor"]', '#' + frmOpcao);
    rVlrmaior = $('label[for="vlrmaior"]', '#' + frmOpcao);
    rVlcredit = $('label[for="vlcredit"]', '#' + frmOpcao);
    rLqtdedas = $('label[for="lqtdedas"]', '#' + frmOpcao);
    rLvalores = $('label[for="lvalores"]', '#' + frmOpcao);


    rDslibera.addClass('rotulo').css({'width': '250px'});
    rDscheque.addClass('rotulo').css({'width': '250px'});
    rDschqdev.addClass('rotulo').css({'width': '250px'});
    rDschqcop.addClass('rotulo').css({'width': '250px'});
    rDschqban.addClass('rotulo').css({'width': '250px'});
    rDsdmenor.addClass('rotulo').css({'width': '250px'});
    rDsdmaior.addClass('rotulo').css({'width': '250px'});
    rDscredit.addClass('rotulo').css({'width': '250px'});
    rDtlibera.addClass('rotulo-linha').css({'width': '20px'});
    rQtcheque.addClass('rotulo-linha').css({'width': '20px'});
    rQtchqdev.addClass('rotulo-linha').css({'width': '20px'});
    rQtchqcop.addClass('rotulo-linha').css({'width': '20px'});
    rQtchqban.addClass('rotulo-linha').css({'width': '20px'});
    rQtdmenor.addClass('rotulo-linha').css({'width': '20px'});
    rQtdmaior.addClass('rotulo-linha').css({'width': '20px'});
    rQtcredit.addClass('rotulo-linha').css({'width': '20px'});
    rVlcheque.addClass('rotulo-linha').css({'width': '20px'});
    rVlchqdev.addClass('rotulo-linha').css({'width': '20px'});
    rVlchqcop.addClass('rotulo-linha').css({'width': '20px'});
    rVlchqban.addClass('rotulo-linha').css({'width': '20px'});
    rVlrmenor.addClass('rotulo-linha').css({'width': '20px'});
    rVlrmaior.addClass('rotulo-linha').css({'width': '20px'});
    rVlcredit.addClass('rotulo-linha').css({'width': '20px'});

    rLqtdedas.addClass('rotulo').css({'width': '360px'});
    rLvalores.addClass('rotulo-linha').css({'width': '130px'});

    // input
    cDtlibera = $('#dtlibera', '#' + frmOpcao);
    cQtcheque = $('#qtcheque', '#' + frmOpcao);
    cQtchqdev = $('#qtchqdev', '#' + frmOpcao);
    cQtchqcop = $('#qtchqcop', '#' + frmOpcao);
    cQtchqban = $('#qtchqban', '#' + frmOpcao);
    cQtrmenor = $('#qtdmenor', '#' + frmOpcao);
    cQtrmaior = $('#qtdmaior', '#' + frmOpcao);
    cQtcredit = $('#qtcredit', '#' + frmOpcao);
    cVlcheque = $('#vlcheque', '#' + frmOpcao);
    cVlchqdev = $('#vlchqdev', '#' + frmOpcao);
    cVlchqcop = $('#vlchqcop', '#' + frmOpcao);
    cVlchqban = $('#vlchqban', '#' + frmOpcao);
    cVlrmenor = $('#vlrmenor', '#' + frmOpcao);
    cVlrmaior = $('#vlrmaior', '#' + frmOpcao);
    cVlcredit = $('#vlcredit', '#' + frmOpcao);

    cDtlibera.css({'width': '90px'}).addClass('data');
    cQtcheque.css({'width': '120px'}).addClass('inteiro');
    cQtchqdev.css({'width': '120px'}).addClass('inteiro');
    cQtchqcop.css({'width': '120px'}).addClass('inteiro');
    cQtchqban.css({'width': '120px'}).addClass('inteiro');
    cQtrmenor.css({'width': '120px'}).addClass('inteiro');
    cQtrmaior.css({'width': '120px'}).addClass('inteiro');
    cQtcredit.css({'width': '120px'}).addClass('inteiro');
    cVlcheque.css({'width': '120px'}).addClass('monetario');
    cVlchqdev.css({'width': '120px'}).addClass('monetario');
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
        controlaOperacao('FD', nriniseq, nrregist);
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
    rCdagechq.css({'width': '78px'}).addClass('rotulo-linha');
    rNrctachq.css({'width': '67px'}).addClass('rotulo-linha');
    rNrcheque.css({'width': '94px'}).addClass('rotulo-linha');

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

    // banco
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

    // agencia
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

    // agencia
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

    // cheque
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
    arrayLargura[0] = '60px';
    arrayLargura[1] = '45px';
    arrayLargura[2] = '45px';
    arrayLargura[3] = '45px';
    arrayLargura[4] = '85px';
    arrayLargura[5] = '45px';
    arrayLargura[6] = '75px';
    arrayLargura[7] = '45px';

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
    $('li:eq(0)', linha1).addClass('txtNormalBold').css({'width': '12%', 'text-align': 'right'});
    $('li:eq(1)', linha1).addClass('txtNormal').css({'width': '45%'});
    $('li:eq(2)', linha1).addClass('txtNormalBold').css({'width': '12%', 'text-align': 'right'});
    $('li:eq(3)', linha1).addClass('txtNormal');

    // complemento linha 2
    var linha2 = $('ul.complemento', '#linha2').css({'clear': 'both', 'border-top': '0'});
    $('li:eq(0)', linha2).addClass('txtNormalBold').css({'width': '12%', 'text-align': 'right'});
    $('li:eq(1)', linha2).addClass('txtNormal').css({'width': '59%'});

    // complemento linha 3
    var linha3 = $('ul.complemento', '#linha3').css({'clear': 'both', 'border-top': '0'});
    $('li:eq(0)', linha3).addClass('txtNormalBold').css({'width': '12%', 'text-align': 'right'});
    $('li:eq(1)', linha3).addClass('txtNormal').css({'width': '45%'});
    $('li:eq(2)', linha3).addClass('txtNormalBold').css({'width': '12%', 'text-align': 'right'});
    $('li:eq(3)', linha3).addClass('txtNormal');

    // complemento linha 4
    var linha4 = $('ul.complemento', '#linha4').css({'clear': 'both', 'border-top': '0'});
    $('li:eq(0)', linha4).addClass('txtNormalBold').css({'width': '12%', 'text-align': 'right'});
    $('li:eq(1)', linha4).addClass('txtNormal').css({'width': '30%'});
    $('li:eq(2)', linha4).addClass('txtNormal');

    // complemento linha 5
    var linha5 = $('ul.complemento', '#linha5').css({'clear': 'both', 'border-top': '0'});
    $('li:eq(0)', linha5).addClass('txtNormal').css({'width': '100%'});

    /********************
     EVENTO COMPLEMENTO	
     *********************/
    // seleciona o registro que � clicado
    $('table > tbody > tr', divRegistro).click(function() {
        selecionaOpcaoP($(this));
    });

    // seleciona o registro que � focado
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

// opcao M
function formataOpcaoM() {

    formataAssociado();

    // label
    rDsdopcao = $('label[for="dsdopcao"]', '#' + frmOpcao);
    rDsdvalor = $('label[for="dsdvalor"]', '#' + frmOpcao);
    rDschqcop = $('label[for="dschqcop"]', '#' + frmOpcao);
    rDtiniper = $('label[for="dtiniper"]', '#' + frmOpcao);
    rDtfimper = $('label[for="dtfimper"]', '#' + frmOpcao);

    rDsdopcao.css({'width': '95px'}).addClass('rotulo');
    rDsdvalor.css({'width': '210px'}).addClass('rotulo-linha');
    rDschqcop.css({'width': '95px'}).addClass('rotulo');
    rDtiniper.css({'width': '210px'}).addClass('rotulo-linha');
    rDtfimper.css({'width': '20px'}).addClass('rotulo-linha');

    // input
    cDsdopcao = $('#dsdopcao', '#' + frmOpcao);
    cDsdvalor = $('#dsdvalor', '#' + frmOpcao);
    cDschqcop = $('#dschqcop', '#' + frmOpcao);
    cDtiniper = $('#dtiniper', '#' + frmOpcao);
    cDtfimper = $('#dtfimper', '#' + frmOpcao);

    cDsdopcao.css({'width': '170px'});
    cDsdvalor.css({'width': '176px'});
    cDschqcop.css({'width': '170px'});
    cDtiniper.css({'width': '75px'}).addClass('data');
    cDtfimper.css({'width': '75px'}).addClass('data');

    // Outros	
    cTodosOpcao.desabilitaCampo();

    cDtfimper.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se � a tecla TAB ou ENTER, 
        if (e.keyCode == 9 || e.keyCode == 13) {
            btnContinuar();
            return false;
        }

    });

    layoutPadrao();
    controlaPesquisas();
    return false;

}

// opcao R
function formataOpcaoR() {

    // label
    rDtmvtolt = $('label[for="dtmvtolt"]', '#' + frmOpcao);
    rCdagenci = $('label[for="cdagenci"]', '#' + frmOpcao);

    rDtmvtolt.css({'width': '130px'}).addClass('rotulo');
    rCdagenci.css({'width': '370px'}).addClass('rotulo-linha');

    // input
    cDtmvtolt = $('#dtmvtolt', '#' + frmOpcao);
    cCdagenci = $('#cdagenci', '#' + frmOpcao);

    cDtmvtolt.css({'width': '75px'}).addClass('data');
    cCdagenci.css({'width': '75px'}).addClass('inteiro').attr('maxlength', '3');

    // Outros	
    cTodosOpcao.habilitaCampo();

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

// opcao O
function formataOpcaoO() {

    // label
    rDtiniper = $('label[for="dtiniper"]', '#' + frmOpcao);
    rDtfimper = $('label[for="dtfimper"]', '#' + frmOpcao);
    rNrdconta = $('label[for="nrdconta"]', '#' + frmOpcao);
    rCdagenci = $('label[for="cdagenci"]', '#' + frmOpcao);

    rDtiniper.css({'width': '42px'}).addClass('rotulo');
    rDtfimper.css({'width': '20px'}).addClass('rotulo-linha');
    rNrdconta.css({'width': '140px'}).addClass('rotulo-linha');
    rCdagenci.css({'width': '115px'}).addClass('rotulo-linha');

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

    // data inicial
    cDtiniper.unbind('blur').bind('blur', function() {
        cDtfimper.val(cDtiniper.val());
    });

    // data inicial
    cDtiniper.unbind('keydown').bind('keydown', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            cDtfimper.focus();
        }
    });

    // data final
    cDtfimper.unbind('keydown').bind('keydown', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            cNrdconta.focus();
        }
    });

    // conta
    cNrdconta.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        var auxconta = normalizaNumero(cNrdconta.val());

        // Clica no botao prosseguir
        if (typeof e.keyCode === 'undefined' && (auxconta === 0 || validaCampo('nrdconta', auxconta))) {
            Gera_Impressao('');

            // Se � a tecla TAB, 	
        } else if ((e.keyCode == 9 || e.keyCode == 13) && (auxconta === 0 || validaCampo('nrdconta', auxconta))) {
            cCdagenci.focus();
            return false;

        } else if (e.keyCode == 9 || e.keyCode == 13 || typeof e.keyCode == 'undefined') {
            return false;
        }


    });

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

// opcao Q
function formataOpcaoQ() {

    formataAssociado();

    // label
    rVldescto = $('label[for="vldescto"]', '#' + frmOpcao);
    rVldescto.css({'width': '558px'}).addClass('rotulo');

    // input
    cVldescto = $('#vldescto', '#' + frmOpcao);
    cVldescto.css({'width': '100px'}).addClass('monetario');

    // Outros	
    cTodosOpcao.desabilitaCampo();

    // tabela
    var divRegistro = $('div.divRegistros', '#' + frmOpcao);
    var tabela = $('table', divRegistro);

    $('#' + frmOpcao).css({'margin-top': '5px'});
    divRegistro.css({'height': '200px', 'padding-bottom': '2px'});

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '75px';
    arrayLargura[1] = '75px';
    arrayLargura[2] = '75px';
    arrayLargura[3] = '220px';
    arrayLargura[4] = '50px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'left';
    arrayAlinha[4] = 'right';
    arrayAlinha[5] = 'right';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

    layoutPadrao();
    controlaPesquisas();
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
    rNrcheque.css({'width': '176px'}).addClass('rotulo-linha');
    rVlcheque.css({'width': '176px'}).addClass('rotulo-linha');

    // input
    cCdbanchq = $('#cdbanchq', '#' + frmOpcao);
    cNrcheque = $('#nrcheque', '#' + frmOpcao);
    cVlcheque = $('#vlrchequ', '#' + frmOpcao);

    cCdbanchq.css({'width': '75px'}).addClass('inteiro').attr('maxlength', '3');
    cNrcheque.css({'width': '75px'}).addClass('inteiro').attr('maxlength', '6');
    cVlcheque.css({'width': '100px'}).addClass('monetario');

    // Outros	
    cTodosOpcao.desabilitaCampo();

    // banco	
    cCdbanchq.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se � a tecla TAB ou ENTER, 
        if ((e.keyCode == 9 || e.keyCode == 13)) {
            cNrcheque.focus();
            return false;
        }

    });

    // cheque	
    cNrcheque.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se � a tecla TAB ou ENTER, 
        if ((e.keyCode == 9 || e.keyCode == 13)) {
            cVlcheque.focus();
            return false;
        }

    });

    // valor	
    cVlcheque.unbind('keydown').bind('keydown', function(e) {
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
    divRegistro.css({'height': '200px', 'padding-bottom': '2px'});

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '75px';
    arrayLargura[1] = '170px';
    arrayLargura[2] = '40px';
    arrayLargura[3] = '50px';
    arrayLargura[4] = '75px';
    arrayLargura[5] = '70px';

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

// opcao S
function formataOpcaoS() {

    // label
    rDsliberx = $('label[for="dsliberx"]', '#' + frmOpcao);
    rDssldant = $('label[for="dssldant"]', '#' + frmOpcao);
    rDscheque = $('label[for="dscheque"]', '#' + frmOpcao);
    rDslibera = $('label[for="dslibera"]', '#' + frmOpcao);
    rDschqdev = $('label[for="dschqdev"]', '#' + frmOpcao);
    rDscredit = $('label[for="dscredit"]', '#' + frmOpcao);
    rDschqcop = $('label[for="dschqcop"]', '#' + frmOpcao);
    rDschqban = $('label[for="dschqban"]', '#' + frmOpcao);
    rDtlibera = $('label[for="dtlibera"]', '#' + frmOpcao);
    rQtsldant = $('label[for="qtsldant"]', '#' + frmOpcao);
    rQtcheque = $('label[for="qtcheque"]', '#' + frmOpcao);
    rQtlibera = $('label[for="qtlibera"]', '#' + frmOpcao);
    rQtchqdev = $('label[for="qtchqdev"]', '#' + frmOpcao);
    rQtcredit = $('label[for="qtcredit"]', '#' + frmOpcao);
    rQtchqcop = $('label[for="qtchqcop"]', '#' + frmOpcao);
    rQtchqban = $('label[for="qtchqban"]', '#' + frmOpcao);
    rVlsldant = $('label[for="vlsldant"]', '#' + frmOpcao);
    rVlcheque = $('label[for="vlcheque"]', '#' + frmOpcao);
    rVllibera = $('label[for="vllibera"]', '#' + frmOpcao);
    rVlchqdev = $('label[for="vlchqdev"]', '#' + frmOpcao);
    rVlcredit = $('label[for="vlcredit"]', '#' + frmOpcao);
    rVlchqcop = $('label[for="vlchqcop"]', '#' + frmOpcao);
    rVlchqban = $('label[for="vlchqban"]', '#' + frmOpcao);
    rLqtdedas = $('label[for="lqtdedas"]', '#' + frmOpcao);
    rLvalores = $('label[for="lvalores"]', '#' + frmOpcao);


    rDsliberx.addClass('rotulo').css({'width': '250px'});
    rDssldant.addClass('rotulo').css({'width': '250px'});
    rDscheque.addClass('rotulo').css({'width': '250px'});
    rDslibera.addClass('rotulo').css({'width': '250px'});
    rDschqdev.addClass('rotulo').css({'width': '250px'});
    rDscredit.addClass('rotulo').css({'width': '250px'});
    rDschqcop.addClass('rotulo').css({'width': '250px'});
    rDschqban.addClass('rotulo').css({'width': '250px'});
    rDtlibera.addClass('rotulo-linha').css({'width': '20px'});
    rQtsldant.addClass('rotulo-linha').css({'width': '20px'});
    rQtcheque.addClass('rotulo-linha').css({'width': '20px'});
    rQtlibera.addClass('rotulo-linha').css({'width': '20px'});
    rQtchqdev.addClass('rotulo-linha').css({'width': '20px'});
    rQtcredit.addClass('rotulo-linha').css({'width': '20px'});
    rQtchqcop.addClass('rotulo-linha').css({'width': '20px'});
    rQtchqban.addClass('rotulo-linha').css({'width': '20px'});
    rVlsldant.addClass('rotulo-linha').css({'width': '20px'});
    rVlcheque.addClass('rotulo-linha').css({'width': '20px'});
    rVllibera.addClass('rotulo-linha').css({'width': '20px'});
    rVlchqdev.addClass('rotulo-linha').css({'width': '20px'});
    rVlcredit.addClass('rotulo-linha').css({'width': '20px'});
    rVlchqcop.addClass('rotulo-linha').css({'width': '20px'});
    rVlchqban.addClass('rotulo-linha').css({'width': '20px'});

    rLqtdedas.addClass('rotulo').css({'width': '350px'});
    rLvalores.addClass('rotulo-linha').css({'width': '130px'});

    // input
    cDtlibera = $('#dtlibera', '#' + frmOpcao);
    cQtsldant = $('#qtsldant', '#' + frmOpcao);
    cQtcheque = $('#qtcheque', '#' + frmOpcao);
    cQtlibera = $('#qtlibera', '#' + frmOpcao);
    cQtchqdev = $('#qtchqdev', '#' + frmOpcao);
    cQtcredit = $('#qtcredit', '#' + frmOpcao);
    cQtchqcop = $('#qtchqcop', '#' + frmOpcao);
    cQtchqban = $('#qtchqban', '#' + frmOpcao);
    cVlsldant = $('#vlsldant', '#' + frmOpcao);
    cVlcheque = $('#vlchequx', '#' + frmOpcao);
    cVllibera = $('#vllibera', '#' + frmOpcao);
    cVlchqdev = $('#vlchqdev', '#' + frmOpcao);
    cVlcredit = $('#vlcredit', '#' + frmOpcao);
    cVlchqcop = $('#vlchqcop', '#' + frmOpcao);
    cVlchqban = $('#vlchqban', '#' + frmOpcao);

    cDtlibera.css({'width': '90px'}).addClass('data');
    cQtsldant.css({'width': '120px'}).addClass('inteiro');
    cQtcheque.css({'width': '120px'}).addClass('inteiro');
    cQtlibera.css({'width': '120px'}).addClass('inteiro');
    cQtchqdev.css({'width': '120px'}).addClass('inteiro');
    cQtcredit.css({'width': '120px'}).addClass('inteiro');
    cQtchqcop.css({'width': '120px'}).addClass('inteiro');
    cQtchqban.css({'width': '120px'}).addClass('inteiro');
    cVlsldant.css({'width': '120px'}).addClass('monetario');
    cVlcheque.css({'width': '120px'}).addClass('monetario');
    cVllibera.css({'width': '120px'}).addClass('monetario');
    cVlchqdev.css({'width': '120px'}).addClass('monetario');
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
        controlaOperacao('SD', nriniseq, nrregist);
        return false;

    });

    cDtlibera.unbind('keydown').bind('keydown', function(e) {
        if (e.keyCode == 13) {
            btnOK3.click();
            return false;
        }
    });


    layoutPadrao();
    controlaPesquisas();
    return false;

}

// opcao L
function formataOpcaoL() {

    // label
    rDtiniper = $('label[for="dtiniper"]', '#' + frmOpcao);
    rDtfimper = $('label[for="dtfimper"]', '#' + frmOpcao);
    rCdagenci = $('label[for="cdagenci"]', '#' + frmOpcao);
    rNrdconta = $('label[for="nrdconta"]', '#' + frmOpcao);
    rNrborder = $('label[for="nrborder"]', '#' + frmOpcao);

    rDtiniper.css({'width': '110px'}).addClass('rotulo');
    rDtfimper.css({'width': '25px'}).addClass('rotulo-linha');
    rCdagenci.css({'width': '25px'}).addClass('rotulo-linha');
    rNrdconta.css({'width': '45px'}).addClass('rotulo-linha');
    rNrborder.css({'width': '55px'}).addClass('rotulo-linha');

    // input
    cDtiniper = $('#dtiniper', '#' + frmOpcao);
    cDtfimper = $('#dtfimper', '#' + frmOpcao);
    cCdagenci = $('#cdagenci', '#' + frmOpcao);
    cNrdconta = $('#nrdconta', '#' + frmOpcao);
    cNrborder = $('#nrborder', '#' + frmOpcao);

    cDtiniper.css({'width': '75px'}).addClass('data');
    cDtfimper.css({'width': '75px'}).addClass('data');
    cCdagenci.css({'width': '75px'}).addClass('inteiro').attr('maxlength', '3');
    cNrdconta.css({'width': '75px'}).addClass('conta');
    cNrborder.css({'width': '75px'}).addClass('inteiro');

    // Outros	
    cTodosOpcao.habilitaCampo();

    // de
    cDtiniper.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se � a tecla TAB ou ENTER, 
        if ((e.keyCode == 9 || e.keyCode == 13)) {
            cDtfimper.focus();
            return false;
        }

    });

    // ate
    cDtfimper.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se � a tecla TAB ou ENTER, 
        if ((e.keyCode == 9 || e.keyCode == 13)) {
            cCdagenci.focus();
            return false;
        }

    });

    // PA
    cCdagenci.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se � a tecla TAB ou ENTER, 
        if ((e.keyCode == 9 || e.keyCode == 13)) {
            cNrdconta.focus();
            return false;
        }

    });

    // conta
    cNrdconta.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se � a tecla TAB ou ENTER, 
        if ((e.keyCode == 9 || e.keyCode == 13)) {
            cNrborder.focus();
            return false;
        }

    });

    // bordero
    cNrborder.unbind('keydown').bind('keydown', function(e) {
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

// opcao N
function formataOpcaoN() {

    // label
    rDtiniper = $('label[for="dtiniper"]', '#' + frmOpcao);
    rDtfimper = $('label[for="dtfimper"]', '#' + frmOpcao);
    rCdagenci = $('label[for="cdagenci"]', '#' + frmOpcao);
    rNrdconta = $('label[for="nrdconta"]', '#' + frmOpcao);
    rNrctrlim = $('label[for="nrctrlim"]', '#' + frmOpcao);

    rDtiniper.css({'width': '110px'}).addClass('rotulo');
    rDtfimper.css({'width': '25px'}).addClass('rotulo-linha');
    rCdagenci.css({'width': '25px'}).addClass('rotulo-linha');
    rNrdconta.css({'width': '45px'}).addClass('rotulo-linha');
    rNrctrlim.css({'width': '55px'}).addClass('rotulo-linha');

    // input
    cDtiniper = $('#dtiniper', '#' + frmOpcao);
    cDtfimper = $('#dtfimper', '#' + frmOpcao);
    cCdagenci = $('#cdagenci', '#' + frmOpcao);
    cNrdconta = $('#nrdconta', '#' + frmOpcao);
    cNrctrlim = $('#nrctrlim', '#' + frmOpcao);

    cDtiniper.css({'width': '75px'}).addClass('data');
    cDtfimper.css({'width': '75px'}).addClass('data');
    cCdagenci.css({'width': '75px'}).addClass('inteiro').attr('maxlength', '3');
    cNrdconta.css({'width': '75px'}).addClass('conta');
    cNrctrlim.css({'width': '75px'}).addClass('inteiro');

    // Outros	
    cTodosOpcao.habilitaCampo();

    // de
    cDtiniper.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se � a tecla TAB ou ENTER, 
        if ((e.keyCode == 9 || e.keyCode == 13)) {
            cDtfimper.focus();
            return false;
        }

    });

    // ate
    cDtfimper.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se � a tecla TAB ou ENTER, 
        if ((e.keyCode == 9 || e.keyCode == 13)) {
            cCdagenci.focus();
            return false;
        }

    });

    // PA
    cCdagenci.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se � a tecla TAB ou ENTER, 
        if ((e.keyCode == 9 || e.keyCode == 13)) {
            cNrdconta.focus();
            return false;
        }

    });

    // conta
    cNrdconta.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se � a tecla TAB ou ENTER, 
        if ((e.keyCode == 9 || e.keyCode == 13)) {
            cNrctrlim.focus();
            return false;
        }

    });

    // contrato
    cNrctrlim.unbind('keydown').bind('keydown', function(e) {
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



function Gera_Impressao(inresgat) {

    $('#cddopcao', '#' + frmOpcao).val(cddopcao);
    $('#inresgat', '#' + frmOpcao).val(inresgat);

    var action = UrlSite + 'telas/descto/imprimir_dados.php';

    cTodosOpcao.habilitaCampo();

    carregaImpressaoAyllos(frmOpcao, action, "cTodosOpcao.desabilitaCampo();estadoInicial();");

}

function validaCampo(campo, valor) {

    // conta
    if (campo == 'nrdconta' && !validaNroConta(valor)) {
        showError('error', 'D�gito errado.', 'Alerta - Ayllos', '$(\'#' + campo + '\',\'#frmOpcao\').select();');
        return false;

        // cpf/cnpj
    } else if (campo == 'nrcpfcgc' && verificaTipoPessoa(valor) == 0) {
        showError('error', 'D�gito errado.', 'Alerta - Ayllos', '$(\'#' + campo + '\',\'#frmOpcao\').select();');
        return false;

    }

    return true;
}


// botoes
function btnVoltar() {

    if (cddopcao == 'A' && isHabilitado(cNrcpfcgc)) {
        cTodosOpcao.habilitaCampo();
        cNrdconta.focus();
        cNrcpfcgc.desabilitaCampo().val('');
        cNmcheque.desabilitaCampo().val('');

    } else if (cddopcao == 'C' && isHabilitado(cNrdconta)) {
        estadoInicial();

    } else if (cddopcao == 'C' && isHabilitado(cNrcpfcgc)) {
        cNrdconta.habilitaCampo().focus();
        cNrcpfcgc.desabilitaCampo().val('');

    } else if (cddopcao == 'C' && isHabilitado(cDtlibini)) {

        if ((normalizaNumero(cNrdconta.val()) == 0 && normalizaNumero(cNrcpfcgc.val()) == 0) || normalizaNumero(cNrcpfcgc.val()) > 0) {
            cNrcpfcgc.habilitaCampo().focus();
            cNrdconta.desabilitaCampo().val('');

        } else {
            cNrdconta.habilitaCampo().focus();
            cNrcpfcgc.desabilitaCampo().val('');
        }

        cDtlibini.desabilitaCampo().val('');
        cDtlibfim.desabilitaCampo().val('');
        cNmprimtl.val('');

    } else if (cddopcao == 'C' && !isHabilitado(cDtlibini)) {
        $('#' + frmOpcao + ' fieldset:eq(1)').css({'display': 'none'});
        $('#divPesquisaRodape', '#divTela').css({'display': 'none'});
        cDtlibini.habilitaCampo().focus();
        cDtlibfim.habilitaCampo();
        trocaBotao('Prosseguir');

    } else if (cddopcao == 'F' && isHabilitado(cDtlibera)) {
        $('#' + frmOpcao + ' fieldset:eq(1)').css({'display': 'none'});
        $('input', '#' + frmOpcao + ' fieldset:eq(1)').limpaFormulario();
        cNrdconta.habilitaCampo().select();
        cNmprimtl.val('');
        cDtlibera.desabilitaCampo();
        trocaBotao('Prosseguir');

    } else if (cddopcao == 'M' && isHabilitado(cDsdopcao)) {
        buscaOpcao();

    } else if (cddopcao == 'P' && isHabilitado(cNrdconta)) {
        estadoInicial();

    } else if (cddopcao == 'P' && isHabilitado(cCdbanchq)) {
        $('#' + frmOpcao + ' fieldset:eq(1)').css({'display': 'none'});
        $('input', '#' + frmOpcao + ' fieldset:eq(1)').limpaFormulario();
        cNrdconta.habilitaCampo().select();
        cNmprimtl.val('');
        cCdbanchq.desabilitaCampo();

    } else if (cddopcao == 'P' && !isHabilitado(cNrdconta) && !isHabilitado(cCdbanchq)) {
        $('input', '#' + frmOpcao + ' fieldset:eq(1)').habilitaCampo();
        $('#' + frmOpcao + ' fieldset:eq(2)').css({'display': 'none'});
        $('#complemento', '#' + frmOpcao).css({'display': 'none'});
        cCdbanchq.select();
        trocaBotao('Prosseguir');

    } else if (cddopcao == 'Q' && !isHabilitado(cNrdconta)) {
        $('#' + frmOpcao + ' fieldset:eq(1)').css({'display': 'none'});
        $('#' + frmOpcao + ' fieldset:eq(2)').css({'display': 'none'});
        cNrdconta.habilitaCampo().select();
        cNmprimtl.val('');
        trocaBotao('Prosseguir');

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

function btnContinuar() {

    if (divError.css('display') == 'block') {
        return false;
    }
    
    var mensagem = 'Aguarde, buscando dados ...';
    showMsgAguardo(mensagem);

    if (cddopcao == 'A' && isHabilitado(cNrdconta)) {
        cNrdconta.keydown();

    } else if (cddopcao == 'A' && isHabilitado(cNrcpfcgc)) {
        manterRotina('VC');

    } else if (cddopcao == 'C' && isHabilitado(cNrdconta)) {
        cNrdconta.keydown();

    } else if (cddopcao == 'C' && isHabilitado(cNrcpfcgc)) {
        cNrcpfcgc.keydown();

    } else if (cddopcao == 'C' && isHabilitado(cDtlibini)) {
        controlaOperacao('CC', nriniseq, nrregist);

    } else if (cddopcao == 'F' && isHabilitado(cNrdconta)) {
        cNrdconta.keydown();

    } else if (cddopcao == 'M' && isHabilitado(cNrdconta)) {
        cNrdconta.keydown();

    } else if (cddopcao == 'M' && isHabilitado($('#dsdopcao', '#' + frmOpcao))) {
        Gera_Impressao('');

    } else if (cddopcao == 'P' && isHabilitado(cNrdconta)) {
        cNrdconta.keydown();

    } else if (cddopcao == 'P' && isHabilitado(cCdbanchq)) {
        controlaOperacao('PC', nriniseq, nrregist);

    } else if (cddopcao == 'R') {
        Gera_Impressao('');

    } else if (cddopcao == 'O') {
        cNrdconta.keydown();

    } else if (cddopcao == 'Q') {
        cNrdconta.keydown();

    } else if (cddopcao == 'T') {
        controlaOperacao('BT', nriniseq, nrregist);

    } else if (cddopcao == 'L') {
        if (cDtiniper.val() == '') {
			hideMsgAguardo();
            showError("error","Per�odo de Digita&ccedil;&atilde;o deve ser informado.","Alerta - Ayllos","cDtiniper.focus()");
        } else if (cDtfimper.val() == '') {
			hideMsgAguardo();
            showError("error","Per�odo de Digita&ccedil;&atilde;o deve ser informado.","Alerta - Ayllos","cDtfimper.focus()");
        } else if (days_between(cDtfimper.val(), cDtiniper.val()) > 60) {
			hideMsgAguardo();
            showError("error","Informe um intervalo de at� 60 dias.","Alerta - Ayllos","cDtfimper.focus()");
        } else {
            Gera_Impressao('');
        }

    } else if (cddopcao == 'N') {
        var dtdehoje = dtmvtolt.split('/');
        var dtdigita = cDtfimper.val().split('/');
        if (cDtiniper.val() == '') {
            showError("error","Per�odo de Digita&ccedil;&atilde;o deve ser informado.","Alerta - Ayllos","cDtiniper.focus()");
        } else if (cDtfimper.val() == '') {
            showError("error","Per�odo de Digita&ccedil;&atilde;o deve ser informado.","Alerta - Ayllos","cDtfimper.focus()");
        } else if (days_between(cDtfimper.val(), cDtiniper.val()) > 30) {
            showError("error","Informe um intervalo de at� 30 dias.","Alerta - Ayllos","cDtfimper.focus()");
        } else if (new Date(dtdigita[2], dtdigita[1] - 1, dtdigita[0]) >= new Date(dtdehoje[2], dtdehoje[1] - 1, dtdehoje[0])) {
            showError("error","Informe uma data inferior ao dia atual.","Alerta - Ayllos","cDtfimper.focus()");
        } else {
            Gera_Impressao('');
        }

    }

    controlaPesquisas();
    //hideMsgAguardo();
    
    return false;
}

function days_between(date1, date2) {

    date1 = new Date(date1.substr(6,4), date1.substr(3,2) - 1, date1.substr(0,2));
    date2 = new Date(date2.substr(6,4), date2.substr(3,2) - 1, date2.substr(0,2));

    // The number of milliseconds in one day
    var ONE_DAY = 1000 * 60 * 60 * 24;

    // Convert both dates to milliseconds
    var date1_ms = date1.getTime();
    var date2_ms = date2.getTime();

    // Calculate the difference in milliseconds
    var difference_ms = Math.abs(date1_ms - date2_ms);

    // Convert back to days and return
    return Math.round(difference_ms/ONE_DAY);

}

function trocaBotao(botao) {

    $('#divBotoes', '#divTela').html('');
    $('#divBotoes', '#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>');

    if (botao != '') {
        $('#divBotoes', '#divTela').append('&nbsp;<a href="#" class="botao" onclick="btnContinuar(); return false;" >' + botao + '</a>');
    }
    return false;
}

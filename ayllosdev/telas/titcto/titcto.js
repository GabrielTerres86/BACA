/*!
 * FONTE        : titcto.js
 * CRIAÇÃO      : Luis Fernando (GFT) 
 * DATA CRIAÇÃO : 07/03/2018
 * OBJETIVO     : Biblioteca de funções da tela TITCTO
 * --------------
 * ALTERAÇÕES   : 09/04/2018 - Ajuste para inclusão de nova opção para imprimir borderos não liberados (Alex Sandro - GFT).
 *
 * --------------
 *
 */

//Formulários e Tabela
var frmCab = 'frmCab';
var frmOpcao = 'frmOpcao';

var cddopcao = 'C';

var nrJanelas = 0;

var cTodosOpcao;
var cTpcobran;
var cFlresgat;
var cNrdconta;
var cNmprimtl;
var cNrcpfcgc;
var cDtvencto;
var cTpdepesq;
var cNrdocmto;
var cVltitulo;
var cDtiniper;

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

    cCddopcao.val('C');
    cCddopcao.focus();

    removeOpacidade('divTela');
}


// controla
function controlaOperacao(operacao) {

    var nrdconta = normalizaNumero($('#nrdconta', '#' + frmOpcao).val());
    var nrcpfcgc = normalizaNumero($('#nrcpfcgc', '#' + frmOpcao).val());
    var nmprimtl = $('#nmprimtl', '#' + frmOpcao).val();
    var tpcobran = $('#tpcobran', '#' + frmOpcao).val();
    var flresgat = $("#flresgat", '#' + frmOpcao).prop("checked")?"S":"";
    var dtvencto = $('#dtvencto', '#' + frmOpcao).val();
    var tpdepesq = $('#tpdepesq', '#' + frmOpcao).val();
    var nrdocmto = normalizaNumero($('#nrdocmto', '#' + frmOpcao).val());
    var vltitulo = normalizaNumero($('#vltitulo', '#' + frmOpcao).val());

    var mensagem = 'Aguarde, buscando dados ...';
    showMsgAguardo(mensagem);

    cTodosOpcao.removeClass('campoErro');

    // Carrega dados da conta através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/titcto/principal.php',
        data:
                {
                    operacao: operacao,
                    cddopcao: cddopcao,
                    nrdconta: nrdconta,
                    nrcpfcgc: nrcpfcgc,
                    nmprimtl: nmprimtl,
                    tpcobran: tpcobran,
                    flresgat: flresgat,
                    dtvencto: dtvencto,
                    tpdepesq: tpdepesq,
                    nrdocmto: nrdocmto,
                    vltitulo: vltitulo,
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
    var mensagem = '';

    switch (operacao) {
        case 'BA':
            mensagem = 'Aguarde, buscando dados ...';
            break;
    }

    cTodosOpcao.removeClass('campoErro');
    showMsgAguardo(mensagem);

    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/titcto/manter_rotina.php',
        data: {
            operacao: operacao,
            cddopcao: cddopcao,
            nrdconta: nrdconta,
            nrcpfcgc: nrcpfcgc,
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
                console.log(error);
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

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/titcto/form_opcao_' + cddopcao.toLowerCase() + '.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', "unblockBackground()");
        },
        success: function(response) {
            $('#divTela').html(response);

            formataCabecalho();

            cCddopcao.desabilitaCampo();
            cCddopcao.val(cddopcao);

            // limpa formulario
            cTodosOpcao = $('input[type="text"],input[type="checkbox"], select', '#' + frmOpcao);
            cTodosOpcao.limpaFormulario().removeClass('campoErro');

            formataOpcao();

            hideMsgAguardo();
            return false;
        }
    });

    return false;

}

function formataOpcao() {

    highlightObjFocus($('#' + frmOpcao));

    if(cddopcao == 'B'){
        formataOpcaoB();
        cDtiniper.focus();
    } else if (cddopcao == 'C') {
        formataOpcaoC();
        $('#' + frmOpcao +' .listar_resgatados').hide();
        $('#' + frmOpcao +' .tipo_cobranca').hide();
        $('#' + frmOpcao + ' fieldset:eq(1)').hide();
        cNrdconta.habilitaCampo().focus();

    } else if (cddopcao == 'F') {
        formataOpcaoF();
        $('#' + frmOpcao +' .tipo_cobranca').hide();
        $('#' + frmOpcao + ' fieldset:eq(1)').hide();
        cNrdconta.habilitaCampo().focus();
    } else if (cddopcao == 'T') {
        formataOpcaoT();
        $('#' + frmOpcao + ' fieldset:eq(1)').hide();
        $('#' + frmOpcao + ' fieldset:eq(2)').hide();
        $('#' + frmOpcao +' .tipo_cobranca').hide();
        cNrdconta.habilitaCampo().focus();

    } else if (cddopcao == 'S') {
        $('#' + frmOpcao +' .saldo_contabil').hide();
        formataOpcaoS();
        cTpcobran.habilitaCampo().focus();

    } else if (cddopcao == 'L') {
        formataOpcaoL();
        cDtvencto.focus();
    } else if (cddopcao == 'Q') {
        formataOpcaoQ();
        $('#' + frmOpcao +' .tipo_cobranca').hide();
        $('#' + frmOpcao + ' fieldset:eq(1)').hide();
        cNrdconta.habilitaCampo().focus();

    }

    controlaPesquisas();
    return false;
}

function controlaOpcao() {

    highlightObjFocus($('#' + frmOpcao));

    formataCabecalho();
    $('#' + frmOpcao).show();
    cTodosOpcao = $('input[type="text"],input[type="checkbox"], select', '#' + frmOpcao);

    if (cddopcao == 'C') {
        formataOpcaoC();
        trocaBotao('Imprimir');

    } else if (cddopcao == 'F') {
        formataOpcaoF();
        cDtvencto.habilitaCampo().focus();
        trocaBotao('');
    } else if (cddopcao == 'T') {
        formataOpcaoT();
        trocaBotao('');
    } else if (cddopcao == 'S') {
        formataOpcaoS();
        cDtvencto.habilitaCampo().focus();
        trocaBotao('');
    } else if (cddopcao == 'Q') {
        formataOpcaoQ();
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
    cNrdconta.unbind('keypress').bind('keypress', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        var auxconta = normalizaNumero(cNrdconta.val());

        // Se é a tecla TAB ou ENTER, 
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
        cNrcpfcgc.desabilitaCampo();
        cFlresgat.habilitaCampo();
        $('#' + frmOpcao +' .listar_resgatados').show();
        $('#' + frmOpcao +' .tipo_cobranca').show();
        cTpcobran.habilitaCampo().focus();
    } else if (cddopcao == 'Q') {
        cNrcpfcgc.desabilitaCampo();
        $('#' + frmOpcao +' .tipo_cobranca').show();
        cTpcobran.habilitaCampo().focus();
    } else if (cddopcao == 'F') {
        $('#' + frmOpcao +' .tipo_cobranca').show();
        cTpcobran.habilitaCampo().focus();
    } else if (cddopcao == 'T') {
        $('#' + frmOpcao + ' fieldset:eq(1)').show();
        cTpdepesq.habilitaCampo().focus();
        cNrdocmto.habilitaCampo();
        cVltitulo.habilitaCampo();
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
    cCddopcao.css({'width': '970px'});

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
    cCddopcao.unbind('keypress').bind('keypress', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se é a tecla ENTER
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
function formataOpcaoB() {
    // label
    rDtiniper = $('label[for="dtiniper"]', '#' + frmOpcao);
    rDtfimper = $('label[for="dtfimper"]', '#' + frmOpcao);
    rCdagenci = $('label[for="cdagenci"]', '#' + frmOpcao);
    rNrdconta = $('label[for="nrdconta"]', '#' + frmOpcao);
    rNrborder = $('label[for="nrborder"]', '#' + frmOpcao);

    rDtiniper.css({'width': '115px'}).addClass('rotulo');
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

        // Se é a tecla TAB ou ENTER, 
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

        // Se é a tecla TAB ou ENTER, 
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

        // Se é a tecla TAB ou ENTER, 
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

        // Se é a tecla TAB ou ENTER, 
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



// opcao C
function formataOpcaoC() {

    // label
    rNrdconta = $('label[for="nrdconta"]', '#' + frmOpcao);
    rNrcpfcgc = $('label[for="nrcpfcgc"]', '#' + frmOpcao);
    rNmprimtl = $('label[for="nmprimtl"]', '#' + frmOpcao);
    rTpcobran = $('label[for="tpcobran"]', '#' + frmOpcao);
    rFlresgat = $('label[for="flresgat"]', '#' + frmOpcao);

    rNrdconta.css({'width': '108px'}).addClass('rotulo');
    rNrcpfcgc.css({'width': '84px'}).addClass('rotulo-linha');
    rNmprimtl.css({'width': '108px'}).addClass('rotulo');
    rTpcobran.css({'width': '108px'}).addClass('rotulo');
    rFlresgat.css({'width': '128px'}).addClass('rotulo-linha');

    // input
    cNrdconta = $('#nrdconta', '#' + frmOpcao);
    cNrcpfcgc = $('#nrcpfcgc', '#' + frmOpcao);
    cNmprimtl = $('#nmprimtl', '#' + frmOpcao);
    cTpcobran = $('#tpcobran', '#' + frmOpcao);
    cFlresgat = $('#flresgat', '#' + frmOpcao);

    cNrdconta.css({'width': '75px'}).addClass('pesquisa conta');
    cNrcpfcgc.css({'width': '95px'}).addClass('inteiro').attr('maxlength', '14');
    cNmprimtl.css({'width': '480px'});
    cTpcobran.css({'width': '145px'});
    cFlresgat.css({'width': '20px','margin-top':'5px','height':'16px'});
   
    if ($.browser.msie) {
        rNrcpfcgc.css({'width': '86px'});
    }

    // Outros   
    cTodosOpcao.desabilitaCampo();

    // tabela
    var divRegistro = $('div.divRegistros', '#' + frmOpcao);
    var tabela = $('table', divRegistro);

    $('#' + frmOpcao).css({'margin-top': '5px'});
    divRegistro.css({'height': '307px', 'padding-bottom': '2px'});

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '68';
    arrayLargura[1] = '68';
    arrayLargura[2] = '68';
    arrayLargura[3] = '75';
    arrayLargura[4] = '40';
    arrayLargura[5] = '70';
    arrayLargura[6] = '80';
    arrayLargura[7] = '80';
    arrayLargura[8] = '80';
    arrayLargura[9] = '100';
    arrayLargura[10] = '';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'left';
    arrayAlinha[1] = 'right';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'right';
    arrayAlinha[4] = 'right';
    arrayAlinha[5] = 'right';
    arrayAlinha[6] = 'right';
    arrayAlinha[7] = 'right';
    arrayAlinha[8] = 'center';
    arrayAlinha[9] = 'left';
    arrayAlinha[10] = 'left';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

    // conta
    cNrdconta.unbind('keypress').bind('keypress', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        var auxconta = normalizaNumero(cNrdconta.val());

        // Se é a tecla TAB ou ENTER, 
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
    cNrcpfcgc.unbind('keypress').bind('keypress', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        var auxcpfcg = normalizaNumero(cNrcpfcgc.val());

        // Se é a tecla TAB ou ENTER, 
        if ((e.keyCode === 9 || e.keyCode === 13 || typeof e.keyCode == 'undefined') && (auxcpfcg === 0 || validaCampo('nrcpfcgc', auxcpfcg))) {
            manterRotina('BA');
            return false;

        } else if (e.keyCode == 9 || e.keyCode == 13 || typeof e.keyCode == 'undefined') {
            return false;
        }


    });

    cTpcobran.unbind('keypress').bind('keypress', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se é a tecla TAB ou ENTER, 
        if ((e.keyCode == 9 || e.keyCode == 13)) {
            cFlresgat.focus();
            return false;
        }
    });

    cFlresgat.unbind('keypress').bind('keypress', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se é a tecla TAB ou ENTER, 
        if ((e.keyCode == 9 || e.keyCode == 13)) {
            cNrdconta.desabilitaCampo();
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
    // label
    rNrdconta = $('label[for="nrdconta"]', '#' + frmOpcao);
    rNrcpfcgc = $('label[for="nrcpfcgc"]', '#' + frmOpcao);
    rNmprimtl = $('label[for="nmprimtl"]', '#' + frmOpcao);
    rTpcobran = $('label[for="tpcobran"]', '#' + frmOpcao);

    // label
    rDtvencto = $('label[for="dtvencto"]', '#' + frmOpcao);

    rDstitulo = $('label[for="dstitulo"]', '#' + frmOpcao);
    rDsderesg = $('label[for="dsderesg"]', '#' + frmOpcao);
    rDsdpagto = $('label[for="dsdpagto"]', '#' + frmOpcao);
    rDscredit = $('label[for="dscredit"]', '#' + frmOpcao);

    rQttitulo = $('label[for="qttitulo"]', '#' + frmOpcao);
    rVltitulo = $('label[for="vltitulo"]', '#' + frmOpcao);
    rQtderesg = $('label[for="qtderesg"]', '#' + frmOpcao);
    rVlderesg = $('label[for="vlderesg"]', '#' + frmOpcao);
    rQtdpagto = $('label[for="qtdpagto"]', '#' + frmOpcao);
    rVldpagto = $('label[for="vldpagto"]', '#' + frmOpcao);
    rQtcredit = $('label[for="qtcredit"]', '#' + frmOpcao);
    rVlcredit = $('label[for="vlcredit"]', '#' + frmOpcao);
    rLqtdedas = $('label[for="lqtdedas"]', '#' + frmOpcao);
    rLvalores = $('label[for="lvalores"]', '#' + frmOpcao);


    rNrdconta.css({'width': '108px'}).addClass('rotulo');
    rNrcpfcgc.css({'width': '84px'}).addClass('rotulo-linha');
    rNmprimtl.css({'width': '108px'}).addClass('rotulo');
    rTpcobran.css({'width': '108px'}).addClass('rotulo');
    rDtvencto.css({'width': '127px'}).addClass('rotulo');


    rDstitulo.addClass('rotulo').css({'width': '250px'});
    rDsderesg.addClass('rotulo').css({'width': '250px'});
    rDsdpagto.addClass('rotulo').css({'width': '250px'});
    rDscredit.addClass('rotulo').css({'width': '250px'});

    rQttitulo.addClass('rotulo-linha').css({'width': '20px'});
    rVltitulo.addClass('rotulo-linha').css({'width': '20px'});
    rQtderesg.addClass('rotulo-linha').css({'width': '20px'});
    rVlderesg.addClass('rotulo-linha').css({'width': '20px'});
    rQtdpagto.addClass('rotulo-linha').css({'width': '20px'});
    rVldpagto.addClass('rotulo-linha').css({'width': '20px'});
    rQtcredit.addClass('rotulo-linha').css({'width': '20px'});
    rVlcredit.addClass('rotulo-linha').css({'width': '20px'});

    rLqtdedas.addClass('rotulo').css({'width': '360px'});
    rLvalores.addClass('rotulo-linha').css({'width': '130px'});

    // input
    cNrdconta = $('#nrdconta', '#' + frmOpcao);
    cNmprimtl = $('#nmprimtl', '#' + frmOpcao);
    cNrcpfcgc = $('#nrcpfcgc', '#' + frmOpcao);
    cTpcobran = $('#tpcobran', '#' + frmOpcao);
    cDtvencto = $('#dtvencto', '#' + frmOpcao);

    cQttitulo = $('#qttitulo', '#' + frmOpcao);
    cVltitulo = $('#vltitulo', '#' + frmOpcao);
    cQtderesg = $('#qtderesg', '#' + frmOpcao);
    cVlderesg = $('#vlderesg', '#' + frmOpcao);
    cQtdpagto = $('#qtdpagto', '#' + frmOpcao);
    cVldpagto = $('#vldpagto', '#' + frmOpcao);
    cQtcredit = $('#qtcredit', '#' + frmOpcao);
    cVlcredit = $('#vlcredit', '#' + frmOpcao);
    cLqtdedas = $('#lqtdedas', '#' + frmOpcao);
    cLvalores = $('#lvalores', '#' + frmOpcao);

    cDtvencto.css({'width': '90px'}).addClass('data');

    cQttitulo.css({'width': '120px'}).addClass('inteiro');
    cVltitulo.css({'width': '120px'}).addClass('monetario');
    cQtderesg.css({'width': '120px'}).addClass('inteiro');
    cVlderesg.css({'width': '120px'}).addClass('monetario');
    cQtdpagto.css({'width': '120px'}).addClass('inteiro');
    cVldpagto.css({'width': '120px'}).addClass('monetario');
    cQtcredit.css({'width': '120px'}).addClass('inteiro');
    cVlcredit.css({'width': '120px'}).addClass('monetario');
    cLqtdedas.css({'width': '120px'}).addClass('inteiro');
    cLvalores.css({'width': '120px'}).addClass('monetario');
    cNrdconta.css({'width': '75px'}).addClass('pesquisa conta');
    cNrcpfcgc.css({'width': '95px'}).addClass('inteiro').attr('maxlength', '14');
    cNmprimtl.css({'width': '472px'});

    // Outros   
    btnOK2 = $('#btnOk2', '#' + frmOpcao);
    cTodosOpcao.desabilitaCampo();

    // Se clicar no botao OK
    btnOK2.unbind('click').bind('click', function() {

        if (divError.css('display') == 'block') {
            return false;
        }
        if (cDtvencto.hasClass('campoTelaSemBorda')) {
            return false;
        }
        controlaOperacao('FD');
        return false;

    });

    cDtvencto.unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            btnOK2.click();
            return false;
        }
    });

    cTpcobran.unbind('keypress').bind('keypress', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se é a tecla TAB ou ENTER, 
        if ((e.keyCode == 9 || e.keyCode == 13)) {
            btnContinuar();
            return false;
        }
    });
    
    // conta
    cNrdconta.unbind('keypress').bind('keypress', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        var auxconta = normalizaNumero(cNrdconta.val());

        // Se é a tecla TAB ou ENTER, 
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
    cNrcpfcgc.unbind('keypress').bind('keypress', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        var auxcpfcg = normalizaNumero(cNrcpfcgc.val());

        // Se é a tecla TAB ou ENTER, 
        if ((e.keyCode === 9 || e.keyCode === 13 || typeof e.keyCode == 'undefined') && (auxcpfcg === 0 || validaCampo('nrcpfcgc', auxcpfcg))) {
            manterRotina('BA');
            return false;

        } else if (e.keyCode == 9 || e.keyCode == 13 || typeof e.keyCode == 'undefined') {
            return false;
        }


    });

    layoutPadrao();
    controlaPesquisas();
    return false;

}

// opcao T
function formataOpcaoT() {
    
    // label
    rNrdconta = $('label[for="nrdconta"]', '#' + frmOpcao);
    rNrcpfcgc = $('label[for="nrcpfcgc"]', '#' + frmOpcao);
    rNmprimtl = $('label[for="nmprimtl"]', '#' + frmOpcao);
    rTpcobran = $('label[for="tpcobran"]', '#' + frmOpcao);
    rTpdepesq = $('label[for="tpdepesq"]', '#' + frmOpcao);
    rNrdocmto = $('label[for="nrdocmto"]', '#' + frmOpcao);
    rVltitulo = $('label[for="vltitulo"]', '#' + frmOpcao);

    rNrdconta.css({'width': '108px'}).addClass('rotulo');
    rNrcpfcgc.css({'width': '84px'}).addClass('rotulo-linha');
    rNmprimtl.css({'width': '108px'}).addClass('rotulo');
    rTpcobran.css({'width': '108px'}).addClass('rotulo');
    rTpdepesq.css({'width': '108px'}).addClass('rotulo');
    rNrdocmto.css({'width': '108px'}).addClass('rotulo-linha');
    rVltitulo.css({'width': '108px'}).addClass('rotulo-linha');
    
    // input
    cNrdconta = $('#nrdconta', '#' + frmOpcao);
    cNrcpfcgc = $('#nrcpfcgc', '#' + frmOpcao);
    cNmprimtl = $('#nmprimtl', '#' + frmOpcao);
    cTpcobran = $('#tpcobran', '#' + frmOpcao);
    cTpdepesq = $('#tpdepesq', '#' + frmOpcao);
    cNrdocmto = $('#nrdocmto', '#' + frmOpcao);
    cVltitulo = $('#vltitulo', '#' + frmOpcao);

    cNrdconta.css({'width': '75px'}).addClass('pesquisa conta');
    cNrcpfcgc.css({'width': '95px'}).addClass('inteiro').attr('maxlength', '14');
    cNmprimtl.css({'width': '480px'});
    cTpcobran.css({'width': '145px'});
    cTpdepesq.css({'width': '75px'});
    cNrdocmto.css({'width': '75px'}).addClass('inteiro').attr('maxlength', '6');
    cVltitulo.css({'width': '100px'}).addClass('monetario');
    
   
    if ($.browser.msie) {
        rNrcpfcgc.css({'width': '86px'});
    }

    // Outros   
    cTodosOpcao.desabilitaCampo();

    // Situacao 
    cTpdepesq.unbind('keypress').bind('keypress', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se é a tecla TAB ou ENTER, 
        if ((e.keyCode == 9 || e.keyCode == 13)) {
            cNrdocmto.focus();
            return false;
        }

    });

    // boleto   
    cNrdocmto.unbind('keypress').bind('keypress', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se é a tecla TAB ou ENTER, 
        if ((e.keyCode == 9 || e.keyCode == 13)) {
            cVltitulo.focus();
            return false;
        }

    });

    // valor    
    cVltitulo.unbind('keypress').bind('keypress', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se TAB ou ENTER
        if (e.keyCode == 9 || e.keyCode == 13) {
            btnContinuar();
            return false;
        }
    });

    cTpcobran.unbind('keypress').bind('keypress', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }
        // Se é a tecla TAB ou ENTER, 
        if ((e.keyCode == 9 || e.keyCode == 13)) {
            btnContinuar();
            return false;
        }
    });

    // conta
    cNrdconta.unbind('keypress').bind('keypress', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }
        var auxconta = normalizaNumero(cNrdconta.val());
        // Se é a tecla TAB ou ENTER, 
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
    cNrcpfcgc.unbind('keypress').bind('keypress', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        var auxcpfcg = normalizaNumero(cNrcpfcgc.val());

        // Se é a tecla TAB ou ENTER, 
        if ((e.keyCode === 9 || e.keyCode === 13 || typeof e.keyCode == 'undefined') && (auxcpfcg === 0 || validaCampo('nrcpfcgc', auxcpfcg))) {
            manterRotina('BA');
            return false;

        } else if (e.keyCode == 9 || e.keyCode == 13 || typeof e.keyCode == 'undefined') {
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
    arrayLargura[0] = '80px';
    arrayLargura[1] = '35px';
    arrayLargura[2] = '60px';
    arrayLargura[3] = '60px';
    arrayLargura[4] = '80px';
    arrayLargura[5] = '45px';
    arrayLargura[6] = '85px';
    arrayLargura[7] = '100px';
    arrayLargura[8] = '70px';
    arrayLargura[9] = '';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'right';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'right';
    arrayAlinha[6] = 'right';
    arrayAlinha[7] = 'center';
    arrayAlinha[8] = 'right';
    arrayAlinha[9] = 'right';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

    layoutPadrao();
    controlaPesquisas();
    return false;

}

// opcao S
function formataOpcaoS() {
    /* CONTABIL */
    //label
    rTpcobran = $('label[for="tpcobran"]', '#' + frmOpcao);
    rDssldant = $('label[for="dssldant"]', '#' + frmOpcao);
    rDstitulo = $('label[for="dstitulo"]', '#' + frmOpcao);
    rDsvencid = $('label[for="dsvencid"]', '#' + frmOpcao);
    rDsderesg = $('label[for="dsderesg"]', '#' + frmOpcao);
    rDscredit = $('label[for="dscredit"]', '#' + frmOpcao);
    rDsvencto = $('label[for="dsvencto"]', '#' + frmOpcao);

    rQtsldant = $('label[for="qtsldant"]', '#' + frmOpcao);
    rQttitulo = $('label[for="qttitulo"]', '#' + frmOpcao);
    rQtvencid = $('label[for="qtvencid"]', '#' + frmOpcao);
    rQtderesg = $('label[for="qtderesg"]', '#' + frmOpcao);
    rQtcredit = $('label[for="qtcredit"]', '#' + frmOpcao);
    rVlsldant = $('label[for="vlsldant"]', '#' + frmOpcao);
    rVltitulo = $('label[for="vltitulo"]', '#' + frmOpcao);
    rVlvencid = $('label[for="vlvencid"]', '#' + frmOpcao);
    rVlderesg = $('label[for="vlderesg"]', '#' + frmOpcao);
    rVlcredit = $('label[for="vlcredit"]', '#' + frmOpcao);

    rLqtdedas = $('label[for="lqtdedas"]', '#' + frmOpcao);
    rLvalores = $('label[for="lvalores"]', '#' + frmOpcao);


    rTpcobran.addClass('rotulo').css({'width': '250px'});

    rDssldant.addClass('rotulo').css({'width': '250px'});
    rDstitulo.addClass('rotulo').css({'width': '250px'});
    rDsvencid.addClass('rotulo').css({'width': '250px'});
    rDsderesg.addClass('rotulo').css({'width': '250px'});
    rDscredit.addClass('rotulo').css({'width': '250px'});
    rDsvencto.addClass('rotulo').css({'width': '250px'});

    rQtsldant.addClass('rotulo-linha').css({'width': '20px'});
    rQttitulo.addClass('rotulo-linha').css({'width': '20px'});
    rQtvencid.addClass('rotulo-linha').css({'width': '20px'});
    rQtderesg.addClass('rotulo-linha').css({'width': '20px'});
    rQtcredit.addClass('rotulo-linha').css({'width': '20px'});
    rVlsldant.addClass('rotulo-linha').css({'width': '20px'});
    rVltitulo.addClass('rotulo-linha').css({'width': '20px'});
    rVlvencid.addClass('rotulo-linha').css({'width': '20px'});
    rVlderesg.addClass('rotulo-linha').css({'width': '20px'});
    rVlcredit.addClass('rotulo-linha').css({'width': '20px'});

    rLqtdedas.addClass('rotulo').css({'width': '350px'});
    rLvalores.addClass('rotulo-linha').css({'width': '130px'});

    // input
    cTpcobran = $('#tpcobran', '#' + frmOpcao);
    cQtsldant = $("#qtsldant", '#' + frmOpcao);
    cQttitulo = $("#qttitulo", '#' + frmOpcao);
    cQtvencid = $("#qtvencid", '#' + frmOpcao);
    cQtderesg = $("#qtderesg", '#' + frmOpcao);
    cQtcredit = $("#qtcredit", '#' + frmOpcao);
    cVlsldant = $("#vlsldant", '#' + frmOpcao);
    cVltitulo = $("#vltitulo", '#' + frmOpcao);
    cVlvencid = $("#vlvencid", '#' + frmOpcao);
    cVlderesg = $("#vlderesg", '#' + frmOpcao);
    cVlcredit = $("#vlcredit", '#' + frmOpcao);
    cDtvencto = $("#dtvencto", '#' + frmOpcao);

    cTpcobran.css({'width': '145px'});

    cQtsldant.css({'width': '120px'}).addClass('inteiro');
    cQttitulo.css({'width': '120px'}).addClass('inteiro');
    cQtvencid.css({'width': '120px'}).addClass('inteiro');
    cQtderesg.css({'width': '120px'}).addClass('inteiro');
    cQtcredit.css({'width': '120px'}).addClass('inteiro');
    cVlsldant.css({'width': '120px'}).addClass('monetario');
    cVltitulo.css({'width': '120px'}).addClass('monetario');
    cVlvencid.css({'width': '120px'}).addClass('monetario');
    cVlderesg.css({'width': '120px'}).addClass('monetario');
    cVlcredit.css({'width': '120px'}).addClass('monetario');
    cDtvencto.css({'width': '90px'}).addClass('data');

    /* CONTABIL RESIDUAL*/
    //label
    rDssldant_residual = $('label[for="dssldant_residual"]', '#' + frmOpcao);
    rDstitulo_residual = $('label[for="dstitulo_residual"]', '#' + frmOpcao);
    rDsvencid_residual = $('label[for="dsvencid_residual"]', '#' + frmOpcao);
    rDsderesg_residual = $('label[for="dsderesg_residual"]', '#' + frmOpcao);
    rDscredit_residual = $('label[for="dscredit_residual"]', '#' + frmOpcao);
    rDsvencto_residual = $('label[for="dsvencto_residual"]', '#' + frmOpcao);

    rQtsldant_residual = $('label[for="qtsldant_residual"]', '#' + frmOpcao);
    rQttitulo_residual = $('label[for="qttitulo_residual"]', '#' + frmOpcao);
    rQtvencid_residual = $('label[for="qtvencid_residual"]', '#' + frmOpcao);
    rQtderesg_residual = $('label[for="qtderesg_residual"]', '#' + frmOpcao);
    rQtcredit_residual = $('label[for="qtcredit_residual"]', '#' + frmOpcao);
    rVlsldant_residual = $('label[for="vlsldant_residual"]', '#' + frmOpcao);
    rVltitulo_residual = $('label[for="vltitulo_residual"]', '#' + frmOpcao);
    rVlvencid_residual = $('label[for="vlvencid_residual"]', '#' + frmOpcao);
    rVlderesg_residual = $('label[for="vlderesg_residual"]', '#' + frmOpcao);
    rVlcredit_residual = $('label[for="vlcredit_residual"]', '#' + frmOpcao);

    rLqtdedas_residual = $('label[for="lqtdedas_residual"]', '#' + frmOpcao);
    rLvalores_residual = $('label[for="lvalores_residual"]', '#' + frmOpcao);



    rDssldant_residual.addClass('rotulo').css({'width': '250px'});
    rDstitulo_residual.addClass('rotulo').css({'width': '250px'});
    rDsvencid_residual.addClass('rotulo').css({'width': '250px'});
    rDsderesg_residual.addClass('rotulo').css({'width': '250px'});
    rDscredit_residual.addClass('rotulo').css({'width': '250px'});
    rDsvencto_residual.addClass('rotulo').css({'width': '250px'});

    rQtsldant_residual.addClass('rotulo-linha').css({'width': '20px'});
    rQttitulo_residual.addClass('rotulo-linha').css({'width': '20px'});
    rQtvencid_residual.addClass('rotulo-linha').css({'width': '20px'});
    rQtderesg_residual.addClass('rotulo-linha').css({'width': '20px'});
    rQtcredit_residual.addClass('rotulo-linha').css({'width': '20px'});
    rVlsldant_residual.addClass('rotulo-linha').css({'width': '20px'});
    rVltitulo_residual.addClass('rotulo-linha').css({'width': '20px'});
    rVlvencid_residual.addClass('rotulo-linha').css({'width': '20px'});
    rVlderesg_residual.addClass('rotulo-linha').css({'width': '20px'});
    rVlcredit_residual.addClass('rotulo-linha').css({'width': '20px'});

    rLqtdedas_residual.addClass('rotulo').css({'width': '350px'});
    rLvalores_residual.addClass('rotulo-linha').css({'width': '130px'});


    // input
    cQtsldant_residual = $("#qtsldant_residual", '#' + frmOpcao);
    cQttitulo_residual = $("#qttitulo_residual", '#' + frmOpcao);
    cQtvencid_residual = $("#qtvencid_residual", '#' + frmOpcao);
    cQtderesg_residual = $("#qtderesg_residual", '#' + frmOpcao);
    cQtcredit_residual = $("#qtcredit_residual", '#' + frmOpcao);
    cVlsldant_residual = $("#vlsldant_residual", '#' + frmOpcao);
    cVltitulo_residual = $("#vltitulo_residual", '#' + frmOpcao);
    cVlvencid_residual = $("#vlvencid_residual", '#' + frmOpcao);
    cVlderesg_residual = $("#vlderesg_residual", '#' + frmOpcao);
    cVlcredit_residual = $("#vlcredit_residual", '#' + frmOpcao);


    cQtsldant_residual.css({'width': '120px'}).addClass('inteiro');
    cQttitulo_residual.css({'width': '120px'}).addClass('inteiro');
    cQtvencid_residual.css({'width': '120px'}).addClass('inteiro');
    cQtderesg_residual.css({'width': '120px'}).addClass('inteiro');
    cQtcredit_residual.css({'width': '120px'}).addClass('inteiro');
    cVlsldant_residual.css({'width': '120px'}).addClass('monetario');
    cVltitulo_residual.css({'width': '120px'}).addClass('monetario');
    cVlvencid_residual.css({'width': '120px'}).addClass('monetario');
    cVlderesg_residual.css({'width': '120px'}).addClass('monetario');
    cVlcredit_residual.css({'width': '120px'}).addClass('monetario');

    // Outros   
    btnOK3 = $('#btnOk3', '#' + frmOpcao);
    cTodosOpcao.desabilitaCampo();
    
    cTpcobran.unbind('keypress').bind('keypress', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se é a tecla TAB ou ENTER, 
        if ((e.keyCode == 9 || e.keyCode == 13)) {
            btnContinuar();
            return false;
        }
    });
    // Se clicar no botao OK
    btnOK3.unbind('click').bind('click', function() {

        if (divError.css('display') == 'block') {
            return false;
        }
        if (cDtvencto.hasClass('campoTelaSemBorda')) {
            return false;
        }
        controlaOperacao('SD');
        return false;
    });

    cDtvencto.unbind('keypress').bind('keypress', function(e) {
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
    rDtvencto = $('label[for="dtvencto"]', '#' + frmOpcao);
    rCdagenci = $('label[for="cdagenci"]', '#' + frmOpcao);

    rDtvencto.css({'width': '220px'}).addClass('rotulo');
    rCdagenci.css({'width': '35px'}).addClass('rotulo-linha');

    // input
    cDtvencto = $('#dtvencto', '#' + frmOpcao);
    cCdagenci = $('#cdagenci', '#' + frmOpcao);

    cDtvencto.css({'width': '75px'}).addClass('data');
    cCdagenci.css({'width': '75px'}).addClass('inteiro').attr('maxlength', '3');

    // Outros   
    cTodosOpcao.habilitaCampo();

    // de
    cDtvencto.unbind('keypress').bind('keypress', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se é a tecla TAB ou ENTER, 
        if ((e.keyCode == 9 || e.keyCode == 13)) {
            cCdagenci.focus();
            return false;
        }

    });

    // PA
    cCdagenci.unbind('keypress').bind('keypress', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se é a tecla TAB ou ENTER, 
        if ((e.keyCode == 9 || e.keyCode == 13)) {
            btnContinuar();
            return false;
        }

    });


    layoutPadrao();
    controlaPesquisas();
    return false;

}


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


// botoes
function btnVoltar() {
    if (cddopcao == 'C'){
        if((!cNrdconta.hasClass('campoTelaSemBorda'))) {
            estadoInicial();
        } else if ((!cNrcpfcgc.hasClass('campoTelaSemBorda'))) {
            cNrdconta.habilitaCampo().focus();
            cNrcpfcgc.desabilitaCampo().val('');

        } else if ((!cTpcobran.hasClass('campoTelaSemBorda'))) {
            if ((normalizaNumero(cNrdconta.val()) == 0 && normalizaNumero(cNrcpfcgc.val()) == 0) || normalizaNumero(cNrcpfcgc.val()) > 0) {
                cNrcpfcgc.habilitaCampo().focus();
                cNrdconta.desabilitaCampo().val('');

            } else {
                cNrdconta.habilitaCampo().focus();
                cNrcpfcgc.desabilitaCampo().val('');
            }
            $('#' + frmOpcao +' .listar_resgatados').hide();
            $('#' + frmOpcao +' .tipo_cobranca').hide();
            cTpcobran.desabilitaCampo().val('T');
            cFlresgat.desabilitaCampo().prop("checked",false);
            cNmprimtl.val('');
        } else if (!(!cTpcobran.hasClass('campoTelaSemBorda'))) {
            $('#' + frmOpcao + ' fieldset:eq(1)').hide();
            cTpcobran.habilitaCampo().focus();
            cFlresgat.habilitaCampo();
            trocaBotao('Prosseguir');
        } 
    } else if (cddopcao =='F'){
        if((!cNrdconta.hasClass('campoTelaSemBorda'))) {
            estadoInicial();
        } else if ((!cNrcpfcgc.hasClass('campoTelaSemBorda'))) {
            cNrdconta.habilitaCampo().focus();
            cNrcpfcgc.desabilitaCampo().val('');

        }else if((!cTpcobran.hasClass('campoTelaSemBorda'))) {
            if ((normalizaNumero(cNrdconta.val()) == 0 && normalizaNumero(cNrcpfcgc.val()) == 0) || normalizaNumero(cNrcpfcgc.val()) > 0) {
                cNrcpfcgc.habilitaCampo().focus();
                cNrdconta.desabilitaCampo().val('');

            } else {
                cNrdconta.habilitaCampo().focus();
                cNrcpfcgc.desabilitaCampo().val('');
            }
            cNmprimtl.val('');
            cTpcobran.val('T').desabilitaCampo();
            $('#' + frmOpcao +' .tipo_cobranca').hide();
            trocaBotao('Prosseguir');
        } else if ((!cDtvencto.hasClass('campoTelaSemBorda'))) {
            $('#' + frmOpcao + ' fieldset:eq(1)').hide();
            $('input', '#' + frmOpcao + ' fieldset:eq(1)').limpaFormulario();
            cTpcobran.habilitaCampo().focus();
            cDtvencto.desabilitaCampo();
            trocaBotao('Prosseguir');
        }
    } else if (cddopcao == 'S'){
        if((!cTpcobran.hasClass('campoTelaSemBorda'))){
            estadoInicial();
        } 
        else {
            $('#' + frmOpcao +' .saldo_contabil').hide();
            trocaBotao('Prosseguir');
            cTpcobran.habilitaCampo().focus();
        } 
     } else if (cddopcao == 'T'){
        if ((!cNrdconta.hasClass('campoTelaSemBorda'))){
            estadoInicial();
        }
        else if((!cTpdepesq.hasClass('campoTelaSemBorda'))) {
            $('#' + frmOpcao + ' fieldset:eq(1)').hide();
            $('input', '#' + frmOpcao + ' fieldset:eq(1)').limpaFormulario();
            cNrdconta.habilitaCampo().select();
            cNmprimtl.val('');
            cTpdepesq.desabilitaCampo();
        } else if((!cTpcobran.hasClass('campoTelaSemBorda'))){
            cTpdepesq.habilitaCampo().focus();
            cNrdocmto.habilitaCampo();
            cVltitulo.habilitaCampo();
            cTpcobran.desabilitaCampo();
            $('#' + frmOpcao +' .tipo_cobranca').hide();
        } else {
            cTpcobran.habilitaCampo().focus();
            $('#' + frmOpcao + ' fieldset:eq(2)').hide();
            trocaBotao('Prosseguir');
        }

    } else if (cddopcao == 'Q'){
        if((!cNrdconta.hasClass('campoTelaSemBorda'))) {
            estadoInicial();
        } else if ((!cNrcpfcgc.hasClass('campoTelaSemBorda'))) {
            cNrdconta.habilitaCampo().focus();
            cNrcpfcgc.desabilitaCampo().val('');

        } else if ((!cTpcobran.hasClass('campoTelaSemBorda'))) {
            if ((normalizaNumero(cNrdconta.val()) == 0 && normalizaNumero(cNrcpfcgc.val()) == 0) || normalizaNumero(cNrcpfcgc.val()) > 0) {
                cNrcpfcgc.habilitaCampo().focus();
                cNrdconta.desabilitaCampo().val('');

            } else {
                cNrdconta.habilitaCampo().focus();
                cNrcpfcgc.desabilitaCampo().val('');
            }
            $('#' + frmOpcao +' .tipo_cobranca').hide();
            cTpcobran.desabilitaCampo().val('T');
            cNmprimtl.val('');
        } else if (cTpcobran.hasClass('campoTelaSemBorda')) {
            $('#' + frmOpcao + ' fieldset:eq(1)').hide();
            cTpcobran.habilitaCampo().focus();
            trocaBotao('Prosseguir');
        } 
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




    var dtmvtolt = $('#glbdtmvtolt','#frmCab').val();


    if(cddopcao == 'B'){

        var dtmvtoltarr = dtmvtolt.split("/");
        var dtmvtolt_convert = new Date(Date.UTC(dtmvtoltarr[2], dtmvtoltarr[1]-1, dtmvtoltarr[0], 0, 0, 0));

        var dtcDtiniper = cDtiniper.val();
        var dtcDtiniperarr = dtcDtiniper.split("/");
        var cDtiniper_convert = new Date(Date.UTC(dtcDtiniperarr[2], dtcDtiniperarr[1]-1, dtcDtiniperarr[0], 0, 0, 0));

        var dtcDtfimper = cDtfimper.val();
        var dtcDtfimperarr = dtcDtfimper.split("/");
        var cDtfimper_convert = new Date(Date.UTC(dtcDtfimperarr[2], dtcDtfimperarr[1]-1, dtcDtfimperarr[0], 0, 0, 0));

        dtmvtolt_convert_time = dtmvtolt_convert.getTime();
        cDtiniper_convert_time = cDtiniper_convert.getTime();
        cDtfimper_convert_time = cDtfimper_convert.getTime();


        if (cDtiniper.val() == '') {
        
            hideMsgAguardo();
            showError("error","Período de Digita&ccedil;&atilde;o deve ser informado.","Alerta - Ayllos","cDtiniper.focus()");
        
        } else if (cDtfimper.val() == '') {
        
            hideMsgAguardo();
            showError("error","Período de Digita&ccedil;&atilde;o deve ser informado.","Alerta - Ayllos","cDtfimper.focus()");
        
        } else if (days_between(cDtfimper.val(), cDtiniper.val()) > 60) {
        
            hideMsgAguardo();
            showError("error","Informe um intervalo de até 60 dias.","Alerta - Ayllos","cDtfimper.focus()");
        
        }else if (cDtiniper_convert_time > cDtfimper_convert_time){
        
            hideMsgAguardo();
            showError("error","Data de in&iacute;cio do periodo deve ser menor ou igual a data final","Alerta - Ayllos","cDtiniper.focus()");
        
        }else if (cDtiniper_convert_time > dtmvtolt_convert_time){
        
            hideMsgAguardo();
            showError("error","Data de in&iacute;cio do per&iacute;odo deve ser menor ou igual do que a data de movimentação do sistema","Alerta - Ayllos","cDtiniper.focus()");
        
        }else if(cDtfimper_convert_time > dtmvtolt_convert_time){
        
            hideMsgAguardo();
            showError("error","Data de fim do per&iacute;odo deve ser menor ou igual do que a data de movimentação do sistema","Alerta - Ayllos","cDtfimper.focus()");
        }
        
        else {
            gerarImpressaoBorderoNaoLiberado();
        }
        
    } else if(cddopcao == 'C'){
        if ((!cNrdconta.hasClass('campoTelaSemBorda'))) {
            hideMsgAguardo();
            cNrdconta.keypress();
        } else if ((!cNrcpfcgc.hasClass('campoTelaSemBorda'))) {
            hideMsgAguardo();
            cNrcpfcgc.keypress();
        } else if ((!cTpcobran.hasClass('campoTelaSemBorda'))) {
            cNrdconta.desabilitaCampo();
            controlaOperacao('CT');
        }
        else if ($('#' + frmOpcao + ' fieldset:eq(1)').css('display')=='block') {
            gerarImpressaoConsulta();
        }
    } else if (cddopcao == 'F'){
        if((!cNrdconta.hasClass('campoTelaSemBorda'))) {
            cNrdconta.keypress();
        }
        else if((!cTpcobran.hasClass('campoTelaSemBorda'))){
            cTpcobran.desabilitaCampo();
            hideMsgAguardo();
            trocaBotao('');
            $('#' + frmOpcao + ' fieldset:eq(1)').show();
            cDtvencto.habilitaCampo().val(dtmvtopr).select();
        }
        else if((!cDtvencto.hasClass('campoTelaSemBorda'))){

        }
    } else if (cddopcao == 'S') {
        hideMsgAguardo();
        cTpcobran.desabilitaCampo();
        $('#' + frmOpcao +' .saldo_contabil').show();
        cDtvencto.val(dtmvtolt);
        cDtvencto.habilitaCampo().select();
        trocaBotao('');
    } else if (cddopcao == 'T'){
        if((!cNrdconta.hasClass('campoTelaSemBorda'))) {
            cNrdconta.keypress();
        } else if((!cTpdepesq.hasClass('campoTelaSemBorda'))) {
            hideMsgAguardo();
            $('#' + frmOpcao +' .tipo_cobranca').show();
            cTpcobran.habilitaCampo().focus();
            cTpdepesq.desabilitaCampo();
            cNrdocmto.desabilitaCampo();
            cVltitulo.desabilitaCampo();
        } else if((!cTpcobran.hasClass('campoTelaSemBorda'))){
            cTpcobran.desabilitaCampo();
            controlaOperacao('BT');
        }
    } else if (cddopcao == 'L') {
        if (cDtvencto.val() == '') {
            hideMsgAguardo();
            showError("error","O dia deve ser informado.","Alerta - Ayllos","cDtvencto.focus()");
        } else {
            hideMsgAguardo();
            gerarImpressaoLote();
        }
    } else if(cddopcao == 'Q'){
        if ((!cNrdconta.hasClass('campoTelaSemBorda'))) {
            hideMsgAguardo();
            cNrdconta.keypress();
        } else if ((!cNrcpfcgc.hasClass('campoTelaSemBorda'))) {
            hideMsgAguardo();
            cNrcpfcgc.keypress();
        } else if ((!cTpcobran.hasClass('campoTelaSemBorda'))) {
            cNrdconta.desabilitaCampo();
            controlaOperacao('BP');
        }
    }

    controlaPesquisas();
    //hideMsgAguardo();
    
    return false;
}


// opcao C
function formataOpcaoC() {

    // label
    rNrdconta = $('label[for="nrdconta"]', '#' + frmOpcao);
    rNrcpfcgc = $('label[for="nrcpfcgc"]', '#' + frmOpcao);
    rNmprimtl = $('label[for="nmprimtl"]', '#' + frmOpcao);
    rTpcobran = $('label[for="tpcobran"]', '#' + frmOpcao);
    rFlresgat = $('label[for="flresgat"]', '#' + frmOpcao);

    rNrdconta.css({'width': '108px'}).addClass('rotulo');
    rNrcpfcgc.css({'width': '84px'}).addClass('rotulo-linha');
    rNmprimtl.css({'width': '108px'}).addClass('rotulo');
    rTpcobran.css({'width': '108px'}).addClass('rotulo');
    rFlresgat.css({'width': '128px'}).addClass('rotulo-linha');

    // input
    cNrdconta = $('#nrdconta', '#' + frmOpcao);
    cNrcpfcgc = $('#nrcpfcgc', '#' + frmOpcao);
    cNmprimtl = $('#nmprimtl', '#' + frmOpcao);
    cTpcobran = $('#tpcobran', '#' + frmOpcao);
    cFlresgat = $('#flresgat', '#' + frmOpcao);

    cNrdconta.css({'width': '75px'}).addClass('pesquisa conta');
    cNrcpfcgc.css({'width': '95px'}).addClass('inteiro').attr('maxlength', '14');
    cNmprimtl.css({'width': '480px'});
    cTpcobran.css({'width': '145px'});
    cFlresgat.css({'width': '20px','margin-top':'5px','height':'16px'});
   
    if ($.browser.msie) {
        rNrcpfcgc.css({'width': '86px'});
    }

    // Outros   
    cTodosOpcao.desabilitaCampo();

    // tabela
    var divRegistro = $('div.divRegistros', '#' + frmOpcao);
    var tabela = $('table', divRegistro);

    $('#' + frmOpcao).css({'margin-top': '5px'});
    divRegistro.css({'height': '307px', 'padding-bottom': '2px'});

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '68';
    arrayLargura[1] = '68';
    arrayLargura[2] = '68';
    arrayLargura[3] = '75';
    arrayLargura[4] = '40';
    arrayLargura[5] = '70';
    arrayLargura[6] = '80';
    arrayLargura[7] = '80';
    arrayLargura[8] = '80';
    arrayLargura[9] = '100';
    arrayLargura[10] = '';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'left';
    arrayAlinha[1] = 'right';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'right';
    arrayAlinha[4] = 'right';
    arrayAlinha[5] = 'right';
    arrayAlinha[6] = 'right';
    arrayAlinha[7] = 'right';
    arrayAlinha[8] = 'center';
    arrayAlinha[9] = 'left';
    arrayAlinha[10] = 'left';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

    // conta
    cNrdconta.unbind('keypress').bind('keypress', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        var auxconta = normalizaNumero(cNrdconta.val());

        // Se é a tecla TAB ou ENTER, 
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
    cNrcpfcgc.unbind('keypress').bind('keypress', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        var auxcpfcg = normalizaNumero(cNrcpfcgc.val());

        // Se é a tecla TAB ou ENTER, 
        if ((e.keyCode === 9 || e.keyCode === 13 || typeof e.keyCode == 'undefined') && (auxcpfcg === 0 || validaCampo('nrcpfcgc', auxcpfcg))) {
            manterRotina('BA');
            return false;

        } else if (e.keyCode == 9 || e.keyCode == 13 || typeof e.keyCode == 'undefined') {
            return false;
        }


    });

    cTpcobran.unbind('keypress').bind('keypress', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se é a tecla TAB ou ENTER, 
        if ((e.keyCode == 9 || e.keyCode == 13)) {
            cFlresgat.focus();
            return false;
        }
    });

    cFlresgat.unbind('keypress').bind('keypress', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se é a tecla TAB ou ENTER, 
        if ((e.keyCode == 9 || e.keyCode == 13)) {
            cNrdconta.desabilitaCampo();
            btnContinuar()
            return false;
        }
    });

    layoutPadrao();
    controlaPesquisas();
    return false;

}

// opcao Q
function formataOpcaoQ() {

    // label
    rNrdconta = $('label[for="nrdconta"]', '#' + frmOpcao);
    rNrcpfcgc = $('label[for="nrcpfcgc"]', '#' + frmOpcao);
    rNmprimtl = $('label[for="nmprimtl"]', '#' + frmOpcao);
    rTpcobran = $('label[for="tpcobran"]', '#' + frmOpcao);

    rNrdconta.css({'width': '108px'}).addClass('rotulo');
    rNrcpfcgc.css({'width': '84px'}).addClass('rotulo-linha');
    rNmprimtl.css({'width': '108px'}).addClass('rotulo');
    rTpcobran.css({'width': '108px'}).addClass('rotulo');

    // input
    cNrdconta = $('#nrdconta', '#' + frmOpcao);
    cNrcpfcgc = $('#nrcpfcgc', '#' + frmOpcao);
    cNmprimtl = $('#nmprimtl', '#' + frmOpcao);
    cTpcobran = $('#tpcobran', '#' + frmOpcao);

    cNrdconta.css({'width': '75px'}).addClass('pesquisa conta');
    cNrcpfcgc.css({'width': '95px'}).addClass('inteiro').attr('maxlength', '14');
    cNmprimtl.css({'width': '480px'});
    cTpcobran.css({'width': '145px'});
   
    if ($.browser.msie) {
        rNrcpfcgc.css({'width': '86px'});
    }

    // Outros   
    cTodosOpcao.desabilitaCampo();

    // tabela
    var divRegistro = $('div.divRegistros', '#' + frmOpcao);
    var tabela = $('table', divRegistro);

    $('#' + frmOpcao).css({'margin-top': '5px'});
    divRegistro.css({'height': '307px', 'padding-bottom': '2px'});

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '68';
    arrayLargura[1] = '68';
    arrayLargura[2] = '68';
    arrayLargura[3] = '75';
    arrayLargura[4] = '40';
    arrayLargura[5] = '70';
    arrayLargura[6] = '80';
    arrayLargura[7] = '80';
    arrayLargura[8] = '';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'left';
    arrayAlinha[1] = 'right';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'right';
    arrayAlinha[4] = 'right';
    arrayAlinha[5] = 'right';
    arrayAlinha[6] = 'right';
    arrayAlinha[7] = 'right';
    arrayAlinha[8] = 'left';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

    // conta
    cNrdconta.unbind('keypress').bind('keypress', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        var auxconta = normalizaNumero(cNrdconta.val());

        // Se é a tecla TAB ou ENTER, 
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
    cNrcpfcgc.unbind('keypress').bind('keypress', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        var auxcpfcg = normalizaNumero(cNrcpfcgc.val());

        // Se é a tecla TAB ou ENTER, 
        if ((e.keyCode === 9 || e.keyCode === 13 || typeof e.keyCode == 'undefined') && (auxcpfcg === 0 || validaCampo('nrcpfcgc', auxcpfcg))) {
            manterRotina('BA');
            return false;

        } else if (e.keyCode == 9 || e.keyCode == 13 || typeof e.keyCode == 'undefined') {
            return false;
        }


    });

    cTpcobran.unbind('keypress').bind('keypress', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se é a tecla TAB ou ENTER, 
        if ((e.keyCode == 9 || e.keyCode == 13)) {
            cNrdconta.desabilitaCampo();
            btnContinuar();
            return false;
        }
    });

    layoutPadrao();
    controlaPesquisas();
    return false;

}

function gerarImpressaoConsulta() {
    
    var nrdconta = normalizaNumero($('#nrdconta', '#' + frmOpcao).val());
    var nrcpfcgc = normalizaNumero($('#nrcpfcgc', '#' + frmOpcao).val());
    var nmprimtl = $('#nmprimtl', '#' + frmOpcao).val();
    var tpcobran = $('#tpcobran', '#' + frmOpcao).val();
    var flresgat = $("#flresgat", '#' + frmOpcao).prop("checked")?"S":"";
    var dtvencto = $('#dtvencto', '#' + frmOpcao).val();
    
    $("#nrdconta","#frmImprimirConsultaTitcto").val(nrdconta);
    $("#nrcpfcgc","#frmImprimirConsultaTitcto").val(nrcpfcgc);
    $("#nmprimtl","#frmImprimirConsultaTitcto").val(nmprimtl);
    $("#tpcobran","#frmImprimirConsultaTitcto").val(tpcobran);
    $("#flresgat","#frmImprimirConsultaTitcto").val(flresgat);
    $("#dtvencto","#frmImprimirConsultaTitcto").val(dtvencto);
    
    var action = $("#frmImprimirConsultaTitcto").attr("action");
    var callafter = "hideMsgAguardo();";
    carregaImpressaoAyllos("frmImprimirConsultaTitcto",action,callafter);
    return false;
}

function gerarImpressaoLote() {
    
    var dtvencto = $('#dtvencto', '#' + frmOpcao).val();
    var cdagenci = $('#cdagenci', '#' + frmOpcao).val();
    
    $("#dtvencto","#frmImprimirLoteTitcto").val(dtvencto);
    $("#cdagenci","#frmImprimirLoteTitcto").val(cdagenci);
    
    var action = $("#frmImprimirLoteTitcto").attr("action");
    var callafter = "hideMsgAguardo();";

    console.log("[action] - " + action);
    console.log("[callafter] - " + callafter);
    
    carregaImpressaoAyllos("frmImprimirLoteTitcto",action,callafter);
    return false;
}

function gerarImpressaoBorderoNaoLiberado() {
    
    var dtiniper = $('#dtiniper', '#' + frmOpcao).val();
    var dtfimper = $('#dtfimper', '#' + frmOpcao).val();
    var cdagenci = $('#cdagenci', '#' + frmOpcao).val();
    var nrdconta = $('#nrdconta', '#' + frmOpcao).val();
    var nrborder = $('#nrborder', '#' + frmOpcao).val();

    
    $("#dtiniper","#frmImprimirBorderoNaoLiberadoTitcto").val(dtiniper);
    $("#dtfimper","#frmImprimirBorderoNaoLiberadoTitcto").val(dtfimper);
    $("#cdagenci","#frmImprimirBorderoNaoLiberadoTitcto").val(cdagenci);
    $("#nrdconta","#frmImprimirBorderoNaoLiberadoTitcto").val(nrdconta);
    $("#nrborder","#frmImprimirBorderoNaoLiberadoTitcto").val(nrborder);
    
    var action = $("#frmImprimirBorderoNaoLiberadoTitcto").attr("action");
    var callafter = "hideMsgAguardo();";

    console.log("[action] - " + action);
    console.log("[callafter] - " + callafter);
    
    carregaImpressaoAyllos("frmImprimirBorderoNaoLiberadoTitcto",action,callafter);
    return false;
}


function trocaBotao(botao) {

    $('#divBotoes', '#divTela').html('');
    $('#divBotoes', '#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>');

    if (botao != '') {
        $('#divBotoes', '#divTela').append('&nbsp;<a href="#" class="botao" onclick="btnContinuar(); return false;" >' + botao + '</a>');
    }
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

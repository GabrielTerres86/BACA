/*!
 * FONTE        : verpro.js
 * CRIAÇÃO      : Rogerius Militão (DB1) 
 * DATA CRIAÇÃO : 25/10/2011
 * OBJETIVO     : Biblioteca de funções da tela VERPRO       Última alteração: 16/11/2015
 * --------------
 * ALTERAÇÕES   :
 * 001: 02/07/2012 - Jorge (CECRED) : Alterado funcao Gera_Impressao(), novo esquema para impressao.
 * 002: 30/11/2012 - David (CECRED) : Eliminar funcoes sem utilização
 * 003: 16/01/2013 - Daniel (CECRED) : Implantacao novo layout.
 * 004: 02/05/2013 - Gabriel (CECRED) : Transferencia Intercooperativa.
 * 005: 09/10/2014 - Adriano (CECRED) : Ajuste para inclusão de protoclos de resgate de aplicação.
 * 006: 09/06/2015 - Vanessa (CECRED) : Inclusão do campo ISPB para TEDS
 * 007: 16/11/2015 - Andre Santos (SUPERO) : Aumento do campo Lin.Digitavel e Cod.Barras 
 * --------------
 */

//Formulários e Tabela
var frmCab = 'frmCab';
var frmDados = 'frmVerpro';
var tabDados = 'tabVerpro';

var cdtippro = '';
var nmprepos = '';
var nmoperad = '';
var tppgamto = '';
var dsdbanco = '';
var dsageban = '';
var nrctafav = '';
var nmfavore = '';
var nrcpffav = '';
var dsfinali = '';
var dstransf = '';
var dscedent = '';
var dttransa = '';
var hrautent = '';
var hrautenx = '';
var dtmvtolt = '';
var vldocmto = '';
var dsprotoc = '';
var cdbarras = '';
var lndigita = '';
var nrseqaut = '';
var nrdocmto = '';
var flgpagto = '';
var dslinha1 = '';
var dslinha2 = '';
var dslinha3 = '';

var nrJanelas = 0;

//Labels/Campos do cabeçalho
var rNrdconta, rNmprimtl, rDatainic, rDatafina, rCdtippro, rDstippro,
        cNrdconta, cNmprimtl, cDatainic, cDatafina, cCdtippro, cDstippro, cTodosCabecalho, btnOK;

var cTodosDados;

$(document).ready(function() {
    estadoInicial();
});

// seletores
function estadoInicial() {
    $('#divTela').fadeTo(0, 0.1);

    trocaBotao('Prosseguir');

    hideMsgAguardo();
    formataCabecalho();

    cTodosCabecalho.limpaFormulario().removeClass('campoErro');

    $('#' + tabDados).remove();
    $('#linha1').remove();
    $('#linha2').remove();
    $('#linha3').remove();
    $('#divPesquisaRodape').remove();

    removeOpacidade('divTela');

    highlightObjFocus($('#frmCab'));

    $('#frmCab').css({'display': 'block'});
    $('#divBotoes').css({'display': 'block'});

    cNrdconta.focus();

}

// controle
function controlaOperacao(operacao, nriniseq, nrregist) {

    var nrdconta = normalizaNumero(cNrdconta.val());
    var nmprimtl = cNmprimtl.val();
    var datainic = cDatainic.val();
    var datafina = cDatafina.val();
    var cdtippro = operacao == 'BP' ? cCdtippro.val() : 0;

    var mensagem = 'Aguarde, buscando dados ...';
    showMsgAguardo(mensagem);

    // Carrega dados da conta através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/verpro/principal.php',
        data:
                {
                    operacao: operacao,
                    nrdconta: nrdconta,
                    nmprimtl: nmprimtl,
                    datainic: datainic,
                    datafina: datafina,
                    cdtippro: cdtippro,
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

function controlaPesquisas() {

    /*---------------------*/
    /*  CONTROLE CONTA/DV  */
    /*---------------------*/
    var linkConta = $('a:eq(0)', '#' + frmCab);

    if (linkConta.prev().hasClass('campoTelaSemBorda')) {
        linkConta.addClass('lupa').css('cursor', 'auto').unbind('click').bind('click', function() {
            return false;
        });
    } else {

        linkConta.prev().unbind('blur').bind('blur', function() {
            controlaPesquisas();
            return false;
        });

        linkConta.css('cursor', 'pointer').unbind('click').bind('click', function() {
            mostraPesquisaAssociado('nrdconta', frmCab);
        });
    }

    return false;
}

function controlaLayout(operacao) {

    formataCabecalho();

    if (operacao == 'BD') {
        cTodosCabecalho.habilitaCampo();
        cNrdconta.desabilitaCampo();
        cNmprimtl.desabilitaCampo();
        cDatainic.focus();

    } else if (operacao == 'BP') {
        $('#divBotoes:eq(0)').remove();
        cTodosCabecalho.desabilitaCampo();
        formataTabela();
    }

    $('#frmCab').css({'display': 'block'});
    $('#divBotoes').css({'display': 'block'});

    controlaFoco();

    controlaPesquisas();
    hideMsgAguardo();
    return false;
}


// formata
function formataCabecalho() {

    // rotulo
    rNrdconta = $('label[for="nrdconta"]', '#' + frmCab);
    rNmprimtl = $('label[for="nmprimtl"]', '#' + frmCab);
    rDatainic = $('label[for="datainic"]', '#' + frmCab);
    rDatafina = $('label[for="datafina"]', '#' + frmCab);
    rCdtippro = $('label[for="cdtippro"]', '#' + frmCab);

    rNrdconta.addClass('rotulo').css({'width': '39px'});
    rNmprimtl.addClass('rotulo').css({'width': '39px'});
    rDatainic.addClass('rotulo-linha').css({'width': '73px'});
    rDatafina.addClass('rotulo-linha').css({'width': '67px'});
    rCdtippro.addClass('rotulo-linha').css({'width': '28px'});

    // campo
    cNrdconta = $('#nrdconta', '#' + frmCab);
    cNmprimtl = $('#nmprimtl', '#' + frmCab);
    cDatainic = $('#datainic', '#' + frmCab);
    cDatafina = $('#datafina', '#' + frmCab);
    cCdtippro = $('#cdtippro', '#' + frmCab);
    cDstippro = $('#dstippro', '#' + frmCab);

    cNrdconta.addClass('conta pesquisa').css({'width': '75px'})
    cNmprimtl.css({'width': '610px'});
    cDatainic.addClass('data').css({'width': '75px'});
    cDatafina.addClass('data').css({'width': '75px'});
    cCdtippro.css({'width': '150px'});

    // outros
    btnOK = $('#btnOK', '#' + frmCab);
    cTodosCabecalho = $('input[type="text"],select', '#' + frmCab);

    if ($.browser.msie) {
        rDatainic.css({'width': '76px'});
        rDatafina.css({'width': '70px'});
        rCdtippro.css({'width': '30px'});
    }

    cTodosCabecalho.desabilitaCampo();
    cNrdconta.habilitaCampo();
    cNrdconta.focus();

    btnOK.unbind('click').bind('click', function() {

        if (divError.css('display') == 'block') {
            return false;
        }

        if (cNrdconta.hasClass('campoTelaSemBorda')) {
            return false;
        }

        // Armazena o número da conta na variável global
        var nrdconta = normalizaNumero(cNrdconta.val());

        // Verifica se o número da conta é vazio
        if (nrdconta == '') {
            return false;
        }

        // Verifica se a conta é válida
        if (!validaNroConta(nrdconta)) {
            showError('error', 'Conta/dv inv&aacute;lida.', 'Alerta - Ayllos', 'focaCampoErro(\'nrdconta\',\'' + frmCab + '\');');
            return false;
        }

        cTodosCabecalho.removeClass('campoErro');

        // Se chegou até aqui, a conta é diferente do vazio e é válida, então realizar a operação desejada
        controlaOperacao('BD', 1, 12);
        return false;

    });


    cNrdconta.unbind('keypress').bind('keypress', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se é a tecla ENTER, 
        if (e.keyCode == 13) {
            btnOK.click();
            return false;

        } else if (e.keyCode == 118) {
            mostraPesquisaAssociado('nrdconta', frmCab);
            return false;
        }
    });

    layoutPadrao();
    cNrdconta.trigger('blur');
    controlaPesquisas();
    return false;
}

function formataTabela() {

    // tabela
    var divRegistro = $('div.divRegistros', '#' + tabDados);
    var tabela = $('table', divRegistro);

    $('#' + tabDados).css({'margin-top': '5px'});
    divRegistro.css({'height': '205px', 'padding-bottom': '2px'});

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '65px';
    arrayLargura[1] = '48px';
    arrayLargura[2] = '70px';
    arrayLargura[3] = '250px'; // 190

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'left';
    arrayAlinha[4] = 'left';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, 'mostraProtocolo();');

    /********************
     FORMATA COMPLEMENTO	
     *********************/
    // complemento linha 1
    var linha1 = $('ul.complemento', '#linha1').css({'margin-left': '1px'});
    $('li:eq(0)', linha1).addClass('txtNormal').css({'text-align': 'left', 'padding-left': '10px'});

    // complemento linha 2
    var linha2 = $('ul.complemento', '#linha2').css({'clear': 'both', 'border-top': '0'});
    $('li:eq(0)', linha2).addClass('txtNormal').css({'text-align': 'left', 'padding-left': '27px'});

    // complemento linha 3
    var linha3 = $('ul.complemento', '#linha3').css({'clear': 'both', 'border-top': '0'});
    $('li:eq(0)', linha3).addClass('txtNormal').css({'text-align': 'left', 'padding-left': '250px'});

    /********************
     EVENTO COMPLEMENTO	
     *********************/
    // seleciona o registro que é clicado
    $('table > tbody > tr', divRegistro).click(function() {
        selecionaTabela($(this));
    });

    // seleciona o registro que é focado
    $('table > tbody > tr', divRegistro).focus(function() {
        selecionaTabela($(this));
    });

    $('table > tbody > tr:eq(0)', divRegistro).click();

    return false;
}

function selecionaTabela(tr) {

    $('#cdbarras', '.complemento').html($('#cdbarras', tr).val());
    $('#lndigita', '.complemento').html($('#lndigita', tr).val());
    $('#terminal', '.complemento').html($('#terminal', tr).val());

    cdtippro = $('#cdtippro', tr).val();
    nmprepos = $('#nmprepos', tr).val();
    nmoperad = $('#nmoperad', tr).val();
    tppgamto = $('#tppgamto', tr).val();
    dsdbanco = $('#dsdbanco', tr).val();
    dsageban = $('#dsageban', tr).val();
    nrctafav = $('#nrctafav', tr).val();
    nmfavore = $('#nmfavore', tr).val();
    nrcpffav = $('#nrcpffav', tr).val();
    dsfinali = $('#dsfinali', tr).val();
    dstransf = $('#dstransf', tr).val();
    dscedent = $('#dscedent', tr).val();
    dttransa = $('#dttransa', tr).val();
    hrautent = $('#hrautent', tr).val();
    hrautenx = $('#hrautenx', tr).val();
    dtmvtolt = $('#dtmvtolt', tr).val();
    vldocmto = $('#vldocmto', tr).val();
    dsprotoc = $('#dsprotoc', tr).val();
    cdbarras = $('#cdbarras', tr).val();
    lndigita = $('#lndigita', tr).val();
    nrseqaut = $('#nrseqaut', tr).val();
    nrdocmto = $('#nrdocmto', tr).val();
    flgpagto = $('#flgpagto', tr).val();
    dslinha1 = $('#dslinha1', tr).val();
    dslinha2 = $('#dslinha2', tr).val();
    dslinha3 = $('#dslinha3', tr).val();

    return false;
}


// detalhes do protocolo
function mostraProtocolo() {

    showMsgAguardo('Aguarde, buscando ...');

    var nrdconta = normalizaNumero(cNrdconta.val());
    var nmprimtl = cNmprimtl.val();

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/verpro/form_verpro.php',
        data: {
            cdtippro: cdtippro,
            nrdconta: nrdconta,
            nmprimtl: nmprimtl,
            nmprepos: nmprepos,
            nmoperad: nmoperad,
            dsdbanco: dsdbanco,
            dsageban: dsageban,
            nrctafav: nrctafav,
            nmfavore: nmfavore,
            nrcpffav: nrcpffav,
            dsfinali: dsfinali,
            dstransf: dstransf,
            dscedent: dscedent,
            dttransa: dttransa,
            hrautent: hrautent,
            hrautenx: hrautenx,
            dtmvtolt: dtmvtolt,
            vldocmto: vldocmto,
            dsprotoc: dsprotoc,
            cdbarras: cdbarras,
            lndigita: lndigita,
            nrseqaut: nrseqaut,
            nrdocmto: nrdocmto,
            dslinha1: dslinha1,
            dslinha2: dslinha2,
            dslinha3: dslinha3,
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground()");
        },
        success: function(response) {
            $('#divRotina').html(response);
            exibeRotina($('#divRotina'));
            formataVerpro();
            return false;
        }
    });
    return false;


}

function formataVerpro() {

    // label
    rNmprepos = $('label[for="nmprepos"]', '#' + frmDados);
    rNmoperad = $('label[for="nmoperad"]', '#' + frmDados);
    rNrdocmtx = $('label[for="nrdocmtx"]', '#' + frmDados);
    rTpdpagto = $('label[for="tpdpagto"]', '#' + frmDados);
    rDsdbanco = $('label[for="dsdbanco"]', '#' + frmDados);
    rDsageban = $('label[for="dsageban"]', '#' + frmDados);
    rNrctafav = $('label[for="nrctafav"]', '#' + frmDados);
    rNmfavore = $('label[for="nmfavore"]', '#' + frmDados);
    rNrcpffav = $('label[for="nrcpffav"]', '#' + frmDados);
    rDsfinali = $('label[for="dsfinali"]', '#' + frmDados);
    rDstransf = $('label[for="dstransf"]', '#' + frmDados);
    rDscedent = $('label[for="dscedent"]', '#' + frmDados);
    rDttransa = $('label[for="dttransa"]', '#' + frmDados);
    rHrautenx = $('label[for="hrautenx"]', '#' + frmDados);
    rDtmvtolt = $('label[for="dtmvtolt"]', '#' + frmDados);
    rVldocmto = $('label[for="vldocmto"]', '#' + frmDados);
    rDsprotoc = $('label[for="dsprotoc"]', '#' + frmDados);
    rCdbarras = $('label[for="cdbarras"]', '#' + frmDados);
    rLndigita = $('label[for="lndigita"]', '#' + frmDados);
    rNrseqaut = $('label[for="nrseqaut"]', '#' + frmDados);
    rNrdocmto = $('label[for="nrdocmto"]', '#' + frmDados);
    rDsispbif = $('label[for="dsispbif"]', '#' + frmDados);

    // labels protocolo aplicacao
    rNrctaapl = $('label[for="nrctaapl"]', '#' + frmDados);
    rNmsolici = $('label[for="nmsolici"]', '#' + frmDados);
    rDtaplica = $('label[for="dtaplica"]', '#' + frmDados);
    rHraplica = $('label[for="hraplica"]', '#' + frmDados);
    rNraplica = $('label[for="nraplica"]', '#' + frmDados);
    rVlaplica = $('label[for="vlaplica"]', '#' + frmDados);
    rTxctrada = $('label[for="txctrada"]', '#' + frmDados);
    rTxminima = $('label[for="txminima"]', '#' + frmDados);
    rDtvencto = $('label[for="dtvencto"]', '#' + frmDados);
    rCarencia = $('label[for="carencia"]', '#' + frmDados);
    rDtcarenc = $('label[for="dtcarenc"]', '#' + frmDados);
    rTxperiod = $('label[for="txperiod"]', '#' + frmDados);

    //labels protocolo de resgate de aplicação
    rDtresgat = $('label[for="dtresgat"]', '#' + frmDados);
    rHrresgat = $('label[for="hrresgat"]', '#' + frmDados);
    rVlrbruto = $('label[for="vlrbruto"]', '#' + frmDados);
    rVldoirrf = $('label[for="vldoirrf"]', '#' + frmDados);
    rVlaliqir = $('label[for="vlaliqir"]', '#' + frmDados);
    rVlliquid = $('label[for="vlliquid"]', '#' + frmDados);


    rNmprepos.addClass('rotulo').css({'width': '115px'});
    rNmoperad.addClass('rotulo').css({'width': '115px'});
    rNrdocmtx.addClass('rotulo').css({'width': '115px'});
    rTpdpagto.addClass('rotulo-linha').css({'width': '45px'});
    rDsdbanco.addClass('rotulo').css({'width': '115px'});
    rDsispbif.addClass('rotulo').css({'width': '115px'});

    rDsageban.addClass('rotulo').css({'width': '115px'});
    rNrctafav.addClass('rotulo').css({'width': '115px'});
    rNmfavore.addClass('rotulo').css({'width': '115px'});
    rNrcpffav.addClass('rotulo').css({'width': '115px'});
    rDsfinali.addClass('rotulo').css({'width': '115px'});
    rDstransf.addClass('rotulo').css({'width': '115px'});
    rDscedent.addClass('rotulo').css({'width': '115px'});
    rDttransa.addClass('rotulo').css({'width': '115px'});
    rHrautenx.addClass('rotulo-linha').css({'width': '45px'});
    rDtmvtolt.addClass('rotulo').css({'width': '115px'});
    rVldocmto.addClass('rotulo').css({'width': '115px'});
    rDsprotoc.addClass('rotulo').css({'width': '115px'});
    rCdbarras.addClass('rotulo').css({'width': '115px'});
    rLndigita.addClass('rotulo').css({'width': '115px'});
    rNrseqaut.addClass('rotulo').css({'width': '115px'});
    rNrdocmto.addClass('rotulo').css({'width': '115px'});

    rNrctaapl.addClass('rotulo').css({'width': '130px'});
    rNmsolici.addClass('rotulo').css({'width': '130px'});
    rDtaplica.addClass('rotulo').css({'width': '130px'});
    rHraplica.addClass('rotulo').css({'width': '130px'});
    rNraplica.addClass('rotulo').css({'width': '130px'});
    rVlaplica.addClass('rotulo').css({'width': '130px'});
    rTxctrada.addClass('rotulo').css({'width': '130px'});
    rTxminima.addClass('rotulo').css({'width': '130px'});
    rDtvencto.addClass('rotulo').css({'width': '130px'});
    rCarencia.addClass('rotulo').css({'width': '130px'});
    rDtcarenc.addClass('rotulo').css({'width': '130px'});
    rTxperiod.addClass('rotulo').css({'width': '115px'});

    rDtresgat.addClass('rotulo').css({'width': '130px'});
    rHrresgat.addClass('rotulo').css({'width': '130px'});
    rVlrbruto.addClass('rotulo').css({'width': '130px'});
    rVldoirrf.addClass('rotulo').css({'width': '130px'});
    rVlaliqir.addClass('rotulo').css({'width': '130px'});
    rVlliquid.addClass('rotulo').css({'width': '130px'});

    // campos
    cNmprepos = $('#nmprepos', '#' + frmDados);
    cNmoperad = $('#nmoperad', '#' + frmDados);
    cNrdocmtx = $('#nrdocmtx', '#' + frmDados);
    cTpdpagto = $('#tpdpagto', '#' + frmDados);
    cDsdbanco = $('#dsdbanco', '#' + frmDados);
    cDsageban = $('#dsageban', '#' + frmDados);
    cNrctafav = $('#nrctafav', '#' + frmDados);
    cNmfavore = $('#nmfavore', '#' + frmDados);
    cNrcpffav = $('#nrcpffav', '#' + frmDados);
    cDsfinali = $('#dsfinali', '#' + frmDados);
    cDstransf = $('#dstransf', '#' + frmDados);
    cDscedent = $('#dscedent', '#' + frmDados);
    cDttransa = $('#dttransa', '#' + frmDados);
    cHrautenx = $('#hrautenx', '#' + frmDados);
    cDtmvtolt = $('#dtmvtolt', '#' + frmDados);
    cVldocmto = $('#vldocmto', '#' + frmDados);
    cDsprotoc = $('#dsprotoc', '#' + frmDados);
    cCdbarras = $('#cdbarras', '#' + frmDados);
    cLndigita = $('#lndigita', '#' + frmDados);
    cNrseqaut = $('#nrseqaut', '#' + frmDados);
    cNrdocmto = $('#nrdocmto', '#' + frmDados);

    // campos protocolo aplicacao
    cNrctaapl = $('#nrctaapl', '#' + frmDados);
    cNmsolici = $('#nmsolici', '#' + frmDados);
    cDtaplica = $('#dtaplica', '#' + frmDados);
    cHraplica = $('#hraplica', '#' + frmDados);
    cNraplica = $('#nraplica', '#' + frmDados);
    cVlaplica = $('#vlaplica', '#' + frmDados);
    cTxctrada = $('#txctrada', '#' + frmDados);
    cTxminima = $('#txminima', '#' + frmDados);
    cDtvencto = $('#dtvencto', '#' + frmDados);
    cCarencia = $('#carencia', '#' + frmDados);
    cDtcarenc = $('#dtcarenc', '#' + frmDados);
    cTxperiod = $('#txperiod', '#' + frmDados);

    //Campos protoclo aplicação
    cDtresgat = $('#dtresgat', '#' + frmDados);
    cHrresgat = $('#hrresgat', '#' + frmDados);
    cVlrbruto = $('#vlrbruto', '#' + frmDados);
    cVldoirrf = $('#vldoirrf', '#' + frmDados);
    cVlaliqir = $('#vlaliqir', '#' + frmDados);
    cVlliquid = $('#vlliquid', '#' + frmDados);

    cNmprepos.css({'width': '440px'});
    cNmoperad.css({'width': '440px'});
    cNrdocmtx.css({'width': '200px'});
    cTpdpagto.css({'width': '189px'});
    cDsdbanco.css({'width': '440px'});
    cDsageban.css({'width': '440px'});
    cNrctafav.css({'width': '440px'});
    cNmfavore.css({'width': '440px'});
    cNrcpffav.css({'width': '440px'});
    cDsfinali.css({'width': '440px'});
    cDstransf.css({'width': '440px'});
    cDscedent.css({'width': '440px'});
    cDttransa.css({'width': '200px'});
    cHrautenx.css({'width': '189px'});
    cDtmvtolt.css({'width': '440px'});
    cVldocmto.css({'width': '440px'});
    cDsprotoc.css({'width': '440px'});
    cCdbarras.css({'width': '440px'});
    cLndigita.css({'width': '440px'});
    cNrseqaut.css({'width': '440px'});
    cNrdocmto.css({'width': '440px'});

    cNrctaapl.css({'width': '400px'});
    cNmsolici.css({'width': '400px'});
    cDtaplica.css({'width': '400px'});
    cHraplica.css({'width': '400px'});
    cNraplica.css({'width': '400px'});
    cVlaplica.css({'width': '400px'});
    cTxctrada.css({'width': '400px'});
    cTxminima.css({'width': '400px'});
    cDtvencto.css({'width': '400px'});
    cCarencia.css({'width': '400px'});
    cDtcarenc.css({'width': '400px'});
    cTxperiod.css({'width': '400px'});

    cDtresgat.css({'width': '400px'});
    cHrresgat.css({'width': '400px'});
    cVlrbruto.css({'width': '400px'});
    cVldoirrf.css({'width': '400px'});
    cVlaliqir.css({'width': '400px'});
    cVlliquid.css({'width': '400px'});

    if ($.browser.msie) {
        rTpdpagto.css({'width': '48px'});
        rHrautenx.css({'width': '48px'});
    }

    var label = tppgamto + ':' + dsdbanco;
    var auxiliar = dsdbanco;
    var auxiliar2 = '';
    var auxiliar3 = '';
    var auxiliar4 = '';

    if (cdtippro == '1' || cdtippro == '4') {
        auxiliar2 = nrdocmto;
        auxiliar3 = nrseqaut;
    }

    if (cdtippro == '2' || cdtippro == '6') {
        auxiliar2 = nrdocmto;
        auxiliar3 = dscedent;
        auxiliar4 = nrseqaut;
    }

    if (nmprepos == '') {
        rNmprepos.css({'display': 'none'});
        cNmprepos.css({'display': 'none'});
    }

    if (nmoperad == '') {
        rNmoperad.css({'display': 'none'});
        cNmoperad.css({'display': 'none'});
    }

    rNrdocmtx.css({'display': 'none'});
    rTpdpagto.css({'display': 'none'});
    rDsageban.css({'display': 'none'});
    rNrctafav.css({'display': 'none'});
    rNmfavore.css({'display': 'none'});
    rNrcpffav.css({'display': 'none'});
    rDsfinali.css({'display': 'none'});
    rDstransf.css({'display': 'none'});

    cNrdocmtx.css({'display': 'none'});
    cTpdpagto.css({'display': 'none'});
    cDsageban.css({'display': 'none'});
    cNrctafav.css({'display': 'none'});
    cNmfavore.css({'display': 'none'});
    cNrcpffav.css({'display': 'none'});
    cDsfinali.css({'display': 'none'});
    cDstransf.css({'display': 'none'});

    rNrctaapl.css({'display': 'none'});
    rNmsolici.css({'display': 'none'});
    rDtaplica.css({'display': 'none'});
    rHraplica.css({'display': 'none'});
    rNraplica.css({'display': 'none'});
    rVlaplica.css({'display': 'none'});
    rTxctrada.css({'display': 'none'});
    rTxminima.css({'display': 'none'});
    rDtvencto.css({'display': 'none'});
    rCarencia.css({'display': 'none'});
    rDtcarenc.css({'display': 'none'});
    rTxperiod.css({'display': 'none'});

    cNrctaapl.css({'display': 'none'});
    cNmsolici.css({'display': 'none'});
    cDtaplica.css({'display': 'none'});
    cHraplica.css({'display': 'none'});
    cNraplica.css({'display': 'none'});
    cVlaplica.css({'display': 'none'});
    cTxctrada.css({'display': 'none'});
    cTxminima.css({'display': 'none'});
    cDtvencto.css({'display': 'none'});
    cCarencia.css({'display': 'none'});
    cDtcarenc.css({'display': 'none'});
    cTxperiod.css({'display': 'none'});

    cDtresgat.css({'display': 'none'});
    cHrresgat.css({'display': 'none'});
    cVlrbruto.css({'display': 'none'});
    cVldoirrf.css({'display': 'none'});
    cVlaliqir.css({'display': 'none'});
    cVlliquid.css({'display': 'none'});


    rDsageban.html('Agencia Favorecido:');

    if (cdtippro == '1' || cdtippro == '2' || cdtippro == '4' || cdtippro == '6') {

        if (cdtippro == '1') {
            rDsageban.html('Coop. Destino:');

            rDsageban.css({'display': 'block'});
            cDsageban.css({'display': 'block'});
        }

        if (cdtippro == '1' || cdtippro == '4') {
            rDsdbanco.html('Conta/dv Destino:');
            rDscedent.css({'display': 'none'});
            cDscedent.css({'display': 'none'});
            rDtmvtolt.html('Data Transferencia:');
            rCdbarras.css({'display': 'none'});
            rLndigita.css({'display': 'none'});
            cCdbarras.css({'display': 'none'});
            cLndigita.css({'display': 'none'});
        } else if (tppgamto != 'Banco') {
            rDsdbanco.html(tppgamto + ':');
            rDscedent.css({'display': 'none'});
            cDscedent.css({'display': 'none'});
        }

    } else if (cdtippro == '9') {

        rNrdocmtx.css({'display': 'none'});
        rTpdpagto.css({'display': 'none'});
        rDsdbanco.css({'display': 'block'});
        rDsageban.css({'display': 'block'});
        rNrctafav.css({'display': 'block'});
        rNmfavore.css({'display': 'block'});
        rNrcpffav.css({'display': 'block'});
        rDsfinali.css({'display': 'block'});
        rDscedent.css({'display': 'none'});
        rDttransa.css({'display': 'block'});
        rHrautenx.css({'display': 'block'});
        rDtmvtolt.css({'display': 'none'});
        rVldocmto.css({'display': 'block'});
        rDsprotoc.css({'display': 'block'});
        rCdbarras.css({'display': 'none'});
        rLndigita.css({'display': 'none'});
        rNrseqaut.css({'display': 'block'});
        rNrdocmto.css({'display': 'block'});

        cNrdocmtx.css({'display': 'none'});
        cTpdpagto.css({'display': 'none'});
        cDsdbanco.css({'display': 'block'});
        cDsageban.css({'display': 'block'});
        cNrctafav.css({'display': 'block'});
        cNmfavore.css({'display': 'block'});
        cNrcpffav.css({'display': 'block'});
        cDsfinali.css({'display': 'block'});
        cDscedent.css({'display': 'none'});
        cDttransa.css({'display': 'block'});
        cHrautenx.css({'display': 'block'});
        cDtmvtolt.css({'display': 'none'});
        cVldocmto.css({'display': 'block'});
        cDsprotoc.css({'display': 'block'});
        cCdbarras.css({'display': 'none'});
        cLndigita.css({'display': 'none'});
        cNrseqaut.css({'display': 'block'});
        cNrdocmto.css({'display': 'block'});

        if (dstransf != '') {
            rDstransf.css({'display': 'block'});
            cDstransf.css({'display': 'block'});
        } else {
            rDstransf.css({'display': 'none'});
            cDstransf.css({'display': 'none'});
        }

    } else if (cdtippro == '10') {

        rDsprotoc.css({'width': '130px'});
        rNrseqaut.css({'width': '130px'});

        cDsprotoc.css({'width': '400px'});
        cNrseqaut.css({'width': '400px'});

        rDscedent.css({'display': 'none'});
        cDscedent.css({'display': 'none'});
        rCdbarras.css({'display': 'none'});
        rLndigita.css({'display': 'none'});
        cCdbarras.css({'display': 'none'});
        cLndigita.css({'display': 'none'});

        rDsdbanco.css({'display': 'none'});
        cDsdbanco.css({'display': 'none'});
        rNrdocmto.css({'display': 'none'});
        cNrdocmto.css({'display': 'none'});

        rDttransa.css({'display': 'none'});
        rHrautenx.css({'display': 'none'});
        rDtmvtolt.css({'display': 'none'});
        rVldocmto.css({'display': 'none'});

        cDttransa.css({'display': 'none'});
        cHrautenx.css({'display': 'none'});
        cDtmvtolt.css({'display': 'none'});
        cVldocmto.css({'display': 'none'});

        rNrctaapl.css({'display': 'block'});
        rNmsolici.css({'display': 'block'});
        rDtaplica.css({'display': 'block'});
        rHraplica.css({'display': 'block'});
        rNraplica.css({'display': 'block'});
        rVlaplica.css({'display': 'block'});
        rTxctrada.css({'display': 'block'});
        rTxminima.css({'display': 'block'});
        rDtvencto.css({'display': 'block'});
        rCarencia.css({'display': 'block'});
        rDtcarenc.css({'display': 'block'});

        cNrctaapl.css({'display': 'block'});
        cNmsolici.css({'display': 'block'});
        cDtaplica.css({'display': 'block'});
        cHraplica.css({'display': 'block'});
        cNraplica.css({'display': 'block'});
        cVlaplica.css({'display': 'block'});
        cTxctrada.css({'display': 'block'});
        cTxminima.css({'display': 'block'});
        cDtvencto.css({'display': 'block'});
        cCarencia.css({'display': 'block'});
        cDtcarenc.css({'display': 'block'});

    } else if (cdtippro == '12') {

        rDsprotoc.css({'width': '130px'});
        rNrseqaut.css({'width': '130px'});

        cDsprotoc.css({'width': '400px'});
        cNrseqaut.css({'width': '400px'});

        rDscedent.css({'display': 'none'});
        cDscedent.css({'display': 'none'});
        rCdbarras.css({'display': 'none'});
        rLndigita.css({'display': 'none'});
        cCdbarras.css({'display': 'none'});
        cLndigita.css({'display': 'none'});

        rDsdbanco.css({'display': 'none'});
        cDsdbanco.css({'display': 'none'});
        rNrdocmto.css({'display': 'none'});
        cNrdocmto.css({'display': 'none'});

        rDttransa.css({'display': 'none'});
        rHrautenx.css({'display': 'none'});
        rDtmvtolt.css({'display': 'none'});
        rVldocmto.css({'display': 'none'});

        cDttransa.css({'display': 'none'});
        cHrautenx.css({'display': 'none'});
        cDtmvtolt.css({'display': 'none'});
        cVldocmto.css({'display': 'none'});

        rNrctaapl.css({'display': 'block'});
        rNmsolici.css({'display': 'block'});
        rNraplica.css({'display': 'block'});

        cNrctaapl.css({'display': 'block'});
        cNmsolici.css({'display': 'block'});
        cNraplica.css({'display': 'block'});
        cDtresgat.css({'display': 'block'});
        cHrresgat.css({'display': 'block'});
        cVlrbruto.css({'display': 'block'});
        cVldoirrf.css({'display': 'block'});
        cVlaliqir.css({'display': 'block'});
        cVlliquid.css({'display': 'block'});

    } else {

        if (cdtippro == '3') {
            rDsdbanco.html('Nr. do Plano:');
            if (flgpagto == 'yes') {
                auxiliar = nrdocmto + '              Tipo: Debito em folha';
                cTpdpagto.val('Debito em folha');
            } else {
                auxiliar = nrdocmto + '              Tipo: Debito em conta';
                cTpdpagto.val('Debito em conta');
            }
            rNrdocmtx.css({'display': 'block'});
            rTpdpagto.css({'display': 'block'});
            cNrdocmtx.css({'display': 'block'});
            cTpdpagto.css({'display': 'block'});
            rDsdbanco.css({'display': 'none'});
            cDsdbanco.css({'display': 'none'});
            rNrdocmto.css({'display': 'none'});
            cNrdocmto.css({'display': 'none'});
            $('#label2', '#' + frmDados).val('Nr. do Plano:');
        } else {
            rDsdbanco.html(tppgamto + ':');
            $('#label2', '#' + frmDados).val(tppgamto);
        }

        rDscedent.css({'display': 'none'});
        cDscedent.css({'display': 'none'});
        rDttransa.html('Data:');
        rDtmvtolt.html('Data Movimento:');

        if (cdtippro == '7') {
            rCdbarras.css({'display': 'block'});
            rLndigita.css({'display': 'block'});
            cCdbarras.css({'display': 'block'});
            cLndigita.css({'display': 'block'});

        } else {
            rCdbarras.css({'display': 'none'});
            rLndigita.css({'display': 'none'});
            cCdbarras.css({'display': 'none'});
            cLndigita.css({'display': 'none'});

        }

        rNrseqaut.css({'display': 'none'});
        cNrseqaut.css({'display': 'none'});

        if (cdtippro != '5') {
            rNrdocmto.css({'display': 'none'});
            cNrdocmto.css({'display': 'none'});			
        }
		
		if (cdtippro == '13') {
			rNrdocmto.css({'display': 'block','width':'170px'});
            cNrdocmto.css({'display': 'block','width':'100px'});	
			
			rNrseqaut.css({'display': 'block','width':'170px'});
			cNrseqaut.css({'display': 'block','width':'100px'});
		}
		
    }

    $('#label', '#' + frmDados).val(label);
    $('#auxiliar', '#' + frmDados).val(auxiliar);
    $('#auxiliar2', '#' + frmDados).val(auxiliar2);
    $('#auxiliar3', '#' + frmDados).val(auxiliar3);
    $('#auxiliar4', '#' + frmDados).val(auxiliar4);

    // outros
    cTodosDados = $('input[type="text"],select', '#' + frmDados);
    cTodosDados.desabilitaCampo();

    // centraliza a divRotina
    $('#divRotina').css({'width': '600px'});
    $('#divConteudo').css({'width': '575px'});
    $('#divRotina').centralizaRotinaH();

    hideMsgAguardo();
    bloqueiaFundo($('#divRotina'));
    return false;

}

function Gera_Impressao() {

    var action = UrlSite + 'telas/verpro/imprimir_dados.php';

    cTodosDados.habilitaCampo();

    carregaImpressaoAyllos(frmDados, action, "cTodosDados.desabilitaCampo();bloqueiaFundo(divRotina);");

}

// botoes
function btnVoltar() {
    estadoInicial();
    controlaPesquisas();
    return false;
}

function btnContinuar() {


    if (divError.css('display') == 'block') {
        return false;
    }
    if (cNrdconta.hasClass('campo')) {
        btnOK.click();
    }
    else if (cDatainic.hasClass('campo')) {
        controlaOperacao('BP', 1, 12);
    }
    return false;

}

function trocaBotao(botao) {

    $('#divBotoes', '#divTela').html('');
    $('#divBotoes', '#divTela').append('<a href="#" class="botao" id="btVoltar" onClick="btnVoltar(); return false;">Voltar</a>&nbsp;');
    $('#divBotoes', '#divTela').append('<a href="#" class="botao" id="btSalvar" onClick="btnContinuar(); return false;">' + botao + '</a>');

    return false;
}

function controlaFoco() {

    $('#datainic', '#frmCab').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#datafina', '#frmCab').focus();
            return false;
        }
    });

    $('#datafina', '#frmCab').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#cdtippro', '#frmCab').focus();
            return false;
        }
    });

    $('#cdtippro', '#frmCab').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            controlaOperacao('BP', 1, 12);
            return false;
        }
    });

}
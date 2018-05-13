/*!
 * FONTE        : impres.js
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 31/08/2011
 * OBJETIVO     : Biblioteca de funções da tela IMPRES
 * --------------
 * ALTERAÇÕES   :
 * 02/07/2012 - Jorge        (CECRED) : Alterado funcao Gera_Impressao(), novo esquema de impressao.
 * 10/09/2012 - Guilherme    (SUPERO) : Novos tipos de relatorio Aplicacao(Analit/Sintet/Demonst)
 * 29/11/2012 - Daniel       (CECRED) : Alterado botões do tipo tag <input> para tag <a> novo layout,
 *                                      incluso efeito fade e highlightObjFocus. Alterado posicionamento]
 *	                                    campos da tela, tratamento navegação campos.
 * 31/05/2013 - Daniel       (CECRED) : Alterado focus no keypress do campo inrelext.
 * 30/12/2014 - Kelvin       (CECRED) : Padronizando a mascara do campo nrctremp.
 *										10 Digitos - Campos usados apenas para visualização
 *										8 Digitos - Campos usados para alterar ou incluir novos contratos
 *										(SD 233714)
  05/01/2016 - Jonathan         (RKAM): Ajsutes para inclusão do relatorio de juros e encargos - M273

  08/08/2016 - Guilherme      (SUPERO): M325 - Informe de Rendimentos Trimestral PJ

 * --------------
 */

//Formulários e Tabela

var cddopcao = '';

var frmCab = 'frmCab';
var frmDados = 'frmImpres';
var tabDados = 'tabImpres';

var arrayTipo = new Array();
var arrayImpres = new Array();
var camposDc = '';
var dadosDc = '';

var nrJanelas = 0;

//Labels/Campos do cabeçalho
var rCddopcao, rNrdconta, rTpextrat,
	cCddopcao, cNrdconta, cTpextrat, cTodosCabecalho, btnOK1, btnOK2;


var rDtrefere, rDtreffim, rFlgtarif, rInrelext, rInselext, rNrctremp, rNraplica, rNranoref, rFlgemiss,
	cDtrefere, cDtreffim, cFlgtarif, cInrelext, cInselext, cNrctremp, cNraplica, cNranoref, cFlgemiss,
    cTodosDados, btnOK3, cTpmodelo, rTpmodelo, cTpinform, rTpinform, cNrperiod, rNrperiod;


$(document).ready(function () {
    estadoInicial();
});

// seletores
function estadoInicial() {
    $('#divTela').fadeTo(0, 0.1);

    $('#divBotoes', '#divTela').css({ 'display': 'block' });
    $('#frmCab').css({ 'display': 'block' });
    $('#tabImpres', '#divTela').css({ 'display': 'block' });

    $('#divTipo6').hide();

    $("#btContinuar", "#divBotoes").hide();
    $("#btVoltar", "#divBotoes").hide();

    if (arrayImpres.length == 0) {
        $('#' + frmDados).css({ 'display': 'none' });
        $('#' + tabDados).css({ 'display': 'none' });
    }

    arrayTipo[0] = new Array();
    arrayTipo[1] = new Array('dtrefere', 'dtreffim', 'flgtarif', 'inrelext', 'flgemiss');
    arrayTipo[2] = new Array('nranoref', 'flgemiss');
    arrayTipo[3] = new Array('inselext', 'nrctremp', 'flgemiss');
    arrayTipo[4] = new Array('dtrefere', 'inselext', 'nraplica', 'flgemiss', 'tpmodelo', 'dtreffim');
    arrayTipo[5] = new Array('dtrefere', 'dtreffim', 'inselext', 'nraplica', 'flgemiss');
    arrayTipo[6] = new Array('tpinform','nrperiod','nranoref', 'flgemiss');
    arrayTipo[7] = new Array('dtrefere', 'flgemiss');
    arrayTipo[8] = new Array('dtrefere');
    arrayTipo[9] = new Array('nranoref', 'flgemiss');
    arrayTipo[10] = new Array();
    arrayTipo[11] = new Array();
    arrayTipo[12] = new Array('nranoref');

    cddopcao = '';

    hideMsgAguardo();
    atualizaSeletor();
    controlaLayout();

    cTodosDados.limpaFormulario();

    cNrdconta.val('');
    cTpextrat.val('0');
    cFlgtarif.val('');
    cInrelext.val('0');
    cInselext.val('0');
    cFlgemiss.val('');
    cTpmodelo.val('1');
    cDtrefere.val('');
    cDtreffim.val('');
    cTpinform.val(0);

    removeOpacidade('divTela');
    ocultaCampos(cTpextrat.val());

    highlightObjFocus($("#frmCab"));
    highlightObjFocus($("#frmImpres"));

}

function ocultaCampos(tipo) {

    if (tipo == 4) {
        var newOptions = {
            '1': '1-Especifico',
            '2': '2-Todos',
            '3': '3-Com Saldo',
            '4': '4-Sem Saldo'
        };

        $('#divTodos0').css({ 'display': 'block' }); //Tipo Relat
        $('#divTodos1').css({ 'display': 'none' });
        $('#divTodos2').css({ 'display': 'none' });
    }
    else
        if (tipo == 0) {
            var newOptions = {
                '1': '1-Especifico',
                '2': '2-Todos'
            };
            $('#divTodos0').css({ 'display': 'none' }); //Tipo Relat
            $('#divTodos1').css({ 'display': 'block' });
            $('#divTodos2').css({ 'display': 'block' });
        }
        else {
            var newOptions = {
                '1': '1-Especifico',
                '2': '2-Todos'
            };
            $('#divTodos0').css({ 'display': 'none' }); //Tipo Relat
            $('#divTodos1').css({ 'display': 'block' });
            $('#divTodos2').css({ 'display': 'block' });
        }
    if (tipo != 6) {
        $('#divTipo6').hide();
        $('#divPeriodo').hide();
    }else {$('#divTipo6').show();}


    var selectedOption = '2';

    if (cInselext.prop) {
        var options = cInselext.prop('options');
    }
    else {
        var options = cInselext.attr('options');
    }

    $('option', cInselext).remove();

    $.each(newOptions, function (val, text) {
        options[options.length] = new Option(text, val);
    });
    cInselext.val(selectedOption);

}

function estadoCabecalho() {

    if (arrayImpres.length == 0) {
        $('#' + frmDados).css({ 'display': 'none' });
        $('#' + tabDados).css({ 'display': 'none' });
    }

    ocultaCampos(0);

    cTodosCabecalho.habilitaCampo();
    cCddopcao.desabilitaCampo();
    cNrdconta.focus();
    cNrdconta.val('');
    cTpextrat.val('');


    cTodosDados.limpaFormulario().desabilitaCampo();
    cFlgtarif.val('');
    cInrelext.val('0');
    cInselext.val('0');
    cFlgemiss.val('');
    cTpinform.val(0);

    controlaPesquisas();
    return false;
}

function atualizaSeletor() {

    // cabecalho
    rCddopcao = $('label[for="cddopcao"]', '#' + frmCab);
    rNrdconta = $('label[for="nrdconta"]', '#' + frmCab);
    rTpextrat = $('label[for="tpextrat"]', '#' + frmCab);

    cCddopcao = $('#cddopcao', '#' + frmCab);
    cNrdconta = $('#nrdconta', '#' + frmCab);
    cTpextrat = $('#tpextrat', '#' + frmCab);

    cTodosCabecalho = $('input[type="text"],select', '#' + frmCab);
    btnOK1 = $('#btnOK1', '#' + frmCab);
    btnOK2 = $('#btnOK2', '#' + frmCab);


    rDtrefere = $('label[for="dtrefere"]', '#' + frmDados);
    rDtreffim = $('label[for="dtreffim"]', '#' + frmDados);
    rFlgtarif = $('label[for="flgtarif"]', '#' + frmDados);
    rInrelext = $('label[for="inrelext"]', '#' + frmDados);
    rInselext = $('label[for="inselext"]', '#' + frmDados);
    rNrctremp = $('label[for="nrctremp"]', '#' + frmDados);
    rNraplica = $('label[for="nraplica"]', '#' + frmDados);
    rNranoref = $('label[for="nranoref"]', '#' + frmDados);
    rFlgemiss = $('label[for="flgemiss"]', '#' + frmDados);
    rTpmodelo = $('label[for="tpmodelo"]', '#' + frmDados);
    rTpinform = $('label[for="tpinform"]', '#' + frmDados);
    rNrperiod = $('label[for="nrperiod"]', '#' + frmDados);
    rBtnoK3 = $('label[for="btnOK3"]', '#' + frmDados);


    cDtrefere = $('#dtrefere', '#' + frmDados);
    cDtreffim = $('#dtreffim', '#' + frmDados);
    cFlgtarif = $('#flgtarif', '#' + frmDados);
    cInrelext = $('#inrelext', '#' + frmDados);
    cInselext = $('#inselext', '#' + frmDados);
    cTpmodelo = $('#tpmodelo', '#' + frmDados);
    cNrctremp = $('#nrctremp', '#' + frmDados);
    cNraplica = $('#nraplica', '#' + frmDados);
    cNranoref = $('#nranoref', '#' + frmDados);
    cTpinform = $('#tpinform', '#' + frmDados);
    cNrperiod = $('#nrperiod', '#' + frmDados);
    cFlgemiss = $('#flgemiss', '#' + frmDados);

    cTodosDados = $('input[type="text"],select', '#' + frmDados);
    btnOK3 = $('#btnOK3', '#' + frmDados);

    return false;

}


// controle
function controlaOperacao() {

    hideMsgAguardo();

    var cddopcao = cCddopcao.val();
    var nrdconta = normalizaNumero(cNrdconta.val());
    var mensagem = 'Aguarde, buscando ...';

    showMsgAguardo(mensagem);

    // Carrega dados da conta através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/impres/principal.php',
        data:
				{
				    cddopcao: cddopcao,
				    nrdconta: nrdconta,
				    redirect: 'script_ajax'
				},
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function (response) {
            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divTela').html(response);
                    return false;
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

function manterRotina(operacao) {

    hideMsgAguardo();
    var mensagem = '';
    var nrdconta = normalizaNumero(cNrdconta.val());
    var tpextrat = normalizaNumero(cTpextrat.val());
    var dtrefere = cDtrefere.val();
    var dtreffim = cDtreffim.val();
    var flgtarif = cFlgtarif.val() != null ? cFlgtarif.val() : '';
    var nranoref = normalizaNumero(cNranoref.val());
    var inselext = normalizaNumero(cInselext.val());
    var nrctremp = normalizaNumero(cNrctremp.val());
    var narplica = normalizaNumero(cNraplica.val());
    var tpmodelo = normalizaNumero(cTpmodelo.val());
    var tpinform = normalizaNumero(cTpinform.val());
    var nrperiod = normalizaNumero(cNrperiod.val());
    var flgemiss = cFlgemiss.val() != null ? cFlgemiss.val() : '';
    var inrelext = normalizaNumero(cInrelext.val());


    var camposDc = '';
    camposDc = retornaCampos(arrayImpres, '|');

    var dadosDc = '';
    dadosDc = retornaValores(arrayImpres, ';', '|', camposDc);

    if (cInrelext.hasClass('campo') && (cInrelext.val() <= 0 || cInrelext.val() >= 5)) {
        showError('error', 'Tipo de impressao errada.', 'Alerta - Ayllos', 'focaCampoErro(\'inrelext\',\'' + frmDados + '\');');
        return false;
    } else if (cInselext.hasClass('campo') && (((cInselext.val() < 1 || cInselext.val() > 2) && tpextrat != 4) ||
                                                 ((cInselext.val() < 1 || cInselext.val() > 4) && tpextrat == 4))) {
        showError('error', '170 - Selecao errada...', 'Alerta - Ayllos', 'focaCampoErro(\'inselext\',\'' + frmDados + '\');');
        return false;
    } else if (cDtrefere.hasClass('campo') && (cDtrefere.val() == '' || cDtrefere.val() == null)) {
        showError('error', '170 - Data nao informada!', 'Alerta - Ayllos', 'focaCampoErro(\'dtrefere\',\'' + frmDados + '\');');
        return false;
    }

    cTodosDados.removeClass('campoErro');


    var dtArrIni = dtrefere.split('/');
    var dtArrFim = dtreffim.split('/');

    // Por causa da formatacao de MES/ANO quando selecionado "4-Aplicação"
    if (tpextrat == 4 && tpmodelo == 1 && operacao == 'VO') {
        dtrefere = "01/" + dtArrIni[0] + "/" + dtArrIni[1];
        dtreffim = "01/" + dtArrFim[0] + "/" + dtArrFim[1];

        dtArrIni = dtrefere.split('/');
        dtArrFim = dtreffim.split('/');

        //showError('error',dtreffim ,'Alerta - Ayllos','');
    }
    var cmpDtrefere = parseInt(dtArrIni[2] + dtArrIni[1] + dtArrIni[0]);
    var cmpDtreffim = parseInt(dtArrFim[2] + dtArrFim[1] + dtArrFim[0]);


    if ((cmpDtrefere > cmpDtreffim) && (operacao == 'VO')) {
        showError('error', 'Data Inicial superior a Data Final!', 'Alerta - Ayllos', 'focaCampoErro(\'dtrefere\',\'' + frmDados + '\');');
        return false;
    }

    switch (operacao) {
        case 'VD': mensagem = 'Aguarde, validando ...'; break;
        case 'VO': mensagem = 'Aguarde, validando ...'; break;
        case 'GD': mensagem = 'Aguarde, gravando ...'; break;
        default: return false; break;
    }

    showMsgAguardo(mensagem);

    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/impres/manter_rotina.php',
        data: {
            operacao: operacao,
            cddopcao: cddopcao,
            nrdconta: nrdconta,
            tpextrat: tpextrat,
            tpmodelo: tpmodelo,
            dtrefere: dtrefere,
            dtreffim: dtreffim,
            flgtarif: flgtarif,
            nranoref: nranoref,
            inselext: inselext,
            nrctremp: nrctremp,
            narplica: narplica,
            flgemiss: flgemiss,
            inrelext: inrelext,
            camposDc: camposDc,
            tpinform: tpinform,
            nrperiod: nrperiod,
            dadosDc: dadosDc,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function (response) {
            try {
                eval(response);
                ocultaCampos(tpextrat);
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
    var linkConta = $('a:eq(1)', '#' + frmCab);

    if (linkConta.prev().hasClass('campoTelaSemBorda')) {
        linkConta.addClass('lupa').css('cursor', 'auto').unbind('click').bind('click', function () { return false; });
    } else {
        linkConta.css('cursor', 'pointer').unbind('click').bind('click', function () {
            mostraPesquisaAssociado('nrdconta', frmCab);
        });
    }

    /*--------------------*/
    /*  CONTROLE CONTRATO */
    /*--------------------*/
    var linkContrato = $('#nrctremp', '#' + frmDados).next();

    if (linkContrato.prev().hasClass('campoTelaSemBorda')) {
        linkContrato.addClass('lupa').css('cursor', 'auto').unbind('click').bind('click', function () { return false; });
    } else {
        linkContrato.css('cursor', 'pointer').unbind('click').bind('click', function () {
            mostraContrato();
            return false;
        });
    }

    /*--------------------*/
    /* CONTROLE APLICACAO */
    /*--------------------*/
    var linkAplicacao = $('#nraplica', '#' + frmDados).next();

    if (linkAplicacao.prev().hasClass('campoTelaSemBorda')) {
        linkAplicacao.addClass('lupa').css('cursor', 'auto').unbind('click').bind('click', function () { return false; });
    } else {
        linkAplicacao.css('cursor', 'pointer').unbind('click').bind('click', function () {
            if (cTpextrat.val() == 5) {
                mostraPoupanca();
            } else {
                mostraAplicacao();
            }
            return false;
        });
    }


    return false;
}


// formata
function formataCabecalho() {

    // cabecalho
    rCddopcao.addClass('rotulo').css({ 'width': '42px' });
    rNrdconta.addClass('rotulo-linha').css({ 'width': '48px' });
    rTpextrat.addClass('rotulo-linha').css({ 'width': '39px' });

    cCddopcao.css({ 'width': '400px' })
    cNrdconta.addClass('conta pesquisa').css({ 'width': '75px' });
    cTpextrat.css({ 'width': '275px' });

    if ($.browser.msie) {
        //	cTpextrat.css({'width':'280px'});
        rTpextrat.addClass('rotulo-linha').css({ 'width': '42px' });
    }

    cTodosCabecalho.desabilitaCampo();
    cCddopcao.habilitaCampo().focus();

    // Se clicar no botao OK
    btnOK1.unbind('click').bind('click', function () {

        controlaOk(1);
        return false;

    });

    // Se clicar no botao OK
    btnOK2.unbind('click').bind('click', function () {

        controlaOk(2);
        return false;

    });

    // Enter Opção
    $('#cddopcao', '#frmCab').unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }
        if (cCddopcao.hasClass('campoTelaSemBorda')) { return false; }

        // Se é a tecla ENTER,
        if (e.keyCode == 9 || e.keyCode == 13) {
            controlaOk(1);
            $('#nrdconta', '#frmCab').focus();
            return false;
        }

    });

    // Enter Conta
    $('#nrdconta', '#frmCab').unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }
        if (!$('#cddopcao', '#frmCab').hasClass('campoTelaSemBorda')) { return false; }

        // Se é a tecla ENTER,
        if (e.keyCode == 9 || e.keyCode == 13) {

            $('#tpextrat', '#frmCab').focus();
            return false;
        }

    });

    // Enter Tipo Extrato
    $('#tpextrat', '#frmCab').unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }
        //if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda') ) { return false; }

        // Se é a tecla ENTER,
        if (e.keyCode == 9 || e.keyCode == 13) {

            controlaOk(2);
            return false;
        }

    });

    layoutPadrao();
    controlaPesquisas();
    return false;
}

function formataDados() {

    $('fieldset').css({ 'clear': 'both', 'border': '1px solid #777', 'margin': '3px 0px', 'padding': '0 3px 5px 3px' });
    $('fieldset > legend').css({ 'font-size': '11px', 'color': '#777', 'margin-left': '5px', 'padding': '0px 2px' });

    rDtrefere.addClass('rotulo').css({ 'width': '53px' });
    rDtreffim.addClass('rotulo-linha').css({ 'width': '85px' });
    rFlgtarif.addClass('rotulo-linha').css({ 'width': '77px' });
    rInrelext.addClass('rotulo').css({ 'width': '53px' });
    rInselext.addClass('rotulo-linha').css({ 'width': '93px' });
    rTpmodelo.addClass('rotulo').css({ 'width': '51px' });
    rNrctremp.addClass('rotulo-linha').css({ 'width': '65px' });
    rNraplica.addClass('rotulo').css({ 'width': '53px' });
    rNranoref.addClass('rotulo-linha').css({ 'width': '69px' });
    rFlgemiss.addClass('rotulo-linha').css({ 'width': '93px' });
    rTpinform.addClass('rotulo').css({ 'width': '53px' });
    rNrperiod.addClass('rotulo-linha').css({ 'width': '65px' });
    rBtnoK3.css({ 'width': '1px' });

    if ($.browser.msie) {
        rFlgemiss.css({ 'width': '95px' });
    }


    if (cTpextrat.val() == 4) {
        cDtrefere.removeClass('data');
        cDtreffim.removeClass('data');

        cDtrefere.addClass('dataMesAno').css({ 'width': '120px' }).attr('maxlength', '7');
        cDtreffim.addClass('dataMesAno').css({ 'width': '120px' }).attr('maxlength', '7');

        if ($.browser.msie) {
            rFlgemiss.addClass('rotulo-linha').css({ 'width': '75px' });
        } else {
            rFlgemiss.addClass('rotulo-linha').css({ 'width': '68px' });
        }

    }
    else {
        cDtrefere.removeClass('dataMesAno');
        cDtreffim.removeClass('dataMesAno');

        cDtrefere.addClass('data').css({ 'width': '120px' }).attr('maxlength', '10');
        cDtreffim.addClass('data').css({ 'width': '120px' }).attr('maxlength', '10');
    }

    cInselext.css({ 'width': '113px' });
    cFlgtarif.css({ 'width': '110px' });
    cInrelext.css({ 'width': '140px' });
    cTpmodelo.css({ 'width': '150px' });
    cTpinform.css({ 'width': '140px' });
    cNrperiod.css({ 'width': '110px' });
    cNrctremp.addClass('pesquisa').css({ 'width': '120px', 'text-align': 'right' }).setMask('INTEGER', 'z.zzz.zzz.zzz', '.', '');
    cNraplica.addClass('pesquisa').css({ 'width': '120px', 'text-align': 'right' }).setMask('INTEGER', 'zzz.zzz', '.', '');
    cNranoref.addClass('inteiro').css({ 'width': '120px' }).attr('maxlength', '4');
    cFlgemiss.css({ 'width': '110px' });

    if ($.browser.msie) {
        cInselext.css({ 'width': '110px' });
        rDtrefere.css({ 'width': '50px' });
        rDtreffim.css({ 'width': '92px' });
        rFlgtarif.css({ 'width': '78px' });
        rInrelext.css({ 'width': '50px' });
        rInselext.css({ 'width': '95px' });
        rTpmodelo.css({ 'width': '51px' });
        rNrctremp.css({ 'width': '72px' });
        rNraplica.css({ 'width': '50px' });
        rNranoref.css({ 'width': '75px' });

    }

    cTodosDados.desabilitaCampo();

    var i = parseInt(cTpextrat.val());
    ocultaCampos(i);

    if (in_array('dtrefere', arrayTipo[i])) { cDtrefere.habilitaCampo(); }
    if (in_array('dtreffim', arrayTipo[i])) { cDtreffim.habilitaCampo(); }
    if (in_array('flgtarif', arrayTipo[i])) { cFlgtarif.habilitaCampo(); }
    if (in_array('inrelext', arrayTipo[i])) { cInrelext.habilitaCampo(); }
    if (in_array('inselext', arrayTipo[i])) { cInselext.habilitaCampo(); }
    if (in_array('tpmodelo', arrayTipo[i])) { cTpmodelo.habilitaCampo(); }
    if (in_array('nrctremp', arrayTipo[i])) { cNrctremp.habilitaCampo(); }
    if (in_array('nraplica', arrayTipo[i])) { cNraplica.habilitaCampo(); }
    if (in_array('tpinform', arrayTipo[i])) { cTpinform.habilitaCampo(); }
    if (in_array('nrperiod', arrayTipo[i])) { cNrperiod.habilitaCampo(); }
    if (in_array('nrrelato', arrayTipo[i])) { cNrrelato.habilitaCampo(); }
    if (in_array('nranoref', arrayTipo[i])) { cNranoref.habilitaCampo(); }
    if (in_array('flgemiss', arrayTipo[i])) { cFlgemiss.habilitaCampo(); }

    $('#' + frmDados).css({ 'display': 'block' });
    $('#' + arrayTipo[i][0], '#' + frmDados).focus();

    // Se clicar no botao OK
    btnOK3.unbind('click').bind('click', function () {
        if (divError.css('display') == 'block') { return false; }
        manterRotina('VO');

        ocultaCampos(cTpextrat.val());
        return false;

    });

    layoutPadrao();
    controlaPesquisas();
    return false;
}

function montarTabela() {

    $('#' + tabDados).html('<div class="divRegistros">' +
	'<table>' +
	'<thead>' +
	'<tr>' +
	'<th>Conta</th>' +
	'<th>Tipo</th>' +
	'<th>Dt. Inic</th>' +
	'<th>Dt. Final</th>' +

	'<th>Trf</th>' +
	'<th>Lista</th>' +
	'<th>Sel</th>' +
	'<th>Contrato</th>' +
	'<th>Aplicac</th>' +
	'<th>Ano</th>' +
	'<th>Quando</th>' +
	'</tr>' +
	'</thead>' +
	'<tbody>' +
	'</tbody>' +
	'</table>' +
	'</div>');

    // insere
    var total = arrayImpres.length - 1;

    for (var i = total; i >= 0; i--) {

        var nrdconta = mascara(arrayImpres[i]['nrdconta'], '####.###-#');
        var tpextrat = arrayImpres[i]['tpextrat'];
        var tpinform = arrayImpres[i]['tpinform'];
        var nrperiod = arrayImpres[i]['nrperiod'];
        var dsextrat = arrayImpres[i]['dsextrat'];
        var dtrefere = arrayImpres[i]['dtrefere'] != '' ? arrayImpres[i]['dtrefere'] : '';
        var dtreffim = arrayImpres[i]['dtreffim'] != '' ? arrayImpres[i]['dtreffim'] : '';
        var tpmodelo = (arrayImpres[i]['tpmodelo'] > 0 && arrayImpres[i]['tpextrat'] > 1) ? arrayImpres[i]['tpmodelo'] : '';
        var flgtarif = (arrayImpres[i]['tpextrat'] == 1 ? (arrayImpres[i]['flgtarif'] == 'no' ? 'Nao' : 'Sim') : '');
        var inrelext = arrayImpres[i]['inrelext'] > 0 ? arrayImpres[i]['inrelext'] : '';
        var inselext = (arrayImpres[i]['inselext'] > 0 && arrayImpres[i]['tpextrat'] > 1) ? arrayImpres[i]['inselext'] : '';
        var nrctremp = arrayImpres[i]['nrctremp'] > 0 ? mascara(arrayImpres[i]['nrctremp'], '####.###') : '';
        var nraplica = arrayImpres[i]['nraplica'] > 0 ? mascara(arrayImpres[i]['nraplica'], '####.###') : '';
        var nranoref = arrayImpres[i]['nranoref'] > 0 ? arrayImpres[i]['nranoref'] : '';
        var flgemiss = arrayImpres[i]['flgemiss'] == 'no' ? 'Process' : '<a href="javascript:Gera_Impressao(\'' + i + '\')"><img src="' + UrlImagens + 'icones/ico_impressora.png" border="0"> Agora</a>';
        $('#tabImpres > div > table > tbody').append('<tr></tr>');
        $('#tabImpres > div > table > tbody > tr:last-child').append('<td>' + nrdconta + '</td>');
        $('#tabImpres > div > table > tbody > tr:last-child').append('<td>' + dsextrat + '</td>');
        $('#tabImpres > div > table > tbody > tr:last-child').append('<td>' + dtrefere + '</td>');
        $('#tabImpres > div > table > tbody > tr:last-child').append('<td>' + dtreffim + '</td>');
        $('#tabImpres > div > table > tbody > tr:last-child').append('<td>' + flgtarif + '</td>');
        $('#tabImpres > div > table > tbody > tr:last-child').append('<td>' + inrelext + '</td>');
        $('#tabImpres > div > table > tbody > tr:last-child').append('<td>' + inselext + '</td>');
        $('#tabImpres > div > table > tbody > tr:last-child').append('<td>' + nrctremp + '</td>');
        $('#tabImpres > div > table > tbody > tr:last-child').append('<td>' + nraplica + '</td>');
        $('#tabImpres > div > table > tbody > tr:last-child').append('<td>' + nranoref + '</td>');
        $('#tabImpres > div > table > tbody > tr:last-child').append('<td>' + flgemiss + '</td>');
    }

    //
    formataTabela();
    $('#' + tabDados).css({ 'display': 'block' });

    return false;
}

function formataTabela() {

    // tabela
    var divRegistro = $('div.divRegistros', '#' + tabDados);
    var tabela = $('table', divRegistro);

    $('#' + tabDados).css({ 'margin-top': '5px' });
    divRegistro.css({ 'height': '160px', 'padding-bottom': '2px' });

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '63px';
    arrayLargura[1] = '34px';
    arrayLargura[2] = '62px';
    arrayLargura[3] = '62px';
    arrayLargura[4] = '25px';
    arrayLargura[5] = '32px';
    arrayLargura[6] = '25px';
    arrayLargura[7] = '52px';
    arrayLargura[8] = '50px';
    arrayLargura[9] = '27px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'right';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'center';
    arrayAlinha[6] = 'center';
    arrayAlinha[7] = 'right';
    arrayAlinha[8] = 'right';
    arrayAlinha[9] = 'center';
    arrayAlinha[10] = 'center';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

    hideMsgAguardo();
    return false;
}

function controlaLayout(operacao) {

    formataCabecalho();
    var dtdozemeses;
    var dtdehoje = dtmvtolt;

    if (cTpextrat.val() == 4) {
        var dtArray = dtmvtolt.split('/');
        dtdehoje = dtArray[1] + "/" + dtArray[2];

        dtCalc = new Date(dtArray[2], dtArray[1], 1);
        dtCalc.setFullYear(dtCalc.getFullYear() - 1);
        dtCalc.setMonth(dtCalc.getMonth() + 1);

        dtnova = dtCalc.getDate() + '/' + dtCalc.getMonth() + '/' + dtCalc.getFullYear();

        var dtArray = dtnova.split('/');

        if (parseInt(dtArray[1]) < 10) {
            dtdozemes = "0" + dtArray[1] + "/" + dtArray[2];
        }
        else {
            dtdozemes = dtArray[1] + "/" + dtArray[2];
        }
    }

    controlaFoco(cTpextrat.val()); // Daniel

    if (operacao == 'VO') {
        $('#cddopcao', '#frmCab').desabilitaCampo;
        $("#btContinuar", "#divBotoes").hide();
    } // Daniel


    if (cddopcao == 'C') {
        arrayImpres = new Array();
        formataTabela();
        $('#' + frmDados).css({ 'display': 'none' });
        $('#divBotoes').css({ 'display': 'block' });
        $('#frmCab').css({ 'display': 'block' });
        $('#tabImpres', '#divTela').css({ 'display': 'block' });
        $("#btContinuar", "#divBotoes").hide();
        $("#btVoltar", "#divBotoes").show();

    } else if ((cddopcao == 'I' || cddopcao == 'E') && operacao == 'VD') {
        hideMsgAguardo();
        $("#btContinuar", "#divBotoes").show();
        $("#btVoltar", "#divBotoes").show();

        if (cTpextrat.val() == '10') {
            manterRotina('VO');
        } else {

            cFlgemiss.val('yes');

            switch (cTpextrat.val()) {
                case '1': cFlgtarif.val('yes'); cInrelext.val('1'); break;
                case '4': cDtreffim.val(dtdehoje); cDtrefere.val(dtdozemes); break;
                case '5': cDtreffim.val(dtmvtolt); break;
                case '8': cFlgemiss.val('yes'); break;
            }

            formataDados();
        }

        cTodosCabecalho.desabilitaCampo();

    } else if ((cddopcao == 'I' || cddopcao == 'E') && (operacao == 'VO' || operacao == 'GD')) {
        hideMsgAguardo();

        if (cddopcao == 'E') { buscarImpresArray(); }

        montarTabela();
        cTodosDados.desabilitaCampo();
        $("#cddopcao", "#frmCab").desabilitaCampo();

        //	estadoCabecalho();

    } else if ((cddopcao == 'I' || cddopcao == 'E') && operacao == 'NO') {
        hideMsgAguardo();
        formataDados();
        arrayImpres.pop(); // remove o ultimo elemento do arrayImpres
    }

    controlaPesquisas();
    return false;
}


// contrato
function mostraContrato() {

    showMsgAguardo('Aguarde, buscando ...');

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/impres/contrato.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground()");
        },
        success: function (response) {
            $('#divRotina').html(response);
            buscaContrato();
            return false;
        }
    });
    return false;

}

function buscaContrato() {

    showMsgAguardo('Aguarde, buscando ...');

    var nrdconta = normalizaNumero(cNrdconta.val());

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/impres/busca_contrato.php',
        data: {
            nrdconta: nrdconta,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground();");
        },
        success: function (response) {

            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divConteudo').html(response);
                    exibeRotina($('#divRotina'));
                    formataContrato();
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

function formataContrato() {

    var divRegistro = $('div.divRegistros', '#divContrato');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({ 'height': '120px', 'width': '500px' });

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '60px';
    arrayLargura[1] = '62px';
    arrayLargura[2] = '80px';
    arrayLargura[3] = '60px';
    arrayLargura[4] = '80px';
    arrayLargura[5] = '38px';


    var arrayAlinha = new Array();
    arrayAlinha[0] = 'right';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'right';
    arrayAlinha[4] = 'right';
    arrayAlinha[5] = 'right';
    arrayAlinha[6] = 'right';

    var metodoTabela = 'selecionaContrato();';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

    hideMsgAguardo();
    bloqueiaFundo($('#divRotina'));

    return false;
}

function selecionaContrato() {

    if ($('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao')) {

        $('table > tbody > tr', 'div.divRegistros').each(function () {
            if ($(this).hasClass('corSelecao')) {
                cNrctremp.val($('#nrctremp', $(this)).val());
                layoutPadrao();
                fechaRotina($('#divRotina'));
                return false;
            }
        });
    }

    return false;
}


// aplicacao
function mostraAplicacao() {

    showMsgAguardo('Aguarde, buscando ...');

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/impres/aplicacao.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground()");
        },
        success: function (response) {
            $('#divRotina').html(response);
            buscaAplicacao();
            return false;
        }
    });
    return false;

}

function buscaAplicacao() {

    showMsgAguardo('Aguarde, buscando ...');

    var nrdconta = normalizaNumero(cNrdconta.val());

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/impres/busca_aplicacao.php',
        data: {
            nrdconta: nrdconta,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground();");
        },
        success: function (response) {

            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divConteudo').html(response);
                    exibeRotina($('#divRotina'));
                    formataAplicacao();
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

function formataAplicacao() {

    var divRegistro = $('div.divRegistros', '#divAplicacao');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({ 'height': '120px', 'width': '320px' });

    var ordemInicial = new Array();
    ordemInicial = [[1, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '55px';
    arrayLargura[1] = '80px';
    arrayLargura[2] = '45px';


    var arrayAlinha = new Array();
    arrayAlinha[0] = 'left';
    arrayAlinha[1] = 'right';
    arrayAlinha[2] = 'left';
    arrayAlinha[3] = 'right';

    var metodoTabela = 'selecionaAplicacao();';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

    hideMsgAguardo();
    bloqueiaFundo($('#divRotina'));

    return false;
}

function selecionaAplicacao() {

    if ($('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao')) {

        $('table > tbody > tr', 'div.divRegistros').each(function () {
            if ($(this).hasClass('corSelecao')) {
                cNraplica.val($('#nraplica', $(this)).val());
                layoutPadrao();
                cNraplica.trigger('blur');
                fechaRotina($('#divRotina'));
                return false;
            }
        });
    }

    return false;
}


// poupanca

function mostraPoupanca() {

    showMsgAguardo('Aguarde, buscando ...');

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/impres/poupanca.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground()");
        },
        success: function (response) {
            $('#divRotina').html(response);
            buscaPoupanca();
            return false;
        }
    });
    return false;

}

function buscaPoupanca() {

    showMsgAguardo('Aguarde, buscando ...');

    var nrdconta = normalizaNumero(cNrdconta.val());

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/impres/busca_poupanca.php',
        data: {
            nrdconta: nrdconta,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground();");
        },
        success: function (response) {

            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divConteudo').html(response);
                    exibeRotina($('#divRotina'));
                    formataPoupanca();
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

function formataPoupanca() {

    var divRegistro = $('div.divRegistros', '#divPoupanca');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({ 'height': '120px', 'width': '400px' });

    var ordemInicial = new Array();
    ordemInicial = [[1, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '70px';
    arrayLargura[1] = '120px';
    arrayLargura[2] = '70px';


    var arrayAlinha = new Array();
    arrayAlinha[0] = 'left';
    arrayAlinha[1] = 'right';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'right';

    var metodoTabela = 'selecionaPoupanca();';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

    hideMsgAguardo();
    bloqueiaFundo($('#divRotina'));

    return false;
}

function selecionaPoupanca() {

    if ($('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao')) {

        $('table > tbody > tr', 'div.divRegistros').each(function () {
            if ($(this).hasClass('corSelecao')) {
                cNraplica.val($('#nrctrrpp', $(this)).val());
                layoutPadrao();
                cNraplica.trigger('blur');
                fechaRotina($('#divRotina'));
                return false;
            }
        });
    }

    return false;
}



// imprimir
function Gera_Impressao(i) {

    $('#nrdconta', '#frmImprimir').val(arrayImpres[i]['nrdconta']);
    $('#idseqttl', '#frmImprimir').val(arrayImpres[i]['idseqttl']);
    $('#tpextrat', '#frmImprimir').val(arrayImpres[i]['tpextrat']);
    $('#dtrefere', '#frmImprimir').val(arrayImpres[i]['dtrefere']);
    $('#dtreffim', '#frmImprimir').val(arrayImpres[i]['dtreffim']);
    $('#flgtarif', '#frmImprimir').val(arrayImpres[i]['flgtarif']);
    $('#inrelext', '#frmImprimir').val(arrayImpres[i]['inrelext']);
    $('#inselext', '#frmImprimir').val(arrayImpres[i]['inselext']);
    $('#tpmodelo', '#frmImprimir').val(arrayImpres[i]['tpmodelo']);
    $('#nrctremp', '#frmImprimir').val(arrayImpres[i]['nrctremp']);
    $('#nraplica', '#frmImprimir').val(arrayImpres[i]['nraplica']);
    $('#nranoref', '#frmImprimir').val(arrayImpres[i]['nranoref']);
    $('#tpinform', '#frmImprimir').val(arrayImpres[i]['tpinform']);
    $('#nrperiod', '#frmImprimir').val(arrayImpres[i]['nrperiod']);

    var action = UrlSite + 'telas/impres/imprimir_dados.php';
    cTodosCabecalho.habilitaCampo();

    carregaImpressaoAyllos("frmImprimir", action);

}


// busca e remove um registro do array
function buscarImpresArray() {

    var qtde = 0;
    var total = arrayImpres.length;

    var nrdconta = normalizaNumero(cNrdconta.val());
    var tpextrat = normalizaNumero(cTpextrat.val());
    var dtrefere = cDtrefere.val();
    var dtreffim = cDtreffim.val();
    var flgtarif = (tpextrat == 10 ? 'yes' : (cFlgtarif.val() == 'yes' ? 'yes' : 'no'));
    var inrelext = normalizaNumero(cInrelext.val());
    var inselext = normalizaNumero(cInselext.val());
    var tpmodelo = normalizaNumero(cTpmodelo.val());
    var nrctremp = normalizaNumero(cNrctremp.val());
    var nraplica = normalizaNumero(cNraplica.val());
    var nranoref = normalizaNumero(cNranoref.val());
    var tpinform = normalizaNumero(cTpinform.val());
    var nrperiod = normalizaNumero(cNrperiod.val());
    var flgemiss = (tpextrat == 10 ? 'yes' : (cFlgemiss.val() == 'yes' ? 'yes' : 'no'));

    for (i = 0; i < total; i++) {

        qtde = 0;

        if (nrdconta == arrayImpres[i]['nrdconta']) { qtde = qtde + 1; } //else { alert(nrdconta +' - ' + arrayImpres[i]['nrdconta']) }
        if (tpextrat == arrayImpres[i]['tpextrat']) { qtde = qtde + 1; } //else { alert(tpextrat +' - ' + arrayImpres[i]['tpextrat']) }
        if (dtrefere == arrayImpres[i]['dtrefere']) { qtde = qtde + 1; } //else { alert(dtrefere +' - ' + arrayImpres[i]['dtrefere']) }
        if (dtreffim == arrayImpres[i]['dtreffim']) { qtde = qtde + 1; } //else { alert(dtreffim +' - ' + arrayImpres[i]['dtreffim']) }
        if (flgtarif == arrayImpres[i]['flgtarif']) { qtde = qtde + 1; } //else { alert(flgtarif +' - ' + arrayImpres[i]['flgtarif']) }
        if (inrelext == arrayImpres[i]['inrelext']) { qtde = qtde + 1; } //else { alert(inrelext +' - ' + arrayImpres[i]['inrelext']) }
        if (inselext == arrayImpres[i]['inselext']) { qtde = qtde + 1; } //else { alert(inselext +' - ' + arrayImpres[i]['inselext']) }
        if (tpmodelo == arrayImpres[i]['tpmodelo']) { qtde = qtde + 1; } //else { alert(inselext +' - ' + arrayImpres[i]['inselext']) }
        if (nrctremp == arrayImpres[i]['nrctremp']) { qtde = qtde + 1; } //else { alert(nrctremp +' - ' + arrayImpres[i]['nrctremp']) }
        if (nraplica == arrayImpres[i]['nraplica']) { qtde = qtde + 1; } //else { alert(nraplica +' - ' + arrayImpres[i]['nraplica']) }
        if (nranoref == arrayImpres[i]['nranoref']) { qtde = qtde + 1; } //else { alert(nranoref +' - ' + arrayImpres[i]['nranoref']) }
        if (flgemiss == arrayImpres[i]['flgemiss']) { qtde = qtde + 1; } //else { alert(flgemiss +' - ' + arrayImpres[i]['flgemiss']) }
        if (tpinform == arrayImpres[i]['tpinform']) { qtde = qtde + 1; } //else { alert(tpinform +' - ' + arrayImpres[i]['tpinform']) }
        if (nrperiod == arrayImpres[i]['nrperiod']) { qtde = qtde + 1; } //else { alert(nrperiod +' - ' + arrayImpres[i]['nrperiod']) }

        if (qtde == 11) { removerImpresArray(i); return false; }

    }

    return false;
}

function removerImpresArray(registro) {

    var total = arrayImpres.length - 1;

    for (i = registro; i < total; i++) {
        arrayImpres[i] = arrayImpres[i + 1];
    }

    arrayImpres.pop();
    return false;
}


// botoes
function btnVoltar() {
    if (cNrdconta.hasClass('campoTelaSemBorda') && cCddopcao.hasClass('campoTelaSemBorda')) {
        arrayImpres.pop();
        estadoCabecalho();
        $('#tabImpres').css('display', 'none');
        $('#frmImpres').css('display', 'none');
    } else {
        arrayImpres.pop();
        estadoInicial();
        $('#tabImpres').css('display', 'none');
        $('#frmImpres').css('display', 'none');
    }

    $("#btContinuar", "#divBotoes").hide();

    controlaPesquisas();
    return false;
}

function btnContinuar() {

    /*
	if ( cCddopcao.hasClass('campo') ) {
		btnOK1.click();

	} else if ( cNrdconta.hasClass('campo') ) {
		btnOK2.click();

	}
	*/
    controlaLayout();
    return false;
}

function trocaBotao(botao) {

    $('#divBotoes', '#divTela').html('');
    $('#divBotoes', '#divTela').append('<input type="image" id="btVoltar" src="../../imagens/botoes/voltar.gif" onClick="btnVoltar(); return false;" />&nbsp;');
    $('#divBotoes', '#divTela').append('<input type="image" id="btSalvar" src="../../imagens/botoes/' + botao + '.gif" onClick="btnContinuar(); return false;"/>');

    return false;
}

function controlaOk(opcao) {

    if (opcao == 1) {
        if (divError.css('display') == 'block') { return false; }
        if (cCddopcao.hasClass('campoTelaSemBorda')) { return false; }

        cddopcao = cCddopcao.val();

        if (cddopcao == 'I' || cddopcao == 'E') {
            estadoCabecalho();

        } else if (cddopcao == 'C') {
            controlaOperacao();
            cTodosCabecalho.desabilitaCampo();

        }

        $('#divBotoes').css({ 'display': 'block' });
        $("#btContinuar", "#divBotoes").hide();
        $("#btVoltar", "#divBotoes").show();

        return false;
    }

    if (opcao == 2) {

        if (divError.css('display') == 'block') { return false; }
        if (cNrdconta.hasClass('campoTelaSemBorda')) { return false; }

        // Verifica se a conta é válida
        if (!validaNroConta(normalizaNumero(cNrdconta.val()))) {
            showError('error', 'Conta/dv inv&aacute;lida.', 'Alerta - Ayllos', 'focaCampoErro(\'nrdconta\',\'' + frmCab + '\');');
            return false;
        }

        // Verifica se a conta é válida
        if (cTpextrat.val() == '0') {
            showError('error', 'Selecione um tipo.', 'Alerta - Ayllos', 'focaCampoErro(\'tpextrat\',\'' + frmCab + '\');');
            return false;
        }

        cTpmodelo.val('1');
        cTodosCabecalho.removeClass('campoErro');
        manterRotina('VD');

        if (cddopcao == 'C') {
            $("#btSalvar", "#divBotoes").hide();

        }


    }

    if (opcao == 3) {
        if (divError.css('display') == 'block') { return false; }
        manterRotina('VO');

        ocultaCampos(cTpextrat.val());
        return false;
    }
}


function controlaFoco(cddopcao) {

    if (cddopcao == 1) {

        $('#dtrefere', '#frmImpres').unbind('keypress').bind('keypress', function (e) {

            if (divError.css('display') == 'block') { return false; }

            if (e.keyCode == 9 || e.keyCode == 13) {
                controlaOk(1);
                $('#dtreffim', '#frmImpres').focus();
                return false;
            }

        });

        $('#dtreffim', '#frmImpres').unbind('keypress').bind('keypress', function (e) {

            if (divError.css('display') == 'block') { return false; }

            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#inrelext', '#frmImpres').focus();
                return false;
            }

        });

        $('#inrelext', '#frmImpres').unbind('keypress').bind('keypress', function (e) {

            if (divError.css('display') == 'block') { return false; }

            if (e.keyCode == 9 || e.keyCode == 13) {
                //	$('#flgtarif','#frmImpres').focus();
                $('#flgemiss', '#frmImpres').focus();
                return false;
            }

        });

        $('#flgtarif', '#frmImpres').unbind('keypress').bind('keypress', function (e) {

            if (divError.css('display') == 'block') { return false; }

            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#flgemiss', '#frmImpres').focus();
                return false;
            }

        });

        $('#flgemiss', '#frmImpres').unbind('keypress').bind('keypress', function (e) {

            if (divError.css('display') == 'block') { return false; }

            if (e.keyCode == 9 || e.keyCode == 13) {
                controlaOk(3);
                return false;
            }

        });


    }

    if (cddopcao == 2) {

        $('#nranoref', '#frmImpres').unbind('keypress').bind('keypress', function (e) {

            if (divError.css('display') == 'block') { return false; }

            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#flgemiss', '#frmImpres').focus();
                return false;
            }

        });

        $('#flgemiss', '#frmImpres').unbind('keypress').bind('keypress', function (e) {

            if (divError.css('display') == 'block') { return false; }

            if (e.keyCode == 9 || e.keyCode == 13) {
                controlaOk(3);
                return false;
            }

        });
    }


    if (cddopcao == 3) {

        $('#inselext', '#frmImpres').unbind('keypress').bind('keypress', function (e) {

            if (divError.css('display') == 'block') { return false; }

            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#nrctremp', '#frmImpres').focus();
                return false;
            }

        });

        $('#nrctremp', '#frmImpres').unbind('keypress').bind('keypress', function (e) {

            if (divError.css('display') == 'block') { return false; }

            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#flgemiss', '#frmImpres').focus();
                return false;
            }

        });

        $('#flgemiss', '#frmImpres').unbind('keypress').bind('keypress', function (e) {

            if (divError.css('display') == 'block') { return false; }

            if (e.keyCode == 9 || e.keyCode == 13) {
                controlaOk(3);
                return false;
            }

        });
    }

    if (cddopcao == 4) {


        $('#tpmodelo', '#frmImpres').unbind('keypress').bind('keypress', function (e) {

            if (divError.css('display') == 'block') { return false; }

            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#dtrefere', '#frmImpres').focus();
                return false;
            }

        });

        $('#dtrefere', '#frmImpres').unbind('keypress').bind('keypress', function (e) {

            if (divError.css('display') == 'block') { return false; }

            if (e.keyCode == 9 || e.keyCode == 13) {
                controlaOk(1);
                $('#dtreffim', '#frmImpres').focus();
                return false;
            }

        });

        $('#dtreffim', '#frmImpres').unbind('keypress').bind('keypress', function (e) {

            if (divError.css('display') == 'block') { return false; }

            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#inselext', '#frmImpres').focus();
                return false;
            }

        });


        $('#inselext', '#frmImpres').unbind('keypress').bind('keypress', function (e) {

            if (divError.css('display') == 'block') { return false; }

            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#nraplica', '#frmImpres').focus();
                return false;
            }

        });

        $('#nraplica', '#frmImpres').unbind('keypress').bind('keypress', function (e) {

            if (divError.css('display') == 'block') { return false; }

            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#flgemiss', '#frmImpres').focus();
                return false;
            }

        });

        $('#flgemiss', '#frmImpres').unbind('keypress').bind('keypress', function (e) {

            if (divError.css('display') == 'block') { return false; }

            if (e.keyCode == 9 || e.keyCode == 13) {
                controlaOk(3);
                return false;
            }

        });
    }

    if (cddopcao == 5) {

        $('#dtrefere', '#frmImpres').unbind('keypress').bind('keypress', function (e) {

            if (divError.css('display') == 'block') { return false; }

            if (e.keyCode == 9 || e.keyCode == 13) {
                controlaOk(1);
                $('#dtreffim', '#frmImpres').focus();
                return false;
            }

        });

        $('#dtreffim', '#frmImpres').unbind('keypress').bind('keypress', function (e) {

            if (divError.css('display') == 'block') { return false; }

            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#inselext', '#frmImpres').focus();
                return false;
            }

        });

        $('#inselext', '#frmImpres').unbind('keypress').bind('keypress', function (e) {

            if (divError.css('display') == 'block') { return false; }

            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#nraplica', '#frmImpres').focus();
                return false;
            }

        });

        $('#nraplica', '#frmImpres').unbind('keypress').bind('keypress', function (e) {

            if (divError.css('display') == 'block') { return false; }

            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#flgemiss', '#frmImpres').focus();
                return false;
            }

        });

        $('#flgemiss', '#frmImpres').unbind('keypress').bind('keypress', function (e) {

            if (divError.css('display') == 'block') { return false; }

            if (e.keyCode == 9 || e.keyCode == 13) {
                controlaOk(3);
                return false;
            }

        });


    }

    if (cddopcao == 6) {

        $('#tpinform', '#frmImpres').unbind('keypress').bind('keypress', function (e) {

            if (divError.css('display') == 'block') { return false; }

            if (e.keyCode == 9 || e.keyCode == 13) {
                if ($('#tpinform', '#frmImpres').val() == 0) { // ANUAL
                    $('#nranoref', '#frmImpres').focus();
                } else {    // TRIMESTRAL
                    $('#nrperiod', '#frmImpres').focus();
                }
                return false;
            }

        });

        $('#nrperiod', '#frmImpres').unbind('keypress').bind('keypress', function (e) {

            if (divError.css('display') == 'block') { return false; }

            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#nranoref', '#frmImpres').focus();
                return false;
            }

        });

        $('#nranoref', '#frmImpres').unbind('keypress').bind('keypress', function (e) {

            if (divError.css('display') == 'block') { return false; }

            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#flgemiss', '#frmImpres').focus();
                return false;
            }

        });

        $('#flgemiss', '#frmImpres').unbind('keypress').bind('keypress', function (e) {

            if (divError.css('display') == 'block') { return false; }

            if (e.keyCode == 9 || e.keyCode == 13) {
                controlaOk(3);
                return false;
            }

        });
    }

    if (cddopcao == 7) {

        $('#dtrefere', '#frmImpres').unbind('keypress').bind('keypress', function (e) {

            if (divError.css('display') == 'block') { return false; }

            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#flgemiss', '#frmImpres').focus();
                return false;
            }

        });

        $('#flgemiss', '#frmImpres').unbind('keypress').bind('keypress', function (e) {

            if (divError.css('display') == 'block') { return false; }

            if (e.keyCode == 9 || e.keyCode == 13) {
                controlaOk(3);
                return false;
            }

        });


    }

    if (cddopcao == 8) {

        $('#dtrefere', '#frmImpres').unbind('keypress').bind('keypress', function (e) {

            if (divError.css('display') == 'block') { return false; }

            if (e.keyCode == 9 || e.keyCode == 13) {
                controlaOk(3);
                return false;
            }

        });

    }

    if (cddopcao == 9) {

        $('#nranoref', '#frmImpres').unbind('keypress').bind('keypress', function (e) {

            if (divError.css('display') == 'block') { return false; }

            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#flgemiss', '#frmImpres').focus();
                return false;
            }

        });

        $('#flgemiss', '#frmImpres').unbind('keypress').bind('keypress', function (e) {

            if (divError.css('display') == 'block') { return false; }

            if (e.keyCode == 9 || e.keyCode == 13) {
                controlaOk(3);
                return false;
            }

        });
    }

    if (cddopcao == 12) {

        $('#nranoref', '#frmImpres').unbind('keypress').bind('keypress', function (e) {

            if (divError.css('display') == 'block') { return false; }

            if (e.keyCode == 9 || e.keyCode == 13) {
                controlaOk(3);
                return false;
            }

        });


    }
}
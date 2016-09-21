/*!
 * FONTE        : cobran.js
 * CRIA��O      : Rogerius Milit�o (DB1) 
 * DATA CRIA��O : 17/04/2015
 * OBJETIVO     : Biblioteca de fun��es da tela COBRAN
 * --------------
 * ALTERA��ES   :
 * --------------
 * [29/03/2012] Rog�rius Milit�o (DB1) : Ajuste no layout padr�o
 * [28/06/2012] Jorge I. H.   (CECRED) : Ajuste em esquema de impressao em funcao Gera_Impressao()
 * [19/10/2012] Jorge I. H.   (CECRED) : Altera��es e ajustes em tela COBRAN  
 * [03/05/2013] Jorge I. H.   (CECRED) : Adicionado campo vldescto em funcao manterRotina(). 
 * [14/08/2013] Carlos        (CECRED) : Altera��o da sigla PAC para PA.
 * [03/12/2014] Jean Reddiga  (RKAM)   : De acordo com a circula 3.656 do Banco Central,substituir nomenclaturas Cedente
 *	             			             por Benefici�rio e  Sacado por Pagador  Chamado 229313 (Jean Reddiga - RKAM).
 * [17/04/2015] Lucas Reinert (CECRED) : Adicionado campo Tp. Emissao. (Reinert)
 * [16/11/2015] Jorge Hamaguchi(CECRED): Adicionado campo Somente Crise. (Jorge/Andrino)
 * 30/12/2015 - Altera��es Referente Projeto Negativa��o Serasa (Daniel)	
 * 09/05/2016 - Adicionar o filtro numero da conta para os tipos: 2 - Numero do Boleto, 3 - Data de Emissao, 4 - Data de Pagamento
 *              5 - Data de Vencimento, 6 - Nome do Pagador (Douglas - Chamado 441759)
 */

//Formul�rios e Tabela
var frmCab = 'frmCab';
var frmOpcao = 'frmOpcao';
var frmTabela = 'frmTabela';

var cddopcao = 'C';
var tpconsul = '';
var flgregis = '';
var inestcri = '';
var consulta = '';
var tprelato = '';

var nrJanelas = 0;
var nriniseq = 1;
var nrregist = 50;
var vrsarqvs = '';
var arquivos = '';
var ni = 0;

var registro;

var cdcooper, nrinssac, nrnosnum, dsdoccop, nmdsacad, flgcbdda, flgreaux, dsendsac, complend, nmbaisac, nmcidsac, cdufsaca, nrcepsac,
	dscjuros, dscmulta, dscdscto, dtdocmto, dsdespec, flgaceit, dsstacom, dtvencto, vltitulo, vldesabt, qtdiaprt, dtdpagto, vldpagto,
	vljurmul, cdbandoc, nrdcoaux, nrcnvcob, cdsituac, dssituac, cdtpinsc, nrdocmto, dsemiten, inserasa, flserasa, qtdianeg;

$(document).ready(function () {
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

    fechaRotina($('#divUsoGenerico'));
    fechaRotina($('#divRotina'));

    $('#' + frmOpcao).remove();
    $('#' + frmTabela).remove();
    $('#divBotoes:eq(0)', '#divTela').remove();
    $('#divPesquisaRodape', '#divTela').remove();

    cCddopcao.val(cddopcao);
    cCddopcao.habilitaCampo().focus();

    removeOpacidade('divTela');
}


// controla
function controlaOperacao(operacao, nriniseq, nrregist) {

    var nrdconta = normalizaNumero($('#nrdconta', '#' + frmOpcao).val());
    var nrdcontx = normalizaNumero($('#nrdcontx', '#' + frmOpcao).val());
    var ininrdoc = normalizaNumero($('#ininrdoc', '#' + frmOpcao).val());
    var fimnrdoc = normalizaNumero($('#fimnrdoc', '#' + frmOpcao).val());
    var nrinssac = $('#nrinssac', '#' + frmOpcao).val();
    var nmprimtl = $('#nmprimtl', '#' + frmOpcao).val();
    var nmprimtx = $('#nmprimtx', '#' + frmOpcao).val();
    var indsitua = $('#indsitua', '#' + frmOpcao).val();
    var numregis = nrregist;
    var iniseque = nriniseq;
    var inidtven = $('#inidtven', '#' + frmOpcao).val();
    var fimdtven = $('#fimdtven', '#' + frmOpcao).val();
    var inidtdpa = $('#inidtdpa', '#' + frmOpcao).val();
    var fimdtdpa = $('#fimdtdpa', '#' + frmOpcao).val();
    var inidtmvt = $('#inidtmvt', '#' + frmOpcao).val();
    var fimdtmvt = $('#fimdtmvt', '#' + frmOpcao).val();
    var consulta = $('#consulta', '#' + frmOpcao).val();
    var tpconsul = $('#tpconsul', '#' + frmOpcao).val();
    var dsdoccop = $('#dsdoccop', '#' + frmOpcao).val();
    var flgregis = $('#flgregis', '#' + frmOpcao).val();
    var inestcri = $('#inestcri', '#' + frmOpcao).val();

    cTodosOpcao.removeClass('campoErro');
	
	var mensagem = 'Aguarde, buscando dados ...';
    showMsgAguardo(mensagem);

    // Carrega dados da conta atrav�s de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobran/principal.php',
        data:
				{
				    operacao: operacao,
				    cddopcao: cddopcao,
				    nrdconta: nrdconta,
				    nrdcontx: nrdcontx,
				    ininrdoc: ininrdoc,
				    fimnrdoc: fimnrdoc,
				    nrinssac: nrinssac,
				    nmprimtl: nmprimtl,
				    nmprimtx: nmprimtx,
				    indsitua: indsitua,
				    numregis: numregis,
				    iniseque: iniseque,
				    inidtven: inidtven,
				    fimdtven: fimdtven,
				    inidtdpa: inidtdpa,
				    fimdtdpa: fimdtdpa,
				    inidtmvt: inidtmvt,
				    fimdtmvt: fimdtmvt,
				    consulta: consulta,
				    tpconsul: tpconsul,
				    dsdoccop: dsdoccop,
				    flgregis: flgregis,
				    inestcri: inestcri,
				    nrregist: nrregist,
				    nriniseq: nriniseq,
				    redirect: 'script_ajax'
				},
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss�vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function (response) {
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
    var nrdcontx = normalizaNumero($('#nrdcontx', '#' + frmOpcao).val());
    var ininrdoc = $('#ininrdoc', '#' + frmOpcao).val();
    var fimnrdoc = $('#fimnrdoc', '#' + frmOpcao).val();
    var nrinssac = $('#nrinssac', '#' + frmOpcao).val();
    var nmprimtl = $('#nmprimtl', '#' + frmOpcao).val();
    var nmprimtx = $('#nmprimtx', '#' + frmOpcao).val();
    var indsitua = $('#indsitua', '#' + frmOpcao).val();
    var numregis = $('#numregis', '#' + frmOpcao).val();
    var iniseque = $('#iniseque', '#' + frmOpcao).val();
    var inidtven = $('#inidtven', '#' + frmOpcao).val();
    var fimdtven = $('#fimdtven', '#' + frmOpcao).val();
    var inidtdpa = $('#inidtdpa', '#' + frmOpcao).val();
    var fimdtdpa = $('#fimdtdpa', '#' + frmOpcao).val();
    var inidtmvt = $('#inidtmvt', '#' + frmOpcao).val();
    var fimdtmvt = $('#fimdtmvt', '#' + frmOpcao).val();
    var consulta = $('#consulta', '#' + frmOpcao).val();
    var tpconsul = $('#tpconsul', '#' + frmOpcao).val();
    var dsdoccop = $('#dsdoccop', '#' + frmOpcao).val();
    var flgregis = $('#flgregis', '#' + frmOpcao).val();
    var inestcri = $('#inestcri', '#' + frmOpcao).val();
    var cdinstru = $('#cdinstru', '#frmConsulta').val();
    var vlabatim = $('#vlabatim', '#frmCampo').val();
    var dtvencto = $('#dtvencto', '#frmCampo').val();
    var vldescto = $('#vldescto', '#frmCampo').val();

    var nmarqint = '';

    if (cddopcao == 'C') {
        nmarqint = $('#nmarqint', '#frmExportar').val();
    } else if (cddopcao == 'I') {
        nmarqint = $('#nmarqint', '#' + frmOpcao).val();
    }

    var mensagem = '';
    fechaRotina($('#divUsoGenerico'));

    switch (operacao) {
        case 'BA': mensagem = 'Aguarde, buscando dados ...'; break;
        case 'EA': mensagem = 'Aguarde, exportando ...'; break;
        case 'VI': mensagem = 'Aguarde, validando dados ...'; break;
        case 'GI': mensagem = 'Aguarde, gravando dados ...'; break;
        case 'IA': mensagem = 'Aguarde, integrando ...'; break;
    }

    cTodosOpcao.removeClass('campoErro');
    showMsgAguardo(mensagem);

    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/cobran/manter_rotina.php',
        data: {
            operacao: operacao,
            cddopcao: cddopcao,
            nrdconta: nrdconta,
            nrdcontx: nrdcontx,
            ininrdoc: ininrdoc,
            fimnrdoc: fimnrdoc,
            nrinssac: nrinssac,
            nmprimtl: nmprimtl,
            nmprimtx: nmprimtx,
            indsitua: indsitua,
            numregis: numregis,
            iniseque: iniseque,
            inidtven: inidtven,
            fimdtven: fimdtven,
            inidtdpa: inidtdpa,
            fimdtdpa: fimdtdpa,
            inidtmvt: inidtmvt,
            fimdtmvt: fimdtmvt,
            consulta: consulta,
            tpconsul: tpconsul,
            dsdoccop: dsdoccop,
            flgregis: flgregis,
            inestcri: inestcri,
            nmarqint: nmarqint,
            cdinstru: cdinstru,
            nrdcoaux: nrdcoaux, // conta
            nrcnvcob: nrcnvcob,
            nrdocmto: nrdocmto,
            cdtpinsc: cdtpinsc,
            vlabatim: vlabatim,
            dtvencto: dtvencto,
            vrsarqvs: vrsarqvs,
            arquivos: arquivos,
            vldescto: vldescto,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function (response) {
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
        linkConta.addClass('lupa').css('cursor', 'auto').unbind('click').bind('click', function () { return false; });
    } else {
        linkConta.css('cursor', 'pointer').unbind('click').bind('click', function () {
            mostraPesquisaAssociado('nrdconta', frmOpcao);
        });
    }


    var linkContx = $('a:eq(1)', '#' + frmOpcao);

    if (linkContx.prev().hasClass('campoTelaSemBorda')) {
        linkContx.addClass('lupa').css('cursor', 'auto').unbind('click').bind('click', function () { return false; });
    } else {
        linkContx.css('cursor', 'pointer').unbind('click').bind('click', function () {
            mostraPesquisaAssociado('nrdcontx', frmOpcao);
        });
    }

    return false;
}


// cabecalho
function formataCabecalho() {

    // Label
    rCddopcao = $('label[for="cddopcao"]', '#' + frmCab);
    rCddopcao.css({ 'width': '51px' }).addClass('rotulo');

    // Input
    cCddopcao = $('#cddopcao', '#' + frmCab);
    cCddopcao.css({ 'width': '581px' });

    // Outros	
    cTodosCabecalho = $('input[type="text"], select', '#' + frmCab);
    btnOK1 = $('#btnOk1', '#' + frmCab);
    cTodosCabecalho.desabilitaCampo();

    // Se clicar no botao OK
    btnOK1.unbind('click').bind('click', function () {

        if (divError.css('display') == 'block') { return false; }
        if (cCddopcao.hasClass('campoTelaSemBorda')) { return false; }

        trocaBotao('Avan�ar');

        //
        cddopcao = cCddopcao.val();

        //
        if (cddopcao == 'I') {
            msgConfirmacao();
        } else {
            buscaOpcao();
        }

        cCddopcao.desabilitaCampo();
        return false;

    });

    // opcao
    cCddopcao.unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        // Se � a tecla ENTER, 
        if (e.keyCode == 13) {
            btnOK1.click();
            return false;
        }
    });

    layoutPadrao();
    controlaPesquisas();
    return false;
}


// opcao
function buscaOpcao() {

    showMsgAguardo('Aguarde, buscando dados ...');

    // Executa script de confirma��o atrav�s de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobran/form_opcao_' + cddopcao.toLowerCase() + '.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N�o foi poss�vel concluir a requisi��o.', 'Alerta - Ayllos', "unblockBackground()");
        },
        success: function (response) {
            $('#divTela').html(response);

            //
            formataCabecalho();

            // 
            cCddopcao.desabilitaCampo();
            cCddopcao.val(cddopcao);

            // limpa formulario
            cTodosOpcao = $('input[type="text"], select', '#' + frmOpcao);
            cTodosOpcao.limpaFormulario().removeClass('campoErro');
            $('#divPesquisaRodape', '#divTela').remove();

            if (cddopcao == 'C') {
                formataOpcaoC();
                cFlgregis.val('no');
                cInestcri.val('0');
                tipoOptionC();

            } else if (cddopcao == 'I') {
                formataOpcaoI();
            } else if (cddopcao == 'R') {
                formataOpcaoR();
            }

            hideMsgAguardo();
            return false;
        }
    });

    return false;

}

function controlaOpcao() {

    formataCabecalho();

    if (cddopcao == 'C') {
        $('#divBotoes:eq(0)', '#divTela').remove();
        formataTabela();
        formataOpcaoC();
        controlaLayoutC();
        $('input, select', '#' + frmOpcao).desabilitaCampo();
        $('#btVoltar', '#divBotoes').focus();
    }

    controlaPesquisas();
    return false;
}


// opcao C
function formataOpcaoC() {

    highlightObjFocus($('#' + frmOpcao));

    // label
    rTpconsul = $('label[for="tpconsul"]', '#' + frmOpcao);
    rConsulta = $('label[for="consulta"]', '#' + frmOpcao);
    rFlgregis = $('label[for="flgregis"]', '#' + frmOpcao);
    rInestcri = $('label[for="inestcri"]', '#' + frmOpcao);

    rTpconsul.css({ 'width': '100px' }).addClass('rotulo');
    rFlgregis.css({ 'width': '150px' }).addClass('rotulo-linha');
    rConsulta.css({ 'width': '100px' }).addClass('rotulo');
    rInestcri.css({ 'width': '150px' }).addClass('rotulo-linha');

    // input
    cTpconsul = $('#tpconsul', '#' + frmOpcao);
    cConsulta = $('#consulta', '#' + frmOpcao);
    cFlgregis = $('#flgregis', '#' + frmOpcao);
    cInestcri = $('#inestcri', '#' + frmOpcao);

    cTpconsul.css({ 'width': '195px' });
    cConsulta.css({ 'width': '195px' });
    cFlgregis.css({ 'width': '65px' });
    cInestcri.css({ 'width': '65px' });

    // Outros	
    cTodosOpcao.habilitaCampo();
    //cConsulta.desabilitaCampo();
    cTpconsul.focus();


    $('#' + frmOpcao + ' fieldset:eq(1)').css({ 'display': 'none' });
    $('#' + frmOpcao + ' fieldset:eq(2)').css({ 'display': 'none' });
    $('#' + frmOpcao + ' fieldset:eq(3)').css({ 'display': 'none' });
    $('#' + frmOpcao + ' fieldset:eq(4)').css({ 'display': 'none' });
    $('#' + frmOpcao + ' fieldset:eq(5)').css({ 'display': 'none' });
    $('#' + frmOpcao + ' fieldset:eq(6)').css({ 'display': 'none' });
    $('#' + frmOpcao + ' fieldset:eq(7)').css({ 'display': 'none' });

    // Consulta
    cTpconsul.unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }

        var auxtpcon = normalizaNumero(cTpconsul.val())

        // Se � a tecla TAB, 
        if ((e.keyCode == 9 || e.keyCode == 13) && validaCampo('tpconsul', auxtpcon)) {
            tipoOptionC();
            cFlgregis.focus();
            return false;
        } else if (e.keyCode == 9 || e.keyCode == 13) {
            return false;
        }
    });

    // cob registrada
    cFlgregis.unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }

        // Se � a tecla TAB, 
        if (e.keyCode == 9 || e.keyCode == 13) {
            cConsulta.focus();
            return false;
        }

    });

    // Tipo 
    cConsulta.unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        // Se � a tecla TAB, 
        if (e.keyCode == 9 || e.keyCode == 13) {
            cInestcri.focus();
            return false;
        }

    });

    // Somente Crise
    cInestcri.unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }

        // Se � a tecla TAB, 
        if (e.keyCode == 9 || e.keyCode == 13) {
            btnContinuar();
            return false;
        }

    });

    layoutPadrao();
    controlaPesquisas();
    return false;

}

function tipoOptionC() {

    tpconsul = cTpconsul.val();
    flgregis = cFlgregis.val();

    var selopc = ($('#consulta', '#' + frmOpcao)) ? $('#consulta', '#' + frmOpcao).val() : 0;

    if (tpconsul > 0 && flgregis) {

        var option = '';

        if (tpconsul == '1') {
            option = option + '<option value="1">1-Numero da Conta</option>';
            option = option + '<option value="2">2-Numero do Boleto</option>';
            option = option + '<option value="8">8-Nro. Conta/Nro. Doc.</option>';

        } else if (tpconsul == '2') {
            option = option + '<option value="1">1-Numero da Conta</option>';
            option = option + '<option value="2">2-Numero do Boleto</option>';
            option = option + '<option value="4">4-Data Pagamento</option>';
            option = option + '<option value="8">8-Nro. Conta/Nro. Doc.</option>';

        } else if (tpconsul == '3') {
            option = option + '<option value="1">1-Numero da Conta</option>';
            option = option + '<option value="2">2-Numero do Boleto</option>';
            option = option + '<option value="3">3-Data Emissao</option>';
            option = option + '<option value="4">4-Data Pagamento</option>';
            option = option + '<option value="5">5-Data Vencimento</option>';
            option = option + '<option value="6">6-Nome do Pagador</option>';
            option = option + '<option value="8">8-Nro. Conta/Nro. Doc.</option>';

        }

        cConsulta.html(option);
        if (selopc > 0) {
            $('#consulta', '#' + frmOpcao).val(selopc);
        }

    }

    return false;

}

function controlaLayoutC() {

    consulta = normalizaNumero(cConsulta.val());

    if (consulta > 0) {

        ni = consulta == 8 ? 7 : consulta;

        cTpconsul.desabilitaCampo();
        cConsulta.desabilitaCampo();
        cFlgregis.desabilitaCampo();
        cInestcri.desabilitaCampo();
        $('#' + frmOpcao + ' fieldset:eq(' + ni + ')').css({ 'display': 'block' });

        if (consulta == '1') {
            formataTipo1();
			// Foco no campo Numero da Conta
			$('#nrdconta', '#' + frmOpcao).focus();

        } else if (consulta == '2') {
			// Mostrar o campo de numero da conta para "2 - Numero do Boleto"
			$('#' + frmOpcao + ' fieldset:eq(1)').css({ 'display': 'block' });
			formataTipo1();
			
            formataTipo2();
			// Foco no campo Numero da Conta
			$('#nrdconta', '#' + frmOpcao).focus();

        } else if (consulta == '3') {
			// Mostrar o campo de numero da conta para "3 - data de Emissao"
			$('#' + frmOpcao + ' fieldset:eq(1)').css({ 'display': 'block' });
			formataTipo1();
			
            formataTipo3();
			// Foco no campo Numero da Conta
			$('#nrdconta', '#' + frmOpcao).focus();
            

        } else if (consulta == '4') {
			// Mostrar o campo de numero da conta para "4 - data de pagamento"
			$('#' + frmOpcao + ' fieldset:eq(1)').css({ 'display': 'block' });
			formataTipo1();
			
            formataTipo4();
			// Foco no campo Numero da Conta
			$('#nrdconta', '#' + frmOpcao).focus();

        } else if (consulta == '5') {
			// Mostrar o campo de numero da conta para "5 - data de Vencimento"
			$('#' + frmOpcao + ' fieldset:eq(1)').css({ 'display': 'block' });
			formataTipo1();
			
            formataTipo5();
			// Foco no campo Numero da Conta
			$('#nrdconta', '#' + frmOpcao).focus();
			
        } else if (consulta == '6') {
			// Mostrar o campo de numero da conta para "6 - Nome do Pagador"
			$('#' + frmOpcao + ' fieldset:eq(1)').css({ 'display': 'block' });
			formataTipo1();
			
            formataTipo6();
			// Foco no campo Numero da Conta
			$('#nrdconta', '#' + frmOpcao).focus();

        } else if (consulta == '8') {
            formataTipo8();
            cNrdconta.habilitaCampo().focus();
        }

        layoutPadrao();
        controlaPesquisas();

    } else {
        showError('error', '329 - Tipo de consulta errado.', 'Alerta - Ayllos', "cConsulta.focus();");
        return false;
    }

    return false;
}

function formataTipo1() {

    // label
    rNrdconta = $('label[for="nrdconta"]', '#' + frmOpcao);
    rNmprimtl = $('label[for="nmprimtx"]', '#' + frmOpcao);

    rNrdconta.css({ 'width': '58px' }).addClass('rotulo');
    rNmprimtl.css({ 'width': '44px' }).addClass('rotulo-linha');

    // input
    cNrdconta = $('#nrdconta', '#' + frmOpcao);
    cNmprimtl = $('#nmprimtx', '#' + frmOpcao);

    cNrdconta.css({ 'width': '75px' }).addClass('pesquisa conta');
    cNmprimtl.css({ 'width': '458px' });

    cNmprimtl.desabilitaCampo();

    // conta
    cNrdconta.unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }

        var auxconta = normalizaNumero(cNrdconta.val());
		var consulta = $('#consulta', '#' + frmOpcao).val();
		
        // Se � a tecla TAB, 
        if (e.keyCode == 9 || e.keyCode == 13) {
			if( auxconta != 0 ){
				if (validaCampo('nrdconta', auxconta)){
					manterRotina('BA');
					return false;
				}
			}
			
			if ( consulta == 2 ) { // 2 - Numero do Boleto
				$('#ininrdoc','#' + frmOpcao).focus();
			} else if ( consulta == 3 ) { // 3 - Data de Emissao
				$('#inidtmvt','#' + frmOpcao).focus();
			} else if ( consulta == 4 ) { // 4 - Data de Pagamento
				$('#inidtdpa','#' + frmOpcao).focus();
			} else if ( consulta == 5 ) { // 5 - Data de Vencimento
				$('#inidtven','#' + frmOpcao).focus();
			} else if ( consulta == 6 ) { // 6 - Nome do Pagador
				$('#nmprimtl','#' + frmOpcao).focus();
			}
			return false;
		}			

    });
	
	cNrdconta.habilitaCampo();

    return false;
}

function formataTipo2() {

    // label
    rIninrdoc = $('label[for="ininrdoc"]', '#' + frmOpcao);
    rFimnrdoc = $('label[for="fimnrdoc"]', '#' + frmOpcao);

    rIninrdoc.css({ 'width': '58px' }).addClass('rotulo');
    rFimnrdoc.css({ 'width': '22px' }).addClass('rotulo-linha');

    // input
    cIninrdoc = $('#ininrdoc', '#' + frmOpcao);
    cFimnrdoc = $('#fimnrdoc', '#' + frmOpcao);

    cIninrdoc.css({ 'width': '83px' }).addClass('inteiro').attr('maxlength', '10');
    cFimnrdoc.css({ 'width': '84px' }).addClass('inteiro').attr('maxlength', '10');

    if (tpconsul == '3') {
        cFimnrdoc.habilitaCampo();
    } else {
        cFimnrdoc.desabilitaCampo();
    }

    // de
    cIninrdoc.unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }

        // Se � a tecla TAB, 
        if ((e.keyCode == 9 || e.keyCode == 13) && tpconsul != '3') {
            btnContinuar();
            return false;
        }

		if (e.keyCode == 9 || e.keyCode == 13) {
            cFimnrdoc.focus();
            return false;
        }		
		
    });

    // ate
    cFimnrdoc.unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }

        // Se � a tecla TAB, 
        if ((e.keyCode == 9 || e.keyCode == 13) && tpconsul == '3') {
            btnContinuar();
            return false;
        }

    });
	
	cIninrdoc.habilitaCampo();

    return false;
}

function formataTipo3() {

    // label
    rInidtmvt = $('label[for="inidtmvt"]', '#' + frmOpcao);
    rFimdtmvt = $('label[for="fimdtmvt"]', '#' + frmOpcao);

    rInidtmvt.css({ 'width': '58px' }).addClass('rotulo');
    rFimdtmvt.css({ 'width': '22px' }).addClass('rotulo-linha');

    // input
    cInidtmvt = $('#inidtmvt', '#' + frmOpcao);
    cFimdtmvt = $('#fimdtmvt', '#' + frmOpcao);

    cInidtmvt.css({ 'width': '83px' }).addClass('data');
    cFimdtmvt.css({ 'width': '84px' }).addClass('data');

    // de
    cInidtmvt.unbind('keydown').bind('keydown', function (e) {
        // Se � a tecla TAB ou ENTER, 
        if (e.keyCode == 9 || e.keyCode == 13) {
            cFimdtmvt.focus();
            return false;
        }

    });
	
    // ate
    cFimdtmvt.unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }

        // Se � a tecla TAB ou ENTER, 
        if (e.keyCode == 9 || e.keyCode == 13) {
            btnContinuar();
            return false;
        }

    });
	
	cInidtmvt.habilitaCampo();
	cFimdtmvt.habilitaCampo();

    return false;
}

function formataTipo4() {

    // label
    rInidtdpa = $('label[for="inidtdpa"]', '#' + frmOpcao);
    rFimdtdpa = $('label[for="fimdtdpa"]', '#' + frmOpcao);

    rInidtdpa.css({ 'width': '58px' }).addClass('rotulo');
    rFimdtdpa.css({ 'width': '22px' }).addClass('rotulo-linha');

    // input
    cInidtdpa = $('#inidtdpa', '#' + frmOpcao);
    cFimdtdpa = $('#fimdtdpa', '#' + frmOpcao);

    cInidtdpa.css({ 'width': '83px' }).addClass('data');
    cFimdtdpa.css({ 'width': '84px' }).addClass('data');
    
    // de
    cInidtdpa.unbind('keydown').bind('keydown', function (e) {
        // Se � a tecla TAB ou ENTER, 
        if (e.keyCode == 9 || e.keyCode == 13) {
            cFimdtdpa.focus();
            return false;
        }

    });
	
	// ate
    cFimdtdpa.unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }

        // Se � a tecla TAB ou ENTER, 
        if (e.keyCode == 9 || e.keyCode == 13) {
            btnContinuar();
            return false;
        }

    });
	
	cInidtdpa.habilitaCampo();
	cFimdtdpa.habilitaCampo();


    return false;
}

function formataTipo5() {

    // label
    rInidtven = $('label[for="inidtven"]', '#' + frmOpcao);
    rFimdtven = $('label[for="fimdtven"]', '#' + frmOpcao);

    rInidtven.css({ 'width': '58px' }).addClass('rotulo');
    rFimdtven.css({ 'width': '22px' }).addClass('rotulo-linha');

    // input
    cInidtven = $('#inidtven', '#' + frmOpcao);
    cFimdtven = $('#fimdtven', '#' + frmOpcao);

    cInidtven.css({ 'width': '83px' }).addClass('data');
    cFimdtven.css({ 'width': '84px' }).addClass('data');

    // de
    cInidtven.unbind('keydown').bind('keydown', function (e) {
        // Se � a tecla TAB ou ENTER, 
        if (e.keyCode == 9 || e.keyCode == 13) {
            cFimdtven.focus();
            return false;
        }

    });
	
    // ate
    cFimdtven.unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }

        // Se � a tecla TAB ou ENTER, 
        if (e.keyCode == 9 || e.keyCode == 13) {
            btnContinuar();
            return false;
        }

    });
	
	cInidtven.habilitaCampo();
	cFimdtven.habilitaCampo();
	
    return false;
}

function formataTipo6() {

    // label
    rNmprimtl = $('label[for="nmprimtl"]', '#' + frmOpcao);
    rNmprimtl.css({ 'width': '58px' }).addClass('rotulo');

    // input
    cNmprimtl = $('#nmprimtl', '#' + frmOpcao);
    cNmprimtl.css({ 'width': '600px' });

    // Pagador
    cNmprimtl.unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }

        var auxnmpri = cNmprimtl.val();

        // Se � a tecla TAB ou ENTER, 
        if ((e.keyCode == 9 || e.keyCode == 13 || typeof e.keyCode == 'undefined') && (validaCampo('nmprimtl', auxnmpri))) {
            controlaOperacao('CB', nriniseq, nrregist);
            return false;
        } else if (e.keyCode == 9 || e.keyCode == 13 || typeof e.keyCode == 'undefined') {
            return false;
        }

    });

	cNmprimtl.habilitaCampo();
	
    return false;
}

function formataTipo8() {

    // label
    rNrdconta = $('label[for="nrdcontx"]', '#' + frmOpcao);
    rNmprimtl = $('label[for="nmprimtl"]', '#' + frmOpcao);
    rDsdoccop = $('label[for="dsdoccop"]', '#' + frmOpcao);

    rNrdconta.css({ 'width': '58px' }).addClass('rotulo');
    rNmprimtl.css({ 'width': '44px' }).addClass('rotulo-linha');
    rDsdoccop.css({ 'width': '55px' }).addClass('rotulo-linha');

    // input
    cNrdconta = $('#nrdcontx', '#' + frmOpcao);
    cNmprimtl = $('#nmprimtl', '#' + frmOpcao);
    cDsdoccop = $('#dsdoccop', '#' + frmOpcao);

    cNrdconta.css({ 'width': '75px' }).addClass('pesquisa conta');
    cNmprimtl.css({ 'width': '303px' });
    cDsdoccop.css({ 'width': '95px' }).attr('maxlength', '12');

    cNmprimtl.desabilitaCampo();
    cDsdoccop.desabilitaCampo();

    if ($.browser.msie) {
        cNmprimtl.css({ 'width': '304px' });
    }

    // conta
    cNrdconta.unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }

        var auxconta = normalizaNumero(cNrdconta.val());

        // Se � a tecla TAB ou ENTER, 
        if ((e.keyCode == 9 || e.keyCode == 13 || typeof e.keyCode == 'undefined') && (validaCampo('nrdconta', auxconta))) {
            manterRotina('BA');
            return false;
        }

    });

    // nr. doc
    cDsdoccop.unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }

        // Se � a tecla TAB ou ENTER, 
        if (e.keyCode == 9 || e.keyCode == 13) {
            btnContinuar();
            return false;
        }

    });

    return false;
}

// opcao C - tabela 
function formataTabela() {

    var divRegistro = $('div.divRegistros', '#' + frmTabela);
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({ 'height': '130px' });

    var ordemInicial = new Array();
    //ordemInicial = [[0,0]];	


    // sem registro
    if (flgregis == 'no') {
        var arrayLargura = new Array();
        arrayLargura[0] = '95px';
        arrayLargura[1] = '65px';
        arrayLargura[2] = '75px';
        arrayLargura[3] = '75px';
        arrayLargura[4] = '95px';
        arrayLargura[5] = '95px';

        var arrayAlinha = new Array();
        arrayAlinha[0] = 'right';
        arrayAlinha[1] = 'right';
        arrayAlinha[2] = 'center';
        arrayAlinha[3] = 'center';
        arrayAlinha[4] = 'right';
        arrayAlinha[5] = 'right';
        arrayAlinha[6] = 'right';

        // com registro
    } else if (flgregis == 'yes') {
        var arrayLargura = new Array();
        arrayLargura[0] = '110px';
        arrayLargura[1] = '95px';
        arrayLargura[2] = '95px';
        arrayLargura[3] = '95px';
        arrayLargura[4] = '95px';

        var arrayAlinha = new Array();
        arrayAlinha[0] = 'right';
        arrayAlinha[1] = 'right';
        arrayAlinha[2] = 'center';
        arrayAlinha[3] = 'center';
        arrayAlinha[4] = 'center';
        arrayAlinha[5] = 'right';

    }

    var metodoTabela = '';
    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);


    /********************
	 FORMATA COMPLEMENTO	
	*********************/
    // complemento linha 1
    var linha1 = $('ul.complemento', '#linha1').css({ 'margin-left': '1px', 'width': '99.5%' });

    $('li:eq(0)', linha1).addClass('txtNormalBold').css({ 'width': '14%', 'text-align': 'right' });
    $('li:eq(1)', linha1).addClass('txtNormal').css({ 'width': '48%' });
    $('li:eq(2)', linha1).addClass('txtNormalBold').css({ 'width': '14%', 'text-align': 'right' });
    $('li:eq(3)', linha1).addClass('txtNormal');

    // complemento linha 2
    var linha2 = $('ul.complemento', '#linha2').css({ 'clear': 'both', 'border-top': '0', 'width': '99.5%' });

    $('li:eq(0)', linha2).addClass('txtNormalBold').css({ 'width': '14%', 'text-align': 'right' });
    $('li:eq(1)', linha2).addClass('txtNormal').css({ 'width': '48%' });
    $('li:eq(2)', linha2).addClass('txtNormalBold').css({ 'width': '14%', 'text-align': 'right' });
    $('li:eq(3)', linha2).addClass('txtNormal');

    // complemento linha 3
    var linha3 = $('ul.complemento', '#linha3').css({ 'clear': 'both', 'border-top': '0', 'width': '99.5%' });

    $('li:eq(0)', linha3).addClass('txtNormalBold').css({ 'width': '14%', 'text-align': 'right' });
    $('li:eq(1)', linha3).addClass('txtNormal').css({ 'width': '48%' });
    $('li:eq(2)', linha3).addClass('txtNormalBold').css({ 'width': '14%', 'text-align': 'right' });
    $('li:eq(3)', linha3).addClass('txtNormal');

    // complemento linha 4
    var linha4 = $('ul.complemento', '#linha4').css({ 'clear': 'both', 'border-top': '0', 'width': '99.5%' });

    $('li:eq(0)', linha4).addClass('txtNormalBold').css({ 'width': '14%', 'text-align': 'right' });
    $('li:eq(1)', linha4).addClass('txtNormal').css({ 'width': '48%' });
    $('li:eq(2)', linha4).addClass('txtNormalBold').css({ 'width': '14%', 'text-align': 'right' });
    $('li:eq(3)', linha4).addClass('txtNormal');

    // complemento linha 5
    var linha5 = $('ul.complemento', '#linha5').css({ 'clear': 'both', 'border-top': '0', 'width': '99.5%' });

    $('li:eq(0)', linha5).addClass('txtNormalBold').css({ 'width': '14%', 'text-align': 'right' });
    $('li:eq(1)', linha5).addClass('txtNormal').css({ 'width': '48%' });
    $('li:eq(2)', linha5).addClass('txtNormalBold').css({ 'width': '14%', 'text-align': 'right' });
    $('li:eq(3)', linha5).addClass('txtNormal');


    /********************
	  EVENTO COMPLEMENTO	
	*********************/

    // seleciona o registro que � clicado
    $('table > tbody > tr', divRegistro).die("click").live("click", function () {
        selecionaTabela($(this));
    });

    // verifica o log do registro com duplo click na linha correspondente
    $('table > tbody > tr', divRegistro).die("dblclick").live("dblclick", function () {
        buscaConsulta('log');
    });

    $('table > tbody > tr:eq(0)', divRegistro).click();

    return false;
}

function selecionaTabela(tr) {
    registro = tr;

    $('#vltitulo', '.complemento').html($('#vltitulo', tr).val());
    $('#nmdsacad', '.complemento').html($('#nmdsacad', tr).val());
    $('#dsdpagto', '.complemento').html($('#dsdpagto', tr).val());
    $('#dsorgarq', '.complemento').html($('#dsorgarq', tr).val());
    $('#nrdctabb', '.complemento').html($('#nrdctabb', tr).val());

    if (flgregis == 'no') {
        $('#dssituac', '.complemento').html($('#dssituac', tr).val());
        $('#dsinssac', '.complemento').html($('#dsinssac', tr).val());
        $('#dtdpagto', '.complemento').html($('#dtdpagto', tr).val());
        $('#dtvencto', '.complemento').html($('#dtvencto', tr).val());
        $('#dsdoccop', '.complemento').html($('#dsdoccop', tr).val());

    } else if (flgregis == 'yes') {
        $('#dssituac', '.complemento').html($('#dssituac', tr).val());
        $('#nrcnvcob', '.complemento').html($('#nrcnvcob', tr).val());
        $('#cdbanpag', '.complemento').html($('#cdbanpag', tr).val());
        $('#nmprimtl', '.complemento').html($('#nmprimtl', tr).val());
        $('#nrnosnum', '.complemento').html($('#nrnosnum', tr).val());

        cdcooper = $('#cdcooper', tr).val();
        nrdcoaux = $('#nrdconta', tr).val();
        cdsituac = $('#cdsituac', tr).val();
        dssituac = $('#dssituac', tr).val();
        nrcnvcob = $('#nrcnvcob', tr).val();
        nrdocmto = $('#nrdocmto', tr).val();
        nrinssac = $('#nrinssac', tr).val();
        nrnosnum = $('#nrnosnum', tr).val();
        dsdoccop = $('#dsdoccop', tr).val();
        nmdsacad = $('#nmdsacad', tr).val();
        flgreaux = $('#flgregis', tr).val();
        flgcbdda = $('#flgcbdda', tr).val();
        dsendsac = $('#dsendsac', tr).val();
        complend = $('#complend', tr).val();
        nmbaisac = $('#nmbaisac', tr).val();
        nmcidsac = $('#nmcidsac', tr).val();
        cdufsaca = $('#cdufsaca', tr).val();
        nrcepsac = $('#nrcepsac', tr).val();
        dscjuros = $('#dscjuros', tr).val();
        dscmulta = $('#dscmulta', tr).val();
        dscdscto = $('#dscdscto', tr).val();
        dtdocmto = $('#dtdocmto', tr).val();
        dsdespec = $('#dsdespec', tr).val();
        flgaceit = $('#flgaceit', tr).val();
        dsemiten = $('#dsemiten', tr).val();
        dsstacom = $('#dsstacom', tr).val();
        dssituac = $('#dssituac', tr).val();
        dtvencto = $('#dtvencto', tr).val();
        vltitulo = $('#vltitulo', tr).val();
        vldesabt = $('#vldesabt', tr).val();
        qtdiaprt = $('#qtdiaprt', tr).val();
        dtdpagto = $('#dtdpagto', tr).val();
        vldpagto = $('#vldpagto', tr).val();
        vljurmul = $('#vljurmul', tr).val();
        cdbandoc = $('#cdbandoc', tr).val();
        cdtpinsc = $('#cdtpinsc', tr).val();
        inserasa = $('#inserasa', tr).val();
        flserasa = $('#flserasa', tr).val();
        qtdianeg = $('#qtdianeg', tr).val();

    }

    return false;
}

// opcao C - consulta
function buscaConsulta(operacao) {

    if (operacao == 'instrucoes' && (cdsituac == 'B' || cdsituac == 'L')) {
        showError('error', 'Opcao nao disponivel para situacao ' + dssituac, 'Alerta - Ayllos', "");
        return false;
    }

    var mensagem = 'Aguarde, buscando dados ...';
    showMsgAguardo(mensagem);

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobran/form_consulta.php',
        data: {
            operacao: operacao,
            nrdconta: nrdcoaux,
            nrcnvcob: nrcnvcob,
            nrdocmto: nrdocmto,
            cdcooper: cdcooper,
            cdbandoc: cdbandoc,
            flserasa: flserasa,
            qtdianeg: qtdianeg,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N�o foi poss�vel concluir a requisi��o.', 'Alerta - Ayllos', "fechaRotina( $(\'#divRotina\') );");
        },
        success: function (response) {

            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divRotina').html(response);
                    exibeRotina($('#divRotina'));
                    formataConsulta();

                    if (operacao == 'log') {
                        formataLog();
                    } else if (operacao == 'instrucoes') {
                        formataInstrucoes();
                    }

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

function formataConsulta() {

    rNrinssac = $('label[for="nrinssac"]', '#frmConsulta');
    rNrnosnum = $('label[for="nrnosnum"]', '#frmConsulta');
    rDsdoccop = $('label[for="dsdoccop"]', '#frmConsulta');
    rNmdsacad = $('label[for="nmdsacad"]', '#frmConsulta');
    rFlgregis = $('label[for="flgregis"]', '#frmConsulta');
    rFlgcbdda = $('label[for="flgcbdda"]', '#frmConsulta');
    rDsendsac = $('label[for="dsendsac"]', '#frmConsulta');
    rComplend = $('label[for="complend"]', '#frmConsulta');
    rNmbaisac = $('label[for="nmbaisac"]', '#frmConsulta');
    rNmcidsac = $('label[for="nmcidsac"]', '#frmConsulta');
    rCdufsaca = $('label[for="cdufsaca"]', '#frmConsulta');
    rNrcepsac = $('label[for="nrcepsac"]', '#frmConsulta');
    rDscjuros = $('label[for="dscjuros"]', '#frmConsulta');
    rDscmulta = $('label[for="dscmulta"]', '#frmConsulta');
    rDscdscto = $('label[for="dscdscto"]', '#frmConsulta');
    rDtdocmto = $('label[for="dtdocmto"]', '#frmConsulta');
    rDsdespec = $('label[for="dsdespec"]', '#frmConsulta');
    rFlgaceit = $('label[for="flgaceit"]', '#frmConsulta');
    rDsemiten = $('label[for="dsemiten"]', '#frmConsulta');
    rDsstacom = $('label[for="dsstacom"]', '#frmConsulta');
    rDssituac = $('label[for="dssituac"]', '#frmConsulta');
    rDtvencto = $('label[for="dtvencto"]', '#frmConsulta');
    rVltitulo = $('label[for="vltitulo"]', '#frmConsulta');
    rVldesabt = $('label[for="vldesabt"]', '#frmConsulta');
    rQtdiaprt = $('label[for="qtdiaprt"]', '#frmConsulta');
    rQtdianeg = $('label[for="qtdianeg"]', '#frmConsulta');
    rDtdpagto = $('label[for="dtdpagto"]', '#frmConsulta');
    rVldpagto = $('label[for="vldpagto"]', '#frmConsulta');
    rVljurmul = $('label[for="vljurmul"]', '#frmConsulta');
    rCdbandoc = $('label[for="cdbandoc"]', '#frmConsulta');


    rNrinssac.addClass('rotulo').css({ 'width': '61px' });
    rNrnosnum.addClass('rotulo-linha').css({ 'width': '80px' });
    rDsdoccop.addClass('rotulo-linha').css({ 'width': '70px' });
    rNmdsacad.addClass('rotulo').css({ 'width': '61px' });
    rFlgregis.addClass('rotulo-linha').css({ 'width': '70px' });
    rFlgcbdda.addClass('rotulo-linha').css({ 'width': '33px' });
    rDsendsac.addClass('rotulo').css({ 'width': '61px' });
    rComplend.addClass('rotulo-linha').css({ 'width': '70px' });
    rNmbaisac.addClass('rotulo').css({ 'width': '61px' });
    rNmcidsac.addClass('rotulo-linha').css({ 'width': '80px' });
    rCdufsaca.addClass('rotulo-linha').css({ 'width': '70px' });
    rNrcepsac.addClass('rotulo-linha').css({ 'width': '30px' });
    rDscjuros.addClass('rotulo').css({ 'width': '61px' });
    rDscmulta.addClass('rotulo-linha').css({ 'width': '80px' });
    rDscdscto.addClass('rotulo-linha').css({ 'width': '70px' });
    rDtdocmto.addClass('rotulo').css({ 'width': '61px' });
    rDsdespec.addClass('rotulo-linha').css({ 'width': '55px' });
    rFlgaceit.addClass('rotulo-linha').css({ 'width': '40px' });
    rDsemiten.addClass('rotulo-linha').css({ 'width': '78px' });
    rDsstacom.addClass('rotulo-linha').css({ 'width': '46px' });
    rDssituac.addClass('rotulo-linha').css({ 'width': '41px' });
    rDtvencto.addClass('rotulo').css({ 'width': '61px' });
    rVltitulo.addClass('rotulo-linha').css({ 'width': '55px' });
    rVldesabt.addClass('rotulo-linha').css({ 'width': '78px' });
    rQtdiaprt.addClass('rotulo-linha').css({ 'width': '41px' });
    rQtdianeg.addClass('rotulo-linha').css({ 'width': '41px' });
    rDtdpagto.addClass('rotulo').css({ 'width': '61px' });
    rVldpagto.addClass('rotulo-linha').css({ 'width': '55px' });
    rVljurmul.addClass('rotulo-linha').css({ 'width': '78px' });
    rCdbandoc.addClass('rotulo-linha').css({ 'width': '41px' });

    cNrinssac = $('#nrinssac', '#frmConsulta');
    cNrnosnum = $('#nrnosnum', '#frmConsulta');
    cDsdoccop = $('#dsdoccop', '#frmConsulta');
    cNmdsacad = $('#nmdsacad', '#frmConsulta');
    cFlgregis = $('#flgregis', '#frmConsulta');
    cFlgcbdda = $('#flgcbdda', '#frmConsulta');
    cDsendsac = $('#dsendsac', '#frmConsulta');
    cComplend = $('#complend', '#frmConsulta');
    cNmbaisac = $('#nmbaisac', '#frmConsulta');
    cNmcidsac = $('#nmcidsac', '#frmConsulta');
    cCdufsaca = $('#cdufsaca', '#frmConsulta');
    cNrcepsac = $('#nrcepsac', '#frmConsulta');
    cDscjuros = $('#dscjuros', '#frmConsulta');
    cDscmulta = $('#dscmulta', '#frmConsulta');
    cDscdscto = $('#dscdscto', '#frmConsulta');
    cDtdocmto = $('#dtdocmto', '#frmConsulta');
    cDsdespec = $('#dsdespec', '#frmConsulta');
    cDsemiten = $('#dsemiten', '#frmConsulta');
    cFlgaceit = $('#flgaceit', '#frmConsulta');
    cDsstacom = $('#dsstacom', '#frmConsulta');
    cDssituac = $('#dssituac', '#frmConsulta');
    cDtvencto = $('#dtvencto', '#frmConsulta');
    cVltitulo = $('#vltitulo', '#frmConsulta');
    cVldesabt = $('#vldesabt', '#frmConsulta');
    cQtdiaprt = $('#qtdiaprt', '#frmConsulta');
    cQtdianeg = $('#qtdianeg', '#frmConsulta');
    cDtdpagto = $('#dtdpagto', '#frmConsulta');
    cVldpagto = $('#vldpagto', '#frmConsulta');
    cVljurmul = $('#vljurmul', '#frmConsulta');
    cCdbandoc = $('#cdbandoc', '#frmConsulta');
    cInserasa = $('#inserasa', '#frmConsulta');

    cNrinssac.val(nrinssac).css({ 'width': '140px' });
    cNrnosnum.val(nrnosnum).css({ 'width': '140px' });
    cDsdoccop.val(dsdoccop).css({ 'width': '140px' });
    cNmdsacad.val(nmdsacad).css({ 'width': '366px' });
    cFlgregis.val(flgreaux).css({ 'width': '50px' });
    cFlgcbdda.val(flgcbdda).css({ 'width': '50px' });
    cDsendsac.val(dsendsac).css({ 'width': '366px' });
    cComplend.val(complend).css({ 'width': '140px' });
    cNmbaisac.val(nmbaisac).css({ 'width': '140px' });
    cNmcidsac.val(nmcidsac).css({ 'width': '140px' });
    cCdufsaca.val(cdufsaca).css({ 'width': '30px' });
    cNrcepsac.val(nrcepsac).css({ 'width': '74px' });
    cDscjuros.val(dscjuros).css({ 'width': '140px' });
    cDscmulta.val(dscmulta).css({ 'width': '140px' });
    cDscdscto.val(dscdscto).css({ 'width': '140px' });
    cDtdocmto.val(dtdocmto).css({ 'width': '90px' });
    cDsdespec.val(dsdespec).css({ 'width': '44px' });
    cFlgaceit.val(flgaceit).css({ 'width': '20px' });
    cDsemiten.val(dsemiten).css({ 'width': '90px' });
    cDsstacom.val(dsstacom).css({ 'width': '100px' });
    cDssituac.val(dssituac).css({ 'width': '100px' });
    cDtvencto.val(dtvencto).css({ 'width': '90px' });
    cVltitulo.val(vltitulo).css({ 'width': '110px' });
    cVldesabt.val(vldesabt).css({ 'width': '90px' });
    cQtdiaprt.val(qtdiaprt).css({ 'width': '100px' });
    cQtdianeg.val(qtdianeg).css({ 'width': '100px' });
    cDtdpagto.val(dtdpagto).css({ 'width': '90px' });
    cVldpagto.val(vldpagto).css({ 'width': '110px' });
    cVljurmul.val(vljurmul).css({ 'width': '90px' });
    cCdbandoc.val(cdbandoc).css({ 'width': '100px' });

    cInserasa.val(inserasa);

    cTodosConsulta = $('input[type="text"],select', '#frmConsulta');
    cTodosConsulta.desabilitaCampo();

    // centraliza a divRotina
    $('#divRotina').css({ 'width': '680px' });
    $('#divConteudo').css({ 'width': '665px' });
    $('#divRotina').centralizaRotinaH();

    layoutPadrao();
    hideMsgAguardo();
    bloqueiaFundo($('#divRotina'));
    return false;
}

function formataLog() {

    var divRegistro = $('div.divRegistros', '#frmConsulta');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({ 'height': '100px' });

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '85px';
    arrayLargura[1] = '350px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'left';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'left';

    var metodoTabela = '';
    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

    return false;
}

function formataInstrucoes(operacao) {

    highlightObjFocus($('#frmConsulta'));

    // Label
    rCdinstru = $('label[for="cdinstru"]', '#frmConsulta');
    rCdinstru.css({ 'width': '60px' }).addClass('rotulo');

    cCdinstru = $('#cdinstru', '#frmConsulta');
    cCdinstru.css({ 'width': '548px' });

    // Outros	
    btnOK2 = $('#btnOk2', '#frmConsulta');
    cCdinstru.habilitaCampo();

    // Se clicar no botao OK
    btnOK2.unbind('click').bind('click', function () {

        if (divError.css('display') == 'block') { return false; }
        if (cCdinstru.hasClass('campoTelaSemBorda')) { return false; }

        if (cCdinstru.val() > 0) {
            manterRotina('VI');
        }

        return false;

    });

    return false;
}

function buscaCampo() {

    var cdinstru = $('#cdinstru', '#frmConsulta').val();
    var mensagem = 'Aguarde, buscando dados ...';
    showMsgAguardo(mensagem);

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobran/form_campo.php',
        data: {
            cdinstru: cdinstru,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N�o foi poss�vel concluir a requisi��o.', 'Alerta - Ayllos', "fechaRotina( $(\'#divUsoGenerico\') ); bloqueiaFundo($(\'#divRotina\')); ");
        },
        success: function (response) {

            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divUsoGenerico').html(response);
                    exibeRotina($('#divUsoGenerico'));
                    formataCampo();

                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'fechaRotina( $(\'#divUsoGenerico\') ); bloqueiaFundo($(\'#divRotina\')); ');
                }
            } else {
                try {
                    eval(response);
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'fechaRotina( $(\'#divUsoGenerico\') ); bloqueiaFundo($(\'#divRotina\')); ');
                }
            }



        }
    });
    return false;
}

function formataCampo() {

    highlightObjFocus($('#frmCampo'));

    rVlabatim = $('label[for="vlabatim"]', '#frmCampo');
    rDtvencto = $('label[for="dtvencto"]', '#frmCampo');

    rVlabatim.css({ 'width': '152px' }).addClass('rotulo-linha');
    rDtvencto.css({ 'width': '152px' }).addClass('rotulo-linha');

    // Input
    cVlabatim = $('#vlabatim', '#frmCampo');
    cDtvencto = $('#dtvencto', '#frmCampo');

    cVlabatim.css({ 'width': '120px' }).addClass('monetario');
    cDtvencto.css({ 'width': '120px' }).addClass('data');

    cVlabatim.habilitaCampo().focus();
    cDtvencto.habilitaCampo().focus();

    // centraliza a divUsoGenerico
    $('#divUsoGenerico').css({ 'width': '375px' });
    $('#divCampo').css({ 'width': '350px', 'height': '90px' });
    $('#divUsoGenerico').centralizaRotinaH();

    hideMsgAguardo();
    bloqueiaFundo($('#divUsoGenerico'));
    layoutPadrao();
    return false;
}

// opcao C - exportar
function formataExportar() {

    highlightObjFocus($('#frmExportar'));

    rNmarqint = $('label[for="nmarqint"]', '#frmExportar');
    cNmarqint = $('#nmarqint', '#frmExportar');

    rNmarqint.addClass('rotulo').css({ 'width': '55px' });
    cNmarqint.addClass('campo').css({ 'width': '420px' }).attr('maxlength', '60');

    cNmarqint.focus();

    // centraliza a divUsoGenerico
    $('#divRotina').css({ 'width': '525px' });
    $('#divConteudo').css({ 'width': '500px', 'height': '90px' });
    $('#divRotina').centralizaRotinaH();

    $('fieldset', '#frmExportar').css({ 'padding': '3px' });

    // conta
    $('#btContinuar', '#divRotina').unbind('click').bind('click', function () {
        if (divError.css('display') == 'block') { return false; }

        if (cNmarqint.val() == '') {
            showError('error', '375 - O campo deve ser preenchido.', 'Alerta - Ayllos', 'bloqueiaFundo( $(\'#divRotina\') );');
        } else {
            manterRotina('EA');
        }

    });

    layoutPadrao();
    hideMsgAguardo();
    bloqueiaFundo($('#divRotina'));
    return false;
}

function buscaExportar() {

    var mensagem = 'Aguarde, buscando dados ...';

    showMsgAguardo(mensagem);

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobran/form_exportar.php',
        data: {
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N�o foi poss�vel concluir a requisi��o.', 'Alerta - Ayllos', "fechaRotina( $(\'#divRotina\') );");
        },
        success: function (response) {

            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divRotina').html(response);
                    exibeRotina($('#divRotina'));
                    formataExportar();
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



// opcao I
function formataOpcaoI() {

    highlightObjFocus($('#frmOpcao'));

    cNmarqint = $('#nmarqint', '#frmOpcao');
    cNmarqint.addClass('campo alphanumlower').css({ 'width': '660px', 'text-transform': 'lowercase' }).attr('maxlength', '60');
    cNmarqint.focus();

    cNmarqint.unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }

        // Se apertou enter 
        if (e.keyCode == 13) {
            btnContinuar();
            return false;
        }
    });

    if (vrsarqvs == 'yes') {
        $('legend', '#frmOpcao').html('Caminho dos Arquivos que Serao Integrados');
    } else if (vrsarqvs == 'no') {
        $('legend', '#frmOpcao').html('Nome do Arquivo a ser Integrado');
    }

    layoutPadrao();
    return false;
}

// opcao I - arquivo
function formataArquivo() {

    highlightObjFocus($('#frmArquivo'));

    var divRegistro = $('div.divRegistros', '#frmArquivo');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({ 'height': '130px' });

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '20px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'left';

    var metodoTabela = '';
    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

    // centraliza a divUsoGenerico
    $('#divRotina').css({ 'width': '375px' });
    $('#divConteudo').css({ 'width': '350px' });
    $('#divRotina').centralizaRotinaH();

    $('fieldset', '#frmArquivo').css({ 'padding': '3px' });

    // conta

    $('#btContinuar', '#divRotina').unbind('click').bind('click', function () {
        if (divError.css('display') == 'block') { return false; }

        if (cNmarqint.val() == '') {
            showError('error', '375 - O campo deve ser preenchido.', 'Alerta - Ayllos', 'bloqueiaFundo( $(\'#divRotina\') );');
        } else {
            salvaArquivo();
        }

    });


    layoutPadrao();
    hideMsgAguardo();
    bloqueiaFundo($('#divRotina'));
    return false;
}

function buscaArquivo() {

    var nmarqint = $('#nmarqint', '#' + frmOpcao).val();
    var mensagem = 'Aguarde, buscando dados ...';
    showMsgAguardo(mensagem);

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobran/tab_arquivo.php',
        data: {
            nmarqint: nmarqint,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N�o foi poss�vel concluir a requisi��o.', 'Alerta - Ayllos', "fechaRotina( $(\'#divRotina\') );");
        },
        success: function (response) {

            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divRotina').html(response);
                    exibeRotina($('#divRotina'));
                    formataArquivo();
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

function salvaArquivo() {

    arquivos = '';

    $('#arquivos:checked', '#frmArquivo').each(function () {
        if (arquivos == '') {
            arquivos = $(this).val();
        } else {
            arquivos = arquivos + ';' + $(this).val();
        }
    });


    if (arquivos != '') {
        fechaRotina($('#divRotina'));
        msgConfirmacao();
    }

    return false;
}



// opcao R
function formataOpcaoR() {

    highlightObjFocus($('#' + frmOpcao));

    /*****************
		FIELDSET 1
	******************/
    // label
    rFlgregis = $('label[for="flgregis"]', '#' + frmOpcao);
    rTprelato = $('label[for="tprelato"]', '#' + frmOpcao);

    rFlgregis.css({ 'width': '65px' }).addClass('rotulo');
    rTprelato.css({ 'width': '65px' }).addClass('rotulo-linha');

    // input
    cFlgregis = $('#flgregis', '#' + frmOpcao);
    cTprelato = $('#tprelato', '#' + frmOpcao);

    cFlgregis.css({ 'width': '65px' });
    cTprelato.css({ 'width': '458px' });

    /*****************
		FIELDSET 2
	******************/
    // label
    rInidtmvt = $('label[for="inidtmvt"]', '#' + frmOpcao);
    rFimdtmvt = $('label[for="fimdtmvt"]', '#' + frmOpcao);
    rCdstatus = $('label[for="cdstatus"]', '#' + frmOpcao);
    rNrdconta = $('label[for="nrdconta"]', '#' + frmOpcao);
    rCdagenci = $('label[for="cdagenci"]', '#' + frmOpcao);
    rNmprimtl = $('label[for="nmprimtl"]', '#' + frmOpcao);
    rInserasa = $('label[for="inserasa"]', '#' + frmOpcao);

    rInidtmvt.css({ 'width': '53px' }).addClass('rotulo');
    rFimdtmvt.css({ 'width': '20px' }).addClass('rotulo-linha');
    rCdstatus.css({ 'width': '66px' }).addClass('rotulo-linha');
    rInserasa.css({ 'width': '105px' }).addClass('rotulo-linha');
    rNrdconta.css({ 'width': '50px' }).addClass('rotulo-linha');
    rCdagenci.css({ 'width': '38px' }).addClass('rotulo-linha');
    rNmprimtl.css({ 'width': '53px' }).addClass('rotulo-linha');

    // input
    cInidtmvt = $('#inidtmvt', '#' + frmOpcao);
    cFimdtmvt = $('#fimdtmvt', '#' + frmOpcao);
    cCdstatus = $('#cdstatus', '#' + frmOpcao);
    cNrdconta = $('#nrdconta', '#' + frmOpcao);
    cCdagenci = $('#cdagenci', '#' + frmOpcao);
    cNmprimtl = $('#nmprimtl', '#' + frmOpcao);
    cInserasa = $('#inserasa', '#' + frmOpcao);

    cInidtmvt.css({ 'width': '75px' }).addClass('data');
    cFimdtmvt.css({ 'width': '75px' }).addClass('data');
    cCdstatus.css({ 'width': '100px' });
    cNrdconta.css({ 'width': '75px' }).addClass('conta pesquisa');
    cCdagenci.css({ 'width': '40px' }).addClass('inteiro').attr('maxlength', '3');
    cNmprimtl.css({ 'width': '350px' });

    if ($.browser.msie) {
        cTprelato.css({ 'width': '462px' });
        rCdstatus.css({ 'width': '68px' });
        rNrdconta.css({ 'width': '64px' });
        rCdagenci.css({ 'width': '55px' });
    }

    // Outros	
    cTodosOpcao.habilitaCampo();
    tipoOptionR();
    cFlgregis.focus();

    $('#' + frmOpcao + ' fieldset:eq(0)').css({ 'display': 'block' });
    $('#' + frmOpcao + ' fieldset:eq(1)').css({ 'display': 'none' });

    // cob. regis
    cFlgregis.unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }

        // Se � a tecla TAB, 
        if (e.keyCode == 9 || e.keyCode == 13) {
            tipoOptionR();
            cTprelato.habilitaCampo().focus();
            return false;
        }
    });


    // relatorio
    cTprelato.unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }

        // Se � a tecla TAB, 
        if (e.keyCode == 9 || e.keyCode == 13) {
            btnContinuar();
            return false;
        }

    });

    // relatorio
    cInidtmvt.unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }

        // Se � a tecla TAB, 
        if (e.keyCode == 9 || e.keyCode == 13) {
            cFimdtmvt.focus();
            return false;
        }

    });

    //
    cFimdtmvt.unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }

        // Se � a tecla TAB, 
        if (e.keyCode == 9 || e.keyCode == 13) {

            if (cTprelato.val() == '1' || cTprelato.val() == '3') {
                btnContinuar();
                return false;
            } else if (cTprelato.val() == '2' || cTprelato.val() == '4' || cTprelato.val() == '6') {
                cNrdconta.focus();
                return false;
            } else if (cTprelato.val() == '5') {
                cCdstatus.focus();
                return false;
            }

        }

    });

    // status
    cCdstatus.unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }

        // Se � a tecla TAB, 
        if (e.keyCode == 9 || e.keyCode == 13) {
            cInserasa.focus();
            return false;
        }

    });

    cInserasa.unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }

        // Se � a tecla TAB, 
        if (e.keyCode == 9 || e.keyCode == 13) {
            cNrdconta.focus();
            return false;
        }

    });

    // conta
    cNrdconta.unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }

        var auxconta = normalizaNumero(cNrdconta.val());

        // Se � a tecla TAB, 
        if (e.keyCode == 9 || e.keyCode == 13 || typeof e.keyCode == 'undefined') {

            if (tprelato == 6 && normalizaNumero(cNrdconta.val()) == 0) {
                cNrdconta.desabilitaCampo();
                cCdagenci.habilitaCampo().focus();
            } else if (validaCampo('nrdconta', auxconta)) {
                manterRotina('BA');
            }

            controlaPesquisas();
            return false;
        }

    });


    layoutPadrao();
    controlaPesquisas();
    return false;

}

function tipoOptionR() {

    flgregis = cFlgregis.val();

    var selopc = ($('#tprelato', '#' + frmOpcao)) ? $('#tprelato', '#' + frmOpcao).val() : 0;

    if (flgregis) {

        var option = '';

        if (flgregis == 'yes') {
            option = option + '<option value="5">5- Relatorio Beneficiario</option>';
            option = option + '<option value="6">6- Relatorio Movimento de Cobranca Registrada</option>';

        } else if (flgregis == 'no') {
            option = option + '<option value="1">1- Gestao da carteira de cobranca sem registro - Por PA</option>';
            option = option + '<option value="2">2- Gestao da carteira de cobranca sem registro - Por Cooperado</option>';
            option = option + '<option value="3">3- Gestao da carteira de cobranca sem registro - Por Convenio</option>';
            option = option + '<option value="4">4- Relatorio Movimento de liquidacoes - Francesa(S/ Registro)</option>';

        }

        cTprelato.html(option);
        if (selopc > 0) {
            $('#tprelato', '#' + frmOpcao).val(selopc);
        }

    }

    return false;

}

function controlaLayoutR() {

    tprelato = cTprelato.val();
    cTodosOpcao.desabilitaCampo();
    cInidtmvt.habilitaCampo();
    cFimdtmvt.habilitaCampo();

    $('#divInserasa').css({ 'display': 'none' });

    if (tprelato == '2') {
        cNrdconta.habilitaCampo();

    } if (tprelato == '4') {
        cNrdconta.habilitaCampo();

    } else if (tprelato == '5') {
        $('#divInserasa').css({ 'display': 'block' });
        cCdstatus.habilitaCampo();
        cNrdconta.habilitaCampo();
        cInserasa.habilitaCampo();

    } else if (tprelato == '6') {
        cNrdconta.habilitaCampo();
        //cCdagenci.habilitaCampo();	
    }

    $('#' + frmOpcao + ' fieldset:eq(1)').css({ 'display': 'block' });
    cInidtmvt.focus();
    controlaPesquisas();
    return false;
}



// imprimir
function Gera_Impressao(nmarqpdf) {

    cTodosOpcao.habilitaCampo();

    $('#cddopcao', '#' + frmOpcao).val(cddopcao);
    $('#nmarqpdf', '#' + frmOpcao).val(nmarqpdf);

    var action = UrlSite + 'telas/cobran/imprimir_opcao_' + cddopcao.toLowerCase() + '.php';
    var callafter = "";

    if (cddopcao == 'R') {
        callafter = "estadoInicial();";
    }

    carregaImpressaoAyllos(frmOpcao, action, callafter);

}

function mostraImprimir(arquivo1, arquivo2) {

    var mensagem = 'Aguarde, buscando dados ...';
    showMsgAguardo(mensagem);

    // Executa script de confirma��o atrav�s de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobran/form_imprimir.php',
        data: {
            arquivo1: arquivo1,
            arquivo2: arquivo2,
            redirect: 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N�o foi poss�vel concluir a requisi��o.', 'Alerta - Ayllos', "unblockBackground()");
        },
        success: function (response) {
            hideMsgAguardo();

            $('#divRotina').html(response);
            exibeRotina($('#divRotina'));

            formataImprimir();
            return false;
        }
    });
    return false;

}

function formataImprimir() {

    $('#arquivo1', '#frmImprimir').css({ 'width': '95%', 'height': '25px', 'cursor': 'pointer', 'margin': '9px' });
    $('#arquivo2', '#frmImprimir').css({ 'width': '95%', 'height': '25px', 'cursor': 'pointer', 'margin': '9px' });

    if ($.browser.msie) {
        $('#arquivo1', '#frmImprimir').css({ 'margin-top': '11px' });
        $('#arquivo2', '#frmImprimir').css({ 'margin-top': '11px' });
    }

    // centraliza a divRotina
    $('#divRotina').css({ 'width': '355px' });
    $('#divConteudo').css({ 'width': '330px' });
    $('#divRotina').centralizaRotinaH();

    layoutPadrao();
    hideMsgAguardo();
    bloqueiaFundo($('#divRotina'));
    return false;
}


// valida
function validaCampo(campo, valor) {

    // conta
    if (campo == 'nrdconta' && !validaNroConta(valor)) {
        showError('error', 'D�gito errado.', 'Alerta - Ayllos', '$(\'#' + campo + '\',\'#frmOpcao\').focus();');
        return false;
    } else if (campo == 'nmprimtl' && valor == '') {
        showError('error', 'O campo deve ser preenchido.', 'Alerta - Ayllos', '$(\'#' + campo + '\',\'#frmOpcao\').focus();');
        return false;
    } else if (campo == 'tpconsul' && (valor < 1 || valor > 3)) {
        showError('error', 'Tipo de consulta errado.', 'Alerta - Ayllos', '$(\'#' + campo + '\',\'#frmOpcao\').focus();');
        return false;
    }

    return true;
}


// mensagem
function msgConfirmacao() {
    if (cddopcao == 'C') {
        var cdinstru = $('#cdinstru', '#frmConsulta').val();
        showConfirmacao('Confirma execucao Instrucao ' + cdinstru + ' ?', 'Confirma&ccedil;&atilde;o - Ayllos', 'manterRotina(\'GI\');', 'bloqueiaFundo( $(\'#divRotina\') );', 'sim.gif', 'nao.gif');
    } else if (cddopcao == 'I' && isHabilitado(cCddopcao)) {
        showConfirmacao('Importar varios arquivos ?', 'Confirma&ccedil;&atilde;o - Ayllos', 'vrsarqvs=\'yes\'; buscaOpcao();', 'vrsarqvs=\'no\'; buscaOpcao();', 'sim.gif', 'nao.gif');
    } else if (cddopcao == 'I' && isHabilitado($('#nmarqint', '#' + frmOpcao))) {
        showConfirmacao('Confirma a operacao ?', 'Confirma&ccedil;&atilde;o - Ayllos', 'manterRotina(\'IA\');', '', 'sim.gif', 'nao.gif');
    }

    return false;
}


// botoes
function btnVoltar() {

    if (cddopcao === 'C' && $('#frmTabela').length) {
        $('#' + frmTabela).remove();
        $('#divPesquisaRodape', '#divTela').remove();
        trocaBotao('Avan�ar');

		for(var x = 1; x < 8; x++) {
			$('input, select', '#' + frmOpcao + ' fieldset:eq(' + x + ')').limpaFormulario();
			$('fieldset:eq(' + x + ')', '#' + frmOpcao).css({ 'display': 'none' });
		}

        controlaLayoutC();

    } else if (cddopcao === 'C' && ni > 0 && $('fieldset:eq(' + ni + ')', '#' + frmOpcao).css('display') == 'block') {
        
		for(var x = 1; x < 8; x++) {
			$('input, select', '#' + frmOpcao + ' fieldset:eq(' + x + ')').limpaFormulario();
			$('fieldset:eq(' + x + ')', '#' + frmOpcao).css({ 'display': 'none' });
		}
		
        tipoOptionC();
        cTpconsul.habilitaCampo();
        cConsulta.habilitaCampo();
        cFlgregis.habilitaCampo();
        cInestcri.habilitaCampo().focus();

    } else if (cddopcao === 'C' && isHabilitado(cConsulta)) {
        estadoInicial();

    } else if (cddopcao == 'R' && $('fieldset:eq(1)', '#' + frmOpcao).css('display') == 'block') {
        $('input, select', '#' + frmOpcao + ' fieldset:eq(1)').limpaFormulario();
        $('fieldset:eq(1)', '#' + frmOpcao).css({ 'display': 'none' });
        cFlgregis.habilitaCampo();
        cTprelato.habilitaCampo().focus();

    } else {
        estadoInicial();
    }

    controlaPesquisas();
    return false;
}

function btnContinuar() {

    if (divError.css('display') == 'block') { return false; }

    if (cddopcao == 'C' && isHabilitado(cConsulta)) {
        controlaLayoutC();

    } else if (cddopcao == 'C') {
        if ((consulta == '1' || consulta == '8') && isHabilitado(cNrdconta)) {
            cNrdconta.keydown();

        } else if (consulta == '6') {
            cNmprimtl.keydown();

        } else {
            controlaOperacao('CB', nriniseq, nrregist);
        }

    } else if (cddopcao == 'I') {

        if (cNmarqint.val() != '') {

            if (vrsarqvs == 'yes') {
                buscaArquivo();
            } else {
                msgConfirmacao();
            }

        } else {
            showError('error', '375 - O campo deve ser preenchido.', 'Alerta - Ayllos', "cNmarqint.focus();");
            return false;
        }

    } else if (cddopcao == 'R' && isHabilitado(cTprelato)) {
        controlaLayoutR();

    } else if (cddopcao == 'R' && isHabilitado(cInidtmvt)) {

        if (isHabilitado(cNrdconta)) {
            cNrdconta.keydown();
        } else {
            Gera_Impressao();
        }
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
    return false;
}

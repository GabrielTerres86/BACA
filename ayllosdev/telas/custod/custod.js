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
 * [30/09/2016] Odirlei Busana   (AMcom) : Inclusao relatorio de detalhamento de remessa custodia.
 * [16/12/2016] Lucas Reinert (CECRED)   : Alterações referentes ao projeto 300.
 * [11/04/2017] Permitir acessar o Ayllos mesmo vindo do CRM. (Jaison/Andrino)
 * [20/06/2017] Lucas Lombardi(CECRED)   : Retiradas as linhas Menor e Maior. PRJ367 - Compe Sessao Unica
 * [16/01/2018] Lucas Reinert (CECRED)	 : Aumentado tamanho do campo de senha para 30 caracteres. (PRJ339)
 * [06/02/2018] Mateus Zimmermann (Mouts): Alterações referentes ao projeto 454.1 - Resgate de cheque em custodia. ()
 * [19/06/2019] Daniel Lombardi (Mout'S) : Alterações referentes a RITM0022866 validação de data na opção C.
 * [09/08/2019] Jefferson       (Mout'S) : Alteracao da busca_cheques_em_custodia para considerar
                                           a data de custodia ao inves da data de liberacao.
                                           INC0016418 (Jefferson - Mout'S)
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
var cNrcpfcnpj = [];
var cDsemiten = [];
var glbDtmvtolt;

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

	glbDtmvtolt = $('#glb_dtmvtolt', '#frmCab').val();	
    // formulario	
    formataCabecalho();
    cTodosCabecalho.limpaFormulario().removeClass('campoErro');

    $('#' + frmOpcao).remove();
    $('#divBotoes', '#divTela').remove();
    //$('#divPesquisaRodape', '#divTela').remove();

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
    var dtcusini = $('#dtcusini', '#' + frmOpcao).val();
    var dtcusfim = $('#dtcusfim', '#' + frmOpcao).val();
    var nrdolote = $('#nrdolote', '#' + frmOpcao).val();
    var dsdocmc7 = $('#dsdocmc7', '#' + frmOpcao).val();
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
	var cdagenci = normalizaNumero($('#cdagenci', '#' + frmOpcao).val());
    if (dtcusini == '' && dtlibini == '') {
        showError('error', 'Data de início de custodia ou de liberação não informada!!', 'Alerta - Aimaro', 'unblockBackground()');
        return true;} 	
	if (dsdocmc7 !== undefined)
		dsdocmc7 = $('#dsdocmc7', '#' + frmOpcao).val().toString().replace(/[^0-9]/g, "").substr(0,30);

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
					dtcusini: dtcusini,
					dtcusfim: dtcusfim,
					nrdolote: nrdolote,
					dsdocmc7: dsdocmc7,
					cdagenci: cdagenci,
                    redirect: 'script_ajax'
                },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'estadoInicial();');
        },
        success: function(response) {
            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divTela').html(response);
                    return false;
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'unblockBackground()');
                }
            } else {
                try {
                    eval(response);
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'unblockBackground()');
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
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'estadoInicial();');
        },
        success: function(response) {
            try {
                eval(response);
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'estadoInicial();');
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
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', "unblockBackground()");
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

            //$('#divPesquisaRodape', '#divTela').remove();

            formataOpcao();

            // Seta os valores caso tenha vindo do CRM
            if ($("#crm_inacesso","#frmCab").val() == 1 && cddopcao != 'S') {
                $("#nrdconta","#frmOpcao").val($("#crm_nrdconta","#frmCab").val());
            }

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

        $('#divTela fieldset:eq(1)').css({'display': 'none'});
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
    } else if (cddopcao == 'H') {
		formataOpcaoH();
        $('#divCheques').css({'display': 'none'});        
		cNrdconta.habilitaCampo().focus();
	} else if (cddopcao == 'X') {
		formataOpcaoX();
        $('#divCheques').css({'display': 'none'});        
		cNrdconta.habilitaCampo().focus();
	} else if (cddopcao == 'L') {
		formataOpcaoL();
		$('#divFiltros').css({'display': 'none'});        
		$('#divRemessa').css({'display': 'none'});        
		cNrdconta.habilitaCampo().focus();
	} else if (cddopcao == 'I') {
		formataOpcaoI();
        $('#divCustch').css({'display': 'none'});        
		cNrdconta.habilitaCampo().focus();
    } else if (cddopcao == 'N') {
        formataOpcaoN();

        cNrdconta.habilitaCampo().focus();
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
		cDtcusini.habilitaCampo().focus();
		cDtcusfim.habilitaCampo();
        cTpcheque.habilitaCampo();
		cCdagenci.habilitaCampo();
		cNrdolote.habilitaCampo();
        cDtlibini.habilitaCampo();
        cDtlibfim.habilitaCampo();
		cDsdocmc7.habilitaCampo();

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
		cDtcusini.habilitaCampo().select();
		cDtcusfim.habilitaCampo();

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
    } else if (cddopcao == 'H') {
		$('#divCheques').css({'display': 'block'});
		cDsdocmc7.habilitaCampo().focus();
	} else if (cddopcao == 'X') {
		$('#divCheques').css({'display': 'block'});
		cDsdocmc7.habilitaCampo().focus();
	}  else if (cddopcao == 'L') {
		$('#divFiltros').css({'display': 'block'});
		cDtinicst.habilitaCampo().val(glbDtmvtolt).select();
		cDtfimcst.habilitaCampo().val(glbDtmvtolt);
    cCdagenci.habilitaCampo();
		cInsithcc.habilitaCampo();
	}  else if (cddopcao == 'I') {
		$('#divCustch').css({'display': 'block'});
		cDtchqbom.habilitaCampo().focus();
		cDtemissa.habilitaCampo();
		cVlcheque.habilitaCampo();
		cDsdocmc7.habilitaCampo();
		trocaBotoesI();
    } else if (cddopcao == 'N'){
        cDtresgat.habilitaCampo().select();
        cNrcheque.habilitaCampo();
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
            showError('error', 'Arquivo nao informado !!', 'Alerta - Aimaro', 'bloqueiaFundo( $(\'#divRotina\') ); cNmdireto.focus();');
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
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', "fechaRotina( $(\'#divRotina\') );");
        },
        success: function(response) {

            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divRotina').html(response);
                    exibeRotina($('#divRotina'));
                    formataDiretorio();
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'fechaRotina( $(\'#divRotina\') );');
                }
            } else {
                try {
                    eval(response);
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'fechaRotina( $(\'#divRotina\') );');
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
    rCddopcao.css({'width': '75px'}).addClass('rotulo');

    // Input
    cCddopcao = $('#cddopcao', '#' + frmCab);
    cCddopcao.css({'width': '888px'});

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
	rDtcusini = $('label[for="dtcusini"]', '#' + frmOpcao);
    rDtcusfim = $('label[for="dtcusfim"]', '#' + frmOpcao);
    rTpcheque = $('label[for="tpcheque"]', '#' + frmOpcao);
	rCdagenci = $('label[for="cdagenci"]', '#' + frmOpcao);
	rNrdolote = $('label[for="nrdolote"]', '#' + frmOpcao);	
    rDtlibini = $('label[for="dtlibini"]', '#' + frmOpcao);
    rDtlibfim = $('label[for="dtlibfim"]', '#' + frmOpcao);
	rDsdocmc7 = $('label[for="dsdocmc7"]', '#' + frmOpcao);	

    rNrdconta.css({'width': '200px'}).addClass('rotulo');
    rDtcusini.css({'width': '200px'}).addClass('rotulo');
    rDtcusfim.css({'width': '25px'}).addClass('rotulo-linha');
    rTpcheque.css({'width': '163px'}).addClass('rotulo-linha');
    rCdagenci.css({'width': '25px'}).addClass('rotulo-linha');
    rNrdolote.css({'width': '35px'}).addClass('rotulo-linha');
    rDtlibini.css({'width': '200px'}).addClass('rotulo');
    rDtlibfim.css({'width': '25px'}).addClass('rotulo-linha');
    rDsdocmc7.css({'width': '100px'}).addClass('rotulo-linha');	

    // input
    cNrdconta = $('#nrdconta', '#' + frmOpcao);
    cTpcheque = $('#tpcheque', '#' + frmOpcao);
    cNmprimtl = $('#nmprimtl', '#' + frmOpcao);
    cDtcusini = $('#dtcusini', '#' + frmOpcao);
    cDtcusfim = $('#dtcusfim', '#' + frmOpcao);
    cCdagenci = $('#cdagenci', '#' + frmOpcao);
    cNrdolote = $('#nrdolote', '#' + frmOpcao);
    cDtlibini = $('#dtlibini', '#' + frmOpcao);
    cDtlibfim = $('#dtlibfim', '#' + frmOpcao);
    cDsdocmc7 = $('#dsdocmc7', '#' + frmOpcao);
	btnOKC = $('#btnOkC', '#' + frmOpcao);

    cNrdconta.css({'width': '75px'}).addClass('pesquisa conta');
    cNmprimtl.css({'width': '517px'});
    cDtcusini.css({'width': '75px'}).addClass('data');
    cDtcusfim.css({'width': '75px'}).addClass('data');
    cTpcheque.css({'width': '110px'});
	cCdagenci.css({'width': '30px'}).addClass('inteiro').attr('maxlength','3');
	cNrdolote.css({'width': '50px'}).addClass('inteiro').attr('maxlength','4');
    cDtlibini.css({'width': '75px'}).addClass('data');
    cDtlibfim.css({'width': '75px'}).addClass('data');
	cDsdocmc7.css({'width':'290px'}).attr('maxlength','34');

    //
    if ($.browser.msie) {
        rTpcheque.css({'width': '42px'});
        rDtlibini.css({'width': '77px'});
        rDtlibfim.css({'width': '72px'});
    }

    // Outros	
    cTodosOpcao.desabilitaCampo();

    // tabela
    var divRegistro = $('div.divRegistros', '#divTela');
    var tabela = $('table', divRegistro);

    $('#' + frmOpcao).css({'margin-top': '5px'});
    divRegistro.css({'height': '207px', 'padding-bottom': '2px'});

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '73px';
    arrayLargura[1] = '50px';
    arrayLargura[2] = '50px';
    arrayLargura[3] = '79px';
    arrayLargura[4] = '59px';
    arrayLargura[5] = '73px';
    arrayLargura[6] = '77px';
    arrayLargura[7] = '47px';
    arrayLargura[8] = '47px';
    arrayLargura[9] = '73px';
    arrayLargura[10] = '73px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'right';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'right';
    arrayAlinha[4] = 'right';
    arrayAlinha[5] = 'right';
    arrayAlinha[6] = 'center';
    arrayAlinha[7] = 'right';
    arrayAlinha[8] = 'right';
    arrayAlinha[9] = 'center';
    arrayAlinha[10] = 'center';
    arrayAlinha[11] = 'left';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

    // conta
    cNrdconta.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        var auxconta = normalizaNumero(cNrdconta.val());

        // Se é a tecla TAB ou ENTER, 
        if ((e.keyCode == 9 || e.keyCode == 13 || typeof e.keyCode == 'undefined') && (auxconta === 0 || validaCampo('nrdconta', auxconta))) {
            if (auxconta == 0) {
                showError('error', 'Número de conta não informada!!', 'Alerta - Aimaro');
                return true;
            }   
            manterRotina('BIA');
            return false;
        } else if (e.keyCode == 9 || e.keyCode == 13 || typeof e.keyCode == 'undefined') {
            return false;
        }


    });

	// Data Inicio Custódia
    cDtcusini.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se é a tecla TAB ou ENTER, 
        if ((e.keyCode == 9 || e.keyCode == 13)) {
            cDtcusfim.focus();
            return false;
        }

    });

	// Data Fim Custódia
    cDtcusfim.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
    return false;
        }

        // Se é a tecla TAB ou ENTER, 
        if ((e.keyCode == 9 || e.keyCode == 13)) {
            cTpcheque.focus();
            return false;
        }

    });
	
	// Situação Cheque
    cTpcheque.unbind('keydown').bind('keydown', function(e) {
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
            cNrdolote.focus();
            return false;
        }

    });

	// Lote
    cNrdolote.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se é a tecla TAB ou ENTER, 
        if ((e.keyCode == 9 || e.keyCode == 13)) {
            cDtlibini.focus();
            return false;
        }

    });
	
	// Data Inicio Liberação
    cDtlibini.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se é a tecla TAB ou ENTER, 
        if ((e.keyCode == 9 || e.keyCode == 13)) {
            cDtlibfim.focus();
            return false;
        }

    });
	
    // Data Fim Liberação
    cDtlibfim.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se é a tecla TAB ou ENTER, 
        if ((e.keyCode == 9 || e.keyCode == 13)) {
            cDsdocmc7.focus();
            return false;
        }

    });

	cDsdocmc7.unbind('keyup').bind('keyup', function(e) {
		formataCampoCmc7(false);
		return false;
	});
	cDsdocmc7.unbind('blur').bind('blur', function(e) {
		formataCampoCmc7(true);
		return false;
	});
	cDsdocmc7.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		

		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
            btnContinuar();
            return false;

        }
    });
	$('#divPesquisaRodape', '#divTela').formataRodapePesquisa();
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
    rQtcredit = $('label[for="qtcredit"]', '#' + frmOpcao);
    rVlcheque = $('label[for="vlcheque"]', '#' + frmOpcao);
    rVlchqdev = $('label[for="vlchqdev"]', '#' + frmOpcao);
    rVlchqdsc = $('label[for="vlchqdsc"]', '#' + frmOpcao);

    rVlchqcop = $('label[for="vlchqcop"]', '#' + frmOpcao);
    rVlchqban = $('label[for="vlchqban"]', '#' + frmOpcao);
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
    rQtcredit.addClass('rotulo-linha').css({'width': '20px'});
    rVlcheque.addClass('rotulo-linha').css({'width': '20px'});
    rVlchqdev.addClass('rotulo-linha').css({'width': '20px'});
    rVlchqdsc.addClass('rotulo-linha').css({'width': '20px'});
    rVlchqcop.addClass('rotulo-linha').css({'width': '20px'});
    rVlchqban.addClass('rotulo-linha').css({'width': '20px'});
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
    cQtcredit = $('#qtcredit', '#' + frmOpcao);
    cVlcheque = $('#vlcheque', '#' + frmOpcao);
    cVlchqdev = $('#vlchqdev', '#' + frmOpcao);
    cVlchqdsc = $('#vlchqdsc', '#' + frmOpcao);
    cVlchqcop = $('#vlchqcop', '#' + frmOpcao);
    cVlchqban = $('#vlchqban', '#' + frmOpcao);
    cVlcredit = $('#vlcredit', '#' + frmOpcao);

    cDtlibera.css({'width': '90px'}).addClass('data');
    cQtcheque.css({'width': '120px'}).addClass('inteiro');
    cQtchqdev.css({'width': '120px'}).addClass('inteiro');
    cQtchqdsc.css({'width': '120px'}).addClass('inteiro');
    cQtchqcop.css({'width': '120px'}).addClass('inteiro');
    cQtchqban.css({'width': '120px'}).addClass('inteiro');
    cQtcredit.css({'width': '120px'}).addClass('inteiro');
    cVlcheque.css({'width': '120px'}).addClass('monetario');
    cVlchqdev.css({'width': '120px'}).addClass('monetario');
    cVlchqdsc.css({'width': '120px'}).addClass('monetario');
    cVlchqcop.css({'width': '120px'}).addClass('monetario');
    cVlchqban.css({'width': '120px'}).addClass('monetario');
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
    rDtcusini = $('label[for="dtcusini"]', '#' + frmOpcao);
    rDtcusfim = $('label[for="dtcusfim"]', '#' + frmOpcao);

    rNrdconta.css({'width': '44px'}).addClass('rotulo');
    rNmprimtl.css({'width': '44px'}).addClass('rotulo');
    rDtcusini.css({'width': '273px'}).addClass('rotulo-linha');
    rDtcusfim.css({'width': '25px'}).addClass('rotulo-linha');

    // input
    cNrdconta = $('#nrdconta', '#' + frmOpcao);
    cNmprimtl = $('#nmprimtl', '#' + frmOpcao);
    cDtcusini = $('#dtcusini', '#' + frmOpcao);
    cDtcusfim = $('#dtcusfim', '#' + frmOpcao);

    cNrdconta.css({'width': '75px'}).addClass('pesquisa conta');
    cNmprimtl.css({'width': '553px'});
    cDtcusini.css({'width': '75px'}).addClass('data');
    cDtcusfim.css({'width': '75px'}).addClass('data');

    // Outros	
    cTodosOpcao.desabilitaCampo();


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

	// Data Inicio Custodia
    cDtcusini.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se é a tecla TAB ou ENTER, 
        if ((e.keyCode == 9 || e.keyCode == 13)) {
            cDtcusfim.focus();
            return false;
        }

    });

	// Data Fim Custodia
    cDtcusfim.unbind('keydown').bind('keydown', function(e) {
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
	
	cDtcusini.attr('tabindex', 1);
	cDtcusfim.attr('tabindex', 2);
	
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
                // Seta os valores caso tenha vindo do CRM
                if ($("#crm_inacesso","#frmCab").val() == 1) {
                    $("#nrdconta","#frmOpcao").val($("#crm_nrdconta","#frmCab").val());
                }
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
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', "estadoInicial();");
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
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'estadoInicial();');
                }
            } else {
                try {
                    eval(response);
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'estadoInicial();');
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
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', "estadoInicial();");
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
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'estadoInicial();');
            }
        }
    });

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
        showError('error', 'D&iacute;gito errado.', 'Alerta - Aimaro', '$(\'#' + campo + '\',\'#frmOpcao\').select();');
        return false;

        // cpf/cnpj
    } else if (campo == 'nrcpfcgc' && verificaTipoPessoa(valor) == 0) {
        showError('error', 'D&iacute;gito errado.', 'Alerta - Aimaro', '$(\'#' + campo + '\',\'#frmOpcao\').select();');
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
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', "unblockBackground()");
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
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', "unblockBackground();");
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
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'unblockBackground()');
                }
            } else {
                try {
                    eval(response);
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'unblockBackground()');
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
    cSenha.addClass('campo').css({'width': '100px'}).attr('maxlength', '30');



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
	
	codsenha = encodeURIComponent(codsenha, "UTF-8");
	
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
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'unblockBackground()');
        },
        success: function(response) {
            try {
                eval(response);
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'unblockBackground()');
            }
        }
    });

    return false;

}


// botoes
function btnVoltar() {

    if (cddopcao == 'C' && !cNrdconta.hasClass('campoTelaSemBorda')) {
        estadoInicial();

    } else if (cddopcao == 'C' && !cTpcheque.hasClass('campoTelaSemBorda')) {
        var auxconta = cNrdconta.val();
        cTodosOpcao.desabilitaCampo().limpaFormulario();
        cNrdconta.habilitaCampo().val(auxconta).select();

    } else if (cddopcao == 'C' && cNrdconta.hasClass('campoTelaSemBorda') && cTpcheque.hasClass('campoTelaSemBorda')) {
        $('#divTela fieldset:eq(1)').css({'display': 'none'});
        $('#divPesquisaRodape', '#divTela').css({'display': 'none'});
		cTodosOpcao.habilitaCampo();
		cNrdconta.desabilitaCampo();
		cNmprimtl.desabilitaCampo();
        cDtcusini.focus();
        trocaBotao('Prosseguir');

    } else if (cddopcao == 'D' && !cDtlibera.hasClass('campoTelaSemBorda')) {
        cNrdconta.habilitaCampo().select();
        cNmprimtl.val('');
        cDtlibera.desabilitaCampo().val('');

    } else if (cddopcao == 'F' && !cDtlibera.hasClass('campoTelaSemBorda')) {
        $('#' + frmOpcao + ' fieldset:eq(1)').css({'display': 'none'});
        $('input', '#' + frmOpcao + ' fieldset:eq(1)').limpaFormulario();
        cNrdconta.habilitaCampo().select();
        cNmprimtl.val('');
        cDtlibera.desabilitaCampo();
        trocaBotao('Prosseguir');

    } else if (cddopcao == 'M' && !cDtcusini.hasClass('campoTelaSemBorda')) {
        cNrdconta.habilitaCampo().select();
        cNmprimtl.val('');
        cDtcusini.desabilitaCampo().val('');
        cDtcusfim.desabilitaCampo().val('');

    } else if (cddopcao == 'P' && !cNrdconta.hasClass('campoTelaSemBorda')) {
        estadoInicial();

    } else if (cddopcao == 'P' && !cCdbanchq.hasClass('campoTelaSemBorda')) {
        $('#' + frmOpcao + ' fieldset:eq(1)').css({'display': 'none'});
        $('input', '#' + frmOpcao + ' fieldset:eq(1)').limpaFormulario();
        cNrdconta.habilitaCampo().select();
        cNmprimtl.val('');

    } else if (cddopcao == 'P' && cNrdconta.hasClass('campoTelaSemBorda') && cCdbanchq.hasClass('campoTelaSemBorda')) {
        $('input', '#' + frmOpcao + ' fieldset:eq(1)').habilitaCampo();
        $('#' + frmOpcao + ' fieldset:eq(2)').css({'display': 'none'});
        $('#complemento', '#' + frmOpcao).css({'display': 'none'});
        cCdbanchq.select();
        trocaBotao('Prosseguir');

    } else if (cddopcao == 'S' && $('#dsdopcao', '#' + frmOpcao).val() == 3 && !($('#dtlibera', '#' + frmOpcao).hasClass('campoTelaSemBorda'))) {
        cNrdconta.habilitaCampo().select();
        cDtlibera.desabilitaCampo();
        trocaBotao('Prosseguir');

    } else if (cddopcao == 'S' && !($('#dtlibera', '#' + frmOpcao).hasClass('campoTelaSemBorda'))) {
        cDsdopcao.habilitaCampo().focus();
        cDtlibera.desabilitaCampo();
        trocaBotao('Prosseguir');

    } else if (cddopcao == 'S' && !($('#nrdconta', '#' + frmOpcao).hasClass('campoTelaSemBorda'))) {
        cDsdopcao.habilitaCampo().focus();
        cNrdconta.desabilitaCampo().val('');
        trocaBotao('Prosseguir');
    } else if (cddopcao == 'T' && !cCdbanchq.hasClass('campoTelaSemBorda')) {
        $('#' + frmOpcao + ' fieldset:eq(1)').css({'display': 'none'});
        $('input', '#' + frmOpcao + ' fieldset:eq(1)').limpaFormulario();
        cNrdconta.habilitaCampo().select();
        cNmprimtl.val('');
        cCdbanchq.desabilitaCampo();

    } else if (cddopcao == 'T' && cNrdconta.hasClass('campoTelaSemBorda') && cCdbanchq.hasClass('campoTelaSemBorda')) {
        $('input', '#' + frmOpcao + ' fieldset:eq(1)').habilitaCampo();
        $('#' + frmOpcao + ' fieldset:eq(2)').css({'display': 'none'});
        cCdbanchq.select();
        trocaBotao('Prosseguir');

    } else if (cddopcao == 'H' && cNrdconta.hasClass('campoTelaSemBorda')) {
        $('#divCheques').css({'display': 'none'});        
        var auxconta = cNrdconta.val();        
        cNrdconta.habilitaCampo().val(auxconta).select();
		var btnResgatar = $('#btResgatar','#divBotoes');
		var btnProsseguir = $('#btProsseguir','#divBotoes');

		if (btnResgatar.css('display') == 'inline-block') {
			btnResgatar.css({'display': 'none'});
			btnProsseguir.css({'display': 'inline-block'});
		}
		limpaGridCheques();
	} else if (cddopcao == 'X' && cNrdconta.hasClass('campoTelaSemBorda')) {
        $('#divCheques').css({'display': 'none'});        
        var auxconta = cNrdconta.val();        
        cNrdconta.habilitaCampo().val(auxconta).select();
		var btnCancelar = $('#btCancelar','#divBotoes');
		var btnProsseguir = $('#btProsseguir','#divBotoes');

		if (btnCancelar.css('display') == 'inline-block') {
			btnCancelar.css({'display': 'none'});
			btnProsseguir.css({'display': 'inline-block'});
		}
		limpaGridCheques();
	}else if (cddopcao == 'L' && $('#divChqRemessa').css('display') == 'block') {
		$('#divFiltros').css({'display': 'block'});
		$('#divAssociado').css({'display': 'block'});
		$('#divChqRemessa').css({'display': 'none'});
		$('#divCheque').css({'display': 'none'});
		$('#divAssociadoChq').css({'display': 'none'});
		
		buscaRemessas(glbTabNriniseq, glbTabNrregist);
		
	}else if (cddopcao == 'L' && $('#divRemessa').css('display') == 'block') {
		$('#divRemessa').css({'display': 'none'});
		
		cDtinicst.habilitaCampo().val('').focus();
		cDtfimcst.habilitaCampo().val('');
    cCdagenci.habilitaCampo().val('');
		cInsithcc.habilitaCampo().val('0');	
		
		trocaBotoesL();
		
	}else if (cddopcao == 'L' && cNrdconta.hasClass('campoTelaSemBorda')) {
		$('#divFiltros').css({'display': 'none'});        
		var auxconta = cNrdconta.val();        
        cNrdconta.habilitaCampo().val(auxconta).select();
		cDtinicst.val('');
		cDtfimcst.val('');
		cCdagenci.val('');
		cInsithcc.val('0');	
		
	}else if (cddopcao == 'I' && $('#divEmiten').css('display') == 'block') {
		$('#divEmiten').css({'display': 'none'});
		$('#divCustch').css({'display': 'block'});
		
		limpaTabEmiten();
		
		trocaBotoesI();
		
	}else if (cddopcao == 'I' && cNrdconta.hasClass('campoTelaSemBorda')) {
		$('#divCustch').css({'display': 'none'});        
		var auxconta = cNrdconta.val();        
        cNrdconta.habilitaCampo().val(auxconta).select();
		cDtchqbom.val('');
		cDtemissa.val('');
		cVlcheque.val('');	
		cDsdocmc7.val('');	
		limpaTabCustch();
		atualizaMensagemQtdRegistros();
		trocaBotoesI();
    } else {
        estadoInicial();
    }

    controlaPesquisas();
    return false;
}

function msgAtencao() {

    showError('inform', 'ATENCAO! Esta operacao NAO tem volta!', 'Alerta - Aimaro', 'mostraSenha();');
    return false;
}

function btnRemover(i) {
    showConfirmacao('Confirma a exclusao do protocolo?', 'Confirma&ccedil;&atilde;o - Aimaro', 'removeLote(\'' + i + '\');', 'bloqueiaFundo( $(\'#divRotina\') );', 'sim.gif', 'nao.gif');
    return false;
}

function btnContinuar() {

    if (divError.css('display') == 'block') {
        return false;
    }

    if (cddopcao == 'C' && !cNrdconta.hasClass('campoTelaSemBorda')) {
        cNrdconta.keydown();

    } else if (cddopcao == 'C' && !cTpcheque.hasClass('campoTelaSemBorda') ) {
        controlaOperacao('CCC', nriniseq, nrregist);

    } else if (cddopcao == 'F' && !cNrdconta.hasClass('campoTelaSemBorda')) {
        cNrdconta.keydown();

    } else if (cddopcao == 'M' && !cNrdconta.hasClass('campoTelaSemBorda')) {
        cNrdconta.keydown();

    } else if (cddopcao == 'M' && !cDtcusini.hasClass('campoTelaSemBorda')) {
        showConfirmacao('Imprimir os cheques RESGATADOS E DESCONTADOS?', 'Confirma&ccedil;&atilde;o - Aimaro', 'Gera_Impressao(\'yes\');', 'Gera_Impressao(\'no\');', 'sim.gif', 'nao.gif');

    } else if (cddopcao == 'P' && !cNrdconta.hasClass('campoTelaSemBorda')) {
        cNrdconta.keydown();

    } else if (cddopcao == 'P' && !cCdbanchq.hasClass('campoTelaSemBorda')) {
        controlaOperacao('PCC', nriniseq, nrregist);

    } else if (cddopcao == 'R') {
        if (cNmdopcao.val() == 'yes') {
            buscaDiretorio();
        } else {
            showConfirmacao('Imprimir os cheques RESGATADOS E DESCONTADOS?', 'Confirma&ccedil;&atilde;o - Aimaro', 'Gera_Impressao();', '', 'sim.gif', 'nao.gif');
        }

    } else if (cddopcao == 'O') {
        cNrdconta.keydown();

    } else if (cddopcao == 'T' && !cNrdconta.hasClass('campoTelaSemBorda')) {
        cNrdconta.keydown();

    } else if (cddopcao == 'T' && !cCdbanchq.hasClass('campoTelaSemBorda')) {
        controlaOperacao('TLC', nriniseq, nrregist);

    } else if (cddopcao == 'S' && !cDsdopcao.hasClass('campoTelaSemBorda')) {
        cDsdopcao.keydown();

    } else if (cddopcao == 'S' && !cNrdconta.hasClass('campoTelaSemBorda')) {
        cNrdconta.keydown();

    } else if (cddopcao == 'S' && !cDtlibera.hasClass('campoTelaSemBorda')) {
        controlaOperacao('SDC', nriniseq, nrregist);

    } else if (cddopcao == 'H' && !cNrdconta.hasClass('campoTelaSemBorda')) {
        cNrdconta.keydown();
		
	} else if (cddopcao == 'H' && !cDsdocmc7.hasClass('campoTelaSemBorda')) {
		validarResgate();	
		
	} else if (cddopcao == 'X' && !cNrdconta.hasClass('campoTelaSemBorda')) {
        cNrdconta.keydown();
		
	} else if (cddopcao == 'X' && !cDsdocmc7.hasClass('campoTelaSemBorda')) {
		validarCancelarResgate();	
		
	} else if (cddopcao == 'L' && !cNrdconta.hasClass('campoTelaSemBorda')) {
        cNrdconta.keydown();
		
	} else if (cddopcao == 'L' && ($('#divChqRemessa').css('display') == 'block')) {
		conciliarCheques();
		
	}else if (cddopcao == 'L' && !cDtinicst.hasClass('campoTelaSemBorda')) {
		buscaRemessas(1, 50);
		
	} else if (cddopcao == 'I' && !cNrdconta.hasClass('campoTelaSemBorda')) {
        cNrdconta.keydown();
		
	} else if (cddopcao == 'I' && !cDtchqbom.hasClass('campoTelaSemBorda')) {
		finalizarCustodia();

    } else if (cddopcao == 'N' && !cDtresgat.hasClass('campoTelaSemBorda')) {
        buscarChequesResgatados();

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

function formataCampoCmc7(exitCampo){
	var mask   = '<zzzzzzzz<zzzzzzzzzz>zzzzzzzzzzzz:';
	var indice = 0;
	var valorAtual = cDsdocmc7.val();
	var valorNovo  = '';
	
	if ( valorAtual == '' ){
		return false;
	}
	
	if ( exitCampo && valorAtual.length < 34) {
		showError('error','Valor do CMC-7 inv&aacute;lido.','Alerta - Aimaro','cDsdocmc7.focus();');
	}
	
	//remover os caracteres de formatação
	valorAtual = valorAtual.replace(/[^0-9]/g, "").substr(0,30);
	
	for ( var x = 0;  x < valorAtual.length; x++ ) {
				
		//verifica se é um separador da máscara
		if (mask.charAt(indice) != 'z'){
			valorNovo = valorNovo.concat(mask.charAt(indice));
			indice++;
		}
		valorNovo = valorNovo.concat(valorAtual.charAt(x));		
		indice++;
	}
	
	// verifica se o valor digitado possui 30 caracteres sem formatação
	if ( valorAtual.length == 30 ){
		// Adiciona o ultimo caracter da máscara
		valorNovo = valorNovo.concat(':');
	}
	
	cDsdocmc7.val(valorNovo);
}

// opcao H
function formataOpcaoH() {

    // label
    rNrdconta = $('label[for="nrdconta"]', '#' + frmOpcao);
	rDsdocmc7 = $('label[for="dsdocmc7"]', '#' + frmOpcao);	

    rNrdconta.css({'width': '100px'}).addClass('rotulo');
    rDsdocmc7.css({'width': '100px'}).addClass('rotulo');	

    // input
    cNrdconta = $('#nrdconta', '#' + frmOpcao);
    cNmprimtl = $('#nmprimtl', '#' + frmOpcao);
    cDsdocmc7 = $('#dsdocmc7', '#' + frmOpcao);
	btnAdd	  = $('#btnAdd','#'+frmOpcao);
	
    cNrdconta.css({'width': '75px'}).addClass('pesquisa conta');
    cNmprimtl.css({'width': '517px'});
	cDsdocmc7.css({'width':'290px'}).attr('maxlength','34');
	
    // Outros	
    cTodosOpcao.desabilitaCampo();

    // tabela
    var divRegistro = $('div.divRegistros', '#' + frmOpcao);
    var tabela = $('table', divRegistro);

    $('#' + frmOpcao).css({'margin-top': '5px'});
    divRegistro.css({'height': '207px', 'padding-bottom': '2px'});

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '50px';
    arrayLargura[1] = '50px';
    arrayLargura[2] = '50px';
    arrayLargura[3] = '79px';
    arrayLargura[4] = '59px';
    arrayLargura[5] = '73px';
    arrayLargura[6] = '73px';
    arrayLargura[7] = '240px';
    arrayLargura[8] = '16px';
	
    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'right';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'right';
    arrayAlinha[4] = 'right';
    arrayAlinha[5] = 'right';
    arrayAlinha[6] = 'center';
    arrayAlinha[7] = 'center';
    arrayAlinha[8] = 'center';
    arrayAlinha[9] = 'right';

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

	cDsdocmc7.unbind('keyup').bind('keyup', function(e) {
		formataCampoCmc7(false);
		return false;
	});
	cDsdocmc7.unbind('blur').bind('blur', function(e) {
		formataCampoCmc7(true);
		return false;
	});
	cDsdocmc7.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
	
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			btnAdd.click();
			return false;

		}
	});		
	
    layoutPadrao();
    controlaPesquisas();
	
    return false;

}

// opcao X
function formataOpcaoX() {

    // label
    rNrdconta = $('label[for="nrdconta"]', '#' + frmOpcao);
	rDsdocmc7 = $('label[for="dsdocmc7"]', '#' + frmOpcao);	

    rNrdconta.css({'width': '100px'}).addClass('rotulo');
    rDsdocmc7.css({'width': '100px'}).addClass('rotulo');	

    // input
    cNrdconta = $('#nrdconta', '#' + frmOpcao);
    cNmprimtl = $('#nmprimtl', '#' + frmOpcao);
    cDsdocmc7 = $('#dsdocmc7', '#' + frmOpcao);
	btnAdd	  = $('#btnAdd','#'+frmOpcao);
	
    cNrdconta.css({'width': '75px'}).addClass('pesquisa conta');
    cNmprimtl.css({'width': '517px'});
	cDsdocmc7.css({'width':'290px'}).attr('maxlength','34');
	
    // Outros	
    cTodosOpcao.desabilitaCampo();

    // tabela
    var divRegistro = $('div.divRegistros', '#' + frmOpcao);
    var tabela = $('table', divRegistro);

    $('#' + frmOpcao).css({'margin-top': '5px'});
    divRegistro.css({'height': '207px', 'padding-bottom': '2px'});

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '50px';
    arrayLargura[1] = '50px';
    arrayLargura[2] = '50px';
    arrayLargura[3] = '79px';
    arrayLargura[4] = '59px';
    arrayLargura[5] = '73px';
    arrayLargura[6] = '73px';
    arrayLargura[7] = '240px';
    arrayLargura[8] = '16px';
	
    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'right';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'right';
    arrayAlinha[4] = 'right';
    arrayAlinha[5] = 'right';
    arrayAlinha[6] = 'center';
    arrayAlinha[7] = 'center';
    arrayAlinha[8] = 'center';
    arrayAlinha[9] = 'right';

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

	cDsdocmc7.unbind('keyup').bind('keyup', function(e) {
		formataCampoCmc7(false);
		return false;
	});
	cDsdocmc7.unbind('blur').bind('blur', function(e) {
		formataCampoCmc7(true);
		return false;
	});
	cDsdocmc7.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
	
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			btnAdd.click();
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
    rNrdconta = $('label[for="nrdconta"]', '#' + frmOpcao);
    rNrctarem = $('label[for="nrctarem"]', '#' + frmOpcao);
	rDtinicst = $('label[for="dtinicst"]', '#' + frmOpcao);	
	rDtfimcst = $('label[for="dtfimcst"]', '#' + frmOpcao);	
  rCdagenci = $('label[for="cdagenci"]', '#' + frmOpcao);
	rInsithcc = $('label[for="insithcc"]', '#' + frmOpcao);	
	rNmarquiv = $('label[for="nmarquiv"]', '#' + frmOpcao);	
	rInsithc2 = $('label[for="insithc2"]', '#' + frmOpcao);	
	rNrremret = $('label[for="nrremret"]', '#' + frmOpcao);	
	rDsorigem = $('label[for="dsorigem"]', '#' + frmOpcao);	
	rDsdocmc7 = $('label[for="dsdocmc7"]', '#' + frmOpcao);	
	rDsmsgcmc7 = $('#dsmsgcmc7','#'+frmOpcao);        
	
    rNrdconta.css({'width': '100px'}).addClass('rotulo');
    rNrctarem.css({'width': '100px'}).addClass('rotulo');
    rDtinicst.css({'width': '100px'}).addClass('rotulo');	
    rDtfimcst.css({'width': '25px'}).addClass('rotulo-linha');
    rCdagenci.css({'width': '50px'}).addClass('rotulo-linha');
    rInsithcc.css({'width': '93px'}).addClass('rotulo-linha');
    rNmarquiv.css({'width': '100px'}).addClass('rotulo');	
    rInsithc2.css({'width': '75px'}).addClass('rotulo-linha');
	rNrremret.css({'width': '75px'}).addClass('rotulo-linha');
	rDsorigem.css({'width': '75px'}).addClass('rotulo-linha');
    rDsdocmc7.css({'width': '100px'}).addClass('rotulo');	
	rDsmsgcmc7.css({'width':'200px','text-align':'left','margin-left':'3px'}).addClass('rotulo-linha');
	
    // input
    cNrdconta = $('#nrdconta', '#' + frmOpcao);
    cNrctarem = $('#nrctarem', '#' + frmOpcao);
    cNmprimtl = $('#nmprimtl', '#' + frmOpcao);
    cNmttlrem = $('#nmttlrem', '#' + frmOpcao);
    cDtinicst = $('#dtinicst', '#' + frmOpcao);
    cDtfimcst = $('#dtfimcst', '#' + frmOpcao);
    cCdagenci = $('#cdagenci', '#' + frmOpcao);
    cInsithcc = $('#insithcc', '#' + frmOpcao);
    cNmarquiv = $('#nmarquiv', '#' + frmOpcao);
    cInsithc2 = $('#insithc2', '#' + frmOpcao);
    cNrremret = $('#nrremret', '#' + frmOpcao);
    cDsorigem = $('#dsorigem', '#' + frmOpcao);
    cDsdocmc7 = $('#dsdocmc7', '#' + frmOpcao);	
	btnBscrem = $('#btBscrem','#'+frmOpcao);
	
    cNrdconta.css({'width': '75px'}).addClass('pesquisa conta');
    cNrctarem.css({'width': '75px'}).addClass('pesquisa conta');
    cNmprimtl.css({'width': '517px'});
    cNmttlrem.css({'width': '517px'});
    cDtinicst.css({'width': '75px'}).addClass('data');
    cDtfimcst.css({'width': '75px'}).addClass('data');
    cCdagenci.css({'width': '40px'}).addClass('inteiro').attr('maxlength', '3');;
    cInsithcc.css({'width': '110px'});
    cNmarquiv.css({'width': '290px'});
    cInsithc2.css({'width': '110px'});
	cNrremret.css({'width': '50px'}).addClass('inteiro');
	cDsorigem.css({'width': '181px'});
	cDsdocmc7.css({'width':'290px'}).attr('maxlength','34');

    // Outros	
    cTodosOpcao.desabilitaCampo();
	
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

	// Data Inicio Remessa de Custódia
    cDtinicst.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se é a tecla TAB ou ENTER, 
        if (e.keyCode == 13) {
            cDtfimcst.focus();
            return false;
        }

    });

	// Data Fim Remessa de Custódia
    cDtfimcst.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se é a tecla TAB ou ENTER, 
        if (e.keyCode == 13) {
            cCdagenci.focus();
            return false;
        }

    });

	// Data Fim Remessa de Custódia
    cCdagenci.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se é a tecla TAB ou ENTER,
        if (e.keyCode == 13) {
            cInsithcc.focus();
            return false;
        }

    });
	
	// Status da Remessa
    cInsithcc.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se é a tecla TAB ou ENTER, 
        if ( e.keyCode == 13) {
            btnContinuar();
            return false;
        }

    });
	
	cDsdocmc7.unbind('keyup').bind('keyup', function(e) {
		formataCampoCmc7(false);
		return false;
	});
	cDsdocmc7.unbind('blur').bind('blur', function(e) {
		formataCampoCmc7(true);
		return false;
	});
	cDsdocmc7.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
	
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			conciliaChequeGrid();
			return false;

		}
	});		
	
    layoutPadrao();
    controlaPesquisas();
	
	cDtinicst.attr('tabindex', 1);
	cDtfimcst.attr('tabindex', 2);
	cInsithcc.attr('tabindex', 3);
	btnBscrem.attr('tabindex', 4);
	
    return false;

}

function formataTabelaL(){
	
	    // tabela
    var divRegistro = $('div.divRegistros', '#divRemessa');
    var tabela = $('table', divRegistro);
	
	glbTabNrdconta = undefined;
	glbTabNrctarem = undefined;
	glbTabDtmvtolt = undefined;
	glbTabNrremret = undefined;
	glbTabVltotchq = undefined;
	glbTabQtcheque = undefined;
	glbTabQtconcil = undefined;
	glbTabInsithcc = undefined;
	glbTabDtcustod = undefined;
	glbTabNmarquiv = undefined;
	glbTabNrconven = undefined;
	glbTabIntipmvt = undefined;
	glbTabNmprimtl = undefined;
	glbTabDsorigem = undefined;
	
    $('#' + frmOpcao).css({'margin-top': '5px'});
    divRegistro.css({'height': '207px', 'padding-bottom': '2px'});

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '70px';
    arrayLargura[1] = '70px';
    arrayLargura[2] = '70px';
    arrayLargura[3] = '100px';
    arrayLargura[4] = '90px';
    arrayLargura[5] = '90px';
    arrayLargura[6] = '100px';
    arrayLargura[7] = '70px';
	
    var arrayAlinha = new Array();
    arrayAlinha[0] = 'right';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'right';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'center';
    arrayAlinha[6] = 'left';
    arrayAlinha[7] = 'center';
    arrayAlinha[8] = 'left';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, 'buscaChequesRemessa()');
	
	glbTabNriniseq = $('table > tbody', divRegistro).find('#nriniseq').val();
	glbTabNrregist = $('table > tbody', divRegistro).find('#nrregist').val();
	
	$('table.tituloRegistros > thead > tr', '#divRemessa').click( function() {
		glbTabNrdconta = undefined;
		glbTabNrctarem = undefined;
		glbTabDtmvtolt = undefined;
		glbTabNrremret = undefined;
		glbTabVltotchq = undefined;
		glbTabQtcheque = undefined;
		glbTabQtconcil = undefined;
		glbTabInsithcc = undefined;
		glbTabDtcustod = undefined;
		glbTabNmarquiv = undefined;
		glbTabNrconven = undefined;
		glbTabIntipmvt = undefined;
		glbTabNmprimtl = undefined;
		glbTabDsorigem = undefined;

	// seleciona o registro que é clicado
		$('table > tbody > tr', divRegistro).click( function() {
			glbTabNrdconta = normalizaNumero($(this).find('#nrdconta > span').text());
			glbTabNrctarem = $(this).find('#nrdconta > span').text() ;
			glbTabDtmvtolt = $(this).find('#dtmvtolt > span').text() ;
			glbTabNrremret = $(this).find('#nrremret > span').text() ;
			glbTabVltotchq = $(this).find('#vltotchq > span').text() ;
			glbTabQtcheque = $(this).find('#qtcheque > span').text() ;
			glbTabQtconcil = $(this).find('#qtconcil > span').text() ;
			glbTabInsithcc = $(this).find('#insithcc > span').text() ;
			glbTabDtcustod = $(this).find('#dtcustod > span').text() ;
			glbTabNmarquiv = $(this).find('#nmarquiv > span').text() ;
			glbTabNrconven = $(this).find('#nrconven').val();
			glbTabIntipmvt = $(this).find('#intipmvt').val();
			glbTabNmprimtl = $(this).find('#nmprimtl').val();
			glbTabDsorigem = $(this).find('#dsorigem').val();
		});
	});
	
	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		glbTabNrdconta = normalizaNumero($(this).find('#nrdconta > span').text());
		glbTabNrctarem = $(this).find('#nrdconta > span').text() ;
		glbTabDtmvtolt = $(this).find('#dtmvtolt > span').text() ;
		glbTabNrremret = $(this).find('#nrremret > span').text() ;
		glbTabVltotchq = $(this).find('#vltotchq > span').text() ;
		glbTabQtcheque = $(this).find('#qtcheque > span').text() ;
		glbTabQtconcil = $(this).find('#qtconcil > span').text() ;
		glbTabInsithcc = $(this).find('#insithcc > span').text() ;
		glbTabDtcustod = $(this).find('#dtcustod > span').text() ;
		glbTabNmarquiv = $(this).find('#nmarquiv > span').text() ;
		glbTabNrconven = $(this).find('#nrconven').val();
		glbTabIntipmvt = $(this).find('#intipmvt').val();
		glbTabNmprimtl = $(this).find('#nmprimtl').val();
		glbTabDsorigem = $(this).find('#dsorigem').val();
	});
	
	$('table > tbody > tr:eq(0)', divRegistro).click();	
	
}

function adicionaChequeGrid(){

	var cmc7  = cDsdocmc7.val();
	// Limpa campo
	cDsdocmc7.val('');
	var cmc7_sem_format  = cmc7.replace(/[^0-9]/g, "").substr(0,30);
	
	if ( cmc7 == '' ) {
		return false;
	}
		
	if ( cmc7_sem_format.length < 30 ) {
		showError('error','CMC-7 inv&aacute;lido.','Alerta - Aimaro','cDsdocmc7.focus();');
		return false;
	}
		
	var idCriar = "id_".concat(cmc7_sem_format);

	//Desmontar o CMC-7 para exibir os campos
	var banco     = cmc7_sem_format.substr(0,3);
	var agencia   = cmc7_sem_format.substr(3,4);
	var comp 	  = cmc7_sem_format.substr(8,3);
	var cheque    = cmc7_sem_format.substr(11,6);
	var conta     = 0;
	var qtdLinhas = $('#tbCheques tbody tr').length;
	var corLinha  = (qtdLinhas%2 === 0) ? 'corImpar' : 'corPar';
	
	if( banco == 1 ){
	    conta = mascara(normalizaNumero(cmc7_sem_format.substr(21,8)),'####.###-#');
	} else {
		conta = mascara(normalizaNumero(cmc7_sem_format.substr(19,10)),'######.###-#');
	}
	
	if(!document.getElementById(idCriar)) {
		
		// Criar a linha na tabela
		$("#tbCheques > tbody")
			.append($('<tr>') // Linha
			    .attr('id',idCriar)
				.attr('class',corLinha)								
				.append($('<td>') // Coluna: Comp
					.attr('style','width: 50px; text-align:right')
					.text(comp)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_comp')
						.attr('id','aux_comp')
						.attr('value',comp)
					)
				)
				.append($('<td>') // Coluna: Banco
					.attr('style','width: 50px; text-align:right')
					.text(banco)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_banco')
						.attr('id','aux_banco')
						.attr('value',banco)
					)
				)
				.append($('<td>')  // Coluna: Agência
					.attr('style','width: 50px; text-align:right')
					.text(agencia)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_agencia')
						.attr('id','aux_agencia')
						.attr('value',agencia)
					)
				)
				.append($('<td>') // Coluna: Número da Conta
					.attr('style','width: 79px; text-align:right')
					.text(conta)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_conta')
						.attr('id','aux_conta')
						.attr('value',conta)
					)
				)
				.append($('<td>') // Coluna: Número do Cheque
					.attr('style','width: 59px; text-align:right')
					.text(cheque)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_cheque')
						.attr('id','aux_cheque')
						.attr('value',cheque)
					)
				)
				.append($('<td>') // Coluna: Data Boa
				    .attr('style','width: 73px; text-align:center')
					.attr('name','aux_dtlibera')
					.attr('id','aux_dtlibera')
					.text('')									
				)
				.append($('<td>') // Coluna: Valor
					.attr('style','width: 73px; text-align:right')
					.attr('name','aux_vlcheque')
					.attr('id','aux_vlcheque')
					.text('')					
				)
				.append($('<td>') // Coluna: CMC-7
					.attr('style','width: 240px; text-align:center')
					.text(cmc7)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_dsdocmc7')
						.attr('id','aux_dsdocmc7')
						.attr('value',cmc7_sem_format)
					)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_cmc7')
						.attr('id','aux_cmc7')
						.attr('value',cmc7)
					)
				)
				.append($('<td>') // Coluna: Botão para REMOVER
					.attr('style','width: 15px; text-align:center')
					.append($('<img>')
						.attr('src', UrlImagens + 'geral/panel-delete_16x16.gif')
						.click(function(event) {
							
							var chequeRemove = document.getElementById($(this).parent().parent().attr('id'));
							chequeRemove.parentNode.removeChild(chequeRemove);

							return false;
						})
					)
				)
				.append($('<td>') // Coluna: Crítica
				    .attr('style','text-align:left')
					.attr('name','aux_dscritic')
					.attr('id','aux_dscritic')
					.text('')
				)
			);
		
		$('#btResgatar','#divBotoes').css({'display': 'none'});
		$('#btCancelar','#divBotoes').css({'display': 'none'});
		$('#btProsseguir','#divBotoes').css({'display': 'inline-block'});
	}
}

function validarResgate(){
	
	var aux_flgerro = false;
	var btnResgatar = $('#btResgatar','#divTela');
	var btnProsseguir = $('#btProsseguir','#divTela');
	if( $('#tbCheques tbody tr').length > 0 ){
		showMsgAguardo('Aguarde, validando cheque(s) informado(s) ...');
		
		var nrdconta = normalizaNumero( cNrdconta.val() );
		var dscheque = "";
		var corLinha  = 'corImpar';		

		$('#tbCheques tbody tr').each(function(){
			if( dscheque != "" ){
				dscheque += "|";
			}
			
			if ($("#aux_dscritic",this).text() != ''){					
				aux_flgerro = true;		
			}
			
			dscheque += $("#aux_dsdocmc7",this).val(); // CMC-7
			
			// Limpar a crítica
			$("#aux_dscritic",this).text('');
			$(this).css('background', '');
			// Adiciona a cor Zebrado na Tabela de Cheques
			$(this).attr('class', corLinha);
			if( corLinha == 'corImpar' ){
				corLinha = 'corPar';
			} else {
				corLinha = 'corImpar';
			}			
		});

		if( dscheque == "" ){
			unblockBackground();
			showError('error','Nenhum cheque foi informado para resgate.','Alerta - Aimaro','');
			return false;
		}
		
		if ((btnResgatar.css('display') == 'inline-block') && (!aux_flgerro)){
			hideMsgAguardo();			
			showConfirmacao('Confirma o resgate do(s) cheque(s) informado(s)?', 'Confirma&ccedil;&atilde;o - Aimaro', 'mostraAutorizaResgate();', 'return false;', 'sim.gif', 'nao.gif'); //bloqueiaFundo( $(\'#divRotina\') )
		}else{
			$.ajax({        
				type: 'POST',
				dataType: 'html',
				url: UrlSite + 'telas/custod/valida_resgate.php',
				async: false,
				data: {
					nrdconta: nrdconta,
					dscheque: dscheque,
					inresgte: 2, // Validação
					redirect: 'html_ajax'           
					}, 
				error: function(objAjax,responseError,objExcept) {
					hideMsgAguardo();           
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',"unblockBackground()");
				},
				success: function(response) {
					hideMsgAguardo();
					try {
						eval( response );					
						btnResgatar.css({'display': 'inline-block'});
						btnProsseguir.css({'display': 'none'});
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground();');
					}
				}
			});
		}
	} else {
		showError('error','Nenhum cheque foi informado para resgate','Alerta - Aimaro','unblockBackground();');
	}
	
}

function efetuaResgate(flgImpressao){
	
	showMsgAguardo('Aguarde, efetuando resgate do(s) cheque(s) informado(s) ...');

    var nrdconta = normalizaNumero($('#nrdconta', '#' + frmOpcao).val());
    var nomeresg = $('#nomeresg', '#frmAutorizar').val();
    var docuresg = $('#docuresg', '#frmAutorizar').val();
    var dscheque = "";

    $('#tbCheques tbody tr').each(function(){
        if( dscheque != "" ){
            dscheque += "|";
        }

        if ($("#aux_dscritic",this).text() != ''){                  
            aux_flgerro = true;     
        }

        dscheque += $("#aux_dsdocmc7",this).val(); // CMC-7
              
    });

    if( dscheque == "" ){
        unblockBackground();
        showError('error','Nenhum cheque foi informado para resgate.','Alerta - Aimaro','');
        return false;
    }

    $.ajax({
      type: 'POST',
      dataType: 'html',
      url: UrlSite + 'telas/custod/valida_resgate.php', 
		async: false,
		data: {
			nrdconta: nrdconta,
			dscheque: dscheque,
            nomeresg: nomeresg,
            docuresg: docuresg,
			inresgte: 1, // Efetua resgate
			redirect: 'html_ajax'           
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',"unblockBackground()");
		},
		success: function(response) {
			hideMsgAguardo();
			try {
                if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                    if (flgImpressao) {
                        var action = UrlSite + "telas/custod/comprovante_pdf.php";
                        carregaImpressaoAyllos("formImpres",action,'estadoInicial();');
                    }
                }
				eval( response );					
			} catch(error) {					
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground();');
			}
		}
	});
}

function validarCancelarResgate(){
	
	var aux_flgerro = false;
	var btnCancelar = $('#btCancelar','#divBotoes');
	var btnProsseguir = $('#btProsseguir','#divBotoes');
	if( $('#tbCheques tbody tr').length > 0 ){
		showMsgAguardo('Aguarde, validando cheque(s) informado(s) ...');
		
		var nrdconta = normalizaNumero( cNrdconta.val() );
		var dscheque = "";
		var corLinha  = 'corImpar';		

		$('#tbCheques tbody tr').each(function(){
			if( dscheque != "" ){
				dscheque += "|";
			}
			
			if ($("#aux_dscritic",this).text() != ''){					
				aux_flgerro = true;		
			}
			
			dscheque += $("#aux_dsdocmc7",this).val(); // CMC-7
			
			// Limpar a crítica
			$("#aux_dscritic",this).text('');
			$(this).css('background', '');
			// Adiciona a cor Zebrado na Tabela de Cheques
			$(this).attr('class', corLinha);
			if( corLinha == 'corImpar' ){
				corLinha = 'corPar';
			} else {
				corLinha = 'corImpar';
			}			
		});

		if( dscheque == "" ){
			unblockBackground();
			showError('error','Nenhum cheque foi informado para cancelamento de resgate.','Alerta - Aimaro','');
			return false;
		}
		
		if ((btnCancelar.css('display') == 'inline-block') && (!aux_flgerro)){
			hideMsgAguardo();			
			showConfirmacao('Confirma o cancelamento de resgate do(s) cheque(s) informado(s)?', 'Confirma&ccedil;&atilde;o - Aimaro', 'efetuaCancelarResgate('+nrdconta+',"'+dscheque+'");', 'return false;', 'sim.gif', 'nao.gif');
		}else{
			$.ajax({        
				type: 'POST',
				dataType: 'html',
				url: UrlSite + 'telas/custod/valida_cancela_resgate.php', 
				async: false,
				data: {
					nrdconta: nrdconta,
					dscheque: dscheque,
					inresgte: 2, // Validação
					redirect: 'html_ajax'           
					}, 
				error: function(objAjax,responseError,objExcept) {
					hideMsgAguardo();           
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',"unblockBackground()");
				},
				success: function(response) {
					hideMsgAguardo();
					try {
						eval( response );					
						btnCancelar.css({'display': 'inline-block'});
						btnProsseguir.css({'display': 'none'});
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground();');
					}
				}
			});
		}
	} else {
		showError('error','Nenhum cheque foi informado para cancelamento de resgate','Alerta - Aimaro','unblockBackground();');
	}
	
}

function efetuaCancelarResgate(nrdconta,dscheque){
	
	showMsgAguardo('Aguarde, efetuando cancelamento de resgate do(s) cheque(s) informado(s) ...');
	
	$.ajax({        
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/custod/valida_cancela_resgate.php', 
		async: false,
		data: {
			nrdconta: nrdconta,
			dscheque: dscheque,
			inresgte: 1, // Efetua resgate
			redirect: 'html_ajax'           
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();           
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',"unblockBackground()");
		},
		success: function(response) {
			hideMsgAguardo();
			try {
				eval( response );					
			} catch(error) {						
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground();');
			}
		}
	});
}

function limpaGridCheques(){
	
	$('#tbCheques tbody tr').each(function(){				
		$(this).remove();		
	});
	
	return false;
}

function trocaBotoesL(){

	var btnProsseguir = $('#btProsseguir','#divBotoes');
	var btnConciliar  = $('#btConciliar','#divBotoes');
	var btnConciliarT = $('#btConciliarT','#divBotoes');
	var btnCustodiar  = $('#btCustodiar','#divBotoes');
	var btnImprimir   = $('#btImprimir','#divBotoes');
	var btnExcluir    = $('#btnExcluir','#divBotoes');		

	if ($('#divRemessa').css('display') == 'block'){
		
		btnProsseguir.css({'display': 'none'});
		btnConciliar.css({'display': 'inline-block'});
		btnConciliarT.css({'display': 'inline-block'});
		btnCustodiar.css({'display': 'inline-block'});
		btnImprimir.css({'display': 'inline-block'});
		btnExcluir.css({'display': 'inline-block'});
		
	}else{
		
		btnProsseguir.css({'display': 'inline-block'});
		btnConciliar.css({'display': 'none'});
		btnConciliarT.css({'display': 'none'});
		btnCustodiar.css({'display': 'none'});
		btnImprimir.css({'display': 'none'});
		btnExcluir.css({'display': 'none'});

	}
	
}

function buscaRemessas(nriniseq, nrregist){

	showMsgAguardo('Aguarde, buscando remessa(s) de cheque(s) custodiado(s) ...');
	
	var dtinicst, dtfimcst, cdagenci, insithcc;
	
	nrdconta = normalizaNumero(cNrdconta.val());
	dtinicst = cDtinicst.val();
	dtfimcst = cDtfimcst.val();
	cdagenci = cCdagenci.val();
	insithcc = cInsithcc.val();	
	
	$.ajax({        
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/custod/busca_remessas.php', 
		data: {
			nrdconta: nrdconta,
			dtinicst: dtinicst,
			dtfimcst: dtfimcst,
			cdagenci: cdagenci,
			insithcc: insithcc,
			nrregist: nrregist,
			nriniseq: nriniseq,
			redirect: 'html_ajax'           
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();           
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',"unblockBackground()");
		},
		success: function(response) {
			hideMsgAguardo();
			if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
				try{
					$('#divRemessa').html(response);
					$('#divRemessa').css({'display': 'block'});
					formataTabelaL();
					$('#divPesquisaRodape', '#divRemessa').formataRodapePesquisa();					
					
					trocaBotoesL();
				} catch(error){
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground();');
				}
			}else{
				try {
					eval( response );					
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground();');
				}
			}
		}
	});
	
}

function buscaChequesRemessa(){
	
	if (glbTabNrremret == undefined) {
		showError('error','Nenhuma remessa selecionada.','Alerta - Aimaro',"unblockBackground()");
		return false;
	}
	showMsgAguardo('Aguarde, buscando cheques da remessa...');
	
	$.ajax({        
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/custod/busca_cheques_remessa.php', 
		data: {
			nrdconta: glbTabNrdconta,
			nrconven: glbTabNrconven,
			nrremret: glbTabNrremret,
			intipmvt: glbTabIntipmvt,
			insithcc: glbTabInsithcc,
			redirect: 'html_ajax'           
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();           
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',"unblockBackground()");
		},
		success: function(response) {
			hideMsgAguardo();
			if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
				try{
					$('#divChqRemessa').html(response);
					mostraChequesRemessa()
				} catch(error){
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground();');
				}
			}else{
				try {
					eval( response );					
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground();');
				}
			}
		}
	});
}

function formataTabelaChequesL(){
	
    // tabela
    var divRegistro = $('div.divRegistros', '#divChqRemessa');
    var tabela = $('table', divRegistro);

    $('#' + frmOpcao).css({'margin-top': '5px'});
    divRegistro.css({'height': '207px', 'padding-bottom': '2px'});

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '50px';
    arrayLargura[1] = '50px';
    arrayLargura[2] = '50px';
    arrayLargura[3] = '100px';
    arrayLargura[4] = '70px';
    arrayLargura[5] = '90px';
    arrayLargura[6] = '60px';
    arrayLargura[7] = '350px';
    arrayLargura[8] = '25px';
	
    var arrayAlinha = new Array();
    arrayAlinha[0] = 'right';
    arrayAlinha[1] = 'right';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'right';
    arrayAlinha[4] = 'right';
    arrayAlinha[5] = 'right';
    arrayAlinha[6] = 'center';
    arrayAlinha[7] = 'left';
    arrayAlinha[8] = 'center';
    arrayAlinha[9] = 'center';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, 'mostraDetalhamentoCheque()');
	
	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		glbTabCompcheq = $(this).find('#compcheq > span').text() ;
		glbTabCddbanco = $(this).find('#cddbanco > span').text() ;
		glbTabCdagenci = $(this).find('#cdagenci > span').text() ;
		glbTabNrctachq = $(this).find('#nrctachq > span').text() ;
		glbTabNrcheque = $(this).find('#nrcheque > span').text() ;
		glbTabVlcheque = $(this).find('#vlcheque > span').text() ;
		glbTabInconcil = $(this).find('td > #inconcil').val() ;
		glbTabCdocorre = $(this).find('#cdocorre > span').text() ;
		glbTabDsdocmc7 = $(this).find('#dsdocmc7').val();
	});
		
	$('table > tbody > tr:eq(0)', divRegistro).click();	
	
}

function mostraChequesRemessa(){

	var btnProsseguir = $('#btProsseguir','#divBotoes');
	var btnConciliar  = $('#btConciliar','#divBotoes');
	var btnConciliarT = $('#btConciliarT','#divBotoes');
	var btnCustodiar  = $('#btCustodiar','#divBotoes');
	var btnImprimir   = $('#btImprimir','#divBotoes');
	var btnExcluir    = $('#btnExcluir','#divBotoes');

	// Mostra/esconde Divs 
	$('#divFiltros').css({'display': 'none'});
	$('#divAssociado').css({'display': 'none'});
	$('#divRemessa').css({'display': 'none'});
	$('#divChqRemessa').css({'display': 'block'});
	$('#divCheque').css({'display': 'block'});
	$('#divAssociadoChq').css({'display': 'block'});
	// Formata tabela de cheques da remessa
	formataTabelaChequesL();
	
	// Mostra/esconde botões
	btnConciliar.css({'display': 'none'});
	btnConciliarT.css({'display': 'none'});
	btnCustodiar.css({'display': 'none'});
	btnImprimir.css({'display': 'none'});
	btnExcluir.css({'display': 'none'});
	
	if (glbTabInsithcc != 'Processado')
		btnProsseguir.css({'display': 'inline-block'});
	
	// Controla valores e foco dos campos
	cNrctarem.val(glbTabNrctarem);
	cNmttlrem.val(glbTabNmprimtl);
	cNmarquiv.val(glbTabNmarquiv);
	cInsithc2.val(glbTabInsithcc);
	cNrremret.val(glbTabNrremret);
	cDsorigem.val(glbTabDsorigem);
	
	if (glbTabInsithcc == 'Pendente'){
		cDsdocmc7.habilitaCampo();
		cDsdocmc7.focus();
	}else{
		cDsdocmc7.desabilitaCampo();
	}
}

function verificaInconcil(inconcil){
	if (inconcil.checked == false) {
		inconcil.disabled = true;
		inconcil.value = 0;
	}
}

function conciliaChequeGrid(){
	
	if (glbTabInsithcc == 'Processado')
		return false;
	
	var divRegistro = $('div.divRegistros', '#divChqRemessa');
	var dsdocmc7_sf = cDsdocmc7.val().replace(/[^0-9]/g, "").substr(0,30);
	var flgEncontrou = 0;
	
	$('table > tbody > tr', divRegistro).each(function(){		
		if ($(this).find('#dsdocmc7').val() == dsdocmc7_sf){
			$(this).find('td > #inconcil').prop('checked', true);
			$(this).find('td > #inconcil').prop('disabled', false);	
			$(this).find('td > #inconcil').val('1');
			mostraMsgSucesso();
			flgEncontrou = 1;
			return false;
		}
	});
	if (flgEncontrou == 0){
		mostraMsgErro();
	}
	cDsdocmc7.val('');
}

// Detalhamento Cheque
function mostraDetalhamentoCheque() {
	
	showMsgAguardo('Aguarde, buscando detalhamento do cheque...');

	// Executa script através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/custod/detalhamento_cheque.php', 
		data: {			
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',"unblockBackground()");
		},
		success: function(response) {			
			$('#divRotina').css({'height': '400px'});						
			$('#divRotina').html(response);				
            exibeRotina($('#divRotina'));			
			buscaDetalheCheque();
		}				
	});
	
	return false;
	
}

function buscaDetalheCheque(){
	
	// Executa script através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/custod/form_detalhe_cheque.php', 
		data: {			
			nrdconta: glbTabNrdconta,
			nmprimtl: glbTabNmprimtl,
			cddbanco: glbTabCddbanco,
			cdagenci: glbTabCdagenci,
			nrctachq: glbTabNrctachq,	
			nrcheque: glbTabNrcheque,	
			vlcheque: glbTabVlcheque,
			nrremret: glbTabNrremret,
			nrconven: glbTabNrconven,
			intipmvt: glbTabIntipmvt,
			dsdocmc7: glbTabDsdocmc7,
			dtmvtolt: glbTabDtmvtolt,
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',"unblockBackground()");
		},
		success: function(response) {			
			$('#divDetalhamento').html(response);			
			formataDetalheCheque();
		}				
	});
	
	return false;
	
}

function formataDetalheCheque(){
	
	var rNrdconta_det, rCddbanco_det, rCdagectl_det, rNrctachq_det, rNrcheque_det,
		rDsdocmc7_det, rNrcpfcgc_det, rDsemiten_det, rDtmvtolt_det, rCdagenci_det,
		rCdbccxlt_det, rNrdolote_det, rDtemissa_det, rDtlibera_det, rVlcheque_det,
		rDsocorre_det;
		
	var cNrdconta_det, cNmprimtl_det, cCddbanco_det, cCdagectl_det, cNrctachq_det, 
		cDsdocmc7_det, cNrcpfcgc_det, cDsemiten_det, cDtmvtolt_det, cCdagenci_det,
		cCdbccxlt_det, cNrdolote_det, cDtemissa_det, cDtlibera_det, cVlcheque_det,
		cNrcheque_det, cDsocorre_det, cTodosDetalheChq;
    var btnAlterarChq = $('#btAlterarChq', '#divBotoesDetalhe');
	var vr_dtemissa;
	highlightObjFocus($('#frmDetalheCheque'));
	
	cTodosDetalheChq = $('input[type="text"]', '#frmDetalheCheque');
    // label
    rNrdconta_det = $('label[for="nrdconta"]', '#frmDetalheCheque');
	rCddbanco_det = $('label[for="cddbanco"]', '#frmDetalheCheque');
	rCdagectl_det = $('label[for="cdagectl"]', '#frmDetalheCheque');
	rNrctachq_det = $('label[for="nrctachq"]', '#frmDetalheCheque');
	rNrcheque_det = $('label[for="nrcheque"]', '#frmDetalheCheque');
	rDsdocmc7_det = $('label[for="dsdocmc7"]', '#frmDetalheCheque');
	rNrcpfcgc_det = $('label[for="nrcpfcgc"]', '#frmDetalheCheque');
	rDsemiten_det = $('label[for="dsemiten"]', '#frmDetalheCheque');
	rDtmvtolt_det = $('label[for="dtmvtolt"]', '#frmDetalheCheque');
	rCdagenci_det = $('label[for="cdagenci"]', '#frmDetalheCheque');
	rCdbccxlt_det = $('label[for="cdbccxlt"]', '#frmDetalheCheque');
	rNrdolote_det = $('label[for="nrdolote"]', '#frmDetalheCheque');
	rDtemissa_det = $('label[for="dtemissa"]', '#frmDetalheCheque');
	rDtlibera_det = $('label[for="dtlibera"]', '#frmDetalheCheque');
	rVlcheque_det = $('label[for="vlcheque"]', '#frmDetalheCheque');;
	rDsocorre_det = $('label[for="dsocorre"]', '#frmDetalheCheque');;
	
    rNrdconta_det.css({'width': '68px'}).addClass('rotulo');
    rCddbanco_det.css({'width': '61px'}).addClass('rotulo');
    rCdagectl_det.css({'width': '55px'}).addClass('rotulo-linha');
    rNrctachq_det.css({'width': '44px'}).addClass('rotulo-linha');
    rNrcheque_det.css({'width': '50px'}).addClass('rotulo-linha');
    rDsdocmc7_det.css({'width': '61px'}).addClass('rotulo');
    rNrcpfcgc_det.css({'width': '61px'}).addClass('rotulo');
    rDsemiten_det.css({'width': '60px'}).addClass('rotulo-linha');
    rDtmvtolt_det.css({'width': '101px'}).addClass('rotulo');
    rCdagenci_det.css({'width': '30px'}).addClass('rotulo-linha');
    rCdbccxlt_det.css({'width': '75px'}).addClass('rotulo-linha');
    rNrdolote_det.css({'width': '35px'}).addClass('rotulo-linha');
    rDtemissa_det.css({'width': '101px'}).addClass('rotulo');
    rDtlibera_det.css({'width': '60px'}).addClass('rotulo-linha');
    rVlcheque_det.css({'width': '40px'}).addClass('rotulo-linha');
    rDsocorre_det.css({'width': '70px'}).addClass('rotulo');

    // input
    cNrdconta_det = $('#nrdconta', '#frmDetalheCheque');
    cNmprimtl_det = $('#nmprimtl', '#frmDetalheCheque');
    cCddbanco_det = $('#cddbanco', '#frmDetalheCheque');
    cCdagectl_det = $('#cdagectl', '#frmDetalheCheque');
    cNrctachq_det = $('#nrctachq', '#frmDetalheCheque');
    cNrcheque_det = $('#nrcheque', '#frmDetalheCheque');
    cDsdocmc7_det = $('#dsdocmc7', '#frmDetalheCheque');
    cNrcpfcgc_det = $('#nrcpfcgc', '#frmDetalheCheque');
    cDsemiten_det = $('#dsemiten', '#frmDetalheCheque');
    cDtmvtolt_det = $('#dtmvtolt', '#frmDetalheCheque');
    cCdagenci_det = $('#cdagenci', '#frmDetalheCheque');
    cCdbccxlt_det = $('#cdbccxlt', '#frmDetalheCheque');
    cNrdolote_det = $('#nrdolote', '#frmDetalheCheque');
    cDtemissa_det = $('#dtemissa', '#frmDetalheCheque');
    cDtlibera_det = $('#dtlibera', '#frmDetalheCheque');
    cVlcheque_det = $('#vlcheque', '#frmDetalheCheque');
    cDsocorre_det = $('#dsocorre', '#frmDetalheCheque');

    cNrdconta_det.css({'width': '75px'}).addClass('conta');
    cNmprimtl_det.css({'width': '367px'});
    cCddbanco_det.css({'width': '40px'}).addClass('inteiro');
    cCdagectl_det.css({'width': '50px'}).addClass('inteiro');
    cNrctachq_det.css({'width': '100px'}).addClass('inteiro');
    cNrcheque_det.css({'width': '80px'}).addClass('inteiro');
    cDsdocmc7_det.css({'width': '350px'});
    cNrcpfcgc_det.css({'width': '120px'});
    cDsemiten_det.css({'width': '252px'});
    cDtmvtolt_det.css({'width': '80px'}).addClass('data');
    cCdagenci_det.css({'width': '40px'}).addClass('inteiro');
    cCdbccxlt_det.css({'width': '40px'}).addClass('inteiro');
    cNrdolote_det.css({'width': '80px'}).addClass('inteiro');
    cDtemissa_det.css({'width': '80px'}).addClass('data');
    cDtlibera_det.css({'width': '80px'}).addClass('data');
	cVlcheque_det.css({'width': '125px'}).addClass('moeda');
	cDsocorre_det.css({'width': '430px'});

	cTodosDetalheChq.desabilitaCampo();
	
	layoutPadrao();
	
	if (glbTabIntipmvt == 3  && glbTabInsithcc != 'Processado') {
		btnAlterarChq.css('display', 'inline-block');
		vr_dtemissa = cDtemissa_det.val();
		cDtemissa_det.habilitaCampo().val(vr_dtemissa).select();
		cDtlibera_det.habilitaCampo();
		cVlcheque_det.habilitaCampo();
	}

	// Data Emissão
    cDtemissa_det.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se é a tecla TAB ou ENTER, 
        if (e.keyCode == 13) {
            cDtlibera_det.focus();
            return false;
        }

    });

	// Data Boa
    cDtlibera_det.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se é a tecla TAB ou ENTER, 
        if (e.keyCode == 13) {
            cVlcheque_det.focus();
            return false;
        }

    });
	
	// Valor do cheque
	cVlcheque_det.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
            confirmaAlteraDetalhe();
            return false;
        }
    }); 
	
    hideMsgAguardo();
    bloqueiaFundo($('#divRotina'));
	return false;
}

function confirmaAlteraDetalhe(){
	showConfirmacao('Confirma a altera&ccedil;&atilde;o dos dados do cheque?', 'Confirma&ccedil;&atilde;o - Aimaro', 'alteraDetalheCheque();', 'return false;', 'sim.gif', 'nao.gif');
	return false;
}

function alteraDetalheCheque(){
	
	showMsgAguardo('Aguarde, alterando detalhe do cheque...');

	var dtemissa, dtlibera, vlcheque;
	
	dtemissa = $('#dtemissa', '#frmDetalheCheque').val();
	dtlibera = $('#dtlibera', '#frmDetalheCheque').val();
	vlcheque = normalizaNumero($('#vlcheque', '#frmDetalheCheque').val());
	vlcheque = vlcheque.replace(',', '.');
	
	// Executa script através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/custod/altera_detalhe_cheque.php', 
		data: {			
			nrdconta: glbTabNrdconta,
			nrremret: glbTabNrremret,
			nrconven: glbTabNrconven,
			intipmvt: glbTabIntipmvt,
			dsdocmc7: glbTabDsdocmc7,
			dtemissa: dtemissa,
			dtlibera: dtlibera,
			vlcheque: vlcheque,
			inconcil: glbTabInconcil,
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',"unblockBackground()");
		},
		success: function(response) {			
			eval(response);			
		}				
	});
	
	return false;
	
}

function confirmaExcluiCheque(){
	if (glbTabInsithcc == 'Pendente'){		
		showConfirmacao('Confirma a exclus&atilde;o do cheque?', 'Confirma&ccedil;&atilde;o - Aimaro', 'excluiChequeRemessa();', 'return false;', 'sim.gif', 'nao.gif');
	}
	return false;
}

function excluiChequeRemessa(){
	
	showMsgAguardo('Aguarde, excluindo cheque da remessa...');
	
	// Executa script através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/custod/exclui_cheque_remessa.php', 
		data: {			
			nrdconta: glbTabNrdconta,
			nrremret: glbTabNrremret,
			nrconven: glbTabNrconven,
			intipmvt: glbTabIntipmvt,
			dsdocmc7: glbTabDsdocmc7,
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',"unblockBackground()");
		},
		success: function(response) {			
			eval(response);		
		}				
	});
	
	return false;
	
}

function confirmaConciliarCheques(){
	showConfirmacao('Confirma a execu&ccedil;&atilde;o da opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Aimaro', 'conciliarCheques();', 'return false;', 'sim.gif', 'nao.gif');
}

function conciliarCheques(){
			
	showMsgAguardo('Aguarde, conciliando cheque(s) da remessa...');
	
	var inconcilChq, inconcilChqOrig;
	var divRegistro = $('div.divRegistros', '#divChqRemessa');
	var dscheque = '';
	$('table > tbody > tr', divRegistro).each(function(){
		inconcilChq = $(this).find('td > #inconcil').val();
		inconcilChqOrig = $(this).find('td > #inconcil_original').val();
	
		if (inconcilChq != inconcilChqOrig){
			
			if( dscheque != '' ){
				dscheque += '|';
			}
			
			dscheque += $(this).find('#dsdocmc7').val() + '#' + inconcilChq;
		}
	});
	
	// Executa script através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/custod/concilia_cheques.php', 
		data: {			
			nrdconta: glbTabNrdconta,
			nrremret: glbTabNrremret,
			nrconven: glbTabNrconven,
			intipmvt: glbTabIntipmvt,
			dscheque: dscheque,
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',"unblockBackground()");
		},
		success: function(response) {			
			eval(response);		
		}				
	});
	
	return false;
}

function confirmaConciliarTodos(){
	
	if (glbTabNrremret == undefined) {
		showError('error','Nenhuma remessa selecionada.','Alerta - Aimaro',"unblockBackground()");
		return false;
	}
	showConfirmacao('Confirma a execu&ccedil;&atilde;o da opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Aimaro', 'conciliarTodosCheques();', 'return false;', 'sim.gif', 'nao.gif');
}

function conciliarTodosCheques(){
			
	showMsgAguardo('Aguarde, conciliando cheque(s) da remessa...');
		
	// Executa script através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/custod/concilia_todos_cheques.php', 
		data: {			
			nrdconta: glbTabNrdconta,
			nrremret: glbTabNrremret,
			nrconven: glbTabNrconven,
			intipmvt: glbTabIntipmvt,
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',"unblockBackground()");
		},
		success: function(response) {			
			eval(response);		
		}				
	});
	
	return false;
}

function validaImprimirCustodL(){

    if (glbTabNrremret == undefined) {
		showError('error','Nenhuma remessa selecionada.','Alerta - Aimaro',"unblockBackground()");
		return false;
	}
	if (glbTabInsithcc == 'Pendente'){
        showError('error','Impress&atilde;o apenas permitida para remessas processadas.','Alerta - Aimaro',"unblockBackground()");
		return false;
    }

	ImprimirCustodL();
}

function ImprimirCustodL(){

	$('#formImpres').html('');

	// Insiro input do tipo hidden do formulário para enviá-los posteriormente
	$('#formImpres').append('<input type="hidden" id="cddopcao" name="cddopcao" />');
	$('#formImpres').append('<input type="hidden" id="nrdconta" name="nrdconta" />');
	$('#formImpres').append('<input type="hidden" id="nrremret" name="nrremret" />');
	$('#formImpres').append('<input type="hidden" id="sidlogin" name="sidlogin" />');
	
	// Agora insiro os devidos valores nos inputs criados
	$('#cddopcao','#formImpres').val( 'C' );
	$('#nrdconta','#formImpres').val( glbTabNrdconta );
	$('#nrremret','#formImpres').val( glbTabNrremret );
	$('#sidlogin','#formImpres').val( $('#sidlogin','#frmMenu').val() );
    
	var action = UrlSite + 'telas/custod/imprimir_custod_l.php';
	
	carregaImpressaoAyllos("formImpres",action,"bloqueiaFundo(divRotina);hideMsgAguardo();");
     
}

function verificaChqConc(){
	
	if (glbTabNrremret == undefined) {
		showError('error','Nenhuma remessa selecionada.','Alerta - Aimaro',"unblockBackground()");
		return false;
	}
	
	showMsgAguardo('Aguarde, verificando cheque(s) conciliado(s) da remessa...');
		
	// Executa script através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/custod/verifica_cheques_conciliados.php', 
		data: {			
			nrdconta: glbTabNrdconta,
			nrremret: glbTabNrremret,
			nrconven: glbTabNrconven,
			intipmvt: glbTabIntipmvt,
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',"unblockBackground()");
		},
		success: function(response) {			
			hideMsgAguardo();
			eval(response);		
		}				
	});
	
	return false;	
	
}

function confirmaCustodiaConc(flgcqcon, flgocorr){

	if (flgcqcon == '1'){
		showConfirmacao('Existe(m) cheque(s) n&atilde;o conciliado(s). Deseja continuar?', 'Confirma&ccedil;&atilde;o - Aimaro', 'confirmaCustodiaOcor(' + flgocorr + ');', 'return false;', 'sim.gif', 'nao.gif');
	}else{
		confirmaCustodiaOcor(flgocorr);
	}
	
	return false;
}

function confirmaCustodiaOcor(flgocorr){
	if (flgocorr == '1'){
		showConfirmacao('Existe(m) cheque(s) com ocorr&ecirc;ncias. Deseja continuar?', 'Confirma&ccedil;&atilde;o - Aimaro', 'confirmaCustodiaGeral();', 'return false;', 'sim.gif', 'nao.gif');
	}else{
		confirmaCustodiaGeral();
	}
	return false;
}

function confirmaCustodiaGeral(){
		
	showConfirmacao('Esta operacao ir&aacute; custodiar esta remessa. Deseja continuar?', 'Confirma&ccedil;&atilde;o - Aimaro', 'custodiarRemessa();', 'return false;', 'sim.gif', 'nao.gif');
	
	return false;
}

function custodiarRemessa(){
	
	showMsgAguardo('Aguarde, efetuando cust&oacute;dia da remessa...');
		
	// Executa script através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/custod/efetua_custodia_remessa.php', 
		data: {			
			nrdconta: glbTabNrdconta,
			nrremret: glbTabNrremret,
			nrconven: glbTabNrconven,
			intipmvt: glbTabIntipmvt,
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',"unblockBackground()");
		},
		success: function(response) {			
			hideMsgAguardo();
			eval(response);		
		}				
	});
	
	return false;	
}

function confirmaExclusao(){

	if (glbTabNrremret == undefined) {
		showError('error','Nenhuma remessa selecionada.','Alerta - Aimaro',"unblockBackground()");
		return false;
	}
	
	showConfirmacao('Esta operacao ir&aacute; excluir esta remessa. Deseja continuar?', 'Confirma&ccedil;&atilde;o - Aimaro', 'excluirRemessa();', 'return false;', 'sim.gif', 'nao.gif');
	
	return false;

}

function excluirRemessa(){
	
	showMsgAguardo('Aguarde, excluindo remessa...');
		
	// Executa script através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/custod/exclui_remessa.php', 
		data: {			
			nrdconta: glbTabNrdconta,
			nrremret: glbTabNrremret,
			nrconven: glbTabNrconven,
			intipmvt: glbTabIntipmvt,
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',"unblockBackground()");
		},
		success: function(response) {			
			hideMsgAguardo();
			eval(response);		
		}				
	});
	
	return false;	
}

// opcao i
function formataOpcaoI() {

    // label
    rNrdconta = $('label[for="nrdconta"]', '#' + frmOpcao);	
	rDtchqbom = $('label[for="dtchqbom"]','#'+frmOpcao); 
	rDtemissa = $('label[for="dtemissa"]','#'+frmOpcao); 
	rVlcheque = $('label[for="vlcheque"]','#'+frmOpcao);        
	rDsdocmc7 = $('label[for="dsdocmc7"]','#'+frmOpcao);        

    rNrdconta.css({'width': '100px'}).addClass('rotulo');
	rDtchqbom.addClass('rotulo').css({'width':'100px'});
	rDtemissa.addClass('rotulo-linha').css({'width':'120px'});
	rVlcheque.addClass('rotulo-linha').css({'width':'60px'});
	rDsdocmc7.addClass('rotulo-linha').css({'width':'65px'});

    // input
    cNrdconta = $('#nrdconta', '#' + frmOpcao);
    cNmprimtl = $('#nmprimtl', '#' + frmOpcao);
	cDtchqbom = $('#dtchqbom','#'+frmOpcao); 
	cDtemissa = $('#dtemissa','#'+frmOpcao); 
	cVlcheque = $('#vlcheque','#'+frmOpcao); 
	cDsdocmc7 = $('#dsdocmc7','#'+frmOpcao); 
	btnAdd	  = $('#btnAdd','#'+frmOpcao);
	
    cNrdconta.css({'width': '75px'}).addClass('pesquisa conta');	
    cNmprimtl.css({'width': '517px'});
	cDtchqbom.css({'width':'75px'}).addClass('data');	
	cDtemissa.css({'width':'75px'}).addClass('data');	
	cVlcheque.css({'width':'110px'}).addClass('moeda');
	cDsdocmc7.css({'width':'290px'}).attr('maxlength','34');

	
    // Outros	
    cTodosOpcao.desabilitaCampo();

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
	// Data boa
	cDtchqbom.unbind('keydown').bind('keydown', function(e) {
		// Se é a tecla TAB ou ENTER, 
        if (e.keyCode == 9 || e.keyCode == 13 ) {
            cDtemissa.focus();
            return false;
        }
	});
	cDtemissa.unbind('keydown').bind('keydown', function(e) {
		// Se é a tecla TAB ou ENTER, 
        if (e.keyCode == 9 || e.keyCode == 13 ) {
            cVlcheque.focus();
            return false;
        }
	});
	// Valor do cheque
	cVlcheque.unbind('keydown').bind('keydown', function(e) {
		// Se é a tecla TAB ou ENTER, 
        if (e.keyCode == 9 || e.keyCode == 13 ) {
            cDsdocmc7.focus();
            return false;
        }
	});
	// CMC 7
	cDsdocmc7.unbind('keyup').bind('keyup', function(e) {
		formataCampoCmc7(false);
		return false;
	});
	cDsdocmc7.unbind('blur').bind('blur', function(e) {
		formataCampoCmc7(true);
		return false;
	});
	cDsdocmc7.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		

		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			btnAdd.click();
			return false;

		}
	});	
	
	btnAdd.unbind('click').bind('click', function() {
		if ( divError.css('display') == 'block' ) { return false; }		

		validaChequeI();
		return false;
	});		
	

	formataTabelaI();
	formataTabelaEmitenI();
	layoutPadrao(); 
    controlaPesquisas();
	
    return false;

}

function formataTabelaI(){
	// Tabela
	$('#tabCustch').css({'display':'block'});
    $('#divConteudo').css({'display':'block'});

    var divRegistro = $('div.divRegistros', '#tabCustch');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

    $('#tabCustch').css({'margin-top':'5px'});
	divRegistro.css({'height':'305px','width':'1000px','padding-bottom':'2px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
    arrayLargura[0] = '67px';
    arrayLargura[1] = '67px';
	arrayLargura[2] = '90px';
	arrayLargura[3] = '50px';
	arrayLargura[4] = '50px';
	arrayLargura[5] = '90px';
	arrayLargura[6] = '90px';
	arrayLargura[7] = '234px';
	arrayLargura[8] = '15px';
	arrayLargura[9] = '';

    var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'left';
	arrayAlinha[3] = 'left';
	arrayAlinha[4] = 'left';
	arrayAlinha[5] = 'left';
	arrayAlinha[6] = 'left';
	arrayAlinha[7] = 'left';
	arrayAlinha[8] = 'left';
	arrayAlinha[9] = 'left';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);
	hideMsgAguardo();
	return false;
}

function mostraDivEmiten(){
	
	$('#divCustch').css({'display': 'none'});
	$('#divEmiten').css({'display':'block'});		
	
	trocaBotoesI();
	cNrcpfcnpj = [];
	cDsemiten = [];

}

function formataTabelaEmitenI(){
	// Tabela
    var divRegistro = $('div.divRegistros', '#divEmiten');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
	
    $('#divEmiten').css({'margin-top':'5px'});
	divRegistro.css({'height':'305px','width':'1000px','padding-bottom':'2px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '50px';
	arrayLargura[1] = '50px';
	arrayLargura[2] = '90px';
	arrayLargura[3] = '150px';
	arrayLargura[4] = '350px';
	
    var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'right';
    arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'center';
	arrayAlinha[4] = 'center';
	arrayAlinha[5] = 'left';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);
	return false;
}

function trocaBotoesI(){

	var btnProsseguir = $('#btProsseguir','#divBotoes');
	var btnNovoCheque = $('#btNovo','#divBotoes');
	var btnValidarCus = $('#btValidar','#divBotoes');
	var btnFinalizar  = $('#btFinalizar','#divBotoes');		

	if ($('#divCustch').css('display') == 'block'){
		
		btnProsseguir.css({'display': 'none'});
		btnNovoCheque.css({'display': 'inline-block'});
		btnValidarCus.css({'display': 'inline-block'});
		
	}else{
		
		btnProsseguir.css({'display': 'inline-block'});
		btnNovoCheque.css({'display': 'none'});
		btnValidarCus.css({'display': 'none'});

	}
	
}

function adicionaChequeI(){

	var data    = cDtchqbom.val();
	var dataEmi = cDtemissa.val();
	var valor   = cVlcheque.val();
	var cmc7    = cDsdocmc7.val();
	var cmc7_sem_format  = cmc7.replace(/[^0-9]/g, "").substr(0,30);
	
	var idCriar = "id_".concat(cmc7_sem_format);

	//Desmontar o CMC-7 para exibir os campos
	var banco     = cmc7_sem_format.substr(0,3);
	var agencia   = cmc7_sem_format.substr(3,4);	
	var cheque    = cmc7_sem_format.substr(11,6);
	var conta     = 0;
	var qtdLinhas = $('#tbCheques tbody tr').length;
	var corLinha  = (qtdLinhas%2 === 0) ? 'corImpar' : 'corPar';
	
	if( banco == 1 ){
	    conta = mascara(normalizaNumero(cmc7_sem_format.substr(21,8)),'####.###-#');
	} else {
		conta = mascara(normalizaNumero(cmc7_sem_format.substr(19,10)),'######.###-#');
	}
	
	if(!document.getElementById(idCriar)) {				
		
		// Criar a linha na tabela
		$("#tbCheques > tbody")
			.prepend($('<tr>') // Linha
			    .attr('id',idCriar)
				.attr('class',corLinha)
				.append($('<td>') // Coluna: Data Boa
				    .attr('style','width: 67px; text-align:left')
					.text(data)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_dtchqbom')
						.attr('id','aux_dtchqbom')
						.attr('value',data)
					)
				)
				.append($('<td>') // Coluna: Data de Emissão
				    .attr('style','width: 67px; text-align:left')
					.text(dataEmi)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_dtemissa')
						.attr('id','aux_dtemissa')
						.attr('value',dataEmi)
					)
				)
				.append($('<td>') // Coluna: Valor
					.attr('style','width: 90px; text-align:right')
					.text(valor)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_vlcheque')
						.attr('id','aux_vlcheque')
						.attr('value',valor)
					)
				)
				.append($('<td>') // Coluna: Banco
					.attr('style','width: 50px; text-align:right')
					.text(banco)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_banco')
						.attr('id','aux_banco')
						.attr('value',banco)
					)
				)
				.append($('<td>')  // Coluna: Agência
					.attr('style','width: 50px; text-align:right')
					.text(agencia)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_agencia')
						.attr('id','aux_agencia')
						.attr('value',agencia)
					)
				)
				.append($('<td>') // Coluna: Número do Cheque
					.attr('style','width: 90px; text-align:right')
					.text(cheque)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_cheque')
						.attr('id','aux_cheque')
						.attr('value',cheque)
					)
				)
				.append($('<td>') // Coluna: Número da Conta
					.attr('style','width: 90px; text-align:right')
					.text(conta)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_conta')
						.attr('id','aux_conta')
						.attr('value',conta)
					)
				)
				.append($('<td>') // Coluna: CMC-7
					.attr('style','width: 230px; text-align:right')
					.text(cmc7)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_dsdocmc7')
						.attr('id','aux_dsdocmc7')
						.attr('value',cmc7_sem_format)
					)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_cmc7')
						.attr('id','aux_cmc7')
						.attr('value',cmc7)
					)
				)
				.append($('<td>') // Coluna: Botão para REMOVER
					.attr('style','width: 15px; text-align:center')
					.append($('<img>')
						.attr('src', UrlImagens + 'geral/panel-delete_16x16.gif')
						.click(function(event) {
							
							var chequeRemove = document.getElementById($(this).parent().parent().attr('id'));
							chequeRemove.parentNode.removeChild(chequeRemove);

							atualizaMensagemQtdRegistros();
							return false;
						})
					)
				)
				.append($('<td>') // Coluna: Crítica
				    .attr('style','text-align:left')
					.attr('name','aux_dscritic')
					.attr('id','aux_dscritic')
					.text('')
				)
			);

		atualizaMensagemQtdRegistros();
		//Utiliza o Botão Novo após incluir um cheque na custódia
		novoCheque();
	}
}

function atualizaMensagemQtdRegistros(){
	var vlTotal = 0;
	var qtTotal = 0;
	
	// Totalizar o valor dos cheques
	$('#tbCheques tbody tr').each(function(){
		// Quantidade de Cheques
		qtTotal++;
		// Somar Todos
		vlTotal += converteMoedaFloat(normalizaNumero($("#aux_vlcheque",this).val()));
	});
	$('#qtdChequeCustodiar').html('<span style="font-size: 12px">Exibindo ' + qtTotal + ' cheques para custodiar. Valor Total R$ ' + number_format(vlTotal,2,',','.') + '</span>');
}

function novoCheque(){
	//Limpa o valor dos campos e seta foco na data
	cDtemissa.val('');
	cVlcheque.val('');
	cDsdocmc7.val('');
	cDtchqbom.focus().select();
}

function finalizarCustodia(){
	if( $('#tabEmiten tbody tr').length > 0 ){
		showConfirmacao('Deseja cadastrar os emitentes e finalizar a cust&oacute;dia de cheques?','Confirma&ccedil;&atilde;o - Aimaro','cadastrarEmitentes();','novoCheque()','sim.gif','nao.gif');
	}else if( $('#tbCheques tbody tr').length > 0 ){
		showConfirmacao('Deseja finalizar a cust&oacute;dia de cheques?','Confirma&ccedil;&atilde;o - Aimaro','finalizaCustodiaCheque();','novoCheque()','sim.gif','nao.gif');
	} else {
		showError('error','Nenhum cheque foi informado para custodiar.','Alerta - Aimaro','novoCheque();');
	}
}

function finalizaCustodiaCheque(){
	
	showMsgAguardo('Aguarde, finalizando cust&oacute;dia ...');
	
	var nrdconta = normalizaNumero( cNrdconta.val() );
	var dscheque = "";
	var corLinha  = 'corImpar';

	$('#tbCheques tbody tr').each(function(){
		if( dscheque != "" ){
			dscheque += "|";
		}
		
		dscheque += $("#aux_dtchqbom",this).val() + ";" ; // Data Boa
		dscheque += $("#aux_dtemissa",this).val() + ";" ; // Data Emissão
		dscheque += $("#aux_vlcheque",this).val().replace(/\./g,'').replace(',','.') + ";" ; // Valor
		dscheque += $("#aux_dsdocmc7",this).val() + ";"; // CMC-7
		
		
		// Limpar a crítica
		$("#aux_dscritic",this).text('');
		$(this).css('background', '');
		// Adiciona a cor Zebrado na Tabela de Cheques
		$(this).attr('class', corLinha);
		if( corLinha == 'corImpar' ){
			corLinha = 'corPar';
		} else {
			corLinha = 'corImpar';
		}
	});
	
	if( dscheque == "" ){
		unblockBackground();
		showError('error','Nenhum cheque foi informado para custodiar.','Alerta - Aimaro','novoCheque();');
		return false;
	}
	
	$.ajax({        
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/custod/cadastrar_custch.php', 
        data: {
            nrdconta: nrdconta,
			dscheque: dscheque,
            redirect: 'html_ajax'           
            }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();           
            showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',"unblockBackground()");
        },
        success: function(response) {
			hideMsgAguardo();
			try {
				eval( response );
			} catch(error) {						
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground();');
			}
        }
    });
}

function validaCustodiaCheque(){
	
	showMsgAguardo('Aguarde, validando cust&oacute;dia ...');
	
	var nrdconta = normalizaNumero( cNrdconta.val() );
	var dscheque = "";
	var corLinha  = 'corImpar';

	$('#tbCheques tbody tr').each(function(){
		if( dscheque != "" ){
			dscheque += "|";
		}
		
		dscheque += $("#aux_dtchqbom",this).val() + ";" ; // Data Boa
		dscheque += $("#aux_dtemissa",this).val() + ";" ; // Data Emissão
		dscheque += $("#aux_vlcheque",this).val().replace(/\./g,'').replace(',','.') + ";" ; // Valor
		dscheque += $("#aux_dsdocmc7",this).val(); // CMC-7
		
		// Limpar a crítica
		$("#aux_dscritic",this).text('');
		$(this).css('background', '');
		// Adiciona a cor Zebrado na Tabela de Cheques
		$(this).attr('class', corLinha);
		if( corLinha == 'corImpar' ){
			corLinha = 'corPar';
		} else {
			corLinha = 'corImpar';
		}
	});

	if( dscheque == "" ){
		unblockBackground();
		showError('error','Nenhum cheque foi informado para custodiar.','Alerta - Aimaro','hideMsgAguardo(); novoCheque();');
		return false;
	}
	
	$.ajax({        
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/custod/validar_custch.php', 
        data: {
            nrdconta: nrdconta,
			dscheque: dscheque,
            redirect: 'html_ajax'           
            }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();           
            showError('error','N&atildeo foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',"unblockBackground()");
        },
        success: function(response) {
			hideMsgAguardo();
			try {
				eval( response );
			} catch(error) {						
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground();');
			}
        }
    });
}

function solicitaImpressaoCustodiaEmitida(){
    showConfirmacao('Deseja imprimir a cust&oacute;dia de cheques?', 'Confirma&ccedil;&atilde;o - Aimaro', 'geraImpressaoCustodia();', 'estadoInicial();', 'sim.gif', 'nao.gif');
}

function geraImpressaoCustodia(){

	var nrdconta = cNrdconta.val();
	var nmprimtl = cNmprimtl.val();
	var dscheque = "";
	
	$('#tbCheques tbody tr').each(function(){
		if( dscheque != "" ){
			dscheque += "|";
		}
		
		dscheque += $("#aux_dtchqbom",this).val() + ";" ; // Data Boa
		dscheque += $("#aux_vlcheque",this).val().replace(/\./g,'').replace(',','.') + ";" ; // Valor Cheque
		dscheque += $("#aux_banco",   this).val() + ";" ; // Banco
		dscheque += $("#aux_agencia", this).val() + ";" ; // Agência
		dscheque += $("#aux_cheque",  this).val() + ";" ; // Número Cheque
		dscheque += $("#aux_conta",   this).val() + ";" ; // Número Conta
		dscheque += $("#aux_cmc7",    this).val();        // CMC-7
	});

	$('#formImpres').html('');
	
	$('#formImpres').append('<input type="hidden" id="nrdconta" name="nrdconta" value="'+nrdconta+'"/>');
	$('#formImpres').append('<input type="hidden" id="nmprimtl" name="nmprimtl" value="'+nmprimtl+'"/>');
	$('#formImpres').append('<input type="hidden" id="dscheque" name="dscheque" value="'+dscheque+'"/>');
	$('#formImpres').append('<input type="hidden" id="sidlogin" name="sidlogin" value="'+ $('#sidlogin','#frmMenu').val() + '"/>');	
	
	var action = UrlSite + "telas/custod/custodia_pdf.php";
	carregaImpressaoAyllos("formImpres",action,'estadoInicial();');
}

function criaEmitente(cdcmpchq, cdbanchq, cdagechq, nrctachq, nrsequen){

	var idCriar = "id_" + cdcmpchq + cdbanchq + cdagechq + nrctachq;

	var qtdLinhas = $('#tabEmiten tbody tr').length;
	var corLinha  = (qtdLinhas%2 === 0) ? 'corImpar' : 'corPar';
	
	if( cdbanchq == 1 ){
	    nrctachq = mascara(normalizaNumero(nrctachq.toString()),'####.###-#');
	} else {
		nrctachq = mascara(normalizaNumero(nrctachq.toString()),'######.###-#');
	}
		
	if(!document.getElementById(idCriar)) {
		
		// Criar a linha na tabela
		$("#tabEmiten > tbody")
			.append($('<tr>') // Linha
			    .attr('id',idCriar)
				.attr('class',corLinha)
				.append($('<td>') // Coluna: Banco
					.attr('style','width: 50px; text-align:right')
					.text(cdbanchq)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','cdbanchq')
						.attr('id','cdbanchq')
						.attr('value',cdbanchq)
					)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','cdcmpchq')
						.attr('id','cdcmpchq')
						.attr('value',cdcmpchq)						
					)
				)
				.append($('<td>')  // Coluna: Agência
					.attr('style','width: 50px; text-align:right')
					.text(cdagechq)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','cdagechq')
						.attr('id','cdagechq')
						.attr('value',cdagechq)
					)
				)
				.append($('<td>') // Coluna: Número da Conta
					.attr('style','width: 90px; text-align:right')
					.text(nrctachq)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','nrctachq')
						.attr('id','nrctachq')
						.attr('value',nrctachq)
					)
				)
				.append($('<td>') // Coluna: CPF/CNPJ
					.attr('style','width: 150px; text-align:center')
					.append($('<input>')
						.attr('type','text')
						.attr('name','nrcpfcnpj')
						.attr('id','nrcpfcnpj' + nrsequen)
						.attr('style', 'width: 140px;')
						.attr('maxlength','18')
						.attr('class', 'campo')
					)
					
				)
				.append($('<td>') // Coluna: Emitente
					.attr('style','width: 350px; text-align:center')
					.append($('<input>')
						.attr('type','text')
						.attr('name','dsemiten')
						.attr('id','dsemiten' + nrsequen)
						.attr('style', 'width: 340px;')
						.attr('class', 'campo alphanum')
					)
				)
				.append($('<td>') // Coluna: Crítica
				    .attr('style','text-align:left')
					.attr('name','dscritic')
					.attr('id','dscritic')
					.text('')
				)
			);
		
	}
	
	highlightObjFocus($('#' + frmOpcao));
	cNrcpfcnpj[nrsequen] = $('#' + 'nrcpfcnpj' + nrsequen, '#' + frmOpcao);	
	cDsemiten[nrsequen] = $('#' + 'dsemiten' + nrsequen, '#' + frmOpcao);		
	cDsemiten[nrsequen].attr('maxlength','60').setMask("STRING",60,charPermitido(),""); 
	
	cNrcpfcnpj[nrsequen].unbind('keydown').bind('keydown', function(e) {		
        if (divError.css('display') == 'block') {
            return false;
        }
		
		// Se é a tecla TAB ou ENTER, 
        if (e.keyCode == 9 || e.keyCode == 13) {
            cDsemiten[nrsequen].focus();
            return false;
        }
		
		mascaraCpfCnpj(this,cpfCnpj);
		
   });
	
	cDsemiten[nrsequen].unbind('keydown').bind('keydown', function(e) {		
        if (divError.css('display') == 'block') {
            return false;
        }
		
		// Se é a tecla TAB ou ENTER, 
        if (e.keyCode == 9 || e.keyCode == 13) {
			if (cNrcpfcnpj[nrsequen + 1] !== undefined){
				cNrcpfcnpj[nrsequen + 1].focus();			
			}else{
				btnContinuar();
			}
        }
    });
		
	layoutPadrao();		
	return false;
}

function mascaraCpfCnpj(o,f){
    v_obj=o
    v_fun=f
    setTimeout('execmascara()',1)
}
 
function execmascara(){
    v_obj.value=v_fun(v_obj.value)
}
 
function cpfCnpj(v){
    v=v.replace(/\D/g,"")
    if (v.length <= 11) { //CPF
        v=v.replace(/(\d{3})(\d)/,"$1.$2")
        v=v.replace(/(\d{3})(\d)/,"$1.$2")
        v=v.replace(/(\d{3})(\d{1,2})$/,"$1-$2")
 
    } else { //CNPJ
        v=v.replace(/^(\d{2})(\d)/,"$1.$2")
        v=v.replace(/^(\d{2})\.(\d{3})(\d)/,"$1.$2.$3")
		v=v.replace(/\.(\d{3})(\d)/,".$1/$2")
        v=v.replace(/(\d{4})(\d)/,"$1-$2")
    }
    return v
}

function cadastrarEmitentes(){

	showMsgAguardo('Aguarde, cadastrando emitentes ...');
	
	var dscheque = "";
	var idNrcpfcnpj, idDsemiten;
	var corLinha  = 'corImpar';
	var flgerro = false;
	
	$('#tabEmiten tbody tr').each(function(){
		
		idNrcpfcnpj = $("input[name='nrcpfcnpj']",this).attr('id');
		idDsemiten  = $("input[name='dsemiten']",this).attr('id');
		
		if ($("input[name='nrcpfcnpj']",this).val() == ""){
			showError('error','Preencha todos os campos para continuar.','Alerta - Aimaro','hideMsgAguardo();$(\'#'+idNrcpfcnpj+'\').focus();');
			flgerro = true;
			return false;
		}
		
		if ($("input[name='dsemiten']",this).val() == ""){
			showError('error','Preencha todos os campos para continuar.','Alerta - Aimaro','hideMsgAguardo(); $(\'#'+idDsemiten+'\').focus();');
			flgerro = true;
			return false;
		}
		
		if( dscheque != "" ){
			dscheque += "|";
		}
		
		dscheque += normalizaNumero($("#cdcmpchq",this).val()) + ";"; // Compe
		dscheque += normalizaNumero($("#cdbanchq",this).val()) + ";"; // Banco
		dscheque += normalizaNumero($("#cdagechq",this).val()) + ";"; // Agencia
		dscheque += normalizaNumero($("#nrctachq",this).val()) + ";"; // Conta
		dscheque += $("input[name='nrcpfcnpj']",this).val().replace(/[^0-9]/g, '') + ";" ; // Nrcpfcnpj
		dscheque += $("input[name='dsemiten']",this).val().toUpperCase(); // Emitente
		
		// Limpar a crítica
		$("#dscritic",this).text('');
		$(this).css('background', '');
		// Adiciona a cor Zebrado na Tabela de Cheques
		$(this).attr('class', corLinha);
		if( corLinha == 'corImpar' ){
			corLinha = 'corPar';
		} else {
			corLinha = 'corImpar';
		}

	});
	
	if (flgerro == true){
		return false;
	}
	
	if (dscheque == ""){
		showError('error','Emitentes n&atilde;o encontrados.','Alerta - Aimaro','hideMsgAguardo();');
		return false;
	}
		
	$.ajax({        
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/custod/cadastrar_emiten.php', 
        data: {
			dscheque: dscheque,
            redirect: 'html_ajax'           
            }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();           
            showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',"unblockBackground()");
        },
        success: function(response) {
			hideMsgAguardo();
			try {
				eval( response );
			} catch(error) {						
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground();');
			}
        }
    });
	
}

function limpaTabEmiten(){
	
	$('#tabEmiten tbody tr').each(function(){
		var registro = document.getElementById($(this).attr('id'));
		registro.parentNode.removeChild(registro);
	});
	
}

function limpaTabCustch(){
	
	$('#tbCheques tbody tr').each(function(){
		var registro = document.getElementById($(this).attr('id'));
		registro.parentNode.removeChild(registro);
	});
	
}

function mostraMsgSucesso(){
	var dsmsgcmc7 = $('#dsmsgcmc7','#' + frmOpcao);
	dsmsgcmc7.text('Cheque conciliado com sucesso!');
	dsmsgcmc7.css('display', 'block');
	dsmsgcmc7.css('color', 'green');
	setTimeout(mostraMsgCmc7, 2000);
}

function mostraMsgErro(){
	var dsmsgcmc7 = $('#dsmsgcmc7','#' + frmOpcao);
	dsmsgcmc7.text('Cheque n\u00E3o encontrado!');
	dsmsgcmc7.css('display', 'block');
	dsmsgcmc7.css('color', 'red');
	setTimeout(mostraMsgCmc7, 2000);
}

function mostraMsgCmc7(){
	$('#dsmsgcmc7','#' + frmOpcao).css('display','none');
}

function validaCmc7(typedValue) {
	if(typedValue === undefined || typedValue === null){
        return false;
	  }
	  typedValue      = typedValue.replace(/\s/g, "");
	  if(!typedValue){
		return false;
	  }
	  
	  var pieces = {
		firstPiece  : typedValue.substr(1,7)
		, secondPiece : typedValue.substr(10,10)
		, thirdPiece  : typedValue.substr(22,10)
	  };

	  var digits = {
		  firstDigit : parseInt(typedValue.substr(8,1))
		, secondDigit :  parseInt(typedValue.substr(21,1))
		, thirdDigit : parseInt(typedValue.substr(32,1))
	  };

	  var calculatedDigits = {
		firstDigit : module10(pieces.firstPiece)
		, secondDigit :  module10(pieces.secondPiece)
		, thirdDigit : module10(pieces.thirdPiece)
	  };

	  if ( (calculatedDigits.secondDigit != digits.firstDigit)
		|| (calculatedDigits.firstDigit != digits.secondDigit)
		|| (calculatedDigits.thirdDigit != digits.thirdDigit) ) {
		  return false;
	  }
	  return true;
}	  

function module10(str) {

        if(str === undefined || str === null){
          return 0;
        }
        var size = str.length - 1;
        var result = 0;
        var weight = 2;

        for (var i = size; i >= 0; i--) {
            total = str.substr(i, 1) * weight;
            if (total > 9) {
                result = result + 1 + (total - 10);
            } else {
                result = result + total;
            }
            if (weight == 1) {
                weight = 2;
            } else {
                weight = 1;
            }
        }
        var dv = 10 - mod(result, 10);
        if (dv == 10) {
            dv = 0;
        }
        return dv;
}
	
function mod(dividend, divisor) {	
	
     return Math.round(dividend - (Math.floor(dividend/divisor)*divisor));
}

function validaChequeI(){
	
	showMsgAguardo('Aguarde, validando cheque ...');
	
	var nrdconta = normalizaNumero( cNrdconta.val() );
	var dscheque = "";
	var data    = cDtchqbom.val();
	var dataEmi = cDtemissa.val();
	var valor   = cVlcheque.val();
	var cmc7    = cDsdocmc7.val();
	var cmc7_sem_format  = cmc7.replace(/[^0-9]/g, "").substr(0,30);
	
	// Validar se os campos estão preenchidos
	if ( data == '' ) {
		showError('error','Data boa inv&aacute;lida.','Alerta - Aimaro','hideMsgAguardo();cDtchqbom.focus();');
		return false;
	}
	
	if ( dataEmi == '' ) {
		showError('error','Data de emiss&atilde;o inv&aacute;lida.','Alerta - Aimaro','hideMsgAguardo();cDtemissa.focus();');
		return false;
	}
	
	if ( valor == '' || valor == '0,00') {
		showError('error','Valor inv&aacute;lido.','Alerta - Aimaro','hideMsgAguardo(); cVlcheque.focus();');
		return false;
	}
	
	if ( cmc7_sem_format.length < 30 ) {
		showError('error','CMC-7 inv&aacute;lido.','Alerta - Aimaro','hideMsgAguardo(); cDsdocmc7.focus();');
		return false;
	}
	
	var aDataBoa = data.split("/"); 
	var aDataEmi = dataEmi.split("/"); 
	var aDtmvtolt = aux_dtmvtolt.split("/"); 
	var dtcompara1 = parseInt(aDataBoa[2].toString() + aDataBoa[1].toString() + aDataBoa[0].toString()); 
	var dtcompara2 = parseInt(aDataEmi[2].toString() + aDataEmi[1].toString() + aDataEmi[0].toString()); 
	var dtcompara3 = parseInt(aDtmvtolt[2].toString() + aDtmvtolt[1].toString() + aDtmvtolt[0].toString()); 
	
	if ( dtcompara1 <= dtcompara3 ) {
		showError('error','A data boa deve ser maior que a data atual.','Alerta - Aimaro','hideMsgAguardo(); cDtchqbom.focus();');
		return false;
	}
	
	if ( dtcompara2 > dtcompara3 ) {
		showError('error','A data de emiss&atilde;o deve ser menor que a data atual.','Alerta - Aimaro','hideMsgAguardo(); cDtchqbom.focus();');
		return false;
	}
	
	if (!validaCmc7(cmc7)){
		showError('error','CMC-7 Inv&aacute;lido!','Alerta - Aimaro','hideMsgAguardo(); cDsdocmc7.limpaFormulario();cDsdocmc7.focus();');
		return false;
	}	
	
	dscheque += data + ";" ; // Data Boa
	dscheque += dataEmi + ";" ; // Data Emissão
	dscheque += valor.replace(/\./g,'').replace(',','.') + ";" ; // Valor
	dscheque += cmc7_sem_format; // CMC-7
	
	$.ajax({        
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/custod/validar_cheque_i.php', 
        data: {
            nrdconta: nrdconta,
			dscheque: dscheque,
            redirect: 'html_ajax'           
            }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();           
            showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',"unblockBackground()");
        },
        success: function(response) {
			hideMsgAguardo();
			try {
				eval( response );
			} catch(error) {						
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground();');
			}
        }
    });
}

// Mostra form cadastro de emitente
function mostraFormEmitente(cdcmpchq, cdbanchq, cdagechq, nrctachq) {
	
	showMsgAguardo('Aguarde, carregando cadastro de emitente...');

	// Executa script através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/custod/detalhamento_emitente.php', 
		data: {			
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',"unblockBackground()");
		},
		success: function(response) {			
			$('#divRotina').css({'height': '400px'});						
			$('#divRotina').html(response);				
            exibeRotina($('#divRotina'));			
			buscaFormEmitente(cdcmpchq, cdbanchq, cdagechq, nrctachq);
		}				
	});
	
	return false;
	
}

function buscaFormEmitente(cdcmpchq, cdbanchq, cdagechq, nrctachq){
	
	if( cdbanchq == 1 ){
	    nrctachq = mascara(normalizaNumero(nrctachq.toString()),'####.###-#');
	} else {
		nrctachq = mascara(normalizaNumero(nrctachq.toString()),'######.###-#');
	}
	
	// Executa script através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/custod/form_cadastra_emitente.php', 
		data: {			
			cdcmpchq: cdcmpchq,	
			cdbanchq: cdbanchq,
			cdagechq: cdagechq,
			nrctachq: nrctachq,	
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',"unblockBackground()");
		},
		success: function(response) {			
			$('#divDetalhamento').html(response);			
			formataCadastroEmitente();
		}				
	});
	
	return false;
	
}

function formataCadastroEmitente(){
	
	var rCdcmpchq_emi, rCdbanchq_emi, rCdagechq_emi, rNrctachq_emi, 
		rNrcpfcgc_emi, rDsemiten_emi;
		
	var cCdcmpchq_emi, cCdbanchq_emi, cCdagechq_emi, cNrctachq_emi, 
		cNrcpfcgc_emi, cDsemiten_emi;
		
    var btnIncluirEmi = $('#btIncluirEmi', '#divBotoesDetalhe');
	highlightObjFocus($('#frmCadastraEmitente'));
	
    // label
	rCdcmpchq_emi = $('label[for="cdcmpchq"]', '#frmCadastraEmitente');
	rCdbanchq_emi = $('label[for="cdbanchq"]', '#frmCadastraEmitente');
	rCdagechq_emi = $('label[for="cdagechq"]', '#frmCadastraEmitente');
	rNrctachq_emi = $('label[for="nrctachq"]', '#frmCadastraEmitente');
	rNrcpfcgc_emi = $('label[for="nrcpfcgc"]', '#frmCadastraEmitente');
	rDsemiten_emi = $('label[for="dsemiten"]', '#frmCadastraEmitente');
	
    rCdcmpchq_emi.css({'width': '61px'}).addClass('rotulo');
    rCdbanchq_emi.css({'width': '61px'}).addClass('rotulo-linha');
    rCdagechq_emi.css({'width': '61px'}).addClass('rotulo-linha');
    rNrctachq_emi.css({'width': '61px'}).addClass('rotulo-linha');
    rNrcpfcgc_emi.css({'width': '120px'}).addClass('rotulo');
    rDsemiten_emi.css({'width': '120px'}).addClass('rotulo');

    // input
    cCdcmpchq_emi = $('#cdcmpchq', '#frmCadastraEmitente');
    cCdbanchq_emi = $('#cdbanchq', '#frmCadastraEmitente');
    cCdagechq_emi = $('#cdagechq', '#frmCadastraEmitente');
    cNrctachq_emi = $('#nrctachq', '#frmCadastraEmitente');
    cNrcpfcgc_emi = $('#nrcpfcgc', '#frmCadastraEmitente');
    cDsemiten_emi = $('#dsemiten', '#frmCadastraEmitente');
	cDsemiten_emi.setMask("STRING",60,charPermitido(),"");

    cCdcmpchq_emi.css({'width': '40px'}).desabilitaCampo();
    cCdbanchq_emi.css({'width': '40px'}).desabilitaCampo();
    cCdagechq_emi.css({'width': '50px'}).desabilitaCampo();
    cNrctachq_emi.css({'width': '98px'}).desabilitaCampo();
    cNrcpfcgc_emi.css({'width': '150px'}).habilitaCampo();
    cDsemiten_emi.css({'width': '379px'}).habilitaCampo();
	cDsemiten_emi.addClass('alphanum');
	
	layoutPadrao();
	
	cNrcpfcgc_emi.focus();
	
	// Data Emissão
    cNrcpfcgc_emi.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se é a tecla TAB ou ENTER, 
        if (e.keyCode == 13) {
            cDsemiten_emi.focus();
            return false;
        }

		mascaraCpfCnpj(this,cpfCnpj);
		
    });

	// Data Boa
    cDsemiten_emi.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se é a tecla TAB ou ENTER, 
        if (e.keyCode == 13) {
            confirmaIncluiEmitente();
            return false;
        }
		
    });
		
    hideMsgAguardo();
    bloqueiaFundo($('#divRotina'));
	return false;
}

function confirmaIncluiEmitente(){
	showConfirmacao('Confirma a inclus&atilde;o do emitente?', 'Confirma&ccedil;&atilde;o - Aimaro', 'incluiEmitente();', 'return false;', 'sim.gif', 'nao.gif');
	return false;
}

function incluiEmitente(){
	
	showMsgAguardo('Aguarde, cadastrando emitente...');

	var cdcmpchq, cdbanchq, cdagechq, nrctachq, nrcpfcgc, dsemiten, dscheque;
	
	cdcmpchq = normalizaNumero($('#cdcmpchq', '#frmCadastraEmitente').val());
	cdbanchq = normalizaNumero($('#cdbanchq', '#frmCadastraEmitente').val());
	cdagechq = normalizaNumero($('#cdagechq', '#frmCadastraEmitente').val());
	nrctachq = normalizaNumero($('#nrctachq', '#frmCadastraEmitente').val());
	nrcpfcgc = normalizaNumero($('#nrcpfcgc', '#frmCadastraEmitente').val());
	dsemiten = $('#dsemiten', '#frmCadastraEmitente').val();
				
	if (nrcpfcgc == ""){
		showError('error','Preencha todos os campos para continuar.','Alerta - Aimaro','hideMsgAguardo(); $(\'#nrcpfcgc\', \'#frmCadastraEmitente\').focus(); bloqueiaFundo($(\'#divRotina\'));');
		return false;
	}
	
	if (dsemiten == ""){
		showError('error','Preencha todos os campos para continuar.','Alerta - Aimaro','hideMsgAguardo(); $(\'#nrcpfcgc\', \'#frmCadastraEmitente\').focus(); bloqueiaFundo($(\'#divRotina\'));');
		return false;
	}

	dscheque = cdcmpchq + ';' + 
			   cdbanchq + ';' + 
			   cdagechq + ';' + 
			   nrctachq + ';' + 
			   nrcpfcgc + ';' + 
			   dsemiten.toUpperCase();
	$.ajax({        
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/custod/cadastrar_emitente_I.php', 
        data: {
			dscheque: dscheque,
            redirect: 'html_ajax'           
            }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();           
            showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',"unblockBackground()");
        },
        success: function(response) {
			hideMsgAguardo();
			try {
				eval( response );
			} catch(error) {						
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground();');
			}
        }
    });
	
	return false;
	
}

function mostraAutorizaResgate() {

    // Executa script através de ajax
    $.ajax({        
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/custod/autorizar_resgate.php', 
        data: {         
            redirect: 'html_ajax'           
            }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',"unblockBackground()");
        },
        success: function(response) {           
            $('#divRotina').html(response);             
            exibeRotina($('#divRotina'));
            formataAutorizarRegaste();         
        }               
    });
    
    return false;
    
}

function formataAutorizarRegaste(){

    divRotina.css('width', '300px');
    divRotina.css('height', '400px');

    $('#divAutSenha').css('display', 'none');
    $('#divNomeDoc').css('display', 'none');

    if (inpessoa > 1 && idastcjt == 1) {
        $('#divAutIB').css('display', 'block');
    } else {
        $('#divAutIB').css('display', 'none');
    }
    
    // label
    var rSenha     = $('label[for="dssencar"]', '#frmAutorizar');
    var rNome      = $('label[for="nomeresg"]', '#frmAutorizar');
    var rDocumento = $('label[for="docuresg"]', '#frmAutorizar');

    rSenha.addClass('rotulo').css('width', '40px');
    rNome.addClass('rotulo').css('width', '40px');
    rDocumento.addClass('rotulo').css('width', '40px');

    // input
    var cSenha                  = $('#dssencar', '#frmAutorizar');
    var cFlgAutorizaSenha       = $('#flgAutorizaSenha', '#frmAutorizar');
    var cFlgAutorizaIB          = $('#flgAutorizaIB', '#frmAutorizar');
    var cFlgAutorizaComprovante = $('#flgAutorizaComprovante', '#frmAutorizar');
    var cNome                   = $('#nomeresg', '#frmAutorizar');
    var cDocumento              = $('#docuresg', '#frmAutorizar');
    
    cSenha.css('width', '100px').addClass('campo');
    cFlgAutorizaSenha.css('clear', 'left');
    cFlgAutorizaIB.css('clear', 'left');
    cFlgAutorizaComprovante.css('clear', 'left');
    cNome.css('width', '220px').addClass('campo');
    cDocumento.css('width', '220px').addClass('campo');
}

function alteraOpcaoAutorizar(){
    var opcaoSelecionada = $('input[type=radio][name=flgautoriza]:checked', '#frmAutorizar').val();
    if (opcaoSelecionada == 'senha') {
        $('#divAutSenha').css('display', 'block');
        $('#divNomeDoc').css('display', 'none');
    } else if (opcaoSelecionada == 'ib') {
        $('#divAutSenha').css('display', 'none');
        $('#divNomeDoc').css('display', 'none');
    } else if (opcaoSelecionada == 'comprovante') {
        $('#divAutSenha').css('display', 'none');
        //$('#divNomeDoc').css('display', 'block');
    }
}

function prosseguirAutorizacao() {

    hideMsgAguardo();

    var nrdconta = normalizaNumero($('#nrdconta', '#' + frmOpcao).val());
    var opcaoSelecionada = $('input[type=radio][name=flgautoriza]:checked', '#frmAutorizar').val();

    if (opcaoSelecionada == 'senha') {
        // Validar a senha digitada
        var dssencar = $('#dssencar', '#frmAutorizar').val();

        showMsgAguardo('Aguarde, validando ...');

        $.ajax({
            type: 'POST',
            async: true,
            url: UrlSite + 'telas/custod/valida_senha_cooperado.php',
            data: {
                nrdconta: nrdconta,
                dssencar: dssencar,
                inpessoa: inpessoa,
                idastcjt: idastcjt,
                redirect: 'script_ajax'
            },
            error: function(objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'unblockBackground()');
            },
            success: function(response) {
                try {
                    eval(response);
                    return false;
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'unblockBackground()');
                }
            }
        });
    } else if(opcaoSelecionada == 'ib'){
        criaTransPendenteCheque('ib');
    } else if(opcaoSelecionada == 'comprovante'){
        geraImpressaoComprovante('frmAutorizar');
    }

    return false;

}

function geraImpressaoComprovante(form){

    showMsgAguardo('Aguarde, buscando cheque(s) resgatados(s) ...');

    var nrdconta = cNrdconta.val();
    var nmprimtl = cNmprimtl.val();
    // var nomeresg = $('#nomeresg', '#' + form).val();
    // var docuresg = $('#docuresg', '#' + form).val();
    var dscheque = "";
    
    $('#tbCheques tbody tr').each(function(){

        // Verificar se o cheque está "checado" para imprimir o comprovante e se a opcao escolhida é N
        if(!$('#flgcompr' + $("#aux_cheque",  this).val()).is(':checked') && cddopcao == 'N'){
            return true;
        }

        if( dscheque != "" ){
            dscheque += "|";
        }
        
        dscheque += $("#aux_cheque",  this).val() + ";" ; // Número Cheque
        if (cddopcao == 'N') {
            dscheque += $("#aux_vlcheque",this).val() + ";" ; // Valor Cheque
        } else {
            dscheque += $("#aux_vlcheque",this).html() + ";" ; // Valor Cheque
        }
        dscheque += $("#aux_cmc7",    this).val();        // CMC-7
    });

    $('#formImpres').html('');

    $('#formImpres').append('<input type="hidden" id="nrdconta" name="nrdconta" value="'+nrdconta+'"/>');
    $('#formImpres').append('<input type="hidden" id="nmprimtl" name="nmprimtl" value="'+nmprimtl+'"/>');
    $('#formImpres').append('<input type="hidden" id="dscheque" name="dscheque" value="'+dscheque+'"/>');
    $('#formImpres').append('<input type="hidden" id="sidlogin" name="sidlogin" value="'+ $('#sidlogin','#frmMenu').val() + '"/>');
    $('#formImpres').append('<input type="hidden" id="inpessoa" name="inpessoa" value="'+inpessoa+'"/>');
    $('#formImpres').append('<input type="hidden" id="idastcjt" name="idastcjt" value="'+idastcjt+'"/>');

    buscarResponsaveisAssinatura();
}

// opcao N
function formataOpcaoN() {

    // label
    rNrdconta = $('label[for="nrdconta"]', '#' + frmOpcao);
    rDtresgat = $('label[for="dtresgat"]', '#' + frmOpcao);
    rNrcheque = $('label[for="nrcheque"]', '#' + frmOpcao);

    rNrdconta.css({'width': '120px'}).addClass('rotulo');
    rDtresgat.css({'width': '120px'}).addClass('rotulo');
    rNrcheque.css({'width': '120px'}).addClass('rotulo');

    // input
    cNrdconta = $('#nrdconta', '#' + frmOpcao);
    cDtresgat = $('#dtresgat', '#' + frmOpcao);
    cNmprimtl = $('#nmprimtl', '#' + frmOpcao);
    cNrcheque = $('#nrcheque', '#' + frmOpcao);
    cDsdocmc7 = $('#dsdocmc7', '#' + frmOpcao);

    cNrdconta.css({'width': '75px'}).addClass('pesquisa conta');
    cNmprimtl.css({'width': '553px'});
    cDtresgat.css({'width': '75px'}).addClass('data');
    cNrcheque.css({'width': '553px'});

    // Outros   
    cTodosOpcao.desabilitaCampo();

    //
    if ($.browser.msie) {
        rDtresgat.css({'width': '152px'});
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

    layoutPadrao();
    controlaPesquisas();
    
    cDtresgat.attr('tabindex', 1);
    cNrcheque.attr('tabindex', 2);
    
    return false;

}

function buscarChequesResgatados(){

    showMsgAguardo('Aguarde, buscando cheque(s) resgatados(s) ...');
    
    var nrdconta = normalizaNumero(cNrdconta.val());
    var dtresgat = cDtresgat.val();
    var nrcheque = cNrcheque.val();
    
    $.ajax({        
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/custod/busca_cheques_resgatados.php', 
        data: {
            nrdconta: nrdconta,
            dtresgat: dtresgat,
            nrcheque: nrcheque,
            redirect: 'html_ajax'           
            }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();           
            showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',"unblockBackground()");
        },
        success: function(response) {
            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try{
                    $('#divCheques').html(response);
                    formataTabelaN();
                } catch(error){
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground();');
                }
            }else{
                try {
                    eval( response );                   
                } catch(error) {                        
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground();');
                }
            }
        }
    });

}

function formataTabelaN(){
    
    // tabela
    var divRegistro = $('div.divRegistros', '#divCheques');
    var tabela = $('table', divRegistro);
    
    $('#' + frmOpcao).css({'margin-top': '5px'});
    divRegistro.css({'height': '207px', 'padding-bottom': '2px'});

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '20px';
    arrayLargura[1] = '80px';
    arrayLargura[2] = '80px';
    arrayLargura[3] = '80px';
    arrayLargura[4] = '80px';
    arrayLargura[5] = '80px';
    
    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'right';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'right';
    arrayAlinha[4] = 'right';
    arrayAlinha[5] = 'right';
    arrayAlinha[6] = 'center';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

    $('#btProsseguir').css('display', 'none');
    $('#btImprimir').css('display', '');
    
}

function formRespAssinatura(){

    var nrdconta = normalizaNumero($('#nrdconta', '#' + frmOpcao).val());
    
    // Executa script através de ajax
    $.ajax({        
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/custod/form_resp_assinatura.php', 
        data: {         
            nrdconta: nrdconta,
            redirect: 'html_ajax'           
            }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',"unblockBackground()");
        },
        success: function(response) {
            hideMsgAguardo();  
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try{
                    $('#divAutorizar').html(response);           
                    formataTabelaResponsaveisAssinatura();
                } catch(error){
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground();');
                }
            }else{
                try {
                    eval( response );                   
                } catch(error) {                        
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground();');
                }
            }         
        }               
    });
    
    return false;
    
}

function formataTabelaResponsaveisAssinatura(){
    
    // tabela
    var divRegistro = $('div.divRegistros', '#divAutorizar');
    var tabela = $('table', divRegistro);

    var ordemInicial = new Array();

    var arrayLargura = new Array();
	arrayLargura[0] = '13px';
    
    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');
    
}

function selecionarResponsavel(){
    var nrcpfcgc = $('input[type=radio][name=nrcpfcgc]:checked', '#tabelaResponsaveis').val();

    criaTransPendenteCheque('senha', nrcpfcgc);
}

function buscarResponsaveisAssinatura(){

    var nrdconta = normalizaNumero($('#nrdconta', '#' + frmOpcao).val());
    
    // Executa script através de ajax
    $.ajax({        
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/custod/busca_responsaveis_assinatura.php', 
        data: {         
            nrdconta: nrdconta,
            redirect: 'html_ajax'           
            }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',"unblockBackground()");
        },
        success: function(response) {
            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try{

                    $('#formImpres').append(response);
                    if (cddopcao == 'N') {
                        var action = UrlSite + "telas/custod/comprovante_pdf.php";
                        carregaImpressaoAyllos("formImpres",action,'estadoInicial();');
                    } else if (cddopcao == 'H') {
                        efetuaResgate(true);
                    }

                } catch(error){
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground();');
                }
            }else{
                try {
                    eval( response );                   
                } catch(error) {                        
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground();');
                }
            }
        }
    });
    
    return false;
    
}

function criaTransPendenteCheque(opcao, nrcpfcgc){
    
    showMsgAguardo('Aguarde, criando pendencias...');

    if (opcao == 'senha' && (nrcpfcgc == '' || nrcpfcgc == undefined)) {
        hideMsgAguardo();
        showError('error','Nenhum respons&aacute;vel foi selecionado.','Alerta - Aimaro',"unblockBackground()");
    }

    var nrdconta = normalizaNumero($('#nrdconta', '#' + frmOpcao).val());
    var dscheque = "";

    $('#tbCheques tbody tr').each(function(){
        if( dscheque != "" ){
            dscheque += "|";
        }

        if ($("#aux_dscritic",this).text() != ''){                  
            aux_flgerro = true;     
        }

        dscheque += $("#aux_dsdocmc7",this).val(); // CMC-7
              
    });

    if( dscheque == "" ){
        unblockBackground();
        showError('error','Nenhum cheque foi informado para resgate.','Alerta - Aimaro','');
        return false;
    }

    $.ajax({
      type: 'POST',
      dataType: 'html',
      url: UrlSite + 'telas/custod/cria_trans_pend_resgate_cst.php', 
        async: false,
        data: {
            nrdconta: nrdconta,
            dscheque: dscheque,
            nrcpfcgc: nrcpfcgc,
            redirect: 'html_ajax'
            }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',"unblockBackground()");
        },
        success: function(response) {
            hideMsgAguardo();
            try {
                eval( response );
            } catch(error) {                    
                showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground();');
            }
        }
    });
}

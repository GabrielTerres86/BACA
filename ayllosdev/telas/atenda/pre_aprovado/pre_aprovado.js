/*!
 * FONTE        : pre_aprovado.js
 * CRIAÇÃO      : Petter Rafael - Envolti
 * DATA CRIAÇÃO : Janeiro/2019
 * OBJETIVO     : Biblioteca de funções da rotina Pre Aprovado da tela ATENDA
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */

// Função para acessar as abas da tela
function acessaOpcaoAba(nrOpcoes, id, opcao) {
    if (opcao == "0") {
        var msg = "aba Pr&eacute;-Aprovado";
    } else if (opcao == "1") {
        var msg = "aba Motivos";
    } else if (opcao == "2") {
        var msg = "aba Alterar";
    }

    bloqueiaFundo(divRotina);
    showMsgAguardo("Aguarde, carregando " + msg + " ...");

    // Atribui cor de destaque para aba da opção
    for (var i = 0; i <= nrOpcoes; i++) {
        if (id == i) {
            $("#linkAba" + id).attr("class", "txtBrancoBold");
            $("#imgAbaEsq" + id).attr("src", UrlImagens + "background/mnu_sle.gif");
            $("#imgAbaDir" + id).attr("src", UrlImagens + "background/mnu_sld.gif");
            $("#imgAbaCen" + id).css("background-color", "#969FA9");
            continue;
        }

        $("#linkAba" + i).attr("class", "txtNormalBold");
        $("#imgAbaEsq" + i).attr("src", UrlImagens + "background/mnu_nle.gif");
        $("#imgAbaDir" + i).attr("src", UrlImagens + "background/mnu_nld.gif");
        $("#imgAbaCen" + i).css("background-color", "#C6C8CA");
    }

    // Carrega conteúdo da opção através de ajax
    if (opcao == "0") {
        $.ajax({
            type: "POST",
            dataType: "html",
            url: UrlSite + "telas/atenda/pre_aprovado/manter_pre_aprovado.php",
            data: {
                nrdconta: nrdconta,
                redirect: "html_ajax"
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', bloqueiaFundo(divRotina));
            },
            success: function (response) {
                if (response.indexOf('showError("error"') == -1) {
                    $('#divConteudoOpcao').html(response);
                    formataRegra();
                } else {
                    eval(response);
                }

                return false;
            }
        });
    } else if (opcao == "1") {
        $.ajax({
            type: "POST",
            dataType: "html",
            url: UrlSite + "telas/atenda/pre_aprovado/manter_motivos.php",
            data: {
                nrdconta: nrdconta,
                redirect: "html_ajax"
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', bloqueiaFundo(divRotina));
            },
            success: function (response) {
                if (response.indexOf('showError("error"') == -1) {
                    $('#divConteudoOpcao').html(response);
                    formataRegra();
                } else {
                    eval(response);
                }

                return false;
            }
        });
    } else if (opcao == "2") {
        $.ajax({
            type: "POST",
            dataType: "html",
            url: UrlSite + "telas/atenda/pre_aprovado/manter_alterar.php",
            data: {
                nrdconta: nrdconta,
                opcao: "cons",
                redirect: "html_ajax"
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', bloqueiaFundo(divRotina));
            },
            success: function (response) {
                if (response.indexOf('showError("error"') == -1) {
                    $('#divConteudoOpcao').html(response);
                    tabelaLayoutPreAprov();
                } else {
                    eval(response);
                }

                return false;
            }
        });
    }
}

function controlaLayout(operacao) {
    $('#divConteudoOpcao').hide(0, function () {
        divRotina.css('width', '600px');
        $('form.frmPreAprovado').css('height', '460px');
        layoutPadrao();
        hideMsgAguardo();
        bloqueiaFundo(divRotina);
        $(this).fadeIn(1000);
        divRotina.centralizaRotinaH();
    });

    return false;
}

function tabelaLayout() {
    var divRegistro = $('div.divRegistros');
    var tabela = $('table', divRegistro);

    divRegistro.css('height', '400px');

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '';
    arrayLargura[1] = '100px';
    arrayLargura[2] = '100px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'left';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'center';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

    layoutPadrao();
    divRotina.centralizaRotinaH();
}

function tabelaLayoutPreAprov() {
    var divRegistro = $('div.divRegistros');
    var tabela = $('table', divRegistro);

    divRegistro.css('height', '350px');
    divRegistro.css('width', '100%');

    var ordemInicial = new Array();
    //ordemInicial = [[1, 1]];

    var arrayLargura = new Array();
    arrayLargura[0] = '60px';
    arrayLargura[1] = '85px';
    arrayLargura[2] = '55px';
    arrayLargura[3] = '185px';
    arrayLargura[4] = '100px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'left';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'left';
    arrayAlinha[4] = 'left';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

    layoutPadrao();
    divRotina.centralizaRotinaH();
}

function formataRegra() {
    if ($('label[for="flgbloq"]').length) {
        var rFlgbloq = $('label[for="flgbloq"]');
        var rIdmotivo = $('label[for="idmotivo"]');
        var rDtatualiza = $('label[for="dtatualiza"]');
        var rParcelaLC = $('label[for="parcelaLC"]');
        var rParcelaMax = $('label[for="parcelaMax"]');
        var rAimaroLimite = $('label[for="aimaroLimite"]');
        var rParcelaPot = $('label[for="parcelaPot"]');
        var rParcelaValor = $('label[for="parcelaValor"]');

        var rParcelaOp = $('label[for="parcelaOp"]');
        var rParcelaOpC = $('label[for="parcelaOpC"]');
        var rVlpropAndamt = $('label[for="vlpropAndamt"]');
        var rVlpropAndamtCje = $('label[for="vlpropAndamtCje"]');
        var rVlpotLimMax = $('label[for="vlpotLimMax"]');
        var rNrfimpre = $('label[for="nrfimpre"]');
        var rSumempr = $('label[for="sumempr"]');
        var rVlparcel = $('label[for="vlparcel"]');
        var rVldispon = $('label[for="vldispon"]');
        var rVlpotParcMax = $('label[for="vlpotParcMax"]');
        var rUValorParc = $('label[for="uValorParc"]');
        var rVlScr6190 = $('label[for="vlScr6190"]');
        var rVlScr6190Cje = $('label[for="vlScr6190Cje"]');
        var rVlopePosScr = $('label[for="vlopePosScr"]');
        var rTipoCarga = $('label[for="tipoCarga"]');
        var rVlopePosScrCje = $('label[for="vlopePosScrCje"]');

        rFlgbloq.css({ width: '210px' });
        rTipoCarga.css({ width: '210px' });
        rVlparcel.css({ width: '210px' });
        rVldispon.css({ width: '210px' });
        rIdmotivo.css({ width: '120px' });
        rDtatualiza.css({ width: '120px' });
        rParcelaLC.css({ width: '380px' });
        rParcelaMax.css({ width: '380px' });
        rAimaroLimite.css({ width: '380px' });
        rParcelaPot.css({ width: '380px' });
        rParcelaValor.css({ width: '380px' });
        rParcelaOp.css({ width: '380px' });
        rParcelaOpC.css({ width: '380px' });
        rVlpropAndamt.css({ width: '430px' });
        rVlpotLimMax.css({ width: '430px' });
        rNrfimpre.css({ width: '430px' });
        rSumempr.css({ width: '430px' });
        rVlpotParcMax.css({ width: '430px' });
        rUValorParc.css({ width: '430px' });
        rVlScr6190.css({ width: '430px' });
        rVlScr6190Cje.css({ width: '430px' });
        rVlopePosScr.css({ width: '430px' });
        rVlopePosScrCje.css({ width: '430px' });
        rVlpropAndamtCje.css({ width: '430px' });

        var cFlgbloq = $('#flgbloq');
        var cIdmotivo = $('#idmotivo');
        var cDsmotivo = $('#dsmotivo');
        var cDtatualiza = $('#dtatualiza');
        var cParcelaLC = $('#parcelaLC');
        var cParcelaMax = $('#parcelaMax');
        var cAimaroLimite = $('#aimaroLimite');
        var cParcelaPot = $('#parcelaPot');
        var cParcelaValor = $('#parcelaValor');
        var cParcelaOp = $('#parcelaOp');
        var cParcelaOpC = $('#parcelaOpC');
        var cVlpropAndamt = $('#vlpropAndamt');
        var cVlpropAndamtCje = $('#vlpropAndamtCje');
        var cVlpotLimMax = $('#vlpotLimMax');
        var cNrfimpre = $('#nrfimpre');
        var cSumempr = $('#sumempr');
        var cVlparcel = $('#vlparcel');
        var cVldispon = $('#vldispon');
        var cVlpotParcMax = $('#vlpotParcMax');
        var cUValorParc = $('#uValorParc');
        var cVlScr6190 = $('#vlScr6190');
        var cVlScr6190Cje = $('#vlScr6190Cje');
        var cVlopePosScr = $('#vlopePosScr');
        var cTipoCarga = $('#tipoCarga');
        var cVlopePosScrCje = $('#vlopePosScrCje');

        cFlgbloq.css({ width: '100px', 'text-align': 'right' }).addClass('campo').desabilitaCampo();
        cIdmotivo.css({ width: '30px' }).addClass('campo').desabilitaCampo();
        cDsmotivo.css({ width: '250px' }).addClass('campo').desabilitaCampo();
        cDtatualiza.css({ width: '100px' }).addClass('campo').desabilitaCampo();
        cParcelaLC.css({ width: '100px' }).addClass('campo').desabilitaCampo();
        cParcelaMax.css({ width: '100px' }).addClass('campo').desabilitaCampo();
        cAimaroLimite.css({ width: '100px' }).addClass('campo').desabilitaCampo();
        cParcelaPot.css({ width: '100px' }).addClass('campo').desabilitaCampo();
        cParcelaValor.css({ width: '100px' }).addClass('campo').desabilitaCampo();
        cParcelaOp.css({ width: '100px' }).addClass('campo').desabilitaCampo();
        cParcelaOpC.css({ width: '100px' }).addClass('campo').desabilitaCampo();
        cVlpropAndamt.css({ width: '100px', 'text-align': 'right' }).addClass('campo').desabilitaCampo();
        cVlpropAndamtCje.css({ width: '100px', 'text-align': 'right' }).addClass('campo').desabilitaCampo();
        cVlpotLimMax.css({ width: '100px', 'text-align': 'right' }).addClass('campo').desabilitaCampo();
        cNrfimpre.css({ width: '100px', 'text-align': 'right' }).addClass('campo').desabilitaCampo();
        cSumempr.css({ width: '100px', 'text-align': 'right' }).addClass('campo').desabilitaCampo();
        cVlparcel.css({ width: '100px', 'text-align': 'right' }).addClass('campo').desabilitaCampo();
        cVldispon.css({ width: '100px', 'text-align': 'right' }).addClass('campo').desabilitaCampo();
        cVlpotParcMax.css({ width: '100px', 'text-align': 'right' }).addClass('campo').desabilitaCampo();
        cUValorParc.css({ width: '100px', 'text-align': 'right' }).addClass('campo').desabilitaCampo();
        cVlScr6190.css({ width: '100px', 'text-align': 'right' }).addClass('campo').desabilitaCampo();
        cVlScr6190Cje.css({ width: '100px', 'text-align': 'right' }).addClass('campo').desabilitaCampo();
        cVlopePosScr.css({ width: '100px', 'text-align': 'right' }).addClass('campo').desabilitaCampo();
        cTipoCarga.css({ width: '100px', 'text-align': 'right' }).addClass('campo').desabilitaCampo();
        cVlopePosScrCje.css({ width: '100px', 'text-align': 'right' }).addClass('campo').desabilitaCampo();
    } else {
        var cSemPreAprovado = $('#semPreAprovado');
        cSemPreAprovado.css({ width: '100%' });
    }
}

/**
 * Função para tratar o combo com os motivos de bloqueio ou desloqueio
 * A função recebe dois objetos
 * 
 * Param: @param objParam objeto para pegar o valor e ser tratado
 * 	      @param objComboAlvo objeto que vai ser afetado com o resultado			
 * 
 * Autor: David Valente [Envolti]
 * Data: 24/04/2019
 */

function populaComboMotivo(objParam, objComboAlvo) {

    // Caso tenha selecionado a opção SELECIONE
    if ($.trim($(objParam).val()) == "") {
        $(objComboAlvo).empty().append("<option>Selecione</option>");
        return false;
    }

    // Limpa conteúdo do combo alvo
    $(objComboAlvo).empty().append('<option>Carregando...</option>>');

    showMsgAguardo("Aguarde, processando dados...");

    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/pre_aprovado/form_combo_motivos.php",
        data: {
            pr_flgtipo: $(objParam).val(),
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', bloqueiaFundo(divRotina));
        },
        success: function (response) {

            $(objComboAlvo).empty().append(response);
            hideMsgAguardo();
            return false;
        }
    });
}



function formataRegraAltera(alterar) {
    var rIdmotivo = $('label[for="idmotivo"]');
    var rFlglibera = $('label[for="flglibera"]');
    var rDtatualiza = $('label[for="dtatualiza"]');
    var rStatusCarga = $('label[for="statusCarga"]');
    var rIdCarga = $('label[for="idCarga"]');
    var rVigInicial = $('label[for="vigInicial"]');
    var rVigFinal = $('label[for="vigFinal"]');

    rIdmotivo.css({ width: '260px' });
    rFlglibera.css({ width: '260px' });
    rDtatualiza.css({ width: '260px' });
    rStatusCarga.css({ width: '260px' });
    rIdCarga.css({ width: '260px' });
    rVigInicial.css({ width: '260px' });
    rVigFinal.css({ width: '22px' });

    var cIdmotivo = $('#idmotivo');
    var cFlglibera = $('#flglibera');
    var cDtatualiza = $('#dtatualiza');
    var cChkIndeter = $('#chkIndeter');

    if (alterar) {
        cFlglibera.habilitaCampo();

        if (cFlglibera.val() == 1) {
            cDtatualiza.desabilitaCampo().setMask("INTEGER", "99/99/9999", "");
            cChkIndeter.desabilitaCampo();
        } else {
            cDtatualiza.habilitaCampo().setMask("INTEGER", "99/99/9999", "");
            cChkIndeter.habilitaCampo();
        }

    } else {
        cIdmotivo.desabilitaCampo();
        cFlglibera.desabilitaCampo();
        cDtatualiza.desabilitaCampo();
        cChkIndeter.desabilitaCampo();
    }

    populaComboMotivo($(cFlglibera), $("#idmotivo"));

    var cStatusCarga = $('#statusCarga').desabilitaCampo();
    var cIdCarga = $('#idCarga').desabilitaCampo();
    var cVigInicial = $('#vigInicial').desabilitaCampo();
    var cVigFinal = $('#vigFinal').desabilitaCampo();

    cIdmotivo.css({ width: '200px' }).addClass('campo');
    cFlglibera.css({ width: '100px' }).addClass('campo');
    cDtatualiza.css({ width: '87px' }).addClass('campo');
    cStatusCarga.css({ width: '200px' }).addClass('campo');
    cIdCarga.css({ width: '200px' }).addClass('campo');
    cVigInicial.css({ width: '87px' }).addClass('campo');
    cVigFinal.css({ width: '87px' }).addClass('campo');
    cChkIndeter.css({ margin: '4px 4px 0 12px' }).addClass('campo');

    // Combo bloqueio manual sim/não
    cFlglibera.change(function () {
        // Atualiza os dados de acordo com a opção selecionada no combo flglibera
        populaComboMotivo($(this), $("#idmotivo"));
        if ($(this).val() == 0) {
            cIdmotivo.habilitaCampo();
            cChkIndeter.prop('checked', false).prop("disabled", false);
            cDtatualiza.habilitaCampo().val('');
        } else {
            cIdmotivo.desabilitaCampo();
            cChkIndeter.attr('checked', 'checked').desabilitaCampo();
            cDtatualiza.desabilitaCampo().val('');
        }
    });

    // Se marcar a opção indeterminado
    // Desabilita o campo data
    cChkIndeter.click(function () {
        if ($(this).is(':checked')) {
            cDtatualiza.val('');
            cDtatualiza.desabilitaCampo();
        } else {
            cDtatualiza.habilitaCampo().setMask("INTEGER", "99/99/9999", "");
            $(cDtatualiza).focus();
        }

    });

    $('#btVoltar').css({ padding: '3px' });
    $('#btAlterar').css({ padding: '3px' });
    $('#btConcluir').css({ padding: '3px' });
}


function confirmaAlteracao() {
    if ($('#dtatualiza').val() == "" && !$('#chkIndeter').is(':checked') && $('#flglibera').val() == 0) {
        showError('error', 'Uma data ou per&iacute;odo indefinido deve ser selecionados!', 'Notifica&ccedil;&atilde;o - Ayllos', '');
    } else {
        showConfirmacao('Confirma a opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'alteraRegra();', 'voltaRotina($("#divRotina"));', 'sim.gif', 'nao.gif');
    }
}


function alteraRegra() {

    var flglibera = $('#flglibera', '#frmPreAprovadoAltera').val();
    var idmotivo = $('#idmotivo', '#frmPreAprovadoAltera').val();
    var dtatualiza = $('#dtatualiza', '#frmPreAprovadoAltera').val();

    showMsgAguardo("Aguarde, alterando dados...");

    $.post(UrlSite + "telas/atenda/pre_aprovado/manter_alterar.php", {
        nrdconta: nrdconta,
        flglibera: flglibera,
        idmotivo: idmotivo,
        dtatualiza: dtatualiza,
        opcaoAcao: "ins"
    })
		.done(function (response) {
		    try {
		        if (response.indexOf('showError("error"') == -1) {
		            showError('inform', 'Altera&ccedil;&atilde;o salva com sucesso!', 'Notifica&ccedil;&atilde;o - Ayllos', acessaOpcaoAba(2, 2, 2));
		            //$('#divConteudoOpcao').html(response);
		        } else {
		            // Volta ao estado inicial
		            $('#flglibera').prop('selectedIndex', 0);
		            $('#idmotivo').prop('selectedIndex', 0);
		            $('#dtatualiza').val('');
		            eval(response);
		        }

		        return false;
		    } catch (error) {
		        hideMsgAguardo();
		        showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		    }
		})
		 .fail(function () {
		     hideMsgAguardo();
		     showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		 });
}

function voltaRotina() {
    acessaOpcaoAba(2, 2, 2);
}

function liberarAltera() {

    showMsgAguardo("Aguarde, processando dados...");

    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/pre_aprovado/manter_alterar.php",
        data: {
            nrdconta: nrdconta,
            alterar: 1,
            opcao: "cons",
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', bloqueiaFundo(divRotina));
        },
        success: function (response) {
            if (response.indexOf('showError("error"') == -1) {
                hideMsgAguardo();

                $('#divConteudoOpcao').html(response);

                formataRegraAltera(true);
                tabelaLayoutPreAprov();
            } else {
                hideMsgAguardo();
                eval(response);
            }

            return false;
        }
    });

}
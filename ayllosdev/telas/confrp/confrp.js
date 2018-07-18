/*!
 * FONTE        : confrp.js
 * CRIAÇÃO      : Lombardi (CECRED)
 * DATA CRIAÇÃO : Março/2016
 * OBJETIVO     : Biblioteca de funções da tela CONFRP
 */
function confirmar(qtdregis, idparame_reciproci, dslogcfg, cp_idparame_reciproci, cp_desmensagem, cp_deslogconfrp, executafuncao, divanterior, tela_anterior) {
    var ls_configrp = "";
    var ls_vinculacoesrp = "";
    var idindicador;
    var nmindicador;
    var tpindicador;
    var vlminimo;
    var vlmaximo;
    var perscore;
    var pertolera;
    var verifica_selecionados = false;
    var qtvinculacoes = $('#hd_qtdvinculacoes').val();

    for (var i = 0; i < qtdregis; i++) {
        if ($('#ativo' + i).is(':checked')) {
            if ($('#tpindicador' + i).val()[0] == "M" || $('#tpindicador' + i).val()[0] == "Q") {
                if ($('#vlminimo' + i).val() == "" || converteNumero($('#vlminimo' + i).val()) < 0.01) {
                    exibeMensagem($('#nmindicador' + i).val() + " - Valor M&iacute;nimo inv&aacute;lido! Favor informar um valor superior a 0(zero) e inferior ao Valor M&aacute;ximo!");
                    return false;
                }
                if ($('#vlmaximo' + i).val() == "") {
                    exibeMensagem($('#nmindicador' + i).val() + " - Valor M&aacute;ximo inv&aacute;lido! Favor informar um valor superior ao Valor M&iacute;nimo!");
                    return false;
                }                
            }
            if ($('#peso' + i).val() == "" || converteNumero($('#peso' + i).val()) < 0.01) {
                exibeMensagem($('#nmindicador' + i).val() + " - Peso inv&aacute;lido! Favor informar um valor superior a 0(zero)!");
                return false;
            }
            verifica_selecionados = true;
        }
    }

    for (var i = 0; i < qtvinculacoes; i++) {
        if ($('#ativa' + i).is(':checked')) {
            if ($('#tpvinculacao' + i).val()[0] == "M" || $('#tpvinculacao' + i).val()[0] == "Q") {
                if ($('#vlpercentual' + i).val() == "" || converteNumero($('#vlpercentual' + i).val()) < 0.01) {
                    exibeMensagem($('#nmvinculacao' + i).val() + " - Valor inv&aacute;lido! Favor informar um valor superior a 0(zero)!");
                    return false;
                }
            }
            verifica_selecionados = true;
        }
    }

    if ($('#vlcustocee').val() == "" || converteNumero($('#vlcustocee').val()) < 0.01) {
        exibeMensagem("Custo CEE - Valor inv&aacute;lido! Favor informar um valor superior a 0(zero)!");
        return false;
    }
    
    if ($('#vlcustocoo').val() == "" || converteNumero($('#vlcustocoo').val()) < 0.01) {
        exibeMensagem("Custo COO - Valor inv&aacute;lido! Favor informar um valor superior a 0(zero)!");
        return false;
    }
    
    if ($('#vlpesoboleto').val() == "" || converteNumero($('#vlpesoboleto').val()) < 0.01) {
        exibeMensagem("Peso do boleto - Valor inv&aacute;lido! Favor informar um valor superior a 0(zero)!");
        return false;
    }
    
    if ($('#vlpesoadicional').val() == "" || converteNumero($('#vlpesoadicional').val()) < 0.01) {
        exibeMensagem("Peso adicional - Valor inv&aacute;lido! Favor informar um valor superior a 0(zero)!");
        return false;
    }    

    if (!verifica_selecionados) {
        if (tela_anterior == 'pacote_tarifas')
            eval('fechaRotina($(\'#divUsoGenerico\'));' + executafuncao);
        else
            exibeMensagem("Pelo menos um indicador deve estar ativo e com todas as informa&ccedil;&otilde;es preenchidas!");
        return false;
    }


    for (var i = 0; i < qtdregis; i++) {
        if ($('#ativo' + i).is(':checked')) {
            if ($('#tpindicador' + i).val()[0] == "A" &&
                (($('#vlminimo' + i).val() != "" && $('#vlminimo' + i).val() != "-") ||
                    ($('#vlmaximo' + i).val() != "" && $('#vlmaximo' + i).val() != "-"))) {
                exibeMensagem($('#nmindicador' + i).val() + " - Indicador do tipo Ades&atilde;o s&oacute; permite o preenchimento do '%Score!");
                $('#vlminimo' + i).val("-");
                $('#vlmaximo' + i).val("-");
                return false;
            }

            vlminimo = converteMoedaFloat($('#vlminimo' + i).val());
            vlmaximo = converteMoedaFloat($('#vlmaximo' + i).val());

            if ((vlminimo > vlmaximo) || (vlminimo < 0)) {
                exibeMensagem($('#nmindicador' + i).val() + " - Valor M&iacute;nimo inv&aacute;lido! Favor informar um valor superior a 0(zero) e inferior ao Valor M&aacute;ximo!");
                return false;
            }

            if ((vlmaximo < vlminimo) || (vlmaximo < 0)) {
                exibeMensagem($('#nmindicador' + i).val() + " - Valor M&aacute;ximo inv&aacute;lido! Favor informar um valor superior ao Valor M&iacute;nimo!");
                return false;
            }
        }
        ls_configrp += $('#ativo' + i).is(':checked') + ',';
        ls_configrp += converteNumero($('#idindicador' + i).val()) + ',';
        ls_configrp += $('#tpindicador' + i).val()[0] + ',';
        ls_configrp += converteNumero($('#vlminimo' + i).val()) + ',';
        ls_configrp += converteNumero($('#vlmaximo' + i).val()) + ',';
        ls_configrp += converteNumero($('#peso' + i).val()) + ';';
    }

    for (var i = 0; i < qtvinculacoes; i++) {
        ls_vinculacoesrp += $('#ativa' + i).is(':checked') + ',';
        ls_vinculacoesrp += converteNumero($('#idvinculacao' + i).val()) + ',';
        ls_vinculacoesrp += $('#tpvinculacao' + i).val()[0] + ',';
        ls_vinculacoesrp += converteNumero($('#vlpercentual' + i).val()) + ';';
    }

    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/confrp/confirmar_config.php',
        data: {
            ls_configrp: ls_configrp.replace(/.$/, ''),
            ls_vinculacoesrp: ls_vinculacoesrp.replace(/.$/, ''),
            vlcustocee: converteNumero($('#vlcustocee').val()),
            vlcustocoo: converteNumero($('#vlcustocoo').val()),
            vlpesoboleto: converteNumero($('#vlpesoboleto').val()),
            vlpesoadicional: converteNumero($('#vlpesoadicional').val()),
            idparame_reciproci: idparame_reciproci,
            dslogcfg: dslogcfg,
            totaldesconto: $('#totaldesconto').val(),
            cp_idparame_reciproci: cp_idparame_reciproci,
            cp_desmensagem: cp_desmensagem,
            cp_deslogconfrp: cp_deslogconfrp,
            executafuncao: executafuncao,
            divanterior: divanterior,
            redirect: 'html_ajax' // Tipo de retorno do ajax
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#nrercben','#divBeneficio').focus();");
        },
        success: function(response) {
            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground();');
            }
        }
    });
}

function converteNumero(numero) {
    return numero.replace('.', '').replace(',', '.');
}

function exibeMensagem(msg) {
    showError("inform", msg, "Alerta - Ayllos", "bloqueiaFundo($('#divUsoGenerico'));", "NaN");
}
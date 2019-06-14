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
            if ($('#desconto' + i).val() == "" || converteNumero($('#peso' + i).val()) < 0.01) {
                exibeMensagem($('#nmindicador' + i).val() + " - Desconto inv&aacute;lido! Favor informar um valor superior a 0(zero)!");
                return false;
            }
            verifica_selecionados = true;
        }
    }

    for (var i = 0; i < qtvinculacoes; i++) {
        if ($('#ativa' + i).is(':checked')) {
            if ($('#descontovinculacao' + i).val() == "" || converteNumero($('#descontovinculacao' + i).val()) < 0.01) {
                exibeMensagem("Vincula&ccedil;&atilde;o " + $('#nmvinculacao' + i).val() + " - Desconto inv&aacute;lido! Favor informar um valor superior a 0(zero)!");
                return false;
            }
            if ($('#pesovinculacao' + i).val() == "" || converteNumero($('#pesovinculacao' + i).val()) < 0.01) {
                exibeMensagem("Vincula&ccedil;&atilde;o " + $('#nmvinculacao' + i).val() + " - Peso inv&aacute;lido! Favor informar um valor superior a 0(zero)!");
                return false;
            }
            verifica_selecionados = true;
        }
    }

    if ($('#vldescontomax_cee').val() == "" || converteNumero($('#vldescontomax_cee').val()) < 0.01) {
        exibeMensagem("Custo CEE - Valor inv&aacute;lido! Favor informar um valor superior a 0(zero)!");
        return false;
    }
    
    if ($('#vldescontomax_coo').val() == "" || converteNumero($('#vldescontomax_coo').val()) < 0.01) {
        exibeMensagem("Custo COO - Valor inv&aacute;lido! Favor informar um valor superior a 0(zero)!");
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
        ls_configrp += converteMoedaFloat($('#vlminimo' + i).val()) + ',';
        ls_configrp += converteMoedaFloat($('#vlmaximo' + i).val()) + ',';
        ls_configrp += converteNumero($('#peso' + i).val()) + ',';
        ls_configrp += converteNumero($('#desconto' + i).val()) + ';';
    }

    for (var i = 0; i < qtvinculacoes; i++) {
        ls_vinculacoesrp += 'true,';
        ls_vinculacoesrp += converteNumero($('#idvinculacao' + i).val()) + ',';
        ls_vinculacoesrp += converteNumero($('#descontovinculacao' + i).val()) + ',';
        ls_vinculacoesrp += converteNumero($('#pesovinculacao' + i).val()) + ';';
    }

    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/confrp/confirmar_config.php',
        data: {
            ls_configrp: ls_configrp.replace(/.$/, ''),
            ls_vinculacoesrp: ls_vinculacoesrp.replace(/.$/, ''),
            vldescontomax_cee: converteNumero($('#vldescontomax_cee').val()),
            vldescontomax_coo: converteNumero($('#vldescontomax_coo').val()),
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
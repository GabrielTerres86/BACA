/*!
 * FONTE        : desconto_rating.js
 * CRIAÇÃO      : Luiz Otávio Olinger Momm (AMCOM)
 * DATA CRIAÇÃO : Março/2019
 * OBJETIVO     : Biblioteca de funções da subrotina de Descontos de Títulos
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 
 * 001: [04/03/2019] Inclusão do botão Alterar Rating P450 (Luiz Otávio Olinger Momm - AMCOM).
 * 002: [14/03/2019] Inclusão do botão Analisar P450 (Luiz Otávio Olinger Momm - AMCOM).
 * 003: [15/04/2019] Identificação quando for Analisar e quando for Alterar Rating P450 (Luiz Otávio Olinger Momm - AMCOM)
 * 004: [20/05/2019] Alteração para o novo limite de crédito utilizar o Analisar e Alterar Rating - P450 (Luiz Otávio Olinger Momm - AMCOM)

/* [001] */
function btnTituloPropostaRating() {
    /*
    Variáveis nrdconta, nrctrlim globais no JS ao clicar na linha
    */
    carregarAlteracaoRating(nrdconta, nrctrlim, '3');
    return false;
}

function btnChequeRating() {
    /*
    Variáveis nrdconta, nrcontrato globais no JS ao clicar na linha
    */
    if (nrdconta > 0 && nrcontrato > 0) {
        carregarAlteracaoRating(nrdconta, nrcontrato, '2');
        return false;
    } else {
        return false;
    }
}

var widthDIVDialog = $('#divOpcoesDaOpcao2').css("width");

function formatarTelaAlteracaoRating(){

    $('#divAlteracaoRating').css('width','400px');

    $('fieldset').css({'clear': 'both', 'border': '1px solid #777', 'margin': '3px', 'padding': '10px 3px 5px 3px'});
    $('fieldset > legend').css({'font-size': '11px', 'color': '#777', 'margin-left': '5px', 'padding': '0px 2px'});

    return false;
}

function carregarAlteracaoRating(nrdconta, contrato, tipoProduto) {
    showMsgAguardo('Aguarde, carregando alteração de Rating ...');
    exibeRotina($('#divOpcoesDaOpcao2'));

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/descontos/rating/rating.php',
        data: {
            nrdconta: nrdconta,
            contrato: contrato,
            tipoProduto: tipoProduto,
            btntipo: '2',
            redirect: 'html_ajax'
            },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro',"unblockBackground()");
        },
        success: function(response) {
            if (response.toLowerCase().indexOf("ERRO RATING".toLowerCase()) != -1) {
                hideMsgAguardo();
                showError('error', response, 'Alerta - Aimaro',"unblockBackground()");
                if (tipoProduto == '3') {
                    carregaLimitesTitulosPropostas();
                    formataLayout('divPropostas');
                }
                if (tipoProduto == '2') {
                    carregaLimitesCheques();
                    formataLayout('divLimites');
                }
            } else {

                $('#divOpcoesDaOpcao2').html(response);
                layoutPadrao();
                hideMsgAguardo();
                formatarTelaAlteracaoRating();
                divRotina.centralizaRotinaH();
                bloqueiaFundo(divRotina);
                
                if (tipoProduto == '3') {

                    $("#btVoltar", "#divBotoesFormRatingManutencao").unbind('click').bind('click', function() {
                        carregaLimitesTitulosPropostas();
                        formataLayout('divPropostas');
                        return false;
                    });
                    $("#btSair").unbind('click').bind('click', function() {
                        carregaLimitesTitulosPropostas();
                        formataLayout('divPropostas');
                        return false;
                    });

                } else if (tipoProduto == '2') {

                    $("#btVoltar", "#divBotoesFormRatingManutencao").unbind('click').bind('click', function() {
                        carregaLimitesCheques();
                        formataLayout('divLimites');
                        return false;
                    });
                    $("#btSair").unbind('click').bind('click', function() {
                        carregaLimitesCheques();
                        formataLayout('divLimites');
                        return false;
                    });

                }

                $("#btSalvar", "#divBotoesFormRatingManutencao").unbind('click').bind('click', function() {
                    var tipoproduto = $(this).data('tipoproduto');
                    salvarAlteracaoRating(tipoproduto);
                });
            }
            return false;
        }
    });

    return false;
}

function salvarAlteracaoRating(paramTipoproduto) {
    showMsgAguardo('Aguarde, enviando rating ...');
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/atenda/descontos/rating/ajax_rating.php',
        dataType: "json",
        data: {
            flgopcao: 'salvarRating',
            btntipo: '2',
            cdcooper: $("#divBotoesFormRatingManutencao").data('cdcooper'),
            nrcpfcgc: $("#divBotoesFormRatingManutencao").data('nrcpfcgc'),
            nrdconta: $("#divBotoesFormRatingManutencao").data('nrdconta'),
            contrato: $("#divBotoesFormRatingManutencao").data('contrato'),
            justificativa: $("#campoJustificativa", "#frmRatingManutencao").val(),
            notanova: $("#notanova", "#frmRatingManutencao").val(),
            tipoproduto: paramTipoproduto
        }
    }).done(function(jsonResult) {
        hideMsgAguardo();
        if (jsonResult.erro == true) {
            showError('error', jsonResult.msg, 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
        } else {
            if (paramTipoproduto == '3') {
                carregaLimitesTitulosPropostas();
                formataLayout('divPropostas');
                return false;
            }
            if (paramTipoproduto == '2') {
                carregaLimitesCheques();
                formataLayout('divLimites');
                return false;
            }
        }
        return true;
    }).fail(function(jsonResult) {
        hideMsgAguardo();
        showError('error', 'Falha de comunicação com servidor. Tente novamente.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
    }).always(function() {

    });
}
/* [001] */

/* [002] */
function ratingMotor(paramTipoproduto) {
    /*
    Variáveis nrdconta, nrcontrato globais no JS ao clicar na linha
    */

    /* [004] */
    if (paramTipoproduto == '1') {
        // Variável global do Limite de Crédito em JSON
        nrcontrato = var_globais.nrctrpro;
        nrdconta = var_globais.nrdconta;
    }
    /* [004] */

    showMsgAguardo('Aguarde, enviando rating ...');
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/atenda/descontos/rating/ajax_rating.php',
        dataType: "json",
        data: {
            flgopcao: 'salvarRating',
            btntipo: '1',
            cdcooper: 999, // na Análise não é necessário retornar.
            nrcpfcgc: '',
            nrdconta: nrdconta,
            contrato: nrcontrato,
            justificativa: '',
            notanova: '',
            tipoproduto: paramTipoproduto
        }
    }).done(function(jsonResult) {
        hideMsgAguardo();
        if (jsonResult.erro == true) {
            showError('error', jsonResult.msg, 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
        } else {
            if (paramTipoproduto == '2') {
                showError('inform', 'Operação realizada com sucesso', 'Aviso - Aimaro', 'bloqueiaFundo(divRotina); fechaRotina($("#divUsoGenerico"), $("#divRotina")); carregaLimitesCheques();');
            }
            if (paramTipoproduto == '3') {
                showError('inform', 'Operação realizada com sucesso', 'Aviso - Aimaro', 'bloqueiaFundo(divRotina)');
            }        
            if (paramTipoproduto == '1') {
                showError('inform', 'Operação realizada com sucesso', 'Aviso - Aimaro', 'bloqueiaFundo(divRotina);acessaTela("@");');
            }   
        }
        return true;
    }).fail(function(jsonResult) {
        hideMsgAguardo();
        showError('error', 'Falha de comunicação com servidor. Tente novamente.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
    }).always(function() {

    });
}
/* [002] */
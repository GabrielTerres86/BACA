/*!
 * FONTE        : limite_saque_taa.js
 * CRIAÇÃO      : James Prust Junior
 * DATA CRIAÇÃO : Julho/2015
 * OBJETIVO     : Funcoes da tela Limite Saque TAA
 * --------------
 * ALTERAÇÕES   : 00/00/0000 - 
 * --------------
 **************** Cuidado ao alterar o fonte, pois o mesmo é utilizado na rotina de Cartão Magnético e Cartão de Crédito.
 *
 *                30/07/2016 - Adicionado função controlaFoco.(Evandro - RKAM).
 * 				  27/06/2018 - Ajustes JS para execução do Ayllos em modo embarcado no CRM. (Christian Grosch - CECRED)
 */
function acessaOpcaoAbaLimiteSaqueTAA() {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando dados do limite saque TAA...");

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/limite_saque_taa/principal.php",
        data: {
            nrdconta: nrdconta,
            operacao: "AC",
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", bloqueiaFundo(divRotina));
        },
        success: function (response) {
            if (response.indexOf('showError("error"') == -1) {
                $('#divConteudoLimiteSaqueTAA').html(response);
                controlaFoco();
            } else {
                eval(response);
            }
            return false;
        }
    });
}

//Função para controle de navegação
function controlaFoco() {
    $('#divConteudoLimiteSaqueTAA').each(function () {
        $(this).find("#divBotoes > a").first().addClass("FirstInputModal").focus();
        $(this).find("#divBotoes > a").last().addClass("LastInputModal");
    });

    //Se estiver com foco na classe LastInputModal
    $(".FirstInputModal").focus(function () {
        $(this).bind('keydown', function (e) {   
            if (e.keyCode == 27) {
                encerraRotina();
            }
            //e.stopPropagation();
            //e.preventDefault();
        });
    });

    //Se estiver com foco na classe LastInputModal
    $(".LastInputModal").focus(function () {
        var pressedShift = false;

        $(this).bind('keyup', function (e) {
            if (e.keyCode == 16) {
                pressedShift = false;//Quando tecla shift for solta passa valor false 
            }
        })

        $(this).bind('keydown', function (e) {
            e.stopPropagation();
            e.preventDefault();

            if (e.keyCode == 27) {
                encerraRotina();
            }
            if (e.keyCode == 13) {
                $(".LastInputModal").click();
            }
            if (e.keyCode == 16) {
                pressedShift = true;//Quando tecla shift for pressionada passa valor true 
            }
            if ((e.keyCode == 9) && pressedShift == true) {
                return setFocusCampo($(target), e, false, 0);
            }
            else if (e.keyCode == 9) {
                $(".FirstInputModal").focus();
            }
        });
    });

    $(".FirstInputModal").focus();
}

// Função que formata o layout
function controlaLayoutLimiteSaqueTAA(operacao) {

    var cTodos = $('select,input', '#frmLimiteSaqueTAA');
    // label
    rVllimiteSaque = $('label[for="vllimite_saque"]', '#frmLimiteSaqueTAA');
    rFlgemissaoReciboSaque = $('label[for="flgemissao_recibo_saque"]', '#frmLimiteSaqueTAA');
    rDtalteracaoLimite = $('label[for="dtalteracao_limite"]', '#frmLimiteSaqueTAA');
    rNmoperadorAlteracao = $('label[for="nmoperador_alteracao"]', '#frmLimiteSaqueTAA');

    rVllimiteSaque.addClass('rotulo').css('width', '140px');
    rFlgemissaoReciboSaque.addClass('rotulo').css('width', '140px');
    rDtalteracaoLimite.addClass('rotulo').css('width', '140px');
    rNmoperadorAlteracao.addClass('rotulo').css('width', '140px');

    // campo
    cVllimiteSaque = $('#vllimite_saque', '#frmLimiteSaqueTAA');
    cFlgemissaoReciboSaque = $('#flgemissao_recibo_saque', '#frmLimiteSaqueTAA');
    cDtalteracaoLimite = $('#dtalteracao_limite', '#frmLimiteSaqueTAA');
    cNmoperadorAlteracao = $('#nmoperador_alteracao', '#frmLimiteSaqueTAA');

    cVllimiteSaque.setMask('DECIMAL', 'zzz.zzz.zz9,99', '.', '');
    cVllimiteSaque.css('width', '110px');
    cFlgemissaoReciboSaque.css('width', '110px');
    cDtalteracaoLimite.css('width', '110px');
    cNmoperadorAlteracao.css('width', '300px');
    cTodos.desabilitaCampo();
    cTodos.addClass('campo');

    switch (operacao) {
        // Concluir Alteracao
        case 'CA':
            cVllimiteSaque.habilitaCampo();
            cVllimiteSaque.focus();
            cFlgemissaoReciboSaque.habilitaCampo();
            break;
    }

    hideMsgAguardo();
    bloqueiaFundo(divRotina);
    divRotina.centralizaRotinaH();
}

function controlaOperacaoLimiteSaqueTAA(operacao, nomeRotinaPai) {

    var msgOperacao = '';
    var nomeRotinaPai = nomeRotinaPai || 'limite_saque_taa';

    switch (operacao) {
        // Consulta para Alteração
        case 'CA':
            msgOperacao = 'abrindo altera&ccedil;&atilde;o';
            cddopcao = 'A';
            break;
            // Alteração para Consulta
        case 'AC':
            showConfirmacao('Deseja cancelar altera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Aimaro', 'controlaOperacaoLimiteSaqueTAA(\'\')', 'bloqueiaFundo(divRotina)', 'sim.gif', 'nao.gif');
            return false;
            break;
            // Finalizar Alteracao	
        case 'CONCLUIR':
            if ((nomeRotinaPai == 'magnetico') || (nomeRotinaPai == 'cartao_credito')) {
                msgOperacao = 'Deseja confirmar a entrega do cart&atilde;o?';
            } else {
                msgOperacao = 'Deseja confirmar a altera&ccedil;&atilde;o?';
            }
            showConfirmacao(msgOperacao, 'Confirma&ccedil;&atilde;o - Aimaro', 'manterRotinaLimiteSaqueTAA("' + nomeRotinaPai + '")', 'bloqueiaFundo(divRotina)', 'sim.gif', 'nao.gif');
            return false;
            break;
        default:
            msgOperacao = 'abrindo consulta';
            cddopcao = '@';
            break;
    }

    showMsgAguardo('Aguarde, ' + msgOperacao + '...');

    // Executa script de através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/limite_saque_taa/principal.php',
        data: {
            nrdconta: nrdconta,
            operacao: operacao,
            nomeRotinaPai: nomeRotinaPai,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
        },
        success: function (response) {
            if (response.indexOf('showError("error"') == -1) {
                $('#divConteudoLimiteSaqueTAA').html(response);
            } else {
                eval(response);
            }
            return false;
        }
    });
}

function manterRotinaLimiteSaqueTAA(nomeRotinaPai) {

    showMsgAguardo('Aguarde, salvando altera&ccedil;&atilde;o ...');

    var fVllimiteSaque = $('#vllimite_saque', '#frmLimiteSaqueTAA').val();
    var iEmissaoReciboSaque = $('#flgemissao_recibo_saque', '#frmLimiteSaqueTAA').val();

    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/atenda/limite_saque_taa/manter_rotina.php',
        data: {
            nrdconta: nrdconta,
            nomeRotinaPai: nomeRotinaPai,
            vllimite_saque: fVllimiteSaque,
            flgemissao_recibo_saque: iEmissaoReciboSaque,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
                return;
            }
            hideMsgAguardo();
            bloqueiaFundo(divRotina);
        }
    });
}
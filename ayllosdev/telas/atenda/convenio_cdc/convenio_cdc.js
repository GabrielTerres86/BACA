/*!
 * FONTE        : convenio_cdc.js
 * CRIAÇÃO      : Andre Santos (SUPERO)
 * DATA CRIAÇÃO : Janeiro/2015
 * OBJETIVO     : Biblioteca de funções da rotina Convenio CDC  da tela de CONTAS
 * --------------
 * ALTERAÇÕES   : 09/03/2015 - Incluir o item Convenio CDC - Pessoa Fisica
 *                             (Andre Santos - SUPERO)
 *							   
 *				  24/08/2015 - Projeto Reformulacao cadastral		   
 *						  	  (Tiago Castro - RKAM)			
 *
 *                25/07/2016 - Adicionado função controlaFoco.(Evandro - RKAM).
 * --------------
 */

var rFlgativo, rDtcnvcdc,
    cFlgativo, cDtcnvcdc;

var idseqttl = "1"; // Variável global para armazenar nr. da sequencia dos titulares

// Função para acessar opções da rotina
function acessaOpcaoAba() {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        dataType: "html",
        type: "POST",
        url: UrlSite + "telas/atenda/convenio_cdc/principal.php",
        data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            flgcadas: "C",
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', bloqueiaFundo(divRotina));
        },
        success: function (response) {
            $('#divConteudoOpcao').html(response);
            controlaFoco();
        }
    });
}

//Função para controle de navegação
function controlaFoco() {
    $('#divConteudoOpcao').each(function () {
        $(this).find("#frmConvenioCdc > select").first().addClass("FirstInputModal").focus();
        $(this).find("#frmConvenioCdc > select").first().addClass("FluxoNavega");
        $(this).find("#divBotoes > :input[type=image]").addClass("FluxoNavega");
        $(this).find("#divBotoes > :input[type=image]").last().addClass("LastInputModal");
    });

    //Se estiver com foco na classe FluxoNavega
    $("#btVoltar").focus(function () {
        $(this).bind('keydown', function (e) {
            if (e.keyCode == 13) {
                e.stopPropagation();
                e.preventDefault();
                encerraRotina().click();
            }
        });
    });

    $(".LastInputModal").focus(function () {
        var pressedShift = false;

        $(this).bind('keyup', function (e) {
            if (e.keyCode == 16) {
                pressedShift = false;//Quando tecla shift for solta passa valor false 
            }
        })

        $(this).bind('keydown', function (e) {
            if (e.keyCode == 27) {
                e.stopPropagation();
                e.preventDefault();
                encerraRotina().click();
            }
            if (e.keyCode == 13) {
                $(this).click();
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


function manterRotina() {

    showMsgAguardo('Aguarde, salvando altera&ccedil;&atilde;o ...');

    var flgativo = ($('#flgativo', '#frmConvenioCdc').val() == 'S') ? true : false;
    var dtcnvcdc = $('#dtcnvcdc', '#frmConvenioCdc').val();

    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/atenda/convenio_cdc/manter_rotina.php',
        data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            flgativo: flgativo,
            dtcnvcdc: dtcnvcdc,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function (response) {
            hideMsgAguardo();
            showError('inform', 'O Conv&ecirc;nio CDC foi atualizado com sucesso!', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina);acessaOpcaoAba()');
            eval(response);

        }
    });
}

function mostraData() {
    if ($('#flgativo', '#frmConvenioCdc').val() == 'S') {
        $('#divDataConvnio').css({ 'display': 'block' });
    } else {
        $('#divDataConvnio').css({ 'display': 'none' });
        $('#dtcnvcdc', '#frmConvenioCdc').val('');
    }
    return false;
}

// Função para seleção de titular para consulta e alteração de dados
function selecionaTitular(id, qtTitulares) {

    // Formata cor da linha da tabela que lista titulares e esconde div com dados do mesmo
    for (var i = 1; i <= qtTitulares; i++) {

        // Esconde div com dados do titular
        $("#divTitInternet" + i).css("display", "none");
    }

    // Mostra div com os dados do titular selecionado
    $("#divTitInternet" + id).css("display", "block");

    // Mostra sequência do titular no título da área de dados
    $("#spanSeqTitular").html(id);

    $("#divTitularCDCPrincipal > #divBotoes > input").each(function () {
        $(this).prop("disabled", false);
    });

    // Armazena sequencial do titular selecionado
    idseqttl = id;
}

function controlaLayout() {

    var rFlgativo = $('label[for="flgativo"]', '#frmConvenioCdc');
    var rDtcnvcdc = $('label[for="dtcnvcdc"]', '#frmConvenioCdc');

    var cFlgativo = $('#flgativo', '#frmConvenioCdc');
    var cDtcnvcdc = $('#dtcnvcdc', '#frmConvenioCdc');

    $('#frmConvenioCdc').css({ 'padding-top': '5px', 'padding-bottom': '15px' });

    // Formatação dos rotulos
    rFlgativo.css('width', '150px');
    rDtcnvcdc.css('width', '150px');

    cFlgativo.css('width', '50px');
    cDtcnvcdc.addClass('campo').addClass('data').css({ 'width': '85px' });

    highlightObjFocus($('#frmConvenioCdc'));

    cFlgativo.habilitaCampo();
    cFlgativo.focus();

    cFlgativo.unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            cDtcnvcdc.focus();
            return false;
        }
    });

    cDtcnvcdc.unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            manterRotina();
            return false;
        }
    });

    if ($('#flgativo', '#frmConvenioCdc').val() == 'S') {
        $('#divDataConvnio').css({ 'display': 'block' });
    } else {
        $('#divDataConvnio').css({ 'display': 'none' });
        $('#dtcnvcdc', '#frmConvenioCdc').val('');
    }

    var divRegistro = $('div.divRegistros', '#divTitularCDCPrincipal');
    var tabela = $('table', divRegistro);

    divRegistro.css('height', '55px');

    var ordemInicial = new Array();


    var arrayLargura = new Array();
    arrayLargura[0] = '70px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'left';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

    $('tbody > tr', tabela).each(function () {
        if ($(this).hasClass('corSelecao')) {
            $(this).focus();
        }
    });


    layoutPadrao();
    hideMsgAguardo();
    bloqueiaFundo(divRotina);
    $(this).fadeIn(1000);
    divRotina.centralizaRotinaH();
    return false;
}
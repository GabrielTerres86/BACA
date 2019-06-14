/*!
 * FONTE        : dda.js
 * CRIAÇÃO      : Gabriel Ramirez
 * DATA CRIAÇÃO : Abril/2011 
 * OBJETIVO     : Biblioteca de funções da tela DDA 
 * --------------
 * ALTERAÇÕES   :
 * 29/06/2012 - Jorge Hamaguchi (CECRED) : Ajuste para esquema de impressao em funcao termo() e titulosBloqueados()
 * 09/07/2012 - Jorge Hamaguchi (CECRED) : Retirado campo "redirect" popup
 * 03/12/2014 - Jean Reddiga  	(RKAM)	 : De acordo com a circula 3.656 do Banco Central, substituir nomenclaturas 
 *                                         Cedente por Beneficiário e Sacado por Pagador. Chamado 229313
 * 24/08/2015 - Projeto Reformulacao cadastral		   
 *  			(Tiago Castro - RKAM)
 * 25/07/2016 - (Evandro - RKAM) : Adicionado função controlaFoco. 
 * 27/06/2018 - Christian Grosch (CECRED): Ajustes JS para execução do Ayllos em modo embarcado no CRM.
 * --------------
 */

var contWin = 0;   // Variável para contagem do número de janelas abertas para impressos
var idseqttl = "1"; // Variável global para armazenar nr. da sequencia dos titulares
function acessaOpcaoAba() {

    showMsgAguardo('Aguarde, carregando os dados ...');

    // Carrega conteúdo da opção através do Ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/dda/principal.php',
        data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            redirect: 'ajax_html'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
        },
        success: function (response) {
            $("#divImpressoes").css({ 'display': 'none' });
            $("#divTestemunhas").css({ 'display': 'none' });
            $("#divConteudoOpcao").css({ 'display': 'block' });
            $("#divConteudoOpcao").html(response);
            controlaFoco();
        }
    });
}

//Função para controle de navegação
function controlaFoco() {
    $('#divConteudoOpcao').each(function () {
        $(this).find("#divBotoes > :input[type=image]").addClass("FluxoNavega");
        $(this).find("#divBotoes > :input[type=image]").first().addClass("FirstInputModal").focus();
        $(this).find("#divBotoes > :input[type=image]").last().addClass("LastInputModal");
    });

    //Se estiver com foco na classe FluxoNavega
    $(".FirstInputModal").focus(function () {
        $(this).bind('keydown', function (e) {
            if (e.keyCode == 13) {
                e.stopPropagation();
                e.preventDefault();
                encerraRotina();
            }
        });
    });

    //Se estiver com foco na classe FluxoNavega
    $(".FluxoNavega").focus(function () {
        $(this).bind('keydown', function (e) {
            if (e.keyCode == 13) {
                $(this).click();
            }
        });
    });

    $(".FirstInputModal").focus();
}

function acessaTitular() {

    $("#divConteudoTitular").remove();
    $("#divBotoes").remove();

    showMsgAguardo('Aguarde, carregando os dados ...');

    // Carrega conteúdo da opção através do Ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/dda/principal_titular.php',
        data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            redirect: 'ajax_html'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
        },
        success: function (response) {
            $("#divConteudoOpcao").append(response);
        }
    });
}

function ConfirmaAderir() {

    showConfirmacao('Confirma a ades&atilde;o do cooperado ao DDA ?', 'Confirma&ccedil;&atilde;o - Aimaro', 'aderir()', ' blockBackground(parseInt($("#divRotina").css("z-index")))', 'sim.gif', 'nao.gif');

}

function aderir() {

    var nmrotina = "aderir-sacado";

    showMsgAguardo('Aguarde, aderindo ao DDA ...');

    // Carrega conteúdo da opção através do Ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/dda/manter_rotina.php',
        data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            nmrotina: nmrotina,
            redirect: 'ajax_html'
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
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

function ConfirmaEncerrar() {

    showConfirmacao('Confirma a exclus&atilde;o do cooperado ao DDA ?', 'Confirma&ccedil;&atilde;o - Aimaro', 'encerrar()', ' blockBackground(parseInt($("#divRotina").css("z-index")))', 'sim.gif', 'nao.gif');

}

function encerrar() {

    var nmrotina = "encerrar-sacado-dda";

    showMsgAguardo('Aguarde, encerrando o DDA ...');

    // Carrega conteúdo da opção através do Ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/dda/manter_rotina.php',
        data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            nmrotina: nmrotina,
            redirect: 'ajax_html'
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
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

function imprimir() {

    // Carrega conteúdo da opção através do Ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/dda/imprimir.php',
        data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            redirect: 'ajax_html'
        },
        error: function (objAjax, responseError, objExcept) {
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
        },
        success: function (response) {
            $("#divImpressoes").html(response);
        }
    });
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

    $("#divTitularDDAPrincipal > #divBotoes > input").each(function () {
        $(this).prop("disabled", false);
    });

    // Armazena sequencial do titular selecionado
    idseqttl = id;

}

function controlaLayoutTabela() {

    var divRegistro = $('div.divRegistros', '#divTitularDDAPrincipal');
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
}

// Controlar Layout quando selecionado Botao de 'Imprimir'
function controlaLayout() {

    $("#divConteudoOpcao").css({ 'display': 'none' });
    $("#divImpressoes").css({ 'display': 'block' });

    $('div', '#divImpressoes').css({
        'display': 'block',
        'float': 'left',
        'margin': '6px',
        'font-weight': 'bold',
        'border-color': '#949ead',
        'border-style': 'solid',
        'background-color': '#ced3c6',
        'border-width': '1px',
        'cursor': 'auto',
        'padding': '10px 21px'
    });

    // Trocando a classe no evento hover
    $('div', '#divImpressoes').hover(
		function () {
		    $(this).css({ 'background-color': '#f7f3f7', 'border-width': '1px', 'cursor': 'pointer' });
		},
		function () {
		    $(this).css({ 'background-color': '#ced3c6', 'border-width': '1px', 'cursor': 'auto' });
		}
	);

    // Adicionando evento click
    $('div', '#divImpressoes').click(function () {

        if ($(this).attr('id') == "adesao") {
            testemunhas("imprime-termo-adesao");
        }
        else
            if ($(this).attr('id') == "exclusao") {
                testemunhas("imprime-termo-exclusao");
            }
            else
                if ($(this).attr('id') == "titulos") {
                    verificaSacado();
                }
    });
}




function confirmaImpressao(nmrotina) {

    var dsmsg = (nmrotina == "aderir-sacado") ? "ades&atilde;o" : "exclus&atilde;o";

    nmrotina = (nmrotina == "aderir-sacado") ? "imprime-termo-adesao" : "imprime-termo-exclusao";

    var metodo = (executandoProdutos) ? "encerraRotina();" : "acessaOpcaoAba();";

    metodo += "blockBackground(parseInt($('#divRotina').css('z-index')));";

    showConfirmacao('Deseja imprimir o termo de ' + dsmsg + '?',
                    'Confirma&ccedil;&atilde;o - Aimaro',
                    'testemunhas("' + nmrotina + '")',
                    metodo,
                    'sim.gif',
                    'nao.gif');
}

function testemunhas(nmrotina) {

    // Carrega conteúdo da opção através do Ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/dda/testemunhas.php',
        data: {
            nmrotina: nmrotina,
            redirect: 'ajax_html'
        },
        error: function (objAjax, responseError, objExcept) {
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
        },
        success: function (response) {
            $("#divTestemunhas").html(response);
        }
    });
}


function validaCpf(nmrotina) {

    var nmdtest1 = $("#nmdtest1", "#divTestemunhas").val();
    var cpftest1 = $("#cpftest1", "#divTestemunhas").val();
    var nmdtest2 = $("#nmdtest2", "#divTestemunhas").val();
    var cpftest2 = $("#cpftest2", "#divTestemunhas").val();

    showMsgAguardo('Aguarde, validando os dados ...');

    // Carrega conteúdo da opção através do Ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/dda/valida_cpf.php',
        data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            nmrotina: nmrotina,
            nmdtest1: nmdtest1,
            cpftest1: cpftest1,
            nmdtest2: nmdtest2,
            cpftest2: cpftest2,
            redirect: 'ajax_html'
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
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}


function termo(nmrotina) {

    var nmdtest1 = $("#nmdtest1", "#divTestemunhas").val();
    var cpftest1 = $("#cpftest1", "#divTestemunhas").val();
    var nmdtest2 = $("#nmdtest2", "#divTestemunhas").val();
    var cpftest2 = $("#cpftest2", "#divTestemunhas").val();

    $('#sidlogin', '#frmTermo').remove();

    $('#frmTermo').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin', '#frmMenu').val() + '" />');

    $("#nrdconta", "#frmTermo").val(nrdconta);
    $("#idseqttl", "#frmTermo").val(idseqttl);
    $("#nmrotina", "#frmTermo").val(nmrotina);
    $("#nmdtest1", "#frmTermo").val(nmdtest1);
    $("#cpftest1", "#frmTermo").val(cpftest1);
    $("#nmdtest2", "#frmTermo").val(nmdtest2);
    $("#cpftest2", "#frmTermo").val(cpftest2);

    var action = $("#frmTermo").attr("action");
    var callafter = (executandoProdutos) ? "encerraRotina();" : "acessaOpcaoAba();";

    carregaImpressaoAyllos("frmTermo", action, callafter);

}

function verificaSacado() {

    showMsgAguardo('Aguarde, verificando a situacao do Pagador ...');

    // Carrega conteúdo da opção através do Ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/dda/verifica_sacado.php',
        data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            redirect: 'ajax_html'
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
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

function titulosBloqueados() {

    $('#sidlogin', '#frmTitulos').remove();

    $('#frmTitulos').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin', '#frmMenu').val() + '" />');

    $("#nrdconta", "#frmTitulos").val(nrdconta);
    $("#idseqttl", "#frmTitulos").val(idseqttl);

    var action = $("#frmTitulos").attr("action");
    var callafter = "acessaOpcaoAba();";

    carregaImpressaoAyllos("frmTitulos", action, callafter);

}
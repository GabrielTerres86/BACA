/***********************************************************************
      Fonte: pagamento_titulo_arq.js
      Autor: Andre Santos - SUPERO
      Data : Setembro/2014            Ultima atualizacao:  /  /

      Objetivo  : Biblioteca de funcoes da rotina PAGTO TITULOS POR ARQUIVO tela ATENDA.

      Alteracoes:
      25/07/2016 - Adicionado função controlaFoco.(Evandro - RKAM).
 ***********************************************************************/

var dsdregis = "";  // Variavel para armazenar os valores dos titulares
var nrconven = 0;   // Variavel para guardar o convenio no inclui-altera.php
var mensagem = "Deseja efetuar impress&atilde;o do Termo de Ades&atilde;o ?"; // Mensagem de confirmacao de impressao
var callafterCobranca = '';

function habilitaSetor(setorLogado) {

    var setoresHabilitados = ['COBRANCA', 'TI', 'SUPORTE'];

    if (setoresHabilitados.indexOf(setorLogado) == -1) {
        $('#flgcebhm', '#frmConsulta').desabilitaCampo();
    }
}


// Acessar tela principal da rotina
function acessaOpcaoAba() {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando os pagtos de titulos...");

    // Carrega conte&uacute;do da op&ccedil;&atilde;o atrav&eacute;s de ajax
    $.ajax({
        dataType: "html",
        type: "POST",
        url: UrlSite + "telas/atenda/pagamento_titulo_arq/principal.php",
        data: {
            nrdconta: nrdconta,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function (response) {
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
    $(".FluxoNavega").focus(function () {
        $(this).bind('keydown', function (e) {
            if (e.keyCode == 13) {
                $(this).click();
            }
        });
    });

    $(".FirstInputModal").focus();
}

/* Iniciar Impressao Termo de Servi&ccedil;o */
function acessaImpressaoTermo() {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando Termo de Servi&ccedil;o ...");

    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/pagamento_titulo_arq/imprimir.php",
        data: {
            nrdconta: nrdconta,
            nmdatela: "ATENDA",
            nmrotina: "PAGTO POR ARQUIVO",
            redirect: "html_ajax" // Tipo de retorno do ajax			
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "");
        },
        success: function (response) {
            $("#divRotina").html(response);
        }
    });
}


/* Voltar para a rotina de Pagto por Arquivo */
function encerrarImpressaoTermo() {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando Termo de Servi&ccedil;o ...");

    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/pagamento_titulo_arq/pagamento_titulo_arq.php",
        data: {
            nrdconta: nrdconta,
            nmdatela: "ATENDA",
            nmrotina: "PAGTO POR ARQUIVO",
            redirect: "html_ajax" // Tipo de retorno do ajax			
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "");
        },
        success: function (response) {
            $("#divRotina").html(response);
        }
    });
}


// Confirma se o convenio deve ser excluido
function confirmaExclusao() {

    var nrconven = $("#nrconven", "#divConteudoOpcao").val();

    // Convenio nao selecionado
    if (nrconven == "") {
        showError("error", "Selecione algum conv&ecirc;nio para excluir.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    showConfirmacao('078 - Confirma cancelamento do servi&ccedil;o? (S/N)', "Confirma&ccedil;&atilde;o - Ayllos", 'VerifConvenioAceiteCancel(0);', "blockBackground(parseInt($('#divRotina').css('z-index')))", "sim.gif", "nao.gif");
}


// Confirma inclusao de convenio
function confirmaInclusao() {
    showConfirmacao('078 - Confirma Ades&atilde;o ao servi&ccedil;o? (S/N)', "Confirma&ccedil;&atilde;o - Ayllos", 'VerifConvenioAceiteCancel(1);', "blockBackground(parseInt($('#divRotina').css('z-index')))", "sim.gif", "nao.gif");
}


function VerifConvenioAceiteCancel(tpdtermo) {

    var msg;

    // Quantdo Cancelar o Convenio
    if (tpdtermo == 0) {
        var nrconven = $("#nrconven", "#divConteudoOpcao").val();

        if (nrconven == "") {
            showError("error", "Selecione algum conv&ecirc;nio para excluir.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            return false;
        }
    } else {
        var nrconven = 1;
    }

    // Mostra mensagem de aguardo
    if (tpdtermo == 0) {
        showMsgAguardo("Aguarde, cancelando o Servi&ccedil;o ...");
    } else {
        showMsgAguardo("Aguarde, efetuando a Ades&atilde;o do Servi&ccedil;o ...");
    }

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        dataType: "html",
        type: "POST",
        url: UrlSite + "telas/atenda/pagamento_titulo_arq/verifica_conven_aceit_cancel.php",
        data: {
            nrdconta: nrdconta,
            nrconven: nrconven,
            tpdtermo: tpdtermo,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                hideMsgAguardo();
                if (tpdtermo == 0) {
                    msg = 'Cancelamento do Servi&ccedil;o efetuado com sucesso! <br/> Favor imprimir o Termo de Cancelamento para o cooperado.';
                } else {
                    msg = 'Ades&atilde;o do Servi&ccedil;o efetuado com sucesso! <br/>Favor imprimir o Termo de Ades&atilde;o para o cooperado.';
                }
                showError("inform", msg, "Alerta - Ayllos", "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));acessaOpcaoAba();");

                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}


function buscaTermoServico(tpdtermo) {

    var msg;
    var nrconven = 1;

    // Mostra mensagem de aguardo
    if (tpdtermo == 0) {
        showMsgAguardo("Aguarde, buscando Termo de Cancelando do Servi&ccedil;o ...");
    } else {
        showMsgAguardo("Aguarde, buscando Termo de Ades&atilde;o do Servi&ccedil;o ...");
    }

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        dataType: "html",
        type: "POST",
        url: UrlSite + "telas/atenda/pagamento_titulo_arq/relatorio.php",
        data: {
            nrdconta: nrdconta,
            nrconven: nrconven,
            tpdtermo: tpdtermo,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                hideMsgAguardo();
                ImpressaoTermoServico(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}


function ImpressaoTermoServico(resposta) {

    showMsgAguardo("Aguarde, abrindo termo ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        dataType: "html",
        type: "POST",
        url: UrlSite + "telas/atenda/pagamento_titulo_arq/impressao.php",
        data: {
            resposta: resposta,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                hideMsgAguardo();
                $("#divRotina").html(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}


function impressaoConteudo() {

    var conteudo = document.getElementById('divTermo').innerHTML,
    tela_impressao = window.open('about:blank');

    tela_impressao.document.write(conteudo);
    tela_impressao.document.close(); // <-- Esse close é uma particularidade do IE
    tela_impressao.window.focus();   // <-- Esse focus é uma particularidade do IE
    tela_impressao.window.print();
    tela_impressao.window.close();
}


/* Formata a tabela gerada dentro do fonte principal.php */
function controlaLayout(nomeForm) {

    if (nomeForm == 'divResultado') {

        var divRegistro = $('div.divRegistros', '#' + nomeForm);
        var tabela = $('table', divRegistro);

        tabela.zebraTabela(0);

        $('#' + nomeForm).css('width', '600px');
        divRegistro.css('height', '85px');

        var ordemInicial = new Array();

        var arrayLargura = new Array();
        arrayLargura[0] = '60px';
        arrayLargura[1] = '83px';
        arrayLargura[2] = '260px';
        arrayLargura[3] = '63x';
        arrayLargura[4] = '53px';
        arrayLargura[5] = '15px';

        var arrayAlinha = new Array();
        arrayAlinha[0] = 'right';
        arrayAlinha[1] = 'center';
        arrayAlinha[2] = 'left';
        arrayAlinha[3] = 'center';
        arrayAlinha[4] = 'center';

        tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

        $('tbody > tr', tabela).each(function () {
            if ($(this).hasClass('corSelecao')) {
                $(this).focus();
            }
        });

        ajustarCentralizacao();

    }

    callafterCobranca = '';
    layoutPadrao();
    return false;
}


// Destacar convenio selecinado e setar valores do item selecionado
function selecionaConvenio(idLinha, nrconven, dtcadast, cdoperad, flgativo, dsorigem) {

    $("#nrconven", "#divConteudoOpcao").val(nrconven);
    $("#dtcadast", "#divConteudoOpcao").val(dtcadast);
    $("#cdoperad", "#divConteudoOpcao").val(cdoperad);
    $("#flgativo", "#divConteudoOpcao").val(flgativo);
    $("#dsorigem", "#divConteudoOpcao").val(dsorigem);

}
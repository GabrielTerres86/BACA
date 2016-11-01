/*******************************************************************
    Fonte: telefone.js
    Autor: Gabriel
    Data : Janeiro/2011                Ultima atualizacao : 13/07/2011

    Objetivo  : Biblioteca de funcoes da rotina TELEFONE tela ATENDA.

    Alteracoes: 13/07/2011 - Alterado para layout padrão (Gabriel Capoia - DB1)

*******************************************************************/


// Acessar tela principal da rotina
function acessaOpcaoAba() {

    $("#linkAba0").addClass('FirstInputModal')
    $("#linkAba0").addClass('LastInputModal').focus();
    $("#linkAba0:focus").css({ 'border': 'none', 'outline': 'none' });
    $(".LastInputModal").bind('keydown', function (e) {
        if (e.keyCode == 9) {
            $(".FirstInputModal").focus();
            e.stopPropagation();
            e.preventDefault();
        }
    });

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando os telefones ...");

    // Carrega conte&uacute;do da op&ccedil;&atilde;o atrav&eacute;s de ajax
    $.ajax({
        dataType: "html",
        type: "POST",
        url: UrlSite + "telas/atenda/telefone/principal.php",
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
        }
    });

}

function controlaLayout() {

    var nomeForm = 'divResultado';
    var divRegistro = $('div.divRegistros', '#' + nomeForm);
    var tabela = $('table', divRegistro);

    divRegistro.css('height', '140px');

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '75px';
    arrayLargura[1] = '40px';
    arrayLargura[2] = '60px';
    arrayLargura[3] = '45px';
    arrayLargura[4] = '80px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'center';


    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

}
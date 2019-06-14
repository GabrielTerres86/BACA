/************************************************************************
 Fonte: prestacoes.js                                              
 Autor: Lucas R                                                 
 Data : Maio/2013                Última Alteração: //
																  
 Objetivo  : Biblioteca de funções da rotina de Prestacoes da tela 
			 ATENDA                                               
																	 
 Alterações:
            18/08/2016 - Adicionado função controlaFoco - (Evandro - RKAM)
 ***********************************************************************/

//Função para controle de navegação
function controlaFoco() {
    $('#divConteudoOpcao').each(function () {
        $(this).find("#divBotoes > :input[type=image]").addClass("FluxoNavega");
        $(this).find("#divBotoes > :input[type=image]").first().addClass("FirstInputModal").focus();
        $(this).find("#divBotoes > :input[type=image]").last().addClass("LastInputModal");

        $(this).find("#divBotoes > a").addClass("FluxoNavega");
        $(this).find("#divBotoes > a").first().addClass("FirstInputModal").focus();
        $(this).find("#divBotoes > a").last().addClass("LastInputModal");
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




function CarregaCooperativa() {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde carregando dados de emprestimos da cooperativa ...");

    // Carrega biblioteca javascript da rotina
    // Ao carregar efetua chamada do conteúdo da rotina através de ajax
    $.getScript(UrlSite + "telas/atenda/prestacoes/cooperativa/prestacoes.js", function () {
        $.ajax({
            type: "POST",
            dataType: "html",
            url: UrlSite + "telas/atenda/prestacoes/cooperativa/prestacoes.php",
            data: {
                nrdconta: nrdconta,
                nmdatela: 'ATENDA',
                redirect: "html_ajax"
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            },
            success: function (response) {
                hideMsgAguardo();
                $("#divRotina").html(response);
                controlaFoco();
            }
        });
    });

}


function CarregaBndes() {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde carregando dados do BNDES ...");

    // Carrega biblioteca javascript da rotina
    // Ao carregar efetua chamada do conteúdo da rotina através de ajax
    $.getScript(UrlSite + "telas/atenda/prestacoes/bndes/bndes.js", function () {
        $.ajax({
            type: "POST",
            dataType: "html",
            url: UrlSite + "telas/atenda/prestacoes/bndes/bndes.php",
            data: {
                nrdconta: nrdconta,
                nmdatela: 'ATENDA',
                redirect: "html_ajax"
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            },
            success: function (response) {
                hideMsgAguardo();
                $("#divRotina").html(response);
                controlaFoco();
                $("#divBotoes > a").first().addClass("FirstInputModal").focus();
                $("#divBotoes > a").last().addClass("LastInputModal");
            }
        });
    });
}
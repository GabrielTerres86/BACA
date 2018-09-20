/***********************************************************************
      Fonte: convenios.js
      Autor: Guilherme
      Data : Fevereiro/2007                &Uacute;ltima Altera&ccedil;&atilde;o:   /  /

      Objetivo  : Biblioteca de fun&ccedil;&otilde;es da rotina CONVENIOS da tela
                  ATENDA

      Altera&ccedil;&otilde;es:
              30/06/2011 - Alterado para layout padrão (Rogerius - DB1).		
	  
 ***********************************************************************/

// Fun&ccedil;&atilde;o para acessar op&ccedil;&otilde;es da rotina
function acessaOpcaoAba(nrOpcoes, id, opcao) {


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


    if (opcao == "0") {	// Op&ccedil;&atilde;o Principal
        var msg = "conv&ecirc;nios";
    }
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando " + msg + " ...");

    // Atribui cor de destaque para aba da op&ccedil;&atilde;o
    for (var i = 0; i < nrOpcoes; i++) {
        if (id == i) { // Atribui estilos para foco da op&ccedil;&atilde;o
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
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/convenios/principal.php",
        data: {
            nrdconta: nrdconta,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function (response) {
            $("#divConteudoOpcao").html(response);
        }
    });
}

// Função para formata o layout
function controlaLayout() {

    // tabela	
    var divRegistro = $('div.divRegistros');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({ 'height': '180px' });

    var ordemInicial = new Array();
    ordemInicial = [[2, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '30px';
    arrayLargura[1] = '200px';
    arrayLargura[2] = '78px';
    arrayLargura[3] = '65px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'right';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'right';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);

}

//************************************************************************//
//*** Fonte: conta_investimento.js                                     ***//
//*** Autor: David                                                     ***//
//*** Data : Setembro/2007                Ultima Alteracao: 26/06/2012 ***//
//***                                                                  ***//
//*** Objetivo  : Biblioteca de funcoes da rotina Conta Investimento   ***//
//***             da tela ATENDA                                       ***//
//***                                                                  ***//	 
//*** Alteracoes: 06/10/2008 - Validar aplicacoes bloqueadas (David).  ***//
//***																   ***//
//***			  30/06/2011 - Alterado para layout padrão			   ***// 
//***						   (Rogerius - DB1).			           ***//
//***																   ***//
//***			  26/06/2012 - Alterado condicao para submeter impressao**//
//***						   em imprimirExtrato() (Jorge)	           ***//
//***                                                                  ***//
//***		      25/07/2016 - Adicionado função controlaFoco          ***//
//***		                                (Evandro - RKAM)		   ***//        
//************************************************************************//

// Fun&ccedil;&atilde;o para acessar op&ccedil;&otilde;es da rotina
function acessaOpcaoAba(nrOpcoes, id, opcao) {
    if (opcao == "@") {	// Op&ccedil;&atilde;o Principal
        var msg = ", carregando extrato";
        var UrlOperacao = UrlSite + "telas/atenda/conta_investimento/principal.php";
    } else if (opcao == "S") { // Op&ccedil;&atilde;o Saque
        var msg = ", carregando op&ccedil;&atilde;o para saque";
        var UrlOperacao = UrlSite + "telas/atenda/conta_investimento/saque.php";
    } else if (opcao == "C") { // Op&ccedil;&atilde;o Cancelamento
        var msg = ", carregando op&ccedil;&atilde;o para cancelamento";
        var UrlOperacao = UrlSite + "telas/atenda/conta_investimento/cancelamento.php";
    } else if (opcao == "I") { // Op&ccedil;&atilde;o Imprime Extrato	
        var msg = ", carregando op&ccedil;&atilde;o para extrato";
        var UrlOperacao = UrlSite + "telas/atenda/conta_investimento/imprimir_extrato.php";
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde" + msg + " ...");

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

    if (opcao == "@") {	// Opção Principal		
        // Carrega conteúdo da opção através de ajax
        $.ajax({
            type: "POST",
            dataType: "html",
            url: UrlOperacao,
            data: {
                nrdconta: nrdconta,
                dtiniper: $("#dtiniper", "#frmContaInv").val(),
                dtfimper: $("#dtfimper", "#frmContaInv").val(),
                redirect: "html_ajax"
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            },
            success: function (response) {
                $("#divConteudoOpcao").html(response);
                controlaFoco(opcao);
                return false;
            }
        });
    } else { // Demais Opções
        // Carrega conteúdo da opção através de ajax
        $.ajax({
            type: "POST",
            dataType: "html",
            url: UrlOperacao,
            data: {
                redirect: "html_ajax"
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            },
            success: function (response) {
                $("#divConteudoOpcao").html(response);
                controlaFoco(opcao);
                return false;
            }
        });
    }


}

// Fun&ccedil;&atilde;o para confirmar saque na conta investimento
function confirmaSaque(inconfir) {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, efetuando saque ...");

    var vlresgat = $("#vlresgat", "#frmContaInv").val();

    // Valida valor do saque
    if ($.trim(vlresgat) == "" || !validaNumero(vlresgat, true, 0, 0)) {
        hideMsgAguardo();
        showError("erro", "Valor do Saque inv&aacute;lido.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')));$('#vlresgat','#frmContaInv').focus()");
        $("#vlresgat", "#frmContaInv").val("");
        return false;
    }

    // Executa script de saque atrav&eacute;s de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/conta_investimento/obtem_saque.php",
        data: {
            nrdconta: nrdconta,
            vlresgat: vlresgat.replace(/\./g, ""),
            inconfir: inconfir,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

// Fun&ccedil;&atilde;o para cancelar saque na conta investimento
function cancelaSaque() {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, cancelando saque ...");

    var nrdocmto = $("#nrdocmto", "#frmContaInv").val();

    // Valida n&uacute;mero de documento do saque
    if ($.trim(nrdocmto) == "") {
        hideMsgAguardo();
        showError("error", "N&uacute;mero do Documento inv&aacute;lido.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')));$('#nrdocmto','#frmContaInv').focus()");
        $("#nrdocmto", "#frmContaInv").val("");
        return false;
    }

    // Executa script de saque atrav&eacute;s de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/conta_investimento/obtem_cancelamento.php",
        data: {
            nrdconta: nrdconta,
            nrdocmto: nrdocmto.replace(/\./g, ""),
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

// Fun&ccedil;&atilde;o para imprimir extrato da conta investimento em PDF
function imprimirExtrato() {

    $("#nrdconta", "#frmContaInv").val(nrdconta);
    $("#nrctainv", "#frmContaInv").val(retiraCaracteres($("#nrctainv", "#frmCabAtenda").val(), "0123456789", true));

    var action = $("#frmContaInv").attr("action");
    var callafter = "bloqueiaFundo(divRotina);";

    carregaImpressaoAyllos("frmContaInv", action, callafter);

}

//
function layoutOpcao() {
    // Esconde mensagem de aguardo
    hideMsgAguardo();

    // Bloqueia conteúdo que está átras do div da rotina
    blockBackground(parseInt($("#divRotina").css("z-index")));
}


//controle de foco de navegação
function controlaFoco(opcao) {
    var IdForm = '';
    var formid;

    if (opcao == "@") { //Principal
        $('#divConteudoOpcao').each(function () {
            formid = $('#divConteudoOpcao form');
            IdForm = $(formid).attr('id');//Seleciona o id do formulario
            if (IdForm == "frmContaInv") {
                $(this).find("#frmContaInv > :input[type=text]").first().addClass("FirstInputModal").focus();
                $(this).find("#frmContaInv > :input").last().addClass("LastInputModal");
            };
        });
    }
    if (opcao == "S") { //Saque 
        $('#divConteudoOpcao').each(function () {
            formid = $('#divConteudoOpcao form');
            IdForm = $(formid).attr('id');//Seleciona o id do formulario
            if (IdForm == "frmContaInv") {
                $(this).find("#frmContaInv > :input[type=text]").first().addClass("FirstInputModal").focus();
                $(this).find("#frmContaInv > :input").last().addClass("LastInputModal");
            };
        });
    }
    if (opcao == "C") { //Cancelamento 
        $('#divConteudoOpcao').each(function () {
            formid = $('#divConteudoOpcao form');
            IdForm = $(formid).attr('id');//Seleciona o id do formulario
            if (IdForm == "frmContaInv") {
                $(this).find("#frmContaInv > :input[type=text]").first().addClass("FirstInputModal").focus();
                $(this).find("#frmContaInv > :input").last().addClass("LastInputModal");
            };
        });
    }
    if (opcao == "I") { //Imprimir extrato 
        $('#divConteudoOpcao').each(function () {
            formid = $('#divConteudoOpcao form');
            IdForm = $(formid).attr('id');//Seleciona o id do formulario
            if (IdForm == "frmContaInv") {
                $(this).find("#frmContaInv > :input[type=text]").first().addClass("FirstInputModal").focus();
                $(this).find("#frmContaInv > :input").last().addClass("LastInputModal");
            };
        });
    }

    //Se estiver com foco na classe LastInputModal
    $(".LastInputModal").focus(function () {
        $(this).bind('keydown', function (e) {
            if (e.keyCode == 13) {
                $(this).click();
                e.stopPropagation();
                e.preventDefault();
            }
        });
    });

    $(".FirstInputModal").focus();
}

// Função que formata o layout em tableless
function controlaLayout(aba) {

    var nomeForm = 'frmContaInv';

    if (aba == 'principal') {

        if ($.browser.msie) {
            $('#' + nomeForm).css('margin-bottom', '-10px')
        }

        // label
        rDtiniper = $('label[for="dtiniper"]', '#' + nomeForm);
        rDtfimper = $('label[for="dtfimper"]', '#' + nomeForm);

        rDtiniper.addClass('rotulo').css({ 'width': '50px' });
        rDtfimper.addClass('rotulo-linha');

        // campo
        cDtiniper = $('#dtiniper', '#' + nomeForm);
        cDtfimper = $('#dtfimper', '#' + nomeForm);

        cDtiniper.addClass('campo').css({ 'width': '65px' });
        cDtfimper.addClass('campo').css({ 'width': '65px' });

        // tabela
        var divRegistro = $('div.divRegistros');
        var tabela = $('table', divRegistro);
        var linha = $('table > tbody > tr', divRegistro);

        divRegistro.css({ 'height': '150px' });

        var ordemInicial = new Array();
        ordemInicial = [[0, 0]];

        var arrayLargura = new Array();
        arrayLargura[0] = '56px';
        arrayLargura[1] = '160px';
        arrayLargura[2] = '15px';
        arrayLargura[3] = '45px';
        arrayLargura[4] = '24px';
        arrayLargura[5] = '65px';


        var arrayAlinha = new Array();
        arrayAlinha[0] = 'left';
        arrayAlinha[1] = 'left';
        arrayAlinha[2] = 'center';
        arrayAlinha[3] = 'right';
        arrayAlinha[4] = 'center';
        arrayAlinha[5] = 'right';
        arrayAlinha[6] = 'right';

        tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);
    } else if (aba == 'saque') {

        // label
        rVlresgat = $('label[for="vlresgat"]', '#' + nomeForm);
        rVlresgat.addClass('rotulo').css({ 'width': '240px' });

        // campo
        cVlresgat = $('#vlresgat', '#' + nomeForm);
        cVlresgat.addClass('campo').css({ 'width': '85px', 'text-align': 'right' });

    } else if (aba == 'cancelamento') {

        // label
        rNrdocmto = $('label[for="nrdocmto"]', '#' + nomeForm);
        rNrdocmto.addClass('rotulo').css({ 'width': '260px' });

        // campo
        cNrdocmto = $('#nrdocmto', '#' + nomeForm);
        cNrdocmto.addClass('campo').css({ 'width': '85px', 'text-align': 'right' });

    } else if (aba == 'imprimir_extrato') {

        // label
        rDtiniper = $('label[for="dtiniper"]', '#' + nomeForm);
        rDtfimper = $('label[for="dtfimper"]', '#' + nomeForm);

        rDtiniper.addClass('rotulo').css({ 'width': '170px' });
        rDtfimper.addClass('rotulo-linha').css({ 'width': '10px' });

        // campo
        cDtiniper = $('#dtiniper', '#' + nomeForm);
        cDtfimper = $('#dtfimper', '#' + nomeForm);

        cDtiniper.addClass('campo').css({ 'width': '65px' });
        cDtfimper.addClass('campo').css({ 'width': '65px' });

    }

    layoutPadrao();
    return false;

}


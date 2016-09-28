//************************************************************************//
//*** Fonte: magneticos.js                                             ***//
//*** Autor: David                                                     ***//
//*** Data : Setembro/2008                �ltima Altera��o: 08/10/2015 ***//
//***                                                                  ***//
//*** Objetivo  : Biblioteca de fun��es da rotina Cart�es Magn�ticos   ***//
//***             da tela ATENDA                                       ***//
//***                                                                  ***//	 
//*** Altera��es: 04/06/2009 - Incluir par�metro tpusucar na altera��o ***//
//***                          de cart�o magn�tico (David).            ***//
//***                                                                  ***//	 
//***             22/10/2010 - Altera��o na acessaOpcaoAba (David).    ***//
//***																   ***//
//*** 		      13/07/2011 - Alterado para layout padr�o 			   ***//
//***						   (Rogerius - DB1). 					   ***//	
//***																   ***//
//***			  22/12/2011 - Ajuste para inclus�o das op��es   	   ***//
//***						   Num�rica, Solicitar Letras (Adriano).   ***//
//***																   ***//
//***			  05/01/2012 - Ajuste para alterar a senha do cartao   ***//
//***						   ao solicitar entrega (Adriano).		   ***//
//***																   ***//
//***			  12/01/2012 - Alterar Solicitar Letras para Limpar    ***//
//***                          Letras e adicionar Solicitar Letras     ****/
//***                          Altera��o geral para senha Letras       ***//
//***						   (Guilherme).                   		   ***//
//***																   ***//
//***			  27/06/2012 - Retirado window.open, alterado esquema de**//
//***						   impressao em geraDeclaracaoRecebimento() **//
//***						   e geraTermoResponsabilidade() (Jorge).  ***//
//***																   ***//
//***             07/11/2012 - Adicionado param. 'tpusucar' (Lucas)    ***//
//***																   ***//
//***	          11/01/2013 - Requisitar cadastro de Letras ao        ***//
//***						   entregar cartao (Lucas).                ***//
//***																   ***//
//***	          23/07/2015 - Remover as opcoes Limite e Recibo de    ***//
//***   					   Saque. (James)					       ***//
//***																   ***//
//***             08/10/2015 - Reformulacao cadastral (Gabriel-RKAM)   ***//
//***                                                                  ***//
//***        	  25/07/2016 - Adicionado fun��o controlaFoco. Evandro RKAM)*//
//************************************************************************//

var callafterMagneticos = '';
var metOpcaoAba = '';
var nrcartao = 0;  // Vari�vel para armazenar n�mero do cart�o magn�tico selecionado
var idLinha = 0;  // Vari�vel para armazanar o id da linha que cont�m o cart�o selecionado
var nrcpfppt = 0;  // Vari�vel para armazenar CPF do preposto
var cpfpreat = 0;  // Vari�vel para armazenar CPF do preposto atual
var tpusucar = 0;  // Vari�vel para armazenar idseqttl


// Fun��o para acessar op��es da rotina
function acessaOpcaoAba(nrOpcoes, id, opcao) {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando dados dos cart&otilde;es magn&eacute;ticos ...");

    callafterMagneticos = '';
    metOpcaoAba = '';

    // Atribui cor de destaque para aba da op&ccedil;&atilde;o
    $("#linkAba0").attr("class", "txtBrancoBold");
    $("#imgAbaEsq0").attr("src", UrlImagens + "background/mnu_sle.gif");
    $("#imgAbaDir0").attr("src", UrlImagens + "background/mnu_sld.gif");
    $("#imgAbaCen0").css("background-color", "#969FA9");

    // Carrega conte�do da op��o atrav�s de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/magneticos/principal.php",
        data: {
            nrdconta: nrdconta,
            inpessoa: inpessoa,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divConteudoOpcao").html(response);

            if (executandoProdutos) {
                solicitacaoCartao('I');
            }
            controlaFoco();
        }
    });
}

function controlaFoco() {
    var IdForm = '';
    var formid;
    $('#divConteudoOpcao').each(function () {
        formid = $('#divConteudoOpcao form');
        IdForm = $(formid).attr('id');//Seleciona o id do formulario
        if (IdForm == "frmDadosMagneticos") {
            $(this).find("#divBotoes > :input[type=image]").addClass("FluxoNavega");
            $(this).find("#divBotoes > :input[type=image]").first().addClass("FirstInputModal").focus();
            $(this).find("#divBotoes > :input[type=image]").last().addClass("LastInputModal");
        };
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

// Fun��o para sele��o do cart�o magn�ico
function selecionaMagnetico(id, qtMagneticos, cartao, tpusucar) {
    var cor = "";

    this.tpusucar = tpusucar;

    // Formata cor da linha da tabela que lista cart�es magn�ticos
    for (var i = 1; i <= qtMagneticos; i++) {

        // if (cor == "#F4F3F0") {
        // cor = "#FFFFFF";
        // } else {
        // cor = "#F4F3F0";
        // }		

        // Formata cor da linha
        // $("#trMagnetico" + i).css("background-color",cor);

        if (i == id) {
            // Atribui cor de destaque para cart�o magn�tico selecionado
            // $("#trMagnetico" + id).css("background-color","#FFB9AB");

            // Armazena n&uacute;mero do cart�o magn�tico selecionado
            nrcartao = retiraCaracteres(cartao, "0123456789", true);
            idLinha = id;
        }
    }
}

function voltarDivPrincipal(height, width) {
    var width = width || 0;

    $("#divMagneticosOpcao01").css("display", "none");
    $("#divConteudoLimiteSaqueTAA").css("display", "none");
    $('#divNumericaLetras').css('display', 'none');
    $('#divNumerica').css('display', 'none');
    $("#divMagneticosPrincipal").css("display", "block");

    $("#divConteudoOpcao").css("height", height + "px");

    if (width > 0) {
        $("#divConteudoOpcao").css("width", width + "px");
    }

    $("#divMagneticosOpcao01").html("");

}

// Fun��o para consultar cart�o magn�tico
function consultaCartaoMagnetico() {

    // Se n�o tiver nenhum cart�o selecionado
    if (nrcartao == 0) {
        return false;
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando dados do cart&atilde;o magn&eacute;tico ...");

    // Executa script de consulta atrav�s de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/magneticos/consultar.php",
        data: {
            nrdconta: nrdconta,
            nrcartao: nrcartao,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divMagneticosOpcao01").html(response);
        }
    });
}

// Fun��o para obter dados para alterar/incluir novo cart�o magn�tico
function solicitacaoCartao(cddopcao) {

    // Se n�o tiver nenhum cart�o selecionado
    if (cddopcao == "A" && nrcartao == 0) {
        return false;
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando dados " + (cddopcao == "I" ? "para novo" : "do") + " cart&atilde;o magn&eacute;tico ...");

    // Executa script de solicita��o atrav�s de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/magneticos/solicitacao.php",
        data: {
            nrdconta: nrdconta,
            nrcartao: (cddopcao == "A" ? nrcartao : "0"),
            cddopcao: cddopcao,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divMagneticosOpcao01").html(response);
        }
    });
}

// Fun��o para validar dados para altera��o do cart�o magn�tico
function validarDadosAlteracao() {
    var tpusucar = $("#tpusucar", "#frmDadosCartaoMagnetico").val();
    var nmtitcrd = $("#nmtitcrd", "#frmDadosCartaoMagnetico").val();

    // Valida identificador do titular do atrav�s de ajax
    if (tpusucar == "" || !validaNumero(tpusucar, true, 0, 0)) {
        showError("error", "Titular inv&aacute;lido.", "Alerta - Ayllos", "$('#tpusucar','#frmDadosCartaoMagnetico').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    // Valida o nome do titular
    if ($.trim(nmtitcrd) == "") {
        showError("error", "Inform o nome do titular.", "Alerta - Ayllos", "$('#nmtitcrd','#frmDadosCartaoMagnetico').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    showConfirmacao("Deseja alterar o cart&atilde;o magn&eacute;tico?", "Confirma&ccedil;&atilde;o - Ayllos", "alterarCartaoMagnetico(" + tpusucar + ",'" + nmtitcrd + "');", "blockBackground(parseInt($('#divRotina').css('z-index')))", "sim.gif", "nao.gif");
}

// Fun��o para alterar dados do cart�o magn�tico
function alterarCartaoMagnetico(tpusucar, nmtitcrd) {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, alterando solicita&ccedil;&atilde;o do cart&atilde;o magn&eacute;tico ...");

    // Executa script de altera��o atrav�s de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/magneticos/alterar_cartao_magnetico.php",
        data: {
            nrdconta: nrdconta,
            nrcartao: nrcartao,
            tpusucar: tpusucar,
            nmtitcrd: nmtitcrd,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

// Fun��o para validar dados para inclus�o do cart�o magn�tico
function validarDadosInclusao() {
    var tpusucar = $("#tpusucar", "#frmDadosCartaoMagnetico").val();
    var nmtitcrd = $("#nmtitcrd", "#frmDadosCartaoMagnetico").val();

    // Valida identificador do titular do atrav�s de ajax
    if (tpusucar == "" || !validaNumero(tpusucar, true, 0, 0)) {
        showError("error", "Titular inv&aacute;lido.", "Alerta - Ayllos", "$('#tpusucar','#frmDadosCartaoMagnetico').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    // Valida o nome do titular
    if ($.trim(nmtitcrd) == "") {
        showError("error", "Inform o nome do titular.", "Alerta - Ayllos", "$('#nmtitcrd','#frmDadosCartaoMagnetico').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    showConfirmacao("Deseja incluir o cart&atilde;o magn&eacute;tico?", "Confirma&ccedil;&atilde;o - Ayllos", "incluirCartaoMagnetico(" + tpusucar + ",'" + nmtitcrd + "');", "blockBackground(parseInt($('#divRotina').css('z-index')))", "sim.gif", "nao.gif");
}

// Fun��o para incluir novo cart�o magn�tico
function incluirCartaoMagnetico(tpusucar, nmtitcrd) {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, incluindo solicita&ccedil;&atilde;o de cart&atilde;o magn&eacute;tico ...");

    // Executa script de inclus�o atrav�s de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/magneticos/incluir_cartao_magnetico.php",
        data: {
            nrdconta: nrdconta,
            nrcartao: nrcartao,
            tpusucar: tpusucar,
            nmtitcrd: nmtitcrd,
            inpessoa: inpessoa,
            nrcpfppt: nrcpfppt,
            executandoProdutos: executandoProdutos,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

function confirmaExclusaoCartao() {
    // Se n�o tiver nenhum cart�o selecionado
    if (nrcartao == 0) {
        return false;
    }

    showConfirmacao("Deseja excluir o cart&atilde;o magn&eacute;tico?", "Confirma&ccedil;&atilde;o - Ayllos", "excluirCartaoMagnetico()", "blockBackground(parseInt($('#divRotina').css('z-index')))", "sim.gif", "nao.gif");
}

// Fun��o para excluir cart�o magn�tico
function excluirCartaoMagnetico() {
    // Se n�o tiver nenhum cart�o selecionado
    if (nrcartao == 0) {
        return false;
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, exclu&iacute;ndo cart&atilde;o magn&eacute;tico ...");

    // Executa script de exclus�o atrav�s de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/magneticos/excluir.php",
        data: {
            nrdconta: nrdconta,
            nrcartao: nrcartao,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

function confirmaBloqueioCartao() {
    // Se n�o tiver nenhum cart�o selecionado
    if (nrcartao == 0) {
        return false;
    }

    showConfirmacao("Deseja bloquear o cart&atilde;o magn&eacute;tico?", "Confirma&ccedil;&atilde;o - Ayllos", "bloquearCartaoMagnetico()", "blockBackground(parseInt($('#divRotina').css('z-index')))", "sim.gif", "nao.gif");
}

// Fun��o para bloquear cart�o magn�tico
function bloquearCartaoMagnetico() {
    // Se n�o tiver nenhum cart�o selecionado
    if (nrcartao == 0) {
        return false;
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, bloqueando cart&atilde;o magn&eacute;tico ...");

    // Executa script de bloqueio atrav�s de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/magneticos/bloquear.php",
        data: {
            nrdconta: nrdconta,
            nrcartao: nrcartao,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

function confirmaCancelamentoCartao() {
    // Se n�o tiver nenhum cart�o selecionado
    if (nrcartao == 0) {
        return false;
    }

    showConfirmacao("Deseja cancelar o cart&atilde;o magn&eacute;tico?", "Confirma&ccedil;&atilde;o - Ayllos", "cancelarCartaoMagnetico()", "blockBackground(parseInt($('#divRotina').css('z-index')))", "sim.gif", "nao.gif");
}

// Fun��o para bloquear cart�o magn�tico
function cancelarCartaoMagnetico() {
    // Se n�o tiver nenhum cart�o selecionado
    if (nrcartao == 0) {
        return false;
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, cancelando cart&atilde;o magn&eacute;tico ...");

    // Executa script de cancelamento atrav�s de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/magneticos/cancelar.php",
        data: {
            nrdconta: nrdconta,
            nrcartao: nrcartao,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

function acessaOpcaoSenha(ope) {

    var operacao = ope;

    // Se n�o tiver nenhum cart�o selecionado
    if (nrcartao == 0) {
        return false;
    }

    $('#divNumericaLetras').css('display', 'none');
    $("#divConteudoOpcao").css("height", "185px");


    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, obtendo dados para alterar a senha ...");

    // Executa script de cancelamento atrav�s de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/magneticos/senha.php",
        data: {
            nrdconta: nrdconta,
            nrcartao: nrcartao,
            operacao: operacao,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divMagneticosOpcao01").html(response);
        }
    });
}

function opcaoSolicitarLetras(ope) {

    var operacao = ope;

    // Se n�o tiver nenhum cart�o selecionado
    if (nrcartao == 0) {
        return false;
    }

    $('#divNumericaLetras').css('display', 'none');
    $('#divConteudoLimiteSaqueTAA').css('display', 'none');
    $("#divConteudoOpcao").css("height", "165px");
    $("#divConteudoOpcao").css("width", "490px");

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, obtendo dados para alterar as Letras de Seguranca ...");

    // Executa script atrav�s de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/magneticos/senha_letras.php",
        data: {
            nrdconta: nrdconta,
            nrcartao: nrcartao,
            operacao: operacao,
            tpusucar: tpusucar,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divMagneticosOpcao01").html(response);
        }
    });
}

// Fun��o para validar altera��o de senha do cart�o magn�tico
function validarAlteracaoSenhaCartao(ope) {

    var nrsenatu = $("#nrsenatu", "#frmSenhaCartaoMagnetico").val();
    var nrsencar = $("#nrsencar", "#frmSenhaCartaoMagnetico").val();
    var nrsencon = $("#nrsencon", "#frmSenhaCartaoMagnetico").val();
    var operacao = ope;

    if (nrsenatu == "") {
        showError("error", "Informe a senha atual.", "Alerta - Ayllos", "$('#nrsenatu','#frmSenhaCartaoMagnetico').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    if (nrsencar == "") {
        showError("error", "Informe a nova senha.", "Alerta - Ayllos", "$('#nrsencar','#frmSenhaCartaoMagnetico').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    if (nrsencon == "") {
        showError("error", "Confirme a nova senha.", "Alerta - Ayllos", "$('#nrsencon','#frmSenhaCartaoMagnetico').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    showConfirmacao("Deseja alterar a senha do cart&atilde;o magn&eacute;tico?", "Confirma&ccedil;&atilde;o - Ayllos", "alterarSenhaCartao()", "blockBackground(parseInt($('#divRotina').css('z-index')))", "sim.gif", "nao.gif");
}

// Fun��o para validar altera��o de senha do cart�o magn�tico
function validarAlteracaoSenhaLetrasCartao(ope) {

    var dssennov = $("#dssennov", "#frmSenhaLetrasCartaoMagnetico").val();
    var dssencon = $("#dssencon", "#frmSenhaLetrasCartaoMagnetico").val();
    var operacao = ope;

    if (dssennov == "") {
        showError("error", "Informe as Letras de Seguran&ccedila.", "Alerta - Ayllos", "$('#dssennov','#frmSenhaLetrasCartaoMagnetico').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    if (dssencon == "") {
        showError("error", "Confirme as suas letras.", "Alerta - Ayllos", "$('#dssencon','#frmSenhaLetrasCartaoMagnetico').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    if (operacao == "E") {
        showConfirmacao("Deseja cadastrar as Letras de Seguran&ccedil;a  do cart&atilde;o magn&eacute;tico?", "Confirma&ccedil;&atilde;o - Ayllos", "alterarSenhaLetrasCartao()", "blockBackground(parseInt($('#divRotina').css('z-index')))", "sim.gif", "nao.gif");
    } else {
        showConfirmacao("Deseja alterar as Letras de Seguran&ccedil;a  do cart&atilde;o magn&eacute;tico?", "Confirma&ccedil;&atilde;o - Ayllos", "alterarSenhaLetrasCartao()", "blockBackground(parseInt($('#divRotina').css('z-index')))", "sim.gif", "nao.gif");
    }
}

// Fun��o para alterar senha do cart�o magn�tico
function alterarSenhaCartao() {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, alterando senha do cart&atilde;o magn&eacute;tico ...");

    var nrsenatu = $("#nrsenatu", "#frmSenhaCartaoMagnetico").val();
    var nrsencar = $("#nrsencar", "#frmSenhaCartaoMagnetico").val();
    var nrsencon = $("#nrsencon", "#frmSenhaCartaoMagnetico").val();

    // Executa script de altera��o de senha atrav�s de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/magneticos/alterar_senha.php",
        data: {
            nrdconta: nrdconta,
            nrcartao: nrcartao,
            nrsenatu: nrsenatu,
            nrsencar: nrsencar,
            nrsencon: nrsencon,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

// Fun��o para alterar senha do cart�o magn�tico
function alterarSenhaLetrasCartao() {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, alterando as Letras de Seguran&ccedil;a do cart&atilde;o magn&eacute;tico ...");

    var dssennov = $("#dssennov", "#frmSenhaLetrasCartaoMagnetico").val();
    var dssencon = $("#dssencon", "#frmSenhaLetrasCartaoMagnetico").val();

    // Executa script de altera��o de senha atrav�s de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/magneticos/alterar_senha_letras.php",
        data: {
            nrdconta: nrdconta,
            tpusucar: tpusucar,
            nrcartao: nrcartao,
            dssennov: dssennov,
            dssencon: dssencon,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

// Fun��o para sele�o do preposto
function selecionaPreposto(id, qtPreposto, nmprepos, nrcpfpre) {
    var cor = "";

    // Formata cor da linha da tabela que lista prepostos e esconde div com dados do mesmo
    for (var i = 1; i <= qtPreposto; i++) {
        if (cor == "#F4F3F0") {
            cor = "#FFFFFF";
        } else {
            cor = "#F4F3F0";
        }

        // Formata cor da linha
        $("#trPreposto" + i).css("background-color", cor);
    }

    // Atribui cor de destaque para preposto selecionado
    $("#trPreposto" + id).css("background-color", "#FFB9AB");

    // Mostra nome do novo preposto na tela
    $("#nmprepos", "#frmSelecaoPreposto").val((cpfpreat == nrcpfpre ? "" : nmprepos));

    // Armazena CPF do preposto selecionado
    nrcpfppt = nrcpfpre;
}

// Fun��o para confirmar atualiza��o de preposto
function confirmaAtualizacaoPreposto(cddopcao, ope) {

    var operacao = ope;

    if (cpfpreat > 0 && cpfpreat == nrcpfppt) {
        limparPreposto();

        if (operacao == "E") {
            voltarDivPrincipal('185');
            acessaOpcaoSenha(operacao);
        } else {
            if (cddopcao == "I") {
                escondeDivPreposto();
            }
        }
    } else {
        var metodoNo = 'limparPreposto();blockBackground(parseInt($("#divRotina").css("z-index")))';

        if (cpfpreat > 0) {
            if (operacao == "E") {

                metodoNo = 'voltarDivPrincipal("185");acessaOpcaoSenha("' + operacao + '");limparPreposto();';
            } else {
                if (cddopcao == "I") {
                    metodoNo = 'escondeDivPreposto();' + metodoNo;
                }
            }
        }
        showConfirmacao('Confirma atualiza&ccedil;&atilde;o do preposto?', 'Confirma&ccedil;&atilde;o - Ayllos', 'atualizarPreposto("' + cddopcao + '","' + operacao + '")', metodoNo, 'sim.gif', 'nao.gif');
    }
}

// Fun��o para limpar vari�vel utilizada para armazenar CPF do preposto
function limparPreposto() {
    nrcpfppt = 0;
}

// Fun��o para atualizar preposto
function atualizarPreposto(cddopcao, ope) {


    if (ope == "E") {
        voltarDivPrincipal("185");
        acessaOpcaoSenha(ope);
    } else {
        if (cddopcao == "I") {
            // Mostra div para solicita��o de cart�o magn�tico
            escondeDivPreposto();

            blockBackground(parseInt($("#divRotina").css("z-index")));
        }
    }
}

// Fun��o para mostrar o div divPrepostoCartaoMag
function mostraDivPreposto() {
    // Aumenta tamanho do div onde o conte�do da op��o ser� visualizado
    $("#divConteudoOpcao").css({ "height": "240px", "width": "540px" });

    $("#divFormCartaoMag").css("display", "none");
    $("#divPrepostoCartaoMag").css("display", "block");
}

// Fun��o para esconder o div divPrepostoCartaoMag
function escondeDivPreposto() {
    // Aumenta tamanho do div onde o conte�do da op��o ser� visualizado
    $("#divConteudoOpcao").css({ "height": "295px", "width": "490px" });

    $("#divPrepostoCartaoMag").css("display", "none");
    $("#divFormCartaoMag").css("display", "block");
}

// Fun��o para carregar os prepostos para entregar do cart�o magn�tico
function carregaPrepostosEntrega(ope) {

    var operacao = ope;

    // Se n�o tiver nenhum cart�o selecionado
    if (nrcartao == 0) {
        return false;
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, obtendo dados para entrega ...");

    // Carrega conte�do da op��o atrav�s de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/magneticos/entregar_preposto.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrcartao: nrcartao,
            operacao: operacao,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divMagneticosOpcao01").html(response);
        }
    });
}

function validaSenhaCartaoMagnetico() {

    var nrsenatu = $("#nrsenatu", "#frmSenhaCartaoMagnetico").val();
    var nrsencar = $("#nrsencar", "#frmSenhaCartaoMagnetico").val();
    var nrsencon = $("#nrsencon", "#frmSenhaCartaoMagnetico").val();

    // Se n�o tiver nenhum cart�o selecionado
    if (nrcartao == 0) {
        return false;
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, validando senha...");

    // Executa script de confirma��o atrav�s de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/magneticos/validar_senha.php",
        data: {
            nrdconta: nrdconta,
            nrcartao: nrcartao,
            nrsenatu: nrsenatu,
            nrsencar: nrsencar,
            nrsencon: nrsencon,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

// Fun��o para entregar cart�o magn�tico
function entregarCartaoMagnetico() {

    var nrsenatu = $("#nrsenatu", "#frmSenhaCartaoMagnetico").val();
    var nrsencar = $("#nrsencar", "#frmSenhaCartaoMagnetico").val();
    var nrsencon = $("#nrsencon", "#frmSenhaCartaoMagnetico").val();

    // Se n�o tiver nenhum cart�o selecionado
    if (nrcartao == 0) {
        return false;
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, entregando cart&atilde;o magn&eacute;tico ...");

    // Executa script de confirma��o atrav�s de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/magneticos/entregar.php",
        data: {
            nrdconta: nrdconta,
            nrcartao: nrcartao,
            inpessoa: inpessoa,
            nrcpfppt: nrcpfppt,
            nrsenatu: nrsenatu,
            nrsencar: nrsencar,
            nrsencon: nrsencon,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

function verificaImpressao() {
    if (inpessoa == "1") {
        geraDeclaracaoRecebimento();
    } else {
        geraTermoResponsabilidade();
    }
}

// Fun��o para gerar termo de responsabilidade para uso de cart�o magn�tico
function geraTermoResponsabilidade() {

    $("#nrdconta", "#frmImpressaoMagnetico").val(nrdconta);
    $("#nrcartao", "#frmImpressaoMagnetico").val(nrcartao);

    var action = UrlSite + "telas/atenda/magneticos/impressao_termo_responsabilidade.php";
    var callafter = "blockBackground(parseInt($('#divRotina').css('z-index')));";

    if (callafterMagneticos != '') {
        callafter = callafterMagneticos;
        callafterMagneticos = '';
    }

    carregaImpressaoAyllos("frmImpressaoMagnetico", action, callafter);
}

// Fun��o para gerar declara��o de recebimento do cart�o magn�tico
function geraDeclaracaoRecebimento() {
    // Se n�o tiver nenhum cart�o selecionado
    if (nrcartao == 0) {
        return false;
    }

    $("#nrdconta", "#frmImpressaoMagnetico").val(nrdconta);
    $("#nrcartao", "#frmImpressaoMagnetico").val(nrcartao);

    var action = UrlSite + "telas/atenda/magneticos/impressao_declaracao_recebimento.php";
    var callafter = "blockBackground(parseInt($('#divRotina').css('z-index')));";

    if (callafterMagneticos != '') {
        callafter = callafterMagneticos;
        callafterMagneticos = '';
    }

    carregaImpressaoAyllos("frmImpressaoMagnetico", action, "opcaoSolicitarLetras(\'E\')");
}


// Fun��o que formata a tela principal
function formataPrincipal() {

    // Aumenta tamanho do div onde o conte�do da op��o ser� visualizado
    $("#divConteudoOpcao").css("height", "185px");
    $("#divConteudoOpcao").css("width", "490px");

    var divRegistro = $('div.divRegistros');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({ 'height': '105px', 'width': '490px' });

    var ordemInicial = new Array();
    ordemInicial = [[1, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '200px';
    arrayLargura[1] = '120px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'left';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'left';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);
    return false;

}

// Fun��o formata o formulario do cart�o
function formataCartao(cddopcao) {

    var nomeForm = 'frmDadosCartaoMagnetico';

    // label	
    rNmtitcrd = $('label[for="nmtitcrd"]', '#' + nomeForm);
    rNrcartao = $('label[for="nrcartao"]', '#' + nomeForm);
    rNrseqcar = $('label[for="nrseqcar"]', '#' + nomeForm);
    rDtemscar = $('label[for="dtemscar"]', '#' + nomeForm);
    rDscarcta = $('label[for="dscarcta"]', '#' + nomeForm);
    rDtvalcar = $('label[for="dtvalcar"]', '#' + nomeForm);
    rDssitcar = $('label[for="dssitcar"]', '#' + nomeForm);
    rDtentcrm = $('label[for="dtentcrm"]', '#' + nomeForm);
    rDtcancel = $('label[for="dtcancel"]', '#' + nomeForm);
    rDttransa = $('label[for="dttransa"]', '#' + nomeForm);
    rHrtransa = $('label[for="hrtransa"]', '#' + nomeForm);
    rNmoperad = $('label[for="nmoperad"]', '#' + nomeForm);

    rNmtitcrd.addClass('rotulo').css({ 'width': '113px' });
    rNrcartao.addClass('rotulo').css({ 'width': '113px' });
    rNrseqcar.addClass('rotulo-linha').css({ 'width': '118px' });
    rDtemscar.addClass('rotulo-linha').css({ 'width': '364px' });
    rDscarcta.addClass('rotulo').css({ 'width': '113px' });
    rDtvalcar.addClass('rotulo-linha').css({ 'width': '118px' });
    rDssitcar.addClass('rotulo').css({ 'width': '113px' });
    rDtentcrm.addClass('rotulo-linha').css({ 'width': '118px' });
    rDtcancel.addClass('rotulo').css({ 'width': '367px' });
    rDttransa.addClass('rotulo').css({ 'width': '113px' });
    rHrtransa.addClass('rotulo-linha').css({ 'width': '118px' });
    rNmoperad.addClass('rotulo').css({ 'width': '113px' });

    // campos	
    cTpusucar = $('#tpusucar', '#' + nomeForm);
    cNmtitcrd = $('#nmtitcrd', '#' + nomeForm);
    cNrcartao = $('#nrcartao', '#' + nomeForm);
    cNrseqcar = $('#nrseqcar', '#' + nomeForm);
    cDtemscar = $('#dtemscar', '#' + nomeForm);
    cDscarcta = $('#dscarcta', '#' + nomeForm);
    cDtvalcar = $('#dtvalcar', '#' + nomeForm);
    cDssitcar = $('#dssitcar', '#' + nomeForm);
    cDtentcrm = $('#dtentcrm', '#' + nomeForm);
    cDtcancel = $('#dtcancel', '#' + nomeForm);
    cDttransa = $('#dttransa', '#' + nomeForm);
    cHrtransa = $('#hrtransa', '#' + nomeForm);
    cNmoperad = $('#nmoperad', '#' + nomeForm);


    cNrcartao.addClass('campoTelaSemBorda').css({ 'width': '130px' });
    cNrseqcar.addClass('campoTelaSemBorda').css({ 'width': '100px' });
    cDtemscar.addClass('campoTelaSemBorda').css({ 'width': '100px' });
    cDscarcta.addClass('campoTelaSemBorda').css({ 'width': '130px' });
    cDtvalcar.addClass('campoTelaSemBorda').css({ 'width': '100px' });
    cDssitcar.addClass('campoTelaSemBorda').css({ 'width': '130px' });
    cDtentcrm.addClass('campoTelaSemBorda').css({ 'width': '100px' });
    cDtcancel.addClass('campoTelaSemBorda').css({ 'width': '100px' });
    cDttransa.addClass('campoTelaSemBorda').css({ 'width': '130px' });
    cHrtransa.addClass('campoTelaSemBorda').css({ 'width': '100px' });
    cNmoperad.addClass('campoTelaSemBorda').css({ 'width': '354px' });

    $("#" + nomeForm).submit(function () {
        return false;
    });

    // Se tiver uma sele&ccedil;&atilde;o de titular na tela, cria fun&ccedil;&atilde;o para mostrar nome no campo nmtitcrd
    if (cTpusucar.is("select")) {

        cTpusucar.unbind("change");

        cTpusucar.bind("change", function () {
            $("#nmtitcrd", "#frmDadosCartaoMagnetico").val(titular[$("#tpusucar", "#frmDadosCartaoMagnetico").val()]);
            $("#nmtitcrd", "#frmDadosCartaoMagnetico").focus();
        });
    }

    cTpusucar.unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 13) {
            cTpusucar.trigger('change');
            return false;
        }
    });

    cNmtitcrd.unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 13) {
            if (cddopcao == 'I') {
                validarDadosInclusao();
            }
            return false;
        }
    });

    if ($.browser.msie) {
        rDtcancel.css({ 'width': '364px' });
        cNmoperad.css({ 'width': '351px' });
    }

    layoutPadrao();

    cTpusucar.focus();

    return false;
}

// Fun��o formata o formulario de senha
function formataSenha() {

    var nomeForm = 'frmSenhaCartaoMagnetico';

    // label
    rNrsenatu = $('label[for="nrsenatu"]', '#' + nomeForm);
    rNrsencar = $('label[for="nrsencar"]', '#' + nomeForm);
    rNrsencon = $('label[for="nrsencon"]', '#' + nomeForm);

    rNrsenatu.addClass('rotulo').css({ 'width': '230px' });
    rNrsencar.addClass('rotulo').css({ 'width': '230px' });
    rNrsencon.addClass('rotulo').css({ 'width': '230px' });

    // campos
    cNrsenatu = $('#nrsenatu', '#' + nomeForm);
    cNrsencar = $('#nrsencar', '#' + nomeForm);
    cNrsencon = $('#nrsencon', '#' + nomeForm);

    cNrsenatu.addClass('campo').css({ 'width': '100px' }).setMask("INTEGER", "zzzzzz", "", "");
    cNrsencar.addClass('campo').css({ 'width': '100px' }).setMask("INTEGER", "zzzzzz", "", "");
    cNrsencon.addClass('campo').css({ 'width': '100px' }).setMask("INTEGER", "zzzzzz", "", "");

    $("#divMagneticosPrincipal").css("display", "none");
    $("#divMagneticosOpcao01").css("display", "block");

    cNrsenatu.focus();

    layoutPadrao();
    return false;
}

// Fun��o formata o formulario de senha letras
function formataSenhaLetras() {

    var nomeForm = 'frmSenhaLetrasCartaoMagnetico';

    // label
    rDssennov = $('label[for="dssennov"]', '#' + nomeForm);
    rDssencon = $('label[for="dssencon"]', '#' + nomeForm);

    rDssennov.addClass('rotulo').css({ 'width': '220px' });
    rDssencon.addClass('rotulo').css({ 'width': '220px' });

    // campos
    cDssennov = $('#dssennov', '#' + nomeForm);
    cDssencon = $('#dssencon', '#' + nomeForm);

    cDssennov.addClass('campo').css({ 'width': '50px' });
    cDssencon.addClass('campo').css({ 'width': '50px' });

    $("#divMagneticosPrincipal").css("display", "none");
    $("#divMagneticosOpcao01").css("display", "block");

    cDssennov.focus();

    layoutPadrao();
    return false;
}

// Fun��o formata o layout do preposto
function formataPreposto() {

    var divRegistro = $('div.divRegistros', '#divPrepostoCartaoMag');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({ 'height': '105px', 'width': '540px' });

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '60px';
    arrayLargura[1] = '200px';
    arrayLargura[2] = '80px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'right';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'left';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);

    var nomeForm = 'frmSelecaoPreposto';

    // label
    rNmprepo1 = $('label[for="nmprepo1"]', '#' + nomeForm);
    rNmprepos = $('label[for="nmprepos"]', '#' + nomeForm);

    rNmprepo1.addClass('rotulo').css({ 'width': '90px' });
    rNmprepos.addClass('rotulo').css({ 'width': '90px' });

    cNmprepo1 = $('#nmprepo1', '#' + nomeForm);
    cNmprepos = $('#nmprepos', '#' + nomeForm);

    cNmprepo1.addClass('campoTelaSemBorda').css({ 'width': '300px' });
    cNmprepos.addClass('campoTelaSemBorda').css({ 'width': '300px' });

    layoutPadrao();
    return false;

}

function acessaOpcao() {

    $('#divMagneticosOpcao01').css('display', 'none');
    $('#divConteudoLimiteSaqueTAA').css('display', 'none');
    $('#divMagneticosPrincipal').css('display', 'none');
    $('#divConteudoOpcao').css('height', '50px');
    $('#frmSenhaCartaoMagnetico').css('display', 'none');
    $('#divNumericaLetras').css('display', 'block');

    return false;

}

function opcaoLimparLetras() {

    showConfirmacao("Deseja limpar letras?", "Confirma&ccedil;&atilde;o - Ayllos", "limparLetras()", "blockBackground(parseInt($('#divRotina').css('z-index')))", "sim.gif", "nao.gif");

}


function limparLetras() {

    showMsgAguardo("Aguarde, limpando letras ...");

    // Executa solicita��o de letras atrav�s de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/magneticos/limpar_letras.php",
        data: {
            nrdconta: nrdconta,
            nrcartao: nrcartao,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

function abreTelaLimiteSaque() {

    $("#divMagneticosOpcao01").css("display", "none");
    $("#divConteudoLimiteSaqueTAA").css("display", "block");

    var url = UrlSite + "telas/atenda/limite_saque_taa/limite_saque_taa.js";
    $.getScript(url, function () {
        controlaOperacaoLimiteSaqueTAA('CA', 'magnetico');
    }, true);

    return false;
}
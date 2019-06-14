/****************************************************************************
 Fonte: tele_atendimento.js                                       
 Autor: David                                                     
 Data : Fevereiro/2008               Ultima Alteracao: 30/09/2015 
                                                                  
 Objetivo  : Biblioteca de fun&ccedil;&otilde;es da rotina Tele   
	     	  Atendimento da tela ATENDA                          
                                                                   
 Alteracoes: 30/06/2011 - Alterado para layout padrão (Rogerius - DB1)		  	
																				
			 08/11/2013 - Adição das funções "senhaNaoCadastrada",			  		
			 			  "criaSenhaURA" e "mostraCriaSenhaURA". Alteração das		
						  existentes para funcionamento do cadastro de senhas 		
						  (Cristian)									       	
																				
			 18/11/2013 - Remoção da Função criaSenhaUra e adequação           	 
				 		  da função alterarSenhaURA para fazer o cadastro e  	 	
						  alteração das senhas 							  	 	
						  Alteração no nome da função alterarSenhaURA para   	 	
						  criarAlterarSenhaURA 							  	 	
						  (Cristian)										  
																				
			 24/01/2014 - Criada function valida_senha_ura para validacao da  
						  criacao/alteracao da senha de Tele Atendimento.	  	 	
						  (Reinert)                                            	
																			
			 30/09/2015 - Ajuste para inclusão das novas telas "Produtos"
						  (Gabriel - Rkam -> Projeto 217).			 	 	 
			
			 27/07/2016 - Adicionado função controlaFoco.(Evandro - RKAM).
//******************************************************************************/

var existeSenha = 1;
var cddopcao;

// Fun&ccedil;&atilde;o para carregar dados da op&ccedil;&atilde;o principal
function acessaOpcaoPrincipal() {
    // Configura visualiza&ccedil;&atilde;o dos divs
    $("#divDadosSenhaURA").css("display", "none");
    $("#divAlteraSenhaURA").css("display", "none");
    $("#divCadastrarSenhaURA").css("display", "none");
    $("#divCriaSenhaURA").css("display", "none");

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando dados da senha do Tele Atendimento ...");

    // Carrega conte&uacute;do da op&ccedil;&atilde;o atrav&eacute;s de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/tele_atendimento/principal.php",
        data: {
            nrdconta: nrdconta,
            executandoProdutos: executandoProdutos,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
                controlaEventos();
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Aimaro", "$('#nrdconta','#frmCabAtenda').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
            controlaFoco();
        }
    });
}

//Função para controle de navegação
function controlaFoco() {
    $('#divConteudoOpcao form').each(function () {
        $(this).find(":input[type=image]").addClass("FluxoNavega");
        $(this).find(":input[type=image]").first().addClass("FirstInputModal").focus();
        $(this).find(":input[type=image]").first().addClass("LastInputModal").focus();
    });

    //Se estiver com foco na classe FluxoNavega
    $(".FluxoNavega").focus(function () {
        $(this).bind('keydown', function (e) {
            if (e.keyCode == 13) {
                $(this).click();
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
            e.stopPropagation();
            e.preventDefault();

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

function senhaNaoCadastrada() {
    highlightObjFocus($('#frmCriaSenhaURA'));
    $("#divDadosSenhaURA").css("display", "none");
    $("#divAlteraSenhaURA").css("display", "none");
    $("#divCadastrarSenhaURA").css("display", "block");
    $("#divCriaSenhaURA").css("display", "none");
    existeSenha = 0;
    cddopcao = 'I';
    hideMsgAguardo();
    blockBackground(1);
}


// Fun&ccedil;&atilde;o para mostrar campos de altera&ccedil;&atilde;o de senha do Tele Atendimento
function senhaURA() {
    $("#divDadosSenhaURA").css("display", "none");
    $("#divAlteraSenhaURA").css("display", "block");
    $("#divCadastrarSenhaURA").css("display", "none");
    $("#divCriaSenhaURA").css("display", "none");

    highlightObjFocus($('#frmSenhaURA'));
    controlaFocoEnter("frmSenhaURA");
    $("#cddsenh1", "#frmSenhaURA").focus();

    existeSenha = 1;
    cddopcao = 'A';
}

// Fun&ccedil;&atilde;o para mostrar campos de cria&ccedil;&atilde;o de senha do Tele Atendimento
function mostraCriaSenhaURA() {
    $("#divDadosSenhaURA").css("display", "none");
    $("#divAlteraSenhaURA").css("display", "none");
    $("#divCadastrarSenhaURA").css("display", "none");
    $("#divCriaSenhaURA").css("display", "block");
    $("#cddsenh1", "#frmCriaSenhaURA").focus();
    return false;
}

// Retornar a tela principal da rotina
function retornarOpcaoPrincipal() {
    // Limpar campos de senha	
    limpaCamposSenha();

    // Se a tela foi chamada pela rotina "Produtos" então encerra a rotina, do contrário, acessa op&ccedil;&atilde;o principal da rotina
    if (executandoProdutos) {
        encerraRotina();
    }
    else {
        acessaOpcaoPrincipal();
    }
}

function limpaCamposSenha() {
    var frmSenha;
    existeSenha ? frmSenha = "frmSenhaURA" : frmSenha = "frmCriaSenhaURA";
    $('#cddsenh1', '#' + frmSenha).val('');
    $('#cddsenh2', '#' + frmSenha).val('');
}

// Fun&ccedil;&atilde;o para alterar senha do Tele Atendimento
function criarAlterarSenhaURA() {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, alterando senha do Tele Atendimento ...");
    var frmSenha;
    existeSenha ? frmSenha = "frmSenhaURA" : frmSenha = "frmCriaSenhaURA";

    var cddsenh1 = $("#cddsenh1", "#" + frmSenha).val();

    // Carrega conte&uacute;do da op&ccedil;&atilde;o atrav&eacute;s de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/tele_atendimento/criar_alterar_senha_ura.php",
        data: {
            nrdconta: nrdconta,
            cddsenha: cddsenh1,
            exisenha: existeSenha,
            redirect: "script_ajax" // Tipo de retorno do ajax
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
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Aimaro", "$('#nrdconta','#frmCabAtenda').focus()");
            }
        }
    });
}

function verifica_senha_ura() {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, validando senha do Tele Atendimento ...");
    var frmSenha;
    existeSenha ? frmSenha = "frmSenhaURA" : frmSenha = "frmCriaSenhaURA";

    var cddsenh1 = $("#cddsenh1", "#" + frmSenha).val();
    var cddsenh2 = $("#cddsenh2", "#" + frmSenha).val();

    var cCddsenh1 = $("#cddsenh1", "#" + frmSenha);
    var cCddsenh2 = $("#cddsenh2", "#" + frmSenha);

    if (cddsenh1 == "") {
        hideMsgAguardo();
        showError("error", "Senha incorreta.", "Alerta - Aimaro", "cCddsenh1.focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    if (cddsenh2 == "") {
        hideMsgAguardo();
        showError("error", "Senha incorreta.", "Alerta - Aimaro", "cCddsenh2.focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    if (cddsenh1 != cddsenh2) {
        hideMsgAguardo();
        limpaCamposSenha();
        showError("error", "Senha incorreta.", "Alerta - Aimaro", "cCddsenh1.focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    // Carrega conteudo da opcao atraves de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/tele_atendimento/valida_senha_ura.php",
        data: {
            cddsenha: cddsenh1,
            cddsenh2: cddsenh2,
            frmSenha: frmSenha,
            cddopcao: cddopcao,
            redirect: "script_ajax" // Tipo de retorno do ajax
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
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Aimaro", "$('#nrdconta','#frmCabAtenda').focus()");
            }
        }
    });

}

// Função que formata o layout
function controlaLayout() {

    /*----------------------*/
    /*    PRIMEIRA TELA		*/
    /*----------------------*/

    // label
    rNmopeura = $('label[for="nmopeura"]', '#frmURA');
    rDtaltsnh = $('label[for="dtaltsnh"]', '#frmURA');
    rBotao1 = $('label[for="botao1"]', '#frmURA');

    rNmopeura.addClass('rotulo').css({ 'width': '112px' });
    rDtaltsnh.addClass('rotulo').css({ 'width': '112px' });
    rBotao1.addClass('rotulo').css({ 'width': '112px' });

    // campo
    cNmopeura = $('#nmopeura', '#frmURA');
    cDtaltsnh = $('#dtaltsnh', '#frmURA');

    cNmopeura.css({ 'width': '140px' });
    cDtaltsnh.css({ 'width': '140px' });

    $('input, select', '#frmURA').desabilitaCampo();

    /*----------------------*/
    /*    SEGUNDA TELA		*/
    /*----------------------*/

    // mensagem
    $('#msgSenhaURA').css({ 'width': '260px', 'background-color': '#E3E2DD', 'padding': '5px', 'margin': '10px 0 5px 0 ' });

    // label
    rCddsenh1 = $('label[for="cddsenh1"]', '#frmSenhaURA');
    rCddsenh2 = $('label[for="cddsenh2"]', '#frmSenhaURA');
    rBotao2 = $('label[for="botao2"]', '#frmSenhaURA');

    rCddsenh1.addClass('rotulo').css({ 'width': '111px' });
    rCddsenh2.addClass('rotulo').css({ 'width': '111px' });
    rBotao2.addClass('rotulo').css({ 'width': '111px' });

    // campo
    cCddsenh1 = $('#cddsenh1', '#frmSenhaURA');
    cCddsenh2 = $('#cddsenh2', '#frmSenhaURA');

    cCddsenh1.css({ 'width': '140px' });
    cCddsenh2.css({ 'width': '140px' });

    $('input, select', '#frmSenhaURA').habilitaCampo();

    /*----------------------*/
    /*    TERCEIRA TELA		*/
    /*----------------------*/

    // label
    rNmopeura = $('label[for="nmopeura"]', '#frmCadURA');
    rBotao3 = $('label[for="botao3"]', '#frmCadURA');

    rNmopeura.addClass('rotulo').css({ 'width': '80px' });
    rBotao3.addClass('rotulo').css({ 'width': '80px' });

    // campo
    cNmopeura = $('#nmopeura', '#frmCadURA');

    cNmopeura.css({ 'width': '140px' });

    $('input, select', '#frmCadURA').desabilitaCampo();

    /*----------------------*/
    /*    QUARTA TELA		*/
    /*----------------------*/

    // mensagem
    $('#msgSenhaURA', '#frmCriaSenhaURA').css({ 'width': '260px', 'background-color': '#E3E2DD', 'padding': '5px', 'margin': '10px 0 5px 0 ' });

    // label
    rCddsenh1 = $('label[for="cddsenh1"]', '#frmCriaSenhaURA');
    rCddsenh2 = $('label[for="cddsenh2"]', '#frmCriaSenhaURA');
    rBotao2 = $('label[for="botao2"]', '#frmCriaSenhaURA');

    rCddsenh1.addClass('rotulo').css({ 'width': '111px' });
    rCddsenh2.addClass('rotulo').css({ 'width': '111px' });
    rBotao2.addClass('rotulo').css({ 'width': '111px' });

    // campo
    cCddsenh1 = $('#cddsenh1', '#frmCriaSenhaURA');
    cCddsenh2 = $('#cddsenh2', '#frmCriaSenhaURA');

    cCddsenh1.css({ 'width': '140px' });
    cCddsenh2.css({ 'width': '140px' });

    $('input, select', '#frmCriaSenhaURA').habilitaCampo();
}

function controlaEventos() {

    $("#divAlteraSenhaURA").submit(function () {
        return false;
    });

    $("#frmSenhaURA").submit(function () {
        return false;
    });

    $("#divCriaSenhaURA").submit(function () {
        return false;
    });

    $("#frmCriaSenhaURA").submit(function () {
        return false;
    });

    $("#cddsenh1", "#frmSenhaURA").unbind('keydown').bind('keydown', function (e) {
        if (e.keyCode == 13) {
            $("#cddsenh2", "#frmSenhaURA").focus();
            return false;
        }
    });

    $("#cddsenh2", "#frmSenhaURA").unbind('keydown').bind('keydown', function (e) {
        if (e.keyCode == 13) {
            verifica_senha_ura();
            return false;
        }
    });

    $("#cddsenh1", "#frmCriaSenhaURA").unbind('keydown').bind('keydown', function (e) {
        if (e.keyCode == 13) {
            $("#cddsenh2", "#frmCriaSenhaURA").focus();
            return false;
        }
    });

    $("#cddsenh2", "#frmCriaSenhaURA").unbind('keydown').bind('keydown', function (e) {
        if (e.keyCode == 13) {
            verifica_senha_ura();
            return false;
        }
    });

}
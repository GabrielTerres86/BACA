//************************************************************************//
//*** Fonte: poupanca_programada.js                                     ***//
//*** Autor: David                                                      ***//
//*** Data : Mar�o/2010                   Ultima Alteracao: 17/05/2018  ***//
//***                                                                   ***//
//*** Objetivo  : Biblioteca de fun��es da rotina Poupan�a Programada   ***//
//***             da tela ATENDA                                        ***//
//***                                                                   ***//	 
//*** Altera��es:  07/05/2010 - Incluir tratamento para o tipo de       ***//
//***							de impressao do extrato (Gabriel).	    ***//
//***                                                                   ***//
//***              22/10/2010 - N�o permitir impress�o se nenhum pou-   ***//
//***                           pan�a estiver selecionada e altera��o   ***//
//***                           na fun��o acessaOpcaoAba (David).       ***//	
//***                                                                   ***//
//***              13/07/2011 - Alterado para layout padr�o             ***//
//***              (Gabriel Capoia - DB1)				                ***//
//***																    ***//
//***              27/12/2011 - Alterada na fun��o 'acessaOpcaoIncluir' ***//
//***              				para c�lculo da data de inicio e        ***//
//***              				de vencimento m�ximo. (Lucas)           ***//
//***																    ***//
//***			  27/06/2012 - Retirado window.open, novo esquema  para ***//
//***						   impressao em imprimirAutorizacao() (Jorge).*//
//***    																***//
//***			  04/06/2013 - Incluido var complemento no controlaLayout**//
//***						   (Lucas R.)                               ***//  
//***                                                                   ***//
//***             01/12/2017 - N�o permitir acesso a op��o de incluir   ***//
//***                          quando conta demitida                    ***//
//***                         (Jonata - RKAM P364).                     ***//
//***                                                                   ***//
//***            21/02/2018 - Corre��o do login enviado para a tela     ***//
//***                         poupanca_resgate_valida.php               ***//
//***                         (Antonio R Jr)-Chamado 852162             ***//
//***                                                                   ***//
//***            04/04/2018 - Ajuste para chamar a rotina de senha      ***//
//***                         do coordenador. PRJ366 (Lombardi)         ***//
//***                                                                   ***//
//***            17/05/2018 - Validar bloqueio de poupan�a programada   ***//
//***                         (SM404).                                  ***//
//***                                                                   ***//
//*************************************************************************//

var nrctrrpp = 0;        // Vari�vel para armazenar n�mero da poupan�a selecionada
var cdtiparq = 0;        // Vari�vel para armazenar identificador de proposta (0 - Contratado / 1 - Proposta)
var nrdrowid = "";       // Vari�vel para armazenar rowid do registro da poupan�a selecionada
var nrdocmto = 0;        // Vari�vel para armazenar n�mero do resgate selecionado
var flgoprgt = false;    // Vari�vel que indica se foi feita alguma atualiza��o na op��o resgate
var idLinha = -1;       // Vari�vel para armazanar o id da linha que cont�m a poupan�a selecionada
var idLinhaResg = -1;       // Vari�vel para armazanar o id da linha que cont�m o resgate selecionado
var callafterPoupanca = '';

// Fun��o para acessar op��es da rotina
function acessaOpcaoAba(nrOpcoes, id, opcao) {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando poupan&ccedil;as programadas ...");
	
	callafterPoupanca = '';
	
	// Atribui cor de destaque para aba da op��o
    $("#linkAba0").attr("class", "txtBrancoBold");
    $("#imgAbaEsq0").attr("src", UrlImagens + "background/mnu_sle.gif");
    $("#imgAbaDir0").attr("src", UrlImagens + "background/mnu_sld.gif");
    $("#imgAbaCen0").css("background-color", "#969FA9");
	
	// Carrega conte�do da op��o atrav�s de ajax
	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/atenda/poupanca_programada/principal.php",
		data: {
			nrdconta: nrdconta,
			sitaucaoDaContaCrm: sitaucaoDaContaCrm,
			redirect: "html_ajax"
		},
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			$("#divConteudoOpcao").html(response);
            controlaFoco();
		}				
	}); 		
}

//Fun��o para controle de navega��o
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

// Fun��o para sele��o da poupan�a programada
function selecionaPoupanca(id, qtPoupanca, poupanca, tipo, registro) {
	var cor = "";
	
	// Formata cor da linha da tabela que lista poupan�as
	for (var i = 0; i <= qtPoupanca; i++) {		
		if (cor == "#F4F3F0") {
			cor = "#FFFFFF";
		} else {
			cor = "#F4F3F0";
		}		
		
		// Formata cor da linha
        $("#trPoupanca" + i).css("background-color", cor);
		
		if (i == id) {
			// Atribui cor de destaque para poupan�a selecionada
            $("#trPoupanca" + id).css("background-color", "#FFB9AB");
			
			// Armazena n�mero da poupan�a selecionada
            nrctrrpp = retiraCaracteres(poupanca, "0123456789", true);
			cdtiparq = tipo;
			nrdrowid = registro;
            idLinha = id;
		}
	}
}

function voltarDivPrincipal() {
    $("#divResgate").css("display", "none");
    $("#divOpcoes").css("display", "none");
    $("#divPoupancasPrincipal").css("display", "block");
	
	// Aumenta tamanho do div onde o conte�do da op��o ser� visualizado
    $("#divConteudoOpcao").css("height", "225px");
}

// Fun��o para acessar op��o para cancelamento da poupan�a
function acessaOpcaoCancelar() {
	// Se n�o tiver nenhuma poupan�a selecionada
	if (nrctrrpp == 0 || cdtiparq == 1) {
		return false;
	}
	
    showConfirmacao("Deseja cancelar a poupan&ccedil;a programada?", "Confirma&ccedil;&atilde;o - Ayllos", "cancelarPoupanca()", "blockBackground(parseInt($('#divRotina').css('z-index')))", "sim.gif", "nao.gif");
}

// Fun��o para cancelamento da poupan�a
function cancelarPoupanca() {	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, cancelando poupan&ccedil;a programada ...");
	
	// Executa script de consulta atrav�s de ajax
	$.ajax({		
		type: "POST",		
		url: UrlSite + "telas/atenda/poupanca_programada/poupanca_cancelar.php", 
		data: {
			nrdconta: nrdconta,
			nrctrrpp: nrctrrpp,			
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

// Fun��o para acessar op��o para reativa��o da poupan�a
function acessaOpcaoReativar() {
	// Se n�o tiver nenhuma poupan�a selecionada
	if (nrctrrpp == 0 || cdtiparq == 1) {
		return false;
	}
	
    showConfirmacao("Deseja reativar a poupan&ccedil;a programada?", "Confirma&ccedil;&atilde;o - Ayllos", "reativarPoupanca()", "blockBackground(parseInt($('#divRotina').css('z-index')))", "sim.gif", "nao.gif");
}

// Fun��o para reativar a poupan�a
function reativarPoupanca() {
	// Se n�o tiver nenhuma poupan�a selecionada
	if (nrctrrpp == 0 || cdtiparq == 1) {
		return false;
	}
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, reativando poupan&ccedil;a programada ...");
	
	// Executa script de consulta atrav�s de ajax
	$.ajax({		
		type: "POST",		
		url: UrlSite + "telas/atenda/poupanca_programada/poupanca_reativar.php", 
		data: {
			nrdconta: nrdconta,
			nrctrrpp: nrctrrpp,			
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

// Fun��o para consultar a poupan�a
function consultarPoupanca() {
	// Se n�o tiver nenhuma poupan�a selecionada
    if (nrctrrpp == 0 || cdtiparq == 1) {
		return false;
	}
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, consultando poupan&ccedil;a programada ...");	
	
	// Executa script de consulta atrav�s de ajax
	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/atenda/poupanca_programada/poupanca_consultar.php", 
		data: {
			nrdconta: nrdconta,
			nrctrrpp: nrctrrpp,			
			redirect: "html_ajax"
		}, 
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			$("#divOpcoes").html(response);
		}				
	});	
}

// Fun��o para voltar para o div de consulta
function voltaDivConsulta() {
    $("#divExtratoPoupanca").css("display", "none");
    $("#divDadosPoupanca").css("display", "block");
}

// Fun��o para consultar extrato da poupan�a programada
function extratoPoupanca() {	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando extrato ...");
	
	// Executa script de consulta atrav�s de ajax
	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/atenda/poupanca_programada/poupanca_extrato.php", 
		data: {
			nrdconta: nrdconta,
			nrctrrpp: nrctrrpp,
            dtiniper: $("#dtiniper", "#frmExtrato").val(),
            dtfimper: $("#dtfimper", "#frmExtrato").val(),
			redirect: "html_ajax"
		}, 
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			$("#divExtratoPoupanca").html(response);
		}				
	});				
}

// Fun��o para acessar op��o para suspender a poupan�a
function acessaOpcaoSuspender() {
	// Se n�o tiver nenhuma poupan�a selecionada
	if (nrctrrpp == 0 || cdtiparq == 1) {
		return false;
	}
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando dados da poupan&ccedil;a programada ...");	
	
	// Executa script de consulta atrav�s de ajax
	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/atenda/poupanca_programada/poupanca_suspender_carregar.php", 
		data: {
			nrdconta: nrdconta,
			nrctrrpp: nrctrrpp,			
			redirect: "html_ajax"
		}, 
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			$("#divOpcoes").html(response);
		}				
	});	
}

// Fun��o para validar suspens�o da poupan�a programada
function validarSuspensaoPoupanca() {		
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, validando suspens&atilde;o ...");
	
    var nrmesusp = $("#nrmesusp", "#frmDadosPoupanca").val();
	
	// Valida quantidade de meses
    if (nrmesusp == "" || !validaNumero(nrmesusp, true, 0, 0)) {
		hideMsgAguardo();
        showError("error", "Quantidade de meses inv&aacute;lida.", "Alerta - Ayllos", "$('#nrmesusp','#frmDadosPoupanca').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}			
	
	// Executa script de consulta atrav�s de ajax
	$.ajax({		
		type: "POST",		
		url: UrlSite + "telas/atenda/poupanca_programada/poupanca_suspender_validar.php", 
		data: {
			nrdconta: nrdconta,
			nrctrrpp: nrctrrpp, 
			nrmesusp: nrmesusp,			
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

// Fun��o para suspender a poupan�a programada
function suspenderPoupanca(nrmesusp) {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, suspendendo poupan&ccedil;a programada ...");	
		
	// Executa script de consulta atrav�s de ajax
	$.ajax({		
		type: "POST",		
		url: UrlSite + "telas/atenda/poupanca_programada/poupanca_suspender.php", 
		data: {
			nrdconta: nrdconta,
			nrctrrpp: nrctrrpp,		
			nrmesusp: nrmesusp,
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

function voltarDivResgate() {	
    $("#divOpcoes").css("display", "none");
    $("#divResgate").css("display", "block");
	
	// Zerar vari�veis globais utilizadas na op��o de resgate	
	nrdocmto = 0;
}

//Fun��o para validar o bloqueio da aplica��o
function validaBloqueioAplicacao(){
	// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, validando bloqueio aplica&ccedil;&atilde;o ...");

    // Executa script de consulta atrav�s de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/poupanca_programada/valida_bloqueio_poup.php",
        data: {
            nrdconta: nrdconta,
			nrctrrpp: nrctrrpp,
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

function acessaOpcaoResgate() {
	// Se n�o tiver nenhuma poupan�a selecionada
	if (nrctrrpp == 0 || cdtiparq == 1) {
		return false;
	}
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando op&ccedil;&atilde;o para resgate ...");
	
	// Executa script de consulta atrav�s de ajax
	$.ajax({		
		type: "POST",		
		url: UrlSite + "telas/atenda/poupanca_programada/poupanca_resgate.php", 
		data: {
			nrdconta: nrdconta,
			nrctrrpp: nrctrrpp,
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

// Fun��o para acessar op��o para efetuar o resgate
function acessaOpcaoEfetuarResgate() {		
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando op&ccedil;&atilde;o para resgate ...");
	
	var strHTML = "";
	strHTML = '<form action="" method="post" name="frmResgate" id="frmResgate" onSubmit="return false;">';
	strHTML += '	<fieldset>';
	strHTML += '		<legend>Resgate da Poupan&ccedil;a Programada</legend>';
	
	strHTML += '		<label for="tpresgat">Tipo de Resgate:</label>';
	strHTML += '		<select name="tpresgat" id="tpresgat" class="campo">';
	strHTML += '			<option value="P" selected>PARCIAL</option>';
	strHTML += '			<option value="T">TOTAL</option>';
	strHTML += '		</select>';
	strHTML += '		<br />';
	
	strHTML += '		<label for="vlresgat">Valor do Resgate:</label>';
	strHTML += '		<input name="vlresgat" type="text" class="campo" id="vlresgat" autocomplete="no" value="0,00" />';
	strHTML += '		<br />';
	
	strHTML += '		<label for="dtresgat">Data do Resgate:</label>';
	strHTML += '		<input name="dtresgat" type="text" class="campo" id="dtresgat" autocomplete="no" value="" />';
	strHTML += '		<br />';
	
	
	strHTML += '		<label for="flgctain">Resgatar Saldo para a CI?:</label>';
	strHTML += '		<select name="flgctain" id="flgctain" class="campo">';
	strHTML += '			<option value="no">N&Atilde;O</option>';
	strHTML += '			<option value="yes">SIM</option>';
	strHTML += '		</select>';
	strHTML += '		<br /><br />';
	strHTML += '		<label for="flautori">Autorizar opera&ccedil;&atilde;o:</label>';
	strHTML += '		<input type="checkbox" id="flautori" name="flautori" value="Bike">';
	strHTML += '	</fieldset>';								
	
	strHTML += '	<div id="dvautoriza" name="dvautoriza">';
	strHTML += '	<fieldset>';
	strHTML += '	<legend>Autorizar Resgate da Aplica&ccedil;&atilde;o</legend>';
	strHTML += '		<br />';
	strHTML += '		<label for="cdopera2">Operador:</label>';
	strHTML += '		<input name="cdopera2" type="text" class="campo" id="cdopera2" autocomplete="no">';
	strHTML += '		<br />';
	strHTML += '		<label for="cddsenha">Senha:</label>';
	strHTML += '		<input name="cddsenha" type="password" id="cddsenha" class="campo" autocomplete="no">';	
	strHTML += '	</fieldset>';
	strHTML += '	</div>';			
	strHTML += '</form>';
	
	strHTML += '<div id="divBotoes">';
	strHTML += '	<input type="image" src="' + UrlImagens + 'botoes/cancelar.gif" onClick="voltarDivResgate();return false;" />';
	//strHTML += '	<input type="image" src="' + UrlImagens + 'botoes/concluir.gif" onClick="validarResgate();return false;" />';
	strHTML += '	<input type="image" src="' + UrlImagens + 'botoes/concluir.gif" onClick="validaBloqueioAplicacao();return false;" />';
	strHTML += '</div>';
	
	$("#divOpcoes").html(strHTML);
	
	controlaLayout('frmResgate');
	
    $("#vlresgat", "#frmResgate").setMask("DECIMAL", "zzz.zzz.zz9,99", "", "");
    $("#dtresgat", "#frmResgate").setMask("DATE", "", "", "divRotina");
	
    $("#tpresgat", "#frmResgate").unbind("change");
    $("#tpresgat", "#frmResgate").bind("change", function () {
		if ($(this).val() == "T") {
            $("#vlresgat", "#frmResgate").val("0,00");
            $("#vlresgat", "#frmResgate").prop("disabled", true);
            $("#vlresgat", "#frmResgate").attr("class", "campoTelaSemBorda");
		} else {
            $("#vlresgat", "#frmResgate").removeProp("disabled");
            $("#vlresgat", "#frmResgate").attr("class", "campo");
		}
	});
	
    $("#divResgate").css("display", "none");
    $("#divOpcoes").css("display", "block");
	
	// Esconde mensagem de aguardo
	hideMsgAguardo();
	blockBackground(parseInt($("#divRotina").css("z-index")));
}

// Fun��o para validar resgate da poupan�a programada
function validarResgate() {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, validando resgate ...");
	
    var tpresgat = $("#tpresgat", "#frmResgate").val();
    var vlresgat = $("#vlresgat", "#frmResgate").val().replace(/\./g, "");
    var dtresgat = $("#dtresgat", "#frmResgate").val();
    var flgctain = $("#flgctain", "#frmResgate").val();
    var cdopera2 = $("#cdopera2", "#frmResgate").val();
    var cddsenha = $("#cddsenha", "#frmResgate").val();
    var fvisivel = $("#dvautoriza").is(':visible') ? 1 : 0;	
	
	if (tpresgat == "P") {
		// Valida valor do resgate
        if (vlresgat == "" || !validaNumero(vlresgat, true, 0, 0)) {
			hideMsgAguardo();
            showError("error", "Valor do resgate inv&aacute;lido.", "Alerta - Ayllos", "$('#vlresgat','#frmResgate').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
			return false;
		}			
	}
	
	// Valida data de resgate
	if (dtresgat == "" || !validaData(dtresgat)) {
		hideMsgAguardo();
        showError("error", "Data de resgate inv&aacute;lida.", "Alerta - Ayllos", "$('#dtresgat','#frmResgate').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}
	
	// Executa script de consulta atrav�s de ajax
	$.ajax({		
		type: "POST",		
		url: UrlSite + "telas/atenda/poupanca_programada/poupanca_resgate_validar.php", 
		data: {
			nrdconta: nrdconta,
			nrctrrpp: nrctrrpp, 
			tpresgat: tpresgat,
			vlresgat: vlresgat,
			dtresgat: dtresgat,
			flgctain: flgctain,
			cdopera2: cdopera2,
			cddsenha: cddsenha,
			fvisivel: fvisivel,
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

// Fun��o para efetuar resgate da poupan�a programada
function efetuarResgate(cdoperad, tpresgat, vlresgat, dtresgat, flgctain) {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, efetuando resgate ...");
	
	// Executa script de consulta atrav�s de ajax
	$.ajax({		
		type: "POST",		
		url: UrlSite + "telas/atenda/poupanca_programada/poupanca_resgate_efetuar.php", 
		data: {
			cdoperad: cdoperad,
			nrdconta: nrdconta,
			nrctrrpp: nrctrrpp,
			tpresgat: tpresgat,
			vlresgat: vlresgat,
			dtresgat: dtresgat,
			flgctain: flgctain,
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

// Fun��o para consultar resgates da poupan�a programada
function obtemResgates(flgcance) {	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando resgates ...");
	
	// Executa script de consulta atrav�s de ajax
	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/atenda/poupanca_programada/poupanca_resgate_carregar.php", 
		data: {
			nrdconta: nrdconta,
			nrctrrpp: nrctrrpp,
			flgcance: flgcance,
			redirect: "html_ajax"
		}, 
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			$("#divOpcoes").html(response);
		}				
	});				
}

// Fun��o para sele��o do resgate
function selecionaResgate(id, qtResgate, documento) {
	var cor = "";
	
	// Formata cor da linha da tabela que lista resgates
	for (var i = 0; i <= qtResgate; i++) {		
		if (cor == "#F4F3F0") {
			cor = "#FFFFFF";
		} else {
			cor = "#F4F3F0";
		}		
		
		// Formata cor da linha
        $("#trResgate" + i).css("background-color", cor);
		
		if (i == id) {
			// Atribui cor de destaque para resgate selecionado
            $("#trResgate" + id).css("background-color", "#FFB9AB");
	
			// Armazena n�mero e data do resgate selecionado			
            nrdocmto = retiraCaracteres(documento, "0123456789", true);
			idLinhaResg = id;		
		}
	}
}

// Fun��o para cancelamento de resgate
function cancelarResgates() {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, cancelando resgate ...");
	
	// Executa script de consulta atrav�s de ajax
	$.ajax({		
		type: "POST",		
		url: UrlSite + "telas/atenda/poupanca_programada/poupanca_resgate_cancelar.php", 
		data: {
			nrdconta: nrdconta,
			nrctrrpp: nrctrrpp,
			nrdocmto: nrdocmto,			
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

// Fun��o para acessar op��o para alterar a poupan�a
function acessaOpcaoAlterar() {
	// Se n�o tiver nenhuma poupan�a selecionada
	if (nrctrrpp == 0 || cdtiparq == 1) {
		return false;
	}
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando dados da poupan&ccedil;a programada ...");	
	
	// Executa script de consulta atrav�s de ajax
	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/atenda/poupanca_programada/poupanca_alterar_carregar.php", 
		data: {
			nrdconta: nrdconta,
			nrctrrpp: nrctrrpp,			
			redirect: "html_ajax"
		}, 
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			$("#divOpcoes").html(response);
		}				
	});
}

// Fun��o para validar altera��o da poupan�a programada
function validarAlteracaoPoupanca() {	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, validando altera&ccedil&atilde;o ...");
	
    var vlprerpp = $("#vlprerpp", "#frmDadosPoupanca").val().replace(/\./g, "");
	
	// Valida valor da presta��o
    if (vlprerpp == "" || !validaNumero(vlprerpp, true, 0, 0)) {
		hideMsgAguardo();
        showError("error", "Valor de presta&ccedil;&atilde;o inv&aacute;lido.", "Alerta - Ayllos", "$('#vlprerpp','#frmDadosPoupanca').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}			
	
	// Executa script de consulta atrav�s de ajax
	$.ajax({		
		type: "POST",		
		url: UrlSite + "telas/atenda/poupanca_programada/poupanca_alterar_validar.php", 
		data: {
			nrdconta: nrdconta,
			nrctrrpp: nrctrrpp, 
			vlprerpp: vlprerpp,			
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

// Fun��o para alterar a poupan�a programada
function alterarPoupanca(vlprerpp) {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, alterando poupan&ccedil;a programada ...");	
		
	// Executa script de consulta atrav�s de ajax
	$.ajax({		
		type: "POST",		
		url: UrlSite + "telas/atenda/poupanca_programada/poupanca_alterar.php", 
		data: {
			nrdconta: nrdconta,
			nrctrrpp: nrctrrpp,		
			vlprerpp: vlprerpp,
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

// Fun��o para acessar op��o para incluir poupan�a
function acessaOpcaoIncluir() {	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando dados para inclus&atilde;o ...");
    dtinirpp = $('#dtinirpp', '#frmDadosPoupanca').val();
	// Executa script de consulta atrav�s de ajax
	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/atenda/poupanca_programada/poupanca_incluir_carregar.php", 
		data: {
			nrdconta: nrdconta,
			dtinirpp: dtinirpp,
			redirect: "html_ajax"
		},
        error: function (objAjax, responseError, objExcept) {
		
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			$("#divOpcoes").html(response);
			
		}				
	});
}

// Fun��o para validar inclus�o de poupan�a programada
function validarInclusaoPoupanca() {	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, validando inclus&atilde;o ...");
	
    var dtinirpp = $("#dtinirpp", "#frmDadosPoupanca").val();
    var diadtvct = $("#diadtvct", "#frmDadosPoupanca").val();
    var mesdtvct = $("#mesdtvct", "#frmDadosPoupanca").val();
    var anodtvct = $("#anodtvct", "#frmDadosPoupanca").val();
    var vlprerpp = $("#vlprerpp", "#frmDadosPoupanca").val().replace(/\./g, "");
    var tpemiext = $("#tpemiext", "#frmDadosPoupanca").val();

	//Limpa o campo de Erro anterior
    $('input, select', '#frmDadosPoupanca').removeClass('campoErro');
		
	// Valida data de in�cio	
	if (dtinirpp == "" || !validaData(dtinirpp)) {
		hideMsgAguardo();
        showError("error", "Data de in&iacute;cio inv&aacute;lida.", "Alerta - Ayllos", "focaCampoErro(\'dtinirpp\',\'frmDadosPoupanca\');blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}
	
	// Valida m�s para o vencimento
    if (mesdtvct == "" || !validaNumero(mesdtvct, true, 0, 0)) {
		hideMsgAguardo();
        showError("error", "Dia para vencimento inv&aacute;lido.", "Alerta - Ayllos", "focaCampoErro(\'mesdtvct\',\'frmDadosPoupanca\');blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}
	
	// Valida ano para o vencimento
    if (anodtvct == "" || !validaNumero(anodtvct, true, 0, 0)) {
		hideMsgAguardo();
        showError("error", "Dia para vencimento inv&aacute;lido.", "Alerta - Ayllos", "focaCampoErro(\'anodtvct\',\'frmDadosPoupanca\');blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}
	
	// Valida data de vencimento	
	if (!validaData(diadtvct + "/" + mesdtvct + "/" + anodtvct)) {
		hideMsgAguardo();
        showError("error", "Data de vencimento inv&aacute;lida.", "Alerta - Ayllos", "focaCampoErro(\'mesdtvct\',\'frmDadosPoupanca\');blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}
	
	// Valida quantidade de meses
    if (vlprerpp == "" || !validaNumero(vlprerpp, true, 0, 0)) {
		hideMsgAguardo();
        showError("error", "Valor de presta&ccedil;&atilde;o inv&aacute;lido.", "Alerta - Ayllos", "focaCampoErro(\'vlprerpp\',\'frmDadosPoupanca\');blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}	

	
    // Validar tipo de impressado do extrato 
    if (tpemiext == "" || !validaNumero(tpemiext, true, 0, 0)) {
		hideMsgAguardo();
        showError("error", "Tipo de impressao do extrato inv&aacute;lido.", "Alerta - Ayllos", "focaCampoErro(\'tpemiext\',\'frmDadosPoupanca\');blockBackground(parseInt($('#divRotina').css('z-index')))");
	    return false;
	}
	
	// Executa script de consulta atrav�s de ajax
	$.ajax({		
		type: "POST",		
		url: UrlSite + "telas/atenda/poupanca_programada/poupanca_incluir_validar.php", 
		data: {
			nrdconta: nrdconta,
			dtinirpp: dtinirpp, 
			diadtvct: diadtvct,
			mesdtvct: mesdtvct,
			anodtvct: anodtvct,
			vlprerpp: vlprerpp,	
			tpemiext: tpemiext, 				
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

// Fun��o para incluir a poupan�a programada
function incluirPoupanca(dtinirpp, diadtvct, mesdtvct, anodtvct, vlprerpp, tpemiext) {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, incluindo poupan&ccedil;a programada ...");	
		
	// Executa script de consulta atrav�s de ajax
	$.ajax({		
		type: "POST",		
		url: UrlSite + "telas/atenda/poupanca_programada/poupanca_incluir.php", 
		data: {
			nrdconta: nrdconta,
			dtinirpp: dtinirpp, 
			diadtvct: diadtvct,
			mesdtvct: mesdtvct,
			anodtvct: anodtvct,
			vlprerpp: vlprerpp,
			tpemiext: tpemiext,
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

// Fun��o para impress�o da autoriza��o da poupan�a programada
function imprimirAutorizacao(registro, tparquiv) {
	registro = registro == "" ? nrdrowid : registro;
	tparquiv = tparquiv == "" ? cdtiparq : tparquiv;
	
	if (registro == 0 || registro == "") {
		return false;
	}
	
    $("#nrdconta", "#frmAutorizacao").val(nrdconta);
    $("#nrdrowid", "#frmAutorizacao").val(registro);
    $("#cdtiparq", "#frmAutorizacao").val(tparquiv);
	
	var action = $("#frmAutorizacao").attr("action");
	var callafter = "blockBackground(parseInt($('#divRotina').css('z-index')));";
	
	if (callafterPoupanca != '') {
		callafter = callafterPoupanca;
		callafterPoupanca = '';
	}
	
    carregaImpressaoAyllos("frmAutorizacao", action, callafter);
	
}

function controlaLayout(nomeForm) {

    $('#' + nomeForm).addClass('formulario');
	
    if (nomeForm == 'frmExtrato') {
	
        var Ldtiniper = $('label[for="dtiniper"]', '#' + nomeForm);
        var Ldtfimper = $('label[for="dtfimper"]', '#' + nomeForm);
		
        var Cdtiniper = $('#dtiniper', '#' + nomeForm);
        var Cdtfimper = $('#dtfimper', '#' + nomeForm);
		
        $('#' + nomeForm).css('width', '545px');
		
        Ldtiniper.addClass('rotulo').css('width', '80px');
		Ldtfimper.addClass('rotulo-linha');
		
        Cdtiniper.css({ 'width': '65px' });
        Cdtfimper.css({ 'width': '65px' });
		
		Cdtiniper.habilitaCampo();
		Cdtfimper.habilitaCampo();
		
        var divRegistro = $('div.divRegistros', '#divExtrato');
        var tabela = $('table', divRegistro);
						
        divRegistro.css('height', '160px');
		
		var ordemInicial = new Array();
				
		var arrayLargura = new Array();
		arrayLargura[0] = '60px';
		arrayLargura[1] = '130px';
		arrayLargura[2] = '70px';
		arrayLargura[3] = '30px';
		arrayLargura[4] = '80px';
				
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'left';
		arrayAlinha[1] = 'left';
		arrayAlinha[2] = 'right';
		arrayAlinha[3] = 'center';
		arrayAlinha[4] = 'right';
		arrayAlinha[5] = 'right';
						
        tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');
		
	
    } else if (nomeForm == 'frmDadosPoupanca') {
	
        var Lvlprerpp = $('label[for="vlprerpp"]', '#' + nomeForm);
        var Lqtprepag = $('label[for="qtprepag"]', '#' + nomeForm);
        var Lvlprepag = $('label[for="vlprepag"]', '#' + nomeForm);
        var Lvljuracu = $('label[for="vljuracu"]', '#' + nomeForm);
        var Lvlrgtacu = $('label[for="vlrgtacu"]', '#' + nomeForm);
        var Lvlsdrdpp = $('label[for="vlsdrdpp"]', '#' + nomeForm);
        var Ldtinirpp = $('label[for="dtinirpp"]', '#' + nomeForm);
        var Ldtrnirpp = $('label[for="dtrnirpp"]', '#' + nomeForm);
        var Ldtcancel = $('label[for="dtcancel"]', '#' + nomeForm);
        var Ldtaltrpp = $('label[for="dtaltrpp"]', '#' + nomeForm);
        var Ldtdebito = $('label[for="dtdebito"]', '#' + nomeForm);
        var Ldtvctopp = $('label[for="dtvctopp"]', '#' + nomeForm);
        var Lnrmesusp = $('label[for="nrmesusp"]', '#' + nomeForm);
        var Ldsmsgsaq = $('label[for="dsmsgsaq"]', '#' + nomeForm);
        var Ldspesqui = $('label[for="dspesqui"]', '#' + nomeForm);
        var Ldssitrpp = $('label[for="dssitrpp"]', '#' + nomeForm);
		
        var Cvlprerpp = $('#vlprerpp', '#' + nomeForm);
        var Cqtprepag = $('#qtprepag', '#' + nomeForm);
        var Cvlprepag = $('#vlprepag', '#' + nomeForm);
        var Cvljuracu = $('#vljuracu', '#' + nomeForm);
        var Cvlrgtacu = $('#vlrgtacu', '#' + nomeForm);
        var Cvlsdrdpp = $('#vlsdrdpp', '#' + nomeForm);
        var Cdtinirpp = $('#dtinirpp', '#' + nomeForm);
        var Cdtrnirpp = $('#dtrnirpp', '#' + nomeForm);
        var Cdtcancel = $('#dtcancel', '#' + nomeForm);
        var Cdtaltrpp = $('#dtaltrpp', '#' + nomeForm);
        var Cdtdebito = $('#dtdebito', '#' + nomeForm);
        var Cdtvctopp = $('#dtvctopp', '#' + nomeForm);
        var Cnrmesusp = $('#nrmesusp', '#' + nomeForm);
        var Cdsmsgsaq = $('#dsmsgsaq', '#' + nomeForm);
        var Cdspesqui = $('#dspesqui', '#' + nomeForm);
        var Cdssitrpp = $('#dssitrpp', '#' + nomeForm);
		
        $('#' + nomeForm).css('width', '510px');
		
        Lvlprerpp.addClass('rotulo').css('width', '130px');
        Lqtprepag.css('width', '135px');
        Lvlprepag.addClass('rotulo').css('width', '130px');
        Lvljuracu.css('width', '135px');
        Lvlrgtacu.addClass('rotulo').css('width', '130px');
        Lvlsdrdpp.css('width', '135px');
        Ldtinirpp.addClass('rotulo').css('width', '130px');
        Ldtrnirpp.css('width', '135px');
        Ldtcancel.addClass('rotulo').css('width', '130px');
        Ldtaltrpp.css('width', '135px');
        Ldtdebito.addClass('rotulo').css('width', '130px');
        Ldtvctopp.css('width', '135px');
        Lnrmesusp.addClass('rotulo').css('width', '368px');
        Ldsmsgsaq.addClass('rotulo').css('width', '130px');
        Ldspesqui.addClass('rotulo').css('width', '130px');
        Ldssitrpp.css('width', '75px');
		
        Cvlprerpp.css({ 'width': '100px', 'text-align': 'right' });
        Cqtprepag.css({ 'width': '100px' });
        Cvlprepag.css({ 'width': '100px' });
        Cvljuracu.css({ 'width': '100px' });
        Cvlrgtacu.css({ 'width': '100px' });
        Cvlsdrdpp.css({ 'width': '100px' });
        Cdtinirpp.css({ 'width': '100px' });
        Cdtrnirpp.css({ 'width': '100px' });
        Cdtcancel.css({ 'width': '100px' });
        Cdtaltrpp.css({ 'width': '100px' });
        Cdtdebito.css({ 'width': '100px' });
        Cdtvctopp.css({ 'width': '100px' });
        Cnrmesusp.css({ 'width': '25px', 'text-align': 'right' });
        Cdsmsgsaq.css({ 'width': '338px' });
        Cdspesqui.css({ 'width': '160px' });
        Cdssitrpp.css({ 'width': '100px' });
	
    } else if (nomeForm == 'frmIncluirPoupanca') {
		
		nomeForm = 'frmDadosPoupanca';
		
        $('#' + nomeForm).addClass('formulario');
		
        var Ldtinirpp = $('label[for="dtinirpp"]', '#' + nomeForm);
        var Ldiadtvct = $('label[for="diadtvct"]', '#' + nomeForm);
        var Lmesdtvct = $('label[for="mesdtvct"]', '#' + nomeForm);
        var Lanodtvct = $('label[for="anodtvct"]', '#' + nomeForm);
        var Lvlprerpp = $('label[for="vlprerpp"]', '#' + nomeForm);
        var Ltpemiext = $('label[for="tpemiext"]', '#' + nomeForm);
		
        var Cdtinirpp = $('#dtinirpp', '#' + nomeForm);
        var Cdiadtvct = $('#diadtvct', '#' + nomeForm);
        var Cmesdtvct = $('#mesdtvct', '#' + nomeForm);
        var Canodtvct = $('#anodtvct', '#' + nomeForm);
        var Cvlprerpp = $('#vlprerpp', '#' + nomeForm);
        var Ctpemiext = $('#tpemiext', '#' + nomeForm);
		
        Ldtinirpp.addClass('rotulo').css('width', '270px');
        Ldiadtvct.addClass('rotulo').css('width', '270px');
        Lmesdtvct.css('width', '11px');
        Lanodtvct.css('width', '11px');
        Lvlprerpp.addClass('rotulo').css('width', '270px');
        Ltpemiext.addClass('rotulo').css('width', '270px');
		
        Cdtinirpp.css({ 'width': '115px' });
        Cdiadtvct.css({ 'width': '25px' });
        Cmesdtvct.css({ 'width': '25px' });
        Canodtvct.css({ 'width': '37px' });
        Cvlprerpp.css({ 'width': '115px', 'text-align': 'right' });
        Ctpemiext.css({ 'width': '115px' });
	
    } else if (nomeForm == 'divResultadoResgates') {
		
        var divRegistro = $('div.divRegistros', '#' + nomeForm);
        var tabela = $('table', divRegistro);
						
        divRegistro.css('height', '145px');
		
        $('#' + nomeForm).css('width', '555px');
		
		var ordemInicial = new Array();
				
		var arrayLargura = new Array();
		arrayLargura[0] = '55px';
		arrayLargura[1] = '75px';
		arrayLargura[2] = '75px';
		arrayLargura[3] = '60px';
		arrayLargura[4] = '105px';
		arrayLargura[5] = '35px';
				
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'left';
		arrayAlinha[1] = 'right';
		arrayAlinha[2] = 'left';
		arrayAlinha[3] = 'center';
		arrayAlinha[4] = 'left';
		arrayAlinha[5] = 'center';
		arrayAlinha[6] = 'right';
						
        tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');
		
        $('tbody > tr', tabela).each(function () {
            if ($(this).hasClass('corSelecao')) {
				$(this).focus();		
			}
		});
	
    } else if (nomeForm == 'divPoupancasPrincipal') {
	
        var divRegistro = $('div.divRegistros', '#' + nomeForm);
        var tabela = $('table', divRegistro);
						
        divRegistro.css('height', '145px');
		
        $('#' + nomeForm).css('width', '605px');
		
		var ordemInicial = new Array();
				
		var arrayLargura = new Array();
		arrayLargura[0] = '58px';
		arrayLargura[1] = '58px';
		arrayLargura[2] = '60px';
		arrayLargura[3] = '30px';
		arrayLargura[4] = '65px';
		arrayLargura[5] = '65px';
		arrayLargura[6] = '55px';
		arrayLargura[7] = '25px';
		arrayLargura[8] = '25px';
				
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'left';
		arrayAlinha[1] = 'left';
		arrayAlinha[2] = 'right';
		arrayAlinha[3] = 'center';
		arrayAlinha[4] = 'right';
		arrayAlinha[5] = 'right';
		arrayAlinha[6] = 'left';
		arrayAlinha[7] = 'center';
		arrayAlinha[8] = 'center';
		arrayAlinha[9] = 'center';
						
        tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');
		
        $('tbody > tr', tabela).each(function () {
            if ($(this).hasClass('corSelecao')) {
				$(this).focus();		
			}
		});
	
		// complemento
        var complemento = $('ul.complemento', '#divPoupancasPrincipal');
	
		ajustarCentralizacao();
		
    } else if (nomeForm == 'frmResgate') {
	
        var Ltpresgat = $('label[for="tpresgat"]', '#' + nomeForm);
        var Lvlresgat = $('label[for="vlresgat"]', '#' + nomeForm);
        var Ldtresgat = $('label[for="dtresgat"]', '#' + nomeForm);
        var Lflgctain = $('label[for="flgctain"]', '#' + nomeForm);
        var Lflautori = $('label[for="flautori"]', '#' + nomeForm);
        var Lcdopera2 = $('label[for="cdopera2"]', '#' + nomeForm);
        var Lcddsenha = $('label[for="cddsenha"]', '#' + nomeForm);
		
        var Ctpresgat = $('#tpresgat', '#' + nomeForm);
        var Cvlresgat = $('#vlresgat', '#' + nomeForm);
        var Cdtresgat = $('#dtresgat', '#' + nomeForm);
        var Cflgctain = $('#flgctain', '#' + nomeForm);
        var Cflautori = $('#flautori', '#' + nomeForm);
        var Ccdopera2 = $("#cdopera2", '#' + nomeForm);
        var Ccddsenha = $("#cddsenha", '#' + nomeForm);

        Ltpresgat.addClass('rotulo').css('width', '210px');
        Lvlresgat.addClass('rotulo').css('width', '210px');
        Ldtresgat.addClass('rotulo').css('width', '210px');
        Lflgctain.addClass('rotulo').css('width', '210px');
        Lflautori.addClass('rotulo').css('width', '210px');
        Lcdopera2.addClass('rotulo').css('width', '210px');
        Lcddsenha.addClass('rotulo').css('width', '210px');
		
        Ctpresgat.css({ 'width': '90px' });
        Cvlresgat.css({ 'width': '90px', 'text-align': 'right' });
        Cdtresgat.css({ 'width': '90px' });
        Cflgctain.css({ 'width': '90px' });
        Ccdopera2.css({ 'width': '90px' });
        Ccddsenha.css({ 'width': '90px' });
		
		divAutoriza = $('#dvautoriza');
		divAutoriza.hide();
		
        $("#divConteudoOpcao").css("height", "200px");
		
        Cflautori.click(function () {
			divAutoriza.toggle();
			
            $("#cdopera2", '#dvautoriza').val('');
            $("#cddsenha", '#dvautoriza').val('');
			
			
            if ($("#dvautoriza").is(':visible')) {
                $("#divConteudoOpcao").css("height", "300px");
            } else {
                $("#divConteudoOpcao").css("height", "200px");
			}
		});
		
	}

	return false;
}

function senhaCoordenador(executaDepois) {
	pedeSenhaCoordenador(2,executaDepois,'divRotina');
}
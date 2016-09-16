/***********************************************************************
      Fonte: cobranca.js
      Autor: Gabriel
      Data : Dezembro/2010             Ultima atualizacao : 24/11/2015

      Objetivo  : Biblioteca de funcoes da rotina CONBRANCA tela ATENDA.

      Alteracoes: 19/05/2011 - Incluir Cob. Regis (Guilherme).
	  
				  14/07/2011 - Alterado para layout padrão 
							   (Gabriel Capoia - DB1)
							   
				  26/07/2011 - Incluir opcao de impressao (Gabriel)		

				  08/09/2011 - Ajuste para chamada da Lista Negra 
							   (Adriano).
							   
				  26/06/2012 - Ajustado para submeter impressao  em funcao  imprimirTermoAdesao()
							   (Jorge)
							   
				  10/05/2013 - Retirado campo de valor maximo do boleto vllbolet 
							   Retirado funcao validaDadosTitulares (Jorge)
							   
				  19/09/2013 - Inclusao do campo Convenio Homologado. Criação da function
				               habilitaSetor (Carlos)
                  
				  06/11/2014 - Correção de bug na função "habilitaSetor" que utilizava a função "IndexOf" 
							   onde ocasionava erro no navegador IE. Isso tudo para que a fosse possível adicionar
							   o convênio "IMPRESSO PELO SOFTWARE" na tela de cobranças. (Kelvin)
							   
				  28/04/2015 - Incluido campos cooperativa emite e expede e
							   cooperado emite e expede. (Reinert)
							   
				  06/10/2015 - Reformulacao cadastral (Gabriel-RKAM)			   
						
                  24/11/2015 - Inclusao do indicador de negativacao pelo Serasa.
                               (Jaison/Andrino)

                  27/04/2016 - Ajuste para que departamento CANAIS possa ter acesso 
                               a todas as funções da tela, conforme solicitadono
                               chamado 441903. (Kelvin)

 ***********************************************************************/
 
 var dsdregis = "";  // Variavel para armazenar os valores dos titulares 
 var nrconven = 0;   // Variavel para guardar o convenio no inclui-altera.php
 var mensagem = "Deseja efetuar impress&atilde;o do termo de ades&atilde;o ?"; // Mensagem de confirmacao de impressao
 var callafterCobranca = '';

function habilitaSetor(setorLogado) {
    if ((setorLogado != "CANAIS") && (setorLogado != "TI") && (setorLogado != "SUPORTE")) {
		$('#flgcebhm', '#frmConsulta').desabilitaCampo();
	}	
}
 
 // Acessar tela principal da rotina
 function acessaOpcaoAba() {
 
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando os conv&ecirc;nios ...");
 
	// Carrega conte&uacute;do da op&ccedil;&atilde;o atrav&eacute;s de ajax
	$.ajax({		
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/atenda/cobranca/principal.php",
		data: {
			nrdconta: nrdconta,
			redirect: "html_ajax"
		},
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
		},
        success: function (response) {
			
            $("#divConteudoOpcao").css('display', 'block');
            $("#divOpcaoConsulta").css('display', 'none');
            $("#divOpcaoIncluiAltera").css('display', 'none');
            $("#pesquisaConvenio").css('display', 'none');
            $("#divTitular").css('display', 'none');
            $("#divOpcaoInternet").css('display', 'none');
            $("#divTestemunhas").css('display', 'none');
		
			$("#divConteudoOpcao").html(response);
		}				
	});
 }
 
// Destacar convenio selecinado e setar valores do item selecionado
function selecionaConvenio(idLinha, nrconven, dsorgarq, nrcnvceb, dssitceb, dtcadast, cdoperad, inarqcbr, cddemail, dsdemail, flgcruni, flgcebhm, flgregis, flcooexp, flceeexp, cddbanco, flserasa, flsercco) {
 
    var qtConvenios = $("#qtconven", "#divConteudoOpcao").val();
		
    $("#nrconven", "#divConteudoOpcao").val(nrconven);
    $("#dsorgarq", "#divConteudoOpcao").val(dsorgarq);
    $("#nrcnvceb", "#divConteudoOpcao").val(nrcnvceb);
    $("#dssitceb", "#divConteudoOpcao").val(dssitceb);
    $("#dtcadast", "#divConteudoOpcao").html(dtcadast);
    $("#cdoperad", "#divConteudoOpcao").html(cdoperad);
    $("#inarqcbr", "#divConteudoOpcao").val(inarqcbr);
    $("#cddemail", "#divConteudoOpcao").val(cddemail);
    $("#dsdemail", "#divConteudoOpcao").val(dsdemail);
    $("#flgcruni", "#divConteudoOpcao").val(flgcruni);
    $("#flgcebhm", "#divConteudoOpcao").val(flgcebhm);
    $("#flgregis", "#divConteudoOpcao").val(flgregis);
    $("#flcooexp", "#divConteudoOpcao").val(flcooexp);
    $("#flceeexp", "#divConteudoOpcao").val(flceeexp);
    $("#flserasa", "#divConteudoOpcao").val(flserasa);
    $("#cddbanco", "#divConteudoOpcao").val(cddbanco);
	
	$("#flsercco", "#divConteudoOpcao").val(flsercco);

 }

// Verifica se o convenio CEB pode ser Excluido
function validaExclusao() {

    var nrconven = $("#nrconven", "#divConteudoOpcao").val();
	
	// Convenio nao selecionado 
    if (nrconven == "") {
        showError("error", "Selecione algum conv&ecirc;nio para excluir.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, validando a exclus&atilde;o do conv&ecirc;nio ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		dataType: "html",
		type: "POST", 
		url: UrlSite + "telas/atenda/cobranca/valida_exclusao.php",
		data: {
		  	nrdconta: nrdconta, 
			nrconven: nrconven,
			redirect: "script_ajax" // Tipo de retorno do ajax
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
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});	

}

// Confirmar a exclusao do convenio CEB
function confirmaExclusao() {

    var flgregis = $("#flgregis", "#divConteudoOpcao").val();

    if (flgregis == 'SIM') {
        showConfirmacao('Confirma a exclus&atilde;o do conv&ecirc;nio ?', 'Confirma&ccedil;&atilde;o - Ayllos', 'confirmaImpressaoCancelamento("SIM")', ' blockBackground(parseInt($("#divRotina").css("z-index")))', 'sim.gif', 'nao.gif');
    } else {
        showConfirmacao('Confirma a exclus&atilde;o do conv&ecirc;nio ?', 'Confirma&ccedil;&atilde;o - Ayllos', 'realizaExclusao()', ' blockBackground(parseInt($("#divRotina").css("z-index")))', 'sim.gif', 'nao.gif');
}
}

// Efetuar a exclusao do convenio CEB
function realizaExclusao() {
	
    var nrconven = $("#nrconven", "#divConteudoOpcao").val();
    var nrcnvceb = $("#nrcnvceb", "#divConteudoOpcao").val();

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, Excluindo o conv&ecirc;nio ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		dataType: "html",
		type: "POST", 
		url: UrlSite + "telas/atenda/cobranca/realiza_exclusao.php",
		data: {
		  	nrdconta: nrdconta, 
			nrconven: nrconven,
			nrcnvceb: nrcnvceb,
			redirect: "script_ajax" // Tipo de retorno do ajax
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
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});	

}

// Exibe a opcao de Consulta ou Habilitacao 
function consulta(cddopcao, nrconven, dsorgarq, flginclu, flgregis, cddbanco) {
	
    var nrcnvceb = $("#nrcnvceb", "#divConteudoOpcao").val();
    var dssitceb = $("#dssitceb", "#divConteudoOpcao").val();
    var inarqcbr = $("#inarqcbr", "#divConteudoOpcao").val();
    var cddemail = $("#cddemail", "#divConteudoOpcao").val();
    var dsdemail = $("#dsdemail", "#divConteudoOpcao").val();
    var flgcruni = $("#flgcruni", "#divConteudoOpcao").val();
    var flgcebhm = $("#flgcebhm", "#divConteudoOpcao").val();
    var qtTitulares = $("#qtTitulares", "#divConteudoOpcao").val();
    var titulares = $("#titulares", "#divConteudoOpcao").val();
    var dsdmesag = $("#dsdmesag", "#divConteudoOpcao").val();
    var flcooexp = $("#flcooexp", "#divConteudoOpcao").val();
    var flceeexp = $("#flceeexp", "#divConteudoOpcao").val();
    var flserasa = $("#flserasa", "#divConteudoOpcao").val();
	var emails;	
	
	var flsercco = $("#flserasa","#divOpcaoIncluiAltera").val();
	
	if (nrconven == "") {
        nrconven = $("#nrconven", "#divConteudoOpcao").val();
	}
				
	if (nrconven == "") {
        showError("error", "Selecione algum conv&ecirc;nio para consultar.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		return;
	}	
	
	if (dsorgarq == "") {
        dsorgarq = $("#dsorgarq", "#divConteudoOpcao").val();
	}
	
	if (flgregis == "") {
        flgregis = $("#flgregis", "#divConteudoOpcao").val();
	}	
	
	if (trim(cddopcao) != "C") { // Quando for Habilitacao, carregar emails
        emails = $("#emails_titular", "#divConteudoOpcao").val();
	}
		
    if (flginclu == "true") { // Se esta incluindo , zerar campos
		nrcnvceb = 0;
		dssitceb = "ATIVO";
		inarqcbr = 0;
		cddemail = 0;
		dsdemail = "";
		flgcruni = "SIM";
		flgcebhm = "NAO";		
	}
	
    if (cddbanco == "") {
        cddbanco = $("#cddbanco", "#divConteudoOpcao").val();
	}
	
    // Carrega conte&uacute;do da op&ccedil;&atilde;o atrav&eacute;s de ajax
 	$.ajax({		
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/atenda/cobranca/consulta-habilita.php",
		data: {		
            dsdmesag: dsdmesag,
            nrcnvceb: nrcnvceb,
            nrconven: nrconven,
            dsorgarq: dsorgarq,
            dssitceb: dssitceb,
            inarqcbr: inarqcbr,
            cddemail: cddemail,
            dsdemail: dsdemail,
            flgcruni: flgcruni,
            flgcebhm: flgcebhm,
            flgregis: flgregis,
            flcooexp: flcooexp,
            flceeexp: flceeexp,
            flserasa: flserasa,
            cddbanco: cddbanco,
			qtTitulares: qtTitulares,
            titulares: titulares,
            emails: emails,
            cddopcao: cddopcao,
			flsercco: flsercco, /* Indica se Convenio Possui Serasa*/
									
			redirect: "script_ajax"
		},
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
		},
        success: function (response) {
			$("#divOpcaoConsulta").html(response);
		}		
	});
}

// Se habilitacao, valida dados primeiro , senao já chama os titulares
function titulares(cddopcao, titulares) {

	if (trim(cddopcao) != "C") { // Se habilitacao, primeiro valida dados da tela 
        validaDadosLimites(false, titulares); // Soh valida , nao chama confirmacao 
	}
	else { // Se consulta
        chamaTitulares(cddopcao, titulares);
	}
}
	
// Tela que apresenta os dados dos titulares
function chamaTitulares(cddopcao, titulares) {

    // Carrega conte&uacute;do da op&ccedil;&atilde;o atrav&eacute;s de ajax
 	$.ajax({		
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/atenda/cobranca/titulares.php",
		data: {				
            cddopcao: cddopcao,
            titulares: titulares,
			
			redirect: "script_ajax"
		},
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
		},
        success: function (response) {
			$("#divTitular").html(response);		
		}		
	});	
}

// Abrir a tela de habilitacao
function habilita() {
	
    var nrconven = $("#nrconven", "#divConteudoOpcao").val();
    var dsorgarq = $("#dsorgarq", "#divConteudoOpcao").val();
    var flgregis = $("#flgregis", "#divConteudoOpcao").val();
    var cddbanco = $("#cddbanco", "#divConteudoOpcao").val();
	
	var flsercco = $("#flsercco", "#divConteudoOpcao").val();
	
	// Carrega conte&uacute;do da op&ccedil;&atilde;o atrav&eacute;s de ajax
	$.ajax({		
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/atenda/cobranca/inclui-altera.php",
		data: {		
		    nrconven: nrconven,
			dsorgarq: dsorgarq,
			flgregis: flgregis,
			cddbanco: cddbanco,
			flsercco: flsercco,
			redirect: "script_ajax"
		},
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
		},
        success: function (response) {
			$("#divOpcaoIncluiAltera").html(response);		
		}
		
	});
	
}

// Chamar a tela de zoom dos convenios 
function pesquisaConvenio() {

    var bo = 'b1wgen0059.p';
	var procedure = 'busca_convenios';
    var titulo = 'Conv&ecirc;nios';
    var qtReg = '50';
    var filtro = 'Convenio;nrconven;65px;S;0|Origem;dsorgarq;155px;S;';
    var colunas = 'Convenio;nrconven;15%;right|Origem;dsorgarq;55%;left|Situacao;flgativo;15%;left|Registrada;flgregis;15%;left';
	
	// Se esta desabilitado o campo do convenio
    if ($("#nrconven", "#divOpcaoIncluiAltera").prop("disabled") == true) {
		return;
	}
		
    mostraPesquisa(bo, procedure, titulo, qtReg, filtro, colunas, divRotina);
	return false;
}

// Verificar se pode ser realizada a inclusao 
function validaHabilitacao() {

    var nrconven = retiraCaracteres($("#nrconven", "#divOpcaoIncluiAltera").val(), "0123456789", true);
    var dsorgarq = $("#dsorgarq", "#divOpcaoIncluiAltera").val();
		
	if (nrconven == "") {
        showError("error", "O campo do conv&ecirc;nio deve ser prenchido.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}	
		
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, Validando a habilita&ccedil;&atilde;o do conv&ecirc;nio ...");
			
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		dataType: "html",
		type: "POST", 
		url: UrlSite + "telas/atenda/cobranca/valida_habilitacao.php",
		data: {
		  	nrdconta: nrdconta, 
			nrconven: nrconven,
			dsorgarq: dsorgarq,
			redirect: "script_ajax" // Tipo de retorno do ajax
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
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});	
}

// Validar os dados da habilitacao
function validaDadosLimites(flgconti, titulares, cddopcao) {
	
    var dsorgarq = $("#dsorgarq", "#divOpcaoConsulta").val();
    var inarqcbr = $("#inarqcbr", "#divOpcaoConsulta").val();
    var cddemail = $("#dsdemail", "#divOpcaoConsulta").val();
		
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, Validando os dados da habilita&ccedil;&atilde;o do conv&ecirc;nio ...");
			
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		dataType: "html",
		type: "POST", 
		url: UrlSite + "telas/atenda/cobranca/valida-dados-limites.php",
		data: {
		  	nrdconta: nrdconta, 
			dsorgarq: dsorgarq,
			inarqcbr: inarqcbr,
			cddemail: cddemail,
			flgconti: flgconti,
			titulares: titulares,
			cddopcao: cddopcao,
			redirect: "script_ajax" // Tipo de retorno do ajax
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
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});	
}

// Confirmar a habilitacao do convenio
function confirmaHabilitacao(cddopcao) {
    var dssitceb = $("#dssitceb", "#divOpcaoConsulta").val().toUpperCase();
    var dsmensagem = dssitceb == 'YES' ? "Confirma a habilita&ccedil;&atilde;o do conv&ecirc;nio?" : "Confirma a inativa&ccedil;&atilde;o do conv&ecirc;nio?";
    showConfirmacao(dsmensagem, 'Confirma&ccedil;&atilde;o - Ayllos', 'confirmaHabilitacaoSerasa("' + cddopcao + '")', ' blockBackground(parseInt($("#divRotina").css("z-index")))', 'sim.gif', 'nao.gif');
}

// Confirmar a habilitacao do Serasa
function confirmaHabilitacaoSerasa(cddopcao) {

    var blnchecked = $("#flserasa", "#divOpcaoConsulta").prop("checked");
    var flserasa_old = $("#flserasa", "#divConteudoOpcao").val();
    flserasa_old = flserasa_old == '' ? "NAO" : flserasa_old;
    var flserasa_new = blnchecked ? "SIM" : "NAO";
    var dsmensagem = blnchecked ? "Deseja habilitar a Negativa&ccedil;&atilde;o via Serasa?" : "Deseja cancelar a Negativa&ccedil;&atilde;o via Serasa?";

    // Se foi habilitado/desabilitado o indicador
    if (flserasa_old != flserasa_new) {

        // Seta como checkbox alterado, utilizado no realiza_habilitacao.php
        $("#flseralt", "#divConteudoOpcao").val(1);

        if (trim(cddopcao) == "A") {
            showConfirmacao(dsmensagem, 'Confirma&ccedil;&atilde;o - Ayllos', 'validaHabilitacaoSerasa("' + cddopcao + '")', ' blockBackground(parseInt($("#divRotina").css("z-index")))', 'sim.gif', 'nao.gif');
        } else {
            validaHabilitacaoSerasa(cddopcao);
        }

    } else {
        realizaHabilitacao(cddopcao);
    }

}

// Valida a habilitacao do Serasa
function validaHabilitacaoSerasa(cddopcao) {

    var blnchecked = $("#flserasa","#divOpcaoConsulta").prop("checked");

    // Foi clicado para habilitar Serasa
    if (blnchecked) {
        // Se nao possuir CNAE cadastrado
        if (parseInt(cdclcnae) < 1) {
            showError("error", "CNAE da conta n&atilde;o informado. Favor verificar.", "Alerta - Ayllos", "bloqueiaFundo(divRotina)");
        } else {

            // Mostra mensagem de aguardo
            showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");

            // Carrega conteúdo da opção através de ajax
            $.ajax({
                type: "POST",
                dataType: 'html',
                url: UrlSite + "telas/atenda/cobranca/consulta-cnae-boleto.php",
                data: {
                    cdclcnae: cdclcnae,
                    consulta: 1,
                    redirect: "script_ajax" // Tipo de retorno do ajax
                },
                error: function (objAjax, responseError, objExcept) {
                    hideMsgAguardo();
                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o." + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
                },
                success: function (tbgen_cnae_flserasa) {
                    hideMsgAguardo();
                    bloqueiaFundo($('#divOpcaoIncluiAltera'));
                    if (tbgen_cnae_flserasa == 0) {
                        showError('error', 'N&atilde;o &eacute; permitido habilitar o servi&ccedil;o para este segmento (CNAE).', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
                    } else {
                        realizaHabilitacao(cddopcao);
                    }
                }
            });

        }

    } else { // Foi clicado para desabilitar Serasa

        var nrconven = normalizaNumero($("#nrconven", "#divOpcaoConsulta").val());

        // Mostra mensagem de aguardo
        showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");

        // Carrega conteúdo da opção através de ajax
        $.ajax({
            type: "POST",
            dataType: 'html',
            url: UrlSite + "telas/atenda/cobranca/consulta-cnae-boleto.php",
            data: {
                nrdconta: nrdconta,
                nrconven: nrconven,
                consulta: 2,
                redirect: "script_ajax" // Tipo de retorno do ajax
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.." + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
            },
            success: function (flposbol) {
                hideMsgAguardo();
                bloqueiaFundo($('#divOpcaoIncluiAltera'));
                // Se possuir boleto em aberto
                if (flposbol == 1) {
                    showConfirmacao("Deseja cancelar as instru&ccedil;&otilde;es de negativa&ccedil;&atilde;o sobre os boletos em aberto?", 'Confirma&ccedil;&atilde;o - Ayllos', 'setFlgBoleto(\'' + cddopcao + '\', \'1\')', 'setFlgBoleto(\'' + cddopcao + '\', \'0\')', 'sim.gif', 'nao.gif');
                } else {
                    realizaHabilitacao(cddopcao);
                }
            }
        });
    }

}

function setFlgBoleto(cddopcao, flposbol) {
    $("#flposbol", "#divConteudoOpcao").val(flposbol);
    realizaHabilitacao(cddopcao);
}

// Efetuar a inclusao do convenio 
function realizaHabilitacao(cddopcao) {

    var nrconven = $("#nrconven", "#divOpcaoConsulta").val();
    var dssitceb = $("#dssitceb", "#divOpcaoConsulta").val();
    var inarqcbr = $("#inarqcbr", "#divOpcaoConsulta").val();
    var cddemail = $("#dsdemail", "#divOpcaoConsulta").val();
    var flgcruni = $("#flgcruni", "#divOpcaoConsulta").val();
    var flgcebhm = $("#flgcebhm", "#divOpcaoConsulta").val();
    var flgregis = $("#flgregis", "#divOpcaoConsulta").val();
    var flserasa = $("#flserasa", "#divOpcaoConsulta").val();
    var flseralt = $("#flseralt", "#divConteudoOpcao").val();
    var flposbol = $("#flposbol", "#divConteudoOpcao").val();
    var cddbanco = $("#cddbanco", "#divOpcaoConsulta").val();

    nrconven = normalizaNumero(nrconven);
		
    if ($("#flcooexp", "#divOpcaoConsulta").prop("checked") == true) {
		var flcooexp = 1;
    } else {
		var flcooexp = 0;
	}
    if ($("#flceeexp", "#divOpcaoConsulta").prop("checked") == true) {
		var flceeexp = 1;
    } else {
		var flceeexp = 0;
	}	
    if ($("#flserasa", "#divOpcaoConsulta").prop("checked") == true) {
	    var flserasa = 1;
    } else {
	    var flserasa = 0;
	}
    var nrcpfcgc = $("#nrcpfcgc", "#frmCabAtenda").val().replace(".", "").replace(".", "").replace("-", "").replace("/", "");
		
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, Incluindo a habilita&ccedil;&atilde;o do conv&ecirc;nio ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		dataType: "html",
		type: "POST", 
		url: UrlSite + "telas/atenda/cobranca/realiza_habilitacao.php",
		data: {
		  	nrdconta: nrdconta, 
			nrconven: nrconven,
			dssitceb: dssitceb,
			inarqcbr: inarqcbr,
			cddemail: cddemail,
			flgcruni: flgcruni,
			flgcebhm: flgcebhm,
			dsdregis: dsdregis,
			flgregis: flgregis,
			flcooexp: flcooexp,
			flceeexp: flceeexp,
			flserasa: flserasa,
			flseralt: flseralt,
			flposbol: flposbol,
			nrcpfcgc: nrcpfcgc,
			cddopcao: cddopcao,
			executandoProdutos: executandoProdutos,
			redirect: "script_ajax" // Tipo de retorno do ajax
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
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});
}

// Perguntar se quer fazer a impressao do termo
function confirmaImpressao(flgregis, dsdtitul) {

	var callafterCobranca = 'blockBackground(parseInt($("#divRotina").css("z-index")));';

	callafterCobranca += (executandoProdutos) ? 'encerraRotina();' : 'acessaOpcaoAba();';
	
    if ($("#dssitceb", "#divConteudoOpcao").val() == 'INATIVO') {
        aux_mensagem = "Deseja efetuar impress&atilde;o do termo de cancelamento ?"; // Mensagem de confirmacao de impressao;
    } else {
        aux_mensagem = mensagem;
    }

	// Se cobranca Registrada
    if (flgregis == "SIM") {
        showConfirmacao(aux_mensagem,
						'Confirma&ccedil;&atilde;o - Ayllos',
						'testemunhas("' + flgregis + '");blockBackground(parseInt($("#divRotina").css("z-index")));',
						callafterCobranca, 
						'sim.gif',
						'nao.gif');	
	}
	else {		
        showConfirmacao(aux_mensagem,
					   'Confirma&ccedil;&atilde;o - Ayllos',
					   'imprimirTermoAdesao("' + flgregis + '","' + dsdtitul + '");',
					   callafterCobranca,
					   'sim.gif',
					   'nao.gif');	
	}
		
}

function testemunhas(flgregis) {
					
	var nmrotina = "imprimirTermoAdesao";
	
	// Carrega conteúdo da opção através do Ajax
	$.ajax({		
		type: 'POST', 
		dataType: 'html',
		url: UrlSite + 'telas/atenda/dda/testemunhas.php',
		data: {		    
			nmrotina: nmrotina,
			flgregis: flgregis,
			redirect: 'ajax_html'
		},		
        error: function (objAjax, responseError, objExcept) {
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
		},
        success: function (response) {
            $("#divOpcaoIncluiAltera").css({ 'display': 'none' });
            $("#divOpcaoConsulta").css({ 'display': 'none' });
			$("#divTestemunhas").html(response);			

		}				
	});
}


function validaCpf(nmrotina) {

	var idseqttl = 1;
    var nmdtest1 = $("#nmdtest1", "#divTestemunhas").val();
    var cpftest1 = $("#cpftest1", "#divTestemunhas").val();
    var nmdtest2 = $("#nmdtest2", "#divTestemunhas").val();
    var cpftest2 = $("#cpftest2", "#divTestemunhas").val();
    var flgregis = $("#flgregis", "#divTestemunhas").val();
 
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
			flgregis: flgregis,
			redirect: 'ajax_html'
		},		
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
		},
        success: function (response) {
			try {
				eval(response);
            } catch (error) {
				hideMsgAguardo();					
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});
}	
		

// Função para carregar impressao de termo de adesão em PDF
function imprimirTermoAdesao(flgregis, dsdtitul, tpimpres) {
	
    var nmdtest1 = $("#nmdtest1", "#divTestemunhas").val();
    var cpftest1 = $("#cpftest1", "#divTestemunhas").val();
    var nmdtest2 = $("#nmdtest2", "#divTestemunhas").val();
    var cpftest2 = $("#cpftest2", "#divTestemunhas").val();
	
    var nrconven = normalizaNumero($("#nrconven", "#divConteudoOpcao").val());
	
    flgregis = (flgregis == "SIM") ? "yes" : "no";
	
    $("#nrdconta", "#frmTermo").val(nrdconta);
    $("#dsdtitul", "#frmTermo").val(dsdtitul);
    $("#flgregis", "#frmTermo").val(flgregis);
    $("#nmdtest1", "#frmTermo").val(nmdtest1);
    $("#cpftest1", "#frmTermo").val(cpftest1);
    $("#nmdtest2", "#frmTermo").val(nmdtest2);
    $("#cpftest2", "#frmTermo").val(cpftest2);
    $("#nrconven", "#frmTermo").val(nrconven);

    tpimpres = typeof tpimpres !== 'undefined' ? tpimpres : "1";

    $("#tpimpres", "#frmTermo").val(tpimpres);
	
	var action = $("#frmTermo").attr("action");
	var callafter = "acessaOpcaoAba();";
	
	if (executandoProdutos) {
		callafterCobranca = 'encerraRotina();';
	}
	
	if (callafterCobranca != '') {
		callafter = callafterCobranca;
	}
	
    carregaImpressaoAyllos("frmTermo", action, callafter);
}

// Limpar campos e deselecionar o convenio 
function limpaCampos() {

    var cor = "";
    var qtConvenios = $("#qtconven", "#divConteudoOpcao").val();
	
    $("#nrconven", "#divConteudoOpcao").val("");
    $("#dsorgarq", "#divConteudoOpcao").val("");
	
    var nomeForm = 'divResultado';
    var divRegistro = $('div.divRegistros', '#' + nomeForm);
    var tabela = $('table', divRegistro);
		
	tabela.zebraTabela();
			
}

function controlaLayout(nomeForm) {

    if (nomeForm == 'frmConsulta') {
		
        $('#' + nomeForm).addClass('formulario');
	
        var Lnrconven = $('label[for="nrconven"]', '#' + nomeForm);
        var Ldsorgarq = $('label[for="dsorgarq"]', '#' + nomeForm);
        var Ldssitceb = $('label[for="dssitceb"]', '#' + nomeForm);
        var Lflgregis = $('label[for="flgregis"]', '#' + nomeForm);
        var Lflcooexp = $('label[for="flcooexp"]', '#' + nomeForm);
        var Lflceeexp = $('label[for="flceeexp"]', '#' + nomeForm);
        var Lflserasa = $('label[for="flserasa"]', '#' + nomeForm);
        var Linarqcbr = $('label[for="inarqcbr"]', '#' + nomeForm);
        var Ldsdemail = $('label[for="dsdemail"]', '#' + nomeForm);
        var Lflgcruni = $('label[for="flgcruni"]', '#' + nomeForm);
        var Lflgcebhm = $('label[for="flgcebhm"]', '#' + nomeForm);
		
        var Cnrconven = $('#nrconven', '#' + nomeForm);
        var Cdsorgarq = $('#dsorgarq', '#' + nomeForm);
        var Cdssitceb = $('#dssitceb', '#' + nomeForm);
        var Cflgregis = $('#flgregis', '#' + nomeForm);
        var Cinarqcbr = $('#inarqcbr', '#' + nomeForm);
        var Cdsdemail = $('#dsdemail', '#' + nomeForm);
        var Cflgcruni = $('#flgcruni', '#' + nomeForm);
        var Cflgcebhm = $('#flgcebhm', '#' + nomeForm);
		
        Lnrconven.addClass('rotulo').css('width', '210px');
        Ldsorgarq.addClass('rotulo').css('width', '210px');
        Ldssitceb.addClass('rotulo').css('width', '210px');
        Lflgregis.addClass('rotulo').css('width', '210px');
        Lflcooexp.addClass('rotulo').css('width', '210px');
        Lflceeexp.addClass('rotulo').css('width', '210px');
        Lflserasa.addClass('rotulo').css('width', '210px');
        Linarqcbr.addClass('rotulo').css('width', '210px');
        Ldsdemail.addClass('rotulo').css('width', '210px');
        Lflgcruni.addClass('rotulo').css('width', '210px');
        Lflgcebhm.addClass('rotulo').css('width', '210px');
		
        Cnrconven.css({ 'width': '70px' });
        Cdsorgarq.css({ 'width': '200px' });
        Cdssitceb.css({ 'width': '70px' });
        Cflgregis.css({ 'width': '50px' });
        Cinarqcbr.css({ 'width': '155px' });
        Cdsdemail.css({ 'width': '200px' });
        Cflgcruni.css({ 'width': '50px' });
        Cflgcebhm.css({ 'width': '50px' });
		
    } else if (nomeForm == 'frmHabilita') {
	
        var Lnrconven = $('label[for="nrconven"]', '#' + nomeForm);
        var Ldsorgarq = $('label[for="dsorgarq"]', '#' + nomeForm);
		
        var Cnrconven = $('#nrconven', '#' + nomeForm);
        var Cdsorgarq = $('#dsorgarq', '#' + nomeForm);
		
        $('#' + nomeForm).addClass('formulario');
		
        Lnrconven.addClass('rotulo').css('width', '210px');
        Ldsorgarq.addClass('rotulo').css('width', '210px');
															 
        Cnrconven.addClass('pesquisa').css({ 'width': '66px' }).attr('maxlength', '8').setMask("INTEGER", "zzzzz.zz9", ".", "");
        Cdsorgarq.css({ 'width': '150px', 'background-color': 'F3F3F3', 'font-size': '11px', 'padding': '2px 4px 1px 4px' });

        Cnrconven.unbind('keydown').bind('keydown', function (e) {
            if (divError.css('display') == 'block') { return false; }
            if (e.keyCode == 118) {
				pesquisaConvenio();
			}
		});	
		
		
    } else if (nomeForm == 'divResultado') {
		
        var divRegistro = $('div.divRegistros', '#' + nomeForm);
        var tabela = $('table', divRegistro);
		
		tabela.zebraTabela(0);
						
        $('#' + nomeForm).css('width', '600px');
        divRegistro.css('height', '85px');
						
		var ordemInicial = new Array();
				
		var arrayLargura = new Array();
		arrayLargura[0] = '65px';
		arrayLargura[1] = '220px';
		arrayLargura[2] = '60px';
		arrayLargura[3] = '57px';
		arrayLargura[4] = '60px';
		
						
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'right';
		arrayAlinha[1] = 'left';
		arrayAlinha[2] = 'left';
		arrayAlinha[3] = 'right';
		arrayAlinha[4] = 'left';
		arrayAlinha[5] = 'left';
								
        tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');
		
        $('tbody > tr', tabela).each(function () {
            if ($(this).hasClass('corSelecao')) {
				$(this).focus();		
			}
		});

		// complemento
        var complemento = $('ul.complemento');
		
		$('li:eq(0)', complemento).addClass('txtNormalBold');
        $('li:eq(1)', complemento).addClass('txtNormal').css({ 'width': '35%' });
		$('li:eq(2)', complemento).addClass('txtNormalBold');
        $('li:eq(3)', complemento).addClass('txtNormal').css({ 'width': '40%' });

		ajustarCentralizacao();	
		
	}
	
	callafterCobranca = '';
	controlaPesquisas();		
	layoutPadrao();
	return false;
}

function controlaPesquisas() {

	/*--------------------*/
	/*  CONTROLE CONVENIO */
	/*--------------------*/
    var linkConvenio = $('a:eq(0)', '#frmHabilita');
	
    if (linkConvenio.prev().hasClass('campoTelaSemBorda')) {
        linkConvenio.addClass('lupa').css('cursor', 'auto').unbind('click').bind('click', function () { return false; });
	} else {
        linkConvenio.css('cursor', 'pointer').unbind('click').bind('click', function () {
			pesquisaConvenio();
		});
	}

	// Convenio
    $('#nrconven', '#frmHabilita').unbind('change').bind('change', function () {
        var bo = 'b1wgen0059.p';
        var procedure = 'busca_convenios';
        var titulo = 'Conv&ecirc;nios';
		var filtrosDesc = '';
        buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'dsorgarq', normalizaNumero($(this).val()), 'dsorgarq', filtrosDesc, 'frmHabilita');
		return false;
	});	
	
	return false;
}


// Perguntar se quer fazer a impressao do termo
function confirmaImpressaoCancelamento(flgregis) {

    var callafterCobranca = 'blockBackground(parseInt($("#divRotina").css("z-index")));';

    callafterCobranca += (executandoProdutos) ? 'encerraRotina();' : 'acessaOpcaoAba(); realizaExclusao();';

    aux_mensagem = "Deseja efetuar impress&atilde;o do termo de cancelamento ?"; // Mensagem de confirmacao de impressao;

    showConfirmacao(aux_mensagem,
					'Confirma&ccedil;&atilde;o - Ayllos',
					'testemunhasCancelamento("' + flgregis + '");blockBackground(parseInt($("#divRotina").css("z-index")));',
					callafterCobranca,
					'sim.gif',
					'nao.gif');
}

function testemunhasCancelamento(flgregis) {

    var nmrotina = "imprimirTermoCancelamento";

    // Carrega conteúdo da opção através do Ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/dda/testemunhas.php',
        data: {
            nmrotina: nmrotina,
            flgregis: flgregis,
            redirect: 'ajax_html'
        },
        error: function (objAjax, responseError, objExcept) {
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function (response) {
            $("#divOpcaoIncluiAltera").css({ 'display': 'none' });
            $("#divOpcaoConsulta").css({ 'display': 'none' });
            $("#divTestemunhas").html(response);

        }
    });
}

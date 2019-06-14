/***********************************************************************
   Fonte: dep_vista.js
   Autor: Guilherme
   Data : Fevereiro/2007                  Última Alteração: 24/01/2018

   Objetivo  : Biblioteca de funções da rotina Dep. Vista da tela
               ATENDA

   Alterações: 02/10/2009 - Tratamento para listagem de depositos identificados no extrato (David).							
               02/09/2010 - Ajuste na função obtemSaldos (David).		
               29/06/2011 - Imprimir Extrato - Alterado para layout padrão (Rogerius - DB1).
               29/08/2011 - Imprimir Extrato - Nova coluna: Parcela (Marcelo L. Pereira - GATI).
							 01/09/2011 - Incluir informacoes de historico e data liberacao no rodape (Gabriel)
							 26/06/2012 - Alterado funcao Gera_Impressao(), novo esquema para impressao (Jorge)			   
							 31/05/2013 - Fixado valor do campo inisenta e na procedure validarImpressao (Daniel)			   
							 04/06/2013 - Incluir label[for="vlblqjud"] em controlaLayout (Lucas R.)           	   
							 27/08/2015 - Ajuste para inclusão da nova rotina "Créditos Recebidos" (Gabriel - RKAM -> Projeto 127).	
							 14/10/2015 - Adicionado novos campos média do mês atual e dias úteis decorridos. SD 320300 (Kelvin).
							 25/07/2016 - Adicionado função controlaFoco (Evandro - RKAM)
							 06/10/2016 - Incluido campo de valores bloqueados em acordos de empréstimos "vlblqaco", Prj. 302 (Jean Michel).
							 11/07/2017 - Novos campos Limite Pré-aprovado disponível e Última Atu. Lim. Pré-aprovado na aba Principal, Melhoria M441. ( Mateus Zimmermann/MoutS )
                             04/11/2017 - Ajuste permitir apenas consulta de extrato quando contas demitidas
                                          (Jonata - RKAM P364).
							 24/01/2018 - Na funcao controlaLayout havia erros de sintaxe ocasionando problemas na 
							              formatação da tela (Tiago #824708)
							 12/03/2018 - Campos de data de inicio de atraso e data transf prejuizo (Marcel Kohls / AMCom)
               26/06/2018 - Campos do pagamento do prejuizo(Conta Transitoria)
                            P450 - Diego Simas - AMcom
			   01/08/2018 - Ajuste nos campos do pagamento do prejuízo da conta transitória
			   				PJ450 - Diego Simas - AMcom
			   03/08/2018 - Campos do pagamento do empréstimo (Conta Transitória)
                            P450 - Diego Simas - AMcom
               21/08/2018 - Incluído campo Juros referente ao juros remuneratório da conta transitória.
				  		    PJ450 - Diego Simas - AMcom 
			   04/09/2018 - Ajuste na mensagem de pagamento de prejuizo em conta sem saldo
			   			    PJ450 - Diego Simas - AMcom

 ***********************************************************************/

var contWin  = 0;  // Variável para contagem do número de janelas abertas para impressão de extratos
var dtiniper = "";
var dtfimper = "";

// Função para acessar opções da rotina
function acessaOpcaoAba(nrOpcoes,id,opcao) {
	

	if (opcao == "0") {	// Opção Principal
		var msg = "dep&oacute;sitos &agrave; vista";
		var UrlOperacao = UrlSite + "telas/atenda/dep_vista/principal.php";
	} else if (opcao == "1") {	// Opção Extrato
		var msg = "extrato";
		var UrlOperacao = UrlSite + "telas/atenda/dep_vista/extrato.php";
	} else if (opcao == "2") {	// Opção Médias
		var msg = "m&eacute;dias";
		var UrlOperacao = UrlSite + "telas/atenda/dep_vista/medias.php";
	} else if (opcao == "3") {	// Opção CPMF
		var msg = "cpmf";
		var UrlOperacao = UrlSite + "telas/atenda/dep_vista/cpmf.php";
	} else if (opcao == "4") {	// Opção Saldos Anteriores
		var msg = "op&ccedil;&atilde;o para extrato";
		var UrlOperacao = UrlSite + "telas/atenda/dep_vista/imprimir_extrato.php";
	} else if (opcao == "5") {	// Opção Saldos Anteriores
		var msg = "saldos anteriores";
		var UrlOperacao = UrlSite + "telas/atenda/dep_vista/saldos_anteriores.php";
	} else if (opcao == "6") {	// Opção Cash
		var msg = "extratos cash";
		var UrlOperacao = UrlSite + "telas/atenda/dep_vista/cash.php";
	}else if (opcao == "7") {	// Opção Créditos Recebidos
		var msg = "creditos recebidos";
		var UrlOperacao = UrlSite + "telas/atenda/dep_vista/creditos_recebidos.php";
}

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando " + msg + " ...");

	// Atribui cor de destaque para aba da opção
	nrOpcoes = nrOpcoes + 1;
	for (var i = 0; i < nrOpcoes; i++) {
		if (id == i) { // Atribui estilos para foco da opção
			$("#linkAba" + id).attr("class","txtBrancoBold");
			$("#imgAbaEsq" + id).attr("src",UrlImagens + "background/mnu_sle.gif");				
			$("#imgAbaDir" + id).attr("src",UrlImagens + "background/mnu_sld.gif");
			$("#imgAbaCen" + id).css("background-color","#969FA9");
			continue;			
		}
		
		$("#linkAba" + i).attr("class","txtNormalBold");
		$("#imgAbaEsq" + i).attr("src",UrlImagens + "background/mnu_nle.gif");			
		$("#imgAbaDir" + i).attr("src",UrlImagens + "background/mnu_nld.gif");
		$("#imgAbaCen" + i).css("background-color","#C6C8CA");
	}
	
	if (opcao == "1") {	// Opção extrato		
		$.ajax({		
			type: "POST",
			dataType: "html",
			url: UrlOperacao,
			data: {
				nrdconta: nrdconta,
				dtiniper: $("#dtiniper","#frmExtDepVista").val(),
				dtfimper: $("#dtfimper","#frmExtDepVista").val(),
				iniregis: $("#iniregis","#frmExtDepVista").val(),
				redirect: "html_ajax"
			},
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')) )");
			},
			success: function(response) {
				$("#divConteudoOpcao").html(response);
				controlaFoco(opcao);
			}				
		}); 
	}else if (opcao == "5") {	// Opção saldos anteriores		
		$.ajax({		
			type: "POST",
			dataType: "html",
			url: UrlOperacao,
			data: {
				nrdconta: nrdconta,
				dtdapesq: $("#dtdapesq","#frmSaldoAnt").val(),
				redirect: "html_ajax"
			},
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')) )");
			},
			success: function(response) {
				$("#divConteudoOpcao").html(response);
				controlaFoco(opcao);
			}				
		}); 
	}else if (opcao == "6") {	// Opção Cash		
		$.ajax({		
			type: "POST",
			dataType: "html",
			url: UrlOperacao,
			data: {
				nrdconta: nrdconta,
				dtrefere: $("#dtrefere","#frmExtCash").val(),
				redirect: "html_ajax"
			},
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')) )");
			},
			success: function(response) {
				$("#divConteudoOpcao").html(response);
				controlaFoco(opcao);
			}				
		}); 
	} else { // Demais Opções
		// Carrega conteúdo da opção através de ajax
		$.ajax({		
			type: "POST",
			dataType: "html",
			url: UrlOperacao,
			data: {
				nrdconta: nrdconta,
				redirect: "html_ajax"
			},
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')) )");
			},
			success: function(response) {
				$("#divConteudoOpcao").html(response);
				controlaFoco(opcao);
			}				
		}); 		
	}
}

//controle de foco de navegação
function controlaFoco(opcao) {
    var IdForm = '';
    var formid;

    if (opcao == "0") { //Principal
        $('.FirstInput:first ').focus();
			}				
    if (opcao == "1") { //Extrato 
        $('#divConteudoOpcao').each(function () {
            formid = $('#divConteudoOpcao form');
            IdForm = $(formid).attr('id');//Seleciona o id do formulario
            if (IdForm == "frmExtDepVista") {
                $(this).find("#frmExtDepVista > :input[type=text]").first().addClass("FirstInputModal").focus();
                $(this).find("#frmExtDepVista > :input").last().addClass("LastInputModal");

                //Se estiver com foco na classe LastInputModal
                $(".LastInputModal").focus(function () {
                    $(this).bind('keydown', function (e) {
                        if (e.keyCode == 13) {
                            $(".LastInputModal").click();
                        }
                });
                });

            };
        });
        $('.FirstInputModal:first ').focus();
	}
    if (opcao == "4") { //Imprimir extrato
        $('#divConteudoOpcao').each(function () {
            formid = $('#divConteudoOpcao form');
            IdForm = $(formid).attr('id');//Seleciona o id do formulario
            if (IdForm == "frmExtrato") {
                $(this).find("#frmExtrato > :input[type=text]").first().addClass("FirstInputModal").focus();
                $(this).find("#frmExtrato > :input").last().addClass("LastInputModal");

                //Se estiver com foco na classe LastInputModal
                $(".LastInputModal").focus(function () {
                    $(this).bind('keydown', function (e) {
                        if (e.keyCode == 13) {
                            $(".LastInputModal").click();
}
                    });
                });
            };
        });
        $('.FirstInputModal:first ').focus();
    }
    if (opcao == "5") { //Saldos anteriores
        $('#divConteudoOpcao').each(function () {
            formid = $('#divConteudoOpcao form');
            IdForm = $(formid).attr('id');//Seleciona o id do formulario
            if (IdForm == "frmSaldoAnt") {
                $(this).find("#frmSaldoAnt > :input[type=text]").first().addClass("FirstInputModal").focus();
                $(this).find("#frmSaldoAnt > :input[type=image]").last().addClass("LastInputModal");

                //Se estiver com foco na classe LastInputModal
                $(".LastInputModal").focus(function () {
                    $(this).bind('keydown', function (e) {
                        if (e.keyCode == 13) {
                            $(".LastInputModal").click();
                        }
                    });
                });
            };
        });
        $('.FirstInputModal:first ').focus();
    }
    if (opcao == "6") { //Cash
        $('#divConteudoOpcao').each(function () {
            formid = $('#divConteudoOpcao form');
            IdForm = $(formid).attr('id');//Seleciona o id do formulario
            if (IdForm == "frmExtCash") {
                $(this).find("#frmExtCash > :input[type=text]").first().addClass("FirstInputModal").focus();
                $(this).find("#frmExtCash > :input").last().addClass("LastInputModal");

                //Se estiver com foco na classe LastInputModal
                $(".LastInputModal").focus(function () {
                    $(this).bind('keydown', function (e) {
                        if (e.keyCode == 13) {
                            $(".LastInputModal").click();
                        }
                    });
                });
            };
        });
    }
    $('.FirstInputModal:first ').focus();
}

// Função para confirmar saque na conta investimento
function obtemSaldos() {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, efetuando busca ...");

	var dtrefere = $("#dtrefere","#frmSaldoAnt").val();

	// Valida data
	if ($.trim(dtrefere) == "" || !validaData(dtrefere)) {
		hideMsgAguardo();
		showError("erro","Data de Pesquisa inv&aacute;lida.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')));$('#dtrefere','#frmSaldoAnt').focus()");
		$("#dtrefere","#frmSaldoAnt").val("");
		return false;
	}

	// Executa script de saldos através de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/atenda/dep_vista/obtem_saldos.php",
		data: {
			nrdconta: nrdconta,
			dtrefere: dtrefere,
			redirect: "script_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}
	});
}

// Função para validar impressão do extrato
function validarImpressao() {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, verificando impress&atilde;o ...");

	var dtiniper = $("#dtiniper","#frmExtrato").val();
	var dtfimper = $("#dtfimper","#frmExtrato").val();
	var inisenta = "0"; // $("#inisenta","#frmExtrato").val(); Daniel

	// Valida data inicial
	if ($.trim(dtiniper) == "" || !validaData(dtiniper)) {
		hideMsgAguardo();
		showError("erro","Data inicial inv&aacute;lida.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')));$('#dtiniper','#frmExtrato').focus()");
		$("#dtiniper","#frmExtrato").val("");
		return false;
	}

	// Valida data final
	if ($.trim(dtfimper) == "" || !validaData(dtfimper)) {
		hideMsgAguardo();
		showError("erro","Data final inv&aacute;lida.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')));$('#dtfimper','#frmExtrato').focus()");
		$("#dtfimper","#frmExtrato").val("");
		return false;
	}

	// Executa script através de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/atenda/dep_vista/validar_impressao_extrato.php",
		data: {
			nrdconta: nrdconta,
			dtiniper: dtiniper,
			dtfimper: dtfimper,
			inisenta: inisenta,
			redirect: "script_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}
	});
}

// Função para imprimir extrato da conta em PDF
function imprimirExtrato() {	
	blockBackground(parseInt($("#divRotina").css("z-index")));
	$("#nrdconta","#frmExtrato").val(nrdconta);
	
	var action = $("#frmExtrato").attr("action");
	var callafter = "bloqueiaFundo(divRotina);";
	
	carregaImpressaoAyllos("frmExtrato",action,callafter);
}

function imprimirExtratoCT() {
	blockBackground(parseInt($("#divRotina").css("z-index")));
	$("#nrdconta", "#frmDetalhesCT").val(nrdconta);

	var action = $("#frmDetalhesCT").attr("action");
	var callafter = "bloqueiaFundo(divRotina);";

	carregaImpressaoAyllos("frmDetalhesCT", action, callafter);
}



function imprimeExtratoLancamentosCT() {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, verificando impress&atilde;o ...");

	var dtiniper = $("#dtiniper", "#frmDetalhesCT").val();
	var dtfimper = $("#dtfimper", "#frmDetalhesCT").val();

	// Valida data inicial
	if ($.trim(dtiniper) == "" || !validaData(dtiniper)) {
		hideMsgAguardo();
		showError("erro", "Data inicial inv&aacute;lida.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')));$('#dtiniper','#frmExtrato').focus()");
		$("#dtiniper", "#frmDetalhesCT").val("");
		return false;
	}

	// Valida data final
	if ($.trim(dtfimper) == "" || !validaData(dtfimper)) {
		hideMsgAguardo();
		showError("erro", "Data final inv&aacute;lida.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')));$('#dtfimper','#frmExtrato').focus()");
		$("#dtfimper", "#frmDetalhesCT").val("");
		return false;
	}

	// Executa script atraves de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/atenda/dep_vista/validar_impressao_extrato_CT.php",
		data: {
			nrdconta: nrdconta,
			dtiniper: dtiniper,
			dtfimper: dtfimper,
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

//
function obtemExtrato() {
	$("#iniregis","#frmExtDepVista").val("1");
	
	acessaOpcaoAba(2,1,1);
}

//
function navega(iniregis) {
	$("#dtiniper","#frmExtDepVista").val(dtiniper);
	$("#dtfimper","#frmExtDepVista").val(dtfimper);
	$("#iniregis","#frmExtDepVista").val(iniregis);
	
	acessaOpcaoAba(2,1,1);
}

// Função que formata o layout
function controlaLayout( nomeForm ){

	var altura = '310px';

	if (nomeForm == 'frmDadosDepVista') {
        //Seleção dos Labels e Inputs
        if ($.browser.msie) {
            $('fieldset').css({ 'padding-top': '6px' });
        } else {
            $('fieldset').css({ 'padding': '4px 4px' });
        }

        cTodos = $('input', '#' + nomeForm);

        var Lvlsddisp = $('label[for="vlsddisp"]', '#' + nomeForm);
        var Cvlsddisp = $('#vlsddisp', '#' + nomeForm);

        var Lvlsaqmax = $('label[for="vlsaqmax"]', '#' + nomeForm);
        var Cvlsaqmax = $('#vlsaqmax', '#' + nomeForm);

        var Lvlsdbloq = $('label[for="vlsdbloq"]', '#' + nomeForm);
        var Cvlsdbloq = $('#vlsdbloq', '#' + nomeForm);

        var Lvlacerto = $('label[for="vlacerto"]', '#' + nomeForm);
        var Cvlacerto = $('#vlacerto', '#' + nomeForm);

        var Lvlsdblpr = $('label[for="vlsdblpr"]', '#' + nomeForm);
        var Cvlsdblpr = $('#vlsdblpr', '#' + nomeForm);

        var Lvlsdblfp = $('label[for="vlsdblfp"]', '#' + nomeForm);
        var Cvlsdblfp = $('#vlsdblfp', '#' + nomeForm);

        var Lvlipmfpg = $('label[for="vlipmfpg"]', '#' + nomeForm);
        var Cvlipmfpg = $('#vlipmfpg', '#' + nomeForm);
	
		var Lvlblqaco = $('label[for="vlblqaco"]', '#' + nomeForm);
        var Cvlblqaco = $('#vlblqaco', '#' + nomeForm);

        var Lvlsdchsl = $('label[for="vlsdchsl"]', '#' + nomeForm);
        var Cvlsdchsl = $('#vlsdchsl', '#' + nomeForm);

        var Lvlblqjud = $('label[for="vlblqjud"]', '#' + nomeForm);
        var Cvlblqjud = $('#vlblqjud', '#' + nomeForm);

        var Lvlstotal = $('label[for="vlstotal"]', '#' + nomeForm);
        var Cvlstotal = $('#vlstotal', '#' + nomeForm);

        var Lvllimcre = $('label[for="vllimcre"]', '#' + nomeForm);
        var Cvllimcre = $('#vllimcre', '#' + nomeForm);

		var Lvlsldctr = $('label[for="vlsldctr"]', '#' + nomeForm);
		var Cvlsldctr = $('#vlsldctr', '#' + nomeForm);

        var Ldtultlcr = $('label[for="dtultlcr"]', '#' + nomeForm);
        var Cdtultlcr = $('#dtultlcr', '#' + nomeForm);

        var Lvllimdis = $('label[for="vllimdis"]', '#' + nomeForm);
        var Cvllimdis = $('#vllimdis', '#' + nomeForm);

        var Ldtliberacao = $('label[for="dtliberacao"]', '#' + nomeForm);
        var Cdtliberacao = $('#dtliberacao', '#' + nomeForm);

		var Ldttrapre = $('label[for="dttrapre"]', '#' + nomeForm);
        var Cdttrapre = $('#dttrapre', '#' + nomeForm);

		var Ldtiniatr = $('label[for="dtiniatr"]', '#' + nomeForm);
        var Cdtiniatr = $('#dtiniatr', '#' + nomeForm);

        //Formatação dos Labels
        Lvlsddisp.addClass('rotulo').css('width', '110px');
        Lvlsaqmax.css('width', '180px');
        Lvlsdbloq.addClass('rotulo').css('width', '110px');
        Lvlacerto.css('width', '180px');
        Lvlsdblpr.addClass('rotulo').css('width', '110px');
        Lvlsdblfp.addClass('rotulo').css('width', '110px');
        Lvlipmfpg.css('width', '180px');
		Lvlblqaco.addClass('rotulo').css('width', '110px');
        Lvlsdchsl.addClass('rotulo').css('width', '110px');
        Lvlblqjud.addClass('rotulo').css('width', '110px');
        Lvlstotal.addClass('rotulo').css('width', '110px');
        Lvllimcre.addClass('rotulo').css('width', '110px');
		Lvlsldctr.addClass('rotulo').css('width', '110px');
        Ldtultlcr.css('width', '180px');
        Lvllimdis.css('width', '180px');
        Ldtliberacao.css('width', '180px');
		Ldtiniatr.css('width', '180px');
		Ldttrapre.css('width', '180px');

        //Formatação dos campos
        Cvlsddisp.css('width', '87px').addClass('monetario');
        Cvlsaqmax.css('width', '93px').addClass('monetario');
        Cvlsdbloq.css('width', '87px').addClass('monetario');
        Cvlacerto.css('width', '93px').addClass('monetario');
        Cvlsdblpr.css('width', '87px').addClass('monetario');
        Cvlsdblfp.css('width', '87px').addClass('monetario');
        Cvlipmfpg.css('width', '93px').addClass('monetario');
		Cvlblqaco.css('width', '87px').addClass('monetario');
        Cvlsdchsl.css('width', '87px').addClass('monetario');
        Cvlblqjud.css('width', '87px').addClass('monetario');
        Cvlstotal.css('width', '87px').addClass('monetario');
        Cvllimcre.css('width', '87px').addClass('monetario');
		Cvlsldctr.css('width', '87px').addClass('monetario');
        Cdtultlcr.css('width', '93px').addClass('data');
        Cvllimdis.css('width', '93px').addClass('monetario');
        Cdtliberacao.css('width', '93px').addClass('data');
		Cdtiniatr.css('width', '93px').addClass('data');
		Cdttrapre.css('width', '93px').addClass('data');

        cTodos.desabilitaCampo();

    }else if( nomeForm == 'frmExtDepVista' ){
	
		altura = '245px';
	
		//Formatação do formulário
		$('#'+nomeForm).css('width','525px').addClass('formulario');
		
		if ( $.browser.msie ) {
			$('#'+nomeForm).css('margin-bottom','-10px')
		}
		
		var Ldtiniper = $('label[for="dtiniper"]','#'+nomeForm);
		var Cdtiniper = $('#dtiniper','#'+nomeForm);

		var Ldtfimper = $('label[for="dtfimper"]','#'+nomeForm);
		var Cdtfimper = $('#dtfimper','#'+nomeForm);

		Ldtiniper.addClass('rotulo').css('width','55px');
		Ldtfimper.addClass('rotulo-linha');
		
		Cdtiniper.css('width','65px');
		Cdtfimper.css('width','65px');
		
		Cdtiniper.habilitaCampo();
		Cdtfimper.habilitaCampo();
		
		// Seta máscara aos campos dtiniper e dtfimper
		$("#dtiniper,#dtfimper","#frmExtDepVista").setMask("DATE","","","divRotina");

		$("#dtiniper","#frmExtDepVista").focus();

		//Formatação da tabela
		$('#divPesquisaRodape','#divConteudoOpcao').formataRodapePesquisa();

		var divRegistro = $('div.divRegistros','#divConteudoOpcao');		
		var tabela      = $('table', divRegistro );
		var linha       = $('table > tbody > tr', divRegistro );

		divRegistro.css('height','150px');

		var ordemInicial = new Array();
		ordemInicial = [[0,0]];

		var arrayLargura = new Array();
		arrayLargura[0] = '55px';
		arrayLargura[1] = '144px';
		arrayLargura[2] = '70px';
		arrayLargura[3] = '40px';
		arrayLargura[4] = '27px';
		arrayLargura[5] = '60px';

		var arrayAlinha = new Array();
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'left';
		arrayAlinha[2] = 'right';
		arrayAlinha[3] = 'center';
		arrayAlinha[4] = 'center';
		arrayAlinha[5] = 'right';
		arrayAlinha[6] = 'right';

		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '');

	} else if (nomeForm == 'frmDetalhesCT') {

		$("#dtiniper,#dtfimper", "#frmDetalhesCT").setMask("DATE", "", "", "divRotina");
		var rNrctrato = $('label[for="nrctremp"]', '#frmPagPrejCC');
		rNrctrato.css({ 'width': '70px' });
		var cNrctrato = $('#nrctremp', '#frmPagPrejCC');
		cNrctrato.css({ 'width': '120px' }).addClass('inteiro').attr('maxlength', '14');
		cNrctrato.habilitaCampo();

	}else if( nomeForm == 'frmMedias' ){

		var altura = '237px';

		var cTodos  = $('input','#'+nomeForm);

		var Lperiodo  = $('label[for="period0"], label[for="period1"], label[for="period2"], label[for="period3"], label[for="period4"], label[for="period5"], label[for="period6"]','#'+nomeForm); 
		var Cperiodo  = $('#period0, #period1, #period2, #period3, #period4, #period5, #period6','#'+nomeForm);

		var Lvlsmnmes = $('label[for="vlsmnmes"]','#'+nomeForm);
		var Cvlsmnmes = $('#vlsmnmes','#'+nomeForm);

		var Lvlsmnesp = $('label[for="vlsmnesp"]','#'+nomeForm);
		var Cvlsmnesp = $('#vlsmnesp','#'+nomeForm);

		var Lvlsaqmax = $('label[for="vlsaqmax"]','#'+nomeForm);
		var Cvlsaqmax = $('#vlsaqmax','#'+nomeForm);

		var Lqtdiaute = $('label[for="qtdiaute"]','#'+nomeForm);
		var Cqtdiaute = $('#qtdiaute','#'+nomeForm);

		var Lvltsddis = $('label[for="vltsddis"]','#'+nomeForm);
		var Cvltsddis = $('#vltsddis','#'+nomeForm);
		
		var Lqtdiauti = $('label[for="qtdiauti"]','#'+nomeForm);
		var Cqtdiauti = $('#qtdiauti','#'+nomeForm);
		
		var Lvlsmdtri = $('label[for="vlsmdtri"]','#'+nomeForm);
		var Cvlsmdtri = $('#vlsmdtri','#'+nomeForm);
		
		var Lvlsmdsem = $('label[for="vlsmdsem"]','#'+nomeForm);
		var Cvlsmdsem = $('#vlsmdsem','#'+nomeForm);
		
		Lperiodo.addClass('rotulo').css('width','80px');
		Lvlsmnmes.css('width','160px');
		Lvlsmnesp.css('width','160px');
		Lvlsaqmax.css('width','160px');
		Lqtdiaute.css('width','160px');
		Lqtdiauti.css('width','160px');
		Lvltsddis.addClass('rotulo').css('width','80px');
		Lvlsmdtri.addClass('rotulo').css('width','80px');
		Lvlsmdsem.addClass('rotulo').css('width','80px');
				
		Cvlsmnmes.css('width','80px');
		Cvlsmnesp.css('width','80px');
		Cvlsaqmax.css('width','80px');
		Cqtdiaute.css('width','80px');
		Cqtdiauti.css('width','80px');
		Cvltsddis.css('width','80px');
		Cvlsmdtri.css('width','80px');
		Cvlsmdsem.css('width','80px');
				
		Cperiodo.css('width','80px');
		
		cTodos.desabilitaCampo();
	
	} else if ( nomeForm == 'frmExtrato' ) {

		// rotulos
		rDtiniper	= $('label[for="dtiniper"]', '#'+nomeForm);	
		rDtfimper	= $('label[for="dtfimper"]', '#'+nomeForm);	
		rInisenta	= $('label[for="inisenta"]', '#'+nomeForm);
		rInrelext	= $('label[for="inrelext"]', '#'+nomeForm);
		
		rDtiniper.addClass('rotulo').css({'width':'170px'});
		rDtfimper.addClass('rotulo-linha');
		rInisenta.addClass('rotulo').css({'width':'170px'});
		rInrelext.addClass('rotulo').css({'width':'170px'});
		
		// campos
		cDtiniper	= $('#dtiniper', '#'+nomeForm);
		cDtfimper   = $('#dtfimper', '#'+nomeForm);
		cInisenta   = $('#inisenta', '#'+nomeForm);
		cInrelext   = $('#inrelext', '#'+nomeForm);

		cDtiniper.css({'width':'65px'});
		cDtfimper.css({'width':'65px'});
		cInisenta.css({'width':'50px'});
		cInrelext.css({'width':'140px'});

		// botao
		btImprimir = $('label[for="botao"]', '#'+nomeForm);
		btImprimir.css({'width':'170px'});
		
		$('input, select', '#'+nomeForm).habilitaCampo();
		
	} else if ( nomeForm == 'frmCPMF' ) {


		rExecicio  	= $('label[for="execicio"]' ,'#'+nomeForm);
		rBase1		= $('label[for="base1"]'	,'#'+nomeForm);	
		rBase2		= $('label[for="base2"]'	,'#'+nomeForm);	
		rValor1     = $('label[for="valor1"]'  	,'#'+nomeForm);
		rValor2     = $('label[for="valor2"]'  	,'#'+nomeForm);
	
		rExecicio.addClass('rotulo').css({'width':'338px'});
		rBase1.addClass('rotulo').css({'width':'170px'});
		rBase2.addClass('rotulo-linha').css({'width':'10px'});
		rValor1.addClass('rotulo').css({'width':'170px'});
		rValor2.addClass('rotulo-linha').css({'width':'10px'});
		
		cBase1		= $('#base1' , '#'+nomeForm);
		cBase2		= $('#base2' , '#'+nomeForm);
		cValor1		= $('#valor1', '#'+nomeForm);
		cValor2		= $('#valor2', '#'+nomeForm);
		
		cBase1.css({'width':'75px', 'text-align':'right'});	
		cBase2.css({'width':'75px', 'text-align':'right'});
		cValor1.css({'width':'75px', 'text-align':'right'});
		cValor2.css({'width':'75px', 'text-align':'right'});
		
		$('input', '#'+nomeForm).desabilitaCampo();
	
	
	} else if (nomeForm == 'frmSaldoAnt') {

        var altura = '257px';

        // rotulos
        rDtrefere = $('label[for="dtrefere"]', '#' + nomeForm);
        rVlsddisp = $('label[for="vlsddisp"]', '#' + nomeForm);
        rVlsdbloq = $('label[for="vlsdbloq"]', '#' + nomeForm);
        rVlsdblpr = $('label[for="vlsdblpr"]', '#' + nomeForm);
        rVlsdblfp = $('label[for="vlsdblfp"]', '#' + nomeForm);
        rVlsdchsl = $('label[for="vlsdchsl"]', '#' + nomeForm);
        rVlsdindi = $('label[for="vlsdindi"]', '#' + nomeForm);
        rVlstotal = $('label[for="vlstotal"]', '#' + nomeForm);
        rVllimcre = $('label[for="vllimcre"]', '#' + nomeForm);
		rVlsldctr = $('label[for="vlsldctr"]', '#' + nomeForm);
        rVlblqjud = $('label[for="vlblqjud"]', '#' + nomeForm);
        rVllimcpa = $('label[for="vllimcpa"]', '#' + nomeForm);
        

        rDtrefere.addClass('rotulo').css({ 'width': '200px' });
        rVlsddisp.addClass('rotulo').css({ 'width': '200px' });
        rVlsdbloq.addClass('rotulo').css({ 'width': '200px' });
        rVlsdblpr.addClass('rotulo').css({ 'width': '200px' });
        rVlsdblfp.addClass('rotulo').css({ 'width': '200px' });
        rVlsdchsl.addClass('rotulo').css({ 'width': '200px' });
        rVlsdindi.addClass('rotulo').css({ 'width': '200px' });
        rVlstotal.addClass('rotulo').css({ 'width': '200px' });
        rVllimcre.addClass('rotulo').css({ 'width': '200px' });
		rVlsldctr.addClass('rotulo').css({ 'width': '200px' });
        rVlblqjud.addClass('rotulo').css({ 'width': '200px' });
        rVllimcpa.addClass('rotulo').css({ 'width': '200px' });
	
        // campos
        cDtrefere = $('#dtrefere', '#' + nomeForm);
        cVlsddisp = $('#vlsddisp', '#' + nomeForm);
        cVlsdbloq = $('#vlsdbloq', '#' + nomeForm);
        cVlsdblpr = $('#vlsdblpr', '#' + nomeForm);
        cVlsdblfp = $('#vlsdblfp', '#' + nomeForm);
        cVlsdchsl = $('#vlsdchsl', '#' + nomeForm);
        cVlsdindi = $('#vlsdindi', '#' + nomeForm);
        cVlstotal = $('#vlstotal', '#' + nomeForm);
        cVllimcre = $('#vllimcre', '#' + nomeForm);
		cVlsldctr = $('#vlsldctr', '#' + nomeForm);
        cVlblqjud = $('#vlblqjud', '#' + nomeForm);
        cVllimcpa = $('#vllimcpa', '#' + nomeForm);

        cDtrefere.css({ 'width': '75px' });
        cVlsddisp.css({ 'width': '75px', 'text-align': 'right' });
        cVlsdbloq.css({ 'width': '75px', 'text-align': 'right' });
        cVlsdblpr.css({ 'width': '75px', 'text-align': 'right' });
        cVlsdblfp.css({ 'width': '75px', 'text-align': 'right' });
        cVlsdchsl.css({ 'width': '75px', 'text-align': 'right' });
        cVlsdindi.css({ 'width': '75px', 'text-align': 'right' });
        cVlstotal.css({ 'width': '75px', 'text-align': 'right' });
        cVllimcre.css({ 'width': '75px', 'text-align': 'right' });
		cVlsldctr.css({ 'width': '75px', 'text-align': 'right' });
        cVlblqjud.css({ 'width': '75px', 'text-align': 'right' });
        cVllimcpa.css({ 'width': '75px', 'text-align': 'right' });
		
		$('input, select', '#'+nomeForm).desabilitaCampo();
		cDtrefere.habilitaCampo();

	} else if ( nomeForm == 'frmExtCash' ) {

		var altura = '210px';

		if ( $.browser.msie ) {
			$('#'+nomeForm).css('margin-bottom','-10px');
		}
		
		// rotulo
		rDtrefere = $('label[for="dtrefere"]', '#'+nomeForm);
		rDtrefere.addClass('rotulo').css({'width':'50px'});
		
		// campos
		cDtrefere = $('#dtrefere', '#'+nomeForm);
		cDtrefere.addClass('campo').css({'width':'65px'});
		
		cDtrefere.unbind('keypress').bind('keypress',function(e) {
			if (e.keyCode == 13) {
				$(this).next().trigger('click');
				return false;
			}
			
			return true;
		});
			
		// tabela	
		var divRegistro = $('div.divRegistros');		
		var tabela      = $('table', divRegistro );
		var linha       = $('table > tbody > tr', divRegistro );
				
		divRegistro.css({'height':'160px','width':'490px'});
		
		var ordemInicial = new Array();
		ordemInicial = [[0,0]];
				
		var arrayLargura = new Array();
		arrayLargura[0] = '56px';
		arrayLargura[1] = '56px';
		arrayLargura[2] = '30px';
		arrayLargura[3] = '230px';
		
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'center';
		arrayAlinha[2] = 'center';
		arrayAlinha[3] = 'left';
		arrayAlinha[4] = 'center';
		
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha );
		
	}else if(nomeForm == 'frmCreditosRecebidos' ) {
		
		$('label','#frmCreditosRecebidos').each( function(i) {
			
			// rotulo
			$(this).addClass('rotulo').css({'width':'220px'});			
						
		});
		
		$('input','#frmCreditosRecebidos').each( function(i) {
			
			// rotulo
			$(this).addClass('campo').css({'width':'100px','text-align':'right'}).desabilitaCampo();		
						
		});		
		
	} else if (nomeForm == 'frmDadosDetalhesAtraso') {
		var divForm = '#' + nomeForm;

		$(divForm + ' .rotulo').css({'width':'180px'});
		$(divForm + ' .campo').css({'width':'100px','text-align':'right'}); //.desabilitaCampo();

        $('input, select', divForm).desabilitaCampo();
	}

	$('#divConteudoOpcao').css('height',altura);
	layoutPadrao();

	return false;
}

function selecionaExtrato(dshistor,dtlibera) {

	$("#dshistor","#complemento").html(dshistor);
	$("#dtlibera","#complemento").html(dtlibera);

}

function mostraDetalhesAtraso() {
	showMsgAguardo('Aguarde, abrindo detalhes...');

    exibeRotina($('#divUsoGenerico'));

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/dep_vista/detalhes_atraso.php',
        data: {
            nrdconta: nrdconta,
			cdcooper: cdcooper,
            redirect: 'html_ajax'
            },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','N?o foi poss?vel concluir a requisi??o.','Alerta - Aimaro',"blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
			//console.log(response);
            $('#divUsoGenerico').html(response);
            //layoutPadrao();
            hideMsgAguardo();
            bloqueiaFundo($('#divUsoGenerico'));
        }
    });
}

function mostraDetalhesCT() {
	showMsgAguardo('Aguarde, abrindo detalhes da conta transitoria...');

	exibeRotina($('#divUsoGenerico'));

	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atenda/dep_vista/detalhes_conta_transitoria.php',
		data: {
			nrdconta: nrdconta,
			cdcooper: cdcooper,
			dtiniper: $("#dtiniper", "#frmDetalhesCT").val(),
			dtfimper: $("#dtfimper", "#frmDetalhesCT").val(),
			redirect: 'html_ajax'
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'N?o foi poss?vel concluir a requisi??o.', 'Alerta - Aimaro', "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function (response) {
			$('#divUsoGenerico').html(response);
			//layoutPadrao();
			hideMsgAguardo();
			bloqueiaFundo($('#divUsoGenerico'));
		}
	});
}

// Fun??o que formata a tabela lan?amentos Contra Transit?ria
function formataLancamentosCT() {

	var divRegistro = $('div.divRegistros', '#divTabContraOrdens');
	var tabela = $('table', divRegistro);
	var linha = $('table > tbody > tr', divRegistro);

	divRegistro.css({ 'height': '235px', 'width': '650px' });

	var ordemInicial = new Array();


	var arrayLargura = new Array();
	arrayLargura[0] = '67px';
	arrayLargura[1] = '100px';
	arrayLargura[2] = '100px';
	arrayLargura[3] = '100px';
	arrayLargura[4] = '100px';
	arrayLargura[5] = '100px';


	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'center';
	arrayAlinha[3] = 'center';
	arrayAlinha[4] = 'center';
	arrayAlinha[5] = 'center';

	tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);
	ajustarCentralizacao();
	return false;
}
/*
Inicio das rotinas relacionadas ao pagamento de prejuizo
*/
function mostraPagamentoPrejuzCC() {

	showMsgAguardo('Aguarde, abrindo detalhes da conta transitoria...');

	exibeRotina($('#divUsoGenerico'));

	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atenda/dep_vista/pagamento_prejuz_cc.php',
		data: {
			nrdconta: nrdconta,
			cdcooper: cdcooper,
			redirect: 'html_ajax'
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'N?o foi poss?vel concluir a requisi??o.', 'Alerta - Aimaro', "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function (response) {
			hideMsgAguardo();
			$('#divUsoGenerico').html(response);
			bloqueiaFundo($('#divUsoGenerico'));
		}
	});
}

function mostraLiberacaoCC() {

	showMsgAguardo('Aguarde, abrindo detalhes da conta transitoria...');

	exibeRotina($('#divUsoGenerico'));

	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atenda/dep_vista/liberacao_cc.php',
		data: {
			nrdconta: nrdconta,
			cdcooper: cdcooper,
			redirect: 'html_ajax'
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'N?o foi poss?vel concluir a requisi??o.', 'Alerta - Aimaro', "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function (response) {
			hideMsgAguardo();
			$('#divUsoGenerico').html(response);
			bloqueiaFundo($('#divUsoGenerico'));
		}
	});
}

function mostraPagamentoEmp(nrctremp){
	showMsgAguardo('Aguarde, abrindo detalhes da conta transitoria...');

	exibeRotina($('#divUsoGenerico'));

	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atenda/dep_vista/emprestimos_cc.php',
		data: {
			nrdconta: nrdconta,
			cdcooper: cdcooper,
			redirect: 'html_ajax'
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'N?o foi poss?vel concluir a requisi??o.', 'Alerta - Aimaro', "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function (response) {
			hideMsgAguardo();
			$('#divUsoGenerico').html(response);
			bloqueiaFundo($('#divUsoGenerico'));
			if(nrctremp != null){
				$('#nrctremp', '#frmEmpCC').val(nrctremp);
			}
		}
	});
}

function formataPagamentoPrejuzCC() {
	var Lvlsdprej = $('label[for="vlsdprej"]', '#frmPagPrejCC');
	var Cvlsdprej = $('#vlsdprej', '#frmPagPrejCC');
	var Ljuremune = $('label[for="juremune"]', '#frmPagPrejCC');
	var Cjuremune = $('#juremune', '#frmPagPrejCC');
	var Lvlttjurs = $('label[for="vlttjurs"]', '#frmPagPrejCC');
	var Cvlttjurs = $('#vlttjurs', '#frmPagPrejCC');
	var Lvltotiof = $('label[for="vltotiof"]', '#frmPagPrejCC');
	var Cvltotiof = $('#vltotiof', '#frmPagPrejCC');
	var Lvlpagto = $('label[for="vlpagto"]', '#frmPagPrejCC');
	var Cvlpagto = $('#vlpagto', '#frmPagPrejCC');
	var Lvlabono = $('label[for="vlabono"]', '#frmPagPrejCC');
	var Cvlabono = $('#vlabono', '#frmPagPrejCC');
	var Lvlsaldo = $('label[for="vlsaldo"]', '#frmPagPrejCC');
	var Cvlsaldo = $('#vlsaldo', '#frmPagPrejCC');

	Lvlsdprej.addClass('rotulo').css({ 'width': '130px' });
	Cvlsdprej.css({ 'width': '110px', 'text-align': 'right' }).addClass('monetario');
	Ljuremune.addClass('rotulo').css({ 'width': '130px' });
	Cjuremune.css({ 'width': '110px', 'text-align': 'right' }).addClass('monetario');
	Lvlttjurs.addClass('rotulo').css({ 'width': '130px' });
	Cvlttjurs.css({ 'width': '110px', 'text-align': 'right' }).addClass('monetario');
	Lvltotiof.addClass('rotulo').css({ 'width': '130px' });
	Cvltotiof.css({ 'width': '110px', 'text-align': 'right' }).addClass('monetario');
	Lvlpagto.addClass('rotulo').css({ 'width': '130px' });
	Cvlpagto.css({ 'width': '110px', 'text-align': 'right' }).addClass('monetario');
	Lvlabono.addClass('rotulo').css({ 'width': '130px' });
	Cvlabono.css({ 'width': '110px', 'text-align': 'right' }).addClass('monetario');
	Lvlsaldo.addClass('rotulo').css({ 'width': '130px' });
	Cvlsaldo.css({ 'width': '110px', 'text-align': 'right' }).addClass('monetario');

	Cvlpagto.setMask('DECIMAL', 'zzz.zzz.zz9,99', '.', ',');
	Cvlabono.setMask('DECIMAL', 'zzz.zzz.zz9,99', '.', ',');
}

function formataLiberacaoCC() {
	var Lvlpagto = $('label[for="vlpagto"]', '#frmLibCC');
	var Cvlpagto = $('#vlpagto', '#frmLibCC');

	Lvlpagto.addClass('rotulo').css({ 'width': '45px' });
	Cvlpagto.css({ 'width': '110px', 'text-align': 'right' }).addClass('monetario');

	Cvlpagto.setMask('DECIMAL', 'zzz.zzz.zz9,99', '.', '');
}

function formataEmprestimo() {
	var Lvlpagto = $('label[for="vlpagto"]', '#frmEmpCC');
	var Cvlpagto = $('#vlpagto', '#frmEmpCC');

	Lvlpagto.addClass('rotulo').css({ 'width': '80px' });
	Cvlpagto.css({ 'width': '110px', 'text-align': 'right' }).addClass('monetario');

	Cvlpagto.setMask('DECIMAL', 'zzz.zzz.zz9,99', '.', '');

	var Lvlabono = $('label[for="vlabono"]', '#frmEmpCC');
	var Cvlabono = $('#vlabono', '#frmEmpCC');

	Lvlabono.addClass('rotulo').css({ 'width': '80px' });
	Cvlabono.css({ 'width': '110px', 'text-align': 'right' }).addClass('monetario');

	Cvlabono.setMask('DECIMAL', 'zzz.zzz.zz9,99', '.', '');

	var Lnrctremp = $('label[for="nrctremp"]', '#frmEmpCC');
	var Cnrctremp = $('#nrctremp', '#frmEmpCC');

	Lnrctremp.addClass('rotulo').css({ 'width': '80px' });
	Cnrctremp.css({ 'width': '110px', 'text-align': 'right' }).attr('maxlength', '13');

	Cnrctremp.setMask('INTEGER', 'z.zzz.zzz.zz9', '.', '');

	Lvlabono.hide();
	Cvlabono.hide();

}

// início contrato
function mostraContrato(campo, formulario) {

	showMsgAguardo('Aguarde, buscando ...');

	// Executa script de confirmação através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atenda/dep_vista/contrato.php',
		data: {
			redirect: 'html_ajax'
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Aimaro', "unblockBackground()");
		},
		success: function (response) {
			$('#divUsoGenerico').html(response);
			buscaContrato(campo, formulario, nrdconta);
			return false;
		}
	});

	return false;

}

function buscaContrato(campo, formulario, nrdconta) {

	showMsgAguardo('Aguarde, buscando ...');
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atenda/dep_vista/busca_contrato.php',
		data: {
			nrdconta: nrdconta,
			redirect: 'script_ajax'
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Aimaro', "unblockBackground();");
		},
		success: function (response) {

			if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
				try {
					$('#divConteudo').html(response);
					exibeRotina($('#divUsoGenerico'));
					formataContrato(campo, formulario);
					return false;
				} catch (error) {
					hideMsgAguardo();
					showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'unblockBackground()');
				}
			} else {
				try {
					eval(response);
				} catch (error) {
					hideMsgAguardo();
					showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'unblockBackground()');
				}
			}
		}
	});
	return false;
}

function formataContrato(campo, formulario) {

	var divRegistro = $('div.divRegistros', '#divContrato');
	var tabela = $('table', divRegistro);
	var linha = $('table > tbody > tr', divRegistro);

	divRegistro.css({ 'height': '120px', 'width': '500px' });

	var ordemInicial = new Array();
	ordemInicial = [[0, 0]];

	var arrayLargura = new Array();
	arrayLargura[0] = '60px';
	arrayLargura[1] = '62px';
	arrayLargura[2] = '80px';
	arrayLargura[3] = '60px';
	arrayLargura[4] = '80px';
	arrayLargura[5] = '38px';


	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'right';
	arrayAlinha[6] = 'right';

	var metodoTabela = "selecionaContrato('" + campo + "','" + formulario + "');";

	tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

	hideMsgAguardo();
	//bloqueiaFundo($('#divUsoGenerico1'));

	return false;
}

function selecionaContrato(campo, formulario) {

	if ($('table > tbody > tr', '#divContrato').hasClass('corSelecao')) {

		$('table > tbody > tr', '#divContrato').each(function () {
			if ($(this).hasClass('corSelecao')) {				
               	mostraPagamentoEmp($('#nrctremp', $(this)).val());				
                consultaSituacaoEmpr($('#nrctremp', $(this)).val());
			}
		});
	}

	return false;

}
//fim contrato

function retiraMascara(numero) {
	numero = parseFloat(numero.replace(".", "").replace(",", "."));
	return numero;
}

function calcularSaldo() {
	
	var vlsdprej = retiraMascara($('#vlsdprej', '#frmPagPrejCC').val()) || 0;
	var juremune = retiraMascara($('#juremune', '#frmPagPrejCC').val()) || 0;
	var vltotiof = retiraMascara($('#vltotiof', '#frmPagPrejCC').val()) || 0;
	var vlpagto = retiraMascara($('#vlpagto', '#frmPagPrejCC').val()) || 0;
	var vlabono = retiraMascara($('#vlabono', '#frmPagPrejCC').val()) || 0;

	var vlsaldo = (vlsdprej + vltotiof + juremune) - (vlpagto + vlabono);
	
	$('#vlsaldo', '#frmPagPrejCC').val(numberToReal(vlsaldo));
}

function numberToReal(numero) {
	var numero = numero.toFixed(2).split('.');
	numero[0] = numero[0].split(/(?=(?:...)*$)/).join('.');
	return numero.join(',');
}

function efetuaPagamentoPrejuizoCC() {

  var vlpagto = $('#vlpagto', '#frmPagPrejCC').val() || 0;
	var vlabono = $('#vlabono', '#frmPagPrejCC').val() || 0;
  
	if (validaPagamentoPreju() == false) {
		return false;
	}	

	showMsgAguardo('Aguarde, efetuando pagamento...');
	exibeRotina($('#divUsoGenerico'));

	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atenda/dep_vista/paga_prejuz_cc.php',
		data: {
			nrdconta: nrdconta,
			vlrpagto: vlpagto,
			vlrabono: vlabono,
			redirect: 'html_ajax'
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Aimaro', "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function (response) {
			eval(response);			
		}
	});

	return false;
}

function efetuaLiberacaoCC(vlPagto) {
    
	showMsgAguardo('Aguarde, efetuando liberação...');  
	exibeRotina($('#divUsoGenerico'));
        
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atenda/dep_vista/paga_liberacao_cc.php',
		data: {
			nrdconta: nrdconta,
			cdcooper: cdcooper,
			vlrpagto: vlPagto,
			redirect: 'html_ajax'
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function (response) {
			if (response.indexOf('showError("error"') == -1) {
				showError("inform", 'Libera&ccedil;&atilde;o efetuada com sucesso.', "Alerta - Aimaro", mostraDetalhesCT());
			} else {
				eval(response);
			}
		}
	});    
	
	return false;

}

function efetuaPagamentoEmp(nrctrato, vlpagto, vlabono) {
	
	showMsgAguardo('Aguarde, efetuando pagamento...');
	exibeRotina($('#divUsoGenerico'));

	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atenda/dep_vista/paga_emprestimo.php',
		data: {
			nrdconta: nrdconta,
			cdcooper: cdcooper,
			nrctremp: nrctrato,
			vlrpagto: vlpagto,
			vlrabono: vlabono,
			redirect: 'html_ajax'
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Aimaro', "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function (response) {
			eval(response);			
		}
	});
	
	return false;

}

function consultaSituacaoEmpr(nrctremp){

	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atenda/dep_vista/consulta_situacao_empr.php',
		data: {
			nrdconta: nrdconta,
			cdcooper: cdcooper,
			nrctremp: nrctremp,			
			redirect: 'html_ajax'
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Aimaro', "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function (response) {			
			eval(response);			
		}
	});
	
	return false;

}

function validaPagamentoPreju() {
	var vlpagto = retiraMascara($('#vlpagto', '#frmPagPrejCC').val()) || 0;
	var vlabono = retiraMascara($('#vlabono', '#frmPagPrejCC').val()) || 0;
	var vlsaldo = retiraMascara($('#vlsaldo', '#frmPagPrejCC').val()) || 0;

	if (vlpagto <= 0 && vlabono <= 0) {
		showError("inform", 'Informe o valor do pagamento ou valor de abono.', "Alerta - Aimaro");
		return false;
	} else if (vlsaldo < 0) {
		showError("inform", 'O valor do pagamento não pode ultrapassar o valor principal.', "Alerta - Aimaro");
		return false;
	} else {
		return true;
	}
}

function validaLiberacaoSaque() {
	var vlpagto = retiraMascara($('#vlpagto', '#frmPagPrejCC').val()) || 0;

	if (vlpagto <= 0) {
		showError("inform", 'Informe o valor a ser liberado para saque.', "Alerta - Aimaro");
		return false;
	} else {
		return true;
	}
}

/*
Final das rotinas relacionadas ao pagamento de prejuizo
*/

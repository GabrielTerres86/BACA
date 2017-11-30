/**********************************************************************
  Fonte: capital.js                                                
  Autor: David													   
  Data : Outubro/2007                 Ultima Alteracao: 23/03/2017
                                                                   
  Objetivo  : Biblioteca de funcoes da rotina Capital da tela      
              ATENDA                                               
                                                                   	 
  Alteracoes: 10/07/2012 - Ajuste para submeter impressao em       
  						   cancelarPlanoAtual e imprimeNovoPlano   
  						   (Jorge).			   					   
        														   					
  			  04/06/2013 - Incluir label[for="vlblqjud"] em        
  						   controlaLayout (Lucas R.)           	   
  																   	
              26/02/2014 - Adicionado campos 'cdtipcor' e          
                           'vlcorfix' (tratamento p/ reajuste do   
                           valor do plano de capital). (Fabricio)  

			  30/09/2015 - Ajuste para inclusão das novas telas "Produtos"
				           (Gabriel - Rkam -> Projeto 217).			  
					
		      25/07/2016 - Alterado função controlaFoco.
		                   (Evandro - RKAM)	.	  						   
					
              23/03/2017 - Auste para solicitar a senha do cartão magnético do cooperado
                           e não gerar termo 
                           (Jonata - RKAM / M294).
 					
*************************************************************************/

var callafterCapital = '';

var lstLancamentos = new Array();
var lstEstorno = new Array();
var glb_opcao = "";

var vintegra = 0;


// Fun&ccedil;&atilde;o para acessar op&ccedil;&otilde;es da rotina
function acessaOpcaoAba(nrOpcoes, id, opcao) {
		
	glb_opcao = opcao;
	
	if (opcao == "@") {	// Op&ccedil;&atilde;o Principal
		var msg = ", carregando dados de capital";
		var UrlOperacao = UrlSite + "telas/atenda/capital/principal.php";
	} else if (opcao == "S") { // Op&ccedil;&atilde;o Subscri&ccedil;&atilde;o Inicial
		var msg = ", carregando subscri&ccedil;&atilde;o inicial";
		var UrlOperacao = UrlSite + "telas/atenda/capital/subscricao_inicial.php";
	} else if (opcao == "E") { // Op&ccedil;&atilde;o Extrato
		var msg = ", carregando extrato";
		var UrlOperacao = UrlSite + "telas/atenda/capital/extrato.php";
	} else if (opcao == "P") { // Op&ccedil;&atilde;o Plano de Capital
		var msg = ", carregando dados do plano";
		var UrlOperacao = UrlSite + "telas/atenda/capital/plano_de_capital.php";
	} else if (opcao == "I") { // Opcao Integralizacao
		var msg = ", carregando op&ccedil;&atilde;o de integraliza&ccedil;&atilde;o de cotas";
		var UrlOperacao = UrlSite + "telas/atenda/capital/integralizacao.php";
	} else if (opcao == "L") { // Opcao Estornar Integralizacao
		var msg = ", carregando lan&ccedil;amentos";
		var UrlOperacao = UrlSite + "telas/atenda/capital/buscar_integralizacoes.php";
		
		$("#divEstorno").html("");
	}
	
	if (opcao != "")
		// Mostra mensagem de aguardo
		showMsgAguardo("Aguarde" + msg + " ...");
	
	// Atribui cor de destaque para aba da op&ccedil;&atilde;o
	for (var i = 0; i < nrOpcoes; i++) {
		if (id == i) { // Atribui estilos para foco da op&ccedil;&atilde;o
            $("#linkAba" + id).attr("class", "txtBrancoBold");
            $("#imgAbaEsq" + id).attr("src", UrlImagens + "background/mnu_sle.gif");
            $("#imgAbaDir" + id).attr("src", UrlImagens + "background/mnu_sld.gif");
            $("#imgAbaCen" + id).css("background-color", "#969FA9");
			
			if (id == 5) {
				$('#divIntegralizacao').css({'display': 'block', 'height': '142px'});
				$('#divEstorno').css({'display': 'none'});
			} else
			if (id == 6) {
				lstLancamentos = "";
				lstEstorno = "";
                    $('#divIntegralizacao').css({ 'display': 'none' });
                    $('#divEstorno').css({ 'display': 'block' });
			}
			
			continue;			
		}
		
        $("#linkAba" + i).attr("class", "txtNormalBold");
        $("#imgAbaEsq" + i).attr("src", UrlImagens + "background/mnu_nle.gif");
        $("#imgAbaDir" + i).attr("src", UrlImagens + "background/mnu_nld.gif");
        $("#imgAbaCen" + i).css("background-color", "#C6C8CA");
	}

	if (opcao == "E") { // Opção Extrato
		$('.divRegistros').remove();	
		
		// Carrega conte&uacute;do da op&ccedil;&atilde;o atrav&eacute;s de ajax
		$.ajax({		
			type: "POST", 
			dataType: "html",
			url: UrlOperacao,
			data: {
				nrdconta: nrdconta,
                dtiniper: $("#dtiniper", "#frmExtCapital").val(),
                dtfimper: $("#dtfimper", "#frmExtCapital").val(),
				redirect: "html_ajax"
			},
            error: function (objAjax, responseError, objExcept) {
				hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			},
            success: function (response) {
				$("#divConteudoOpcao").html(response);
                controlaFoco(opcao);
			}				
		});
	} else if (opcao != "") { // Demais Opções		
		// Carrega conte&uacute;do da op&ccedil;&atilde;o atrav&eacute;s de ajax
		$.ajax({		
			type: "POST", 
			dataType: "html",
			url: UrlOperacao,
			data: {
				nrdconta: nrdconta,
				redirect: "html_ajax"
			},
            error: function (objAjax, responseError, objExcept) {
				hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			},
            success: function (response) {
				if (opcao == "L")
					eval(response);
				else
					$("#divConteudoOpcao").html(response);
					controlaFoco(opcao); 
			}				
		}); 
	}					
}


//Função para controle de navegação
function controlaFoco(opcao) {
    var IdForm = '';
    var formid;

    if (opcao == "@") { //Principal
        $('.FirstInput:first ').focus();
	}
    if (opcao == "P") { //Plano de capital
        $('#divConteudoOpcao').each(function () {
            formid = $('#divConteudoOpcao form');
            IdForm = $(formid).attr('id');//Seleciona o id do formulario
            if (IdForm == "frmNovoPlano") {
                $(this).find("#frmNovoPlano > :input").first().addClass("FirstInputModal").focus();
                $(this).find("#divBotoesSenha > :input[type=image]").addClass("FluxoNavega");
                $(this).find("#divBotoesSenha > :input[type=image]").last().addClass("LastInputModal");
                $(this).find("#divBotoesAutorizacao > :input[type=image]").addClass("FluxoNavega");
                $(this).find("#divBotoesAutorizacao > :input[type=image]").last().addClass("LastInputModal");
            };

            //Se estiver com foco na classe FluxoNavega
            $(".FluxoNavega").focus(function () {
                $(this).bind('keydown', function (e) {
                    if (e.keyCode == 13) {
                        $(this).click();
                        e.stopPropagation();
                        e.preventDefault();
	}
                });
            });


            //Fechar mensagem de erro
            $("#divError > :input[type=image]").focus(function () {
                $(this).bind('keydown', function (e) {
                    if (e.keyCode == 13) {
                        $(this).click();
                        return false;
                    };
                });
            });

            $(".FirstInputModal").focus();
        });
}	

    if (opcao == "E") { //Extrato
        $('#divConteudoOpcao').each(function () {
            formid = $('#divConteudoOpcao form');
            IdForm = $(formid).attr('id');//Seleciona o id do formulario
            if (IdForm == "frmExtCapital") {
                $(this).find("#frmExtCapital > :input").first().addClass("FirstInputModal").focus();
                $(this).find("#frmExtCapital > :input").addClass("FluxoNavega");
                $(this).find("#frmExtCapital > :input").last().addClass("LastInputModal");
            };

            //Se estiver com foco na classe FluxoNavega
            $(".FluxoNavega").focus(function () {
                $(this).bind('keydown', function (e) {
                    if (e.keyCode == 13) {
                        $(this).click();
                    }
                });
            });

            $(".FirstInputModal").focus();
        });
    }

    if (opcao == "I") { //Integralizar Cotas
        $('#divConteudoOpcao').each(function () {
            formid = $('#divConteudoOpcao form');
            IdForm = $(formid).attr('id');//Seleciona o id do formulario
            if (IdForm == "frmIntegraliza") {
                $(this).find("#frmIntegraliza > :input").first().addClass("FirstInputModal").focus();
                $(this).find("#frmIntegraliza > :input").last().addClass("LastInputModal");
            };

            //Se estiver com foco na classe LastInputModal
            $(".LastInputModal").focus(function () {
                $(this).bind('keydown', function (e) {
                    if (e.keyCode == 13) {
                        $(this).click();
                    }
                });
            });

            $(".FirstInputModal").focus();
        });
    }
}





// Fun&ccedil;&atilde;o para validar novo plano de capital
function validaNovoPlano(altera) {

	if (!altera)
		// Mostra mensagem de aguardo
		showMsgAguardo("Aguarde, validando novo plano ...");
	else
		showMsgAguardo("Aguarde, validando dados do plano ...");
	
	// Valida valor do plano
    if ($("#vlprepla", "#frmNovoPlano").val() == "" || !validaNumero($("#vlprepla", "#frmNovoPlano").val(), true, 0, 0) || ($("#vlprepla", "#frmNovoPlano").val() == "0,00")) {
		hideMsgAguardo();
        showError("error", "Valor do plano inv&aacute;lido.", "Alerta - Ayllos", "$('#vlprepla','#frmNovoPlano').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	} 
	
	// Valida valor da correcao, caso informado correcao por valor fixo
    if (($("#cdtipcor", "#frmNovoPlano").val() == 2) && ($("#vlcorfix", "#frmNovoPlano").val() == "0,00")) {
		hideMsgAguardo();
        showError("error", "Valor de corre&ccedil;&atilde;o inv&aacute;lido.", "Alerta - Ayllos", "$('#vlcorfix','#frmNovoPlano').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}

	// Valida quantidade de presta&ccedil;&otilde;es do plano
    if ($("#qtpremax", "#frmNovoPlano").val() == "" || !validaNumero($("#qtpremax", "#frmNovoPlano").val(), true, 0, 0)) {
		hideMsgAguardo();
        showError("error", "Quantidade presta&ccedil;&otilde;es inv&aacute;lida.", "Alerta - Ayllos", "$('#qtpremax','#frmNovoPlano').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	} 	
	
	// Valida data de in&iacute;cio do pagamento do plano
    if ($("#dtdpagto", "#frmNovoPlano").val() == "" || !validaData($("#dtdpagto", "#frmNovoPlano").val())) {
		hideMsgAguardo();
        showError("error", "Data de in&iacute;cio do plano inv&aacute;lida.", "Alerta - Ayllos", "$('#dtdpagto','#frmNovoPlano').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}
	
	// Executa script de valida&ccedil;&atilde;o do plano atrav&eacute;s de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/capital/validar_novo_plano.php",
		data: {
			nrdconta: nrdconta,
            vlprepla: $("#vlprepla", "#frmNovoPlano").val().replace(/\./g, ""),
            cdtipcor: $("#cdtipcor", "#frmNovoPlano").val(),
            vlcorfix: $("#vlcorfix", "#frmNovoPlano").val().replace(/\./g, ""),
            flgpagto: $("#flgpagto", "#frmNovoPlano").val(),
            qtpremax: $("#qtpremax", "#frmNovoPlano").val(),
            dtdpagto: $("#dtdpagto", "#frmNovoPlano").val(),
			flcancel: altera,
            tpautori: $("input[name='tpautori']:checked", "#frmNovoPlano").val(),
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

// Fun&ccedil;&atilde;o para cadastrar novo plano de capital
function cadastraNovoPlano(altera,tpautori) {

	if (!altera)
		// Mostra mensagem de aguardo
		showMsgAguardo("Aguarde, cadastrando novo plano ...");
	else
		showMsgAguardo("Aguarde, alterando dados do plano ...");
	
	// Valida valor do plano
    if ($("#vlprepla", "#frmNovoPlano").val() == "" || !validaNumero($("#vlprepla", "#frmNovoPlano").val(), true, 0, 0)) {
		hideMsgAguardo();
        showError("error", "Valor do plano inv&aacute;lido.", "Alerta - Ayllos", "$('#vlprepla','#frmNovoPlano').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	} 
	
	// Valida valor da correcao, caso informado correcao por valor fixo
    if ($("#cdtipcor", "#frmNovoPlano").val() == 2 && $("#vlcorfix", "#frmNovoPlano").val() == 0) {
		hideMsgAguardo();
        showError("error", "Valor de corre&ccedil;&atilde;o inv&aacute;lido.", "Alerta - Ayllos", "$('#vlcorfix','#frmNovoPlano').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}

	// Valida quantidade de presta&ccedil;&otilde;es do plano
    if ($("#qtpremax", "#frmNovoPlano").val() == "" || !validaNumero($("#qtpremax", "#frmNovoPlano").val(), true, 0, 0)) {
		hideMsgAguardo();
        showError("error", "Quantidade presta&ccedil;&otilde;es inv&aacute;lida.", "Alerta - Ayllos", "$('#qtpremax','#frmNovoPlano').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	} 	
	
	// Valida data de in&iacute;cio do pagamento do plano
    if ($("#dtdpagto", "#frmNovoPlano").val() == "" || !validaData($("#dtdpagto", "#frmNovoPlano").val())) {
		hideMsgAguardo();
        showError("error", "Data de in&iacute;cio do plano inv&aacute;lida.", "Alerta - Ayllos", "$('#dtdpagto','#frmNovoPlano').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}
	
	// Executa script de cadastro do plano atrav&eacute;s de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/capital/cadastrar_novo_plano.php",
		data: {
			nrdconta: nrdconta,
            vlprepla: $("#vlprepla", "#frmNovoPlano").val().replace(/\./g, ""),
            cdtipcor: $("#cdtipcor", "#frmNovoPlano").val(),
            vlcorfix: $("#vlcorfix", "#frmNovoPlano").val().replace(/\./g, ""),
            flgpagto: $("#flgpagto", "#frmNovoPlano").val(),
            qtpremax: $("#qtpremax", "#frmNovoPlano").val(),
            dtdpagto: $("#dtdpagto", "#frmNovoPlano").val(),
			flcancel: altera,
            executandoProdutos: executandoProdutos,
            tpautori: tpautori,
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


// Fun&ccedil;&atilde;o para cancelar plano de capital
function cancelarPlanoAtual() {
	
    showMsgAguardo("Aguarde, cancelando plano ...");

    // Executa script de cancelamento do plano atrav&eacute;s de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/capital/excluir_novo_plano.php",
        data: {
            nrdconta: nrdconta,
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


// Fun&ccedil;&atilde;o para cancelar plano de capital
function excluirPlano() {
    
	// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
	blockBackground(parseInt($('#divRotina').css('z-index')));
    $("#nrdconta", "#frmTermoCancela").val(nrdconta);
	
	var action = $("#frmTermoCancela").attr("action");
	var callafter = "blockBackground(parseInt($('#divRotina').css('z-index')));";
	
    carregaImpressaoAyllos("frmTermoCancela", action, callafter);

}

// Fun&ccedil;&atilde;o para imprimir termo de autoriza&ccedil;&atilde;o do novo plano de capital em PDF
function imprimeNovoPlano() {
	
    $("#nrdconta", "#frmTermoAutoriza").val(nrdconta);
	
    var action = $("#frmTermoAutoriza").attr("action");
	var callafter = "blockBackground(parseInt($('#divRotina').css('z-index')));";
	
	if (executandoProdutos) { 
		callafter = "encerraRotina();";
	} else {
		if (callafterCapital != '') {
			callafter = callafterCapital;
		}	
	}
	
    carregaImpressaoAyllos("frmTermoAutoriza", action, callafter);
}	

//
function controlaLayout(operacao) {	
		
    altura = '170px';
	largura = '425px';
	
	// Operação consultando
    if (in_array(operacao, ['SUBS_INICIAL'])) {
	
		var divRegistro = $('div.divRegistros');		
        var tabela = $('table', divRegistro);
		
        divRegistro.css('height', '149px');
		
		var ordemInicial = new Array();
        ordemInicial = [[0, 0]];
		
		var arrayLargura = new Array();
		arrayLargura[0] = '100px';
		arrayLargura[1] = '100px';
		arrayLargura[2] = '70px';

		
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'center';
		arrayAlinha[2] = 'right';
		arrayAlinha[3] = 'right';
		
        tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');
		
    } else if (in_array(operacao, ['PRINCIPAL'])) {

		nomeForm = 'frmDadosCapital';		
        altura = '133px';
        largura = '425px';

        $('#' + nomeForm).css('margin-top', '2px')
		
        var rRotulos = $('label[for="vlcaptal"],label[for="vldcotas"],label[for="vlblqjud"],label[for="dspagcap"],label[for="vlmoefix"],label[for="cdagenci"]', '#' + nomeForm);
        var rBanco = $('label[for="cdbccxlt"]', '#' + nomeForm);
        var rLote = $('label[for="nrdolote"]', '#' + nomeForm);
        var rRotuloLinha = $('label[for="nrctrpla"],label[for="vlprepla"],label[for="qtprepag"],label[for="dtinipla"]', '#' + nomeForm);
		
        var cTodos = $('select,input', '#' + nomeForm);

        var cPacBcLot = $('#cdagenci,#cdbccxlt,#nrdolote', '#' + nomeForm);
				

        cTodos.addClass('campo').css('width', '100px');
        cPacBcLot.addClass('campo').css('width', '55px');
	
        rRotulos.addClass('rotulo').css('width', '115px');
        rRotuloLinha.addClass('rotulo-linha').css('width', '95px');
        rBanco.addClass('rotulo-linha').css('width', '80px');
        rLote.addClass('rotulo-linha').css('width', '44px');
		
		cTodos.desabilitaCampo();
	
    } else if (in_array(operacao, ['PLANO_CAPITAL'])) {
	
		nomeForm = 'frmNovoPlano';		
        altura = '240px';
        largura = '425px';

        $('#' + nomeForm).css('margin-top', '4px')
		
        var cTodos = $('select,input', '#' + nomeForm);
        cTodos.addClass('').css('width', '195px');
		
        var rRotulos = $('label[for="vlprepla"],label[for="cdtipcor"],label[for="vlcorfix"],label[for="flgpagto"],label[for="qtpremax"],label[for="dtdpagto"],label[for="dtultatu"],label[for="dtproatu"],label[for="tpautori"]', '#' + nomeForm);
        var rSenha = $('label[for="senha"]', '#' + nomeForm);
        var rAutorizacao = $('label[for="autorizacao"]', '#' + nomeForm);
        var cDeb = $('#flgpagto', '#' + nomeForm);
        var cData = $('#dtdpagto,#dtultatu,#dtproatu', '#' + nomeForm);
        var cQtpremax = $('#qtpremax', '#' + nomeForm);
        var cCdtipcor = $('#cdtipcor', '#' + nomeForm);
        var cDtdpagto = $("#dtdpagto", '#' + nomeForm);
        var cSenha = $('#senha', '#' + nomeForm);
        var cAutorizacao = $('#autorizacao', '#' + nomeForm);

        rSenha.css('width', '30px');
        rAutorizacao.css('width', '50px');

        cDeb.addClass('campo').css('width', '195px');
        cData.addClass('data').css('width', '195px');
        cSenha.css('width', '30px');
        cAutorizacao.css('width', '30px');

        rRotulos.addClass('rotulo').css('width', '160px');
		
        cSenha.click();

        cCdtipcor.unbind('keydown').bind('keydown', function (e) {
			if (e.keyCode == 13) {
				cDeb.focus();
				return false;
			}
		}); 
		
        cDeb.unbind('keydown').bind('keydown', function (e) {
			if (e.keyCode == 13) {
				cQtpremax.focus();
				return false;
			}
		}); 
				
        cDtdpagto.unbind('keydown').bind('keydown', function (e) {
			if (e.keyCode == 13) {
				validaNovoPlano(false);
				return false;
			}
		}); 

    } else if (in_array(operacao, ['EXTRATO'])) {

		nomeForm = 'frmExtCapital';
        altura = '195px';
		largura = '425px';

        if ($.browser.msie) {
            $('#' + nomeForm).css('margin-bottom', '-10px')
		}		
		
        var rPeriodo = $('label[for="dtperiod"]', '#' + nomeForm);
        rPeriodo.addClass('rotulo').css('width', '50px');
		
        var cDatas = $('#dtiniper,#dtfimper', '#' + nomeForm);
        cDatas.addClass('data campo').css('width', '70px');
		
        var rPerioMe = $('label[for="dtperime"]', '#' + nomeForm);
        rPerioMe.addClass('rotulo-linha').css('width', '7px');
	
		var divRegistro = $('div.divRegistros');		
        var tabela = $('table', divRegistro);
		
        divRegistro.css('height', '149px');
		
		var ordemInicial = new Array();
        ordemInicial = [[0, 0]];
		
		var arrayLargura = new Array();
		arrayLargura[0] = '55px';
		arrayLargura[1] = '100px';
		arrayLargura[2] = '60px';
		arrayLargura[3] = '25px';
		arrayLargura[4] = '50px';

		var arrayAlinha = new Array();
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'left';
		arrayAlinha[2] = 'right';
		arrayAlinha[3] = 'center';
		arrayAlinha[4] = 'right';
		arrayAlinha[5] = 'right';
		
        tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');
				
    } else if (in_array(operacao, ['INTEGRALIZA'])) {
				
        altura = '190px';
	
		$('div.divIntegralizacao').css('height','142px');
		
		var rVintegra = $('label[for="vintegra"]','#frmIntegraliza');
	
        var cVlintegra = $('#vintegra', '#divIntegralizacao');
		
        rVintegra.addClass('rotulo').css({ 'width': '130px', 'margin-left': '40px' });
		
        cVlintegra.addClass('rotulo-linha').css('width', '90px');
		cVlintegra.habilitaCampo();
		
        cVlintegra.unbind('keypress').bind('keypress', function (e) {
			
			if (e.keyCode == 13)
				return false;
		});
		
    } else if (in_array(operacao, ['ESTORNO'])) {
	
		var divRegistro = $('div.divRegistros');		
        var tabela = $('table', divRegistro);
		
		divRegistro.css('height','93px');
		$('#divEstorno').css('height','115px');
		
		var ordemInicial = new Array();
        ordemInicial = [[0, 0]];
		
		var arrayLargura = new Array();
		arrayLargura[0] = '20px';
		arrayLargura[1] = '73px';
		arrayLargura[2] = '55px';

		var arrayAlinha = new Array();
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'center';
		arrayAlinha[2] = 'right';
		
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '');

		$('th.ordemInicial').css({'width':'6px'});
	}
	
	callafterCapital = '';
	
    divRotina.css('width', largura);
    $('#divConteudoOpcao').css({ 'height': altura, 'width': largura });

	layoutPadrao();

	hideMsgAguardo();
	bloqueiaFundo(divRotina);

	removeOpacidade('divConteudoOpcao');
	divRotina.centralizaRotinaH();

	return false;
}

function integralizaCotas(flgsaldo) {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, realizando integraliza&ccedil;&atilde;o de cotas ...");
	
	if (flgsaldo) // flgsaldo indica se é para validar ou não o limite de crédito	
		vintegra = $('#vintegra','#divIntegralizacao').val().replace(/\./g,"");
	
	// Valida valor de integralizacao
    if (vintegra == "" || !validaNumero(vintegra, true, 0, 0)) {
		hideMsgAguardo();
        showError("error", "Valor inv&aacute;lido para integraliza&ccedil;&atilde;o.", "Alerta - Ayllos", "$('#vintegra','#divIntegralizacao').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}
	
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/capital/integralizar_cotas.php",
		data: {
			nrdconta: nrdconta,
			vintegra: vintegra,
			flgsaldo: flgsaldo,
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

function selecionaIntegralizacao(id) {

	if (lstEstorno == "")
		lstEstorno = new Array();
	
	if($("#appest" + id).is(":checked")){
		var campos = new Object();
		campos["auxidest"] = id;
		campos["lctrowid"] = lstLancamentos[id].lctrowid;
		lstEstorno.push(campos);
	} else {
		for(i=0; i < lstEstorno.length; i++) {
			if(lstEstorno[i]["auxidest"] == id)
				lstEstorno.splice(i,1);
		}
	}
}

function estornaIntegralizacao() {

	if (lstEstorno == "") {
		hideMsgAguardo();
        showError("error", "Nenhum lan&ccedil;amento selecionado!", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, estornando lan&ccedil;amento(s) ...");
	
	var camposPc = '';
	var dadosPrc = '';
	
	camposPc = retornaCampos(lstEstorno, '|');
	dadosPrc = retornaValores(lstEstorno, ';', '|', camposPc);
	
	$.ajax({		
		type: "POST", 
		dataType: "html",
		url: UrlSite + "telas/atenda/capital/estornar_integralizacoes.php",
		data: {
			nrdconta: nrdconta,
			camposPc: camposPc,
			dadosPrc: dadosPrc,
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

// senha
function mostraSenha() {

	if (glb_opcao == "L" && lstEstorno == "") {
		hideMsgAguardo();
        showError("error", "Nenhum lan&ccedil;amento selecionado!", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}

	showMsgAguardo('Aguarde, abrindo ...');

	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atenda/capital/senha.php', 
		data: {
			redirect: 'html_ajax'			
			}, 
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground()");
		},
        success: function (response) {
			$('#divConteudoOpcao').html(response);
			exibeRotina($('#divConteudoOpcao'));
			formataSenha();
			blockBackground(parseInt($("#divRotina").css("z-index")));
			return false;
		}				
	});
	return false;
	
}

function formataSenha() {

	highlightObjFocus($('#frmSenha'));

    rOperador = $('label[for="operauto"]', '#frmSenha');
    rSenha = $('label[for="codsenha"]', '#frmSenha');
	
    rOperador.addClass('rotulo').css({ 'width': '165px' });
    rSenha.addClass('rotulo').css({ 'width': '165px' });

    cOperador = $('#operauto', '#frmSenha');
    cSenha = $('#codsenha', '#frmSenha');
	
    cOperador.addClass('campo').css({ 'width': '100px' }).attr('maxlength', '10');
    cSenha.addClass('campo').css({ 'width': '100px' }).attr('maxlength', '10');
	
    $('#divConteudoSenha').css({ 'width': '400px', 'height': '120px' });

	hideMsgAguardo();		
	cOperador.focus();
	return false;
}

function validarSenha() {
		
	hideMsgAguardo();		
	
	// Situacao
    operauto = $('#operauto', '#frmSenha').val();
    var codsenha = $('#codsenha', '#frmSenha').val();

    showMsgAguardo('Aguarde, validando dados ...');

	$.ajax({		
        type: 'POST',
        async: true,
        url: UrlSite + 'telas/atenda/capital/valida_senha.php',
			data: {
            operauto: operauto,
            codsenha: codsenha,
            opcao: glb_opcao,
            redirect: 'script_ajax'
			}, 
        error: function (objAjax, responseError, objExcept) {
				hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
			},
        success: function (response) {
				try {
					eval(response);
					return false;
            } catch (error) {
					hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
				}
			}
		});

	return false;	
	                     
}

function habilitaValor() {

    if ($('#cdtipcor', '#frmNovoPlano').val() == 2)
        $('#divValorCorrecao').css({ 'display': 'block' });
	else
        $('#divValorCorrecao').css({ 'display': 'none' });

}


function controlaBotoes(tipo) {
    
    /*Senha*/
    if (tipo == '1') {
        
        $('#divBotoesAutorizacao').css('display', 'none');
        $('#divBotoesSenha').css('display', 'inline');

    /*Autorizacao*/
    } else {
        
        $('#divBotoesAutorizacao').css('display', 'inline');
        $('#divBotoesSenha').css('display', 'none');

    }

    
}
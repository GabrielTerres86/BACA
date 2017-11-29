/******************************************************************************
 Fonte: aplicacoes.js                                             
 Autor: David                                                     
 Data : Setembro/2009                Última Alteração: 29/11/2017
                                                                  
 Objetivo  : Biblioteca de funções da rotina Aplicações da tela   
             ATENDA                                               
                                                                  	 
 Alterações: 04/10/2010 - Adaptação para novas opções Incluir,    
                          Alterar e Excluir (David).              
                                                                  
             22/10/2010 - Alteração na acessaOpcaoAba (David).    
                                                                  
             12/08/2011 - Criado funcoes obtemResgatesVarias(),   
 			  selecionaResgateVarias(), verificaResgates(),        
			  cancelarResgatesVarias(), viewComplementoResgVarias()
			  selLinhaProVarias(), selLinhaCanVarias(),      	   
			  formataTabelaResgateCheck(),formataTabelaResgateNoCheck
			  formataTabelaResgateCheck(),formataTabelaResgateNoCheck
			  voltarDivResgatarVarias(). (Jorge)  				   
																   
                          Criado funcoes voltarDivResgatarVarias(),
		      acessaOpcaoResgatarVarias(), acessaOpcaoResgates(),   
			  listarResgatesAuto(), listarResgatesManual(),		   
			  formataResgatarVarias(), voltarDivResgateAutoManual(),
		      continuaListarResgates(), 						   
		      formataTabelaResgateAutomatico(),                    
		      cadastrarVariosResgates(), formataTabelaResgateManual(),
			  selecionaAplicacaoManual(), selecionaResgatesManual(),
			  atualizaTotalDiferenca(), resgataValorParcial(),     
			  formataResgateParcial(), voltarDivAutoManual(),      
		      setValorParcialResgate(). Fabricio                   
                                                                  
             21/09/2011 - Adicionado funcao marcaDesmarcaTodos(). 
                          (Fabricio)                              
                                                                  
             01/08/2012 - Adicionado funcao exibeParamImpressao() 
                          e campos referentes ao bt Imprimir e    
                          validações para Demonstrativo Aplicações
                          (Guilherme/Supero)                      
																  
			  04/05/2013 - Incluir complemento.css({'height':'40px'})
                          (Lucas R.)                              
                                                                  
  		  	  23/08/2013 - Implementação novos produtos Aplicação 
                           (Lucas).                               
                                                                  
             30/04/2014 - Ajustes referente ao projeto Captação   
 						   (Adriano).    						  
                                                                  
             25/07/2014 - Atualizacao verificaTipoAplicacao       
						   referente ao projeto de captacao		  
						   (Jean Michel)						  
                                                                  
			  28/07/2014 - Inclusao da function					  
						   selecionaCarenciaCaptacao para o 	  
						   projeto de captacao (Jean Michel)	  
																  
			  12/08/2014 - Ajustar a function formataResgate e    
                          formataResgatarVarias para desabilitar  
						   o campo Data de Resgate (Douglas		  
						   Projeto Captação Internet 2014/2)	  
                                                                  
             09/09/2014 - Inclusao da function                    
                          acessaOpcaoAgendamento (Douglas		  
						   Projeto Captação Internet 2014/2)      
                                                                  
             23/10/2014 - Corrigido para qdo for incluir uma      
                          aplicacao RDC PRE para pegar a qtd      
                          de dias carencia corretamente do campo  
                          (Tiago Projeto Captação Internet 2014/2)
						  
			 26/12/2014 - Ajuste para corrigir o problema de permitir  
                          o cadastro de aplicações com data de     
                          vencimento errada (SD - 237402)			
  					     (Adriano).
		     
			 14/04/2015 - Adicionado novo campo com a data de carência 
			     	      da aplicação SD - 266191 (Kelvin)
						  
			 08/10/2015 - Reformulacao cadastral (Gabriel-RKAM)  

             29/03/2017 - Inclui validacao para uso da senha do operador para o resgate de aplicacoes. SD 632578

             28/09/2017 - Correcao na simulacao de aplicacoes atraves ATENDA - APLICACOES. SD 685979. (Carlos Rafael Tanholi)

			 29/11/2017 - Validacao sobre valor bloqueado. M460 - BancenJud (Thiago Rodrigues)
***************************************************************************/

var nraplica = 0;     // Variável para armazenar número da aplicação selecionada
var cdprodut = 0;     // Variável para armazenar número do produto selecionada
var dtresgat = "";    // Variável para armazenar data do resgate selecionado
var nrdocmto = 0;     // Variável para armazenar número do resgate selecionado
var tpaplrdc = 0;     // Variável para armazenar tipo de aplicação (1 - RDCPRE / 2 - RDCPOS)
var cdperapl = 0;     // Variável para armazenar código do período de carência
var flgcaren = false; // Variável que indica se a lista de carência deve ser carregada
var aux_qtdiaapl = 0; // Variável que armazena os dias aplicados - RDCPOS
var aux_qtdiacar = 0; // Variável que armazena os dias de carência - RDCPOS/RDCPRE
var flgoprgt = false; // Variável que indica se foi feita alguma atualização na opção resgate
var glbvenct = "";    // Variável que armazena conteúdo do campo vencimento
var glbqtdia = "0";   // Variável que armazena conteúdo do campo dias
var idLinhaCanVar = 1; //variavel que armazena id da linha que contem o resgate de CANCELAMENTO selecionado em resgatar varias
var idLinhaProVar = 1; //variavel que armazena id da linha que contem o resgate de PROXIMOS selecionado em resgatar varias
var idLinha = -1;     // Variável para armazanar o id da linha que contém a aplicação selecionada
var idLinhaResg = 0;  // Variável para armazanar o id da linha que contém o resgate selecionado
var fncMsgsAplic = ""; // Variável para armazenar função que deverá acionada após as confirmações de validação para nova aplicação 
var metodoBlock = "blockBackground(parseInt($('#divRotina').css('z-index')))"; // Variável para armazenar função de bloqueio do background
var msgAplica = new Array(); // Variável para armazenar mensagens de confirmação no momento da validação
var lstAplicacoes = new Array(); // Variável para armazenar aplicações do cooperado
var lstResgatesChecked = new Array(); // Variável para armazenar cancelamento de resgates de aplicacao do cooperado
var lstResgates = new Array(); // Variável para armazenar resgates de aplicacao do cooperado
var lstDadosResgate;
var lstQuestionaCliente;
var lstResgatesManual = new Array();
var valdtresg = false;

var flgDigitValor = true;
var flgDigitVencto = true;

var auxExcluir = 0;

var tpaplica;
var idtippro;
var idprodut;
var cNraplica = $('#tpaplic2', '#divImprimir');
var glbTpaplica;

//Adicionar os scripts da tela de agendamento
$.getScript(UrlSite + "telas/atenda/aplicacoes/agendamento.js");



// Função para acessar opções da rotina
function acessaOpcaoAba(nrOpcoes, id, opcao) {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando aplica&ccedil;&otilde;es do associado ...");

    // Atribui cor de destaque para aba da opção
    $("#linkAba0").attr("class", "txtBrancoBold");
    $("#imgAbaEsq0").attr("src", UrlImagens + "background/mnu_sle.gif");
    $("#imgAbaDir0").attr("src", UrlImagens + "background/mnu_sld.gif");
    $("#imgAbaCen0").css("background-color", "#969FA9");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/aplicacoes/principal.php",
        data: {
            nrdconta: nrdconta,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divConteudoOpcao").html(response);

            if (executandoProdutos) {
                buscaDadosAplicacao('I');
            }
            controlaFoco();
        }
    });
}

//Função para controle de navegação
function controlaFoco() {
    $('#divConteudoOpcao #divAplicacoesPrincipal').each(function () {
        $(this).find("#divBotoes > a").addClass("FluxoNavega");
        $(this).find("#divBotoes > a").first().addClass("FirstInputModal").focus();
        $(this).find("#divBotoes > a").last().addClass("LastInputModal");
    });

    //Se estiver com foco na classe FluxoNavega
    $(".FluxoNavega").focus(function () {
        $(this).bind('keydown', function (e) {
            if (e.keyCode == 27) {
                encerraRotina(true).click();
            }
        });
    });

    //Se estiver com foco na classe LastInputModal
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

            if (e.keyCode == 13) {
                $(".LastInputModal").click();
            }
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

// Função para seleção da aplicação
function selecionaAplicacao(id, qtAplicacao, aplicacao, tpaplica) {

    if (tpaplica == null || tpaplica == 'undefined') {
        glbTpaplica = "A";
    } else {
        glbTpaplica = tpaplica;
    }

    // Formata cor da linha da tabela que lista aplicações
    for (var i = 0; i < qtAplicacao; i++) {

        if (i == id) {
            // Mostrar informações adicionais da aplicação
            $("#tdSit").html(lstAplicacoes[id].dssitapl);
            $("#tdTxCtr").html(lstAplicacoes[id].txaplmax);
            $("#tdTxMin").html(lstAplicacoes[id].txaplmin);
            $("#tdResg").html(lstAplicacoes[id].cddresga);
            $("#tdDtResg").html(lstAplicacoes[id].dtresgat);
            $("#tdNrApl").html(lstAplicacoes[id].nrdocmto.replace(/\,/g, "."));

            // Armazena número da aplicação selecionada
            nraplica = retiraCaracteres(aplicacao, "0123456789", true);
            cdprodut = lstAplicacoes[id].cdprodut;
            idLinha = id;
        }
    }
}

function voltarDivPrincipal() {

    $("#divResgate").css("display", "none");
    $("#divResgatarVarias").css("display", "none");
    $("#divAcumula").css("display", "none");
    $("#divDadosAplicacao").css("display", "none");
    $("#frmDadosAplicacaoPre").css("display", "none");
    $("#frmDadosAplicacaoPos").css("display", "none");
    $("#divImprimir").css("display", "none");
    $("#divAutoManual").css("display", "none");
    $("#divZoomAplicacao").css("display", "none");
    $("#divAgendamento").css("display", "none");
    $("#divAplicacoesPrincipal").css("display", "block");

    // Aumenta tamanho do div onde o conteúdo da opção será visualizado
    $("#divConteudoOpcao").css("height", "280px");

    $("#dsaplica", "#frmDadosAplicacaoPre").val("");
    $("#dsaplica", "#frmDadosAplicacaoPos").val("");

    // Bloqueia conteúdo que está átras do div da rotina
    blockBackground(parseInt($("#divRotina").css("z-index")));
}

function voltarDivImprimir() {

    $("#divResgate").css("display", "none");
    $("#divResgatarVarias").css("display", "none");
    $("#divAcumula").css("display", "none");
    $("#divDadosAplicacao").css("display", "none");
    $("#frmDadosAplicacaoPos").css("display", "none");
    $("#frmDadosAplicacaoPre").css("display", "none");
    $("#divImprimir").css("display", "block");
    $("#divAutoManual").css("display", "none");
    $("#divZoomAplicacao").css("display", "none");
    $("#divAplicacoesPrincipal").css("display", "none");

    // Aumenta tamanho do div onde o conteúdo da opção será visualizado
    $("#divConteudoOpcao").css("height", "220px");

    // Bloqueia conteúdo que está átras do div da rotina
    blockBackground(parseInt($("#divRotina").css("z-index")));
}

function voltarDivResgate() {

    $("#divConteudoOpcao").css("height", "60px");

    $("#divOpcoes").css("display", "none");
    $("#divResgate").css("display", "block");

    // Zerar variáveis globais utilizadas na opção de resgate
    dtresgat = "";
    nrdocmto = 0;
}

function voltarDivResgatarVarias() {
    $("#divConteudoOpcao").css("height", "60px");

    $("#divOpcoes").css("display", "none");
    $("#divResgatarVarias").css("display", "block");

    // Zerar variáveis globais utilizadas na opção de resgate
    dtresgat = "";
    nrdocmto = 0;
}

function voltarDivAcumula() {
    // Aumenta tamanho do div onde o conteúdo da opção será visualizado
    $("#divConteudoOpcao").css("height", "60px");

    $("#divOpcoes").css("display", "none");
    $("#divAcumula").css("display", "block");
}

function acessaOpcaoResgate() {

    // Se não tiver nenhuma aplicação selecionada
    if (nraplica == 0) {
        return false;
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando op&ccedil;&atilde;o para resgate ...");

    // Executa script de consulta através de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/aplicacoes/resgate.php",
        data: {
            nrdconta: nrdconta,
            nraplica: nraplica,
            tpaplica: glbTpaplica,
            flcadrgt: "no",
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

function acessaOpcaoResgatarVarias() {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando op&ccedil;&atilde;o para resgate ...");

    // Executa script de consulta através de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/aplicacoes/resgatar_varias.php",
        data: {
            nrdconta: nrdconta,
            flcadrgt: "no",
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

// Função para consultar proximos resgates
function obtemResgates(flgcance) {
    // Se não tiver nenhuma aplicação selecionada
    if (nraplica == 0) {
        return false;
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando resgates ...");

    // Executa script de consulta através de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + (flgcance ? "telas/atenda/aplicacoes/resgate_cancelamento.php" : "telas/atenda/aplicacoes/resgate_proximos.php"),
        data: {
            nrdconta: nrdconta,
            nraplica: nraplica,
            tpaplica: glbTpaplica,
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

// Função para seleção do resgate
function selecionaResgate(id, qtResgate, data, documento) {
    var cor = "";

    // Formata cor da linha da tabela que lista resgates
    for (var i = 1; i <= qtResgate; i++) {
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

            // Armazena número e data do resgate selecionado
            dtresgat = data;
            nrdocmto = retiraCaracteres(documento, "0123456789", true);
            idLinhaResg = id;
        }
    }
}


// Função para cancelamento de resgate
function cancelarResgates() {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, cancelando resgate ...");

    // Executa script de consulta através de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/aplicacoes/resgate_cancelar.php",
        data: {
            nrdconta: nrdconta,
            nraplica: nraplica,
            nrdocmto: nrdocmto,
            dtresgat: dtresgat,
            tpaplica: glbTpaplica,
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

function acessaOpcaoCadastroResgate() {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando op&ccedil;&atilde;o para cadastro de resgate ...");

    // Executa script de consulta através de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/aplicacoes/resgate.php",
        data: {
            nrdconta: nrdconta,
            nraplica: nraplica,
            tpaplica: glbTpaplica,
            flcadrgt: "yes",
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

// Função para cadastro do resgate
function cadastrarResgate(flmensag) {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, " + (flmensag == "yes" ? "validando" : "cadastrando") + " resgate ...");

    var tpresgat = $("#tpresgat", "#frmResgate").val();
    var vlresgat = $("#vlresgat", "#frmResgate").val().replace(/\./g, "");
    var dtresgat = $("#dtresgat", "#frmResgate").val();
    var flgctain = $("#flgctain", "#frmResgate").val();
    // consiste check "Autorizar operação" 
    var cdopera2 = ($("#flautori").is(':checked')) ? $("#cdopera2", "#frmResgate").val() : '';
    var cddsenha = ($("#flautori").is(':checked')) ? $("#cddsenha", "#frmResgate").val() : '';

    if (tpresgat == "P" || tpresgat == 1) {
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

    // Executa script de consulta através de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/aplicacoes/resgate_cadastrar.php",
        data: {
            nrdconta: nrdconta,
            nraplica: nraplica,
            tpresgat: tpresgat,
            vlresgat: vlresgat,
            dtresgat: dtresgat,
            tpaplica: glbTpaplica,
            flgctain: flgctain,
            flmensag: flmensag,
            cdopera2: cdopera2,
            cddsenha: cddsenha,
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

// Função para mostrar opção ACUMULA
function acessaOpcaoAcumula() {
    $("#divAplicacoesPrincipal").css("display", "none");
    $("#divAcumula").css("display", "block");
    $("#divConteudoOpcao").css("height", "60px");
}

// Função para consultar saldos acumulados da aplicação
function consultaSaldoAcumulado() {
    // Se não tiver nenhuma aplicação selecionada
    if (nraplica == 0) {
        return false;
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando saldos acumulados ...");

    // Executa script de consulta através de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/aplicacoes/acumula_consultar.php",
        data: {
            nrdconta: nrdconta,
            nraplica: nraplica,
            idtipapl: glbTpaplica,
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

// Função para acessar opção de simulação de saldos acumulados
function opcaoSimulacao() {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando op&ccedil;&atilde;o de simula&ccedil;&atilde;o ...");

    // Executa script de consulta através de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/aplicacoes/acumula_simular.php",
        data: {
            nrdconta: nrdconta,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoes").html(response);
            formataAcumulaSimular();

        }
    });
}

// Função para calcular permanência da aplicação (vencimento)
function calculaPermanencia(nomcampo, valcampo) {

    var tipo = ($("#tpaplica option:selected", "#frmSimular").text() == "RDCPRE") ? true : false;

    if (tipo) {

        var qtdiaapl = "0";
        var dtvencto = "";

        eval(nomcampo + ' = "' + valcampo + '"');

        if (qtdiaapl == 0 && dtvencto == "") {
            return true;
        }

        if (glbqtdia == $("#qtdiaapl", "#frmSimula" + $("#tpaplica option:selected", "#frmSimular").text()).val() &&
			glbvenct == $("#dtvencto", "#frmSimula" + $("#tpaplica option:selected", "#frmSimular").text()).val()) {
            return true;
        }

    } else {

        if ((glbqtdia == $("#qtdiaapl", "#frmSimula" + $("#tpaplica option:selected", "#frmSimular").text()).val() && glbvenct == $("#dtvencto", "#frmSimula" + $("#tpaplica option:selected", "#frmSimular").text()).val()) ||
			(aux_qtdiaapl == 0 && $("#dtvencto", "#frmSimula" + $("#tpaplica option:selected", "#frmSimular").text()).val() == "")) {
            return true;
        }

        dtvencto = $("#dtvencto", "#frmSimula" + $("#tpaplica option:selected", "#frmSimular").text()).val();

    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, calculando perman&ecirc;ncia (vencimento) ...");

    // Executa script de consulta através de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/aplicacoes/acumula_permanencia.php",
        data: {
            nrdconta: nrdconta,
            tpaplica: $("#tpaplica", "#frmSimular").val(),
            qtdiaapl: (tipo) ? qtdiaapl : aux_qtdiaapl,
            qtdiacar: (tipo) ? 0 : aux_qtdiacar,
            dtvencto: dtvencto,
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

// Função para períodos de carêcia para simulação
function obtemCarencia() {

    var tpaplica = $("#tpaplica", "#frmSimular").val();

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando per&iacute;odos para car&ecirc;ncia...");

    // Executa script de consulta através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/aplicacoes/acumula_carencia.php",
        data: {
            nrdconta: nrdconta,
            tpaplica: tpaplica,
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

function selecionaCarencia(periodo, qtdiaapl, carencia, dtcarenc, simulacao) {

    var vllanmto;
    aux_qtdiaapl = qtdiaapl;
    aux_qtdiacar = carencia;
    cdperapl = periodo;

    if (simulacao) {

        $("#qtdiacar", "#frmSimula" + $("#tpaplica option:selected", "#frmSimular").text()).val(carencia);
        $("#dtcarenc", "#frmSimula" + $("#tpaplica option:selected", "#frmSimular").text()).val(dtcarenc);
        $("#dtvencto", "#frmSimula" + $("#tpaplica option:selected", "#frmSimular").text()).focus();
        // seta o periodo da aplicacao
        $("#cdperapl", "#frmSimula" + $("#tpaplica option:selected", "#frmSimular").text()).val(cdperapl);
        $("#divCarencia").css("visibility", "hidden");

        calculaPermanencia();

    } else {

        $("#qtdiacar", "#frmDadosAplicacaoPos").val(carencia);
        $("#dtcarenc", "#frmDadosAplicacaoPos").val(dtcarenc);

        $("#divSelecionaCarencia").hide();

        vllanmto = parseFloat($("#vllanmto", "#frmDadosAplicacaoPos").val().replace(/\./g, "").replace(/\,/g, "."));

        if (vllanmto > 0) {
            obtemTaxaAplicacao();
        }

    }
}

function fechaZoomCarencia(periodo, qtdiaapl, carencia, dtcarenc, simulacao) {

    aux_qtdiaapl = qtdiaapl;
    aux_qtdiacar = carencia;
    cdperapl = periodo;

    if (carencia) {
        showError("error", "Selecione a car&ecirc;ncia da aplica&ccedil;&atilde;o.", "Alerta - Ayllos", "$('#vllanmto','#frmDadosAplicacaoPos').focus(); $('#divSelecionaCarencia').hide(); blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    if (simulacao) {

        $("#qtdiacar", "#frmSimula" + $("#tpaplica option:selected", "#frmSimular").text()).val(carencia);
        $("#dtcarenc", "#frmSimula" + $("#tpaplica option:selected", "#frmSimular").text()).val(dtcarenc);
        $("#dtvencto", "#frmSimula" + $("#tpaplica option:selected", "#frmSimular").text()).focus();

        $("#divCarencia").css("visibility", "hidden");

        calculaPermanencia();

    } else {

        $("#divSelecionaCarencia").hide();

        $("#qtdiacar", "#frmDadosAplicacaoPos").val(aux_qtdiacar);
        $("#dtcarenc", "#frmDadosAplicacaoPos").val(dtcarenc);

        if (parseFloat($("#vllanmto", "#frmDadosAplicacaoPos").val().replace(/\./g, "").replace(/\,/g, ".")) > 0) {
            obtemTaxaAplicacao();
        }
    }
}

// Função para calcular saldo acumulado
function calcularSaldoAcumulado() {
    var tpaplica = $("#tpaplica", "#frmSimular").val();
    var vlaplica = $("#vlaplica", "#frmSimula" + $("#tpaplica option:selected", "#frmSimular").text()).val().replace(/\./g, "");
    var dtvencto = $("#dtvencto", "#frmSimula" + $("#tpaplica option:selected", "#frmSimular").text()).val();
    var cdperapl = $("#cdperapl", "#frmSimula" + $("#tpaplica option:selected", "#frmSimular").text()).val();

    if (vlaplica == "" || !validaNumero(vlaplica, true, 0, 0)) {
        showError("error", "Informe o valor da aplica&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    if (dtvencto == "") {
        showError("error", "Informe a data de vencimento.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    if (tpaplica == 8 && parseInt(cdperapl, 10) <= 0) {
        showError("error", "Informe a car&ecirc;ncia.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, simulando saldo acumulado ...");

    // Executa script de consulta através de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/aplicacoes/acumula_calcular_saldo.php",
        data: {
            nrdconta: nrdconta,
            tpaplica: tpaplica,
            vlaplica: vlaplica,
            dtvencto: dtvencto,
            cdperapl: cdperapl,
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

// Função para obter código do tipo da aplicação
function verificaTipoAplicacao(fnc) {
    // Mostra mensagem de aguardo

    showMsgAguardo("Aguarde, verificando tipo da aplica&ccedil;&atilde;o");

    var tpaplica = $("#tpaplica", "#frmDadosAplicacao").val();
    var strValorApl = new Array();
    fechaZoomCarencia();

    strValorApl = tpaplica.split(',', 3);
    tpaplica = strValorApl[0]; /*Codigo do tipo da aplicacao*/
    idtippro = strValorApl[1]; /*Verifica se produto é PRE OU POS dos produtos novos*/
    idprodut = strValorApl[2]; /*Verifica se é produto novo ou antigo*/

    // Executa script de consulta através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/aplicacoes/aplicacao_verifica_tipo.php",
        data: {
            nrdconta: nrdconta,
            tpaplica: tpaplica,
            idtippro: idtippro,
            idprodut: idprodut,
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

// Função para calcular data de resgate da aplicação (vencimento)
function calculaDataResgate(nmdcampo, dtresgat) {

    var dtcarenc = $("#dtcarenc", "#frmDadosAplicacaoPos").val();
    var tpaplica = $("#tpaplica", "#frmDadosAplicacao").val();
    var strValorApl = tpaplica.split(',', 3);

    //valdtresg = false;

    tpaplica = strValorApl[0]; /*Codigo do tipo da aplicacao*/
    idtippro = strValorApl[1]; /*Verifica se produto é PRE OU POS dos produtos novos*/
    idprodut = strValorApl[2]; /*Verifica se é produto novo ou antigo*/

    if (idprodut == 'A') {

        if (tpaplrdc == 0) {
            // Se o tipo de aplicação ainda não foi validado, força a validação e aciona novamente a função para calcular a data de resgate
            $("#tpaplica", "#frmDadosAplicacao").trigger("blur", ['calculaDataResgate("' + dtresgat + '")']);

            return false;
        }

        if ((tpaplrdc == 1 && (aux_qtdiacar == 0 && dtresgat == "")) || (tpaplrdc == 1 && (aux_qtdiaapl == 0 && dtresgat == ""))) {
            return true;
        }

        if (tpaplrdc == 1) {

            if (aux_qtdiaapl == 0 && $("#dtresgat", "#frmDadosAplicacaoPre").val() == "") {
                return true;
            }

            if (glbqtdia == $("#qtdiaapl", "#frmDadosAplicacaoPre").val() && glbvenct == $("#dtresgat", "#frmDadosAplicacaoPre").val()) {
                return true;
            }
        } else {
            if ((glbqtdia == $("#qtdiaapl", "#frmDadosAplicacaoPos").val() && glbvenct == $("#dtresgat", "#frmDadosAplicacaoPos").val()) ||
				(aux_qtdiaapl == 0 && $("#dtresgat", "#frmDadosAplicacaoPos").val() == "")) {
                return true;
            }
        }
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, verificando data do resgate ...");

    // Executa script de consulta através de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/aplicacoes/aplicacao_data_resgate.php",
        data: {
            nrdconta: nrdconta,
            tpaplica: tpaplica,
            idtippro: idtippro,
            idprodut: idprodut,
            qtdiaapl: aux_qtdiaapl,
            qtdiacar: aux_qtdiacar,
            dtresgat: dtresgat,
            nmdcampo: nmdcampo,
            qtdiapra: $("#qtdiapra", "#frmDadosAplicacaoPos").val(),
            dtcarenc: dtcarenc,
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

// Função para carregar carências
function carregaCarenciaAplicacao() {

    var tpaplica = $("#tpaplica", "#frmDadosAplicacao").val();
    var strValorApl = tpaplica.split(',', 3);

    tpaplica = strValorApl[0]; /*Codigo do tipo da aplicacao*/
    idtippro = strValorApl[1]; /*Verifica se produto é PRE OU POS dos produtos novos*/
    idprodut = strValorApl[2]; /*Verifica se é produto novo ou antigo*/

    if (idprodut == "A") {
        if (tpaplrdc == 0) {
            return false;
        }
    }

    // Mostra mensagem de aguardo
    if (tpaplrdc == 1) { // RDCPRE
        var vllanmto = $("#vllanmto", "#frmDadosAplicacaoPre").val().replace(/\./g, "");

        if (vllanmto == 0 || vllanmto == null || vllanmto == "0,00") {
            $("#vllanmto", "#frmDadosAplicacaoPre").focus();
        } else {
            obtemTaxaAplicacao();
        }
    } else {

        // Executa script de consulta através de ajax
        $.ajax({
            type: "POST",
            url: UrlSite + "telas/atenda/aplicacoes/aplicacao_carencia.php",
            data: {
                nrdconta: nrdconta,
                tpaplica: tpaplica, /*Codigo do tipo da aplicacao*/
                idtippro: idtippro, /*Verifica se produto é PRE OU POS dos produtos novos*/
                idprodut: idprodut, /*Verifica se é produto novo ou antigo*/
                qtdiaapl: 0,
                qtdiacar: 0,
                redirect: "script_ajax"
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            },
            success: function (response) {
                try {
                    hideMsgAguardo();
                    eval(response);
                } catch (error) {
                    hideMsgAguardo();
                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
                }
            }
        });

        showMsgAguardo("Aguarde, carregando per&iacute;odos para car&ecirc;ncia...");
    }

}

// Função para obter taxa de rendimento da aplicação
function obtemTaxaAplicacao() {

    var strValorApl = new Array();

    var tpaplica = $("#tpaplica", "#frmDadosAplicacao").val();
    var carencia = $("#qtdiacar", "#frmDadosAplicacaoPos").val();
    var vllanmto = (tpaplrdc == 1) ? $("#vllanmto", "#frmDadosAplicacaoPre").val().replace(/\./g, "") : $("#vllanmto", "#frmDadosAplicacaoPos").val().replace(/\./g, "");

    strValorApl = tpaplica.split(',', 3);

    tpaplica = strValorApl[0]; /* Codigo do tipo da aplicacao */
    idtippro = strValorApl[1]; /* Verifica se produto é PRE OU POS dos produtos novos */
    idprodut = strValorApl[2]; /* Verifica se é produto novo ou antigo */

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando taxa de rendimento ...");

    if (tpaplica != 7 && carencia == 0) {
        hideMsgAguardo();
        showError("error", "Selecione a car&ecirc;ncia da aplica&ccedil;&atilde;o.", "Alerta - Ayllos", "$('#vllanmto','#frmDadosAplicacaoPos').focus(); blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    if (cdperapl == 0 || cdperapl == null || cdperapl == '' && (tpaplica == 7 && idprodut == "A")) {
        cdperapl = 1;
    }

    // Executa script de consulta através de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/aplicacoes/aplicacao_taxa_rendimento.php",
        data: {
            nrdconta: nrdconta,
            tpaplica: tpaplica,
            cdperapl: cdperapl,
            vllanmto: vllanmto,
            idtippro: idtippro,
            idprodut: idprodut,
            qtdiaapl: aux_qtdiaapl,
            qtdiacar: carencia,
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

// Função para carregar dados da aplicação para inclusão, alteração ou exclusão
function buscaDadosAplicacao(cddopcao) {

    var strpagin = "";
    // Se não tiver nenhuma aplicação selecionada
    if (nraplica == 0 && cddopcao == "E") {
        return false;
    }

    switch (cddopcao) {
        case "E": var msg = "Aguarde, carregando dados para exclus&atilde;o ..."; break;
        case "I": var msg = "Aguarde, carregando dados para inclus&atilde;o ..."; break;
        default: return false; break;
    }

    // Mostra mensagem de aguardo
    showMsgAguardo(msg);

    if (auxExcluir == 1 && glbTpaplica == "N") {
        strpagin = "excluir_nova_aplicacao.php";
        auxExcluir = 0;
    } else {
        strpagin = "aplicacao_obtem_dados.php";
    }

    // Executa script de consulta através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/aplicacoes/" + strpagin,
        data: {
            nrdconta: nrdconta,
            nraplica: nraplica,
            cddopcao: cddopcao,
            tpaplica: glbTpaplica,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            hideMsgAguardo();
            eval(response);
            //cTpaplica.trigger('change');
        }
    });
}

// Função para controlar operações de alteração, inclusão e exclusão para uma nova aplicação
function controlarAplicacao(flgvalid, cddopcao) {

    var tpaplica = $("#tpaplica", "#frmDadosAplicacao").val();
    var strValorApl = new Array();

    //Caso a data vencimento seja alterada, esta, deve ser validada novamente
    /*if(valdtresg){
		$('#dtresgat','#frmDadosAplicacaoPos').trigger('blur');
		return false;
	}*/

    // Se não tiver nenhuma aplicação selecionada
    if (nraplica == 0 && cddopcao == "E") {
        return false;
    }

    strValorApl = tpaplica.split(',', 3);

    tpaplica = strValorApl[0]; /* Codigo do tipo da aplicacao */
    idtippro = strValorApl[1]; /* Verifica se produto é PRE OU POS dos produtos novos */
    idprodut = strValorApl[2]; /* Verifica se é produto novo ou antigo */

    if (cTxaplicaPre.val() == '0,000000' && idprodut == 'A' && tpaplica == 7) {
        obtemTaxaAplicacao();
        return false;
    }

    switch (cddopcao) {
        case "E": var msg = "Aguarde, " + (flgvalid ? "validando exclus&atilde;o ..." : "exclu&iacute;ndo aplica&ccedil;&atilde;o ..."); break;
        case "I": var msg = "Aguarde, " + (flgvalid ? "validando inclus&atilde;o ..." : "inclu&iacute;ndo aplica&ccedil;&atilde;o ..."); break;
        default: return false; break;
    }

    // Mostra mensagem de aguardo
    showMsgAguardo(msg);

    if (idprodut == 'N') {
        var idseqttl = 1;
        var cdprodut = tpaplica;
        var qtdiaapl = $("#qtdiaapl", "#frmDadosAplicacaoPos").val();
        var dtresgat = $("#dtresgat", "#frmDadosAplicacaoPos").val();
        var qtdiacar = $("#qtdiacar", "#frmDadosAplicacaoPos").val();
        var qtdiaprz = $("#qtdiapra", "#frmDadosAplicacaoPos").val();
        var vllanmto = $("#vllanmto", "#frmDadosAplicacaoPos").val();
        var idorirec = $("#flgrecno", "#frmDadosAplicacaoPos").val();

        var iddebcti = 0;
        var idgerlog = 1;

        if (cddopcao == "I") {
            if (vllanmto == "" || !validaNumero(vllanmto, true, 0, 0)) {
                hideMsgAguardo();
                showError("error", "Valor inv&aacute;lido.", "Alerta - Ayllos", "$('#vllanmto','#frmDadosAplicacaoPos').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
                return false;
            }

            if (qtdiacar == "" || !validaNumero(qtdiacar, true, 0, 0)) {
                hideMsgAguardo();
                showError("error", "Car&ecirc;ncia inv&aacute;lida.", "Alerta - Ayllos", "$('#qtdiacar','#frmDadosAplicacaoPos').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
                return false;
            }

            if (dtresgat == null || dtresgat == '') {
                hideMsgAguardo();
                showError("error", "Informe a data de resgate.", "Alerta - Ayllos", "$('#dtresgat','#frmDadosAplicacaoPos').focus(); blockBackground(parseInt($('#divRotina').css('z-index')))");
                return false;
            }

            if (flgDigitValor) {
                $("#btConcluir", "#divBtnAplicacao").focus();
                return true;
            }

            if (flgDigitVencto) {
                $("#btConcluir", "#divBtnAplicacao").focus();
                return true;
            }
        }

        if ($("#flgdebci", "#frmDadosAplicacaoPos").val() == 'no') {
            flgdebci = 0;
        } else {
            flgdebci = 1;
        };

        $.ajax({
            type: "POST",
            url: UrlSite + "telas/atenda/aplicacoes/valida_nova_aplicacao.php",
            data: {
                cddopcao: cddopcao,
                nrdconta: nrdconta,
                idseqttl: idseqttl,
                cdprodut: cdprodut,
                qtdiaapl: qtdiaapl,
                dtvencto: dtresgat,
                qtdiacar: qtdiacar,
                qtdiaprz: qtdiaprz,
                vlaplica: vllanmto,
                iddebcti: flgdebci,
                idorirec: idorirec,
                idgerlog: idgerlog,
                flgvalid: flgvalid,
                redirect: "script_ajax"
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            },
            success: function (response) {
                try {
                    hideMsgAguardo();
                    eval(response);
                } catch (error) {
                    hideMsgAguardo();
                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
                }
            }
        });
    } else {

        /*RDCPOS*/
        if (tpaplica == 8) {
            var qtdiacar = $("#qtdiacar", "#frmDadosAplicacaoPos").val();
            var dtresgat = $("#dtresgat", "#frmDadosAplicacaoPos").val();
            var flgdebci = $("#flgdebci", "#frmDadosAplicacaoPos").val();
            var vllanmto = $("#vllanmto", "#frmDadosAplicacaoPos").val().replace(/\./g, "");

            if (flgdebci == 'no') {
                flgdebci = 0;
            } else {
                flgdebci = 1;
            };

            if (cddopcao == "I") {
                if (vllanmto == "" || !validaNumero(vllanmto, true, 0, 0)) {
                    hideMsgAguardo();
                    showError("error", "Valor inv&aacute;lido.", "Alerta - Ayllos", "$('#vllanmto','#frmDadosAplicacaoPos').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
                    return false;
                }

                if (qtdiacar == "" || !validaNumero(qtdiacar, true, 0, 0)) {
                    hideMsgAguardo();
                    showError("error", "Car&ecirc;ncia inv&aacute;lida.", "Alerta - Ayllos", "$('#qtdiacar','#frmDadosAplicacaoPos').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
                    return false;
                }

                if (dtresgat == "" || !validaData(dtresgat)) {
                    hideMsgAguardo();
                    showError("error", "Data de vencimento inv&aacute;lida.", "Alerta - Ayllos", "$('#dtresgat','#frmDadosAplicacaoPos').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
                    return false;
                }

                if (cdperapl == 0) {
                    hideMsgAguardo();
                    showError("error", "Selecione o per&iacute;odo de car&ecirc;ncia.", "Alerta - Ayllos", "$('#dtresgat','#frmDadosAplicacaoPos').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
                    return false;
                }

                if (flgDigitValor) {
                    $("#btConcluir", "#divBtnAplicacao").focus();
                    return true;
                }

                if (flgDigitVencto) {
                    $("#btConcluir", "#divBtnAplicacao").focus();
                    return true;
                }
            }

            aux_qtdiaapl = $("#qtdiaapl", "#frmDadosAplicacaoPos").val();
        } else {
            var qtdiacar = $("#qtdiacar", "#frmDadosAplicacaoPre").val();
            var dtresgat = $("#dtresgat", "#frmDadosAplicacaoPre").val();
            var flgdebci = $("#flgdebci", "#frmDadosAplicacaoPre").val();
            var vllanmto = $("#vllanmto", "#frmDadosAplicacaoPre").val().replace(/\./g, "");

            if (flgdebci == 'no') {
                flgdebci = 0;
            } else {
                flgdebci = 1;
            };

            if (cddopcao == "I") {
                if (dtresgat == "" || !validaData(dtresgat)) {
                    hideMsgAguardo();
                    showError("error", "Data de vencimento inv&aacute;lida.", "Alerta - Ayllos", "$('#dtresgat','#frmDadosAplicacaoPre').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
                    return false;
                }

                if (vllanmto == "" || !validaNumero(vllanmto, true, 0, 0)) {
                    hideMsgAguardo();
                    showError("error", "Valor inv&aacute;lido.", "Alerta - Ayllos", "$('#vllanmto','#frmDadosAplicacaoPre').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
                    return false;
                }

                if (flgDigitVencto) {
                    $("#btConcluir", "#divBtnAplicacao").focus();
                    return true;
                }

                if (flgDigitValor) {
                    $("#btConcluir", "#divBtnAplicacao").focus();
                    return true;
                }
            }

            aux_qtdiaapl = $("#qtdiaapl", "#frmDadosAplicacaoPre").val();
        }

        // Executa script de consulta através de ajax
        $.ajax({
            type: "POST",
            url: UrlSite + "telas/atenda/aplicacoes/aplicacao_controlar.php",
            data: {
                nrdconta: nrdconta,
                flgvalid: flgvalid,
                cddopcao: cddopcao,
                tpaplica: tpaplica,
                nraplica: nraplica,
                qtdiaapl: aux_qtdiaapl,
                dtresgat: dtresgat,
                qtdiacar: qtdiacar,
                cdperapl: cdperapl,
                flgdebci: flgdebci,
                vllanmto: vllanmto,
                idtipapl: glbTpaplica,
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

}

// Função para mostrar mensagens de confirmação para inclusão de nova aplicação
function confirmaOperacaoAplicacao(cddopcao, i) {

    var dsaplica = (tpaplrdc == 1) ? $('#dsaplica', '#frmDadosAplicacaoPre').val() : $('#dsaplica', '#frmDadosAplicacaoPos').val();

    if (msgAplica.length <= 1 || (i + 1) == msgAplica.length) {
        var msg = msgAplica.length == 0 ? "Confirma a inclusao da aplicacao " + dsaplica + "?" : msgAplica[i].dsmensag + " Confirma a inclusao da aplicacao " + dsaplica + "?";
        fncMsgsAplic = "controlarAplicacao(false,'" + cddopcao + "')";
    } else {
        var msg = msgAplica[i].dsmensag + " Confirma a operacao?";
        fncMsgsAplic = "confirmaOperacaoAplicacao('" + cddopcao + "'," + (i + 1) + ")";
    }

    if (msgAplica.length == 0 || msgAplica[i].inconfir != 2) {
        showConfirmacao(msg, "Confirma&ccedil;&atilde;o - Ayllos", fncMsgsAplic, "blockBackground(parseInt($('#divRotina').css('z-index')))", "sim.gif", "nao.gif");
    } else if (msgAplica[i].inconfir == 2) {
        showConfirmacao(msgAplica[i].dsmensag + " Deseja Continuar?", "Confirma&ccedil;&atilde;o - Ayllos", "pedeSenhaCoordenador(2,fncMsgsAplic,'divRotina')", "blockBackground(parseInt($('#divRotina').css('z-index')))", "sim.gif", "nao.gif");
    }
}

// Função para mostrar mensagens de notificação após inclusão de nova aplicação
function notificaOperacaoAplicacao(i) {
    if (msgAplica.length <= 1 || (i + 1) == msgAplica.length) {
        fncMsgsAplic = (executandoProdutos) ? "encerraRotina();" : "acessaOpcaoAba(0,0,'@');";
    } else {
        fncMsgsAplic = "notificaOperacaoAplicacao(" + (i + 1) + ")";
    }

    if (msgAplica.length == 0) {
        eval(fncMsgsAplic);
    } else {
        showError("inform", msgAplica[i].dsmensag, "Alerta - Ayllos", fncMsgsAplic);
    }
}


// Função para carregar tela de Parametros de Impressao
function exibeParamImpressao() {

    $("#divConteudoOpcao").css("height", "160");
    $("#divAplicacoesPrincipal").css("display", "none");
    $("#divImprimir").css("display", "block");

    // Seta parametros de tela
    $("#tpmodelo", "#divImprimir").focus();
    $("#tpmodelo", "#divImprimir").val(1);
    $("#dtiniper", "#divImprimir").val('');
    $("#dtfimper", "#divImprimir").val('');
    $("#tprelato", "#divImprimir").val(1);
    $("#divImpPeriodo").css("display", "block");
    $("#dtiniper", "#frmImpressao").focus();
    $("#tpaplic2", "#divImprimir").val(nraplica).setMask('INTEGER', 'zzz.zzz', '.', '');
}


//
function controlaLayout(layout) {

    /*****************************
			FORMATA TABELA		
	******************************/
    // tabela	
    var divRegistro = $('div.divRegistros', '#divAplicacoesPrincipal');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({ 'height': '140px' });

    var ordemInicial = new Array();
    //ordemInicial = [[0,0]];
    //ordemInicial = 0;

    var arrayLargura = new Array();
    arrayLargura[0] = '60px';
    arrayLargura[1] = '130px';
    arrayLargura[2] = '35px';
    arrayLargura[3] = '60px';
    arrayLargura[4] = '60px';
    arrayLargura[5] = '75px';
    arrayLargura[7] = '60px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'right';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'right';
    arrayAlinha[6] = 'right';
    arrayAlinha[7] = 'center';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);

    // complemento
    var complemento = $('ul.complemento', '#divAplicacoesPrincipal');
    complemento.css({ 'height': '40px' });

    $('li:eq(0)', complemento).addClass('txtNormalBold');
    $('li:eq(1)', complemento).addClass('txtNormal').css({ 'width': '13%' });
    $('li:eq(2)', complemento).addClass('txtNormalBold');
    $('li:eq(3)', complemento).addClass('txtNormal').css({ 'width': '14%' });
    $('li:eq(4)', complemento).addClass('txtNormalBold');
    $('li:eq(5)', complemento).addClass('txtNormal').css({ 'width': '14%' });
    $('li:eq(6)', complemento).addClass('txtNormalBold');
    $('li:eq(7)', complemento).addClass('txtNormal').css({ 'width': '8%' });
    $('li:eq(8)', complemento).addClass('txtNormalBold');
    $('li:eq(9)', complemento).addClass('txtNormal');
    $('li:eq(10)', complemento).addClass('txtNormalBold').css({ 'width': '20%' });
    $('li:eq(11)', complemento).addClass('txtNormal').css({ 'width': '30%' });
    $('li:eq(12)', complemento).addClass('txtNormalBold');
    $('li:eq(13)', complemento).addClass('txtNormal');

    /*****************************
			FORMATA DADOS		
	******************************/

    $("#divSelecionaCarencia").hide();

    // label
    rTpaplica = $('label[for="tpaplica"]', '#frmDadosAplicacao');

    rDtresgatPos = $('label[for="dtresgat"]', '#frmDadosAplicacaoPos');
    rDtcarencPos = $('label[for="dtcarenc"]', '#frmDadosAplicacaoPos');
    rQtdiacarPos = $('label[for="qtdiacar"]', '#frmDadosAplicacaoPos');
    rFlgdebciPos = $('label[for="flgdebci"]', '#frmDadosAplicacaoPos');
    rVllanmtoPos = $('label[for="vllanmto"]', '#frmDadosAplicacaoPos');
    rTxaplicaPos = $('label[for="txaplica"]', '#frmDadosAplicacaoPos');
    rDsaplicaPos = $('label[for="dsaplica"]', '#frmDadosAplicacaoPos');
    rFlgrecnoPos = $('label[for="flgrecno"]', '#frmDadosAplicacaoPos');

    rQtdiaaplPre = $('label[for="qtdiaapl"]', '#frmDadosAplicacaoPre');
    rDtresgatPre = $('label[for="dtresgat"]', '#frmDadosAplicacaoPre');
    rQtdiacarPre = $('label[for="qtdiacar"]', '#frmDadosAplicacaoPre');
    rFlgdebciPre = $('label[for="flgdebci"]', '#frmDadosAplicacaoPre');
    rVllanmtoPre = $('label[for="vllanmto"]', '#frmDadosAplicacaoPre');
    rTxaplicaPre = $('label[for="txaplica"]', '#frmDadosAplicacaoPre');
    rDsaplicaPre = $('label[for="dsaplica"]', '#frmDadosAplicacaoPre');

    rTpmodelo = $('label[for="tpmodelo"]', '#frmImpressao');
    rDtiniper = $('label[for="dtiniper"]', '#frmImpressao');
    rTprelato = $('label[for="tprelato"]', '#frmImpressao');
    rTpaplic2 = $('label[for="tpaplic2"]', '#frmImpressao');

    rTpaplica.addClass('rotulo').css({ 'width': '200px' });

    rDtresgatPos.addClass('rotulo').css({ 'width': '225px' });
    rDtcarencPos.addClass('rotulo').css({ 'width': '225px' });
    rQtdiacarPos.addClass('rotulo').css({ 'width': '225px' });
    rFlgdebciPos.addClass('rotulo').css({ 'width': '225px' });
    rVllanmtoPos.addClass('rotulo').css({ 'width': '225px' });
    rTxaplicaPos.addClass('rotulo').css({ 'width': '225px' });
    rDsaplicaPos.addClass('rotulo').css({ 'width': '225px' });
    rFlgrecnoPos.addClass('rotulo').css({ 'width': '225px' });

    rQtdiaaplPre.addClass('rotulo').css({ 'width': '225px' });
    rDtresgatPre.addClass('rotulo').css({ 'width': '225px' });
    rQtdiacarPre.addClass('rotulo').css({ 'width': '225px' });
    rFlgdebciPre.addClass('rotulo').css({ 'width': '225px' });
    rVllanmtoPre.addClass('rotulo').css({ 'width': '225px' });
    rTxaplicaPre.addClass('rotulo').css({ 'width': '225px' });
    rDsaplicaPre.addClass('rotulo').css({ 'width': '225px' });

    rTpmodelo.addClass('rotulo').css({ 'width': '150px' });
    rDtiniper.addClass('rotulo').css({ 'width': '150px' });
    rTprelato.addClass('rotulo').css({ 'width': '150px' });
    rTpaplic2.addClass('rotulo').css({ 'width': '150px' });

    // campo
    cTpaplica = $('#tpaplica', '#frmDadosAplicacao');

    cDtresgatPos = $('#dtresgat', '#frmDadosAplicacaoPos');
    cDtcarencPos = $('#dtcarenc', '#frmDadosAplicacaoPos');
    cQtdiacarPos = $('#qtdiacar', '#frmDadosAplicacaoPos');
    cFlgdebciPos = $('#flgdebci', '#frmDadosAplicacaoPos');
    cVllanmtoPos = $('#vllanmto', '#frmDadosAplicacaoPos');
    cTxaplicaPos = $('#txaplica', '#frmDadosAplicacaoPos');
    cDsaplicaPos = $('#dsaplica', '#frmDadosAplicacaoPos');
    cFlgrecnoPos = $('#flgrecno', '#frmDadosAplicacaoPos');

    cQtdiaaplPre = $('#qtdiaapl', '#frmDadosAplicacaoPre');
    cDtresgatPre = $('#dtresgat', '#frmDadosAplicacaoPre');
    cQtdiacarPre = $('#qtdiacar', '#frmDadosAplicacaoPre');
    cFlgdebciPre = $('#flgdebci', '#frmDadosAplicacaoPre');
    cVllanmtoPre = $('#vllanmto', '#frmDadosAplicacaoPre');
    cTxaplicaPre = $('#txaplica', '#frmDadosAplicacaoPre');
    cDsaplicaPre = $('#dsaplica', '#frmDadosAplicacaoPre');

    cTpmodelo = $('#tpmodelo', '#frmImpressao');
    cDtiniper = $('#dtiniper', '#frmImpressao');
    cDtfimper = $('#dtfimper', '#frmImpressao');
    cTprelato = $('#tprelato', '#frmImpressao');
    cTpaplic2 = $('#tpaplic2', '#frmImpressao');

    cTpaplica.css({ 'width': '115px' });

    cDtresgatPos.css({ 'width': '90px' });
    cDtcarencPos.css({ 'width': '90px' });
    cQtdiacarPos.css({ 'width': '70px', 'text-align': 'right' });
    cFlgdebciPos.css({ 'width': '90px' });
    cVllanmtoPos.css({ 'width': '90px', 'text-align': 'right' });
    cTxaplicaPos.css({ 'width': '90px', 'text-align': 'right' });
    cDsaplicaPos.css({ 'width': '150px', 'text-align': 'center' });
    cFlgrecnoPos.css({ 'width': '90px' });

    cQtdiaaplPre.css({ 'width': '90px', 'text-align': 'right' });
    cDtresgatPre.css({ 'width': '90px' });
    cQtdiacarPre.css({ 'width': '70px', 'text-align': 'right' });
    cFlgdebciPre.css({ 'width': '90px' });
    cVllanmtoPre.css({ 'width': '90px', 'text-align': 'right' });
    cTxaplicaPre.css({ 'width': '90px', 'text-align': 'right' });
    cDsaplicaPre.css({ 'width': '150px', 'text-align': 'center' });

    cTpmodelo.css({ 'width': '125px' });
    cDtiniper.css({ 'width': '58px' });
    cDtfimper.css({ 'width': '58px' });
    cTprelato.css({ 'width': '125px' });
    cTpaplic2.addClass('pesquisa').css({ 'width': '80px', 'text-align': 'right' }).setMask('INTEGER', 'zzz.zzz', '.', '');

    cDtiniper.setMask("STRING", "99/9999", "/", "");
    cDtiniper.val('');
    cDtfimper.setMask("STRING", "99/9999", "/", "");
    cDtfimper.val('');

    if (parseFloat($('#VlBloq').next().html()) == 0 && parseFloat($('#VlSldCntInvest').html()) == 0) {
        $("#flgdebci", "#frmDadosAplicacaoPos").desabilitaCampo();
    }

    controlaFocoEnter('divConteudoOpcao');


    $('input, select', '#frmDadosAplicacaoPos').habilitaCampo();
    $('input, select', '#frmDadosAplicacao').habilitaCampo();

    if (parseFloat($('#VlBloq').next().html()) == 0 && parseFloat($('#VlSldCntInvest').html()) == 0) {
        cFlgdebciPos.desabilitaCampo();
    }
    cDtcarencPos.desabilitaCampo();
    cQtdiacarPos.desabilitaCampo();
    cTxaplicaPos.desabilitaCampo();
    cDsaplicaPos.desabilitaCampo();
    cDtresgatPos.desabilitaCampo();

    $('input, select', '#frmDadosAplicacaoPre').habilitaCampo();
    if (parseFloat($('#VlBloq').next().html()) == 0 && parseFloat($('#VlSldCntInvest').html()) == 0) {
        cFlgdebciPre.desabilitaCampo();
    }
    cQtdiacarPre.desabilitaCampo();
    cTxaplicaPre.desabilitaCampo();
    cDsaplicaPre.desabilitaCampo();

    highlightObjFocus($('#frmDadosAplicacao'));
    highlightObjFocus($('#frmDadosAplicacaoPos'));
    highlightObjFocus($('#frmDadosAplicacaoPre'));
    highlightObjFocus($('#frmImpressao'));

    $('input', '#frmImpressao').focus(function () {
        this.select();
    });

    layoutPadrao();

    return false;
}

//
function formataResgate() {

    $("#divConteudoOpcao").css("height", "165px");

    // label
    rTpresgat = $('label[for="tpresgat"]', '#frmResgate');
    rVlresgat = $('label[for="vlresgat"]', '#frmResgate');
    rDtresgat = $('label[for="dtresgat"]', '#frmResgate');
    rFlgctain = $('label[for="flgctain"]', '#frmResgate');
    rCdopera2 = $('label[for="cdopera2"]', '#frmResgate');
    rCddsenha = $('label[for="cddsenha"]', '#frmResgate');
    rFlautori = $('label[for="flautori"]', '#frmResgate');

    rTpresgat.addClass('rotulo').css({ 'width': '250px' });
    rVlresgat.addClass('rotulo').css({ 'width': '250px' });
    rDtresgat.addClass('rotulo').css({ 'width': '250px' });
    rFlgctain.addClass('rotulo').css({ 'width': '250px' });
    rCdopera2.addClass('rotulo').css({ 'width': '250px' });
    rCddsenha.addClass('rotulo').css({ 'width': '250px' });
    rFlautori.addClass('rotulo').css({ 'width': '250px' });

    // input
    cTpresgat = $('#tpresgat', '#frmResgate');
    cVlresgat = $('#vlresgat', '#frmResgate');
    cDtresgat = $('#dtresgat', '#frmResgate');
    cFlgctain = $('#flgctain', '#frmResgate');
    cCdopera2 = $('#cdopera2', '#frmResgate');
    cCddsenha = $('#cddsenha', '#frmResgate');
    cFlautori = $('#flautori', '#frmResgate');

    cTpresgat.css({ 'width': '90px' });
    cVlresgat.css({ 'width': '90px', 'text-align': 'right' });
    cDtresgat.css({ 'width': '90px' });
    cFlgctain.css({ 'width': '90px' }).desabilitaCampo();
    cCdopera2.css({ 'width': '90px' });
    cCddsenha.css({ 'width': '90px' });


    $('input, select', '#frmResgate').habilitaCampo();
    cFlgctain.desabilitaCampo();
    cDtresgat.desabilitaCampo();

    divAutoriza = $('#dvautoriza');
    divAutoriza.hide();

    $("#divConteudoOpcao").css("height", "200px");

    cFlautori.click(function () {
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


//
function formataTabelaResgate() {

    $("#divConteudoOpcao").css("height", "220px");

    // tabela	
    var divRegistro = $('div.divRegistros', '#divOpcoes');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({ 'height': '160px' });

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '55px';
    arrayLargura[1] = '70px';
    arrayLargura[2] = '100px';
    arrayLargura[3] = '55px';
    arrayLargura[4] = '100px';
    arrayLargura[5] = '45px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'left';
    arrayAlinha[1] = 'right';
    arrayAlinha[2] = 'left';
    arrayAlinha[3] = 'left';
    arrayAlinha[4] = 'left';
    arrayAlinha[5] = 'center';
    arrayAlinha[6] = 'right';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);
    ajustarCentralizacao();
    return false;
}

//
function formataAcumulaConsulta() {

    // Aumenta tamanho do div onde o conte&uacute;do da op&ccedil;&atilde;o ser&aacute; visualizado
    $("#divConteudoOpcao").css("height", "275px");

    $("#divAcumula").css("display", "none");
    $("#divOpcoes").css("display", "block");

    rCampo1 = $('label[for="campo1"]', '#frmDadosAcumula');
    rCampo2 = $('label[for="campo2"]', '#frmDadosAcumula');
    rCampo3 = $('label[for="campo3"]', '#frmDadosAcumula');
    rCampo4 = $('label[for="campo4"]', '#frmDadosAcumula');
    rCampo5 = $('label[for="campo5"]', '#frmDadosAcumula');
    rCampo6 = $('label[for="campo6"]', '#frmDadosAcumula');
    rCampo7 = $('label[for="campo7"]', '#frmDadosAcumula');

    rCampo1.addClass('rotulo').css({ 'width': '134px' });
    rCampo2.addClass('rotulo').css({ 'width': '134px' });
    rCampo3.addClass('rotulo-linha').css({ 'width': '135px' });
    rCampo4.addClass('rotulo').css({ 'width': '134px' });
    rCampo5.addClass('rotulo-linha').css({ 'width': '135px' });
    rCampo6.addClass('rotulo').css({ 'width': '134px' });
    rCampo7.addClass('rotulo-linha').css({ 'width': '135px' });

    cCampo1 = $('#campo1', '#frmDadosAcumula');
    cCampo2 = $('#campo2', '#frmDadosAcumula');
    cCampo3 = $('#campo3', '#frmDadosAcumula');
    cCampo4 = $('#campo4', '#frmDadosAcumula');
    cCampo5 = $('#campo5', '#frmDadosAcumula');
    cCampo6 = $('#campo6', '#frmDadosAcumula');
    cCampo7 = $('#campo7', '#frmDadosAcumula');

    cCampo1.css({ 'width': '100px' });
    cCampo2.css({ 'width': '100px' });
    cCampo3.css({ 'width': '100px' });
    cCampo4.css({ 'width': '100px' });
    cCampo5.css({ 'width': '100px' });
    cCampo6.css({ 'width': '100px' });
    cCampo7.css({ 'width': '100px' });

    $('input, select', '#frmDadosAcumula').desabilitaCampo();

}

//
function formataAcumulaSimular() {

    // Aumenta tamanho do div onde o conte&uacute;do da op&ccedil;&atilde;o ser&aacute; visualizado
    $("#divConteudoOpcao").css("height", "270px");

    $("#divAcumula").css("display", "none");
    $("#divOpcoes").css("display", "block");

    /************************
		FORMULARIO SIMULAR
	*************************/
    // label frmSimular
    rTpaplica = $('label[for="tpaplica"]', '#frmSimular');
    rTpaplica.addClass('rotulo').css({ 'width': '106px' });

    // campo frmSimular
    cTpaplica = $('#tpaplica', '#frmSimular');
    cTpaplica.addClass('campo').css({ 'width': '115px' });

    /************************
	 FORMULARIO SIMULA RDCPRE
	*************************/
    // label frmSimulaRDCPRE
    rVlaplica = $('label[for="vlaplica"]', '#frmSimulaRDCPRE');
    rQtdiaapl = $('label[for="qtdiaapl"]', '#frmSimulaRDCPRE');
    rDtvencto = $('label[for="dtvencto"]', '#frmSimulaRDCPRE');
    rTxaplica = $('label[for="txaplica"]', '#frmSimulaRDCPRE');
    rTxaplmes = $('label[for="txaplmes"]', '#frmSimulaRDCPRE');
    rVlsldrdc = $('label[for="vlsldrdc"]', '#frmSimulaRDCPRE');

    rVlaplica.addClass('rotulo').css({ 'width': '104px' });
    rQtdiaapl.addClass('rotulo-linha').css({ 'width': '82px' });
    rDtvencto.addClass('rotulo-linha').css({ 'width': '82px' });
    rTxaplica.addClass('rotulo').css({ 'width': '104px' });
    rTxaplmes.addClass('rotulo-linha').css({ 'width': '82px' });
    rVlsldrdc.addClass('rotulo-linha').css({ 'width': '82px' });

    // campo frmSimulaRDCPRE
    cVlaplica = $('#vlaplica', '#frmSimulaRDCPRE');
    cQtdiaapl = $('#qtdiaapl', '#frmSimulaRDCPRE');
    cDtvencto = $('#dtvencto', '#frmSimulaRDCPRE');
    cTxaplica = $('#txaplica', '#frmSimulaRDCPRE');
    cTxaplmes = $('#txaplmes', '#frmSimulaRDCPRE');
    cVlsldrdc = $('#vlsldrdc', '#frmSimulaRDCPRE');

    cVlaplica.addClass('campo').css({ 'width': '80px', 'text-align': 'right' });
    cQtdiaapl.addClass('campo').css({ 'width': '70px', 'text-align': 'right' });
    cDtvencto.addClass('campo').css({ 'width': '70px' });
    cTxaplica.addClass('campoTelaSemBorda').css({ 'width': '80px', 'text-align': 'right' });
    cTxaplmes.addClass('campoTelaSemBorda').css({ 'width': '70px', 'text-align': 'right' });
    cVlsldrdc.addClass('campoTelaSemBorda').css({ 'width': '70px', 'text-align': 'right' });

    /************************
	 FORMULARIO SIMULA RDCPOS
	*************************/
    // label frmSimulaRDCPOS
    rVlaplica = $('label[for="vlaplica"]', '#frmSimulaRDCPOS');
    rQtdiacar = $('label[for="qtdiacar"]', '#frmSimulaRDCPOS');
    rDtcarenc = $('label[for="dtcarenc"]', '#frmSimulaRDCPOS');
    rDtvencto = $('label[for="dtvencto"]', '#frmSimulaRDCPOS');
    rTxaplica = $('label[for="txaplica"]', '#frmSimulaRDCPOS');
    rTxaplmes = $('label[for="txaplmes"]', '#frmSimulaRDCPOS');

    rVlaplica.addClass('rotulo').css({ 'width': '104px' });
    rQtdiacar.addClass('rotulo-linha').css({ 'width': '104px' });
    rDtcarenc.addClass('rotulo-linha').css({ 'width': '104px' });
    rDtvencto.addClass('rotulo').css({ 'width': '104px' });
    rTxaplica.addClass('rotulo-linha').css({ 'width': '90px' });
    rTxaplmes.addClass('rotulo-linha').css({ 'width': '82px' });

    // campo frmSimulaRDCPOS
    cVlaplica = $('#vlaplica', '#frmSimulaRDCPOS');
    cQtdiacar = $('#qtdiacar', '#frmSimulaRDCPOS');
    cDtcarenc = $('#dtcarenc', '#frmSimulaRDCPOS');
    cDtvencto = $('#dtvencto', '#frmSimulaRDCPOS');
    cTxaplica = $('#txaplica', '#frmSimulaRDCPOS');
    cTxaplmes = $('#txaplmes', '#frmSimulaRDCPOS');

    cVlaplica.addClass('campo').css({ 'width': '80px', 'text-align': 'right' });
    cQtdiacar.addClass('campoTelaSemBorda').css({ 'width': '55px', 'text-align': 'right' });
    cDtcarenc.addClass('campoTelaSemBorda').css({ 'width': '70px', 'text-align': 'right' });
    cDtvencto.addClass('campo').css({ 'width': '80px', 'text-align': 'right' });
    cTxaplica.addClass('campoTelaSemBorda').css({ 'width': '70px', 'text-align': 'right' });
    cTxaplmes.addClass('campoTelaSemBorda').css({ 'width': '70px', 'text-align': 'right' });

    if ($.browser.msie) {
        $('#divCarencia', '#frmSimulaRDCPOS').css({ 'margin-left': '-500px' });
    } else {
        $('#divCarencia', '#frmSimulaRDCPOS').css({ 'margin-left': '5px', 'margin-top': '26px' });
    }

    layoutPadrao();
    return false;
}

function acessaOpcaoResgates(automatica) {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando op&ccedil;&atilde;o para cadastro de resgate ...");

    // Executa script de consulta através de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/aplicacoes/resgatar_varias.php",
        data: {
            nrdconta: nrdconta,
            flcadrgt: "yes",
            flgauto: (automatica ? "true" : "false"),
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

// Função para listar os resgates a serem realizados(de forma automatica)
function listarResgatesAuto(dtmvtolt) {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, validando resgates ...");

    var slresgat = $("#slresgat", "#frmResgateVarias").val().replace(/\./g, "")
    var vlresgat = $("#vlresgat", "#frmResgateVarias").val().replace(/\./g, "");
    var dtresgat = $("#dtresgat", "#frmResgateVarias").val();
    var flgctain = $("#flgctain", "#frmResgateVarias").val();
    var flgsenha = "0";
    var cdopera2 = $("#cdopera2", "#frmResgateVarias").val();
    var cddsenha = $("#cddsenha", "#frmResgateVarias").val();
    var flgerror = false;

    // Valida valor do resgate
    if ((vlresgat == "") || (!validaNumero(vlresgat, true, 0, 0)) || (parseFloat(vlresgat.replace(/\,/g, ".")) > parseFloat(slresgat.replace(/\,/g, ".")))) {
        hideMsgAguardo();
        showError("error", "Valor do resgate inv&aacute;lido.", "Alerta - Ayllos", "$('#vlresgat','#frmResgateVarias').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    /*valida aqui Tiago resgate varios automatico*/
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/aplicacoes/resgate_valida_limite_operador.php",
        data: {
            nrdconta: nrdconta,
            vlresgat: vlresgat,
            cdopera2: cdopera2,
            cddsenha: cddsenha,
            flgsenha: flgsenha,
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
        },
        async: false
    });

    /*Verifica se houve erro na chamado do ajax acima*/
    if (flgerror == true) {
        return false;
    }

    // Valida data de resgate
    if (dtresgat == "" || !validaData(dtresgat) || (dataParaTimestamp(dtresgat) < dtmvtolt)) {
        hideMsgAguardo();
        showError("error", "Data de resgate inv&aacute;lida.", "Alerta - Ayllos", "$('#dtresgat','#frmResgateVarias').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    lstQuestionaCliente = new Array();
    lstDadosResgate = new Array();

    var camposPc = '';
    camposPc = retornaCampos(lstQuestionaCliente, '|');

    var dadosPrc = '';
    dadosPrc = retornaValores(lstQuestionaCliente, ';', '|', camposPc);

    var camposPc2 = '';
    camposPc2 = retornaCampos(lstDadosResgate, '|');

    var dadosPrc2 = '';
    dadosPrc2 = retornaValores(lstDadosResgate, ';', '|', camposPc2);

    // Executa script de consulta através de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/aplicacoes/resgate_automatico.php",
        data: {
            nrdconta: nrdconta,
            slresgat: slresgat,
            vlresgat: vlresgat,
            vlrgtini: vlresgat,
            dtresgat: dtresgat,
            flgctain: flgctain,
            camposPc: camposPc,
            dadosPrc: dadosPrc,
            camposPc2: camposPc2,
            dadosPrc2: dadosPrc2,
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

// Função para listar os resgates a serem realizados(de forma manual)
function listarResgatesManual(dtmvtolt) {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, validando resgates ...");

    var slresgat = $("#slresgat", "#frmResgateVarias").val().replace(/\./g, "")
    var vlresgat = $("#vlresgat", "#frmResgateVarias").val().replace(/\./g, "");
    var dtresgat = $("#dtresgat", "#frmResgateVarias").val();
    var flgctain = $("#flgctain", "#frmResgateVarias").val();
    var flgsenha = "0";
    var cdopera2 = $("#cdopera2", "#frmResgateVarias").val();
    var cddsenha = $("#cddsenha", "#frmResgateVarias").val();
    var flgerror = false;

    // Valida valor do resgate
    if (vlresgat == "" || !validaNumero(vlresgat, true, 0, 0) || (parseFloat(parseFloat(vlresgat.replace(/\,/g, "."))) > parseFloat(slresgat.replace(/\,/g, ".")))) {
        hideMsgAguardo();
        showError("error", "Valor do resgate inv&aacute;lido.", "Alerta - Ayllos", "$('#vlresgat','#frmResgateVarias').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    // Valida data de resgate
    if (dtresgat == "" || !validaData(dtresgat) || (dataParaTimestamp(dtresgat) < dtmvtolt)) {
        hideMsgAguardo();
        showError("error", "Data de resgate inv&aacute;lida.", "Alerta - Ayllos", "$('#dtresgat','#frmResgateVarias').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    /*valida aqui Tiago resgate varios automatico*/

    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/aplicacoes/resgate_valida_limite_operador.php",
        data: {
            nrdconta: nrdconta,
            vlresgat: vlresgat,
            cdopera2: cdopera2,
            cddsenha: cddsenha,
            flgsenha: flgsenha,
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
        },
        async: false
    });

    /*Verifica se houve erro na chamado do ajax acima*/
    if (flgerror == true) {
        return false;
    }

    // Executa script de consulta através de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/aplicacoes/resgate_manual.php",
        data: {
            cdopera2: cdopera2,
            nrdconta: nrdconta,
            slresgat: slresgat,
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

function formataResgatarVarias() {

    $("#divConteudoOpcao").css("height", "165px");

    // label
    rVlresgat = $('label[for="vlresgat"]', '#frmResgateVarias');
    rSlresgat = $('label[for="slresgat"]', '#frmResgateVarias');
    rDtresgat = $('label[for="dtresgat"]', '#frmResgateVarias');
    rFlgctain = $('label[for="flgctain"]', '#frmResgateVarias');
    rCdopera2 = $('label[for="cdopera2"]', '#frmResgateVarias');
    rCddsenha = $('label[for="cddsenha"]', '#frmResgateVarias');
    rFlautori = $('label[for="flautori"]', '#frmResgateVarias');

    rVlresgat.addClass('rotulo').css({ 'width': '250px' });
    rSlresgat.addClass('rotulo').css({ 'width': '250px' });
    rDtresgat.addClass('rotulo').css({ 'width': '250px' });
    rFlgctain.addClass('rotulo').css({ 'width': '250px' });
    rCdopera2.addClass('rotulo').css({ 'width': '250px' });
    rCddsenha.addClass('rotulo').css({ 'width': '250px' });
    rFlautori.addClass('rotulo').css({ 'width': '250px' });


    // input
    cVlresgat = $('#vlresgat', '#frmResgateVarias');
    cSlresgat = $('#slresgat', '#frmResgateVarias');
    cDtresgat = $('#dtresgat', '#frmResgateVarias');
    cFlgctain = $('#flgctain', '#frmResgateVarias');
    cCdopera2 = $('#cdopera2', '#frmResgateVarias');
    cCddsenha = $('#cddsenha', '#frmResgateVarias');
    cFlautori = $('#flautori', '#frmResgateVarias');

    cVlresgat.css({ 'width': '90px', 'text-align': 'right' });
    cSlresgat.css({ 'width': '90px', 'text-align': 'right' });
    cDtresgat.css({ 'width': '90px' });
    cFlgctain.css({ 'width': '90px' }).desabilitaCampo();
    cCdopera2.css({ 'width': '90px' });
    cCddsenha.css({ 'width': '90px' });


    $('input, select', '#frmResgateVarias').habilitaCampo();
    cFlgctain.desabilitaCampo();
    cDtresgat.desabilitaCampo();
    divAutoriza = $('#dvautoriza');
    divAutoriza.hide();

    cFlautori.click(function () {
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

function voltarDivResgateAutoManual(cadastrou) {
    $("#divConteudoOpcao").css("height", "165px");

    $("#divAutoManual").css("display", "none");

    if (cadastrou == "true") {
        lstResgatesManual = "";

        $("#divAplicacoesPrincipal").css("display", "block");

        // Aumenta tamanho do div onde o conteúdo da opção será visualizado
        $("#divConteudoOpcao").css("height", "220px");

        acessaOpcaoAba(0, 0, 0);
    }
    else
        $("#divOpcoes").css("display", "block");


    // Zerar variáveis globais utilizadas na opção de resgate
    dtresgat = "";
    nrdocmto = 0;
}

//================== RESGATAR VARIAS (CANCELAMENTO e PROXIMOS) ======================

// Função para consultar proximos resgates da conta
function obtemResgatesVarias(flgcance) {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando resgates ...");

    // Executa script de consulta através de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + (flgcance ? "telas/atenda/aplicacoes/resgate_varias_cancelamento.php" : "telas/atenda/aplicacoes/resgate_varias_proximos.php"),
        data: {
            nrdconta: nrdconta,
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

function preencheZero(numero, qtde) {
    var str = '' + numero;
    while (str.length < qtde) {
        str = '0' + str;
    }
    return str;
}

// Função para validar parametros da tela de Impressao
function imprimirValidar() {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, validando impress&atilde;o ...");

    var tpmodelo = $("#tpmodelo", "#frmImpressao").val();
    var dtiniper = $("#dtiniper", "#frmImpressao").val();
    var dtfimper = $("#dtfimper", "#frmImpressao").val();
    var tprelato = $("#tprelato", "#frmImpressao").val();
    var tpaplic2 = $("#tpaplic2", "#frmImpressao").val();
    var dtmvtolt = $("#dtdehoje", "#frmImpressao").val();

    if (!dtiniper) { dtiniper = '00/0000' }
    if (!dtfimper) { dtfimper = '00/0000' }
    if (!tpaplic2) { tpaplic2 = '0' }

    if (tpmodelo == '1') { // apenas se for 'Demonstrativo'

        var dtArrIni = dtiniper.split('/');
        var dtArrFim = dtfimper.split('/');

        var dtArrHoj = dtmvtolt.split('/');
        var dtRefIni = parseFloat(dtArrIni[1] + '' + dtArrIni[0]);
        var dtRefFim = parseFloat(dtArrFim[1] + '' + dtArrFim[0]);

        var dtdehoje = parseFloat(dtArrHoj[2] + '' + dtArrHoj[1]);
        var dtlimite = parseFloat(dtdehoje) - 100; // Como é um numero, ex. 201206, subtraindo 100, numericamente passa a ser 1 ano anterior, no caso, 201106 (12 meses)

        if (((parseFloat(dtArrIni[0]) == 0) || (parseFloat(dtArrIni[0]) > 12) || (parseFloat(dtArrIni[1]) == 0))) {
            hideMsgAguardo();
            showError("error", "Per&iacute;odo informado &eacute; inv&aacute;lido! ", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            $("#dtiniper", "#frmImpressao").focus();
            return false;
        } else {
            if (dtRefIni > dtdehoje) {
                hideMsgAguardo();
                showError("error", "Per&iacute;odo informado &eacute; superior a data atual: " + dtiniper, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
                $("#dtiniper", "#frmImpressao").focus();
                return false;
            }
            else if (dtRefFim < dtRefIni) {
                hideMsgAguardo();
                showError("error", "Per&iacute;odo final superior ao per&iacute;odo inicial: " + dtiniper, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
                $("#dtiniper", "#frmImpressao").focus();
                return false;
            }
        }
    }

    if (tprelato == 1 && (tpaplic2 == '' || tpaplic2 == '0')) {
        hideMsgAguardo();
        showError("error", "Aplica&ccedil;&atilde;o deve ser informada!", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        $("#tpaplic2", "#frmImpressao").focus();
        return false;
    }

    //function imprimirRelatorios(tpmodelo, dtiniper, dtfimper, tpaplic2, tprelato) {

    $('#sidlogin', '#frmTipo').remove();
    $('#nrdconta', '#frmTipo').remove();
    $('#tpmodelo', '#frmTipo').remove();
    $('#dtiniper', '#frmTipo').remove();
    $('#dtfimper', '#frmTipo').remove();
    $('#tprelato', '#frmTipo').remove();
    $('#tpaplic2', '#frmTipo').remove();

    // Se não deu erro ao abrir a nova janela, então submete o formulário
    $('#frmImprimir').append('<input type="hidden" id="nrdconta" name="nrdconta" />');
    $('#frmImprimir').append('<input type="hidden" id="tpmodelo" name="tpmodelo" />');
    $('#frmImprimir').append('<input type="hidden" id="dtiniper" name="dtiniper" />');
    $('#frmImprimir').append('<input type="hidden" id="dtfimper" name="dtfimper" />');
    $('#frmImprimir').append('<input type="hidden" id="tprelato" name="tprelato" />');
    $('#frmImprimir').append('<input type="hidden" id="tpaplic2" name="tpaplic2" />');

    $("#nrdconta", "#frmImprimir").val(nrdconta);
    $("#tpmodelo", "#frmImprimir").val(tpmodelo);
    $("#dtiniper", "#frmImprimir").val(dtiniper);
    $("#dtfimper", "#frmImprimir").val(dtfimper);
    $("#tprelato", "#frmImprimir").val(tprelato);
    $("#tpaplic2", "#frmImprimir").val(tpaplic2);

    var action = UrlSite + 'telas/atenda/aplicacoes/imprimir_relatorio.php';
    var callafter = "bloqueiaFundo(divRotina);";

    carregaImpressaoAyllos("frmImprimir", action, callafter);
}

//adiciona ou retira a aplicacao da lista (resgates)
function selecionaResgateVarias(num, app, data, documento, idtipapl) {

    documento = retiraCaracteres(documento, "0123456789", true);
    if ($("#appresg" + num).is(":checked")) {
        var campos = new Object();
        campos["auxidres"] = num;
        campos["nraplica"] = app;
        campos["dtresgat"] = data;
        campos["nrdocmto"] = documento;
        campos["idtipapl"] = idtipapl;
        lstResgatesChecked.push(campos);
    } else {
        for (i = 0; i < lstResgatesChecked.length; i++) {
            if (lstResgatesChecked[i]["auxidres"] == num) {
                lstResgatesChecked.splice(i, 1);
            }
        }
    }
}

function selLinhaProVarias() {
    $("#trResgateVarias" + idLinhaProVar).click();
}

function selLinhaCanVarias() {
    $("#trResgateVarias" + idLinhaCanVar).click();
}

function viewComplementoResgVarias(indice, from) {
    if (from == 'C') {
        idLinhaCanVar = parseInt(indice) + 1;
    } else {
        idLinhaProVar = parseInt(indice) + 1;
    }
    $("#tdSoli").html(lstResgates[indice].dtmvtolt);
    $("#tdHist").html(lstResgates[indice].dshistor);
    $("#tdOper").html(lstResgates[indice].nmoperad);
    $("#tdHres").html(lstResgates[indice].hrtransa);
}

//funcao que verifica se ha resgates selecionados para cancelar
function verificaResgates() {
    if (lstResgatesChecked.length > 0) {
        showConfirmacao('Deseja cancelar o(s) resgate(s)?', 'Confirma&ccedil;&atilde;o - Ayllos', 'cancelarResgatesVarias()', metodoBlock, 'sim.gif', 'nao.gif'); return false;
    } else {
        showError("inform", "Marque os resgates que deseja cancelar.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
    }
}

function cancelarResgatesVarias() {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, cancelando resgate(s) ...");

    var camposPc = '';
    camposPc = retornaCampos(lstResgatesChecked, '|');

    var dadosPrc = '';
    dadosPrc = retornaValores(lstResgatesChecked, ';', '|', camposPc);

    // Executa script de consulta através de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/aplicacoes/resgate_cancelar_varias.php",
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

function continuaListarResgates(resposta, restanteValor) {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, validando resgates ...");

    var slresgat = $("#slresgat", "#frmResgateVarias").val().replace(/\./g, "")
    var vlrgtini = $("#vlresgat", "#frmResgateVarias").val().replace(/\./g, "");
    var dtresgat = $("#dtresgat", "#frmResgateVarias").val();
    var flgctain = $("#flgctain", "#frmResgateVarias").val();

    lstQuestionaCliente[lstQuestionaCliente.length - 1].resposta = resposta;

    var camposPc = '';
    camposPc = retornaCampos(lstQuestionaCliente, '|');

    var dadosPrc = '';
    dadosPrc = retornaValores(lstQuestionaCliente, ';', '|', camposPc);

    var camposPc2 = '';
    camposPc2 = retornaCampos(lstDadosResgate, '|');

    var dadosPrc2 = '';
    dadosPrc2 = retornaValores(lstDadosResgate, ';', '|', camposPc2);

    // Executa script de consulta através de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/aplicacoes/resgate_automatico.php",
        data: {
            nrdconta: nrdconta,
            slresgat: slresgat,
            vlresgat: restanteValor,
            vlrgtini: vlrgtini,
            dtresgat: dtresgat,
            flgctain: flgctain,
            camposPc: camposPc,
            dadosPrc: dadosPrc,
            camposPc2: camposPc2,
            dadosPrc2: dadosPrc2,
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

function formataTabelaResgateCheck() {

    $("#divConteudoOpcao").css("height", "240px");

    // tabela	
    var divRegistro = $('div.divRegistros', '#divOpcoes');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({ 'height': '160px' });

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();

    arrayLargura[0] = '1px';   //dtSolic (hidden)
    arrayLargura[1] = '20px';   //check
    arrayLargura[2] = '60px';	//aplicacao
    arrayLargura[3] = '60px';	//data
    arrayLargura[4] = '70px';	//documento
    arrayLargura[5] = '60px';	//tipo
    arrayLargura[6] = '130px';	//situacao

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'right';
    arrayAlinha[5] = 'center';
    arrayAlinha[6] = 'center';
    arrayAlinha[7] = 'right';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);

}

function formataTabelaResgateNoCheck() {

    $("#divConteudoOpcao").css("height", "240px");

    // tabela	
    var divRegistro = $('div.divRegistros', '#divOpcoes');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({ 'height': '160px' });

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '1px';	//dtSolic (hidden)
    arrayLargura[1] = '70px';	//aplicacao
    arrayLargura[2] = '70px';	//data
    arrayLargura[3] = '70px';	//documento
    arrayLargura[4] = '90px';	//tipo
    arrayLargura[5] = '110px';	//situacao	

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'right';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'right';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'center';
    arrayAlinha[6] = 'right';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);

}

function formataTabelaResgateAutomatico() {

    $("#divConteudoOpcao").css("height", "230px");

    /*****************************
			FORMATA TABELA		
	******************************/
    // tabela	
    var divDados = $('div.divRegistros', '#divAutoManual');
    var tabela = $('table', divDados);
    var linha = $('table > tbody > tr', divDados);

    divDados.css({ 'height': '140px' });

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '60px';
    arrayLargura[1] = '128px';
    arrayLargura[2] = '50px';
    arrayLargura[3] = '60px';
    arrayLargura[4] = '70px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'right';
    arrayAlinha[5] = 'right';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);

    // complemento
    var complemento = $('ul.complemento', '#divAutoManual');

    $('li:eq(0)', complemento).addClass('txtNormalBold');
    $('li:eq(1)', complemento).addClass('txtNormal').css({ 'width': '15%' });
    $('li:eq(2)', complemento).addClass('txtNormalBold');
    $('li:eq(3)', complemento).addClass('txtNormal').css({ 'width': '11%' });
    $('li:eq(4)', complemento).addClass('txtNormalBold');
    $('li:eq(5)', complemento).addClass('txtNormal').css({ 'width': '11%' });

}

// Função para cadastro de varios resgates
function validaDiferenca(formaResgate, flmensag, nrdconta, dtresgat, flgctain) {

    var msg = "O valor total selecionado n&atilde;o confere com o valor total informado. Deseja realmente fazer o resgate?";

    if (parseFloat($("#tdTotSel").html().replace(",", ".")) == 0) {
        showError("error", "Selecione as aplica&ccedil;&otilde;es que deseja resgatar.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    if (parseFloat($("#tdDifer").html().replace(",", ".")) == 0) {
        cadastrarVariosResgates(formaResgate, flmensag, nrdconta, dtresgat, flgctain);
    } else {
        showConfirmacao(msg, "Confirma&ccedil;&atilde;o - Ayllos", 'cadastrarVariosResgates(\'' + formaResgate + '\', \'' + flmensag + '\', \'' + nrdconta + '\', \'' + dtresgat + '\', \'' + flgctain + '\')', 'voltarDivPrincipal()', "sim.gif", "nao.gif");
    }
}

// Função para cadastro de varios resgates
function cadastrarVariosResgates(formaResgate, flmensag, nrdconta, dtresgat, flgctain) {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, " + (flmensag == "yes" ? "validando" : "cadastrando") + " resgates ...");

    var camposPc = '';
    var dadosPrc = '';
    var cdopera2 = $("#cdopera2", "#frmResgateVarias").val();

    if (formaResgate == "automatica") {
        camposPc = retornaCampos(lstDadosResgate, '|');
        dadosPrc = retornaValores(lstDadosResgate, ';', '|', camposPc);
    } else {

        for (var i = 0; i < lstResgatesManual.length; i++) {
            if (lstResgatesManual[i].tpresgat == "2")
                lstResgatesManual[i].vlresgat = 0;
        }

        camposPc = retornaCampos(lstResgatesManual, '|');
        dadosPrc = retornaValores(lstResgatesManual, ';', '|', camposPc);
    }

    // Executa script de consulta através de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/aplicacoes/resgate_cadastrar_varios.php",
        data: {
            cdoperad: cdopera2,
            nrdconta: nrdconta,
            dtresgat: dtresgat,
            flgctain: flgctain,
            flmensag: flmensag,
            camposPc: camposPc,
            dadosPrc: dadosPrc,
            formargt: formaResgate,
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

function formataTabelaResgateManual() {

    $("#divConteudoOpcao").css("height", "280px");

    // tabela	
    var divRegistro = $('div.divRegistros', '#divAutoManual');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({ 'height': '160px' });

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '20px';   //check
    arrayLargura[1] = '55px';	//data
    arrayLargura[2] = '100px';	//aplicacao
    arrayLargura[3] = '50px';	//documento
    arrayLargura[4] = '70px';	//vencto
    arrayLargura[5] = '60px';	//saldo
    arrayLargura[6] = '60px';	//saldo resgate

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'left';
    arrayAlinha[3] = 'right';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'right';
    arrayAlinha[6] = 'right';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);

    // complemento
    var complemento = $('ul.complemento', '#divAutoManual');

    $('li:eq(0)', complemento).addClass('txtNormalBold');
    $('li:eq(1)', complemento).addClass('txtNormal').css({ 'width': '15%' });
    $('li:eq(2)', complemento).addClass('txtNormalBold');
    $('li:eq(3)', complemento).addClass('txtNormal').css({ 'width': '11%' });
    $('li:eq(4)', complemento).addClass('txtNormalBold');
    $('li:eq(5)', complemento).addClass('txtNormal').css({ 'width': '11%' });
    $('li:eq(6)', complemento).addClass('txtNormalBold');
    $('li:eq(7)', complemento).addClass('txtNormal').css({ 'width': '10%' });
    $('li:eq(8)', complemento).addClass('txtNormalBold');
    $('li:eq(9)', complemento).addClass('txtNormal');
}

// Função para seleção da aplicação
function selecionaAplicacaoManual(id, qtAplicacao, aplicacao) {

    var aplicacao = new String(aplicacao);

    // Formata cor da linha da tabela que lista aplicações
    for (var i = 0; i < qtAplicacao; i++) {

        if (i == id) {
            // Mostrar informações adicionais da aplicação
            $("#tdSitM").html(lstDadosResgate[id].dssitapl);
            $("#tdTxCtrM").html(lstDadosResgate[id].txaplmax);
            $("#tdTxMinM").html(lstDadosResgate[id].txaplmin);
            $("#tdResgM").html(lstDadosResgate[id].cddresga);
            $("#tdDtResgM").html(lstDadosResgate[id].dtresgat);

            //$("#linkApl" + id).focus();

            // Armazena número da aplicação selecionada
            nraplica = retiraCaracteres(aplicacao, "0123456789", true);
            idLinha = id;
        }
    }
}

function verificaVencimento(num, dtmvtolt) {

    var aux_dtmvtolt;
    var aux_dtvencto;

    aux_dtmvtolt = dtmvtolt.substr(3, 2);
    aux_dtmvtolt = aux_dtmvtolt + "/" + dtmvtolt.substr(0, 2);
    aux_dtmvtolt = aux_dtmvtolt + "/" + dtmvtolt.substr(6, 4);

    aux_dtvencto = lstDadosResgate[num].dtvencto.substr(3, 2);
    aux_dtvencto = aux_dtvencto + "/" + lstDadosResgate[num].dtvencto.substr(0, 2);
    aux_dtvencto = aux_dtvencto + "/" + lstDadosResgate[num].dtvencto.substr(6, 4);

    var dataAtual = new Date(aux_dtmvtolt);
    var dataVencto = new Date(aux_dtvencto);

    var msg = "Aplica&ccedil;&atilde;o n&uacute;mero " + lstDadosResgate[num].nraplica + " vencer&aacute em " + lstDadosResgate[num].dtvencto + ". Resgatar?";

    if ($("#appresg" + num).is(":checked")) {
        if (dataVencto > dataAtual) {
            if ((dataVencto - dataAtual) < 864000000) { // 864000000 = 10 dias em milisegundos
                showConfirmacao(msg, "Confirma&ccedil;&atilde;o - Ayllos", 'selecionaResgatesManual(\'' + num + '\', \'' + dtmvtolt + '\')', 'desmarcaAplicacao(\'' + num + '\')', "sim.gif", "nao.gif");
            } else {
                selecionaResgatesManual(num, dtmvtolt);
            }
        } else {
            selecionaResgatesManual(num, dtmvtolt);
        }
    } else {
        selecionaResgatesManual(num, dtmvtolt);
    }

}

//adiciona ou retira a aplicacao da lista (resgate varios de forma manual)
function selecionaResgatesManual(num, dtmvtolt) {

    if (lstResgatesManual == "")
        lstResgatesManual = new Array();

    lstDadosResgate[num].nrdocmto = retiraCaracteres(lstDadosResgate[num].nrdocmto, "0123456789", true);
    if ($("#appresg" + num).is(":checked")) {

        if (lstDadosResgate[num].dtvencto > dtmvtolt) {
            if ((lstDadosResgate[num].dtvencto - dtmvtolt) < 10) {
                null;
            }
        }

        if (atualizaTotalDiferenca($("#tdTotInf").html(), $("#tdTotSel").html(), $("#tdDifer").html(), true, num)) {

            var campos = new Object();
            campos["auxidres"] = num;
            campos["nraplica"] = lstDadosResgate[num].nraplica;
            campos["dtmvtolt"] = lstDadosResgate[num].dtmvtolt;
            campos["dshistor"] = lstDadosResgate[num].dshistor;
            campos["nrdocmto"] = lstDadosResgate[num].nrdocmto;
            campos["dtvencto"] = lstDadosResgate[num].dtvencto;
            campos["sldresga"] = lstDadosResgate[num].sldresga;
            campos["idtipapl"] = lstDadosResgate[num].idtipapl;

            lstDadosResgate[num].vlresgat = lstDadosResgate[num].vlresgat.toString();
            lstDadosResgate[num].vlresgat = lstDadosResgate[num].vlresgat.replace(",", ".");

            campos["vlresgat"] = number_format(lstDadosResgate[num].vlresgat, 2, ",", ".");
            campos["tpresgat"] = lstDadosResgate[num].tpresgat;

            /*if (lstDadosResgate[num].tpresgat == "")
				campos["tpresgat"] = "T";
			else
				campos["tpresgat"] = lstDadosResgate[num].tpresgat;*/

            lstResgatesManual.push(campos);
        }
    } else {
        for (i = 0; i < lstResgatesManual.length; i++) {
            if (lstResgatesManual[i]["auxidres"] == num) {
                lstResgatesManual.splice(i, 1);

                atualizaTotalDiferenca($("#tdTotInf").html(), $("#tdTotSel").html(), $("#tdDifer").html(), false, num);
            }
        }
    }
}

function desmarcaAplicacao(num) {
    $("#appresg" + num).removeProp("checked");
}

function atualizaTotalDiferenca(totinf, totsel, diferenca, checked, id) {

    totsel = (totsel.replace(".", "")).replace(",", ".");
    diferenca = (diferenca.replace(".", "")).replace(",", ".");
    totinf = (totinf.replace(".", "")).replace(",", ".");

    var totsel = new Number(totsel);
    var diferenca = new Number(diferenca);
    var totInform = new Number(totinf);

    var sldresga = lstDadosResgate[id].sldresga;
    var vlresgat = lstDadosResgate[id].vlresgat;

    if ((parseFloat(totsel) == parseFloat(totInform)) && (checked)) {
        showError("error", "O total selecionado n&atilde;o pode ser maior que o total informado.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        desmarcaAplicacao(id);
        return false;
    } else {
        if (checked) {
            /*if (vlresgat == "0"){
				if ((totsel + parseFloat(sldresga)) > totInform) {
					$("#appresg" + id).removeProp('checked');
					showError("error","Para resgate desta aplica&ccedil;&atilde;o, informe um valor de resgate menor, utilizando a op&ccedil;&atilde;o Parcial.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
					return false;
				} else {
					lstDadosResgate[id].vlresgat = sldresga;
					
					totsel = totsel + parseFloat(lstDadosResgate[id].vlresgat.replace(",","."));
					diferenca = diferenca - parseFloat(lstDadosResgate[id].vlresgat.replace(",","."));
					$("#tdTotSel").html(number_format(totsel, 2, ",","."));
					$("#tdDifer").html(number_format(diferenca, 2, ",","."));
				}
			} else {
				if ((totsel + parseFloat(vlresgat)) > totInform) {
					$("#appresg" + id).removeProp('checked');
					showError("error","Para resgate desta aplica&ccedil;&atilde;o, informe um valor de resgate menor, utilizando a op&ccedil;&atilde;o Parcial.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
					return false;
				} else {
					totsel = totsel + parseFloat(lstDadosResgate[id].vlresgat.replace(",","."));
					diferenca = diferenca - parseFloat(lstDadosResgate[id].vlresgat.replace(",","."));
					$("#tdTotSel").html(number_format(totsel, 2, ",","."));
					$("#tdDifer").html(number_format(diferenca, 2, ",","."));
				}
			}*/
            if ((totsel + parseFloat(sldresga)) > totInform) {
                lstDadosResgate[id].vlresgat = String(diferenca).replace(".", ",");
                lstDadosResgate[id].tpresgat = "1";
            } else {
                lstDadosResgate[id].vlresgat = sldresga;
                lstDadosResgate[id].tpresgat = "2";
            }

            totsel = totsel + parseFloat(lstDadosResgate[id].vlresgat.replace(",", "."));
            diferenca = diferenca - parseFloat(lstDadosResgate[id].vlresgat.replace(",", "."));
            $("#tdTotSel").html(number_format(totsel, 2, ",", "."));
            $("#tdDifer").html(number_format(diferenca, 2, ",", "."));

        } else {
            totsel = totsel - parseFloat(lstDadosResgate[id].vlresgat.replace(",", "."));
            diferenca = diferenca + parseFloat(lstDadosResgate[id].vlresgat.replace(",", "."));
            $("#tdTotSel").html(number_format(totsel, 2, ",", "."));
            $("#tdDifer").html(number_format(diferenca, 2, ",", "."));
        }
    }
    return true;
}

function resgataValorParcial() {

    // Executa script de consulta através de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/aplicacoes/resgata_valor_parcial.php",
        data: {
            nraplica: nraplica,
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

function formataResgateParcial() {

    $("#divConteudoOpcao").css("height", "100px");

    // label
    rVlresgat = $('label[for="vlresgat"]', '#frmResgataValorParcial');

    rVlresgat.addClass('rotulo').css({ 'width': '250px' });

    // input
    cVlresgat = $('#vlresgat', '#frmResgataValorParcial');

    cVlresgat.css({ 'width': '90px', 'text-align': 'right' });

    $('input, select', '#frmResgataValorParcial').habilitaCampo();
}

function voltarDivAutoManual() {
    $("#divConteudoOpcao").css("height", "280px");
    $("#divResgateParcial").css("display", "none");
    $("#divAutoManual").css("display", "block");
}

function setValorParcialResgate() {

    if ($("#appresg" + idLinha).is(":checked")) {
        $("#appresg" + idLinha).removeProp('checked');
        selecionaResgatesManual(idLinha);
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, validando valor do resgate ...");

    var tddifer = ($("#tdDifer").html().replace(".", "")).replace(",", ".");

    var diferenca = new Number(tddifer);

    var sldresga = lstDadosResgate[idLinha].sldresga;
    var vlresgat = $("#vlresgat", "#frmResgataValorParcial").val().replace(/\./g, "");

    vlresgat = vlresgat.toString();
    vlresgat = vlresgat.replace(",", ".");

    sldresga = sldresga.toString();
    sldresga = sldresga.replace(",", ".");

    // Valida valor do resgate
    if (vlresgat == "" || !validaNumero(vlresgat, true, 0, 0)) {
        hideMsgAguardo();
        showError("error", "Valor do resgate inv&aacute;lido.", "Alerta - Ayllos", "$('#vlresgat','#frmResgate').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    // Verifica se valor do resgate eh igual ao saldo para resgate
    if (parseFloat(vlresgat) >= parseFloat(sldresga)) {
        hideMsgAguardo();
        showError("error", "Valor do resgate parcial deve ser menor que o saldo para resgate.", "Alerta - Ayllos", "$('#vlresgat','#frmResgate').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    // Verifica se valor do resgate eh maior que a diferenca
    if (parseFloat(vlresgat) > diferenca) {
        hideMsgAguardo();
        showError("error", "Valor do resgate parcial n&atilde;o pode ser maior que a diferen&ccedil;a.", "Alerta - Ayllos", "$('#vlresgat','#frmResgate').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    lstDadosResgate[idLinha].vlresgat = vlresgat;
    lstDadosResgate[idLinha].tpresgat = "P";


    $("#divResgateParcial").css("display", "none");
    $("#divAutoManual").css("display", "block");
    hideMsgAguardo();
    blockBackground(parseInt($("#divRotina").css("z-index")));
}

function marcaDesmarcaTodos(qtd) {

    if ($("#marcaTodos").is(":checked")) {
        for (var i = 0; i < qtd; i++) {
            $("#appresg" + (i)).prop("checked", true);

            selecionaResgateVarias(i, lstResgates[i].nraplica, lstResgates[i].dtresgat, lstResgates[i].nrdocmto, lstResgates[i].idtipapl);
        }

    } else {
        for (var i = 0; i < qtd; i++) {
            $("#appresg" + (i)).removeProp("checked");

            selecionaResgateVarias(i, lstResgates[i].nraplica, lstResgates[i].dtresgat, lstResgates[i].nrdocmto, lstResgates[i].idtipapl);
        }
    }
}

// aplicacao
function mostraAplicacao() {

    showMsgAguardo('Aguarde, buscando ...');
    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/aplicacoes/aplicacao.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground()");
        },
        success: function (response) {
            $('#divRotina').html(response);
            buscaAplicacao(nrdconta);
            return false;
        }
    });
    return false;

}

function buscaAplicacao(nrdconta) {

    showMsgAguardo('Aguarde, buscando ...');

    var nrdconta = normalizaNumero(nrdconta);

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/aplicacoes/busca_aplicacao.php',
        data: {
            nrdconta: nrdconta,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground();");
        },
        success: function (response) {

            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divConteudo').html(response);
                    exibeRotina($('#divRotina'));
                    formataAplicacao();
                    return false;
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            } else {
                try {
                    eval(response);
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            }
        }
    });
    return false;
}

function formataAplicacao() {

    var divRegistro = $('div.divRegistros', '#divAplicacao');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({ 'height': '120px', 'width': '320px' });

    var ordemInicial = new Array();
    ordemInicial = [[1, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '55px';
    arrayLargura[1] = '80px';
    arrayLargura[2] = '45px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'left';
    arrayAlinha[1] = 'right';
    arrayAlinha[2] = 'left';
    arrayAlinha[3] = 'right';

    var metodoTabela = 'selecionarAplicacao();';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

    hideMsgAguardo();
    //bloqueiaFundo( $('#divRotina') );

    return false;
}

function selecionarAplicacao() {

    if ($('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao')) {

        $('table > tbody > tr', 'div.divRegistros').each(function () {
            if ($(this).hasClass('corSelecao')) {
                cNraplica.val($('#tpaplic2', $(this)).val());
                layoutPadrao();
                cNraplica.trigger('blur');
                //fechaRotina($('#divRotina'));
                return false;
            }
        });
    }
    return false;
}

function selecionaCarenciaCaptacao(carencia, prazo) {

    $("#qtdiacar", "#frmDadosAplicacaoPos").val(carencia);
    $("#qtdiapra", "#frmDadosAplicacaoPos").val(prazo);
    $("#divSelecionaCarencia").hide();

    aux_qtdiaapl = prazo;
    aux_qtdiacar = carencia;

    obtemTaxaAplicacao();
}

function acessaOpcaoAgendamento() {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando op&ccedil;&atilde;o para agendamento ...");

    // Executa script de consulta através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/aplicacoes/principal_agendamento.php",
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

// Função para cadastro do resgate
function cadastraNovaAplicacaoResgate() {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, cadastrando resgate ...");

    var tpresgat = $("#tpresgat", "#frmResgate").val();
    var vlresgat = $("#vlresgat", "#frmResgate").val().replace(/\./g, "");
    var dtresgat = $("#dtresgat", "#frmResgate").val();
    var flgctain = $("#flgctain", "#frmResgate").val();
    var cdopera2 = $("#cdopera2", "#frmResgate").val();
    var cddsenha = $("#cddsenha", "#frmResgate").val();

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

    // Executa script de consulta através de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/aplicacoes/resgate_cadastrar_nova_aplic.php",
        data: {
            nrdconta: nrdconta,
            nraplica: nraplica,
            tpresgat: tpresgat,
            vlresgat: vlresgat,
            dtresgat: dtresgat,
            flgctain: flgctain,
            cdopera2: cdopera2,
            cddsenha: cddsenha,
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

function ativaCampo() {

    //$("#vllanmto","#frmDadosAplicacaoPos").bind("blur");
    //$("#vllanmto","#frmDadosAplicacaoPos").bind("keydown");
    //$("#vllanmto","#frmDadosAplicacaoPos").bind("keyup");


    $("#tpaplica", "#frmDadosAplicacao").bind("keydown", function (e) {
        if (e.keyCode == 13) {
            if ($(this).val() == "7,1,A")
                $('#qtdiaapl', '#frmDadosAplicacaoPre').focus();
            return false;
        } else {
            $('#vllanmto', '#frmDadosAplicacaoPos').focus();
            return false;
        }
    });

    $("#vllanmto", "#frmDadosAplicacaoPre").bind("keydown", function (e) {
        if (e.keyCode == 13) {
            $(this).blur();
            return false;
        }
    });

    $("#vllanmto", "#frmDadosAplicacaoPos").bind("keydown", function (e) {
        if (e.keyCode == 13) {
            $('#dtresgat', '#frmDadosAplicacaoPos').focus();
            return false;
        }

        return $(this).setMaskOnKeyDown("DECIMAL", "zz.zzz.zz9,99", "", e);
    });

    $('#dtresgat', '#frmDadosAplicacaoPos').bind("keydown", function (e) {
        if (e.keyCode == 13) {
            controlarAplicacao(true, 'I');
            return false;
        }

        return $(this).setMaskOnKeyDown("DECIMAL", "zz.zzz.zz9,99", "", e);
    });


    $("#vllanmto", "#frmDadosAplicacaoPos").bind("keyup", function (e) {
        return $(this).setMaskOnKeyUp("DECIMAL", "zz.zzz.zz9,99", "", e);
    });
}

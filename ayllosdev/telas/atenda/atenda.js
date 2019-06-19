//************************************************************************//
//*** Fonte: atenda.js                                                 ***//
//*** Autor: David                                                     ***//
//*** Data : Agosto/2007                  Última Alteração: 23/11/2018 ***//
//***                                                                  ***//
//*** Objetivo  : Biblioteca de funções da tela ATENDA                 ***//
//***                                                                  ***//	 
//*** Alterações: 12/09/2008 - Incluir variável global inpessoa        ***//
//***                        - Ativar rotina Cartões Magnéticos na     ***//
//***                          funcao focoRotina() (David).            ***//
//***                        - Ativar rotina Descontos na função       ***//
//***                          focoRotina() (Guilherme).               ***//
//***                                                                  ***//
//***             13/08/2009 - Alterado consultaAssociado para         ***//
//***                          utilizar paginação (Guilherme).         ***//
//***                                                                  ***//
//***             12/01/2010 - Retirar funcoes de pesquisa associados. ***//
//***                          Utilizar biblioteca genérica (David).   ***//
//***                                                                  ***//
//***             29/06/2011 - Tableless (Rogerius - DB1).		       ***//
/*
 *				  05/08/2011 - Limpar rotina Ficha cadastral (Gabriel)
 *				  
 *				  01/11/2011 - Retirado os tratamentos para não listar
 *							   a rotina 'Seguro'(Marcelo Pereira - GATI)
 *							   
 *				  16/01/2012 - Ajustes diversos (David).		
 *						
 *				  13/03/2012 - Adicionado parametro para manter referencia
 *							   da janela de impressao. (Jorge)
 *							   
 *				  26/06/2012 - Alterado funcao imprimeAnotacoes(),
 * 							   adequado para submeter impressao. (Jorge)
 *
 *				  26/09/2013 - Alterado funcao obtemCabecalho(),
 * 							   adequado para ter botao de Cartao Ass.
							   (Jean Michel)
							   
			      02/07/2014 - Tratamento na funcao limparDadosCampos
				               para nao limpar o campo que contem o nome
							   do servidor do GED (SmartShare) e o codigo
							   da cooperativa.
							   (Fabricio)
							   
				  30/09/2014 - Ajustando funcao LimpaCampo para limpar
				               corretamente quando a tela é carregada
							   (André Santos - SUPERO)
							   
			      05/11/2014 - Incluso novo parâmetro flgerlog com valor "yes"
				               na requisição ajax realizada na função obtemCabecalho()
							   (Daniel)
							   
			      23/07/2015 - Inclusao do item Limite Saque TAA. (James)		
				  
				  24/08/2015 - Projeto Reformulacao cadastral		   
							   (Tiago Castro - RKAM)	

				  04/09/2015 - Ajuste para inclusão das novas telas "Atendimento,
						       Produtos"
				              (Gabriel - Rkam -> Projeto 217).
                              
                  25/11/2015 - Ajustes na leitura do campo hdnFlgdig, para interpretar o valor
                               como yes ou no SD364350 (Odirlei-AMcom)
                  
                  29/08/2016 - Depois de carregar a conta do cooperado, da um Blur no imput
                               para que a tecla ESC funcione adequadamente. 

				  02/09/2016 - Incluido parametro name na div com id #divSemCartaoAss - necessario para navegação no IE
                             - Adicionado função ControlaFocoAnotacoes.
                             - Adicionado parametro labelRot na rotina acessaRotina - (Evandro - RKAM)	   
                  14/12/2016 - Correcao referente aos chamados 568566, erro ao redirecioar da tela contas para produtos
                               telas atenda. (Gil - MOUTS)


				  20/01/2017 - Adicionar parametro 'produtos', na chamada da function acessaRotina(Lucas Ranghetti #537087)

				  27/03/2017 - Criado function dossieDigdoc. (Projeto 357 - Reinert)

                  14/07/2017 - Alteração para o cancelamento manual de produtos. Projeto 364 (Reinert)

                  14/11/2017 - Não apresentar pop-up de anotações quando impedimentos estiver sendo executado (Jonata - P364).

                   21/11/2017 - Ajuste para controle das mensagens de alerta referente a seguro (Jonata - RKAM P364).
				  
				  22/02/2018 - Alteracoes referentes ao uso do Ctrl+C Ctrl+V no CPF/CNPJ do cooperado (Lucas Ranghetti #851205)
				   
                  26/03/2018 - Alterado para permitir acesso a tela pelo CRM. (Reinert)
				   
                  16/07/2018 - Novo campo Nome Social (#SCTASK0017525 - Andrey Formigari)
				   
                  08/11/2018 - Alteração do campo indnivel da tela atenda para nrdgrupo - P484. Gabriel Marcos (Mouts).

                  23/11/2018 - P442 - Inclusao de Score (Thaise-Envolti)
				   
                  11/01/2019 - Adicionada modal para selecionar impressão de Documentos quando for pessoa física (Luis Fernando - GFT)
                  
                  07/06/2019 - Atualização da funcção limparDadosCampos() passando a quantidade de campos
				               limpos de 30 (0 a 29) para 37 (0 a 36)
							 - Inclusão de nova chamada da função limparDadosCampos() dentro da função
							   obtemCabecalho() para que os campos sejam limpos antes de serem carregados
							   pelas rotinas chamadas do php
							   PRB0041519 - Jackson

***************************************************************************/

var flgAcessoRotina = false; // Flag para validar acesso as rotinas da tela ATENDA
var flgMostraAnota = false; // Flag que indica se anotações devem ser mostradas após as mensagens

var nrdconta = ""; // Variável global para armazenar nr. da conta/dv
var nrdctitg = ""; // Variável global para armazenar nr. da conta integração
var inpessoa = ""; // Variável global para armazenar o tipo de pessoa (física/jurídica)
var cdcooper = ""; // Variável global para armazenar o codigo da cooperativa
var dscsersm = ""; // Variável global para armazenar o o servidor do smartshare
var contWinAnot = 0; // Para impressão das anotações
var cdproduto = 0; // Identificar que servico foi chamado via rotina Produtos
var bkp_inpessoa = 0; // Bkp do inpessoa pois, o inpessoa e' queimada em outras rotinas

var sitaucaoDaContaCrm =0 //Recebe a situação da conta para controle de acesso a determinado produtos da tela ATENDA;

var podeCopiar = true;

$(document).ready(function () {

    // Mostra mensagem de aguardo	
    showMsgAguardo("Aguarde, carregando configura&ccedil;&otilde;es da tela ...");

    // Evento onKeyUp no campo "nrdconta"
    $("#nrdconta", "#frmCabAtenda").bind("keyup", function (e) {
        // Seta máscara ao campo
        if (!$(this).setMaskOnKeyUp("INTEGER", "zzzz.zzz-z", "", e)) {
            return false;
        }

        // Se foi alterado o número da conta, limpa o campo "nrdctitg" e não permite acessar as rotinas
        if (flgAcessoRotina && retiraCaracteres($(this).val(), "0123456789", true) != nrdconta) {
            $("#nrdctitg", "#frmCabAtenda").val("0.000.000-0");
            flgAcessoRotina = false;
        }
    });

    // Evento onKeyDown no campo "nrdconta"
    $("#nrdconta", "#frmCabAtenda").bind("keydown", function (e) {
        // Captura código da tecla pressionada
        var keyValue = getKeyValue(e);

        // Se o botão enter foi pressionado, carrega dados da conta
        if (keyValue == 13) {
            flgcadas = 'C';
            obtemCabecalho();
            return false;
        }

        // Seta máscara ao campo
        return $(this).setMaskOnKeyDown("INTEGER", "zzzz.zzz-z", "", e);
    });

    // Evento onBlur no campo "nrdconta"
    $("#nrdconta", "#frmCabAtenda").bind("blur", function () {
        if ($(this).val() == "") {
            return true;
        }

        // Valida número da conta
        if (!validaNroConta(retiraCaracteres($(this).val(), "0123456789", true))) {
            showError("error", "Conta/dv inv&aacute;lida.", "Alerta - Aimaro", "$('#nrdconta','#frmCabAtenda').focus()");
            limparDadosCampos();
            return false;
        }

        return true;
    });

    // Evento onKeyUp no campo "nrdctitg"
    $("#nrdctitg", "#frmCabAtenda").bind("keyup", function (e) {
        // Se foi alterado o número da conta/itg, limpa o campo "nrdconta" e não permite acessar as rotinas
        if (flgAcessoRotina && retiraCaracteres($(this).val(), "0123456789X", true) != nrdctitg) {
            $("#nrdconta", "#frmCabAtenda").val("");
            flgAcessoRotina = false;
        }
    });

    // Evento onKeyDown no campo "nrdctitg"
    $("#nrdctitg", "#frmCabAtenda").bind("keydown", function (e) {
        // Captura código da tecla pressionada
        var keyValue = getKeyValue(e);

        // Se o botão enter foi pressionado, carrega dados da conta
        if (keyValue == 13) {
            flgcadas = 'C';
            $(this).blur();
            obtemCabecalho();
            return false;
        }

    });

    $("#nrdctitg", "#frmCabAtenda").setMask("STRING", "9.999.999-9", ".-", "");


    // Se fo chamada pela MATRIC -> CONTAS -> ATENDA, abrir dados do novo cooperado
    if ($("#nrdconta", "#frmCabAtenda").val() != "") {
        obtemCabecalho();
    } else {
        $("#nrdconta", "#frmCabAtenda").focus();
    }

	// Seta os valores caso tenha vindo do CRM
    if ($("#crm_inacesso","#frmCabAtenda").val() == 1) {
        $("#nrdconta","#frmCabAtenda").val($("#crm_nrdconta","#frmCabAtenda").val());
		obtemCabecalho();
    }	
	
    hideMsgAguardo();
});

// Função para setar foco na rotina
function focoRotina(id, flgEvent) {
    if (!flgAcessoRotina || $("#labelRot" + id).html() == "&nbsp;") {
        return false;
    }

    if (flgEvent) { // MouserOver
        $("#labelRot" + id).css({
            backgroundColor: "#FFB4A0",
            cursor: "pointer"
        });
        $("#valueRot" + id).css({
            backgroundColor: "#FFB4A0",
            cursor: "pointer"
        });
    } else { // MouseOut
        $("#labelRot" + id).css({
            backgroundColor: "#E3E2DD",
            cursor: "default"
        });
        $("#valueRot" + id).css({
            backgroundColor: "#E3E2DD",
            cursor: "default"
        });
    }
}

// Função para fechar div com mensagens de alerta
function encerraMsgsAlerta() {
    // Esconde div
    $("#divMsgsAlerta").css("visibility", "hidden");

    $("#divListaMsgsAlerta").html("&nbsp;");

    if (flgMostraAnota) {
        // Mostra div 
        $("#divAnotacoes").css("visibility", "visible");

        // Bloqueia conteúdo que está átras do div de Anotações
        blockBackground(parseInt($("#divAnotacoes").css("z-index")));

        // Flag para não mostrar a tela de anotações
        flgMostraAnota = false;
    } else {
        // Esconde div de bloqueio
        unblockBackground();
    }
}

// Função para esconder as Anotações
function encerraAnotacoes() {
    // Esconde div da rotina
    $("#divAnotacoes").css("visibility", "hidden");

    $("#divListaAnotacoes").html("&nbsp;");

    unblockBackground();

}

// Função para selecionar função buscaAnotacoes() com Enter
function EnterAnotacoes() {
    $('.Anotacoes').bind('keydown', function (e) {
        if (e.keyCode == 13) {
            buscaAnotacoes();
            return false;
        }
    });
}

// Função para buscar anotações do associado
function buscaAnotacoes() {
    // Mostra mensagem de aguardo	
    showMsgAguardo("Aguarde, carregando anota&ccedil;&otilde;es ...");

    // Carrega dados da conta através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/busca_anotacoes.php",
        data: {
            nrdconta: nrdconta,
            redirect: "html_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divAnotacoes').css('z-index')))");
        },
        success: function (response) {
            $("#divListaAnotacoes").html(response);
            ControlaFocoAnotacoes();
        }
    });
}

// Função para navegar em anotações do associado
function ControlaFocoAnotacoes() {

    $('.FirstAnota').focus();

    //Se estiver com foco na classe LastAnota
    $(".LastAnota").focus(function () {
        var pressedShift = false;

        $(this).bind('keyup', function (e) {
            if (e.keyCode == 16) {
                pressedShift = false;//Quando tecla shift for solta passa valor false 
            }
        })

        $(this).bind('keydown', function (e) {
            e.stopPropagation();
            e.preventDefault();
            if (e.keyCode == 27) {
                $(".FirstInput").focus();
                encerraAnotacoes().click();
            }
            if (e.keyCode == 13) {
                $(".FirstInput").focus();
                encerraAnotacoes().click();
            }
            if (e.keyCode == 16) {
                pressedShift = true;//Quando tecla shift for pressionada passa valor true 
            }
            if ((e.keyCode == 9) && pressedShift == true) {
                return setFocusCampo($(target), e, false, 0);
            }
            else if (e.keyCode == 9) {
                $(".FirstAnota").focus();
            }
        });
    });

    $(".FirstInput:first").focus();

    if ($('#divAnotacoes').css({ 'visibility': 'visible' })) {
        $('.FirstAnota').focus();
        blockBackground(parseInt($("#divAnotacoes").css("z-index")));
    };
}

// Função para imprimir anotações do associado
function imprimeAnotacoes() {

    $('input,select', '#frmAnotacoes').habilitaCampo();
    $('#nrdconta', '#frmAnotacoes').val(nrdconta);

    var action = $('#frmAnotacoes').attr('action');
    var callafter = "blockBackground(parseInt($('#divAnotacoes').css('z-index')));$('input, select', '#frmAnotacoes,.classDisabled').desabilitaCampo();";

    carregaImpressaoAyllos("frmAnotacoes", action, callafter);

}


// Função para acessar rotinas da tela ATENDA
function acessaRotina(labelRot, nomeValidar, nomeTitulo, nomeURL, opeProdutos) {

    // Verifica se é uma chamada válida
    if (!flgAcessoRotina) {
        return false;
    }

    // Mostra mensagem de aguardo	
    showMsgAguardo("Aguarde, carregando rotina de " + nomeTitulo + " ...");

    var url = UrlSite + "telas/atenda/" + nomeURL + "/" + nomeURL;

    if (nomeURL == "produtos") {

        var urlScript = UrlSite + "includes/" + nomeURL + "/" + nomeURL;
    } else {
        var urlScript = UrlSite + "telas/atenda/" + nomeURL + "/" + nomeURL;
    }

    // Salvar o inpessoa, pois ela e' queimada em algumas rotinas (Seguro, por exemplo)
    if (inpessoa != 1 && inpessoa != 2 && inpessoa != 3) {
        inpessoa = bkp_inpessoa;
    } else {
        bkp_inpessoa = inpessoa;
    }

    // Carrega biblioteca javascript da rotina
    // Ao carregar efetua chamada do conteúdo da rotina através de ajax	
    $.getScript(urlScript + ".js", function () {

        $.ajax({
            type: "POST",
            dataType: "html",
            url: url + ".php",
            data: {
                nrdconta: nrdconta,
                nmdatela: "ATENDA",
                nmrotina: nomeValidar,
                opeProdutos: opeProdutos,
                flgcadas: flgcadas,
                labelRot: labelRot,
                executandoProdutos: executandoProdutos,
                cdproduto: cdproduto,
                redirect: "html_ajax" // Tipo de retorno do ajax
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "");
            },
            success: function (response) {
                $("#divRotina").html(response);
            }
        });
    });

}

// Função para visualizar div da rotina
function mostraRotina() {
    $("#divRotina").css("visibility", "visible");
    $('#divRotina').css({ 'margin-left': '', 'margin-top': '' }); // Restaurar valores
    $("#divRotina").centralizaRotinaH();

}

// Função para esconder div da rotina e carregar dados da conta novamente
function encerraRotina(flgCabec) {

    //Condição para voltar foco na opção selecionada
    var CaptaIdRetornoFoco = '';
    CaptaIdRetornoFoco = $(".SetFoco").attr("id");
    if (CaptaIdRetornoFoco) {
        $(CaptaIdRetornoFoco).focus();
    }

    unblockBackground();
    $("#divRotina").css({ "width": "545px", 'margin-left': '', 'margin-top': '', "visibility": "hidden" });
    $("#divRotina").html("");

    // Para esconder o F2
    nmrotina = ""

    sequenciaProdutos();

    if (flgCabec && executandoProdutos == false) {
        obtemCabecalho();
    }

}

function sequenciaProdutos() {

    if (executandoProdutos) {

        if (executandoProdutosServicos && (posicao < produtosTelasServicos.length)) {

            eval(produtosTelasServicos[posicao]);
            posicao++;
            return false;

        } else if (executandoProdutosServicosAdicionais && (posicao < produtosTelasServicosAdicionais.length)) {
            eval(produtosTelasServicosAdicionais[posicao]);
            posicao++;
            return false;
        }

    }
}

function sequenciaImpedimentos() {
    if (executandoImpedimentos) {	
		if (nmtelant == "COBRAN"){		
			acessaRotina('','COBRANCA','Cobran&ccedil;a','cobranca');
			nmtelant = "";
			if (posicao == 1){ // Se for selecionado primeiramente cobrança
				posicao++;
			}
            return false;			
        }else if (posicao <= produtosCancMAtenda.length) {
			if (produtosCancMAtenda[posicao - 1] == '' || produtosCancMAtenda[posicao - 1] == 'undefined'){
				eval(produtosCancM[posicao - 1]);
				posicao++;
			}else{
				eval(produtosCancMAtenda[posicao - 1]);
				posicao++;
			}
            return false;
        }else{
			eval(produtosCancM[posicao - 1]);
			posicao++;
			return false;
		}
    }
}

// Função para carregar dados da conta informada
function obtemCabecalho() {

    var flgdigit;
    var aux_nrdconta;

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando dados da conta/dv ...");

    // Armazena conta/dv e conta/itg informadas
    nrdconta = retiraCaracteres($("#nrdconta", "#frmCabAtenda").val(), "0123456789", true);
    nrdctitg = retiraCaracteres($("#nrdctitg", "#frmCabAtenda").val().toUpperCase(), "0123456789X", true);
    cdcooper = $("#hdnCooper", "#frmCabAtenda").val();
    dscsersm = $("#hdnServSM", "#frmCabAtenda").val();

    flgerlog = "yes";

    // Se nenhum dos tipos de conta foi informado
    if (nrdconta == "" && nrdctitg == "") {
        hideMsgAguardo();
        showError("error", "Informe o n&uacute;mero da Conta/dv ou da Conta/Itg.", "Alerta - Aimaro", "$('#nrdconta','#frmCabAtenda').focus()");
        return false;
    }

    // Se conta/dv foi informada, valida
    if (nrdconta != "") {
        if (!validaNroConta(nrdconta)) {
            hideMsgAguardo();
            showError("error", "Conta/dv inv&aacute;lida.", "Alerta - Aimaro", "$('#nrdconta','#frmCabAtenda').focus()");
            limparDadosCampos();
            return false;
        }
    }

    // Realiza a limpeza dos campos antes de carregar as informações do cooperado pesquisado
	limparDadosCampos();

    // Carrega dados da conta através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/obtem_cabecalho.php",
        data: {
            nrdconta: nrdconta,
            nrdctitg: nrdctitg,
            flgerlog: flgerlog,
            flgProdutos: flgProdutos,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "$('#nrdconta','#frmCabAtenda').focus()");
        },
        success: function (response) {
            try {
                eval(response);
                flgdigit = "no";
                flgdigit = $("#hdnFlgdig", "#frmCabAtenda").val();
                aux_nrdconta = $("#nrdconta", "#frmCabAtenda").val();
                aux_nrdconta = aux_nrdconta.replace('-', '.');
                if (inpessoa == 1){
                    $("#divSemCartaoAss").html("<a tabindex='6' name='6' class='txtNormal SetFocus' style='margin-left: 1px; cursor:default' href='#' onclick='abreDocumentos(); return false;' >Documentos</a>");
                }
                else{
                    if (flgdigit == "yes" || flgdigit == "S") {
                        $("#divSemCartaoAss").html("<a tabindex='6' name='6' class='txtNormal SetFocus' href='#' onclick='dossieDigdoc(9,true); return false;' >&nbsp;Cart&atilde;o Ass.</a>");
                    } else {
                        $("#divSemCartaoAss").html("<a tabindex='6' name='6' class='txtNormal SetFocus' style='margin-left: 1px; cursor:default' >&nbsp;Cart&atilde;o Ass.</a>");
                    }
                }

                if (flgProdutos) {
                    if (executandoProdutos) {
                        sequenciaProdutos();
                    } else {
                        acessaRotina('PRODUTOS', 'Produtos', 'produtos', 'produtos', 1);
                    }
                    flgProdutos = false;
                }
				if (executandoImpedimentos){
				    // Limpar tela anterior
					$("#divMsgsAlerta").css('visibility', 'hidden');
					$("#divAnotacoes").css('visibility', 'hidden');
					sequenciaImpedimentos();
				}

            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Aimaro", "$('#nrdconta','#frmCabAtenda').focus()");
            }
        }
    });

}

function abreDocumentos(){
    $("#divRotina").html($("#rotinaDocumentos").html());
    mostraRotina();
    bloqueiaFundo($('#divRotina'));
}

// Função para limpar campos com dados da conta
function limparDadosCampos() {
    // Limpa campos com dados pessoais da conta
    for (i = 0; i < document.frmCabAtenda.length; i++) {
        if ((document.frmCabAtenda.elements[i].name != "hdnServSM") && (document.frmCabAtenda.elements[i].name != "hdnCooper"))
            document.frmCabAtenda.elements[i].value = "";
    }

    // Limpa campos com saldos da conta
    for (i = 0; i < 36; i++) {
        $("#labelRot" + i).html("&nbsp;");
        $("#valueRot" + i).html("&nbsp;");
    }

}

// Função que formata formulario inicial
function formataCabecalho() {

    // link
    $('a', '#frmCabAtenda').addClass('txtNormal');

    // linha
    $('hr', '#frmCabAtenda').css({ 'margin': '3px 0 3px 0' });

    // rotulo
    rNrdconta = $('label[for="nrdconta"]', '#frmCabAtenda');
    rNrdctitg = $('label[for="nrdctitg"]', '#frmCabAtenda');
    rDssititg = $('label[for="dssititg"]', '#frmCabAtenda');
    rNrmatric = $('label[for="nrmatric"]', '#frmCabAtenda');
    rCdagenci = $('label[for="cdagenci"]', '#frmCabAtenda');
    rNrctainv = $('label[for="nrctainv"]', '#frmCabAtenda');
    rDtadmiss = $('label[for="dtadmiss"]', '#frmCabAtenda');
    rDtadmemp = $('label[for="dtadmemp"]', '#frmCabAtenda');
    rDtaltera = $('label[for="dtaltera"]', '#frmCabAtenda');
    rDtdemiss = $('label[for="dtdemiss"]', '#frmCabAtenda');
    rNmprimtl = $('label[for="nmprimtl"]', '#frmCabAtenda');
    rNmSocial = $('label[for="nmsocial"]', '#frmCabAtenda');
    rDsnatopc = $('label[for="dsnatopc"]', '#frmCabAtenda');
    rNrramfon = $('label[for="nrramfon"]', '#frmCabAtenda');
    rDsnatura = $('label[for="dsnatura"]', '#frmCabAtenda');
    rNrcpfcgc = $('label[for="nrcpfcgc"]', '#frmCabAtenda');
    rDstipcta = $('label[for="dstipcta"]', '#frmCabAtenda');
    rDssitdct = $('label[for="dssitdct"]', '#frmCabAtenda');
    //rIndnivel = $('label[for="indnivel"]', '#frmCabAtenda');
    rNrdgrupo = $('label[for="nrdgrupo"]', '#frmCabAtenda');
    rCdempres = $('label[for="cdempres"]', '#frmCabAtenda');
    //rCdsecext = $('label[for="cdsecext"]', '#frmCabAtenda');
    //rCdturnos = $('label[for="cdturnos"]', '#frmCabAtenda');
    //rCdtipsfx = $('label[for="cdtipsfx"]', '#frmCabAtenda');
    rCdscobeh = $('label[for="cdscobeh"]', '#frmCabAtenda');
    rQtdevolu = $('label[for="qtdevolu"]', '#frmCabAtenda');
    rQtdddeve = $('label[for="qtdddeve"]', '#frmCabAtenda');
    rDtabtcct = $('label[for="dtabtcct"]', '#frmCabAtenda');
    rFtsalari = $('label[for="ftsalari"]', '#frmCabAtenda');
    rVlprepla = $('label[for="vlprepla"]', '#frmCabAtenda');
    rQttalret = $('label[for="qttalret"]', '#frmCabAtenda');

    rNrdconta.addClass('rotulo');
    rNrdctitg.addClass('rotulo-linha').css({ 'width': '65px' });
    rDssititg.addClass('rotulo-linha');
    rNrmatric.addClass('rotulo').css({ 'width': '111px' });
    rCdagenci.addClass('rotulo-linha').css({ 'width': '38px' });
    rNrctainv.addClass('rotulo-linha').css({ 'width': '83px' });
    rDtadmiss.addClass('rotulo-linha').css({ 'width': '75px' });
    rDtadmemp.addClass('rotulo').css({ 'width': '111px' });
    rDtaltera.addClass('rotulo-linha').css({ 'width': '137px' });
    rDtdemiss.addClass('rotulo-linha').css({ 'width': '75px' });
    rNmprimtl.addClass('rotulo').css({ 'width': '111px' });
    rNmSocial.addClass('rotulo').css({ 'width': '111px' });
    rDsnatopc.addClass('rotulo').css({ 'width': '111px' });
    rNrramfon.addClass('rotulo-linha').css({ 'width': '55px' });
    rDsnatura.addClass('rotulo').css({ 'width': '111px' });
    rNrcpfcgc.addClass('rotulo-linha').css({ 'width': '55px' });
    rDstipcta.addClass('rotulo').css({ 'width': '111px' });
    rDssitdct.addClass('rotulo-linha').css({ 'width': '55px' });
    //rIndnivel.addClass('rotulo').css({ 'width': '111px' });
    rNrdgrupo.addClass('rotulo').css({ 'width': '111px' });
    rCdempres.addClass('rotulo-linha').css({ 'width': '56px' });
    //rCdsecext.addClass('rotulo-linha').css({ 'width': '39px' });
    //rCdturnos.addClass('rotulo-linha').css({ 'width': '39px' });
    //rCdtipsfx.addClass('rotulo-linha').css({ 'width': '71px' });
    rCdscobeh.addClass('rotulo-linha').css({ 'width': '104px' });
    rQtdevolu.addClass('rotulo').css({ 'width': '111px' });
    rQtdddeve.addClass('rotulo-linha').css({ 'width': '105px' });
    rDtabtcct.addClass('rotulo-linha').css({ 'width': '78px' });
    rFtsalari.addClass('rotulo').css({ 'width': '111px' });
    rVlprepla.addClass('rotulo-linha').css({ 'width': '105px' });
    rQttalret.addClass('rotulo-linha').css({ 'width': '78px' });

    // campo
    cNrdconta = $('#nrdconta', '#frmCabAtenda');
    cNrdctitg = $('#nrdctitg', '#frmCabAtenda');
    cDssititg = $('#dssititg', '#frmCabAtenda');
    cNrmatric = $('#nrmatric', '#frmCabAtenda');
    cCdagenci = $('#cdagenci', '#frmCabAtenda');
    cNrctainv = $('#nrctainv', '#frmCabAtenda');
    cDtadmiss = $('#dtadmiss', '#frmCabAtenda');
    cDtadmemp = $('#dtadmemp', '#frmCabAtenda');
    cDtaltera = $('#dtaltera', '#frmCabAtenda');
    cDtdemiss = $('#dtdemiss', '#frmCabAtenda');
    cNmprimtl = $('#nmprimtl', '#frmCabAtenda');
    cNmSocial = $('#nmsocial', '#frmCabAtenda');
    cDsnatopc = $('#dsnatopc', '#frmCabAtenda');
    cNrramfon = $('#nrramfon', '#frmCabAtenda');
    cDsnatura = $('#dsnatura', '#frmCabAtenda');
    cNrcpfcgc = $('#nrcpfcgc', '#frmCabAtenda');
    cDstipcta = $('#dstipcta', '#frmCabAtenda');
    cDssitdct = $('#dssitdct', '#frmCabAtenda');
    //cIndnivel = $('#indnivel', '#frmCabAtenda');
    cNrdgrupo = $('#nrdgrupo', '#frmCabAtenda');
    cCdempres = $('#cdempres', '#frmCabAtenda');
    //cCdsecext = $('#cdsecext', '#frmCabAtenda');
    //cCdturnos = $('#cdturnos', '#frmCabAtenda');
    //cCdtipsfx = $('#cdtipsfx', '#frmCabAtenda');
    cCdscobeh = $('#cdscobeh', '#frmCabAtenda');
    cQtdevolu = $('#qtdevolu', '#frmCabAtenda');
    cQtdddeve = $('#qtdddeve', '#frmCabAtenda');
    cDtabtcct = $('#dtabtcct', '#frmCabAtenda');
    cFtsalari = $('#ftsalari', '#frmCabAtenda');
    cVlprepla = $('#vlprepla', '#frmCabAtenda');
    cQttalret = $('#qttalret', '#frmCabAtenda');

    cNrdconta.css({ 'width': '70px', 'text-align': 'right' });
    cNrdctitg.css({ 'width': '70px', 'text-align': 'right' });
    cDssititg.css({ 'width': '50px' });
    cNrmatric.css({ 'width': '48px' });
    cCdagenci.css({ 'width': '25px' });
    cNrctainv.css({ 'width': '75px' });
    cDtadmiss.css({ 'width': '63px' });
    cDtadmemp.css({ 'width': '63px' });
    cDtaltera.css({ 'width': '75px' });
    cDtdemiss.css({ 'width': '63px' });
    cNmprimtl.css({ 'width': '425px' });
    cNmSocial.css({ 'width': '425px' });
    cDsnatopc.css({ 'width': '194px' });
    cNrramfon.css({ 'width': '170px' });
    cDsnatura.css({ 'width': '194px' });
    cNrcpfcgc.css({ 'width': '170px' });
    cDstipcta.css({ 'width': '194px' });
    cDssitdct.css({ 'width': '170px' });
    //cIndnivel.css({ 'width': '38px' });;
    cNrdgrupo.css({ 'width': '43px' });
    cCdempres.css({ 'width': '40px' });
    //cCdsecext.css({ 'width': '45px' });
    //cCdturnos.css({ 'width': '38px' });
    //cCdtipsfx.css({ 'width': '30px' });
    cCdscobeh.css({ 'width': '170px' });
    cQtdevolu.css({ 'width': '80px' });
    cQtdddeve.css({ 'width': '80px' });
    cDtabtcct.css({ 'width': '70px' });
    cFtsalari.css({ 'width': '80px' });
    cVlprepla.css({ 'width': '80px' });
    cQttalret.css({ 'width': '70px' });

    // ie
    if ($.browser.msie) {

        $('hr', '#frmCabAtenda').css({ 'margin': '0' });

        rCdagenci.css({ 'width': '41px' });
        rNrctainv.css({ 'width': '86px' });
        rDtadmiss.css({ 'width': '78px' });

        rDtaltera.css({ 'width': '140px' });
        rDtdemiss.css({ 'width': '77px' });

        rNrramfon.css({ 'width': '58px' });
        rNrcpfcgc.css({ 'width': '58px' });
        rDssitdct.css({ 'width': '58px' });

        rCdempres.css({ 'width': '40px' });
        //rCdsecext.css({ 'width': '42px' });
        //rCdturnos.css({ 'width': '42px' });
        //rCdtipsfx.css({ 'width': '74px' });

        rQtdddeve.css({ 'width': '107px' });
        rDtabtcct.css({ 'width': '81px' });
        rVlprepla.css({ 'width': '107px' });
        rQttalret.css({ 'width': '81px' });
    }

    $('input, select', '#frmCabAtenda').desabilitaCampo();
    cNrdconta.habilitaCampo();
    cNrdctitg.habilitaCampo();
	$('#nrcpfcgc2','#frmCabAtenda').hide();	
	$('#nrcpfcgc','#frmCabAtenda').attr("disabled", false); // pra funcionar no IE

    layoutPadrao();

}


function ajustarCentralizacao() {
    if (!$('#divBotoesSenha', '#divRotina').length) {
        var x = $.browser.msie ? $(window).innerWidth() : $("body").offset().width;
        x = x - 178;
        $('#divRotina').css({ 'width': x + 'px' });
    }

    $('#divRotina').centralizaRotinaH();
    return false;
}

function dossieDigdoc(cdproduto,ignoraFundo){

	var mensagem = 'Aguarde, acessando dossie...';
	showMsgAguardo( mensagem );

    if (ignoraFundo === undefined){
        ignoraFundo = false;
    }

	// Carrega dados da conta através de ajax
	$.ajax({
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/digdoc.php',
		data    :
				{
					nrdconta	: nrdconta,
					cdproduto   : cdproduto, // Codigo do produto
                    nmdatela    : 'ATENDA',
 					redirect	: 'script_ajax'
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','estadoInicial();');
				},
		success : function(response) {
					hideMsgAguardo();
					// Portabilidade
					if (cdproduto == 6){
						bloqueiaFundo($('#divUsoGenerico'));
					}else {
                        if (!ignoraFundo) {
                            blockBackground(parseInt($('#divRotina').css('z-index')));
                        }
					}

					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							eval( response );
							return false;
						} catch(error) {
							hideMsgAguardo();							
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
						}
					} else {
						try {
							eval( response );							
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
						}
					}
				}
	});

	return false;
}	  

function dadosCadastraisDigdoc(){
    dossieDigdoc(8);
}

function impedSeguros(seguroVida, seguroAuto) {

    if (seguroVida == '1' && seguroAuto == '1') {
        showError('error', 'Cancelamento do SEGURO AUTO deve ser realizado via 0800.', 'Alerta - Aimaro', 'showError("error","Cancelamento do SEGURO DE VIDA PREVISUL deve ser realizado no sistema de gest&atilde;o de seguros.","Alerta - Aimaro", "acessaRotina(\'\',\'SEGURO\',\'Seguro\',\'seguro\');")');
    } else if (seguroVida == '1') {

       showError("error","Cancelamento do SEGURO DE VIDA PREVISUL deve ser realizado no sistema de gest&atilde;o de seguros.","Alerta - Aimaro", "acessaRotina(\'\',\'SEGURO\',\'Seguro\',\'seguro\')");

    } else if (seguroAuto == '1') {
        showError('error', 'Cancelamento do SEGURO AUTO deve ser realizado via 0800.', 'Alerta - Aimaro', 'acessaRotina("","SEGURO","Seguro","seguro");');
    } else {
        acessaRotina("", "SEGURO", "Seguro", "seguro");
    }

    return false;
}

function impedConsorcios(){
	showError('error','Cancelamento dos CONSORCIOS devem ser realizados pelo portal do Sicredi.','Alerta - Aimaro','acessaRotina(\'\',\'CONSORCIO\',\'Cons&oacute;rcios\',\'consorcio\');');
	return false;
}

/******************************************************************************** 
   Funcao para efetuar o Ctrl+C e retirar os caracteres especias antes do Ctrl+V
   Favor nao alterar está função pois pode nao funcionar mais
*********************************************************************************/
function copiarCampo(){	
	
	var vlrSemCaracter;
	
	vlrSemCaracter = retiraCaracteres($('#nrcpfcgc','#frmCabAtenda').val(), "0123456789", true);
	$('#nrcpfcgc2','#frmCabAtenda').val(vlrSemCaracter);
	$('#nrcpfcgc2','#frmCabAtenda').show();
	$('#nrcpfcgc2','#frmCabAtenda').habilitaCampo();
	$('#nrcpfcgc2','#frmCabAtenda').select();	
	
	document.execCommand("copy");				
	$('#nrcpfcgc2','#frmCabAtenda').hide();				
	podeCopiar = false;
	$('#nrcpfcgc','#frmCabAtenda').habilitaCampo();
	$('#nrcpfcgc','#frmCabAtenda').select();
	$('#nrcpfcgc','#frmCabAtenda').desabilitaCampo();	
	$('#nrcpfcgc','#frmCabAtenda').attr("disabled", false);	// pra funcionar no IE
}

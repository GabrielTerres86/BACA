/*!
 * FONTE        : limite_credito.js
 * CRIAÇÃO      : David
 * DATA CRIAÇÃO : Setembro/2007
 * OBJETIVO     : Biblioteca de funções da rotina de Limite de Crédito 
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 000: [13/04/2010] David     (CECRED)  : Adaptação para novo RATING
 * 000: [16/09/2010] David	   (CECRED)  : Ajuste para enviar impressoes via email para o PAC Sede
 * 000: [27/10/2010] David     (CECRED)  : Tratamento para projeto de linhas de crédito 
 * 001: [28/04/2011] Rodolpho      (DB1) : Adaptação para o Zoom Endereço e Avalistas genérico
 * 002: [28/06/2011] Rogérius      (DB1) : Tableless - Inlcui as funções formatacaoPrincipal(), formatacaoUltimasAlteracoes() e formatacaoImprimir()
 * 003: [05/09/2011] Adriano   (CECRED)  : Alterado a function confirmaNovoLimite para passar o nrcpfcgc na requisição ajax;
 * 004: [23/09/2011] Guilherme (CECRED)  : Adaptar para Rating Singulares
 * 005: [09/11/2011] Fabricio  (CECRED)  : Incluido parametro na funcao trataRatingSingulares para verificar se todos os itens estao selecionados, antes
 *                                         de continuar a operacao.
 *                                         Incluido parametro flgratok na funcao confirmaNovoLimite, para indicar se ja foi informado os itens do rating.
 * 006: [30/05/2012] JOrge 	   (CECRED)  : Criado funcao checaEnter(), funcao para retornar true caso seja tecla Enter. 
 * 007: [27/06/2012] Jorge     (CECRED)  : Alterado esquema para impressao, retirao window.open (Jorge)
 * 008: [28/08/2012] Lucas R.  (CECRED)  : Declarado variavel flgProposta.
 * 009: [22/11/2012] Adriano   (CECRED)  : Ajustes referente ao projeto GE.
 * 010: [02/07/2014] Jonata      (RKAM)  : Permitir alterar a observacao da proposta.
 * 011: [23/12/2014] James               : Incluir a acao Renovar. (James)
 * 012: [09/01/2015] Tiago     (CECRED)  : Incluir acao alterar proposta.
 * 013: [20/02/2015] Kelvin    (CECRED)  : Corrigido erro das abas duplicadas
 * 014: [23/02/2015] Kelvin    (CECRED)  : Adicionado formatação no momento de adicionar os valores nos campos dos "dados da renda" e o campo SFN do "rating"
 * 015: [06/04/2015] Jonata      (RKAM)  : Consultas Automatizadas.
 * 016: [01/06/2015] Reinert   (CECRED)  : Alterado para apresentar mensagem de confirmacao de proposta para
 *										   menores nao emancipados. (Reinert)
 * 017:[08/10/2015] Gabriel    (RKAM)    : Reformulacao cadastral (Gabriel-RKAM).
 * 018:[26/01/2016] Heitor     (RKAM)    : Chamado 364592 - Alterada atribuicao ao campo vloutras, nao estava preenchendo corretamente ao retornar valor decimal
 *
 * 018: [17/12/2015] Lunelli   (CECRED)  : Edição de número do contrato de limite (Lucas Lunelli - SD 360072 [M175])
 * 019: [15/07/2016] Andrei    (RKAM)    : Ajuste para utilizar rotina convertida a buscar as linhas de limite de credito.
 * 020:	[25/07/2016] Evandro     (RKAM)  : Alterado função controlaFoco.		 
 * 021: [08/08/2017] Heitor    (MOUTS)   : Implementacao da melhoria 438. 
 * 022: [05/12/2017] Lombardi  (CECRED)  : Gravação do campo idcobope e inserção da tela GAROPC. Projeto 404
 */
 
var callafterLimiteCred = '';
var nrctrimp = '0';  // Variável para armazenar código do contrato para impressão
var nrctrpro = '0';  // Variável para armazenar contrato da proposta
var cddlinha = '';   // Variável para acumular código da linha de crédito informada no form de novo limite
var situacao_limite = ""; // Variável para armazenar a situação do limite atualmente selecionado
var flgProposta;	 //Existe ou não uma proposta cadastrada
var flgAltera;
var dsinfcad;

var nomeForm = 'frmNovoLimite'; 			// Variável para guardar o nome do formulário corrente
var boAvalista = 'b1wgen0019.p'; 			// BO para esta rotina
var procAvalista = 'obtem-dados-avalista'; 	// Nome da procedures que busca os avalistas

var strHTML = ''; // Variável usada na criação da div de alerta do grupo economico.
var strHTML2 = ''; // Variável usada na criação do form onde serão mostradas as mensagens de alerta do grupo economico.	
var dsmetodo = ''; // Variável usada para manipular o método a ser executado na função encerraMsgsGrupoEconomico.
		
var aux_inconfir = ""; /*Variável usada para controlar validações que serão realizadas dentro das ptocedures valida_proposta, efetua_liber_anali_bordero.*/
var aux_inconfi2 = ""; /*Variável usada para controlar validações que serão realizadas dentro das ptocedures valida_proposta, efetua_liber_anali_bordero.*/

var idSocio = 0; 	   // Indicador do socio para as consultas automatizadas
var ant_inconcje = 0;
		
		
// Variável que armazena o nome da rotina conforme tipo de pessoa (1 - Física / 2 - Jurídica)
var strTitRotinaLC = inpessoa == 1 ? "Limite de Cr&eacute;dito" : "Limite Empresarial";
var strTitRotinaUC = inpessoa == 1 ? "LIMITE DE CR&Eacute;DITO" : "LIMITE EMPRESARIAL";

// array com os dados do rating das singulares
var arrayRatingSingulares = new Array();

// Carrega biblioteca javascript referente ao RATING
$.getScript(UrlSite + 'includes/rating/rating.js');

// Carrega biblioteca javascript referente aos AVALISTAS
$.getScript(UrlSite + 'includes/avalistas/avalistas.js');	

// Carrega biblioteca javascript referente as CONSULTAS AUTOMATIZADAS
$.getScript(UrlSite + "includes/consultas_automatizadas/protecao_credito.js");

/*	Criar array de objetos com os dados do Rating - 004 */
function trataRatingSingulares(qtdTotalTopicos) {
	
	showMsgAguardo("Aguarde, validando itens do rating...");

	arrayRatingSingulares = new Array();
	
	//var nomeCampo = "";
    $("select", '#frmDadosRatingSingulares').each(function () {
		
		i = arrayRatingSingulares.length;
		
        eval('var regFilho' + i + ' = new Object();');
		
        eval('regFilho' + i + '["nrtopico"] = $(this).attr("name").substr($(this).attr("name").indexOf("topico_") + 7, ($(this).attr("name").indexOf("item_") - 1) - ($(this).attr("name").indexOf("topico_") + 7))');
        eval('regFilho' + i + '["nritetop"] = $(this).attr("name").substr($(this).attr("name").indexOf("item_") + 5)');
        eval('regFilho' + i + '["nrseqite"] = $(this).val()');
		
        eval('arrayRatingSingulares[' + i + '] = regFilho' + i + ';');
			
        if (arrayRatingSingulares[i]["nrseqite"] == "" || !validaNumero(arrayRatingSingulares[i]["nrseqite"], true, 0, 0)) {
			hideMsgAguardo();
            showError("error", "Item " + arrayRatingSingulares[i]["nrtopico"] + "." + arrayRatingSingulares[i]["nritetop"] + " n&atilde;o informado.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			return false;
		} else {
            if (qtdTotalTopicos == i + 1) {
				confirmaNovoLimite(1, true);
			}
		}
			
		
		i++;
    });
	
	return false;
	
}

// Função para acessar opções da rotina
function acessaOpcaoAba(nrOpcoes, id, cddopcao) {

	var flpropos;
	
	if (cddopcao == "@") {	// Opção Principal
		var msg = ", carregando dados do " + strTitRotinaLC;
		var urlOperacao = UrlSite + "telas/atenda/limite_credito/principal.php";
	} else if (cddopcao == "N" || cddopcao == "N1") { // Opção Novo Limite
		var msg = ", carregando op&ccedil;&atilde;o para novo " + strTitRotinaLC;
		var urlOperacao = UrlSite + "telas/atenda/limite_credito/novo_limite.php";
		nomeForm = 'frmNovoLimite';
		flpropos = true;

		if (cddopcao == "N" && $("a[name=N]").text() == "Alterar Limite") {
		    mostraTelaAltera();
		    return false;
		} else {
		    cddopcao = "N";
		}

	} else if (cddopcao == "U") { // Opção Últimas Alterações
		var msg = ", carregando &uacute;ltimas altera&ccedil;&otilde;es do " + strTitRotinaLC;
		var urlOperacao = UrlSite + "telas/atenda/limite_credito/ultimas_alteracoes.php";
	} else if (cddopcao == "I") { // Opção Imprimir		
		var msg = ", carregando op&ccedil;&atilde;o para impress&otilde;es";
		var urlOperacao = UrlSite + "telas/atenda/limite_credito/imprimir.php";
	} else if (cddopcao == "A") { // Opção consulta limite ativo
		var msg = ", carregando o limite ativo ";
		var urlOperacao = UrlSite + "telas/atenda/limite_credito/novo_limite.php";
		flpropos = false;
	} else if (cddopcao == "P") { // Opcao consulta limite proposto
		var msg = ", carregando o limite proposto ";
		var urlOperacao = UrlSite + "telas/atenda/limite_credito/novo_limite.php";
		flpropos = true;
	}	
		
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde" + msg + " ...");
	
	// Atribui cor de destaque para aba da opção
	for (var i = 0; i < nrOpcoes; i++) {
		if (!$("#linkAba" + id)) {
			continue;
		}
				
		if (id == i) { // Atribui estilos para foco da opção
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
		url: urlOperacao,
		data: {
			nrdconta: nrdconta,
			cddopcao: cddopcao,
			flpropos: flpropos,
			inconfir: 1,
			redirect: "html_ajax"
		},		
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			$("#divConteudoOpcao").html(response);
			controlaFoco(cddopcao);
		}				
	});	
}

// Função para confirmar novo Limite de Crédito
function confirmaNovoLimite(inconfir, flgratok) {

    var nrcpfcgc = $("#nrcpfcgc", "#frmCabAtenda").val().replace(".", "").replace(".", "").replace("-", "").replace("/", "");
	var camposRS = "";
	var dadosRtS = "";
    var nrctrrat = $("#nrctrpro", "#frmDadosLimiteCredito").val();
	
	if (flgratok) {
        camposRS = retornaCampos(arrayRatingSingulares, '|');
        dadosRtS = retornaValores(arrayRatingSingulares, ';', '|', camposRS);
	}
	
	showMsgAguardo("Aguarde, confirmando novo " + strTitRotinaLC + " ...");
	
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/atenda/limite_credito/confirma_novo_limite.php", 
		data: {
			nrdconta: nrdconta,
			inconfir: inconfir,
			nrcpfcgc: nrcpfcgc,
			nrctrrat: nrctrrat,
			flgratok: flgratok,
			/** Variaveis ref ao rating singulares **/
			camposRS: camposRS,
			dadosRtS: dadosRtS,
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

// Função para excluir proposta de Limite de Crédito
function excluirNovoLimite() {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, excluindo novo " + strTitRotinaLC + " ...");	
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/atenda/limite_credito/excluir_novo_limite.php", 
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

// Função para cancelar Limite de Crédito atual
function cancelarLimiteAtual(nrctrlim) {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, cancelando " + strTitRotinaLC + " atual ...");
	
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/atenda/limite_credito/cancelar_limite_atual.php", 
		data: {
			nrdconta: nrdconta,			
			nrctrlim: nrctrlim,
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

function renovarLimiteAtual(nrctrlim) {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, renovando " + strTitRotinaLC + " atual ...");
	
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/atenda/limite_credito/renovar_limite_atual.php", 
		data: {
			nrdconta: nrdconta,
			nrctrlim: nrctrlim,
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

// Função para validar novo limite de crédito
function validarNovoLimite(inconfir, inconfi2) {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, validando novo " + strTitRotinaLC + " ...");
	
    var nrctrlim = $("#nrctrlim", "#frmNovoLimite").val().replace(/\./g, "");
    var cddlinha = $("#cddlinha", "#frmNovoLimite").val();
    var vllimite = $("#vllimite", "#frmNovoLimite").val().replace(/\./g, "");
    var flgimpnp = $("#flgimpnp", "#frmNovoLimite").val();
	
	// Valida número do contrato
    if (nrctrlim == "" || !validaNumero(nrctrlim, true, 0, 0)) {
		hideMsgAguardo();
        showError("error", "N&uacute;mero de contrato inv&aacute;lido.", "Alerta - Ayllos", "$('#nrctrlim','#frmNovoLimite').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	} 
	
	// Valida linha de crédito
    if (cddlinha == "" || !validaNumero(cddlinha, true, 0, 0)) {
		hideMsgAguardo();
        showError("error", "Linha de cré	dito inv&aacute;lida.", "Alerta - Ayllos", "$('#cddlinha','#frmNovoLimite').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}

	// Valida valor do limite de crédito
    if (vllimite == "" || !validaNumero(vllimite, true, 0, 0)) {
		hideMsgAguardo();
        showError("error", "Valor do " + strTitRotinaLC + " inv&aacute;lido.", "Alerta - Ayllos", "$('#vllimite','#frmNovoLimite').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	} 	
	
	// Executa script de validação do limite através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/limite_credito/validar_novo_limite.php",
		data: {
			nrdconta: nrdconta,
			nrctrlim: nrctrlim,
			cddlinha: cddlinha,
			vllimite: vllimite,
			flgimpnp: flgimpnp,
			inconfir: inconfir,
			inconfi2: inconfi2,
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

// Função para cadastrar novo plano de capital
function cadastrarNovoLimite() {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, cadastrando novo " + strTitRotinaLC + " ...");
	
    nrinfcad = (typeof (nrinfcad) == "undefined") ? 1 : nrinfcad;
	
	// Executa script de cadastro do limite atravé	s de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/limite_credito/cadastrar_novo_limite.php",
		data: {
			nrdconta: nrdconta,
            nrctrlim: $("#nrctrlim", "#frmNovoLimite").val().replace(/\./g, ""),
            cddlinha: $("#cddlinha", "#frmNovoLimite").val(),
            vllimite: $("#vllimite", "#frmNovoLimite").val().replace(/\./g, ""),
            flgimpnp: $("#flgimpnp", "#frmNovoLimite").val(),
            vlsalari: $("#vlsalari", "#frmNovoLimite").val() > 0 ? $("#vlsalari", "#frmNovoLimite").val().replace(/\./g, "") : '0,00',
            vlsalcon: $("#vlsalcon", "#frmNovoLimite").val() > 0 ? $("#vlsalcon", "#frmNovoLimite").val().replace(/\./g, "") : '0,00',
            vloutras: $("#vloutras", "#frmNovoLimite").val() > 0 ? $("#vloutras", "#frmNovoLimite").val().replace(/\./g, "") : '0,00',
            vlalugue: $("#vlalugue", "#frmNovoLimite").val() > 0 ? $("#vlalugue", "#frmNovoLimite").val().replace(/\./g, "") : '0,00',
            inconcje: ($("#inconcje_1", "#frmNovoLimite").prop('checked')) ? 1 : 0,
            dsobserv: $("#dsobserv", "#frmNovoLimite").val(),
			dtconbir: dtconbir,			
			/** Variáveis globais alimentadas na função validaDadosRating em rating.js **/
			nrgarope: nrgarope,
			nrinfcad: nrinfcad,
			nrliquid: nrliquid,
			nrpatlvr: nrpatlvr,			
			perfatcl: perfatcl,
			nrperger: nrperger,		
		    /** ---------------------------------------------------------------------- **/
            nrctaav1: normalizaNumero($("#nrctaav1", "#frmNovoLimite").val()),
            nmdaval1: $("#nmdaval1", "#frmNovoLimite").val(),
            nrcpfav1: normalizaNumero($("#nrcpfav1", "#frmNovoLimite").val()),
            tpdocav1: $("#tpdocav1", "#frmNovoLimite").val(),
            dsdocav1: $("#dsdocav1", "#frmNovoLimite").val(),
            nmdcjav1: $("#nmdcjav1", "#frmNovoLimite").val(),
            cpfcjav1: normalizaNumero($("#cpfcjav1", "#frmNovoLimite").val()),
            tdccjav1: $("#tdccjav1", "#frmNovoLimite").val(),
            doccjav1: $("#doccjav1", "#frmNovoLimite").val(),
            ende1av1: $("#ende1av1", "#frmNovoLimite").val(),
            ende2av1: $("#ende2av1", "#frmNovoLimite").val(),
            nrcepav1: normalizaNumero($("#nrcepav1", "#frmNovoLimite").val()),
            nmcidav1: $("#nmcidav1", "#frmNovoLimite").val(),
            cdufava1: $("#cdufava1", "#frmNovoLimite").val(),
            nrfonav1: $("#nrfonav1", "#frmNovoLimite").val(),
            emailav1: $("#emailav1", "#frmNovoLimite").val(),
            nrender1: normalizaNumero($("#nrender1", "#frmNovoLimite").val()),
            complen1: $("#complen1", "#frmNovoLimite").val(),
            nrcxaps1: normalizaNumero($("#nrcxaps1", "#frmNovoLimite").val()),
            vlrenme1: $("#vlrenme1", "#frmNovoLimite").val(),
			
            nrctaav2: normalizaNumero($("#nrctaav2", "#frmNovoLimite").val()),
            nmdaval2: $("#nmdaval2", "#frmNovoLimite").val(),
            nrcpfav2: normalizaNumero($("#nrcpfav2", "#frmNovoLimite").val()),
            tpdocav2: $("#tpdocav2", "#frmNovoLimite").val(),
            dsdocav2: $("#dsdocav2", "#frmNovoLimite").val(),
            nmdcjav2: $("#nmdcjav2", "#frmNovoLimite").val(),
            cpfcjav2: normalizaNumero($("#cpfcjav2", "#frmNovoLimite").val()),
            tdccjav2: $("#tdccjav2", "#frmNovoLimite").val(),
            doccjav2: $("#doccjav2", "#frmNovoLimite").val(),
            ende1av2: $("#ende1av2", "#frmNovoLimite").val(),
            ende2av2: $("#ende2av2", "#frmNovoLimite").val(),
            nrcepav2: normalizaNumero($("#nrcepav2", "#frmNovoLimite").val()),
            nmcidav2: $("#nmcidav2", "#frmNovoLimite").val(),
            cdufava2: $("#cdufava2", "#frmNovoLimite").val(),
            nrfonav2: $("#nrfonav2", "#frmNovoLimite").val(),
            emailav2: $("#emailav2", "#frmNovoLimite").val(),
            nrender2: normalizaNumero($("#nrender2", "#frmNovoLimite").val()),
            complen2: $("#complen2", "#frmNovoLimite").val(),
            nrcxaps2: normalizaNumero($("#nrcxaps2", "#frmNovoLimite").val()),
            vlrenme2: $("#vlrenme2", "#frmNovoLimite").val(),
			idcobope: $("#idcobert", "#frmNovoLimite").val(),
			redirect: "script_ajax"
		},		
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			try {										
				eval(response);
				changeAbaPropLabel("Alterar Limite");				
            } catch (error) {
				hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	}); 
}

// Função para verificar se deve ser enviado e-mail ao PAC Sede
function verificaEnvioEmail(idimpres, flgimpnp, nrctrlim) {   
    showConfirmacao("Efetuar envio de e-mail para Sede?", "Confirma&ccedil;&atilde;o - Ayllos", "carregarImpresso(" + idimpres + ",'yes','" + flgimpnp + "'," + nrctrlim + ");", "carregarImpresso(" + idimpres + ",'no','" + flgimpnp + "'," + nrctrlim + ");", "sim.gif", "nao.gif");
}

// Função para carregar impresso desejado em PDF (Proposta, Contrato ou Rescisão do Limite de Crédito)
function carregarImpresso(idimpres, flgemail, flgimpnp, nrctrlim, fnfinish) {
	if (nrctrlim == undefined || nrctrlim == 0) {
        nrctrlim = retiraCaracteres($("#contrato", "#frmImprimir").val(), "0123456789", true);
		
        if (nrctrlim == "" || !validaNumero(nrctrlim, true, 0, 0)) {
            showError("error", "Informe o n&uacute;mero do contrato.", "Alerta - Ayllos", "$('#contrato','#frmImprimir').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
			return false;		
		}
	}	
	
	/* alteracao 006 */
	if (idimpres == "5") {
        imprimirRating(false, 1, nrctrlim, "divConteudoOpcao", fnfinish);
		return;
	}	
	
    $("#nrdconta", "#frmImprimir").val(nrdconta);
    $("#idimpres", "#frmImprimir").val(idimpres);
    $("#nrctrlim", "#frmImprimir").val(nrctrlim);
    $("#flgemail", "#frmImprimir").val(flgemail);
    $("#flgimpnp", "#frmImprimir").val(flgimpnp);
	
	var callafter = "blockBackground(parseInt($('#divRotina').css('z-index')));";
    var action = $('#frmImprimir').attr('action');
	
	if (callafterLimiteCred != '') {
		callafter = callafterLimiteCred;
	}

    carregaImpressaoAyllos("frmImprimir", action, callafter);
}

function checaEnter(campo, e) {
	var keycode; 
	if (window.event) keycode = window.event.keyCode; 
	else if (e) keycode = e.which; 
	else return true; 

	if (keycode == 13)
		return false; 
	else 
		return true; 
}

function abrirTelaGAROPC(cddopcao, idcobert, nrctrlim) {

    showMsgAguardo('Aguarde, carregando ...');
	
    exibeRotina($('#divUsoGAROPC'));
    $('#divRotina').css({'display':'none'});
	
    var tipaber = '';
	var idcobert = normalizaNumero($('#idcobert','#frmNovoLimite').val());
	var codlinha = normalizaNumero($('#cddlinha','#frmNovoLimite').val());
    var vllimite = $('#vllimite','#frmNovoLimite').val();
	
	switch (cddopcao) {
		case 'N':
			tipaber = (idcobert > 0) ? 'A' : 'I';
			break;
		default:
			tipaber = 'C';
			break;
	}
	
    // Carrega conteúdo da opção através do Ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/garopc/garopc.php',
        data: {
            nmdatela     : 'LIMITE_CREDITO',
            tipaber      : tipaber,
            nrdconta     : nrdconta,
            tpctrato     : 1,
            idcobert     : idcobert,
            dsctrliq     : cddopcao = 'P' ? nrctrlim : '',
            codlinha     : codlinha,
            vlropera     : vllimite,
            divanterior  : 'divRotina',
            ret_nomcampo : 'idcobert',
            ret_nomformu : 'frmNovoLimite',
            ret_execfunc : 'lcrShowHideDiv(\\\'divDadosObservacoes\\\',\\\'divDadosRenda\\\');$(\\\'#divRotina\\\').css({\\\'display\\\':\\\'block\\\'});bloqueiaFundo($(\\\'#divRotina\\\'));',
            ret_errofunc : '$(\\\'#divRotina\\\').css({\\\'display\\\':\\\'block\\\'});bloqueiaFundo($(\\\'#divRotina\\\'));',
			redirect     : 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function (response) {
            hideMsgAguardo();
            $('#divUsoGAROPC').html(response);
            bloqueiaFundo($('#divUsoGAROPC'));
        }
    });
} 

// Função para mostrar div com formulário de dados para digitação ou consulta
function lcrShowHideDiv(divShow, divHide) {
    $("#" + divShow).css("display", "block");
    $("#" + divHide).css("display", "none");
}

/*
 * OBJETIVO : Função para validar avalistas 
 * ALTERAÇÃO 001: Padronizado o recebimento de valores 
 */
function validarAvalistas() {
	
	showMsgAguardo('Aguarde, validando dados dos avalistas ...');
	
    var nrctaav1 = normalizaNumero($('#nrctaav1', '#' + nomeForm).val());
    var nrcpfav1 = normalizaNumero($('#nrcpfav1', '#' + nomeForm).val());
    var cpfcjav1 = normalizaNumero($('#cpfcjav1', '#' + nomeForm).val());
    var nrctaav2 = normalizaNumero($('#nrctaav2', '#' + nomeForm).val());
    var nrcpfav2 = normalizaNumero($('#nrcpfav2', '#' + nomeForm).val());
    var cpfcjav2 = normalizaNumero($('#cpfcjav2', '#' + nomeForm).val());

    var nmdaval1 = trim($('#nmdaval1', '#' + nomeForm).val());
    var ende1av1 = trim($('#ende1av1', '#' + nomeForm).val());
    var nrcepav1 = normalizaNumero($('#nrcepav1', '#' + nomeForm).val());
	
    var nmdaval2 = trim($('#nmdaval2', '#' + nomeForm).val());
    var ende1av2 = trim($('#ende1av2', '#' + nomeForm).val());
    var nrcepav2 = normalizaNumero($('#nrcepav2', '#' + nomeForm).val());
	
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/limite_credito/validar_dados_avalistas.php",
		data: {
            nrdconta: nrdconta, nrctaav1: nrctaav1, nmdaval1: nmdaval1,
            nrcpfav1: nrcpfav1, cpfcjav1: cpfcjav1, ende1av1: ende1av1,
            nrctaav2: nrctaav2, nmdaval2: nmdaval2, nrcpfav2: nrcpfav2,
            cpfcjav2: cpfcjav2, ende1av2: ende1av2, nrcepav1: nrcepav1,
			nrcepav2: nrcepav2, flgpropo: flgProposta, redirect: 'script_ajax'
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

// Função para formata o layout
function controlaLayout(cddopcao) {

	//----------------------------------------------------------------
	// FORMULÁRIO NOVO LIMITE
	//----------------------------------------------------------------		
    var cTodosLimite = $('input, select', '#' + nomeForm + ' .fsLimiteCredito');
    $('label', '#' + nomeForm + ' .fsLimiteCredito').addClass('rotulo').css('width', '200px');
    $('#nrctrlim', '#' + nomeForm + ' .fsLimiteCredito').addClass('contrato').css('width', '60px');
    $('#cddlinha', '#' + nomeForm + ' .fsLimiteCredito').addClass('codigo pesquisa').attr('maxlength', '3').css('width', '35px');
    $('#dsdlinha', '#' + nomeForm + ' .fsLimiteCredito').addClass('descricao').css('width', '170px');
    $('#vllimite', '#' + nomeForm + ' .fsLimiteCredito').addClass('moeda').css('width', '90px');
    $('#flgimpnp', '#' + nomeForm + ' .fsLimiteCredito').css('width', '70px');
    $('#dsobserv', '#' + nomeForm + ' .fsObservacoes').addClass('campo');
				
	// Se for novo limite ou alteracao, habilitar campos
	if (cddopcao == 'N') {
		cTodosLimite.habilitaCampo();
	} else {
		cTodosLimite.desabilitaCampo();
	}
		
	if (flgProposta) {
        $('#nrctrlim', '#' + nomeForm + ' .fsLimiteCredito').desabilitaCampo();
		changeAbaPropLabel("Alterar Limite");
    } else {
		changeAbaPropLabel("Novo Limite");				
	}
	
	//----------------------------------------------------------------
	// FORMULÁRIO DADOS DA RENDA
	//----------------------------------------------------------------	

    var rSalTit = $('label[for="vlsalari"]', '#' + nomeForm + ' .fsDadosRenda');
    var rSalCjg = $('label[for="vlsalcon"]', '#' + nomeForm + ' .fsDadosRenda');
    var rOutras = $('label[for="vloutras"]', '#' + nomeForm + ' .fsDadosRenda');
    var rAlugue = $('label[for="vlalugue"]', '#' + nomeForm + ' .fsDadosRenda');
    var rInconc = $('label[for="inconcje"]', '#' + nomeForm + ' .fsConjuge');
    var cValores = $('input type="text"', '#' + nomeForm + ' .fsDadosRenda');
    var cInconcje = $('input', '#' + nomeForm + ' .fsConjuge');
	
    rSalTit.addClass('rotulo').css({ 'width': '130px' });
    rOutras.addClass('rotulo').css({ 'width': '130px' });
    rSalCjg.addClass('rotulo-linha').css({ 'width': '80px' });
    rAlugue.addClass('rotulo-linha').css({ 'width': '80px' });
    rInconc.addClass('rotulo-linha').css({ 'width': '130px' });
    cValores.addClass('moeda').css({ 'width': '90px' }).val('0').habilitaCampo();
    cInconcje.css({ 'width': '30px' }).habilitaCampo();
	
	//----------------------------------------------------------------
	// FORMULÁRIO OBSERVAÇÕES
	//----------------------------------------------------------------		
    $('#dsobserv', '#' + nomeForm + ' .fsObservacoes').addClass('campo').css({ 'width': '95%', 'height': '90px' });
	
	//----------------------------------------------------------------
	// FORMULÁRIO RATING SINGULARES
	//----------------------------------------------------------------		
    $('fieldset').css({ 'clear': 'both', 'border': '1px solid #777', 'margin': '3px 0px', 'padding': '10px 3px 5px 3px' });
    $('fieldset > legend').css({ 'font-size': '11px', 'color': '#777', 'margin-left': '5px', 'padding': '0px 2px' });
	
	// Se nao for pessoa fisica, esconder informacoes do conjuge
	if (inpessoa != 1) {	
        $(".fsConjuge", "#divDadosRenda").css('display', 'none');
	}
	
	// Se nao tiver conjuge, desabilita a consulta automatizadas para o mesmo
	if (nrcpfcjg == 0 && nrctacje == 0) {	
        $("input[name='inconcje']", "#divDadosRenda").desabilitaCampo();
	}
	
	layoutPadrao();	
	cValores.trigger('blur');
	controlaPesquisas();

	callafterLimiteCred = '';
}

// Função que formata a tabela ultimas alteracoes
function formataUltimasAlteracoes() {
			
	var divRegistro = $('div.divRegistros');		
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);
			
    divRegistro.css({ 'height': '200px', 'width': '100%' });
	
	var ordemInicial = new Array();
    ordemInicial = [[1, 1]];
			
	var arrayLargura = new Array();
	arrayLargura[0] = '60px';
	arrayLargura[1] = '60px';
	arrayLargura[2] = '60px';
	arrayLargura[3] = '75px';
	arrayLargura[4] = '75px';
	
		
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'center';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'left';
	arrayAlinha[5] = 'left';
	
    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);
	return false;
}

// Função que formata a imprimir
function formataImprimir() {

    $('#frmImprimir').css({ 'padding': '10px' });
	
	// label
	rContrato = $('label[for="contrato"]', '#frmImprimir');
    rContrato.css({ 'font-weight': 'bold' })
	
	// campo
	cContrato = $('#contrato', '#frmImprimir');
    cContrato.addClass('contrato campo').css({ 'width': '100px', 'text-align': 'right' });
	
	layoutPadrao();
	
}

// Função que formata a pagina principal
function formataPrincipal() {

	$('input, select', '#frmDadosLimiteCredito').desabilitaCampo();		

	// rotulo
    rVllimite = $('label[for="vllimite"]', '#frmDadosLimiteCredito');
    rDtmvtolt = $('label[for="dtmvtolt"]', '#frmDadosLimiteCredito');
    rCddlinha = $('label[for="cddlinha"]', '#frmDadosLimiteCredito');
    rDtfimvig = $('label[for="dtfimvig"]', '#frmDadosLimiteCredito');
    rNrctrlim = $('label[for="nrctrlim"]', '#frmDadosLimiteCredito');
    rQtdiavig = $('label[for="qtdiavig"]', '#frmDadosLimiteCredito');
    rDsencfi1 = $('label[for="dsencfi1"]', '#frmDadosLimiteCredito');
    rDsencfi2 = $('label[for="dsencfi2"]', '#frmDadosLimiteCredito');
    rDsencfi3 = $('label[for="dsencfi3"]', '#frmDadosLimiteCredito');
    rDssitlli = $('label[for="dssitlli"]', '#frmDadosLimiteCredito');
    rNmoperad = $('label[for="nmoperad"]', '#frmDadosLimiteCredito');
    rNmopelib = $('label[for="nmopelib"]', '#frmDadosLimiteCredito');
    rFlgenvio = $('label[for="flgenvio"]', '#frmDadosLimiteCredito');
    rDstprenv = $('label[for="dstprenv"]', '#frmDadosLimiteCredito');
    rQtrenova = $('label[for="qtrenova"]', '#frmDadosLimiteCredito');
    rDtrenova = $('label[for="dtrenova"]', '#frmDadosLimiteCredito');
	rDtultmaj = $('label[for="dtultmaj"]', '#frmDadosLimiteCredito');

    rVllimite.addClass('rotulo').css({ 'width': '126px' });
    rDtmvtolt.addClass('rotulo-linha').css({ 'width': '110px' });
    rCddlinha.addClass('rotulo').css({ 'width': '126px' });
    rDtfimvig.addClass('rotulo-linha').css({ 'width': '110px' });
    rNrctrlim.addClass('rotulo').css({ 'width': '126px' });
    rQtdiavig.addClass('rotulo-linha').css({ 'width': '250px' });
    rDsencfi1.addClass('rotulo').css({ 'width': '126px' });
    rDsencfi2.addClass('rotulo').css({ 'width': '126px' });
    rDsencfi3.addClass('rotulo').css({ 'width': '126px' });
    rDssitlli.addClass('rotulo').css({ 'width': '126px' });
    rNmoperad.addClass('rotulo').css({ 'width': '126px' });
    rNmopelib.addClass('rotulo').css({ 'width': '126px' });
    rFlgenvio.addClass('rotulo').css({ 'width': '126px' });
    rDstprenv.addClass('rotulo').css({ 'width': '126px' });
    rQtrenova.addClass('rotulo-linha').css({ 'width': '83px' });
    rDtrenova.addClass('rotulo-linha').css({ 'width': '91px' });
	rDtultmaj.addClass('rotulo-linha').css({ 'width': '80px' });
	
	// campos
    cVllimite = $('#vllimite', '#frmDadosLimiteCredito');
    cDtmvtolt = $('#dtmvtolt', '#frmDadosLimiteCredito');
    cCddlinha = $('#cddlinha', '#frmDadosLimiteCredito');
    cDtfimvig = $('#dtfimvig', '#frmDadosLimiteCredito');
    cNrctrlim = $('#nrctrlim', '#frmDadosLimiteCredito');
    cQtdiavig = $('#qtdiavig', '#frmDadosLimiteCredito');
    cDsencfi1 = $('#dsencfi1', '#frmDadosLimiteCredito');
    cDsencfi2 = $('#dsencfi2', '#frmDadosLimiteCredito');
    cDsencfi3 = $('#dsencfi3', '#frmDadosLimiteCredito');
    cDssitlli = $('#dssitlli', '#frmDadosLimiteCredito');
    cNmoperad = $('#nmoperad', '#frmDadosLimiteCredito');
    cNmopelib = $('#nmopelib', '#frmDadosLimiteCredito');
    cFlgenvio = $('#flgenvio', '#frmDadosLimiteCredito');
    cDstprenv = $('#dstprenv', '#frmDadosLimiteCredito');
    cQtrenova = $('#qtrenova', '#frmDadosLimiteCredito');
    cDtrenova = $('#dtrenova', '#frmDadosLimiteCredito');
	cDtultmaj = $('#dtultmaj', '#frmDadosLimiteCredito');

    cVllimite.css({ 'width': '220px' });
    cDtmvtolt.css({ 'width': '70px' });
    cCddlinha.css({ 'width': '220px' });
    cDtfimvig.css({ 'width': '70px' });
    cNrctrlim.css({ 'width': '80px' });
    cQtdiavig.css({ 'width': '70px' });
    cDsencfi1.css({ 'width': '336px' });
    cDsencfi2.css({ 'width': '336px' });
    cDsencfi3.css({ 'width': '336px' });
    cDssitlli.css({ 'width': '250px' });
    cNmoperad.css({ 'width': '250px' });
    cNmopelib.css({ 'width': '250px' });
    cFlgenvio.css({ 'width': '250px' });
    cDstprenv.css({ 'width': '80px' });
    cQtrenova.css({ 'width': '70px' });
    cDtrenova.css({ 'width': '70px' });
	cDtultmaj.css({ 'width': '70px' });

	// ie
    if ($.browser.msie) {
        $('#novoContratoLimite').css({ 'padding': '10px', 'text-align': 'center', 'height': '30px', 'width': '93%' });
        cDsencfi1.css({ 'width': '333px' });
        cDsencfi2.css({ 'width': '333px' });
        cDsencfi3.css({ 'width': '333px' });
	}	

}

// Função que controla a lupa de pesquisa
function controlaPesquisas() {		
	
	var campoAnterior = '';
	var procedure, titulo, qtReg, filtrosPesq, filtrosDesc, colunas;	
    var bo = 'zoom0001';
	
    $('a', '#' + nomeForm).ponteiroMouse();
	
	// CÓDIGO DA LINHA
	titulo      = 'Linhas de Crédito';
	procedure   = 'BUSCALINHAS';
	$('#cddlinha','#'+nomeForm).unbind('change').bind('change', function() {
	    filtrosDesc = 'tpdlinha|' + inpessoa + ';flgstlcr|1;nriniseq|1;nrregist|30';
		buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'dsdlinha',$(this).val(),'dsdlinha',filtrosDesc,'frmNovoLimite');
		return false;
    }).next().unbind('click').bind('click', function () {
        filtrosPesq = 'Linha;cddlinha;30px;S;|Descrição;dsdlinha;200px;S;|Tipo;tpdlinha;20px;N;' + inpessoa + "|;flgstlcr;;;1;N";
        colunas = 'Código;cddlinha;11%;right|Descrição;dsdlinha;49%;left|Tipo;dsdtplin;18%;left|Taxa;dsdtxfix;22%;center';
        fncOnClose = 'cddlinha = $("#cddlinha","#frmNovoLimite").val()';
        mostraPesquisa(bo, procedure, titulo, '20', filtrosPesq, colunas, divRotina, fncOnClose);
        return false;
    });
}


//Função para controle de navegação	
function controlaFoco(opcao) {

    if (opcao == "@") { //Principal

        $('#divConteudoOpcao').each(function () {
            formid = $('#divConteudoOpcao form');
            IdForm = $(formid).attr('id');//Seleciona o id do formulario
            if (IdForm == "frmDadosLimiteCredito") {
                $(this).find("#divBotoes > a").attr({ href: 'javascript:void(null);' });
                $(this).find("#divBotoes > a").first().addClass("FirstInputModal").focus().css({ 'position': 'relative', 'top': '-3px' });
                $(this).find("#divBotoes > a img").first().css({ 'margin': '0 0 0 -3px' });
                $(this).find("#divBotoes > a").last().addClass("LastInputModal").css({ 'position': 'relative', 'top': '-4px' });
                $(this).find("#divBotoes > a img").last().css({ 'margin': '0 0 0 -3px' });
                $(this).find("#divBotoes > a").last().addClass("FluxoNavega");
                $(this).find("#divBotoes > :input[type=image]").addClass("FluxoNavega");

                $(this).find("#divDadosPrincipal_2 :input[type=image]").first().addClass("FirstInputModal").focus();
                $(this).find("#divDadosPrincipal_2 :input[type=image]").addClass("FluxoNavega");
                $(this).find("#divDadosPrincipal_2 :input[type=image]").last().addClass("LastInputModal");

				
				//Se estiver com foco na classe LastInputModal
                $(".FirstInputModal").focus(function () {
                    $(this).bind('keydown', function (e) {
                        if (e.keyCode == 27) {
                            encerraRotina().click();
                        }
                    })              
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

                        if (e.keyCode == 13) {
                            e.preventDefault();
                            e.stopImmediatePropagation();
                            $(".LastInputModal").click();
                        }
                        if (e.keyCode == 16) {
                            pressedShift = true;//Quando tecla shift for pressionada passa valor true 
                        }
                        if ((e.keyCode == 9) && pressedShift == true) {
                            return setFocusCampo($(target), e, false, 0);
                        }
                        else if (e.keyCode == 9) {
                            e.stopPropagation();
                            e.preventDefault();
                            $(".FirstInputModal").focus();
                        }
                    });
                });
            }

            //Se estiver com foco na classe FluxoNavega
            $(".FluxoNavega").focus(function () {
                $(this).bind('keydown', function (e) {
                    if (e.keyCode == 13) {
                        e.preventDefault();
                        e.stopImmediatePropagation();
                        $(this).click();
                    }
                });
            });

        });

        $(".FirstInputModal").focus();
    }
    if (opcao == "N") { //Novo Limite

        $('#divConteudoOpcao').each(function () {
            formid = $('#divConteudoOpcao form');
            IdForm = $(formid).attr('id');//Seleciona o id do formulario
            if (IdForm == "frmNovoLimite") {
                $(this).find("#frmNovoLimite #divDadosLimite .fsLimiteCredito > :input[type=text]").first().addClass("FirstInputModal").focus();
                $(this).find("#divBotoes:first > :input[type=image]").last().addClass("LastInputModal");
                $("#btVoltar").focus(function () {
                    $(this).bind('keydown', function (e) {
                        if (e.keyCode == 13) {
                            acessaOpcaoAba(8, 0, '@');
		return false;										
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
                        if (e.keyCode == 13) {
                            e.stopPropagation();
                            e.preventDefault();
                            $(".LastInputModal").click();
                        }
                        if (e.keyCode == 16) {
                            pressedShift = true;//Quando tecla shift for pressionada passa valor true 
                        }
                        if ((e.keyCode == 9) && pressedShift == true) {
                            return setFocusCampo($(target), e, false, 0);
                        }
                        else if (e.keyCode == 9) {
                            e.stopPropagation();
                            e.preventDefault();
                            $(".FirstInputModal").focus();
                        }
                    });
                });
            };
        });
        $(".FirstInputModal").focus();
    }
    if (opcao == "I") { //Imprimir

        $('#divConteudoOpcao').each(function () {
            formid = $('#divConteudoOpcao form');
            IdForm = $(formid).attr('id');//Seleciona o id do formulario
            if (IdForm == "frmImprimir") {
                $(this).find("#frmImprimir > :input[type=text]").first().addClass("FirstInputModal").focus();
                $(this).find("#divBotoes > a").last().addClass("LastInputModal");

                //Se estiver com foco na classe LastInputModal
                $(".LastInputModal").focus(function () {
                    var pressedShift = false;

                    $(this).bind('keyup', function (e) {
                        if (e.keyCode == 16) {
                            pressedShift = false;//Quando tecla shift for solta passa valor false 
                        }
                    })

                    $(this).bind('keydown', function (e) {

                        if (e.keyCode == 13) {
                            e.stopPropagation();
                            e.preventDefault();
                            $(".LastInputModal").click();
                        }
                        if (e.keyCode == 16) {
                            pressedShift = true;//Quando tecla shift for pressionada passa valor true 
                        }
                        if ((e.keyCode == 9) && pressedShift == true) {
                            return setFocusCampo($(target), e, false, 0);
                        }
                        else if (e.keyCode == 9) {
                            //e.stopPropagation();
                            //e.preventDefault();
                            $(".FirstInputModal").focus();
                        }
                    });
                });
            }
        });
        $(".FirstInputModal").focus();
    }
    if (opcao == "U") { //Últimas alterações
        $('#divConteudoOpcao').bind('keydown', function (e) {
            if (e.keyCode == 27) {
                encerraRotina().click();
            }
        })

        $('#divConteudoOpcao').each(function () {
            $(".tituloRegistros").find("thead tr th").first().addClass("FirstInputModal").focus();
        });
    }

    if (opcao == "A") { //Cons.Lim.Ativo

        $('#divConteudoOpcao').bind('keydown', function (e) {
            if (e.keyCode == 27) {
                encerraRotina().click();
            }
        })

        $('#divConteudoOpcao').each(function () {
            formid = $('#divConteudoOpcao form');
            IdForm = $(formid).attr('id');//Seleciona o id do formulario

            if (IdForm == "frmNovoLimite") {
                $("#frmNovoLimite").find("#divDadosLimite #divBotoes > :input[type=image]").first().addClass("FirstInputModal").focus();
                $("#frmNovoLimite").find("#divDadosLimite #divBotoes > :input[type=image]").addClass("FluxoNavega");
                $("#frmNovoLimite").find("#divDadosLimite #divBotoes > :input[type=image]").last().addClass("LastInputModal");

                //Se estiver com foco na classe LastInputModal
                $(".LastInputModal").focus(function () {
                    var pressedShift = false;

                    $(this).bind('keyup', function (e) {
                        if (e.keyCode == 16) {
                            pressedShift = false;//Quando tecla shift for solta passa valor false 
                        }
                    })

                    $(this).bind('keydown', function (e) {

                        if (e.keyCode == 13) {
                            $(".LastInputModal").click();
                        }
                        if (e.keyCode == 27) {
                            encerraRotina().click();
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
            }

            //Se estiver com foco na classe FluxoNavega
            $(".FluxoNavega").focus(function () {
                $(this).bind('keydown', function (e) {
                    if (e.keyCode == 13) {
                        $(this).click();
                    }
                });
            });

        });

        $(".FirstInputModal").focus();
    }

    if (opcao == "P") { //Cons.Lim.Proposto
        $('#divConteudoOpcao').bind('keydown', function (e) {
            if (e.keyCode == 27) {
                encerraRotina().click();
            }
        })

        $('#divConteudoOpcao').each(function () {
            formid = $('#divConteudoOpcao form');
            IdForm = $(formid).attr('id');//Seleciona o id do formulario
            if (IdForm == "frmNovoLimite") {
                $(this).find("#divBotoes > :input[type=image]").addClass("FluxoNavega");
                $(this).find("#divBotoes > :input[type=image]").first().addClass("FirstInputModal").focus();
            }
	});	

        //Se estiver com foco na classe FluxoNavega
        $(".FluxoNavega").focus(function () {
            $(this).bind('keydown', function (e) {


                if (e.keyCode == 13) {
                    $(this).click();
                }
                if (e.keyCode == 27) {
                    encerraRotina().click();
}
            });
        });

        $(".FirstInputModal").focus();
    }
}



// Função para fechar div com mensagens de alerta
function encerraMsgsGrupoEconomico() {
	
	// Esconde div
    $("#divMsgsGrupoEconomico").css("visibility", "hidden");
	
	$("#divListaMsgsGrupoEconomico").html("&nbsp;");
	
	// Esconde div de bloqueio
	unblockBackground();
	blockBackground(parseInt($("#divRotina").css("z-index")));
	
	eval(dsmetodo);
	
	return false;
	
}

function mostraMsgsGrupoEconomico() {
	
	
    if (strHTML != '') {
		
		// Coloca conteúdo HTML no div
		$("#divListaMsgsGrupoEconomico").html(strHTML);
		$("#divMensagem").html(strHTML2);
				
		// Mostra div 
        $("#divMsgsGrupoEconomico").css("visibility", "visible");
		
		exibeRotina($("#divMsgsGrupoEconomico"));
		
		// Esconde mensagem de aguardo
		hideMsgAguardo();
					
		// Bloqueia conteúdo que está átras do div de mensagens
		blockBackground(parseInt($("#divMsgsGrupoEconomico").css("z-index")));
				
	}
	
	return false;
	
}

function formataGrupoEconomico() {

    var divRegistro = $('div.divRegistros', '#divMsgsGrupoEconomico');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);
			
    divRegistro.css({ 'height': '140px' });
	
    $('#divListaMsgsGrupoEconomico').css({ 'height': '200px' });
    $('#divMensagem').css({ 'width': '250px' });
	
	var ordemInicial = new Array();
					
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	
    tabela.formataTabela(ordemInicial, '', arrayAlinha);
	
	return false;
	
}



function buscaGrupoEconomico() {

	showMsgAguardo("Aguarde, verificando grupo econ&ocirc;mico...");
	
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/atenda/descontos/titulos/busca_grupo_economico.php',
		data: {
			nrdconta: nrdconta,	
			redirect: 'html_ajax'
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
	
	return false;
	
}

function calcEndividRiscoGrupo(nrdgrupo) {

	showMsgAguardo("Aguarde, calculando endividamento e risco do grupo econ&ocirc;mico...");

	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/atenda/descontos/titulos/calc_endivid_grupo.php',
		data: {
			nrdconta: nrdconta,	
			nrdgrupo: nrdgrupo,
			redirect: 'html_ajax'
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
	
	return false;
	
}

function escondeObservacoes() {
    $("#divDadosPrincipal, #divDadosPrincipal_2").css('display', 'block');
    $("#divDadosObservacoes").css("display", "none");
}

function confirmaAlteracaoObservacao(nrctrpro) {
    showConfirmacao('Deseja confirmar a altera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'atualizaObservacoes(' + nrctrpro + ')', 'blockBackground(parseInt($("#divRotina").css("z-index")))', 'sim.gif', 'nao.gif');
}

function atualizaObservacoes(nrctrpro) {
	
	showMsgAguardo("Aguarde, gravando as observa&ccedil;&otilde;es...");

	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/atenda/limite_credito/grava_observacao.php',
		data: {
			nrdconta: nrdconta,	
			nrctrlim: nrctrpro,
            dsobserv: $("#dsobserv", "#divDadosObservacoes").val(),
			redirect: 'html_ajax'
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
	
	return false;
	
}

//***********************************************************TIAGO********************************************************
// Função para validar novo limite de crédito
function validarAlteracaoLimite(inconfir, inconfi2) {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, validando novo " + strTitRotinaLC + " ...");
	
    var nrctrlim = $("#nrctrlim", "#frmNovoLimite").val().replace(/\./g, "");
    var cddlinha = $("#cddlinha", "#frmNovoLimite").val();
    var vllimite = $("#vllimite", "#frmNovoLimite").val().replace(/\./g, "");
    var flgimpnp = $("#flgimpnp", "#frmNovoLimite").val();
	
	// Valida número do contrato
    if (nrctrlim == "" || !validaNumero(nrctrlim, true, 0, 0)) {
		hideMsgAguardo();
        showError("error", "N&uacute;mero de contrato inv&aacute;lido.", "Alerta - Ayllos", "$('#nrctrlim','#frmNovoLimite').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	} 
	
	// Valida linha de crédito
    if (cddlinha == "" || !validaNumero(cddlinha, true, 0, 0)) {
		hideMsgAguardo();
        showError("error", "Linha de cré	dito inv&aacute;lida.", "Alerta - Ayllos", "$('#cddlinha','#frmNovoLimite').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}

	// Valida valor do limite de crédito
    if (vllimite == "" || !validaNumero(vllimite, true, 0, 0)) {
		hideMsgAguardo();
        showError("error", "Valor do " + strTitRotinaLC + " inv&aacute;lido.", "Alerta - Ayllos", "$('#vllimite','#frmNovoLimite').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	} 	
	
	// Executa script de validação do limite através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/limite_credito/validar_alteracao_limite.php",
		data: {
			nrdconta: nrdconta,
			nrctrlim: nrctrlim,
			cddlinha: cddlinha,
			vllimite: vllimite,
			flgimpnp: flgimpnp,
			inconfir: inconfir,
			inconfi2: inconfi2,
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

// Função para cadastrar novo plano de capital
function alterarNovoLimite() {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, alterando o " + strTitRotinaLC + " ...");
			
	// Executa script de cadastro do limite atravé	s de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/limite_credito/alterar_novo_limite.php",
		data: {
			nrdconta: nrdconta,
            nrctrlim: $("#nrctrlim", "#frmNovoLimite").val().replace(/\./g, ""),
            cddlinha: $("#cddlinha", "#frmNovoLimite").val(),
            vllimite: $("#vllimite", "#frmNovoLimite").val().replace(/\./g, ""),
            flgimpnp: $("#flgimpnp", "#frmNovoLimite").val(),
            vlsalari: $("#vlsalari", "#frmNovoLimite").val().replace(/\./g, ""),
            vlsalcon: $("#vlsalcon", "#frmNovoLimite").val().replace(/\./g, ""),
            vloutras: $("#vloutras", "#frmNovoLimite").val().replace(/\./g, ""),
            vlalugue: $("#vlalugue", "#frmNovoLimite").val().replace(/\./g, ""),
            inconcje: ($("#inconcje_1", "#frmNovoLimite").prop('checked')) ? 1 : 0,
            dsobserv: $("#dsobserv", "#frmNovoLimite").val(),
			dtconbir: dtconbir,			
			/** Variáveis globais alimentadas na função validaDadosRating em rating.js **/
			nrgarope: nrgarope,
			nrinfcad: nrinfcad,
			nrliquid: nrliquid,
			nrpatlvr: nrpatlvr,			
			perfatcl: perfatcl,
			nrperger: nrperger,		
		    /** ---------------------------------------------------------------------- **/
            nrctaav1: normalizaNumero($("#nrctaav1", "#frmNovoLimite").val()),
            nmdaval1: $("#nmdaval1", "#frmNovoLimite").val(),
            nrcpfav1: normalizaNumero($("#nrcpfav1", "#frmNovoLimite").val()),
            tpdocav1: $("#tpdocav1", "#frmNovoLimite").val(),
            dsdocav1: $("#dsdocav1", "#frmNovoLimite").val(),
            nmdcjav1: $("#nmdcjav1", "#frmNovoLimite").val(),
            cpfcjav1: normalizaNumero($("#cpfcjav1", "#frmNovoLimite").val()),
            tdccjav1: $("#tdccjav1", "#frmNovoLimite").val(),
            doccjav1: $("#doccjav1", "#frmNovoLimite").val(),
            ende1av1: $("#ende1av1", "#frmNovoLimite").val(),
            ende2av1: $("#ende2av1", "#frmNovoLimite").val(),
            nrcepav1: normalizaNumero($("#nrcepav1", "#frmNovoLimite").val()),
            nmcidav1: $("#nmcidav1", "#frmNovoLimite").val(),
            cdufava1: $("#cdufava1", "#frmNovoLimite").val(),
            nrfonav1: $("#nrfonav1", "#frmNovoLimite").val(),
            emailav1: $("#emailav1", "#frmNovoLimite").val(),
            nrender1: normalizaNumero($("#nrender1", "#frmNovoLimite").val()),
            complen1: $("#complen1", "#frmNovoLimite").val(),
            nrcxaps1: normalizaNumero($("#nrcxaps1", "#frmNovoLimite").val()),
            vlrenme1: $("#vlrenme1", "#frmNovoLimite").val(),

            nrctaav2: normalizaNumero($("#nrctaav2", "#frmNovoLimite").val()),
            nmdaval2: $("#nmdaval2", "#frmNovoLimite").val(),
            nrcpfav2: normalizaNumero($("#nrcpfav2", "#frmNovoLimite").val()),
            tpdocav2: $("#tpdocav2", "#frmNovoLimite").val(),
            dsdocav2: $("#dsdocav2", "#frmNovoLimite").val(),
            nmdcjav2: $("#nmdcjav2", "#frmNovoLimite").val(),
            cpfcjav2: normalizaNumero($("#cpfcjav2", "#frmNovoLimite").val()),
            tdccjav2: $("#tdccjav2", "#frmNovoLimite").val(),
            doccjav2: $("#doccjav2", "#frmNovoLimite").val(),
            ende1av2: $("#ende1av2", "#frmNovoLimite").val(),
            ende2av2: $("#ende2av2", "#frmNovoLimite").val(),
            nrcepav2: normalizaNumero($("#nrcepav2", "#frmNovoLimite").val()),
            nmcidav2: $("#nmcidav2", "#frmNovoLimite").val(),
            cdufava2: $("#cdufava2", "#frmNovoLimite").val(),
            nrfonav2: $("#nrfonav2", "#frmNovoLimite").val(),
            emailav2: $("#emailav2", "#frmNovoLimite").val(),
            nrender2: normalizaNumero($("#nrender2", "#frmNovoLimite").val()),
            complen2: $("#complen2", "#frmNovoLimite").val(),
            nrcxaps2: normalizaNumero($("#nrcxaps2", "#frmNovoLimite").val()),
            vlrenme2: $("#vlrenme2", "#frmNovoLimite").val(),
            idcobope: $("#idcobert", "#frmNovoLimite").val(),
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

function buscaDadosProposta(nrdconta, nrctrlim) {

	// Executa script de confirmação através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/atenda/limite_credito/obtem_dados_proposta.php", 
		data: {
			nrdconta: nrdconta,
			nrctrlim: nrctrlim,
			redirect: "script_ajax"
		}, 
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			try {				
				eval(response);				
				hideMsgAguardo();				
				blockBackground(parseInt($("#divRotina").css("z-index")));				
            } catch (error) {
				hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		} 				
	});				

}

function dadosRenda() {

    var nrctrlim = $("#nrctrlim", ".fsLimiteCredito").val();
	var cTodosRenda = $('input, select', '#divDadosRenda');		
	
	showMsgAguardo("Aguarde, consultando dados ...");
			
    $("#divDadosLimite").css("display", "none");
    $("#divDadosRenda").css("display", "block");
	cTodosRenda.desabilitaCampo();

	buscaDadosProposta(nrdconta, nrctrlim);
	
}

function setDadosProposta(vlsalari, vlsalcon, vloutras, vlalugue, nrctaav1, nrctaav2, inconcje, nrcpfav1, nrcpfav2, idcobert) {
	//Nao estava preenchendo corretamente o campo quando retornava um valor decimal
	//Chamado 364592
    vlsalari = vlsalari.replace(",", ".");
    vlsalcon = vlsalcon.replace(",", ".");
    vloutras = vloutras.replace(",", ".");
    vlalugue = vlalugue.replace(",", ".");

    $("#vlsalari").val(number_format(vlsalari, 2, ",", "."));
    $("#vlsalcon").val(number_format(vlsalcon, 2, ",", "."));
    $("#vloutras").val(number_format(vloutras, 2, ",", "."));
    $("#vlalugue").val(number_format(vlalugue, 2, ",", "."));
    $("#inconcje_" + inconcje).prop('checked', 'true');
		
    $("#nrctaav1", "#frmNovoLimite").val(nrctaav1);
    $("#nrctaav2", "#frmNovoLimite").val(nrctaav2);
    $("#nrcpfav1", "#frmNovoLimite").val(nrcpfav1);
    $("#nrcpfav2", "#frmNovoLimite").val(nrcpfav2);
	$("#idcobert", "#frmNovoLimite").val(idcobert);
    
	// Salvar o valor da consulta do conjuge antes de ser alterado pelo usuario
	ant_inconcje = inconcje;
	
}

function setDadosRating(nrgarope, nrinfcad, nrliquid, nrpatlvr) {

    var nrctaav1 = normalizaNumero($('#nrctaav1', '#divDadosAvalistas').val());
    var nrcpfav1 = normalizaNumero($('#nrcpfav1', '#divDadosAvalistas').val());
	
    var nrctaav2 = normalizaNumero($('#nrctaav2', '#divDadosAvalistas').val());
    var nrcpfav2 = normalizaNumero($('#nrcpfav2', '#divDadosAvalistas').val());
	
    $("#ant_nrctaav1", "#divDadosAvalistas").val(nrctaav1);
    $("#ant_nrcpfav1", "#divDadosAvalistas").val(nrcpfav1);
    $("#ant_nrctaav2", "#divDadosAvalistas").val(nrctaav2);
    $("#ant_nrcpfav2", "#divDadosAvalistas").val(nrcpfav2);
    
    carregaAvalista(1);
	carregaAvalista(2);
						
	// Este campo foi para a tela de consultas automatizadas.
	// Colocar "1" somente para validar os dados do Rating
	nrinfcad = (nrinfcad == 0) ? 1 : nrinfcad;
					
	$("#nrgarope").val(nrgarope);	
	$("#nrinfcad").val(nrinfcad);
	$("#nrliquid").val(nrliquid);
	$("#nrpatlvr").val(nrpatlvr);
		
}

function setDadosObservacao(dsobserv) {
	$("#dsobserv").val(dsobserv);
    $('#dsobserv', '#' + nomeForm + ' .fsObservacoes').val(dsobserv);
}

function changeAbaPropLabel(dslababa) {
	$("a[name=N]").text(dslababa);
}

function trataObservacao(cddopcao) {

    var cTodosObservacao = $("input, select, textarea", "#divDadosObservacoes");
	
	// Se nao for Inclusao ou alteracao, desabilitar os campos
	if (cddopcao != 'N') {
		cTodosObservacao.desabilitaCampo();
	}
	
}

function efetuar_consultas() {

	var cddopcao = (flgProposta == 1) ? 'A' : 'I';
				
	showMsgAguardo('Aguarde, efetuando consultas ...');
				
	$.ajax({
        type: 'POST',
        url: UrlSite + 'includes/consultas_automatizadas/efetuar_consultas.php',
        data: {
            nrdconta: nrdconta,
            nrdocmto: nrctrrat,
            inprodut: 3, // Cheque especial
            cddopcao: cddopcao,
            insolici: 1,
            redirect: 'script_ajax'
		  },
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
		},
        success: function (response) {
			hideMsgAguardo();				
			eval(response);
			return false;
		}
	});
	return false;
}

// Function para controlar as telas das consultas automatizadas
function controlaOperacao(operacao) {

    var nrctrlim = $("#nrctrlim", "#frmNovoLimite").val();
    var iddoaval_busca = 0;
	var inpessoa_busca = 0;
	var nrdconta_busca = 0;
	var nrcpfcgc_busca = 0;
	var inconcje = 0;

    if (inpessoa == 1) {
        inconcje = $("#inconcje_1", "#divDadosRenda").prop('checked') ? 1 : 0;
	}

	switch (operacao) {
	
		case 'A_INICIO':
		case 'C_INICIO': 
		case 'I_INICIO': {
			idSocio = 0;
            lcrShowHideDiv('divDadosRating', 'frmOrgaos');
			return false;
		}
	
		case 'I_PROTECAO_TIT': {
			idSocio = 0;
		}
	
		case 'A_PROTECAO_TIT': {
			idSocio = 0;
			inpessoa_busca = inpessoa;
			nrdconta_busca = nrdconta;
			nrcpfcgc_busca = 0;	
			break;
		}
	
		case 'C_PROTECAO_TIT': {
			idSocio = 0;
			inpessoa_busca = inpessoa;
			nrdconta_busca = nrdconta;
			nrcpfcgc_busca = 0;
			break;
		}
		
		case 'A_PROTECAO_SOC':
		case 'C_PROTECAO_SOC': {
			idSocio = idSocio + 1;
			inpessoa_busca = inpessoa;
			nrdconta_busca = nrdconta;
			nrcpfcgc_busca = 0;
			break;
		}
		
		case 'A_PROTECAO_AVAL':
		case 'C_PROTECAO_AVAL': {  // Aval 1
			iddoaval_busca = 1;
			idSocio = 0;
            inpessoa_busca = $("#inpesso1", "#divDadosAvalistas").val();
            nrdconta_busca = normalizaNumero($("#nrctaav1", "#divDadosAvalistas").val());
            nrcpfcgc_busca = normalizaNumero($("#nrcpfav1", "#divDadosAvalistas").val());
			
            var ant_nrctaav1 = normalizaNumero($("#ant_nrctaav1", "#divDadosAvalistas").val());
            var ant_nrcpfav1 = normalizaNumero($("#ant_nrcpfav1", "#divDadosAvalistas").val());
			 
			// Se nao tem avalista 1, ou se mudaram os dados do aval 1, vai para o proximo 
            if ((nrdconta_busca == 0 && nrcpfcgc_busca == 0) ||
			     (nrdconta_busca != ant_nrctaav1) ||
  				 (nrcpfcgc_busca != ant_nrcpfav1)) {
                controlaOperacao(operacao.substr(0, 2) + "DADOS_AVAL");
				return false;
			}
			
			break;
		}
		
		case 'A_DADOS_AVAL':
		case 'C_DADOS_AVAL': {  // Aval 2
			iddoaval_busca = 2;
            inpessoa_busca = $("#inpesso2", "#divDadosAvalistas").val();
            nrdconta_busca = normalizaNumero($("#nrctaav2", "#divDadosAvalistas").val());
            nrcpfcgc_busca = normalizaNumero($("#nrcpfav2", "#divDadosAvalistas").val());
			
            var ant_nrctaav2 = normalizaNumero($("#ant_nrctaav2", "#divDadosAvalistas").val());
            var ant_nrcpfav2 = normalizaNumero($("#ant_nrcpfav2", "#divDadosAvalistas").val());
						
			// Se nao tem avalista 2, ou se mudaram os dados do aval 2, vai para a proxima tela 
            if ((nrdconta_busca == 0 && nrcpfcgc_busca == 0) ||
			     (nrdconta_busca != ant_nrctaav2) ||
				 (nrcpfcgc_busca != ant_nrcpfav2)) {
				
				if (operacao == 'A_DADOS_AVAL') { // Alteracao
					buscaGrupoEconomico();
				} else {						
					acessaOpcaoAba(8, 0, '@'); // Consulta
				}
				return false;
			}
			
            operacao = operacao.substr(0, 1) + '_PROTECAO_AVAL_2';
			break;
		}	
		
		case 'A_COMITE_APROV': {
            validaItensRating(operacao, true);
			return false;
		}
		
		case 'A_AVAIS': {
			$("#frmOrgaos").remove();	
            $("#divDadosAvalistas").css('display', 'block');
			return false;
		}
		
		case 'C_COMITE_APROV': {
			$("#frmOrgaos").remove();	
            $("#divDadosAvalistas").css('display', 'block');
			return false;
		}	

		case 'A_PROTECAO_CONJ':
			
            if (ant_inconcje == 0) {
				controlaOperacao('A_COMITE_APROV');
				return false;
			} else {
                validaItensRating(operacao, true);
			}
		case 'C_PROTECAO_CONJ': {
			iddoaval_busca = 99;
			inpessoa_busca = 1;
			nrdconta_busca = nrctacje; 
			nrcpfcgc_busca = nrcpfcjg;		
			break;
		}
	
	}
		
	// Esconde div do RATING e AVAIS e remover o das consultas automatizadas
    $("#divDadosRating").css("display", "none");
    $("#divDadosAvalistas").css("display", "none");
	$("#frmOrgaos").remove();
	
	showMsgAguardo('Aguarde, abrindo consultar ...');

	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'includes/consultas_automatizadas/form_orgaos.php',
		data: {
			nrdconta: nrdconta,
			nrdocmto: nrctrlim,
			iddoaval_busca: iddoaval_busca, 
			inpessoa_busca: inpessoa_busca, 
			nrdconta_busca: nrdconta_busca,
			nrcpfcgc_busca: nrcpfcgc_busca,
			operacao: operacao,
			inprodut: 3,
			idSocio: idSocio,  
			inconcje: inconcje, 
			dtcnsspc: dtconbir,
			redirect: 'html_ajax' 
		},
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
		},
        success: function (response) {
		
			hideMsgAguardo();
		
            if (response.indexOf('showError("error"') == -1) {
								
				$('#frmNovoLimite').append(response);
									
				dsinfcad = (operacao == 'I_PROTECAO_TIT') ? "" : dsinfcad;
										
                formata_protecao(operacao, nrinfcad, dsinfcad);

			} else {
                eval(response);
			}
			return false;
		}
	});

}

function controlaSocios(operacao, cdcooper, idSocio, qtSocios) {
				
	if (operacao == "A_PROTECAO_TIT") {
        if ($("#nrinfcad", "#frmOrgaos").val() != undefined) {
            dtconbir = $("#dtcnsspc", "#frmOrgaos").val();
            nrinfcad = $("#nrinfcad", "#frmOrgaos").val();
		}
	}			
				
    if (idSocio > qtSocios) { // Nao tem mais socios, mostrar avais
	
		$("#frmOrgaos").remove();	
        $("#divDadosAvalistas").css('display', 'block');
		
	}
	else { // Proximo socio
        controlaOperacao(operacao.substr(0, 2) + "PROTECAO_SOC");
	}

}

function validaItensRating(operacao, flgarray) {
	
    validaDadosRating(cdcooper, operacao, 3);

}

function confirmaInclusaoMenor(nrdconta, cddopcao, flpropos, inconfir) {

	// Mostra mensagem de aguardo
	showMsgAguardo('Aguarde, carregando...');
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		dataType: "html",
		url: UrlSite + "telas/atenda/limite_credito/novo_limite.php",
		data: {
			nrdconta: nrdconta,
			cddopcao: cddopcao,
			flpropos: flpropos,
			inconfir: inconfir,
			redirect: "html_ajax"
		},		
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			$("#divConteudoOpcao").html(response);
			controlaFoco(cddopcao);
		}				
	});
}

function mostraTelaAltera() {

    showMsgAguardo('Aguarde, abrindo altera&ccedil;&atilde;o...');

    exibeRotina($('#divUsoGenerico'));

    limpaDivGenerica();

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/limite_credito/alterar_novo_limite_form.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $('#divUsoGenerico').html(response);
            layoutPadrao();
            hideMsgAguardo();
            bloqueiaFundo($('#divUsoGenerico'));           
        }
    });
   
    return false;
}


function exibeAlteraNumero() {
    
    showMsgAguardo('Aguarde, abrindo altera&ccedil;&atilde;o...');

    exibeRotina($('#divUsoGenerico'));

    limpaDivGenerica();
    
    /*
    if (situacao_limite != "") {
        showError("error", "&Eacute; poss&iacute;vel alterar apenas contratos nao efetivados.", "Alerta - Ayllos", "fechaRotinaAltera();");
        return false;
    }
    */

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/limite_credito/numero.php',
        data: {
            nrctrpro: nrctrpro,
            redirect: 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "bloqueiaFundo($('#divUsoGenerico'));");
        },
        success: function (response) {
            $('#divUsoGenerico').html(response);
            layoutPadrao();
            hideMsgAguardo();
            bloqueiaFundo($('#divUsoGenerico'));
        }
    });

    return false;
}

function fechaRotinaAltera() {

    fechaRotina($('#divUsoGenerico'), $('#divRotina'));
    acessaOpcaoAba(8, 0, '@'); // Consulta
    return false;

}

function limpaDivGenerica() {

    $('#numero').remove();
    $('#altera').remove();

    return false;
}

function confirmaAlteraNrContrato() {
    showConfirmacao("Alterar n&uacute;mero da proposta?", "Confirma&ccedil;&atilde;o - Ayllos", "AlteraNrContrato();", "$('#new_nrctrlim','#frmNumero').focus();blockBackground(parseInt($('#divUsoGenerico').css('z-index')));", "sim.gif", "nao.gif");
}

// Função para alterar apenas o numero de contrato de limite 
function AlteraNrContrato() {

    showMsgAguardo("Aguarde, alterando n&uacute;mero do contrato ...");

    var nrctrant = $('#nrctrlim', '#frmNumero').val().replace(/\./g, "");
    var nrctrlim = $('#new_nrctrlim', '#frmNumero').val().replace(/\./g, "");

    // Valida número do contrato
    if (nrctrlim == "" || nrctrlim == "0" || !validaNumero(nrctrlim, true, 0, 0)) {
        hideMsgAguardo();
        showError("error", "Numero da proposta deve ser diferente de zero.", "Alerta - Ayllos", "$('#new_nrctrlim','#frmNumero').focus();blockBackground(parseInt($('#divUsoGenerico').css('z-index')));");
        return false;
    }

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/limite_credito/alterar_novo_limite_numero.php",        
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrctrlim: nrctrlim,
            nrctrant: nrctrant,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
        },
        success: function (response) {
            $("#divMsg").html(response);
            layoutPadrao();
            hideMsgAguardo();
            bloqueiaFundo($('#divUsoGenerico'));
        }
    });
}

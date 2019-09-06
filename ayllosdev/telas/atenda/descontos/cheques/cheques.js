/*!
 * FONTE        : cheques.php
 * CRIAÇÃO      : Guilherme
 * DATA CRIAÇÃO : Março/2009
 * OBJETIVO     : Biblioteca de funções da subrotina de Descontos de cheques
 * --------------
 * ALTERAÇÕES   : 11/12/2017
 * --------------
 * 000: [14/06/2010] David     (CECRED) : Adaptação para RATING
 * 000: [21/09/2010] David	   (CECRED) : Ajuste para enviar impressoes via email para o PAC Sede
 * 001: [04/05/2010] Rodolpho     (DB1) : Adaptação para o Zoom Endereço e Avalistas genérico
 * 002: [12/09/2011] Adriano   (CECRED) : Ajuste para Lista Negra
 * 003: [26/06/2012] Jorge	   (CECRED) : Alterado esquema para impressao em gerarImpressao().
 * 004: [21/11/2012] Adirano   (CECRED) : Ajuste referente ao projeto GE.
 * 005: [01/04/2013] Lucas R.  (CECRED) : Ajustes na function controlaLupas.
 * 006: [12/05/2015] Reinert   (CECRED) : Alterado para apresentar mensagem ao realizar inclusao
 *								          de proposta de novo limite de desconto de cheque para
 *									      menores nao emancipados.
 * 007: [20/08/2015] Kelvin    (CECRED) : Ajuste feito para não inserir caracters
 *  								      especiais na observação, conforme solicitado
 *										  no chamado 315453.
 *
 * 008: [17/12/2015] Lunelli   (CECRED) : Edição de número do contrato de limite (Lunelli - SD 360072 [M175])
 * 009: [20/06/2016] Jaison/James (CECRED) : Inicializacao da aux_inconfi6.
 * 010: [18/11/2016] Jaison/James (CECRED) : Reinicializa glb_codigoOperadorLiberacao somente quando pede a senha do coordenador.
 * 011: [22/11/2016] Jaison/James (CECRED) : Zerar glb_codigoOperadorLiberacao antes da cdopcolb.
 * 012: [06/09/2016] Lombardi  (CECRED) : Inclusao do botão "Renovação" para renovação do limite de desconto de cheque. Projeto 300.
 * 013: [09/09/2016] Lombardi  (CECRED) : Inclusao do botão "Desbloquear Inclusao de Bordero" para desbloquear inclusao de desconto de cheque. Projeto 300.
 * 014: [12/09/2016] Lombardi  (CECRED) : Inclusao do botão "Confirmar Novo Limite" para confirmar o novo limite que esta em estudo(Antiga LANCDC). Projeto 300.
 * 015: [16/12/2016] Reinert   (CECRED) : Alterações referentes ao projeto 300.
 * 016: [26/05/2017] Odirlei   (AMcom)  : Alterado para tipo de impressao 10 - Analise bordero.
 *                                        Desabilitado o campo nrctrlim na inclusao de limite. - PRJ300 - Desconto de cheque
 * 017: [31/05/2017] Odirlei   (AMcom)  : Ajuste para verificar se possui cheque custodiado no dia de hoje. - PRJ300 - Desconto de cheque 
 * 018: [26/06/2017] Jonata     (RKAM)  : Ajuste para rotina ser chamada através da tela ATENDA > Produtos - P364. 
 * 019: [21/07/2017] Lombardi  (CECRED) : Ajuste no cadastro de emitentes. - PRJ300 - Desconto de cheque 
 * 020: [11/12/2017] Augusto / Marcos (Supero) : P404 - Inclusão de Garantia de Cobertura das Operações de Crédito
 * 021: [06/02/2018] Mateus Z  (Mouts)  : Alterações referentes ao projeto 454.1 - Resgate de cheque em custodia.
 * 022: [16/04/2018] Lombardi  (CECRED) : Adicionado parametro vlcompcr no ajax da function verificarEmitentes. PRJ366
 * 023: [04/06/2019] Mateus Z  (Mouts) : Alteração para chamar tela de autorização quando alterar valor. PRJ 470 - SM2
 * 024: [08/07/2019] Mateus Z  (Mouts) : Alterações referente ao PRJ 438 - Sprint 14 - Reformulação do Desconto de Cheques.
 * 025: [17/07/2019] Paulo Martins  (Mouts) : Alterações referente ao PRJ 438 - Sprint 16 
 */

var contWin    = 0;  // Variável para contagem do número de janelas abertas para impressos
var nrcontrato = ""; // Variável para armazenar número do contrato de descto selecionado
var nrbordero = ""; // Variável para armazenar número do bordero de descto selecionado
var nrdolote = ""; // Variável para armazenar número do lote de descto selecionado
var flgrejei = 0; // Variável para armazenar se o descto selecionado está rejeitado
var flcusthj = 0;    // Variável para armazenar se o bordero possui cheques custodiados no dia de hoje
var flresghj = 0;    // Variável para armazenar se deseja resgatar os cheques custodiados no dia de hoje
var situacao_limite = ""; // Variável para armazenar a situação do limite atualmente selecionado
var cd_situacao_lim = 0; // Variável para armazenar o código da situação do limite atualmente selecionado
var valor_limite = 0; // Variável para armazenar o valor limite do limite atualmente selecionado
var idcobope = 0; // Variável para armazenar o id da cobertura da garantia da operação
var idLinhaB   = 0;  // Variável para armazanar o id da linha que contém o bordero selecionado
var idLinhaL   = 0;  // Variável para armazanar o id da linha que contém o limite selecionado
var dtrating   = 0;  // Data rating (é calculada e alimentada no cheques_limite_incluir.php)
var diaratin   = 0;  // Dia do rating da tabela tt-risco (é alimentada no cheques_limite_incluir.php)
var vlrrisco   = 0;  // Valor do risco (é alimentada no cheques_limite_incluir.php)

// ALTERAÇÃO 001: Criação de variáveis globais
var nomeForm    	= 'frmDadosLimiteDscChq'; 	// Variável para guardar o nome do formulário corrente
var boAvalista  	= 'b1wgen0028.p'; 			// BO para esta rotina
var procAvalista 	= 'carrega_avalista'; 		// Nome da procedures que busca os avalistas
var operacao		= '' 						// Operação corrente

var strHTML 		= ''; // Variável usada na criação da div de alerta do grupo economico.
var strHTML2 		= ''; // Variável usada na criação do form onde serão mostradas as mensagens de alerta do grupo economico.
var dsmetodo   		= ''; // Variável usada para manipular o método a ser executado na função encerraMsgsGrupoEconomico.

var aux_cddopcao = "";

var aux_inconfir = ""; /*Variável usada para controlar validações que serão realizadas dentro das ptocedures valida_proposta, efetua_liber_anali_bordero.*/
var aux_inconfi2 = ""; /*Variável usada para controlar validações que serão realizadas dentro das ptocedures valida_proposta, efetua_liber_anali_bordero.*/
var aux_inconfi3 = ""; /*Variável usada para controlar validações que serão realizadas dentro das ptocedures valida_proposta, efetua_liber_anali_bordero.*/
var aux_inconfi4 = ""; /*Variável usada para controlar validações que serão realizadas dentro das ptocedures valida_proposta, efetua_liber_anali_bordero.*/
var aux_inconfi5 = ""; /*Variável usada para controlar validações que serão realizadas dentro das ptocedures valida_proposta, efetua_liber_anali_bordero.*/
var aux_inconfi6 = ""; /*Variável usada para controlar validações que serão realizadas dentro das ptocedures valida_proposta, efetua_liber_anali_bordero.*/

var cNrcpfcnpj = [];
var cDsemiten = [];
var ChqsRemovidos = [];

// Pj470 - SM2 -- Mateus Zimmermann -- Mouts
var aux_vllimite_anterior = 0;
// Fim Pj470 - SM2

$.getScript(UrlSite + "telas/atenda/descontos/cheques/js/tela_avalistas.js");

//bruno - prj 470 - tela autorizacao
$.getScript(UrlSite + 'includes/autorizacao_contrato/autorizacao_contrato.js');

// BORDEROS DE DESCONTO DE CHEQUES
// Mostrar o <div> com os borderos de desconto de cheques
function carregaBorderosCheques() {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando border&ocirc;s de desconto de cheques ...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/atenda/descontos/cheques/cheques_bordero.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			executandoProdutos: executandoProdutos,
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divOpcoesDaOpcao2").html(response);
		}
	});
}

// Função para seleção do bordero
function selecionaBorderoCheques(id,qtBorderos,bordero,contrato,nrdolote, rejeitado, custodiado_hj) {
	var cor = "";

	// Formata cor da linha da tabela que lista os borderos de descto cheques
	for (var i = 1; i <= qtBorderos; i++) {
		if (cor == "#F4F3F0") {
			cor = "#FFFFFF";
		} else {
			cor = "#F4F3F0";
		}

		// Formata cor da linha
		$("#trBordero" + i).css("background-color",cor);

		if (i == id) {
			// Atribui cor de destaque para bordero selecionado
			$("#trBordero" + id).css("background-color","#FFB9AB");

			// Armazena número do bordero selecionado
			nrbordero  = retiraCaracteres(bordero,"0123456789",true);
			nrcontrato = retiraCaracteres(contrato,"0123456789",true);
			nrdolote   = retiraCaracteres(nrdolote,"0123456789",true);
      flgrejei   = rejeitado;
            flcusthj  = custodiado_hj; // Possui cheques custodiados no dia de hoje
			idLinhaB   = id;
		}

	}
}

// OPÇÕES CONSULTA/EXCLUSÃO/IMPRIMIR/LIBERAÇÃO/ANÁLISE
// Mostrar dados do border&ocirc; para fazer
function mostraDadosBorderoDscChq(opcaomostra) {

	if (nrbordero == 0 || nrbordero == '' || nrbordero === undefined) {
		hideMsgAguardo();
		showError("error","Nenhum border&ocirc; selecionado.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}

	if (opcaomostra == 'E' && flgrejei == 1) {
    hideMsgAguardo();
		showError("error","Opera&ccedil;&atilde;o n&atilde;o permitida. Border&ocirc; rejeitado.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando dados do border&ocirc; ...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/atenda/descontos/cheques/cheques_bordero_carregadados.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			cddopcao: opcaomostra,
			nrborder: nrbordero,
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divOpcoesDaOpcao3").html(response);
		}
	});
}

function abrirTelaGAROPC(cddopcao) {

    showMsgAguardo('Aguarde, carregando ...');

    var idcobert = normalizaNumero($('#idcobert','#'+nomeForm).val());
    var codlinha = normalizaNumero($('#cddlinha','#'+nomeForm).val());
    var vlropera = $('#vllimite','#'+nomeForm).val();
    
    var nrctrlim = '';
    // Se estamos consultando e está em estudo ou se iremos incluir ou se iremos alterar o limite enviaremos o codigo do contrato ativo
    if ( (cddopcao == 'C' && cd_situacao_lim == 1) || cddopcao == 'I' || cddopcao == 'A') {
      nrctrlim = normalizaNumero($('#nrcontratoativo').val());
    }
    
    // Se estivermos alterando, porém não houver cobertura é por que estamos alterando algo antigo (devemos criar um novo para estes casos)
    if (cddopcao == 'A' && idcobert == '') {
      cddopcao = 'I';
    }
  

    // Carrega conteúdo da opção através do Ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/garopc/garopc.php',
        data: {
            tipaber      : cddopcao,
            idcobert     : idcobert,
            nrdconta     : nrdconta,
            tpctrato     : 2,
            dsctrliq     : nrctrlim,
            codlinha     : codlinha,
            vlropera     : vlropera
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
        },
        success: function (response) {
            hideMsgAguardo();
            // Criaremos uma div oculta para conter toda a estrutura da tela GAROPC
            $('#divUsoGAROPC').html(response).hide();
            // Iremos incluir o conteúdo do form da div oculta dentro da div principal de descontos
            $("#frmGAROPC", "#divUsoGAROPC").appendTo('#divFormGAROPC');
            // Iremos remover os botões originais da GAROPC e usar os proprios da tela
            $("#divBotoes","#frmGAROPC").detach();
            dscShowHideDiv("divFormGAROPC;divBotoesGAROPC","divDscChq_Limite;divBotoesLimite");
            bloqueiaFundo($('#divFormGAROPC'));
            $("#frmDadosLimiteDscChq").css("width", 540);
        }
    });
}

// OPÇÃO CONSULTAR
// Mostrar cheques do bordero
function carregaChequesBorderoDscChq() {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando cheques do border&ocirc; ...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/atenda/descontos/cheques/cheques_bordero_consultar_visualizacheques.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			nrborder: nrbordero,
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divOpcoesDaOpcao4").html(response);
		}
	});
}

//Valida exclusao bordero de cheque
function ValidExcluirBorderoDscChq() {
    // Se possuir cheques custodiados no dia de hoje
    // verificar se deseja resgatar estes cheques
	if (flcusthj == 1){
        confirmaResgateCustodiahj('excluirBorderoDscChq();','E');
    }else{
        excluirBorderoDscChq();
    }
       
}


// OPÇÃO EXCLUIR
// Função para excluir um bordero de desconto de cheques
function excluirBorderoDscChq() {

	if (flgrejei == 1) {
    hideMsgAguardo();
		showError("error","Opera&ccedil;&atilde;o n&atilde;o permitida. Border&ocirc; rejeitado.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}

	// Se não tiver nenhum bordero selecionado
	if (nrbordero == "") {
		return false;
	}

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, excluindo border&ocirc; ...");

	// Executa script de exclusão através de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/atenda/descontos/cheques/cheques_bordero_excluir.php",
		data: {
			nrdconta: nrdconta,
			nrborder: nrbordero,
            flresghj: flresghj,
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

// OPÇÃO IMPRIMIR
// Função para mostrar a opção Imprimir dos borderos de desconto de cheques
function mostraImprimirBordero(){

	if (nrbordero == 0 || nrbordero == '' || nrbordero === undefined) {
		hideMsgAguardo();
		showError("error","Nenhum border&ocirc; selecionado.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando op&ccedil;&atilde;o Imprimir ...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/atenda/descontos/cheques/cheques_bordero_imprimir.php",
		dataType: "html",
		data: {
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divOpcoesDaOpcao3").html(response);
			layoutPadrao();
		}
	});

}

// Função para verificar se deve ser enviado e-mail ao PAC Sede
function verificaEnvioEmail(idimpres,limorbor) {
	showConfirmacao("Efetuar envio de e-mail para Sede?","Confirma&ccedil;&atilde;o - Aimaro","gerarImpressao(" + idimpres + "," + limorbor + ",'yes');","gerarImpressao(" + idimpres + "," + limorbor + ",'no');","sim.gif","nao.gif");
}

// Função para gerar impressão em PDF
function gerarImpressao(idimpres,limorbor,flgemail,fnfinish,flgrestr) {

	if (idimpres == 8) {
		imprimirRating(false,2,nrcontrato,"divOpcoesDaOpcao3",fnfinish);
		return;
	}

	$("#nrdconta","#frmImprimir").val(nrdconta);
	$("#idimpres","#frmImprimir").val(idimpres);
	$("#flgemail","#frmImprimir").val(flgemail);
	$("#flgrestr","#frmImprimir").val(flgrestr);
	$("#nrctrlim","#frmImprimir").val(nrcontrato);
	$("#nrborder","#frmImprimir").val(nrbordero);
	$("#limorbor","#frmImprimir").val(limorbor);

	var action = $("#frmImprimir").attr("action");
	var callafter = "blockBackground(parseInt($('#divRotina').css('z-index')));";

    //incluir no after para carregar os borderos
    if (idimpres == 10) {
       var callafter = callafter + "carregaBorderosCheques();";
    }
    
	
	carregaImpressaoAyllos("frmImprimir",action,callafter);

}

// OPÇÃO LIBERAR
// Liberar/Analisar border&ocirc; de desconto de cheques
function liberaAnalisaBorderoDscChq(opcao,idconfir,idconfi2,idconfi3,idconfi4,idconfi5,idconfi6,indentra,indrestr){

    var nrcpfcgc = $("#nrcpfcgc","#frmCabAtenda").val().replace(".","").replace(".","").replace("-","").replace("/","");
    var mensagem = '';
    var cdopcoan = 0;
    var cdopcolb = 0;

    // Reinicializa somente quando pede a senha
    if (idconfi6 == 51) {
        glb_codigoOperadorLiberacao = 0;
    }

	// Mostra mensagem de aguardo
	if (opcao == "N") {
		mensagem = "analisando";
        cdopcoan = glb_codigoOperadorLiberacao;
	} else {
		mensagem = "liberando";
        cdopcolb = glb_codigoOperadorLiberacao;
	}

	showMsgAguardo("Aguarde, "+mensagem+" o border&ocirc; ...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/atenda/descontos/cheques/cheques_bordero_liberaranalisar.php",
		data: {
			nrdconta: nrdconta,
			nrborder: nrbordero,
			cddopcao: opcao,
			inconfir: idconfir,
			inconfi2: idconfi2,
			inconfi3: idconfi3,
			inconfi4: idconfi4,
			inconfi5: idconfi5,
			inconfi6: idconfi6,
			indentra: indentra,
			indrestr: indrestr,
			nrcpfcgc: nrcpfcgc,
            cdopcoan: cdopcoan,
            cdopcolb: cdopcolb,
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

// LIMITES DE DESCONTO DE CHEQUES
// Mostrar o <div> com os limites de desconto de cheques
function carregaLimitesCheques() {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando limites de desconto de cheques ...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/atenda/descontos/cheques/cheques_limite.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			executandoProdutos: executandoProdutos,
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divOpcoesDaOpcao2").html(response);
		}
	});

}

// Função para seleção do limite
function selecionaLimiteCheques(id,qtLimites,limite,dssitlim,insitlim,vllimite,mIdcobope) {
	var cor = "";

	// Formata cor da linha da tabela que lista os limites de descto cheques
	for (var i = 1; i <= qtLimites; i++) {
		if (cor == "#F4F3F0") {
			cor = "#FFFFFF";
		} else {
			cor = "#F4F3F0";
		}

		// Formata cor da linha
		$("#trLimite" + i).css("background-color",cor);

		if (i == id) {
			// Atribui cor de destaque para limite selecionado
			$("#trLimite" + id).css("background-color","#FFB9AB");

			// Armazena número do limite selecionado
			nrcontrato = limite;
			idLinhaL = id;
			situacao_limite = dssitlim;
			cd_situacao_lim = insitlim;
			valor_limite = vllimite;
			idcobope = mIdcobope;
		}
	}
}

// Função para mostrar a opção Imprimir dos limites de desconto de cheques
function mostraImprimirLimite() {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando op&ccedil;&atilde;o Imprimir ...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/atenda/descontos/cheques/cheques_limite_imprimir.php",
		dataType: "html",
		data: {
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divOpcoesDaOpcao3").html(response);
		}
	});
	
}

/**
 * Autor: Bruno Luiz Katzjarowski - Mout's
 * Data: 18/12/2018;
 * bruno - prj 470 - tela autorizacao
 */
function chamarImpressaoChequeLimite(){

	var aux_nrctrato = 0;
	if(operacao == 'I'){
		aux_nrctrato = nrcontrato;
	} else {
		aux_nrctrato = $("#nrctrlim","#frmDadosLimiteDscChq").val().replace(/\./g,"");
	}

	//bruno - prj 470 - tela autorizacao
	var params = {
		nrdconta : nrdconta,
		obrigatoria: 1,
		tpcontrato: 27,
		vlcontrato: $("#vllimite","#frmDadosLimiteDscChq").val().replace(/\./g,""), //vllimite,
		nrcontrato: aux_nrctrato,
		funcaoImpressao: "mostraImprimirLimite();",
		funcaoGeraProtocolo: 'carregaLimitesCheques();'
	};
	mostraTelaAutorizacaoContrato(params);
}

// Função para cancelar um limite de desconto de cheques
function cancelaLimiteDscChq() {
	// Se não tiver nenhum limite selecionado
	if (nrcontrato == "") {
		return false;
	}

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, cancelando limite ...");

	// Executa script de cancelamento através de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/atenda/descontos/cheques/cheques_limite_cancelar.php",
		data: {
			nrdconta: nrdconta,
			nrctrlim: nrcontrato,
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

// Função para excluir um limite de desconto de cheques
function excluirLimiteDscChq() {
	// Se não tiver nenhum limite selecionado
	if (nrcontrato == "") {
		return false;
	}

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, excluindo limite ...");

	// Executa script de exclusão através de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/atenda/descontos/cheques/cheques_limite_excluir.php",
		data: {
			nrdconta: nrdconta,
			nrctrlim: nrcontrato,
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

// OPÇÃO CONSULTAR
// Carregar os dados para consulta de limite de desconto de cheques
function carregaDadosConsultaLimiteDscChq(cddopcao) {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando dados de desconto de cheques ...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/atenda/descontos/cheques/cheques_limite_consultar.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			nrctrlim: nrcontrato,
			cddopcao: cddopcao,
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divOpcoesDaOpcao3").html(response);
			preencherDemonstracao();
		}
	});

}

// OPÇÃO INCLUIR
// Carregar os dados para inclusão de limite de cheques
function carregaDadosInclusaoLimiteDscChq(inconfir) {

	showMsgAguardo("Aguarde, carregando dados de desconto de cheques ...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/atenda/descontos/cheques/cheques_limite_incluir.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			inconfir: inconfir,
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divOpcoesDaOpcao3").html(response);
			$("#divConteudoOpcao").css('display','none');
			controlaLupas();
		}
	});

}

function abrirTelaDemoDescontoCheque(abrir){
    if(typeof abrir == 'undefined'){
        abrir = false;
    }
    if(abrir){
		$("#frmDadosLimiteDscChq").css("width", 525);
		dscShowHideDiv("divDscChq_Demonstracao;divBotoesDemo","divDscChq_Avalistas;divBotoesAval");
		preencherDemonstracao();
    }else{
		$("#frmDadosLimiteDscChq").css("width", 515);
		dscShowHideDiv("divDscChq_Avalistas;divBotoesAval","divDscChq_Demonstracao;divBotoesDemo");
    }
}
// OPÇÃO ALTERAR
function mostraTelaAltera() {

    showMsgAguardo('Aguarde, abrindo altera&ccedil;&atilde;o...');
	$('#divUsoGenerico').html('');
    exibeRotina($('#divUsoGenerico'));

    if (situacao_limite != "EM ESTUDO") {
        showError("error", "N&atilde;o &eacute; poss&iacute;vel alterar contrato. Situa&ccedil;&atilde;o do limite DEVE estar em ESTUDO.", "Alerta - Aimaro", "fechaRotinaAltera();");
        return false;
    }

    limpaDivGenerica();

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/descontos/cheques/cheques_limite_alterar_form.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Aimaro', "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $('#divUsoGenerico').html(response);
            layoutPadrao();
            hideMsgAguardo();
            bloqueiaFundo($('#divUsoGenerico'));
        }
    });

    $('#todaProp', '#frmAltera').focus();
    return false;
}

function exibeAlteraNumero() {

    showMsgAguardo('Aguarde, abrindo altera&ccedil;&atilde;o...');

    exibeRotina($('#divUsoGenerico'));

    limpaDivGenerica();

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/descontos/cheques/numero.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Aimaro', "bloqueiaFundo($('#divUsoGenerico'));");
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
    carregaLimitesCheques();
    return false;

}

function limpaDivGenerica() {

    $('#numero').remove();
    $('#altera').remove();

    return false;
}

function confirmaAlteraNrContrato() {
    showConfirmacao("Alterar n&uacute;mero da proposta?", "Confirma&ccedil;&atilde;o - Aimaro", "AlteraNrContrato();", "$('#new_nrctrlim','#frmNumero').focus();blockBackground(parseInt($('#divUsoGenerico').css('z-index')));", "sim.gif", "nao.gif");
}

// Função para alterar apenas o numero de contrato de limite
function AlteraNrContrato() {

    showMsgAguardo("Aguarde, alterando n&uacute;mero do contrato ...");

    var nrctrant = $('#nrctrlim', '#frmNumero').val().replace(/\./g, "");
    var nrctrlim = $('#new_nrctrlim', '#frmNumero').val().replace(/\./g, "");

    // Valida número do contrato
    if (nrctrlim == "" || nrctrlim == "0" || !validaNumero(nrctrlim, true, 0, 0)) {
        hideMsgAguardo();
        showError("error", "Numero da proposta deve ser diferente de zero.", "Alerta - Aimaro", "$('#new_nrctrlim','#frmNumero').focus();blockBackground(parseInt($('#divUsoGenerico').css('z-index')));");
        return false;
    }

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/descontos/cheques/cheques_limite_alterar_numero.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrctrlim: nrctrlim,
            nrctrant: nrctrant,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
        },
        success: function (response) {
            $("#divOpcoesDaOpcao3").html(response);
            layoutPadrao();
            hideMsgAguardo();
            bloqueiaFundo($('#divUsoGenerico'));
        }
    });
}

// Carregar os dados para consulta de limite de desconto de cheques
function carregaDadosAlteraLimiteDscChq() {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando dados de desconto de cheques ...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/atenda/descontos/cheques/cheques_limite_alterar.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			nrctrlim: nrcontrato,
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divOpcoesDaOpcao3").html(response);
			controlaLupas();
		}
	});

}

// Função para gravar dados do limite de desconto de cheques
function gravaLimiteDscChq(cddopcao) {


	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, efetuando " + (cddopcao == "A" ? "altera&ccedil;&atilde;o" : "inclus&atilde;o") + " do limite ...");
	var nrcpfcgc = $("#nrcpfcgc","#frmCabAtenda").val().replace(".","").replace(".","").replace("-","").replace("/","");
	// PRJ 438 - Sprint 7 - Função com a atribuição das variaveis dos avalistas
    geraRegsDinamicosAvalistas();
    var nrctaav1 = (typeof aux_nrctaav0 == 'undefined') ? 0  : aux_nrctaav0;
    var nmdaval1 = (typeof aux_nmdaval0 == 'undefined') ? '' : aux_nmdaval0;
	var nrcpfav1 = (typeof aux_nrcpfav0 == 'undefined') ? '' : aux_nrcpfav0;
	var tpdocav1 = (typeof aux_tpdocav0 == 'undefined') ? '' : aux_tpdocav0;
	var dsdocav1 = (typeof aux_dsdocav0 == 'undefined') ? '' : aux_dsdocav0;
	var nmdcjav1 = (typeof aux_nmdcjav0 == 'undefined') ? '' : aux_nmdcjav0;
	var cpfcjav1 = (typeof aux_cpfcjav0 == 'undefined') ? '' : aux_cpfcjav0;
	var tdccjav1 = (typeof aux_tdccjav0 == 'undefined') ? '' : aux_tdccjav0;
	var doccjav1 = (typeof aux_doccjav0 == 'undefined') ? '' : aux_doccjav0;
	var ende1av1 = (typeof aux_ende1av0 == 'undefined') ? '' : aux_ende1av0;
	var ende2av1 = (typeof aux_ende2av0 == 'undefined') ? '' : aux_ende2av0;
	var nrfonav1 = (typeof aux_nrfonav0 == 'undefined') ? '' : aux_nrfonav0;
	var emailav1 = (typeof aux_emailav0 == 'undefined') ? '' : aux_emailav0;
	var nmcidav1 = (typeof aux_nmcidav0 == 'undefined') ? '' : aux_nmcidav0;
	var cdufava1 = (typeof aux_cdufava0 == 'undefined') ? '' : aux_cdufava0;
	var nrcepav1 = (typeof aux_nrcepav0 == 'undefined') ? '' : aux_nrcepav0;
	var cdnacio1 = (typeof aux_cdnacio0 == 'undefined') ? '' : aux_cdnacio0;
	var vledvmt1 = (typeof aux_vledvmt0 == 'undefined') ? '' : aux_vledvmt0;
	var vlrenme1 = (typeof aux_vlrenme0 == 'undefined') ? '' : aux_vlrenme0;
	var nrender1 = (typeof aux_nrender0 == 'undefined') ? '' : aux_nrender0;
	var complen1 = (typeof aux_complen0 == 'undefined') ? '' : aux_complen0;
	var nrcxaps1 = (typeof aux_nrcxaps0 == 'undefined') ? '' : aux_nrcxaps0;
	var inpesso1 = (typeof aux_inpesso0 == 'undefined') ? '' : aux_inpesso0;
	var dtnasct1 = (typeof aux_dtnasct0 == 'undefined') ? '' : aux_dtnasct0;
	var vlrecjg1 = (typeof aux_vlrencj0 == 'undefined') ? '' : aux_vlrencj0;
	var nrctaav2 = (typeof aux_nrctaav1 == 'undefined') ? 0  : aux_nrctaav1;
	var nmdaval2 = (typeof aux_nmdaval1 == 'undefined') ? '' : aux_nmdaval1;
	var nrcpfav2 = (typeof aux_nrcpfav1 == 'undefined') ? '' : aux_nrcpfav1;
	var tpdocav2 = (typeof aux_tpdocav1 == 'undefined') ? '' : aux_tpdocav1;
	var dsdocav2 = (typeof aux_dsdocav1 == 'undefined') ? '' : aux_dsdocav1;
	var nmdcjav2 = (typeof aux_nmdcjav1 == 'undefined') ? '' : aux_nmdcjav1;
	var cpfcjav2 = (typeof aux_cpfcjav1 == 'undefined') ? '' : aux_cpfcjav1;
	var tdccjav2 = (typeof aux_tdccjav1 == 'undefined') ? '' : aux_tdccjav1;
	var doccjav2 = (typeof aux_doccjav1 == 'undefined') ? '' : aux_doccjav1;
	var ende1av2 = (typeof aux_ende1av1 == 'undefined') ? '' : aux_ende1av1;
	var ende2av2 = (typeof aux_ende2av1 == 'undefined') ? '' : aux_ende2av1;
	var nrfonav2 = (typeof aux_nrfonav1 == 'undefined') ? '' : aux_nrfonav1;
	var emailav2 = (typeof aux_emailav1 == 'undefined') ? '' : aux_emailav1;
	var nmcidav2 = (typeof aux_nmcidav1 == 'undefined') ? '' : aux_nmcidav1;
	var cdufava2 = (typeof aux_cdufava1 == 'undefined') ? '' : aux_cdufava1;
	var nrcepav2 = (typeof aux_nrcepav1 == 'undefined') ? '' : aux_nrcepav1;
	var cdnacio2 = (typeof aux_cdnacio1 == 'undefined') ? '' : aux_cdnacio1;
	var vledvmt2 = (typeof aux_vledvmt1 == 'undefined') ? '' : aux_vledvmt1;
	var vlrenme2 = (typeof aux_vlrenme1 == 'undefined') ? '' : aux_vlrenme1;
	var nrender2 = (typeof aux_nrender1 == 'undefined') ? '' : aux_nrender1;
	var complen2 = (typeof aux_complen1 == 'undefined') ? '' : aux_complen1;
	var nrcxaps2 = (typeof aux_nrcxaps1 == 'undefined') ? '' : aux_nrcxaps1;
	var inpesso2 = (typeof aux_inpesso1 == 'undefined') ? '' : aux_inpesso1;
    var dtnasct2 = (typeof aux_dtnasct1 == 'undefined') ? '' : aux_dtnasct1;
	var vlrecjg2 = (typeof aux_vlrecjg1 == 'undefined') ? '' : aux_vlrecjg1;
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/atenda/descontos/cheques/cheques_limite_grava_proposta.php",
		data: {
			nrdconta: nrdconta,
			cddopcao: cddopcao,
			nrcpfcgc: nrcpfcgc,

			nrctrlim: $("#nrctrlim","#frmDadosLimiteDscChq").val().replace(/\./g,""),
			vllimite: $("#vllimite","#frmDadosLimiteDscChq").val().replace(/\./g,""),
			dsramati: $("#dsramati","#frmDadosLimiteDscChq").val(),
            vlmedtit: $("#vlmedtit","#frmDadosLimiteDscChq").val().replace(/\./g,""),
			vlfatura: $("#vlfatura","#frmDadosLimiteDscChq").val().replace(/\./g,""),
			cddlinha: $("#cddlinha","#frmDadosLimiteDscChq").val(),
			dsobserv: removeCaracteresInvalidos(removeAcentos($("#dsobserv","#frmDadosLimiteDscChq").val())),
			qtdiavig: $("#qtdiavig","#frmDadosLimiteDscChq").val().replace(/dias/,""),

			// 1o. Avalista
			nrctaav1: normalizaNumero(nrctaav1),
			nmdaval1: nmdaval1,
			nrcpfav1: normalizaNumero(nrcpfav1),
			tpdocav1: tpdocav1,
			dsdocav1: dsdocav1,
			nmdcjav1: nmdcjav1,
			cpfcjav1: normalizaNumero(cpfcjav1),
			tdccjav1: tdccjav1,
			doccjav1: doccjav1,
			ende1av1: ende1av1,
			ende2av1: ende2av1,
			nrcepav1: normalizaNumero(nrcepav1),
			nmcidav1: nmcidav1,
			cdufava1: cdufava1,
			nrfonav1: nrfonav1,
			emailav1: emailav1,
			nrender1: normalizaNumero(nrender1),
			complen1: complen1,
			nrcxaps1: normalizaNumero(nrcxaps1),
			vlrenme1: vlrenme1,
            vlrecjg1: vlrecjg1,
            cdnacio1: cdnacio1,
			inpesso1: inpesso1,
			dtnasct1: dtnasct1,

			// 2o. Avalista
			nrctaav2: normalizaNumero(nrctaav2),
			nmdaval2: nmdaval2,
			nrcpfav2: normalizaNumero(nrcpfav2),
			tpdocav2: tpdocav2,
			dsdocav2: dsdocav2,
			nmdcjav2: nmdcjav2,
			cpfcjav2: normalizaNumero(cpfcjav2),
			tdccjav2: tdccjav2,
			doccjav2: doccjav2,
			ende1av2: ende1av2,
			ende2av2: ende2av2,
			nrcepav2: normalizaNumero(nrcepav2),
			nmcidav2: nmcidav2,
			cdufava2: cdufava2,
			nrfonav2: nrfonav2,
			emailav2: emailav2,
			nrender2: normalizaNumero(nrender2),
			complen2: complen2,
			nrcxaps2: normalizaNumero(nrcxaps2),
			vlrenme2: vlrenme2,
            vlrecjg2: vlrecjg2,
            cdnacio2: cdnacio2,
			inpesso2: inpesso2,
			dtnasct2: dtnasct2,
            idcobope: normalizaNumero($("#idcobert","#frmDadosLimiteDscChq").val()),

			// Variáveis globais alimentadas na função validaDadosRating em rating.js
			nrgarope: nrgarope,
			nrinfcad: nrinfcad,
			nrliquid: nrliquid,
			nrpatlvr: nrpatlvr,
			vltotsfn: vltotsfn,
			perfatcl: perfatcl,
			nrperger: nrperger,


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

// Validar os dados da proposta de limite
function validaLimiteDscChq(cddopcao,idconfir,idconfi2,idconfi5) {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, validando dados do limite ...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/atenda/descontos/cheques/cheques_limite_valida_proposta.php",
		data: {
			nrdconta: nrdconta,
			nrctrlim: $("#nrctrlim","#frmDadosLimiteDscChq").val().replace(/\./g,""),
			cddopcao: cddopcao,
			dtrating: dtrating,
			diaratin: diaratin,
			vlrrisco: vlrrisco,
			vllimite: $("#vllimite","#frmDadosLimiteDscChq").val().replace(/\./g,""),
			cddlinha: $("#cddlinha","#frmDadosLimiteDscChq").val(),
			inconfir: idconfir,
			inconfi2: idconfi2,
			inconfi4: 71,
			inconfi5: idconfi5,
			redirect: "html_ajax"

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

// Função para validar o numero de contrato
function validaNrContrato() {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, validando n&uacute;mero do contrato ...");

    /* Campo para confirmar numero removido	 
	var antnrctr = $("#antnrctr","#frmDadosLimiteDscChq").val().replace(/\./g,"");

	// Valida número do contrato
	if (antnrctr == "" || !validaNumero(antnrctr,true,0,0)) {
		hideMsgAguardo();
		showError("error","Confirme o n&uacute;mero do contrato.","Alerta - Aimaro","$('#antnrctr','#frmDadosLimiteDscChq').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}
	*/
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/atenda/descontos/cheques/cheques_limite_incluir_validaconfirma.php",
		data: {
			nrdconta: nrdconta,
            nrctrlim: $("#nrctrlim","#frmDadosLimiteDscChq").val().replace(/\./g,""),
			nrctaav1: 0,
			nrctaav2: 0,
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

/*!
 * OBJETIVO : Função para validar avalistas
 * ALTERAÇÃO 001: Padronizado o recebimento de valores
 */
function validarAvalistas() {

	showMsgAguardo('Aguarde, validando dados dos avalistas ...');

	var nrctaav1 = normalizaNumero( $('#nrctaav1','#'+nomeForm).val() );
	var nrcpfav1 = normalizaNumero( $('#nrcpfav1','#'+nomeForm).val() );
	var cpfcjav1 = normalizaNumero( $('#cpfcjav1','#'+nomeForm).val() );
	var nrctaav2 = normalizaNumero( $('#nrctaav2','#'+nomeForm).val() );
	var nrcpfav2 = normalizaNumero( $('#nrcpfav2','#'+nomeForm).val() );
	var cpfcjav2 = normalizaNumero( $('#cpfcjav2','#'+nomeForm).val() );

	var nmdaval1 = trim( $('#nmdaval1','#'+nomeForm).val() || '' );
	var ende1av1 = trim( $('#ende1av1','#'+nomeForm).val() || '' );
	var nrcepav1 = normalizaNumero($("#nrcepav1",'#'+nomeForm).val())

	var nmdaval2 = trim( $('#nmdaval2','#'+nomeForm).val() || '' );
	var ende1av2 = trim( $('#ende1av2','#'+nomeForm).val() || '' );
	var nrcepav2 = normalizaNumero($("#nrcepav2",'#'+nomeForm).val());


	$.ajax({
		type: 'POST',
		url: UrlSite + 'telas/atenda/descontos/cheques/cheques_avalistas_validadados.php',
		data: {
			nrdconta: nrdconta,	nrctaav1: nrctaav1,	nmdaval1: nmdaval1,
			nrcpfav1: nrcpfav1, cpfcjav1: cpfcjav1,	ende1av1: ende1av1,
			nrctaav2: nrctaav2,	nmdaval2: nmdaval2, nrcpfav2: nrcpfav2,
			cpfcjav2: cpfcjav2,	ende1av2: ende1av2, cddopcao: operacao,
			nrcepav1: nrcepav1, nrcepav2: nrcepav2, redirect: 'script_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina);');
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. ' + error.message,'Alerta - Aimaro','bloqueiaFundo(divRotina);');
			}
		}
	});
}

function controlaLupas(){

	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas;

	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmDadosLimiteDscChq';

	// Atribui a classe lupa para os links de desabilita todos
	$('a','#'+nomeFormulario).addClass('lupa').css('cursor','auto');

	// Percorrendo todos os links
	$('a','#'+nomeFormulario).each( function(i) {

		if ( !$(this).prev().hasClass('campoTelaSemBorda') ) $(this).css('cursor','pointer');

		$(this).click( function() {
			if ( $(this).prev().hasClass('campoTelaSemBorda') ) {
				return false;
			} else {
				campoAnterior = $(this).prev().attr('name');

				if ( campoAnterior == 'cddlinha' ) {
					bo			= 'b1wgen0009.p';
					procedure	= 'lista-linhas-desc-chq';
					titulo      = 'Linhas de Desconto de Cheque';
					qtReg		= '5';
					filtros 	= 'C&oacutedigo;cddlinha;30px;S;0|Descr;cddlinh2;100px;S;;N;|;txmensal;;;';
					colunas 	= 'Cod.;cddlinha;15%;right|Descr;dsdlinha;65%;left|Taxa;txmensal;20%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,divRotina);
					return false;
				}
			}
		});
	});

	$('#cddlinha','#'+nomeFormulario).unbind('change').bind('change',function() {

		//Adiciona filtro por conta para a Procedure
		var filtrosDesc = 'nrdconta|'+ nrdconta;

		buscaDescricao('b1wgen0009.p','linha-desc-chq','Linhas de Desconto de Cheque',$(this).attr('name'),'cddlinh2',$(this).val(),'dsdlinha',filtrosDesc,nomeFormulario);
		$('#cddlinha', '#divDscChq_Limite').attr('aux', '');
		buscaDescricao('b1wgen0009.p','linha-desc-chq','Linhas de Desconto de Cheque',$(this).attr('name'),'txmensal',$(this).val(),'txmensal',filtrosDesc,nomeFormulario);
		return false;
	});

	$('#cddlinha','#'+nomeFormulario).unbind('keypress').bind('keypress',function(e) {

		if(e.keyCode == 13){

			//Adiciona filtro por conta para a Procedure
			var filtrosDesc = 'nrdconta|'+ nrdconta;

			buscaDescricao('b1wgen0009.p','linha-desc-chq','Linhas de Desconto de Cheque',$(this).attr('name'),'cddlinh2',$(this).val(),'dsdlinha',filtrosDesc,nomeFormulario);
			$('#cddlinha', '#divDscChq_Limite').attr('aux', '');
			buscaDescricao('b1wgen0009.p','linha-desc-chq','Linhas de Desconto de Cheque',$(this).attr('name'),'txmensal',$(this).val(),'txmensal',filtrosDesc,nomeFormulario);

			return false;

		}

	});


	return false;
}


// Função para fechar div com mensagens de alerta
function encerraMsgsGrupoEconomico(){

	// Esconde div
	$("#divMsgsGrupoEconomico").css("visibility","hidden");

	$("#divListaMsgsGrupoEconomico").html("&nbsp;");

	// Esconde div de bloqueio
	unblockBackground();
	blockBackground(parseInt($("#divRotina").css("z-index")));

	eval(dsmetodo);

	return false;

}

function mostraMsgsGrupoEconomico(){


	if(strHTML != ''){

		// Coloca conteúdo HTML no div
		$("#divListaMsgsGrupoEconomico").html(strHTML);
		$("#divMensagem").html(strHTML2);

		// Mostra div
		$("#divMsgsGrupoEconomico").css("visibility","visible");

		exibeRotina($("#divMsgsGrupoEconomico"));

		// Esconde mensagem de aguardo
		hideMsgAguardo();

		// Bloqueia conteúdo que está átras do div de mensagens
		blockBackground(parseInt($("#divMsgsGrupoEconomico").css("z-index")));

	}

	return false;

}

function formataGrupoEconomico(){

	var divRegistro = $('div.divRegistros','#divMsgsGrupoEconomico');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

	divRegistro.css({'height':'140px'});

	$('#divListaMsgsGrupoEconomico').css({'height':'200px'});
	$('#divMensagem').css({'width':'250px'});

	var ordemInicial = new Array();

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';

	tabela.formataTabela( ordemInicial, '', arrayAlinha );

	return false;

}



function buscaGrupoEconomico() {

	showMsgAguardo("Aguarde, verificando grupo econ&ocirc;mico...");

	$.ajax({
		type: 'POST',
		url: UrlSite + 'telas/atenda/descontos/titulos/busca_grupo_economico.php',
		data: {
			nrdconta: nrdconta,
			// PRJ 438 - Sprint 14 - Flag para nao validar o avalista, que já é validado anteriormente (0 não validar / 1 validar)
			flgValidarAvalistas: 0,
			redirect: 'html_ajax'
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

	return false;

}
function removeAcentos(str){
	return str.replace(/[àáâãäå]/g,"a").replace(/[ÀÁÂÃÄÅ]/g,"A").replace(/[ÒÓÔÕÖØ]/g,"O").replace(/[òóôõöø]/g,"o").replace(/[ÈÉÊË]/g,"E").replace(/[èéêë]/g,"e").replace(/[Ç]/g,"C").replace(/[ç]/g,"c").replace(/[ÌÍÎÏ]/g,"I").replace(/[ìíîï]/g,"i").replace(/[ÙÚÛÜ]/g,"U").replace(/[ùúûü]/g,"u").replace(/[ÿ]/g,"y").replace(/[Ñ]/g,"N").replace(/[ñ]/g,"n");
}

function removeCaracteresInvalidos(str){
	return str.replace(/[^A-z0-9\sÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëÇçÌÍÎÏìíîïÙÚÛÜùúûüÿÑñ\!\@\$\%\*\(\)\-\_\=\+\[\]\{\}\?\;\:\.\,\/\>\<]/g,"");
}

function mostraListagemRestricoes(opcao,idconfir,idconfi2,idconfi3,idconfi4,idconfi5,idconfi6,indentra,indrestr) {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando listagem ...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/atenda/descontos/cheques/cheques_restricoes.php",
		dataType: "html",
		data: {
			cddopcao: opcao,
			inconfir: idconfir,
			inconfi2: idconfi2,
			inconfi3: idconfi3,
			inconfi4: idconfi4,
			inconfi5: idconfi5,
			inconfi6: idconfi6,
			indentra: indentra,
			indrestr: indrestr,
			nrdconta: nrdconta,
			nrborder: nrbordero,
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divOpcoesDaOpcao2").html(response);
		}
	});
}

function formataValorLimite() {

	highlightObjFocus( $('#frmReLimite') );

	var Lvllimite = $('label[for="vllimite"]','#frmReLimite');

	var Cvllimite = $('#vllimite','#frmReLimite');
	Cvllimite.css({'width':'90px','text-align':'right'}).setMask("DECIMAL","zzz.zzz.zz9,99","");
	Cvllimite.habilitaCampo();
	Cvllimite.focus();

	Cvllimite.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }
		if ( e.keyCode == 13) {
			renovaValorLimite();
			return false;
		}
	});

	$('#btRenovar').unbind('click').bind('click', function(){
		renovaValorLimite();
		return false;
	});

	return false;
}

function renovaValorLimite() {

	showMsgAguardo('Aguarde, efetuando renovacao...');

	var vllimite = converteNumero($('#vllimite','#frmReLimite').val());
	var nrctrlim = $('#nrctrlim','#frmReLimite').val();

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/atenda/descontos/cheques/cheques_renova_limite.php",
		data: {
			nrdconta: nrdconta,
			vllimite: vllimite,
			nrctrlim: nrctrlim.replace(/[^0-9]/g,''),
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

	return false;
}

function desbloqueiaInclusaoBordero() {

	showMsgAguardo('Aguarde, efetuando desbloqueio...');

	var nrctrlim = $('#nrctrlim','#frmCheques').val();

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/atenda/descontos/cheques/cheques_desbloqueia_bordero.php",
		data: {
			nrdconta: nrdconta,
			nrctrlim: nrctrlim.replace(/\./g,''),
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

	return false;
}

function acessaValorLimite() {

    showMsgAguardo('Aguarde, carregando ...');

	var vllimite = $('#vllimite','#frmCheques').val();
	var nrctrlim = $('#nrctrlim','#frmCheques').val();

    exibeRotina($('#divUsoGenerico'));

	// Carrega conteúdo da opção através do Ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/descontos/cheques/cheques_valor_limite.php',
        data: {
			vllimite: vllimite,
			nrctrlim: nrctrlim,
			redirect: 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
        },
        success: function (response) {
		    $('#divUsoGenerico').html(response);
            layoutPadrao();
            formataValorLimite();
            $('#vllimite','#frmReLimite').desabilitaCampo();
            hideMsgAguardo();
            bloqueiaFundo($('#divUsoGenerico'));
        }
    });

	return false;
}

function confirmaNovoLimite(cddopera) {

	if (cd_situacao_lim != 1)
		return false;

	showMsgAguardo('Aguarde, Confirmando novo Limite...');

	valor_limite = valor_limite.replace(/\./g,"").replace(',', '.');

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/atenda/descontos/cheques/cheques_limite_confirmar_novo_limite.php",
		data: {
			nrdconta: nrdconta,
			vllimite: valor_limite,
			nrctrlim: nrcontrato,
			cddopera: cddopera,
			idcobope: idcobope,
			redirect: "script_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}
	});

	return false;
}

function ultimasAlteracoes() {
    showMsgAguardo("Aguarde, carregando &uacute;ltimas altera&ccedil;&otilde;es ...");
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/descontos/cheques/cheques_historico.php",
        dataType: "html",
        data: {
            nrdconta: nrdconta,
            nrctrlim: 0,
            redirect: "html_ajax"
        },      
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            hideMsgAguardo();        	
            $("#divOpcoesDaOpcao2").html(response);
        }               
    });
    return false;     	
}
function verificaMensagens(mensagem_01,mensagem_02,mensagem_03,mensagem_04,qtctarel,grupo,vlutiliz,vlexcedi) {

	if (mensagem_01 != '')
		showConfirmacao(mensagem_01
					   ,"Confirma&ccedil;&atilde;o - Aimaro"
					   ,"verificaMensagens('','" + mensagem_02 + "','" + mensagem_03 + "','" + mensagem_04 + "','" + qtctarel + "','" + grupo + "','" + vlutiliz + "','" + vlexcedi + "')"
					   ,"telaOperacaoNaoEfetuada()"
					   ,"sim.gif","nao.gif");
	else if (mensagem_02 != '')
		showConfirmacao('<center>' + (mensagem_02 + "<br>Deseja confirmar esta operação?") + '</center>'
					   ,"Confirma&ccedil;&atilde;o - Aimaro"
					   ,"verificaMensagens('','','" + mensagem_03 + "','" + mensagem_04 + "','" + qtctarel + "','" + grupo + "','" + vlutiliz + "','" + vlexcedi + "')"
					   ,"telaOperacaoNaoEfetuada()"
					   ,"sim.gif","nao.gif");
	else if (mensagem_03 != ''){

		exibeRotina($('#divUsoGenerico'));

		limpaDivGenerica();

		// Carrega conteúdo da opção através do Ajax
		$.ajax({
			type: 'POST',
			dataType: 'html',
			url: UrlSite + 'telas/atenda/descontos/cheques/cheques_tabela_grupo.php',
			data: {
			 mensagem_03: mensagem_03,
			 mensagem_04: mensagem_04,
			    nrdconta: nrdconta,
			    qtctarel: qtctarel,
				   grupo: grupo,
			    vlutiliz: vlutiliz,
			    vlexcedi: vlexcedi,
				redirect: 'html_ajax'
			},
			error: function (objAjax, responseError, objExcept) {
				hideMsgAguardo();
				showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
			},
			success: function (response) {
				$('#divUsoGenerico').html(response);
				layoutPadrao();
				formataMensagem03();
				hideMsgAguardo();
				bloqueiaFundo($('#divUsoGenerico'));
			}
		});
	}
	else if (mensagem_04 != '')
		showError("inform",mensagem_04,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')));verificaMensagens('','','','','','','','');");
	else
		confirmaNovoLimite(1);
	return false;

}

function telaOperacaoNaoEfetuada() {
	fechaRotina($('#divUsoGenerico'),'divRotina');
	showError('inform','Opera&ccedil;&atilde;o n&atilde;o efetuada!','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))');
	return false;
}

function formataMensagem03() {

	var Labels = $('label[for="vlutiliz"],label[for="vlexcedi"]','#divGrupoEconomico');

	Labels.css({'width':'120px','height':'22px','float':'left','display':'block'});

	var Inputs = $('input','#divGrupoEconomico');
	Inputs.css({'width':'120px','text-align':'right','float':'left','display':'block'});
	Inputs.desabilitaCampo();

	var divRegistro = $('div.divRegistros','#divGrupoEconomico');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

	divRegistro.css({'height':'100px'});
	divRegistro.css({'width':'250px'});

	var ordemInicial = new Array();
	ordemInicial = [[0,0]];

	var arrayLargura = new Array();
	arrayLargura[0] = '230px';


	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';

	var metodoTabela = '';

	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );

	$('#btnContinuar').unbind('click');

	return false;
}

function converteNumero (numero){
  return numero.replace('.','').replace(',','.');
}

function mostraFormIABordero(cddopcao){

	if (cddopcao == 'I' && $('#hd_insitblq','#frmCheques').val() == 1){
		showError("error","Inclus&atilde;o de novos border&ocirc;s bloqueada.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}

	if (cddopcao == 'I' && $('#hd_perrenov','#frmCheques').val() == 1){
		showError("error","Opera&ccedil;&atilde;o n&atilde;o permitida. Contrato de limite de desconto vencido.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}

  if (cddopcao == 'A' && flgrejei == 1) {
    hideMsgAguardo();
    showError("error","Opera&ccedil;&atilde;o n&atilde;o permitida. Border&ocirc; rejeitado.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
    return false;
  }

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando dados do border&ocirc; ...");

	if (cddopcao == 'I') {
		nrbordero = 0;
	} else if (nrbordero == 0 || nrbordero == '' || nrbordero === undefined) {
		hideMsgAguardo();
		showError("error","Nenhum border&ocirc; selecionado.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}

	if (cddopcao == 'A' && $('#hd_perrenov','#frmCheques').val() == 1){
		showError("error","Opera&ccedil;&atilde;o n&atilde;o permitida. Contrato de limite de desconto vencido.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}

	ChqsRemovidos = new Array();

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/atenda/descontos/cheques/cheques_bordero_ia_form.php",
		dataType: "html",
		data: {
			cddopcao: cddopcao,
			nrdconta: nrdconta,
			nrborder: nrbordero,
			executandoProdutos: executandoProdutos,
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
			return false;
		},
		success: function(response) {
			$("#divOpcoesDaOpcao3").html(response);
			layoutPadrao();
		}
	});
}

function mostraTelaChequesCustodia(nriniseq, nrregist, htmlDivSel){
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, buscando cheques em cust&oacute;dia ...");

	var idLinha;
	var objImg;
	// Carrega conteúdo da opção através de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/atenda/descontos/cheques/cheques_bordero_custodia_selec.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			nrctrlim: nrcontrato,
			nriniseq: nriniseq,
			nrregist: nrregist,
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$('#divOpcoesDaOpcao4').html(response);
			if (htmlDivSel != ''){
				$('#divChequesSelPag').html(htmlDivSel);
			}

			$('#tbChequesSel tbody tr').each(function(){
				idLinha = $(this).attr('id').substring(1);
				if (document.getElementById(idLinha)){
					objImg = $('#'+idLinha).find('td > img');
					objImg.attr('style', 'opacity: 0.4; cursor: default');
				}
			});
			$('#tbChequesBordero tbody tr').each(function(){
				idLinha = $(this).attr('id').substring(1);
				if (document.getElementById(idLinha)){
					objImg = $('#'+idLinha).find('td > img');
					objImg.attr('style', 'opacity: 0.4; cursor: default');
				}
			});
		}
	});
}

function mostraTelaChequesNovos(){
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando tela de novos cheques ...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/atenda/descontos/cheques/cheques_bordero_custodia_novo.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			nrctrlim: normalizaNumero($('#nrctrlim','#frmCheques').val()),
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$('#divOpcoesDaOpcao4').html(response);
		}
	});
}

function adicionaChequeBordero(htmlLinha, idLinha){

	var objImg;
	var imgBtn;
	var qtdLinhas = $('#tbChequesSel tbody tr').length;
	var corLinha  = (qtdLinhas%2 === 0) ? 'corImpar' : 'corPar';
	var idLinhaB  = 'b' + idLinha.substring(1);

	if(!document.getElementById(idLinha) && !document.getElementById(idLinhaB)) {
		$("#tbChequesSel > tbody").append($('<tr>')
										.attr('id', idLinha)
										.attr('class',corLinha)
										.append(htmlLinha)
		);
		objImg = $('#'+idLinha).find('td > img');
		imgBtn = objImg.attr('src');
		imgBtn = imgBtn.replace('servico_ativo', 'servico_nao_ativo');
		objImg.attr('src', imgBtn);
		objImg.attr('title', 'Remover');
		objImg.attr('style', 'cursor: pointer');
		objImg.attr('onclick', 'removeChequeSelecionado(\''+ idLinha + '\');');
	}else{
		//showError("error","Cheque j&aacute; selecionado.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}

	return false;

}

function removeChequeSelecionado(idLinha){

	if (idLinha.charAt(0) == 's'){

		var chequeRemove = document.getElementById(idLinha);
		chequeRemove.parentNode.removeChild(chequeRemove);
		zebraTabelas('tbChequesSel');

		var objImg = $('#'+idLinha.substring(1)).find('td > img');
		objImg.attr('style', 'opacity: 1; cursor: pointer');

	}else{
		var objImg = $('#'+idLinha).find('td > img');
		objImg.attr('style', 'opacity: 0.4; cursor: default');

	}

	return false;
}

function adicionarChqsBordero(intipchq, idTabela){

	var dtlibera, cdcmpchq, cdbanchq, cdagechq, nrctachq,
		nrcheque, nmcheque, nrcpfcgc, vlcheque, dssithcc,
		dsdocmc7, dtdcaptu, dtcustod, flchqbor;

	var x = 0;

	$('#' + idTabela + ' tbody tr').each(function(){
		x = x + 1
	});

	if ( x == 0) {
		showError('error','N&atilde;o foram selecionados cheques.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));');
		return false;
	}

	if (idTabela == 'tbChequesSel'){
		$('#' + idTabela + ' tbody tr').each(function(){
			dtlibera = $(this).find('td:eq(0) > span').text();  // Data Boa
			cdcmpchq = $(this).find('td:eq(1) > span').text();  // Compe
			cdbanchq = $(this).find('td:eq(2) > span').text();  // Banco
			cdagechq = $(this).find('td:eq(3) > span').text();  // Agência
			nrctachq = $(this).find('td:eq(4) > span').text();  // Nr. da Conta do Cheque
			nrcheque = $(this).find('td:eq(5) > span').text();  // Nr. do Cheque
			nmcheque = $(this).find('td:eq(6) > span').text();  // Nome do Emitente
			nrcpfcgc = $(this).find('td:eq(7) > span').text();  // CPF/CNPJ do Emitente
			vlcheque = $(this).find('td:eq(8) > span').text();  // Valor do cheque
			dssithcc = $(this).find('td:eq(9) > span').text();  // Situação
			dsdocmc7 = $("#dsdocmc7",this).val();     			// CMC7
			dtdcaptu = $("#dtdcaptu",this).val();     			// Data de emissão
			dtcustod = $("#dtcustod",this).val();     			// Data custódia
			nrremret = $("#nrremret",this).val();     			// Número da remessa
			flchqbor = 0;

			adicionarChequeBordero(dtlibera, cdcmpchq, cdbanchq, cdagechq, nrctachq, nrcheque, vlcheque, dssithcc, nmcheque, nrcpfcgc, intipchq, dsdocmc7, dtdcaptu, dtcustod, nrremret, flchqbor);

		});
	}else if(idTabela == 'tbChequesNovos'){
		$('#' + idTabela + ' tbody tr').each(function(){
			dtlibera = $("#aux_dtlibera",this).val();     // Data Boa
			cdcmpchq = $("#aux_cdcmpchq",this).val();	  // Compe
			cdbanchq = $("#aux_cdbanchq",this).val();	  // Banco
			cdagechq = $("#aux_cdagechq",this).val();	  // Agência
			nrctachq = $("#aux_nrctachq",this).val();	  // Nr. da Conta do Cheque
			nrcheque = $("#aux_nrcheque",this).val();	  // Nr. do Cheque
			vlcheque = $("#aux_vlcheque",this).val();	  // Valor do cheque
			dssithcc = $("#aux_dssithcc",this).text();	  // Situação
			nmcheque = $("#aux_nmcheque",this).val();     // Nome do Emitente
			nrcpfcgc = $("#aux_nrcpfcgc",this).val();     // CPF/CNPJ do Emitente
			dsdocmc7 = $("#aux_dsdocmc7",this).val();     // CMC7
			dtdcaptu = $("#aux_dtdcaptu",this).val();     // Data de emissão
			dtcustod = ' ';     						  // Data de custódia
			nrremret = 0;
			flchqbor = 0;

			adicionarChequeBordero(dtlibera, cdcmpchq, cdbanchq, cdagechq, nrctachq, nrcheque, vlcheque, dssithcc, nmcheque, nrcpfcgc, intipchq, dsdocmc7, dtdcaptu, dtcustod, nrremret, flchqbor);

		});
	}
	layoutPadrao();
	voltaDiv(4,3,4,'DESCONTO DE CHEQUES');
	blockBackground(parseInt($('#divRotina').css('z-index')))
	return false;
}

function adicionarChequeBordero(dtlibera, cdcmpchq, cdbanchq, cdagechq, nrctachq, nrcheque, vlcheque, dssithcc, nmcheque, nrcpfcgc, intipchq, dsdocmc7, dtdcaptu, dtcustod, nrremret, flchqbor){

	// Criar id único
	var idCriar = 'b'								   +
				  normalizaNumero(cdbanchq).toString() +
				  normalizaNumero(cdagechq).toString() +
				  normalizaNumero(cdcmpchq).toString() +
				  normalizaNumero(nrcheque).toString() +
				  normalizaNumero(nrctachq).toString();

	var cmc7_sem_format = dsdocmc7.replace(/[^0-9]/g, "").substr(0,30);

	var qtdLinhas = $('#tbChequesBordero tbody tr').length;
	var corLinha  = (qtdLinhas%2 === 0) ? 'corImpar' : 'corPar';

	if(!document.getElementById(idCriar)) {

		$('#tbChequesBordero tbody')
			.append($('<tr>') // Linha
					.attr('id',idCriar)
					.attr('class',corLinha)
					.append($('<input>')
							.attr('type','hidden')
							.attr('name','aux_flchqbor')
							.attr('id','aux_flchqbor')
							.attr('value',flchqbor)
					)
					.append($('<input>')
							.attr('type','hidden')
							.attr('name','aux_intipchq')
							.attr('id','aux_intipchq')
							.attr('value',intipchq)
					)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_dsdocmc7')
						.attr('id','aux_dsdocmc7')
						.attr('value',cmc7_sem_format)
					)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_dtdcaptu')
						.attr('id','aux_dtdcaptu')
						.attr('value',dtdcaptu)
					)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_dtcustod')
						.attr('id','aux_dtcustod')
						.attr('value',dtcustod)
					)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_nrremret')
						.attr('id','aux_nrremret')
						.attr('value',nrremret)
					)
					.append($('<td>') // Coluna: Data Boa
						.attr('style','width: 73px; text-align:center')
						.text(dtlibera)
						.append($('<input>')
							.attr('type','hidden')
							.attr('name','aux_dtlibera')
							.attr('id','aux_dtlibera')
							.attr('value',dtlibera)
						)
					)
					.append($('<td>') // Coluna: Cmp
						.attr('style','width: 30px; text-align:right')
						.text(cdcmpchq)
						.append($('<input>')
							.attr('type','hidden')
							.attr('name','aux_cdcmpchq')
							.attr('id','aux_cdcmpchq')
							.attr('value',normalizaNumero(cdcmpchq))
						)
					)
					.append($('<td>') // Coluna: Bco
						.attr('style','width: 30px; text-align:right')
						.text(cdbanchq)
						.append($('<input>')
							.attr('type','hidden')
							.attr('name','aux_cdbanchq')
							.attr('id','aux_cdbanchq')
							.attr('value',normalizaNumero(cdbanchq))
						)
					)
					.append($('<td>') // Coluna: Ag.
						.attr('style','width: 30px; text-align:right')
						.text(cdagechq)
						.append($('<input>')
							.attr('type','hidden')
							.attr('name','aux_cdagechq')
							.attr('id','aux_cdagechq')
							.attr('value',normalizaNumero(cdagechq))
						)
					)
					.append($('<td>') // Coluna: Conta
						.attr('style','width: 69px; text-align:right')
						.text(nrctachq)
						.append($('<input>')
							.attr('type','hidden')
							.attr('name','aux_nrctachq')
							.attr('id','aux_nrctachq')
							.attr('value',normalizaNumero(nrctachq))
						)
					)
					.append($('<td>') // Coluna: Cheque
						.attr('style','width: 59px; text-align:right')
						.text(nrcheque)
						.append($('<input>')
							.attr('type','hidden')
							.attr('name','aux_nrcheque')
							.attr('id','aux_nrcheque')
							.attr('value',normalizaNumero(nrcheque))
						)
					)
					.append($('<td>') // Coluna: Nome
						.attr('style','width: 210px; text-align:left')
						.attr('name','aux_nmcheque_t')
						.attr('id','aux_nmcheque_t')
						.text(nmcheque)
						.append($('<input>')
							.attr('type','hidden')
							.attr('name','aux_nmcheque')
							.attr('id','aux_nmcheque')
							.attr('value',nmcheque)
						)
					)
					.append($('<td>') // Coluna: CPF/CNPJ
						.attr('style','width: 100px; text-align:right')
						.attr('name','aux_nrcpfcgc_t')
						.attr('id','aux_nrcpfcgc_t')
						.text(nrcpfcgc)
						.append($('<input>')
							.attr('type','hidden')
							.attr('name','aux_nrcpfcgc')
							.attr('id','aux_nrcpfcgc')
							.attr('value',normalizaNumero(nrcpfcgc))
						)
					)
					.append($('<td>') // Coluna: Valor
						.attr('style','width: 70px; text-align:right')
						.text(vlcheque)
						.append($('<input>')
							.attr('type','hidden')
							.attr('name','aux_vlcheque')
							.attr('id','aux_vlcheque')
							.attr('value',vlcheque)
						)
					)
					.append($('<td>') // Coluna: Situação
						.attr('style','width: 59px; text-align:center')
						.text(dssithcc)
						.append($('<input>')
							.attr('type','hidden')
							.attr('name','aux_dssitchq')
							.attr('id','aux_dssitchq')
							.attr('value',dssithcc)
						)
					)
					.append($('<td>') // Coluna: Botão para REMOVER
						.attr('style','text-align:center')
						.append($('<img>')
							.attr('src', UrlImagens + 'geral/servico_nao_ativo.gif')
							.attr('width', 16)
							.attr('height', 16)
							.attr('title', 'Remover')
							.attr('style', 'cursor: pointer')
							.click(function(event) {
								controlaChequeBordero(idCriar);
								atualizaValoresBordero();
								armazenaChequesRemovidos(flchqbor, dtlibera, cmc7_sem_format);
								return false;
							})
						)
					)
				);
		atualizaValoresBordero();
	}

}

function controlaChequeBordero(idLinha){
	var objImg, imgBtn;

	if ($('#'+idLinha).css('text-decoration').match('none')){
		$('#'+idLinha).css('text-decoration','line-through');
		objImg = $('#'+idLinha).find('td > img');
		imgBtn = objImg.attr('src');
		imgBtn = imgBtn.replace('servico_nao_ativo', 'servico_ativo');
		objImg.attr('src', imgBtn);
		objImg.attr('title', 'Adicionar');
	}else{
		$('#'+idLinha).css('text-decoration', 'none');
		objImg = $('#'+idLinha).find('td > img');
		imgBtn = objImg.attr('src');
		imgBtn = imgBtn.replace('servico_ativo', 'servico_nao_ativo');
		objImg.attr('src', imgBtn);
		objImg.attr('title', 'Remover');
	}
}

function zebraTabelas(idTabela){

	var contador = 0;

	$('#' + idTabela + ' tbody tr').each(function(){
		$('#' + idTabela).zebraTabela(contador);
		$(this).removeClass('corSelecao');
		contador += 1;
	});

}

function adicionaChequeGrid(){

	var cDsdocmc7 = $('#dsdocmc7', '#frmChequesCustodiaNovo');
	var cDtlibera = $('#dtlibera', '#frmChequesCustodiaNovo');
	var cDtdcaptu = $('#dtdcaptu', '#frmChequesCustodiaNovo');
	var cVlcheque = $('#vlcheque', '#frmChequesCustodiaNovo');

	var cmc7  = cDsdocmc7.val();
	// Limpa campo
	cDsdocmc7.val('');
	var cmc7_sem_format  = cmc7.replace(/[^0-9]/g, "").substr(0,30);
/*
	if ( cmc7 == '' ) {
		return false;
	}

		// Validar se os campos estão preenchidos
	if ( cDtlibera.val() == '' ) {
		showError('error','Data boa inv&aacute;lida.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\'))); $(\'#dtlibera\', \'#frmChequesCustodiaNovo\').focus();');
		return false;
	}

	if ( cDtdcaptu.val() == '' ) {
		showError('error','Data de emiss&atilde;o inv&aacute;lida.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\'))); $(\'#dtdcaptu\', \'#frmChequesCustodiaNovo\').focus();');
		return false;
	}

	if ( cVlcheque.val() == '' || cVlcheque.val() == '0,00') {
		showError('error','Valor inv&aacute;lido.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\'))); $(\'#vlcheque\', \'#frmChequesCustodiaNovo\').focus();');
		return false;
	}

	if ( cmc7_sem_format.length < 30 ) {
		showError('error','CMC-7 inv&aacute;lido.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\'))); $(\'#dsdocmc7\', \'#frmChequesCustodiaNovo\').focus();');
		return false;
	}

	var aDtlibera = cDtlibera.val().split("/");
	var aDtdcaptu = cDtdcaptu.val().split("/");
	var aDtmvtolt = aux_dtmvtolt.split("/");
	var dtcompara1 = parseInt(aDtlibera[2].toString() + aDtlibera[1].toString() + aDtlibera[0].toString());
	var dtcompara2 = parseInt(aDtdcaptu[2].toString() + aDtdcaptu[1].toString() + aDtdcaptu[0].toString());
	var dtcompara3 = parseInt(aDtmvtolt[2].toString() + aDtmvtolt[1].toString() + aDtmvtolt[0].toString());

	if ( dtcompara1 <= dtcompara3 ) {
		showError('error','A data boa deve ser maior que a data atual.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\'))); $(\'#dtlibera\', \'#frmChequesCustodiaNovo\').focus();');
		return false;
	}

	if ( dtcompara2 > dtcompara3 ) {
		showError('error','A data de emiss&atilde;o deve ser menor que a data atual.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\'))); $(\'#dtdcaptu\', \'#frmChequesCustodiaNovo\').focus();');
		return false;
	}
*/
	var idCriar = "id_".concat(cmc7_sem_format);

	var dtlibera = cDtlibera.val();
	var dtdcaptu = cDtdcaptu.val();
	var vlcheque = cVlcheque.val();
	//Desmontar o CMC-7 para exibir os campos
	var cdbanchq = normalizaNumero(cmc7_sem_format.substr(0,3));
	var cdagechq = normalizaNumero(cmc7_sem_format.substr(3,4));
	var cdcmpchq = normalizaNumero(cmc7_sem_format.substr(8,3));
	var nrcheque = normalizaNumero(cmc7_sem_format.substr(11,6));
	var nrctachq = 0;
	var qtdLinhas = $('#tbChequesNovos tbody tr').length;
	var corLinha  = (qtdLinhas%2 === 0) ? 'corImpar' : 'corPar';

	if( cdbanchq == 1 ){
	    nrctachq = mascara(normalizaNumero(cmc7_sem_format.substr(21,8)),'####.###-#');
	} else {
		nrctachq = mascara(normalizaNumero(cmc7_sem_format.substr(19,10)),'######.###-#');
	}

	if(!document.getElementById(idCriar)) {

		// Criar a linha na tabela
		$("#tbChequesNovos > tbody")
			.append($('<tr>') // Linha
			    .attr('id',idCriar)
				.attr('class',corLinha)
				.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_dsdocmc7')
						.attr('id','aux_dsdocmc7')
						.attr('value',cmc7_sem_format)
				)
				.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_nrcpfcgc')
						.attr('id','aux_nrcpfcgc')
				)
				.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_nmcheque')
						.attr('id','aux_nmcheque')
				)
				.append($('<td>') // Coluna: Data Boa
				    .attr('style','width: 73px; text-align:center')
					.text(dtlibera)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_dtlibera')
						.attr('id','aux_dtlibera')
						.attr('value',dtlibera)
					)
				)
				.append($('<td>') // Coluna: Data Emissão
				    .attr('style','width: 73px; text-align:center')
					.text(dtdcaptu)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_dtdcaptu')
						.attr('id','aux_dtdcaptu')
						.attr('value',dtdcaptu)
					)
				)
				.append($('<td>') // Coluna: Comp
					.attr('style','width: 30px; text-align:right')
					.text(cdcmpchq)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_cdcmpchq')
						.attr('id','aux_cdcmpchq')
						.attr('value',cdcmpchq)
					)
				)
				.append($('<td>') // Coluna: Banco
					.attr('style','width: 30px; text-align:right')
					.text(cdbanchq)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_cdbanchq')
						.attr('id','aux_cdbanchq')
						.attr('value',cdbanchq)
					)
				)
				.append($('<td>')  // Coluna: Agência
					.attr('style','width: 30px; text-align:right')
					.text(cdagechq)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_cdagechq')
						.attr('id','aux_cdagechq')
						.attr('value',cdagechq)
					)
				)
				.append($('<td>') // Coluna: Número da Conta
					.attr('style','width: 84px; text-align:right')
					.text(nrctachq)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_nrctachq')
						.attr('id','aux_nrctachq')
						.attr('value',nrctachq)
					)
				)
				.append($('<td>') // Coluna: Número do Cheque
					.attr('style','width: 59px; text-align:right')
					.text(nrcheque)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_nrcheque')
						.attr('id','aux_nrcheque')
						.attr('value',nrcheque)
					)
				)
				.append($('<td>') // Coluna: Valor
					.attr('style','width: 85px; text-align:right')
					.text(vlcheque)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','aux_vlcheque')
						.attr('id','aux_vlcheque')
						.attr('value',vlcheque)
					)
				)
				.append($('<td>') // Coluna: Situação
					.attr('style','width: 59px; text-align:center')
					.attr('name','aux_dssithcc')
					.attr('id','aux_dssithcc')
					.text('Pendente Entrega')
				)
				.append($('<td>') // Coluna: Crítica
				    .attr('style','width: 140px; text-align:left')
					.attr('name','aux_dscritic')
					.attr('id','aux_dscritic')
					.text('')
				)
				.append($('<td>') // Coluna: Botão para REMOVER
					.attr('style','text-align:center')
					.append($('<img>')
						.attr('src', UrlImagens + 'geral/servico_nao_ativo.gif')
						.attr('width', 16)
						.attr('height', 16)
						.attr('title', 'Remover')
						.attr('style', 'cursor: pointer')
						.click(function(event) {

							var chequeRemove = document.getElementById($(this).parent().parent().attr('id'));
							chequeRemove.parentNode.removeChild(chequeRemove);
							zebraTabelas('tbChequesNovos');
							return false;
						})
					)
				)
			);
		novoCheque();
	}
}

function validaNovosCheques(){

	showMsgAguardo('Aguarde, validando cheques ...');

	var dscheque = "";
	var corLinha  = 'corImpar';

	$('#tbChequesNovos tbody tr').each(function(){
		if( dscheque != "" ){
			dscheque += "|";
		}

		dscheque += $("#aux_dtlibera",this).val() + ";" ; // Data Boa
		dscheque += $("#aux_dtdcaptu",this).val() + ";" ; // Data Emissão
		dscheque += $("#aux_vlcheque",this).val().replace(/\./g,'').replace(',','.') + ";" ; // Valor
		dscheque += $("#aux_dsdocmc7",this).val(); // CMC-7

		// Limpar a crítica
		$("#aux_dscritic",this).text('');
		$(this).css('background', '');
		// Adiciona a cor Zebrado na Tabela de Cheques
		$(this).attr('class', corLinha);
		if( corLinha == 'corImpar' ){
			corLinha = 'corPar';
		} else {
			corLinha = 'corImpar';
		}
	});

	if( dscheque == "" ){
		hideMsgAguardo();
		showError('error','Nenhum cheque foi informado.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));');
		return false;
	}else{

		$.ajax({
			type: 'POST',
			dataType: 'html',
			url: UrlSite + 'telas/atenda/descontos/cheques/cheques_bordero_custodia_novo_valida.php',
			data: {
				nrdconta: nrdconta,
				dscheque: dscheque,
				redirect: 'html_ajax'
				},
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));');
			},
			success: function(response) {
				hideMsgAguardo();
				try {
					eval( response );
				} catch(error) {
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));');
				}
			}
		});
	}
}

function novoCheque(){
	var cDsdocmc7 = $('#dsdocmc7', '#frmChequesCustodiaNovo');
	var cDtlibera = $('#dtlibera', '#frmChequesCustodiaNovo');
	var cDtdcaptu = $('#dtdcaptu', '#frmChequesCustodiaNovo');
	var cVlcheque = $('#vlcheque', '#frmChequesCustodiaNovo');
	//Limpa o valor dos campos e seta foco na data
	cDtdcaptu.val('');
	cVlcheque.val('');
	cDsdocmc7.val('');
	cDtlibera.val('').focus();
}

function adicionaEmitente(idCheque, nrcpfcgc, nmcheque){

	$('#aux_nrcpfcgc','#' + idCheque).val(nrcpfcgc);
	$('#aux_nrcpfcgc_t','#' + idCheque).text(nrcpfcgc);
	$('#aux_nmcheque','#' + idCheque).val(nmcheque);
	$('#aux_nmcheque_t','#' + idCheque).text(nmcheque);

}

function atualizaValoresBordero(){

	var qtcompln = 0;
	var vlcompcr = 0;

	$('#tbChequesBordero tbody tr').each(function(){
		if ($(this).css('text-decoration').match('none')){
			qtcompln++;
			vlcompcr += Number($('#aux_vlcheque', this).val().replace('.','').replace(',','.'));
		}
	});
	$('#qtcompln', '#frmBorderosIA').val(qtcompln);
	$('#vlcompcr', '#frmBorderosIA').val(number_format(vlcompcr, 2, ',', '.'));
}

function atualizaValoresBorderoAnalise(){

	var qtcompln = 0;
	var vlcompcr = 0;

	$('#tbChequesBordero tbody tr').each(function(){
		qtcompln++;
		vlcompcr += Number($(this).find('td:eq(8) > span').text().replace('.','').replace(',','.'));
	});
	$('#qtcompln', '#frmBorderosAnalise').val(qtcompln);
	$('#vlcompcr', '#frmBorderosAnalise').val(number_format(vlcompcr, 2, ',', '.'));
}

function armazenaChequesRemovidos(flchqbor, dtlibera, dsdocmc7){

	var idx, dschqrem, flgdispo;
	flgdispo = 1;

	if (flchqbor == 1){
		idx = ChqsRemovidos.length;
		dschqrem  = dtlibera + ';';
		dschqrem += dsdocmc7;
		for (i = 0; i < ChqsRemovidos.length; i++) {

			if( ChqsRemovidos[i] == dschqrem ){
				flgdispo = 0;
				ChqsRemovidos.splice(i, 1);
			}

		}
		if (flgdispo == 1){
			ChqsRemovidos[idx] = dschqrem;
		}
	}

}

function verificarEmitentes(){

	showMsgAguardo('Aguarde, verificando emitentes ...');

	var dscheque = "";
	var corLinha  = 'corImpar';

	$('#tbChequesBordero tbody tr').each(function(){
		if( dscheque != "" ){
			dscheque += "|";
		}

		dscheque += $("#aux_dsdocmc7",this).val(); // CMC-7

	});

	var vlcompcr = $('#vlcompcr', '#frmBorderosIA').val().replace('.','').replace(',','.');
	
	if( dscheque == "" ){
		hideMsgAguardo();
		showError('error','Nenhum cheque foi informado para o border&ocirc;.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));');
		return false;
	}else{

		$.ajax({
			type: 'POST',
			dataType: 'html',
			url: UrlSite + 'telas/atenda/descontos/cheques/cheques_bordero_verifica_emitentes.php',
			data: {
				nrdconta: nrdconta,
				dscheque: dscheque,
				vlcompcr: vlcompcr,
				redirect: 'html_ajax'
				},
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));');
			},
			success: function(response) {
				hideMsgAguardo();
				try {
					eval( response );
				} catch(error) {
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));');
				}
			}
		});
	}
}

function criaEmitente(cdcmpchq, cdbanchq, cdagechq, nrctachq, nrsequen){

	var idCriar = "id_" + cdcmpchq + cdbanchq + cdagechq + nrctachq;

	var qtdLinhas = $('#tabEmiten tbody tr').length;
	var corLinha  = (qtdLinhas%2 === 0) ? 'corImpar' : 'corPar';

	if( cdbanchq == 1 ){
	    nrctachq = mascara(normalizaNumero(nrctachq.toString()),'####.###-#');
	} else {
		nrctachq = mascara(normalizaNumero(nrctachq.toString()),'######.###-#');
	}

	if(!document.getElementById(idCriar)) {

		// Criar a linha na tabela
		$("#tabEmiten > tbody")
			.append($('<tr>') // Linha
			    .attr('id',idCriar)
				.attr('class',corLinha)
				.append($('<td>') // Coluna: Banco
					.attr('style','width: 50px; text-align:right')
					.text(cdbanchq)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','cdbanchq')
						.attr('id','cdbanchq')
						.attr('value',cdbanchq)
					)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','cdcmpchq')
						.attr('id','cdcmpchq')
						.attr('value',cdcmpchq)
					)
				)
				.append($('<td>')  // Coluna: Agência
					.attr('style','width: 50px; text-align:right')
					.text(cdagechq)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','cdagechq')
						.attr('id','cdagechq')
						.attr('value',cdagechq)
					)
				)
				.append($('<td>') // Coluna: Número da Conta
					.attr('style','width: 90px; text-align:right')
					.text(nrctachq)
					.append($('<input>')
						.attr('type','hidden')
						.attr('name','nrctachq')
						.attr('id','nrctachq')
						.attr('value',nrctachq)
					)
				)
				.append($('<td>') // Coluna: CPF/CNPJ
					.attr('style','width: 150px; text-align:center')
					.append($('<input>')
						.attr('type','text')
						.attr('name','nrcpfcnpj')
						.attr('id','nrcpfcnpj' + nrsequen)
						.attr('style', 'width: 140px;')
						.attr('maxlength','18')
						.attr('class', 'campo')
					)

				)
				.append($('<td>') // Coluna: Emitente
					.attr('style','width: 350px; text-align:center')
					.append($('<input>')
						.attr('type','text')
						.attr('name','dsemiten')
						.attr('id','dsemiten' + nrsequen)
						.attr('style', 'width: 340px;')
						.attr('class', 'campo alphanum')
					)
				)
				.append($('<td>') // Coluna: Crítica
				    .attr('style','text-align:left')
					.attr('name','dscritic')
					.attr('id','dscritic')
					.text('')
				)
			);

	}

	highlightObjFocus($('#frmBorderosIA'));
	cNrcpfcnpj[nrsequen] = $('#' + 'nrcpfcnpj' + nrsequen, '#frmBorderosIA');
	cDsemiten[nrsequen] = $('#' + 'dsemiten' + nrsequen, '#frmBorderosIA');
	cDsemiten[nrsequen].attr('maxlength','60').setMask("STRING",60,charPermitido(),"");

	cNrcpfcnpj[nrsequen].unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

		// Se é a tecla TAB ou ENTER,
        if (e.keyCode == 9 || e.keyCode == 13) {
            cDsemiten[nrsequen].focus();
            return false;
        }

		mascaraCpfCnpj(this,cpfCnpj);

   });

	cDsemiten[nrsequen].unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

		// Se é a tecla TAB ou ENTER,
        if (e.keyCode == 9 || e.keyCode == 13) {
			if (cNrcpfcnpj[nrsequen + 1] !== undefined){
				cNrcpfcnpj[nrsequen + 1].focus();
			}else{
				prosseguirManterBordero();
			}
        }
    });

	layoutPadrao();
	return false;
}

function mascaraCpfCnpj(o,f){
    v_obj=o
    v_fun=f
    setTimeout('execmascara()',1)
}

function execmascara(){
    v_obj.value=v_fun(v_obj.value)
}

function cpfCnpj(v){
    v=v.replace(/\D/g,"")
    if (v.length <= 11) { //CPF
        v=v.replace(/(\d{3})(\d)/,"$1.$2")
        v=v.replace(/(\d{3})(\d)/,"$1.$2")
        v=v.replace(/(\d{3})(\d{1,2})$/,"$1-$2")

    } else { //CNPJ
        v=v.replace(/^(\d{2})(\d)/,"$1.$2")
        v=v.replace(/^(\d{2})\.(\d{3})(\d)/,"$1.$2.$3")
		v=v.replace(/\.(\d{3})(\d)/,".$1/$2")
        v=v.replace(/(\d{4})(\d)/,"$1-$2")
    }
    return v
}

function mostraDivEmiten(){

	$('#divChqsBordero').css({'display': 'none'});
	$('#divBotoesBordero').css({'display': 'none'});
	$('#divEmiten').css({'display':'block'});
	$('#btProsseguir').attr('onclick', 'prosseguirManterBordero(); return false;');
	blockBackground(parseInt($('#divRotina').css('z-index')));

	cNrcpfcnpj = [];
	cDsemiten = [];

}

function prosseguirManterBordero(){
	var msg;

	if (cddopcao == 'I') msg = 'incluir';
	else msg = 'alterar';

	if( $('#tabEmiten tbody tr').length > 0 ){
		showConfirmacao('Deseja cadastrar os emitentes e '+ msg +' o border&ocirc; de desconto?','Confirma&ccedil;&atilde;o - Aimaro','cadastrarEmitentes();','','sim.gif','nao.gif');
	}else if( $('#tbChequesBordero tbody tr').length > 0 ){
		showConfirmacao('Deseja '+ msg +' o border&ocirc; de desconto?','Confirma&ccedil;&atilde;o - Aimaro','manterBordero();','','sim.gif','nao.gif');
	} else {
		showError('error','Nenhum cheque foi informado no border&ocirc;.','Alerta - Aimaro','');
	}
}

function cadastrarEmitentes(){

	showMsgAguardo('Aguarde, cadastrando emitentes ...');

	var dscheque = "";
	var idNrcpfcnpj, idDsemiten;
	var corLinha  = 'corImpar';
	var flgerro = false;

	$('#tabEmiten tbody tr').each(function(){

		idNrcpfcnpj = $("input[name='nrcpfcnpj']",this).attr('id');
		idDsemiten  = $("input[name='dsemiten']",this).attr('id');

		if ($("input[name='nrcpfcnpj']",this).val() == ""){
			showError('error','Preencha todos os campos para continuar.','Alerta - Aimaro','hideMsgAguardo();$(\'#'+idNrcpfcnpj+'\').focus();');
			flgerro = true;
			return false;
		}

		if ($("input[name='dsemiten']",this).val() == ""){
			showError('error','Preencha todos os campos para continuar.','Alerta - Aimaro','hideMsgAguardo(); $(\'#'+idDsemiten+'\').focus();');
			flgerro = true;
			return false;
		}

		if( dscheque != "" ){
			dscheque += "|";
		}

		dscheque += normalizaNumero($("#cdcmpchq",this).val()) + ";"; // Compe
		dscheque += normalizaNumero($("#cdbanchq",this).val()) + ";"; // Banco
		dscheque += normalizaNumero($("#cdagechq",this).val()) + ";"; // Agencia
		dscheque += normalizaNumero($("#nrctachq",this).val()) + ";"; // Conta
		dscheque += $("input[name='nrcpfcnpj']",this).val().replace(/[^0-9]/g, '') + ";" ; // Nrcpfcnpj
		dscheque += $("input[name='dsemiten']",this).val().toUpperCase(); // Emitente

		// Limpar a crítica
		$("#dscritic",this).text('');
		$(this).css('background', '');
		// Adiciona a cor Zebrado na Tabela de Cheques
		$(this).attr('class', corLinha);
		if( corLinha == 'corImpar' ){
			corLinha = 'corPar';
		} else {
			corLinha = 'corImpar';
		}

	});

	if (flgerro == true){
		return false;
	}

	if (dscheque == ""){
		showError('error','Emitentes n&atilde;o encontrados.','Alerta - Aimaro','hideMsgAguardo();');
		return false;
	}

	$.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/descontos/cheques/cadastrar_emiten.php',
        data: {
			dscheque: dscheque,
            redirect: 'html_ajax'
            },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));');
        },
        success: function(response) {
			hideMsgAguardo();
			try {
				eval( response );
			} catch(error) {
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));');
			}
        }
    });

}

function manterBordero(){

	showMsgAguardo('Aguarde, efetuando opera&ccedil;&atilde;o ...');

	var dscheque = "";
	var dscheque_exc = "";
	var flchqbor;

	if (ChqsRemovidos.length > 0){
		for (i = 0; i < ChqsRemovidos.length; i++) {

			if( dscheque_exc != "" ){
				dscheque_exc += "|";
			}

			dscheque_exc += ChqsRemovidos[i];
		}
	}

	$('#tbChequesBordero tbody tr').each(function(){

		flchqbor = $("#aux_flchqbor",this).val();

		// Em caso de alteração do bordero, devemos ignorar os cheques que já estão inclusos
		if (flchqbor != 1 && $(this).css('text-decoration').match('none')) {

			if( dscheque != "" ){
				dscheque += "|";
			}

			dscheque += $("#aux_dtlibera",this).val() + ";" ; // Data Boa
			dscheque += $("#aux_dtdcaptu",this).val() + ";" ; // Data Emissão
			dscheque += $("#aux_dtcustod",this).val() + ";" ; // Data Custódia
			dscheque += $("#aux_intipchq",this).val() + ";" ; // Tipo de Cheque
			dscheque += $("#aux_vlcheque",this).val().replace(/\./g,'') + ";" ; // Valor
			dscheque += $("#aux_dsdocmc7",this).val() + ";" ; // CMC-7
			dscheque += $("#aux_nrremret",this).val(); // Número remessa
		}
	});

	if (dscheque == "" && dscheque_exc == "" ){
		showError('error','Border&ocirc; n&atilde;o foi modificado.','Alerta - Aimaro','hideMsgAguardo();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));');
		return false;
	}

	$.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/descontos/cheques/manter_bordero.php',
        data: {
			nrdconta: nrdconta,
			nrborder: nrbordero,
			nrdolote: nrdolote,
			cddopcao: cddopcao,
			dscheque: dscheque,
			dscheque_exc: dscheque_exc,
			executandoProdutos: executandoProdutos,
            redirect: 'html_ajax'
            },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));');
        },
        success: function(response) {
			hideMsgAguardo();
			try {
				eval( response );
			} catch(error) {
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));');
			}
        }
    });

}

function mostraFormAnaliseBordero(){

	if (nrbordero == 0 || nrbordero == '' || nrbordero === undefined) {
		hideMsgAguardo();
		showError("error","Nenhum border&ocirc; selecionado.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}

  if (flgrejei == 1) {
    hideMsgAguardo();
    showError("error","Opera&ccedil;&atilde;o n&atilde;o permitida. Border&ocirc; rejeitado.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
    return false;
  }

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando dados do border&ocirc; ...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/atenda/descontos/cheques/cheques_bordero_analise.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			nrborder: nrbordero,
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divOpcoesDaOpcao3").html(response);
			layoutPadrao();
		}
	});
}

function concluirAnaliseBordero(){
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, atualizando situa&ccedil;&atilde;o dos cheques do border&ocirc; ...");

	var dscheque = "";

	$('#tbChequesBordero tbody tr').each(function(){

		flgaprov = $("#insitana",this).val();

		if( dscheque != "" ){
			dscheque += "|";
		}

		dscheque += $("#dsdocmc7",this).val() + ";"; // CMC-7
		dscheque += flgaprov; // Aprovado/Reprovado
	});

	if (dscheque == "" ){
		showError('error','Border&ocirc; n&atilde;o foi modificado.','Alerta - Aimaro','hideMsgAguardo();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));');
		return false;
	}

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/atenda/descontos/cheques/cheques_bordero_conclui_analise.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			nrborder: nrbordero,
			dscheque: dscheque,
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			hideMsgAguardo();
			try {
				eval( response );
			} catch(error) {
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));');
			}
		}
	});
}

function verificaAssinaturaBordero(){

	if (nrbordero == 0 || nrbordero == '' || nrbordero === undefined) {
		hideMsgAguardo();
		showError("error","Nenhum border&ocirc; selecionado.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}

	if (flgrejei == 1) {
		hideMsgAguardo();
		showError("error","Opera&ccedil;&atilde;o n&atilde;o permitida. Border&ocirc; rejeitado.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
    }

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, verificando se border&ocirc; necessita de assinatura...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/atenda/descontos/cheques/cheques_bordero_verifica_assinatura.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			nrborder: nrbordero,
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			hideMsgAguardo();
			try {
				eval( response );
			} catch(error) {
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));');
			}
		}
	});
}

function efetivaBordero(flgImpressao){
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, verificando se border&ocirc; necessita de assinatura...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/atenda/descontos/cheques/cheques_bordero_efetiva_bordero.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			nrborder: nrbordero,
            flresghj: flresghj,
			cdopcolb: ' ',
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			hideMsgAguardo();
			try {
				if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
					if (flgImpressao) {
						var action = UrlSite + "telas/atenda/descontos/cheques/comprovante_pdf.php";
	                	carregaImpressaoAyllos("formImpres",action,'estadoInicial();');
					}
				}
				eval( response );
			} catch(error) {
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));');
			}
		}
	});
}

function mostraFormResgate(){

	if (nrbordero == 0 || nrbordero == '' || nrbordero === undefined) {
		hideMsgAguardo();
		showError("error","Nenhum border&ocirc; selecionado.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando dados do border&ocirc; ...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/atenda/descontos/cheques/cheques_bordero_resgate.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			nrborder: nrbordero,
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divOpcoesDaOpcao3").html(response);
			layoutPadrao();
		}
	});

}

function selecionaChequeResgate(){

	var cDsdocmc7 = $('#dsdocmc7','#frmBorderoResgate');
	var divRegistro = $('div.divRegistros', '#divBorderoResgate');
	var dsdocmc7_sf = cDsdocmc7.val().replace(/[^0-9]/g, "").substr(0,30);
	var flgEncontrou = 0;

	$('table > tbody > tr', divRegistro).each(function(){
		if ($(this).find('#aux_dsdocmc7').val() == dsdocmc7_sf){
			$(this).find('td > #flgresgat').prop('checked', true);
			$(this).find('td > #flgresgat').prop('disabled', false);
			$(this).find('td > #flgresgat').val('1');
			mostraMsgSucesso();
			flgEncontrou = 1;
			return false;
		}
	});
	if (flgEncontrou == 0){
		mostraMsgErro();
	}
	cDsdocmc7.val('');
}

function verificaFlgresgat(flgresgat){
	if (flgresgat.checked == false) {
		flgresgat.disabled = true;
		flgresgat.value = 0;
	}
}

function confirmaRejeitaBordero() {
  if (flgrejei == 1) {
    hideMsgAguardo();
    showError("error","Border&ocirc; j&aacute; rejeitado.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
    return false;
  }

  
  if (flcusthj == 1){
      aux_acao = "confirmaResgateCustodiahj('rejeitaBorderoDscChq();','R')";      
  }else {
      aux_acao = "rejeitaBorderoDscChq();";
  }


  showConfirmacao('Deseja rejeitar borderô?','Confirma&ccedil;&atilde;o - Aimaro',aux_acao,'','sim.gif','nao.gif');
  return false;
}

function rejeitaBorderoDscChq(){

	if (nrbordero == 0 || nrbordero == '' || nrbordero === undefined) {
		hideMsgAguardo();
		showError("error","Nenhum border&ocirc; selecionado.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, rejeitando border&ocirc; de desconto...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/atenda/descontos/cheques/cheques_bordero_rejeitar.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			nrborder: nrbordero,
            flresghj: flresghj,
			redirect: "html_ajax"
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

function mostraMsgSucesso(){
	var dsmsgcmc7 = $('#dsmsgcmc7','#frmBorderoResgate');
	dsmsgcmc7.text('Cheque marcado para resgate');
	dsmsgcmc7.css('display', 'block');
	dsmsgcmc7.css('color', 'green');
	setTimeout(mostraMsgCmc7, 2000);
}

function mostraMsgErro(){
	var dsmsgcmc7 = $('#dsmsgcmc7','#frmBorderoResgate');
	dsmsgcmc7.text('Cheque não encontrado');
	dsmsgcmc7.css('display', 'block');
	dsmsgcmc7.css('color', 'red');
	setTimeout(mostraMsgCmc7, 2000);
}

function mostraMsgCmc7(){
	$('#dsmsgcmc7','#frmBorderoResgate').css('display','none');
}

function concluiResgate(){
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, verificando saldo do cooperado...");

	var divRegistro = $('div.divRegistros', '#divBorderoResgate');

	var dscheque = "";
	var vlcheque = 0;

	$('table > tbody > tr', divRegistro).each(function(){

		if ($(this).find('td > #flgresgat').val() == '1'){

			if( dscheque != "" ){
				dscheque += "|";
			}

			dscheque += $("#aux_dsdocmc7",this).val(); // CMC-7
			vlcheque += Number($("#aux_vlcheque",this).val().replace('.','').replace(',','.'));
			
		}
	});
	
	if (dscheque == "" ){
		showError('error','Border&ocirc; n&atilde;o foi modificado.','Alerta - Aimaro','hideMsgAguardo();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));');
		return false;
	}

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/atenda/descontos/cheques/cheques_bordero_verifica_saldo.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			vlcheque: vlcheque,
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			hideMsgAguardo();
			try {
				eval(response);
			} catch(error) {
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));');
			}
		}
	});

}

function efetuaResgate() {
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, efetuando resgate dos cheques selecionados ...");
	
	var divRegistro = $('div.divRegistros', '#divBorderoResgate');

	var dscheque = "";

	$('table > tbody > tr', divRegistro).each(function(){

		if ($(this).find('td > #flgresgat').val() == '1'){

			if( dscheque != "" ){
				dscheque += "|";
			}

			dscheque += $("#aux_dsdocmc7",this).val(); // CMC-7
		}
	});
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/atenda/descontos/cheques/cheques_bordero_efetua_resgate.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			nrborder: nrbordero,
			dscheque: dscheque,
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			hideMsgAguardo();
			try {
				eval( response );
			} catch(error) {
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));');
			}
		}
	});
}

// Apresentar confirmacao se gostaria de resgatar os cheques custodiados no dia de hoje
function confirmaResgateCustodiahj(acao,tipoacao) {
  if (tipoacao == 'L') {
      msg = 'O border&ocirc; possui cheques reprovados custodiados na data de hoje, deseja realizar o resgate da cust&oacute;dia de cheque?'
  }else{
      msg = 'O border&ocirc; possui cheques custodiados na data de hoje, deseja realizar o resgate da cust&oacute;dia de cheque?';
  }
      
  
  showConfirmacao(msg,'Confirma&ccedil;&atilde;o - Aimaro','flresghj = 1; ' + acao,'flresghj = 0; ' + acao,'sim.gif','nao.gif');
  return false;
}
			 
function validaCheque(){
	
	showMsgAguardo('Aguarde, validando cheque ...');
	
	var dscheque = "";
	var data    = $('#dtlibera', '#frmChequesCustodiaNovo').val();
	var dataEmi = $('#dtdcaptu', '#frmChequesCustodiaNovo').val();
	var valor   = $('#vlcheque', '#frmChequesCustodiaNovo').val();
	var cmc7    = $('#dsdocmc7', '#frmChequesCustodiaNovo').val();
	var cmc7_sem_format  = cmc7.replace(/[^0-9]/g, "").substr(0,30);
	
	// Validar se os campos estão preenchidos
	if ( data == '' ) {
		showError('error','Data boa inv&aacute;lida.','Alerta - Aimaro','hideMsgAguardo(); blockBackground(parseInt($(\'#divRotina\').css(\'z-index\'))); $(\'#dtlibera\', \'#frmChequesCustodiaNovo\').focus();');
		return false;
	}
	
	if ( dataEmi == '' ) {
		showError('error','Data de emiss&atilde;o inv&aacute;lida.','Alerta - Aimaro','hideMsgAguardo(); blockBackground(parseInt($(\'#divRotina\').css(\'z-index\'))); $(\'#dtdcaptu\', \'#frmChequesCustodiaNovo\').focus();');
		return false;
	}
	
	if ( valor == '' || valor == '0,00') {
		showError('error','Valor inv&aacute;lido.','Alerta - Aimaro','hideMsgAguardo(); blockBackground(parseInt($(\'#divRotina\').css(\'z-index\'))); $(\'#vlcheque\', \'#frmChequesCustodiaNovo\').focus();');
		return false;
	}
	
	if ( cmc7_sem_format.length < 30 ) {
		showError('error','CMC-7 inv&aacute;lido.','Alerta - Aimaro','hideMsgAguardo(); blockBackground(parseInt($(\'#divRotina\').css(\'z-index\'))); $(\'#dsdocmc7\', \'#frmChequesCustodiaNovo\').focus();');
		return false;
	}
	
	var aDataBoa = data.split("/"); 
	var aDataEmi = dataEmi.split("/"); 
	var aDtmvtolt = aux_dtmvtolt.split("/"); 
	var dtcompara1 = parseInt(aDataBoa[2].toString() + aDataBoa[1].toString() + aDataBoa[0].toString()); 
	var dtcompara2 = parseInt(aDataEmi[2].toString() + aDataEmi[1].toString() + aDataEmi[0].toString()); 
	var dtcompara3 = parseInt(aDtmvtolt[2].toString() + aDtmvtolt[1].toString() + aDtmvtolt[0].toString()); 
	
	if ( dtcompara1 <= dtcompara3 ) {
		showError('error','A data boa deve ser maior que a data atual.','Alerta - Aimaro','hideMsgAguardo(); blockBackground(parseInt($(\'#divRotina\').css(\'z-index\'))); $(\'#dtlibera\', \'#frmChequesCustodiaNovo\').focus();');
		return false;
	}
	
	if ( dtcompara2 > dtcompara3 ) {
		showError('error','A data de emiss&atilde;o deve ser menor que a data atual.','Alerta - Aimaro','hideMsgAguardo(); blockBackground(parseInt($(\'#divRotina\').css(\'z-index\'))); $(\'#dtdcaptu\', \'#frmChequesCustodiaNovo\').focus();');
		return false;
	}
	/*
	if (!validaCmc7(cmc7)){
		showError('error','CMC-7 Inv&aacute;lido!','Alerta - Aimaro','hideMsgAguardo(); cDsdocmc7.limpaFormulario();cDsdocmc7.focus();');
		return false;
	}
	*/
	dscheque += data + ";" ; // Data Boa
	dscheque += dataEmi + ";" ; // Data Emissão
	dscheque += valor.replace(/\./g,'').replace(',','.') + ";" ; // Valor
	dscheque += cmc7_sem_format; // CMC-7
	
	$.ajax({        
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/descontos/cheques/cheques_bordero_validar_cheque.php', 
        data: {
            nrdconta: nrdconta,
			dscheque: dscheque,
            redirect: 'html_ajax'           
            }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();           
            showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',"unblockBackground()");
        },
        success: function(response) {
			hideMsgAguardo();
			try {
				eval( response );
			} catch(error) {						
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground();');
			}
        }
    });
}

// Mostra form cadastro de emitente
function mostraFormEmitente(cdcmpchq, cdbanchq, cdagechq, nrctachq) {
	
	showMsgAguardo('Aguarde, carregando cadastro de emitente...');

	// Executa script através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atenda/descontos/cheques/cheques_bordero_detalhamento_emitente.php', 
		data: {			
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',"unblockBackground()");
		},
		success: function(response) {			
			$('#divUsoGenerico').css({'height': '400px'});						
			$('#divUsoGenerico').html(response);				
            exibeRotina($('#divUsoGenerico'));			
			buscaFormEmitente(cdcmpchq, cdbanchq, cdagechq, nrctachq);
		}				
	});
	
	return false;
	
}

function buscaFormEmitente(cdcmpchq, cdbanchq, cdagechq, nrctachq){
	
	if( cdbanchq == 1 ){
	    nrctachq = mascara(normalizaNumero(nrctachq.toString()),'####.###-#');
	} else {
		nrctachq = mascara(normalizaNumero(nrctachq.toString()),'######.###-#');
	}
	
	// Executa script através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atenda/descontos/cheques/cheques_bordero_form_cadastra_emitente.php', 
		data: {			
			cdcmpchq: cdcmpchq,	
			cdbanchq: cdbanchq,
			cdagechq: cdagechq,
			nrctachq: nrctachq,	
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',"unblockBackground()");
		},
		success: function(response) {			
			$('#divDetalhamento').html(response);			
			formataCadastroEmitente();
		}				
	});
	
	return false;
	
}

function formataCadastroEmitente(){
	
	var rCdcmpchq_emi, rCdbanchq_emi, rCdagechq_emi, rNrctachq_emi, 
		rNrcpfcgc_emi, rDsemiten_emi;
		
	var cCdcmpchq_emi, cCdbanchq_emi, cCdagechq_emi, cNrctachq_emi, 
		cNrcpfcgc_emi, cDsemiten_emi;
		
    var btnIncluirEmi = $('#btIncluirEmi', '#divBotoesDetalhe');
	highlightObjFocus($('#frmCadastraEmitente'));
	
    // label
	rCdcmpchq_emi = $('label[for="cdcmpchq"]', '#frmCadastraEmitente');
	rCdbanchq_emi = $('label[for="cdbanchq"]', '#frmCadastraEmitente');
	rCdagechq_emi = $('label[for="cdagechq"]', '#frmCadastraEmitente');
	rNrctachq_emi = $('label[for="nrctachq"]', '#frmCadastraEmitente');
	rNrcpfcgc_emi = $('label[for="nrcpfcgc"]', '#frmCadastraEmitente');
	rDsemiten_emi = $('label[for="dsemiten"]', '#frmCadastraEmitente');
	
    rCdcmpchq_emi.css({'width': '61px'}).addClass('rotulo');
    rCdbanchq_emi.css({'width': '61px'}).addClass('rotulo-linha');
    rCdagechq_emi.css({'width': '61px'}).addClass('rotulo-linha');
    rNrctachq_emi.css({'width': '61px'}).addClass('rotulo-linha');
    rNrcpfcgc_emi.css({'width': '120px'}).addClass('rotulo');
    rDsemiten_emi.css({'width': '120px'}).addClass('rotulo');

    // input
    cCdcmpchq_emi = $('#cdcmpchq', '#frmCadastraEmitente');
    cCdbanchq_emi = $('#cdbanchq', '#frmCadastraEmitente');
    cCdagechq_emi = $('#cdagechq', '#frmCadastraEmitente');
    cNrctachq_emi = $('#nrctachq', '#frmCadastraEmitente');
    cNrcpfcgc_emi = $('#nrcpfcgc', '#frmCadastraEmitente');
    cDsemiten_emi = $('#dsemiten', '#frmCadastraEmitente');
	cDsemiten_emi.setMask("STRING",60,charPermitido(),"");

    cCdcmpchq_emi.css({'width': '40px'}).desabilitaCampo();
    cCdbanchq_emi.css({'width': '40px'}).desabilitaCampo();
    cCdagechq_emi.css({'width': '50px'}).desabilitaCampo();
    cNrctachq_emi.css({'width': '98px'}).desabilitaCampo();
    cNrcpfcgc_emi.css({'width': '150px'}).habilitaCampo();
    cDsemiten_emi.css({'width': '379px'}).habilitaCampo();
	cDsemiten_emi.addClass('alphanum');
	
	layoutPadrao();
	
	cNrcpfcgc_emi.focus();
	
	// Data Emissão
    cNrcpfcgc_emi.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se é a tecla TAB ou ENTER, 
        if (e.keyCode == 13) {
            cDsemiten_emi.focus();
            return false;
        }

		mascaraCpfCnpj(this,cpfCnpj);
		
    });

	// Data Boa
    cDsemiten_emi.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se é a tecla TAB ou ENTER, 
        if (e.keyCode == 13) {
            confirmaIncluiEmitente();
            return false;
        }
		
    });
		
    hideMsgAguardo();
    bloqueiaFundo($('#divUsoGenerico'));
	return false;
}

function confirmaIncluiEmitente(){
	showConfirmacao('Confirma a inclus&atilde;o do emitente?', 'Confirma&ccedil;&atilde;o - Aimaro', 'incluiEmitente();', 'return false;', 'sim.gif', 'nao.gif');
	return false;
}

function incluiEmitente(){
	
	showMsgAguardo('Aguarde, cadastrando emitente...');

	var cdcmpchq, cdbanchq, cdagechq, nrctachq, nrcpfcgc, dsemiten, dscheque;
	
	cdcmpchq = normalizaNumero($('#cdcmpchq', '#frmCadastraEmitente').val());
	cdbanchq = normalizaNumero($('#cdbanchq', '#frmCadastraEmitente').val());
	cdagechq = normalizaNumero($('#cdagechq', '#frmCadastraEmitente').val());
	nrctachq = normalizaNumero($('#nrctachq', '#frmCadastraEmitente').val());
	nrcpfcgc = normalizaNumero($('#nrcpfcgc', '#frmCadastraEmitente').val());
	dsemiten = $('#dsemiten', '#frmCadastraEmitente').val();
				
	if (nrcpfcgc == ""){
		showError('error','Preencha todos os campos para continuar.','Alerta - Aimaro','hideMsgAguardo(); $(\'#nrcpfcgc\', \'#frmCadastraEmitente\').focus(); bloqueiaFundo($(\'#divUsoGenerico\'));');
		return false;
	}
	
	if (dsemiten == ""){
		showError('error','Preencha todos os campos para continuar.','Alerta - Aimaro','hideMsgAguardo(); $(\'#nrcpfcgc\', \'#frmCadastraEmitente\').focus(); bloqueiaFundo($(\'#divUsoGenerico\'));');
		return false;
	}

	dscheque = cdcmpchq + ';' + 
			   cdbanchq + ';' + 
			   cdagechq + ';' + 
			   nrctachq + ';' + 
			   nrcpfcgc + ';' + 
			   dsemiten.toUpperCase();
	$.ajax({        
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/descontos/cheques/cheques_bordero_cadastrar_emitente.php', 
        data: {
			dscheque: dscheque,
            redirect: 'html_ajax'           
            }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();           
            showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',"unblockBackground()");
        },
        success: function(response) {
			hideMsgAguardo();
			try {
				eval( response );
			} catch(error) {						
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground();');
			}
        }
    });
	
	return false;
	
}

function mostraAutorizaResgate(){

    // Executa script através de ajax
    $.ajax({        
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/descontos/cheques/autorizar_resgate.php', 
        data: {         
            redirect: 'html_ajax'           
            }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',"unblockBackground()");
        },
        success: function(response) {
            $("#divOpcoesDaOpcao2").html(response);
            formataAutorizarRegaste();
        }
    });
	
	return false;
	
}

function formataAutorizarRegaste(){

    $('#divAutSenha').css('display', 'none');
    $('#divNomeDoc').css('display', 'none');

    if (inpessoa > 1 && idastcjt == 1) {
        $('#divAutIB').css('display', 'block');
    } else {
        $('#divAutIB').css('display', 'none');
    }
    
    // label
    var rSenha     = $('label[for="dssencar"]', '#frmAutorizar');
    var rNome      = $('label[for="nomeresg"]', '#frmAutorizar');
    var rDocumento = $('label[for="docuresg"]', '#frmAutorizar');

    rSenha.addClass('rotulo').css('width', '40px');
    rNome.addClass('rotulo').css('width', '40px');
    rDocumento.addClass('rotulo').css('width', '40px');

    // input
    var cSenha                  = $('#dssencar', '#frmAutorizar');
    var cFlgAutorizaSenha       = $('#flgAutorizaSenha', '#frmAutorizar');
    var cFlgAutorizaIB          = $('#flgAutorizaIB', '#frmAutorizar');
    var cFlgAutorizaComprovante = $('#flgAutorizaComprovante', '#frmAutorizar');
    var cNome                   = $('#nomeresg', '#frmAutorizar');
    var cDocumento              = $('#docuresg', '#frmAutorizar');
    
    cSenha.css('width', '100px').addClass('campo');
    cFlgAutorizaSenha.css('clear', 'left');
    cFlgAutorizaIB.css('clear', 'left');
    cFlgAutorizaComprovante.css('clear', 'left');
    cNome.css('width', '220px').addClass('campo');
    cDocumento.css('width', '220px').addClass('campo');
}

function alteraOpcaoAutorizar(){
    var opcaoSelecionada = $('input[type=radio][name=flgautoriza]:checked', '#frmAutorizar').val();
    if (opcaoSelecionada == 'senha') {
        $('#divAutSenha').css('display', 'block');
        $('#divNomeDoc').css('display', 'none');
    } else if (opcaoSelecionada == 'ib') {
        $('#divAutSenha').css('display', 'none');
        $('#divNomeDoc').css('display', 'none');
    } else if (opcaoSelecionada == 'comprovante') {
        $('#divAutSenha').css('display', 'none');
        $('#divNomeDoc').css('display', 'block');
    }
}

function prosseguirAutorizacao(){

    hideMsgAguardo();

    var opcaoSelecionada = $('input[type=radio][name=flgautoriza]:checked', '#frmAutorizar').val();

    if (opcaoSelecionada == 'senha') {
        // Validar a senha digitada
        var dssencar = $('#dssencar', '#frmAutorizar').val();

        showMsgAguardo('Aguarde, validando ...');

        $.ajax({
            type: 'POST',
            async: true,
            url: UrlSite + 'telas/atenda/descontos/cheques/valida_senha_cooperado.php',
            data: {
                nrdconta: nrdconta,
                dssencar: dssencar,
                inpessoa: inpessoa,
                idastcjt: idastcjt,
                redirect: 'script_ajax'
            },
            error: function(objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'unblockBackground()');
            },
            success: function(response) {
                try {
                    eval(response);
                    return false;
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'unblockBackground()');
                }
            }
        });
    } else if(opcaoSelecionada == 'ib'){
        criaTransPendenteCheque('ib');
    } else if(opcaoSelecionada == 'comprovante'){
        geraImpressaoComprovante();
    }

    return false;

}

function geraImpressaoComprovante(){

    showMsgAguardo('Aguarde, buscando cheque(s) resgatados(s) ...');

    $('#formImpres').html('');

    $('#formImpres').append('<input type="hidden" id="nrdconta" name="nrdconta" value="'+nrdconta+'"/>');
    $('#formImpres').append('<input type="hidden" id="nmprimtl" name="nmprimtl" value="'+nmprimtl+'"/>');
    $('#formImpres').append('<input type="hidden" id="sidlogin" name="sidlogin" value="'+ $('#sidlogin','#frmMenu').val() + '"/>');
    $('#formImpres').append('<input type="hidden" id="inpessoa" name="inpessoa" value="'+inpessoa+'"/>');
    $('#formImpres').append('<input type="hidden" id="idastcjt" name="idastcjt" value="'+idastcjt+'"/>');

    buscarChequesCustodiadosHoje();
}

function buscarChequesCustodiadosHoje(){
    
    // Executa script através de ajax
    $.ajax({        
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/descontos/cheques/busca_cheques_cust_hj.php', 
        data: {         
            nrdconta: nrdconta,
            nrborder: nrbordero,
            redirect: 'html_ajax'           
            }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',"unblockBackground()");
        },
        success: function(response) {
            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try{

                    $('#formImpres').append(response);
                    
                    buscarResponsaveisAssinatura();

                } catch(error){
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground();');
                }
            }else{
                try {
                    eval( response );                   
                } catch(error) {                        
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground();');
                }
            }
        }
    });
    
    return false;
    
}

function buscarResponsaveisAssinatura(){
    
    // Executa script através de ajax
    $.ajax({        
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/descontos/cheques/busca_responsaveis_assinatura.php', 
        data: {         
            nrdconta: nrdconta,
            redirect: 'html_ajax'           
            }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',"unblockBackground()");
        },
        success: function(response) {
            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try{

                    $('#formImpres').append(response);
                    efetivaBordero(true);

                } catch(error){
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground();');
                }
            }else{
                try {
                    eval( response );                   
                } catch(error) {                        
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground();');
                }
            }
        }
    });
    
    return false;
    
}

function selecionarResponsavel(){
    var nrcpfcgc = $('input[type=radio][name=nrcpfcgc]:checked', '#tabelaResponsaveis').val();

    criaTransPendenteCheque('senha', nrcpfcgc);
}

function criaTransPendenteCheque(opcao, nrcpfcgc){
    
    showMsgAguardo('Aguarde, criando pendências para os outros responsáveis...');

    $.ajax({
      type: 'POST',
      dataType: 'html',
      url: UrlSite + 'telas/atenda/descontos/cheques/cria_trans_pend_resgate_cst.php', 
        async: false,
        data: {
            nrdconta: nrdconta,
            nrcpfcgc: nrcpfcgc,
            nrborder: nrbordero,
            redirect: 'html_ajax'
            }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',"unblockBackground()");
        },
        success: function(response) {
            hideMsgAguardo();
            try {
                eval( response );                   
            } catch(error) {                    
                showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground();');
            }
        }
    });
}

function formRespAssinatura(){
    
    // Executa script através de ajax
    $.ajax({        
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/descontos/cheques/form_resp_assinatura.php', 
        data: {         
            nrdconta: nrdconta,
            redirect: 'html_ajax'           
            }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',"unblockBackground()");
        },
        success: function(response) {
            hideMsgAguardo();  
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try{
                    $('#divAutorizar').html(response);           
                    formataTabelaResponsaveisAssinatura();
                } catch(error){
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground();');
                }
            }else{
                try {
                    eval( response );                   
                } catch(error) {                        
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground();');
                }
            }         
        }               
    });
    
    return false;
    
}

function formataTabelaResponsaveisAssinatura(){
    
    // tabela
    var divRegistro = $('div.divRegistros', '#divAutorizar');
    var tabela = $('table', divRegistro);

    var ordemInicial = new Array();

    var arrayLargura = new Array();
	arrayLargura[0] = '13px';
    
    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');
}
function telefone(fone){
	if(fone != null){
		fone = fone.replace(/\D/g,"");                 //Remove tudo o que não é dígito
		if (fone.length < 10 || fone.length > 11)
			return '';
		fone = fone.replace(/^(\d\d)(\d)/g,"($1) $2"); //Coloca parênteses em volta dos dois primeiros dígitos
		fone = fone.replace(/(\d{4})(\d)/,"$1-$2");    //Coloca hífen entre o quarto e o quinto dígitos
		return fone;
	} else {
		return '';
	}
}
// PJ438
function preencherDemonstracao() {
	var demoNivrisco  = $('#nivrisco',"#frmDadosLimiteDscChq").val();
	var demoNrctrlim  = $('#nrctrlim',"#frmDadosLimiteDscChq").val();
	var demoVllimite  = $('#vllimite',"#frmDadosLimiteDscChq").val();
	var demoCddlinha  = $('#cddlinha',"#frmDadosLimiteDscChq").val();
	    demoCddlinha += ' - ';
	    demoCddlinha += $('#cddlinh2',"#frmDadosLimiteDscChq").val();
	var demoTxmensal  = $('#txmensal',"#frmDadosLimiteDscChq").val();
	var demoQtdiavig  = $('#qtdiavig',"#frmDadosLimiteDscChq").val();
	$('#demoNivrisco').val(demoNivrisco);
	$('#demoNrctrlim').val(demoNrctrlim);
	$('#demoVllimite').val(demoVllimite);
	$('#demoCddlinha').val(demoCddlinha);
	$('#demoTxmensal').val(demoTxmensal);
	$('#demoQtdiavig').val(demoQtdiavig);
}

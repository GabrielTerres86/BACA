/*!
 * FONTE        : titulos.php
 * CRIAÇÃO      : Guilherme
 * DATA CRIAÇÃO : Março/2009
 * OBJETIVO     : Biblioteca de funções da subrotina de Descontos de Títulos
 * --------------
 * ALTERAÇÕES   : 18/11/2016
 * --------------
 * 000: [08/06/2010] David     (CECRED) : Adaptação para RATING
 * 000: [22/09/2010] David	   (CECRED) : Ajuste para enviar impressoes via email para o PAC Sede
 * 001: [04/05/2010] Rodolpho     (DB1) : Adaptação para o Zoom Endereço e Avalistas genérico
 * 002: [12/09/2011] Adriano   (CECRED) : Ajuste para Lista Negra
 * 003: [10/07/2012] Jorge	   (CECRED) : Alterado esquema para impressao em gerarImpressao().
 * 004: [11/07/2012] Lucas     (CECRED) : Lupas para listagem de Linhas de Desconto de Título disponíveis.
 * 005: [05/11/2012] Adriano   (CECRED) : Ajustes referente ao projeto GE.
 * 005: [01/04/2013] Lucas R.  (CECRED) : Ajustes na function controlaLupas.
 * 006: [21/05/2015] Reinert   (CECRED) : Alterado para apresentar mensagem ao realizar inclusao
 *								          de proposta de novo limite de desconto de titulo para
 *									      menores nao emancipados.
 * 007: [20/08/2015] Kelvin    (CECRED) : Ajuste feito para não inserir caracters 
 *  								      especiais na observação, conforme solicitado
 *										  no chamado 315453.
 *
 * 008: [17/12/2015] Lunelli   (CECRED) : Edição de número do contrato de limite (Lunelli - SD 360072 [M175])
 * 009: [27/06/2016] Jaison/James (CECRED) : Inicializacao da aux_inconfi6.
 * 010: [18/11/2016] Jaison/James (CECRED) : Reinicializa glb_codigoOperadorLiberacao somente quando pede a senha do coordenador.
 */

var contWin    = 0;  // Variável para contagem do número de janelas abertas para impressos
var nrcontrato = ""; // Variável para armazenar número do contrato de descto selecionado
var nrbordero = ""; // Variável para armazenar número do bordero de descto selecionado
var situacao_limite = ""; // Variável para armazenar a situação do limite atualmente selecionado
var idLinhaB   = 0;  // Variável para armazanar o id da linha que contém o bordero selecionado
var idLinhaL   = 0;  // Variável para armazanar o id da linha que contém o limite selecionado
var dtrating   = 0;  // Data rating (é calculada e alimentada no titulos_limite_incluir.php)
var diaratin   = 0;  // Dia do rating da tabela tt-risco (é alimentada no titulos_limite_incluir.php)
var vlrrisco   = 0;  // Valor do risco (é alimentada no titulos_limite_incluir.php)

// ALTERAÇÃO 001: Criação de variáveis globais 
var nomeForm    	= 'frmDadosLimiteDscTit'; 	// Variável para guardar o nome do formulário corrente
var boAvalista  	= 'b1wgen0028.p'; 			// BO para esta rotina
var procAvalista 	= 'carrega_avalista'; 		// Nome da procedures que busca os avalistas
var operacao		= '' 						// Operação corrente

var strHTML 		= ''; // Variável usada na criação da div de alerta do grupo economico.
var strHTML2 		= ''; // Variável usada na criação do form onde serão mostradas as mensagens de alerta do grupo economico.	
var dsmetodo   		= ''; // Variável usada para manipular o método a ser executado na função encerraMsgsGrupoEconomico.


var aux_inconfir = ""; /*Variável usada para controlar validações que serão realizadas dentro das ptocedures valida_proposta, efetua_liber_anali_bordero.*/
var aux_inconfi2 = ""; /*Variável usada para controlar validações que serão realizadas dentro das ptocedures valida_proposta, efetua_liber_anali_bordero.*/
var aux_inconfi3 = ""; /*Variável usada para controlar validações que serão realizadas dentro das ptocedures valida_proposta, efetua_liber_anali_bordero.*/
var aux_inconfi4 = ""; /*Variável usada para controlar validações que serão realizadas dentro das ptocedures valida_proposta, efetua_liber_anali_bordero.*/
var aux_inconfi5 = ""; /*Variável usada para controlar validações que serão realizadas dentro das ptocedures valida_proposta, efetua_liber_anali_bordero.*/
var aux_inconfi6 = ""; /*Variável usada para controlar validações que serão realizadas dentro das ptocedures valida_proposta, efetua_liber_anali_bordero.*/


// ALTERAÇÃO 001: Carrega biblioteca javascript referente aos AVALISTAS
$.getScript(UrlSite + 'includes/avalistas/avalistas.js');

// BORDERÔS DE DESCONTO DE TÍTULOS
// Mostrar o <div> com os borderos de desconto de títulos
function carregaBorderosTitulos() {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando border&ocirc;s de desconto de t&iacute;tulos ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/descontos/titulos/titulos_bordero.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divOpcoesDaOpcao2").html(response);
		}				
	});		
}

// Função para seleção do bordero
function selecionaBorderoTitulos(id,qtBorderos,bordero,contrato) {
	var cor = "";

	// Formata cor da linha da tabela que lista os borderos de descto titulos
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
			idLinhaB  = id;		
		}
	}
}

// OPÇÕES CONSULTA/EXCLUSÃO/IMPRIMIR/LIBERAÇÃO/ANÁLISE
// Mostrar dados do bordero para fazer
function mostraDadosBorderoDscTit(opcaomostra) {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando dados do border&ocirc; ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/descontos/titulos/titulos_bordero_carregadados.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			cddopcao: opcaomostra,
			nrborder: nrbordero,
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divOpcoesDaOpcao3").html(response);
		}				
	});		
}

// OPÇÃO CONSULTAR
// Mostrar títulos do bordero
function carregaTitulosBorderoDscTit() { 
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando t&iacute;tulos do border&ocirc; ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/descontos/titulos/titulos_bordero_consultar_visualizatitulos.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			nrborder: nrbordero,
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divOpcoesDaOpcao4").html(response);
		}				
	});		
} 

// OPÇÃO EXCLUIR
// Função para excluir um bordero de desconto de títulos
function excluirBorderoDscTit() {	
	// Se não tiver nenhum bordero selecionado
	if (nrbordero == "") {
		return false;
	}
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, excluindo border&ocirc; ...");
	
	// Executa script de exclusão através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/atenda/descontos/titulos/titulos_bordero_excluir.php", 
		data: {
			nrdconta: nrdconta,
			nrborder: nrbordero,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});				
}

// OPÇÃO IMPRIMIR
// Função para mostrar a opção Imprimir dos borderos de desconto de títulos
function mostraImprimirBordero(){
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando op&ccedil;&atilde;o Imprimir ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/descontos/titulos/titulos_bordero_imprimir.php",
		dataType: "html",
		data: {
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divOpcoesDaOpcao3").html(response);
		}				
	});
}

// Função para verificar se deve ser enviado e-mail ao PAC Sede
function verificaEnvioEmail(idimpres,limorbor) {
	showConfirmacao("Efetuar envio de e-mail para Sede?","Confirma&ccedil;&atilde;o - Ayllos","gerarImpressao(" + idimpres + "," + limorbor + ",'yes');","gerarImpressao(" + idimpres + "," + limorbor + ",'no');","sim.gif","nao.gif");
}

// Função para gerar impressão em PDF
function gerarImpressao(idimpres,limorbor,flgemail,fnfinish) {
	
	if (idimpres == 8) {
		imprimirRating(false,3,nrcontrato,"divOpcoesDaOpcao3",fnfinish);
		return;		
	}
	
	$("#nrdconta","#frmImprimirDscTit").val(nrdconta);
	$("#idimpres","#frmImprimirDscTit").val(idimpres);
	$("#flgemail","#frmImprimirDscTit").val(flgemail);
	$("#nrctrlim","#frmImprimirDscTit").val(nrcontrato);
	$("#nrborder","#frmImprimirDscTit").val(nrbordero);		
	$("#limorbor","#frmImprimirDscTit").val(limorbor);
	
	var action = $("#frmImprimirDscTit").attr("action");
	var callafter = "blockBackground(parseInt($('#divRotina').css('z-index')));";
	
	carregaImpressaoAyllos("frmImprimirDscTit",action,callafter);

}

// OPÇÃO LIBERAR
// Liberar/Analisar bordero de desconto de títulos
function liberaAnalisaBorderoDscTit(opcao,idconfir,idconfi2,idconfi3,idconfi4,idconfi5,idconfi6,indentra,indrestr) {

	var nrcpfcgc = normalizaNumero($("#nrcpfcgc","#frmCabAtenda").val());
    var mensagem = '';
    var cdopcoan = 0;
    var cdopcolb = 0;
			
	// Mostra mensagem de aguardo
	if (opcao == "N") {
		mensagem = "analisando";
        cdopcoan = glb_codigoOperadorLiberacao;
	} else {
		mensagem = "liberando";
        cdopcolb = glb_codigoOperadorLiberacao;
	}

    // Reinicializa somente quando pede a senha
    if (idconfi6 == 51) {
        glb_codigoOperadorLiberacao = 0;
    }

	showMsgAguardo("Aguarde, "+mensagem+" o border&ocirc; ...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/descontos/titulos/titulos_bordero_liberaranalisar.php",
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
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}			
	});
}

// LIMITES DE DESCONTO DE TITULOS
// Mostrar o <div> com os limites de desconto de títulos
function carregaLimitesTitulos() {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando limites de desconto de t&iacute;tulos ...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divOpcoesDaOpcao2").html(response);
		}				
	});		
}

// Função para seleção do limite
function selecionaLimiteTitulos(id,qtLimites,limite,dssitlim) {
	var cor = "";
	
	// Formata cor da linha da tabela que lista os limites de descto titulos
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
		}
	}
}

// Função para mostrar a opção Imprimir dos limites de desconto de títulos
function mostraImprimirLimite() {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando op&ccedil;&atilde;o Imprimir ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite_imprimir.php",
		dataType: "html",
		data: {
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divOpcoesDaOpcao3").html(response);
		}				
	});
}

// Função para cancelar um limite de desconto de títulos
function cancelaLimiteDscTit() {	
	// Se não tiver nenhum limite selecionado
	if (nrcontrato == "") {
		return false;
	}
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, cancelando limite ...");
	
	// Executa script de cancelamento através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite_cancelar.php", 
		data: {
			nrdconta: nrdconta,
			nrctrlim: nrcontrato,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});				
}

// Função para excluir um limite de desconto de títulos
function excluirLimiteDscTit() {	
	// Se não tiver nenhum limite selecionado
	if (nrcontrato == "") {
		return false;
	}
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, excluindo limite ...");
	
	// Executa script de exclusão através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite_excluir.php", 
		data: {
			nrdconta: nrdconta,
			nrctrlim: nrcontrato,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});				
}

// OPÇÃO CONSULTAR
// Carregar os dados para consulta de limite de desconto de títulos
function carregaDadosConsultaLimiteDscTit() {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando dados de desconto de t&iacute;tulos ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite_consultar.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			nrctrlim: nrcontrato,
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divOpcoesDaOpcao3").html(response);
		}				
	});		
}

// OPÇÃO INCLUIR
// Carregar os dados para inclusãoo de limite de títulos
function carregaDadosInclusaoLimiteDscTit(inconfir) {

	showMsgAguardo("Aguarde, carregando dados de desconto de t&iacute;tulos ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite_incluir.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			inconfir: inconfir,
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divOpcoesDaOpcao3").html(response);
			$("#divConteudoOpcao").css('display','none');
			controlaLupas(nrdconta);
		}				
	});		
}

// OPÇÃO ALTERAR
function mostraTelaAltera() {

    showMsgAguardo('Aguarde, abrindo altera&ccedil;&atilde;o...');

    exibeRotina($('#divUsoGenerico'));

    if (situacao_limite != "EM ESTUDO") {
        showError("error", "N&atilde;o &eacute; poss&iacute;vel alterar contrato. Situa&ccedil;&atilde;o do limite ATIVO.", "Alerta - Ayllos", "fechaRotinaAltera();");
        return false;
    }

    limpaDivGenerica();

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/descontos/titulos/titulos_limite_alterar_form.php',
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
        url: UrlSite + 'telas/atenda/descontos/titulos/numero.php',
        data: {
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
    carregaLimitesTitulos();
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
        showError("error", "Numero da proposta deve ser diferente de zero.", "Alerta - Ayllos", "$('#new_nrctrlim','#frmNumero').focus();blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
        return false;
    }

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite_alterar_numero.php",
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
            $("#divOpcoesDaOpcao3").html(response);
            layoutPadrao();
            hideMsgAguardo();
            bloqueiaFundo($('#divUsoGenerico'));
        }
    });
}

// Carregar os dados para consulta de limite de desconto de títulos
function carregaDadosAlteraLimiteDscTit() {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando dados de desconto de t&iacute;tulos ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite_alterar.php",
		dataType: "html",
		data: {
			nrdconta: nrdconta,
			nrctrlim: nrcontrato,
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divOpcoesDaOpcao3").html(response);
			controlaLupas(nrdconta);
		}				
	});		
}

// Função para gravar dados do limite de desconto de titulo
function gravaLimiteDscTit(cddopcao) {

	var nrcpfcgc = $("#nrcpfcgc","#frmCabAtenda").val().replace(".","").replace(".","").replace("-","").replace("/","");
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, efetuando " + (cddopcao == "A" ? "altera&ccedil;&atilde;o" : "inclus&atilde;o") + " do limite ...");
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite_grava_proposta.php",
		data: {
			nrdconta: nrdconta,
			cddopcao: cddopcao,
			nrcpfcgc: nrcpfcgc,
			
			nrctrlim: $("#nrctrlim","#frmDadosLimiteDscTit").val().replace(/\./g,""),
			vllimite: $("#vllimite","#frmDadosLimiteDscTit").val().replace(/\./g,""),
			dsramati: $("#dsramati","#frmDadosLimiteDscTit").val(),
            vlmedtit: $("#vlmedtit","#frmDadosLimiteDscTit").val().replace(/\./g,""),
			vlfatura: $("#vlfatura","#frmDadosLimiteDscTit").val().replace(/\./g,""),
			vloutras: $("#vloutras","#frmDadosLimiteDscTit").val().replace(/\./g,""),
			vlsalari: $("#vlsalari","#frmDadosLimiteDscTit").val().replace(/\./g,""),
			vlsalcon: $("#vlsalcon","#frmDadosLimiteDscTit").val().replace(/\./g,""),
			dsdbens1: $("#dsdbens1","#frmDadosLimiteDscTit").val(),
			dsdbens2: $("#dsdbens2","#frmDadosLimiteDscTit").val(),            
			cddlinha: $("#cddlinha","#frmDadosLimiteDscTit").val(),
			dsobserv: removeCaracteresInvalidos(removeAcentos($("#dsobserv","#frmDadosLimiteDscTit").val())),
			qtdiavig: $("#qtdiavig","#frmDadosLimiteDscTit").val().replace(/dias/,""),

			// 1o. Avalista 
			nrctaav1: normalizaNumero($("#nrctaav1","#frmDadosLimiteDscTit").val()),
			nmdaval1: $("#nmdaval1","#frmDadosLimiteDscTit").val(),
			nrcpfav1: normalizaNumero($("#nrcpfav1","#frmDadosLimiteDscTit").val()),
			tpdocav1: $("#tpdocav1","#frmDadosLimiteDscTit").val(),
			dsdocav1: $("#dsdocav1","#frmDadosLimiteDscTit").val(),
			nmdcjav1: $("#nmdcjav1","#frmDadosLimiteDscTit").val(),
			cpfcjav1: normalizaNumero($("#cpfcjav1","#frmDadosLimiteDscTit").val()),
			tdccjav1: $("#tdccjav1","#frmDadosLimiteDscTit").val(),
			doccjav1: $("#doccjav1","#frmDadosLimiteDscTit").val(),
			ende1av1: $("#ende1av1","#frmDadosLimiteDscTit").val(),
			ende2av1: $("#ende2av1","#frmDadosLimiteDscTit").val(),
			nrcepav1: normalizaNumero($("#nrcepav1","#frmDadosLimiteDscTit").val()),
			nmcidav1: $("#nmcidav1","#frmDadosLimiteDscTit").val(),
			cdufava1: $("#cdufava1","#frmDadosLimiteDscTit").val(),
			nrfonav1: $("#nrfonav1","#frmDadosLimiteDscTit").val(),
			emailav1: $("#emailav1","#frmDadosLimiteDscTit").val(),
			nrender1: normalizaNumero($("#nrender1","#frmDadosLimiteDscTit").val()),
			complen1: $("#complen1","#frmDadosLimiteDscTit").val(),
			nrcxaps1: normalizaNumero($("#nrcxaps1","#frmDadosLimiteDscTit").val()),

			// 2o. Avalista 
			nrctaav2: normalizaNumero($("#nrctaav2","#frmDadosLimiteDscTit").val()),
			nmdaval2: $("#nmdaval2","#frmDadosLimiteDscTit").val(),
			nrcpfav2: normalizaNumero($("#nrcpfav2","#frmDadosLimiteDscTit").val()),
			tpdocav2: $("#tpdocav2","#frmDadosLimiteDscTit").val(),
			dsdocav2: $("#dsdocav2","#frmDadosLimiteDscTit").val(),
			nmdcjav2: $("#nmdcjav2","#frmDadosLimiteDscTit").val(),
			cpfcjav2: normalizaNumero($("#cpfcjav2","#frmDadosLimiteDscTit").val()),
			tdccjav2: $("#tdccjav2","#frmDadosLimiteDscTit").val(),
			doccjav2: $("#doccjav2","#frmDadosLimiteDscTit").val(),
			ende1av2: $("#ende1av2","#frmDadosLimiteDscTit").val(),
			ende2av2: $("#ende2av2","#frmDadosLimiteDscTit").val(),
			nrcepav2: normalizaNumero($("#nrcepav2","#frmDadosLimiteDscTit").val()),
			nmcidav2: $("#nmcidav2","#frmDadosLimiteDscTit").val(),
			cdufava2: $("#cdufava2","#frmDadosLimiteDscTit").val(),
			nrfonav2: $("#nrfonav2","#frmDadosLimiteDscTit").val(),
			emailav2: $("#emailav2","#frmDadosLimiteDscTit").val(),
			nrender2: normalizaNumero($("#nrender2","#frmDadosLimiteDscTit").val()),
			complen2: $("#complen2","#frmDadosLimiteDscTit").val(),
			nrcxaps2: normalizaNumero($("#nrcxaps2","#frmDadosLimiteDscTit").val()),
			
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
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});	
}

// Validar os dados da proposta de limite
function validaLimiteDscTit(cddopcao,idconfir,idconfi2,idconfi5) {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, validando dados do limite ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite_valida_proposta.php",
		data: {
			nrdconta: nrdconta,
			nrctrlim: $("#nrctrlim","#frmDadosLimiteDscTit").val().replace(/\./g,""),
			cddopcao: cddopcao,
			dtrating: dtrating, 
			diaratin: diaratin, 
			vlrrisco: vlrrisco, 
			vllimite: $("#vllimite","#frmDadosLimiteDscTit").val().replace(/\./g,""),
			cddlinha: $("#cddlinha","#frmDadosLimiteDscTit").val(),
			inconfir: idconfir,
			inconfi2: idconfi2,
			inconfi4: 71,
			inconfi5: idconfi5,
			redirect: "html_ajax"
  	
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}			
	});
}

// Função para validar o numero de contrato
function validaNrContrato() {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, validando n&uacute;mero do contrato ...");
	
	var antnrctr = $("#antnrctr","#frmDadosLimiteDscTit").val().replace(/\./g,"");
	
	// Valida número do contrato
	if (antnrctr == "" || !validaNumero(antnrctr,true,0,0)) {
		hideMsgAguardo();
		showError("error","Confirme o n&uacute;mero do contrato.","Alerta - Ayllos","$('#antnrctr','#frmDadosLimiteDscTit').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	} 
	
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/descontos/titulos/titulos_limite_incluir_validaconfirma.php",
		data: {
			nrdconta: nrdconta,
            nrctrlim: $("#nrctrlim","#frmDadosLimiteDscTit").val().replace(/\./g,""),
			antnrctr: antnrctr,
			nrctaav1: 0,
			nrctaav2: 0,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
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
	
	var nmdaval1 = trim( $('#nmdaval1','#'+nomeForm).val() );
	var ende1av1 = trim( $('#ende1av1','#'+nomeForm).val() );
	var nrcepav1 = normalizaNumero($("#nrcepav1",'#'+nomeForm).val())
	
	var nmdaval2 = trim( $('#nmdaval2','#'+nomeForm).val() );
	var ende1av2 = trim( $('#ende1av2','#'+nomeForm).val() );
	var nrcepav2 = normalizaNumero($("#nrcepav2",'#'+nomeForm).val())
	
	$.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/atenda/descontos/titulos/titulos_avalistas_validadados.php',
		data: {
			nrdconta: nrdconta,	nrctaav1: nrctaav1,	nmdaval1: nmdaval1,	
			nrcpfav1: nrcpfav1, cpfcjav1: cpfcjav1,	ende1av1: ende1av1,	
			nrctaav2: nrctaav2,	nmdaval2: nmdaval2, nrcpfav2: nrcpfav2,	
			cpfcjav2: cpfcjav2,	ende1av2: ende1av2, cddopcao: operacao,
			nrcepav1: nrcepav1, nrcepav2: nrcepav2, redirect: 'script_ajax'
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina);');
		},
		success: function(response) {
			try {
				eval(response);				
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. ' + error.message,'Alerta - Ayllos','bloqueiaFundo(divRotina);');
			}
		}				
	});
}

function controlaLupas(nrdconta) {

	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmDadosLimiteDscTit';
		
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
					bo			= 'b1wgen0030.p';
					procedure	= 'lista-linhas-desc-tit';
					titulo      = 'Linhas de Desconto de T&iacute;tulo';
					qtReg		= '5';
					filtros 	= 'C&oacutedigo;cddlinha;30px;S;0|Descr;cddlinh2;100px;S;;N;|Taxa;txmensal;100px;S;;N;codigo;|Conta;nrdconta;100px;S;' + nrdconta + ';N;codigo;';
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
		
		buscaDescricao('b1wgen0030.p','lista-linhas-desc-tit','Linhas de Desconto de T&iacute;tulo',$(this).attr('name'),'cddlinh2',$(this).val(),'dsdlinha',filtrosDesc,nomeFormulario);
		return false;
	});	
	
	$('#cddlinha','#'+nomeFormulario).unbind('keypress').bind('keypress',function(e) {		
		
		if(e.keyCode == 13){
		
			//Adiciona filtro por conta para a Procedure
			var filtrosDesc = 'nrdconta|'+ nrdconta;
			
			buscaDescricao('b1wgen0030.p','lista-linhas-desc-tit','Linhas de Desconto de T&iacute;tulo',$(this).attr('name'),'cddlinh2',$(this).val(),'dsdlinha',filtrosDesc,nomeFormulario);
						
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
			redirect: 'html_ajax'
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
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
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
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
		url: UrlSite + "telas/atenda/descontos/titulos/titulos_restricoes.php",
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
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divOpcoesDaOpcao2").html(response);
		}				
	});		
}

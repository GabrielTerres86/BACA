/*!
 * FONTE        : cheques.php
 * CRIAÇÃO      : Guilherme
 * DATA CRIAÇÃO : Março/2009
 * OBJETIVO     : Biblioteca de funções da subrotina de Descontos de cheques
 * --------------
 * ALTERAÇÕES   : 18/11/2016
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
 */
 
var contWin    = 0;  // Variável para contagem do número de janelas abertas para impressos
var nrcontrato = ""; // Variável para armazenar número do contrato de descto selecionado
var nrbordero = ""; // Variável para armazenar número do bordero de descto selecionado
var situacao_limite = ""; // Variável para armazenar a situação do limite atualmente selecionado
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


var aux_inconfir = ""; /*Variável usada para controlar validações que serão realizadas dentro das ptocedures valida_proposta, efetua_liber_anali_bordero.*/
var aux_inconfi2 = ""; /*Variável usada para controlar validações que serão realizadas dentro das ptocedures valida_proposta, efetua_liber_anali_bordero.*/
var aux_inconfi3 = ""; /*Variável usada para controlar validações que serão realizadas dentro das ptocedures valida_proposta, efetua_liber_anali_bordero.*/
var aux_inconfi4 = ""; /*Variável usada para controlar validações que serão realizadas dentro das ptocedures valida_proposta, efetua_liber_anali_bordero.*/
var aux_inconfi5 = ""; /*Variável usada para controlar validações que serão realizadas dentro das ptocedures valida_proposta, efetua_liber_anali_bordero.*/
var aux_inconfi6 = ""; /*Variável usada para controlar validações que serão realizadas dentro das ptocedures valida_proposta, efetua_liber_anali_bordero.*/



// ALTERAÇÃO 001: Carrega biblioteca javascript referente aos AVALISTAS
$.getScript(UrlSite + 'includes/avalistas/avalistas.js');

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
function selecionaBorderoCheques(id,qtBorderos,bordero,contrato) {
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
			idLinhaB  = id;		
		}

	}
}

// OPÇÕES CONSULTA/EXCLUSÃO/IMPRIMIR/LIBERAÇÃO/ANÁLISE
// Mostrar dados do border&ocirc; para fazer
function mostraDadosBorderoDscChq(opcaomostra) {
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
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divOpcoesDaOpcao3").html(response);
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
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divOpcoesDaOpcao4").html(response);
		}				
	});		
}

// OPÇÃO EXCLUIR
// Função para excluir um bordero de desconto de cheques
function excluirBorderoDscChq() {
	
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
// Função para mostrar a opção Imprimir dos borderos de desconto de cheques
function mostraImprimirBordero(){
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
		imprimirRating(false,2,nrcontrato,"divOpcoesDaOpcao3",fnfinish);
		return;		
	}				
	
	$("#nrdconta","#frmImprimir").val(nrdconta);
	$("#idimpres","#frmImprimir").val(idimpres);
	$("#flgemail","#frmImprimir").val(flgemail);
	$("#nrctrlim","#frmImprimir").val(nrcontrato);
	$("#nrborder","#frmImprimir").val(nrbordero);		
	$("#limorbor","#frmImprimir").val(limorbor);
	
	var action = $("#frmImprimir").attr("action");
	var callafter = "blockBackground(parseInt($('#divRotina').css('z-index')));";
	
	carregaImpressaoAyllos("frmImprimir",action,callafter);
	
}

// OPÇÃO LIBERAR
// Liberar/Analisar border&ocirc; de desconto de cheques
function liberaAnalisaBorderoDscChq(opcao,idconfir,idconfi2,idconfi3,idconfi4,idconfi5,idconfi6,indentra,indrestr){

    var nrcpfcgc = $("#nrcpfcgc","#frmCabAtenda").val().replace(".","").replace(".","").replace("-","").replace("/","");
    var mensagem = '';
    var cdopcoan = 0;
    var cdopcolb = 0;
	
	// Mostra mensagem de aguardo
	if (opcao == "N"){
		mensagem = "analisando";
        cdopcoan = glb_codigoOperadorLiberacao;
	}else{
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
function selecionaLimiteCheques(id,qtLimites,limite,dssitlim) {
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
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divOpcoesDaOpcao3").html(response);
		}				
	});
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
// Carregar os dados para consulta de limite de desconto de cheques
function carregaDadosConsultaLimiteDscChq() {
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
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divOpcoesDaOpcao3").html(response);		
			$("#divConteudoOpcao").css('display','none');
			controlaLupas();
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
        url: UrlSite + 'telas/atenda/descontos/cheques/cheques_limite_alterar_form.php',
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
        url: UrlSite + 'telas/atenda/descontos/cheques/numero.php',
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
    carregaLimitesCheques();
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
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divOpcoesDaOpcao3").html(response);
			controlaLupas();
		}				
	});
		
}

// Função para gravar dados do limite de desconto de cheques
function gravaLimiteDscChq(cddopcao) {

	var nrcpfcgc = $("#nrcpfcgc","#frmCabAtenda").val().replace(".","").replace(".","").replace("-","").replace("/","");
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, efetuando " + (cddopcao == "A" ? "altera&ccedil;&atilde;o" : "inclus&atilde;o") + " do limite ...");
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
			vloutras: $("#vloutras","#frmDadosLimiteDscChq").val().replace(/\./g,""),
			vlsalari: $("#vlsalari","#frmDadosLimiteDscChq").val().replace(/\./g,""),
			vlsalcon: $("#vlsalcon","#frmDadosLimiteDscChq").val().replace(/\./g,""),
			dsdbens1: $("#dsdbens1","#frmDadosLimiteDscChq").val(),
			dsdbens2: $("#dsdbens2","#frmDadosLimiteDscChq").val(),            
			cddlinha: $("#cddlinha","#frmDadosLimiteDscChq").val(),
			dsobserv: removeCaracteresInvalidos(removeAcentos($("#dsobserv","#frmDadosLimiteDscChq").val())),
			qtdiavig: $("#qtdiavig","#frmDadosLimiteDscChq").val().replace(/dias/,""),
			
			// 1o. Avalista 
			nrctaav1: normalizaNumero($("#nrctaav1","#frmDadosLimiteDscChq").val()),
			nmdaval1: $("#nmdaval1","#frmDadosLimiteDscChq").val(),
			nrcpfav1: normalizaNumero($("#nrcpfav1","#frmDadosLimiteDscChq").val()),
			tpdocav1: $("#tpdocav1","#frmDadosLimiteDscChq").val(),
			dsdocav1: $("#dsdocav1","#frmDadosLimiteDscChq").val(),
			nmdcjav1: $("#nmdcjav1","#frmDadosLimiteDscChq").val(),
			cpfcjav1: normalizaNumero($("#cpfcjav1","#frmDadosLimiteDscChq").val()),
			tdccjav1: $("#tdccjav1","#frmDadosLimiteDscChq").val(),
			doccjav1: $("#doccjav1","#frmDadosLimiteDscChq").val(),
			ende1av1: $("#ende1av1","#frmDadosLimiteDscChq").val(),
			ende2av1: $("#ende2av1","#frmDadosLimiteDscChq").val(),
			nrcepav1: normalizaNumero($("#nrcepav1","#frmDadosLimiteDscChq").val()),
			nmcidav1: $("#nmcidav1","#frmDadosLimiteDscChq").val(),
			cdufava1: $("#cdufava1","#frmDadosLimiteDscChq").val(),
			nrfonav1: $("#nrfonav1","#frmDadosLimiteDscChq").val(),
			emailav1: $("#emailav1","#frmDadosLimiteDscChq").val(),
			nrender1: normalizaNumero($("#nrender1","#frmDadosLimiteDscChq").val()),
			complen1: $("#complen1","#frmDadosLimiteDscChq").val(),
			nrcxaps1: normalizaNumero($("#nrcxaps1","#frmDadosLimiteDscChq").val()),

			// 2o. Avalista 
			nrctaav2: normalizaNumero($("#nrctaav2","#frmDadosLimiteDscChq").val()),
			nmdaval2: $("#nmdaval2","#frmDadosLimiteDscChq").val(),
			nrcpfav2: normalizaNumero($("#nrcpfav2","#frmDadosLimiteDscChq").val()),
			tpdocav2: $("#tpdocav2","#frmDadosLimiteDscChq").val(),
			dsdocav2: $("#dsdocav2","#frmDadosLimiteDscChq").val(),
			nmdcjav2: $("#nmdcjav2","#frmDadosLimiteDscChq").val(),
			cpfcjav2: normalizaNumero($("#cpfcjav2","#frmDadosLimiteDscChq").val()),
			tdccjav2: $("#tdccjav2","#frmDadosLimiteDscChq").val(),
			doccjav2: $("#doccjav2","#frmDadosLimiteDscChq").val(),
			ende1av2: $("#ende1av2","#frmDadosLimiteDscChq").val(),
			ende2av2: $("#ende2av2","#frmDadosLimiteDscChq").val(),
			nrcepav2: normalizaNumero($("#nrcepav2","#frmDadosLimiteDscChq").val()),
			nmcidav2: $("#nmcidav2","#frmDadosLimiteDscChq").val(),
			cdufava2: $("#cdufava2","#frmDadosLimiteDscChq").val(),
			nrfonav2: $("#nrfonav2","#frmDadosLimiteDscChq").val(),
			emailav2: $("#emailav2","#frmDadosLimiteDscChq").val(),
			nrender2: normalizaNumero($("#nrender2","#frmDadosLimiteDscChq").val()),
			complen2: $("#complen2","#frmDadosLimiteDscChq").val(),
			nrcxaps2: normalizaNumero($("#nrcxaps2","#frmDadosLimiteDscChq").val()),
			
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
	
	var antnrctr = $("#antnrctr","#frmDadosLimiteDscChq").val().replace(/\./g,"");
	
	// Valida número do contrato
	if (antnrctr == "" || !validaNumero(antnrctr,true,0,0)) {
		hideMsgAguardo();
		showError("error","Confirme o n&uacute;mero do contrato.","Alerta - Ayllos","$('#antnrctr','#frmDadosLimiteDscChq').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	} 
	
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/atenda/descontos/cheques/cheques_limite_incluir_validaconfirma.php",
		data: {
			nrdconta: nrdconta,
            nrctrlim: $("#nrctrlim","#frmDadosLimiteDscChq").val().replace(/\./g,""),
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
					filtros 	= 'C&oacutedigo;cddlinha;30px;S;0|Descr;cddlinh2;100px;S;;N;';
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
		return false;
	});	
	
	$('#cddlinha','#'+nomeFormulario).unbind('keypress').bind('keypress',function(e) {		
		
		if(e.keyCode == 13){
		
			//Adiciona filtro por conta para a Procedure
			var filtrosDesc = 'nrdconta|'+ nrdconta;
			
			buscaDescricao('b1wgen0009.p','linha-desc-chq','Linhas de Desconto de Cheque',$(this).attr('name'),'cddlinh2',$(this).val(),'dsdlinha',filtrosDesc,nomeFormulario);
						
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
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			$("#divOpcoesDaOpcao2").html(response);
		}				
	});		
}

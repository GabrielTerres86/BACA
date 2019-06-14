//************************************************************************//
//*** Fonte: agendamento.js                                            ***//
//*** Autor: Douglas                                                   ***//
//*** Data : Setembro/2014                Última Alteração: 14/11/2014 ***//
//***                                                                  ***//
//*** Objetivo  : Biblioteca de funções da rotina Agendamento de       ***//
//***             aplicações e resgates                                ***//
//***                                                                  ***//	 
//*** Alterações: 14/10/2014 - Separar a validação e a inclusão do     ***//
//***                          agendamento(Douglas - Projeto Captação  ***//
//***                          Internet 2014/2)                        ***//
//***                                                                  ***//
//***             20/10/2014 - Adicionar função para o campo de data   ***//
//***                          inicial (Douglas - Projeto Captação     ***//
//***                          Internet 2014/2)                        ***//
//***                                                                  ***//
//***             07/11/2014 - Ajustado mensagem de exclusão do agenda ***//
//***                          mento de aplicação e de resgate         ***//
//***                          (Douglas - Projeto Captação Internet    ***//
//***                          2014/2)                                 ***//
//***                                                                  ***//
//***             14/11/2014 - Ajustado parseInt para não ocorre erro  ***//
//***                          (Douglas - Projeto Captação Internet    ***//
//***                          2014/2)                                 ***//
//***                                                                  ***//
//************************************************************************//

var lstAgendamentos = new Array(); // Variável para armazenar agendamentos da conta do cooperado
var lstDetalheAgendamento = new Array(); // Variável para armazenar os detalhes do agendamento
var agendamentoSelecionado; // Armazena o agendamento que foi selecionado
var detalheAgendamentoSelecionado; // Armazena o agendamento que foi selecionado
var arrayCarencias = new Array(); // Armazena a lista de carência
var nrctraar = 0; // Variável para armazenar número do agendamento selecionado
var documentoDetalhe = ""; // Variável para armazenar número do documento do agendamento selecionado
var dadosTela; // Variável para armazenar o valor dos campos da tela no momento da inclusão do agendamento
var mensagemConfirmacao; // Variável para armazenar o valor dos campos da tela no momento da inclusão do agendamento

/** 
 * Acessado pelo botao de agendamento. Esconde as demais divs para mostrar apenas as opcoes de agendamento
 */
function novoAgendamento(){
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando op&ccedil;&atilde;o para cadastro do agendamento ...");
	
	// Aumenta tamanho do div onde o conte&uacute;do da op&ccedil;&atilde;o ser&aacute; visualizado
	$("#divConteudoOpcao").css("height","60px");

	// Mostra div para op&ccedil;&atilde;o de resgate
	$("#divAgendamento").css("display","none");
	$("#divTipoAgendamento").css("display","block");
	// Esconde mensagem de aguardo
	hideMsgAguardo();
	blockBackground(parseInt($("#divRotina").css("z-index")));
}

/** 
 * Validacao de linha selecionada para realizar a exclusao do agendamento
 */
function excluirAgendamento(){
	if(nrctraar > 0){
		var msg = "Confirma a exclus&atilde;o do agendamento de " + agendamentoSelecionado.tipoagen.toLowerCase() + " n&uacute;mero " + nrctraar + " ?";
		showConfirmacao(msg,"Confirma&ccedil;&atilde;o - Aimaro","executaCancelamentoAgendamento()","blockBackground(parseInt($('#divRotina').css('z-index')))","sim.gif","nao.gif");
	} else {
		showError("error","Selecione o agendamento para excluir.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}
}

/** 
 * Realiza a exclusao do agendamento
 */
function executaCancelamentoAgendamento(){
	// Verificar se existe agendamento selecionado
	if (nrctraar == "" || !validaNumero(nrctraar,true,0,0)) {
		hideMsgAguardo();
		showError("error","N&uacute;mero do agendamento não identificado","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}

	// Executa script de consulta através de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/atenda/aplicacoes/agendamento_cancelar.php", 
		data: {nrdconta: nrdconta,
			   nrctraar: nrctraar,
			   redirect: "script_ajax"},
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

/** 
 * Acessa os detalhes do agendamento
 */
function detalhesAgendamento(){
	if(nrctraar > 0){
		// Mostra mensagem de aguardo
		showMsgAguardo("Aguarde, carregando os detalhes do agendamento ...");
		
		var flgtipar = (agendamentoSelecionado.flgtipar == "yes") ? 1 : 0;
		var nrdocmto = agendamentoSelecionado.nrdocmto;
		
		// Executa script de consulta através de ajax
		$.ajax({		
			type: "POST",		
			url: UrlSite + "telas/atenda/aplicacoes/agendamento_detalhar.php", 
			data: {nrdconta: nrdconta,
			       nrdocmto: nrdocmto,
		           flgtipar: flgtipar,
				   redirect: "script_ajax"}, 
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
	} else {
		showError("atencao","Selecione um agendamento para buscar os detalhes","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
	}
}

/** 
 * Voltar o agendamento
 */
function voltarAgendamento(){
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando op&ccedil;&atilde;o para cadastro do agendamento ...");
	
	// Aumenta tamanho do div onde o conte&uacute;do da op&ccedil;&atilde;o ser&aacute; visualizado
	$("#divConteudoOpcao").css("height","250px");

	// Mostra div para op&ccedil;&atilde;o de resgate
	$("#divTipoAgendamento").css("display","none");
	$("#divDetalhesAgendamento").css("display","none");
	$("#divAgendamento").css("display","block");
	// Esconde mensagem de aguardo
	hideMsgAguardo();
	blockBackground(parseInt($("#divRotina").css("z-index")));
}

/** 
 * Acessar a opcao de agendamento de aplicacao
 */
function acessaOpcaoAgendamentoAplicacao(){
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando op&ccedil;&atilde;o para cadastro do agendamento de aplica&ccedil;&atilde;o ...");
	
	// Executa script de consulta através de ajax
	$.ajax({		
		type: "POST",		
		url: UrlSite + "telas/atenda/aplicacoes/agendamento_aplicacao.php", 
		data: {nrdconta: nrdconta,
			   redirect: "script_ajax"}, 
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

/** 
 * Acessar a opcao de agendamento de resgate
 */
function acessaOpcaoAgendamentoResgate(){
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando op&ccedil;&atilde;o para cadastro do agendamento de resgate ...");

	// Executa script de consulta através de ajax
	$.ajax({		
		type: "POST",		
		url: UrlSite + "telas/atenda/aplicacoes/agendamento_resgate.php", 
		data: {nrdconta: nrdconta,
			   redirect: "script_ajax"}, 
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

/** 
 * Voltar a opcao do tipo de agendamento
 */
function voltarTipoAgendamento(){
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando op&ccedil;&atilde;o para cadastro do agendamento ...");
	
	// Aumenta tamanho do div onde o conte&uacute;do da op&ccedil;&atilde;o ser&aacute; visualizado
	$("#divConteudoOpcao").css("height","60px");

	// Mostra div para op&ccedil;&atilde;o de resgate
	$("#divAgendamento").css("display","none");
	$("#divAgendamentoAplicacao").css("display","none");
	$("#divAgendamentoResgate").css("display","none");
	$("#divTipoAgendamento").css("display","block");
	// Esconde mensagem de aguardo
	hideMsgAguardo();
	blockBackground(parseInt($("#divRotina").css("z-index")));
}

/** 
 * Habilitar os campos da tela de agendamento de aplicacao/resgate de acordo com a opcao do tipo de inclusao
 */
function habilitaCampoAgendamento(tipo,valor){
	var nameForm = "";
	// Campos e labels para tipo de agendamento mensal ou na data
	var labelMes = new Array();
	var campoMes = new Array();
	var labelData = new Array();
	var campoData = new Array();
	var bFocus = true;
	var x;
	
	// Validacao do tipo de agendamento para recuperar o formulario
	if(tipo == "R"){
		nameForm = "#frmAgendamentoResgate";
		labelMes = new Array("#label_do_mes","#label_no_dia","#label_mes");
		campoMes = new Array("#dtdiaaar","#qtmesaar");
		labelData = new Array("#label_data");
		campoData = new Array("#dtiniaar");
	   
	} else if(tipo == "A"){
		nameForm = "#frmAgendamentoAplicacao";
		labelMes = new Array("#label_do_mes","#label_no_dia","#label_mes","#label_vcto","#label_vcto_dias");
		campoMes = new Array("#dtdiaaar","#qtmesaar","#dtvendia");
		labelData = new Array("#label_data");
		campoData = new Array("#dtiniaar");
		
	} else {
		return false;
	}
	
	if(valor === undefined){
		// Se nao possuir o valor, busca o valor do campo
		valor = $("#flgtipin",nameForm).val();
		bFocus = false;
	}

	if(valor == 0){ // Opcao de agendamento na data
		// Desabilitar e esconder os campos do mes
		for (x in labelMes) {
			$(labelMes[x],nameForm).hide();
		}
		for (x in campoMes) {
			$(campoMes[x],nameForm).hide();
			$(campoMes[x],nameForm).attr('disabled','disabled');
		}

		// Habilitar e mostrar os campos do dia
		for (x in labelData) {
			$(labelData[x],nameForm).show();
		}
		for (x in campoData) {
			$(campoData[x],nameForm).show();
			$(campoData[x],nameForm).removeAttr('disabled');
		}
	
		if (bFocus) {
			$("#dtiniaar",nameForm).focus();
		}
	
	}else{ // Opcao de agendamento mensal
		// Desabilitar e esconder os campos do dia
		for (x in labelData) {
			$(labelData[x],nameForm).hide();
		}
		for (x in campoData) {
			$(campoData[x],nameForm).hide();
			$(campoData[x],nameForm).attr('disabled','disabled');
		}
		
		// Habilitar e mostrar os campos do mes
		for (x in labelMes) {
			$(labelMes[x],nameForm).show();
		}
		for (x in campoMes) {
			$(campoMes[x],nameForm).show();
			$(campoMes[x],nameForm).removeAttr('disabled');
		}
		
		if (bFocus) {
			$("#dtdiaaar",nameForm).focus();
		}
		
	}

	return false;
}

/** 
 * Validacao do numero do dia do agendamento
 */
function validaQtdDias(valor,tipo){
	// Validacao do dia para nao ser maior que o dia 28 ou menor que o dia 1
	if(valor > 28 || valor < 1){
		if(tipo == "R"){
			showError("atencao","Agendamento permitido apenas at&eacute; o dia 28 de cada m&ecirc;s!","Alerta - Aimaro","$(\"#dtdiaaar\",\"#frmAgendamentoResgate\").focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
		} else if(tipo == "A"){
			showError("atencao","Agendamento permitido apenas at&eacute; o dia 28 de cada m&ecirc;s!","Alerta - Aimaro","$(\"#dtdiaaar\",\"#frmAgendamentoAplicacao\").focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
		}
		return false;
	}	
	
	return true;
}

/** 
 * Formatacao da tabela de agendamentos
 */
function formataTabelaAgendamentos() {

	$("#divConteudoOpcao").css("height","250px");
	
	// tabela	
	var divRegistro = $('div.divRegistros', '#divAgendamento');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'170px'});
	
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];
	
	// Definicao do tamanho das colunas da tabela
	var arrayLargura = new Array();
	arrayLargura[0] = '60px';   // numero
	arrayLargura[1] = '70px';   // tipo
	arrayLargura[2] = '60px';	// parcela
	arrayLargura[3] = '160px';	// valor

	// Definicao do alinhamento do valor das colunas da tabela
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';   // numero
	arrayAlinha[1] = 'center';  // tipo
	arrayAlinha[2] = 'center';  // parcela
	arrayAlinha[3] = 'right';   // valor
	arrayAlinha[4] = 'center';  // data proximo lancamento
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha );
}

/** 
 * Selecionar um agendamento e guardar as informacoes
 */
function selecionaAgendamento(indice) {	
	agendamentoSelecionado = lstAgendamentos[indice];
	// Armazena número da aplicação selecionada
	nrctraar = retiraCaracteres(agendamentoSelecionado.nrctraar,"0123456789",true);
}

/** 
 * Recarrega as informacoes do agendamento
 */
function recarregaAgendamento() {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando agendamentos do associado ...");
	acessaOpcaoAgendamento();
}

/** 
 * Validacao para inclusao do agendamento de resgate
 */
function confirmarAgendamentoResgate(){
	var vlparaar = $("#vlparaar","#frmAgendamentoResgate").val().replace(/\./g,"");
	var flgtipin = $("#flgtipin","#frmAgendamentoResgate").val();
	var dtiniaar = $("#dtiniaar","#frmAgendamentoResgate").val();
	var dtdiaaar = $("#dtdiaaar","#frmAgendamentoResgate").val();
	var qtmesaar = $("#qtmesaar","#frmAgendamentoResgate").val();
	
	if (vlparaar == "" || !validaNumero(vlparaar,true,0,0)) {
		hideMsgAguardo();
		showError("error","Valor inv&aacute;lido.","Alerta - Aimaro","$('#vlparaar','#frmAgendamentoResgate').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");			
		return false;
	}
	
	if (flgtipin < 0 || flgtipin > 1) {
		hideMsgAguardo();
		showError("error","Car&ecirc;ncia inv&aacute;lida.","Alerta - Aimaro","$('#flgtipin','#frmAgendamentoResgate').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}
	
	if(flgtipin == 0){ // Tipo de carência = UNICA
		if (dtiniaar == "" || !validaData(dtiniaar)) {
			hideMsgAguardo();
			showError("error","Data inv&aacute;lida.","Alerta - Aimaro","$('#dtiniaar','#frmAgendamentoResgate').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
			return false;
		}
	} else { // Tipo de carência = MENSAL
		if (dtdiaaar == "" || !validaNumero(dtdiaaar,true,0,0)) {
			hideMsgAguardo();
			showError("error","Dia inv&aacute;lido.","Alerta - Aimaro","$('#dtdiaaar','#frmAgendamentoResgate').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");			
			return false;
		}
		
		// Validar se o dia á válido
		if (!validaQtdDias(dtdiaaar,"R")){ 
			return false;
		}
		
		if (qtmesaar == "" || !validaNumero(qtmesaar,true,0,0)) {
			hideMsgAguardo();
			showError("error","Quantidade de meses inv&aacute;lido.","Alerta - Aimaro","$('#qtmesaar','#frmAgendamentoResgate').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");			
			return false;
		}

		// Validar a quantidade de meses do agendamento
		if (!validaQtdMeses("R")){ 
			return false;
		}
	}
	
	// Monta o parametro com as informacoes da tela para que seja enviado na confirmacao
	dadosTela = { nrdconta: nrdconta,
	              vlparaar: vlparaar,
	              flgtipin: flgtipin,
	              dtiniaar: dtiniaar,
	              dtdiaaar: dtdiaaar,
	              qtmesaar: qtmesaar,
	              qtdiaven: 0,
	              flgtipar: 1, /* Tipo de Agendamento = 1 (Resgate) */
		          redirect: "script_ajax" 
				};
	
	// Abre a confirmacao para o usuario
	mensagemConfirmacao = "Confirma a inclus&atilde;o do agendamento de resgate?";
	validarNovoAgendamento();
}

/** 
 * Validacao para incluir o agendamento de aplicacao
 */
function confirmarAgendamentoAplicacao(){
	var vlparaar = $("#vlparaar","#frmAgendamentoAplicacao").val().replace(/\./g,"");
	var flgtipin = $("#flgtipin","#frmAgendamentoAplicacao").val();
	var dtiniaar = $("#dtiniaar","#frmAgendamentoAplicacao").val();
	var dtdiaaar = $("#dtdiaaar","#frmAgendamentoAplicacao").val();
	var qtmesaar = $("#qtmesaar","#frmAgendamentoAplicacao").val();
	var qtdiacar = $("#qtdiacar","#frmAgendamentoAplicacao").val();
	var dtvencto = $("#dtvencto","#frmAgendamentoAplicacao").val();
	var qtdiaven = arrayCarencias[qtdiacar];
	
	if (vlparaar == "" || !validaNumero(vlparaar,true,0,0)) {
		hideMsgAguardo();
		showError("error","Valor inv&aacute;lido.","Alerta - Aimaro","$('#vlparaar','#frmAgendamentoAplicacao').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");			
		return false;
	}
	
	if (flgtipin < 0 || flgtipin > 1) {
		hideMsgAguardo();
		showError("error","Tipo de aplica&ccedil;&atilde;o inv&aacute;lida.","Alerta - Aimaro","$('#flgtipin','#frmAgendamentoAplicacao').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}
	
	if(flgtipin == 0){ // Tipo de aplicacao = UNICA
		if (dtiniaar == "" || !validaData(dtiniaar)) {
			hideMsgAguardo();
			showError("error","Data inv&aacute;lida.","Alerta - Aimaro","$('#dtiniaar','#frmAgendamentoAplicacao').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
			return false;
		}
	} else { // Tipo de carência = MENSAL
		if (dtdiaaar == "" || !validaNumero(dtdiaaar,true,0,0)) {
			hideMsgAguardo();
			showError("error","Dia inv&aacute;lido.","Alerta - Aimaro","$('#dtdiaaar','#frmAgendamentoAplicacao').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");			
			return false;
		}
		
		// Validar se o dia á válido
		if (!validaQtdDias(dtdiaaar,"A")){ 
			return false;
		}
		
		if (qtmesaar == "" || !validaNumero(qtmesaar,true,0,0)) {
			hideMsgAguardo();
			showError("error","Quantidade de meses inv&aacute;lido.","Alerta - Aimaro","$('#qtmesaar','#frmAgendamentoAplicacao').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");			
			return false;
		}
		
		if (!validaQtdMeses("A")){ 
			return false;
		}
	}

	
	if (qtdiacar == "" || !validaNumero(qtdiacar,true,0,0)) {
		hideMsgAguardo();
		showError("error","Car&ecirc;ncia inv&aacute;lida.","Alerta - Aimaro","$('#qtmesaar','#frmAgendamentoAplicacao').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");			
		return false;
	}
	
	if (dtvencto == "" || !validaData(dtvencto)) {
		hideMsgAguardo();
		showError("error","Data de vencimento inv&aacute;lida.","Alerta - Aimaro","$('#dtvencto','#frmAgendamentoAplicacao').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}

	if (typeof qtdiaven === "undefined" || !validaNumero(qtdiaven,true,0,0)) {
		hideMsgAguardo();
		showError("error","Quantidade de dias de vencimento inv&aacute;lido.","Alerta - Aimaro","$('#qtmesaar','#frmAgendamentoAplicacao').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");			
		return false;
	}
	
	//Monta os dados dos campos de agendamento de aplicacao
	dadosTela = { nrdconta: nrdconta,
	              vlparaar: vlparaar,
	              flgtipin: flgtipin,
	              dtiniaar: dtiniaar,
	              dtdiaaar: dtdiaaar,
	              qtmesaar: qtmesaar,
	              qtdiacar: qtdiacar,
	              dtvencto: dtvencto,
				  qtdiaven: qtdiaven,
	              flgtipar: 0, /* Tipo de Agendamento = 0 (Aplicação) */
		          redirect: "script_ajax" 
				};
	
	//Abre a tela de confirmacao para o usuario
	mensagemConfirmacao = "Confirma a inclus&atilde;o do agendamento de aplica&ccedil;&atilde;o?";
	validarNovoAgendamento();
}

/** 
 * Inclusao do agendamento
 */
function incluirAgendamento(){
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, gravando novo agendamento ...");

	// Executa script de consulta através de ajax
	$.ajax({		
		type: "POST",		
		url: UrlSite + "telas/atenda/aplicacoes/agendamento_cadastrar.php", 
		data: dadosTela, 
		error: function(objAjax,responseError,objExcept) {
			dadosTela = {};
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			dadosTela = {};
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}
	});	
}

/**
* Funcao para montar a data de vencimento do primeiro agendamento quando o tipo for mensal
*/
function montaDataVencimento(){

	var flgtipin = $("#flgtipin","#frmAgendamentoAplicacao").val();
	var dtiniaar = $("#dtiniaar","#frmAgendamentoAplicacao").val();
	var dtdiaaar = $("#dtdiaaar","#frmAgendamentoAplicacao").val();
	var dtmvtolt = $("#dtmvtolt","#frmAgendamentoAplicacao").val();
    var novaData;

	if(flgtipin == 0){ // Tipo de aplicacao = UNICA
		if (dtiniaar == "" || !validaData(dtiniaar)){
			return false;
		}
		novaData = dtiniaar;
		
	} else { // Tipo de carência = MENSAL
		if (dtdiaaar == "" || !validaNumero(dtdiaaar,true,0,0)) {
			return false;
		}
		
		// Validar se o dia e válido
		if (!validaQtdDias(dtdiaaar,"A")){ 
			return false;
		}
		
		var data = dtmvtolt.split("/");
		var dia = parseInt(data[0],10);
		var mes = parseInt(data[1],10);
		var ano = parseInt(data[2],10);
		
		// Verificar se o dia que vai iniciar as aplicações é maior que o dia atual
		if ( dtdiaaar > dia ){
			// atualizamos apenas o dia
			dia = dtdiaaar;
		} else {
			// se o dia de inicio é menor, temos que atualizar todos os elementos da data
			// atualizar o dia
			dia = dtdiaaar;
			// Verificar se é o último mês do ano
			if ( mes == 12 ){
				// Atualiza para o primeiro mês e incrementa o ano
				mes = 1;
				ano = ano + 1;
			} else {
				// incrementa apenas o mês
				mes = mes + 1;
			}
		}
		//Montar a nova data de vencimento
		novaData  = (dia < 10) ? "0" + dia.toString() : dia.toString();
		novaData += "/";
		novaData += (mes < 10) ? "0" + mes.toString() : mes.toString();
		novaData += "/" + ano.toString();
	}
	return novaData;
}

/**
* Funcao para pegar data de vencimento de acordo com o dia de carencia
*/ 
function getDataVencto(){
	var qtdiacar = $("#qtdiacar","#frmAgendamentoAplicacao").val();
	var dtparam  = montaDataVencimento();
	var qtdiaapl = arrayCarencias[qtdiacar];

	if(dtparam === false){
		return false;
	}

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, calculando data de vencimento do agendamento de aplica&ccedil;&atilde;o ...");
	
	// Executa script de consulta através de ajax
	$.ajax({		
		type: "POST",		
		url: UrlSite + "telas/atenda/aplicacoes/soma_data_vencto.php", 
		data: {nrdconta: nrdconta,
		       qtdiacar: qtdiaapl,
			   dtiniaar: dtparam}, 
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

/** 
 * Atualiza a data de vencimento do agendamento
 */
function setDataVenctoAgendamento(dtvencto){
	$("#dtvencto","#frmAgendamentoAplicacao").val(dtvencto);
}

/** 
 * Busca a diferenca entre as datas de vencimento e data de inicio do agendamento
 */
function getIntervaloDias(){
	var dtvencto = $("#dtvencto","#frmAgendamentoAplicacao").val();
	var flgtipin = $("#flgtipin","#frmAgendamentoAplicacao").val();
	
	// O campo de dias de vencimento não é mostrado quando o tipo de agendamento é UNICO
	// por isso não busca o intervalo de dias 
	if( flgtipin == 0 ){ // Tipo de aplicacao = UNICA
		return false;
	}

	// Buscar a data de acordo com o tipo.
	// Se for mensal deve-se montar uma data, caso contrario a data informada na tela
	var dtparam = montaDataVencimento();
	
	if(dtparam === false){
		return false;
	}
	
	if (dtvencto == "" || !validaData(dtvencto)){
		return false;
	}
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, calculando data de vencimento do agendamento de aplica&ccedil;&atilde;o ...");
	
	// Executa script de consulta através de ajax
	$.ajax({		
		type: "POST",		
		url: UrlSite + "telas/atenda/aplicacoes/busca_intervalo_dias.php", 
		data: {nrdconta: nrdconta,
		       dtiniitr: dtparam ,
			   dtfinitr: dtvencto}, 
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

/** 
 * Atualiza a diferenca de dias entre o vencimento e o inicio do agendamento
 */
function setDiasVencimento(dtvendia){
	$("#dtvendia","#frmAgendamentoAplicacao").val(dtvendia);
}

/** 
 * Validacao para que a quantidade de meses do agendamento nao seja maior que a quantidade definida pela PA
 */
function validaQtdMeses(tipo){
	var formulario = (tipo == 'A') ? "#frmAgendamentoAplicacao" : "#frmAgendamentoResgate";
	var valor  = parseInt($("#qtmesaar",formulario).val(),10);
	var qtdMes = parseInt($("#qtmesage",formulario).val(),10);
	
	if(valor > qtdMes || valor < 1){
		var msg = "Quantidade de meses invalida! Quantidade maxima permitida no PA: " + qtdMes;
	    if (tipo == 'A') {
			showError("atencao",msg,"Alerta - Aimaro","$(\"#qtmesaar\",\"#frmAgendamentoAplicacao\").focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
		} else {
			showError("atencao",msg,"Alerta - Aimaro","$(\"#qtmesaar\",\"#frmAgendamentoResgate\").focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
		}
		return false;
	}
	
	return true;
}


function formataTabelaDetalhesAgendamento(){
	$("#divConteudoOpcao").css("height","250px");
	
	// tabela	
	var divRegistro = $('div', '#divDetalhesAgendamento');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'170px'});
	
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];
	
	// Definicao do tamanho das colunas da tabela
	var arrayLargura = new Array();
	arrayLargura[0] = '70px';   // Tipo
	arrayLargura[1] = '70px';   // Data
	arrayLargura[2] = '150px';	// Documento
	arrayLargura[3] = '100px';	// Valor
	

	// Definicao do alinhamento do valor das colunas da tabela
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';   // Tipo
	arrayAlinha[1] = 'left';    // Data
	arrayAlinha[2] = 'center';  // Documento
	arrayAlinha[3] = 'right';   // Valor
	arrayAlinha[4] = 'center';  // Situacao
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha );
}

/** 
 * Selecionar um agendamento e guardar as informacoes
 */
function selecionaDetalheAgendamento(indice) {
	detalheAgendamentoSelecionado = lstDetalheAgendamento[indice];
	// Armazena número da aplicação selecionada
	documentoDetalhe = detalheAgendamentoSelecionado.nrdocmto;
}


/** 
 * Validacao de linha selecionada para realizar a exclusao do detalhe do agendamento
 */
function excluirDetalheAgendamento(){
	if (documentoDetalhe == ""){
		// Se nao possuir documento selecionado, exibe erro
		showError("error","Selecione o detalhe de agendamento para excluir.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}
	
	// Verificar se a situacao do agendamento esta pendente
	if (detalheAgendamentoSelecionado.insitlau == "1") {
		var msg  = "Confirma a exclus&atilde;o do detalhe do agendamento de " + detalheAgendamentoSelecionado.dsdtipar.toLowerCase();
			msg += ", documento n&uacute;mero " + documentoDetalhe + " ?";
		showConfirmacao(msg,"Confirma&ccedil;&atilde;o - Aimaro","executaCancelamentoDetalheAgendamento()","blockBackground(parseInt($('#divRotina').css('z-index')))","sim.gif","nao.gif");
	} else {
		var msg  = "O detalhe de agendamento de " + detalheAgendamentoSelecionado.dsdtipar.toLowerCase();
		    msg += " n&atilde;o pode ser exclu&iacute;do, pois est&aacute; com a situa&ccedil;&atilde;o diferente de pendente.";
		showError("error",msg,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}
}

/** 
 * Realiza a exclusao do detalhe do agendamento
 */
function executaCancelamentoDetalheAgendamento(){
	// Verificar se existe agendamento selecionado
	if (documentoDetalhe == "" ) {
		hideMsgAguardo();
		showError("error","N&uacute;mero do documento do agendamento não identificado.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, excluindo detalhe do agendamento ...");
	
	// Executa script de consulta através de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/atenda/aplicacoes/agendamento_excluir_detalhe.php", 
		data: detalheAgendamentoSelecionado,
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

/**
* Funcao para recarregar as informacoes do agendamento, quando voltar da tela de detalhes do agendamento
*/
function voltarAgendamentoDetalhes(){
	recarregaAgendamento();
}

/** 
 * Validacao de linha selecionada para realizar a exclusao do detalhe do agendamento
 */
function excluirTodosDetalhesAgendamento(){
	var bExcluir = false;
	
	for (var x in lstDetalheAgendamento){
		if ( lstDetalheAgendamento[x].insitlau == "1" ){
			bExcluir = true;
		}
	}
	
	if ( !bExcluir ) {
		showError("error","N&atilde;o existe detalhamento pendente para excluir.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}
	
	var msg  = "Confirma a exclus&atilde;o de todos os detalhes do agendamento de " + agendamentoSelecionado.tipoagen.toLowerCase();
		msg += " n&uacute;mero " + agendamentoSelecionado.nrctraar + " que ainda est&atilde;o pendentes?";
	showConfirmacao(msg,"Confirma&ccedil;&atilde;o - Aimaro","executaExclusaoTodosDetalhesAgendamento()","blockBackground(parseInt($('#divRotina').css('z-index')))","sim.gif","nao.gif");
}

/** 
 * Realiza a exclusao do detalhe do agendamento
 */
function executaExclusaoTodosDetalhesAgendamento(){
	var detagend = "";
	for (var x in lstDetalheAgendamento){
		if ( lstDetalheAgendamento[x].insitlau == "1" ){
			if( detagend != "" ){
				detagend += "|";
			}
			
			detagend += lstDetalheAgendamento[x].flgtipar + ";" + lstDetalheAgendamento[x].nrdocmto;
		}
	}

	if ( detagend == "" ) {
		showError("error","N&atilde;o existe detalhamento pendente para excluir.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
		return false;
	}

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, excluindo todos os detalhes do agendamento ...");
	
	// Executa script de consulta através de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/atenda/aplicacoes/agendamento_excluir_todos_detalhes.php", 
		data: {nrdconta: nrdconta,
			   detagend: detagend,
			   redirect: "script_ajax"},
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

function solicitarConfirmacaoInclusao(){
	hideMsgAguardo();
	showConfirmacao(mensagemConfirmacao,"Confirma&ccedil;&atilde;o - Aimaro","incluirAgendamento()","blockBackground(parseInt($('#divRotina').css('z-index')))","sim.gif","nao.gif");
}

/** 
 * Validar novo agendamento
 */
function validarNovoAgendamento(){
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, validando os dados para cadastro do agendamento ...");

	// Executa script de consulta através de ajax
	$.ajax({		
		type: "POST",		
		url: UrlSite + "telas/atenda/aplicacoes/agendamento_validar.php", 
		data: dadosTela, 
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


function onBlurDiaAgendamentoAplica(){
	validaQtdDias(this.value,"A");
	getDataVencto();
}
/*!
 * FONTE        : cadcon.js
 * CRIA��O      : Heitor Augusto Schmitt (RKAM)
 * DATA CRIA��O : 08/10/2015
 * OBJETIVO     : Biblioteca de fun��es da tela CADCON
 * --------------
 * ALTERA��ES   :
 * --------------
 */

var flgVoltarGeral = 1;

$(document).ready(function() {
	// Estado Inicial da tela
	estadoInicial();
	formataTabCad();
	formataTabCon();
	formataTabAge();
	formataTabAlt(1);
	formataTabTrf(1);
});

function estadoInicial(){
	//Voltar para a tela principal
	flgVoltarGeral = 1;

	$("#divTela").fadeTo(0,0.1);

	hideMsgAguardo();
	//Formata��o do cabe�alho

	formataCabecalho();
	//Formata��o da tela de Cadastro de Consultores
	formataCadastroConsultor();
	// Formatar a Altera��o de Consultores
	formataAlteracaoConsultor();
	// Formatar a Transfer�ncia de Consultores
	formataTransferenciaConsultor();

	removeOpacidade("divTela");

	highlightObjFocus( $("#frmCab") );

	//Exibe cabe�alho e define tamanho da tela
	$("#frmCab").css({"display":"block"});
	$("#divTela").css({"width":"700px","padding-bottom":"2px"});

	$("#divCadastroConsultor").css({"display":"none"});
	$("#divConsultaConsultor").css({"display":"none"});
	$("#divAlteracaoConsultor").css({"display":"none"});
	$("#divTransferenciaConsultor").css({"display":"none"});

	//Esconder os bot�es da tela
	$("#divBotoes").css({"display":"none"});

	//Foca o campo da Op��o
	$("#cddotipo","#frmCab").focus();
}

function formataCabecalho() {
	// rotulo
	$('label[for="cddotipo"]',"#frmCab").addClass("rotulo").css({"width":"100px"}); 
	
	// campo
	$("#cddotipo","#frmCab").css("width","500px").habilitaCampo();
	
	$('input[type="text"],select','#frmCab').limpaFormulario().removeClass('campoErro');
	layoutPadrao();
	
	//Define a��o para ENTER e TAB no campo Op��o
	$("#cddotipo","#frmCab").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			//Executa fun��o do bot�o OK
			liberaFormulario();
			return false;
		}
    });	
	
	//Define a��o para CLICK no bot�o de OK
	$("#btnOK","#frmCab").unbind('click').bind('click', function() {
		liberaFormulario();
		return false;
    });	
	return false;	
}

function liberaFormulario(){
	var cddotipo = $("#cddotipo","#frmCab");

	if(cddotipo.prop("disabled")){
		// Se o campo estiver desabilitado, n�o executa a libera��o do formul�rio pois j� existe uma a��o sendo executada
		return;
	}

	if (cddotipo.val() == "I" || cddotipo.val() == "A" || cddotipo.val() == "T") {
		manterConsultor("VA","","","","");
	}

	cddotipo.desabilitaCampo();

	// Validar a op��o que foi selecionada na tela
	switch(cddotipo.val()){
		case "I": // Inclus�o
			estadoInicialCadastro();
		break;

		case "C": // Consulta
			estadoInicialConsulta();
			manterConsultor("C","","","","");
		break;

		case "A": // Altera��o
			estadoInicialAlteracao();
		break;

		case "T": //Transfer�ncia
			estadoInicialTransferencia();
		break;

		default:
			estadoInicial();
		break;
	}
}

function controlaVoltar(){
	estadoInicial();
}

function controlaConcluir(){
	switch($("#cddotipo","#frmCab").val()){
		case "I": // Inclus�o
			//Quando for inclus�o, solicita confirma��o
			showConfirmacao('Confirma a inclus&atilde;o do consultor?','Confirma&ccedil;&atilde;o - Ayllos','confirmouOperacaoConsultor();','','sim.gif','nao.gif');
		break;

		case "A": // Altera��o
			//Quando for altera��o, solicita confirma��o
			showConfirmacao('Confirma a altera&ccedil;&atilde;o do consultor?','Confirma&ccedil;&atilde;o - Ayllos','confirmouOperacaoConsultor();','','sim.gif','nao.gif');
		break;

		case "T": // Transfer�ncia
			//Quando for transfer�ncia, solicita confirma��o
			showConfirmacao('Confirma a transfer&ecirc;ncia do consultor?','Confirma&ccedil;&atilde;o - Ayllos','confirmouOperacaoConsultor();','','sim.gif','nao.gif');
		break;
	}
}

function ativarInativar() {
	showConfirmacao('Confirma a ativa&ccedil;&atilde;o/inativa&ccedil;&atilde;o do consultor?','Confirma&ccedil;&atilde;o - Ayllos','confirmouAtivacaoInativacaoConsultor();','','sim.gif','nao.gif');
}

/***********************************************************************************************************
									IN�CIO -> Fun��es para a tela de Consultores
***********************************************************************************************************/

function estadoInicialCadastro(){
	//Retorna para a principal
	flgVoltarGeral = 1;

	hideMsgAguardo();

	removeOpacidade("divTela");

	$("#tbCadcon > tbody").html("");
	$("#tbCadcon > thead").html("");
	$("#tbConage > tbody").html("");
	$("#tbConage > thead").html("");
	$("#tbConcon > tbody").html("");
	$("#tbConcon > thead").html("");
	$("#tbAltcon > tbody").html("");
	$("#tbAltcon > thead").html("");
	$("#tbTrfcon > tbody").html("");
	$("#tbTrfcon > thead").html("");

	$("#divCadastroConsultor").css({"display":"block"});

	//Esconde cadastro e os bot�es
	$("#divBotoes").css({"display":"block"});
	$("#btConcluir","#divBotoes").show();

	//Exibe cabe�alho e define tamanho da tela
	$("#frmCadConsultor","#divCadastroConsultor").css({"display":"block"});

	//Limpa os campos do formul�rio e remove o erro dos campos
	$('input[type="text"],select','#frmCadConsultor').limpaFormulario().removeClass('campoErro');
}

function estadoInicialConsulta(){
	//Retorna para a principal
	flgVoltarGeral = 1;
	hideMsgAguardo();
	removeOpacidade("divTela");
	
	$("#tbCadcon > tbody").html("");
	$("#tbCadcon > thead").html("");
	$("#tbConage > tbody").html("");
	$("#tbConage > thead").html("");
	$("#tbConcon > tbody").html("");
	$("#tbConcon > thead").html("");
	$("#tbAltcon > tbody").html("");
	$("#tbAltcon > thead").html("");
	$("#tbTrfcon > tbody").html("");
	$("#tbTrfcon > thead").html("");

	$("#divConsultaConsultor").css({"display":"block"});

	//Esconde cadastro e os bot�es
	$("#divBotoes").css({"display":"block"});
	
	//Exibe cabe�alho e define tamanho da tela
	$("#frmConConsultor","#divConsultaConsultor").css({"display":"block"});
	
	// Esconder o bot�o de Concluir
	$("#btConcluir","#divBotoes").hide();
	
	//Limpa os campos do formul�rio e remove o erro dos campos
	$('input[type="text"],select','#frmConConsultor').limpaFormulario().removeClass('campoErro');
}

function estadoInicialAlteracao(){
	//Retorna para a principal
	flgVoltarGeral = 1;

	hideMsgAguardo();

	removeOpacidade("divTela");

	$("#tbCadcon > tbody").html("");
	$("#tbCadcon > thead").html("");
	$("#tbConage > tbody").html("");
	$("#tbConage > thead").html("");
	$("#tbConcon > tbody").html("");
	$("#tbConcon > thead").html("");
	$("#tbAltcon > tbody").html("");
	$("#tbAltcon > thead").html("");
	$("#tbTrfcon > tbody").html("");
	$("#tbTrfcon > thead").html("");

	$("#divAlteracaoConsultor").css({"display":"block"});

	//Esconde cadastro e os bot�es
	$("#divBotoes").css({"display":"block"});
	$("#btConcluir","#divBotoes").show();

	//Exibe cabe�alho e define tamanho da tela
	$("#frmAltConsultor","#divAlteracaoConsultor").css({"display":"block"});

	//Limpa os campos do formul�rio e remove o erro dos campos
	$('input[type="text"],select','#frmAltConsultor').limpaFormulario().removeClass('campoErro');
	$("#cdconsultor","#frmAltConsultor").habilitaCampo();
}

function estadoInicialTransferencia(){
	//Retorna para a principal
	flgVoltarGeral = 1;

	hideMsgAguardo();

	removeOpacidade("divTela");

	$("#tbCadcon > tbody").html("");
	$("#tbCadcon > thead").html("");
	$("#tbConage > tbody").html("");
	$("#tbConage > thead").html("");
	$("#tbConcon > tbody").html("");
	$("#tbConcon > thead").html("");
	$("#tbAltcon > tbody").html("");
	$("#tbAltcon > thead").html("");
	$("#tbTrfcon > tbody").html("");
	$("#tbTrfcon > thead").html("");

	$("#divTransferenciaConsultor").css({"display":"block"});

	//Esconde cadastro e os bot�es
	$("#divBotoes").css({"display":"block"});
	$("#btConcluir","#divBotoes").show();

	//Exibe cabe�alho e define tamanho da tela
	$("#frmTrfConsultor","#divTransferenciaConsultor").css({"display":"block"});

	//Limpa os campos do formul�rio e remove o erro dos campos
	$('input[type="text"],select','#frmTrfConsultor').limpaFormulario().removeClass('campoErro');
}

function formataCadastroConsultor(){
	// rotulo
	$('label[for="cdconsultor"]',"#frmCadConsultor").addClass("rotulo").css({"width":"150px"}); 
	$('label[for="cdoperador"]',"#frmCadConsultor").addClass("rotulo").css({"width":"150px"}); 
	$('label[for="nmoperador"]',"#frmCadConsultor").addClass("rotulo").css({"width":"150px"});
	$('label[for="cdagenci"]',"#frmCadConsultor").addClass("rotulo").css({"width":"150px"});
	$('label[for="tbCadcon"]',"#frmCadConsultor").addClass("rotulo").css({"width":"250px"});

	// campo
	$("#cdconsultor","#frmCadConsultor").css("width","80px").attr("maxlength","5").habilitaCampo();
	$("#cdoperador","#frmCadConsultor").addClass("alphanum").css("width","70px").attr("maxlength","10").habilitaCampo();
	$("#nmoperador","#frmCadConsultor").addClass("alphanum").css("width","300px").attr("maxlength","40").desabilitaCampo();
	$("#cdagenci","#frmCadConsultor").addClass("alphanum").css("width","70px").attr("maxlength","5").habilitaCampo();
	$("#nmextage","#frmCadConsultor").addClass("alphanum").css("width","300px").attr("maxlength","35").desabilitaCampo();

	//Define a��o para o campo de c�digo do operador
	$("#cdoperador","#frmCadConsultor").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			buscaOperadorCad();
			return false;
		}
    });

	//Define a��o para o campo de c�digo do operador
	$("#cdagenci","#frmCadConsultor").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			buscaAgenciaCad();
			return false;
		}
    });	

	return false;
}

function formataTabCad() {
	// Tabela
	var divRegistro = $("div.divRegistros", "#tabCadcon");
	var tabela      = $("table", divRegistro );
	var linha       = $("table > tbody > tr", divRegistro );

	$("#tabCadcon").css({"margin-top":"5px"});
	divRegistro.css({"height":"290px","width":"700px","padding-bottom":"2px"});

	var ordemInicial = new Array();

	//Define a largura dos campos
	var arrayLargura = new Array();
    arrayLargura[0] = "80px";
    arrayLargura[1] = "";
	arrayLargura[2] = "80px";

	//Define a posi��o dos elementos nas c�lulas da linha
    var arrayAlinha = new Array();
	arrayAlinha[0] = "right";
	arrayAlinha[1] = "left";
	arrayAlinha[2] = "center";

	//Aplica as informa��es na tabela
	$(".ordemInicial","#tabCadcon").remove();
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);
	//
	
	$('input[type="text"],select','#frmCadConsultor').limpaFormulario().removeClass('campoErro');
	layoutPadrao();
}

function formataTabCon() {
	// Tabela de Consultores
	var divRegistro = $("div.divRegistros", "#tabConcon");
	var tabela      = $("table", divRegistro );
	var linha       = $("table > tbody > tr", divRegistro );

	$("#tabCadcon").css({"margin-top":"5px"});
	divRegistro.css({"height":"290px","width":"700px","padding-bottom":"2px"});

	var ordemInicial = new Array();

	//Define a largura dos campos
	var arrayLargura = new Array();
    arrayLargura[0] = "80px";
    arrayLargura[1] = "";
    arrayLargura[2] = "80px";

	//Define a posi��o dos elementos nas c�lulas da linha
    var arrayAlinha = new Array();
	arrayAlinha[0] = "left";
	arrayAlinha[1] = "left";
	arrayAlinha[2] = "center";

	//Aplica as informa��es na tabela
	$(".ordemInicial","#tabConcon").remove();
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);

	return false;
}

function formataTabAge() {
	// Tabela de Ag�ncias
	var divRegistro = $("div.divRegistros", "#tabConage");
	var tabela      = $("table", divRegistro );
	var linha       = $("table > tbody > tr", divRegistro );

    $("#tabCadage").css({"margin-top":"5px"});
	divRegistro.css({"height":"290px","width":"700px","padding-bottom":"2px"});

	var ordemInicial = new Array();

	//Define a largura dos campos
	var arrayLargura = new Array();
    arrayLargura[0] = "80px";
    arrayLargura[1] = "";

	//Define a posi��o dos elementos nas c�lulas da linha
    var arrayAlinha = new Array();
	arrayAlinha[0] = "right";
	arrayAlinha[1] = "left";

	//Aplica as informa��es na tabela
	$(".ordemInicial","#tabConage").remove();
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);
}

function formataAlteracaoConsultor(){
	// rotulo
	$('label[for="cdconsultor"]',"#frmAltConsultor").addClass("rotulo").css({"width":"150px"});
	$('label[for="cdoperador"]',"#frmAltConsultor").addClass("rotulo").css({"width":"150px"});
	$('label[for="nmoperador"]',"#frmAltConsultor").addClass("rotulo").css({"width":"150px"});
	$('label[for="tbAlrcon"]',"#frmAltConsultor").addClass("rotulo").css({"width":"250px"});
	$('label[for="cdagenci"]',"#frmAltConsultor").addClass("rotulo").css({"width":"150px"});
	$('label[for="tbCadcon"]',"#frmAltConsultor").addClass("rotulo").css({"width":"250px"});

	// campo
	$("#cdconsultor","#frmAltConsultor").css("width","80px").attr("maxlength","5").habilitaCampo();
	$("#cdoperador","#frmAltConsultor").addClass("alphanum").css("width","70px").attr("maxlength","10").habilitaCampo();
	$("#nmoperador","#frmAltConsultor").addClass("alphanum").css("width","300px").attr("maxlength","40").desabilitaCampo();
	$("#cdagenci","#frmAltConsultor").addClass("alphanum").css("width","70px").attr("maxlength","5").habilitaCampo();
	$("#nmextage","#frmAltConsultor").addClass("alphanum").css("width","300px").attr("maxlength","35").desabilitaCampo();

	$("#cdconsultor","#frmAltConsultor").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			buscaOperadorAlt();
			return false;
		}
    });	
	
	//Define a��o para o campo de c�digo do operador
	$("#cdoperador","#frmAltConsultor").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			buscaOperadorAlteracao();
			return false;
		}
    });
	
	//Define a��o para o campo de c�digo do operador
	$("#cdagenci","#frmAltConsultor").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			buscaAgenciaAlt();
			return false;
		}
    });	

	return false;
}

function formataTabAlt(cdopcao) {
	// Tabela
	var divRegistro = $("div.divRegistros", "#tabAltcon");
	var tabela      = $("table", divRegistro );
	var linha       = $("table > tbody > tr", divRegistro );

	$("#tabAltcon").css({"margin-top":"5px"});
	divRegistro.css({"height":"290px","width":"700px","padding-bottom":"2px"});

	var ordemInicial = new Array();

	//Define a largura dos campos
	var arrayLargura = new Array();
    arrayLargura[0] = "80px";
    arrayLargura[1] = "";
	arrayLargura[2] = "80px";

	//Define a posi��o dos elementos nas c�lulas da linha
    var arrayAlinha = new Array();
	arrayAlinha[0] = "right";
	arrayAlinha[1] = "left";
	arrayAlinha[2] = "center";

	//Aplica as informa��es na tabela
	$(".ordemInicial","#tabAltcon").remove();
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);
	//
	
	if (cdopcao == 1) {
		$('input[type="text"],select','#frmAltConsultor').limpaFormulario().removeClass('campoErro');
	}
	layoutPadrao();
}

function formataTransferenciaConsultor(){
	// rotulo
	$('label[for="cdconsultororg"]',"#frmTrfConsultor").addClass("rotulo").css({"width":"150px"});
	$('label[for="cdoperadororg"]',"#frmTrfConsultor").addClass("rotulo").css({"width":"150px"});
	$('label[for="nmoperadororg"]',"#frmTrfConsultor").addClass("rotulo").css({"width":"150px"});
	$('label[for="cdconsultordst"]',"#frmTrfConsultor").addClass("rotulo").css({"width":"150px"});
	$('label[for="cdoperadordst"]',"#frmTrfConsultor").addClass("rotulo").css({"width":"150px"});
	$('label[for="nmoperadordst"]',"#frmTrfConsultor").addClass("rotulo").css({"width":"150px"});
	$('label[for="tbTrfcon"]',"#frmTrfConsultor").addClass("rotulo").css({"width":"250px"});

	// campo
	$("#cdconsultororg","#frmTrfConsultor").css("width","80px").attr("maxlength","5").habilitaCampo();
	$("#cdoperadororg","#frmTrfConsultor").addClass("alphanum").css("width","80px").attr("maxlength","10").desabilitaCampo();
	$("#nmoperadororg","#frmTrfConsultor").addClass("alphanum").css("width","350px").attr("maxlength","40").desabilitaCampo();
	$("#cdconsultordst","#frmTrfConsultor").css("width","80px").attr("maxlength","5").habilitaCampo();
	$("#cdoperadordst","#frmTrfConsultor").addClass("alphanum").css("width","80px").attr("maxlength","10").desabilitaCampo();
	$("#nmoperadordst","#frmTrfConsultor").addClass("alphanum").css("width","350px").attr("maxlength","40").desabilitaCampo();

	//Define a��o para o campo de c�digo do operador
	$("#cdconsultororg","#frmTrfConsultor").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			buscaOperadorOrigem();
			return false;
		}
    });
	
	$("#cdconsultordst","#frmTrfConsultor").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			buscaOperadorDestino();
			return false;
		}
    });
	
	return false;
}

function formataTabTrf(cdopcao) {
	// Tabela
	var divRegistro = $("div.divRegistros", "#tabTrfcon");
	var tabela      = $("table", divRegistro );
	var linha       = $("table > tbody > tr", divRegistro );

	$("#tabTrfcon").css({"margin-top":"5px"});
	divRegistro.css({"height":"290px","width":"700px","padding-bottom":"2px"});

	var ordemInicial = new Array();

	//Define a largura dos campos
	var arrayLargura = new Array();
    arrayLargura[0] = "65px";
    arrayLargura[1] = "230px";
    arrayLargura[2] = "65px";
	arrayLargura[3] = "230px";
	arrayLargura[4] = "65px";

	//Define a posi��o dos elementos nas c�lulas da linha
    var arrayAlinha = new Array();
	arrayAlinha[0] = "right";
	arrayAlinha[1] = "left";
	arrayAlinha[2] = "right";
	arrayAlinha[3] = "left";
	arrayAlinha[4] = "center";

	//Aplica as informa��es na tabela
	$(".ordemInicial","#tabTrfcon").remove();
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);
	//
	if (cdopcao == 1) {
		$('input[type="text"],select','#frmTrfConsultor').limpaFormulario().removeClass('campoErro');
	}

	layoutPadrao();
}

function confirmouOperacaoConsultor(){
	//Recupera a op��o
	var cddopcao = $("#cddotipo","#frmCab").val();
	var mensagem = "Aguarde ...";

	//Atualiza a mensagem que ser� exibida
	if(cddopcao == "I") {
		mensagem = "Aguarde, incluindo consultor ...";
	} else if (cddopcao == "A") {
		mensagem = "Aguarde, alterando consultor ...";
	} else if (cddopcao == "T") {
		mensagem = "Aguarde, transferindo contas ...";
	}

	//mostra mensagem e finaliza a opera��o
	showMsgAguardo( mensagem );	

	if (cddopcao == "I") {
		manterConsultor(cddopcao,$("#cdconsultor","#frmCadConsultor").val(),$("#cdoperador","#frmCadConsultor").val(),"","");

		$('#tbCadcon > tbody > tr').each(function() {
			manterConsultor("II",$("#cdconsultor","#frmCadConsultor").val(),"",$("td:eq(0)", $(this) ).html(),"");
		});
		
		showError('inform','Inclu&iacute;do com sucesso.','Alerta - Ayllos','estadoInicialCadastro();');
	} else if (cddopcao == "A") {
		manterConsultor("AB",$("#cdconsultor","#frmAltConsultor").val(),"","","");
		manterConsultor("AC",$("#cdconsultor","#frmAltConsultor").val(),$("#cdoperador","#frmAltConsultor").val(),"","");

		$('#tbAltcon > tbody > tr').each(function() {
			manterConsultor("AD",$("#cdconsultor","#frmAltConsultor").val(),"",$("td:eq(0)", $(this) ).html(),"");
		});
		
		showError('inform','Altera&ccedil;&atilde;o realizada com sucesso.','Alerta - Ayllos','estadoInicialAlteracao();');
	} else if (cddopcao == "T") {
		$("input[type=checkbox][name='idtransf']").each(function() {
			if(this.checked == true) {
				manterConsultor(cddopcao,$("#cdconsultordst","#frmTrfConsultor").val(),"","",this.value);
			}
		});
		
		showError('inform','Transfer&ecirc;ncia realizada com sucesso.','Alerta - Ayllos','estadoInicialTransferencia();');
	}
}

function confirmouAtivacaoInativacaoConsultor() {
	var mensagem = "Aguarde, processando ativa&ccedil;&atilde;o/inativa&ccedil;&atilde;o do consultor ...";
	manterConsultor("ATIN",$("#cdconsultor","#frmAltConsultor").val(),"","","");

	showError('inform','Ativa&ccedil;&atilde;o/inativa&ccedil;&atilde;o efetuada com sucesso.','Alerta - Ayllos','estadoInicialAlteracao();');
}

function criaLinhaConsulta(cdconsultor,dtinclus,cdoperad,nmoperad){
	// Criar a linha na tabela
	$("#tbConcon > tbody")
		.append($('<tr onclick="selecionaLinhaConsulta(this)">') // Linha
			.attr('id',"id_".concat(cdconsultor))
			.append($('<td>') // Coluna: C�digo do Consultor
				.attr('style','width: 80px; text-align:right')
				.text(cdconsultor)
			)
			.append($('<td>') // Coluna: Nome do Consultor
				.attr('style','text-align:left')
				.text(nmoperad)
			)
			.append($('<td>') // Coluna: C�digo do Consultor
				.attr('style','width: 80px; text-align:center')
				.text(dtinclus)
			)
		);
}

function criaLinhaConsultaAgencia(cdagenci,nmextage){
	// Criar a linha na tabela
	$("#tbConage > tbody")
		.append($('<tr onclick="selecionaLinhaConsultaAgencia(this)">') // Linha
			.attr('id',"id_".concat(cdagenci))
			.append($('<td>') // Coluna: C�digo da Agencia
				.attr('style','width: 80px; text-align:right')
				.text(cdagenci)
			)
			.append($('<td>') // Coluna: Nome da Agencia
				.attr('style','text-align:left')
				.text(nmextage)
			)
		);
}

function criaLinhaCadastroAgencia(cdagenci,nmextage){
	// Criar a linha na tabela
	$("#tbCadcon > tbody")
		.append($('<tr>') // Linha
			.attr('id',"id_".concat(cdagenci))
			.append($('<td>') // Coluna: C�digo da Agencia
				.attr('style','width: 80px; text-align:right')
				.text(cdagenci)
			)
			.append($('<td>') // Coluna: Nome da Agencia
				.attr('style','text-align:left')
				.text(nmextage)
			)
			.append($('<td>') // Coluna: Bot�o para REMOVER
				.attr('style','width: 80px; text-align:center')
				.append($('<img onclick="excluirLinhaAgencia(this)">')
					.attr('src', UrlImagens + 'geral/btn_excluir.gif')
				)
			)
		);
}

function criaLinhaAlteracaoAgencia(cdagenci,nmextage){
	// Criar a linha na tabela
	$("#tbAltcon > tbody")
		.append($('<tr>') // Linha
			.attr('id',"id_".concat(cdagenci))
			.append($('<td>') // Coluna: C�digo da Agencia
				.attr('style','width: 80px; text-align:right')
				.text(cdagenci)
			)
			.append($('<td>') // Coluna: Nome da Agencia
				.attr('style','text-align:left')
				.text(nmextage)
			)
			.append($('<td>') // Coluna: Bot�o para REMOVER
				.attr('style','width: 80px; text-align:center')
				.append($('<img onclick="excluirLinhaAgencia(this)">')
					.attr('src', UrlImagens + 'geral/btn_excluir.gif')
				)
			)
		);
}

function criaLinhaContaTrf(nrdconta, nmprimtl, cdagenci, nmextage) {
	//var checkbox = '<input type="checkbox" name="idtransf" value='+nrdconta+'/>';
	
	$("#tbTrfcon > tbody")
		.append($('<tr>') // Linha
			.attr('id',"id_".concat(nrdconta))
			.append($('<td>') 
				.attr('style','width: 65px; text-align:right')
				.text(nrdconta)
			)
			.append($('<td>') 
				.attr('style','width: 230px; text-align:left')
				.text(nmprimtl)
			)
			.append($('<td>') 
				.attr('style','width: 65px; text-align:right')
				.text(cdagenci)
			)
			.append($('<td>') 
				.attr('style','width: 230px; text-align:left')
				.text(nmextage)
			)
			.append($('<td>')
				.attr('style','width: 65px; text-align:center')
				.append($('<input type="checkbox" name="idtransf" value="'+nrdconta+'"/>')
				)
			)
		);
}

function excluirLinhaAgencia(linha) {
	linha.closest('tr').remove();
}

function limpaTabelaAgencia() {
	$("#tbConage > tbody").html("");
}

function limpaTabelaAgenciaAlt() {
	$("#tbAltcon > tbody").html("");
}

function selecionaLinhaConsulta(linha) {
	linha.style.backgroundColor = "";
	//$("td:eq(0)", linha ).html();
	manterConsultor("CA",$("td:eq(0)", linha ).html(),"","","");
}

function selecionaLinhaConsultaAgencia(linha) {
	linha.style.backgroundColor = "";
}

function manterConsultor(cddopcao,cdconsultor,cdoperad,cdagenci,nrdconta){
    //Requisi��o para processar a op��o que foi selecionada

	$.ajax({
        type: "POST",
        url: UrlSite + "telas/cadcon/manter_rotina_consultor.php",
        data: {
            cddopcao:     cddopcao,
			cdconsultor:  cdconsultor,
			cdoperad:     cdoperad,
			cdagenci:     cdagenci,
			nrdconta:     nrdconta,
			redirect:     "script_ajax"
		},
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function(response) {
           hideMsgAguardo();
			try {
				eval(response);
			} catch (error) {
					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
			}
		}
    });
    return false;
}

function buscaOperadorAlt(){
	var cdconsultor = $("#cdconsultor","#frmAltConsultor").val().trim(); 
	//Valida o c�digo do operador
	if(cdconsultor != "") {
		//Busca as informa��es do c�digo informado
		manterConsultor("AO",cdconsultor,"","","");
	}
}

function buscaOperadorAlteracao(){
	var cdoperad = $("#cdoperador","#frmAltConsultor").val().trim(); 
	//Valida o c�digo do operador
	if(cdoperad != "") {
		//Busca as informa��es do c�digo informado
		manterConsultor("AOA","",cdoperad,"","");
	}
}

function buscaOperadorCad(){
	var cdoperad = $("#cdoperador","#frmCadConsultor").val().trim(); 
	//Valida o c�digo do operador
	if(cdoperad != "") {
		//Busca as informa��es do c�digo informado
		manterConsultor("IO","",cdoperad,"","");
	}
}

function buscaOperadorOrigem(){
	var cdconsultor = $("#cdconsultororg","#frmTrfConsultor").val().trim(); 
	//Valida o c�digo do operador
	if(cdconsultor != "") {
		//Busca as informa��es do c�digo informado
		manterConsultor("TO",cdconsultor,"","","");
	}
}

function buscaOperadorDestino(){
	var cdconsultororg = $("#cdconsultororg","#frmTrfConsultor").val().trim(); 
	var cdconsultordst = $("#cdconsultordst","#frmTrfConsultor").val().trim(); 
	//Valida o c�digo do operador
	if(cdconsultororg != "" && cdconsultordst != "") {
		//Busca as informa��es do c�digo informado
		manterConsultor("TD",cdconsultordst,"","","");
		manterConsultor("TA",cdconsultororg,cdconsultordst,"","");
	}
}

function associaOperadorTrfOrg(cdoperad, nmoperad) {
	$("#cdoperadororg","#frmTrfConsultor").val(cdoperad);
	$("#nmoperadororg","#frmTrfConsultor").val(nmoperad);
	$("#cdconsultordst","#frmTrfConsultor").focus();
}

function associaOperadorTrfDst(cdoperad, nmoperad) {
	$("#cdoperadordst","#frmTrfConsultor").val(cdoperad);
	$("#nmoperadordst","#frmTrfConsultor").val(nmoperad);
}

function associaOperadorCad(cdoperad, nmoperad) {
	if (cdoperad == $("#cdoperador","#frmCadConsultor").val().trim()) {
		$("#nmoperador","#frmCadConsultor").val(nmoperad);
		$("#cdagenci","#frmCadConsultor").focus();
	}
}

function associaOperadorAlt(cdoperad, nmoperad) {
	$("#cdoperador","#frmAltConsultor").val(cdoperad);
	$("#nmoperador","#frmAltConsultor").val(nmoperad);
	$("#cdoperador","#frmAltConsultor").focus();
	$("#cdconsultor","#frmAltConsultor").desabilitaCampo();
}

function associaOperadorAlteracao(cdoperad, nmoperad) {
	if (cdoperad == $("#cdoperador","#frmAltConsultor").val().trim()) {
		$("#nmoperador","#frmAltConsultor").val(nmoperad);
		$("#cdagenci","#frmAltConsultor").focus();
	}
}

function associaAgenciaCad(cdagenci, nmextage) {
	if (cdagenci == $("#cdagenci","#frmCadConsultor").val().trim()) {
		$("#nmextage","#frmCadConsultor").val(nmextage);
	}
}

function associaAgenciaAlt(cdagenci, nmextage) {
	if (cdagenci == $("#cdagenci","#frmAltConsultor").val().trim()) {
		$("#nmextage","#frmAltConsultor").val(nmextage);
	}
}

function incluirAgenciaCad () {
	var cdagenci = $("#cdagenci","#frmCadConsultor").val().trim();
	var nmextage = $("#nmextage","#frmCadConsultor").val().trim();

	if (cdagenci != "" && nmextage != "") {
		criaLinhaCadastroAgencia(cdagenci, nmextage);
		$("#cdagenci","#frmCadConsultor").val("");
		$("#nmextage","#frmCadConsultor").val("");
	}
}

function incluirAgenciaAlt () {
	var cdagenci = $("#cdagenci","#frmAltConsultor").val().trim();
	var nmextage = $("#nmextage","#frmAltConsultor").val().trim();

	if (cdagenci != "" && nmextage != "") {
		criaLinhaAlteracaoAgencia(cdagenci, nmextage);
		$("#cdagenci","#frmAltConsultor").val("");
		$("#nmextage","#frmAltConsultor").val("");
	}
}

function buscaAgenciaCad(){
	var cdagenci = $("#cdagenci","#frmCadConsultor").val().trim(); 
	//Valida o c�digo do operador
	if(cdagenci != "") {
		//Busca as informa��es do c�digo informado
		manterConsultor("IA","","",cdagenci,"");
	}
}

function buscaAgenciaAlt() {
	var cdagenci = $("#cdagenci","#frmAltConsultor").val().trim();
	//Valida o c�digo do operador
	if(cdagenci != "") {
		//Busca as informa��es do c�digo informado
		manterConsultor("AA","","",cdagenci,"");
	}
}

function mostrarPesquisaOperador(){
	//Defini��o dos filtros
	var filtros	= "C�digo Operador;cdoperador;50px;S;;S;|Nome Operador;nmoperador;200px;S;;S;descricao";
	//Campos que ser�o exibidos na tela
	var colunas = 'C�digo;cdoperador;20%;right|Nome Operador;nmoperador;80%;left';			
	//Exibir a pesquisa
	mostraPesquisa("CADCON", "CADCON_CONSULTA_OPERADORES", "Operadores","100",filtros,colunas);
}

function mostrarPesquisaAgencia(){
	//Defini��o dos filtros
	var filtros	= "C�digo Agencia;cdagenci;50px;S;;S;|Nome Agencia;nmextage;200px;S;;S;descricao";
	//Campos que ser�o exibidos na tela
	var colunas = 'C�digo;cdagenci;20%;right|Nome Agencia;nmextage;80%;left';
	//Exibir a pesquisa
	mostraPesquisa("CADCON", "CADCON_CONSULTA_AGENCIAS", "Agencias","100",filtros,colunas);
}

function mostrarPesquisaConsultorOrg(){
	//Defini��o dos filtros
	var filtros	= "C�digo Consultor;cdconsultororg;50px;S;;S;|C�digo Operador;cdoperadororg;50px;S;;S;|Nome Operador;nmoperadororg;200px;S;;S;descricao";
	//Campos que ser�o exibidos na tela
	var colunas = 'C�digo;cdconsultororg;20%;right|C�digo;cdoperadororg;20%;right|Nome Operador;nmoperadororg;80%;left';
	//Exibir a pesquisa
	mostraPesquisa("CADCON", "CADCON_CONSULTA_CONSULTORES_ORG", "Consultores","100",filtros,colunas);
}

function mostrarPesquisaConsultorDst(){
	//Defini��o dos filtros
	var filtros	= "C�digo Consultor;cdconsultordst;50px;S;;S;|C�digo Operador;cdoperadordst;50px;S;;S;|Nome Operador;nmoperadordst;200px;S;;S;descricao";
	//Campos que ser�o exibidos na tela
	var colunas = 'C�digo;cdconsultordst;20%;right|C�digo;cdoperadordst;20%;right|Nome Operador;nmoperadordst;80%;left';
	//Exibir a pesquisa
	mostraPesquisa("CADCON", "CADCON_CONSULTA_CONSULTORES_DST", "Consultores","100",filtros,colunas);
}

function consultorInativo() {
	//$("#cdconsultor","#frmAltConsultor").css("width","80px").attr("maxlength","5").habilitaCampo();
	$("#cdoperador","#frmAltConsultor").desabilitaCampo();
	$("#nmoperador","#frmAltConsultor").desabilitaCampo();
	$("#cdagenci","#frmAltConsultor").desabilitaCampo();
	$("#nmextage","#frmAltConsultor").desabilitaCampo();
}

/***********************************************************************************************************
									FIM -> Fun��es para a tela de Consultores
***********************************************************************************************************/
/*!
 * FONTE        : qbrsig.js
 * CRIAÇÃO      : Heitor - Mouts
 * DATA CRIAÇÃO : 07/12/2018
 * OBJETIVO     : Biblioteca de funções da tela QBRSIG
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

var flgVoltarGeral = 1;
var iniregis       = 1;
var qtregistros    = 0;
var qtregpag       = 10;

$(document).ready(function() {
	// Estado Inicial da tela
	estadoInicial();
	formataTabParReg();
	formataTabParHis();
	formataTabQbrSig();
	formataTabQbrSigContas();
});

function estadoInicial(){
	//Voltar para a tela principal
	flgVoltarGeral = 1;

	$("#divTela").fadeTo(0,0.1);

	hideMsgAguardo();
	//Formatação do cabeçalho

	formataCabecalho();	
	formataParametroRegra();
	formataParametroHistorico();
	formataQuebraSigilo();
	
	removeOpacidade("divTela");

	highlightObjFocus( $("#frmCab") );

	//Exibe cabeçalho e define tamanho da tela
	$("#frmCab").css({"display":"block"});
	$("#divTela").css({"width":"700px","padding-bottom":"2px"});
		
	//Esconder os botões da tela
	$("#divBotoes").css({"display":"none"});

	//Foca o campo da Opção
	$("#cddotipo","#frmCab").focus();
}

function formataCabecalho() {
	// rotulo
	$('label[for="cddotipo"]',"#frmCab").addClass("rotulo").css({"width":"100px"}); 
	
	// campo
	$("#cddotipo","#frmCab").css("width","500px").habilitaCampo();
	
	$('input[type="text"],select','#frmCab').limpaFormulario().removeClass('campoErro');
	layoutPadrao();
	
	//Define ação para ENTER e TAB no campo Opção
	$("#cddotipo","#frmCab").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			//Executa função do botão OK
			liberaFormulario();
			return false;
		}
    });
	
	//Define ação para CLICK no botão de OK
	$("#btnOK","#frmCab").unbind('click').bind('click', function() {
		liberaFormulario();
		return false;
    });	
	return false;	
}

function liberaFormulario() {
	var cddotipo = $("#cddotipo","#frmCab");

	if(cddotipo.prop("disabled")){
		// Se o campo estiver desabilitado, não executa a liberação do formulário pois já existe uma ação sendo executada
		return;
	}

	cddotipo.desabilitaCampo();

	// Validar a opção que foi selecionada na tela
	switch(cddotipo.val()){
		case "PR": //Parametro Regra
			estadoInicialParametroRegra(); //estadoInicialCadastro
		break;

		case "PH": //Parametro Historico
			estadoInicialParametroHistorico();			
		break;
		
		case "QS": //Quebra Sigilo
			estadoInicialQuebraSigilo();
		break;

		default:
			estadoInicial();
		break;
	}
}

function controlaVoltar(){
	estadoInicial();
}

function msgSucessoSalvar(){
	showError('inform','Hist&oacute;rico salvo com sucesso!','Alerta - Aimaro','estadoInicialParametroHistorico();');
}

function msgSucessoQbr(){
	showError('inform',"Quebra de sigilo solicitada com sucesso! O t&eacute;rmino da execu&ccedil;&atilde;o ser&aacute; relatado via e-mail!",'Alerta - Aimaro','estadoInicialQuebraSigilo();');
}

function msgSucessoArq(){
	$("#tbQbrsig > tbody > tr:first").trigger('click');
	showError('inform','Arquivos gerados com sucesso!','Alerta - Aimaro','estadoInicialQuebraSigilo();');
}

function msgSucessoRpc(){
	$("#tbQbrsig > tbody > tr:first").trigger('click');
	showError('inform','Quebra reprocessada com sucesso!','Alerta - Aimaro','estadoInicialQuebraSigilo();');
}

function msgSucessoSlv(nrseq_quebra_sigilo,nrseqlcm){
	var cddopcao = "CQQ"; //Consulta conta quebra
	consultaQuebra(cddopcao, 'NOVO');

	showError('inform','Informa&ccedil;&otilde;es atualizadas com sucesso!','Alerta - Aimaro','');
}

function estadoInicialParametroRegra(){
	//Retorna para a principal
	flgVoltarGeral = 1;

	hideMsgAguardo();

	removeOpacidade("divTela");

	$("#tbParreg > tbody").html("");
	$("#tbParreg > thead").html("");

	$("#divParametroRegra").css({"display":"block"});

	//Esconde cadastro e os botões
	$("#divBotoes").css({"display":"block"});
	$("#btConcluir","#divBotoes").hide();
	$("#btQuebrar","#divBotoes").hide();
	$("#btGerar","#divBotoes").hide();
	$("#btSalvar","#divBotoes").hide();
	$("#btReprocessar","#divBotoes").hide();
	
	//Exibe cabeçalho e define tamanho da tela
	$("#frmParametroRegra","#divParametroRegra").css({"display":"block"});

	//Limpa os campos do formulário e remove o erro dos campos
	//$('input[type="text"],select','#frmParametroRegra').limpaFormulario().removeClass('campoErro');

	formataParametroRegra();
	formataOpcaoParametroRegra();
	consultaRegra();
}

function estadoInicialParametroHistorico(){
	var cddopcao = $("#cddotipo","#frmCab").val();

	//Retorna para a principal
	flgVoltarGeral = 1;

	hideMsgAguardo();

	removeOpacidade("divTela");

	$("#tbParhis > tbody").html("");
	$("#tbParhis > thead").html("");

	$("#divParametroHistorico").css({"display":"block"});

	//Esconde cadastro e os botões
	$("#divBotoes").css({"display":"block"});
	$("#btConcluir","#divBotoes").hide();
	$("#btQuebrar","#divBotoes").hide();
	$("#btGerar","#divBotoes").hide();
	$("#btSalvar","#divBotoes").hide();
	$("#btReprocessar","#divBotoes").hide();

	//Exibe cabeçalho e define tamanho da tela
	$("#frmParametroHistorico","#divParametroHistorico").css({"display":"block"});

	//Limpa os campos do formulário e remove o erro dos campos
	$('input[type="text"],select','#frmParametroHistorico').limpaFormulario().removeClass('campoErro');
	$('#cdestsig','#frmParametroHistorico').val(0);
	
	formataParametroHistorico();
	formataOpcaoParametroHistorico();
	consultaHistorico(cddopcao, "");
}

function estadoInicialQuebraSigilo(){
	var cddopcao = $("#cddotipo","#frmCab").val();

	//Retorna para a principal
	flgVoltarGeral = 1;

	hideMsgAguardo();

	removeOpacidade("divTela");

	$("#tbQbrsig > tbody").html("");
	$("#tbQbrsig > thead").html("");
	$("#tbQbrsigcontas > tbody").html("");
	$("#tbQbrsigcontas > thead").html("");

	$("#divQuebraSigilo").css({"display":"block"});

	//Esconde cadastro e os botões
	$("#divBotoes").css({"display":"block"});
	$("#btConcluir","#divBotoes").hide();
	$("#btQuebrar","#divBotoes").show();
	$("#btGerar","#divBotoes").hide();
	$("#btSalvar","#divBotoes").hide();
	$("#btReprocessar","#divBotoes").hide();

	//Exibe cabeçalho e define tamanho da tela
	$("#frmQuebraSigilo","#divQuebraSigilo").css({"display":"block"});

	//Limpa os campos do formulário e remove o erro dos campos
	$('input[type="text"],select','#frmQuebraSigilo').limpaFormulario().removeClass('campoErro');
	$('#nmrescop','#frmQuebraSigilo').val(1);
	$('#filtro_idsitqbr','#frmQuebraSigilo').val(0);
	
	formataQuebraSigilo();
	formataOpcaoQuebraSigilo();
}

function formataParametroRegra(){

    $("#fsparreg","#frmParametroRegra").css({"display":"none"});
    $("#tbParreg > tbody").html("");
    
	return false;
}

function formataParametroHistorico(){

	// rotulo
	$('label[for="cdhistor"]',"#frmParametroHistorico").addClass('rotulo').css({"width":"125px"});
	$('label[for="dsexthst"]',"#frmParametroHistorico").addClass('rotulo-linha').css({"width":"125px"});
	$('label[for="cdhisrec"]',"#frmParametroHistorico").addClass('rotulo').css({"width":"125px"});
	$('label[for="cdestsig"]',"#frmParametroHistorico").addClass('rotulo-linha').css({"width":"125px"});

	// campo
	$("#cdhistor","#frmParametroHistorico").addClass("inteiro campo").css({"width":"53px"}).attr("maxlength","5");
	$("#dsexthst","#frmParametroHistorico").addClass("campo").css({"width":"300px"});
	$("#cdhisrec","#frmParametroHistorico").addClass("inteiro campo").css({"width":"53px"}).attr("maxlength","5");
	$("#cdestsig","#frmParametroHistorico").addClass("campo").css({"width":"300px"});

    $("#fsparhis","#frmParametroHistorico").css({"display":"none"});
    $("#tbParhis > tbody").html("");

	$("#cdhistor","#frmParametroHistorico").habilitaCampo();
    $("#dsexthst","#frmParametroHistorico").desabilitaCampo();
	$("#cdhisrec","#frmParametroHistorico").habilitaCampo();
	$("#cdestsig","#frmParametroHistorico").habilitaCampo();

	$("#cdhistor","#frmParametroHistorico").unbind('keydown').bind('keydown', function(e){
        var tecla = (e.keyCode?e.keyCode:e.which);

        /* verifica se a tecla pressionada foi o ENTER ou TAB*/
        if(tecla == 13 || tecla == 9){
			var cddopcao = "CPH";
			var cdhistor = $("#cdhistor","#frmParametroHistorico").val();

			$("#dsexthst","#frmParametroHistorico").val("");
			$("#cdhisrec","#frmParametroHistorico").val("");
			$("#cdestsig","#frmParametroHistorico").val(0);
			
			consultaHistorico(cddopcao, cdhistor);
			$("#cdhisrec","#frmParametroHistorico").focus();
			return false;
        }
    });

	return false;
}

function formataQuebraSigilo(){

	//Rotulos
	//Linha 1
	$('label[for="nmrescop"]',"#frmQuebraSigilo").addClass('rotulo').css({"width":"100px"});
	$('label[for="nrdconta"]',"#frmQuebraSigilo").addClass('rotulo-linha').css({"width":"100px"});
	$('label[for="nrcpfcgc"]',"#frmQuebraSigilo").addClass('rotulo-linha').css({"width":"83px"});

	//Linha 2
	$('label[for="nmprimtl"]',"#frmQuebraSigilo").addClass('rotulo').css({"width":"100px"});

	//Linha 3
	$('label[for="dtiniper"]',"#frmQuebraSigilo").addClass('rotulo').css({"width":"100px"});
	$('label[for="dtfimper"]',"#frmQuebraSigilo").addClass('rotulo-linha').css({"width":"100px"});
	$('label[for="btnIncluirConta"]',"#frmQuebraSigilo").addClass('rotulo-linha').css({"width":"100px"});
	
	//Linha 4
	$('label[for="nrseq_quebra_sigilo"]',"#frmQuebraSigilo").addClass('rotulo').css({"width":"100px"});
	$('label[for="filtro_idsitqbr"]',"#frmQuebraSigilo").addClass('rotulo-linha').css({"width":"100px"});
	
	//Complemento
	$('label[for="compldsobsqbr"]',"#frmQuebraSigilo").addClass('rotulo').css({"width":"100px"});
	$('label[for="complnrdocmto"]',"#frmQuebraSigilo").addClass('rotulo').css({"width":"100px"});
	$('label[for="complcdbandep"]',"#frmQuebraSigilo").addClass('rotulo-linha').css({"width":"100px"});
	$('label[for="complcdagedep"]',"#frmQuebraSigilo").addClass('rotulo').css({"width":"100px"});
	$('label[for="complnrctadep"]',"#frmQuebraSigilo").addClass('rotulo-linha').css({"width":"165px"});
	$('label[for="complnrcpfcgc"]',"#frmQuebraSigilo").addClass('rotulo').css({"width":"100px"});
	$('label[for="complnmprimtl"]',"#frmQuebraSigilo").addClass('rotulo-linha').css({"width":"100px"});

	//Campos
	//Linha 1
	$("#nmrescop","#frmQuebraSigilo").addClass("campo").css({"width":"125px"});
	$("#nrdconta","#frmQuebraSigilo").addClass("campo").css({"width":"125px"}).setMask('INTEGER','zzzz.zzz-z','.-','');
	$("#nrcpfcgc","#frmQuebraSigilo").addClass("campo").css({"width":"125px"});

	//Linha 2
	$("#nmprimtl","#frmQuebraSigilo").addClass("campo").css({"width":"587px"});

	//Linha 3
	$("#dtiniper","#frmQuebraSigilo").addClass("campo").css({"width":"125px"}).setMask('DATE','','','');
	$("#dtfimper","#frmQuebraSigilo").addClass("campo").css({"width":"125px"}).setMask('DATE','','','');
	$("#btnIncluirConta","#frmQuebraSigilo").css({"width":"110px"});

	//Linha 4
	$("#nrseq_quebra_sigilo","#frmQuebraSigilo").addClass("campo").css({"width":"125px"});
	$("#filtro_idsitqbr","#frmQuebraSigilo").addClass("campo").css({"width":"340px"});

	//Complemento
	$("#compldsobsqbr","#frmQuebraSigilo").addClass("campo").css({"width":"500px"});
	$("#complnrdocmto","#frmQuebraSigilo").addClass("campo").css({"width":"140px"});
	$("#complcdbandep","#frmQuebraSigilo").addClass("campo").css({"width":"75px"});
	$("#complnmextbcc","#frmQuebraSigilo").addClass("campo").css({"width":"250px"});
	$("#complcdagedep","#frmQuebraSigilo").addClass("campo").css({"width":"75px"});
	$("#complnrctadep","#frmQuebraSigilo").addClass("campo").css({"width":"75px"});
	$("#complnrcpfcgc","#frmQuebraSigilo").addClass("campo").css({"width":"140px"});
	$("#complnmprimtl","#frmQuebraSigilo").addClass("campo").css({"width":"328px"});

    $("#fsqbrsig","#frmQuebraSigilo").css({"display":"none"});
    $("#tbQbrsig > tbody").html("");
	$("#tbQbrsigcontas > tbody").html("");

	$("#nmrescop","#frmQuebraSigilo").habilitaCampo();
	$("#nrdconta","#frmQuebraSigilo").habilitaCampo();
	$("#nrcpfcgc","#frmQuebraSigilo").desabilitaCampo();
	$("#nmprimtl","#frmQuebraSigilo").desabilitaCampo();
	$("#nrseq_quebra_sigilo","#frmQuebraSigilo").habilitaCampo();
	$("#dtiniper","#frmQuebraSigilo").habilitaCampo();
	$("#dtfimper","#frmQuebraSigilo").habilitaCampo();
	$("#compldsobsqbr","#frmQuebraSigilo").desabilitaCampo();
	$("#complnrdocmto","#frmQuebraSigilo").desabilitaCampo();
	$("#complnmextbcc","#frmQuebraSigilo").desabilitaCampo();
	$("#filtro_idsitqbr","#frmQuebraSigilo").habilitaCampo();

	$("#nrdconta","#frmQuebraSigilo").unbind('keydown').bind('keydown', function(e) {
        var tecla = (e.keyCode?e.keyCode:e.which);

        /* verifica se a tecla pressionada foi o ENTER ou TAB*/
        if(tecla == 13 || tecla == 9){
			var cddopcao = "CCQ"; //Consulta conta quebra

			consultaQuebra(cddopcao, 'NOVO');
			$("#dtiniper","#frmQuebraSigilo").focus();
			return false;
        }
    });

	$("#nrseq_quebra_sigilo","#frmQuebraSigilo").unbind('keydown').bind('keydown', function(e) {
        var tecla = (e.keyCode?e.keyCode:e.which);

        /* verifica se a tecla pressionada foi o ENTER ou TAB*/
        if(tecla == 13 || tecla == 9){
			var cddopcao = "CQQ"; //Consulta quebra
			consultaQuebra(cddopcao, 'NOVO');

			return false;
        }
    });
	
	return false;
}

function setarDadosConta(nmprimtl,nrcpfcgc) {
	$("#nmprimtl","#frmQuebraSigilo").val(nmprimtl);
	$("#nrcpfcgc","#frmQuebraSigilo").val(nrcpfcgc);
}

function setarDadosQuebra(cdcooper,nrdconta,nrcpfcgc,nmprimtl,dtiniper,dtfimper) {
	$("#nmrescop","#frmQuebraSigilo").val(cdcooper);
	$("#nrdconta","#frmQuebraSigilo").val(nrdconta);
	$("#nrcpfcgc","#frmQuebraSigilo").val(nrcpfcgc);
	$("#nmprimtl","#frmQuebraSigilo").val(nmprimtl);
	$("#dtiniper","#frmQuebraSigilo").val(dtiniper);
	$("#dtfimper","#frmQuebraSigilo").val(dtfimper);
}

function buscaDesHistoricoAilos(cdhistor){
    var cddotipo = $("#cddotipo","#frmCab");

	if (cdhistor != ""){
		if (cddotipo.val() == "PH") {
			manterParametro("BHT","",cdhistor,"","",""); //buscar descrição historico ailos
		}
    }
}

function formataTabCad() {
	// Tabela
	var divRegistro = $("div.divRegistros", "#tabCadpar");
	var tabela      = $("table", divRegistro );
	var linha       = $("table > tbody > tr", divRegistro );

	$("#tabCadpar").css({"margin-top":"5px"});
	divRegistro.css({"height":"170px","width":"700px","padding-bottom":"2px"});

	var ordemInicial = new Array();

	//Define a largura dos campos
	var arrayLargura = new Array();
    arrayLargura[0] = "80px";
    arrayLargura[1] = "";
	arrayLargura[2] = "50px";
	arrayLargura[3] = "80px";

	//Define a posição dos elementos nas células da linha
    var arrayAlinha = new Array();
	arrayAlinha[0] = "right";
	arrayAlinha[1] = "left";
	arrayAlinha[2] = "center";
	arrayAlinha[3] = "center";

	//Aplica as informações na tabela
	$(".ordemInicial","#tabCadpar").remove();
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);

	return false;
}

function formataTabParReg() {
	// Tabela de Consulta parametro
	var divRegistro = $("div.divRegistros", "#tabParreg");
	var tabela      = $("table", divRegistro );
	var linha       = $("table > tbody > tr", divRegistro );

	$("#tabParreg").css({"margin-top":"5px"});
	divRegistro.css({"height":"230px","width":"700px","padding-bottom":"2px"});

	var ordemInicial = new Array();

	//Define a largura dos campos
	var arrayLargura = new Array();
    arrayLargura[0] = "53px";

	//Define a posição dos elementos nas células da linha
    var arrayAlinha = new Array();
	arrayAlinha[0] = "right";

	//Aplica as informações na tabela
	$(".ordemInicial","#tabParreg").remove();
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);

	return false;
}

function formataTabParHis() {
	// Tabela de Consulta parametro
	var divRegistro = $("div.divRegistros", "#tabParhis");
	var tabela      = $("table", divRegistro );
	var linha       = $("table > tbody > tr", divRegistro );

	$("#tabParhis").css({"margin-top":"5px"});
	divRegistro.css({"height":"230px","width":"700px","padding-bottom":"2px"});

	var ordemInicial = new Array();

	//Define a largura dos campos
	var arrayLargura = new Array();
    arrayLargura[0] = "53px";
    arrayLargura[1] = "297px";
    arrayLargura[2] = "53px";
	arrayLargura[3] = "";

	//Define a posição dos elementos nas células da linha
    var arrayAlinha = new Array();
	arrayAlinha[0] = "right";
	arrayAlinha[1] = "left";
	arrayAlinha[2] = "right";
	arrayAlinha[3] = "left";

	//Aplica as informações na tabela
	$(".ordemInicial","#tabParhis").remove();
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);

	return false;
}

function formataTabQbrSig() {
	// Tabela de Consulta parametro
	var divRegistro = $("div.divRegistros", "#tabQbrsig");
	var tabela      = $("table", divRegistro );
	var linha       = $("table > tbody > tr", divRegistro );

	$("#tabQbrsig").css({"margin-top":"5px"});
	divRegistro.css({"height":"150px","width":"700px","padding-bottom":"2px"});

	var ordemInicial = new Array();

	//Define a largura dos campos
	var arrayLargura = new Array();
    arrayLargura[0] = "80px";
    arrayLargura[1] = "80px";
    arrayLargura[2] = "80px";
	arrayLargura[3] = "";

	//Define a posição dos elementos nas células da linha
    var arrayAlinha = new Array();
	arrayAlinha[0] = "center";
	arrayAlinha[1] = "left";
	arrayAlinha[2] = "left";
	arrayAlinha[3] = "left";
	
	//Aplica as informações na tabela
	$(".ordemInicial","#tabQbrsig").remove();
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);
	
	// seleciona o registro que é clicado
    $('table > tbody > tr', divRegistro).die("click").live("click", function () {
        selecionaTabela($(this));
    });
	
	//Formatação da tabela
	$('#divPesquisaRodape').formataRodapePesquisa();

	return false;
}

function formataTabQbrSigContas() {
	// Tabela de Consulta parametro
	var divRegistro = $("div.divRegistros", "#tabQbrsigcontas");
	var tabela      = $("table", divRegistro );
	var linha       = $("table > tbody > tr", divRegistro );

	$("#tabQbrsigcontas").css({"margin-top":"5px"});
	divRegistro.css({"height":"75px","width":"700px","padding-bottom":"2px"});

	var ordemInicial = new Array();

	//Define a largura dos campos
	var arrayLargura = new Array();
    arrayLargura[0] = "200px";
    arrayLargura[1] = "200px";
	arrayLargura[2] = "200px";
    arrayLargura[3] = "";

	//Define a posição dos elementos nas células da linha
    var arrayAlinha = new Array();
	arrayAlinha[0] = "left";
	arrayAlinha[1] = "center";
	arrayAlinha[2] = "center";
	arrayAlinha[3] = "";

	//Aplica as informações na tabela
	$(".ordemInicial","#tabQbrsigcontas").remove();
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);
	
	// seleciona o registro que é clicado
    $('table > tbody > tr', divRegistro).die("click").live("click", function () {
        selecionaTabela($(this));
    });

	return false;
}

function selecionaTabela(tr) {
    $('#compldsobsqbr', '#frmQuebraSigilo').val($('#dsobsqbr', tr).text());
	$('#complnrdocmto', '#frmQuebraSigilo').val($('#nrdocmto', tr).text());
	$('#complcdbandep', '#frmQuebraSigilo').val($('#cdbandep', tr).text());
	$('#complnmextbcc', '#frmQuebraSigilo').val($('#nmextbcc', tr).text());
	$('#complcdagedep', '#frmQuebraSigilo').val($('#cdagedep', tr).text());
	$('#complnrctadep', '#frmQuebraSigilo').val($('#nrctadep', tr).text());
	$('#complnrcpfcgc', '#frmQuebraSigilo').val($('#nrcpfcgc', tr).text());
	$('#complnmprimtl', '#frmQuebraSigilo').val($('#nmprimtl', tr).text());
	$('#complnrseqlcm', '#frmQuebraSigilo').val($('#nrseqlcm', tr).text());
}

function validaHistoricoAilos(){
	if ($("#dsexthst","#frmParametroHistorico").val() == "") {
		showError('alert','Hist&oacute;rico n&atilde;o encontrado!','Alerta - Aimaro','estadoInicialParametroHistorico()');
	}
}

function formataOpcaoParametroRegra(){
	$("#fsparreg","#frmParametroRegra").css({"display":"block"});  
	return false;
}

function formataOpcaoParametroHistorico(){
	$("#fsparhis","#frmParametroHistorico").css({"display":"block"});  
	return false;
}

function formataOpcaoQuebraSigilo(){
	$("#fsqbrsig","#frmQuebraSigilo").css({"display":"block"});  
	return false;
}

function criaLinhaHistorico(cdhistor,dsexthst,cdhisrec,cdestsig){	
	// Criar a linha na tabela
	$("#tbParhis > tbody")
		.append($('<tr>') // Linha
			.attr('id',"id_".concat(cdhistor))
			.append($('<td>') 
				.attr('style','width: 53px; text-align:right')
				.text(cdhistor)
			)
			.append($('<td>')  
				.attr('style','width: 297px; text-align:left')
				.text(dsexthst)
			)
			.append($('<td>') 
				.attr('style','width: 53px; text-align:center')
				.text(cdhisrec)
			)
			.append($('<td>')  
				.attr('style','text-align:left')
				.text(cdestsig)
			)
		);
}

function incluirConta(){
	
	var nrdconta = $("#nrdconta","#frmQuebraSigilo").val();
	var dtiniper = $("#dtiniper","#frmQuebraSigilo").val();
	var dtfimper = $("#dtfimper","#frmQuebraSigilo").val();
	
	if (nrdconta != "" && dtiniper != "" && dtfimper != "") {	
		// Criar a linha na tabela
		$("#tbQbrsigcontas > tbody")
			.append($('<tr>') // Linha
				.attr('id',"idconta_".concat(nrdconta))
				.append($('<td>') 
					.attr('style','width: 195px; text-align:right')
					.text(nrdconta)
				)
				.append($('<td>')
					.attr('style','width: 196px; text-align:center')
					.text(dtiniper)
				)
				.append($('<td>') 
					.attr('style','width: 196px; text-align:center')
					.text(dtfimper)
				)
				.append($('<td>') // Coluna: Botão para REMOVER
					.attr('style','text-align:center')
					.append($('<img onclick="excluirLinhaConta(this)">')
						.attr('src', UrlImagens + 'geral/btn_excluir.gif')
					)
				)
			);
		
		$("#nrdconta","#frmQuebraSigilo").val("");
		$("#nrcpfcgc","#frmQuebraSigilo").val("");
		$("#nmprimtl","#frmQuebraSigilo").val("");
		$("#dtiniper","#frmQuebraSigilo").val("");
		$("#dtfimper","#frmQuebraSigilo").val("");
		
		$("#nmrescop","#frmQuebraSigilo").desabilitaCampo();
		$("#nrdconta","#frmQuebraSigilo").focus();
	}
}

function incluirContaQuebra(nrdconta,dtiniper,dtfimper){

	// Criar a linha na tabela
	$("#tbQbrsigcontas > tbody")
		.append($('<tr>') // Linha
			.attr('id',"idconta_".concat(nrdconta))
			.append($('<td>') 
				.attr('style','width: 195px; text-align:center')
				.text(nrdconta)
			)
			.append($('<td>')
				.attr('style','width: 196px; text-align:center')
				.text(dtiniper)
			)
			.append($('<td>') 
				.attr('style','width: 196px; text-align:center')
				.text(dtfimper)
			)
			.append($('<td>') // Coluna: Botão para REMOVER
				.attr('style','text-align:center')
				.append($('<img onclick="excluirLinhaConta(this)">')
					.attr('src', UrlImagens + 'geral/btn_excluir.gif')
				)
			)
		);
	
	$("#nrdconta","#frmQuebraSigilo").val("");
	$("#nrcpfcgc","#frmQuebraSigilo").val("");
	$("#nmprimtl","#frmQuebraSigilo").val("");
	$("#dtiniper","#frmQuebraSigilo").val("");
	$("#dtfimper","#frmQuebraSigilo").val("");
	
	$("#nrdconta","#frmQuebraSigilo").desabilitaCampo();
	$("#nrcpfcgc","#frmQuebraSigilo").desabilitaCampo();
	$("#nmprimtl","#frmQuebraSigilo").desabilitaCampo();
	$("#dtiniper","#frmQuebraSigilo").desabilitaCampo();
	$("#dtfimper","#frmQuebraSigilo").desabilitaCampo();
	$("#nmrescop","#frmQuebraSigilo").desabilitaCampo();
	$("#nrdconta","#frmQuebraSigilo").focus();
}

function excluirLinhaConta(linha) {
	$(linha).closest('tr').remove();
}

function criaLinhaLancamento(dtmvtolt,cdhistor,vllanmto,idsitqbr,nrseqlcm,dsobsqbr,nrdocmto,cdbandep,nmextbcc,cdagedep,nrctadep,nrcpfcgc,nmprimtl){	
	// Criar a linha na tabela
	$("#tbQbrsig > tbody")
		.append($('<tr>') // Linha
			.attr('id',"id_".concat(nrseqlcm))
			.append($('<td>') 
				.attr('style','width: 80px; text-align:center')
				.text(dtmvtolt)
			)
			.append($('<td>')  
				.attr('style','width: 80px; text-align:left')
				.text(cdhistor)
			)
			.append($('<td>') 
				.attr('style','width: 80px; text-align:left')
				.text(vllanmto)
			)
			.append($('<td>')  
				.attr('style','text-align:left')
				.text(idsitqbr)
			)
			.append($('<td>')
				.attr({'style':'text-align:left; display:none'
				      ,'id':'dsobsqbr'})
				.text(dsobsqbr)
			)
			.append($('<td>')
				.attr({'style':'text-align:left; display:none'
				      ,'id':'nrdocmto'})
				.text(nrdocmto)
			)
			.append($('<td>')
				.attr({'style':'text-align:left; display:none'
				      ,'id':'cdbandep'})
				.text(cdbandep)
			)
			.append($('<td>')
				.attr({'style':'text-align:left; display:none'
				      ,'id':'nmextbcc'})
				.text(nmextbcc)
			)
			.append($('<td>')
				.attr({'style':'text-align:left; display:none'
				      ,'id':'cdagedep'})
				.text(cdagedep)
			)
			.append($('<td>')
				.attr({'style':'text-align:left; display:none'
				      ,'id':'nrctadep'})
				.text(nrctadep)
			)
			.append($('<td>')
				.attr({'style':'text-align:left; display:none'
				      ,'id':'nrcpfcgc'})
				.text(nrcpfcgc)
			)
			.append($('<td>')
				.attr({'style':'text-align:left; display:none'
				      ,'id':'nmprimtl'})
				.text(nmprimtl)
			)
			.append($('<td>')
				.attr({'style':'text-align:left; display:none'
				      ,'id':'nrseqlcm'})
				.text(nrseqlcm)
			)
		);
}

function selecionaPrimeiroLancamento() {
	$("#tbQbrsig > tbody > tr:first").trigger('click');
	
	if ($("#nrseq_quebra_sigilo","#frmQuebraSigilo").val() != "") {
		$("#btGerar","#divBotoes").show();
		$("#btReprocessar","#divBotoes").show();
		$("#btSalvar","#divBotoes").show();
	}
}

function criaLinhaRegra(cdestsig,nmestsig){
	// Criar a linha na tabela
	$("#tbParreg > tbody")
		.append($('<tr>') // Linha
			.attr('id',"id_".concat(cdestsig))
			.append($('<td>') 
				.attr('style','width: 53px; text-align:right')
				.text(cdestsig)
			)
			.append($('<td>')  
				.attr('style','text-align:left')
				.text(nmestsig)
			)
		);
}

function setarDesHistoricoAilos(cdhistor,dsexthst,cdhisrec,cdestsig) {
	$("#dsexthst","#frmParametroHistorico").val(dsexthst);
	$("#cdhisrec","#frmParametroHistorico").val(cdhisrec);
	$("#cdestsig","#frmParametroHistorico").val(cdestsig);
}

function consultaHistorico(cddopcao, cdhistor){
    showMsgAguardo('Aguarde efetuando operacao...');

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/qbrsig/consulta_historico.php",
        data: {
			cddopcao:            cddopcao,
			cdhistor:     		 cdhistor,
            redirect:            "script_ajax"
		},
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function(response) {
           hideMsgAguardo();
			try {
				eval(response);
			} catch (error) {
					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
			}
		}
    });
    return false;
}

function consultaQuebra(cddopcao,idpagina){
    showMsgAguardo('Aguarde efetuando operacao...');

	if (cddopcao == 'CQQ') {
		$("#tbQbrsig > tbody").html("");
	    $("#tbQbrsig > thead").html("");
		$("#tbQbrsigcontas > tbody").html("");
	    $("#tbQbrsigcontas > thead").html("");
	}

	var cdcooper = $("#nmrescop","#frmQuebraSigilo").val();
	var nrdconta = $("#nrdconta","#frmQuebraSigilo").val();
	var nrseq_quebra_sigilo = $("#nrseq_quebra_sigilo","#frmQuebraSigilo").val();
	var idsitqbr = $("#filtro_idsitqbr","#frmQuebraSigilo").val();

	if (idpagina == 'ANTERIOR') {
		if ((iniregis - qtregpag) > 0) {
			iniregis = iniregis - qtregpag;
		} else {
			iniregis = 1;
		}
	} else if (idpagina == 'PROXIMO') {
		if ((iniregis + qtregpag) > qtregistros && qtregistros != 0) {
			iniregis = iniregis;
		} else {
			iniregis = iniregis + qtregpag;
		}
	} else if (idpagina == 'NOVO') {
		iniregis    = 1;
		qtregistros = 0;
	}

	nrdconta = nrdconta.replace(".","");
	nrdconta = nrdconta.replace("-","");

	if((cddopcao == "CCQ" && nrdconta != "") || (cddopcao == "CQQ" && nrseq_quebra_sigilo != "")){
		$.ajax({
			type: "POST",
			url: UrlSite + "telas/qbrsig/consulta_quebra.php",
			data: {
				cddopcao:            cddopcao,
				cdcooper:            cdcooper,
				nrdconta:            nrdconta,
				nrseq_quebra_sigilo: nrseq_quebra_sigilo,
				idsitqbr:            idsitqbr,
				iniregis:            iniregis,
				qtregpag:            qtregpag,
				redirect:            "script_ajax"
			},
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')) )");
			},
			success: function(response) {
			   hideMsgAguardo();
				try {
					eval(response);
				} catch (error) {
						hideMsgAguardo();
						showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
				}
			}
		});
	} else {
		hideMsgAguardo('Aguarde efetuando operacao...');
	}
    return false;
}

function consultaRegra(){
    showMsgAguardo('Aguarde efetuando operacao...');

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/qbrsig/consulta_regra.php",
        data: {
            redirect:            "script_ajax"
		},
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function(response) {
           hideMsgAguardo();
			try {
				eval(response);
			} catch (error) {
					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
			}
		}
    });
    return false;
}

function manterQuebra(cddopcao){
    showMsgAguardo('Aguarde efetuando operacao...');

	var cdcooper = $("#nmrescop","#frmQuebraSigilo").val();
	var nrdconta = "";
	var nrseq_quebra_sigilo = $("#nrseq_quebra_sigilo","#frmQuebraSigilo").val();
	var dtiniper = "";
	var dtfimper = "";
	var cdbandep = $("#complcdbandep","#frmQuebraSigilo").val();
	var cdagedep = $("#complcdagedep","#frmQuebraSigilo").val();
	var nrctadep = $("#complnrctadep","#frmQuebraSigilo").val();
	var nrcpfcgc = $("#complnrcpfcgc","#frmQuebraSigilo").val();
	var nmprimtl = $("#complnmprimtl","#frmQuebraSigilo").val();
	var nrseqlcm = $("#complnrseqlcm","#frmQuebraSigilo").val();

	$('#tbQbrsigcontas > tbody > tr').each(function(){	
		if (nrdconta == ''){
			nrdconta = $("td:eq(0)", $(this)).html();
		}else{
			nrdconta = nrdconta + ';' + $("td:eq(0)", $(this)).html();
		}

		if (dtiniper == ''){
			dtiniper = $("td:eq(1)", $(this)).html();
		}else{
			dtiniper = dtiniper + ';' + $("td:eq(1)", $(this)).html();
		}

		if (dtfimper == ''){
			dtfimper = $("td:eq(2)", $(this)).html();
		}else{
			dtfimper = dtfimper + ';' + $("td:eq(2)", $(this)).html();
		}		
	});

	$.ajax({
		type: "POST",
		url: UrlSite + "telas/qbrsig/manter_quebra.php",
		data: {
			cddopcao:            cddopcao,
			cdcooper:            cdcooper,
			nrdconta:            nrdconta,
			nrseq_quebra_sigilo: nrseq_quebra_sigilo,
			dtiniper:            dtiniper,
			dtfimper:            dtfimper,
			cdbandep:            cdbandep,
			cdagedep:            cdagedep,
			nrctadep:            nrctadep,
			nrcpfcgc:            nrcpfcgc,
			nmprimtl:            nmprimtl,
			nrseqlcm:            nrseqlcm,
			redirect:            "script_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')) )");
		},
		success: function(response) {
		   hideMsgAguardo();
			try {
				eval(response);
			} catch (error) {
					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
			}
		}
	});

    return false;
}

function salvarHistorico() {
	var cddopcao = $("#cddotipo","#frmCab").val();
	var cdhistor = $("#cdhistor","#frmParametroHistorico").val();
	var cdhisrec = $("#cdhisrec","#frmParametroHistorico").val();
	var cdestsig = $("#cdestsig","#frmParametroHistorico").val();

	if (cdhistor != ""){
		showMsgAguardo('Aguarde efetuando operacao...');

		$.ajax({
			type: "POST",
			url: UrlSite + "telas/qbrsig/manter_historico.php",
			data: {
				cddopcao: cddopcao,
				cdhistor: cdhistor,
				cdhisrec: cdhisrec,
				cdestsig: cdestsig,
				redirect: "script_ajax"
			},
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')) )");
			},
			success: function(response) {
			   hideMsgAguardo();
				try {
					eval(response);
				} catch (error) {
						hideMsgAguardo();
						showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
				}
			}
		});
		return false;
	}
}

function atualizaTextoPaginacao(qtregist) {
	qtregistros = qtregist;
	var qtdAte;
	
	if ((iniregis + qtregpag - 1) > qtregistros) {
		qtdAte = qtregistros;
	} else {
		qtdAte = (iniregis + qtregpag - 1);
	}
	
	$("#txtPaginacao","#frmQuebraSigilo").text("Exibindo " + iniregis + " - " + qtdAte + " de " + qtregistros);
}

function qbrsigMostraPesquisaAssociado() {
	var cdcooper = $("#nmrescop","#frmQuebraSigilo").val();

	mostraPesquisaAssociado('nrdconta','frmQuebraSigilo','','',cdcooper);
}

			
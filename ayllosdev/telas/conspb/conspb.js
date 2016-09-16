/*!
 * FONTE        : conspb.js
 * CRIAÇÃO      : Douglas Quisinski
 * DATA CRIAÇÃO : 30/07/2015
 * OBJETIVO     : Biblioteca de funções da tela CONSPB
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
 
// Armazena as críticas de processamento do arquivo
var aCriticas        = Array();
var qtdTotalRegistro = 0;  // Quantidade total de registros processados
var qtdTotalPaginas  = 0;  // Quantidade total de páginas para exibir
var nrPagAtual       = 0;  // Pagina atual
var qtdPagina        = 50; // Quantidade de registros por página
var processado       = 0;
 
$(document).ready(function() {
	estadoInicial();
});

// seletores
function estadoInicial() {
	$("#divTela").fadeTo(0,0.1);

	hideMsgAguardo();
	formataCabecalho();
	
	removeOpacidade("divTela");

	highlightObjFocus( $("#frmCab") ); 
	
	$("#frmCab").css({"display":"block"});
	$("#divTela").css({"width":"600px","padding-bottom":"2px"});
	
	// Limpar Tabela
	$("#tbConspb > tbody").html('');
	$('#lable_quantidade').html('P&aacute;gina 0 de 0. Exibindo cr&iacute;ticas de 0 at&eacute; 0 de um total de 0.');
	$('a.paginacaoAnt').hide();
	$('a.paginacaoProx').hide();
	$("#userfile","#frmCab").val("");

	// Zerar o armazenamento de críticas
	aCriticas        = Array();
	qtdTotalRegistro = 0;
	qtdTotalPaginas  = 0;
	nrPagAtual       = 0;
	processado       = 0;
}

// Formata o Cabeçalho da Página
function formataCabecalho() {
	// rotulo
	$('label[for="dspartes"]',"#frmCab").addClass("rotulo").css({"width":"100px"}); 
	$('label[for="dsdopcao"]',"#frmCab").addClass("rotulo").css({"width":"100px"}); 
	$('label[for="userfile"]',"#frmCab").addClass("rotulo").css({"width":"100px"}); 
	
	// campo
	$("#dspartes","#frmCab").css("width","300px").habilitaCampo().focus();
	$("#dsdopcao","#frmCab").css("width","300px").habilitaCampo();
	$("#userfile","#frmCab").css("width","400px").habilitaCampo();
	
	$('input[type="text"],select','#frmCab').limpaFormulario().removeClass('campoErro');
	layoutPadrao();
	return false;	
}

// Formata os campos do detalhamento
function formataCamposDetalhe() {
	// rotulo - Detalhes
	$('label[for="cddotipo"]', "#tbDetalhes").addClass("rotulo").css({"width":"200px"}); 
	$('label[for="nrcontro"]', "#tbDetalhes").addClass("rotulo").css({"width":"200px"}); 
	$('label[for="nrctrlif"]', "#tbDetalhes").addClass("rotulo").css({"width":"200px"}); 
	$('label[for="vlconcil"]', "#tbDetalhes").addClass("rotulo").css({"width":"200px"}); 
	$('label[for="dtmensag"]', "#tbDetalhes").addClass("rotulo").css({"width":"200px"}); 
	$('label[for="dsdahora"]', "#tbDetalhes").addClass("rotulo").css({ "width": "200px" });
	$('label[for="dsorigem"]', "#tbDetalhes").addClass("rotulo").css({ "width": "200px" });
	$('label[for="dsorigemerro"]', "#tbDetalhes").addClass("rotulo").css({"width":"200px"}); 
	$('label[for="dsespeci"]', "#tbDetalhes").addClass("rotulo").css({"width":"200px"}); 
	// rotulo - Debitado
	$('label[for="cddbanco_deb"]', "#frmDebitado").addClass("rotulo").css({"width":"100px"}); 
	$('label[for="cdagenci_deb"]', "#frmDebitado").addClass("rotulo").css({"width":"100px"}); 
	$('label[for="nrdconta_deb"]', "#frmDebitado").addClass("rotulo").css({"width":"100px"}); 
	$('label[for="nrcpfcgc_deb"]', "#frmDebitado").addClass("rotulo").css({"width":"100px"}); 
	$('label[for="nmcooper_deb"]', "#frmDebitado").addClass("rotulo").css({"width":"100px"}); 
	// rotulo - Creditado
	$('label[for="cddbanco_cre"]', "#frmCreditado").addClass("rotulo").css({"width":"100px"}); 
	$('label[for="cdagenci_cre"]', "#frmCreditado").addClass("rotulo").css({"width":"100px"}); 
	$('label[for="nrdconta_cre"]', "#frmCreditado").addClass("rotulo").css({"width":"100px"}); 
	$('label[for="nrcpfcgc_cre"]', "#frmCreditado").addClass("rotulo").css({"width":"100px"}); 
	$('label[for="nmcooper_cre"]', "#frmCreditado").addClass("rotulo").css({"width":"100px"}); 
                        
	// campo - Detalhes
	$("#cddotipo", "#tbDetalhes").css("width","180px").desabilitaCampo(); 
	$("#nrcontro", "#tbDetalhes").css("width","180px").desabilitaCampo(); 
	$("#nrctrlif", "#tbDetalhes").css("width","180px").desabilitaCampo(); 
	$("#vlconcil", "#tbDetalhes").css("width","180px").desabilitaCampo(); 
	$("#dtmensag", "#tbDetalhes").css("width", "180px").desabilitaCampo();
	$("#dsdahora", "#tbDetalhes").css("width", "180px").desabilitaCampo();
	$("#dsorigem", "#tbDetalhes").css("width","180px").desabilitaCampo(); 
	$("#dsorigemerro", "#tbDetalhes").css("width","180px").desabilitaCampo(); 
	$("#dsespeci", "#tbDetalhes").css("width","180px").desabilitaCampo(); 
	// campo - Debitado
	$("#cddbanco_deb", "#frmDebitado").css("width","180px").desabilitaCampo(); 
	$("#cdagenci_deb", "#frmDebitado").css("width","180px").desabilitaCampo(); 
	$("#nrdconta_deb", "#frmDebitado").css("width","180px").desabilitaCampo(); 
	$("#nrcpfcgc_deb", "#frmDebitado").css("width","180px").desabilitaCampo(); 
	$("#nmcooper_deb", "#frmDebitado").css("width","180px").desabilitaCampo(); 
	// campo - Creditado
	$("#cddbanco_cre", "#frmCreditado").css("width","180px").desabilitaCampo(); 
	$("#cdagenci_cre", "#frmCreditado").css("width","180px").desabilitaCampo(); 
	$("#nrdconta_cre", "#frmCreditado").css("width","180px").desabilitaCampo(); 
	$("#nrcpfcgc_cre", "#frmCreditado").css("width","180px").desabilitaCampo(); 
	$("#nmcooper_cre", "#frmCreditado").css("width","180px").desabilitaCampo(); 
	
	layoutPadrao();
	limparCamposDetalhe();
	
	$("#divDetalhes").css({"display":"none"});
	return false;	
}

// Controla o VOLTAR da seleção de um registro
function voltarSelecao(){
	limparCamposDetalhe();
	$("#divConteudo").css("display","block");
	$("#divDetalhes").css("display","none");
	$("#frmDebitado").css({"display":"none"});
	$("#frmCreditado").css({"display":"none"});
}

// Limpa os dados dos campos de detalhamento
function limparCamposDetalhe(){
	// campo - Detalhes
	$("#cddotipo", "#tbDetalhes").val("");
	$("#nrcontro", "#tbDetalhes").val("");
	$("#nrctrlif", "#tbDetalhes").val("");
	$("#vlconcil", "#tbDetalhes").val("");
	$("#dtmensag", "#tbDetalhes").val("");
	$("#dsdahora", "#tbDetalhes").val("");
	$("#dsorigem", "#tbDetalhes").val("");
	$("#dsorigemerro", "#tbDetalhes").val("");
	$("#dsespeci", "#tbDetalhes").val("");
	// campo - Debitado
	$("#cddbanco_deb", "#frmDebitado").val("");
	$("#cdagenci_deb", "#frmDebitado").val("");
	$("#nrdconta_deb", "#frmDebitado").val("");
	$("#nrcpfcgc_deb", "#frmDebitado").val("");
	$("#nmcooper_deb", "#frmDebitado").val("");
	// campo - Creditado
	$("#cddbanco_cre", "#frmCreditado").val("");
	$("#cdagenci_cre", "#frmCreditado").val("");
	$("#nrdconta_cre", "#frmCreditado").val("");
	$("#nrcpfcgc_cre", "#frmCreditado").val("");
	$("#nmcooper_cre", "#frmCreditado").val("");
}

// Atualiza as informações de acordo com a linha selecionada
function selecionarDetalhesLinha(id){
	limparCamposDetalhe();
	
	var obj = aCriticas[id];
	
	// campo - Detalhes 
	$("#cddotipo", "#tbDetalhes").val(obj.cddotipo);
	$("#nrcontro", "#tbDetalhes").val(obj.nrcontro);
	$("#nrctrlif", "#tbDetalhes").val(obj.nrctrlif);
	$("#vlconcil", "#tbDetalhes").val(obj.vlconcil);
	$("#dtmensag", "#tbDetalhes").val(obj.dtmensag);
	$("#dsdahora", "#tbDetalhes").val(obj.dsdahora);
	$("#dsorigem", "#tbDetalhes").val(obj.dsorigem);
	$("#dsorigemerro", "#tbDetalhes").val(obj.dsorigemerro);
	$("#dsespeci", "#tbDetalhes").val(obj.dsespeci);
    // campo - Debitado
	$("#cddbanco_deb", "#frmDebitado") .val(obj.cddbanco_deb);
	$("#cdagenci_deb", "#frmDebitado") .val(obj.cdagenci_deb);
	$("#nrdconta_deb", "#frmDebitado") .val(obj.nrdconta_deb);
	$("#nrcpfcgc_deb", "#frmDebitado") .val(obj.nrcpfcgc_deb);
	$("#nmcooper_deb", "#frmDebitado") .val(obj.nmcooper_deb);
	// campo - Creditado
	$("#cddbanco_cre", "#frmCreditado").val(obj.cddbanco_cre);
	$("#cdagenci_cre", "#frmCreditado").val(obj.cdagenci_cre);
	$("#nrdconta_cre", "#frmCreditado").val(obj.nrdconta_cre);
	$("#nrcpfcgc_cre", "#frmCreditado").val(obj.nrcpfcgc_cre);
	$("#nmcooper_cre", "#frmCreditado").val(obj.nmcooper_cre);
	
	// esconder a tabela e exibir o detalhamento
	$("#divConteudo").css("display","none");
	$("#divDetalhes").css("display","block");	
	$("#frmDebitado").css({"display":"block"});
	$("#frmCreditado").css({"display":"block"});
}

function controlaBotao( opcao ) {
	switch(opcao){
		case "P":
			processarArquivo();
		break;
		
		case "I":
			imprimirRelatorio();
		break;
		
		case "C":
			cancelarOperacao();
		break;
	}
}

function processarArquivo(){
	aCriticas        = Array();
	qtdTotalRegistro = 0;
	qtdTotalPaginas  = 0;
	nrPagAtual       = 0;

	// Limpar Tabela
	$("#tbConspb > tbody").html('');
	// Link para o action do formulario
	var action   = UrlSite + "telas/conspb/manter_rotina.php";
	var form     = $("#frmCab");
	var userFile = $("#userfile","#frmCab");
	
	// Habilitar os campos para que o valor que está no userfile possa ser recuperado
	$("#dspartes","#frmCab").habilitaCampo();
	$("#dsdopcao","#frmCab").habilitaCampo();
	$("#userfile","#frmCab").habilitaCampo();
	
	//Limpar os campos de erro da tela
	$('input,select','#frmCab').removeClass('campoErro');
	
	// Se o campo de arquivo estiver sem valor informado
	if (userFile.val().length == 0) {
		showError("error","Arquivo a ser processado não foi selecionado.","Alerta - Ayllos","focaCampoErro(\"userfile\",\"frmCab\")");
		return false; 
	}

	if($.inArray(userFile.val().split('.').pop().toLowerCase(), ['csv']) == -1) {
		showError("error","Tipo de arquivo invalido. Utilizar o formato '.csv'","Alerta - Ayllos","focaCampoErro(\"userfile\",\"frmCab\")");
		return false; 
	}	
	
	// Mensagem de aguardo...
	showMsgAguardo("Aguarde, processando arquivo ...");
	
	// Configuro o formulário para posteriormente submete-lo
	form.attr("method","post");
	form.attr("action",action);
	form.attr("target","frameBlank");		
	form.submit();
	
	return false;
}

function imprimirRelatorio(){
	if(processado == 0){
		showError("error","Arquivo ainda n&atilde;o foi processado","Alerta - Ayllos","");
		return false;
	}
	
	if(aCriticas.length == 0){
		showError("error","Nenhum erro identificado no arquivo","Alerta - Ayllos","controlaBotao('C')");
		return false;
	}
	
	var csv = "Tipo;Numero de Controle;Numero de Controle IF;Valor;Data;Horario;Origem Erro;Origem;Especie;" + 
	          "Banco Debitado;Agencia Debitado;Conta Debitado;CPF/CNPJ Debitado;Nome Cooperado Debitado;" +
			  "Banco Creditado;Agencia Creditado;Conta Creditado;CPF/CNPJ Creditado;Nome Cooperado Creditado;\r\n"; // Header

	for (var x in aCriticas){
		var obj = aCriticas[x];
		csv += "\"" + obj.cddotipo + "\";"        + // Tipo
			   "\"" + obj.nrcontro + "\";"        + // Número de Controle
			   "\"" + obj.nrctrlif + "\";"        + // Número de Controle IF
			   "\"" + obj.vlconcil + "\";"        + // Valor
			   "\"" + obj.dtmensag + "\";"        + // Data da Mensagem
			   "\"" + obj.dsdahora + "\";"        + // Horário
			   "\"" + obj.dsorigemerro + "\";"    + // Origem Erro
			   "\"" + obj.dsorigem + "\";"        + // Origem
			   "\"" + obj.dsespeci + "\";"        + // Espécie
               "\"" + obj.cddbanco_deb + "\";"    + // Banco Debitado
               "\"" + obj.cdagenci_deb + "\";"    + // Agência Debitado
               "\"" + obj.nrdconta_deb + "\";"    + // Conta Debitado
               "\"" + obj.nrcpfcgc_deb + "\";"    + // CPF/CNPJ Debitado
               "\"" + obj.nmcooper_deb + "\";"    + // Nome Cooperado Debitado
               "\"" + obj.cddbanco_cre + "\";"    + // Banco Creditado
               "\"" + obj.cdagenci_cre + "\";"    + // Agência Creditado
               "\"" + obj.nrdconta_cre + "\";"    + // Conta Creditado
               "\"" + obj.nrcpfcgc_cre + "\";"    + // CPF/CNPJ Creditado
               "\"" + obj.nmcooper_cre + "\";\r\n"; // Nome Cooperado Creditado
	}
	
	// verificar se o navegador é o Internet Explorer < versão 10
	if (navigator.userAgent.search(/msie/i) != "-1") {
		var frame = document.createElement("iframe");
		document.body.appendChild(frame);

		frame.contentWindow.document.open("text/html", "replace");
		frame.contentWindow.document.write("sep=,\r\n" + csv);
		frame.contentWindow.document.close();
		frame.contentWindow.focus();
		frame.contentWindow.document.execCommand("SaveAs", true, "criticas.csv");

		document.body.removeChild(frame);
		
	} else if (window.navigator.msSaveOrOpenBlob) {
		
		// Download de arquivo para o Internet Explorer
		var blob = new Blob([decodeURIComponent(csv)], {type: "text/csv;charset=utf-8;"});
		navigator.msSaveOrOpenBlob(blob, "criticas.csv");
		
	} else {
		
		//Download para os demais navegadores
		var downloadLink = document.createElement("a");
		downloadLink.href = 'data:text/csv;charset=utf-8,' + escape(csv);
		downloadLink.download = "criticas.csv";
		document.body.appendChild(downloadLink);
		downloadLink.click();
		document.body.removeChild(downloadLink);
	}
}

function cancelarOperacao(){
	estadoInicial();
}

function adicionaCritica(obj){
	aCriticas.push(obj);
}

function processaCriticas(){	

	$("#dspartes","#frmCab").desabilitaCampo();
	$("#dsdopcao","#frmCab").desabilitaCampo();
	$("#userfile","#frmCab").desabilitaCampo();
	
	qtdTotalRegistro = aCriticas.length;
	qtdTotalPaginas  = Math.floor(qtdTotalRegistro/qtdPagina);
	nrPagAtual       = 1;
	processado       = 1;
	
	if ( qtdTotalRegistro%qtdPagina > 0 ){
		qtdTotalPaginas++;
	}

	$('a.paginacaoAnt').hide();
	$('a.paginacaoProx').hide();
	
	if(qtdTotalPaginas > 1){
		$('a.paginacaoProx').show();
	}
	
	paginaCriticas();
	hideMsgAguardo();
	
	showError('alerta','Foram encontradas ' + qtdTotalRegistro + ' criticas. Verifique!','Alerta - Ayllos','hideMsgAguardo();');
}

function controlaPaginacaoAnterior(){
	nrPagAtual--;
	/* Se a página for menor que 2, esconde a paginação anterior e exibe apenas a próxima página*/ 
	if(nrPagAtual < 2) {
		nrPagAtual = 1;
		$('a.paginacaoAnt').hide();
	}
	if(qtdTotalPaginas > 1){
		$('a.paginacaoProx').show();
	}
	
	paginaCriticas();
}

function controlaPaginacaoProximo(){
	nrPagAtual++;
	/* Se for a ultima pagina esconde o próximo*/
	if(nrPagAtual >= qtdTotalPaginas){
		nrPagAtual = qtdTotalPaginas;
		$('a.paginacaoProx').hide();
	}
	if(nrPagAtual > 1){
		$('a.paginacaoAnt').show();
	}
	
	paginaCriticas();
}

function paginaCriticas(){
	var nrInicial = 1;
	var nrFinal   = qtdPagina;

	if (nrPagAtual > 1){
		var atualiza = (qtdPagina * (nrPagAtual-1));
		nrInicial = 1 + atualiza;
		nrFinal   = qtdPagina + atualiza;
	}
	
	if(nrFinal > qtdTotalRegistro){
		nrFinal = qtdTotalRegistro;
	}
	// Limpar Tabela
	$("#tbConspb > tbody").html('');
	
	var style_linha = 'padding:0px 5px;border-right:1px dotted #999;font-size:11px;color:#333;';
	
	for(var indice = nrInicial-1; indice < nrFinal; indice++){
		var obj = aCriticas[indice];
		var tr  = '<tr onclick="selecionarDetalhesLinha('.concat(indice).concat(')">');
		// Criar a linha na tabela
		$("#tbConspb > tbody")
			.append($(tr) // Linha
				.attr('id',"id_".concat(obj.nrdlinha))
				.attr('height',"16px")
				.append($('<td>') // Coluna: Tipo
					.attr('style',style_linha + 'width: 130px; text-align:left')
					.text(obj.cddotipo)
				)
				.append($('<td>') // Coluna: Número de Controle
					.attr('style',style_linha + 'width: 250px; text-align:left')
					.text(obj.nrcontro)
				)
				.append($('<td>') // Coluna: Número de Controle IF
					.attr('style',style_linha + 'width: 250px; text-align:left')
					.text(obj.nrctrlif)
				)
				.append($('<td>') // Coluna: Valor
					.attr('style',style_linha + 'width: 100px; text-align:right')
					.text(obj.vlconcil)
				)
				.append($('<td>') // Coluna: Data da mensagem
					.attr('style', style_linha + 'width: 60px; text-align:left')
					.text(obj.dtmensag)
				)
				.append($('<td>') // Coluna: Horário
					.attr('style',style_linha + 'width: 60px; text-align:left')
					.text(obj.dsdahora)
				)
				.append($('<td>') // Coluna: Erro
					.attr('style',style_linha + 'width: 130px; text-align:left')
					.text(obj.dsorigemerro)
				)
				.append($('<td>') // Coluna: Origem
					.attr('style',style_linha + 'width: 220px; text-align:left')
					.text(obj.dsorigem)
				)
				.append($('<td>') // Coluna: Espécie
					.attr('style',style_linha + 'width: 60px; text-align:left')
					.text(obj.dsespeci)
				)
				.append($('<td>') // Coluna: Banco Debitado
					.attr('style',style_linha + 'width: 170px; text-align:right')
					.text(obj.cddbanco_deb)
				)
				.append($('<td>') // Coluna: Agencia Debitada
					.attr('style',style_linha + 'width: 180px; text-align:right')
					.text(obj.cdagenci_deb)
				)
				.append($('<td>') // Coluna: Conta Debitada
					.attr('style',style_linha + 'width: 170px; text-align:right')
					.text(obj.nrdconta_deb)
				)
				.append($('<td>') // Coluna: CPF/CNPJ Debitado
					.attr('style',style_linha + 'width: 180px; text-align:left')
					.text(obj.nrcpfcgc_deb)
				)
				.append($('<td>') // Coluna: Nome Debitado
					.attr('style',style_linha + 'width: 230px; text-align:left')
					.text(obj.nmcooper_deb)
				)
				.append($('<td>') // Coluna: Banco Creditado
					.attr('style',style_linha + 'width: 170px; text-align:right')
					.text(obj.cddbanco_cre)
				)
				.append($('<td>') // Coluna: Agencia Creditada
					.attr('style',style_linha + 'width: 180px; text-align:right')
					.text(obj.cdagenci_cre)
				)
				.append($('<td>') // Coluna: Conta Creditada
					.attr('style',style_linha + 'width: 170px; text-align:right')
					.text(obj.nrdconta_cre)
				)
				.append($('<td>') // Coluna: CPF/CNPJ Creditado
					.attr('style',style_linha + 'width: 180px; text-align:left')
					.text(obj.nrcpfcgc_cre)
				)
				.append($('<td>') // Coluna: Nome Creditado
					.attr('style',style_linha + 'width: 230px; text-align:left')
					.text(obj.nmcooper_cre)
				)
			);
	};
    
	$('#lable_quantidade').html('P&aacute;gina ' + nrPagAtual + ' de ' + qtdTotalPaginas + '. ' + 
	                            'Exibindo cr&iacute;ticas de ' + nrInicial + ' at&eacute; ' + nrFinal + 
								' de um total de ' + qtdTotalRegistro + '.');
	 
	zebradoLinhaTabela($("#tbConspb > tbody > tr"));
}
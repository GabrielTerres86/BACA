/*!
 * FONTE        : conspb.js
 * CRIAÇÃO      : Douglas Quisinski
 * DATA CRIAÇÃO : 30/07/2015
 * OBJETIVO     : Biblioteca de funções da tela CONSPB
 * --------------
 * ALTERAÇÕES   : 01/06/2016 - Ajustado o script para a conciliacao do arquivo que nao sera mais por UPLOAD (Douglas - Chamado 443701)
 * --------------
 */
 
// Armazena as críticas de processamento do arquivo
var aCriticas        = Array();
var qtdTotalRegistro = 0;  // Quantidade total de registros processados
var qtdTotalPaginas  = 0;  // Quantidade total de páginas para exibir
var nrPagAtual       = 0;  // Pagina atual
var qtdPagina        = 50; // Quantidade de registros por página
var nrInicial        = 0;  // Numero da critica inicial
var nrFinal          = 0;  // Numero da critica final

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
	$("#divConteudo").css({"display":"none"});
	$("#tbConspb").css({"display":"none"});
	$("#divBotoes").css({"display":"block"});
	$("#btProcessar","#divBotoes").show();
	
	$("#dspartes","#frmCab").focus();
	
	// Limpar Tabela
	$("#tbConspb > tbody").html('');
	$('#lable_quantidade').html('P&aacute;gina 0 de 0. Exibindo cr&iacute;ticas de 0 at&eacute; 0 de um total de 0.');
	$('a.paginacaoAnt').hide();
	$('a.paginacaoProx').hide();

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
	$('label[for="dspartes"]',"#frmCab").addClass("rotulo").css({"width":"150px"}); 
	$('label[for="dsdopcao"]',"#frmCab").addClass("rotulo").css({"width":"150px"}); 
	$('label[for="nmarquiv"]',"#frmCab").addClass("rotulo").css({"width":"150px"}); 
	
	// campo
	$("#dspartes","#frmCab").css("width","300px").habilitaCampo().focus();
	$("#dsdopcao","#frmCab").css("width","300px").habilitaCampo();
	$("#nmarquiv","#frmCab").css("width","300px").habilitaCampo();
	
	//Define ação para ENTER e TAB no campo do nome do arquivo
	$("#dspartes","#frmCab").unbind('keypress').bind('keypress', function(e) {
		$(this).removeClass('campoErro');
		if (e.keyCode == 9 || e.keyCode == 13) {
			$("#dsdopcao","#frmCab").focus();
			return false;
		}
    });	
	
	//Define ação para ENTER e TAB no campo do nome do arquivo
	$("#dsdopcao","#frmCab").unbind('keypress').bind('keypress', function(e) {
		$(this).removeClass('campoErro');
		if (e.keyCode == 9 || e.keyCode == 13) {
			$("#nmarquiv","#frmCab").focus();
			return false;
		}
    });	
	
	
	//Define ação para ENTER e TAB no campo do nome do arquivo
	$("#nmarquiv","#frmCab").unbind('keypress').bind('keypress', function(e) {
		$(this).removeClass('campoErro');
		if (e.keyCode == 9 || e.keyCode == 13) {
			//Executa função de concluir
			processarArquivo();
			return false;
		}
    });	
	
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
	$("#divBotoes").css("display","block");
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
	$("#divBotoes").css("display","none");
	$("#divDetalhes").css("display","block");	
	$("#frmDebitado").css({"display":"block"});
	$("#frmCreditado").css({"display":"block"});
}

function controlaBotao( opcao ) {
	switch(opcao){
		case "P":
			processarArquivo();
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
	
	//Limpar os campos de erro da tela
	$('input,select','#frmCab').removeClass('campoErro');
	
	var nmarquiv = $("#nmarquiv","#frmCab").val();
	if ( nmarquiv == "" ) {
		showError('error','Nome do Arquivo não informado.','Alerta - Ayllos','$("#nmarquiv","#frmCab").focus();');
		return false;
	}
	showConfirmacao('Deseja conciliar o arquivo "' + nmarquiv + '.csv" ?','Confirma&ccedil;&atilde;o - Ayllos','conciliarPlanilha();','$("#nmarquiv","#frmCab").focus();','sim.gif','nao.gif');
}

function conciliarPlanilha() {
	var nmarquiv = $("#nmarquiv","#frmCab").val();
	var dspartes = $("#dspartes","#frmCab").val();
	var dsdopcao = $("#dsdopcao","#frmCab").val();
	
	$('input,select','#frmCab').removeClass('campoErro').desabilitaCampo();
	
	showMsgAguardo( "Aguarde, conciliando planilha..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/conspb/manter_rotina.php",
        data: {
			nmarquiv: nmarquiv,
			dspartes: dspartes,
			dsdopcao: dsdopcao,
            redirect: "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#nmarquiv','#frmCab').focus();");
        },
        success: function(response) {
            hideMsgAguardo();
			try {
	
				eval(response);
	
			} catch (error) {
					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#nmarquiv','#frmCab').focus();");
				}
			}
    });
    return false;
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
	$("#nmarquiv","#frmCab").desabilitaCampo();
	

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
	nrInicial = 1;
	nrFinal   = qtdPagina;

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
	$("#btProcessar","#divBotoes").hide();
	
	var nmarquiv = $("#nmarquiv","#frmCab").val();
	
	showMsgAguardo( "Aguarde, paginando planilha..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/conspb/paginar_criticas.php",
        data: {
			nmarquiv: nmarquiv,
			nrinicri: nrInicial,
			nrqtdcri: qtdPagina,
            redirect: "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#nmarquiv','#frmCab').focus();");
        },
        success: function(response) {
            hideMsgAguardo();
			try {

				eval(response);
				
			} catch (error) {
					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#nmarquiv','#frmCab').focus();");
				}
			}
    });
    return false;
}

function mostrarCriticas() {
	// Limpar Tabela
	$("#tbConspb > tbody").html('');
	
	var style_linha = 'padding:0px 5px;border-right:1px dotted #999;font-size:11px;color:#333;';
	
	for(var indice in aCriticas){
		var obj = aCriticas[indice];
		var tr  = '<tr onclick="selecionarDetalhesLinha(' + indice + ')">';
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
	
	$("#divConteudo").css({"display":"block"});
	$("#tbConspb").css({"display":"block"});
}

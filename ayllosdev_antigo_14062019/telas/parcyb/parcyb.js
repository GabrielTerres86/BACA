/*!
 * FONTE        : parcyb.js
 * CRIAÇÃO      : Douglas Quisinski
 * DATA CRIAÇÃO : 08/09/2015
 * OBJETIVO     : Biblioteca de funções da tela PARCYB
 * --------------
 * ALTERAÇÕES   : 19/09/2016 - Ajustes para exibicao do codigo de acessoria do CYBER, PRJ. 302 (Jean Michel).
 *
 *                13/01/2017 - inclusão da coluna cdtrscyb (código da transação cyber) da tabela CRAPHIS, PRJ 432 (Jean Calão).
 *                             inclusão das colunas flgjudic e flextjud, da tabela de ndcassessorias de cobrança, PRJ 432 (Jean Calão/Mout´S).
 * --------------
 */

var flgVoltarGeral = 1;

$(document).ready(function() {
	// Estado Inicial da tela
	estadoInicial();
	// Formatar a consulta de assessorias
	formataConsultaAssessoria();
	// Formatar a consulta de motivos CIN
	formataConsultaMotivoCin();
	// Formatar a consulta de Parametrização de Históricos
	formataConsultaParametrizarHistorico();
});

// Função para o estado Inicial da tela de Parametrização do CYBER
function estadoInicial(){
	//Voltar para a tela principal
	flgVoltarGeral = 1;
	
	$("#divTela").fadeTo(0,0.1);

	hideMsgAguardo();
	//Formatação do cabeçalho
	formataCabecalho();
	//Formatação da tela de Assessoria
	formataTelaAssessoria();
	//Formatação da tela de Motivos CIN
	formataTelaMotivoCin();
	//Formatação da tela de Parametrização de Históricos
	formataTelaParametrizarHistorico();
	
	removeOpacidade("divTela");

	highlightObjFocus( $("#frmCab") );
	
	//Exibe cabeçalho e define tamanho da tela
	$("#frmCab").css({"display":"block"});
	$("#divTela").css({"width":"720px","padding-bottom":"2px"});
	
	//Esconder a tela de assessorias
	$("#divTelaAssessoria").css({"display":"none"});
	//Esconder a tela de motivos CIN
	$("#divTelaMotivoCin").css({"display":"none"});
	//Esconder a tela de parametrização dos históricos
	$("#divTelaParametrizarHistorico").css({"display":"none"});
	
	//Esconder os botões da tela
	$("#divBotoes").css({"display":"none"});
	
	//Foca o campo da Opção
	$("#cddotipo","#frmCab").focus();
}

// Formata o Cabeçalho da Página
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

// Função para liberar as informações do formulário de acordo com a configuração desejada
function liberaFormulario(){
	var cddotipo = $("#cddotipo","#frmCab");
	
	if(cddotipo.prop("disabled")){
		// Se o campo estiver desabilitado, não executa a liberação do formulário pois já existe uma ação sendo executada
		return;
	}
	
	cddotipo.desabilitaCampo();
	
	// Validar a opção que foi selecionada na tela
	switch(cddotipo.val()){
		case "A": // Assessorias
			estadoInicialAssessorias();
		break;
		
		case "M": // Motivos CIN
			estadoInicialMotivosCin();
		break;
		
		case "H": // Parametrização de Históricos
			estadoInicialParametrizarHistorico();
		break;
		
		default:
			estadoInicial();
		break;
	}
}

// Função para controlar as ações para quando acionar o botão voltar na tela
function controlaVoltar(){
	// Validar qual a opção que foi selecionada no cabeçalho padrão
	switch($("#cddotipo","#frmCab").val()){
		case "A": // Assessorias
			// Realiza as validação da opção de voltar da assessoria
			controlaVoltarAssessoria();
		break;
		
		case "M": // Motivos CIN
			// Realiza as validação da opção de voltar da motivo CIN
			controlaVoltarMotivoCin();
		break;
		
		case "H": // Parametrização de Históricos
			controlaVoltarParametrizarHistorico();
		break;

		default:
			// Por padrão volta para o estado inicial da tela
			estadoInicial();
		break;
	}
}

// Função para controlar as ações para quando acionar o botão concluir na tela
function controlaConcluir(){
	switch($("#cddotipo","#frmCab").val()){
		case "A": // Assessorias
			// Realiza as validação da opção de concluir da assessoria
			controlaConcluirAssessoria();
		break;
		
		case "M": // Motivos CIN
			// Realiza as validação da opção de concluir da motivo CIN
			controlaConcluirMotivoCin();
		break;
		
		case "H": // Parametrização de Históricos
			// Realiza as validação da opção de concluir da parametrizacao de historicos
			controlaConcluirParametrizarHistorico();
		break;
	}
}

/***********************************************************************************************************
									INÍCIO -> Funções para a tela de Assessoria
***********************************************************************************************************/
// Função para o estado inicial da tela de Assessorias
function estadoInicialAssessorias(){
	//No estado inicial da tela de assessorias, retorna para a principal
	flgVoltarGeral = 1;
	
	hideMsgAguardo();
	
	removeOpacidade("divTela");
	
	// Mostrar a tela de assessorias
	$("#divTelaAssessoria").css({"display":"block"});
	
	highlightObjFocus( $("#frmCabAssessoria","#divTelaAssessoria") ); 
	
	//Esconde a consulta e limpa a tabela
	$("#divConsultaAssessoria","#divTelaAssessoria").css({"display":"none"});
	//$("#divExclusaoAssessoria","#divTelaAssessoria").css({"display":"none"});
	$("#tbCadcas > tbody").html("");
	
	//Esconde cadastro e os botões
	$("#frmAssessoria","#divTelaAssessoria").css({"display":"none"});
	$("#divBotoes").css({"display":"block"});
	
	//Exibe cabeçalho e define tamanho da tela
	$("#frmCabAssessoria","#divTelaAssessoria").css({"display":"block"});
	
	//Limpa os campos do formulário e remove o erro dos campos
	$('input[type="text"],select','#frmAssessoria').limpaFormulario().removeClass('campoErro');
	//Foca o campo da Opção
	$("#cddopcao_assessoria","#frmCabAssessoria").habilitaCampo().val("CA").focus();
	//Esconde o botão de concluir
	$("#btConcluir","#divBotoes").hide();
	
	//retira o Check dos campos flgjudic e flextjud
	$("#flgjudic","#frmAssessoria").removeAttr("checked","checked");
	$("#flextjud","#frmAssessoria").removeAttr("checked","checked");
}

// Função para formatar a tela de assessoria
function formataTelaAssessoria(){
	//Formatação do cabeçalho e formulário
	formataCabecalhoAssessoria();
	formataCadastroAssessoria();
}

// Formata o Cabeçalho da tela de Assessorias
function formataCabecalhoAssessoria() {
	// rotulo
	$('label[for="cddopcao_assessoria"]',"#frmCabAssessoria").addClass("rotulo").css({"width":"100px"}); 
	
	// campo
	$("#cddopcao_assessoria","#frmCabAssessoria").css("width","500px").habilitaCampo();
	$('input[type="text"],select','#frmCabAssessoria').limpaFormulario().removeClass('campoErro');
	layoutPadrao();
	
	//Define ação para ENTER e TAB no campo Opção
	$("#cddopcao_assessoria","#frmCabAssessoria").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			//Executa função do botão OK
			liberaAcaoAssessoria();
			return false;
		}
    });	

	//Define ação para CLICK no botão de OK da tela de Assessoria
	$("#btnOkAssessoria","#frmCabAssessoria").unbind('click').bind('click', function(e) {
		//Executa função do botão OK
		liberaAcaoAssessoria();
		return false;
    });	
	
	return false;	
}

// Função para formatar os campos da tela de cadastro de assessoria
function formataCadastroAssessoria(){
	// rotulo
	$('label[for="cdassessoria"]',"#frmAssessoria").addClass("rotulo").css({"width":"150px"}); 
	$('label[for="nmassessoria"]',"#frmAssessoria").addClass("rotulo").css({"width":"150px"}); 
	$('label[for="cdasscyb"]', "#frmAssessoria").addClass("rotulo").css({ "width": "150px" });
	$('label[for="flgjudic"]', "#frmAssessoria").addClass("rotulo").css({ "width": "150px" });
	$('label[for="flextjud"]', "#frmAssessoria").addClass("rotulo").css({ "width": "150px" });
	$('label[for="cdsigcyb"]', "#frmAssessoria").addClass("rotulo").css({ "width": "150px" });
	// campo
	$("#cdassessoria","#frmAssessoria").css("width","100px").habilitaCampo();
	$("#nmassessoria","#frmAssessoria").addClass("alphanum").css("width","500px").attr("maxlength","50").habilitaCampo();
	$("#cdasscyb", "#frmAssessoria").css("width", "100px").habilitaCampo();
	$("#flgjudic", "#frmAssessoria").css("width", "50px").habilitaCampo();
	$("#flextjud", "#frmAssessoria").css("width", "50px").habilitaCampo();
	$("#cdsigcyb", "#frmAssessoria").css("width", "100px").habilitaCampo();

	$('input[type="text"],select','#frmAssessoria').limpaFormulario().removeClass('campoErro');
	layoutPadrao();

	//Define ação para o campo de código da assessoria
	$("#cdassessoria","#frmAssessoria").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Quando ENTER ou TAB realiza a busca da assessoria pelo código
			buscaAssessoria();
			return false;
		}
	});

    //Define ação para o campo de código da assessoria CYBER
	$("#cdasscyb", "#frmAssessoria").unbind('keypress').bind('keypress', function (e) {
	    if (e.keyCode == 9 || e.keyCode == 13) {
	        // Quando ENTER ou TAB coloca foco no campo de nome de acessoria
	        $("#nmassessoria", "#frmAssessoria").focus();
	        return false;
	    }
	});
	
	//Define ação para o campo de código da assessoria
	$("#cdassessoria","#frmAssessoria").unbind('blur').bind('blur', function(e) {
		// Quando ENTER ou TAB realiza a busca da assessoria pelo código
		buscaAssessoria();
		return false;
    });	

	//Define ação para o campo de nome da assessoria
	$("#nmassessoria","#frmAssessoria").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			$("#fljudic", "#frmAssessoria").focus();
			return false;
		}
    });	
	
	
	//Define ação para o campo flag judicial
	$("#flgjudic","#frmAssessoria").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			//Quando ENTER ou TAB define o foco para o campo Extra Judicial		
			 $("#flextjud", "#frmAssessoria").focus();
		     return false;
		}
    });	
	
	//Define ação para o campo de flag extra judicial
	$("#flextjud","#frmAssessoria").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			//Quando ENTER ou TAB executa a ação de concluir do formulário
			controlaConcluirAssessoria();
			return false;
		}
    });	
	return false;
}

// Formata a tela de Consulta da Página
function formataConsultaAssessoria() {
	// Tabela
	$("#divConteudo","#divTelaAssessoria").css({"display":"block"});

    var divRegistro = $("div.divRegistros", "#tabCadcas");
	var tabela      = $("table", divRegistro );
	var linha       = $("table > tbody > tr", divRegistro );

    $("#tabCadcas").css({"margin-top":"5px"});
	divRegistro.css({"height":"290px","width":"700px","padding-bottom":"2px"});

	var ordemInicial = new Array();
	
	//Define a largura dos campos
	var arrayLargura = new Array();
    arrayLargura[0] = "100px";
    arrayLargura[1] = "100px";
	arrayLargura[2] = "200px";
	arrayLargura[3] = "80px";
	arrayLargura[4] = "80px";
	arrayLargura[5] = "100px";
	
	//Define a posição dos elementos nas células da linha
    var arrayAlinha = new Array();
	arrayAlinha[0] = "left";
	arrayAlinha[1] = "left";
	arrayAlinha[2] = "center";
	arrayAlinha[3] = "center";
	arrayAlinha[4] = "center";
	arrayAlinha[5] = "left";

	//Aplica as informações na tabela
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);
	return false;
}

// Função para liberar as informações da tela de assessoria
function liberaAcaoAssessoria(){
	var cddopcao = $("#cddopcao_assessoria","#frmCabAssessoria");
	cddopcao.desabilitaCampo();
	//Quando executar a tela de assessoria, retorna para a tela de assessorias
	flgVoltarGeral = 0;

	$("#divConsultaAssessoria").css({"display":"none"});
	//$("#divExclusaoAssessoria").css({"display":"none"});
	$("#frmAssessoria").css({"display":"none"});
	
	// Esconder o botão de Concluir
	$("#btConcluir","#divBotoes").hide();

	//Validar a opção selecionada na tela
	if(cddopcao.val() == "CA") {
		// executa a consulta, listando as assessorias cadastradas
		executaConsultaAssessorias();
	} else if (cddopcao.val() == "EA"){
		// executa a consulta, listando as assessorias cadastradas (Exclusão)
		executaConsultaAssessoriasExclusao();
	} else {
		$("#frmAssessoria").css({"display":"block"});
		$("#divBotoes").css({"display":"block"});
		$("#btConcluir","#divBotoes").show();
		
		$("#cdassessoria","#frmAssessoria").habilitaCampo().focus();
		if(cddopcao.val() == "IA"){
			// Quando for inclusão desabilita o código para que seja possivel informar apenas o nome da assessoria
			$("#cdassessoria","#frmAssessoria").desabilitaCampo();
			$("#cdasscyb", "#frmAssessoria").focus();
		    //$("#nmassessoria","#frmAssessoria").focus();
		}
		
		// Verificar a opção para exibir a lupa de pesquisa
		if(cddopcao.val() == "AA"){
			$("#pesqassess").css({"display":"block"});
		} else {
			$("#pesqassess").css({"display":"none"});
		}
	}
}

// Função para o botão voltar
function controlaVoltarAssessoria(){
	if (flgVoltarGeral == 1) {
		// Quando não for executado nada na tela de assessoria, retorna para a tela principal
		estadoInicial();
	} else {
		// Quando ocorrer alguma ação na tela de assessoria, retorna para o estado inicial da tela de assessorias
		estadoInicialAssessorias();
	}
}

// Função para o botão Concluir
function controlaConcluirAssessoria(){
	//Validação do campo código para quando a opção não for incluir
	if($("#cddopcao_assessoria","#frmCabAssessoria").val() != "IA" && $("#cdassessoria","#frmAssessoria").val() == "") {
		showError('error','C&oacute;digo inv&aacute;lido!','Campo obrigat&oacute;rio','$("#cdassessoria","#frmAssessoria").focus();');
		return false;
	}
	
    //Validação da descrição informada
	if ($("#cdasscyb", "#frmAssessoria").val() == "") {
	    showError('error', 'C&oacute;digo CYBER inv&aacute;lido!!', 'Campo obrigat&oacute;rio', '$("#cdasscyb","#frmAssessoria").focus();');
	    return false;
	}

	//Validação da descrição informada
	if($("#nmassessoria","#frmAssessoria").val() == "") {
		showError('error','Nome de Assessoria inv&aacute;lido!','Campo obrigat&oacute;rio','$("#nmassessoria","#frmAssessoria").focus();');
		return false;
	}
	
	if($("#flgjudic","#frmAssessoria").val() == "") {
		showError('error','Indicador de cobranca judicial inv&aacutelido!','Campo obrigat&oacute;rio','$("#flgjudic","#frmAssessoria").focus();');
		return false;
	}
	
	//Verifica a opção
	if($("#cddopcao_assessoria","#frmCabAssessoria").val() == "AA") {
		//Quando for alteração, solicita confirmação
		showConfirmacao('Confirma a altera&ccedil;&atilde;o da assessoria?','Confirma&ccedil;&atilde;o - Ayllos','confirmouOperacaoAssessoria();','','sim.gif','nao.gif');
	} else {
		//Se não está alterando executa a ação
		confirmouOperacaoAssessoria();
	}
}

function confirmouOperacaoAssessoria(){
	//Recupera a opção
	var cddopcao = $("#cddopcao_assessoria","#frmCabAssessoria").val();
	var mensagem = "Aguarde ...";
	
	var vflgjudic = ($("#flgjudic", "#frmAssessoria").prop("checked")) ? "1" : "0";	
	var vflextjud = ($("#flextjud", "#frmAssessoria").prop("checked")) ? "1" : "0";	
	
	//Atualiza a mensagem que será exibida
	if(cddopcao == "IA") {
		mensagem = "Aguarde, incluindo assessoria ...";
	} else {
		mensagem = "Aguarde, alterando assessoria ...";
	}
	//mostra mensagem e finaliza a operação
	showMsgAguardo( mensagem );	

	var nmassessoria = $("#nmassessoria","#frmAssessoria").val()
														  .replace(/[ÀÁÂÃÄÅ]/g,"A")
	                                                      .replace(/[àáâãäå]/g,"a")
														  .replace(/[ÒÓÔÕÖØ]/g,"O")
														  .replace(/[òóôõöø]/g,"o")
														  .replace(/[ÈÉÊË]/g,"E")
														  .replace(/[èéêë]/g,"e")
														  .replace(/[Ç]/g,"C")
														  .replace(/[ç]/g,"c")
														  .replace(/[ÌÍÎÏ]/g,"I")
														  .replace(/[ìíîï]/g,"i")
														  .replace(/[ÙÚÛÜ]/g,"U")
														  .replace(/[ùúûü]/g,"u")
														  .replace(/[ÿ]/g,"y")
														  .replace(/[Ñ]/g,"N")
														  .replace(/[ñ]/g,"n")
														  .replace(/[^A-z0-9\s\!\@\$\%\*\(\)\-\_\=\+\[\]\{\}\?\;\:\.\,\/\>\<]/g,"");														  														 
												  

	manterAssessoria(cddopcao, $("#cdassessoria", "#frmAssessoria").val(), nmassessoria, $("#cdasscyb", "#frmAssessoria").val(), vflgjudic, vflextjud, $("#cdsigcyb", "#frmAssessoria").val());
}

// Função para executar a busca de todas as acessorias
function executaConsultaAssessorias(){
	//Mostrar a consulta e botões
	$("#divConsultaAssessoria").css({"display":"block"});
	$("#divBotoes").css({"display":"block"});
	//Esconder o botão de concluir, pois na consulta exibe apenas a opção de voltar
	$("#btConcluir","#divBotoes").hide();
	//Limpar a tabela
	$("#tbCadcas > tbody").html("");
	//Iniciar a busca das assessorias
	showMsgAguardo( "Aguarde, carregando assessorias..." );	
	manterAssessoria("CA","","");	
}

function executaConsultaAssessoriasExclusao(){
	//Mostrar a consulta e botões
	$("#divConsultaAssessoria").css({"display":"block"});
	$("#divBotoes").css({"display":"block"});
	//Esconder o botão de concluir, pois na consulta exibe apenas a opção de voltar
	$("#btConcluir","#divBotoes").hide();
	//Limpar a tabela
	$("#tbCadcas > tbody").html("");
	//Iniciar a busca das assessorias
	showMsgAguardo( "Aguarde, carregando assessorias..." );	
	//Verificar
	manterAssessoria("EA","","");
}

// Função para criar a linha com as assessorias cadastradas
function criaLinhaAssessoria(cdassessoria, nmassessoria, cdasscyb, flgjudic, flextjud, cdsigcyb) {
	var field_flgjudic = $('<input>', { type:"checkbox", name: "flgjudic_a", id: "flgjudic_a"});
	var field_flextjud = $('<input>', { type:"checkbox", name: "flextjud_a", id: "flextjud_a"});	
	
	if (flgjudic == 1) {
		field_flgjudic.attr("checked","checked");
		field_flgjudic.attr("disabled","disabled");
	} else {
		field_flgjudic.removeAttr("checked","checked");
		field_flgjudic.attr("disabled","disabled");
	}
	
	if (flextjud == 1) {
		field_flextjud.attr("checked","checked");
		field_flextjud.attr("disabled","disabled");
	} else {
		field_flextjud.removeAttr("checked","checked");
		field_flextjud.attr("disabled","disabled");
	}
	
	// Criar a linha na tabela
	$("#tbCadcas > tbody")
		.append($('<tr>') // Linha
			.attr('id',"id_".concat(cdassessoria))
			.append($('<td>') // Coluna: Código da Assessoria
				.attr('style','width: 112px; text-align:right') //13%
				.text(cdassessoria)
			)
            .append($('<td>') // Coluna: Código da Assessoria CYBER
				.attr('style', 'width: 112px; text-align:right') // 22%
				.text(cdasscyb)
			)
			.append($('<td>') // Coluna: Nome da Assessoria
				.attr('style', 'width: 223px; text-align:left') // 45%
				.text(nmassessoria)
			)
        	.append($('<td>') // Coluna: Flag Cobranca Judicial
				.attr('style', 'width: 90px; text-align:right') //10%
				.append(field_flgjudic)			
			)
            .append($('<td>') // Coluna: Flag Cobranca Extra Judicial
				.attr('style', 'width: 60px; text-align:right') //10%
				.append(field_flextjud)				
			)
			.append($('<td>') // Coluna: Código da Sigla Cyber
				.attr('style', 'width: 60px; text-align:left') //10%
				.text(cdsigcyb)				
			)
			.append($('<td>') // Coluna: Botão para REMOVER
				.attr('style', ' text-align:center')
				.append($('<img onclick="solicitarMensagemExclusaoAssessoria(' + cdassessoria + ')">')
					.attr('src', UrlImagens + 'geral/btn_excluir.gif')
				)
			)
		);
}

function criaLinhaAssessoriaConsulta(cdassessoria, nmassessoria, cdasscyb, flgjudic, flextjud, cdsigcyb) {
	var field_flgjudic = $('<input>', { type:"checkbox", name: "flgjudic_a", id: "flgjudic_a"});
	var field_flextjud = $('<input>', { type:"checkbox", name: "flextjud_a", id: "flextjud_a"});
	
	if (flgjudic == 1) {
		field_flgjudic.attr("checked","checked");
		field_flgjudic.attr("disabled","disabled");
	} else {
		field_flgjudic.removeAttr("checked","checked");
		field_flgjudic.attr("disabled","disabled");
	}
	
	if (flextjud == 1) {
		field_flextjud.attr("checked","checked");
		field_flextjud.attr("disabled","disabled");
	} else {
		field_flextjud.removeAttr("checked","checked");
		field_flextjud.attr("disabled","disabled");
	}
	
		
	// Criar a linha na tabela
	
	$("#tbCadcas > tbody")
		.append($('<tr>') // Linha
			.attr('id',"id_".concat(cdassessoria))
			.append($('<td>') // Coluna: Código da Assessoria
				.attr('style','width: 100px; text-align:right')
				.text(cdassessoria)
			)
            .append($('<td>') // Coluna: Código da Assessoria CYBER
				.attr('style', 'width: 100px; text-align:right')
				.text(cdasscyb)
			)
			.append($('<td>') // Coluna: Nome da Assessoria
				.attr('style','width: 200px; text-align:left')
				.text(nmassessoria)
			)
            .append($('<td>') // Coluna: Flag cobranca judicial
			    .attr('style', 'width: 80px; text-align:center')
				.append(field_flgjudic)
				//.text(flgjudic)
			)
            .append($('<td>') // Coluna: Flag cobranca extra judicial
				.attr('style', 'width: 80px; text-align:center')		
                .append(field_flextjud)				
				//.text(flextjud)
			)
			.append($('<td>') // Coluna: Sigla no Cyber
				.attr('style', 'width: 80px; text-align:center')		
                .text(cdsigcyb)
			)
		);
}

// Função para solicitar confirmação da exclusão da assessoria
function solicitarMensagemExclusaoAssessoria(cdassessoria){
	showConfirmacao('Confirma a exclus&atilde;o da assessoria?','Confirma&ccedil;&atilde;o - Ayllos','excluirAssessoria(' + cdassessoria + ');','','sim.gif','nao.gif');
}

// Função para realizar a requisição de exclusão da assessoria
function excluirAssessoria(cdassessoria){
	if(cdassessoria == "" ) {
		showError('error','Assessoria inv&aacute;lida!','Alerta - Ayllos','');
		return false;
	}
	//Exibe mensagem e solicita a exclusão
	showMsgAguardo( "Aguarde, excluindo assessoria ..." );	
	manterAssessoria("EA",cdassessoria,"");
}

// Função para manter rotina (Consultar/Incluir/Alterar/Excluir)
function manterAssessoria(cddopcao, cdassessoria, nmassessoria, cdasscyb, flgjudic, flextjud, cdsigcyb) {
    //Requisição para processar a opção que foi selecionada
	
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/parcyb/manter_rotina_assessoria.php",
        data: {
            cddopcao:     cddopcao,
			cdassessoria: cdassessoria,
			nmassessoria: nmassessoria,
			cdasscyb:     cdasscyb,
			flgjudic:     flgjudic,
            flextjud:     flextjud,
			cdsigcyb:	  cdsigcyb,
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

// Função executada quando sair do campo de código de assessoria na opção Alterar
function buscaAssessoria(){
	var cdassessoria = $("#cdassessoria").val().trim();
	//Valida o código da assessoria
	if(cdassessoria != "") {
		//Busca as informações do código informado
		manterAssessoria("CA",cdassessoria,"");		
	}
}

// Função para abrir a pesquisa de asessorias
function mostrarPesquisaAssessoria(){
	//Definição dos filtros
	var filtros	= "Código Assessoria;cdassessoria;50px;N;;N;|Nome Assessoria;nmassessoria;200px;S;;S;descricao";
	//Campos que serão exibidos na tela
	var colunas = 'Código;cdassessoria;15%;right|Código CYBER;cdasscyb;15%;right|Nome Assessoria;nmassessoria;45%;left|Judicial;flgjudic;10%;center|Extra Judicial;flextjud;10%;center';
	//Exibir a pesquisa
	mostraPesquisa("PARCYB", "PARCYB_BUSCAR_ASSESSORIAS", "Assessorias","100",filtros,colunas);
}

/***********************************************************************************************************
									FIM -> Funções para a tela de Assessoria
***********************************************************************************************************/

/***********************************************************************************************************
									INÍCIO -> Funções para a tela de Motivos CIN
***********************************************************************************************************/
// Função para o estado inicial da tela de Motivos CIN
function estadoInicialMotivosCin(){
	//No estado inicial da tela de motivos CIN, retorna para a principal
	flgVoltarGeral = 1;
	
	hideMsgAguardo();
	
	removeOpacidade("divTela");
	
	// Mostrar a tela de motivos CIN
	$("#divTelaMotivoCin").css({"display":"block"});
	
	highlightObjFocus( $("#frmCabMotivoCin","#divTelaMotivoCin") ); 
	
	//Esconde a consulta e limpa a tabela
	$("#divConsultaMotivosCin","#divTelaMotivoCin").css({"display":"none"});
	$("#tbCadcmt > tbody").html("");
	
	
	//Esconde cadastro e os botões
	$("#frmMotivoCin","#divTelaMotivoCin").css({"display":"none"});
	$("#divBotoes").css({"display":"block"});
	
	//Exibe cabeçalho e define tamanho da tela
	$("#frmCabMotivoCin","#divTelaMotivoCin").css({"display":"block"});
	
	//Limpa os campos do formulário e remove o erro dos campos
	$('input[type="text"],select','#frmMotivoCin').limpaFormulario().removeClass('campoErro');
	//Foca o campo da Opção
	$("#cddopcao_motivo_cin","#frmCabMotivoCin").habilitaCampo().val("CM").focus();
	//Esconde o botão de concluir
	$("#btConcluir","#divBotoes").hide();
}

// Função para formatar a tela de motivo CIN
function formataTelaMotivoCin(){
	//Formatação do cabeçalho e formulário
	formataCabecalhoMotivoCin();
	formataCadastroMotivoCin();
}

// Formata o Cabeçalho da tela de Motivos CIN
function formataCabecalhoMotivoCin() {
	// rotulo
	$('label[for="cddopcao_motivo_cin"]',"#frmCabMotivoCin").addClass("rotulo").css({"width":"100px"}); 
	
	// campo
	$("#cddopcao_motivo_cin","#frmCabMotivoCin").css("width","500px").habilitaCampo();
	$('input[type="text"],select','#frmCabMotivoCin').limpaFormulario().removeClass('campoErro');
	layoutPadrao();
	
	//Define ação para ENTER e TAB no campo Opção
	$("#cddopcao_motivo_cin","#frmCabMotivoCin").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			//Executa função do botão OK
			liberaAcaoMotivoCin();
			return false;
		}
    });	

	//Define ação para CLICK no botão de OK da tela de Motivo CIN
	$("#btnOkMotivoCin","#frmCabMotivoCin").unbind('click').bind('click', function(e) {
		//Executa função do botão OK
		liberaAcaoMotivoCin();
		return false;
    });	
	
	return false;	
}

// Formata o cadastro de Motivos CIN
function formataCadastroMotivoCin() {
	// rotulo
	$('label[for="cdmotivocin"]',"#frmMotivoCin").addClass("rotulo").css({"width":"150px"}); 
	$('label[for="dsmotivocin"]',"#frmMotivoCin").addClass("rotulo").css({"width":"150px"}); 
	
	// campo
	$("#cdmotivocin","#frmMotivoCin").css("width","100px").habilitaCampo();
	$("#dsmotivocin","#frmMotivoCin").addClass("alphanum").css("width","500px").attr("maxlength","100").habilitaCampo();
	
	$('input[type="text"],select','#frmMotivoCin').limpaFormulario().removeClass('campoErro');
	layoutPadrao();

	//Define ação para o campo de código da motivo CIN
	$("#cdmotivocin","#frmMotivoCin").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Quando ENTER ou TAB realiza a busca da motivo CIN pelo código
			buscaMotivoCin();
			return false;
		}
    });	

	//Define ação para o campo de código da motivo CIN
	$("#cdmotivocin","#frmMotivoCin").unbind('blur').bind('blur', function(e) {
		buscaMotivoCin();
		return false;
    });	
	
	//Define ação para o campo de nome da motivo CIN
	$("#dsmotivocin","#frmMotivoCin").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			//Quando ENTER ou TAB executa a ação de concluir do formulário
			controlaConcluirMotivoCin();
			return false;
		}
    });	
	
	return false;
}
// Formata a tela de Consulta da Página
function formataConsultaMotivoCin() {
	// Tabela
	$("#divConteudo","#divTelaMotivoCin").css({"display":"block"});

    var divRegistro = $("div.divRegistros", "#tabCadcmt");
	var tabela      = $("table", divRegistro );
	var linha       = $("table > tbody > tr", divRegistro );

    $("#tabCadcmt").css({"margin-top":"5px"});
	divRegistro.css({"height":"290px","width":"700px","padding-bottom":"2px"});

	var ordemInicial = new Array();
	
	//Define a largura dos campos
	var arrayLargura = new Array();
    arrayLargura[0] = "80px";
    arrayLargura[1] = "";
    arrayLargura[2] = "80px";

	//Define a posição dos elementos nas células da linha
    var arrayAlinha = new Array();
	arrayAlinha[0] = "left";
	arrayAlinha[1] = "left";
	arrayAlinha[2] = "center";

	//Aplica as informações na tabela
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);
	return false;
}

// Função para liberar as informações da tela de motivos CIN
function liberaAcaoMotivoCin(){
	var cddopcao = $("#cddopcao_motivo_cin","#frmCabMotivoCin");
	cddopcao.desabilitaCampo();
	flgVoltarGeral = 0;

	$("#divConsultaMotivosCin").css({"display":"none"});
	$("#frmMotivoCin").css({"display":"none"});
	$("#divBotoes").css({"display":"none"});
	$("#btConcluir","#divBotoes").hide();
	
	//Validar a opção selecionada na tela
	if(cddopcao.val() == "CM") {
		// executa a consulta, listando as motivos CIN cadastrados
		executaConsultaMotivosCin();
	} else {
		$("#frmMotivoCin").css({"display":"block"});
		$("#divBotoes").css({"display":"block"});
		$("#btConcluir","#divBotoes").show();
		
		$("#cdmotivocin","#frmMotivoCin").habilitaCampo().focus();
		if(cddopcao.val() == "IM"){
			// Quando for inclusão desabilita o código para que seja possivel informar apenas o motivo CIN
			$("#cdmotivocin","#frmMotivoCin").desabilitaCampo();
			$("#dsmotivocin","#frmMotivoCin").focus();
		}
		
		// Verificar a opção para exibir a lupa de pesquisa
		if(cddopcao.val() == "AM"){
			$("#pesqmotcin").css({"display":"block"});
		} else {
			$("#pesqmotcin").css({"display":"none"});
		}
	}
}

// Função para o botão voltar
function controlaVoltarMotivoCin(){
	if (flgVoltarGeral == 1) {
		// Quando não for executado nada na tela de motivos CIN, retorna para a tela principal
		estadoInicial();
	} else {
		// Quando ocorrer alguma ação na tela de motivo CIN, retorna para o estado inicial da tela de motivos CIN
		estadoInicialMotivosCin();
	}
}

// Função para o botão Concluir
function controlaConcluirMotivoCin(){
	//Validação do campo código para quando a opção não for incluir
	if($("#cddopcao_motivo_cin","#frmCabMotivoCin").val() != "IM" && $("#cdmotivocin","#frmMotivoCin").val() == "") {
		showError('error','C&oacute;digo inv&aacute;lido!','Campo obrigat&oacute;rio','$("#cdmotivocin","#frmMotivoCin").focus();');
		return false;
	}
	
	//Validação da descrição informada
	if($("#dsmotivocin","#frmMotivoCin").val() == "") {
		showError('error','Motivo CIN inv&aacute;lido!','Campo obrigat&oacute;rio','$("#dsmotivocin","#frmMotivoCin").focus();');
		return false;
	}
	
	//Verifica a opção
	if($("#cddopcao_motivo_cin","#frmCabMotivoCin").val() == "AM") {
		//Quando for alteração, solicita confirmação
		showConfirmacao('Confirma a altera&ccedil;&atilde;o do motivo CIN?','Confirma&ccedil;&atilde;o - Ayllos','confirmouOperacaoMotivoCin();','','sim.gif','nao.gif');
	} else {
		//Se não está alterando executa a ação
		confirmouOperacaoMotivoCin();
	}
}

function confirmouOperacaoMotivoCin(){
	//Recupera a opção
	var cddopcao     = $("#cddopcao_motivo_cin","#frmCabMotivoCin").val();
	var mensagem = "Aguarde ...";
	
	//Atualiza a mensagem que será exibida
	if(cddopcao == "IM") {
		mensagem = "Aguarde, incluindo motivo CIN ...";
	} else {
		mensagem = "Aguarde, alterando motivo CIN ...";
	}
	//mostra mensagem e finaliza a operação
	showMsgAguardo( mensagem );	
	
	var dsmotivo = $("#dsmotivocin","#frmMotivoCin").val()
                                                    .replace(/[ÀÁÂÃÄÅ]/g,"A")
									   			    .replace(/[àáâãäå]/g,"a")
										     		.replace(/[ÒÓÔÕÖØ]/g,"O")
												    .replace(/[òóôõöø]/g,"o")
												    .replace(/[ÈÉÊË]/g,"E")
												    .replace(/[èéêë]/g,"e")
												    .replace(/[Ç]/g,"C")
												    .replace(/[ç]/g,"c")
												    .replace(/[ÌÍÎÏ]/g,"I")
												    .replace(/[ìíîï]/g,"i")
												    .replace(/[ÙÚÛÜ]/g,"U")
												    .replace(/[ùúûü]/g,"u")
												    .replace(/[ÿ]/g,"y")
												    .replace(/[Ñ]/g,"N")
												    .replace(/[ñ]/g,"n")
												    .replace(/[^A-z0-9\s\!\@\$\%\*\(\)\-\_\=\+\[\]\{\}\?\;\:\.\,\/\>\<]/g,"");
	
	manterMotivoCin(cddopcao,$("#cdmotivocin","#frmMotivoCin").val(),dsmotivo);
}


// Função para executar a busca de todas os motivos CIN
function executaConsultaMotivosCin(){
	//Mostrar a consulta e botões
	$("#divConsultaMotivosCin").css({"display":"block"});
	$("#divBotoes").css({"display":"block"});
	//Esconder o botão de concluir, pois na consulta exibe apenas a opção de voltar
	$("#btConcluir","#divBotoes").hide();
	//Limpar a tabela
	$("#tbCadcmt > tbody").html("");
	//Iniciar a busca dos motivos CIN
	showMsgAguardo( "Aguarde, carregando motivos CIN ..." );	
	manterMotivoCin("CM","","");	
}

//Função para criar a linha com os motivos CIN cadastrados
function criaLinhaMotivoCin(cdmotivo,dsmotivo){
	// Criar a linha na tabela
	$("#tbCadcmt > tbody")
		.append($('<tr>') // Linha
			.attr('id',"id_".concat(cdmotivo))
			.append($('<td>') // Coluna: Código do Motivo
				.attr('style','width: 80px; text-align:right')
				.text(cdmotivo)
			)
			.append($('<td>') // Coluna: Motivo CIN
				.attr('style','text-align:left')
				.text(dsmotivo)
			)
			.append($('<td>') // Coluna: Botão para REMOVER
				.attr('style','width: 80px; text-align:center')
				.append($('<img onclick="solicitarMensagemExclusaoMotivoCin(' + cdmotivo + ')">')
					.attr('src', UrlImagens + 'geral/panel-delete_16x16.gif')
				)
			)
		);
}

// Função para solicitar confirmação da exclusão do motivo CIN
function solicitarMensagemExclusaoMotivoCin(cdmotivo){
	showConfirmacao('Confirma a exclus&atilde;o do motivo CIN?','Confirma&ccedil;&atilde;o - Ayllos','excluirMotivoCin(' + cdmotivo + ');','','sim.gif','nao.gif');	
}

//Função para realizar a requisição de exclusão do motivo CIN
function excluirMotivoCin(cdmotivo){
	if(cdmotivo == "" ) {
		showError('error','Motivo CIN inv&aacute;lida!','Alerta - Ayllos','');
		return false;
	}
	//Exibe mensagem e solicita a exclusão
	showMsgAguardo( "Aguarde, excluindo motivo CIN ..." );	
	manterMotivoCin("EM",cdmotivo,"");
}

//Função para manter rotina (Consultar/Incluir/Alterar/Excluir)
function manterMotivoCin(cddopcao,cdmotivo,dsmotivo){
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/parcyb/manter_rotina_motivo_cin.php",
        data: {
            cddopcao:    cddopcao,
			cdmotivocin: cdmotivo,
			dsmotivocin: dsmotivo,
            redirect:    "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function(response) {
            hideMsgAguardo();
			eval(response);
        }
    });
    return false;	
}

//Função executada quando sair do campo de código de motivo CIN na opção Alterar
function buscaMotivoCin(){
	var cdmotivo = $("#cdmotivocin").val();
	//Valida o código do motivo CIN
	if(cdmotivo != "") {
		//Busca as informaçoes do código informado
		manterMotivoCin("CM",cdmotivo,"");		
	}
}

// Função para abrir a pesquisa de motivos CIN
function mostrarPesquisaMotivoCin(){
	//Definição dos filtros
	var filtros	= "Código;cdmotivocin;50px;N;;N;|Motivo CIN;dsmotivocin;200px;S;;S;descricao";
	//Campos que serão exibidos na tela
	var colunas = 'Código;cdmotivo;20%;right|Motivo CIN;dsmotivo;80%;left';			
	//Exibir a pesquisa
	mostraPesquisa("PARCYB", "PARCYB_BUSCAR_MOTIVOS_CIN", "Motivos CIN","100",filtros,colunas);
}

/***********************************************************************************************************
									FIM -> Funções para a tela de Motivos CIN
***********************************************************************************************************/

/***********************************************************************************************************
									INÍCIO -> Funções para a tela de Parametrização de Históricos
***********************************************************************************************************/

// Função para o estado inicial da tela de Parametrização de Históricos
function estadoInicialParametrizarHistorico(){
	//No estado inicial da tela de  Parametrização de Históricos, retorna para a principal
	flgVoltarGeral = 1;
	
	hideMsgAguardo();
	
	removeOpacidade("divTela");
	
	// Mostrar a tela de Parametrização de Históricos
	$("#divTelaParametrizarHistorico").css({"display":"block"});
	
	highlightObjFocus( $("#frmCabParametrizarHistorico","#divTelaParametrizarHistorico") ); 
	
	//Esconde a consulta e limpa a tabela
	$("#divConsultaParametrizarHistorico","#divTelaParametrizarHistorico").css({"display":"none"});
	$("#divFiltrosParametrizarHistorico","#divTelaParametrizarHistorico").css({"display":"none"});
	$("#tbParhis > tbody").html("");
	
	//Esconde cadastro e os botões
	$("#frmCabParametrizarHistorico","#divTelaParametrizarHistorico").css({"display":"none"});
	$("#divBotoes").css({"display":"block"});
	
	//Exibe cabeçalho e define tamanho da tela
	$("#frmCabParametrizarHistorico","#divTelaParametrizarHistorico").css({"display":"block"});
	
	//Limpa os campos do formulário e remove o erro dos campos
	$('input[type="text"],select','#frmCabParametrizarHistorico').limpaFormulario().removeClass('campoErro');
	//Foca o campo da Opção
	$("#cddopcao_parametrizar_historico","#frmCabParametrizarHistorico").habilitaCampo().val("CH").focus();
	//Esconde o botão de concluir
	$("#btConcluir","#divBotoes").hide();
}

// Função para formatar a tela de Parametrização de Históricos
function formataTelaParametrizarHistorico(){
	//Formatação do cabeçalho e formulário
	formataCabecalhoParametrizarHistorico();
	formataFiltrosParametrizarHistorico();
}

// Formata o Cabeçalho da tela de Parametrização de Históricos
function formataCabecalhoParametrizarHistorico() {
	// rotulo
	$('label[for="cddopcao_parametrizar_historico"]',"#frmCabParametrizarHistorico").addClass("rotulo").css({"width":"100px"}); 
	
	// campo
	$("#cddopcao_parametrizar_historico","#frmCabParametrizarHistorico").css("width","500px").habilitaCampo();
	$('input[type="text"],select','#frmCabParametrizarHistorico').limpaFormulario().removeClass('campoErro');
	layoutPadrao();
	
	//Define ação para ENTER e TAB no campo Opção
	$("#cddopcao_parametrizar_historico","#frmCabParametrizarHistorico").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			//Executa função do botão OK
			liberaAcaoParametrizarHistorico();
			return false;
		}
    });	

	//Define ação para CLICK no botão de OK da tela de Parametrização de Históricos
	$("#btnOkParametrizarHistorico","#frmCabParametrizarHistorico").unbind('click').bind('click', function(e) {
		//Executa função do botão OK
		liberaAcaoParametrizarHistorico();
		return false;
    });	
	
	return false;	
}

// Função para formatar os campos de filtro utilizados na tela de Parametrização de Históricos
function formataFiltrosParametrizarHistorico(){
	// Campos de Pesquisa do histórico por código e descrição
	// rotulo
	$('label[for="cdhistor"]',"#frmFiltrosParametrizarHistorico").addClass("rotulo").css({"width":"100px"}); 
	$('label[for="dshistor"]',"#frmFiltrosParametrizarHistorico").addClass("rotulo-linha").css({"width":"100px"}); 
	// campo
	$("#cdhistor","#frmFiltrosParametrizarHistorico").css("width","50px").habilitaCampo();
	$("#dshistor","#frmFiltrosParametrizarHistorico").css("width","200px").habilitaCampo();
	
	
	// Campos de Pesquisa do histórico por FILTRO
	//rotulo
	$('label[for="rdfiltro1"]',"#frmFiltrosParametrizarHistorico").addClass("rotulo-linha").css({"width":"200px","text-align":"left"}); 
	$('label[for="rdfiltro2"]',"#frmFiltrosParametrizarHistorico").addClass("rotulo-linha").css({"width":"150px","text-align":"left"}); 
	$('label[for="rdfiltro3"]',"#frmFiltrosParametrizarHistorico").addClass("rotulo-linha").css({"width":"150px","text-align":"left"}); 
	//campos
	$("#rdfiltro1","#frmFiltrosParametrizarHistorico").css("width","10px").habilitaCampo();
	$("#rdfiltro2","#frmFiltrosParametrizarHistorico").css("width","10px").habilitaCampo();
	$("#rdfiltro3","#frmFiltrosParametrizarHistorico").css("width","10px").habilitaCampo();
	
	$('input[type="text"]','#frmFiltrosParametrizarHistorico').limpaFormulario().removeClass('campoErro');
	layoutPadrao();
	
	//Define ação para CLICK no botão de Pesquisar da tela de Parametrização de Históricos
	$("#btnPesquisarHistorico","#frmFiltrosParametrizarHistorico").unbind('click').bind('click', function(e) {
		//Executa função do botão Pesquisar
		pesquisarHistorico();
		return false;
    });	
	
	//Define ação para CLICK no botão de Filtrar da tela de Parametrização de Históricos
	$("#btnFiltrarHistorico","#frmFiltrosParametrizarHistorico").unbind('click').bind('click', function(e) {
		//Executa função do botão Pesquisar
		filtrarHistorico();
		return false;
    });	
	
	return false;	
}

function formataConsultaParametrizarHistorico(){
	// Tabela
	$("#divConteudo","#divConsultaParametrizarHistorico").css({"display":"block"});

    var divRegistro = $("div.divRegistros", "#tabParhis");
	var tabela      = $("table", divRegistro );
	var linha       = $("table > tbody > tr", divRegistro );

    $("#tabParhis").css({"margin-top":"5px"});
	divRegistro.css({"height":"290px","width":"720px","padding-bottom":"2px"});

	var ordemInicial = new Array();
	
	//Define a largura dos campos
	var arrayLargura = new Array();
    arrayLargura[0] = "70px";
    arrayLargura[1] = "130px"; 
    arrayLargura[2] = "100px"; 
    arrayLargura[3] = "100px";
    arrayLargura[4] = "100px";
	arrayLargura[5] = "100px";
    arrayLargura[6] = "15px";
    
	//Define a posição dos elementos nas células da linha
    var arrayAlinha = new Array();
	arrayAlinha[0] = "right";
	arrayAlinha[1] = "left";
	arrayAlinha[2] = "left";
	arrayAlinha[3] = "center";
	arrayAlinha[4] = "center";
	arrayAlinha[5] = "left";
	arrayAlinha[6] = "left";

	//Aplica as informações na tabela
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);
	return false;
}

// Função para liberar as informações da tela de Parametrização de Históricos
function liberaAcaoParametrizarHistorico(){
	var cddopcao = $("#cddopcao_parametrizar_historico","#frmCabParametrizarHistorico");
	cddopcao.desabilitaCampo();
	//Quando executar a tela de Parametrização de Históricos, retorna para a tela de Parametrização de Históricos
	flgVoltarGeral = 0;

	// Esconder o botão de Concluir
	$("#btConcluir","#divBotoes").hide();

	//Mostra as opções da tela
	$("#divConsultaParametrizarHistorico","#divTelaParametrizarHistorico").css({"display":"block"});
	$("#divFiltrosParametrizarHistorico","#divTelaParametrizarHistorico").css({"display":"block"});
	$("#frmFiltrosParametrizarHistorico","#divTelaParametrizarHistorico").css({"display":"block"});
	
	$("#tdPesquisarHistorico","#frmFiltrosParametrizarHistorico").hide();
	$("#tdFiltrarHistorico","#frmFiltrosParametrizarHistorico").hide();
	
	if(cddopcao.val() == "CH") {
		// Exibe os campos de Filtro
		$("#tdFiltrarHistorico","#frmFiltrosParametrizarHistorico").show();
		$("#rdfiltro3","#frmFiltrosParametrizarHistorico").attr("checked","checked").focus();
	} else {
		// Exibe os campos de Código e descrição
		$("#tdPesquisarHistorico","#frmFiltrosParametrizarHistorico").show();
		$("#cdhistor","#frmFiltrosParametrizarHistorico").val("").focus();
		$("#dshistor","#frmFiltrosParametrizarHistorico").val("");
		$("#btConcluir","#divBotoes").show();
	}
}

// Função para o botão voltar
function controlaVoltarParametrizarHistorico(){
	if (flgVoltarGeral == 1) {
		// Quando não for executado nada na tela de parametrização de histórico, retorna para a tela principal
		estadoInicial();
	} else {
		// Quando ocorrer alguma ação na tela de parametrização de histórico, retorna para o estado inicial da tela de parametrização de histórico
		estadoInicialParametrizarHistorico();
	}
}

// Função para o botão Concluir
function controlaConcluirParametrizarHistorico(){
	var historicos = "";
	var werro = 0;
	
	$('#tbParhis tbody tr').each(function(){

		var indcalem_ant = $("#indcalem_h",this).val();
		var indcalcc_ant = $("#indcalcc_h", this).val();
		var cdtrscyb_ant = $("#cdtrscyb_h", this).val();
		var indcalem_atu = ($("#indcalem_a",this).prop("checked")) ? "S" : "N";
		var indcalcc_atu = ($("#indcalcc_a", this).prop("checked")) ? "S" : "N";
		var cdtrscyb_atu = $("#cdtrscyb_a", this).val();
	
		if (indcalem_ant != indcalem_atu || indcalcc_ant != indcalcc_atu || cdtrscyb_ant != cdtrscyb_atu) {
			if( historicos != "" ){
				// Separador dos históricos
				historicos += "|";
			}
			historicos += $("#cdhistor_h",this).val() + ";" ; // Código do Histórico
			historicos += indcalem_atu  + ";" ;               // Cálculo de Empréstimo
			historicos += indcalcc_atu + ";";                 // Cálculo de Conta Corrente
			historicos += cdtrscyb_atu;                       // código da transação Cyber
			
			if (cdtrscyb_atu != "PA" && cdtrscyb_atu != "ES" && cdtrscyb_atu != "RF" && cdtrscyb_atu != " ") {
			    showError("error","Opcao invalida para o campo codigo transacao CYBER!","Alerta - Ayllos","$('#cdtrscyb_a', this).focus();");
				werro = 1;
		        return false;
	        }
		}		
		
		
	});

	if(historicos == ""){
		showError("error","Nenhum historico foi alterado.","Alerta - Ayllos","");
		return false;
	}
		
	//Mensagem de alteração de Parametrização
	if (werro == 0) {
		showMsgAguardo( "Aguarde, atualizando parametriza&ccedil;&atilde;o dos hist&oacute;ricos...");
		
		manterParametrizacaoHistorico("AH","","","","",historicos);  
	}
}

// Função para pesquisar os históricos por código/descrição
function pesquisarHistorico(){
	var opcao = "T"; // Padrão da pesquisa é todos
	var cdhistor = $("#cdhistor","#frmFiltrosParametrizarHistorico").val();
	var dshistor = $("#dshistor","#frmFiltrosParametrizarHistorico").val();
	var cdfiltro = "";
	
	if(cdhistor != "" && dshistor != ""){
		showError("error","Informe apenas um campo para pesquisar.","Alerta - Ayllos","");
		return false;
	}
	
	if (cdhistor != ""){
		opcao = "C"; // Se possuir código informado a opção de pesquisa é "C"
	}
	
	if (dshistor != ""){
		opcao = "D"; // Se possuir descrição informada a opção de pesquisa é "D"
	}
	
	executaPesquisaParametrizacaoHistorico("CH",opcao,cdfiltro,cdhistor,dshistor);
}

// Função para pesquisar os históricos por filtro
function filtrarHistorico(){
	var opcao = "F"; // Quando for pesquisa por filtro, sempre utilizar a opção "F"
	var rdfiltro1 = $("#rdfiltro1","#frmFiltrosParametrizarHistorico").prop("checked");
	var rdfiltro2 = $("#rdfiltro2","#frmFiltrosParametrizarHistorico").prop("checked");
	var rdfiltro3 = $("#rdfiltro3","#frmFiltrosParametrizarHistorico").prop("checked");

	var cdfiltro = (rdfiltro1) ? 1 : ((rdfiltro2) ? 2 : ((rdfiltro3) ? 3 : 0));
	var cdhistor = "";
	var dshistor = "";
	
	if(cdfiltro == 0){
		showError("error","Selecione o filtro.","Alerta - Ayllos","");
		return false;
	}
	
	executaPesquisaParametrizacaoHistorico("CH",opcao,cdfiltro,cdhistor,dshistor);
}

function executaPesquisaParametrizacaoHistorico(cddopcao,pesquisa,cdfiltro,cdhistor,dshistor){
	//Limpar a tabela
	$("#tbParhis > tbody").html("");
	//Iniciar a busca das assessorias
	showMsgAguardo( "Aguarde, carregando parametriza&ccedil;&atilde;o de hist&oacute;rico..." );	
	manterParametrizacaoHistorico(cddopcao,pesquisa,cdfiltro,cdhistor,dshistor,"");
}

// Função para manter rotina (Consultar/Alterar)
function manterParametrizacaoHistorico(cddopcao,pesquisa,cdfiltro,cdhistor,dshistor,historicos){
	//Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/parcyb/manter_rotina_parametrizar_historico.php",
        data: {
            cddopcao: cddopcao,
			pesquisa: pesquisa,
			cdfiltro: cdfiltro,
			cdhistor: cdhistor,
			dshistor: dshistor,
			historicos: historicos,
            redirect: "script_ajax"
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

function criaLinhaParametrizarHistorico(cdhistor,dshistor,indebcre,indcalem,indcalcc,cdtrscyb){
	
	var field_indcalem = $('<input>', { type:"checkbox", name: "indcalem_a", id: "indcalem_a"});
	var field_indcalcc = $('<input>', { type:"checkbox", name: "indcalcc_a", id: "indcalcc_a"});
	var field_cdtrscyb = $('<input>', { type:"text", name: "cdtrscyb_a", id: "cdtrscyb_a", value: cdtrscyb});
	
	if($("#cddopcao_parametrizar_historico","#frmCabParametrizarHistorico").val() == "CH"){
		field_indcalem.attr("disabled","disabled");
		field_indcalcc.attr("disabled","disabled");
		field_cdtrscyb.attr("type","hidden");
		
		var vtexto  = cdtrscyb;
	}
	else
	{		
        var vtexto  = "";
		
	}
	
	if(indcalem == "S"){
		field_indcalem.attr("checked","checked");
	}
	
	if(indcalcc == "S"){
		field_indcalcc.attr("checked","checked");
	}
			
	// Criar a linha na tabela
	$("#tbParhis > tbody")
		.append($("<tr>") // Linha
			.attr("id","id_".concat(cdhistor))
			.append($("<td>") // Coluna: Código do Histórico
				.attr("style","width: 77px; text-align:left")
				.text(cdhistor)
				.append($("<input>")
					.attr("type","hidden")
					.attr("name","cdhistor_h")
					.attr("id","cdhistor_h")
					.attr("value",cdhistor)
				)
			)
			.append($("<td>") // Coluna: Descrição do Histórico
				.attr("style","width: 135px; text-align:left")
				.text(dshistor)
			)
			.append($("<td>") // Coluna: Indicador de Débito e Crédito do Histórico
				.attr("style","width: 107px; text-align:left")
				.text(indebcre)
			)
			.append($("<td>") // Coluna: Cálculo do Empréstimo
				.attr("style","width: 154px; text-align:center")
				.append(field_indcalem)
				.append($("<input>")
					.attr("type","hidden")
					.attr("name","indcalem_h")
					.attr("id","indcalem_h")
					.attr("value",indcalem)
				)
			)
			.append($("<td>") // Coluna: Cálculo de Conta Corrente
				.attr("style","width: 115px; text-align:center")
				.append(field_indcalcc)
				.append($("<input>")
					.attr("type","hidden")					
					.attr("name","indcalcc_h")
					.attr("id","indcalcc_h")
					.attr("value",indcalcc)
				)
			)
		
			.append($("<td id='cpotrscyb'>") // 13/01/2017 - Jean Calão - criação da Coluna: Código transação CYBER
				.attr("style","width: 114px; text-align:left")
				.text(vtexto)
				.append(field_cdtrscyb)			
                .append($("<input>")
					.attr("type","hidden")					
					.attr("name","cdtrscyb_h")
					.attr("id","cdtrscyb_h")
					.attr("value",cdtrscyb)			
                )					
			) 
     		
		);
}
/***********************************************************************************************************
									FIM -> Funções para a tela de Parametrização de Históricos
***********************************************************************************************************/

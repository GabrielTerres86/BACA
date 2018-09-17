/*!
 * FONTE        : prcins.js
 * CRIAÇÃO      : Douglas Quisinski
 * DATA CRIAÇÃO : 24/09/2015
 * OBJETIVO     : Biblioteca de funções da tela PRCINS
 * --------------
 * ALTERAÇÕES   : 14/10/2015 - Ajuste decorrente a homologação (Adriano).
 * -------------- 16/02/2016 - Ajustes para corrigir o problema de não conseguir carregar
                               corretamente as informações para opção "E"
                               (Adriano - SD 402006)

                  22/03/2017 - Adicionado opção para importar a planilha de prova de vida (Douglas - Chamado 618510)
 */

var	cdcooper = 0;
var	nrdconta = 0;
var	nrdocmto = 0;
	
$(document).ready(function() {
	
	estadoInicial();	
	formataTabelaExcluirLancamento();
	formataTabelaResumo();
	
});

// seletores
function estadoInicial() {
	
	$('#divTela').css({'display':'inline'}).fadeTo(0,0.1);
	removeOpacidade('divTela');	

	formataCabecalho();

	formataExcluirLancamento();
	formataProcessarPlanilha();
	formataResumo();
	formataSolicitar();
	formataImportarProvaVida();

	removeOpacidade('divTela');
	highlightObjFocus( $('#frmCab') ); 
	
	$('#divBotoes').css({'display':'none'});
	$('#frmCab').css({'display':'block'});
	$('#divTela').css({'width':'700px','padding-bottom':'2px'});
	
	$("#cddopcao","#frmCab").focus();
	
}

function formataCabecalho(){
	
	// rotulo
	$('label[for="cddopcao"]',"#frmCab").addClass("rotulo").css({"width":"45px"}); 
	
	// campo
	$("#cddopcao","#frmCab").css("width","565px").habilitaCampo();
	
	$('input[type="text"],select','#frmCab').limpaFormulario().removeClass('campoErro');
		
	//Define ação para ENTER e TAB no campo Opção
	$("#cddopcao","#frmCab").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			
			liberaFormulario();
			
			return false;
			
		}
    });	
	
	//Define ação para CLICK no botão de OK
	$("#btnOK","#frmCab").unbind('click').bind('click', function() {
			
		liberaFormulario();
		
		$(this).unbind('click');			
		
		return false;
    });	
	
	layoutPadrao();
	
	return false;	
}

function formataExcluirLancamento() {

	// rotulo
	$('label[for="cddotipo"]',"#frmExcluirLancamento").addClass("rotulo").css({"width":"100px"}); 
	$('label[for="cdcooper"]',"#frmExcluirLancamento").addClass("rotulo").css({"width":"100px"}); 
	$('label[for="nrdconta"]', "#frmExcluirLancamento").addClass("rotulo").css({ "width": "100px" });

	// campo
	$("#cddotipo","#frmExcluirLancamento").css("width","500px").habilitaCampo();
	$("#cdcooper","#frmExcluirLancamento").css("width","500px").desabilitaCampo();
	$('#nrdconta','#frmExcluirLancamento').css("width","75px").addClass('conta pesquisa').desabilitaCampo();
		
	// Adicionar evento para quando sair do campo de lançamento
	$("#cddotipo","#frmExcluirLancamento").unbind('keypress').bind('keypress', function(e) {
		
		$(this).removeClass('campoErro');
		
		if (e.keyCode == 9 || e.keyCode == 13) {
		    
			//Executa função do botão OK
			validarTipoLancamentoExcluir();
			return false;
		}
    });	
	
	//Define ação para ENTER e TAB no campo cooperativa
	$("#cdcooper","#frmExcluirLancamento").unbind('keypress').bind('keypress', function(e) {
		
		$(this).removeClass('campoErro');
		
		if (e.keyCode == 9 || e.keyCode == 13) {
			
			if($("#cddotipo","#frmExcluirLancamento").val() == 'T'){
				
				controlaConcluir();
				
			}else{
			
				$("#nrdconta","#frmExcluirLancamento").focus();
				
			}
			
			return false;
		}
    });
	
	//Define ação para ENTER e TAB no campo do nome do arquivo
	$("#nrdconta","#frmExcluirLancamento").unbind('keypress').bind('keypress', function(e) {
		
		$(this).removeClass('campoErro');
		
		if (e.keyCode == 9 || e.keyCode == 13) {
			
			controlaConcluir();
			return false;
		}
    });
	
	$('#divExcluir').css({'display':'none'});
	$('#frmExcluirLancamento').css({'display':'none'});
	highlightObjFocus( $('#frmExcluirLancamento') ); 
	
	return false;
}

function formataProcessarPlanilha(){
	
	// rotulo
	$('label[for="nmdarqui"]',"#frmProcessar").addClass("rotulo").css({"width":"100px"}); 
	// campo
	$("#nmdarqui","#frmProcessar").attr('maxlength','80').addClass("alphanum").css({"width":"500px"}).habilitaCampo();

	$('input[type="text"],select','#frmProcessar').limpaFormulario().removeClass('campoErro');
	$('#fsetFiltroProcessarObs','#frmProcessar').css({'display':'block'});
	$('#fsetFiltroProcessarResumo','#frmProcessar').css({'display':'none'});
	$('#fsetFiltroProcessarDivergencia','#frmProcessar').css({'display':'none'});
	
	//Define ação para ENTER e TAB no campo do nome do arquivo
	$("#nmdarqui","#frmProcessar").unbind('keypress').bind('keypress', function(e) {
		
		$(this).removeClass('campoErro');
		
		if (e.keyCode == 9 || e.keyCode == 13) {
			//Executa função de concluir
			concluirProcessarPlanilha();
			return false;
		}
    });
	
	$("#lbQtdPlanilha","#divResumoProcesso").addClass("rotulo").css({"width":"160px","display":"none"}); 
	$("#qtdPlanilha","#divResumoProcesso").addClass("rotulo-linha").css({"width":"150px","display":"none","text-align":"left"}).html("");
	
	$("#lbValorPlanilha","#divResumoProcesso").addClass("rotulo-linha").css({"width":"160px","display":"none"}); 
	$("#valorPlanilha","#divResumoProcesso").addClass("rotulo-linha").css({"width":"150px","display":"none","text-align":"left"}).html("");
	
	$("#lbQtdProcessada","#divResumoProcesso").addClass("rotulo").css({"width":"160px","display":"none"}); 
	$("#qtdProcessada","#divResumoProcesso").addClass("rotulo-linha").css({"width":"150px","display":"none","text-align":"left"}).html("");
	
	$("#lbValorTotal","#divResumoProcesso").addClass("rotulo-linha").css({"width":"160px","display":"none"}); 
	$("#valorTotal","#divResumoProcesso").addClass("rotulo-linha").css({"width":"150px","display":"none","text-align":"left"}).html("");
	
	$("#lbQtdErros","#divResumoProcesso").addClass("rotulo").css({"width":"160px","display":"none"}); 
	$("#qtdErros","#divResumoProcesso").addClass("rotulo-linha").css({"width":"150px","display":"none","text-align":"left"}).html("");
	
	$("#lbValorErros","#divResumoProcesso").addClass("rotulo-linha").css({"width":"160px","display":"none"}); 
	$("#valorErros","#divResumoProcesso").addClass("rotulo-linha").css({"width":"150px","display":"none","text-align":"left"}).html("");
		
	$('#frmProcessar').css({'display':'none'});	
	$('#divResumoProcesso').css({'display':'none'});
	highlightObjFocus( $('#frmProcessar') ); 
	
	layoutPadrao();
	
	return false;
}

function formataResumo(){
	// rotulo
	$('label[for="cdcopaux"]',"#frmResumo").addClass("rotulo").css({"width":"100px"}); 
	$('label[for="dtinicio"]',"#frmResumo").addClass("rotulo").css({"width":"100px"}); 
	$('label[for="dtafinal"]',"#frmResumo").addClass("rotulo-linha").css({"width":"30px"}); 
	
	// campo
	$("#cdcopaux","#frmResumo").css("width","500px").habilitaCampo();
	$('#dtinicio','#frmResumo').css({'width':'80px'}).addClass('data').habilitaCampo();
	$('#dtafinal','#frmResumo').css({'width':'80px'}).addClass('data').habilitaCampo();

	$('input[type="text"],select','#frmResumo').limpaFormulario().removeClass('campoErro');
	
	//Define ação para ENTER e TAB no campo de cooperativa
	$("#cdcopaux","#frmResumo").unbind('keypress').bind('keypress', function(e) {
		
		$(this).removeClass('campoErro');
		
		if (e.keyCode == 9 || e.keyCode == 13) {
			$('#dtinicio','#frmResumo').focus();
			return false;
		}
    });

	//Define ação para ENTER e TAB no campo de data do resumo
	$("#dtinicio","#frmResumo").unbind('keypress').bind('keypress', function(e) {
		
		$(this).removeClass('campoErro');
		
		if (e.keyCode == 9 || e.keyCode == 13) {
			//Executa função de concluir
			$("#dtafinal","#frmResumo").focus();
			return false;
		}
    });
	
	//Define ação para ENTER e TAB no campo de data do resumo
	$("#dtafinal","#frmResumo").unbind('keypress').bind('keypress', function(e) {
		
		$(this).removeClass('campoErro');
		
		if (e.keyCode == 9 || e.keyCode == 13) {
			//Executa função de concluir
			concluirResumo();
			return false;
		}
    });
	
	$('#divResumo').css({'display':'none'});
	$('#frmResumo').css({'display':'none'});
	highlightObjFocus( $('#frmResumo') ); 
	
	layoutPadrao();
	
	return false;
}

function formataSolicitar(){
	// rotulo
	$('label[for="cdcopaux"]',"#frmSolicitar").addClass("rotulo").css({"width":"100px"}); 
	// campo
	$("#cdcopaux","#frmSolicitar").css("width","500px").habilitaCampo();

	$('input[type="text"],select','#frmSolicitar').limpaFormulario().removeClass('campoErro');
	
	//Define ação para ENTER e TAB no campo de cooperativa
	$("#cdcopaux","#frmSolicitar").unbind('keypress').bind('keypress', function(e) {
		
		$(this).removeClass('campoErro');
		
		if (e.keyCode == 9 || e.keyCode == 13) {
			//Executa função de concluir
			concluirSolicitar();
			return false;
		}
    });

	$('#frmSolicitar').css({'display':'none'});
	highlightObjFocus( $('#frmSolicitar') ); 
	
	layoutPadrao();
	
	return false;
	
}

function formataImportarProvaVida(){
	
	$('#fsetFiltroProvaVidaObs','#frmImportarProvaVida').css({'display':'block'});
	
	$('#frmImportarProvaVida').css({'display':'none'});	
	highlightObjFocus( $('#frmImportarProvaVida') ); 
	
	layoutPadrao();
	
	return false;
}

function formataTabelaExcluirLancamento() {
	$('#divExcluir').css({'width':'650px','padding-bottom':'2px','padding-left':'4px'});
	
	var divRegistro = $('div.divRegistros', '#divExcluir');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

    divRegistro.css({'height':'250px','width':'650px','padding-bottom':'2px'});
	$('#divRegistrosRodape','#divExcluir').formataRodapePesquisa();	
	
	var ordemInicial = new Array();

	var arrayLargura = new Array();
    arrayLargura[0] = '140px';
	arrayLargura[1] = '90px';
	arrayLargura[2] = '75px';
	arrayLargura[3] = '130px';
	arrayLargura[4] = '90px';
		
    var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
    arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'left';
	arrayAlinha[4] = 'left';
	arrayAlinha[5] = 'right';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);
	
	$('table > tbody > tr', divRegistro).each( function(i) {
		
		if ( $(this).hasClass( 'corSelecao' ) ) {
		
			selecionaLancamento($(this));
			
		}	
		
	});	
	
	//seleciona o lancamento que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		
		selecionaLancamento($(this));
	});
	
	return false;
	
}

function formataTabelaResumo(){
	$('#divResumo').css({'width':'650px','padding-bottom':'2px','padding-left':'4px'});
	
	var divRegistro = $('div.divRegistros', '#divResumo');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

    divRegistro.css({'height':'250px','width':'650px','padding-bottom':'2px'});
	$('#divRegistrosRodape','#divResumo').formataRodapePesquisa();	
	
	var ordemInicial = new Array();

	var arrayLargura = new Array();
    arrayLargura[0] = '250px';
	arrayLargura[1] = '150px';
	
    var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
    arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'right';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);
	
	return false;
	
}

function formataTabelaSolicitar(){
	
	var divRegistro = $('div.divRegistros', '#divSolicitarResumo');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

    divRegistro.css({'height':'250px','width':'700px','padding-bottom':'2px'});
	$('#divRegistrosRodape','#divSolicitarResumo').formataRodapePesquisa();	
			
	var ordemInicial = new Array();

	var arrayLargura = new Array();
    arrayLargura[0] = '150px';
	
    var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
    arrayAlinha[1] = 'left';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);
	
	return false;

}

function formataTabelaCooperativaErros(){
	$('#divResumoErros').css({'width':'300px','padding-bottom':'2px','padding-left':'180px'});
	
	var divRegistro = $('div.divRegistros', '#divResumoErros');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

    divRegistro.css({'height':'250px','width':'300px','padding-bottom':'2px'});
	$('#divRegistrosRodape','#divResumoErros').formataRodapePesquisa();	
	
	var ordemInicial = new Array();

	var arrayLargura = new Array();
	
    var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);
	
	return false;
	
}

function liberaFormulario() {

	switch($("#cddopcao","#frmCab").val()) {
		case "E": // Excluir pagamento de beneficio
			liberaAcaoExcluirLancamento();
		break;
		
		case "P": // Processar planilha de pagamento dos beneficios
			liberaAcaoProcessarPlanilha();
		break;
		
		case "R": // Resumo de pagamentos de benefício
			carregarListaCooperativas();
		break;
		
		case "S": // Solicitar as mensagens para o SICREDI
			carregarListaCooperativas();
		break;
		
		case "I": // Processar planilha de prova de vida
			liberaAcaoImportarProvaVida();
		break;
	}

}

function liberaAcaoExcluirLancamento(){
	// Desabilitar a opção
	$("#cddopcao","#frmCab").desabilitaCampo();
	
	// Limpar formulário
	$('input[type="text"],select','#frmExcluirLancamento').limpaFormulario().removeClass('campoErro');
	
	// Mostrar a tela
	$('#frmExcluirLancamento').css({'display':'block'});
	$('#fsetExcluirFiltro','#frmExcluirLancamento').css({'display':'block'});
	$('#fsetExcluirLancamentos','#frmExcluirLancamento').css({'display':'none'});
	$('#divExcluir').css({'display':'none'});	
	$('#divBotoes').css({'display':'block','padding-bottom':'15px'});
	$('#btVoltar','#divBotoes').css({'display':'inline'});
	$('#btConcluir', '#divBotoes').css({ 'display': 'none' });
	$('#btProsseguir', '#divBotoes').css({ 'display': 'inline' });
	
	// Adicionar foco no primeiro campo
	$("#cddotipo","#frmExcluirLancamento").habilitaCampo().focus();
	
}

function liberaAcaoProcessarPlanilha(){
	
	// Desabilitar a opção
	$("#cddopcao","#frmCab").desabilitaCampo();
	
	// Limpar formulário
	$('input[type="text"],select','#frmProcessar').limpaFormulario().removeClass('campoErro');
	
	// Mostrar a tela
	$('#frmProcessar').css({'display':'block'});
	$('#divResumoProcesso').css({'display':'none'});
	$('#fsetFiltroProcessarObs','#frmProcessar').css({'display':'block'});
	$('#fsetFiltroProcessarResumo','#frmProcessar').css({'display':'none'});
	$('#fsetFiltroProcessarDivergencia','#frmProcessar').css({'display':'none'});
	$('#divBotoes').css({'display':'block','padding-bottom':'15px'});
	$('#btVoltar','#divBotoes').css({'display':'inline'});
	$('#btConcluir', '#divBotoes').css({ 'display': 'inline' });
	$('#btProsseguir', '#divBotoes').css({ 'display': 'none' });
	
	// Adicionar foco no primeiro campo
	$("#nmdarqui","#frmProcessar").habilitaCampo().focus();
	
}

function liberaAcaoResumo(){
	// Desabilitar a opção
	$("#cddopcao","#frmCab").desabilitaCampo();
	// Limpar formulário
	$('input[type="text"],select','#frmResumo').limpaFormulario().removeClass('campoErro').habilitaCampo();
	// Mostrar a tela
	$('#frmResumo').css({'display':'block'});
	$('#fsetResumo','#frmResumo').css({'display':'none'});
	$('#divResumo').css({'display':'none'});
	$('#divBotoes').css({'display':'block','padding-bottom':'15px'});
	$('#btVoltar','#divBotoes').css({'display':'inline'});
	$('#btConcluir', '#divBotoes').css({ 'display': 'inline' });
	$('#btProsseguir', '#divBotoes').css({ 'display': 'none' });
	$("#tbResumo > tbody").html("");
	
	// Adicionar foco no primeiro campo
	$("#cdcopaux","#frmResumo").val("0").focus();
}

function liberaAcaoSolicitar(){
	
	// Desabilitar a opção
	$("#cddopcao","#frmCab").desabilitaCampo();
	
	// Limpar formulário
	$('input[type="text"],select','#frmSolicitar').limpaFormulario().removeClass('campoErro');
	
	// Mostrar a tela
	$('#frmSolicitar').css({'display':'block'});
	$('#divBotoes').css({'display':'block','padding-bottom':'15px'});
	$('#btVoltar','#divBotoes').css({'display':'inline'});
	$('#btConcluir', '#divBotoes').css({ 'display': 'inline' });
	$('#btProsseguir', '#divBotoes').css({ 'display': 'none' });
	$('#fsetSolicitarResumo','#frmSolicitar').css('display','none');
	$('#divSolicitarResumo','#frmSolicitar').css('display','none'); 
		
	// Adicionar foco no primeiro campo
	$("#cdcopaux","#frmSolicitar").habilitaCampo().val("0").focus();
}

function liberaAcaoImportarProvaVida(){
	
	// Desabilitar a opção
	$("#cddopcao","#frmCab").desabilitaCampo();
	
	// Mostrar a tela
	$('#frmImportarProvaVida').css({'display':'block'});
	$('#fsetFiltroProvaVidaObs','#frmImportarProvaVida').css({'display':'block'});
	$('#divBotoes').css({'display':'block','padding-bottom':'15px'});
	$('#btVoltar','#divBotoes').css({'display':'inline'});
	$('#btConcluir', '#divBotoes').css({ 'display': 'inline' });
	$('#btProsseguir', '#divBotoes').css({ 'display': 'none' });
	
	$('#btConcluir', '#divBotoes').focus();
	
}

function controlaVoltar(){
	
	switch($("#cddopcao","#frmCab").val()) {
		
		case "E": // Excluir pagamento de beneficio
			if($('#divExcluir').css('display') == 'block'){
				liberaAcaoExcluirLancamento();							
			}else{
				estadoInicial();
			}
		break;
		
		case "P": // Processar planilha de pagamento dos beneficios
			
			if($('#divResumoProcesso').css('display') == 'block'){
				liberaAcaoProcessarPlanilha();							
			}else{
				estadoInicial();
			}
			
		break;
		
		case "R": // Resumo de pagamentos de benefício
		
			if($('#divResumo').css('display') == 'block'){
				carregarListaCooperativas();	
			}else{
				estadoInicial();
			}
			
		break;
		
		case "S": // Solicitar as mensagens para o SICREDI
			
			if($('#fsetSolicitarResumo').css('display') == 'block'){
				carregarListaCooperativas();
			}else{
				estadoInicial();
			}
			
		break;
		
		case "I": // Importar planilha de prova de vida
			
			estadoInicial();
			
		break;
	}
	
}

function controlaConcluir() {

    switch ($("#cddopcao", "#frmCab").val()) {

		case "E": // Excluir pagamento de beneficio
		
			if($('#divExcluir','#frmExcluirLancamento').css('display') == 'block'){
				processaExcluirLancamento();
			}else{
				concluirExcluirLancamento();
			}
				
		break;
		
		case "P": // Processar planilha de pagamento dos beneficios
			concluirProcessarPlanilha();
		break;
		
		case "R": // Resumo de pagamentos de benefício
			concluirResumo();
		break;
		
		case "S": // Solicitar as mensagens para o SICREDI
			concluirSolicitar();
		break;
		
		case "I": // Importar planilha de prova de vida
			concluirImportarProvaVida();
		break;
	}
}

function controlaProsseguir() {
    
    if (!$('#cdcooper', '#frmExcluirLancamento').hasClass('campoTelaSemBorda')) {
    
        concluirExcluirLancamento();

    } else {
    
        validarTipoLancamentoExcluir();
        
    }

}

function concluirExcluirLancamento(){
	
    showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'buscarLancamentoExcluir();', '$("#nrdconta","#frmExcluirLancamento").focus();', 'sim.gif', 'nao.gif');
	
}

function concluirProcessarPlanilha(){
	
	$("#lbQtdPlanilha","#divResumoProcesso").css({'display':'none'});
	$("#qtdPlanilha","#divResumoProcesso").css({'display':'none'}).html("");
	
	$("#lbValorPlanilha","#divResumoProcesso").css({'display':'none'});
	$("#valorPlanilha","#divResumoProcesso").css({'display':'none'}).html("");
	
	$("#lbQtdProcessada","#divResumoProcesso").css({'display':'none'});
	$("#qtdProcessada","#divResumoProcesso").css({'display':'none'}).html("");
	
	$("#lbQtdErros","#divResumoProcesso").css({'display':'none'});
	$("#qtdErros","#divResumoProcesso").css({'display':'none'}).html("");
	
	$("#lbValorErros","#divResumoProcesso").css({'display':'none'});
	$("#valorErros","#divResumoProcesso").css({'display':'none'}).html("");
	
	$("#lbValorTotal","#divResumoProcesso").css({'display':'none'});
	$("#valorTotal","#divResumoProcesso").css({'display':'none'}).html("");
	
	$('#divResumoProcesso').css({'display':'none'});
		
	var nmdarqui = $("#nmdarqui","#frmProcessar").val();
	if ( nmdarqui == "" ) {
		showError('error','Nome do Arquivo não informado.','Alerta - Ayllos','$("#nmdarqui","#frmProcessar").focus();');
		return false;
	}
	showConfirmacao('Deseja processar o arquivo "' + nmdarqui + '.csv" para pagamento dos beneficios?','Confirma&ccedil;&atilde;o - Ayllos','processaProcessarPlanilha();','$("#nmdarqui","#frmProcessar").focus();','sim.gif','nao.gif');
}

function concluirResumo(){
	
	if ( $("#dtinicio","#frmResumo").val() == "" || $("#dtafinal","#frmResumo").val() == "") {
		showError('error','Período não informado.','Alerta - Ayllos','$("#dtinicio","#frmResumo").focus();focaCampoErro(\'dtinicio\',\'frmResumo\');');
		return false;
	}
	$("#tbResumo > tbody").html("");
	showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','processaResumo();','$("#cdcopaux","#frmResumo").focus();','sim.gif','nao.gif');
}

function concluirSolicitar(){
	
	showError('inform','Antes de efetuar a solicita&ccedil;&atilde;o, contate o SICREDI para verificar permiss&atilde;o.','Alerta - Ayllos','showConfirmacao(\'Deseja realizar a solicita&ccedil;&atilde;o?\',\'Confirma&ccedil;&atilde;o - Ayllos\',\'processaSolicitar();\',\'\',\'sim.gif\',\'nao.gif\');');
	
}

function concluirImportarProvaVida(){
	
	showConfirmacao('Deseja processar o arquivo "PV_CECRED.csv" para atualizar a data da prova de vida dos benefici&aacute;rios do INSS? ','Confirma&ccedil;&atilde;o - Ayllos','processaImportarProvaVida();','','sim.gif','nao.gif');
	
}

function processaExcluirLancamento(){
	
	var cddotipo = $("#cddotipo","#frmExcluirLancamento").val();
	
	$('input,select','#frmExcluirLancamento').removeClass('campoErro');
	
	if (cddotipo == "E"){
		
		if ( cdcooper == 0 || nrdconta == 0 || nrdocmto == 0 ){
			showError('error','Lan&ccedil;amento n&atilde;o identificado para excluir.','Alerta - Ayllos','');
			return false;
		}
		
		showMsgAguardo( "Aguarde, excluindo lan&ccedil;amento..." );
		
	} else {
		
		showMsgAguardo( "Aguarde, excluindo todos os lan&ccedil;amentos..." );
	}

	//Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/prcins/manter_rotina_excluir_lancamento.php",
        data: {
			cddotipo: cddotipo,
			cdcooper: cdcooper,
			nrdconta: normalizaNumero(nrdconta),
			nrdocmto: nrdocmto,
            redirect: "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#cddotipo','#frmExcluirLancamento').focus();");
        },
        success: function(response) {
            hideMsgAguardo();
			try {
				eval(response);
			} catch (error) {
					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#cddotipo','#frmExcluirLancamento').focus();");
				}
			}
    });
    return false;
}

function processaProcessarPlanilha(){
	
	var nmdarqui = $("#nmdarqui","#frmProcessar").val();
	
	$('input','#frmProcessar').removeClass('campoErro').desabilitaCampo();
	
	showMsgAguardo( "Aguarde, processando planilha com o pagamento dos benef&iacute;cios..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/prcins/manter_rotina_processar.php",
        data: {
			nmdarqui: nmdarqui,
            redirect: "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#nmdarqui','#frmProcessar').focus();");
        },
        success: function(response) {
            hideMsgAguardo();
			try {
				eval(response);
			} catch (error) {
					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#nmdarqui','#frmProcessar').focus();");
				}
			}
    });
    return false;
}

function processaResumo(){
	
	//Desabilita todos os campos do form
	$("input,select","#frmResumo").desabilitaCampo();
	
	var cdcopaux = $("#cdcopaux","#frmResumo").val();
	var dtinicio = $("#dtinicio","#frmResumo").val();
	var dtafinal = $("#dtafinal","#frmResumo").val();
	
	$('input,select','#frmResumo').removeClass('campoErro');
	
	showMsgAguardo( "Aguarde, buscando resumo..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/prcins/manter_rotina_resumo.php",
        data: {
			cdcopaux: cdcopaux,
			dtinicio: dtinicio,
			dtafinal: dtafinal,
            redirect: "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#cdcopaux','#frmResumo').focus();");
        },
        success: function(response) {
            hideMsgAguardo();
			try {
				eval(response);
			} catch (error) {
					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#cdcopaux','#frmResumo').focus();");
				}
			}
    });
    return false;
}

function processaSolicitar(){
	
	$('select','#frmSolicitar').desabilitaCampo().removeClass('campoErro');
	
	showMsgAguardo( "Aguarde, efetuando solicita&ccedil;&atilde;o..." );	
	
	var cdcopaux = $("#cdcopaux","#frmSolicitar").val();
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/prcins/manter_rotina_solicitar.php",
        data: {
			cdcopaux: cdcopaux,
            redirect: "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#cdcopaux','#frmSolicitar').focus()");
        },
        success: function(response) {
            hideMsgAguardo();
			try {
				eval(response);
			} catch (error) {
					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#cdcopaux','#frmSolicitar').focus()");
				}
			}
    });
    return false;
}

function processaImportarProvaVida(){
	
	showMsgAguardo( "Aguarde, processando planilha para atualizar a data da prova de vida dos benef&iacute;cios do INSS..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/prcins/manter_rotina_importar_prova_vida.php",
        data: {
			redirect: "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
        },
        success: function(response) {
            hideMsgAguardo();
			try {
				eval(response);
			} catch (error) {
					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "");
				}
			}
    });
    return false;
}

function carregarListaCooperativas() {
	
	var cddopcao = $("#cddopcao","#frmCab").val();
	var tipopera = (cddopcao == 'E') ? $("#cddotipo","#frmExcluirLancamento").val() : '';
	
	showMsgAguardo( "Aguarde, buscando cooperativas..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/prcins/buscar_cooperativas.php",
        data: {
			cddopcao: cddopcao,
			tipopera: tipopera,
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
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "");
				}
			}
    });
    return false;	
}

function buscarLancamentoExcluir() {
	
	var cddopcao = $("#cddopcao","#frmCab").val();
    var cddotipo = $("#cddotipo","#frmExcluirLancamento").val();
    
	cdcooper = $("#cdcooper","#frmExcluirLancamento").val();
    nrdconta = normalizaNumero($("#nrdconta","#frmExcluirLancamento").val());
	
	$('input,select','#frmExcluirLancamento').desabilitaCampo().removeClass('campoErro');
		
	if ( cddotipo == "E" ) {
		if(cdcooper == "" || cdcooper == 0) {
			showError('error','Cooperativa não informada.','Alerta - Ayllos','$(\'input,select\',\'#frmExcluirLancamento\').habilitaCampo();focaCampoErro(\'cdcooper\',\'frmExcluirLancamento\');');
			return false;
		}

		if(nrdconta == "") {
			showError('error','Conta não informada.','Alerta - Ayllos','$(\'input,select\',\'#frmExcluirLancamento\').habilitaCampo();focaCampoErro(\'nrdconta\',\'frmExcluirLancamento\');');
			return false;
		}
	} else  if( cddotipo == "T" ) {
		nrdconta = 0;
	}
	
	// Limpar a listagem de lançamentos
	$("#tbExcluir > tbody").html("");
	
	//Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/prcins/buscar_lancamento_excluir.php",
        data: {
			cddopcao: cddopcao,
			cddotipo: cddotipo,
            cdcooper: cdcooper,
			nrdconta: nrdconta,
			redirect: "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#cddotipo','#frmExcluirLancamento').focus();");
        },
        success: function(response) {
            hideMsgAguardo();
			try {
				eval(response);
			} catch (error) {
					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#cddotipo','#frmExcluirLancamento').focus();");
				}
			}
    });
    return false;	
}

function validarTipoLancamentoExcluir(){
	
	var cddotipo = $("#cddotipo","#frmExcluirLancamento").val();
	$("#tbFiltrarExcluir","#frmExcluirLancamento").css({'display':'none'});
	
	// Habilitar os campos apenas quando a opção selecionada for exclusivo
	if ( cddotipo == "E" ) {
		$("#tbExcluir > tbody").html("");
		$("#tbFiltrarExcluir","#frmExcluirLancamento").css({'display':'block'});
		$("#nrdconta","#frmExcluirLancamento").habilitaCampo();
		$("#cdcooper","#frmExcluirLancamento").habilitaCampo().focus();
		
	} else {
		$("#tbFiltrarExcluir","#frmExcluirLancamento").css({'display':'block'});
		$("#nrdconta","#frmExcluirLancamento").desabilitaCampo().val('');
		$("#cdcooper","#frmExcluirLancamento").habilitaCampo().focus();	
		
	}
	
	carregarListaCooperativas();			
	return false;
		
}

function exibirResumoProcesso(qtdPlanilha,valorPlanilha,qtdProcessada,qtdErros, valorErros,valorTotal){
	
	$("#lbQtdPlanilha","#divResumoProcesso").css({'display':'block'});
	$("#qtdPlanilha","#divResumoProcesso").css({'display':'block'}).val(qtdPlanilha);
	
	$("#lbValorPlanilha","#divResumoProcesso").css({'display':'block'});
	$("#valorPlanilha","#divResumoProcesso").css({'display':'block'}).val(valorPlanilha);
	
	$("#lbQtdProcessada","#divResumoProcesso").css({'display':'block'});
	$("#qtdProcessada","#divResumoProcesso").css({'display':'block'}).val(qtdProcessada);
	
	$("#lbQtdErros","#divResumoProcesso").css({'display':'block'});
	$("#qtdErros","#divResumoProcesso").css({'display':'block'}).val(qtdErros);
	
	$("#lbValorErros","#divResumoProcesso").css({'display':'block'});
	$("#valorErros","#divResumoProcesso").css({'display':'block'}).val(valorErros);
	
	$("#lbValorTotal","#divResumoProcesso").css({'display':'block'});
	$("#valorTotal","#divResumoProcesso").css({'display':'block'}).val(valorTotal);
	
	$('#divResumoProcesso').css({'display':'block'});
}

function selecionaLancamento(tr){

	cdcooper = $('#cdcooper', tr ).val();
	nrdconta = normalizaNumero($('#nrdconta', tr ).val());
	nrdocmto = $('#nrdocmto', tr ).val();

	return false;
	
}
/*!
 * FONTE        : histor.js
 * CRIAÇÃO      : Jéssica (DB1) 
 * DATA CRIAÇÃO : 30/09/2013
 * OBJETIVO     : Biblioteca de funções da tela HISTOR
 * --------------
 * ALTERAÇÕES   : 11/03/2016 - Homologacao e ajustes da conversao da tela HISTOR (Douglas - Chamado 412552)
 *                07/02/2017 - #552068 Aumento da largura da tabela para comportar os dados corretamente 
 *                             Retirada a coluna de CPMF na função formataTabelaConsulta (Carlos)
 *				  05/12/2017 - Adicionado novo campo Ind. Monitaoramento - Melhoria 458 - Antonio R. Jr (mouts)
 *                26/03/2018 - PJ 416 - BacenJud - Incluir o campo de inclusão do histórico no bloqueio judicial - Márcio - Mouts
 *                05/04/2018 - PJ 416 - BacenJud - Inclusão do form de senha para confirmação de alteração do bloqueio judicial - Mateus Z (Mouts)
 *                11/04/2018 - Incluído novo campo "Estourar a conta corrente" (inestocc)
 *                             Diego Simas - AMcom
 *                16/05/2017 - Ajustes prj420 - Resolucao - Heitor (Mouts)
 *                15/05/2018 - 364 - Sm 5 - Incluir campo inperdes Rafael (Mouts)
 *                11/06/2018 - P450 - Alterado o label "Estourar a conta corrente" para 
 *     					       "Debita após o estouro de conta corrente (60 dias)".
 *							   Diego Simas (AMcom) - Prj 450 
 *               
 *                18/07/2018 - Alterado para esconder o campo referente ao débito após o estouro de conta  
 * 							   Criado novo campo "indebprj", indicador de débito após transferência da CC para Prejuízo
 * 							   PJ 450 - Diego Simas - AMcom			
 *
 * --------------
 */

// Definir a quantidade de registros que devem ser carregados nas consultas 
var nrregist = 50; 
var aux_inestocc = 0;
var aux_indebprj = 0;
	
$(document).ready(function () {
	aux_inestocc = $('#inestocc', '#frmHistorico').val();
	aux_indebprj = $('#indebprj', '#frmHistorico').val();
	estadoInicial();
	return false;
});

/**
 * Funcao para o estado inicial da tela
 * Formatacao dos campos e acoes da tela
 */
function estadoInicial() {
	
	$('#divTela').css({'display':'block'}).fadeTo(0,0.1);
	
	// Formatar o layout da tela
	formataCabecalho();
	formataFiltros();
	formataCadastroHistorico();
	formataBotoes();

	removeOpacidade('divTela');
    highlightObjFocus($('#frmCab'));
	
	// Limpar as tabelas de historico
    $('#frmTabHistoricos').css({ 'display': 'none' });
    $('#frmHistorico').css({ 'display': 'none' });
    $('#divHistoricos', '#frmTabHistoricos').html('');
	$("tr.estouraConta").hide();
	
	// esconder os botoes da tela
    $('#divBotoes').css({ 'display': 'none' });
    $('#frmCab').css({ 'display': 'block' });
    $('#divTela').css({ 'width': '700px', 'padding-bottom': '2px' });
	
	// Ajustar o label do botao "PROSSEGUIR"
	trocaBotao("Prosseguir");
	
	// Adicionar o foco no campo de OPCAO 
    $("#cddopcao", "#frmCab").focus();
    
}

/**
 * Formatacao dos campos do cabecalho
 */
function formataCabecalho() {

	// Labels
	$('label[for="cddopcao"]',"#frmCab").addClass("rotulo").css({"width":"120px"}); 
	
	// Campos
    $("#cddopcao", "#frmCab").css("width", "450px").habilitaCampo();
	
    $('input[type="text"],select', '#frmCab').limpaFormulario().removeClass('campoErro');
	
	//Define ação para ENTER e TAB no campo Opção
    $("#cddopcao", "#frmCab").unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Executar a liberacao dos campos do formulario de acordo com a opcao
			liberaFormulario();
			return false;
		}
    });	
	
	//Define ação para CLICK no botão de OK
    $("#btnOK", "#frmCab").unbind('click').bind('click', function () {
		// Executar a liberacao dos campos do formulario de acordo com a opcao
		liberaFormulario();
		// Remover o click do botao, para nao executar mais de uma vez
		$(this).unbind('click');
		return false;
    });	
	
	layoutPadrao();
	
	return false;	
}

/**
 * Formatacao dos campos do filtro de consulta
 */
function formataFiltros() {
	// Labels
	$('label[for="cdhistor"]','#fsetFiltroConsultar').addClass('rotulo').css({'width':'120px'});
	$('label[for="dshistor"]','#fsetFiltroConsultar').addClass('rotulo-linha').css({'width':'70px'});
	$('label[for="tpltmvpq"]','#fsetFiltroConsultar').addClass('rotulo-linha').css({'width':'45px'});
	$('label[for="cdgrupo_historico"]','#fsetFiltroConsultar').addClass('rotulo').css({'width':'120px'});
	
	// Campos
	$('#cdhistor','#fsetFiltroConsultar').css({'width':'60px'}).setMask('INTEGER','z.zzz','.','');
	$('#dshistor','#fsetFiltroConsultar').css({'width':'110px'});
	$('#tpltmvpq','#fsetFiltroConsultar').css({'width':'40px'});
	$('#cdgrupo_historico','#fsetFiltroConsultar').css({'width':'60px'}).attr('maxlength','5').setMask('INTEGER','zzzzz','','');
	$('#dsgrupo_historico','#fsetFiltroConsultar').css({'width':'350px'});

	// Limpar todos os campos do formulario, e remover o destaque dos campos com erro
    $('input[type="text"],select', '#fsetFiltroConsultar').limpaFormulario().removeClass('campoErro');
	
	// Esconder a tela de filtros
    $('#frmFiltros').css({ 'display': 'none' });
    highlightObjFocus($('#frmFiltros'));
	
	// Controlar o foco dos campos quando pressionar TAB ou ENTER
	controlaCamposFiltroConsulta();

	layoutPadrao();
	
	return false;
}

/**
 * Formatacao dos campos do historico
 */
function formataCadastroHistorico() {
	// LABEL - Dados Gerais
    $('label[for="cdhistor"]', '#frmHistorico').addClass('rotulo').css({ 'width': '120px' });
    $('label[for="cdhinovo"]', '#frmHistorico').addClass('rotulo-linha').css({ 'width': '100px' });
    $('label[for="dshistor"]', '#frmHistorico').addClass('rotulo').css({ 'width': '120px' });
    $('label[for="indebcre"]', '#frmHistorico').addClass('rotulo').css({ 'width': '120px' });
    $('label[for="tplotmov"]', '#frmHistorico').addClass('rotulo-linha').css({ 'width': '100px' });
    $('label[for="inhistor"]', '#frmHistorico').addClass('rotulo-linha').css({ 'width': '90px' });
    $('label[for="dsexthst"]', '#frmHistorico').addClass('rotulo').css({ 'width': '120px' });
    $('label[for="dsextrat"]', '#frmHistorico').addClass('rotulo').css({ 'width': '120px' });
    $('label[for="nmestrut"]', '#frmHistorico').addClass('rotulo').css({ 'width': '120px' });
	//PJ 416 - Início		
    $('label[for="indutblq"]', '#frmHistorico').addClass('rotulo').css({ 'width': '200px' }); 
	//PJ 416 - Fim
	
	// CAMPOS - Dados Gerais
    $('#cdhistor', '#frmHistorico').css({ 'width': '60px' }).setMask('INTEGER', 'z.zzz', '.', '');
    $('#cdhinovo', '#frmHistorico').css({ 'width': '60px' }).setMask('INTEGER', 'z.zzz', '.', '');
    $('#dshistor', '#frmHistorico').css({ 'width': '200px' }).attr('maxlength', '13');
    $('#indebcre', '#frmHistorico').css({ 'width': '100px' }).attr('maxlength', '1');
    $('#tplotmov', '#frmHistorico').css({ 'width': '60px' }).attr('maxlength', '3').setMask('INTEGER', 'zzz', '', '');
    $('#inhistor', '#frmHistorico').css({ 'width': '60px' }).attr('maxlength', '2').setMask('INTEGER', 'zz', '', '');
    $('#dsexthst', '#frmHistorico').css({ 'width': '455px' }).attr('maxlength', '50');
    $('#dsextrat', '#frmHistorico').css({ 'width': '200px' }).attr('maxlength', '21');
    $('#nmestrut', '#frmHistorico').css({ 'width': '250px' }).attr('maxlength', '32');
	// PJ416
    $('#indutblq', '#frmHistorico').css({ 'width': '50px' }).attr('maxlength', '1'); 
	
	
	// LABEL - Indicadores
    $('label[for="indoipmf"]', '#frmHistorico').addClass('rotulo').css({ 'width': '170px' });
    $('label[for="inclasse"]', '#frmHistorico').addClass('rotulo-linha').css({ 'width': '130px' });
    $('label[for="inautori"]', '#frmHistorico').addClass('rotulo').css({ 'width': '170px' });
    $('label[for="inavisar"]', '#frmHistorico').addClass('rotulo-linha').css({ 'width': '130px' });
    $('label[for="indcompl"]', '#frmHistorico').addClass('rotulo').css({ 'width': '170px' });
    $('label[for="indebcta"]', '#frmHistorico').addClass('rotulo-linha').css({ 'width': '130px' });
    $('label[for="incremes"]', '#frmHistorico').addClass('rotulo').css({ 'width': '170px' });
    $('label[for="inmonpld"]', '#frmHistorico').addClass('rotulo-linha').css({ 'width': '130px' });

	// CAMPOS - Indicadores	
    $('#indoipmf', '#frmHistorico').css({ 'width': '50px' }).attr('maxlength', '1').setMask('INTEGER', 'z', '', '');
    $('#inclasse', '#frmHistorico').css({ 'width': '50px' }).attr('maxlength', '6').setMask('INTEGER', 'zz.zzz', '', '');
    $('#inautori', '#frmHistorico').css({ 'width': '50px' });
    $('#inavisar', '#frmHistorico').css({ 'width': '50px' });
    $('#indcompl', '#frmHistorico').css({ 'width': '50px' });
    $('#indebcta', '#frmHistorico').css({ 'width': '120px' });
    $('#incremes', '#frmHistorico').css({ 'width': '160px' });
    $('#inmonpld', '#frmHistorico').css({ 'width': '50px' });

	
	// LABEL - Dados Contabeis
    $('label[for="cdhstctb"]', '#frmHistorico').addClass('rotulo').css({ 'width': '180px' });
    $('label[for="tpctbccu"]', '#frmHistorico').addClass('rotulo').css({ 'width': '180px' });
    $('label[for="tpctbcxa"]', '#frmHistorico').addClass('rotulo').css({ 'width': '180px' });
    $('label[for="nrctacrd"]', '#frmHistorico').addClass('rotulo').css({ 'width': '180px' });
    $('label[for="nrctadeb"]', '#frmHistorico').addClass('rotulo-linha').css({ 'width': '175px' });
    $('label[for="ingercre"]', '#frmHistorico').addClass('rotulo').css({ 'width': '180px' });
    $('label[for="ingerdeb"]', '#frmHistorico').addClass('rotulo-linha').css({ 'width': '175px' });
    $('label[for="nrctatrc"]', '#frmHistorico').addClass('rotulo').css({ 'width': '180px' });
    $('label[for="nrctatrd"]', '#frmHistorico').addClass('rotulo-linha').css({ 'width': '175px' });
    $('label[for="inestocc"]', '#frmHistorico').addClass('rotulo').css({ 'width': '520px' });
	$('label[for="indebprj"]', '#frmHistorico').addClass('rotulo').css({ 'width': '520px' });

	// CAMPOS - Dados Contabeis
    $('#cdhstctb', '#frmHistorico').css({ 'width': '50px' }).attr('maxlength', '5').setMask('INTEGER', 'zzzzz', '', '');
    $('#tpctbcxa', '#frmHistorico').css({ 'width': '295px' });
    $('#tpctbccu', '#frmHistorico').css({ 'width': '150px' });
    $('#nrctacrd', '#frmHistorico').css({ 'width': '50px' }).attr('maxlength', '4').setMask('INTEGER', 'zzzz', '', '');
    $('#nrctadeb', '#frmHistorico').css({ 'width': '50px' }).attr('maxlength', '4').setMask('INTEGER', 'zzzz', '', '');
    $('#ingercre', '#frmHistorico').css({ 'width': '80px' });
    $('#ingerdeb', '#frmHistorico').css({ 'width': '80px' });
    $('#nrctatrc', '#frmHistorico').css({ 'width': '50px' }).attr('maxlength', '4').setMask('INTEGER', 'zzzz', '', '');
    $('#nrctatrd', '#frmHistorico').css({ 'width': '50px' }).attr('maxlength', '4').setMask('INTEGER', 'zzzz', '', '');
    $('#inestocc', '#frmHistorico').css({ 'width': '80px' });
	$('#indebprj', '#frmHistorico').css({ 'width': '80px' });

	
	// LABEL - Tarifas
    $('label[for="vltarayl"]', '#frmHistorico').addClass('rotulo').css({ 'width': '60px' });
    $('label[for="vltarcxo"]', '#frmHistorico').addClass('rotulo-linha').css({ 'width': '50px' });
    $('label[for="vltarint"]', '#frmHistorico').addClass('rotulo-linha').css({ 'width': '65px' });
    $('label[for="vltarcsh"]', '#frmHistorico').addClass('rotulo-linha').css({ 'width': '50px' });

	// CAMPOS - Tarifas	
    $('#vltarcxo', '#frmHistorico').css({ 'width': '75px' }).addClass('moeda');
    $('#vltarint', '#frmHistorico').css({ 'width': '75px' }).addClass('moeda');
    $('#vltarcsh', '#frmHistorico').css({ 'width': '75px' }).addClass('moeda');
    $('#vltarayl', '#frmHistorico').css({ 'width': '75px' }).addClass('moeda');

	// LABEL - Situacoes de Conta
	$('label[for="cdgrupo_historico"]','#frmHistorico').addClass('rotulo').css({'width':'130px'});
	
	// CAMPO - Situacoes de Conta
	$('#cdgrupo_historico','#frmHistorico').css({'width':'60px'}).attr('maxlength','5').setMask('INTEGER','zzzzz','','');
	$('#dsgrupo_historico','#frmHistorico').css({'width':'350px'}).desabilitaCampo();

	// LABEL - Outros
    $('label[for="flgsenha"]', '#frmHistorico').addClass('rotulo').css({ 'width': '100px' });
    $('label[for="cdprodut"]', '#frmHistorico').addClass('rotulo').css({ 'width': '100px' });
    $('label[for="cdagrupa"]', '#frmHistorico').addClass('rotulo').css({ 'width': '100px' });
	$('label[for="idmonpld"]', '#frmHistorico').addClass('rotulo').css({ 'width': '100px' });
    $('label[for="inperdes"]', '#frmHistorico').addClass('rotulo').css({ 'width': '190px' });

	// CAMPOS - Outros
    $('#flgsenha', '#frmHistorico').css({ 'width': '60px' });
    $('#cdprodut', '#frmHistorico').css({ 'width': '60px' }).attr('maxlength', '5').setMask('INTEGER', 'zzzzz', '', '');
    $('#dsprodut', '#frmHistorico').css({ 'width': '350px' }).desabilitaCampo();
    $('#cdagrupa', '#frmHistorico').css({ 'width': '60px' }).attr('maxlength', '5').setMask('INTEGER', 'zzzzz', '', '');
    $('#dsagrupa', '#frmHistorico').css({ 'width': '350px' }).desabilitaCampo();
	$('#idmonpld', '#frmHistorico').css({ 'width': '60px' });
    $('#inperdes', '#frmHistorico').css({ 'width': '60px' });

	
    $('input[type="text"],select', '#frmHistorico').desabilitaCampo().limpaFormulario().removeClass('campoErro');
	
	// Controlar o foco dos campos quando pressionar TAB ou ENTER
	controlaCamposCadastroHistorico();
	
	layoutPadrao();
	
	return false;	
}

/**
 * Formatacao dos botoes da tela
 */
function formataBotoes() {
	//Define ação para CLICK no botão de VOLTAR
    $("#btVoltar", "#divBotoes").unbind('click').bind('click', function () {
		// Realizar o voltar da tela de acordo com a OPCAO selionada
		voltar();
		return false;
    });	

	//Define ação para CLICK no botão de Prosseguir
    $("#btSalvar", "#divBotoes").unbind('click').bind('click', function () {
		// Realizar a acao de prosseguir de acordo com a OPCAO selecionada
		prosseguir();
		return false;
    });	

	layoutPadrao();

	return false;
}

/**
 * Funcao para liberar os campos da tela de acordo com a OPCAO selecionada
 */
function liberaFormulario() {
	// Validar qual a opcao que o usuario selecionou
    switch ($("#cddopcao", "#frmCab").val()) {
		case "C": // Consultar Historicos
			liberaAcaoConsultar();
		break;
		
		case "I": // Incluir Historicos
			liberaAcaoIncluir();
		break;
		
		case "A": // Alterar Historicos
			liberaAcaoAlterar();
		break;
		
		case "X": // Replicar Historicos
			liberaAcaoReplicar();
		break;
		
		case "B": // Listar Historicos Boletim de Caixa
			liberaAcaoListarBoletim();
		break;
		
		case "O": // Listar Historicos OUTROS
			liberaAcaoListarOutros();
		break;
	}
}

/**
 * Funcao para liberar os campos de Filtro da Consulta
 */
function liberaAcaoConsultar() {
	// Limpar a tabela de historicos
    $('#frmTabHistoricos').css({ 'display': 'none' });
    $('#divHistoricos', '#frmTabHistoricos').html('');
	// Liberar os filtros de consulta
	liberaFiltrosConsultar();
}

/**
 * Funcao para liberar os campos de opcao "INCLUIR"
 */
function liberaAcaoIncluir() {
	// Alterar o label do botao para "Incluir"
	trocaBotao("Incluir");
	// Liberar todos os campos do cadastro, incluindo o campo "NOVO CODIGO"
	liberaCadastro();
}

/**
 * Funcao para liberar os campos de opcao "ALTERAR"
 */
function liberaAcaoAlterar() {
	// Alterar o label do botao para "Alterar"
	trocaBotao("Alterar");	
	// Liberar todos os campos do cadastro, sem o campo "NOVO CODIGO"
	liberaCadastro();
}

/**
 * Funcao para liberar os campos de opcao "REPLICAR"
 */
function liberaAcaoReplicar() {
	// Alterar o label do botao para "Replicar"
	trocaBotao("Replicar");
	// Liberar todos os campos do cadastro, sem o campo "NOVO CODIGO"
	liberaCadastro();
}

/**
 * Funcao para liberar os campos de opcao "Listar Historicos do Boletim"
 */
function liberaAcaoListarBoletim() {
	// Limpar a tabela que lista os historicos
	liberaAcaoListar();
	// Solicitamos a confirmacao, pois a tela nao possui campos para serem informados
    showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'consultarHistoricosBoletim(1,false);', 'estadoInicial();', 'sim.gif', 'nao.gif');
}

/**
 * Funcao para liberar os campos de opcao "Listar Historico OUTROS"
 */
function liberaAcaoListarOutros() {
	// Limpar a tabela que lista os historicos
	liberaAcaoListar();
	// Solicitamos a confirmacao, pois a tela nao possui campos para serem informados
    showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'consultarHistoricosOutros(1,false);', 'estadoInicial();', 'sim.gif', 'nao.gif');
}

/**
 * Funcao para liberar os campos da consulta
 */
function liberaFiltrosConsultar() {
	// Desabilitar a opção
    $("#cddopcao", "#frmCab").desabilitaCampo();
	// Limpar formulário
	$('input[type="text"],select','#frmFiltros').limpaFormulario().removeClass('campoErro').habilitaCampo();
	$('#dsgrupo_historico','#fsetFiltroConsultar').desabilitaCampo();
	
	// Mostrar a tela
    $('#frmFiltros').css({ 'display': 'block' });
    $('#fsetFiltroConsultar', '#frmFiltros').css({ 'display': 'block' });
    $('#divBotoes').css({ 'display': 'block', 'padding-bottom': '15px' });
    $('#btVoltar', '#divBotoes').css({ 'display': 'inline' });
    $('#btSalvar', '#divBotoes').css({ 'display': 'inline' });
	
	// Adicionar foco no primeiro campo
    $("#cdhistor", "#fsetFiltroConsultar").val("").focus();
}

/**
 * Funcao para liberar os campos de cadastro do historico
 */
function liberaCadastro() {
	// Desabilitar a opção
    $("#cddopcao", "#frmCab").desabilitaCampo();
	// Limpar formulário
    $('input[type="text"],select', '#frmHistorico').limpaFormulario().desabilitaCampo().removeClass('campoErro');
	// Mostrar a tela
    $('#frmHistorico').css({ 'display': 'block' });
    $('#divBotoes').css({ 'display': 'block', 'padding-bottom': '15px' });
    $('#btVoltar', '#divBotoes').css({ 'display': 'inline' });
    $('#btSalvar', '#divBotoes').css({ 'display': 'inline' });
	
	// Verificar se o campo "Codigo Novo" deve ser mostrado
    if ($("#cddopcao", "#frmCab").val() == "I") {
        $('label[for="cdhinovo"]', '#frmHistorico').show();
        $('#cdhinovo', '#frmHistorico').show().habilitaCampo();
	} else {
        $('label[for="cdhinovo"]', '#frmHistorico').hide();
        $('#cdhinovo', '#frmHistorico').hide().desabilitaCampo();
	}
	
	//Setar a opcao padrao das listas
    $('#indebcre', '#frmHistorico').val("D");
    $('#inautori', '#frmHistorico').val("0");
    $('#inavisar', '#frmHistorico').val("0");
    $('#indcompl', '#frmHistorico').val("0");
    $('#indebcta', '#frmHistorico').val("0");
    $('#incremes', '#frmHistorico').val("0");
    $('#inmonpld', '#frmHistorico').val("0");
    $('#tpctbcxa', '#frmHistorico').val("0");
    $('#tpctbccu', '#frmHistorico').val("0");
	$('#inestocc', '#frmHistorico').val("0");
	$('#indebprj', '#frmHistorico').val("0");
    $('#ingercre', '#frmHistorico').val("1");
    $('#ingerdeb', '#frmHistorico').val("1");
    $('#flgsenha', '#frmHistorico').val("1");
	$('#idmonpld', '#frmHistorico').val("1");
	//PJ 416
    $('#indutblq', '#frmHistorico').val("S");
	$('#inperdes', '#frmHistorico').val("0");
	

	
	// Adicionar foco no primeiro campo
    $("#cdhistor", "#frmHistorico").habilitaCampo().val("").focus();
}

/**
 * Funcao para liberar os campos da opcao de listagem dos historicos
 * Altera o label do botao para "IMPRIMIR"
 */
function liberaAcaoListar() {
	// Desabilitar a opção
    $("#cddopcao", "#frmCab").desabilitaCampo();
    $('#divBotoes').css({ 'display': 'block', 'padding-bottom': '15px' });
    $('#btVoltar', '#divBotoes').css({ 'display': 'inline' });
    $('#btSalvar', '#divBotoes').css({ 'display': 'inline' });

	// Limpar a tabela de historicos
    $('#frmTabHistoricos').css({ 'display': 'none' });
    $('#divHistoricos', '#frmTabHistoricos').html('');
	
	// Alterar o label do botao para "IMPRIMIR"
	trocaBotao("Imprimir");
}

/**
 * Funcao para controlar a ordem dos campos dos filtros da consulta
 */
function controlaCamposFiltroConsulta(){
	
	$('#cdgrupo_historico','#fsetFiltroConsultar').removeAttr('aux');
	
	// Validacao do campo CDHISTOR para quando executar o TAB ou ENTER
    $('#cdhistor', '#fsetFiltroConsultar').unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
			// Setar foco no campo DSHISTOR
            $('#dshistor', '#fsetFiltroConsultar').focus();
			return false;
		}	
	});
	
	// Validacao do campo DSHISTOR para quando executar o TAB ou ENTER
    $('#dshistor', '#fsetFiltroConsultar').unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
			// Setar foco no campo TPLTMVPQ
            $('#tpltmvpq', '#fsetFiltroConsultar').focus();
			return false;
		}	
	});
	
	// Validacao do campo TPLTMVPQ para quando executar o TAB ou ENTER
	$('#tpltmvpq','#fsetFiltroConsultar').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			// Setar foco no campo CDGRUPO_HISTORICO
			$('#cdgrupo_historico','#fsetFiltroConsultar').focus();
			return false;
		}	
	});
	
	// Validacao do campo CDGRUPO_HISTORICO para quando executar o TAB ou ENTER
	$('#cdgrupo_historico','#fsetFiltroConsultar').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
		
			$('#divTela').css('display','block');
			
			var bo = 'ZOOM0001';
			var procedure = 'BUSCA_GRUPO_HISTORICO';
			var titulo = 'Grupo de Hist&oacute;rico';
			buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'dsgrupo_historico', $(this).val(), 'dsgrupo_historico', '', 'fsetFiltroConsultar','$(\"#btSalvar\",\"#divBotoes\").focus();');
			
			return false;
		}	
	});
}


/**
 * Funcao para controlar a ordem dos campos da tela de Historico
 */
function controlaCamposCadastroHistorico() {
	//Define ação para ENTER e TAB no campo Codigo do Historico
    $("#cdhistor", "#frmHistorico").unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Executar a opcao de selecionar o historico
            if ($("#cddopcao", "#frmCab").val() == "I") {
                $("#cdhinovo", "#frmHistorico").focus();
			} else {
				executaSelecaoHistorico(0);
			}
			return false;
		}
    });	
	
	//Define ação para ENTER e TAB no campo Novo Codigo do Historico
    $("#cdhinovo", "#frmHistorico").unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Executar a opcao de selecionar o historico
			executaSelecaoHistorico(1);
			return false;
		}
    });	
	
	//Define ação para ENTER e TAB no campo descricao do historico
    $("#dshistor", "#frmHistorico").unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Setar foco no proximo campo
            $("#indebcre", "#frmHistorico").focus();
			return false;
		}
    });	
	
	//Define ação para ENTER e TAB no campo debito/credito
    $("#indebcre", "#frmHistorico").unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Setar foco no proximo campo
            $("#tplotmov", "#frmHistorico").focus();
			return false;
		}
    });	
	
	//Define ação para ENTER e TAB no campo tipo de lote
    $("#tplotmov", "#frmHistorico").unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Setar foco no proximo campo
            $("#inhistor", "#frmHistorico").focus();
			return false;
		}
    });	

	//Define ação para ENTER e TAB no campo Ind de Funcao
    $("#inhistor", "#frmHistorico").unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Setar foco no proximo campo
            $("#dsexthst", "#frmHistorico").focus();
			return false;
		}
    });	

	//Define ação para ENTER e TAB no campo descricao do historico por extenso
    $("#dsexthst", "#frmHistorico").unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Setar foco no proximo campo
            $("#dsextrat", "#frmHistorico").focus();
			return false;
		}
    });	

	//Define ação para ENTER e TAB no campo descricao do historico no extrato
    $("#dsextrat", "#frmHistorico").unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Setar foco no proximo campo
            $("#nmestrut", "#frmHistorico").focus();
			return false;
		}
    });	

	//Define ação para ENTER e TAB no campo nome da estrutura
    $("#nmestrut", "#frmHistorico").unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Setar foco no proximo campo
            $("#indoipmf", "#frmHistorico").focus();
			return false;
		}
    });	

	//Define ação para ENTER e TAB no campo indicador da incidencia do IPMF
    $("#indoipmf", "#frmHistorico").unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Setar foco no proximo campo
            $("#inclasse", "#frmHistorico").focus();
			return false;
		}
    });	

	//Define ação para ENTER e TAB no campo classe do CPMF
    $("#inclasse", "#frmHistorico").unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Setar foco no proximo campo
            $("#inautori", "#frmHistorico").focus();
			return false;
		}
    });	

	//Define ação para ENTER e TAB no campo indicador de autorizacao de debito
    $("#inautori", "#frmHistorico").unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Setar foco no proximo campo
            $("#inavisar", "#frmHistorico").focus();
			return false;
		}
    });	

	//Define ação para ENTER e TAB no campo indicador de aviso para debito
    $("#inavisar", "#frmHistorico").unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Setar foco no proximo campo
            $("#indcompl", "#frmHistorico").focus();
			return false;
		}
    });	

	//Define ação para ENTER e TAB no campo indicador de complemento
    $("#indcompl", "#frmHistorico").unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Setar foco no proximo campo
            $("#indebcta", "#frmHistorico").focus();
			return false;
		}
    });	
	
	//Define ação para ENTER e TAB no campo indicador de debito em conta
    $("#indebcta", "#frmHistorico").unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Setar foco no proximo campo
            $("#incremes", "#frmHistorico").focus();
			return false;
		}
    });	
	
	//Define ação para ENTER e TAB no campo indicador para estatistica de credito no mes
    $("#incremes", "#frmHistorico").unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Setar foco no proximo campo
            $("#inmonpld", "#frmHistorico").focus();
			return false;
		}
    });	
	
    //Define ação para ENTER e TAB no campo indicador para estatistica de credito no mes
    $("#inmonpld", "#frmHistorico").unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            // Setar foco no proximo campo
            $("#cdhstctb", "#frmHistorico").focus();
            return false;
        }
    });

	//Define ação para ENTER e TAB no campo historico contabilidade
    $("#cdhstctb", "#frmHistorico").unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Setar foco no proximo campo
            $("#tpctbccu", "#frmHistorico").focus();
			return false;
		}
    });	
	
	//Define ação para ENTER e TAB no campo tipo de contabilizacao do centro de custo
    $("#tpctbccu", "#frmHistorico").unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Setar foco no proximo campo
            $("#tpctbcxa", "#frmHistorico").focus();
			return false;
		}
    });	
	
	//Define ação para ENTER e TAB no campo tipo de contabilizacao do caixa
    $("#tpctbcxa", "#frmHistorico").unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Setar foco no proximo campo
            $("#nrctacrd", "#frmHistorico").focus();
			return false;
		}
    });	
	
	//Define ação para ENTER e TAB no campo conta a creditar
    $("#nrctacrd", "#frmHistorico").unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Setar foco no proximo campo
            $("#nrctadeb", "#frmHistorico").focus();
			return false;
		}
    });	
	
	//Define ação para ENTER e TAB no campo conta a debitar
    $("#nrctadeb", "#frmHistorico").unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Setar foco no proximo campo
            $("#ingercre", "#frmHistorico").focus();
			return false;
		}
    });	
	
	//Define ação para ENTER e TAB no campo gerencial a credito
    $("#ingercre", "#frmHistorico").unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Setar foco no proximo campo
            $("#ingerdeb", "#frmHistorico").focus();
			return false;
		}
    });	
	
	//Define ação para ENTER e TAB no campo gerencial a debito
    $("#ingerdeb", "#frmHistorico").unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Setar foco no proximo campo
            $("#nrctatrc", "#frmHistorico").focus();
			return false;
		}
    });	
	

	//Define ação para ENTER e TAB no campo conta tarifa credito
	$("#nrctatrc", "#frmHistorico").unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Setar foco no proximo campo
			$("#indebprj", "#frmHistorico").focus();
			return false;
		}
	});		

	//Define ação para ENTER e TAB no campo debita prejuízo
	$("#indebprj", "#frmHistorico").unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Setar foco no proximo campo
			$("#nrctatrd", "#frmHistorico").focus();
			return false;
		}
	});
	
	//Define ação para ENTER e TAB no campo conta tarifa debito
    $("#nrctatrd", "#frmHistorico").unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Setar foco no proximo campo
            $("#vltarayl", "#frmHistorico").focus();
			return false;
		}
    });	

	//Define ação para ENTER e TAB no campo tarifa - ayllos
    $("#vltarayl", "#frmHistorico").unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Setar foco no proximo campo
            $("#vltarcxo", "#frmHistorico").focus();
			return false;
		}
    });	
	
	//Define ação para ENTER e TAB no campo tarifa - caixa
    $("#vltarcxo", "#frmHistorico").unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Setar foco no proximo campo
            $("#vltarint", "#frmHistorico").focus();
			return false;
		}
    });	
	
	//Define ação para ENTER e TAB no campo tarifa - internet
    $("#vltarint", "#frmHistorico").unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Setar foco no proximo campo
            $("#vltarcsh", "#frmHistorico").focus();
			return false;
		}
    });	
	
	//Define ação para ENTER e TAB no campo tarifa - cash
    $("#vltarcsh", "#frmHistorico").unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Setar foco no proximo campo
			$("#cdgrupo_historico","#frmHistorico").focus();
			return false;
		}
    });	
	
	// Acao para quando alterar o valor do campo
	$('#cdgrupo_historico','#frmHistorico').unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Setar foco no proximo campo
			$('#divTela').css('display','block');
		
			var bo = 'ZOOM0001';
			var procedure = 'BUSCA_GRUPO_HISTORICO';
			var titulo = 'Grupo de Hist&oacute;rico';
			buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'dsgrupo_historico', $(this).val(), 'dsgrupo_historico', '', 'frmHistorico','$("#flgsenha", "#frmHistorico").focus();');
			
			return false;
		}
    });	
	
	//Define ação para ENTER e TAB no campo solicitar senha
    $("#flgsenha", "#frmHistorico").unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Setar foco no proximo campo
			// PJ 416 - Início
            //$("#cdprodut", "#frmHistorico").focus();
            $("#indutblq", "#frmHistorico").focus();	
			// PJ 416 Fim
            return false;
        }
    });
	//PJ 416 - Início
    //Define ação para ENTER e TAB no campo solicitar senha
    $("#indutblq", "#frmHistorico").unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            // Setar foco no proximo campo
            $("#cdprodut", "#frmHistorico").focus();
			return false;
		}
    });	
	//PJ 416 - Fim
	
    // Acao para quando alterar o valor do campo
	$("#cdprodut", "#frmHistorico").unbind('change').bind('change', function () {

        $('#divTela').css('display', 'block');
	
		var bo = 'b1wgen0179.p';
	    var procedure = 'Busca_Produto';
	    var titulo = 'Produto';
		buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'dsprodut', $(this).val(), 'dsprodut', 'undefined', 'frmHistorico');
		
		return false;
	});

    //Define ação para ENTER e TAB no campo codigo do produto
	$("#cdprodut", "#frmHistorico").unbind('keypress').bind('keypress', function (e) {
	    if (e.keyCode == 9 || e.keyCode == 13) {
	        // Setar foco no proximo campo
	        $("#cdagrupa", "#frmHistorico").focus();
	        return false;
	    }
	});

    // Acao para quando alterar o valor do campo
	$("#cdagrupa", "#frmHistorico").unbind('change').bind('change', function () {

        $('#divTela').css('display', 'block');

		// Informacoes da pesquisa
	    var bo = 'b1wgen0179.p';
	    var procedure = 'Busca_Grupo';
	    var titulo = 'Agrupamento';
	    buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'dsagrupa', $(this).val(), 'dsagrupa', 'undefined', 'frmHistorico');
	    return false;
	});

    //Define ação para ENTER e TAB no campo codigo do agrupamento
	$("#cdagrupa", "#frmHistorico").unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Finaliza o cadastro
			$('#idmonpld', '#frmHistorico').focus();
			return false;
		}
    });	
	
    $("#idmonpld", "#frmHistorico").unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Finaliza o cadastro
			$('#btSalvar', '#divBotoes').focus();
			return false;
		}
    });	
	
	//Chama tela para pedir senha de coordenador quando o histórico for flegado sim
	//para estourar a conta (Diego Simas - AMcom)	
	$("#inestocc", "#frmHistorico").unbind('change').bind('change', function () {			
		var inestocc = $(this).val();
		var opcao = $("#cddopcao", "#frmCab").val();		
		//só pedir senha caso haja alteração no inesstocc (Indicador para Estourar Conta)
		if(opcao == "A"){	
			if(inestocc == 0){
				$('#inestocc', '#frmHistorico').val(1);
			}else{
				$('#inestocc', '#frmHistorico').val(0);
			}			
				bloqueiaFundo(divRotina);
				pedeSenhaCoordenador(2, 'voltaTelaSenha('+inestocc+');', '');
				return false;			
		}else{
			if (aux_inestocc != inestocc) {
				$('#inestocc', '#frmHistorico').val(0);
				bloqueiaFundo(divRotina);
				pedeSenhaCoordenador(2, 'voltaTelaSenha(1);', '');
				return false;
			}			
		}		
	});	

	//Chama tela para pedir senha de coordenador quando o histórico for flegado sim
	//para debitar após transferência da conta para prejuízo (Diego Simas - AMcom)
	$("#indebprj", "#frmHistorico").unbind('change').bind('change', function () {
		var indebprj = $(this).val();
		var opcao = $("#cddopcao", "#frmCab").val();
		//só pedir senha caso haja alteração no inesstocc (Indicador para Estourar Conta)
		if (opcao == "A") {
			if (indebprj == 0) {
				$('#indebprj', '#frmHistorico').val(1);
			} else {
				$('#indebprj', '#frmHistorico').val(0);
			}
			bloqueiaFundo(divRotina);
			pedeSenhaCoordenador(2, 'voltaTelaSenha(' + indebprj + ');', '');
			return false;
		} else {
			if (aux_indebprj != indebprj) {
				$('#indebprj', '#frmHistorico').val(0);
				bloqueiaFundo(divRotina);
				pedeSenhaCoordenador(2, 'voltaTelaSenha(1);', '');
				return false;
			}
		}
	});	

	$("#indutblq", "#frmHistorico").unbind('change').bind('change', function () {

    	indutblq = $("#indutblq", "#frmHistorico").val();

    	if(indutblq == 'N'){
    		mostraSenha();
}

		return false;
	});
}

/**
 * Funcao para controlar a execucao do botao VOLTAR
 */
function voltaTelaSenha(valor) {
	$('#inestocc', '#frmHistorico').val(valor);
	$('#indebprj', '#frmHistorico').val(valor);
	$("#divUsoGenerico").css("visibility", "hidden");
	$("#divUsoGenerico").html("");
	unblockBackground();				
}


/**
 * Funcao para controlar a execucao do botao VOLTAR
 */
function voltar() {
	// Validar a opcao selecionada em tela
    switch ($("#cddopcao", "#frmCab").val()) {
		
		case "C": // Consultar
            if ($('#cdhistor', '#fsetFiltroConsultar').prop('disabled')) {
				// Se o campo CDHISTOR, da tela de filtro estiver desabilitada, 
				// vamos voltar apenas uma etapa
				// liberando os campos da opcao de consultar da tela
				liberaAcaoConsultar();							
            } else {
				// Volta para o estado inicial da tela
				estadoInicial();
			}
		break;
		
		case "I": // Incluir Historicos
            if ($('#cdhistor', '#frmHistorico').prop('disabled')) {
				// Se o campo CDHISTOR, da tela de Historico estiver desabilitado
				// vamos voltar apenas uma etapa
				// liberando os campos da opcao de incluir
				liberaAcaoIncluir();							
            } else {
				// Volta para o estado inicial da tela
				estadoInicial();
			}
		break;
		
		case "A": // Alterar Historicos
            if ($('#cdhistor', '#frmHistorico').prop('disabled')) {
				// Se o campo CDHISTOR, da tela de Historico estiver desabilitado
				// vamos voltar apenas uma etapa
				// liberando os campos da opcao de alterar
				liberaAcaoAlterar();							
            } else {
				// Volta para o estado inicial da tela
				estadoInicial();
			}
		break;
		
		case "X": // Replicar Historicos
            if ($('#cdhistor', '#frmHistorico').prop('disabled')) {
				// Se o campo CDHISTOR, da tela de Historico estiver desabilitado
				// vamos voltar apenas uma etapa
				// liberando os campos da opcao de replicar
				liberaAcaoReplicar();							
            } else {
				// Volta para o estado inicial da tela
				estadoInicial();
			}
		break;

		case "B": // Listar Historicos Rotina 11
			// A opcao de Listar os Historico do Boletim de Caixa nao possui nenhum campo informado em tela
			// com isso volta para o estado inicial da tela
			estadoInicial();
		break;

		case "O": // Listar Historicos Rotina  56 
			// A opcao de Listar os Historico da tela OUTROS nao possui nenhum campo informado em tela
			// com isso volta para o estado inicial da tela
			estadoInicial();
		break;

		default:
			estadoInicial();
	}
}

/**
 * Funcao para controlar a execucao do botao PROSSEGUIR
 */
function prosseguir() {
    
    if (divError.css('display') == 'block') { return false; }

	// Validar a opcao selecionada em tela
    switch ($("#cddopcao", "#frmCab").val()) {
		
		case "C": // Consultar
			// Solicitar a confirmacao da consulta dos historicos
            showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'consultarHistoricos(1,false);', '', 'sim.gif', 'nao.gif');
		break;
		
		case "I": // Incluir
			// Solicitar a confirmacao da incluir historico
            showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'manterRotina();', '', 'sim.gif', 'nao.gif');
		break;
		
		case "A": // Alterar
			// Solicitar a confirmacao da incluir historico
            showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'manterRotina();', '', 'sim.gif', 'nao.gif');
		break;
		
		case "X": // Replicar
			// Solicitar a confirmacao da incluir historico
            showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'manterRotina();', '', 'sim.gif', 'nao.gif');
		break;
		
		case "B": // Listar Historicos Rotina 11
			// Solicitar a confirmacao da impressao dos historicos do Boletim de Caixa
            showConfirmacao('Confirmar impress&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'geraImpressao();', '', 'sim.gif', 'nao.gif');
		break;

		case "O": // Listar Historicos Rotina  56 
			// Solicitar a confirmacao da impressao dos historicos da tela OUTROS
            showConfirmacao('Confirmar impress&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'geraImpressao();', '', 'sim.gif', 'nao.gif');
		break;
	}

	return false;
}

/**
 * Controlar a pesquisa de historicos
 */
function controlaPesquisaHistorico() {

	// Definir o tamanho da tela de pesquisa
    $("#divCabecalhoPesquisa").css("width", "100%");
    $("#divResultadoPesquisa").css("width", "100%");

	// Se esta desabilitado o campo 
    if ($("#cdhistor", "#frmHistorico").prop("disabled") == true) { return; }
	
	$('input,select', "#frmHistorico").removeClass('campoErro'); 
	
	//Remove a classe de Erro do form
	$('input,select', "#frmHistorico").removeClass('campoErro');
	
	// Informacoes para pesquisa
    var bo = 'b1wgen0153.p';
	var procedure = 'lista-historicos';
    var titulo = 'Historicos';
    var qtReg = '20';
    var filtros = 'C&oacutedigo;cdhistor;80px;S;;S|Hist&oacuterico;dshistor;280px;S;;S';
    var colunas = 'C&oacutedigo;cdhistor;20%;right|Hist&oacuterico;dshistor;50%;left';
	
	// Exibir a tela de pesquisa
    mostraPesquisa(bo, procedure, titulo, qtReg, filtros, colunas, $('#divTela'), 'executaSelecaoHistorico(0);');
	
	return false;
}

/**
 * Controlar a pesquisa de agrupamentos
 */
function controlaPesquisaAgrupamento() {
	// Definir o tamanho da tela de pesquisa
    $("#divCabecalhoPesquisa").css("width", "100%");
    $("#divResultadoPesquisa").css("width", "100%");

	// Se esta desabilitado o campo 
    if ($("#cdagrupa", "#frmHistorico").prop("disabled") == true) { return; }
	
	//Remove a classe de Erro do form
	$('input,select', '#frmHistorico').removeClass('campoErro');
	
    var cdagrupa = $('#cdagrupa', '#frmHistorico').val();
	var dsagrupa = '';
	
	// Informacoes da pesquisa
    var bo = 'b1wgen0179.p';
    var procedure = 'Busca_Grupo';
    var titulo = 'Agrupamento';
    var qtReg = '20';
    var filtros = 'C&oacutedigo;cdagrupa;80px;S;' + cdagrupa + ';S|Agrupamento;dsagrupa;280px;S;' + dsagrupa + ';S';
    var colunas = 'C&oacutedigo;cdagrupa;20%;right|Agrupamento;dsagrupa;50%;left';
	
	// Exibir a tela de pesquisa
    mostraPesquisa(bo, procedure, titulo, qtReg, filtros, colunas, $('#divTela'), '$(\'#cdagrupa\',\'#frmHistorico\').val()');
	
	return false;
}

/**
 * Controlar a pesquisa de Historico
 */
function controlaPesquisaGrupoHistorico(formulario) {
	
	// Definir o tamanho da tela de pesquisa
	$("#divCabecalhoPesquisa").css("width","100%");
	$("#divResultadoPesquisa").css("width","100%");
	
	// Se esta desabilitado o campo 
	if ($("#cdgrupo_historico","#" + formulario).prop("disabled") == true)  { return; }
	
	//Remove a classe de Erro do form
	$('input,select', '#' + formulario).removeClass('campoErro');
	
	// Informacoes da pesquisa
	var bo			  = 'ZOOM0001';
	var procedure	  = 'BUSCA_GRUPO_HISTORICO';
	var titulo        = 'Grupo Hist&oacute;rico';
	var qtReg		  = '20';
	var filtros 	  = 'C&oacutedigo;cdgrupo_historico;80px;S;;S|Grupo de Hist&oacuterico;dsgrupo_historico;280px;S;;S';
	var colunas 	  = 'C&oacutedigo;cdgrupo_historico;20%;right|Grupo de Hist&oacuterico;dsgrupo_historico;50%;left';
	
	// Exibir a tela de pesquisa
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,$('#divTela'),'$(\'#cdgrupo_historico\',\'#' + formulario + '\').val()');
	
	return false;
}

/**
 * Controlar a pesquisa de Produto
 */
function controlaPesquisaProduto() {
	// Definir o tamanho da tela de pesquisa
    $("#divCabecalhoPesquisa").css("width", "100%");
    $("#divResultadoPesquisa").css("width", "100%");

	// Se esta desabilitado o campo 
    if ($("#cdprodut", "#frmHistorico").prop("disabled") == true) { return; }
	
	//Remove a classe de Erro do form
	$('input,select', '#frmHistorico').removeClass('campoErro');
	
    var cdprodut = $('#cdprodut', '#frmHistorico').val();
	var dsprodut = '';
	
	// Informacoes da pesquisa
    var bo = 'b1wgen0179.p';
    var procedure = 'Busca_Produto';
    var titulo = 'Produto';
    var qtReg = '20';
    var filtros = 'C&oacutedigo;cdprodut;80px;S;' + cdprodut + ';S|Produto;dsprodut;280px;S;' + dsprodut + ';S';
    var colunas = 'C&oacutedigo;cdprodut;20%;right|Produto;dsprodut;50%;left';
	
	// Exibir a tela de pesquisa
    mostraPesquisa(bo, procedure, titulo, qtReg, filtros, colunas, $('#divTela'), '$(\'#cdprodut\',\'#frmHistorico\').val()');
	
	return false;
}

/**
 * Funcao para trocar o label do campo que deve sr exibido
 * labelBotao -> Titulo que deve ser exibido no botao
 */
function trocaBotao(labelBotao) {
	$('#btSalvar').text(labelBotao);
}

/**
 * Funcao para realizar a busca do Historicos de acordo com os filtros informados
 * nriniseq -> Sequencia que deve iniciar a pesquisa
 * paginacao -> se os registros estao sendo paginados
 */
function consultarHistoricos(nriniseq, paginacao) {	
	// Campos da tela
    var cddopcao = $('#cddopcao','#frmCab').val();
    var cdhistor = $('#cdhistor','#fsetFiltroConsultar').val();	
    var dshistor = $('#dshistor','#fsetFiltroConsultar').val();
    var tpltmvpq = $('#tpltmvpq','#fsetFiltroConsultar').val();
    var cdgrphis = $('#cdgrupo_historico','#fsetFiltroConsultar').val();
	
    showMsgAguardo("Aguarde, buscando Hist&oacute;ricos...");

	// Se a pesquisa eh paginada, listamos todos
    if (paginacao) {
		cdhistor = 0;
	}
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
		dataType: 'html',
        url: UrlSite + "telas/histor/consultar_historicos.php",
        data: {
			cddopcao: cddopcao, 	 
			cdhistor: cdhistor, 	 
			dshistor: dshistor,	 
			tpltmvpq: tpltmvpq,
			cdgrphis: cdgrphis,
			nrregist: nrregist,
			nriniseq: nriniseq,
			redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "$('#cdhistor','#fsetFiltroConsultar').focus();");
        },
        success: function (response) {
            hideMsgAguardo();
			try {
				// Executamos o resultado da requisicao
				eval(response);
				// Na consulta de historicos vamos desabilitar todos os campos da pesquisa e forçar que o usuário a utilizar a opcao de voltar primeiro
                $('input[type="text"],select', '#fsetFiltroConsultar').desabilitaCampo();
			} catch (error) {
					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#cdhistor','#fsetFiltroConsultar').focus();");
				}
			}
    });
    return false;
}

/**
 * Funcao para realizar a busca dos Historicos do Boletim de Caixa
 * nriniseq -> Sequencia que deve iniciar a pesquisa
 * paginacao -> se os registros estao sendo paginados
 */
function consultarHistoricosBoletim(nriniseq, paginacao) {	
	
    var cddopcao = $('#cddopcao', '#frmCab').val();
	
    showMsgAguardo("Aguarde, buscando Hist&oacute;ricos...");

    if (paginacao) {
		cdhistor = 0;
	}
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
		dataType: 'html',
        url: UrlSite + "telas/histor/consultar_historicos_boletim.php",
        data: {
			cddopcao: cddopcao,
			nrregist: nrregist,
			nriniseq: nriniseq,
			redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "estadoInicial();");
        },
        success: function (response) {
            hideMsgAguardo();
			try {
				// Executar o resultado da requisicao
				eval(response);
			} catch (error) {
					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "estadoInicial();");
				}
			}
    });
    return false;
}

/**
 * Funcao para realizar a busca do Historicos da tela OUTROS
 * nriniseq -> Sequencia que deve iniciar a pesquisa
 * paginacao -> se os registros estao sendo paginados
 */
function consultarHistoricosOutros(nriniseq, paginacao) {	
	
    var cddopcao = $('#cddopcao', '#frmCab').val();
	
    showMsgAguardo("Aguarde, buscando Hist&oacute;ricos...");

    if (paginacao) {
		cdhistor = 0;
	}
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
		dataType: 'html',
        url: UrlSite + "telas/histor/consultar_historicos_outros.php",
        data: {
			cddopcao: cddopcao,
			nrregist: nrregist,
			nriniseq: nriniseq,
			redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "estadoInicial();");
        },
        success: function (response) {
            hideMsgAguardo();
			try {
				// Executar o resultado da requisicao
				eval(response);
			} catch (error) {
					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "estadoInicial();");
				}
			}
    });
    return false;
}

/**
 * Funcao para formatacao da tabela de consulta dos historicos
 */
function formataTabelaConsulta() {
    var divRegistro = $('div.divRegistros', '#divHistoricos');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);
	
    divRegistro.css({ 'height': '250px', 'width': '700px', 'padding-bottom': '2px' });
    $('#divHistoricos').css({ 'padding-top': '10px' });

	var ordemInicial = new Array();
	
	var arrayLargura = new Array();
	arrayLargura[0] = '45px';
	arrayLargura[1] = '';
	arrayLargura[2] = '30px';
	arrayLargura[3] = '45px';
/*	arrayLargura[4] = '55px'; CPMF */ 
	arrayLargura[4] = '45px';
	arrayLargura[5] = '55px';
	arrayLargura[6] = '55px';
/*  arrayLargura[7] = '55px'; */
	
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'left';
	arrayAlinha[3] = 'right';	
/*	arrayAlinha[4] = 'right'; CPMF */
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'right';
	arrayAlinha[6] = 'right';
/*  arrayAlinha[7] = 'right'; */
	
    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');
	
    $('#divTabela').css({ 'display': 'block' });
	
	return false;
}

/**
 * Funcao para formatacao da tabela de historicos do boletim e da tela outros
 */
function formataTabelaHistoricos() {
    var divRegistro = $('div.divRegistros', '#divHistoricos');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);
	
    divRegistro.css({ 'height': '250px', 'width': '650px', 'padding-bottom': '2px' });
    $('#divHistoricos').css({ 'padding-top': '10px' });

	var ordemInicial = new Array();
	
	var arrayLargura = new Array();
	arrayLargura[0] = '60px';
	arrayLargura[1] = '';
	arrayLargura[2] = '50px';
	
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'left';
	
    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');
	
    $('#divTabela').css({ 'display': 'block' });
	
	return false;
}

/**
 * Funcao para gerar a impressao
 */
function geraImpressao() {
    $('#cddopcao', '#frmRelatorio').val($('#cddopcao', '#frmCab').val());
	
	var action = UrlSite + 'telas/histor/gerar_impressao.php';	
    carregaImpressaoAyllos("frmRelatorio", action, "");
	return false;
}

/**
 * Funcao para executar a selecao de um historico
 */
function executaSelecaoHistorico(validaNovoHistorico) {
	
    var cddopcao = $('#cddopcao', '#frmCab').val();
    var cdhistor = $('#cdhistor', '#frmHistorico').val();
    var cdhinovo = $('#cdhinovo', '#frmHistorico').val();
	
	// Validar a opcao selecionada
    if (cddopcao == 'A' || cddopcao == 'X') {
		// Se estiver selecionado a opcao de "A" (Alterar) ou "X" (Replicar), validamos se o codigo do historico foi informado
        if (cdhistor == '' || cdhistor == '0') {
            showError('error', 'C&oacute;digo do Hist&oacute;rico deve ser informado.', 'Alerta - Ayllos', "focaCampoErro(\'cdhistor\', \'frmHistorico\');");
			return false;
		}
	    // Se chegou aqui todas as validacoes estao OK
		buscaHistorico();
    }
	
    if (cddopcao == "I") {
        if (cdhistor == '' || cdhistor == '0') {
            showError('error', 'C&oacute;digo do Hist&oacute;rico deve ser informado.', 'Alerta - Ayllos', "focaCampoErro(\'cdhistor\', \'frmHistorico\');");
			return false;
		} else {
		    if (validaNovoHistorico == 1) {
		        if (cdhinovo == '' || cdhinovo == '0') {
		            showError('error', 'Novo C&oacute;digo do Hist&oacute;rico deve ser informado.', 'Alerta - Ayllos', "focaCampoErro(\'cdhinovo\', \'frmHistorico\');");
		            return false;
		        }

		        // Se chegou aqui todas as validacoes estao OK
		        buscaHistorico();
            } else {
		        $('#cdhinovo', '#frmHistorico').focus();
		    }
		}
	} 
}

/**
 * Funcao para buscar todos os dados do historico e carregar ele em tela
 */
function buscaHistorico() {	
    var cddopcao = $("#cddopcao", "#frmCab").val();
    var cdhistor = $("#cdhistor", "#frmHistorico").val();
    var cdhinovo = $("#cdhinovo", "#frmHistorico").val();
	
	showMsgAguardo('Aguarde, buscando Hist&oacute;rico...');

	$.ajax({		
        type: 'POST',
		dataType: 'html',
        url: UrlSite + 'telas/histor/busca_historico.php',
        data:
				{ 
				  cddopcao: cddopcao, 	 
				  cdhistor: cdhistor, 	 
				  cdhinovo: cdhinovo, 	 
				  redirect: 'script_ajax'
				},
        error: function (objAjax, responseError, objExcept) {
					hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '');
				},
        success: function (response) {
					hideMsgAguardo();
		            try {
						eval( response );
						$('#dsgrupo_historico', '#frmHistorico').desabilitaCampo();
						$('#dsprodut', '#frmHistorico').desabilitaCampo();
						$('#dsagrupa', '#frmHistorico').desabilitaCampo();
                liberaMonitoramento();
                    } catch (error) {
						hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '');
					}
				}
	}); 
}

/**
 * Funcao para ajustar o comportamento do campo Ind. Monitoramento de acordo com o Campo Debito/Credito
 */
function liberaMonitoramento() {
    var op = $('#indebcre', '#frmHistorico').val();
    var cddopcao = $('#cddopcao', '#frmCab').val();
    if (cddopcao == 'I') {
        if (op == 'D') {
            $('#inmonpld', '#frmHistorico').desabilitaCampo();
            $('#inmonpld', '#frmHistorico').val('0');
        } else {
            $('#inmonpld', '#frmHistorico').habilitaCampo();
            $('#inmonpld', '#frmHistorico').val('1');
        }
    } else {
        if (op == 'D') {
            $('#inmonpld', '#frmHistorico').desabilitaCampo();
            $('#inmonpld', '#frmHistorico').val('0');
        }
    }
}

/**
 * Funcao para realizar a gravacao dos dados do historico (Alterar/Incluir/Replicar)
 */
function manterRotina() {
	
	showMsgAguardo('Aguarde efetuando operacao...');

    var cddopcao = $('#cddopcao', '#frmCab').val();
    var cdhistor = $('#cdhistor', '#frmHistorico').val();
    var cdhinovo = $('#cdhinovo', '#frmHistorico').val();
	
    var cdhstctb = $('#cdhstctb', '#frmHistorico').val();
    var dsexthst = $('#dsexthst', '#frmHistorico').val();
    var dshistor = $('#dshistor', '#frmHistorico').val();
    var inautori = $('#inautori', '#frmHistorico').val();
    var inavisar = $('#inavisar', '#frmHistorico').val();
    var inclasse = $('#inclasse', '#frmHistorico').val();
    var incremes = $('#incremes', '#frmHistorico').val();
    var inmonpld = $('#inmonpld', '#frmHistorico').val();
    var indcompl = $('#indcompl', '#frmHistorico').val();
    var indebcta = $('#indebcta', '#frmHistorico').val();
    var indoipmf = $('#indoipmf', '#frmHistorico').val();
	var inestocc = $('#inestocc', '#frmHistorico').val();
	var indebprj = $('#indebprj', '#frmHistorico').val();

    var inhistor = $('#inhistor', '#frmHistorico').val();
    var indebcre = $('#indebcre', '#frmHistorico').val();
    var nmestrut = $('#nmestrut', '#frmHistorico').val();
    var nrctacrd = $('#nrctacrd', '#frmHistorico').val();
    var nrctatrc = $('#nrctatrc', '#frmHistorico').val();
    var nrctadeb = $('#nrctadeb', '#frmHistorico').val();
    var nrctatrd = $('#nrctatrd', '#frmHistorico').val();
    var tpctbccu = $('#tpctbccu', '#frmHistorico').val();
    var tplotmov = $('#tplotmov', '#frmHistorico').val();
    var tpctbcxa = $('#tpctbcxa', '#frmHistorico').val();

	var ingercre  = $('#ingercre','#frmHistorico').val();
	var ingerdeb  = $('#ingerdeb','#frmHistorico').val();
	
	var cdgrupo_historico  = $('#cdgrupo_historico','#frmHistorico').val();
	
	var flgsenha  = $('#flgsenha','#frmHistorico').val();
	var indutblq  = $('#indutblq','#frmHistorico').val();
	var cdprodut  = $('#cdprodut','#frmHistorico').val();
	var cdagrupa  = $('#cdagrupa','#frmHistorico').val();
	var dsextrat  = $('#dsextrat','#frmHistorico').val();
	
    var vltarayl = $('#vltarayl', '#frmHistorico').val();
    var vltarcxo = $('#vltarcxo', '#frmHistorico').val();
    var vltarint = $('#vltarint', '#frmHistorico').val();
    var vltarcsh = $('#vltarcsh', '#frmHistorico').val();

    var indebfol = $('#indebfol', '#frmHistorico').val();
    var txdoipmf = $('#txdoipmf', '#frmHistorico').val();
	
	var idmonpld = $('#idmonpld', '#frmHistorico').val();
    var inperdes = $('#inperdes', '#frmHistorico').val();
	
	// PRJ 416 
    var operauto = $('#operauto', '#frmHistorico').val();	
	
	$.ajax({		
        type: 'POST',
		dataType: 'html',
        url: UrlSite + 'telas/histor/manter_rotina.php',
        data:
				{ 
				  cddopcao : cddopcao,	
				  cdhistor : cdhistor,
				  cdhinovo : cdhinovo,
				  cdhstctb : cdhstctb,
				  dsexthst : dsexthst,
				  dshistor : dshistor,
				  inautori : inautori,
				  inavisar : inavisar,
				  inclasse : inclasse,
				  incremes : incremes,
				  indcompl : indcompl,
				  indebcta : indebcta,
				  indoipmf : indoipmf,
				  inestocc : inestocc,
				  indebprj : indebprj,
				  inhistor : inhistor,
				  indebcre : indebcre,
				  nmestrut : nmestrut,
				  nrctacrd : nrctacrd,
				  nrctatrc : nrctatrc,
				  nrctadeb : nrctadeb,
				  nrctatrd : nrctatrd,
				  tpctbccu : tpctbccu,
				  tplotmov : tplotmov,
				  tpctbcxa : tpctbcxa,
				  ingercre : ingercre,
				  ingerdeb : ingerdeb,
				  cdgrupo_historico: cdgrupo_historico,
				  flgsenha : flgsenha,
				  indutblq : indutblq,	
				  cdprodut : cdprodut,
				  cdagrupa : cdagrupa,
				  dsextrat : dsextrat,
				  vltarayl : vltarayl,
				  vltarcxo : vltarcxo,
				  vltarint : vltarint,
				  vltarcsh : vltarcsh,
				  indebfol : indebfol,
				  txdoipmf : txdoipmf,
				  inperdes : inperdes, 

				  idmonpld : idmonpld,
				  operauto : operauto,
				  redirect : 'script_ajax'
				  
				},
        error: function (objAjax, responseError, objExcept) {
					hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '');
				},
        success: function (response) {
					hideMsgAguardo();

					try {
                eval(response);
            } catch (error) {
						hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '');
					}
				}
	});
}

// Inicio PRJ 416
function mostraSenha() {

	showMsgAguardo('Aguarde, abrindo ...');

	// Executa script de confirmação através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/histor/senha.php',
		data: {
			redirect: 'html_ajax'
			},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			buscaSenha();
			return false;
		}
	});
	return false;

}

function buscaSenha() {

	hideMsgAguardo();		
		
	showMsgAguardo('Aguarde, abrindo ...');

	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/histor/form_senha.php', 
		data: {
			redirect: 'script_ajax'			
			}, 
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground();");
		},
        success: function (response) {
		
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
				try {
					$('#divConteudoSenha').html(response);
					exibeRotina($('#divRotina'));
					formataSenha();
                    $('#codsenha', '#frmSenha').unbind('keydown').bind('keydown', function (e) {
                        if (divError.css('display') == 'block') { return false; }
						// Se é a tecla ENTER, 
                        if (e.keyCode == 13) {
							validarSenha();
							return false;			
						} 
					});
					return false;
                } catch (error) {
					hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
				}
			} else {
				try {
                    eval(response);
                } catch (error) {
					hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
				}
			}
		}				
	});
	
	return false;
}

function formataSenha() {

	highlightObjFocus($('#frmSenha'));

    rOperador = $('label[for="operauto"]', '#frmSenha');
    rSenha = $('label[for="codsenha"]', '#frmSenha');
	
    rOperador.addClass('rotulo').css({ 'width': '165px' });
    rSenha.addClass('rotulo').css({ 'width': '165px' });

    cOperador = $('#operauto', '#frmSenha');
    cSenha = $('#codsenha', '#frmSenha');
	
    cOperador.addClass('campo').css({ 'width': '100px' }).attr('maxlength', '10');
    cSenha.addClass('campo').css({ 'width': '100px' }).attr('maxlength', '10');
	
    $('#divConteudoRotina').css({ 'width': '400px', 'height': '120px' });

	// centraliza a divRotina
    $('#divRotina').css({ 'width': '425px' });
    $('#divConteudoSenha').css({ 'width': '400px' });
	$('#divRotina').centralizaRotinaH();
	$('#divRotina').css({ 'top': '300px' });
	
					hideMsgAguardo();
    bloqueiaFundo($('#divRotina'));
	cOperador.focus();

	return false;
}

function validarSenha() {
		
	hideMsgAguardo();		
	
	// Situacao
    operauto = $('#operauto', '#frmSenha').val();
    var codsenha = $('#codsenha', '#frmSenha').val();
	
    showMsgAguardo('Aguarde, validando dados ...');

	$.ajax({		
        type: 'POST',
        async: true,
        url: UrlSite + 'telas/histor/valida_senha.php',
			data: {
            operauto: operauto,
            codsenha: codsenha,
            redirect: 'script_ajax'
			}, 
        error: function (objAjax, responseError, objExcept) {
				hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '');
			},
        success: function (response) {
					try {
                eval(response);
					// se não ocorreu erro, vamos gravar as alçterações
                if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                    
                    // Salvar em um campo hidden qual operador que autorizou a alteração do campo bloqueio juridico para "nao"
                	salvarOperadorAutorizou(operauto);

                    fechaRotina($('#divRotina'));

                }
					return false;
            } catch (error) {
						hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '');
					}
				}
	});
		
	return false;
}

function fecharFormSenha(){
	$('#indutblq', '#frmHistorico').val("S");
	fechaRotina($('#divRotina'));
}

function salvarOperadorAutorizou(operauto){
	$('#operauto', '#frmHistorico').val(operauto);
}
// Fim PRJ 416
/*!
 * FONTE        : parecc.js
 * CRIACAO      : Luis Fernando (Supero)
 * DATA CRIACAO : 28/01/2019
 * OBJETIVO     : Biblioteca de funcoes da tela PARECC
 * --------------
 * ALTERACOES   : 
 *
 * --------------
 */

var glb_aderidos = [];
var glb_disponiveis = [];
var glb_cdcooper = 0;

$(document).ready(function () {
    estadoInicial();
	return false;
});

/**
 * Funcao para carregar a lista de cooperativas ativas do sistema
 */
function carregarListaCooperativas() {

	showMsgAguardo("Aguarde, buscando cooperativas...");
	
	var cdcooperativa = $("#cdcooperativa", "#frmCab").val();
	var idfuncionalidade  = $('#idfuncionalidade','#frmCab').val();
	var idtipoenvio  = $('#idtipoenvio','#frmCab').val();

	//Requisicao para processar a opcao que foi selecionada
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/parecc/busca_pa_cooperativa.php",
		data: {
			cdcooperativa: cdcooperativa, // Cooperativa selecionada
			idfuncionalidade : idfuncionalidade,  // Tipo de Funcionalidade 
			idtipoenvio : idtipoenvio,  // % Tipo de Envio
			redirect: "script_ajax"
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
		},
		success: function (response) {
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

/**
 * Funcao para carregar a flag Habilitar cooperativa para envio ao endereço do cooperado
 */
function carregarFlagHabilitar() {
    
    showMsgAguardo("Aguarde, buscando parametros...");

    var cdcooperativa = $("#cdcooperativa", "#frmCab").val();
    var idfuncionalidade = $('#idfuncionalidade', '#frmCab').val();
    
    //Requisicao para processar a opcao que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/parecc/busca_flghabilitar.php",
        data: {
            cdcooperativa: cdcooperativa, // Cooperativa selecionada
            idfuncionalidade: idfuncionalidade,  // Tipo de Funcionalidade
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function (response) {
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

/**
 * Funcao para o estado inicial da tela
 * Formatacao dos campos e acoes da tela
 */
function estadoInicial() {

	$('#divTela').css({ 'display': 'inline' }).fadeTo(0, 0.1);
	$('#frmCadsoa').hide();

	// Formatar o layout da tela
	formataCabecalho();
	formataMultSelectPA();
	formataBotoes();

	removeOpacidade('divTela');
	highlightObjFocus($('#frmCab'));

	// Esconder a tela de horarios
	$('#frmParametros').css({ 'display': 'none' });

	$('#frmCab').css({ 'display': 'block' });
	$('#divTela').css({ 'width': '510px', 'padding-bottom': '2px' });

	// Adicionar o foco no campo de OPCAO 
	$("#cddopcao", "#frmCab").val("A").focus();
	$("#cdcooperativa", "#frmCab").val("0");
	$("#idfuncionalidade", "#frmCab").val("0");
	$("#idtipoenvio", "#frmCab").val("0");
	carregarFlagHabilitar();
}

/**
 * Formatacao dos campos de selecao de PA
 */
function formataMultSelectPA() {
	// Labels
	var rDsproduto  = $('label[for="dsservico"]','#frmCadsoa');
	var rDsaderido  = $('label[for="dsaderido"]','#frmCadsoa');
	
	// Arrrow btns
	var btLeft = $('#btLeft','#frmCadsoa');
	var btRigth = $('#btRigth','#frmCadsoa');

	// Multi selects
	var cDsproduto = $('#dsservico','#frmCadsoa');
	var cDsaderido = $('#dsaderido','#frmCadsoa');

	// Btns
	var btSelecioneDisponiveis = $('#btSelecioneDisponiveis','#frmCadsoa');
	var btSelecioneAderidos = $('#btSelecioneAderidos','#frmCadsoa');
	var btVoltar = $('#btVoltar','#frmCadsoa');
	var btSalvar = $('#btSalvar','#frmCadsoa');

	/*dsservico	*/	
	rDsproduto.addClass('rotulo').css('margin-left','0px');
	cDsproduto.addClass('campo').css({'width':'215px','height':'250px','float':'left','margin':'0px 0px 0px 0px'});
	btSelecioneDisponiveis.css({'margin-left': '0px'});

	/*dsaderido	*/
	rDsaderido.addClass('rotulo-linha').css('margin-left','188px');
	cDsaderido.addClass('campo').css({'width':'215px','height':'250px','float':'left','margin':'0px 0px 0px 27px'});
	btSelecioneAderidos.css({'margin-left': '205px'});

	/*Botoes*/
	btVoltar.css({'margin-left': '190px','margin-top': '25px'});
	btSalvar.css({'margin-left': '10px','margin-top': '25px'});

	btLeft.css({'margin-left': '23px','margin-top': '80px','width': '15px'});
	btRigth.css({'margin-left': '-30px','margin-top': '150px','width': '15px'});

	var removerServicos = function(){
	  $("#dsaderido").find("option:selected").each(function(){
		$("#dsservico").find("option[value=" + $(this).val() + "]").css("color","black");
		
		for (var i = 0; i < glb_aderidos.length; i++)
			if (glb_aderidos[i].cdproduto == $(this).val())
				glb_aderidos.splice(i, 1);
		
		$("#dsservico").append($(this).clone());
		$(this).remove();
	  });
	};

	btRigth.unbind('click').bind('click',function(e){
	 $("#dsservico").find("option:selected").each(function(){
			var intCentros = $("#dsaderido").find("option[value=" 	+ $(this).val() + "]").size();
			if (intCentros < 1) {
		  		$("#dsaderido").append($(this).clone());
				$(this).remove();
			}
	  });
	});
	
	$("#btLeft").click(removerServicos);

	btSelecioneDisponiveis.unbind('click').bind('click',function(e){
		 $('#dsservico option').prop('selected', true);
	});

	btSelecioneAderidos.unbind('click').bind('click',function(e){
		 $('#dsaderido option').prop('selected', true);
	});

	btVoltar.unbind('click').bind('click', function (e) {
        estadoInicial();
    });
}

/**
 * Formatacao dos campos do cabecalho
 */
function formataCabecalho() {

	glb_cdcooper = $("#hdnCooper", "#divTela").val();

	// Labels
	$('label[for="cddopcao"]', "#frmCab").addClass("rotulo").css({ "width": "40px" });
	$('label[for="cdcooperativa"]', "#frmCab").addClass("rotulo");
	$('#flghabilitar').attr('checked', true);
	// Campos
	$("#cddopcao", "#frmCab").css("width", "400px").css("float", "right").habilitaCampo();
	$("#cdcooperativa", "#frmCab").css("width", "400px").css("float", "right").habilitaCampo();
	$("#idfuncionalidade", "#frmCab").css("width", "400px").css("float", "right").habilitaCampo();
	$("#idtipoenvio", "#frmCab").css("width", "335px").css("margin-left", "24px").css("float", "right").habilitaCampo();

	$("#btnOK", "#frmCab").css("width", "45px");

	if (glb_cdcooper == 3)
		$("#flghabilitar", "#frmCab").habilitaCampo();
	else
		$("#flghabilitar", "#frmCab").desabilitaCampo();

	$('input[type="text"],select', '#frmCab').limpaFormulario().removeClass('campoErro');

	//Define acao para ENTER e TAB no campo Opcao
	$("#cddopcao", "#frmCab").unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			if (glb_cdcooper == 3)
				// Seta foco na cooperativa
				$("#cdcooper", "#frmCab").focus();
			else
				// Executar a liberacao dos campos do formulario de acordo com a opcao
				carregarParamsCoop();
			return false;
		}
	});

	//Define acao para ENTER e TAB no campo Opcao
	$("#cdcooperativa", "#frmCab").unbind('keypress').bind('keypress', function (e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Executar a liberacao dos campos do formulario de acordo com a opcao
			carregarParamsCoop();
			return false;
		}
	});

	//Define acao para CLICK no botao de OK
	$("#btnOK", "#frmCab").unbind('click').bind('click', function () {
		var idfuncionalidade  = $('#idfuncionalidade','#frmCab').val();
		var idtipoenvio  = $('#idtipoenvio','#frmCab').val();
		var cddopcao  = $('#cddopcao','#frmCab').val();
		var cdcooperativa  = $('#cdcooperativa','#frmCab').val();

		if (cdcooperativa == '' || cdcooperativa == undefined) {
			hideMsgAguardo();
			showError('error','Uma Cooperativa deve ser selecionada.','Alerta - Ayllos','');
			return false;
		}

		if (cddopcao == '' || cddopcao == undefined) {
			hideMsgAguardo();
			showError('error','Uma Opcao deve ser selecionada.','Alerta - Ayllos','');
			return false;
		}

		if (idfuncionalidade == '' || idfuncionalidade == undefined) {
			hideMsgAguardo();
			showError('error','Uma funcionalidade deve ser selecionada.','Alerta - Ayllos','');
			return false;
		}

		if (idtipoenvio == '' || idtipoenvio == undefined) {
			hideMsgAguardo();
			showError('error','Um Tipo de Envio deve ser selecionado.','Alerta - Ayllos','');
			return false;
		}

		$('#frmCadsoa').show();
		// Executar a liberacao dos campos do formulario de acordo com a opcao
		carregarCoopMultSelect();
		// Remover o click do botao, para nao executar mais de uma vez	
		$(this).unbind('click');
		return false;
	});

	layoutPadrao();
	return false;
}

/**
 * Formatacao dos botoes da tela
 */
function formataBotoes() {
	//Define acao para CLICK no bot�o de VOLTAR
	$("#btVoltar", "#frmCadsoa").unbind('click').bind('click', function () {
		// Realizar o voltar da tela de acordo com a OPCAO selionada
		voltar();
		return false;
	});

	//Define acao para CLICK no botao de Prosseguir
	$("#btSalvar", "#frmCadsoa").unbind('click').bind('click', function () {
		// Realizar a acao de prosseguir de acordo com a OPCAO selecionada
		salvar();
		return false;
	});

	layoutPadrao();

	return false;
}

/**
 * Funcao para controlar a execucao do botao VOLTAR
 */
function voltar() {
	// Validar a opcao selecionada em tela
	switch ($("#cddopcao", "#frmCab").val()) {

		case "A": // Alterar Parametros
			// Volta para o estado inicial da tela
			estadoInicial();
			break;

		default:
			estadoInicial();
	}
}

/**
 * Funcao para controlar a execucao do botao SALVAR
 */
function salvar() {

	if (divError.css('display') == 'block') { return false; }

	// Validar a opcao selecionada em tela
	switch ($("#cddopcao", "#frmCab").val()) {

		case "A": // Alterar
			// Solicitar a confirmacao para alterar os parametros
			showConfirmacao('Deseja confirmar a opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'manterRotina();', '', 'sim.gif', 'nao.gif');
			break;
	}

	return false;
}

/**
 * Funcao para carregar o componente para selecionar as cooperativas.
 */
function carregarCoopMultSelect() {

	showMsgAguardo("Aguarde, buscando parametros...");

	if ($("#cddopcao", "#frmCab").val() != "A") {
	    $('#btLeft', '#frmCadsoa').unbind('click');
	    $('#btRigth', '#frmCadsoa').unbind('click');
	    
	    $('#dsservico', '#frmCadsoa').attr("disabled", "disabled");
	    $('#dsaderido', '#frmCadsoa').attr("disabled", "disabled");

	    $('#btSelecioneDisponiveis', '#frmCadsoa').unbind('click');
	    $('#btSelecioneAderidos', '#frmCadsoa').unbind('click');

	    $('#btSalvar', '#frmCadsoa').unbind('click');
	}

	// Desabilitar a opcao
	$("#cddopcao", "#frmCab").desabilitaCampo();
	$("#cdcooperativa", "#frmCab").desabilitaCampo();
	$("#idfuncionalidade", "#frmCab").desabilitaCampo();
	$("#idtipoenvio", "#frmCab").desabilitaCampo();
	$("#btnOK","#frmCab").desabilitaCampo();
	$("#flghabilitar","#frmCab").desabilitaCampo();

	$('#dsservico').find('option').remove().end();
	$('#dsaderido').find('option').remove().end();

	var cdcooperativa = $("#cdcooperativa", "#frmCab").val();
	var idfuncionalidade  = $('#idfuncionalidade','#frmCab').val();
	var idtipoenvio  = $('#idtipoenvio','#frmCab').val();

	//Requisicao para processar a opcao que foi selecionada
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/parecc/busca_pa_cooperativa.php",
		data: {
			cdcooperativa: cdcooperativa,
			idfuncionalidade : idfuncionalidade,  // Tipo de Funcionalidade 
			idtipoenvio : idtipoenvio,  // % Tipo de Envio
			redirect: "script_ajax"
		},
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
		},
		success: function (response) {
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

function populaCampos(campo, chave, valor) {
	$("#"+campo).append('<option value='+chave+'>'+valor+'</option>');

	return false;
}

/**
 * Funcao para realizar a gravacao dos parametros
 */
function manterRotina(){
	
	showMsgAguardo('Aguarde efetuando operacao...');
	
	var cddopcao  = $('#cddopcao','#frmCab').val();
	var cdcooperativa  = $('#cdcooperativa','#frmCab').val();
	
	var flghabilitar  = $('#flghabilitar','#frmCab').is(':checked') ? 1 : 0;
	var idfuncionalidade  = $('#idfuncionalidade','#frmCab').val();
	var idtipoenvio  = $('#idtipoenvio','#frmCab').val();
	var cdcooppodenviar = [];
	$("#dsaderido option").each(function() {
		cdcooppodenviar.push($( this ).val());
	});

	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/parecc/manter_rotina.php', 
		data: {
				cddopcao : cddopcao,	// Opcao
				cdcooperativa : cdcooperativa,  // Cooperativa selecionada
				flghabilitar : flghabilitar,  // Envio ao endereço cooperado
				idfuncionalidade : idfuncionalidade,  // Tipo de Funcionalidade 
				idtipoenvio : idtipoenvio,  // % Tipo de Envio
				cdcooppodenviar: cdcooppodenviar.join(','),
				redirect : 'script_ajax'
			},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
		},
		success: function(response) { 
			hideMsgAguardo();

			try {
				eval( response );
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
			}
		}
	});
}
/*!
 * FONTE        : pargoc.js
 * CRIA��O      : Lucas Afonso
 * DATA CRIA��O : 04/10/2017
 * OBJETIVO     : Biblioteca de fun��es da tela PARGOC
 * --------------
 * ALTERA��ES   : 
 *
 * --------------
 */

var glb_cdcooper = 0; $("#hdnCooper", "#divTela").val();
 
$(document).ready(function() {
	estadoInicial();
	return false;
});

/**
 * Funcao para carregar a lista de cooperativas ativas do sistema
 */
function carregarListaCooperativas() {
	
	showMsgAguardo( "Aguarde, buscando cooperativas..." );
	
    //Requisi��o para processar a op��o que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/pargoc/buscar_cooperativas.php",
        data: {
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

/**
 * Funcao para o estado inicial da tela
 * Formatacao dos campos e acoes da tela
 */
function estadoInicial() {
	
	carregarListaCooperativas();
	$('#divTela').css({'display':'inline'}).fadeTo(0,0.1);
	
	// Formatar o layout da tela
	formataCabecalho();
	formataBotoes();

	removeOpacidade('divTela');
	highlightObjFocus( $('#frmCab') ); 
	
	// Esconder a tela de horarios
	$('#frmParametros').css({'display':'none'});
	
	// esconder os botoes da tela
	$('#divBotoes').css({'display':'none'});
	$('#frmCab').css({'display':'block'});
	$('#divTela').css({'width':'700px','padding-bottom':'2px'});
	
	// Adicionar o foco no campo de OPCAO 
	$("#cddopcao","#frmCab").val("A").focus();
	$("#cdcooper","#frmCab").val("0");
}

/**
 * Formatacao dos campos do cabecalho
 */
function formataCabecalho() {

	glb_cdcooper = $("#hdnCooper", "#divTela").val();
	
	// Labels
	$('label[for="cddopcao"]',"#frmCab").addClass("rotulo").css({"width":"40px"}); 
	$('label[for="cdcooper"]',"#frmCab").addClass("rotulo"); 
	
	// Campos
	$("#cddopcao","#frmCab").css("width","460").habilitaCampo();
	$("#cdcooper","#frmCab").css("width","427");
	
	if (glb_cdcooper == 3)
		$("#cdcooper","#frmCab").habilitaCampo();
	else
		$("#cdcooper","#frmCab").desabilitaCampo();
	
	$('input[type="text"],select','#frmCab').limpaFormulario().removeClass('campoErro');
		
	//Define a��o para ENTER e TAB no campo Op��o
	$("#cddopcao","#frmCab").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			if (glb_cdcooper == 3)
				// Seta foco na cooperativa
				$("#cdcooper","#frmCab").focus();
			else
				// Executar a liberacao dos campos do formulario de acordo com a opcao
				carregarParamsCoop();
			return false;
		}
    });	

	//Define a��o para ENTER e TAB no campo Op��o
	$("#cdcooper","#frmCab").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Executar a liberacao dos campos do formulario de acordo com a opcao
			carregarParamsCoop();
			return false;
		}
    });	
	
	//Define a��o para CLICK no bot�o de OK
	$("#btnOK","#frmCab").unbind('click').bind('click', function() {
		// Executar a liberacao dos campos do formulario de acordo com a opcao
		carregarParamsCoop();
		// Remover o click do botao, para nao executar mais de uma vez
		$(this).unbind('click');
		return false;
    });	
	
	layoutPadrao();
	
	return false;	
}

/**
 * Funcao para formatar os campos de horario da tela
 */
function formataCadastro(){
	// LABEL - PARAMETROS GERAIS
	$('label[for="inresgate_automatico"]','#frmParametros').addClass('rotulo-linha').css({'width':'250px'});
	$('label[for="qtdias_atraso_permitido"]','#frmParametros').addClass('rotulo-linha').css({'width':'250px'});
	
	// CAMPOS - PARAMETROS GERAIS
	$('#inresgate_automatico','#frmParametros').css({'margin-top':'5px'});
	
	$('#qtdias_atraso_permitido','#frmParametros').css({'width':'70px', 'text-align': 'right'}).attr('maxlength','2').setMask('INTEGER', 'zz');
	
	// LABEL - PARAMETROS PARA LINHAS GENERICAS
	$('label[for="peminimo_cobertura"]','#frmParametros').addClass('rotulo-linha').css({'width':'250px'});
	
	// CAMPOS - PARAMETROS PARA LINHAS GENERICAS
	$('#peminimo_cobertura','#frmParametros').css({'width':'70px'}).css('text-align', 'right').setMask('DECIMAL','zz9,99','.','');
	
	// Controlar o foco dos campos quando pressionar TAB ou ENTER
	controlaCamposCadastro();
	
	$('#frmParametros').css({'display':'none'});
	
	layoutPadrao();
	
	return false;	
}


/**
 * Formatacao dos botoes da tela
 */
function formataBotoes(){
	//Define a��o para CLICK no bot�o de VOLTAR
	$("#btVoltar","#divBotoes").unbind('click').bind('click', function() {
		// Realizar o voltar da tela de acordo com a OPCAO selionada
		voltar();
		return false;
    });	

	//Define a��o para CLICK no bot�o de Prosseguir
	$("#btSalvar","#divBotoes").unbind('click').bind('click', function() {
		// Realizar a acao de prosseguir de acordo com a OPCAO selecionada
		prosseguir();
		return false;
    });	

	layoutPadrao();

	return false;
}

/**
 * Funcao para controlar o foco dos campos e validar os horarios digitados
 */
function controlaCamposCadastro() {
	
	$("#inresgate_automatico","#frmParametros").focus();
	
	//Define a��o para ENTER e TAB no campo ATUALIZAR HORARIO DE PAGAMENTO SICREDI
	$("#inresgate_automatico","#frmParametros").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Setar o foco no proximo campo de atualizar
			if ($("#inresgate_automatico","#frmParametros").is(":checked"))
				$("#qtdias_atraso_permitido","#frmParametros").focus();
			else
				$("#peminimo_cobertura","#frmParametros").focus();
			return false;
		}
    });
	
	//Define a��o para ENTER e TAB no campo ATUALIZAR HORARIO DE PAGAMENTO SICREDI
	$("#qtdias_atraso_permitido","#frmParametros").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Setar o foco no proximo campo de atualizar
			$("#peminimo_cobertura","#frmParametros").focus();
			return false;
		}
    });
	
	//Define a��o para ENTER e TAB no campo HORARIO INICIAL DE PAGAMENTO SICREDI
	$("#peminimo_cobertura","#frmParametros").unbind('keydown').bind('keydown', function(e) {
		if (e.keyCode == 13) {
			prosseguir();
			return false;
		}
    });
}

/**
 * Funcao para controlar a execucao do botao VOLTAR
 */
function voltar() {
	// Validar a opcao selecionada em tela
	switch($("#cddopcao","#frmCab").val()) {
		
		case "A": // Alterar Parametros
			// Volta para o estado inicial da tela
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
    
	if ( divError.css('display') == 'block' ) { return false; }		

	// Validar a opcao selecionada em tela
	switch($("#cddopcao","#frmCab").val()) {
		
		case "A": // Alterar
			// Solicitar a confirmacao para alterar os parametros
			showConfirmacao('Deseja confirmar a opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','manterRotina();','','sim.gif','nao.gif');
		break;
		
	}

	return false;
}

/**
 * Funcao para carregar os parametros
 */
function carregarParamsCoop(){
	// Desabilitar a op��o
	$("#cddopcao","#frmCab").desabilitaCampo();
	$("#cdcooper","#frmCab").desabilitaCampo();
	
	var cddopcao = $("#cddopcao","#frmCab").val();
	var cdcooper = $("#cdcooper","#frmCab").val();
	
	showMsgAguardo( "Aguarde, buscando parametros..." );
	
    //Requisi��o para processar a op��o que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/pargoc/busca_dados.php",
        data: {
            cddopcao: cddopcao,
			cdcooper: cdcooper,
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

/**
 * Funcao para realizar a gravacao dos parametros
 */
function manterRotina(){
	
	//showMsgAguardo('Aguarde efetuando operacao...');
	
	var cddopcao  = $('#cddopcao','#frmCab').val();
	var cdcooper  = $('#cdcooper','#frmCab').val();
	
	var inresgate_automatico  = $('#inresgate_automatico','#frmParametros').is(':checked') ? 1 : 0;
	var qtdias_atraso_permitido  = $('#qtdias_atraso_permitido','#frmParametros').val();
	var peminimo_cobertura  = $('#peminimo_cobertura','#frmParametros').val();
	
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/pargoc/manter_rotina.php', 
		data:
			{ 
				cddopcao : cddopcao,	// Opcao
				cdcooper : cdcooper,  // Cooperativa selecionada
				inresgate_automatico : inresgate_automatico,  // Resgate Autom�tico
				qtdias_atraso_permitido : qtdias_atraso_permitido,  // Dias de atraso p/ resgate autom�tico
				peminimo_cobertura : peminimo_cobertura.replace(',','.'),  // % M�n Cobertura p/ Garantia
				redirect : 'script_ajax'
			},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N�o foi poss�vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
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

/**
 * Funcao para liberar os campos "Atualizar" da tela de Horarios
 */
function populaCampos(inresgate_automatico, qtdias_atraso_permitido, peminimo_cobertura){
	
	formataCadastro();
	// Limpar formul�rio
	$('input[type="text"],select','#frmParametros').limpaFormulario().desabilitaCampo().removeClass('campoErro');
	
	$('#inresgate_automatico','#frmParametros').habilitaCampo();
	
	if (inresgate_automatico === 1) {
		$("#inresgate_automatico","#frmParametros").attr("checked","true");
		$("#qtdias_atraso_permitido","#frmParametros").habilitaCampo();
	} else {
		$("#inresgate_automatico","#frmParametros").removeAttr('checked');
		$("#qtdias_atraso_permitido","#frmParametros").desabilitaCampo();
	}
	
	$("#qtdias_atraso_permitido","#frmParametros").val(qtdias_atraso_permitido);
	$("#peminimo_cobertura","#frmParametros").val(peminimo_cobertura).habilitaCampo();
	
	if ($('#cddopcao','#frmCab').val() == "C") {
		$('#inresgate_automatico','#frmParametros').attr("disabled","true");
		$('input[type="text"],select','#frmParametros').desabilitaCampo();
	}
	
	// Mostrar a tela
	$('#frmParametros').css({'display':'block'});
	
	$('#divBotoes').css({'display':'block','padding-bottom':'15px'});
	$('#btVoltar','#divBotoes').css({'display':'inline'});
	$('#btSalvar','#divBotoes').css({'display':'inline'});
	
	return false;
}

/**
 * Funcao para habilitar ou desabilitar o campo "Dias de atraso p/ resgate autom�tico"
 */
function verificaCampoQtDias(checkbox){
	
	if (checkbox.checked)
		$("#qtdias_atraso_permitido","#frmParametros").val(0).habilitaCampo();
	else
		$("#qtdias_atraso_permitido","#frmParametros").val(0).desabilitaCampo();
	
	return false;
}

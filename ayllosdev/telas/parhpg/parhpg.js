/*!
 * FONTE        : parhpg.js
 * CRIAÇÃO      : Douglas Quisinski
 * DATA CRIAÇÃO : 15/04/2016
 * OBJETIVO     : Biblioteca de funções da tela PARHPG
 * --------------
 * ALTERAÇÕES   : 19/06/2017 - Removida a linha com informações da Devolução VLB.
				               PRJ367 - Compe Sessao Unica (Lombardi)

                  08/03/2018 - #PRJ367 Aumentadas as larguras dos labels "devolução diurna" e "devolução fraude/imp" (Carlos)
 * --------------
 */

$(document).ready(function() {
	carregarListaCooperativas();
	estadoInicial();
	return false;
});

/**
 * Funcao para carregar a lista de cooperativas ativas do sistema
 */
function carregarListaCooperativas() {
	
	showMsgAguardo( "Aguarde, buscando cooperativas..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/parhpg/buscar_cooperativas.php",
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
	
	$('#divTela').css({'display':'inline'}).fadeTo(0,0.1);
	
	// Formatar o layout da tela
	formataCabecalho();
	formataCadastro();
	formataBotoes();

	removeOpacidade('divTela');
	highlightObjFocus( $('#frmCab') ); 
	
	// Esconder a tela de horarios
	$('#frmHorarios').css({'display':'none'});
	
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

	// Labels
	$('label[for="cddopcao"]',"#frmCab").addClass("rotulo").css({"width":"80px"}); 
	$('label[for="cdcooper"]',"#frmCab").addClass("rotulo").css({"width":"80px"}); 
	
	// Campos
	$("#cddopcao","#frmCab").css("width","450px").habilitaCampo();
	$("#cdcooper","#frmCab").css("width","450px").habilitaCampo();
	
	$('input[type="text"],select','#frmCab').limpaFormulario().removeClass('campoErro');
	
	//Define ação para ENTER e TAB no campo Opção
	$("#cddopcao","#frmCab").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Seta foco na cooperativa
			$("#cdcooper","#frmCab").focus();
			return false;
		}
    });	

	//Define ação para ENTER e TAB no campo Opção
	$("#cdcooper","#frmCab").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Executar a liberacao dos campos do formulario de acordo com a opcao
			liberaFormulario();
			return false;
		}
    });	
	
	//Define ação para CLICK no botão de OK
	$("#btnOK","#frmCab").unbind('click').bind('click', function() {
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
 * Funcao para formatar os campos de horario da tela
 */
function formataCadastro(){
	// LABEL - HORARIO DE PAGAMENTO
	$('label[for="hrsicred"]','#frmHorarios').addClass('rotulo').css({'width':'130px'});
	$('label[for="hrsicini"]','#frmHorarios').addClass('rotulo-linha').css({'width':'50px'});
	$('label[for="hrsicfim"]','#frmHorarios').addClass('rotulo-linha').css({'width':'30px'});
	$('label[for="hrtitulo"]','#frmHorarios').addClass('rotulo').css({'width':'130px'});
	$('label[for="hrtitini"]','#frmHorarios').addClass('rotulo-linha').css({'width':'50px'});
	$('label[for="hrtitfim"]','#frmHorarios').addClass('rotulo-linha').css({'width':'30px'});
	$('label[for="hrnetmob"]','#frmHorarios').addClass('rotulo').css({'width':'130px'});
	$('label[for="hrnetini"]','#frmHorarios').addClass('rotulo-linha').css({'width':'50px'});
	$('label[for="hrnetfim"]','#frmHorarios').addClass('rotulo-linha').css({'width':'30px'});
	$('label[for="hrpagtaa"]','#frmHorarios').addClass('rotulo').css({'width':'130px'});
	$('label[for="hrtaaini"]','#frmHorarios').addClass('rotulo-linha').css({'width':'50px'});
	$('label[for="hrtaafim"]','#frmHorarios').addClass('rotulo-linha').css({'width':'30px'});
	$('label[for="hrpaggps"]','#frmHorarios').addClass('rotulo').css({'width':'130px'});
	$('label[for="hrgpsini"]','#frmHorarios').addClass('rotulo-linha').css({'width':'50px'});
	$('label[for="hrgpsfim"]','#frmHorarios').addClass('rotulo-linha').css({'width':'30px'});
	
	// CAMPOS - HORARIO DE PAGAMENTO 
	// Atualizar Hora SICREDI
	$('#hrsicatu','#frmHorarios').css({'width':'120px'});
	// Horario Inicio Pagamento SICREDI
	$('#hrsicini','#frmHorarios').css({'width':'70px'}).attr('maxlength','5');
	$('#hrsicini','#frmHorarios').mask('00:00');
	$('#hrsicini','#frmHorarios').setMask('STRING','99:99',':','');
	// Horario Fim Pagamento SICREDI
	$('#hrsicfim','#frmHorarios').css({'width':'70px'}).attr('maxlength','5');
	$('#hrsicfim','#frmHorarios').mask('00:00');
	$('#hrsicfim','#frmHorarios').setMask('STRING','99:99',':','');

	// Atualizar Hora Titulos/Faturas
	$('#hrtitatu','#frmHorarios').css({'width':'120px'});
	// Horario Inicio Pagamento Titulo/Faturas
	$('#hrtitini','#frmHorarios').css({'width':'70px'}).attr('maxlength','5');
	$('#hrtitini','#frmHorarios').mask('00:00');
	$('#hrtitini','#frmHorarios').setMask('STRING','99:99',':','');
	// Horario Fim Paragamento Titulo/Faturas
	$('#hrtitfim','#frmHorarios').css({'width':'70px'}).attr('maxlength','5');
	$('#hrtitfim','#frmHorarios').mask('00:00');
	$('#hrtitfim','#frmHorarios').setMask('STRING','99:99',':','');
	
	// Atualizar Hora Internet/Mobile
	$('#hrnetatu','#frmHorarios').css({'width':'120px'});
	// Horario Inicio Internet/Mobile
	$('#hrnetini','#frmHorarios').css({'width':'70px'}).attr('maxlength','5');
	$('#hrnetini','#frmHorarios').mask('00:00');
	$('#hrnetini','#frmHorarios').setMask('STRING','99:99',':','');
	// Horario Fim Internet/Mobile
	$('#hrnetfim','#frmHorarios').css({'width':'70px'}).attr('maxlength','5');
	$('#hrnetfim','#frmHorarios').mask('00:00');
	$('#hrnetfim','#frmHorarios').setMask('STRING','99:99',':','');
	
	// Atualizar Hora TAA
	$('#hrtaaatu','#frmHorarios').css({'width':'120px'});
	// Horario Inicio TAA
	$('#hrtaaini','#frmHorarios').css({'width':'70px'}).attr('maxlength','5');
	$('#hrtaaini','#frmHorarios').mask('00:00');
	$('#hrtaaini','#frmHorarios').setMask('STRING','99:99',':','');
	// Hora Fim TAA
	$('#hrtaafim','#frmHorarios').css({'width':'70px'}).attr('maxlength','5');
	$('#hrtaafim','#frmHorarios').mask('00:00');
	$('#hrtaafim','#frmHorarios').setMask('STRING','99:99',':','');

	// Atualizar Hora GPS
	$('#hrgpsatu','#frmHorarios').css({'width':'120px'});
	// Horario de Inicio GPS
	$('#hrgpsini','#frmHorarios').css({'width':'70px'}).attr('maxlength','5');
	$('#hrgpsini','#frmHorarios').mask('00:00');
	$('#hrgpsini','#frmHorarios').setMask('STRING','99:99',':','');
	// Horario Fim GPS
	$('#hrgpsfim','#frmHorarios').css({'width':'70px'}).attr('maxlength','5');
	$('#hrgpsfim','#frmHorarios').mask('00:00');
	$('#hrgpsfim','#frmHorarios').setMask('STRING','99:99',':','');

	
	// LABEL - HORARIO DE ESTORNO DE PAGAMENTO
	$('label[for="hrsiccan"]','#frmHorarios').addClass('rotulo').css({'width':'130px'});
	$('label[for="hrsiclim"]','#frmHorarios').addClass('rotulo-linha').css({'width':'50px'});
	$('label[for="hrtitcan"]','#frmHorarios').addClass('rotulo').css({'width':'130px'});
	$('label[for="hrtitlim"]','#frmHorarios').addClass('rotulo-linha').css({'width':'50px'});
	$('label[for="hrnetcan"]','#frmHorarios').addClass('rotulo').css({'width':'130px'});
	$('label[for="hrnetlim"]','#frmHorarios').addClass('rotulo-linha').css({'width':'50px'});
	$('label[for="hrtaacan"]','#frmHorarios').addClass('rotulo').css({'width':'130px'});
	$('label[for="hrtaalim"]','#frmHorarios').addClass('rotulo-linha').css({'width':'50px'});

	// CAMPOS - HORARIO DE ESTORNO DE PAGAMENTO
	// Atualizar Hora Cancelamento SICREDI
	$('#hrsiccau','#frmHorarios').css({'width':'120px'});
	// Horario de Cancelamento SICREDI
	$('#hrsiccan','#frmHorarios').css({'width':'70px'}).attr('maxlength','5');
	$('#hrsiccan','#frmHorarios').mask('00:00');
	$('#hrsiccan','#frmHorarios').setMask('STRING','99:99',':','');
	
	// Atualizar Hora Cancelamento Titulo/Faturas
	$('#hrtitcau','#frmHorarios').css({'width':'120px'});
	// Horario de Cancelamento Titulo/Faturas
	$('#hrtitcan','#frmHorarios').css({'width':'70px'}).attr('maxlength','5');
	$('#hrtitcan','#frmHorarios').mask('00:00');
	$('#hrtitcan','#frmHorarios').setMask('STRING','99:99',':','');
	
	// Atualizar Hora Cancelamento Internet/Mobile
	$('#hrnetcau','#frmHorarios').css({'width':'120px'});
	// Horario de Cancelamento Internet/Mobile
	$('#hrnetcan','#frmHorarios').css({'width':'70px'}).attr('maxlength','5');
	$('#hrnetcan','#frmHorarios').mask('00:00');
	$('#hrnetcan','#frmHorarios').setMask('STRING','99:99',':','');
	
	// Atualizar Hora Cancelamento TAA
	$('#hrtaacau','#frmHorarios').css({'width':'120px'});
	// Horario de Cancelamento TAA
	$('#hrtaacan','#frmHorarios').css({'width':'70px'}).attr('maxlength','5');
	$('#hrtaacan','#frmHorarios').mask('00:00');
	$('#hrtaacan','#frmHorarios').setMask('STRING','99:99',':','');

	// LABEL - DEVOLUCAO DE CHEQUE
	$('label[for="hrdevdiu"]','#frmHorarios').addClass('rotulo').css({'width':'140px'});
	$('label[for="hrdiuini"]','#frmHorarios').addClass('rotulo-linha').css({'width':'50px'});
	$('label[for="hrdiufim"]','#frmHorarios').addClass('rotulo-linha').css({'width':'30px'});
	$('label[for="hrdevnot"]','#frmHorarios').addClass('rotulo').css({'width':'140px'});
	$('label[for="hrnotini"]','#frmHorarios').addClass('rotulo-linha').css({'width':'50px'});
	$('label[for="hrnotfim"]','#frmHorarios').addClass('rotulo-linha').css({'width':'30px'});
	
	// CAMPOS - DEVOLUCAO DE CHEQUE
	
	// Atualizar Devolucao Diurna
	$('#hrdiuatu','#frmHorarios').css({'width':'120px'});
	// Horario Inicio Devolucao Diurna
	$('#hrdiuini','#frmHorarios').css({'width':'70px'}).attr('maxlength','5');
	$('#hrdiuini','#frmHorarios').mask('00:00');
	$('#hrdiuini','#frmHorarios').setMask('STRING','99:99',':','');
	// Horario Fim Devolucao Diurna
	$('#hrdiufim','#frmHorarios').css({'width':'70px'}).attr('maxlength','5');
	$('#hrdiufim','#frmHorarios').mask('00:00');
	$('#hrdiufim','#frmHorarios').setMask('STRING','99:99',':','');
	
	// Atualizar Devolucao Noturna
	$('#hrnotatu','#frmHorarios').css({'width':'120px'});
	// Horario Inicio Devolucao Noturna
	$('#hrnotini','#frmHorarios').css({'width':'70px'}).attr('maxlength','5');
	$('#hrnotini','#frmHorarios').mask('00:00');
	$('#hrnotini','#frmHorarios').setMask('STRING','99:99',':','');
	// Horario Fim Devolucao Noturna
	$('#hrnotfim','#frmHorarios').css({'width':'70px'}).attr('maxlength','5');
	$('#hrnotfim','#frmHorarios').mask('00:00');
	$('#hrnotfim','#frmHorarios').setMask('STRING','99:99',':','');
	
	$('input[type="text"],select','#frmHorarios').desabilitaCampo().limpaFormulario().removeClass('campoErro');
	
	// Controlar o foco dos campos quando pressionar TAB ou ENTER
	controlaCamposCadastro();
	
	$('#frmHorarios').css({'display':'none'});
	
	layoutPadrao();
	
	return false;	
}


/**
 * Formatacao dos botoes da tela
 */
function formataBotoes(){
	//Define ação para CLICK no botão de VOLTAR
	$("#btVoltar","#divBotoes").unbind('click').bind('click', function() {
		// Realizar o voltar da tela de acordo com a OPCAO selionada
		voltar();
		return false;
    });	

	//Define ação para CLICK no botão de Prosseguir
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
	
	//Define ação para ENTER e TAB no campo ATUALIZAR HORARIO DE PAGAMENTO SICREDI
	$("#hrsicatu","#frmHorarios").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			if ( $(this).val() == "S" ){
				// Habilitar os campos de horario Inicial e Final de pagamento do SICREDI
				$("#hrsicini","#frmHorarios").habilitaCampo().focus();
				$("#hrsicfim","#frmHorarios").habilitaCampo();
			} else {
				// Desabilitar os campos de horario Inicial e Final de pagamento do SICREDI
				$("#hrsicini","#frmHorarios").desabilitaCampo();
				$("#hrsicfim","#frmHorarios").desabilitaCampo();
				// Setar o foco no proximo campo de atualizar
				$("#hrtitatu","#frmHorarios").focus();
			}
			return false;
		}
    });
	
	//Define ação para ENTER e TAB no campo HORARIO INICIAL DE PAGAMENTO SICREDI
	$("#hrsicini","#frmHorarios").unbind('keydown').bind('keydown', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Horario Invalido
			if ( !validaHorarioDigitado($(this).val()) ) {
				showError("error","Hora de in&iacute;cio do pagamento SICREDI inv&aacute;lida.","Alerta - Ayllos","focaCampoErro(\'hrsicini\', \'frmHorarios\');",false);
			
			// Sem erros
			} else {
				$(this).removeClass('campoErro');
				$("#hrsicfim","#frmHorarios").focus();
			}
			return false;
		}
    });

	//Define ação para ENTER e TAB no campo HORARIO FINAL DE PAGAMENTO SICREDI
	$("#hrsicfim","#frmHorarios").unbind('keydown').bind('keydown', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Horario Invalido
			if ( !validaHorarioDigitado($(this).val()) ) {
				showError("error","Hora de fim do pagamento SICREDI inv&aacute;lida.","Alerta - Ayllos","focaCampoErro(\'hrsicfim\', \'frmHorarios\');",false);
			
			// Hora Inicial Maior que Hora Final
			} else if( compararHora($("#hrsicini","#frmHorarios").val(), $(this).val()) ){
				showError("error","Hora de fim do pagamento SICREDI n&atilde;o pode ser menor que a hora de in&iacute;cio.","Alerta - Ayllos","focaCampoErro(\'hrsicfim\', \'frmHorarios\');",false);
	
			// Sem erros 
			} else {
				$(this).removeClass('campoErro');
				$("#hrtitatu","#frmHorarios").focus();
			}
			return false;
		}
    });
	
	//Define ação para ENTER e TAB no campo ATUALIZAR HORARIO DE PAGAMENTO TITULOS/FATURAS
	$("#hrtitatu","#frmHorarios").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			if ( $(this).val() == "S" ){
				// Habilitar os campos de horario Inicial e Final de pagamento do TITULOS/FATURAS
				$("#hrtitini","#frmHorarios").habilitaCampo().focus();
				$("#hrtitfim","#frmHorarios").habilitaCampo();
			} else {
				// Desabilitar os campos de horario Inicial e Final de pagamento do TITULOS/FATURAS
				$("#hrtitini","#frmHorarios").desabilitaCampo();
				$("#hrtitfim","#frmHorarios").desabilitaCampo();
				// Setar o foco no proximo campo de atualizar
				$("#hrnetatu","#frmHorarios").focus();
			}
			return false;
		}
    });
	
	//Define ação para ENTER e TAB no campo HORARIO INICIAL DE PAGAMENTO TITULOS/FATURAS
	$("#hrtitini","#frmHorarios").unbind('keydown').bind('keydown', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Horario Invalido
			if ( !validaHorarioDigitado($(this).val()) ) {
				showError("error","Hora de in&iacute;cio do pagamento TITULOS/FATURAS inv&aacute;lida.","Alerta - Ayllos","focaCampoErro(\'hrtitini\', \'frmHorarios\');",false);
			
			// Sem erros
			} else {
				$(this).removeClass('campoErro');
				$("#hrtitfim","#frmHorarios").focus();
			}
			return false;
		}
    });

	//Define ação para ENTER e TAB no campo HORARIO FINAL DE PAGAMENTO TITULOS/FATURAS
	$("#hrtitfim","#frmHorarios").unbind('keydown').bind('keydown', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Horario Invalido
			if ( !validaHorarioDigitado($(this).val()) ) {
				showError("error","Hora de fim do pagamento TITULOS/FATURAS inv&aacute;lida.","Alerta - Ayllos","focaCampoErro(\'hrtitfim\', \'frmHorarios\');",false);

			// Hora Inicial Maior que Hora Final
			} else if( compararHora($("#hrtitini","#frmHorarios").val(), $(this).val()) ){
				showError("error","Hora de fim do pagamento TITULOS/FATURAS n&atilde;o pode ser menor que a hora de in&iacute;cio.","Alerta - Ayllos","focaCampoErro(\'hrtitfim\', \'frmHorarios\');",false);

			// Sem erros
			} else {
				$(this).removeClass('campoErro');
				$("#hrnetatu","#frmHorarios").focus();
			}
			return false;
		}
    });
	
	//Define ação para ENTER e TAB no campo ATUALIZAR HORARIO DE PAGAMENTO INTERNET/MOBILE
	$("#hrnetatu","#frmHorarios").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			if ( $(this).val() == "S" ){
				// Habilitar os campos de horario Inicial e Final de pagamento do INTERNET/MOBILE
				$("#hrnetini","#frmHorarios").habilitaCampo().focus();
				$("#hrnetfim","#frmHorarios").habilitaCampo();
			} else {
				// Desabilitar os campos de horario Inicial e Final de pagamento do INTERNET/MOBILE
				$("#hrnetini","#frmHorarios").desabilitaCampo();
				$("#hrnetfim","#frmHorarios").desabilitaCampo();
				// Setar o foco no proximo campo de atualizar
				$("#hrtaaatu","#frmHorarios").focus();
			}
			return false;
		}
    });
	
	//Define ação para ENTER e TAB no campo HORARIO INICIAL DE PAGAMENTO INTERNET/MOBILE
	$("#hrnetini","#frmHorarios").unbind('keydown').bind('keydown', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Horario Invalido
			if ( !validaHorarioDigitado($(this).val()) ) {
				showError("error","Hora de in&iacute;cio do pagamento INTERNET/MOBILE inv&aacute;lida.","Alerta - Ayllos","focaCampoErro(\'hrnetini\', \'frmHorarios\');",false);
			
			// Sem erros
			} else {
				$(this).removeClass('campoErro');
				$("#hrnetfim","#frmHorarios").focus();
			}
			return false;
		}
    });

	//Define ação para ENTER e TAB no campo HORARIO FINAL DE PAGAMENTO INTERNET/MOBILE
	$("#hrnetfim","#frmHorarios").unbind('keydown').bind('keydown', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Horario Invalido
			if ( !validaHorarioDigitado($(this).val()) ) {
				showError("error","Hora de fim do pagamento INTERNET/MOBILE inv&aacute;lida.","Alerta - Ayllos","focaCampoErro(\'hrnetfim\', \'frmHorarios\');",false);

			// Hora Inicial Maior que Hora Final
			} else if( compararHora($("#hrnetini","#frmHorarios").val(), $(this).val()) ){
				showError("error","Hora de fim do pagamento INTERNET/MOBILE n&atilde;o pode ser menor que a hora de in&iacute;cio.","Alerta - Ayllos","focaCampoErro(\'hrnetfim\', \'frmHorarios\');",false);

			// Sem erros
			} else {
				$(this).removeClass('campoErro');
				$("#hrtaaatu","#frmHorarios").focus();
			}
			return false;
		}
    });
	
	//Define ação para ENTER e TAB no campo ATUALIZAR HORARIO DE PAGAMENTO TAA
	$("#hrtaaatu","#frmHorarios").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			if ( $(this).val() == "S" ){
				// Habilitar os campos de horario Inicial e Final de pagamento do TAA
				$("#hrtaaini","#frmHorarios").habilitaCampo().focus();
				$("#hrtaafim","#frmHorarios").habilitaCampo();
			} else {
				// Desabilitar os campos de horario Inicial e Final de pagamento do TAA
				$("#hrtaaini","#frmHorarios").desabilitaCampo();
				$("#hrtaafim","#frmHorarios").desabilitaCampo();
				// Setar o foco no proximo campo de atualizar
				$("#hrgpsatu","#frmHorarios").focus();
			}
			return false;
		}
    });
	
	//Define ação para ENTER e TAB no campo HORARIO INICIAL DE PAGAMENTO TAA
	$("#hrtaaini","#frmHorarios").unbind('keydown').bind('keydown', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Horario Invalido
			if ( !validaHorarioDigitado($(this).val()) ) {
				showError("error","Hora de in&iacute;cio do pagamento TAA inv&aacute;lida.","Alerta - Ayllos","focaCampoErro(\'hrtaaini\', \'frmHorarios\');",false);

			// Sem erros
			} else {
				$(this).removeClass('campoErro');
				$("#hrtaafim","#frmHorarios").focus();
			}
			return false;
		}
    });

	//Define ação para ENTER e TAB no campo HORARIO FINAL DE PAGAMENTO TAA
	$("#hrtaafim","#frmHorarios").unbind('keydown').bind('keydown', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Horario Invalido
			if ( !validaHorarioDigitado($(this).val()) ) {
				showError("error","Hora de fim do pagamento TAA inv&aacute;lida.","Alerta - Ayllos","focaCampoErro(\'hrtaafim\', \'frmHorarios\');",false);

			// Hora Inicial Maior que Hora Final
			} else if( compararHora($("#hrtaaini","#frmHorarios").val(), $(this).val()) ){
				showError("error","Hora de fim do pagamento TAA n&atilde;o pode ser menor que a hora de in&iacute;cio.","Alerta - Ayllos","focaCampoErro(\'hrtaafim\', \'frmHorarios\');",false);

			// Sem erros
			} else {
				$(this).removeClass('campoErro');
				$("#hrgpsatu","#frmHorarios").focus();
			}
			return false;
		}
    });
	
	//Define ação para ENTER e TAB no campo ATUALIZAR HORARIO DE PAGAMENTO GPS
	$("#hrgpsatu","#frmHorarios").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			if ( $(this).val() == "S" ){
				// Habilitar os campos de horario Inicial e Final de pagamento do GPS
				$("#hrgpsini","#frmHorarios").habilitaCampo().focus();
				$("#hrgpsfim","#frmHorarios").habilitaCampo();
			} else {
				// Desabilitar os campos de horario Inicial e Final de pagamento do GPS
				$("#hrgpsini","#frmHorarios").desabilitaCampo();
				$("#hrgpsfim","#frmHorarios").desabilitaCampo();
				// Setar o foco no proximo campo de atualizar
				$("#hrsiccau","#frmHorarios").focus();
			}
			return false;
		}
    });
	
	//Define ação para ENTER e TAB no campo HORARIO INICIAL DE PAGAMENTO GPS
	$("#hrgpsini","#frmHorarios").unbind('keydown').bind('keydown', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Horario Invalido
			if ( !validaHorarioDigitado($(this).val()) ) {
				showError("error","Hora de in&iacute;cio do pagamento GPS inv&aacute;lida.","Alerta - Ayllos","focaCampoErro(\'hrgpsini\', \'frmHorarios\');",false);
			
			// Sem erros
			} else {
				$(this).removeClass('campoErro');
				$("#hrgpsfim","#frmHorarios").focus();
			}
			return false;
		}
    });

	//Define ação para ENTER e TAB no campo HORARIO FINAL DE PAGAMENTO GPS
	$("#hrgpsfim","#frmHorarios").unbind('keydown').bind('keydown', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Horario Invalido
			if ( !validaHorarioDigitado($(this).val()) ) {
				showError("error","Hora de fim do pagamento GPS inv&aacute;lida.","Alerta - Ayllos","focaCampoErro(\'hrgpsfim\', \'frmHorarios\');",false);

			// Hora Inicial Maior que Hora Final
			} else if( compararHora($("#hrgpsini","#frmHorarios").val(), $(this).val()) ){
				showError("error","Hora de fim do pagamento GPS n&atilde;o pode ser menor que a hora de in&iacute;cio.","Alerta - Ayllos","focaCampoErro(\'hrgpsfim\', \'frmHorarios\');",false);

			// Sem erros
			} else {
				$(this).removeClass('campoErro');
				$("#hrsiccau","#frmHorarios").focus();
			}
			return false;
		}
    });

	//Define ação para ENTER e TAB no campo ATUALIZAR HORARIO DE CANCELAMENTO PAGAMENTO SICREDI
	$("#hrsiccau","#frmHorarios").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			if ( $(this).val() == "S" ){
				// Habilitar os campos de horario Inicial e Final de Cancelamento de Pagamento SICREDI
				$("#hrsiccan","#frmHorarios").habilitaCampo().focus();
			} else {
				// Desabilitar os campos de horario Inicial e Final de Cancelamento de Pagamento SICREDI
				$("#hrsiccan","#frmHorarios").desabilitaCampo();
				// Setar o foco no proximo campo de atualizar
				$("#hrtitcau","#frmHorarios").focus();
			}
			return false;
		}
    });
	
	//Define ação para ENTER e TAB no campo HORARIO INICIAL DE CANCELAMENTO PAGAMENTO SICREDI
	$("#hrsiccan","#frmHorarios").unbind('keydown').bind('keydown', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Horario Invalido
			if ( !validaHorarioDigitado($(this).val()) ) {
				showError("error","Hora de cancelamento do pagamento SICREDI inv&aacute;lida.","Alerta - Ayllos","focaCampoErro(\'hrsiccan\', \'frmHorarios\');",false);

			// Sem erros
			} else {
				$(this).removeClass('campoErro');
				$("#hrtitcau","#frmHorarios").focus();
			}
			return false;
		}
    });
	
	//Define ação para ENTER e TAB no campo ATUALIZAR HORARIO DE CANCELAMENTO PAGAMENTO TITULOS/FATURAS
	$("#hrtitcau","#frmHorarios").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			if ( $(this).val() == "S" ){
				// Habilitar os campos de horario Inicial e Final de Cancelamento de Pagamento TITULOS/FATURAS
				$("#hrtitcan","#frmHorarios").habilitaCampo().focus();
			} else {
				// Desabilitar os campos de horario Inicial e Final de Cancelamento de Pagamento TITULOS/FATURAS
				$("#hrtitcan","#frmHorarios").desabilitaCampo();
				// Setar o foco no proximo campo de atualizar
				$("#hrnetcau","#frmHorarios").focus();
			}
			return false;
		}
    });
	
	//Define ação para ENTER e TAB no campo HORARIO INICIAL DE CANCELAMENTO PAGAMENTO TITULOS/FATURAS
	$("#hrtitcan","#frmHorarios").unbind('keydown').bind('keydown', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Horario Invalido
			if ( !validaHorarioDigitado($(this).val()) ) {
				showError("error","Hora de cancelamento do pagamento TITULOS/FATURAS inv&aacute;lida.","Alerta - Ayllos","focaCampoErro(\'hrtitcan\', \'frmHorarios\');",false);

			// Sem erros
			} else {
				$(this).removeClass('campoErro');
				$("#hrnetcau","#frmHorarios").focus();
			}
			return false;
		}
    });
	
	//Define ação para ENTER e TAB no campo ATUALIZAR HORARIO DE CANCELAMENTO PAGAMENTO INTERNET/MOBILE
	$("#hrnetcau","#frmHorarios").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			if ( $(this).val() == "S" ){
				// Habilitar os campos de horario Inicial e Final de Cancelamento de Pagamento INTERNET/MOBILE
				$("#hrnetcan","#frmHorarios").habilitaCampo().focus();
			} else {
				// Desabilitar os campos de horario Inicial e Final de Cancelamento de Pagamento INTERNET/MOBILE
				$("#hrnetcan","#frmHorarios").desabilitaCampo();
				// Setar o foco no proximo campo de atualizar
				$("#hrtaacau","#frmHorarios").focus();
			}
			return false;
		}
    });

	//Define ação para ENTER e TAB no campo HORARIO DE CANCELAMENTO PAGAMENTO INTERNET/MOBILE
	$("#hrnetcan","#frmHorarios").unbind('keydown').bind('keydown', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Horario Invalido
			if ( !validaHorarioDigitado($(this).val()) ) {
				showError("error","Hora de cancelamento do pagamento INTERNET/MOBILE inv&aacute;lida.","Alerta - Ayllos","focaCampoErro(\'hrnetcan\', \'frmHorarios\');",false);

			// Sem erros
			} else {
				$(this).removeClass('campoErro');
				$("#hrtaacau","#frmHorarios").focus();
			}
			return false;
		}
    });

	//Define ação para ENTER e TAB no campo ATUALIZAR HORARIO DE CANCELAMENTO PAGAMENTO TAA
	$("#hrtaacau","#frmHorarios").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			if ( $(this).val() == "S" ){
				// Habilitar os campos de horario Inicial e Final de Cancelamento de Pagamento TAA
				$("#hrtaacan","#frmHorarios").habilitaCampo().focus();
			} else {
				// Desabilitar os campos de horario Inicial e Final de Cancelamento de Pagamento TAA
				$("#hrtaacan","#frmHorarios").desabilitaCampo();
				// Setar o foco no proximo campo de atualizar
				$("#hrdiuatu","#frmHorarios").focus();
			}
			return false;
		}
    });
	
	//Define ação para ENTER e TAB no campo HORARIO DE CANCELAMENTO PAGAMENTO TAA
	$("#hrtaacan","#frmHorarios").unbind('keydown').bind('keydown', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Horario Invalido
			if ( !validaHorarioDigitado($(this).val()) ) {
				showError("error","Hora de cancelamento do pagamento TAA inv&aacute;lida.","Alerta - Ayllos","focaCampoErro(\'hrtaacan\', \'frmHorarios\');",false);
				
			// Sem erros
			} else {
				$(this).removeClass('campoErro');
				$("#hrdiuatu","#frmHorarios").focus();
			}
			return false;
		}
    });
	
	//Define ação para ENTER e TAB no campo ATUALIZAR HORARIO DE DEVOLUCAO DIURNA
	$("#hrdiuatu","#frmHorarios").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			if ( $(this).val() == "S" ){
				// Habilitar os campos de horario Inicial e Final de DEVOLUCAO DIURNA
				$("#hrdiuini","#frmHorarios").habilitaCampo().focus();
				$("#hrdiufim","#frmHorarios").habilitaCampo();
			} else {
				// Desabilitar os campos de horario Inicial e Final de DEVOLUCAO DIURNA
				$("#hrdiuini","#frmHorarios").desabilitaCampo();
				$("#hrdiufim","#frmHorarios").desabilitaCampo();
				// Setar o foco no proximo campo de atualizar
				$("#hrnotatu","#frmHorarios").focus();
			}
			return false;
		}
    });
	
	//Define ação para ENTER e TAB no campo HORARIO INICIAL DE DEVOLUCAO DIURNA
	$("#hrdiuini","#frmHorarios").unbind('keydown').bind('keydown', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Horario Invalido
			if ( !validaHorarioDigitado($(this).val()) ) {
				showError("error","Hora de in&iacute;cio da DEVOLUCAO DIURNA inv&aacute;lida.","Alerta - Ayllos","focaCampoErro(\'hrdiuini\', \'frmHorarios\');",false);

			// Sem erros
			} else {
				$(this).removeClass('campoErro');
				$("#hrdiufim","#frmHorarios").focus();
			}
			return false;
		}
    });

	//Define ação para ENTER e TAB no campo HORARIO FINAL DE DEVOLUCAO DIURNA
	$("#hrdiufim","#frmHorarios").unbind('keydown').bind('keydown', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Horario Invalido
			if ( !validaHorarioDigitado($(this).val()) ) {
				showError("error","Hora de fim da DEVOLUCAO DIURNA inv&aacute;lida.","Alerta - Ayllos","focaCampoErro(\'hrdiufim\', \'frmHorarios\');",false);

			// Hora Inicial Maior que Hora Final
			} else if( compararHora($("#hrdiuini","#frmHorarios").val(), $(this).val()) ){
				showError("error","Hora de fim da DEVOLUCAO DIURNA n&atilde;o pode ser menor que a hora de in&iacute;cio.","Alerta - Ayllos","focaCampoErro(\'hrdiufim\', \'frmHorarios\');",false);

			// Sem erros
			} else {
				$(this).removeClass('campoErro');
				$("#hrnotatu","#frmHorarios").focus();
			}
			return false;
		}
    });

	//Define ação para ENTER e TAB no campo ATUALIZAR HORARIO DE DEVOLUCAO NOTURNA
	$("#hrnotatu","#frmHorarios").unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			if ( $(this).val() == "S" ){
				// Habilitar os campos de horario Inicial e Final de DEVOLUCAO NOTURNA
				$("#hrnotini","#frmHorarios").habilitaCampo().focus();
				$("#hrnotfim","#frmHorarios").habilitaCampo();
			} else {
				// Desabilitar os campos de horario Inicial e Final de DEVOLUCAO NOTURNA
				$("#hrnotini","#frmHorarios").desabilitaCampo();
				$("#hrnotfim","#frmHorarios").desabilitaCampo();
				// Setar o foco no proximo campo de atualizar
				$("#btSalvar","#divBotoes").focus();
			}
			return false;
		}
    });
	
	//Define ação para ENTER e TAB no campo HORARIO INICIAL DE DEVOLUCAO NOTURNA
	$("#hrnotini","#frmHorarios").unbind('keydown').bind('keydown', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Horario Invalido
			if ( !validaHorarioDigitado($(this).val()) ) {
				showError("error","Hora de in&iacute;cio da DEVOLUCAO NOTURNA inv&aacute;lida.","Alerta - Ayllos","focaCampoErro(\'hrnotini\', \'frmHorarios\');",false);
				
			// Sem erros
			} else {
				$(this).removeClass('campoErro');
				$("#hrnotfim","#frmHorarios").focus();
			}
			return false;
		}
    });

	//Define ação para ENTER e TAB no campo HORARIO FINAL DE DEVOLUCAO NOTURNA
	$("#hrnotfim","#frmHorarios").unbind('keydown').bind('keydown', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			// Horario Invalido
			if ( !validaHorarioDigitado($(this).val()) ) {
				showError("error","Hora de fim da DEVOLUCAO NOTURNA inv&aacute;lida.","Alerta - Ayllos","focaCampoErro(\'hrnotfim\', \'frmHorarios\');",false);

			// Hora Inicial Maior que Hora Final
			} else if( compararHora($("#hrnotini","#frmHorarios").val(), $(this).val()) ){
				showError("error","Hora de fim da DEVOLUCAO NOTURNA n&atilde;o pode ser menor que a hora de in&iacute;cio.","Alerta - Ayllos","focaCampoErro(\'hrnotfim\', \'frmHorarios\');",false);

			// Sem erros
			} else {
				$(this).removeClass('campoErro');
				$("#btSalvar","#divBotoes").focus();
			}
			return false;
		}
    });
}

/**
 * Funcao para validar se o horario informado esta entre 00:00 e 23:59
 */
function validaHorarioDigitado(horario){
	// Separar as horas em ":"
	var tempo  = horario.split(":");
	var hora   = tempo[0];
	var minuto = tempo[1];
	// Comparar hora e minutos
	if (hora < 0 || hora > 23 || minuto < 0 || minuto > 59) {
		return false;
	}
	return true;
}

/**
 * Funcao parar comparar datas de inicio e fim
 */
function compararHora(horaInicio, horaFim) {
    // Separamos as horas por ":"
	horaInicio = horaInicio.split(":");
    horaFim    = horaFim.split(":");

    var d = new Date();
	// Criamos a hora inicial e a hora final de acordo com as horas digitadas em tela
    var dataInicial = new Date(d.getFullYear(), d.getMonth(), d.getDate(), horaInicio[0], horaInicio[1]);
    var dataFinal = new Date(d.getFullYear(), d.getMonth(), d.getDate(), horaFim[0], horaFim[1]);

	// Verifica se a hora Inicial eh maior que a hora Final
    return dataInicial > dataFinal;
};

/**
 * Funcao para liberar os campos da tela de acordo com a OPCAO selecionada
 */
function liberaFormulario() {
	// Validar qual a opcao que o usuario selecionou
	switch($("#cddopcao","#frmCab").val()) {
		case "A": // Alterar Horarios de Pagamento da COMPE
			liberaAcaoAlterar();
			// Carregar os horarios de pagamento para alteracao
			carregarHorariosCoop();
		break;
	}
}

/**
 * Funcao para liberar os campos de opcao "ALTERAR"
 */
function liberaAcaoAlterar(){
	// Desabilitar a opção
	$("#cddopcao","#frmCab").desabilitaCampo();
	$("#cdcooper","#frmCab").desabilitaCampo();
	
	// Limpar formulário
	$('input[type="text"],select','#frmHorarios').limpaFormulario().desabilitaCampo().removeClass('campoErro');
	// Mostrar a tela
	$('#frmHorarios').css({'display':'block'});
	$('#divBotoes').css({'display':'block','padding-bottom':'15px'});
	$('#btVoltar','#divBotoes').css({'display':'inline'});
	$('#btSalvar','#divBotoes').css({'display':'inline'});
}

/**
 * Funcao para controlar a execucao do botao VOLTAR
 */
function voltar() {
	// Validar a opcao selecionada em tela
	switch($("#cddopcao","#frmCab").val()) {
		
		case "A": // Alterar Historicos
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
			// Solicitar a confirmacao da incluir historico
			showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','manterRotina();','','sim.gif','nao.gif');
		break;
		
	}

	return false;
}

/**
 * Funcao para carregar os horarios do PA SEDE da cooperativa selecionada na alteracao
 */
function carregarHorariosCoop(){
	var cddopcao = $("#cddopcao","#frmCab").val();
	var cdcooper = $("#cdcooper","#frmCab").val();
	
	showMsgAguardo( "Aguarde, buscando horarios..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/parhpg/busca_dados.php",
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
 * Funcao para realizar a gravacao dos dados do historico (Alterar/Incluir/Replicar)
 */
function manterRotina(){
	
	showMsgAguardo('Aguarde efetuando operacao...');

	var cddopcao  = $('#cddopcao','#frmCab').val();
	var cdcooper  = $('#cdcooper','#frmCab').val();
	
	
	var hrsicatu  = $('#hrsicatu','#frmHorarios').val();
	var hrsicini  = $('#hrsicini','#frmHorarios').val();
	var hrsicfim  = $('#hrsicfim','#frmHorarios').val();
	var hrtitatu  = $('#hrtitatu','#frmHorarios').val();
	var hrtitini  = $('#hrtitini','#frmHorarios').val();
	var hrtitfim  = $('#hrtitfim','#frmHorarios').val();
	var hrnetatu  = $('#hrnetatu','#frmHorarios').val();
	var hrnetini  = $('#hrnetini','#frmHorarios').val();
	var hrnetfim  = $('#hrnetfim','#frmHorarios').val();
	var hrtaaatu  = $('#hrtaaatu','#frmHorarios').val();
	var hrtaaini  = $('#hrtaaini','#frmHorarios').val();
	var hrtaafim  = $('#hrtaafim','#frmHorarios').val();
	var hrgpsatu  = $('#hrgpsatu','#frmHorarios').val();
	var hrgpsini  = $('#hrgpsini','#frmHorarios').val();
	var hrgpsfim  = $('#hrgpsfim','#frmHorarios').val();
	var hrsiccau  = $('#hrsiccau','#frmHorarios').val();
	var hrsiccan  = $('#hrsiccan','#frmHorarios').val();
	var hrtitcau  = $('#hrtitcau','#frmHorarios').val();
	var hrtitcan  = $('#hrtitcan','#frmHorarios').val();
	var hrnetcau  = $('#hrnetcau','#frmHorarios').val();
	var hrnetcan  = $('#hrnetcan','#frmHorarios').val();
	var hrtaacau  = $('#hrtaacau','#frmHorarios').val();
	var hrtaacan  = $('#hrtaacan','#frmHorarios').val();
	var hrdiuatu  = $('#hrdiuatu','#frmHorarios').val();
	var hrdiuini  = $('#hrdiuini','#frmHorarios').val();
	var hrdiufim  = $('#hrdiufim','#frmHorarios').val();
	var hrnotatu  = $('#hrnotatu','#frmHorarios').val();
	var hrnotini  = $('#hrnotini','#frmHorarios').val();
	var hrnotfim  = $('#hrnotfim','#frmHorarios').val();

	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/parhpg/manter_rotina.php', 
		data    :
				{ 
				  cddopcao : cddopcao,	// Opcao
				  cdcooper : cdcooper,  // Cooperativa selecionada
				  hrsicatu : hrsicatu,  // Atualizar Horario Pagamento SICREDI "S/N"
				  hrsicini : hrsicini,  // Horario de Pagamento SICREDI - Inicial
				  hrsicfim : hrsicfim,  // Horario de Pagamento SICREDI - Final
				  hrtitatu : hrtitatu,  // Atualizar Horario Pagamento TITULOS/FATURAS "S/N"
				  hrtitini : hrtitini,  // Horario de Pagamento TITULOS/FATURAS - Inicial
				  hrtitfim : hrtitfim,  // Horario de Pagamento TITULOS/FATURAS - Final
				  hrnetatu : hrnetatu,  // Atualizar Horario Pagamento INTERNET/MOBILE "S/N"
				  hrnetini : hrnetini,  // Horario de Pagamento INTERNET/MOBILE - Inicial
				  hrnetfim : hrnetfim,  // Horario de Pagamento INTERNET/MOBILE - Final
				  hrtaaatu : hrtaaatu,  // Atualizar Horario Pagamento TAA "S/N"
				  hrtaaini : hrtaaini,  // Horario de Pagamento TAA - Inicial
				  hrtaafim : hrtaafim,  // Horario de Pagamento TAA - Final
				  hrgpsatu : hrgpsatu,  // Atualizar Horario Pagamento GPS "S/N"
				  hrgpsini : hrgpsini,  // Horario de Pagamento GPS - Inicial
				  hrgpsfim : hrgpsfim,  // Horario de Pagamento GPS - Final
				  hrsiccau : hrsiccau,  // Atualizar Horario Cancelamento do Pagamento SICREDI "S/N"
				  hrsiccan : hrsiccan,  // Horario de Cancelamento de Pagamento SICREDI
				  hrtitcau : hrtitcau,  // Atualizar Horario Cancelamento do Pagamento TITULOS/FATURAS "S/N"
				  hrtitcan : hrtitcan,  // Horario de Cancelamento de Pagamento TITULOS/FATURAS
				  hrnetcau : hrnetcau,  // Atualizar Horario Cancelamento do Pagamento INTERNET/MOBILE "S/N"
				  hrnetcan : hrnetcan,  // Horario de Cancelamento de Pagamento INTERNET/MOBILE
				  hrtaacau : hrtaacau,  // Atualizar Horario Cancelamento do Pagamento TAA "S/N"
				  hrtaacan : hrtaacan,  // Horario de Cancelamento de Pagamento TAA
				  hrdiuatu : hrdiuatu,  // Atualizar Horario DEVOLUCAO DIURNA "S/N"
				  hrdiuini : hrdiuini,  // Horario de Pagamento DEVOLUCAO DIURNA - Inicial
				  hrdiufim : hrdiufim,  // Horario de Pagamento DEVOLUCAO DIURNA - Final
				  hrnotatu : hrnotatu,  // Atualizar Horario DEVOLUCAO NOTURNA "S/N"
				  hrnotini : hrnotini,  // Horario de Pagamento DEVOLUCAO NOTURNA - Inicial
				  hrnotfim : hrnotfim,  // Horario de Pagamento DEVOLUCAO NOTURNA - Final
				  redirect : 'script_ajax'
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
				},
		success : function(response) { 
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
function liberaCamposAtualizar(){
	// Bloquear todos os campos do formulario
	$('input[type="text"]','#frmHorarios').desabilitaCampo();
	// Habilitar os campos "ATUALIZAR"
	$('#hrsicatu','#frmHorarios').val("N").habilitaCampo().focus();
	$('#hrtitatu','#frmHorarios').val("N").habilitaCampo();
	$('#hrnetatu','#frmHorarios').val("N").habilitaCampo();
	$('#hrtaaatu','#frmHorarios').val("N").habilitaCampo();
	$('#hrgpsatu','#frmHorarios').val("N").habilitaCampo();
	$('#hrsiccau','#frmHorarios').val("N").habilitaCampo();
	$('#hrtitcau','#frmHorarios').val("N").habilitaCampo();
	$('#hrnetcau','#frmHorarios').val("N").habilitaCampo();
	$('#hrtaacau','#frmHorarios').val("N").habilitaCampo();
	$('#hrdiuatu','#frmHorarios').val("N").habilitaCampo();
	$('#hrnotatu','#frmHorarios').val("N").habilitaCampo();
}
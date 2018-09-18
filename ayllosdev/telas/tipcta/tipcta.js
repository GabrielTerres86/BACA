/***********************************************************************
 Fonte: tipcta.js                                                  
 Autor: Lombardi
 Data : JULHO/2016                Última Alteração: 

 Objetivo  : Cadastro de servicos ofertados na tela LCREDI

 Alterações: 

************************************************************************/

var detachedAt, detachedElem="";

$(document).ready(function() {	
	
	estadoInicial();
	
});


function estadoInicial() {
    
    //Inicializa o array
    RegLinha = new Object();
	
	$('#divConteudo').html('');
	
    formataCabecalho();
	
    $('#cddopcao', '#frmCab').habilitaCampo().focus().val('I');
       	
}

function formataCabecalho() {

    // rotulo
    $('label[for="cddopcao"]', "#frmCab").addClass("rotulo").css({ "width": "45px" });

    // campo
    $("#cddopcao", "#frmCab").css("width", "630px").habilitaCampo();

    $('#divTela').css({ 'display': 'block' }).fadeTo(0, 0.1);
    removeOpacidade('divTela');
    $('#frmCab').css({ 'display': 'block' });
    highlightObjFocus($('#frmCab'));

    $('input[type="text"],select', '#frmCab').limpaFormulario().removeClass('campoErro');

    //Define ação para ENTER e TAB no campo Opção
    $("#cddopcao", "#frmCab").unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) {

            mostrarConteudo();

            return false;

        }

    });

    //Define ação para CLICK no botão de OK
    $("#btnOK", "#frmCab").unbind('click').bind('click', function () {

        // Se esta desabilitado o campo 
        if ($("#cddopcao", "#frmCab").prop("disabled") == true) {
            return false;
        }

        mostrarConteudo();

        $(this).unbind('click');

        return false;
        
    });

    layoutPadrao();

    return false;
}

function formataTipoConta() {
	
	var cddopcao = $("#cddopcao", "#frmCab").val();
    // Desabilitar a opção
    $("#cddopcao", "#frmCab").desabilitaCampo();
    
    //labels
    $('label[for="inpessoa"]', "#frmTipoConta").addClass("rotulo").css({ "width": "130px" });
	$('label[for="cdtipo_conta"]', "#frmTipoConta").addClass("rotulo").css({ "width": "130px" });
	$('label[for="cdcatego"]', "#frmTipoConta").addClass("rotulo").css({ "width": "130px" });
	$('label[for="tpcadast"]', "#frmTipoConta").addClass("rotulo").css({ "width": "130px" });
	$('label[for="cdmodali"]', "#frmTipoConta").addClass("rotulo-linha").css({ "width": "110px" });
	$('label[for="indconta_itg"]', "#frmTipoConta").addClass("rotulo").css({ "width": "130px" });
	
    // campos
    $('#inpessoa_1', '#frmTipoConta').css({ "margin-left": "10px", "margin-right" :"3px"}).desabilitaCampo();
    $('#inpessoa_2', '#frmTipoConta').css({ "margin-left": "10px", "margin-right" :"3px"}).desabilitaCampo();
    $('#inpessoa_3', '#frmTipoConta').css({ "margin-left": "10px", "margin-right" :"3px"}).desabilitaCampo();
    $('#cdtipo_conta', '#frmTipoConta').addClass('inteiro').css({ 'width': '50px', 'text-align': 'right' }).attr('maxlength', '5').desabilitaCampo();
    $('#dstipo_conta', '#frmTipoConta').css({ 'width': '400px', "margin-left": "6px"}).attr('maxlength', '50').desabilitaCampo();
    $('#individual', '#frmTipoConta').css({ "margin-left": "4px", "margin-right" :"50px"}).desabilitaCampo();
    $('#conjunta_solidaria', '#frmTipoConta').css({ "margin-left": "4px", "margin-right" :"50px"}).desabilitaCampo();
    //$('#conjunta_nao_solidaria', '#frmTipoConta').css({ "margin-left": "4px", "margin-right" :"50px"}).desabilitaCampo();
    $('#tpcadast', '#frmTipoConta').css({ 'width': '130px' }).desabilitaCampo();
    $('#cdmodali', '#frmTipoConta').css({ 'width': '230px' }).desabilitaCampo();
    $('#indconta_itg', '#frmTipoConta').css({ 'width': '50px' }).desabilitaCampo();
    
    $('#frmTipoConta').css({ 'display': 'block' });
    $('#divBotoes').css({ 'display': 'block' });
    $('#btProsseguir', '#divBotoes').css({ 'display': 'none' });
    
	$('input[type=radio][name=inpessoa]').change(function () {
		verificaInpessoa(this.value);
	});
	
	$("#inpessoa_1").prop("checked", true);
	
	if (cddopcao == 'I') {
		$('#inpessoa_1', '#frmTipoConta').habilitaCampo();
		$('#inpessoa_2', '#frmTipoConta').habilitaCampo();
		$('#inpessoa_3', '#frmTipoConta').habilitaCampo();
		$('#dstipo_conta', '#frmTipoConta').habilitaCampo();
		$('#individual', '#frmTipoConta').habilitaCampo();
		$('#conjunta_solidaria', '#frmTipoConta').habilitaCampo();
		//$('#conjunta_nao_solidaria', '#frmTipoConta').habilitaCampo();
		$('#tpcadast', '#frmTipoConta').habilitaCampo();
		$('#cdmodali', '#frmTipoConta').habilitaCampo();
		$('#indconta_itg', '#frmTipoConta').habilitaCampo();
		
		$("#dstipo_conta", "#frmTipoConta").focus();
	
	} else {
		$('#inpessoa_1', '#frmTipoConta').habilitaCampo();
		$('#inpessoa_2', '#frmTipoConta').habilitaCampo();
		$('#inpessoa_3', '#frmTipoConta').habilitaCampo();
		$('#cdtipo_conta', '#frmTipoConta').habilitaCampo();
		$("#cdtipo_conta", "#frmTipoConta").focus();
		
		$('#cdtipo_conta', '#frmTipoConta').unbind('blur').bind('blur', function() {
			buscarTipoDeConta();
		});
	}
	
	switch(cddopcao) {
		case 'I':
			$("#btProsseguir", "#divBotoes").css({ 'display': 'inline' }).text('Incluir');
			
			//Define ação para CLICK no botão de Concluir
			$("#btProsseguir", "#divBotoes").unbind('click').bind('click', function () {
				if (verificaCampos())
					confirmaIncluir();
			});
		break;
		case 'A':
		case 'E':
			$("#btProsseguir", "#divBotoes").css({ 'display': 'inline' }).text('Prosseguir');
			break;
		case 'C':
			$("#btProsseguir", "#divBotoes").css({ 'display': 'inline' }).text('Prosseguir');
			
			//Define ação para CLICK no botão de Concluir
			$("#btProsseguir", "#divBotoes").unbind('click').bind('click', function () {
				buscarTipoDeConta();
			});
			break;
		default:
			break;
	}	
	
	highlightObjFocus($('#frmTipoConta'));
    
	controlaFoco();
	
	//Define ação para os selects
    $("select", "#frmTipoConta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });
	
    //Define ação para CLICK no botão de Voltar
    $("#btVoltar", "#divBotoes").unbind('click').bind('click', function () {

        controlaVoltar('1');

        return false;

    });

    layoutPadrao();

}

function buscaBackup() {
	var bo, procedure, titulo, qtReg, filtros, colunas, cdhiscxa;
	
	bo			= 'ZOOM0001';
	procedure	= 'BUSCA_TIPO_CONTA';
	titulo      = 'Tipos de conta';
	qtReg		= '20';
	filtros 	= 'inpessoa|'+ $('input[type=radio][name=inpessoa]:checked').val() + ';cdcooper|0';
	buscaDescricao(bo,procedure,titulo,'cdtipo_conta','dstipo_conta',$('#cdtipo_conta', '#frmTipoConta').val(),'dstipo_conta',filtros,'frmTipoConta','buscarTipoDeConta();');
	return false;
}

function formataTransferencia() {
	
	var bo, procedure, titulo, qtReg, filtros, colunas, cdhiscxa;
	
	var cddopcao = $("#cddopcao", "#frmCab").val();
    // Desabilitar a opção
    $("#cddopcao", "#frmCab").desabilitaCampo();
    
    //labels
    $('label[for="inpessoa"]', "#frmTransferencia").addClass("rotulo").css({ "width": "180px" });
    $('label[for="cdcooper"]', "#frmTransferencia").addClass("rotulo").css({ "width": "180px" });
	$('label[for="cdtipo_conta"]', "#frmTransferencia").addClass("rotulo").css({ "width": "180px" });
   
    // campos
    $('#inpessoa_1', '#frmTransferencia').css({ "margin-left": "10px", "margin-right" :"3px", "margin-top": "3px"}).habilitaCampo();
    $('#inpessoa_2', '#frmTransferencia').css({ "margin-left": "10px", "margin-right" :"3px", "margin-top": "3px"}).habilitaCampo();
    $('#inpessoa_3', '#frmTransferencia').css({ "margin-left": "10px", "margin-right" :"3px", "margin-top": "3px"}).habilitaCampo();
    $('#cdcooper', '#frmTransferencia').css({ "margin-left": "3px", "width": "140px"}).habilitaCampo();
    $('#cdtipo_conta', '#divTransferencia_1').addClass('inteiro').css({ 'width': '50px', 'text-align': 'right' }).attr('maxlength', '5').habilitaCampo();
    $('#dstipo_conta', '#divTransferencia_1').css({ 'width': '400px', "margin-left": "6px"}).attr('maxlength', '50').desabilitaCampo();
    $('#cdtipo_conta', '#divTransferencia_2').addClass('inteiro').css({ 'width': '50px', 'text-align': 'right' }).attr('maxlength', '5').habilitaCampo();
    $('#dstipo_conta', '#divTransferencia_2').css({ 'width': '400px', "margin-left": "6px"}).attr('maxlength', '50').desabilitaCampo();
    
    $('#frmTransferencia').css({ 'display': 'block' });
    $('#divBotoes').css({ 'display': 'block' });
    $('#btProsseguir', '#divBotoes').css({ 'display': 'none' });
    
	$("#inpessoa_1").prop("checked", true);
	
	$("#cdcooper", "#frmTransferencia").unbind('change').bind('change', function() {
		$("#cdtipo_conta", "#divTransferencia_1").val('');
		$("#dstipo_conta", "#divTransferencia_1").val('');
		$("#cdtipo_conta", "#divTransferencia_2").val('');
		$("#dstipo_conta", "#divTransferencia_2").val('');
		return false;
	});
	
	$('input[type=radio][name=inpessoa]').unbind('change').bind('change', function() {
		$("#cdtipo_conta", "#divTransferencia_1").val('');
		$("#dstipo_conta", "#divTransferencia_1").val('');
		$("#cdtipo_conta", "#divTransferencia_2").val('');
		$("#dstipo_conta", "#divTransferencia_2").val('');
		return false;
	});
	
	$('#cdtipo_conta', '#divTransferencia_1').unbind('change').bind('change', function() {
		bo			= 'ZOOM0001';
		procedure	= 'BUSCA_TIPO_CONTA';
		titulo      = 'Tipos de conta';
		qtReg		= '20';
		filtros 	= 'inpessoa|'+ $('input[type=radio][name=inpessoa]:checked').val() + ';cdcooper|' + $('#cdcooper', '#frmTransferencia').val();
		buscaDescricao(bo,procedure,titulo,'cdtipo_conta','dstipo_conta',$('#cdtipo_conta', '#divTransferencia_1').val(),'dstipo_conta',filtros,'divTransferencia_1');
		return false;
	});
	
	$('#cdtipo_conta', '#divTransferencia_2').unbind('change').bind('change', function() {
		bo			= 'ZOOM0001';
		procedure	= 'BUSCA_TIPO_CONTA';
		titulo      = 'Tipos de conta';
		qtReg		= '20';
		filtros 	= 'inpessoa|'+ $('input[type=radio][name=inpessoa]:checked').val() + ';cdcooper|' + $('#cdcooper', '#frmTransferencia').val();
		buscaDescricao(bo,procedure,titulo,'cdtipo_conta','dstipo_conta',$('#cdtipo_conta', '#divTransferencia_2').val(),'dstipo_conta',filtros,'divTransferencia_2');
		return false;
	});
	
	$("#btProsseguir", "#divBotoes").css({ 'display': 'inline' }).text('Transferir');

	//Define ação para CLICK no botão de Concluir
	$("#btProsseguir", "#divBotoes").unbind('click').bind('click', function () {

		if (verificaCampos())
			confirmaTransferencia();
		
	});
	
	highlightObjFocus($('#frmTransferencia'));   
    
    //Define ação para os inputs
    $("input", "#frmTransferencia").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });
	
	//Define ação para os selects
    $("select", "#frmTransferencia").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });
	
    //Define ação para CLICK no botão de Voltar
    $("#btVoltar", "#divBotoes").unbind('click').bind('click', function () {

        controlaVoltar('1');

        return false;

    });

	$("#cdcooper", "#frmTransferencia").focus();
	
    layoutPadrao();

}

function controlaFoco() {
	
	var cddopcao = $("#cddopcao", "#frmCab").val();
	
    //Define ação para os campos
    $('input', '#frmTipoConta').unbind('keypress').bind('keypress', function (e) {
	
        if (divError.css('display') == 'block') { return false; }
		
        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {
			
			if ($(this).attr('name') == 'indconta_itg') {
				$('#btProsseguir','#divBotoes').focus();
			} else {
				$(this).nextAll('.campo:first').focus();
			}
            return false;
        }
    });
    
	//Define ação para os campos
    $('select', '#frmTipoConta').unbind('keydown').bind('keydown', function (e) {
	
        if (divError.css('display') == 'block') { return false; }
		
        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {
			
			if ($(this).attr('name') == 'indconta_itg') {
				$('#btProsseguir','#divBotoes').focus();
			} else {
				$(this).nextAll('.campo:first').focus();
			}
            return false;
        }
    });
	
}

function mostrarConteudo(inpessoa, cdtipo_conta) {
	cddopcao = $("#cddopcao", "#frmCab").val();
	
	if (cddopcao != 'T') {
		montaTipoConta();
		if (inpessoa > 0 && cdtipo_conta > 0) {
			buscarTipoDeConta(inpessoa, cdtipo_conta);
		}
	} else {
		montaTransferencia();
	}
}

function montaTipoConta() {

    var cddopcao = $("#cddopcao", "#frmCab").val();

    showMsgAguardo("Aguarde ...");

    //Requisição para montar o form correspondente a opção escolhida
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/tipcta/form_tipo_de_conta.php",
        data: {
			cddopcao: cddopcao,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "estadoInicial();");
        },
        success: function (response) {

            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {

                    $('#divConteudo').html(response);
					formataTipoConta();
                    return false;
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "estadoInicial();");
                }
            } else {
                try {

                    eval(response);
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "estadoInicial();");
                }
            }
        }

    });

    return false;

}

function montaTransferencia() {

    var cddopcao = $("#cddopcao", "#frmCab").val();

    showMsgAguardo("Aguarde ...");

    //Requisição para montar o form correspondente a opção escolhida
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/tipcta/form_transferencia.php",
        data: {
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "estadoInicial();");
        },
        success: function (response) {

            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {

                    $('#divConteudo').html(response);
					formataTransferencia();
                    return false;
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "estadoInicial();");
                }
            } else {
                try {

                    eval(response);
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "estadoInicial();");
                }
            }
        }

    });

    return false;

}

function buscarTipoDeConta(inpessoa, cdtipo_conta) {
	
	var cddopcao = $("#cddopcao", "#frmCab").val();
	var inpessoa   = inpessoa > 0 ? inpessoa : $('input[type=radio][name=inpessoa]:checked').val().trim();
	var cdtipo_conta   = cdtipo_conta > 0 ? cdtipo_conta : $("#cdtipo_conta","#frmTipoConta").val().trim();
	
	if (cdtipo_conta.length == 0)
		return false;
	
	// Mostra mensagem de aguardo	
	showMsgAguardo("Aguarde...");
	
	// Executa script de confirmação através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/tipcta/buscar_tipo_de_conta.php',
		data: {
			cddopcao: 		cddopcao,
			inpessoa: 		inpessoa,
			cdtipo_conta: 	cdtipo_conta,
			redirect: 'html_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();

			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			hideMsgAguardo();
			eval(response);
			
			switch(cddopcao) {
				case 'A':
					$('#inpessoa_1', '#frmTipoConta').desabilitaCampo();
					$('#inpessoa_2', '#frmTipoConta').desabilitaCampo();
					$('#inpessoa_3', '#frmTipoConta').desabilitaCampo();
					$('#cdtipo_conta', '#frmTipoConta').desabilitaCampo();
					$('#dstipo_conta', '#frmTipoConta').habilitaCampo();
					$('#individual', '#frmTipoConta').habilitaCampo();
					$('#conjunta_solidaria', '#frmTipoConta').habilitaCampo();
					//$('#conjunta_nao_solidaria', '#frmTipoConta').habilitaCampo();
					$('#tpcadast', '#frmTipoConta').habilitaCampo();
					$('#cdmodali', '#frmTipoConta').habilitaCampo();
					$('#indconta_itg', '#frmTipoConta').habilitaCampo();
					$('#dstipo_conta', '#frmTipoConta').focus();
					$("#btProsseguir", "#divBotoes").text('Alterar');
					$("#btProsseguir", "#divBotoes").unbind('click').bind('click', function () {
						if (verificaCampos())
							confirmaAlterar();						
					});
					verificaInpessoa(inpessoa);
					break;
				case 'E':
					$('#inpessoa_1', '#frmTipoConta').desabilitaCampo();
					$('#inpessoa_2', '#frmTipoConta').desabilitaCampo();
					$('#inpessoa_3', '#frmTipoConta').desabilitaCampo();
					$('#cdtipo_conta', '#frmTipoConta').desabilitaCampo();
					$("#btProsseguir", "#divBotoes").text('Excluir');
					$("#btProsseguir", "#divBotoes").unbind('click').bind('click', function () {
						confirmaExcluir();						
					});
					break;
				default: 
					break;
			}
			controlaFoco();
			return false;
		}
	});
}

function confirmaIncluir() {
	
	showConfirmacao('Confirma a inclus&atilde;o do Tipo de Conta?', 'Confirma&ccedil;&atilde;o - Ayllos', 'incluirTipodeConta();', '$(\'#btVoltar\',\'#divBotoesConsulta\').focus();', 'sim.gif', 'nao.gif');
}

function confirmaAlterar() {
	
	showConfirmacao('Confirma a altera&ccedil;&atilde;o do Tipo de Conta?', 'Confirma&ccedil;&atilde;o - Ayllos', 'alterarTipodeConta();', '$(\'#btVoltar\',\'#divBotoesConsulta\').focus();', 'sim.gif', 'nao.gif');
}

function confirmaExcluir() {
	
	showConfirmacao('Confirma a exclus&atilde;o do Tipo de Conta?', 'Confirma&ccedil;&atilde;o - Ayllos', 'excluirTipodeConta();', '$(\'#btVoltar\',\'#divBotoesConsulta\').focus();', 'sim.gif', 'nao.gif');
}

function confirmaTransferencia() {
	
	showConfirmacao('Confirma a transfer&ecirc;ncia entre os Tipos de Conta selecionados? A opera&ccedil;&atilde;o n&atilde;o poder&aacute; ser desfeita.', 'Confirma&ccedil;&atilde;o - Ayllos', 'transferirTipodeConta();', '$(\'#btVoltar\',\'#divBotoesConsulta\').focus();', 'sim.gif', 'nao.gif');
}

function incluirTipodeConta() {
	
	var inpessoa   = $('input[type=radio][name=inpessoa]:checked').val();
	var dstipo_conta   = $("#dstipo_conta","#frmTipoConta").val().trim();
	var individual = $("#individual","#frmTipoConta").is(':checked') ? 1 : 0;
	var conjunta_solidaria = $("#conjunta_solidaria","#frmTipoConta").is(':checked') ? 1 : 0;
	var conjunta_nao_solidaria = 0; //$("#conjunta_nao_solidaria","#frmTipoConta").is(':checked') ? 1 : 0;
	var tpcadast   = $("#tpcadast option:selected").val();
	var cdmodali   = $("#cdmodali option:selected").val();
	var indconta_itg   = $("#indconta_itg option:selected").val();
	
	// Mostra mensagem de aguardo	
	showMsgAguardo("Aguarde...");
	
	// Executa script de confirmação através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/tipcta/incluir_tipo_de_conta.php',
		data: {
			inpessoa: 				inpessoa,
			dstipo_conta: 			dstipo_conta,
			individual: 			individual,
			conjunta_solidaria: 	conjunta_solidaria,
			conjunta_nao_solidaria: conjunta_nao_solidaria,
			tpcadast: 				tpcadast,
			cdmodali: 				cdmodali,
			indconta_itg: 			indconta_itg,
			redirect: 'html_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();

			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			hideMsgAguardo();
			eval(response);
			return false;
		}
	});
	
}

function alterarTipodeConta() {
	
	var inpessoa = $('input[type=radio][name=inpessoa]:checked').val();
	var cdtipo_conta = $("#cdtipo_conta","#frmTipoConta").val().trim();
	var cdtipo_conta = $("#cdtipo_conta","#frmTipoConta").val().trim();
	var dstipo_conta = $("#dstipo_conta","#frmTipoConta").val().trim();
	var individual = $("#individual","#frmTipoConta").is(':checked') ? 1 : 0;
	var conjunta_solidaria = $("#conjunta_solidaria","#frmTipoConta").is(':checked') ? 1 : 0;
	var conjunta_nao_solidaria = 0; //$("#conjunta_nao_solidaria","#frmTipoConta").is(':checked') ? 1 : 0;
	var tpcadast = $("#tpcadast option:selected").val();
	var cdmodali = $("#cdmodali option:selected").val();
	var indconta_itg = $("#indconta_itg option:selected").val();
	
	// Mostra mensagem de aguardo	
	showMsgAguardo("Aguarde...");
	
	// Executa script de confirmação através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/tipcta/alterar_tipo_de_conta.php',
		data: {
			inpessoa:				inpessoa,
			cdtipo_conta: 			cdtipo_conta,
			dstipo_conta: 			dstipo_conta,
			individual: 			individual,
			conjunta_solidaria: 	conjunta_solidaria,
			conjunta_nao_solidaria: conjunta_nao_solidaria,
			tpcadast: 				tpcadast,
			cdmodali: 				cdmodali,
			indconta_itg: 			indconta_itg,
			redirect: 'html_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();

			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			hideMsgAguardo();
			eval(response);
			return false;
		}
	});
	
}

function excluirTipodeConta() {
	
	var inpessoa     = $('input[type=radio][name=inpessoa]:checked').val();
	var cdtipo_conta = $("#cdtipo_conta","#frmTipoConta").val().trim();
	
	// Mostra mensagem de aguardo	
	showMsgAguardo("Aguarde...");
	
	// Executa script de confirmação através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/tipcta/excluir_tipo_de_conta.php',
		data: {
			inpessoa: 	  inpessoa,
			cdtipo_conta: cdtipo_conta,
			redirect: 'html_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();

			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			hideMsgAguardo();
			eval(response);
			return false;
		}
	});
	
}

function transferirTipodeConta() {
	
	var inpessoa = $('input[type=radio][name=inpessoa]:checked').val();
	var cdcooper = $("#cdcooper","#frmTransferencia").val().trim();
	var cdtipo_conta_origem = $("#cdtipo_conta","#divTransferencia_1").val().trim();
	var cdtipo_conta_destino = $("#cdtipo_conta","#divTransferencia_2").val().trim();
	
	// Mostra mensagem de aguardo	
	showMsgAguardo("Aguarde...");
	
	// Executa script de confirmação através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/tipcta/transferir_tipo_de_conta.php',
		data: {
			inpessoa: inpessoa,
			cdcooper: cdcooper,
			cdtipo_conta_origem:  cdtipo_conta_origem,
			cdtipo_conta_destino: cdtipo_conta_destino,
			redirect: 'html_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();

			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			hideMsgAguardo();
			eval(response);
			return false;
		}
	});
	
}

function controlaPesquisa(divPai, buscaTipoDeConta) {
	
	if ($("#cddopcao", "#frmCab").val() == 'I') { return false }
	
    var bo, procedure, titulo, qtReg, filtros, colunas, cdhiscxa;
	var inpessoa = $('input[type=radio][name=inpessoa]:checked').val();
	var cdcooper = $("#cdcooper","#frmTransferencia").length ? $('#cdcooper','#frmTransferencia').val() : 0;
	
    bo			= 'ZOOM0001';
    procedure	= 'BUSCA_TIPO_CONTA';
    titulo      = 'Tipos de Conta';
    qtReg		= '20';
    filtros 	= 'Cod. Tipo de Conta;cdtipo_conta;45px;S;;S|Descri&ccedil&atildeo;dstipo_conta;200px;S|Tipo de Pessoa;inpessoa;200px;N;' + inpessoa + ';N|Cooperativa;cdcooper;200px;N;' + cdcooper + ';N';
    colunas 	= 'Codigo;cdtipo_conta;15%;right|Descri&ccedil&atildeo;dstipo_conta;55%;left';  
    
    mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'',(buscaTipoDeConta ? 'buscarTipoDeConta();' : ''),divPai);
    
}

function verificaCampos() {
	
	var cddopcao = $("#cddopcao", "#frmCab").val();
	
	if (cddopcao == 'T') {
	
		if ($("#cdtipo_conta","#divTransferencia_1").val() == '') {
			showError("error", "Tipo e conta origem inv&aacute;lido.", "Alerta - Ayllos", "");
			return false;
		}
	
		if ($("#cdtipo_conta","#divTransferencia_2").val() == '') {
			showError("error", "Tipo e conta destino inv&aacute;lido.", "Alerta - Ayllos", "");
			return false;
		}
	
	} else {
	
		var isInpessoaChecked = jQuery("input[name=inpessoa]:checked").val();
	
		if (!isInpessoaChecked) {
			showError("error", "Selecione um Tipo de Pessoa.", "Alerta - Ayllos", "");
			return false;
		}
	
		if ($("#dstipo_conta","#frmTipoConta").val().trim() == '') {
			showError("error", "Descri&ccedil;&atilde;o do Tipo de Conta inv&aacute;lido.", "Alerta - Ayllos", "");
			return false;
		}
	
		if (jQuery("input[name='cdcatego']:checked").length == 0) {
			showError("error", "Selecione uma categoria.", "Alerta - Ayllos", "");
			return false;
		}
	
	}
	return true;
}

function verificaInpessoa(inpessoa) {
	var cddopcao = $("#cddopcao", "#frmCab").val();
	if (cddopcao == 'I' || cddopcao == 'A') {
		if (inpessoa == 1) {
			$("#individual","#frmTipoConta").habilitaCampo();
			$("#conjunta_solidaria","#frmTipoConta").habilitaCampo();
			//$("#conjunta_nao_solidaria","#frmTipoConta").habilitaCampo();	
			if (detachedElem != "") { // Foi feito assim por causa do IE
				$("#cdmodali option[value=2]","#frmTipoConta").removeAttr('disabled').show();
				$(detachedElem).insertAfter($("#cdmodali option").eq(detachedAt-1));
				detachedElem = "";
			}
		} else {
			$("#individual","#frmTipoConta").desabilitaCampo().prop("checked",true);
			$("#conjunta_solidaria","#frmTipoConta").desabilitaCampo().prop("checked",false);
			//$("#conjunta_nao_solidaria","#frmTipoConta").desabilitaCampo().prop("checked",false);
			if (detachedElem == "") { // Foi feito assim por causa do IE
				detachedAt = $("#cdmodali option[value=2]","#frmTipoConta").prevAll().length;
				detachedElem = $("#cdmodali option[value=2]","#frmTipoConta").detach();
			}
		}
	}
}

function controlaVoltar(ope,tpconsul) {
    
    estadoInicial();
    return false;

}

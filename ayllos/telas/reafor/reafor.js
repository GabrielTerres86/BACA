/*!
 * FONTE        : reafor.js
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Outubro/2014
 * OBJETIVO     : Biblioteca de funções da tela REAFOR
 * --------------
 * ALTERAÇÕES   :
 * -----------------------------------------------------------------------
 */

// Variaveis

var idrowid = '';

var rCddopcao, rDtmvtolt,
    cCddopcao, cDtmvtolt;

var rNrcpfcgc,rNmprimtl,rNrdconta,rNrctremp,
    cNrcpfcgc,cNmprimtl,cNrdconta,cNrctremp;

var cTodosCabecalho, btnOK, btnOK2,btnOK3;


// Funcao de Data JavaScript
function dataString(vData) {

    var dtArray = vData.split('/');

    switch (dtArray[1]) {
    case "1":
    case "2":
    case "3":
    case "4":
    case "5":
    case "6":
    case "7":
    case "8":
    case "9":
        vMes = "0" + (dtArray[1]);
        break;
    default:
        vMes = dtArray[1];
    }

    return dtArray[0] + "/" + vMes + "/" + dtArray[2];
}

function setaDataTela() {

    var dtHoje  = new Date();
    var dtmvtolt 	=  dataString(dtHoje.getDate() + "/" + (dtHoje.getMonth()+1)  + "/" + dtHoje.getFullYear());

    $('#dtmvtolt','#frmCab').val(dtmvtolt);
    return false;
}


// Tela
$(document).ready(function() {
	estadoInicial();
});


function estadoInicial() {

	$('#divRotina').fadeTo(0,0.1);

	// Inicializa Variavel
	idrowid = '';

	atualizaSeletor();
	formataCabecalho();

	$('#divConsulta').css({'display':'none'});
	$('#divRegistros').css({'display':'none'});
	$('#divBotoes').css({'display':'none'});
	$('#divIncluir').css({'display':'none'});
	$('#frmCab').css({'display':'block'});
	$("#divConteudo").html('');

	removeOpacidade('divTela');

	$('#btIncluir','#divBotoes').hide();
	$('#btAlterar','#divBotoes').hide();
	$('#btExcluir','#divBotoes').hide();
	$('#btnVoltar','#divBotoes').hide();
	btnOK.prop('disabled',false);

	cCddopcao.focus();
}


// Cabecalho
function atualizaSeletor() {

	/** Geral **/
	rCddopcao	    = $('label[for="cddopcao"]','#frmCab');

	cCddopcao		= $('#cddopcao','#frmCab');

	cTodosCabecalho	= $('input[type="text"],select','#frmCab');
	btnOK			= $('#btnOK','#frmCab');
	btnOK2			= $('#btnOK2','#frmCab');
	btnOK3			= $('#btnOK3','#frmCab');

	/** Campos da divConsulta **/
	rDtmvtolt       = $('label[for="dtmvtolt"]','#frmCab');

	cDtmvtolt       = $('#dtmvtolt','#frmCab');

	/** Campos da divIncluir **/
	rNrcpfcgc	    = $('label[for="nrcpfcgc"]','#frmCab');
	rNmprimtl       = $('label[for="nmprimtl"]','#frmCab');
	rNrdconta       = $('label[for="nrdconta"]','#frmCab');
	rNrctremp       = $('label[for="nrctremp"]','#frmCab');

	cNrcpfcgc		= $('#nrcpfcgc','#frmCab');
	cNmprimtl       = $('#nmprimtl','#frmCab');
	cNrdconta       = $('#nrdconta','#frmCab');
	cNrctremp       = $('#nrctremp','#frmCab');

	cCddopcao.habilitaCampo();
	return false;
}


// Formatacao da Tela
function formataCabecalho() {

	/** Geral **/
	rCddopcao.addClass('rotulo').css({'width':'80px'});
	cCddopcao.addClass('rotulo').css({'width':'450px'});

	/** Campos da divConsulta **/
	rDtmvtolt.addClass('rotulo').css({'width':'80px'});
	cDtmvtolt.addClass('data').css({'width':'85px'});

	/** Campos da divIncluir **/
	rNrcpfcgc.addClass('rotulo').css({'width':'80px'});
	rNmprimtl.addClass('rotulo-linha').css({'width':'90px'});
	rNrdconta.addClass('rotulo-linha').css({'width':'90px'});
	rNrctremp.addClass('rotulo-linha').css({'width':'90px'});

	cNrcpfcgc.addClass('rotulo-linha').css({'width':'100px'});
	cNmprimtl.addClass('rotulo-linha').css({'width':'280px'});
	cNrdconta.addClass('rotulo-linha').css({'width':'100px'});
	cNrctremp.addClass('rotulo-linha').css({'width':'100px'});

	highlightObjFocus( $('#frmCab') );

	opcaoTela();
	layoutPadrao();
	return false;
}


function opcaoTela() {

	// Se clicar no botao OK de cddopcao
	btnOK.unbind('click').bind('click', function() {
		if (cCddopcao.val() == 'C') {
			btnOK.prop('disabled',true);

	        $('#divConsulta').css({'display':'block'});

			$('#btVoltar' ,'#divBotoes').show();
			$('#divBotoes').css({'display':'block'});
			$('#btVoltar' ,'#divBotoes').show();

			cDtmvtolt.val(aux_dtmvtolt);
			cDtmvtolt.habilitaCampo();
			cDtmvtolt.focus();
			cCddopcao.desabilitaCampo();
		}else
		if (cCddopcao.val() == 'I') {
			incluirNovoRegistro();
		}
		return false;
	});

	// Se clicar no botao OK de dtmvtolt
	btnOK2.unbind('click').bind('click', function() {
		btnOK2.prop('disabled',true);
		cDtmvtolt.desabilitaCampo();
		consultaDadosReafor();
		return false;
	});

	// Se clicar no botao OK de nrcpfcgc
	btnOK3.unbind('click').bind('click', function() {
		btnOK3.prop('disabled',true);
		consultaContaAssocido();
		return false;
	});

	cCddopcao.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			if (cCddopcao.val() == 'C') {
				btnOK.prop('disabled',true);
				$('#divConsulta').css({'display':'block'});

				$('#btVoltar' ,'#divBotoes').show();
				$('#divBotoes').css({'display':'block'});
				$('#btVoltar' ,'#divBotoes').show();

				cDtmvtolt.val(aux_dtmvtolt);
				cDtmvtolt.habilitaCampo();
				cDtmvtolt.focus();
				cCddopcao.desabilitaCampo();
			}else
			if (cCddopcao.val() == 'I') {
				incluirNovoRegistro();
			}
			return false;
		}
	});


	cDtmvtolt.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13) {
			btnOK2.prop('disabled',true);
			cDtmvtolt.desabilitaCampo();
			consultaDadosReafor();
			return false;
		}
	});


	cNrcpfcgc.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13) {
			btnOK3.prop('disabled',true);
			consultaContaAssocido();
			return false;
		}
	});


	cNrdconta.unbind('keypress').bind('keypress', function() {
		if ( e.keyCode == 9 || e.keyCode == 13) {
			consultaContratoAssocido();
			return false;
		}
    });


	cNrctremp.unbind('keypress').bind('keypress', function() {
		if ( e.keyCode == 9 || e.keyCode == 13) {
			gravarRegistro(idrowid===undefined ? '' : idrowid);
			return false;
		}
    });

	return false;
}


// Botoes da Tela
function btnIncluir() {
	gravarRegistro(idrowid===undefined ? '' : idrowid);
    return false;
}


function btnAlterar() {

	// Nenhum registro foi selecionado
	if (idrowid === undefined) {return false;}

	// Desabilita os botoes
	btnOK.prop('disabled',true);
	btnOK2.prop('disabled',true);
	btnOK3.prop('disabled',true);

	retornaRegistro(idrowid);
	return false;
}

function btnExcluir() {

	// Nenhum registro foi selecionado
	if (idrowid === undefined) {return false;}

	showConfirmacao("Confirma a exclus&atilde;o do registro?","Confirma&ccedil;&atilde;o - Ayllos","excluirRegistro(idrowid);","idrowid = \'\';","sim.gif","nao.gif");
	return false;
}


function btnVoltar() {

	cCddopcao.val('C');
	cDtmvtolt.val('');
	cNrcpfcgc.val('');
	cNmprimtl.val('');
	cNrdconta.val('');
	cNrctremp.val('');

	// Inicializa Variavel
	idrowid = '';

	btnOK.prop('disabled',false);
	btnOK2.prop('disabled',false);
	btnOK3.prop('disabled',false);
	$('#nrdconta','#frmCab').empty();
	$('#nrctremp','#frmCab').empty();
	$('input,select','#frmCab').removeClass('campoErro');
	$('#divConteudo').css({'display':'none'});
	estadoInicial();
	return false;
}


// Requisi&ccedil;&otilde;es da Tela


/* Monta tabela de dados REAFOR */
function consultaDadosReafor() {

    var dtmvtolt = cDtmvtolt.val();

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando dados ...");

	$.ajax({
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/reafor/consulta_dados_reafor.php",
		data: {
			dtmvtolt : dtmvtolt,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function(response) {
			hideMsgAguardo();
			try {
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						$('input,select','#frmCab').removeClass('campoErro');
						$("#divConteudo").html(response);
						formataTabela();
						$('#btAlterar','#divBotoes').show();
						$('#btExcluir','#divBotoes').show();
					} catch(error) {
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
					}
				} else {
					try {
						eval(response);
					} catch(error) {
						hideMsgAguardo();
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
					}
				}
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));");
			}
		}
	});
}


/* Consulta contas do Associado */
function consultaContaAssocido() {

	cNrcpfcgc.desabilitaCampo();
    var nrcpfcgc = cNrcpfcgc.val();

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando contas ...");

	$.ajax({
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/reafor/consulta_contas_associ.php",
		data: {
			nrcpfcgc : nrcpfcgc,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function(response) {
			hideMsgAguardo();
		    try {
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						$('input,select','#frmCab').removeClass('campoErro');
						cNrdconta.habilitaCampo();
						eval(response);
					} catch(error) {
						hideMsgAguardo();
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')));");
					}
				} else {
					try {
						eval(response);
					} catch(error) {
						hideMsgAguardo();
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')));estadoInicial();");
					}
				}
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));");
			}
		}
	});

	return false;
}


/* Consulta contratos relacionado a conta informada */
function consultaContratoAssocido() {

	$('#nrctremp','#frmCab').empty();
	cNrcpfcgc.desabilitaCampo();
	var nrdconta = cNrdconta.val();

	// Exibe no campo de contrato TODOS os contratos
	if (nrdconta == 'TODAS') {
	   $('#btIncluir','#divBotoes').show();
	   $('#nrctremp','#frmCab').append('<option value="0">TODOS</option>');
	   cNrctremp.habilitaCampo();
	   cNrctremp.focus();
	   return false;
	}

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando contratos ...");

	$.ajax({
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/reafor/consulta_contrato_associ.php",
		data: {
			nrdconta : nrdconta,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function(response) {
		    hideMsgAguardo();
			try {
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						$('#btIncluir','#divBotoes').show();
						cNrctremp.habilitaCampo();
						cNrctremp.focus();
						eval(response);
					} catch(error) {
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
					}
				} else {
					try {
						eval(response);
					} catch(error) {
						hideMsgAguardo();
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
					}
				}
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));");
			}
		}
	});

	return false;
}


/* Grava o registro de reabilitacao */
function gravarRegistro(rowid) {

	var nrcpfcgc = cNrcpfcgc.val();

	if (cNrdconta.val() == 'TODAS') {
		var nrdconta = 0;
	}else{
		var nrdconta = cNrdconta.val();
	}

	if (cNrctremp.val() == 'TODOS') {
		var nrctremp = 0;
	}else{
		var nrctremp = cNrctremp.val();
	}

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, gravando dados ...");

	$.ajax({
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/reafor/inserir_dados_reafor.php",
		data: {
			nrcpfcgc : nrcpfcgc,
			nrdconta : nrdconta,
			nrctremp : nrctremp,
			rowid    : rowid,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function(response) {
		    hideMsgAguardo();
			try {
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						if (rowid=='') {
						   idrowid = '';
						   showError("inform","Inclus&atilde;o de registro efetuada com sucesso!","Alerta - Ayllos","incluirNovoRegistro();");
						} else {
						   idrowid = '';
						   showError("inform","Atualiza&ccedil;&atilde;o do registro foi efetuada com sucesso!","Alerta - Ayllos","btnVoltar();");
						}
						eval(response);
					} catch(error) {
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
					}
				} else {
					try {
						eval(response);
					} catch(error) {
						hideMsgAguardo();
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
					}
				}
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}
	});

	return false;
}


/* Exclui os registros selecionados */
function excluirRegistro(rowid) {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, excluindo registro ...");

	$.ajax({
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/reafor/excluir_dados_reafor.php",
		data: {
			rowid    : rowid,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function(response) {
			hideMsgAguardo();
		    try {
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
					    idrowid = '';
						showError("inform","Exclus&atilde;o do registro foi efetuada com sucesso!","Alerta - Ayllos","consultaDadosReafor();");
						eval(response);
					} catch(error) {
						hideMsgAguardo();
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')));");
					}
				} else {
					try {
						eval(response);
					} catch(error) {
						hideMsgAguardo();
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')));estadoInicial();");
					}
				}
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));");
			}
		}
	});

	return false;
}


/* Retorna o registro para atualizar */
function retornaRegistro(rowid) {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, buscando dados...");

	$.ajax({
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/reafor/retorna_dados_reafor.php",
		data: {
			rowid    : rowid,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function(response) {
			hideMsgAguardo();
		    try {
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						$('#nrdconta','#frmCab').empty();
						$('#nrctremp','#frmCab').empty();
						$('input,select','#frmCab').removeClass('campoErro');
						$('#divConsulta').css({'display':'none'});
						$('#divRegistros').css({'display':'none'});
						$('#divConteudo').css({'display':'none'});
						$('#divIncluir').css({'display':'block'});

						cNrdconta.habilitaCampo();

						$('#btIncluir','#divBotoes').hide();
						$('#btAlterar','#divBotoes').hide();
						$('#btExcluir','#divBotoes').hide();
						$('#btnVoltar','#divBotoes').hide();
						eval(response);
					} catch(error) {
						hideMsgAguardo();
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')));");
					}
				} else {
					try {
						eval(response);
					} catch(error) {
						hideMsgAguardo();
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')));estadoInicial();");
					}
				}
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}
	});
	return false;
}


// Formata Tabela
function formataTabela() {

    $('input[type="text"],select','#frmCab').desabilitaCampo();
    $('#divConteudo').css({'display':'block'});

    var divRegistro = $('div.divRegistros', '#tabDados');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

    $('#tabDados').css({'margin-top':'1px'});
	divRegistro.css({'height':'370px','padding-bottom':'1px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '50px';
	arrayLargura[1] = '75px';
	arrayLargura[2] = '247px';
	arrayLargura[3] = '114px';
	arrayLargura[4] = '280px';
    arrayLargura[5] = '85px';
    arrayLargura[6] = '74px';
	arrayLargura[7] = '15px';

	var arrayAlinha = new Array();
        arrayAlinha[0] = 'center';
        arrayAlinha[1] = 'center';
        arrayAlinha[2] = 'left';
        arrayAlinha[3] = 'center';
        arrayAlinha[4] = 'left';
        arrayAlinha[5] = 'center';
        arrayAlinha[6] = 'center';

	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	hideMsgAguardo();

	/* Atribuindo o foco para a linha da tabela, pois ao clicar no cabecalho nao retornava
	para linha da tabela, dessa maneira a tela apresentava erro na hora de alterar ou
	excluir o registro selecionado */

	$('table > thead > tr > th', divRegistro).unbind('click').bind('click', function() {
		$('table > tbody > tr > td', divRegistro).focus();
	});

	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		selecionaTabela($(this));
	});

    // seleciona o registro que é focado
	$('table > tbody > tr', divRegistro).focus( function() {
		selecionaTabela($(this));
	});

	$('table > tbody > tr:eq(0)', divRegistro).click();
	return false;
}


function selecionaTabela(tr) {
	/* Variavel Global que recebera o ROWID
	do campo selecionado para ser alterado
	ou excluido */

    idrowid = $('#chk', tr).val();
	return false;
}


function incluirNovoRegistro() {
	btnOK.prop('disabled',true);
	btnOK3.prop('disabled',false);

	$('#divIncluir').css({'display':'block'});

    $('#divBotoes').css({'display':'block'});

	$('#btVoltar' ,'#divBotoes').show();
	
	cNrcpfcgc.val('');
	cNmprimtl.val('');
	cNrdconta.val('');
	cNrctremp.val('');
	
	$('#nrdconta','#frmCab').empty();
	$('#nrctremp','#frmCab').empty();

	cNrcpfcgc.habilitaCampo();
	cNrcpfcgc.focus();
	cNmprimtl.desabilitaCampo();
	cNrdconta.desabilitaCampo();
	cNrctremp.desabilitaCampo();
	cCddopcao.desabilitaCampo();
	
}


function controlaLayout() {

	atualizaSeletor();
	formataCabecalho();

	cDtmvtolt.val('');
	layoutPadrao();
	return false;
}
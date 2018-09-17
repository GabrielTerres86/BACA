/*!
 * FONTE        : traesp.js
 * CRIAÇÃO      : Fabricio
 * DATA CRIAÇÃO : 24/02/2012
 * OBJETIVO     : Biblioteca de funções da tela TRAESP
 * --------------
 * ALTERAÇÕES   : 04/07/2012 - Retirado ajax de reimprimeControle() e imprimeListagemTransacoes() e passado para submeter em funcao executaImpressao(). (Jorge)	
 * --------------
 */
 
var cddopcao = '';

var rCddopcao, rNrdconta, rDtmvtolt, rCdagenci, rDatamvto, rTpdocmto, rCodagenc, rCdbccxlt, rNrdolote, rNrdocmto, rCdageint, rNrdcaixa, rNrdocint, rContacor,
	cCddopcao, cNrdconta, cDtmvtolt, cCdagenci, cDatamvto, cTpdocmto, cCodagenc, cCdbccxlt, cNrdolote, cNrdocmto, cCdageint, cNrdcaixa, cNrdocint, cContacor;
	
var lstCooperativas = new Array();
var lstRelatorios   = new Array();
var lstDadosFechamento;
var lstRegistro = new Array();

var cdcooper, nmrescop, cdopecxa, nrdcaixa, nrseqaut, nrdctabb, tpoperac;

var carregouOpcoes = false;

var flgconfirma = false;

var glb_id = -1;


$(document).ready(function() {
	
	estadoInicial();
	
	controlaNavegacao();
		
});

function controlaNavegacao() {

	cCddopcao.unbind('keypress').bind('keypress', function(e) {
		if (divError.css('display') == 'block') { return false; }
		// Se é a tecla ENTER
		if (e.keyCode == 13) {
			setaOpcao();
			return false;
		}
	});
	
	cNrdconta.unbind('keypress').bind('keypress', function(e) {
		if (divError.css('display') == 'block') { return false; }
		// Se é a tecla ENTER
		if (e.keyCode == 13) {
			cDtmvtolt.focus();
			return false;
		}
	});
	
	cDtmvtolt.unbind('keypress').bind('keypress', function(e) {
		if (divError.css('display') == 'block') { return false; }
		// Se é a tecla ENTER
		if (e.keyCode == 13) {
			consultaTransacoes(1, 50);
			return false;
		}
	});
	
	cCdagenci.unbind('keypress').bind('keypress', function(e) {
		if (divError.css('display') == 'block') { return false; }
		// Se é a tecla ENTER
		if (e.keyCode == 13) {
			consultaTransacoesPac(1, 50);
			return false;
		}
	});
	
	cDatamvto.unbind('keypress').bind('keypress', function(e) {
		if (divError.css('display') == 'block') { return false; }
		// Se é a tecla ENTER
		if (e.keyCode == 13) {
			cTpdocmto.focus();
			return false;
		}
	});
	
	cTpdocmto.unbind('keypress').bind('keypress', function(e) {
		if (divError.css('display') == 'block') { return false; }
		// Se é a tecla ENTER
		if (e.keyCode == 13) {
		
			if (cTpdocmto.val() == 4)
				cCdageint.focus();
			else
			if (cTpdocmto.val() != "")
				cCodagenc.focus();
				
			return false;
		}
	});
	
	cCodagenc.unbind('keypress').bind('keypress', function(e) {
		if (divError.css('display') == 'block') { return false; }
		// Se é a tecla ENTER
		if (e.keyCode == 13) {
			cCdbccxlt.focus();
			return false;
		}
	});
	
	cCdbccxlt.unbind('keypress').bind('keypress', function(e) {
		if (divError.css('display') == 'block') { return false; }
		// Se é a tecla ENTER
		if (e.keyCode == 13) {
			cNrdolote.focus();
			return false;
		}
	});
	
	cNrdolote.unbind('keypress').bind('keypress', function(e) {
		if (divError.css('display') == 'block') { return false; }
		// Se é a tecla ENTER
		if (e.keyCode == 13) {
			cNrdocmto.focus();
			return false;
		}
	});
	
	cContacor.unbind('keypress').bind('keypress', function(e) {
		if (divError.css('display') == 'block') { return false; }
		// Se é a tecla ENTER
		if (e.keyCode == 13) {
			consultaControleMovimentacao();
			return false;
		}
	});
	
	cCdageint.unbind('keypress').bind('keypress', function(e) {
		if (divError.css('display') == 'block') { return false; }
		// Se é a tecla ENTER
		if (e.keyCode == 13) {
			cNrdcaixa.focus();
			return false;
		}
	});
	
	cNrdcaixa.unbind('keypress').bind('keypress', function(e) {
		if (divError.css('display') == 'block') { return false; }
		// Se é a tecla ENTER
		if (e.keyCode == 13) {
			cNrdocint.focus();
			return false;
		}
	});
	
	cNrdocint.unbind('keypress').bind('keypress', function(e) {
		if (divError.css('display') == 'block') { return false; }
		// Se é a tecla ENTER
		if (e.keyCode == 13) {
			consultaControleMovimentacao();
			return false;
		}
	});
	
	cNmrescop.unbind('keypress').bind('keypress', function(e) {
		if (divError.css('display') == 'block') { return false; }
		// Se é a tecla ENTER
		if (e.keyCode == 13) {
			consultaDadosFechamento();
			return false;
		}
	});

}


// seletores
function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);
	
	fechaRotina( $('#divRotina') );
	
	cddopcao = "";
	
	controlaLayout();

	if (!carregouOpcoes)
		carregaOpcoes(cdcooper);
	
	cCddopcao.val(cddopcao);
	
	removeOpacidade('divTela');
	
	highlightObjFocus( $('#frmCab') );
	
	cCddopcao.focus();
	
	return false;
	
}

function carregaOpcoes(cdcooper) {
	
	if (cdcooper == 3) {
		$('#cddopcao','#frmCab').append("<option value='F'>F - Fechamento</option>");
		$('#cddopcao','#frmCab').append("<option value='S'>S - SISBACEN</option>");
	} else {
		$('#cddopcao','#frmCab').append("<option value='C'>C - Consultar Transa&ccedil;&otilde;es em Esp&eacute;cie</option>");
		$('#cddopcao','#frmCab').append("<option value='I'>I - Imprimir</option>");
		$('#cddopcao','#frmCab').append("<option value='P'>P - Listar Transa&ccedil;&otilde;es sem Documento</option>");
	}
	
	carregouOpcoes = true;

}

function setaOpcao() {
	
	if ( divError.css('display') == 'block' ) { return false; }		
		if ( cCddopcao.hasClass('campoTelaSemBorda') ) { return false; }
		
		cddopcao = cCddopcao.val();
		if ( cddopcao == '' ) { return false; }
				
		controlaLayout();
		
		if (cddopcao != "S")
			cCddopcao.desabilitaCampo();

}

function controlaLayout() {

	rCddopcao			= $('label[for="cddopcao"]'	,'#frmCab');
	
	rNrdconta           = $('label[for="nrdconta"]'	,'#frmConsulta');
	rDtmvtolt           = $('label[for="dtmvtolt"]'	,'#frmConsulta');
	
	rCdagenci           = $('label[for="cdagenci"]' ,'#frmConsultaPac');
	
	rDatamvto           = $('label[for="dtmvtolt"]' ,'#frmReimprimeControle');
	rTpdocmto           = $('label[for="tpdocmto"]' ,'#frmReimprimeControle');
	
	rCodagenc           = $('label[for="cdagenci"]' ,'#divCampos');
	rCdbccxlt           = $('label[for="cdbccxlt"]' ,'#divCampos');
	rNrdolote           = $('label[for="nrdolote"]' ,'#divCampos');
	rNrdocmto           = $('label[for="nrdocmto"]' ,'#divCampos');
	
	rContacor           = $('label[for="nrdconta"]' ,'#divCamposOutros');
	
	rCdageint           = $('label[for="cdageint"]' ,'#divCamposIntercoop');
	rNrdcaixa           = $('label[for="nrdcaixa"]' ,'#divCamposIntercoop');
	rNrdocint           = $('label[for="nrdocint"]' ,'#divCamposIntercoop');
	
	rNmrescop           = $('label[for="nmrescop"]' ,'#divConfirmaSisbacen');
	
	cCddopcao			= $('#cddopcao'	,'#frmCab');
	
	cNrdconta			= $('#nrdconta'	,'#frmConsulta');
	cDtmvtolt			= $('#dtmvtolt'	,'#frmConsulta');
	
	cCdagenci           = $('#cdagenci' ,'#frmConsultaPac');
	
	cDatamvto           = $('#dtmvtolt' ,'#frmReimprimeControle');
	cTpdocmto           = $('#tpdocmto' ,'#frmReimprimeControle');
	
	cCodagenc           = $('#cdagenci' ,'#divCampos');
	cCdbccxlt           = $('#cdbccxlt' ,'#divCampos');
	cNrdolote           = $('#nrdolote' ,'#divCampos');
	cNrdocmto           = $('#nrdocmto' ,'#divCampos');
	
	cContacor           = $('#nrdconta' ,'#divCamposOutros');
	
	cCdageint           = $('#cdageint' ,'#divCamposIntercoop');
	cNrdcaixa           = $('#nrdcaixa' ,'#divCamposIntercoop');
	cNrdocint           = $('#nrdocint' ,'#divCamposIntercoop');
	
	cNmrescop           = $('#nmrescop' ,'#divConfirmaSisbacen');
	
	
	rCddopcao.addClass('rotulo').css({'width':'68px','margin-left':'70px'});
	cCddopcao.css({'width':'456px'});
	
	$('#divConsulta').css({'display':'none'});
	$('#divConsultaPac').css({'display':'none'});
	$('#divReimprimeControle').css({'display':'none'});
	$('#divConfirmaSisbacen').css({'display':'none'});
	$('#divRegistros').css({'display':'none'});
	
	if (cddopcao == 'C') {
	
		$('#divDadosConsulta').html("");
	
		rNrdconta.addClass('rotulo').css({'width':'50px','margin-left':'230px'});
		rDtmvtolt.addClass('rotulo-linha').css({'width':'40px'});
		
		cNrdconta.addClass('rotulo').css({'width':'70px'}).setMask("INTEGER","zzzz.zzz-z","","");
		
		cDtmvtolt.addClass('data').css({'width':'70px'});	
		
		cNrdconta.habilitaCampo();
		cDtmvtolt.habilitaCampo();
		
		cNrdconta.limpaFormulario();
		cDtmvtolt.limpaFormulario();
		
		$('#divConsulta').css({'display':'block'});
		
		highlightObjFocus( $('#frmConsulta') );
		
		cNrdconta.focus();
		
	} else if (cddopcao == 'P') {
		
		$('#divDadosConsultaPac').html("");
		
		rCdagenci.addClass('rotulo').css({'margin-left':'325px'});
		
		cCdagenci.addClass('rotulo').css({'width':'40px'}).setMask("INTEGER","zzz","","");
		
		cCdagenci.habilitaCampo();
				
		cCdagenci.limpaFormulario();
				
		$('#divConsultaPac').css({'display':'block'});
		
		highlightObjFocus( $('#frmConsultaPac') );
		
		cCdagenci.focus();
		
	} else if (cddopcao == 'I') {
	
		$('#divDadosMovimentacao').html("");
		
		rDatamvto.addClass('rotulo').css({'width':'50px','margin-left':'150px'});
		rTpdocmto.addClass('rotulo-linha').css({'width':'120px'});
		
		cDatamvto.addClass('data').css({'width':'70px'});
		cTpdocmto.addClass('rotulo').css({'width':'150px'});
		
		cCodagenc.setMask("INTEGER","zzz","","");
		cCdbccxlt.setMask("INTEGER","zzz","","");
		cNrdolote.setMask("INTEGER","zzz.zzz",".","");
		cNrdocmto.setMask("INTEGER","zz.zzz.zzz",".","");
		
		cContacor.setMask("INTEGER","zzzz.zzz-z",".-","");
	
		cCdageint.setMask("INTEGER","zzz","","");
		cNrdcaixa.setMask("INTEGER","zzz","","");
		cNrdocint.setMask("INTEGER","zz.zzz.zzz",".","");
		
		cDatamvto.limpaFormulario();
		cTpdocmto.limpaFormulario();
		cTpdocmto.val("");
		
		//cDatamvto.habilitaCampo();
		
		$('input,select','#divReimprimeControle').habilitaCampo();
		$('#lupaPesq','#divReimprimeControle').prop('disabled',false);
		
		trocaBotao("Prosseguir");
		
		$('#divCampos').css({'display':'none'});
		$('#divCamposOutros').css({'display':'none'});
		$('#divCamposIntercoop').css({'display':'none'});
		$('#divReimprimeControle').css({'display':'block'});
		
		highlightObjFocus( $('#frmReimprimeControle') );
		
		cDatamvto.focus();
		
	} else if (cddopcao == "S") {
	
		imprimeListagemTransacoes();
		
	} else if (cddopcao == "F") {
		
		$('#divDadosConfirmaSisbacen').html("");
		
		$("#divDadosConfirmaSisbacen").css("height","5px");
		
		rNmrescop.addClass('rotulo').css({'margin-left':'240px'});
		
		cNmrescop.addClass('rotulo').css({'width':'150px'});
		
		carregaCoops();
		
	}
	
	cCddopcao.habilitaCampo();
		
	layoutPadrao();
	return false;

}

function consultaTransacoes(nriniseq, nrregist) {
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, consultando transa&ccedil;&otilde;es em esp&eacute;cie ...");
	
	var nrdconta = retiraCaracteres($("#nrdconta","#frmConsulta").val(),"0123456789",true);
	var dtmvtolt = $('#dtmvtolt','#frmConsulta').val();
	
	// Executa script de consulta através de ajax
	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/traesp/exibe_dados_consulta.php", 
		data: {
			nrdconta: nrdconta,
			dtmvtolt: dtmvtolt,
			nriniseq: nriniseq,
			nrregist: nrregist,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divDadosConsulta').html(response);
					formataTabela("#divDadosConsulta");
					$('#divPesquisaRodape1').formataRodapePesquisa();
				} catch(error) {
					showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
				}
			} else {
				try {
					eval( response );
				} catch(error) {
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
				}
			}
		}				
	});

}

function consultaTransacoesPac(nriniseq, nrregist) {
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, consultando transa&ccedil;&otilde;es em esp&eacute;cie ...");
	
	var cdagenci = $('#cdagenci','#frmConsultaPac').val();
	
	if (cdagenci == 0 || cdagenci == "") {
		hideMsgAguardo();
		showError("error","PA não informado.","Alerta - Ayllos","cCdagenci.focus();",false);
		return false;
	}
	
	// Executa script de consulta através de ajax
	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/traesp/exibe_dados_consulta_pac.php", 
		data: {
			cdagenci: cdagenci,
			nriniseq: nriniseq,
			nrregist: nrregist,
			redirect: "html_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divDadosConsultaPac').html(response);
					formataTabela("#divDadosConsultaPac");
					$('#divPesquisaRodape2').formataRodapePesquisa();
				} catch(error) {
					showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
				}
			} else {
				try {
					eval( response );
				} catch(error) {
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
				}
			}
		}				
	});

}

function consultaControleMovimentacao() {
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, consultando controles de movimenta&ccedil;&atilde;o ...");
	
	$('#divDadosMovimentacao').html("");
	
	var dtmvtolt = $('#dtmvtolt','#frmReimprimeControle').val();
	var nrdconta = 0;
	
	if (dtmvtolt == "") {
		hideMsgAguardo();
		showError("error","Data não informada.","Alerta - Ayllos","cDatamvto.focus();",false);
		return false;
	}
	
	if (cTpdocmto.val() >= 0 && cTpdocmto.val() <= 3 && (!cTpdocmto.val() == "")) {
	
		var cdagenci = $('#cdagenci','#frmReimprimeControle').val();
		var cdbccxlt = retiraCaracteres($('#cdbccxlt','#frmReimprimeControle').val(),"0123456789",true);
		var nrdolote = retiraCaracteres($('#nrdolote','#frmReimprimeControle').val(),"0123456789",true);
		var nrdocmto = retiraCaracteres($('#nrdocmto','#frmReimprimeControle').val(),"0123456789",true);
		
		if ((!validaNumero(cdagenci,true,0,0)) || (cdagenci == "")) {
			hideMsgAguardo();
			showError("error","PA inválido ou não informado.","Alerta - Ayllos","cCodagenc.focus();",false);
			return false;
		}
		
		if ((!validaNumero(cdbccxlt,true,0,0)) || (cdbccxlt == "")) {
			hideMsgAguardo();
			showError("error","Banco/caixa inválido ou não informado.","Alerta - Ayllos","cCdbccxlt.focus();",false);
			return false;
		}
		
		if ((!validaNumero(nrdolote,true,0,0)) || (nrdolote == "")) {
			hideMsgAguardo();
			showError("error","Lote inválido ou não informado.","Alerta - Ayllos","cNrdolote.focus();",false);
			return false;
		}
		
		if ((!validaNumero(nrdocmto,true,0,0)) || (nrdocmto == "")) {
			hideMsgAguardo();
			showError("error","Documento inválido ou não informado.","Alerta - Ayllos","cNrdocmto.focus();",false);
			return false;
		}
		
		if (cTpdocmto.val() == 0) {
		
			nrdconta = retiraCaracteres($('#nrdconta','#frmReimprimeControle').val(),"0123456789",true);
		
			if ((!validaNumero(nrdconta,true,0,0)) || (nrdconta == "")) {
				hideMsgAguardo();
				showError("error","Conta/dv inválida ou não informada.","Alerta - Ayllos","cContacor.focus();",false);
				return false;
			}
		}
		
	} else {
		
		var cdagenci = $('#cdageint','#frmReimprimeControle').val();
			nrdcaixa = retiraCaracteres($('#nrdcaixa','#frmReimprimeControle').val(),"0123456789",true);
		var nrdocmto = retiraCaracteres($('#nrdocint','#frmReimprimeControle').val(),"0123456789",true);
		var nrdolote = 11000 + parseInt(nrdcaixa);
		var cdbccxlt = 11;
		
		if ((!validaNumero(cdagenci,true,0,0)) || (cdagenci == "")) {
			hideMsgAguardo();
			showError("error","PA inválido ou não informado.","Alerta - Ayllos","cCdageint.focus();",false);
			return false;
		}
		
		if ((!validaNumero(nrdcaixa,true,0,0)) || (nrdcaixa == "")) {
			hideMsgAguardo();
			showError("error","Caixa inválido ou não informado.","Alerta - Ayllos","cNrdcaixa.focus();",false);
			return false;
		}
		
		if ((!validaNumero(nrdocmto,true,0,0)) || (nrdocmto == "")) {
			hideMsgAguardo();
			showError("error","Documento inválido ou não informado.","Alerta - Ayllos","cNrdocint.focus();",false);
			return false;
		}
	}
	
	
	// Executa script de consulta através de ajax
	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/traesp/exibe_dados_controle_movimentacao.php", 
		data: {
			dtmvtolt: dtmvtolt,
			cdagenci: cdagenci,
			cdbccxlt: cdbccxlt,
			nrdolote: nrdolote,
			nrdocmto: nrdocmto,
			nrdconta: nrdconta,
			redirect: "html_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divDadosMovimentacao').html(response);
					formataTabela("#divDadosMovimentacao");
					
					if ($('#divDadosMovimentacao').html() != "") {
						trocaBotao('Imprimir');
						$('input,select','#divReimprimeControle').desabilitaCampo();
						$('#lupaPesq','#divReimprimeControle').prop('disabled',true);
					}
				} catch(error) {
					showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
				}
			} else {
				try {
					eval( response );
				} catch(error) {
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
				}
			}
		}				
	});

}

function formataTabela(nmdivform) {

	/*****************************
			FORMATA TABELA		
	******************************/
	// tabela	
	var divDados = $('div.divRegistros', nmdivform);		
	var tabela      = $('table', divDados );
	var linha       = $('table > tbody > tr', divDados );
			
	divDados.css({'height':'140px'});
	
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];
	
	var arrayLargura = new Array();
	arrayLargura[0] = '29px';
	arrayLargura[1] = '45px';
	arrayLargura[2] = '64px';
	arrayLargura[3] = '84px';
	arrayLargura[4] = '70px';
	arrayLargura[5] = '67px';
	arrayLargura[6] = '88px';
	arrayLargura[7] = '65px';
	arrayLargura[8] = '40px';
	
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'left';
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'right';
	arrayAlinha[6] = 'center';
	arrayAlinha[7] = 'left';
	arrayAlinha[8] = 'left';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha );
	
}

function habilitaCampos() {
	
	if (cTpdocmto.val() >= 0 && cTpdocmto.val() <= 3 && (!cTpdocmto.val() == "")) {
		
		if (cTpdocmto.val() == 0)
			rCodagenc.addClass('rotulo').css({'margin-left':'50px'});
		else
			rCodagenc.addClass('rotulo').css({'margin-left':'100px'});
			
		rCdbccxlt.addClass('rotulo-linha').css({'margin-left':'10px'});
		rNrdolote.addClass('rotulo-linha').css({'margin-left':'10px'});
		rNrdocmto.addClass('rotulo-linha').css({'margin-left':'10px'});
		
		if (cTpdocmto.val() == 0) {
			rContacor.addClass('rotulo-linha').css({'margin-left':'10px'});
			
			cNrdocmto.unbind('keypress').bind('keypress', function(e) {
				if (divError.css('display') == 'block') { return false; }
				// Se é a tecla ENTER
				if (e.keyCode == 13) {
					cContacor.focus();
					return false;
				}
			});
			
		} else {
			cNrdocmto.unbind('keypress').bind('keypress', function(e) {
				if (divError.css('display') == 'block') { return false; }
				// Se é a tecla ENTER
				if (e.keyCode == 13) {
					consultaControleMovimentacao();
					return false;
				}
			});
		}
		
		cCodagenc.addClass('rotulo').css({'width':'40px'});
		cCdbccxlt.addClass('rotulo-linha').css({'width':'40px'});
		cNrdolote.addClass('rotulo-linha').css({'width':'60px'});
		cNrdocmto.addClass('rotulo-linha').css({'width':'70px'});
		
		if (cTpdocmto.val() == 0)
			cContacor.addClass('rotulo-linha').css({'width':'70px'});
		
		var cCampos = $('input','#divCampos');
		
		cCampos.limpaFormulario();
		cCampos.habilitaCampo();
		
		if (cTpdocmto.val() == 0) {
			cContacor.limpaFormulario();
			cContacor.habilitaCampo();
		}
		
		$('#divCamposIntercoop').css({'display':'none'});
		$('#divCampos').css({'display':'block'});
		
		if (cTpdocmto.val() == 0)
			$('#divCamposOutros').css({'display':'block'});
		else
			$('#divCamposOutros').css({'display':'none'});
		
		$('#divBotaoOK').css({'display':'block'});
		
	} else if (cTpdocmto.val() == 4) {
	
		rCdageint.addClass('rotulo').css({'margin-left':'180px'});
		rNrdcaixa.addClass('rotulo-linha').css({'margin-left':'10px'});
		rNrdocint.addClass('rotulo-linha').css({'margin-left':'10px'});
		
		cCdageint.addClass('rotulo').css({'width':'40px'});
		cNrdcaixa.addClass('rotulo-linha').css({'width':'40px'});
		cNrdocint.addClass('rotulo-linha').css({'width':'75px'});
		
		var cCamposInter = $('input','#divCamposIntercoop');
		
		cCamposInter.limpaFormulario();
		cCamposInter.habilitaCampo();
		
		$('#divCampos').css({'display':'none'});
		$('#divCamposOutros').css({'display':'none'});
		$('#divCamposIntercoop').css({'display':'block'});
		$('#divBotaoOK').css({'display':'block'});
		
	} else {
		$('#divCampos').css({'display':'none'});
		$('#divCamposOutros').css({'display':'none'});
		$('#divCamposIntercoop').css({'display':'none'});
		$('#divBotaoOK').css({'display':'none'});
	}
	
	cTpdocmto.focus();
	
}

function reimprimeControle() {
	
	if ($('#divDadosMovimentacao').html() == "") return false;			
	executaImpressao("true");
	
}

function imprimeListagemTransacoes() {
	
	executaImpressao("false");
	
}

function executaImpressao(reimpressao){

	$('#sidlogin','#frmImpressao').remove();
	$('#frmImpressao').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '"/>');	
	
	if (reimpressao == "true"){
		
		var dtmvtolt = $('#dtmvtolt','#frmReimprimeControle').val();
		
		if (cTpdocmto.val() >= 0 && cTpdocmto.val() <= 3 && (!cTpdocmto.val() == "")) {
			var cdagenci = $('#cdagenci','#frmReimprimeControle').val();
			var cdbccxlt = $('#cdbccxlt','#frmReimprimeControle').val();
			var nrdolote = $('#nrdolote','#frmReimprimeControle').val();
			var nrdocmto = $('#nrdocmto','#frmReimprimeControle').val();
			
		} else {
			var cdagenci = $('#cdageint','#frmReimprimeControle').val();
			    nrdcaixa = $('#nrdcaixa','#frmReimprimeControle').val();
			var nrdocmto = $('#nrdocint','#frmReimprimeControle').val();
			var nrdolote = 11000 + parseInt(nrdcaixa);
			var cdbccxlt = 11;
		}
		
		$('#dtmvtolt','#frmImpressao').remove();
		$('#cdagenci','#frmImpressao').remove();
		$('#cdbccxlt','#frmImpressao').remove();
		$('#nrdolote','#frmImpressao').remove();
		$('#nrdocmto','#frmImpressao').remove();
		$('#nmrescop','#frmImpressao').remove();
		$('#cdopecxa','#frmImpressao').remove();
		$('#nrseqaut','#frmImpressao').remove();
		$('#nrdctabb','#frmImpressao').remove();
		$('#tpoperac','#frmImpressao').remove();
		$('#nrdcaixa','#frmImpressao').remove();
		
		$('#frmImpressao').append('<input type="hidden" id="dtmvtolt" name="dtmvtolt" value="'+dtmvtolt+'"/>');
		$('#frmImpressao').append('<input type="hidden" id="cdagenci" name="cdagenci" value="'+cdagenci+'"/>');
		$('#frmImpressao').append('<input type="hidden" id="cdbccxlt" name="cdbccxlt" value="'+cdbccxlt+'"/>');
		$('#frmImpressao').append('<input type="hidden" id="nrdolote" name="nrdolote" value="'+nrdolote+'"/>');
		$('#frmImpressao').append('<input type="hidden" id="nrdocmto" name="nrdocmto" value="'+nrdocmto+'"/>');
		$('#frmImpressao').append('<input type="hidden" id="nmrescop" name="nmrescop" value="'+nmrescop+'"/>');
		$('#frmImpressao').append('<input type="hidden" id="cdopecxa" name="cdopecxa" value="'+cdopecxa+'"/>');
		$('#frmImpressao').append('<input type="hidden" id="nrseqaut" name="nrseqaut" value="'+nrseqaut+'"/>');
		$('#frmImpressao').append('<input type="hidden" id="nrdctabb" name="nrdctabb" value="'+nrdctabb+'"/>');
		$('#frmImpressao').append('<input type="hidden" id="tpoperac" name="tpoperac" value="'+tpoperac+'"/>');
		$('#frmImpressao').append('<input type="hidden" id="nrdcaixa" name="nrdcaixa" value="'+nrdcaixa+'"/>');
		
		var action = UrlSite + "telas/traesp/reimprime_controle_movimentacao.php";
	}else{
		var action = UrlSite + "telas/traesp/imprime_listagem_transacoes.php";
	}	
	
	carregaImpressaoAyllos("frmImpressao",action);
}

function carregaCoops() {
	
	// Executa script de consulta através de ajax
	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/traesp/carrega_coops.php", 
		data: {
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});

}

function carregaCooperativas(qtdCooperativas){
	
	for (var i = 0; i < qtdCooperativas; i++)
		$('option','#frmConfirmaSisbacen').remove();
		
	cNmrescop.append("<option id=0 value=3>TODAS</option>");
	
	for (var i = 1; i <= qtdCooperativas; i++)
		cNmrescop.append("<option id='"+i+"' value='"+lstCooperativas[i - 1].cdcooper+"'>"+lstCooperativas[i - 1].nmrescop+"</option>");

}

function consultaDadosFechamento() {
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, consultando dados para o fechamento ...");
	
	var cdcooper = $('#nmrescop','#frmConfirmaSisbacen').val();
	
	// Executa script de consulta através de ajax
	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/traesp/dados_fechamento_sisbacen.php", 
		data: {
			cdcooper: cdcooper,
			redirect: "html_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});

}

function formataTabelaFechamento() {
	
	// tabela	
	var divRegistro = $('div.divRegistros', '#divDadosConfirmaSisbacen');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'140px'});
	
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];
	
	var arrayLargura = new Array();
	
	arrayLargura[0] = '12px';
	arrayLargura[1] = '69px';   //coop
	arrayLargura[2] = '59px';	//pac
	arrayLargura[3] = '88px';	//conta
	arrayLargura[4] = '99px';	//documento
	arrayLargura[5] = '80px';	//operacao
	arrayLargura[6] = '90px';	//valor
	arrayLargura[7] = '54px';	//coaf

	
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'left';
	arrayAlinha[6] = 'right';
	arrayAlinha[7] = 'left';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha );
	
	// complemento
	var complemento  = $('ul.complemento', '#divDadosConfirmaSisbacen');
	
	$('li:eq(0)', complemento).addClass('txtNormalBold');
	$('li:eq(1)', complemento).addClass('txtNormal').css({'width':'70%'});
	$('li:eq(2)', complemento).addClass('txtNormalBold');
	$('li:eq(3)', complemento).addClass('txtNormal').css({'width':'11%'});
	$('li:eq(4)', complemento).addClass('txtNormalBold');
	$('li:eq(5)', complemento).addClass('txtNormal').css({'width':'5%'});
	$('li:eq(6)', complemento).addClass('txtNormalBold');
	$('li:eq(7)', complemento).addClass('txtNormal').css({'width':'20%'});
	$('li:eq(8)', complemento).addClass('txtNormalBold');
	$('li:eq(9)', complemento).addClass('txtNormal').css({'width':'30%'});
	$('li:eq(10)', complemento).addClass('txtNormalBold');
	
	$("#justific","#divDadosConfirmaSisbacen").addClass('rotulo-linha').css({'width':'78%'});
	$("#justific","#divDadosConfirmaSisbacen").limpaFormulario();
	$("#justific","#divDadosConfirmaSisbacen").desabilitaCampo();
}

// Função para seleção do registro para fechamento do SISBACEN
function selecionaRegistro(id,qtRegistros) {
	
	// Formata cor da linha da tabela que lista os registros para fechamento do SISBACEN
	for (var i = 0; i < qtRegistros; i++) {		
		
		if (i == id) {
			
			$("#tdNmprimtl").html(lstDadosFechamento[id].nmprimtl);
			$("#tdDtmvtolt").html(lstDadosFechamento[id].dtmvtolt);
			$("#tdFlinfdst").html(lstDadosFechamento[id].flinfdst);
			$("#tdRecursos").html(lstDadosFechamento[id].recursos);
			$("#tdDstrecur").html(lstDadosFechamento[id].dstrecur);
		}
	}
}

function marcaTodos(qtdregis) {

	var cFlgtodos   = $("#chktodos","#divDadosConfirmaSisbacen");
		
	cFlgtodos.unbind("click").bind("click",function() {
		for (i = 0; i < qtdregis; i++)
			$('#appreg' + i,'#divDadosConfirmaSisbacen').prop('checked',cFlgtodos.prop('checked'));	
	});
	
	showConfirmacao("Todos os registros ser&atilde;o atualizados. Confirma a opera&ccedil;&atilde;o?","Confirma&ccedil;&atilde;o - Ayllos","confirmaDadosSisbacen('-1','false');","desmarcaTodos(" + qtdregis + ");","sim.gif","nao.gif");
}

function desmarcaTodos(qtdregis) {

	$("#chktodos","#divDadosConfirmaSisbacen").prop('checked', false);
	
	for (i = 0; i < qtdregis; i++)
		$('#appreg' + i,'#divDadosConfirmaSisbacen').prop('checked',false);

}

function verificaInfoCoaf(id, qtdregis) {

	glb_id = id;

	showConfirmacao("Opera&ccedil;&atilde;o deve ser informada ao COAF?","Confirma&ccedil;&atilde;o - Ayllos","confirmaDadosSisbacen(" + id + ",'true');","desabilitaSelecao(" + qtdregis + ");","sim.gif","nao.gif");

}

function desabilitaSelecao(qtdregis) {

	$("#chktodos","#divDadosConfirmaSisbacen").prop('disabled', true);

	for (i = 0; i < qtdregis; i++)
		$('#appreg' + i,'#divDadosConfirmaSisbacen').prop('disabled',true);
	
	informaJustificativa(qtdregis);

}

function habilitaSelecao(qtdregis) {

	$("#chktodos","#divDadosConfirmaSisbacen").prop('disabled', false);

	for (i = 0; i < qtdregis; i++)
		$('#appreg' + i,'#divDadosConfirmaSisbacen').prop('disabled',false);

}

function confirmaDadosSisbacen(id, informaCoaf) {

	if (informaCoaf)
		showMsgAguardo("Aguarde, confirmando dados no Sisbacen ...");
	else
		showMsgAguardo("Aguarde, carregando dados para justificativa ...");
	
	var cdcooper = $('#nmrescop','#frmConfirmaSisbacen').val();
	var justific = $('#justifica','#divInfoTransacao').val();
	
	if (id == -1) {
		var camposPc = '';
		var dadosPrc = '';
	
		camposPc = retornaCampos(lstDadosFechamento, '|');
		dadosPrc = retornaValores(lstDadosFechamento, ';', '|', camposPc);
	} else {
		
		id = glb_id;
		
		if (!informaCoaf) {
			if (justific == "") {
				hideMsgAguardo();
				showError("error","Justificativa não informada.","Alerta - Ayllos","$('#justifica','#divInfoTransacao').focus();",false);
				return false;
			}
		}
		
		if (lstRegistro == "")
			lstRegistro = new Array();
		
		var campos = new Object();
		campos["cdcooper"] = lstDadosFechamento[id].cdcooper;
		campos["cdagenci"] = lstDadosFechamento[id].cdagenci;
		campos["nrdconta"] = lstDadosFechamento[id].nrdconta;
		campos["dtmvtolt"] = lstDadosFechamento[id].dtmvtolt;
		campos["nrdocmto"] = lstDadosFechamento[id].nrdocmto;
		
		lstRegistro.push(campos);
		
		var camposPc = '';
		var dadosPrc = '';
	
		camposPc = retornaCampos(lstRegistro, '|');
		dadosPrc = retornaValores(lstRegistro, ';', '|', camposPc);
		
	}
	
	// Executa script de consulta através de ajax
	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/traesp/efetua_confirmacao_dados_sisbacen.php", 
		data: {
			cdcooper: cdcooper,
			identifi: id,
			infoCoaf: informaCoaf,
			justific: justific,
			camposPc: camposPc,
			dadosPrc: dadosPrc,
			redirect: "html_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					eval(response);
					fechaRotina($('#divRotina'));
					showError("inform","Registro(s) atualizado(s) com sucesso!","Alerta - Ayllos","consultaDadosFechamento();");

				} catch(error) {
					showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
				}
			} else {
				try {
					eval( response );
				} catch(error) {
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
				}
			}
		}				
	});

}

function trocaBotao(botao) {
	
	$('#divBotoes','#frmReimprimeControle').html("");
	$('#divBotoes','#frmReimprimeControle').append('<a href="#" class="botao" id="btVoltar" onclick="estadoInicial(); return false;">Voltar</a>');

	if (botao == "Prosseguir")
		$('#divBotoes','#frmReimprimeControle').append('<a href="#" class="botao" id="btProsseguir" onclick="consultaControleMovimentacao(); return false;" >' + botao + '</a>');
	else
	if (botao == "Imprimir")
		$('#divBotoes','#frmReimprimeControle').append('<a href="#" class="botao" id="btnImprimir" onclick="reimprimeControle(); return false;" >' + botao + '</a>');
		
	return false;
}

function informaJustificativa(qtdregis) {
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, consultando transa&ccedil;&otilde;es em esp&eacute;cie ...");
	
	// Executa script de consulta através de ajax
	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/traesp/form_justificativa.php", 
		data: {
			qtdregis: qtdregis,
			redirect: "html_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divRotina').html(response);
					exibeRotina($('#divRotina'));
					formataDadosJustificativa();
					carregaInformacoes();
				} catch(error) {
					showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
				}
			} else {
				try {
					eval( response );
				} catch(error) {
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
				}
			}
		}				
	});

}

function formataDadosJustificativa() {

	var complemento = '#divInfoTransacao';
	
	$('li:eq(0)', complemento).addClass('txtNormalBold').css({'margin-left':'20px'});
	$('li:eq(1)', complemento).addClass('txtNormal').css({'width':'5%'});
	$('li:eq(2)', complemento).addClass('txtNormalBold').css({'margin-left':'60px'});
	$('li:eq(3)', complemento).addClass('txtNormal').css({'width':'5%'});
	$('li:eq(4)', complemento).addClass('txtNormalBold').css({'margin-left':'38px'});
	$('li:eq(5)', complemento).addClass('txtNormal').css({'width':'10%'});
	$('li:eq(6)', complemento).addClass('txtNormalBold').css({'margin-left':'12px'});
	$('li:eq(7)', complemento).addClass('txtNormal').css({'width':'42%'});
	$('li:eq(8)', complemento).addClass('txtNormalBold').css({'margin-left':'104px'});
	$('li:eq(9)', complemento).addClass('txtNormal').css({'width':'7%'});
	$('li:eq(10)', complemento).addClass('txtNormalBold');
	$('li:eq(11)', complemento).addClass('txtNormal').css({'width':'12%'});
	$('li:eq(12)', complemento).addClass('txtNormalBold');
	$('li:eq(13)', complemento).addClass('txtNormal').css({'width':'12%'});
	$('li:eq(14)', complemento).addClass('txtNormalBold');
	$('li:eq(15)', complemento).addClass('txtNormal').css({'width':'20%'});
	$('li:eq(16)', complemento).addClass('txtNormalBold');
	$('li:eq(17)', complemento).addClass('txtNormal').css({'width':'5%'});
	$('li:eq(18)', complemento).addClass('txtNormalBold').css({'margin-left':'28px'});
	$('li:eq(19)', complemento).addClass('txtNormal').css({'width':'25%'});
	$('li:eq(20)', complemento).addClass('txtNormalBold').css({'margin-left':'14px'});
	$('li:eq(21)', complemento).addClass('txtNormal').css({'width':'25%'});
	$('li:eq(22)', complemento).addClass('txtNormalBold');
	
	
	$("#justifica",complemento).addClass('rotulo-linha').css({'width':'99%'}).setMask("STRING",100,charPermitido(),"");;
	$("#justifica",complemento).limpaFormulario();
	
	$("#justifica",complemento).unbind('keypress').bind('keypress', function(e) {
		if (divError.css('display') == 'block') { return false; }
		// Se é a tecla ENTER
		if (e.keyCode == 13) {
			confirmaDadosSisbacen(0,false);
			return false;
		}
	});

}

function carregaInformacoes() {
	
	$("#cdcooper","#Complemento").html(lstDadosFechamento[glb_id].cdcooper);
	$("#cdagenci","#Complemento").html(lstDadosFechamento[glb_id].cdagenci);
	$("#nrdconta","#Complemento").html(lstDadosFechamento[glb_id].nrdconta);
	$("#nmprimtl","#Complemento").html(lstDadosFechamento[glb_id].nmprimtl);
	$("#nrdocmto","#Complemento").html(lstDadosFechamento[glb_id].nrdocmto);
	$("#tpoperac","#Complemento").html(lstDadosFechamento[glb_id].tpoperac);
	$("#vllanmto","#Complemento").html(number_format(lstDadosFechamento[glb_id].vllanmto.replace(",","."), 2, ",","."));
	$("#dtmvtolt","#Complemento").html(lstDadosFechamento[glb_id].dtmvtolt);
	$("#flinfdst","#Complemento").html(lstDadosFechamento[glb_id].flinfdst);
	$("#recursos","#Complemento").html(lstDadosFechamento[glb_id].recursos);
	$("#dstrecur","#Complemento").html(lstDadosFechamento[glb_id].dstrecur);
	
	highlightObjFocus($('#divInfoTransacao'));
	$('#justifica','#divInfoTransacao').habilitaCampo(); 
	$('#justifica','#divInfoTransacao').focus();
	

}

function controlaPesquisa() {
	
	var bo, procedure, titulo, qtReg, filtros, colunas, cdagenci, titulo_coluna, cdagencis, nmresage;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmConsultaPac';
	
	var cdagenci = $('#cdagenci','#'+nomeFormulario).val();
	cdagencis = cdagenci;
	nmresage = '';
	
	titulo_coluna = "Descricao";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-pacs';
	titulo      = 'Agência PA';
	qtReg		= '20';
	
	filtros 	= 'Cód. PA;cdagenci;30px;S;' + cdagenci + ';S|Agência PA;nmresage;200px;S;' + nmresage + ';N';
	colunas 	= 'Codigo;cdagenci;20%;right|' + titulo_coluna + ';nmresage;50%;left';
		
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cdagenci\',\'#frmInfConsulta\').val()');
	
	return false;

}
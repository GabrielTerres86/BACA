/*!
 * FONTE        : icfjud.js
 * CRIAÇÃO      : Fabricio
 * DATA CRIAÇÃO : 28/02/2013
 * OBJETIVO     : Biblioteca de funções da tela ICFJUD
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
 
var cddopcao = '';

var rCddopcao, rNrdconta, rCdbandes, rCdagedes, rNrctades, rDacaojud, rDtinireq, rCdbancon, rCdagecon, rNrctacon, rDsdocmc7,
	cCddopcao, cNrdconta, cCdbandes, cCdagedes, cNrctades, cDacaojud, cDtinireq, cCdbancon, cCdagecon, cNrctacon, cDsdocmc7;

var btnOK, linkConta, cCampos;

var nrdconta = 0;

var lstDadosICF;

var dtinireq, intipreq, cdbanreq, cdagereq, nrctareq, dsdocmc7;


$(document).ready(function() {
	
	estadoInicial();
		
});


// seletores
function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);
	
	fechaRotina( $('#divRotina') );
	
	cddopcao = "";
	
	controlaLayout();
	
	cCddopcao.val(cddopcao);
	
	removeOpacidade('divTela');
	
	return false;
	
}

function controlaLayout() {
	
	rCddopcao			= $('label[for="cddopcao"]'	,'#frmCab');
	
	btnOK				= $('#btnOK','#frmCab');
	
	rNrdconta           = $('label[for="nrdconta"]'	,'#frmInclusao');
	rCdbandes           = $('label[for="cdbandes"]' ,'#frmInclusao');
	rCdagedes           = $('label[for="cdagedes"]' ,'#frmInclusao');
	rNrctades           = $('label[for="nrctades"]' ,'#frmInclusao');
	rDacaojud           = $('label[for="dacaojud"]' ,'#frmInclusao');
	rTpdconta        	= $('label[for="tpdconta"]' ,'#frmInclusao');
	rDtdtroca        	= $('label[for="dtdtroca"]' ,'#frmInclusao');
	rVldopera        	= $('label[for="vldopera"]' ,'#frmInclusao');
	rDsdocmc7Inc        = $('label[for="dsdocmc7"]' ,'#frmInclusao');
	
	rDtinireq           = $('label[for="dtinireq"]'	,'#frmConsulta');
	rCdbancon           = $('label[for="cdbancon"]' ,'#frmConsulta');
	rIntipreq           = $('label[for="intipreq"]' ,'#frmConsulta');
	rCdagecon           = $('label[for="cdagecon"]' ,'#frmConsulta');
	rNrctacon           = $('label[for="nrctacon"]' ,'#frmConsulta');
	rDsdocmc7           = $('label[for="dsdocmc7"]' ,'#frmConsulta');
	
	cCddopcao			= $('#cddopcao'	,'#frmCab');
	
	cNrdconta			= $('#nrdconta'	,'#frmInclusao');
	cNmprimtl           = $('#nmprimtl' ,'#frmInclusao');
	cCdbandes           = $('#cdbandes' ,'#frmInclusao');
	cCdagedes           = $('#cdagedes' ,'#frmInclusao');
	cNrctades           = $('#nrctades' ,'#frmInclusao');
	cDacaojud           = $('#dacaojud' ,'#frmInclusao');
	cTpdconta        	= $('#tpdconta' ,'#frmInclusao');
	cDtdtroca        	= $('#dtdtroca' ,'#frmInclusao');
	cVldopera        	= $('#vldopera' ,'#frmInclusao');	
	cDsdocmc7Inc        = $('#dsdocmc7' ,'#frmInclusao');
	
	cDtinireq           = $('#dtinireq'	,'#frmConsulta');
	cCdbancon           = $('#cdbancon' ,'#frmConsulta');
	cIntipreq           = $('#intipreq' ,'#frmConsulta');
	cCdagecon           = $('#cdagecon' ,'#frmConsulta');
	cNrctacon           = $('#nrctacon' ,'#frmConsulta');
	cDsdocmc7           = $('#dsdocmc7' ,'#frmConsulta');
	
	cCampos             = $('input' ,'#frmInclusao,#frmConsulta');
	
	linkConta           = $('a:eq(0)','#frmInclusao,#frmConsulta');
	
	rCddopcao.addClass('rotulo').css({'width':'60px'});
	cCddopcao.css({'width':'605px'});
	
	$('#divInclusao').css({'display':'none'});
	$('#divConsulta').css({'display':'none'});
	$('#divDadosConsulta').css({'display':'none'});
	
	if (cddopcao == 'I') {
	
		highlightObjFocus($('#frmInclusao'));
	
		rNrdconta.addClass('rotulo').css({'width':'77px'});
		rCdbandes.addClass('rotulo').css({'width':'123px'});
		rCdagedes.addClass('rotulo-linha').css({'width':'60px'});
		rNrctades.addClass('rotulo-linha').css({'width':'50px'});
		rDacaojud.addClass('rotulo').css({'width':'123px'});
		rTpdconta.addClass('rotulo').css({'width':'123px'});
		rDtdtroca.addClass('rotulo').css({'width':'123px'});
		rVldopera.addClass('rotulo').css({'width':'123px'});
		rDsdocmc7Inc.addClass('rotulo').css({'width':'123px'});
		
		cNrdconta.addClass('conta pesquisa').css({'width':'80px'});
		cNmprimtl.addClass('descricao').css({'width':'317px'});
		cCdbandes.addClass('rotulo').css({'width':'60px'});
		cCdagedes.addClass('rotulo-linha');
		cNrctades.addClass('rotulo');
		cTpdconta.addClass('campo').css({'width':'140px'});
		cDtdtroca.addClass('data').css({'width':'80px'});
		cVldopera.addClass('moeda'); // .setMask('DECIMAL', 'zzz.zzz.zzz,zz', '', '')
		cDsdocmc7Inc.addClass('campo').css({'width':'260px'});
		
		cDsdocmc7Inc.unbind('keyup').bind('keyup', function(e) {
			formataCampoCmc7(false);
			return false;
		});
		cDsdocmc7Inc.unbind('blur').bind('blur', function(e) {
			formataCampoCmc7(true);
			return false;
		});		
		
		cDsdocmc7Inc.unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }		
		
			// Se é a tecla ENTER, 
			if ( e.keyCode == 13 ) {
				incluiICF();
				return false;

			}
		});		
		
		
		if ($.browser.msie) {
			cCdagedes.css({'width':'60px'});
			cNrctades.css({'width':'100px'});
		} else {
			cCdagedes.css({'width':'57px'});
			cNrctades.css({'width':'97px'});
		}
		
		cDacaojud.addClass('rotulo').css({'width':'228px'});
		
		
		cCampos.habilitaCampo();
		cCampos.limpaFormulario();
		cCampos.removeClass('campoErro');
		
		$('#divInclusao').css({'display':'block'});
		
		cNrdconta.focus();
		
	} else if (cddopcao == 'C') {
	
		highlightObjFocus($('#frmConsulta'));
	
		rDtinireq.addClass('rotulo').css({'width':'125px'});
		rCdbancon.addClass('rotulo-linha').css({'width':'120px'});
		rIntipreq.addClass('rotulo-linha').css({'width':'50px'});
		rCdagecon.addClass('rotulo').css({'width':'125px'});
		rNrctacon.addClass('rotulo-linha').css({'width':'120px'});
		rDsdocmc7.addClass('rotulo').css({'width':'125px'});
		
		cDtinireq.addClass('data').css({'width':'72px'});
		cCdbancon.addClass('rotulo-linha').css({'width':'70px'});
		cCdagecon.addClass('rotulo').css({'width':'72px'});
		cNrctacon.addClass('rotulo-linha').css({'width':'70px'});
		cDsdocmc7.addClass('rotulo-linha').css({'width':'260px'});
		
		cCampos.habilitaCampo();
		cCampos.limpaFormulario();
		$("#intipreq","#frmConsulta").val(1);
		$('#btnImprimir','#frmConsulta').remove();
	
		$('#divConsulta').css({'display':'block'});
		
		cDtinireq.focus();
	
	}
	
	cCddopcao.habilitaCampo();
	
	cCddopcao.unbind('change').bind('change', function() { 	
		cddopcao = cCddopcao.val();
		return false;

	});	
		
	// Se clicar no botao OK
	btnOK.unbind('click').bind('click', function() { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( cCddopcao.hasClass('campoTelaSemBorda') ) { return false; }
		
		// Armazena o número da conta na variável global
		cddopcao = cCddopcao.val();
		if ( cddopcao == '' ) { return false; }

				
		controlaLayout();
		
		cCddopcao.desabilitaCampo();
		
		return false;
			
	});
	
	if ( linkConta.prev().hasClass('campoTelaSemBorda') ) {
		linkConta.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {
		linkConta.css('cursor','pointer').unbind('click').bind('click', function() {	
			if (cddopcao == 'I')
				mostraPesquisaAssociado('nrdconta','frmInclusao');
			else if (cddopcao == 'C')
				mostraPesquisaAssociado('contacon','frmConsulta');
		});
	}
	
	layoutPadrao();
	return false;

}

function consultaInicial() { 	
	
	if ( divError.css('display') == 'block' ) { return false; }
	if( $('#nrdconta','#frmInclusao').hasClass('campoTelaSemBorda') ){ return false; }
	
	cNmprimtl.val("");
				
	// Armazena o número da conta na variável global e operacao
	nrdconta = normalizaNumero( $('#nrdconta','#frmInclusao').val() );
	
	// Verifica se o número da conta é vazio
	if ( nrdconta == '' ) { return false; }
		
	// Verifica se a conta é válida
	if ( !validaNroConta(nrdconta) ) { 
		showError('error','Conta/dv inválida.','Alerta - ICFJUD','focaCampoErro(\'nrdconta\',\'frmInclusao\');'); 
		return false; 
	}
	
	cNrdconta.removeClass('campoErro');
	
	buscaCooperado();
	
};

function buscaCooperado() {
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, buscando nome do cooperado ...");
	
	// Executa script de consulta através de ajax
	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/icfjud/busca_cooperado.php", 
		data: {
			nrdconta: nrdconta,
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

function incluiICF() {
	
	nrdconta = normalizaNumero( $('#nrdconta','#frmInclusao').val() );
	var nmprimtl = $("#nmprimtl","#frmInclusao").val();
	var cdbandes = retiraCaracteres($("#cdbandes","#frmInclusao").val(),"0123456789",true);
	var cdagedes = retiraCaracteres($("#cdagedes","#frmInclusao").val(),"0123456789",true);
	var nrctades = retiraCaracteres($("#nrctades","#frmInclusao").val(),"0123456789",true);
	var dacaojud = $("#dacaojud","#frmInclusao").val();
	var dsdocmc7 = $("#dsdocmc7","#frmInclusao").val();
	var tpdconta = $("#tpdconta","#frmInclusao").val();
	var dtdtroca = $("#dtdtroca","#frmInclusao").val();
	var vldopera = $("#vldopera","#frmInclusao").val();
	
	if (nrdconta == '') {
		showError('error','Conta/dv n&atilde;o informada.','Alerta - ICFJUD','focaCampoErro(\'nrdconta\',\'frmInclusao\');');
		return false;
	}
	
	// Verifica se a conta é válida
	if ( !validaNroConta(nrdconta) ) { 
		showError('error','Conta/dv inv&aacute;lida.','Alerta - ICFJUD','focaCampoErro(\'nrdconta\',\'frmInclusao\');'); 
		return false; 
	}
	
	if (nmprimtl == '') {
		showError('error','Confirme o n&uacute;mero da conta.','Alerta - ICFJUD','focaCampoErro(\'btOK\',\'frmInclusao\');'); 
		return false;
	}
	
	cNrdconta.removeClass('campoErro');
	
	if (cdbandes == '') {
		showError('error','Banco destino n&atilde;o informado.','Alerta - ICFJUD','focaCampoErro(\'cdbandes\',\'frmInclusao\');');
		return false;
	}
	
	if (cdbandes == 85) {
		showError('error','Banco destino n&atilde;o pode ser o mesmo que o banco origem.','Alerta - ICFJUD','focaCampoErro(\'cdbandes\',\'frmInclusao\');');
		return false;
	}
	
	cCdbandes.removeClass('campoErro');
	
	if (cdagedes == '') {
		showError('error','Ag&ecirc;ncia destino n&atilde;o informada.','Alerta - ICFJUD','focaCampoErro(\'cdagedes\',\'frmInclusao\');');
		return false;
	}
	
	cCdagedes.removeClass('campoErro');
	
	if (nrctades == '') {
		showError('error','Conta destino n&atilde;o informada.','Alerta - ICFJUD','focaCampoErro(\'nrctades\',\'frmInclusao\');');
		return false;
	}
	
	cNrctades.removeClass('campoErro');
	
	if (dacaojud == '') {
		showError('error','Descri&ccedil;&atilde;o da a&ccedil;&atilde;o judicial n&atilde;o informada.','Alerta - ICFJUD','focaCampoErro(\'dacaojud\',\'frmInclusao\');');
		return false;
	}
	
	cDacaojud.removeClass('campoErro');
	
	if (tpdconta == '00'){
		showError('error','Selecione o tipo de conta.','Alerta - ICFJUD','focaCampoErro(\'tpdconta\',\'frmInclusao\');');
		return false;		
	}
		
	cTpdconta.removeClass('campoErro');	
		
	if (dtdtroca == '') {
		showError('error','Data da troca n&atilde;o informada.','Alerta - ICFJUD','focaCampoErro(\'dtdtroca\',\'frmInclusao\');');
		return false;
	}
	
	cDtdtroca.removeClass('campoErro');	
	
	if (vldopera == '') {
		showError('error','Valor da opera&ccedil;&atilde;o n&atilde;o informado.','Alerta - ICFJUD','focaCampoErro(\'vldopera\',\'frmInclusao\');');
		return false;
	}
	
	if (Number(vldopera.replace(",",".")) <= 0) {
		showError('error','Valor da opera&ccedil;&atilde;o informada deve ser maior que 0,00.','Alerta - ICFJUD','focaCampoErro(\'vldopera\',\'frmInclusao\');');
		return false;
	}
	
	cVldopera.removeClass('campoErro');	
	
	if (dsdocmc7 == '') {
		showError('error','CMC7 n&atilde;o informado.','Alerta - ICFJUD','focaCampoErro(\'dsdocmc7\',\'frmInclusao\');');
		return false;
	}	
	
	cDsdocmc7.removeClass('campoErro');	
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, incluindo ICF ...");
	
	// Executa script de consulta através de ajax
	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/icfjud/inclui_icf.php", 
		data: {
			nrdconta: nrdconta,
			cdbandes: cdbandes,
			cdagedes: cdagedes,
			nrctades: nrctades,
			dacaojud: dacaojud,
			cdoperad: cdoperad,
			dsdocmc7: dsdocmc7,
			tpdconta: tpdconta,
			dtdtroca: dtdtroca,
			vldopera: vldopera,
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

function reenviarICFs() {
	
	var nrctareq = null;
	var dacaojud = null;
	var chkReenviarICF = null;

	var nrsctareq = '';
	var listaacaojud = '';
	var qtdItensSelecionados = 0;

	for (var i = 0; i < lstDadosICF.length; i++)
	{
		var chkReenviarICF = $("#chkReenviarICF_" + i,"#trArquivosProcessados" + i);

		if (chkReenviarICF.prop('checked') == true) {
			nrctareq = $("#hddNrctareqICF_" + i,"#trArquivosProcessados" + i);
			dacaojud = $("#hddDacaojudICF_" + i,"#trArquivosProcessados" + i);
			if (nrsctareq == '') {
				nrsctareq = nrctareq.val();
				listaacaojud = dacaojud.val();
			}
			else
			{
				nrsctareq = nrsctareq + ';' + nrctareq.val();
				listaacaojud = listaacaojud + ';' + dacaojud.val();
			}

			qtdItensSelecionados = qtdItensSelecionados + 1;
		}
	}

	if (qtdItensSelecionados == 0) {
		showError('error','Nenhum registro selecionado.','Alerta - ICFJUD','');
		return false;
	}
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, reenviando ICFs selecionadas ...");
	
	// Executa script de consulta atrav?s de ajax
	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/icfjud/reenviar_icf.php", 
		data: {
			nrsctareq: nrsctareq,
			listaacaojud: listaacaojud,
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
	var arrayAlinha = new Array();

	if (cddopcao == 'I') {
		arrayLargura[0] = '70px';
		arrayLargura[1] = '70px';
		arrayLargura[2] = '70px';
		arrayLargura[3] = '70px';
		arrayLargura[4] = '70px';

	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'left';
		arrayAlinha[5] = 'left';
	}
	else
	{
		arrayLargura[0] = '15px';
		arrayLargura[1] = '70px';
		arrayLargura[2] = '70px';
		arrayLargura[3] = '70px';
		arrayLargura[4] = '70px';
		arrayLargura[5] = '70px';

		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'right';
		arrayAlinha[2] = 'right';
		arrayAlinha[3] = 'right';
		arrayAlinha[4] = 'right';
		arrayAlinha[5] = 'left';
		arrayAlinha[6] = 'left';
	}
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha );
			
	$('#divBotoes','#frmConsulta').append('<a href="#" class="botao" id="btnImprimir" name="btnImprimir" onClick="executaImpressao(); return false;">Imprimir</a>');
	
}

function consultaICF() {
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, consultando dados ICF ...");
	
	$('#divDadosConsulta').html("");
	$('#btnImprimir','#frmConsulta').remove();
	
	dtinireq = cDtinireq.val();
	intipreq = $("#intipreq","#frmConsulta").val();
	cdbanreq = cCdbancon.val();
	cdagereq = cCdagecon.val();
	nrctareq = cNrctacon.val();
	dsdocmc7 = cDsdocmc7.val();
	
	// Executa script de consulta através de ajax
	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/icfjud/consulta_icf.php", 
		data: {
			dtinireq: dtinireq,
			intipreq: intipreq,
			cdbanreq: cdbanreq,
			cdagereq: cdagereq,
			nrctareq: nrctareq,
			dsdocmc7: dsdocmc7,
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

function executaImpressao() {
	
	var camposPc = '';
	camposPc = retornaCampos(lstDadosICF, '|');
	
	var dadosPrc = '';
	dadosPrc = retornaValores(lstDadosICF, ';', '|', camposPc);
	
	$('#sidlogin','#frmImpressao').remove();
	$('#dtinireq','#frmImpressao').remove();
	$('#intipreq','#frmImpressao').remove();
	$('#cdbanreq','#frmImpressao').remove();
	$('#cdagereq','#frmImpressao').remove();
	$('#nrctareq','#frmImpressao').remove();
	$('#camposPc','#frmImpressao').remove();
	$('#dadosPrc','#frmImpressao').remove();
	
	$('#frmImpressao').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '"/>');	
	$('#frmImpressao').append('<input type="hidden" id="dtinireq" name="dtinireq" value="'+dtinireq+'"/>');
	$('#frmImpressao').append('<input type="hidden" id="intipreq" name="intipreq" value="'+intipreq+'"/>');
	$('#frmImpressao').append('<input type="hidden" id="cdbanreq" name="cdbanreq" value="'+cdbanreq+'"/>');
	$('#frmImpressao').append('<input type="hidden" id="cdagereq" name="cdagereq" value="'+cdagereq+'"/>');
	$('#frmImpressao').append('<input type="hidden" id="nrctareq" name="nrctareq" value="'+nrctareq+'"/>');
	$('#frmImpressao').append('<input type="hidden" id="camposPc" name="camposPc" value="'+camposPc+'"/>');
	$('#frmImpressao').append('<input type="hidden" id="dadosPrc" name="dadosPrc" value="'+dadosPrc+'"/>');
		
	var action = UrlSite + "telas/icfjud/imprime_icf.php";
	
	carregaImpressaoAyllos("frmImpressao",action);
}

function formataCampoCmc7(exitCampo){
	var mask   = '<zzzzzzzz<zzzzzzzzzz>zzzzzzzzzzzz:';
	var indice = 0;
	var valorAtual = cDsdocmc7Inc.val();
	var valorNovo  = '';
	
	if ( valorAtual == '' ){
		return false;
	}
	
	if ( exitCampo && valorAtual.length < 34) {
		showError('error','Valor do CMC-7 inv&aacute;lido.','Alerta - Aimaro','cDsdocmc7Inc.focus();');
	}
	
	//remover os caracteres de formatação
	valorAtual = valorAtual.replace(/[^0-9]/g, "").substr(0,30);
	
	for ( var x = 0;  x < valorAtual.length; x++ ) {
				
		//verifica se é um separador da máscara
		if (mask.charAt(indice) != 'z'){
			valorNovo = valorNovo.concat(mask.charAt(indice));
			indice++;
		}
		valorNovo = valorNovo.concat(valorAtual.charAt(x));		
		indice++;
	}
	
	// verifica se o valor digitado possui 30 caracteres sem formatação
	if ( valorAtual.length == 30 ){
		// Adiciona o ultimo caracter da máscara
		valorNovo = valorNovo.concat(':');
	}
	
	cDsdocmc7Inc.val(valorNovo);
}

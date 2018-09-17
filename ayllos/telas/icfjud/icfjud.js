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

var rCddopcao, rNrdconta, rCdbandes, rCdagedes, rNrctades, rDacaojud, rDtinireq, rCdbancon, rCdagecon, rNrctacon,
	cCddopcao, cNrdconta, cCdbandes, cCdagedes, cNrctades, cDacaojud, cDtinireq, cCdbancon, cCdagecon, cNrctacon;

var btnOK, linkConta, cCampos;

var nrdconta = 0;

var lstDadosICF;

var dtinireq, intipreq, cdbanreq, cdagereq, nrctareq;


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
	
	rDtinireq           = $('label[for="dtinireq"]'	,'#frmConsulta');
	rCdbancon           = $('label[for="cdbancon"]' ,'#frmConsulta');
	rIntipreq           = $('label[for="intipreq"]' ,'#frmConsulta');
	rCdagecon           = $('label[for="cdagecon"]' ,'#frmConsulta');
	rNrctacon           = $('label[for="nrctacon"]' ,'#frmConsulta');
	
	cCddopcao			= $('#cddopcao'	,'#frmCab');
	
	cNrdconta			= $('#nrdconta'	,'#frmInclusao');
	cNmprimtl           = $('#nmprimtl' ,'#frmInclusao');
	cCdbandes           = $('#cdbandes' ,'#frmInclusao');
	cCdagedes           = $('#cdagedes' ,'#frmInclusao');
	cNrctades           = $('#nrctades' ,'#frmInclusao');
	cDacaojud           = $('#dacaojud' ,'#frmInclusao');
	
	cDtinireq           = $('#dtinireq'	,'#frmConsulta');
	cCdbancon           = $('#cdbancon' ,'#frmConsulta');
	cIntipreq           = $('#intipreq' ,'#frmConsulta');
	cCdagecon           = $('#cdagecon' ,'#frmConsulta');
	cNrctacon           = $('#nrctacon' ,'#frmConsulta');
	
	cCampos             = $('input' ,'#frmInclusao,#frmConsulta');
	
	linkConta           = $('a:eq(0)','#frmInclusao,#frmConsulta');
	
	rCddopcao.addClass('rotulo').css({'width':'60px'});
	cCddopcao.css({'width':'430px'});
	
	$('#divInclusao').css({'display':'none'});
	$('#divConsulta').css({'display':'none'});
	$('#divDadosConsulta').css({'display':'none'});
	
	if (cddopcao == 'I') {
	
		highlightObjFocus($('#frmInclusao'));
	
		rNrdconta.addClass('rotulo').css({'width':'60px'});
		rCdbandes.addClass('rotulo').css({'width':'60px'});
		rCdagedes.addClass('rotulo-linha').css({'width':'115px'});
		rNrctades.addClass('rotulo-linha').css({'width':'121px'});
		rDacaojud.addClass('rotulo').css({'width':'60px'});
		
		cNrdconta.addClass('conta pesquisa').css({'width':'80px'});
		cNmprimtl.addClass('descricao').css({'width':'330px'});
		cCdbandes.addClass('rotulo').css({'width':'60px'});
		cCdagedes.addClass('rotulo-linha');
		cNrctades.addClass('rotulo-linha');
		
		if ($.browser.msie) {
			cCdagedes.css({'width':'60px'});
			cNrctades.css({'width':'100px'});
		} else {
			cCdagedes.css({'width':'57px'});
			cNrctades.css({'width':'97px'});
		}
		
		cDacaojud.addClass('rotulo').css({'width':'238px'});
		
		
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
		
		cDtinireq.addClass('data').css({'width':'72px'});
		cCdbancon.addClass('rotulo-linha').css({'width':'70px'});
		cCdagecon.addClass('rotulo').css({'width':'72px'});
		cNrctacon.addClass('rotulo-linha').css({'width':'70px'});
		
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
	
	if (nrdconta == '') {
		showError('error','Conta/dv não informada.','Alerta - ICFJUD','focaCampoErro(\'nrdconta\',\'frmInclusao\');');
		return false;
	}
	
	// Verifica se a conta é válida
	if ( !validaNroConta(nrdconta) ) { 
		showError('error','Conta/dv inválida.','Alerta - ICFJUD','focaCampoErro(\'nrdconta\',\'frmInclusao\');'); 
		return false; 
	}
	
	if (nmprimtl == '') {
		showError('error','Confirme o número da conta.','Alerta - ICFJUD','focaCampoErro(\'btOK\',\'frmInclusao\');'); 
		return false;
	}
	
	cNrdconta.removeClass('campoErro');
	
	if (cdbandes == '') {
		showError('error','Banco destino não informado.','Alerta - ICFJUD','focaCampoErro(\'cdbandes\',\'frmInclusao\');');
		return false;
	}
	
	if (cdbandes == 85) {
		showError('error','Banco destino não pode ser o mesmo que o banco origem.','Alerta - ICFJUD','focaCampoErro(\'cdbandes\',\'frmInclusao\');');
		return false;
	}
	
	cCdbandes.removeClass('campoErro');
	
	if (cdagedes == '') {
		showError('error','Agência destino não informada.','Alerta - ICFJUD','focaCampoErro(\'cdagedes\',\'frmInclusao\');');
		return false;
	}
	
	cCdagedes.removeClass('campoErro');
	
	if (nrctades == '') {
		showError('error','Conta destino não informada.','Alerta - ICFJUD','focaCampoErro(\'nrctades\',\'frmInclusao\');');
		return false;
	}
	
	cNrctades.removeClass('campoErro');
	
	if (dacaojud == '') {
		showError('error','Descrição da ação judicial não informada.','Alerta - ICFJUD','focaCampoErro(\'dacaojud\',\'frmInclusao\');');
		return false;
	}
	
	cDacaojud.removeClass('campoErro');
	
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
	arrayLargura[0] = '100px';
	arrayLargura[1] = '72px';
	arrayLargura[2] = '123px';
	arrayLargura[3] = '115px';
	arrayLargura[4] = '83px';
	
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'left';
	
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
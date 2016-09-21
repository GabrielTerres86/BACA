/*!
 * FONTE        : reltar.js
 * CRIAÇÃO      : Daniel Zimmermann 
 * DATA CRIAÇÃO : 13/03/2013
 * OBJETIVO     : Biblioteca de funções da tela RELTAR
 * --------------
 * ALTERAÇÕES   : 15/08/2013 - Alteração da sigla PAC para PA (Carlos)
 * -----------------------------------------------------------------------
 */

//Formulários e Tabela
var frmCab   		= 'frmCab';
var frmReltar       = 'frmReltar';

//Labels/Campos do cabeçalho
var rInpessoa, rTprelato, rCdhistor, rCdmotest, rCdcooper, rCdagenci, rNrdconta, rDtinicio, rDtafinal, rCdhisest, 
	cInpessoa, cTprelato, cCdhistor, cCdmotest, cCdcooper, cCdagenci, cNrdconta, cDtinicio, cDtafinal, cCdhisest,
	cDshistor, cDshisest, cDsmotest, cNmrescop, cNmresage, cNmprimtl, cGlbcoope, cCddgrupo, cCdsubgru, cDsdgrupo,
	cDssubgru, rCddgrupo, rCdsubgru, rFlgresum, cFlgresum;

$(document).ready(function() {
	estadoInicial();
});

function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);
	
	hideMsgAguardo();		
	formataCabecalho();
	formataFrmReltar();
	controlaNavegacao();
	
	trocaBotao('Prosseguir');
	
	cTodosCabecalho.limpaFormulario().removeClass('campoErro');	

	highlightObjFocus( $('#frmCab') );
	highlightObjFocus( $('#frmReltar') );
	
	$('#frmCab').css({'display':'block'});
	$('#frmReltar').css({'display':'none'});
	$('#divBotoes').css({'display':'none'});
	
	cCdcooper.habilitaCampo();
	cInpessoa.habilitaCampo();
	cTprelato.habilitaCampo();
	cCdagenci.habilitaCampo();
	cNrdconta.habilitaCampo();
	cCdhistor.habilitaCampo();
	cCdhisest.habilitaCampo();
	cCddgrupo.habilitaCampo();
	cCdsubgru.habilitaCampo();
	cTprelato.val('1');
	cTprelato.focus();	
	removeOpacidade('divTela');
	
}

function formataCabecalho() {

	// Cabecalho
	rTprelato			= $('label[for="tprelato"]','#'+frmCab);	

	rTprelato.addClass('rotulo').css({'width':'100px'});
	
	cTprelato			= $('#tprelato','#'+frmCab);
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	
	cTprelato.addClass('campo').css({'width':'533px'});

	layoutPadrao();

	return false;
}


function formataFrmReltar() {

	// Cabecalho
	rInpessoa			= $('label[for="inpessoa"]','#'+frmReltar);
	
	rCddgrupo			= $('label[for="cddgrupo"]','#'+frmReltar);
	rCdsubgru			= $('label[for="cdsubgru"]','#'+frmReltar);
	
	rCdhistor			= $('label[for="cdhistor"]','#'+frmReltar);
	rCdhisest			= $('label[for="cdhisest"]','#'+frmReltar);
	rCdmotest			= $('label[for="cdmotest"]','#'+frmReltar);	
	rCdcooper			= $('label[for="cdcopaux"]','#'+frmReltar);
	rCdagenci			= $('label[for="cdagenci"]','#'+frmReltar);
	rNrdconta			= $('label[for="nrdconta"]','#'+frmReltar);
	rDtinicio			= $('label[for="dtinicio"]','#'+frmReltar); 
	rDtafinal			= $('label[for="dtafinal"]','#'+frmReltar);
	rFlgresum           = $('label[for="flgresum"]','#'+frmReltar);
	
	rInpessoa.addClass('rotulo').css({'width':'100px'});
	rCddgrupo.addClass('rotulo').css({'width':'100px'});
	rCdsubgru.addClass('rotulo').css({'width':'100px'});
	rCdhistor.addClass('rotulo').css({'width':'100px'});
	rCdhisest.addClass('rotulo').css({'width':'100px'});
	rCdmotest.addClass('rotulo').css({'width':'100px'});	
	rCdcooper.addClass('rotulo').css({'width':'100px'});
	rCdagenci.addClass('rotulo').css({'width':'100px'});
	rNrdconta.addClass('rotulo').css({'width':'100px'});
	rDtinicio.addClass('rotulo').css({'width':'100px'});
	rDtafinal.addClass('rotulo').css({'width':'100px'});
	rFlgresum.addClass('rotulo').css({'width':'100px'});
	
	cInpessoa			= $('#inpessoa','#'+frmReltar); 
	cCddgrupo			= $('#cddgrupo','#'+frmReltar); 
	cDsdgrupo			= $('#dsdgrupo','#'+frmReltar); 
	cCdsubgru			= $('#cdsubgru','#'+frmReltar); 
	cDssubgru			= $('#dssubgru','#'+frmReltar); 
	cCdhistor			= $('#cdhistor','#'+frmReltar);
	cDshistor			= $('#dshistor','#'+frmReltar);
	cCdhisest			= $('#cdhisest','#'+frmReltar);
	cDshisest			= $('#dshisest','#'+frmReltar);
	cCdmotest			= $('#cdmotest','#'+frmReltar);
	cDsmotest			= $('#dsmotest','#'+frmReltar);
	cCdcooper			= $('#cdcopaux','#'+frmReltar);
	cNmrescop			= $('#nmrescop','#'+frmReltar);
	cCdagenci			= $('#cdagenci','#'+frmReltar);
	cNmresage			= $('#nmresage','#'+frmReltar);
	cNrdconta			= $('#nrdconta','#'+frmReltar); 
	cDtinicio			= $('#dtinicio','#'+frmReltar);
	cDtafinal			= $('#dtafinal','#'+frmReltar); 
	cNmprimtl			= $('#nmprimtl','#'+frmReltar);
	cFlgresum           = $('#flgresum','#'+frmReltar);
	cGlbcoope			= $('#glbcoope','#frmCab');
	
	cInpessoa.addClass('campo').css({'width':'553px'});
	cCdhistor.addClass('inteiro campo').css({'width':'80px'}).attr('maxlength','5').setMask('INTEGER','zzzzz','','');
	cCddgrupo.addClass('inteiro campo').css({'width':'80px'}).attr('maxlength','5').setMask('INTEGER','zzzzz','','');
	cDsdgrupo.addClass('campo').css({'width':'450px'}).desabilitaCampo();
	cCdsubgru.addClass('inteiro campo').css({'width':'80px'}).attr('maxlength','5').setMask('INTEGER','zzzzz','','');
	cDssubgru.addClass('campo').css({'width':'450px'}).desabilitaCampo();
	cDshistor.addClass('campo').css({'width':'450px'}).desabilitaCampo();
	cCdhisest.addClass('inteiro campo').css({'width':'80px'}).attr('maxlength','5').setMask('INTEGER','zzzzz','','');
	cDshisest.addClass('campo').css({'width':'450px'}).desabilitaCampo();
	cCdmotest.addClass('inteiro campo').css({'width':'80px'}).attr('maxlength','5').setMask('INTEGER','zzzzz','','');
	cDsmotest.addClass('campo').css({'width':'450px'}).desabilitaCampo();
	cCdcooper.addClass('inteiro campo').css({'width':'80px'}).attr('maxlength','10').setMask('INTEGER','zzzzzzzzzz','','');
	cNmrescop.addClass('campo').css({'width':'450px'}).desabilitaCampo();
	cCdagenci.addClass('inteiro campo').css({'width':'80px'}).attr('maxlength','5').setMask('INTEGER','zzzzz','','');
	cNmresage.addClass('campo').css({'width':'450px'}).desabilitaCampo();
	cNrdconta.addClass('conta pesquisa campo').css({'width':'80px'});
	cNmprimtl.addClass('campo').css({'width':'450px'}).desabilitaCampo();
	cDtinicio.addClass('data campo').css({'width':'80px'});
	cDtafinal.addClass('data campo').css({'width':'80px'});
	
	layoutPadrao();

	return false;
}

// Controle
function buscaAssociado() {

	hideMsgAguardo();

	var nrdconta = normalizaNumero( cNrdconta.val() );
	var cdcooper = normalizaNumero( cCdcooper.val() );
	var cdagenci = normalizaNumero( cCdagenci.val() );
	
	var mensagem = 'Aguarde, buscando associado ...';
	showMsgAguardo( mensagem );	
	
	//Carrega dados da conta através de ajax
	$.ajax({		
		type	: 'POST',
		url		: UrlSite + 'telas/reltar/busca_associado.php', 
		data    : 
				{ 
					nrdconta	: nrdconta,
					cdcooper	: cdcooper,
					cdagenci	: cdagenci,
					redirect	: 'script_ajax' 
				}, 
				error: function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
				},
				success: function(response) {
					try {
						hideMsgAguardo();
						eval(response);
					} catch(error) {
						hideMsgAguardo();
						showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
					}
				}						
	});			

}

function controlaPesquisas(valor) {
	
	switch( valor )
	{
		case 1:
			controlaPesquisaHistorico()	
			break;
		case 2:
			controlaPesquisaHistoricoEstorno()
			break;
		case 3:
		  controlaPesquisaMotivos();
		  break;		
		case 4:
			controlaPesquisaCoop();
			break;
		case 5:
			controlaPesquisaPac();
			break;
		case 6:
			// Se esta desabilitado o campo 
			if ($("#nrdconta","#frmReltar").prop("disabled") == true)  {
				return;
			}	
			mostraPesquisaAssociado('nrdconta', frmCab );
			break;
		case 7:
			controlaPesquisaGrupo();
			break; //grupo
		case 8:
			controlaPesquisaSubGrupo();
			break; //subgrupo
	}
}

// Formata
function controlaNavegacao() {

	cTprelato.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			liberaCampos();
			return false;
		}
	});	

	//tiago tratar os campos  cddgrupo e cdsubgru
	cCddgrupo.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			if (cCddgrupo.val() == '') {
				cCdsubgru.focus();
				return false;
			} else {
				buscaGrupo();
			}
		}
	});	

	cCdsubgru.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			if (cCdsubgru.val() == '') {
				if($('#divEstorno').is(":visible")){
					cCdhisest.focus();
				}else{
					cCdhistor.focus();
				}	
				return false;
			} else {
				buscaSubGrupo();
			}
		}
	});	
	
	cCdhistor.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			if (cCdhistor.val() == '') {
				if ( cGlbcoope.val() == 3 ) {
					cCdcooper.focus();
					return false;
				} else {
					cCdagenci.focus();
					return false;
				}
			} else {			    
				buscaHistorico();
			}
		}
	});	
	
	cCdhisest.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			if (cCdhisest.val() == '') {
				cCdmotest.focus();
				return false;
			} else {			    
				buscaHistoricoEstorno();
			}
		}
	});	
	
	cCdmotest.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			if (cCdmotest.val() == '') {
				if ( cGlbcoope.val() == 3 ) {
					cCdcooper.focus();
				} else {
					cCdagenci.focus();
				}
			} else {
				buscaDadosMotivo();
			}
			return false;
		}
	});
	
	cCdcooper.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			if (cCdcooper.val() == '') {
				$('#nmrescop','#frmReltar').val('');
				cInpessoa.focus();
				return false;
			} else {
				buscaCooperativa();
			}
		}
		
	});
	
	cCdagenci.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			if (cCdagenci.val() == '') {
				cInpessoa.focus();
				return false;
			} else {
				buscaDadosAgencia();
			}
		}
	});
	
	cInpessoa.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			cNrdconta.focus();
			return false;
		}
	});
	
	cNrdconta.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			if (cNrdconta.val() == '') {
				cDtinicio.focus();
			} else {
				buscaAssociado();
				return false;
			}
		} else if ( e.keyCode == 118 ) {
			mostraPesquisaAssociado('nrdconta', frmCab );
			return false;
		}
	});
	
	cDtinicio.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			cDtafinal.focus();
			return false;
		}
	});
	
	cDtafinal.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			btnContinuar();
			return false;
		}
	});

	
	return false;	
	
}

function controlaLayout() {
}

// Botoes
function btnVoltar() {
	estadoInicial();
	return false;
}

function btnContinuar() {

	//Remove a classe de Erro do form
	$('input,select', '#frmReltar').removeClass('campoErro');

	var dtinicio = cDtinicio.val();
	var dtafinal = cDtafinal.val();

	if ( dtinicio == '' ){
		hideMsgAguardo();
		showError("error","Periodo Inicial deve ser informado.","Alerta - Ayllos","focaCampoErro(\'dtinicio\', \'frmReltar\');",false);
		return false;
	
	}
	
	if ( dtafinal == '' ){
		hideMsgAguardo();
		showError("error","Periodo Final deve ser informado.","Alerta - Ayllos","focaCampoErro(\'dtafinal\', \'frmReltar\');",false);
		return false;
	
	}
	
		
	var aux_inicio = parseInt(dtinicio.split("/")[2].toString() + dtinicio.split("/")[1].toString() + dtinicio.split("/")[0].toString()); 
	var aux_final  = parseInt(dtafinal.split("/")[2].toString() + dtafinal.split("/")[1].toString() + dtafinal.split("/")[0].toString()); 
	
	if ( aux_inicio > aux_final ) {
		hideMsgAguardo();
		showError("error","Periodo Inicial deve ser menor que Periodo Final.","Alerta - Ayllos","focaCampoErro(\'dtinicio\', \'frmReltar\');",false);
		return false;
	}

	Gera_Impressao();

}

function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;" >Voltar</a>&nbsp;');
	
	if (botao != '') {
		$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onclick="btnContinuar(); return false;" >' + botao + '</a>');
	}

	return false;
}

function buscaHistorico(){

	showMsgAguardo("Aguarde, consultando Historico...");

	var tprelato = $('#tprelato','#frmCab').val();
	tprelato = normalizaNumero(tprelato);		

	var cdhistor = $('#cdhistor','#frmReltar').val();
	cdhistor = normalizaNumero(cdhistor);		
	
	if(tprelato == 3){
		cdhistor = $('#cdhisest','#frmReltar').val();
		cdhistor = normalizaNumero(cdhistor);		
	}
	
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/reltar/busca_historico.php", 
		data: {
			cdhistor: cdhistor,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {				
				hideMsgAguardo();					
				eval(response);				
				buscaSubgrupoHistorico();
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});	
	
}

function buscaSubgrupoHistorico(){

	showMsgAguardo("Aguarde, consultando Historico...");

	var tprelato = $('#tprelato','#frmCab').val();
	tprelato = normalizaNumero(tprelato);	
	var cdhistor = $('#cdhistor','#frmReltar').val();
	cdhistor = normalizaNumero(cdhistor);	
	var cdhisest = $('#cdhisest','#frmReltar').val();
	cdhisest = normalizaNumero(cdhisest);	
	var cdhistmp = 0;
	var flgestor = 0;
	
	if(   ($('#cdhistor','#frmReltar').hasClass('campoTelaSemBorda') && (cdhistor > 0)) || 
	      ($('#cdhisest','#frmReltar').hasClass('campoTelaSemBorda') && (cdhisest > 0)) ){
				
		if(cdhistor > 0){
			cdhistmp = cdhistor;			
			flgestor = 0;
		}else{
			cdhistmp = cdhisest;
			
			if(tprelato != 3){
				flgestor = 1;
			}	
		}
	
		// Executa script através de ajax
		$.ajax({		
			type: "POST",
			url: UrlSite + "telas/reltar/busca_subgrupo_historico.php", 
			data: {
				cdhistor: cdhistmp,
				flgestor: flgestor,
				redirect: "script_ajax"
			}, 
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			},
			success: function(response) {
				try {			
					hideMsgAguardo();
					eval(response);
					
					if( ! $('#cdsubgru','#frmReltar').hasClass('campoTelaSemBorda') ){
						buscaSubGrupo();
					}	
				} catch(error) {
					hideMsgAguardo();
					showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
				}				
			}				
		});		
		
		

	}else{
		hideMsgAguardo();
	}
}

function buscaGrupo(){

	showMsgAguardo("Aguarde, consultando Grupo...");

	var cddgrupo = $('#cddgrupo','#frmReltar').val();
	cddgrupo = normalizaNumero(cddgrupo);	
	
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/reltar/busca_grupo.php", 
		data: {
			cddgrupo: cddgrupo,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();	
				eval(response);
				
				if( $("#divEstorno").is(":visible") ){
				
					if( $('#cdhisest','#frmReltar').hasClass('campoTelaSemBorda') ){
						$('#cdmotest','#frmReltar').focus();												
					}else{
						if( $('#cdsubgru','#frmReltar').hasClass('campoTelaSemBorda') ){
							$('#cdhisest','#frmReltar').focus();
						}					
					}
					
				}else{
					if( $('#cdhistor','#frmReltar').hasClass('campoTelaSemBorda') ){ 
						$('#cdcopaux','#frmReltar').focus();
					}else{
						if( $('#cdsubgru','#frmReltar').hasClass('campoTelaSemBorda') ){ 
							$('#cdhistor','#frmReltar').focus();
						}	
					}	
				}
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});	
	
}

function buscaSubGrupo(){

	showMsgAguardo("Aguarde, consultando SubGrupo...");

	var cdsubgru = $('#cdsubgru','#frmReltar').val();
	cdsubgru = normalizaNumero(cdsubgru);	
	
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/reltar/busca_subgrupo.php", 
		data: {
			cdsubgru: cdsubgru,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();	
				eval(response);				
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});		
	
}

function buscaHistoricoEstorno(){

	var tprelato = $('#tprelato','#frmCab').val();
	tprelato = normalizaNumero(tprelato);	
	
	if(tprelato == 3){
		buscaHistorico();
		return false;
	}

	showMsgAguardo("Aguarde, consultando Historico...");

	var cdhisest = $('#cdhisest','#frmReltar').val();
	cdhisest = normalizaNumero(cdhisest);	
	
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/reltar/busca_historico_estorno.php", 
		data: {
			cdhisest: cdhisest,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();				
				eval(response);
				buscaSubgrupoHistorico();				
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});	
	
}

function controlaPesquisaHistoricoEstorno() {

	// Se esta desabilitado o campo 
	if ($("#cdhisest","#frmReltar").prop("disabled") == true)  {
		return;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdhisest, titulo_coluna, cdgrupos, dshisest;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmReltar';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdhisest = $('#cdhisest','#'+nomeFormulario).val();	
	cdhisest = normalizaNumero(cdhisest);		
	dshisest = ' ';
	
	titulo_coluna = "Historicos";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-historicos-estorno-tarifa';
	titulo      = 'Historicos';
	qtReg		= '10';
	filtros 	= 'Codigo;cdhisest;130px;S;' + cdhisest + ';S|Descricao;dshisest;100px;S;' + dshisest + ';S';
	colunas 	= 'Codigo;cdhistor;20%;right|' + titulo_coluna + ';dshistor;50%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cdhisest\',\'#frmDetalhaTarifa\').val()');
	
	return false;
}

function controlaPesquisaHistorico() {

	// Se esta desabilitado o campo 
	if ($("#cdhistor","#frmReltar").prop("disabled") == true)  {
		return;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdhistor, titulo_coluna, cdgrupos, dshistor;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmReltar';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdhistor = $('#cdhistor','#'+nomeFormulario).val();
	cdhistor = cdhistor;	
	dshistor = '';
	
	titulo_coluna = "Historicos";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-historicos-tarifa';
	titulo      = 'Historicos';
	qtReg		= '10';
	filtros 	= 'Codigo;cdhistor;130px;S;' + cdhistor + ';S|Descricao;dshistor;330px;S;' + dshistor + ';S';
	colunas 	= 'Codigo;cdhistor;20%;right|' + titulo_coluna + ';dshistor;50%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cdhistor\',\'#frmDetalhaTarifa\').val()');
	
	return false;
}

//tiago pesquisa grupo
function controlaPesquisaGrupo() {

	// Se esta desabilitado o campo 
	if ($("#cddgrupo","#frmReltar").prop("disabled") == true)  {
		return;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cddgrupo, titulo_coluna, cdgrupos, dsdgrupo;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmReltar';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cddgrupo = $('#cddgrupo','#'+nomeFormulario).val();
	cddgrupo = cddgrupo;	
	dsdgrupo = '';
	
	titulo_coluna = "Grupos";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-grupos';
	titulo      = 'Grupos';
	qtReg		= '10';
	filtros 	= 'Codigo;cddgrupo;130px;S;' + cddgrupo + ';S|Descricao;dsdgrupo;330px;S;' + dsdgrupo + ';S';
	colunas 	= 'Codigo;cddgrupo;20%;right|' + titulo_coluna + ';dsdgrupo;50%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cddgrupo\',\'#frmDetalhaTarifa\').val()');
	
	return false;
}

//tiago pesquisa subgrupo
function controlaPesquisaSubGrupo() {

	// Se esta desabilitado o campo 
	if ($("#cdsubgru","#frmReltar").prop("disabled") == true)  {
		return;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdsubgru, titulo_coluna, cdgrupos, dssubgru;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmReltar';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdsubgru = $('#cdsubgru','#'+nomeFormulario).val();
	cdsubgru = cdsubgru;	
	dssubgru = '';
	
	titulo_coluna = "SubGrupos";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-subgrupos';
	titulo      = 'SubGrupos';
	qtReg		= '10';
	filtros 	= 'Codigo;cdsubgru;130px;S;' + cdsubgru + ';S|Descricao;dssubgru;330px;S;' + dssubgru + ';S';
	colunas 	= 'Codigo;cdsubgru;20%;right|' + titulo_coluna + ';dssubgru;50%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cdsubgru\',\'#frmDetalhaTarifa\').val()');
	
	return false;
}

function liberaCampos() {

	if ( $('#tprelato','#frmCab').hasClass('campoTelaSemBorda')  ) { return false; } ;	
	
	

	$('#tprelato','#'+frmCab).desabilitaCampo();
	$('#frmReltar').css({'display':'block'});
	$('#divBotoes').css({'display':'block'});
	formataFrmReltar();
	
	$('#divEstorno').css({'display':'none'});
	$('#divHistorico').css({'display':'block'});
	
	//cCdhistor.focus();
	cCddgrupo.focus();
	
	if ( (cTprelato.val() == 2 ) || (cTprelato.val() == 3  ) ) {
		$('#divEstorno').css({'display':'block'});
		$('#divHistorico').css({'display':'none'});
		//cCdhisest.focus();
	} 
	
	$('input, select', '#'+frmReltar).limpaFormulario().removeClass('campoErro');	
	
	var tprelato = $('#tprelato','#frmCab').val();
	$('#tprelato1','#frmReltar').val(tprelato);
	
	var dtafinal = $('#glbdtmvt','#frmCab').val();
	var dtinicio = "01/" + dtafinal.split("/")[1].toString() + "/" + dtafinal.split("/")[2].toString()
	
	$('#dtinicio','#frmReltar').val(dtinicio);
	$('#dtafinal','#frmReltar').val(dtafinal);
	
	if ( $('#glbcoope','#frmCab').val() == 3 ) {
		$('#cdagenci','#frmReltar').desabilitaCampo();
		$('#nrdconta','#frmReltar').desabilitaCampo();
	}
	
	return false;

}


function buscaDadosMotivo() {

	showMsgAguardo("Aguarde, consultando Motivos...");

	var cdmotest = $('#cdmotest','#frmReltar').val();
		cdmotest = normalizaNumero(cdmotest);
		
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/reltar/busca_motivo.php", 
		data: {
			cdmotest: cdmotest,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});	

}

function buscaDadosAgencia() {

	showMsgAguardo("Aguarde, consultando Pa...");

	var cdagenci = $('#cdagenci','#frmReltar').val();
		cdagenci = normalizaNumero(cdagenci);
		
	var cdcooper = $('#cdcopaux','#frmReltar').val();
		cdcooper = normalizaNumero(cdcooper);
		
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/reltar/busca_agencia.php", 
		data: {
			cdagenci: cdagenci,
			cdcooper: cdcooper,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});	

}


// imprimir
function Gera_Impressao() {	

	//showMsgAguardo("Aguarde, gerando relatorio...");

	var tprelato = $('#tprelato1','#frmReltar').val(); 
	var cdhistor = $('#cdhistor','#frmReltar').val();	
	var cddgrupo = $('#cddgrupo','#frmReltar').val();
	var cdsubgru = $('#cdsubgru','#frmReltar').val();	
	var cdhisest = $('#cdhisest','#frmReltar').val();
	var cdmotest = $('#cdmotest','#frmReltar').val();
	var cdcooper = $('#cdcopaux','#frmReltar').val();
	var cdagenci = $('#cdagenci','#frmReltar').val();
	var inpessoa = $('#inpessoa','#frmReltar').val();
	var nrdconta = $('#nrdconta','#frmReltar').val();
	var dtinicio = $('#dtinicio','#frmReltar').val();
	var dtafinal = $('#dtafinal','#frmReltar').val();
    var flgresum = $('#flgresum','#frmReltar');

	tprelato = normalizaNumero(tprelato);
	cdhistor = normalizaNumero(cdhistor);
	cddgrupo = normalizaNumero(cddgrupo);
	cdsubgru = normalizaNumero(cdsubgru);
	cdhisest = normalizaNumero(cdhisest);
	cdmotest = normalizaNumero(cdmotest);
	cdcooper = normalizaNumero(cdcooper);
	cdagenci = normalizaNumero(cdagenci);
	inpessoa = normalizaNumero(inpessoa);
	nrdconta = normalizaNumero(nrdconta);
	
	$('#cdhistor1','#frmReltar').val(cdhistor);
	$('#cdhisest1','#frmReltar').val(cdhisest);	
	$('#cddgrupo1','#frmReltar').val(cddgrupo);
	$('#cdsubgru1','#frmReltar').val(cdsubgru);	
	$('#cdmotest1','#frmReltar').val(cdmotest);
	$('#cdcooper1','#frmReltar').val(cdcooper);
	$('#cdagenci1','#frmReltar').val(cdagenci);
	$('#inpessoa1','#frmReltar').val(inpessoa);
	$('#nrdconta1','#frmReltar').val(nrdconta);	
	
	/*Resumido transformar o numero do tprelato no numero correspondente
	  ao seu relatorio resumido se o input estiver checkado obs:ver fonte manter_rotina.php*/
	if( $('#flgresum:checked','#frmReltar').val() == 'on' ){			
		switch(tprelato)
		{
			case '1':
			  $('#tprelato1','#frmReltar').val('6'); /*rel-receita-tarifa-resumido*/			  
			  break;
			case '2':
			  $('#tprelato1','#frmReltar').val('7'); /*rel-estorno-tarifa-resumido*/			  
			  break;
			case '3':
			  $('#tprelato1','#frmReltar').val('8'); /*rel-tarifa-baixada-resumido*/			  
			  break;
			case '4':
			  $('#tprelato1','#frmReltar').val('9'); /*rel-tarifa-pendente-resumido*/			  
			  break;
			case '5':
			  $('#tprelato1','#frmReltar').val('10');; /*rel-estouro-cc-resumido*/			  
			  break;			  
		}
	}
	
	var action = UrlSite + 'telas/reltar/manter_rotina.php';
	
	$('#sidlogin','#frmReltar').remove();
	
	$('#frmReltar').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '" />');

	carregaImpressaoAyllos("frmReltar",action,"estadoInicial();");
	
	return false;
		
}


function controlaPesquisaMotivos() {

	// Se esta desabilitado o campo 
	if ($("#cdmotest","#frmReltar").prop("disabled") == true)  {
		return;
	}
	
 	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdmotest, titulo_coluna, cdmotests, dsmotest, tpaplica;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmReltar';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdmotest = $('#cdmotest','#'+nomeFormulario).val();
	cdmotests = cdmotest;	
	dsmotest = ' ';
	tpaplica = 1;
	
	titulo_coluna = "Descricao";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-met';
	titulo      = 'Motivos de Estorno Baixa de Tarifas';
	qtReg		= '10';
	filtros 	= 'Codigo;cdmotest;130px;S;' + cdmotest + ';S|Descricao;dsmotest;100px;S;' + dsmotest + ';N|Aplicacao;tpaplica;100px;N;' + tpaplica + ';N';
	colunas 	= 'Codigo;cdmotest;20%;right|' + titulo_coluna + ';dsmotest;50%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cdmotest\',\'#frmCab\').val()');
	
	return false; 
}


function controlaPesquisaPac() {

	// Se esta desabilitado o campo 
	if ($("#cdagenci","#frmReltar").prop("disabled") == true)  {
		return;
	}
	
 	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdcooper, nmrescop, cdagenci, titulo_coluna, cdagencis, nmresage;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmReltar';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdagenci = $('#cdagenci','#'+nomeFormulario).val();
	
	var cdcooper = $('#cdcopaux','#frmReltar').val();
	
	if ( cdcooper == '' ) {
		var cdcooper = $('#glbcoope','#frmCab').val();	
	}
	
	cdagencis = cdagenci;	
	nmresage = ' ';
	nmrescop = ' ';
	
	titulo_coluna = "Descricao";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-pacs';
	titulo      = 'Agência PA';
	qtReg		= '20';
	
	if ( $('#glbcoope','#frmCab').val() == 3 ) {
		filtros 	= 'Coop;cdcooper;30px;S;' + cdcooper + ';S|Nome Coop;nmrescop;30px;N;' + nmrescop + ';N|Cód. PA;cdagenci;30px;S;' + cdagenci + ';S|Agência PA;nmresage;200px;S;' + nmresage + ';N';
		colunas 	= 'Cód. Coop;cdcooper;20%;right|Cooperativa;nmrescop;27%;right|Cód. PA;cdagenci;15%;right|' + titulo_coluna + ';nmresage;50%;left';
	} else {
		filtros 	= 'Cód. PA;cdagenci;30px;S;' + cdagenci + ';S|Agência PA;nmresage;200px;S;' + nmresage + ';N';
		colunas 	= 'Codigo;cdagenci;20%;right|' + titulo_coluna + ';nmresage;50%;left';
	}
	
	
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cdagenci\',\'#frmReltar\').val()');
	
	return false; 
}

function controlaPesquisaCoop(){

	// Se esta desabilitado o campo 
	if ($("#cdcopaux","#frmReltar").prop("disabled") == true)  {
		return;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdcooper, titulo_coluna, cdcoopers, cdcopaux, nmrescop;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmReltar';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdcopaux = $('#cdcopaux','#'+nomeFormulario).val();
	cdcoopers = cdcopaux;	
	nmrescop = '';
	
	var cdcopaux = '' ;	
	
	titulo_coluna = "Cooperativas";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-cooperativas';
	titulo      = 'Cooperativas';
	qtReg		= '10';
	filtros 	= 'Codigo;cdcopaux;130px;S;' + cdcopaux + ';S|Descricao;nmrescop;200px;S;' + nmrescop + ';S';
	colunas 	= 'Codigo;cdcooper;20%;right|' + titulo_coluna + ';nmrescop;50%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cdcopaux\',\'#frmReltar\').val()');
	
	return false;
}


function buscaCooperativa(){

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, buscando cooperativa...");

	var cdcooper = $('#cdcopaux','#frmReltar').val();
	cdcooper = normalizaNumero(cdcooper);

	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/reltar/busca_dados_cooperativa.php", 
		data: {
			cdcooper: cdcooper,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();
				$('#cdagenci','#frmReltar').habilitaCampo();
				$('#nrdconta','#frmReltar').habilitaCampo();
				$('#cdcopaux','#frmReltar').desabilitaCampo();
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});	
	
	return false;

}
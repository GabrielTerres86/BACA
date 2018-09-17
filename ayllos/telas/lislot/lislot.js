/*!
 * FONTE        : lislot.js
 * CRIAÇÃO      : Jéssica (DB1) 
 * DATA CRIAÇÃO : 20/02/2014
 * OBJETIVO     : Biblioteca de funções da tela LISLOT
 * --------------
 * ALTERAÇÕES   : 11/03/2015 Inclusao de title para os históricos de lote no campo "histórico" (Carlos)
 *
 *				  09/05/2016 - Ajustado os parametros para enviar e receber pelo metodo GET
 *							   para ajustar problema de permissão solicitado no chamado 447548. (Kelvin)
 *
 *                11/11/2016 - Ajustes referente ao chamado 492589. (Kelvin)
 * --------------
 */
 
 var nometela;

//Formulários e Tabela
var frmCab   	 = 'frmCab';
var frmConsulta  = 'frmConsulta';
var frmRelatorio = 'frmRelatorio';
var frmDiretorio = 'frmDiretorio';
var frmLocal     = 'frmLocal';
var divTabela;
var dsdircop;
     
var cddopcao, tpdopcao, cdagenci, cdhistor, nrdconta, 
	dtinicio, dttermin, nmdopcao, totregis, vllanmto, dsiduser,
	cTodosCabecalho, btnOK, cTodosConsulta, cTodosManter;

var rCddopcao, rTpdopcao, rCdagenci, rCdhistor, rNrdconta, 
	rDtinicio, rDttermin, rNmdopcao, rTotregis, rVllanmto,
	cCddopcao, cTpdopcao, cCdagenci, cCdhistor, cNrdconta, 
	cDtinicio, cDttermin, cNmdopcao, cTotregis, cVllanmto;
	
$(document).ready(function() {
	divTabela		= $('#divTabela');
	estadoInicial();
	nrregist = 50;
		
	return false;
		
});

function carregaDados(){

	cddopcao = $('#cddopcao','#'+frmCab).val();
	tpdopcao = $('#tpdopcao','#'+frmConsulta).val();
	cdagenci = $('#cdagenci','#'+frmConsulta).val();
	cdhistor = $('#cdhistor','#'+frmConsulta).val();
	nrdconta = $('#nrdconta','#'+frmConsulta).val();
	nrdconta = nrdconta.replace(/[-. ]*/g,'');
	dtinicio = $('#dtinicio','#'+frmConsulta).val(); 
	dttermin = $('#dttermin','#'+frmConsulta).val();
	nmdopcao = $('#nmdopcao','#'+frmConsulta).val();
				
	return false;
} //carregaDados

// inicio
function estadoInicial() {

	$('#frmCab').fadeTo(0,0.1);
		
	$('#divTabela').html('');
		
	formataCabecalho();
	formataConsulta();
	formataSaida();
		
	removeOpacidade('frmCab');
	
	return false;
	
}

// formata
function formataCabecalho() {
		
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
		
	btnOK				= $('#btnOK','#'+frmCab);
	
	
	//Cabecalho
		
	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab);	
	cCddopcao			= $('#cddopcao','#'+frmCab);
		
	cTodosCabecalho.habilitaCampo();
			
	rCddopcao.addClass('rotulo').css({'width':'200px'});
	cCddopcao.css({'width':'230px'});
			
	cCddopcao.focus();
	
	
	btnOK.unbind('click').bind('click', function() {
				
		if ( divError.css('display') == 'block' ) { return false; }		
		
		cTodosCabecalho.removeClass('campoErro');	
		cCddopcao.desabilitaCampo();		
		
		controlaLayout();
			
	});
	
	cCddopcao.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }

		// Se é a tecla ENTER
		if ( e.keyCode == 13) {

			btnContinuar();
			return false;
		}

	});
	
	
	$('#frmConsulta').css('display','none');
					
	highlightObjFocus( $('#frmCab') );
	highlightObjFocus( $('#frmConsulta') );
					
	layoutPadrao();
	
	cCddopcao.focus();	
		
	return false;	
}

function controlaLayout() {

	$('#frmConsulta').css('display','block');
	
	cTpdopcao.focus();
		
	cCddopcao.unbind('change').bind('change', function() {
		
		if(cCddopcao.val() == "T"){
			
			$('#divSaida').css('display','none');
							
		}else{
						
			$('#divSaida').css('display','block');
				
		}		
		
		return false;
			
	});	
			
	cCddopcao.trigger('change');
	
	
	cTpdopcao.unbind('change').bind('change', function() {
		
		$('#cdhistor','#'+frmConsulta).removeAttr('title');
		
		if(cTpdopcao.val() == "CAIXA"){
		
			$('#nrdconta','#divConsulta').css('display','none');
			$('label[for="nrdconta"]','#divConsulta').css('display','none');
			$('#cdagenci','#divConsulta').habilitaCampo();			
										
		}else if(cTpdopcao.val() == "LOTE P/PA"){
					
			$('#nrdconta','#divConsulta').css('display','none');
			$('label[for="nrdconta"]','#divConsulta').css('display','none');
			$('#cdagenci','#divConsulta').desabilitaCampo();
			$('#cdhistor','#'+frmConsulta).attr('title', 'Informe um Historico ou \'0\' (zero) para 8, 105, 626, 889, 351, 770, 397, 47, 621, 521.');

		}else{
		
			$('#nrdconta','#divConsulta').css('display','block');
			$('label[for="nrdconta"]','#divConsulta').css('display','block');
			$('#cdagenci','#divConsulta').habilitaCampo();
		
		}	
		
		return false;
			
	});	
			
			
	cTpdopcao.trigger('change');
	
				
	return false;
}

//botoes
function btnVoltar() {

	$('#frmConsulta').limpaFormulario();
	$('#frmDetalhe').limpaFormulario();
			
	estadoInicial();
		
	return false;
}

function btnContinuar() {

	if ( divError.css('display') == 'block' ) { return false; }		
			
	if ( cCddopcao.hasClass('campo') ) {
		btnOK.click();
		
	}else {
		if(cCddopcao.val() == "T"){
		
			buscaLislot(1);
			
		} else if ( cNmdopcao.val() == "no"  ) {
			Gera_Impressao();
		} else if ( cNmdopcao.val() == "yes"  ) {
			buscaLocal();
		}
						
	}	
							
	return false;

}

function buscaLislot(nriniseq) {	
	
	showMsgAguardo('Aguarde, buscando Historicos...');

	carregaDados();
	
				
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/'+nometela+'/busca_lislot.php', 
		data    :
				{ 
				  cddopcao 	: cddopcao, 	 
				  tpdopcao	: tpdopcao,
				  cdagenci 	: cdagenci,
				  cdhistor	: cdhistor,
				  nrdconta  : nrdconta,
				  dtinicio  : dtinicio,
				  dttermin  : dttermin,
				  nmdopcao  : nmdopcao,
				  nrregist  : nrregist,
				  nriniseq  : nriniseq,
				  redirect  : 'script_ajax'
				  
				  
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
				},
		success : function(response) { 
					hideMsgAguardo();
					
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							$('#divTabela').html(response);
							return false;
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
						}
					} else {
						try {
							eval( response );
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
						}
					}
					
				}
	}); 
}

// imprimir .TXT
function Gera_ImpressaoTXT() {

	showMsgAguardo('Aguarde, Gerando Arquivo...');

	carregaDados();

	$.ajax({
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/'+nometela+'/imprimir_dados.php',
		data    :
				{ cddopcao 	: cddopcao, 	 
				  tpdopcao	: tpdopcao,
				  cdagenci 	: cdagenci,
				  cdhistor	: cdhistor,
				  nrdconta  : nrdconta,
				  dtinicio  : dtinicio,
				  dttermin  : dttermin,
				  nmdopcao  : nmdopcao,
				  dsiduser  : dsiduser,
				  redirect: 'script_ajax'

				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#tpChequ1\',\'#frmTipoCheque\').focus();');
				},
		success : function(response) {
					hideMsgAguardo();

					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							fechaRotina($('#divRotina'));
							return false;
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#tpChequ1\',\'#frmTipoCheque\').focus();');
						}
					} else {
						try {
							eval( response );
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#tpChequ1\',\'#frmTipoCheque\').focus();');
						}
					}

				}
	});

	return false;
}

function buscaLocal() {

	hideMsgAguardo();

	showMsgAguardo('Aguarde, abrindo ...');

	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/lislot/arquivo.php',
		data: {
			dsdircop: dsdircop,
			redirect: 'script_ajax'
			},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {

			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divRotina').html(response);
					hideMsgAguardo();
					exibeRotina($('#divRotina'));
					formataArquivo();
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			} else {
				try {
					eval( response );
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		}
	});
	return false;
}

function formataArquivo(){

	cNmarquiv = $('#nmarquiv','#'+frmLocal);

	rNmarquiv  = $('label[for="nmarquiv"]','#'+frmLocal);
	rNmarquiva = $('label[for="nmarquiva"]','#'+frmLocal);

	rNmarquiv.addClass('rotulo').css({'width':'180px'});
	rNmarquiva.addClass('rotulo-linha').css({'width':'30px'});

	cNmarquiv.css({'width':'180px'});

	cNmarquiv.habilitaCampo();
	cNmarquiv.focus();
	
	cNmarquiv.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }

		// Se é a tecla ENTER
		if ( e.keyCode == 13) {

			validaArquivo();
			return false;
		}

	});

	return false;
}

function validaArquivo(){

	if ( cNmarquiv.val() == '' ){
		showError('error','Arquivo n&atilde;o informado.','Alerta - Ayllos','bloqueiaFundo($(\'#divRotina\'));cNmarquiv.focus();'); return false;
	}

	dsiduser = cNmarquiv.val();
	Gera_ImpressaoTXT();

	return false;
}


// imprimir .PDF
function Gera_Impressao() {
	cddopcao = cCddopcao.val();
	tpdopcao = cTpdopcao.val();
	cdagenci = cCdagenci.val();
	cdhistor = cCdhistor.val();
	nrdconta = cNrdconta.val();
	dtinicio = cDtinicio.val();
	dttermin = cDttermin.val();
	nmdopcao = cNmdopcao.val();
		
	$('#sidlogin','#frmConsulta').remove();	
	
	$('#frmConsulta').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '" />');	
	
	$('#frmConsulta').append('<input type="hidden" id="cddopcao" name="cddopcao" value="' + cddopcao + '" />');	
	$('#frmConsulta').append('<input type="hidden" id="tpdopcao" name="tpdopcao" value="' + tpdopcao + '" />');
	$('#frmConsulta').append('<input type="hidden" id="cdagenci" name="cdagenci" value="' + cdagenci + '" />');
	$('#frmConsulta').append('<input type="hidden" id="cdhistor" name="cdhistor" value="' + cdhistor + '" />');
	$('#frmConsulta').append('<input type="hidden" id="nrdconta" name="nrdconta" value="' + nrdconta + '" />');
	$('#frmConsulta').append('<input type="hidden" id="dtinicio" name="dtinicio" value="' + dtinicio + '" />');
	$('#frmConsulta').append('<input type="hidden" id="dttermin" name="dttermin" value="' + dttermin + '" />');
	$('#frmConsulta').append('<input type="hidden" id="nmdopcao" name="nmdopcao" value="' + nmdopcao + '" />');
		
	var action = UrlSite + 'telas/lislot/imprimir_dados.php';
	
	carregaImpressaoAyllos("frmConsulta",action,"estadoInicial();");
	
	return false;
	
}

function formataTabela() {

	var divRegistro = $('div.divRegistros', divTabela );	
	
	var tabela      = $('table', divRegistro );
	
	divRegistro.css({'height':'207px','border-bottom':'1px dotted #777','padding-bottom':'2px'});	
	divTabela.css({'padding-top':'10px'});	
		
	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '62px';
	arrayLargura[1] = '30px';
	arrayLargura[2] = '60px';
	arrayLargura[3] = '250px';
	arrayLargura[4] = '65px';
				
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'left';	
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'right';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
		
	divTabela.css({'display':'block'});

	formataDetalhe();
	
	
	return false;
}

function formataTabCaixa() {

	var divRegistro = $('div.divRegistros', divTabela );	
	
	var tabela      = $('table', divRegistro );
	
	divRegistro.css({'height':'207px','border-bottom':'1px dotted #777','padding-bottom':'2px'});	
	divTabela.css({'padding-top':'10px'});	
		
	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '62px';
	arrayLargura[1] = '30px';
	arrayLargura[2] = '50px';
	arrayLargura[3] = '150px';
	
			
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'right';	
	arrayAlinha[4] = 'right';
	
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
		
	divTabela.css({'display':'block'});

	formataDetalhe();
	
	
	return false;
}

function formataTabLote() {

	var divRegistro = $('div.divRegistros', divTabela );	
	
	var tabela      = $('table', divRegistro );
	
	divRegistro.css({'height':'207px','border-bottom':'1px dotted #777','padding-bottom':'2px'});	
	divTabela.css({'padding-top':'10px'});	
		
	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '62px';
	arrayLargura[1] = '30px';
	arrayLargura[2] = '60px';
	arrayLargura[3] = '71px';
	arrayLargura[4] = '80px';
	arrayLargura[5] = '120px';
					
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'right';	
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'right';
	arrayAlinha[6] = 'right';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
				
	divTabela.css({'display':'block'});

	formataDetalhe();
	
	
	return false;
}

function formataConsulta(){

	cTodosConsulta = $('input[type="text"],select','#divConsulta');
	
	rTpdopcao = $('label[for="tpdopcao"]','#divConsulta');
	rCdagenci = $('label[for="cdagenci"]','#divConsulta');
	rCdhistor = $('label[for="cdhistor"]','#divConsulta');
	rNrdconta = $('label[for="nrdconta"]','#divConsulta');
	rDtinicio = $('label[for="dtinicio"]','#divConsulta');  
	rDttermin = $('label[for="dttermin"]','#divConsulta');
					
	cTpdopcao = $('#tpdopcao','#divConsulta');	
	cCdagenci = $('#cdagenci','#divConsulta');	
	cCdhistor = $('#cdhistor','#divConsulta');	
	cNrdconta = $('#nrdconta','#divConsulta');
	cDtinicio = $('#dtinicio','#divConsulta');
	cDttermin = $('#dttermin','#divConsulta');
			
	rTpdopcao.css({'width':'80px'});
	rCdagenci.css({'width':'65px'});
	rCdhistor.css({'width':'100px'});
	rNrdconta.css({'width':'73px'});
	rDtinicio.css({'width':'80px'});
	rDttermin.css({'width':'65px'});
			
	cTpdopcao.css({'width':'90px'});
	cCdagenci.css({'width':'40px'});
	cCdhistor.css({'width':'47px'}).setMask('INTEGER','z.zzz','.','');
	cNrdconta.css({'width':'90px'}).addClass('conta');
	cDtinicio.css({'width':'90px'}).addClass('data');
	cDttermin.css({'width':'90px'}).addClass('data');
					
	cTodosConsulta.habilitaCampo();
		
	layoutPadrao();
	
	cDttermin.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }

		// Se é a tecla ENTER
		if ( e.keyCode == 13) {

			btnContinuar();
			return false;
		}

	});

	return false;
}

function formataSaida(){

	cTodosSaida = $('input[type="text"],select','#divSaida');
	
	rNmdopcao = $('label[for="nmdopcao"]','#divSaida');
	
	cNmdopcao = $('#nmdopcao','#divSaida');
	
	rNmdopcao.css({'width':'50px'});
	
	cNmdopcao.css({'width':'90px'});
	
	
	cTodosSaida.habilitaCampo();
		
	layoutPadrao();
	
	cNmdopcao.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }

		// Se é a tecla ENTER
		if ( e.keyCode == 13) {

			btnContinuar();
			return false;
		}

	});

	return false;

}

function formataDetalhe(){

	cTodosDetalhe = $('input[type="text"],select','#divDetalhe');
	
	rTotregis = $('label[for="totregis"]','#divDetalhe');
	rVllanmto = $('label[for="vllanmto"]','#divDetalhe');
					
	cTotregis = $('#totregis','#divDetalhe');	
	cVllanmto = $('#vllanmto','#divDetalhe');	
			
	rTotregis.css({'width':'150px'});
	rVllanmto.css({'width':'200px'});
			
	cTotregis.css({'width':'90px'});
	cVllanmto.css({'width':'135px'}).addClass('moeda');
						
	cTodosDetalhe.desabilitaCampo();
		
	layoutPadrao();

	return false;
}


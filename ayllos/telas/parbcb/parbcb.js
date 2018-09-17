/*!
 * FONTE        : parbcb.js
 * CRIAÇÃO      : Jean Michel
 * DATA CRIAÇÃO : 08/04/2014
 * OBJETIVO     : Biblioteca de funções da tela PARBCB
 * PROJETO		: Projeto de Novos Cartões Bancoob
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */

// Definição de algumas variáveis globais 
var cddopcao		= '0';
	
//Formulários
var frmCab   		= 'frmCab';

//Labels/Campos do cabeçalho
var rTparquiv, rNrseqarq, rDtultint, rDsddirarq, rChkretpr; 
var cTparquiv, cNrseqarq, cDatultin, cDsddirarq, cChkretpr;
var cTodosCabecalho, btnCab;

$(document).ready(function() {	
	estadoInicial();	
	highlightObjFocus( $('#'+frmCab) );
	
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	
	return false;	
});

// seletores
function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);
	$('#frmCab').css({'display':'block'});
	$('#divBotoes').css({'display':'block'});
			
	formataCabecalho();
	
	cTodosCabecalho.limpaFormulario();
	cTparquiv.val( cddopcao );
	
	removeOpacidade('divTela');	
	unblockBackground();
	hideMsgAguardo();
	
	$('#nrseqarq','#frmCab').desabilitaCampo();
	$('#dtultint','#frmCab').desabilitaCampo();
	$('#dsdirarq','#frmCab').desabilitaCampo();
	$('#flgretpr','#frmCab').desabilitaCampo();	
	
	$('input,select', '#frmCab').removeClass('campoErro');
	
	controlaFoco();		
}

function controlaFoco() {

	$('#tparquiv','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				//LiberaCampos();
				return false;
			}	
	});
	
	$('#btnOK','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				efetuarConsulta();
				$('#tparquiv','#frmCab').focus();
				return false;
			}	
	});
	
}

function formataCabecalho() {

	// cabecalho
	rTparquiv = $('label[for="tparquiv"]','#'+frmCab); 
	rNrseqarq = $('label[for="nrseqarq"]','#'+frmCab); 
	rDtultint = $('label[for="dtultint"]','#'+frmCab); 
	rDsdirarq = $('label[for="dsdirarq"]','#'+frmCab); 
	rFlgretpr = $('label[for="flgretpr"]','#'+frmCab); 
	
	cTparquiv = $('#tparquiv','#'+frmCab); 
	cNrseqarq = $('#nrseqarq','#'+frmCab); 
	cDtultint = $('#dtultint','#'+frmCab); 
	cDsdirarq = $('#dsdirarq','#'+frmCab); 
	cFlgretpr = $('#flgretpr','#'+frmCab); 
	
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	
	btnCab				= $('#btOK','#'+frmCab);
	
	rTparquiv.css('width','105px');
	rNrseqarq.css('width','105px');
	rDtultint.css('width','105px');
	rDsdirarq.css('width','105px');
	rFlgretpr.css('width','120px');
	
	cTparquiv.css({'width':'390px'});
	cNrseqarq.css({'width':'150px'});
	cDtultint.css({'width':'150px'});
	cDsdirarq.css({'width':'100px'});
	cFlgretpr.css({'width':'30px'});
	
	cTodosCabecalho.habilitaCampo();
	
	$('#tparquiv','#'+frmCab).focus();
	
	layoutPadrao();
	carregaCombo();
	return false;	
}

function efetuarConsulta(tipoacao) {
	
	var tparquiv = $('#tparquiv','#'+frmCab).val() == null ? 0 : $('#tparquiv','#'+frmCab).val();
	var dsdirarq = $('#dsdirarq','#'+frmCab).val();
	var nrseqarq = $('#nrseqarq','#'+frmCab).val() == null ? 0 : $('#nrseqarq','#'+frmCab).val();
	var hdndepar = $('#hdndepar','#'+frmCab).val();
	var flgretpr = 0;
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/parbcb/manter_rotina.php", 
		data: {
			tipoacao: tipoacao,
			tparquiv: tparquiv,
			nrseqarq: nrseqarq,
			dsdirarq: dsdirarq,
			flgretpr: flgretpr,
			hdndepar: hdndepar,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			hideMsgAguardo();
			eval(response);				
		}
	});	
}

function carregaCombo() {	
		
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/parbcb/carrega_combo.php", 
		data: {
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			hideMsgAguardo();
			eval(response);				
		}
	});	
}

function btnVoltar(){
	
	$('#tparquiv','#'+frmCab).val('1');
	$('#flgretpr','#'+frmCab).attr('checked',false);
	$('#dsdirarq','#'+frmCab).val('');
	$('#nrseqarq','#'+frmCab).val('');
	$('#dtultint','#'+frmCab).val('');
	$('#tparquiv','#'+frmCab).focus();
}

function btnContinuar(){
	var tparquiv = $('#tparquiv','#'+frmCab).val();
	var nrseqarq = $('#nrseqarq','#'+frmCab).val();
	
	if (tparquiv == '' || tparquiv == null){
		showError("error","Informe o Tipo de Arquivo.","Alerta - Ayllos","");
		$('#cddopcao','#'+frmCab).focus();
		return false;
	}
	
	if (nrseqarq == '' || nrseqarq == null || nrseqarq == 0){
		showError("error","Informe a Sequ&ecirc;ncia.","Alerta - Ayllos","");
		$('#nrseqarq','#'+frmCab).focus();
		return false;
	}
	
	efetuarConsulta('A');	
}

function mudaOpcao(){
	$('#flgretpr','#'+frmCab).attr('checked',false);
	$('#dsdirarq','#'+frmCab).val('');
	$('#nrseqarq','#'+frmCab).val('');
	$('#dtultint','#'+frmCab).val('');
	$('#btnOK','#'+frmCab).focus();
}
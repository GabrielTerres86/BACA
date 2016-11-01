/*!
 * FONTE        : logprt.js
 * CRIAÇÃO      : Lombardi (CECRED)
 * DATA CRIAÇÃO : Junho/2015
 * OBJETIVO     : Biblioteca de funções da tela LOGPRT
 */

var nrseqlog     = 0; 
var detalhe      = new Array();
var strHTML      = '';
var ObjDetalhe   = new Object();
var flgConsultar = '';

$(document).ready(function() {
	$('#frmCabLogprt', '#divTela').css({'display':'block'});
});

function formataCabecalho() {	

  var nomeForm = 'frmCabLogprt';
	
	$('label[for="cdopcao"]','#'+nomeForm).addClass('rotulo').css('width','46px');
	$('label[for="dtlogini"]','#'+nomeForm).addClass('rotulo').css('width','80px');
	$('label[for="dtlogfin"]','#'+nomeForm).addClass('rotulo-linha').css('width','80px');
	
	$('#cdopcao','#'+nomeForm).addClass('data').css('width','580px').habilitaCampo();
	$('#dtlogini','#'+nomeForm).addClass('data').css('width','75px').habilitaCampo();
	$('#dtlogfin','#'+nomeForm).addClass('data').css('width','75px').habilitaCampo();
  
  
	$("#dtlogini","#"+nomeForm).setMask("DATE","","","");
	$("#dtlogfin","#"+nomeForm).setMask("DATE","","","");
			
	return false;	
}

function controlaLayout(operacao,cfgtable) {
	$('#divTela').fadeTo(0,0.1);	
	$('#divLogprt').fadeTo(0,0.1);
	
	$('#divTela').css('visibility') == 'visible';
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'0px 3px 5px 3px'});		
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	
	layoutPadrao();		
	removeOpacidade('divTela');
	removeOpacidade('divLogprt');
	
	highlightObjFocus( $("#frmCabLogprt") );
  
	return false;	
}

function estadoInicial() {
	
	formataCabecalho();
	
	return false;

}

function geraImpressao(arquivo) {
	
    $('#nmarquiv', '#frmImprimir').val(arquivo);
	
    var action = UrlSite + 'telas/logprt/imprimir_pdf.php';
	
    carregaImpressaoAyllos("frmImprimir", action);

}

function geraRelatorio() {

	showMsgAguardo('Aguarde, consultando log ...');	
	// Carrega conteúdo da opção através de ajax
	var UrlOperacao = UrlSite + "telas/logprt/gerar_relatorio.php";
	$.ajax({
		type: "POST",
		dataType: "html",
		url: UrlOperacao,
		data: {
			 cdopcao: $("#cdopcao","#frmCabLogprt").val(),
			dtlogini: $("#dtlogini","#frmCabLogprt").val(),
			dtlogfin: $("#dtlogfin","#frmCabLogprt").val()
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			hideMsgAguardo();
			if(response.substr(0,4) == "hide"){
				eval(response);
			}else{
				geraImpressao(response);
			}
			return false;
		}
	});
}
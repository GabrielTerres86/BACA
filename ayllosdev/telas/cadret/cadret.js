/*!
 * FONTE        : cadret.js
 * CRIA��O      : Jorge I. Hamaguchi
 * DATA CRIA��O : 27/08/2013
 * OBJETIVO     : Biblioteca de fun��es da tela CADRET
 * --------------
 * ALTERA��ES   : 
 * -----------------------------------------------------------------------
 */
 
//Formul�rios e Tabela
var frmCab   		= 'frmCab';
var frmcadret       = 'frmcadret';

//Labels/Campos do cabe�alho
var rCddopcao, rCdoperac, rNrtabela, rCdretorn, rDsretorn;
var cCddopcao, cCdoperac, cNrtabela, cCdretorn, cDsretorn, cTodosCabecalho;


$(document).ready(function() {
	estadoInicial();
});

// seletores
function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);
	
	fechaRotina( $('#divRotina') );
	hideMsgAguardo();		
	formataCabecalho();
	formataFrmcadret();
	controlaNavegacao();
	
	trocaBotao('Prosseguir');
	
	cTodosCabecalho.limpaFormulario().removeClass('campoErro');	

	highlightObjFocus( $('#'+frmCab) );
	highlightObjFocus( $('#'+frmcadret) );
	
	$('#'+frmCab).css({'display':'block'});
	$('#'+frmcadret).css({'display':'none'});
	$('#divRetorno').html('').css({'display':'none'});
	$('#divBotoes').css({'display':'none'});
	
	cCddopcao.habilitaCampo();
	cCdoperac.habilitaCampo();
	cNrtabela.habilitaCampo();
	removeOpacidade('divTela');

	$("#cddopcao","#"+frmCab).val("C").focus();
	
	return false;

}


function formataCabecalho() {

	// Cabecalho
	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab);	
	rCddopcao.addClass('rotulo').css({'width':'60px'});
	cCddopcao			= $('#cddopcao','#'+frmCab);
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	cCddopcao.addClass('campo').css({'width':'450px'});
	layoutPadrao();
	return false;
}


function formataFrmcadret() {
	
	// Cabecalho
	rCdoperac = $('label[for="cdoperac"]','#'+frmcadret);
	rNrtabela = $('label[for="nrtabela"]','#'+frmcadret);
	rCdretorn = $('label[for="cdretorn"]','#'+frmcadret);
	rDsretorn = $('label[for="dsretorn"]','#'+frmcadret);
	
	rCdoperac.addClass('rotulo').css({'width':'75px'});
	rNrtabela.addClass('rotulo').css({'width':'75px'});
	rCdretorn.addClass('rotulo').css({'width':'75px'});
	rDsretorn.addClass('rotulo').css({'width':'75px'});
	
	cCdoperac = $('#cdoperac','#'+frmcadret);
	cNrtabela = $('#nrtabela','#'+frmcadret);
	cCdretorn = $('#cdretorn','#'+frmcadret);
	cDsretorn = $('#dsretorn','#'+frmcadret);
	
	cCdoperac.addClass('campo').css({'width':'150px'});
	cNrtabela.addClass('campo').css({'width':'150px'});
	cCdretorn.addClass('campo').css({'width':'150px'}).setMask('INTEGER','zz9','','');;
	cDsretorn.addClass('campo').css({'width':'450px'}).attr({"maxlength":"60"});
	
	layoutPadrao();

	return false;
}


// Formata
function controlaNavegacao() {

	cCddopcao.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se � a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			liberaCampos();
			return false;
		}
	});	
	
	cCdoperac.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se � a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			cNrtabela.focus();
			return false;
		}
	});
	
	cNrtabela.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se � a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			if(cCddopcao.val() != "C"){
				cCdretorn.focus();
			}else{
				btnContinuar();
			}
			return false;
		}
	});
	
	cCdretorn.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se � a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			if(cCddopcao.val() == "I"){
				cDsretorn.focus();
			}else{
				btnContinuar();
			}
			return false;
		}
	});
	
	cDsretorn.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se � a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			btnContinuar();
			return false;
		}
	});
	
	return false;	
	
}


function liberaCampos() {
	
	var cddopcao = $('#cddopcao','#'+frmCab);

	if ( cddopcao.hasClass('campoTelaSemBorda')  ) { return false; } ;	
	
	cddopcao.desabilitaCampo();
	$('#'+frmcadret).css({'display':'block'});
	$('#divBotoes').css({'display':'block'});
	formataFrmcadret();
	
	$('input, select', '#'+frmcadret).limpaFormulario().removeClass('campoErro');
	
	highlightObjFocus($('#'+frmcadret));
	
	if(cddopcao.val() == "C"){
		$("#tr_cdretorn","#"+frmcadret).hide();
		$("#tr_dsretorn","#"+frmcadret).hide();
		cCdoperac.focus();
	}else if(cddopcao.val() == "I"){
		$("#tr_cdretorn","#"+frmcadret).show();
		$("#tr_dsretorn","#"+frmcadret).show();
		cCdretorn.habilitaCampo();
		cDsretorn.habilitaCampo();
		cCdoperac.focus();
	}else if(cddopcao.val() == "A"){
		$("#tr_cdretorn","#"+frmcadret).show();
		$("#tr_dsretorn","#"+frmcadret).show();
		cCdretorn.habilitaCampo();
		cDsretorn.desabilitaCampo();
		cCdoperac.focus();
	}
	
	return false;

}


// Botoes
function btnVoltar() {
	estadoInicial();
	return false;
}

function btnContinuar() {
	
	var cddopcao = $("#cddopcao","#"+frmCab).val();
	
	//Remove a classe de Erro do form
	$('input,select', '#'+frmcadret).removeClass('campoErro');
	
	if(cddopcao == "A" && cDsretorn.attr('disabled') != "disabled"){
		manter_rotina('A1');
	}else{
		manter_rotina();
	}
	return false;
}


function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;" >Voltar</a>&nbsp;');
	
	if (botao != '') {
		$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onclick="btnContinuar(); return false;" >' + botao + '</a>');
	}

	return false;
}

function manter_rotina(rotina){
	
	var cddopcao = $('#cddopcao','#'+frmCab).val();
	var cdoperac = $('#cdoperac','#'+frmcadret).val();
	var nrtabela = $('#nrtabela','#'+frmcadret).val();
	var cdretorn = $('#cdretorn','#'+frmcadret).val();
	var dsretorn = $('#dsretorn','#'+frmcadret).val();
	
	if(rotina != undefined){
		operacao = rotina;
	}else{
		operacao = cddopcao;
	}
	
	if((cddopcao == "I" || cddopcao == "A") && (cdretorn == "" || cdretorn == "0")){
		showError("error","C�digo de retorno inv�lido.","Alerta - Ayllos","hideMsgAguardo();focaCampoErro('cdretorn','frmcadret');");
		return false;
	}
	
	if((cddopcao == "I" || cddopcao == "A1") && dsretorn == ""){
		showError("error","Descri��o de retorno inv�lido.","Alerta - Ayllos","hideMsgAguardo();focaCampoErro('dsretorn','frmcadret');");
		return false;
	}
	
	window.focus();
	
		 if(cddopcao == "C")  msgaguardo = "carregando";
	else if(cddopcao == "I")  msgaguardo = "cadastrando";
	else if(cddopcao == "A")  msgaguardo = "carregando";
	else if(cddopcao == "A1") msgaguardo = "alterando";
	else 					  msgaguardo = "carregando";
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, "+msgaguardo+" ...");
	
	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/cadret/manter_rotina.php", 
		data: {
			cddopcao: cddopcao,
			operacao: operacao,
			cdoperac: cdoperac,
			nrtabela: nrtabela,
			cdretorn: cdretorn,
			dsretorn: dsretorn,
			redirect: "html_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				$('#divRetorno').html(response);
				if(cddopcao == "C"){
					layoutConsulta();
				}
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});	
}

function layoutConsulta() {
	
	altura  = '195px';
	largura = '425px';

	// Configura��es da tabela
	var divRegistro = $('div.divRegistros');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
		
	divRegistro.css('height','180px');
		
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];
			
	if ( $.browser.msie ) {	
		
		var arrayLargura = new Array();
		arrayLargura[0] = '60px';
		arrayLargura[1] = '';
	} else {
		var arrayLargura = new Array();
		arrayLargura[0] = '60px';
		arrayLargura[1] = '';
	}	
	
	var arrayAlinha = new Array();
		arrayAlinha[0] = 'right';
		arrayAlinha[1] = 'left';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );		
	
	divRotina.css('width',largura);	
	$('#divRotina').css({'height':altura,'width':largura});
	
	layoutPadrao();	
	hideMsgAguardo();
	removeOpacidade('#divRegistros');
}

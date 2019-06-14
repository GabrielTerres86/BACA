/*!
 * FONTE        : relint.js
 * CRIAÇÃO      : Jorge I. Hamaguchi
 * DATA CRIAÇÃO : 24/07/2013
 * OBJETIVO     : Biblioteca de funções da tela RELINT
 * --------------
 * ALTERAÇÕES   : 
 * -----------------------------------------------------------------------
 */
 
//Formulários e Tabela
var frmCab   		= 'frmCab';
var frmRelint       = 'frmRelint';

//Labels/Campos do cabeçalho
var rCddopcao, rCdagenci, rNmarqtel, cCddopcao, cCdagenci, cNmarqtel;

$(document).ready(function() {
	estadoInicial();
});

// seletores
function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);
	
	fechaRotina( $('#divRotina') );
	hideMsgAguardo();		
	formataCabecalho();
	formataFrmRelint();
	controlaNavegacao();
	
	trocaBotao('Prosseguir');
	
	cTodosCabecalho.limpaFormulario().removeClass('campoErro');	

	highlightObjFocus( $('#'+frmCab) );
	highlightObjFocus( $('#'+frmRelint) );
	
	$('#'+frmCab).css({'display':'block'});
	$('#'+frmRelint).css({'display':'none'});
	$('#divBotoes').css({'display':'none'});
	
	cCddopcao.habilitaCampo();
	cCdagenci.habilitaCampo();
	cNmarqtel.habilitaCampo();
	removeOpacidade('divTela');
		
	$("#cddopcao","#"+frmCab).focus();
	
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


function formataFrmRelint() {
	
	var charPermitidos = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.";
	// Cabecalho
	rCdagenci = $('label[for="cdagenci"]','#'+frmRelint);
	rNmarqtel = $('label[for="nmarqtel"]','#'+frmRelint);
	rCdagenci.addClass('rotulo').css({'width':'100px'});
	rNmarqtel.addClass('rotulo').css({'width':'100px'});
	cCdagenci = $('#cdagenci','#'+frmRelint);
	cNmarqtel = $('#nmarqtel','#'+frmRelint);
	
	cCdagenci.addClass('inteiro campo').css({'width':'80px'}).attr('maxlength','5').setMask('INTEGER','zzzzz','','');
	cNmarqtel.addClass('campo').css({'width':'160px'}).setMask("STRING",30,charPermitidos,"");
	
	layoutPadrao();

	return false;
}


// Formata
function controlaNavegacao() {

	cCddopcao.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			liberaCampos();
			return false;
		}
	});	
	
	cCdagenci.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			if ( $("#tr_nmarqtel").css("display") != "none"){
				cNmarqtel.focus();
			}else{	
				btnContinuar();	
			}
			return false;
		}
	});
	
	cNmarqtel.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			btnContinuar();
			return false;
		}
	});
	
	return false;	
	
}


function liberaCampos() {

	if ( $('#cddopcao','#'+frmCab).hasClass('campoTelaSemBorda')  ) { return false; } ;	
	
	$('#cddopcao','#'+frmCab).desabilitaCampo();
	$('#'+frmRelint).css({'display':'block'});
	$('#divBotoes').css({'display':'block'});
	formataFrmRelint();
	
	$('input, select', '#'+frmRelint).limpaFormulario().removeClass('campoErro');
	
	highlightObjFocus($('#'+frmRelint));
	
	$("#cdagenci","#"+frmRelint).focus();
	if($('#cddopcao','#'+frmCab).val() == "V"){
		$("#tr_nmarqtel").hide();
	}else if($('#cddopcao','#'+frmCab).val() == "R"){
		$("#tr_nmarqtel").show();
	}	
	
	return false;

}


// Botoes
function btnVoltar() {
	estadoInicial();
	return false;
}

function btnContinuar() {	
	if($.trim($("#cdagenci","#"+frmRelint).val()) == ""){
		showError("error","Informe o n&uacute;mero do PA!","Alerta - Ayllos","$('#cdagenci','#"+frmRelint+"').focus();");
		return false;
	}else if (isNaN(parseInt($.trim($("#cdagenci","#"+frmRelint).val())))){
		showError("error","Informe um n&uacute;mero v&aacute;lido do PA!","Alerta - Ayllos","$('#cdagenci','#"+frmRelint+"').focus();");
		return false;
	}else if(parseInt($("#cdagenci","#"+frmRelint).val()) == 0){
		if($("#tr_nmarqtel").css("display") != "none"){
			if(cNmarqtel.val() == ""){
				showError("error","Informe o nome do arquivo a ser gerado!","Alerta - Ayllos","$('#nmarquiv','#"+frmRelint+"').focus();");
				return false;
			}
		}	
		showConfirmacao("Confirma a opera&ccedil;&atilde;o para todos os PA's?","Confirma&ccedil;&atilde;o - Ayllos","Gera_Impressao();","$('#cdagenci','#"+frmRelint+"').focus();","sim.gif","nao.gif");
	}else{
		//Remove a classe de Erro do form
		$('input,select', '#'+frmRelint).removeClass('campoErro');
		Gera_Impressao();
	}
}


function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;" >Voltar</a>&nbsp;');
	
	if (botao != '') {
		$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onclick="btnContinuar(); return false;" >' + botao + '</a>');
	}

	return false;
}

// imprimir
function Gera_Impressao() {	
	
	var cddopcao = $('#cddopcao','#'+frmCab).val();
	var cdagenci = $('#cdagenci','#'+frmRelint).val();
	var nmarqtel = $('#nmarqtel','#'+frmRelint).val();
	
	window.focus();
	
	if(cddopcao == "R"){
		Gera_Arquivo();
		return false;
	}
	
	showMsgAguardo("Aguarde, gerando relatorio...");
	
	cdagenci = normalizaNumero(cdagenci);
	
	$('#cddopcao','#frmImpressao').val(cddopcao);
	$('#cdagenci','#frmImpressao').val(cdagenci);
	$('#nmarqtel','#frmImpressao').val(nmarqtel);
	
	var action = UrlSite + 'telas/relint/manter_rotina.php';
	
	$('#sidlogin','#frmImpressao').remove();
	
	$('#frmImpressao').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '" />');

	carregaImpressaoAyllos("frmImpressao",action,"estadoInicial();");
	
}

function Gera_Arquivo(){

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, gerando arquivo ...");
	
	var cddopcao = $('#cddopcao','#'+frmCab).val();
	var cdagenci = $('#cdagenci','#'+frmRelint).val();
	var nmarqtel = $('#nmarqtel','#'+frmRelint).val();
	
	cdagenci = normalizaNumero(cdagenci);
	
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/relint/manter_rotina.php", 
		data: {
			cddopcao: cddopcao,
			cdagenci: cdagenci,
			nmarqtel: nmarqtel,
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

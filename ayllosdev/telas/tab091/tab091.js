/************************************************************************
  Fonte: tab091.js                                                 
  Autor: Adriano                                                   
  Data : Agosto/2011                  Última Alteração: 18/02/2013 
                                                                  
  Objetivo  : Biblioteca de funções da tela TAB091                 
                                                                  
  Alterações: 18/02/2013 - Ajustes referente ao projeto Cadastro   
						   Restritivo (Adriano).
  ************************************************************************/

var frmCabTab091, frmTab091;

// Variaveis do cabecalho
var cCddopcao;
var cCdcooper;

// Variaveis do frame TAB091
var cDsemail1;
var cDsemail2;
var cDsemail3;
var cDsemail4;
var cDsemail5;


$(document).ready(function() {
	
	frmCabTab091 =  $('#frmCabTab091');
	frmTab091    =  $('#frmTab091');
	
	controlaLayout();	
	
});

function controlaLayout(){

	formataCabecalho();
	estadoInicial();
	layoutPadrao();
	
}

function estadoInicial() {

	$('#cddopcao','#frmCabTab091').habilitaCampo().focus();
	$('#cdcooper','#frmCabTab091').html(slcooper).habilitaCampo();
	$('#divMsgAjuda').css('display','none');
	
	return false;
}

function formataCabecalho(){

	$('#divTela').fadeTo(0,0.1);
		
	removeOpacidade('divTela');		
	
	$('#frmCabTab091').css('display','block');

	var cddopcao = $("#cddopcao","#frmCabTab091").val();
	var rCddopcao = $('label[for="cddopcao"]','#frmCabTab091');
	var rCdcooper = $('label[for="cdcooper"]','#frmCabTab091');
	
		
	rCddopcao.css('width','50px').addClass('rotulo');
	rCdcooper.css('width','80px').addClass('rotulo-linha');
		
		
	cCddopcao = $('#cddopcao','#frmCabTab091');
	cCddopcao.focus();
	cCdcooper = $('#cdcooper','#frmCabTab091');
	cCdcooper.html( slcooper );		
			
	cCddopcao.css('width','320px');
	cCddopcao.habilitaCampo().focus();
	cCdcooper.css('width','125px').attr('maxlength','2');
	cCdcooper.habilitaCampo().focus();
	
	// Se pressionar cCddopcao
	cCddopcao.unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
						
		// Se é a tecla ENTER, TAB, F1
		if ( e.keyCode == 13 || e.keyCode == 9 || e.KeyCode == 18) {
			
			cCdcooper.focus();
			return false;
		
		}

	});		
	
	
	// Se pressionar cCdcooper
	cCdcooper.unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
						
		// Se é a tecla ENTER, F1
		if ( e.keyCode == 13 || e.KeyCode == 18) {
			
			obtemConsulta();
 						
			return false;
		
		}

	});		
	

}

function formataFormulario() {

	$('#divFormulario').css('display','block');
	$('#frmTab091').css('display','block');
	
	highlightObjFocus( $('#divFormulario') );
	
	var rDsemail1	= $('label[for="dsemail1"]','#frmTab091');
	var rDsemail2	= $('label[for="dsemail2"]','#frmTab091');
	var rDsemail3	= $('label[for="dsemail3"]','#frmTab091');
	var rDsemail4	= $('label[for="dsemail4"]','#frmTab091');
	var rDsemail5	= $('label[for="dsemail5"]','#frmTab091');
	
	rDsemail1.css('width', '200px').addClass('rotulo');
	rDsemail2.css('width', '200px').addClass('rotulo');
	rDsemail3.css('width', '200px').addClass('rotulo');
	rDsemail4.css('width', '200px').addClass('rotulo');
	rDsemail5.css('width', '200px').addClass('rotulo');
	
	frmTab091.css({'height':'160px'});
	
	cDsemail1 = $('#dsemail1','#frmTab091');
	cDsemail2 = $('#dsemail2','#frmTab091');
	cDsemail3 = $('#dsemail3','#frmTab091');
	cDsemail4 = $('#dsemail4','#frmTab091');
	cDsemail5 = $('#dsemail5','#frmTab091');
	
	cDsemail1.addClass('email').css('width','250px').attr('maxlength','50');
	cDsemail2.addClass('email').css('width','250px').attr('maxlength','50');
	cDsemail3.addClass('email').css('width','250px').attr('maxlength','50');
	cDsemail4.addClass('email').css('width','250px').attr('maxlength','50');
	cDsemail5.addClass('email').css('width','250px').attr('maxlength','50');
	
	
	cTodos = $('input','#frmTab091');
	
	if( $("#cddopcao","#frmCabTab091").val() == 'C') {
		cTodos.desabilitaCampo();
	}else{
		cTodos.habilitaCampo();
	}
	
	
	// Se pressionar cDsemail1
	cDsemail1.unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
						
		// Se é a tecla ENTER, TAB, F1
		if ( e.keyCode == 13 || e.keyCode == 09 || e.keyCode == 18) {
			cDsemail2.focus();
		
			return false;
		
		}
		
	});		
	
	// Se pressionar cDsemail2
	cDsemail2.unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
						
		// Se é a tecla ENTER, TAB, F1
		if ( e.keyCode == 13 || e.keyCode == 09 || e.keyCode == 18 ) {
			cDsemail3.focus();
		
			return false;
		
		}
				
	});		
	
	// Se pressionar cDsemail3
	cDsemail3.unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
						
		// Se é a tecla ENTER, TAB, F1
		if ( e.keyCode == 13 || e.keyCode == 09 || e.keyCode == 18 ) {
			cDsemail4.focus();
		
			return false;
		
		}
		
	});		
	
	// Se pressionar cDsemail4
	cDsemail4.unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
						
		// Se é a tecla ENTER, TAB, F1
		if ( e.keyCode == 13 || e.keyCode == 09 || e.keyCode == 18 ) {
			cDsemail5.focus();
		
			return false;
		
		}

	});	
	
	// Se pressionar cDsemail5
	cDsemail5.unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
	
		// Se é a tecla ENTER, F1
		if ( e.keyCode == 13 || e.keyCode == 18 ) {
			alteraDados();
		
			return false;
		
		}
		
	});	
	
	
}

function obtemConsulta(){

	var cddopcao = $("#cddopcao","#frmCabTab091").val();
	var cdcooper = $("#cdcooper","#frmCabTab091").val();

	// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");
	
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		dataType: 'html',
		url: UrlSite + "telas/tab091/obtem_consulta.php",
		data: {
			cddopcao: cddopcao,
			cdcooper: cdcooper,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#cddopcao','#frmCabTab091').focus()");							
		},
		success: function(response) {				
			hideMsgAguardo();
			$('#divFormulario').html(response);
			
		}		
		
	});


}

function alteraDados() {

	var cddopcao = $("#cddopcao","#frmCabTab091").val();
	
	if (cddopcao == "A") {
		showConfirmacao('Deseja efetuar a altera&ccedil;&atilde;o?','E-mail','grava_dados();','voltaDiv();estadoInicial();','sim.gif','nao.gif');
	}
}

function grava_dados(){

	var dstextab = formataEmail($("#dsemail1","#frmTab091").val() , $("#dsemail2","#frmTab091").val() , $("#dsemail3","#frmTab091").val(), $("#dsemail4","#frmTab091").val(), $("#dsemail5","#frmTab091").val());
	var cdcooper = $("#cdcooper","#frmCabTab091").val();
	
	// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, enviando informa&ccedil;&otilde;es ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/tab091/grava_dados.php",
		data: {
			dstextab: dstextab,
			cdcooper: cdcooper,
			redirect: "script_ajax" // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#cddopcao','#frmCabTab091').focus()");							
		},
		success: function(response) {				
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();					
			    showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#cddopcao','#frmCabTab091').focus()");							
			}				
		}		
				
	});
}

function voltaDiv(){

	$('#divFormulario').css('display','none');
	cCddopcao.focus();
	
	return false;
}

function formataEmail(dsdemail1, dsdemail2, dsdemail3, dsdemail4, dsdemail5) {

	var retorno = '';
	var email1  = '';
	var email2  = '';
	var email3  = '';
	var email4  = '';
	var email5  = '';
	var i = 0;
	
	
	email1 = dsdemail1;
	email2 = dsdemail2;
	email3 = dsdemail3;
	email4 = dsdemail4;
	email5 = dsdemail5;
	
	for(i = 0; i <= email1.length; i++){
		email1 = email1.replace(",","").replace(";","");
			
	}
	
	for(i = 0; i <= email2.length; i++){
		email2 = email2.replace(",","").replace(";","");
	
	}
	
	for(i = 0; i <= email3.length; i++){
		email3 = email3.replace(",","").replace(";","");
		
	}
	
	for(i = 0; i <= email4.length; i++){
		email4 = email4.replace(",","").replace(";","");
		
	}
	
	for(i = 0; i <= email5.length; i++){
		email5 = email5.replace(",","").replace(";","");
		
	}
	
	retorno = email1 + "," + email2 + "," + email3 + "," + email4 + "," + email5;
	
	return retorno;
	
}

	
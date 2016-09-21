/************************************************************************
	Fonte: mudsen.js
	Autor: Gabriel
	Data : Julho/2011						Ultima Alteracao: 20/11/2012
	
	Objetivo: Funcoes necessarias para a tela MUDSEN.
	
	Alteracoes: 20/11/2012 - Incluso efeito highlightObjFocus e fadeTo, incluso 
				validacao se campo fora preenchido apos pressionar enter
				(Daniel).	

************************************************************************/


$(document).ready(function() {

	$('#frmMudsen').fadeTo(0,0.1);
	
	$('#tdConteudoTela').css({'display':'block'});
	

	highlightObjFocus( $("#frmMudsen") );	

	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});

	var cdoperad = $("#cdoperad","#frmMudsen");

	// Mostrar Botoao de Continuar
	$("#btContinuar","#divMsgAjuda").show();
		
	$("#cdoperad","#frmMudsen").unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			if  ( $("#cdoperad","#frmMudsen").val() == "" ) {
				showError("error","Campo deve ser prenchido.","Alerta - Ayllos","$('#cdoperad','#frmMudsen').focus()");							
				return false;
			} else {
				$("#cdsenha1","#frmMudsen").focus();
				return false;
			}
		}	
	});
	
	$("#cdsenha1","#frmMudsen").unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			if  ( $("#cdsenha1","#frmMudsen").val() == "" ) {
				showError("error","Campo deve ser prenchido.","Alerta - Ayllos","$('#cdsenha1','#frmMudsen').focus()");							
				return false;
			} else {
				$("#cdsenha2","#frmMudsen").focus();
				return false;
			}
		S}	
	});
	
	$("#cdsenha2","#frmMudsen").unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			if  ( $("#cdsenha2","#frmMudsen").val() == "" ) {
				showError("error","Campo deve ser prenchido.","Alerta - Ayllos","$('#cdsenha2','#frmMudsen').focus()");							
				return false;
			} else {
				$("#cdsenha3","#frmMudsen").focus();
				return false;
			}
		}	
	});
	
	$("#cdsenha3","#frmMudsen").unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			if  ( $("#cdsenha2","#frmMudsen").val() == "" ) {
				showError("error","Campo deve ser prenchido.","Alerta - Ayllos","$('#cdsenha2','#frmMudsen').focus()");							
				return false;
			} else {
				altera_senha ();
				return false;
			}
		}	
	});
   
	removeOpacidade('frmMudsen');
	cdoperad.focus();
   
});


// Mostrar a mensagem de Ajuda na tela
function formataMsgAjuda() {

	var divMensagem = $('#divMsgAjuda');
	divMensagem.css({'border':'1px solid #ddd','background-color':'#eee','padding':'2px','height':'20px','margin':'7px 0px'});
	
	var spanMensagem = $('span','#divMsgAjuda');
	spanMensagem.css({'text-align':'left','font-size':'11px','float':'left','padding':'3px'});
	
	var botoesMensagem = $('input','#divMsgAjuda');
	botoesMensagem.css({'display':'none','float':'right','padding-left':'2px','margin-top':'0px'});	
	
	// Mostrar a mensagem de ajuda
	$('input,select').focus( function() {
		
	 spanMensagem.html($(this).attr('alt'));
	 	
	});		 
	
}


function altera_senha () {
	
	var cdoperad = $("#cdoperad","#frmMudsen").val();
	var cdsenha1 = $("#cdsenha1","#frmMudsen").val();
	var cdsenha2 = $("#cdsenha2","#frmMudsen").val();
	var cdsenha3 = $("#cdsenha3","#frmMudsen").val();
	
	// Todos os campos devem ser prenchidos 
	if  (cdoperad == "") {
		showError("error","Campo deve ser prenchido.","Alerta - Ayllos","$('#cdoperad','#frmMudsen').focus()");							
		return;
	}
	if  (cdsenha1 == "") {
		showError("error","Campo deve ser prenchido.","Alerta - Ayllos","$('#cdsenha1','#frmMudsen').focus()");							
		return;
	}
	if  (cdsenha2 == "") {
		showError("error","Campo deve ser prenchido.","Alerta - Ayllos","$('#cdsenha2','#frmMudsen').focus()");							
		return;
	}
	if  (cdsenha3 == "") {
		showError("error","Campo deve ser prenchido.","Alerta - Ayllos","$('#cdsenha3','#frmMudsen').focus()");							
		return;
	}
	
	// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, validando os dados da tela ...");	
	
	$.ajax({
		type: "POST", 
		url: UrlSite + "telas/mudsen/alterar-senha.php",
		data: {
			cdoperad: cdoperad,
			cdsenha1: cdsenha1,
			cdsenha2: cdsenha2,
			cdsenha3: cdsenha3,
			redirect: "script_ajax" // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {				
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#cdoperad','#frmMudsen').focus()");							
		},
		success: function(response) {		
			try {
				eval(response);							
			} catch(error) {						
				hideMsgAguardo();					
			    showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#cdoperad','#frmMudsen').focus()");							
			}	
		}	
	});	
}

function limpaTela () {

	$("input","#frmMudsen").val("");
	$("#cdoperad","#frmMudsen").focus();

}

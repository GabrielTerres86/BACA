/***********************************************************************
 Fonte: tab007.js                                                  
 Autor: Lucas/Gabriel                                                     
 Data : Nov/2011                Última Alteração:  24/10/2012
                                                                   
 Objetivo  : Biblioteca de funções da tela TAB007.                 
                                                                   	 
 Alterações: 24/10/2012 - Alteração layout tela, tratamento opção Voltar
					      Inclusão de efeito fade e highlightObjFocus.
						  Inclusão processo de desabilitação de campo opção
						  e regra para execução no botão OK. Retirado 
						  processo de geração mensagem ajuda no rodape.
						  (Daniel).
************************************************************************/

var cddopcao;
var Cvlmaidep;
var Cvlmaisal;
var Cvlmaiapl;
var Cvlmaicot;
var Cvlsldneg;

var assinc;
var vlmaidep;
var vlmaisal;
var vlmaiapl;
var vlmaicot;
var vlsldneg;

$(document).ready(function() {	

	$('#frmCabTab007').fadeTo(0,0.1);
	$('#frmTab007').fadeTo(0,0.1);
	
	removeOpacidade('frmCabTab007');
	removeOpacidade('frmTab007');
	
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	
	Cvlmaidep =  $('#vlmaidep','#frmTab007');
	Cvlmaisal =  $('#vlmaisal','#frmTab007');
	Cvlmaiapl =  $('#vlmaiapl','#frmTab007');
	Cvlmaicot =  $('#vlmaicot','#frmTab007');
	Cvlsldneg =  $('#vlsldneg','#frmTab007');
	
	Cvlmaidep.desabilitaCampo();
	Cvlmaisal.desabilitaCampo();
	Cvlmaiapl.desabilitaCampo();
	Cvlmaicot.desabilitaCampo();
	Cvlsldneg.desabilitaCampo();
	
	Cvlmaidep.css('width','125px');
	Cvlmaisal.css('width','125px');
	Cvlmaiapl.css('width','125px');
	Cvlmaicot.css('width','125px');
	Cvlsldneg.css('width','125px');
	
	// rotulo
	rCvlmaidep			= $('label[for="vlmaidep"]','#frmTab007'); 
	rCvlmaidep.css('width','170px');
	
	rCvlmaisal			= $('label[for="vlmaisal"]','#frmTab007'); 
	rCvlmaisal.css('width','170px');
	
	rCvlmaiapl			= $('label[for="vlmaiapl"]','#frmTab007'); 
	rCvlmaiapl.css('width','170px');
	
	rCvlmaicot			= $('label[for="vlmaicot"]','#frmTab007'); 
	rCvlmaicot.css('width','170px');
	
	rCvlsldneg			= $('label[for="vlsldneg"]','#frmTab007'); 
	rCvlsldneg.css('width','170px');
	
	
	$("#btAlterar","#divMsgAjuda").hide();
	$("#btVoltar","#divMsgAjuda").hide();

	$('input','#frmTab007').setMask("DECIMAL","zzz.zzz.zz9,99",",");
	
	formataMsgAjuda('');
	
	$("#divMsgAjuda").css('display','block');
	
	$('#cddopcao','#frmCabTab007').focus();
	
	$('#cddopcao','#frmCabTab007').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#btnOK','#frmCabTab007').focus();
			return false;
		}	
	});

});

function define_operacao () {

	// Verifica se campo Opção está desativado.
	if( $('#cddopcao','#frmCabTab007').hasClass('campoTelaSemBorda') ){ return false; }
	
	cTodosCabecalho		= $('input[type="text"],select','#frmCabTab007'); 
	cTodosCabecalho.desabilitaCampo();

	var nomeForm    = 'frmTab007';
	highlightObjFocus( $('#'+nomeForm) );
	
	var nomeForm    = 'frmCabTab007';
	highlightObjFocus( $('#'+nomeForm) );

	cddopcao  = $('#cddopcao','#frmCabTab007').val();
			
	if (cddopcao == "C"){
		assinc = true; //Não sincronizado
		consulta_tab007();
	}
	
	if (cddopcao == "P"){
		assinc = false; //Sincronizado
		permiss_tab007();
	}
}

function confirma() {

	var msgConfirma = "Deseja efetuar a altera&ccedil;&atilde;o do valor ?";
	showConfirmacao(msgConfirma,'Confirma&ccedil;&atilde;o - Ayllos','altera_tab007()','define_operacao()','sim.gif','nao.gif');

}

function consulta_tab007 () {
	
	cddopcao = "C";
	
	mensagem = 'Aguarde, consultando os dados ...';
	
	// Mostra mensagem de aguardo
	showMsgAguardo(mensagem);

	Cvlmaidep.desabilitaCampo();
	Cvlmaisal.desabilitaCampo();
	Cvlmaiapl.desabilitaCampo();
	Cvlmaicot.desabilitaCampo();
	Cvlsldneg.desabilitaCampo();
		
	$("#btAlterar","#divMsgAjuda").hide();
	$("#btVoltar","#divMsgAjuda").show();

	// Carrega dados da conta através de ajax
	$.ajax({		
		type: "POST",
		async: assinc,
		url: UrlSite + "telas/tab007/manter_rotina.php", 
		data: {
			cddopcao:cddopcao,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#cddopcao','#frmTab007').focus()");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();					
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#cddopcao','#frmTab007').focus()");				
			}
		}				
	});
}

function permiss_tab007 () {

	mensagem = 'Aguarde, verificando premissao ...';
	
	// Mostra mensagem de aguardo
	showMsgAguardo(mensagem);
	
	// Carrega dados da conta através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/tab007/manter_rotina.php", 
		data: {
			cddopcao:cddopcao,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#cddopcao','#frmTab007').focus()");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();					
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#cddopcao','#frmTab007').focus()");				
			}
		}				
	});
}


function altera_tab007 () {

	cddopcao = "A";

	vlmaidep = Cvlmaidep.val();
	vlmaisal = Cvlmaisal.val();
	vlmaiapl = Cvlmaiapl.val();
	vlmaicot = Cvlmaicot.val();
	vlsldneg = Cvlsldneg.val();
	
	mensagem = 'Aguarde, alterando os dados ...';
	
	// Mostra mensagem de aguardo
	showMsgAguardo(mensagem);
     
	// Carrega dados da conta através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/tab007/manter_rotina.php", 
		data: {
			cddopcao:cddopcao,
			vlmaidep:vlmaidep,
			vlmaisal:vlmaisal,
			vlmaiapl:vlmaiapl,
			vlmaicot:vlmaicot,
			vlsldneg:vlsldneg,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#cddopcao','#frmTab007').focus()");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();					
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#cddopcao','#frmTab007').focus()");				
			}
		}				
	});
}

function habilita_campos() {

	Cvlmaidep.habilitaCampo();
	Cvlmaisal.habilitaCampo();
	Cvlmaiapl.habilitaCampo();
	Cvlmaicot.habilitaCampo();
	Cvlsldneg.habilitaCampo();
		
	$("#btAlterar","#divMsgAjuda").show();
	$("#btVoltar","#divMsgAjuda").show();
	
	Cvlmaidep.focus();
		
	//Foca no próximo campo caso pressine ENTER 
	Cvlmaidep.keypress( function(e) {
		if ( e.keyCode == 13 ) { 
			Cvlmaiapl.focus();
			return false;
		}		
	});
	Cvlmaiapl.keypress( function(e) {
		if ( e.keyCode == 13 ) { 
			Cvlmaicot.focus();
			return false; 
		}		
	});
	Cvlmaicot.keypress( function(e) {
		if ( e.keyCode == 13 ) { 
			Cvlmaisal.focus();
			return false; 
		}		
	});
	Cvlmaisal.keypress( function(e) {
		if ( e.keyCode == 13 ) { 
			Cvlsldneg.focus();
			return false; 
		}		
	});
	Cvlsldneg.keypress( function(e) {
		if ( e.keyCode == 13 ) { 
			confirma();
			return false; 
		}		
	});
}

// Mostrar a mensagem de Ajuda na tela
function formataMsgAjuda() {
	
	var botoesMensagem = $('input','#divMsgAjuda');
	botoesMensagem.css({'display':'none','float':'right','padding-left':'2px','margin-top':'0px'});	
	
}

function voltar() {

		cTodosCabecalho		= $('input[type="text"],select','#frmCabTab007'); 
		cTodosCabecalho.habilitaCampo();
		$("#btAlterar","#divMsgAjuda").hide();
		$("#btVoltar","#divMsgAjuda").hide();
		$('#cddopcao','#frmCabTab007').focus();
		Cvlmaidep.desabilitaCampo().val('');
		Cvlmaisal.desabilitaCampo().val('');
		Cvlmaiapl.desabilitaCampo().val('');
		Cvlmaicot.desabilitaCampo().val('');
		Cvlsldneg.desabilitaCampo().val('');

}
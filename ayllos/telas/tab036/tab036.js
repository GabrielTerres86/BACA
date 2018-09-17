/***********************************************************************
 Fonte: tab036.js                                                  
 Autor: Lucas/Gabriel                                                     
 Data : Nov/2011                Última Alteração: 25/10/2012  
                                                                   
 Objetivo  : Biblioteca de funções da tela TAB036.                 
                                                                   	 
 Alterações: 25/10/2012 - Incluso função voltaroltar, inclusão do efeito
						  fade e highlightObjFocus, tratamento processo
						  de desabilitação de campo opção e regra para
						  execução no botão OK. Retirado processo de
						  geração mensagem ajuda no rodape. (Daniel)                                                      
************************************************************************/

var cddopcao;
var assinc;

var Lvlrating;
var Lvlgrecon;

var Cvlrating;
var Cvlgrecon;

var vlrating;
var vlgrecon;

$(document).ready(function() {	

	$('#frmCabTab036').fadeTo(0,0.1);
	$('#frmTab036').fadeTo(0,0.1);
	
	removeOpacidade('frmCabTab036');
	removeOpacidade('frmTab036');
	
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});



	$('#cddopcao','#frmCabTab036').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				$('#btnOK','#frmCabTab036').focus();
				return false;
			}	
	});			

	
	Cvlrating = $('#vlrating','#frmTab036');
	Cvlgrecon = $('#vlgrecon','#frmTab036');
	
	Lvlrating	= $('label[for="vlrating"]','#frmTab036');
	Lvlgrecon	= $('label[for="vlgrecon"]','#frmTab036');
	
	Cvlrating.css('width','85px');
	Cvlgrecon.css('width','85px');
	
	Cvlrating.desabilitaCampo();
	Cvlgrecon.desabilitaCampo();
	
	$("#btAlterar","#divMsgAjuda").hide();
	
	$("#btVoltar","#divMsgAjuda").hide();

	Cvlrating.setMask("DECIMAL","zzz.zzz.zz9,99",",");
	Cvlgrecon.setMask("DECIMAL","zz9,99",",");	

	formataMsgAjuda('');
	
	$("#divMsgAjuda").css('display','block'); 
	
	rCvlrating			= $('label[for="vlrating"]','#frmTab036'); 
	rCvlrating.css('width','130px');
	
	rCvlgrecon			= $('label[for="vlgrecon"]','#frmTab036'); 
	rCvlgrecon.css('width','130px');
	
	rpercent			= $('label[for="percent"]','#frmTab036'); 
	rpercent.css('width','140x');
	
	
	$('#cddopcao','#frmCabTab036').focus();
	
});


function define_operacao () {

	// Verifica se campo Opção está desativado.
	if( $('#cddopcao','#frmCabTab036').hasClass('campoTelaSemBorda') ){ return false; }
	
	cTodosCabecalho		= $('input[type="text"],select','#frmCabTab036'); 
	cTodosCabecalho.desabilitaCampo();

	var nomeForm    = 'frmTab036';
	highlightObjFocus( $('#'+nomeForm) );
	
	var nomeForm    = 'frmCabTab036';
	highlightObjFocus( $('#'+nomeForm) );

	cddopcao  = $('#cddopcao','#frmCabTab036').val();
	
	if (cddopcao == "C"){
		assinc = true; //Não sincronizado
		busca_tab036();
		$("#btVoltar","#divMsgAjuda").show();
	}
	
	if (cddopcao == "P"){
		assinc = false; //Sincronizado
		permiss_tab036();
	}

}

function confirma() {

	var msgConfirma = "Deseja efetuar a altera&ccedil;&atilde;o do valor ?";
	showConfirmacao(msgConfirma,'Confirma&ccedil;&atilde;o - Ayllos','altera_tab036()','define_operacao()','sim.gif','nao.gif');

}

function busca_tab036 () {

	cddopcao  = "C";
	
	Cvlrating.desabilitaCampo();
	Cvlgrecon.desabilitaCampo();
			
	$("#btAlterar","#divMsgAjuda").hide();
	$("#btVoltar","#divMsgAjuda").hide();

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando dados ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST",
		async: assinc,
		url: UrlSite + "telas/tab036/manter_rotina.php", 
		data: {
			cddopcao: cddopcao,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#cddopcao','#frmTab036').focus()");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();					
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#cddopcao','#frmTab036').focus()");				
			}
		}				
	}); 
}

function permiss_tab036 () {

	mensagem = 'Aguarde, verificando premissao ...';
	
	// Mostra mensagem de aguardo
	showMsgAguardo(mensagem);
	
	// Carrega dados da conta através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/tab036/manter_rotina.php", 
		data: {
			cddopcao:cddopcao,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#cddopcao','#frmTab036').focus()");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();					
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#cddopcao','#frmTab036').focus()");				
			}
		}				
	});
}

function altera_tab036 () {

	cddopcao  = "A";
	
	vlrating = $('#vlrating','#frmTab036').val();
	vlgrecon = $('#vlgrecon','#frmTab036').val();

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, alterando dados ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/tab036/manter_rotina.php", 
		data: {
			cddopcao: cddopcao,
			vlrating: vlrating,
			vlgrecon: vlgrecon,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#cddopcao','#frmTab036').focus()");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();					
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#cddopcao','#frmTab036').focus()");				
			}
		}				
	}); 
}

function habilita_campos () {

	Cvlrating.habilitaCampo();
	Cvlgrecon.habilitaCampo();
	
	$("#btAlterar","#divMsgAjuda").show();
	$("#btVoltar","#divMsgAjuda").show();
	Cvlrating.focus();
	
	//Foca no próximo campo caso pressine ENTER 
	Cvlrating.keypress( function(e) {
		if ( e.keyCode == 13 ) { 
			Cvlgrecon.focus();
			return false;
		}		
	});
	Cvlgrecon.keypress( function(e) {
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

	cTodosCabecalho		= $('input[type="text"],select','#frmCabTab036'); 
	cTodosCabecalho.habilitaCampo();
	$("#btAlterar","#divMsgAjuda").hide();
	$("#btVoltar","#divMsgAjuda").hide();
	$('#cddopcao','#frmCabTab036').focus();
	$('#vlrating','#frmTab036').desabilitaCampo().val('');
	$('#vlgrecon','#frmTab036').desabilitaCampo().val('');

}

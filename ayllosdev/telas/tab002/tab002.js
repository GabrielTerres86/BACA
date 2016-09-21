/***********************************************************************
 Fonte: tab002.js                                                  
 Autor: Lucas                                                     
 Data : Nov/2011                Última Alteração:  25/10/2012
                                                                   
 Objetivo  : Biblioteca de funções da tela TAB002.                 
                                                                   	 
 Alterações:    23/10/2012 - Retirado processo de geração mensagem ajuda,
							 incluso função de opacidade ao acionar a tela.
							 Incluso função highlightObjFocus.
							 
				25/10/2012 - Incluso processo para desabilitar campo opção e 
							 botão ok. Incluso tratamentos para opção "V"
							 voltar.
							 
************************************************************************/

var cddopcao;
var qtfolind;
var qtfolcjt;

var Cqtfolind;
var Cqtfolcjt;

$(document).ready(function() {	


	$("#btSalvar","#divMsgAjuda").hide();
	$("#btVoltar","#divMsgAjuda").hide();

	$('#frmCabTab002').fadeTo(0,0.1);
	$('#frmTab002').fadeTo(0,0.1);
	
	removeOpacidade('frmCabTab002');
	removeOpacidade('frmTab002');
	
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});

		
	Cqtfolind =  $('#qtfolind','#frmTab002');
	Cqtfolcjt =  $('#qtfolcjt','#frmTab002');
	
	Cqtfolind.desabilitaCampo();
	Cqtfolcjt.desabilitaCampo();
	
	Cqtfolind.css('width','65px');
	Cqtfolcjt.css('width','65px');
	
	$('input','#frmTab002').setMask("INTEGER","zzz",",");
	
	formataMsgAjuda('');
	
	$("#btAlterar","#divMsgAjuda").hide();
	$("#btExcluir","#divMsgAjuda").hide();
	$("#btVoltar","#divMsgAjuda").hide();
	
	$("#divMsgAjuda").css('display','block'); 
	
	$('#cddopcao','#frmCabTab002').focus();
	
	$('#cddopcao','#frmCabTab002').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#btnOK','#frmCabTab002').focus();
			return false;
		}	
	});	
	
	var nomeForm    = 'frmTab002';
	highlightObjFocus( $('#'+nomeForm) );
	
	nomeForm    = 'frmCabTab002';
	highlightObjFocus( $('#'+nomeForm) );
	
});

function confirma (msgConfirma, cddopcao) {
	
	var funcao;
	
	if (cddopcao == "A"){
	
		funcao = "altera_tab002()";
		
	}
	
	if (cddopcao == "E"){
	
		funcao = "exclui_tab002()";
		
	
	}
	
	if (cddopcao == "I"){
	
		funcao = "cria_tab002()";
	
	}
		
	if (cddopcao == "V"){
	
		cTodosCabecalho		= $('input[type="text"],select','#frmCabTab002'); 
		cTodosCabecalho.habilitaCampo();
		$("#btExcluir","#divMsgAjuda").hide();
		$("#btAlterar","#divMsgAjuda").hide();
		$("#btSalvar","#divMsgAjuda").hide();
		$("#btVoltar","#divMsgAjuda").hide();
		$('#cddopcao','#frmCabTab002').focus();
		Cqtfolind.desabilitaCampo().val('');
		Cqtfolcjt.desabilitaCampo().val('');

	} else {	
		showConfirmacao(msgConfirma,'Confirma&ccedil;&atilde;o - Ayllos',funcao,'','sim.gif','nao.gif');
	}
}

function define_operacao() {

	// Verifica se campo Opção está desativado.
	if( $('#cddopcao','#frmCabTab002').hasClass('campoTelaSemBorda') ){ return false; }
	
	var msgConfirma;
	cddopcao = $('#cddopcao','#frmCabTab002').val();

	if (cddopcao == "C"){
		consulta_tab002();
		$("#btVoltar","#divMsgAjuda").show();
	}
	
	
	if (cddopcao == "A"){
	
		consulta_tab002();
		
		//Habilita campos para edição
		Cqtfolind.habilitaCampo();
		Cqtfolcjt.habilitaCampo();
		
		highlightObjFocus( $('#frmCabTab002') );
		highlightObjFocus( $('#frmTab002') );
		
		Cqtfolind.focus();
		
		//Controla botões
		$("#btAlterar","#divMsgAjuda").show();
		$("#btExcluir","#divMsgAjuda").hide();
		$("#btSalvar","#divMsgAjuda").hide();
		$("#btVoltar","#divMsgAjuda").show();
						
	}
	
	if (cddopcao == "E"){
		consulta_tab002();
				
		//Controla botões
		$("#btExcluir","#divMsgAjuda").show();
		$("#btAlterar","#divMsgAjuda").hide();
		$("#btSalvar","#divMsgAjuda").hide();
		$("#btVoltar","#divMsgAjuda").show();
		
	}
	
	if (cddopcao == "I"){
	
		//Habilita campos para edição
		Cqtfolind.habilitaCampo();
		Cqtfolcjt.habilitaCampo();
		
		
		//Limpa Form
		$("#frmTab002").limpaFormulario();
		
		Cqtfolind.focus();
		
		//Controla botões
		$("#btAlterar","#divMsgAjuda").hide();
		$("#btExcluir","#divMsgAjuda").hide();
		$("#btSalvar","#divMsgAjuda").show();
		$("#btVoltar","#divMsgAjuda").show();

	}
	
	cTodosCabecalho		= $('input[type="text"],select','#frmCabTab002'); 
	cTodosCabecalho.desabilitaCampo();
	
	
	//Foca no próximo campo caso pressine ENTER 
	Cqtfolind.keypress( function(e) {
		if ( e.keyCode == 13 ) { 
			Cqtfolcjt.focus();
			return false; 
		}		
	});
	
	Cqtfolcjt.keypress( function(e) {
		if ( e.keyCode == 13 ) { 
		
			cddopcao = $('#cddopcao','#frmCabTab002').val();
		
			//Define a mensagem para Confirmação
			if (cddopcao == "A"){
				msgConfirma = "Deseja efetuar a altera&ccedil;&atilde;o do valor ?";
				confirma(msgConfirma, cddopcao);
			}
			if (cddopcao == "I"){
				msgConfirma = "Deseja criar o registro ?";
				confirma(msgConfirma, cddopcao);
			}
			
			return false; 
		}
	});	
	
}

function consulta_tab002() {

	cddopcao = "C";
	
	Cqtfolind.desabilitaCampo();
	Cqtfolcjt.desabilitaCampo();
	
	$("#btAlterar","#divMsgAjuda").hide();
	$("#btSalvar","#divMsgAjuda").hide();
	$("#btExcluir","#divMsgAjuda").hide();
	
	mensagem = 'Aguarde, buscando os dados ...';
	
	// Mostra mensagem de aguardo
	showMsgAguardo(mensagem);
		
	// Carrega dados da conta através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/tab002/manter_rotina.php", 
		data: {
			cddopcao: cddopcao,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#cddopcao','#frmTab002').focus()");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();					
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#cddopcao','#frmTab002').focus()");				
			}
		}				
	}); 	
	
	
}

function altera_tab002() {

 	cddopcao  = "A";

	qtfolind = Cqtfolind.val();
	qtfolcjt = Cqtfolcjt.val();
	
	
	$('input','#frmTab002').removeClass('campoErro');
	
	
	if (qtfolind == "" || qtfolind == "0") {
		showError("error","026 - Quantidade errada.","Alerta - Ayllos","Cqtfolind.focus();focaCampoErro('qtfolind','frmTab002')");
		return false;				
	}
	
	if (qtfolcjt == "" || qtfolcjt == "0") {
		showError("error","026 - Quantidade errada.","Alerta - Ayllos","Cqtfolcjt.focus();focaCampoErro('qtfolcjt','frmTab002')");
		return false;				
	}
		
	mensagem = 'Aguarde, alterando os dados ...';
	
	// Mostra mensagem de aguardo
	showMsgAguardo(mensagem);
		
	// Carrega dados da conta através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/tab002/manter_rotina.php", 
		data: {
			cddopcao: cddopcao,
			qtfolind: qtfolind,
			qtfolcjt: qtfolcjt,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#cddopcao','#frmTab002').focus()");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();					
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#cddopcao','#frmTab002').focus()");				
			}
		}				
	}); 
	
	$("#btAlterar","#divMsgAjuda").desabilitaCampo();
	
}

function cria_tab002() {

	cddopcao  = "I";

	qtfolind = Cqtfolind.val();
	qtfolcjt = Cqtfolcjt.val();
	
	
	$('input','#frmTab002').removeClass('campoErro');
	
	
	if (qtfolind == "" || qtfolind == "0") {
		showError("error","026 - Quantidade errada.","Alerta - Ayllos","Cqtfolind.focus();focaCampoErro('qtfolind','frmTab002')");
		return false;				
	}
	
	if (qtfolcjt == "" || qtfolcjt == "0") {
		showError("error","026 - Quantidade errada.","Alerta - Ayllos","Cqtfolcjt.focus();focaCampoErro('qtfolcjt','frmTab002')");
		return false;				
	}
		
	mensagem = 'Aguarde, criando os dados ...';
	
	// Mostra mensagem de aguardo
	showMsgAguardo(mensagem);
		
	// Carrega dados da conta através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/tab002/manter_rotina.php", 
		data: {
			cddopcao: cddopcao,
			qtfolind: qtfolind,
			qtfolcjt: qtfolcjt,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#cddopcao','#frmTab002').focus()");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();					
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#cddopcao','#frmTab002').focus()");				
			}
		}				
	}); 
}

function exclui_tab002() {

	cddopcao  = "E";

	mensagem = 'Aguarde, excluindo dados ...';
	
	// Mostra mensagem de aguardo
	showMsgAguardo(mensagem);
		
	// Carrega dados da conta através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/tab002/manter_rotina.php", 
		data: {
			cddopcao: cddopcao,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#cddopcao','#frmTab002').focus()");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();					
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#cddopcao','#frmTab002').focus()");				
			}
		}				
	}); 	
}

// Mostrar a mensagem de Ajuda na tela
function formataMsgAjuda() {

	var botoesMensagem = $('input','#divMsgAjuda');
	botoesMensagem.css({'display':'none','float':'right','padding-left':'2px','margin-top':'0px'});	

}



/***********************************************************************
 Fonte: partrp.js
 Autor: Jean Calao - Mout´s
 Data : Mai/2017               ultima Alteracao: 28/05/2017

 Objetivo  : Biblioteca de funcoes da tela PARTRP

 Alteracoes:
************************************************************************/

var qtfolind;
var qtfolcjt;

// Campos tela

var Cdsvlrprm1;
var Cdsvlrprm2;
var Cdsvlrprm3;
var Cdsvlrprm4;
var Cdsvlrprm5;
var Cdsvlrprm6;
var Cdsvlrprm7;
var Cdsvlrprm8;
var Cdsvlrprm9;

// Array com os labels da tela
var dslabels = ["Data de inicio da vigencia"
			   ,"Produto da transferencia"
			   ,"Operacao"
			   ,"Tipo Produto"
			   ,"Indicador de fraude"
			   ,"Historico para valor principal"
			   ,"Historico estorno valor principal"
			   ,"Historico para juros + 60"
			   ,"Historico estorno juros + 60"
			   ];

$(document).ready(function() {

	$('#frmPARTRP').fadeTo(0,0.1);

	removeOpacidade('frmPARTRP');

	$('fieldset > legend').css({'font-size':'13px','color':'red','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});

	Cdsvlrprm1 = $('#dsvlrprm_1','#frmPARTRP');
	Cdsvlrprm2 = $('#dsvlrprm_2','#frmPARTRP');
	Cdsvlrprm3 = $('#dsvlrprm_3','#frmPARTRP');
	Cdsvlrprm4 = $('#dsvlrprm_4','#frmPARTRP');
	Cdsvlrprm5 = $('#dsvlrprm_5','#frmPARTRP');
	Cdsvlrprm6 = $('#dsvlrprm_6','#frmPARTRP');
	Cdsvlrprm7 = $('#dsvlrprm_7','#frmPARTRP');
	Cdsvlrprm8 = $('#dsvlrprm_8','#frmPARTRP');
	Cdsvlrprm9 = $('#dsvlrprm_9','#frmPARTRP');

	//Cdsvlrprm1.setMask('STRING' ,'99/99/9999' ,'','');
	Cdsvlrprm6.setMask('INTEGER' ,'zzzz'	,'','');
	Cdsvlrprm7.setMask('INTEGER' ,'zzzz'	,'','');
	Cdsvlrprm8.setMask('INTEGER' ,'zzzz'	,'','');
	Cdsvlrprm9.setMask('INTEGER' ,'zzzz'	,'','');
   
	formataMsgAjuda('');

	$("#divBotoes").css('display','block');

	$('#dsvlrprm_1','#frmPARTRP').focus();

	//consulta_partrp();
	
	Cdsvlrprm1.unbind('paste').bind('paste', function(e) { return false; });
	Cdsvlrprm2.unbind('paste').bind('paste', function(e) { return false; });
	Cdsvlrprm3.unbind('paste').bind('paste', function(e) { return false; });
	Cdsvlrprm4.unbind('paste').bind('paste', function(e) { return false; });
	Cdsvlrprm5.unbind('paste').bind('paste', function(e) { return false; });
	Cdsvlrprm6.unbind('paste').bind('paste', function(e) { return false; });
	Cdsvlrprm7.unbind('paste').bind('paste', function(e) { return false; });
	Cdsvlrprm8.unbind('paste').bind('paste', function(e) { return false; });
	Cdsvlrprm9.unbind('paste').bind('paste', function(e) { return false; });
	
    $('#frmPARTRP').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			var idCampo = $(this).attr('id');
			var idUnder = idCampo.indexOf('_') + 1;
			var idIndex = parseInt(idCampo.substr(idUnder,idCampo.lenght));

			// Verifica qual devera ser o proximo indice
			switch (idIndex) {
				case 9:
					idIndex = 0;
					break;
			default:
					idIndex = idIndex + 1;
			}

			if (idIndex > 0) {
				// Foco no proximo campo
				$('#dsvlrprm_' + idIndex,'#frmPARTRP').focus();
			} else  {
				// Foco no botao
				$('#btSalvar' ,'#divBotoes').focus();
			}

			return false;
		}
	});
	
	var nomeForm    = 'frmPARTRP';
	highlightObjFocus( $('#'+nomeForm) );

});

function confirma() {
	var msgConfirma = 'Deseja salvar as informa&ccedil;&otilde;es?';

	showConfirmacao(msgConfirma,'Confirma&ccedil;&atilde;o - Ayllos','altera_partrp();','','sim.gif','nao.gif');

}
/*
function consulta_partrp() {

	mensagem = 'Aguarde, processando ...';
    
	// Mostra mensagem de aguardo
	showMsgAguardo(mensagem);
   
	// Carrega dados da conta atraves de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/partrp/buscar_rotina.php",
		data: {
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function(response) {
		    hideMsgAguardo();
			try {
				eval(response);
				hideMsgAguardo();
			} catch(error) {
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","");
			}
		}
	});

}
*/
function fn_pesquisa() {
    // Captura todos os campos num array
	var dsvlrprm = document.getElementsByName("dsvlrprm");

	mensagem = 'Aguarde, processando ...';

	// Mostra mensagem de aguardo
	showMsgAguardo(mensagem);
   
    if( $("#idfraude","#frmPARTRP").prop("checked") ){
		dsvlrprm[4].value = 'S'; 
	} else {
		dsvlrprm[4].value = 'N'; 
	}
	
	// Carrega dados da conta atraves de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/partrp/buscar_rotina.php",
		data: {dsvlrprm1:  dsvlrprm[0].value,
			dsvlrprm2:  dsvlrprm[1].value,
			dsvlrprm3:  dsvlrprm[2].value,
			dsvlrprm4:  dsvlrprm[3].value,
			dsvlrprm5:  dsvlrprm[4].value,		
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function(response) {
		    hideMsgAguardo();
			try {
				eval(response);
				hideMsgAguardo();
			} catch(error) {
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","");
			}
		}
	});

}

function altera_partrp() {

	// Captura todos os campos num array
	var dsvlrprm = document.getElementsByName("dsvlrprm");

	$('input,textarea','#frmPARTRP').removeClass('campoErro');
	
	if( $("#idfraude","#frmPARTRP").prop("checked") ){
		dsvlrprm[4].value = 'S'; 
	} else {
		dsvlrprm[4].value = 'N'; 
	}
    
	// Percorrer todos os campos da tela
	for (i = 0; i < dsvlrprm.length; i++) {

		if (dsvlrprm[i].value.length == 0 ) {

			// Nao considerar a posicao quando estiver vazia
			if (dslabels[i]=="") { continue; }

			/*Foi realizado esse tratamento pois a forma como a tela foi construida estava
			  impossibilitando adicionar um novo campo sem ter que mexer na estrutura inteira
			  sendo muito perigoso */
			if(i == 11){
				showError("error","Favor informar " + dslabels[i] + ".","Alerta - Ayllos","focaCampoErro('dsvlrprm_11','frmPARTRP');");
				return false;
			}else{
				if(i > 11){
					showError("error","Favor informar " + dslabels[i] + ".","Alerta - Ayllos","focaCampoErro('dsvlrprm_" + (i) + "','frmPARTRP');");
					return false;
				}else{
					showError("error","Favor informar " + dslabels[i] + ".","Alerta - Ayllos","focaCampoErro('dsvlrprm_" + (i+1) + "','frmPARTRP');");
					return false;
				}
			}
		}
	}

	// Percorrer os tres primeiros campos e validar se foi informado valor maior que zero
	for (i = 0; i < 3; i++) {
		if (dsvlrprm[i].value <= 0 ) {
		    showError("error","" + dslabels[i] + " deve ser maior que zero.","Alerta - Ayllos","focaCampoErro('dsvlrprm_" + (i+1) + "','frmPARTRP');");
			return false;
		}
	}
	
	mensagem = 'Aguarde, processando ...';

	// Mostra mensagem de aguardo
	showMsgAguardo(mensagem);
	    
	// Carrega dados da conta atraves de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/partrp/manter_rotina.php",
		data: {
			dsvlrprm1:  dsvlrprm[0].value,
			dsvlrprm2:  dsvlrprm[1].value,
			dsvlrprm3:  dsvlrprm[2].value,
			dsvlrprm4:  dsvlrprm[3].value,
			dsvlrprm5:  dsvlrprm[4].value,
			dsvlrprm6:  dsvlrprm[5].value,
			dsvlrprm7:  dsvlrprm[6].value,
			dsvlrprm8:  dsvlrprm[7].value,
			dsvlrprm9:  dsvlrprm[8].value,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function(response) {
		    hideMsgAguardo();
			showError("inform","Registro salvo com sucesso!","Alerta - Ayllos","");
			try {
				eval(response);
			} catch(error) {
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","");
			}
		}
	});
  
}

// Mostrar a mensagem de Ajuda na tela
function formataMsgAjuda() {

	var botoesMensagem = $('input','#divBotoes');
	botoesMensagem.css({'float':'right','padding-left':'2px','margin-top':'0px'});

} 

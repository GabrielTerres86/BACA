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
var Cdsvlrprm10;
var Cdsvlrprm11;
var Cdsvlrprm12;
var Cdsvlrprm13;
var Cdsvlrprm14;
var Cdsvlrprm15;
var Cdsvlrprm16;
var Cdsvlrprm17;
var Cdsvlrprm18;
var Cdsvlrprm19;
var Cdsvlrprm20;
var Cdsvlrprm21;
var Cdsvlrprm22;
var Cdsvlrprm23;
var Cdsvlrprm24;
var Cdsvlrprm25;

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

	Cdsvlrprm1   = $('#dsvlrprm_1','#frmPARTRP');
	Cdsvlrprm2   = $('#dsvlrprm_2','#frmPARTRP');
	Cdsvlrprm3   = $('#dsvlrprm_3','#frmPARTRP');
	Cdsvlrprm4   = $('#dsvlrprm_4','#frmPARTRP');
	Cdsvlrprm5   = $('#dsvlrprm_5','#frmPARTRP');
	Cdsvlrprm6   = $('#dsvlrprm_6','#frmPARTRP');
	Cdsvlrprm7   = $('#dsvlrprm_7','#frmPARTRP');
	Cdsvlrprm8   = $('#dsvlrprm_8','#frmPARTRP');
	Cdsvlrprm9   = $('#dsvlrprm_9','#frmPARTRP');
	Cdsvlrprm10 = $('#dsvlrprm_10','#frmPARTRP');
	Cdsvlrprm11 = $('#dsvlrprm_11','#frmPARTRP');
	Cdsvlrprm12 = $('#dsvlrprm_12','#frmPARTRP');
	Cdsvlrprm13 = $('#dsvlrprm_13','#frmPARTRP');
	Cdsvlrprm14 = $('#dsvlrprm_14','#frmPARTRP');
	Cdsvlrprm15 = $('#dsvlrprm_15','#frmPARTRP');
	Cdsvlrprm16 = $('#dsvlrprm_16','#frmPARTRP');
	Cdsvlrprm17 = $('#dsvlrprm_17','#frmPARTRP');
	Cdsvlrprm18 = $('#dsvlrprm_18','#frmPARTRP');
	Cdsvlrprm19 = $('#dsvlrprm_19','#frmPARTRP');
	Cdsvlrprm20 = $('#dsvlrprm_20','#frmPARTRP');
	Cdsvlrprm21 = $('#dsvlrprm_21','#frmPARTRP');
	Cdsvlrprm22 = $('#dsvlrprm_22','#frmPARTRP');
	Cdsvlrprm23 = $('#dsvlrprm_23','#frmPARTRP');
	Cdsvlrprm24 = $('#dsvlrprm_24','#frmPARTRP');
	Cdsvlrprm25 = $('#dsvlrprm_25','#frmPARTRP');

	Cdsvlrprm1.setMask('STRING' ,'99/99/9999' ,'','');
	Cdsvlrprm3.setMask('INTEGER' ,'zzzz'	,'','');
    Cdsvlrprm4.setMask('INTEGER' ,'zzzz'	,'','');
    Cdsvlrprm5.setMask('INTEGER' ,'zzzz'	,'','');
    Cdsvlrprm6.setMask('INTEGER' ,'zzzz'	,'','');
	Cdsvlrprm7.setMask('INTEGER' ,'zzzz'	,'','');
	Cdsvlrprm8.setMask('INTEGER' ,'zzzz'	,'','');
	Cdsvlrprm9.setMask('INTEGER' ,'zzzz'	,'','');
    Cdsvlrprm10.setMask('INTEGER' ,'zzzz'	,'','');
    Cdsvlrprm11.setMask('INTEGER' ,'zzzz'	,'','');
    Cdsvlrprm12.setMask('INTEGER' ,'zzzz'	,'','');
    Cdsvlrprm13.setMask('INTEGER' ,'zzzz'	,'','');
    Cdsvlrprm14.setMask('INTEGER' ,'zzzz'	,'','');
    Cdsvlrprm15.setMask('INTEGER' ,'zzzz'	,'','');
    Cdsvlrprm16.setMask('INTEGER' ,'zzzz'	,'','');
    Cdsvlrprm17.setMask('INTEGER' ,'zzzz'	,'','');
    Cdsvlrprm18.setMask('INTEGER' ,'zzzz'	,'','');
    Cdsvlrprm19.setMask('INTEGER' ,'zzzz'	,'','');
    Cdsvlrprm20.setMask('INTEGER' ,'zzzz'	,'','');
    Cdsvlrprm21.setMask('INTEGER' ,'zzzz'	,'','');
    Cdsvlrprm22.setMask('INTEGER' ,'zzzz'	,'','');
    Cdsvlrprm23.setMask('INTEGER' ,'zzzz'	,'','');
    Cdsvlrprm24.setMask('INTEGER' ,'zzzz'	,'','');
    Cdsvlrprm25.setMask('INTEGER' ,'zzzz'	,'','');
    
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
	Cdsvlrprm10.unbind('paste').bind('paste', function(e) { return false; });
	Cdsvlrprm11.unbind('paste').bind('paste', function(e) { return false; });
	Cdsvlrprm12.unbind('paste').bind('paste', function(e) { return false; });
	Cdsvlrprm13.unbind('paste').bind('paste', function(e) { return false; });
	Cdsvlrprm14.unbind('paste').bind('paste', function(e) { return false; });
	Cdsvlrprm15.unbind('paste').bind('paste', function(e) { return false; });
	Cdsvlrprm16.unbind('paste').bind('paste', function(e) { return false; });
	Cdsvlrprm17.unbind('paste').bind('paste', function(e) { return false; });
	Cdsvlrprm18.unbind('paste').bind('paste', function(e) { return false; });
	Cdsvlrprm19.unbind('paste').bind('paste', function(e) { return false; });
	Cdsvlrprm20.unbind('paste').bind('paste', function(e) { return false; });
	Cdsvlrprm21.unbind('paste').bind('paste', function(e) { return false; });
	Cdsvlrprm22.unbind('paste').bind('paste', function(e) { return false; });
	Cdsvlrprm23.unbind('paste').bind('paste', function(e) { return false; });
	Cdsvlrprm24.unbind('paste').bind('paste', function(e) { return false; });
	Cdsvlrprm25.unbind('paste').bind('paste', function(e) { return false; });
	
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
   	
	// Carrega dados da conta atraves de ajax
	$.ajax({
		type: "POST",
		url: UrlSite + "telas/partrp/buscar_rotina.php",
		data: {dsvlrprm1:  dsvlrprm[0].value,
			dsvlrprm2:  dsvlrprm[1].value,
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
	   
	// Percorrer todos os campos da tela
	for (i = 0; i < dsvlrprm.length; i++) {

		if (dsvlrprm[i].value.length == 0 ) {

			// Nao considerar a posicao quando estiver vazia
			if (dslabels[i]=="") { continue; }
     		showError("error","Favor informar " + dslabels[i] + ".","Alerta - Ayllos","focaCampoErro('dsvlrprm_" + (i+1) + "','frmPARTRP');");
			return false;
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
			dsvlrprm10:  dsvlrprm[9].value,
			dsvlrprm11:  dsvlrprm[10].value,
			dsvlrprm12:  dsvlrprm[11].value,
			dsvlrprm13:  dsvlrprm[12].value,
			dsvlrprm14:  dsvlrprm[13].value,
			dsvlrprm15:  dsvlrprm[14].value,
			dsvlrprm16:  dsvlrprm[15].value,
			dsvlrprm17:  dsvlrprm[16].value,
			dsvlrprm18:  dsvlrprm[17].value,
			dsvlrprm19:  dsvlrprm[18].value,
			dsvlrprm20:  dsvlrprm[19].value,
			dsvlrprm21:  dsvlrprm[20].value,
			dsvlrprm22:  dsvlrprm[21].value,
			dsvlrprm23:  dsvlrprm[22].value,
			dsvlrprm24:  dsvlrprm[23].value,
			dsvlrprm25:  dsvlrprm[24].value,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","1-N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function(response) {
		    hideMsgAguardo();
			showError("inform","Registro salvo com sucesso!","Alerta - Ayllos","");
			try {
				eval(response);
			} catch(error) {
				showError("error","2-N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","");
			}
		}
	});
  
}

// Mostrar a mensagem de Ajuda na tela
function formataMsgAjuda() {

	var botoesMensagem = $('input','#divBotoes');
	botoesMensagem.css({'float':'right','padding-left':'2px','margin-top':'0px'});

} 

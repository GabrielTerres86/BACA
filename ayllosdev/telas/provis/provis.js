/***********************************************************************
/***********************************************************************
 Fonte: provis.js                                                  
 Autor: Renato Darosci - Supero                                                    
 Data : Ago/2016                Última Alteração: 31/08/2016
                                                                   
 Objetivo  : Biblioteca de funções da tela PROVIS
                                                                   	 
 Alterações: 					  
							 
************************************************************************/

// Campos tela
var cVlriscoA;
var cVlriscoB;
var cVlriscoC;
var cVlriscoD;
var cVlriscoE;
var cVlriscoF;
var cVlriscoG;
var cVlriscoH;
var cVlriscAA;

$(document).ready(function() {	

	$('#frmCabPROVIS').fadeTo(0,0.1);
	$('#frmPROVIS').fadeTo(0,0.1);
	
	removeOpacidade('frmCabPROVIS');
	removeOpacidade('frmPROVIS');
	
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	
	cVlriscoA = $('#vlriscoA', '#frmPROVIS');
	cVlriscoB = $('#vlriscoB', '#frmPROVIS');
	cVlriscoC = $('#vlriscoC', '#frmPROVIS');
	cVlriscoD = $('#vlriscoD', '#frmPROVIS');
	cVlriscoE = $('#vlriscoE', '#frmPROVIS');
	cVlriscoF = $('#vlriscoF', '#frmPROVIS');
	cVlriscoG = $('#vlriscoG', '#frmPROVIS');
	cVlriscoH = $('#vlriscoH', '#frmPROVIS');
	cVlriscAA = $('#vlriscAA', '#frmPROVIS');
	
	formataMsgAjuda('');
	
	$("#divBotoes").css('display','block'); 
	
    // Consultar os dados e exibir na tela
    consulta_provisaoCL(); 
	
	cVlriscoA.unbind('paste').bind('paste', function (e) { return false; });
	cVlriscoB.unbind('paste').bind('paste', function (e) { return false; });
	cVlriscoC.unbind('paste').bind('paste', function (e) { return false; });
	cVlriscoD.unbind('paste').bind('paste', function (e) { return false; });
	cVlriscoE.unbind('paste').bind('paste', function (e) { return false; });
	cVlriscoF.unbind('paste').bind('paste', function (e) { return false; });
	cVlriscoG.unbind('paste').bind('paste', function (e) { return false; });
	cVlriscoH.unbind('paste').bind('paste', function (e) { return false; });
	cVlriscAA.unbind('paste').bind('paste', function (e) { return false; });

	cVlriscoA.addClass('porcento');
	cVlriscoB.addClass('porcento');
	cVlriscoC.addClass('porcento');
	cVlriscoD.addClass('porcento');
	cVlriscoE.addClass('porcento');
	cVlriscoF.addClass('porcento');
	cVlriscoG.addClass('porcento');
	cVlriscoH.addClass('porcento');
	cVlriscAA.addClass('porcento');
    
    // Campo - Risco AA
	cVlriscAA.unbind('keypress').bind('keypress', function (e) {
	    if (e.keyCode == 9 || e.keyCode == 13) {
	        cVlriscoA.focus();
	    } else return true;
		return false;
	});	
    // Campo - Risco A
	cVlriscoA.unbind('keypress').bind('keypress', function (e) {
	    if (e.keyCode == 9 || e.keyCode == 13) {
	        cVlriscoB.focus();
	    } else return true;
	    return false;
	});
    // Campo - Risco B
	cVlriscoB.unbind('keypress').bind('keypress', function (e) {
	    if (e.keyCode == 9 || e.keyCode == 13) {
	        cVlriscoC.focus();
	    } else return true;
	    return false;
	});
    // Campo - Risco C
	cVlriscoC.unbind('keypress').bind('keypress', function (e) {
	    if (e.keyCode == 9 || e.keyCode == 13) {
	        cVlriscoD.focus();
	    } else return true;
	    return false;
	});
    // Campo - Risco D
	cVlriscoD.unbind('keypress').bind('keypress', function (e) {
	    if (e.keyCode == 9 || e.keyCode == 13) {
	        cVlriscoE.focus();
	    } else return true;
	    return false;
	});
    // Campo - Risco E
	cVlriscoE.unbind('keypress').bind('keypress', function (e) {
	    if (e.keyCode == 9 || e.keyCode == 13) {
	        cVlriscoF.focus();
	    } else return true;
	    return false;
	});
    // Campo - Risco F
	cVlriscoF.unbind('keypress').bind('keypress', function (e) {
	    if (e.keyCode == 9 || e.keyCode == 13) {
	        cVlriscoG.focus();
	    } else return true;
	    return false;
	});
    // Campo - Risco G
	cVlriscoG.unbind('keypress').bind('keypress', function (e) {
	    if (e.keyCode == 9 || e.keyCode == 13) {
	        cVlriscoH.focus();
	    } else return true;
	    return false;
	});
    // Campo - Risco H
	cVlriscoH.unbind('keypress').bind('keypress', function (e) {
	    if (e.keyCode == 9 || e.keyCode == 13) {
	        // Foco no botão
	        $('#btSalvar', '#divBotoes').focus();
	    } else return true;
	    return false;
	});

	var nomeForm = 'frmPROVIS';
	highlightObjFocus( $('#'+nomeForm) );
	
	nomeForm = 'frmCabPROVIS';
	highlightObjFocus( $('#'+nomeForm) );

    // Setar o foco
	cVlriscAA.focus();

    // Configurar o layout
	layoutPadrao();

});

function confirma() {
	
	var msgConfirma = 'Deseja salvar as informa&ccedil;&otilde;es?';
	
	showConfirmacao(msgConfirma,'Confirma&ccedil;&atilde;o - Ayllos','altera_provisaoCL()','','sim.gif','nao.gif');
	
}

function consulta_provisaoCL() {

	mensagem = 'Aguarde, consultando ...';
	
	// Mostra mensagem de aguardo
	showMsgAguardo(mensagem);
		
	// Carrega dados da conta através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/provis/buscar_rotina.php", 
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

function altera_provisaoCL() {
 	
	// Captura todos os campos num array
    var campos = $('input', '#frmPROVIS');
	
    // Remover a classe de erro de todos os campos
	campos.removeClass('campoErro');
	
	// Percorrer todos os campos da tela
	for (i = 0; i < campos.length; i++) {
	    
        // Capturar o label do campo validado, sem os "dois pontos"
	    var label = $("label[for='" + campos[i].id + "']").text().replace(':', '');

		// Se o campo não foi informado
	    if (campos[i].value.length == 0) {

	        showError("error", "Risco \"" + label + "\" deve ser informado.", "Alerta - Ayllos", "focaCampoErro('" + campos[i].id + "','frmPROVIS')");
			return false; 
	    }

	    // Se o campo é maior que 100
	    if (Math.round(parseFloat(campos[i].value.replace(',', '.')) * 100) > 10000) {

	        showError("error", "Risco \"" + label + "\" não pode ser maior que 100.", "Alerta - Ayllos", "focaCampoErro('" + campos[i].id + "','frmPROVIS')");
	        return false;
	    }
	}
	
	mensagem = 'Aguarde, processando ...';
	
	// Mostra mensagem de aguardo
	showMsgAguardo(mensagem);

	// Carrega dados da conta através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/provis/manter_rotina.php", 
		data: {
		    vlriscoA: cVlriscoA.val(),
		    vlriscoB: cVlriscoB.val(),
		    vlriscoC: cVlriscoC.val(),
		    vlriscoD: cVlriscoD.val(),
		    vlriscoE: cVlriscoE.val(),
		    vlriscoF: cVlriscoF.val(),
		    vlriscoG: cVlriscoG.val(),
		    vlriscoH: cVlriscoH.val(),
            vlriscAA: cVlriscAA.val(),
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function(response) {
		    hideMsgAguardo();
		    showError("inform", "Registro salvo com sucesso!", "Alerta - Ayllos", "consulta_provisaoCL();");
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

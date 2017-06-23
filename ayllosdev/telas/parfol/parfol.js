/***********************************************************************
/***********************************************************************
 Fonte: parfol.js                                                  
 Autor: Renato Darosci - Supero                                                    
 Data : Mai/2015                Última Alteração: 12/05/2017
                                                                   
 Objetivo  : Biblioteca de funções da tela PARFOL
                                                                   	 
 Alterações: 21/10/2015 - Remocao da cddopcao que nao eh usada jah que a
                          tela nao possui meno, vai direto para o acesso
			         	  (Marcos-Supero)   
						  
            23/11/2015 - Desconsiderando a posicao 4 do array de acessos
						(Andre Santos - SUPERO)	  						  
							 
			19/01/2017 - Adicionado novo limite de horario para pagamento no dia
                         para contas da cooperativa. (M342 - Kelvin)			
			
			12/05/2017 - Segunda fase da melhoria 342 (Kelvin).
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
var dslabels = ["Qtde meses cancelamento automático"
			   ,"Qtde dias para envio comprovantes"
			   ,"Nro meses para emissão dos Comprovantes"
			   ,"" // Antigo Histórico Débito Tarifa
			   ,"Histórico Estorno Outras Empresas"
			   ,"Histórico Estorno para Cooperativas"
			   ,"E-mails para alerta na Central"
			   ,"Agendamento"
			   ,"Portabilidade (Pgto no dia)"
			   ,"Solicitação Estouro Conta"
			   ,"Liberação Estouro Conta"
			   ,"Pagto no dia (contas cooperativa)"
			   ,"Lote"
			   ,"Histórico Crédito TEC"
			   ,"Histórico Débito TEC"
			   ,"Histórico Recusa TEC"
			   ,"Histórico Devolução TEC"
			   ,"Histórico Devolução Empresa"
               ,"Lote TRF"
               ,"Histórico Débito TRF"
               ,"Histórico Crédito TRF"
			   ,"E-mails para alerta ao Financeiro"
			   ,"Habilita Transferência"
			   ,"Horário Limite (Transf no Dia)"
			   ,"Tarifa"];

$(document).ready(function() {	

	$('#frmCabPARFOL').fadeTo(0,0.1);
	$('#frmPARFOL').fadeTo(0,0.1);
	
	removeOpacidade('frmCabPARFOL');
	removeOpacidade('frmPARFOL');
	
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	
	Cdsvlrprm1 = $('#dsvlrprm_1','#frmPARFOL');
	Cdsvlrprm2 = $('#dsvlrprm_2','#frmPARFOL');	
	Cdsvlrprm3 = $('#dsvlrprm_3','#frmPARFOL');
	Cdsvlrprm4 = $('#dsvlrprm_4','#frmPARFOL');
	Cdsvlrprm5 = $('#dsvlrprm_5','#frmPARFOL');
	Cdsvlrprm6 = $('#dsvlrprm_6','#frmPARFOL');
	Cdsvlrprm7 = $('#dsvlrprm_7','#frmPARFOL');
	Cdsvlrprm8 = $('#dsvlrprm_8','#frmPARFOL');
	Cdsvlrprm9 = $('#dsvlrprm_9','#frmPARFOL');	
	Cdsvlrprm10= $('#dsvlrprm_10','#frmPARFOL');
	Cdsvlrprm11= $('#dsvlrprm_11','#frmPARFOL');
	Cdsvlrprm12= $('#dsvlrprm_12','#frmPARFOL');
	Cdsvlrprm13= $('#dsvlrprm_13','#frmPARFOL');
	Cdsvlrprm14= $('#dsvlrprm_14','#frmPARFOL');
	Cdsvlrprm15= $('#dsvlrprm_15','#frmPARFOL');
	Cdsvlrprm16= $('#dsvlrprm_16','#frmPARFOL');
	Cdsvlrprm17= $('#dsvlrprm_17','#frmPARFOL');
	Cdsvlrprm18= $('#dsvlrprm_18','#frmPARFOL');
	Cdsvlrprm19= $('#dsvlrprm_19','#frmPARFOL');
	Cdsvlrprm20= $('#dsvlrprm_20','#frmPARFOL');
	Cdsvlrprm21= $('#dsvlrprm_21','#frmPARFOL');
	Cdsvlrprm22= $('#dsvlrprm_22','#frmPARFOL');
	Cdsvlrprm23= $('#dsvlrprm_23','#frmPARFOL');
	Cdsvlrprm24= $('#dsvlrprm_24','#frmPARFOL');
	Cdsvlrprm25= $('#dsvlrprm_25','#frmPARFOL');
	
	Cdsvlrprm1.setMask('INTEGER' ,'zz'     	,'','');
	Cdsvlrprm2.setMask('INTEGER' ,'zz'		,'','');
	Cdsvlrprm3.setMask('INTEGER' ,'zz'		,'','');
	Cdsvlrprm4.setMask('INTEGER' ,'zzzz'	,'','');
    Cdsvlrprm5.setMask('INTEGER' ,'zzzz'	,'','');	
	Cdsvlrprm6.setMask('INTEGER' ,'zzzz'	,'','');
	
	Cdsvlrprm8.mask('00:00');
	Cdsvlrprm8.setMask('STRING','99:99',':','');
	
	Cdsvlrprm9.mask('00:00');
	Cdsvlrprm9.setMask('STRING','99:99',':','');
	
	Cdsvlrprm10.mask('00:00');
	Cdsvlrprm10.setMask('STRING','99:99',':','');
	
	Cdsvlrprm11.mask('00:00');
	Cdsvlrprm11.setMask('STRING','99:99',':','');
	
	Cdsvlrprm12.setMask('INTEGER','zzzzz'	,'','');
	Cdsvlrprm13.setMask('INTEGER','zzzz'	,'','');
	Cdsvlrprm14.setMask('INTEGER','zzzz'	,'','');
	Cdsvlrprm15.setMask('INTEGER','zzzz'	,'','');
	Cdsvlrprm16.setMask('INTEGER','zzzz'	,'','');
	Cdsvlrprm17.setMask('INTEGER','zzzz'	,'','');
	Cdsvlrprm18.setMask('INTEGER','zzzzz'	,'','');
	Cdsvlrprm19.setMask('INTEGER','zzzz'	,'','');
	Cdsvlrprm20.setMask('INTEGER','zzzz'	,'','');
	
	Cdsvlrprm22.mask('00:00');
	Cdsvlrprm22.setMask('STRING','99:99',':','');
	
	Cdsvlrprm24.mask('00:00');
	Cdsvlrprm24.setMask('STRING','99:99',':','');
	
	formataMsgAjuda('');
	
	$("#divBotoes").css('display','block'); 
	
	$('#dsvlrprm_1','#frmPARFOL').focus();
	
	consulta_parfol();
	
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
	Cdsvlrprm17.unbind('paste').bind('paste', function(e) { return false; });
	Cdsvlrprm18.unbind('paste').bind('paste', function(e) { return false; });
	Cdsvlrprm19.unbind('paste').bind('paste', function(e) { return false; });	
	Cdsvlrprm20.unbind('paste').bind('paste', function(e) { return false; });
	Cdsvlrprm21.unbind('paste').bind('paste', function(e) { return false; });
	Cdsvlrprm22.unbind('paste').bind('paste', function(e) { return false; });
	Cdsvlrprm23.unbind('paste').bind('paste', function(e) { return false; });
	Cdsvlrprm24.unbind('paste').bind('paste', function(e) { return false; });
	Cdsvlrprm25.unbind('paste').bind('paste', function(e) { return false; });
	
	$('.campo','#frmPARFOL').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			var idCampo = $(this).attr('id');
			var idUnder = idCampo.indexOf('_') + 1;
			var idIndex = parseInt(idCampo.substr(idUnder,idCampo.lenght));

			// Verifica qual deverá ser o próximo indice
			switch (idIndex) {
				case 21:
					idIndex = 0;
					break;
				case 3: 
					/* Ignorar o Index 4 - Ir para o Proximo */				
					idIndex = 5;
					break;
				default:
					idIndex = idIndex + 1;
			}

			if (idIndex > 0) {
				// Foco no próximo campo
				$('#dsvlrprm_' + idIndex,'#frmPARFOL').focus();
			} else  {
				// Foco no botão
				$('#btSalvar' ,'#divBotoes').focus();
			}
			
			return false;
		}
	});	
	
	Cdsvlrprm23.change(function() {
		if (Cdsvlrprm23.val() == "0"){
			Cdsvlrprm25.prop('disabled', true);
			Cdsvlrprm25.val("0");
			Cdsvlrprm24.prop('disabled', true);	
		} else {
			Cdsvlrprm25.prop('disabled', false);						
			Cdsvlrprm24.prop('disabled', false);	
		}
		
			
	});
	
	
	var nomeForm    = 'frmPARFOL';
	highlightObjFocus( $('#'+nomeForm) );
	
	nomeForm    = 'frmCabPARFOL';
	highlightObjFocus( $('#'+nomeForm) );
	
	
	
});

function confirma() {
	
	var msgConfirma = 'Deseja salvar as informa&ccedil;&otilde;es?';
	
	showConfirmacao(msgConfirma,'Confirma&ccedil;&atilde;o - Ayllos','altera_parfol()','','sim.gif','nao.gif');
	
}

function consulta_parfol() {

	mensagem = 'Aguarde, processando ...';
	
	// Mostra mensagem de aguardo
	showMsgAguardo(mensagem);
		
	// Carrega dados da conta através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/parfol/buscar_rotina.php", 
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

function altera_parfol() {
 	
	// Captura todos os campos num array
	var dsvlrprm = document.getElementsByName("dsvlrprm");
	
	$('input,textarea','#frmPARFOL').removeClass('campoErro');
	
	// Percorrer todos os campos da tela
	for (i = 0; i < dsvlrprm.length; i++) {
		
		if (dsvlrprm[i].value.length == 0 ) {

			// Nao considerar a posicao quando estiver vazia
			if (dslabels[i]=="") { continue; }
			/*Foi realizado esse tratamento pois a forma como a tela foi construida estava
			  impossibilitando adicionar um novo campo sem ter que mexer na estrutura inteira
			  sendo muito perigoso */
			if(i == 11){
				showError("error","Favor informar " + dslabels[i] + ".","Alerta - Ayllos","focaCampoErro('dsvlrprm_" + (22) + "','frmPARFOL')");
				return false;
			}else{
				if(i > 11 && i < 22){
					showError("error","Favor informar " + dslabels[i] + ".","Alerta - Ayllos","focaCampoErro('dsvlrprm_" + (i) + "','frmPARFOL')");
					return false;
				}else{
		    showError("error","Favor informar " + dslabels[i] + ".","Alerta - Ayllos","focaCampoErro('dsvlrprm_" + (i+1) + "','frmPARFOL')");
			return false; 
		}
	}
		}
	}
	
	// Percorrer os três primeiros campos e validar se foi informado valor maior que zero
	for (i = 0; i < 3; i++) {
		if (dsvlrprm[i].value <= 0 ) {
		    showError("error","" + dslabels[i] + " deve ser maior que zero.","Alerta - Ayllos","focaCampoErro('dsvlrprm_" + (i+1) + "','frmPARFOL')");
			return false; 
		}
	}
	
	// Validar o textarea de Emails da Central
	if (Cdsvlrprm7.val().length == 0) {
		showError("error","Favor informar " + dslabels[6] + ".","Alerta - Ayllos","focaCampoErro('dsvlrprm_7','frmPARFOL')");
		return false; 
	}
	
	// Validar o textarea de Emails do Financeiro
	if (Cdsvlrprm21.val().length == 0) {
		showError("error","Favor informar " + dslabels[21] + ".","Alerta - Ayllos","focaCampoErro('dsvlrprm_21','frmPARFOL')");
		return false; 
	}
	
	// Remover quebras de linha do campo de e-mail
	var dsSemQuebra1 = Cdsvlrprm7.val();
	// Enquanto houver quebras de linha
	while (dsSemQuebra1.indexOf("\n") >= 0) {
		dsSemQuebra1 = dsSemQuebra1.replace("\n","");
	}
	dsSemQuebra2 = Cdsvlrprm21.val();
	// Enquanto houver quebras de linha
	while (dsSemQuebra2.indexOf("\n") >= 0) {
		dsSemQuebra2 = dsSemQuebra2.replace("\n","");
	}
	
	mensagem = 'Aguarde, processando ...';
	
	// Mostra mensagem de aguardo
	showMsgAguardo(mensagem);

	// Carrega dados da conta através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/parfol/manter_rotina.php", 
		data: {
			dsvlrprm1:  dsvlrprm[0].value,
			dsvlrprm2:  dsvlrprm[1].value,
			dsvlrprm3:  dsvlrprm[2].value,
			dsvlrprm4:  dsvlrprm[3].value,
			dsvlrprm5:  dsvlrprm[4].value,
			dsvlrprm6:  dsvlrprm[5].value,
			dsvlrprm7:  dsSemQuebra1,
			dsvlrprm8:  dsvlrprm[7].value,
			dsvlrprm9:  dsvlrprm[8].value,
			dsvlrprm10: dsvlrprm[9].value,
			dsvlrprm11: dsvlrprm[10].value,
			dsvlrprm12: dsvlrprm[12].value,
			dsvlrprm13: dsvlrprm[13].value,
			dsvlrprm14: dsvlrprm[14].value,
			dsvlrprm15: dsvlrprm[15].value,
			dsvlrprm16: dsvlrprm[16].value,
			dsvlrprm17: dsvlrprm[17].value,
			dsvlrprm18: dsvlrprm[18].value,
			dsvlrprm19: dsvlrprm[19].value,
			dsvlrprm20: dsvlrprm[20].value,
			dsvlrprm21: dsSemQuebra2,
			dsvlrprm22: dsvlrprm[11].value,
			dsvlrprm23: dsvlrprm[22].value,
			dsvlrprm24: dsvlrprm[23].value,
			dsvlrprm25: dsvlrprm[24].value,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function(response) {
		    hideMsgAguardo();
			showError("inform","Registro salvo com sucesso!","Alerta - Ayllos","consulta_parfol();");
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

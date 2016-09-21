/*!
 * FONTE        : resultado.js
 * CRIA��O      : Gabriel Capoia (DB1)
 * DATA CRIA��O : Abril/2010 
 * OBJETIVO     : Biblioteca de fun��es da rotina Resultado da tela de CONTAS
 *
 * ALTERACOES   : 05/08/2015 - Reformulacao cadastral (Gabriel-RKAM)
 */
var operacao = '';
var flgContinuar = false;

// Fun��o para acessar op��es da rotina
function acessaOpcaoAba(nrOpcoes,id,opcao) {  
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando dados de Resultado ...");
	
	// Atribui cor de destaque para aba da op��o
	for (var i = 0; i < nrOpcoes; i++) {
		if (id == i) { // Atribui estilos para foco da op��o
			$("#linkAba" + id).attr("class","txtBrancoBold");
			$("#imgAbaEsq" + id).attr("src",UrlImagens + "background/mnu_sle.gif");				
			$("#imgAbaDir" + id).attr("src",UrlImagens + "background/mnu_sld.gif");
			$("#imgAbaCen" + id).css("background-color","#969FA9");
			continue;			
		}
		
		$("#linkAba" + i).attr("class","txtNormalBold");
		$("#imgAbaEsq" + i).attr("src",UrlImagens + "background/mnu_nle.gif");			
		$("#imgAbaDir" + i).attr("src",UrlImagens + "background/mnu_nld.gif");
		$("#imgAbaCen" + i).css("background-color","#C6C8CA");
	}

	// Carrega conte�do da op��o atrav�s de ajax
	$.ajax({		
		type: "POST", 
		dataType: "html",
		url: UrlSite + "telas/contas/resultado/principal.php",
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			flgcadas: flgcadas,
			operacao: operacao,
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss�vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',bloqueiaFundo(divRotina));
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 ) {
				$('#divConteudoOpcao').html(response);
			} else {
				eval( response );
				controlaFoco( operacao );
			}
			return false;
		}				
	});
		
}

function controlaOperacao(operacao, msgRetorno) {

	// Verifica permiss�es de acesso
	if ( (operacao == 'CA') && (flgAlterar != '1') ) { 
		showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de altera&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina);');
		return false;
	} 
		
	// Mostra mensagem de aguardo
	var msgOperacao = '';
	switch (operacao) {			
		// Consulta para Altera��o
		case 'CA': 
			msgOperacao = 'abrindo altera&ccedil;&atilde;o';
			break;
		// Altera��o para Consulta
		case 'AC': 
			showConfirmacao('Deseja cancelar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','controlaOperacao()','bloqueiaFundo(divRotina)','sim.gif','nao.gif');
			return false;
			break;	
		// Altera��o para Valida��o - Validando Altera��o
		case 'AV': 
			manterRotina(operacao);
			return false;
			break;	
		// Valida��o para Altera��o - Salvando Altera��o
		case 'VA': 
			manterRotina(operacao);
			return false;
			break;				
		// Qualquer outro valor: Cancelando Opera��o
		default: 
			msgOperacao = 'abrindo consulta';
			break;			
	}
	
	showMsgAguardo('Aguarde, ' + msgOperacao + '...');
	
	// Executa script de atrav�s de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/contas/resultado/principal.php', 
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			flgcadas: flgcadas,
			operacao: operacao,
			redirect: "html_ajax"
		},  
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss�vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 ) {
				$('#divConteudoOpcao').html(response);
			} else {
				eval( response );
				controlaFoco( operacao );
			}
			return false;
		}				
	});			
}

function manterRotina(operacao) {

	hideMsgAguardo();		
	var msgOperacao = '';
	switch (operacao) {	
		case 'VA': msgOperacao = 'salvando altera&ccedil;&atilde;o'; break;
		case 'AV': msgOperacao = 'validando altera&ccedil;&atilde;o'; break;										
		default: return false; break;
	}
	showMsgAguardo('Aguarde, ' + msgOperacao + '...');
	
	
	var vlrctbru = number_format(parseFloat($('#vlrctbru','#frmDadosResultados').val().replace(/[.R$ ]*/g,'').replace(',','.')),2,',','');
	var vlctdpad = number_format(parseFloat($('#vlctdpad','#frmDadosResultados').val().replace(/[.R$ ]*/g,'').replace(',','.')),2,',','');
	var vldspfin = number_format(parseFloat($('#vldspfin','#frmDadosResultados').val().replace(/[.R$ ]*/g,'').replace(',','.')),2,',','');
	var ddprzpag = $('#ddprzpag','#frmDadosResultados').val();
	var ddprzrec = $('#ddprzrec','#frmDadosResultados').val();
	var dtaltjfn = $('#dtaltjfn','#frmDadosResultados').val();
	
	$.ajax({		
		type: 'POST',
		url: UrlSite + 'telas/contas/resultado/manter_rotina.php', 		
		data: {
			nrdconta: nrdconta, idseqttl: idseqttl, 			
			vlrctbru: vlrctbru, vlctdpad: vlctdpad,             
            vldspfin: vldspfin, ddprzrec: ddprzrec,             
            ddprzpag: ddprzpag, dtaltjfn: dtaltjfn,             
			flgcadas: flgcadas, operacao: operacao,                                 
			redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			try {
				eval(response);
				
				if (operacao == 'VA' && (flgContinuar == true || flgcadas == 'M') ) {
					proximaRotina();
				}
				
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
			}
		}				
	});
}

function controlaLayout(operacao) {
	
	var rotulos = $('label[for="vlrctbru"],label[for="vlctdpad"],label[for="vldspfin"],label[for="ddprzrec"],label[for="ddprzpag"]','#frmDadosResultados');	
	var campos  = $('#vlrctbru,#vlctdpad,#vldspfin,#ddprzrec,#ddprzpag','#frmDadosResultados');	
	
	altura  = '250px';
	largura = '554px';
	divRotina.css('width',largura);	
	$('#divConteudoOpcao').css('height',altura);
	
	// Sempre inicia com tudo bloqueado
	campos.removeClass('campo').addClass('campoTelaSemBorda').prop('disabled',true);
	
	// Formata��o dos rotulos
	rotulos.addClass('rotulo rotulo-250');
	$('label[for="dtaltjfn"]','div.divFinanc').addClass('rotulo').css({'width':'170px'});
	$('label[for="cdoperad"]','div.divFinanc').css({'width':'70px'});
			
	//formata��o dos campos
	$('#vlrctbru,#vlctdpad,#vldspfin','#frmDadosResultados').attr('maxlength','14').css({'width':'100px'});
	$('#ddprzrec,#ddprzpag','#frmDadosResultados').attr('maxlength','3').css({'width':'40px'});
	
	$('#dtaltjfn','div.divFinanc').css({'width':'74px'});
	$('#cdoperad','div.divFinanc').css({'width':'58px'});
	$('#nmoperad','div.divFinanc').css({'width':'140px'});
	$('#dtaltjfn,#cdoperad,#nmoperad','div.divFinanc').removeClass('campo').addClass('campoTelaSemBorda').prop('disabled',true);
	
	switch(operacao) {
	
		// Consulta Altera��o
		case 'CA': 
			campos.removeClass('campoTelaSemBorda').addClass('campo').removeProp('disabled');
			break;
			
		default: 
			break;
	}
	
	$("#ddprzpag","#frmDadosResultados").unbind("keydown").bind("keydown",function(e) {
		if (e.keyCode == 13) {
			$("#btSalvar","#divBotoes").trigger("click");
			return false;
		}	
	});		
			
	layoutPadrao();
	hideMsgAguardo();
	bloqueiaFundo(divRotina);
	removeOpacidade('divConteudoOpcao');
	highlightObjFocus($('#frmDadosResultados'));
	controlaFocoEnter("frmDadosResultados");
	controlaFoco(operacao);
	divRotina.centralizaRotinaH();	
	return false;	
}	

function controlaFoco(operacao) {
	if (in_array(operacao,['AC',''])) {
		$('#btAlterar','#divBotoes').focus();
	} else {
		$('#vlrctbru','#frmDadosResultados').focus();
	}
	return false;
}

function controlaContinuar () {
 
 flgContinuar = true;
  
  if ($("#btAlterar","#divBotoes").length > 0) {
    proximaRotina();
 } else {
    controlaOperacao('AV');
 }
 
}
function voltarRotina() {
	fechaRotina(divRotina);
	acessaRotina('FINANCEIRO-BANCO','Banco','banco');	
}

function proximaRotina () {
	hideMsgAguardo();
	encerraRotina(false);
	acessaRotina('FINANCEIRO-FATURAMENTO','Faturamento','faturamento');				
}
/*!
 * FONTE        : ativo_passvo.js
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : Abril/2010 
 * OBJETIVO     : Biblioteca de funções da rotina Ativo/Passivo da tela de CONTAS
 *
 * ALTERACOES   : [05/08/2015] Gabriel (RKAM) : Reformulacao cadastral. 
 */

var operacao = '';
var flgContinuar = false;

function acessaOpcaoAba(nrOpcoes,id,opcao) {  
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando...");
	
	// Atribui cor de destaque para aba da opção
	for (var i = 0; i < nrOpcoes; i++) {
		if (id == i) { // Atribui estilos para foco da opção
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

	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		dataType: "html",
		url: UrlSite + "telas/contas/ativo_passivo/principal.php",
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			flgcadas: flgcadas,
			operacao: operacao,
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro',bloqueiaFundo(divRotina));
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

	// Verifica permissões de acesso
	if ( (operacao == 'CA') && (flgAlterar != '1') ) { 
		showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de altera&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		return false;
	} 
		
	// Mostra mensagem de aguardo
	var msgOperacao = '';
	switch (operacao) {			
		// Consulta para Alteração
		case 'CA': 
			msgOperacao = 'abrindo altera&ccedil;&atilde;o';
			break;
		// Alteração para Consulta
		case 'AC': 
			showConfirmacao('Deseja cancelar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','controlaOperacao()','bloqueiaFundo(divRotina)','sim.gif','nao.gif');
			return false;
			break;	
		// Alteração para Validação - Validando Alteração
		case 'AV': 
			manterRotina(operacao);
			return false;
			break;	
		// Validação para Alteração - Salvando Alteração
		case 'VA': 
			manterRotina(operacao);
			return false;
			break;				
		// Qualquer outro valor: Cancelando Operação
		default: 
			msgOperacao = 'abrindo tela';
			break;			
	}
	
	showMsgAguardo('Aguarde, ' + msgOperacao + '...');
	
	// Executa script de através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/contas/ativo_passivo/principal.php', 
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			flgcadas: flgcadas,
			operacao: operacao,
			redirect: "html_ajax"
		},  
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
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
	showMsgAguardo('Aguarde, ' + msgOperacao + ' ...');
	
	var mesdbase = $('#mesdbase','#frmAtivoPassivo').val();
	var anodbase = $('#anodbase','#frmAtivoPassivo').val();
	var vlcxbcaf = number_format(parseFloat($('#vlcxbcaf','#frmAtivoPassivo').val().replace(/[.R$ ]*/g,'').replace(',','.')),2,',','');
	var vlctarcb = number_format(parseFloat($('#vlctarcb','#frmAtivoPassivo').val().replace(/[.R$ ]*/g,'').replace(',','.')),2,',','');
	var vlrestoq = number_format(parseFloat($('#vlrestoq','#frmAtivoPassivo').val().replace(/[.R$ ]*/g,'').replace(',','.')),2,',','');
	var vloutatv = number_format(parseFloat($('#vloutatv','#frmAtivoPassivo').val().replace(/[.R$ ]*/g,'').replace(',','.')),2,',','');
	var vlrimobi = number_format(parseFloat($('#vlrimobi','#frmAtivoPassivo').val().replace(/[.R$ ]*/g,'').replace(',','.')),2,',','');
	var vlfornec = number_format(parseFloat($('#vlfornec','#frmAtivoPassivo').val().replace(/[.R$ ]*/g,'').replace(',','.')),2,',','');
	var vloutpas = number_format(parseFloat($('#vloutpas','#frmAtivoPassivo').val().replace(/[.R$ ]*/g,'').replace(',','.')),2,',','');
	var vldivbco = number_format(parseFloat($('#vldivbco','#frmAtivoPassivo').val().replace(/[.R$ ]*/g,'').replace(',','.')),2,',','');
	var dtaltjfn = $('#dtaltjfn','#frmAtivoPassivo').val();
	var cdopejfn = $('#cdopejfn','#frmAtivoPassivo').val();
	
	$.ajax({		
		type: 'POST',
		url: UrlSite + 'telas/contas/ativo_passivo/manter_rotina.php', 		
		data: {
			nrdconta: nrdconta, idseqttl: idseqttl, 
			mesdbase: mesdbase, anodbase: anodbase,
            vlcxbcaf: vlcxbcaf, vlctarcb: vlctarcb,
            vlrestoq: vlrestoq, vloutatv: vloutatv,
            vlrimobi: vlrimobi, vlfornec: vlfornec,
            vloutpas: vloutpas, vldivbco: vldivbco,
            dtaltjfn: dtaltjfn, cdopejfn: cdopejfn,
			operacao: operacao, flgcadas: flgcadas,
			redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			try {
				eval(response);
				
				if (operacao == 'VA' && (flgContinuar == true || flgcadas == 'M') ) {
					proximaRotina();
				}
				
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
			}
		}				
	});
}

function controlaLayout(operacao) {
	
	var rotulos = $('label[for="vlcxbcaf"],label[for="vlrestoq"],label[for="vlrimobi"],label[for="vlfornec"],label[for="vldivbco"]','#frmAtivoPassivo');	
	var campos  = $('#vlctarcb,#vlcxbcaf,#vlrestoq,#vloutatv,#vlrimobi,#vlfornec,#vloutpas,#vldivbco,#mesdbase,#anodbase','#frmAtivoPassivo');	
	var cVldivbco = $("#vldivbco","#frmAtivoPassivo");
	
	altura  = '290px';
	largura = '560px';
	divRotina.css('width',largura);	
	$('#divConteudoOpcao').css('height',altura);
				
	// Sempre inicia com tudo bloqueado
	campos.removeClass('campo').addClass('campoTelaSemBorda').prop('disabled',true);
	
	$('fieldset:eq(0)','#frmAtivoPassivo').css('padding','5px 0px');
	
	// Formatação dos rotulos
	rotulos.addClass('rotulo rotulo-140');
	$('label[for="dtaltjfn"]','#frmAtivoPassivo').addClass('rotulo').css({'width':'200px'});
	$('label[for="mesdbase"]','#frmAtivoPassivo').css({'width':'439px','text-align':'right'});
	$('label[for="anodbase"]','#frmAtivoPassivo').css({'padding-left':'3px'});
	$('label[for="vlctarcb"],label[for="vloutatv"],label[for="vloutpas"]','#frmAtivoPassivo').addClass('rotulo-110').css({'text-align':'right'});
	$('label[for="cdopejfn"]','#frmAtivoPassivo').addClass('rotulo-70');
			
	//formatação dos campos
	$('#vlcxbcaf,#vlrestoq,#vlrimobi,#vlfornec,#vldivbco','#frmAtivoPassivo').attr('maxlength','17').css({'width':'131px'});
	$('#mesdbase','#frmAtivoPassivo').css({'width':'25px'}).attr('maxlength','2');
	$('#anodbase','#frmAtivoPassivo').css({'width':'40px'}).attr('maxlength','4');
	$('#vlctarcb,#vloutatv,#vloutpas','#frmAtivoPassivo').css({'width':'126px'}).attr('maxlength','17');
	
	$('#dtaltjfn','#frmAtivoPassivo').css({'width':'74px'});
	$('#cdopejfn','#frmAtivoPassivo').css({'width':'58px'});
	$('#nmoperad','#frmAtivoPassivo').css({'width':'115px'});
	$('#dtaltjfn,#cdopejfn,#nmoperad','#frmAtivoPassivo').removeClass('campo').addClass('campoTelaSemBorda').prop('disabled',true);
	
	switch(operacao) {	
		// Consulta Alteração
		case 'CA': 
			campos.habilitaCampo();
			break;			
		default: 
			break;
	}
	
	cVldivbco.unbind("keydown").bind("keydown",function(e) {
		if (e.keyCode == 13) {
			$("#btSalvar","#divBotoes").trigger("click");
			return false;
		}	
	});	
 		
	layoutPadrao();
	hideMsgAguardo();
	bloqueiaFundo(divRotina);
	removeOpacidade('divConteudoOpcao');
	divRotina.centralizaRotinaH();
	highlightObjFocus($('#frmAtivoPassivo'));
	controlaFocoEnter("frmAtivoPassivo");
	controlaFoco(operacao);
	return false;	
}	

function controlaFoco(operacao) {	
	if (in_array(operacao,['AC',''])) {
		$('#btAlterar','#divBotoes').focus();
	} else {
		$('.campo:first','#frmAtivoPassivo').focus();
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
	acessaRotina('CLIENTE FINANCEIRO','Cliente Financeiro','cliente_financeiro');	
}

function proximaRotina () {
	hideMsgAguardo();
	encerraRotina(false);
	acessaRotina('FINANCEIRO-BANCO','Banco','banco');				
}
/*!
 * FONTE        : filiacao.js
 * CRIAÇÃO      : Alexandre Scola (DB1)
 * DATA CRIAÇÃO : Janeiro/2010 
 * OBJETIVO     : Biblioteca de funções da rotina Filiação da tela de CONTAS
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 001: [01/04/2010] Rodolpho Telmo (DB1): Adequação ao novo padrão
 * 002: [26/04/2010] Rodolpho Telmo (DB1): Retirada função "revisaoCadastral", agora se encontra no arquivo funcoes.js
 * 003: [02/09/2015] Gabriel (RKAM)      : Reformulacao Cadastral.
 */

function controlaOperacaoFiliacao(operacao, msgRetorno) {
	
	// Verifica permissões de acesso
	if ( (operacao == 'CA') && (flgAlterarFiliacao != '1') ) { 
		showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de altera&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina);');
		return false;
	} 
		
	// Mostra mensagem de aguardo
	var msgOperacao = '';
	switch (operacao) {			
		// Consulta para Alteração
		case 'CA': 
			msgOperacao = 'abrindo altera&ccedil;&atilde;o';
			cddopcao    = 'A';
			break;
		// Alteração para Consulta
		case 'AC': 
			showConfirmacao('Deseja cancelar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','controlaOperacaoFiliacao(\'\')','bloqueiaFundo(divRotina)','sim.gif','nao.gif');
			return false;
			break;	
		// Alteração para Validação - Validando Alteração
		case 'AV': 
			manterRotinaFiliacao(operacao);
			return false;
			break;	
		// Validação para Alteração - Salvando Alteração
		case 'VA': 
			manterRotinaFiliacao(operacao);
			return false;
			break;				
		// Finalizou Alteração
		case 'FA':
			acessaOpcaoAbaDados(6,2,'@');			
			return false;		
		// Qualquer outro valor: Cancelando Operação
		default: 
			msgOperacao = 'abrindo consulta';
			cddopcao    = 'C';
			break;			
	}
	
	showMsgAguardo('Aguarde, ' + msgOperacao + '...');
	
	// Executa script de através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/contas/filiacao/principal.php', 
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			operacao: operacao,
			redirect: "html_ajax"
		},  
		error: function(objAjax,responseError,objExcept) {	
			hideMsgAguardo();
			showError('error','N&atilde;o foi possivel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function(response) {			
			if ( response.indexOf('showError("error"') == -1 ) {
				$('#divConteudoOpcao').html(response);
			} else {
				eval( response );				
			}
			return false;
		}				
	});			
}

function manterRotinaFiliacao(operacao) {

	hideMsgAguardo();		
	var msgOperacao = '';
	switch (operacao) {	
		case 'VA': msgOperacao = 'salvando altera&ccedil;&atilde;o'; break;
		case 'AV': msgOperacao = 'validando altera&ccedil;&atilde;o'; break;										
		default: return false; break;
	}
	showMsgAguardo('Aguarde, ' + msgOperacao + ' ...');
	
	var nmmaettl = trim($("#nmmaettl","#frmDadosFiliacao").val());
	var nmpaittl = trim($("#nmpaittl","#frmDadosFiliacao").val());
	
	$.ajax({		
		type: 'POST',
		url: UrlSite + 'telas/contas/filiacao/manter_rotina.php', 		
		data: {
			nrdconta: nrdconta, idseqttl: idseqttl, 
			nmmaettl: nmmaettl, nmpaittl: nmpaittl,	
			operacao: operacao,
			redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
			}
		}				
	});
}

function controlaLayoutFiliacao(operacao) {	
	
	var rotulos = $('label[for="nmmaettl"],label[for="nmpaittl"]','#frmDadosFiliacao');	
	var campos  = $('#nmmaettl,#nmpaittl','#frmDadosFiliacao');	
	
	$('#divConteudoOpcao').hide(0, function() {
		
		$('#frmDadosFiliacao').css({'padding-top':'5px','padding-bottom':'0px'});
		
		// Sempre inicia com tudo bloqueado
		campos.removeClass('campo').addClass('campoTelaSemBorda').prop('disabled',true).attr('maxlength','40');
		
		// Formatação dos rotulos
		rotulos.addClass('rotulo rotulo-100');
		
		// Formatação dos campos
		campos.css({'width':'370px'}).addClass('alpha');
		
		switch(operacao) {
		
			// Consulta Alteração
			case 'CA': 
				$('#divConteudoOpcao').css('height','120px');
				campos.removeClass('campoTelaSemBorda').addClass('campo').removeProp('disabled');
				break;
				
			default: 
				break;
		}
		
		$("#nmpaittl","#frmDadosFiliacao").unbind("keydown").bind("keydown",function(e) {
			if (e.keyCode == 13) {
				$("#btSalvar","#divBotoes").trigger("click");
				return false;
			}	
		});	
		
		layoutPadrao();
		hideMsgAguardo();
		bloqueiaFundo(divRotina);	
		$(this).fadeIn(1000);
		divRotina.centralizaRotinaH(); 
		highlightObjFocus($('#frmDadosFiliacao'));
		controlaFocoEnter("frmDadosFiliacao");	
		controlaFocoFiliacao(operacao);
	});	
	
	return false;	
}	

function controlaFocoFiliacao(operacao) {
		
	if (in_array(operacao,['AC','FA',''])) {
		$('#btAlterar','#divBotoes').focus();
	} else {		
		$('#nmmaettl','#frmDadosFiliacao').focus();
	}
	return false;
}
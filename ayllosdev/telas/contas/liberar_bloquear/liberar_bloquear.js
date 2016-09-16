/*!
 * FONTE        : liberar_bloquear.js
 * CRIAÇÃO      : James Prust Junior
 * DATA CRIAÇÃO : Janeiro/2015
 * OBJETIVO     : Biblioteca de funções da rotina Liberar/Bloquear  da tela de CONTAS
 * --------------
 * ALTERAÇÕES   : 06/01/2016 - Adicionar campo de libera credito pre-aprovado (Anderson).
 * --------------
 */
// Função para acessar opções da rotina
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
		url: UrlSite + "telas/contas/liberar_bloquear/principal.php",
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,			
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',bloqueiaFundo(divRotina));
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

function controlaOperacao(operacao, msgRetorno) {

	// Verifica permissões de acesso
	if ( (operacao == 'CA') && (flgAlterar != '1') ) { 
		showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de altera&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina);');
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
			showConfirmacao('Deseja cancelar altera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','controlaOperacao(\'\')','bloqueiaFundo(divRotina)','sim.gif','nao.gif');
			return false;
			break;	
		// Finalizar Alteracao	
		case 'ALTERAR':
			manterRotina(operacao);
			operacao = '';
			break;
		default: 
			msgOperacao = 'abrindo consulta';
			cddopcao    = '@';
			break;			
	}
	
	showMsgAguardo('Aguarde, ' + msgOperacao + '...');
	
	// Executa script de através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/contas/liberar_bloquear/principal.php', 
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			operacao: operacao,
			redirect: "html_ajax"
		},  
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
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

function manterRotina(operacao) {

	hideMsgAguardo();
	showMsgAguardo('Aguarde, salvando altera&ccedil;&atilde;o ...');
	
	var flgrenli = $('#flgrenli', '#frmLiberarBloquear').val();
	var flgcrdpa = $('#flgcrdpa', '#frmLiberarBloquear').val();

	$.ajax({		
		type: 'POST',
		url: UrlSite + 'telas/contas/liberar_bloquear/manter_rotina.php', 		
		data: {
			nrdconta: nrdconta, 
			idseqttl: idseqttl, 
			flgrenli: flgrenli,
            flgcrdpa: flgcrdpa,
			operacao: operacao, 
			redirect: 'script_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function (response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
				return;
			}
			hideMsgAguardo();
			bloqueiaFundo(divRotina);
		}				
	});
}

function controlaLayout(operacao, libera_crd_pa) {	
	
	var rFlgrenli = $('label[for="flgrenli"]','#frmLiberarBloquear');
	var cFlgrenli = $('#flgrenli','#frmLiberarBloquear');	
	var rFlgcrdpa = $('label[for="flgcrdpa"]', '#frmLiberarBloquear');
	var cFlgcrdpa = $('#flgcrdpa', '#frmLiberarBloquear');

	$('#divConteudoOpcao').hide(0, function() {
		$('#frmLiberarBloquear').css({'padding-top':'5px','padding-bottom':'15px'});		
		cFlgrenli.css('width','50px');
		cFlgrenli.desabilitaCampo();
		cFlgcrdpa.css('width', '50px');
		cFlgcrdpa.desabilitaCampo();
		
		// Formatação dos rotulos
		rFlgrenli.css('width', '200px');
		rFlgcrdpa.css('width', '200px');
				
		switch(operacao) {
			// Consulta Alteração
			case 'CA': 
			    cFlgrenli.habilitaCampo();
			    if (libera_crd_pa) {
			        cFlgcrdpa.habilitaCampo();
			    }
			break;
		}
		
		layoutPadrao();
		hideMsgAguardo();
		bloqueiaFundo(divRotina);	
		$(this).fadeIn(1000);
		controlaFoco(operacao);
		divRotina.centralizaRotinaH(); 
	});	
	
	return false;	
}	

function controlaFoco(operacao) {
	if (in_array(operacao,['AC',''])) {
		$('#btAlterar','#divBotoes').focus();
	} else {		
		$('#flgrenli','#frmLiberarBloquear').focus();
	}
	return false;
}
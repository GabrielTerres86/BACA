/*!
 * FONTE        : liberar_bloquear.js
 * CRIAÇÃO      : James Prust Junior
 * DATA CRIAÇÃO : Janeiro/2015
 * OBJETIVO     : Biblioteca de funções da rotina Liberar/Bloquear  da tela ATENDA
 * --------------
 * ALTERAÇÕES   : 06/01/2016 - Adicionar campo de libera credito pre-aprovado (Anderson).
 *                27/07/2016 - Adicionados novos campos para a fase 3 do projeto pre aprovado (Lombardi)
 *                03/05/2017 - Ajuste na label do campo flgrenli para o projeto 300. (Lombardi)
 *                08/08/2017 - Implementacao da melhoria 438. Heitor (Mouts).
 *								15/03/2018 - Campo de selecao de cancelamento automatico de credito (Marcel Kohls / AMCom)
 * --------------
 */
// Função para acessar opções da rotina
function acessaOpcaoAba(nrOpcoes,id,opcao) {
	if (opcao == "0") {	// Opção Principal
		var msg = "aba conta corrente";
	} else if (opcao == "1") {	// Opção Extrato
		var msg = "aba pre-aprovado";
	}

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando " + msg + " ...");
	
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
	if (opcao == "0") {	// Opção extrato
		$.ajax({
			type: "POST", 
			dataType: "html",
			url: UrlSite + "telas/atenda/liberar_bloquear/conta_corrente.php",
			data: {
				nrdconta: nrdconta,
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
				}
				return false;
			}				
		});
	}else if (opcao == "1") {	// Opção saldos anteriores		
	    $.ajax({
			type: "POST", 
			dataType: "html",
			url: UrlSite + "telas/atenda/liberar_bloquear/principal.php",
			data: {
				nrdconta: nrdconta,
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
				}
				return false;
			}				
		});
	}
}

function controlaOperacao(operacao, msgRetorno) {

	// Verifica permissões de acesso
	if ( ((operacao == 'CA') && (flgAlterar != '1') ) || ((operacao == 'MA') && (flgAlterar != '1')) ) { 
		showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de altera&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina);');
		return false;
	}

	// Mostra mensagem de aguardo
	var msgOperacao = '';
	var operacaoOrg = operacao;

	switch (operacao) {			
		// Consulta para Alteração
		case 'CA': 
			msgOperacao = 'abrindo altera&ccedil;&atilde;o';
			cddopcao    = 'A';
			break;
		// Alteração para Consulta
		case 'AC': 
			showConfirmacao('Deseja cancelar altera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','controlaOperacao(\'\')','bloqueiaFundo(divRotina)','sim.gif','nao.gif');
			return false;
			break;	
		// Consulta para Alteração
		case 'MA': 
			msgOperacao = 'abrindo altera&ccedil;&atilde;o';
			cddopcao    = 'A';
			break;
		// Alteração para Consulta
		case 'AM': 
			showConfirmacao('Deseja cancelar altera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','controlaOperacao(\'\')','bloqueiaFundo(divRotina)','sim.gif','nao.gif');
			return false;
			break;
		// Finalizar Alteracao
		case 'ALTERAR':
			manterRotina(operacao);
			operacao = '';
			break;
		case 'ALTERARM':
		    showConfirmacao('Deseja confirmar a altera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','controlaOperacao("ALTERARC")','bloqueiaFundo(divRotina)','sim.gif','nao.gif');
			return false;
			break;
	    case 'ALTERARC':
			manterRotina(operacao);
			operacao = 'AM';
			break;
		default: 
			msgOperacao = 'abrindo consulta';
			cddopcao    = '@';
			break;
	}
	
	showMsgAguardo('Aguarde, ' + msgOperacao + '...');
	if (operacaoOrg != 'ALTERARC') {
		if (operacao == '') {
			acessaOpcaoAba(2,0,0);
		} else if (operacao == 'MA' || operacao == 'AM') { // Executa script de através de ajax
		
			$.ajax({
				type: 'POST',
				dataType: 'html',
				url: UrlSite + 'telas/atenda/liberar_bloquear/conta_corrente.php', 
				data: {
					nrdconta: nrdconta,
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
					}
					return false;
				}				
			});
		} else {
			$.ajax({
				type: 'POST',
				dataType: 'html',
				url: UrlSite + 'telas/atenda/liberar_bloquear/principal.php', 
				data: {
					nrdconta: nrdconta,
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
					}
					return false;
				}				
			});
		}
	}
}

function manterRotina(operacao) {
	hideMsgAguardo();
	showMsgAguardo('Aguarde, salvando altera&ccedil;&atilde;o ...');

	if (operacao == 'ALTERARC') {
		var flgrenli = $('#flgrenli', '#frmContaCorrente').val();
		var flmajora = $('#flmajora', '#frmContaCorrente').val();
		var flcnaulc = $('#flcnaulc', '#frmContaCorrente').val();
		var dsmotmaj = $('#motivo_bloqueio_maj', '#frmContaCorrente').val();
	} else {
		var flgcrdpa = $('#flgcrdpa', '#frmLiberarBloquear').val();
	}

	$.ajax({		
		type: 'POST',
		url: UrlSite + 'telas/atenda/liberar_bloquear/manter_rotina.php', 		
		data: {
			nrdconta: nrdconta, 
			flgrenli: flgrenli,
            flgcrdpa: flgcrdpa,
			flmajora: flmajora,
			flcnaulc: flcnaulc,
			dsmotmaj: dsmotmaj,
			operacao: operacao, 
			redirect: 'script_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function (response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
				return;
			}
			hideMsgAguardo();
			bloqueiaFundo(divRotina);
		}				
	});
}

function controlaLayout(operacao) {	
	
	var rFlgrenli = $('label[for="flgrenli"]', '#frmContaCorrente');
	var rFlmajora = $('label[for="flmajora"]', '#frmContaCorrente');
	var rFlcnaulc = $('label[for="flcnaulc"]', '#frmContaCorrente');
	var rMotivo_bloqueio_maj = $('label[for="motivo_bloqueio_maj"]', '#frmContaCorrente');
	var rCdopemaj = $('label[for="cdopemaj"]', '#frmContaCorrente');
	//
	var rFlgcrdpa = $('label[for="flgcrdpa"]', '#frmLiberarBloquear');
	var rDtultatt = $('label[for="dtultatt"]', '#frmLiberarBloquear');
	var rMotivo_bloqueio = $('label[for="motivo_bloqueio"]', '#frmLiberarBloquear');
	var rLiberado_sem = $('label[for="liberado_sem"]', '#frmLiberarBloquear');
	var rLiberado_man = $('label[for="liberado_man"]', '#frmLiberarBloquear');
	var rDscarga = $('label[for="dscarga"]', '#frmLiberarBloquear');
	var rDtinicial = $('label[for="dtinicial"]', '#frmLiberarBloquear');
	//
	var cFlgrenli = $('#flgrenli', '#frmContaCorrente');
	var cFlmajora = $('#flmajora', '#frmContaCorrente');
	var cFlcnaulc = $('#flcnaulc', '#frmContaCorrente');
	var cMotivo_bloqueio_maj = $('#motivo_bloqueio_maj', '#frmContaCorrente');
	var cCdopemaj = $('#cdopemaj', '#frmContaCorrente');
	var cNmopemaj = $('#nmopemaj', '#frmContaCorrente');
	//
	var cFlgcrdpa = $('#flgcrdpa', '#frmLiberarBloquear');
	var cDtultatt = $('#dtultatt', '#frmLiberarBloquear');
	var cMotivo_bloqueio = $('#motivo_bloqueio', '#frmLiberarBloquear');
	var cLiberado_sem = $('#liberado_sem', '#frmLiberarBloquear');
	var cLiberado_man = $('#liberado_man', '#frmLiberarBloquear');
	var cDscarga = $('#dscarga', '#frmLiberarBloquear');
	var cDtinicial = $('#dtinicial', '#frmLiberarBloquear');
	var cDtfinal = $('#dtfinal', '#frmLiberarBloquear');
	//
	$('#divConteudoOpcao').hide(0, function() {
		$('#frmLiberarBloquear').css({'padding-top':'5px','padding-bottom':'15px'});		
		cFlgrenli.css('width','50px').desabilitaCampo();
		cFlmajora.css('width','50px').desabilitaCampo();
		cFlcnaulc.css('width','50px').desabilitaCampo();
		cMotivo_bloqueio_maj.css('width', '350px').desabilitaCampo();
		cCdopemaj.css('width','67px').desabilitaCampo();
		cNmopemaj.css('width','280px').desabilitaCampo();
		//
		cFlgcrdpa.css('width', '50px').desabilitaCampo();
		cDtultatt.css('width', '80px').desabilitaCampo();
		cMotivo_bloqueio.css('width', '100px').desabilitaCampo();
		cLiberado_sem.css('width', '50px').desabilitaCampo();
		cLiberado_man.css('width', '50px').desabilitaCampo();
		cDscarga.css('width', '285px').desabilitaCampo();
		cDtinicial.css('width', '80px').desabilitaCampo();
		cDtfinal.css('width', '80px').desabilitaCampo();
		
		// Formatação dos rotulos
		rFlgrenli.css('width', '381px');
		rFlmajora.css('width', '381px');
		rFlcnaulc.css('width', '381px');
		rMotivo_bloqueio_maj.css('width', '180px');
		rCdopemaj.css('width', '180');
		//
		rFlgcrdpa.css('width', '250px');
		rDtultatt.css('width', '150px');
		rMotivo_bloqueio.css('width', '200px');
		rLiberado_sem.css('width', '245px');
		rLiberado_man.css('width', '245px');
		rDscarga.css('width', '245px').addClass('rotulo');
		rDtinicial.css('width', '245px').addClass('rotulo');
		
		switch(operacao) {
			// Consulta Alteração
			case 'CA': 
			    cFlgcrdpa.habilitaCampo();
				break;
			case 'MA':
				cFlgrenli.habilitaCampo();
				cFlmajora.habilitaCampo();
				cFlcnaulc.habilitaCampo();
				cMotivo_bloqueio_maj.habilitaCampo();
				break;
		}
		
		divRotina.css('width','600px');
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

/*!
 * FONTE        : emails.js
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 17/05/2010 
 * OBJETIVO     : Biblioteca de funções na rotina E-MAILS da tela de CONTAS
 *
 * ALTERACOES   : 05/05/2014 - Alterado o tamanho do e-mail para 60 caracteres. (Douglas Quisinski).
 *
 * 	              04/08/2015 - Reformulacao cadastral (Gabriel-Rkam).
 *
 *                21/07/2016 - Remover caracteres especiais e acentos do endereco de email
 *                             Chamado 490892 - Heitor (RKAM)
 *
 *				  19/03/2019 - Inserção dos campos de Status, Canal e Data de revisão - Vitor S. Assanuma (GFT)
 */

var nrdrowid  = ''; 
var operacao  = '';
var cddopcao  = '';
var nomeForm  = 'frmEmails';
 
function acessaOpcaoAba(nrOpcoes,id,opcao) {

	// Mostra mensagem de aguardo
	showMsgAguardo('Aguarde, carregando...');
	
	// Atribui cor de destaque para aba da opção
	for (var i = 0; i < nrOpcoes; i++) {
		if (!$('#linkAba' + id)) {
			continue;
		}
		
		if (id == i) { // Atribui estilos para foco da opção
			$('#linkAba'   + id).attr('class','txtBrancoBold');
			$('#imgAbaEsq' + id).attr('src',UrlImagens + 'background/mnu_sle.gif');				
			$('#imgAbaDir' + id).attr('src',UrlImagens + 'background/mnu_sld.gif');
			$('#imgAbaCen' + id).css('background-color','#969FA9');
			continue;			
		}
		
		$('#linkAba'   + i).attr('class','txtNormalBold');
		$('#imgAbaEsq' + i).attr('src',UrlImagens + 'background/mnu_nle.gif');			
		$('#imgAbaDir' + i).attr('src',UrlImagens + 'background/mnu_nld.gif');
		$('#imgAbaCen' + i).css('background-color','#C6C8CA');
	}

	// Carrega conteúdo da opção através do Ajax
	$.ajax({		
		type: 'POST', 
		dataType: 'html',
		url: UrlSite + 'telas/contas/emails/principal.php',
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			inpessoa: inpessoa,
			flgcadas: flgcadas,
			operacao: operacao,
			redirect: 'html_ajax'
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

function controlaOperacao(operacao) {

	if ( (operacao == 'TA') && (flgAlterar != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de altera&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)'); return false; }
	if ( (operacao == 'TE') && (flgExcluir != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de exclus&atilde;o.'        ,'Alerta - Aimaro','bloqueiaFundo(divRotina)'); return false; }
	if ( (operacao == 'TI') && (flgIncluir != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de incluis&atilde;o.'       ,'Alerta - Aimaro','bloqueiaFundo(divRotina)'); return false; }
	
	// Se a operação necessita filtrar somente um registro, então filtro abaixo
	// Para isso verifico a linha que está selecionado e pego o valor do INPUT HIDDEN desta linha	
	if ( in_array(operacao,['TA','TE','CF']) ) {
		nrdrowid = '';
		$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				nrdrowid = $('input', $(this) ).val();
			}
		});	
		if ( nrdrowid == '' ) { return false; }		
	}
		
	var mensagem = '';	
	switch (operacao) {			
		case 'CF' : 
			mensagem = 'abrindo consultar ...';
			cddopcao = 'C';
			break;
		case 'TA' : 
			mensagem = 'abrindo altera&ccedil;&atilde;o ...';
			cddopcao = 'A';
			break;
		case 'TI' : 
			mensagem = 'abrindo inclus&atilde;o...';
			nrdrowid = '';
			cddopcao = 'I';
			break;			
		case 'TE' : 
			mensagem = 'processando exclus&atilde;o...';
			cddopcao = 'E';
			break;					
		case 'AT' : 
			showConfirmacao('Deseja cancelar altera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','controlaOperacao()','bloqueiaFundo(divRotina)','sim.gif','nao.gif');
			return false;
			break;
		case 'IT' : 
			showConfirmacao('Deseja cancelar inclus&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','controlaOperacao()','bloqueiaFundo(divRotina)','sim.gif','nao.gif');
			return false;
			break;			
		case 'AV' : manterRotina(operacao);return false;break;	
		case 'VA' : manterRotina(operacao);return false;break;
		case 'IV' : manterRotina(operacao);return false;break;
		case 'VI' : manterRotina(operacao);return false;break;
		case 'EV' : manterRotina(operacao);return false;break;
		case 'VE' : manterRotina(operacao);return false;break;
		default   : 
			operacao = '';
			nrdrowid = '';
			cddopcao = 'C';
			mensagem = 'carregado...';
			break;
	}
	showMsgAguardo('Aguarde, ' + mensagem);	
	
	// Executa script de através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/contas/emails/principal.php', 
		data: {
			nrdconta: nrdconta,	
			idseqttl: idseqttl,
			inpessoa: inpessoa,
			operacao: operacao,	
			nrdrowid: nrdrowid,
			cddopcao: cddopcao,	
			flgcadas: flgcadas,
			redirect: 'script_ajax'
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

function manterRotina( operacao ) {
	hideMsgAguardo();	
	var mensagem = '';
	switch (operacao) {	
		case 'AV': mensagem = 'validando altera&ccedil;&atilde;o'; break;
		case 'IV': mensagem = 'validando inclus&atilde;o'; break;				
		case 'EV': mensagem = 'validando exclus&atilde;o'; break;								
		case 'VA': mensagem = 'alterando'; break;
		case 'VI': mensagem = 'incluindo'; break;
		case 'VE': mensagem = 'excluindo'; break;
		default: controlaOperacao(); return false; break;
	}
	showMsgAguardo('Aguarde, ' + mensagem + '...');
	
	dsdemail = $('#dsdemail','#'+nomeForm).val();
	secpscto = $('#secpscto','#'+nomeForm).val();
	nmpescto = $('#nmpescto','#'+nomeForm).val();
	nrdrowid = $('#nrdrowid','#'+nomeForm).val();
	
	if (dsdemail != '') {
		dsdemail = removeAcentos(removeCaracteresInvalidos(dsdemail));
	}
	
	if (nmpescto != '') {
		nmpescto = removeAcentos(removeCaracteresInvalidos(nmpescto));
	}
	
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		url: UrlSite + 'telas/contas/emails/manter_rotina.php', 		
		data: {
			nrdconta: nrdconta, idseqttl: idseqttl, 
			dsdemail: dsdemail, secpscto: secpscto,
			nmpescto: nmpescto, operacao: operacao, 
			nrdrowid: nrdrowid,	flgcadas: flgcadas,
			redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			try {
				eval(response);
				return false;
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
			}
		}				
	});
}

function controlaLayout(operacao) {		
	var alt = inpessoa == 1 ? '145px' : '115px';
	altura  = ( in_array(operacao,['AT','IT','FI','FA','FE','SC','']) ) ? '205px' : alt;
	largura = ( in_array(operacao,['AT','IT','FI','FA','FE','SC','']) ) ? '730px' : '500px';
	divRotina.css('width',largura);	
	$('#divConteudoOpcao').css('height',altura);
	
	// Visualização em tabela
	if ( in_array(operacao,['AT','IT','FI','FA','FE','SC','']) ) {	

		var divRegistro = $('div.divRegistros');		
		var tabela      = $('table', divRegistro );
		var linha       = $('table > tbody > tr', divRegistro );
		
		divRegistro.css('height','150px');
		
		var ordemInicial = new Array();
		ordemInicial = [[1,0]];
		
		var arrayLargura = new Array();
		arrayLargura[0] = '490px';
		arrayLargura[1] = '70px';
		arrayLargura[2] = '90px';
		
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'left';
		arrayAlinha[1] = 'center';
		arrayAlinha[2] = 'center';
		
		var metodoTabela = ( operacao != 'SC' ) ? 'controlaOperacao(\'TA\')' : 'controlaOperacao(\'CF\')';
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );
	
	// Operação Alterando/Incluindo
	} else {	
		
		var rRotulos  = $('label'    ,'#'+nomeForm);
		var cTodos    = $('input'    ,'#'+nomeForm);
		var cEmail	  = $('#dsdemail','#'+nomeForm);
		var cSetor	  = $('#secpscto','#'+nomeForm);
		var cContato  = $('#nmpescto','#'+nomeForm);		
		var cSituacao = $('#dssituac','#'+nomeForm);		
		var cDsdcanal = $('#dsdcanal','#'+nomeForm);		
		var cDtRevisa = $('#dtrevisa','#'+nomeForm);

		var rEmail    = $('label[for="dsdemail"]','#'+nomeForm);
		var rSetor    = $('label[for="secpscto"]','#'+nomeForm);
		var rContato  = $('label[for="nmpescto"]','#'+nomeForm);
		var rSituacao = $('label[for="dssituac"]','#'+nomeForm);
		var rDsdcanal = $('label[for="dsdcanal"]','#'+nomeForm);
		var rDtRevisa = $('label[for="dtrevisa"]','#'+nomeForm);	

		rEmail.addClass('rotulo').css('width','90px');
		rSetor.addClass('rotulo').css('width','90px');
		rContato.addClass('rotulo').css('width','90px');
		rSituacao.addClass('rotulo').css('width','90px');
		rDsdcanal.addClass('rotulo-linha').css('width','60px');
		rDtRevisa.addClass('rotulo-linha').css('width','90px');
		
		cTodos.addClass('campo');
		cEmail.addClass('email').css('width','377px').attr('maxlength','60');
		cSetor.addClass('alphanum').css('width','70px').attr('maxlength','8');
		cContato.addClass('alphanum').css('width','277px').attr('maxlength','25');
		cSituacao.css('width','60px');
		cDsdcanal.css('width','70px');
		cDtRevisa.css('width','85px');
		cSituacao.desabilitaCampo();
		cDsdcanal.desabilitaCampo();
		cDtRevisa.desabilitaCampo();
		
		// Se for pessoa Física, bloquear os campos Setor e Nome Contato
		if( inpessoa == 1 ) {
			cSetor.removeClass('campo').addClass('campoTelaSemBorda').prop('disabled',true);
			cContato.removeClass('campo').addClass('campoTelaSemBorda').prop('disabled',true);
		}		
		
		if (operacao == 'TI') {
			$('#'+nomeForm).limpaFormulario();
		}else if (operacao == 'CF' ) {
			cTodos.desabilitaCampo();
		}	
		
		cEmail.unbind("keydown").bind("keydown",function(e) {
			if (e.keyCode == 13 && inpessoa == 1) {
				$("#btSalvar","#divBotoes").trigger("click");
				return false;
			}	
		});	
		
		cContato.unbind("keydown").bind("keydown",function(e) {
			if (e.keyCode == 13 && inpessoa == 2) {
				$("#btSalvar","#divBotoes").trigger("click");
				return false;
			}	
		});	
		
	}
	
	layoutPadrao();
	hideMsgAguardo();
	bloqueiaFundo(divRotina);
	removeOpacidade('divConteudoOpcao');
	highlightObjFocus($('#divConteudoOpcao'));
	controlaFocoEnter("divConteudoOpcao");
	controlaFoco(operacao);
	divRotina.centralizaRotinaH();
	return false;	
}

function controlaFoco(operacao) {
	if (in_array(operacao,['AT','IT','FA','FI','FE',''])) {
		$('#btIncluir','#divBotoes').focus();
	} else {
		$('#dsdemail','#'+nomeForm).focus();
	}
	return false;
}

function voltarRotina() {
	if (inpessoa == 1) {
		acessaOpcaoAbaDados(3,1,'@');
	} else {
		fechaRotina(divRotina);
		acessaRotina('TELEFONES','Telefones','telefones');
	}
}

function proximaRotina () {
	encerraRotina(false);
	
	if (inpessoa == 1) {
		acessaRotina('COMERCIAL','Comercial','comercial_pf');
	} else {
		acessaRotina('REFERENCIAS','Referências','referencias');
	}	
}
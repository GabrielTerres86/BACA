/*!
 * FONTE        : contatos.js
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 11/05/2010 
 * OBJETIVO     : Biblioteca de funções na rotina CONTATOS da tela de CONTAS
 * ALTERAÇÃO    : Adicionado pesquisa CEP. ( Rodolpho/Rogérius. (DB1) ).
 *
 *                31/08/2015 - Refomulacao cadastral (Gabriel-RKAM).
 */

var nrdrowid  = ''; 
var nrdctato  = '';
var operacao  = '';
var cddopcao  = '';
var nomeFormContatos  = 'frmContatos';
 

function controlaOperacaoContatos(operacao) {

	if ( (operacao == 'TA') && (flgAlterar   != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de altera&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)'); return false; }
	if ( (operacao == 'TC') && (flgConsultar != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de consulta.'               ,'Alerta - Aimaro','bloqueiaFundo(divRotina)'); return false; }
	if ( (operacao == 'TX') && (flgExcluir   != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de exclus&atilde;o.'        ,'Alerta - Aimaro','bloqueiaFundo(divRotina)'); return false; }
	if ( (operacao == 'TI') && (flgIncluir   != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de incluis&atilde;o.'       ,'Alerta - Aimaro','bloqueiaFundo(divRotina)'); return false; }
	
	// Se a operação necessita filtrar somente um registro, então filtro abaixo
	// Para isso verifico a linha que está selecionado e pego o valor do INPUT HIDDEN desta linha	
	if ( in_array(operacao,['TA','TC','TX']) ) {
		nrdrowid = '';
		$('table > tbody > tr', 'div.divRegistrosContatos').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				nrdrowid = $('input', $(this) ).val();
			}
		});
		if ( nrdrowid == '' ) { return false; }	
	}
			
	var msgOperacao = '';
	
	switch (operacao) {			
		case 'TA' : 
			msgOperacao = 'abrindo altera&ccedil;&atilde;o...';
			cddopcao = 'A';
			break;
		case 'AT' : 
			showConfirmacao('Deseja cancelar altera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','controlaOperacaoContatos(\'\')','bloqueiaFundo(divRotina)','sim.gif','nao.gif');
			return false;
			break;
		case 'TC' : 
			msgOperacao = 'abrindo consulta...';
			cddopcao = 'C';
			break;
		case 'TI' : 
			msgOperacao = 'abrindo inclus&atilde;o...';
			nrdrowid = '';
			nrdctato = '';
			cddopcao = 'I';
			break;		
		case 'TB' : 
			msgOperacao = 'buscando dados da Conta informada ...';
			cddopcao = 'I';
			break;
		case 'TX' : 
			msgOperacao = 'processando exclus&atilde;o ...';
			cddopcao = 'E';
			break;
		case 'TE' : 
			showConfirmacao('Deseja confirmar exclus&atilde;o?'        ,'Confirma&ccedil;&atilde;o - Aimaro','manterRotinaContatos(\'E\')','controlaOperacaoContatos(\'\')','sim.gif','nao.gif');
			return false;
			break;					
		case 'AT' : 
			showConfirmacao('Deseja cancelar altera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','controlaOperacaoContatos(\'\')','bloqueiaFundo(divRotina)','sim.gif','nao.gif');
			return false;
			break;
		case 'IT' : 
			showConfirmacao('Deseja cancelar inclus&atilde;o?'        ,'Confirma&ccedil;&atilde;o - Aimaro','controlaOperacaoContatos(\'\')','bloqueiaFundo(divRotina)','sim.gif','nao.gif');
			return false;
			break;
		case 'AV' : manterRotinaContatos(operacao);return false;break;	
		case 'VA' : manterRotinaContatos(operacao);return false;break;
		case 'IV' : manterRotinaContatos(operacao);return false;break;
		case 'VI' : manterRotinaContatos(operacao);return false;break;	
		default   : 
			acessaOpcaoAbaDados(6,2,'@');
			return false;
	}
	showMsgAguardo('Aguarde, ' + msgOperacao);		
		
	// Executa script de através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/contas/contatos/principal.php', 
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			operacao: operacao,
			nrdrowid: nrdrowid,
			nrdctato: nrdctato,
			cddopcao: cddopcao,
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
				controlaFocoContatos( operacao );
			}
			return false;
		}				
	});			
}

function manterRotinaContatos( operacao ) {
	hideMsgAguardo();	
	var msgOperacao = '';
	switch (operacao) {	
		case 'VA': msgOperacao = 'salvando altera&ccedil;&atilde;o';break;
		case 'AV': msgOperacao = 'validando altera&ccedil;&atilde;o';break;						
		case 'VI': msgOperacao = 'salvando inclus&atilde;o';break;
		case 'IV': msgOperacao = 'validando inclus&atilde;o';break;						
		case 'E' : msgOperacao = 'excluindo';break;
		default: controlaOperacaoContatos(''); return false; break;
	}
	showMsgAguardo('Aguarde, ' + msgOperacao + ' ...');
	
	nrdctato = $('#nrdctato','#frmContatos').val();
	nmdavali = $('#nmdavali','#frmContatos').val();
	nrtelefo = $('#nrtelefo','#frmContatos').val();
	dsdemail = $('#dsdemail','#frmContatos').val();
	
	nrdctato = normalizaNumero(nrdctato);
	
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		url: UrlSite + 'telas/contas/contatos/manter_rotina.php', 		
		data: {
			nrdconta: nrdconta, idseqttl: idseqttl, nrdctato: nrdctato,
			nmdavali: nmdavali, nrtelefo: nrtelefo, dsdemail: dsdemail,	
			operacao: operacao, nrdrowid: nrdrowid,	redirect: 'script_ajax'
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

function controlaLayoutContatos(operacao) {		
	
	altura  = ( in_array(operacao,['CT','AT','IT','FI','FA','FE','']) ) ? '205px' : '150px';
	largura = ( in_array(operacao,['CT','AT','IT','FI','FA','FE','']) ) ? '580px' : '580px';
	divRotina.css('width',largura);	
	
	if ( in_array(operacao,['TC','TA','TX','TI']) ) {	
		$('#divConteudoOpcao').css('height',altura);
	}
	
	// Operação consultando
	if ( in_array(operacao,['CT','AC','IC','FI','FA','FE','']) ) {	

		var divRegistro = $('div.divRegistrosContatos');		
		var tabela      = $('table', divRegistro );
		var linha       = $('table > tbody > tr', divRegistro );
			
		divRegistro.css('height','60px');
		
		var ordemInicial = new Array();
		ordemInicial = [[0,0]];
		
		var arrayLargura = new Array();
		arrayLargura[0] = '60px';
		arrayLargura[1] = '160px';
		arrayLargura[2] = '70px';
		arrayLargura[3] = '158px';
		
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'right';

		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, 'controlaOperacaoContatos(\'TA\')' );
		
		$('#frmReferencias > fieldset > table').remove();

	
	// Operação Alterando/Incluindo
	} else {			
	
		// RÓTULOS - ENDEREÇO / CONTA / NOME/ TELEFONE / EMAIL
		var rCon	= $('label[for="nrdctato"]','#'+nomeFormContatos);
		var rNom	= $('label[for="nmdavali"]','#'+nomeFormContatos);
		
		var rTel	= $('label[for="nrtelefo"]','#'+nomeFormContatos);
		var rEma	= $('label[for="dsdemail"]','#'+nomeFormContatos);
		
		// conta e nome
		rCon.addClass('rotulo rotulo-70');
		rNom.addClass('rotulo-linha').css('width','35px');
			
		// telefone e email
		rTel.addClass('rotulo rotulo-70');
		rEma.addClass('rotulo-40');

		// CAMPOS - ENDEREÇO / CONTA / NOME TELEFONE / EMAIL
		var cTodos	= $('input, select','#'+nomeFormContatos);
		var cSelect = $('select','#frmContatos');
		var cConta 	= $('#nrdctato','#frmContatos');

		var cCon	= $('#nrdctato','#'+nomeFormContatos);
		var cNom	= $('#nmdavali','#'+nomeFormContatos);

		var cTel	= $('#nrtelefo','#'+nomeFormContatos);
		var cEma	= $('#dsdemail','#'+nomeFormContatos);
		
		// conta e nome
		cCon.css('width','65px').addClass('conta pesquisa');
		cNom.css('width','324px').addClass('alphanum').attr('maxlength','40');
	
		
		// telefone e email
		cTel.css('width','150px').attr('maxlength','20');
		cEma.css('width','257px').attr('maxlength','30');
		
		
		// Formatanto os Campos
		cTodos.habilitaCampo();
		
		
		switch (operacao) {
			case 'TI': // Caso Inclusão
				$('#'+nomeFormContatos).limpaFormulario();
				cTodos.desabilitaCampo();
				cSelect.desabilitaCampo();
				cConta.habilitaCampo();
				controlaPesquisasContatos();
				break;
			case 'TC': // Caso Consulta
				cTodos.desabilitaCampo();
				cSelect.desabilitaCampo();
				break;
			case 'TX': // Caso Exclusão Consulta
				cTodos.desabilitaCampo();
				cSelect.desabilitaCampo();
				break;			
			case 'TB': // Caso Pesquisa pela Conta para Inclusão
				cTodos.desabilitaCampo();
				cSelect.desabilitaCampo();
				break;
			case 'TA': // Caso Alteração
				cTodos.habilitaCampo();
				cSelect.habilitaCampo();
				cConta.desabilitaCampo();
				break;
		}
		
		controlaPesquisasContatos();		
		layoutPadrao();
		
		if (in_array(operacao,['TA','TX','TC','TB'])) {		
			cConta.trigger('blur');
		}
		
		// Ao mudar Nr. Conta do Contato, busca os dados do Contato, caso a conta for vazia, limpar formulário
		cConta.unbind('keydown').bind('keydown', function(e){ 		
			if ( divError.css('display') == 'block' ) { return false; }				
			// Se é a tecla ENTER, verificar numero conta e realizar as devidas operações
			if ( e.keyCode == 13 ) {							
				// Armazena o número da conta na variável global
				nrconta = normalizaNumero( $(this).val() );							
				// Verifica se o número da conta é vazio
				if ( nrconta == '' || nrconta == 0 ) { 
					cTodos.habilitaCampo();
					cSelect.habilitaCampo();
					cConta.desabilitaCampo();
					controlaPesquisasContatos();
					cNom.focus();
					
				} else {
					if ( !validaNroConta(nrconta) ) { showError('error','Conta/dv inválida.','Alerta - Aimaro','bloqueiaFundo(divRotina);'); return false; }
					nrdctato = nrconta;
					controlaOperacaoContatos('TB');
				}
				return false;
			}		
		});
		
		cEma.unbind("keydown").bind("keydown",function(e) {
			if (e.keyCode == 13) {
				$("#btSalvar","#divBotoes").trigger("click");
				return false;
			}	
		});	

	}
			
	hideMsgAguardo();
	bloqueiaFundo(divRotina);
	removeOpacidade('divConteudoOpcao');
	highlightObjFocus($('#divConteudoOpcao'));
	controlaFocoEnter("divConteudoOpcao");
	controlaFocoContatos(operacao);
	divRotina.centralizaRotinaH();
	return false;	
}

function controlaFocoContatos(operacao) {
	if (in_array(operacao,['CT','AT','IT','FA','FI','FE',''])) {
		$('#btConsultar','#divBotoes').focus();
	} else if (operacao == 'TC'){
		$('#btVoltar','#divBotoes').focus();
	} else {
		$('#nrdctato','#'+nomeFormContatos).focus();
	}
	return false;
}

function controlaPesquisasContatos() {
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	
	// CONTROLE DAS PESQUISAS
	
	// Atribui a classe lupa para os links de desabilita todos
	$('a','#'+nomeFormContatos).addClass('lupa').css('cursor','auto');
	
	// Percorrendo todos os links
	$('a','#'+nomeFormContatos).each( function() {
	
		if ( !$(this).prev().hasClass('campoTelaSemBorda') ) { $(this).css('cursor','pointer'); }
		
		$(this).click( function() {
			if ( $(this).prev().hasClass('campoTelaSemBorda') ) {
				return false;
			} else {						
				campoAnterior = $(this).prev().attr('name');
				
				// numero da conta
				if ( campoAnterior == 'nrdctato' ) {
					mostraPesquisaAssociado('nrdctato',nomeFormContatos,divRotina);	
					return false;					
				
				} 
			}
			return false;
		});
	});
	
	return false;
}

function btLimpar(){		
	
	cTodos = $('input, select','#frmContatos');
	cSelect = $('select','#frmContatos');
	cConta = $('#nrdctato','#frmContatos');
	cNome = $('#nmdavali','#frmContatos');
	
	$('#'+nomeFormContatos).limpaFormulario();
	cTodos.desabilitaCampo();
	cSelect.desabilitaCampo();
	cConta.habilitaCampo();
	controlaPesquisasContatos();
	controlaFocoContatos(operacao);

	return false;	
}
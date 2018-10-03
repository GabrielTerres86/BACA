/*!
 * FONTE        : informativos.js
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 19/04/2010 
 * OBJETIVO     : Biblioteca de funções na rotina INFORMATIVOS da tela de CONTAS
 *
 * ALTERACOES   : 18/09/2015 - Reformulacao cadastral (Gabriel-RKAM)
 */

var nrdrowid = '';
var operacao = '';
var cddopcao = 'C';
var cdrelato, cdprogra, cddfrenv, cdperiod, cdseqinc;

function acessaOpcaoAba(nrOpcoes,id,opcao) {

	showMsgAguardo('Aguarde, carregando...');
	
	for (var i = 0; i < nrOpcoes; i++) {
		if (!$('#linkAba' + id)) {
			continue;
		}
		
		if (id == i) { // Atribui estilos para foco da opção cdseqinc
			$('#linkAba' + id).attr('class','txtBrancoBold');
			$('#imgAbaEsq' + id).attr('src',UrlImagens + 'background/mnu_sle.gif');				
			$('#imgAbaDir' + id).attr('src',UrlImagens + 'background/mnu_sld.gif');
			$('#imgAbaCen' + id).css('background-color','#969FA9');
			continue;			
		}
		
		$('#linkAba' + i).attr('class','txtNormalBold');
		$('#imgAbaEsq' + i).attr('src',UrlImagens + 'background/mnu_nle.gif');			
		$('#imgAbaDir' + i).attr('src',UrlImagens + 'background/mnu_nld.gif');
		$('#imgAbaCen' + i).css('background-color','#C6C8CA');
	}

	$.ajax({		
		type: 'POST', 
		dataType: 'html',
		url: UrlSite + 'telas/contas/informativos/principal.php',
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			nrdrowid: nrdrowid,
			cddopcao: cddopcao,
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
	
	if ( operacao != 'CE' && operacao != 'EC' && !verificaContadorSelect() ) return false;	
	
	if ( (operacao == 'BI') && (flgIncluir != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de inclus&atilde;o.'         ,'Alerta - Aimaro','bloqueiaFundo(divRotina)'); return false; }
	if ( (operacao == 'CX') && (flgExcluir != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de exclus&atilde;o.'         ,'Alerta - Aimaro','bloqueiaFundo(divRotina)'); return false; }
	
	if ( in_array(operacao,['CA','CX']) ) {
		nrdrowid = '';
		$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				nrdrowid = $('input', $(this) ).val();
			}
		});
		if ( nrdrowid == '' ) { return false; }	
	}
	
	var msgOperacao = '';
	if (in_array(operacao,['FA','FI','FE','','EC'])) {
		//alert('Op vazia');
		msgOperacao = 'abrindo consulta';			
		nrdrowid    = '';
		cddopcao    = 'C';
	} else if ( operacao == 'AC' ) {
		showConfirmacao('Deseja cancelar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','controlaOperacao(\'\')','bloqueiaFundo(divRotina)','sim.gif','nao.gif');
		return false;
	} else  if ( operacao == 'IC' ) {
		showConfirmacao('Deseja cancelar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','controlaOperacao(\'BI\')','bloqueiaFundo(divRotina)','sim.gif','nao.gif');
		return false;
	} else if (in_array(operacao,['AV','IV','VA','VI'])) {
		manterRotina(operacao);
		return false;
	} else if ( operacao == 'CI'  ) {
		cdrelato = '';
		cdprogra = '';
		cddfrenv = '';
		cdperiod = '';
				
		$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				cdrelato = $('#cdrelato', $(this) ).val();
				cdprogra = $('#cdprogra', $(this) ).val();
				cddfrenv = $('#cddfrenv', $(this) ).val();
				cdperiod = $('#cdperiod', $(this) ).val();
			}
		});
		if ( cdperiod == '' && cddfrenv == '' && cdprogra == '' && cdrelato == '' ) { return false; }		
		msgOperacao = 'abrindo inclus&atilde;o';	
		cddopcao    = 'I';		
	} else if ( operacao == 'BI' ) {
		msgOperacao = 'abrindo inclus&atilde;o';
		cdrelato = '';
		cdprogra = '';
		cddfrenv = '';
		cdperiod = '';			
		cddopcao    = 'I';		
	} else if ( operacao == 'CA' ) {
		msgOperacao = 'abrindo altera&ccedil;&atilde;o';
		cddopcao = 'A';
	} else if ( operacao == 'CX' ) {
		msgOperacao = 'abrindo exclus&atilde;o';
		cddopcao = 'E';
	} else if ( operacao == 'CE' ) {
		showConfirmacao('Deseja confirmar exlus&atilde;o do informativo?','Confirma&ccedil;&atilde;o - Aimaro','manterRotina(\''+operacao+'\')','controlaOperacao(\'EC\')','sim.gif','nao.gif');
		return false;	
	}

	showMsgAguardo('Aguarde, ' + msgOperacao + '...');

	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/contas/informativos/principal.php', 
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			operacao: operacao,
			nrdrowid: nrdrowid,
			cddopcao: cddopcao,
			cdrelato: cdrelato,
			cdprogra: cdprogra,
			cddfrenv: cddfrenv,
			cdperiod: cdperiod,		
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

function manterRotina(operacao) {
	
	hideMsgAguardo();
	var msgOperacao = '';
	switch (operacao) {	
		case 'VA':
			msgOperacao = 'salvando altera&ccedil;&atilde;o'; 
			cddopcao    = 'A';
			break;
		case 'VI': 
			msgOperacao = 'salvando inclus&atilde;o'; 
			cddopcao    = 'I';
			break;
		case 'AV': 
			msgOperacao = 'validando altera&ccedil;&atilde;o'; 
			cddopcao    = 'A';
			break;			
		case 'IV': 
			msgOperacao = 'validando inclus&atilde;o'; 
			cddopcao    = 'I';
			break;			
		case 'CE': 
			msgOperacao = 'excluindo'; 
			cddopcao    = 'E';
			break;				
		default: 
			return false; 
			break;
	}
	
	showMsgAguardo('Aguarde, ' + msgOperacao + '...');
	
	if ( operacao != 'CE' ) {
		cdrelato = $('#cdrelato','#frmDadosInformativos').val();
		cdprogra = $('#cdprogra','#frmDadosInformativos').val();
		cddfrenv = $('#cddfrenv','#frmDadosInformativos').val();
		cdperiod = $('#cdperiod','#frmDadosInformativos').val();
		cdseqinc = $('#cdseqinc','#frmDadosInformativos').val();
	}
		
	$.ajax({		
		type: 'POST',
		url: UrlSite + 'telas/contas/informativos/manter_rotina.php', 		
		data: {
			nrdconta: nrdconta,	idseqttl: idseqttl,	cdrelato: cdrelato,	
			cdprogra: cdprogra,	cddfrenv: cddfrenv,	cdperiod: cdperiod,
			cdseqinc: cdseqinc,	nrdrowid: nrdrowid,	cddopcao: cddopcao,	
			operacao: operacao,	redirect: 'script_ajax'
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

function controlaLayout( operacao ) {	

	$('#divInformativos').fadeTo(1,0.01);
	
	altura  = ( in_array(operacao,['AC','IC','FI','FA','FE','BI','','EC']) ) ? '205px' : '145px';
	largura = ( in_array(operacao,['AC','IC','FI','FA','FE','BI','','EC']) ) ? '540px' : '480px';	
	$('#divConteudoOpcao').css({'height':altura,'width':largura});	
	
	// Operação consultando
	if ( in_array(operacao,['AC','IC','FI','FA','FE','','EC']) ) {	
				
		var divRegistro = $('div.divRegistros');		
		var tabela      = $('table', divRegistro );
		var linha       = $('table > tbody > tr', divRegistro );
		
		divRegistro.css('height','150px');
		
		var ordemInicial = new Array();
		ordemInicial = [[0,0]];
		
		var arrayLargura = new Array();
		arrayLargura[0] = '175px';
		arrayLargura[1] = '85px';
		arrayLargura[2] = '85px';
		
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'left';
		arrayAlinha[1] = 'center';
		arrayAlinha[2] = 'center';
		arrayAlinha[3] = 'left';
		
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, 'controlaOperacao(\'CA\')' );
		
	// Operação Alterando/Incluindo
	} else if ( operacao == 'BI' ) {	
				
		var divRegistro = $('div.divRegistros');		
		var tabela      = $('table', divRegistro );
		var linha       = $('table > tbody > tr', divRegistro );
		
		divRegistro.css('height','150px');
		
		var ordemInicial = new Array();
		ordemInicial = [[0,0]];
		
		var arrayLargura = new Array();
		arrayLargura[0] = '190px';
		arrayLargura[1] = '90px';
		arrayLargura[2] = '90px';
		
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'left';
		arrayAlinha[1] = 'center';
		arrayAlinha[2] = 'center';
		arrayAlinha[3] = 'center';
		
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, 'controlaOperacao(\'CI\')' );
		
	// Operação Alterando/Incluindo
	} else {	
	
		var filtro        = '';
		var cdrelatoCampo = $('#nmrelato','#frmDadosInformativos');
		var cddfrenvCampo = $('#dsdfrenv','#frmDadosInformativos');
		var cdperiodCampo = $('#cdperiod','#frmDadosInformativos');
		var cdseqincCampo = $('#cdseqinc','#frmDadosInformativos');			
	
		// Controla CSS
		$('#frmDadosInformativos').css('padding-top','5px');
		$('label','#frmDadosInformativos').addClass('rotulo rotulo-120');
		cdrelatoCampo.css('width','300px');
		cddfrenvCampo.css('width','150px');
		cdperiodCampo.css('width','150px');
		cdseqincCampo.css('width','300px');	
		
		cdseqincCampo.unbind("keydown").bind("keydown",function(e) {
			if (e.keyCode == 13) {
				$("#btSalvar","#divBotoes").trigger("click");
				return false;
			}	
		});	
		
		// Inclusão
		if ( operacao == 'CI' ) {
		
			// Inicio somente com o primeiro select habilitado, após escolhido algum valor, monto o select logo abaixo, 
			// pois os valores permitidos dependem do valor escolhido no select anterior.
			cdrelatoCampo.desabilitaCampo();
			cddfrenvCampo.desabilitaCampo();
			cdperiodCampo.desabilitaCampo();
			cdseqincCampo.habilitaCampo();
			
			filtros = 'cdrelato;'+cdrelato+'|cddfrenv;'+cddfrenv;
			montaSelect('b1wgen0064.p','busca_relatorios','cdperiod','cdperiod','dsperiod',cdperiod,filtros);
			
			// Select para o campo Recebimento - Sempre filtrar pela Conta e Titular, e 
			filtros = 'nrdconta;'+nrdconta+'|idseqttl;'+idseqttl+'|cddfrenv;'+cddfrenv;
			montaSelect('b1wgen0059.p','busca_recebimento','cdseqinc','cdrecebe','dsrecebe',cdseqinc,filtros);					
			
		// Alteração
		} else if ( operacao == 'CA' ) {
		
			cdrelatoCampo.desabilitaCampo();
			cddfrenvCampo.desabilitaCampo();
			cdperiodCampo.habilitaCampo();
			cdseqincCampo.habilitaCampo();
			
			// montaSelect para o campo Período - Filtrar pelo Informativo e Forma de Envio
			filtros = 'cdrelato;'+cdrelato+'|cddfrenv;'+cddfrenv;
			montaSelect('b1wgen0064.p','busca_relatorios','cdperiod','cdperiod','dsperiod',cdperiod,filtros);
			
			// Select para o campo Recebimento - Sempre filtrar pela Conta e Titular, e 
			filtros = 'nrdconta;'+nrdconta+'|idseqttl;'+idseqttl+'|cddfrenv;'+cddfrenv;
			montaSelect('b1wgen0059.p','busca_recebimento','cdseqinc','cdrecebe','dsrecebe',cdseqinc,filtros);
			
		} else if ( operacao == 'CX' ) {
		
			cdrelatoCampo.removeClass('campoTelaSemBorda').addClass('campo').removeProp('disabled');
			cddfrenvCampo.removeClass('campoTelaSemBorda').addClass('campo').removeProp('disabled');						
			cdperiodCampo.removeClass('campoTelaSemBorda').addClass('campo').removeProp('disabled');
			cdseqincCampo.removeClass('campoTelaSemBorda').addClass('campo').removeProp('disabled');

			// montaSelect para o campo Período - Filtrar pelo Informativo e Forma de Envio
			filtros = 'cdrelato;'+cdrelato+'|cddfrenv;'+cddfrenv;
			montaSelect('b1wgen0064.p','busca_relatorios','cdperiod','cdperiod','dsperiod',cdperiod,filtros);
			
			// Select para o campo Recebimento - Sempre filtrar pela Conta e Titular, e 
			filtros = 'nrdconta;'+nrdconta+'|idseqttl;'+idseqttl+'|cddfrenv;'+cddfrenv;
			montaSelect('b1wgen0059.p','busca_recebimento','cdseqinc','cdrecebe','dsrecebe',cdseqinc,filtros);
			
		}	
	}
	layoutPadrao();	
	hideMsgAguardo();
	bloqueiaFundo(divRotina);
	removeOpacidade('divInformativos');
	highlightObjFocus($('#divInformativos'));
	controlaFocoEnter("divInformativos");
	controlaFoco(operacao);	
	return false;
}

function controlaFoco(operacao) {
	
	if (in_array(operacao,['AC','IC','FI','FA','FE',''])) {
		$('#btAlterar','#divBotoes').focus();
	} else if (operacao == 'BI') {
		$('#btIncluir','#divBotoes').focus();
	} else if ( operacao == 'CI' ){
		$('#cdseqinc','#frmDadosInformativos').focus();
	} else {
		$('#cdperiod','#frmDadosInformativos').focus();
	}
	return false;
}



function voltarRotina() {
	acessaOpcaoAbaDados(4,1,'@');
}

function proximaRotina () {
	acessaOpcaoAbaDados(4,3,'@');			
}
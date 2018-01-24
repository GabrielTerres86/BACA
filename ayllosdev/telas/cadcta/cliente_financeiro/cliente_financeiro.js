/*!
 * FONTE        : cliente_financeiro.js
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : Março/2010 
 * OBJETIVO     : Biblioteca de funções na rotina CLIENTE FINANCEIRO da tela de CADCTA
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 001: [29/03/2010] Rodolpho Telmo     (DB1) : Controle de Abas
 * 002: [08/05/2010] Rodolpho Telmo     (DB1) : Função para impressão da ficha cadastral
 * 003: [05/05/2010] Rodolpho Telmo     (DB1) : Adaptação da tela ao "tableSorter"
 * 004: [11/11/2010] Gabriel Capoia     (DB1) : Bloqueio do campo "Instituição Financeira"
 * 005: [29/06/2012] Jorge Hamaguchi (CEBRED) : Ajuste em esquema de impressao em  imprimeFichaCadastralCF()
 * 006: [09/07/2012] Jorge Hamaguchi (CEBRED) : Retirado campo "redirect" popup.
 * 007: [05/08/2015] Gabriel (RKAM)           : Reformulacao cadastral. 
 */
 
var tpregist = '';
var nrdrowid = '';
var dtmvtosf = '';
var dtmvtolt = '';
var hrtransa = '';
var nrseqdig = '';
var flgenvio = '';
var dtdenvio = '';
var insitcta = '';
var dtdemiss = '';
var cdmotdem = '';

function acessaOpcaoAba(nrOpcoes,id,opcao,operacao) {  
	
	// Controle das Abas
	if (id == '1') { // Primeira Aba - Dados Sistema Financeiro
		var msg = 'Dados Sistema Financeiro';
	} else if (id == '2') {	// Segunda Aba - Emissão Ficha Cadastral
		var msg = "Emiss&atilde;o Ficha Cadastral";
	} 
	tpregist = id;
	
	// Mostra mensagem de aguardo
	showMsgAguardo('Aguarde, carregando...');
	
	// Atribui cor de destaque para aba da opção
	for (var i = 1; i <= nrOpcoes; i++) {
		if (id == i) { // Atribui estilos para foco da opção
			$('#linkAbaCli' + id).attr('class','txtBrancoBold');
			$('#imgAbaCliEsq' + id).attr('src',UrlImagens + 'background/mnu_sle.gif');				
			$('#imgAbaCliDir' + id).attr('src',UrlImagens + 'background/mnu_sld.gif');
			$('#imgAbaCliCen' + id).css('background-color','#969FA9');
			continue;			
		}
		$('#linkAbaCli' + i).attr('class','txtNormalBold');
		$('#imgAbaCliEsq' + i).attr('src',UrlImagens + 'background/mnu_nle.gif');			
		$('#imgAbaCliDir' + i).attr('src',UrlImagens + 'background/mnu_nld.gif');
		$('#imgAbaCliCen' + i).css('background-color','#C6C8CA');
	}

	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: 'POST', 
		dataType: 'html',
		url: UrlSite + 'telas/cadcta/cliente_financeiro/principal.php',
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			tpregist: tpregist,
			nrseqdig: nrseqdig,
			nrdrowid: nrdrowid,
			flgcadas: flgcadas,
			operacao: operacao,
			redirect: 'html_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',bloqueiaFundo(divRotina));
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 ) {
				$('#divConteudoCliente').html(response);
			} else {
				eval( response );
				controlaFoco( operacao );
			}
			return false;
		}		
	}); 		
}

function controlaOperacao(operacao) {
	
	if ( in_array(operacao,['FD','VEE','VED']) ) {
		nrdrowid = ''; dtmvtosf = ''; dtmvtolt = ''; hrtransa = ''; nrseqdig = ''; 
		flgenvio = ''; dtdenvio = ''; insitcta = ''; dtdemiss = ''; cdmotdem = '';		
		$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				nrdrowid = $('#nrdrowid', $(this) ).val();
				dtmvtosf = $('#dtmvtosf', $(this) ).val();
				dtmvtolt = $('#dtmvtolt', $(this) ).val();
				hrtransa = $('#hrtransa', $(this) ).val();
				nrseqdig = $('#nrseqdig', $(this) ).val();
				flgenvio = $('#flgenvio', $(this) ).val();
				dtdenvio = $('#dtdenvio', $(this) ).val();
				insitcta = $('#insitcta', $(this) ).val();
				dtdemiss = $('#dtdemiss', $(this) ).val();
				cdmotdem = $('#cdmotdem', $(this) ).val();
				// alert( 'dtmvtosf='+dtmvtosf+'| dtmvtolt='+dtmvtolt+'| nrseqdig='+nrseqdig );
			}
		});
		if ( nrdrowid == '' && dtmvtosf == '' && dtmvtolt == '' && hrtransa == '' && nrseqdig == '' &&
			 flgenvio == '' && dtdenvio == '' && insitcta == '' && dtdemiss == '' && cdmotdem == '' ) { return false; }		
	}
	
	// Mostra mensagem de aguardo nrseqdig
	var msgOperacao = '';
	switch (operacao) {			
		case 'TD': // Consulta tabela dados
			nrdrowid = ''; dtmvtosf = ''; dtmvtolt = ''; hrtransa = ''; nrseqdig = ''; 
			flgenvio = ''; dtdenvio = ''; insitcta = ''; dtdemiss = ''; cdmotdem = '';		
			msgOperacao = 'abrindo consulta de Dados';
			acessaOpcaoAba(2,1,'@',operacao);
			return false;
			break;
		case 'TE': //Consulta tabela Emissão
			nrdrowid = ''; dtmvtosf = ''; dtmvtolt = ''; hrtransa = ''; nrseqdig = ''; 
			flgenvio = ''; dtdenvio = ''; insitcta = ''; dtdemiss = ''; cdmotdem = '';
			msgOperacao = 'abrindo consulta de Emiss&atilde;o';
			acessaOpcaoAba(2,2,'@',operacao);
			return false;
			//showMsgAguardo('Aguarde, ' + msgOperacao + ' de Cliente Financeiro ...');
			break;			
		case 'FD': // Abre Formulario Dados
			msgOperacao = 'abrindo formul&aacute;rio de dados';
			break;
		case 'CO': // Cancela opereção de inclusão/alteração de ambos os formulários
			showConfirmacao('Deseja cancelar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','controlaOperacao(\'\')','bloqueiaFundo(divRotina)','sim.gif','nao.gif');
			return false;
			break;
		case 'FI': // Abre Formulario Dados em modo inclusão
			msgOperacao = 'abrindo formul&aacute;rio de dados';
			break;
		case 'FE': // Abre Formulario Emissão
			msgOperacao = 'abrindo inclus&atilde;o';
			nrseqdig = '';
			break;				
		case 'VA': //Valida alteração no formulario de dados
			manterRotina(operacao);
			return false;
			break;
		case 'VD': //Valida inclusão no formulario de dados
			manterRotina(operacao);
			return false;
			break;
		case 'VE': //Valida inclusão no formulario de emissão
			manterRotina(operacao);
			return false;
			break;
		case 'VEE': //Valida exclusão no formulario de emissão
			manterRotina(operacao);
			return false;
			break;
		case 'VED': //Valida exclusão no formulario de emissão
			manterRotina(operacao);
			return false;
			break;
		case 'AD': //Altera dados do formulario de dados após validar
			manterRotina(operacao);
			return false;
			break;
		case 'ID': //Inclui dados do formulario de dados após validar
			manterRotina(operacao);
			return false;
			break;
		case 'IE': //Inclui dados do formulario de emissão após validar
			manterRotina(operacao);
			return false;
			break;		
		// Qualquer outro valor: Cancelando Operação
		default: 
			msgOperacao = 'abrindo consulta de Dados';
			nrdrowid = ''; dtmvtosf = ''; dtmvtolt = ''; hrtransa = ''; nrseqdig = ''; 
			flgenvio = ''; dtdenvio = ''; insitcta = ''; dtdemiss = ''; cdmotdem = '';
			var op = ( tpregist == 1 ) ? 'TD' : 'TE'; 
			acessaOpcaoAba(2,tpregist,'@',op);
			showMsgAguardo('Aguarde, ' + msgOperacao + '...');
			return false;
			break;			
	}
	
	showMsgAguardo('Aguarde, ' + msgOperacao + '...');
	
	
	// Executa script de através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadcta/cliente_financeiro/principal.php', 
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			tpregist: tpregist,
			nrseqdig: nrseqdig,
			nrdrowid: nrdrowid,
			flgcadas: flgcadas,
			operacao: operacao,
			redirect: "script_ajax"
		},  
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',bloqueiaFundo(divRotina));
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 ) {						
				$('#divConteudoCliente').html(response);
			} else {
				eval( response );
				controlaFoco( operacao );
			}
			if ( (operacao=='I') || (operacao=='FA') ) {
				showError('inform','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Retorno - Ayllos',bloqueiaFundo(divRotina));
				if (operacao=='I') {
					obtemTitular();
				}
			}				
			return false;			
		}				
	});
		
}

function manterRotina(operacao) {

	hideMsgAguardo();		
	var msgOperacao = '';
	switch (operacao) {	
		case 'VA': msgOperacao = 'validando altera&ccedil;&atilde;o '; break;
		case 'VD': msgOperacao = 'validando inclus&atilde;o '; break;
		case 'VE': msgOperacao = 'validando inclus&atilde;o '; break;
		case 'VEE': msgOperacao = 'validando exclus&atilde;o '; break;
		case 'VED': msgOperacao = 'validando exclus&atilde;o '; break;
		case 'AD': msgOperacao = 'alterando '; break;						
		case 'ED': msgOperacao = 'excluindo '; break;						
		case 'EE': msgOperacao = 'excluindo '; break;						
		case 'ID': msgOperacao = 'incluindo '; break;						
		case 'IE': msgOperacao = 'incluindo '; break;						
		default: return false; break;
	}
	showMsgAguardo('Aguarde, ' + msgOperacao + '...');
	
	// Descobre com qual formulário estamos trabalhando
	var nomeFormulario = (tpregist == 1) ? '#formDadosSistFinanc' : '#formEmissaoSistFinanc';
	
	// Recebendo valores do formulário  
	var nrcpfcgc = $('#nrcpfcgc','#frmCabClienteFinanceiro').val();	
	var cddbanco = $('#cddbanco',nomeFormulario).val();
	var cdageban = $('#cdageban',nomeFormulario).val();
	var cdagenci = $('#cdagenci',nomeFormulario).val();
	var dtabtcct = $('#dtabtcct',nomeFormulario).val();
	var nrdctasf = $('#nrdctasf',nomeFormulario).val();
	var dgdconta = $('#dgdconta',nomeFormulario).val();
	var nminsfin = $('#nminsfin',nomeFormulario).val();
	
	// alert('operacao='+operacao);
	
	// Recebendo os valores hidden
	if (!in_array(operacao,['VEE','VED','ED','EE']) ) {
		dtmvtosf = $('#dtmvtosf',nomeFormulario).val();
		dtmvtolt = $('#dtmvtolt',nomeFormulario).val();
		hrtransa = $('#hrtransa',nomeFormulario).val();
		nrseqdig = $('#nrseqdig',nomeFormulario).val();
		flgenvio = $('#flgenvio',nomeFormulario).val();
		dtdenvio = $('#dtdenvio',nomeFormulario).val();
		insitcta = $('#insitcta',nomeFormulario).val();
		dtdemiss = $('#dtdemiss',nomeFormulario).val();
		cdmotdem = $('#cdmotdem',nomeFormulario).val();
	}
	
	// alert( 'dtmvtosf='+dtmvtosf+'| dtmvtolt='+dtmvtolt+'| nrseqdig='+nrseqdig );
	
	$.ajax({		
		type: 'POST',
		url: UrlSite + 'telas/cadcta/cliente_financeiro/manter_rotina.php', 		
		data: {
			nrdconta: nrdconta, idseqttl: idseqttl, nrcpfcgc: nrcpfcgc,						
			tpregist: tpregist, nrseqdig: nrseqdig, cddbanco: cddbanco,		                
			cdageban: cdageban, dtabtcct: dtabtcct, nrdctasf: nrdctasf,                     
			hrtransa: hrtransa, flgenvio: flgenvio, dtdenvio: dtdenvio,                     
			insitcta: insitcta, dtdemiss: dtdemiss, cdmotdem: cdmotdem,                     
			cdagenci: cdagenci, nminsfin: nminsfin, dgdconta: dgdconta, 
			dtmvtolt: dtmvtolt, nrdrowid: nrdrowid, operacao: operacao,                     
			dtmvtosf: dtmvtosf, flgcadas: flgcadas, redirect: 'script_ajax'                                                         
		},                                                                                  
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',bloqueiaFundo(divRotina));
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',bloqueiaFundo(divRotina));
			}
		}				
	});
}

function controlaLayout(operacao) {	

	$('#divConteudoCliente').fadeTo(1,0.01);	
	altura  = '350px';
	largura = '550px';
	divRotina.css({'height':altura,'width':largura});	
	
	$('#nrcpfcgc','#frmCabClienteFinanceiro').addClass( ( inpessoa == 1 ) ? 'cpf' : 'cnpj' );
	
	// Cabecalho é somente leitura
	var cabecalho = $('#nrcpfcgc,#inpessoa,#nmextttl','#frmCabClienteFinanceiro');
	cabecalho.removeClass('campo').addClass('campoTelaSemBorda').prop('disabled',true);	
	
	// Definindo larguras
	$('#nrcpfcgc','#frmCabClienteFinanceiro').css('width','110px');
	$("label[for='inpessoa']","#frmCabClienteFinanceiro").css('width','245px');
	$('#inpessoa','#frmCabClienteFinanceiro').css('width','78px');
	$('#nmextttl','#frmCabClienteFinanceiro').css('width','436px');		
	
	$('#divConteudoClienteFinanc').css({'clear':'left','margin-top':'5px','padding-top':'5px','border-top':'1px solid #949EAD'});	
	$('#formDadosSistFinanc,#formEmissaoSistFinanc').css('height','174px');
	
	$('#dtabtcct,#nrdctasf,#dgdconta,#cddbanco,#cdageban','#formDadosSistFinanc').addClass('campo');
	$('#nmdbanco,#nmageban','#formDadosSistFinanc').css({'width':'379px'});
	$('#nminsfin','#formDadosSistFinanc').css({'width':'394px'});
	$('#dtabtcct','#formDadosSistFinanc').css({'width':'80px'});
	$('#nrdctasf','#formDadosSistFinanc').css({'width':'85px'});
	$('#dgdconta','#formDadosSistFinanc').css({'width':'30px'});
	
	//Alteração: Mantem sempre o campo instituição finaceira bloqueado
	$('#nminsfin','#formDadosSistFinanc').desabilitaCampo();
	
	var codigoD = $('.codigo','#formDadosSistFinanc');
	var codigoE = $('.codigo','#formEmissaoSistFinanc'); 
	
	switch (operacao) { 			
		
		// Consulta Tabela Dados Cliente Financeiro
		case 'TD': 
			
			var divRegistro = $('#divTabelaDadosFin');		
			var tabela      = $('table', divRegistro );
			var linha       = $('table > tbody > tr', divRegistro );
			
			divRegistro.css('height','150px');
			
			var ordemInicial = new Array();
			ordemInicial = [[0,0]];
			
			var arrayLargura = new Array();
			arrayLargura[0] = '55px';
			arrayLargura[1] = '65px';
			arrayLargura[2] = '80px';
			arrayLargura[3] = '35px';
			arrayLargura[4] = '70px';
			
			var arrayAlinha = new Array();
			arrayAlinha[0] = 'right';
			arrayAlinha[1] = 'right';
			arrayAlinha[2] = 'right';
			arrayAlinha[3] = 'right';
			arrayAlinha[4] = 'center';
			arrayAlinha[5] = 'left';
			
			tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, 'controlaOperacao(\'FD\');' );
					
			break;
		// Consulta Tabela Emissao Cliente Financeiro	
		case 'TE': 
		
			var divRegistro = $('#divTabelaEmissaoFin');		
			var tabela      = $('table', divRegistro );
			var linha       = $('table > tbody > tr', divRegistro );
			
			divRegistro.css('height','150px');
			
			var ordemInicial = new Array();
			ordemInicial = [[0,0]];
			
			var arrayLargura = new Array();
			arrayLargura[0] = '173px';
			arrayLargura[1] = '173px';
			
			var arrayAlinha = new Array();
			arrayAlinha[0] = 'center';
			arrayAlinha[1] = 'center';
			arrayAlinha[2] = 'center';
			
			tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha );
					
		// Formulário de Dados modo inclusão
		case 'FI': 
			$("#formDadosSistFinanc").limpaFormulario();
			$('#nminsfin','#formDadosSistFinanc').desabilitaCampo();
			break;

		// Formulário de Dados	
		case 'FD': 
			break;
			
		case 'FE': // Formulário Emissão
			$("#formEmissaoSistFinanc").limpaFormulario();
			$('#nmdbanco,#nmageban','#formEmissaoSistFinanc').css({'width':'379px'});
			$('#cddbanco,#cdageban','#formEmissaoSistFinanc').habilitaCampo();
			break;
		
		default: 
			break;
	}
		
	layoutPadrao();	
	
	$('#nrcpfcgc','#frmCabClienteFinanceiro').trigger('blur');
	
	codigoE.unbind('blur').bind('blur', function() { 
		controlaLupas(operacao);
	});
	codigoD.unbind('blur').bind('blur', function() { 
		controlaLupas(operacao); 
	});
	
	$('#dgdconta','#formDadosSistFinanc').unbind("keydown").bind("keydown",function(e) {
		if (e.keyCode == 13) {
			$("#btSalvar","#divBotoes").trigger("click");
			return false;
		}	
	});	
	
	$('#cdageban','#formEmissaoSistFinanc').unbind("keydown").bind("keydown",function(e) {
		if (e.keyCode == 13) {
			$("#btSalvar","#divBotoes").trigger("click");
			return false;
		}	
	});	
	
	hideMsgAguardo();
	bloqueiaFundo(divRotina);
	removeOpacidade('divConteudoCliente');
	divRotina.centralizaRotinaH();
	controlaLupas(operacao);	
	highlightObjFocus($('#divConteudoCliente'));
	controlaFocoEnter("divConteudoCliente");
	
	
	controlaFoco(operacao);	
	return false;
}

function controlaLupas(operacao) {

	if (!in_array(operacao,['FD','FI','FE'])) { return false; }
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = (in_array(operacao,['FD','FI'])) ? 'formDadosSistFinanc' : 'formEmissaoSistFinanc';
	
	// Atribui a classe lupa para os links de desabilita todos
	$('a','#'+nomeFormulario).addClass('lupa').css('cursor','auto');
	
	// Percorrendo todos os links
	$('a','#'+nomeFormulario).each( function(i) {
	
		if ( !$(this).prev().hasClass('campoTelaSemBorda') ) $(this).css('cursor','pointer');
		
		$(this).click( function() {
			if ( $(this).prev().hasClass('campoTelaSemBorda') ) {
				return false;
			} else {						
				campoAnterior = $(this).prev().attr('name');

				// Banco
				if ( campoAnterior == 'cddbanco' ) {
					bo			= 'b1wgen0059.p';
					procedure	= 'busca_banco';
					titulo      = 'Banco';
					qtReg		= '30';
					filtros 	= 'Cód. Banco;cddbanco;30px;S;0|Nome Banco;nmdbanco;200px;S;';
					colunas 	= 'Código;cdbccxlt;20%;right|Banco;nmextbcc;80%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,divRotina);
					return false;
				
				// Agência
				} else if ( campoAnterior == 'cdageban' ) {
					bo			= 'b1wgen0059.p';
					procedure	= 'busca_agencia';
					titulo      = 'Agência';
					qtReg		= '30';
					filtros 	= 'Cód. Agência;cdageban;30px;S;0|Agência;nmageban;200px;S;|Cód. Banco;cddbanco;30px;N;|Banco;nmdbanco;200px;N;';
					colunas 	= 'Código;cdageban;20%;right|Agência;nmageban;80%;left';
					mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,divRotina);
					return false;

				}			
			}
		});
	});
	
	
	// Bancos cddbanco
	$('#cddbanco','#'+nomeFormulario).unbind('change').bind('change',function() {		
		$('#cdageban,#nmageban','#'+nomeFormulario).val('');
		
		//Alteração: Mantem sempre o campo instituição finaceira bloqueado
		if ( nomeFormulario == 'formDadosSistFinanc'){
			// if ( $(this).val() == 0 || $(this).val() == '' ) {
			if ( $(this).val() == 0 ) {
				showError('error','Informe o banco','Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
				$('#cddbanco,#nmdbanco').val('');
				return false;
				// $('#nminsfin','#formDadosSistFinanc').habilitaCampo();
			}
		}	
		buscaDescricao('b1wgen0059.p','busca_banco','Banco',$(this).attr('name'),'nmdbanco',$(this).val(),'nmextbcc','cddbanco',nomeFormulario);
		return false;
	});	
	
			
	// Agencia
	$('#cdageban','#'+nomeFormulario).unbind('change').bind('change', function() {	
		if ($('#cddbanco','#'+nomeFormulario).val() == '') {
			showError('error','Informe o banco','Alerta - Ayllos', 'bloqueiaFundo(divRotina)');			
			return false;
		}		
		buscaDescricao('b1wgen0059.p','busca_agencia','Agencia',$(this).attr('name'),'nmageban',$(this).val(),'nmageban','cddbanco',nomeFormulario);
		return false;
	});	
	
	return false;
}

function controlaFoco(operacao) {
	if (in_array(operacao,['TD','TE',''])) {
		$('#btIncluir','#divBotoes').focus();
	} else if (in_array(operacao,['FD','FI'])) {
		$('.campo:first','#formDadosSistFinanc').focus();
	} 	
	return false;
}

function imprimeFichaCadastralCF(){	
	
	nrdrowid = '';	nrseqdig = '';
	$('table > tbody > tr', 'div.divRegistros').each( function() {
		if ( $(this).hasClass('corSelecao') ) {
			nrdrowid = $('#nrdrowid', $(this) ).val();
			nrseqdig = $('#nrseqdig', $(this) ).val();
		}
	});
	
	if ( nrdrowid == '' && nrseqdig == ''  ) { return false; }		
	
	
	$('#nrdconta','#frmCabClienteFinanceiro').remove();		
	$('#idseqttl','#frmCabClienteFinanceiro').remove();		
	$('#tpregist','#frmCabClienteFinanceiro').remove();		
	$('#nrseqdig','#frmCabClienteFinanceiro').remove();		
	$('#nrdrowid','#frmCabClienteFinanceiro').remove();		
	$('#sidlogin','#frmCabClienteFinanceiro').remove();		
	
	// Insiro input do tipo hidden do formulário para enviá-los posteriormente
	$('#frmCabClienteFinanceiro').append('<input type="hidden" id="nrdconta" name="nrdconta" />');
	$('#frmCabClienteFinanceiro').append('<input type="hidden" id="idseqttl" name="idseqttl" />');
	$('#frmCabClienteFinanceiro').append('<input type="hidden" id="tpregist" name="tpregist" />');
	$('#frmCabClienteFinanceiro').append('<input type="hidden" id="nrseqdig" name="nrseqdig" />');
	$('#frmCabClienteFinanceiro').append('<input type="hidden" id="nrdrowid" name="nrdrowid" />');
	$('#frmCabClienteFinanceiro').append('<input type="hidden" id="sidlogin" name="sidlogin" />');
	
	// Agora insiro os devidos valores nos inputs criados
	$('#nrdconta','#frmCabClienteFinanceiro').val( nrdconta );
	$('#idseqttl','#frmCabClienteFinanceiro').val( idseqttl );
	$('#tpregist','#frmCabClienteFinanceiro').val( tpregist );
	$('#nrseqdig','#frmCabClienteFinanceiro').val( nrseqdig );
	$('#nrdrowid','#frmCabClienteFinanceiro').val( nrdrowid );	
	$('#sidlogin','#frmCabClienteFinanceiro').val( $('#sidlogin','#frmMenu').val() );
	
	var action = UrlSite + 'telas/cadcta/cliente_financeiro/imp_fichacadastral.php';
	var callafter = "$('input,select','#frmCabClienteFinanceiro').desabilitaCampo();bloqueiaFundo(divRotina);";

	$('input,select','#frmCabClienteFinanceiro').habilitaCampo();
	
	carregaImpressaoAyllos("frmCabClienteFinanceiro",action,callafter);
	
}

function voltarRotina() {
	
	if (inpessoa == 1) {
		acessaOpcaoAbaDados(4,0,'@');
	} else {
		fechaRotina(divRotina);
		acessaRotina('CONTA CORRENTE','Conta Corrente','conta_corrente');	
	}
}

function proximaRotina () {
	hideMsgAguardo();
	
	if (inpessoa == 1) {
		acessaOpcaoAbaDados(4,2,'@');
	} else {
		encerraRotina(false);
		acessaRotina('FINANCEIRO-ATIVO/PASSIVO','Ativo/Passivo','ativo_passivo');	
	}			
}
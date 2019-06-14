/*!
 * FONTE        : banco.js
 * CRIAÇÃO      : Gabriel Capoia - DB1 Informatica
 * DATA CRIAÇÃO : 26/04/2010 
 * OBJETIVO     : Biblioteca de funções na rotina Faturamento da tela de CONTAS
 *
 * ALTERACOES   : 05/08/2015 - Reformulacao cadastral (Gabriel-RKAM)
 */

var nrposext = '';
var operacao = '';

function acessaOpcaoAba(nrOpcoes,id,opcao) {

	// Mostra mensagem de aguardo
	showMsgAguardo('Aguarde, carregando...');
	
	// Atribui cor de destaque para aba da opção
	for (var i = 0; i < nrOpcoes; i++) {
		if (!$('#linkAba' + id)) {
			continue;
		}
		
		if (id == i) { // Atribui estilos para foco da opção
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

	// Carrega conteúdo da opção através do Ajax
	$.ajax({		
		type: 'POST', 
		dataType: 'html',
		url: UrlSite + 'telas/contas/faturamento/principal.php',
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			nrposext: nrposext,
			flgcadas: flgcadas,
			operacao: operacao,
			redirect: 'html_ajax'
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','1 N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
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
	// Se não possui acesso para alterar, emitir mensagem	
	if ( (operacao == 'CA') && (flgAlterar != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de altera&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)'); return false; }
	if ( (operacao == 'CI') && (flgIncluir != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de inclus&atilde;o.' ,'Alerta - Aimaro','bloqueiaFundo(divRotina)'); return false; }
	if ( (operacao == 'CE') && (flgExcluir != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de exclus&atilde;o.' ,'Alerta - Aimaro','bloqueiaFundo(divRotina)'); return false; }
	
	if ( in_array(operacao,['CA','CE']) ) {
		nrposext = '';
		$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				nrposext = $('input', $(this) ).val();
			}
		});	
		if ( nrposext == '' ) { return false; }		
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
		// Consulta para Inclusão
		case 'CI': 
			msgOperacao = 'abrindo inclus&atilde;o';
			nrposext    = '';
			break;							
		// Inclusão para Consulta
		case 'IC': 
			showConfirmacao('Deseja cancelar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','controlaOperacao()','bloqueiaFundo(divRotina)','sim.gif','nao.gif');
			return false;
			break;			
		// Alteração para Validação: Validando Alteração
		case 'AV': 
			manterRotina(operacao);
			return false;
			break;
		// Inclusão para Validação: Validando Inclusão
		case 'IV': 
			manterRotina(operacao);
			return false;
			break;		
		// Validação para Alteração: Salvando Alteração
		case 'VA':
			manterRotina(operacao);
			return false;
			break;		
		// Validação para Inclusão: Salvando Inclusão
		case 'VI': 
			manterRotina(operacao);
			return false;
			break;
		// Consulta para Exclusão: Excluindo Bem
		case 'CE':
			//hideMsgAguardo();
			showConfirmacao('Deseja confirmar exclus&atilde;o do faturamento?','Confirma&ccedil;&atilde;o - Aimaro','manterRotina(\''+operacao+'\')','bloqueiaFundo(divRotina)','sim.gif','nao.gif');
			return false;
			break;	
		// Finalizou Alteração, mostrar mensagem
		case 'FA':
			msgOperacao = 'finalizando altera&ccedil;&atilde;o';
			nrposext	= '';
			break;	
		// Finalizou Inclusão, mostrar mensagem
		case 'FI':
			msgOperacao = 'finalizando inclus&atilde;o';			
			nrposext	= '';
			break;
		case 'FE':
			msgOperacao = 'finalizando exclus&atilde;o';			
			nrposext	= '';
			break;							
		// Qualquer outro valor: Cancelando Operação
		default: 
			msgOperacao = 'abrindo consulta';	
			nrposext 	= '';
			break;
	}

	showMsgAguardo('Aguarde, ' + msgOperacao + '...');
	
	// Executa script de através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/contas/faturamento/principal.php', 
		data: {
			nrdconta: nrdconta,
			idseqttl: idseqttl,
			flgcadas: flgcadas,
			operacao: operacao,
			nrposext: nrposext,
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
	// Definindo as variáveis que serão utilizadas
	var anoftbru, mesftbru, vlrftbru ;
	
	// Primerio oculta a mensagem de aguardo
	hideMsgAguardo();
	var msgOperacao = '';
	switch (operacao) {	
		case 'VA':
			msgOperacao = 'salvando altera&ccedil;&atilde;o'; 
			break;
		case 'VI': 
			msgOperacao = 'salvando inclus&atilde;o'; 
			idseqbem    = '';
			break;
		case 'AV': 
			msgOperacao = 'validando altera&ccedil;&atilde;o'; 
			break;			
		case 'IV': 
			msgOperacao = 'validando inclus&atilde;o'; 
			break;			
		case 'CE': 
			msgOperacao = 'excluindo'; 
			break;				
		default: 
			return false; 
			break;
	}
	
	// Mostra mensagem de aguardo
	showMsgAguardo('Aguarde, ' + msgOperacao + ' ...');
	
	// Somente recebo nas variáveis do formulário quando estivermos Validando/Alterando/Incluindo	
	if ( operacao != 'CE' ) {                                                                       
		
		// Recebendo valores do formulário                                                          
		anoftbru = $('#anoftbru','#frmDadosFaturamento').val();                                     
		mesftbru = $('#mesftbru','#frmDadosFaturamento').val();
		vlrftbru = number_format(parseFloat($('#vlrftbru','#frmDadosFaturamento').val().replace(/[.R$ ]*/g,'').replace(',','.')),2,',','');
	
	} else if ( operacao == 'CE') {
		
		anoftbru = '';
		mesftbru = '';
		vlrftbru = '';
				
	}
	
	//alert('op= '+operacao+' nrposext= '+nrposext+' anoftbru= '+anoftbru+' mesftbru= '+mesftbru+' vlrftbru= '+vlrftbru);
	
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		url: UrlSite + 'telas/contas/faturamento/manter_rotina.php', 		
		data: {			
			nrdconta: nrdconta,
			idseqttl: idseqttl,		
			anoftbru: anoftbru,				      
			mesftbru: mesftbru,             
			vlrftbru: vlrftbru,             
			nrposext: nrposext,
			flgcadas: flgcadas,
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
function controlaLayout( operacao ) {	
	altura  = ( in_array(operacao,['AC','IC','FI','FA','FE','']) ) ? '200px' : '150px';
	largura = '400px';
	divRotina.css('width',largura);	
	$('#divConteudoOpcao').css('height',altura);	
	
	$('label[for="dtaltjfn"]','.divFinanc').addClass('rotulo').css({'width':'60px'});	
	$('label[for="cdoperad"]','.divFinanc').css({'width':'60px'});
	$('#dtaltjfn','.divFinanc').css({'width':'74px'});	
	$('#cdoperad','.divFinanc').css({'width':'58px'});
	$('#nmoperad','.divFinanc').css({'width':'110px'});	
	$('#dtaltjfn,#cdoperad,#nmoperad','.divFinanc').removeClass('campo').addClass('campoTelaSemBorda').prop('disabled',true);
	
	// Operação consultando
	if ( in_array(operacao,['AC','IC','FI','FA','FE','']) ) {		
		
		var divRegistro = $('div.divRegistros');		
		var tabela      = $('table', divRegistro );
		var linha       = $('table > tbody > tr', divRegistro );
		
		divRegistro.css('height','100px');
		
		var ordemInicial = new Array();
		ordemInicial = [[1,1], [0,1]];
		
		var arrayLargura = new Array();
		arrayLargura[0] = '60px';
		arrayLargura[1] = '120px';
		
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'right';
		arrayAlinha[1] = 'center';
		arrayAlinha[2] = 'right';
		
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, 'controlaOperacao(\'CA\');' );
		
	
	// Operação Alterando/Incluindo
	} else {		
	
		var rotulos      = $('label[for="mesftbru"],label[for="anoftbru"],label[for="vlrftbru"]','#frmDadosFaturamento');
		var cTodos       = $('#mesftbru,#anoftbru,#vlrftbru','#frmDadosFaturamento');
		var cMes  	     = $('#mesftbru','#frmDadosFaturamento');
		var cAno	     = $('#anoftbru','#frmDadosFaturamento');
		var cFaturamento = $('#vlrftbru','#frmDadosFaturamento');	

		// Controla largura dos campos 
		rotulos.addClass('rotulo').css({'width':'170px'}); 
		cMes.css({'width':'38px'}).attr('maxlength','2').addClass('inteiro');
		cAno.css({'width':'38px'}).attr('maxlength','4').addClass('inteiro');
		cFaturamento.css({'width':'100px'}).attr('maxlength','14').addClass('moeda');	
		
		// Caso é inclusão, limpar dados do formulário
		if ( operacao == 'CI' ) {
			$('#frmDadosFaturamento').limpaFormulario();
		}
		
		// Adicionando as classes
		cTodos.addClass('campo');	

		cFaturamento.unbind("keydown").bind("keydown",function(e) {
			if (e.keyCode == 13) {
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
	if (in_array(operacao,['AC','IC','FI','FA','FE',''])) {
		$('#btAlterar','#divBotoes').focus();
	} else {
		$('#mesftbru','#frmDadosFaturamento').focus();
	}
	return false;
}

function voltarRotina() {
	fechaRotina(divRotina);
	acessaRotina('FINANCEIRO-RESULTADO','Resultado','resultado');	
}

function proximaRotina () {
	hideMsgAguardo();
	encerraRotina(false);
	acessaRotina('FINANCEIRO-INF.ADICIONAIS','Inf. Adicionais','inf_adicionais');				
}
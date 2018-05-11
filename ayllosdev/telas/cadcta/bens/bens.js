/*!
 * FONTE        : bens.js
 * CRIAÇÃO      : Rodolpho Telmo - DB1 Informatica
 * DATA CRIAÇÃO : 03/03/2010 
 * OBJETIVO     : Biblioteca de funções na rotina Bens da tela de CONTAS
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 001: [26/04/2010] Rodolpho Telmo  (DB1): Retirada função "revisaoCadastral", agora se encontra no arquivo funcoes.js 
 * 002: [05/05/2010] Rodolpho Telmo (DB1) : Adaptação da tela ao "tableSorter"
 * 003: [04/08/2015] Gabriel (RKAM)       : Reformulacao cadastral.
 * 004: [24/08/2015] Jorge Hamaguchi      : Retirada de caracteres especiais em descricao do bem. SD - 320666
   005: [15/10/2015] Kelvin  (CECRED)     : Adicionado validação para remover caracteres especiais SD 320666 (Kelvin).
   006: [25/01/2016] Tiago Castro (RKAM)  : Retirado IF pois nao era carregado as variaveis.
 */	  

var nrdrowid = '';
var idseqbem = '';
var cddopcao = '';
var operacao = '';

// Função para acessar opções da rotina
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
		url: UrlSite + 'telas/cadcta/bens/principal.php',
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
			showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
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

/*!
 * OBJETIVO : Função de controle das ações/operações da Rotina de Bens da tela de CONTAS
 * PARÂMETRO: Operação que deseja-se realizar
 */
function controlaOperacao(operacao) {
	// Se não possui acesso para alterar, emitir mensagem	
	if ( (operacao == 'CA') && (flgAlterar != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de altera&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina);'); return false;}
	if ( (operacao == 'CI') && (flgIncluir != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de inclus&atilde;o.' ,'Alerta - Ayllos','bloqueiaFundo(divRotina);'); return false; }
	if ( (operacao == 'CX') && (flgExcluir != '1') ) { showError('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de exclus&atilde;o.' ,'Alerta - Ayllos','bloqueiaFundo(divRotina);'); return false; }

	if ( in_array(operacao,['CA','CX','CF']) ) {
		nrdrowid = '';	idseqbem = '';
		$('table > tbody > tr', 'div.divRegistrosBens').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				nrdrowid = $('#nrdrowid', $(this) ).val();
				idseqbem = $('#idseqbem', $(this) ).val();
			}
		});
		if ( nrdrowid == '' && idseqbem == ''  ) { return false; }
	}
	
	// Mostra mensagem de aguardo
	var msgOperacao = '';
	switch (operacao) {
		// Consulta para Alteração
		case 'CA': 
			msgOperacao = 'abrindo altera&ccedil;&atilde;o';
			cddopcao 	= 'A';
			break;
		case 'CF': 
			msgOperacao = 'abrindo consulta';
			cddopcao 	= 'C';
			break;			
		// Alteração para Consulta
		case 'AC': 
			showConfirmacao('Deseja cancelar altera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','controlaOperacao(\'\')','bloqueiaFundo(divRotina)','sim.gif','nao.gif');
			return false;
			break;				
		// Consulta para Inclusão
		case 'CI': 
			msgOperacao = 'abrindo inclus&atilde;o';
			cddopcao 	= 'I';
			nrdrowid    = '';
			idseqbem    = '';
			break;							
		// Inclusão para Consulta
		case 'IC': 
			showConfirmacao('Deseja cancelar inclus&atilde;o?'        ,'Confirma&ccedil;&atilde;o - Ayllos','controlaOperacao(\'\')','bloqueiaFundo(divRotina)','sim.gif','nao.gif');
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
		case 'CX': 
			msgOperacao = 'abrindo exclus&atilde;o';
			cddopcao 	= 'E';
			break;
		case 'CE':
			//hideMsgAguardo();
			showConfirmacao('Deseja confirmar exclus&atilde;o do bem?','Confirma&ccedil;&atilde;o - Ayllos','manterRotina(\''+operacao+'\')','controlaOperacao(\'\')','sim.gif','nao.gif');
			return false;
			break;	
		// Finalizou Alteração, mostrar mensagem
		case 'FA':
			msgOperacao = 'finalizando altera&ccedil;&atilde;o';
			nrdrowid	= '';
			idseqbem	= '';
			cddopcao 	= 'C';
			break;	
		// Finalizou Inclusão, mostrar mensagem
		case 'FI':
			msgOperacao = 'finalizando inclus&atilde;o';			
			nrdrowid	= '';
			idseqbem	= '';
			cddopcao 	= 'C';
			break;
		// Finalizou Exclusão, mostrar mensagem
		case 'FE':
			msgOperacao = 'finalizando exclus&atilde;o';			
			nrdrowid	= '';
			idseqbem	= '';
			cddopcao 	= 'C';
			break;							
		// Qualquer outro valor: Cancelando Operação
		default: 
			msgOperacao = 'abrindo consulta';	
			nrdrowid 	= '';
			idseqbem 	= '';
			cddopcao 	= 'C';
			break;
	}

	showMsgAguardo('Aguarde, ' + msgOperacao + '...');
	
	// Executa script de através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadcta/bens/principal.php', 
		data: {
			nrdconta: nrdconta,	
			idseqttl: idseqttl,
			inpessoa: inpessoa,
			operacao: operacao,
			nrdrowid: nrdrowid,
			idseqbem: idseqbem,	
			cddopcao: cddopcao,
			flgcadas: flgcadas, 
			redirect: 'script_ajax'
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
				controlaFoco( operacao );
			}
			return false;		
		}				
	});			
}

/*!
 * OBJETIVO : Função manterRotina tem o sentido de: Alterar/Incluir/Excluir
 *            Primeiro ela realiza a validação dos dados e depois realiza a devida operação
 */
function manterRotina(operacao) {
	// Definindo as variáveis que serão utilizadas
	var dsrelbem, persemon, qtprebem, vlprebem, vlrdobem;
	
	// Primerio oculta a mensagem de aguardo
	hideMsgAguardo();
	var msgOperacao = '';
	switch (operacao) {	
		case 'VA':
			msgOperacao = 'salvando altera&ccedil;&atilde;o'; 
			break;
		case 'VI': 
			msgOperacao = 'salvando inclus&atilde;o'; 
			nrdrowid    = '';
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
	showMsgAguardo('Aguarde, ' + msgOperacao + '...');
	
	// Somente recebo nas variáveis do formulário quando estivermos Validando/Alterando/Incluindo
	//if ( operacao != 'CE' ) {
		// Recebendo valores do formulário 
		
		// alteracao 004
		$('#dsrelbem','#frmDadosBens').val(retiraCaracteres($('#dsrelbem','#frmDadosBens').val(),"'|\\;",false));
		
		dsrelbem = trim($('#dsrelbem','#frmDadosBens').val());
		persemon = $('#persemon','#frmDadosBens').val();
		qtprebem = $('#qtprebem','#frmDadosBens').val();
		vlprebem = number_format(parseFloat($('#vlprebem','#frmDadosBens').val().replace(/[.R$ ]*/g,'').replace(',','.')),2,',','.');
		vlrdobem = number_format(parseFloat($('#vlrdobem','#frmDadosBens').val().replace(/[.R$ ]*/g,'').replace(',','.')),2,',','.');
	//}
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		url: UrlSite + 'telas/cadcta/bens/manter_rotina.php', 		
		data: {
			nrdconta: nrdconta, idseqttl: idseqttl,	dsrelbem: removeAcentos(removeCaracteresInvalidos(dsrelbem)).replace("<","").replace(">",""),
			persemon: persemon,	qtprebem: qtprebem,	vlprebem: vlprebem,
			vlrdobem: vlrdobem, nrdrowid: nrdrowid,	idseqbem: idseqbem,
			operacao: operacao,	flgcadas: flgcadas, redirect: 'script_ajax'
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
			}
		}				
	});
}

/*!
 * OBJETIVO : Controlar o layout da tela de acordo com a operação
 *            Algumas formatações CSS que não funcionam, são contornadas por esta função
 * PARÂMETRO: Valores válidos: [C] Consultando [A] Alterando [I] Incluindo
 */
function controlaLayout( operacao ) {	

	altura  = ( in_array(operacao,['AC','IC','FI','FA','FE','SC','']) ) ? '215px' : '165px';
	largura = ( in_array(operacao,['AC','IC','FI','FA','FE','SC','']) ) ? '535px' : '447px';	
	divRotina.css({'width':largura});
	$('#divConteudoOpcao').css({'height':altura});	

	// Operação consultando
	if ( in_array(operacao,['AC','IC','FI','FA','FE','SC','']) ) {	
	
		var divRegistro = $('div.divRegistrosBens');		
		var tabela      = $('table', divRegistro );
	
		divRegistro.css('height','150px');
		
		var ordemInicial = new Array();
		ordemInicial = [[0,0]];
		
		var arrayLargura = new Array();
		arrayLargura[0] = '195px';
		arrayLargura[1] = '60px';
		arrayLargura[2] = '40px';
		arrayLargura[3] = '65px';
		
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'left';
		arrayAlinha[1] = 'right';
		arrayAlinha[2] = 'right';
		arrayAlinha[3] = 'right';
		arrayAlinha[4] = 'right';
		
		if ( operacao != 'SC' ){
			tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, 'controlaOperacao(\'CA\')' );
		}else{
			tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, 'controlaOperacao(\'CF\')' );
		}
	
	// Operação Alterando/Incluindo
	} else {	

		var persemon, qtprebem, vlrdobem;
	
		var cTodos      = $('#dsrelbem,#persemon,#qtprebem,#vlprebem,#vlrdobem','#frmDadosBens');
		var cDescricao  = $('#dsrelbem','#frmDadosBens');
		var cPercentual = $('#persemon','#frmDadosBens');
		var cQtParcela  = $('#qtprebem','#frmDadosBens');
		var cVlParcela  = $('#vlprebem','#frmDadosBens');
		var cVlBem      = $('#vlrdobem','#frmDadosBens');
		
		// Controla largura dos campos
		$('label','#frmDadosBens').css({'width':'135px'}).addClass('rotulo');
		cDescricao.css({'width':'277px'});
		cPercentual.css({'width':'50px'});
		cQtParcela.css({'width':'50px'});
		cVlParcela.css({'width':'135px','text-align':'right'}).attr('alt','p6p3c2D').autoNumeric().trigger('blur');
		cVlBem.css({'width':'135px'});
		
		
		if ( operacao == 'CF' ) {
			cTodos.desabilitaCampo();
		}else{
		
			// Caso é inclusão, limpar dados do formulário
			if ( operacao == 'CI' ) {
				$('#frmDadosBens').limpaFormulario();
			}
			
			// Adicionando as classes
			cTodos.addClass('campo').removeClass('campoErro');
			
			
			// Se percentual sem ônus = 100, tava campos "qtprebem" e "vlprebem"
			persemon = parseFloat( cPercentual.val().replace(',','.') );

			if ( persemon == 100 ) {
				cQtParcela.unbind().removeClass('campo').addClass('campoTelaSemBorda').prop('disabled',true).attr('tabindex','-1').val('0');
				cVlParcela.unbind().removeClass('campo').addClass('campoTelaSemBorda').prop('disabled',true).attr('tabindex','-1').val('0,00');
				
			} 
			
			// Valida Percentual sem Ônus
			cPercentual.change(function () {			
				persemon = parseFloat( cPercentual.val().replace(',','.') );
				
				// Se maior do que 100, mostra mensagem de erro e retorna o foco no mesmo campo
				if ( persemon > 100 ) {
					showError('error','Valor Percentual sem &ocirc;nus deve ser menor ou igual a 100,00.','Alerta - Ayllos','bloqueiaFundo($("#divRotina"),\'persemon\',\'frmDadosBens\')');
				} else {
					cPercentual.removeClass('campoErro');
					if ( persemon == 100 ) {
						cQtParcela.unbind().removeClass('campo').addClass('campoTelaSemBorda').prop('disabled',true).attr('tabindex','-1').val(0);
						cVlParcela.unbind().removeClass('campo').addClass('campoTelaSemBorda').prop('disabled',true).attr('tabindex','-1').val(0,00);
						layoutPadrao();
						cVlBem.focus();
						return false;	  
					} else {						
						cQtParcela.removeClass('campoTelaSemBorda').addClass('campo').removeProp('disabled').removeAttr('tabindex');
						cVlParcela.removeClass('campoTelaSemBorda').addClass('campo').removeProp('disabled').removeAttr('tabindex');
						cVlParcela.attr('alt','p6p3c2D').autoNumeric().trigger('blur');
						cQtParcela.focus();				
					}
				}
			});	
			
			cVlBem.unbind("keydown").bind("keydown",function(e) {
				if (e.keyCode == 13) {
					$("#btSalvar","#divBotoes").trigger("click");
					return false;
				}	
			});	
	   }
    }
	layoutPadrao();
	hideMsgAguardo();
	bloqueiaFundo(divRotina);
	removeOpacidade('divConteudoOpcao');
	highlightObjFocus($('#frmDadosBens'));
	controlaFocoEnter("frmDadosBens");
	controlaFoco(operacao);	
	divRotina.centralizaRotinaH();		
	return false;	
}

function validaBens(operacao){
	
	var dsrelbem, persemon, qtprebem, vlprebem, vlrdobem;	
	
	var cTodos      = $('#dsrelbem,#persemon,#qtprebem,#vlprebem,#vlrdobem','#frmDadosBens');
	var cDescricao  = $('#dsrelbem','#frmDadosBens');
	var cPercentual = $('#persemon','#frmDadosBens');
	var cQtParcela  = $('#qtprebem','#frmDadosBens');
	var cVlParcela  = $('#vlprebem','#frmDadosBens');
	var cVlBem      = $('#vlrdobem','#frmDadosBens');	

	cTodos.removeClass('campoErro');
	
	// alteracao 004
	cDescricao.val(retiraCaracteres(cDescricao.val(),"'|\\;",false));
	
	// Recebe todos os valores em variáveis
	dsrelbem = trim( cDescricao.val() );
	persemon = cPercentual.val().replace(',','.');
	qtprebem = parseFloat( cQtParcela.val().replace(',','.').replace('','0') );
	vlprebem = parseFloat( cVlParcela.val().replace(',','.').replace('R$ ','').replace('','0') );
	vlrdobem = parseFloat( cVlBem.val().replace(',','.').replace('R$ ','').replace('','0') );
	
	// Descrição do bem não pode ser vazia
	if ( dsrelbem == '' ) { showError('error','Descri&ccedil;&atilde;o do bem deve se preenchido.','Alerta - Ayllos','bloqueiaFundo($("#divRotina"),\'dsrelbem\',\'frmDadosBens\')');return false; } 
	
	// Não aceita percentual sem ônus maior do que 100%	
	if ( persemon > 100 ) {	showError('error','Percentual sem &ocirc;nus deve ser menor ou igual a 100,00.','Alerta - Ayllos','bloqueiaFundo($("#divRotina"),\'persemon\',\'frmDadosBens\')');return false; }
	
	// Se percentual sem ônus for 100%, então qtde. e valor das parcelas deve ser zero
	if ( ( persemon == 100 ) && ( qtprebem > 0 ) ) { showError('error','Parcelas a pagar deve ser zero.','Alerta - Ayllos','bloqueiaFundo($("#divRotina"),\'qtprebem\',\'frmDadosBens\')');return false; }
	if ( ( persemon == 100 ) && ( vlprebem > 0 ) ) { showError('error','Valor da parcela deve ser zero.','Alerta - Ayllos','bloqueiaFundo($("#divRotina"),\'vlprebem\',\'frmDadosBens\')');return false; }

	// Se percentual sem ônus for menor do que 100%, então qtde. e valor das parcelas devem ser maiores do que zero
	if ( ( persemon < 100 ) && ( qtprebem == 0 ) ) { showError('error','Parcelas a pagar deve ser maior que zero.','Alerta - Ayllos','bloqueiaFundo($("#divRotina"),\'qtprebem\',\'frmDadosBens\')');return false; }
	if ( ( persemon < 100 ) && ( vlprebem == 0 ) ) { showError('error','Valor da parcela deve ser maior que zero.','Alerta - Ayllos','bloqueiaFundo($("#divRotina"),\'vlprebem\',\'frmDadosBens\')');return false; }
	
	// Valida valor do bem
	if( vlrdobem <= 0 ) {showError('error','Valor do Bem deve ser maior que zero.','Alerta - Ayllos','bloqueiaFundo($("#divRotina"),\'vlrdobem\',\'frmDadosBens\')');return false; }
	
	controlaOperacao(operacao);
	return false;
}

function controlaFoco(operacao) {
	if (in_array(operacao,['AC','IC','FI','FA','FE',''])) {
		$('#btAlterar','#divBotoes').focus();
	} else {
		$('.campo:first','#frmDadosBens').focus();
	}
	return false;
}

function voltarRotina() {
	if (inpessoa == 1) {
		 acessaOpcaoAbaDados(2,0,'@');
	} else {
		fechaRotina(divRotina);
		acessaRotina('PROCURADORES','Representante/Procurador','procuradores');
	}
}

function proximaRotina () {
		
	hideMsgAguardo();
	encerraRotina(false);
	
	if (inpessoa == 1) {
		acessaRotina('CONTA CORRENTE','Conta Corrente','conta_corrente_pf');	
	}else {
		acessaRotina('TELEFONES','Telefones','telefones');	
	}	
}
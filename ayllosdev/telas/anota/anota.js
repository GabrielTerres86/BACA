/*!
 * FONTE        : anota.js
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 14/02/2011
 * OBJETIVO     : Biblioteca de funções da tela ANOTA
 * --------------
 * ALTERAÇÕES   : 
 * 000: [25/06/2012] Jorge Hamaguchi  (CECRED): Alterado funcao Gera_Impressao(), adequado para submeter para impressao
 * 001: [19/10/2016] Kelvin			  (CECRED): Permitir incluir acentuacao, porem removendo caracteres que afetam o xml,
												conforme solicitado no chamado 517202. (Kelvin)
 * --------------
 */

// Definição de algumas variáveis globais 
var operacao 		= ''; // Armazena a operação corrente da tela ANOTA
var nrdconta 		= 0; // Armazena o Número da Conta/dv
var nrseqdig		= 0; // Armazena a chave do registro
var nrdcontaOld 	= ''; // Variável auxiliar para guardar o número da conta passada
var operacaoOld		= ''; // Variável auxiliar para guardar a operação passada
var nrJanelas 		= 0; // Armazena o número de janelas para as impressões

//Variaveis que armazenam informações do parcelamento
var qtparcel = '';
var vlparcel = '';
var msgRetor = '';


$(document).ready(function() {
	controlaOperacao();	
});

function controlaOperacao( novaOp ) {
			
	operacao = ( typeof novaOp != 'undefined' ) ? novaOp : operacao;
	
	if (in_array(operacao,['TC','TA','EV','IM'])){
		nrseqdig = '';
		$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				nrseqdig = $('input', $(this) ).val();
			}
		});	
		if ( nrseqdig == ''  ) { return false; }
	}
				
	var mensagem = '';
	switch (operacao) {
		case 'FC': nrseqdig	= 0; mensagem = 'Aguarde, buscando dados ...'; break;		
		case 'TC': mensagem = 'Aguarde, abrindo vizualiza&ccedil;&atilde;o ...'; break;		
		case 'FA': nrseqdig	= 0; mensagem = 'Aguarde, verificando conta/dv ...'; break;		
		case 'TA': mensagem = 'Aguarde, verificando conta/dv ...'; break;		
		case 'FE': nrseqdig	= 0;mensagem = 'Aguarde, verificando conta/dv ...'; break;
		case 'FI': nrseqdig	= 0; mensagem = 'Aguarde, verificando conta/dv ...'; break;
		case 'TI': nrseqdig	= 0; mensagem = 'Aguarde, verificando conta/dv ...'; break;
		case 'IM': Gera_Impressao(); return false; break;
						
		case 'IF': showConfirmacao('Deseja cancelar inclus&atilde;o?'	,'Confirma&ccedil;&atilde;o - Anota','controlaOperacao("FI");','','sim.gif','nao.gif'); return false; break;
		case 'AT': showConfirmacao('Deseja cancelar altera&ccedil;&atilde;o?'	,'Confirma&ccedil;&atilde;o - Anota','controlaOperacao("FA");','','sim.gif','nao.gif'); return false; break;
		case 'ET': showConfirmacao('Deseja cancelar exclus&atilde;o?'	,'Confirma&ccedil;&atilde;o - Anota','controlaOperacao("FE");','','sim.gif','nao.gif'); return false; break;
				
		case 'EV': manterRotina(); return false; break;
		case 'IV': manterRotina(); return false; break;
		case 'AV': manterRotina(); return false; break;
				
		case 'VE': manterRotina(); return false; break;		
		case 'VA': manterRotina(); return false; break;
		case 'VI': manterRotina(); return false; break;
				
		case 'VR': verificaRelatorio(); return false; break;
		
		default  : 
			nrseqdig = 0;
			mensagem = 'Aguarde, abrindo tela ...'; 
			break;
	}
	showMsgAguardo( mensagem );	
			
	// Carrega dados da conta através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/anota/principal.php', 
		data    : 
				{ 
					nmdatela: 'ANOTA',
					nmrotina: '',
					nrdconta: nrdconta,	
					operacao: operacao,
					nrseqdig: nrseqdig,
					redirect: 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Anota','$(\'#nrdconta\',\'#frmCabAnota\').focus()');
				},
		success : function(response) { 
					hideMsgAguardo();
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							$('#divAnota').html(response);
							return false;
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
						}
					} else {
						try {
							eval( response );
							controlaFoco();
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
						}
					}
				}
	}); 
}

function manterRotina() {
		
	hideMsgAguardo();		
	var mensagem = '';
	switch (operacao) {	
		case 'VI': mensagem = 'Aguarde, incluindo ...'; break;                                                              
		case 'VA': mensagem = 'Aguarde, alterando ...'; break;
		case 'VE': mensagem = 'Aguarde, excluindo ...'; break;
		case 'IV': mensagem = 'Aguarde, validando inclus&atilde;o ...'; break;
		case 'AV': mensagem = 'Aguarde, validando altera&ccedil;&atilde;o ...'; break;
		case 'EV': mensagem = 'Aguarde, validando exclus&atilde;o ...'; break;
		default: return false; break;
	}
	
	showMsgAguardo( mensagem );	
					 
	var dsobserv = '';
	var flgprior = '';

	if ( operacao != 'EV' && operacao != 'VE' ){
		
		dsobserv = removeCaracteresInvalidos($('#dsobserv','#frmAnota').val());
		flgprior = $('input[name="flgprior"]:checked','#frmAnota').val();
				
	}
				
	$.ajax({		
			type  : 'POST',
			async : true ,
			url   : UrlSite + 'telas/anota/manter_rotina.php', 		
			data: {
				nrdconta: nrdconta,	
				nrseqdig: nrseqdig,
				dsobserv: dsobserv, 
				flgprior: flgprior,
				operacao: operacao,
				redirect: 'script_ajax'
			}, 
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
			},
			success: function(response) {
				try {
					eval(response);
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		});

	return false;	
	                     
}       	

function controlaLayout() {

	$('#divAnota').fadeTo(0,0.1);
				
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'0px 3px 5px 3px'});
	
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	
	$('#divBotoes').css({'text-align':'center','padding-top':'5px'});
	
	if (in_array(operacao,['','FC','FA','FE','FI'])){
	
		var divRegistro = $('div.divRegistros');		
		var tabela      = $('table', divRegistro );
		var linha       = $('table > tbody > tr', divRegistro );
		
		divRegistro.css({'height':'150px','border-bottom':'1px solid #777','padding-bottom':'2px'});
		
		var ordemInicial = new Array();
		ordemInicial = [[2,1], [3,1]];
				
		var arrayLargura = new Array();
		arrayLargura[0] = '115px';
		arrayLargura[1] = '50px';
		arrayLargura[2] = '60px';
		arrayLargura[3] = '47px';
			
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'left';
		arrayAlinha[1] = 'center';
		arrayAlinha[2] = 'center';
		arrayAlinha[3] = 'center';
		arrayAlinha[4] = 'left';
		
		var metodoTabela = '';
			
		switch (operacao) {
			case 'FC': metodoTabela = 'controlaOperacao(\'TC\')';	break;
			case 'FA': metodoTabela = 'controlaOperacao(\'TA\')';	break;
			case 'FE': metodoTabela = 'controlaOperacao(\'EV\')';	break;
			default	 : metodoTabela = '';	break;
		}
		
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );		
		
		if (operacao == '' ){
			$('#tabConteudo').css('display','none');
			$('#nrdconta','#frmCabAnota').val(nrdcontaOld);
			$('#opcao','#frmCabAnota').val( operacaoOld );
		}else{
			$('#tabConteudo').css('display','block');
		}
	
	}else if ( operacao == 'TC' ){
	
		var cTodos   = $('input','#frmVisualiza');
		
		var cConta   = $('#nrdconta','#frmVisualiza');
		var cTitular = $('#nmprimtl','#frmVisualiza');
		var cData    = $('#dtmvtolt','#frmVisualiza');
		var cHora    = $('#hrtransc','#frmVisualiza');
		var cCodOper = $('#cdoperad','#frmVisualiza');
		var cOperad  = $('#nmoperad','#frmVisualiza');
		var cTexto   = $('#dsobserv','#frmVisualiza');
		
		var rConta   = $('label[for="nrdconta"]','#frmVisualiza');
		var rTitular = $('label[for="nmprimtl"]','#frmVisualiza');
		var rData    = $('label[for="dtmvtolt"]','#frmVisualiza');
		var rHora    = $('label[for="hrtransc"]','#frmVisualiza');
		var rOperad  = $('label[for="nmoperad"]','#frmVisualiza');
		var rFlgPri  = $('#flgprior','#frmVisualiza');
		
		rConta.addClass('rotulo').css('width','96px');
		rTitular.css('width','42px');
		rData.addClass('rotulo').css('width','96px');
		rHora.css('width','42px');
		rOperad.css('width','28px');
		rFlgPri.addClass('rotulo').css('width','215px');;
		
		cConta.addClass('conta').css('width','66px');
		cTitular.addClass('alphanum').css('width','268px');
		cData.addClass('data').css('width','66px');
		cHora.addClass('').css('width','53px');
		cCodOper.addClass('codigo').css('width','30px');
		cOperad.addClass('descricao').css('width','150px');
		
		cTexto.css({'width':'418px','height':'98px','float':'left','margin':'3px 0px 3px 60px','padding-right':'1px'});
		cTexto.desabilitaCampo();
		cTodos.desabilitaCampo();
	
	}else{
		var cTexto  = $('#dsobserv','#frmAnota');
		var rFlgPri = $('label[for="flgprior"]','#frmAnota');						
		
		cTexto.css({'width':'510px','height':'136px','float':'left','margin':'3px 0px 3px 13px','padding-right':'1px'});
		
		rFlgPri.addClass('rotulo').css('width','86px');
		cTexto.habilitaCampo();
		
		if (operacao == 'TI'){
			$('#frmAnota').limpaFormulario();
		}
		
	}
	
	layoutPadrao();
		
	$('.conta').trigger('blur');
	
	controlaPesquisas();
	
	removeOpacidade('divAnota');

	return false;
	
}

// Função para carregar impresso desejado em PDF (Proposta, Contrato ou Rescisão do Limite de Crédito)
function Gera_Impressao() {	
	
	// Eliminar 
	$('#nrdconta','#frmCabAnota').remove();		
	$('#nrseqdig','#frmCabAnota').remove();		
	$('#sidlogin','#frmCabAnota').remove();
	
	// Insiro input do tipo hidden do formulário para enviá-los posteriormente
	$('#frmCabAnota').append('<input type="hidden" id="nrdconta" name="nrdconta" />');
	$('#frmCabAnota').append('<input type="hidden" id="nrseqdig" name="nrseqdig" />');
	$('#frmCabAnota').append('<input type="hidden" id="sidlogin" name="sidlogin" />');
	
	// Agora insiro os devidos valores nos inputs criados
	$('#nrdconta','#frmCabAnota').val( nrdconta );		
	$('#nrseqdig','#frmCabAnota').val( nrseqdig );		
	$('#sidlogin','#frmCabAnota').val( $('#sidlogin','#frmMenu').val() );	
	
	var action = UrlSite + 'telas/anota/imprimir_dados.php';
	
	carregaImpressaoAyllos("frmCabAnota",action);
	
}

function formataCabecalho() {
	
	var nomeForm    = 'frmCabAnota';
	
	var rLinha    = $('label[for="nrdconta"],label[for="nmprimtl"]','#'+nomeForm);	
	var rOpcao    = $('label[for="opcao"]','#'+nomeForm);	
	var cTodos	  = $('input[type="text"],select','#'+nomeForm);
	var cOpcao    = $('#opcao','#'+nomeForm);
	var cNrConta  = $('#nrdconta','#'+nomeForm);
    var cNome	  = $('#nmprimtl','#'+nomeForm);
		
	rLinha.addClass('rotulo-linha');
	rOpcao.css('width','46px');
	cTodos.desabilitaCampo();
	cOpcao.css('width','34px');
	cNrConta.addClass('conta pesquisa').css('width','66px');
	cNome.addClass('descricao').css('width','298px');
			
	if ( $.browser.msie ) {
		cNrConta.css('width','65px');
	}	

	if ( operacao == '' ) {	
		
		cNrConta.habilitaCampo();
		cOpcao.habilitaCampo();

		// Se eu mudar a opção, muda a variável global operacao
		cOpcao.unbind('change').bind('change', function() { 
			operacao = $(this).val();
			operacaoOld = operacao;
		});
		
		// Se pressionar alguma tecla no campo numero da conta, verificar a tecla pressionada e toda a devida ação
		cNrConta.unbind('keypress').bind('keypress', function(e) { 	
		
			if ( divError.css('display') == 'block' ) { return false; }		
			
			// Se é a tecla ENTER, verificar numero conta e realizar as devidas operações
			if ( e.keyCode == 13 ) {		
				// Armazena o número da conta na variável global
				nrdconta = normalizaNumero( $(this).val() );
				nrdcontaOld = nrdconta;
												
				// Verifica se o número da conta é vazio
				if ( nrdconta == '' ) { return false; }
					
				// Verifica se a conta é válida
				if ( !validaNroConta(nrdconta) ) { 
					showError('error','Conta/dv inv&aacute;lida.','Alerta - Anota','focaCampoErro(\'nrdconta\',\'frmCabAnota\');'); 
					return false; 
				}
				
				// Se chegou até aqui, a conta é diferente do vazio e é válida, então realizar a operação desejada
				controlaOperacao( $('#opcao','#'+nomeForm).val() );
				return false;
			// Se é a tecla TAB, focar o campo opcao
			} else if ( e.keyCode == 9 ) { 
				cOpcao.focus(); 
				return false; 
			}
		});		
		
	} else {	
		// Selecionar a opção (operação) correta
		$('#opcao option:selected','#frmCabAnota').val();
		if ( operacao == 'TA'){
			$('#opcao','#frmCabAnota').val('FA');
		}else if ( operacao == 'FI'){
			$('#opcao','#frmCabAnota').val('TI');
		}else{
			$('#opcao','#frmCabAnota').val(operacao);
		}
	
		cNrConta.desabilitaCampo();
		cOpcao.desabilitaCampo();
	}
			
	return false;	
}

function controlaFoco() {
			
	if ( operacao == '' ) {
		$('#nrdconta','#frmCabAnota').focus().focus();	
		
	} else if (operacao == 'FC') {
		$('#btConsultar','#divBotoes').focus();
		
	} else if (operacao == 'TC') {
		$('#btVoltar','#divBotoes').focus();
		
	} else if (operacao == 'FA') {
		$('#btAlterar','#divBotoes').focus();	
		
	} else if (operacao == 'TI') {
		$('#flgpryes','#frmAnota').focus();

	} else if (operacao == 'FE') {
		$('#btExcluir','#divBotoes').focus();

	} else if (operacao == 'TA') {
		$('#flgpryes','#frmAnota').focus();
		
	} else if (operacao == 'FI') {
		$('#btIncluir','#divBotoes').focus();
	}
	
	return false;
}

function controlaPesquisas() {
			
	/*---------------------*/
	/*  CONTROLE CONTA/DV  */
	/*---------------------*/
	var linkConta = $('a:eq(0)','#frmCabAnota');
		
	if ( linkConta.prev().hasClass('campoTelaSemBorda') ) {		
		linkConta.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {
		linkConta.css('cursor','pointer').unbind('click').bind('click', function() {			
			mostraPesquisaAssociado('nrdconta','frmCabAnota');
		});
	}
	
}

function consultaInicial() { 	
		
	if ( divError.css('display') == 'block' ) { return false; }
	if( $('#nrdconta','#frmCabAnota').hasClass('campoTelaSemBorda') ){ return false; }
				
	// Armazena o número da conta na variável global
	nrdconta = normalizaNumero( $('#nrdconta','#frmCabAnota').val() );
	nrdcontaOld = nrdconta;

	// Verifica se o número da conta é vazio
	if ( nrdconta == '' ) { return false; }
		
	// Verifica se a conta é válida
	if ( !validaNroConta(nrdconta) ) { 
		showError('error','Conta/dv inválida.','Alerta - Anota','focaCampoErro(\'nrdconta\',\'frmCabAnota\');'); 
		return false; 
	}
	
	// Se chegou até aqui, a conta é diferente do vazio e é válida, então realizar a operação desejada
	controlaOperacao( $('#opcao','#frmCabAnota').val() );
	
};	

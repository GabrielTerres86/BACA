/*!
 * FONTE        : mantal.js
 * CRIAÇÃO      : Rogerius Militão (DB1) 
 * DATA CRIAÇÃO : 21/06/2011
 * OBJETIVO     : Biblioteca de funções da tela MANTAL
 * --------------
 * ALTERAÇÕES   :
 * 000: [02/07/2012] Jorge Hamaguchi  (CECRED): Alterado funcao Gera_Impressao(), novo esquema de impressao.
 * 001: [06/06/2016] Lucas Ranghetti  (CECRED): Incluir validação para o campo cAgencia e validar agencia ( #462172)
 * 002: [23/01/2017] Tiago Machado    (CECRED): Validar se deve alterar agencia para o banco 756 tambem (#549323)
 * 003: [04/11/2017] Jonata           (RKAM)  : 04/11/2017 - Ajuste para tela ser chamada atraves da tela CONTAS > IMPEDIMENTOS (P364)
                               
 * --------------
 */

// Definição de algumas variáveis globais 
var operacao 		= ''; // Armazena a operação corrente da tela MANTAL
var controle		= '';	

var cddopcao		= '';

var aux_cdagechq	= '';
var aux_nriniche	= '';
var aux_nrfimche	= '';
var aux_altagchq    = 0; // Armazena se deve alerar campo agencia (Contas migradas)

var cheque  		= ''; // Armazena os cheques em custodia/desconto retornado do Valida-Dados

var imp_cheques		= ''; // Armazena os cheques retornado do Grava-Dados
var imp_criticas	= ''; // Armazena as criticas retornado do Grava-Dados
var nrJanelas 		= 0;  // Armazena o número de janelas para as impressões

var arrayMantal		= '';

//Formulários
var formCab   		= 'frmCab';
var formDados 		= 'frmMantal';

//Labels/Campos do cabeçalho
var rOpcao, rConta, rNome, cTodos, cOpcao, cConta, cNome ;

//Labels/Campos do formulário de dados
var rBanco, rAgencia, rContraCheque,
    rNrChequeIni, rNrChequeFim, cBanco, 
	cAgencia, cContraCheque, cNrChequeIni, cNrChequeFim;


$(document).ready(function() {
	estadoInicial();
});


// seletores
function estadoInicial() {
	$('#divTela').fadeTo(0,0.1);

	setGlobais();	
	
	$('input', '#'+ formCab ).limpaFormulario();
	$('input', '#'+ formDados ).limpaFormulario();
	$('#divTabMantal').css({'display':'none'});
	
	atualizaSeletor();
	controlaLayout();
	formataCabecalho();
	

	$('input, select','#'+ formCab ).removeClass('campoErro');
	$('input, select','#'+ formDados ).removeClass('campoErro');
	
	cBanco.attr('aux','');
	cConta.focus();
	removeOpacidade('divTela');
	return false;
}

function atualizaSeletor(){

	rOpcao = $('label[for="cddopcao"]','#'+formCab);
	rConta = $('label[for="nrdconta"]','#'+formCab);
	rNome  = $('label[for="nmprimtl"]','#'+formCab);
	
	cTodos = $('input[type="text"],select','#'+formCab);
	cOpcao = $('#cddopcao','#'+formCab);
	cConta = $('#nrdconta','#'+formCab);
	cNome  = $('#nmprimtl','#'+formCab);
	
	rBanco        = $('label[for="cdbanchq"]','#'+formDados);
	rAgencia      = $('label[for="cdagechq"]','#'+formDados);
	rContraCheque = $('label[for="nrctachq"]','#'+formDados);
	rNrChequeIni  = $('label[for="nrinichq"]','#'+formDados);
	rNrChequeFim  = $('label[for="nrfimchq"]','#'+formDados);
	
	cTodos_1      = $('input[type="text"],select','#'+formDados);
	cBanco        = $('#cdbanchq','#'+formDados);
	cAgencia      = $('#cdagechq','#'+formDados);
	cContraCheque = $('#nrctachq','#'+formDados);
	cNrChequeIni  = $('#nrinichq','#'+formDados);
	cNrChequeFim  = $('#nrfimchq','#'+formDados);

	return false;
}


// controle
function controlaOperacao( novaOp ) {
				
	operacao = ( typeof novaOp != 'undefined' ) ? novaOp : operacao;
	
	var mensagem = 'Aguarde, buscando dados ...';
	
	showMsgAguardo( mensagem );	
	
	// Carrega dados da conta através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/mantal/principal.php', 
		data    : 
				{ 
					cddopcao	: cddopcao,					
					nrdconta	: nrdconta, 
					redirect	: 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) {
					hideMsgAguardo();
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							$('#divFiltro').html(response);
							return false;
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
						}
					} else {
						try {
							eval( response );
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
						}
					}
				}
	});

	return false;	
}

function manterRotina() {
		
	hideMsgAguardo();		

	var mensagem = '';
	
	// Banco
	var cdbanchq = normalizaNumero( cBanco.val() 		);
	var cdagechq = normalizaNumero( cAgencia.val() 		);
	var nrctachq = normalizaNumero( cContraCheque.val() );
	var nrinichq = normalizaNumero( cNrChequeIni.val() 	);
	var nrfimchq = normalizaNumero( cNrChequeFim.val() 	);
	
	switch (operacao) {
		case 'B1': mensagem = 'Aguarde, buscando...'; break;
		case 'D1': mensagem = 'Aguarde, buscando...'; break;

		case 'B2': mensagem = 'Aguarde, validando...'; break;
		case 'D2': mensagem = 'Aguarde, validando...'; break;

		case 'B3': mensagem = 'Aguarde, gravando...'; break;
		case 'D3': mensagem = 'Aguarde, gravando...'; break;
		
		default: return false; break;
	}
	
	showMsgAguardo( mensagem );	
	$('input, select','#'+ formDados ).removeClass('campoErro');
	
	$.ajax({		
			type  : 'POST',
			async : false ,
			url   : UrlSite + 'telas/mantal/manter_rotina.php', 		
			data: {
				// Controle
				operacao	: operacao,
				
				// Cabecalho
				cddopcao	: cddopcao,
				nrdconta	: nrdconta,
				
				// Banco
				cdbanchq	: cdbanchq,
				cdagechq	: cdagechq,
				nrctachq	: nrctachq,
				nrinichq	: nrinichq,
				nrfimchq	: nrfimchq,
				
				//
				nriniche	: aux_nriniche,
				nrfimche	: aux_nrfimche,
				
				//
				imp_cheques : imp_cheques,
				imp_criticas: imp_criticas,
				
				redirect	: 'script_ajax'
			}, 
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
			},
			success: function(response) {
				
				try {
					eval(response);
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				}
			}
		});

	return false;	
	                     
}       	

function controlaPesquisas() {

	/*---------------------*/
	/*  CONTROLE CONTA/DV  */
	/*---------------------*/
	var linkConta = $('a:eq(0)','#'+ formCab );

	if ( linkConta.prev().hasClass('campoTelaSemBorda') ) {		
		linkConta.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {

		linkConta.prev().unbind('blur').bind('blur', function() { 
			controlaPesquisas();
			return false;
		});	
	
		linkConta.css('cursor','pointer').unbind('click').bind('click', function() {			
			mostraPesquisaAssociado('nrdconta', formCab );
		});
	}

	return false;
}


// formata
function controlaLayout() {

	
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('#divBotoes').css({'text-align':'center','padding-top':'5px'});

	rBanco.addClass('rotulo').css('width','42px');
	rAgencia.addClass('rotulo-linha').css('width','53px');
	rContraCheque.addClass('rotulo-linha').css('width','84px');
	rNrChequeIni.addClass('rotulo-linha').css('width','41px');
	rNrChequeFim.addClass('rotulo-linha').css('width','35px');
		
	cBanco.css('width','30px').setMask('INTEGER','zzz','','');
	cAgencia.css('width','37px').setMask('INTEGER','zzzz','','');
	cContraCheque.css('width','65px').setMask('INTEGER','zzzz.zzz.z','.','');
	cNrChequeIni.addClass('cheque').css('width','60px');
	cNrChequeFim.addClass('cheque').css('width','60px');

	cTodos_1.desabilitaCampo();

	if ( $.browser.msie ) {
		rBanco.css('width','41px');
		rAgencia.css('width','56px');
		rContraCheque.css('width','88px');
		rNrChequeIni.css('width','44px');
		rNrChequeFim.css('width','37px');
	}	

	// Se pressionar alguma tecla no campo BANCO, verificar a tecla pressionada e toda a devida ação
	cBanco.unbind('keypress').bind('keypress', function(e) { 	
		if ( divError.css('display') == 'block' ) { return false; }	
		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) { 
				operacao = operacao.charAt(0) + '1';
			cBanco.desabilitaCampo();
			
				manterRotina();
			return false;			
			}

	});		
	
	// Se pressionar alguma tecla no campo AGENCIA, verificar a tecla pressionada e toda a devida ação
	cAgencia.unbind('keypress').bind('keypress', function(e) { 	
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			if(!validaAgencia()){
				cContraCheque.desabilitaCampo();
				cNrChequeIni.desabilitaCampo();
				cNrChequeFim.desabilitaCampo();
			}else{
				cContraCheque.habilitaCampo().focus();
				cNrChequeIni.habilitaCampo();
				cNrChequeFim.habilitaCampo();
				cAgencia.desabilitaCampo();
			}
			return false;			
		} 
	});		

	// Se pressionar alguma tecla no campo CONTRA CHEQUE, verificar a tecla pressionada e toda a devida ação
	cContraCheque.unbind('keypress').bind('keypress', function(e) { 	
		if ( divError.css('display') == 'block' ) { return false; }		
			
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			cNrChequeIni.focus();
			return false;			
		} 
		
	});		

	// Se pressionar alguma tecla no campo INICIO, verificar a tecla pressionada e toda a devida ação
	cNrChequeIni.unbind('keypress').bind('keypress', function(e) { 	
		if ( divError.css('display') == 'block' ) { return false; }		
		
		// Se é a tecla ENTER, 	
		if ( e.keyCode == 13 ) {
 			cNrChequeFim.focus();
			return false;			
		} 

	});		

	// Se pressionar alguma tecla no campo FIM, verificar a tecla pressionada e toda a devida ação
	cNrChequeFim.unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
			
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			operacao = operacao.charAt(0) + '2';
			cNrChequeFim.desabilitaCampo();
			manterRotina();
			return false;			
		} 

	});		

	// Se pressionar alguma tecla no campo FIM, verificar a tecla pressionada e toda a devida ação
	cNrChequeFim.next().unbind('click').bind('click', function() { 	
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( cNrChequeFim.hasClass('campoTelaSemBorda') ) { return false; }
		operacao = operacao.charAt(0) + '2';
		manterRotina();
		return false;			
		
	});		
	
	
	if ( operacao == 'B0' || operacao == 'D0' ) {
		$('input, select', '#'+ formCab ).desabilitaCampo();
		
		cAgencia.desabilitaCampo();
		cBanco.habilitaCampo().focus();
		controle = '1';
		operacao = operacao.charAt(0) + controle;
		
	} else if ( operacao == 'B1' || operacao == 'D1' ) {
		cAgencia.val(aux_cdagechq);
		$('input, select', '#'+ formCab ).desabilitaCampo();
		
		if(cBanco.val() == 85  || cBanco.val() == 756) {
			validaContaMigrada();
		}else{ 
			aux_altagchq = 0;
		}
		
		if (aux_altagchq == 1) {
			cAgencia.habilitaCampo().focus();
		}else{
			cContraCheque.habilitaCampo().focus();
			cNrChequeIni.habilitaCampo();
			cNrChequeFim.habilitaCampo();
		 }
		 
		controle = '2';
		operacao = operacao.charAt(0) + controle;
		hideMsgAguardo();

	} else if ( operacao == 'B2' || operacao == 'D2' ) {
		
		// Verifica se retornou alguma cheque em custodia/desconto e abre, senao grava
		if ( cheque != '' ) {
			mostraCheques();
		} else {
			controle = '3';
			operacao = operacao.charAt(0) + controle;
			manterRotina();
			return false;
		}
		
	
	} else if ( operacao == 'B3' || operacao == 'D3' ) {
		montarTabela();
		operacao = operacao.charAt(0) + '0';
		cBanco.attr( 'aux', '' );	
		controlaLayout();
		hideMsgAguardo();
		return false;
	}
	
	
	layoutPadrao();
	$('.conta').trigger('blur');
	controlaPesquisas();
	return false;
	
}

function formataCabecalho() {
	
	rOpcao.css('width','44px');
	rConta.addClass('rotulo-linha');
	rNome.addClass('rotulo-linha');
	
	cTodos.desabilitaCampo();
	cOpcao.css('width','33px');
	cConta.addClass('conta pesquisa').css('width','66px');
	cNome.addClass('descricao').css('width','332px');

	if ( $.browser.msie ) {
		cConta.css('width','65px');
		cNome.css('width','333px');
	}	

	$('#btSalvar', '#divTela').css({'display':'none'});
	cConta.habilitaCampo();
	cOpcao.habilitaCampo();

	// Se pressionar alguma tecla no campo numero da conta, verificar a tecla pressionada e toda a devida ação
	cConta.unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
			
		// Se é a tecla ENTER, verificar numero conta e realizar as devidas operações
		if ( e.keyCode == 13 || e.keyCode == 112 ) {		
			
			setGlobais();
			
			// Armazena o número da conta na variável global
			nrdconta = normalizaNumero( cConta.val() );
											
			// Verifica se o número da conta é vazio
			if ( nrdconta == '' ) { return false; }
	
			// Verifica se a conta é válida
			if ( !validaNroConta(nrdconta) ) { 
				showError('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'nrdconta\',\''+ formCab +'\');'); 
				return false; 
			}
		
			controle 		= '0';
			cddopcao 		= cOpcao.val();
			operacao		= cddopcao + controle;		
			
			// Se chegou até aqui, a conta é diferente do vazio e é válida, então realizar a operação desejada
			controlaOperacao( operacao );
			return false;
		} 

	});		
			
	// Se clicar no botao OK
	$('#btnOK','#frmCab').unbind('click').bind('click', function() {
		
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( cConta.hasClass('campoTelaSemBorda')  ) { return false; }		

		//
		setGlobais();
		
		// Armazena o número da conta na variável global
		nrdconta = normalizaNumero( cConta.val() );
											
		// Verifica se o número da conta é vazio
		if ( nrdconta == '' ) { return false; }
	
		// Verifica se a conta é válida
		if ( !validaNroConta(nrdconta) ) { 
			showError('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'nrdconta\',\''+ formCab +'\');'); 
			return false; 
		}
		
		controle 		= '0';
		cddopcao 		= cOpcao.val();
		operacao		= cddopcao + controle;
		
		// Se chegou até aqui, a conta é diferente do vazio e é válida, então realizar a operação desejada
		controlaOperacao( operacao );
		return false;
			
	});
	
	cOpcao.unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
			
		// Se é a tecla ENTER, pular para o proximo campo
		if ( e.keyCode == 13  ) {		
			cConta.focus();
	return false;	
}
	});

	if (executandoImpedimentos){
		
		if (nrdconta != '') {
			$("#nrdconta","#frmCab").val(nrdconta);
			
			$("#btnOK",'#frmCab').click();		
		}else{
			nrdconta = 0;
		}

	}	
	
	return false;	
}


// imprimir
function Gera_Impressao() {	
	
	var action = UrlSite + 'telas/mantal/imprimir_dados.php';
	
	$('#sidlogin','#'+formDados).remove();		
	
	$('#'+formDados).append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '" />');

	// Configuro o formulário para posteriormente submete-lo
	
	$('#nrdconta','#'+formDados).val(nrdconta);
	$('#cheques','#'+formDados).val(imp_cheques);
	$('#criticas','#'+formDados).val(imp_criticas);
	
	carregaImpressaoAyllos(formDados,action,"estadoInicial();");
	
}


// tabela
function montarTabela() {

	var divTabMantal = $('#divTabMantal');	
	
	divTabMantal.html('<fieldset id="tabConteudo">'+
	'<div class="divRegistros">'+
	'<table>'+
	'<thead>'+
	'<tr>'+
	'<th>Banco</th>'+
	'<th>Agência</th>'+
	'<th>Conta Cheque</th>'+
	'<th>Inicial</th>'+
	'<th>Final</th>'+
	'</tr>'+
	'</thead>'+
	'<tbody>'+
	'</tbody>'+
	'</table>'+
	'</div>'+
	'</fieldset>');	

	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	formataTabela();	

}

function formataTabela() {
	
	// tabela
	var divRegistro = $('div.divRegistros', '#divTabMantal');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
	
	divRegistro.css({'height':'150px','padding-bottom':'2px'});
	
	
	// Monta Tabela dos Itens
	$('#tabConteudo > div > table > tbody').html('');
	var total = arrayMantal.length - 1;
	
	for( i=total; i>=0; i-- ) {
		$('#tabConteudo > div > table > tbody').append('<tr></tr>');																					
		$('#tabConteudo > div > table > tbody > tr:last-child').append('<td>'+ arrayMantal[i]['cdbanchq'] +'</td>');
		$('#tabConteudo > div > table > tbody > tr:last-child').append('<td>'+ arrayMantal[i]['cdagechq'] +'</td>');
		$('#tabConteudo > div > table > tbody > tr:last-child').append('<td>'+ mascara(arrayMantal[i]['nrctachq'],'####.###.#') +'</td>');
		$('#tabConteudo > div > table > tbody > tr:last-child').append('<td>'+ mascara(arrayMantal[i]['nrinichq'], '###.###.#') +'</td>');
		$('#tabConteudo > div > table > tbody > tr:last-child').append('<td>'+ mascara(arrayMantal[i]['nrfimchq'], '###.###.#') +'</td>');
		
	}
	
	
	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '82px';
	arrayLargura[1] = '101px';
	arrayLargura[2] = '111px';
	arrayLargura[3] = '101px';


	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'center';
	arrayAlinha[3] = 'center';
	arrayAlinha[4] = 'center';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	$('#btSalvar', '#divTela').css({'display':''});
	return false;
}


// cheques
function mostraCheques() {
	
	showMsgAguardo('Aguarde, abrindo ...');

	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/mantal/cheques.php', 
		data: {
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			buscaCheques();
			return false;
		}				
	});
	return false;
	
}

function buscaCheques() {
		
	showMsgAguardo('Aguarde, buscando ...');

	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/mantal/tab_cheques.php', 
		data: {
			cheque: cheque, 
			redirect: 'script_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {
		
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divConteudoCheques').html(response);
					exibeRotina($('#divRotina'));
					formataCheques();
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			} else {
				try {
					eval( response );
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		}				
	});
	return false;
}

function formataCheques() {

	/********************
		FORMATA TABELA	
	*********************/
	var divRegistro = $('div.divRegistros','#divCheque');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'160px','width':'500px'});
	
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];
			
	var arrayLargura = new Array();
	arrayLargura[0] = '70px';
	arrayLargura[1] = '280px';
	
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'center';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );


	/********************
	 FORMATA COMPLEMENTO	
	*********************/
	// complemento linha 1
	var linha1  = $('ul.complemento', '#divChequeLinha1');
	
	$('li:eq(0)', linha1).addClass('txtNormalBold').css({'width':'17%'});
	$('li:eq(1)', linha1).addClass('txtNormal').css({'width':'38%'});
	$('li:eq(2)', linha1).addClass('txtNormalBold').css({'width':'18%'});
	$('li:eq(3)', linha1).addClass('txtNormal');

	// complemento linha 2
	var linha2  = $('ul.complemento', '#divChequeLinha2').css({'clear':'both','border-top':'0'});
	
	$('li:eq(0)', linha2).addClass('txtNormalBold').css({'width':'17%'});
	$('li:eq(1)', linha2).addClass('txtNormal');

	
	/********************
	  EVENTO COMPLEMENTO	
	*********************/
	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		selecionaCheque($(this));
	});	

	// seleciona o registro que é focado
	$('table > tbody > tr', divRegistro).focus( function() {
		selecionaCheque($(this));
	});	
	
	
	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	return false;
}

function selecionaCheque(tr) {

	$('#tpchequeLi').html($('#tpcheque', tr ).val());
	$('#dtliberaLi').html($('#dtlibera', tr ).val());
	$('#cdpesquiLi').html($('#cdpesqui', tr ).val());

	return false;
}

function continuarCheque( opcao ) {

	fechaRotina($('#divRotina'));

	if ( opcao == 'S' ) {
		controle = '3';
		operacao = operacao.charAt(0) + controle;
		manterRotina();
	} else {
		cBanco.attr('aux','');
		controle = '0';
		operacao = operacao.charAt(0) + controle;
		controlaLayout();
	}

	return false;	
}


// botoes
function btnVoltar() {
	
		if (executandoImpedimentos){
			posicao++;
			showMsgAguardo('Aguarde, carregando tela DCTROR ...');
			setaParametrosImped('DCTROR','',nrdconta,flgcadas, 'MANTAL');
			setaImped();
			direcionaTela('DCTROR','no');
		}else{

			estadoInicial();	
		}
	
	
	return false;
}

function btnContinuar() {
	showConfirmacao('Deseja continuar a operação?','Confirma&ccedil;&atilde;o - Ayllos','continuarCheque(\'S\');','continuarCheque(\'N\');','sim.gif','nao.gif');
	return false;
}

function btnConcluir() {
	
	if ( arrayMantal.length > 0 ) {
	
		if ( cddopcao == 'B' || imp_criticas != '' ) {
			showConfirmacao('Imprimir ?','Confirma&ccedil;&atilde;o - Ayllos','Gera_Impressao();','estadoInicial();','sim.gif','nao.gif');
		} else {
			$('input', '#'+ formCab ).limpaFormulario();
			$('input', '#'+ formDados ).limpaFormulario();
			estadoInicial();
		}
	}
	
	return false;	

}


// set global
function setGlobais() {

	if (!executandoImpedimentos){
		nrdconta 		= 0 ; 	
	}	
	operacao 		= ''; 
	controle		= '';	
	cddopcao		= '';
	aux_cdagechq	= '';
	aux_nriniche	= '';
	aux_nrfinche	= '';
	cheque  		= '';
	imp_cheques		= '';
	imp_criticas	= '';
	nrJanelas		= 0;
	arrayMantal 	= new Array();
	return false;
}

function validaContaMigrada() {
		
	hideMsgAguardo();

	showMsgAguardo( 'Aguarde, validando ...' );	

	$.ajax({		
			type  : 'POST',
			async : false ,
			url   : UrlSite + 'telas/mantal/valida_conta_migrada.php',
			data: {
				nrdconta	: nrdconta,
				redirect	: 'script_ajax'
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


function validaAgencia() {
		
	hideMsgAguardo();
	
	var aux_retorno = false;
	var cdagechq = $('#cdagechq','#'+formDados).val();
	
	showMsgAguardo( 'Aguarde, validando ...');	

	$.ajax({		
			type  : 'POST',
			async : false ,
			url   : UrlSite + 'telas/mantal/valida_agencia.php',
			data: {
				nrdconta	: nrdconta,
				cdagechq	: cdagechq,
				redirect	: 'script_ajax'
			}, 
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
			},
			success: function(response) {
				try {
					if (response.indexOf('showError("error"') == -1) {
						aux_retorno = true;
						eval(response);

						hideMsgAguardo();
					} else {
						aux_retorno = false;
						hideMsgAguardo();
						eval(response);
					}
				} catch(error) {
					hideMsgAguardo();
				}
			}
		});
	
	return aux_retorno;
}
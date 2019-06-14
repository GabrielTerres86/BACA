/*!
 * FONTE        : desext.js
 * CRIAÇÃO      : Rogerius Militão (DB1) 
 * DATA CRIAÇÃO : 28/07/2011
 * OBJETIVO     : Biblioteca de funções da tela DESEXT
 * --------------
 * ALTERAÇÕES   : 17/09/2012 - Inclusão de novo layout para botoes Voltar, Concluir e Prosseguir, 
							   inclusão de condicao para navegar com tecla Enter. (Lucas R.)
 * --------------
 */

// Definição de algumas variáveis globais 
var arrayDesext		= new Array();
var cdagepac		= '';
var nrdconta		= 0;
var idseqttl		= 1;

//Formulários
var frmCab   		= 'frmCab';
var tabDados		= 'tabDesext';

//Labels/Campos do cabeçalho
var rNrdconta, rCdsecext, rTpextcta, rTpavsdeb, rNmprimtl,
	cNrdconta, cCdsecext, cTpextcta, cTpavsdeb, cNmprimtl, cTodos, btnOK;

$(document).ready(function() {
	estadoInicial();
	$('#'+tabDados).css({'display':'none'});	
});

// seletores
function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);

	cdagepac = '';
	nrdconta = 0 ;
	hideMsgAguardo();		
	atualizaSeletor();
	formataCabecalho();
		
	removeOpacidade('divTela');
	
}

function atualizaSeletor(){

	// cabecalho
	rNrdconta			= $('label[for="nrdconta"]','#'+frmCab); 
	rCdsecext			= $('label[for="cdsecext"]','#'+frmCab); 
	rTpextcta			= $('label[for="tpextcta"]','#'+frmCab); 
	rTpavsdeb	        = $('label[for="tpavsdeb"]','#'+frmCab);        
	rNmprimtl	        = $('label[for="nmprimtl"]','#'+frmCab);        
	
	cNrdconta			= $('#nrdconta','#'+frmCab); 
	cCdsecext			= $('#cdsecext','#'+frmCab); 
	cTpextcta			= $('#tpextcta','#'+frmCab); 
	cTpavsdeb			= $('#tpavsdeb','#'+frmCab); 
	cNmprimtl			= $('#nmprimtl','#'+frmCab); 
	cTodos				= $('input[type="text"],select','#'+frmCab);
	btnOK				= $('#btnOK','#'+frmCab);
	
	return false;
}

// controle
function controlaOperacao() {
	
	nrdconta = normalizaNumero( cNrdconta.val() );
	
	var mensagem = 'Aguarde, buscando dados ...';
	showMsgAguardo( mensagem );	
	
	// Carrega dados da conta através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/desext/principal.php', 
		data    : 
				{ 
					nrdconta	: nrdconta, 
					redirect	: 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();					
					showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) {
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

function manterRotina( operacao ) {
		
	hideMsgAguardo();		

	var mensagem = '';
	var nrdconta = normalizaNumero( cNrdconta.val() );
	var cdsecext = normalizaNumero( cCdsecext.val() );
	var tpextcta = normalizaNumero( cTpextcta.val() );
	var tpavsdeb = normalizaNumero( cTpavsdeb.val() );
	var nmprimtl = cNmprimtl.val();
	
	switch (operacao) {
		case 'V': mensagem = 'Aguarde, validando...'; break;
		case 'G': mensagem = 'Aguarde, gravando...'; break;
		default: return false; break;
	}
	
	showMsgAguardo( mensagem );	
	
	$.ajax({		
			type  : 'POST',
			url   : UrlSite + 'telas/desext/manter_rotina.php', 		
			data: {
				operacao	: operacao,
				nrdconta	: nrdconta,
				cdsecext	: cdsecext,
				tpextcta	: tpextcta,
				tpavsdeb	: tpavsdeb,
				nmprimtl	: nmprimtl,	
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
	var linkConta = $('a:eq(0)','#'+ frmCab );
	var linkDestino = $('a:eq(2)','#'+ frmCab );

	if ( linkConta.prev().hasClass('campoTelaSemBorda') ) {		
		
		linkConta.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} 
	else

		/*if (linkDestino.prev().hasClass('campoTelaSemBorda')) */	{
	
		linkConta.prev().unbind('blur').bind('blur', function() { 
			controlaPesquisas();
			return false;
		});	
	
		linkConta.css('cursor','pointer').unbind('click').bind('click', function() {			
			mostraPesquisaAssociado('nrdconta', frmCab );
		});
	}

	if ( linkDestino.prev().hasClass('campoTelaSemBorda') ) {		
		linkDestino.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {
	
		linkDestino.css('cursor','pointer').unbind('click').bind('click', function() {			
			var bo 			= 'b1wgen0059.p';
			var procedure	= 'Busca_Destino_Extrato';
			var titulo      = 'Destino de Extrato';
			var qtReg		= '30';
			var filtrosPesq	= 'Código;cdsecext;30px;S;0|Destino;dssecext;200px;S;|Cód. Agência;cdagepac;30px;N;'+cdagepac+';N;';
			var colunas 	= 'Código;cdsecext;20%;right|Descrição;dssecext;80%;left';
			mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas,frmCab);
			return false;
		});
	}

	return false;
}

// formata
function formataCabecalho() {

	var nomeForm    = 'frmCab';
	highlightObjFocus( $('#'+nomeForm) );
		
	rNrdconta.addClass('rotulo').css({'width':'44px'});
	rCdsecext.addClass('rotulo-linha').css({'width':'50px'});
	rTpextcta.addClass('rotulo-linha').css({'width':'50px'});
	rTpavsdeb.addClass('rotulo-linha').css({'width':'50px'});
	rNmprimtl.addClass('rotulo').css({'width':'44px'});
	
	cNrdconta.addClass('conta pesquisa').css({'width':'75px'})
	cCdsecext.addClass('inteiro pesquisa').css({'width':'64px'}).attr('maxlength','3');
	cTpextcta.addClass('inteiro').css({'width':'64px'}).attr('maxlength','1');
	cTpavsdeb.addClass('inteiro').css({'width':'65px'}).attr('maxlength','1');
	cNmprimtl.css({'width':'504px'}).attr('maxlength','40');
	
	if ( $.browser.msie ) {
		rCdsecext.css({'width':'53px'});
		rTpextcta.css({'width':'53px'});
		rTpavsdeb.css({'width':'53px'});
	}	
	
	cTodos.desabilitaCampo();
	cNrdconta.habilitaCampo();
	cNrdconta.focus();
	//trocaBotao('Prosseguir');
	
	// Se clicar no botao OK
	btnOK.unbind('click').bind('click', function() { 	
  
		cTodos.removeClass('campoErro');	
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( cNrdconta.hasClass('campoTelaSemBorda')  ) { return false; }		
		
		// Armazena o número da conta na variável global
		nrdconta = normalizaNumero( cNrdconta.val() );
		
		// Verifica se o número da conta é vazio
		if ( nrdconta == '' ) { return false; }
	
		// Verifica se a conta é válida
		if ( !validaNroConta(nrdconta) ) { 
			showError('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'nrdconta\',\''+ frmCab +'\');'); 
			return false; 
		}

		// Se chegou até aqui, a conta é diferente do vazio e é válida, então realizar a operação desejada
		controlaOperacao();
		return false;
			
	});	

	cNrdconta.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {

			// Armazena o número da conta na variável global
			nrdconta = normalizaNumero( cNrdconta.val() );
			
			// Verifica se o número da conta é vazio
			if ( nrdconta == '' ) { return false; }
		
			// Verifica se a conta é válida
			if ( !validaNroConta(nrdconta) ) { 
				showError('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'nrdconta\',\''+ frmCab +'\');'); 
				return false; 
			}
		
			cTodos.removeClass('campoErro');	
			controlaOperacao();
			return false;
			
		} else if ( e.keyCode == 118 ) {
			mostraPesquisaAssociado('nrdconta', frmCab );
			return false;
		}
	});
	
	//Destino
	cCdsecext.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9) {	
			cTpextcta.focus();
			return false;
		}
	});

	//Extrato
	cTpextcta.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9) {
			cTpavsdeb.focus();
			return false;
		}
	});
	
	//Avisos e executa enter	
	cTpavsdeb.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9 ) {
			btnContinuar();
			return false;
		}
	});
		
	layoutPadrao();
	controlaPesquisas();
	return false;

}

function controlaLayout() {
				
	cTodos.habilitaCampo().removeClass('campoErro');
	cCdsecext.focus();
	cNrdconta.desabilitaCampo();
	cNmprimtl.desabilitaCampo();
	trocaBotao('Concluir');
	
	hideMsgAguardo();
	layoutPadrao();
	controlaPesquisas();
	return false;
	
}

// tabela
function montarTabela() {
	
	$('#'+tabDados).html(
	'<div class="divRegistros">	'+
		'<table>'+
			'<thead>'+
				'<tr>'+
					'<th>Conta</th>'+
					'<th>Titular</th>'+
					'<th>Destino</th>'+
					'<th>Extrato</th>'+
					'<th>Avisos</th>'+
				'</tr>'+
			'</thead>'+
			'<tbody>'+
			'</tbody>'+
		'</table>'+
	'</div>'
	);	

	formataTabela();	

}

function formataTabela() {
	
	// tabela
	var divRegistro = $('div.divRegistros', '#'+tabDados);		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
	
	$('#'+tabDados).css({'margin-top':'5px'});
	divRegistro.css({'height':'230px','padding-bottom':'2px'});

	// Monta Tabela dos Itens
	$('#tabDesext > div > table > tbody').html('');
	
	for( var i in arrayDesext ) {
		$('#tabDesext > div > table > tbody').append('<tr></tr>');																					
		$('#tabDesext > div > table > tbody > tr:last-child').append('<td>'+ arrayDesext[i]['nrdconta'] +'</td>');
		$('#tabDesext > div > table > tbody > tr:last-child').append('<td>'+ arrayDesext[i]['nmprimtl'].substr(0,33) +'</td>');
		$('#tabDesext > div > table > tbody > tr:last-child').append('<td>'+ arrayDesext[i]['cdsecext'] +'</td>');
		$('#tabDesext > div > table > tbody > tr:last-child').append('<td>'+ arrayDesext[i]['tpextcta'] +'</td>');
		$('#tabDesext > div > table > tbody > tr:last-child').append('<td>'+ arrayDesext[i]['tpavsdeb'] +'</td>');
	}

	if ( arrayDesext.length >= 14 ) { arrayDesext = new Array(); }
	
	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '70px';
	arrayLargura[1] = '250px';
	arrayLargura[2] = '55px';
	arrayLargura[3] = '55px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'right';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	
	$('#'+tabDados).css({'display':'block'});	
	estadoInicial();
	cNrdconta.desabilitaCampo();
	return false;
}

// botoes
function btnVoltar() {
	estadoInicial();
	
	$("#tabDesext").css('display','none'); 	
	cTodos.limpaFormulario().removeClass('campoErro');
	return false;
}

function btnContinuar() {

	cTodos.removeClass('campoErro');	
	if ( divError.css('display') == 'block' ) { return false; }		
	if ( cNrdconta.hasClass('campo')  ) { 	
	
		// Armazena o número da conta na variável global
		nrdconta = normalizaNumero( cNrdconta.val() );

		// Verifica se o número da conta é vazio
		if ( nrdconta == '' ) { return false; }

		// Verifica se a conta é válida
		if ( !validaNroConta(nrdconta) ) { 
			showError('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'nrdconta\',\''+ frmCab +'\');'); 
			return false; 
		}

		cTodos.removeClass('campoErro');	
		
		// Se chegou até aqui, a conta é diferente do vazio e é válida, então realizar a operação desejada
		controlaOperacao();
	} else {
		manterRotina('V');
	}
	
	return false;

}

function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>&nbsp;');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onclick="btnContinuar(); return false;">'+botao+'</a>&nbsp;');
	return false;
} 
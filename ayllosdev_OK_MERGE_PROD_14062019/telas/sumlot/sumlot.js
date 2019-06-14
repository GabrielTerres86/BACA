/*!
 * FONTE        : sumlot.js
 * CRIAÇÃO      : Rogerius Militão (DB1) 
 * DATA CRIAÇÃO : 25/10/2011
 * OBJETIVO     : Biblioteca de funções da tela SUMLOT
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * [11/04/2012] Rogérius Militão   (DB1) : Ajuste no layout padrão
 *
 * [02/07/2012] Jorge Hamaguchi (CECRED) : Alterado funcao Gera_Criticas() , novo esquema para impressao.  
 */

//Formulários
var frmCab   		= 'frmCab';
var nrJanelas		= 0;

//Labels/Campos do cabeçalho
var rCdagenci, rCdbccxlt, rQtcompln, rVlcompap,
	cCdagenci, cCdbccxlt, cQtcompln, cVlcompap, cNmarqpdf, cTodosCabecalho;

$(document).ready(function() {
	estadoInicial();
});


// seletores
function estadoInicial() {
	$('#divTela').fadeTo(0,0.1);
	
	trocaBotao('Prosseguir');
	hideMsgAguardo();		
	formataCabecalho();
	cTodosCabecalho.limpaFormulario().removeClass('campoErro');	

	removeOpacidade('divTela');
}


// controle
function controlaOperacao() {
	
	var cdagenci = normalizaNumero( cCdagenci.val() ); 
	var cdbccxlt = normalizaNumero( cCdbccxlt.val() );
	
	var mensagem = 'Aguarde, buscando dados ...';
	showMsgAguardo( mensagem );	
	
	// Carrega dados da conta através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/sumlot/principal.php', 
		data    : 
				{ 
					cdagenci	: cdagenci,
					cdbccxlt	: cdbccxlt,
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


// formata
function formataCabecalho() {

	highlightObjFocus($('#'+frmCab));

	// rotulo
	rCdagenci			= $('label[for="cdagenci"]','#'+frmCab); 
	rCdbccxlt			= $('label[for="cdbccxlt"]','#'+frmCab);
	rQtcompln			= $('label[for="qtcompln"]','#'+frmCab);
	rVlcompap			= $('label[for="vlcompap"]','#'+frmCab);

	rCdagenci.addClass('rotulo').css({'width':'33px'});
	rCdbccxlt.addClass('rotulo-linha').css({'width':'82px'});
	rQtcompln.addClass('rotulo-linha').css({'width':'107px'});
	rVlcompap.addClass('rotulo-linha').css({'width':'129px'});

	// campo
	cCdagenci			= $('#cdagenci', '#'+frmCab); 
	cCdbccxlt			= $('#cdbccxlt', '#'+frmCab);			
	cQtcompln			= $('#qtcompln', '#'+frmCab);
	cVlcompap			= $('#vlcompap', '#'+frmCab);	
	cNmarqpdf			= $('#nmarqpdf', '#'+frmCab);	

	cCdagenci.addClass('inteiro').css({'width':'50px'}).attr('maxlength','3');
	cCdbccxlt.addClass('inteiro').css({'width':'50px'}).attr('maxlength','3');	
	cQtcompln.css({'width':'75px','text-align':'right'});	
	cVlcompap.css({'width':'119px','text-align':'right'});	
	
	// todos campos e botao
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	btnOK				= $('#btnOK','#'+frmCab);

	if ( $.browser.msie ) {
		rCdbccxlt.css({'width':'86px'});
		rQtcompln.css({'width':'109px'});
		rVlcompap.css({'width':'132px'});
	}	
	
	cTodosCabecalho.desabilitaCampo();	
	cCdagenci.habilitaCampo();
	cCdbccxlt.habilitaCampo();
	cCdagenci.focus();
	
	// Se clicar no botao OK
	btnOK.unbind('click').bind('click', function() { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( cCdagenci.hasClass('campoTelaSemBorda')  ) { return false; }		
		
		cTodosCabecalho.removeClass('campoErro');	
		
		// Se chegou até aqui, a conta é diferente do vazio e é válida, então realizar a operação desejada
		controlaOperacao();
		return false;
			
	});	

	cCdagenci.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla TAB ou ENTER, 
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cCdbccxlt.focus();
			return false;
		} 
	});	
	
	cCdbccxlt.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla TAB ou ENTER, 
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			controlaOperacao();
			return false;
		} 
	});	

	layoutPadrao();
	return false;	
}


// imprimir
function Gera_Criticas() {	

	hideMsgAguardo();
	
	var action = UrlSite + 'telas/sumlot/imprimir_criticas.php';
				
	carregaImpressaoAyllos(frmCab,action,"cTodosCabecalho.desabilitaCampo();$('#btVoltar', '#divTela').focus();	$('#btProsseguir', '#divTela').remove();");
	
}


// botoes
function btnVoltar() {
	estadoInicial();
	return false;
}

function btnContinuar() {
	
	if ( divError.css('display') == 'block' ) { return false; }		
	if ( cCdagenci.hasClass('campo') ) { controlaOperacao(); }
	return false;

}

function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>&nbsp;');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btProsseguir" onclick="btnContinuar(); return false;">'+botao+'</a>');
	return false;
}


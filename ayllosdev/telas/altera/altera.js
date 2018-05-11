/*!
 * FONTE        : altera.js
 * CRIAÇÃO      : Henrique
 * DATA CRIAÇÃO : 24/06/2011
 * OBJETIVO     : Biblioteca de funções da tela ALTERA
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 * [27/03/2012] Rogérius Militão (DB1) : Novo layout padrão
 * [11/04/2017] Permitir acessar o Ayllos mesmo vindo do CRM. (Jaison/Andrino)
 */
 
var nrdconta, nmprimtl, nrdctitg;
var frmCabecalho, divTabela, divRegistros;
var cNrdconta, cNmprimtl, cNrdctitg;
var cDtaltera, cTpaltera, cNmoperad, cDsaltera;

$(document).ready(function() {

	// Inicializando algumas variáveis
	nrdconta = 0;
	nmprimtl = '';
	nrdctitg = '';
	
	frmCabecalho = $('#frmCabecalho');
	divTabela    = $('#divTabela');
	divRegistros = $('div.divRegistros', divTabela );
	
	// Inicializando os seletores dos campos do cabeçalho
	cNrdconta = $('#nrdconta','#frmCabAltera');
	cNmprimtl = $('#nmprimtl','#frmCabAltera');
	cNrdctitg = $('#nrdctitg','#frmCabAltera');
	
	controlaLayout();

});

function controlaLayout() {	
	formataCabecalho();
	formataTabela();
	layoutPadrao();		
}

function formataCabecalho() {

	highlightObjFocus( $('#frmCabAltera') );

	//ROTULOS
	var rNrdconta   = $('label[for="nrdconta"]','#frmCabAltera');
	var rNmprimtl	= $('label[for="nmprimtl"]','#frmCabAltera');
	var	rNrdctitg   = $('label[for="nrdctitg"]','#frmCabAltera');
		
	rNrdconta.addClass('rotulo').css({'width':'40px'});
	rNmprimtl.addClass('rotulo-linha').css({'width':'45px'});
	rNrdctitg.addClass('rotulo-linha').css({'width':'62px'});
	
	cNrdconta.addClass('conta pesquisa').css({'width':'75px'}).habilitaCampo();
	cNmprimtl.css({'width':'310px'}).desabilitaCampo();
	cNrdctitg.css({'width':'120px'}).desabilitaCampo();

	if ( $.browser.msie ) {
		rNrdctitg.css({'width':'65px'});
		cNrdconta.css({'width':'77px'});
	} 
	
	cNrdconta.buscaConta('carrega_dados();','estadoInicial();');

    // Seta os valores caso tenha vindo do CRM
    if ($("#crm_inacesso","#frmCabAltera").val() == 1) {
        $("#nrdconta","#frmCabAltera").val($("#crm_nrdconta","#frmCabAltera").val());
    }
	
}

function formataTabela() {
	
	divRegistros = $('div.divRegistros', divTabela );
	
	cDtaltera = $('#dtaltera',divRegistros);
	cTpaltera = $('#tpaltera',divRegistros);
	cNmoperad = $('#nmoperad',divRegistros);
	cDsaltera = $('#dsaltera',divRegistros);
	
	divRegistros.css({'height':'335px','padding-bottom':'2px'});
	
	//ROTULOS
	var rDtaltera   = $('label[for="dtaltera"]',divRegistros);
	var rTpaltera	= $('label[for="tpaltera"]',divRegistros);
	var	rNmoperad   = $('label[for="nmoperad"]',divRegistros);
		
	rDtaltera.addClass('rotulo').css({'width':'25px'});;
	rTpaltera.addClass('rotulo-linha').css({'padding-left': '35px'});
	rNmoperad.addClass('rotulo-linha').css({'padding-left': '35px'});;
	
	cDtaltera.css({'width':'80px'}).desabilitaCampo();
	cTpaltera.css({'width':'25px'}).desabilitaCampo();
	cNmoperad.css({'width':'300px'}).desabilitaCampo();
	cDsaltera.desabilitaCampo();
	divTabela.css({'display':'block'});
	
	cNrdconta.next().next().css({'display':'block'});
	cNrdconta.focus();
	return false;
}

function carrega_dados(){

	var nrdconta = retiraCaracteres($("#nrdconta","#frmCabAltera").val(),"0123456789",true);
	
	// Valida número da conta
	if (!validaNroConta(nrdconta)) {
		showError("error","Conta/dv inválida.","Alerta - Ayllos","$('#nrdconta','#frmCabAltera').focus();");
		return false;
	}

	// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, validando informa&ccedil;&otilde;es ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		dataType: 'html',
		url: UrlSite + "telas/altera/carrega_dados.php",
		data: {
		    nrdconta: nrdconta,	
			redirect: "script_ajax" // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrdconta','#frmCabAltera').focus();");							
		},
		success: function(response) {	
			hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divTabela').html(response);
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#nrdconta\',\'#frmCabAltera\').focus();');
				}
			} else {
				try {
					eval( response );
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#nrdconta\',\'#frmCabAltera\').focus();');
				}
			}
		
		}		
				
	});

}

function estadoInicial() {
	var cTodos = $('input','#frmCabAltera');

	cTodos.val('');
	cNrdconta.focus();
	
}


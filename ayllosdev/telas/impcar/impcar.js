/*!
 * FONTE        : impcar.js
 * CRIAÇÃO      : James Prust Junior
 * DATA CRIAÇÃO : 23/03/2016
 * OBJETIVO     : Biblioteca de funções da tela IMPCAR
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
$(document).ready(function() {

	estadoInicial();

	highlightObjFocus( $('#frmCab') );

	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});

	return false;

});

function estadoInicial() {

	$('#frmCab').css({'display':'block'});
	$('#frmImportarArquivo').css({'display':'none'});
	$('#divBotoes', '#divTela').html('').css({'display':'block'});

	formataCabecalho();

	return false;

}

function controlaFoco() {
		
	$('#cddopcao','#frmCab').unbind('keypress').bind('keypress', function(e) {
	
		if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda') ) { return false; }
		
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			eventTipoOpcao();			
			return false;
		}	
	});
	
	$('#btnOK','#frmCab').unbind('keypress').bind('keypress', function(e) {
		
		if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda') ) { return false; }
		
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			eventTipoOpcao();
			return false;
		}	
	});
	
	$('#btnOK','#frmCab').unbind('click').bind('click', function(){
	
		if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda') ) { return false; }		
		eventTipoOpcao();
		return false;			
	});
	
	return false;
	
}

function eventTipoOpcao(){
	var oOpcao = $('#cddopcao','#frmCab');
	oOpcao.desabilitaCampo();
	
	buscaArquivosImportacao(oOpcao.val());
	return false;	
}

function formataCabecalho() {

	$('input,select', '#frmCab').removeClass('campoErro');
	$('#divTela').css({'display':'inline'}).fadeTo(0,0.1);
	removeOpacidade('divTela');	

	cTodosCabecalho = $('input[type="text"],select','#frmCab'); 
	cTodosCabecalho.limpaFormulario();

	// cabecalho
	rCddopcao			= $('label[for="cddopcao"]','#frmCab'); 
	cCddopcao			= $('#cddopcao','#frmCab'); 
	//Rótulos
	rCddopcao.css('width','44px');
	//Campos	
	cCddopcao.css({'width':'496px'}).habilitaCampo().focus();
	
	controlaFoco();
	layoutPadrao();

	return false;	
}

function btnVoltar(){
	$('#frmImportarArquivo').css('display','none');
	estadoInicial();
	return false;
}

function btnContinuar() {
	buscaArquivosImportacao($('#cddopcao','#frmCab').val());
	return false;	
}

function trocaBotao( funcaoSalvar,funcaoVoltar,sTitulo) {	
    var sTitulo = sTitulo || 'Concluir';

	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onClick="'+funcaoVoltar+'; return false;">Voltar</a>&nbsp;');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onClick="'+funcaoSalvar+'; return false;">'+sTitulo+'</a>');	
	return false;
}

function formataTelaImportacaoArquivos() {

	var cDsstatus 	= $('#dsstatus','#frmImportarArquivo');
	var rDsstatus 	= $('label[for="dsstatus"]', '#frmImportarArquivo');
    var divRegistro = $('#divArquivos');
    var tabela      = $('table', divRegistro );
    var linha       = $('table > tbody > tr', divRegistro );

	rDsstatus.addClass('rotulo-linha').css({'width':'40px'});
	cDsstatus.addClass('campo').css({'width':'100px'});	
	cDsstatus.desabilitaCampo();

	// FORMATA O GRID DOS LANCAMENTOS DE PAGAMENTO
    divRegistro.css({'height':'120px'});

    var ordemInicial = new Array();
    ordemInicial = [[0,0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '100px';

	var arrayAlinha = new Array();
    arrayAlinha[0] = 'left';
    arrayAlinha[1] = 'left';

    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);
    return false;
}

function buscaArquivosImportacao(op) {

	showMsgAguardo("Aguarde...");
	
	$.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/impcar/busca_arquivos_importacao.php',
        data: {
			cddopcao: op,
			redirect: 'script_ajax'
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
        },
        success: function(response) {
			try {
				hideMsgAguardo();
				$('#divImpcar').html(response);				
				formataTelaImportacaoArquivos();
                return false;
            } catch(error) {
                hideMsgAguardo();
                showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
            }
        }
    });
	return false;
}

function importarArquivos() {

	showMsgAguardo("Aguarde...");

	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/impcar/manter_rotina.php",
		data: {
		    cddopcao: $('#cddopcao','#frmCab').val(),
			redirect: "script_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divTela').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
				return false;
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
			}
		}
	});
}
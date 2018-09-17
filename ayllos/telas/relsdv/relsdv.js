/*!
 * FONTE        : relsdv.js
 * CRIAÇÃO      : Jean Calão (Mout´S)
 * DATA CRIAÇÃO : Fevereiro /2017
 * OBJETIVO     : Biblioteca de funções da rotina de geração do relatório de saldo devedor de empréstimo 
 * --------------
 * ALTERAÇÃO: 
 * -----------------------------------------------------------------------
 */


$(document).ready(function() {
	estadoInicial();
    
});


function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);

    formataCabecalho();	
	
	$('#divBotoes').css({'display':'block'});
	$('#divOpcoes2').css({'display':'block'});
	$('#frmCab').css({'display':'block'});

	removeOpacidade('divTela');
	$("#nmdarqui","#frmCab").focus();

}	

// Formata
function formataCabecalho() {	
	
	highlightObjFocus( $('#frmCab') );
	
	layoutPadrao();
	return false;	
}	


// Botoes
function btnVoltar() {
	estadoInicial();
	return false;
}



function btnGerar() {
	
//	if ( divError.css('display') == 'block' ) { return false; }		
	
	showConfirmacao('Confirma gera&ccedil;&atilde;o dos registros?','Confirma&ccedil;&atilde;o - Ayllos','gerarRelsdv();','','sim.gif','nao.gif');				
}

function gerarRelsdv() {
	
	hideMsgAguardo();
	
	var nmdarqui;
	var nmdarsai;
	
	var nmdarqui = $("#nmdarqui","#frmCab").val();
	var nmdarsai = $("#nmdarsai","#frmCab").val();
	
		
	// Carrega dados da conta através de ajax
	$.ajax({		
		type: 'POST',
		url	: UrlSite + 'telas/relsdv/gerar_relsdv.php', 
		data: { 
				nmdarqui: nmdarqui,
				nmdarsai: nmdarsai,
				redirect: 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) {
			try {
				hideMsgAguardo();		
				eval(response);				
			    return false;
			} catch(error) {				
				hideMsgAguardo();
				showError('error','Arquivo processado com sucesso.','Alerta - Ayllos','');
			}
		}
	});				
}


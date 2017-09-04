/*
  FONTE        : libcrm.js
  CRIAÇÃO      : Kelvin Souza Ott 
  DATA CRIAÇÃO : 09/08/2017
  OBJETIVO     : Biblioteca de funções da tela LIBCRM
  --------------
  ALTERAÇÕES   : 
 
  --------------
 */
 var frmLibCrm   		= 'frmLibCrm';
 
 var rFlgaccrm, cFlgaccrm, btnConfirmar;
 
 $(document).ready(function() {		
	estadoInicial();			
	
	buscaParametros();
	
	return false;	
});

// Inicio
function estadoInicial() {

	$('#frmLibCrm').fadeTo(0,0.1);
	
	removeOpacidade(frmLibCrm);	
	
	return false;
	
}

function buscaParametros(){
	
	showMsgAguardo('Aguarde, consultando parametros...');
	
	$.ajax({		
		type	: 'POST',
		dataType: 'script',
		url		: UrlSite + 'telas/'+nometela+'/busca_parametros.php', 
		data    :
				{ 	
				    redirect: 'script_ajax'				 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#nrdconta\',\'#frmCab\').focus();');
				},
		success : function(response) { 		
					hideMsgAguardo();								
				}
	});
}

function alteraParametros(){
	showMsgAguardo('Aguarde, alterando parametros...');
	
	var flgaccrm = $("#flgaccrm").val();
	
	$.ajax({		
		type	: 'POST',
		dataType: 'script',
		url		: UrlSite + 'telas/'+nometela+'/altera_parametros.php', 
		data    :
				{ 	flgaccrm: flgaccrm
				   ,redirect: 'script_ajax'				 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#nrdconta\',\'#frmCab\').focus();');
				},
		success : function(response) { 		
					hideMsgAguardo();								
				}
	});
}
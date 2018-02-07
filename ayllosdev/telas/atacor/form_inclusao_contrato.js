/*!
 * FONTE        : form_inclusao_contrato.js
 * CRIAÇÃO      : Leticia Terres (AMcom)
 * DATA CRIAÇÃO : 29/03/2011
 * OBJETIVO     : Biblioteca de funções na rotina Prestações da tela ATENDA
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

function limpaDivGenerica(){ 

	$('#tbImp').remove();
	
	return false;
}

function mostraDivQualificaControle(operacao) {

	showMsgAguardo('Aguarde, abrindo inclus?o de contratos...');

	limpaDivGenerica();

	exibeRotina($('#divUsoGenerico'));

	 var nracordo = $('#nracordo').val();
	 var cdcooper = $('#cdcooper').val();	
	 
	//Executa script de confirma��o atrav�s de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atacor/form_inclusao_contrato.php',
		 data: {
			 nracordo: nracordo,			
			 cdcooper: cdcooper,
		 	redirect: 'html_ajax'
		 },
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function (response) {
			 $('#divUsoGenerico').html(response);
			 layoutPadrao();
			 hideMsgAguardo();
			 bloqueiaFundo($('#divUsoGenerico'));
             $('#nracordo', '#frmincctr').focus(); 

		}
	});

	return false;
}


function controlaOperacao(operacao) {

	var mensagem = '';
	var nracordo = 0;
	var nrctremp = 0;
	var cdcooper = 0;

	if ( in_array(operacao,['']) ) {
		nrctremp = '';
	}


	switch (operacao) {
		case 'BUSCA_CONTRATOS_LC100':
			mostraDivQualificaControle(operacao);
			return false;
			break;
	}
}

function valida_contrato(operacao){
	 var nracordo = $('#nracordo').val();
	 var cdcooper = $('#cdcooper').val();	
	 var nrctremp = $('#nrctremp').val();	  

	 $.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/atacor/manter_rotina.php',
		 data: {
			 nracordo: nracordo,			
			 cdcooper: cdcooper,
			 nrctremp: nrctremp,
			 operacao: operacao,
		 	 redirect: 'html_ajax'
		 },
		error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function (response) {			
			 $('#divUsoGenerico').html(response);
			 layoutPadrao();
			 hideMsgAguardo();
			 bloqueiaFundo($('#divUsoGenerico'));
             $('#nracordo', '#frmincctr').focus(); 			
		}
	});
}

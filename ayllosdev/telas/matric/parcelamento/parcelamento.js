/*!
 * FONTE        : parcelamento.js
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 15/07/2010 
 * OBJETIVO     : Biblioteca de funções da rotina Parcelamento da tela MATRIC
 */

function controlaLayoutParcelamento(operParc) {

	$('#divUsoGenerico').css({'width':'370px'});
	$('#divParcelamento').css({'height':'277px'});
	$('#frmParcelamento').css({'margin-bottom':'4px','padding-top':'3px'});
	$('label','#frmParcelamento').addClass('rotulo').css({'width':'150px'});
	
	$('#dtdebito','#frmParcelamento').css({'width':'70px'}).addClass('data');
	$('#vlparcel','#frmParcelamento').css('width','70px').addClass('moeda_6');
	$('#qtparcel','#frmParcelamento').css({'width':'25px'}).addClass('inteiro').attr('maxlength','2');	
	
	$('#dtdebito, #vlparcel, #qtparcel','#frmParcelamento').habilitaCampo();
		
	var tabParc = $('table', '#divParcelamento');
	
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];

	var arrayLargura = new Array();
	arrayLargura[0] = '50px';
	arrayLargura[1] = '100px';
	

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'right';

	tabParc.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
		
	layoutPadrao();
	$('#dtdebito','#frmParcelamento').focus();
	$('#divUsoGenerico').centralizaRotinaH();	
	return false;
}

function carregaDadosParcelamento(dtdebito,qtparcel,vlparcel,msgRetor,operParc) {
	
	$.ajax({		
		type	: 'POST', 
		dataType: 'html',
		async   : false ,
		url		: UrlSite + 'telas/matric/parcelamento/principal.php',
		data	: {
					nrdconta: nrdconta,
					operParc: operParc,
					dtdebito: dtdebito,
					qtparcel: qtparcel,
					vlparcel: vlparcel,
					msgRetor: msgRetor,
					redirect: 'html_ajax'
				},		
		error	: function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
				},
		success	: function(response) {
					if ( response.indexOf('showError("error"') == -1 ) {
						$('#divParcelamento').html(response);
						aux = true;
						return true;
					} else {
						eval( response );
						aux = false;
						controlaFoco();
						return false;
					}
					
				}				 
	});
	return aux;	
}

function finalizaParcelamento(){
	
	if( !validaParcelamento() ){ return false; }
		
	dtdebito = $('#dtdebito','#frmParcelamento').val();
	qtparcel = $('#qtparcel','#frmParcelamento').val();
	vlparcel = $('#vlparcel','#frmParcelamento').val();
	
		
	if ( carregaDadosParcelamento(dtdebito,qtparcel,vlparcel,msgRetor,'GP') ) {
		desabilitaCamposParc();
		hideMsgAguardo();
		showConfirmacao(msgRetParc,'Confirmação - PARCELAMENTO DO CAPITAL','exibeMsgRetorno();','habilitaCamposParc();bloqueiaFundo( $(\'#divUsoGenerico\') );','sim.gif','nao.gif');
		return false;
	}else{
		habilitaCamposParc();
		hideMsgAguardo();
		bloqueiaFundo(divError);
	}
	
return false;
}

function desabilitaCamposParc(){
	
	$('#dtdebito','#frmParcelamento').desabilitaCampo();
	$('#qtparcel','#frmParcelamento').desabilitaCampo();
	$('#vlparcel','#frmParcelamento').desabilitaCampo();
	
	return false;
}

function habilitaCamposParc(){
	
	$('#dtdebito','#frmParcelamento').habilitaCampo();
	$('#qtparcel','#frmParcelamento').habilitaCampo();
	$('#vlparcel','#frmParcelamento').habilitaCampo();
	
	return false;
}

function exibeMsgRetorno(){
	
	msgRetor = $('#msgRetor','#frmParcelamento').val();
	fechaRotina( $('#divUsoGenerico') );
	metodo = ( operacao == 'IV' ) ? 'controlaOperacao(\'VI\');' : 'controlaOperacao(\'VA\');'; 
	
	showConfirmacao(msgRetor,'Confirmação - MATRIC',metodo,'unblockBackground();','sim.gif','nao.gif');
	
}

function validaParcelamento(){
	
	$("input","#frmParcelamento").removeClass("campoErro");
	
	var dtdebito = $('#dtdebito','#frmParcelamento').val();
	var qtparcel = $('#qtparcel','#frmParcelamento').val();
	var vlparcel = $('#vlparcel','#frmParcelamento').val();
	
	//Data de inicio
	if ( !validaData( dtdebito ) ) { hideMsgAguardo();showError('error','Data inválida','Alerta - Aimaro','bloqueiaFundo( $(\'#divUsoGenerico\') ,\'dtdebito\',\'frmParcelamento\');'); return false; } 
	if ( dtdebito == '' ) { hideMsgAguardo();showError('error','Data inválida','Alerta - Aimaro','bloqueiaFundo( $(\'#divUsoGenerico\') ,\'dtdebito\',\'frmParcelamento\');'); return false; } 
	
	//Valor das parcelas
	if( vlparcel == '' || 	vlparcel <= 0 ){ hideMsgAguardo();showError('error','Valor a parcelar inválido','Alerta - Aimaro','bloqueiaFundo( $(\'#divUsoGenerico\') ,\'vlparcel\',\'frmParcelamento\');'); return false; } 
		
	//Quantidade de parcelas
	if( qtparcel == '' || qtparcel <= 0 ){ hideMsgAguardo();showError('error','Quantidade de parcelas inválida','Alerta - Aimaro','bloqueiaFundo( $(\'#divUsoGenerico\') ,\'qtparcel\',\'frmParcelamento\');'); return false; } 
		
	return true;
}
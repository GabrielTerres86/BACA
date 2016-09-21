/*!
 * FONTE        : confrp.js
 * CRIAÇÃO      : Lombardi (CECRED)
 * DATA CRIAÇÃO : Março/2016
 * OBJETIVO     : Biblioteca de funções da tela CONFRP
 */
 
function confirmar(qtdregis, idparame_reciproci, dslogcfg, cp_idparame_reciproci, cp_desmensagem, cp_deslogconfrp, executafuncao, divanterior) {

  var ls_configrp = "";
  var idindicador;
  var nmindicador;
  var tpindicador;
  var vlminimo;
  var vlmaximo;
  var perscore;
  var pertolera;
  var verifica_selecionados = false;
 
  if (converteNumero($('#perdesmax').val()) == "" || converteNumero($('#perdesmax').val()) < 0.01 || converteNumero($('#perdesmax').val()) > 100) {
    exibeMensagem("% M&aacute;ximo de Desconto Permitido ao C&aacute;lculo deve ser informado. Utilizar 0,01% a 100,00%!");
    return false;
  }
  
  for (var i = 0; i < qtdregis; i++){
    if ($('#ativo' + i).is(':checked')) {
	  if ( converteNumero($('#perscore' + i).val()) > 100 || 
		   converteNumero($('#perscore' + i).val()) < 0 || 
		   converteNumero($('#pertolera' + i).val()) > 100 || 
		   converteNumero($('#pertolera' + i).val()) < 0) {
		exibeMensagem($('#nmindicador' + i).val() + " - Percentuais informados devem estar na faixa de 0,00% a 100,00%!");
		return false;
	  }
	  if ($('#perscore' + i).val() == ""){
		  exibeMensagem($('#nmindicador' + i).val() + " - Percentual de Score n&atilde;o preenchido! Favor informar um valor na faixa de 0,00% a 100%!");
         return false;
	  } else if ($('#tpindicador' + i).val()[0] == "M" || $('#tpindicador' + i).val()[0] == "Q"){
	      if ($('#vlminimo' + i).val() == "" || converteNumero($('#vlminimo' + i).val()) < 0.01) {
		  exibeMensagem($('#nmindicador' + i).val() + " - Valor M&iacute;nimo inv&aacute;lido! Favor informar um valor superior a 0(zero) e inferior ao Valor M&aacute;ximo!");
		  return false;
		}
		if ($('#vlmaximo' + i).val() == ""){
		  exibeMensagem($('#nmindicador' + i).val() + " - Valor M&aacute;ximo inv&aacute;lido! Favor informar um valor superior ao Valor M&iacute;nimo!");
		  return false;
		}
	  }
      verifica_selecionados = true;
    }
  }
  
  if (!verifica_selecionados) {
    exibeMensagem("Pelo menos um indicador deve estar ativo e com todas as informa&ccedil;&otilde;es preenchidas!");  
    return false;
  }
      
  
  for (var i = 0; i < qtdregis; i++){
    if ($('#ativo' + i).is(':checked')) {
      if ($('#tpindicador' + i).val()[0] == "A" &&
         (($('#vlminimo' + i).val()  != "" && $('#vlminimo' + i).val() != "-") || 
          ($('#vlmaximo' + i).val()  != "" && $('#vlminimo' + i).val() != "-") || 
          ($('#pertolera' + i).val() != "" && $('#vlminimo' + i).val() != "-"))) {
            exibeMensagem($('#nmindicador' + i).val() + " - Indicador do tipo Ades&atilde;o s&oacute; permite o preenchimento do '%Score!");
        $('#vlminimo' + i).val("-");
        $('#vlmaximo' + i).val("-");
        $('#pertolera' + i).val("-");
        return false;
      }
      
      vlminimo    = converteMoedaFloat($('#vlminimo' + i).val());
      vlmaximo    = converteMoedaFloat($('#vlmaximo' + i).val());
      
      if ((vlminimo > vlmaximo) || (vlminimo < 0)){
        exibeMensagem($('#nmindicador' + i).val() + " - Valor M&iacute;nimo inv&aacute;lido! Favor informar um valor superior a 0(zero) e inferior ao Valor M&aacute;ximo!");
        return false;
      }
      
      if ((vlmaximo < vlminimo) || (vlmaximo < 0)){
        exibeMensagem($('#nmindicador' + i).val() + " - Valor M&aacute;ximo inv&aacute;lido! Favor informar um valor superior ao Valor M&iacute;nimo!");
        return false;
      }
      if($('#perscore' + i).val() < 0 || 
         $('#perscore' + i).val() > 100 || 
         $('#pertolera' + i).val() < 0 || 
         $('#pertolera' + i).val() > 100)
        exibeMensagem($('#nmindicador' + i).val() + " - Percentuais informados devem estar na faixa de 0,00% a 100,00%!");
    }
    ls_configrp += $('#ativo' + i).is(':checked') + ',';
    ls_configrp += converteNumero($('#idindicador' + i).val()) + ',';
    ls_configrp += $('#tpindicador' + i).val()[0] + ',';
    ls_configrp += converteNumero($('#vlminimo' + i).val()) + ',';
    ls_configrp += converteNumero($('#vlmaximo' + i).val()) + ',';
    ls_configrp += converteNumero($('#perscore' + i).val()) + ',';
    ls_configrp += converteNumero($('#pertolera' + i).val()) + ';';
  }
  
  showMsgAguardo('Aguarde, confirmando...');
  
  $.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/confrp/confirmar_config.php',
		data: {
             ls_configrp: ls_configrp.replace(/.$/, ''),
             perdesmax: converteNumero($('#perdesmax').val()),
             idparame_reciproci: idparame_reciproci,
             dslogcfg: dslogcfg,
             totaldesconto: $('#totaldesconto').val(),
             cp_idparame_reciproci: cp_idparame_reciproci,
             cp_desmensagem: cp_desmensagem,
             cp_deslogconfrp: cp_deslogconfrp,
		     executafuncao: executafuncao,
		     divanterior: divanterior,
             redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrercben','#divBeneficio').focus();");							
		},
		success: function(response) {			
				hideMsgAguardo();
        try {
          eval( response );						
        } catch(error) {						
          showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
				}
		}				
	}); 
}

function converteNumero (numero){
  return numero.replace('.','').replace(',','.');
}

function exibeMensagem(msg) {
  showError("inform",msg,"Alerta - Ayllos","bloqueiaFundo($('#divUsoGenerico'));","NaN");
}
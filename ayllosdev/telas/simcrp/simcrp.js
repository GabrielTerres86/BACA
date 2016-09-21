/*!
 * FONTE        : simcrp.js
 * CRIAÇÃO      : Lombardi (CECRED)
 * DATA CRIAÇÃO : Março/2016
 * OBJETIVO     : Biblioteca de funções da tela SIMCRP
 */
 
 $(document).ready(function() {
	
	//layoutPadrao();
	return false;
	
	});
 
 
 function confirmar(qtdregis, idparame_reciproci, idcalculo_reciproci, modo, cp_idcalculo, cp_desmensagem, cp_totaldesconto, executafuncao, divanterior) {
  showMsgAguardo('');
  var ls_vlcontrata = "";
  var contador = 0;
  var existe_M_Q = false;
  for (var i = 0; i < qtdregis; i++){
    if (($('#vlcontrata' + i).val() != "" && converteMoedaFloat($('#vlcontrata' + i).val()) > 0) || 
        ($('#perdesconto' + i).val() != "" && converteMoedaFloat($('#perdesconto' + i).val()) > 0)) {
      if ($('#tpindicador' + i).val()[0] == "M" || $('#tpindicador' + i).val()[0] == "Q") {
        ls_vlcontrata += $('#idindicador' + i).val() + ',' + $('#nmindicador' + i).val() + ',' + converteMoedaFloat($('#vlcontrata' + i).val()) + ';';
        existe_M_Q = true;
      }
      contador++;
    }
  }
  
  if (contador > 0 && existe_M_Q) {
    $.ajax({		
      type: 'POST', 
      url: UrlSite + 'telas/simcrp/busca_minmax.php',
      data: {
             ls_vlcontrata: ls_vlcontrata.replace(/.$/, ''),
             idcalculo: idcalculo_reciproci,
             idparame_reciproci: idparame_reciproci,
           redirect: 'html_ajax' // Tipo de retorno do ajax
      },		
      error: function(objAjax,responseError,objExcept) {
        hideMsgAguardo();
        showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrercben','#divBeneficio').focus();");							
        return false;
      },
      success: function(response) {
        if (response == "S") {
            confirma_dados(qtdregis, idparame_reciproci, idcalculo_reciproci, modo, cp_idcalculo, cp_desmensagem, cp_totaldesconto, executafuncao, divanterior);
        }else{
		  hideMsgAguardo();
          //exibeMensagem("Valor Contratado inv&aacute;lido! Favor informar um valor entre IPR.VLMINIMO a IPR.VLMAXIMO!");
		  exibeMensagem(response);
          return false;
        }
      }
    });
  } else {
    if (contador > 0) {
        confirma_dados(qtdregis, idparame_reciproci, idcalculo_reciproci, modo, cp_idcalculo, cp_desmensagem, cp_totaldesconto, executafuncao, divanterior);
    }else {
      hideMsgAguardo();
      exibeMensagem("Para o c&aacute;lculo da Reciprocidade voc&ecirc; deve preencher o campo \"Contratado\" para pelo menos um Indicador!");
    }
  }
}

 function confirma_dados(qtdregis, idparame_reciproci, idcalculo_reciproci, modo, cp_idcalculo, cp_desmensagem, cp_totaldesconto, executafuncao, divanterior) {
  var ls_registros = "";
  
  for (var i = 0; i < qtdregis; i++){
    if ($('#vlcontrata' + i).val() != "" && converteMoedaFloat($('#vlcontrata' + i).val()) > 0)
      ls_registros += '1,';
    else
      ls_registros += '0,';
    
    ls_registros += $('#idindicador' + i).val() + ',';
    ls_registros += $('#tpindicador' + i).val()[0] + ',';
    ls_registros += converteMoedaFloat($('#vlcontrata' + i).val()) + ',';
    ls_registros += converteMoedaFloat($('#perdesconto' + i).val()) + ',';
    ls_registros += converteMoedaFloat($('#pertolera' + i).val()) + ';';
  }
  
  $.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/simcrp/confirmar_simcrp.php',
		data: {  ls_vlcontrata: ls_registros.replace(/.$/, ''),
        idparame_reciproci: idparame_reciproci,
       idcalculo_reciproci: idcalculo_reciproci,
  qtdmes_retorno_reciproci: converteMoedaFloat($('#retorno_reciproci').val()),
        flgreversao_tarifa: converteMoedaFloat($('#reversao_tarifa').val()),
        flgdebito_reversao: converteMoedaFloat($('#debito_reajuste_reciproci').val()),
                      modo: modo,
             totaldesconto: $('#totaldesconto').val(),
              cp_idcalculo: cp_idcalculo,
            cp_desmensagem: cp_desmensagem,
          cp_totaldesconto: cp_totaldesconto,
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
  showError("inform",msg,'Alerta - Ayllos',"bloqueiaFundo($('#divUsoGenerico'));","NaN");
}

function preenche_desretorno(valor) {
  $.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/simcrp/preenche_desretorno.php',
		data: {
         valor: valor,
      redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrercben','#divBeneficio').focus();");							
		},
		success: function(response) {}				
	});
  return false;
}

function calculaTotalDesconto(qtdregis) {
  var totalDesconto = 0;
  
  for (var i = 0; i < qtdregis; i++) {
    totalDesconto += parseFloat(converteMoedaFloat($('#perdesconto' + i).val()));
  }
  $('#totaldesconto').val(number_format(totalDesconto,2,',','.'));
}

function emite_crrl713(nrdconta,idcalculo,idparame) {
  showMsgAguardo('Aguarde, Emitindo relat&oacute;rio das ultimas 12 ocorr&ecirc;ncias dos indicadores...');
  $.ajax({		
		type: 'POST', 
		url: UrlSite + 'telas/simcrp/emite_crrl713.php',
		data: {
      nrdconta: nrdconta,
     idcalculo: idcalculo,
      idparame: idparame,
      redirect: 'html_ajax' // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrercben','#divBeneficio').focus();");							
		},
		success: function(response) {
		  geraImpressao(response);
		  bloqueiaFundo($('#divUsoGenerico'));
		}				
	});
  return false;

}

function geraImpressao(arquivo) {
	
    $('#nmarquiv', '#frmImprimir').val(arquivo);
	
    var action = UrlSite + 'telas/simcrp/imprimir_pdf.php';
	
    carregaImpressaoAyllos("frmImprimir", action, "bloqueiaFundo($('#divUsoGenerico'));");	
}

function pct_desconto_indicador(posicao,idcalculo,idparame,qtdregis) {
  var idindicador = $('#idindicador' + posicao).val();
  var vlrbase = converteMoedaFloat($('#vlcontrata' + posicao).val());
  if ($('#tpindicador' + posicao).val()[0] == "A" && vlrbase == 0) {
      $('#perdesconto' + posicao).val('0,00');
      calculaTotalDesconto(qtdregis);
  }
  else {
      $.ajax({		
		    type: 'POST', 
		    url: UrlSite + 'telas/simcrp/pct_desconto_indicador.php',
		    data: {
           idcalculo: idcalculo,
           idparame: idparame,
           idindicador: idindicador,
           vlrbase: vlrbase,
          redirect: 'html_ajax' // Tipo de retorno do ajax
		    },		
		    error: function(objAjax,responseError,objExcept) {
			    showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","unblockBackground();");							
		    },
		    success: function(response) {
		      if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
			    try {
				    if (parseFloat(converteMoedaFloat(response)) < 100)
				        $('#perdesconto' + posicao).val(response);
				    else
					    $('#perdesconto' + posicao).val('100,00');
			      calculaTotalDesconto(qtdregis);
			    } catch(error) {						
			      showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
				    }
		      } else {
			    try {
			      eval( response );						
			    } catch(error) {						
			      showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
			    }
		      }
		    }				
        });
    }
  return false;
}
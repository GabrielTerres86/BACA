/*!
 * FONTE        : sol030.js
 * CRIAÇÃO      : Lucas Lombardi
 * DATA CRIAÇÃO : 05/08/2016
 * OBJETIVO     : Biblioteca de funções da tela SOL030
 * --------------
 * ALTERAÇÕES   : 14/06/2017 - Ajuste para inclusão da opção de prazo para desligamento (Jonata - RKAM P364).
 *				  
 *				  
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
	$('#divDetalhes').css({'display':'none'});
	$('#divFiltro').html('');

	$('#divBotoes', '#divTela').html('').css({'display':'block'});

	formataCabecalho();
	return false;

}

function controlaFoco() {
		
	$('#cddopcao','#frmCab').unbind('keypress').bind('keypress', function(e) {
		
		if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda') ) { return false; }
		
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			acessa_rotina();
			return false;
		}	
	});
	
	$('#btnOK','#frmCab').unbind('keypress').bind('keypress', function(e) {
		
		if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda') ) { return false; }
		
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			acessa_rotina();
			return false;
		}	
	});
	
	$('#btnOK','#frmCab').unbind('click').bind('click', function(){
	
		if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda') ) { return false; }		
		acessa_rotina();
		return false;			
	});
				
	return false;
	
}

function formataCabecalho() {

	$('input,select', '#frmCab').removeClass('campoErro');
	$('#divTela').css({'display':'inline'}).fadeTo(0,0.1);
	removeOpacidade('divTela');	

	cTodosCabecalho = $('input[type="text"],select','#frmCab'); 
	cTodosCabecalho.limpaFormulario();

	// cabecalho
	rCddopcao = $('label[for="cddopcao"]','#frmCab');

	cCddopcao = $('#cddopcao','#frmCab');

	//Rótulos
	rCddopcao.css('width','44px');

	//Campos	
	cCddopcao.css({'width':'496px'}).habilitaCampo().focus();
	
	// Esconde o campo tipo de cadastro
	$('#trTipoCadastro').hide();

	controlaFoco();
	layoutPadrao();

	return false;	

}

function acessa_rotina() {
	$('#cddopcao','#frmCab').desabilitaCampo();
	var cddopcao = $('#cddopcao','#frmCab').val();
	switch (cddopcao) {
		case 'D':
		case 'I':
			acessaDataInformativo(cddopcao);
			break;
		case 'C':
		case 'A':
			acessaCalculoSobras(cddopcao);
			break;
			
		case 'P':
		
			consultaPrazoDesligamento();
		
		break;
		
		case 'V':
		
			consultaValorMinimoCapitalTed();
		
		break;
		
		case 'G':
		
			apresentaFormFiltro();
			
		break;
		
	}
	return false;
}


function consultaPrazoDesligamento() {
	
	var cddopcao = $('#cddopcao','#frmCab').val();
		
    showMsgAguardo('Aguarde, carregando...');

	// Executa script atraves de ajax
    $.ajax({		
        type: 'POST',
        url: UrlSite + 'telas/sol030/consulta_prazo_desligamento.php',
        data: {
				cddopcao: cddopcao,
				redirect: 'html_ajax'			
              }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"estadoInicial()");
        },
        success: function(response) {
            hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divDetalhes').html(response);
					return false;
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				}
			} else {
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				}
			}
        }				
    });
	
    return false;
	
}

function alterarPrazoDesligamento() {
	
	var cddopcao = $('#cddopcao','#frmCab').val();
	var qtddias = $('#qtddias','#frmPrazoDesligamento').val();
	
	if( $('#flgNoAto','#frmPrazoDesligamento').prop('checked')){
		
		var tpprazo = 1;
		
	}else if( $('#flgAposAgo','#frmPrazoDesligamento').prop('checked')){
		
		var tpprazo = 2;
		
	}

	showMsgAguardo('Aguarde ...');

	// Executa script atraves de ajax
    $.ajax({		
        type: 'POST',
        url: UrlSite + 'telas/sol030/alterar_prazo_desligamento.php',
        data: {
				cddopcao : cddopcao,
				qtddias  : qtddias,
				tpprazo  : tpprazo,
				redirect: 'html_ajax'			
              }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"estadoInicial()");
        },
        success: function(response) {
            hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divDetalhes').html(response);
					return false;
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				}
			} else {
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				}
			}
        }				
    });
	
    return false;
	
}

function alterarValorMinimoTedCapital() {
	
	var cddopcao = $('#cddopcao','#frmCab').val();
	var vlminimo = isNaN(parseFloat($('#vlminimo', '#frmValorMinimoCapital').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vlminimo', '#frmValorMinimoCapital').val().replace(/\./g, "").replace(/\,/g, "."));
	
	$('input','#frmValorMinimoCapital').desabilitaCampo();
	
    showMsgAguardo('Aguarde, realizando opera&ccedil;&atilde;o...');

	// Executa script atraves de ajax
    $.ajax({		
        type: 'POST',
        url: UrlSite + 'telas/sol030/alterar_valor_minimo_ted_capital.php',
        data: {
				cddopcao : cddopcao,
				vlminimo : vlminimo,
				redirect: 'html_ajax'			
              }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"estadoInicial()");
        },
        success: function(response) {
            hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divDetalhes').html(response);
					return false;
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				}
			} else {
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				}
			}
        }				
    });
	
    return false;
	
}

function consultaValorMinimoCapitalTed() {
	
	var cddopcao = $('#cddopcao','#frmCab').val();
		
    showMsgAguardo('Aguarde, carregando...');

	// Executa script atraves de ajax
    $.ajax({		
        type: 'POST',
        url: UrlSite + 'telas/sol030/consulta_valor_minimo_capital_ted.php',
        data: {
				cddopcao: cddopcao,
				redirect: 'html_ajax'			
              }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"estadoInicial()");
        },
        success: function(response) {
            hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divDetalhes').html(response);
					return false;
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				}
			} else {
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				}
			}
        }				
    });
	
    return false;
	
}

function acessaDataInformativo(cddopcao) {
	
    showMsgAguardo('Aguarde, carregando...');

	// Executa script atraves de ajax
    $.ajax({		
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/sol030/form_data_informativo.php',
        data: {
				cddopcao: cddopcao,
				redirect: 'html_ajax'			
              }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
        },
        success: function(response) {
            hideMsgAguardo();
            $('#divDetalhes').html(response);
			formataDataInformativo(cddopcao);
        }				
    });
    return false;
}

function acessaCalculoSobras(cddopcao) {
	
    showMsgAguardo('Aguarde, carregando...');

    // Executa script atraves de ajax
    $.ajax({		
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/sol030/form_calculo_sobras.php',
        data: {
				cddopcao: cddopcao,
				redirect: 'html_ajax'			
              }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
        },
        success: function(response) {
            hideMsgAguardo();
            $('#divDetalhes').html(response);
			formataCalculoSobras(cddopcao);
        }				
    });
    return false;
}


function formataPrazoDesligamento(){

	highlightObjFocus( $('#frmPrazoDesligamento') );
	highlightObjFocus( $('#fsetDevolucaoCapital') );
	
	$('#fsetPrazoDesligamento').css({'border-bottom':'1px solid #777'});	
	$('#fsetDevolucaoCapital').css({'border-bottom':'1px solid #777'});	
	
	//Label do fsetPrazoDesligamento
	rFlgNoAto = $('label[for="flgNoAto"]','#frmPrazoDesligamento');
	rFlgAposAgo = $('label[for="flgAposAgo"]','#frmPrazoDesligamento');
	rQtddias = $('label[for="qtddias"]','#frmPrazoDesligamento');
	
	rFlgNoAto.addClass('radio').css({'width':'80px', 'text-align':'left'});
	rFlgAposAgo.addClass('radio').css({'width':'80px', 'text-align':'left'});
	rQtddias.addClass("rotulo").css('width','250px');
		  		
	//Campos do fsetPrazoDesligamento
	cFlgNoAto = $('#flgNoAto','#frmPrazoDesligamento');
	cFlgAposAgo = $('#flgAposAgo','#frmPrazoDesligamento');
	cQtddias = $('#qtddias','#frmPrazoDesligamento');
	
    cFlgNoAto.css({'width':'20px','padding-left':'120px'}).habilitaCampo();
	cFlgAposAgo.css({'width':'20px','padding-left':'120px'}).habilitaCampo();
	cQtddias.addClass('inteiro').css({'width':'120px'}).attr('maxlength','4').habilitaCampo();
	
	// Percorrendo todos os links
    $('input, select', '#frmPrazoDesligamento').each(function () {
		
		//Define ação para o campo
		$(this).unbind('keypress').bind('keypress', function (e) {

			$('input,select').removeClass('campoErro');
			
			if (divError.css('display') == 'block') { return false; }

			// Se é a tecla ENTER, TAB
			if (e.keyCode == 13 || e.keyCode == 9) {

				$(this).nextAll('.campo:first').focus();

				return false;
			}
			
		});
		
    });

    cFlgNoAto.unbind('change').bind('change', function () {

        if ($(this).prop('checked')) {

            $('#qtddias', '#frmPrazoDesligamento').val('0').desabilitaCampo();
            
        } else {

            $('#qtddias', '#frmPrazoDesligamento').habilitaCampo();

        }

        return false;

    });

    cFlgAposAgo.unbind('change').bind('change', function () {

        if ($(this).prop('checked')) {

            $('#qtddias', '#frmPrazoDesligamento').habilitaCampo();

        } else {

            $('#qtddias', '#frmPrazoDesligamento').val('0').desabilitaCampo();

        }

        return false;

    });
	
	layoutPadrao();
	
	$('#divDetalhes').css({'display':'block'});
	$('#frmPrazoDesligamento').css('display','block');
	$('#divBotoesPrazoDesligamento').css('display','block');
	
	cFlgNoAto.trigger("change");
	cFlgNoAto.focus();
	
	return false;
	
}

function formataValorMinimoCapital(){

	highlightObjFocus( $('#frmValorMinimoCapital') );
	
	$('#fsetValorMinimoCapital').css({'border-bottom':'1px solid #777'});
	
	//Label do fsetValorMinimoCapital
	rVlminimo = $('label[for="vlminimo"]','#frmValorMinimoCapital');
		
	rVlminimo.css('width','120px').addClass('rotulo');
	
	//Campos do fsetValorMinimoCapital
	cVlminimo = $('#vlminimo','#frmValorMinimoCapital');
	
    cVlminimo.css('width','200px').addClass('moeda').habilitaCampo();
	
	//Define ação para o campo vlminimo
    cVlminimo.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $('#btConcluir','#divBotoesValorMinimoCapital').click();

            return false;
        }

    });
	
	layoutPadrao();
	
	$('#divDetalhes').css({'display':'block'});
	$('#frmValorMinimoCapital').css('display','block');
	$('#divBotoesValorMinimoCapital').css('display','block');
	
	cVlminimo.focus();
	
	return false;
	
}


function formataCalculoSobras(cddopcao) {
	
	// labels
	rIncreret = $('label[for="increret"]','#frmCalculoSobras');
	rIndeschq = $('label[for="indeschq"]','#frmCalculoSobras');
	rIndestit = $('label[for="indestit"]','#frmCalculoSobras');
	rIndemiti = $('label[for="indemiti"]','#frmCalculoSobras');
	rUnsobdep = $('label[for="unsobdep"]','#frmCalculoSobras');
	rTxretorn = $('label[for="txretorn"]','#frmCalculoSobras');
	rTxjurapl = $('label[for="txjurapl"]','#frmCalculoSobras');
	rTxjursdm = $('label[for="txjursdm"]','#frmCalculoSobras');
	rTxjurtar = $('label[for="txjurtar"]','#frmCalculoSobras');
	rTxreauat = $('label[for="txreauat"]','#frmCalculoSobras');
	rTxjurcap = $('label[for="txjurcap"]','#frmCalculoSobras');
	rInpredef = $('label[for="inpredef"]','#frmCalculoSobras');
	rDssopfco = $('label[for="dssopfco"]','#frmCalculoSobras');
	rDssopjco = $('label[for="dssopjco"]','#frmCalculoSobras');
	
	// campos
	cIncreret = $('#increret','#frmCalculoSobras');
	cIndeschq = $('#indeschq','#frmCalculoSobras');
	cIndestit = $('#indestit','#frmCalculoSobras');
	cIndemiti = $('#indemiti','#frmCalculoSobras');
	cUnsobdep = $('#unsobdep','#frmCalculoSobras');
	cTxretorn = $('#txretorn','#frmCalculoSobras');
	cTxjurapl = $('#txjurapl','#frmCalculoSobras');
	cTxjursdm = $('#txjursdm','#frmCalculoSobras');
	cTxjurtar = $('#txjurtar','#frmCalculoSobras');
	cTxreauat = $('#txreauat','#frmCalculoSobras');
	cTxjurcap = $('#txjurcap','#frmCalculoSobras');
	cInpredef = $('#inpredef','#frmCalculoSobras');
	cDssopfco = $('#dssopfco','#frmCalculoSobras');
	cDssopfcc = $('#dssopfcc','#frmCalculoSobras');
	cDssopjco = $('#dssopjco','#frmCalculoSobras');
	cDssopjcc = $('#dssopjcc','#frmCalculoSobras');
	                 
	rIncreret.css('width','310px').addClass('rotulo');
	rIndeschq.css('width','310px').addClass('rotulo');
	rIndestit.css('width','310px').addClass('rotulo');
	rIndemiti.css('width','310px').addClass('rotulo');
	rUnsobdep.css('width','310px').addClass('rotulo');
	rTxretorn.css('width','310px').addClass('rotulo');
	rTxjurapl.css('width','310px').addClass('rotulo');
	rTxjursdm.css('width','310px').addClass('rotulo');
	rTxjurtar.css('width','310px').addClass('rotulo');
	rTxreauat.css('width','310px').addClass('rotulo');
	rTxjurcap.css('width','310px').addClass('rotulo');
	rInpredef.css('width','310px').addClass('rotulo');
	rDssopfco.css('width','310px').addClass('rotulo');
	rDssopjco.css('width','310px').addClass('rotulo');
	
	cIncreret.addClass('campo').css('width','50px');
	cIndeschq.addClass('campo').css('width','50px');
	cIndestit.addClass('campo').css('width','50px');
	cIndemiti.addClass('campo').css('width','50px');
	cUnsobdep.addClass('campo').css('width','50px');
	cTxretorn.addClass('campo inteiro').css('width','105px').setMask('DECIMAL','zz9,99999999',',','');
	cTxjurapl.addClass('campo inteiro').css('width','105px').setMask('DECIMAL','zz9,99999999',',','');
	cTxjursdm.addClass('campo inteiro').css('width','105px').setMask('DECIMAL','zz9,99999999',',','');
	cTxjurtar.addClass('campo inteiro').css('width','105px').setMask('DECIMAL','zz9,99999999',',','');
	cTxreauat.addClass('campo inteiro').css('width','105px').setMask('DECIMAL','zz9,99999999',',','');
	cTxjurcap.addClass('campo inteiro').css('width','105px').setMask('DECIMAL','zz9,99999999',',','');
	
	cInpredef.addClass('campo').css('width','90px');
	cDssopfco.addClass('campo inteiro').css('width','50px').setMask('DECIMAL','zz9,99',',','');
	cDssopfcc.addClass('campo inteiro').css('width','50px').setMask('DECIMAL','zz9,99',',','');
	cDssopjco.addClass('campo inteiro').css('width','50px').setMask('DECIMAL','zz9,99',',','');
	cDssopjcc.addClass('campo inteiro').css('width','50px').setMask('DECIMAL','zz9,99',',','');
	
	if (cddopcao == 'C') {
		cIncreret.desabilitaCampo();
		cIndeschq.desabilitaCampo();
		cIndestit.desabilitaCampo();
		cIndemiti.desabilitaCampo();
		cUnsobdep.desabilitaCampo();
		cTxretorn.desabilitaCampo();
		cTxjurapl.desabilitaCampo();
		cTxjursdm.desabilitaCampo();
		cTxjurtar.desabilitaCampo();
		cTxreauat.desabilitaCampo();
		cTxjurcap.desabilitaCampo();
		cInpredef.desabilitaCampo();
		cDssopfco.desabilitaCampo();
		cDssopjco.desabilitaCampo();
	}
	else{
		if (converteNumero($('#dssopfco','#frmCalculoSobras').val()) == 0)
			$('#dssopfco','#frmCalculoSobras').val(number_format(100,2,','));
		if (converteNumero($('#dssopjco','#frmCalculoSobras').val()) == 0)
			$('#dssopjco','#frmCalculoSobras').val(number_format(100,2,','));
	}
	
	highlightObjFocus( $('#frmCalculoSobras') );
	layoutPadrao();
	
	cDssopfcc.desabilitaCampo();
	cDssopjcc.desabilitaCampo();
	
	preencheDistribuicaoSobras();
	
	cDssopfco.keyup(function(e) {
		preencheDistribuicaoSobras();
		return false;
	});
	
	cDssopjco.keyup(function(e) {
		preencheDistribuicaoSobras();
		return false;
	});
	
	cInpredef.keyup(function(e) {
		preencheDistribuicaoSobras();
		return false;
	});
	
	$('#btVoltar','#frmCalculoSobras').keyup(function(e) {
		preencheDistribuicaoSobras();
		return false;
	});
	
	if (cddopcao == 'C') {
		$('#btAlterar','#frmCalculoSobras').css('visibility','hidden');
	} else {
		$('#btAlterar','#frmCalculoSobras').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				confirmaOpcao();
				return false;
			}	
		});
		
		$('#btAlterar','#frmCalculoSobras').unbind('click').bind('click', function(){
			confirmaOpcao();
			return false;			
		});
	}
	$('#btVoltar','#frmCalculoSobras').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			estadoInicial();
			return false;
		}	
	});
	
	$('#btVoltar','#frmCalculoSobras').unbind('click').bind('click', function(){
		estadoInicial();
		return false;			
	});
	
	$('#divDetalhes').css({'display':'block'});
	
	
	if (cddopcao == 'C') {
		$('#btVoltar','#frmCalculoSobras').focus();
	}else {
		$('#increret','#frmCalculoSobras').focus();
	}
	
	return false;	
}

function formataDataInformativo(cddopcao) {
	
	// labels
	rDtapinco = $('label[for="dtapinco"]','#frmDataInformativo');
	rDtapinco.css('width','310px').addClass('rotulo');
    
	// campos
	cDtapinco = $('#dtapinco','#frmDataInformativo');
	cDtapinco.css({'width':'72px','text-align':'right'}).addClass('campo inteiro').attr('maxlength','14').setMask("DATE","","","");
	
	highlightObjFocus( $('#frmDataInformativo') );
	layoutPadrao();
	
	
	cDtapinco.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			confirmaOpcao();
			return false;
		}	
	});
	
	$('#btAlterar','#frmDataInformativo').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			confirmaOpcao();
			return false;
		}	
	});
	
	$('#btAlterar','#frmDataInformativo').unbind('click').bind('click', function(){
		confirmaOpcao();
		return false;			
	});

	$('#btVoltar','#frmDataInformativo').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			estadoInicial();
			return false;
		}	
	});
	
	$('#btVoltar','#frmDataInformativo').unbind('click').bind('click', function(){
		estadoInicial();
		return false;			
	});
	
	$('#divDetalhes').css({'display':'block'});
	
	if (cddopcao == 'D') {
		cDtapinco.desabilitaCampo();
        $('#btAlterar', '#frmDataInformativo').css('visibility', 'hidden');
		$('#btVoltar','#frmDataInformativo').focus();
	}else {
		$('#dtapinco','#frmDataInformativo').focus();
	}
	
	return false;	
}

function confirmaOpcao(){
	var cddopcao = $('#cddopcao','#frmCab').val();
	var msgConfirm, funcaoSim, funcaoNao;
	switch(cddopcao){
		case 'I': // altera data informativo
			msgConfirm = 'Deseja alterar data informativo? ';
			funcaoSim = 'alteraDataInformativo();'
			funcaoNao = '$(\'#dtapinco\',\'#frmDataInformativo\').focus()';
			break;
		case 'A': // altera calculo sobras
			if ($('#inpredef','#frmCalculoSobras').val() == '0')
				msgConfirm = 'O calculo previo sera executado on-line. Deseja continuar?';
			else
				msgConfirm = 'Voce esta solicitando o processo DEFINITIVO. Este processo NAO TEM VOLTA. Confirme a operacao.';
			
			funcaoSim = 'alteraCalculoSobras();';
			funcaoNao = '$(\'#increret\',\'#frmCalculoSobras\').focus()';
			break;
	}
	
	showConfirmacao(msgConfirm,'Confirma&ccedil;&atilde;o - Ayllos',funcaoSim,funcaoNao,'sim.gif','nao.gif');
	return false;
}

function alteraDataInformativo(){
	
	dtapinco = $('#dtapinco','#frmDataInformativo').val();
	
	if (dtapinco == ''){
		showError('error','Data informada deve ser maior ou igual a data atual.','Alerta - Ayllos',"$('#dtapinco','#frmDataInformativo').focus();");
		return false;
	}
	
    showMsgAguardo('Aguarde, carregando...');

	// Executa script atraves de ajax
    $.ajax({		
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/sol030/altera_data_informativo.php',
        data: {
				dtapinco: dtapinco,
				redirect: 'html_ajax'			
              }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
        },
        success: function(response) {
            hideMsgAguardo();
            eval(response);
        }				
    });
    return false;
}

function alteraCalculoSobras(){
	
	ininccmi = $('#ininccmi','#frmCalculoSobras').val();
	increret = $('#increret','#frmCalculoSobras').val();
	txretorn = $('#txretorn','#frmCalculoSobras').val();
	txjurcap = $('#txjurcap','#frmCalculoSobras').val();
	txjurapl = $('#txjurapl','#frmCalculoSobras').val();
	txjursdm = $('#txjursdm','#frmCalculoSobras').val();
	txjurtar = $('#txjurtar','#frmCalculoSobras').val();
	txreauat = $('#txreauat','#frmCalculoSobras').val();
	inpredef = $('#inpredef','#frmCalculoSobras').val();
	indeschq = $('#indeschq','#frmCalculoSobras').val();
	indemiti = $('#indemiti','#frmCalculoSobras').val();
	unsobdep = $('#unsobdep','#frmCalculoSobras').val();
	indestit = $('#indestit','#frmCalculoSobras').val();
	dssopfco = $('#dssopfco','#frmCalculoSobras').val();
	dssopjco = $('#dssopjco','#frmCalculoSobras').val();
	
    showMsgAguardo('Aguarde, carregando...');

	// Executa script atraves de ajax
    $.ajax({		
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/sol030/altera_calculo_sobras.php',
        data: {
				ininccmi: ininccmi,
				increret: increret,
				txretorn: txretorn,
				txjurcap: txjurcap,
				txjurapl: txjurapl,
				txjursdm: txjursdm,
				txjurtar: txjurtar,
				txreauat: txreauat,
				inpredef: inpredef,
				indeschq: indeschq,
				indemiti: indemiti,
				unsobdep: unsobdep,
				indestit: indestit,
				dssopfco: dssopfco,
				dssopjco: dssopjco,
				redirect: 'html_ajax'			
              }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
        },
        success: function(response) {
            hideMsgAguardo();
            eval(response);
        }				
    });
    return false;
}

function calcula_retorno_sobras() {
	
    showMsgAguardo('Efetuando C&aacute;lculo .....');

	// Executa script atraves de ajax
    $.ajax({		
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/sol030/calcula_retorno_sobras.php',
        data: {
				redirect: 'html_ajax'			
              }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
        },
        success: function(response) {
            hideMsgAguardo();
            eval(response);
        }				
    });
    return false;
}

function preencheDistribuicaoSobras() {
	dssopfco = converteNumero($('#dssopfco','#frmCalculoSobras').val());
	dssopjco = converteNumero($('#dssopjco','#frmCalculoSobras').val());
	
	if (dssopfco > 100){
		dssopfco = 100;
		$('#dssopfco','#frmCalculoSobras').val(number_format(dssopfco,2,','));
	}
	if (dssopjco > 100) {
		dssopjco = 100;
		$('#dssopjco','#frmCalculoSobras').val(number_format(dssopjco,2,','));
	}
	$('#dssopfcc','#frmCalculoSobras').val(number_format(100 - dssopfco,2,','));
	$('#dssopjcc','#frmCalculoSobras').val(number_format(100 - dssopjco,2,','));
}

function converteNumero (numero){
  return Number(numero.replace('.','').replace(',','.'));
}


function buscarContasRateioTedCapital(nriniseq,nrregist) {

	var cddopcao = $('#cddopcao','#frmCab').val();
	var flctadst = $('#flctadst','#frmFiltro').val();
	
	$('select','#frmFiltro').desabilitaCampo();
	$('#divBotoesFiltro').css('display','none');
	
    showMsgAguardo("Aguarde, buscando contas ...");

	$('input,select').removeClass('campoErro');
	
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/sol030/buscar_contas_rateio_ted_capital.php",
        data: {
			cddopcao: cddopcao,
			flctadst: flctadst,
			nriniseq: nriniseq,
            nrregist: nrregist,
			redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "estadoInicial();");
        },
        success: function (response) {

			hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divDetalhes').html(response);
					return false;
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				}
			} else {
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				}
			}
			
        }

    });

    return false;

}



function formataFormContas(tpoperac){

	$('#fsetContas').css({'border-bottom':'1px solid #777'});	
	$('#fsetDestino').css({'border-bottom':'1px solid #777'});	
	
	var cTodosDados = $('input[type="text"],select','#fsetDestino');

	cTodosDados.desabilitaCampo();

	var rNrconta_dest = $('label[for="nrconta_dest"]','#fsetDestino');
	var rCdbanco_dest = $('label[for="cdbanco_dest"]','#fsetDestino');
	var rCdagenci_dest = $('label[for="cdagenci_dest"]','#fsetDestino');
	var rDsagenci_dest = $('label[for="dsagenci_dest"]','#fsetDestino');
	var rDsbanco_dest = $('label[for="dsagenci_dest"]','#fsetDestino');
	var rNrcpfcgc_dest = $('label[for="nrcpfcgc_dest"]','#fsetDestino');
	var rNmtitular_dest = $('label[for="nmtitular_dest"]','#fsetDestino');
	var rInsit_autoriza = $('label[for="insit_autoriza"]','#fsetDestino');

	rNrconta_dest.css({'width':'70px'}).addClass('rotulo');
	rNmtitular_dest.addClass('rotulo-linha');
	rNrcpfcgc_dest.css({'width':'70px'}).addClass('rotulo');	
	rCdbanco_dest.css({'width':'70px'}).addClass('rotulo');
	rDsbanco_dest.css({'width':'262px'}).addClass('rotulo-linha');
	rCdagenci_dest.css({'width':'70px'}).addClass('rotulo');
	rDsagenci_dest.css({'width':'262px'}).addClass('rotulo-linha');
	rInsit_autoriza.css({'width':'70px'}).addClass('rotulo-linha');
	
	
	var cNrconta_dest   = $('#nrconta_dest','#fsetDestino');
	var cNrdigito_dest   = $('#nrdigito_dest','#fsetDestino');
	var cCdbanco_dest   = $('#cdbanco_dest','#fsetDestino');
	var cDsbanco_dest   = $('#dsbanco_dest','#fsetDestino');
	var cCdagenci_dest  = $('#cdagenci_dest','#fsetDestino');
	var cDsagenci_dest  = $('#dsagenci_dest','#fsetDestino');
	var cNrcpfcgc_dest  = $('#nrcpfcgc_dest','#fsetDestino');
	var cNmtitular_dest =  $('#nmtitular_dest','#fsetDestino');
	var cInsit_autoriza = $('#insit_autoriza','#fsetDestino');

	cNrconta_dest.css({'width':'100px'}).attr('maxlength','10').addClass('inteiro');  
	cNrdigito_dest.css({'width':'40px'}).attr('maxlength','1').addClass('inteiro');  
	cCdbanco_dest.css({'width':'100px'}).attr('maxlength','5').addClass('inteiro');    
	cDsbanco_dest.css({'width':'375px'}).attr('maxlength','55').addClass('alphanum');    
	cCdagenci_dest.css({'width':'100px'}).attr('maxlength','5').addClass('inteiro');   
	cDsagenci_dest.css({'width':'375px'}).attr('maxlength','55').addClass('alphanum');   
	cNrcpfcgc_dest.css({'width':'145px'}).attr('maxlength','18').addClass('inteiro');   
	cNmtitular_dest.css({'width':'290px'}).attr('maxlength','55').addClass('alphanum');  
	cInsit_autoriza.css({'width':'100px'}).attr('maxlength','20').addClass('alphanum');  
	
	highlightObjFocus( $('#fsetDestino') );

	layoutPadrao();
		
	return false;
	
}


//Funcao para formatar a tabela com as contas demitidas
function formataTabelaContasRateioTedCapital(){

	var divRegistro = $('div.divRegistros');		
	var tabela      = $('table',divRegistro );	
	var linha		= $('table > tbody > tr', divRegistro );
									
	divRegistro.css({ 'height': '150px', 'width' : '100%'});
			
	var ordemInicial = new Array();
    ordemInicial = [[0, 0]];
					
	var arrayLargura = new Array(); 
	    arrayLargura[0] = '20%';
	    arrayLargura[1] = '50%';
							
	var arrayAlinha = new Array();
		arrayAlinha[0] = 'right';
		arrayAlinha[1] = 'left';
		arrayAlinha[2] = 'right';				
	
	tabela.formataTabela(ordemInicial,arrayLargura,arrayAlinha);
		
	//Seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		
		selecionaRegistro($(this));	
		
	});			
	
	$('table > tbody > tr', divRegistro).focus(function () {
		
		selecionaRegistro($(this));	

	});

	//Deixa o primeiro registro ja selecionado
	$('table > tbody > tr', divRegistro).each(function (i) {

		if ($(this).hasClass('corSelecao')) {

			selecionaRegistro($(this));	

		}

	});
	
	$('#divRegistros').css('display','block');
	$('#divRegistrosRodape','#divDetalhes').formataRodapePesquisa();		
		
	return false;
	
}


function selecionaRegistro(linha){
	
	$('#nrconta_dest','#fsetDestino').val($('#nrconta_dest',linha).val());
	$('#nrdigito_dest','#fsetDestino').val($('#nrdigito_dest',linha).val());
	$('#nmtitular_dest','#fsetDestino').val($('#nmtitular_dest',linha).val());
	$('#nrcpfcgc_dest','#fsetDestino').val($('#nrcpfcgc_dest',linha).val());
	$('#cdbanco_dest','#fsetDestino').val($('#cdbanco_dest',linha).val());
	$('#dsbanco_dest','#fsetDestino').val($('#dsbanco_dest',linha).val());
	$('#cdagenci_dest','#fsetDestino').val($('#cdagenci_dest',linha).val());
	$('#dsagenci_dest','#fsetDestino').val($('#dsagenci_dest',linha).val());
	$('#insit_autoriza','#fsetDestino').val($('#insit_autoriza',linha).val());
	
	return false;
}


function gerarTedRateioCapital() {
	
	var cddopcao = $('#cddopcao','#frmCab').val();
	
	showMsgAguardo('Aguarde, realizando opera&ccedil;&atilde;o...');

	// Executa script atraves de ajax
    $.ajax({		
        type: 'POST',
        url: UrlSite + 'telas/sol030/gerar_ted_rateio_capital.php',
        data: {
				cddopcao : cddopcao,
				redirect: 'html_ajax'			
              }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"estadoInicial()");
        },
        success: function(response) {
            hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divRotina').html(response);
					return false;
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				}
			} else {
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				}
			}
        }				
    });
	
    return false;
	
}


function formataTabelaContasTedCapital() {

	var divRegistro = $('div.divRegistros','#divRotina');		
	var tabela      = $('table',divRegistro );	
	var linha		= $('table > tbody > tr', divRegistro );
									
	divRegistro.css({'height':'150px'});
			
	var ordemInicial = new Array();
					
	var arrayLargura = new Array(); 
		arrayLargura[0] = '100px';
		arrayLargura[1] = '500px';
							
	var arrayAlinha = new Array();
		arrayAlinha[0] = 'right';
		arrayAlinha[1] = 'left';
		arrayAlinha[2] = 'right';
				
	var metodoTabela = '';
				
	tabela.formataTabela(ordemInicial,arrayLargura,arrayAlinha,metodoTabela);	
	
	$('#divBotoesInconsistencias').css('display','block');
	$('#divRegistros','#divRotina').css('display','block');
	$('#divRegistrosRodape','#frmInconsistencias').formataRodapePesquisa();		
	
	return false;
	
}

function apresentaFormFiltro() {
		
	var cddopcao = $('#cddopcao','#frmCabMincap').val(); 
	
	showMsgAguardo('Aguarde...');		
		
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/sol030/form_filtro.php', 
		data: {			 
			cddopcao: cddopcao,
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"estadoInicial();");
		},
		success: function(response) {
			hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divFiltro').html(response);
					return false;
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial()');
				}
			} else {
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				}
			}
		}				
	});
	
	return false;
	
}

function formataFormFiltro(){

	$('#frmFiltro').css({'display':'block'});	
	$('#fsetFiltro').css({'border-bottom':'1px solid #777'});	

	var rFlctadst = $('label[for="flctadst"]','#fsetFiltro');

	rFlctadst.css({'width':'140px'}).addClass('rotulo');
		
	var cFlctadst = $('#flctadst','#fsetFiltro');

	cFlctadst.css({'width':'120px'}).addClass('alphanum').habilitaCampo();

	highlightObjFocus( $('#fsetFiltro') );

	$('#divBotoesFiltro').css('display','block');
	layoutPadrao();
		
	cFlctadst.focus();
	
	return false;
	
}

function controlaVoltar(ope){
	
	switch (ope){
		
		case '1':
		
			estadoInicial();
		break;
		
		case '2':
		
			$('#divDetalhes').html('');
			apresentaFormFiltro();
		
		break;
		
		
	}
	
	return false;
	
}
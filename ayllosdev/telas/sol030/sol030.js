/*!
 * FONTE        : sol030.js
 * CRIAÇÃO      : Lucas Lombardi
 * DATA CRIAÇÃO : 05/08/2016
 * OBJETIVO     : Biblioteca de funções da tela SOL030
 * --------------
 * ALTERAÇÕES   : 
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
	}
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
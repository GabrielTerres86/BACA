/*!
 * FONTE        : concap.js
 * CRIAÇÃO      : Lucas R.
 * DATA CRIAÇÃO : Novembro/2013
 * OBJETIVO     : Biblioteca de funções da tela CONCAP
 * --------------
 * ALTERAÇÕES   :
 * 001: 29/01/2014 - Ajuste de layout para opção "F" (David)
 * --------------
 */
 
 var rCdagenci, rVltotapl, rVltotrgt, rVlcapliq, rDtmvtolt, rOpcaoimp,
     cCdagenci, cVltotapl, cVltotrgt, cVlcapliq, cDtmvtolt, cOpcaoimp;
	 
 var btnOK;
 var cCampos, cCamposOperacao;
 


$(document).ready(function() {

	estadoInicial();
	
});


function estadoInicial() {
	
	$('#divOpcaoT').css({'display':'none'});
	$('#divOperacao').css({'display':'none'});
	$('#divBotoes').css({'display':'none'});
	$('#div_tabOpcaoT').css({'display':'none'});
	$('#divRegistros').css({'display':'none'});
	$('#divPesquisaRodape').css({'display':'none'});
	
	controlaLayout();
	
	controlaFoco();
	$('#divCab').css({'display':'block'});
	$('#cddopcao','#frmCab').habilitaCampo().focus();

}

function controlaLayout() {

	// CAMPOS frmCab
	rCddopcao			= $('label[for="cddopcao"]'	,'#frmCab');
    cCddopcao			= $('#cddopcao'	,'#frmCab');
	btnOK				= $('#btnOK','#frmCab');
	
	//CAMPOS frmOperacao
	rCdagenci           = $('label[for="cdagenci"]' ,'#frmOperacao');
	rDtmvtolt           = $('label[for="dtmvtolt"]' ,'#frmOperacao');
	rOpcaoimp           = $('label[for="opcaoimp"]' ,'#frmOperacao');
	
	cCdagenci           = $('#cdagenci' ,'#frmOperacao');
	cDtmvtolt           = $('#dtmvtolt' ,'#frmOperacao');
	cOpcaoimp           = $('#opcaoimp' ,'#frmOperacao');
	
	//CAMPOS frmOpcaoT
	rVltotapl           = $('label[for="vltotapl"]' ,'#frmOpcaoT');
	rVltotrgt			= $('label[for="vltotrgt"]' ,'#frmOpcaoT');
	rVlcapliq			= $('label[for="vlcapliq"]' ,'#frmOpcaoT');
		
    cVltotapl           = $('#vltotapl' ,'#frmOpcaoT');
	cVltotrgt			= $('#vltotrgt' ,'#frmOpcaoT');
	cVlcapliq			= $('#vlcapliq' ,'#frmOpcaoT');
		
	cCampos             = $('input' , '#frmOperacao', '#frmOpcaoT');
	cCamposOperacao     = $('input' , '#frmOperacao'); 
	
	rCddopcao.addClass('rotulo').css({'width':'60px'});
	cCddopcao.css({'width':'430px'});
	
	highlightObjFocus($('#frmOperacao'));
	highlightObjFocus($('#frmOpcaoT'));
	
	//CAMPOS frmOpcaoT
	rVltotapl.addClass('rotulo').css({'width':'150px'});
	rVltotrgt.addClass('rotulo-linha').css({'width':'150px'});
	rVlcapliq.addClass('rotulo').css({'width':'150px'});
	
	cVltotapl.addClass('monetario').css({'width':'130px'});
	cVltotrgt.addClass('monetario').css({'width':'130px'});
	cVlcapliq.addClass('monetario').css({'width':'130px'});
	
	// Se clicar no botao OK
	btnOK.unbind('click').bind('click', function() {
	
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( cCddopcao.hasClass('campoTelaSemBorda') ) { return false; }
		
		if (  cCddopcao.val() == '' ) { return false; }

		//controlaLayout();
        $('#divBotoes').css({'display':'block'});
		$('#divOperacao').css({'display':'block'});
		
		cCddopcao.desabilitaCampo();
		
		//CAMPOS frmOperacao
		rCdagenci.addClass('rotulo').css({'width':'40px'});
		rDtmvtolt.addClass('rotulo-linha').css({'width':'70px'});
		rOpcaoimp.addClass('rotulo-linha').css({'width':'50px'});
		
		cCdagenci.addClass('campo').css({'width':'85px'}).setMask('INTEGER','zz9');	
		cDtmvtolt.addClass('campo').css({'width':'85px'});
		cOpcaoimp.addClass('campo').css({'width':'180px'});
		
		cDtmvtolt.desabilitaCampo();
		cCdagenci.focus();
		
		if(cCddopcao.val() == 'T') {
			controlaBotoes(1);
		}
		else{
			controlaBotoes(2);
		}	
	
		return false;
	});
	
	layoutPadrao();

	return false;
	
}

function controlaBotoes(seq) {
	
	if (seq == 1){ // Voltar Continuar
        $('#divBotoes').css({'display':'block'});
        $('#btVoltar'    ,'#divBotoes').show();
        $('#btnContinuar','#divBotoes').show();

        $('#btnImprimir' ,'#divBotoes').hide();
				
		return false;
    }
	else if (seq == 2){ // Voltar Imprimir
        $('#divBotoes').css({'display':'block'});
        $('#btVoltar'    ,'#divBotoes').show();
        $('#btnImprimir','#divBotoes').show();

        $('#btnContinuar' ,'#divBotoes').hide();
				
		return false;
    }
	else if (seq == 3){ //Apenas Voltar
		$('#divBotoes').css({'display':'block'});
        $('#btVoltar'    ,'#divBotoes').show();
		
        $('#btnImprimir','#divBotoes').hide();
		$('#btnContinuar' ,'#divBotoes').hide();
		
		return false;
	}
}

function controlaFoco() {
	
	$('#cddopcao','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#btnOK','#frmCab').focus();
			return false;
		}	
	});
	
	$('#cdagenci','#frmOperacao').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#opcaoimp','#frmOperacao').focus();
			return false;
		}	
	});
	
	$('#opcaoimp','#frmOperacao').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			if (cCddopcao.val() == "T") {
				$('#btnContinuar','#divBotoes').focus();
			} else{
				$('#btnImprimir','#divBotoes').focus();
			}
			return false;
		}	
	});
	
}

function preValidar() {
	
	var cdagenci = $("#cdagenci","#frmOperacao").val();
    	
	if (cdagenci == ''){
		showError('error','Agência não informada.','Alerta - CONCAP','focaCampoErro(\'cdagenci\',\'frmOperacao\');');
		return false;
	}
	cCdagenci.removeClass('campoErro');	
			
}

function btnContinuar() {
	
	preValidar();
	
	if (cCddopcao.val() == 'T') {		
		
		consultar(1,30);
	}
	
}

function btnVoltar() {

	 if($('#divOpcaoT').css('display') == 'block'){
	 	$('#divOperacao').css({'display':'block'});
		$('#divBotoes').css({'display':'block'});
		
		$('#divOpcaoT').css({'display':'none'});		
		$('#div_tabOpcaoT').css({'display':'none'});
		controlaBotoes(1);
		cCamposOperacao.habilitaCampo();
		cDtmvtolt.desabilitaCampo();
		cOpcaoimp.habilitaCampo();
		cCdagenci.focus();
		controlaFoco();
	}
	else if($('#divOperacao').css('display') == 'block'){
			$('#divOperacao').css({'display':'none'});			
			$('#divOpcaoT').css({'display':'none'});
			$('#divBotoes').css({'display':'none'});
			$('#div_tabOpcaoT').css({'display':'none'});
			$('#divRegistros').css({'display':'none'});
			estadoInicial();		
			
		}
	else { estadoInicial(); }
		
	return false;
}

function geraImpressao() {

	showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Ayllos","btnImprimir();","hideMsgAguardo();","sim.gif","nao.gif");
	
}

function btnImprimir() {
	
	cddopcao = cCddopcao.val();
	cdagenci = cCdagenci.val();
	dtmvtolt = cDtmvtolt.val();
	opcaoimp = cOpcaoimp.val();
	
	$('#cddopcao','#frmImpressao').val( cddopcao );
	$('#cdagenci','#frmImpressao').val( cdagenci );
	$('#dtmvtolt','#frmImpressao').val( dtmvtolt );
	$('#opcaoimp','#frmImpressao').val( opcaoimp );
	
	
	var action    = UrlSite + 'telas/concap/impressao.php';	
	var callafter = "bloqueiaFundo(divRotina);hideMsgAguardo();";
	
	carregaImpressaoAyllos("frmImpressao",action,callafter);
	
}

function consultar(nriniseq, nrregist) {

	$('#divOpcaoT').css({'display':'block'});
	$('#div_tabOpcaoT').css({'display':'block'});
	
	cddopcao = cCddopcao.val();
	cdagenci = cCdagenci.val();
	dtmvtolt = cDtmvtolt.val();
	opcaoimp = cOpcaoimp.val();
	
	cCdagenci.desabilitaCampo();
	cOpcaoimp.desabilitaCampo();
	
	cVltotapl.desabilitaCampo();
	cVltotrgt.desabilitaCampo();
	cVlcapliq.desabilitaCampo();
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, executando a pesquisa ...");

	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/concap/consulta.php", 
		data: {
			cddopcao: cddopcao, 
			cdagenci: cdagenci,
			dtmvtolt: dtmvtolt,
			opcaoimp: opcaoimp,
			nriniseq: nriniseq,
			nrregist: nrregist,
			redirect: "html_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {  
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();
				$('#div_tabOpcaoT').html(response);
				$('#divPesquisaRodape','#div_tabOpcaoT').formataRodapePesquisa();
				layoutConsulta(opcaoimp);
				controlaBotoes(3);
                return false;
			} catch(error) {
				hideMsgAguardo(); 
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}
	});
	
}

function layoutConsulta(opcaoimp) {
	
/*	altura  = '195px';
	largura = '425px';	*/
	
	altura  = '195px';
	largura = '800px';	
	

	// Configurações da tabela
	var divRegistro = $('div.divRegistros');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
		
	divRegistro.css('height','200px');
	divRegistro.css('width','800px');
		
	var ordemInicial = new Array();
	    		
	var arrayLargura = new Array();
		arrayLargura[0] = '30px'; 
		arrayLargura[1] = '60px'; 
		arrayLargura[2] = '310px';
		arrayLargura[3] = '60px'; 
		arrayLargura[4] = '90px'; 
		arrayLargura[5] = '170px'; 
		//88	
	/* PA conta nome aplicacao valorapli operador */
	
	var arrayAlinha = new Array();
		arrayAlinha[0] = 'right';
		arrayAlinha[1] = 'right';
		arrayAlinha[2] = 'left';
		arrayAlinha[3] = 'right';
		arrayAlinha[4] = 'right';
		arrayAlinha[5] = 'left';
		
	if (opcaoimp == "F") {
	 /*
		arrayLargura[0] = '40px';
		arrayLargura[1] = '80px';
		arrayLargura[2] = '180px';
		arrayLargura[3] = '63px';
		arrayLargura[4] = '100px';
        arrayLargura[5] = '75px';		
		arrayLargura[6] = '63px'; */
		
		arrayLargura[0] = '30px'; 
		arrayLargura[1] = '60px'; 
		arrayLargura[2] = '256px';
		arrayLargura[3] = '60px'; 
		arrayLargura[4] = '90px'; 
		arrayLargura[5] = '157px';		
		arrayLargura[6] = '63px';
		arrayAlinha[6]  = 'center';
	}
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );		
			
	divRotina.css('width',largura);	
	$('#divRotina').css({'height':altura,'width':largura});
	
	layoutPadrao();	
	hideMsgAguardo();
	removeOpacidade('#divRegistros');
}
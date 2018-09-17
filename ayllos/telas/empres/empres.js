/*********************************************************************************************
 Fonte: empres.php                                      			                    
 Autor: Michel Candido                                                                 
 Data : Novembro/2013                                                                  
 -----------
 Alterações: 11/03/2014 - Ajustes para deixar fonte no padrão, Softdesk - 130006 (Lucas R)
			 
			 30/12/2014 - Padronizando a mascara do campo nrctremp.
					      10 Digitos - Campos usados apenas para visualização
				    	  8 Digitos - Campos usados para alterar ou incluir novos contratos
					      (Kelvin - SD 233714)
             
             27/04/2016 - Ajustes no layout da tela, conforme solicitado no chamado 438581.
                          (Kelvin)
------------ 
**********************************************************************************************/

var nomeTitulo = 'EMPRES';

//Labels/Campos do cabeçalho
var rNrdonta, rNmprimtl, rCdtipsfx, rDtate, rNrctremp, 
	cNrdconta, cNmprimtl, cCdtipsfx, cDtate, cNrctremp, cTodosCabecalho;

	//Labels/CAmpos do formulario de emprestimo
var rCdpesqui,	rVlemprst,	rTxdjuros,	rVlsdeved,	rVljurmes,	rVlpreemp,	rVljuracu,	rVlprepag,	rQtmesdec,	rVlpreapg,	rDsdpagto,	rQtprecal,
	rDslcremp,	rQtpreapg,	rDsfinemp,	rNrctaav1,	rCpfcgc1,	rNmdaval1,	rNrraval1,	rNrctaav2,	rCpfcgc2,	rNmdaval2,	rNrraval2,
	cCdpesqui,	cVlemprst,	cTxdjuros,	cVlsdeved,	cVljurmes,	cVlpreemp,	cVljuracu,	cVlprepag,	cQtmesdec,	cVlpreapg,	cDsdpagto,	cQtprecal,
	cDslcremp,	cQtpreapg,	cDsfinemp,	cNrctaav1,	cCpfcgc1,	cNmdaval1,	cNrraval1,	cNrctaav2,	cCpfcgc2,	cNmdaval2,	cNrraval2,	cTodosFrmEmprestimo;

$(document).ready(function(){

	estadoInicial();
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px',width:'620px'});

});

function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);
	$('#frmCab').css({'display':'block'});
	$('#frmEmprestimo').css({'display':'none'});
	$('#divBotoes').css({'display':'block'});
	$('#btVoltar','#divBotoes').hide();
	$('#btSalvar','#divBotoes').show();

	//atribui destaque aos campos do formulario
	highlightObjFocus($('#frmCab'));
	formataCabecalho();	
	removeOpacidade('divTela'); 
}

function limpaCampos(){
	cNmprimtl.limpaFormulario();
	cCdtipsfx.limpaFormulario();
	cNrdconta.limpaFormulario();
	cDtate.limpaFormulario();
	cNrctremp.limpaFormulario();
}

function formataCabecalho(){
	
	cTodosCabecalho = $('input[type="text"]','#frmCab');
	cTodosCabecalho.desabilitaCampo();
	cTodosCabecalho.limpaFormulario();

	/*rotulo*/
	rNrdconta   = $('label[for="nrdconta"]','#frmCab');
	rNmprimtl   = $('label[for="nmprimtl"]','#frmCab');
	rCdtipsfx	= $('label[for="cdtipsfx"]','#frmCab');
	rNrctremp   = $('label[for="nrctremp"]','#frmCab');
	rDtate 	    = $('label[for="dtAte"]','#frmCab');

	rNmprimtl.css({width:'45px'});
	rCdtipsfx.css({width:'30px'});
	rDtate.css({width:'246px'});
	
	/* campos Form */
	cNmprimtl   = $('#nmprimtl','#frmCab');
	cCdtipsfx   = $('#cdtipsfx','#frmCab');
	cNrdconta 	= $('#nrdconta','#frmCab');
	cDtate 		= $('#dtAte','#frmCab');
	cNrctremp   = $('#nrctremp','#frmCab');

	cNmprimtl.css({width:'280px'});
	cCdtipsfx.css({width:'29px'});
	cNrdconta.habilitaCampo().addClass('conta').css({width:'80px'}).focus();
	cNrctremp.addClass('contrato2');

	/*Ajustar formatação para o IE*/
	if ( $.browser.msie ) {
		cDtate.css({width:'86px'});
	}else {
		cDtate.css({width:'80px'});
	}

	//Remove a classe de Erro do form
	$('input,select', '#frmCab').removeClass('campoErro');
	$('input,select', '#frmEmprestimo').removeClass('campoErro');

	/* Foca Campo data ao teclar Enter no campo Contrato*/
	cNrctremp.unbind('keypress').bind('keypress', function(e) {
		
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cDtate.focus();
			return false;
		}
	}); 

	/*ao pressionar enter no campo conta*/
	cNrdconta.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			carregaContrato();
			return false;
		}
	}); 

	/*ao pressionar enter no campo data*/
	cDtate.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			carregaEmprestimo();
			return false;
		}
	}); 

	limpaCampos();
	formataFormularioEmprestimo();
	layoutPadrao();
	return false;
}

function controlaOperacao(){

	if(!cNrdconta.hasClass('campoTelaSemBorda')){ 
		carregaContrato();
	}else{
		if(cDtate.val()){
		carregaEmprestimo();
		}
	}
}

function formataFormularioEmprestimo(){

	cTodosFrmEmprestimo = $('input[type="text"]','#frmEmprestimo');
	cTodosFrmEmprestimo.desabilitaCampo();

	rCdpesqui  = $('label[for="cdpesqui"]','#frmEmprestimo');
	rVlemprst  = $('label[for="vlemprst"]','#frmEmprestimo')
	rTxdjuros  = $('label[for="txdjuros"]','#frmEmprestimo');
	rVlsdeved  = $('label[for="vlsdeved"]','#frmEmprestimo');
	rVljurmes  = $('label[for="vljurmes"]','#frmEmprestimo');
	rVlpreemp  = $('label[for="vlpreemp"]','#frmEmprestimo');
	rVljuracu  = $('label[for="vljuracu"]','#frmEmprestimo');
	rVlprepag  = $('label[for="vlprepag"]','#frmEmprestimo');
	rQtmesdec  = $('label[for="qtmesdec"]','#frmEmprestimo');
	rDsdpagto  = $('label[for="dsdpagto"]','#frmEmprestimo');
	rVlpreapg  = $('label[for="vlpreapg"]','#frmEmprestimo');  
	rQtprecal  = $('label[for="qtprecal"]','#frmEmprestimo');
	rDslcremp  = $('label[for="dslcremp"]','#frmEmprestimo');
	rQtpreapg  = $('label[for="qtpreapg"]','#frmEmprestimo');
	rDsfinemp  = $('label[for="dsfinemp"]','#frmEmprestimo');
	rNrctaav1  = $('label[for="nrctaav1"]','#frmEmprestimo');
	rCpfcgc1   = $('label[for="cpfcgc1"]','#frmEmprestimo');
	rNmdaval1  = $('label[for="nmdaval1"]','#frmEmprestimo');
	rNrraval1  = $('label[for="nrraval1"]','#frmEmprestimo');
	rNrctaav2  = $('label[for="nrctaav2"]','#frmEmprestimo');
	rCpfcgc2   = $('label[for="cpfcgc2"]','#frmEmprestimo');
	rNmdaval2  = $('label[for="nmdaval2"]','#frmEmprestimo');
	rNrraval2  = $('label[for="nrraval2"]','#frmEmprestimo');

	rCdpesqui.css({width:'120px'});
	rVlemprst.css({width:'120px'});
	rTxdjuros.css({width:'211px'});
	rVlsdeved.css({width:'120px'});
	rVljurmes.css({width:'211px'});
	rVlpreemp.css({width:'120px'});
	rVljuracu.css({width:'211px'});
	rVlprepag.css({width:'120px'});
	rQtmesdec.css({width:'211px'});
	rDsdpagto.css({width:'10px'});
	rVlpreapg.css({width:'120px'});
	rQtprecal.css({width:'120px'});
	rDslcremp.css({width:'125px'});
	rQtpreapg.css({width:'120px'});
	rDsfinemp.css({width:'125px'});
	rNrctaav1.css({width:'55px'});
	rCpfcgc1.css({width:''});
	rNmdaval1.css({width:''});
	rNrraval1.css({width:'55px'});
	rNrctaav2.css({width:'55px'});
	rCpfcgc2.css({width:''});
	rNmdaval2.css({width:''});
	rNrraval2.css({width:'55px'});
	
	cCdpesqui  = $('#cdpesqui','#frmEmprestimo');
	cVlemprst  = $('#vlemprst','#frmEmprestimo');
	cTxdjuros  = $('#txdjuros','#frmEmprestimo');
	cVlsdeved  = $('#vlsdeved','#frmEmprestimo');
	cVljurmes  = $('#vljurmes','#frmEmprestimo');
	cVlpreemp  = $('#vlpreemp','#frmEmprestimo');
	cVljuracu  = $('#vljuracu','#frmEmprestimo');
	cVlprepag  = $('#vlprepag','#frmEmprestimo');
	cQtmesdec  = $('#qtmesdec','#frmEmprestimo');
	cDsdpagto  = $('#dsdpagto','#frmEmprestimo');
	cVlpreapg  = $('#vlpreapg','#frmEmprestimo');
	cQtprecal  = $('#qtprecal','#frmEmprestimo');
	cDslcremp  = $('#dslcremp','#frmEmprestimo');
	cQtpreapg  = $('#qtpreapg','#frmEmprestimo');
	cDsfinemp  = $('#dsfinemp','#frmEmprestimo');
	cNrctaav1  = $('#nrctaav1','#frmEmprestimo');
	cRcpfAval1 = $('#cpfcgc1','#frmEmprestimo');
	cNmdaval1  = $('#nmdaval1','#frmEmprestimo');
	cNrraval1  = $('#nrraval1','#frmEmprestimo');
	cNrctaav2  = $('#nrctaav2','#frmEmprestimo');
	cCpfcgc2   = $('#cpfcgc2','#frmEmprestimo');
	cNmdaval2  = $('#nmdaval2','#frmEmprestimo');
	cNrraval2  = $('#nrraval2','#frmEmprestimo');
	
	cQtprecal.css({'text-align':'right', width: '90px'});
	cQtpreapg.css({'text-align':'right', width: '90px'});
	cQtmesdec.css('text-align','right');

	cTxdjuros.addClass('porcento_7').css('text-align','right');
	cVlemprst.addClass('moeda');
	cVlsdeved.addClass('moeda');
	cVljurmes.addClass('moeda').css('text-align','right');
	cVlpreemp.addClass('moeda');
	cVljuracu.addClass('moeda');
	cVlprepag.addClass('moeda');
	cVlpreapg.addClass('moeda');

	/*Ajustar formatação para o IE*/
	if ( $.browser.msie ) {
		cDsdpagto.css({width:'332px'});
		cCdpesqui.css({width:'476px'});
		cDslcremp.css({width:'259px'});
		cDsfinemp.css({width:'259px'});
		cNmdaval1.css({width:'185px'});
		cNmdaval2.css({width:'185px'});
	} else {
		cDsdpagto.css({width:'338px'});
		cCdpesqui.css({width:'488px'});
		cDslcremp.css({width:'270px'});
		cDsfinemp.css({width:'270px'});
		cNmdaval1.css({width:'195px'});
		cNmdaval2.css({width:'195px'});
	}

	cNrctaav1.css({width:'72px'}).addClass('conta');
	cRcpfAval1.css({width:'125px'}).css('text-align','right');
	cNrraval1.css({width:'97px'}).css('text-align','right');
	cNrctaav2.css({width:'72px'}).addClass('conta');
	cCpfcgc2.css({width:'125px'}).css('text-align','right');
	cNrraval2.css({width:'97px'}).css('text-align','right');

}

function carregaEmprestimo(){

	cTodosFrmEmprestimo.limpaFormulario();

	var nrdconta = normalizaNumero(cNrdconta.val());
	var nrctremp = normalizaNumero(cNrctremp.val());
	var dtcalcul = cDtate.val();

	showMsgAguardo("Aguarde, carregando ...");

	/* Valida data */
	if ($.trim(dtcalcul) != "") {
	if (!validaData(dtcalcul)){
	    hideMsgAguardo();
		showError('error','Data inv&aacute;lida.','Alerta - Ayllos',"focaCampoErro('dtAte', 'frmCab');");
		$("#dtAte","#frmCab").val("");
		return false;
	} }

	$.ajax({
		type: "POST",
		url: UrlSite + "telas/empres/busca_emprestimo.php",
		data: {
			nrdconta: nrdconta,
			nrctremp: nrctremp,
			dtcalcul: dtcalcul,
			busca:'emprestimo',
			redirect: "script_ajax" // Tipo de retorno do ajax
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) { 
				try {
					eval(response);
					hideMsgAguardo(); 
				} catch(error) {
					eval(response);
					hideMsgAguardo(); 
				}
			}else{
				try {
                    eval( response );
                } catch(error) {
                    hideMsgAguardo();                   
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
                }
			}
		},
		error: function(objAjax,responseError,objExcept) {
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#nrdconta','#frmCab').focus()");
		}
	}); 
}

function carregaContrato(){

	cNrctremp.limpaFormulario();
	cCdtipsfx.limpaFormulario();
	cNmprimtl.limpaFormulario();

	var nrdconta = normalizaNumero(cNrdconta.val());
	var nrctremp = normalizaNumero(cNrctremp.val());
	var dtcalcul = cDtate.val();

	showMsgAguardo("Aguarde, carregando ...");

	$.ajax({
		type: "POST",
		url: UrlSite + "telas/empres/busca_emprestimo.php", 
		data: {
			nrdconta: nrdconta,
			nrctremp: nrctremp,
			dtcalcul: dtcalcul,
			busca:'contrato',
			redirect: "script_ajax" // Tipo de retorno do ajax
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) { 
				try {
					eval(response);
					 hideMsgAguardo(); 
				} catch(error) {
					eval(response);
					hideMsgAguardo(); 
				}
			}else{
				try {
                    eval( response );
                } catch(error) {
                    hideMsgAguardo();                   
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
                }
			}
		},
		error: function(objAjax,responseError,objExcept) {
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#nrdconta','#frmCab').focus()");
		}
	}); 
}

function controlaPesquisa(pesquisa){

	switch(pesquisa){
		case '1':
			if(cNrdconta.hasClass('campoTelaSemBorda')){ return false; }
			return mostraPesquisaAssociado('nrdconta','frmCab','','carregaContrato()');
		break;
		case '2': 
			mostraContrato();
			return false;
		break;
	}
}

// contrato
function mostraContrato() {

	showMsgAguardo('Aguarde, buscando ...');

	// Executa script de confirmação através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/empres/contrato.php', 
		data: {
			redirect: 'html_ajax'
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			buscaContrato();
			return false;
		}
	}); 

	return false;  

}

function buscaContrato() {

	showMsgAguardo('Aguarde, buscando ...');

	var nrdconta = normalizaNumero( cNrdconta.val() );	

	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/empres/busca_contrato.php', 
		data: {
			nrdconta: nrdconta, 
			redirect: 'script_ajax'
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {

			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divConteudo').html(response);
					exibeRotina($('#divRotina'));
					formataContrato();
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			} else {
				try {
					eval( response );
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		}
	});
	return false;
}

function formataContrato() {

	var divRegistro = $('div.divRegistros','#divContrato');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

	divRegistro.css({'height':'120px','width':'500px'});

	var ordemInicial = new Array();
	ordemInicial = [[0,0]];

	var arrayLargura = new Array();
	arrayLargura[0] = '60px';
	arrayLargura[1] = '62px';
	arrayLargura[2] = '80px';
	arrayLargura[3] = '60px';
	arrayLargura[4] = '80px';
	arrayLargura[5] = '38px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'right';
	arrayAlinha[6] = 'right';

	var metodoTabela = 'selecionaContrato();';

	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );

	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );

	return false;
}

function selecionaContrato() {
	
	if ( $('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao') ) {
					
		$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				cNrctremp.val( $('#nrctremp', $(this) ).val() );
			}	
		});
	}

	fechaRotina($('#divRotina'));
	return false;
	
}

function btnVoltar(){

	cTodosFrmEmprestimo.limpaFormulario();
	estadoInicial();
	return false;
}
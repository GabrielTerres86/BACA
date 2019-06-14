/***********************************************************************
 Fonte: trfcop.js                                                  
 Autor: Gabriel                                                     
 Data : Setembro/2011                Última Alteração:  28/12/2012
                                                                   
 Objetivo  : Biblioteca de funções da tela TRFCOP.                 
                                                                   	 
 Alterações: 18/12/2012 - Inclusao efeito highlightObjFocus, inclusao funcao ControlaFocus()
			              alteracao tamanho campos para novo padrao de layout (Daniel).
			 
			 28/12/2012 - Tratar paginacao da listagem (Gabriel)      

			 14/03/2013 - Incluir nova informacao de Origem (Gabriel)		
************************************************************************/


var detalhes = new Array();
var cddopcao;
var cTodosCabecalho;
var dttransa;	


$(document).ready(function() {	

		highlightObjFocus( $('#frmTrfcop') );
		highlightObjFocus( $('#divOpcao_P') );
		
		ControlaFocus();
						
		$("#cddopcao","#frmTrfcop").unbind("change").bind("change",function(e) { 
	    
		if ($(this).val() == "L") {		
		
			cTodosCabecalho.habilitaCampo();
			
			$("#dttransa","#frmTrfcop").focus();
			$("#dttransa","#frmTrfcop").val(dttransa);
			
			$("#tpoperac","#frmTrfcop").val("1");
			$("#tpdenvio","#frmTrfcop").val("1");
			
			cddopcao = 'L1';
			
		} 
		else 
		if  ($(this).val() == "P") { 	
				
			cTodosCabecalho.val("");
			cTodosCabecalho.desabilitaCampo();
			
			$("#tpoperac","#frmTrfcop").val("1");
			$("#tpdenvio","#frmTrfcop").val("1");
			
			$("#cddopcao","#frmTrfcop").val("P");
			$("#cddopcao","#frmTrfcop").habilitaCampo();
			
			cddopcao = 'P1';
			
			consultaInicial();
			return false;
			
		}			
	});
	
	
	formataMsgAjuda('');
	cTodosCabecalho = $('input,select','#frmTrfcop');
	dttransa = $("#dttransa","#frmTrfcop").val();

	$("#dttransa","#frmTrfcop").setMask("DATE","99/99/9999","");	
	$("#dttransa","#frmTrfcop").focus();
	$("#vlaprcoo","#divOpcao_P").setMask("DECIMAL","zzz.zzz.zz9,99",",");	
	$("#cddopcao","#frmTrfcop").trigger("change");
	
	// $("#dttransa","#frmTrfcop").unbind();
	
});

function controlaLayout( nomeForm ) {

	if( nomeForm == 'divResultado' ){
		
		var divRegistro = $('div.divRegistros','#'+nomeForm);		
		var tabela      = $('table', divRegistro );
		
		tabela.zebraTabela(0);
						
		$('#'+nomeForm).css('width','100%');
		divRegistro.css('height','300px');
						
		var ordemInicial = new Array();
				
		var arrayLargura = new Array();
		arrayLargura[0] = '61px';
		arrayLargura[1] = '82px';
		arrayLargura[2] = '253px';
		arrayLargura[3] = '99px';
		arrayLargura[4] = '100px';
		
		if ( $.browser.msie ) {
			arrayLargura[0] = '60px';
			arrayLargura[1] = '80px';
			arrayLargura[2] = '330px';
			arrayLargura[3] = '100px';
			arrayLargura[4] = '100px';
		}
							
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'right';
		arrayAlinha[2] = 'center';
		arrayAlinha[3] = 'right';
								
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
		
		$('tbody > tr',tabela).each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				$(this).focus();		
			}
		});			
	}
	
}

function consultaInicial() {

	// Se ja ta numa opcao , retorna 
	if ($('#cddopcao','#frmTrfcop').hasClass('campoTelaSemBorda')) { return false; }
	
	
	$("#divBotoes").css('display','block'); 
	  
	manter_rotina(1);	
	
	return false;
	
}

function confirma () {

	var msgConfirma = "Deseja efetuar a altera&ccedil;&atilde;o do valor ?";
	
	showConfirmacao(msgConfirma,'Confirma&ccedil;&atilde;o - Ayllos','manter_rotina(1)','','sim.gif','nao.gif');

}


// Função para chamar a manter_rotina.php
function manter_rotina (nriniseq) { 	

	var dttransa = $("#dttransa","#frmTrfcop").val();
	var tpoperac = $("#tpoperac","#frmTrfcop").val();
	var tpdenvio = $("#tpdenvio","#frmTrfcop").val();
	var cdpacrem = $("#cdpacrem","#frmTrfcop").val();
	var vlaprcoo = $("#vlaprcoo","#divOpcao_P").val();
	var mensagem = '';
				
	switch (cddopcao) {
		case 'L1': 
		
		  mensagem = 'Aguarde, consultando as opera&ccedil;&otilde;es entre as cooperativas ...';	
		  		  
		  $("#divOpcao_L").html('');
		  $("#divOpcao_L").css("display","block");
		  $("#btProsseguir","#divBotoes").hide();
		  $("#btVoltar","#divBotoes").show();
	  	  
		  cTodosCabecalho.desabilitaCampo();
	
		  break;
		
		case 'P1':
		
			mensagem = 'Aguarde, consultando os dados ...';
		    
			$("#divOpcao_P").css("display","block");
			$("#btProsseguir","#divBotoes").show();
			$("#btVoltar","#divBotoes").show();
			
			cTodosCabecalho.desabilitaCampo();
		  
			break;
		
		case 'P2': 
		
		  mensagem = 'Aguarde, alterando os dados ...';
		  
		  break;
		  
		default:
		  mensagem = 'Aguarde, consultando ...';
		  break;
	}
	
	// Mostra mensagem de aguardo
	showMsgAguardo(mensagem);
		
	// Carrega dados da conta através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/trfcop/manter_rotina.php", 
		data: {
			cddopcao: cddopcao,
			dttransa: dttransa,
			tpoperac: tpoperac,
			tpdenvio: tpdenvio,
			vlaprcoo: vlaprcoo,
			nriniseq: nriniseq,
			cdpacrem: cdpacrem,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#tpoperac','#frmTrfcop').focus()");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();					
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#tpoperac','#frmTrfcop').focus()");				
			}
		}				
	}); 
}

function selecionaOpe(id) {

	$("#divOpcao_L").css("display","none");
	$("#divDetalhes_L").css("display","block");
		
	$("#cdagerem","#frmDetalheLog").val(detalhes[id].cdagerem);
	$("#cdagedst","#frmDetalheLog").val(detalhes[id].cdagedst);
	$("#nrctarem","#frmDetalheLog").val(detalhes[id].nrctarem);
	$("#nrctadst","#frmDetalheLog").val(detalhes[id].nrctadst);
	$("#nmprirem","#frmDetalheLog").val(detalhes[id].nmprirem);
	$("#nmpridst","#frmDetalheLog").val(detalhes[id].nmpridst);
	$("#nrcpfrem","#frmDetalheLog").val(detalhes[id].nrcpfrem);
	$("#nrcpfdst","#frmDetalheLog").val(detalhes[id].nrcpfdst);
	$("#dspacrem","#frmDetalheLog").val(detalhes[id].dspacrem);

}

// Mostrar a mensagem de Ajuda na tela
function formataMsgAjuda() {

var botoesMensagem = $('input','#divBotoes');
	botoesMensagem.css({'display':'none','float':'right','padding-left':'2px','margin-top':'0px'});		
	
}

function voltar () {

	if ( $("#divDetalhes_L").css("display") == "block" ) {
	
		$("#divDetalhes_L").css("display","none")
		$("#divOpcao_L").css("display","block");
		return;	
		
	}

	$("#divOpcao_P").css("display","none");
	$("#divOpcao_L").css("display","none");
	$("#divBotoes").css('display','none'); 
	
	$("#cddopcao","#frmTrfcop").val("L");	
	$("#cddopcao","#frmTrfcop").trigger("change");
	
	cTodosCabecalho.habilitaCampo();
	
	$("#dttransa","#frmTrfcop").focus();

}


function ControlaFocus() {

	$('#dttransa','#frmTrfcop').unbind('keypress').bind('keypress', function(e) {
	if ( e.keyCode == 9 || e.keyCode == 13 ) {	
		$("#tpoperac","#frmTrfcop").focus();
		return false;
	}	
	});	
	
	$('#tpoperac','#frmTrfcop').unbind('keypress').bind('keypress', function(e) {
	if ( e.keyCode == 9 || e.keyCode == 13 ) {	
		$("#tpdenvio","#frmTrfcop").focus();
		return false;
	}	
	});
	
	$('#tpdenvio','#frmTrfcop').unbind('keypress').bind('keypress', function(e) {
	if ( e.keyCode == 9 || e.keyCode == 13 ) {
		$("#cdpacrem","#frmTrfcop").focus();	
		return false;
	}	
	});
	
	$('#cdpacrem','#frmTrfcop').unbind('keypress').bind('keypress', function(e) {
	if ( e.keyCode == 9 || e.keyCode == 13 ) {
		consultaInicial();
		return false;
	}	
	});
	
	$('#cddopcao','#frmTrfcop').unbind('keypress').bind('keypress', function(e) {
	if ( e.keyCode == 9 || e.keyCode == 13 ) {
		$("#dttransa","#frmTrfcop").focus();
		return false;
	}	
	});
	
	$('#vlaprcoo','#divOpcao_P').unbind('keypress').bind('keypress', function(e) {
	if ( e.keyCode == 9 || e.keyCode == 13 ) {
		confirma();
		return false;
	}	
	});
}
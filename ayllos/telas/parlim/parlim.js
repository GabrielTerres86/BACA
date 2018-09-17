/***********************************************************************
/***********************************************************************
 Fonte: parlim.js                                                  
 Autor: Lucas Ranghetti
 Data : Fevereiro/2017                Última Alteração: 
                                                                   
 Objetivo  : Biblioteca de funções da tela PARLIM
                                                                   	 
 Alterações: 
 
************************************************************************/


var cddopcao;
var msgConfirma;

var Cqtdiacor, Rqtdiacor;
var Cvlminchq, Rvlminchq;
var Cvlminiof, Rvlminiof;
var Cvlminadp, Rvlminadp;


$(document).ready(function() {	
    
	$("#btSalvar","#divBotoes").hide();
	$("#btVoltar","#divBotoes").hide();

	$('#frmCab').fadeTo(0,0.1);
	$('#frmParlim').fadeTo(0,0.1);
	
	removeOpacidade('frmCab');
	removeOpacidade('frmParlim');
	
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	
	Rqtdiacor = $('label[for="qtdiacor"]','#frmParlim');
	Rvlminchq = $('label[for="vlminchq"]','#frmParlim');
    Rvlminiof = $('label[for="vlminiof"]','#frmParlim');
	Rvlminadp = $('label[for="vlminadp"]','#frmParlim');
	
	Rqtdiacor.addClass('rotulo').css('width','400px');
	Rvlminchq.addClass('rotulo').css('width','400px');
	Rvlminiof.addClass('rotulo').css('width','400px');
	Rvlminadp.addClass('rotulo').css('width','400px');
	
	Cqtdiacor =  $('#qtdiacor','#frmParlim');
	Cvlminchq =  $('#vlminchq','#frmParlim');
	Cvlminiof =  $('#vlminiof','#frmParlim');
	Cvlminadp =  $('#vlminadp','#frmParlim');	
	
	Cqtdiacor.desabilitaCampo();
	Cvlminchq.desabilitaCampo();
	Cvlminiof.desabilitaCampo();
	Cvlminadp.desabilitaCampo();	
	
	Cqtdiacor.css('width','65px').setMask('INTEGER','zzz9','','');
	Cvlminchq.css('width','120px').setMask('DECIMAL','z.zzz.zzz.zz9,99','.','');
	Cvlminiof.css('width','120px').setMask('DECIMAL','z.zzz.zzz.zz9,99','.','');
	Cvlminadp.css('width','120px').setMask('DECIMAL','z.zzz.zzz.zz9,99','.','');
	
	$("#divTela").css('display','block'); 
	
	$('#cddopcao','#frmCab').focus();
	
	$('#cddopcao','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#btnOK','#frmCab').focus();
			return false;
		}	
	});	
	
	var nomeForm    = 'frmParlim';
	highlightObjFocus( $('#frmParlim') );	
	highlightObjFocus( $('#frmCab') );
	
});

function btVoltar(){	
	
	cTodosCabecalho = $('input[type="text"],select','#frmCab'); 
	cTodosCabecalho.habilitaCampo();	
	
	$("#btSalvar","#divBotoes").hide();
	$("#btVoltar","#divBotoes").hide();
	$('#cddopcao','#frmCab').focus();
	$('#cddopcao','#frmCab').val('C');
	Cqtdiacor.desabilitaCampo().val('');
	Cvlminchq.desabilitaCampo().val('');
	Cvlminiof.desabilitaCampo().val('');
	Cvlminadp.desabilitaCampo().val('');	
	
}

function btSalvar(){
	
	//cddopcao = $('#cddopcao','#frmCab').val();
	
	//Define a mensagem para Confirmação
	if (cddopcao == "CA"){ 
	    cddopcao = 'A';
		msgConfirma = "Deseja efetuar a altera&ccedil;&atilde;o ?";
		confirma(msgConfirma);
	}
	if (cddopcao == "I"){
		msgConfirma = "Deseja criar o registro ?";
		confirma(msgConfirma);
	}		
}

function define_operacao() {

	// Verifica se campo Opção está desativado.
	if( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda') ){ return false; }
		
	cddopcao = $('#cddopcao','#frmCab').val();
		
	if (cddopcao == "C"){ 
		
		manter_rotina();
		
		$("#btSalvar","#divBotoes").hide();				
		$("#btVoltar","#divBotoes").show();
	}	
	
	if (cddopcao == "A"){
		cddopcao = 'CA';
		manter_rotina();
		
		//Habilita campos para edição
		Cqtdiacor.habilitaCampo();
		Cvlminchq.habilitaCampo();
		Cvlminiof.habilitaCampo();
		Cvlminadp.habilitaCampo();	
		
		highlightObjFocus( $('#frmCab') );
		highlightObjFocus( $('#frmParlim') );
		
		Cqtdiacor.focus();
		
		//Controla botões
		$("#btSalvar","#divBotoes").show();				
		$("#btVoltar","#divBotoes").show();		
					
	}
	
	if (cddopcao == "I"){
		
		//Habilita campos para edição
		Cqtdiacor.habilitaCampo();
		Cvlminchq.habilitaCampo();
		Cvlminiof.habilitaCampo();
		Cvlminadp.habilitaCampo();	
		
		//Limpa Form
		$("#frmParlim").limpaFormulario();
		
		Cqtdiacor.focus();
		
		//Controla botões
		$("#btSalvar","#divBotoes").show();				
		$("#btVoltar","#divBotoes").show();
	}
	
	var cTodosCabecalho		= $('input[type="text"],select','#frmCab'); 
	cTodosCabecalho.desabilitaCampo();	
	
	//Foca no próximo campo caso pressine ENTER 
	Cqtdiacor.keypress( function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9) { 
			Cvlminchq.focus();
			return false; 
		}		
	});
	
	//Foca no próximo campo caso pressine ENTER 
	Cvlminchq.keypress( function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9) { 
			Cvlminiof.focus();
			return false; 
		}		
	});
	
	//Foca no próximo campo caso pressine ENTER 
	Cvlminiof.keypress( function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9) { 
			Cvlminadp.focus();
			return false; 
		}		
	});
	
	Cvlminadp.keypress( function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9) { 
				
		    //Define a mensagem para Confirmação
			if (cddopcao == "CA"){
				msgConfirma = "Deseja efetuar a altera&ccedil;&atilde;o do valor ?";
				cddopcao = 'A';
				confirma(msgConfirma);
			}
			if (cddopcao == "I"){
				msgConfirma = "Deseja criar o registro ?";
				confirma(msgConfirma);
			}			
			return false; 
		}
	});		
}

function confirma(msgConfirma){
	showConfirmacao(msgConfirma,'Confirma&ccedil;&atilde;o - Ayllos','manter_rotina();','','sim.gif','nao.gif');
}

function manter_rotina(){
	
	showMsgAguardo("Aguarde, carregando...");
	
    //Requisição para processar a opção que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/parlim/manter_rotina.php",
        data: {
            qtdiacor: Cqtdiacor.val(),
            vlminchq: Cvlminchq.val(),
            vlminiof: Cvlminiof.val(),
			vlminadp: Cvlminadp.val(),
            cddopcao: cddopcao,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "$('#btVoltar','#divBotoes').focus();");
        },
        success: function (response) {

            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', "$('#btVoltar','#divBotoes').focus();");
			}
		}
			
    });
    return false;	
}
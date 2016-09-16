/*********************************************************************************************
 FONTE        : cbrfra.js
 CRIAÇÃO      : Rodrigo Bertelli (Rkam)         
 DATA CRIAÇÃO : Junho/2014
 OBJETIVO     : Biblioteca de funções da tela CBRFRA
 ***********************************************************************************************/

// Definição de algumas variáveis globais 
var cddopcao		= 'C';
	
//Formulários
var frmCab   		= 'frmCab';

//Labels/Campos do cabeçalho
var rCddopcao, cCddopcao, cTodosCabecalho, btnCab;

$(document).ready(function() {
   
	estadoInicial();
	
	highlightObjFocus( $('#divFormPrincipal') );
	
	$(".somenteNumeros").live("keypress", function(objEvent) {
      var strValor = $(this).val();
      var objLetra = String.fromCharCode(objEvent.which);
      if (objLetra == "," && strValor.indexOf(",") != -1) {
        return false;
      } else {
        return somenteCaracteresNumericos(objEvent.which)
      }
    });
	
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	
	return false;
});

// seletores
function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);
    $('#frmCab').css({'display':'block'});
	$('#divBotoes',"#divTabela","#divFormPrincipal").css({'display':'none'});
	$('#nrdcodigo').val('');
	$('#nmdatainicial').val('');
	$('#nmdatafinal').val('');
	
	formataLayout();
	
	cTodosCabecalho.limpaFormulario();
	cTodosCabecalho.habilitaCampo();
	
	cCddopcao.val( cddopcao );
	
	removeOpacidade('divTela');	
	unblockBackground();
	hideMsgAguardo();
	
	//trocaBotao( '' , '' );
	$("#btVoltar","#divBotoes","#divTabela").hide();
	$("#btnGravar","#divBotoes","#divTabela").hide();
	
	$('input,select', '#frmCab').removeClass('campoErro');
		
	cCddopcao.habilitaCampo();
	cCddopcao.focus();
	$("#divFormPrincipal").hide();
	$("#divTabela").hide();
	$(".clsincluir").hide();
	$(".clsconsulta").hide();
	$(".clsexcluir").hide();
	$("#hdnacao").val('');
	$("#hdncodbarexc").val('');
	
	var date = new Date();
	var intdia = date.getMonth()+1;
	var dia = intdia < 10 ? '0'+intdia : intdia;
	var strDate = date.getDate() + "/" + (dia) + "/" + date.getFullYear();
	
	$('#nmdata').val(strDate);

}

function formataLayout() {

	// Cabecalho	
	cTodosCabecalho			  = $('input[type="text"],select','#'+frmCab);
	btnCab					  = $('#btOK','#'+frmCab);
	
	cCddopcao				  = $('#cddopcao','#'+frmCab); 
	rCddopcao				  = $('label[for="cddopcao"]','#'+frmCab); 
	
	cCddopcao.css({'width':'440px'});
	rCddopcao.css('width','44px');
	$("#nrdcodigo").css({'width':'455px'});
	$(".clsdata").css({'width':'153px'});
	$(".clspadding").css({'padding-left':'10px'});
	$(".clsbotao").css({'margin-left':'20px'});
	
	controlaFoco();	

	layoutPadrao();
	return false;	
}

function controlaFoco() {

	cCddopcao.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			liberaCampos();
			return false;
		}	
	});
	
	$('#btnOK','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			liberaCampos();
			return false;
		}
	});
	
	$("#nrdcodigo").unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			if (cCddopcao.val() == "C" || cCddopcao.val() == "E" ) {
				$("#nmdatainicial").focus();
			}
			else {
				$("#nmdata").focus();
			}
			return false;
		}
	});
	
	$("#nmdatainicial").unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$("#nmdatafinal").focus();
			return false;
		}
	});
	
	$("#nmdatafinal").unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			realizaOperacao(cCddopcao.val(), '1' , '30')
			return false;
		}
	});
	
	$("#nmdata").unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			confirma('I');
			return false;
		}
	});
	
}

function trocaBotao(botao , cddopcao) {

	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>');	
	
	if ( botao != '' ) {
		$('#divBotoes','#divTela').append('&nbsp;<a href="#" class="botao" id="btSalvar" onClick="confirma(\'' + cddopcao + '\'); return false;" >'+botao+'</a>');		
	}
	
	return false;
}

function liberaCampos() {
    
	if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda')  ) {
		return false; 
	}
	
	var strOpcao = $('#cddopcao').val();
	
	cCddopcao.desabilitaCampo();
	
	realizaOperacao(strOpcao, 0 , 0);
	
	if(strOpcao === "C"){	
	
		$(".clsconsulta").show();
		$('#divTabela').show();
	
	}else if(strOpcao === "I"){
	
		$(".clsincluir").show();
	
	}else{

		$(".clsconsulta").show();
		$(".clsexcluir").show();
		$('#divTabela').show();

	}
	
	$('#divBotoes').css({'display':'block'});
	$('#btSalvar','#divBotoes').show();
	$('#btVoltar','#divBotoes').show();
	$('#divFormPrincipal').show();
	$("#hdnacao").val(strOpcao);
	$("#nrdcodigo","#divFormPrincipal").focus();
	    
	return false;
}
	
function btnVoltar() {
	
	estadoInicial();
	return false;
}


function confirma(cddopcao) {
	var strCodigo = $("#nrdcodigo").val();
	var strdata = $("#nmdata").val();
	
	
	if(cddopcao == 'I' && (strCodigo == '' || strdata == '') ){
	    showError("error","Todos os campos devem ser prenchidos.","Alerta - Ayllos","");
		return false;
	}
	var mensagem;
	
	// Mostra mensagem de aguardo
	if (cddopcao == "I"){ 
		mensagem = 'Deseja incluir Código com Fraude?'; 
	}
	else if (cddopcao == "E"){ 
		mensagem = 'Deseja excluir Código com Fraude?';  
		$("#nrdcodigo").val('');
	}	
	showConfirmacao(mensagem,'Confirma&ccedil;&atilde;o - Ayllos','realizaOperacao("' + cddopcao + '" , "1" , "30");','','sim.gif','nao.gif')
}

function realizaOperacao(cddopcao, nriniseq , nrregist) {
	
	var strcodbarra = $("#nrdcodigo").val();
	var stropcao = $("#cddopcao").val();
	var datinclusao = $("#nmdata").val();
	var datinicio = $("#nmdatainicial").val();
	var datfim = $("#nmdatafinal").val();
	var codbarexc = $("#hdncodbarexc").val();
		
	// Mostra mensagem de aguardo
	if (cddopcao == "C"){  		
		showMsgAguardo("Aguarde, consultando código com fruade..."); 
	} 
	else if (cddopcao == "I"){ 
		showMsgAguardo("Aguarde, incluindo códigos com fruade...");
		$("#nrdcodigo").val('');	
	}
	else { 
		showMsgAguardo("Aguarde, excluindo códigos com fruade...");  
	}
	
		
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		dataType: 'text',
		url: UrlSite + "telas/cbrfra/manter_rotina.php", 
		data: {
			cddopcao: cddopcao,
			stropcao : stropcao,
			nrdcodigo: strcodbarra,
			nmdata: datinclusao,
			nmdatainicial : datinicio,
			nmdatafinal : datfim,
			nrdcodigoexc : codbarexc,
			nriniseq : nriniseq,
			nrregist : nrregist,
			redirect: 'html_ajax'			
			},
		async: false,			
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();
				
				try {
					eval(response);
				} catch (err) {
					$("#divTabela").html(response);
				}
				
				if (nriniseq == 0) {
					$("#registros").html('');
				}
				
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});				
}
function validaDataInput(objElemento){
	var datInput = $(objElemento).val();
		if(!validaData(datInput)){
			$(objElemento).val('');
			$(objElemento).focus();
		}
	}
function preencheCodExclusao(strcodexclusao){
	$("#hdncodbarexc").val(strcodexclusao);
	if (!confirma('E')){
	return false;
	}
}
function somenteCaracteresNumericos(intWhich) {
    var objLetra = String.fromCharCode(intWhich);
    var objRegNum = /[0-9]+/;
    if (!objRegNum.test(objLetra)) {
        return false;
    } else {
        return true;
    }
}


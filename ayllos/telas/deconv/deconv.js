/************************************************************************
	Fonte: deconv.js
	Autor: Gabriel
	Data : Junho/2011					     Ultima Alteracao: 20/11/2012
	
	Objetivo: Funcoes necessarias para a tela DECONV.
	
	Alteracoes:
	
	29/06/2012 - Jorge (CECRED) : Ajustado esquema de impressao em funcao geraDeclaracao()
	20/11/2012 - Daniel(CECRED) : Incluso efeito highlightObjFocus e fadeTo, incluso 
								  navegacao campos usando enter, incluso funcao
								  libera_campo (Daniel). 
	
************************************************************************/

var contWin  = 0; // Variável para contagem do número de janelas abertas para impressos


$(document).ready(function() {

	estadoInicial();
    
});


function mostraPesquisaConven () {

	var bo        = 'b1wgen0059.p';
	var procedure = 'Busca_Convenio';
	var titulo    = 'Conv&ecirc;nios';
	var qtReg     = '50';
	var filtro    = 'Convenio;cdconven;65px;S;0|Nome;nmempres;155px;S;';
	var colunas   = 'Convenio;cdconven;25%;right|Nome;nmempres;75%;left';
	
	// Se esta desabilitado o campo do convenio
	if ($("#cdconven","#frmDeconv").prop("disabled") == true)  {
		return;
	}
					
	mostraPesquisa(bo,procedure,titulo,qtReg,filtro,colunas);	

}


function mostraPesquisaAssoc () {

    // Se esta desabilitado o campo do conta
	if ($("#nrdconta","#frmDeconv").prop("disabled") == true)  {
		return;
	}
		
	mostraPesquisaAssociado('nrdconta','frmDeconv','');

}


function valida_traz_titulares () {

	if( $('#cdconven','#frmDeconv').hasClass('campoTelaSemBorda') ){ $("#opcao","#frmDeconv").focus(); return false; }

	var cdconven = $("#cdconven","#frmDeconv").val();	
	var nrdconta = retiraCaracteres($("#nrdconta","#frmDeconv").val(),"0123456789",true);
	 	
	
	if (cdconven == "") {
		showError("error","O campo do Cod. do Convenio deve ser prenchido.","Alerta - Ayllos","$('#cdconven','#frmDeconv').focus()");		
		return;			
	}
	
	if (nrdconta == "") {
		showError("error","O campo da Conta/dv deve ser prenchido.","Alerta - Ayllos","$('#nrdconta','#frmDeconv').focus()");		
		return;			
	}
	
	// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, validando os dados da tela ...");	
	
	$.ajax({
		type: "POST", 
		url: UrlSite + "telas/deconv/valida-traz-titulares.php",
		data: {
			nrdconta: nrdconta,
			cdconven: cdconven,	
			redirect: "script_ajax" // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {				
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#cdconven','#frmDeconv').focus()");							
		},
		success: function(response) {		
			try {
				eval(response);							
			} catch(error) {						
				hideMsgAguardo();					
			    showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#cdconven','#frmDeconv').focus()");							
			}	
		}	
	});
}


function controlaBotoes() {

    // Esconder botao de Continuar
	$("#btContinuar","#divBotoes").hide();
	
	// Desabilitar campos principais
	$('#opcao','#frmDeconv').desabilitaCampo();
	$('#nrdconta','#frmDeconv').desabilitaCampo();
	$('#cdconven','#frmDeconv').desabilitaCampo();

	// Mostrar botoes de Voltar e Imprimir
	$("#btVoltar","#divBotoes").show();
	$("#btImprimir","#divBotoes").show();
	$("#btImprimir","#divBotoes").focus();
	
}


function SelecionaTit (idseqttl,qtTitulares) {
			
	var cor = "";
	
	// Guardar titular selecionado 
	$("#idseqttl","#frmDeconv").val(idseqttl);
	
	// Mudar cor do item selecionado
	for(var i=1; i <= qtTitulares; i++) {
	
		cor = (cor == "") ? "#FFFFFF" : "";
		
		// Formata cor da linha
		$("#titular" + i).css("background-color",cor);
		
		if (i == idseqttl) {
			// Atribui cor de destaque para convenio selecionado
			$("#titular" + idseqttl).css("background-color","#FFB9AB");				
		}			
	}	
}


function geraDeclaracao () {

	var nrdconta = retiraCaracteres($("#nrdconta","#frmDeconv").val(),"0123456789",true);
	var idseqttl = $("#idseqttl","#frmDeconv").val();
	var cdconven = $("#cdconven","#frmDeconv").val();	
	
	if  (idseqttl == "" || nrdconta == "" || cdconven == "") {
		return;		
	}
	
	var action = UrlSite + 'telas/deconv/impressao_declaracao.php';
	
	$('#sidlogin','#frmDeconv').remove();			
	
	$('#frmDeconv').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '" />');	
	
	$("#conta","#frmDeconv").val(nrdconta);
	$("#convenio","#frmDeconv").val(cdconven);	
	
	carregaImpressaoAyllos("frmDeconv",action,"limpaDados();");
	
}

	
function limpaDados() {

	// Esconder titulares
	$('#divTitulares').html("");

	// Esconder botao de Voltar
	$("#btVoltar","#divBotoes").hide();
	$("#btImprimir","#divBotoes").hide();
	$("#btContinuar","#divBotoes").hide();
	
	// Mostrar botao de Continuar
	//$("#btContinuar","#divMsgAjuda").show();
	
	// Limpar campo de convenio e conta
	$("#cdconven","#frmDeconv").val("");
	$("#nrdconta","#frmDeconv").val("");
	$("#idseqttl","#frmDeconv").val("");
	
	// Habilitar campos principais
	$('#opcao','#frmDeconv').habilitaCampo();
	$('#nrdconta','#frmDeconv').desabilitaCampo();
	$('#cdconven','#frmDeconv').desabilitaCampo();
	
	// Setar foco
	$("#opcao","#frmDeconv").focus();

}

function libera_campo() {

	// Verifica se campo opcao está desativado.
	if( $('#opcao','#frmDeconv').hasClass('campoTelaSemBorda') ){ return false; }

	$("#btVoltar","#divBotoes").show();
	$("#btContinuar","#divBotoes").show();
	
	$('#nrdconta','#frmDeconv').habilitaCampo();
	$('#cdconven','#frmDeconv').habilitaCampo();
	$('#opcao','#frmDeconv').desabilitaCampo();
	$('#btnOK','#frmDeconv').desabilitaCampo();
	
	$('#cdconven','#frmDeconv').focus();
	
}

function estadoInicial() {

	
  $('#frmDeconv').fadeTo(0,0.1);
  
  $('#tdConteudoTela').css({'display':'block'});
  

  highlightObjFocus( $("#frmDeconv") );	
  
  $('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
  $('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});

  var cdconven = $("#cdconven","#frmDeconv");
  var nrdconta = $("#nrdconta","#frmDeconv");
  var copcao   = $("#opcao","#frmDeconv")
  
  // Setar as Mascaras dos campos
  cdconven.setMask("INTEGER","zzzz");
  nrdconta.setMask("INTEGER","zzzz.zzz-z","");
  
  // Setar foco
  $("#opcao","#frmDeconv").focus();
  
  cdconven.desabilitaCampo();
  nrdconta.desabilitaCampo();
  
  // Mostrar Botoao de Continuar
  $("#btContinuar","#divBotoes").hide();
  
  $("#btImprimir","#divBotoes").hide();
  $("#btVoltar","#divBotoes").hide();
  
  $("#divBotoes").css('display','block');
  
  // Se campo Opção
  $('#opcao','#frmDeconv').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#btnOK','#frmDeconv').focus();
			return false;
		}	
	});
  	

  // Se campo Convenio
  cdconven.unbind("keydown").bind("keydown",function(e) {
    
  	 if(e.keyCode == 13) { // ENTER 
		if  ( $("#cdconven","#frmDeconv").val() == "" ) {
				showError("error","O campo do Cod. do Convenio deve ser prenchido.","Alerta - Ayllos","$('#cdconven','#frmDeconv').focus()");				
				return false;
		} else {
			nrdconta.focus();
		}
     }
     if (e.keyCode == 118) { // F7
	    mostraPesquisaConven();
	 }
  });
  
  // Se Campo de Conta/Dv	
  nrdconta.unbind("keydown").bind("keydown", function (e) {
   	   	
	if(e.keyCode == 13) { // ENTER
	   valida_traz_titulares();
	   return false;
	}	
	else		
	if (e.keyCode == 118) { // F7
		mostraPesquisaAssociado('nrdconta','frmDeconv','');
	}
	
  });

  removeOpacidade('frmDeconv');

}

function btVoltar() {

	limpaDados();
	estadoInicial();

}

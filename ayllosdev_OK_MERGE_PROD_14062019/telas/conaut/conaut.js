/*********************************************************************************************
 FONTE        : conaut.js
 CRIAÇÃO      : Jonata Cardoso (Rkam)         
 DATA CRIAÇÃO : Julho/2014
 OBJETIVO     : Biblioteca de funções da tela conaut
 ***********************************************************************************************/

// Definição de algumas variáveis globais 
var cdtipcad        = 'B';
var cddopcao		= 'C';
		
//Formulários
var frmCab   		= 'frmCab';

//Labels/Campos do cabeçalho
var rCdtipcad, cCdtipcad, rCddopcao, cCddopcao, cTodosCabecalho, btnCab;

$(document).ready(function() {
   
	estadoInicial();
	
	highlightObjFocus( $('#'+frmCab) );
	
	$(".somenteNumeros").live("keypress", function(objEvent) {
      var strValor = $(this).val();
      var objLetra = String.fromCharCode(objEvent.which);
      if (objLetra == "," && strValor.indexOf(",") != -1) {
        return false;
      } else {
	  
	   if (objEvent.which == "8" || objEvent.which == "32" || objEvent.which == "44" || objEvent.which == "46"  ) {
		return true;
	   }
	  
       return somenteCaracteresNumericos(objEvent.which)
      }
    });
	
	$("#cddopcao").unbind('change').bind('change', function() { 
		cddopcao = $(this).val();
	});
	
	$("#dsbircon","#form_opcao_p").unbind('change').bind('change',function() {
		cddopcao = "I2";
		realizaOperacao();
	});
	
	$("#inpessoa","#form_opcao_p").unbind('change').bind('change',function() {
		cddopcao = "I0";
		manter_rotina();
	});
	
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	
	return false;
});

// seletores
function estadoInicial() {

	cddopcao = 'C';

	$('#divTela').fadeTo(0,0.1);
    $('#frmCab').css({'display':'block'});
	$('#divBotoes',"#divTabela","#form_opcao_b").css({'display':'none'});
	
	$("#form_opcao_b").find(':input').each(function() {
        $(this).val('');
	});	
	formataLayout();
	
	cTodosCabecalho.limpaFormulario();
	cTodosCabecalho.habilitaCampo();
	btnCab.habilitaCampo();
	
	cCdtipcad.val( cdtipcad );
	cCddopcao.val( cddopcao );
	
	removeOpacidade('divTela');	
	unblockBackground();
	hideMsgAguardo();
	
	$("#divBotoes").hide();	
	$('input,select', '#frmCab').removeClass('campoErro');
		
	cCdtipcad.habilitaCampo();	
	cCddopcao.habilitaCampo();
	cCdtipcad.focus();
	
	$("#form_opcao_b,  #form_opcao_m , #form_opcao_p, #form_opcao_t, #form_opcao_r, #form_opcao_c ").hide();
	$(".class_opcao_b, .class_opcao_m, .class_opcao_p, .class_opcao_t, .class_opcao_r, .class_opcao_c").hide();

	$(".div_opcao").hide();
	$("#divTabela").hide();
	
}

function formataLayout() {

	// Cabecalho	
	cTodosCabecalho			  = $('input[type="text"],select','#'+frmCab);
	btnCab					  = $('#btnOK','#'+frmCab);
	
	cCdtipcad                 = $('#cdtipcad','#'+frmCab);
	rCdtipcad                 = $('label[for="cdtipcad"]','#'+frmCab);
	
	cCddopcao				  = $('#cddopcao','#'+frmCab); 
	rCddopcao				  = $('label[for="cddopcao"]','#'+frmCab); 
	
	cCdtipcad.css({'width':'440px'});
	rCdtipcad.css('width','55px');
	
	cCddopcao.css({'width':'440px'});
	rCddopcao.css('width','55px');
	$(".clsdata").css({'width':'70px'});
	$(".clspadding").css({'padding-left':'10px'});
	
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
	
	btnCab.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			liberaCampos();
			return false;
		}
	});
}

function liberaCampos() {
    
	if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda')  ) { 
	  return false; 
	}
	
	cTodosCabecalho.desabilitaCampo();
	btnCab.desabilitaCampo();
	
	realizaOperacao();
 
	return false;
}
	
function btnVoltar() {

	estadoInicial();
	return false;
	
}

function realizaOperacao() {

	var cdtipcad = $("#cdtipcad").val();
	var form_opcao = "#form_opcao_" + cdtipcad.toLowerCase();
	
	if (cddopcao == 'C') { 	 // Consultar dados
	
		if (cdtipcad == "T") {
			$('#divTabela').css({'display':'none'});
			$(".div_opcao").show();
			$(".class_opcao_" + cdtipcad.toLowerCase()).show();
			$("#form_opcao_"  + cdtipcad.toLowerCase()).show();
			$("#qtsegrsp","#form_opcao_t").desabilitaCampo();
		}
		else {
			$('#divTabela').css({'display':'block'});
		}
		
		$(form_opcao + " input, " + form_opcao + " select").val("");	
		
		cddopcao = $('#cddopcao','#'+frmCab).val();	

		if (cddopcao != 'C') {
			cddopcao = cddopcao + '1';
		} else {
			$("#btSalvar").css({'display':'none'});

		}
			
		manter_rotina();

	}
	else 
	if (cddopcao == 'A') {   // Consultar dados
	
		if (cdtipcad == "T") {
			$('#divTabela').css({'display':'none'});
			$(".div_opcao").show();
			$(".class_opcao_" + cdtipcad.toLowerCase()).show();
			$("#form_opcao_"  + cdtipcad.toLowerCase()).show();
			$("#qtsegrsp","#form_opcao_t").habilitaCampo();
		}
		else {
			$('#divTabela').css({'display':'block'});
		}

		$(form_opcao + " input, " + form_opcao + " select").val("");
		cddopcao = 'A1';
		manter_rotina();
	    $("#btSalvar").css({'display':'inline'});
		$("#btSalvar").html('Alterar');
	} 
	else 
	if  (cddopcao == 'A1') { // Abrir dados para alteracao
		if (cdtipcad == 'B' && $("#cdbircon","#form_opcao_b").val() == "") {
			showError("error","Selecione um bir&ocirc; antes de alterar.","Alerta - Ayllos","");
			return;
		}
		if (cdtipcad == 'M' && $("#cdmodbir","#form_opcao_m").val() == "") {
			showError("error","Selecione uma modalidade antes de alterar.","Alerta - Ayllos","");
			return;
		}
		if (cdtipcad == 'C' && $("#cdbircon","#form_opcao_c").val() == "") {
			showError("error","Selecione uma conting&ecirc;ncia antes de alterar.","Alerta - Ayllos","");
			return;
		}
		if (cdtipcad == 'R' && $("#flgselec","#form_opcao_r").val() == "") {
			showError("error","Selecione uma consulta antes de alterar.","Alerta - Ayllos","");
			return;
		}	
		if (cdtipcad == 'P' && $("#cdbircon","#form_opcao_p").val() == "") {
			showError("error","Selecione uma parametriza&ccedil;&atilde;o antes de alterar.","Alerta - Ayllos","");
			return;
		}
	
		$('#divTabela').css({'display':'none'});
		cddopcao = 'A2';	
		$("#btSalvar").css({'display':'inline'});
		$("#btSalvar").html('Salvar');
		$(".div_opcao").show();
		$(".class_opcao_" + cdtipcad.toLowerCase()).show();
		$("#form_opcao_"  + cdtipcad.toLowerCase()).show();
		
		if (cdtipcad == "M" || cdtipcad == "C") {
			$("#dsbircon","#form_opcao_" + cdtipcad.toLowerCase()).desabilitaCampo();
		}
		if (cdtipcad == "R") {
			$("#inprodut,#inpessoa","#form_opcao_r").desabilitaCampo();
		}
		if (cdtipcad == "P") {
			$("input, select","#form_opcao_p").desabilitaCampo();
			$("#dsmodbir","#form_opcao_p").habilitaCampo();
		}
					
		if (cdtipcad == 'M') {
			cddopcao = "A3";
			manter_rotina();
		}
		
		if (cdtipcad == "P") {
			cddopcao = "A4";
			manter_rotina();
		}
		
	}
	else if (cddopcao == "A2" || cddopcao == 'A3' || cddopcao == "A4") { // Efetuar alteracao
 		cddopcao = 'A';
		var mensagem = 'Deseja confirmar a altera&ccedil;&atilde;o?';  
		showConfirmacao(mensagem,'Confirma&ccedil;&atilde;o - Ayllos','manter_rotina();','cddopcao = "A2"','sim.gif','nao.gif');
	}
	else
	if (cddopcao == 'I') { 	 //  Abrir tela de Inclusao
	
		if (cdtipcad == "T") {
			showError("error","Somente as op&ccedil;&otilde;es 'C' e 'A' est&atilde;o disponive&iacute;s.","Alerta - Ayllos","estadoInicial();");
			return;
		}
	
		$('#divTabela').css({'display':'none'});
		$(form_opcao + " input, " + form_opcao + " select").val("");
		cddopcao = 'I1';
		$("#btSalvar").css({'display':'inline'});
		$("#btSalvar").html('Incluir');
		$(".div_opcao").show();
		$(".class_opcao_" + cdtipcad.toLowerCase()).show();
		$("#form_opcao_"  + cdtipcad.toLowerCase()).show();
		
		if (cdtipcad == 'M' || cdtipcad == "C" || cdtipcad == "P") {
			cddopcao = "I0";
			manter_rotina();
		}
		
		if (cdtipcad == "M" || cdtipcad == "C") {
			$("#dsbircon","#form_opcao_" + cdtipcad.toLowerCase()).habilitaCampo();
		}
		
		if (cdtipcad == "R") {
			$("#inprodut,#inpessoa","#form_opcao_r").habilitaCampo();
		}
		
		if (cdtipcad == "P") {
			$("input, select","#form_opcao_p").habilitaCampo();
		}
		
	} 
	else
	if (cddopcao == "I0" || cddopcao == 'I1' || cddopcao == "I3") { // Efetuar inclusao
		cddopcao = "I";
		var mensagem = 'Deseja confirmar a inclus&atilde;o?';  
		showConfirmacao(mensagem,'Confirma&ccedil;&atilde;o - Ayllos','manter_rotina();','cddopcao = "I1"','sim.gif','nao.gif');
	}
	else
	if (cddopcao == "I2") {
		manter_rotina();
	}
	else 
	if (cddopcao == 'E') {  // Consultar os dados
	
	    if (cdtipcad == "T") {
			showError("error","Somente as op&ccedil;&otilde;es 'C' e 'A' est&atilde;o disponive&iacute;s.","Alerta - Ayllos","estadoInicial();");
			return;
		}
	
		$('#divTabela').css({'display':'block'});
		$(form_opcao + " input, " + form_opcao + " select").val("");
		cddopcao = 'E1';
		manter_rotina();
		$("#btSalvar").css({'display':'inline'});
		$("#btSalvar").html('Excluir');
	}
	else 
	if (cddopcao == 'E1') { // Excluir o registro
		if (cdtipcad == "B" && $("#cdbircon","#form_opcao_b").val() == "") {
			showError("error","Selecione um bir&ocirc; antes de excluir.","Alerta - Ayllos","");
			return;
		}	
		if (cdtipcad == "M" && $("#cdmodbir","#form_opcao_m").val() == "") {
			showError("error","Selecione um bir&ocirc; antes de excluir.","Alerta - Ayllos","");
			return;
		}	
		if (cdtipcad == "C" && $("#cdbircon","#form_opcao_c").val() == "") {
			showError("error","Selecione uma conting&ecirc;ncia antes de excluir.","Alerta - Ayllos","");
			return;
		}
		if (cdtipcad == 'R' && $("#flgselec","#form_opcao_r").val() == "") {
			showError("error","Selecione uma consulta antes de excluir.","Alerta - Ayllos","");
			return;
		}	
		if (cdtipcad == 'P' && $("#cdbircon","#form_opcao_p").val() == "") {
			showError("error","Selecione uma parametriza&ccedil;&atilde;o antes de excluir.","Alerta - Ayllos","");
			return;
		}
		
		cddopcao = "E";
		var mensagem = 'Deseja confirmar a exclus&atilde;o?';  
		showConfirmacao(mensagem,'Confirma&ccedil;&atilde;o - Ayllos','manter_rotina();','cddopcao = "E1"','sim.gif','nao.gif');
	}
	
	$('#divBotoes').css({'display':'block'});
	
}

function manter_rotina () {

	// Obter o tipo de cadastro
	var cdtipcad = $("#cdtipcad").val();
	
	// Dados do cadastro do biro
	var cdbircon = "";
	var cdmodbir = "";
	
	var form_opcao = "#form_opcao_" + cdtipcad.toLowerCase();
	
	if  ((cddopcao == "I" || cddopcao == "A" || cddopcao == "I2" ) && (cdtipcad == "M" || cdtipcad == "C" || cdtipcad == "P")) {
		cdbircon = $("#dsbircon",form_opcao).val();
		if (cdtipcad == "P" && cddopcao != "I2") {
		  cdmodbir = $("#dsmodbir",form_opcao).val();
		} else {
		  cdmodbir = $("#cdmodbir",form_opcao).val();
		}
	} else  {
		cdbircon = $("#cdbircon",form_opcao).val();
		cdmodbir = $("#cdmodbir",form_opcao).val();
	}
	
	// Dados do biro
	var dsbircon = $("#dsbircon",form_opcao).val();
	var nmtagbir = $("#nmtagbir","#form_opcao_b").val();
	// Dados do cadastro da modalidade
	var dsmodbir = $("#dsmodbir",form_opcao).val();
	var inpessoa = $("#inpessoa",form_opcao).val();
	var nmtagmod = $("#nmtagmod","#form_opcao_m").val();
	var nrordimp = $("#nrordimp","#form_opcao_m").val();
	// Dados das propostas
	var vlinicio = $("#vlinicio","#form_opcao_p").val().replace(".","").replace(",",".");
	// Dados de retorno de consulta
	var qtsegrsp = $("#qtsegrsp","#form_opcao_t").val();
	// Dados para o reaproveitamento de consultas
	var inprodut = $("#inprodut",form_opcao).val();
	var qtdiarpv = $("#qtdiarpv","#form_opcao_r").val();
	// Dados para a contingencia
	var dtinicon = $("#dtinicon","#form_opcao_c").val();
	
	if ( (cdtipcad == "P" && cddopcao == "I") && (isNaN(vlinicio) || vlinicio == "")  ) {
		cddopcao = "I0";
		showError("error","O valor inicial deve ser prenchido.","Alerta - Ayllos","");
		return;
	}
	
	if ( cdtipcad == "P" && cddopcao == "I" && dsmodbir == null) {
		cddopcao = "I0";
		showError("error","A modalidade deve ser prenchida.","Alerta - Ayllos","");
		return;
	}

	var dsmensag; 

	if (cddopcao == 'C' || cddopcao == 'A1' || cddopcao == "A3" || cddopcao == 'E1' || cddopcao == 'I0' || cddopcao == "I2") {
		dsmensag = 'Aguarde, consultando os dados ...'; 
		
		if (cdtipcad == "P") {
			inprodut =  $("#inprodut","#filtro_proposta").val();
		}
		else if (cdtipcad == "R") {
			inprodut = "";
		}
		
		
	} else {
		dsmensag = 'Aguarde, salvando os dados ...';
	}
	
    showMsgAguardo(dsmensag);

	$.ajax({		
		type: "POST",
		dataType: 'html',
		url: UrlSite + "telas/conaut/manter_rotina.php", 
		data: {
		    cdtipcad: cdtipcad,
			cddopcao: cddopcao,
			cdbircon: cdbircon,
			dsbircon: dsbircon,
			nmtagbir: nmtagbir,
			vlinicio: vlinicio,
			cdmodbir: cdmodbir,
			dsmodbir: dsmodbir,
			inpessoa: inpessoa,
			nmtagmod: nmtagmod,
			qtsegrsp: qtsegrsp,
			nrordimp: nrordimp,
			inprodut: inprodut,
			qtdiarpv: qtdiarpv,
			dtinicon: dtinicon,
			redirect: 'script_ajax'			
			},
		async: true,			
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();
				
				if (cddopcao == "I0" || cddopcao == "I2" || cddopcao == "A3" || cddopcao == "A4") {
					
					try {
						eval (response);
					} catch (error) {
						$("option",$("#dsmodbir","#form_opcao_p")).remove();
					}
					
					if (cddopcao == "I2") {
						cddopcao = "I0";
					}
					else
					if (cdtipcad == "P" && cddopcao == "I0") {
					    cddopcao = "I2";
						realizaOperacao();
					}
					
				} else {
					if (cdtipcad == "T" && (cddopcao == "C" || cddopcao == "A1" )) {
						eval(response);		
						cddopcao = (cddopcao == "A1") ? "A2" : cddopcao;
					} else {
						$("#divTabela").html(response);	
					}
				}
				
				if (cddopcao == 'I' || cddopcao == 'A' || cddopcao == 'E') {
					estadoInicial();
				} else {
					formataTabela();
				}
				
			} 
			catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","");
			}
		}				
	});	

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

function formataTabela() {

	var divRegistro = $('div.divRegistros');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
	
	divRegistro.css({'height':'150px','padding-bottom':'2px'});
	
	var ordemInicial = new Array();
	ordemInicial = [[0,0], [0,1]];
					
	var arrayAlinha = new Array();
  	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'left';
	
	var metodoTabela = '';
	
	tabela.formataTabela( ordemInicial, '', arrayAlinha, metodoTabela );		
	
	return false;
}

function armazenarBiro (cdbircon, dsbircon, nmtagbir) {
	$('#cdbircon',"#form_opcao_b").val(cdbircon);
	$('#dsbircon',"#form_opcao_b").val(dsbircon);
	$('#nmtagbir',"#form_opcao_b").val(nmtagbir);	
}

function armazenarModalidade (cdbircon, cdmodbir, dsmodbir, inpessoa, nmtagmod, nrordimp) {
	$('#cdbircon',"#form_opcao_m").val(cdbircon);
	$('#cdmodbir',"#form_opcao_m").val(cdmodbir);
	$('#dsmodbir',"#form_opcao_m").val(dsmodbir);	
	$('#inpessoa',"#form_opcao_m").val(inpessoa);
	$('#nmtagmod',"#form_opcao_m").val(nmtagmod);
	$('#nrordimp',"#form_opcao_m").val(nrordimp);	
}

function armazenarContingencia (cdbircon , dsbircon, dtinicon) {
	$("#cdbircon","#form_opcao_c").val(cdbircon);
	$("#dtinicon","#form_opcao_c").val(dtinicon);
	$("option",$("#dsbircon","#form_opcao_c")).remove();
    $("#dsbircon","#form_opcao_c").append("<option value='" + cdbircon + "'>" + dsbircon + "</option>");
}

function armazenarReaproveitamento (inprodut, inpessoa, qtdiarpv) {
	$("#inprodut","#form_opcao_r").val(inprodut);
	$("#inpessoa","#form_opcao_r").val(inpessoa);
	$("#qtdiarpv","#form_opcao_r").val(qtdiarpv);
	$("#flgselec","#form_opcao_r").val(true);
}

function armazenarParametrizacao (inprodut, inpessoa, vlinicio, cdbircon, dsbircon, cdmodbir, dsmodbir ) {
	$("#inprodut","#form_opcao_p").val(inprodut);
	$("#inpessoa","#form_opcao_p").val(inpessoa);
	$("#vlinicio","#form_opcao_p").val(vlinicio);
	$("#cdbircon","#form_opcao_p").val(cdbircon);

	$("option",$("#dsbircon","#form_opcao_p")).remove();
	$("#dsbircon","#form_opcao_p").append("<option value='" + cdbircon + "'>" + dsbircon + "</option>");
	
	$("option",$("#dsmodbir","#form_opcao_p")).remove();
	$("#dsmodbir","#form_opcao_p").append("<option value='" + dsmodbir + "'>" + dsmodbir + "</option>");
}
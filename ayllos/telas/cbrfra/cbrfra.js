/*********************************************************************************************
 FONTE        : cbrfra.js
 CRIAÇÃO      : Rodrigo Bertelli (Rkam)         
 DATA CRIAÇÃO : Junho/2014
 OBJETIVO     : Biblioteca de funções da tela CBRFRA
 
 ALTERAÇÕES   :
 
 22/08/2016 - #456682 Inclusão dos tipos de fraude TED PF e PJ (Carlos)
 16/09/2016 - Melhoria nas mensagens, de "Código" para "Registro", para ficar genérico, conforme solicitado pelo Maicon (Carlos)
 15/02/2016 - Inclusão do tipo  Telefone Celular. Melhoria nas mensagens. Projeto 321 - Recarga de Celular. (Lombardi)
 
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
	$('#nrcpf').val('');
	$('#nrcnpj').val('');
	$('#nrdddcel').val('');
	$('#nrtelcel').val('');
	
	$('#nmdatainicial').val('');
	$('#nmdatafinal').val('');
	
	$('#divTED1').hide();
	$('#divTED2').hide();
	$('#divTelefoneCelular').hide();
	$('#divBoleto').show();
	$('#tipo').val('1');	
	
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
	$('#nmdata').desabilitaCampo();
}

function formataLayout() {

	// Cabecalho	
	cTodosCabecalho			  = $('input[type="text"],select','#'+frmCab);	
	
	btnCab					  = $('#btOK','#'+frmCab);
		
	cCddopcao				  = $('#cddopcao','#'+frmCab); 
	rCddopcao				  = $('label[for="cddopcao"]','#'+frmCab); 
			
	cCddopcao.css({'width':'440px'});
	rCddopcao.css('width','44px');
	
	$('#lblTipo, #lblCodigo, #lblCpf, #lblCnpj, #lblTelCel, #lblDataini, #lblData').css({'width':'90px'});	
	
	$("#nrdcodigo").css({'width':'450px'});
	$(".clsdata").css({'width':'75px'});
	$(".clspadding").css({'padding-left':'10px'});
	$(".clsbotao").css({'right':'0'});
	
	$('#tipo').css({'width':'140px'});

	controlaFoco();	

	layoutPadrao();

	$("#nrcpf").css({'width':'450px', 'text-align':'left'});
	$("#nrcnpj").css({'width':'450px','text-align':'left'});
	$("#nrdddcel").css({'width':'25px','text-align':'left'}).setMask('INTEGER','zz','','');
	$("#nrtelcel").css({'width':'125px','text-align':'left'}).setMask("INTEGER","zzzzz-zzzz",".-","");

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
				confirma('I');
			}
			return false;
		}
	});	
	
	$("#tipo").unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			if ($("#tipo").val() == '1') {
				$("#nrdcodigo").focus();
			}
			else if ($("#tipo").val() == '2') {
				$("#nrcpf").focus();
			}
			else if ($("#tipo").val() == '3') {
				$("#nrcpfcnpj").focus();
			} else {
				$("#nrdddcel").focus();
			}
				
			return false;
		}
	});


	$("#nrcpf").unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			if (cCddopcao.val() == "C" || cCddopcao.val() == "E" ) {
				$("#nmdatainicial").focus();
			}
			else {
				confirma('I');
			}
			return false;
		}
	});

	$("#nrcnpj").unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			if (cCddopcao.val() == "C" || cCddopcao.val() == "E" ) {
				$("#nmdatainicial").focus();
			}
			else {
				confirma('I');
			}
			return false;
		}
	});
	
	$("#nrdddcel").unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13) {	
			$("#nrtelcel").focus();
			return false;
		}
	});
	
	$("#nrtelcel").unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			if (cCddopcao.val() == "C" || cCddopcao.val() == "E" ) {
				$("#nmdatainicial").focus();
			}
			else {
				confirma('I');
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
	
}
function atualizaTipo() {
	if ($("#tipo").val() == '1') {
	    $('#divTED1').hide();
	    $('#divTED2').hide();
		$('#divTelefoneCelular').hide();
	    $('#divBoleto').show();
	} else if ($("#tipo").val() == '2') {		
	    $('#divBoleto').hide();
		$('#divTED2').hide();
		$('#divTelefoneCelular').hide();
		$('#divTED1').show();
	} else if ($("#tipo").val() == '3') {		
		$('#divBoleto').hide();
		$('#divTED1').hide();
		$('#divTelefoneCelular').hide();
		$('#divTED2').show();
	} else if ($("#tipo").val() == '4') {		
		$('#divBoleto').hide();
		$('#divTED1').hide();
		$('#divTED2').hide();
		$('#divTelefoneCelular').show();
	}
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
	$("#tipo","#divFormPrincipal").focus();
	    
	return false;
}
	
function btnVoltar() {
	
	estadoInicial();
	return false;
}


function confirma(cddopcao) {
	var strCodigo;
	var strdata = $("#nmdata").val();		
	
	if ($("#tipo").val() == '1') {		
		strCodigo = $("#nrdcodigo").val();
	}
	else if ($("#tipo").val() == '2') {
		strCodigo = $("#nrcpf").val();
	}
	else if ($("#tipo").val() == '3') {
		strCodigo = $("#nrcpfcnpj").val();
	}
	else {
		strCodigo = $("#nrdddcel").val() + $("#nrtelcel").val();
	}
		
	if(cddopcao == 'I') {
		if ((strCodigo == '' || strdata == '')){
			showError("error","Todos os campos devem ser prenchidos.","Alerta - Ayllos","");
			return false;
		}
		
		//TELEFONE CELULAR
		if ($("#tipo").val() == 4) { 
			
			if ($("#nrdddcel").val() == '' || $("#nrtelcel").val() == '') {
				showError("error","Todos os campos devem ser prenchidos.","Alerta - Ayllos","$(\"#nrdddcel\").focus();");
				return false;
			}
			
			if ($("#nrdddcel").val().length < 2) {
				showError("error","DDD inv&aacute;lido.","Alerta - Ayllos","$(\"#nrdddcel\").focus();");
				return false;
			}
			
			if ($("#nrtelcel").val().length < 10) {
				showError("error","Telefone inv&aacute;lido.","Alerta - Ayllos","$(\"#nrtelcel\").focus();");
				return false;
			}
		}
	}
	
	var mensagem;
	
	// Monta mensagem de confirmacao
	if ($("#tipo").val() == '1') {		
		mensagem = 'Código';
	}
	else if ($("#tipo").val() == '2') {
		mensagem = 'CPF';
	}
	else if ($("#tipo").val() == '3') {
		mensagem = 'CNPJ';
	}
	else {
		mensagem = 'Telefone Celular';
	}
	
	if (cddopcao == "I"){ 
		mensagem = 'Deseja incluir ' + mensagem + ' com Fraude?';
	}
	else if (cddopcao == "E"){ 	
		mensagem = 'Deseja excluir ' + mensagem + ' com Fraude?';
	}	
	
	// Mostra mensagem de confirmacao
	showConfirmacao(mensagem,
	'Confirma&ccedil;&atilde;o - Ayllos',
	'realizaOperacao("' + cddopcao + '" , "1" , "30");',
	'',
	'sim.gif',
	'nao.gif');
}

function realizaOperacao(cddopcao, nriniseq , nrregist) {
	
	var dsfraude;
	var stropcao     = $("#cddopcao").val();
	var tipo         = $("#tipo").val();
	var datinclusao  = $("#nmdata").val();
	var datinicio    = $("#nmdatainicial").val();
	var datfim       = $("#nmdatafinal").val();
	var codbarexc    = $("#hdncodbarexc").val();

	switch (tipo) {
		case '1':
			dsfraude = $("#nrdcodigo").val();
			break;
		case '2':
			dsfraude = $("#nrcpf").val();
			break;
		case '3':
			dsfraude = $("#nrcnpj").val();
			break;
		case '4':
				dsfraude = $("#nrdddcel").val() + $("#nrtelcel").val();
			break;
		default:
			dsfraude = $("#nrdcodigo").val();
			break;
	}
	
	if(cddopcao == 'C' || cddopcao == 'E') {
		
		if ($("#nmdatainicial").val() != '' && $("#nmdatafinal").val() != '') {
			var date1 = $("#nmdatainicial").val();
			var date2 = $("#nmdatafinal").val();
			var newDate1 = new Date();
			var newDate2 = new Date();
			newDate1.setFullYear(date1.substr(6,4),(date1.substr(3,2) - 1),date1.substr(0,2));
			newDate2.setFullYear(date2.substr(6,4),(date2.substr(3,2) - 1),date2.substr(0,2));

			if (newDate2 < newDate1) {
				showError("error","Data final deve ser maior ou igual a Data inicial.","Alerta - Ayllos","");
				return false;
			}
		}
	}
	// Mostra mensagem de aguardo
	if (cddopcao == "C"){  		
		showMsgAguardo("Aguarde, consultando registro de fraude..."); 
	} 
	else if (cddopcao == "I"){ 
		showMsgAguardo("Aguarde, incluindo registro de fraude...");
	}
	else { 
		showMsgAguardo("Aguarde, excluindo registros de fraude...");  
	}

	if (cddopcao == "I" || cddopcao == "E"){
		$("#nrdcodigo").val('');
		$("#nrcpf").val('');
		$("#nrcnpj").val('');
		$("#nrdddcel").val('')
		$("#nrtelcel").val('');
	}
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		dataType: 'text',
		url: UrlSite + "telas/cbrfra/manter_rotina.php", 
		data: {
			cddopcao      : cddopcao,
			stropcao      : stropcao,
			tipo          : tipo,
			dsfraude      : dsfraude,
			nmdata        : datinclusao,
			nmdatainicial : datinicio,
			nmdatafinal   : datfim,
			nrdcodigoexc  : codbarexc,
			nriniseq      : nriniseq,
			nrregist      : nrregist,
			redirect      : 'html_ajax'			
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
					$("#tipo").focus();
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

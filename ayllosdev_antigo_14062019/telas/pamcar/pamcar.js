/*!
 * FONTE        : pamcar.js
 * CRIAÇÃO      : Fabricio
 * DATA CRIAÇÃO : 07/12/2011
 * OBJETIVO     : Biblioteca de funções da tela PAMCAR
 * --------------
 * ALTERAÇÕES   : 07/02/2012 - Alterado a função gravaRegistroConvenio para validar se a conta 
 *								 duplicada é diferente da conta origem (Adriano).
 *								 
 *				  12/06/2012 - Alterado funcao imprimeTermo() e imprimeRelatorio(), 
 * 							   novo esquema para impressao. (Jorge)
 *				
 *				  19/06/2012 - Desabilitar botões de Alteração e Impressão em 
 *							   seu estado inicial (Lucas).
 *
 *				  30/10/2012 - Criados relatórios de Limite de Cheque Especial e 
 *							   Informações Cadastrais para a opção "R" (Lucas)
 
				  06/03/2013 - Novo layout padrao (Gabriel).	
				  
				  26/02/2014 - Adicionado global flgdemis; utilizada para tratamento
				               na procedure alteraCamposHabilitacao(). (Fabricio)
 *				
 * --------------
 */
 
var cddopcao = '';

var rCddopcao, rVllimpam, rVlpamuti, rVlmenpam, rPrtaxpam,
    cCddopcao, cNmrescop, cVllimpam, cVlpamuti, cVlmenpam, 
	cPrtaxpam, cCamposAltera;
	
var lstCooperativas = new Array();
var lstRelatorios   = new Array();

var nrdconta, nrdctitg, flgdemis;

var vllimpam, dddebpam, nrctapam;


$(document).ready(function() {
	
	estadoInicial();
	
	// Evento onKeyUp no campo "nrdconta"
	$("#nrdconta","#frmHabilita").bind("keyup",function(e) { 
		// Seta máscara ao campo
		if (!$(this).setMaskOnKeyUp("INTEGER","zzzz.zzz-z","",e)) {
			return false;
		}
		
		// Se foi alterado o número da conta, limpa o campo "nrdctitg" e não permite acessar as rotinas
		if (retiraCaracteres($(this).val(),"0123456789",true) != nrdconta) {
			$("#nrdctitg","#frmHabilita").val("0.000.000-0");
		}
	});
	
	// Evento onKeyDown no campo "nrdconta"
	$("#nrdconta","#frmHabilita").bind("keydown",function(e) {
		// Captura código da tecla pressionada
		var keyValue = getKeyValue(e);
		
		// Se o botão enter foi pressionado, carrega dados da conta
		if (keyValue == 13) {
			obtemDadosConta(); 
			return false;
		}	
		
		// Seta máscara ao campo
		return $(this).setMaskOnKeyDown("INTEGER","zzzz.zzz-z","",e);
	});		
	
	// Evento onKeyDown no campo "nrdctitg"
	$("#nrdctitg","#frmHabilita").bind("keydown",function(e) {
		// Captura código da tecla pressionada
		var keyValue = getKeyValue(e);

		// Se o botão enter foi pressionado, carrega dados da conta
		if (keyValue == 13) {
			$(this).blur();
			obtemDadosConta();
			return false;
		}			
	});	

	$("#nrdctitg","#frmHabilita").setMask("STRING","9.999.999-9",".-","");
	$("#nrctapam","#frmHabilita").setMask("INTEGER","zzzz.zzz-z","","");
	
});


// seletores
function estadoInicial() {
	
	$('#divTela').fadeTo(0,0.1);
	
	fechaRotina( $('#divRotina') );
	
	cddopcao = "";
	
	trocaBotao("Alterar","frmLimite");
	trocaBotao("Alterar","frmHabilita");
	
	$("#btnAlterar","#frmHabilita").css('display', 'none');
	$("#btnImprime","#frmHabilita").css('display', 'none');
	
	controlaLayout(true);

	$('#nmrescop','#frmLimite').val(1);
		
	cCamposAltera.limpaFormulario();
	cCddopcao.val(cddopcao);
	
	removeOpacidade('divTela');
	return false;
	
}

function controlaLayout(carregaCoops) {

	// cabecalho
	rCddopcao			= $('label[for="cddopcao"]'	,'#frmCab'); 
	rNmrescop           = $('label[for="nmrescop"]'	,'#divCooper');
	rVllimpam			= $('label[for="vllimpam"]'	,'#frmLimite'); 
	rVlpamuti			= $('label[for="vlpamuti"]'	,'#frmLimite'); 
	rVlmenpam			= $('label[for="vlmenpam"]'	,'#frmLimite'); 
	rPrtaxpam			= $('label[for="prtaxpam"]'	,'#frmLimite');

	rNrdconta           = $('label[for="nrdconta"]'	,'#frmHabilita');
	rNrdctitg			= $('label[for="nrdctitg"]'	,'#frmHabilita'); 
	rDssititg			= $('label[for="dssititg"]'	,'#frmHabilita'); 
	rNmprimtl			= $('label[for="nmprimtl"]'	,'#frmHabilita'); 
	rNrcpfcgc			= $('label[for="nrcpfcgc"]'	,'#frmHabilita');
	rFlgpamca           = $('label[for="flgpamca"]'	,'#frmHabilita');
	rVllimpaH           = $('label[for="vllimpaH"]'	,'#frmHabilita');
	rDddebpam           = $('label[for="dddebpam"]'	,'#frmHabilita');
	rNrctapam           = $('label[for="nrctapam"]'	,'#frmHabilita');
	
	rNmarquiv           = $('label[for="nmarquiv"]' ,'#frmProcessa');
	
	rDtinicio           = $('label[for="dtinicio"]' ,'#frmLogProcesso');
	rDtfim              = $('label[for="dtfim"]'    ,'#frmLogProcesso');
	
	rNmrelato           = $('label[for="nmrelato"]' ,'#frmRelatorio');
	
	cCddopcao			= $('#cddopcao'	,'#frmCab'); 
	cNmrescop           = $('#nmrescop'	,'#divCooper');
	cVllimpam			= $('#vllimpam'	,'#frmLimite');
	cVlpamuti			= $('#vlpamuti'	,'#frmLimite');
	cVlmenpam			= $('#vlmenpam'	,'#frmLimite');
	cPrtaxpam			= $('#prtaxpam'	,'#frmLimite');
	
	cNrdconta           = $('#nrdconta'	,'#frmHabilita');
	cNrdctitg			= $('#nrdctitg'	,'#frmHabilita');
	cDssititg			= $('#dssititg'	,'#frmHabilita');
	cNmprimtl			= $('#nmprimtl'	,'#frmHabilita');
	cNrcpfcgc			= $('#nrcpfcgc'	,'#frmHabilita');
	cFlgpamca			= $('#flgpamca'	,'#frmHabilita');
	cVllimpaH			= $('#vllimpaH'	,'#frmHabilita');
	cDddebpam			= $('#dddebpam'	,'#frmHabilita');
	cNrctapam			= $('#nrctapam'	,'#frmHabilita');
	
	cNmarquiv           = $('#nmarquiv' ,'#frmProcessa');
	
	cDtinicio           = $('#dtinicio' ,'#frmLogProcesso');
	cDtfim              = $('#dtfim'    ,'#frmLogProcesso');
	
	cNmrelato           = $('#nmrelato' ,'#frmRelatorio');
	
	cCamposAltera		= $('#vllimpam,#vlmenpam,#prtaxpam','#frmLimite');
	cCamposAlteraH      = $('#vllimpaH,#dddebpam,#nrctapam','#frmHabilita');
	var btnOK			= $('#btnOK','#frmCab');
	
	rCddopcao.addClass('rotulo').css({'width':'68px'});
	cCddopcao.css({'width':'456px'});
	
	$('#divLimite').css({'display':'none'});
	$('#divHabilita').css({'display':'none'});
	$('#divProcessa').css({'display':'none'});
	$('#divLogProcesso').css({'display':'none'});
	$('#divRelatorio').css({'display':'none'});
	
	
	// Formata
	if ( cddopcao == 'L' ) {
	
		$("#frmLimite").css({'display':'block'});
	
		rNmrescop.addClass('rotulo').css({'width':'75px'});
		rVllimpam.addClass('rotulo').css({'width':'40px','margin-left':'35px'});	
		rVlpamuti.addClass('rotulo-linha').css({'width':'100px','margin-left':'93px'});		
		rVlmenpam.addClass('rotulo').css({'width':'75px'});		
		rPrtaxpam.addClass('rotulo').css({'width':'55px','margin-left':'20px'});
		
		cNmrescop.addClass('rotulo').css('width','130px');
		cVllimpam.addClass('monetario').css({'width':'130px'});	
		cVlpamuti.addClass('monetario').css({'width':'130px','float':'right','margin-right':'20px'});		
		cVlmenpam.addClass('monetario').css({'width':'70px'});
		cPrtaxpam.addClass('porcento').css({'width':'70px'});
		
		cCamposAltera.desabilitaCampo();
		cVlpamuti.desabilitaCampo();
		
		buscaRegistro(carregaCoops);
		
			
	} else if (cddopcao == 'H'){
	
		$("#frmHabilita").css({'display':'block'});
	
		rNrdconta.addClass('rotulo').css({'width':'68px'});
		cNrdconta.addClass('rotulo').css('width','80px');
		rNrdctitg.addClass('rotulo-linha').css({'width':'60px','margin-left':'5px'});	
		cNrdctitg.addClass('rotulo-linha').css({'width':'80px'});	
		rDssititg.addClass('rotulo-linha').css({'width':'100px','margin-left':'115px'});
		cDssititg.addClass('rotulo-linha').css({'width':'50px'});		
		rNmprimtl.addClass('rotulo').css({'width':'115px'});		
		cNmprimtl.addClass('rotulo').css({'width':'450px'});
		rNrcpfcgc.addClass('rotulo').css({'width':'115px'} );
		cNrcpfcgc.addClass('rotulo').css({'width':'150px'});
		
		rFlgpamca.addClass('rotulo').css({'width':'115px'});
		cFlgpamca.addClass('rotulo').css({'width':'50px'});
		
		rVllimpaH.addClass('rotulo').css({'width':'115px'});
		cVllimpaH.addClass('monetario').css({'width':'90px'});
		
		rDddebpam.addClass('rotulo').css({'width':'115px'});
		cDddebpam.addClass('rotulo').css({'width':'50px'});
		
		rNrctapam.addClass('rotulo').css({'width':'115px'});
		cNrctapam.addClass('rotulo').css({'width':'90px'});
	
		cDssititg.desabilitaCampo();
		cNmprimtl.desabilitaCampo();
		cNrcpfcgc.desabilitaCampo();
		cFlgpamca.desabilitaCampo();
		
		$('input,select', '#frmHabilita').limpaFormulario();
								
		$('#divHabilita').css({'display':'block'});
		
		cCamposAlteraH.desabilitaCampo();
		
		cNrdctitg.habilitaCampo();
		cNrdconta.habilitaCampo().focus();
				
	} else if (cddopcao == 'P'){
	
		$("#frmProcessa").css({'display':'block'});
	
		rNmarquiv.addClass('rotulo').css({'width':'120px'});
		
		cNmarquiv.addClass('rotulo').css('width','350px');
		cNmarquiv.val("");
		cNmarquiv.desabilitaCampo();
	
		$('#divProcessa').css({'display':'block'});
	
	} else if (cddopcao == 'X'){
	
		$("#frmLogProcesso").css({'display':'block'});
	
		rDtinicio.addClass('rotulo-linha').css({'width':'75px','margin-left':'100px'});
		rDtfim.addClass('rotulo-linha').css({'width':'75px'});
		
		cDtinicio.addClass('data').css({'width':'75px'});	
		cDtfim.addClass('data').css({'width':'75px'});
		
		cDtinicio.habilitaCampo();
		cDtfim.habilitaCampo();
			
		$('#divLog').html("");
	
		$('#divLogProcesso').css({'display':'block'});
		
		cDtfim.val("");
		cDtinicio.val("").focus();
	
	} else if (cddopcao == 'R'){
		
		$("#frmRelatorio").css({'display':'block'});
	
		rNmrelato.addClass('rotulo').css({'width':'120px'});
		cNmrelato.addClass('rotulo').css('width','350px');
		
		buscaRelatorios();
	
	}
	
	cCddopcao.habilitaCampo();
	
	cCddopcao.unbind('change').bind('change', function() { 	
		cddopcao = cCddopcao.val();
		return false;

	});	
		
	// Se clicar no botao OK
	btnOK.unbind('click').bind('click', function() { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( cCddopcao.hasClass('campoTelaSemBorda') ) { return false; }
		
		// Armazena o número da conta na variável global
		cddopcao = cCddopcao.val();
		if ( cddopcao == '' ) { return false; }

		cCamposAltera.removeClass('campoErro');
		
		controlaLayout(true);
		cCddopcao.desabilitaCampo();
		
		return false;
			
	});
	
	cVllimpam.unbind('keypress').bind('keypress', function(e) { 
		if (e.keyCode == 9 || e.keyCode == 13 ) {	
			cVlmenpam.focus();
			return false;
		}		
	});
	
	cVlmenpam.unbind('keypress').bind('keypress', function(e) { 
		if (e.keyCode == 9 || e.keyCode == 13 ) {	
			cPrtaxpam.focus();
			return false;
		}		
	});
	
	cPrtaxpam.unbind('keypress').bind('keypress', function(e) { 
		if (e.keyCode == 9 || e.keyCode == 13 ) {	
			verificaPermissao();
			return false;
		}		
	});
	
	cVllimpaH.unbind('keypress').bind('keypress', function(e) { 
		if (e.keyCode == 9 || e.keyCode == 13 ) {	
			cDddebpam.focus();
			return false;
		}		
	});
	
	cDddebpam.unbind('keypress').bind('keypress', function(e) { 
		if (e.keyCode == 9 || e.keyCode == 13 ) {	
			cNrctapam.focus();
			return false;
		}		
	});
	
	cNrctapam.unbind('keypress').bind('keypress', function(e) { 
		if (e.keyCode == 9 || e.keyCode == 13 ) {	
			gravaRegistroConvenio();
			return false;
		}		
	});
	
	cDtinicio.unbind("keypress").bind("keypress",function(e) {
		// Captura código da tecla pressionada
		var keyValue = getKeyValue(e);
		
		if (keyValue == 13) {
			cDtfim.focus();
			return false;
		}
	});
	
	cDtfim.unbind("keypress").bind("keypress",function(e) {
		// Captura código da tecla pressionada
		var keyValue = getKeyValue(e);
		
		if (keyValue == 13) {
			exibeLog();
			return false;
		}
	});
	
	// Se clicar no Anotações
	$('#anotacao','#divHabilita').unbind('click').bind('click', function() { 	
		
		if( $('#nrdconta','#divHabilita').val() != '' ){
			buscaAnotacoes();
			
		}else{
			showError("error","Conta/dv inv&aacute;lida.","Alerta - Ayllos","blockBackground(); unblockBackground(); $('#nrdconta','#divHabilita').focus();");
			
		}
		
		return false;
						
	});

	layoutPadrao();
	return false;	
}

function verificaPermissao(){
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, verificando permiss&atilde;o para altera&ccedil;&atilde;o ...");
	
	// Executa script de consulta através de ajax
	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/pamcar/verifica_permissao.php", 
		data: {
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});				


}

function liberaCampos(){

	cCamposAltera.habilitaCampo();
	cNmrescop.desabilitaCampo();
	cVllimpam.focus();
	trocaBotao("Concluir","frmLimite");

}

function trocaBotao(nmBotao, frame) {

	$('#divBotoes','#'+frame).html('');
	$('#divBotoes','#'+frame).append('<a href="#" class="botao" id="btVoltar" onClick="estadoInicial(); return false;">Voltar</a>	');
			
	if (frame == "frmLimite"){
		if (nmBotao == "Concluir")
			$('#divBotoes','#frmLimite').append('<a href="#" class="botao" id="btnSalvar" onClick="criaAlteraRegistro(); return false;">' + nmBotao + '</a>');
		else
			$('#divBotoes','#frmLimite').append('<a href="#" class="botao" id="btnAlterar" onClick="verificaPermissao(); return false;">' + nmBotao + '</a>');
	} else
	if (frame == "frmHabilita"){
	
		if (nmBotao == "Concluir")
			$('#divBotoes','#frmHabilita').append('<a href="#" class="botao" id="btnSalvar" onClick="gravaRegistroConvenio(); return false;">' + nmBotao + '</a>');
		else{
			$('#divBotoes','#frmHabilita').append('<a href="#" class="botao" id="btnAlterar" onClick="alteraCamposHabilitacao(); return false;">' + nmBotao + '</a>');		
		}
	} 
	
	$('#divBotoes','#frmHabilita').append('<a href="#" class="botao" id="btnImprime" onClick="geraTermo(); return false;"> Imprimir Contrato </a>');
	
	return false;
}

function criaAlteraRegistro(){

	var vllimpam = $('#vllimpam','#frmLimite').val();
	var vlmenpam = $('#vlmenpam','#frmLimite').val();
	var pertxpam = $('#prtaxpam','#frmLimite').val();
	var cdcooper = $('#nmrescop','#frmLimite').val();
	
	
	if ((!validaNumero(vllimpam,true,0,0)) || (vllimpam == "")){
		showError("error","Valor do limite inv&aacute;lido.","Alerta - Ayllos","$('#vllimpam','#frmLimite').focus();");
		return false;
	}
	
	if ((!validaNumero(vlmenpam,true,0,0)) || (vlmenpam == "")){
		showError("error","Valor da mensalidade inv&aacute;lido.","Alerta - Ayllos","$('#vlmenpam','#frmLimite').focus();");
		return false;
	}
	
	if ((!validaNumero(pertxpam,true,0,0)) || (pertxpam == "")){
		showError("error","Valor da taxa inv&aacute;lido.","Alerta - Ayllos","$('#prtaxpam','#frmLimite').focus();");
		return false;
	}

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, salvando altera&ccedil;&otilde;es ...");
	
	// Executa script de consulta através de ajax
	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/pamcar/grava_registro.php", 
		data: {
			vllimpam: vllimpam,
			vlmenpam: vlmenpam,
			pertxpam: pertxpam,
			cdcooper: cdcooper,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				estadoInicial();					
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});

}

function buscaRegistro(carregaCoops){	

	var coopSelected = $('#nmrescop','#frmLimite').val();

		
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, buscando informa&ccedil;&otilde;es ...");
	
	// Executa script de consulta através de ajax
	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/pamcar/busca_registro.php", 
		data: {
			carregaCoops: carregaCoops,
			coopSelected: coopSelected,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				//$('#divTela').html(response);
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});

}

function setaValores(vllimpam, vlpamuti, vlmenpam, pertxpam){

	$('#vllimpam','#frmLimite').val(number_format(vllimpam.replace(",", "."), 2, ",", "."));
	$('#vlpamuti','#frmLimite').val(number_format(vlpamuti.replace(",", "."), 2, ",", "."));
	$('#vlmenpam','#frmLimite').val(number_format(vlmenpam.replace(",", "."), 2, ",", "."));
	$('#prtaxpam','#frmLimite').val(number_format(pertxpam.replace(",", "."), 2, ",", "."));

}

function carregaCooperativas(qtdCooperativas){

	//cNmrescop.addClass('rotulo').css('width','130px');
	
	for (var i = 0; i < qtdCooperativas; i++) {
		$('option','#divCooper').remove();
		
	}
	
	
	for (var i = 0; i < qtdCooperativas; i++) {
		cNmrescop.append("<option id='"+i+"' value='"+lstCooperativas[i].cdcooper+"'>"+lstCooperativas[i].nmrescop+"</option>");
	}
	
	
	cNmrescop.habilitaCampo();

}

// Função para carregar dados da conta informada
function obtemDadosConta() {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando dados da conta/dv ...");		
	
	// Armazena conta/dv e conta/itg informadas
	nrdconta = retiraCaracteres($("#nrdconta","#frmHabilita").val(),"0123456789",true);
	nrdctitg = retiraCaracteres($("#nrdctitg","#frmHabilita").val().toUpperCase(),"0123456789X",true);
	
	// Se nenhum dos tipos de conta foi informado
	if (nrdconta == "" && nrdctitg == "") {
		hideMsgAguardo();
		showError("error","Informe o n&uacute;mero da Conta/dv ou da Conta/Itg.","Alerta - Ayllos","$('#nrdconta','#frmHabilita').focus()");
		return false;
	}

	// Se conta/dv foi informada, valida
	if (nrdconta != "") { 
		if (!validaNroConta(nrdconta)) {
			hideMsgAguardo();
			showError("error","Conta/dv inv&aacute;lida.","Alerta - Ayllos","$('#nrdconta','#frmHabilita').focus()");
			//limparDadosCampos();
			return false;
		}
	} 
	
	// Carrega dados da conta através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/pamcar/obtem_dados_conta.php", 		
		data: {
			nrdconta: nrdconta,
			nrdctitg: nrdctitg,
			redirect: "script_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#nrdconta','#frmHabilita').focus()");
		},
		success: function(response) {			
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();					
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrdconta','#frmHabilita').focus()");				
			}			
		}				
	}); 
}

function alteraCamposHabilitacao(){

	if (cNrdconta.val() == 0) {
		showError("error","Conta/dv inv&aacute;lida.","Alerta - Ayllos","$('#nrdconta','#frmHabilita').focus()");
		return false;
	}

	cFlgpamca.habilitaCampo();

	if (cFlgpamca.val() == "S") {
		if (flgdemis == "no") {
			cCamposAlteraH.habilitaCampo();
			cVllimpaH.focus();
		}
	}
	else {
		cCamposAlteraH.desabilitaCampo();
	}
	trocaBotao("Concluir","frmHabilita");
	
	vllimpam = cVllimpaH.val();
	dddebpam = cDddebpam.val();
	nrctapam = cNrctapam.val();

}

// Função para buscar anotações do associado
function buscaAnotacoes() {
	// Mostra mensagem de aguardo	
	showMsgAguardo("Aguarde, carregando anota&ccedil;&otilde;es ...");
	
	// Carrega dados da conta através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/atenda/busca_anotacoes.php", 
		data: {
			nrdconta: nrdconta,			
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divAnotacoes').css('z-index')))");
		},
		success: function(response) {
			$("#divListaAnotacoes").html(response);
		}				
	});	
}

function gravaRegistroConvenio(){

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, salvando altera&ccedil;&otilde;es ...");

	var nrcpfcgc = $('#nrcpfcgc','#frmHabilita').val();
	var flgpamca = $('#flgpamca','#frmHabilita').val();
	var vllimpam = $('#vllimpaH','#frmHabilita').val();
	var dddebpam = $('#dddebpam','#frmHabilita').val();
	var nrctapam = retiraCaracteres($("#nrctapam","#frmHabilita").val(),"0123456789",true);
	
	// Armazena conta/dv informada
	nrdconta = retiraCaracteres($("#nrdconta","#frmHabilita").val(),"0123456789",true);
	
	// Se a conta/dv nao foi informada
	if (nrdconta == "") {
		hideMsgAguardo();
		showError("error","Informe o n&uacute;mero da Conta/dv.","Alerta - Ayllos","$('#nrdconta','#frmHabilita').focus()");
		return false;
	}

	// Se conta/dv foi informada, valida
	if (nrdconta != "") { 
		if (!validaNroConta(nrdconta)) {
			hideMsgAguardo();
			showError("error","Conta/dv inv&aacute;lida.","Alerta - Ayllos","$('#nrdconta','#frmHabilita').focus()");
			return false;
		}
	}
	
	
	if (flgpamca == "S"){
	
		if (flgdemis == "yes"){
			hideMsgAguardo();
			showError("error","O conv&ecirc;nio precisa ser inativado pois o cooperado est&aacute; demitido!","Alerta - Ayllos","$('#flgpamca','#frmHabilita').focus();");
			return false;
		}
	
		if ((!validaNumero(vllimpam,true,0,0)) || (vllimpam == "")){
			hideMsgAguardo();
			showError("error","Valor do limite inv&aacute;lido.","Alerta - Ayllos","$('#vllimpaH','#frmHabilita').focus();");
			return false;
		}
	
		if ((!validaNumero(dddebpam,true,0,0)) || (dddebpam == "")){
			hideMsgAguardo();
			showError("error","Dia do d&eacute;bito inv&aacute;lido.","Alerta - Ayllos","$('#dddebpam','#frmHabilita').focus();");
			return false;
		}
	
		// Se a conta duplicada nao foi informada
		if (nrctapam == "") {
			hideMsgAguardo();
			showError("error","Informe o n&uacute;mero da Conta Duplicada.","Alerta - Ayllos","$('#nrctapam','#frmHabilita').focus()");
			return false;
		}
		
			
		//Se a conta duplicada nao for diferente da conta origem
		if (nrctapam == nrdconta) {
			hideMsgAguardo();
			showError("error","Conta Duplicada deve ser diferente do n&uacute;mero da conta.","Alerta - Ayllos","$('#nrctapam','#frmHabilita').focus()");
			return false;
		}

		// Se conta duplicada foi informada, valida
		if (nrctapam != "") { 
			if (!validaNroConta(nrctapam)) {
				hideMsgAguardo();
				showError("error","Conta Duplicada inv&aacute;lida.","Alerta - Ayllos","$('#nrctapam','#frmHabilita').focus()");
				return false;
			}
		}
	}
	
	// Executa script de consulta através de ajax
	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/pamcar/grava_registro_convenio.php", 
		data: {
			nrdconta: nrdconta,
			nrcpfcgc: nrcpfcgc,
			flgpamca: flgpamca,
			vllimpam: vllimpam,
			dddebpam: dddebpam,
			nrctapam: nrctapam,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});

}

function geraTermo(){

	// Armazena conta/dv informada
	nrdconta = retiraCaracteres($("#nrdconta","#frmHabilita").val(),"0123456789",true);
	
	// Se a conta/dv nao foi informada
	if (nrdconta == "") {
		hideMsgAguardo();
		showError("error","Informe o n&uacute;mero da Conta/dv.","Alerta - Ayllos","$('#nrdconta','#frmHabilita').focus()");
		return false;
	}

	// Se conta/dv foi informada, valida
	if (nrdconta != "") { 
		if (!validaNroConta(nrdconta)) {
			hideMsgAguardo();
			showError("error","Conta/dv inv&aacute;lida.","Alerta - Ayllos","$('#nrdconta','#frmHabilita').focus()");
			return false;
		}
	}	
	
	imprimeTermo();
	
}

function imprimeTermo() {
	
	var nrdconta = retiraCaracteres($("#nrdconta","#frmHabilita").val(),"0123456789",true);
	var flgpamca = $('#flgpamca','#frmHabilita').val();
	var sidlogin = $('#sidlogin','#frmMenu').val();
	
	$('#nrdconta','#frmImpressao').remove();
	$('#flgpamca','#frmImpressao').remove();
	$('#sidlogin','#frmImpressao').remove();
	
	$('#frmImpressao').append('<input type="hidden" id="nrdconta" name="nrdconta" value="'+nrdconta+'"/>');
	$('#frmImpressao').append('<input type="hidden" id="flgpamca" name="flgpamca" value="'+flgpamca+'"/>');	
	$('#frmImpressao').append('<input type="hidden" id="sidlogin" name="sidlogin" value="'+sidlogin+'"/>');
	
	var action = UrlSite + "telas/pamcar/gera_termo.php";	
		
	carregaImpressaoAyllos("frmImpressao",action);
	
}

function mostraArquivos(){

	var bo        = 'b1wgen0059.p';
	var procedure = 'busca_arquivos_pamcard';
	var titulo    = 'Arquivos de D&eacute;bitos - PAMCARD';
	var qtReg     = '50';
	var filtro    = 'Arquivo;nmarquiv;100px;S;""';
	var colunas   = 'Arquivos;nmarquiv;55%;left';
		
	mostraPesquisa(bo,procedure,titulo,qtReg,filtro,colunas,'','');	
	
	
	
	return false;


}

function processaArquivoDebito(){

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, processando arquivo de d&eacute;bito ...");

	var nmarquiv = $('#nmarquiv','#frmProcessa').val();
	
	// Se o arquivo de debito nao foi informado
	if (nmarquiv == "") {
		hideMsgAguardo();
		showError("error","Selecione o arquivo para d&eacute;bito.","Alerta - Ayllos","$('#nmarquiv','#frmProcessa').focus()");
		return false;
	}
	
	// Executa script de consulta através de ajax
	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/pamcar/processa_arquivo_debito.php", 
		data: {
			nmarquiv: nmarquiv,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});
}

function exibeLog(){

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando log dos arquivos ...");
	
	$('#divLog').html("");

	var dtinicio = $('#dtinicio','#frmLogProcesso').val();
	var dtfim    = $('#dtfim','#frmLogProcesso').val();
	
	// Se a data inicial nao foi informada
	if (dtinicio == "") {
		hideMsgAguardo();
		showError("error","Data inicial n&atilde;o informada.","Alerta - Ayllos","$('#dtinicio','#frmLogProcesso').focus()");
		return false;
	}
	
	// Se a data final nao foi informada
	if (dtfim == "") {
		hideMsgAguardo();
		showError("error","Data final n&atilde;o informada.","Alerta - Ayllos","$('#dtfim','#frmLogProcesso').focus()");
		return false;
	}
	
	// Executa script de consulta através de ajax
	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/pamcar/exibe_log.php", 
		data: {
			dtinicio: dtinicio,
			dtfim: dtfim,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});

}

function formataTabelaLog() {

	/*****************************
			FORMATA TABELA		
	******************************/
	// tabela	
	var divDados = $('div.divRegistros', '#divLogProcesso');		
	var tabela      = $('table', divDados );
	var linha       = $('table > tbody > tr', divDados );
			
	divDados.css({'height':'140px'});
	
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];
			
	var arrayLargura = new Array();
	arrayLargura[0] = '110px';
	arrayLargura[1] = '150px';
	arrayLargura[2] = '148px';
	
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'center';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha );
	
}

function carregaRelatorios(){
	
	for (var i = -2; i < lstRelatorios.length; i++) {
		$('option','#divRelatorio').remove();
	}
	
	cNmrelato.append("<option id='chqespec' value='chqespec'>Limite de Cheque Especial</option>");
	cNmrelato.append("<option id='inforcad' value='inforcad'>Informa&ccedil;&otilde;es Cadastrais</option>");
	
	for (var i = 0; i < lstRelatorios.length; i++) {
		cNmrelato.append("<option id='"+i+"' value='"+lstRelatorios[i].substr(0, lstRelatorios[i].indexOf(".") + 1) + "pdf"+"'>Processamento PAMCARD - " + lstRelatorios[i]+"</option>");
	}
	
	cNmrelato.habilitaCampo();

}

function buscaRelatorios(){

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando relat&oacute;rios ...");
	
	// Executa script de consulta através de ajax
	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/pamcar/busca_relatorio.php", 
		data: {
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});

}

function imprimeRelatorio() {
	
	$('#nmarqpdf','#frmImpressao').remove();	
	$('#sidlogin','#frmImpressao').remove();
	
	if ($('#nmrelato option:selected','#frmRelatorio').attr('id') == 'chqespec' ||
		$('#nmrelato option:selected','#frmRelatorio').attr('id') == 'inforcad') {
		
			$('#frmImpressao').append('<input type="hidden" id="nmarqpdf" name="nmarqpdf" value="'+$('#nmrelato','#frmRelatorio').val()+'"/>');
				
		} else {
		
			$('#frmImpressao').append('<input type="hidden" id="nmarqpdf" name="nmarqpdf" value="crrl615_'+$('#nmrelato','#frmRelatorio').val()+'"/>');
		
		}
		
	$('#frmImpressao').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '" />');	 
	
	var action = UrlSite + "telas/pamcar/gera_relatorio.php";				
	
	carregaImpressaoAyllos("frmImpressao",action);

}
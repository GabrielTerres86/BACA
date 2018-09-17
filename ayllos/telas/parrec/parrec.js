/*!
 * FONTE        : parrec.js
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 31/01/2017
 * OBJETIVO     : Biblioteca de funções da tela PARREC
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */

// Definição de algumas variáveis globais 
var cddopcao		= 'C';
var aux_cdbccxlt;
var aux_nrispbif;
//Labels/Campos do cabeçalho
var cCddopcao, cCdcooper, cFlgsitsac, cFlgsittaa, cFlgsitibn, cVlrmaxpf, cVlrmaxpj, 
	cNrispbif, cCdbccxlt, cNmresbcc, cCdageban, cNmageban, cNrdconta, cNrdocnpj, cDsdonome,
	cDsmsgsaldo, cDsmsgoperac, cTodosCabecalho, cTodosParrec, btnCab;	

$(document).ready(function() {

	estadoInicial();
	
	highlightObjFocus( $('#frmCab') );
	
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	
	return false;
	
	
});

// seletores
function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);
	$('#frmCab').css({'display':'block'});
	$('#frmParrec').css({'display':'none'});
	$('#frmParrec').limpaFormulario();
	$('#divSingulares', '#frmParrec').css({'display':'none'});
	$('#divCecred', '#frmParrec').css({'display':'none'});
	$('#divMensagens', '#frmParrec').css({'display':'none'});
	$('#divBotoes').css({'display':'none'});
	$('input,select', '#frmCab').removeClass('campoErro');	
	
	// Zera variáveis
	aux_cdbccxlt = 0;
	aux_nrispbif = 0;
	
	formataCabecalho();

	cCddopcao.val( cddopcao );
	removeOpacidade('divTela');	
	unblockBackground();
	hideMsgAguardo();
	
	$("#btVoltar","#divBotoes").hide();
	
	controlaFoco();
	controlaPesquisa()
}

function controlaFoco() {
		
	/* -------------- Cabeçalho - INICIO -------------- */
	
	$('#btnOK','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			btnContinuar();
			return false;
		}	
	});

	$('#btnOK','#frmCab').unbind('click').bind('click', function(e) {
		if (!($('#cddopcao', '#frmCab').hasClass('campoTelaSemBorda'))){
			btnContinuar();
		}
		return false;
	});
	
	$('#cddopcao','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			if ($(this).val() == 'M'){
				$('#btnOK','#frmCab').click();				
			}else{
				cCdcooper.focus();
			}
			return false;
		}	
	});
	
	$('#cddopcao','#frmCab').unbind('change').bind('change', function(e) {
		if ($(this).val() == 'M'){
			$('#cdcooper','#frmCab').css('display', 'none');
			$('label[for="cdcooper"]','#frmCab').css('display','none');
			$('#cdcooper','#frmCab').desabilitaCampo();
			return false;
		}else{
			$('#cdcooper','#frmCab').css('display', 'block');
			$('label[for="cdcooper"]','#frmCab').css('display','block');
			$('#cdcooper','#frmCab').habilitaCampo();
			return false;
		}
	});
	
	$('#cdcooper','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#btnOK','#frmCab').click();
			return false;
		}	
	});
	
	/* -------------- Cabeçalho - FIM -------------- */
	
	/* --- Opções A,C (Coop Singulares) - INICIO --- */
	
	$('#vlrmaxpf','#frmParrec').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 13 ) {	
			$('#vlrmaxpj','#frmParrec').select();
			return false;
		}	
	});
	
	$('#vlrmaxpj','#frmParrec').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 13 ) {	
			$('#btProsseguir','#divBotoes').click();
			return false;
		}	
	});
	
	$('#vlrmaxpf','#frmParrec').attr('tabindex', 1);
	$('#vlrmaxpj','#frmParrec').attr('tabindex', 2);
	$('#btProsseguir','#divBotoes').attr('tabindex', 3);
	
	/* ---- Opções A,C (Coop Singulares) - FIM ---- */
	
	/* ------- Opções A,C (CECRED) - INICIO ------- */
	
	$('#cdageban','#frmParrec').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#nrdconta','#frmParrec').focus();
			$(this).removeClass('campoErro');
		}
	});
	
	$('#cdageban','#frmParrec').unbind('focusout').bind('focusout', function(e) {
		$(this).removeClass('campoErro campoFocusIn');
		$(this).addClass('campo');
		if ($(this).val() == '' || $(this).val() == 'undefined'){
			$(this).val(0);
			$(this).trigger('change');
		}
	});
	
	
	$('#nrdconta','#frmParrec').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#nrdocnpj','#frmParrec').focus();
		}
	});
	
	$('#nrdocnpj','#frmParrec').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#dsdonome','#frmParrec').focus();
		}
	});
	
	$('#dsdonome','#frmParrec').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			btnContinuar();
		}
	});
	
	/* --------- Opções A,C (CECRED) - FIM -------- */
	
}

function controlaPesquisa(){
	
	var bo        = '';
	var procedure = '';
	var titulo    = '';
	var qtReg	  = '';
	var filtros   = '';
    var colunas   = '';
	
	$('#btLupaISPB','#frmParrec').css('cursor', 'pointer').unbind('click').bind('click', function () {
		if ($('#nrispbif','#frmParrec').hasClass('campoTelaSemBorda')) { return false; }	
			bo			= 'BANCOS';
			procedure	= 'PESQUISABANCO';
			titulo      = 'Institui&ccedil;&atilde;o Financeira';
			qtReg		= '30';
			filtros 	= 'C&oacutedigo;cdbccxlt;30px;N;;N|Instituição Financeira;nmresbcc;300px;S;;S|ISPB;nrispbif;75px;N;;N'
			colunas 	= 'Banco;cdbccxlt;10%;left|Nome Abreviado;nmresbcc;40%;left|ISPB;nrispbif;20%;left|Operando no STR;flgdispb;25%;left';										
			mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'frmParrec', 'retornoPesquisaISPB();');					
			$("#divCabecalhoPesquisa > table").css("width","600px");
			$("#divResultadoPesquisa > table").css("width","600px");
			$("#divCabecalhoPesquisa").css("width","600px");
			$("#divResultadoPesquisa").css("width","600px");
			$("#divCabecalhoPesquisa > table > thead > tr").append('<td style="width:2%;">&nbsp;</td>');
			$('#nmresbccPesquisa', '#formPesquisa').attr('maxlength','20');			
			$('#divPesquisa').centralizaRotinaH();
			
		return false;
    });
	
	$('#nrispbif','#frmParrec').unbind('keyup').bind('keyup', function (e) {
		if (e.keyCode == 13 ) {	
			bo			= 'BANCOS';
			procedure	= 'PESQUISABANCO';
			titulo      = 'Institui&ccedil;&atilde;o Financeira';
			qtReg		= '30';
			filtros 	= 'C&oacutedigo;cdbccxlt;30px;N;;N|Instituição Financeira;nmresbcc;300px;S;;S|ISPB;nrispbif;75px;N;' + $(this).val() + ';N'
			colunas 	= 'Banco;cdbccxlt;10%;left|Nome Abreviado;nmresbcc;40%;left|ISPB;nrispbif;20%;left|Operando no STR;flgdispb;25%;left';										
			mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'frmParrec', 'retornoPesquisaISPB();');
			$("#divCabecalhoPesquisa > table").css("width","600px");
			$("#divResultadoPesquisa > table").css("width","600px");
			$("#divCabecalhoPesquisa").css("width","600px");
			$("#divResultadoPesquisa").css("width","600px");
			$("#divCabecalhoPesquisa > table > thead > tr").append('<td style="width:2%;">&nbsp;</td>');		
			$('#nmresbccPesquisa', '#formPesquisa').attr('maxlength','20');									
			$('#divPesquisa').centralizaRotinaH();
			$("#nrispbifPesquisa").val('');
			return false;			
		}
	});
	
	$('#nrispbif','#frmParrec').unbind('change').bind('change', function () {
		bo			= 'BANCOS';
		procedure	= 'PESQUISABANCO';
		titulo      = 'Institui&ccedil;&atilde;o Financeira';
		qtReg		= '30';
		filtros 	= 'C&oacutedigo;cdbccxlt;30px;N;;N|Instituição Financeira;nmresbcc;300px;S;;S|ISPB;nrispbif;75px;N;' + $(this).val() + ';N'
		colunas 	= 'Banco;cdbccxlt;10%;left|Nome Abreviado;nmresbcc;40%;left|ISPB;nrispbif;20%;left|Operando no STR;flgdispb;25%;left';										
		mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'frmParrec', 'retornoPesquisaISPB();');
		$("#divCabecalhoPesquisa > table").css("width","600px");
		$("#divResultadoPesquisa > table").css("width","600px");
		$("#divCabecalhoPesquisa").css("width","600px");
		$("#divResultadoPesquisa").css("width","600px");
		$("#divCabecalhoPesquisa > table > thead > tr").append('<td style="width:2%;">&nbsp;</td>');	
		$('#nmresbccPesquisa', '#formPesquisa').attr('maxlength','20');					
		$('#divPesquisa').centralizaRotinaH();
		$("#nrispbifPesquisa").val('');
		return false;
	});
	
	$('#btLupaAge','#frmParrec').css('cursor', 'pointer').unbind('click').bind('click', function () {
		if ($('#cdageban','#frmParrec').hasClass('campoTelaSemBorda')) { return false; }	
		if ($('#cdbccxlt','#frmParrec').val() == '') {
			showError('error','Informe o banco','Alerta - Ayllos', 'unblockBackground()');			
			return false;
		}		
		bo			= 'b1wgen0059.p';
		procedure	= 'busca_agencia';
		titulo      = 'Agência';
		qtReg		= '30';
		filtros 	= 'Cód. Agência;cdageban;30px;S;0|Agência;nmageban;200px;S;|Cód. Banco;cdbccxlt;30px;N;|Banco;nmresbcc;200px;N;';
		colunas 	= 'Código;cdageban;20%;right|Agência;nmageban;80%;left';
		mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'frmParrec', '$(\'#nrdconta\', \'#frmParrec\').focus()');
		$("#divCabecalhoPesquisa > table").css("width","500px");
		$("#divResultadoPesquisa > table").css("width","500px");
		$("#divCabecalhoPesquisa").css("width","500px");
		$("#divResultadoPesquisa").css("width","500px");
		$('#divPesquisa').centralizaRotinaH();		
		return false;
	});
	
		// Agencia
	$('#cdageban','#frmParrec').unbind('change').bind('change', function() {	
		if ($('#cdbccxlt','#frmParrec').val() == '') {
			showError('error','Informe o banco','Alerta - Ayllos', 'unblockBackground()');			
			return false;
		}		
		bo			= 'b1wgen0059.p';
		procedure	= 'busca_agencia';
		titulo      = 'Agência';
		buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'nmageban',$(this).val(),'nmageban','cdbccxlt','frmParrec');
		return false;
	});	

}

function retornoPesquisaISPB(){

	if (cCdbccxlt.val() != aux_cdbccxlt){
		// Capturar o código do banco e ISPB após a pesquisa em suas variáveis auxiliares
		aux_cdbccxlt = cCdbccxlt.val();
		aux_nrispbif = cNrispbif.val();
		cCdageban.val('');
		cNmageban.val('');
	}else{
		// Zera variáveis
		aux_cdbccxlt = 0;
		aux_nrispbif = 0;
		
		cCdbccxlt.val('');
		cNmresbcc.val('');
	}
	// Focar no próximo campo do form
	$('#cdageban', '#frmParrec').focus();	

}

function formataCabecalho(){
	
	cTodosCabecalho		= $('input[type="text"],select','#frmCab');
	cTodosCabecalho.limpaFormulario();
	cTodosCabecalho.habilitaCampo();
	
	// cabecalho
	rCddopcao = $('label[for="cddopcao"]','#frmCab'); 
	rCdcooper = $('label[for="cdcooper"]','#frmCab'); 
	rCddopcao.css('width','40px');
	rCdcooper.css({'width':'80px'}).addClass('rotulo-linha');	
	
	cCddopcao = $('#cddopcao','#frmCab').css({'width':'375px'}); 
	cCdcooper = $('#cdcooper','#frmCab').css('width','100px');
	btnCab		 = $('#btOK','#frmCab');
		
	cCddopcao.focus();
	
}

function formataLayoutSingulares() {
	
	highlightObjFocus( $('#frmParrec') );
	// Canais de Recarga
	rFlgsitsac  = $('label[for="flsitsac"]','#frmParrec');
	rFlgsitsacs = $('label[for="flsitsacs"]','#frmParrec');
	rFlgsitsacn = $('label[for="flsitsacn"]','#frmParrec');
	rFlgsittaa  = $('label[for="flsittaa"]','#frmParrec');
	rFlgsittaas = $('label[for="flsittaas"]','#frmParrec');
	rFlgsittaan = $('label[for="flsittaan"]','#frmParrec');
	rFlgsitibn  = $('label[for="flsitibn"]','#frmParrec');
	rFlgsitibns = $('label[for="flsitibns"]','#frmParrec');
	rFlgsitibnn = $('label[for="flsitibnn"]','#frmParrec');
	
	rFlgsitsac.addClass('rotulo').css({'width':'268px'});
	rFlgsitsacs.addClass('radio').css({'width':'30px', 'text-align':'center'});
	rFlgsitsacn.addClass('radio').css({'width':'30px', 'text-align':'center'});
	rFlgsittaa.addClass('rotulo').css({'width':'268px'});
	rFlgsittaas.addClass('radio').css({'width':'30px', 'text-align':'center'});
	rFlgsittaan.addClass('radio').css({'width':'30px', 'text-align':'center'});
	rFlgsitibn.addClass('rotulo').css({'width':'268px'});
	rFlgsitibns.addClass('radio').css({'width':'30px', 'text-align':'center'});
	rFlgsitibnn.addClass('radio').css({'width':'30px', 'text-align':'center'});
	
	cFlgsitsac = $('input[name="flsitsac"]' ,'#frmParrec').addClass('campo');
	cFlgsittaa = $('input[name="flsittaa"]' ,'#frmParrec').addClass('campo');
	cFlgsitibn = $('input[name="flsitibn"]' ,'#frmParrec').addClass('campo');

	// Limite Máximo Diário
	rVlrmaxpf = $('label[for="vlrmaxpf"]','#frmParrec');
	rVlrmaxpj = $('label[for="vlrmaxpj"]','#frmParrec');
	
	rVlrmaxpf.addClass('rotulo').css('width', '150px');
	rVlrmaxpj.addClass('rotulo-linha').css('width', '175px');
	
	cVlrmaxpf = $('#vlrmaxpf','#frmParrec').addClass('campo moeda').css('width', '100px');
	cVlrmaxpj = $('#vlrmaxpj','#frmParrec').addClass('campo moeda').css('width', '100px');
		
	layoutPadrao();
	return false;	
}

function formataLayoutCecred() {
	
	highlightObjFocus( $('#frmParrec') );
	// Dados bancarios de repasse
	rNrispbif = $('label[for="nrispbif"]','#frmParrec');
	rCdbccxlt = $('label[for="cdbccxlt"]','#frmParrec');
	rCdageban = $('label[for="cdageban"]','#frmParrec');
	rNrdconta = $('label[for="nrdconta"]','#frmParrec');
	rNrdocnpj = $('label[for="nrdocnpj"]','#frmParrec');
	rDsdonome = $('label[for="dsdonome"]','#frmParrec');

	rNrispbif.addClass('rotulo').css({'width':'160px'});
	rCdbccxlt.addClass('rotulo').css({'width':'160px'});
	rCdageban.addClass('rotulo').css({'width':'160px'});
	rNrdconta.addClass('rotulo').css({'width':'160px'});
	rNrdocnpj.addClass('rotulo').css({'width':'160px'});
	rDsdonome.addClass('rotulo').css({'width':'160px'});
	
	cNrispbif = $('#nrispbif','#frmParrec').addClass('campo pesquisa inteiro').css({'width':'80px'}).attr('maxlength', '8'); // ,'text-align':'right'
	cCdbccxlt = $('#cdbccxlt','#frmParrec').addClass('campo inteiro').css({'width':'50px'});
	cNmresbcc = $('#nmresbcc','#frmParrec').addClass('campo').css({'width':'370px'});
	cCdageban = $('#cdageban','#frmParrec').addClass('campo pesquisa inteiro').css({'width':'50px'}).attr('maxlength', '5');
	cNmageban = $('#nmageban','#frmParrec').addClass('campo').css({'width':'350px'});
	cNrdconta = $('#nrdconta','#frmParrec').addClass('campo inteiro').css({'width':'100px'}).attr('maxlength', '12');
	cNrdocnpj = $('#nrdocnpj','#frmParrec').addClass('campo cnpj').css({'width':'150px'}).attr('maxlength', '18');
	cDsdonome = $('#dsdonome','#frmParrec').addClass('campo').css({'width':'423px'}).attr('maxlength', '50');;
		
	cCdbccxlt.desabilitaCampo();
	cNmresbcc.desabilitaCampo();
	cNmageban.desabilitaCampo();
		
	layoutPadrao();
	return false;	
}

function formataLayoutMensagens(){

	highlightObjFocus( $('#frmParrec') );
	// Dados bancarios de repasse
    $('fieldset > legend').css({'font-size': '11px', 'color': '#777', 'margin-left': '5px', 'padding': '0px 2px'});
    $('fieldset').css({'clear': 'both', 'border': '1px solid #777', 'margin': '3px 0px', 'padding': '10px 3px 5px 3px'});
    $('fieldset > fieldset').css({'clear': 'both', 'border': '1px solid #777', 'margin': '3px 10px', 'padding': '10px 3px 5px 3px'});
	cDsmsgsaldo  = $('#dsmsgsaldo', '#frmParrec');	
	cDsmsgoperac = $('#dsmsgoperac', '#frmParrec');	
	
	cDsmsgsaldo.css('width', '580px').addClass('alpha textarea').attr('maxlength','1000');
	cDsmsgoperac.css('width', '580px').addClass('alpha textarea').attr('maxlength','1000');
	
	layoutPadrao();
	return false;	
}

// botoes
function btnVoltar() {
	
	estadoInicial();
	return false;
}

function btnContinuar() {

	// Botão OK do cabeçalho
	if (!($('#cddopcao', '#frmCab').hasClass('campoTelaSemBorda'))) {
		$('input,select', '#frmCab').removeClass('campoErro');
		cddopcao = cCddopcao.val();
		cTodosCabecalho		= $('input[type="text"],select','#frmCab'); 	
		cTodosParrec		= $('input,select','#frmParrec');
		cTodosCabecalho.desabilitaCampo();
				
		if (cddopcao == 'M'){
			buscaMensagens();
		}else{
			if (cddopcao == 'C'){
				cTodosParrec.desabilitaCampo();
			}else{
				cTodosParrec.habilitaCampo();
			}
			
			if ( $('#cdcooper','#frmCab').val() == '3'){
				buscaParamCecred();				
			}else{
				buscaParamSingulares();
			}
		}
	}else{
		if (cddopcao == 'A'){
			if ( $('#cdcooper','#frmCab').val() == '3'){
				alteraParamCecred();
			}else{
				alteraParamSingulares();
			}
		} else if(cddopcao == 'M'){
			alteraMensagens();
		}
	}
	
	return false;
		
}

function buscaParamSingulares() {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, buscando par&acirc;metros da cooperativa...");	
	
	var cdcooper = cCdcooper.val();
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/parrec/busca_parametros_coop.php", 
		data: {
			cddopcao: cddopcao,
			cdcooper: cdcooper,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();				
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});				
}

function buscaParamCecred() {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, buscando par&acirc;metros da Ailos...");	
	
	var cdcooper = cCdcooper.val();
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/parrec/busca_parametros_cecred.php", 
		data: {
			cddopcao: cddopcao,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();				
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});				
}

function buscaMensagens() {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, buscando mensagens...");	
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/parrec/busca_mensagens.php", 
		data: {
			cddopcao: cddopcao,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();				
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});				
}


function alteraParamSingulares(){

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, efetuando opera&ccedil;&atilde;o...");	
	
	var cdcooper = cCdcooper.val();
	var flsitsac = $('input[name="flsitsac"]:checked', '#frmParrec').val();
	var flsittaa = $('input[name="flsittaa"]:checked', '#frmParrec').val();
	var flsitibn = $('input[name="flsitibn"]:checked', '#frmParrec').val();
	var vlrmaxpf = cVlrmaxpf.val();
	var vlrmaxpj = cVlrmaxpj.val();
	vlrmaxpf = vlrmaxpf.replace(/[^0-9\,]/g, "");
	vlrmaxpf = vlrmaxpf.replace(',','.');
	vlrmaxpj = vlrmaxpj.replace(/[^0-9\,]/g, "");
	vlrmaxpj = vlrmaxpj.replace(',','.');
		
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/parrec/altera_parametros_coop.php", 
		data: {
			cddopcao: cddopcao,
			cdcooper: cdcooper,
			flsitsac: flsitsac,
			flsittaa: flsittaa,
			flsitibn: flsitibn,
			vlrmaxpf: vlrmaxpf,
			vlrmaxpj: vlrmaxpj,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();				
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});
	
	return false;
}

function alteraParamCecred(){

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, efetuando opera&ccedil;&atilde;o...");	
	
	var nrispbif = cNrispbif.val();
	var cdbccxlt = cCdbccxlt.val();
	var nmresbcc = cNmresbcc.val();
	var cdageban = cCdageban.val();
	var nrdconta = cNrdconta.val();
	var nrdocnpj = cNrdocnpj.val();
	var dsdonome = cDsdonome.val();

	if (nmresbcc == '' || aux_nrispbif != nrispbif){
		blockBackground(parseInt($('#divRotina').css('z-index')));
		showError("error","Informe o n&uacute;mero ISPB.","Alerta - Ayllos","hideMsgAguardo(); $('#nrispbif', '#frmParrec').focus();");
		cCdbccxlt.val('');
		cNmresbcc.val('');
		return false;
	}	
	if (nrdconta == 0){
		blockBackground(parseInt($('#divRotina').css('z-index')));
		showError("error","Informe o n&uacute;mero da conta.","Alerta - Ayllos","hideMsgAguardo(); $('#nrdconta', '#frmParrec').focus();");
		return false;
	}
	if (nrdocnpj == 0){
		blockBackground(parseInt($('#divRotina').css('z-index')));
		showError("error","Informe o CNPJ.","Alerta - Ayllos","hideMsgAguardo(); $('#nrdocnpj', '#frmParrec').focus();");
		return false;
	}
	if (dsdonome == ''){
		blockBackground(parseInt($('#divRotina').css('z-index')));
		showError("error","Informe o nome.","Alerta - Ayllos","hideMsgAguardo(); $('#dsdonome', '#frmParrec').focus();");
		return false;
	}
	
	if (cdageban == '' || cdageban == 'undefined'){
		cdageban = 0;
	}
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/parrec/altera_parametros_cecred.php", 
		data: {
			cddopcao: cddopcao,
			nrispbif: nrispbif,
			cdageban: cdageban,
			nrdconta: nrdconta,
			nrdocnpj: nrdocnpj,
			dsdonome: dsdonome,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();				
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});
	
	return false;
}

function alteraMensagens(){
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, efetuando opera&ccedil;&atilde;o...");	
	
	var dsmsgsaldo = removeCaracteresInvalidos(cDsmsgsaldo.val());
	var dsmsgoperac = removeCaracteresInvalidos(cDsmsgoperac.val());
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/parrec/altera_mensagens.php", 
		data: {
			cddopcao: cddopcao,
			dsmsgsaldo: dsmsgsaldo,
			dsmsgoperac: dsmsgoperac,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();				
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});
	
	return false;
}

function checaRadio(nmdcampo, valor){
	if (valor == 0){
		$('#' + nmdcampo + 'n', '#frmParrec').prop("checked", true);
	}else if(valor == 1){
		$('#' + nmdcampo + 's', '#frmParrec').prop("checked", true);
	}
}
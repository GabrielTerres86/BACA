/*!
 * FONTE        : cadscr.js						Último ajuste: 16/01/2018
 * CRIAÇÃO      : Jéssica - DB1
 * DATA CRIAÇÃO : 09/10/2015
 * OBJETIVO     : Biblioteca de funções da tela CADSCR
 * --------------
 * ALTERAÇÕES   : 08/12/2015 - Ajustes de homologação referente a conversão efetuada pela DB1
 *							  (Adriano).
 *
 *			  	  16/01/2018 - Aumentado tamanho do campo de senha para 30 caracteres. (PRJ339 - Reinert)						    
 * -----------------------------------------------------------------------
 */
 
//Formulários e Tabela
var frmCab   	 = 'frmCab';
var frmConsulta  = 'frmConsulta';
var frmSenha     = 'frmSenha';
var divTabela;
var tabHistorico = 'tabHistorico';
     
var cddopcao, dtsolici, dtrefere, nrdconta, operador, nrdsenha, operacao, vllanmto,
	cTodosCabecalho, btnOK, cTodosConsulta;

var rCddopcao, rDtsolici, rDtrefere, rNrdconta, rOperador, rNrdsenha, rVllanmto,
	cCddopcao, cDtsolici, cDtrefere, cNrdconta, cOperador, cNrdsenha, cVllanmto;
	
var regCdhistor = "";
var regDshistor = "";
var regDstphist = "";
var regVllanmto = "";

	
$(document).ready(function() {
	
	divTabela = $('#divTabela');
	estadoInicial();			
	return false;
		
});

function carregaDados(){

	cddopcao = $('#cddopcao','#'+frmCab).val();
	dtsolici = $('#dtsolici','#'+frmConsulta).val();
	dtrefere = $('#dtrefere','#'+frmConsulta).val();
	cdhistor = $('#cdhistor','#'+frmConsulta).val();
	nrdconta = $('#nrdconta','#'+frmConsulta).val();
	nrdconta = nrdconta.replace(/[-. ]*/g,'');
	operador = $('#operador','#'+frmSenha).val();
	nrdsenha = $('#nrdsenha','#'+frmSenha).val();
	
	return false;
	
} //carregaDados

// inicio
function estadoInicial() {
	
	$('#frmCab').fadeTo(0,0.1);
	$('#divTabela').html('');
		
	formataCabecalho();
	formataConsulta();
	formataSenha();
	
	$('#frmConsulta').limpaFormulario();
	$('#frmSenha').limpaFormulario();
	
	$('#tabHistorico').css('display','none');
		
	removeOpacidade('frmCab');
	
	$('#btSalvar','#divBotoes').hide();
	$('#btConcluir','#divBotoes').hide();
	$('#btSalvarSenha','#divBotoes').hide();
	$('#btVoltar','#divBotoes').hide();
	$('#btAlterar','#divBotoes').hide();
	$('#btIncluir','#divBotoes').hide();
	$('#btExcluir','#divBotoes').hide();
	$('#btAlterarHist','#divBotoes').hide();
	$('#btIncluirHist','#divBotoes').hide();
	$('#btExcluirHist','#divBotoes').hide();
	
    return false;
	
}

// formata
function formataCabecalho() {
	
	$('label[for="cddopcao"]','#frmCab').css('width','45px').addClass('rotulo');
	$('#divTela').css({'display':'inline'}).fadeTo(0,0.1);
	removeOpacidade('divTela');		
		
	btnOK =  $('#btnOK','#'+frmCab);	          
	rCddopcao = $('label[for="cddopcao"]','#'+frmCab);	
	cCddopcao = $('#cddopcao','#'+frmCab);
			
	cCddopcao.css({'width':'520px'});
			
	cCddopcao.habilitaCampo().focus().val('C');
	
	btnOK.unbind('click').bind('click', function() { 
		
		if(cCddopcao.hasClass('campoTelaSemBorda') ){
			return false;
		}
		
		if ( divError.css('display') == 'block' ) { return false; }		
		
		cCddopcao.desabilitaCampo();	
		
		controlaLayout();
			
	});
	
	cCddopcao.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }

		// Se é a tecla ENTER
		if ( e.keyCode == 13) {

			btnContinuar();
			return false;
		}

	});
	
	$('#frmConsulta').css('display','none');
	$('#frmSenha').css('display','none');
			
	highlightObjFocus( $('#frmCab') );
	highlightObjFocus( $('#frmConsulta') );
	highlightObjFocus( $('#frmSenha') );
		
	layoutPadrao();
	
	cCddopcao.focus();	
		
	return false;	
}

function controlaLayout() {
	
	if(cCddopcao.val() == "C") {
		
		$('#frmConsulta').css('display','block');
		cDtsolici.focus();
		
		$('#divBotoes').css('display','block');
		$('#btConcluir','#divBotoes').show();
		$('#btVoltar','#divBotoes').show();
		
	}else if(cCddopcao.val() == "B"){
		
		$('#frmConsulta').css('display','block');
		cDtsolici.focus();
		cDtrefere.desabilitaCampo();
		cNrdconta.desabilitaCampo();	
		
		$('#divBotoes').css('display','block');
		$('#btConcluir','#divBotoes').show();
		$('#btVoltar','#divBotoes').show();
	
	}else if(cCddopcao.val() == "X"){
		
		$('#frmConsulta').css('display','block');
									
		cDtsolici.focus();
		cDtrefere.desabilitaCampo();
		cNrdconta.desabilitaCampo();
		
		$('#divBotoes').css('display','block');
		$('#btSalvar','#divBotoes').show();
		$('#btVoltar','#divBotoes').show();
	
	}else if(cCddopcao.val() == "L"){
		
		$('#frmConsulta').css('display','block');
		cDtsolici.focus();
	
		$('#divBotoes').css('display','block');
		$('#btSalvar','#divBotoes').show();
		$('#btVoltar','#divBotoes').show();
	
	}
		
	return false;
}

//botoes
function btnVoltar() {
	
	if(cCddopcao.val() == "C"){

		if($('#frmHistorico').css('display')=='block'){
			
			$('#frmConsulta').limpaFormulario();
			$('input','#frmConsulta').habilitaCampo();
			
			$('#frmHistorico').css('display','none');
			
			cDtsolici.focus();

			$('#btVoltar','#divBotoes').show();
			$('#btConcluir','#divBotoes').show();
			
		}else{
			estadoInicial();
		}
	
	}else if(cCddopcao.val() == "L"){

		if($('#frmHistorico').css('display')=='block'){
		
			$('#frmHistorico').css('display','none');
						
			cDtsolici.focus();

			$('#btVoltar','#divBotoes').show();
			$('#btSalvar','#divBotoes').hide();
			$('#btAlterar','#divBotoes').show();
			$('#btIncluir','#divBotoes').show();
			$('#btExcluir','#divBotoes').show();
			$('#btAlterarHist','#divBotoes').hide();
			$('#btIncluirHist','#divBotoes').hide();
			$('#btExcluirHist','#divBotoes').hide();
			
		}else if( $('#frmConsulta').css('display')=='none'){
			
			$('#frmConsulta').css('display','block');
			$('input','#frmConsulta').habilitaCampo();
			
			cDtsolici.focus();

			$('#btVoltar','#divBotoes').show();
			$('#btSalvar','#divBotoes').show();
			$('#btAlterar','#divBotoes').hide();
			$('#btIncluir','#divBotoes').hide();
			$('#btExcluir','#divBotoes').hide();
			$('#btAlterarHist','#divBotoes').hide();
			$('#btIncluirHist','#divBotoes').hide();
			$('#btExcluirHist','#divBotoes').hide();

		}else{
			
			estadoInicial();
			
		}
		
	}else if(cddopcao == 'X'){
		
		if($('#frmSenha').css('display')=='block'){
			
			$('#frmSenha').css('display','none').limpaFormulario();
			$('#frmConsulta').css('display','block');
						
			cDtsolici.habilitaCampo().focus();
			
			$('#btVoltar','#divBotoes').show();
			$('#btConcluir','#divBotoes').show();
			$('#btAlterar','#divBotoes').hide();
			$('#btIncluir','#divBotoes').hide();
			$('#btExcluir','#divBotoes').hide();
			$('#btSalvarSenha','#divBotoes').hide();
			$('#btAlterarHist','#divBotoes').hide();
			$('#btIncluirHist','#divBotoes').hide();
			$('#btExcluirHist','#divBotoes').hide();
			
		}else{
			
			estadoInicial();
			
		}
	
	}else{
	
		estadoInicial();
		
	}
	
	return false;
}

function btnContinuar() {

	if ( divError.css('display') == 'block' ) { return false; }		
			
	if ( cCddopcao.hasClass('campo') ) {
		btnOK.click();
		
	}else {
		
		$('input','#frmConsulta').desabilitaCampo();
		verificaDados();
						
	}	
							
	return false;

}

// Botoes
function btnIncluir() {
	
	$('#frmConsulta').css('display','none');
	
	$('#btSalvar','#divBotoes').hide();
	$('#btSalvarSenha','#divBotoes').hide();
	$('#btVoltar','#divBotoes').show();
	$('#btAlterar','#divBotoes').hide();
	$('#btIncluir','#divBotoes').hide();
	$('#btExcluir','#divBotoes').hide();
	$('#btAlterarHist','#divBotoes').hide();
	$('#btIncluirHist','#divBotoes').show();
	$('#btExcluirHist','#divBotoes').hide();
	
	operacao = 'I';
	
	buscaHistorico();
	
	return false;
}

function btnAlterar() {
	
	$('#frmConsulta').css('display','none');
	
	$('#btSalvar','#divBotoes').hide();
	$('#btSalvarSenha','#divBotoes').hide();
	$('#btVoltar','#divBotoes').show();
	$('#btAlterar','#divBotoes').hide();
	$('#btIncluir','#divBotoes').hide();
	$('#btExcluir','#divBotoes').hide();
	$('#btAlterarHist','#divBotoes').show();
	$('#btIncluirHist','#divBotoes').hide();
	$('#btExcluirHist','#divBotoes').hide();
	
	operacao = 'A';
	
	buscaLancamentos(1,30);
			
	return false;
}

function btnExcluir() {
	
	$('#frmConsulta').css('display','none');
	
	$('#btSalvar','#divBotoes').hide();
	$('#btSalvarSenha','#divBotoes').hide();
	$('#btVoltar','#divBotoes').show();
	$('#btAlterar','#divBotoes').hide();
	$('#btIncluir','#divBotoes').hide();
	$('#btExcluir','#divBotoes').hide();
	$('#btAlterarHist','#divBotoes').hide();
	$('#btIncluirHist','#divBotoes').hide();
	$('#btExcluirHist','#divBotoes').show();;
	
	operacao = 'E';
	
	buscaLancamentos(1,30);
	
	return false;
}

function btnIncluirHist() {
	
	$('#frmDados').css('display','block');
	
	mostrarTela("I");
			
	return false;
}

function btnAlterarHist() {
	
	mostrarTela("A");			
	return false;
}

function btnExcluirHist() {
	
	showConfirmacao("Voc&ecirc; tem certeza que deseja excluir o lan&ccedil;amento selecionado?","Confirma&ccedil;&atilde;o - Ayllos","gravaLancamento();","","sim.gif","nao.gif");
		
	return false;
}

function btnContinuarSenha() {

	if ( divError.css('display') == 'block' ) { return false; }		
							
	showConfirmacao("Deseja confirmar a opera&ccedil;&atilde;o?","Confirma&ccedil;&atilde;o - Ayllos","validaSenha(); ","$('#operador','#frmSenha').focus();","continuar.gif","cancelar.gif");
									
	return false;

}

function geraOperacao() {

	if ( divError.css('display') == 'block' ) { return false; }	
		
	$('#frmConsulta').css('display','none');		
				
	$('#btSalvar','#divBotoes').hide();
	$('#btSalvarSenha','#divBotoes').hide();
	$('#btVoltar','#divBotoes').show();
	$('#btAlterar','#divBotoes').show();
	$('#btIncluir','#divBotoes').show();
	$('#btExcluir','#divBotoes').show();
							
	return false;

}

function mostrarTela(opcao) {
			
	if(cCddopcao.val() == "C" || cCddopcao.val() == "B" || cCddopcao.val() == "X" || $('#btExcluirHist').css('display')=='inline-block'){
		
		return false;
		
	}else{
				
		$.ajax({
			type	: "POST",
			dataType: "html",
			url		: UrlSite + "telas/cadscr/acessa_rotina.php",
			data: {
				redirect: "html_ajax"
			},
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')) )");
			},
			success: function(response) {
				 mostraRotina();
				$("#divRotina").html(response);
			}
		});
		return false;
	}
}

// Função para visualizar div da rotina
function mostraRotina() {
	$("#divRotina").css("visibility","visible");
	$("#divRotina").centralizaRotinaH();
}

// Função para esconder div da rotina e carregar dados da conta novamente
function encerraRotina(flgCabec) {	
	
	$("#divRotina").css({"width":"545px","visibility":"hidden"});
	$("#divRotina").html("");
	
	// Esconde div de bloqueio
	unblockBackground();
		
	return false;
}

/* Acessar tela principal da rotina */
function acessaOpcaoAba() {

	/* Monta o conteudo atraves dos botoes de incluir/alterar */
	
	$('input,select').removeClass('campoErro');
		
	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/cadscr/form_dados.php",
		data: {
			regCdhistor : regCdhistor,
			regDshistor : regDshistor,
			regDstphist : regDstphist,
			regVllanmto : regVllanmto,
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')) )");
		},
		success: function(response) {
			$("#divConteudoOpcao").html(response);
			atualizaSeletor();
		}
	});
	return false;
}


// Cabecalho Principal
function atualizaSeletor() {

	/** Formulario Dados **/
	rCdhistor = $('label[for="cdhistor"]','#frmDados');
	rDshistor = $('label[for="dshistor"]','#frmDados');
	rDstphist = $('label[for="dstphist"]','#frmDados');
	rVllanmto = $('label[for="vllanmto"]','#frmDados');
			  
	cCdhistor = $('#cdhistor','#frmDados');
	cDshistor = $('#dshistor','#frmDados');
	cDstphist = $('#dstphist','#frmDados');
	cVllanmto = $('#vllanmto','#frmDados');	

	cTodosCabDados = $('input[type="text"],select,textArea','#frmDados');	
		
	formataDados();
		
}

// Formatacao da Tela
function formataDados() {
	
	cTodosCabDados = $('input[type="text"],select','#frmDados');
	
	rCdhistor = $('label[for="cdhistor"]','#frmDados');
	rDshistor = $('label[for="dshistor"]','#frmDados');
	rDstphist = $('label[for="dstphist"]','#frmDados');
	rVllanmto = $('label[for="vllanmto"]','#frmDados');
		      
	cCdhistor = $('#cdhistor','#frmDados');
	cDshistor = $('#dshistor','#frmDados');
	cDstphist = $('#dstphist','#frmDados');
	cVllanmto = $('#vllanmto','#frmDados'); 
	
	/** Formulario Dados **/
	rCdhistor.css({'width':'80px'});
	rDshistor.css({'width':'80px'});
	rDstphist.css({'width':'80px'});
	rVllanmto.css({'width':'80px'});
	
	cCdhistor.addClass('campo').css({'width':'350px'});
    cDshistor.addClass('campo').css({'width':'350px'});
	cDstphist.addClass('campo').css({'width':'100px'});
	cVllanmto.addClass('moeda').css({'width':'100px'}).attr('maxlength','25').habilitaCampo();
	
	cCdhistor.desabilitaCampo();
	cDshistor.desabilitaCampo();
	cDstphist.desabilitaCampo();
	
	cVllanmto.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }
				 
		// Se é a tecla ENTER, TAB
		if ( e.keyCode == 13  || e.keyCode == 9) {
			
			$(this).removeClass('campoErro');

			$('#btSalvar','#divBotoesInclui').click();
			return false;
		}
				
	});
	
	highlightObjFocus( $('#frmDados') );
	
	cVllanmto.focus();
	
	layoutPadrao();
	cVllanmto.focus();
	return false;
		
}

function buscaDados(nriniseq,nrregist) {	
	
	$('input,select').removeClass('campoErro');
	
	carregaDados();
	
	showMsgAguardo( "Aguarde, buscando informa&ccedil;&otilde;es..." );

	$.ajax({
		type	: "POST",
		dataType: "html",
		url		: UrlSite + "telas/cadscr/busca_dados.php",
		data: {
			dtsolici: dtsolici,
			dtrefere: dtrefere,
			nrdconta: nrdconta,
			cddopcao: cddopcao,	
			nriniseq: nriniseq,	
			nrregist: nrregist,	
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function(response) {
			hideMsgAguardo();
			$("#divTabela").html(response);
			formataTabela();
		}
	});
	
	return false;
}

function buscaLancamentos(nriniseq,nrregist) {	
	
	$('input,select').removeClass('campoErro');
		
	carregaDados();

	showMsgAguardo( "Aguarde, buscando lan&ccedil;amentos..." );
	
	$.ajax({
		type	: "POST",
		dataType: "html",
		url		: UrlSite + "telas/cadscr/busca_lancamentos.php",
		data: {
			dtsolici: dtsolici,
			dtrefere: dtrefere,
			nrdconta: nrdconta,
			cddopcao: cddopcao,	
			nrregist: nrregist,	
			nriniseq: nriniseq,	
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function(response) {
			hideMsgAguardo();
			$("#divTabela").html(response);
			formataTabelaLancamentos();
		}
	});
	return false;
}

function buscaHistorico() {	
	
	$('input,select').removeClass('campoErro');
		
	carregaDados();

	showMsgAguardo( "Aguarde, buscando hist&oacute;ricos..." );
	
	$.ajax({
		type	: "POST",
		dataType: "html",
		url		: UrlSite + "telas/cadscr/busca_historico.php",
		data: {
			dtsolici: dtsolici,
			dtrefere: dtrefere,
			nrdconta: nrdconta,
			cddopcao: cddopcao,	
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function(response) {
			hideMsgAguardo();
			$("#divTabela").html(response);
			formataTabelaHistorico();
		}
	});
	return false;
}

function gravaLancamento(){
	
	$('input,select').removeClass('campoErro');
		
	carregaDados();
	
	// Verificando qual tipo de gravacao
	if (operacao == "I"){
		var descricao = "inserido";
	}else if (operacao == "A"){
		var descricao = "atualizado";
	}else{
		var descricao = "excluido";
	}

	if(operacao == "E"){
		cdhistor = $('#tabHistorico .corSelecao #cdhistor').val();
		vllanmto = $('#tabHistorico .corSelecao #vllanmto').val();
		dshistor = $('#tabHistorico .corSelecao #dshistor').val();
		dstphist = $('#tabHistorico .corSelecao #dstphist').val();
	}else{
		cdhistor = $('#cdhistor','#frmDados').val();				
		vllanmto = $('#vllanmto','#frmDados').val().replace(/\./g,"");
		dshistor = $('#dshistor','#frmDados').val();
		dstphist = $('#dstphist','#frmDados').val();
	}
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde...");

	$.ajax({
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/cadscr/grava_lancamento.php",
		data: {
			nrdconta : nrdconta,
			dtsolici : dtsolici,
			dtrefere : dtrefere,
			cdhistor : cdhistor,
			vllanmto : vllanmto,
			cddopcao : cddopcao,
			operacao : operacao,			
			redirect : "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			
			hideMsgAguardo();
			try {
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						if(operacao == "I"){
							showError("inform","O lan&ccedil;amento foi " + descricao + " com sucesso!","Alerta - Ayllos","encerraRotina(true);buscaHistorico();")	
						}else{
						
							showError("inform","O lan&ccedil;amento foi " + descricao + " com sucesso!","Alerta - Ayllos","encerraRotina(true);buscaLancamentos(1,30);")					
						}
					} catch(error) {
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')))");
					}
				} else {
					try {
						eval(response);
					} catch(error) {
						hideMsgAguardo();
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')))");
					}
				}
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}
	});
	
	return false;
}

function verificaLancamentoGeracao() {	
	
	$('input,select').removeClass('campoErro');
	
	carregaDados();

	$.ajax({
		type	: "POST",
		dataType: "html",
		url		: UrlSite + "telas/cadscr/verifica_lancamento.php",
		data: {
			dtsolici: dtsolici,
			cddopcao: cddopcao,	
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#cddopcao','#frmCabAlerta').focus()");							
		},
		success: function(response) {
			hideMsgAguardo();			
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try { 	
					geraArquivo();
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

function verificaLancamento() {	
	
	$('input,select').removeClass('campoErro');
	
	controlaLayout();
	
	carregaDados();

	$.ajax({
		type	: "POST",
		dataType: "html",
		url		: UrlSite + "telas/cadscr/verifica_lancamento.php",
		data: {				
			cddopcao: cddopcao,			
			nrdconta: nrdconta,
			dtsolici: dtsolici,
			dtrefere: dtrefere,
			cdhistor: cdhistor,
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#cddopcao','#frmCabAlerta').focus()");							
		},
		success: function(response) {
			hideMsgAguardo();			
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try { 	
					geraOperacao();
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

function verificaDados() {	
	
	$('input,select').removeClass('campoErro');
	
	controlaLayout();
	
	carregaDados();
	
	showMsgAguardo( "Aguarde, validando informa&ccedil;&otilde;es..." );

	$.ajax({
		type	: "POST",
		dataType: "html",
		url		: UrlSite + "telas/cadscr/verifica_dados.php",
		data: {
			cddopcao: cddopcao,
			nrdconta: nrdconta,
			dtsolici: dtsolici,
			dtrefere: dtrefere,
			cdhistor: cdhistor,
			cddopcao: cddopcao,	
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#dtsolici','#divConsulta').focus()");							
		},
		success: function(response) {
			hideMsgAguardo();				
			try {
				eval( response );						
			} catch(error) {						
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$("#dtsolici","#divConsulta").focus()');
			}
		
		}
	});
	return false;
}

function validaSenha() {	
	
	$('input,select').removeClass('campoErro');
	
	$('input','#divSenha').desabilitaCampo();
	
	carregaDados();

	nrdsenha = encodeURIComponent(nrdsenha, "UTF-8");
	
	showMsgAguardo( "Aguarde, validando senha..." );
	
	$.ajax({
		type	: "POST",
		dataType: "html",
		url		: UrlSite + "telas/cadscr/valida_senha.php",
		data: {
			cddopcao: cddopcao,
			operador: operador,
			nrdsenha: nrdsenha,	
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('input','#divSenha').habilitaCampo();$('#operador','#divSenha').focus()");							
		},
		success: function(response) {
			hideMsgAguardo();				
			try {
				eval( response );						
			} catch(error) {						
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$("input","#divSenha").habilitaCampo();$("#operador","#divsenha").focus()');
			}
		}

	});
	return false;
}

function atualizaArquivo() {	
	
	$('input,select').removeClass('campoErro');
	
	carregaDados();

	showMsgAguardo( "Aguarde, atualizando..." );
	
	$.ajax({
		type	: "POST",
		dataType: "html",
		url		: UrlSite + "telas/cadscr/atualiza_arquivo.php",		
		data: {
			nrdconta: nrdconta,
			dtsolici: dtsolici,
			dtrefere: dtrefere,
			cdhistor: cdhistor,
			cddopcao: cddopcao,
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('input','#divSenha').habilitaCampo();$('#operador','#divSenha').focus()");							
		},
		success: function(response) {
			hideMsgAguardo();				
			try { 
				eval( response );						
			} catch(error) {						
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$("input","#divSenha").habilitaCampo();$("#operador","#divSenha").focus()');
			}
		}

	});
	return false;
}

function verificaLancamentoDesfaz() {	
	
	$('input,select').removeClass('campoErro');
	
	controlaLayout();
	
	carregaDados();

	$.ajax({
		type	: "POST",
		dataType: "html",
		url		: UrlSite + "telas/cadscr/verifica_lancamento.php",
		data: {
			dtsolici: dtsolici,
			cddopcao: cddopcao,	
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#cddopcao','#frmCabAlerta').focus()");							
		},
		success: function(response) {
			hideMsgAguardo();				
			try {
				eval( response );						
			} catch(error) {						
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$("#dtsolici","#divConsulta").focus()');
			}
		}

	});
	return false;
}

// gera_arquivo
function geraArquivo() {

	showMsgAguardo('Aguarde, Gerando Arquivo...');

	carregaDados();
		
	$.ajax({
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/cadscr/imprimir_dados.php',
		data    :
				{ cddopcao 	: cddopcao, 	 
				  dtsolici	: dtsolici,
				  dtrefere 	: dtrefere,
				  cdhistor	: cdhistor,
				  nrdconta  : nrdconta,				
				  redirect: 'script_ajax'

				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#tpChequ1\',\'#frmTipoCheque\').focus();');
				},
		success : function(response) {
					hideMsgAguardo();
					
					try {
						eval( response );
					} catch(error) {
						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#tpChequ1\',\'#frmTipoCheque\').focus();');
					}

				}
	});

	return false;
}

function formataTabela() {

	// Habilita a conteudo da tabela
    $('#divCab').css({'display':'block'});

    var divRegistro = $('div.divRegistros', '#tabHistorico');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
	var conteudo	= $('#conteudo', linha).val();
	
    $('#tabConvenio').css({'margin-top':'1px'});
	divRegistro.css({'height':'300px','padding-bottom':'1px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
		arrayLargura[0] = '80px';
		arrayLargura[1] = '80px';
		arrayLargura[2] = '80px';
		arrayLargura[3] = '40px';
		arrayLargura[4] = '80px';
		arrayLargura[5] = '80px';
		arrayLargura[6] = '80px';

	var arrayAlinha = new Array();
		arrayAlinha[0] = 'left';
        arrayAlinha[1] = 'right';
        arrayAlinha[2] = 'left';
        arrayAlinha[3] = 'right';
        arrayAlinha[4] = 'left';
        arrayAlinha[5] = 'right';
        arrayAlinha[6] = 'left';
        arrayAlinha[7] = 'left';

	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	
	/* Atribuindo o foco para a linha da tabela, pois ao clicar no cabecalho nao retornava
	para linha da tabela, dessa maneira a tela apresentava erro na hora de alterar ou
	excluir o registro selecionado */

	$('table > thead > tr > th', divRegistro).unbind('click').bind('click', function() {
		$('table > tbody > tr > td', divRegistro).focus();
	});

	/*
	// seleciona o registro que é focado
	$('table > tbody > tr', divRegistro).focus( function() {
		selecionaTabela($(this));
	});*/

	$('table > tbody > tr:eq(0)', divRegistro).click();
	return false;
}

function formataTabelaLancamentos() {

	// Habilita a conteudo da tabela
    $('#divCab').css({'display':'block'});

    var divRegistro = $('div.divRegistros', '#tabHistorico');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
	var conteudo	= $('#conteudo', linha).val();
	
    $('#tabConvenio').css({'margin-top':'1px'});
	divRegistro.css({'height':'300px','padding-bottom':'1px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
		arrayLargura[0] = '60px';
		arrayLargura[1] = '300px';
		arrayLargura[2] = '71px';

	var arrayAlinha = new Array();
		arrayAlinha[0] = 'right';
        arrayAlinha[1] = 'left';
        arrayAlinha[2] = 'left';
        arrayAlinha[3] = 'right';

	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	
	/* Atribuindo o foco para a linha da tabela, pois ao clicar no cabecalho nao retornava
	para linha da tabela, dessa maneira a tela apresentava erro na hora de alterar ou
	excluir o registro selecionado */

	$('table > thead > tr > th', divRegistro).unbind('click').bind('click', function() {
		$('table > tbody > tr > td', divRegistro).focus();
	});

	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		selecionaTabela($(this));
	});
	
	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).dblclick( function() {
		selecionaTabela($(this));
		
		if(operacao == 'E'){
			btnExcluirHist();
		}else{
			btnAlterarHist();
		}
	});

    // seleciona o registro que é focado
	$('table > tbody > tr', divRegistro).focus( function() {
		selecionaTabela($(this));
	});

	$('table > tbody > tr:eq(0)', divRegistro).click();
	return false;
}

function formataTabelaHistorico() {

	// Habilita a conteudo da tabela
    $('#divCab').css({'display':'block'});

    var divRegistro = $('div.divRegistros', '#tabHistorico');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
	var conteudo	= $('#conteudo', linha).val();
	
    $('#tabConvenio').css({'margin-top':'1px'});
	divRegistro.css({'height':'300px','padding-bottom':'1px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
		arrayLargura[0] = '60px';
		arrayLargura[1] = '421px';

	var arrayAlinha = new Array();
		arrayAlinha[0] = 'right';
        arrayAlinha[1] = 'left';
        arrayAlinha[2] = 'left';

	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	
	/* Atribuindo o foco para a linha da tabela, pois ao clicar no cabecalho nao retornava
	para linha da tabela, dessa maneira a tela apresentava erro na hora de alterar ou
	excluir o registro selecionado */

	$('table > thead > tr > th', divRegistro).unbind('click').bind('click', function() {
		$('table > tbody > tr > td', divRegistro).focus();
	});

	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		selecionaTabela($(this));
	});
	
	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).dblclick( function() {
		
		selecionaTabela($(this));
		
		btnIncluirHist();
					
	});

    // seleciona o registro que é focado
	$('table > tbody > tr', divRegistro).focus( function() {
		selecionaTabela($(this));
	});

	$('table > tbody > tr:eq(0)', divRegistro).click();
	return false;
}

function selecionaTabela(tr) {

	regCdhistor = $('#cdhistor', tr).val();
	regDshistor = $('#dshistor', tr).val();
	regDstphist = $('#dstphist', tr).val();
	regVllanmto = $('#vllanmto', tr).val();
	
	return false;
}

function formataConsulta(){

	$('input').removeClass('campoErro');
	
	cTodosConsulta = $('input[type="text"],select','#divConsulta');
		
	rDtsolici = $('label[for="dtsolici"]','#divConsulta');
	rDtrefere = $('label[for="dtrefere"]','#divConsulta');	
	rNrdconta = $('label[for="nrdconta"]','#divConsulta');
						
	cDtsolici = $('#dtsolici','#divConsulta');	
	cDtrefere = $('#dtrefere','#divConsulta');		
	cNrdconta = $('#nrdconta','#divConsulta');
				
	rDtsolici.css({'width':'120px'});
	rDtrefere.css({'width':'95px'});
	rNrdconta.css({'width':'73px'});
				
	cDtsolici.css({'width':'90px'}).addClass('data');
	cDtrefere.css({'width':'90px'}).addClass('data');	
	cNrdconta.css({'width':'90px'}).addClass('conta');
					
	cTodosConsulta.habilitaCampo();	
		
	cDtsolici.unbind('keypress').bind('keypress', function(e) {
		
		if ( divError.css('display') == 'block' ) { return false;}		
		// Se é a tecla ENTER, TAB
		if ( e.keyCode == 13  || e.keyCode == 9) {		
		
			if (cCddopcao.val() == "X" || cCddopcao.val() == "B"){
				
				$(this).removeClass('campoErro');
				
				if($('#cddopcao','#frmCab').val() == 'C' || $('#cddopcao','#frmCab').val() == 'B'){
					$('#btConcluir','#divBotoes').click();
				}else{
					btnContinuar();
				}
					
				return false;
				
			}else{
					
				$(this).removeClass('campoErro');
				cDtrefere.focus();
					
				return false;
			}
		}
		
	});
	
	cDtrefere.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false;}		
		// Se é a tecla ENTER, TAB
		if ( e.keyCode == 13  || e.keyCode == 9) {		
					
			$(this).removeClass('campoErro');
			cNrdconta.focus();
				
			return false;
		}
		
	});
	
	cNrdconta.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }
				 
		// Se é a tecla ENTER, TAB
		if ( e.keyCode == 13  || e.keyCode == 9) {
			
			$(this).removeClass('campoErro');

			if($('#cddopcao','#frmCab').val() == 'C' || $('#cddopcao','#frmCab').val() == 'B'){
				$('#btConcluir','#divBotoes').click();
			}else{
				btnContinuar();
			}
			
			return false;
		}
				
	});
	
	layoutPadrao();

	return false;
}

function formataSenha(){

	$('input').removeClass('campoErro');
	
	rOperador = $('label[for="operador"]','#divSenha');
	rNrdsenha = $('label[for="nrdsenha"]','#divSenha');	
						
	cOperador = $('#operador','#divSenha');	
	cNrdsenha = $('#nrdsenha','#divSenha');		
			
	rOperador.css({'width':'190px'});
	rNrdsenha.css({'width':'65px'});
				
	cOperador.css({'width':'90px'}).attr('maxlength','10');
	cNrdsenha.css({'width':'90px'}).attr('maxlength','30');	
					
	$('#operador','#divSenha').habilitaCampo();
	$('#nrdsenha','#divSenha').habilitaCampo();
		
	cOperador.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false;}		
		// Se é a tecla ENTER, TAB
		if ( e.keyCode == 13  || e.keyCode == 9) {		
		
			$(this).removeClass('campoErro');
			cNrdsenha.focus();
					
			return false;
			
		}
		
	});
	
	cNrdsenha.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false;}		
		// Se é a tecla ENTER, TAB
		if ( e.keyCode == 13  || e.keyCode == 9) {		
					
			$(this).removeClass('campoErro');
			btnContinuarSenha();
				
			return false;
		}
		
	});
	
	layoutPadrao();

	return false;
}
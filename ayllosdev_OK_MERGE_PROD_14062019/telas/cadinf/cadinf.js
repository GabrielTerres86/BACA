/*!
 * FONTE        : cadinf.js                                   Última alteração: 29/10/2015 
 * CRIAÇÃO      : Jéssica - DB1
 * DATA CRIAÇÃO : 18/08/2015
 * OBJETIVO     : Biblioteca de funções da tela CADINF
 * --------------
 * ALTERAÇÕES   : 29/10/2015 - Ajustes de homologação refente a conversão realizada pela DB1
							   (Adriano).
 * -----------------------------------------------------------------------
 */
 
//Formulários e Tabela
var frmCab   	= 'frmCab';
var frmConsulta = 'frmConsulta';
var divConsulta = 'divConsulta';
var frmDados	= 'frmDados';
var tabInformativo = 'tabInformativo';
var divTabela;

var nmrelato, dsfenvio, dsperiod, flgtitul, flgobrig, mensagem,
    cTodosCabecalho, btnOK, cTodosConsulta, cTodosCabDados;

var rCddopcao, rNmrelato, rDsfenvio, rDsperiod, rFlgtitul, rFlgobrig, 
    cCddopcao, cNmrelato, cDsfenvio, cDsperiod, cFlgtitul, cFlgobrig;

var nrdrowid = "";
var regNmrelato = "";
var regDsfenvio = "";
var regDsperiod = "";
var regFlgtitul = "";
var regFlgobrig = "";
var regCdrelato = "";
var regCdprogra = "";
var regCddfrenv = "";
var regCdperiod = "";
var regTodosTit;


$(document).ready(function() {	
	divTabela		= $('#divTabela');
	estadoInicial();			
	return false;
		
});

// inicio
function estadoInicial() {

	formataCabecalho();
	
	$('#frmDados').limpaFormulario();
	
	$('#tabInformativo').css('display','none');
	$('#tabSelecionaInformativo').css('display','none');
		
	$('#btSalvar','#divBotoes').hide();
	$('#btVoltar','#divBotoesCadastro').hide();
	$('#btAlterar','#divBotoesCadastro').hide();
	$('#btIncluir','#divBotoesCadastro').hide();
	$('#btExcluir','#divBotoesCadastro').hide();
	
    return false;
	
}

// Monta a tela Principal
function controlaLayout() {
		
	$('input,select').removeClass('campoErro');
	
	if(cCddopcao.val() == "C") {
					
		$('#btVoltar','#divBotoesCadastro').show();
		$('#btSalvar','#divBotoes').hide();
			
	}else if(cCddopcao.val() == "A") {
		
		$('#btSalvar','#divBotoes').hide();
		$('#btVoltar','#divBotoesCadastro').show();
		$('#btAlterar','#divBotoesCadastro').show();
		$('#btIncluir','#divBotoesCadastro').hide();
		$('#btExcluir','#divBotoesCadastro').hide();
						
	}else if(cCddopcao.val() == "I") {
		
		$('#frmDados').css('display','block');
		
		$('#btSalvar','#divBotoes').hide();
		$('#btVoltar','#divBotoesCadastro').show();
		$('#btAlterar','#divBotoesCadastro').hide();
		$('#btIncluir','#divBotoesCadastro').show();
		$('#btExcluir','#divBotoesCadastro').hide();
		
	}else if(cCddopcao.val() == "E") {
		
		$('#btSalvar','#divBotoes').hide();
		$('#btVoltar','#divBotoesCadastro').show();
		$('#btAlterar','#divBotoesCadastro').hide();
		$('#btIncluir','#divBotoesCadastro').hide();
		$('#btExcluir','#divBotoesCadastro').show();
		
	}
				
	nrdrowid = "";

	layoutPadrao();
	return false;
}

/* Acessar tela principal da rotina */
function acessaOpcaoAba() {

	/* Monta o conteudo atraves dos botoes de incluir/alterar */
	
	$('input,select').removeClass('campoErro');
		
	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/cadinf/form_dados.php",
		data: {
			nrdrowid     : nrdrowid,
			regNmrelato : regNmrelato,
			regDsfenvio : regDsfenvio,
			regDsperiod : regDsperiod,
			regFlgtitul : regFlgtitul,
			regFlgobrig : regFlgobrig,
			regCdrelato : regCdrelato,
			regCdprogra : regCdprogra,
			regCddfrenv : regCddfrenv,
			regCdperiod : regCdperiod,
			regTodosTit : regTodosTit,
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
	rNmrelato	    	= $('label[for="nmrelato"]','#frmDados');
	rDsfenvio	    	= $('label[for="dsfenvio"]','#frmDados');
	rDsperiod	    	= $('label[for="dsperiod"]','#frmDados');
	rFlgtitul	    	= $('label[for="envcpttl"]','#frmDados');
	rFlgobrig	    	= $('label[for="envcobrg"]','#frmDados');
		
	cNmrelato      		= $('#nmrelato','#frmDados');
	cDsfenvio      		= $('#dsfenvio','#frmDados');
	cDsperiod      		= $('#dsperiod','#frmDados');
	cFlgtitul      		= $('#envcpttl','#frmDados');
	cFlgobrig      		= $('#envcobrg','#frmDados');

	cTodosCabDados	    = $('input[type="text"],select,textArea','#frmDados');	
		
	formataDados();
	
	navegaCampos();
	
}

// Formatacao da Tela
function formataDados() {
	
	cTodosCabDados = $('input[type="text"],select','#frmDados');
	
	rNmrelato	    	= $('label[for="nmrelato"]','#frmDados');
	rDsfenvio	    	= $('label[for="dsfenvio"]','#frmDados');
	rDsperiod	    	= $('label[for="dsperiod"]','#frmDados');
	rFlgtitul	    	= $('label[for="envcpttl"]','#frmDados');
	rFlgobrig	    	= $('label[for="envcobrg"]','#frmDados');
	
	cNmrelato      		= $('#nmrelato','#frmDados');
	cDsfenvio      		= $('#dsfenvio','#frmDados');
	cDsperiod      		= $('#dsperiod','#frmDados');
	cFlgtitul      		= $('#envcpttl','#frmDados'); 
	cFlgobrig      		= $('#envcobrg','#frmDados');

	/** Formulario Dados **/
	rNmrelato.css({'width':'110px'});
	rDsfenvio.css({'width':'110px'});
	rDsperiod.css({'width':'110px'});
	rFlgtitul.css({'width':'110px'});
	rFlgobrig.css({'width':'110px'});

	cNmrelato.addClass('campo').css({'width':'300px'});
    cDsfenvio.addClass('campo').css({'width':'300px'});
	cDsperiod.addClass('campo').css({'width':'100px'});
	cFlgtitul.addClass('campo').css({'width':'100px'});
	cFlgobrig.addClass('campo').css({'width':'100px'});
	
	cNmrelato.desabilitaCampo();
	cDsfenvio.desabilitaCampo();
	cDsperiod.desabilitaCampo();
	
	cFlgobrig.habilitaCampo().focus();
	
	if(cCddopcao.val() == "I"){
		
		if ($('#tabSelecionaInformativo .corSelecao #envcpttl').val() == 0){
		
			$('#envcpttl','#frmDados').habilitaCampo().focus();	
			
		}else{
			
			$('#envcpttl','#frmDados').desabilitaCampo();
			
		}		
		
	}else{
			
		if ($('#tabInformativo .corSelecao #todostit').val() == 0){
		
			$('#envcpttl','#frmDados').habilitaCampo().focus();	
			
		}else{
			
			$('#envcpttl','#frmDados').desabilitaCampo();
			
		}
		
	}
		
	highlightObjFocus( $('#frmDados') );
		
	return false;
	
}

function controlaTitular() {
	
	if(cCddopcao.val() == "A" && ($('#tabInformativo .corSelecao #todostit').val() == 0 && $('#envcpttl','#frmDados').val() == 1 )){
			
		showError("inform","Ao trocar a op&ccedil;&atilde;o (Todos Titulares) para N&atilde;o, os informativos atribu&iacute;dos aos 2 titulares ser&atilde;o exclu&iacute;dos.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')) )");								
	}
							
	return false;
	
}

// formata
function formataCabecalho() {
	
	$('label[for="cddopcao"]','#frmCab').css('width','40px').addClass('rotulo');
	$('#cddopcao','#frmCab').css('width','570px');
	$('#divTela').css({'display':'inline'}).fadeTo(0,0.1);
	removeOpacidade('divTela');

	btnOK =  $('#btnOK','#'+frmCab);	          
	rCddopcao = $('label[for="cddopcao"]','#'+frmCab);	
	cCddopcao = $('#cddopcao','#'+frmCab);
			
	rCddopcao.addClass('rotulo').css({'width':'50px'});
	cCddopcao.css({'width':'510px'});
			
	cCddopcao.habilitaCampo().focus().val('C');
	
	btnOK.unbind('click').bind('click', function() { 
		
		if(cCddopcao.hasClass('campoTelaSemBorda') ){
			return false;
		}
		
		if ( divError.css('display') == 'block' ) { return false; }		
		
		cCddopcao.desabilitaCampo();	
		
		if(cCddopcao.val() == "I"){
			
			selecionaInformativos();
			
		}else{
		
			buscaInformativos();
			
		}
			
	});
	
	cCddopcao.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }

		// Se é a tecla ENTER
		if ( e.keyCode == 13) {

			btnContinuar();
			return false;
		}

	});	
	
	$('#frmDados').css('display','none');
			
	highlightObjFocus( $('#frmCab') );
	highlightObjFocus( $('#frmDados') );
		
	layoutPadrao();
	
	cCddopcao.focus();	
		
	return false;	
}

function navegaCampos() {

	cTodosCabDados.unbind('paste').bind('paste', function(e) {
		return false;
	});

	cNmrelato.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cNmrelato.focus();			
			return false;
		}
	});
		
	cDsfenvio.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cDsperiod.focus();
			return false;
		}
		return false;
	});

	cDsperiod.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cFlgtitul.focus();
			return false;
		}
		return false;
	});
			
	cFlgtitul.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cFlgobrig.focus();
			return false;
		}
		return false;
	});

	cFlgobrig.unbind('keypress').bind('keypress', function(e) {
		$('#btConcluir','#divBotoesInclui').click();
		return false;
	});	
	return false;
			
}

// Botoes
function btnIncluir() {
	$('#frmDados').css('display','block');
	
	mostrarTela("I");
	
	return false;
}

function btnAlterar() {
	mostrarTela("A");
			
	return false;
}

function btnExcluir() {
	if (nrdrowid === undefined) {return false;}
			
	if ($('#tabInformativo .corSelecao #existcra').val() == 0){
		
		showConfirmacao("C&oacute;digo sendo utilizado. Ao exclu&iacute;-lo todos os cooperados perder&atilde;o este informativo.","Confirma&ccedil;&atilde;o - Ayllos","excluirInformativo();","","concluir.gif","cancelar.gif");
	
	}else {	

		showConfirmacao("Voc&ecirc; tem certeza que deseja excluir o informativo selecionado?","Confirma&ccedil;&atilde;o - Ayllos","excluirInformativo();","","sim.gif","nao.gif");
		
	}
	return false;
}

function btnVoltar() {
	estadoInicial();
	return false;
}

function btnContinuar() {
		
	if ( divError.css('display') == 'block' ) { return false; }		
	
	if ( cCddopcao.hasClass('campo') ) {
		btnOK.click();
		
	}else{

		if(cCddopcao.val() == "I"){
				
			btnIncluir();
				
		}else if(cCddopcao.val() == "A"){
	
			btnAlterar();
		}else if(cCddopcao.val() == "E"){
	
			btnExcluir();
		}

	}
			
	return false;

}

function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onClick="btnVoltar(); return false;" >Voltar</a>&nbsp;');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onClick="btnContinuar(); return false;" >'+botao+'</a>&nbsp;');
	
	return false;
}

// Monta Grid Inicial
function buscaInformativos() {
	
	var cddopcao = $('#cddopcao','#frmCab').val();
	
	$('input,select').removeClass('campoErro');
	
	nrdrowid = "";

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, buscando informativo...");
	
	$.ajax({
		type	: "POST",
		dataType: "html",
		url		: UrlSite + "telas/cadinf/busca_informativo.php",
		data: {
			cddopcao : cddopcao,
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function(response) {
			hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
			
					$('#divTabela').html(response);
					return false;
				} catch(error) {						
			
					showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
				}
			} else {
				try {
			
					eval( response );						
				} catch(error) {
			
					showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
				}
			}
		}
	});
	return false;
}

// Monta Grid Inicial
function selecionaInformativos() {
	
	var cddopcao = $('#cddopcao','#frmCab').val();
	
	$('input,select').removeClass('campoErro');
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, buscando informativo...");
	
	$.ajax({
		type	: "POST",
		dataType: "html",
		url		: UrlSite + "telas/cadinf/seleciona_informativo.php",
		data: {
			cddopcao : cddopcao,
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function(response) {
			hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
			
					$('#divTabela').html(response);
					return false;
				} catch(error) {						
			
					showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
				}
			} else {
				try {
			
					eval( response );						
				} catch(error) {
			
					showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
				}
			}
		}
	});
	return false;
}

// Formata tabela de dados da remessa
function formataTabela() {

	// Habilita a conteudo da tabela
    $('#divCab').css({'display':'block'});

    var divRegistro = $('div.divRegistros', '#tabInformativo');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
	var conteudo	= $('#conteudo', linha).val();
	
    $('#tabConvenio').css({'margin-top':'1px'});
	divRegistro.css({'height':'300px','padding-bottom':'1px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '220px';
	arrayLargura[1] = '150px';
	arrayLargura[2] = '80px';
	arrayLargura[3] = '40px';

	var arrayAlinha = new Array();
	
	if(conteudo==0){
		arrayAlinha[0] = 'center';
	}else{
		arrayAlinha[0] = 'left';
	}
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'left';
	arrayAlinha[3] = 'left';
	arrayAlinha[4] = 'left';

	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	hideMsgAguardo();

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
		
		if(cCddopcao.val() == 'A'){
			btnAlterar();
		}else if(cCddopcao.val() == 'E'){
			btnExcluir();
			
		}
	});

    // seleciona o registro que é focado
	$('table > tbody > tr', divRegistro).focus( function() {
		selecionaTabela($(this));
	});

	$('table > tbody > tr:eq(0)', divRegistro).click();
	return false;
}

function selecionaTabela(tr) {
	
    nrdrowid = $('#nrdrowid', tr).val();
	regNmrelato = $('#nmrelato', tr).val();
	regDsfenvio = $('#dsfenvio', tr).val();
	regDsperiod = $('#dsperiod', tr).val();
	regFlgtitul = $('#envcpttl', tr).val();
	regFlgobrig = $('#envcobrg', tr).val();
	regCdrelato = $('#cdrelato', tr).val();
	regCdprogra = $('#cdprogra', tr).val();
	regCddfrenv = $('#cddfrenv', tr).val();
	regCdperiod = $('#cdperiod', tr).val();
	regTodosTit = $('#todostit', tr).val();
	return false;
}

// Formata tabela de dados da remessa
function formataTabelaInformativo() {

	// Habilita a conteudo da tabela
    $('#divCab').css({'display':'block'});

    var divRegistro = $('div.divRegistros', '#tabSelecionaInformativo');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
	var conteudo	= $('#conteudo', linha).val();
	
    $('#tabConvenio').css({'margin-top':'1px'});
	divRegistro.css({'height':'300px','padding-bottom':'1px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '230px';
	arrayLargura[1] = '150px';
	arrayLargura[2] = '80px';

	var arrayAlinha = new Array();
	
	if(conteudo==0){
		arrayAlinha[0] = 'center';
	}else{
		arrayAlinha[0] = 'left';
	}
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'left';
	arrayAlinha[3] = 'left';

	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	hideMsgAguardo();

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
		btnIncluir();
	});

    // seleciona o registro que é focado
	$('table > tbody > tr', divRegistro).focus( function() {
		selecionaTabela($(this));
	});

	$('table > tbody > tr:eq(0)', divRegistro).click();
	return false;
}

function mostrarTela(opcao) {
	
	if(cCddopcao.val() == "C" || cCddopcao.val() == "E"){
		
		return false;
		
	}else{
		
		// Mostra mensagem de aguardo
		showMsgAguardo("Aguarde, carregando informativo...");
	
		/* Abre nova tela para inclusao/edicao de convenio */
		$.ajax({
			type	: "POST",
			dataType: "html",
			url		: UrlSite + "telas/cadinf/cadastro_informativo.php",
			data: {
				redirect: "html_ajax"
			},
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')) )");
			},
			success: function(response) {
				hideMsgAguardo();
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
	
	if(cCddopcao.val() == "A"){
		buscaInformativos();
	}else{
		selecionaInformativos();	
	}
		
	return false;
}

function gravarInformativo(){
	
	$('input,select').removeClass('campoErro');
		
	var rowid    = nrdrowid;
						
	var nmrelato = cNmrelato.val();
	var dsfenvio = cDsfenvio.val();
	var dsperiod = cDsperiod.val();
	var flgtitul = cFlgtitul.val();
	var flgobrig = cFlgobrig.val();
	var cddopcao = cCddopcao.val();
	var todostit = $('#todostit','#frmDados').val();
	var cdrelato = $('#cdrelato','#frmDados').val();
	var cdprogra = $('#cdprogra','#frmDados').val();
	var cddfrenv = $('#cddfrenv','#frmDados').val();
	var cdperiod = $('#cdperiod','#frmDados').val();
		
	// Verificando qual tipo de gravacao
	if (cddopcao == "I"){
		var descricao = "inserido";
	}else{
		var descricao = "atualizado";
	}	
		
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, inserindo dados...");

	$.ajax({
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/cadinf/gravar_dados.php",
		data: {
			rowid    : rowid,
			cddopcao : cddopcao,
			nmrelato : nmrelato,
			dsfenvio : dsfenvio,
			dsperiod : dsperiod,
			flgtitul : flgtitul,
			flgobrig : flgobrig,
			todostit : todostit,
			cdrelato : cdrelato,
			cdprogra : cdprogra,
			cddfrenv : cddfrenv,
			cdperiod : cdperiod,
			redirect : "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			cTodosCabDados.removeClass('campoErro');
			hideMsgAguardo();
			try {
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						
						if(cCddopcao.val() == "I"){
							showError("inform","O informativo foi " + descricao + " com sucesso!","Alerta - Ayllos","encerraRotina(true);");
						}else{
							showError("inform","O informativo foi " + descricao + " com sucesso!","Alerta - Ayllos","encerraRotina(true);");
																																			
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

function excluirInformativo(){

	var cddopcao = $('#cddopcao','#frmCab').val();
	var rowid    = nrdrowid;
		
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, excluindo informativo...");

	$.ajax({
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/cadinf/excluir_informativo.php",
		data: {
			cddopcao : cddopcao,
			rowid    : rowid,
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
						showError("inform","O informativo foi exclu&iacute;do com sucesso!","Alerta - Ayllos","buscaInformativos();");
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

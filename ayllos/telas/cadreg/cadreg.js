/*!
 * FONTE        : cadreg.js									Última alteração: 25/05/2016
 * CRIAÇÃO      : Jéssica - DB1
 * DATA CRIAÇÃO : 19/09/2015
 * OBJETIVO     : Biblioteca de funções da tela CADREG
 * --------------
 * ALTERAÇÕES   :  27/11/2015 - Ajuste decorrente a homologação de conversão realizada pela DB1
                               (Adriano). 
				   
				   25/05/2016 - Ajustado a passagem do cddopcao para o busca_regional.php
								que estava ocasionando erro de permições. Ajuste feito
								para solucionar o problema do chamado 453430. (Kelvin)
							
 * -----------------------------------------------------------------------
 */
 
//Formulários e Tabela
var frmCab   	= 'frmCab';
var frmConsulta = 'frmConsulta';
var divConsulta = 'divConsulta';
var frmDados	= 'frmDados';
var tabRegional = 'tabRegional';
var divTabela;
var divRotina = '';

var cddopcao, cddregio, dsdregio, cdopereg, nmoperad, dsdemail, cdoperad, 
    cTodosCabecalho, btnOK, cTodosConsulta, cTodosCabDados;
	
var rCddopcao, rCddregio, rDsdregio, rCdopereg, rNmoperad, rDsdemail, 
    cCddopcao, cCddregio, cDsdregio, cCdopereg, cNmoperad, cDsdemail;

var nrdrowid = "";
var regCddregio = "";
var regDsdregio = "";
var regCdopereg = "";
var regNmoperad = "";
var regDsdemail = "";


$(document).ready(function() {	
	divTabela		= $('#divTabela');
	estadoInicial();			
	return false;
		
});

function carregaDados(){
	
	cddregio = $('#cddregio','#'+frmConsulta).val();
	dsdregio = $('#dsdregio','#'+frmConsulta).val();
	cdopereg = $('#cdoperad','#'+frmConsulta).val();
	nmoperad = $('#nmoperad','#'+frmConsulta).val();
	dsdemail = $('#dsdemail','#'+frmConsulta).val();
		
	return false;
}

// inicio
function estadoInicial() {

	$('#divTela').css({'display':'inline'}).fadeTo(0,0.1);
	$('#divTabela').html('');
	formataCabecalho();
	formataConsulta();
	
	$('#frmConsulta').limpaFormulario();
	
	$('#frmTabelaRegionais').css('display','none');
		
	removeOpacidade('divTela');
	
	$('#btSalvar','#divBotoes').hide();
	$('#btVoltar','#divBotoes').hide();
	$('#btAlterar','#divBotoes').hide();
		
    return false;
	
}

// formata
function formataCabecalho() {
	
	$('#divTela').css({'display':'block'}).fadeTo(0,0.1);
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
		
		if( cCddopcao.val() == "C" || cCddopcao.val() == "A"){
			buscaRegional(1,30);
		}else{
			buscaSequencialRegional();
			
		}
		
		cCddopcao.desabilitaCampo();		
			
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
			
	highlightObjFocus( $('#frmCab') );
	highlightObjFocus( $('#frmConsulta') );
		
	layoutPadrao();
	
	cCddopcao.focus();	
		
	return false;	
}

// Monta a tela Principal
function controlaLayout() {
		
	$('input,select').removeClass('campoErro');
	
	if(cCddopcao.val() == "C") {
		
		$('#frmConsulta').css('display','none');
					
		$('#btVoltar','#divBotoes').show().focus();
		$('#btSalvar','#divBotoes').hide();
			
	}else if(cCddopcao.val() == "A") {
		
		$('#btSalvar','#divBotoes').hide();
		$('#btVoltar','#divBotoes').show().focus();
		$('#btAlterar','#divBotoes').show();
		
	}else if(cCddopcao.val() == "I") {
		
		$('#frmConsulta').css('display','block');
		
		cDsdregio.focus();
		
		$('#btSalvar','#divBotoes').show();
		$('#btVoltar','#divBotoes').show();
		$('#btAlterar','#divBotoes').hide();
				
	}
				
	layoutPadrao();
	return false;
}


// Formatacao da Tela
function formataConsulta() {
	
	cTodosConsulta = $('input[type="text"],select','#frmConsulta');
	
	rCddregio = $('label[for="cddregio"]','#frmConsulta');
	rDsdregio = $('label[for="dsdregio"]','#frmConsulta');
	rCdopereg = $('label[for="cdoperad"]','#frmConsulta');
	rNmoperad = $('label[for="nmoperad"]','#frmConsulta');
	rDsdemail = $('label[for="dsdemail"]','#frmConsulta');
	          
	cCddregio = $('#cddregio','#frmConsulta');
	cDsdregio = $('#dsdregio','#frmConsulta');
	cCdopereg = $('#cdoperad','#frmConsulta');
	cNmoperad = $('#nmoperad','#frmConsulta');
	cDsdemail = $('#dsdemail','#frmConsulta');

	/** Formulario Dados **/
	rCddregio.css({'width':'150px'});
	rDsdregio.css({'width':'150px'});
	rCdopereg.css({'width':'150px'});
	rNmoperad.css({'width':'150px'});
	rDsdemail.css({'width':'150px'});

	cCddregio.addClass('inteiro').css({'width':'80px'}).desabilitaCampo();
    cDsdregio.css({'width':'400px'}).attr('maxlength','50').habilitaCampo();
	cCdopereg.css({'width':'100px'}).attr('maxlength','10').habilitaCampo();
	cNmoperad.css({'width':'277px'}).desabilitaCampo();
	cDsdemail.addClass('email').css({'width':'400px'}).attr('maxlength','60').habilitaCampo();
	
	cDsdregio.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false;}		
		// Se é a tecla ENTER, TAB
		if ( e.keyCode == 13  || e.keyCode == 9) {		
					
			$(this).removeClass('campoErro');
			cCdopereg.focus();
				
			return false;
		}
		
	});
	
	cCdopereg.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false;}		
		// Se é a tecla ENTER, TAB
		if ( e.keyCode == 13  || e.keyCode == 9) {		
					
			$(this).removeClass('campoErro');
			cDsdemail.focus();
				
			return false;
		}
		
	});
	
	cDsdemail.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }
				 
		// Se é a tecla ENTER, TAB
		if ( e.keyCode == 13  || e.keyCode == 9) {
			
			$(this).removeClass('campoErro');

			$('#btSalvar','#divBotoes').click();
			return false;
		}
				
	});
	
	controlaPesquisasLiberar();
	
	layoutPadrao();

	highlightObjFocus( $('#frmConsulta') );
	return false;
	
	
}

function btnVoltar(ope) {
	
	if(cCddopcao.val() == "A" && $('#frmConsulta').css('display')=='block'){
		
		if(ope == 0 ){
			showConfirmacao('Deseja cancelar a opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','btnVoltar(1);','$(this).focus()','sim.gif','nao.gif');
		}else{
			
			$('#frmConsulta').css('display','none').limpaFormulario();
		
			$('#frmTabelaRegionais').css('display','block');
			
			$('#btAlterar','#divBotoes').show();
			$('#btVoltar','#divBotoes').show();
			$('#btSalvar','#divBotoes').hide();
		
		}
		
	}else{
	
		estadoInicial();
		
	}
			
	return false;

}

function controlaPesquisasLiberar() {
			
	/*---------------------*/
	/*  CONTROLE OPERADOR  */
	/*---------------------*/
	var linkOperador = $('a:eq(0)','#frmConsulta');
	
	if ( linkOperador.prev().hasClass('campoTelaSemBorda') ) {		
		linkOperador.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {
		linkOperador.css('cursor','pointer').unbind('click').bind('click', function() {			
			
			bo			= 'ZOOM';
			procedure	= 'BUSCAOPERADORES';
			titulo      = 'Operador';
			qtReg		= '20';					
			filtrosPesq	= 'Cód. Operador;cdoperad;100px;S;;;descricao;|Nome ;nmoperad;200px;S;;;descricao;';
			colunas 	= 'Código;cdoperad;20%;right|Descrição;nmoperad;80%;left;';
							
			mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas);
		
		});
	}
		
	// Se pressionar cdoperad
	$('#cdoperad','#frmConsulta').unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
						
		// Se é a tecla ENTER, TAB, F1
		if ( e.keyCode == 13  || e.keyCode == 9 || e.keyCode == 18) {
		
			bo			= 'ZOOM';
			procedure	= 'BUSCAOPERADORES';
			titulo      = 'Operador';
			colunas 	= 'Código;cdoperad;20%;right|Descrição;nmoperad;80%;left;';
			filtrosDesc = 'nrregist|1;nriniseq|1';
			divRotina = $('#divTela');
			
			$(this).removeClass('campoErro');
			buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'nmoperad',$(this).val(),'nmoperad',filtrosDesc,'frmConsulta');
				
			return false;
		
		}
				
	});		
		
	return false;
	
}

function btnAlterar(element) {
	
	$('#frmConsulta #dsdemail').val($('#dsdemail', element).val());
	$('#frmConsulta #cddregio').val($('#cddregio', element).val());
	$('#frmConsulta #dsdregio').val($('#dsdregio', element).val());
	$('#frmConsulta #cdoperad').val($('#cdoperad', element).val());
	$('#frmConsulta #nmoperad').val($('#nmoperad', element).val());
	
	$('#frmConsulta').css('display','block');
	
	cDsdregio.focus();
	
	$('#frmTabelaRegionais').css('display','none');
	
	$('#btSalvar','#divBotoes').show();
	$('#btVoltar','#divBotoes').show();
	$('#btAlterar','#divBotoes').hide();
	
	
	return false;
}

function btnContinuar() {
		
	if ( divError.css('display') == 'block' ) { return false; }		
	
	if ( cCddopcao.hasClass('campo') ) {
		btnOK.click();
		
	}else{
		
		if(cCddopcao.val() == "C"){
			
			buscaRegional(1,30);
			
		}else if(cCddopcao.val() == "I" || cCddopcao.val() == "A"){
							
			gravarRegional();
				
		}

	}
			
	return false;

}

// Monta Grid Inicial
function buscaRegional(nriniseq , nrregist) {
	
	var cddopcao = cCddopcao.val();
	
	$('input,select').removeClass('campoErro');
	
	nrdrowid = "";

	$.ajax({
		type	: "POST",
		dataType: "html",
		url		: UrlSite + "telas/cadreg/busca_regional.php",
		data: {
			cddopcao : cddopcao,
			nriniseq : nriniseq,
			nrregist : nrregist,
			redirect: "html_ajax"
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function(response) {
			hideMsgAguardo();
			$("#divTabela").html(response);
			
		}
	});
	return false;
}

function buscaSequencialRegional(){
	
	var cddopcao = cCddopcao.val();
	
	showMsgAguardo( "Aguarde, buscando sequencial..." );
	
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/cadreg/busca_sequencial_regional.php",
        data: {
			cddopcao : cddopcao,
            redirect: "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#dsdregio','#frmConsulta').focus();");
        },
        success: function(response) {
            hideMsgAguardo();
			try {
				eval(response);
			} catch (error) {
					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#dsdregio','#frmConsulta').focus();");
				}
			}
    });
    return false;
}

// Formata tabela de dados da remessa
function formataTabela() {

	// Habilita a conteudo da tabela
    $('#divCab').css({'display':'block'});

    var divRegistro = $('div.divRegistros', '#tabRegional');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
	var conteudo	= $('#conteudo', linha).val();
	
    $('#tabConvenio').css({'margin-top':'1px'});
	divRegistro.css({'height':'300px','padding-bottom':'1px'});
	$('#divRegistrosRodape','#tabConvenio').formataRodapePesquisa();
	
	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '190px';
	arrayLargura[1] = '190px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'left';


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
	
	if (cCddopcao.val() == "A"){
	
		// seleciona o registro que é clicado
		$('table > tbody > tr', divRegistro).dblclick( function() {
			selecionaTabela($(this));
			btnAlterar($(this));
		});
		
	}

    // seleciona o registro que é focado
	$('table > tbody > tr', divRegistro).focus( function() {
		selecionaTabela($(this));
	});

	$('table > tbody > tr:eq(0)', divRegistro).click();
	return false;
}

function selecionaTabela(tr) {
    
	$('input,select').removeClass('campoErro');
	
	regCddregio = $('#cddregio', tr).val();
	regDsdregio = $('#dsdregio', tr).val();
	regCdopereg = $('#cdoperad', tr).val();
	regNmoperad = $('#nmoperad', tr).val();
	regDsdemail = $('#dsdemail', tr).val();
	return false;
}

function gravarRegional(){
	
	$('input,select').removeClass('campoErro');

	var cddregio = cCddregio.val();
	var dsdregio = cDsdregio.val();
	var cdopereg = cCdopereg.val();
	var dsdemail = cDsdemail.val();
	var cddopcao = cCddopcao.val();
	
	// Verificando qual tipo de gravacao
	if (cddopcao == "I"){
		var descricao = "inserido";
	}else{
		var descricao = "atualizado";
	}	
		
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, gravando informa&ccedil;&otilde;es...");

	$.ajax({
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/cadreg/gravar_dados.php",
		data: {
			cddopcao : cddopcao,
			cddregio : cddregio,
			dsdregio : dsdregio,
			cdopereg : cdopereg,
			dsdemail : dsdemail,
			redirect : "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			cTodosConsulta.removeClass('campoErro');
			hideMsgAguardo();
			try {
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						showError("inform","O informativo foi " + descricao + " com sucesso!","Alerta - Ayllos","estadoInicial();");
						
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

/*!
 * FONTE        : extrat.js
 * CRIAÇÃO      : Rogerius Militão (DB1) 
 * DATA CRIAÇÃO : 01/08/2011
 * OBJETIVO     : Biblioteca de funções da tela EXTRAT
 * --------------
 * ALTERAÇÕES   : 28/09/2011 - Incluido campo com informacoes do TAA (Gabriel).
				  31/07/2013 - Implementada opcao A da tela EXTRAT (Lucas).
 * -------------- 19/09/2013 - Implementada opcao AC da tela EXTRAT (Tiago).
 * -------------- 11/12/2013 - Ajuste em funvao buscaExtrato(). adicionado if para opcao "A". (Jorge)
 * -------------- 27/06/2014 - Incluir o campo COOP (Chamado 163044) - (Jonata - RKAM).
 * -------------- 26/11/2014 - Ajuste na função Gera_Impressao(). concatenado a extensão do arquivo
							   pois ao fazer download do arquivo não estava vindo com a extensão. (Kelvin - SD 218243)
 * -------------- 08/06/2016 - Ajuste na LOV para busca de cooperados pois não estava atualizando o campo
                               de conta com o valor escolhido, conforme solicitado no chamado 460148. (Kelvin)
 *                10/04/2017 - Permitir acessar o Ayllos mesmo vindo do CRM. (Jaison/Andrino)
 */

//Formulários e Tabela
var frmCab   		= 'frmCab';
var frmDados  		= 'frmExtrat';
var frmOpcao		= 'frmOpcao';
var frmArquivo		= 'frmArquivo';
var tabDados		= 'tabExtrat';
var cddopcao		= '';

//Labels/Campos do cabeçalho
var rNrdconta, rDtinimov, rDtfimmov, rCddopcao, rNmarquiv, rNmtpoarq, rListachq, rTipoarqv, cTipoarqv, cListachq,
	cNrdconta, cDtinimov, cDtfimmov, cCddopcao, cNmarquiv, cTodosCabecalho, btnOK, btnOKCab;

var rNmprimtl, rVllimcre, rCdagenc1,  
	cNmprimtl, cVllimcre, cCdagenc1, cTodosDados;

$(document).ready(function() {
	estadoInicial();
});


// seletores
function estadoInicial() {
	$('#divTela').fadeTo(0,0.1);
	
	hideMsgAguardo();		
	atualizaSeletor();
	formataCabecalho();
	formataDados();
	
	$('#btSalvar').css({'display':'none'});
	$('#'+tabDados).remove();
	$('#frmExtratSaldo').remove();
	$('#divPesquisaRodape').remove();
	
	cTodosCabecalho.limpaFormulario().removeClass('campoErro');	
	cTodosDados.limpaFormulario().removeClass('campoErro');	

	$('#linha1').css({'display':'none'});
	$('#linha2').css({'display':'none'});
	$('#'+frmDados).css({'display':'none'});
	$('#'+frmOpcao).css({'display':'none'});
	$('#'+frmArquivo).css({'display':'none'});
	$('#divBotoes').css({'display':'none'});
	
	$('#cddopcao','#'+frmCab).habilitaCampo();
	$('#cddopcao','#'+frmCab).focus();
	
	removeOpacidade('divTela');

    // Seta os valores caso tenha vindo do CRM
    if ($("#crm_inacesso","#frmOpcao").val() == 1) {
        $("#nrdconta","#frmOpcao").val($("#crm_nrdconta","#frmOpcao").val());
    }
}

function atualizaSeletor(){

	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab); 
	rNrdconta			= $('label[for="nrdconta"]','#'+frmOpcao); 
	rDtinimov			= $('label[for="dtinimov"]','#'+frmOpcao);
	rDtfimmov			= $('label[for="dtfimmov"]','#'+frmOpcao);
	rNmarquiv			= $('label[for="nmarquiv"]','#'+frmArquivo); 
	rNmtpoarq           = $('label[for="nmtpoarq"]','#'+frmArquivo); 
	
	rListachq			= $('label[for="listachq"]','#'+frmArquivo); 
	rTipoarqv			= $('label[for="tipoarqv"]','#'+frmArquivo); 
	
	cCddopcao			= $('#cddopcao','#'+frmCab);
	cNrdconta			= $('#nrdconta','#'+frmOpcao); 
	cDtinimov			= $('#dtinimov','#'+frmOpcao);	
	cDtfimmov			= $('#dtfimmov','#'+frmOpcao);	
	cNmarquiv			= $('#nmarquiv','#'+frmArquivo); 
	cListachq           = $('#listachq','#'+frmArquivo); 
	cTipoarqv           = $('#tipoarqv','#'+frmArquivo); 
	cTodosCabecalho		= $('input[type="text"],select','#'+frmOpcao);
	btnOK				= $('#btnOK','#'+ frmOpcao);
	btnOKCab			= $('#btnOKCab','#'+ frmCab);

	// contrato
	rNmprimtl	        = $('label[for="nmprimtl"]','#'+frmDados);        
	rVllimcre			= $('label[for="vllimcre"]','#'+frmDados);
	rCdagenc1			= $('label[for="cdagenc1"]','#'+frmDados);

	cNmprimtl			= $('#nmprimtl','#'+frmDados); 
	cVllimcre			= $('#vllimcre', '#'+frmDados);
	cCdagenc1			= $('#cdagenc1', '#'+frmDados);
	cTodosDados			= $('input[type="text"],select','#'+frmDados);
	
	
	return false;
}


// controle


function exibeFormularios(cddopcao) {

	estadoInicial();
	
	this.cddopcao = cddopcao;
			
	$('#'+frmOpcao).css({'display':'block'});
	$('#divBotoes').css({'display':'block'});	
	btnOK.css({'display':'block'})
	
	$('#cddopcao','#'+frmCab).desabilitaCampo();
	
	if (cddopcao == "A"){
		btnOK.css({'display':'none'})
		$('#btSalvar').css({'display':''});
		$('#'+frmArquivo).css({'display':'block'});
	}
	
	cNrdconta.focus();
	
}


function realizaOperacao() {

	if ( divError.css('display') == 'block' ) { return false; }		
	if ( cNrdconta.hasClass('campoTelaSemBorda')  ) { return false; }		

	// Armazena o número da conta na variável global
	var nrdconta = normalizaNumero( cNrdconta.val() );
	var nmarquiv = cNmarquiv.val();

	// Verifica se o número da conta é vazio
	if ( nrdconta == '' ) { return false; }

	// Verifica se a conta é válida
	if ( !validaNroConta(nrdconta) ) { 
		showError('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'nrdconta\',\''+ frmCab +'\');'); 
		return false; 
	}
	
	$('#'+frmDados).css({'display':'block'});
		
	// Se chegou até aqui, a conta é diferente do vazio e é válida, então realizar a operação desejada
	buscaExtrato(1, 50);
	
	return false;
}

function buscaExtrato( nriniseq, nrregist ) {

	hideMsgAguardo();

	var nrdconta = normalizaNumero( cNrdconta.val() );
	var nmarquiv = cNmarquiv.val();
	var dtinimov = cDtinimov.val();
	var dtfimmov = cDtfimmov.val();
	
	if ( cddopcao == "A"){
		
		if ( nmarquiv == '' ) { return false; }
		
		Gera_Impressao();
		return false;
	
	}
	
	var mensagem = 'Aguarde, listando extrato ...';
	showMsgAguardo( mensagem );	
	
	// Carrega dados da conta através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/extrat/principal.php', 
		data    : 
				{ 
					cddopcao	: cddopcao,
					nmarquiv	: nmarquiv,
					nrdconta	: nrdconta,
					dtinimov	: dtinimov,
					dtfimmov	: dtfimmov,
					nriniseq	: nriniseq,
					nrregist	: nrregist,
					redirect	: 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) {
					hideMsgAguardo();
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {							
							$('#divTela').html(response);
							return false;
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
						}
					} else {
						try {
							eval( response );
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
						}
					}

				}
	});
	
	return false;	
}

// imprimir pdf
function Gera_Impressao() {	

	//showMsgAguardo("Aguarde, gerando relatorio...");
	var nrdconta = normalizaNumero( cNrdconta.val() );
	var nmarquiv = cNmarquiv.val();
		
	var dtinimov = cDtinimov.val();
	var dtfimmov = cDtfimmov.val();	
	var cddopcao = $('#cddopcao','#frmCab').val(); 
	var nmarquiv = $('#nmarquiv','#frmArquivo').val();	
	
	var nriniseq = $('#nriniseq','#frmExtrat').val();
	var nrregist = $('#nrregist','#frmExtrat').val();
	var listachq = $('#listachq','#frmArquivo').val();
	var tipoarqv = $('#tipoarqv','#frmArquivo').val();
	
	nrregist = normalizaNumero(nrregist);	
	nriniseq = normalizaNumero(nriniseq);		
	
	$('#cddopcao1','#frmExtrat').val(cddopcao);
	$('#nmarquiv1','#frmExtrat').val(nmarquiv);
	$('#nrdconta1','#frmExtrat').val(nrdconta);
	$('#dtinimov1','#frmExtrat').val(dtinimov);
	$('#dtfimmov1','#frmExtrat').val(dtfimmov);
	$('#nriniseq1','#frmExtrat').val(nriniseq);
	$('#nrregist1','#frmExtrat').val(nrregist);	
	$('#listachq1','#frmExtrat').val(listachq);	
	
	if (cddopcao == "A" && listachq == "S"){
		$('#cddopcao1','#frmExtrat').val("AC");	
		nmarquiv = nmarquiv + tipoarqv;
		$('#nmarquiv1','#frmExtrat').val(nmarquiv);
	}
	else if(cddopcao == "A" && listachq == "N"){
		nmarquiv = nmarquiv + tipoarqv;
		$('#nmarquiv1','#frmExtrat').val(nmarquiv);
	}
	
	var action = UrlSite + 'telas/extrat/manter_rotina.php';
	
	$('#sidlogin','#frmExtrat').remove();	
	$('#frmExtrat').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '" />');
	
	carregaImpressaoAyllos("frmExtrat",action,"estadoInicial();");
	
	return false;		
}


function controlaPesquisas() {

	/*---------------------*/
	/*  CONTROLE CONTA/DV  */
	/*---------------------*/
	var linkConta = $('a:eq(0)','#'+ frmOpcao );

	if ( linkConta.prev().hasClass('campoTelaSemBorda') ) {		
		linkConta.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {
		linkConta.css('cursor','pointer').unbind('click').bind('click', function() {			
			mostraPesquisaAssociado('nrdconta', frmOpcao );
		});
	}

	return false;
}


// formata
function formataCabecalho() {
		
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
		
	rCddopcao.css('width','44px');	
	rNmarquiv.addClass('rotulo').css('width','260px');	
	rListachq.addClass('rotulo').css('width','130px');	
	rTipoarqv.addClass('rotulo').css('width','130px');	
	rNrdconta.addClass('rotulo').css({'width':'120px'});
	rDtinimov.addClass('rotulo-linha').css({'width':'80px'});
	rDtfimmov.addClass('rotulo-linha').css({'width':'5px'});
	

	cCddopcao.css({'width':'535px'});
	cNmarquiv.addClass('campo').css({'width':'200px'});
	cListachq.addClass('campo').css({'width':'80px'});
	cTipoarqv.addClass('campo').css({'width':'80px'});
	cNrdconta.addClass('conta pesquisa').css({'width':'80px'});
	cDtinimov.addClass('data').css({'width':'80px'});	
	cDtfimmov.addClass('data').css({'width':'80px'});	

	
	cTodosCabecalho.habilitaCampo();	
	
	var nomeForm    = 'frmCab';
	highlightObjFocus( $('#'+nomeForm) );
	
	var nomeForm    = 'frmExtrat';
	highlightObjFocus( $('#'+nomeForm) );
	
	// Se clicar no botao OK
	btnOK.unbind('click').bind('click', function() { 	
		realizaOperacao()
	});	
	
	cCddopcao.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			btnOKCab.focus();
			return false;
		}
	});

	cNrdconta.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			cDtinimov.focus();
			return false;
		} else if ( e.keyCode == 118 ) {
			mostraPesquisaAssociado('nrdconta', frmCab );
			return false;
		}
	});	
	
	
	cDtinimov.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			cDtfimmov.focus();
			return false;
		}
	});
	
	cDtfimmov.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			if (cddopcao == "T") {
				btnOK.focus();
				return false;
			} else if (cddopcao == "A") {
				cListachq.focus();		
				return false;
			}
		}
	});
	
	cListachq.unbind('keypress').bind('keypress', function(e){
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {		
			if (cddopcao == "A") {
				cTipoarqv.focus();
				return false;
			}	
		}			
	});

	cTipoarqv.unbind('keypress').bind('keypress', function(e){
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {		
		    if (cddopcao == "A") {				
				cNmarquiv.focus();
				return false;
			}	
		}	
	});
	
	cNmarquiv.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			buscaExtrato(0, 0);
			
			return false;
		}
	});
	
	cTipoarqv.change(function(e){	    	    	    
		rNmtpoarq.text(cTipoarqv.val());		
	})

	layoutPadrao();
	cNrdconta.trigger('blur');
	controlaPesquisas();
	return false;	
}

function formataDados() {

	rNmprimtl.addClass('rotulo').css({'width':'42px'});
	rVllimcre.addClass('rotulo-linha').css({'width':'93px'});
	rCdagenc1.addClass('rotulo-linha').css({'width':'35px'});

	cNmprimtl.css({'width':'253px'});	
	cVllimcre.css({'width':'95px'});
	cCdagenc1.css({'width':'30px'});
	
	if ( $.browser.msie ) {
		cNmprimtl.css({'width':'257px'});	
	}
	
	cTodosDados.desabilitaCampo();

	layoutPadrao();
	controlaPesquisas();
	
	return false;
}

function formataTabela() {
	
	// tabela
	var divRegistro = $('div.divRegistros', '#'+tabDados);		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
	
	$('#'+tabDados).css({'margin-top':'5px'});
	divRegistro.css({'height':'180px','padding-bottom':'2px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '62px';
	arrayLargura[1] = '190px';
	arrayLargura[2] = '89px';
	arrayLargura[3] = '15px';
	arrayLargura[4] = '80px';
	
	/*
	if ( $.browser.msie ) {
		arrayLargura[0] = '62px';
		arrayLargura[1] = '190px';
		arrayLargura[2] = '90px';
		arrayLargura[3] = '15px';
		arrayLargura[4] = '80px';
	}
	*/

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'center';
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'right';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	
	cTodosCabecalho.desabilitaCampo();
	cTodosDados.desabilitaCampo();

	/********************
	 FORMATA COMPLEMENTO	
	*********************/
	// complemento linha 1
	var linha1  = $('ul.complemento', '#linha1').css({'margin-left':'1px','width':'99.5%'});
	
	$('li:eq(0)', linha1).addClass('txtNormalBold').css({'width':'12%','text-align':'right'});
	$('li:eq(1)', linha1).addClass('txtNormal').css({'width':'59%'});
	$('li:eq(2)', linha1).addClass('txtNormalBold').css({'width':'12%','text-align':'right'});
	$('li:eq(3)', linha1).addClass('txtNormal');

	// complemento linha 2
	var linha2  = $('ul.complemento', '#linha2').css({'clear':'both','border-top':'0','width':'99.5%'});
	
	$('li:eq(0)', linha2).addClass('txtNormalBold').css({'width':'12%','text-align':'right'});
	$('li:eq(1)', linha2).addClass('txtNormal').css({'width':'10%'});
	$('li:eq(2)', linha2).addClass('txtNormalBold').css({'width':'12%','text-align':'right'});
	$('li:eq(3)', linha2).addClass('txtNormal').css({'width':'5%'});
	$('li:eq(4)', linha2).addClass('txtNormalBold').css({'width':'12%','text-align':'right'});
	$('li:eq(5)', linha2).addClass('txtNormal').css({'width':'20%'});
	$('li:eq(6)', linha2).addClass('txtNormal');

	if ( $.browser.msie ) {
		$('li:eq(1)', linha1).addClass('txtNormal').css({'width':'56%'});
		$('li:eq(3)', linha2).addClass('txtNormal').css({'width':'4%'});

	}	
	
	/********************
	  EVENTO COMPLEMENTO	
	*********************/
	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		selecionaTabela($(this));
	});	

	// seleciona o registro que é focado
	$('table > tbody > tr', divRegistro).focus( function() {
		selecionaTabela($(this));
	});	

	$('table > tbody > tr:eq(0)', divRegistro).click();
	$('#btSalvar', '#divBotoes').css({'display':'none'});
	controlaPesquisas();
	
	return false;
}

function selecionaTabela(tr) {

	$('#dshistor','.complemento').html( $('#dshistor', tr).val() );
	$('#dtliblan','.complemento').html( $('#dtliblan', tr).val() );
	$('#cdcoptfn','.complemento').html( $('#cdcoptfn', tr).val() );	
	$('#cdagenci','.complemento').html( $('#cdagenci', tr).val() );
	$('#cdbccxlt','.complemento').html( $('#cdbccxlt', tr).val() );
	$('#nrdolote','.complemento').html( $('#nrdolote', tr).val() );
	$('#dsidenti','.complemento').html( $('#dsidenti', tr).val() );
	return false;
}


// botoes
function btnVoltar() {
	estadoInicial();
	controlaPesquisas();
	return false;
}

function btnContinuar() {
	
	if ( divError.css('display') == 'block' ) { return false; }		
//	if ( cNrdconta.hasClass('campo')  ) { btnOK.click(); }
	   buscaExtrato(0, 0);
	
	return false;

}

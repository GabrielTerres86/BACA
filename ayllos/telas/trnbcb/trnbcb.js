/*!
 * FONTE        : trnbcb.js
 * CRIAÇÃO      : Jean Michel
 * DATA CRIAÇÃO : 09/04/2014
 * OBJETIVO     : Biblioteca de funções da tela TRNBCB
 * PROJETO		: Projeto de Novos Cartões Bancoob
 * --------------
 * ALTERAÇÕES   : 01/07/2014 - Inclusão do checkbox Movimenta C/C (Lucas Lunelli)
 * 				  11/08/2014 - Remoção de parâmetros (Lucas Lunelli)
 *				  02/03/2016 - Ajustes referentes ao projeto melhoria 157 (Lucas Ranghetti #330322)
 * --------------
 */

// Definição de algumas variáveis globais 
var cddopcao		= '0';
	
//Formulários
var frmCab   		= 'frmCab';

//Labels/Campos do cabeçalho
var rCddopcao, rCddtrans, rDsctrans, rCdcooper, rFlgdebcc;
var cCddopcao, cCddtrans, cDsctrans, cCdcooper, cFlgdebcc;
var cTodosCabecalho, btnCab;
var glbTabCdhistor, glbTabDshistor, glbTabCdtiptrn;

var erroTabela = 'Nao';
var incluiu = 'Nao';
var excluiu = 'Nao';
var erro_altera = 'nao';

$(document).ready(function() {
	
	estadoInicial();
	
	highlightObjFocus( $('#'+frmCab) );
	
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	
	return false;
	
});

// seletores
function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);
	$('#'+frmCab).css({'display':'block'});		
			
	formataCabecalho();
	
	cTodosCabecalho.limpaFormulario();
	cCddopcao.val( cddopcao );
	
	removeOpacidade('divTela');	
	unblockBackground();
	
	hideMsgAguardo();
		
	$('#cddtrans','#'+frmCab).desabilitaCampo();
	$('#dsctrans','#'+frmCab).desabilitaCampo();	
	$('#flgdebcc','#frmCab').habilitaCampo();
	
	$('input,select', '#'+frmCab).removeClass('campoErro');
	
	controlaFoco();
	
	erroTabela = 'Nao';
	excluiu = 'Nao';
	
	$("#divConteudo").css({"display":"none"});	
	$('#tabTrnbcb').css({'display':'none'});
	$('#fieldsettabTrnbcb').css({'display':'none'});
	$('#divBotoesTab').css({'display':'none'});
	$("#divBotoes").css({"display":"none"});	
}

function controlaFoco() {
	
	$('#cddopcao','#'+frmCab).unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#btnOK','#'+frmCab).focus();
			return false;
		}	
	});
	
	$('#btnOK','#'+frmCab).unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			escolheOpcao();
			if($('#cddopcao','#'+frmCab).val() == 'I') {
				reloadTabela();
			}
			return false;
		}	
	});
	
	$('#cddtrans','#'+frmCab).unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			 if($('#cddopcao','#'+frmCab).val() == 'I') {
				 $('#dsctrans','#'+frmCab).habilitaCampo().focus();			 
				 btnContinuar(4);
			 }else{
				 btnContinuar(1);
				return false;
			 }			
		}	
	});	
	
	$('#dsctrans','#'+frmCab).unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			 btnContinuar(1);
			return false;
		}	
	});	
	
	$('#btSalvar','#'+frmCab).unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			efetuarConsulta($('#cddopcao','#'+frmCab).val());
			$('#btVoltar','#'+frmCab).focus();
			return false;
		}	
	});
	
	$('#btVoltar','#'+frmCab).unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#cddopcao','#'+frmCab).focus();
			return false;
		}	
	});
	
	$('#cddopcao','#'+frmCab).val("C");
}

function formataCabecalho() {

	// cabecalho
	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab); 
	rCddtrans			= $('label[for="cddtrans"]','#'+frmCab);
	rFlgdebcc			= $('label[name="desvazio"]','#'+frmCab); 
	
	cCddopcao			= $('#cddopcao','#'+frmCab);
	cCddtrans			= $('#cddtrans','#'+frmCab);
	cDsctrans			= $('#dsctrans','#'+frmCab);		
	cFlgdebcc			= $('#flgdebcc','#'+frmCab);  
	
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	
	btnCab				= $('#btOK','#'+frmCab);
	
	rCddopcao.css('width','80px');
	rCddtrans.css('width','80px');	
	
	rFlgdebcc.css('width','77px');	
	//cFlgdebcc.css({'width':'10px'});
	
	
	cCddopcao.css({'width':'390px'});
	cCddtrans.css({'width':'60px'});
	cDsctrans.css({'width':'300px'});	
	
	cCddtrans.css('text-align','right');	
	
	cTodosCabecalho.habilitaCampo();
		
	$('#cddopcao','#'+frmCab).focus();	
	return false;	
}

function efetuarConsulta(opcao) {
	
	var cddtrans = $('#cddtrans','#'+frmCab).val();
	var dsctrans = $('#dsctrans','#'+frmCab).val();	
	var cdhistor = 0;
	var flgdebcc = $('#flgdebcc','#'+frmCab).prop('checked');
		
	if (flgdebcc == false) {
		flgdebcc = '0';
	} else {
		flgdebcc = '1';
	}	
	
	if (opcao == 'C') {		
		$('#flgdebcc','#frmCab').desabilitaCampo();
	}
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando dados...");	
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/trnbcb/manter_rotina.php", 
		data: {
			cddopcao: opcao,
			cddtrans: cddtrans,
			dsctrans: dsctrans,			
			cdhistor: cdhistor,
			flgdebcc: flgdebcc,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			hideMsgAguardo();
			eval(response);
			incluiu = 'Sim';
			excluiu = 'Sim';
		}				
	});
	
}

function controlaPesquisas(valor) {
	
	switch( valor )
	{
		case 1:
			controlaPesquisaCoop();
			break;
		case 2:
			controlaPesquisaHistorico();			
			break;		
	}
}

function escolheOpcao(){	
	$('#cddtrans','#'+frmCab).attr('disabled',false); 
	$('#cddtrans','#'+frmCab).attr('readonly',false); 
	$('#cddtrans','#'+frmCab).setMask("INTEGER","9999","","");
	$('#cddtrans','#'+frmCab).css("text-align","right");
	$('#cddtrans','#'+frmCab).focus();
}

function controlaPesquisaHistorico() {

	var cdcopaux = 3; /* CECRED */ 
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdhistor, titulo_coluna, cdgrupos, dshistor;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmVincHis';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdhistor = $('#cdhistor','#'+nomeFormulario).val();
	cdhistor = cdhistor;	
	dshistor = '';
	
	titulo_coluna = "Historicos";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-historicos';	
	titulo      = 'Historicos';
	qtReg		= '10';
	filtros 	= 'Codigo;cdhistor;130px;S;' + cdhistor + ';S|Descricao;dshistor;330px;S;' + dshistor + ';S';
	colunas 	= 'Codigo;cdhistor;20%;right|' + titulo_coluna + ';dshistor;50%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cdhistor\',\'#frmVincHis\').val();','undefined', cdcopaux);
	
	return false;
}

function  cancelaVinculo(){
	
	efetuarConsulta('E3');
	$('#cddopcao','#'+frmCab).val('C');
	$('#cddtrans','#'+frmCab).val('');
	$('#dsctrans','#'+frmCab).val('');	
	$('#flgdebcc','#'+frmCab).prop('checked', false);				
	estadoInicial();		
}

function btnVoltar(){
	var cddopcao = $('#cddopcao','#'+frmCab).val();
	
	if(cddopcao == 'I') {
		// Deve sempre excluir da tabela ao cancelar a operacao na opcao inclusão
		showConfirmacao('Deseja cancelar a inclus&atilde;o do novo v&iacute;nculo?','Confirma&ccedil;&atilde;o - Ayllos','cancelaVinculo()','','sim.gif','nao.gif');				
	}else if(cddopcao == 'A'){
		validaTabela('A3');
		if(erroTabela == 'Nao'){
			$('#cddopcao','#'+frmCab).val('C');
			$('#cddtrans','#'+frmCab).val('');
			$('#dsctrans','#'+frmCab).val('');	
			$('#flgdebcc','#'+frmCab).prop('checked', false);	
			
			estadoInicial();	
		}
	}else{
		$('#cddopcao','#'+frmCab).val('C');
		$('#cddtrans','#'+frmCab).val('');
		$('#dsctrans','#'+frmCab).val('');	
		$('#flgdebcc','#'+frmCab).prop('checked', false);	
		
		estadoInicial();	
	}
}

function btnContinuar(tipAcao){
	var cddopcao = $('#cddopcao','#'+frmCab).val();
	
	var cddtrans = $('#cddtrans','#'+frmCab).val();
	var dsctrans = $('#dsctrans','#'+frmCab).val();		
	var flgdebcc = $('#flgdebcc','#'+frmCab).prop('checked');
		
	if (cddtrans == null || cddtrans == '' || cddtrans == 0){
		showError("error","Informe o C&oacute;digo da Transa&ccedil;&atilde;o.","Alerta - Ayllos","");
		$('#cddtrans','#'+frmCab).focus();
		return false;
	}	
		
	$("#divConteudo").css({"display":"block"});	
	
	if(cddopcao == 'C'){
		$('#dsctrans','#'+frmCab).val('');					
		$('#flgdebcc','#'+frmCab).prop('checked', false);	
		
		$("#divBotoesTab").css({"display":"none"});	
	}else{		
		if(cddopcao != 'E'){
			$("#divBotoesTab").css({"display":"block"});	
		}		
	}	

	if(tipAcao == 2 && cddopcao == 'A') {
		validaTabela('A3');
		if(erroTabela == 'Nao'){			
			efetuarConsulta('A2');			
		}
	}else if(tipAcao == 2 && cddopcao == 'E'){ 
		showConfirmacao('Deseja continuar a  opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','efetuarConsulta(\'E2\')','','sim.gif','nao.gif');
	}else if(tipAcao == 4){
		efetuarConsulta('VT');
	}else if(tipAcao == 2 && cddopcao == 'I'){
		showConfirmacao('Confirma a inclus&atilde;o do novo v&iacute;nculo?','Confirma&ccedil;&atilde;o - Ayllos','efetuaInclusao()','','sim.gif','nao.gif');
	}else{
		efetuarConsulta(cddopcao);
	}
	
	if(tipAcao != 2 && cddopcao != 'I'){		
		reloadTabela();			
	}
}
function efetuaInclusao(){
	validaTabela('A3');
	if(erroTabela == 'Nao'){				
		if(incluiu == 'Sim'){			
			showError('inform','Vinculo cadastrado com sucesso','Alerta - Ayllos','estadoInicial();');
		}		
	}		
}

function mudaOpcao(){
	$('#cddtrans','#'+frmCab).val('');
	$('#dsctrans','#'+frmCab).val('');	
		
	$('#dsctrans','#'+frmCab).attr('disabled',true);		
}

// Formata a Tabela 
function formataTabelaTrnbcb(){	

	var divRegistro = $("div.divRegistros", "#tabTrnbcb");
	var tabela      = $("table", divRegistro );
	var linha       = $("table > tbody > tr", divRegistro );	
	
	$("#tabTrnbcb").css({"margin-top":"3px"});
	divRegistro.css({"height":"200px","width":"550px","padding-bottom":"3px"});

	var ordemInicial;

	var arrayLargura = new Array();
    arrayLargura[0] = "80px"; // Codigo
    arrayLargura[1] = ""; // Descricao
    arrayLargura[2] = "80px"; // Tipo    

    var arrayAlinha = new Array();
	arrayAlinha[0] = "right";
	arrayAlinha[1] = "left";
	arrayAlinha[2] = "left";	
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);	
	
	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		glbTabCdhistor = $(this).find('#tabcdhistor > span').text() ;
		glbTabDshistor = $(this).find('#tabdshistor > span').text() ;
		glbTabCdtiptrn = $(this).find('#tabtphistor > span').text() ;
	});	
	
	if(glbTabCdhistor == ''){
		$('table > tbody > tr:eq(0)', divRegistro).click();
	}else{
		$('table > tbody > tr', divRegistro).each( function(index){
			if( $(this).find('#tabcdhistor > span').text() == glbTabCdhistor ){
				$(this).click();
				return false;
			}
		});
	}
	
	$('#cdhistor','#frmVincHis').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			 controlaPesquisas(2);
			return false;
		}	
	});		
	
	$('#tabTrnbcb').css({'display':'block'});
	return false;	
	
}

function reloadTabela(){

	var opcao;
	var cddopcao = $('#cddopcao','#'+frmCab).val();
	var cddtrans = $('#cddtrans','#'+frmCab).val();
	var dsctrans = $('#dsctrans','#'+frmCab).val();	
	var cdhistor = 0;
	var flgdebcc = $('#flgdebcc','#'+frmCab).prop('checked');
		
	if (flgdebcc == false) {
		flgdebcc = '0';
	} else {
		flgdebcc = '1';
	}	

	opcao = 'C';
	
	$('#divBotoes').css({'display':'block'});
	
	// Carrega dados parametro através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/trnbcb/trnbcb_tabela.php', 
		data    : 
				{ 
					cddopcao: opcao,
					cddtrans: cddtrans,
					dsctrans: dsctrans,			
					cdhistor: cdhistor,					
					flgdebcc: flgdebcc,
					redirect: 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) { 
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {						
							$('#tabTrnbcb').html(response);
							formataTabelaTrnbcb();
							$('#fieldsettabTrnbcb').css({'display':'block'});
							if((cddopcao == 'I') || (cddopcao == 'A' )){ 
								$('#divBotoesTab').css({'display':'block'});
							}else{
								$('#divBotoesTab').css({'display':'none'});
							}
							addClickBotoes();
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

function addClickBotoes(){

	$('#btIncluir','#divBotoesTab').unbind('click').bind('click', function(e) {		
		validaTabela('I');
		if(erroTabela == 'Nao'){
			mostraTrnbcbHistorico('I1');	
		}
	});

	$('#btAlterar','#divBotoesTab').unbind('click').bind('click', function(e) {
		if ( glbTabCdhistor == '' ) {
			hideMsgAguardo();
			showError('error','N&atilde;o tem registros.','Alerta - Ayllos','unblockBackground()');
		} else {
			validaTabela('A');
			if(erroTabela == 'Nao'){
				mostraTrnbcbHistorico('A1');
			}
		}
	});
	
	$('#btExcluir','#divBotoesTab').unbind('click').bind('click', function(e) {
		if ( glbTabCdhistor == '' ) {
			hideMsgAguardo();
			showError('error','N&atilde;o tem registros.','Alerta - Ayllos','unblockBackground()');
		} else {
			showConfirmacao('Deseja realmente excluir o hist&oacute;rico selecionado?','Confirma&ccedil;&atilde;o - Ayllos','realizaOperacao(\'E1\');','return false;','sim.gif','nao.gif');
		}
	});	
	
	return false;
}

function mostraTrnbcbHistorico(opcao) {	

	showMsgAguardo('Aguarde, buscando vinculo da transacao bancoob x historico...');
	
	// Executa script através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/trnbcb/trnbcb_historico.php', 
		data: {
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			hideMsgAguardo();
			$('#divRotina').html(response);
			buscaTrnbcbHistorico(opcao);
		}				
	});
	return false;
	
}

function buscaTrnbcbHistorico(opcao) {

	showMsgAguardo('Aguarde, buscando vinculo da transacao bancoop x historico...');
	
	if(opcao == 'I'){
		var cddtrans = $('#cddtrans','#'+frmCab).val();
		var dsctrans = $('#dsctrans','#'+frmCab).val();
		var dshistor = '';
		var cdhistor = 0;		
	}else{
		var cddtrans = $('#cddtrans','#'+frmCab).val();
		var dsctrans = $('#dsctrans','#'+frmCab).val();
		var dshistor = 	glbTabDshistor;
		var cdhistor = glbTabCdhistor;
		var cdtiptrn = glbTabCdtiptrn;
	}		
	
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/trnbcb/busca_trnbcb_historico.php', 
		data: {
			cddopcao: opcao,
			cddtrans: cddtrans,
			dsctrans: dsctrans,
			dshistor: dshistor,			
			cdhistor: cdhistor,
			cdtiptrn: cdtiptrn,
			redirect: 'script_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {
		
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divConteudoOpcao').html(response);
					exibeRotina($('#divRotina'));
					formataTrnbcbHistor(opcao);					
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			} else {
				try {
					eval( response );
					controlaFoco();
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		}				
	});
	return false;
}

function formataTrnbcbHistor(opcao) {

	$('#divConteudoOpcao', '#telaTrnbcb').css({'width':'600px'});

 	// Rotulos 
	var rCddtrans	= $('label[for="cddtrans"]','#frmVincHis');
	var rDsctrans	= $('label[for="dsctrans"]','#frmVincHis');	
	var rCdhistor	= $('label[for="cdhistor"]','#frmVincHis');
	var rDshistor	= $('label[for="dshistor"]','#frmVincHis');
	var rTphistor	= $('label[for="tphistor"]','#frmVincHis'); 
	
	rCddtrans.addClass('rotulo').css('width','80px');
	rDsctrans.addClass('rotulo').css('width','140px');
	rCdhistor.addClass('rotulo').css('width','80px');
	rDshistor.addClass('rotulo').css('width','140px');
	rTphistor.addClass('rotulo').css('width','80px');
	
	// Campos
	var cTodos	  	= $('input[type="text"],select','#frmVincHis');
	var cCddtrans   = $('#cddtrans','#frmVincHis');
	var cDsctrans   = $('#dsctrans','#frmVincHis');
	var cCdhistor	= $('#cdhistor','#frmVincHis');	
	var cDshistor	= $('#dshistor','#frmVincHis');
	var cTphistor	= $('#tphistor','#frmVincHis');
	

	cTodos.habilitaCampo();	
	cCddopcao.css({'width':'390px'});
	cCddtrans.css({'width':'60px'});
	cDsctrans.css({'width':'300px'}).desabilitaCampo();
	cCdhistor.css({'width':'60px'});
	cDshistor.css({'width':'300px'}).desabilitaCampo();		
	
	cCddtrans.css('text-align','right');	
	cCdhistor.css('text-align','right');

	layoutPadrao();
	hideMsgAguardo();
	
	bloqueiaFundo( $('#divRotina') );
	highlightObjFocus( $('#frmVincHis') );
	
	$('#divRotina').centralizaRotinaH();
	
	$('#frmVincHis').css({'display':'block'});
	
	if(opcao == 'I'){
		cCddtrans.focus();
	}else{
		cCddtrans.desabilitaCampo();
		cCdhistor.focus();
	}
	reloadTabela(); //atualiza as linhas da tabela
		
	return false;
}

function validaTabela(opcao){
	
	var tabtphistor = new Array();	
	var dsctrans = $('#dsctrans','#frmVincHis').val();	
	
	erroTabela = 'Nao';
	
	$('#tabTrnbcb tbody tr').each(function(){				
		
		tabtphistor.push($("#tabtphistor",this).text().substring(1,10).trim());		
	});			
	
	if (opcao == 'A3'){ 
		if ($('#tabTrnbcb tbody tr').length < 2){ 		
			hideMsgAguardo();
			erroTabela = 'Sim';			
			showError('error','V&iacute;nculo com hist&oacute;ricos do Ayllos incompleto.','Alerta - Ayllos','unblockBackground()');			
		}		
	}	
		
	if (opcao == 'I'){		
		if ($('#tabTrnbcb tbody tr').length == 2){ 		
			hideMsgAguardo();
			erroTabela = 'Sim';
			showError('error','N&atilde;o &eacute; poss&iacute;vel vincular mais hist&oacute;ricos para esta transa&ccedil;&atilde;o Bancoob.','Alerta - Ayllos','unblockBackground()');	
			
			if ( ((tabtphistor[0] == 'ONLINE') && (tabtphistor[1] == 'ONLINE')) || 
				((tabtphistor[0] == 'OFFLINE') && (tabtphistor[1] == 'OFFLINE')) ) {				
				hideMsgAguardo();		
				erroTabela = 'Sim';
				showError('error','Hist&oacute;rico do tipo Online|Offline j&aacute; cadastrado.','Alerta - Ayllos','unblockBackground()');
			};
		}		
	}
}

function realizaOperacao(opcao){
	
	var cddopcao = opcao;
	var cddtrans = $('#cddtrans','#frmCab').val();
	var dsctrans = $('#dsctrans','#frmVincHis').val();	
	var cdhistor = $('#cdhistor','#frmVincHis').val();
	
	if(opcao == 'E1') {
		var tphistor = glbTabCdtiptrn;		
	}else{
		var tphistor = $('#tphistor','#frmVincHis').val();
	}
	var flgdebcc = $('#flgdebcc','#'+frmCab).prop('checked');
		
	if (flgdebcc == false) {
		flgdebcc = '0';
	} else {
		flgdebcc = '1';
	}		
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, processando dados...");
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/trnbcb/processa_dados.php",
		data: {
			cddopcao: cddopcao,
			cddtrans: cddtrans,
			dsctrans: dsctrans,			
			cdhistor: cdhistor,
			flgdebcc: flgdebcc,
			tphistor: tphistor,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			hideMsgAguardo();
			validaTabela(opcao);			
			if(erroTabela == 'Nao'){ 
				eval(response);					
				$('#telaTrnbcb').css({'display':'none'});				
				reloadTabela();
			}
		}				
	});	
}
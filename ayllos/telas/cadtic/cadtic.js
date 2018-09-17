/*!
 * FONTE        : cadtic.js
 * CRIAÇÃO      : Daniel Zimmermann / Tiago Machado Flor        
 * DATA CRIAÇÃO : 27/02/2013
 * OBJETIVO     : Biblioteca de funções da tela CADTIC
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */

// Definição de algumas variáveis globais 
var cddopcao		= 'C';
	
//Formulários
var frmCab   		= 'frmCab';

//Labels/Campos do cabeçalho
var rCddopcao, rCdtipcat, cCddopcao, cDstipcat, cTodosCabecalho;

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
	$('#frmCab').css({'display':'block'});
		
	formataCabecalho();
	
	cTodosCabecalho.limpaFormulario();
	cCddopcao.val( cddopcao );
	
	removeOpacidade('divTela');	
	unblockBackground();
	hideMsgAguardo();
	
	$('#cdtipcat','#frmCab').desabilitaCampo();
	$('#dstipcat','#frmCab').desabilitaCampo();
	
	trocaBotao('');
	$("#btVoltar","#divBotoes").hide();
	
	$('input,select', '#frmCab').removeClass('campoErro');
	
	controlaFoco();
		
}

function controlaFoco() {

	var bo, procedure, titulo;	
	
	$('#cddopcao','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				LiberaCampos();
				$('#cdtipcat','#frmCab').focus();
				return false;
			}	
	});
	
	$('#btnOK','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				LiberaCampos();
				$('#cdtipcat','#frmCab').focus();
				return false;
			}	
	});
	
	$('#cdtipcat','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 13 || e.keyCode == 9 ) {	
				if ( $('#cdtipcat','#frmCab').val() == '' ) {
					controlaPesquisa();
				} else {
					if ( ( $('#cddopcao','#frmCab').val() == 'I') ){
						$('#dstipcat','#frmCab').habilitaCampo();
						$('#dstipcat','#frmCab').focus();								
					}else{
						btnContinuar();
					}	
					return false;
				}		
			}	
	});
	
	$('#dstipcat','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			if ($('#dstipcat','#frmCab').val() != ''){
				btnContinuar();
				return false;
			}	
		}			
	});
	
}

function formataCabecalho() {

	// cabecalho
	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab); 
	rCdtipcat			= $('label[for="cdtipcat"]','#'+frmCab); 
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	
	cCddopcao			= $('#cddopcao','#'+frmCab); 
	cCdtipcat			= $('#cdtipcat','#'+frmCab); 
	cDstipcat			= $('#dstipcat','#'+frmCab); 
	
	rCddopcao.css({'width':'44px'});
	rCdtipcat.addClass('rotulo-linha').css({'width':'41px'});
	
	cCddopcao.css({'width':'460px'});
	cCdtipcat.css({'width':'90px'}).attr('maxlength','9').setMask('INTEGER','zzzzzzzzz','','');
	cDstipcat.css({'width':'380px'}).attr('maxlength','50').setMask("STRING",50,charPermitido(),"");
	
	if ( $.browser.msie ) {
		cCdtipcat.css({'width':'80px'});
		cDstipcat.css({'width':'386px'});
		cCddopcao.css({'width':'456px'});
	}	
	
	cTodosCabecalho.habilitaCampo();
	
	$('#cddopcao','#'+frmCab).focus();
				
	layoutPadrao();
	return false;	
}


// botoes
function btnVoltar() {
	estadoInicial();
	return false;
}

function LiberaCampos() {

	if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda')  ) { return false; }	

	// Desabilita campo opção
	cTodosCabecalho		= $('input[type="text"],select','#frmCab'); 
	cTodosCabecalho.desabilitaCampo();
	
	$('#cdtipcat','#frmCab').habilitaCampo();
	$('#dstipcat','#frmCab').desabilitaCampo();
	
	$('#divBotoes', '#divTela').css({'display':'block'});
	
	$("#btSalvar","#divBotoes").show();
	$("#btVoltar","#divBotoes").show();
	
	trocaBotao( 'Prosseguir');

	if ( $('#cddopcao','#frmCab').val() == 'I' ){
		buscaSequencial();
		$('#dstipcat','#frmCab').habilitaCampo();
		trocaBotao( 'Incluir');
		return false;	
	}	
	
	$('#cdtipcat','#frmCab').focus();

	return false;

}

function btnContinuar() {

	$('input,select', '#frmCab').removeClass('campoErro');

	cdtipcat = $('#cdtipcat','#frmCab').val();
	dstipcat = $('#dstipcat','#frmCab').val();
	cddopcao = cCddopcao.val();
	
	
	// Busca dados da Categoria na Alteração e Exclusão.
	if ( cdtipcat != '' ) {
		if ( ( cddopcao == 'A' ) || ( cddopcao == 'E' && dstipcat == '') ) {
			if ( $('#dstipcat','#frmCab').hasClass('campoTelaSemBorda')  ) {
				buscaDados();
				return false;
			}
		}
	}
	
	if ( cdtipcat == '' ){ 
		hideMsgAguardo();
		showError("error","C&oacute;digo da Categoria deve ser informado.","Alerta - Ayllos","focaCampoErro(\'cdtipcat\', \'frmCab\');",false);
		return false; }
		
	if ( ( cddopcao == 'A' && dstipcat == '' ) || ( cddopcao == 'I' && dstipcat == '' ) ){ 
		hideMsgAguardo();
		showError("error","Descri&ccedil;&atilde;o da Categoria deve ser informado.","Alerta - Ayllos","focaCampoErro(\'dstipcat\', \'frmCab\');",false);
		return false; }
	
	// Se chegou até aqui, o categoria é diferente do vazio e é válida, então realizar a operação desejada
	realizaOperacao();
	
	return false;
}

function realizaOperacao() {

	// Mostra mensagem de aguardo
	
	if (cddopcao == "C"){  	   showMsgAguardo("Aguarde, consultando tipo de categoria..."); } 
	else if (cddopcao == "I"){ showMsgAguardo("Aguarde, incluindo tipo de categoria...");  }
	else if (cddopcao == "A"){ showMsgAguardo("Aguarde, alterando tipo de categoria...");  }	
	else if (cddopcao == "E"){ showMsgAguardo("Aguarde, excluindo tipo de categoria...");  }	
	else { showMsgAguardo("Aguarde, liberando aplicacao..."); }
	
	var cdtipcat = $('#cdtipcat','#frmCab').val();
	cdtipcat = normalizaNumero(cdtipcat);
	
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadtic/manter_rotina.php", 
		data: {
			cdtipcat: cdtipcat,
			cddopcao: cddopcao,
			dstipcat: dstipcat,
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

function controlaPesquisa() {


	// Se esta desabilitado o campo contrato
	if ($("#cdtipcat","#frmCab").prop("disabled") == true)  {
		return;
	}
	
	if ( $('#cddopcao','#frmCab').val() == "I"){
		return false;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdtipcat, titulo_coluna, cdgrupos, dstipcat;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmCab';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdtipcat = $('#cdtipcat','#'+nomeFormulario).val();
	cdgrupos = cdtipcat;	
	dstipcat = '';
	
	titulo_coluna = "Tipos de Categoria";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-tipos-categoria';
	titulo      = 'Tipos de categoria';
	qtReg		= '20';
	filtros 	= 'Codigo;cdtipcat;130px;S;' + cdtipcat + ';S|Descricao;dstipcat;100px;S;' + dstipcat + ';N';
	colunas 	= 'Codigo;cdtipcat;15%;right|' + titulo_coluna + ';dstipcat;85%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cdtipcat\',\'#frmCab\').val()');
	
	return false;

}


function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>');

	if ( botao != '') {
		$('#divBotoes','#divTela').append('&nbsp;<a href="#" class="botao" onClick="btnContinuar(); return false;" >'+botao+'</a>');
	}
	return false;
}

function buscaDados() {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, consultando categoria...");
	
	var cdtipcat = $('#cdtipcat','#frmCab').val();
	cdtipcat = normalizaNumero(cdtipcat);
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadtic/busca_dados.php", 
		data: {
			cdtipcat: cdtipcat,
			cddopcao: cddopcao,
			dstipcat: dstipcat,
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

function buscaSequencial(){

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, buscando novo c&oacute;digo...");

	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadtic/busca_sequencial.php", 
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
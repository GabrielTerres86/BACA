/*!
 * FONTE        : cadgru.js
 * CRIAÇÃO      : Tiago Machado          
 * DATA CRIAÇÃO : 21/02/2013
 * OBJETIVO     : Biblioteca de funções da tela CADGRU
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */

// Definição de algumas variáveis globais 
var cddopcao		= 'C';
	
//Formulários
var frmCab   		= 'frmCab';

//Labels/Campos do cabeçalho
var rCddopcao, rcddgrupo, cCddopcao, ccddgrupo, cDsdgrupo, cTodosCabecalho, btnCab;

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
	$('#divBotoes').css({'display':'none'});
	
	trocaBotao( '' );
		
	formataCabecalho();
	
	cTodosCabecalho.limpaFormulario();
	cCddopcao.val( cddopcao );
	
	removeOpacidade('divTela');	
	unblockBackground();
	hideMsgAguardo();
	
	$('#cddgrupo','#frmCab').desabilitaCampo();
	$('#dsdgrupo','#frmCab').desabilitaCampo();
	
	trocaBotao('');
	$("#btVoltar","#divBotoes").hide();
	
	$('input,select', '#frmCab').removeClass('campoErro');
	
	controlaFoco();
		
}

function controlaFoco() {

	$('#cddopcao','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				LiberaCampos();
				return false;
			}	
	});
	
	$('#btnOK','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				LiberaCampos();
				$('#cddgrupo','#frmCab').focus();
				return false;
			}	
	});
	
	$('#cddgrupo','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 13 || e.keyCode == 9 ) {	
				if ( $('#cddgrupo','#frmCab').val() == '' ) {
					controlaPesquisa();
				} else {
					if ( $('#cddopcao','#frmCab').val() == 'I'){
						$('#dsdgrupo','#frmCab').habilitaCampo();
						$('#dsdgrupo','#frmCab').focus();								
					}else{
						btnContinuar(); 
					}	
					return false;
				}		
			}	
	});
	
	$('#dsdgrupo','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			if ($('#dsdgrupo','#frmCab').val() != ''){
				btnContinuar();
				return false;
			}	
		}			
	});
	
}

function formataCabecalho() {

	// cabecalho
	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab); 
	rcddgrupo			= $('label[for="cddgrupo"]','#'+frmCab); 
	
	cCddopcao			= $('#cddopcao','#'+frmCab); 
	ccddgrupo			= $('#cddgrupo','#'+frmCab); 
	cDsdgrupo			= $('#dsdgrupo','#'+frmCab); 
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	btnCab				= $('#btOK','#'+frmCab);
	
	rCddopcao.css('width','44px');
	rcddgrupo.addClass('rotulo-linha').css({'width':'41px'});
	
	cCddopcao.css({'width':'460px'});
	ccddgrupo.css({'width':'90px'}).attr('maxlength','9').setMask('INTEGER','zzzzzzzzz','','');
	cDsdgrupo.css({'width':'380px'}).attr('maxlength','50').setMask("STRING",50,charPermitido(),"");
	
	if ( $.browser.msie ) {
		rcddgrupo.css({'width':'44px'});
		cDsdgrupo.css({'width':'376px'});
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
	
	$('#cddgrupo','#frmCab').habilitaCampo();
	$('#dsdgrupo','#frmCab').desabilitaCampo();
	
	$('#divBotoes', '#divTela').css({'display':'block'});
	
	$("#btSalvar","#divBotoes").show();
	$("#btVoltar","#divBotoes").show();
	
	trocaBotao( 'Prosseguir');

	if ( $('#cddopcao','#frmCab').val() == 'I' ){
		buscaSequencial();
		$('#dsdgrupo','#frmCab').habilitaCampo();
		trocaBotao( 'Incluir');
		return false;
	}
	
	$('#cddgrupo','#frmCab').focus();

	return false;

}

function btnContinuar() {

	$('input,select', '#frmCab').removeClass('campoErro');

	cddgrupo = normalizaNumero( ccddgrupo.val() );
	dsdgrupo = $('#dsdgrupo','#frmCab').val();
	cddopcao = cCddopcao.val();
	
	// Busca dados do Grupo na Alteração e Exclusão.
	if ( cddgrupo != '' ) {
		if ( ( cddopcao == 'A' ) ) {
			if ( $('#dsdgrupo','#frmCab').hasClass('campoTelaSemBorda')  ) {  buscaDados(); return false; }
		}
		
		if ( cddopcao == 'E') {
			if ( ! $('#cddgrupo','#frmCab').hasClass('campoTelaSemBorda') ) { buscaDados();	return false; }
		}
	}
	
	if ( cddgrupo == '' ){ 
		hideMsgAguardo();
		showError("error","C&oacute;digo do Grupo deve ser informado.","Alerta - Ayllos","focaCampoErro(\'cddgrupo\', \'frmCab\');",false);
		return false; }
		
	if ( ( cddopcao == 'A' && dsdgrupo == '' ) || ( cddopcao == 'I' && dsdgrupo == '' ) ){ 
		hideMsgAguardo();
		showError("error","Descri&ccedil;&atilde;o do Grupo deve ser informado.","Alerta - Ayllos","focaCampoErro(\'dsdgrupo\', \'frmCab\');",false);
		return false; }
	
	// Se chegou até aqui, o grupo é diferente do vazio e é válida, então realizar a operação desejada
	realizaOperacao();
	
	return false;
		
}

function realizaOperacao() {

	// Mostra mensagem de aguardo
	
	if (cddopcao == "C"){  	   showMsgAguardo("Aguarde, consultando grupo..."); } 
	else if (cddopcao == "I"){ showMsgAguardo("Aguarde, incluindo grupo...");  }
	else if (cddopcao == "A"){ showMsgAguardo("Aguarde, alterando grupo...");  }	
	else if (cddopcao == "E"){ showMsgAguardo("Aguarde, excluindo grupo...");  }
	else { showMsgAguardo("Aguarde, liberando aplicacao..."); }
	
	var cddgrupo = $('#cddgrupo','#frmCab').val();
	cddgrupo = normalizaNumero(cddgrupo);
	
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadgru/manter_rotina.php", 
		data: {
			cddgrupo: cddgrupo,
			cddopcao: cddopcao,
			dsdgrupo: dsdgrupo,
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
	if ($("#cddgrupo","#frmCab").prop("disabled") == true)  {
		return;
	}
	
	if ( $('#cddopcao','#frmCab').val() == "I"){
		return false;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cddgrupo, titulo_coluna, cdgrupos, dsdgrupo;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmCab';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cddgrupo = $('#cddgrupo','#'+nomeFormulario).val();
	cdgrupos = cddgrupo;
	//cddgrupo = normalizaNumero($(cddgrupo).val());
	dsdgrupo = '';
	
	titulo_coluna = "Grupos de produto";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-grupos';
	titulo      = 'Grupos';
	qtReg		= '20';
	filtros 	= 'Codigo;cddgrupo;100px;S;' + cddgrupo + ';S|Descricao;dsdgrupo;150px;S;' + dsdgrupo + ';S';
	colunas 	= 'Codigo;cddgrupo;20%;right|' + titulo_coluna + ';dsdgrupo;50%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cddgrupo\',\'#frmCab\').val()');
	
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
	showMsgAguardo("Aguarde, consultando grupo...");
	
	var cddgrupo = $('#cddgrupo','#frmCab').val();
	cddgrupo = normalizaNumero(cddgrupo);
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadgru/busca_dados.php", 
		data: {
			cddgrupo: cddgrupo,
			cddopcao: cddopcao,
			dsdgrupo: dsdgrupo,
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
		url: UrlSite + "telas/cadgru/busca_sequencial.php", 
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
/*!
 * FONTE        : cadmet.js
 * CRIAÇÃO      : Daniel Zimmermann          
 * DATA CRIAÇÃO : 06/03/2013
 * OBJETIVO     : Biblioteca de funções da tela CADMET
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */

// Definição de algumas variáveis globais 
var cddopcao		= 'C';
	
//Formulários
var frmCab   		= 'frmCab';

//Labels/Campos do cabeçalho
var rCddopcao, cCddopcao, cCdmotest, cDsmotest, cTpdado, cTodosCabecalho ;

$(document).ready(function() {

	estadoInicial();
	
	highlightObjFocus( $('#'+frmCab) );
	
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	
	return false;
	
});

// Estado Inicial
function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);
	$('#frmCab').css({'display':'block'});
		
	formataCabecalho();
	
	cTodosCabecalho.limpaFormulario();
	$('#tpaplica','#frmCab').val(1);
	cCddopcao.val( cddopcao );
	
	removeOpacidade('divTela');	
	unblockBackground();
	hideMsgAguardo();
	
	cTodosCabecalho.desabilitaCampo();
	$('#cddopcao','#frmCab').habilitaCampo().focus();
	
	$('#divBotoes').css({'display':'none'});
	
	$('input,select', '#frmCab').removeClass('campoErro');
	
	controlaFoco();
		
}

function controlaFoco() {
 
	$('#cddopcao','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				LiberaCampos();
				if ($('#cddopcao','#frmCab').val() == 'I') {
					$('#dsmotest','#frmCab').focus();
					return false; }
				else{
					$('#cdmotest','#frmCab').focus();
					return false; }
			}	
	});
	
	$('#btnOK','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {				
					LiberaCampos();
				if ($('#cddopcao','#frmCab').val() == 'I') {
					$('#dsmotest','#frmCab').focus();
					return false; }
				else{
					$('#cdmotest','#frmCab').focus();
					return false; }
			}	
	});
	
	$('#cdmotest','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				if ( $('#cdmotest','#frmCab').val() == '' ) {
					controlaPesquisa(1);
				} else {
					btnContinuar();					
					$('#dsmotest','#frmCab').focus();
					return false;
				}
			}	
	});	
	
	$('#dsmotest','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				if ( $('#dsmotest','#frmCab').val() == '' ) {
						btnContinuar();
						return false;
				} else {
					$('#tpaplica','#frmCab').focus();
					return false;
				}
			}	
	});
	
	$('#tpaplica','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			if ($('#tpaplica','#frmCab').val() != ''){
				btnContinuar();
				return false;
			}
		}			
	}); 
	
}

function formataCabecalho() {

	// Rotulo
	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab);
	rCdmotest			= $('label[for="cdmotest"]','#'+frmCab); 
	rDsmotest			= $('label[for="dsmotest"]','#'+frmCab);
	rTpaplica			= $('label[for="tpaplica"]','#'+frmCab); 	
	
	// Campo
	cCddopcao			= $('#cddopcao','#'+frmCab); 
	cCdmotest			= $('#cdmotest','#'+frmCab);
	cDsmotest			= $('#dsmotest','#'+frmCab); 
	cTpaplica           = $('#tpaplica','#'+frmCab); 
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	
	rCddopcao.addClass('rotulo').css({'width':'120px'});
	rCdmotest.addClass('rotulo').css({'width':'120px'});
	rDsmotest.addClass('rotulo').css({'width':'120px'});
	rTpaplica.addClass('rotulo').css({'width':'120px'});
	
	cCddopcao.css({'width':'470px'});	
	cCdmotest.css({'width':'90px'}).attr('maxlength','50').setMask('INTEGER','zzzzzzzzz','','');
	cDsmotest.css({'width':'505px'}).attr('maxlength','50').setMask("STRING",50,charPermitido(),"");
	cTpaplica.css({'width':'150px'}).attr('maxlength','9');
	
	cTodosCabecalho.habilitaCampo();
	
	$('#cddopcao','#'+frmCab).focus();
	
	highlightObjFocus( $('#'+frmCab) );
				
	layoutPadrao();
	return false;	
}


// Voltar
function btnVoltar() {
	
	estadoInicial();
	return false;
}

function LiberaCampos() {

	if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda')  ) { return false; }	
	

	// Desabilita campo opção
	cTodosCabecalho		= $('input[type="text"],select','#frmCab'); 
	cTodosCabecalho.desabilitaCampo();
	
	$('#cdmotest','#frmCab').habilitaCampo();
	$('#dsmotest','#frmCab').habilitaCampo();
	$('#tpaplica','#frmCab').habilitaCampo();
	
	$('#divBotoes', '#divTela').css({'display':'block'});
	
	trocaBotao( 'Prosseguir' );

	if ( $('#cddopcao','#frmCab').val() == 'I' ){		
		buscaSequencial(); 
		$('#dsmotest','#frmCab').habilitaCampo();
		$('#dsmotest','#frmCab').focus();
		trocaBotao( 'Incluir');
		return false;	
	}
	
	if ( $('#cddopcao','#frmCab').val() != 'I' ) {		
		$('#dsmotest','#frmCab').desabilitaCampo();
		$('#tpaplica','#frmCab').desabilitaCampo();
		$('#cdmotest','#frmCab').focus();
		return false;	
	}
	
	

	return false;

}

function btnContinuar() {

	$('input,select', '#frmCab').removeClass('campoErro');
	
	cddopcao = cCddopcao.val();	
	cdmotest = normalizaNumero( cCdmotest.val() );
	dsmotest = $('#dsmotest','#frmCab').val();
	
	if (( cdmotest != '' ) && ( ! $('#cdmotest','#frmCab').hasClass('campoTelaSemBorda') )) {		
		buscaDados(1);
		return false;
	}
		
	if ( $('#cdmotest','#frmCab').hasClass('campoTelaSemBorda')  ) {
		if ( cdmotest == '' ){ 
			hideMsgAguardo();
			showError("error","C&oacute;digo do Motivo deve ser informado.","Alerta - Ayllos","focaCampoErro(\'cdmotest\', \'frmCab\');",false);
			return false; 
		}
			
		if ( ( cddopcao == 'A' && dsmotest == '' ) || ( cddopcao == 'I' && dsmotest == '' ) ){ 
			hideMsgAguardo();
			showError("error","Descri&ccedil;&atilde;o do Motivo deve ser informado.","Alerta - Ayllos","focaCampoErro(\'dsmotest\', \'frmCab\');",false);
			return false; 
		}			
		
		realizaOperacao();
	}
		
	return false;
}

function realizaOperacao() {

	// Mostra mensagem de aguardo
	if (cddopcao == "C"){  	   showMsgAguardo("Aguarde, consultando Parametro..."); } 
	else if (cddopcao == "I"){ showMsgAguardo("Aguarde, incluindo Parametro...");  }
	else if (cddopcao == "A"){ showMsgAguardo("Aguarde, alterando Parametro...");  }	
	else if (cddopcao == "E"){ showMsgAguardo("Aguarde, excluindo Parametro...");  }	
	else { showMsgAguardo("Aguarde, liberando aplicacao..."); }
	
	var cdmotest = $('#cdmotest','#frmCab').val();
	var tpaplica = $('#tpaplica','#frmCab').val();
	var dsmotest = $('#dsmotest','#frmCab').val();
	
	cdmotest = normalizaNumero(cdmotest);
	tpaplica = normalizaNumero(tpaplica);
	
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadmet/manter_rotina.php", 
		data: {
			cdmotest: cdmotest,
			cddopcao: cddopcao,
			tpaplica: tpaplica,
			dsmotest: dsmotest,
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

function controlaPesquisa( valor ) {

	switch( valor )
	{
		case 1:
		  controlaPesquisaMotivos();
		  break;
	}

}


function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>');

	if ( botao != '') {
		$('#divBotoes','#divTela').append('&nbsp;<a href="#" class="botao" onClick="btnContinuar(); return false;" >'+botao+'</a>');
	}
	return false;
	
}

function buscaDados( valor ) {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, consultando...");

	switch( valor )
	{
		case 1:
		  buscaDadosMotivo();		  		  
		  break;
	}

}

function buscaDadosMotivo() {

var cdmotest = $('#cdmotest','#frmCab').val();
	cdmotest = normalizaNumero(cdmotest);
		
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadmet/busca_motivo.php", 
		data: {
			cdmotest: cdmotest,
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

function buscaSequencial(){

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, buscando novo c&oacute;digo...");

	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadmet/busca_sequencial.php", 
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

function controlaPesquisaMotivos() {

	// Se esta desabilitado o campo 
	if ($("#cdmotest","#frmCab").prop("disabled") == true)  {
		return;
	}
	
 	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdmotest, titulo_coluna, cdmotests, dsmotest, tpaplica;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmCab';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdmotest = $('#cdmotest','#'+nomeFormulario).val();
	cdmotests = cdmotest;	
	dsmotest = '';
	tpaplica = 1;
	
	titulo_coluna = "Descricao";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-met';
	titulo      = 'Motivos de Estorno Baixa de Tarifas';
	qtReg		= '10';
	filtros 	= 'Codigo;cdmotest;130px;S;' + cdmotest + ';S|Descricao;dsmotest;100px;S;' + dsmotest + ';N|Aplicacao;tpaplica;100px;N;' + tpaplica + ';N';
	colunas 	= 'Codigo;cdmotest;20%;right|' + titulo_coluna + ';dsmotest;50%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cdmotest\',\'#frmCab\').val()');
	
	return false; 
}

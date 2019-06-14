/*!
 * FONTE        : cadint.js
 * CRIAÇÃO      : Tiago Machado          
 * DATA CRIAÇÃO : 21/02/2013
 * OBJETIVO     : Biblioteca de funções da tela CADINT
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */

// Definição de algumas variáveis globais 
var cddopcao		= 'C';
	
//Formulários
var frmCab   		= 'frmCab';

//Labels/Campos do cabeçalho
var rCddopcao, rcdinctar, cCddopcao, ccdinctar, cdsinctar, cTodosCabecalho, btnCab;

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
	
	$('#cdinctar','#frmCab').desabilitaCampo();
	$('#dsinctar','#frmCab').desabilitaCampo();
	
	$('#flgocorr','#frmCab').prop('checked',false).desabilitaCampo();
	$('#flgmotiv','#frmCab').prop('checked',false).desabilitaCampo();
	
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
				$('#cdinctar','#frmCab').focus();
				return false;
			}	
	});
	
	$('#btnOK','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				LiberaCampos();
				$('#cdinctar','#frmCab').focus();
				return false;
			}	
	});
	
	$('#cdinctar','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 118 ) {	
				if ( $('#cdinctar','#frmCab').val() == '' ) {
					controlaPesquisa();
				} else {
					if (( $('#cddopcao','#frmCab').val() == 'I')){
						$('#dsinctar','#frmCab').habilitaCampo();
						$('#dsinctar','#frmCab').focus();	
					}else{
						btnContinuar();  						
					}	
					return false;
				}		
			}	
	});
	
	$('#dsinctar','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			if ($('#dsinctar','#frmCab').val() != ''){
				$('#flgocorr','#frmCab').focus();	
				return false;
			}	
		}			
	});
	
	$('#flgocorr','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				$('#flgmotiv','#frmCab').focus();	
		}			
	});
	
	$('#flgmotiv','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				btnContinuar();
		}			
	});

	$('#flgocorr','#frmCab').unbind('click').bind('click', function(e) {
			
		if( $(this).prop("checked") == true ){
			$(this).val("yes");			
		}else{
			$(this).val("no");			
		}		
			
	});

	$('#flgmotiv','#frmCab').unbind('click').bind('click', function(e) {
			
		if( $(this).prop("checked") == true ){
			$(this).val("yes");			
		}else{
			$(this).val("no");			
		}		
			
	});
	
}

function formataCabecalho() {

	// cabecalho
	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab); 
	rcdinctar			= $('label[for="cdinctar"]','#'+frmCab); 
	
	cCddopcao			= $('#cddopcao','#'+frmCab); 
	ccdinctar			= $('#cdinctar','#'+frmCab); 
	cdsinctar			= $('#dsinctar','#'+frmCab); 
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	btnCab				= $('#btOK','#'+frmCab);
	
	rCddopcao.css('width','44px');
	rcdinctar.addClass('rotulo-linha').css({'width':'41px'});
	
	cCddopcao.css({'width':'460px'});
	ccdinctar.css({'width':'90px'}).attr('maxlength','9').setMask('INTEGER','zzzzzzzzz','','');;
	cdsinctar.css({'width':'380px'}).setMask("STRING",30,charPermitido(),"");;
	
	if ( $.browser.msie ) {
		rcdinctar.css({'width':'44px'});
		cdsinctar.css({'width':'376px'});
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
	
	$('#cdinctar','#frmCab').habilitaCampo();
	// $('#dsinctar','#frmCab').desabilitaCampo();
	// $('#flgocorr','#frmCab').desabilitaCampo();
	// $('#flgmotiv','#frmCab').desabilitaCampo();
	
	$('#divBotoes', '#divTela').css({'display':'block'});
	
	$("#btSalvar","#divBotoes").show();
	$("#btVoltar","#divBotoes").show();
	
	trocaBotao( 'Prosseguir');

	if ( $('#cddopcao','#frmCab').val() == 'I' ) {
		$('#dsinctar','#frmCab').habilitaCampo();
		$('#flgocorr','#frmCab').habilitaCampo();
		$('#flgmotiv','#frmCab').habilitaCampo();
		trocaBotao( 'Incluir');
	}

	if ( $('#cddopcao','#frmCab').val() == 'I' ){
		buscaSequencial();
		$('#dsinctar','#frmCab').habilitaCampo();		
		return false;
	}
	
	$('#cdinctar','#frmCab').focus();

	return false;

}

function btnContinuar() {

	$('input,select', '#frmCab').removeClass('campoErro');

	cdinctar = normalizaNumero( ccdinctar.val() );
	dsinctar = $('#dsinctar','#frmCab').val();
	cddopcao = cCddopcao.val();
	
	// Busca dados da Incidencia para Alteração e Exclusão.
	if ( cdinctar != '' ) {
		if ( ( cddopcao == 'A' ) || ( cddopcao == 'E' && dsinctar == '') ) {
			if ( $('#dsinctar','#frmCab').hasClass('campoTelaSemBorda')  ) {
				buscaDados();
				return false;
			}
		}
	}
	
	if ( cdinctar == '' ){ 
		hideMsgAguardo();
		showError("error","C&oacute;digo da Incid&ecirc;ncia deve ser informado.","Alerta - Ayllos","focaCampoErro(\'cdinctar\', \'frmCab\');",false);
		return false; }
		
	if ( ( cddopcao == 'A' && dsinctar == '' ) || ( cddopcao == 'I' && dsinctar == '' ) ){ 
		hideMsgAguardo();
		showError("error","Descri&ccedil;&atilde;o da Incid&ecirc;ncia deve ser informado.","Alerta - Ayllos","focaCampoErro(\'dsinctar\', \'frmCab\');",false);
		return false; }

	// Se chegou até aqui, o tipo de incidencia é diferente do vazio e é válida, então realizar a operação desejada
	realizaOperacao();
	
	return false;
		
}

function realizaOperacao() {

	// Mostra mensagem de aguardo
	
	if (cddopcao == "C"){  	   showMsgAguardo("Aguarde, consultando tipo de incidencia..."); } 
	else if (cddopcao == "I"){ showMsgAguardo("Aguarde, incluindo tipo de incidencia...");  }
	else if (cddopcao == "A"){ showMsgAguardo("Aguarde, alterando tipo de incidencia...");  }	
	else if (cddopcao == "E"){ showMsgAguardo("Aguarde, excluindo tipo de incidencia...");  }	
	else { showMsgAguardo("Aguarde, liberando aplicacao..."); }
	
	var cdinctar = $('#cdinctar','#frmCab').val();
	cdinctar = normalizaNumero(cdinctar);
	var flgocorr = $('#flgocorr','#frmCab').val();
	var flgmotiv = $('#flgmotiv','#frmCab').val();
		
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadint/manter_rotina.php", 
		data: {
			cdinctar: cdinctar,
			cddopcao: cddopcao,
			dsinctar: dsinctar,
			flgocorr: flgocorr,
			flgmotiv: flgmotiv,
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
	if ($("#cdinctar","#frmCab").prop("disabled") == true)  {
		return;
	}
	
	if ( $('#cddopcao','#frmCab').val() == "I"){
		return false;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdinctar, titulo_coluna, cdgrupos, dsinctar;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmCab';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdinctar = $('#cdinctar','#'+nomeFormulario).val();
	cdgrupos = cdinctar;
	cdinctar = normalizaNumero($(cdinctar).val());
	dsinctar = '';
	
	titulo_coluna = "Tipos de incidencia";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-int';
	titulo      = 'Tipos incidencia';
	qtReg		= '20';
	filtros 	= 'Codigo;cdinctar;130px;S;' + cdinctar + ';S|Descricao;dsinctar;100px;S;' + dsinctar + ';N';
	colunas 	= 'Codigo;cdinctar;20%;right|' + titulo_coluna + ';dsinctar;50%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cdinctar\',\'#frmCab\').val()');
	
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
	showMsgAguardo("Aguarde, consultando incidencia...");
	
	var cdinctar = $('#cdinctar','#frmCab').val();
	cdinctar = normalizaNumero(cdinctar);
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadint/busca_dados.php", 
		data: {
			cdinctar: cdinctar,
			cddopcao: cddopcao,
			dsinctar: dsinctar,
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
		url: UrlSite + "telas/cadint/busca_sequencial.php", 
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
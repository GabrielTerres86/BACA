/*!
 * FONTE        : cadcur.js
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 19/06/2017
 * OBJETIVO     : Biblioteca de funções da tela CADCUR
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */

// Definição de algumas variáveis globais 
var cddopcao		= 'C';
	
//Formulários
var frmCab   		= 'frmCab';
var frmCadcur 		= 'frmCadcur';

//Labels/Campos do cabeçalho
var rCddopcao, rCdfrmttl_cab, rCdfrmttl, rDsfrmttl, cCddopcao, cCdfrmttl_cab, cCdfrmttl, cRsfrmttl_cab, cRsfrmttl, cDsfrmttl, cTodosCabecalho, cTodosFormulario, btnCab;

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
	$('#'+frmCadcur).css({'display':'none'});		
	
	trocaBotao('');
		
	formataCabecalho();
	
	cTodosCabecalho.limpaFormulario();
	$('input[type="text"]','#'+frmCadcur).limpaFormulario();
	cCddopcao.val( cddopcao );
	
	removeOpacidade('divTela');	
	unblockBackground();
	hideMsgAguardo();
	
	$('#cdfrmttl','#frmCab').desabilitaCampo();
	$('#rsfrmttl','#frmCab').desabilitaCampo();
	
	$("#btVoltar","#divBotoes").hide();
	
	$('input,select', '#frmCab').removeClass('campoErro');
	$('#cdfrmttl','#frmCab').change();
	
	controlaFoco();
		
}

function controlaFoco() {

	$('#cddopcao','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cddopcao = $(this).val();
			LiberaCampos();
			return false;
		}	
	});
	
	$('#btnOK','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cddopcao = $('#cddopcao','#frmCab').val();
			LiberaCampos();
			$('#cdfrmttl','#frmCab').focus();				
			return false;
		}	
	});
	
	$('#cdfrmttl','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9 ) {	
			if ( $('#cdfrmttl','#frmCab').val() == '' ) {
				controlaPesquisa();
			} else {		
				$('#cdfrmttl','#frmCab').change();
				$('#btProsseguir','#divBotoes').focus();
			}		
		}	
	});
	
	$('#cdfrmttl','#frmCab').unbind('change').bind('change', function(e) {
		pesquisaCurso($(this).val());
	});
	
	$('#rsfrmttl','#frmCadcur').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9 ) {	
			$('#dsfrmttl','#frmCadcur').focus();
		}	
	});
	
	$('#dsfrmttl','#frmCadcur').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9 ) {	
			btnContinuar();
		}	
	});
		
}

function formataCabecalho() {

	// cabecalho
	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab); 
	rCdfrmttl_cab		= $('label[for="cdfrmttl"]','#'+frmCab); 
	
	cCddopcao			= $('#cddopcao','#'+frmCab); 
	cCdfrmttl_cab		= $('#cdfrmttl','#'+frmCab); 
	cRsfrmttl_cab		= $('#rsfrmttl','#'+frmCab); 
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	btnCab				= $('#btOK','#'+frmCab);
	
	rCddopcao.css('width','44px');
	rCdfrmttl_cab.addClass('rotulo-linha').css({'width':'41px'});
	
	cCddopcao.css({'width':'460px'});
	cCdfrmttl_cab.css({'width':'50px'}).attr('maxlength','9').setMask('INTEGER','zzzzzzzzz','','');
	cRsfrmttl_cab.css({'width':'420px'}).attr('maxlength','50').setMask("STRING",50,charPermitido(),"");
	
	if ( $.browser.msie ) {
		rCdfrmttl_cab.css({'width':'44px'});
		cRsfrmttl_cab.css({'width':'376px'});
		cCddopcao.css({'width':'456px'});
	}	
	
	cTodosCabecalho.habilitaCampo();
	
	$('#cddopcao','#'+frmCab).focus();
				
	layoutPadrao();
	return false;	
}

function formataLayout() {
	
	$('#'+frmCadcur).css({'display':'block'});		
	// cabecalho
	rCdfrmttl			= $('label[for="cdfrmttl"]','#'+frmCadcur); 
	rDsfrmttl			= $('label[for="dsfrmttl"]','#'+frmCadcur); 
	
	cCdfrmttl = $('#cdfrmttl','#'+frmCadcur); 
	cDsfrmttl = $('#dsfrmttl','#'+frmCadcur); 
	cRsfrmttl = $('#rsfrmttl','#'+frmCadcur); 
	cTodosFormulario = $('input[type="text"]','#'+frmCadcur);
	
	rCdfrmttl.addClass('rotulo-linha').css({'width':'80px'});
	rDsfrmttl.addClass('rotulo-linha').css({'width':'80px'});
	
	cCdfrmttl.css({'width':'50px'}).attr('maxlength','9').setMask('INTEGER','zzzzzzzzz','','');
	cRsfrmttl.css({'width':'403px'}).attr('maxlength','19').setMask("STRING",19,charPermitido(),"");
	cDsfrmttl.css({'width':'456px'}).attr('maxlength','40').setMask("STRING",40,charPermitido(),"");
	
	if (cddopcao == 'C' || cddopcao == 'E'){
		cTodosFormulario.desabilitaCampo();
	}else{
		cTodosFormulario.habilitaCampo();
		cCdfrmttl.desabilitaCampo();
		cRsfrmttl.focus();
	}
	
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
	
	$('#cdfrmttl','#frmCab').habilitaCampo();
	
	$('#divBotoes', '#divTela').css({'display':'block'});
	
	$("#btSalvar","#divBotoes").show();
	$("#btVoltar","#divBotoes").show();
	
	trocaBotao('Prosseguir');

	if ( $('#cddopcao','#frmCab').val() == 'I' ){
		cTodosCabecalho.desabilitaCampo();
		formataLayout();
		trocaBotao( 'Incluir');
		return false;
	}
	
	$('#cdfrmttl','#frmCab').focus();

	return false;

}

function btnContinuar() {

	$('input,select', '#frmCab').removeClass('campoErro');

	cdfrmttl = normalizaNumero( cCdfrmttl_cab.val() );
	rsfrmttl = $('#rsfrmttl','#frmCab').val();
	cddopcao = cCddopcao.val();	
	
	if (!$('#cdfrmttl','#frmCab').hasClass('campoTelaSemBorda')) {
		$('input,select', '#frmCab').removeClass('campoErro');
		if ( cdfrmttl == '' ){ 
			hideMsgAguardo();
			showError("error","C&oacute;digo do curso deve ser informado.","Alerta - Ayllos","focaCampoErro(\'cdfrmttl\', \'frmCab\');",false);
			return false; 
		}
		cddopcao = cCddopcao.val();		
		buscaDados();		
		return false;
	}

	// Se chegou até aqui, o curso é diferente do vazio e é válida, então realizar a operação desejada
	realizaOperacao();
	
	return false;
		
}

function realizaOperacao() {

	// Mostra mensagem de aguardo
	
	if (cddopcao == "I"){ showMsgAguardo("Aguarde, incluindo curso...");  }
	else if (cddopcao == "A"){ showMsgAguardo("Aguarde, alterando curso...");  }	
	else if (cddopcao == "E"){ showMsgAguardo("Aguarde, excluindo curso...");  }
	else { showMsgAguardo("Aguarde, liberando aplicacao..."); }
	
	var cdfrmttl = $('#cdfrmttl','#frmCadcur').val();
	var rsfrmttl = $('#rsfrmttl','#frmCadcur').val();
	var dsfrmttl = $('#dsfrmttl','#frmCadcur').val();
	cdfrmttl = normalizaNumero(cdfrmttl);
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadcur/manter_rotina.php", 
		data: {
			cdfrmttl: cdfrmttl,
			rsfrmttl: rsfrmttl,
			dsfrmttl: dsfrmttl,
			cddopcao: cddopcao,
			rsfrmttl: rsfrmttl,
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
	if ($("#cdfrmttl","#frmCab").prop("disabled") == true)  {
		return;
	}
	
	if ( $('#cddopcao','#frmCab').val() == "I"){
		return false;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var packageOra, procedure, titulo, qtReg, filtros, colunas, cdfrmttl, titulo_coluna;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmCab';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdfrmttl = $('#cdfrmttl','#'+nomeFormulario).val();
	cdfrmttl = normalizaNumero($(cdfrmttl).val());
	
	packageOra	= 'TELA_CADCUR'; 
	procedure   = 'PESQUISA_CURSOS';
	titulo 		= 'curso';
	qtReg 		= '20';
	filtros 	= 'Codigo;cdfrmttl;100px;S;' + cdfrmttl + ';S|Descricao;rsfrmttl;150px;S;;S';
	colunas 	= 'Código;cdfrmttl;20%;right|Descrição;rsfrmttl;50%;left';
	mostraPesquisa(packageOra,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cdfrmttl\',\'#frmCab\').val()');	
	
	return false;
}

function pesquisaCurso(cdfrmttl){
	
	if ( $('#cddopcao','#frmCab').val() == "I"){
		return false;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var packageOra, procedure, titulo, qtReg, filtros, colunas, cdfrmttl, titulo_coluna;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmCab';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	cdfrmttl = normalizaNumero(cdfrmttl);
	
	packageOra	= 'TELA_CADCUR'; 
	procedure   = 'PESQUISA_CURSOS';
	titulo 		= 'curso';
	buscaDescricao(packageOra, procedure, titulo, 'cdfrmttl', 'rsfrmttl', cdfrmttl, 'rsfrmttl', '', nomeFormulario);	
	return false;
	
}

function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>');

	if ( botao != '') {
		$('#divBotoes','#divTela').append('&nbsp;<a href="#" id="bt'+ botao + '" class="botao" onClick="btnContinuar(); return false;" >'+botao+'</a>');
	}
	return false;
}

function buscaDados() {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, consultando curso...");
	
	var cdfrmttl = $('#cdfrmttl','#frmCab').val();
	cdfrmttl = normalizaNumero(cdfrmttl);
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadcur/busca_dados.php", 
		data: {
			cdfrmttl: cdfrmttl,
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

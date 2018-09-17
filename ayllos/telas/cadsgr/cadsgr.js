/*!
 * FONTE        : cadgru.js
 * CRIAÇÃO      : Daniel Zimmermann          
 * DATA CRIAÇÃO : 26/02/2013
 * OBJETIVO     : Biblioteca de funções da tela CADSGR
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */

// Definição de algumas variáveis globais 
var cddopcao		= 'C';
	
//Formulários
var frmCab   		= 'frmCab';

//Labels/Campos do cabeçalho
var rCddopcao, rcdsubgru, rCdsubgru, cCddopcao, ccdsubgru, cdssubgru, cDssubgru, cCddgrupo, cTodosCabecalho ;

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
	
	$('#cdsubgru','#frmCab').desabilitaCampo();
	$('#dsdgrupo','#frmCab').desabilitaCampo();
	$('#dssubgru','#frmCab').desabilitaCampo();
	$('#cddgrupo','#frmCab').desabilitaCampo(); 
	
	trocaBotao('');
	$("#btVoltar","#divBotoes").hide();
	
	$('input,select', '#frmCab').removeClass('campoErro');
	
	controlaFoco();
		
}

function controlaFoco() {

	$('#cddopcao','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				LiberaCampos();
				$('#cddgrupo','#frmCab').focus();
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
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				btnContinuar();					
				return false;
			}	
	});	
	
	$('#cdsubgru','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				if ( $('#cdsubgru','#frmCab').val() == '' ) {
					controlaPesquisa();
				} else {
					if ( ( $('#cddopcao','#frmCab').val() == 'I') ){
						$('#dssubgru','#frmCab').habilitaCampo();
						$('#dssubgru','#frmCab').focus();								
					}else{
						btnContinuar();
					}	
					return false;
				} 
			}			
	});
	
	$('#dssubgru','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			if ($('#dssubgru','#frmCab').val() != ''){
				btnContinuar();
				return false;
			}
		}			
	});
	
}

function formataCabecalho() {

	// cabecalho
	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab); 
	rCdsubgru			= $('label[for="cdsubgru"]','#'+frmCab);
	rCddgrupo			= $('label[for="cddgrupo"]','#'+frmCab); 	
	
	cCddopcao			= $('#cddopcao','#'+frmCab); 
	cDssubgru			= $('#dssubgru','#'+frmCab);
	cCdsubgru			= $('#cdsubgru','#'+frmCab); 
	cCddgrupo           = $('#cddgrupo','#'+frmCab); 
	cDsdgrupo			= $('#dsdgrupo','#'+frmCab); 
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	
	rCddopcao.css('width','44px');
	rCdsubgru.addClass('rotulo-linha').css({'width':'41px'});
	rCddgrupo.css('width','45px');
	
	cCddopcao.css({'width':'460px'});	
	cDsdgrupo.css({'width':'390px'}).attr('maxlength','50');	
	cDssubgru.css({'width':'390px'}).attr('maxlength','50').setMask("STRING",50,charPermitido(),"");
	cCdsubgru.css({'width':'80px'}).attr('maxlength','9').setMask('INTEGER','zzzzzzzzz','','');
	cCddgrupo.css({'width':'80px'}).attr('maxlength','9').setMask('INTEGER','zzzzzzzzz','','');;
	
	
	if ( $.browser.msie ) {
		cCddopcao.css({'width':'456px'});
		cDssubgru.css({'width':'385px'})
		cDsdgrupo.css({'width':'385px'})
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
	
	$('#cdsubgru','#frmCab').habilitaCampo();
	$('#cddgrupo','#frmCab').habilitaCampo();
	$('#dssubgru','#frmCab').desabilitaCampo();
	
	$('#divBotoes', '#divTela').css({'display':'block'});
	
	$("#btSalvar","#divBotoes").show();
	$("#btVoltar","#divBotoes").show();
	
	trocaBotao( 'Prosseguir' );

	if ( $('#cddopcao','#frmCab').val() == 'I' ){
		buscaSequencial();
		$('#dssubgru','#frmCab').habilitaCampo();
		trocaBotao( 'Incluir');
		return false;	
	}
	
	$('#cddgrupo','#frmCab').focus();

	return false;

}

function btnContinuar() {

	$('input,select', '#frmCab').removeClass('campoErro');

	cdsubgru = normalizaNumero( cCdsubgru.val() );
	cddgrupo = normalizaNumero( cCddgrupo.val() );
	dssubgru = $('#dssubgru','#frmCab').val();
	dsdgrupo = $('#dsdgrupo','#frmCab').val();	
	cddopcao = cCddopcao.val();	
	
	if (( cddgrupo != '' ) && ( ! $('#cddgrupo','#frmCab').hasClass('campoTelaSemBorda') )) {
			buscaDados(1);
			return false;
		} else {
			$('#cdsubgru','#frmCab').focus();		
		}
		
	if ( cddopcao != 'I' ) {
		
		if (( cdsubgru != '' ) && ( ! $('#cdsubgru','#frmCab').hasClass('campoTelaSemBorda') )) {		    
			buscaDados(2);
			return false;
		}		
	}
	
	if ( ( cddopcao == 'I') && ( cddgrupo == '' ) ) {
			hideMsgAguardo();
			showError("error","C&oacute;digo do Grupo deve ser informado.","Alerta - Ayllos","focaCampoErro(\'cddgrupo\', \'frmCab\');",false);
			return false; 
	}	
		
	if ( $('#cddgrupo','#frmCab').hasClass('campoTelaSemBorda')  ) {
		if ( cdsubgru == '' ){ 
			hideMsgAguardo();
			showError("error","C&oacute;digo do Sub-Grupo deve ser informado.","Alerta - Ayllos","focaCampoErro(\'cdsubgru\', \'frmCab\');",false);
			return false; }
			
		if ( ( cddopcao == 'A' && dssubgru == '' ) || ( cddopcao == 'I' && dssubgru == '' ) ){ 
			hideMsgAguardo();
			showError("error","Descri&ccedil;&atilde;o do Sub-Grupo deve ser informado.","Alerta - Ayllos","focaCampoErro(\'dssubgru\', \'frmCab\');",false);
			return false; }	
		
		// Se chegou até aqui, o Sub-Grupo é diferente do vazio e é válida, então realizar a operação desejada
		realizaOperacao();
	}
		
	return false;
		
}

function realizaOperacao() {

	// Mostra mensagem de aguardo
	
	if (cddopcao == "C"){  	   showMsgAguardo("Aguarde, consultando Sub-grupo..."); } 
	else if (cddopcao == "I"){ showMsgAguardo("Aguarde, incluindo Sub-grupo...");  }
	else if (cddopcao == "A"){ showMsgAguardo("Aguarde, alterando Sub-grupo...");  }	
	else if (cddopcao == "E"){ showMsgAguardo("Aguarde, excluindo Sub-grupo...");  }	
	else { showMsgAguardo("Aguarde, liberando aplicacao..."); }
	
	var cdsubgru = $('#cdsubgru','#frmCab').val();
	cdsubgru = normalizaNumero(cdsubgru);
	
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadsgr/manter_rotina.php", 
		data: {
			cddgrupo: cddgrupo,
			cdsubgru: cdsubgru,
			cddopcao: cddopcao,
			dssubgru: dssubgru,
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

	$("#divCabecalhoPesquisa").css("width","100%");
	$("#divResultadoPesquisa").css("width","100%");

	switch( valor )
	{
		case 1:
		  controlaPesquisaGrupo();
		  break;
		case 2:
		  controlaPesquisaSubGrupo();
		  break;
	}

}

function controlaPesquisaSubGrupo(){

	// Se esta desabilitado o campo 
	if ($("#cdsubgru","#frmCab").prop("disabled") == true)  {
		return;
	}
	
	// Desabilita a consulta no caso de opcao de inclusao.
	if ( $('#cddopcao','#frmCab').val() == "I"){
		return false;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdsubgru, titulo_coluna;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmCab';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdsubgru = $('#cdsubgru','#'+nomeFormulario).val();
	var cddgrupo  = $('#cddgrupo','#'+nomeFormulario).val();
	dssubgru = '';
	
	titulo_coluna = "Sub-grupos de produto";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-subgrupos';
	titulo      = 'Sub-grupos';
	qtReg		= '20';
	filtros 	= 'Grupo;cddgrupo;100px;N;' + cddgrupo + ';S|Codigo;cdsubgru;100px;S;' + cdsubgru + ';S|Descricao;dssubgru;300px;S;' + dssubgru + ';S';
	colunas 	= 'Grupo;cddgrupo;15%;right|Codigo;cdsubgru;15%;right|' + titulo_coluna + ';dssubgru;65%;left';
	
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cdsubgru\',\'#frmCab\').val()');
	
	$("#divCabecalhoPesquisa > table").css("width","560px");
	$("#divResultadoPesquisa > table").css("width","100%");
	$("#divCabecalhoPesquisa > table").css("float","left");
	$("#divCabecalhoPesquisa").css("width","580px");
	$("#divResultadoPesquisa").css("width","100%");
	
	
	return false;
}

function controlaPesquisaGrupo(){

	// Se esta desabilitado o campo 
	if ($("#cddgrupo","#frmCab").prop("disabled") == true)  {
		return;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdsubgru, titulo_coluna;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmCab';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');	
	
	var cddgrupo  = $('#cddgrupo','#'+nomeFormulario).val();
	dsdgrupo = '';
	
	titulo_coluna = "Grupo de produtos";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-grupos';
	titulo      = 'Grupos';
	qtReg		= '10';
	filtros 	= 'Grupo;cddgrupo;100px;S;' + cddgrupo + ';S|Descricao;dsdgrupo;150px;S;' + dsdgrupo + ';S';
	colunas 	= 'Grupo;cddgrupo;20%;right|' + titulo_coluna + ';dsdgrupo;50%;left';
	
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

function buscaDados( valor ) {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, consultando...");

	switch( valor )
	{
		case 1:
		  buscaDadosGrupo();		  		  
		  break;
		case 2:		  
		  buscaDadosSubGrupo();
		  break;
	}

}

function buscaDadosGrupo(){

	var cddgrupo = $('#cddgrupo','#frmCab').val();
	cddgrupo = normalizaNumero(cddgrupo);

	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadsgr/busca_dados_grupo.php", 
		data: {
			cddgrupo: cddgrupo,
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

function buscaDadosSubGrupo(){

	var cdsubgru = $('#cdsubgru','#frmCab').val();		
	cdsubgru = normalizaNumero(cdsubgru);		
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadsgr/busca_dados_subgrupo.php", 
		data: {
			cdsubgru: cdsubgru,
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
		url: UrlSite + "telas/cadsgr/busca_sequencial.php", 
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
/*!
 * FONTE        : cadpar.js
 * CRIAÇÃO      : Daniel Zimmermann          
 * DATA CRIAÇÃO : 06/03/2013
 * OBJETIVO     : Biblioteca de funções da tela CADPAR
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 * 26/06/2014 - Correcao da rotina de replicacao
 *  			de parametros a partir da inclusao - 151018
 *				Carlos Rafael Tanholi
 * 
 * 24/03/2015 - Melhoria, adicionado campo Produto.
 * 				(Jorge/Rodrigo - SD 229250)
 */

// Definição de algumas variáveis globais 
var cddopcao		= 'C';
	
//Formulários
var frmCab   		= 'frmCab';
var tabDados		= 'tabCadpar';
var frmDados  		= 'frmCadpar';


//Labels/Campos do cabeçalho
var rCddopcao, cCddopcao, cCdpartar, cNmpartar, cTpdado, cTodosCabecalho, arrCooperativa, glbTabCdcooper, glbTabDsconteu, glbTabNmrescop,
    cCdprodut,arrReplica;

$(document).ready(function() {

	estadoInicial();
	
	highlightObjFocus( $('#'+frmCab) );
	
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	
	return false;
	
});

// Estado Inicial
function estadoInicial() {

	glbTabCdcooper = '';

	//instancia do array de objetos
	arrCooperativa = new Array();

	$('#divTela').fadeTo(0,0.1);
	$('#frmCab').css({'display':'block'});
		
	formataCabecalho();
	
	cTodosCabecalho.limpaFormulario();
	cCddopcao.val( cddopcao );
	
	removeOpacidade('divTela');	
	unblockBackground();
	hideMsgAguardo();
	
	cTodosCabecalho.desabilitaCampo();
	$('#cddopcao','#frmCab').habilitaCampo().focus();
	
	$('#tpdedado','#frmCab').val('1');
	
	$('#divBotoes').css({'display':'none'});
	$('#tabCadpar').css({'display':'none'});
	
	$('input,select', '#frmCab').removeClass('campoErro');
	
	$('#divReplicar').html('');
	$('#tabCadpar').html('');
	$('#divConteudoOpcao').html('')
	
	controlaFoco();
		
}

function controlaFoco() {

	$('#cddopcao','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				LiberaCampos();				
				if ($('#cddopcao','#frmCab').val() == 'I') {				
					$('#nmpartar','#frmCab').focus();
					return false; }
				else{
					$('#cdpartar','#frmCab').focus();
					return false; }
			}	
	});
	
	$('#btnOK','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {				
					LiberaCampos();					
				if ($('#cddopcao','#frmCab').val() == 'I') {
					$('#nmpartar','#frmCab').focus();
					return false; }
				else{
					$('#cdpartar','#frmCab').focus();
					return false; }
			}	
	});
	
	$('#cdpartar','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				if ( $('#cdpartar','#frmCab').val() == '' ) {
					controlaPesquisa(1);					
				} else {
					btnContinuar();
					$('#nmpartar','#frmCab').focus();
					return false;
				}
			}	
	});	
	
	$('#nmpartar','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				if ( $('#nmpartar','#frmCab').val() != '' ) {
						if ($('#cddopcao','#frmCab').val() != 'A') {
							$('#tpdedado','#frmCab').focus();
						} else {
							btnContinuar();
						}
						return false;
				} else {
					btnContinuar();
					return false;
				}
			}	
	});
	
	$('#tpdedado','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			if ($('#tpdedado','#frmCab').val() != ''){
				btnContinuar();
				return false;
			}
		}			
	});
	
}

function formataCabecalho() {

	// Rotulo
	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab);
	rCdpartar			= $('label[for="cdpartar"]','#'+frmCab); 
	rNmpartar			= $('label[for="nmpartar"]','#'+frmCab);
	rTpdedado			= $('label[for="tpdedado"]','#'+frmCab);
	rDsprodut			= $('label[for="dsprodut"]','#'+frmCab); 	
	
	// Campo
	cCddopcao			= $('#cddopcao','#'+frmCab); 
	cCdpartar			= $('#cdpartar','#'+frmCab);
	cNmpartar			= $('#nmpartar','#'+frmCab); 
	cTpdedado           = $('#tpdedado','#'+frmCab); 
	cCdprodut           = $('#cdprodut','#'+frmCab); 
	cTodosCabecalho		= $('input[type="text"],input[type="hidden"],select','#'+frmCab);
	cDsprodut			= $('#dsprodut','#'+frmCab); 
	
	rCddopcao.addClass('rotulo').css({'width':'120px'});
	rCdpartar.addClass('rotulo').css({'width':'120px'});
	rNmpartar.addClass('rotulo').css({'width':'120px'});
	rTpdedado.addClass('rotulo').css({'width':'120px'});
	rDsprodut.addClass('rotulo').css({'width':'120px'});
	
	cCddopcao.css({'width':'470px'});	
	cCdpartar.css({'width':'90px'}).attr('maxlength','50').setMask('INTEGER','zzzzzzzzz','','');
	cNmpartar.css({'width':'505px'}).attr('maxlength','255').setMask("STRING",255,charPermitido(),"");
	cTpdedado.css({'width':'150px'}).attr('maxlength','9');
	cDsprodut.css({'width':'200px'}).attr('maxlength','200');
	
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
	
	$('#cdpartar','#frmCab').habilitaCampo();
	$('#nmpartar','#frmCab').habilitaCampo();
	$('#tpdedado','#frmCab').habilitaCampo();
	
	$('#divBotoes', '#divTela').css({'display':'block'});
	
	trocaBotao( 'Prosseguir' );

	if ( $('#cddopcao','#frmCab').val() == 'I' ){
		buscaSequencial();
		$('#nmpartar','#frmCab').habilitaCampo();
		$('#nmpartar','#frmCab').focus();
		trocaBotao( 'Incluir');
		return false;	
	}
	
	if ( $('#cddopcao','#frmCab').val() != 'I' ){
		$('#nmpartar','#frmCab').desabilitaCampo();
		$('#tpdedado','#frmCab').desabilitaCampo();
	}
	
	$('#cdpartar','#frmCab').focus();

	return false;

}

function btnContinuar() {

	$('input,select', '#frmCab').removeClass('campoErro');
	
	cddopcao = cCddopcao.val();	
	cdpartar = normalizaNumero( cCdpartar.val() );
	nmpartar = cNmpartar.val();
	dsprodut = cDsprodut.val();
	cdprodut = cCdprodut.val();
	
	if (( cdpartar != '' ) && ( ! $('#cdpartar','#frmCab').hasClass('campoTelaSemBorda') )) {
			buscaDados(1);
			return false;
	} 
		
	if ( $('#cdpartar','#frmCab').hasClass('campoTelaSemBorda')  ) {
		if ( cdpartar == '' ){ 
			hideMsgAguardo();
			showError("error","C&oacute;digo do Par&acirc;metro deve ser informado.","Alerta - Ayllos","focaCampoErro(\'cdpartar\', \'frmCab\');",false);
			return false; }
			
		if ( ( cddopcao == 'A' && nmpartar == '' ) || ( cddopcao == 'I' && nmpartar == '' ) ){ 
			hideMsgAguardo();
			showError("error","Descri&ccedil;&atilde;o do Par&acirc;metro deve ser informado.","Alerta - Ayllos","focaCampoErro(\'nmpartar\', \'frmCab\');",false);
			return false; }	
			
		// Se chegou até aqui, então realizar a operação desejada
		realizaOperacao();
	}
		
	return false;
}

function realizaOperacao() {

	// Mostra mensagem de aguardo
	if (cddopcao == "C"){  	   showMsgAguardo("Aguarde, consultando Par&acirc;metro..."); } 
	else if (cddopcao == "I"){ showMsgAguardo("Aguarde, incluindo Par&acirc;metro...");  }
	else if (cddopcao == "A"){ showMsgAguardo("Aguarde, alterando Par&acirc;metro...");  }	
	else if (cddopcao == "E"){ showMsgAguardo("Aguarde, excluindo Par&acirc;metro...");  }	
	else { showMsgAguardo("Aguarde, liberando aplicacao..."); }
	
	var cdpartar = cCdpartar.val();
	var tpdedado = cTpdedado.val();
	var nmpartar = cNmpartar.val();
	var cdprodut = cCdprodut.val();
	
	cdpartar = normalizaNumero(cdpartar);
	tpdedado = normalizaNumero(tpdedado);
	cdprodut = normalizaNumero(cdprodut);
	
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadpar/manter_rotina.php", 
		data: {
			cdpartar: cdpartar,
			cddopcao: cddopcao,
			tpdedado: tpdedado,
			nmpartar: nmpartar,
			cdprodut: cdprodut,
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
				if(cddopcao != 'E'){
					reloadTabela();
				}	
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
			controlaPesquisaParametro();
			break;
		case 2:
			controlaPesquisaCoop();
		case 3:
			controlaPesquisaProduto();
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
		  buscaDadosParametro();		  		  
		  break;
	}

}

function buscaSequencial(){

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, buscando novo c&oacute;digo...");
	var cddopcao = cCddopcao.val();
	
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadpar/busca_sequencial.php", 
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
				$('#divBotoesTabCadpar').show();
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});				
}


function buscaDadosParametro() {

var cdpartar = normalizaNumero(cCdpartar.val());

	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadpar/busca_dados_parametro.php", 
		data: {
			cdpartar: cdpartar,
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

function buscaCooperativa(){

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, buscando cooperativa...");

	var cdcooper = $('#cdcopaux','#frmParametroCoop').val();
	cdcooper = normalizaNumero(cdcooper);

	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadpar/busca_dados_cooperativa.php", 
		data: {
			cdcopatu: cdcooper,
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
				bloqueiaFundo($('#divRotina'));
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});	
	
	return false;

}


function controlaPesquisaParametro() {

	// Se esta desabilitado o campo 
	if ($("#cdpartar","#frmCab").prop("disabled") == true)  {
		return;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdpartar, titulo_coluna, cdpartars, nmpartar;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmCab';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdpartar = $('#cdpartar','#'+nomeFormulario).val();
	cdpartars = cdpartar;	
	nmpartar = '';
	
	titulo_coluna = "Parametros";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-parametros';
	titulo      = 'Parametros';
	qtReg		= '20';
	filtros 	= 'Codigo;cdpartar;130px;S;' + cdpartar + ';S|Descricao;nmpartar;300px;S;' + nmpartar + ';S';
	colunas 	= 'Codigo;cdpartar;15%;right|' + titulo_coluna + ';nmpartar;75%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cdpartar\',\'#frmCab\').val()');
	
	return false;
}

function controlaPesquisaCoop(){

	// Se esta desabilitado o campo 
	if ($("#cdcopaux","#frmParametroCoop").prop("disabled") == true)  {
		return;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdcooper, titulo_coluna, cdcoopers, cdcopaux, nmrescop;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmParametroCoop';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdcopaux = $('#cdcopaux','#'+nomeFormulario).val();
	cdcoopers = cdcopaux;	
	nmrescop = '';
	
	titulo_coluna = "Cooperativas";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-cooperativas';
	titulo      = 'Cooperativas';
	qtReg		= '20';
	filtros 	= 'Codigo;cdcopaux;130px;S;' + cdcopaux + ';S|Descricao;nmrescop;300px;S;' + nmrescop + ';S';
	colunas 	= 'Codigo;cdcooper;15%;right|' + titulo_coluna + ';nmrescop;75%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cdcopaux\',\'#frmParametroCoop\').val()');
	
	return false;
}

function controlaPesquisaParametro() {

	// Se esta desabilitado o campo 
	if ($("#cdpartar","#frmCab").prop("disabled") == true)  {
		return;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdpartar, titulo_coluna, cdpartars, nmpartar;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmCab';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdpartar = $('#cdpartar','#'+nomeFormulario).val();
	cdpartars = cdpartar;	
	nmpartar = '';
	
	titulo_coluna = "Parametros";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-parametros';
	titulo      = 'Parametros';
	qtReg		= '20';
	filtros 	= 'Codigo;cdpartar;130px;S;' + cdpartar + ';S|Descricao;nmpartar;300px;S;' + nmpartar + ';S';
	colunas 	= 'Codigo;cdpartar;15%;right|' + titulo_coluna + ';nmpartar;75%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cdpartar\',\'#frmCab\').val()');
	
	return false;
}

function controlaPesquisaProduto() {

	// Se esta desabilitado o campo 
	if ($("#nmpartar","#frmCab").prop("disabled") == true)  {
		return;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, titulo_coluna;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmCab';
	
	//var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var dsprodut = $('#dsprodut','#'+nomeFormulario).val();
	
	titulo_coluna = "Produtos";
	
	bo			= 'b1wgen0059.p'; 
	procedure	= 'busca-produtos';
	titulo      = 'Produtos';
	qtReg		= '20';
	filtros 	= 'Area;dsarnego;130px;S;;S|Codigo Produto;cdprodut;;N;;N|Produto;dsprodut;300px;S;;S';
	colunas 	= 'Area;dsarnego;50%;center;;S|Codigo Prod.;cdprodut;;;;N|' + titulo_coluna + ';dsprodut;50%;center';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#dsprodut\',\'#frmCab\').val()');
	
	return false;
}

function formataTabela() { 
	
	// Tabela
	var divRegistro = $('div.divRegistros', '#'+tabDados);		
	var tabela      = $('table', divRegistro );
	
	$('#'+tabDados).css({'margin-top':'5px'});
	divRegistro.css({'height':'150px','padding-bottom':'2px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '100px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'left';
	
	var chamada = cddopcao == 'C' ? 'mostraComplemento(\'consultar\');' : '';
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, chamada );

	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		glbTabCdcooper = $(this).find('#tabcdcooper > span').text() ;
		glbTabDsconteu = $(this).find('#tabdsconteu > span').text() ;
		glbTabNmrescop = $(this).find('#tabdsconteu > #tabnmrescop').val() ;
	});	
	
	if(glbTabCdcooper == ''){
		$('table > tbody > tr:eq(0)', divRegistro).click();
	}else{
		$('table > tbody > tr', divRegistro).each( function(index){
			if( $(this).find('#tabcdcooper > span').text() == glbTabCdcooper ){
				$(this).click();
				return false;
			}
		});
	}
	
	$('#'+tabDados).css({'display':'block'});
	return false;
}

function setaGlobalTab(parCdcooper, parDsconteu, parNmrescop){
	glbTabCdcooper = parCdcooper;
	glbTabDsconteu = parDsconteu;
	glbTabNmrescop = parNmrescop;
}

function mostraParametroCoop(opcao) {

	showMsgAguardo('Aguarde, buscando parametro por cooperativa...');
	
	// Executa script através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadpar/parametro_coop.php', 
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
			buscaParametroCoop(opcao);
		}				
	});
	return false;
	
}

function buscaParametroCoop(opcao) {

	showMsgAguardo('Aguarde, buscando parametro por cooperativa...');

	var cdpartar = normalizaNumero($('#cdpartar', '#'+frmCab).val());	
	var nmpartar = $('#nmpartar', '#'+frmCab).val();
	var tpdedado = $('#tpdedado', '#'+frmCab).val();
	
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadpar/busca_parametro_coop.php', 
		data: {
			cdpartar: cdpartar,
			nmpartar: nmpartar,
			tpdedado: tpdedado,
			opcao: opcao,
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
					formataParametroCoop(opcao);
					$('#tpdedado', '#frmParametroCoop').val(tpdedado);
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

function formataParametroCoop(opcao) {

	$('#divConteudoOpcao', '#telaParametro').css({'width':'600px'});

 	// Rotulos 
	var rNmpartar	= $('label[for="nmpartar"]','#frmParametroCoop');
	var rCdcooper	= $('label[for="cdcopaux"]','#frmParametroCoop');
	var rDsconteu	= $('label[for="dsconteu"]','#frmParametroCoop');
	var rTpdedado	= $('label[for="tpdedado"]','#frmParametroCoop'); 
	
	rNmpartar.addClass('rotulo').css('width','140px');
	rCdcooper.addClass('rotulo').css('width','140px');
	rDsconteu.addClass('rotulo').css('width','140px');
	rTpdedado.addClass('rotulo').css('width','140px');
	
	// Campos
	var cTodos	  	= $('input[type="text"],select','#frmParametroCoop');
	var cCdcooper   = $('#cdcopaux','#frmParametroCoop');
	var cNmpartar	= $('#nmpartar','#frmParametroCoop');	
	var cNmrescop	= $('#nmrescop','#frmParametroCoop');
	var cDsconteu	= $('#dsconteu','#frmParametroCoop');
	var cTpdedado	= $('#tpdedado','#frmParametroCoop');

	cTodos.habilitaCampo();
	cNmpartar.css('width','440px').desabilitaCampo();
	cTpdedado.css('width','440px').desabilitaCampo();
	cNmrescop.css('width','328px').desabilitaCampo();
	cDsconteu.css('width','440px').attr('maxlength','255');
	cDsconteu.css('textAlign','left');
	cCdcooper.css('width','90px').attr('maxlength','2').setMask('INTEGER','zzzzzzzzz','','');

	layoutPadrao();
	hideMsgAguardo();
	
	bloqueiaFundo( $('#divRotina') );
	highlightObjFocus( $('#frmParametroCoop') );
	
	$('#divRotina').centralizaRotinaH();
	
	reloadTabela(); //atualiza as linhas da tabela
	
	if ( opcao == 'A' ) {
		cCdcooper.desabilitaCampo();
		$("#btReplica","#divBotoesParaCoop").hide();
		cDsconteu.focus();
		return false;
	}
	
	if ( opcao == 'R' ) {
		cCdcooper.desabilitaCampo();
		cDsconteu.desabilitaCampo();
		replicaCooperativa();
		return false;
	}
	
	cCdcooper.focus();
	return false;
}

function controlaParametroCoop() {

	$('#cdcopaux','#frmParametroCoop').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				if ( $('#cdcopaux','#frmParametroCoop').val() == '' ) {
					controlaPesquisa(2);
					return false;
				} else {
					realizaOperacaoPco('V');
					return false;
				}
			}	
	});	
	
	$('#dsconteu','#frmParametroCoop').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				if ( $('#dsconteu','#frmParametroCoop').val() == '' ) {
					return false;
				} else {
					$('#cdcopaux','#frmParametroCoop').focus();
					return false;
				}
			}	
	});
	
	$('#cdcopaux','#frmParametroCoop').unbind('change').bind('change', function(e) {
		if ( $('#cdcopaux','#frmParametroCoop').val() == '' ) {
			controlaPesquisa(2);
			return false;
		} else {
			realizaOperacaoPco('V');
			return false;
		}	
	});

}


function replicaCooperativa() {

	if ( $('#cdcopaux','#frmParametroCoop').val() == '' ){ 
		showError('error','Cooperativa deve ser informada!','Alerta - Ayllos',"bloqueiaFundo( $('#divRotina') ); focaCampoErro(\'cdcopaux\', \'frmParametroCoop\');");
		return false; }
		
	if ( $('#dsconteu','#frmParametroCoop').val() == '' ){ 
		showError('error','Conteúdo deve ser informada!','Alerta - Ayllos',"bloqueiaFundo( $('#divRotina') ); focaCampoErro(\'dsconteu\', \'frmParametroCoop\');");
		return false; }

	showMsgAguardo('Aguarde, buscando parametro por cooperativa...');

	var cdpartar = normalizaNumero($('#cdpartar', '#frmCab').val());	
	var tpdedado = normalizaNumero($('#tpdedado', '#frmCab').val());	
	var dsconteu = $('#dsconteu', '#frmParametroCoop').val();
	var nmpartar = $('#nmpartar', '#frmParametroCoop').val();
	var cdcopatu = $('#cdcopaux', '#frmParametroCoop').val();
		
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadpar/replica_parametro_coop.php', 
		data: {
			cdcopatu: cdcopatu,
			cdpartar: cdpartar,
			dsconteu: dsconteu,
			nmpartar: nmpartar,
			tpdedado: tpdedado,
			redirect: 'script_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {
		
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					hideMsgAguardo();
					$('#divReplicar').html(response);
					exibeRotina($('#divRotina'));
					formatareplicaCooperativa();
					controlaClassConteudo();
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

function formatareplicaCooperativa() {

	$('#divConteudoOpcao', '#telaParametro').css({'width':'600px'});

 	// Rotulos 
	var rDsconteu	= $('label[for="dsconteu"]','#frmReplicaCoop');
	
	rDsconteu.addClass('rotulo-linha').css('width','110px');
	rDsconteu.addClass('rotulo-linha').css('text-align','left');
	rDsconteu.addClass('rotulo-linha').css('margin-left','5px');
	
	// Campos
	var cTodos	  	= $('input[type="text"],select','#frmReplicaCoop');
	var cCdcooper   = $('#cdcooper','#frmReplicaCoop');
	var cNmpartar	= $('#nmpartar','#frmReplicaCoop');	
	var cNmrescop	= $('#nmrescop','#frmReplicaCoop');
	var cDsconteu	= $('.dsconteu','#frmReplicaCoop');

	cTodos.habilitaCampo();
	cDsconteu.css('width','420px').attr('maxlength','60');

	layoutPadrao();
	hideMsgAguardo();
	
	bloqueiaFundo( $('#divReplicar') );
	bloqueiaFundo( $('#divRotina') );
	
	highlightObjFocus( $('#frmReplicaCoop') );
	controlaCheck();
	
	$("#btAlterar","#divBotoesParaCoop").hide();
	$("#btVoltar","#divBotoesParaCoop").hide();
	$("#btReplica","#divBotoesParaCoop").hide();
	
	return false;

}

function controlaCheck() {


	function marcaPrimeiro(){
		var flag = true;
		
		$('input[type="checkbox"],select','#frmReplicaCoop').each(
			function(index){
				if( $(this).prop('id') != 'flgcheckall' ){
					if($(this).prop("checked") == false){
						flag = false;
					}	
				}
			}
		);
		
		return flag;
	}

	$('input[type="checkbox"],select','#frmReplicaCoop').each(
		function(index){			
			if( $(this).prop('id') != 'flgcheckall' ){
				$(this).unbind('click').bind('click', function(e){ 
					if($(this).prop("checked") == false){
						$('#flgcheckall','#frmReplicaCoop').prop("checked",false);
					}else{
						$('#flgcheckall','#frmReplicaCoop').prop("checked",marcaPrimeiro());
					}
				})
			}
		}
	)

	
	$('#flgcheckall','#frmReplicaCoop').unbind('click').bind('click', function(e) {
		
		if( $(this).prop("checked") == true ){
			$(this).val("yes");	
			$('input[type="checkbox"],select','#frmReplicaCoop').prop("checked",true);
		}else{
			$(this).val("no");	
			$('input[type="checkbox"],select','#frmReplicaCoop').prop("checked",false);
		}		
			
	});

}

function controlaEstadoManterRorina() {
	$('#tabCadpar').show();
	removeOpacidade('divTela');	
	unblockBackground();
	reloadTabela();
	trocaBotao('');
	cTodosCabecalho.desabilitaCampo();
	
	return false;

}

function controlaEstadoManterRotinaPco() {

	$('#tabCadpar').show();
	removeOpacidade('divTela');	
	unblockBackground();
	reloadTabela();
	fechaRotina($('#divRotina'));
	trocaBotao('');
	
	hideMsgAguardo();
	cTodosCabecalho.desabilitaCampo();
	
	return false;

}

function controlaClassConteudo() {

	$('.cdsconteu','#frmReplicaCoop').css({'width':'420px'});

	switch( $('#tpdedado','#frmCab').val() )
	{
		case '1':
			$('#dsconteu"','#frmParametroCoop').addClass('').attr('maxlength','25').setMask('INTEGER','zzzzzzzzzzzzzzzzzzzzzzzz9','','');
			$('.cdsconteu','#frmReplicaCoop').addClass('inteiro').attr('maxlength','25').setMask('INTEGER','zzzzzzzzzzzzzzzzzzzzzzzz9','','');
		//	$('#dsconteu"','#frmParametroCoop').addClass('porcento_n').attr('maxlength','25'); Daniel
			
			$('#dsconteu"','#frmParametroCoop').unbind('keypress').bind('keypress', function(e) {
				$('#dsconteu"','#frmParametroCoop').val(retirarZeros($('#dsconteu"','#frmParametroCoop').val())) ;
			});	
			
			break;
		case '2':
			$('#dsconteu"','#frmParametroCoop').setMask("STRING",255,charPermitido(),"");
			$('.cdsconteu','#frmReplicaCoop').setMask("STRING",255,charPermitido(),"");
			break;
		case '3':
			$('#dsconteu"','#frmParametroCoop').addClass('moeda_15').attr('maxlength','25');
			$('.cdsconteu','#frmReplicaCoop').addClass('moeda_15').attr('maxlength','25');
			break;
		case '4':
			$('#dsconteu"','#frmParametroCoop').addClass('data');
			$('.cdsconteu','#frmReplicaCoop').addClass('data');
	}
	
}

function coope(checked, cdcooper, value){
	this.checked 	= checked;
	this.cdcooper 	= cdcooper;
	this.value 		= value;
}

function inserirCoope(checked, cdcooper, value){
	var cooperativa = new coope(checked, cdcooper, value);
	arrCooperativa.push(cooperativa);
	
	return false;
}

function fechaTela(){
	controlaEstadoManterRotinaPco();
	fechaRotina($('#divRotina'));
	return false;
}

function reloadTabela(){

	var cddopcao = cCddopcao.val();
	var cdpartar = normalizaNumero( cCdpartar.val() );
	var cdprodut = cCdprodut.val();
	
	// Carrega dados parametro através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/cadpar/tab_cadpar.php', 
		data    : 
				{ 
					cddopcao	: cddopcao,
					cdpartar	: cdpartar,
					cdprodut    : cdprodut,
					redirect	: 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) { 
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {						
							$('#tabCadpar').html(response);
							formataTabela();
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

	$('#btIncluir','#divBotoesTabCadpar').unbind('click').bind('click', function(e) {			
		mostraParametroCoop('I');	
	});

	$('#btAlterar','#divBotoesTabCadpar').unbind('click').bind('click', function(e) {
		if ( glbTabCdcooper == '' ) {
			hideMsgAguardo();
			showError('error','N&atilde;o tem registros.','Alerta - Ayllos','unblockBackground()');
		} else {
			mostraParametroCoop('A');
		}
	});
	
	$('#btExcluir','#divBotoesTabCadpar').unbind('click').bind('click', function(e) {
		if ( glbTabCdcooper == '' ) {
			hideMsgAguardo();
			showError('error','N&atilde;o tem registros.','Alerta - Ayllos','unblockBackground()');
		} else {
			showConfirmacao('Deseja realmente excluir o conteúdo do par&acirc;metro para a cooperativa selecionada?','Confirma&ccedil;&atilde;o - Ayllos','realizaOperacaoPco(\'E\');','return false;','sim.gif','nao.gif');
		}
	});
	
	$('#btReplica','#divBotoesTabCadpar').unbind('click').bind('click', function(e) {
		if ( glbTabCdcooper == '' ) {
			hideMsgAguardo();
			showError('error','N&atilde;o tem registros.','Alerta - Ayllos','unblockBackground()');
		} else {
			mostraParametroCoop('R');
		}
	});
	
	return false;
}

function realizaOperacaoPco(prOpcao) {

	if ( ( prOpcao == 'IR') || (prOpcao == "I") ) { 
		if ( $('#cdcopaux','#frmParametroCoop').val() == '' ){ 
			showError('error','Cooperativa deve ser informada!','Alerta - Ayllos',"bloqueiaFundo( $('#divRotina') ); focaCampoErro(\'cdcopaux\', \'frmParametroCoop\');");
			return false; }
		
		if ( $('#dsconteu','#frmParametroCoop').val() == '' ){ 
			showError('error','Conteúdo deve ser informada!','Alerta - Ayllos',"bloqueiaFundo( $('#divRotina') ); focaCampoErro(\'dsconteu\', \'frmParametroCoop\');");
			return false; }
	}
	// Mostra mensagem de aguardo
	if (prOpcao == "I"){      showMsgAguardo("Aguarde, incluindo Parametro...");  } 
	else if (prOpcao == "R"){ showMsgAguardo("Aguarde, replicando Parametro..."); }
	else if (prOpcao == "A"){ showMsgAguardo("Aguarde, alterando Parametro...");  }	
	else if (prOpcao == "E"){ showMsgAguardo("Aguarde, excluindo Parametro...");  }	
	else if (prOpcao == "V"){ showMsgAguardo("Aguarde, validando existencia de Parametro...");  }	
	else if (prOpcao == "IR"){ showMsgAguardo("Aguarde, incluindo Parametro..."); }
	else { showMsgAguardo("Aguarde, liberando aplicacao..."); }
	
	
	var cdpartar = $('#cdpartar','#frmCab').val();
	var cdcopatu = $('#cdcopaux','#frmParametroCoop').val();
	var dsconteu = $('#dsconteu','#frmParametroCoop').val();
	var lstcdcop = '';
	var lstdscon = '';
	
	cdpartar = normalizaNumero(cdpartar);
	cdcopatu = normalizaNumero(cdcopatu);
	
	if ( (prOpcao == 'A') || (prOpcao == 'E') ){
		cdcopatu = glbTabCdcooper;
	}
	
	if (prOpcao == 'R'){
		lstcdcop = getListaReplica('cdcooper');
		lstdscon = getListaReplica('dsconteu');		
	}
	
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadpar/manter_rotina_pco.php", 
		data: {
			cddopcao: prOpcao,
			cdpartar: cdpartar,
			cdcopatu: cdcopatu,			
			dsconteu: dsconteu,			
			lstcdcop: lstcdcop,
			lstdscon: lstdscon,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
 			hideMsgAguardo();
			try {
				eval(response);
			} catch(error) {
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			} 
			
		}
	});	
}

function getListaReplica(campo){

	var numocorr = $('#numocorr','#frmReplicaCoop').val();
	var lista    = '';
				
	for (var i=1;i<=numocorr;i++){ 
		
		if( $('#flgcheck'+i,'#frmReplicaCoop').prop('checked') == true ){
		
			lista = lista + $('#'+campo+i,'#frmReplicaCoop').val() + ';';		
			
		}	
	}			

	$.trim(lista);
	lista = lista.substr(0,lista.length - 1);
	
	return lista;
}

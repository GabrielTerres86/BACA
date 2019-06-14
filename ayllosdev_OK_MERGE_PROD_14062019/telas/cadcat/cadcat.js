/*
 * FONTE        : cadcat.js
 * CRIAÇÃO      : Daniel Zimmermann          
 * DATA CRIAÇÃO : 26/02/2013
 * OBJETIVO     : Biblioteca de funções da tela CADCAT
 * --------------
 * ALTERAÇÕES   : 25/02/2016 - Adição de novas flags (Dionathan).
 * --------------
 */

// Definição de algumas variáveis globais 
var cddopcao		= 'C';

//Formulários
var frmCab   		= 'frmCab';

//Labels/Campos do cabeçalho
var rCddopcao, rcdsubgru, rCdsubgru, cCddopcao, cCdtipcat, cDssubgru, cCdsubgru, cFldesman, cFlrecipr, cFlcatcee, cFlcatcoo, cTodosCabecalho, cTodasFlags;

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
	cTodasFlags.css({'display':'none'});
	cFldesman.val(0);
	cFlrecipr.val(0);
	cFlcatcee.val(0);
	cFlcatcoo.val(0);
	
	
	removeOpacidade('divTela');	
	unblockBackground();
	hideMsgAguardo();
	
	cTodosCabecalho.desabilitaCampo();
	
	cCddopcao.habilitaCampo();
	cCddopcao.val('C');
	cCddopcao.focus();
	
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
			if ( $('#cddgrupo','#frmCab').val() == '') {
				$('#cdsubgru','#frmCab').focus();
				return false;
			} else {
				btnContinuar();
				return false;
			}
		}			
	});
	
	$('#cdsubgru','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13) {	
			if ( $('#cdsubgru','#frmCab').val() == '') {
				$('#cdtipcat','#frmCab').focus();
				return false;
			} else {
				btnContinuar();
				return false;
			}
		}
	});
	
	$('#cdtipcat','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			if ( $('#cdsubgru','#frmCab').val() == '') {
				if ( ( $('#cddopcao','#frmCab').val() == 'I') ){
					$('#dscatego','#frmCab').focus();
					return false;
				} else {
					$('#cdcatego','#frmCab').focus();
					return false;
				}
			} else {
				btnContinuar();
				return false;
			}
		}
	});
	
	$('#cdcatego','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13) {	
			if ( $('#cdcatego','#frmCab').val() == '') {
				$('#fldesman','#frmCab').focus();
				return false;
			} else {
				btnContinuar();
				return false;
			}
		}
	});
	
	$('#cddgrupo','#frmCab').unbind('blur').bind('blur', function() {
				btnContinuar();
				return false;
	});
	
	
	$('#cdsubgru','#frmCab').unbind('blur').bind('blur', function() {
				btnContinuar();
				return false;
	});
	
	$('#cdtipcat','#frmCab').unbind('blur').bind('blur', function() {
				btnContinuar();
				return false;
	});
	
	$('#cdcatego','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13) {
				btnContinuar();
				return false;
		}
	});
	
}

function formataCabecalho() {

	// Rotulo
	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab); 
	rCddgrupo			= $('label[for="cddgrupo"]','#'+frmCab); 	
	rCdsubgru			= $('label[for="cdsubgru"]','#'+frmCab);
	rCdtipcat			= $('label[for="cdtipcat"]','#'+frmCab);
	rCdcatego			= $('label[for="cdcatego"]','#'+frmCab);
	
	// Campo
	cCddopcao			= $('#cddopcao','#'+frmCab); 
	cCddgrupo           = $('#cddgrupo','#'+frmCab); 
	cCdsubgru			= $('#cdsubgru','#'+frmCab); 
	cCdtipcat			= $('#cdtipcat','#'+frmCab); 
	ccdtipcat			= $('#cdtipcat','#'+frmCab); 
	cCdcatego			= $('#cdcatego','#'+frmCab); 
	cDscatego			= $('#dscatego','#'+frmCab);
	cFldesman			= $('#fldesman','#'+frmCab);
	cFlrecipr			= $('#flrecipr','#'+frmCab);
	cFlcatcee			= $('#flcatcee','#'+frmCab);
	cFlcatcoo			= $('#flcatcoo','#'+frmCab);
	
	cDsdgrupo           = $('#dsdgrupo','#'+frmCab); 
	cDssubgru			= $('#dssubgru','#'+frmCab); 
	cDstipcat			= $('#dstipcat','#'+frmCab);
	
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	cTodasFlags			= $('.trFlags')
	
	rCdcatego.css('width','65px');
	rCddopcao.css('width','65px');
	rCddgrupo.css('width','65px');
	rCdsubgru.css({'width':'65px'});
	rCdtipcat.css({'width':'65px'});
	
	cCdcatego.css({'width':'90px'}).attr('maxlength','9').setMask('INTEGER','zzzzzzzzz','','');
	cCddopcao.css({'width':'436px'});	
	cCddgrupo.css({'width':'90px'}).attr('maxlength','9').setMask('INTEGER','zzzzzzzzz','','');
	cCdsubgru.css({'width':'90px'}).attr('maxlength','9').setMask('INTEGER','zzzzzzzzz','','');
	cCdtipcat.css({'width':'90px'}).attr('maxlength','9').setMask('INTEGER','zzzzzzzzz','','');
	cDscatego.css({'width':'357px'}).attr('maxlength','50').setMask("STRING",50,charPermitido(),"");	

	cDsdgrupo.css({'width':'357px'});
	cDssubgru.css({'width':'357px'});
	cDstipcat.css({'width':'357px'});
	
	
	if ( $.browser.msie ) {
		cCdsubgru.css({'width':'90px'});
		ccdtipcat.css({'width':'90px'});
		cDscatego.css({'width':'357px'});
	}	
	
	cTodosCabecalho.habilitaCampo();
	$('#cddopcao','#'+frmCab).focus();
				
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

	//Desabilita todos os campos
	cTodosCabecalho		= $('input[type="text"],select','#frmCab'); 
	cTodosCabecalho.desabilitaCampo();
	
	$('#cdcatego','#frmCab').habilitaCampo();
	$('#cddgrupo','#frmCab').habilitaCampo();
	$('#cdsubgru','#frmCab').habilitaCampo();
	$('#cdtipcat','#frmCab').habilitaCampo();
	
	$('#divBotoes', '#divTela').css({'display':'block'});
	
	trocaBotao( 'Prosseguir');
	
	$("#btSalvar","#divBotoes").show();
	$("#btVoltar","#divBotoes").show();
	
	if ( $('#cddopcao','#frmCab').val() == 'I' ){
		trocaBotao( 'Incluir');
		buscaSequencial();
		liberaCamposEditaveis();
		$('#dscatego','#frmCab').focus();
	}
	
	if ( $('#cddopcao','#frmCab').val() == 'A' ){
		trocaBotao( 'Alterar');
		$('#cddgrupo','#frmCab').focus();
	}
	
	return false;

}

function btnContinuar() {

	$('input,select', '#frmCab').removeClass('campoErro');

	cddgrupo = normalizaNumero( cCddgrupo.val() );
	cdsubgru = normalizaNumero( cCdsubgru.val() );
	cdtipcat = normalizaNumero( cCdtipcat.val() );
	cdcatego = normalizaNumero( cCdcatego.val() );
	cddopcao = cCddopcao.val();
	
	if (( cdcatego != '' ) && ( ! $('#cdcatego','#frmCab').hasClass('campoTelaSemBorda') )) {
		if (cddopcao != 'I') {
			buscaDados(4);
			return true;
			}
	} else {
		if (( cdsubgru != '' ) && ( ! $('#cdsubgru','#frmCab').hasClass('campoTelaSemBorda') )) {		 
			buscaDados(2);
			return true;
			} else {
			 if (( cddgrupo != '' ) && ( ! $('#cddgrupo','#frmCab').hasClass('campoTelaSemBorda') )) {		 
				buscaDados(1);
				return true;
				}
		}
	}
	
	if (( cdtipcat != '' ) && ( ! $('#cdtipcat','#frmCab').hasClass('campoTelaSemBorda') )) {
			buscaDados(3);
			return true;
			}
	
	return true;
}

function realizaOperacao() {

	// Mostra mensagem de aguardo
	if (cddopcao == "C"){  	   showMsgAguardo("Aguarde, consultando Categoria..."); } 
	else if (cddopcao == "I"){ showMsgAguardo("Aguarde, incluindo Categoria...");  }
	else if (cddopcao == "A"){ showMsgAguardo("Aguarde, alterando Categoria...");  }	
	else if (cddopcao == "E"){ showMsgAguardo("Aguarde, excluindo Categoria...");  }	
	else { showMsgAguardo("Aguarde, liberando aplicacao..."); }
	
	var cddgrupo = $('#cddgrupo','#frmCab').val();
	cddgrupo = normalizaNumero(cddgrupo);	
	var cdsubgru = $('#cdsubgru','#frmCab').val();
	cdsubgru = normalizaNumero(cdsubgru);	
	var cdtipcat = $('#cdtipcat','#frmCab').val();
	cdtipcat = normalizaNumero(cdtipcat);	
	var cdcatego = $('#cdcatego','#frmCab').val();
	cdcatego = normalizaNumero(cdcatego);	
	var dscatego = $('#dscatego','#frmCab').val();
	var fldesman = $('#fldesman','#frmCab').val();
	var flrecipr = $('#flrecipr','#frmCab').val();
	var flcatcee = $('#flcatcee','#frmCab').val();
	var flcatcoo = $('#flcatcoo','#frmCab').val();
	
	
	
//	var strcateg = dscatego.split(" ");
//	strcateg = strcateg[0];
//	var nrconven = normalizaNumero(strcateg);	
	
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadcat/manter_rotina.php", 
		data: {
			cddgrupo: cddgrupo,
			cdsubgru: cdsubgru,
			cdtipcat: cdtipcat,
			cdcatego: cdcatego,
			dscatego: dscatego,
			cddopcao: cddopcao,	
			fldesman: fldesman,
			flrecipr: flrecipr,
			flcatcee: flcatcee,
			flcatcoo: flcatcoo,
//			nrconven: nrconven,
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
		case 3:
		  controlaPesquisaTipoCategoria();
		  break;		  
		case 4:
		  controlaPesquisaCategoria();
		  break;		  		  
	}

}

function controlaPesquisaGrupo() {

	// Se esta desabilitado o campo grupo
	if ($("#cddgrupo","#frmCab").prop("disabled") == true)  {
		return;
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
	dsdgrupo = '';
	
	titulo_coluna = "Grupos de produto";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-grupos';
	titulo      = 'Grupos';
	qtReg		= '10';
	filtros 	= 'Codigo;cddgrupo;100px;S;' + cddgrupo + ';S|Descricao;dsdgrupo;150px;S;' + dsdgrupo + ';S';
	colunas 	= 'Codigo;cddgrupo;20%;right|' + titulo_coluna + ';dsdgrupo;50%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cddgrupo\',\'#frmCab\').val()');
	
	return false;
}

function controlaPesquisaSubGrupo(){

	// Se esta desabilitado o campo  subgrupo
	if ($("#cdsubgru","#frmCab").prop("disabled") == true)  {
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
	
	var cdsubgru = $('#cdsubgru','#'+nomeFormulario).val();
	var cddgrupo  = $('#cddgrupo','#'+nomeFormulario).val();
	dssubgru = '';
	
	titulo_coluna = "Sub-grupos de produto";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-subgrupos';
	titulo      = 'Sub-grupos';
	qtReg		= '10';
	filtros 	= 'Grupo;cddgrupo;100px;N;' + cddgrupo + ';S|Codigo;cdsubgru;100px;S;' + cdsubgru + ';S|Descricao;dssubgru;300px;S;' + dssubgru + ';S';
	colunas 	= 'Grupo;cddgrupo;15%;right|Codigo;cdsubgru;15%;right|' + titulo_coluna + ';dssubgru;65%;left';
	
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cdsubgru\',\'#frmCab\').focus()');
	
	$("#divCabecalhoPesquisa > table").css("width","560px");
	$("#divResultadoPesquisa > table").css("width","100%");
	$("#divCabecalhoPesquisa > table").css("float","left");
	$("#divCabecalhoPesquisa").css("width","580px");
	$("#divResultadoPesquisa").css("width","100%");	
	
	return false;
}

function controlaPesquisaTipoCategoria() {

	// Se esta desabilitado o campo tipo de categoria.
	if ($("#cdtipcat","#frmCab").prop("disabled") == true)  {
		return;
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
	qtReg		= '10';
	filtros 	= 'Codigo;cdtipcat;130px;S;' + cdtipcat + ';S|Descricao;dstipcat;100px;S;' + dstipcat + ';N';
	colunas 	= 'Codigo;cdtipcat;20%;right|' + titulo_coluna + ';dstipcat;50%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cdtipcat\',\'#frmCab\').val()');
	
	return false;	
}

function controlaPesquisaCategoria() {

	// Desabilita a consulta no caso de opcao de inclusao.
	if ( $('#cddopcao','#frmCab').val() == "I"){
		return false;
	}
	
	// Se esta desabilitado o campo tipo de categoria.
	if ($("#cdcatego","#frmCab").prop("disabled") == true)  {
		return;
	}	
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, titulo_coluna, cdgrupos, dscatego;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmCab';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdtipcat = $('#cdtipcat','#'+nomeFormulario).val();
	var cddgrupo = $('#cddgrupo','#'+nomeFormulario).val();
	var cdsubgru = $('#cdsubgru','#'+nomeFormulario).val();
	var cdcatego = $('#cdcatego','#'+nomeFormulario).val();
	
	cdtipcat = normalizaNumero( cdtipcat );
	cddgrupo = normalizaNumero( cddgrupo );
	cdsubgru = normalizaNumero( cdsubgru );
	cdcatego = normalizaNumero( cdcatego );	
		
	dscatego = '';
	
	titulo_coluna = "Categoria";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-categorias';
	titulo      = 'Descricao';
	qtReg		= '20';
	filtros 	= 'Grupo;cddgrupo;130px;S;' + cddgrupo + ';S|' + 'SubGrupo;cdsubgru;130px;S;' + cdsubgru + ';S|' +
	              'Tipo Categoria;cdtipcat;130px;S;' + cdtipcat + ';S|' + 'Categoria;cdcatego;130px;S;' + cdcatego + ';S|' +
				  'Descricao;dscatego;300px;S;' + dscatego + ';S';
	colunas 	= 'Grupo;cddgrupo;13%;right|SubGrupo;cdsubgru;16%;right|Tipo;cdtipcat;10%;right|' +
	              'Codigo;cdcatego;11%;right|' + titulo_coluna + ';dscatego;53%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cdtipcat\',\'#frmCab\').val()');
	
	$("#divPesquisa").css("left","258px");
	$("#divPesquisa").css("top","91px");
	$("#divCabecalhoPesquisa > table").css("width","675px");
	$("#divCabecalhoPesquisa > table").css("float","left");
	$("#divResultadoPesquisa > table").css("width","690px");
	$("#divCabecalhoPesquisa").css("width","690px");
	$("#divResultadoPesquisa").css("width","690px");
	
	
	return false;	
}

function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>');

	if ( ( botao == 'X') && ( $('#cddopcao','#frmCab').val() == 'C' ) ) {
		if ( $('#cddopcao','#frmCab').val() == 'I' ){ botao = 'Incluir'; }
		if ( $('#cddopcao','#frmCab').val() == 'E' ){ botao = 'Excluir'; }
		if ( $('#cddopcao','#frmCab').val() == 'A' ){ botao = 'Alterar'; }
		
		$('#divBotoes','#divTela').append('&nbsp;<a href="#" class="botao" onClick="realizaOperacao(); return false;" >'+botao+'</a>');
		return false;
	}
	
	if ( botao != '')  {
		$('#divBotoes','#divTela').append('&nbsp;<a href="#" class="botao" onClick="validaCampos(); return false;" >'+botao+'</a>');
	}
	
	
	return false;
}

function buscaDados( valor ) {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, efetuando consulta...");
	
	switch( valor )
	{
		case 1:
		  buscaDadosGrupo();		  		  
		  break;
		case 2:		  
		  buscaDadosSubGrupo();
		  break;
		case 3:		  
		  buscaDadosTipoCategoria();
		  break;
		case 4:
		  buscaDadosCategoria();
		  break;
	}

}

function buscaDadosGrupo(){

	var cddgrupo = $('#cddgrupo','#frmCab').val();
	cddgrupo = normalizaNumero(cddgrupo);

	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadcat/busca_dados_grupo.php", 
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
	
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadcat/busca_dados_subgrupo.php", 
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

function buscaDadosTipoCategoria(){

	var cdtipcat = $('#cdtipcat','#frmCab').val();		
	cdtipcat = normalizaNumero(cdtipcat);		
	
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadcat/busca_dados_tipo_cat.php", 
		data: {
			cdtipcat: cdtipcat,
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

function buscaDadosCategoria(){

	var cdcatego = $('#cdcatego','#frmCab').val();		
	cdcatego = normalizaNumero(cdcatego);
	
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		dataType: "script",
		url: UrlSite + "telas/cadcat/busca_dados_categoria.php", 
		data: {
			cdcatego: cdcatego,
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
		url: UrlSite + "telas/cadcat/busca_sequencial.php", 
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

function liberaCamposEditaveis() {
	$('#dscatego','#frmCab').habilitaCampo();
	$('#fldesman','#frmCab').habilitaCampo();
	$('#flrecipr','#frmCab').habilitaCampo();
	$('#flcatcee','#frmCab').habilitaCampo();
	$('#flcatcoo','#frmCab').habilitaCampo();
	$('#dscatego','#frmCab').focus();
}

function validaCampos() {

	if ( btnContinuar() == true ) {
	
	validaOperacao(); }

}

function validaOperacao() {

	var cddgrupo = normalizaNumero( cCddgrupo.val() );
	var cdsubgru = normalizaNumero( cCdsubgru.val() );
	var cdtipcat = normalizaNumero( cCdtipcat.val() );
	var cdcatego = normalizaNumero( cCdcatego.val() );
	var cddopcao = cCddopcao.val();
	var dscatego = cDscatego.val();
	
	if ( ( cddopcao == 'I') ){ 
		if ( cdtipcat == '' ){ 
			hideMsgAguardo();
			showError("error","Tipo da categoria deve ser informado.","Alerta - Ayllos","focaCampoErro(\'cdtipcat\', \'frmCab\');",false);
			return false; }
	}
	
	if ( cdcatego == '' ){ 
		hideMsgAguardo();
		showError("error","C&oacute;digo da categoria deve ser informado.","Alerta - Ayllos","focaCampoErro(\'cdcatego\', \'frmCab\');",false);
		return false;
	}
	
	 if ( ( cddopcao == 'A' ) || ( cddopcao == 'I') ){ 
		if ( dscatego == '' ) {
			if ( ! $('#dscatego','#frmCab').hasClass('campoTelaSemBorda') ) {
				hideMsgAguardo();
				showError("error","Descri&ccedil;&atilde;o da categoria deve ser informado.","Alerta - Ayllos","focaCampoErro(\'dscatego\', \'frmCab\');",false);
			}
			return false; }
	}
	
	if ( (  $('#cdcatego','#frmCab').hasClass('campoTelaSemBorda')) ||
			 (  $('#cddgrupo','#frmCab').hasClass('campoTelaSemBorda')) ||
			 (  $('#cdtipcat','#frmCab').hasClass('campoTelaSemBorda')) ||
			 (  $('#cdsubgru','#frmCab').hasClass('campoTelaSemBorda')) ) {
			trocaBotao('');
	 }
	 
	 realizaOperacao();
	
	return false;
	
}

function exibeOcultaTrFlags() {
    var cddgrupo = $('#cddgrupo','#frmCab').val();
	cddgrupo = normalizaNumero(cddgrupo);
    // Exibe somente se for Grupo 3 - Cobranca
    if (cddgrupo == 3) {
        cTodasFlags.css({'display':'table-row'});
    } else {
        cTodasFlags.css({'display':'none'});
    }
}

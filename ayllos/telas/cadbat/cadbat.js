/*!
 * FONTE        : cadbat.js
 * CRIAÇÃO      : Tiago Machado          
 * DATA CRIAÇÃO : 19/04/2013
 * OBJETIVO     : Biblioteca de funções da tela CADBAT
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */

// Definição de algumas variáveis globais 
var cddopcao		= 'C';
	
//Formulários
var frmCab   		  = 'frmCab';
var frmDadosTarifa    = 'frmDadosTarifa';
var frmDadosParametro = 'frmDadosParametro';

//Labels/Campos do cabeçalho
var rCddopcao, cCddopcao, rCdbattar, cCdbattar, cNmidenti, rTpcadast, cTpcadast, rCdprogra, cCdprogra, cTodosCabecalho, btnCab;
var rCdtarifa, rTppessoa, rDsdgrupo, rDssubgru, rDscatego, cCdtarifa, cDstarifa, cTppessoa, cInpessoa,	cDsdgrupo, cCddgrupo, cDssubgru,
	cCdsubgru, cDscatego, cCdcatego, cTodosDadosTarifa;
var rCdpartar, rTpdedado, cCdpartar, cNmpartar, cTpdedado;


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
	
	$('#frmCab').css({'width':'700px'});	
		
	formataCabecalho();
	formataDadosTarifa();
	formataDadosParametro();
	
	cTodosCabecalho.limpaFormulario();
	cTodosDadosTarifa.limpaFormulario();
	cTodosDadosParametro.limpaFormulario();
	
	cCddopcao.val( cddopcao );
	cTpcadast.val(0);
	
	removeOpacidade('divTela');	
	unblockBackground();
	hideMsgAguardo();
		
	trocaBotao('');
	
	$("#btVoltar","#divBotoes").hide();
	
	$('#frmDadosTarifa').hide();
	$('#frmDadosParametro').hide();
	
	$('input,select', '#frmCab').removeClass('campoErro');
	
	controlaFoco();
		
}

function controlaFoco() {

	$('#cddopcao','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				LiberaCampos();
				$('#cdbattar','#frmCab').focus();
				return false;
			}	
	});
	
	$('#btnOK','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				LiberaCampos();
				$('#cdbattar','#frmCab').focus();
				return false;
			}	
	});
	
	$('#cdbattar','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9 ) {	
			if ( $('#cdbattar','#frmCab').val() == '' ) {
				controlaPesquisa(1);					
			} else {				
				if( $('#cddopcao','#frmCab').val() == 'I' ){
					$('#nmidenti','#frmCab').focus();
				}else{	
					btnContinuar();
				}													
			}		
			return false;
		}			
	});

	$('#nmidenti','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			if ($('#nmidenti','#frmCab').val() != ''){
				btnContinuar();
				return false;
			}	
		}			
	});
	
	$('#tpcadast','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			if ($('#tpcadast','#frmCab').val() != ''){
				if ( $('#tpcadast','#frmCab').val() == 1 ) {
					rCdprogra.show();
					cCdprogra.show().habilitaCampo().focus();
				} else {
					rCdprogra.hide();
					cCdprogra.hide();
				}
				btnContinuar();
				return false;
			}	
		}			
	});
	
	$('#tpcadast','#frmCab').unbind('change').bind('change', function(e) {
			if ( $('#tpcadast','#frmCab').val() == 1 ) {
				rCdprogra.show();
				cCdprogra.show().habilitaCampo().focus();
			} else {
				rCdprogra.hide();
				cCdprogra.hide();
			}
			return false;
	});
	
	
	
}

function formataDadosParametro(){

	rCdpartar	= $('label[for="cdpartar"]','#'+frmDadosParametro);
	rTpdedado	= $('label[for="tpdedado"]','#'+frmDadosParametro);
	
	cCdpartar	= $('#cdpartar','#'+frmDadosParametro);
	cNmpartar	= $('#nmpartar','#'+frmDadosParametro);	
	cTpdedado	= $('#tpdedado','#'+frmDadosParametro);
	
	cTodosDadosParametro = $('input[type="text"],select','#'+frmDadosParametro);

	rCdpartar.addClass('rotulo-linha').css({'width':'80px'});
	rTpdedado.addClass('rotulo-linha').css({'width':'80px'});

	cCdpartar.css({'width':'100px'}).attr('maxlength','10').setMask('INTEGER','zzzzzzzzzz','','');;
	cNmpartar.css({'width':'476px'});	
	cTpdedado.css({'width':'100px'});
	
	if ( $.browser.msie ) {
		cCdpartar.css({'width':'100px'});
		cNmpartar.css({'width':'476px'});		
		cTpdedado.css({'width':'100px'});
	}

	cCdpartar.unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				btnContinuar();
				return false;
			}	
	});	
	
	cTodosDadosParametro.habilitaCampo();
				
	layoutPadrao();	
	
	return false;	
}

function formataDadosTarifa(){

	rCdtarifa	= $('label[for="cdtarifa"]','#'+frmDadosTarifa);
	rTppessoa	= $('label[for="tppessoa"]','#'+frmDadosTarifa);
	rDsdgrupo	= $('label[for="dsdgrupo"]','#'+frmDadosTarifa);
	rDssubgru	= $('label[for="dssubgru"]','#'+frmDadosTarifa);
	rDscatego	= $('label[for="dscatego"]','#'+frmDadosTarifa);
	
	cCdtarifa	= $('#cdtarifa','#'+frmDadosTarifa);
	cDstarifa	= $('#dstarifa','#'+frmDadosTarifa);
	cTppessoa	= $('#tppessoa','#'+frmDadosTarifa);
	cInpessoa	= $('#inpessoa','#'+frmDadosTarifa);
	cDsdgrupo	= $('#dsdgrupo','#'+frmDadosTarifa);
	cCddgrupo	= $('#cddgrupo','#'+frmDadosTarifa);
	cDssubgru	= $('#dssubgru','#'+frmDadosTarifa);
	cCdsubgru	= $('#cdsubgru','#'+frmDadosTarifa);
	cDscatego	= $('#dscatego','#'+frmDadosTarifa);
	cCdcatego	= $('#cdcatego','#'+frmDadosTarifa);
	
	cTodosDadosTarifa = $('input[type="text"],select','#'+frmDadosTarifa);

	
	rCdtarifa.addClass('rotulo-linha').css({'width':'80px'});
	rTppessoa.addClass('rotulo-linha').css({'width':'80px'});
	rDsdgrupo.addClass('rotulo-linha').css({'width':'80px'});
	rDssubgru.addClass('rotulo-linha').css({'width':'80px'});
	rDscatego.addClass('rotulo-linha').css({'width':'80px'});	
	
	cCdtarifa.css({'width':'100px'});
	cDstarifa.css({'width':'476px'});
	cTppessoa.css({'width':'200px'});
	cInpessoa.css({'width':'100px'});
	cDsdgrupo.css({'width':'600px'}).attr('maxlength','255');
	cCddgrupo.css({'width':'100px'});
	cDssubgru.css({'width':'600px'}).attr('maxlength','255');
	cCdsubgru.css({'width':'100px'});
	cDscatego.css({'width':'600px'}).attr('maxlength','255');
	cCdcatego.css({'width':'100px'});
	
	if ( $.browser.msie ) {
		cCdtarifa.css({'width':'100px'});
		cDstarifa.css({'width':'476px'});
		cTppessoa.css({'width':'200px'});
		cInpessoa.css({'width':'100px'});
		cDsdgrupo.css({'width':'600px'}).attr('maxlength','255');
		cCddgrupo.css({'width':'100px'});
		cDssubgru.css({'width':'600px'}).attr('maxlength','255');
		cCdsubgru.css({'width':'100px'});
		cDscatego.css({'width':'600px'}).attr('maxlength','255');
		cCdcatego.css({'width':'100px'});
	}	
	
	cCdtarifa.unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				buscarTarifa();
				return false;
			}	
	});	
	
	cTodosDadosTarifa.habilitaCampo();
				
	$('#dstarifa','#frmDadosTarifa').desabilitaCampo();
	$('#tppessoa','#frmDadosTarifa').desabilitaCampo();
	$('#cddgrupo','#frmDadosTarifa').desabilitaCampo();
	$('#dsdgrupo','#frmDadosTarifa').desabilitaCampo();
	$('#cdsubgru','#frmDadosTarifa').desabilitaCampo();
	$('#dssubgru','#frmDadosTarifa').desabilitaCampo();
	$('#cdcatego','#frmDadosTarifa').desabilitaCampo();
	$('#dscatego','#frmDadosTarifa').desabilitaCampo();
				
	layoutPadrao();	
	
	return false;
}

function formataCabecalho() {

	// cabecalho
	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab); 
	rCdbattar			= $('label[for="cdbattar"]','#'+frmCab); 
	rTpcadast           = $('label[for="tpcadast"]','#'+frmCab); 
	rCdprogra           = $('label[for="cdprogra"]','#'+frmCab); 	
	
	cCddopcao			= $('#cddopcao','#'+frmCab); 
	cCdbattar			= $('#cdbattar','#'+frmCab); 
	cTpcadast			= $('#tpcadast','#'+frmCab); 	
	cCdprogra			= $('#cdprogra','#'+frmCab); 
	cNmidenti			= $('#nmidenti','#'+frmCab); 
	
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	btnCab				= $('#btOK','#'+frmCab);
	
	rCddopcao.css('width','44px');
	rCdbattar.addClass('rotulo-linha').css({'width':'44px'});
	rTpcadast.addClass('rotulo-linha').css({'width':'44px'});
	rCdprogra.addClass('rotulo-linha').css({'width':'83px'});
	
	cCddopcao.css({'width':'610px'});
	cCdbattar.css({'width':'100px'}).attr('maxlength','10').setMask("STRING",11,charPermitido(),"");;
	cNmidenti.css({'width':'523px'}).attr('maxlength','255').setMask("STRING",255,charPermitido(),"");
	cTpcadast.css({'width':'100px'}).attr('maxlength','255');	
	cCdprogra.css({'width':'440px'}).attr('maxlength','255');
	
	if ( $.browser.msie ) {
		rCdbattar.css({'width':'44px'});
		rTpcadast.css({'width':'44px'});
		
		cNmidenti.css({'width':'523px'});
		cCddopcao.css({'width':'610px'});		
		cTpcadast.css({'width':'100px'});
		cCdprogra.css({'width':'460px'});
	}	
	
	cTodosCabecalho.habilitaCampo();
	
	cNmidenti.desabilitaCampo();
	cTpcadast.desabilitaCampo();
	cCdprogra.desabilitaCampo();
	cCdbattar.desabilitaCampo();
	
	$('#cddopcao','#'+frmCab).focus();
	
	rCdprogra.hide();
	cCdprogra.hide();
	
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
	
	$('#cdbattar','#frmCab').habilitaCampo();	
	$('#divBotoes', '#divTela').css({'display':'block'});	
	$("#btSalvar","#divBotoes").show();
	$("#btVoltar","#divBotoes").show();
	
	trocaBotao( 'Prosseguir');

	if ( $('#cddopcao','#frmCab').val() == 'I' ){
	
		$('#cdbattar','#frmCab').focus();
		
		cNmidenti.habilitaCampo();
		cTpcadast.habilitaCampo();	
		trocaBotao( 'Incluir');
		return false;
	}
	
	if( $('#cddopcao','#frmCab').val() == 'A' ){
	
		$('#cdbattar','#frmCab').focus();
		
		cTpcadast.desabilitaCampo();	
		
		if( cTpcadast.val() == 1 ){
			cCdprogra.habilitaCampo();
		}
		
		trocaBotao( 'Alterar');
	}

	if ( $('#cddopcao','#frmCab').val() == 'V' ){
	
		if( parseInt( cTpcadast.val() ) == 1 ){
			cCdtarifa.focus();
		}

		if( parseInt( cTpcadast.val() ) == 2 ){
			cCdpartar.focus();
		}
		
		trocaBotao( 'Prosseguir');
		return false;
	}

	
	$('#cdbattar','#frmCab').focus();

	return false;
}

function btnContinuar() {

	$('input,select', '#frmCab').removeClass('campoErro');
	
	if( (cCddopcao.val() != 'I') && ( cCdbattar.hasClass('campoTelaSemBorda') == false ) ){	
		buscaDados();
		return false;
	}
	
	if( cCddopcao.val() == 'I' ){
		if ( cCdbattar.val() == '' ) {
			showError("error","Sigla deve ser informado.","Alerta - Ayllos","focaCampoErro(\'tpcadast\', \'frmCab\');",false);
			return false;
		}
		
		if ( cNmidenti.val()  == '' ){
			showError("error","Descrição deve ser informado.","Alerta - Ayllos","focaCampoErro(\'nmidenti\', \'frmCab\');",false);
			return false;
		}
		
		if ( parseInt( cTpcadast.val() ) == 0 ){
			showError("error","Tipo deve ser informado.","Alerta - Ayllos","focaCampoErro(\'tpcadast\', \'frmCab\');",false);
			return false;
		}
		
	}

	if( cCddopcao.val() == 'A' ){
		if ( cCdbattar.val() == '' ) {
			return false;
		}		
	}
	
	if( cCddopcao.val() == 'V' ){
		
		if ( parseInt( cTpcadast.val() ) == 1 ){
			if ( (cCdtarifa.val() == '') || (cCdtarifa.val() == 0) ){		
				return false;
			}
		}
		
		if ( parseInt( cTpcadast.val() ) == 2 ){
			if ( (cCdpartar.val() == '') || (cCdpartar.val() == 0) ){					
				return false;
			}
		}
		
	
		if ( cCdbattar.val() == '' ){
			showError("error","Sigla deve ser informada.","Alerta - Ayllos","focaCampoErro(\'cdbattar\', \'frmCab\');",false);
			return false;
		}	

		
		if ( parseInt( cTpcadast.val() ) == 0  ){
			// showError("error","Tipo deve ser informado.","Alerta - Ayllos","focaCampoErro(\'tpcadast\', \'frmCab\');",false);
			return false;		
		}
		
	}
	
	// Se chegou até aqui, o grupo é diferente do vazio e é válida, então realizar a operação desejada
	realizaOperacao();
	
	return false;		
}

function realizaOperacao() {

	// Mostra mensagem de aguardo
	cddopcao = cCddopcao.val();
	
	if (cddopcao == "C"){  	   showMsgAguardo("Aguarde, consultando..."); } 
	else if (cddopcao == "I"){ showMsgAguardo("Aguarde, incluindo...");  }
	else if (cddopcao == "A"){ showMsgAguardo("Aguarde, alterando...");  }	
	else if (cddopcao == "E"){ showMsgAguardo("Aguarde, excluindo...");  }
	else { showMsgAguardo("Aguarde, liberando aplicacao..."); }
	
	var cdbattar = $('#cdbattar','#frmCab').val();	
	var nmidenti = $('#nmidenti','#frmCab').val();	
	var tpcadast = $('#tpcadast','#frmCab').val();	
	var cdprogra = $('#cdprogra','#frmCab').val();	
	var cdtarifa = $('#cdtarifa','#frmDadosTarifa').val();	
	var cdpartar = $('#cdpartar','#frmDadosParametro').val();	
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadbat/manter_rotina.php", 
		data: {
			cddopcao: cddopcao,			
			cdbattar: cdbattar,
			nmidenti: nmidenti,
			tpcadast: tpcadast,
			cdprogra: cdprogra,
			cdtarifa: cdtarifa,
			cdpartar: cdpartar,
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

function controlaPesquisa(valor) {

	$("#divCabecalhoPesquisa").css("width","100%");
	$("#divResultadoPesquisa").css("width","100%");

	switch(valor){
		case 1:
			controlaPesquisaCdbattar();
			break;	
		case 2:
			controlaPesquisaTarifa();
			break;	
		case 3:
			controlaPesquisaParametro();
			break;
	}
	
	return false;
}

function controlaPesquisaTarifa() {

	// Se esta desabilitado o campo 
	if ($("#cdtarifa","#frmDadosTarifa").prop("disabled") == true)  {
		return;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdtarifa, titulo_coluna, cdtarifas, dstarifa, cddgrupo;
    var dsdgrupo, cdsubgru, dssubgru, cdcatego, dscatego, cdinctar, inpessoa, flglaman;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmDadosTarifa';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdtarifa = $('#cdtarifa','#'+nomeFormulario).val();
	cdtarifas = cdtarifa;	
	dstarifa = '';
	dsdgrupo = '';
	cdsubgru = 0;
	dssubgru = '';
	cdcatego = 0;
	dscatego = '';
	cddgrupo = 0;
	
	titulo_coluna = "Tarifas";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-tarifas';
	titulo      = 'Tarifas';
	qtReg		= '20';	
	//filtros 	=           'Grupo;cddgrupo;100px;N;'    + cddgrupo + ';N|Desc;dsdgrupo;150px;N;'      + dsdgrupo + ';N|'; //GRUPO
	filtros     = filtros + 'Subgrupo;cdsubgru;100px;N;' + cdsubgru + ';N|Desc;dssubgru;150px;N;'      + dssubgru + ';N|'; //SUBGRUPO
	filtros     = filtros + 'Categoria;cdcatego;100px;N;' + cdcatego + ';N|Desc;dscatego;150px;N;'     + dssubgru + ';N|'; //CATEGORIA
	filtros     = filtros + 'Codigo;cdtarifa;100px;S;'   + cdtarifa + ';S|Descricao;dstarifa;300px;S;' + dstarifa + ';S|'; //TARIFA
	filtros     = filtros + 'Desc;dspessoa;100px;N;'   + cdtarifa + ';N';                                                  //TIPO PESSOA
	
	colunas     = 'Cod;cdsubgru;4%;right|SubGrupo;dssubgru;21%;left|'                          //SUBGRUPO
	colunas     = colunas + 'Cod;cdcatego;4%;right|Categoria;dscatego;21%;left|'               //CATEGORIA
	colunas     = colunas + 'Cod;cdtarifa;4%;right|' + titulo_coluna + ';dstarifa;21%;left|';  //TARIFA
	colunas		= colunas + 'Tipo;dspessoa;8%;right';	
	//colunas     = colunas + titulo_coluna + ';dstarifa;21%;left|' + 'Cod;cdtarifa;4%;right';  //TARIFA
	
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','buscarTarifa()');	
	
	$("#divPesquisa").css("left","258px");
	$("#divPesquisa").css("top","91px");
	$("#divCabecalhoPesquisa > table").css("width","875px");
	$("#divCabecalhoPesquisa > table").css("float","left");	
	$("#divResultadoPesquisa > table").css("width","890px");
	$("#divCabecalhoPesquisa").css("width","890px");
	$("#divResultadoPesquisa").css("width","890px");
	
	return false;

}

function controlaPesquisaParametro() {

	// Se esta desabilitado o campo 
	if ($("#cdpartar","#frmDadosParametro").prop("disabled") == true)  {
		return;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdpartar, titulo_coluna, cdpartars, nmpartar;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmDadosParametro';
	
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
	filtros 	= 'Codigo;cdpartar;130px;S;' + cdpartar + ';S|Descricao;nmpartar;100px;S;' + nmpartar + ';N';
	colunas 	= 'Codigo;cdpartar;20%;right|' + titulo_coluna + ';nmpartar;50%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','buscarParametro()');
	
	return false;
}

function controlaPesquisaCdbattar(){
	
	// Se esta desabilitado o campo contrato
	if ($("#cdbattar","#frmCab").prop("disabled") == true)  {
		return false;
	}
	
	if ( $('#cddopcao','#frmCab').val() == "I"){
		return false;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdbattar, titulo_coluna, nmidenti;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmCab';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdbattar = $('#cdbattar','#'+nomeFormulario).val();	
	nmidenti = '';
	
	titulo_coluna = "Identificacao";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-cadbat';
	titulo      = 'Vinculacao Tarifas x Programas';
	qtReg		= '20';
	filtros 	= 'Codigo;cdbattar;100px;S;' + cdbattar + ';S|Descricao;nmidenti;550px;S;' + nmidenti + ';S';
	colunas 	= 'Codigo;cdbattar;12%;left|' + titulo_coluna + ';nmidenti;70%;left|Tipo;dscadast;10%;left|Codigo;cdcadast;10%;right';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cdbattar\',\'#frmCab\').val()');	
	
	$("#divPesquisa").css("left","258px");
	$("#divPesquisa").css("top","91px");
	$("#divCabecalhoPesquisa > table").css("width","875px");
	$("#divCabecalhoPesquisa > table").css("float","left");
	$("#divResultadoPesquisa > table").css("width","890px");
	$("#divCabecalhoPesquisa").css("width","890px");
	$("#divResultadoPesquisa").css("width","890px");
	
}

function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>');

	if ( botao != '') {
		$('#divBotoes','#divTela').append('&nbsp;<a href="#" class="botao" id="btContinuar" onClick="btnContinuar(); return false;" >'+botao+'</a>');
	}
	return false;
}

function buscaDados() {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, consultando vinculo...");
	cddopcao = cCddopcao.val();
	
	var cdbattar = $('#cdbattar','#frmCab').val();	
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadbat/busca_dados.php", 
		data: {
			cdbattar: cdbattar,
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

function buscarTarifa(){

	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmDadosTarifa';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');

	showMsgAguardo("Aguarde, consultando Tarifas...");

	var cdtarifa = $('#cdtarifa','#frmDadosTarifa').val();
	cdtarifa = normalizaNumero(cdtarifa);
	
	var cddopcao = $('#cddopcao','#frmCab').val();
	
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadbat/busca_dados_tarifa.php", 
		data: {
			cddopcao: cddopcao,
			cdtarifa: cdtarifa,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					eval(response);
					hideMsgAguardo();					
				} catch(error) {
					hideMsgAguardo();
					showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
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
}

function buscarParametro(){

	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmDadosParametro';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');

	showMsgAguardo("Aguarde, consultando Parametros...");

	var cdpartar = $('#cdpartar','#frmDadosParametro').val();
	cdpartar = normalizaNumero(cdpartar);
	
	var cddopcao = $('#cddopcao','#frmCab').val();
	
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadbat/busca_dados_parametro.php", 
		data: {
			cddopcao: cddopcao,
			cdpartar: cdpartar,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					eval(response);
					hideMsgAguardo();					
				} catch(error) {
					hideMsgAguardo();
					showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
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
}

function buscaSequencial(){

	// Mostra mensagem de aguardo
	// showMsgAguardo("Aguarde, buscando novo c&oacute;digo...");

	// $.ajax({		
		// type: "POST",
		// url: UrlSite + "telas/cadgru/busca_sequencial.php", 
		// data: {
			// redirect: "script_ajax"
		// }, 
		// error: function(objAjax,responseError,objExcept) {
			// hideMsgAguardo();
			// showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		// },
		// success: function(response) {
			// try {
				// hideMsgAguardo();
				// eval(response);
			// } catch(error) {
				// hideMsgAguardo();
				// showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			// }
		// }				
	// });				
	
}


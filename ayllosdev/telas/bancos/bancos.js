/*!
 * FONTE        : bancos.js
 * CRIAÇÃo      : Jéssica (DB1) 
 * DATA CRIAÇÃO : 27/07/2015
 * OBJETIVO     : Biblioteca de funções da tela BANCOS
 * --------------
 * ALTERAÇÔES   : Alterado layout e incluido novos campos: flgoppag, dtaltstr e dtaltpag. 
 *                PRJ-312 (Reinert)
 *
 * ALTERAÇÔES   : 19/08/2016 - Adicionado dois novos filtros, codigo e nome do banco,
 *                             conforme solicitado no chamado 5044701. (Kelvin)
 * 
 *
 * --------------
 */
 
 //Formulários e Tabela
var frmCab   	= 'frmCab';
var frmConsulta = 'frmConsulta';
var divEntrada  = 'divEntrada';

var cddopcao, nmresbcc, cdbccxlt, nrispbif, flgdispb, dtinispb, nmextbcc, flgoppag, dtaltstr, dtaltpag,
    cTodosCabecalho, btnOK, cTodosConsulta, cTodosEntrada, nrcnpjif;

var rCddopcao, rNmresbcc, rCdbccxlt, rNrispbif, rFlgdispb, rDtinispb, rNmextbcc, rFlgoppag, rDtaltstr, rDtaltpag, rNrcnpjif,
    cCddopcao, cNmresbcc, cCdbccxlt, cNrispbif, cFlgdispb, cDtinispb, cNmextbcc, cFlgoppag, cDtaltstr, cDtaltpag, cNrcnpjif;
	
$(document).ready(function() {
	
	estadoInicial();
	
});

function carregaDados(){

	cddopcao = $('#cddopcao','#'+frmCab).val();
	nmresbcc = $('#nmresbcc','#'+frmConsulta).val();
	cdbccxlt = $('#cdbccxlt','#'+divEntrada).val();
	nrispbif = $('#nrispbif','#'+divEntrada).val();
	flgdispb = $('#flgdispb','#'+frmConsulta).val();
	dtinispb = $('#dtinispb','#'+frmConsulta).val();
	flgoppag = $('#flgoppag','#'+frmConsulta).val();
	nmextbcc = $('#nmextbcc','#'+frmConsulta).val();
	nrcnpjif = $('#nrcnpjif','#'+frmConsulta).val();
					                                                 
	return false;
	
} //carregaDados

// inicio
function estadoInicial() {

	$('#frmConsulta').limpaFormulario();
	$('#frmCab').limpaFormulario();
	
	formataCabecalho();
	formataConsulta();
	
	$('#btSalvar','#divBotoes').hide();
	$('#btVoltar','#divBotoes').hide();
	
    return false;
	
}

// formata
function formataCabecalho() {
	
	$('label[for="cddopcao"]','#frmCab').css('width','40px').addClass('rotulo');
	$('#cddopcao','#frmCab').css('width','570px');
	$('#divTela').css({'display':'inline'}).fadeTo(0,0.1);
	removeOpacidade('divTela');		
		
	btnOK =  $('#btnOK','#'+frmCab);	          
	rCddopcao = $('label[for="cddopcao"]','#'+frmCab);	
	cCddopcao = $('#cddopcao','#'+frmCab);
			
	rCddopcao.addClass('rotulo').css({'width':'80px'});
	cCddopcao.css({'width':'467px'});
			
	cCddopcao.habilitaCampo().focus().val('C');
	
	btnOK.unbind('click').bind('click', function() { 
		
		if(cCddopcao.hasClass('campoTelaSemBorda') ){
			return false;
		}
		
		if ( divError.css('display') == 'block' ) { return false; }		
		
		cCddopcao.desabilitaCampo();	
		
		controlaLayout();
			
	});
	
	cCddopcao.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }

		// Se é a tecla ENTER
		if ( e.keyCode == 13) {

			btnContinuar();
			return false;
		}

	});
	
	$('#frmConsulta').css('display','none');
	$('#divEntrada').css('display','none');
			
	highlightObjFocus( $('#frmCab') );
	highlightObjFocus( $('#frmConsulta') );
	highlightObjFocus( $('#divEntrada') );
		
	layoutPadrao();
	
	cCddopcao.focus();	
		
	return false;	
}

function controlaLayout() {
	
	$('#frmConsulta').css('display','none');
	$('#divEntrada').css('display','none');
	$('input,select').removeClass('campoErro');

	if(cCddopcao.val() == "C") {
	
		$('#frmConsulta').css('display','none');
		$('#divEntrada').css('display','block');
		
		$('#btVoltar','#divBotoes').show();
		$('#btSalvar','#divBotoes').show();
		$('#btLupaBanco','#divEntrada').show();
		$('#btLupaISPB','#divEntrada').show();
		
		cCdbccxlt.habilitaCampo();
		cNrispbif.habilitaCampo();

		cCdbccxlt.focus();
			
		controlaPesquisas('divEntrada');
		
	}else if(cCddopcao.val() == "I"){
		
		$('#frmConsulta').css('display','none');
		$('#divEntrada').css('display','block');
		
		$('#btVoltar','#divBotoes').show();
		$('#btSalvar','#divBotoes').show();
		$('#btLupaBanco','#divEntrada').hide();
		$('#btLupaISPB','#divEntrada').hide();
		
		cCdbccxlt.habilitaCampo();
		cNrispbif.habilitaCampo();
		cNmresbcc.desabilitaCampo();
		cNmextbcc.desabilitaCampo();
		cFlgdispb.desabilitaCampo();
		cDtinispb.desabilitaCampo();
		cFlgoppag.desabilitaCampo();
		cNrcnpjif.desabilitaCampo();	
		cCdbccxlt.focus();
	
	}else if(cCddopcao.val() == "A"){
	
		$('#frmConsulta').css('display','none');
		$('#divEntrada').css('display','block');
		
		$('#btVoltar','#divBotoes').show();
		$('#btSalvar','#divBotoes').show();
		$('#btLupaBanco','#divEntrada').show();
		$('#btLupaISPB','#divEntrada').show();
		
		cCdbccxlt.habilitaCampo();
		cNrispbif.habilitaCampo();
		cNmresbcc.desabilitaCampo();
		cNmextbcc.desabilitaCampo();
		cFlgdispb.desabilitaCampo();
		cDtinispb.desabilitaCampo();
		cFlgoppag.desabilitaCampo();
		cNrcnpjif.desabilitaCampo();
		cCdbccxlt.focus();

	}else if(cCddopcao.val() == "M"){
	
		$('#frmConsulta').css('display','none');
		$('#divEntrada').css('display','block');
		
		$('#btVoltar','#divBotoes').show();
		$('#btSalvar','#divBotoes').show();
		$('#btLupaBanco','#divEntrada').show();
		$('#btLupaISPB','#divEntrada').show();
		
		cCdbccxlt.habilitaCampo();
		cNrispbif.habilitaCampo();
		cNmresbcc.desabilitaCampo();
		cNmextbcc.desabilitaCampo();
		cFlgdispb.desabilitaCampo();
		cDtinispb.desabilitaCampo();
		cFlgoppag.desabilitaCampo();
		cNrcnpjif.desabilitaCampo();
		cCdbccxlt.focus();

		controlaPesquisas('divEntrada');

	}
					
	return false;
}


//botoes
function btnVoltar() {
	
	if($('#frmConsulta').css('display')=='block'){
		$('#frmConsulta').css('display','none').limpaFormulario();
		$('#frmCab').limpaFormulario();
		cCdbccxlt.habilitaCampo();
		cCdbccxlt.focus();
		cNrispbif.habilitaCampo();
		$('#btSalvar','#divBotoes').show();
	
	}else{
	
		estadoInicial();
		
	}
		
	return false;
}

function btnContinuar() { 
	
	if ( divError.css('display') == 'block' ) { return false; }		
	
			
	if ( cCddopcao.hasClass('campo') ) {
		btnOK.click();
		
	} else {
					
		$('#btSalvar','#divBotoes').focus();
				
		if(cCddopcao.val() == "C"){
	
			buscaBanco();

			cNrcnpjif.css({'text-align':'left'});
									
		}else if(cCddopcao.val() == "I"){
						
			if ( cCdbccxlt.hasClass('campoTelaSemBorda')  ) {
				
				$('#frmConsulta').css('display','block');
				
				cNmresbcc.focus();
				
				showConfirmacao('Confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','manterRotina();','','sim.gif','nao.gif');
                
			}else {
				
				$('#frmConsulta').css('display','block');

				rDtaltstr.hide();
				cDtaltstr.hide();
				rDtaltpag.hide();
				cDtaltpag.hide();
				
				cCdbccxlt.desabilitaCampo();
				cNrispbif.desabilitaCampo();
				
				cNmresbcc.habilitaCampo();
				cNmextbcc.habilitaCampo();
				cFlgdispb.habilitaCampo();
				cFlgoppag.habilitaCampo();
				cNrcnpjif.desabilitaCampo().css({'text-align':'left'});
				
				if (cFlgdispb.val() == 1){
					cDtinispb.habilitaCampo();
				}else{
					cDtinispb.val('');
					cDtinispb.desabilitaCampo();
				}
				cNmresbcc.focus();				
				
			}

				
		}else if(cCddopcao.val() == "A"){
															
			if ( cCdbccxlt.hasClass('campoTelaSemBorda')  ) {
				
				$('#frmConsulta').css('display','block');
				
				cNmresbcc.focus();
				
				showConfirmacao('Confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','manterRotina();','','sim.gif','nao.gif');

			}else {

				buscaBanco();

				if (cFlgdispb.val() == 1){
					cDtinispb.habilitaCampo();
				}else{
					cDtinispb.val('');
					cDtinispb.desabilitaCampo();
				}

				cNrcnpjif.desabilitaCampo().css({'text-align':'left'});
				nmresbcc.focus();
			}

			return false;

		}else if(cCddopcao.val() == "M"){
			
			if ( cCdbccxlt.hasClass('campoTelaSemBorda')  ) {
				
				cNrcnpjif.focus();
				$('#frmConsulta').css('display','block');
				
				showConfirmacao('Confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','manterRotina();','','sim.gif','nao.gif');
                
			}else {

				buscaBanco();	

				//$('#frmConsulta').css('display','block');

				rDtaltstr.hide();
				cDtaltstr.hide();
				rDtaltpag.hide();
				cDtaltpag.hide();
				
				cCdbccxlt.desabilitaCampo();
				cNrispbif.desabilitaCampo();
				
				cNmresbcc.desabilitaCampo();
				cNmextbcc.desabilitaCampo();
				cFlgdispb.desabilitaCampo();
				cFlgoppag.desabilitaCampo();
				cDtinispb.desabilitaCampo();
				
				cNrcnpjif.habilitaCampo().css({'text-align':'left'});
				cNrcnpjif.focus();
				
			}

		}
		
	}
							
	return false;

}

function buscaBanco() {
	
	showMsgAguardo('Aguarde, buscando Bancos...');
	
	if(cCddopcao.val() == "C"){
	
		$('#btSalvar','#divBotoes').hide();
		$('#btVoltar','#divBotoes').show();
		rDtaltstr.show();
		cDtaltstr.show();
		rDtaltpag.show();
		cDtaltpag.show();
		
	}else{
		rDtaltstr.hide();
		cDtaltstr.hide();
		rDtaltpag.hide();
		cDtaltpag.hide();
	}
				
	$('input,select').removeClass('campoErro');

	carregaDados();
			
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/bancos/busca_consulta_banco.php', 
		data    :
				{ 
				  cddopcao   : cddopcao,
				  cdbccxlt   : cdbccxlt,
				  nrispbif   : nrispbif,
				  redirect   : 'script_ajax'
				  				  
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
				},
		success : function(response) { 				
					hideMsgAguardo();
					try {
						eval( response );
						if(cCddopcao.val() == "M"){
							cNrcnpjif.trigger("focusin");
						}
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
					}
					
				}
	}); 
}

function manterRotina() {
	
	showMsgAguardo('Aguarde efetuando operacao...');
	
	$('#btSalvar','#divBotoes').show();
	$('#btVoltar','#divBotoes').show();
	
	$('input,select').removeClass('campoErro');

	carregaDados();
				
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/bancos/manter_rotina.php', 
		data    :
				{ 
				  cddopcao   : cddopcao,	
				  nmresbcc   : nmresbcc,
				  cdbccxlt   : cdbccxlt,
				  nrispbif   : nrispbif,
				  flgdispb   : flgdispb,
				  dtinispb   : dtinispb,
				  flgoppag   : flgoppag,
				  nmextbcc   : nmextbcc,
				  nrcnpjif   : normalizaNumero(nrcnpjif),
				  redirect   : 'script_ajax'					  
				  
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
				},
		success : function(response) { 
					
					hideMsgAguardo();
					try {
						eval( response );						
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
					}
					
				}
	});

}

function formataConsulta(){

	cTodosConsulta = $('input[type="text"],select','#divConsulta');
	cTodosEntrada = $('input[type="text"],select','#divEntrada');
	
	rCdbccxlt = $('label[for="cdbccxlt"]','#divEntrada');
	rNrispbif = $('label[for="nrispbif"]','#divEntrada');
	rNmresbcc = $('label[for="nmresbcc"]','#frmConsulta');
	rNmextbcc = $('label[for="nmextbcc"]','#frmConsulta');
	rFlgdispb = $('label[for="flgdispb"]','#frmConsulta');
	rFlgoppag = $('label[for="flgoppag"]','#frmConsulta');
	rDtinispb = $('label[for="dtinispb"]','#frmConsulta');
	rDtaltstr = $('label[for="dtaltstr"]','#frmConsulta');
	rDtaltpag = $('label[for="dtaltpag"]','#frmConsulta');	
	rNrcnpjif = $('label[for="nrcnpjif"]','#frmConsulta');
	
	cCdbccxlt = $('#cdbccxlt','#divEntrada');	
	cNrispbif = $('#nrispbif','#divEntrada');
	cNmresbcc = $('#nmresbcc','#frmConsulta');	
	cNmextbcc = $('#nmextbcc','#frmConsulta');
	cFlgdispb = $('#flgdispb','#frmConsulta');
	cFlgoppag = $('#flgoppag','#frmConsulta');
	cDtinispb = $('#dtinispb','#frmConsulta');
	cDtaltstr = $('#dtaltstr','#frmConsulta');
	cDtaltpag = $('#dtaltpag','#frmConsulta');
	cNrcnpjif = $('#nrcnpjif','#frmConsulta');
		
	rCdbccxlt.css({'width':'80px'}).addClass('rotulo');
	rNrispbif.css({'width':'100px'}).addClass('rotulo-linha');
	rNmresbcc.css({'width':'153px'}).addClass('rotulo');
	rNmextbcc.css({'width':'153px'}).addClass('rotulo');
	rFlgdispb.css({'width':'153px'}).addClass('rotulo');
	rFlgoppag.css({'width':'153px'}).addClass('rotulo');
	rDtinispb.css({'width':'87px'}).addClass('rotulo-linha');
	rDtaltstr.css({'width':'110px'}).addClass('rotulo-linha');
	rDtaltpag.css({'width':'275px'}).addClass('rotulo-linha');
	rNrcnpjif.css({'width':'153px'}).addClass('rotulo');
	
	cCdbccxlt.css({'width':'100px','text-align':'right'}).addClass('inteiro').attr('maxlength','3');
	cNrispbif.css({'width':'100px','text-align':'right'}).addClass('inteiro').attr('maxlength','8');
	cNmresbcc.css({'width':'150px'});
	cNmextbcc.css({'width':'250px'});
	cFlgdispb.css({'width':'60px'});
	cFlgoppag.css({'width':'60px'});
	cDtinispb.css({'width':'72px'}).addClass('data').val('');
	cDtaltstr.css({'width':'72px'}).addClass('data').val('');
	cDtaltpag.css({'width':'72px'}).addClass('data').val('');
	cNrcnpjif.css({'width':'250px'}).addClass('cnpj');
	
	cTodosConsulta.desabilitaCampo();
	cTodosEntrada.desabilitaCampo();
	
	cCdbccxlt.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false;}		
		// Se é a tecla ENTER, TAB
		if ( e.keyCode == 13  || e.keyCode == 9) {		
					
			$(this).removeClass('campoErro');
			cNrispbif.focus();
				
			return false;
		}
		
	});	
	
	cNrispbif.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }
				 
		// Se é a tecla ENTER, TAB
		if ( e.keyCode == 13  || e.keyCode == 9) {		
					
			$(this).removeClass('campoErro');
			
			btnContinuar();
			return false;
		}
		// Seta máscara ao campo
		return $(this).setMaskOnKeyUp("INTEGER","zzzzzzzzzzz","",e);
	});
	
	cNmresbcc.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false;}		
		// Se é a tecla ENTER, TAB
		if ( e.keyCode == 13  || e.keyCode == 9) {		
					
			$(this).removeClass('campoErro');
			cNmextbcc.focus();
				
			return false;
		}
		
	});
	
	cNmextbcc.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false;}		
		// Se é a tecla ENTER, TAB
		if ( e.keyCode == 13  || e.keyCode == 9) {		
					
			$(this).removeClass('campoErro');
			cFlgdispb.focus();
				
			return false;
		}
		
	});
	
	cFlgdispb.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false;}		
		// Se é a tecla ENTER, TAB
		if ( e.keyCode == 13  || e.keyCode == 9) {		
					
			$(this).removeClass('campoErro');
			
			if ($(this).val() == 1){
				cDtinispb.habilitaCampo();
				cDtinispb.focus();
			}else{
				cDtinispb.val('');
				cDtinispb.desabilitaCampo();
				cFlgoppag.focus();
			}			
				
			return false;
		}
		
	});
	
	cDtinispb.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }
				 
		// Se é a tecla ENTER, TAB
		if ( e.keyCode == 13  || e.keyCode == 9) {
			
			$(this).removeClass('campoErro');
			cFlgoppag.focus();			
			return false;
		}
				
	});
	
	cFlgoppag.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false;}		
		// Se é a tecla ENTER, TAB
		if ( e.keyCode == 13  || e.keyCode == 9) {		
					
			$(this).removeClass('campoErro');
			btnContinuar();				
			return false;
		}
		
	});
	
	layoutPadrao();
	
	return false;
}

function controlaSitSPB(){

	if (cFlgdispb.val() == 1){
		cDtinispb.habilitaCampo();
		cDtinispb.focus();
	}else{
		cDtinispb.val('');
		cDtinispb.desabilitaCampo();
		cFlgoppag.focus();
	}			

}

function controlaPesquisas(nomeFormulario){

	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdhiscxa;	
	
	var divRotina = 'divTela';
		
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');

	// Atribui a classe lupa para os links de desabilita todos
	$('a','#'+nomeFormulario).addClass('lupa').css('cursor','auto');
	
	// Percorrendo todos os links
	$('a','#'+nomeFormulario).each( function(i) {
	
		if ( !$(this).prev().hasClass('campoTelaSemBorda') ) $(this).css('cursor','pointer');
				
		$(this).unbind('click').bind('click', function() {
			if ( $(this).prev().hasClass('campoTelaSemBorda') ) {
				return false;
			} else {						
				campoAnterior = $(this).prev().attr('name');

				if ( campoAnterior == 'cdbccxlt' ) {
					
					bo			= 'BANCOS';
					procedure	= 'PESQUISABANCO';
					titulo      = 'Institui&ccedil;&atilde;o Financeira';
					qtReg		= '30';
					filtros = 'C&oacutedigo;cdbccxlt;100px;S;;S|Nome Abreviado;nmresbcc;150px;S;;S|ISPB;nrispbif;75px;N;;N'
					colunas 	= 'Banco;cdbccxlt;10%;left|Nome Abreviado;nmresbcc;40%;left|ISPB;nrispbif;20%;left|Operando no STR;flgdispb;25%;left';										
					mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,nomeFormulario);					
					/*$('#formPesquisa','#divPesquisa').css('display','none');*/
					$("#divCabecalhoPesquisa > table").css("width","600px");
					$("#divResultadoPesquisa > table").css("width","600px");
					$("#divCabecalhoPesquisa").css("width","600px");
					$("#divResultadoPesquisa").css("width","600px");
					$('#divPesquisa').centralizaRotinaH();
					
					return false;
					
				}else if ( campoAnterior == 'nrispbif' ) {
					
					bo			= 'BANCOS';
					procedure	= 'PESQUISABANCO';
					titulo      = 'Institui&ccedil;&atilde;o Financeira';
					qtReg		= '30';
					filtros 	= 'C&oacutedigo;cdbccxlt;30px;N;;N|Nome Abreviadoo;nmresbcc;30px;N;;N|ISPB;nrispbif;75px;S;;S'
					colunas 	= 'Banco;cdbccxlt;10%;left|Nome Abreviado;nmresbcc;40%;left|ISPB;nrispbif;20%;left|Operando no STR;flgdispb;25%;left';										
					mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,nomeFormulario);					
					/*$('#formPesquisa','#divPesquisa').css('display','none');*/
					$("#divCabecalhoPesquisa > table").css("width","600px");
					$("#divResultadoPesquisa > table").css("width","600px");
					$("#divCabecalhoPesquisa").css("width","600px");
					$("#divResultadoPesquisa").css("width","600px");
					$('#divPesquisa').centralizaRotinaH();
					
					return false;
					
				}	
				
			}
		});
	});
	
	return false;
	
}

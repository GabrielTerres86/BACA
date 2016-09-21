/*!
 * FONTE        : bancos.js
 * CRIAÇÃo      : Jéssica (DB1) 
 * DATA CRIAÇÃO : 27/07/2015
 * OBJETIVO     : Biblioteca de funções da tela BANCOS
 * --------------
 * ALTERAÇÔES   :
 * 
 *
 * --------------
 */
 
 //Formulários e Tabela
var frmCab   	= 'frmCab';
var frmConsulta = 'frmConsulta';
var frmEntrada  = 'frmEntrada';

var cddopcao, nmresbcc, cdbccxlt, nrispbif, flgdispb, dtinispb, nmextbcc,
    cTodosCabecalho, btnOK, cTodosConsulta, cTodosEntrada;

var rCddopcao, rNmresbcc, rCdbccxlt, rNrispbif, rFlgdispb, rDtinispb, rNmextbcc, 
    cCddopcao, cNmresbcc, cCdbccxlt, cNrispbif, cFlgdispb, cDtinispb, cNmextbcc;
	
$(document).ready(function() {
	
	estadoInicial();
		
});

function carregaDados(){

	cddopcao = $('#cddopcao','#'+frmCab).val();
	nmresbcc = $('#nmresbcc','#'+frmConsulta).val();  
	cdbccxlt = $('#cdbccxlt','#'+frmEntrada).val();                                             
	nrispbif = $('#nrispbif','#'+frmEntrada).val();
	flgdispb = $('#flgdispb','#'+frmConsulta).val();                                            
	dtinispb = $('#dtinispb','#'+frmConsulta).val();
	nmextbcc = $('#nmextbcc','#'+frmConsulta).val();
					                                                 
	return false;
	
} //carregaDados

// inicio
function estadoInicial() {

	$('#frmConsulta').limpaFormulario();
	$('#frmEntrada').limpaFormulario();
	
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
	$('#frmEntrada').css('display','none');
			
	highlightObjFocus( $('#frmCab') );
	highlightObjFocus( $('#frmConsulta') );
	highlightObjFocus( $('#frmEntrada') );
		
	layoutPadrao();
	
	cCddopcao.focus();	
		
	return false;	
}

function controlaLayout() {
	
	$('#frmConsulta').css('display','none');
	$('#frmEntrada').css('display','none');
	$('input,select').removeClass('campoErro');

	if(cCddopcao.val() == "C") {
	
		$('#frmConsulta').css('display','none');
		$('#frmEntrada').css('display','block');
		
		$('#btVoltar','#divBotoes').show();
		$('#btSalvar','#divBotoes').show();
		
		cCdbccxlt.habilitaCampo();
		cNrispbif.habilitaCampo();

		cCdbccxlt.focus();
			
		controlaPesquisas('frmEntrada');
		
	}else if(cCddopcao.val() == "I"){
		
		$('#frmConsulta').css('display','none');
		$('#frmEntrada').css('display','block');
		
		$('#btVoltar','#divBotoes').show();
		$('#btSalvar','#divBotoes').show();
		
		cCdbccxlt.habilitaCampo();
		cNrispbif.habilitaCampo();
		cNmresbcc.desabilitaCampo();
		cNmextbcc.desabilitaCampo();
		cFlgdispb.desabilitaCampo();
		cDtinispb.desabilitaCampo();
		cCdbccxlt.focus();
	
	}else if(cCddopcao.val() == "A"){
	
		$('#frmConsulta').css('display','none');
		$('#frmEntrada').css('display','block');
		
		$('#btVoltar','#divBotoes').show();
		$('#btSalvar','#divBotoes').show();
		
		cCdbccxlt.habilitaCampo();
		cNrispbif.habilitaCampo();
		cNmresbcc.desabilitaCampo();
		cNmextbcc.desabilitaCampo();
		cFlgdispb.desabilitaCampo();
		cDtinispb.desabilitaCampo();
		cCdbccxlt.focus();
			
	}
					
	return false;
}


//botoes
function btnVoltar() {
	
	if($('#frmConsulta').css('display')=='block'){
		$('#frmConsulta').css('display','none').limpaFormulario();
		$('#frmEntrada').limpaFormulario();
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
									
		}else if(cCddopcao.val() == "I"){
						
			if ( cCdbccxlt.hasClass('campoTelaSemBorda')  ) {
				
				$('#frmConsulta').css('display','block');
				
				cNmresbcc.focus();
				
				showConfirmacao('Confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','manterRotina();','','sim.gif','nao.gif');
												
								
			}else {
				
				$('#frmConsulta').css('display','block');
												
				cCdbccxlt.desabilitaCampo();
				cNrispbif.desabilitaCampo();
				cNmresbcc.habilitaCampo();
				cNmextbcc.habilitaCampo();
				cFlgdispb.habilitaCampo();
				cDtinispb.habilitaCampo();
				cNmresbcc.focus();				
				
			}

				
		}else if(cCddopcao.val() == "A"){
															
			if ( cCdbccxlt.hasClass('campoTelaSemBorda')  ) {
				
				$('#frmConsulta').css('display','block');
				
				cNmresbcc.focus();
				
				showConfirmacao('Confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','manterRotina();','','sim.gif','nao.gif');
												
								
			}else {
								
				buscaBanco();
				
			}
						
			return false;
						
		}
		
	}
							
	return false;

}

function buscaBanco() {
	
	showMsgAguardo('Aguarde, buscando Bancos...');
	
	if(cCddopcao.val() == "C"){
	
		$('#btSalvar','#divBotoes').hide();
		$('#btVoltar','#divBotoes').show();
		
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
				  nmextbcc   : nmextbcc,		
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
	
	rNmresbcc = $('label[for="nmresbcc"]','#frmConsulta');
	rCdbccxlt = $('label[for="cdbccxlt"]','#frmEntrada');
	rNrispbif = $('label[for="nrispbif"]','#frmEntrada');
	rFlgdispb = $('label[for="flgdispb"]','#frmConsulta');
	rDtinispb = $('label[for="dtinispb"]','#frmConsulta');
	rNmextbcc = $('label[for="nmextbcc"]','#frmConsulta');
	
	
	cNmresbcc = $('#nmresbcc','#frmConsulta');	
	cCdbccxlt = $('#cdbccxlt','#frmEntrada');	
	cNrispbif = $('#nrispbif','#frmEntrada');
	cFlgdispb = $('#flgdispb','#frmConsulta');
	cDtinispb = $('#dtinispb','#frmConsulta');
	cNmextbcc = $('#nmextbcc','#frmConsulta');
	
		
	rNmresbcc.css({'width':'103px'});
	rCdbccxlt.css({'width':'103px'});
	rNrispbif.css({'width':'100px'});
	rFlgdispb.css({'width':'103px'});
	rDtinispb.css({'width':'191px'});
	rNmextbcc.css({'width':'101px'});
		
	
	cNmresbcc.css({'width':'150px'});
	cCdbccxlt.css({'width':'100px','text-align':'right'}).addClass('inteiro').attr('maxlength','3');
	cNrispbif.css({'width':'100px','text-align':'right'}).addClass('inteiro').attr('maxlength','8');
	cFlgdispb.css({'width':'60px'});
	cDtinispb.css({'width':'100px'}).addClass('data').val('');
	cNmextbcc.css({'width':'250px'});
		
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
			cDtinispb.focus();
				
			return false;
		}
		
	});
	
	cDtinispb.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }
				 
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
					titulo      = 'Bancos';
					qtReg		= '30';
					filtros 	= 'C&oacutedigo;cdbccxlt;30px;N;0;N|Nome Abreviadoo;nmresbcc;30px;N;0;N|ISPB;nrispbif;30px;N;0;N'	
					colunas 	= 'Banco;cdbccxlt;10%;left|Nome Abreviado;nmresbcc;40%;left|ISPB;nrispbif;20%;left|Operando no SPB;flgdispb;25%;left';										
					mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,nomeFormulario);					
					$('#formPesquisa','#divPesquisa').css('display','none');
					$("#divCabecalhoPesquisa > table").css("width","600px");
					$("#divResultadoPesquisa > table").css("width","600px");
					$("#divCabecalhoPesquisa").css("width","600px");
					$("#divResultadoPesquisa").css("width","600px");
					$('#divPesquisa').centralizaRotinaH();
					
					return false;
					
				}else if ( campoAnterior == 'nrispbif' ) {
					
					bo			= 'BANCOS';
					procedure	= 'PESQUISABANCO';
					titulo      = 'Bancos';
					qtReg		= '30';
					filtros 	= 'C&oacutedigo;cdbccxlt;30px;N;0;N|Nome Abreviadoo;nmresbcc;30px;N;0;N|ISPB;nrispbif;30px;N;0;N'
					colunas 	= 'Banco;cdbccxlt;10%;left|Nome Abreviado;nmresbcc;40%;left|ISPB;nrispbif;20%;left|Operando no SPB;flgdispb;25%;left';										
					mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,nomeFormulario);					
					$('#formPesquisa','#divPesquisa').css('display','none');
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

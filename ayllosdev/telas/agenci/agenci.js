/*!
 * FONTE        : agenci.js
 * CRIAÇÃO      : David Kruger
 * DATA CRIAÇÃO : 04/02/2013
 * OBJETIVO     : Biblioteca de funções da tela AGENCI
 * --------------
 * ALTERAÇÕES   : 08/01/2014 - Ajustes para homologação (Adriano)
 * ALTERAÇÕES   : 30/08/2016 - Removido a coluna DIG da pesquisa por agências da tela AGENCI (Andrey)
 *				  
 *				  06/09/2016 - Adicionado filtro pelo nome da agencia e do banco, conforme solicitado
 *  						   no chamado 504477 (Kelvin).
 *				  
 * --------------
 */

$(document).ready(function() {

	estadoInicial();
	
	highlightObjFocus( $('#frmCab') );
	
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	
	return false;
	
	
});

function estadoInicial() {

	$('#frmCab').css({'display':'block'});
	$('#frmAgencia').css({'display':'none'});
	$('#tabFeriados').css({'display':'none'});
	
	$('#divBotoes', '#divTela').html('').css({'display':'block'});
		
	formataCabecalho();
	
	return false;
	
}

function controlaFoco() {
		
	$('#cddopcao','#frmCab').unbind('keypress').bind('keypress', function(e) {
	
		if ( divError.css('display') == 'block' ) { return false; }
		
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#cddopcao','#frmCab').desabilitaCampo();
			$('#cddbanco','#frmCab').habilitaCampo();
			$('#cddbanco','#frmCab').focus();
			trocaBotao('btnContinuar()','estadoInicial()');
			return false;
		}	
	});
	
	$('#btnOK','#frmCab').unbind('keypress').bind('keypress', function(e) {
		
		if ( divError.css('display') == 'block' ) { return false; }
		
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#cddopcao','#frmCab').desabilitaCampo();
			$('#cddbanco','#frmCab').habilitaCampo();
			$('#cddbanco','#frmCab').focus();
			trocaBotao('btnContinuar()','estadoInicial()');
			return false;
		}	
	});
	
	$('#btnOK','#frmCab').unbind('click').bind('click', function(){
	
		if ( divError.css('display') == 'block' ) { return false; }
		
		$('#cddopcao','#frmCab').desabilitaCampo();
		$('#cddbanco','#frmCab').habilitaCampo();
		$('#cddbanco','#frmCab').focus();
		trocaBotao('btnContinuar()','estadoInicial()');
		return false;
			
	});
	
	
	$('#cddbanco','#frmCab').unbind('keypress').bind('keypress', function(e) {
	
		if ( divError.css('display') == 'block' ) { return false; }
	
		if ( e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 118 ) {	
			btnContinuar();
			return false;
		}

	});
				
	return false;
	
}

function formataCabecalho() {

	$('input,select', '#frmCab').removeClass('campoErro');
	$('#divTela').css({'display':'inline'}).fadeTo(0,0.1);
	removeOpacidade('divTela');	
	
	cTodosCabecalho = $('input[type="text"],select','#frmCab'); 
	cTodosCabecalho.limpaFormulario();
	
	// cabecalho
	rCddopcao			= $('label[for="cddopcao"]','#frmCab'); 
	rCddbanco			= $('label[for="cddbanco"]','#frmCab');  
	
	cCddopcao			= $('#cddopcao','#frmCab'); 
	
	cCddbanco			= $('#cddbanco','#frmCab'); 
	cNmextbcc			= $('#nmextbcc','#frmCab'); 
			
	//Rótulos
	rCddopcao.css('width','44px');
	rCddbanco.addClass('rotulo-linha').css({'width':'41px'});
	
	//Campos	
	cCddopcao.css({'width':'496px'}).habilitaCampo().focus();
	cCddbanco.addClass('inteiro').css({'width':'100px'}).attr('maxlength','5').desabilitaCampo();
	
	cNmextbcc.addClass('alphanum').css({'width':'373px'}).attr('maxlength','50').desabilitaCampo();
	
	if ( $.browser.msie ) {
	
		rCddbanco.css({'width':'44px'});
		cCddbanco.css({'width':'101px'});
		cNmextbcc.css({'width':'371px'});		
	}	
	
	controlaFoco();
	layoutPadrao();
	
	return false;	
	
}

//Formata form_agencia
function formataAgencia(){

	highlightObjFocus($('#frmAgencia')); 
	cddopcao = $('#cddopcao','#frmCab').val();
	
	// cabecalho dados agencias
	rCdageban			= $('label[for="cdageban"]','#frmAgencia'); 
	rDgagenci			= $('label[for="dgagenci"]','#frmAgencia');  
	rNmageban			= $('label[for="nmageban"]','#frmAgencia');
	rCdsitagb			= $('label[for="cdsitagb"]','#frmAgencia');
	rCdcompen			= $('label[for="cdcompen"]','#frmAgencia');
	rNmcidade			= $('label[for="nmcidade"]','#frmAgencia');
	rCdufresd			= $('label[for="cdufresd"]','#frmAgencia');
	
	cCdageban			= $('#cdageban','#frmAgencia'); 
	cCddbanco			= $('#cddbanco','#frmCab'); 
	cDgagenci			= $('#dgagenci','#frmAgencia'); 
	cNmageban			= $('#nmageban','#frmAgencia'); 
	cCdsitagb			= $('#cdsitagb','#frmAgencia'); 
	cCdcompen			= $('#cdcompen','#frmAgencia'); 
	cNmcidade			= $('#nmcidade','#frmAgencia'); 
	cCdufresd			= $('#cdufresd','#frmAgencia'); 
	
	cTabferiados		= $('#tabConteudo','#frmFeriados');
	
	cTodosAgenci		= $('input[type="text"], select','#frmAgencia');

	//Labels
	rCdageban.addClass('rotulo').css({'width':'100px'});
	rDgagenci.addClass('rotulo-linha').css({'width':'214px'});
	rNmageban.addClass('rotulo').css({'width':'100px'});
	rCdsitagb.addClass('rotulo').css({'width':'100px'});
	rCdcompen.addClass('rotulo-linha').css({'width':'284px'});
	rNmcidade.addClass('rotulo').css({'width':'100px'});
	rCdufresd.addClass('rotulo-linha').css({'width':'135px'});
	
	//Campos
	cCdageban.addClass('inteiro').css({'width':'100px'}).attr('maxlength','5');	
	cDgagenci.addClass('inteiro').css({'width':'50px'}); 
	cNmageban.addClass('alphanum').css({'width':'390px'}).attr('maxlength','50');
	cCdsitagb.css({'width':'50px'});
	cCdcompen.addClass('inteiro').css({'width':'50px'});
	cNmcidade.addClass('alphanum').css({'width':'200px'});
	cCdufresd.addClass('alphanum').css({'width':'50px'});
	
	cTabferiados.css({'width':'385px','margin-left':'102px', 'margin-right':'100px'});
	
	if ( $.browser.msie ) {
		rCdageban.css({'width':'100px'});
		rDgagenci.css({'width':'214px'});
		rNmageban.css({'width':'99px'});
		rCdsitagb.css({'width':'100px'});
		rCdcompen.css({'width':'284px'});
		rNmcidade.css({'width':'100px'});
		rCdufresd.css({'width':'135px'});
		
		cCdageban.css({'width':'100px'});
		cDgagenci.css({'width':'50px'});
		cNmageban.css({'width':'388px'}).attr('maxlength','50');
		cCdsitagb.css({'width':'50px'});
		cCdcompen.css({'width':'50px'});
		cNmcidade.css({'width':'200px'});
		cCdufresd.css({'width':'50px'});
		
		cTabferiados.css({'width':'390px','margin-left':'102px', 'margin-right':'100px'});
	}	
	
	cTodosAgenci.desabilitaCampo();
	
	$('#cddbanco','#frmCab').desabilitaCampo();
	$('#cdageban','#frmCab').habilitaCampo();
	$('#cddopcao','#frmCab').desabilitaCampo();
	
	$('#cdageban','#frmAgencia').focus();
	
	
	$('#cdageban','#frmAgencia').unbind('keypress').bind('keypress', function(e) {
	
		if ( divError.css('display') == 'block' ) { return false; }
		
		if ( e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 118 ) {	
			btnAvancar();
			return false;
		}	
	});
	
	$('#dgagenci','#frmAgencia').unbind('keypress').bind('keypress', function(e) {
	
		if ( divError.css('display') == 'block' ) { return false; }
		
		if ( e.keyCode == 13 || e.keyCode == 9 ) {	
			$('#nmageban','#frmAgencia').focus();
			return false;
		}	
		
	});
	
	$('#nmageban','#frmAgencia').unbind('keypress').bind('keypress', function(e) {
	
		if ( divError.css('display') == 'block' ) { return false; }
		
		if ( e.keyCode == 13 || e.keyCode == 9 ) {	
			$('#cdsitagb','#frmAgencia').focus();
			return false;
		}	
		
	});
	
	$('#cdsitagb','#frmAgencia').unbind('keypress').bind('keypress', function(e) {
		
		if ( e.keyCode == 13 || e.keyCode == 9 ) {	
		
			$('#btSalvar','#divBotoes').click();
			return false;
		}
		
	}); 	
	
    layoutPadrao();
	
	return false;	

}

function formataTabela() {
	
	// tabela
	var divRegistro = $('div.divRegistros', '#tabFeriados');		
	var tabela      = $('table', divRegistro );
	
	$('#tabFeriados').css({'margin-top':'5px'});
	divRegistro.css({'height':'100px','padding-bottom':'2px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '250px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'center';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);

	$('#divPesquisaRodape', '#divTela').css({'display':'block'});
	return false;
	
}

function controlaCampos(op) {

    var cTodosCabecalho	= $('input[type="text"],select','#frmCab'); 
	
	cTodosCabecalho.desabilitaCampo();

	switch(op){
	
		case 'A':
		
			$('#dgagenci','#frmAgencia').habilitaCampo();
			$('#nmageban','#frmAgencia').habilitaCampo();
			$('#cdsitagb','#frmAgencia').habilitaCampo();
			trocaBotao('showConfirmacao(\'Confirma a operacao?\',\'Confirma&ccedil;&atilde;o - Ayllos\',\'alteraAgencia();\',\'btnVoltar(\\\'V2\\\');\',\'sim.gif\',\'nao.gif\')','btnVoltar(\'V2\')');
						
		break;

		
		case 'I':
			
			$('#dgagenci','#frmAgencia').habilitaCampo();
			$('#nmageban','#frmAgencia').habilitaCampo();
			$('#cdsitagb','#frmAgencia').habilitaCampo();
			trocaBotao("showConfirmacao('Confirma a operacao?','Confirma&ccedil;&atilde;o - Ayllos','novaAgencia();','btnVoltar(\\\'V2\\\');','sim.gif','nao.gif');","btnVoltar('V2')");
		
		break;
		
		case 'E':
		
			trocaBotao("showConfirmacao('Confirma a operacao?','Confirma&ccedil;&atilde;o - Ayllos','deletaAgencia();btnVoltar(\\\'V2\\\');','','sim.gif','nao.gif');","btnVoltar('V2')");
			$('#btSalvar','#divBotoes').css('display','none');
			$('#btSalvar','#divBotoes').click();
			
		break;
		
		default:
			trocaBotao('','btnVoltar(\'V2\')');
			$('#btSalvar','#divBotoes').css('display','none');
			
		break;
		
	}
	
	return false;
	
}


function btnVoltar(op){
	
	if(op == 'V1'){
	
		$('#frmAgencia').css('display','none');
		$('#tabFeriados').css('display','none');
		$('#cddbanco','#frmCab').habilitaCampo().focus().val('');
		$('#nmextbcc','#frmCab').val('');
		trocaBotao('btnContinuar()','estadoInicial()');
		
	}else{
	
		$('#tabFeriados').css('display','none');
		$('input, select', '#frmAgencia').val('');
		$('#cdageban','#frmAgencia').habilitaCampo().focus();
		$('#dgagenci','#frmAgencia').desabilitaCampo();
		$('#nmageban','#frmAgencia').desabilitaCampo();
		$('#cdsitagb','#frmAgencia').desabilitaCampo();
		
		trocaBotao('btnAvancar()','btnVoltar(\'V1\')');
		
	}
	
	return false;
	
}

function btnContinuar() {

    cddbanco = $('#cddbanco','#frmCab').val();
	cddopcao = $('#cddopcao','#frmCab').val();
		
	if(cddbanco != '' ){
		buscaBanco(cddopcao);
	}else{
		controlaPesquisa(1);
	}
	
	return false;
	
}

function btnAvancar(){
	
	var cdageban;

	cdageban = $('#cdageban','#frmAgencia').val();
	
	if(cdageban > 0){
	  buscaAgencia();
	}
	else{
		controlaPesquisa(2);
	}
	
	return false;
	
}

function trocaBotao( funcaoSalvar,funcaoVoltar ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onClick="'+funcaoVoltar+'; return false;" >Voltar</a>&nbsp;');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onClick="'+funcaoSalvar+'; return false;">Prosseguir</a>');
	
	return false;
}


function deletaAgencia() {

	$("input, select","#frmAgencia").removeClass("campoErro");

	showMsgAguardo("Aguarde, excluindo dados...");
	
	var cddbanco = $('#cddbanco','#frmCab').val();
	var cdageban = $('#cdageban','#frmAgencia').val();
	var dgagenci = $('#dgagenci','#frmAgencia').val();
	var nmageban = $('#nmageban','#frmAgencia').val();
	var cdsitagb = $('#cdsitagb','#frmAgencia').val();
	
	cddopcao = $('#cddopcao','#frmCab').val();
	
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/agenci/manter_rotina.php", 
		data: {
			cdageban: cdageban,
			cddbanco: cddbanco,
			dgagenci: dgagenci,
			nmageban: nmageban,
			cdsitagb: cdsitagb,
			cddopcao: cddopcao,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divTela').css('z-index')))");
		},
		success: function(response) {
				try {
					eval(response);
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
				}
			}
	});				
}


function novaAgencia() {
	
	$("input, select","#frmAgencia").removeClass("campoErro");

	showMsgAguardo("Aguarde, incluindo dados...");
	
	var cddbanco = $('#cddbanco','#frmCab').val();
	var cdageban = $('#cdageban','#frmAgencia').val();
	var dgagenci = $('#dgagenci','#frmAgencia').val();
	var nmageban = $('#nmageban','#frmAgencia').val();
	var cdsitagb = $('#cdsitagb','#frmAgencia').val();
	
	cddopcao = $('#cddopcao','#frmCab').val();	
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/agenci/manter_rotina.php", 
		data: {
			cdageban: cdageban,
			cddbanco: cddbanco,
			dgagenci: dgagenci,
			nmageban: nmageban,
			cdsitagb: cdsitagb,
			cddopcao: cddopcao,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divTela').css('z-index')))");
		},
		success: function(response) {
				try {
					eval(response);
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
				}
			}
	});				
}


function buscaBanco(op) {

	var cddbanco = $('#cddbanco','#frmCab').val();
	
	showMsgAguardo("Aguarde, buscando banco...");
	
	$('#cddbanco','#frmCab').removeClass('campoErro');
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/agenci/busca_banco.php", 
		data: {
			cddbanco: cddbanco,
			cddopcao: op,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divTela').css('z-index')))");
		},
		success : function(response) {
					hideMsgAguardo();
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try { 
							$('#divAgencia').html(response);
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
}


function buscaAgencia() {

	var cdageban = $('#cdageban','#frmAgencia').val();
	var cddbanco = $('#cddbanco','#frmCab').val();
	var cddopcao = $('#cddopcao','#frmCab').val();
	
	showMsgAguardo("Aguarde, buscando agencia...");
	
	$('#cdageban','#frmAgencia').removeClass('campoErro');
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/agenci/busca_agencia.php", 
		data: {
			cdageban: cdageban,
			cddbanco: cddbanco,
			cddopcao: cddopcao,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divTela').css('z-index')))");
		},
		success : function(response) {
					hideMsgAguardo();
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try { 
							$('#divAgencia').html(response);
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
}


function alteraAgencia() {

	$("input, select","#frmAgencia").removeClass("campoErro");
	
	showMsgAguardo("Aguarde, alterando dados...");
	
	var cddbanco = $('#cddbanco','#frmCab').val();
	var cdageban = $('#cdageban','#frmAgencia').val();
	var dgagenci = $('#dgagenci','#frmAgencia').val();
	var nmageban = $('#nmageban','#frmAgencia').val();
	var cdsitagb = $('#cdsitagb','#frmAgencia').val();
	
	cddopcao = $('#cddopcao','#frmCab').val();	
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/agenci/manter_rotina.php", 
		data: {
		    cddopcao: cddopcao,
			cdageban: cdageban,
			cddbanco: cddbanco,
			dgagenci: dgagenci,
			nmageban: nmageban,
			cdsitagb: cdsitagb,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divTela').css('z-index')))");
		},
		success: function(response) {
				try {
					eval(response);
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
				}
			}		
	});				
}

function controlaPesquisa(valor){

	switch(valor){
	
		case 1:
			controlaPesquisaBanco();
		break;
		
		case 2:
			controlaPesquisaAgencia();
		break;
		
	}
	
}

function controlaPesquisaBanco(){

	// Se esta desabilitado o campo 
	if ($("#cddbanco","#frmCab").prop("disabled") == true)  {
		return;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, titulo_coluna;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmCab';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cddbanco = $('#cddbanco','#frmCab').val();
	
	bo			= 'b1wgen0149.p';
	procedure	= 'busca-banco';
	titulo      = 'Banco';
	qtReg		= '30';					
	filtrosPesq	= 'Código;cddbanco;50px;S;' + cddbanco+ ';S|Nome;nmextbcc;150px;S;;S;';
	colunas 	= 'Código;cddbanco;35%;right|Nome;nmextbcc;65%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas,'','$(\'#cddbanco\',\'#frmCab\').focus();',nomeFormulario);
	
	return false;
	
}



function controlaPesquisaAgencia(){

	// Se esta desabilitado o campo 
	if ($("#cdageban","#frmAgencia").prop("disabled") == true)  {
		return;
	}
	
	//Guarda informações de layout usados para mostrar a tabela de pesquisa
	var divPesqLeft = $("#divPesquisa").css("left");
	var divPesqTop = $("#divPesquisa").css("top");
	var divCabPesqTableWidth = $("#divCabecalhoPesquisa > table").css("width");
	var divCabPesqTableFloat = $("#divCabecalhoPesquisa > table").css("float");
	var divResulPesqTableWidth = $("#divResultadoPesquisa > table").css("width");
	var divCabPesqWidth = $("#divCabecalhoPesquisa").css("width");
	var divResulPesqWidth = $("#divResultadoPesquisa").css("width");
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, titulo_coluna;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmAgencia';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cddbanco = $('#cddbanco','#frmCab').val();
	var cdageban = $('#cdageban','#frmAgencia').val();
	
	bo			= 'b1wgen0149.p';
	procedure	= 'busca-agencia';
	titulo      = 'Agência';
	qtReg		= '30';	

	filtrosPesq = 'Banco;cddbanco;30px;N;' + cddbanco + ';N;|Código;cdageban;50px;S;' + cdageban + ';S;|Nome;nmageban;150px;S;;S;';
	colunas = 'Banco;cddbanco;10%;right|Agencia;cdageban;10%;center|Nome;nmageban;60%;center|Ativa;cdsitagb;10%;right';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas,'','formataDivPesquisa("' + divPesqLeft + '","' + divPesqTop + '","' + divCabPesqTableWidth + '","' + divCabPesqTableFloat + '","' + divResulPesqTableWidth + '","' + divCabPesqWidth + '","' + divResulPesqWidth + '");',nomeFormulario);
	
	//Ajusta o tamanho da tabela de pesquisa
	$("#divPesquisa").css("left","258px"); 
	$("#divPesquisa").css("top","91px");   
	$("#divCabecalhoPesquisa > table").css("width","675px"); 
	$("#divCabecalhoPesquisa > table").css("float","left"); 
	$("#divResultadoPesquisa > table").css("width","690px");
	$("#divCabecalhoPesquisa").css("width","690px"); 
	$("#divResultadoPesquisa").css("width","690px"); 
	
	return false;
	
}

//Função para alterar o layout da tabela de pesquisa com os valores que foram armazenados em variáveis
//na função controlaPesquisaAgencia.
function formataDivPesquisa(divPesqLeft,divPesqTop,divCabPesqTableWidth,divCabPesqTableFloat,divResulPesqTableWidth,divCabPesqWidth,divResulPesqWidth){

	$('#cdageban','#frmAgencia').focus();
	
	$("#divPesquisa").css("left",'' + divPesqLeft + ''); 
	$("#divPesquisa").css("top",'' + divPesqTop + '');   
	$("#divCabecalhoPesquisa > table").css("width",'' + divCabPesqTableWidth + ''); 
	$("#divCabecalhoPesquisa > table").css("float",'' + divCabPesqTableFloat + ''); 
	$("#divResultadoPesquisa > table").css("width",'' + divResulPesqTableWidth + ''); 
	$("#divCabecalhoPesquisa").css("width",'' + divCabPesqWidth + ''); 
	$("#divResultadoPesquisa").css("width",'' + divResulPesqWidth + ''); 
	
	return false;
	
}
/*!
 * FONTE        : hrcomp.js
 * CRIAÇÃO      : Tiago Machado          
 * DATA CRIAÇÃO : 24/02/2014
 * OBJETIVO     : Biblioteca de funções da tela HRCOMP
 * --------------
 * ALTERAÇÕES   : 25/07/2014 - Retirado tratamento para quando a coop fosse zero (Tiago/Aline)
 * --------------
 */

// Definição de algumas variáveis globais 
var cddopcao		= 'C';
	
//Formulários
var frmCab   		= 'frmCab';
var frmDet          = 'frmDet';

//Labels/Campos do cabeçalho
var rCddopcao, rCdcoopex, cCddopcao, cCdcoopex, cTodosCabecalho, btnCab;
var glbTabNmproces, glbTabFlgativo, glbTabAgeinihr, glbTabAgefimhr;

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
	$('#frmDet').css({'display':'block'});
	$('#divBotoes').css({'display':'none'});
	
	trocaBotao('');
		
	formataCampos();
		
	cTodosCabecalho.limpaFormulario();
	cCddopcao.val( cddopcao );
	
	removeOpacidade('divTela');	
	unblockBackground();
	hideMsgAguardo();
	
	$('#cdcoopex','#frmDet').desabilitaCampo();	
	$('#cdcoopex','#frmDet').hide();	
	$('label[for="cdcoopex"]','#frmDet').hide();
	
	$('#divProcessos').html('');
	
	trocaBotao('');
	$("#btVoltar","#divBotoes").hide();
	
	$('input,select', '#frmCab').removeClass('campoErro');
	$('input,select', '#frmDet').removeClass('campoErro');	
	
	carregaCooperativas();
	
	controlaFoco();
		
}

function controlaFoco() {

	$('#cdcoopex','#frmDet').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				LiberaCampos();
				return false;
			}
	});
	
	$('#btnOK','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				LiberaCampos();
				$('#cdcoopex','#frmDet').focus();
				return false;
			}	
	});
	
	$('#cdcoopex','#frmDet').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 13 || e.keyCode == 9 ) {	
				if ( $('#cdcoopex','#frmDet').val() == '0' ) {
					return false;
				} else {
					btnContinuar(); 
					return false;
				}		
			}	
	});
	
}

function formataCampos() {

	// cabecalho
	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab); 
	rCdcoopex			= $('label[for="cdcoopex"]','#'+frmDet); 
	
	cCddopcao			= $('#cddopcao','#'+frmCab); 
	cCdcoopex			= $('#cdcoopex','#'+frmDet); 	
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	btnCab				= $('#btOK','#'+frmCab);
	
	rCddopcao.css('width','44px');
	rCdcoopex.addClass('rotulo-linha').css({'width':'41px'});
	
	cCddopcao.css({'width':'460px'});
	cCdcoopex.css({'width':'460px'});	
	
	if ( $.browser.msie ) {
		rCdcoopex.css({'width':'44px'});		
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
	
	$('#cdcoopex','#frmDet').show();
	$('label[for="cdcoopex"]','#frmDet').show();
	$('#cdcoopex','#frmDet').habilitaCampo();
			
	$('#divBotoes', '#divTela').css({'display':'block'});
	
	$("#btSalvar","#divBotoes").show();
	$("#btVoltar","#divBotoes").show();
	
	trocaBotao( 'Prosseguir');
	
	$('#cdcoopex','#frmDet').focus();

	return false;
}

function btnContinuar() {

	$('input,select', '#frmCab').removeClass('campoErro');
	$('input,select', '#frmDet').removeClass('campoErro');

	cdcoopex = normalizaNumero( cCdcoopex.val() );	
	cddopcao = cCddopcao.val();
	
	$(cCdcoopex).desabilitaCampo();
	
	// Busca dados da Coop na Alteração e Consulta.
	carregaDetalhamento();
	trocaBotao('');

	if ( cdcoopex === '' ){ 
		hideMsgAguardo();
		showError("error","Cooperativa deve ser informada.","Alerta - Ayllos","focaCampoErro(\'cdcoopex\', \'frmDet\');",false);
		return false; 
	}
	
	return false;		
}

function realizaOperacao() {

	// Mostra mensagem de aguardo
	
	if (cddopcao == "C"){  	   showMsgAguardo("Aguarde, consultando processos..."); } 
	else if (cddopcao == "A"){ showMsgAguardo("Aguarde, alterando processos...");  }	
	else { showMsgAguardo("Aguarde, liberando aplicacao..."); }
	
	var cdcoopex = $('#cdcoopex','#frmDet').val();
	cdcoopex = normalizaNumero(cdcoopex);
	var nmproces = $('#nmprocex','#frmProc').val();
	var flgativo = $('#flgativo','#frmProc').val();
	var ageinihr = $('#agxinihr','#frmProc').val();
	var ageinimm = $('#agxinimm','#frmProc').val();
	var agefimhr = $('#agxfimhr','#frmProc').val();
	var agefimmm = $('#agxfimmm','#frmProc').val();
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/hrcomp/manter_rotina.php", 
		data: {
			cddopcao: cddopcao,
			cdcoopex: cdcoopex,			
			nmproces: nmproces,
			flgativo: flgativo,
			ageinihr: ageinihr,
			ageinimm: ageinimm,
			agefimhr: agefimhr,
			agefimmm: agefimmm,
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
	if ($("#cdcoopex","#frmDet").prop("disabled") == true)  {
		return;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdcoopex, titulo_coluna, cdcoopexs;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmCab';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdcoopex = $('#cdcoopex','#'+nomeFormulario).val();
	cdcoopexs = cddgrupo;
	//cddgrupo = normalizaNumero($(cddgrupo).val());
	dsdgrupo = '';
	
	titulo_coluna = "Grupos de produto";
	
	bo			= 'b1wgen0183.p'; 
	procedure	= 'lista-grupos';
	titulo      = 'Grupos';
	qtReg		= '20';
	filtros 	= 'Codigo;cddgrupo;100px;S;' + cddgrupo + ';S|Descricao;dsdgrupo;150px;S;' + dsdgrupo + ';S';
	colunas 	= 'Codigo;cddgrupo;20%;right|' + titulo_coluna + ';dsdgrupo;50%;left';
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

function buscaDados() {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, consultando grupo...");
	
	var cddgrupo = $('#cddgrupo','#frmCab').val();
	cddgrupo = normalizaNumero(cddgrupo);
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/hrcomp/busca_dados.php", 
		data: {
			cddgrupo: cddgrupo,
			cddopcao: cddopcao,
			dsdgrupo: dsdgrupo,
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

function carregaDetalhamento(){
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, buscando processos...");
	
	var cdcoopex = $('#cdcoopex','#frmDet').val();	
	var cddopcao = $('#cddopcao','#frmCab').val();
	
	// Carrega dados parametro através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/hrcomp/busca_dados.php', 
		data    : 
				{ 
					cddopcao	: cddopcao,
					cdcoopex	: cdcoopex,
					redirect	: 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) { 
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {				

							$('#divProcessos').html(response);	
							$('#divProcessos').css({'display':'block'});
							
							formataProcessos();
							
							var cddopcao = $('#cddopcao','#frmCab').val();
	/*
							if ( cddopcao == 'C' ) {											
								$('#btIncluir','#divBotoesDetalha').hide();
								$('#btAlterar','#divBotoesDetalha').hide();
								$('#btExcluir','#divBotoesDetalha').hide();
							}
							
							carregaParametro(); */
							hideMsgAguardo();
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

function carregaCooperativas(){
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, buscando cooperativas...");	
	
	var cddopcao = $('#cddopcao','#frmCab').val();
	
	// Carrega dados parametro através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/hrcomp/carrega_cooperativas.php', 
		data    : 
				{ 
					cddopcao	: cddopcao,					
					redirect	: 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) { 
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {				
							$('#cdcoopex').html(response);
							hideMsgAguardo();
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


function formataProcessos() {

	$('#divRotina').css('width','640px');

	var divRegistro = $('div.divRegistros','#divProcessos');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'100px','width':'100%'});
	
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];	
	
	var arrayLargura = new Array();
	arrayLargura[0] = '20px';
	arrayLargura[1] = '149px';
	arrayLargura[2] = '50px';
	arrayLargura[3] = '115px';
	arrayLargura[4] = '110px';
	
		
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'left';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'left';
	
	var metodoTabela = '';
			
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );
			
	// seleciona o registro que é clicado 
	
	$('table > tbody > tr', divRegistro).click( function() {
	    glbTabNmproces = $(this).find('#nmproces > span').text();
		glbTabFlgativo = $(this).find('#flgativo > span').text();
		glbTabAgeinihr = $(this).find('#ageinihr > span').text();
		glbTabAgefimhr = $(this).find('#agefimhr > span').text();
		mostraDetalhamentoHrcomp();
	});
	
	/*
	$('table > tbody > tr:eq(0)', divRegistro).click();
	*/
	
	return false;
}

function mostraDetalhamentoHrcomp() {

	if ( cddopcao != 'A' ){
		return false;
	}
	
	if ( (glbTabNmproces == '') || ( cdcoopex = 0 ) ){
		showError('error','Não há registro selecionado','Alerta - Ayllos',"unblockBackground()");
		return false;
	}
	
	showMsgAguardo('Aguarde, buscando detalhamento...');

	// Executa script através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/hrcomp/detalhamento_hrcomp.php', 
		data: {			
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			hideMsgAguardo();
			exibeRotina($('#divRotina'));
			formataDetalhaHrcomp();
			bloqueiaFundo($('#divRotina'));						
			//buscaDetalhaTarifa();
		}				
	});
	
	return false;
	
}

function formataDetalhaHrcomp() {

	$('#divRotina').css('width','660px');

	var frmProc = "frmProc";
	
	$('#frmProc').css({'display':'block'});
	
	var rProcesso	= $('label[for="processo"]','#'+frmProc);
	var rNmprocex	= $('label[for="nmprocex"]','#'+frmProc);
	var rFlgativo	= $('label[for="flgativo"]','#'+frmProc);
	var rAgxinihr	= $('label[for="agxinihr"]','#'+frmProc);
	var rAgxinimm	= $('label[for="agxinimm"]','#'+frmProc);
	var rAgxfimhr	= $('label[for="agxfimhr"]','#'+frmProc);
	var rAgxfimmm	= $('label[for="agxfimmm"]','#'+frmProc);

	rProcesso.addClass('rotulo-linha').css('width','45px');
	rNmprocex.addClass('rotulo-linha');
	rFlgativo.addClass('rotulo-linha').css('width','60px');
	rAgxinihr.addClass('rotulo-linha').css('width','100px');
	rAgxinimm.addClass('rotulo-linha').css('width','10px');
	rAgxfimhr.addClass('rotulo-linha').css('width','100px');
	rAgxfimmm.addClass('rotulo-linha').css('width','10px');
	
	// Campos
	var cTodos	  	= $('input[type="text"],select','#'+frmProc);
	var cNmprocex   = $('#nmprocex','#'+frmProc);	
	var cFlgativo	= $('#flgativo','#'+frmProc);	
	var cAgxinihr	= $('#agxinihr','#'+frmProc);	
	var cAgxinimm	= $('#agxinimm','#'+frmProc);	
	var cAgxfimhr	= $('#agxfimhr','#'+frmProc);	
	var cAgxfimmm	= $('#agxfimmm','#'+frmProc);	

	
	$('#flgativo','#'+frmProc).unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				cAgxinihr.focus();
				return false;
			}
	});
	
	$('#agxinihr','#'+frmProc).unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				cAgxinimm.focus();
				return false;
			}
	});
	
	$('#agxinimm','#'+frmProc).unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				cAgxfimhr.focus();
				return false;
			}
	});
	
	$('#agxfimhr','#'+frmProc).unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {					
				cAgxfimmm.focus();				
				e.keyCode = 9;
				return false;
			}
	});


	$('#agxinihr').bind('focus', function(){
		$(this).select();
	});	

	$('#agxinimm').bind('focus', function(){
		$(this).select();
	});	
	
	$('#agxfimhr').bind('focus', function(){
		$(this).select();
	});	
	
	$('#agxfimmm').bind('focus', function(){
		$(this).select();
	});	
	
	cTodos.habilitaCampo();
	cFlgativo.css('width','60px');	
	cAgxinihr.css('width','20px').attr('maxlength','2').setMask('INTEGER','99','','');
	cAgxinimm.css('width','20px').attr('maxlength','2').setMask('INTEGER','99','','');
	cAgxfimhr.css('width','20px').attr('maxlength','2').setMask('INTEGER','99','','');
	cAgxfimmm.css('width','20px').attr('maxlength','2').setMask('INTEGER','99','','');	
	
	$(rNmprocex).text(glbTabNmproces);
	$('#nmprocex','#'+frmProc).val(glbTabNmproces);
	
	if(glbTabFlgativo == 'no'){
		$('#flgativo','#'+frmProc).val('N');
	}else{		
		$('#flgativo','#'+frmProc).val('S');
	}		
	
	$('#agxinihr','#'+frmProc).val(glbTabAgeinihr.substr(0,glbTabAgeinihr.indexOf(":")));
	$('#agxinimm','#'+frmProc).val(glbTabAgeinihr.substr(glbTabAgeinihr.indexOf(":") + 1,glbTabAgeinihr.length));

	$('#agxfimhr','#'+frmProc).val(glbTabAgefimhr.substr(0,glbTabAgefimhr.indexOf(":")));
	$('#agxfimmm','#'+frmProc).val(glbTabAgefimhr.substr(glbTabAgefimhr.indexOf(":") + 1,glbTabAgefimhr.length));

	
	layoutPadrao();
	hideMsgAguardo();
	
	$('#agxinihr','#'+frmProc).focus().select();	
	
	return false;
}

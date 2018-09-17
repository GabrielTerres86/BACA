/*!
 * FONTE        : debccr.js
 * CRIAÇÃO      : Tiago Machado Flor
 * DATA CRIAÇÃO : 26/01/2015
 * OBJETIVO     : Biblioteca de funções da tela DEBCCR
 * --------------
 * ALTERAÇÕES   : 
 * -----------------------------------------------------------------------
 */

//Formulários e Tabela
var frmCab   		= 'frmCab';
var frmDebccr       = 'frmDebccr';

//Labels/Campos do cabeçalho
var rCddopcao, rCdcooper, rNrdconta, cCddopcao, cCdcooper, cNrdconta, 
    cNmrescop, cNmprimtl, cGlbcoope, glbTabRowid, glbDtmvtolt, glbCdcooper;

$(document).ready(function() {
	estadoInicial();
	inicializaVar();
});

function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);
	
	hideMsgAguardo();		
	formataCabecalho();
	formatafrmDebccr();
	controlaNavegacao();
	$("#divFaturaPendente").html('');
	
	trocaBotao('Carregar');
	
	cTodosCabecalho.limpaFormulario().removeClass('campoErro');	

	highlightObjFocus( $('#frmCab') );
	highlightObjFocus( $('#frmDebccr') );
	
	$('#frmCab').css({'display':'block'});
	$('#frmDebccr').css({'display':'none'});
	$('#divBotoes').css({'display':'none'});
	
	cCdcooper.habilitaCampo();
	cCddopcao.habilitaCampo();
	cNrdconta.habilitaCampo();
	/*.datepicker({
	  showOn: "button",
	  buttonImage: "../../imagens/geral/btn_calendario.gif",
	  buttonImageOnly: true    });  */
  
	cCddopcao.val('E');
	cCddopcao.focus();	
	removeOpacidade('divTela');
	
}

function layoutTabela(){
		var divRegistro = $('#divFaturaPendente > div.divRegistros');
		var tabela      = $('table', divRegistro );

		divRegistro.css('height','150px');

		var ordemInicial = new Array();
		ordemInicial = [[0,0]];

		var arrayLargura = new Array();
		arrayLargura[0] = '70px';
		arrayLargura[1] = '130px';
		arrayLargura[2] = '130px';
		arrayLargura[3] = '115px';

		var arrayAlinha = new Array();
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'right';
		arrayAlinha[2] = 'right';
		arrayAlinha[3] = 'right';

		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
		
		glbTabRowid = '';
		
		// seleciona o registro que é clicado
		$('table > tbody > tr', divRegistro).click( function() {
			glbTabRowid = $(this).find('#rowid > span').text() ;
			//alert(glbTabRowid);
		});
		
		$('table > tbody > tr:eq(0)', divRegistro).click();
		
		return false;		
}

function formataCabecalho() {

	// Cabecalho
	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab);	

	rCddopcao.addClass('rotulo').css({'width':'100px'});
	
	cCddopcao			= $('#cddopcao','#'+frmCab);
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	
	cCddopcao.addClass('campo').css({'width':'533px'});

	layoutPadrao();

	return false;
}


function formatafrmDebccr() {

	// Cabecalho
	rCdcooper			= $('label[for="cdcopaux"]','#'+frmDebccr);
	rNrdconta			= $('label[for="nrdconta"]','#'+frmDebccr);
	
	rCdcooper.addClass('rotulo').css({'width':'100px'});
	rNrdconta.addClass('rotulo').css({'width':'100px'});
	
	cCdcooper			= $('#cdcopaux','#'+frmDebccr);
	cNmrescop			= $('#nmrescop','#'+frmDebccr);
	cNrdconta			= $('#nrdconta','#'+frmDebccr); 
	cNmprimtl			= $('#nmprimtl','#'+frmDebccr);
	cGlbcoope			= $('#glbcoope','#frmCab');
	
	cCdcooper.addClass('inteiro campo').css({'width':'80px'}).attr('maxlength','10').setMask('INTEGER','zzzzzzzzzz','','');
	cNmrescop.addClass('campo').css({'width':'450px'}).desabilitaCampo();
	cNrdconta.addClass('conta pesquisa campo').css({'width':'80px'});
	cNmprimtl.addClass('campo').css({'width':'450px'}).desabilitaCampo();
	
	layoutPadrao();

	return false;
}

// Controle
function buscaAssociado() {

	hideMsgAguardo();

	var nrdconta = normalizaNumero( cNrdconta.val() );
	var cdcooper = normalizaNumero( cCdcooper.val() );
	
	var mensagem = 'Aguarde, buscando associado ...';
	showMsgAguardo( mensagem );	
	
	//Carrega dados da conta através de ajax
	$.ajax({		
		type	: 'POST',
		url		: UrlSite + 'telas/debccr/busca_associado.php', 
		data    : 
				{ 
					nrdconta	: nrdconta,
					cdcooper	: cdcooper,
					redirect	: 'script_ajax' 
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

function controlaPesquisas(valor) {
	
	switch( valor )
	{
		case 1:
			controlaPesquisaCoop();
			break;
		case 2:
			// Se esta desabilitado o campo 
			if ($("#nrdconta","#frmDebccr").prop("disabled") == true)  {
				return;
			}	
			mostraPesquisaAssociado('nrdconta', frmCab );
			break;
	}
}

// Formata
function controlaNavegacao() {

	cCddopcao.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			liberaCampos();
			return false;
		}
	});	
	
	cCdcooper.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			if (cCdcooper.val() == '') {
				$('#nmrescop','#frmDebccr').val('');
				cNrdconta.focus();
				return false;
			} else {
				buscaCooperativa();
			}
		}
		
	});
	
	cNrdconta.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			if (cNrdconta.val() != '') {				
				buscaAssociado();
				return false;
			}
		} else if ( e.keyCode == 118 ) {
			mostraPesquisaAssociado('nrdconta', frmCab );
			return false;
		}
	});
	
	return false;		
}

function controlaLayout() {
}

// Botoes
function btnVoltar() {
	estadoInicial();	
	return false;
}

function btnContinuar() {

	//Remove a classe de Erro do form
	$('input,select', '#frmDebccr').removeClass('campoErro');
	
	if ( glbCdcooper == '3'){
		
		if ( $('#cdcopaux','#'+frmDebccr).val() == '' ){
			hideMsgAguardo();
			showError("error","Cooperativa deve ser informada.","Alerta - Ayllos","focaCampoErro(\'cdcopaux\', \'frmDebccr\');",false);
			return false;			
		}		
		
		if ( $('#nrdconta','#'+frmDebccr).val() == '' ){
			hideMsgAguardo();
			showError("error","Conta deve ser informada.","Alerta - Ayllos","focaCampoErro(\'nrdconta\', \'frmDebccr\');",false);
			return false;			
		}		
		
	} else{
		if ( $('#nrdconta','#'+frmDebccr).val() == '' ){
			hideMsgAguardo();
			showError("error","Numero da conta deve ser informado.","Alerta - Ayllos","focaCampoErro(\'nrdconta\', \'frmDebccr\');",false);
			return false;					
		}
	} 

	buscaFaturaPendenteGrid();
}

function carregaTarifas(){

   return false;
}

function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;" >Voltar</a>&nbsp;');
	
	if (botao != '') {
	
		if(botao == 'Carregar'){
			$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onclick="btnContinuar(); return false;" >' + botao + '</a>');
		}
		
		if(botao == 'Debitar'){
			cCdcooper.desabilitaCampo();
			cCddopcao.desabilitaCampo();
			cNrdconta.desabilitaCampo();
			
			$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onclick="efetivaDebitos(); return false;" >' + botao + '</a>');
		}
		
	}

	
	return false;
}

function botaoPDF(nmarqpdf){

	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btLog" onclick="Gera_Impressao(' + "'" + nmarqpdf + "'" + ');" >Log</a>');
	
	return false;
}

function liberaCampos() {

	if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda')  ) { return false; } ;	

	$('#cddopcao','#'+frmCab).desabilitaCampo();
	$('#frmDebccr').css({'display':'block'});
	$('#divBotoes').css({'display':'block'});
	formatafrmDebccr();
	
	$('input, select', '#'+frmDebccr).limpaFormulario().removeClass('campoErro');	
	
	var cddopcao = $('#cddopcao','#frmCab').val();
	$('#cddopcao1','#frmDebccr').val(cddopcao);
	
	if ( $('#glbcoope','#frmCab').val() == 3 ) {
		$('#nrdconta','#frmDebccr').desabilitaCampo();
	}else{		
		bloqueiaCampos(glbCdcooper);
	}	
	
	return false;
}

// imprimir
function Gera_Impressao(nmarqpdf) {	

	//showMsgAguardo("Aguarde, gerando relatorio...");

	var cddopcao = $('#cddopcao1','#frmDebccr').val(); 
	var cdhistor = $('#cdhistor','#frmDebccr').val();	
	var cddgrupo = $('#cddgrupo','#frmDebccr').val();
	var cdsubgru = $('#cdsubgru','#frmDebccr').val();	
	var cdhisest = $('#cdhisest','#frmDebccr').val();
	var cdmotest = $('#cdmotest','#frmDebccr').val();
	var cdcooper = $('#cdcopaux','#frmDebccr').val();
	var cdagenci = $('#cdagenci','#frmDebccr').val();
	var inpessoa = $('#inpessoa','#frmDebccr').val();
	var nrdconta = $('#nrdconta','#frmDebccr').val();
	var dtinicio = $('#dtinicio','#frmDebccr').val();
	var dtafinal = $('#dtafinal','#frmDebccr').val();

	cdhistor = normalizaNumero(cdhistor);
	cddgrupo = normalizaNumero(cddgrupo);
	cdsubgru = normalizaNumero(cdsubgru);
	cdhisest = normalizaNumero(cdhisest);
	cdmotest = normalizaNumero(cdmotest);
	cdcooper = normalizaNumero(cdcooper);
	cdagenci = normalizaNumero(cdagenci);
	inpessoa = normalizaNumero(inpessoa);
	nrdconta = normalizaNumero(nrdconta);
	
	$('#cdhistor1','#frmDebccr').val(cdhistor);
	$('#cdhisest1','#frmDebccr').val(cdhisest);	
	$('#cddgrupo1','#frmDebccr').val(cddgrupo);
	$('#cdsubgru1','#frmDebccr').val(cdsubgru);	
	$('#cdmotest1','#frmDebccr').val(cdmotest);
	$('#cdcooper1','#frmDebccr').val(cdcooper);
	$('#cdagenci1','#frmDebccr').val(cdagenci);
	$('#inpessoa1','#frmDebccr').val(inpessoa);
	$('#nrdconta1','#frmDebccr').val(nrdconta);	
	$('#nmarqpdf1','#frmDebccr').val(nmarqpdf);	
	
	
	//var action = UrlSite + 'telas/debccr/manter_rotina.php';
	var action = UrlSite + 'telas/debccr/manter_rotina.php';
	
	$('#sidlogin','#frmDebccr').remove();
	
	$('#frmDebccr').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '" />');

	carregaImpressaoAyllos("frmDebccr",action,"estadoInicial();");
	
	return false;
		
}

function controlaPesquisaCoop(){

	// Se esta desabilitado o campo 
	if ($("#cdcopaux","#frmDebccr").prop("disabled") == true)  {
		return;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdcooper, titulo_coluna, cdcoopers, cdcopaux, nmrescop;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmDebccr';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdcopaux = $('#cdcopaux','#'+nomeFormulario).val();
	cdcoopers = cdcopaux;	
	nmrescop = '';
	
	var cdcopaux = '' ;	
	
	titulo_coluna = "Cooperativas";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-cooperativas';
	titulo      = 'Cooperativas';
	qtReg		= '10';
	filtros 	= 'Codigo;cdcopaux;130px;S;' + cdcopaux + ';S|Descricao;nmrescop;200px;S;' + nmrescop + ';S';
	colunas 	= 'Codigo;cdcooper;20%;right|' + titulo_coluna + ';nmrescop;50%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cdcopaux\',\'#frmDebccr\').val()');
	
	return false;
}


function buscaCooperativa(){

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, buscando cooperativa...");

	var cdcooper = $('#cdcopaux','#frmDebccr').val();
	cdcooper = normalizaNumero(cdcooper);

	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/debccr/busca_dados_cooperativa.php", 
		data: {
			cdcooper: cdcooper,
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
	
	return false;

}

function buscaFaturaPendenteGrid(){

	showMsgAguardo("Aguarde, consultando faturas pendentes...");

	var cdcooper = $('#cdcopaux','#frmDebccr').val();
	cdcooper = normalizaNumero(cdcooper);	
	var nrdconta = $('#nrdconta','#frmDebccr').val();
	nrdconta = normalizaNumero(nrdconta);	
	
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/debccr/carrega_grid.php", 
		data: {
		    cdcooper: cdcooper,
			nrdconta: nrdconta,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();					
				$("#divFaturaPendente").html('');				
				eval(response);								
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});		
}

function efetivaDebitos(){

	showMsgAguardo("Aguarde, efetivando debitos das faturas pendentes...");

	var cdcooper = $('#cdcooper','#frmDebccr').val();
	cdcooper = normalizaNumero(cdcooper);	
	//alert(glbTabRowid);
	// Executa script através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/debccr/efetiva_debitos.php", 
		data: {
		    cdcooper: cdcooper,
			fatrowid: glbTabRowid,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				hideMsgAguardo();	
				//alert(response);
				eval(response);		
                glbTabRowid = '';								
			} catch(error) {				
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});		
}


function criaTabelaReg(tabela){
	$("#divFaturaPendente").html(tabela);
	return false;
}

function insereRegTabela(registro){
	$("#divFaturaPendente .divRegistros table").append(registro);
	//$("#divFaturaPendente .divRegistros table").append(registro);
	return false;
}

function insereResumo(qtregtar, vltottar){
	$("#divFaturaPendente").append('<br/><div style="width:100%;border-top: 1px solid #777777;"></div><div style="width:100%;height:20px;display:block;"><table style="float:right;font-weight:bold;padding-bottom:10px;" cellspacing="0" cellpadding="0"><tr><td style="width:140px;">Tarifas selecionadas: </td><td>' + qtregtar + '</td><td style="width:150px;"></td><td style="width:120px;">TOTAL: </td><td>' + vltottar + '</td></tr></table></div><div style="width:100%;height:10px;border-top: 1px solid #777777;"></div>');
	return false;
}

function inicializaVar() {

	hideMsgAguardo();
	
	var mensagem = 'Aguarde, procedimentos iniciais ...';
	showMsgAguardo( mensagem );	
	
	//Carrega dados da conta através de ajax
	$.ajax({		
		type	: 'POST',
		url		: UrlSite + 'telas/debccr/inicializa_var.php', 
		data    : 
				{ 
					redirect	: 'script_ajax' 
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

function bloqueiaCampos(cdcooper){
	$('#cdcopaux','#'+frmDebccr).val(cdcooper);
	buscaCooperativa();    
}
/*!
 * FONTE        : opecel.js
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 21/02/2013
 * OBJETIVO     : Biblioteca de funções da tela OPECEL
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */

// Definição de algumas variáveis globais 
var cddopcao		= 'C';

//Labels/Campos do cabeçalho
var cCddopcao, cCdoperadora, cNmoperadora, cFlgsituacao, cCdhisdebcop, cDshisdebcop, 
	cCdhisdebcnt, cDshisdebcnt, cPerreceita, cTodosCabecalho, cTodosOpecel, btnCab, btLupaOpe;

$(document).ready(function() {

	estadoInicial();
	
	highlightObjFocus( $('#frmCab') );
	
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	
	return false;
	
	
});

// seletores
function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);
	$('#frmCab').css({'display':'block'});
	$('#frmOpecel').css({'display':'none'});
	$('#divBotoes').css({'display':'none'});
	$('#btProsseguir','#divBotoes').text('Prosseguir');
	$('input,select', '#frmCab').removeClass('campoErro');	
	$('input,select', '#frmOpecel').removeClass('campoErro');	
	
	formataCabecalho();

	cCddopcao.val( cddopcao );
	removeOpacidade('divTela');	
	unblockBackground();
	hideMsgAguardo();
	
	$("#btVoltar","#divBotoes").hide();
	
	controlaFoco();
}

function controlaFoco() {
	
	var bo        = '';
	var procedure = '';
	var titulo    = '';
	var qtReg	  = '';
	var filtros   = '';
    var colunas   = '';
	var cdhistor  = 0;
	
	$('#cddopcao','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cCddopcao.desabilitaCampo();
			cCdoperadora.habilitaCampo();
			$('#divBotoes', '#divTela').css({'display':'block'});
			$('#btVoltar','#divBotoes').show();
			$('#btProsseguir','#divBotoes').show();
			cCdoperadora.focus();
			return false;
		}	
	});
	
	$('#btnOK','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cCddopcao.desabilitaCampo();
			cCdoperadora.habilitaCampo();
			$('#divBotoes', '#divTela').css({'display':'block'});
			$('#btVoltar','#divBotoes').show();
			$('#btProsseguir','#divBotoes').show();
			cCdoperadora.focus();
			return false;
		}	
	});

	$('#btnOK','#frmCab').unbind('click').bind('click', function(e) {
		cCddopcao.desabilitaCampo();
		cCdoperadora.habilitaCampo();
		$('#divBotoes', '#divTela').css({'display':'block'});
		$('#btVoltar','#divBotoes').show();
		$('#btProsseguir','#divBotoes').show();
		cCdoperadora.focus();
		return false;
	});
	
	$('#cdoperadora','#frmCab').unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#btProsseguir','#divBotoes').click();
			return false;
		}	
	});
	
	$('#btLupaOpe','#frmCab').css('cursor', 'pointer').unbind('click').bind('click', function () {
		if ($('#cdoperadora','#frmCab').hasClass('campoTelaSemBorda')) { return false; }	
		procedure = 'PESQUISA_OPERADORA';
		titulo = 'Operadora';
		qtReg = '30';
		filtros = ';cdoperadora;;N;;N;;descricao|Operadora;nmoperadora;200px;S;;;descricao';
		colunas = 'Código;cdoperadora;20%;right|Operadora;nmoperadora;80%;left';
		mostraPesquisa('TELA_OPECEL', procedure, titulo, qtReg, filtros, colunas);
		return false;
     });
	 
	$('#flgsituacao','#frmOpecel').unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#cdhisdebcop','#frmOpecel').select();
			return false;
		}	
	});
	
	$('#flgsituacao','#frmOpecel').unbind('change').bind('change', function(e) {
		if ($(this).val() == 0){
			$('input', '#frmOpecel').desabilitaCampo();
			$('input', '#frmOpecel').removeClass('campoErro');
		}else{
			$('#cdhisdebcop', '#frmOpecel').habilitaCampo();
			$('#cdhisdebcnt', '#frmOpecel').habilitaCampo();
			$('#perreceita', '#frmOpecel').habilitaCampo();
			$('#cdhisdebcop', '#frmOpecel').focus();
		}
		return false;
	});

	
	$('#cdhisdebcop','#frmOpecel').unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#cdhisdebcnt','#frmOpecel').select();
			return false;
		}	
	});
	
	$('#cdhisdebcop','#frmOpecel').unbind('change').bind('change', function () {
		cdhistor = normalizaNumero($(this).val());
		buscaHistoricoDebCop(cdhistor);
		
		return false;
	});
	
	$('#btLupaCop','#frmOpecel').css('cursor', 'pointer').unbind('click').bind('click', function () {
		if ($('#cdhisdebcop','#frmOpecel').hasClass('campoTelaSemBorda')) { return false; }	
		// Informacoes para pesquisa
		bo        = 'b1wgen0153.p'; 
		procedure = 'lista-historicos';
		titulo    = 'histórico';
		qtReg	  = '20';
		filtros   = 'C&oacutedigo;cdhisdebcop;80px;S;;S|Hist&oacuterico;dshisdebcop;280px;S;;S';
		colunas   = 'C&oacutedigo;cdhistor;20%;right|Hist&oacuterico;dshistor;50%;left';
		
		// Exibir a tela de pesquisa
		mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas, '', '$(\'#cdhisdebcop\',\'#frmOpecel\').val(); $(\'#cdhisdebcop\',\'#frmOpecel\').removeClass( \'campoErro\' )');
		$('#cdhisdebcopPesquisa', '#formPesquisa').attr('maxlength','4').addClass('codigo');
		$('#dshisdebcopPesquisa', '#formPesquisa').attr('maxlength','50');
		layoutPadrao();
		return false;
     });
	
	$('#cdhisdebcnt','#frmOpecel').unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#perreceita','#frmOpecel').select();
			return false;
		}	
	});
	
	$('#cdhisdebcnt','#frmOpecel').unbind('change').bind('change', function () {
		cdhistor = normalizaNumero($(this).val());
		buscaHistoricoDebCnt(cdhistor);
		return false;
	});
	
	$('#btLupaCnt','#frmOpecel').css('cursor', 'pointer').unbind('click').bind('click', function () {
		if ($('#cdhisdebcnt','#frmOpecel').hasClass('campoTelaSemBorda')) { return false; }	
		// Informacoes para pesquisa
		bo        = 'b1wgen0153.p'; 
		procedure = 'lista-historicos';
		titulo    = 'histórico';
		qtReg	  = '20';
		filtros   = 'C&oacutedigo;cdhisdebcnt;80px;S;;S|Hist&oacuterico;dshisdebcnt;280px;S;;S';
		colunas   = 'C&oacutedigo;cdhistor;20%;right|Hist&oacuterico;dshistor;50%;left';
		
		// Exibir a tela de pesquisa
		mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas, '', '$(\'#cdhisdebcnt\',\'#frmOpecel\').val(); $(\'#cdhisdebcnt\',\'#frmOpecel\').removeClass( \'campoErro\' )');
		$('#cdhisdebcntPesquisa', '#formPesquisa').attr('maxlength','4').addClass('codigo');
		$('#dshisdebcntPesquisa', '#formPesquisa').attr('maxlength','50');
		layoutPadrao();
		return false;
     });

	
	$('#perreceita','#frmOpecel').unbind('keydown').bind('keydown', function(e) {
		if (e.keyCode == 13 ) {	
			btnContinuar();
			return false;
		}	
	});

	
}

function formataCabecalho(){
	
	cTodosCabecalho		= $('input[type="text"],select','#frmCab');
	cTodosCabecalho.limpaFormulario();
	cTodosCabecalho.habilitaCampo();
	
	// cabecalho
	rCddopcao	 = $('label[for="cddopcao"]','#frmCab'); 
	rCdoperadora = $('label[for="cdoperadora"]','#frmCab'); 
	rCddopcao.css('width','70px');
	rCdoperadora.css({'width':'70px'}).addClass('rotulo');	
	
	cCddopcao	 = $('#cddopcao','#frmCab').css({'width':'445px'}); 
	cCdoperadora = $('#cdoperadora','#frmCab').addClass('campo codigo pesquisa').css('width','50px').attr('maxlength','5');
	cNmoperadora = $('#nmoperadora','#frmCab').addClass('campo').css('width','372px');
	btLupaOpe 	 = $('#btLupaOpe','#frmCab');
	btnCab		 = $('#btOK','#frmCab');
	
	cCdoperadora.desabilitaCampo();
	cNmoperadora.desabilitaCampo();
	
	cCddopcao.focus();
	
	layoutPadrao();
}

function formataLayout() {

	highlightObjFocus( $('#frmOpecel') );
	//formulario
	rFlgsituacao = $('label[for="flgsituacao"]','#frmOpecel');
	rCdhisdebcop = $('label[for="cdhisdebcop"]','#frmOpecel');
	rCdhisdebcnt = $('label[for="cdhisdebcnt"]','#frmOpecel');
	rPerreceita  = $('label[for="perreceita"]','#frmOpecel');
	
	rFlgsituacao.css({'width':'175px'}).addClass('rotulo');
	rCdhisdebcop.css({'width':'175px'}).addClass('rotulo');
	rCdhisdebcnt.css({'width':'175px'}).addClass('rotulo');
	rPerreceita.css({'width':'175px'}).addClass('rotulo');
	
	cFlgsituacao = $('#flgsituacao','#frmOpecel').addClass('campo').css('width','80px');
	cCdhisdebcop = $('#cdhisdebcop','#frmOpecel').addClass('campo pesquisa codigo').css('width','50px').attr('maxlength','5');
	cDshisdebcop = $('#dshisdebcop','#frmOpecel').addClass('campo').css('width','300px');
	cCdhisdebcnt = $('#cdhisdebcnt','#frmOpecel').addClass('campo pesquisa codigo').css('width','50px').attr('maxlength','5');
	cDshisdebcnt = $('#dshisdebcnt','#frmOpecel').addClass('campo').css('width','300px');
	cPerreceita  = $('#perreceita','#frmOpecel').addClass('campo').css({'width':'80px','text-align':'right'}).attr('maxlength','6');
	cPerreceita.setMask('DECIMAL','zz9,99','.','');
	cTodosOpecel = $('input[type="text"],select','#frmOpecel');
	
	layoutPadrao();
	return false;	
}


// botoes
function btnVoltar() {
	
	estadoInicial();
	return false;
}

function liberaCampos() {

	cTodosCabecalho		= $('input[type="text"],select','#frmCab'); 	
	cTodosOpecel		= $('input[type="text"],select','#frmOpecel');
	cTodosCabecalho.desabilitaCampo();
	btLupaOpe.css('cursor', 'default');
	formataLayout();
	$('#frmOpecel').css({'display':'block'});
	
	// Desabilita campo opção
	if ( $('#cddopcao','#frmCab').val() == 'C'){
		cTodosOpecel.desabilitaCampo();
		$('#btLupaCop','#frmOpecel').css('cursor', 'default');
		$('#btLupaCnt','#frmOpecel').css('cursor', 'default');
		$('#btProsseguir','#divBotoes').hide();
	}else{
		cTodosOpecel.habilitaCampo();
		cDshisdebcop.desabilitaCampo();
		cDshisdebcnt.desabilitaCampo();
		if (cFlgsituacao.val() == 0){
			cCdhisdebcop.desabilitaCampo();
			cCdhisdebcnt.desabilitaCampo();
			cPerreceita.desabilitaCampo();
		}
		$('#btProsseguir','#divBotoes').text('Alterar');
		cFlgsituacao.focus();
	}
	
	return false;

}

function btnContinuar() {

	if (!$('#cdoperadora','#frmCab').hasClass('campoTelaSemBorda')) {
		$('input,select', '#frmCab').removeClass('campoErro');

		cdoperadora = normalizaNumero( cCdoperadora.val() );
		nmoperadora = cNmoperadora.val();
		cddopcao = cCddopcao.val();
		
		buscaOperadora();
	}else{
		validaOperadora();
	}
	
	return false;
		
}

function buscaOperadora() {

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, consultando operadora...");	
	
	var cdoperadora = normalizaNumero(cCdoperadora.val());
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/opecel/busca_operadora.php", 
		data: {
			cddopcao   : cddopcao,
			cdoperadora: cdoperadora,
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

function buscaHistoricoDebCop(cdhistor){
	// Remove classe de erro
	$('cdhisdebcop', 'frmOpecel').removeClass('campoErro'); 
	// Busca descrição do historico
	bo        = 'b1wgen0153.p'; 
	procedure = 'lista-historicos';
	titulo    = 'histórico';
	buscaDescricao(bo, procedure, titulo, 'cdhisdebcop', 'dshisdebcop', cdhistor, 'dshistor', '', 'frmOpecel');
	
	return false;
}	

function buscaHistoricoDebCnt(cdhistor){
	// Remove classe de erro
	$('cdhisdebcnt', 'frmOpecel').removeClass('campoErro');
	// Busca descrição do historico
	bo        = 'b1wgen0153.p'; 
	procedure = 'lista-historicos';
	titulo    = 'histórico';
	buscaDescricao(bo, procedure, titulo, 'cdhisdebcnt', 'dshisdebcnt', cdhistor, 'dshistor', '', 'frmOpecel');
	
	return false;
}

function validaOperadora(){
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, validando dados inseridos...");	
	
	if (cFlgsituacao.val() == 1){
		if (cCdhisdebcop.val() == '' || cCdhisdebcop.val() == 'undefined' || cCdhisdebcop.val() == '0'){
			hideMsgAguardo();
			showError("error","Informe os hist&oacute;ricos de d&eacute;bito.","Alerta - Ayllos","focaCampoErro('cdhisdebcop', 'frmOpecel');",false);
			return false;
		}
		if (cCdhisdebcnt.val() == '' || cCdhisdebcnt.val() == 'undefined' || cCdhisdebcnt.val() == '0'){
			hideMsgAguardo();
			showError("error","Informe os hist&oacute;ricos de d&eacute;bito.","Alerta - Ayllos","focaCampoErro('cdhisdebcnt', 'frmOpecel');",false);
			return false;
		}
		if (cCdhisdebcop.val() > 0 && (cDshisdebcop.val() == '' || cDshisdebcop.val() == 'undefined' || cDshisdebcop.val() == ' ')){
			hideMsgAguardo();
			showError("error","N&atilde;o h&aacute; hist&oacute;rico com o c&oacute;digo informado.","Alerta - Ayllos","focaCampoErro('cdhisdebcop', 'frmOpecel');",false);
			return false;			
		}
		if (cCdhisdebcnt.val() > 0 && (cDshisdebcnt.val() == '' || cDshisdebcnt.val() == 'undefined' || cDshisdebcnt.val() == ' ')){
			hideMsgAguardo();
			showError("error","N&atilde;o h&aacute; hist&oacute;rico com o c&oacute;digo informado.","Alerta - Ayllos","focaCampoErro('cdhisdebcnt', 'frmOpecel');",false);
			return false;			
		}
	}
	hideMsgAguardo();
	$('input', '#frmOpecel').removeClass( 'campoErro' );
	alteraOperadora();
	return false;
}

function alteraOperadora(){

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, efetuando opera&ccedil;&atilde;o...");	
	
	var cdoperadora = cCdoperadora.val();
	var flgsituacao = cFlgsituacao.val();
	var cdhisdebcop = cCdhisdebcop.val();
	var cdhisdebcnt = cCdhisdebcnt.val();
	var perreceita  = cPerreceita.val();
	perreceita = perreceita.replace(',','.');

	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/opecel/altera_operadora.php", 
		data: {
			cdoperadora: cdoperadora,
			flgsituacao: flgsituacao,
			cdhisdebcop: cdhisdebcop,
			cdhisdebcnt: cdhisdebcnt,
			perreceita : perreceita,
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
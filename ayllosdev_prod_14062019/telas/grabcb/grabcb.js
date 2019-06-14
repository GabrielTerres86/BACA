/*!
 * FONTE        : grabcb.js
 * CRIAÇÃO      : Jean Michel
 * DATA CRIAÇÃO : 09/04/2014
 * OBJETIVO     : Biblioteca de funções da tela GRABCB
 * PROJETO		: Projeto de Novos Cartões Bancoob
 * --------------
 * ALTERAÇÕES   : 02/07/2014 - ocultado campo PA (Lucas Lunelli)
 *				  04/08/2014 - Adicionado parametro de Cod. Cooperativa (Lucas Lunelli)
 * --------------
 */

// Definição de algumas variáveis globais 
var cddopcao		= '0';
	
//Formulários
var frmCab   		= 'frmCab';

//Labels/Campos do cabeçalho
var rCddopcao, rCdgrafin, rCdcooper, rNmrescop, rCdagenci, rSlcadmin, cSlcadmin, cCdagenci, cCdcooper, cNmrescop, cCdgrafin, cCddopcao, cTodosCabecalho, btnCab;

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
	$('#divBotoes').css({'display':'block'});
			
	formataCabecalho();
	
	cTodosCabecalho.limpaFormulario();
	cCddopcao.val( cddopcao );
	
	removeOpacidade('divTela');	
	unblockBackground();
	hideMsgAguardo();
		
	$('#cddopcao','#frmCab').val("C")	;
	$('#cdgrafin','#frmCab').desabilitaCampo();
	$('#nmrescop','#frmCab').desabilitaCampo();
	$('#cdagenci','#frmCab').desabilitaCampo();
	$('#slcadmin','#frmCab').desabilitaCampo();	
	$('#divagenci','#frmCab').show();
	$('input,select', '#frmCab').removeClass('campoErro');
	
	controlaFoco();
		
}

function controlaFoco() {

	$('#cddopcao','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				$('#btnOK','#frmCab').focus();
				return false;
			}	
	});
	
	$('#btnOK','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				escolheOpcao();
				return false;
			}	
	});
	
	$('#cdgrafin','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				btnContinuar(1);
				return false;
			}	
	});
	
	
	$('#nmrescop','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				$('#slcadmin','#frmCab').focus();
				return false;
			}	
	});
	
	/*
	$('#cdagenci','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				$('#slcadmin','#frmCab').focus();
				return false;
			}	
	});
	*/
	
	$('#slcadmin','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				$('#btSalvar','#frmCab').focus();
				return false;
			}	
	});
	
	$('#btSalvar','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				$('#btVoltar','#frmCab').focus();
				return false;
			}	
	});
	
	$('#btVoltar','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				$('#cddopcao','#frmCab').focus();
				return false;
			}	
	});
	
	$('#cddopcao','#'+frmCab).val("C");
	carregaCombo();
}

function formataCabecalho() {

	// cabecalho
	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab); 
	rCdgrafin			= $('label[for="cdgrafin"]','#'+frmCab); 
	rCdcooper			= $('label[for="cdcopaux"]','#'+frmCab); 
	rCdagenci			= $('label[for="cdagenci"]','#'+frmCab); 
	rSlcadmin			= $('label[for="slcadmin"]','#'+frmCab); 
	rNmrescop			= $('label[for="nmrescop"]','#'+frmCab);
	
	cCddopcao			= $('#cddopcao','#'+frmCab); 
	cCdgrafin			= $('#cdgrafin','#'+frmCab); 
	cCdcooper			= $('#cdcopaux','#'+frmCab); 
	cCdagenci			= $('#cdagenci','#'+frmCab); 
	cSlcadmin			= $('#slcadmin','#'+frmCab); 
	cNmrescop			= $('#nmrescop','#'+frmCab);
	
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	
	btnCab				= $('#btOK','#'+frmCab);
	
	rCddopcao.css('width','105px');
	rCdgrafin.css('width','105px');
	rNmrescop.css('width','105px');
	rCdagenci.css('width','20px');
	rSlcadmin.css('width','105px');
	
	cCddopcao.css({'width':'390px'});
	cCdgrafin.css({'width':'150px'});
	cNmrescop.css({'width':'150px'});
	cCdagenci.css({'width':'50px'});
	cSlcadmin.css({'width':'390px'});
	
	//Não exibir PA
	rCdagenci.css('display','none');
	cCdagenci.css('display','none');
	
	cTodosCabecalho.habilitaCampo();
	
	$('#cddopcao','#'+frmCab).focus();
		
	layoutPadrao();
	
	return false;	
}

function escolheOpcao(){	
	$('#cdgrafin','#'+frmCab).attr('disabled',false); 
	$('#cdgrafin','#'+frmCab).attr('readonly',false); 
	$('#cdgrafin','#'+frmCab).setMask("INTEGER","9999999","","");
	$('#cdgrafin','#'+frmCab).css("text-align","right");
	$('#cdgrafin','#frmCab').focus();
}

function efetuarConsulta() {
	
	var cddopcao = $('#cddopcao','#'+frmCab).val();
	var cdgrafin = $('#cdgrafin','#'+frmCab).val();
	var cdcooper = $('#cdcopaux','#frmCab').val();
	var cdagenci = $('#cdagenci','#'+frmCab).val();
	var cdadmcrd = $('#slcadmin','#'+frmCab).val();	
		
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando dados...");
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/grabcb/manter_rotina.php", 
		data: {
			cddopcao: cddopcao,
			cdgrafin: cdgrafin,
			cdcooper: cdcooper,
			cdagenci: cdagenci,
			cdadmcrd: cdadmcrd,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			hideMsgAguardo();
			eval(response);
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
			//controlaPesquisaPac();
			break;		
	}
}

function controlaPesquisaPac() {

	var cdcooper = $('#cdcopaux','#frmCab').val();
	
	// Se esta desabilitado o campo 
	if ($("#cdagenci","#frmCab").prop("disabled") == true || cdcooper == null || cdcooper == '') {
		return;
	}
	
 	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdcooper, nmrescop, cdagenci, titulo_coluna, cdagencis, nmresage;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmCab';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdagenci = $('#cdagenci','#'+nomeFormulario).val();	
	
	if ( cdcooper == '' ) {
		var cdcooper = $('#cdcopaux','#frmCab').val();	
	}
	
	cdagencis = cdagenci;	
	nmresage = ' ';
	nmrescop = ' ';
	
	titulo_coluna = "Descricao";
	
	bo			= 'b1wgen0153.p'; 
	procedure	= 'lista-pacs';
	titulo      = 'Agência PA';
	qtReg		= '20';
		
	filtros 	= 'Coop;cdcooper;30px;N;' + cdcooper + ';S|Nome Coop;nmrescop;30px;N;' + nmrescop + ';N|Cód. PA;cdagenci;30px;S;' + cdagenci + ';S|Agência PA;nmresage;200px;S;' + nmresage + ';N';
	colunas 	= 'Cód. Coop;cdcooper;20%;right|Cooperativa;nmrescop;27%;right|Cód. PA;cdagenci;15%;right|' + titulo_coluna + ';nmresage;50%;left';
	
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cdagenci\',\'#frmCab\').val()');
	
	return false; 
}

function controlaPesquisaCoop(){

	// Se esta desabilitado o campo 
	if ($("#nmrescop","#frmCab").prop("disabled") == true)  {
		return;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdcooper, titulo_coluna, cdcoopers, cdcopaux, nmrescop;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmCab';
	
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
	fncOnClose  = 'carregaCombo();';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#cdcopaux\',\'#frmCab\').val();' + fncOnClose);
	
	return false;
}

function mudaOpcao(){
	var cddopcao = $('#cddopcao','#'+frmCab).val();
	
	$('#cdgrafin','#'+frmCab).val('');
	$('#nmrescop','#'+frmCab).val('');
	$('#cdcopaux','#'+frmCab).val('');
	$('#cdagenci','#'+frmCab).val('');
	$('#slcadmin','#'+frmCab).val('1');
	
	if(cddopcao == 'C'){
		$('#slcadmin','#'+frmCab).attr('disabled', true);
	}
}

function btnVoltar(){
	$('#cddopcao','#'+frmCab).val('C');
	$('#cdgrafin','#'+frmCab).val('');
	$('#nmrescop','#'+frmCab).val('');
	$('#cdcopaux','#'+frmCab).val('');
	$('#cdagenci','#'+frmCab).val('');
	$('#slcadmin','#'+frmCab).val('1');
	$('#cdgrafin','#'+frmCab).attr('disabled', true);
	$('#cddopcao','#'+frmCab).focus();
}

function btnContinuar(tipAcao){
	var cdgrafin = $('#cdgrafin','#'+frmCab).val();	
	var nmrescop = $('#nmrescop','#'+frmCab).val();
	var cdagenci = $('#cdagenci','#'+frmCab).val();
	var slcadmin = $('#slcadmin','#'+frmCab).val();
	var cddopcao = $('#cddopcao','#'+frmCab).val();
	var cdcooper = $('#cdcopaux','#'+frmCab).val();	
	
	if(cddopcao == 'C'){
		$('#nmrescop','#'+frmCab).val('');
		$('#cdagenci','#'+frmCab).val('');
		$('#slcadmin','#'+frmCab).val('1');
	}
	if (cdgrafin == null || cdgrafin == '' || cdgrafin == 0){
		showError("error","Informe o C&oacute;digo de Sequ&ecirc;ncia.","Alerta - Ayllos","");
		$('#cdgrafin','#'+frmCab).focus();
		return false;
	}
	
	if(cddopcao != 'C' && cdcooper != '' && cdcooper != 0){
		if (nmrescop == null || nmrescop == ''){
			showError("error","Informe o C&oacute;digo da Cooperativa.","Alerta - Ayllos","");
			$('#cdgrafin','#'+frmCab).focus();
			return false;
		} else if (slcadmin == null || slcadmin == '' || slcadmin ==0){
			showError("error","Informe o C&oacute;digo do PA.","Alerta - Ayllos","");
			$('#cdgrafin','#'+frmCab).focus();
			return false;
		}
	}
	if(tipAcao == 2 && cddopcao != 'C'){
		showConfirmacao('Deseja continuar a  opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','efetuarConsulta()','','sim.gif','nao.gif');
	}else{
		efetuarConsulta();
	}
	
}

function carregaCombo() {	

	cdcopaux = $('#cdcopaux','#frmCab').val();	
		
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/grabcb/carrega_combo.php", 		
		data: {
			cdcopaux: cdcopaux,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			hideMsgAguardo();
			eval(response);				
		}
	});
	
}
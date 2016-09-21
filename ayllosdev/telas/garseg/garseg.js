/*
 * FONTE        : garseg.js
 * CRIAÇÃO      : Rogério Giacomini (GATI)
 * DATA CRIAÇÃO : setembro/2011
 * OBJETIVO     : Biblioteca de funções da tela GARSEG
 * --------------
 * ALTERAÇÕES   : 
 * 001: 18/01/2013 - Daniel (CECRED) : Implantacao novo layout.
 * --------------
 */

var frmCabecalho, btnGarant, divTabela, divRegistros, divRegistro, tabela, divGarantia, divBotoes, btIncluir, btAlterar, btExluir, btSalvar;
var cCdSegura, cNmSegura, cTpSeguro, cTpPlaseg, cTodos;
var nomeForm;
var divBotoes;
var cDsGarant, cVlGarant, cDsFranqu;

var dsgarant = '';
var vlgarant = '';
var dsfranqu = '';

var nrseqinc = '';
var cdsegura = '';
var nmsegura = '';
var tpseguro = '';
var tpplaseg = '';
var dsgarant = '';
var vlgarant = '';
var dsfranqu = '';
var habilita = false;

$(document).ready(function() {
	// Inicializando algumas variáveis
	
	divGarantia = $('#divGarantia');
	divTabela    = $('#divTabela');
	divRegistros = $('div.divRegistros', divTabela );
	divBotoes = $('div#divBotoes', divTabela );
	divBotoes.desabilitaCampo();
	
	// Inicializando os seletores dos campos do cabeçalho
	cTodos    = $('#cdsegura, #nmsegura, #tpseguro, #tpplaseg' ,'#frmGarseg');
	cCdSegura = $('#cdsegura','#frmGarseg');
	cNmSegura = $('#nmsegura','#frmGarseg');
	cTpSeguro = $('#tpseguro','#frmGarseg');
	cTpPlaseg = $('#tpplaseg','#frmGarseg');
	
	cTpSeguro.desabilitaCampo();
	cTpPlaseg.desabilitaCampo();

	btnGarant = $('#btBuscaGarantias','#frmGarseg');
	
	// controle do botão para listar garantias
	btnGarant.unbind('click').bind('click', function() {
		if(cCdSegura.val() != '' && cTpSeguro.val() != '' && cTpPlaseg.val() != ''){
			carrega_dados();
		}
		else{
			if(cCdSegura.val() == 0 || cCdSegura.val() == ''){
				showError('error','Selecione uma seguradora para listar garantias.','Alerta - Ayllos','bloqueiaFundo($("#divTela"),\'cdsegura\',\'frmGarseg\')');
				return false;
			}
			if(cTpSeguro.val() == ''){
				showError('error','Selecione o tipo do seguro para listar garantias.','Alerta - Ayllos','bloqueiaFundo($("#divTela"),\'tpseguro\',\'frmGarseg\')');
				return false;
			}
			if(cTpPlaseg.val() == ''){
				showError('error','Selecione o tipo do plano para listar garantias.','Alerta - Ayllos','bloqueiaFundo($("#divTela"),\'tpplaseg\',\'frmGarseg\')');
				return false;
			}
		}
		return false;
	});
	
	controlaLayout();
});

function controlaLayout() {	
	formataCabecalho();
	formataTabela();
	controlaFoco();
	
	highlightObjFocus( $('#frmGarseg') );
	highlightObjFocus( $('#frmGarantia') );
	
	cCdSegura.focus();
}

function formataFormulario(operacao) {
	
	var divGarantia = $('#divGarantia');
	divGarantia.css({'width':'500px'});
	
	var rDsGarant = $('label[for="dsgarant"]',"#frmGarantia"); // rótulo descrição da garantia
	var rVlGarant = $('label[for="vlgarant"]',"#frmGarantia"); // rótulo valor cobertura
	var rDsFranqu = $('label[for="dsfranqu"]',"#frmGarantia"); // rótulo descrição da franquia
	
	
	
	var cTodos = $('select,input','#frmGarantia');
	cDsGarant  = $('#dsgarant'   ,"#frmGarantia");
	cVlGarant  = $('#vlgarant'   ,"#frmGarantia");
	cDsFranqu  = $('#dsfranqu'   ,"#frmGarantia");
	
	cTodos.addClass('campo');
		
	cDsGarant.addClass('rotulo').css({'width':'250px'}).attr('maxlength','50');;
	rDsGarant.addClass('rotulo').css({'width':'150px','text-align':'right'});
	
	rVlGarant.addClass('rotulo').css({'width':'150px','text-align':'right'});
	cVlGarant.addClass('moeda').css({'width':'80px'});
	
	cDsFranqu.addClass('rotulo').css({'width':'200px'}).attr('maxlength','50');;
	rDsFranqu.addClass('rotulo').css({'width':'150px','text-align':'right'});
	
	var divBotoes = $('div#divBotoes', divGarantia );
	
	var btSalvar = $('#btSalvar',divBotoes);
	// controle do botão para incluir uma nova garantia
	btSalvar.unbind('click').bind('click', function() {
		if(cDsGarant.val() != '' && cVlGarant.val() != '' && cDsFranqu.val() != '') {
			carrega_dados();
		}
		else{
			if(cDsGarant.val() == ''){
				showError('error','Todos os campos do formulário são obrigatórios.','Alerta - Ayllos','bloqueiaFundo($("#divGarantia"),\'dsgarant\',\'frmGarantia\')');
			}
			if(cVlGarant.val() == ''){
				showError('error','Todos os campos do formulário são obrigatórios.','Alerta - Ayllos','bloqueiaFundo($("#divGarantia"),\'vlgarant\',\'frmGarantia\')');
			}
			if(cDsFranqu.val() == ''){
				showError('error','Todos os campos do formulário são obrigatórios.','Alerta - Ayllos','bloqueiaFundo($("#divGarantia"),\'dsfranqu\',\'frmGarantia\')');
			}
		}
		return false;
	});
	
	layoutPadrao();
}


function formataCabecalho() {
	//ROTULOS
	var rCdSegura = $('label[for="cdsegura"]','#frmGarseg');
	var rTpSeguro = $('label[for="tpseguro"]','#frmGarseg');
	var rTpPlaseg = $('label[for="tpplaseg"]','#frmGarseg');
	
	cCdSegura.addClass('campo').css({'width':'80px','text-align':'right'}).setMask('INTEGER','zzz.zzz.zz9','.','');
	rCdSegura.addClass('rotulo').css({'width':'120px'});
	
	cNmSegura.css({'width':'400px'}).desabilitaCampo();
	
	rTpSeguro.addClass('rotulo').css({'width':'120px'});
	cTpSeguro.addClass('campo').css({'width':'120px','text-align':'left'}).setMask('INTEGER','zzz','.','');
	
	
	rTpPlaseg.css({'width':'80px'});
	cTpPlaseg.addClass('campo').css({'width':'50px','text-align':'right'}).setMask('INTEGER','zzz','.','');
	
	layoutPadrao();
}

function formataTabela() {
	
	divTabela   = $('#divTabela');
	divBotoes   = $('#divBotoes');
	divRegistro = $('div.divRegistros', divTabela );
	tabela      = $('table', divRegistro );
	
	divRegistro.css({'height':'150px','border-bottom':'1px dotted #777','padding-bottom':'2px'});
	
	if ( $.browser.msie ) {	// IE
		divRegistro.css({'height':'165px'});
	}
	
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];
	
	var arrayLargura = new Array();
	arrayLargura[0] = '200px';
	arrayLargura[1] = '80px';
	
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'left';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	
	divGarantia.css({'display':'none'});
	divTabela.css({'display':'block'});
	return false;
}

function carrega_dados(){
	habilita = false;
	cdsegura = retiraCaracteres($("#cdsegura","#frmGarseg").val(),"0123456789",true);	
	var nmsegura = $('#nmsegura','#frmGarseg').val();
	var tpseguro = $('#tpseguro','#frmGarseg').val();
	var tpseguro = $('#tpseguro','#frmGarseg').val();
	var tpplaseg = $('#tpplaseg','#frmGarseg').val();
	
	// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando dados ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		dataType: 'html',
		url: UrlSite + "telas/garseg/carrega_dados.php",
		data: {
		    cdsegura: cdsegura,	nmsegura: nmsegura,
			tpseguro: tpseguro, tpplaseg: tpplaseg,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrsennov','#frmEskeci').focus()");
		},
		success: function(response) {				
			hideMsgAguardo();
			$('#divTabela').html(response);
		}
	});
}

// Função que controla a lupa de pesquisa
function buscarSeguradora() {

	divRotina = $("#divTela");
	var divBotoes = $("#divBotoes");
	var nomeForm='';
	var campoAnterior = '';
	var procedure, titulo, qtReg, filtrosPesq, filtrosDesc, colunas;	
	var bo = 'b1wgen0033.p';		
	
	// CÓDIGO DA SEGURADORA
	titulo      = 'Seguradora';
	procedure   = 'buscar_seguradora';
	
	qtReg		= '50';
	filtrosPesq	= 'C&oacutedigo:;cdsegura;60px;|Descri&ccedil&atildeo:;nmsegura;200px;';	
	colunas 	= 'C&oacutedigo:;cdsegura;11%;right|Descri&ccedil&atildeo:;nmsegura;49%;';
	fncOnClose  = 'cdsegura = $("#cdsegura","#frmGarseg").val()';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas,divRotina,fncOnClose);
	return false;
			
}

function pesquisaBuscaSeguradora() {
		
	hideMsgAguardo();		

	var cdsegura = normalizaNumero($('#cdsegura','#frmGarseg').val());
	
	$.ajax({		
			type  : 'POST',
			async : true ,
			url   : UrlSite + 'telas/garseg/buscar_seguradora.php', 		
			data: {
				cdsegura: cdsegura,
				redirect: 'script_ajax'
			}, 
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
			},
			success: function(response) {
				try {
					eval(response);
					cTpSeguro.habilitaCampo();
					cTpPlaseg.habilitaCampo();
					cTpSeguro.focus();
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		});

	return false;	
	                     
}
function buscaSeguradora() {

	// controle das busca descrições
	var bo 			= 'b1wgen0033.p';
	var procedure	= 'buscar_seguradora';
	var titulo      = 'Seguradora';
	var filtrosDesc = 'flgerlog|false';
	buscaDescricao(bo,procedure,titulo,$('#cdsegura','#frmGarseg').attr('name'),'nmsegura',normalizaNumero($('#cdsegura','#frmGarseg').val()),'nmsegura',filtrosDesc,'frmGarseg');
	return false;
}

function desbloqueiaFundoGarseg(){
	
	bloqueiaFundo( $('#divTela'));
	unblockBackground();
}

// Função para visualizar div da rotina
function mostraRotina() {
	$("#divRotina").css("visibility","visible");
	$('#divRotina').css({'width':'350px'});
	$('#divRotina').centralizaRotinaH();
	formataFormulario();
	cDsGarant.focus();
}

// Função para esconder a div da rotina
function escondeRotina() { 
	$("#divRotina").css("visibility","hidden");
	unblockBackground();
}

function controlaOperacao(operacao){
	var divGarantia = $('#divRotina');
	var divBotoes = $('div#divBotoes', divGarantia );
	var btSalvar = $('#btSalvar',divBotoes);
	nrseqinc = '';
	if (operacao == 'INCLUIR'){
		if(habilita){
			mostraRotina();
			hideMsgAguardo();
			cDsGarant.val('');
			cVlGarant.val('');
			cDsFranqu.val('');
			bloqueiaFundo($('#divRotina'));
			
			btSalvar.unbind('click').bind('click', function() {
				incluirGarantiaAlcada();
				return false;
			});			
		}
	}
	else if (operacao == 'ALTERAR'){
		$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				nrseqinc = $('#nrseqinc', $(this) ).val();
				dsgarant = $('#dsgarant', $(this) ).val();
				vlgarant = $('#vlgarant', $(this) ).val();
				dsfranqu = $('#dsfranqu', $(this) ).val();
			}
		});
		if ( habilita && nrseqinc != '') {
			hideMsgAguardo();
			mostraRotina();
			cDsGarant.val(dsgarant);
			cVlGarant.val(number_format(parseFloat(vlgarant),2,',','.'));
			cDsFranqu.val(dsfranqu);
			bloqueiaFundo($('#divRotina'));
			btSalvar.unbind('click').bind('click', function() {
				alterarGarantia();
			});	
		}
	}
	else if (operacao == 'EXCLUIR'){
		$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				nrseqinc = $('#nrseqinc', $(this) ).val();
				dsgarant = $('#dsgarant', $(this) ).val();
				vlgarant = $('#vlgarant', $(this) ).val();
				dsfranqu = $('#dsfranqu', $(this) ).val();
			}
		});
		if ( habilita && nrseqinc != '') {
			showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','excluirGarantia();','','sim.gif','nao.gif');			
		}
	}
}
function excluirGarantia(){

	cdsegura = cCdSegura.val();
	tpseguro = cTpSeguro.val();
	tpplaseg = cTpPlaseg.val();

	$.ajax({		
		type: "POST", 
		dataType: 'html',
		url: UrlSite + "telas/garseg/excluir_garantia.php",
		data: {
			cdsegura: cdsegura,	nmsegura: nmsegura, nrseqinc: nrseqinc,
			tpseguro: tpseguro, tpplaseg: tpplaseg,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrsennov','#frmEskeci').focus()");
		},
		success: function(response) {				
			hideMsgAguardo();
			carrega_dados();
		}
	});
}
function incluirGarantiaAlcada()
{
	cdsegura = cCdSegura.val();
	tpseguro = cTpSeguro.val();
	tpplaseg = cTpPlaseg.val();
	dsgarant = cDsGarant.val();
	vlgarant = cVlGarant.val();
	dsfranqu = cDsFranqu.val();
	showMsgAguardo("Aguarde, incluindo nova garantia ...");
	incluirGarantia();
}

function incluirGarantia()
{
	// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, incluindo nova garantia ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({
		type: "POST", 
		dataType: 'html',
		url: UrlSite + "telas/garseg/incluir_garantia.php",
		data: {
		    cdsegura: cdsegura, tpseguro: tpseguro, tpplaseg: tpplaseg, 
			dsgarant: dsgarant, vlgarant: vlgarant, dsfranqu: dsfranqu, 
			redirect: "html_ajax" // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrsennov','#frmEskeci').focus()");
		},
		success: function(response) {
			hideMsgAguardo();
			eval(response);
		}
	});
}

function alterarGarantia()
{
	cdsegura = cCdSegura.val();
	tpseguro = cTpSeguro.val();
	tpplaseg = cTpPlaseg.val();
	tpplaseg = cTpPlaseg.val();
	dsgarant = cDsGarant.val();
	vlgarant = cVlGarant.val();
	dsfranqu = cDsFranqu.val();
	nomeForm = 'frmGarantia';
	
	// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, alterando garantia ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({
		type: "POST", 
		dataType: 'html',
		url: UrlSite + "telas/garseg/alterar_garantia.php",
		data: {
		    cdsegura: cdsegura, tpseguro: tpseguro, tpplaseg: tpplaseg, nrseqinc: nrseqinc,
			dsgarant: dsgarant, vlgarant: vlgarant, dsfranqu: dsfranqu, nomeForm: nomeForm,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrsennov','#frmEskeci').focus()");
		},
		success: function(response) {				
			hideMsgAguardo();
			eval(response);
		}
	});
}

function controlaFoco(){

	$('#cdsegura','#frmGarseg').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			if ($('#cdsegura','#frmGarseg').val() == '') { 
				buscarSeguradora();
				return false;
			} else {
				pesquisaBuscaSeguradora();
				$('#tpseguro','#frmGarseg').focus();
				return false;
			}
		} else{
		 }
	});
	
	$('#cdsegura','#frmGarseg').unbind('change').bind('change', function() {
		pesquisaBuscaSeguradora();
	});
	
	$('#tpseguro','#frmGarseg').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#tpplaseg','#frmGarseg').focus();
			return false;
		}
	});
	
	$('#tpplaseg','#frmGarseg').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#btBuscaGarantias','#frmGarseg').focus();
			return false;
		}
	});
	
	
	/* frmGarantia */
	$('#dsgarant','#frmGarantia').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#vlgarant','#frmGarantia').focus();
			return false;
		}
	});
	
	$('#vlgarant','#frmGarantia').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#dsfranqu','#frmGarantia').focus();
			return false;
		}
	});
	
	$('#dsfranqu','#frmGarantia').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			alterarGarantia();
			return false;
		}
	});
	
			
}
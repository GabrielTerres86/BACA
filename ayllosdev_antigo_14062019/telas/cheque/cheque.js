/*!
 * FONTE        : cheque.js
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 13/05/2011
 * OBJETIVO     : Biblioteca de funções da tela CHEQUE
 * --------------
 * ALTERAÇÕES   : 
 * [20/11/2011] Jorge					: Alteracoes referente a mostragem de botoes
 *		   	    						  Criado funcao funcaoVoltar()  
 * [27/03/2012] Rogérius Militão (DB1) 	: Novo layout padrão
 * [04/09/2012] Tiago                   : inclusao de novos campos na tt-cheques.
 * [18/12/2012] Zé                      : Retirar o campo Conta da TIC
 * [30/06/2014] Reinert					: Adicionado campo cdageaco nos detalhes do cheque
 * [10/06/2016] Lucas Ranghetti         : Alterado Width da frame dos detalhes (#422753)
 * [10/04/2017] Permitir acessar o Ayllos mesmo vindo do CRM. (Jaison/Andrino)
 * [26/04/2017] Lucas Ranghetti         : Limpar numero do cheque quando acionar o estado inicial.
 * [14/07/2017] Lucas Reinert           : Alteração para o cancelamento manual de produtos. Projeto 364.
 * [14/11/2017] Jonata   (RKAM)         : Ajuste para chamar rotina correta (P364).
 * --------------
 */

// Variáveis globais usadas para as requisições AJAX
var idseqttl, nrtipoop, nrcheque;

// Variáveis globais para alguns seletores úteis
var frmCheque, frmCabecalho, frmTipoCheque, divTabela;

// Variáveis globais para os seletores dos campos do formulário cabeçalho
var cNrdconta, cNmprimtl, cQtrequis, cNrtipoop, 
	cNrcheque, cTpChequ1, cNrregist;

// Variáveis globais para os seletores dos campos do formulário cheque
var cNrpedido, cDtsolped, cDtrecped, cDsdocmc7,
	cDscordem, cDtmvtolt, cVlcheque, cVldacpmf, cCdtpdchq, 
	cCdbandep, cCdagedep, cNrctadep, cDsobserv, cCdbantic,
	cCdagetic, cNrctaTic, cDtlibtic, cCdageaco;

$(document).ready(function() {
	
	// Inicializando algumas variáveis
	//nrdconta = 0;
	idseqttl = 1;
	nrtipoop = '';
	nrcheque = '';
	
	// Inicializando os seletores principais
	frmCheque		= $('#frmCheque');
	frmCabecalho	= $('#frmCabecalho');
	frmTipoCheque   = $('#frmTipoCheque');
	divTabela		= $('#divTabela');
	divRotina 		= $('#divTela');	

	// Inicializando os seletores dos campos do cabeçalho
	cNrdconta	= $('#nrdconta','#frmCabCheque');
	cNmprimtl	= $('#nmprimtl','#frmCabCheque');
	cQtrequis	= $('#qtrequis','#frmCabCheque');	
	cNrcheque	= $('#nrcheque','#frmTipoCheque');	
	cNrtipoop   = $('input[name="nrtipoop"]','#frmTipoCheque');				
	cTpChequ1   = $('#tpChequ1','#frmTipoCheque');
	cNrregist	= $('#nrregist','#frmTipoCheque');
	
	// Inicializando os seletores dos campos do formulário cheque
	cNrpedido	= $('#nrpedido','#frmCheque');
	cDtsolped	= $('#dtsolped','#frmCheque');
	cDtrecped	= $('#dtrecped','#frmCheque');
	cDsdocmc7	= $('#dsdocmc7','#frmCheque');
	cDscordem	= $('#dscordem','#frmCheque');	
	cDtmvtolt	= $('#dtmvtolt','#frmCheque');	
	cVlcheque	= $('#vlcheque','#frmCheque');
	cVldacpmf	= $('#vldacpmf','#frmCheque');	
	cCdtpdchq	= $('#cdtpdchq','#frmCheque');
	cCdbandep	= $('#cdbandep','#frmCheque');
	cCdagedep	= $('#cdagedep','#frmCheque');
	cNrctadep	= $('#nrctadep','#frmCheque');
	cCdageaco	= $('#cdageaco','#frmCheque');	
	cDsobserv	= $('#dsobserv','#frmCheque');	
	cCdbantic	= $('#cdbantic','#frmCheque');
	cCdagetic	= $('#cdagetic','#frmCheque');
	cNrctatic	= $('#nrctatic','#frmCheque');
	cDtlibtic	= $('#dtlibtic','#frmCheque');
	
	
	controlaLayout();
});

function buscaConta() {
	showMsgAguardo('Aguarde, buscando dados da Conta...');	
	
	nrdconta = normalizaNumero(cNrdconta.val());
			
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/cheque/busca_conta.php', 
		data    :
				{ nrdconta: nrdconta,	
				  idseqttl: idseqttl,
				  redirect: 'script_ajax'

				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','$(\'#nrdconta\',\'#frmCabCheque\').focus();');
				},
		success : function(response) { 
					hideMsgAguardo();
					eval(response);
					if (executandoImpedimentos){
						//$("[name=nrtipoop]", "#frmTipoCheque").val(5);
						if (tppeschq == 1){
							$("#tpChequ1","#frmTipoCheque").click();						
						}else if (tppeschq == 2){
							$("#tpChequ2","#frmTipoCheque").click();
						}else if (tppeschq == 3){
							$("#tpChequ5","#frmTipoCheque").click();						
						}
						$("#btBuscaCheque","#frmTipoCheque").click();						
					}
				}
	}); 
}

function buscaCheque(nriniseq) {
	
	showMsgAguardo('Aguarde, buscando os cheques da Conta...');

	$('input','#frmTipoCheque').removeClass('campoErro');
	
	nrdconta = normalizaNumero(cNrdconta.val());
	nrcheque = normalizaNumero(cNrcheque.val());	
	nrregist = normalizaNumero(cNrregist.val());	
	nrtipoop = normalizaNumero($(cNrtipoop.selector+':checked').val());
			
	if (executandoImpedimentos){
		var execimpe = 1;
	}else{
		var execimpe = 0;
	}
	
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/cheque/busca_cheque.php', 
		data    :
				{ nrdconta: nrdconta,	
				  idseqttl: idseqttl,
				  nrtipoop: nrtipoop,
				  nrcheque: nrcheque,
				  nriniseq: nriniseq,
				  nrregist: nrregist,
				  execimpe: execimpe,
				  tppeschq: tppeschq,
				  redirect: 'script_ajax'
				  
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','$(\'#tpChequ1\',\'#frmTipoCheque\').focus();');
				},
		success : function(response) { 
					hideMsgAguardo();
					
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							$('#divTabela').html(response);
							$('#btDetalhar').focus();
							return false;
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','$(\'#tpChequ1\',\'#frmTipoCheque\').focus();');
						}
					} else {
						try {
							eval( response );
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','$(\'#tpChequ1\',\'#frmTipoCheque\').focus();');
						}
					}
					
				}
	}); 
}

function controlaLayout() {	
	formataCabecalho();
	formataFormulario();	
	formataTabela();	
	layoutPadrao();		
	$("#tdConteudoTela").show();
	$('#btDetalhar','#divBotoes').css({'display':'none'});
	cNrdconta.focus();

    // Seta os valores caso tenha vindo do CRM
    if ($("#crm_inacesso","#frmCabCheque").val() == 1) {
        $("#nrdconta","#frmCabCheque").val($("#crm_nrdconta","#frmCabCheque").val());
    }
	
}

function formataCabecalho() {

	highlightObjFocus( $('#frmCabCheque') );
	highlightObjFocus( $('#frmTipoCheque') );

	// RÓTULOS
	var rNrdconta	= $('label[for="nrdconta"]','#frmCabCheque');
	var rNmprimtl	= $('label[for="nmprimtl"]','#frmCabCheque');
	var rQtrequis	= $('label[for="qtrequis"]','#frmCabCheque');
	var rRadio      = $('label.radio','#frmTipoCheque');					
	var rNrcheque	= $('label[for="nrcheque"]','#frmTipoCheque');	
	var rNrregist	= $('label[for="nrregist"]','#frmTipoCheque');	
	
	rNrdconta.addClass('rotulo-linha');
	rNmprimtl.addClass('rotulo-linha').css({'width':'45px'});
	rQtrequis.addClass('rotulo-linha').css({'width':'33px'});
	rRadio.css({'margin-right':'8px'});
	rNrregist.addClass('rotulo-linha');	
	rNrcheque.addClass('rotulo-linha').css({'width':'70px'});
	
	cNrdconta.addClass('conta pesquisa').css({'width':'80px'}).habilitaCampo();
	cNmprimtl.css({'width':'379px'}).desabilitaCampo();
	cQtrequis.css({'width':'36px'}).desabilitaCampo();	
	cNrcheque.css({'width':'75px'}).attr('maxlength','6').desabilitaCampo();	
	cNrregist.addClass('inteiro').css({'width':'40px'}).attr('maxlength','4').desabilitaCampo();
	cNrtipoop.desabilitaCampo();
	
	frmTipoCheque.css({'border-bottom':'1px solid #777','padding-bottom':'2px'});	
	divRotina.css({'width':'680'});

	if ( $.browser.msie ) {
		rNrdconta.css({'width':'42px'});	
		cNrcheque.css({'width':'70px'});	
	}	
	
	cNrtipoop.unbind('change').bind('change', function() {
		$(this).each( function() {
			if ( $(this).val() == 5 ) {
				cNrcheque.habilitaCampo();				
			} else {
				cNrcheque.desabilitaCampo().val('0');				

			}
		});
	});
	
	//nr. regi
	cNrregist.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 && isHabilitado(cNrregist) && !isHabilitado(cNrcheque))  {
			$('#btBuscaCheque').click();
			return false;
		}
	});
	
	// a partir de
	cNrcheque.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 && isHabilitado(cNrcheque))  {
			$('#btBuscaCheque').click();
			return false;
		}
	});

	// ok
	$('#btBuscaCheque').css({'margin-left':'5px'}).unbind('click').bind('click', function() {
		if (!cNrtipoop.hasClass('campoTelaSemBorda')) {
			cNrregist.val(normalizaNumero(cNrregist.val()) == 0 ? 30 : normalizaNumero(cNrregist.val()));
			buscaCheque(1);
		}
		return false;
	});
	
	cNrdconta.buscaConta('buscaConta();','estadoInicial();');

	$('#btnOK').unbind('click').bind('click', function() {
		if ( isHabilitado(cNrdconta) )  { 
			buscaConta();
			return false;
		}
	});
	
	if (nrdconta != 0){		
		$('#btnOK').click();
	}
	
}

function formataFormulario() {
	
	var cTodos      = $('input','#frmCheque');		
	var rNrpedido	= $('label[for="nrpedido"]','#frmCheque');
	var rDtsolped	= $('label[for="dtsolped"]','#frmCheque');
	var rDtrecped	= $('label[for="dtrecped"]','#frmCheque');
	var rDsdocmc7	= $('label[for="dsdocmc7"]','#frmCheque');
	var rDscordem	= $('label[for="dscordem"]','#frmCheque');	
	var rDtmvtolt	= $('label[for="dtmvtolt"]','#frmCheque');	
	var rDsobserv	= $('label[for="dsobserv"]','#frmCheque');	
	var rVlcheque	= $('label[for="vlcheque"]','#frmCheque');
	var rVldacpmf	= $('label[for="vldacpmf"]','#frmCheque');	
	var rCdtpdchq	= $('label[for="cdtpdchq"]','#frmCheque');
	var rCdbandep	= $('label[for="cdbandep"]','#frmCheque');
	var rCdagedep	= $('label[for="cdagedep"]','#frmCheque');
	var rNrctadep	= $('label[for="nrctadep"]','#frmCheque');
	var rCdageaco	= $('label[for="cdageaco"]','#frmCheque');
	var	rCdbantic	= $('label[for="cdbantic"]','#frmCheque');
	var rCdagetic	= $('label[for="cdagetic"]','#frmCheque');
	var rNrctatic	= $('label[for="nrctatic"]','#frmCheque');
	var rDtlibtic	= $('label[for="dtlibtic"]','#frmCheque');

	rNrpedido.css('width', '130px').addClass('rotulo');
	rDtsolped.css('width','100px').addClass('rotulo-linha');
	rDtrecped.css('width','95px').addClass('rotulo-linha');
	rDsdocmc7.css('width', '130px').addClass('rotulo');
	rDscordem.css('width', '130px').addClass('rotulo');
	rDtmvtolt.css('width', '130px').addClass('rotulo');
	rDsobserv.css('width', '130px').addClass('rotulo');
	rVlcheque.css('width','95px').addClass('rotulo-linha');
	rVldacpmf.css('width','130px').addClass('rotulo-linha');
	rCdtpdchq.css('width','100px').addClass('rotulo-linha');
	rCdbandep.css('width','130px').addClass('rotulo');
	rNrctadep.css('width','95px').addClass('rotulo-linha');
	rCdagedep.css('width','100px').addClass('rotulo-linha');
	rCdageaco.css('width','130px').addClass('rotulo');
	rNrctatic.css('width','100px').addClass('rotulo-linha');
	rCdbantic.css('width','130px').addClass('rotulo');
    rCdagetic.css('width','100px').addClass('rotulo-linha');	
	rDtlibtic.css('width','95px').addClass('rotulo-linha');	
	
	
	cTodos.desabilitaCampo();
	cNrpedido.css({'width': '98px'});
	cDtsolped.css({'width': '98px'}).addClass('data');
	cDtrecped.css({'width': '97px'}).addClass('data');	
	cDsdocmc7.css({'width':'500px'});	
	cDscordem.css({'width':'500px'}).addClass('alphanum');	
	cDtmvtolt.css({'width':'500px'}).addClass('alphanum');	
	cDsobserv.css({'width':'500px'}).addClass('alphanum');	
	cVlcheque.css({'width': '98px'}).addClass('moeda');	
	cVldacpmf.css({'width': '98px'}).addClass('moeda');	
	cCdtpdchq.css({'width': '98px'});
	cCdbandep.css({'width': '98px'}).addClass('integer');
	cCdagedep.css({'width': '98px'}).addClass('integer');
	cNrctadep.css({'width': '98px'}).addClass('integer');
	cCdageaco.css({'width': '98px'}).addClass('integer');
	cCdbantic.css({'width': '98px'}).addClass('integer');
	cCdagetic.css({'width': '98px'}).addClass('integer');
	cNrctatic.css({'width': '98px'}).addClass('integer');
	cDtlibtic.css({'width': '98px'}).addClass('data');
	
	/*
	if ( $.browser.msie ) {	// IE
		rDtrecped.css({'width':'165px'});
		rCdtpdchq.css({'width':'135px'});
		rNrctadep.css({'width':'135px'});
	}*/
	
}

function formataTabela() {

	var divRegistro = $('div.divRegistros', divTabela );		
	var tabela      = $('table', divRegistro );

	divRegistro.css({'height':'207px','border-bottom':'1px dotted #777','padding-bottom':'2px'});
	divTabela.css({'border':'1px solid #777','border-top':'none'});	
	
	$('tr.sublinhado > td',divRegistro).css({'text-decoration':'underline'});	
	
	if ( $.browser.msie ) {	// IE
		divRegistro.css({'height':'165px'});
	}

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '25px';
	arrayLargura[1] = '28px';
	arrayLargura[2] = '63px';
	arrayLargura[3] = '35px';
	arrayLargura[4] = '30px';
	arrayLargura[5] = '28px';
	arrayLargura[6] = '100px';
	arrayLargura[7] = '65px';
	arrayLargura[8] = '65px';
	arrayLargura[9] = '65px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'center';
	arrayAlinha[4] = 'center';
	arrayAlinha[5] = 'left';
	arrayAlinha[6] = 'center';
	arrayAlinha[7] = 'center';
	arrayAlinha[8] = 'center';
	arrayAlinha[9] = 'right';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, 'trocaVisao();' );
	
	frmCheque.css({'display':'none'}).limpaFormulario();
	divTabela.css({'display':'block'});
	
	cNrdconta.next().next().css({'display':'block'});
	$('input','#frmTipoCheque').desabilitaCampo();
	$('#btDetalhar','#divBotoes').css({'display':''});
	
	return false;
}

function selecionaCheque() {
	$('table > tbody > tr', 'div.divRegistros').each( function() {
		if ( $(this).hasClass('corSelecao') ) {
			
			var aVlcheque = ( typeof $('#vlcheque', $(this)).val() == 'undefined' ) ? 0 : $('#vlcheque', $(this)).val();			
			var aVldacpmf = ( typeof $('#vldacpmf', $(this)).val() == 'undefined' ) ? 0 : $('#vldacpmf', $(this)).val();			
			
			cNrpedido.val($('#nrpedido', $(this)).val());
			cDtsolped.val($('#dtsolped', $(this)).val());
			cDtrecped.val($('#dtrecped', $(this)).val());
			cDsdocmc7.val($('#dsdocmc7', $(this)).val());
			cDscordem.val($('#dscordem', $(this)).val());
			cDtmvtolt.val($('#dtmvtolt', $(this)).val());
			cVlcheque.val(number_format(parseFloat(aVlcheque.replace(',','.')),2,',','.'));
			cVldacpmf.val(number_format(parseFloat(aVldacpmf.replace(',','.')),2,',','.'));
			cCdtpdchq.val($('#cdtpdchq', $(this)).val());
			cCdbandep.val($('#cdbandep', $(this)).val());
			cCdagedep.val($('#cdagedep', $(this)).val());
			cNrctadep.val($('#nrctadep', $(this)).val());
			cCdageaco.val($('#cdageaco', $(this)).val());
			cDsobserv.val($('#dsobserv', $(this)).val());
			
			cCdbantic.val($('#cdbantic', $(this)).val());
			cCdagetic.val($('#cdagetic', $(this)).val());
			cNrctatic.val($('#nrctatic', $(this)).val());
			cDtlibtic.val($('#dtlibtic', $(this)).val());
			
		} 
		
	});
	
	return false;
}

function funcaoVoltar(){
	
	if ( divTabela.css('display') == 'block' ){	
		if ( !isHabilitado(cNrdconta) && !isHabilitado(cNrregist) ) {
			$('#btDetalhar','#divBotoes').css({'display':'none'});				
			$('input','#frmTipoCheque').habilitaCampo();
			nrtipoop == 5 ? cNrcheque.habilitaCampo() : cNrcheque.desabilitaCampo();
			cNrregist.focus();
			divTabela.css({'display':'block'});
			$('table > tbody', 'div.divRegistros').html('');
			$('table > tbody > tr > td', 'div#divPesquisaRodape').each(function(i){ $(this).html(''); });
		} else {
			if (executandoImpedimentos){
				sequenciaImpedimentos();
				return false;
			}else{
			estadoInicial();			
			}
		}		
	}else{
		trocaVisao();
	}

}

function trocaVisao() {
	if ( $('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao') ) { 
		// Se a visão está na Tabela, então joga os valores para o formulário
		if ( divTabela.css('display') == 'block' ) selecionaCheque();

		$('#btDetalhar','#divBotoes').toggle();
		frmCheque.toggle();
		divTabela.toggle();

	}

	return false;
}

function setTitular(nome,qtde) {
	cNmprimtl.val(nome);
	cQtrequis.val(qtde);	
	cNrdconta.desabilitaCampo();
	$('input','#frmTipoCheque').habilitaCampo();
	cNrcheque.desabilitaCampo();
	$('#btVoltar','#divBotoes').css({'display':''});
	cTpChequ1.prop('checked',true);
	cTpChequ1.focus();
	
}

function estadoInicial() {
	
	cNrdconta.habilitaCampo();
	$('#nmprimtl','#frmCabCheque').val('');
	$('#btDetalhar','#divBotoes').css({'display':'none'});	
	$('#btVoltar','#divBotoes').css({'display':''});
	$('input',frmTipoCheque).desabilitaCampo();
	frmCheque.css({'display':'none'}).limpaFormulario();
	divTabela.css({'display':'block'});
	cNrdconta.val('').focus();
	cNrcheque.val('0');
	$('table > tbody', 'div.divRegistros').html('');
	$('table > tbody > tr > td', 'div#divPesquisaRodape').each(function(i){ $(this).html(''); });	
}

function sequenciaImpedimentos() {
    if (executandoImpedimentos) {	
		if (posicao <= produtosCancMCheque.length) {
			if (produtosCancMCheque[posicao - 1] == '' || produtosCancMCheque[posicao - 1] == 'undefined'){
				eval(produtosCancM[posicao - 1]);
				posicao++;
			}else{				
				eval(produtosCancMCheque[posicao - 1]);
				posicao++;
				estadoInicial();
				$("#nrdconta","#frmCabCheque").val(nrdconta);
				$("#btnOK","#frmCabCheque").click();						
			}
            return false;
        }else{
			eval(produtosCancM[posicao - 1]);
			posicao++;
			return false;
		}
    }
}

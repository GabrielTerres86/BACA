/*!
 * FONTE        : estour.js
 * CRIAÇÃO      : Jéssica (DB1) 				Última alteração: 02/09/2015
 * DATA CRIAÇÃO : 30/07/2013
 * OBJETIVO     : Biblioteca de funções da tela ESTOUR
 * --------------
 * ALTERAÇÕES   : 02/09/2015 - Ajuste para correção da conversão realizada pela DB1
					     	   (Adriano).
 *				  21/07/2017 - Alterações referentes ao cancelamento manual de produtos do projeto 364.(Reinert)
 * --------------
 */
 //Formulários e Tabela
var frmCab   		= 'frmCab';
var divTabela;

$(document).ready(function() {
	
	divTabela		= $('#divTabela');
	estadoInicial();
			
	return false;
		
});

// inicio
function estadoInicial() {

	$('#frmCab').fadeTo(0,0.1);
		
	$('#divTabela').html('');
		
	formataCabecalho();
	
	removeOpacidade('frmCab');
	
	$('#divBotoes').css({'display':'none'});	

	return false;
	
}

// formata
function formataCabecalho() {
		
	var cTodosCabecalho	= $('input[type="text"],select','#'+frmCab);
		
	var btnOK = $('#btnOK','#'+frmCab);
	
	//label
	var rNrdconta = $('label[for="nrdconta"]','#'+frmCab);	
	var rNmprimtl = $('label[for="nmprimtl"]','#'+frmCab);	
	var rQtddtdev = $('label[for="qtddtdev"]','#'+frmCab);	
	var rDd		  =  $('label[for="dd"]','#'+frmCab);	
	
	rNrdconta.css({'width':'60px'});
	rNmprimtl.css({'width':'60px'});
	rQtddtdev.css({'width':'60px'});
	rDd.css({'width':'20px'});
		
	//campos
	var cNrdconta = $('#nrdconta','#'+frmCab);
	var cNmprimtl = $('#nmprimtl','#'+frmCab);
	var cQtddtdev = $('#qtddtdev','#'+frmCab);
	
	cTodosCabecalho.habilitaCampo();
	
	cNrdconta.css({'width':'90px'}).addClass('conta');
	cNmprimtl.css({'width':'375px'});
	cQtddtdev.css({'width':'45px'});
	
	cNrdconta.habilitaCampo();
	cNmprimtl.desabilitaCampo();
	cQtddtdev.desabilitaCampo();
		
	btnOK.unbind('click').bind('click', function() {
				
		if ( divError.css('display') == 'block' ) { return false; }		
		
		if ($("#nrdconta","#frmCab").prop("disabled") == true)  { return; }
		
		buscaEstouro(1,30);
				
		return false;
			
	});
	
	$('#nrdconta','#frmCab').unbind('keypress').bind('keypress', function(e) {
		
		if ( divError.css('display') == 'block' ) { return false;}		
		
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
		
			$(this).removeClass('campoErro');
			
			buscaEstouro(1,30);	
			return false;
			
		}	
		
	});	
	
	$('#frmConsulta').css('display','none');
		
	highlightObjFocus( $('#frmCab') );
	highlightObjFocus( $('#frmConsulta') );
		
	layoutPadrao();
	
	cNrdconta.focus();	
		
	if (nrdconta != '') {
		$("#nrdconta","#frmCab").val(nrdconta);
		$("#btnOK","#frmCab").click();		
	}else{
		nrdconta = 0;
	}
		
	return false;	
}

//botoes
function btnVoltar() {

	if (executandoImpedimentos){
		sequenciaImpedimentos();
	}else{
	$('#frmCab').limpaFormulario();
	
	estadoInicial();
	}
	return false;
}

function buscaEstouro(nriniseq , nrregist ) {

	var nrdconta = normalizaNumero($('#nrdconta','#frmCab').val());
	
	showMsgAguardo('Aguarde, buscando Estouros...');

	$('input').removeClass('campoErro');
	
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/estour/busca_estouro.php', 
		data    :
				{ 				  
				  nrdconta  : nrdconta,
				  nriniseq  : nriniseq,
				  nrregist  : nrregist,
				  redirect: 'script_ajax'				  
				  
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
				},
		success : function(response) { 
					hideMsgAguardo();
					
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							$('#divTabela').html(response);								
							return false;
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
						}
					} else {
						try {
							eval( response );
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
						}
					}
					
				}
	}); 
}

function formataTabela() {

	var divRegistro = $('div.divRegistros', divTabela );	
	
	var tabela      = $('table', divRegistro );
	
	selecionaEstouro($('table > tbody > tr:eq(0)', divRegistro));

	divRegistro.css({'height':'207px','border-bottom':'1px dotted #777','padding-bottom':'2px'});	
	divTabela.css({'padding-top':'10px'});	
		
	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '50px';
	arrayLargura[1] = '90px';
	arrayLargura[2] = '50px';
	arrayLargura[3] = '200px';
	arrayLargura[4] = '110px';
			
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'center';
	arrayAlinha[3] = 'left';	
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'right';
	
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	
	$('table > tbody > tr', divRegistro).focus( function() {
		selecionaEstouro($(this));
	});
	
	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		selecionaEstouro($(this));		
	});	
	
	divTabela.css({'display':'block'});	
	
	formataConsulta();
	
	return false;
}

function formataConsulta(){

	var cTodosConsulta = $('input[type="text"],select','#divEstouro');
	
	var rNrdctabb = $('label[for="nrdctabb"]','#divEstouro');
	var rNrdocmto = $('label[for="nrdocmto"]','#divEstouro');
	var rCdobserv = $('label[for="cdobserv"]','#divEstouro');
	var rDscodant = $('label[for="dscodant"]','#divEstouro');
	var rDscodatu = $('label[for="dscodatu"]','#divEstouro');
				
	var cNrdctabb = $('#nrdctabb','#divEstouro');	
	var cNrdocmto = $('#nrdocmto','#divEstouro');	
	var cCdobserv = $('#cdobserv','#divEstouro');	
	var cDsobserv = $('#dsobserv','#divEstouro');
	var cDscodant = $('#dscodant','#divEstouro');
	var cDscodatu = $('#dscodatu','#divEstouro');
		
	rNrdctabb.css({'width':'81px'}).addClass('rotulo');
	rNrdocmto.css({'width':'80px'}).addClass('rotulo-linha');
	rCdobserv.css({'width':'80px'}).addClass('rotulo-linha');
	rDscodant.css({'width':'80px'}).addClass('rotulo');
	rDscodatu.css({'width':'80px'}).addClass('rotulo-linha');
				
	cNrdctabb.css({'width':'90px'}).setMask('INTEGER','z.zzz.zzz.9','.','');
	cNrdocmto.css({'width':'90px'}).setMask('INTEGER','z.zzz.zzz.9','.','');
	cCdobserv.css({'width':'30px'});
	cDsobserv.css({'width':'200px'});
	cDscodant.css({'width':'265px'});	
	cDscodatu.css({'width':'235px'});	
	
	cTodosConsulta.desabilitaCampo();
		
	layoutPadrao();

	return false;
}


function selecionaEstouro(tr){ 
	
	$('#nrdconta','#divEstouro').val( $('#nrdconta', tr ).val() );
	$('#nmprimtl','#divEstouro').val( $('#nmprimtl', tr ).val() );
	$('#qtddtdev','#divEstouro').val( $('#qtddtdev', tr ).val() );
	$('#cdagenci','#divEstouro').val( $('#cdagenci', tr ).val() );
	$('#nrdctabb','#divEstouro').val( $('#nrdctabb', tr ).val() );
	$('#nrdocmto','#divEstouro').val( $('#nrdocmto', tr ).val() );
	$('#cdobserv','#divEstouro').val( $('#cdobserv', tr ).val() );
	$('#dsobserv','#divEstouro').val( $('#dsobserv', tr ).val() );
	$('#vllimcre','#divEstouro').val( $('#vllimcre', tr ).val() );
	$('#dscodant','#divEstouro').val( $('#dscodant', tr ).val() );
	$('#dscodatu','#divEstouro').val( $('#dscodatu', tr ).val() );
			
	
	return false;
}

function sequenciaImpedimentos() {
    if (executandoImpedimentos) {	
		eval(produtosCancM[posicao - 1]);
		posicao++;
		return false;
    }
}

/*!
 * FONTE        : blqrgt.js
 * CRIAÇÃO      : Lucas Lunelli          
 * DATA CRIAÇÃO : 17/01/2013
 * OBJETIVO     : Biblioteca de funções da tela BLQRGT
 * --------------
 * ALTERAÇÕES   : 26/05/2014 - Adicionado parametro cddopcao para buscar as informacoes das aplicacoes (Douglas - Chamado 77209)
 *				  28/10/2014 - Inclusão do parametro idtipapl para novos produtos de captacao(Jean Michel).
 *				  11/04/2017 - Permitir acessar o Ayllos mesmo vindo do CRM. (Jaison/Andrino)
 *				  16/11/2017 - Tela remodelada para o projeto 404 (Lombardi).
 *                18/12/2017 - P404 - Inclusão de Garantia de Cobertura das Operações de Crédito (Augusto / Marcos (Supero))
 *				  
 * --------------
 */

// Definição de algumas variáveis globais 
var cddopcao		='C';
var nrdconta 		= 0 ;
var idtipapl 		= '';
var cddopcao 		= 0 ;
var dsdconta 		= ''; // Armazena o Nome do Associado
var nmprodut		= ''; // Nome do produto

//Formulários
var frmCab   		= 'frmCab';

//Labels/Campos do cabeçalho
var rCddopcao, cCddopcao, rNrdconta, cNrdconta, cNmprimtl, cTodosCabecalho, btnCab,
	glb_idcobertura, glb_vlopera;

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
	$('#frmCab').css({'display':'block','width':'700px'});
		
	formataCabecalho();
	cTodosCabecalho.limpaFormulario();
	cCddopcao.val( cddopcao );
	
	removeOpacidade('divTela');

    // Seta os valores caso tenha vindo do CRM
    if ($("#crm_inacesso","#frmCab").val() == 1) {
        $("#nrdconta","#frmCab").val($("#crm_nrdconta","#frmCab").val());
    }
	
	unblockBackground();
	hideMsgAguardo();
	
	$('#nrdconta','#frmCab').desabilitaCampo();
	
	$("#btSalvar","#divBotoes").hide();
	$("#btVoltar","#divBotoes").hide();
	
	$('input,select', '#frmCab').removeClass('campoErro');
	$('#divBloqueios').html('');
	$('#divRotina').html('');
	
	controlaFoco();
		
}

function controlaFoco() {

	var bo, procedure, titulo;	
	
	$('#cddopcao','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				$('#btnOK','#frmCab').focus();
				return false;
			}	
	});
	
	$('#btnOK','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				LiberaCampos();
				$('#nrdconta','#frmCab').focus();
				return false;
			}	
	});
	
	$('#nrdconta','#frmCab').unbind('keypress').bind('keypress', function(e) {
      var val = normalizaNumero(e.target.value);
			if ( e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 118 ) {	
			if ($('#nmprimtl','#frmCab').val() == '' || nrdconta != val) {
        nrdconta = val;
				controlaPesquisaConta();
				return false;
			} else {
				btnContinuar();
				return false;
			}
		}	
	});
	
}

function formataCabecalho() {

	// cabecalho
	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab); 
	rNrdconta			= $('label[for="nrdconta"]','#'+frmCab); 
	
	cCddopcao			= $('#cddopcao','#'+frmCab); 
	cNrdconta			= $('#nrdconta','#'+frmCab); 
	cNmprimtl			= $('#nmprimtl','#'+frmCab); 
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	btnCab				= $('#btOK','#'+frmCab);
	
	rCddopcao.css('width','44px');
	rNrdconta.addClass('rotulo-linha').css({'width':'41px'});
	
	cCddopcao.css({'width':'610px'});
	cNrdconta.addClass('conta pesquisa').css({'width':'118px'});
	cNmprimtl.addClass('alphanum').css({'width':'425px'}).attr('maxlength','50');
	
	if ( $.browser.msie ) {
		rNrdconta.css({'width':'44px'});
		cNrdconta.css({'width':'118px'});
	}	
	
	cTodosCabecalho.habilitaCampo();
	cNmprimtl.desabilitaCampo();
	
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

	// Desabilita campo opção
	cTodosCabecalho		= $('input[type="text"],select','#frmCab'); 
	cTodosCabecalho.desabilitaCampo();

	$('#nrdconta','#frmCab').habilitaCampo();
	
	$('#divBotoes', '#divTela').css({'display':'block'});
	
	$("#btSalvar","#divBotoes").show();
	$("#btVoltar","#divBotoes").show();
	
	$('#nrdconta','#frmCab').focus();

	return false;

}

function btnContinuar() {

	var val = normalizaNumero( cNrdconta.val() );
	
	cddopcao = cCddopcao.val();
	
	nmprimtl = $('#nmprimtl','#frmCab').val();
	
	// Verifica se o número da conta é vazio
	if ( val == '' ) { return false; }
	
	if ( nmprimtl == '' || val != nrdconta ) {
		nrdconta = val;
		controlaPesquisaConta();
		return false;
	}

	// Verifica se a conta é válida
	if ( !validaNroConta(val) ) { 
		showError('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'val\',\''+ frmCab +'\');'); 
		return false; 
	}
	
	// Se chegou até aqui, a conta é diferente do vazio e é válida, então realizar a operação desejada
	buscaBloqueios();
	
	return false;
		
}

function buscaBloqueios() {
	// Mostra mensagem de aguardo
	
	showMsgAguardo("Aguarde, buscando bloqueios...");
	
	var nrdconta = $('#nrdconta','#frmCab').val();
	nrdconta = normalizaNumero(nrdconta);
		
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/blqrgt/busca_blqrgt.php", 
		data: {
			cddopcao: cddopcao,
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
				$('#divBloqueios').html(response);
				formataBloqueiosAplicacao();
				formataBloqueiosCobertura();
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});	
}

function realizaOperacao(tpaplica, idtipapl, nraplica, nmprodut) {

	// Mostra mensagem de aguardo
	
	if (cddopcao == "C"){  	   showMsgAguardo("Aguarde, consultando aplicacao..."); } 
	else if (cddopcao == "B"){ showMsgAguardo("Aguarde, bloqueando aplicacao...");  }
	else if (cddopcao == "V"){ showMsgAguardo("Aguarde, verificando conta...");  }	
	else { showMsgAguardo("Aguarde, liberando aplicacao..."); }
	
	var nrdconta = $('#nrdconta','#frmCab').val();
	nrdconta = normalizaNumero(nrdconta);
		
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/blqrgt/manter_rotina.php", 
		data: {
			nrdconta: nrdconta,
			cddopcao: cddopcao,
			tpaplica: tpaplica,
			idtipapl: idtipapl,
			nraplica: nraplica,
			nmprodut: nmprodut,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});				
}

function controlaPesquisaConta() {

	// Se esta desabilitado o campo da conta
	if ($("#nrdconta","#frmCab").prop("disabled") == true)  {
		return;
	}
	
	if ($("#nrdconta","#frmCab").val() ==  null ||
		$("#nrdconta","#frmCab").val() ==  "" 	   )  {
		mostraPesquisaAssociado('nrdconta','frmCab','');
	} else {
		cddopcao = "V"; //Verificação de Conta/dv
		realizaOperacao();
    $('#divBloqueios').empty();
	}

	return false;
	
}

function formataBloqueiosAplicacao() {
  
  var tabela = $('table', '#divBloqueiosAplicacao' );
  //tabela.css({'width':'200px;'});
  $('#divBloqueiosAplicacao').css({'height':'100px','display':'block'});
  
  var ordemInicial = new Array();
  ordemInicial = [];

  var arrayLargura = new Array();
  arrayLargura[0] = '100px';
  arrayLargura[1] = '100px';
  
  if (cddopcao == 'L')
	arrayLargura[2] = '120px';
 
  var arrayAlinha = new Array();
  arrayAlinha[0] = 'center';
  arrayAlinha[1] = 'center';
  arrayAlinha[2] = 'right';
  
  if (cddopcao == 'L')
	arrayAlinha[3] = 'center';
  
  tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
  
  $('fieldset legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
  $('fieldset').css({'clear':'both','border':'1px solid #c0c0c0','margin':'3px 0px'});
  
  layoutPadrao();
	return false;
}
	
function formataBloqueiosCobertura() {
  
  var tabela = $('table', '#divBloqueiosCobertura' );
 
  $('#divBloqueiosCobertura').css({'height':'100px','display':'block'});
  
  var ordemInicial = new Array();
  ordemInicial = [[1,0]];

  var arrayLargura = new Array();
  arrayLargura[0] = '80px';
  arrayLargura[1] = '70px';
  arrayLargura[2] = '70px';
  arrayLargura[3] = '115px';
  arrayLargura[4] = '105px';
 
  var arrayAlinha = new Array();
  arrayAlinha[0] = 'center';
  arrayAlinha[1] = 'right';
  arrayAlinha[2] = 'center';
  arrayAlinha[3] = 'center';
  arrayAlinha[4] = 'right';
  arrayAlinha[5] = 'right';
  
  tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
  
  $('fieldset legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
  $('fieldset').css({'clear':'both','border':'1px solid #c0c0c0','margin':'3px 0px'});
  
  layoutPadrao();
	return false;
}

function formataConfirmaDesbloqueio () {
	// cabecalho
	rVldesblo = $('label[for="vldesblo"]','#frmValorDesbloq');
	cVldesblo = $('#vldesblo','#frmValorDesbloq');
	
	rVldesblo.addClass('rotulo-linha').css({'width':'100px'});
	cVldesblo.addClass('moeda').css({'width':'100px'}).habilitaCampo();;
				
	layoutPadrao();
	return false;	
}

function confirmaDesbloqueioApl(tpaplica,idtipapl, nraplica, nmprodut) {
	msg = "Voc&ecirc; tem certeza que deseja efetuar o desbloqueio da Aplica&ccedil;&atilde;o selecionada? <br> Observa&ccedil;&atilde;o: Ser&aacute; necess&aacute;ria aprova&ccedil;&atilde;o de seu Coordenador!";
	showConfirmacao(msg,"Confirma&ccedil;&atilde;o - Ayllos","pedeSenhaCoordenador(2,'realizaOperacao(\"" + tpaplica + "\", \"" + idtipapl + "\", \"" + nraplica + "\", \"" + nmprodut + "\");','divRotina');","","sim.gif","nao.gif");
	return false;
}

function confirmaDesbloqueioCob(idcobertura, vlopera) {
	showMsgAguardo('Aguarde...');
	
	glb_idcobertura = idcobertura;
	glb_vlopera = vlopera;
	
	// Executa script de confirmação através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/blqrgt/confirma_desbloqueio_cobertura.php',
		data: {
			vlopera: vlopera,
			redirect: 'html_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();

			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			hideMsgAguardo();
			$('#divRotina').html(response);
			formataConfirmaDesbloqueio();
			exibeRotina($('#divRotina'));
			$('#divRotina').css({'margin-top': '170px'});
			$('#divRotina').css({'width': '300px'});
			$('#divRotina').centralizaRotinaH();
			bloqueiaFundo($('#divRotina'));
			layoutPadrao();

			return false;
		}
	});
}

function desbloqueioCobertura() {
	showMsgAguardo('Aguarde...');
	
	vldesblo = Number($('#vldesblo','#frmValorDesbloq').val().replace(/\./g, "").replace(/\,/g, "."));
	vlopera = Number(glb_vlopera.replace(/\./g, "").replace(/\,/g, "."));
	
	if (vldesblo < 0.01 || vldesblo > vlopera) { 
			hideMsgAguardo();
		showError('error','Valor a desbloquear inválido, favor informar um valor de R$0,01 até R$' + glb_vlopera + '.','Alerta - Ayllos',
		"$('#vldesblo','#frmValorDesbloq').focus();$('#vldesblo','#frmValorDesbloq').val('" + glb_vlopera + "');bloqueiaFundo($('#divRotina'));");
		return false;
	}
	pedeSenhaCoordenador(2,'efetuaDesbloqueio(\'' + vldesblo + '\',glb_codigoOperadorLiberacao);','divRotina','divRotina');
	return false;
}

function efetuaDesbloqueio (vldesblo, cdopelib) {
	
	// Executa script de confirmação através de ajax
	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/blqrgt/desbloqueio_cobertura.php',
		data: {
			idcobertura: glb_idcobertura,
			vldesblo: vldesblo,
			cdopelib: cdopelib,
			redirect: 'html_ajax'
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();

			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			hideMsgAguardo();
			eval(response);
			return false;
		}
	});
}
/*!
 * FONTE        : blqrgt.js
 * CRIAÇÃO      : Lucas Lunelli          
 * DATA CRIAÇÃO : 17/01/2013
 * OBJETIVO     : Biblioteca de funções da tela BLQRGT
 * --------------
 * ALTERAÇÕES   : 26/05/2014 - Adicionado parametro cddopcao para buscar as informacoes das aplicacoes (Douglas - Chamado 77209)
 *				  28/10/2014 - Inclusão do parametro idtipapl para novos produtos de captacao(Jean Michel).
 *				  11/04/2017 - Permitir acessar o Ayllos mesmo vindo do CRM. (Jaison/Andrino)
 * --------------
 */

// Definição de algumas variáveis globais 
var cddopcao		='C';
var nrdconta 		= 0 ;
var tpaplica 		= 0 ;
var idtipapl 		= '';
var nraplica 		= 0 ;
var cddopcao 		= 0 ;
var dsdconta 		= ''; // Armazena o Nome do Associado
var nmprodut		= ''; // Nome do produto

//Formulários
var frmCab   		= 'frmCab';

//Labels/Campos do cabeçalho
var rCddopcao, rNrdconta, rTpaplica, rNraplica,
	cCddopcao, cNrdconta, cTpaplica, cNraplica, cNmprimtl, cTodosCabecalho, btnCab;

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
	$('#tpaplica','#frmCab').val('1');
	$('#tpaplica','#frmCab').desabilitaCampo();
	$('#nraplica','#frmCab').desabilitaCampo();
	
	$("#btSalvar","#divBotoes").hide();
	$("#btVoltar","#divBotoes").hide();
	
	$('input,select', '#frmCab').removeClass('campoErro');
	
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
			if ( e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 118 ) {	
				controlaPesquisaConta();
				return false;
			}	
	});
	
	$('#tpaplica','#frmCab').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				$('#nraplica','#frmCab').focus();
				return false;
			}
	});
	
	$('#nraplica','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 || e.keyCode == 118 ) {	
			if ( $('#nraplica','#frmCab').val() == '' ) {
				controlaPesquisaNrApl();
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
	rTpaplica			= $('label[for="tpaplica"]','#'+frmCab); 
	rNraplica			= $('label[for="nraplica"]','#'+frmCab); 
	
	cCddopcao			= $('#cddopcao','#'+frmCab); 
	cNrdconta			= $('#nrdconta','#'+frmCab); 
	cTpaplica			= $('#tpaplica','#'+frmCab); 
	cNraplica			= $('#nraplica','#'+frmCab); 
	cNmprimtl			= $('#nmprimtl','#'+frmCab); 
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	btnCab				= $('#btOK','#'+frmCab);
	
	rCddopcao.css('width','44px');
	rNrdconta.addClass('rotulo-linha').css({'width':'41px'});
	rTpaplica.addClass('rotulo-linha').css({'width':'41px'});
	rNraplica.addClass('rotulo-linha').css({'width':'41px'});
	
	cCddopcao.css({'width':'496px'});
	cNrdconta.addClass('conta pesquisa').css({'width':'118px'});
	cTpaplica.css({'width':'139px'});
	cNraplica.addClass('inteiro').css({'width':'100px'}).attr('maxlength','10'); 
	cNraplica.setMask('INTEGER','z.zzz.zzz','.-','');
	cNmprimtl.addClass('alphanum').css({'width':'390px'}).attr('maxlength','50');
	
	if ( $.browser.msie ) {
		rNrdconta.css({'width':'44px'});
		rTpaplica.css({'width':'20px'});
		rNraplica.css({'width':'40px'});
		cNrdconta.css({'width':'118px'});
		cTpaplica.css({'width':'139px'});
		cNraplica.css({'width':'110px'});
	}	
	
	cTodosCabecalho.habilitaCampo();
	cTpaplica.desabilitaCampo();
	cNraplica.desabilitaCampo();
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
	
	if (!($('#nmprimtl','#frmCab').val() == "")){
	
		$('#tpaplica','#frmCab').habilitaCampo();
		$('#nraplica','#frmCab').habilitaCampo();		
		$('#tpaplica','#frmCab').focus();
		
		return false;
		
	}
	
	$('#divBotoes', '#divTela').css({'display':'block'});
	
	$("#btSalvar","#divBotoes").show();
	$("#btVoltar","#divBotoes").show();
	
	$('#nrdconta','#frmCab').focus();

	return false;

}

function btnContinuar() {

	var aplDados = cTpaplica.val();
	var arrDados = aplDados.split(',');
	
	nrdconta = normalizaNumero( cNrdconta.val() );
	tpaplica = arrDados[0];
	idtipapl = arrDados[1];
	nmprodut = arrDados[2];
	
	nraplica = normalizaNumero( cNraplica.val() );	
	cddopcao = cCddopcao.val();
	
	nmprimtl = $('#nmprimtl','#frmCab').val();
	
	// Verifica se o número da conta é vazio
	if ( nrdconta === '' || nmprimtl == '') { return false; }

	// Verifica se a conta é válida
	if ( !validaNroConta(nrdconta) ) { 
		showError('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'nrdconta\',\''+ frmCab +'\');'); 
		return false; 
	}
	
	// Se chegou até aqui, a conta é diferente do vazio e é válida, então realizar a operação desejada
	realizaOperacao();
	
	return false;
		
}

function realizaOperacao() {

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
	}

	return false;
	
}

function controlaPesquisaNrApl() {

	// Se esta desabilitado o campo contrato
	if ($("#nraplica","#frmCab").prop("disabled") == true)  {
		return;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, nraplica, titulo_coluna;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmCab';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var aplDados = cTpaplica.val();
	var arrDados = aplDados.split(',');
	
	tpaplica = arrDados[0];
	idtipapl = arrDados[1];
	nmprodut = arrDados[2];
	
	var nraplica = $('#nraplica','#'+nomeFormulario).val();
	var nrdconta = $('#nrdconta','#'+nomeFormulario).val();
	var cddopcao = $('#cddopcao','#'+nomeFormulario).val();
		
	nrcontdv = nrdconta;
	nrdconta = normalizaNumero(nrdconta);	
	titulo_coluna = "Saldo";
		
	bo			= 'b1wgen0148.p';
	procedure	= 'lista-aplicacoes';
	titulo      = 'Aplica&ccedil;&otilde;es';
	qtReg		= '10';
	filtros 	= 'Nr.Aplic.;nraplica;130px;S;' + nraplica + ';S|conta;nrdconta;100px;S;' + nrdconta + ';N|Tp.Aplic;tpaplica;100px;S;' + tpaplica + ';N|Idtipapl;idtipapl;100px;S;' + idtipapl + ';N|Nmprodut;nmprodut;100px;S;' + nmprodut + ';N|Opcao;cddopcao;50px;S;' + cddopcao + ';N';
	colunas 	= 'Nr.Aplic.;nraplica;20%;right|' + titulo_coluna + ';sldresga;50%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas,'','$(\'#nrdconta\',\'#frmCab\').val(nrcontdv)');
	
	return false;

}
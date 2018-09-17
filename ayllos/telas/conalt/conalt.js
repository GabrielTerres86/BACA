/*!
 * FONTE        : conalt.js
 * CRIAÇÃO      : Guilherme
 * DATA CRIAÇÃO : 13/06/2011
 * OBJETIVO     : Biblioteca de funções da tela conalt
 * --------------
 * ALTERAÇÕES   :
 * 28/06/2012 - Jorge         (CECRED) : Alterado funcao imprime(), ajuste para novo esquema de impressao
 * 15/06/2012 - Guilherme Maba(CECRED) : Incluído estilo de cor azul nos campos quando foco estiver ativo(highlightObjFocus);
										 Incluído navegação entre os campos do formulário utilizando a tecla ENTER;
										 Incluído validação na impressão caso campos não forem preenchidos .
   14/08/2013 - Carlos        (CECRED) : Alteração da sigla PAC para PA (Carlos).
   11/04/2014 - Carlos        (CECRED) : Retiradas as validações de PA nao informados pois o PA pode ser zero (Todos).
 * --------------
 */

// Definição de algumas variáveis globais 
var operacao 		= ''; // Armazena a operação corrente da tela AUTORI

var frmCabConalt	= 'frmCabConalt';
var frmConalt		= 'frmConalt';

var cdidenti 		= 0; 
var msgretor		= '';

// Fieldset do formulario
var fCabecalho		= ''; // formulario cabecalho
var fAltConta		= ''; // fieldset conta
var fTransfPAC		= ''; // fieldset contribuinte

var nrJanelas   = 0; // Variável para contagem do número de janelas abertas para impressão

$(document).ready(function() {

	fCabecalho		= $('input[type="text"],select','#'+frmCabConalt);
	fAltConta		= $('input[type="text"],select','#'+frmConalt + ' fieldset:eq(0)'); // fieldset alteracao
	fTransfPAC		= $('input[type="text"],select','#'+frmConalt + ' fieldset:eq(1)'); // fieldset transferencia

	estadoInicial();

});


// Controles
function estadoInicial() {
	
	// variaveis globais
	operacao = '';
	cdidenti = 0; 
	msgretor = '';		

	// 		
	fechaRotina($('#divRotina'));
	
	// limpa formularios
	fCabecalho.limpaFormulario();
	fAltConta.limpaFormulario();
	fTransfPAC.limpaFormulario();
	
	// habilita foco no formulário inicial
	highlightObjFocus($('#frmCabConalt'));
	// retira html da tabela de conteúdo
	$('#divAltContaTabela', '#divAltConta').html('');
	$('#divTransfTabela', '#divTransfPAC').html('');
	
	// formata
	controlaLayout();
	 
}

function controlaOperacao() {

	switch (operacao) {
		// Consulta
		case 'C1': formataCabecalho(); 	operacao='C2'; 	return false; break;
		case 'C2': manterRotina(); operacao = 'C1'; return false; break;
		// Transf pac
		case 'T1': formataCabecalho(); 	operacao='T2'; 	return false; break;
		case 'T2': manterRotina(); operacao = 'T1'; return false; break;
		default: return false; break;		
	}

}

function manterRotina() {

	highlightObjFocus($('#frmConalt'));

	var mensagem = '';
		
	hideMsgAguardo();		
	
	switch (operacao) {	
		case 'C1': mensagem = 'Aguarde, carregando...'; $('#btImprimir.botao','#divBotoes').css('display','none');$('#btVisualizar.botao','#divBotoes').css('display','none');$('#divTransfPAC').css({'display':'none'}); $('#divAltConta').css({'display':'block'}); break;
		case 'C2': mensagem = 'Aguarde, buscando dados...'; break;

		case 'T1': mensagem = 'Aguarde, carregando...'; 	$('#btImprimir.botao','#divBotoes').css('display','inline');$('#btVisualizar.botao','#divBotoes').css('display','inline');$('#divTransfPAC').css({'display':'block'}); $('#divAltConta').css({'display':'none'}); break;
		case 'T2': mensagem = 'Aguarde, buscando dados...'; break;

		default: return false; break;
	}
	
	showMsgAguardo( mensagem );	

	// opcao c
	var nrdconta = normalizaNumero($('#nrdconta', '#'+frmConalt).val());

	// opcao t
	var nrpacori = normalizaNumero($('#nrpacori', '#'+frmConalt).val());
	var nrpacdes = normalizaNumero($('#nrpacdes', '#'+frmConalt).val());
	var dtperini = $('#dtperini', '#'+frmConalt).val();
	var dtperfim = $('#dtperfim', '#'+frmConalt).val();

	$.ajax({		
			type  : 'POST',
			async : true ,
			url   : UrlSite + 'telas/conalt/manter_rotina.php', 		
			data: {
				operacao: operacao,	
				nrdconta: nrdconta,
				nrpacori: nrpacori, nrpacdes: nrpacdes,
				dtperini: dtperini, dtperfim: dtperfim,
				redirect: 'script_ajax'
			}, 
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','1 N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
			},
			success: function(response) {
				try {
					eval(response);
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','2 N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				}
			}
		});
	return false;	
	                     
}       	

function controlaLayout() {

	$('#divTela').fadeTo(0,0.1);
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('#divBotoes').css({'text-align':'center','padding-top':'5px'});
	
	$('#divTransfPAC').css({'display':'none'}); 
	$('#divAltConta').css({'display':'none'});
	

	formataCabecalho();	
	formataConta();
	formataAltConta();
	formataTransfPAC();
	
	layoutPadrao();
	controlaPesquisas();
	controlaFoco();
	removeOpacidade('divTela');
	return false;
	
}

function controlaFoco() {
		
	$('#opcao','#'+frmCabConalt).focus()

	return false;
}

function controlaPesquisas() {
	
	$('a').each( function() {
		if ( !$(this).prev().hasClass('campoTelaSemBorda') ) { $(this).css('cursor','pointer'); }
	});

	/*---------------------*/
	/*  CONTROLE CONTA/DV  */
	/*---------------------*/
	var linkConta = $('a:eq(0)','#frmConalt' + ' fieldset:eq(0)');

	linkConta.css('cursor','pointer').unbind('click').bind('click', function() {			
		mostraPesquisaAssociado('nrdconta','frmConalt');
	});
	
	
}


// Formatações
function formataCabecalho() {
	
	highlightObjFocus($('#frmCabConalt'));
	
	// formata os rotulos
	var rOpcao    	= $('label[for="opcao"]','#'+frmCabConalt);	
	var rConta      = $('label[for="nrdconta"]','#'+frmConalt);
	
	rOpcao.addClass('rotulo').css('width','46px');
	rConta.addClass('rotulo-linha');

	// formatas os campos
	var cOpcao    	= $('#opcao','#'+frmCabConalt);
	var cConta      = $('#nrdconta','#'+frmConalt);
	var cNrpacori	= $('#nrpacori','#'+frmConalt);
	
	cOpcao.css('width','454px');
	cConta.addClass('conta pesquisa').css('width','76px');

	// operacao
	if ( operacao == 'C1' || operacao == 'C2') {
		cConta.habilitaCampo().focus();
	} if ( operacao == 'T1' || operacao == 'T2') {
		cNrpacori.focus();	
	}else {
		cOpcao.habilitaCampo();
		cOpcao.val('C1');
	}	
	
	// retira funções do onclick para não repetir com o BIND
	cOpcao.next().attr('onclick', '');
	// Se pressionar o botao OK
	cOpcao.next().unbind('click').bind('click', function() { 	
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( cOpcao.hasClass('campoTelaSemBorda') ) { return false; }
		
		operacao = cOpcao.val();

		// limpa formulario
		$('#frmConalt').limpaFormulario();
		
		// limpa os divs de tabela
		$('#divAltContaTabela').html('');
		$('#divTransfTabela').html('');
		
		// esconde os divs de tabela
		$('#divAltContaTabela').hide();
		$('#divTransfTabela').hide();

		manterRotina();

		return false;
		
	});	
	
	cOpcao.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 ) {
			cOpcao.next().focus();
			return false;
		}
	});	

	return false;	
}

function formataConta() {

	// rotulo
	var rNrdconta	= $('label[for="nrdconta"]','#'+frmConalt);			
	
	rNrdconta.addClass('rotulo').css({'width':'56px'});
	
	// campo
	var cNrdconta   = $('#nrdconta','#'+frmConalt);

	cNrdconta.addClass('pesquisa conta').css('width','75px');

	// Se pressionar tecla ENTER no campo Conta
	cNrdconta.unbind('keypress').bind('keypress', function(e) {	
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( e.keyCode == 13 ) { 
			
			var nrdconta = normalizaNumero( $(this).val() );
			
			// Verifica se o número da conta é vazio
			if ( nrdconta == '' ) { return false; }
		
			// Verifica se a conta é válida
			if ( !validaNroConta(nrdconta)) { 
				showError('error','Conta/dv inválida.','Alerta - Ayllos','$(\'#nrdconta\',\'#frmConalt\').focus();'); 
				return false; 
			}
			
			// tira borda do erro
			$("input","#frmConalt").removeClass("campoErro");			
			
			manterRotina();

			return false;
			
		}

	});

	return false;	

}

function formataAltConta() {

	// rotulos 
	var rDsagenci	= $('label[for="dsagenci"]','#'+frmConalt);
	var rNrmatric	= $('label[for="nrmatric"]','#'+frmConalt);
	var rDstipcta	= $('label[for="dstipcta"]','#'+frmConalt);
	var rDtabtcct	= $('label[for="dtabtcct"]','#'+frmConalt);
	var rDssititg	= $('label[for="dssititg"]','#'+frmConalt);
	var rDtatipct	= $('label[for="dtatipct"]','#'+frmConalt);
	var rNmprimtl	= $('label[for="nmprimtl"]','#'+frmConalt);	
	var rNmsegntl	= $('label[for="nmsegntl"]','#'+frmConalt);	
	
	rDsagenci.addClass('rotulo-linha').css('width','35px');
	rNrmatric.addClass('rotulo-linha').css('width','60px');
	rDstipcta.addClass('rotulo').css('width','83px');
	rDtabtcct.addClass('rotulo-linha').css('width','120px');
	rDssititg.addClass('rotulo').css('width','83px');
	rDtatipct.addClass('rotulo-linha').css('width','195px');
	rNmprimtl.addClass('rotulo').css('width','83px');
	rNmsegntl.addClass('rotulo').css('width','83px');
	
	// campos
	var cDsagenci	= $('#dsagenci','#'+frmConalt);
	var cNrmatric	= $('#nrmatric','#'+frmConalt);
	var cDstipcta	= $('#dstipcta','#'+frmConalt);
	var cDtabtcct	= $('#dtabtcct','#'+frmConalt);
	var cDssititg	= $('#dssititg','#'+frmConalt);
	var cDtatipct	= $('#dtatipct','#'+frmConalt);
	var cNmprimtl	= $('#nmprimtl','#'+frmConalt);	
	var cNmsegntl	= $('#nmsegntl','#'+frmConalt);	
	
	cDsagenci.addClass('campo alphanum').css('width','190px');
	cNrmatric.addClass('campo inteiro').css('width','80px');
	cDstipcta.addClass('campo alphanum').css('width','200px');
	cDtabtcct.addClass('campo data').css('width','85px');
	cDssititg.addClass('campo alphanum').css('width','125px');
	cDtatipct.addClass('campo alphanum').css('width','85px');
	cNmprimtl.addClass('campo alphanum').css('width','410px');
	cNmsegntl.addClass('campo alphanum').css('width','410px');
	
	$('#divBotaoTransfPAC').css({'text-align':'center','padding-top':'5px'});
	$('#btImprimir.botao','#divBotoes').css('display','none');
	$('#btVisualizar.botao','#divBotoes').css('display','none');
	
	fAltConta.desabilitaCampo();
	
	return false;	
}

function formataTransfPAC() {

	// rotulos 
	var rNrpacpac	= $('label[for="nrpacpac"]','#'+frmConalt);
	var rNrpacori	= $('label[for="nrpacori"]','#'+frmConalt);
	var rNrpacdes	= $('label[for="nrpacdes"]','#'+frmConalt);
	var rDtperper	= $('label[for="dtperper"]','#'+frmConalt);
	var rDtperini	= $('label[for="dtperini"]','#'+frmConalt);
	var rDtperfim	= $('label[for="dtperfim"]','#'+frmConalt);
	
	rNrpacpac.addClass('rotulo').css('width','75px');
	rNrpacori.addClass('rotulo-linha').css('width','75px');
	rNrpacdes.addClass('rotulo-linha').css('width','150px');
	rDtperper.addClass('rotulo').css('width','75px');
	rDtperini.addClass('rotulo-linha').css('width','75px');
	rDtperfim.addClass('rotulo-linha').css('width','150px');
	

	// campos
	var cNrpacori	= $('#nrpacori','#'+frmConalt);
	var cNrpacdes	= $('#nrpacdes','#'+frmConalt);
	var cDtperini	= $('#dtperini','#'+frmConalt);
	var cDtperfim	= $('#dtperfim','#'+frmConalt);
	
	// botao visualizar
	var btVisualizar = $('#btVisualizar.botao','#divBotoes')
	
	cNrpacori.addClass('campo inteiro').css('width','85px').attr('maxlength','3');
	cNrpacdes.addClass('campo inteiro').css('width','85px').attr('maxlength','3');
	cDtperini.addClass('campo data').css('width','85px');
	cDtperfim.addClass('campo data').css('width','85px');
	
	// Se pressionar o botao OK
	cDtperfim.next().attr('onclick', '');
	cDtperfim.next().unbind('click').bind('click', function() {
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( cDtperfim.hasClass('campoTelaSemBorda') ) { return false; }

		manterRotina();
		
		cNrpacori.focus();
		
		highlightObjFocus($('#frmConalt'));
		
		return false;
		
	});

	cNrpacori.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 ) {
			cNrpacdes.focus();
			return false;
		}
	});
	cNrpacdes.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 ) {
			cDtperini.focus();
			return false;
		}
	});
	cDtperini.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 ) {
			cDtperfim.focus();
			return false;
		}
	});
	cDtperfim.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 ) {
			btVisualizar.focus();
			return false;
		}
	});
	
	return false;	
}

function formataTabelaAltConta() {

	var divRegistro = $('div.divRegistros','#divAltContaTabela');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'120px'});
	
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];
			
	var arrayLargura = new Array();
	arrayLargura[0] = '100px';
	arrayLargura[1] = '200px';
	
		
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'left';
	
	var metodoTabela = '';
			
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );
	
	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	
	return false;
}

function formataTabelaTransfPAC() {

	var divRegistro = $('div.divRegistros','#divTransfTabela');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'120px'});
	
	var ordemInicial = new Array();
	ordemInicial = [[3,0]]; // 4a coluna, ascendente
			
	var arrayLargura = new Array();
	
	arrayLargura[0] = '60px';
	arrayLargura[1] = '164px';
	arrayLargura[2] = '50px';
	arrayLargura[3] = '65px';
	arrayLargura[4] = '45px';
	
	var NavVersion = CheckNavigator();	
	if (NavVersion.navegador == 'msie') {
		arrayLargura[5] = '48px';
		arrayLargura[6] = '14px';
	} else {
		arrayLargura[5] = '49px';
		arrayLargura[6] = '15px';
	}
	
	
		
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'center';
	arrayAlinha[3] = 'center';
	arrayAlinha[4] = 'center';
	arrayAlinha[5] = 'center';
	
	var metodoTabela = '';
			
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );
	
	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	
	return false;
}

function imprime(idImpressao){

	// valida se campos forma preenchidos para executar impressão
	if ($('#dtperini', '#'+frmConalt).val() == '') {
		showError('error','Periodo inicio deve ser informado','Alerta - Ayllos','$(\'#dtperini\',\'#frmConalt\').focus();'); 
		return false; 
	} else if ($('#dtperfim', '#'+frmConalt).val() == '') {
		showError('error','Periodo fim deve ser informado','Alerta - Ayllos','$(\'#dtperfim\',\'#frmConalt\').focus();'); 
		return false; 
	}
	
	var action = UrlSite + 'telas/conalt/impressao_transf_pac.php';
	
	$('#sidlogin','#frmConalt').remove();	
	
	$('#frmConalt').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '" />');			
	
	carregaImpressaoAyllos("frmConalt",action);
	
}
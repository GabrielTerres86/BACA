/*!
 * FONTE        : cmaprv.js
 * CRIAÇÃO      : Rogerius Militão (DB1) 
 * DATA CRIAÇÃO : 29/09/2011
 * OBJETIVO     : Biblioteca de funções da tela CMAPRV
 * --------------
 * ALTERAÇÕES   :
 * 28/06/2012 - Jorge           (CECRED): Ajuste para novo esquema de impressao em funcoes Gera_Impressao()
 * 18/01/2013 - Daniel          (CECRED): Implantacao novo layout.
 * 28/02/2014 - Jorge           (CECRED): Adicionado class alphanum. 
 * 27/11/2014 - Jorge/Rosangela (CECRED): Adicionado funcao replaceChars(), utilizado em campo de observacao comite. SD - 218402
 * 16/03/2015 - Jonata          (RKAM)  : Incluir novo campo de Parecer de Credito.
 * 27/05/2015 - Douglas         (CECRED): Remover confirmação do complemento na impressão. Ajuste na inclusão de observação do comitê (Melhoria 18)
 * 27/05/2015 - Gabriel           (RKAM): Incluir situacao 3 para pedir a senha do coordenador tambem. 
 * 19/11/2015 - Lunelli			(CECRED): Correção de remoção de acentos na edição de OBS na operacao GD (Lucas Lunelli SD 323711)
 * --------------
 */

//Formulários
var frmCab   		= 'frmCab';
var tabDados		= 'tabCmaprv';
var frmDados  		= 'frmCmaprv';

var nrJanelas		= 0;
var cddopcao		= 'C';
var status			= new Array();

var seletor;

//Labels/Campos do cabeçalho
var rCddopcao, rCdagenci, rNrdconta, rDtpropos, rDtaprova, rDtaprfim, rAprovad1, rAprovad2, rCdopeapv,
	cCddopcao, cCdagenci, cNrdconta, cDtpropos, cDtaprova, cDtaprfim, cAprovad1, cAprovad2, cCdopeapv, cTodosCabecalho, btnOK;

var rQtpreemp, rVlpreemp, rDtmvtolt, rDsstatus, rInsitapv, rCdopeap1, rDtaprov1, rHrtransa,
	cQtpreemp, cVlpreemp, cDtmvtolt, cDsstatus, cInsitapv, cCdopeap1, cDtaprov1, cHrtransa, cTodosDados;


$(document).ready(function() {
	estadoInicial();
});


// seletores
function estadoInicial() {
	$('#divTela').css({'display':'inline'}).fadeTo(0,0.1);
	
	nrdcont1  = 0;
	nrctremp  = 0;	
	insitaux  = 0;	
	nrctrliq  = '';	
	vlemprst  = 0;	

	status[0] = '0-Nao Analisado';
	status[1] = '1-Aprovado';
	status[2] = '2-Nao Aprovado';
	status[3] = '3-Restricao';
	status[4] = '4-Refazer';
	
	nrJanelas = 0;
	trocaBotao('Prosseguir');
	
	$('#divPesquisaRodape').remove();
	$('#'+tabDados).remove();
	$('#'+frmDados).remove();
	
	hideMsgAguardo();		
	atualizaSeletor();
	formataCabecalho();

	cTodosCabecalho.limpaFormulario().removeClass('campoErro');	
	
	cCddopcao.habilitaCampo();
	cCddopcao.focus();
	cCddopcao.val( cddopcao );
	
	
	removeOpacidade('divTela');
	
	highlightObjFocus( $('#frmCab') );
	highlightObjFocus( $('#frmCmaprv') );
	
}

function atualizaSeletor(){

	// cabecalho
	rCddopcao			= $('label[for="cddopcao"]', '#'+frmCab); 
	rCdagenci			= $('label[for="cdagenci"]', '#'+frmCab); 
	rNrdconta			= $('label[for="nrdconta"]', '#'+frmCab); 
	rDtpropos			= $('label[for="dtpropos"]', '#'+frmCab);
	rDtaprova			= $('label[for="dtaprova"]', '#'+frmCab);
	rDtaprfim			= $('label[for="dtaprfim"]', '#'+frmCab);
	rAprovad1			= $('label[for="aprovad1"]', '#'+frmCab);
	rAprovad2			= $('label[for="aprovad2"]', '#'+frmCab);
	rCdopeapv			= $('label[for="cdopeapv"]', '#'+frmCab);
	
	cCddopcao			= $('#cddopcao', '#'+frmCab); 
	cCdagenci			= $('#cdagenci', '#'+frmCab); 
	cNrdconta			= $('#nrdconta', '#'+frmCab); 
	cDtpropos			= $('#dtpropos', '#'+frmCab);			
	cDtaprova			= $('#dtaprova', '#'+frmCab);			
	cDtaprfim			= $('#dtaprfim', '#'+frmCab);			
	cAprovad1			= $('#aprovad1', '#'+frmCab);			
	cAprovad2			= $('#aprovad2', '#'+frmCab);			
	cCdopeapv			= $('#cdopeapv', '#'+frmCab);			

	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	btnOK				= $('#btnOK','#'+frmCab);

	// dados
	rQtpreemp			= $('label[for="qtpreemp"]', '#'+frmDados);
	rVlpreemp			= $('label[for="vlpreemp"]', '#'+frmDados);
	rDtmvtolt			= $('label[for="dtmvtolt"]', '#'+frmDados);
	rDsstatus           = $('label[for="dsstatus"]', '#'+frmDados);
	rInsitapv			= $('label[for="insitapv"]', '#'+frmDados);
	rCdopeap1			= $('label[for="cdopeap1"]', '#'+frmDados);
	rDtaprov1			= $('label[for="dtaprov1"]', '#'+frmDados);
	rHrtransa			= $('label[for="hrtransa"]', '#'+frmDados);
	
	cQtpreemp			= $('#qtpreemp', '#'+frmDados); 	
	cVlpreemp			= $('#vlpreemp', '#'+frmDados); 	
	cDtmvtolt			= $('#dtmvtolt', '#'+frmDados); 
	cDsstatus           = $('#dsstatus', '#'+frmDados);
	cInsitapv			= $('#insitapv', '#'+frmDados); 
	cCdopeap1			= $('#cdopeap1', '#'+frmDados); 
	cDtaprov1			= $('#dtaprov1', '#'+frmDados); 	
	cHrtransa			= $('#hrtransa', '#'+frmDados); 

	cTodosDados			= $('input[type="text"],select','#'+frmDados);
	
	return false;
}


// controle
function controlaOperacao(nriniseq, nrregist) {
	
	var cddopcao = cCddopcao.val();
	var cdagenc1 = normalizaNumero( cCdagenci.val() );
	var nrdconta = normalizaNumero( cNrdconta.val() );
	var dtpropos = cDtpropos.val();
	var dtaprova = cDtaprova.val();
	var dtaprfim = cDtaprfim.val();
	var aprovad1 = normalizaNumero( cAprovad1.val() );
	var aprovad2 = normalizaNumero( cAprovad2.val() );
	var cdopeapv = cCdopeapv.val();
	
	var mensagem = 'Aguarde, buscando dados ...';
	showMsgAguardo( mensagem );	
	
	// Carrega dados da conta através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/cmaprv/principal.php', 
		data    : 
				{ 
					cddopcao	: cddopcao,
					cdagenc1	: cdagenc1,
					nrdconta	: nrdconta,
					dtpropos	: dtpropos,
					dtaprova	: dtaprova,
					dtaprfim	: dtaprfim,
					aprovad1	: aprovad1,
					aprovad2	: aprovad2,
					cdopeapv	: cdopeapv,
					nriniseq	: nriniseq,
					nrregist	: nrregist,
					redirect	: 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) { 
					hideMsgAguardo();
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							$('#divTela').html(response);
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

function replaceChars(str){
	str = typeof str !== 'undefined' ? str : "";
	str = str.split("\\r").join("").split("\\n").join("").split("'").join("").split("\\").join("");
	return str;
}

function manterRotina( operacao ) {

	hideMsgAguardo();
	
	var mensagem = '';
	
	// cabecalho
	var dtpropos = cDtpropos.val();
	var dtaprova = cDtaprova.val();
	var dtaprfim = cDtaprfim.val();
	var aprovad1 = cAprovad1.val();
	var aprovad2 = cAprovad2.val();
	
	// dados
	var nrdcont1 = $('#nrdcont1','#'+frmDados).val();
	var nrctremp = $('#nrctremp','#'+frmDados).val();
	var insitapv = $('#insitapv','#'+frmDados).val();
	var insitaux = $('#insitaux','#'+frmDados).val();
	var nrctrliq = $('#nrctrliq','#'+frmDados).val();
	var vlemprst = $('#vlemprst','#'+frmDados).val();
	
	// novo status
	var insitapv = cInsitapv.val();
	var dsapraux = status[insitapv] +' - '+ dscomite; 	
	
	// motivo
	var dsobstel = replaceChars($('#dsobscmt', '#frmComplemento').val());
    var dscmaprv = $('#dscmaprv', '#frmComplemento').val();
	var flgalter = $('#flgalter', '#frmComplemento').val() == 'alterar' ? 'yes' : 'no';
	
	switch(operacao) {
	
		case 'VD': mensagem = 'Aguarde, validando dados...'; break;
		case 'VR': mensagem = 'Aguarde, verificando rating...'; break;
		case 'VM': mensagem = 'Aguarde, verificando motivo...'; break;
		case 'CO': 
			showConfirmacao('Confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','manterRotina(\'GD\');','fechaRotina( $(\'#divRotina\') );','sim.gif','nao.gif');
			return false; 
		break;
		case 'GD': mensagem = 'Aguarde, gravando dados...'; break;
	}

	fechaRotina( $('#divRotina') );
	showMsgAguardo( mensagem );	
	
	$.ajax({		
			type  : 'POST',
			url   : UrlSite + 'telas/cmaprv/manter_rotina.php', 		
			data: {
				operacao	: operacao,
				
				// cabecalho
				cddopcao	: cddopcao,
				dtpropos    : dtpropos,
				dtaprova    : dtaprova,
				dtaprfim    : dtaprfim,
				aprovad1    : aprovad1,
				aprovad2    : aprovad2,
				
				// dados
				nrdcont1	: nrdcont1, // emprestimo
				nrctremp	: nrctremp, // emprestimo
				insitapv	: insitapv, // formulario
				insitaux	: insitaux, // emprestimo
				nrctrliq	: nrctrliq, // emprestimo
				vlemprst	: vlemprst, // emprestimo
				
				dsobstel	: dsobstel, // motivo
				dscmaprv	: dscmaprv, // motivo
				flgalter	: flgalter, // motivo
				
				dsapraux	: dsapraux,
				redirect	: 'script_ajax'
			}, 
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
			},
			success: function(response) {
				try {
					eval(response);
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				}
			}
		});

	return false;	
	                     
}       	

function controlaPesquisas() {

	var bo 			= '';
	var procedure	= '';
	var titulo      = '';
	var qtReg		= '';
	var filtrosPesq	= '';
	var colunas 	= '';


	/*---------------------*/
	/*    NÃO APROVACAO    */
	/*---------------------*/
	var linkAprovacao = $('a:eq(0)','#frmComplemento');
		
	if ( linkAprovacao.prev().hasClass('campoTelaSemBorda') ) {		
		linkAprovacao.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {

		linkAprovacao.prev().unbind('blur').bind('blur', function() { 
			controlaPesquisas();
			return false;
		});	

		linkAprovacao.css('cursor','pointer').unbind('click').bind('click', function() {			
			bo 			= 'b1wgen0059.p';
			procedure	= 'busca_motivos_nao_aprovacao';
			titulo      = 'Motivo de não Aprovação';
			qtReg		= '30';
			filtrosPesq	= 'Código;cdcmaprv;30px;S;0|Descrição;dscmaprv;200px;S';
			colunas 	= 'Código;cdcmaprv;20%;right|Descrição;dscmaprv;80%;left';
			mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas,$('#divRotina'));
			return false;
		});
	}
	
	return false;
}

function buscaAprovacao() {
	
	var valor		= $('#cdcmaprv', '#frmComplemento').val();
	var bo			= 'b1wgen0059.p';
	var procedure	= 'busca_motivos_nao_aprovacao';
	var titulo      = 'Motivo de não Aprovação';
	var filtrosDesc = 'cdcmaprv|'+valor;
	buscaDescricao(bo,procedure,titulo,'cdcmaprv','dscmaprv',valor,'dscmaprv',filtrosDesc,'frmComplemento');
	return false;
}


// formata
function formataCabecalho() {
	
	rCddopcao.addClass('rotulo').css({'width':'54px'});
	rCdagenci.addClass('rotulo-linha').css({'width':'51px'});
	rNrdconta.addClass('rotulo-linha').css({'width':'63px'});
	rDtpropos.addClass('rotulo-linha').css({'width':'135px'});
	rDtaprova.addClass('rotulo').css({'width':'54px'});
	rDtaprfim.addClass('rotulo-linha').css({'width':'20px'});
	rAprovad1.addClass('rotulo-linha').css({'width':'62px'});
	rAprovad2.addClass('rotulo-linha').css({'width':'20px'});
	rCdopeapv.addClass('rotulo').css({'width':'54px'});
	
	cCddopcao.css({'width':'500px'});
	cCdagenci.addClass('inteiro').css({'width':'45px'}).attr('maxlength','3');	
	cNrdconta.addClass('conta pesquisa').css({'width':'75px'});	
	cDtpropos.addClass('data').css({'width':'80px'});	
	cDtaprova.addClass('data').css({'width':'80px'});
	cDtaprfim.addClass('data').css({'width':'80px'});	
	cAprovad1.css({'width':'127px'});	
	cAprovad2.css({'width':'128px'});	
	cCdopeapv.addClass('alphanum').css({'width':'187px'}).attr('maxlength','10');	
	
	if ( $.browser.msie ) {
		rCddopcao.css({'width':'57px'});
		rDtaprova.css({'width':'57px'});
		rCdopeapv.css({'width':'57px'});
		rCdagenci.css({'width':'57px'});
	}	
	
	cTodosCabecalho.desabilitaCampo();	
	
	// evento no botao OK
	btnOK.unbind('click').bind('click', function() { 	
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( cCddopcao.hasClass('campo') ) {
			cddopcao = cCddopcao.val();
			cCddopcao.desabilitaCampo();
			cCdagenci.habilitaCampo();
			cCdagenci.focus();
		}
		return false;
			
	});	

	// evento no campo AGENCIA
	cCdagenci.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			campoAgenciaConta(1);
			return false;
		}
	});	
	
	// evento no campo CONTA
	cNrdconta.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			campoAgenciaConta(2);
			return false;
		} else if ( e.keyCode == 118 ) {
			mostraPesquisaAssociado('nrdconta', frmCab );
			return false;
		}
	});	
	
	// focus no ENTER
	cCddopcao.unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) { btnOK.click(); } });	
	cAprovad1.unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) { cAprovad2.focus(); } });	
	cAprovad2.unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) { cCdopeapv.focus(); } });	
	cCdopeapv.unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) { btnContinuar(); } });	
	
	$('#dtpropos','#frmCab').unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) { $('#dtaprova','#frmCab').focus(); } });	
	$('#dtaprova','#frmCab').unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) { $('#dtaprfim','#frmCab').focus(); } });	
	$('#dtaprfim','#frmCab').unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) { $('#aprovad1','#frmCab').focus(); } });	
	$('#aprovad1','#frmCab').unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) { $('#aprovad2','#frmCab').focus(); } });	

	layoutPadrao();
	controlaPesquisas();
	return false;	
}

function formataDados( qtregist ) {

	rQtpreemp.addClass('rotulo').css({'width':'105px'});
	rVlpreemp.addClass('rotulo-linha').css({'width':'125px'});
	rDtmvtolt.addClass('rotulo').css({'width':'105px'});
	rDsstatus.addClass('rotulo-linha').css({'width':'125px'});
	rInsitapv.addClass('rotulo').css({'width':'105px'});
	rCdopeap1.addClass('rotulo-linha').css({'width':'125px'});
	rDtaprov1.addClass('rotulo').css({'width':'105px'});
	rHrtransa.addClass('rotulo-linha').css({'width':'125px'});
	
	cQtpreemp.css({'width':'165px'});
	cVlpreemp.css({'width':'165px'});
	cDtmvtolt.css({'width':'165px'});
	cDsstatus.css({'width':'165px'});
	cInsitapv.css({'width':'165px'});
	cCdopeap1.css({'width':'165px'});
	cDtaprov1.css({'width':'165px'});
	cHrtransa.css({'width':'165px'});

	cTodosDados.desabilitaCampo();

	if ( cddopcao == 'A' && qtregist > 0 ) {
		cInsitapv.habilitaCampo();
		trocaBotao('Alterar');
	}

	cInsitapv.unbind('keyup').bind('keyup', function(e) { return false; });	
	cInsitapv.unbind('keypress').bind('keypress', function(e) { if (e.keyCode == 112) { btnContinuar(); }});	
	
	return false;
}

function formataTabela() {
	
	// tabela
	var divRegistro = $('div.divRegistros', '#'+tabDados);		
	var tabela      = $('table', divRegistro );
	
	$('#'+tabDados).css({'margin-top':'5px'});
	divRegistro.css({'height':'150px','padding-bottom':'2px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '35px';
	arrayLargura[1] = '62px';
	arrayLargura[2] = '79px';
	arrayLargura[3] = '79px';
	arrayLargura[4] = '79px';
	arrayLargura[5] = '79px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'right';
	arrayAlinha[6] = 'right';
	
	var chamada = cddopcao == 'C' ? 'mostraComplemento(\'consultar\');' : '';
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, chamada );

	/********************
	  EVENTO COMPLEMENTO	
	*********************/
	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		selecionaTabela($(this));
	});	

	// seleciona o registro que é focado
	$('table > tbody > tr', divRegistro).focus( function() {
		selecionaTabela($(this));
	});	

	$('table > tbody > tr:eq(0)', divRegistro).click();

	$('#'+tabDados).css({'display':'block'});
	hideMsgAguardo();
	return false;
}

function controlaLayout() {

	return false;
}

function selecionaTabela(tr) {

	seletor = tr;
	
	$('#qtpreemp','#'+frmDados).val( $('#qtpreemp', tr).val() );
	$('#vlpreemp','#'+frmDados).val( $('#vlpreemp', tr).val() );
	$('#dtmvtolt','#'+frmDados).val( $('#dtmvtolt', tr).val() );
	$('#insitapv','#'+frmDados).val( $('#insitapv', tr).val() );
	$('#cdopeap1','#'+frmDados).val( $('#cdopeap1', tr).val() );
	$('#dtaprov1','#'+frmDados).val( $('#dtaprov1', tr).val() );
	$('#hrtransa','#'+frmDados).val( $('#hrtransa', tr).val() );
	$('#nrdcont1','#'+frmDados).val( $('#nrdconta', tr).val() );
	$('#nrctremp','#'+frmDados).val( $('#nrctremp', tr).val() );
	$('#dsobscmt','#'+frmDados).val( replaceChars($('#dsobscmt', tr).val()) );
	$('#insitaux','#'+frmDados).val( $('#insitapv', tr).val() );
	$('#nrctrliq','#'+frmDados).val( $('#nrctrliq', tr).val() );
	$('#vlemprst','#'+frmDados).val( $('#vlemprst', tr).val() );
	$('#instatus','#'+frmDados).val( $('#instatus', tr).val() );
	$('#dsstatus','#'+frmDados).val( $('#dsstatus', tr).val() );
	
	$("#insitapv option[value='0']",'#'+frmDados).text(status[0]); 
	$("#insitapv option[value='1']",'#'+frmDados).text(status[1]); 
	$("#insitapv option[value='2']",'#'+frmDados).text(status[2]); 
	$("#insitapv option[value='3']",'#'+frmDados).text(status[3]); 
	$("#insitapv option[value='4']",'#'+frmDados).text(status[4]); 
	
	$('#insitapv option:selected', '#'+frmDados ).each(function () {
		$(this).text( $('#dsaprova', tr).val() );
	});
	
	return false;
}


// imprimir
function Gera_Impressao() {	
	// trata o select
	var aprovad1 = normalizaNumero( cAprovad1.val() ); 
	var aprovad2 = normalizaNumero( cAprovad2.val() ); 
	cAprovad1.val(aprovad1);	
	cAprovad2.val(aprovad2);
	
	var action = UrlSite + 'telas/cmaprv/imprimir_dados.php';
	
	cTodosCabecalho.habilitaCampo();	
	
	carregaImpressaoAyllos(frmCab,action,"estadoInicial();");
	
}


// complemento
function mostraOpcoes() {

	showMsgAguardo('Aguarde, buscando ...');

	var dsobscmt = replaceChars($('#dsobscmt','#'+frmDados).val());
	
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cmaprv/opcoes.php', 
		data: {
			dsobscmt: dsobscmt,
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			exibeRotina($('#divRotina'));
			formataOpcoes();
			return false;
		}				
	});
	return false;


}

function formataOpcoes() {
	
	$('#btnAlterar'  , '#divOpcao').css({'cursor':'pointer'});
	$('#btnIncluir'  , '#divOpcao').css({'cursor':'pointer'});
	$('#btnConsultar', '#divOpcao').css({'cursor':'pointer'});
	
	// centraliza a divRotina
	$('#divRotina').css({'width':'375px'});
	$('#divOpcao').css({'width':'350px'});
	$('#divRotina').centralizaRotinaH();

	hideMsgAguardo();	
	bloqueiaFundo( $('#divRotina') );
	
	return false;
}

function mostraComplemento( operacao, flag ) {

	flag = ( typeof flag != 'undefined' ) ? flag : '0';
	showMsgAguardo('Aguarde, buscando ...');

	var dsobscmt = replaceChars($('#dsobscmt','#'+frmDados).val());	
	dsobscmt = removeAcentos(dsobscmt);
	
	var insitapv = $('#insitapv','#'+frmDados).val();
	
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cmaprv/complemento.php', 
		data: {
			flag	: flag,
			operacao: operacao,
			cddopcao: cddopcao,
			insitapv: insitapv,
			dsobscmt: dsobscmt,
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			exibeRotina($('#divRotina'));
			formataComplemento( operacao );
			return false;
		}				
	});
	return false;


}

function formataComplemento( operacao ) {

	// rotulo
	rCdcmaprv = $('label[for="cdcmaprv"]', '#frmComplemento');
	rDscmaprv = $('label[for="dscmaprv"]', '#frmComplemento');
	rDsobscmt = $('label[for="dsobscmt"]', '#frmComplemento');
	
	rCdcmaprv.addClass('rotulo').css({'width':'45px'});
	rDscmaprv.addClass('rotulo-linha');
	rDsobscmt.addClass('rotulo');
	
	// camp
	cCdcmaprv = $('#cdcmaprv', '#frmComplemento');
	cDscmaprv = $('#dscmaprv', '#frmComplemento');
	cDsobscmt = $('#dsobscmt', '#frmComplemento'); 
	
	cCdcmaprv.addClass('pesquisa').css({'width':'40px'});
	cDscmaprv.addClass('alphanum').css({'width':'390px'});
	cDsobscmt.addClass('alphanum').css({'width':'99%','height':'150px','padding':'5px'});

	if ( $.browser.msie ) {
		cDscmaprv.css({'width':'383px'});
	}
	
	$('input, textarea', '#frmComplemento').desabilitaCampo();
	
	if ( operacao == 'consultar' ) {
		rCdcmaprv.css({'display':'none'});
		$('a','#frmComplemento').css({'display':'none'});
		cCdcmaprv.css({'display':'none'});
		cDscmaprv.css({'display':'none'});
		
	} else if ( operacao == 'alterar' ) {
		rCdcmaprv.css({'display':'none'});
		$('a','#frmComplemento').css({'display':'none'});
		cCdcmaprv.css({'display':'none'});
		cDscmaprv.css({'display':'none'});
		cDsobscmt.habilitaCampo();
		
	} else if ( operacao == 'incluir' ) {
		cCdcmaprv.css({'display':'block'}).habilitaCampo();
		cDscmaprv.css({'display':'block'});
		cDsobscmt.habilitaCampo();
		
	}
	
	// centraliza a divRotina
	$('#divRotina').css({'width':'525px'});
	$('#divConteudo').css({'width':'500px'});
	$('#divRotina').centralizaRotinaH();

	hideMsgAguardo();	
	bloqueiaFundo( $('#divRotina') );
	controlaPesquisas();
	layoutPadrao();
	return false;
}


// atalho
function campoAgenciaConta(opcao) {

	if ( opcao == 1) {
	
		if ( normalizaNumero(cCdagenci.val()) == 0) {
			cCdagenci.desabilitaCampo();
			cCdagenci.val('0');
			cNrdconta.habilitaCampo();
			cNrdconta.focus();
		} else {
			cNrdconta.val('0');
			cTodosCabecalho.habilitaCampo();
			cCddopcao.desabilitaCampo();		
			cCdagenci.desabilitaCampo();
			cNrdconta.desabilitaCampo();
			cDtpropos.focus();
		}
	
	} else if ( opcao == 2 ) { /* if ( cNrdconta.hasClass('campo') ) { */

		if ( normalizaNumero(cNrdconta.val()) == 0) { cNrdconta.val('0'); }
		cTodosCabecalho.habilitaCampo();
		cCddopcao.desabilitaCampo();		
		cCdagenci.desabilitaCampo();
		cNrdconta.desabilitaCampo();
		cDtpropos.focus();
	}
	return false;
}


// botoes
function btnVoltar() {
	estadoInicial();
	controlaPesquisas();
	return false;
}

function btnContinuar() {
	
	if ( divError.css('display') == 'block' ) { return false; }	
	
	if ( cCddopcao.hasClass('campo') ) {
		btnOK.click();
	} else if ( (cddopcao == 'A' || cddopcao == 'C') && cDtpropos.hasClass('campo') ) {
		controlaOperacao(1,50);
	} else if ( cddopcao == 'R' && cDtpropos.hasClass('campo') ) {
		Gera_Impressao();
	} else if ( cddopcao == 'A' && cInsitapv.length > 0 && cInsitapv.val() != 0 ) {
	
		if ( (cInsitapv.val() == 1 || cInsitapv.val() == 3) && $('#instatus', '#'+frmDados).val() == 3)  { 
			buscaSenha();
		} else {
			manterRotina('VD');
		}
	}
	
	return false;

}

function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onClick="btnVoltar(); return false;" >Voltar</a>&nbsp;');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onClick="btnContinuar(); return false;">'+botao+'</a>');
	
	return false;
}


function botaoOK() {

if ( divError.css('display') == 'block' ) { return false; }		
	if ( cCddopcao.hasClass('campo') ) {
		cddopcao = cCddopcao.val();
		cCddopcao.desabilitaCampo();
		cCdagenci.habilitaCampo();
		cCdagenci.focus();
	}
	return false;

}

function buscaAssociado() {

	// Se esta desabilitado o campo da conta
	if ($("#nrdconta","#frmCab").prop("disabled") == true)  {
		return;
	}
		
	mostraPesquisaAssociado('nrdconta','frmCab','');
	return false;

} 

function buscaSenha() {
	pedeSenhaCoordenador(2,'manterRotina("VD")','');
}


function solicitaIncluirObservacao( flag ){
	/* Solicitar a confirmação para incluir observação apenas quando alterar para a situação: 
       0 - Não Analisado / 1 - Aprovado / 4 - Refazer */
	if ( cInsitapv.val() == 0 || cInsitapv.val() == 1 || cInsitapv.val() == 4 )  { 
		showConfirmacao('Deseja incluir observa&ccedil;&atilde;o do comit&ecirc?','Confirma&ccedil;&atilde;o - Ayllos','confirmaMsgObservacao(' + flag + ',true);',
	                                                                                                                     'confirmaMsgObservacao(' + flag + ',false);','sim.gif','nao.gif');
	} else {
		// Caso contrário mostra a opção de incluir observação
		confirmaMsgObservacao( flag, true );
	}
}

function confirmaMsgObservacao( bMostrarOpcoes, bConfirma ){
	if (bConfirma) {
		if ( bMostrarOpcoes ) {
			mostraOpcoes();
		} else {
			mostraComplemento('incluir');
		}
	} else {
		manterRotina('CO');
	}
}
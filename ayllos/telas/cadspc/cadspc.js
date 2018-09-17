/*!
 * FONTE        : cadspc.js
 * CRIAÇÃO      : Rogerius Militão (DB1) 
 * DATA CRIAÇÃO : 02/03/2012
 * OBJETIVO     : Biblioteca de funções da tela CADSPC
 * --------------
 * ALTERAÇÕES   :15/03/2012 - Correção tipo SPC/SERASA na impressão (Oscar).
 *				:29/03/2012 - Ajuste no layout padrão (Rogérius Militão (DB1))
 * 				:28/06/2012 - Retirado window.open de funcao Gera_Impressao() e incluido mudanca de target quando for Navegador Chrome                
				:10/09/2013 - Retirado a opção de Incluir, Alterar e Baixar, será feito pelo crps657.p de forma automatica. (James)
				:27/02/2014 - Retirado a opção de Atualizar e Selecao para as cooperativas "2,15,17,10,7,12,9". (Oscar)
				:01/04/2014 - Retirado a opção de Atualizar e Selecao. (James)
 * --------------
 */

//Formulários e Tabela
var frmCab   		= 'frmCab';
var frmDevedor		= 'frmDevedor';
var frmOpcao		= 'frmOpcao';
var frmCadSPC		= 'frmCadSPC';

var	cddopcao		= 'C';

var nrdrowid		= 0;
	
var nriniseq		= 1;
var nrregist		= 50;

var nrJanelas		= 0;

$(document).ready(function() {
	estadoInicial();
});


// inicio
function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);

	//
	fechaRotina( $('#divRotina') );
	$('#divRotina').html('');
	
	// retira as mensagens	
	hideMsgAguardo();

	// formailzia	
	formataCabecalho();
	
	// remove o campo prosseguir
	trocaBotao('Prosseguir');	

	// devedor
	$('#'+frmDevedor, '#divTela').css({'display':'none'});
	$('#'+frmCadSPC, '#divTela').css({'display':'none'});
	$('#divBotoes', '#divTela').css({'display':'none'});
	
	// opcao
	$('#'+frmOpcao, '#divTela').remove();
	
	// 
	cTodosCabecalho.limpaFormulario().removeClass('campoErro');	

	cCddopcao.habilitaCampo();
	cCddopcao.focus();
	cCddopcao.val( cddopcao );
	
	removeOpacidade('divTela');
}


// controle
function controlaOperacao( nriniseq, nrregist ) {
	
	var nrcpfcgc = normalizaNumero( $('#nrcpfcgc', '#'+frmDevedor).val() );
	var nrdconta = normalizaNumero( $('#nrdconta', '#'+frmDevedor).val() );
	var tpidenti = normalizaNumero( $('#tpidenti', '#'+frmDevedor).val() );
	
	var mensagem = 'Aguarde, buscando dados ...';
	showMsgAguardo( mensagem );	
	
	// Carrega dados da conta através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/cadspc/principal.php', 
		data    : 
				{ 
					cddopcao	: cddopcao, 
					nrcpfcgc    : nrcpfcgc,
					nrdconta    : nrdconta,
					tpidenti    : tpidenti,
					nriniseq	: nriniseq,
					nrregist	: nrregist,
					redirect	: 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
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

function manterRotina( operacao ) {
		
	hideMsgAguardo();		

	var nrdconta = normalizaNumero( cNrdconta.val() );
	var nrcpfcgc = normalizaNumero( cNrcpfcgc.val() );
	var nrctremp = normalizaNumero( cNrctremp.val() );
	var tpidenti = normalizaNumero( cTpidenti.val() ); 
	var tpctrdev = normalizaNumero( cTpctrdev.val() ); 
	var nrctaavl = normalizaNumero( cNrctaavl.val() ); 

	var nrctrspc = cNrctrspc.val(); 
	var dtvencto = cDtvencto.val(); 
	var vldivida = cVldivida.val(); 

	var dtinclus = cDtinclus.val(); 
	var tpinsttu = normalizaNumero( cTpinsttu.val() ); 
	var dsoberv1 = cDsoberv1.val(); 

	var dtdbaixa = cDtdbaixa.val(); 
	var dsoberv2 = cDsoberv2.val(); 
	
	var mensagem = '';
	
	switch( operacao ) {
		case 'Busca_Devedor': 	mensagem = 'Aguarde, buscando dados...'; 	break;
		case 'Busca_Contratos': mensagem = 'Aguarde, buscando dados...'; 	break;
		case 'Valida_Contrato': mensagem = 'Aguarde, validando dados...'; 	break;
		case 'Busca_Fiador': 	mensagem = 'Aguarde, buscando dados...'; 	break;
		case 'Verifica_Fiador':	mensagem = 'Aguarde, verificando ...'; 		break;
		case 'Valida_Dados':	mensagem = 'Aguarde, validando dados ...';	break;
		case 'Grava_Dados':		mensagem = 'Aguarde, gravando dados ...';	break;
		case 'Busca_Dados':		mensagem = 'Aguarde, buscando dados ...';	break;
		default: return false;	break;
	}
	
	showMsgAguardo( mensagem );	
	
	$.ajax({		
			type  : 'POST',
			url   : UrlSite + 'telas/cadspc/manter_rotina.php', 		
			data: {
				operacao	: operacao,
				cddopcao	: cddopcao,
				nrdconta	: nrdconta,
				nrcpfcgc	: nrcpfcgc,
				nrctremp	: nrctremp,
				tpidenti	: tpidenti,
				tpctrdev	: tpctrdev,
				nrctaavl	: nrctaavl,
				nrctrspc	: nrctrspc,
				dtvencto	: dtvencto,
				vldivida	: vldivida,
				dtinclus	: dtinclus,
				tpinsttu	: tpinsttu,
				dsoberv1	: dsoberv1,
				dtdbaixa	: dtdbaixa,
				dsoberv2	: dsoberv2,
				nrdrowid	: nrdrowid,
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
	
	var tpidenti = normalizaNumero( $('#tpidenti', '#'+frmDevedor).val() );

	/*---------------------*/
	/*  CONTROLE CONTA/DV  */
	/*---------------------*/
	var linkConta = $('a:eq(0)','#'+frmDevedor);

	if ( linkConta.prev().hasClass('campoTelaSemBorda') ) {		
		linkConta.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {
		linkConta.css('cursor','pointer').unbind('click').bind('click', function() {			
			mostraPesquisaAssociado('nrdconta', frmDevedor );
		});
	}

	/*---------------------*/
	/*  CONTROLE DEVEDOR   */
	/*---------------------*/
	var linkDevedor = $('a:eq(0)','#'+frmCadSPC);

	if ( linkDevedor.prev().hasClass('campoTelaSemBorda') ) {		
		linkDevedor.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else if ( tpidenti == 1 ) {
		linkDevedor.css('cursor','pointer').unbind('click').bind('click', function() {			
			mostraConta();
		});
	}

	/*---------------------*/
	/*   CONTROLE FIADOR   */
	/*---------------------*/
	var linkFiador = $('a:eq(1)','#'+frmCadSPC);

	if ( linkFiador.prev().hasClass('campoTelaSemBorda') ) {		
		linkFiador.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {
		linkFiador.css('cursor','pointer').unbind('click').bind('click', function() {			
			mostraConta();
		});
	}
	
	return false;
}

function controlaLayout() {

	$('#'+frmCadSPC, '#divTela').css({'display':'none'});

	if ( cddopcao == 'C' ) {
		formataOpcaoC();
		formataCabecalho();
		formataDevedor();

		$('input', '#'+frmDevedor).desabilitaCampo();
		trocaBotao('');
		$('#btVoltar', '#divBotoes').focus();
	}

	controlaPesquisas();
	hideMsgAguardo();
	return false;
}


// formata
function formataCabecalho() {

	// label
	rCddopcao = $('label[for="cddopcao"]', '#'+frmCab);
	rCddopcao.addClass('rotulo').css({'width':'42px'});
	
	// input
	cCddopcao = $('#cddopcao', '#'+frmCab);
	cCddopcao.css({'width':'600px'});
	
	// outros
	cTodosCabecalho = $('input[type="text"],select','#'+frmCab);
	cTodosCabecalho.desabilitaCampo();
	btnOK1			= $('#btnOk1', '#'+frmCab); 
	
	if ( $.browser.msie ) {
		cCddopcao.css({'width':'598px'});
	}

	//
	cCddopcao.unbind('keydown').bind('keydown', function(e) { 	
		if (e.keyCode == 13) {
			btnOK1.click();
			return false;
		}
	});	
	
	// Se clicar no botao OK
	btnOK1.unbind('click').bind('click', function() { 	
			
		if ((cCddopcao.val() == 'A') || (cCddopcao.val() == 'B') || (cCddopcao.val() == 'I')){
			showError('inform','Essa opção foi desabilitada.','Alerta - Ayllos','');
			return false;
		}
		
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( cCddopcao.hasClass('campoTelaSemBorda')  ) { return false; }		
						
		//
		cCddopcao.desabilitaCampo();
		cddopcao 	= cCddopcao.val();
		
		//
		$('#'+frmOpcao, '#divTela').remove();
		$('input, select', '#'+frmDevedor).limpaFormulario();	
		formataDevedor();
		trocaBotao('Prosseguir');
		return false;
			
	});	

	
	controlaPesquisas();
	return false;	
}

function formataDevedor() {

	highlightObjFocus($('#'+frmDevedor));

	// label
	rNrcpfcgc = $('label[for="nrcpfcgc"]', '#'+frmDevedor);
	rNrdconta = $('label[for="nrdconta"]', '#'+frmDevedor);
	rTpidenti = $('label[for="tpidenti"]', '#'+frmDevedor);
	
	rNrcpfcgc.addClass('rotulo').css({'width':'70px'});
	rNrdconta.addClass('rotulo-linha').css({'width':'320px','display':'block'});
	rTpidenti.addClass('rotulo-linha').css({'width':'337px','display':'block'});
	
	// input
	cNrcpfcgc = $('#nrcpfcgc', '#'+frmDevedor);
	cNrdconta = $('#nrdconta', '#'+frmDevedor);
	cTpidenti = $('#tpidenti', '#'+frmDevedor);
	
	cNrcpfcgc.css({'width':'120px'}).addClass('inteiro').attr('maxlength','14');
	cNrdconta.css({'width':'120px','display':'block'}).addClass('conta pesquisa');
	cTpidenti.css({'width':'120px','display':'block'});
	
	if ( $.browser.msie ) {	
		rTpidenti.css({'width':'340px'});	
	}
	
	$('input', '#frmDevedor').desabilitaCampo();

	if ( cddopcao == 'C' ) {
		rTpidenti.css({'display':'none'});
		cTpidenti.css({'display':'none'});
		cNrdconta.next().css({'display':'block'});
		
		cNrcpfcgc.habilitaCampo();
		$('#frmDevedor').css({'display':'block'});
		$('#divBotoes', '#divTela').css({'display':'block'});
		
	} else if ( cddopcao == 'M' ) {
		buscaOpcaoM();

	} else {
		rNrdconta.css({'display':'none'});
		cNrdconta.css({'display':'none'});
		cNrdconta.next().css({'display':'none'});
		$('#'+frmDevedor).css({'display':'block'});
		
		$('#divBotoes', '#divTela').css({'display':'block'});
		$('input, select', '#'+frmCadSPC).limpaFormulario();
		
		cNrcpfcgc.habilitaCampo();
		cTpidenti.habilitaCampo();

		formataCadSPC();
		$('#'+frmCadSPC).css({'display':'block'});
		
	}
	
	// 
	cNrcpfcgc.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		

			var auxcpfcg = normalizaNumero( $(this).val() );
			
			// Se é a tecla TAB, 
			if ( (e.keyCode == 9 || e.keyCode == 13) && ( auxcpfcg == 0 || validaCampo(auxcpfcg, 'nrcpfcgc', frmDevedor)) ) {
				$(this).triggerHandler('blur');
				
				if ( cddopcao == 'C' ) {
				
					if ( auxcpfcg == 0 ) {
						habilitaConta();
					} else {
						btnContinuar();
					}
					return false;
				
				} else {
					cTpidenti.focus();
					return false;
				}				
			} else if ( e.keyCode === 9 || e.keyCode == 13 ) {
				return false;
			}
			
	});	

	// conta
	cNrdconta.unbind('keydown').bind('keydown', function(e) {
		
		if ( divError.css('display') == 'block' ) { return false; }		

			var auxconta = normalizaNumero( $(this).val() );
			
			// Se é a tecla TAB, 
			if ( (e.keyCode === 9 || e.keyCode == 13) && (auxconta == 0 || validaCampo(auxconta, 'nrdconta', frmDevedor)) ) {				
				$(this).triggerHandler('blur');
				btnContinuar();
				return false;			
			}  else if ( e.keyCode === 9 || e.keyCode == 13 ) {				
				return false;
			}	
			
	});	
	
	// identificacao
	cTpidenti.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		

			// Se é a tecla TAB, 
			if ( e.keyCode === 9 || e.keyCode == 13 ) {
				$(this).triggerHandler('blur');
				btnContinuar();
				return false;			
			}  else if ( e.keyCode === 9 || e.keyCode == 13 ) {
				return false;
			}	
			
	});	

	layoutPadrao();
	controlaPesquisas();
	cNrcpfcgc.focus();
	return false;
}


// opcao A, B e I
function formataCadSPC() {

	highlightObjFocus($('#'+frmCadSPC));

	/**********************
		DEVEDOR/FIADOR
	***********************/
	// label
	rNrdconta = $('label[for="nrdconta"]', '#'+frmCadSPC);
	rNrctaavl = $('label[for="nrctaavl"]', '#'+frmCadSPC);
	rCdagenci = $('label[for="cdagenci"]', '#'+frmCadSPC);
	rNmresage = $('label[for="nmresage"]', '#'+frmCadSPC);
	
	rNrdconta.addClass('rotulo').css({'width':'62px'});
	rNrctaavl.addClass('rotulo').css({'width':'62px'});
	rCdagenci.addClass('rotulo').css({'width':'62px'});
	rNmresage.addClass('rotulo-linha').css({'width':'14px'});
	
	// input
	cNrdconta = $('#nrdconta', '#'+frmCadSPC);
	cNmprimtl = $('#nmprimtl', '#'+frmCadSPC);
	cNrctaavl = $('#nrctaavl', '#'+frmCadSPC);
	cNmpriavl = $('#nmpriavl', '#'+frmCadSPC);
	cCdagenci = $('#cdagenci', '#'+frmCadSPC);
	cNmresage = $('#nmresage', '#'+frmCadSPC);
	
	cNrdconta.css({'width':'120px'}).addClass('conta pesquisa');
	cNmprimtl.css({'width':'450px'});
	cNrctaavl.css({'width':'120px'}).addClass('conta pesquisa');
	cNmpriavl.css({'width':'450px'});
	cCdagenci.css({'width':'120px'}).addClass('inteiro');
	cNmresage.css({'width':'450px'});

	if ( $.browser.msie ) {	
		rNmresage.css({'width':'17px'});
	}
	
	/**********************
		   CONTRATO
	***********************/
	// label
	rTpctrdev = $('label[for="tpctrdev"]', '#'+frmCadSPC);
	rNrctremp = $('label[for="nrctremp"]', '#'+frmCadSPC);
	rNrctrspc = $('label[for="nrctrspc"]', '#'+frmCadSPC);
	rDtvencto = $('label[for="dtvencto"]', '#'+frmCadSPC);
	rVldivida = $('label[for="vldivida"]', '#'+frmCadSPC);

	rTpctrdev.addClass('rotulo').css({'width':'60px'});
	rNrctremp.addClass('rotulo-linha').css({'width':'120px'});
	rNrctrspc.addClass('rotulo-linha').css({'width':'120px'});	
	rDtvencto.addClass('rotulo-linha').css({'width':'102px'});	
	rVldivida.addClass('rotulo').css({'width':'60px'});	
	
	// input 
	cTpctrdev = $('#tpctrdev','#'+frmCadSPC);
	cNrctremp = $('#nrctremp','#'+frmCadSPC);
	cNrctrspc = $('#nrctrspc','#'+frmCadSPC);
	cDtvencto = $('#dtvencto','#'+frmCadSPC);
	cVldivida = $('#vldivida','#'+frmCadSPC);
	
	cTpctrdev.css({'width':'120px'});
	cNrctremp.css({'width':'120px', 'text-align':'right'}).setMask('INTEGER','zz.zzz.zzz','.','');
	cNrctrspc.css({'width':'348px'}).addClass('alphanum').attr('maxlength','40');
	cDtvencto.css({'width':'120px'}).addClass('data');
	cVldivida.css({'width':'120px', 'text-align':'right'}).setMask('DECIMAL','zzz.zzz.zz9,99','.','');

	if ( $.browser.msie ) {	
		rDtvencto.css({'width':'106px'});
		rNrctrspc.css({'width':'121px'});	
	}
	
	/**********************
		   INCLUSAO
	***********************/
	// label
	rDtinclus = $('label[for="dtinclus"]', '#'+frmCadSPC);
	rOperador = $('label[for="operador"]', '#'+frmCadSPC);
	rTpinsttu = $('label[for="tpinsttu"]', '#'+frmCadSPC);
	rDsoberv1 = $('label[for="dsoberv1"]', '#'+frmCadSPC);
	
	rDtinclus.addClass('rotulo').css({'width':'60px'});
	rOperador.addClass('rotulo-linha').css({'width':'60px'});	
	rTpinsttu.addClass('rotulo-linha').css({'width':'55px'});	
	rDsoberv1.addClass('rotulo').css({'width':'60px'});
	
	// input
	cDtinclus = $('#dtinclus', '#'+frmCadSPC);
	cOperador = $('#operador', '#'+frmCadSPC);
	cTpinsttu = $('#tpinsttu', '#'+frmCadSPC);
	cDsoberv1 = $('#dsoberv1', '#'+frmCadSPC);
	
	cDtinclus.css({'width':'120px'}).addClass('data');
	cOperador.css({'width':'226px'});	
	cTpinsttu.css({'width':'120px'});	
	cDsoberv1.css({'width':'593px'}).addClass('alphanum').attr('maxlength','30');

	if ( $.browser.msie ) {
		rOperador.css({'width':'63px'});
		rTpinsttu.css({'width':'59px'});	
	}
	
	/**********************
			BAIXA
	***********************/
	rDtdbaixa = $('label[for="dtdbaixa"]', '#'+frmCadSPC);
	rOpebaixa = $('label[for="opebaixa"]', '#'+frmCadSPC);
	rDsoberv2 = $('label[for="dsoberv2"]', '#'+frmCadSPC);	

	rDtdbaixa.addClass('rotulo').css({'width':'60px'});
	rOpebaixa.addClass('rotulo-linha').css({'width':'60px'});	
	rDsoberv2.addClass('rotulo').css({'width':'60px'});
	
	cDtdbaixa = $('#dtdbaixa', '#'+frmCadSPC);
	cOpebaixa = $('#opebaixa', '#'+frmCadSPC);
	cDsoberv2 = $('#dsoberv2', '#'+frmCadSPC);	

	cDtdbaixa.css({'width':'120px'}).addClass('data');
	cOpebaixa.css({'width':'407px'});	
	cDsoberv2.css({'width':'593px'}).addClass('alphanum').attr('maxlength','30');	
	
	if ( $.browser.msie ) {
		rOpebaixa.css({'width':'63px'});	
	}
	
	cTodosCadSPC = $('input, select', '#'+frmCadSPC);
	cTodosCadSPC.desabilitaCampo();
	
	// devedor
	cNrdconta.unbind('keydown').bind('keydown', function(e) {				
		if ( divError.css('display') == 'block' ) { return false; }		
		
		// Se é a tecla TAB, 
		if ( e.keyCode === 9 || e.keyCode == 13 ) {
			$(this).triggerHandler('blur');
			btnContinuar();
			return false;			
		} 			
	});	
	

	// fiador
	cNrctaavl.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		

		// Se é a tecla TAB, 
		if ( e.keyCode === 9 || e.keyCode == 13 ) {
			$(this).triggerHandler('blur');
			btnContinuar();
			return false;			
		} 			
	});	
	
	// tipo
	cTpctrdev.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		

		// Se é a tecla TAB, 
		if ( e.keyCode === 9 || e.keyCode == 13 ) {
			$(this).triggerHandler('blur');
			btnContinuar();
			return false;			
		} 			
	});	
	
	// contrato
	cNrctremp.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		

		// Se é a tecla TAB, 
		if ( e.keyCode === 9 || e.keyCode == 13 ) {
			$(this).triggerHandler('blur');
			btnContinuar();
			return false;			
		} 			
	});	
	
	// vencimento
	cDtvencto.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		

		// Se é a tecla TAB, 
		if ( e.keyCode === 9 || e.keyCode == 13 ) {
			$(this).triggerHandler('blur');
			cVldivida.focus();
			return false;			
		}  	
	});	
	
	// valor
	cVldivida.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		

		// Se é a tecla TAB, 
		if ( e.keyCode === 9 || e.keyCode == 13 ) { 
			$(this).triggerHandler('blur');
			cNrctrspc.focus();
			return false;					
		}
	});	
	
	// nr contrato do sPC:
	cNrctrspc.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		

		// Se é a tecla TAB, 
		if ( e.keyCode === 9 || e.keyCode == 13 ) {
			$(this).triggerHandler('blur');
			cDtinclus.focus();
			return false;			
		}  			
	});	
	
	// data inclusao
	cDtinclus.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		

		// Se é a tecla TAB, 
		if ( e.keyCode === 9 || e.keyCode == 13 ) {
			$(this).triggerHandler('blur');
			cTpinsttu.focus();
			return false;			
		}  			
	});	
	
	// registro
	cTpinsttu.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		

		// Se é a tecla TAB, 
		if ( e.keyCode === 9 || e.keyCode == 13 ) {
			$(this).triggerHandler('blur');
			btnContinuar();
			return false;			
		}  			
	});	
	
	// observacao inclusao
	cDsoberv1.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		

		// Se é a tecla TAB, 
		if ( e.keyCode === 9 || e.keyCode == 13 ) {
			$(this).triggerHandler('blur');
			btnContinuar();
			return false;			
		}  			
	});	
	
	// data baixa
	cDtdbaixa.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		

		// Se é a tecla TAB, 
		if ( e.keyCode === 9 || e.keyCode == 13 ) {
			$(this).triggerHandler('blur');
			btnContinuar();
			return false;			
		}  			
	});
	
	
	// observacao baixa
	cDsoberv2.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		

		// Se é a tecla TAB, 
		if ( e.keyCode === 9 || e.keyCode == 13 ) {
			$(this).triggerHandler('blur');
			btnContinuar();
			return false;			
		}  			
	});	
	
	controlaPesquisas();
	return false;
}

function prosseguirCadSPC() {

	if ( in_array(cddopcao, ['A','B','I']) && isHabilitado(cNrcpfcgc) ) {
		
		var auxcpfcg = normalizaNumero( cNrcpfcgc.val() );
		
		if ( (auxcpfcg == 0 || validaCampo(auxcpfcg, 'nrcpfcgc', frmDevedor)) && validaCampo(cTpidenti.val(), 'tpidenti', frmDevedor) ) {
			$('input, select', '#'+frmDevedor).desabilitaCampo();
			cNrdconta.habilitaCampo();
			cNrdconta.focus();
		}
		
	} else if ( in_array(cddopcao, ['A','B','I']) && isHabilitado(cNrdconta) ) {
		if ( validaCampo(cNrdconta.val(), 'nrdconta', frmCadSPC) ) {
			if ( cTpidenti.val() == 1 ) {
				manterRotina('Busca_Devedor');
			} else {
				manterRotina('Busca_Fiador');	
			}
		}
		
	} else if ( in_array(cddopcao, ['A','B','I']) && isHabilitado(cNrctaavl) ) {
		if ( validaCampo(cNrctaavl.val(), 'nrctaavl', frmCadSPC) ) {
			manterRotina('Verifica_Fiador');
		}	
		
	} else if ( in_array(cddopcao, ['A','B','I']) && isHabilitado(cTpctrdev) ) {
		if ( cTpctrdev.val() == 1 && cTpidenti.val() == 1 ) {
			cNrctremp.val( cNrdconta.val() );
			cddopcao == 'I' ? manterRotina('Busca_Contratos') : mostraContrato();
		} else if ( validaCampo(cTpctrdev.val(), 'tpctrdev', frmCadSPC) ) {
			cTpctrdev.desabilitaCampo();
			cNrctremp.habilitaCampo().focus();
		}
		
	} else if ( in_array(cddopcao, ['A','B','I']) && isHabilitado(cNrctremp) ) {
		if ( cddopcao == 'I' && cTpidenti.val() == 1 ) {
			manterRotina('Busca_Contratos');
		} else if ( cddopcao == 'I' && in_array(cTpidenti.val(),[3,4]) ) {
			manterRotina('Valida_Contrato');
		} else if ( in_array(cddopcao,['A','B']) ) {
			mostraContrato();
		}		
	
	} else if ( in_array(cddopcao, ['A','B','I']) && (isHabilitado(cDtvencto) || isHabilitado(cDtdbaixa)) ) {		
		manterRotina('Valida_Dados');
	
	} else if ( in_array(cddopcao, ['A','B','I']) && (isHabilitado(cDsoberv1) || isHabilitado(cDsoberv2)) ) {
		showConfirmacao('Confirma a operacao?','Confirma&ccedil;&atilde;o - Ayllos','manterRotina(\'Grava_Dados\');','estadoInicial();','sim.gif','nao.gif');
		
	}
	
	return false;
}

function voltarCadSPC() {

	var fieldset0 = $('input, select', '#'+frmCadSPC+ ' fieldset:eq(0)');
	var fieldset1 = $('input, select', '#'+frmCadSPC+ ' fieldset:eq(1)');
	var fieldset2 = $('input, select', '#'+frmCadSPC+ ' fieldset:eq(2)');
	var fieldset3 = $('input, select', '#'+frmCadSPC+ ' fieldset:eq(3)');
	
	if ( isHabilitado(cNrdconta) ) {
		cTodosCadSPC.limpaFormulario();
		cTodosCadSPC.desabilitaCampo();
		cNrdconta.desabilitaCampo();
		cNrcpfcgc.habilitaCampo().focus();
		cTpidenti.habilitaCampo();

	} else if ( isHabilitado(cNrctaavl) ) {
		cNrdconta.habilitaCampo().focus();
		cNrctaavl.desabilitaCampo().val('');
		cNmpriavl.val('');

	} else if ( isHabilitado(cTpctrdev) ) {
		if ( cTpidenti.val() == 1 ) {
			cNrdconta.habilitaCampo().focus();
			cTpctrdev.desabilitaCampo().val('');
		} else {
			cNrctaavl.habilitaCampo().focus();

		}
		cCdagenci.val('');
		cNmresage.val('');		
		cTpctrdev.desabilitaCampo();
		cTpctrdev.val('0');

	} else if ( isHabilitado(cNrctremp) ) {
		cNrctremp.desabilitaCampo().val('');
		cTpctrdev.habilitaCampo().focus();		
	
	} else if ( isHabilitado(cDtvencto) || isHabilitado(cDtdbaixa) ) {
		var tpctrdev = cTpctrdev.val();
		var tpidenti = cTpidenti.val();
		var nrctremp = cNrctremp.val();
		
		cTodosCadSPC.desabilitaCampo();

		fieldset1.limpaFormulario();
		fieldset2.limpaFormulario();		
		fieldset3.limpaFormulario();

		if ( tpctrdev == 1 && tpidenti == 1 ) {
			cTpctrdev.habilitaCampo().focus();
		} else {
			cNrctremp.habilitaCampo().focus();
		}
		
		cTpctrdev.val(tpctrdev);
		cNrctremp.val(nrctremp);

	} else if ( isHabilitado(cDsoberv1) ) {
		cDsoberv1.desabilitaCampo().val('');
		cNrctrspc.habilitaCampo();
		cDtvencto.habilitaCampo().focus();
		cVldivida.habilitaCampo();
		cDtinclus.habilitaCampo();
		cTpinsttu.habilitaCampo();

	} else if ( isHabilitado(cDsoberv2) ) {
		cDsoberv2.desabilitaCampo();
		cDtdbaixa.habilitaCampo().focus();
		
	} else {
		estadoInicial();
	}
	
	return false;
}


// opcao C
function formataOpcaoC() {

	// tabela
	var divRegistro = $('div.divRegistros', '#'+frmOpcao);		
	var tabela      = $('table', divRegistro );
	
	$('#'+frmOpcao).css({'margin-top':'5px'});
	divRegistro.css({'height':'207px','padding-bottom':'2px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '30px';
	arrayLargura[1] = '80px';
	arrayLargura[2] = '92px';
	arrayLargura[3] = '75px';
	arrayLargura[4] = '80px';
	arrayLargura[5] = '75px';
	arrayLargura[6] = '75px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'left';
	arrayAlinha[3] = 'left';
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'left';
	arrayAlinha[6] = 'left';
	arrayAlinha[7] = 'left';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

	/********************
	 FORMATA COMPLEMENTO	
	*********************/
	// complemento linha 1
	var linha1  = $('ul.complemento', '#linha1').css({'margin-left':'1px','width':'99.5%'});
	
	$('li:eq(0)', linha1).addClass('txtNormalBold').css({'width':'8%','text-align':'right'});
	$('li:eq(1)', linha1).addClass('txtNormal').css({'width':'40%'});
	$('li:eq(2)', linha1).addClass('txtNormalBold').css({'width':'8%','text-align':'right'});
	$('li:eq(3)', linha1).addClass('txtNormal');

	/********************
	  EVENTO COMPLEMENTO	
	*********************/
	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		selecionaOpcaoC($(this));
	});	

	// seleciona o registro que é focado
	$('table > tbody > tr', divRegistro).focus( function() {
		selecionaOpcaoC($(this));
	});	

	$('table > tbody > tr:eq(0)', divRegistro).click();
	
	return false;	
}

function prosseguirOpcaoC() {

	var auxconta = normalizaNumero( cNrdconta.val() );
	var auxcpfcg = normalizaNumero( cNrcpfcgc.val() );
	
	if ( isHabilitado(cNrcpfcgc) && auxcpfcg == 0 ) {
		habilitaConta();
		
	} else if ( (auxconta == 0 || validaCampo(auxconta, 'nrdconta', frmDevedor))  && 
				(auxcpfcg == 0 || validaCampo(auxcpfcg, 'nrcpfcgc', frmDevedor)) ) {
		controlaOperacao( nriniseq, nrregist );
	}

	return false;
}

function voltarOpacaoC() {

	if ( isHabilitado( $('#nrdconta','#'+frmDevedor)) || $('#'+frmOpcao).css('display') == 'block' )  {
		cNrcpfcgc.habilitaCampo().focus();
		cNrdconta.desabilitaCampo().val('');
		$('#'+frmOpcao).css({'display':'none'});
		trocaBotao('Prosseguir');
	} else {
		estadoInicial();
	}

	return false;
}

function selecionaOpcaoC(tr) {

	$('#nmprimtl','.complemento').html( $('#nmprimtl', tr).val() );
	$('#cdagenci','.complemento').html( $('#cdagenci', tr).val() );

	return false;
}


// opcao M
function buscaOpcaoM() {

	var mensagem = 'Aguarde, buscando dados ...';
	showMsgAguardo(mensagem);

	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadspc/form_opcao_m.php', 
		data: {
			redirect: 'script_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"estadoInicial();");
		},
		success: function(response) {

			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divRotina').html(response);
					exibeRotina( $('#divRotina') );
					formataOpcaoM();
					
				} catch(error) {
					hideMsgAguardo();					
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				}
			} else {
				try {
					eval( response );
				} catch(error) {
					hideMsgAguardo();					
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				}
			}
			
			
			
		}				
	});
	return false;
}

function formataOpcaoM() {

	highlightObjFocus($('#'+frmOpcao));

	rCdagenci = $('label[for="cdagenci"]', '#'+frmOpcao);
	rCdagenci.css({'width':'120px'}).addClass('rotulo');
	
	// Input
	cCdagenci = $('#cdagenci', '#'+frmOpcao);
	cCdagenci.css({'width':'120px','text-align':'right'}).setMask('INTEGER','zz9','.','');

	cCdagenci.habilitaCampo().focus();
	
	// pac
	cCdagenci.unbind('keydown').bind('keydown', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		

			// Se é a tecla TAB, 
			if ( e.keyCode === 9 || e.keyCode == 13 ) {
				$(this).triggerHandler('blur');
				Gera_Impressao();
				return false;			
			}  else if ( e.keyCode === 9 || e.keyCode == 13 ) {
				return false;
			}	
			
	});	

	
	// centraliza a divUsoGenerico
	$('#divRotina').css({'width':'375px'});
	$('#divConteudo').css({'width':'350px', 'height':'90px'});	
	$('#divRotina').centralizaRotinaH();

	hideMsgAguardo();		
	bloqueiaFundo( $('#divRotina') );
	return false;
}


// imprimir
function Gera_Impressao() {	
		
	$('#cddopcao', '#'+frmOpcao).val( cddopcao );
	
	var action = UrlSite + 'telas/cadspc/imprimir_opcao_'+ cddopcao.toLowerCase() +'.php';
	
	carregaImpressaoAyllos(frmOpcao,action,"estadoInicial();");
	
}

// zoom contrato
function mostraContrato() {
	
	showMsgAguardo('Aguarde, buscando dados ...');

	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadspc/contrato.php', 
		data: {
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			buscaContrato();
			return false;
		}				
	});
	return false;
	
}

function buscaContrato() {
		
	showMsgAguardo('Aguarde, buscando dados ...');

	var nrdconta = normalizaNumero( cNrdconta.val() );	
	var nrcpfcgc = normalizaNumero( cNrcpfcgc.val() );	
	var nrctremp = normalizaNumero( cNrctremp.val() );	
	var tpidenti = normalizaNumero( cTpidenti.val() );	
	var tpctrdev = normalizaNumero( cTpctrdev.val() );	
	var nrctaavl = normalizaNumero( cNrctaavl.val() );	
	
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadspc/busca_contrato.php', 
		data: {
			cddopcao: cddopcao, 
			nrdconta: nrdconta, 
			nrcpfcgc: nrcpfcgc, 
			nrctremp: nrctremp, 
			tpidenti: tpidenti, 
			tpctrdev: tpctrdev, 
			nrctaavl: nrctaavl, 
			redirect: 'script_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {
		
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divConteudo').html(response);
					exibeRotina($('#divRotina'));
					formataContrato();
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

function formataContrato() {

	var divRegistro = $('div.divRegistros','#divContrato');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'130px'});
	
	var ordemInicial = new Array();
	
	var arrayLargura = new Array();
	arrayLargura[0] = '120px';
	arrayLargura[1] = '85px';
	arrayLargura[2] = '68px';
		
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'left';
	arrayAlinha[3] = 'left';
	
	var metodoTabela = 'selecionaContrato();';
			
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );

	// centraliza a divRotina
	$('#divRotina').css({'width':'425px'});
	$('#divConteudo').css({'width':'400px'});
	$('#divRotina').centralizaRotinaH();

	
	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	
	$('#btVoltar', '#divBotoesContrato').focus();
	
	return false;
}

function selecionaContrato() {
	
	if ( $('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao') ) {
					
		$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				nrdrowid = $('#nrdrowid', $(this) ).val(); 
			}	
		});
	}

	fechaRotina( $('#divRotina') );
	manterRotina('Busca_Dados');
	return false;
}


// zoom conta (devedor e fiador)
function mostraConta() {
	
	showMsgAguardo('Aguarde, buscando dados ...');

	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadspc/conta.php', 
		data: {
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			buscaConta();
			return false;
		}				
	});
	return false;
	
}

function buscaConta() {
		
	showMsgAguardo('Aguarde, buscando dados ...');

	var nrcpfcgc = normalizaNumero( cNrcpfcgc.val() );	
	
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadspc/busca_conta.php', 
		data: {
			nrcpfcgc: nrcpfcgc, 
			redirect: 'script_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {		
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divConteudo').html(response);
					exibeRotina($('#divRotina'));
					formataConta();
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

function formataConta() {

	var divRegistro = $('div.divRegistros','#divConta');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'130px'});
	
	var ordemInicial = new Array();
	
	var arrayLargura = new Array();
	arrayLargura[0] = '80px';
		
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'left';
	
	var metodoTabela = 'selecionaConta();';
			
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );

	// centraliza a divRotina
	$('#divRotina').css({'width':'425px'});
	$('#divConteudo').css({'width':'400px'});
	$('#divRotina').centralizaRotinaH();

	
	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	
	$('#btVoltar', '#divBotoesConta').focus();
	
	return false;
}

function selecionaConta() {

	var nrdconta = '';	
	var nmprimtl = '';	
	
	if ( $('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao') ) {
					
		$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				nrdconta = $('#nrdconta', $(this) ).val(); 
				nmprimtl = $('#nmprimtl', $(this) ).val(); 
			}	
		});
	}

	fechaConta(true,nrdconta,nmprimtl);
	
	return false;
}

function fechaConta(flgDados,nrdconta,nmprimtl) {
	// devedor
	if ( isHabilitado(cNrdconta) ) {
		if (flgDados) {
			cNrdconta.val(nrdconta);
			cNmprimtl.val(nmprimtl);
		}
		cNrdconta.focus();
	// fiador	
	} else if ( isHabilitado(cNrctaavl) ) {
		if (flgDados) {
			cNrctaavl.val(nrdconta);
			cNmpriavl.val(nmprimtl);
		}		
		cNrctaavl.focus();
	}
	
	fechaRotina( $('#divRotina') );
}

// zoom fiador
function mostraFiador() {
	
	showMsgAguardo('Aguarde, buscando dados ...');

	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadspc/fiador.php', 
		data: {
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			buscaFiador();
			return false;
		}				
	});
	return false;
	
}

function buscaFiador() {
		
	showMsgAguardo('Aguarde, buscando dados ...');

	var nrcpfcgc = normalizaNumero( cNrcpfcgc.val() );	
	
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cadspc/busca_fiador.php', 
		data: {
			nrcpfcgc: nrcpfcgc, 
			redirect: 'script_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {
		
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divConteudo').html(response);
					exibeRotina($('#divRotina'));
					formataFiador();
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

function formataFiador() {

	var divRegistro = $('div.divRegistros','#divFiador');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'130px'});
	
	var ordemInicial = new Array();
	
	var arrayLargura = new Array();
	arrayLargura[0] = '80px';
		
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'left';
	
	var metodoTabela = 'selecionaFiador();';
			
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );

	// centraliza a divRotina
	$('#divRotina').css({'width':'425px'});
	$('#divConteudo').css({'width':'400px'});
	$('#divRotina').centralizaRotinaH();

	
	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	
	return false;
}

function selecionaFiador() {
	
	if ( $('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao') ) {
					
		$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				nrdconta = $('#nrdconta', $(this) ).val(); 
				nmprimtl = $('#nmprimtl', $(this) ).val(); 
			}	
		});
	}

	cNrdconta.val(nrdconta);
	cNmprimtl.val(nmprimtl);
	fechaRotina( $('#divRotina') );
	return false;
}


// valida
function validaCampo( valor, campo, frm ) {	
	// conta
	if ( in_array(campo,['nrdconta','nrctaavl']) && !validaNroConta(valor) ) {
		showError('error','Dígito errado.','Alerta - Ayllos','$(\'#'+campo+'\',\'#'+frm+'\').focus();'); 
		return false; 
	
	// cpf/cnpj
	} else if ( campo == 'nrcpfcgc' && verificaTipoPessoa(valor) == 0 ) {
		showError('error','Dígito errado.','Alerta - Ayllos','$(\'#'+campo+'\',\'#'+frm+'\').focus();'); 
		return false; 
	
	// identificacao	
	} else if ( campo == 'tpidenti' && !in_array(valor,[1,3,4]) ) {
		showError('error','Opcao errada.','Alerta - Ayllos','$(\'#'+campo+'\',\'#'+frm+'\').focus();'); 
		return false; 
		
	// tipo	
	} else if ( campo == 'tpctrdev' && !in_array(valor,[1,2,3]) ) {
		showError('error','Opcao errada.','Alerta - Ayllos','$(\'#'+campo+'\',\'#'+frm+'\').focus();'); 
		return false; 
	}
	
	return true;
}

function habilitaConta() {
	cNrcpfcgc.desabilitaCampo();
	cNrdconta.habilitaCampo();
	cNrdconta.focus();
	controlaPesquisas();
	return false;
}


// botoes
function btnVoltar() {
	
	if ( cddopcao == 'C' ) {
		voltarOpacaoC();
		
	} else if ( in_array(cddopcao, ['A','B','I']) ) {
		voltarCadSPC()
	}	

	controlaPesquisas();
	return false;
}

function btnContinuar() {
	
	if ( divError.css('display') == 'block' ) { return false; }		

	if ( cddopcao == 'C' ) {
		prosseguirOpcaoC();
		
	} else if ( in_array(cddopcao, ['A','B','I']) ) {
		prosseguirCadSPC();	
	}	
	
	controlaPesquisas();
	return false;

}

function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>');

	if ( botao != '') {
		$('#divBotoes','#divTela').append('&nbsp;<a href="#" class="botao" onclick="btnContinuar(); return false;" >'+botao+'</a>');
	}
	return false;
}

/*!
 * FONTE        : bcaixa.js
 * CRIAÇÃO      : Rogerius Militão (DB1) 
 * DATA CRIAÇÃO : 25/10/2011
 * OBJETIVO     : Biblioteca de funções da tela BCAIXA
 * --------------
 * ALTERAÇÕES   : 27/01/2012 - Correção de cabeçalho (Tiago).
 * --------------
 * 28/06/2012 - Jorge        (CECRED) : Adicionado confirmacao de impressao para chamada da funcao Gera_Impressao()
 * 										Novo esquema para impressao, retirado window.open em Gera_Impressao()
 *
 * 16/04/2013 - Lucas R.	 (CECRED) : Incluir Array para largura para PAC na formataOpcaoT().
 *									    Incluir parametro tpcaicof em formataOpcaoT().
 *									    Ajustes de layout de form se tpcaicof for COFRE.
 *										Incluir novas functions gera_imp_T() e btnImprimir().
 *
 * 28/08/2013 - Carlos       (CECRED) : Incluido o campo data na opção T para filtrar os saldos dos caixas na procedure Busca_Dados.
 * 24/09/2013 - Carlos       (CECRED) : Inclusão da data na function btnImprimir.
 * 20/02/2015 - Lucas R.     (CECRED) : Ajustes na opcao "T" da Tela, Incluir opcao TOTAL (#245838)
 * 10/06/2016 - Kelvin       (CECRED) : Liberando letras no campo de operador conforme solicitado no chamado 461538.
 * 15/08/2017 - Lucas Ranghetti (CECRED): Incluir operauto(Operador do coordenado) na chamada do fonte mantar_rotina.php (#665982)
 * 16/01/2018 - Lucas Reinert (CECRED): Aumentado tamanho do campo de senha para 30 caracteres. (PRJ339) 
 */

//Formulários e Tabela
var frmCab   		= 'frmCab';
var frmDados   		= 'frmBcaixa';
var tabDados		= 'tabBcaixa';

var cddopcao		= 'I';
var vldentra		= '' ;
var flgsemhi		= '' ;
var nrJanelas		= 0  ;
var cdoplanc		= '' ;
var msgretor		= '' ;
var operauto        = '' ;

//Labels/Campos do cabeçalho
var rCddopcao, rDtmvtolt, rCdagenci, rNrdcaixa, rCdopecxa, rTpcaicof,
	cCddopcao, cDtmvtolt, cCdagenci, cNrdcaixa, cCdopecxa, cTpcaicof, cTodosCabecalho;

//Labels/Campos do dados
var rNrdmaqui, rQtautent, rNrdlacre, rVldsdini, rVldentra, rVldsaida, rVldsdfin,
	cNrdmaqui, cQtautent, cNrdlacre, cVldsdini, cVldentra, cVldsaida, cVldsdfin, cTodosDados;


$(document).ready(function() {
	estadoInicial();
	valorInicial();
});


// seletores
function estadoInicial() {
	$('#divTela').fadeTo(0,0.1);

	vldentra	= '';
	flgsemhi	= '';
	nrJanelas	= 0 ;
	cdoplanc	= '';
	msgretor	= '';
	
	fechaRotina($('#divRotina'));
	$('#divRotina').html('');
	
	trocaBotao('Prosseguir');
	hideMsgAguardo();		
	formataCabecalho( cddopcao );
	formataDados();

	cTodosDados.limpaFormulario().removeClass('campoErro');	

	removeOpacidade('divTela');
	
	if (cddopcao != 'T') {
		$("#panelTpcaicof").css({'visibility':'hidden'});
	}
	
	cCddopcao.focus();
}

function valorInicial() {
	cDtmvtolt.val( dtmvtglb );
	cCdagenci.val( cdageglb );
	cCdopecxa.val( cdopeglb );
	return false;
}

// controle
function manterRotina( operacao ) {

	hideMsgAguardo();		
	var dtmvtolt = cDtmvtolt.val();
	var cdagenci = normalizaNumero( cCdagenci.val() );	
	var nrdcaixa = normalizaNumero( cNrdcaixa.val() );
	var cdopecxa = cCdopecxa.val();	
	var vldentrx = operacao == 'GD' ? vldentra : cVldentra.val();
	var vldsaida = cVldsaida.val();
	var nrdlacre = normalizaNumero( cNrdlacre.val() );
	var qtautent = normalizaNumero( cQtautent.val() );
	var vldsdini = cVldsdini.val();
	var nrdmaqui = normalizaNumero( cNrdmaqui.val() );
	
	var dsdcompl = $('#dsdcompl', '#frmOpcaoLK').val();
	var vldocmto = $('#vldocmto', '#frmOpcaoLK').val();
	var cdhistor = $('#cdhistor', '#frmOpcaoLK').val();
	var nrdocmto = $('#nrdocmto', '#frmOpcaoLK').val();
	var nrseqdig = $('#nrseqdig', '#frmOpcaoLK').val();
	
	var mensagem = '';

	switch( operacao ) {
		case 'BD': mensagem = 'Aguarde, buscando...'; 	break;
		case 'VH': mensagem = 'Aguarde, validando...'; 	break;
		case 'VD': mensagem = 'Aguarde, validando...'; 	break;
		case 'GD': mensagem = 'Aguarde, gravando...'; 	break;
		default: return false; break;
	}
	
	showMsgAguardo( mensagem );	
	
	$.ajax({		
			type  : 'POST',
			url   : UrlSite + 'telas/bcaixa/manter_rotina.php', 		
			data: {
				operacao: operacao,
				cddopcao: cddopcao,
				dtmvtolt: dtmvtolt, 
				cdagenci: cdagenci,
				nrdcaixa: nrdcaixa,
				cdopecxa: cdopecxa,
				cdoplanc: cdoplanc,
				vldentra: vldentrx,
				vldsaida: vldsaida,
				nrdlacre: nrdlacre,
				qtautent: qtautent,
				vldsdini: vldsdini,
				nrdmaqui: nrdmaqui,
				dsdcompl: dsdcompl,
				vldocmto: vldocmto,
				cdhistor: cdhistor,
				nrdocmto: nrdocmto,
				nrseqdig: nrseqdig,
				operauto: operauto,
				redirect: 'script_ajax'
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
					alert('response: ' + response);
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				}
			}
		});

	return false;	
	                     
}       	

function controlaLayout( operacao ) {
		
	if ( cddopcao == 'F' && (operacao == 'BD' || operacao == 'VS') ) {
		hideMsgAguardo();
		
		if ( flgsemhi == 'yes' ) {
			estadoInicial();
			return false;
		}		
		
		cTodosCabecalho.desabilitaCampo();
		cVldentra.habilitaCampo().focus(); 
		cVldsaida.habilitaCampo();
		
	} else if ( cddopcao == 'F' && operacao == 'VD' ) {
		hideMsgAguardo();
		cVldentra.desabilitaCampo();	
		cVldsaida.desabilitaCampo();
		cQtautent.habilitaCampo().focus();
		
	} else if ( cddopcao == 'F' && operacao == 'VA' )  {
		if ( normalizaNumero( cQtautent.val() ) == 0 ) cQtautent.val('0');
		cQtautent.desabilitaCampo();
		cNrdlacre.habilitaCampo().focus();
		
	} else if ( cddopcao == 'F' && operacao == 'GD') {		
		showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Ayllos","Gera_Impressao('Gera_Boletim');","hideMsgAguardo();","sim.gif","nao.gif");	
		
	} else if ( cddopcao == 'I' && operacao == 'BD' ) {
		hideMsgAguardo();
		cTodosCabecalho.desabilitaCampo();		
		cNrdmaqui.habilitaCampo().focus();
		cVldsdini.habilitaCampo();	
	
	} else if ( cddopcao == 'I' && operacao == 'GD' ) {
		showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Ayllos","Gera_Impressao('Gera_Termo');","hideMsgAguardo();","sim.gif","nao.gif");	
			
	}  else if ( (cddopcao == 'L' || cddopcao == 'K') && cdoplanc == 'I' && operacao == 'VH' ) {
		hideMsgAguardo();
		bloqueiaFundo($('#divRotina'));
		$('#cdhistor', '#frmOpcaoLK').desabilitaCampo();
		$('#nrdocmto', '#frmOpcaoLK').habilitaCampo();
		$('#vldocmto', '#frmOpcaoLK').habilitaCampo();
		trocaBotaoOpcaoLK('concluir');
		
	}  else if ( (cddopcao == 'L' || cddopcao == 'K') &&  cdoplanc == 'E' && operacao == 'VD' ) {
		hideMsgAguardo();
		bloqueiaFundo($('#divRotina'));
		showConfirmacao('Confirmar elimitação?','Confirma&ccedil;&atilde;o - Ayllos','manterRotina(\'GD\');','bloqueiaFundo($(\'#divRotina\'));','sim.gif','nao.gif');

	}  else if ( (cddopcao == 'L' || cddopcao == 'K') &&  cdoplanc == 'A' && operacao == 'VD' ) {
		hideMsgAguardo();
		bloqueiaFundo($('#divRotina'));
		$('#cdhistor', '#frmOpcaoLK').focus();
		$('#nrdocmto', '#frmOpcaoLK').desabilitaCampo();
		$('#nrseqdig', '#frmOpcaoLK').desabilitaCampo();

	}  else if ( (cddopcao == 'L' || cddopcao == 'K') &&  cdoplanc == 'A' && operacao == 'VH' ) {
		trocaBotaoOpcaoLK('concluir');
		$('#cdhistor', '#frmOpcaoLK').desabilitaCampo();
		hideMsgAguardo();
		bloqueiaFundo($('#divRotina'));
	
	} else if ( cddopcao == 'K' &&  cdoplanc == '' && operacao == 'GD' ) { //
		hideMsgAguardo();
		showError('inform','Boletim reaberto.','Alerta - Ayllos',"exibeRotina( $('#divRotina') );");
	} 
	
	return false;
}


function formataCabecalho( cddopaux ) {

    $("#panelTpcaicof").css({'visibility':'visible'});

	var nomeForm    = 'frmCab';
	highlightObjFocus( $('#'+nomeForm) );
	highlightObjFocus( $('#'+'frmBcaixa') );
		
	cddopcao = ( typeof cddopaux != 'undefined' ) ? cddopaux : '';
		
	// rotulo
	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab); 
	rDtmvtolt	        = $('label[for="dtmvtolt"]','#'+frmCab);        
	rCdagenci	        = $('label[for="cdagenci"]','#'+frmCab);        
	rNrdcaixa	        = $('label[for="nrdcaixa"]','#'+frmCab);        
	rCdopecxa	        = $('label[for="cdopecxa"]','#'+frmCab);
    rTpcaicof	        = $('label[for="tpcaicof"]','#'+frmCab);

	rCddopcao.addClass('rotulo').css({'width':'45px'});
	rDtmvtolt.addClass('rotulo-linha').css({'width':'42px'});
	rCdagenci.addClass('rotulo-linha').css({'width':'43px'});
	rNrdcaixa.addClass('rotulo-linha').css({'width':'48px'});
	rCdopecxa.addClass('rotulo-linha').css({'width':'71px'});
	rTpcaicof.addClass('rotulo-linha').css({'width':'41px'});
	
	// campo
	cCddopcao			= $('#cddopcao','#'+frmCab); 
	cDtmvtolt			= $('#dtmvtolt','#'+frmCab); 
	cCdagenci			= $('#cdagenci','#'+frmCab); 
	cNrdcaixa			= $('#nrdcaixa','#'+frmCab); 
	cCdopecxa			= $('#cdopecxa','#'+frmCab); 
	cTpcaicof			= $('#tpcaicof','#'+frmCab);
	
	cCddopcao.css({'width':'477px'})
	cDtmvtolt.addClass('data').css({'width':'73px'});	
	cCdagenci.addClass('inteiro').css({'width':'30px'}).attr('maxlength','3');		
	cNrdcaixa.addClass('inteiro').css({'width':'30px'}).attr('maxlength','3');		
	cCdopecxa.css({'width':'78px'}).attr('maxlength','10');	
	cTpcaicof.css({'width':'70px'});
	
	// outros
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	cTodosCabecalho.habilitaCampo();
	cCddopcao.habilitaCampo();
	cCddopcao.focus();
	cCddopcao.val( cddopcao );
	
	cCddopcao.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9) {	
			cDtmvtolt.focus();
			return false;
		}
	});
	
	cDtmvtolt.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9) {	
			cCdagenci.focus();
			return false;
		}
	});
	
	cCdagenci.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9) {	
			cNrdcaixa.focus();
			return false;
		}
	});
	
	cNrdcaixa.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9) {	
			cCdopecxa.focus();
			return false;
		}
	});
	
	cCdopecxa.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9) {	
			btnContinuar();
			return false;
		}
	});
	
	cTpcaicof.desabilitaCampo();
	
	if ( $.browser.msie ) {
	}	
	
	layoutPadrao();
	
	if ( cddopcao == 'T' ) {

		cCdagenci.focus();
		cNrdcaixa.desabilitaCampo();	
		cCdopecxa.desabilitaCampo();
		cTpcaicof.habilitaCampo();
		
		cCdagenci.val('');
		cNrdcaixa.val('');
		cCdopecxa.val('');
		
		$("#panelTpcaicof").css({'visibility':'visible'});
		
		cCddopcao.unbind('keydown').bind('keydown', function(e) {
			if ( e.keyCode == 13 || e.keyCode == 9) {	
				cCdagenci.focus();
				return false;
			}
		});
		
		cCdagenci.unbind('keydown').bind('keydown', function(e) {
			if ( e.keyCode == 13 || e.keyCode == 9) {	
				cTpcaicof.focus();
				return false;
			}
		});
		
		cTpcaicof.unbind('keydown').bind('keydown', function(e) {
			if ( e.keyCode == 13 || e.keyCode == 9) {	
				btnContinuar();
				return false;
			}
		});
	} 

	
	return false;	
}

function formataDados() {

	// rotulo
	rNrdmaqui			= $('label[for="nrdmaqui"]','#'+frmDados); 
	rQtautent	        = $('label[for="qtautent"]','#'+frmDados);        
	rNrdlacre	        = $('label[for="nrdlacre"]','#'+frmDados);        
	rVldsdini	        = $('label[for="vldsdini"]','#'+frmDados);        
	rVldentra	        = $('label[for="vldentra"]','#'+frmDados);        
	rVldsaida	        = $('label[for="vldsaida"]','#'+frmDados);        
	rVldsdfin	        = $('label[for="vldsdfin"]','#'+frmDados);        

	rNrdmaqui.addClass('rotulo').css({'width':'87px'});
	rQtautent.addClass('rotulo-linha').css({'width':'150px'});
	rNrdlacre.addClass('rotulo-linha').css({'width':'83px'});
	rVldsdini.addClass('rotulo').css({'width':'280px'});
	rVldentra.addClass('rotulo').css({'width':'280px'});
	rVldsaida.addClass('rotulo').css({'width':'280px'});
	rVldsdfin.addClass('rotulo').css({'width':'280px'});
	
	// campo
	cNrdmaqui			= $('#nrdmaqui','#'+frmDados); 
	cQtautent			= $('#qtautent','#'+frmDados); 
	cNrdlacre			= $('#nrdlacre','#'+frmDados); 
	cVldsdini			= $('#vldsdini','#'+frmDados); 
	cVldentra			= $('#vldentra','#'+frmDados); 
	cVldsaida			= $('#vldsaida','#'+frmDados); 
	cVldsdfin			= $('#vldsdfin','#'+frmDados); 

	cNrdmaqui.addClass('inteiro').css({'width':'80px', 'text-align':'right'}).attr('maxlength','3');
	cQtautent.css({'width':'80px', 'text-align':'right'}).setMask('INTEGER','z.zzz','.','');
	cNrdlacre.css({'width':'80px', 'text-align':'right'}).setMask('INTEGER','z.zzz.zzz','.','');	
	cVldsdini.addClass('monetario').css({'width':'123px'});	
	cVldentra.addClass('monetario').css({'width':'123px'});	
	cVldsaida.addClass('monetario').css({'width':'123px'});	
	cVldsdfin.addClass('monetario').css({'width':'123px'});	

	// outros
	cTodosDados		= $('input[type="text"],select','#'+frmDados);
	
	cNrdmaqui.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9) {	
			cVldsdini.focus();
			return false;
		}
	});
	
	if ( $.browser.msie ) {
	}	
	
	cTodosDados.desabilitaCampo();
	
	layoutPadrao();
	return false;
}


// opcao C
function formataOpcaoC() { 
	
	// tabela
	var divRegistro = $('div.divRegistros', '#frmOpcaoc');		
	var tabela      = $('table', divRegistro );
	
	$('#frmOpcaoc').css({'margin-top':'5px'});
	divRegistro.css({'height':'120px','padding-bottom':'2px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '90px';
	arrayLargura[1] = '75px';
	arrayLargura[2] = '85px';
	arrayLargura[3] = '120px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'center';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'right';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	
	/********************
	  EVENTO COMPLEMENTO	
	*********************/
	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		seleciona($(this));
	});	

	// seleciona o registro que é focado
	$('table > tbody > tr', divRegistro).focus( function() {
		seleciona($(this));
	});	

	$('table > tbody > tr:eq(0)', divRegistro).click();
	
	// centraliza a divRotina
	$('#divRotina').css({'width':'575px'});
	$('#divConteudo').css({'width':'550px'});
	$('#divRotina').centralizaRotinaH();
	
	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	return false;
}

// opcao L e K
function formataOpcaoLK( cdoplanx ) {

	var legend = '';
	cdoplanc = ( typeof cdoplanx != 'undefined' ) ? cdoplanx : '';

	if ( cdoplanc == 'C' ) {

		// tabela
		var divRegistro = $('div.divRegistros', '#frmOpcaoLK');		
		var tabela      = $('table', divRegistro );
		
		$('#frmOpcaoLK').css({'margin-top':'5px'});
		divRegistro.css({'height':'140px','padding-bottom':'2px'});

		var ordemInicial = new Array();

		var arrayLargura = new Array();
		arrayLargura[0] = '27px';
		arrayLargura[1] = '170px';
		arrayLargura[2] = '112px';
		arrayLargura[3] = '38px';
		arrayLargura[4] = '80px';

		var arrayAlinha = new Array();
		arrayAlinha[0] = 'right';
		arrayAlinha[1] = 'left';
		arrayAlinha[2] = 'left';
		arrayAlinha[3] = 'right';
		arrayAlinha[4] = 'right';
		arrayAlinha[5] = 'right';
		
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

		// centraliza a divRotina
		$('#divRotina').css({'width':'575px'});
		$('#divConteudo').css({'width':'550px'});
		$('#divRotina').centralizaRotinaH();
		
		legend = ' - Consultar';
		
	} else {

		// rotulo
		rCdhistor	        = $('label[for="cdhistor"]','#frmOpcaoLK');  
		rNrctadeb	        = $('label[for="nrctadeb"]','#frmOpcaoLK');  
		rNrctacrd	        = $('label[for="nrctacrd"]','#frmOpcaoLK');  
		rCdhistox	        = $('label[for="cdhistox"]','#frmOpcaoLK');  
		rDsdcompl	        = $('label[for="dsdcompl"]','#frmOpcaoLK');        
		rNrdocmto	        = $('label[for="nrdocmto"]','#frmOpcaoLK');        
		rVldocmto	        = $('label[for="vldocmto"]','#frmOpcaoLK');        
		rNrseqdig	        = $('label[for="nrseqdig"]','#frmOpcaoLK');        
		rBotoes12	        = $('label[for="botoes12"]','#frmOpcaoLK');        

		rCdhistor.addClass('rotulo').css({'width':'90px'});
		rNrctadeb.addClass('rotulo-linha').css({'width':'20px'});
		rNrctacrd.addClass('rotulo-linha').css({'width':'20px'});
		rCdhistox.addClass('rotulo-linha').css({'width':'20px'});
		rDsdcompl.addClass('rotulo').css({'width':'90px'});
		rNrdocmto.addClass('rotulo').css({'width':'90px'});
		rVldocmto.addClass('rotulo').css({'width':'90px'});
		rNrseqdig.addClass('rotulo').css({'width':'90px'});
		rBotoes12.addClass('rotulo').css({'width':'90px'});
		 
		// campo
		cCdhistor			= $('#cdhistor','#frmOpcaoLK'); 
		cDshistor			= $('#dshistor','#frmOpcaoLK'); 
		cNrctadeb			= $('#nrctadeb','#frmOpcaoLK'); 
		cNrctacrd			= $('#nrctacrd','#frmOpcaoLK'); 
		cCdhistox			= $('#cdhistox','#frmOpcaoLK'); 
		cDsdcompl			= $('#dsdcompl','#frmOpcaoLK'); 
		cNrdocmto			= $('#nrdocmto','#frmOpcaoLK'); 
		cVldocmto			= $('#vldocmto','#frmOpcaoLK'); 
		cNrseqdig			= $('#nrseqdig','#frmOpcaoLK'); 

		cCdhistor.addClass('inteiro').css({'width':'40px'}).attr('maxlength','4');	
		cDshistor.css({'width':'145px'});	
		cNrctadeb.css({'width':'40px'});	
		cNrctacrd.css({'width':'40px'});	
		cCdhistox.css({'width':'40px'});	
		cDsdcompl.css({'width':'188px'}).attr('maxlength','30');	
		cNrdocmto.css({'width':'113px'}).setMask('INTEGER','zzz.zzz','.','');;	
		cVldocmto.addClass('monetario').css({'width':'113px'});	
		cNrseqdig.css({'width':'113px'});	
		
		$('input, select', '#frmOpcaoLK').desabilitaCampo().limpaFormulario();
		trocaBotaoOpcaoLK('Prosseguir');
		
		
		// IE
		if ( $.browser.msie ) {
			rNrctacrd.css({'width':'22px'});
		}

		if ( cdoplanc == 'I' ) {
			legend = ' - Incluir';
			cCdhistor.habilitaCampo().focus();	
		
		} else if ( cdoplanc == 'E' || cdoplanc == 'A' ) {
			if ( cdoplanc == 'E' ) {
				legend = ' - Excluir';
				trocaBotaoOpcaoLK('concluir');
			} else if ( cdoplanc == 'A' ) {
				legend = ' - Alterar';
			}
			
			cCdhistor.habilitaCampo().focus();
			cNrdocmto.habilitaCampo();
			cNrseqdig.habilitaCampo();
		}

		//
		cCdhistor.unbind('keypress').bind('keypress', function(e) {
			if ( divError.css('display') == 'block' ) { return false; }		
			// Se é a tecla ENTER, 
			if ( e.keyCode == 13 && cdoplanc == 'I' ) {
				manterRotina('VH');
				return false;
			}
			
			
		});	

		// centraliza a divRotina
		$('#divRotina').css({'width':'525px'});
		$('#divConteudo').css({'width':'500px'});
		$('#divRotina').centralizaRotinaH();
		
	}

	//
	if ( cddopcao == 'L' ) {
		$('legend', '#frmOpcaoLK').html('Lançamentos Extra-Sistema' + legend );
	
	} else if ( cddopcao == 'K' ) {
		$('legend', '#frmOpcaoLK').html('Lançamentos Especiais' + legend );
	}
	
	layoutPadrao();
	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	return false;
}

// opcao S
function formataOpcaoS() { 
	
	// tabela
	var divRegistro = $('div.divRegistros', '#frmOpcaoS');		
	var tabela      = $('table', divRegistro );
	
	$('#frmOpcaoS').css({'margin-top':'5px'});
	divRegistro.css({'height':'150px','padding-bottom':'2px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '35px';
	arrayLargura[1] = '35px';
	arrayLargura[2] = '190px';
	arrayLargura[3] = '13px';
	arrayLargura[4] = '90px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'left';
	arrayAlinha[3] = 'center';
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'right';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

	/********************
	  EVENTO COMPLEMENTO	
	*********************/
	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		seleciona($(this));
	});	

	// seleciona o registro que é focado
	$('table > tbody > tr', divRegistro).focus( function() {
		seleciona($(this));
	});	

	$('table > tbody > tr:eq(0)', divRegistro).click();
	
	// centraliza a divRotina
	$('#divRotina').css({'width':'575px'});
	$('#divConteudo').css({'width':'550px'});
	$('#divRotina').centralizaRotinaH();
	
	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	return false;
}

// opcao T
function formataOpcaoT(tpcaicof) { 
	
	// tabela
	var divRegistro = $('div.divRegistros', '#frmOpcaoT');		
	var tabela      = $('table', divRegistro );
	
	var ordemInicial = new Array();
	
	if(tpcaicof == "CAIXA"){
		
		$('#frmOpcaoT').css({'margin-top':'5px'});
		divRegistro.css({'height':'150px','padding-bottom':'2px'});
		
		$(".csTotal",tabela).hide();
		$(".csCaiCof",tabela).hide();
		$(".csCaixa",tabela).show();
		
		var arrayLargura = new Array();
		arrayLargura[0] = '40px';
		arrayLargura[1] = '40px';
		arrayLargura[2] = '250px';
		arrayLargura[3] = '75px';

		var arrayAlinha = new Array();
		arrayAlinha[0] = 'right';
		arrayAlinha[1] = 'left';
		arrayAlinha[2] = 'left';
		arrayAlinha[3] = 'left';
		
		// centraliza a divRotina
		$('#divRotina').css({'width':'575px'});
		$('#divConteudo').css({'width':'550px'});
		$('#divRotina').centralizaRotinaH();
	
	}else if (tpcaicof == "COFRE"){
	
		$('#frmOpcaoT').css({'margin-top':'5px'});
		divRegistro.css({'height':'100px','padding-bottom':'2px'});
		
		
		var arrayLargura = new Array();
		arrayLargura[0] = '50px';

		var arrayAlinha = new Array();
		arrayAlinha[0] = 'right';
		arrayAlinha[3] = 'right';
		
		
		$(".csCaixa",tabela).hide();
		$(".csTotal",tabela).hide();
		$(".csCaiCof",tabela).hide();
		$(".csCofre",tabela).show();
		
		// centraliza a divRotina
		$('#divRotina').css({'width':'335px'});
		$('#divConteudo').css({'width':'310px'});
		$('#divRotina').centralizaRotinaH();
		
	}else if (tpcaicof == "TOTAL"){
	
		$('#frmOpcaoT').css({'margin-top':'5px'});
		divRegistro.css({'height':'150px','padding-bottom':'2px'});
		
		$(".csCaixa",tabela).hide();
		$(".csCofre",tabela).hide();
		
		var arrayLargura = new Array();
		arrayLargura[0] = '50px';
		if (cCdagenci.val() != 0) {
			arrayLargura[5] = '150px';
			arrayLargura[6] = '150px';
		}else{
			arrayLargura[7] = '150px'; // Saldo(Caixa + Cofre)
		}

		var arrayAlinha = new Array();
		arrayAlinha[0] = 'right'; // PA
		if (cCdagenci.val() != 0) {
			
			$(".csCaiCof",tabela).hide();
			$(".csTotal",tabela).show();
			
			arrayAlinha[5] = 'right'; // Valor Caixa
			arrayAlinha[6] = 'right'; // Valor Cofre
			
			// centraliza a divRotina
			$('#divRotina').css({'width':'475px'});
			$('#divConteudo').css({'width':'450px'});
		}else{
			$(".csTotal",tabela).hide();
			$(".csCaiCof",tabela).show();
			arrayAlinha[7] = 'right'; // Saldo(Caixa + Cofre)

			// centraliza a divRotina
			$('#divRotina').css({'width':'375px'});
			$('#divConteudo').css({'width':'350px'});
		}
		
		$('#divRotina').centralizaRotinaH();
	}
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
		
	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	return false;
			
}


// 
function seleciona( tr ) {
	$('#ndrrecid','#frmImprimir').val( $('#nrcrecid', tr).val() );
	$('#nrdlacre','#frmImprimir').val( $('#nrdlacre', tr).val() );
	return false;
}

function mostraOpcao( cdoplanx ) {
	
	cdoplanc = ( typeof cdoplanx != 'undefined' ) ? cdoplanx : '';
	showMsgAguardo('Aguarde, buscando ...');

	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/bcaixa/opcao.php', 
		data: {
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			buscaOpcao();
			return false;
		}				
	});
	return false;
	
}

function buscaOpcao() {

	var dtmvtolt = cDtmvtolt.val();
	var cdagenci = normalizaNumero( cCdagenci.val() );
	var nrdcaixa = normalizaNumero( cNrdcaixa.val() );
	var cdopecxa = cCdopecxa.val();
	var tpcaicof = cTpcaicof.val();
	
	showMsgAguardo('Aguarde, buscando ...');
		
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/bcaixa/busca_opcao.php', 
		data: {
			cddopcao: cddopcao,
			dtmvtolt: dtmvtolt, 
			cdagenci: cdagenci,
			nrdcaixa: nrdcaixa,
			cdopecxa: cdopecxa,
			cdoplanc: cdoplanc,
			tpcaicof: tpcaicof,
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
					if ( cddopcao == 'K' && msgretor != '' ) {
						showConfirmacao(msgretor,'Confirma&ccedil;&atilde;o - Ayllos','manterRotina(\'GD\');','estadoInicial();','sim.gif','nao.gif');
					} else {		
						exibeRotina( $('#divRotina') );
					}
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
			
			switch ( cddopcao ) {
				case 'C': formataOpcaoC(); 			break;
				case 'K': formataOpcaoLK(cdoplanc); break;
				case 'L': formataOpcaoLK(cdoplanc); break;
				case 'S': formataOpcaoS(); 			break;
				case 'T': formataOpcaoT(tpcaicof);	break;
			}
			
		}				
	});
	return false;
}


// imprimir
function Gera_Impressao( operacao ) {	
	
	$('#operacao','#frmImprimir').val( operacao );
	$('#cddopcao','#frmImprimir').val( cddopcao );

	var action    = UrlSite + 'telas/bcaixa/imprimir_dados.php';	
	var callafter = "bloqueiaFundo(divRotina);";
	
	if ( cddopcao != 'C' && cddopcao != 'S' ) { callafter = "estadoInicial();" }	
		
	carregaImpressaoAyllos("frmImprimir",action,callafter);
	
}


// senha
function mostraSenha() {

	showMsgAguardo('Aguarde, abrindo ...');

	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/bcaixa/senha.php', 
		data: {
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divUsoGenerico').html(response);
			buscaSenha();
			return false;
		}				
	});
	return false;
	
}

function buscaSenha() {

	hideMsgAguardo();		
		
	showMsgAguardo('Aguarde, abrindo ...');

	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/bcaixa/form_senha.php', 
		data: {
			redirect: 'script_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {
		
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divConteudoSenha').html(response);
					exibeRotina($('#divUsoGenerico'));
					formataSenha();
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

function formataSenha() {

	rOperador 	= $('label[for="operauto"]', '#frmSenha');
	rSenha		= $('label[for="codsenha"]', '#frmSenha');	
	
	rOperador.addClass('rotulo').css({'width':'135px'});
	rSenha.addClass('rotulo').css({'width':'135px'});

	cOperador	= $('#operauto', '#frmSenha');
	cSenha		= $('#codsenha', '#frmSenha');
	
	cOperador.addClass('campo').css({'width':'100px'}).attr('maxlength','10').focus();		
    cSenha.addClass('campo').css({'width':'100px'}).attr('maxlength','30');		
	


	// centraliza a divRotina
	$('#divUsoGenerico').css({'width':'355px'});
	$('#divConteudoSenha').css({'width':'330px', 'height':'110px'});	
	$('#divUsoGenerico').centralizaRotinaH();
	
	layoutPadrao();
	hideMsgAguardo();		
	bloqueiaFundo( $('#divUsoGenerico') );
	return false;
}

function validarSenha() {
		
	hideMsgAguardo();		
	
	// Situacao
	operauto 		= $('#operauto','#frmSenha').val();
	var codsenha 	= $('#codsenha','#frmSenha').val();

	codsenha = encodeURIComponent(codsenha, "UTF-8");
	
	showMsgAguardo( 'Aguarde, validando ...' );	

	$.ajax({		
			type  : 'POST',
			async : true ,
			url   : UrlSite + 'telas/bcaixa/valida_senha.php', 		
			data: {
				operauto	: operauto,		
				codsenha	: codsenha,
				cddopcao    : cddopcao,
				redirect	: 'script_ajax'
			}, 
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
			},
			success: function(response) {
				try {
					eval(response);
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		});

	return false;	
	                     
}       	


// botoes
function btnVoltar() {
	
	if ( cddopcao == 'L' && cdoplanc == 'I' && $('#vldocmto', '#frmOpcaoLK').hasClass('campo') ) {
		formataOpcaoLK('I'); 

	} else if ( cddopcao == 'L' && cdoplanc != '' ) {
		formataOpcaoLK(); 
	
	} else {
		estadoInicial();
	
	}
	return false;
}

function btnContinuar() {
	
	if ( divError.css('display') == 'block' ) { return false; }		

	if ( cddopcao == 'C' ) {		
		mostraOpcao();		
	} else if ( cddopcao == 'F' && cNrdlacre.hasClass('campo') ) {
		if ( normalizaNumero(cNrdlacre.val()) == 0 ) {
			showError('error','375 - O campo deve ser preenchido.','Alerta - Ayllos',"unblockBackground(); cNrdlacre.focus();");
		} else {
			showConfirmacao('Confirma fechamento?','Confirma&ccedil;&atilde;o - Ayllos','manterRotina(\'GD\');','','sim.gif','nao.gif');
		}
		
	} else if ( cddopcao == 'F' && cQtautent.hasClass('campo') ) {
		if ( normalizaNumero(cQtautent.val()) == 0 ) {
			showConfirmacao('Sem autenticacoes hoje?','Confirma&ccedil;&atilde;o - Ayllos','controlaLayout(\'VA\');','','sim.gif','nao.gif');
		} else {
			controlaLayout('VA');
		}
		
	} else if ( cddopcao == 'F' && cVldentra.hasClass('campo') ) {
		manterRotina('VD');
		
	} else if ( cddopcao == 'F' ) {
		manterRotina('BD');
	
	} else if ( cddopcao == 'I' && cVldsdini.hasClass('campo') ) {
		manterRotina('GD');
		
	} else if ( cddopcao == 'I' ) {
		manterRotina('BD');

	} else if ( (cddopcao == 'L' || cddopcao == 'K') && cdoplanc == 'A' && $('#cdhistor', '#frmOpcaoLK').hasClass('campo') 
																		&& $('#nrdocmto', '#frmOpcaoLK').hasClass('campo') ) {
		manterRotina('VD');
		
	} else if ( (cddopcao == 'L' || cddopcao == 'K')  && cdoplanc == 'A' && $('#vldocmto', '#frmOpcaoLK').hasClass('campo') ) {
		showConfirmacao('Confirma alteracao?','Confirma&ccedil;&atilde;o - Ayllos','manterRotina(\'GD\');','','sim.gif','nao.gif');

	} else if ( (cddopcao == 'L' || cddopcao == 'K')  && cdoplanc == 'A' && $('#cdhistor', '#frmOpcaoLK').hasClass('campo') ) {
		manterRotina('VH');
		
	} else if ( (cddopcao == 'L' || cddopcao == 'K')  && cdoplanc == 'E' && $('#cdhistor', '#frmOpcaoLK').hasClass('campo') ) {
		manterRotina('VD');
		
	} else if ( (cddopcao == 'L' || cddopcao == 'K')  && cdoplanc == 'I' && $('#vldocmto', '#frmOpcaoLK').hasClass('campo') ) {
		manterRotina('GD');
		
	} else if ( (cddopcao == 'L' || cddopcao == 'K')  && cdoplanc == 'I' && $('#cdhistor', '#frmOpcaoLK').hasClass('campo') ) {
		manterRotina('VH');
		
	} else if ( (cddopcao == 'L' || cddopcao == 'K')  && cdoplanc == '' ) {
		mostraOpcao();

	} else if ( cddopcao == 'S' ) {
		mostraOpcao();
	
	} else if ( cddopcao == 'T' ) {
		mostraOpcao();

	}
	
	return false;

}


function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>&nbsp;');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onclick="btnContinuar(); return false;">'+botao+'</a>&nbsp;');
		
	return false;
}

function trocaBotaoOpcaoLK( botao ) {
	$('#btSalvar','#divRotina').attr('src','../../imagens/botoes/'+botao+'.gif')
	return false;
}

function gera_imp_T() {
		
	showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Ayllos","btnImprimir();","hideMsgAguardo();","sim.gif","nao.gif");	
	
}

function btnImprimir() {

	var tpcaicof = cTpcaicof.val();
	var cdagenci = cCdagenci.val();
	var dtmvtolt = cDtmvtolt.val();
	
	$('#tpcaicof','#frmImprimir').val( tpcaicof );
	$('#cdagenci','#frmImprimir').val( cdagenci );
	$('#dtmvtolt','#frmImprimir').val( dtmvtolt );
	
	var action    = UrlSite + 'telas/bcaixa/Imprimir_opcaoT.php';	
	var callafter = "bloqueiaFundo(divRotina);";
	
	carregaImpressaoAyllos("frmImprimir",action,callafter);

}

function changeTpcaicof(val) {

	if (val == 'COFRE') {
		$("#dtmvtolt").val('');
	    $("#dtmvtolt").desabilitaCampo();
	} else {
		$("#dtmvtolt").val(dtmvtglb);
		$("#dtmvtolt").habilitaCampo();
	}	
	$("#cdagenci").focus();
}

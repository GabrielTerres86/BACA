/*!
 * FONTE        : concbb.js
 * CRIAÇÃO      : Rogerius Militão (DB1) 
 * DATA CRIAÇÃO : 18/08/2011
 * OBJETIVO     : Biblioteca de funções da tela CONCBB
 * --------------
 * ALTERAÇÕES   :
 * 000: [02/07/2012] Jorge Hamaguchi  (CECRED): Alterado funcao Gera_Impressao(), novo esquema para impressao
 * 001: [05/03/2013] Gabriel Ramirez  (CECRED): Novo padrao do layout (Gabriel) 
 * 002: [08/01/2019] Christian Grauppe (Envolti): Alterações P510, campo Tipo Pgto.
 * --------------
 */

var cddopcao = '';
 
//Formulários e Tabela
var frmCab   		= 'frmCab';
var frmDados  		= 'frmConcbb';
var tabDados		= 'tabConcbb';

//Imprimir
var nrJanelas		= 0;

// Opcao T
var msgprint		= '';
var mrsgetor		= '';

//Labels/Campos do cabeçalho
var rCddopcao, rDtmvtolt, rCdagenci, rNrdcaixa, rValorpag, rInss, rRegistro,
	cCddopcao, cDtmvtolt, cCdagenci, cNrdcaixa, cValorpag, cInss, cRegistro, cTodosCabecalho, btnOK;

$(document).ready(function() {
	estadoInicial();
});

// seletores
function estadoInicial() {
	$('#divTela').fadeTo(0,0.1);

	fechaRotina( $('#divRotina') );
	trocaBotao('Prosseguir');
	hideMsgAguardo();		
	formataCabecalho();
	formataDados();

	$('#registro', '#'+frmCab).val('');
	cddopcao	= cCddopcao.val();	
	
	cTodosCabecalho.limpaFormulario();
	cCddopcao.val(cddopcao);

	$('#'+tabDados).css({'display':'none'});
	$('#divBotoes').css({'display':'block'});
	
	removeOpacidade('divTela');
	return false;
}

function estadoCabecalho() {
	$('#divTela').fadeTo(0,0.1);

	$('#registro', '#'+frmCab).val('');

	fechaRotina( $('#divRotina') );
	trocaBotao('Prosseguir');
	hideMsgAguardo();		
	
	$('#'+frmDados).css({'display':'none'});
	$('#'+tabDados).css({'display':'none'});
	$('#divBotoes').css({'display':'block'});
	cTodosCabecalho.habilitaCampo();
	cCddopcao.desabilitaCampo();
	cDtmvtolt.focus();

	if ( cddopcao == 'D' || cddopcao == 'T') { 
		cInss.desabilitaCampo(); 
	} 
	
	removeOpacidade('divTela');
	return false;
}

// controle
function controlaOperacao( nriniseq, nrregist, flggeren ) {

	flggeren = ( typeof flggeren != 'undefined' ) ? flggeren : '';
	hideMsgAguardo();

	var mensagem = 'Aguarde, buscando ...';
	var cddopcao = cCddopcao.val();
	var dtmvtolx = cDtmvtolt.val();
	var cdagencx = normalizaNumero( cCdagenci.val() );
	var nrdcaixx = normalizaNumero( cNrdcaixa.val() );
	var inss	 = cInss.val() != null ? cInss.val() : '' ;
	var valorpag = cValorpag.val();
		
	showMsgAguardo( mensagem );	

	// Carrega dados da conta através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/concbb/principal.php', 
		data    : 
				{ 
					cddopcao	: cddopcao,
					dtmvtolx	: dtmvtolx,			
					cdagencx	: cdagencx,			
					nrdcaixx	: nrdcaixx,			
					inss		: inss,				
					valorpag    : valorpag,
					flggeren	: flggeren,
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


// formata
function formataCabecalho() {

	// cabecalho
	rCddopcao			= $('label[for="cddopcao"]'	,'#'+frmCab); 
	rDtmvtolt			= $('label[for="dtmvtolt"]'	,'#'+frmCab); 
	rCdagenci			= $('label[for="cdagenci"]'	,'#'+frmCab); 
	rNrdcaixa			= $('label[for="nrdcaixa"]'	,'#'+frmCab); 
	rValorpag			= $('label[for="valorpag"]'	,'#'+frmCab); 
	rInss				= $('label[for="inss"]'		,'#'+frmCab); 
	
	cCddopcao			= $('#cddopcao'	,'#'+frmCab); 
	cDtmvtolt			= $('#dtmvtolt'	,'#'+frmCab);
	cCdagenci			= $('#cdagenci'	,'#'+frmCab);
	cNrdcaixa			= $('#nrdcaixa'	,'#'+frmCab);
	cValorpag			= $('#valorpag'	,'#'+frmCab);
	cInss				= $('#inss'		,'#'+frmCab);
	
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	btnOK				= $('#btnOK','#'+frmCab);
	
	// Formata
	if ( cddopcao == 'D' ) {
	
		rCddopcao.addClass('rotulo').css({'width':'68px'});
		rDtmvtolt.addClass('rotulo').css({'width':'68px'});	
		rCdagenci.addClass('rotulo-linha').css({'width':'33px'});		
		rNrdcaixa.addClass('rotulo-linha').css({'width':'38px'});		
		rValorpag.addClass('rotulo-linha').css({'display':'block','width':'38px'});
		rInss.addClass('rotulo-linha').css({'width':'33px'});			
		
		cCddopcao.css({'width':'456px'});
		cDtmvtolt.addClass('data').css({'width':'75px'});	
		cCdagenci.css({'width':'61px'});		
		cNrdcaixa.css({'width':'61px'});
		cValorpag.addClass('monetario').css({'display':'block','width':'70px'});	
		cInss.css({'width':'61px'});		

		if ( $.browser.msie ) {
			rCdagenci.css({'width':'36px'});		
			rNrdcaixa.css({'width':'41px'});		
			rValorpag.css({'width':'41px'});
			rInss.css({'width':'36px'});			
		}
		
	} else {

		rCddopcao.addClass('rotulo').css({'width':'68px'});
		rDtmvtolt.addClass('rotulo').css({'width':'68px'});	
		rCdagenci.addClass('rotulo-linha').css({'width':'61px'});		
		rNrdcaixa.addClass('rotulo-linha').css({'width':'64px'});		
		rValorpag.css({'display':'none'});
		rInss.addClass('rotulo-linha').css({'width':'61px'});			
		
		cCddopcao.css({'width':'456px'});
		cDtmvtolt.addClass('data').css({'width':'75px'});	
		cCdagenci.addClass('inteiro').css({'width':'70px','text-align':'right'}).attr('maxlength','3');		
		cNrdcaixa.addClass('inteiro').css({'width':'70px','text-align':'right'}).attr('maxlength','3');	
		cValorpag.css({'display':'none'});	
		cInss.css({'width':'70px'});		
	
		if ( $.browser.msie ) {
			rCdagenci.css({'width':'64px'});		
			rNrdcaixa.css({'width':'68px'});		
			rInss.css({'width':'64px'});			
		}

	}
	
	cTodosCabecalho.desabilitaCampo();
	cCddopcao.habilitaCampo().focus();
	
	cCddopcao.unbind('change').bind('change', function() { 	
		cddopcao = cCddopcao.val();
		formataCabecalho();
		return false;

	});	
	
	cCddopcao.unbind('keypress').bind('keypress', function(e) { 	
		if (e.keyCode == 9 || e.keyCode == 13 ) {	
			cddopcao = cCddopcao.val();
			formataCabecalho();
			btnOK.click();
			return false;
		}
	});	
	
	cDtmvtolt.unbind('keypress').bind('keypress', function(e) { 	
		if (e.keyCode == 9 || e.keyCode == 13 ) {	
			cCdagenci.focus();
			return false;
		}
	});
	
	cCdagenci.unbind('keypress').bind('keypress', function(e) { 	
		if (e.keyCode == 9 || e.keyCode == 13 ) {	
			cNrdcaixa.focus();
			return false;
		}
	});
	
	cNrdcaixa.unbind('keypress').bind('keypress', function(e) { 	
		if (e.keyCode == 9 || e.keyCode == 13 ) {	
			if (cddopcao == 'C' || cddopcao == 'R' || cddopcao == 'V' ) {
				cInss.focus();
			}
			else
			if (cddopcao == 'D') {
				cValorpag.focus();
			}
			else 
			if  (cddopcao == 'T') {
				btnContinuar();
			}		
			return false;
		}
	});
	
	cValorpag.unbind('keypress').bind('keypress', function(e) { 	
		if (e.keyCode == 9 || e.keyCode == 13 ) {	
			btnContinuar();
			return false;
		}
	});
	
	cInss.unbind('keypress').bind('keypress', function(e) { 	
		if (e.keyCode == 9 || e.keyCode == 13 ) {	
			btnContinuar();
			return false;
		}
	});
		
	// Se clicar no botao OK
	btnOK.unbind('click').bind('click', function() { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( cCddopcao.hasClass('campoTelaSemBorda') ) { return false; }
		
		// Armazena o número da conta na variável global
		cddopcao = cCddopcao.val();
		if ( cddopcao == '' ) { return false; }
		
		cTodosCabecalho.removeClass('campoErro');	
		
		formataCabecalho();
		cTodosCabecalho.habilitaCampo();
		cCddopcao.desabilitaCampo();
		cDtmvtolt.val(dtmvtolt).focus()
		
		if ( cddopcao == 'D' || cddopcao == 'T') { 
			cInss.desabilitaCampo(); 
		} 
		
		if ( cddopcao != 'T' ) {		
			cInss.val('no');
		}
		
		
		return false;
			
	});	

	layoutPadrao();
	return false;	
}

function formataDados() {

	$('fieldset').css({'border':'1px solid #777','padding':'3px 3px 10px 3px'});
	$('#'+frmDados).css({'display':'none'});

	rQtde	   = $('label[for="qtde"]' 	   , '#'+frmDados);
	rValor     = $('label[for="valor"]'	   , '#'+frmDados);
	rQttitrec  = $('label[for="qttitrec"]' , '#'+frmDados);
	rVltitrec  = $('label[for="vltitrec"]' , '#'+frmDados);
	rQttitliq  = $('label[for="qttitliq"]' , '#'+frmDados);
	rVltitliq  = $('label[for="vltitliq"]' , '#'+frmDados);
	rQttitcan  = $('label[for="qttitcan"]' , '#'+frmDados);
	rVltitcan  = $('label[for="vltitcan"]' , '#'+frmDados);
	rQtfatrec  = $('label[for="qtfatrec"]' , '#'+frmDados);
	rVlfatrec  = $('label[for="vlfatrec"]' , '#'+frmDados);
	rQtfatliq  = $('label[for="qtfatliq"]' , '#'+frmDados);
	rVlfatliq  = $('label[for="vlfatliq"]' , '#'+frmDados);
	rQtfatcan  = $('label[for="qtfatcan"]' , '#'+frmDados);
	rVlfatcan  = $('label[for="vlfatcan"]' , '#'+frmDados);
	rQtinss    = $('label[for="qtinss"]'   , '#'+frmDados);
	rVlinss    = $('label[for="vlinss"]'   , '#'+frmDados);
	rQtdinhei  = $('label[for="qtdinhei"]' , '#'+frmDados);
	rVldinhei  = $('label[for="vldinhei"]' , '#'+frmDados);
	rQtcheque  = $('label[for="qtcheque"]' , '#'+frmDados);
	rVlcheque  = $('label[for="vlcheque"]' , '#'+frmDados);	
	rVlrepasse = $('label[for="vlrepasse"]', '#'+frmDados);	

	rQtde.addClass('rotulo').css({'width':'302px'});	
	rValor.addClass('rotulo-linha').css({'width':'144px'});
	
	rQttitrec.addClass('rotulo').css({'width':'190px'});
	rVltitrec.addClass('rotulo-linha').css({'width':'50px'});
	rQttitliq.addClass('rotulo').css({'width':'190px'});	
	rVltitliq.addClass('rotulo-linha').css({'width':'50px'});
	rQttitcan.addClass('rotulo').css({'width':'190px'});
	rVltitcan.addClass('rotulo-linha').css({'width':'50px'});	
	rQtfatrec.addClass('rotulo').css({'width':'190px'});
	rVlfatrec.addClass('rotulo-linha').css({'width':'50px'});	
	rQtfatliq.addClass('rotulo').css({'width':'190px'});
	rVlfatliq.addClass('rotulo-linha').css({'width':'50px'});
	rQtfatcan.addClass('rotulo').css({'width':'190px'});
	rVlfatcan.addClass('rotulo-linha').css({'width':'50px'});
	rQtinss  .addClass('rotulo').css({'width':'190px'});
	rVlinss  .addClass('rotulo-linha').css({'width':'50px'});
	rQtdinhei.addClass('rotulo').css({'width':'190px'});
	rVldinhei.addClass('rotulo-linha').css({'width':'50px'});
	rQtcheque.addClass('rotulo').css({'width':'190px'});
	rVlcheque.addClass('rotulo-linha').css({'width':'50px'});
	rVlrepasse.addClass('rotulo').css({'width':'190px'});
	
	cQttitrec  = $('#qttitrec' , '#'+frmDados);
	cVltitrec  = $('#vltitrec' , '#'+frmDados);
	cQttitliq  = $('#qttitliq' , '#'+frmDados);
	cVltitliq  = $('#vltitliq' , '#'+frmDados);
	cQttitcan  = $('#qttitcan' , '#'+frmDados);
	cVltitcan  = $('#vltitcan' , '#'+frmDados);
	cQtfatrec  = $('#qtfatrec' , '#'+frmDados);
	cVlfatrec  = $('#vlfatrec' , '#'+frmDados);
	cQtfatliq  = $('#qtfatliq' , '#'+frmDados);
	cVlfatliq  = $('#vlfatliq' , '#'+frmDados);
	cQtfatcan  = $('#qtfatcan' , '#'+frmDados);
	cVlfatcan  = $('#vlfatcan' , '#'+frmDados);
	cQtinss    = $('#qtinss'   , '#'+frmDados);
	cVlinss    = $('#vlinss'   , '#'+frmDados);
	cQtdinhei  = $('#qtdinhei' , '#'+frmDados);
	cVldinhei  = $('#vldinhei' , '#'+frmDados);
	cQtcheque  = $('#qtcheque' , '#'+frmDados);
	cVlcheque  = $('#vlcheque' , '#'+frmDados);
	cVlrepasse = $('#vlrepasse', '#'+frmDados);

	cQttitrec.css({'width':'80px','margin-left':'60px','text-align':'right'});
	cVltitrec.css({'width':'80px','text-align':'right'});	                 
	cQttitliq.css({'width':'80px','margin-left':'60px','text-align':'right'});	
	cVltitliq.css({'width':'80px','text-align':'right'});	                 
	cQttitcan.css({'width':'80px','margin-left':'60px','text-align':'right'});	
	cVltitcan.css({'width':'80px','text-align':'right'});	                 
	cQtfatrec.css({'width':'80px','margin-left':'60px','text-align':'right'});	
	cVlfatrec.css({'width':'80px','text-align':'right'});	                 
	cQtfatliq.css({'width':'80px','margin-left':'60px','text-align':'right'});	
	cVlfatliq.css({'width':'80px','text-align':'right'});	                 
	cQtfatcan.css({'width':'80px','margin-left':'60px','text-align':'right'});	
	cVlfatcan.css({'width':'80px','text-align':'right'});	                 
	cQtinss  .css({'width':'80px','margin-left':'60px','text-align':'right'});	
	cVlinss  .css({'width':'80px','text-align':'right'});	                 
	cQtdinhei.css({'width':'80px','margin-left':'60px','text-align':'right'});	
	cVldinhei.css({'width':'80px','text-align':'right'});	                 
	cQtcheque.css({'width':'80px','margin-left':'60px','text-align':'right'});	
	cVlcheque.css({'width':'80px','text-align':'right'});	
	cVlrepasse.css({'width':'80px','margin-left':'197px','text-align':'right'});		

	cTodosDados	= $('input[type="text"],select','#'+frmDados);
	cTodosDados.desabilitaCampo();
	
	layoutPadrao();
	return false;
}

function controlaLayout( flag ) {

	flag = ( typeof flag != 'undefined' ) ? flag : '';

	formataCabecalho();
	formataDados();

	if ( cddopcao == 'C' ) {
		cTodosCabecalho.desabilitaCampo();
		$('#'+frmDados).css({'display':'block'});
		
		if ( flag == 'S' ) {
			showConfirmacao('Deseja listar os LOTES referentes a pesquisa ?','Confirma&ccedil;&atilde;o - Ayllos','Gera_Impressao()','estadoCabecalho();','sim.gif','nao.gif');
			$('#divBotoes').css({'display':'none'});

		} else if ( flag == 'N' ) {
			$('#btSalvar', '#divBotoes').css({'display':'none'});
		}
	
	} else if ( cddopcao == 'D' ) {
		cTodosCabecalho.desabilitaCampo();
		formataTabela();
	
	} else if ( cddopcao == 'R' ) {
		Gera_Impressao();

	} else if ( cddopcao == 'V' ) {
		cTodosCabecalho.desabilitaCampo();
		$('#btSalvar','#divBotoes').css({'display':'none'});
		formataTabela();

	} else if ( cddopcao == 'T' ) {
		$('#inss').limpaFormulario();
		cTodosCabecalho.desabilitaCampo();
		$('#'+frmDados).css({'display':'block'});
		$('#divMensagem','#divTela').css({'display':'none'});
		
		// Se existe mensagem
		if ( flag == 'S' ) {
			$('#divRotina').html( $('#divMensagem','#divTela').html() );
			$('#divMensagem','#divTela').remove();
			formataMensagem();
			
		} else if ( flag == 'N' ) {
			showError('inform',mrsgetor,'Alerta - Ayllos','continuarMensagem();');
		
		}
		
	}

	$('#btVoltar','#divBotoes').focus();
	layoutPadrao();
	return false;
}


// tabela
function formataTabela() {
	
	// tabela
	var divRegistro = $('div.divRegistros', '#'+tabDados);		
	var tabela      = $('table', divRegistro );
	
	$('#'+tabDados).css({'margin-top':'5px'});
	divRegistro.css({'height':'150px','padding-bottom':'2px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '29px';
	arrayLargura[1] = '35px';
	arrayLargura[2] = '161px';
	arrayLargura[3] = '35px';
	arrayLargura[4] = '50px';
	arrayLargura[5] = '60px';
	arrayLargura[6] = '60px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'left';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'right';
	arrayAlinha[6] = 'right';
	arrayAlinha[7] = 'left';
	
	var metodo = '';
	if ( cddopcao == 'D' ) { metodo = 'btnContinuar();'; }
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodo );

	/********************
	 FORMATA COMPLEMENTO	
	*********************/
	// complemento linha 1
	var linha1  = $('ul.complemento', '#linha1').css({'margin-left':'1px','width':'99.5%'});
	
	$('li:eq(0)', linha1).addClass('txtNormalBold').css({'width':'15%','text-align':'right'});
	$('li:eq(1)', linha1).addClass('txtNormal').css({'width':'67%'});
	$('li:eq(2)', linha1).addClass('txtNormal');

	// complemento linha 2
	var linha2  = $('ul.complemento', '#linha2').css({'clear':'both','border-top':'0','width':'99.5%'});
	
	$('li:eq(0)', linha2).addClass('txtNormalBold').css({'width':'15%','text-align':'right'});
	$('li:eq(1)', linha2).addClass('txtNormal').css({'width':'50%'});
	$('li:eq(2)', linha2).addClass('txtNormalBold').css({'width':'13%','text-align':'right'});
	$('li:eq(3)', linha2).addClass('txtNormal');

	// complemento linha 3
	var linha3  = $('ul.complemento', '#linha3').css({'clear':'both','border-top':'0','width':'99.5%'});
	/*
	$('li:eq(0)', linha3).addClass('txtNormalBold').css({'width':'17%','text-align':'right'});
	$('li:eq(1)', linha3).addClass('txtNormal').css({'width':'52%'});
	$('li:eq(2)', linha3).addClass('txtNormalBold').css({'width':'14%','text-align':'right'});
	$('li:eq(3)', linha3).addClass('txtNormal');
	*/
	$('li:eq(0)', linha3).addClass('txtNormalBold').css({'width':'15%','text-align':'right'});
	$('li:eq(1)', linha3).addClass('txtNormal').css({'width':'18%'});
	$('li:eq(2)', linha3).addClass('txtNormalBold').css({'width':'16%','text-align':'right'});
	$('li:eq(3)', linha3).addClass('txtNormal').css({'width':'15%'});
	$('li:eq(4)', linha3).addClass('txtNormalBold').css({'width':'13%','text-align':'right'});

	// complemento linha 4
	var linha4  = $('ul.complemento', '#linha4').css({'clear':'both','border-top':'0','width':'99.5%'});
	
	$('li:eq(0)', linha4).addClass('txtNormalBold').css({'width':'15%','text-align':'right'});
	$('li:eq(1)', linha4).addClass('txtNormal').css({'width':'18%'});
	$('li:eq(2)', linha4).addClass('txtNormalBold').css({'width':'16%','text-align':'right'});//10
	$('li:eq(3)', linha4).addClass('txtNormal').css({'width':'15%'});//22.8
	$('li:eq(4)', linha4).addClass('txtNormalBold').css({'width':'13%','text-align':'right'});//14
/*
	if ( $.browser.msie ) {
		$('li:eq(3)', linha4).addClass('txtNormal').css({'width':'24%'});
	}
*/
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
	
	if ( $('table > tbody > tr:eq(0)', divRegistro).length ) {
		$('table > tbody > tr:eq(0)', divRegistro).click();
	} else {
		$('#btSalvar','#divBotoes').css({'display':'none'});
	}
	
	$('#btVoltar','#divBotoes').focus();
	
	hideMsgAguardo();
	return false;
}

function selecionaTabela(tr) {

	$('#cdbarras','.complemento').html( $('#cdbarras', tr).val() );
	$('#dsdocmto','.complemento').html( $('#dsdocmto', tr).val() );
	$('#dsdocmc7','.complemento').html( $('#dsdocmc7', tr).val() );
	$('#valordoc','.complemento').html( $('#valordoc', tr).val() );
	$('#vldescto','.complemento').html( $('#vldescto', tr).val() );
	$('#valorpag','.complemento').html( $('#valorpag', tr).val() );
	$('#dtvencto','.complemento').html( $('#dtvencto', tr).val() );
	$('#nrautdoc','.complemento').html( $('#nrautdoc', tr).val() );
	$('#flgrgatv','.complemento').html( $('#flgrgatv', tr).val() );
	$('#dstppgto','.complemento').html( $('#dstppgto', tr).val() );
	
	$('#registro','#'+frmCab).val( $('#registro', tr).val() );
	return false;
}


function formataMensagem() {
	
	// tabela
	var divRegistro = $('div.divRegistros', '#tabMensagem');		
	var tabela      = $('table', divRegistro );
	
	$('#tabMensagem').css({'margin-top':'5px'});
	$('#divRotina').css({'width':'440px'});

	divRegistro.css({'height':'150px','width':'440px','padding-bottom':'2px'});
	
	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '50px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'left';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);

	exibeRotina( $('#divRotina') );
	

	showError('inform',mrsgetor,'Alerta - Ayllos','bloqueiaFundo( $(\'#divRotina\') );');
	
	return false;
}

function continuarMensagem() {
	showConfirmacao(msgprint,'Confirma&ccedil;&atilde;o - Ayllos','Gera_Impressao();','estadoCabecalho();','sim.gif','nao.gif');
	return false;
}


// imprimir
function Gera_Impressao() {	
	
	var action = UrlSite + 'telas/concbb/imprimir_dados.php';
	cTodosCabecalho.habilitaCampo();
	
	var callafter = "estadoCabecalho();";
	
	carregaImpressaoAyllos(frmCab,action,callafter);
	
}


// botoes
function btnVoltar() {
	if ( cddopcao == 'C' && cDtmvtolt.hasClass('campoTelaSemBorda') && cCddopcao.hasClass('campoTelaSemBorda') ) {
		estadoCabecalho();
	} else {
		estadoInicial();
	}	
	return false;
}

function btnContinuar() {

	if ( divError.css('display') == 'block' ) { return false; }		
	
	if ( cCddopcao.hasClass('campo') ) {
		btnOK.click();
	
	} else if ( cddopcao == 'D' && $('#'+tabDados).css('display') == 'block' ) {
		showConfirmacao('Deseja realmente selecionar este Docto ?','Confirma&ccedil;&atilde;o - Ayllos','Gera_Impressao()','','sim.gif','nao.gif');
	
	} else if ( cddopcao == 'T' ) {
		showConfirmacao('O arquivo foi recebido pelo GERENCIADOR FINANCEIRO ?','Confirma&ccedil;&atilde;o - Ayllos','controlaOperacao( 1, 30, \'yes\' );','controlaOperacao( 1, 30, \'no\' );','sim.gif','nao.gif');
	
	} else if ( cddopcao == 'R' ) {
		Gera_Impressao();
	} else {
		controlaOperacao( 1, 30 );
	}
	
	return false;
}

function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onClick="btnVoltar(); return false;">Voltar</a>');	
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onClick="btnContinuar(); return false;" style="margin-left:5px"> ' + botao + '</a>');

	return false;
}
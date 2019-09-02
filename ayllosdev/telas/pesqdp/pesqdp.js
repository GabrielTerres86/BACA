/*!
 * FONTE        : pesqdp.js
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 11/01/2013
 * OBJETIVO     : Biblioteca de funções da tela PESQDP
 * --------------
 * ALTERAÇÕES   : 16/06/2014 - Adicionado campo "Age.Dst." na tabela de cheques. (Reinert)
 *				  27/06/2014 - Incluido opção "D". (Reinert)
 *				  14/08/2015 - Removidos todos os campos da tela menos os campos
 *							   Data do Deposito e Valor do cheque. Adicionado novos campos
 *							   para filtro, numero de conta e numero de cheque, conforme
 *							   solicitado na melhoria 300189 (Kelvin)	
 *                15/02/2017 - Zerar os tabindex quando busca um cheque e clica no botão
                               voltar. Andrey Formigari (Mouts) SD 612621.
 * --------------
 */

 var nometela;

//Formulários e Tabela
var frmCab   		= 'frmCab';
var divCheque   	= 'divCheque';
var frmLocal   		= 'frmLocal';
var divTabela;
var dsdircop;


var dtmvtola,   tipocons,   vlcheque,   nrcampo1,   nrcampo2,   nrcampo3,   dtmvtini,   dtmvtfim,
    cdbccxlt, 	dtmvtol2, 	tpdsaida, 	nrregist, 	nriniseq, 	nrdconta,	nrcheque,   nmprimtl,   
	cdagenci,   nmextage,   tpdsaida,   dsiduser,	rCddopcao, 	cCddopcao,  btnOK,      cddopcao,   
	dsdocmc7,   dtdevolu,	cTodosCabecalho, cTodosConsulta, cTodosCheque, cTodosDevolvidos;

var rDtmvtola, rTipocons, rVlcheque, rNrcampo1, rNrcampo2, rNrcampo3,
    cDtmvtola, cTipocons, cVlcheque, cNrcampo1, cNrcampo2, cNrcampo3,

    rDtmvtini, rDtmvtfim, rCdbccxlt, rCdagechq, rNrdconta, rCdbccxlt, rDsdocmc7,
    rNrcheque, rNrctachq, rVlcheque, rCdcmpchq, rDsbccxlt, rNmprimtl, rCdagenci, rNmextage,
    rTpdsaida,
    
    cDtmvtini, cDtmvtfim, cCdbccxlt, cCdagechq, cNrdconta, cNmprimtl, cCdagenci, cNmextage,
	cDsdocmc7, cNrcheque, cNrctachq, cVlcheque, cCdcmpchq, cDsbccxlt, cTpdsaida,
	
	cDtdevolu, rDtdevolu;	
	
$(document).ready(function() {

	divTabela		= $('#divTabela');
	estadoInicial();
	nrregist = 20;

	return false;

});

function carregaDados(idlclreq){

    cddopcao = ( typeof cddopcao == 'undefined' ) ? '' : cddopcao ;
	tipocons = ( typeof tipocons == 'undefined' ) ? '' : tipocons ;
	cdbccxlt = ( typeof cdbccxlt == 'undefined' ) ? '' : cdbccxlt ;
	
	rhdnrcheque = $('#hdnrcheque','#frmConsulta');
	rhdnrdconta = $('#hdnrdconta','#frmConsulta');
	rnrcheque = $('#nrcheque','#frmConsulta');
	rnrdconta = $('#nrdconta','#frmConsulta');
	
	rhdnrcheque.val(idlclreq == 1 ? rnrcheque.val() : rhdnrcheque.val()); 
    rhdnrdconta.val(idlclreq == 1 ? rnrdconta.val() : rhdnrdconta.val());
	
	cddopcao = $('#cddopcao','#frmCab').val();

	dtmvtola = $('#dtmvtola','#frmConsulta').val();
	tipocons = $('#tipocons','#frmConsulta').val();
	vlcheque = $('#vlcheque','#frmConsulta').val();

	vlcheque = number_format(parseFloat(vlcheque.replace(/[.R$ ]*/g,'').replace(',','.')),2,',','');

	nrcampo1 = $('#nrcampo1','#frmConsulta').val();
	nrcampo2 = $('#nrcampo2','#frmConsulta').val();
	nrcampo3 = $('#nrcampo3','#frmConsulta').val();
	nrdconta = rhdnrdconta.val();
	nrdconta = nrdconta.replace(/[-. ]*/g,'');
	nrcheque = rhdnrcheque.val();
	nmprimtl = $('#nmprimtl','#frmConsulta').val();
	cdagenci = $('#cdagenci','#frmConsulta').val();
	nmextage = $('#nmextage','#frmConsulta').val();

	dsdocmc7 = '<' + nrcampo1 + '<' + nrcampo2 + '>' + nrcampo3 + ':';

	dtmvtini = $('#dtmvtini','#frmRelatorio').val();
	dtmvtfim = $('#dtmvtfim','#frmRelatorio').val();
	cdbccxlt = $('#cdbccxlt','#frmRelatorio').val();
	tpdsaida = $('#tpdsaida','#frmRelatorio').val();

	dtmvtola = ( dtmvtola == '' ) ? '?' : dtmvtola;
	dtmvtini = ( dtmvtini == '' ) ? '?' : dtmvtini;
	dtmvtfim = ( dtmvtfim == '' ) ? '?' : dtmvtfim;
	
	dtdevolu = $('#dtdevolu','#frmDevolvidos').val();
	
	dtdevolu = ( dtdevolu == '' ) ? '?' : dtdevolu;

	return false;
}

// inicio
function estadoInicial() {

	$('#frmCab').fadeTo(0,0.1);

	$('#divTabela').html('');

	trocaBotao('Prosseguir');

	formataCabecalho();

	removeOpacidade('frmCab');

	$('#dtmvtola','#frmConsulta').val('');
	$('#vlcheque','#frmConsulta').val('');
	$('#nrcampo1','#frmConsulta').val('');
	$('#nrcampo2','#frmConsulta').val('');
	$('#nrcampo3','#frmConsulta').val('');
	$('#nrdconta','#frmConsulta').val('');
	$('#nmprimtl','#frmConsulta').val('');
	$('#cdagenci','#frmConsulta').val('');
	$('#nmextage','#frmConsulta').val('');
	$('#nrcheque','#frmConsulta').val('');

	$('#dtmvtini','#frmRelatorio').val('');
	$('#dtmvtfim','#frmRelatorio').val('');
	$('#cdbccxlt','#frmRelatorio').val('');
	$('#tpdsaida','#frmRelatorio').val('');
	
	$('#dtdevolu','#frmDevolvidos').val('');

	return false;

}

// formata
function formataCabecalho() {

	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);

	btnOK				= $('#btnOK','#'+frmCab);
	btnProsseguir		= $('#btSalvar','#divBotoes');

	//Cabecalho

	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab);
	cCddopcao			= $('#cddopcao','#'+frmCab);

	rCddopcao.addClass('rotulo').css({'width':'235px'});
	cCddopcao.css({'width':'120px'});

	cTodosCabecalho.habilitaCampo();

	cCddopcao.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }

		// Se é a tecla ENTER
		if ( e.keyCode == 13) {

			btnContinuar();
			return false;
		}

	});

	//Consulta

	cTodosConsulta		= $('input[type="text"],select','#frmConsulta');

	rDtmvtola = $('label[for="dtmvtola"]','#frmConsulta');
	rTipocons = $('label[for="tipocons"]','#frmConsulta');
	rVlcheque = $('label[for="vlcheque"]','#frmConsulta');
	rNrcampo1 = $('label[for="nrcampo1"]','#frmConsulta');
	rNrcampo2 = $('label[for="nrcampo2"]','#frmConsulta');
	rNrcampo3 = $('label[for="nrcampo3"]','#frmConsulta');
	rNrdconta = $('label[for="nrdconta"]','#frmConsulta');
	rNrcheque = $('label[for="nrcheque"]','#frmConsulta');
	rNmprimtl = $('label[for="nmprimtl"]','#frmConsulta');
	rCdagenci = $('label[for="cdagenci"]','#frmConsulta');
	rNmextage = $('label[for="nmextage"]','#frmConsulta');


	cDtmvtola = $('#dtmvtola','#frmConsulta');
	cTipocons = $('#tipocons','#frmConsulta');
	cVlcheque = $('#vlcheque','#frmConsulta');
	cNrcampo1 = $('#nrcampo1','#frmConsulta');
	cNrcampo2 = $('#nrcampo2','#frmConsulta');
	cNrcampo3 = $('#nrcampo3','#frmConsulta');
	cNrdconta = $('#nrdconta','#frmConsulta');
	cNrcheque = $('#nrcheque','#frmConsulta');
	cNmprimtl = $('#nmprimtl','#frmConsulta');
	cCdagenci = $('#cdagenci','#frmConsulta');
	cNmextage = $('#nmextage','#frmConsulta');


	rCddopcao.addClass('rotulo').css({'width':'235px'});
	cCddopcao.css({'width':'120px'});

	rDtmvtola.addClass('rotulo').css({'width':'120px'});
	rTipocons.css({'width':'93px'});
	rVlcheque.addClass('rotulo').css({'width':'120px'});
	rNrcampo1.addClass('rotulo-linha');
	rNrcampo2.addClass('rotulo-linha');
	rNrcampo3.addClass('rotulo-linha');
	rNrdconta.css({'width':'120px'});
	rNrcheque.css({'width':'120px'});
	rNmprimtl.css({'width':'73px'});
	rCdagenci.css({'width':'120px'});
	rNmextage.css({'width':'73px'});

	cDtmvtola.css({'width':'80px'}).addClass('data');
	cTipocons.css({'width':'75px'});
	cVlcheque.css({'width':'120px'}).addClass('moeda');
	cNrcampo1.css({'width':'75px'});
	cNrcampo2.css({'width':'85px'});
	cNrcampo3.css({'width':'95px'});
	cNrdconta.addClass('conta').css({'width':'100px'});
	cNrcheque.addClass('inteiro').css({'width':'100px'});
	cNmprimtl.css({'width':'295px'});
	cCdagenci.css({'width':'100px'});
	cNmextage.css({'width':'295px'});

	cTodosConsulta.habilitaCampo();

	/*tipoConsulta();*/

	cTipocons.unbind('change').bind('change', function() {

		if ( divError.css('display') == 'block' ) { return false; }

		/*tipoConsulta();

		return false;*/

	});

	cDtmvtola.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }

		// Se é a tecla ENTER
		if ( e.keyCode == 13) {

			cTipocons.focus();
			return false;
		}

	});

	cTipocons.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }

		// Se é a tecla ENTER
		if ( e.keyCode == 13) {

			if( cTipocons.val() == 'V' ){
				cVlcheque.focus();
			}else{
				cNrcampo1.focus();
			}
			return false;
		}

	});

	cNrcampo1.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }

		// Se é a tecla ENTER
		if ( e.keyCode == 13) {

			cNrcampo2.focus();

			return false;
		}

	});

	cNrcampo2.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }

		// Se é a tecla ENTER
		if ( e.keyCode == 13) {

			cNrcampo3.focus();

			return false;
		}

	});

	cNrcampo3.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }

		// Se é a tecla ENTER
		if ( e.keyCode == 13) {

			btnContinuar();

			return false;
		}

	});

	cVlcheque.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }

		// Se é a tecla ENTER
		if ( e.keyCode == 13) {

			btnContinuar();

			return false;
		}

	});

	//Relatorio

	cTodosRelatorio = $('input[type="text"],select','#frmRelatorio');

	rDtmvtini = $('label[for="dtmvtini"]','#frmRelatorio');
	rDtmvtfim = $('label[for="dtmvtfim"]','#frmRelatorio');
	rCdbccxlt = $('label[for="cdbccxlt"]','#frmRelatorio');
	rTpdsaida = $('label[for="tpdsaida"]','#frmRelatorio');

	cDtmvtini = $('#dtmvtini','#frmRelatorio');
	cDtmvtfim = $('#dtmvtfim','#frmRelatorio');
	cCdbccxlt = $('#cdbccxlt','#frmRelatorio');
	cTpdsaida = $('#tpdsaida','#frmRelatorio');

	rDtmvtini.addClass('rotulo').css({'width':'85px'});
	rDtmvtfim.css({'width':'65px'});
	rCdbccxlt.css({'width':'55px'});
	rTpdsaida.css({'width':'65px'});

	cDtmvtini.css({'width':'80px'}).addClass('data');
	cDtmvtfim.css({'width':'80px'}).addClass('data');
	cTpdsaida.css({'width':'50px'});

	cTodosRelatorio.habilitaCampo();

	cDtmvtini.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }

		// Se é a tecla ENTER
		if ( e.keyCode == 13) {

			cDtmvtfim.focus();

			return false;
		}

	});

	cDtmvtfim.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }

		// Se é a tecla ENTER
		if ( e.keyCode == 13) {

			cCdbccxlt.focus();

			return false;
		}

	});

	cCdbccxlt.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }

		// Se é a tecla ENTER
		if ( e.keyCode == 13) {

			cTpdsaida.focus();

			return false;
		}

	});

	cTpdsaida.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }

		// Se é a tecla ENTER
		if ( e.keyCode == 13) {

			btnContinuar();

			return false;
		}

	});
	
	// Devolvidos
	
	cTodosDevolvidos = $('input[type="text"],select','#frmDevolvidos');
	
	rDtdevolu = $('label[for="dtdevolu"]','#frmDevolvidos');
	cDtdevolu = $('#dtdevolu','#frmDevolvidos');	
	rDtdevolu.addClass('rotulo').css({'width':'120px'});
	cDtdevolu.css({'width':'80px'}).addClass('data');
	
	cTodosDevolvidos.habilitaCampo();
	
	cDtdevolu.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }

		// Se é a tecla ENTER
		if ( e.keyCode == 13) {

			btnContinuar();

			return false;
		}

	});
	
	btnOK.unbind('click').bind('click', function() {

		if ( divError.css('display') == 'block' ) { return false; }
		
		cTodosCabecalho.removeClass('campoErro');
		cCddopcao.desabilitaCampo();
				
		controlaLayout();

		return false;

	});
	
	$('#frmConsulta').css('display','none');
	$('#frmRelatorio').css('display','none');
	$('#frmDevolvidos').css('display','none');

	highlightObjFocus( $('#frmCab') );
	highlightObjFocus( $('#frmConsulta') );
	highlightObjFocus( $('#frmRelatorio') );
	highlightObjFocus( $('#frmDevolvidos') );

	layoutPadrao();

	cCddopcao.focus();

	return false;
}

/*function tipoConsulta(){

	if( cTipocons.val() == 'V' ){

		cVlcheque.habilitaCampo();
		cNrcampo1.desabilitaCampo();
		cNrcampo2.desabilitaCampo();
		cNrcampo3.desabilitaCampo();
		cNrdconta.desabilitaCampo();
		cNmprimtl.desabilitaCampo();
		cCdagenci.desabilitaCampo();
		cNmextage.desabilitaCampo();
		cVlcheque.focus();

	}else{

		cVlcheque.desabilitaCampo();
		cNrcampo1.habilitaCampo();
		cNrcampo2.habilitaCampo();
		cNrcampo3.habilitaCampo();
		cNrdconta.desabilitaCampo();
		cNmprimtl.desabilitaCampo();
		cCdagenci.desabilitaCampo();
		cNmextage.desabilitaCampo();
		cNrcampo1.focus();


	}

    $('#vlcheque','#frmConsulta').val('');
	$('#nrcampo1','#frmConsulta').val('');
	$('#nrcampo2','#frmConsulta').val('');
	$('#nrcampo3','#frmConsulta').val('');
	$('#nrdconta','#frmConsulta').val('');
	$('#nmprimtl','#frmConsulta').val('');
	$('#cdagenci','#frmConsulta').val('');
	$('#nmextage','#frmConsulta').val('');

	return false;

}*/

function controlaLayout() {

	if( cCddopcao.val() == "C" ){

		$('#frmConsulta').css('display','block');
		cDtmvtola.focus();

	}else if(cCddopcao.val() == "D" ){
	
		$('#frmDevolvidos').css('display','block');
		cDtdevolu.focus();
		
	}else{

		$('#frmRelatorio').css('display','block');
		cDtmvtini.focus();

	}
	return false;
}

// imprimir .PDF
function Gera_Impressao(frmImp) {

	var action = UrlSite + 'telas/'+nometela+'/imprimir_dados.php';			
		
	$('#cddopcao','#' + frmImp).remove();	
	
	// Insiro input do tipo hidden do formulário para enviá-los posteriormente
	$('#' + frmImp).append('<input type="hidden" id="cddopcao" name="cddopcao" />');	
	
	// Agora insiro os devidos valores nos inputs criados
	$('#cddopcao','#' + frmImp).val( cCddopcao.val() );
	
	carregaImpressaoAyllos(frmImp,action,"estadoInicial();");
	
	return false;

}

// imprimir .TXT
function Gera_ImpressaoTXT() {

	//showMsgAguardo('Aguarde, Gerando Arquivo...');

	carregaDados(1);

	$.ajax({
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/'+nometela+'/imprimir_dados.php',
		data    :
				{ cddopcao	: cddopcao,
				  dtmvtola  : dtmvtola,
				  tipocons  : tipocons,
				  vlcheque  : vlcheque,
				  dsdocmc7  : dsdocmc7,
				  nrcampo1  : nrcampo1,
				  nrcampo2  : nrcampo2,
				  nrcampo3	: nrcampo3,
                  nrdconta  : nrdconta,
				  nmprimtl  : nmprimtl,
                  cdagenci  : cdagenci,
                  nmextage  : nmextage,
				  dtmvtini  : dtmvtini,
				  dtmvtfim  : dtmvtfim,
				  cdbccxlt  : cdbccxlt,
				  nrregist  : nrregist,
				  nriniseq  : nriniseq,
				  tpdsaida  : tpdsaida,
				  dsiduser  : dsiduser,
				  redirect: 'script_ajax'

				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#tpChequ1\',\'#frmTipoCheque\').focus();');
				},
		success : function(response) {
					hideMsgAguardo();

					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							fechaRotina($('#divRotina'));
							return false;
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#tpChequ1\',\'#frmTipoCheque\').focus();');
						}
					} else {
						try {
							eval( response );
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#tpChequ1\',\'#frmTipoCheque\').focus();');
						}
					}

				}
	});

	return false;
}

// botoes
function btnVoltar() {
	estadoInicial();
    zerarTabIndex();
	return false;
}

function btnContinuar() {

	if ( divError.css('display') == 'block' ) { return false; }

	if ( cCddopcao.hasClass('campo') ) {
		btnOK.click();

	} else if ( cCddopcao.val() == "C"  ) {
		buscaCheque(1,1);	
	}else if ( cCddopcao.val() == "D"  ) {
		Gera_Impressao('frmDevolvidos');		
	}else if ( cTpdsaida.val() == "P"  ) {
		Gera_Impressao('frmRelatorio');
	} else if ( cTpdsaida.val() == "T"  ) {
		buscaLocal();
	}

	return false;

}

function trocaBotao( botao ) {

	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onClick="btnVoltar(); return false;" >Voltar</a>&nbsp;');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onClick="btnContinuar(); return false;" >'+botao+'</a>&nbsp;');

	return false;
}

function buscaCheque(nriniseq, idlclreq) {
	
	showMsgAguardo('Aguarde, buscando Cheque...');
	
	carregaDados(idlclreq);
	
	$.ajax({
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/'+nometela+'/busca_cheque.php',
		data    :
				{ cddopcao	: cddopcao,
				  dtmvtola  : dtmvtola,
				  tipocons  : tipocons,
				  vlcheque  : vlcheque,
				  dsdocmc7  : dsdocmc7,
				  nrcampo1  : nrcampo1,
				  nrcampo2  : nrcampo2,
				  nrcampo3	: nrcampo3,
                  nrdconta  : nrdconta,
				  nrcheque  : nrcheque,
				  nmprimtl  : nmprimtl,
                  cdagenci  : cdagenci,
                  nmextage  : nmextage,
				  dtmvtini  : dtmvtini,
				  dtmvtfim  : dtmvtfim,
				  cdbccxlt  : cdbccxlt,
				  nrregist  : nrregist,
				  nriniseq  : nriniseq,
				  tpdsaida  : tpdsaida,
				  redirect: 'script_ajax'

				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#tpChequ1\',\'#frmTipoCheque\').focus();');
				},
		success : function(response) {
					hideMsgAguardo();

					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							$('#divTabela').html(response);
							formataTabela();
							return false;
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#tpChequ1\',\'#frmTipoCheque\').focus();');
						}
					} else {
						try {
							eval( response );
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#tpChequ1\',\'#frmTipoCheque\').focus();');
						}
					}

				}
	});
}

function formataTabela() {

	var divRegistro = $('div.divRegistros', divTabela );

	var tabela      = $('table', divRegistro );

	selecionaCheque($('table > tbody > tr:eq(0)', divRegistro));

	divRegistro.css({'height':'207px','border-bottom':'1px dotted #777','padding-bottom':'2px'});
	divTabela.css({'padding-top':'10px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '220px';
	arrayLargura[1] = '30px';
	arrayLargura[2] = '50px';
	arrayLargura[3] = '70px';
	arrayLargura[4] = '60px';

	var arrayAlinha = new Array();
	if ( $.browser.msie ) {
		arrayAlinha[1] = 'left';
		arrayAlinha[2] = 'right';
		arrayAlinha[3] = 'right';
		arrayAlinha[4] = 'right';
		arrayAlinha[5] = 'right';
		arrayAlinha[6] = 'right';
	}else{
		arrayAlinha[0] = 'left';
		arrayAlinha[1] = 'right';
		arrayAlinha[2] = 'right';
		arrayAlinha[3] = 'right';
		arrayAlinha[4] = 'right';
		arrayAlinha[5] = 'right';
	}
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, 'trocaVisao();' );

	$('table > tbody > tr', divRegistro).focus( function() {
		selecionaCheque($(this));

	});

	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		selecionaCheque($(this));

	});

	divTabela.css({'display':'block'});

	cTodosConsulta.desabilitaCampo();

	formataDetalhe();

	return false;
}

function formataDetalhe(){

	cTodosCheque = $('input[type="text"],select','#divCheque');

	rCdagechq = $('label[for="cdagechq"]','#divCheque');
	rCdbccxlt = $('label[for="cdbccxlt"]','#divCheque');
	rDsdocmc7 = $('label[for="dsdocmc7"]','#divCheque');
	rNrcheque = $('label[for="nrcheque"]','#divCheque');
	rNrctachq = $('label[for="nrctachq"]','#divCheque');
	rVlcheque = $('label[for="vlcheque"]','#divCheque');
	rCdcmpchq = $('label[for="cdcmpchq"]','#divCheque');
	rDsbccxlt = $('label[for="dsbccxlt"]','#divCheque');

	cCdagechq = $('#cdagechq','#divCheque');
	cCdbccxlt = $('#cdbccxlt','#divCheque');
	cDsdocmc7 = $('#dsdocmc7','#divCheque');
	cNrcheque = $('#nrcheque','#divCheque');
	cNrctachq = $('#nrctachq','#divCheque');
	cVlcheque = $('#vlcheque','#divCheque');
	cCdcmpchq = $('#cdcmpchq','#divCheque');
	cDsbccxlt = $('#dsbccxlt','#divCheque');

	rCdcmpchq.addClass('rotulo').css({'width':'120px'});
	rCdbccxlt.css({'width':'60px'});
	rCdagechq.css({'width':'70px'});
	rNrcheque.css({'width':'74px'});
	rNrctachq.addClass('rotulo').css({'width':'120px'});
	rVlcheque.css({'width':'205px'});
	rDsdocmc7.addClass('rotulo').css({'width':'120px'});
	rDsbccxlt.css({'width':'70px'});

	cCdcmpchq.css({'width':'40px'});
	cCdbccxlt.css({'width':'40px'});
	cCdagechq.css({'width':'50px'});
	cNrcheque.css({'width':'60px'}).addClass('cheque');
	cNrctachq.css({'width':'95px'}).addClass('conta');
	cVlcheque.css({'width':'100px'}).addClass('moeda');
	cDsdocmc7.css({'width':'250px'});
	cDsbccxlt.css({'width':'80px'});

	cTodosCheque.desabilitaCampo();

	layoutPadrao();

	return false;
}

function selecionaCheque(tr){

	$('#cdagechq','#'+divCheque ).val( $('#cdagechq', tr ).val() );
	$('#cdbccxlt','#'+divCheque ).val( $('#cdbccxlt', tr ).val() );
	$('#dsdocmc7','#'+divCheque ).val( $('#dsdocmc7', tr ).val() );
	$('#nrcheque','#'+divCheque ).val( $('#nrcheque', tr ).val() );
	$('#nrctachq','#'+divCheque ).val( $('#nrctachq', tr ).val() );
	$('#vlcheque','#'+divCheque ).val( $('#vlcheque', tr ).val() );
	$('#cdcmpchq','#'+divCheque ).val( $('#cdcmpchq', tr ).val() );
	$('#dsbccxlt','#'+divCheque ).val( $('#dsbccxlt', tr ).val() );
	$('#nrdconta','#frmConsulta').val($('#nrdconta', tr ).val() );
	$('#nmprimtl','#frmConsulta').val($('#nmprimtl', tr ).val() );
	$('#cdagenci','#frmConsulta').val($('#cdagenci', tr ).val() );
	$('#nmextage','#frmConsulta').val($('#nmextage', tr ).val() );
	$('#nrcheque','#frmConsulta').val($('#nrcheque', tr ).val() );


	return false;
}

function buscaLocal() {

	hideMsgAguardo();

	showMsgAguardo('Aguarde, abrindo ...');

	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/pesqdp/arquivo.php',
		data: {
			dsdircop: dsdircop,
			redirect: 'script_ajax'
			},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {

			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divRotina').html(response);
					hideMsgAguardo();
					exibeRotina($('#divRotina'));
					formataArquivo();
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

function formataArquivo(){

	cNmarquiv = $('#nmarquiv','#'+frmLocal);

	rNmarquiv  = $('label[for="nmarquiv"]','#'+frmLocal);
	rNmarquiva = $('label[for="nmarquiva"]','#'+frmLocal);

	rNmarquiv.addClass('rotulo').css({'width':'180px'});
	rNmarquiva.addClass('rotulo-linha').css({'width':'30px'});

	cNmarquiv.css({'width':'180px'});

	cNmarquiv.habilitaCampo();

	return false;
}

function validaArquivo(){

	if ( cNmarquiv.val() == '' ){
		showError('error','Arquivo n&atilde;o informado.','Alerta - Ayllos','bloqueiaFundo($(\'#divRotina\'));cNmarquiv.focus();'); return false;
	}

	dsiduser = cNmarquiv.val();
	Gera_ImpressaoTXT();

	return false;
}

function zerarTabIndex() {
    $('.formulario input').removeAttr('tabindex');
}
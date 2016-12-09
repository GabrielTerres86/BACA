/*!
 * FONTE        : valpro.js
 * CRIAÇÃO      : Rogerius Militão (DB1) 
 * DATA CRIAÇÃO : 26/12/2011
 * OBJETIVO     : Biblioteca de funções da tela VALPRO
 * --------------
 * ALTERAÇÕES   : 18/12/2012 - Inclusao efeito highlightObjFocus() (Daniel).
 *          
 *                06/10/2015 - Incluindo validacao de protocolo MD5 - Sicredi
 *                             (Andre Santos - SUPERO)
 * --------------
 */

//Formulários e Tabela
var frmCab   		= 'frmCab';

var cddopcao		= 'C';

var cNrdconta, cNrdocmto , cNrseqaut, cDtmvtolt, cHorproto, cMinproto, cSegproto, cVlprotoc, cDsprotoc, cFlvalgps, cTodos;


$(document).ready(function() {
	estadoInicial();
});

// inicio
function estadoInicial() {

	$("#frmCab").css('display','block');
	$("#divBotoes").css('display','block');

	$('#divTela').fadeTo(0,0.1);

	// retira as mensagens	
	hideMsgAguardo();

	// formailzia	
	formataCabecalho();
	formataMsgAjuda();

	// inicializa com a frase de ajuda para o campo cddopcao
	$('span:eq(0)', '#divMsgAjuda').html( cNrdconta.attr('alt') );
	
	//
	cTodos.limpaFormulario().removeClass('campoErro');	
	cFlvalgps.val(0);
	
	highlightObjFocus( $('#frmCab') );
	
	cNrdconta.focus();
	
	removeOpacidade('divTela');
}

//
function controlaPesquisas() {

	/*---------------------*/
	/*  CONTROLE CONTA/DV  */
	/*---------------------*/
	var linkConta = $('a:eq(0)','#'+ frmCab );

	if ( linkConta.prev().hasClass('campoTelaSemBorda') ) {		
		linkConta.addClass('lupa').css('cursor','auto').unbind('click').bind('click', function() { return false; });
	} else {
		linkConta.css('cursor','pointer').unbind('click').bind('click', function() {			
			mostraPesquisaAssociado('nrdconta', frmCab );
		});
	}
	
	return false;
}

// cabecalho
function formataCabecalho() {
	
	// Label
	rNrdconta = $('label[for="nrdconta"]', '#'+frmCab);
	rNrdocmto = $('label[for="nrdocmto"]', '#'+frmCab);
	rNrseqaut = $('label[for="nrseqaut"]', '#'+frmCab);
	rDtmvtolt = $('label[for="dtmvtolt"]', '#'+frmCab);
	rHorproto = $('label[for="horproto"]', '#'+frmCab);
	rMinproto = $('label[for="minproto"]', '#'+frmCab);
	rSegproto = $('label[for="segproto"]', '#'+frmCab);
	rVlprotoc = $('label[for="vlprotoc"]', '#'+frmCab);
	rDsprotoc = $('label[for="dsprotoc"]', '#'+frmCab);
	rFlvalgps = $('label[for="flvalgps"]', '#'+frmCab);

	rNrdconta.css({'width':'60px'}).addClass('rotulo');
	rNrdocmto.css({'width':'92px'}).addClass('rotulo-linha');
	rNrseqaut.css({'width':'113px'}).addClass('rotulo-linha');
	rDtmvtolt.css({'width':'60px'}).addClass('rotulo');
	rHorproto.css({'width':'109px'}).addClass('rotulo-linha');
	rMinproto.css({'width':'5px'}).addClass('rotulo-linha');
	rSegproto.css({'width':'5px'}).addClass('rotulo-linha');
	rVlprotoc.css({'width':'113px'}).addClass('rotulo-linha');
	rDsprotoc.css({'width':'60px'}).addClass('rotulo');
	rFlvalgps.css({'width':'260px'}).addClass('rotulo');
	
	// Input
	cNrdconta = $('#nrdconta', '#'+frmCab);
	cNrdocmto = $('#nrdocmto', '#'+frmCab);
	cNrseqaut = $('#nrseqaut', '#'+frmCab);
	cDtmvtolt = $('#dtmvtolt', '#'+frmCab);
	cHorproto = $('#horproto', '#'+frmCab);
	cMinproto = $('#minproto', '#'+frmCab);
	cSegproto = $('#segproto', '#'+frmCab);
	cVlprotoc = $('#vlprotoc', '#'+frmCab);
	cDsprotoc = $('#dsprotoc', '#'+frmCab);
	cFlvalgps = $('#flvalgps', '#'+frmCab);
	
	cNrdconta.css({'width':'75px'}).addClass('conta pesquisa');
	cNrdocmto.css({'width':'100px','text-align':'right'}).setMask('INTEGER','zzz.zzz.zzz.zzz','.','');
	cNrseqaut.css({'width':'100px','text-align':'right'}).setMask('INTEGER','zz.zzz.zzz','.','');
	cDtmvtolt.css({'width':'75px'}).addClass('data');
	cHorproto.css({'width':'26px'}).addClass('inteiro').attr('maxlength','2');
	cMinproto.css({'width':'26px'}).addClass('inteiro').attr('maxlength','2');
	cSegproto.css({'width':'26px'}).addClass('inteiro').attr('maxlength','2');
	cVlprotoc.css({'width':'100px'}).addClass('monetario');
	cDsprotoc.css({'width':'509px'}).attr('maxlength', '40');
	cFlvalgps.css({'width':'95px'}).addClass('campo');
	
	// Outros	
	cTodos 	  = $('input, select', '#'+frmCab); 
	cTodos.habilitaCampo();
	
	// IE
	if ( $.browser.msie ) {
		rNrdocmto.css({'width':'95px'});
		rNrseqaut.css({'width':'115px'});
		rHorproto.css({'width':'112px'});
		cMinproto.css({'width':'28px'});
		cSegproto.css({'width':'28px'});
		rVlprotoc.css({'width':'115px'});
		cDsprotoc.css({'width':'508px'});
		cFlvalgps.css({'width':'95px'});
	}	

	cNrdconta.unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) cNrdocmto.focus();	});	
	cNrdocmto.unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) cNrseqaut.focus();	});	
	cNrseqaut.unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) cDtmvtolt.focus(); 	});	
	cDtmvtolt.unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) cHorproto.focus(); 	});	
	cHorproto.unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) cMinproto.focus(); 	});	
	cMinproto.unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) cSegproto.focus(); 	});	
	cSegproto.unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) cVlprotoc.focus(); 	});	
	cVlprotoc.unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) cDsprotoc.focus(); 	});
	cDsprotoc.unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) cFlvalgps.focus(); 	});
	cFlvalgps.unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) manterRotina();	 	});
	
	
	layoutPadrao();
	controlaPesquisas();
	return false;	
}

//
function manterRotina( operacao ) {
		
	hideMsgAguardo();		
	cTodos.removeClass('campoErro');	
	
	var mensagem = 'Aguarde, validando dados ...';
	var nrdconta = normalizaNumero( cNrdconta.val() );	
	var nrdocmto = normalizaNumero( cNrdocmto.val() );	
	var nrseqaut = normalizaNumero( cNrseqaut.val() );	
	var dtmvtolx = cDtmvtolt.val();	
	var horproto = normalizaNumero( cHorproto.val() );	
	var minproto = normalizaNumero( cMinproto.val() );	
	var segproto = normalizaNumero( cSegproto.val() );	
	var vlprotoc = cVlprotoc.val();	
	var dsprotoc = cDsprotoc.val();
	var flvalgps = cFlvalgps.val();

	showMsgAguardo( mensagem );	
	
	$.ajax({		
			type  : 'POST',
			url   : UrlSite + 'telas/valpro/manter_rotina.php', 		
			data: {
				nrdconta	: nrdconta,
				nrdocmto	: nrdocmto,
				nrseqaut	: nrseqaut,
				dtmvtolx	: dtmvtolx,
				horproto	: horproto,	
				minproto    : minproto,
				segproto    : segproto,
				vlprotoc    : vlprotoc,
				dsprotoc    : dsprotoc,
				flvalgps    : flvalgps,
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


// ajuda
function formataMsgAjuda() {	
	var divMensagem = $('#divMsgAjuda');
	divMensagem.css({'border':'1px solid #ddd','background-color':'#eee','padding':'2px','height':'20px','margin':'7px 0px'});
	
	var spanMensagem = $('span','#divMsgAjuda');
	spanMensagem.css({'text-align':'left','font-size':'11px','float':'left','padding':'3px'});

	var botoesMensagem = $('#divBotoes','#divMsgAjuda');
	botoesMensagem.css({'float':'right','padding':'0 0 0 2px', 'margin-top':'-20px'});		
	
	if ( $.browser.msie ) {
		spanMensagem.css({'padding':'5px 3px 3px 3px'});
		botoesMensagem.css({'margin-top':'2px'});		
	}	

	$('input[type="text"],select').focus( function() {
		if ( $(this).attr('name') == 'vlprotoc' ) {
			spanMensagem.html('Informe o valor do comprovante.');
		} else {
			spanMensagem.html($(this).attr('alt'));
		}
	});	
	
}


// botoes
function btnVoltar() {
	estadoInicial();
	controlaPesquisas();
	return false;
}

function btnContinuar() {
	if ( divError.css('display') == 'block' ) { return false; }		
	manterRotina();
	controlaPesquisas();
	return false;
}


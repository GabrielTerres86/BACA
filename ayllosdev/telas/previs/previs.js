/*!
 * FONTE        : previs.js
 * CRIAÇÃO      : Rogerius Militão (DB1) 
 * DATA CRIAÇÃO : 27/12/2011													ÚLTIMA ALTERAÇÃO: 03/10/2016
 * OBJETIVO     : Biblioteca de funções da tela PREVIS
 * --------------
 * ALTERAÇÕES   : 01/08/2012 - Implementado regras para as subopcoes (E,S,R) da tela PREVIS opcao 'F' (Tiago)
 *				  22/08/2012 - Ajustes referente ao projeto Fluxo Financeiro (Adriano).
                  25/03/2013 - Padronização de novo layout (Daniel). 
				  05/09/2013 - Alteração da sigla PAC para PA (Carlos).
                  21/03/2016 - Ajuste layout, valores negativos (Adriano)
                  03/10/2016 - Remocao das opcoes "F" e "L" para o PRJ313. (Jaison/Marcos SUPERO)
 * --------------
 */

var frmCab   		= 'frmCab';
var	cddopcao		= 'C';
var cdcoopex		= '';
var cdmovmto		= 'E';
var dtmvtolx        = '';
var hrpermit;				 //Horário permitido ou não para alteração
var vlresgan		= '';    //Armazena o valor atual do resgate antes de ser efetuado alteração do mesmo
var vlaplian		= '';    //Armazena o valor atual da aplicação antes de ser efetuado alteração do mesmo
var qtcopapl		= 0;     //Devido a montagem dos campos no form_fluxo_investimento_cecred ser dinâmica, está variável
					         //irá armazenar o número de cooperativas que serão listadas. Sendo assim, possível 
							 //formatar o css também de forma dinâmica.
							 
var strHTML 		= ''; // Variável usada na criação do form onde serão mostradas as mensagens de alerta.
var style 			= ''; // Variável usada na criação do form onde serão mostradas as mensagens de alerta.	
var mensagem 		= ''; // Variável usada na criação do form onde serão mostradas as mensagens de alerta.						 

var cCddopcao, cCdcooper, cDtmvtolt, cCdagenci, cTodosCabecalho, cDivmovmto, cDivagenci, cDivcooper, cCdmovmto;
var cVldepesp, cVldvlnum, cVlmoedaN, cQtmoedaN, cSubmoedN, cVldnotaN, cQtdnotaN, cSubnotaN;
    


$(document).ready(function() {

	estadoInicial();
	
});


// inicio
function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);

	cdcoopex = '';
	hrpermit = false;
	
	// retira as mensagens	
	hideMsgAguardo();

	// formailzia	
	formataCabecalho();
	
	$('#divBotoes').css('display', 'block');

	cTodosCabecalho.limpaFormulario().removeClass('campoErro');	

	$('#divInformacoes').html('');
	
	cCddopcao.habilitaCampo();
	cCddopcao.focus();
	cCddopcao.val( cddopcao );
	cCdmovmto.habilitaCampo();
	cCdmovmto.val(cdmovmto);		
	
	cDivmovmto.hide();
	cDivagenci.show();
	cCdagenci.show();
    cDivcooper.hide();	
	
	removeOpacidade('divTela');
	
	controlaFocus();
	
	highlightObjFocus( $('#frmCab') );
}


// controle
function controlaOperacao() {

	dtmvtolx = cDtmvtolt.val();
	hrpermit = false;
	strHTML = '';
	
	var cdagencx = normalizaNumero( cCdagenci.val() );
	
	cdmovmto = cCdmovmto.val();
	
	var mensagem = 'Aguarde, buscando dados ...';
	
	showMsgAguardo( mensagem );	
	
		
	// Carrega dados da conta através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/previs/principal.php', 
		data    : 
				{ 
					cddopcao	: cddopcao, 
					cdmovmto	: cdmovmto,
					dtmvtolx    : dtmvtolx,
					cdagencx    : cdagencx,
					cdcoopex    : cdcoopex,
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
							$('#divInformacoes').html(response);
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

function manterRotina() {
		
	hideMsgAguardo();		

	var dtmvtolx = cDtmvtolt.val();
	var cdagencx = normalizaNumero( cCdagenci.val() );
	
	var vldepesp = cVldepesp.val(); 
	var vldvlnum = cVldvlnum.val();
	var vldvlbcb = cVldvlbcb.val();
	
	var qtmoeda1 = $('#qtmoeda1', '#frmPrevisoes').val();	
	var qtmoeda2 = $('#qtmoeda2', '#frmPrevisoes').val();	
	var qtmoeda3 = $('#qtmoeda3', '#frmPrevisoes').val();	
	var qtmoeda4 = $('#qtmoeda4', '#frmPrevisoes').val();	
	var qtmoeda5 = $('#qtmoeda5', '#frmPrevisoes').val();	
	var qtmoeda6 = $('#qtmoeda6', '#frmPrevisoes').val();	
	
	var qtdnota1 = $('#qtdnota1', '#frmPrevisoes').val();	
	var qtdnota2 = $('#qtdnota2', '#frmPrevisoes').val();	
	var qtdnota3 = $('#qtdnota3', '#frmPrevisoes').val();	
	var qtdnota4 = $('#qtdnota5', '#frmPrevisoes').val();	
	var qtdnota5 = $('#qtdnota4', '#frmPrevisoes').val();	
	var qtdnota6 = $('#qtdnota6', '#frmPrevisoes').val();	
	
	var mensagem = 'Aguarde, gravando dados ...';
	
	showMsgAguardo( mensagem );	
	
	$.ajax({		
			type  : 'POST',
			url   : UrlSite + 'telas/previs/manter_rotina.php', 		
			data: {
				cddopcao	: cddopcao,
				dtmvtolx	: dtmvtolx,
				cdagencx	: cdagencx,
				cdcoopex	: cdcoopex,
				vldepesp	: vldepesp,
				vldvlnum    : vldvlnum,
				vldvlbcb	: vldvlbcb,
				qtmoeda1	: qtmoeda1,
				qtmoeda2    : qtmoeda2,
				qtmoeda3    : qtmoeda3,
				qtmoeda4    : qtmoeda4,
				qtmoeda5    : qtmoeda5,
				qtmoeda6    : qtmoeda6,
				qtdnota1	: qtdnota1,
				qtdnota2	: qtdnota2,
				qtdnota3	: qtdnota3,
				qtdnota4	: qtdnota4,
				qtdnota5	: qtdnota5,
				qtdnota6	: qtdnota6,
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

	/*---------------------*/
	/*  CONTROLE PAC  	   */
	/*---------------------*/
	var linkPac = $('a:eq(0)','#'+frmCab);

	if ( linkPac.prev().hasClass('campoTelaSemBorda') ) {		
		linkPac.addClass('lupa').css('cursor','auto').unbind('click');
	} else {
		
		linkPac.css('cursor','pointer').unbind('click').bind('click', function() {			
			bo			= 'b1wgen0059.p';
			procedure	= 'busca_pac';
			titulo      = 'Agência PA';
			qtReg		= '20';					
			filtrosPesq	= 'Cód. PA;cdagenci;30px;S;0;;codigo;|Agência PA;nmresage;200px;S;;;descricao;';
			colunas 	= 'Código;cdagepac;20%;right|Descrição;dsagepac;80%;left';
			mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas);
			
		});
		
	}
	
	return false;
}

function controlaLayout() {
        
    $('#divBotoes').css('display', 'none');
   	
	if ( cddopcao == 'A' || cddopcao == 'I' ) {
	
		formataPrevisoes();		
		cVldepesp.habilitaCampo(); 
		cVldvlnum.habilitaCampo();
		cQtmoedaN.habilitaCampo();
		cQtdnotaN.habilitaCampo();
		cVldepesp.select();

		cDtmvtolt.desabilitaCampo(); 
		cCdagenci.desabilitaCampo(); 

		$('#divBotoesPrevisoes').append('&nbsp;<a href="#" class="botao" id="btSalvar" onClick="btnGravar(); return false;">Prosseguir</a>');
		$('#divBotoesPrevisoes').css('display', 'block');
		
		
	} else if ( cddopcao == 'C' ) {
	
		formataPrevisoes();
		$('#divBotoesPrevisoes').css({ 'display': 'block', 'padding-bottom': '15px' });
		$('#btVoltar', '#divBotoesPrevisoes').css({ 'display': 'inline' });		

		cDtmvtolt.desabilitaCampo(); // Daniel
		cCdagenci.desabilitaCampo(); // Daniel
		
	}	
	
	controlaPesquisas();
	
	return false;
	
}


// formata
function formataCabecalho() {

	// label
	rCddopcao = $('label[for="cddopcao"]', '#'+frmCab);
	rCdcooper = $('label[for="cdcooper"]', '#'+frmCab);
	rDtmvtolt = $('label[for="dtmvtolt"]', '#'+frmCab);
	rCdagenci = $('label[for="cdagenci"]', '#'+frmCab);
	rCdmovmto = $('label[for="cdmovmto"]', '#'+frmCab);
	
	rCddopcao.addClass('rotulo').css({'width':'73px'});
	rCdcooper.addClass('rotulo-linha').css({'width':'78px','text-align':'right'});
	rDtmvtolt.addClass('rotulo-linha').css({'width':'71px'});
	rCdagenci.addClass('rotulo-linha').css({'width':'36px'});
	rCdmovmto.addClass('rotulo-linha').css({'width':'71px'});
	
	// input
	cCddopcao = $('#cddopcao', '#'+frmCab);
	cCdcooper = $('#cdcooper', '#'+frmCab);
	cDtmvtolt = $('#dtmvtolt', '#'+frmCab);
	cCdagenci = $('#cdagenci', '#'+frmCab);
	cCdmovmto = $('#cdmovmto', '#'+frmCab);
	
	cCddopcao.css({'width':'400px'});
	cCdmovmto.css({'width':'190px'});
	cCdcooper.css({'width':'120px'});	
	cDtmvtolt.css({'width':'100px'}).addClass('data');	
	cCdagenci.css({'width':'50px'}).addClass('inteiro pesquisa').attr('maxlength','3');	
	
	// outros
	cTodosCabecalho = $('input[type="text"],select','#'+frmCab);
	cTodosCabecalho.desabilitaCampo();
	cDivmovmto = $('#divmovmto');
	cDivagenci = $('#divagenci');
	cDivcooper = $('#divcooper');
		
	if ( $.browser.msie ) {
		rCdcooper.css({'width':'71px'});
		rDtmvtolt.css({'width':'74px'});
		rCdagenci.css({'width':'38px'});
	}
	
	cCdmovmto.unbind('keypress').bind('keypress', function(e){
	
		if ( divError.css('display') == 'block' ) { return false; }	
		
		cdmovmto = cCdmovmto.val();
		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
		
			if(cdcoplog == 3){
			
				($(this).val() == "A")  ? cDivcooper.hide() : cDivcooper.show();
			
			}else{
				
				cDivcooper.hide();
			
			}
			
			if($("#divcooper").is(":visible")){
			
				cCdcooper.html( slcooper );
				cCdcooper.val( cdcoopex );		
				cCdcooper.habilitaCampo();
				
			}else{
				cDtmvtolt.select();			
			}	
			
			cDtmvtolt.focus();
			cdmovmto = cCdmovmto.val();			
			cCdmovmto.desabilitaCampo();
			return false;
			
		} 	
	});
	
    cCddopcao.unbind('keypress').bind('keypress', function(e) {
	
		if ( divError.css('display') == 'block' ) { return false; }		
		
		var auxopcao = cCddopcao.val();
		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			dtmvtolx = '';
			cddopcao = cCddopcao.val();
			ativaCampoCabecalho();
			
			controlaPesquisas();
			return false;
		} 
		
	});	
	
    cCdcooper.unbind('keypress').bind('keypress', function(e) {
		
		if ( divError.css('display') == 'block' ) { return false; }		
				
		var auxopcao = cCddopcao.val();
		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 && (cddopcao == 'A' || cddopcao == 'C' || cddopcao == 'I') ) {
		
			cCdagenci.select();
			
		}
		
	});	
	
	cCdcooper.change(function(){
	
		if ( divError.css('display') == 'block' ) { return false; }
		
		var auxopcao = cCddopcao.val();
		
		$('#btSalvar','#divBotoes').focus();
				
	});
	
	cDtmvtolt.unbind('keypress').bind('keypress', function(e) {
	
		if ( divError.css('display') == 'block' ) { return false; }	
		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 && (cddopcao == 'A' || cddopcao == 'C' || cddopcao == 'I') ) {
		
			cCdagenci.select();
			
		}
		
	});	
	
	cCdagenci.unbind('keypress').bind('keypress', function(e) {
	
		if ( divError.css('display') == 'block' ) { return false; }	
		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			cdcoopex = normalizaNumero( cCdcooper.val() );
			controlaOperacao();
			return false;
		} 
	});		
	
	
	layoutPadrao();
	controlaPesquisas();	
	
	return false;	
}

function formataPrevisoes() {

	/******************
		DEVOLUCAO
	******************/
	// label
	rVldepesp = $('label[for="vldepesp"]', '#frmPrevisoes');
	rVldvlnum = $('label[for="vldvlnum"]', '#frmPrevisoes');
	rVldvlbcb = $('label[for="vldvlbcb"]', '#frmPrevisoes');
	
	rVldepesp.addClass('rotulo').css({'width':'102px'});
	rVldvlnum.addClass('rotulo-linha').css({'width':'68px'});
	rVldvlbcb.addClass('rotulo-linha').css({'width':'102px'});
	
	// input
	cVldepesp = $('#vldepesp', '#frmPrevisoes');
	cVldvlnum = $('#vldvlnum', '#frmPrevisoes');
	cVldvlbcb = $('#vldvlbcb', '#frmPrevisoes');
	
	cVldepesp.css({'width':'90px'}).addClass('monetario');
	cVldvlnum.css({'width':'100px'}).addClass('monetario');
	cVldvlbcb.css({'width':'100px'}).addClass('monetario');

	if ( $.browser.msie ) {
		rVldepesp.css({'width':'102px'});
		rVldvlnum.css({'width':'71px'});
		rVldvlbcb.css({'width':'105px'});
	}
	
	
	/******************
		TITULOS
	******************/
	// label
	rQtremtit = $('label[for="qtremtit"]', '#frmPrevisoes');
	rVlremtit = $('label[for="vlremtit"]', '#frmPrevisoes');

	rQtremtit.addClass('rotulo').css({'width':'102px'});
	rVlremtit.addClass('rotulo-linha').css({'width':'68px'});
	
	// input
	cQtremtit = $('#qtremtit', '#frmPrevisoes');
	cVlremtit = $('#vlremtit', '#frmPrevisoes');
	
	cQtremtit.css({'width':'90px'}).addClass('inteiro');
	cVlremtit.css({'width':'100px'}).addClass('monetario');

	if ( $.browser.msie ) {
		rVlremtit.css({'width':'71px'});
	}
	
	/******************
		SUPRIMENTOS
	******************/
	// label
	rVlmoedas = $('label[for="vlmoedas"]', '#frmPrevisoes');
	rQtmoedas = $('label[for="qtmoedas"]', '#frmPrevisoes');
	rSubmoeds = $('label[for="submoeds"]', '#frmPrevisoes');
	rVldnotas = $('label[for="vldnotas"]', '#frmPrevisoes');	
	rQtdnotas = $('label[for="qtdnotas"]', '#frmPrevisoes');	
	rSubnotas = $('label[for="subnotas"]', '#frmPrevisoes');	
	
	rVlmoedas.addClass('rotulo-linha').css({'width':'59px'});
	rQtmoedas.addClass('rotulo-linha').css({'width':'76px'});
	rSubmoeds.addClass('rotulo-linha').css({'width':'80px'});
	rVldnotas.addClass('rotulo-linha').css({'width':'142px'});
	rQtdnotas.addClass('rotulo-linha').css({'width':'72px'});
	rSubnotas.addClass('rotulo-linha').css({'width':'102px'});
	
	rVlmoedaN = $('label[for="vlmoeda1"], label[for="vlmoeda2"], label[for="vlmoeda3"], label[for="vlmoeda4"], label[for="vlmoeda5"], label[for="vlmoeda6"]', '#frmPrevisoes');
	rQtmoedaN = $('label[for="qtmoeda1"], label[for="qtmoeda2"], label[for="qtmoeda3"], label[for="qtmoeda4"], label[for="qtmoeda5"], label[for="qtmoeda6"]', '#frmPrevisoes');
	rSubmoedN = $('label[for="submoed1"], label[for="submoed2"], label[for="submoed3"], label[for="submoed4"], label[for="submoed5"], label[for="submoed6"]', '#frmPrevisoes');
	rVldnotaN = $('label[for="vldnota1"], label[for="vldnota2"], label[for="vldnota3"], label[for="vldnota4"], label[for="vldnota5"], label[for="vldnota6"]', '#frmPrevisoes');
	rQtdnotaN = $('label[for="qtdnota1"], label[for="qtdnota2"], label[for="qtdnota3"], label[for="qtdnota4"], label[for="qtdnota5"], label[for="qtdnota6"]', '#frmPrevisoes');
	rSubnotaN = $('label[for="subnota1"], label[for="subnota2"], label[for="subnota3"], label[for="subnota4"], label[for="subnota5"], label[for="subnota6"]', '#frmPrevisoes');
	
	rVlmoedaN.css({'width':'13px'}).addClass('rotulo');
	rQtmoedaN.css({'width':'15px'}).addClass('rotulo-linha');	
	rSubmoedN.css({'width':'15px'}).addClass('rotulo-linha');	
	rVldnotaN.css({'width':'70px'}).addClass('rotulo-linha');	
	rQtdnotaN.css({'width':'15px'}).addClass('rotulo-linha');
	rSubnotaN.css({'width':'15px'}).addClass('rotulo-linha');	

	rTotalpre = $('label[for="totalpre"]', '#frmPrevisoes');
	rTotmoeda = $('label[for="totmoeda"]', '#frmPrevisoes');
	rTotnotas = $('label[for="totnotas"]', '#frmPrevisoes');
	rNmoperad = $('label[for="nmoperad"]', '#frmPrevisoes');
	rHrtransa = $('label[for="hrtransa"]', '#frmPrevisoes');
	
	rTotalpre.addClass('rotulo').css({'width':'53px'});
	rTotmoeda.addClass('rotulo-linha').css({'width':'104px'});
	rTotnotas.addClass('rotulo-linha').css({'width':'227px'});
	rNmoperad.addClass('rotulo').css({'width':'72px'});
	rHrtransa.addClass('rotulo-linha').css({'width':'5px'});
	
	// input
	cVlmoedaN = $('#vlmoeda1, #vlmoeda2, #vlmoeda3, #vlmoeda4, #vlmoeda5, #vlmoeda6', '#frmPrevisoes');
	cQtmoedaN = $('#qtmoeda1, #qtmoeda2, #qtmoeda3, #qtmoeda4, #qtmoeda5, #qtmoeda6', '#frmPrevisoes');
	cSubmoedN = $('#submoed1, #submoed2, #submoed3, #submoed4, #submoed5, #submoed6', '#frmPrevisoes');
	cVldnotaN = $('#vldnota1, #vldnota2, #vldnota3, #vldnota4, #vldnota5, #vldnota6', '#frmPrevisoes');
	cQtdnotaN = $('#qtdnota1, #qtdnota2, #qtdnota3, #qtdnota4, #qtdnota5, #qtdnota6', '#frmPrevisoes');
	cSubnotaN = $('#subnota1, #subnota2, #subnota3, #subnota4, #subnota5, #subnota6', '#frmPrevisoes');

	cVlmoedaN.css({'width':'55px'}).addClass('monetario');
	cQtmoedaN.css({'width':'50px'}).addClass('inteiro').attr('maxlength','3');
	cSubmoedN.css({'width':'90px'}).addClass('monetario');
	cVldnotaN.css({'width':'55px'}).addClass('monetario');
	cQtdnotaN.css({'width':'60px'}).addClass('inteiro').attr('maxlength','6');
	cSubnotaN.css({'width':'90px'}).addClass('monetario');

	cTotmoeda = $('#totmoeda', '#frmPrevisoes');	
	cTotnotas = $('#totnotas', '#frmPrevisoes');	
	cNmoperad = $('#nmoperad', '#frmPrevisoes');	
	cHrtransa = $('#hrtransa', '#frmPrevisoes');
	
	cTotmoeda.css({'width':'90px'}).addClass('monetario');
	cTotnotas.css({'width':'90px'}).addClass('monetario');
	cNmoperad.css({'width':'400px'});
	cHrtransa.css({'width':'90px'});
	
	if ( $.browser.msie ) {
		rVlmoedas.css({'width':'62px'});
		rVldnotas.css({'width':'158px'});
		
		rVldnotaN.css({'width':'85px'});	
		rTotmoeda.css({'width':'91px'});
		rTotnotas.css({'width':'216px'});

		cNmoperad.css({'width':'300px'});
		rHrtransa.css({'width':'78px'});
	}	


	/******************
		OUTROS
	******************/
	
	cTodosPrevisoes = $('input[type="text"],select','#frmPrevisoes');
	cTodosPrevisoes.desabilitaCampo();
	
	
	/******************
		EVENTOS
	******************/
	// Controla a tab nos campos qtde moedas
	cQtmoedaN.unbind('keydown').bind('keydown', function(e) {
		var nrindice = parseInt($(this).attr('id').charAt(7));
		var menos 	 = $('#qtmoeda'+(nrindice-1), '#frmPrevisoes');
		var mais  	 = $('#qtmoeda'+(nrindice+1), '#frmPrevisoes');
		var qtdnota1 = $('#qtdnota1', '#frmPrevisoes');
		
		
		if ( e.keyCode == 9 || e.keyCode == 40 ) {
			
			nrindice = nrindice + 1;

			if ( nrindice >= 1 && nrindice <= 6 ) {
				mais.select();
			} else {
				qtdnota1.select();				
			}		
			
			return false;
			
		} else  if ( e.keyCode == 16 || e.keyCode == 38 ) {
			
			nrindice = nrindice - 1;
			
			if ( nrindice >= 1 && nrindice <= 6 ) {
				menos.select();
			} else {
				cVldvlnum.select();
			}		
			
			return false;
			
		}
		
	});	

	
	// Calcula o subtotal da moeda
	cQtmoedaN.unbind('change').bind('change', function() {
		
		// indice
		var nrindice = $(this).attr('id').charAt(7);
		
		// 
		var vlmoedan = $('#vlmoeda'+nrindice, '#frmPrevisoes');
		var qtmoepcn = $('#qtmoepc'+nrindice, '#frmPrevisoes');
		var submoedn = $('#submoed'+nrindice, '#frmPrevisoes');

		if ( $(this).val() == '' ) 	$(this).val('0');
		
		// calculo	
		var subtotal = parseInt($(this).val()) * converteMoedaFloat(vlmoedan.val()) * parseInt(qtmoepcn.val());
		var subtotal = Math.round(subtotal); // arredonda o valor
		
		submoedn.val(subtotal);
		submoedn.trigger('blur');
		
		calculaTotalMoedas();
		
	});	
	

	// Controla o tab nos campos qtde notas
	cQtdnotaN.unbind('keydown').bind('keydown', function(e) {
	
		var nrindice = parseInt($(this).attr('id').charAt(7));
		var mais   	 = $('#qtdnota'+(nrindice+1), '#frmPrevisoes');
		var menos 	 = $('#qtdnota'+(nrindice-1), '#frmPrevisoes');
		var qtmoeda6 = $('#qtmoeda6', '#frmPrevisoes');
		
		if ( e.keyCode == 9 || e.keyCode == 40 ) {
			
			nrindice	 = nrindice + 1;

			if ( nrindice >= 1 && nrindice <= 6 ) {
				mais.select();
			} else {
				$('#btSalvar','#divBotoes').focus();
			}		
			
			return false;
			
		} else  if ( e.keyCode == 16 || e.keyCode == 38 ) {
			
			nrindice	 = nrindice - 1;
			
			if ( nrindice >= 1 && nrindice <= 6 ) {
				menos.select();
			} else {
				qtmoeda6.select();
			}		
			
			return false;
			
		}
			
	});	
	

	// Calcula a o subtotal das notas
	cQtdnotaN.unbind('change').bind('change', function() {
		
		// indice
		var nrindice = $(this).attr('id').charAt(7);
		
		// 
		var vldnotan = $('#vldnota'+nrindice, '#frmPrevisoes');
		var subnotan = $('#subnota'+nrindice, '#frmPrevisoes');
		
		if ( $(this).val() == '' ) 	$(this).val('0');
		
		// calculo	
		var subtotal = parseInt($(this).val()) * converteMoedaFloat(vldnotan.val());
		var subtotal = Math.round(subtotal); // arredonda o valor
		
		//
		subnotan.val(subtotal);
		subnotan.trigger('blur');
		
		calculaTotalNotas();
	});	
	
	
	layoutPadrao();
	return false;
}



// ativa campo do cabecalho conforme a opcao
function ativaCampoCabecalho() {

	cCddopcao.desabilitaCampo();

	if(dtmvtolx == ''){
		cDtmvtolt.val( dtmvtolt );
	}else{
		cDtmvtolt.val( dtmvtolx );
	}
	
	cCdmovmto.val(cdmovmto);
			
	if ( cddopcao == 'A' ) {
	
		cDivmovmto.hide();
		cDivagenci.show();
		cDivcooper.hide();
		cCdcooper.desabilitaCampo().hide(); 
		cDtmvtolt.desabilitaCampo(); 
		cCdagenci.habilitaCampo().show().select();
	
	} else if ( cddopcao == 'C' ) {
	
		cDivmovmto.hide();
		cDivagenci.show();
		cDivcooper.hide();
		cCdcooper.desabilitaCampo().hide(); 
		cDtmvtolt.habilitaCampo().select(); 
		cCdagenci.habilitaCampo().show();
			
	} else if ( cddopcao == 'I' ) { 
	
		cDivmovmto.hide();
		cDivagenci.show();
		cDivcooper.hide();
		cCdcooper.desabilitaCampo().hide(); 
		cDtmvtolt.desabilitaCampo(); 
		cCdagenci.habilitaCampo().show().select();
	
	}
	
	return false;
	
}

// total moeda
function calculaTotalMoedas() {
	
	// soma	
	var sommoeda = 0;
	
	cSubmoedN.each(function() {
		sommoeda = sommoeda + converteMoedaFloat($(this).val());
	});	
	
	// mostra o valor total
	var totmoeda = $('#totmoeda', '#frmPrevisoes');
	totmoeda.val(sommoeda);
	totmoeda.trigger('blur');
	
	return false;
}

// total notas
function calculaTotalNotas() {

	var somnotas = 0;
	
	// soma
	cSubnotaN.each(function() {
		somnotas = somnotas + converteMoedaFloat($(this).val());
	});	

	// mostra o valor total
	var totnotas = $('#totnotas', '#frmPrevisoes');
	totnotas.val(somnotas);
	totnotas.trigger('blur');

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
	
		cddopcao = cCddopcao.val();
		cdmovmto = cCdmovmto.val();
		ativaCampoCabecalho();		
		
	} else if ( cCdcooper.hasClass('campo') || cDtmvtolt.hasClass('campo') || cCdagenci.hasClass('campo') ) {
	
		cdmovmto = cCdmovmto.val();
		cdcoopex = normalizaNumero( cCdcooper.val() );
			
		controlaOperacao();
						
	}	
	
	controlaPesquisas();
	return false;

}

function btnGravar() {

	if ( divError.css('display') == 'block' ) { return false; }		
  
	if ( cCddopcao.hasClass('campo') ) {
		cddopcao = cCddopcao.val();
		cdmovmto = cCdmovmto.val();
		ativaCampoCabecalho();		
		
	} else {
		cdmovmto = cCdmovmto.val();
		cdcoopex = normalizaNumero( cCdcooper.val() );
			
		manterRotina();
								
	}	
	
	controlaPesquisas();
	return false;

}

function trocaBotao( botao,funcao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onClick="btnVoltar(); return false;">Voltar<a/>');
	
	if ( botao != '') {
		$('#divBotoes','#divTela').append('&nbsp;<a href="#" class="botao" id="btSalvar" onClick="'+funcao+'; return false;">'+botao+'</a>');
	}
	
	return false;
	
}

function bloqueiaCampo(){
	
	singulae = $('#vlrepass1,#vlrepass2,#vlrepass3,#vlrfolha2,#vlnumera2,#vloutros1,#vloutros2,#vloutros3,#vloutros4','#frmFluxo');
	singulas = $('#vlrepass1,#vlrepass2,#vlrepass3,#vlrfolha2,#vlnumera2,#vloutros1,#vloutros2,#vloutros3,#vloutros4','#frmFluxo');
	singular = $('#vlaplica,#vlresgat','#frmFluxo');
	
	if(cdmovmto == "E"){
	
		singulae.desabilitaCampo();
			
	}else if(cdmovmto == "S"){
	
			 singulas.desabilitaCampo();
			 
	}else if(cdmovmto == "R"){
	
			 singular.desabilitaCampo();
			 
	}

	return false;
	
}


function verificaAcesso(){

	var mensagem = 'Aguarde, validando acesso ...';
	
	showMsgAguardo( mensagem );	

	// Gera requisição ajax para validar o acesso
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/previs/verifica_acesso.php', 
		data    : 
				{ 
					cddopcao    : cddopcao,
					cdmovmto    : cdmovmto,
					cdcoopex    : cdcoopex,
					redirect	: 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) {
					hideMsgAguardo();
					eval( response );
																		
				}
				
	});
	
	return false;

}

function liberaAcesso(){

	var mensagem = 'Aguarde, liberando acesso ...';
	
	showMsgAguardo( mensagem );	

	// Gera a requisição ajax para liberar acesso a tela
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/previs/libera_acesso.php', 
		data    : 
				{ 
					cddopcao    : cddopcao,
					cdmovmto	: cdmovmto,
					cdcoopex    : cdcoopex,
					redirect	: 'script_ajax' 
				},
		async 	: false,
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) {
					hideMsgAguardo();	
					eval( response );
																		
				}
				
	});
	
	return false;

}





// Função para fechar div com mensagens de alerta
function encerraMsgsAlerta() {
	
	// Esconde div
	$("#divMsgsAlerta").css("visibility","hidden");
	
	$("#divListaMsgsAlerta").html("&nbsp;");
	
	// Esconde div de bloqueio
	unblockBackground();
	
	return false;
	
}


function mostraMsgsAlerta(){
	
	if(strHTML != ''){
		
		// Coloca conteúdo HTML no div
		$("#divListaMsgsAlerta").html(strHTML);
			
		// Mostra div 
		$("#divMsgsAlerta").css("visibility","visible");
		
		// Esconde mensagem de aguardo
		hideMsgAguardo();
		
		// Bloqueia conteúdo que está átras do div de mensagens
		blockBackground(parseInt($("#divMsgsAlerta").css("z-index")));
		
	}
		
	return false;
	
}


function controlaFocus(){

$('#vldepesp','#frmPrevisoes').unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) { $('#vldvlnum','#frmPrevisoes').focus(); } });	
$('#vldvlnum','#frmPrevisoes').unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) { $('#qtmoeda1','#frmPrevisoes').focus(); } });	
$('#qtmoeda1','#frmPrevisoes').unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) { $('#qtmoeda2','#frmPrevisoes').focus(); } });
$('#qtmoeda2','#frmPrevisoes').unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) { $('#qtmoeda3','#frmPrevisoes').focus(); } });	
$('#qtmoeda3','#frmPrevisoes').unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) { $('#qtmoeda4','#frmPrevisoes').focus(); } });	
$('#qtmoeda4','#frmPrevisoes').unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) { $('#qtmoeda5','#frmPrevisoes').focus(); } });	
$('#qtmoeda5','#frmPrevisoes').unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) { $('#qtmoeda6','#frmPrevisoes').focus(); } });	
$('#qtmoeda6','#frmPrevisoes').unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) { $('#qtdnota1','#frmPrevisoes').focus(); } });
$('#qtdnota1','#frmPrevisoes').unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) { $('#qtdnota2','#frmPrevisoes').focus(); } });
$('#qtdnota2','#frmPrevisoes').unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) { $('#qtdnota3','#frmPrevisoes').focus(); } });
$('#qtdnota3','#frmPrevisoes').unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) { $('#qtdnota4','#frmPrevisoes').focus(); } });
$('#qtdnota4','#frmPrevisoes').unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) { $('#qtdnota5','#frmPrevisoes').focus(); } });
$('#qtdnota5','#frmPrevisoes').unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) { $('#qtdnota6','#frmPrevisoes').focus(); } });
$('#qtdnota6','#frmPrevisoes').unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) { btnGravar(); return false; } });

}



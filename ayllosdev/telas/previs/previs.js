/*!
 * FONTE        : previs.js
 * CRIAÇÃO      : Rogerius Militão (DB1) 
 * DATA CRIAÇÃO : 27/12/2011													ÚLTIMA ALTERAÇÃO: 25/03/2013
 * OBJETIVO     : Biblioteca de funções da tela PREVIS
 * --------------
 * ALTERAÇÕES   : 01/08/2012 - Implementado regras para as subopcoes (E,S,R) da tela PREVIS opcao 'F' (Tiago)
 *				  22/08/2012 - Ajustes referente ao projeto Fluxo Financeiro (Adriano).
                  25/03/2013 - Padronização de novo layout (Daniel). 
				  05/09/2013 - Alteração da sigla PAC para PA (Carlos).
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
	formataMsgAjuda('divTela');
	
	// remove o campo prosseguir
	trocaBotao('Prosseguir','btnContinuar()');	
	
	// inicializa com a frase de ajuda para o campo cddopcao
	/*$('span:eq(0)', '#divMsgAjuda').html( cCddopcao.attr('alt') );*/

	//
	cTodosCabecalho.limpaFormulario().removeClass('campoErro');	

	$('#frmPrevisoes').remove();
	$('#frmLiquidacao').remove();
	$('#frmFluxo').remove();

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

	formataCabecalho();
	formataMsgAjuda('divTela');
		
	if ( cddopcao == 'A' || cddopcao == 'I' ) {
	
		formataPrevisoes();
		ativaCampoCabecalho();
		trocaBotao('Prosseguir','btnGravar()');
		cVldepesp.habilitaCampo(); 
		cVldvlnum.habilitaCampo();
		cQtmoedaN.habilitaCampo();
		cQtdnotaN.habilitaCampo();
		cVldepesp.select();
		
		
	} else if ( cddopcao == 'C' ) {
	
		formataPrevisoes();
		ativaCampoCabecalho();
		cDtmvtolt.desabilitaCampo(); // Daniel
		cCdagenci.desabilitaCampo(); // Daniel

	} else if ( cddopcao == 'F' ) {
	
		formataFluxo();
		ativaCampoCabecalho();
		dtmvtolx = cDtmvtolt.val();
		cdmovmto = cCdmovmto.val();
		habmovte = $('#vlrepass1,#vlrepass2,#vlrepass3,#vlrfolha2,#vlnumera2,#vloutros1,#vloutros2,#vloutros3,#vloutros4','#frmFluxo');
		habmovts = $('#vlrepass1,#vlrepass2,#vlrepass3,#vlrfolha2,#vlnumera2,#vloutros1,#vloutros2,#vloutros3,#vloutros4','#frmFluxo');
		habmovtr = $('#vlresgat, #vlaplica','#frmFluxo');
				
		if(cdcoplog != 3){
		
			if(dtmvtolt == cDtmvtolt.val()){
			
				if (cdmovmto == 'E'){
				
					$('#vlrepass1','#frmFluxo').focus();
					habmovte.habilitaCampo();
										
				}else{
					if (cdmovmto == 'S'){

						$('#vlrepass1','#frmFluxo').focus();
						habmovts.habilitaCampo();
											
					}else{
						if(cdmovmto == 'R'){
						
							$('#vltotres','#frmFluxo').focus();
							habmovtr.habilitaCampo();
													
						}
					
					}
					
				}
				
			}else{
				$('#btVoltar','#divBotoes').select();
				
			}
			
			if(hrpermit){
			
				if(cdmovmto == "E" || cdmovmto == "S"){
					trocaBotao('Prosseguir','showConfirmacao(\'Deseja confirmar opera&ccedil;&atilde;o?\',\'Confirma&ccedil;&atilde;o - Ayllos\',\'gravaDiversos();\',\'\',\'sim.gif\',\'nao.gif\');');
				}else if(cdmovmto == "R"){
					trocaBotao('Prosseguir','showConfirmacao(\'Deseja confirmar opera&ccedil;&atilde;o?\',\'Confirma&ccedil;&atilde;o - Ayllos\',\'gravaApliResg();\',\'\',\'sim.gif\',\'nao.gif\');');
									
				}
			
			}
										
		}
				
	} else if ( cddopcao == 'L') {
		formataLiquidacao();
		ativaCampoCabecalho();		
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
	
	cCdmovmto.change(function(){
	
		if ( divError.css('display') == 'block' ) { return false; }		
		cdmovmto = cCdmovmto.val();
		
		if(cdcoplog == 3){
		
			($(this).val() == "A") ? cDivcooper.hide() : cDivcooper.show();
			
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
		
	});
	
	cCddopcao.unbind('keypress').bind('keypress', function(e) {
	
		if ( divError.css('display') == 'block' ) { return false; }		
		
		var auxopcao = cCddopcao.val();
		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			dtmvtolx = '';
			cddopcao = cCddopcao.val();
			ativaCampoCabecalho();
			
			if(auxopcao == 'F'){
				cCdmovmto.focus();
			}
			
			controlaPesquisas();
			return false;
		} 
		
	});	
	
	cCddopcao.change(function(){
	
		if ( divError.css('display') == 'block' ) { return false; }		
		
		var auxopcao = cCddopcao.val();				
		
		dtmvtolx = '';
		cddopcao = cCddopcao.val();
		ativaCampoCabecalho();
		
		if(auxopcao == 'F'){
			cCdmovmto.focus();
		}
		
		controlaPesquisas();
		
		return false;		
		
	});

	cCdcooper.unbind('keypress').bind('keypress', function(e) {
		
		if ( divError.css('display') == 'block' ) { return false; }		
				
		var auxopcao = cCddopcao.val();
		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 && cddopcao == 'L' ) {
		
			cdcoopex = normalizaNumero( cCdcooper.val() );
			controlaOperacao();
			return false;
			
		} else if ( e.keyCode == 13 && (cddopcao == 'A' || cddopcao == 'C' || cddopcao == 'I') ) {
		
			cCdagenci.select();
			
		} else if (cddopcao == 'F' && e.keyCode == 13) {
				
			(dtmvtolt == cDtmvtolt.val()) ? verificaAcesso() : controlaOperacao();
			return false;
			
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
		if ( e.keyCode == 13 && cddopcao == 'L' ) {
		
			cCdcooper.focus();
			return false;
			
		} else if ( e.keyCode == 13 && (cddopcao == 'A' || cddopcao == 'C' || cddopcao == 'I') ) {
		
			cCdagenci.select();
			
		} else if (cddopcao == 'F' && e.keyCode == 13) {
				
			if($("#divcooper").is(":visible")){
				cCdcooper.focus();
	
			}else{
				(dtmvtolt == cDtmvtolt.val()) ? verificaAcesso() : controlaOperacao();
			}
			return false;
			
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
	cVldvlnum.css({'width':'90px'}).addClass('monetario');
	cVldvlbcb.css({'width':'90px'}).addClass('monetario');

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
	cVlremtit.css({'width':'90px'}).addClass('monetario');

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
	rQtmoedas.addClass('rotulo-linha').css({'width':'66px'});
	rSubmoeds.addClass('rotulo-linha').css({'width':'80px'});
	rVldnotas.addClass('rotulo-linha').css({'width':'142px'});
	rQtdnotas.addClass('rotulo-linha').css({'width':'62px'});
	rSubnotas.addClass('rotulo-linha').css({'width':'92px'});
	
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
	rTotmoeda.addClass('rotulo-linha').css({'width':'94px'});
	rTotnotas.addClass('rotulo-linha').css({'width':'217px'});
	rNmoperad.addClass('rotulo').css({'width':'72px'});
	rHrtransa.addClass('rotulo-linha').css({'width':'75px'});
	
	// input
	cVlmoedaN = $('#vlmoeda1, #vlmoeda2, #vlmoeda3, #vlmoeda4, #vlmoeda5, #vlmoeda6', '#frmPrevisoes');
	cQtmoedaN = $('#qtmoeda1, #qtmoeda2, #qtmoeda3, #qtmoeda4, #qtmoeda5, #qtmoeda6', '#frmPrevisoes');
	cSubmoedN = $('#submoed1, #submoed2, #submoed3, #submoed4, #submoed5, #submoed6', '#frmPrevisoes');
	cVldnotaN = $('#vldnota1, #vldnota2, #vldnota3, #vldnota4, #vldnota5, #vldnota6', '#frmPrevisoes');
	cQtdnotaN = $('#qtdnota1, #qtdnota2, #qtdnota3, #qtdnota4, #qtdnota5, #qtdnota6', '#frmPrevisoes');
	cSubnotaN = $('#subnota1, #subnota2, #subnota3, #subnota4, #subnota5, #subnota6', '#frmPrevisoes');

	cVlmoedaN.css({'width':'45px'}).addClass('monetario');
	cQtmoedaN.css({'width':'50px'}).addClass('inteiro').attr('maxlength','3');
	cSubmoedN.css({'width':'90px'}).addClass('monetario');
	cVldnotaN.css({'width':'45px'}).addClass('monetario');
	cQtdnotaN.css({'width':'60px'}).addClass('inteiro').attr('maxlength','6');
	cSubnotaN.css({'width':'90px'}).addClass('monetario');

	cTotmoeda = $('#totmoeda', '#frmPrevisoes');	
	cTotnotas = $('#totnotas', '#frmPrevisoes');	
	cNmoperad = $('#nmoperad', '#frmPrevisoes');	
	cHrtransa = $('#hrtransa', '#frmPrevisoes');
	
	cTotmoeda.css({'width':'90px'}).addClass('monetario');
	cTotnotas.css({'width':'90px'}).addClass('monetario');
	cNmoperad.css({'width':'300px'});
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

function formataLiquidacao() {
	/******************
		SILOC
	******************/
	// label
	rVlcobbil = $('label[for="vlcobbil"]', '#frmLiquidacao');
	rVlcobmlt = $('label[for="vlcobmlt"]', '#frmLiquidacao');
	
	rVlcobbil.addClass('rotulo').css({'width':'150px'});
	rVlcobmlt.addClass('rotulo-linha').css({'width':'200px'});
	
	// input
	cVlcobbil = $('#vlcobbil', '#frmLiquidacao');
	cVlcobmlt = $('#vlcobmlt', '#frmLiquidacao');
	
	cVlcobbil.css({'width':'90px'}).addClass('monetario');
	cVlcobmlt.css({'width':'90px'}).addClass('monetario');
	
	/******************
		COMPE
	******************/
	// label
	rVlchqnot = $('label[for="vlchqnot"]', '#frmLiquidacao');
	rVlchqdia = $('label[for="vlchqdia"]', '#frmLiquidacao');

	rVlchqnot.addClass('rotulo').css({'width':'150px'});
	rVlchqdia.addClass('rotulo-linha').css({'width':'200px'});
	
	// input
	cVlchqnot = $('#vlchqnot', '#frmLiquidacao');
	cVlchqdia = $('#vlchqdia', '#frmLiquidacao');
	
	cVlchqnot.css({'width':'90px'}).addClass('monetario');
	cVlchqdia.css({'width':'90px'}).addClass('monetario');

	/******************
		OUTROS
	******************/
	cTodosLiquidacao = $('input[type="text"],select','#frmLiquidacao');
	cTodosLiquidacao.desabilitaCampo();
	
	layoutPadrao();
	return false;
}

function formataFluxo() {

	/******************
		OUTROS
	******************/
	cTodosFluxo = $('input[type="text"],select','#frmFluxo');
	cTodosFluxo.desabilitaCampo();

	/******************
	INVESTIMENTO CENTRAL
	******************/
	rCooperat = $('label[for="lbcooper"]', '#frmFluxo');
	rOperador = $('label[for="lboperad"]', '#frmFluxo');
	rValorinv = $('label[for="lbvlrinv"]', '#frmFluxo');
	rMoviment = $('label[for="lbmovime"]', '#frmFluxo');
	
	rCooperat.css({'width':'270px'}).addClass('rotulo');
	rOperador.css({'width':'110px'}).addClass('rotulo-linha');
	rValorinv.css({'width':'192px'}).addClass('rotulo-linha');
	rMoviment.css({'width':'115px'}).addClass('rotulo-linha');

	rNmoperador = $('label[for="operador"]', '#frmFluxo');
	rNmoperador.css({'width':'50px'});
	
	rTpoMovto = $('label[for="tpomovto"]', '#frmFluxo');
	rTpoMovto.css({'width':'20px'});
	
	for(var i = 0; i < qtcopapl; i++){
	
		eval('var rVlresapl'+i+' = $(\'label[for="vlresapl'+i+'"]\', \'#frmFluxo\');');
		eval('rVlresapl'+i+'.css(\'width\',\'20px\');');
		
		eval('var cVlresapl'+i+' = $(\'#vlresapl'+i+'\',\'#frmFluxo\');');
		eval('cVlresapl'+i+'.css(\'width\',\'100px\').addClass(\'monetario\');');
				
	}
	
	rTotmovto = $('label[for="totmovto"]', '#frmFluxo');
	rTotmovto.css({'width':'208px'});
	
	if($.browser.msie){
		rTotmovto.css({'width':'200px'});
	}
	
	cTpoMovto = $('#tpomovto','#frmFluxo');
	cTotmovto = $('#totmovto','#frmFluxo');
	
	cTpoMovto.css({'width':'100px'});
	cTotmovto.css({'width':'100px'}).addClass('monetario');
	
		
	/******************
	DEBITOS e CREDITOS
	******************/
	// label
	rCdbcova1 = $('label[for="cdbcova1"]', '#frmFluxo');
	rCdbcova2 = $('label[for="cdbcova2"]', '#frmFluxo');
	rCdbcova3 = $('label[for="cdbcova3"]', '#frmFluxo');
	rCdbcova4 = $('label[for="cdbcova4"]', '#frmFluxo');	
	
	rCdbcova1.css({'width':'295px'}).addClass('rotulo');
	rCdbcova2.css({'width':'148px'}).addClass('rotulo-linha');
	rCdbcova3.css({'width':'146px'}).addClass('rotulo-linha');
			
	rCdbcova4.css({'width':'142px'}).addClass('rotulo-linha');	
	
	if ( $.browser.msie ) {
		rCdbcova2.css({'width':'146px'}).addClass('rotulo-linha');
		rCdbcova3.css({'width':'142px'}).addClass('rotulo-linha');	
		rCdbcova4.css({'width':'146px'}).addClass('rotulo-linha');
	}	
	
	if(cdmovmto == "R"){
		
		if(!$.browser.msie){
		
			rCdbcova1.css({'width':'304px'}).addClass('rotulo');	
			rCdbcova2.css({'width':'142px'}).addClass('rotulo-linha');
			rCdbcova3.css({'width':'148px'}).addClass('rotulo-linha');
			
		}else{
		
			rCdbcova1.css({'width':'298px'}).addClass('rotulo');
			rCdbcova2.css({'width':'142px'}).addClass('rotulo-linha');
			rCdbcova3.css({'width':'148px'}).addClass('rotulo-linha');
		
		}
		
	}
	
	
	rTodostit = $('label[for="vlcheque"] , label[for="vltotdoc"] , label[for="vltotted"] , label[for="vltottit"] , label[for="vldevolu"] , label[for="vlmvtitg"] , label[for="vlttinss"] , label[for="vltrdeit"] , label[for="vlsatait"] , label[for="vldivers"] , label[for="vlrepass"] , label[for="vlrfolha"] , label[for="vlnumera"] , label[for="vloutros"] , label[for="vlttcrdb"] ', '#frmFluxo');
	rTodosli1 = $('label[for="vlcheque1"], label[for="vltotdoc1"], label[for="vltotted1"], label[for="vltottit1"], label[for="vldevolu1"], label[for="vlmvtitg1"], label[for="vlttinss1"], label[for="vltrdeit1"], label[for="vlsatait1"], label[for="vldivers1"], label[for="vlrepass1"], label[for="vlrfolha1"], label[for="vlnumera1"], label[for="vloutros1"], label[for="vlttcrdb1"]', '#frmFluxo');
	rTodosli2 = $('label[for="vlcheque2"], label[for="vltotdoc2"], label[for="vltotted2"], label[for="vltottit2"], label[for="vldevolu2"], label[for="vlmvtitg2"], label[for="vlttinss2"], label[for="vltrdeit2"], label[for="vlsatait2"], label[for="vldivers2"], label[for="vlrepass2"], label[for="vlrfolha2"], label[for="vlnumera2"], label[for="vloutros2"], label[for="vlttcrdb2"]', '#frmFluxo');
	rTodosli3 = $('label[for="vlcheque3"], label[for="vltotdoc3"], label[for="vltotted3"], label[for="vltottit3"], label[for="vldevolu3"], label[for="vlmvtitg3"], label[for="vlttinss3"], label[for="vltrdeit3"], label[for="vlsatait3"], label[for="vldivers3"], label[for="vlrepass3"], label[for="vlrfolha3"], label[for="vlnumera3"], label[for="vloutros3"], label[for="vlttcrdb3"]', '#frmFluxo');
	rTodosli4 = $('label[for="vlcheque4"], label[for="vltotdoc4"], label[for="vltotted4"], label[for="vltottit4"], label[for="vldevolu4"], label[for="vlmvtitg4"], label[for="vlttinss4"], label[for="vltrdeit4"], label[for="vlsatait4"], label[for="vldivers4"], label[for="vlrepass4"], label[for="vlrfolha4"], label[for="vlnumera4"], label[for="vloutros4"], label[for="vlttcrdb4"]', '#frmFluxo');
		
	rTodostit.css({'width':'150px'}).addClass('rotulo');
	rTodosli1.css({'width':'42px'}).addClass('rotulo-linha');
    rTodosli2.css({'width':'42px'}).addClass('rotulo-linha');
    rTodosli3.css({'width':'42px'}).addClass('rotulo-linha');
	rTodosli4.css({'width':'42px'}).addClass('rotulo-linha');
		
	// input
	cTodosli1 = $('#vlcheque1, #vltotdoc1, #vltotted1, #vltottit1, #vldevolu1, #vlmvtitg1, #vlttinss1, #vltrdeit1, #vlsatait1, #vldivers1, #vlrepass1, #vlrfolha1, #vlnumera1, #vloutros1, #vlttcrdb1', '#frmFluxo');
	cTodosli2 = $('#vlcheque2, #vltotdoc2, #vltotted2, #vltottit2, #vldevolu2, #vlmvtitg2, #vlttinss2, #vltrdeit2, #vlsatait2, #vldivers2, #vlrepass2, #vlrfolha2, #vlnumera2, #vloutros2, #vlttcrdb2', '#frmFluxo');
	cTodosli3 = $('#vlcheque3, #vltotdoc3, #vltotted3, #vltottit3, #vldevolu3, #vlmvtitg3, #vlttinss3, #vltrdeit3, #vlsatait3, #vldivers3, #vlrepass3, #vlrfolha3, #vlnumera3, #vloutros3, #vlttcrdb3', '#frmFluxo');
	cTodosli4 = $('#vlcheque4, #vltotdoc4, #vltotted4, #vltottit4, #vldevolu4, #vlmvtitg4, #vlttinss4, #vltrdeit4, #vlsatait4, #vldivers4, #vlrepass4, #vlrfolha4, #vlnumera4, #vloutros4, #vlttcrdb4', '#frmFluxo');
				
	cTodosli1.css({'width':'100px'}).addClass('moeda_15');
	cTodosli2.css({'width':'100px'}).addClass('moeda_15');
	cTodosli3.css({'width':'100px'}).addClass('moeda_15');
	cTodosli4.css({'width':'100px'}).addClass('moeda_15');
	
	cEntHabil = $('#vlrepass1, #vlrfolha1, #vlnumera1, #vloutros1, #vlrepass2, #vlrfolha2, #vlnumera2, #vloutros2, #vlrepass3, #vlrfolha3, #vlnumera3, #vloutros3, #vlrepass4, #vlrfolha4, #vlnumera4, #vloutros4', '#frmFluxo');
	cEntHabil.desabilitaCampo();	
	
	if ( $.browser.msie ) {
		rTodostit.css({'width':'150px'});	
	}	
	
	
	/********************
	  LAYOUT SAIDA
	*********************/
	rTodossai = $('label[for="vlcheque"] , label[for="vltotdoc"] , label[for="vltotted"] , label[for="vltottit"] , label[for="vldevolu"] , label[for="vlmvtitg"] , label[for="vlttinss"] , label[for="vltrdeit"] , label[for="vlsatait"] , label[for="vlfatbra"] , label[for="vlconven"] , label[for="vldivers"] , label[for="vlrepass"] , label[for="vlnumera"] , label[for="vlrfolha"] , label[for="vloutros"] , label[for="vlttcrdb"]', '#frmFluxo');
	rTodossd1 = $('label[for="vlcheque1"], label[for="vltotdoc1"], label[for="vltotted1"], label[for="vltottit1"], label[for="vldevolu1"], label[for="vlmvtitg1"], label[for="vlttinss1"], label[for="vltrdeit1"], label[for="vlsatait1"], label[for="vlfatbra1"], label[for="vlconven1"], label[for="vldivers1"], label[for="vlrepass1"], label[for="vlnumera1"], label[for="vlrfolha1"], label[for="vloutros1"], label[for="vlttcrdb1"]', '#frmFluxo');
	rTodossd2 = $('label[for="vlcheque2"], label[for="vltotdoc2"], label[for="vltotted2"], label[for="vltottit2"], label[for="vldevolu2"], label[for="vlmvtitg2"], label[for="vlttinss2"], label[for="vltrdeit2"], label[for="vlsatait2"], label[for="vlfatbra2"], label[for="vlconven2"], label[for="vldivers2"], label[for="vlrepass2"], label[for="vlnumera2"], label[for="vlrfolha2"], label[for="vloutros2"], label[for="vlttcrdb2"]', '#frmFluxo');
	rTodossd3 = $('label[for="vlcheque3"], label[for="vltotdoc3"], label[for="vltotted3"], label[for="vltottit3"], label[for="vldevolu3"], label[for="vlmvtitg3"], label[for="vlttinss3"], label[for="vltrdeit3"], label[for="vlsatait3"], label[for="vlfatbra3"], label[for="vlconven3"], label[for="vldivers3"], label[for="vlrepass3"], label[for="vlnumera3"], label[for="vlrfolha3"], label[for="vloutros3"], label[for="vlttcrdb3"]', '#frmFluxo');
	rTodossd4 = $('label[for="vlcheque4"], label[for="vltotdoc4"], label[for="vltotted4"], label[for="vltottit4"], label[for="vldevolu4"], label[for="vlmvtitg4"], label[for="vlttinss4"], label[for="vltrdeit4"], label[for="vlsatait4"], label[for="vlfatbra4"], label[for="vlconven4"], label[for="vldivers4"], label[for="vlrepass4"], label[for="vlnumera4"], label[for="vlrfolha4"], label[for="vloutros4"], label[for="vlttcrdb4"]', '#frmFluxo');
    	
	rTodossai.css({'width':'150px'}).addClass('rotulo');
	rTodossd1.css({'width':'42px'}).addClass('rotulo-linha');
    rTodossd2.css({'width':'42px'}).addClass('rotulo-linha');
    rTodossd3.css({'width':'42px'}).addClass('rotulo-linha');
	rTodossd4.css({'width':'42px'}).addClass('rotulo-linha');
		
	// input
	cTodossd1 = $('#vlcheque1, #vltotdoc1, #vltotted1, #vltottit1, #vldevolu1, #vlmvtitg1, #vlttinss1, #vltrdeit1, #vlsatait1, #vlfatbra1, #vlconven1, #vldivers1, #vlrepass1, #vlnumera1, #vlrfolha1, #vloutros1, #vlttcrdb1', '#frmFluxo');
	cTodossd2 = $('#vlcheque2, #vltotdoc2, #vltotted2, #vltottit2, #vldevolu2, #vlmvtitg2, #vlttinss2, #vltrdeit2, #vlsatait2, #vlfatbra2, #vlconven2, #vldivers2, #vlrepass2, #vlnumera2, #vlrfolha2, #vloutros2, #vlttcrdb2', '#frmFluxo');
	cTodossd3 = $('#vlcheque3, #vltotdoc3, #vltotted3, #vltottit3, #vldevolu3, #vlmvtitg3, #vlttinss3, #vltrdeit3, #vlsatait3, #vlfatbra3, #vlconven3, #vldivers3, #vlrepass3, #vlnumera3, #vlrfolha3, #vloutros3, #vlttcrdb3', '#frmFluxo');
	cTodossd4 = $('#vlcheque4, #vltotdoc4, #vltotted4, #vltottit4, #vldevolu4, #vlmvtitg4, #vlttinss4, #vltrdeit4, #vlsatait4, #vlfatbra4, #vlconven4, #vldivers4, #vlrepass4, #vlnumera4, #vlrfolha4, #vloutros4, #vlttcrdb4', '#frmFluxo');
		
	cTodossd1.css({'width':'100px'}).addClass('moeda_15');
	cTodossd2.css({'width':'100px'}).addClass('moeda_15');
	cTodossd3.css({'width':'100px'}).addClass('moeda_15');
	cTodossd4.css({'width':'100px'}).addClass('moeda_15');
		
	cSaiHabil = $('#vlrepass1, #vlnumera1, #vlrfolha1, #vloutros1, #vlrepass2, #vlnumera2, #vlrfolha2, #vloutros2, #vlrepass3, #vlnumera3, #vlrfolha3, #vloutros3, #vlrepass4, #vlnumera4, #vlrfolha4, #vloutros4','#frmFluxo');
	cSaiHabil.desabilitaCampo();
	
	if ( $.browser.msie ) {
		rTodossai.css({'width':'150px'});
	}
	
	/********************
	  LAYOUT RESULTADO
	*********************/
	rTodosrel = $('label[for="vlentrad"] , label[for="lbinvest"] , label[for="vlsaidas"] , label[for="vlresgat"] , label[for="vlresult"] , label[for="vlaplica"] , label[for="vlsldcta"] , label[for="vlsldfin"]', '#frmFluxo');	
	rTodosrel.css({'width':'180px'}).addClass('rotulo-linha');
	
	rVlentrad1 = $('label[for="vlentrad1"] , label[for="vlsaidas1"], label[for="vlresult1"]'); 
	rVlentrad1.css({'width':'15px'}).addClass('rotulo-linha');
	
	rVlentrad2 =  $('label[for="vlentrad2"] , label[for="vlsaidas2"], label[for="vlresult2"]'); 
	rVlentrad2.css({'width':'38px'}).addClass('rotulo-linha');

	rVlentrad2 =  $('label[for="vlentrad3"] , label[for="vlsaidas3"], label[for="vlresult3"]'); 
	rVlentrad2.css({'width':'47px'}).addClass('rotulo-linha');	
	
	rNmoperad = $('label[for="nmoperad"]', '#frmFluxo');
	rNmoperad.addClass('rotulo').css({'width':'182px'});
	
	rHrtransa = $('label[for="hrtransa"]', '#frmFluxo');
	rHrtransa.addClass('rotulo-linha').css({'width':'182px'});
	
	cTodosrel = $('#vlentrad, #vlentrad1, #vlentrad2, #vlentrad3, #vlsaidas, #vlsaidas1, #vlsaidas2, #vlsaidas3, #vlresgat, #vlresult, #vlresult1, #vlresult2, #vlresult3, #vlaplica, #vlsldcta, #vlsldfin', '#frmFluxo');
	cTodosrel.css({'width':'100px'}).addClass('moeda_15');	
	
	cVlresgat = $('#vlresgat','#frmFluxo');
	cVlaplica = $('#vlaplica','#frmFluxo');
	
	cRelHabil = $('#vlresgat, #vlaplica','#frmFluxo');
	cRelHabil.desabilitaCampo();
	
	cNmoperad = $('#nmoperad', '#frmFluxo');	
	cNmoperad.css({'width':'100px'});
	
	cHrtransa = $('#hrtransa', '#frmFluxo');
	cHrtransa.css({'width':'100px'});
		
	if ( $.browser.msie ) {
		
		rTodosrel.css({'width':'180px'});
		
	}
	
	
	//Se o valor de resgate for > 0, não será permitido incluir um valor para aplicação 
	cVlresgat.unbind('keypress').bind('keypress', function() {
		
		if( $(this).val() != 0 ){
			cVlaplica.desabilitaCampo();
			cVlaplica.val(0);
		}else{
			cVlaplica.habilitaCampo();
		}
		
	});	
		
	
	//Se o valor da aplicação for > 0, não será permitido incluir um valor para resgate
	cVlaplica.unbind('keypress').bind('keypress', function() {
		
		if( $(this).val() != 0 ){
			cVlresgat.desabilitaCampo();
			cVlresgat.val(0);
		}else{
			cVlresgat.habilitaCampo();
		}
				
	});
				
	layoutPadrao();
	return false;
	
}


// ativa campo do cabecalho conforme a opcao
function ativaCampoCabecalho() {

	trocaBotao('Prosseguir','btnContinuar()');
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
			
	} else if ( cddopcao == 'F' ) {
	
		if(cdcoplog == 3){
								
			if(cCdmovmto.val() != "A"){
							
				cCdcooper.habilitaCampo().show().focus(); 
				cDivmovmto.show();
				cDivagenci.hide();
				cCdcooper.html( slcooper );
				cDtmvtolt.habilitaCampo(); 
				cCdcooper.val( cdcoopex );	
				cDivcooper.show();
				
			}else{
				
				$('#divcooper').hide();
				cDivmovmto.show();
				cDivagenci.hide();
				cDtmvtolt.habilitaCampo().focus(); 
								
			}
			
		}else{
		
			cDivmovmto.show();
			cDivagenci.hide();
			cDivcooper.hide();
			cDtmvtolt.habilitaCampo(); 
				
		}
		
	} else if ( cddopcao == 'I' ) { 
	
		cDivmovmto.hide();
		cDivagenci.show();
		cDivcooper.hide();
		cCdcooper.desabilitaCampo().hide(); 
		cDtmvtolt.desabilitaCampo(); 
		cCdagenci.habilitaCampo().show().select();
	
	} else if ( cddopcao == 'L' ) {
	
   		cDivmovmto.hide();
		cDivagenci.hide();
		cDivcooper.show();
		cCdcooper.habilitaCampo().show(); 
		cCdcooper.html( slcoper2 );
		cDtmvtolt.habilitaCampo().focus(); 
		cCdagenci.desabilitaCampo().hide();
		cCdcooper.val( cdcoopex );
	
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


// ajuda
function formataMsgAjuda( tela ) {	
	
	var divMensagem = $('#divMsgAjuda', '#'+tela );
	/*divMensagem.css({'border':'1px solid #ddd','background-color':'#eee','padding':'2px','height':'20px','margin':'7px 0px'});*/
	
	var spanMensagem = $('span',divMensagem);
/*	spanMensagem.css({'text-align':'left','font-size':'11px','float':'left','padding':'3px'});*/

	var botoesMensagem = $('#divBotoes',divMensagem);
	botoesMensagem.css({'float':'center','padding':'0 0 0 2px', 'margin-top':'7px', 'margin-bottom':'5px'});		
	
	if ( $.browser.msie ) {
		spanMensagem.css({'padding':'5px 3px 3px 3px'});
		botoesMensagem.css({'margin-top':'2px'});		
	}
		
/*	spanMensagem.html('Tecle algo ou pressione F4 para sair!');*/
	/*
	$('input[type="text"],select').focus( function() {
		if ( $(this).hasClass('monetario') ) {
			spanMensagem.html('Tecle algo ou pressione F4 para sair!');
		}else if ( $(this).hasClass('moeda_15') ) {
			spanMensagem.html('Tecle algo ou pressione F4 para sair!');
		} else { 
			spanMensagem.html($(this).attr('alt'));
						
		}
	});	
			*/
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
			
		if(cddopcao == "F" && (dtmvtolt == cDtmvtolt.val())){
			verificaAcesso();
		}else{
			controlaOperacao();		
		}
						
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
		
	} else if ( cCdcooper.hasClass('campo') || cDtmvtolt.hasClass('campo') || cCdagenci.hasClass('campo') ) {
	
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


function validaHorario(){

	var mensagem = 'Aguarde, validando horário ...';
	
	showMsgAguardo( mensagem );	

	// Gera requisição ajax para validar horário limite para alteração de valores
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/previs/valida_horario.php', 
		data    : 
				{ 
					cddopcao    : cddopcao,
					cdmovmto	: cdmovmto,
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

function gravaDiversos(){

	var mensagem = 'Aguarde, gravando valores ...';
	var vlrepass = new Array();
	var vlnumera = new Array();
	var vlrfolha = new Array();
	var vloutros = new Array();
	var aux_vlrepass = new Object();
	var aux_vlnumera = new Object();
	var aux_vlrfolha = new Object();
	var aux_vloutros = new Object();
	 
		
	aux_vlrepass['85']  = $('#vlrepass1','#frmFluxo').val();
	aux_vlrepass['01']  = $('#vlrepass2','#frmFluxo').val();
	aux_vlrepass['756'] = $('#vlrepass3','#frmFluxo').val();
	aux_vlrepass['100'] = $('#vlrepass4','#frmFluxo').val();
	aux_vlnumera['85']  = $('#vlnumera1','#frmFluxo').val();	
	aux_vlnumera['01']  = $('#vlnumera2','#frmFluxo').val();	
	aux_vlnumera['756'] = $('#vlnumera3','#frmFluxo').val();	
	aux_vlnumera['100'] = $('#vlnumera4','#frmFluxo').val();	
	aux_vlrfolha['85']  = $('#vlrfolha1','#frmFluxo').val();	
	aux_vlrfolha['01']  = $('#vlrfolha2','#frmFluxo').val();	
	aux_vlrfolha['756'] = $('#vlrfolha3','#frmFluxo').val();	
	aux_vlrfolha['100'] = $('#vlrfolha4','#frmFluxo').val();	
	aux_vloutros['85']  = $('#vloutros1','#frmFluxo').val();	
	aux_vloutros['01']  = $('#vloutros2','#frmFluxo').val();	
	aux_vloutros['756'] = $('#vloutros3','#frmFluxo').val();	
	aux_vloutros['100'] = $('#vloutros4','#frmFluxo').val();
	
	
	vlrepass = aux_vlrepass;
	vlnumera = aux_vlnumera;
	vlrfolha = aux_vlrfolha;
	vloutros = aux_vloutros;
		
	showMsgAguardo( mensagem );	
		

	// Gera requisição ajax para gravar os valores diversos
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/previs/grava_diversos.php', 
		data    : 
				{ 
					cddopcao    : cddopcao,
					cdmovmto	: cdmovmto,
					vlrepass	: vlrepass,
					vlnumera	: vlnumera,
					vlrfolha	: vlrfolha,
					vloutros	: vloutros,
					dtmvtolx	: dtmvtolx,
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



function gravaApliResg(){

	var mensagem = 'Aguarde, gravando valores ...';
	var vlaplica = $('#vlaplica','#frmFluxo').val();
	var vlresgat = $('#vlresgat','#frmFluxo').val();
	
	showMsgAguardo( mensagem );	
	
	// Gera a requisição ajax para gravar o valor da aplicação/resgate
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/previs/grava_apli_resg.php', 
		data    : 
				{ 
					cddopcao    : cddopcao,
					dtmvtolx	: dtmvtolx,
					cdcoopex	: cdcoopex,
					vlresgat	: vlresgat,
					vlresgan	: vlresgan,
					vlaplica	: vlaplica,
					vlaplian	: vlaplian,
					cdmovmto	: cdmovmto,
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



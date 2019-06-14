/*!
 * FONTE        	: pesqdp.js
 * CRIAÇÃO      	: Gabriel Capoia (DB1) 
 * DATA CRIAÇÃO 	: 11/01/2013
 * OBJETIVO     	: Biblioteca de funções da tela PESQDP
 * ULTIMA ALTERAÇÃO : 06/06/2016
 * --------------
 * ALTERAÇÕES   	: 02/07/2013 - Inclusão da variável confirem (Confirma remoção da justificativa) e impressão da justificativa 8. (Reinert)
 *					  08/07/2013 - Alterado para receber o novo padrão de layout do Ayllos Web. (Reinert)
 *
 *					  26/04/2016 - Inclusão da LOV(List of Values) de justificativas conforme solicitado
 *								   no chamado 423093. (Kelvin)
 *
 *					  06/06/2016 - Limitando a quantidade de caracteres nos campos e desabilitando a lov 
 *								   caso não tenha dado dois clicks, conforme solicitado no chamado 461917 
 *								   (Kelvin)
 *
 * --------------
 */
 
 var nometela;

//Formulários e Tabela
var frmCab   		= 'frmCab';
var frmCheque   	= 'frmCheque';
var divCreditos   	= 'divCreditos';

var arrayJust   = new Array();

var divTabela;


var dtmvtola,   tipocons,   vlcheque,   nrcampo1,   nrcampo2,   nrcampo3,   dtmvtini,   dtmvtfim,
    cdbccxlt, 	dtmvtol2, 	tpdsaida, 	nrregist, 	nriniseq, 	rCddopcao, 	cCddopcao,  cTodosCabecalho,
	btnOK, cddopcao, dsdocmc7, cTodosConsulta, cTodosCheque;
	
var rDtmvtola, rTipocons, rVlcheque, rNrcampo1, rNrcampo2, rNrcampo3, cDtmvtola, cTipocons, cVlcheque,
	cNrcampo1, cNrcampo2, cNrcampo3, rDtmvtini, rDtmvtfim, rCdbccxlt, cDtmvtini, cDtmvtfim, cCdbccxlt,
	rCdagechq, rCdbccxlt, rDsdocmc7, rNrcheque, rNrctachq, rVlcheque, rCdcmpchq, rDsbccxlt, cCdagechq,
	cCdbccxlt, cDsdocmc7, cNrcheque, cNrctachq, cVlcheque, cCdcmpchq, cDsbccxlt;
	
var rOperacao, rCdagenca, rDtmvtola, cCddopcao, cOperacao, cCdagenca, cDtmvtola, cdoperad, aux_cdoperad, nrdrowid,
	cddopcao,  operacao,  cdagenca,  dtmvtola, cTodosCreditos, dtmvtoan, flextjus, aux_flextjus, cddjusti, dsdjusti,
	dsobserv, confirem;
	
$(document).ready(function() {
	divTabela		= $('#divTabela');
	estadoInicial();
	nrregist = 20;
		
	return false;
		
});

function carregaDados(){

	cddopcao = $('#cddopcao','#'+frmCab).val();	
	operacao = $('#operacao','#'+frmCab).val();
	cdagenca = $('#cdagenca','#'+frmCab).val();
	dtmvtola = $('#dtmvtola','#'+frmCab).val();
	
	cddopcao = ( typeof cddopcao == 'undefined' ) ? '' : cddopcao ;
	operacao = ( typeof operacao == 'undefined' ) ? '' : operacao ;
	
	dtmvtola = ( dtmvtola == '' ) ? '?' : dtmvtola;

	cddjusti = $('#cddjusti','#'+divCreditos).val();
	dsdjusti = $('#dsdjusti','#'+divCreditos).val();
	dsobserv = $('#dsobserv','#'+divCreditos).val();		
			
	return false;
}

// inicio
function estadoInicial() {

	$('#frmCab').fadeTo(0,0.1);
		
	$('#divTabela').html('');
	
	trocaBotao('Prosseguir');	
	formataCabecalho();
	
	$('input[type="text"],select','#'+frmCab).desabilitaCampo();
	$('#cddopcao','#'+frmCab).habilitaCampo().focus();
	
	$('#dtmvtola','#'+frmCab).val(dtmvtoan);
	$('#cdagenca','#'+frmCab).val('');
	
	removeOpacidade('frmCab');

	return false;
	
}

// formata
function formataCabecalho() {
		
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
		
	btnOK				= $('#btnOK','#'+frmCab);
	btnProsseguir		= $('#btSalvar','#divBotoes');
	
	//Cabecalho
	
	rCddopcao = $('label[for="cddopcao"]','#'+frmCab); 
	rOperacao = $('label[for="operacao"]','#'+frmCab);
	rCdagenca = $('label[for="cdagenca"]','#'+frmCab);
	rDtmvtola = $('label[for="dtmvtola"]','#'+frmCab);
	
	cCddopcao = $('#cddopcao','#'+frmCab); 
	cOperacao = $('#operacao','#'+frmCab); 
	cCdagenca = $('#cdagenca','#'+frmCab); 
	cDtmvtola = $('#dtmvtola','#'+frmCab); 
	
	rCddopcao.addClass('rotulo').css({'width':'60px'});
	rOperacao.css({'width':'70px'});
	rCdagenca.css({'width':'40px'});
	rDtmvtola.css({'width':'40px'});
	
	cCddopcao.css({'width':'120px'});
	cOperacao.css({'width':'80px' });
	cCdagenca.css({'width':'35px' });
	cDtmvtola.css({'width':'90px' }).addClass('data');
	
	cTodosCabecalho.habilitaCampo();
	
	$('#btVoltar','#divBotoes').hide();

	cCddopcao.unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
						
		// Se é a tecla ENTER
		if ( e.keyCode == 13) {
			
			btnContinuar();
			return false;
		
		}

	});

	cCdagenca.unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
						
		// Se é a tecla ENTER
		if ( e.keyCode == 13) {
			
			cDtmvtola.focus();
			return false;
		
		}

	});
	
	cDtmvtola.unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
						
		// Se é a tecla ENTER
		if ( e.keyCode == 13) {
			
			btnContinuar();
			return false;
		
		}

	});
			
	btnOK.unbind('click').bind('click', function() {
				
		if ( divError.css('display') == 'block' ) { return false; }		
			
			$('#btVoltar','#divBotoes').show();
			cTodosCabecalho.removeClass('campoErro');	
			cTodosCabecalho.habilitaCampo('campoErro');	
			cCddopcao.desabilitaCampo();
			cOperacao.desabilitaCampo();
			cCdagenca.focus();
				
		return false;
			
	});	
			
	highlightObjFocus( $('#frmCab') );
		
	layoutPadrao();
	
	cCddopcao.focus();	
		
	return false;	
}

// botoes
function btnVoltar() {
	estadoInicial();
	return false;
}

function btnContinuar() {

	$('#btVoltar','#divBotoes').show();
	if ( divError.css('display') == 'block' ) { return false; }		
	
	if ( cCddopcao.hasClass('campo') ) {
		btnOK.click();	
		
	} else {	
		if ( cCdagenca.hasClass('campo') ){	
			buscaDados(1);
		}else if( cCddopcao.val() == 'J' ){
			if ( flextjus == 'yes' ){
				controlaOperacao();
			}else if ( cCddjusti.hasClass('campo') ){
				showConfirmacao('Deseja incluir a justificativa?','Confirma&ccedil;&atilde;o - Ayllos','aux_cdoperad=cdoperad;if ($("#cddjusti","#"+divCreditos).val() == 8) {aux_flextjus ="no"}else{aux_flextjus ="yes"};confirem="N";manterRotina();','','sim.gif','nao.gif');
			}
		}	
	}
	
	return false;

}

function buscaDados(nriniseq) {
	
	showMsgAguardo('Aguarde, buscando Dados...');

	carregaDados();	
				
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/'+nometela+'/busca_dados.php', 
		data    :
				{ cddopcao  : cddopcao,
				  operacao  : operacao,
				  cdagenca  : cdagenca,
				  dtmvtola  : dtmvtola,				    
				  nrregist  : nrregist,
				  nriniseq  : nriniseq,
				  redirect: 'script_ajax'
				  
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','1 Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#tpChequ1\',\'#frmTipoCheque\').focus();');
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
							showError('error','2 N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#tpChequ1\',\'#frmTipoCheque\').focus();');
						}
					} else {
						try {
							eval( response );
						} catch(error) {
							hideMsgAguardo();
							showError('error','3 N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#tpChequ1\',\'#frmTipoCheque\').focus();');
						}
					}
					
				}
	}); 
	
	return false;
}

function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onClick="btnVoltar(); return false;" >Voltar</a>&nbsp;');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onClick="btnContinuar(); return false;" >'+botao+'</a>&nbsp;');
	
	return false;
}

function formataTabela() {
	
	var divRegistro = $('div.divRegistros', divTabela );	
	
	var tabela      = $('table', divRegistro );
	
	selecionaCreditos($('table > tbody > tr:eq(0)', divRegistro));

	divRegistro.css({'height':'207px','border-bottom':'1px dotted #777','padding-bottom':'2px'});	
	divTabela.css({'padding-top':'10px'});	
		
	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '80px';
	arrayLargura[1] = '250px';
	arrayLargura[2] = '50px';
	arrayLargura[3] = '80px';
	arrayLargura[4] = '100px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'left';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'right';	
	arrayAlinha[5] = 'left';	
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, 'controlaOperacao();' );
	
	$('table > tbody > tr', divRegistro).focus( function() {
		selecionaCreditos($(this));
	
	});
	
	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		selecionaCreditos($(this));

	});
	
	// remove ou inclui registro ao pressionar enter
	$('table > tbody > tr', divRegistro).unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
						
		if ( e.keyCode == 13) {
			
			controlaOperacao();
		
			return false;
		}

	});
	
	divTabela.css({'display':'block'});		
	
	$('input[type="text"],select','#'+frmCab).desabilitaCampo();
	
	formataDetalhe();
	//controlaOperacao();
	
	return false;
}

function controlaOperacao(){

	var operacao = $('#cddopcao','#'+frmCab).val(); 
	
	if ( operacao == 'C' ){ return false;}
	
	if ( flextjus == 'yes' ){ 
	
		//showConfirmacao('Deseja remover a justificativa?','Confirma&ccedil;&atilde;o - Ayllos','$("#divCreditos").limpaFormulario();aux_flextjus ="no";confirem="S";aux_cdoperad="";manterRotina();','','sim.gif','nao.gif');
		showConfirmacao('Deseja remover a justificativa?','Confirma&ccedil;&atilde;o - Ayllos','$("#frmTabela").limpaFormulario();aux_flextjus ="no";confirem="S";aux_cdoperad="";manterRotina();','','sim.gif','nao.gif');
	
	}else{
		$('#cddjusti','#'+divCreditos).habilitaCampo();
		$('#dsobserv','#'+divCreditos).habilitaCampo();
		$('#tbJustificativa','#divCreditos').attr('onClick','controlaPesquisa(1); return false;');
		$('#cddjusti','#'+divCreditos).focus();
	
	}	

	return false;
}

function buscaJustificativa(){

	var cod = $('#cddjusti','#'+divCreditos).val();
  
	if ( cod != 7 ){
		$('#dsdjusti','#'+divCreditos).val((typeof arrayJust[cod] == 'undefined' ) ? '' : arrayJust[cod] );
		$('#dsdjusti','#'+divCreditos).desabilitaCampo();
		$('#dsobserv','#'+divCreditos).focus();
		
	} else {
		$('#dsdjusti','#'+divCreditos).val('');
		$('#dsdjusti','#'+divCreditos).habilitaCampo();
		$('#dsdjusti','#'+divCreditos).focus();		
	}


	return false;
}

function formataDetalhe(){

	cTodosCreditos = $('input[type="text"],select','#'+divCreditos);
	
	rCddjusti = $('label[for="cddjusti"]','#'+divCreditos);
	rDsdjusti = $('label[for="dsdjusti"]','#'+divCreditos);
	rDsobserv = $('label[for="dsobserv"]','#'+divCreditos);
	
	cCddjusti = $('#cddjusti','#'+divCreditos);
	cDsdjusti = $('#dsdjusti','#'+divCreditos);
	cDsobserv = $('#dsobserv','#'+divCreditos);
	cTbJustificativa = $('#tbJustificativa','#'+divCreditos);
	
	rCddjusti.addClass('rotulo').css({'width':'120px'});
	rDsdjusti.css({'width':'5px'});
	rDsobserv.addClass('rotulo').css({'width':'120px'});
	
	cCddjusti.css({'width':'35px'});
	cDsdjusti.css({'width':'360px'});
	cDsobserv.css({'width':'403px'});
	
	//Não desabilita a tag <a> pois não é um type=text
	cTodosCreditos.desabilitaCampo();
	cTbJustificativa.removeAttr('onclick');
		
	layoutPadrao();
	
	highlightObjFocus($('#'+divCreditos));
	
	cCddjusti.unbind('keypress').bind('keypress', function(e) { 
		
		if ( divError.css('display') == 'block' ) { return false; }		
						
		// Se é a tecla ENTER
		if ( e.keyCode == 13) {
			
			if ($('#cddjusti','#'+divCreditos).val() == 7){
				cDsdjusti.focus();
			}else{
				cDsobserv.focus();
			}
			return false;
		
		}

	});
	
	cDsdjusti.unbind('keypress').bind('keypress', function(e) { 	
		
		if ( divError.css('display') == 'block' ) { return false; }		
						
		// Se é a tecla ENTER
		if ( e.keyCode == 13) {
			
			cDsobserv.focus();
		
			return false;
		}

	});
	
	cDsobserv.unbind('keypress').bind('keypress', function(e) {
		
		if ( divError.css('display') == 'block' ) { return false; }		
						
		// Se é a tecla ENTER
		if ( e.keyCode == 13) {
			
			btnContinuar();
		
			return false;
		}

	});
		
	return false;
}

function selecionaCreditos(tr){ 

	flextjus = $('#flextjus', tr ).val();
	nrdrowid = $('#nrdrowid', tr ).val();
		
	if ( flextjus == 'yes' || $('#cddjusti', tr ).val() == 8){
	
		$('#cddjusti','#'+divCreditos).val( $('#cddjusti', tr ).val() );
		$('#dsdjusti','#'+divCreditos).val( $('#dsdjusti', tr ).val() );
		$('#dsobserv','#'+divCreditos).val( $('#dsobserv', tr ).val() );	
	
	}else{
	
		$('#cddjusti','#'+divCreditos).val('');
		$('#dsdjusti','#'+divCreditos).val('');
		$('#dsobserv','#'+divCreditos).val('');	
	
	}
	
	return false;
}

function manterRotina() {
		
	hideMsgAguardo();		
	
	carregaDados();	
	
	var mensagem = '';
		
	showMsgAguardo( 'Aguarde, gravando dados ...' );	
	
	$.ajax({		
			type  : 'POST',
			url   : UrlSite + 'telas/'+nometela+'/manter_rotina.php', 		
			data: {
				flextjus	: aux_flextjus,
				cddjusti	: cddjusti,
				dsdjusti	: dsdjusti,
				dsobserv	: dsobserv,				
				nrdrowid	: nrdrowid,				
				cdoperad    : aux_cdoperad,				
				confirem	: confirem,
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

function controlaPesquisa(param) {
	if(param == 1) {
		if(cddopcao != "C") {
			mostraJustificativa();
		}
	}
}

//mostra a tabela de justificativas
function mostraJustificativa() {
	showMsgAguardo('Aguarde, buscando ...');

	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cldpac/lista_justificativa.php', 
		data: { redirect: 'html_ajax' }, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			buscaJustificativas("modal");
			return false;
		}				
	});
	
	return false;
}

/*tabela de justificativas -- Opção J*/
function buscaJustificativas(tipo) {
	showMsgAguardo('Aguarde, buscando ...');
	
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cldpac/carrega_justificativas.php', 
		data: { cddjusti: cddjusti,
         		tipoBusca: tipo,
				cddopcao: cddopcao,
		     	redirect: 'script_ajax' }, 
		error: function(objAjax,responseError,objExcept) {
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					if(tipo == "modal") {
						$('#divConteudo').html(response);
						exibeRotina($('#divRotina'));
						formataJustificativa();
						return false;
					} else if(tipo == "pesquisa") {
						eval(response);
						hideMsgAguardo();
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
		}				
	});
	return false;
}

function formataJustificativa() {
	var divRegistro = $('div.divRegistros','#divJustificativas');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'120px','width':'545px'});
	
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];	
	
	var arrayLargura = new Array();
	arrayLargura[0] = '100px';
	arrayLargura[1] = '445px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'left';
	
	var metodoTabela = 'selecionaJustificativa();';
			
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );
	
	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	
	return false;
}

function selecionaJustificativa() {
	cDsdjusti = $('#dsdjusti','#'+divCreditos);
	cCddjusti = $('#cddjusti','#'+divCreditos);
	
	if ( $('table > tbody > tr', 'div#divJustificativas div.divRegistros').hasClass('corSelecao') ) {
		$('table > tbody > tr', 'div#divJustificativas div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				cCddjusti.val($('#hcddjusti', $(this)).val());

				if($('#hcddjusti', $(this)).val() != 7) {
					cDsdjusti.val($('#hdsdjusti', $(this)).val());
					cDsdjusti.desabilitaCampo();
				} else if($('#hcddjusti', $(this)).val() == 7) {
					cDsdjusti.val('');
					cDsdjusti.habilitaCampo();
					cDsdjusti.focus();
				}
			}
		});
	}
	
	fechaRotina($('#divRotina'));
	return false;
}

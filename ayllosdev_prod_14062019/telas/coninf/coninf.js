/*!
 * FONTE        : coninf.js
 * CRIAÇÃO      : Gabriel Capoia (DB1) 
 * DATA CRIAÇÃO : 29/11/2012
 * OBJETIVO     : Biblioteca de funções da tela CONINF
 * --------------
 * ALTERAÇÕES   :
 *
 * --------------
 */

//Formulários e Tabela
var frmCab   		= 'frmCab';
var frmLocal   		= 'frmLocal';
var tabDados		= 'tabConinf';
var divTabela;
var dsdircop;

var cdcooper,	dsiduser, 	cdcoopea, 	cdagenca, 	tpdocmto, 	indespac, 	cdfornec, 	dtmvtol1,
 	dtmvtol2, 	tpdsaida, 	nrregist, 	nriniseq, 	rCddopcao, rNrdrelat, rCdagenca, 
	cCddopcao, cNrdrelat, cCdagenca, cTodosCabecalho, btnOK,
	rCdcoopea, rDtmvtola, rDtmvtol2, rCdagenca, rTpdocmto, rIndespac, rCdfornec, rTpdsaida,
	cCdcoopea, cDtmvtola, cDtmvtol2, cCdagenca, cTpdocmto, cIndespac, cCdfornec, cTpdsaida;

var flgvepac 		= '';
var arrayConinf		= new Array();

var nrJanelas		= 0;
	
$(document).ready(function() {
	controlaOperacao('');		
	divTabela		= $('#divTabela');
	estadoInicial();
	nrregist = 20;
	
	return false;
		
});

function carregaDados(){

	cdcoopea = $('#cdcoopea','#'+frmCab).val(); 
	cdagenca = $('#cdagenca','#'+frmCab).val();
	tpdocmto = $('#tpdocmto','#'+frmCab).val();
	indespac = $('#indespac','#'+frmCab).val();
	cdfornec = $('#cdfornec','#'+frmCab).val();
	dtmvtol1 = $('#dtmvtol1','#'+frmCab).val();
	dtmvtol2 = $('#dtmvtol2','#'+frmCab).val();
	tpdsaida = $('#tpdsaida','#'+frmCab).val();
	
	cdcoopea = ( typeof cdcoopea == 'undefined' ) ? '' : cdcoopea ;
	tpdocmto = ( typeof tpdocmto == 'undefined' ) ? '' : tpdocmto ;
	
	dtmvtol1 = ( dtmvtol1 == '' ) ? '?' : dtmvtol1;
	dtmvtol2 = ( dtmvtol2 == '' ) ? '?' : dtmvtol2;
		
	return false;
}

// inicio
function estadoInicial() {

	$('#frmCab').fadeTo(0,0.1);
	
	$('#'+frmCab).limpaFormulario();
	
	// arrayImprel = new Array();
	
	$('#divTabela').html('');
	
	trocaBotao('Prosseguir');	
	formataCabecalho();
	
	removeOpacidade('frmCab');

	return false;
	
}

// controle
function controlaOperacao(cddopcao) {
	
	var mensagem = 'Aguarde, buscando dados ...';
	
	showMsgAguardo( mensagem );	
	
	carregaDados();
	
	// Carrega dados da conta através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/coninf/principal.php', 
		data    : 
				{ 
					cddopcao	: cddopcao,
					dsiduser	: dsiduser,
					cdcoopea	: cdcoopea,
					cdagenca    : cdagenca,
					tpdocmto    : tpdocmto,
					indespac    : indespac,
					cdfornec    : cdfornec,
					dtmvtol1    : dtmvtol1,
					dtmvtol2    : dtmvtol2,
					tpdsaida    : tpdsaida,
					nrregist    : nrregist,
					nriniseq    : nriniseq,
					
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
	rCdcoopea = $('label[for="cdcoopea"]','#'+frmCab); 
	rDtmvtola = $('label[for="dtmvtol1"]','#'+frmCab); 
	rDtmvtol2 = $('label[for="dtmvtol2"]','#'+frmCab); 
	rCdagenca = $('label[for="cdagenca"]','#'+frmCab); 
	rTpdocmto = $('label[for="tpdocmto"]','#'+frmCab); 
	rIndespac = $('label[for="indespac"]','#'+frmCab); 
	rCdfornec = $('label[for="cdfornec"]','#'+frmCab); 
	rTpdsaida = $('label[for="tpdsaida"]','#'+frmCab); 
	
	cCdcoopea = $('#cdcoopea','#'+frmCab); 
	cDtmvtola = $('#dtmvtol1','#'+frmCab); 
	cDtmvtol2 = $('#dtmvtol2','#'+frmCab); 
	cCdagenca = $('#cdagenca','#'+frmCab); 
	cTpdocmto = $('#tpdocmto','#'+frmCab); 
	cIndespac = $('#indespac','#'+frmCab); 
	cCdfornec = $('#cdfornec','#'+frmCab); 
	cTpdsaida = $('#tpdsaida','#'+frmCab); 
	
	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab); 
	rNrdrelat	        = $('label[for="nrdrelat"]','#'+frmCab);        
	rCdagenca	        = $('label[for="cdagenca"]','#'+frmCab);        
	
	cCddopcao			= $('#cddopcao','#'+frmCab); 
	cNrdrelat			= $('#nrdrelat','#'+frmCab); 
	cCdagenca			= $('#cdagenca','#'+frmCab); 
	
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	btnOK				= $('#btnOK','#'+frmCab);
	btnProsseguir		= $('#btSalvar','#divBotoes');
	
	//Label
	rCdcoopea.addClass('rotulo').css({'width':'105px'});
	rDtmvtola.addClass('rotulo-linha').css({'width':'63px'});
	rDtmvtol2.addClass('rotulo-linha').css({'width':'14px','padding-right':'6px'});
	rCdagenca.addClass('rotulo').css({'width':'105px'});
	rTpdocmto.addClass('rotulo-linha').css({'width':'212px'});
	rIndespac.addClass('rotulo').css({'width':'105px'});
	rCdfornec.addClass('rotulo-linha').css({'width':'147px'});
	rTpdsaida.addClass('rotulo-linha').css({'width':'40px'});
	
	//Campos
	cCdcoopea.css({'width':'150px'});
	cDtmvtola.css({'width':'92px'}).addClass('data');
	cDtmvtol2.css({'width':'92px'}).addClass('data');
	cCdagenca.css({'width':'35px'});
	cTpdocmto.css({'width':'210px'});
	cIndespac.css({'width':'100px'});
	cCdfornec.css({'width':'100px'});
	cTpdsaida.css({'width':'65px'});

	
	if ( cdcooper == 3){
		cTodosCabecalho.desabilitaCampo();
		cCdcoopea.habilitaCampo();
		cCdcoopea.val(cdcooper);
		cCdcoopea.focus();
		
	}else{
		cTodosCabecalho.habilitaCampo();
		cCdcoopea.desabilitaCampo();		
		cCdcoopea.val(cdcooper);		
		cDtmvtola.focus();
	}
	
	highlightObjFocus( $('#frmCab') );
	
	// Se clicar no botao OK
	btnOK.unbind('click').bind('click', function() {
				
		if ( divError.css('display') == 'block' ) { return false; }		
		if ( cCdcoopea.hasClass('campoTelaSemBorda')  ) { return false; }		
		
		cTodosCabecalho.removeClass('campoErro');	
		
		// Se chegou até aqui, a conta é diferente do vazio e é válida, então realizar a operação desejada			
		cTodosCabecalho.habilitaCampo();
		cCdcoopea.desabilitaCampo();		
		cDtmvtola.focus();
		
		return false;
			
	});	
	
	
	cCdcoopea.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		

		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			btnOK.click();			
			return false;
		} 
	});	
			
	
	layoutPadrao();
	return false;	
}

function controlaLayout() {

	cTodosCabecalho.desabilitaCampo();
	cNrdrelat.habilitaCampo();
	cNrdrelat.focus();
	return false;
}

// imprimir
function Gera_Impressao() {				
	
	var action = UrlSite + 'telas/imprel/imprimir_dados.php';	
		
	cTodosCabecalho.habilitaCampo();		
	
	carregaImpressaoAyllos(frmCab,action,"estadoInicial();");
	
}

// botoes
function btnVoltar() {
	estadoInicial();
	return false;
}

function btnContinuar() {

	if ( divError.css('display') == 'block' ) { return false; }		
	
	if ( cCdcoopea.hasClass('campo') ) {
		btnOK.click();	
		
	} else if ( cTpdsaida.val() == "A"  ) {		
		buscaLocal();	
	} else if ( cTpdsaida.val() == "T"  ) {
		buscaInformativo(1);
	}
	
	return false;

}

function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onClick="btnVoltar(); return false;" >Voltar</a>&nbsp;');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onClick="btnContinuar(); return false;" >'+botao+'</a>&nbsp;');
	
	return false;
}

function buscaInformativo(nriniseq) {
	
	showMsgAguardo('Aguarde, buscando Informativos...');

	carregaDados();
			
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/coninf/busca_informativo.php', 
		data    :
				{ dsiduser	: dsiduser,
				cdcoopea	: cdcoopea,
				cdagenca    : cdagenca,
				tpdocmto    : tpdocmto,
				indespac    : indespac,
				cdfornec    : cdfornec,
				dtmvtol1    : dtmvtol1,
				dtmvtol2    : dtmvtol2,
				tpdsaida    : tpdsaida,
				nrregist    : nrregist,
				nriniseq    : nriniseq,
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

	divRegistro.css({'height':'207px','border-bottom':'1px dotted #777','padding-bottom':'2px'});
	//divTabela.css({'border':'1px solid #777','border-top':'none'});	
		
	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '45px';
	arrayLargura[1] = '65px';
	arrayLargura[2] = '35px';
	arrayLargura[3] = '235px';
	arrayLargura[4] = '35px';
	arrayLargura[5] = '70px';
	

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'center';
	arrayAlinha[3] = 'left';
	arrayAlinha[4] = 'center';
	arrayAlinha[5] = 'left';
	arrayAlinha[6] = 'left';	
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, 'trocaVisao();' );
	
	divTabela.css({'display':'block'});	
	
	cTodosCabecalho.desabilitaCampo();
	
	return false;
}

function buscaLocal() {

	hideMsgAguardo();		
		
	showMsgAguardo('Aguarde, abrindo ...');

	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/coninf/arquivo.php', 
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
	buscaInformativo(0);

	return false;
}
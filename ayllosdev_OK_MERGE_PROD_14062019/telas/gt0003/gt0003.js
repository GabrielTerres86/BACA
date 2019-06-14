/*!
 * FONTE        : gt0003.js
 * CRIAÇÃO      : Jéssica (DB1) 
 * DATA CRIAÇÃO : 20/09/2013
 * OBJETIVO     : Biblioteca de funções da tela GT0003
 * --------------
 * ALTERAÇÕES   :
 *
 * --------------
 */
 
 var nometela;

//Formulários e Tabela
var frmCab   	 = 'frmCab';
var frmConsulta  = 'frmConsulta';
var frmRelatorio = 'frmRelatorio';
var frmTotais    = 'frmTotais';
var divTabela;

var aux_data, aux_coop, aux_conv, dtmvtoan;

var cddopcao, dtmvtolt, cdcooper, nmrescop, cdcopdom, cdconven, nrcnvfbr, nmempres, dtcredit, 
	nmarquiv, qtdoctos, vldoctos, vltarifa, vlapagar, nrsequen, nriniseq, nrregist, tiporel,
	dtinici,  dtfinal,  totqtdoc, totvldoc, tottarif, totpagar,
    cTodosCabecalho, btnOK, cTodosConsulta;

var rCddopcao, rDtmvtolt, rCdcooper, rNmrescop, rCdcopdom, rCdconven, rNrcnvfbr, rNmempres,
	rDtcredit, rNmarquiv, rQtdoctos, rVldoctos, rVltarifa, rVlapagar, rNrsequen, rTiporel,
	rDtinici,  rDtfinal,  rTotqtdoc, rTotvldoc, rTottarif, rTotpagar,
	cCddopcao, cDtmvtolt, cCdcooper, cNmrescop, cCdcopdom, cCdconven, cNrcnvfbr, cNmempres,
	cDtcredit, cNmarquiv, cQtdoctos, cVldoctos, cVltarifa, cVlapagar, cNrsequen, cTiporel,
	cDtinici,  cDtfinal,  cTotqtdoc, cTotvldoc, cTottarif, cTotpagar; 

$(document).ready(function() {
	divTabela		= $('#divTabela');
	estadoInicial();
	nrregist = 50;

	$('#divBotoes','#divTela').css({'display':'none'});
	$('#divBotoesConsulta','#divTela').css({'display':'none'});
	
	$('#cddopcao','#'+frmCab).focus();

	return false;
		
});

function carregaDados(){
	
	cddopcao = $('#cddopcao','#'+frmCab).val();
	dtmvtolt = $('#dtmvtolt','#'+frmConsulta).val();
	cdcooper = $('#cdcooper','#'+frmConsulta).val();
	cdconven = $('#cdconven','#'+frmConsulta).val();
			
	return false;
} //carregaDados

// inicio
function estadoInicial() {

	$('#frmCab').fadeTo(0,0.1);
		
	$('#divTabela').html('');
		
	formataCabecalho();
	formataConsulta();
	formataRelatorio();
	
	$('#dtmvtolt','#'+frmConsulta).val(dtmvtoan);
	$('#dtinici','#'+frmRelatorio).val(dtmvtoan);
	$('#dtfinal','#'+frmRelatorio).val(dtmvtoan);
		
	removeOpacidade('frmCab');
	
	
	cDtmvtolt.unbind('keypress').bind('keypress', function(e) {
		// Se é a tecla ENTER
		if (e.keyCode == 13) {
			$('#cdcooper','#divConsulta').focus();
			return false;
		}
	});
	
	$('#cdcooper','#divConsulta').unbind('keypress').bind('keypress', function(e) {
		// Se é a tecla ENTER
		if (e.keyCode == 13) {
			$('#cdconven','#divConsulta').focus();
			return false;
		}
	});
	
	$('#cdconven','#divConsulta').unbind('keypress').bind('keypress', function(e) {
		// Se é a tecla ENTER
		if (e.keyCode == 13) {
			btnContinuar();
			return false;
		}
	});
	
	$('#cddopcao','#'+frmCab).focus();
	
	return false;
	
}

// formata
function formataCabecalho() {

	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);

	btnOK				= $('#btnOK','#'+frmCab);	

	//Cabecalho

	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab);	
	cCddopcao			= $('#cddopcao','#'+frmCab);

	cTodosCabecalho.habilitaCampo();

	rCddopcao.addClass('rotulo').css({'width':'55px'});
	cCddopcao.css({'width':'510px'});

	btnOK.unbind('click').bind('click', function() {

		if ( divError.css('display') == 'block' ) { return false; }		

		cTodosCabecalho.removeClass('campoErro');
		cCddopcao.desabilitaCampo();		

		controlaLayout();
		
		$('#divBotoesConsulta').css('display', 'block');        
	});
	
	cCddopcao.unbind('keypress').bind('keypress', function(e) {
		// Se é a tecla ENTER
		if (e.keyCode == 13) {
			btnOK.click();
			return false;
		}
	});
	

	$('#frmConsulta').css('display','none');
	$('#frmRelatorio').css('display','none');
	$('#frmTotais').css('display','none');
		
	highlightObjFocus( $('#frmCab') );
	highlightObjFocus( $('#frmConsulta') );
	highlightObjFocus( $('#frmRelatorio') );
	highlightObjFocus( $('#frmTotais') );

	cCdcooper = $('#cdcooper','#divConsulta');
	cCdconven = $('#cdconven','#divConsulta');	
	cCdcooper.addClass('inteiro');
	cCdconven.addClass('inteiro');
	
	layoutPadrao();
	
	cCddopcao.focus();	
		
	return false;	
}

function controlaLayout() {

	if( cCddopcao.val() == "C" ){

		$('#frmConsulta').css('display','block');

		cTodosConsulta.desabilitaCampo();		
		
        cDtmvtolt = $('#dtmvtolt','#divConsulta');
		cCdcooper = $('#cdcooper','#divConsulta');
		cCdconven = $('#cdconven','#divConsulta');

		habilitaConsulta();
		
		cCdcooper.addClass('inteiro');
		cCdconven.addClass('inteiro');
		
		layoutPadrao();
		cDtmvtolt.focus();
	
	} else {

		$('#divBotoesConsulta').css('display', 'none');

		$('#frmRelatorio').css('display','block');

		cTodosRelatorio.habilitaCampo();

		cTiporel.focus();
	}

	return false;
}

//botoes
function btnVoltar(op) {

	cTodosConsulta.removeClass('campoErro');

    switch (op) {

        case 1: // volta para opcao
			$('#frmConsulta').limpaFormulario();
			$('#frmRelatorio').limpaFormulario();
			$('#frmTotais').limpaFormulario();			
			
			$('#divBotoes','#divTela').css({'display':'none'});
            $('#divBotoesConsulta','#divTela').css({'display':'none'});
			
			estadoInicial();
        break;

        case 2: // volta para filtro
            $('#frmConsulta').limpaFormulario();
			$('#frmRelatorio').limpaFormulario();
			$('#frmTotais').limpaFormulario();

			habilitaConsulta();
			
			$('#divBotoes','#divTela').css({'display':'none'});
			
			$('#divBotoesConsulta','#divTela').css({'display':'block'});

			$('#divTabela').html('');
			$('#dtmvtolt','#'+frmConsulta).val(dtmvtolt);
			
			cDtmvtolt.focus();
        break;
    }
}

function btnContinuar() {

	if ( divError.css('display') == 'block' ) { return false; }		
    
	$('#divBotoesConsulta','#divTela').css({'display':'none'});	
	
	if ( cCddopcao.hasClass('campo') ) {
		btnOK.click();
		
	} else if(cCddopcao.val() == "C") {

		buscaGt0003(1,true);
		
		cDtmvtolt.desabilitaCampo();
		cCdcooper.desabilitaCampo();
		cCdconven.desabilitaCampo();
	
	} else if(cCddopcao.val() == "R") {
		
		$('#cdcooper', '#frmRelatorio').desabilitaCampo();
		$('#tiporel', '#frmRelatorio').desabilitaCampo();
		$('#dtinici', '#frmRelatorio').desabilitaCampo();
		$('#dtfinal', '#frmRelatorio').desabilitaCampo();
		$('#divBotoesConsulta','#divTela').css({'display':'none'});

		geraRelatorio();		
	}

				
	return false;

}

function buscaGt0003(nriniseq,aux_consulta ) {

	showMsgAguardo('Aguarde, buscando Dados...');

	carregaDados();

	$('#dtmvtolt', '#frmConsulta').removeClass('campoErro');
    $('#cdcooper', '#frmConsulta').removeClass('campoErro');
	$('#cdconven', '#frmConsulta').removeClass('campoErro');
	
	
	if ( aux_consulta ){		
		aux_data = dtmvtolt;
		aux_coop = cdcooper;
		aux_conv = cdconven;
	}else{
		dtmvtolt = aux_data;
		cdcooper = aux_coop;
		cdconven = aux_conv;	
	}

	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/'+nometela+'/busca_gt0003.php', 
		data    :
				{ 
				  cddopcao  : cddopcao,
				  dtmvtolt  : dtmvtolt,	
				  cdcooper  : cdcooper,
				  cdconven  : cdconven,
				  nrregist  : nrregist,
				  nriniseq  : nriniseq,
				  redirect: 'script_ajax'
				  
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
				},
		success : function(response) { 
					hideMsgAguardo();
					
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							$('#divTabela').html(response);	
							$('#btVoltar','#divBotoes').focus();
							$('#btSalvar','#divBotoes').css({'display':'none'});
							
							return false;
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
						}
					} else {
						try {
							eval( response );
							$('#divBotoesConsulta','#divTela').css({'display':'block'});
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
						}
					}
					
				}
	}); 
}


function Gera_Impressao(nmarqpdf, callback) {

    hideMsgAguardo();

    var action = UrlSite + 'telas/'+nometela+'/imprimir_pdf.php';

    $('#nmarqpdf', '#frmRelatorio').remove();
    $('#sidlogin', '#frmRelatorio').remove();

    $('#frmRelatorio').append('<input type="hidden" id="nmarqpdf" name="nmarqpdf" value="' + nmarqpdf + '" />');
    $('#frmRelatorio').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin', '#frmMenu').val() + '" />');

    carregaImpressaoAyllos("frmRelatorio", action, callback);

}

function geraRelatorio() {
	//Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, solicitando relatório...');
	
	var cdcooper = $('#cdcooper', '#frmRelatorio').val();
	var tiporel  = $('#tiporel', '#frmRelatorio').val();
	var dtinici  = $('#dtinici', '#frmRelatorio').val();
	var dtfinal  = $('#dtfinal', '#frmRelatorio').val();
	var cddopcao = $('#cddopcao', '#frmCab').val();
	
    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/'+nometela+'/imprimir_dados.php',
        data: {
			cdcooper: cdcooper,
			tiporel:  tiporel,
			dtinici:  dtinici,
			dtfinal:  dtfinal,			
            cddopcao: cddopcao,
            redirect: 'html_ajax' // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#tiporel','#frmRelatorio').focus();");
			$('#divBotoesConsulta','#divTela').css({'display':'block'});
        },
        success: function (response) {
            hideMsgAguardo();
            try {
                eval(response);
				$('#divBotoesConsulta','#divTela').css({'display':'block'});
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground();$("#tiporel","#frmRelatorio").focus();');
				$('#divBotoesConsulta','#divTela').css({'display':'block'});
            }

        }
    });	

	return false;

}

function formataTabela() {

	var divRegistro = $('div.divRegistros', divTabela );	
	
	var tabela      = $('table', divRegistro );
	
	selecionaConvenio($('table > tbody > tr:eq(0)', divRegistro));
	
	divRegistro.css({'height':'207px','border-bottom':'1px dotted #777','padding-bottom':'2px'});	
	divTabela.css({'padding-top':'10px'});	
		
	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '60px';
	arrayLargura[1] = '60px';
	arrayLargura[2] = '60px';
	arrayLargura[3] = '60px';
	arrayLargura[4] = '60px';
	arrayLargura[5] = '60px';
	arrayLargura[6] = '60px';
	arrayLargura[7] = '60px';
			
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'center';
	arrayAlinha[3] = 'center';	
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'right';
	arrayAlinha[6] = 'right';
	arrayAlinha[7] = 'right';
	arrayAlinha[8] = 'right';
	
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	
	$('table > tbody > tr', divRegistro).focus( function() {
		selecionaConvenio($(this));
	
	});
	
	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		selecionaConvenio($(this));

	});	
			
	divTabela.css({'display':'block'});	
	
	formataTotais();
	
	return false;
}

function selecionaConvenio(tr){ 

	$('#dtmvtolt','#frmConsulta').val( $('#dtmvtolt', tr ).val() );
	$('#cdcooper','#frmConsulta').val( $('#cdcooper', tr ).val() );
	$('#nmrescop','#frmConsulta').val( $('#nmrescop', tr ).val() );
	$('#cdcopdom','#frmConsulta').val( $('#cdcopdom', tr ).val() );
	$('#cdconven','#frmConsulta').val( $('#cdconven', tr ).val() );
	$('#nrcnvfbr','#frmConsulta').val( $('#nrcnvfbr', tr ).val() );
	$('#nmempres','#frmConsulta').val( $('#nmempres', tr ).val() );
	$('#dtcredit','#frmConsulta').val( $('#dtcredit', tr ).val() );
	$('#nmarquiv','#frmConsulta').val( $('#nmarquiv', tr ).val() );
	$('#qtdoctos','#frmConsulta').val( $('#qtdoctos', tr ).val() );
	$('#vldoctos','#frmConsulta').val( $('#vldoctos', tr ).val() );
	$('#vltarifa','#frmConsulta').val( $('#vltarifa', tr ).val() );
	$('#vlapagar','#frmConsulta').val( $('#vlapagar', tr ).val() );
	$('#nrsequen','#frmConsulta').val( $('#nrsequen', tr ).val() );
		
	return false;
}

function habilitaConsulta() {    
	cDtmvtolt.habilitaCampo();
	cCdcooper.habilitaCampo();
	cCdconven.habilitaCampo();	
}

function formataConsulta(){

	cTodosConsulta = $('input[type="text"],select','#divConsulta');
	
	rDtmvtolt = $('label[for="dtmvtolt"]','#divConsulta');
	rCdcooper = $('label[for="cdcooper"]','#divConsulta');
	rNmrescop = $('label[for="nmrescop"]','#divConsulta');
	rCdcopdom = $('label[for="cdcopdom"]','#divConsulta');
	rCdconven = $('label[for="cdconven"]','#divConsulta');
	rNrcnvfbr = $('label[for="nrcnvfbr"]','#divConsulta');
	rNmempres = $('label[for="nmempres"]','#divConsulta');
	rDtcredit = $('label[for="dtcredit"]','#divConsulta');
	rNmarquiv = $('label[for="nmarquiv"]','#divConsulta');
	rQtdoctos = $('label[for="qtdoctos"]','#divConsulta');
	rVldoctos = $('label[for="vldoctos"]','#divConsulta');
	rVltarifa = $('label[for="vltarifa"]','#divConsulta');
	rVlapagar = $('label[for="vlapagar"]','#divConsulta');
	rNrsequen = $('label[for="nrsequen"]','#divConsulta');
	
		
	cDtmvtolt = $('#dtmvtolt','#divConsulta');	
	cCdcooper = $('#cdcooper','#divConsulta');	
	cNmrescop = $('#nmrescop','#divConsulta');	
	cCdcopdom = $('#cdcopdom','#divConsulta');
	cCdconven = $('#cdconven','#divConsulta');
	cNrcnvfbr = $('#nrcnvfbr','#divConsulta');
	cNmempres = $('#nmempres','#divConsulta');
	cDtcredit = $('#dtcredit','#divConsulta');
	cNmarquiv = $('#nmarquiv','#divConsulta');
	cQtdoctos = $('#qtdoctos','#divConsulta');
	cVldoctos = $('#vldoctos','#divConsulta');
	cVltarifa = $('#vltarifa','#divConsulta');
	cVlapagar = $('#vlapagar','#divConsulta');
	cNrsequen = $('#nrsequen','#divConsulta');
	
	
	rDtmvtolt.css({'width':'125px'});
	rCdcooper.css({'width':'125px'});
	rNmrescop.css({'width':'110px'});
	rCdcopdom.css({'width':'125px'});
	rCdconven.css({'width':'125px'});
	rNrcnvfbr.css({'width':'110px'});
	rNmempres.css({'width':'150px'});
	rDtcredit.css({'width':'75px'});
	rNmarquiv.css({'width':'125px'});
	rQtdoctos.css({'width':'164px'});
	rVldoctos.css({'width':'125px'});
	rVltarifa.css({'width':'164px'});
	rVlapagar.css({'width':'125px'});
	rNrsequen.css({'width':'164px'});
	
	cDtmvtolt.css({'width':'80px'}).addClass('data');
	cCdcooper.css({'width':'80px'});
	cNmrescop.css({'width':'294px'});
	cCdcopdom.css({'width':'80px'});
	cCdconven.css({'width':'40px'});
	cNrcnvfbr.css({'width':'136px'});
	cNmempres.css({'width':'294px'});
	cDtcredit.css({'width':'80px'});
	cNmarquiv.css({'width':'160px'});
	cQtdoctos.css({'width':'160px'});
	cVldoctos.css({'width':'160px'}).addClass('moeda');
	cVltarifa.css({'width':'160px'}).addClass('moeda');
	cVlapagar.css({'width':'160px'}).addClass('moeda');
	cNrsequen.css({'width':'90px'});
	
	cCdcooper.addClass('inteiro');
	cCdconven.addClass('inteiro');
	
	cTodosConsulta.habilitaCampo();
		
	layoutPadrao();

	return false;
}

function formataRelatorio(){

	cTodosRelatorio = $('input[type="text"],select','#divRelatorio');
	
	rTiporel  = $('label[for="tiporel"]','#divRelatorio');
	rCdcooper = $('label[for="cdcooper"]','#divRelatorio');
	rDtinici  = $('label[for="dtinici"]','#divRelatorio');
	rDtfinal  = $('label[for="dtfinal"]','#divRelatorio');
		
		
	cTiporel  = $('#tiporel','#divRelatorio');	
	cCdcooper = $('#cdcooper','#divRelatorio');	
	cDtinici  = $('#dtinici','#divRelatorio');	
	cDtfinal  = $('#dtfinal','#divRelatorio');
	
	
	rTiporel.css({'width':'30px'});
	rCdcooper.css({'width':'70px'});
	rDtinici.css({'width':'70px'});
	rDtfinal.css({'width':'70px'});
	
	
	cTiporel.css({'width':'95px'});
	cCdcooper.css({'width':'80px'});
	cDtinici.css({'width':'80px'}).addClass('data');
	cDtfinal.css({'width':'80px'}).addClass('data');
	
				
	cTodosRelatorio.habilitaCampo();
	cTodosRelatorio.removeClass('campoErro');
	
	cTiporel.unbind('keypress').bind('keypress', function(e) {
		// Se é a tecla ENTER
		if (e.keyCode == 13) {
			cCdcooper.focus();
			return false;
		}
	});
	cCdcooper.unbind('keypress').bind('keypress', function(e) {
		// Se é a tecla ENTER
		if (e.keyCode == 13) {
			cDtinici.focus();
			return false;
		}
	});
	cDtinici.unbind('keypress').bind('keypress', function(e) {
		// Se é a tecla ENTER
		if (e.keyCode == 13) {
			cDtfinal.focus();
			return false;
		}
	});
	cDtfinal.unbind('keypress').bind('keypress', function(e) {
		// Se é a tecla ENTER
		if (e.keyCode == 13) {
			btnContinuar();
			return false;
		}
	});
		
	layoutPadrao();

	cTiporel.focus();
	
	return false;
}

function formataTotais(){

	cTodosTotais = $('input[type="text"],select','#divTotais');
	
	rTotqtdoc = $('label[for="totqtdoc"]','#divTotais');
	rTotvldoc = $('label[for="totvldoc"]','#divTotais');
	rTottarif = $('label[for="tottarif"]','#divTotais');
	rTotpagar = $('label[for="totpagar"]','#divTotais');
		
		
	cTotqtdoc = $('#totqtdoc','#divTotais');	
	cTotvldoc = $('#totvldoc','#divTotais');	
	cTottarif = $('#tottarif','#divTotais');	
	cTotpagar = $('#totpagar','#divTotais');
	
	
	rTotqtdoc.css({'width':'120px'});
	rTotvldoc.css({'width':'120px'});
	rTottarif.css({'width':'120px'});
	rTotpagar.css({'width':'120px'});
	
	
	cTotqtdoc.css({'width':'160px'}).addClass('moeda');
	cTotvldoc.css({'width':'160px'}).addClass('moeda');
	cTottarif.css({'width':'160px'}).addClass('moeda');
	cTotpagar.css({'width':'160px'}).addClass('moeda');
	
				
	cTodosTotais.desabilitaCampo();
		
	layoutPadrao();

	return false;
}
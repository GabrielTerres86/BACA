/*!
 * FONTE        : logrbc.js
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Novembro/2014
 * OBJETIVO     : Biblioteca de funções da tela LOGRBC
 * --------------
 * ALTERAÇÕES   :
 * -----------------------------------------------------------------------
 */



// Variaveis
var idrowid = '';

var rIdtpreme, rDtmvtolt, rIdpenden,
    cIdtpreme, cDtmvtolt, cIdpenden;

var rDtremess, rTpremess, rLsarquiv, rLsarqcan, rLsarquiv1, rDscancel,
    cDtremess, cTpremess, cLsarquiv, cLsarqcan, cDscancel, cRowid, cIdopreto;

var cTodosCabecalho, btnOK;




// Tela
$(document).ready(function() {
	estadoInicial();
});

function estadoInicial() {

	// Efeito de inicializacao
	$('#divRotina').fadeTo(0,0.1);

	// Inicializa Variavel
	idrowid = '';

	// Monta a tela Principal
	atualizaSeletor();
	formataCabecalho();

	// Remove a visualizacao das DIV's
	$('#divRegistros').css({'display':'none'});
	$('#divBotoes').css({'display':'none'});
	$('#divEventos').css({'display':'none'});
	$('#divCancelamento').css({'display':'none'});
	$('#divConsulta').css({'display':'block'});
	$('#frmCab').css({'display':'block'});
	$("#divConteudo").html('');

	// Remove Opacidade da Tela
	removeOpacidade('divTela');

	// Desativa os Botoes
	$('#btEventos','#divBotoes').hide();
	$('#btCancelar','#divBotoes').hide();
	$('#btConfirm','#divBotoes').hide();
	$('#btnVoltar','#divBotoes').hide();
	$('#btVoltar2','#divBotoes').hide();


	// Foco no campo de data
	cIdtpreme.focus();
	return false;
}

function estadoInicialCancel() {

	$('#btConfirm','#divBotoes').show();

	// Limpa a DIV de Conteudo
	$("#divConteudo").html('');
	$('#divConsulta').css({'display':'none'});
	$('#divEventos').css({'display':'block'});
	$('#divCancelamento').css({'display':'block'});

	// Cria o cabecalho de Cancelamento
	formataCabEventos();

	// Desabilita os campos
	cDtremess.desabilitaCampo();
	cTpremess.desabilitaCampo();

	// Desativa os Botoes
	$('#btEventos','#divBotoes').hide();
	$('#btCancelar','#divBotoes').hide();
	$('#btVoltar','#divBotoes').hide();
	$('#btVoltar2','#divBotoes').show();

	cDscancel.focus();
	return false;
}

// Cabecalho
function atualizaSeletor() {

	/** Geral **/
	rIdtpreme	    = $('label[for="idtpreme"]','#frmCab');
	rDtmvtolt       = $('label[for="dtmvtolt"]','#frmCab');
	rIdpenden       = $('label[for="idpenden"]','#frmCab');

	cIdtpreme		= $('#idtpreme','#frmCab');
	cDtmvtolt       = $('#dtmvtolt','#frmCab');
	cIdpenden       = $('#idpenden','#frmCab');

	cTodosCabecalho	= $('input[type="text"],select','#frmCab');
	btnOK			= $('#btnOK','#frmCab');

	rIdtpreme.habilitaCampo();
	rDtmvtolt.habilitaCampo();
	return false;
}

// Formatacao da Tela
function formataCabecalho() {

	/** Geral **/
	rIdtpreme.addClass('rotulo-linha').css({'width':'200px'});
	rDtmvtolt.addClass('rotulo-linha').css({'width':'70px'});
	rIdpenden.addClass('rotulo-linha').css({'width':'120px'});

	cIdtpreme.addClass('campo').css({'width':'200px'});
	cDtmvtolt.addClass('campo').addClass('data').css({'width':'85px'});
	cIdpenden.addClass('campo').css({'width':'35px'});

	highlightObjFocus( $('#frmCab') );

	opcaoTela();
	layoutPadrao();
	return false;
}

// Formatacao Cabecalho de Eventos e Cancelamento
function formataCabEventos() {

	/** Eventos e Cancelamento **/
	rTpremess	    = $('label[for="tpremess"]','#frmCab');
	rDtremess       = $('label[for="dtremess"]','#frmCab');
	rLsarquiv	    = $('label[for="lsarquiv"]','#frmCab');
	rLsarqcan	    = $('label[for="lsarqcan"]','#frmCab');
	rLsarquiv1	    = $('label[for="lsarquiv1"]','#frmCab');
	rDscancel	    = $('label[for="dscancel"]','#frmCab');

	cTpremess		= $('#tpremess','#frmCab');
	cDtremess       = $('#dtremess','#frmCab');
	cLsarquiv		= $('#lsarquiv','#frmCab');
	cLsarqcan		= $('#lsarqcan','#frmCab');
	cDscancel		= $('#dscancel','#frmCab');

	// Campos Hidden
	cRowid  	    = $('#rowid','#frmCab');
	cIdopreto  	    = $('#idopreto','#frmCab');

	cTodosCabecalho	= $('input[type="text"],select','#frmCab');

	rLsarquiv1.addClass('rotulo-linha').css({'width':'980px'});
	rTpremess.addClass('rotulo-linha').css({'width':'100px'});
	rDtremess.addClass('rotulo-linha').css({'width':'100px'});
	rLsarquiv.addClass('rotulo-linha').css({'width':'100px'});
	rLsarqcan.addClass('rotulo-linha').css({'width':'100px'});
	rDscancel.addClass('rotulo').css({'width':'150px'});

	cTpremess.addClass('campo').css({'width':'85px'});
	cDtremess.addClass('campo').addClass('data').css({'width':'130px'});
	cLsarquiv.addClass('campo').css({'width':'450px','font-family':'Courier New'});
	cLsarqcan.addClass('campo').css({'width':'445px'});
	cDscancel.css({'width':'1000px'});

	highlightObjFocus( $('#frmCab') );

	opcaoTela();
	layoutPadrao();
	return false;
}

// Funcoes definidas
function opcaoTela() {

	// Se precionar ENTER no campo de Bureaux
	cIdtpreme.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cDtmvtolt.focus();
			return false;
		}
	});

	// Se precionar ENTER no campo de Data
	cDtmvtolt.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13) {
			consultaRemessa();
			return false;
		}
	});

	// Se clicar no botao OK
	btnOK.unbind('click').bind('click', function() {
		consultaRemessa();
		return false;
	});

	return false;
}




// Botoes da Tela
function btnEventos() {

	// Estado Inicial da Tela de Eventos

	// Limpa a DIV de Conteudo
	$("#divConteudo").html('');
	$('#divConsulta').css({'display':'none'});
	$('#divEventos').css({'display':'block'});
	$('#divArquivos').css({'display':'none'});
	$('#divArquivosCancel').css({'display':'none'});

	// Cria o cabecalho de Eventos
	formataCabEventos();

	// Consulta os Eventos da remessa selecionada
	consultaEventosRemessa(idrowid);

	// Desabilita os campos
	cTpremess.desabilitaCampo();
	cDtremess.desabilitaCampo();
	
	// Desativa os Botoes
	$('#btEventos','#divBotoes').hide();
	$('#btCancelar','#divBotoes').hide();
	$('#btConfirm','#divBotoes').hide();
	$('#btVoltar','#divBotoes').hide();
	$('#btVoltar2','#divBotoes').show();
	
	return false;
	
}

function btnCancelar() {

	// Estado Inicial da Tela de Eventos

	// Desabilita o conteudo da tela
	$('#divConsulta').css({'display':'none'});
	$('#divEventos').css({'display':'none'});
	$('#divCancelamento').css({'display':'none'});
	$('#divBotoes').css({'display':'none'});
	$('#divArquivos').css({'display':'none'});
	$('#divArquivosCancel').css({'display':'none'});

	// Configura os campos na tela
	formataCabEventos();

	// Desabilita os campos
	cTpremess.desabilitaCampo();
	cDtremess.desabilitaCampo();

	// Desativa os Botoes
	$('#btEventos','#divBotoes').hide();
	$('#btCancelar','#divBotoes').hide();
	$('#btConfirm','#divBotoes').hide();
	$('#btVoltar','#divBotoes').hide();
	$('#btVoltar2','#divBotoes').show();

	// Valida a remessa selecionada
	verificaRemessa(idrowid);

	// Cria o cabecalho de Eventos

	// Limpa a DIV de Conteudo
	$("#divConteudo").html('');
	$('#divConsulta').css({'display':'none'});
	$('#divEventos').css({'display':'block'});

	return false;
}

function btnVoltar() {

	cIdtpreme.val('TODAS');
	cDtmvtolt.val(aux_dtmvtolt);

	// Inicializa Variavel
	idrowid = '';
	
	// Limpa conteudo da lista
	cLsarquiv.empty();
	cLsarqcan.empty();

	estadoInicial();
	return false;
}

function btnVoltar2() {

	cRowid.val('');

	// Voltar a modo de Consulta
	$('#btVoltar2','#divBotoes').hide();
	$('#btConfirm','#divBotoes').hide();
	$('#btVoltar','#divBotoes').show();

	// Limpa conteudo da lista
	cLsarquiv.empty();
	cLsarqcan.empty();

	// Oculta a DIV de Eventos e Cancelamento
	$('#divEventos').css({'display':'none'});
	$('#divCancelamento').css({'display':'none'});

	// Exibe novamente DIV de Principal
	$('#divConsulta').css({'display':'block'});

	consultaRemessa();
	return false;
}

function btnConfirm() {
	showConfirmacao("Voc&ecirc; tem certeza que deseja cancelar o Envio/Retorno desta remessa?","Confirma&ccedil;&atilde;o - Ayllos","cancelarRemessa(idrowid);","","sim.gif","nao.gif");
	return false;
}




// Consulta Remessas do dia informado
function consultaRemessa(){

	// Captura os valores de tela
	var idtpreme = cIdtpreme.val();
	var dtmvtolt = cDtmvtolt.val();
	var idpenden = cIdpenden.is(':checked')==true ? 1 : 0;
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando dados ...");

	$.ajax({
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/logrbc/consulta_dados_logrbc.php",
		data: {
			dtmvtolt : dtmvtolt,
			idtpreme : idtpreme,
			idpenden : idpenden,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function(response) {
			hideMsgAguardo();
			try {
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						$('input,select','#frmCab').removeClass('campoErro');
						$('#divBotoes').css({'display':'block'});
						$("#divConteudo").html(response);
						formataTabela();
						$('#btEventos','#divBotoes').show();
						$('#btCancelar','#divBotoes').show();
						$('#btVoltar','#divBotoes').show();
					} catch(error) {
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
					}
				} else {
					try {
						eval(response);
					} catch(error) {
						hideMsgAguardo();
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
					}
				}
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));");
			}
		}
	});

	return false;
}

// Consulta Eventos da Remessas
function consultaEventosRemessa(rowid){

	// Limpa os campos
	limpaCampos();

	// Captura os valores de tela
	var rowid    = rowid;
	var nmarquiv = cLsarquiv.val();
	if (nmarquiv == null) {nmarquiv = '';}

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando eventos de remessa ...");

	$.ajax({
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/logrbc/consulta_eventos_logrbc.php",
		data: {
			rowid    : rowid,
			nmarquiv : nmarquiv,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function(response) {
			hideMsgAguardo();
			try {
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						$('input,select','#frmCab').removeClass('campoErro');
						$('#divBotoes').css({'display':'block'});
						$("#divConteudo").html(response);

						if (cIdopreto.val() == "M"){
							cLsarquiv.habilitaCampo();
							$('#divCab').css({'display':'block'});
							$('#divArquivos').css({'display':'block'});
							rLsarquiv.show();
							cLsarquiv.show();
							formataTabelaEventosMultiplos();
						}else{
							$('#divCab').css({'display':'none'});
							cLsarquiv.append('<option value=""></option>');
							cLsarquiv.desabilitaCampo();
							rLsarquiv.hide();
							cLsarquiv.hide();

							formataTabelaEventosUnicos();
						}
					} catch(error) {
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
					}
				} else {
					try {
						eval(response);
					} catch(error) {
						hideMsgAguardo();
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
					}
				}
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));");
			}
		}
	});

	return false;
}

// Verifica se a remessa pode ser cancelada
function verificaRemessa(rowid){

	// Limpa os campos
	limpaCampos();

	// Captura os valores de tela
	var rowid    = rowid;

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, verificando dados da remessa ...");

	$.ajax({
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/logrbc/verifica_logrbc.php",
		data: {
			rowid    : rowid,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function(response) {
			hideMsgAguardo();
			try {
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						$('input,select','#frmCab').removeClass('campoErro');
						$('#divBotoes').css({'display':'block'});
						$("#divConteudo").html(response);
						estadoInicialCancel();
						if (cIdopreto.val() == "M"){
							$('#divCab').css({'display':'block'});
							$('#divArquivosCancel').css({'display':'block'});
							rLsarquiv.show();
							cLsarquiv.show();
							formataTabelaEventosMultiplos();
						}
					} catch(error) {
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
					}
				} else {
					try {
						eval(response);
					} catch(error) {
						hideMsgAguardo();
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
					}
				}
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));");
			}
		}
	});

	return false;
}

// Verifica se a remessa pode ser cancelada
function cancelarRemessa(rowid){

	// Captura os valores de tela
	var rowid = rowid;
	var dsmotcan = removeCaracterEsp(cDscancel.val());
	var nmarqcan = cLsarqcan.val();
	if (nmarqcan == null) {nmarqcan = '';}


	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, efetuando cancelamento da remessa ...");

	$.ajax({
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/logrbc/cancelar_logrbc.php",
		data: {
			rowid : rowid,
			dsmotcan : dsmotcan,
			nmarqcan : nmarqcan,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function(response) {
			hideMsgAguardo();
			try {
				if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
					try {
						showError("inform","Cancelamento da remessa efetuada com sucesso!","Alerta - Ayllos","btnVoltar();");
						eval(response);
					} catch(error) {
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
					}
				} else {
					try {
						eval(response);
					} catch(error) {
						hideMsgAguardo();
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
					}
				}
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));");
			}
		}
	});

	return false;
}




// Formata tabela de dados da remessa
function formataTabela() {

	// Habilita a conteudo da tabela
    $('#divConteudo').css({'display':'block'});

    var divRegistro = $('div.divRegistros', '#tabDados');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

    $('#tabDados').css({'margin-top':'1px'});
	divRegistro.css({'height':'370px','padding-bottom':'1px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '150px';
	arrayLargura[1] = '150px';
	arrayLargura[2] = '180px';
	arrayLargura[3] = '90px';
	arrayLargura[4] = '90px';
	arrayLargura[5] = '90px';
	arrayLargura[6] = '90px';
	arrayLargura[7] = '14px';

	var arrayAlinha = new Array();
        arrayAlinha[0] = 'center';
        arrayAlinha[1] = 'left';
        arrayAlinha[2] = 'left';
        arrayAlinha[3] = 'center';
        arrayAlinha[4] = 'center';
        arrayAlinha[5] = 'center';
        arrayAlinha[6] = 'center';


	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	hideMsgAguardo();

	/* Atribuindo o foco para a linha da tabela, pois ao clicar no cabecalho nao retornava
	para linha da tabela, dessa maneira a tela apresentava erro na hora de alterar ou
	excluir o registro selecionado */


	$('table > thead > tr > th', divRegistro).unbind('click').bind('click', function() {
		$('table > tbody > tr > td', divRegistro).focus();
	});

	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		selecionaTabela($(this));
	});

    // seleciona o registro que é focado
	$('table > tbody > tr', divRegistro).focus( function() {
		selecionaTabela($(this));
	});

	$('table > tbody > tr:eq(0)', divRegistro).click();
	return false;
}

function selecionaTabela(tr) {

    idrowid = $('#indrowid', tr).val();
	return false;
}

// Formata tabela de eventos Unicos de remessa
function formataTabelaEventosUnicos() {

	// Habilita a conteudo da tabela
    $('#divConteudo').css({'display':'block'});

    var divRegistro = $('div.divRegistros', '#tabEventoUnico');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

    $('#tabEventoUnico').css({'margin-top':'1px'});
	divRegistro.css({'height':'370px','padding-bottom':'1px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '210px';
	arrayLargura[1] = '210px';
	arrayLargura[2] = '530px';
	arrayLargura[3] = '16px';

	var arrayAlinha = new Array();
        arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'left';
        arrayAlinha[2] = 'left';

	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	hideMsgAguardo();

	/* Atribuindo o foco para a linha da tabela, pois ao clicar no cabecalho nao retornava
	para linha da tabela, dessa maneira a tela apresentava erro na hora de alterar ou
	excluir o registro selecionado */


	$('table > thead > tr > th', divRegistro).unbind('click').bind('click', function() {
		$('table > tbody > tr > td', divRegistro).focus();
	});

	return false;
}


// Formata tabela com eventos Multi-Arquivos da remessa
function formataTabelaEventosMultiplos() {

	// Habilita a conteudo da tabela
    $('#divConteudo').css({'display':'block'});

    var divRegistro = $('div.divRegistros', '#tabEventoMultiplo');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

    $('#tabEventoMultiplo').css({'margin-top':'1px'});
	divRegistro.css({'height':'370px','padding-bottom':'1px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '100px';
	arrayLargura[1] = '290px';
	arrayLargura[2] = '100px';
	arrayLargura[3] = '450px';
	arrayLargura[4] = '16px';

	var arrayAlinha = new Array();
        arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'left';
        arrayAlinha[2] = 'left';
        arrayAlinha[3] = 'left';

	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	hideMsgAguardo();

	/* Atribuindo o foco para a linha da tabela, pois ao clicar no cabecalho nao retornava
	para linha da tabela, dessa maneira a tela apresentava erro na hora de alterar ou
	excluir o registro selecionado */


	$('table > thead > tr > th', divRegistro).unbind('click').bind('click', function() {
		$('table > tbody > tr > td', divRegistro).focus();
	});

	return false;
}




// Pesquisa Eventos da Remessa
function pesquisaEventosArq() {

	idrowid = cRowid.val();
	consultaEventosRemessa(idrowid);
	return false;
}


// Limpa os campos
function limpaCampos() {

	cDtremess.val('');
    cTpremess.val('');
    cDscancel.val('');

	return false;
}

// Limpa os campos
function retornaEstadoInicial() {

	cDtremess.val('');
    cTpremess.val('');
    cDscancel.val('');
	
	cRowid.val('');

	// Limpa conteudo da lista
	cLsarquiv.empty();
	cLsarqcan.empty();

	estadoInicial();
	return false;
}

/* Funcao criada para substituir os caracteres */
function removeCaracterEsp(caracter){

	// Limpa a variavel
	var string = "";

	// Remove os caracteres especiais
	string = caracter.replace("á","a")
					 .replace("à","a")
					 .replace("Á","A")
					 .replace("À","A")
			 		 .replace("ã","a")
					 .replace("Ã","A")
					 .replace("Â","A")
					 .replace("â","a")
					 .replace("é","e")
					 .replace("É","E")
					 .replace("ê","e")
					 .replace("Ê","E")
					 .replace("í","i")
					 .replace("Í","I")
					 .replace("Ô","O")
					 .replace("ô","o")
					 .replace("ó","o")
					 .replace("ú","u")
					 .replace("Ú","U")
					 .replace("Ó","O")
					 .replace("õ","o")
					 .replace("Õ","O")
					 .replace("ç","c")
					 .replace("Ç","C")
					 .replace("<","")
					 .replace(">","");

	// Retorna a string sem caracteres especiais
	return string;
}


function controlaLayout() {

	atualizaSeletor();
	formataCabecalho();

	cDtmvtolt.val('');
	layoutPadrao();
	return false;
}
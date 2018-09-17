/*!
 * FONTE        : parrac.js
 * CRIAÇÃO      : Jonata Cardoso (RKAM) 
 * DATA CRIAÇÃO : 28/01/2015
 * OBJETIVO     : Biblioteca de funções da tela parrac
 * --------------
 * ALTERAÇÕES   : 
 */

//Formulários e Tabela
var frmCab   		= 'frmCab';
var frmDados  		= 'frmExtrat';
var frmOpcao		= 'frmOpcao';
var frmArquivo		= 'frmArquivo';
var cddopcao 	    = 'C';

var badBrowser = true;

if(navigator.appName.indexOf("Internet Explorer") != -1 || document.documentMode == 8){
	badBrowser = true;
}else{
	badBrowser = false;
}

$(document).ready(function() {
	estadoInicial();
});

function estadoInicial() {

	var btSalvar    = $('#btSalvar','#frmCrapqac');
	
	btSalvar.html('Alterar');

	$('#divTela').fadeTo(0,0.1);
	
	hideMsgAguardo();
	
	cddopcao = 'C';

	controlaOperacao('C1' , 0 );	

	removeOpacidade('divTela');
	
}

function controlaOperacao( operacao , nrseqvac) {

	hideMsgAguardo();
	
	showMsgAguardo( 'Aguarde, consultando as informa&ccedil;&otilde;es ...' );	
		
	// Carrega dados da conta através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/parrac/principal.php', 
		data    : 
				{ 
					operacao : operacao,  
					nrseqvac : nrseqvac,						
					redirect : 'html_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) {
					hideMsgAguardo();
					limpaTela(operacao);
					try {		
						if ( response.indexOf('showError("error"') == -1 ) {
							$('#divTela').append(response);
						} else {
							eval( response );
						}
						return false;
					} catch(error) {
						hideMsgAguardo();
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
					}	
				}		
	});
	
	return false;	
}

function limpaTela(operacao) {

	switch(operacao) {
		case 'C1': $("#frmCrapvac").remove();
		case 'C2': $("#frmCrapqac").remove();	
	}

}



function formataTabelaVersao() {
		
	var divRegistro = $('div.divRegistros', '#tabCrapvac');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
	
	$('#tabCrapvac').css({'margin-top':'5px'});
	divRegistro.css({'height':'30px','padding-bottom':'2px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'left';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

	return false;
}


function formataCriterios() {

	var frmDados = 'divCrapqac';

	var rLacre123 = $('label[for="lacre123"]', '#'+frmDados);
	rLacre123.addClass('rotulo').css({'width':'300px','text-align':'left','margin-left':'10px'});

	var rCriterio  = $('label[name="nrseqqac"]', '#'+frmDados);
	var rCriterio2 = $('label[name="nrseqqac-2"]', '#'+frmDados);
	var rinstatus  = $('label[for="instatus"]', '#'+frmDados);
	var rEspaco    = $('label[for="espaco"]', '#'+frmDados);

	rCriterio.addClass('rotulo').css({'text-align':'left','margin-left':'5px'});
	rCriterio2.addClass('rotulo-linha').css({'text-align':'left','margin-left':'5px'});
	rinstatus.addClass('rotulo-linha').css({'width':'40px'});

	var cCriterio     = $("input[name='criterio']",'#'+frmDados); 
	var cCdstatus     = $('select[name="cdstatus"]', '#'+frmDados);
	var cInstatus     = $('select[name="instatus"]', '#'+frmDados);
	var cCriterio61   = $("#criterio-6-1",'#'+frmDados);
	
	cCdstatus.css({'width':'120px'});
	cInstatus.css({'width':'120px'});
	rEspaco.css({'width':'10px'});
	
	// Tratamento de foco dos campos
	cCriterio.unbind('keypress').bind('keypress',function(e) {
		
		var tecla = (e.keyCode?e.keyCode:e.which);
		var campo =  $("input[name='criterio']",'#'+frmDados);
		var indice = campo.index(this);
		
		if (tecla == 13 && campo[indice+1] != null) { 
			campo[indice+1].focus();
		}
		
	}); 
		
	// Nao permitir alterar este campo (Tipo conta)
	cCriterio61.unbind('keypress').bind('keypress', function (e) {
	
		var tecla = (e.keyCode?e.keyCode:e.which);
		
		if(tecla != 13) {
			return false;
		}
		
		var campo =  $("input[name='criterio']",'#'+frmDados);
		var indice = campo.index(this);
		
		if (tecla == 13 && campo[indice+1] != null) { 
			campo[indice+1].focus();
		}
		
	});
	
	
	// Mudar o status do item 
	cCdstatus.unbind('change').bind('change',function(e) {
				
		var qtcaracter = ($(this).attr('id').length == 11) ? 1 : 2;		
		var item       = $(this).attr('id').substr(9,qtcaracter) + "-";
		var cCriterio  = $("[id^='criterio-" + item + "']","#frmCrapqac");
		var cCriterio2 = $("[id^='criterio2-" + item + "']","#frmCrapqac");
		var cInstatus  = $("[id^='instatus-" + item +"']","#frmCrapqac");
		var cdstatus   = $(this).val();
		
		
		// Habilitar/desabilitar campos dependendo se o item esta ativo ou nao
		cCriterio.each(function(e) {
			habilitaDesabilita($(this),cdstatus);
		});	
		
		cCriterio2.each(function(e) {
			habilitaDesabilita($(this),cdstatus);
		});	
		
		cInstatus.each(function(e) {
			habilitaDesabilita($(this),cdstatus);
		});		
	
	});
	
	var cTodosDados = $('input[type="text"],select','#'+frmDados);
	cTodosDados.desabilitaCampo();
	$("#criterio-6-1","#"+frmDados).habilitaCampo();
	layoutPadrao();
	return false;
	
}

function habilitaDesabilita ( objeto, cdstatus ) {
	
	if (cdstatus == "1") { // Ativo 
		objeto.habilitaCampo();
	} else { // Inativo
		objeto.val("");
		objeto.desabilitaCampo();
	}
	
}

function selecionaVersao(nrseqvac, dsversao, dtinivig) {

	$("#nrseqvac","#frmCrapvac").val(nrseqvac);
	$("#dsversao","#frmCrapvac").val(dsversao);
	$("#dtinivig","#frmCrapvac").val(dtinivig);
	
	controlaOperacao( 'C2' , nrseqvac);
	
	$("#criterio-6-1","#"+frmDados).habilitaCampo();
	
	return false;
}

function manter_rotina (operacao) {

	cddopcao = operacao.substr(0,1);
	
	var nrseqvac = 0, cdcooper;
	var dsversao = '', dtinivig = '' , dscasprp = '';
	var dsoperac = (cddopcao == 'D') ? 'duplica&ccedil;&atilde;o' : (cddopcao == 'I') ? 'inclus&atilde;o' : (cddopcao == 'A') ? 'altera&ccedil;&atilde;o' : 'exclus&atilde;o';
	
	// Data atual do sistema
	var dtmvtolt  = $("#dtmvtolt","#frmCrapvac").val();
	var dtcompar1 = parseInt(dtmvtolt.split("/")[2].toString() + dtmvtolt.split("/")[1].toString() + dtmvtolt.split("/")[0].toString()); 
	// Vigencia
	var dtinivig  = $("#dtinivig","#frmCrapvac").val();
	
	var inparece = $("#inparece_1","#frmCrapvac").prop('checked') ? 'S' : 'N';

	if (dtinivig == "") {
		showError('error','Nenhuma vers&atilde;o foi selecionada.','Alerta - Ayllos',"unblockBackground()");
		return false;
	}
	
	if (operacao != 'A_parecer_1' && operacao != 'A_parecer_2' ) {
		if (permiteAlterarVersao(cddopcao) == false) {
			return false;
		}
	}
	
	switch (operacao) {
	
		// Inclusao e alteracao de versao
		case 'I_crapvac_2': 
		case 'A_crapvac_2':
		case 'D_crapvac_2': {
			if  ($("#dsversao","#frmVersao").val() == "") {
				showError('error','Informe a descri&ccedil;&atilde;o da vers&atildeo.','Alerta - Ayllos','blockBackground(parseInt($("#divRotina").css("z-index")));');
				return false;
			}
			if  ($("#dtinivig","#frmVersao").val() == "") {
				showError('error','Informe a data da vers&atildeo.','Alerta - Ayllos','blockBackground(parseInt($("#divRotina").css("z-index")));');
				return false;
			}
				
			dtinivig = $("#dtinivig","#frmVersao").val();
			dtcompar2 = parseInt(dtinivig.split("/")[2].toString() + dtinivig.split("/")[1].toString() + dtinivig.split("/")[0].toString()); 
			
			if (dtcompar2 <= dtcompar1 && cddopcao != 'A') {
				showError('error','A data da vers&atildeo deve ser maior a data atual.','Alerta - Ayllos','blockBackground(parseInt($("#divRotina").css("z-index")));');
				return false;
			}
			showConfirmacao('Confirma a ' + dsoperac + '?' ,'Confirma&ccedil;&atilde;o - Ayllos','manter_rotina("' + operacao.substr(0,10) + '3");','blockBackground(parseInt($("#divRotina").css("z-index")));','sim.gif','nao.gif');
			return false;
		}
		case 'I_crapvac_3': 
		case 'A_crapvac_3': 
		case 'D_crapvac_3': {		
			nrseqvac = (operacao == 'I_crapvac_3') ? 0 : $("#nrseqvac","#frmCrapvac").val();
			dsversao = $("#dsversao","#frmVersao").val();
			dtinivig = $("#dtinivig","#frmVersao").val();
			break;
		}
		
		// Duplicacao de versao para outras cooperativas
		case 'D_crapvac_5': {
			showConfirmacao('Confirma a ' + dsoperac + '?' ,'Confirma&ccedil;&atilde;o - Ayllos','manter_rotina("' + operacao.substr(0,10) + '6");','blockBackground(parseInt($("#divRotina").css("z-index")));','sim.gif','nao.gif');
			return false;
		}
		
		case 'D_crapvac_6': {
			nrseqvac = $("#nrseqvac","#frmCrapvac").val();
			cdcooper = $("#cdcooper","#frmDuplica").val();
			break;
		}
	
		// Alteracao
		case 'A_parecer_1':
		case 'A_crapqac_1': {
			showConfirmacao('Confirma a ' + dsoperac + '?','Confirma&ccedil;&atilde;o - Ayllos','manter_rotina("' + operacao.substr(0,10) + '2");','','sim.gif','nao.gif');
			return false;
		}
		case 'A_crapqac_2': {
			cadastrarItens();
			return false;
		}
		
		// Exclusao da versao
		case 'E_crapvac_1': {
			if ( $("#nrseqvac","#frmCrapvac").val() == "") {
				return false;
			}
 			showConfirmacao('Confirma a exclus&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','manter_rotina(\'E_crapvac_2\');','','sim.gif','nao.gif');
			return false;
		}
		
		case 'V_questionario':
		case 'E_crapvac_2': {
			nrseqvac = $("#nrseqvac","#frmCrapvac").val();
			break;
		}
		
	}
	
	var mensagem = 'Aguarde...';
 	
	showMsgAguardo(mensagem);
	
	cddopcao = (cddopcao == 'D') ? 'I' : cddopcao;
	cddopcao = (cddopcao == 'V') ? 'C' : cddopcao;
	
	// Efetuar a alteracao/exclusao/inclusao
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/parrac/manter_rotina.php', 
		data    : 
				{ 
					cddopcao : cddopcao, 
					operacao : operacao,  
					nrseqvac : nrseqvac,
					dsversao : dsversao,
					dtinivig : dtinivig,
					cdcooper : cdcooper,
					inparece : inparece,
					redirect : 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) {
					hideMsgAguardo();
					eval( response );
		}		
	});

}

function cadastrarItens() {

	var cNrseqqac = $("[name='nrseqqac']","#divCrapqac");
	var nrseqvac  = $("#nrseqvac","#frmCrapvac").val();
	var operacao  = 'A_crapqac_2';
	var qtItens  = 0;
	var mensagem = 'Aguarde, salvando os dados ...';
 	
	showMsgAguardo(mensagem);
		
	cNrseqqac.each(function() {
	
		var nrseqiac = $(this).attr('nrseqiac');
		var nrseqqac = $(this).attr('nrseqqac');
		var vlparam1 = $("#criterio-"   + $(this).attr('id').substr(9),"#divCrapqac").val();
		var vlparam2 = $("#criterio2-" + $(this).attr('id').substr(9),"#divCrapqac").val();
		var instatus = $("#instatus-"   + $(this).attr('id').substr(9),"#divCrapqac").val();
		var inmensag = $("#inmensag-"   + nrseqqac,"#divCrapqac").val();
		var dsmensag = $("#dsmensag-"   + nrseqqac,"#divCrapqac").val();
				
		if ($(this).attr('id') == 'nrseqqac-6-1') {
			vlparam1 = $("#dssitcta","#divCrapqac").val();
		}
		
		if ($(this).attr('id') == 'nrseqqac-8-1') {
			vlparam1 = vlparam1.replace('.','').replace(',','.');
		}
		
		if ($(this).attr('id') == 'nrseqqac-3-2') {
			vlparam1 = $("#criterio-3-1","#divCrapqac").val();
		}
		
		if ($(this).attr('id') == 'nrseqqac-3-4') {
			vlparam1 = $("#criterio-3-3","#divCrapqac").val();
		}
		
		if ($(this).attr('id') == 'nrseqqac-3-6') {
			vlparam1 = $("#criterio-3-5","#divCrapqac").val();
		}
				
		// Efetuar a alteracao/inclusao dos itens
		$.ajax({		
			type	: 'POST',
			dataType: 'html',
			url		: UrlSite + 'telas/parrac/manter_rotina.php', 
			data    :
					{ 
						cddopcao : operacao.substr(0,1), 
						operacao : operacao,
						nrseqvac : nrseqvac,
						nrseqiac : nrseqiac,
						nrseqqac : nrseqqac,
						instatus : instatus,
						inmensag : inmensag, 
						dsmensag : dsmensag,
						vlparam1 : vlparam1,
						vlparam2 : vlparam2,			
						redirect : 'script_ajax' 
					},
			error   : function(objAjax,responseError,objExcept) {
						showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
					
						qtItens++;
					
						if (qtItens == cNrseqqac.size()) {
							hideMsgAguardo();
							controlaOperacao('C1','0');
						}
					},
			success : function(response) {
						eval(response);	
						
						qtItens++;
						
						if (qtItens == cNrseqqac.size()) {
							salvarAtivosInativos(operacao);
						}
			}		
		});		
	}); 
}

function salvarAtivosInativos (operacao) {

	var cCdstatus = $("[name='cdstatus']","#divCrapqac");
	var qtItens   = 0, qtTotal = 0;
	var nrseqvac  = $("#nrseqvac","#frmCrapvac").val();


	// Contabilizar o total de itens alterados 
	cCdstatus.each(function() {
		if ($(this).val() == 2) {
			qtTotal++;
		}
	});	
	
	if (qtTotal == 0) {
		hideMsgAguardo();
		controlaOperacao('C1','0');
		return false;
	}
	
	cCdstatus.each(function() {
		
		if ($(this).val() == 2) {
			
			var nrseqiac = $(this).attr('nrseqiac');
				
			// Efetuar a alteracao/inclusao dos itens
			$.ajax({		
				type	: 'POST',
				dataType: 'html',
				url		: UrlSite + 'telas/parrac/manter_rotina.php', 
				data    :
						{ 
							cddopcao : 'E', 
							operacao : operacao,
							nrseqvac : nrseqvac,	
							nrseqiac : nrseqiac,	 					
							redirect : 'script_ajax' 
						},
				error   : function(objAjax,responseError,objExcept) {
							showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
						
							qtItens++;
													
							if (qtItens == qtTotal) {
								hideMsgAguardo();
								controlaOperacao('C1','0');
							}
						},
				success : function(response) {
				
							eval(response);
							
							qtItens++;
														
							if (qtItens == qtTotal) {
								hideMsgAguardo();
								controlaOperacao('C1','0');
							}
				}		
			});
		}		
	});
	
}

function rotina ( operacao , objeto ) {
		
	if (typeof objeto != "undefined" ) {	
		
		if (operacao == 'tipo_residencia' || operacao == 'situacao_conta') {
			objeto.blur();
		} else {
			// Se este item esta inativo, nao mostrar as mensagens
			if ($("#cdstatus-" + objeto + "0","#frmCrapqac").val() == 2) {
				return false;
			}		
		}			
	}	
			
	if (operacao != 'situacao_conta' && operacao != 'tipo_residencia' )	 {	
			
		cddopcao = operacao.substr(0,1);	
		
		if (cddopcao == 'A') {
			if (permiteAlterarVersao(cddopcao) == false) {
				return false;
			}
		}
		
	}
		
	switch (operacao) {
		case 'D_crapvac_1':
		case 'D_crapvac_4': {
			if ($("#nrseqvac","#frmCrapvac").val() == "") {
				return false;
			}
			break;
		}
	}
	
	var mensagem = 'Aguarde...';

	fechaRotina( $('#divUsoGenerico') );
 	showMsgAguardo(mensagem);
	
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/parrac/rotina.php', 
		data: {
			redirect: 'html_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			hideMsgAguardo();
			$('#divRotina').html(response);
			mostraRotina( operacao );
		}				
	});
	return false;
	
}

function mostraRotina( operacao ) {
	
	var mensagem = 'Aguarde...';
	var nrseqvac = $("#nrseqvac","#frmCrapvac").val();
	var dscasprp = $("#dscasprp","#frmCrapqac").val();
	var dssitcta = $("#dssitcta","#frmCrapqac").val(); 
	var nrseqiac = 0 , nrseqqac = 0;
	var inmensag = 0 , dsmensag = '';
	
	if (operacao.substr(0,16) == 'mensagem_positiv' || operacao.substr(0,16) == 'mensagem_atencao') {
		nrseqqac = operacao.substr(17);
		operacao = operacao.substr(0,16);
		nrseqiac = (operacao.substr(0,16) == 'mensagem_atencao') ? $("#btMensagem-" + nrseqqac,"#divCrapqac").attr('nrseqiac') : $("#btMensagemPositiva-" + nrseqqac,"#divCrapqac").attr('nrseqiac');
		inmensag = $("#inmensag-" + nrseqqac,"#divCrapqac").val();
		dsmensag = $("#dsmensag-" + nrseqqac,"#divCrapqac").val();		
	}
	
	if (operacao != 'situacao_conta' && operacao != 'tipo_residencia' )	 {
		cddopcao = operacao.substr(0,1);
	}
		
	showMsgAguardo(mensagem);

	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/parrac/mostra_rotina.php', 
		data: {
			operacao : operacao,
			cddopcao : cddopcao,
			nrseqvac : nrseqvac,
			dscasprp : dscasprp,
			dssitcta : dssitcta,
			nrseqiac : nrseqiac,
			inmensag : inmensag,
			dsmensag : dsmensag,
			nrseqqac : nrseqqac,
			redirect: 'script_ajax'			
			}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"fechaOpcao();");
		},
		success: function(response) {
			hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divConteudo').html(response);
					exibeRotina( $('#divRotina') );
					trataFoco(operacao);
				} catch(error) {
					hideMsgAguardo();					
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','fechaOpcao();');
				}
			} else {
				try {
					eval( response );
				} catch(error) {
					hideMsgAguardo();					
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','fechaOpcao();');
				}
			}
		}
	});
	return false;
}

function fechaOpcao() {

	fechaRotina( $('#divRotina') );
	$('#divRotina').html('');
	
}

function formataVersao (operacao) {
	
	var rTodos = $('label', '#frmVersao');
	
	rTodos.addClass('rotulo').css({'width':'100px'});
	
	var cDsversao = $('#dsversao', '#frmVersao');
	var cDtinivig = $('#dtinivig', '#frmVersao');
	
	cDsversao.addClass('campo').css({'width':'250px'});
	cDtinivig.addClass('data campo').css({'width':'74px'});
	
	cddopcao = operacao.substr(0,1);
	
	cDsversao.unbind('keypress').bind('keypress',function(e) {
		if ( e.keyCode == 13 ) {
			cDtinivig.focus();
		}	
	});
	
	cDtinivig.unbind('keypress').bind('keypress',function(e) {
		if ( e.keyCode == 13 ) {
			manter_rotina(cddopcao.toUpperCase() + '_crapvac_2')
		}	
	});
	
	layoutPadrao();
	
}

function formataDuplicacao () {

	var rTodos = $('label', '#frmDuplica');
	
	rTodos.addClass('rotulo').css({'width':'90px'});
	
	var cCdcooper = $('#cdcooper','#frmDuplica');
	
	cCdcooper.addClass('campo').css({'width':'180px'});

}

function formataResidencia () {

	var rTodos = $('label', '#frmResidencia');
	
	rTodos.addClass('rotulo-linha').css({'width':'230px','text-align':'left'});
	
}

function formataSituacaoConta () {

	var rTodos = $('label', '#frmSituacaoConta');
	
	rTodos.addClass('rotulo-linha').css({'width':'230px','text-align':'left'});

}

function formataMensagem () {
	
	var rTodos      = $('label', '#frmMensagem');
	var cTodos      = $('input,select,textarea','#frmMensagem');
	var cinmensag   = $("#inmensag","#frmMensagem");
	var cDsmensag   = $("#dsmensag","#frmMensagem");
	var cDsvariav   = $("#dsvariav","#frmMensagem");
	var cCriterio1  = $('input[name="criterio"]','#divCrapqac').first();	
	var btSalvar    = $('#btSalvar','#divBotoesMensagens');
 	
	rTodos.addClass('rotulo').css({'width':'120px','text-align':'left'});
	cinmensag.addClass('campo').css({'width':'300px'});
	cDsmensag.addClass('campo').css({'width':'300px','height':'80px'}).attr('maxlength','400');
	cDsvariav.addClass('campo').css({'width':'300px','height':'50px','text-align':'left'}).desabilitaCampo();
	
	if (isHabilitado(cCriterio1) == false) {
		cTodos.desabilitaCampo();
		btSalvar.css({'display':'none'});
	} 
	
	if (!badBrowser ) {
		cDsmensag.val( cDsmensag.val().trim() );
	} 
	
}

function trataFoco(operacao) {

	switch(operacao) {
		case 'I_crapvac_1' :
		case 'A_crapvac_1' :
		case 'D_crapvac_1' : { $("#dsversao","#frmVersao").focus();  break; }
		case 'D_crapvac_4' : { $("#cdcooper","#frmDuplica").focus(); break; }		
	}

}

function habilitaAlteracao () {

	var cTodosDados = $('input[type="text"],select','#divCrapqac');
	var btSalvar    = $('#btSalvar','#frmCrapqac');
	var cCriterio1  = $('input[name="criterio"]','#divCrapqac').first();
	var cCdstatus   = $('select[name="cdstatus"]','#divCrapqac');
	
	if (isHabilitado(cCdstatus.first())) {
		manter_rotina('A_crapqac_1');
	} else {
		if (permiteAlterarVersao('A')) {
			cTodosDados.habilitaCampo();
			cCdstatus.trigger("change");
			btSalvar.html('Salvar');
			cCriterio1.focus();
			cddopcao = 'A';
		}
	}
	
}

function atualizaResidencia () {

	var cIncasprp   = $("input[name='incasprp']","#frmResidencia");
	var dscasprp    = '', dscasprp2 = '';
	
	cIncasprp.each(function() {
		if ($(this).prop('checked') == true) {
			dscasprp  += (dscasprp == '')  ? $(this).val()       : ';' + $(this).val() ;
			dscasprp2 += (dscasprp2 == '') ? $(this).prop('id')  : ';' + $(this).prop('id') ;
		}
	});
	
	// Salvar o valor para a residencia
	$("#dscasprp","#divCrapqac").val(dscasprp);
	
}

function atualizaSituacaoConta () {

	var cCdsitcta   = $("input[name='cdsitcta']","#frmSituacaoConta");
	var dssitcta    = '', dssitcta2 = '';
	var cCriterio61 = $("#criterio-6-1","#divCrapqac");
	
	cCdsitcta.each(function() {
		if ($(this).prop('checked') == true) {
			dssitcta  += (dssitcta == '')  ? $(this).val()       : ';' + $(this).val() ;
			dssitcta2 += (dssitcta2 == '') ? $(this).prop('id')  : ';' + $(this).prop('id') ;
		}
	});
	
	// Salvar o valor para a residencia
	$("#dssitcta","#divCrapqac").val(dssitcta);
	cCriterio61.val(dssitcta2).blur();

}

function salvaMensagem () {

	var inmensag = $("#inmensag","#frmMensagem").val();
	var dsmensag = $("#dsmensag","#frmMensagem").val();
	var nrseqqac = $("#nrseqqac","#frmMensagem").val();
	
	$("#inmensag-" + nrseqqac,"#divCrapqac").val(inmensag);
	$("#dsmensag-" + nrseqqac,"#divCrapqac").val(dsmensag);

}

function permiteAlterarVersao (cddopcao) {

	// Data atual do sistema
	var dtmvtolt  = $("#dtmvtolt","#frmCrapvac").val();
	var dtcompar1 = parseInt(dtmvtolt.split("/")[2].toString() + dtmvtolt.split("/")[1].toString() + dtmvtolt.split("/")[0].toString()); 
	// Vigencia
	var dtinivig  = $("#dtinivig","#frmCrapvac").val();
	
	if (dtinivig == "") {
		showError('error','Nenhuma vers&atilde;o foi selecionada.','Alerta - Ayllos',"unblockBackground()");
		return false;
	}
	
	var dtcompar2 = parseInt(dtinivig.split("/")[2].toString() + dtinivig.split("/")[1].toString() + dtinivig.split("/")[0].toString()); 
		
	if (dtcompar2 <= dtcompar1 && (cddopcao == "A" || cddopcao == "E")) {
		showError('error','Não &eacute; possivel alterar esta vers&atilde;o.','Alerta - Ayllos',"unblockBackground()");
		return false;
	}
	
	return true;

}

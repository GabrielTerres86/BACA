/*!
 * FONTE        : parmcr.js
 * CRIAÇÃO      : Jonata Cardoso (RKAM) 
 * DATA CRIAÇÃO : 09/12/2014
 * OBJETIVO     : Biblioteca de funções da tela PARMCR
 * --------------
 * ALTERAÇÕES   : 
 */

//Formulários e Tabela
var frmCab   		= 'frmCab';
var frmDados  		= 'frmExtrat';
var frmOpcao		= 'frmOpcao';
var frmArquivo		= 'frmArquivo';


$(document).ready(function() {
	estadoInicial();
});

function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);
	
	hideMsgAguardo();

	controlaOperacao('C1' , 0, 0, 0, 0, false);	

	removeOpacidade('divTela');
	
}

function controlaOperacao( operacao , nrversao, nrseqtit , nrseqper, flgbloqu) {

	hideMsgAguardo();
	
	showMsgAguardo( 'Aguarde, consultando as informa&ccedil;&otilde;es ...' );	
		
	// Carrega dados da conta através de ajax
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/parmcr/principal.php', 
		data    : 
				{ 
					operacao : operacao,  
					nrversao : nrversao,	
					nrseqtit : nrseqtit,	
					nrseqper : nrseqper,	
				    flgbloqu : flgbloqu,					
					redirect : 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) {
					hideMsgAguardo();
															
					if (flgbloqu && $("#divError").css('display') == 'block' ) {
						blockBackground(parseInt($("#divRotina").css("z-index")));
					}
					limpaTela(operacao);
					try {							
						$('#divTela').append(response);
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
		case 'C1': $("#frmCrapvqs").remove();
		case 'C2': $("#frmCraptqs").remove();
		case 'C3': $("#frmCrappqs").remove();
		case 'C4': $("#frmCraprqs").remove();
	
	}

}



function formataTabelaVersao() {
		
	var divRegistro = $('div.divRegistros', '#tabCrapvqs');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
	
	$('#tabCrapvqs').css({'margin-top':'5px'});
	divRegistro.css({'height':'30px','padding-bottom':'2px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'left';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

	return false;
}

function formataTabelaTitulo() {

	var divRegistro = $('div.divRegistros', '#tabCraptqs');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
	
	$('#tabCraptqs').css({'margin-top':'5px'});
	divRegistro.css({'height':'30px','padding-bottom':'2px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'left';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

	return false;
	
}

function formataTabelaPergunta () {

	var divRegistro = $('div.divRegistros', '#tabCrappqs');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
	
	$('#tabCrappqs').css({'margin-top':'5px'});
	divRegistro.css({'height':'75px','padding-bottom':'2px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'left';
	arrayAlinha[3] = 'left';
	arrayAlinha[4] = 'left';
	arrayAlinha[5] = 'left';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

	return false;
}

function formataTabelaResposta () {

	var divRegistro = $('div.divRegistros', '#tabCraprqs');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
	
	$('#tabCraprqs').css({'margin-top':'5px'});
	divRegistro.css({'height':'50px','padding-bottom':'2px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '47px';
	arrayLargura[1] = '100px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'left';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

	return false;
	
}

function selecionaVersao(nrversao, dtinivig) {

	// Salvar a sequencia e data de vigencia da versao
	$("#nrversao","#frmCrapvqs").val(nrversao);
	$("#dtinivig","#frmCrapvqs").val(dtinivig);

	controlaOperacao( 'C2' , nrversao, 0 , 0, false);
	return false;
}

function selecionaTitulo (nrseqtit) {

	// Salvar a sequencia do titulo
	$("#nrseqtit","#frmCraptqs").val(nrseqtit);
	
	controlaOperacao( 'C3' , 0, nrseqtit , 0, false);
	
	return false;
}

function selecionaPergunta (nrseqper, intipres, dsregexi, nrordper) {

	// Salvar a sequencia e tipo de resposta da pergunta
	$("#nrseqper","#frmCrappqs").val(nrseqper);
	$("#intipres","#frmCrappqs").val(intipres);
	$("#dsregexi","#frmCrappqs").val(dsregexi);
	$("#nrordper","#frmCrappqs").val(nrordper);
	
	controlaOperacao( 'C4' , 0, 0 , nrseqper, false);
	
	return false;
	
}

function selecionaResposta(nrseqres) {

	// Salvar a sequencia da resposta
	$("#nrseqres","#frmCraprqs").val(nrseqres);
	
	return false;
}

function manter_rotina (operacao) {

	var nrversao = 0, nrseqtit = 0, nrseqper = 0, nrseqres = 0, nrordper = 0, inobriga = 0, 
		intipres = 0, nrregcal = 0, nrordtit = 0, nrordres = 0;
	var dsversao = '', dtinivig = '', dstitulo = '', dspergun = '', dsregexi = '', dsrespos = '';
	var cddopcao = operacao.substr(0,1);
	var dsoperac = (cddopcao == 'D') ? 'duplica&ccedil;&atilde;o' : (cddopcao == 'I') ? 'inclus&atilde;o' : (cddopcao == 'A') ? 'altera&ccedil;&atilde;o' : 'exclus&atilde;o';

	// Data atual do sistema
	var dtmvtolt  = $("#dtmvtolt","#frmCrapvqs").val();
	var dtcompar1 = parseInt(dtmvtolt.split("/")[2].toString() + dtmvtolt.split("/")[1].toString() + dtmvtolt.split("/")[0].toString()); 
	// Vigencia
	var dtinivig  = $("#dtinivig","#frmCrapvqs").val();
	var dtcompar2 = parseInt(dtinivig.split("/")[2].toString() + dtinivig.split("/")[1].toString() + dtinivig.split("/")[0].toString()); 
		
		
	if (dtcompar2 <= dtcompar1 && cddopcao == 'E') {
		showError('error','Não &eacute; possivel alterar esta vers&atilde;o.','Alerta - Ayllos',"unblockBackground()");
		return false;
	}
	
	switch (operacao) {
		
		// Consulta de perguntas
		case 'C_crappqs_1': {
			nrseqtit = $("#nrseqtit","#frmCraptqs").val();
			nrordper = $("#nrordper","#frmPergunta").val();
			dsregexi = $("#dsregexi","#frmPergunta").val();
			break;
		}
		
		// Consulta de respostas 
		case 'C_craprqs_1': {
			
			nrordres = $("#nrordres","#frmCraprqs").val();
			dsregexi = $("#dsregexi","#frmPergunta").val();
			nrseqper = 	$("#dsfiltro","#frmExistencia").val();
			if (nrseqper == null) {
				nrseqper = dsregexi.substr(8,dsregexi.indexOf("=") - 8); //pergunta10=resposta4
			}
			break;
		}
	
		// Inclusao e alteracao de versao
		case 'I_crapvqs_2': 
		case 'A_crapvqs_2':
		case 'D_crapvqs_2': {
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
		case 'I_crapvqs_3': 
		case 'A_crapvqs_3': 
		case 'D_crapvqs_3': {
			nrversao = $("#nrversao","#frmCrapvqs").val();
			dsversao = $("#dsversao","#frmVersao").val();
			dtinivig = $("#dtinivig","#frmVersao").val();
			break;
		}
	
		// Inclusao e alteracao de titulo
		case 'I_craptqs_2': 
		case 'A_craptqs_2': {
			if  ($("#nrordtit","#frmTitulo").val() == "") {
				showError('error','Informe a ordem do t&iacute;tulo.','Alerta - Ayllos','blockBackground(parseInt($("#divRotina").css("z-index")));');
				return false;
			}
			if  ($("#dstitulo","#frmTitulo").val() == "") {
				showError('error','Informe a descri&ccedil;&atilde;o do t&iacute;tulo.','Alerta - Ayllos','blockBackground(parseInt($("#divRotina").css("z-index")));');
				return false;
			}
			showConfirmacao('Confirma a ' + dsoperac + '?','Confirma&ccedil;&atilde;o - Ayllos','manter_rotina("' + operacao.substr(0,10) + '3");','blockBackground(parseInt($("#divRotina").css("z-index")));','sim.gif','nao.gif');
			return false;
		}
		case 'I_craptqs_3': 
		case 'A_craptqs_3': {	
			nrversao = $("#nrversao","#frmCrapvqs").val();
			nrseqtit = $("#nrseqtit","#frmCraptqs").val();
			nrordtit = $("#nrordtit","#frmTitulo").val();
			dstitulo = $("#dstitulo","#frmTitulo").val();
			break;
		}
		
		// Inclusao e alteracao de pergunta
		case 'I_crappqs_2': 
		case 'A_crappqs_2': {
		
			if ($("#nrordper","#frmPergunta").val() == "") {
				showError('error','Informe a ordem da pergunta.','Alerta - Ayllos','blockBackground(parseInt($("#divRotina").css("z-index")));');
				return false;
			}
		
			if ($("#dspergun","#frmPergunta").val().trim() == "") {
				showError('error','Informe a descri&ccedil;&atilde;o da pergunta.','Alerta - Ayllos','blockBackground(parseInt($("#divRotina").css("z-index")));');
				return false;
			}
		
			showConfirmacao('Confirma a ' + dsoperac + '?','Confirma&ccedil;&atilde;o - Ayllos','manter_rotina("' + operacao.substr(0,10) + '3");','blockBackground(parseInt($("#divRotina").css("z-index")));','sim.gif','nao.gif');
			return false;
		}
		case 'I_crappqs_3':
		case 'A_crappqs_3': {
			nrseqtit = $("#nrseqtit","#frmCraptqs").val();
			nrseqper = $("#nrseqper","#frmCrappqs").val();
			nrordper = $("#nrordper","#frmPergunta").val();
			dspergun = $("#dspergun","#frmPergunta").val();
			inobriga = $("#inobriga","#frmPergunta").val();
			intipres = $("#intipres","#frmPergunta").val();
			nrregcal = $("#nrregcal","#frmPergunta").val();
			dsregexi = $('#dsregexi','#frmPergunta').val();
			break;
		}
		
		// Inclusao e alteracao da resposta
		case 'I_craprqs_2': 
		case 'A_craprqs_2': {
			
			if ($("#dsrespos","#frmResposta").val() == "") {
				showError('error','Informe a descri&ccedil;&atilde;o da resposta.','Alerta - Ayllos','blockBackground(parseInt($("#divRotina").css("z-index")));');
				return false;
			}
			
			showConfirmacao('Confirma a ' + dsoperac + '?','Confirma&ccedil;&atilde;o - Ayllos','manter_rotina("' + operacao.substr(0,10) + '3");','blockBackground(parseInt($("#divRotina").css("z-index")));','sim.gif','nao.gif');
			return false;
		
		}
		case 'I_craprqs_3':
		case 'A_craprqs_3': {
			nrseqper = $("#nrseqper","#frmCrappqs").val();
			nrseqres = $("#nrseqres","#frmCraprqs").val();
			nrordres = $("#nrordres","#frmResposta").val();
			dsrespos = $("#dsrespos","#frmResposta").val();
			break;
			
		}		
	
		// Exclusao da versao
		case 'E_crapvqs_1': {
			if ( $("#nrversao","#frmCrapvqs").val() == "") {
				return false;
			}
 			showConfirmacao('Confirma a exclus&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','manter_rotina(\'E_crapvqs_2\');','','sim.gif','nao.gif');
			return false;
		}
		case 'E_crapvqs_2': {
			nrversao = $("#nrversao","#frmCrapvqs").val();
			break;
		}
		// Exclusao do titulo
		case 'E_craptqs_1': {
			if ($("#nrseqtit","#frmCraptqs").val() == "") {
				return false;
			}
			showConfirmacao('Confirma a exclus&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','manter_rotina(\'E_craptqs_2\');','','sim.gif','nao.gif');
			return false;
		}
		case 'E_craptqs_2': {
			nrversao = $("#nrversao","#frmCrapvqs").val();
			nrseqtit = $("#nrseqtit","#frmCraptqs").val();
			break;
		}
		// Exclusao da pergunta
		case 'E_crappqs_1': {
			if ($("#nrseqper","#frmCrappqs").val() == "") {
				return false;
			}
			showConfirmacao('Confirma a exclus&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','manter_rotina(\'E_crappqs_2\');','','sim.gif','nao.gif');
			return false;
		}
		case 'E_crappqs_2': {
			nrseqtit = $("#nrseqtit","#frmCraptqs").val();
		    nrseqper = $("#nrseqper","#frmCrappqs").val();
			break;
		}
		// Exclusao da resposta
		case 'E_craprqs_1': {
			if ($("#nrseqres","#frmCraprqs").val() == "") {
				return false;
			}
		 	showConfirmacao('Confirma a exclus&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','manter_rotina(\'E_craprqs_2\');','','sim.gif','nao.gif');
			return false;
		}
		case 'E_craprqs_2': {
			nrseqper = $("#nrseqper","#frmCrappqs").val();
			nrseqres = $("#nrseqres","#frmCraprqs").val();
		}
	}
	
	var mensagem = 'Aguarde...';
 	
	showMsgAguardo(mensagem);
	
	// Efetuar a alteracao/exclusao/inclusao
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/parmcr/manter_rotina.php', 
		data    : 
				{ 
					cddopcao : cddopcao, 
					operacao : operacao,  
					nrversao : nrversao,	
					nrseqtit : nrseqtit,	
					nrseqper : nrseqper,	
					nrseqres : nrseqres,
					dsversao : dsversao,
					dtinivig : dtinivig,
					nrordtit : nrordtit,
					dstitulo : dstitulo, 
					nrordper : nrordper,
					dspergun : dspergun,
					inobriga : inobriga,
					intipres : intipres,
					nrregcal : nrregcal,
					dsregexi : dsregexi,
					nrordres : nrordres,
					dsrespos : dsrespos,
					redirect : 'script_ajax' 
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) {
					hideMsgAguardo();
					eval(response);	
				}		
	});

}

function rotina ( operacao ) {

	// Data atual do sistema
	var dtmvtolt  = $("#dtmvtolt","#frmCrapvqs").val();
	var dtcompar1 = parseInt(dtmvtolt.split("/")[2].toString() + dtmvtolt.split("/")[1].toString() + dtmvtolt.split("/")[0].toString()); 
	// Vigencia
	var dtinivig  = $("#dtinivig","#frmCrapvqs").val();
	var dtcompar2 = parseInt(dtinivig.split("/")[2].toString() + dtinivig.split("/")[1].toString() + dtinivig.split("/")[0].toString()); 
	var cddopcao = operacao.substr(0,1);	
	var qtpergun = $("#qtpergun","#frmQuestionario").val(); 

		
	if (dtcompar2 <= dtcompar1 && operacao != "I_crapvqs_1" && operacao != 'D_crapvqs_1' && cddopcao != 'C') {
		showError('error','Não &eacute; possivel alterar esta vers&atilde;o.','Alerta - Ayllos',"unblockBackground()");
		return false;
	}	
		
	// Se nao foi selecionado nenhum item na opcao A, retornar
	switch (operacao) {
		case 'A_crapvqs_1': {
			if ($("#nrversao","#frmCrapvqs").val() == "") {
				return false;
			}
			break;
		}
		case 'A_craptqs_1': {
			if ($("#nrseqtit","#frmCraptqs").val() == "") {
				return false;
			}
			break;
		}
		case 'A_crappqs_1': {
			if ($("#nrseqper","#frmCrappqs").val() == "") {
				return false;
			}
			break;
		}
		case 'A_craprqs_1': {
			if ($("#nrseqres","#frmCraprqs").val() == "") {
				return false;
			}
			break;
		}
		case 'I_craprqs_1': {
			if ($("#intipres","#frmCrappqs").val() != "1") {
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
		url: UrlSite + 'telas/parmcr/rotina.php', 
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
			mostraRotina( operacao , qtpergun );
		}				
	});
	return false;
	
}

function mostraRotina( operacao , qtpergun) {
	
	var mensagem = 'Aguarde...';
	var nrversao = $("#nrversao","#frmCrapvqs").val();
	var nrseqtit = $("#nrseqtit","#frmCraptqs").val();
	var nrseqper = $("#nrseqper","#frmCrappqs").val();
	var nrseqres = $("#nrseqres","#frmCraprqs").val();
		
	showMsgAguardo(mensagem);

	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/parmcr/mostra_rotina.php', 
		data: {
			operacao : operacao,
			cddopcao : 'C',
			nrversao : nrversao,
			nrseqtit : nrseqtit,
			nrseqper : nrseqper,
			nrseqres : nrseqres,
			qtpergun : qtpergun,
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

function formataVersao (cddopcao) {
	
	var rTodos = $('label', '#frmVersao');
	
	rTodos.addClass('rotulo').css({'width':'100px'});
	
	var cDsversao = $('#dsversao', '#frmVersao');
	var cDtinivig = $('#dtinivig', '#frmVersao');
	
	cDsversao.addClass('campo').css({'width':'250px'});
	cDtinivig.addClass('data campo').css({'width':'74px'});
	
	cDsversao.unbind('keypress').bind('keypress',function(e) {
		if ( e.keyCode == 13 ) {
			cDtinivig.focus();
		}	
	});
	
	cDtinivig.unbind('keypress').bind('keypress',function(e) {
		if ( e.keyCode == 13 ) {
			manter_rotina(cddopcao.toUpperCase() + '_crapvqs_2')
		}	
	});
	
	layoutPadrao();
	
}

function formataQuestionario() {
	
	var nomeForm = 'frmQuestionario';
	var altura   = '440px';
	var largura  = '500px';
		
	var rTodos = $('label','#'+nomeForm);
	var cTodos = $("select,input",'#'+nomeForm);
	var cDescricao = $('input[name="descricao"]','#'+nomeForm);
	var cInteiros  = $('input[name="inteiro"]',"#"+nomeForm);
	
	rTodos.addClass('rotulo-linha').css('width','60%');
	cTodos.addClass('campo').css({'width':'35%','margin-left':'10px'});
	cDescricao.attr('maxlength','50');
	cInteiros.addClass('campo inteiro').css({'text-align':'right'}).setMask('INTEGER','zzz.zz9','.','');
	
	$('#' + nomeForm).css({'height':altura,'width':largura});

}

function formataTitulo (cddopcao) {

	var rTodos = $('label', '#frmTitulo');

	rTodos.addClass('rotulo').css({'width':'65px'});	
	
	var cNrordtit = $('#nrordtit', '#frmTitulo');
	var cDstitulo = $('#dstitulo', '#frmTitulo');
	
	cNrordtit.addClass('campo inteiro').css({'width':'80px','text-align':'right'}).setMask('INTEGER','zz9','.','');
	cDstitulo.addClass('campo').css({'width':'300px'});
	
	cNrordtit.unbind('keypress').bind('keypress',function(e) {
		if ( e.keyCode == 13 ) {
			cDstitulo.focus();
		}	
	});
	
	cDstitulo.unbind('keypress').bind('keypress',function(e) {
		if ( e.keyCode == 13 ) {
			manter_rotina(cddopcao.toUpperCase() + '_craptqs_2');
		}	
	});
	
	layoutPadrao();

}

function formataPergunta (cddopcao) {

	var rTodos = $('label', '#frmPergunta');
	
	rTodos.addClass('rotulo linha').css({'width':'130px'});
	
	var cNrordper = $('#nrordper', '#frmPergunta');
	var cDspergun = $('#dspergun', '#frmPergunta');
	var cInobriga = $('#inobriga', '#frmPergunta');
	var cIntipres = $('#intipres', '#frmPergunta');
	var cNrregcal = $('#nrregcal', '#frmPergunta');
	var cDsregexi = $('#dsregexi-2', '#frmPergunta');
	
	var nrordper = 0;
	var dsregexi = $('#dsregexi', '#frmPergunta').val();
	
	cNrordper.addClass('campo inteiro').css({'width':'80px','text-align':'right'}).setMask('INTEGER','zz9','.','');;
	cDspergun.addClass('campo').css({'width':'370px','height':'50px'});
	cInobriga.addClass('campo').css({'width':'80px'});
	cIntipres.addClass('campo').css({'width':'120px'});
	cNrregcal.addClass('campo').css({'width':'120px'});
	cDsregexi.addClass('campo').css({'width':'170px'}).desabilitaCampo();
	
	if ( $.browser.msie ) {
		//cDspergun.css({'margin-left':'3px'});		
	} else {
		cDspergun.css({'margin-left':'3px'});
	}
		
	cNrordper.unbind('keypress').bind('keypress',function(e) {
		if ( e.keyCode == 13 ) {
			cDspergun.focus();
		}	
	});
	
	cNrordper.unbind('focus').bind('focus',function(e) {
		nrordper = cNrordper.val();
	});
	
	cNrordper.unbind('blur').bind('blur',function(e) {
		// Se tem regra de existencia e mudou a ordem da pergunta, verificar regra novamente
		if (dsregexi.substr(0,8) == "pergunta" && nrordper != cNrordper.val()) {
			showError('error','Verifique a regra de exist&ecirc;ncia.','Alerta - Ayllos','blockBackground(parseInt($("#divRotina").css("z-index")));');
			cDsregexi.val("");
			$("#tpdregis","#frmExistencia").val("0");
			alteraFiltro();
		}
		// Se mudou a ordem, alterar filtro de existencia
		if (cDsregexi.val() == "Não" && nrordper != cNrordper.val()) {
			$("#tpdregis","#frmExistencia").val("0");
			alteraFiltro();
		}
		
	});
	
	cDspergun.unbind('focus').bind('focus',function(e) {	
			if ($(this).val() == "  ") {
				$(this).val("");	
			}			
	});
	
	
	cDspergun.unbind('keypress').bind('keypress',function(e) {
		if ( e.keyCode == 13 ) {
			cInobriga.focus();
		}	
	});
	
	cInobriga.unbind('keypress').bind('keypress',function(e) {
		if ( e.keyCode == 13 ) {
			cIntipres.focus();
		}	
	});

	cIntipres.unbind('keypress').bind('keypress',function(e) {
		if ( e.keyCode == 13 ) {
			cNrregcal.focus();
		}	
	});	
		
	layoutPadrao();
}

function formataResposta (cddopcao) {

	var rTodos = $('label', '#frmResposta');
	
	rTodos.addClass('rotulo').css({'width':'130px'});
	
	var cNrordres = $('#nrordres', '#frmResposta');
	var cDsrespos = $('#dsrespos', '#frmResposta');
	
	cNrordres.addClass('campo inteiro').css({'width':'80px','text-align':'right'}).setMask('INTEGER','zz9','.','');;
	cDsrespos.addClass('campo').css({'width':'300px'});

	cNrordres.unbind('keypress').bind('keypress',function(e) {
		if ( e.keyCode == 13 ) {
			cDsrespos.focus();
		}	
	});	
	
	cDsrespos.unbind('keypress').bind('keypress',function(e) {
		if ( e.keyCode == 13 ) {
			manter_rotina(cddopcao.toUpperCase() + '_craprqs_2');
		}	
	});	
	
	layoutPadrao();
	
}

function formataExistencia (cddopcao) {

	var rTodos    = $('label','#frmExistencia');
	var rDsrespos = $("#dsrespos","#frmExistencia");
	var rLinha    = $("#linha","#frmExistencia"); 
	
	rTodos.css({'width':'160px','text-align':'left'});
	rDsrespos.addClass('rotulo-linha');
	rLinha.addClass('rotulo-linha');
	
	var cTpdregis = $('#tpdregis','#frmExistencia');
	var cDsfiltro = $('#dsfiltro','#frmExistencia');
	var cDsrespos = $("#dsrespos",'#frmExistencia');
	
	cTpdregis.addClass('campo').css({'width':'150px'});
	cDsfiltro.addClass('campo').css({'width':'300px'}); 
	cDsrespos.addClass('campo').css({'width':'450px'}); 

	cTpdregis.unbind('keypress').bind('keypress',function(e) {
		if ( e.keyCode == 13 ) {
			cDsfiltro.focus();
		}	
	});	
	
	cDsfiltro.unbind('keypress').bind('keypress',function(e) {
		if ( e.keyCode == 13 ) {
			cDsrespos.focus();
		}	
	});
	
	cDsrespos.unbind('keypress').bind('keypress',function(e) {
		if ( e.keyCode == 13 ) {
		}	
	});
	
	layoutPadrao();

}

function telaExistencia () {
	
	// Se estou na tela de pergunta, mostrar a de existencia
	if ($("#frmPergunta").css('display') == 'block') {
	
		if ($("#nrordper","#frmPergunta").val() == "") {
			showError('error','Informe a ordem desta pergunta.','Alerta - Ayllos','blockBackground(parseInt($("#divRotina").css("z-index")));');
			return;
		}
	
		$("#divBotoesPerg").css('display','none');
		$("#frmPergunta").css('display','none');
		$("#frmExistencia").css('display','block');
		$("#divBotoesExis").css('display','block');
	} else {
	
		montaRegraExistencia();
	
		// Senao mostrar a tela de pergunta
		$("#divBotoesPerg").css('display','block');
		$("#frmPergunta").css('display','block');
		$("#frmExistencia").css('display','none');
		$("#divBotoesExis").css('display','none');
	}

}

function voltarPergunta () {
	// Senao mostrar a tela de pergunta
	$("#divBotoesPerg").css('display','block');
	$("#frmPergunta").css('display','block');
	$("#frmExistencia").css('display','none');
	$("#divBotoesExis").css('display','none');
}

function montaRegraExistencia () {

	var tpdregis = $("#tpdregis","#frmExistencia").val();
	var dsfiltro = $("#dsfiltro","#frmExistencia").val();
	var dsrespos = $("#dsrespos","#frmExistencia").val();
	var dsregexi = '', dsregexi2 = '';
	
	if (tpdregis == 0) {
		dsregexi = '';
	}
	else
	if (tpdregis == 1) {
		dsregexi = '#PESSOA=' + dsrespos;
	}
	else {
		if (dsfiltro != null && dsrespos != null) {
			dsregexi = 'pergunta' + dsfiltro + "=resposta" + dsrespos;
		}
	}
	
	dsregexi2 = (dsregexi == '') ? 'Não' : 'Sim';
	
	$("#dsregexi","#frmPergunta").val(dsregexi);
	$("#dsregexi-2","#frmPergunta").val(dsregexi2);

}

function alteraFiltro () {

	var tpdregis = $("#tpdregis","#frmExistencia").val();
	
	// Limpar opcoes do filtro
	$("#dsfiltro","#frmExistencia").html("");
	$("#dsrespos","#frmExistencia").html("");
	
	// Variavel
	if (tpdregis == 1) {
		$("#dsfiltro","#frmExistencia").append('<option value="1">Pessoa</option>');
		$("#dsrespos","#frmExistencia").append('<option value="1">F&iacute;sica</option>');
		$("#dsrespos","#frmExistencia").append('<option value="2">Jur&iacute;dica</option>');
	} 
	else 
	if (tpdregis == 2){
		manter_rotina('C_crappqs_1');		
	}
	
}

function alteraResposta () {

	manter_rotina('C_craprqs_1');

}

function trataFoco(operacao) {

	operacao = operacao.substr(2,7);

	switch(operacao) {
		case 'crapvqs' : { $("#dsversao","#frmVersao").focus(); break; }
		case 'craptqs' : { $("#nrordtit","#frmTitulo").focus(); break; }
		case 'crappqs' : { $("#nrordper","#frmPergunta").focus(); break; }
		case 'craprqs' : { $("#nrordres","#frmResposta").focus(); break; }
		
	}

}

function verificaTipoPessoa () {
	showConfirmacao('Qual o tipo de pessoa que deseja consultar?','Confirma&ccedil;&atilde;o - Ayllos','rotina(\'C_perguntas_1\');','rotina(\'C_perguntas_2\');','fisica.gif','juridica.gif');
}

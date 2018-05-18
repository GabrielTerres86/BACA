/*!
 * FONTE        : arqbcb.js
 * CRIAÇÃO      : Lucas Lunelli          
 * DATA CRIAÇÃO : 13/03/2014
 * OBJETIVO     : Biblioteca de funções da tela ARQBCB
 * --------------
 * ALTERAÇÕES   :  29/10/2014 - Ajuste na rotina realizaOperacao() para 
 *								aumentar o tempo de timeout para 15min
 *								(Odirlei/Amcom)
 *              :  11/05/2018 - Adicionar opcao de C - Configuracao do webservice (Anderson) 
 *
 * --------------
 */
// Definição de algumas variáveis globais 
var cddopcao		= 'C';
	
//Formulários
var frmBcb   		= 'frmBcb';

//Labels/Campos do cabeçalho
var rCddopcao, rCddarqui, cCddopcao, cCddarqui, cTodosCabecalho, btnCab;

$(document).ready(function() {

	estadoInicial();
	
	highlightObjFocus( $('#'+frmBcb) );
	
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	
	return false;
	
});

// seletores
function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);
	$('#frmBcb').css({'display':'block'});
	$('#divBotoes').css({'display':'none'});
		
	escondeCamposConfiguracaoWebService();
	
	trocaBotao( '' );
		
	formataCabecalho();
	
	cTodosCabecalho.limpaFormulario();
	cCddopcao.val( cddopcao );
	
	removeOpacidade('divTela');	
	unblockBackground();
	hideMsgAguardo();
	
	$('#cddarqui','#frmBcb').desabilitaCampo();
	$('#cddarqui','#frmBcb').desabilitaCampo();
	
	trocaBotao('');
	$("#btVoltar","#divBotoes").hide();
	
	$('input,select', '#frmBcb').removeClass('campoErro');
		
	$('#cddopcao','#frmBcb').val("E");
	
	controlaSelect();
		
	controlaFoco();
		
}

function controlaFoco() {

	$('#cddopcao','#frmBcb').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				LiberaCampos();
				return false;
			}	
	});
	
	$('#btnOK','#frmBcb').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				LiberaCampos();
				$('#cddarqui','#frmBcb').focus();
				return false;
			}	
	});
	
	$('#cddarqui','#frmBcb').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 13 || e.keyCode == 9 ) {
				btnContinuar(); 				
			}
	});
	
	$('#tlcooper','#frmBcb').unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				liberaCamposConfiguracaoWebServicePosCooperativa();
				return false;
			}	
	});
}

function formataCabecalho() {

	// cabecalho
	rCddopcao			= $('label[for="cddopcao"]','#'+frmBcb); 
	rCddarqui			= $('label[for="cddarqui"]','#'+frmBcb); 
	
	cCddopcao			= $('#cddopcao','#'+frmBcb); 
	cCddarqui			= $('#cddarqui','#'+frmBcb); 
	cTodosCabecalho		= $('input[type="text"],select','#'+frmBcb);
	btnCab				= $('#btOK','#'+frmBcb);
	
	cCddarqui.show();
	rCddarqui.show();
	
	rCddopcao.css('width','44px');
	rCddarqui.addClass('rotulo-linha').css({'width':'43px'});
	
	cCddopcao.css({'width':'460px'});
	cCddarqui.css({'width':'460px'});
	
	if ( $.browser.msie ) {
		cCddopcao.css({'width':'456px'});
		cCddarqui.css({'width':'456px'});
	}	
	
	cTodosCabecalho.habilitaCampo();
	
	$('#cddopcao','#'+frmBcb).focus();
				
	layoutPadrao();
	return false;	
}


// botoes
function btnVoltar() {
	estadoInicial();
	return false;
}

function LiberaCampos() {
	
	cOpcao = $('#cddopcao','#frmBcb');
	if (cOpcao.val() == 'C') {
		liberaCamposConfiguracaoWebService();
	}

	if ( $('#cddopcao','#frmBcb').hasClass('campoTelaSemBorda')  ) { return false; }	

	// Desabilita campo opção
	/* cTodosCabecalho		= $('input[type="text"],select','#frmBcb'); 
	cTodosCabecalho.desabilitaCampo(); */
	
	cOpcao.habilitaCampo();	
	$('#divBotoes', '#divTela').css({'display':'block'});
	
	$("#btSalvar","#divBotoes").show();
	$("#btVoltar","#divBotoes").show();
		
	controlaSelect();
	
	trocaBotao('Prosseguir');
	
	$('#cddarqui','#frmBcb').focus();
	
	

	return false;

}

function escondeCamposConfiguracaoWebService(){
	/* Esconde campos da cooperativa */
	rCdcooper			= $('label[for="tlcooper"]','#'+frmBcb); 
	cCdcooper			= $('#tlcooper','#'+frmBcb); 
	rCdcooper.hide();
	cCdcooper.hide();
	
	/* Esconde campos da configuracao WS */
	rFlctgbcb			= $('label[for="flctgbcb"]','#'+frmBcb); 
	cFlctgbcb			= $('#flctgbcb','#'+frmBcb); 	
	rFlctgbcb.hide();
	cFlctgbcb.hide();
}

function liberaCamposConfiguracaoWebService(){
	/* Esconde campos do tipo de Arquivos */
	rCddarqui			= $('label[for="cddarqui"]','#'+frmBcb); 
	cCddarqui			= $('#cddarqui','#'+frmBcb); 
	cCddarqui.hide();
	rCddarqui.hide();
	
	/* Mostra campos da cooperativa */
	rCdcooper			= $('label[for="tlcooper"]','#'+frmBcb); 
	cCdcooper			= $('#tlcooper','#'+frmBcb);
	rCdcooper.show();
	cCdcooper.show();
	/* rCdcooper.habilitaCampo();
	cCdcooper.habilitaCampo();  */
	
	/* Esconde campos da configuracao WS */
	rFlctgbcb			= $('label[for="flctgbcb"]','#'+frmBcb); 
	cFlctgbcb			= $('#flctgbcb','#'+frmBcb); 	
	rFlctgbcb.show();
	cFlctgbcb.show();
	
	liberaCamposConfiguracaoWebServicePosCooperativa();
}

function liberaCamposConfiguracaoWebServicePosCooperativa(){
	cCdcooper = $('#tlcooper','#frmBcb');
	
	hideMsgAguardo();
    mensagem = 'Aguarde, carregando configura&ccedil;&otilde;es...';
    showMsgAguardo(mensagem);
	
	/* Busca configuracao da cooperativa */
	$.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/arqbcb/manter_rotina_webservice.php",
        data: {
            cdcooper: cCdcooper.val(),
			cddopcao: "C",
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
			try {
                eval(response);	
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
            }			
        }
    });
}

function mantemConfiguracaoWebService(){
	cCdcooper = $('#tlcooper','#frmBcb');
	cFlctgbcb = $('#flctgbcb','#frmBcb');
	
	hideMsgAguardo();
    mensagem = 'Aguarde, alterando configura&ccedil;&otilde;es...';
    showMsgAguardo(mensagem);
	
	/* Busca configuracao da cooperativa */
	$.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/arqbcb/manter_rotina_webservice.php",
        data: {
            cdcooper: cCdcooper.val(),
			flctgbcb: cFlctgbcb.val(),
			cddopcao: "A",
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
			try {
                eval(response);	
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
            }			
        }
    });
}

function controlaSelect() {
		
	cCddarqui.empty();
		
	if ( $('#cddopcao','#frmBcb').val() == 'E'){
		cCddarqui.append("<option value='A'> Saldo disponível dos Associados </option>");
		cCddarqui.append("<option value='C'> Solicitação de Cartão </option>");
	} else {
		cCddarqui.append("<option value='D'> Conciliação de Débitos </option>");
	}
	
	return false;

}

function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>');

	if ( botao != '') {
		$('#divBotoes','#divTela').append('&nbsp;<a href="#" class="botao" onClick="btnContinuar(); return false;" >'+botao+'</a>');
	}
	return false;
}

function btnContinuar() {

	$('input,select', '#frmBcb').removeClass('campoErro');

	$cOpcao = $('#cddopcao','#frmBcb');
	/* Se for opcao de C - Configuracao WebService*/
	if ($cOpcao.val() == 'C') {
		mantemConfiguracaoWebService();
	} else {
		cddarqui = cCddarqui.val()
		cddopcao = cCddopcao.val();
		
		realizaOperacao();	
	}
	
	return false;
		
}

function realizaOperacao() {

	// Mostra mensagem de aguardo
	
	if 		(cddopcao == "E"){ showMsgAguardo("Aguarde, gerando arquivo...");  } 
	else if (cddopcao == "R"){ showMsgAguardo("Aguarde, lendo arquivo..."); }
	else 				  	 { showMsgAguardo("Aguarde, abrindo tela..."); 		}
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/arqbcb/manter_rotina.php", 
		timeout:900000,//900 seg = 15min
		data: {
			cddarqui: cddarqui,
			cddopcao: cddopcao,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			
			hideMsgAguardo();			
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","focaCampoErro(\'cddarqui\', \'frmBcb\');",false);
		},
		success: function(response) {
			try {
				hideMsgAguardo();
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});				
}
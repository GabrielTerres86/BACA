/*!
 * FONTE        : autori.js
 * CRIAÇÃO      : Dionathan Henchel
 * DATA CRIAÇÃO : 04/05/2016
 * OBJETIVO     : Biblioteca de funções da tela PARMDA
 * --------------
 * ALTERAÇÕES   : 
 */

// Definição de algumas variáveis globais
var cddopcao = ''; // Armazena a operação corrente da tela PARMDA
var cdcooper = ''; // Armazena a cooperativa atual (Se for 0 seleciona todas)

var frmCab,cCddopcao,cCdcooper,cTodosCabecalho,cTodosPrincipal;

$(document).ready(function() {
	
	estadoInicial();
	
	highlightObjFocus( $('#frmCab') );
	
	return false;
	
});

function estadoInicial() {

	$('#frmCab').css({'display':'block'});
	$('#divDetalhamento').css({'display':'none'});
	$('#divBotoes').css({'display':'none'});
	
	formataCabecalho();
	
	cTodosCabecalho.limpaFormulario();
	cCddopcao.val( cddopcao );
	habilitaopcaotodas();
	
	removeOpacidade('divTela');	
	unblockBackground();
	hideMsgAguardo();
	
	cTodosCabecalho.habilitaCampo();
	cCddopcao.focus();
}

function formataCabecalho() {
	
	// cabecalho
	var rCddopcao = $('label[for="cddopcao"]','#frmCab');
	var rCdcooper = $('label[for="cdcooper"]','#frmCab');
	
	cCddopcao = $('#cddopcao','#frmCab');
	cCdcooper = $('#cdcooper','#frmCab');
	
	cTodosCabecalho = $('input[type="text"],input[type="checkbox"],select','#frmCab');
	
	rCddopcao.css('margin-left', '5px');
	rCdcooper.css('margin-left', '5px');
	
	cCddopcao.css('width', '400px');	
	cCdcooper.css('width', '100px');
	
	layoutPadrao();
	return false;
}

function formataPrincipal() {
	
	var rFlgEnviaSMS  = $('label[for="flgenvia_sms"]','#frmPrincipal');
	var rFlgCobTarifa = $('label[for="flgcobra_tarifa"]','#frmPrincipal');
	var rCdTarifaPF   = $('label[for="cdtarifa_pf"]','#frmPrincipal');
	var rCdTarifaPJ   = $('label[for="cdtarifa_pj"]','#frmPrincipal');
	var rHrEnvioSMS   = $('label[for="hrenvio_sms"]','#frmPrincipal');

	var cFlgEnviaSMS  = $('#flgenvia_sms','#frmPrincipal');
	var cFlgCobTarifa = $('#flgcobra_tarifa','#frmPrincipal');
	var cCdTarifaPF   = $('#cdtarifa_pf','#frmPrincipal');
	var cVlTarifaPF   = $('#vltarifa_pf','#frmPrincipal');
	var cCdTarifaPJ   = $('#cdtarifa_pj','#frmPrincipal');
	var cVlTarifaPJ   = $('#vltarifa_pj','#frmPrincipal');
	var cHrEnvioSMS   = $('#hrenvio_sms','#frmPrincipal');
	
	rFlgEnviaSMS .css('width','180px');
	rFlgCobTarifa.css('width','180px');
	rCdTarifaPF  .css('width','180px');
	rCdTarifaPJ  .css('width','180px');
	rHrEnvioSMS  .css('width','180px');
	
	cCdTarifaPF.addClass('campo inteiro').attr('maxlength','9').css('width','50px');
	cVlTarifaPF.addClass('campo moeda').css('width','100px');
	cCdTarifaPJ.addClass('campo inteiro').attr('maxlength','9').css('width','50px');
	cVlTarifaPJ.addClass('campo moeda').css('width','100px');
	cHrEnvioSMS.addClass('campo').attr('maxlength','5').css('width','45px');
	
	cTodosPrincipal = $('input[type="text"],input[type="checkbox"],select,textarea','#frmPrincipal');
	cTodosPrincipal.desabilitaCampo();
	
	cFlgCobTarifa.unbind('click');
	cCdTarifaPF.unbind('blur');
	cCdTarifaPJ.unbind('blur');
	
	//Habilita os campos apenas para alteração
	if (cddopcao == 'A')
	{
		cTodosPrincipal.habilitaCampo();
		cVlTarifaPF.desabilitaCampo();
		cVlTarifaPJ.desabilitaCampo();
		habilitaTarifas();
		
		cFlgCobTarifa.click(function (event) {
				habilitaTarifas();
		});
		cCdTarifaPF.blur(function (event) {
				realizaOperacao('TPF');
		});
		cCdTarifaPJ.blur(function (event) {
				realizaOperacao('TPJ');
		});
	}
	
	layoutPadrao();
	
	return false;
}

function habilitaopcaotodas() {
	
	cddopcao = cCddopcao.val();
	
	//Remove a opção "Todas" e seleciona Viacredi
	$("option[value='0']", cCdcooper).remove();
    $("option[value='1']", cCdcooper).attr('selected', true);
	
	//Caso for alteração, adiciona a opção todas e seleciona esta
	if (cddopcao == 'A'){
		cCdcooper.prepend($('<option>', {
			value: 0,
			text: 'Todas'
		}));
		
		$("option[value='0']", cCdcooper).attr('selected', true);
	}
}

function LiberaCampos() {
	
	if ( cCddopcao.hasClass('campoTelaSemBorda')  ) { return false; }	
	
	cddopcao = cCddopcao.val();
	cdcooper = normalizaNumero(cCdcooper.val());
	
	//Desabilita campos do cabeçalho
	cTodosCabecalho.desabilitaCampo();
	
	realizaOperacao('C');
	
	$("#btVoltar","#divBotoes").show();
	$("#btProsseguir","#divBotoes").show();
	
	if (cddopcao == 'C') {
		$("#btProsseguir","#divBotoes").hide();
	}
	
	return false;
}

function habilitaTarifas() {
	
	var cFlgCobTarifa = $('#flgcobra_tarifa','#frmPrincipal');
	var cCdTarifaPF   = $('#cdtarifa_pf','#frmPrincipal');
	var cVlTarifaPF   = $('#vltarifa_pf','#frmPrincipal');
	var cCdTarifaPJ   = $('#cdtarifa_pj','#frmPrincipal');
	var cVlTarifaPJ   = $('#vltarifa_pj','#frmPrincipal');
	
	if (cFlgCobTarifa.is(':checked'))
	{
		cCdTarifaPF.habilitaCampo();
		cCdTarifaPJ.habilitaCampo();
	}
	else
	{
		cCdTarifaPF.val('');
		cCdTarifaPJ.val('');
		cVlTarifaPF.val('');
		cVlTarifaPJ.val('');
		cCdTarifaPF.desabilitaCampo();
		cCdTarifaPJ.desabilitaCampo();
	}
}

function btProsseguir() {
	realizaOperacao(cddopcao);
}

function realizaOperacao(pcddopcao) {
	
	var mensagem = '';
	
	hideMsgAguardo();
	
	switch (pcddopcao) {
		case 'C' : mensagem = 'Aguarde, Buscando parâmetros...';    break;		
		case 'A' : mensagem = 'Aguarde, Alterando parâmetros...';   break;		
		case 'TPF' : mensagem = ''; break;
		case 'TPJ' : mensagem = ''; break;
		//case 'E' : mensagem = 'Aguarde, Excluindo parâmetros...';   break;
		default:   return false; break;
	}
	
	if (mensagem != '') {
		showMsgAguardo( mensagem );
	}
	
	var flgenvia_sms    = $('#flgenvia_sms','#frmPrincipal').is(':checked') ? 1 : 0;
	var flgcobra_tarifa = $('#flgcobra_tarifa','#frmPrincipal').is(':checked') ? 1 : 0;
	var hrenvio_sms     = $('#hrenvio_sms','#frmPrincipal').val();
	var cdtarifa_pf     = $('#cdtarifa_pf','#frmPrincipal').val();
	var cdtarifa_pj     = $('#cdtarifa_pj','#frmPrincipal').val();
	var mensagens 		= [];

	if (pcddopcao == 'A')
	{
		// Gera um objeto com o conteúdo das mensagens na tela
		$("textarea","#divMensagens").each(function() {
			if ($(this).val() != '')
			{
				mensagens.push({
						  cdtipo_mensagem: $(this).attr("cdtipo_mensagem"),
						  dsmensagem: $(this).val()
				});
			}
		});
	}
	
	//alert(JSON.stringify(mensagens));
	
	$.ajax({
			type  : 'POST',
			async : true ,
			url   : UrlSite + 'telas/parmda/manter_rotina.php', 		
			data: {
				cddopcao	    : pcddopcao,
				cdcooper	    : cdcooper,
				flgenvia_sms    : flgenvia_sms,
				flgcobra_tarifa : flgcobra_tarifa,
				hrenvio_sms     : hrenvio_sms,
				cdtarifa_pf     : cdtarifa_pf,
				cdtarifa_pj     : cdtarifa_pj,
				json_mensagens	: JSON.stringify(mensagens),
				
				redirect: 'script_ajax'
			},
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial()');
			},
			success: function(response) { 
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							hideMsgAguardo();
							eval(response);
							
							if (pcddopcao == "C")
							{
								$('#divDetalhamento').css({'display':'block'});
								$('#divBotoes', '#divTela').css({'display':'block'});
							}
							
							formataPrincipal();
							
							return false;
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial()');
						}
					} else {
						try {
							eval( response );
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial()');
						}
					}
				}
		});

	
	return false;	
}
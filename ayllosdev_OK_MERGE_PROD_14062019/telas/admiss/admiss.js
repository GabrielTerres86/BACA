/*!
 * FONTE        : admiss.js
 * CRIAÇÃO      : Lucas Lunelli          
 * DATA CRIAÇÃO : 06/02/2013
 * OBJETIVO     : Biblioteca de funções da tela ADMISS
 * --------------
 * ALTERAÇÕES   : 
 *				  
 *				  
 * --------------
 */

var cddopcao			= 'C';
var frmCab   			= 'frmCab';
var frmDadosAdmiss  	= 'frmDadosAdmiss';
var frmOpcao  			= 'frmOpcao';
var tabDadosAdmissMes	= 'tabAdmissMes';
var frmImp				= 'frmImp';

var cCddopcao, cTodosDados, nrregist, nriniseq;

$(document).ready(function() {

	estadoInicial();
	
	highlightObjFocus( $('#'+frmCab) );
	highlightObjFocus( $('#'+frmOpcao) );
	highlightObjFocus( $('#'+frmDadosAdmiss) );
	highlightObjFocus( $('#'+frmImp) );
	
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	
	return false;
	
});

function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);
	$('#frmCab').css({'display':'block'});
	
	controlaLayout();

	cCddopcao.val(cddopcao);
	
	$('input,select', '#frmCab').removeClass('campoErro');
	
	controlaFoco();
	
	cTodosDados.limpaFormulario();
	$('#'+frmDadosAdmiss).limpaFormulario();
	cTodosDados.desabilitaCampo();
	
	removeOpacidade('divTela');
	
	unblockBackground();
	hideMsgAguardo();
	
	$('#'+frmDadosAdmiss).css({'display':'none'});
	
	
	$('#frmOpcao').css({'display':'none'});
	$('#frmImp').css({'display':'none'});
	
	$('#dtdemiss', '#frmOpcao').css({'display':'none'}).val('');
	$('#dtdemiss2', '#frmOpcao').css({'display':'none'});
	
	$('#cdagenci', '#frmOpcao').habilitaCampo();
	$('#dtdemiss', '#frmOpcao').habilitaCampo();
	$('#qtadmtot', '#frmOpcao').val('');
	
	
	$('#divBotoes', '#divTela').css({'display':'none'});
	$("#btSalvar","#divBotoes").hide();
	$("#btVoltar","#divBotoes").hide();
	$('#'+tabDadosAdmissMes).remove();
	$('#divPesquisaRodape').remove();
	$('#tabDemissMes').remove();
	$('#cddopcao','#'+frmCab).habilitaCampo();
	$('#cddopcao','#'+frmCab).focus();
	
	
	$('#cddopcao1', '#frmImp').val('');
	$('#numdopac1', '#frmImp').val('');
	$('#dtdecons1', '#frmImp').val('');
	$('#dtatecon1', '#frmImp').val('');
	
	$('#numdopac','#frmImp').habilitaCampo();
	$('#dtdecons','#frmImp').habilitaCampo();
	$('#dtatecon','#frmImp').habilitaCampo();
	
}

function controlaLayout() {

	//cabeçalho
	var rCddopcao	= $('label[for="cddopcao"]','#'+frmCab); 
	var btnCab		= $('#btOK','#'+frmCab);
	cCddopcao		= $('#cddopcao','#'+frmCab);
	
	rCddopcao.css('width','80px');	
	cCddopcao.css({'width':'546px'});
	
	//dados
	var rQtadmmes	= $('label[for="qtadmmes"]','#'+frmDadosAdmiss);
	var rQtdemmes 	= $('label[for="qtdemmes"]','#'+frmDadosAdmiss);
	var rQtassmes 	= $('label[for="qtassmes"]','#'+frmDadosAdmiss);
	var rQtdslmes 	= $('label[for="qtdslmes"]','#'+frmDadosAdmiss);
	var rVlcapini 	= $('label[for="vlcapini"]','#'+frmDadosAdmiss);
	var rNrmatric  	= $('label[for="nrmatric"]','#'+frmDadosAdmiss);
	var rQtparcap 	= $('label[for="qtparcap"]','#'+frmDadosAdmiss);
	var rVlcapsub 	= $('label[for="vlcapsub"]','#'+frmDadosAdmiss);
	var rFlgabcap 	= $('label[for="flgabcap"]','#'+frmDadosAdmiss);
	
	var rCdagenci 	= $('label[for="cdagenci"]','#'+frmOpcao);
	var rQtadmtot 	= $('label[for="qtadmtot"]','#'+frmOpcao);
	var rDtdemiss 	= $('label[for="dtdemiss"]','#'+frmOpcao);
	
	var rNumdopac 	= $('label[for="numdopac"]','#frmImp');
	var rDtdecons 	= $('label[for="dtdecons"]','#frmImp');
	var rDtatecon 	= $('label[for="dtatecon"]','#frmImp');
	

	rQtadmmes.addClass('rotulo-linha').css('width','380px');
	rQtdemmes.addClass('rotulo-linha').css('width','380px');
	rQtassmes.addClass('rotulo-linha').css('width','380px');
	rQtdslmes.addClass('rotulo-linha').css('width','380px');
	rVlcapini.addClass('rotulo-linha').css('width','380px');
	rNrmatric.addClass('rotulo-linha').css('width','380px');
	rQtparcap.addClass('rotulo-linha').css('width','380px');
	rVlcapsub.addClass('rotulo-linha').css('width','380px');
	rFlgabcap.addClass('rotulo-linha').css('width','380px');	
	
	rCdagenci.addClass('rotulo-linha').css('width','250px');
	rQtadmtot.addClass('rotulo-linha').css('width','80px');
	rDtdemiss.addClass('rotulo-linha').css('width','80px');
	
	rNumdopac.addClass('rotulo-linha').css('width','180px');
	rDtdecons.addClass('rotulo-linha').css('width','100px');
	rDtatecon.addClass('rotulo-linha').css('width','50px');
	
	cTodosDados		= $('input[type="text"],select','#'+frmDadosAdmiss);
	var cQtdemmes 	= $('#qtdemmes','#'+frmDadosAdmiss);
	var cQtadmmes	= $('#qtadmmes','#'+frmDadosAdmiss);
	var cQtassmes 	= $('#qtassmes','#'+frmDadosAdmiss);
	var cQtdslmes 	= $('#qtdslmes','#'+frmDadosAdmiss);
	var cVlcapini 	= $('#vlcapini','#'+frmDadosAdmiss);
	var cNrmatric 	= $('#nrmatric','#'+frmDadosAdmiss);
	var cQtparcap 	= $('#qtparcap','#'+frmDadosAdmiss);
	var cVlcapsub 	= $('#vlcapsub','#'+frmDadosAdmiss);
	var cFlgabcap 	= $('#flgabcap','#'+frmDadosAdmiss);
	
	var cCdagenci 	= $('#cdagenci','#'+frmOpcao);
	var cQtadmtot 	= $('#qtadmtot','#'+frmOpcao);
	var cDtdemiss 	= $('#dtdemiss','#'+frmOpcao);
	
	var cNumdopac 	= $('#numdopac','#frmImp');
	var cDtdecons 	= $('#dtdecons','#frmImp');
	var cDtatecon 	= $('#dtatecon','#frmImp');
		
	cQtdemmes.addClass('campo inteiro');
	cQtadmmes.addClass('campo inteiro').css('width','100px').attr('maxlength','20');
	cQtassmes.addClass('campo inteiro').css('width','100px').attr('maxlength','17');
	cQtdslmes.addClass('campo inteiro').css('width','100px');
	cVlcapini.addClass('campo inteiro').css('width','100px');
	cNrmatric.addClass('campo inteiro').css('width','100px');
	cQtparcap.addClass('campo inteiro').css('width','100px').attr('maxlength','2');
	cVlcapsub.addClass('campo inteiro').css('width','100px').attr('maxlength','40');
	cFlgabcap.addClass('campo').css('width','100px').attr('maxlength','20');
	
	cCdagenci.addClass('campo inteiro').css('width','50px');
	cQtadmtot.addClass('campo inteiro').css('width','60px');
	cDtdemiss.addClass('campo data').css('width','80px');
	
	cNumdopac.addClass('campo inteiro').css('width','50px');
	cDtdecons.addClass('campo data').css('width','80px');
	cDtatecon.addClass('campo data').css('width','80px');
	
	
	cQtdemmes.setMask("INTEGER","zzzz9",".-","");	
	cQtadmmes.setMask("INTEGER","zzz.zz9",".-","");	
	cQtassmes.setMask("INTEGER","zzz.zz9",".-","");	
	cQtdslmes.setMask("INTEGER","zzz.zz9",".-","");
	cVlcapini.setMask("DECIMAL","zzz.zzz.zz9,99","","");
	cNrmatric.setMask("INTEGER","zzz.zz9",".-","");	
	cQtparcap.setMask("INTEGER","z9",".-","");	
	cVlcapsub.setMask("DECIMAL","zzz.zzz.zz9,99","","");
	cCdagenci.setMask("INTEGER","zz9",".-","");
	
	if ( cddopcao == 'C' ) {
	
		$('#'+frmDadosAdmiss).css({'display':'block'});
		$('#divBotoes', '#divTela').css({'display':'block'});			
		$("#btVoltar","#divBotoes").show();
		
		$('#cddopcao','#'+frmCab).focus();
		
		cTodosDados.desabilitaCampo();
	
	} else if ( cddopcao == 'A' ) {
	
		$('#'+frmDadosAdmiss).css({'display':'block'});		
		$('#divBotoes', '#divTela').css({'display':'block'});	
		$("#btVoltar","#divBotoes").show();
		$("#btSalvar","#divBotoes").show();
		
		/* $("#btSalvar","#divBotoes").click(function(){realizaOperacao('A'); return false;}); */
		
	}
	
	layoutPadrao();
	return false;
	
}


function btnVoltar() {
	
	estadoInicial();
	return false;
}

function controlaOperacao( nriniseq, nrregist ) {

	showMsgAguardo('Aguarde, buscando informa&ccedil;&otilde;es...');
	
	var numdopac = $('#cdagenci','#frmOpcao').val();
	var opcao    = $('#cddopcao','#frmCab').val();
	var dtdemiss = $('#dtdemiss','#frmOpcao').val();
	
	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url   : UrlSite + 'telas/admiss/manter_rotina.php',
		data    :
				{ cddopcao	: opcao,			  	
				  numdopac	: numdopac,
				  nrregist  : nrregist,
				  nriniseq  : nriniseq,
				  dtdemiss  : dtdemiss,
				  redirect: 'script_ajax'
				  
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				},
		success : function(response) {
					hideMsgAguardo();
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							$('#divTabela').html(response);
							formataTabela();
							$('#cdagenci','#frmOpcao').desabilitaCampo();
							$('#dtdemiss','#frmOpcao').desabilitaCampo();
							$("#btSalvar","#divBotoes").hide();
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

function realizaOperacao(cddopcao) {

	this.cddopcao = cddopcao;
	$('#cddopcao','#'+frmCab).desabilitaCampo();
	
	var mensagem = '';
	
	hideMsgAguardo();
	
	switch (cddopcao) {	
		case 'C' : mensagem = 'Aguarde, Consultando informa&ccedil;&otilde;es...';    break;		
		case 'A' : mensagem = 'Aguarde, Alterando informa&ccedil;&otilde;es...';      break;
		default:   return false; break;
	}
	
	showMsgAguardo( mensagem );
			
	var vlcapini = normalizaNumero($('#vlcapini','#'+frmDadosAdmiss).val());
	var qtparcap = normalizaNumero($('#qtparcap','#'+frmDadosAdmiss).val());
	var vlcapsub = normalizaNumero($('#vlcapsub','#'+frmDadosAdmiss).val());
	var flgabcap = $('#flgabcap','#'+frmDadosAdmiss).val();
	
	var numdopac = normalizaNumero($('#numdopac','#frmImp').val());
	var dtdecons = $('#dtdecons','#frmImp').val();
	var dtatecon = $('#dtatecon','#frmImp').val();
	
	$.ajax({		
			type  : 'POST',
			async : true ,
			url   : UrlSite + 'telas/admiss/manter_rotina.php', 		
			data: {
				vlcapini: vlcapini,
				qtparcap: qtparcap,
				vlcapsub: vlcapsub,
				flgabcap: flgabcap,
				cddopcao: cddopcao,
				numdopac: numdopac,
				dtdecons: dtdecons,
				dtatecon: dtatecon,
				redirect: 'script_ajax'
			}, 
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
			},
			success: function(response) {
				try {
				
					hideMsgAguardo();
					eval(response);
					
					controlaLayout();
					
					// Utilizo a regra abaixo para habilitar os campos apenas quando
					// operador clicou no botao OK e nao mais quando clicar em concluir
					// Regra valida apenas para opcao A - Alterar
					if ( ($('#cddopcao','#'+frmCab).val() == "A") && cddopcao == "C" ){
						habilitaCampos();
						$("#btSalvar","#divBotoes").show();
					}
					
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		});

	
	return false;	

}

function habilitaCampos() {
	
	$('#vlcapini','#'+frmDadosAdmiss).habilitaCampo();
	$('#qtparcap','#'+frmDadosAdmiss).habilitaCampo();
	$('#vlcapsub','#'+frmDadosAdmiss).habilitaCampo();
	$('#flgabcap','#'+frmDadosAdmiss).habilitaCampo();
	$('#vlcapsub','#'+frmDadosAdmiss).focus();

	return false;
}

function formataTabela() {

	if ( $('#cddopcao','#frmCab').val() == "L") {

		$('#divRotina').css('width','640px');

		// tabela
		var divRegistro = $('div.divRegistros', '#'+tabDadosAdmissMes);		
		var tabela      = $('table', divRegistro );
		var linha       = $('table > tbody > tr', divRegistro );
		
		$('#'+tabDadosAdmissMes).css({'margin-top':'5px'});
		divRegistro.css({'height':'230px','width':'100%'});
		
		var ordemInicial = new Array();
		ordemInicial = [[0,0]];	

		var arrayLargura = new Array();
		arrayLargura[0] = '40px';
		arrayLargura[1] = '80px';
		arrayLargura[2] = '80px';
		
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'right';
		arrayAlinha[2] = 'right';
		arrayAlinha[3] = 'left';
		
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
		
	} else {
	
		$('#divRotina').css('width','640px');

		// tabela
		var divRegistro = $('div.divRegistros', '#tabDemissMes');		
		var tabela      = $('table', divRegistro );
		var linha       = $('table > tbody > tr', divRegistro );
		
		$('#tabDemissMes').css({'margin-top':'5px'});
		divRegistro.css({'height':'230px','width':'100%'});
		
		var ordemInicial = new Array();
		ordemInicial = [[0,0]];	

		var arrayLargura = new Array();
		arrayLargura[0] = '66px';
		arrayLargura[1] = '35px';
		arrayLargura[2] = '70px';
		arrayLargura[3] = '280px';
		arrayLargura[4] = '30px';
		
		var arrayAlinha = new Array();
		arrayAlinha[0] = 'right';
		arrayAlinha[1] = 'right';
		arrayAlinha[2] = 'right';
		arrayAlinha[3] = 'left';
		arrayAlinha[4] = 'left';
		arrayAlinha[5] = 'left';
		
		tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	
	}

	return false;
}


function botaoOK() {

	// Campo opcao esta habilitado
	if ($('#cddopcao','#frmCab').prop('disabled') == false) {
	
		if($('#cddopcao','#frmCab').val() == 'A'){
			realizaOperacao('C') ;
		} else{
		
			if ( ( $('#cddopcao','#frmCab').val() == 'L') || 
			     ( $('#cddopcao','#frmCab').val() == 'D') ||
				 ( $('#cddopcao','#frmCab').val() == 'N') ) {
				liberaOpcaoPac();
			} 
			else {
				realizaOperacao($('#cddopcao','#frmCab').val()); 
			}
		}	
		
	} else {
	
		if ($('#cddopcao','#frmCab').val() == 'A') {
			showConfirmacao('Confirma a altera&ccedil;&atilde;o dos dados?','Confirma&ccedil;&atilde;o - Ayllos','realizaOperacao(\'A\');','return false;','sim.gif','nao.gif');	
			return false;
		}
		
		if ($('#cddopcao','#frmCab').val() == 'N') {
			 
			realizaOperacao($('#cddopcao','#frmCab').val()); 
		}
	}
	
	return false;

}


function liberaOpcaoPac(){

	$('#cddopcao','#frmCab').desabilitaCampo();

	if ( $('#cddopcao','#frmCab').val() == 'N' ) {
		$('#frmImp').css({'display':'block'});
		$('#numdopac','#frmImp').focus().val("");
		
		var dtatecon = $('#glbdtmvt','#frmCab').val();
		var dtdecons = "01/" + dtatecon.split("/")[1].toString() + "/" + dtatecon.split("/")[2].toString()
		
		$('#dtdecons','#frmImp').val(dtdecons);
		$('#dtatecon','#frmImp').val(dtatecon);
		
		
	} else {
		$('#frmOpcao').css({'display':'block'});
		$('#cdagenci','#frmOpcao').focus().val("");
	}
	
	
	$('#divBotoes', '#divTela').css({'display':'block'});

	$("#btVoltar","#divBotoes").show();
	$("#btSalvar","#divBotoes").show();

	$('#qtadmtot','#frmOpcao').desabilitaCampo();

	hideMsgAguardo();

	if ( $('#cddopcao','#frmCab').val() == 'D' ) {
		$('#dtdemiss', '#frmOpcao').css({'display':'block'});
		$('#dtdemiss2', '#frmOpcao').css({'display':'block'});
		var rCdagenci 	= $('label[for="cdagenci"]','#'+frmOpcao);
		rCdagenci.addClass('rotulo-linha').css('width','180px');
		
		var auxdtmvt = $('#glbdtmvt','#frmCab').val();
		var dtdemiss = "01/" + auxdtmvt.split("/")[1].toString() + "/" + auxdtmvt.split("/")[2].toString()
		
		$('#dtdemiss','#frmOpcao').val(dtdemiss);
		
	}
	
	return false;
}

function controlaOpcao(){

	var aux = $('#cddopcao','#frmCab').val();
	
	switch( aux )
	{
		case 'L':
			controlaOperacao(1,30);
			break;
		case 'D':
			controlaOperacao(1,30);
			break;
		case 'A':
			botaoOK();
			break;		
		case 'N':
			Gera_Impressao();
			break;
	}
}


function controlaFoco() {

	$('#cddopcao','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#btnOK','#frmCab').focus();
			return false;
		}	
	});
	
	$('#btnOK','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {		
			botaoOK();
			return false;
		}	
	});
	
	$('#cdagenci','#frmOpcao').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			if ( $('#cddopcao','#frmCab').val() == 'D' ) {
				$('#dtdemiss','#frmOpcao').focus();
			} else {
				controlaOpcao();
			}
			return false;
		}	
	});
	
	$('#dtdemiss','#frmOpcao').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			controlaOpcao();
			return false;
		}	
	});
	
	$('#vlcapsub','#frmDadosAdmiss').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#vlcapini','#frmDadosAdmiss').focus();
			return false;
		}	
	});
	
	$('#vlcapini','#frmDadosAdmiss').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#qtparcap','#frmDadosAdmiss').focus();
			return false;
		}	
	});
	
	$('#qtparcap','#frmDadosAdmiss').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#flgabcap','#frmDadosAdmiss').focus();
			return false;
		}	
	});
	
	$('#flgabcap','#frmDadosAdmiss').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			botaoOK();
			return false;
		}	
	});
	
	$('#numdopac','#frmImp').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#dtdecons','#frmImp').focus();
			return false;
		}	
	});
	
	$('#dtdecons','#frmImp').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#dtatecon','#frmImp').focus();
			return false;
		}	
	});
	
	$('#dtatecon','#frmImp').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			controlaOpcao();
			return false;
		}	
	});
	
}



function Gera_Impressao() {	

	var cddopcao = "N"; 
	var numdopac = $('#numdopac','#frmImp').val();	
	var dtdecons = $('#dtdecons','#frmImp').val();
	var dtatecon = $('#dtatecon','#frmImp').val();	

	numdopac = normalizaNumero(numdopac);
	
	$('#cddopcao1','#frmImp').val(cddopcao);
	$('#numdopac1','#frmImp').val(numdopac);
	$('#dtdecons1','#frmImp').val(dtdecons);	
	$('#dtatecon1','#frmImp').val(dtatecon);
	
	$('#numdopac','#frmImp').desabilitaCampo();
	$('#dtdecons','#frmImp').desabilitaCampo();
	$('#dtatecon','#frmImp').desabilitaCampo();
	
	var action = UrlSite + 'telas/admiss/gera_impressao.php';
	
	$('#sidlogin','#frmImp').remove();
	
	$('#frmImp').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '" />');
	
	carregaImpressaoAyllos("frmImp",action,"estadoInicial();");
	
	return false;
		
}
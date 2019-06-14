/*!
 * FONTE        : movtos.js
 * CRIAÇÃO      : Jéssica (DB1) 
 * DATA CRIAÇÃO : 24/02/2014							Útilma Alteração: 03/12/2014
 * OBJETIVO     : Biblioteca de funções da tela MOVTOS
 * --------------
 * ALTERAÇÕES   : 25/11/2014 - Criado rotina para apresentar um pop-up na opção C
 *							   (Jéssica - DB1).
                
				  03/12/2014 - Ajustes para liberação (Adriano).
 
 
 */
 
 var nometela;

//Formulários e Tabela
var frmCab   	 = 'frmCab';
var frmConsulta  = 'frmConsulta';
var frmOpcaoF    = 'frmOpcaoF';
var frmOpcaoL    = 'frmOpcaoL';
var frmOpcaoR    = 'frmOpcaoR';
var frmOpcaoS    = 'frmOpcaoS';
var frmOpcaoE    = 'frmOpcaoE';
var frmLocal     = 'frmLocal';
var divConsulta	 = 'divConsulta';
var divSituacao  = 'divSituacao';
var divSaida  	 = 'divSaida';
var divBotoes    = 'divBotoes';
var divTabela;
	
$(document).ready(function() {

	divTabela = $('#divTabela');
	estadoInicial();
			
	return false;
		
});

// inicio
function estadoInicial() {

	$('#divTabela').html('');
	$('#divSaida').html('');
	
	$('#frmConsulta').limpaFormulario();
	$('#frmOpcaoF').limpaFormulario();
	$('#frmOpcaoL').limpaFormulario();
	$('#frmOpcaoR').limpaFormulario();
	$('#frmOpcaoS').limpaFormulario();
	$('#frmDetalhe').limpaFormulario();
	$('#frmOpcaoE').limpaFormulario();
		
	formataCabecalho();	
	formataConsulta();
	formataOpcaoF();
	formataOpcaoL();
	formataOpcaoR();
	formataOpcaoS();
	formataOpcaoE();
	formataSitBradesco();
	formataSaidaGB();
	
	$('#divBotoes','#divTela').css('display','none');	
	
	return false;	
	
}

// formata
function formataCabecalho() {
		
	var cTodosCabecalho	= $('input[type="text"],select','#'+frmCab);		
	var btnOK			= $('#btnOK','#'+frmCab);
	
	//Cabecalho
	var rCddopcao			= $('label[for="cddopcao"]','#'+frmCab);	
	var cCddopcao			= $('#cddopcao','#'+frmCab);
	
	rCddopcao.css('width','40px').addClass('rotulo');
	cCddopcao.css('width','530px');
	
	$('#divTela').css({'display':'inline'}).fadeTo(0,0.1);
	removeOpacidade('divTela');	
	$('#'+frmCab).css('display','block');
		
	cTodosCabecalho.habilitaCampo();
	cCddopcao.focus();	
	
	btnOK.unbind('click').bind('click', function() {
				
		if ( divError.css('display') == 'block' ) { return false; }		
		
		cTodosCabecalho.removeClass('campoErro');	
		cCddopcao.desabilitaCampo();		
		
		controlaLayout();
			
	});
	
	cCddopcao.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }

		// Se é a tecla ENTER ou TAB
		if ( e.keyCode == 13 || e.keyCode == 9) {

			btnContinuar();
			return false;
		}

	});
		
	$('#frmConsulta').css('display','none');
	$('#frmOpcaoF').css('display','none');
	$('#frmOpcaoL').css('display','none');
	$('#frmOpcaoR').css('display','none');
	$('#frmOpcaoS').css('display','none');
	$('#frmOpcaoE').css('display','none');
	$('#divBotoes').css('display','none');
				
	highlightObjFocus( $('#frmCab') );
	highlightObjFocus( $('#frmConsulta') );
	highlightObjFocus( $('#frmOpcaoF') );
	highlightObjFocus( $('#frmOpcaoL') );
	highlightObjFocus( $('#frmOpcaoR') );
	highlightObjFocus( $('#frmOpcaoS') );
	highlightObjFocus( $('#frmOpcaoE') );
	highlightObjFocus( $('#divBotoes') );
					
	layoutPadrao();
	
	cCddopcao.focus();	
		
	return false;	
}

function controlaLayout() {

	var cddopcao = $('#cddopcao','#'+frmCab).val();
	
	$('#divBotoes','#divTela').css('display','block');

	if(cddopcao == "C"){
	
		$('#frmConsulta').css('display','block');
								
		$('#tpdopcao','#'+frmConsulta).focus();
		
		$('#tpdopcao','#'+frmConsulta).unbind('change').bind('change', function() {
		
			if($('#tpdopcao','#'+frmConsulta).val() == "Todos Cartoes"){
			
				$('#dsadmcrd','#divConsulta').unbind('change').bind('change', function() {
				
					if($(this).val() == "BANCO DO BRASIL"){
					
						$('#divSituacao').css('display','none');
						$('label[name="situacao"]','#divConsulta').css('display','none');
						$('input[type="checkbox"]','#divConsulta').css('display','block');
						$('label[name="situacao"]','#divConsulta').css('display','block');
						$('label[for="situacao"]','#divSituacao').css('display','none');
						$('label[for="situacao"]','#divConsulta').css('display','block');
												
						$('#divSaida').css('display','none');
						$('#lgvisual','#divConsulta').css('display','block');
						$('label[for="lgvisual"]','#divConsulta').css('display','block');
			
						$('#dtinicio','#divConsulta').desabilitaCampo();
						$('#ddtfinal','#divConsulta').desabilitaCampo();
						$('#tpdomvto','#divConsulta').habilitaCampo();
						$('#dtprdini','#divConsulta').desabilitaCampo();
						$('#dtprdfin','#divConsulta').desabilitaCampo();
						$('input[type="checkbox"]','#divConsulta').habilitaCampo();
				
					} else{
					
						$('#divSituacao').css('display','block');
						$('label[name="situacao"]','#divSituacao').css('display','block');
						$('input[type="checkbox"]','#divConsulta').css('display','none');
						$('label[name="situacao"]','#divConsulta').css('display','none');
						$('label[for="situacao"]','#divSituacao').css('display','block');
						$('label[for="situacao"]','#divConsulta').css('display','none');
						
						$('#divSaida').css('display','none');
						$('#lgvisual','#divConsulta').css('display','block');
						$('label[for="lgvisual"]','#divConsulta').css('display','block');
					
						$('#dtinicio','#divConsulta').desabilitaCampo();
						$('#ddtfinal','#divConsulta').desabilitaCampo();
						$('#tpdomvto','#divConsulta').desabilitaCampo();
						$('#dtprdini','#divConsulta').desabilitaCampo();
						$('#dtprdfin','#divConsulta').desabilitaCampo();
						$('input[type="checkbox"]','#divSituacao').habilitaCampo();
											
					}
					return false;
				});	
			
				$('#dsadmcrd','#divConsulta').trigger('change');

				$('#tpdomvto','#divConsulta').unbind('change').bind('change', function() {
				
					if($(this).val() == "C"){
						
						$('#dtprdini').limpaFormulario();
						$('#dtprdfin').limpaFormulario();
																		
						$('#dtinicio','#divConsulta').desabilitaCampo();
						$('#ddtfinal','#divConsulta').desabilitaCampo();
						$('#dsadmcrd','#divConsulta').habilitaCampo();
						$('#dtprdini','#divConsulta').desabilitaCampo();
						$('#dtprdfin','#divConsulta').desabilitaCampo();
						$('input[type="checkbox"]','#divConsulta').habilitaCampo();
				
					} else{
					
						$('#dtinicio','#divConsulta').desabilitaCampo();
						$('#ddtfinal','#divConsulta').desabilitaCampo();
						$('#dsadmcrd','#divConsulta').habilitaCampo();
						$('#dtprdini','#divConsulta').habilitaCampo();
						$('#dtprdfin','#divConsulta').habilitaCampo();
						$('input[type="checkbox"]','#divConsulta').habilitaCampo();
					
					}
					return false;
				});	
			
				$('#tpdomvto','#divConsulta').trigger('change');					
							
			}else if($('#tpdopcao','#'+frmConsulta).val() == "Por Periodo"){
			
				$('#dsadmcrd','#divConsulta').unbind('change').bind('change', function() {
				
					if($(this).val() == "BANCO DO BRASIL"){
					
						$('#divSaida').css('display','none');
						$('#lgvisual','#divConsulta').css('display','block');
						$('label[for="lgvisual"]','#divConsulta').css('display','block');
						
						$('#divSituacao').css('display','none');
						$('label[name="situacao"]','#divConsulta').css('display','none');
						$('input[type="checkbox"]','#divConsulta').css('display','block');
						$('label[name="situacao"]','#divConsulta').css('display','block');
						$('label[for="situacao"]','#divSituacao').css('display','none');
						$('label[for="situacao"]','#divConsulta').css('display','block');
						
						$('#dtinicio','#divConsulta').habilitaCampo();
						$('#ddtfinal','#divConsulta').habilitaCampo();
						$('#dsadmcrd','#divConsulta').habilitaCampo();
						$('#tpdomvto','#divConsulta').desabilitaCampo();
						$('#dtprdini','#divConsulta').desabilitaCampo();
						$('#dtprdfin','#divConsulta').desabilitaCampo();
						$('input[type="checkbox"]','#divConsulta').habilitaCampo();
						
					} else{
					
						$('#divSaida').css('display','none');
						$('#lgvisual','#divConsulta').css('display','block');
						$('label[for="lgvisual"]','#divConsulta').css('display','block');
						
						$('#divSituacao').css('display','block');
						$('label[name="situacao"]','#divSituacao').css('display','block');
						$('input[type="checkbox"]','#divConsulta').css('display','none');
						$('label[name="situacao"]','#divConsulta').css('display','none');
						$('label[for="situacao"]','#divSituacao').css('display','block');
						$('label[for="situacao"]','#divConsulta').css('display','none');
					
						$('#dtinicio','#divConsulta').habilitaCampo();
						$('#ddtfinal','#divConsulta').habilitaCampo();
						$('#dsadmcrd','#divConsulta').habilitaCampo();
						$('#tpdomvto','#divConsulta').desabilitaCampo();
						$('#dtprdini','#divConsulta').desabilitaCampo();
						$('#dtprdfin','#divConsulta').desabilitaCampo();
						$('input[type="checkbox"]','#divSituacao').habilitaCampo();
					
					}
					return false;
				});	
			
				$('#dsadmcrd','#divConsulta').trigger('change');
				
			}else{
				
				$('#divSaida').css('display','block');
				$('#lgvisual','#divConsulta').css('display','none');
				$('label[for="lgvisual"]','#divConsulta').css('display','none');	
				$('#dtinicio','#divConsulta').desabilitaCampo();
				$('#ddtfinal','#divConsulta').desabilitaCampo();
				$('#dsadmcrd','#divConsulta').desabilitaCampo();
				$('#tpdomvto','#divConsulta').desabilitaCampo();
				$('#dtprdini','#divConsulta').desabilitaCampo();
				$('#dtprdfin','#divConsulta').desabilitaCampo();
				$('input[type="checkbox"]','#divConsulta').desabilitaCampo();
				$('input[type="checkbox"]','#divSituacao').desabilitaCampo();
								
			}
			
			return false;
			
		});	
		
		$('#tpdopcao','#'+frmConsulta).trigger('change');
		
	}else if(cddopcao == "F"){
	
		$('#frmOpcaoF').css('display','block');
		$('#cdempres','#'+frmOpcaoF).val('');
		
		$('#cdempres','#divOpcaoF').focus();
				
	}else if(cddopcao == "L"){
	
		$('#frmOpcaoL').css('display','block');
		
		$('#dtinicio','#divOpcaoL').focus();
				
	}else if(cddopcao == "R"){
	
		$('#frmOpcaoR').css('display','block');		
		$('#cdagenci','#frmOpcaoR').focus();
				
	}else if(cddopcao == "S"){
	
		$('#frmOpcaoS').css('display','block');
		$('#cdagenci','#divOpcaoS').focus();
		
	}else if(cddopcao == "E"){
	
		$('#frmOpcaoE').css('display','block');
		$('#lgvisual','#divOpcaoE').focus();
		
	}else if(cddopcao == "A"){
	
		buscaLinhasFinalides(1);
				
	}
			
	return false;
	
}

//botoes
function btnVoltar() {

	$('#frmConsulta').limpaFormulario();
	$('#frmOpcaoF').limpaFormulario();
	$('#frmOpcaoL').limpaFormulario();
	$('#frmOpcaoR').limpaFormulario();
	$('#frmOpcaoS').limpaFormulario();
	$('#frmDetalhe').limpaFormulario();
	$('#frmOpcaoE').limpaFormulario();
	
	$('#divBotoes','#divTela').css('display','none');		
	
	estadoInicial();
		
	return false;
}

function btnContinuar() {

	var cddopcao = $('#cddopcao','#'+frmCab).val();
	
	if ( divError.css('display') == 'block' ) { return false; }		
		
	if ( $('#cddopcao','#'+frmCab).hasClass('campo') ) {
		$('#btnOK','#'+frmCab).click();
		
	}else {
		
		if(cddopcao == "C" && $('#lgvisual','#'+frmConsulta).val() == "A"){
		
			buscaLocal();
			
		}else if(cddopcao == "C" && $('#lgvisual','#'+frmConsulta).val() == "I"){
		
			imprimirDados(1);			
						
		}else if(cddopcao == "C" && ($('#divSaida').css('display')=='block')){	
		
			buscaLocal();
					
		}else if(cddopcao == "F"){
		
			if ($('#lgvisual','#'+frmOpcaoF).val() == "A") {
				buscaLocal();
				
			} else if ($('#lgvisual','#'+frmOpcaoF).val() == "I") {
				imprimirDados(1);
			}
		
		}else if(cddopcao == "L"){
				
			if ($('#lgvisual','#'+frmOpcaoL).val() == "A") {
				buscaLocal();
				
			} else if ($('#lgvisual','#'+frmOpcaoL).val() == "I") {
				imprimirDados(1);
			}
				
		}else if(cddopcao == "R"){
		
			if($('#lgvisual','#'+frmOpcaoR).val() == "A") {
				
				buscaLocal();
				
			} else if($('#lgvisual','#'+frmOpcaoR).val() == "I"){
			
				imprimirDados(1);
			}
				
		}else if(cddopcao == "S"){
		
			if ($('#lgvisual','#'+frmOpcaoS).val() == "A") {
				buscaLocal();
				
			} else if ($('#lgvisual','#'+frmOpcaoS).val() == "I") {
				imprimirDados(1);
			}
				
		}else if(cddopcao == "A"){
						
			buscaLocal();
							
		}else if(cddopcao == "E"){
		
			if ($('#lgvisual','#'+frmOpcaoE).val() == "A") {
				buscaLocal();
				
			} else if ($('#lgvisual','#'+frmOpcaoE).val() == "I") {
				imprimirDados(1);
			}
		}
	}	
							
	return false;

}

function buscaLinhasFinalides(nriniseq) {	
	
	var cddopcao = $('#cddopcao','#'+frmCab).val();
	
	showMsgAguardo('Aguarde, buscando informações...');

	$.ajax({		
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/movtos/busca_linhas_finalidades.php', 
		data    :
				{ 
				  cddopcao 	: cddopcao, 	 
				  nrregist  : 50,
				  nriniseq  : nriniseq,
				  redirect  : 'script_ajax'				  
				  
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
							return false;
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
						}
					} else {
						try {
							eval( response );
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
						}
					}
					
				}
	}); 
}

function buscaLocal() {

	hideMsgAguardo();

	showMsgAguardo('Aguarde, abrindo ...');

	$.ajax({
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/movtos/arquivo.php',
		data: {			
			   redirect: 'script_ajax'
			},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {

			hideMsgAguardo();
			
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divRotina').html(response);					
					exibeRotina($('#divRotina'));
					formataArquivo();
					return false;
				} catch(error) {					
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			} else {
				try {
					eval( response );
				} catch(error) {					
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
				}
			}
		}
	});
	return false;
}

function validaArquivo(){

	var nmarquiv = $('#nmarquiv','#'+frmLocal).val();
	
	if ( nmarquiv == '' ){
		showError('error','Arquivo n&atilde;o informado.','Alerta - Ayllos','bloqueiaFundo($(\'#divRotina\'));$(\'#nmarquiv\',\'#frmLocal\').focus();'); return false;
	}

	imprimirDados(0,nmarquiv);
			
	return false;

}

// imprimir .TXT
function imprimirDados(gerarpdf,nmarquiv) {

	showMsgAguardo('Aguarde, Gerando Arquivo...');
	
	var cddopcao = $('#cddopcao','#'+frmCab).val();
				
	if(cddopcao == "C"){
	
		var tpdopcao = $('#tpdopcao','#'+frmConsulta).val();	
		var dsadmcrd = $('#dsadmcrd','#'+frmConsulta).val();
		var tpdomvto = $('#tpdomvto','#'+frmConsulta).val();
		var lgvisual = $('#lgvisual','#'+divConsulta).val();
	
		if(tpdopcao == "Por Periodo"){
			var dtinicio = $('#dtinicio','#'+frmConsulta).val(); 
			var ddtfinal = $('#ddtfinal','#'+frmConsulta).val();
		}else{
			var dtinicio = $('#dtprdini','#'+frmConsulta).val(); 
			var ddtfinal = $('#dtprdfin','#'+frmConsulta).val();
		}
		
		var situacao = "";
	
		if($('#dsadmcrd','#divConsulta').val() == "BANCO DO BRASIL" ){ 
		
			$('input:checkbox:checked', '#divConsulta' ).each(function () {
				situacao += $(this).val() + ",";
			});		
			
		}else if($('#dsadmcrd','#divConsulta').val() == "BRADESCO" ){
		
			$('input:checkbox:checked', '#divSituacao' ).each(function () {
				situacao += $(this).val() + ",";
			});
			
		}
		
	}else if(cddopcao == "L"){
	
		var dtinicio = $('#dtinicio','#'+frmOpcaoL).val(); 
		var ddtfinal = $('#ddtfinal','#'+frmOpcaoL).val();
		var lgvisual = $('#lgvisual','#'+frmOpcaoL).val();
		
	}else if(cddopcao == "R"){
	
		var tppessoa = $('#tppessoa','#'+frmOpcaoR).val();
		var cdultrev = $('#cdultrev','#'+frmOpcaoR).val();
		var cdagenci = $('#cdagenci','#'+frmOpcaoR).val();
		var lgvisual = $('#lgvisual','#'+frmOpcaoR).val();
		
	}else if(cddopcao == "S"){
	
		var tpcontas = $('#tpcontas','#'+frmOpcaoS).val();
		var cdagenci = $('#cdagenci','#'+frmOpcaoS).val();
		var lgvisual = $('#lgvisual','#'+frmOpcaoS).val();
		
	}else if(cddopcao == "F"){
	
		var cdempres = $('#cdempres','#'+frmOpcaoF).val();
		var lgvisual = $('#lgvisual','#'+frmOpcaoF).val();
		
	}else if(cddopcao == "E"){
	
		var lgvisual = $('#lgvisual','#'+frmOpcaoE).val();
		
	}else if(cddopcao == "A"){
				
		var linhaCred = '';
		var finalidade = '';
		
		$("input:checked",$("#registrosLinhaCredito")).each( function(index){
			linhaCred += $(this).val() + ",";		
		});
		
		$("input:checked",$("#registrosFinalidade")).each( function(index){
			finalidade += $(this).val() + ",";		
		});	
		
	}

	$.ajax({
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/movtos/imprimir_dados.php',
		data    :
				{ cddopcao : cddopcao, 	 
				  tpdopcao : tpdopcao,
				  cdagenci : cdagenci,
				  cdempres : cdempres,
				  dtinicio : dtinicio,
				  ddtfinal : ddtfinal,
				  tppessoa : tppessoa,
				  cdultrev : cdultrev,				  
				  lgvisual : lgvisual,
				  tpcontas : tpcontas,		
				  nmarquiv : nmarquiv,
				  situacao : situacao,
				  tpdomvto : tpdomvto,
				  linhacre : linhaCred,
				  finalida : finalidade,
				  dsadmcrd : dsadmcrd,
				  gerarpdf : gerarpdf,
				  redirect: 'script_ajax'

				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#tpChequ1\',\'#frmTipoCheque\').focus();');
				},
		success : function(response) {
					hideMsgAguardo();				
					try {
						eval( response );						
					} catch(error) {						
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','blockBackground(parseInt($("#divRotina").css("z-index")));$("#orgbenef","#frmTrocaDomicilio").focus();');
					}

				}
	});
		
	return false;
	
}

function Gera_Impressao(nmarqpdf) {	
	
	var cddopcao = $('#cddopcao','#'+frmCab).val();
	
	hideMsgAguardo();	
	
	var action = UrlSite + 'telas/inss/imprimir_pdf.php';
	
	if(cddopcao == "C"){
		
		$('#nmarqpdf','#frmConsulta').remove();	
		$('#sidlogin','#frmConsulta').remove();	
		$('#frmConsulta').append('<input type="hidden" id="nmarqpdf" name="nmarqpdf" value="' + nmarqpdf + '" />');	
		$('#frmConsulta').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '" />');	
		carregaImpressaoAyllos("frmConsulta",action,"estadoInicial();");

	}else if(cddopcao == "F"){
	
		$('#nmarqpdf','#frmOpcaoF').remove();	
		$('#sidlogin','#frmOpcaoF').remove();	
		$('#frmOpcaoF').append('<input type="hidden" id="nmarqpdf" name="nmarqpdf" value="' + nmarqpdf + '" />');	
		$('#frmOpcaoF').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '" />');	
		
		carregaImpressaoAyllos("frmOpcaoF",action,"estadoInicial();");
		
	}else if(cddopcao == "L"){
	
		$('#nmarqpdf','#frmOpcaoL').remove();
		$('#sidlogin','#frmOpcaoL').remove();
		$('#frmOpcaoL').append('<input type="hidden" id="nmarqpdf" name="nmarqpdf" value="' + nmarqpdf + '" />');	
		$('#frmOpcaoL').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '" />');	
		
		carregaImpressaoAyllos("frmOpcaoL",action,"estadoInicial();");
				
	}else if(cddopcao == "R"){
		
		$('#nmarqpdf','#frmOpcaoR').remove();
		$('#sidlogin','#frmOpcaoR').remove();
		$('#frmOpcaoR').append('<input type="hidden" id="nmarqpdf" name="nmarqpdf" value="' + nmarqpdf + '" />');	
		$('#frmOpcaoR').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '" />');	
		
		carregaImpressaoAyllos("frmOpcaoR",action,"estadoInicial();");
										
	}else if(cddopcao == "S"){
		
		$('#nmarqpdf','#frmOpcaoS').remove();
		$('#sidlogin','#frmOpcaoS').remove();
		$('#frmOpcaoS').append('<input type="hidden" id="nmarqpdf" name="nmarqpdf" value="' + nmarqpdf + '" />');	
		$('#frmOpcaoS').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '" />');	
		
		carregaImpressaoAyllos("frmOpcaoS",action,"estadoInicial();");
		
	}else if(cddopcao == "A"){
		
		$('#nmarqpdf','#frmOpcaoA').remove();
		$('#sidlogin','#frmOpcaoA').remove();
		$('#frmOpcaoA').append('<input type="hidden" id="nmarqpdf" name="nmarqpdf" value="' + nmarqpdf + '" />');	
		$('#frmOpcaoA').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '" />');	
		
		carregaImpressaoAyllos("frmLocal",action,"estadoInicial();");
				
	}else if(cddopcao == "E"){
	
		$('#nmarqpdf','#frmOpcaoE').remove();
		$('#sidlogin','#frmOpcaoE').remove();
		$('#frmOpcaoE').append('<input type="hidden" id="nmarqpdf" name="nmarqpdf" value="' + nmarqpdf + '" />');	
		$('#frmOpcaoE').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin','#frmMenu').val() + '" />');	
		
		carregaImpressaoAyllos("frmOpcaoE",action,"estadoInicial();");
	}
		
}

function formataTabela() {

	var divRegistro = $('div.divRegistros', divTabela );	
	
	var tabela      = $('table', divRegistro );
	
	selecionaMovtoC($('table > tbody > tr:eq(0)', divRegistro));
	
	divRegistro.css({'height':'207px','border-bottom':'1px dotted #777','padding-bottom':'2px'});	
	divTabela.css({'padding-top':'10px'});	
		
	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '91px';
	arrayLargura[1] = '43px';
	arrayLargura[2] = '59px';
	arrayLargura[3] = '59px';
	arrayLargura[4] = '161px';
				
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'left';
	arrayAlinha[3] = 'right';	
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'right';
	
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
	
	$('table > tbody > tr', divRegistro).focus( function() {
		selecionaMovtoC($(this));
	
	});
	
	// seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		selecionaMovtoC($(this));

	});
			
	divTabela.css({'display':'block'});
	
	return false;
}

function formataArquivo(){

	var cNmarquiv = $('#nmarquiv','#'+frmLocal);
    var rNmarquiv  = $('label[for="nmarquiv"]','#'+frmLocal);
	
	rNmarquiv.addClass('rotulo').css({'width':'180px'});
	
	cNmarquiv.css({'width':'180px'});
	cNmarquiv.habilitaCampo();
	cNmarquiv.focus();
	
	cNmarquiv.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }

		// Se é a tecla ENTER ou TAB
		if ( e.keyCode == 13 || e.keyCode == 9) {

			showConfirmacao('Confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','validaArquivo();','$(\'#nmarquiv\',\'#frmLocal\').focus();bloqueiaFundo($(\'#divRotina\'));','sim.gif','nao.gif');			
			return false;
		}

	});

	return false;
}

function formataLinCred() {

	var divRegistro = $('div.divRegistros', divTabela );	
	
	var tabela      = $('#linCred');
	
	divRegistro.css({'height':'207px','border-bottom':'1px dotted #777','padding-bottom':'2px'});	
			
	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '45px';
	arrayLargura[1] = '50px';
		
			
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'left';
		
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
				
	divTabela.css({'display':'block'});

	return false;
}

function formataFinalidade() {

	var divRegistro = $('div.divRegistros', divTabela );	
	
	var tabela      = $('#finalidade' );
	
	divRegistro.css({'height':'207px','border-bottom':'1px dotted #777','padding-bottom':'2px'});	
			
	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '45px';
	arrayLargura[1] = '50px';
		
			
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'left';
		
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );
				
	divTabela.css({'display':'block'});
	
	return false;
}

function geraSelecao(){

	var auxSelecao = "";

	$('input:checkbox:checked', divTabela ).each(function () {
		auxSelecao +=  $(this).val() + ',';
	});	
	
	return auxSelecao;
}

function formataConsulta(){

	var cTodosConsulta = $('input[type="text"],select','#divConsulta');
	
	var rTpdopcao = $('label[for="tpdopcao"]','#divConsulta');
	var rDtinicio = $('label[for="dtinicio"]','#divConsulta');
	var rDdtfinal = $('label[for="ddtfinal"]','#divConsulta');
	var rDsadmcrd = $('label[for="dsadmcrd"]','#divConsulta');
	var rTpdomvto = $('label[for="tpdomvto"]','#divConsulta');  
	var rDtprdini = $('label[for="dtprdini"]','#divConsulta');
	var rDtprdfin = $('label[for="dtprdfin"]','#divConsulta');
	var rSituacao = $('label[id="situacaoCartao"]','#divConsulta');
	var rLgvisual = $('label[for="lgvisual"]','#divConsulta');
				
	var cTpdopcao = $('#tpdopcao','#divConsulta');	
	var cDtinicio = $('#dtinicio','#divConsulta');	
	var cDdtfinal = $('#ddtfinal','#divConsulta');	
	var cDsadmcrd = $('#dsadmcrd','#divConsulta');
	var cTpdomvto = $('#tpdomvto','#divConsulta');
	var cDtprdini = $('#dtprdini','#divConsulta');
	var cDtprdfin = $('#dtprdfin','#divConsulta');
	var cSituacao = $('input[type="checkbox"]','#divConsulta');
	var cLgvisual = $('#lgvisual','#divConsulta');
		
	rTpdopcao.css({'width':'125px'});
	rDtinicio.css({'width':'65px'});
	rDdtfinal.css({'width':'65px'});
	rDsadmcrd.css({'width':'125px'});
	rTpdomvto.css({'width':'115px'});
	rDtprdini.css({'width':'125px'});
	rDtprdfin.css({'width':'106px'});
	rSituacao.css({'width':'125px'});
	
	
	$('label[name="situacao"]','#divConsulta').each( function (){
		
		if($(this).attr('id') != 'situacaoCartao'){ 
		
			$(this).css('padding-left','20px');
			
		}
		
	});
	
	rLgvisual.css({'width':'65px'});
		
	cTpdopcao.css({'width':'130px'});
	cDtinicio.css({'width':'90px'}).addClass('data');
	cDdtfinal.css({'width':'90px'}).addClass('data');
	cDsadmcrd.css({'width':'130px'});
	cTpdomvto.css({'width':'40px'});
	cDtprdini.css({'width':'90px'}).addClass('data');
	cDtprdfin.css({'width':'90px'}).addClass('data');
	cSituacao.css({'width':'15px','height':'15px','padding':'0px'});		
	cLgvisual.css({'width':'90px'});
					
	cTodosConsulta.habilitaCampo();
			
	layoutPadrao();
	
	cLgvisual.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }

		// Se é a tecla ENTER
		if ( e.keyCode == 13) {

			btnContinuar();
			return false;
		}

	});

	return false;
	
}

function formataSitBradesco(){

	var cTodosConsulta = $('input[type="text"],select','#divSituacao');
	
	var rSituacao = $('label[id="situacaoCartao"]','#divSituacao');
				
	var cSituacao = $('input[type="checkbox"]','#divSituacao');
			
	rSituacao.css({'width':'125px'});
	
	cSituacao.css({'width':'15px','height':'15px','padding':'0px'});
		
	$('label','#divSituacao').each( function (){
		
		if($(this).attr('id') != 'situacaoCartao'){ 
		
			if($(this).attr('id') == 'labelSituacao6'){
				$(this).css('padding-left','145px');
			}else{
			
				$(this).css('padding-left','20px');
				
			}		
		}
		
	});
						
	cTodosConsulta.habilitaCampo();
		
	layoutPadrao();
	
	return false;
	
}

function formataSaidaGB(){

	var cTodosConsulta = $('input[type="text"],select','#divSaida');
	
	var rLgvisual = $('label[for="lgvisual"]','#divSaida');
	var cLgvisual = $('#lgvisual','#divSaida');
			
	rLgvisual.css({'width':'85px'});
	cLgvisual.css({'width':'90px'});
							
	cTodosConsulta.habilitaCampo();
		
	layoutPadrao();
	
	return false;
}

function formataOpcaoF(){

	var cTodosOpcaoF = $('input[type="text"],select','#divOpcaoF');
		
	var rCdempres = $('label[for="cdempres"]','#divOpcaoF');
	var rLgvisual = $('label[for="lgvisual"]','#divOpcaoF');
	
	var cCdempres = $('#cdempres','#divOpcaoF');
	var cLgvisual = $('#lgvisual','#divOpcaoF');	
	
	rCdempres.css({'width':'200px'});
	rLgvisual.css({'width':'90px'});
		
	cCdempres.css({'width':'55px'}).addClass('inteiro').attr('maxlength','5').val('');
	cLgvisual.css({'width':'90px'});
						
	cTodosOpcaoF.habilitaCampo();
		
	layoutPadrao();
	
	cCdempres.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }

		// Se é a tecla ENTER ou TAB
		if ( e.keyCode == 13 || e.keyCode == 9) {
			
			$('#lgvisual','#divOpcaoF').focus();
			return false;
		}

	});	
	
	cLgvisual.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }

		// Se é a tecla ENTER ou TAB
		if ( e.keyCode == 13 || e.keyCode == 9) {

			$('#btSalvar','#divBotoes').click();
			return false;
		}

	});

	return false;
}

function formataOpcaoL(){

	var cTodosOpcaoL = $('input[type="text"],select','#divOpcaoL');	
	
	var rDtinicio = $('label[for="dtinicio"]','#divOpcaoL');
	var rDdtfinal = $('label[for="ddtfinal"]','#divOpcaoL');
	var rLgvisual = $('label[for="lgvisual"]','#divOpcaoL');
	
	var cDtinicio = $('#dtinicio','#divOpcaoL');	
	var cDdtfinal = $('#ddtfinal','#divOpcaoL');	
	var cLgvisual = $('#lgvisual','#divOpcaoL');	
				
	rDtinicio.css({'width':'90px'});
	rDdtfinal.css({'width':'85px'});
	rLgvisual.css({'width':'85px'});
	
	cDtinicio.css({'width':'90px'}).addClass('data').val('');
	cDdtfinal.css({'width':'90px'}).addClass('data').val('');
	cLgvisual.css({'width':'90px'});
						
	cTodosOpcaoL.habilitaCampo();
		
	layoutPadrao();
	
	cDtinicio.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }

		// Se é a tecla ENTER ou TAB
		if ( e.keyCode == 13 || e.keyCode == 9) {

			$(this).removeClass('campoErro');
			cDdtfinal.focus();
			return false;
		}

	});
	
	cDdtfinal.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }

		// Se é a tecla ENTER ou TAB
		if ( e.keyCode == 13 || e.keyCode == 9) {

			$(this).removeClass('campoErro');
			$('#lgvisual','#divOpcaoL').focus();
			return false;
		}

	});
	
	cLgvisual.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }

		// Se é a tecla ENTER ou TAB
		if ( e.keyCode == 13 || e.keyCode == 9) {
			$(this).removeClass('campoErro');
			$('#btSalvar','#divBotoes').click();
			return false;
		}

	});

	return false;
}

function formataOpcaoR(){

	var cTodosOpcaoR = $('input[type="text"],select','#divOpcaoR');
	
	var rCdagenci = $('label[for="cdagenci"]','#divOpcaoR');
	var rTppessoa = $('label[for="tppessoa"]','#divOpcaoR');
	var rCdultrev = $('label[for="cdultrev"]','#divOpcaoR');
	var rLgvisual = $('label[for="lgvisual"]','#divOpcaoR');
					
	var cCdagenci = $('#cdagenci','#divOpcaoR');	
	var cTppessoa = $('#tppessoa','#divOpcaoR');	
	var cCdultrev = $('#cdultrev','#divOpcaoR');	
	var cLgvisual = $('#lgvisual','#divOpcaoR');	
			
	rCdagenci.css({'width':'75px'});
	rTppessoa.css({'width':'95px'});
	rCdultrev.css({'width':'130px'});
	rLgvisual.css({'width':'65px'});
			
	cCdagenci.css({'width':'40px'}).addClass('inteiro').attr('maxlength','4').val('');
	cTppessoa.css({'width':'40px'}).addClass('inteiro').attr('maxlength','3').val('');
	cCdultrev.css({'width':'40px'}).addClass('inteiro').attr('maxlength','3').val('');
	cLgvisual.css({'width':'90px'});
						
	cTodosOpcaoR.habilitaCampo();
		
	layoutPadrao();
	
	cCdagenci.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }

		// Se é a tecla ENTER ou TAB
		if ( e.keyCode == 13 || e.keyCode == 9) {

			$(this).removeClass('campoErro');
			cTppessoa.focus();
			return false;
		}

	});
	
	cTppessoa.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }

		// Se é a tecla ENTER ou TAB
		if ( e.keyCode == 13 || e.keyCode == 9) {

			$(this).removeClass('campoErro');
			cCdultrev.focus();
			return false;
		}

	});
	
	cCdultrev.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }

		// Se é a tecla ENTER ou TAB
		if ( e.keyCode == 13 || e.keyCode == 9) {

			$(this).removeClass('campoErro');
			$('#lgvisual','#frmOpcaoR').focus();						
			return false;
			
		}

	});
	
	cLgvisual.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }

		// Se é a tecla ENTER ou TAB
		if ( e.keyCode == 13 || e.keyCode == 9) {

			$(this).removeClass('campoErro');
			$('#btSalvar','#divBotoes').click();
			return false;
		}

	});

	return false;
}

function formataOpcaoS(){

	var cTodosOpcaoS = $('input[type="text"],select','#divOpcaoS');
	
	var rCdagenci = $('label[for="cdagenci"]','#divOpcaoS');
	var rTpcontas = $('label[for="tpcontas"]','#divOpcaoS');
	var rLgvisual = $('label[for="lgvisual"]','#divOpcaoS');
					
	var cCdagenci = $('#cdagenci','#divOpcaoS');	
	var cTpcontas = $('#tpcontas','#divOpcaoS');	
	var cLgvisual = $('#lgvisual','#divOpcaoS');	
			
	rCdagenci.css({'width':'90px'});
	rTpcontas.css({'width':'85px'});
	rLgvisual.css({'width':'85px'});
			
	cCdagenci.css({'width':'40px'}).addClass('inteiro').attr('maxlength','4').val('');
	cTpcontas.css({'width':'90px'});
	cLgvisual.css({'width':'90px'});
						
	cTodosOpcaoS.habilitaCampo();
		
	layoutPadrao();
	
	cCdagenci.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }

		// Se é a tecla ENTER ou TAB
		if ( e.keyCode == 13 || e.keyCode == 9) {

			$(this).removeClass('campoErro');
			cTpcontas.focus();
			return false;
		}

	});
	
	cTpcontas.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }

		// Se é a tecla ENTER ou TAB
		if ( e.keyCode == 13 || e.keyCode == 9) {
	
			$(this).removeClass('campoErro');
			$('#lgvisual','#divOpcaoS').focus();	
			return false;
		}

	});
	
	cLgvisual.unbind('keypress').bind('keypress', function(e) {
	
		if ( divError.css('display') == 'block' ) { return false; }

		// Se é a tecla ENTER ou TAB
		if ( e.keyCode == 13 || e.keyCode == 9) {
			
			$(this).removeClass('campoErro');
			$('#btSalvar','#divBotoes').click();
			return false;
		}

	});

	return false;
}

function formataOpcaoE(){

	var cTodosOpcaoE = $('input[type="text"],select','#divOpcaoE');
	var rLgvisual = $('label[for="lgvisual"]','#divOpcaoE');					
	var cLgvisual = $('#lgvisual','#divOpcaoE');	
			
	rLgvisual.css({'width':'85px'});
	cLgvisual.css({'width':'90px'});
						
	cTodosOpcaoE.habilitaCampo();
		
	layoutPadrao();
	
	cLgvisual.unbind('keypress').bind('keypress', function(e) {

		if ( divError.css('display') == 'block' ) { return false; }

		// Se é a tecla ENTER ou TAB
		if ( e.keyCode == 13 || e.keyCode == 9) {

			$(this).removeClass('campoErro');
			$('#btSalvar','#divBotoes').click();			
			return false;
		}

	});

	return false;
}

function controlaPesquisa(nmdoform){

	// Se esta desabilitado o campo 
	if ($("#cdagenci","#" + nmdoform ).prop("disabled") == true)  {
		return;
	}
	
	/* Remove foco de erro */
	$('input','#' + nmdoform).removeClass('campoErro'); 
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdhistor, titulo_coluna, cdgrupos, dshistor;	
	
	//Remove a classe de Erro do form
	$('input','#' + nmdoform).removeClass('campoErro');
			
	bo			= 'b1wgen0059.p';
	procedure	= 'busca_pac';
	titulo      = 'Agência PA';
	qtReg		= '20';					
	filtrosPesq	= 'Cód. PA;cdagenci;30px;S;0;;codigo;|Agência PA;nmresage;200px;S;;;descricao;';
	colunas 	= 'Código;cdagepac;20%;right|Descrição;dsagepac;80%;left';
	mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas);
		
	return false;	

}
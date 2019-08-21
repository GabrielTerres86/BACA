/**************************************************************************************
	ATENÇÃO: SE ESTA TELA ALGUM DIA FOR LIBERADA PARA A PRODUÇÃO TEM QUE SER ALTERADA
			 PARA O NOVO LAYOUT DO AYLLOS WEB.
			 FALAR COM O GABRIEL OU DANIEL. 19/02/2013.
****************************************************************************************/

//*********************************************************************************************//
//*** Fonte: tab094.js                                                 						***//
//*** Autor: Tiago                                                   						***//
//*** Data : Julho/2012                  Última Alteração: 04/07/2013  						***//
//***                                                                  						***//
//*** Objetivo  : Biblioteca de funções da tela TAB094                 						***//
//***                                                                  						***//	 
//*** Alterações: 02/10/2012 - Ajustes referente ao projeto Fluxo Financeiro (Adriano).		***//
//***			  27/06/2013 - Adicionados dois novos campos: mrgitgcr e mrgitgdb (Reinert).***//
//***			  04/07/2013 - Alterado para receber o novo layout padrão do Ayllos Web		***//
//***						  (Reinert).													***//
//*********************************************************************************************//

var cCddopcao;
var cCdcooper;
var frmCabTab094;
var frmTab094;


$(document).ready(function() {
	
	frmCabTab094 =  $('#frmCabTab094');
	frmTab094    =  $('#frmTab094');
	
	controlaLayout();	
			
});

function controlaLayout(){
	
	formataCabecalho();
	estadoInicial();
		
}

function formataCabecalho(){

	$('#divTela').fadeTo(0,0.1);
		
	removeOpacidade('divTela');		

	$('#frmCabTab094').css('display','block');
	
	var cddopcao = $("#cddopcao","#frmCabTab094").val();
	
	var rCddopcao = $('label[for="cddopcao"]','#frmCabTab094');
	var rCdcooper = $('label[for="cdcooper"]','#frmCabTab094');
		
	rCddopcao.css('width','50px').addClass('rotulo');
	rCdcooper.css('width','80px').addClass('rotulo-linha');
	
	frmCabTab094.css({'width':'620px'});
		
	highlightObjFocus($('#frmCabTab094')); 
	
	cCddopcao = $('#cddopcao','#frmCabTab094');
	cCddopcao.css('width','320px');
	cCddopcao.habilitaCampo().focus();
	
	cCdcooper = $('#cdcooper','#frmCabTab094');
	cCdcooper.html( slcooper );
	cCdcooper.habilitaCampo();
	cCdcooper.css('width','125px').attr('maxlength','2');
	
	cCddopcao.unbind('keypress').bind('keypress',function(e){
		
		if(e.keyCode == 13 || e.keyCode == 9 || e.KeyCode == 18){
			
			cCdcooper.focus();
			
			return false;
		}
		
	});
	
	cCddopcao.unbind('changed').bind('changed',function(e){
		
		cCdcooper.focus();
		
		return false;
	});
	
	cCdcooper.unbind('keypress').bind('keypress',function(e){
		
		if(e.keyCode == 13){
			
			acesso_opcao();
		
			return false;
		}
		
	});
	
	cCdcooper.unbind('changed').bind('changed',function(e){
		
		acesso_opcao();
		
		return false;
	});
	
	
}

function formataFormulario() {
	
	$('#divFormulario').css('display','block');
	$('#frmTab094').css('display','block');
	highlightObjFocus($('#frmTab094'));

	var rDstextab	= $('label[for="dstextab"]','#frmTab094');
	var rMrgsrdoc	= $('label[for="mrgsrdoc"]','#frmTab094');
	var rMrgsrchq	= $('label[for="mrgsrchq"]','#frmTab094');
	var rMrgnrtit	= $('label[for="mrgnrtit"]','#frmTab094');
	var rMrgsrtit	= $('label[for="mrgsrtit"]','#frmTab094');
	var rCaldevch	= $('label[for="caldevch"]','#frmTab094');
	var rMrgitgcr	= $('label[for="mrgitgcr"]','#frmTab094');
	var rMrgitgdb	= $('label[for="mrgitgdb"]','#frmTab094');
	var rHorabloq	= $('label[for="horabloq"]','#frmTab094');
	
	var cMrgsrdoc = $('#mrgsrdoc','#frmTab094');
	var cMrgsrchq = $('#mrgsrchq','#frmTab094');
	var cMrgnrtit = $('#mrgnrtit','#frmTab094');
	var cMrgsrtit = $('#mrgsrtit','#frmTab094');
	var cCaldevch = $('#caldevch','#frmTab094');	
	var cMrgitgcr = $('#mrgitgcr','#frmTab094');
	var cMrgitgdb = $('#mrgitgdb','#frmTab094');
	var cHorabloq = $('#horabloq','#frmTab094');
	var cHorabloq2 = $('#horabloq2','#frmTab094');
	
	cMrgsrdoc.css('width','50px').addClass('porcento_n');
	cMrgsrchq.css('width','50px').addClass('porcento_n');
	cMrgnrtit.css('width','50px').addClass('porcento_n');
	cMrgsrtit.css('width','50px').addClass('porcento_n');
	cCaldevch.css('width','50px').addClass('porcento');  
	cMrgitgcr.css('width','50px').addClass('porcento_n');
	cMrgitgdb.css('width','50px').addClass('porcento_n');
	cHorabloq.css('width','25px');
	cHorabloq2.css('width','25px');
	
	cHorabloq.setMask("INTEGER","99","");
	cHorabloq2.setMask("INTEGER","99","");
	
	
	cMrgsrdoc.keypress(function(e){
	
		if(e.keyCode == 13 || e.keyCode == 09 || e.keyCode == 18){
			
			cMrgsrchq.focus();
		
			return false;
		}
	
	});
	
	cMrgsrchq.keypress(function(e){
	
		if(e.keyCode == 13 || e.keyCode == 09 || e.keyCode == 18){
			
			cMrgnrtit.focus();
			
			return false;
		}
	
	});
	
	cMrgnrtit.keypress(function(e){
	
		if(e.keyCode == 13 || e.keyCode == 09 || e.keyCode == 18){
			
			cMrgsrtit.focus();
			
			return false;
		}
	
	});
	
	cMrgsrtit.keypress(function(e){
	
		if(e.keyCode == 13 || e.keyCode == 09 || e.keyCode == 18){
			
			cCaldevch.focus();
			
			return false;
		}
	
	});
	
	cCaldevch.keypress(function(e){
	
		if(e.keyCode == 13 || e.keyCode == 09 || e.keyCode == 18){
			
			cMrgitgcr.focus();
			
			return false;
		}
	
	});
	
	cMrgitgcr.keypress(function(e){
	
		if(e.keyCode == 13 || e.keyCode == 09 || e.keyCode == 18){
			
			cMrgitgdb.focus();
			
			return false;
		}
	
	});

	cMrgitgdb.keypress(function(e){
	
		if(e.keyCode == 13 || e.keyCode == 09 || e.keyCode == 18){
			
			cHorabloq.focus();
			
			return false;
		}
	
	});
	
	cHorabloq.keypress(function(e){
	
		if(e.keyCode == 13 || e.keyCode == 09 || e.keyCode == 18){
			
			cHorabloq2.focus();
		
			return false;
		}
	
	});
	
	cHorabloq2.keypress(function(e){
	
		if(e.keyCode == 13 || e.keyCode == 18){
			
			altera_dados();
			
			return false;
		}
	
	});

}

function voltaDiv(){
	
	$('#divFormulario').css('display','none');
	cCddopcao.focus();
	
	return false;
}

function obtemConsulta(){	

	var cddopcao = $("#cddopcao","#frmCabTab094").val();	
	var cdcooper = $('#cdcooper','#frmCabTab094').val();
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type	: "POST", 
		dataType: 'html',
		url		: UrlSite + "telas/tab094/obtem_consulta.php",
		data	: {
					cdcooper: cdcooper,				
					cddopcao: cddopcao,				
					redirect: "script_ajax" // Tipo de retorno do ajax
				},		
		error	: function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#cddopcao','#frmCabTab094').focus()");							
				},
		success : function(response) {										
					hideMsgAguardo();
					$('#divFormulario').html(response);
				}			
		});
		
	return false;

}

function altera_dados() {
	
	var cddopcao = $("#cddopcao","#frmCabTab094").val();	
	
	if (cddopcao == "A") {
		showConfirmacao('Confirma a atualiza&ccedil;&atilde;o dos parametros?','Tab094','grava_dados();','voltaDiv();estadoInicial();','sim.gif','nao.gif');
	}
}

function grava_dados(){
	
	var mrgsrdoc = $('#mrgsrdoc','#frmTab094').val();
	var mrgsrchq = $('#mrgsrchq','#frmTab094').val();
	var mrgnrtit = $('#mrgnrtit','#frmTab094').val();
	var mrgsrtit = $('#mrgsrtit','#frmTab094').val();
	var caldevch = $('#caldevch','#frmTab094').val();	
	var mrgitgcr = $('#mrgitgcr','#frmTab094').val();
	var mrgitgdb = $('#mrgitgdb','#frmTab094').val();
	var horabloq = $('#horabloq','#frmTab094').val();
	var horabloq2 = $('#horabloq2','#frmTab094').val();
	var cdcooper = $("#cdcooper","#frmCabTab094").val();
	

	horabloq = retiraCaracteres(horabloq,'0123456789',true);
	
	// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, enviando informa&ccedil;&otilde;es ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type	: "POST", 
		url		: UrlSite + "telas/tab094/grava_dados.php",
		data	: {
					mrgsrdoc  : mrgsrdoc,
					mrgsrchq  : mrgsrchq,
					mrgnrtit  : mrgnrtit,
					mrgsrtit  : mrgsrtit,
					caldevch  : caldevch,
					mrgitgcr  : mrgitgcr,
					mrgitgdb  : mrgitgdb,
					horabloq  : horabloq,
					horabloq2 : horabloq2,
					cdcoopex  : cdcooper,
					redirect  : "script_ajax" // Tipo de retorno do ajax
				},		
		error	: function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#cddopcao','#frmCabTab094').focus()");							
				},
		success	: function(response) {				
					try {
						eval(response);
						} catch(error) {
						hideMsgAguardo();					
						showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#cddopcao','#frmCabTab094').focus()");							
					}				
				}		
				
	});
	
}

function estadoInicial() {

	
	$('#cddopcao','#frmCabTab094').habilitaCampo().focus();
	$('#cdcooper','#frmCabTab094').html(slcooper).habilitaCampo();
	
	$('#mrgsrdoc','#frmTab094').val('0');
	$('#mrgsrchq','#frmTab094').val('0');
	$('#mrgnrtit','#frmTab094').val('0');
	$('#mrgsrtit','#frmTab094').val('0');
	$('#caldevch','#frmTab094').val('0');
	$('#mrgitgcr','#frmTab094').val('0');
	$('#mrgitgdb','#frmTab094').val('0');
	$('#horabloq','#frmTab094').val('00');
	$('#horabloq2','#frmTab094').val('00');

	$('#mrgsrdoc','#frmTab094').desabilitaCampo();
	$('#mrgsrchq','#frmTab094').desabilitaCampo();
	$('#mrgnrtit','#frmTab094').desabilitaCampo();
	$('#mrgsrtit','#frmTab094').desabilitaCampo();
	$('#caldevch','#frmTab094').desabilitaCampo();
	$('#mrgitgcr','#frmTab094').desabilitaCampo();
	$('#mrgitgdb','#frmTab094').desabilitaCampo();
	$('#horabloq','#frmTab094').desabilitaCampo();
	$('#horabloq2','#frmTab094').desabilitaCampo();
	
	$('#divMsgAjuda').css('display','none');
	
	return false;
}

function formataMsgAjuda() {	

	var divMensagem = $('#divMsgAjuda');
	
	divMensagem.css({'border':'1px solid #ddd','background-color':'#eee','padding':'2px','height':'20px','margin':'7px 0px'});
	
	var spanMensagem = $('span','#divMsgAjuda');
	
	spanMensagem.css({'text-align':'left','font-size':'11px','float':'left','padding':'3px'});

	var botoesMensagem = $('input','#divMsgAjuda');
	
	botoesMensagem.css({'float':'right','padding-left':'2px'});		
	
	$('input,select').focus( function() {
		if ( $(this).attr('type') == 'image' ) {
			spanMensagem.html('');
		}else if($(this).hasClass('porcento_n')) {
			spanMensagem.html('');
		}else if($(this).hasClass('porcento')) {
			spanMensagem.html('');
		}else {
			spanMensagem.html($(this).attr('alt'));
		}
	});	
	
	return false;
	
}

function acesso_opcao(){
	
	var cddopcao = $('#cddopcao','#frmCabTab094').val();	

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, enviando informa&ccedil;&otilde;es ...");

	obtemConsulta();
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type	: "POST", 
		url		: UrlSite + "telas/tab094/acesso_opcao.php",
		data	: {
				cddopcao: cddopcao,
				redirect: "script_ajax" // Tipo de retorno do ajax
			},				
		error	: function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#cddopcao','#frmCabTab094').focus()");							
				},
		success	: function(response) {				
					hideMsgAguardo();
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try { 
							$('#dstextab','#frmTab094').html(response);
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
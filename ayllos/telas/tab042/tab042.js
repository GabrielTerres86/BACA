/***********************************************************************
Fonte: tab042.js                                                 
Autor: Henrique                                                  
Data : Agosto/2010                  Última Alteração: 13/09/2017            
                                                                  
Objetivo  : Biblioteca de funções da tela TAB042                 
                                                                 	 
Alterações: 25/10/2012 - Incluso função voltar, inclusão do efeito
						 fade e highlightObjFocus, tratamento processo
						 de desabilitação de campo opção e regra para
						 execução no botão OK. Retirado processo de
						 geração mensagem ajuda no rodape. (Daniel)    
                         
	         13/09/2017 - Correcao na validacao de permissoes na tela. SD 750528 (Carlos Rafael Tanholi).

************************************************************************/

var nrcartao;

var frmCabTab042, frmTab042;

// Variaveis do cabecalho
var cCddopcao;

// Variaveis do frame TAB042
var cDstextab;

$(document).ready(function() {

	$('#frmCabTab042').fadeTo(0,0.1);
	$('#frmTab042').fadeTo(0,0.1);
	
	removeOpacidade('frmCabTab042');
	removeOpacidade('frmTab042');
	
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});

	$("#btAlterar","#divMsgAjuda").hide();
	
	$("#btVoltar","#divMsgAjuda").hide();
	
	$("#divMsgAjuda").css('display','block');
	
	frmCabTab042 =  $('#frmCabTab042');
	frmTab042    =  $('#frmTab042');
	
	controlaLayout();	
	
	$('#cddopcao','#frmCabTab042').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			$('#btnOK','#frmCabTab042').focus();
			return false;
		}	
	});	
	
	$('#cddopcao','#frmCabTab042').focus();
	
});

function controlaLayout(){
	formataCabecalho();
	formataFormulario();
	formataMsgAjuda();
	estadoInicial();
	layoutPadrao();
	
}

function formataCabecalho(){

	
	var rCddopcao = $('label[for="cddopcao"]','#frmCabTab042');
	
	/*
	rCddopcao.css('padding-left','25px').addClass('rotulo');
	*/
	
	cCddopcao = $('#cddopcao','#frmCabTab042');
	
	/*
	cCddopcao.css('width','477px');
	*/
	
	cCddopcao.habilitaCampo().focus();
	

}

function formataFormulario() {

	var rDstextab	= $('label[for="dstextab"]','#frmTab042');
		
	rDstextab.css('width', '80px').addClass('rotulo');
	cDstextab = $('#dstextab','#frmTab042');
	
	cDstextab.desabilitaCampo();
	
	var nomeForm    = 'frmTab042';
	highlightObjFocus( $('#'+nomeForm) );
	
	var nomeForm    = 'frmCabTab042';
	highlightObjFocus( $('#'+nomeForm) );
	
}

function carrega_dados(){

	// Verifica se campo Opção está desativado.
	if( $('#cddopcao','#frmCabTab042').hasClass('campoTelaSemBorda') ){ return false; }
	
	// Desabilita campo opção
	cTodosCabecalho		= $('input[type="text"],select','#frmCabTab042'); 
	cTodosCabecalho.desabilitaCampo();
	

	var cddopcao = $("#cddopcao","#frmCabTab042").val();

	// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");
	
	if (cddopcao != "") {
		
		if (cddopcao == "C") {
			cDstextab.desabilitaCampo();
			$("#btAlterar","#divMsgAjuda").hide();
			$("#btVoltar","#divMsgAjuda").show();
		} else {
			cDstextab.habilitaCampo();
			$("#btAlterar","#divMsgAjuda").show();
			$("#btVoltar","#divMsgAjuda").show();
			$('#dstextab','#frmCabTab042').focus
			
			//Altera os dados de pressionar ENTER 
			cDstextab.keypress( function(e) {
				if ( e.keyCode == 13 ) { 
					altera_dados();
					return false;
				}		
			});
						
		}
		
		// Carrega conteúdo da opção através de ajax
		$.ajax({		
			type: "POST", 
			dataType: 'html',
			url: UrlSite + "telas/tab042/carrega_dados.php",
			data: {
				cddopcao: cddopcao,
				redirect: "html_ajax" // Tipo de retorno do ajax
			},		
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#cddopcao','#frmCabTab042').focus()");							
			},
			success: function(response) {				
				hideMsgAguardo();
				if (response.indexOf('showError') != -1 ) {
					eval(response);
				} else {
				$('#dstextab','#frmTab042').html(response);
				document.getElementById('dstextab').focus();
				}
			}		
			});
						
	} else {
		hideMsgAguardo();
		estadoInicial();
	}
	
}

function altera_dados() {

	var cddopcao = $("#cddopcao","#frmCabTab042").val();
	
	if (cddopcao == "A") {
		showConfirmacao('Confirma a atualiza&ccedil;&atilde;o das contas?','Contas','grava_dados();','estadoInicial();','sim.gif','nao.gif');
	}
}

function grava_dados(){
	var dstextab = $("#dstextab","#frmTab042").val();
						
	// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, enviando informa&ccedil;&otilde;es ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/tab042/grava_dados.php",
		data: {
			dstextab: dstextab,
			redirect: "script_ajax" // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#cddopcao','#frmCabTab042').focus()");							
		},
		success: function(response) {				
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();					
			    showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#cddopcao','#frmCabTab042').focus()");							
			}				
		}		
				
	});
}

function estadoInicial() {
	$('#cddopcao','#frmCabTab042').val('');
	$('#dstextab','#frmTab042').val('');
	cDstextab.desabilitaCampo();
	$('input','#divMsgAjuda').hide();
	
	
	cTodosCabecalho	= $('input[type="text"],select','#frmCabTab042'); 
	cTodosCabecalho.habilitaCampo();
	$("#btAlterar","#divMsgAjuda").hide();
	$('#cddopcao','#frmCabTab042').focus();
}

function estadoConsulta(){
	$('#cddopcao','#frmCabTab042').val('C');
	cDstextab.desabilitaCampo();
	$('input','#divMsgAjuda').hide();
}

function formataMsgAjuda() {	

	var botoesMensagem = $('input','#divMsgAjuda');
	botoesMensagem.css({'display':'none','float':'right','padding-left':'2px','margin-top':'0px'});	
	
}

function voltar() {

		cTodosCabecalho	= $('input[type="text"],select','#frmCabTab042'); 
		cTodosCabecalho.habilitaCampo();
		$("#btAlterar","#divMsgAjuda").hide();
		$("#btVoltar","#divMsgAjuda").hide();
		$('#cddopcao','#frmCabTab042').focus();
		$('#dstextab','#frmTab042').desabilitaCampo();
		estadoInicial();

}


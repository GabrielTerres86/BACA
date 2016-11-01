/************************************************************************
 Fonte: eskeci.js                                                 
 Autor: Henrique                                                  
 Data : Maio/2010                  Última Alteração:              
                                                                  
 Objetivo  : Biblioteca de funções da tela ESKECI                 
                                                                 	 
 Alterações: 19/09/2012 - Alterado tela para novo padrao de layout (Lucas R.)                                                     
 
			 27/07/2015 - Removido o campo vlsaqmax. (James)
************************************************************************/

var nrcartao;

var frmCabecalho, frmEskeci;

// Variaveis do cabecalho
var cNrcartao;

// Variaveis do frame Eskeci
var cNrdconta, cNrdctitg, cNmprimtl, cNmtitcrd, cDtemscar, cDtvalcar,
	cNrsennov, cNrsencon;

$(document).ready(function() {

	nrcartao = 0;
	
	frmCabecalho = $('frmCabecalho');
	frmEskeci    =  $('#frmEskeci');
	
	cNrcartao = $('#nrcartao','#frmCabEskeci');
	
	cNrdconta = $('#nrdconta','#frmEskeci');
	cNrdctitg = $('#nrdctitg','#frmEskeci');
	cNmprimtl = $('#nmprimtl','#frmEskeci');
	cNmtitcrd = $('#nmtitcrd','#frmEskeci');	
	cDtemscar = $('#dtemscar','#frmEskeci');
	cDtvalcar = $('#dtvalcar','#frmEskeci');
	cNrsennov = $('#nrsennov','#frmEskeci');
	cNrsencon = $('#nrsencon','#frmEskeci');
	
	controlaLayout();	
});

function controlaLayout(){
	formataCabecalho();
	formataFormulario();
	layoutPadrao();
	cNrcartao.focus();
	
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
}

function formataCabecalho(){
	
	$('#btAlterar','#divMsgAjuda').css({'margin-left':'446px'});
			
	var nomeForm    = 'frmCabEskeci';
	highlightObjFocus( $('#'+nomeForm) );
		
	var nomeForm    = 'frmEskeci';
	highlightObjFocus( $('#'+nomeForm) );
	
	var rNrcartao = $('label[for="nrcartao"]','#frmCabEskeci');
	
	rNrcartao.css('padding-left','130px').addClass('rotulo-linha');
	
	cNrcartao.setMask('INTEGER','zzzz.zzzz.zzzz.zzzz','.','');
	cNrcartao.css({'width':'145px'}).habilitaCampo();
	
	cNrcartao.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9) {	
			buscaCartao();
			return false;
		}
	});
	
	cNrsennov.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9) {
		    cNrsencon.focus();
			
			return false;
		}
	});

	
	cNrsencon.unbind('keydown').bind('keydown', function(e) {
		if ( e.keyCode == 13 || e.keyCode == 9) {
		    validaSenha();
			
			return false;
		}
	});
}

function formataFormulario() {

	var cTodos = $('input','#frmEskeci');	
	
	var rNrdconta	= $('label[for="nrdconta"]','#frmEskeci');
	var rNrdctitg	= $('label[for="nrdctitg"]','#frmEskeci');
	var rNmprimtl	= $('label[for="nmprimtl"]','#frmEskeci');
	var rNmtitcrd	= $('label[for="nmtitcrd"]','#frmEskeci');	
	var rDtemscar	= $('label[for="dtemscar"]','#frmEskeci');	
	var rDtvalcar	= $('label[for="dtvalcar"]','#frmEskeci');	
	var rNrsennov	= $('label[for="nrsennov"]','#frmEskeci');	
	var rNrsencon	= $('label[for="nrsencon"]','#frmEskeci');

	rNrdconta.css('width', '140px').addClass('rotulo');
	rNrdctitg.css('width', '124px').addClass('rotulo-linha');	
	rNmprimtl.css('width', '140px').addClass('rotulo');
	rNmtitcrd.css('width', '140px').addClass('rotulo');	
	rDtemscar.css('width', '140px').addClass('rotulo');
	rDtvalcar.css('width', '187px').addClass('rotulo-linha');	
	rNrsennov.css('width','140px').addClass('rotulo');
	rNrsencon.css('width','187px').addClass('rotulo-linha');	
		
	cTodos.desabilitaCampo();
	cNrdconta.css({'width': '110px'}).addClass('conta');
	cNrdctitg.css({'width':'113px'}).addClass('contaitg');
	cNmprimtl.css({'width':'353px'});
	cNmtitcrd.css({'width':'353px'});
	cDtemscar.css('width','80px').addClass('data');
	cDtvalcar.css('width','80px').addClass('data');
	cNrsennov.css({'width': '80px'}).addClass('integer').attr('maxlength','6');
	cNrsencon.css({'width': '80px'}).addClass('integer').attr('maxlength','6');
}

function buscaCartao() {

	var nrcartao = retiraCaracteres($("#nrcartao","#frmCabEskeci").val(),"0123456789",true);
						
	// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, validando informa&ccedil;&otilde;es ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/eskeci/carrega_dados.php",
		data: {
		    nrcartao: nrcartao,		
			redirect: "script_ajax" // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrcartao','#frmCabEskeci').focus()");							
		},
		success: function(response) {				
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();					
			    showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrcartao','#frmCabEskeci').focus()");							
			}				
		}		
				
	}); 
	
}

function validaSenha() {
	var nrcartao = retiraCaracteres($("#nrcartao","#frmCabEskeci").val(),"0123456789",true);
	var nrdconta = retiraCaracteres($("#nrdconta","#frmEskeci").val(),"0123456789",true);
	var nrsennov = retiraCaracteres($("#nrsennov","#frmEskeci").val(),"0123456789",true);
    var nrsencon = retiraCaracteres($("#nrsencon","#frmEskeci").val(),"0123456789",true);
						
	// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, validando informa&ccedil;&otilde;es ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/eskeci/valida_senha.php",
		data: {
			nrdconta: nrdconta,
		    nrcartao: nrcartao,		
			nrsennov: nrsennov,
			nrsencon: nrsencon,
			redirect: "script_ajax" // Tipo de retorno do ajax
					
		},	
			error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrsennov','#frmEskeci').focus()");							
		},
		success: function(response) {				
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();					
			    showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrsennov','#frmEskeci').focus()");							
			}				
		}		
				
	}); 
	
}

function gravaSenha(){
	var nrcartao = retiraCaracteres($("#nrcartao","#frmCabEskeci").val(),"0123456789",true);
	var nrdconta = retiraCaracteres($("#nrdconta","#frmEskeci").val(),"0123456789",true);
	var nrsennov = retiraCaracteres($("#nrsennov","#frmEskeci").val(),"0123456789",true);
						
	// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, validando informa&ccedil;&otilde;es ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/eskeci/grava_senha.php",
		data: {
			nrdconta: nrdconta,
		    nrcartao: nrcartao,		
			nrsennov: nrsennov,
			redirect: "script_ajax" // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrsennov','#frmEskeci').focus()");							
		},
		success: function(response) {				
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();					
			    showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrsennov','#frmEskeci').focus()");							
			}				
		}
					
	}); 
		estadoInicial();
}

function estadoInicial() {
	
	var cTodos = $('input','#frmEskeci');
	
	cNrcartao.habilitaCampo();
	cNrsennov.desabilitaCampo();
	cNrsencon.desabilitaCampo();
	
	cTodos.val('');
	cNrcartao.val('').focus();
}

function habilitaAlteracao() {	

	cNrcartao.desabilitaCampo();
	cNrsennov.habilitaCampo();
	cNrsencon.habilitaCampo();
	
	cNrsennov.focus();
	
}
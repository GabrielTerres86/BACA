//************************************************************************//
//*** Fonte: caddne.js                                                 ***//
//*** Autor: Henrique - Jorge                                          ***//
//*** Data : Agosto/2011                  Última Alteração:            ***//
//***                                                                  ***//
//*** Objetivo  : Biblioteca de funções da tela CADDNE                 ***//
//***                                                                  ***//	 
//*** Alterações:                                                      ***//
//************************************************************************//

var frmCabCaddne, frmCaddne;

// Variaveis do cabecalho
var cCddopcao, cNrcepend, linkCep;

// Variaveis do formulario 
var cNmreslog, cNmresbai, cNmrescid, cCduflogr, cDstiplog, cDscmplog, cDsoricad;

// Campos referentes ao formulario da tela CADDNE, alguns nao sao utilizados
var camposOrigem = "nrcepend;endereco;nmreslog;dscmplog;cxpostal;nmresbai;cduflogr;nmrescid;dstiplog;idoricad;dsoricad;nrdrowid;nmreslog";

// Preparar função para executar após a seleção de registro na pesquisa de CEP's
mtSelecaoEndereco = function() { 
	$('#nrcepend','#frmCabCaddne').val($('#nrcepend','#frmCaddne').val());		
	
	$('#btVoltar','#divMsgAjuda').show();
	
	// Se for cadastro dos correios
	if ($('#idoricad','#frmCaddne').val() == "1") {
		$('input','#frmCaddne').desabilitaCampo();
		$('span','#divMsgAjuda').html('Este endere&ccedil;o n&atilde;o pode ser Alterado / Exclu&iacute;do.');
		$('#btAlterar','#divMsgAjuda').hide();
		$('#btExcluir','#divMsgAjuda').hide();
		$('#btImportar','#divMsgAjuda').hide();		
	} else {
		$('span','#divMsgAjuda').html('');		
		if ($('#cddopcao','#frmCabCaddne').val() == "A") {
			$('input','#frmCaddne').habilitaCampo();	
			$('#dsoricad','#frmCaddne').desabilitaCampo();
			$('#btExcluir').hide();
			$('#btAlterar').show();
		} else if ($('#cddopcao','#frmCabCaddne').val() == "E") {			
			$('input','#frmCaddne').desabilitaCampo();			
			$('#btAlterar').hide();
			$('#btExcluir').show();			
		}
	} 		
}

$(document).ready(function() {
	
	frmCabCaddne =  $('#frmCabCaddne');
	frmCaddne    =  $('#frmCaddne');
	
	cCddopcao = $('#cddopcao','#frmCabCaddne');
	cNrcepend = $('#nrcepend','#frmCabCaddne');
	linkCep = $('#btLupa','#frmCabCaddne');
	btRefresh = $('#btRefresh','#frmCabCaddne');
	
	cNmreslog = $('#nmreslog','#frmCaddne');
	cNmresbai = $('#nmresbai','#frmCaddne');
	cNmrescid = $('#nmrescid','#frmCaddne');
	cCduflogr = $('#cduflogr','#frmCaddne');
	cDscmplog = $('#dscmplog','#frmCaddne');
	cDstiplog = $('#dstiplog','#frmCaddne');
	cDsoricad = $('#dsoricad','#frmCaddne');
		
	controlaLayout();	
});

function controlaLayout(){
	formataCabecalho();
	formataFormulario();
	formataMsgAjuda();
	estado_inicial();
	layoutPadrao();
}

function formataCabecalho(){
	
	var rCddopcao = $('label[for="cddopcao"]','#frmCabCaddne');
	var rNrceplog = $('label[for="nrcepend"]','#frmCabCaddne');
	
	rCddopcao.css('padding-left','50px').addClass('rotulo');
	rNrceplog.css('padding-left','25px').addClass('rotulo-linha');
	$('input','#frmCabCaddne').css('margin-left','10px');
	
	cCddopcao.css('width','36px');
	cNrcepend.css('width','64px').attr('maxlength','9');;
	cNrcepend.addClass('cep pesquisa').habilitaCampo();
	cCddopcao.habilitaCampo().focus();	
}

function formataFormulario(){
	var cTodos = $('input','#frmCaddne');

	var rNmreslog = $('label[for="nmreslog"]','#frmCaddne');
	var rNmresbai = $('label[for="nmresbai"]','#frmCaddne');
	var rNmrescid = $('label[for="nmrescid"]','#frmCaddne');
	var rCduflogr = $('label[for="cduflogr"]','#frmCaddne');
	var rDstiplog = $('label[for="dstiplog"]','#frmCaddne');
	var rDscmplog = $('label[for="dscmplog"]','#frmCaddne');
	var rDsoricad = $('label[for="dsoricad"]','#frmCaddne');
	
	rNmreslog.css('padding-left','19px').addClass('rotulo');
	rNmresbai.css('padding-left','51px').addClass('rotulo');
	rNmrescid.css('padding-left','47px').addClass('rotulo');
	rCduflogr.css('padding-left', '9px').addClass('rotulo-linha');
	rDstiplog.css('padding-left', '5px').addClass('rotulo-linha');
	rDscmplog.css('padding-left','6px').addClass('rotulo');
	rDsoricad.css('padding-left','17px').addClass('rotulo');
	
	cTodos.desabilitaCampo();
	cTodos.css({'text-transform':'uppercase'});
	cNmreslog.css('width','440px').attr('maxlength','70');
	cNmresbai.css('width','440px').attr('maxlength','70');
	cNmrescid.css('width','170px').attr('maxlength','40');
	cCduflogr.css('width', '25px').attr('maxlength', '2');
	cDstiplog.css('width','157px').attr('maxlength','25');
	cDscmplog.css('width','440px').attr('maxlength','90');	
	cDsoricad.css('width','440px').attr('maxlength','90');
	
}

function formataImportacao(){

	var cTodos = $('input','#frmImportacao');
		
	cTodos.addClass('rotulo').attr('alt','Selecione para importar');
	cTodos.prop('disabled', true);
	cTodos.prop("checked",false);
	$("#frmImportacao").find("input[type=image]").prop("disabled", false);

}

function formataMsgAjuda(){	
	var divMensagem = $('#divMsgAjuda');
	divMensagem.css({'border':'1px solid #ddd','background-color':'#eee','padding':'2px','height':'20px','margin':'7px 0px'});
	
	var spanMensagem = $('span','#divMsgAjuda');
	spanMensagem.css({'text-align':'left','font-size':'11px','float':'left','padding':'3px'});

	var botoesMensagem = $('input','#divMsgAjuda');
	botoesMensagem.css({'float':'right','padding-left':'2px'}).hide();		
	
	$('input,select').focus( function() {
		if ( $(this).attr('type') == 'image' ) {
			spanMensagem.html('');
		} else {
			spanMensagem.html($(this).attr('alt'));
		}
	});	
}

function altera_opcao(){

	var cddopcao = cCddopcao.val();
	
	if (cddopcao != "T") {
		cNrcepend.habilitaCampo();
		controlaPesquisas();
	} else {
		cNrcepend.val("").desabilitaCampo();
		linkCep.unbind('click').bind('click', function(){});
	}
}

function estado_inicial(){

	var cTodos = $('input','#frmCaddne');
	
	cNrcepend.habilitaCampo();
	cNrcepend.val("");
	cCddopcao.habilitaCampo().val("A").focus();
	cTodos.val("").desabilitaCampo();
	
	$('#frmCabCaddne').show();
	$('#frmCaddne').show();
	$('#frmImportacao').hide();
	$('input','#divMsgAjuda').hide();
	
	controlaPesquisas();
}

function executa_opcao(){

	var cddopcao = cCddopcao.val();
	var nrcepend = retiraCaracteres(cNrcepend.val(),"0123456789",true);
	var cTodos = $('input','#frmCaddne');	
	
	cTodos.desabilitaCampo();
	cCddopcao.desabilitaCampo();
	
	if (cddopcao == "T") {
		$('#frmCaddne').hide();
		$('#frmImportacao').show();
		$('#btVoltar').show();
		$('#btImportar').show();
		formataImportacao();
		verifica_arquivos();				
	} else {	
		if (nrcepend == 0) {
			showError("error","Informe o CEP ou clique na lupa para pesquisar.","Alerta - Ayllos","$('#nrcepend','#frmCabCaddne').val('').focus()");
			return false;
		}
		
		$('#frmImportacao').hide();
		$('#btImportar').hide();		
		$('#btVoltar').show();
		$('#frmCaddne').show();	
		busca_endereco(nrcepend);		
		cNrcepend.desabilitaCampo();			
	}
}

function importa_arquivos() {

	var listauf = new Array();
	$("input:checked","#frmImportacao").each(function() {
		listauf.push($(this).val());
	});
	
	if(listauf.length > 0){
		listauf.sort();
		showMsgAguardo("Aguarde, processando arquivo de " + listauf[0] + " ...");
		setTimeout(function(){ limpa_acentosLista(listauf); listauf=null; },100);
	}
	
}

function grava_importacao(){
	
	var listauf = new Array();
	$("input:checked","#frmImportacao").each(function() {
		listauf.push($(this).val());
	});
	
	if(listauf.length > 0){
		listauf.sort();
		showMsgAguardo("Aguarde, gravando arquivo de " + listauf[0] + " ...");
		setTimeout(function(){ efetua_grava_importacao(listauf); listauf=null; },100);
	}

}

function efetua_grava_importacao(listauf){

	var cduflogr = listauf.shift();
	
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/caddne/monta_importacao.php",
		async: false,
		data: {
			cduflogr: cduflogr,		   
			redirect: "script_ajax" // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrcepend','#frmCabCaddne').focus()");							
		},
		success: function(response) {				
			try {				
				if ($.trim(response) != "") {
					hideMsgAguardo();					
					eval(response);
				} else {			
					if (listauf.length > 0) {
						showMsgAguardo("Aguarde, gravando arquivo de " + listauf[0] + " ...");
						setTimeout(function() { efetua_grava_importacao(listauf); listauf=null; },100);
					} else {
						hideMsgAguardo();
						showError("inform","Endereços importados com sucesso.","Alerta - Ayllos","formataImportacao();copia_arquivos();");
					}
				}
			} catch(error) {
				hideMsgAguardo();					
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrcepend','#frmCabCaddne').focus()");							
			}				
		}							
	});	
	
}

function limpa_acentos(cduflogr,callback){

	var cback = (callback != undefined) ? callback : "";
	
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/caddne/limpa_arquivos.php",
		async: false,
		data: {
			cduflogr: cduflogr,		   
			redirect: "script_ajax" // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrcepend','#frmCabCaddne').focus()");							
		},
		success: function(response) {				
			try {
				eval(response);
				eval(cback);
			} catch(error) {
				hideMsgAguardo();					
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrcepend','#frmCabCaddne').focus()");							
			}				
		}							
	});
}

//funcao para retirar acentos dos arquivos.. passar como parametro um array dos UFs
function limpa_acentosLista(listauf){

	var cduflogr = listauf.shift();
	var msgErro  = 'showError("inform","Importa&ccedil;&atilde;o cancelada!","Alerta - Ayllos","");';
	
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/caddne/limpa_arquivos.php",
		async: false,
		data: {
			cduflogr: cduflogr,		   
			redirect: "script_ajax" // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrcepend','#frmCabCaddne').focus()");							
		},
		success: function(response) {				
			try {
				eval(response);
				if(listauf.length > 0){
					showMsgAguardo("Aguarde, processando arquivo de " + listauf[0] + " ...");
					setTimeout(function(){ limpa_acentosLista(listauf); listauf=null; },100);
				}else{
					hideMsgAguardo();
					showConfirmacao('Os endereços foram carregados, deseja finalizar a importa&ccedil;&atilde;o?','Endere&ccedil;os','grava_importacao();',msgErro,'sim.gif','nao.gif');
				}
			} catch(error) {
				hideMsgAguardo();	
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrcepend','#frmCabCaddne').focus()");							
			}				
		}							
	});	
}

function copia_arquivos(){

	// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, verificando arquivos dos estados ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/caddne/copia_arquivos.php",
		data: {
			redirect: "script_ajax" // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrcepend','#frmCabCaddne').focus()");							
		},
		success: function(response) {				
			try {				
				eval(response);				
			} catch(error) {
				hideMsgAguardo();					
			    showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrcepend','#frmCabCaddne').focus()");							
			}				
		}							
	});
}

function verifica_arquivos(){

	// Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, verificando arquivos de atualiza&ccedil;&atilde;o ...");
	
	// Carrega conteúdo da opção através de ajax
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/caddne/verifica_arquivos.php",
		data: {
			redirect: "script_ajax" // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrcepend','#frmCabCaddne').focus()");							
		},
		success: function(response) {				
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();					
			    showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrcepend','#frmCabCaddne').focus()");							
			}				
		}							
	});

}

function busca_endereco(nrcepend){
	
	hideMsgAguardo();
	
	$('input','#frmCaddne').desabilitaCampo();
	
	mostraPesquisaEndereco('frmCaddne',camposOrigem,$('#divTela'),$('#nrcepend','#frmCabCaddne').val());
	
}

function exclui_endereco(){

	var nrdrowid = $('#nrdrowid','#frmCaddne').val();
	
	showMsgAguardo("Aguarde, exclu&iacute;ndo informa&ccedil;&otilde;es ...");
	
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/caddne/exclui_endereco.php",
		data: {
		    nrdrowid: nrdrowid,		
			redirect: "script_ajax" // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrcepend','#frmCabCaddne').focus()");							
		},
		success: function(response) {				
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();					
			    showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrcepend','#frmCabCaddne').focus()");							
			}				
		}							
	});
}

function valida_endereco() {
	
	var nrcepend = retiraCaracteres(cNrcepend.val(),"0123456789",true);
	var cdufende = cCduflogr.val();
	var dstiplog = cDstiplog.val();
	var nmreslog = cNmreslog.val();
	var nmresbai = cNmresbai.val();
	var nmrescid = cNmrescid.val();
	var dscmplog = cDscmplog.val();
	var nrdrowid = $('#nrdrowid','#frmCaddne').val();

	showMsgAguardo("Aguarde, validando informa&ccedil;&otilde;es ...");
	
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/caddne/valida_endereco.php",
		data: {
		    nrcepend: nrcepend,
			cdufende: cdufende,
			dstiplog: dstiplog,
			nmreslog: nmreslog,
			nmresbai: nmresbai,
			nmrescid: nmrescid,
			dscmplog: dscmplog,
			nrdrowid: nrdrowid,
			redirect: "script_ajax" // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrcepend','#frmCabCaddne').focus()");							
		},
		success: function(response) {				
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();					
			    showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrcepend','#frmCabCaddne').focus()");							
			}				
		}							
	});
}

function grava_endereco() {

	var nrcepend = retiraCaracteres(cNrcepend.val(),"0123456789",true);
	var cdufende = cCduflogr.val();
	var dstiplog = cDstiplog.val();
	var nmreslog = cNmreslog.val();
	var nmresbai = cNmresbai.val();
	var nmrescid = cNmrescid.val();
	var dscmplog = cDscmplog.val();
	var nrdrowid = $('#nrdrowid','#frmCaddne').val();
	
	showMsgAguardo("Aguarde, validando informa&ccedil;&otilde;es ...");
	
	$.ajax({		
		type: "POST", 
		url: UrlSite + "telas/caddne/grava_endereco.php",
		data: {
		    nrcepend: nrcepend,
			cdufende: cdufende,
			dstiplog: dstiplog,
			nmreslog: nmreslog,
			nmresbai: nmresbai,
			nmrescid: nmrescid,
			dscmplog: dscmplog,
			nrdrowid: nrdrowid,
			redirect: "script_ajax" // Tipo de retorno do ajax
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrcepend','#frmCabCaddne').focus()");							
		},
		success: function(response) {				
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();					
			    showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".","Alerta - Ayllos","$('#nrcepend','#frmCabCaddne').focus()");							
			}				
		}							
	});
	
}

function controlaPesquisas(){
	
	$('a').each( function() {
		if ( !$(this).prev().hasClass('campoTelaSemBorda') ) { $(this).css('cursor','pointer'); }
	});	
	
	linkCep.css('cursor','pointer').unbind('click').bind('click', function() {
		$('input,select','#frmCabCaddne').desabilitaCampo();
		mostraPesquisaEndereco('frmCaddne',camposOrigem,$('#divTela'));
	});
}

function marcaTodosUfs(){
	$("#frmImportacao").find("input[type=checkbox]:not(:disabled)").prop("checked",true);
}

function desmarcaTodosUfs(){
	$("#frmImportacao").find("input[type=checkbox]").prop("checked", false); 
}
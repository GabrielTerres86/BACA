/*!
 * FONTE        : cadmsg.js
 * CRIAÇÃO      : Rogerius Militão (DB1) 
 * DATA CRIAÇÃO : 26/12/2011
 * OBJETIVO     : Biblioteca de funções da tela CADMSG
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

var operacao 	= ''; // Armazena a operação corrente da tela CADMSG
 
//Formulários e Tabela
var frmNovaMsg	= 'frmNovaMsg';
var divNovaMsg, divListMsg ,divListErr, divViewMsg;
var cDsdassun, cDsdmensg , cCdidpara, cDsidpara, cUserFile, cNomlink, cUrllink, rSpanInfo;
var textantes  	= "";
var textdepois 	= "";
var lstCooperativas = new Array();
var cdcadmsg, keyvalue;

$(document).ready(function() {
	estadoInicial();
});

// inicio
function estadoInicial() {
	
	divNovaMsg  = $("#divNovaMsg");
    divListMsg  = $("#divListMsg");
	divListErr  = $("#divListErr");
	divViewMsg  = $("#divViewMsg");
	
	divNovaMsg.hide();
	divListMsg.hide();
	divListErr.html('').hide();
	divViewMsg.html('').hide();
	
	operacao = '';
	
	$('#divTela').fadeTo(0,0.1);

	// retira as mensagens	
	hideMsgAguardo();
	
	// formaliza
	formataOpcoes();
	formataFormulario();
	
	// habilita foco no formulário inicial
	highlightObjFocus($('#'+frmNovaMsg));
	
	// Outros	
	cTodos 	  = $('input', '#'+frmNovaMsg); 
	cTodos.habilitaCampo();
	cTodos.limpaFormulario().removeClass('campoErro');
	
	removeOpacidade('divTela');
	
	layoutPadrao();
	
	$("#divTela").focus();
	
}

function formataOpcoes(){
	var divOpcoes = $('#divOpcoes');
	divOpcoes.css({'border':'1px solid #ddd','background-color':'#eee','padding':'2px','height':'40px','margin':'7px 0px'});

	var botoesOpcoes = $('#divBotoes','#divOpcoes');
	botoesOpcoes.css({'float':'center','padding':'0 0 0 2px', 'margin-top':'10px'});		
	
}

// formulario do cadastro de envio de mensagem
function formataFormulario() {
	
	// Label
	rDsdassun = $('label[for="dsdassun"]', '#'+frmNovaMsg);
	rDsdmensg = $('label[for="dsdmensg"]', '#'+frmNovaMsg);
	rCdidpara = $('label[for="cdidpara"]', '#'+frmNovaMsg);
	rSpanInfo = $('#spanInfo', '#'+frmNovaMsg);
	rSpanJTxt = $('#SpanJTxt', '#'+frmNovaMsg);
	
	// Input
	cDsdassun = $('#dsdassun', '#'+frmNovaMsg);
	cDsdmensg = $('#dsdmensg', '#'+frmNovaMsg);
	cCdidpara = $('#cdidpara', '#'+frmNovaMsg);
	cDsidpara = $('#dsidpara', '#'+frmNovaMsg);
	cUserFile = $('#userfile', '#'+frmNovaMsg);
	
	//a ref
	aHref1 = $('#ahref1', '#'+frmNovaMsg);
	aHref2 = $('#ahref2', '#'+frmNovaMsg);
	aHref3 = $('#ahref3', '#'+frmNovaMsg);
	
	//div add link
	divlink1 = $("#divOutAddLink", '#'+frmNovaMsg);
	divlink2 = $("#divAddLink", '#'+frmNovaMsg);
	cNomlink = $("#nomlink", '#'+frmNovaMsg);
	cUrllink = $("#urllink", '#'+frmNovaMsg);
	
	divlink1.css({'position':'relative','left':'350px','top':'16px','width':'0'});
	divlink2.css({'display':'none','border':'1px solid','width':'210px','margin':'5px','background':'lightyellow','position':'absolute'});
	
	cDsdassun.css({'width':'100%'});
	cDsdmensg.css({'width':'100%','border':'1px solid #777777','font-size':'11px','padding':'2px 4px 1px'});
	cCdidpara.css({'width':'300px','border':'1px solid #777777','font-size':'11px','padding':'2px 4px 1px'});
	cCdidpara.val("1");
	cDsidpara.css({'width':'300px','border':'1px solid #777777','font-size':'11px','padding':'2px 4px 1px','display':'block'});
	rSpanInfo.css({'margin-left':'20px','font-style':'italic','font-size':'10px','display':'inline','float':'right','position':'relative','top':'-20px'});
	rSpanJTxt.css({'display':'none'});
	cUserFile.css({'display':'none'});
	
	aHref1.css({'position':'relative','left':'100px','font-weight':'bold','font-size':'10px','text-decoration':'underline'});
	aHref2.css({'position':'relative','left':'130px','font-weight':'bold','font-size':'10px','text-decoration':'underline'});
	aHref3.css({'position':'relative','left':'160px','font-weight':'bold','font-size':'10px','text-decoration':'underline'});
	
	$("#divBotoesEnviar").css({'margin-bottom':'20px'});
	
	cDsdmensg.focusin(function(){
		$("#divAddLink").slideUp("fast");
	});
	
	//passando foco para o proximo campo com ENTER
	cDsdassun.unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) cDsdmensg.focus();	});
	 cNomlink.unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) cUrllink.focus();	});
	 cUrllink.unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) $("#btnAddLinkOk").focus();	});
	cCdidpara.unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) cDsidpara.focus(); 	});
	cDsidpara.unbind('keypress').bind('keypress', function(e) { if ( e.keyCode == 13 ) $("#btnEnviarMsg").focus(); 	});
	
	return false;	
}

//
function manterRotina() {
	
	cTodos.removeClass('campoErro');

	var mensagem = 'Aguarde, carregando dados ...';
	var dsdassun = cDsdassun.val();	
	var dsdmensg = cDsdmensg.val();	
	var cdidpara = cCdidpara.val();	
	var dsidpara = cDsidpara.val();	
	var userfile = cUserFile.val();
	
	if(operacao == "BI"){
		//operacao de botao "Nova Mensagem"
		divNovaMsg.fadeIn("slow");
		cCdidpara.val("1").show();
		rSpanInfo.show();
		cDsidpara.show();
		cUserFile.hide();
		rSpanJTxt.hide();
		cDsdassun.focus();
		return false;
		
	}else if(operacao == "I"){
		//operacao de Incluir mensagens
		
		mensagem = 'Aguarde, validando dados ...';
		showMsgAguardo( mensagem );
		
		// valida se campos forma preenchidos para executar impressão
		if (cDsdassun.val() == '') {
			showError('error','Assunto da mensagem deve ser informado','Alerta - Ayllos','hideMsgAguardo();focaCampoErro(\'dsdassun\',\'frmNovaMsg\');'); 
			return false; 
		} else if (cDsdmensg.val() == '') {
			showError('error','Descrição da mensagem deve ser informado','Alerta - Ayllos','hideMsgAguardo();focaCampoErro(\'dsdmensg\',\'frmNovaMsg\');'); 
			return false; 
		} else if (cCdidpara.val() == '1') {
			if(cDsidpara.val() == null){
				showError('error','Cooperativa de destino deve ser informado','Alerta - Ayllos','hideMsgAguardo();focaCampoErro(\'dsidpara\',\'frmNovaMsg\');'); 
				return false; 
			}
		} else if (cCdidpara.val() == '2') {
			if(cUserFile.val() == ''){
				showError('error','Arquivo a ser carregado deve ser informado','Alerta - Ayllos','hideMsgAguardo();focaCampoErro(\'userfile\',\'frmNovaMsg\');'); 
				return false; 
			}
			//validacao do arquivo
			var frm   	  = document.frmNovaMsg;
			var caminho   = frm.userfile.value;
			var extensoes = ["txt"];
			var achou     = false;
			for(i=0;i<extensoes.length;i++){
				if(caminho.slice(caminho.lastIndexOf('.')+1).toLowerCase() == extensoes[i]){
					achou = true;
					break;
				}
			}
			if(!achou){
				showError('error','Tipo de arquivo não permitido','Alerta - Ayllos','hideMsgAguardo();focaCampoErro(\'userfile\',\'frmNovaMsg\');'); 
				return false;
			}
			//fim validacao arquivo
		}
		
		$('#sidlogin','#frmNovaMsg').remove();
		$('#operacao','#frmNovaMsg').remove();
		
		// Insiro input do tipo hidden do formulário para enviá-los posteriormente
		$('#frmNovaMsg').append('<input type="hidden" id="sidlogin" name="sidlogin" />');
		$('#frmNovaMsg').append('<input type="hidden" id="operacao" name="operacao" />');
		
		// Agora insiro o devido valor no campo (campo necessario para validar sessao)
		$('#sidlogin','#frmNovaMsg').val( $('#sidlogin','#frmMenu').val() );
		$('#operacao','#frmNovaMsg').val( operacao );
		
		var NavVersion = CheckNavigator();
		
		action = UrlSite + 'telas/cadmsg/manter_rotina.php?keylink=' + milisegundos();
		
		// Configuro o formulário para posteriormente submete-lo
		$('#frmNovaMsg').attr('method','post');
		$('#frmNovaMsg').attr('action',action);
		$('#frmNovaMsg').attr("target",'frameBlank');		
		showMsgAguardo( "Aguarde, enviando mensagens ...<br />&nbsp;&nbsp;&nbsp;Esta operação pode levar alguns minutos ..." );
		$('#divListErr').html('');
		$('#frmNovaMsg').submit();
		
		
	}else if(operacao == "C"){
		//operacao de Consultar mensagens 
		
		mensagem = 'Aguarde, carregando cadastros de mensagens ...';
		showMsgAguardo( mensagem );
		
		$.ajax({
			type  : 'POST',
			url   : UrlSite + 'telas/cadmsg/manter_rotina.php', 
			data: {
				operacao    : operacao,
				dsdassun	: dsdassun,
				dsdmensg	: dsdmensg,
				cdidpara	: cdidpara,
				dsidpara	: dsidpara,
				userfile	: userfile,
				redirect	: 'script_ajax'
			}, 
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
			},
			success: function(response) {
				try {
					eval(response);
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				}
			}
		});
	}else if(operacao == "L"){
		//operacao de visualizar mensagem enviada
		
		mensagem = 'Aguarde, carregando dados da mensagem ...';
		
		showMsgAguardo( mensagem );	
		
		$.ajax({
			type  : 'POST',
			url   : UrlSite + 'telas/cadmsg/manter_rotina.php', 
			data: {
				operacao    : operacao,
				cdcadmsg	: cdcadmsg,
				keyvalue	: keyvalue,
				redirect	: 'script_ajax'
			}, 
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
			},
			success: function(response) {
				try {
					eval(response);
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
				}
			}
		});
	}
	else if(operacao == "E"){
		//operacao de exclusao de mensagens via cadmsg
		
		mensagem = 'Aguarde, excluindo mensagens ...<br />&nbsp;&nbsp;&nbsp;Esta operação pode levar alguns minutos ...';
		showMsgAguardo( mensagem );	
		
		// Executa script de exclusao de mensagens através de ajax
		$.ajax({		
			type: "POST",
			dataType: "html",
			url: UrlSite + "telas/cadmsg/manter_rotina.php", 
			data: {
				operacao: operacao,
				cdcadmsg: cdcadmsg,
				keyvalue: keyvalue,
				redirect: "script_ajax"
			}, 
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			},
			success: function(response) {
				try {
					eval(response);
				} catch(error) {
					hideMsgAguardo();
					showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
				}
			}				
		});
	}
	
	return false;
}

function formataTabListMsg() {

	var divRegistro = $('div.divRegistros','#divListMsg');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'150px'});
	
	var ordemInicial = new Array();
	ordemInicial = [[1,1]];
			
	var arrayLargura = new Array();
	arrayLargura[0] = '';
	arrayLargura[1] = '110px';
	arrayLargura[2] = '70px';
	arrayLargura[3] = '70px';
	arrayLargura[4] = '40px';
	
		
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'center';
	arrayAlinha[3] = 'center';
	arrayAlinha[4] = 'center';
	
	var metodoTabela = '';
			
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );
	
	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	
	return false;
}

function clearNovaMsg(){
	var frm = document.frmNovaMsg;
	frm.reset();
}

//botao de nova mensagem
function btnNovaMsg(){
	divListMsg.hide();
	divListErr.html('').hide();
	divViewMsg.html('').hide();
	operacao = "BI";
	clearNovaMsg();
	buscaCooperativas();
	cDsdassun.focus();
	manterRotina();
	return false;
}

//botao de listar mensagens
function btnListMsg(){
	divNovaMsg.hide();
	divListErr.html('').hide();
	divViewMsg.html('').hide();
	fecharViewCadMsg();
	operacao = "C";
	manterRotina();
	return false;
}

//botao de "voltar"
function btnVoltar() {
	estadoInicial();
	return false;
}

//botao de enviar mensagem
function btnEnviarMsg() {
	operacao = "I";
	manterRotina();
	return false;
}

//visualizar a mensagem enviada para os cooperados
function ver_cadmsg(codcadmsg,chavekey){
	operacao = "L";
	cdcadmsg = codcadmsg;
	keyvalue = chavekey;
	manterRotina();
	return false;
}

//fechar visualizacao da mensagem
function fecharViewCadMsg(){
	divViewMsg.fadeOut(500);
}

//confirmar exclusao das mensagens
function confExcMsg(cdcadmsg,qttotlid,keyvalue){
	var msg = "Deseja excluir esta mensagem?" ;
	if(qttotlid > 0){
		msg = "Há cooperados que já leram esta mensagem. Deseja realmente excluí-la?";
	}
	showConfirmacao(msg,'Confirma&ccedil;&atilde;o - Ayllos','excluirCadMsg('+cdcadmsg+',"'+keyvalue+'");','hideMsgAguardo();','sim.gif','nao.gif');
}

function excluirCadMsg(cdcadmsg,keyvalue){
	
	operacao = "E";
	cdcadmsg = cdcadmsg;
	keyvalue = keyvalue;
	manterRotina();
	return false;
}


//funcao ajax para buscar cooperativas
function buscaCooperativas(){
	
	showMsgAguardo( "Aguarde, buscando as cooperativas ..." );
	
	// Executa script de consulta através de ajax
	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/cadmsg/busca_cooperativas.php", 
		data: {
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				eval(response);
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});
}

//funcao para carregar cooperativas em combobox
function carregaCooperativas(qtdCooperativas) {
	for (var i = 0; i < qtdCooperativas; i++) {
		$('option','#dsidpara').remove();
		
	}
	for (var i = 0; i < qtdCooperativas; i++) {
		cDsidpara.append("<option id='"+i+"' value='"+lstCooperativas[i].cdcooper+"'>"+lstCooperativas[i].nmrescop+"</option>");
	}
		
	hideMsgAguardo();
}

//onchange do combobox do campo "Para"
function mostraCamposCoop(){
	cDsidpara.slideToggle("slow");
	rSpanInfo.fadeToggle("slow");
	cUserFile.slideToggle("slow");
	rSpanJTxt.fadeToggle("slow");
}

//link de "adicionar nome cooperado"
function addTagCooperado(){
	var textarea = document.frmNovaMsg.dsdmensg;
	var posicao  = getCaret(textarea);
	textantes  	 = cDsdmensg.val().substring(0,posicao);
	textdepois   = cDsdmensg.val().substring(posicao);
	cDsdmensg.val(textantes+"#cooperado#"+textdepois).focus();
}

//link de "adicionar nome cooperativa"
function addTagCooperativa(){
	var textarea = document.frmNovaMsg.dsdmensg;
	var posicao  = getCaret(textarea);
	textantes  	 = cDsdmensg.val().substring(0,posicao);
	textdepois   = cDsdmensg.val().substring(posicao);
	cDsdmensg.val(textantes+"#cooperativa#"+textdepois).focus();
}

//link de "adicionar link"
function addTagLink(){
	var textarea = document.frmNovaMsg.dsdmensg;
	var posicao  = getCaret(textarea);
	textantes    = cDsdmensg.val().substring(0,posicao);
	textdepois   = cDsdmensg.val().substring(posicao);
	$("#divAddLink").slideToggle("fast");
	cNomlink.val('').focus();
	cUrllink.val("http://");
}

//botao de OK em "adicionar link"
function btnAddLinkOk(){
	if(cNomlink.val().length == 0){
		btnAddLinkCanc();
		return false;
	}
	cDsdmensg.val(textantes+'<a href="'+cUrllink.val()+'" target="_blank" style="color:blue;font-weight:bold;text-decoration:underline;">'+cNomlink.val()+'</a>'+textdepois).focus();
}

//botao de cancelar em "adicionar link"
function btnAddLinkCanc(){
	$("#divAddLink").slideUp("fast");
	cDsdmensg.focus();
}


//funcao para pegar posicao do cursor dentro do textarea
function getCaret(el) { 
	if (el.selectionStart) { 
		return el.selectionStart; 
	} else if (document.selection) {
		el.focus(); 
		var r = document.selection.createRange(); 
		if (r == null) { 
			return 0; 
		} 
		var re = el.createTextRange(), rc = re.duplicate(); 
		re.moveToBookmark(r.getBookmark()); 
		re.moveToBookmark(r.getBookmark()); 
		rc.setEndPoint('EndToStart', re); 
		var add_newlines = 0; 
		for (var i=0; i<rc.text.length; i++) {
			if (rc.text.substr(i, 2) == '\r\n') { 
				add_newlines += 1; 
				i++; 
			}	 
		} 
		//return rc.text.length + add_newlines; 
		//We need to substract the no. of lines 
		return rc.text.length - add_newlines; 
	} 
	return 0; 
}


function msgError(tipo,msg,callback){
	showError(tipo,msg,"Alerta - Ayllos",callback);
}
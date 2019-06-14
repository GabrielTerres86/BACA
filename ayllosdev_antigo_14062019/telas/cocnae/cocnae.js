/*!
 * FONTE        : cocnae.js
 * CRIAÇÃO      : Tiago Machado          
 * DATA CRIAÇÃO : 08/09/2016
 * OBJETIVO     : Biblioteca de funções da tela COCNAE
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */

// Definição de algumas variáveis globais 
var cddopcao		= 'C';
	
//Formulários
var frmCab   		= 'frmCab';
var frmCadastro   	= 'frmCadastro';
var frmArquivo      = 'frmArquivo';
var frmExporta      = 'frmExporta';

//Labels/Campos do cabeçalho
var rCddopcao, cCddopcao, cTodosCabecalho, btnCab;

//Labels/Campos do cadastro
var rCdcnae, cCdcnae, cDscnae, rTpcnae, cTpcnae, rDtmvtolt, cDtmvtolt, rDsmotivo, cDsmotivo, rDslicenca, cDslicenca, cTodosCadastro, cLupacnae;

//Labels/Campos do form de upload
var cUserfile;

//Labels/Campos do form de upload
var cSpMensagem;


$(document).ready(function() {

	estadoInicial();
	
	highlightObjFocus( $('#'+frmCab) );
	
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	
	return false;
	
	
});

// seletores
function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);
	$('#frmCab').css({'display':'block'});
	$('#frmCadastro').css({'display':'none'});
	$('#frmArquivo').css({'display':'none'});
	$('#frmExporta').css({'display':'none'});
	$('#divBotoes').css({'display':'none'});
	
	$('#frmCab').css({'width':'700px'});	
		
	formataCabecalho();
	formataCadastro();
	formataUpload();
	formataExporta();
	
	cTodosCabecalho.limpaFormulario();
	cTodosCadastro.limpaFormulario();
	
	cCddopcao.val( cddopcao );
	
	removeOpacidade('divTela');	
	unblockBackground();
	hideMsgAguardo();
		
	trocaBotao('');
	
	$("#btVoltar","#divBotoes").hide();
	
	$('input,select', '#frmCab').removeClass('campoErro');
	
	//controlaFoco();
		
}

function formataCabecalho() {

	// cabecalho
	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab); 
	
	cCddopcao			= $('#cddopcao','#'+frmCab); 
	
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	btnCab				= $('#btOK','#'+frmCab);
	
	rCddopcao.css('width','44px');
	
	cCddopcao.css({'width':'610px'});
	
	if ( $.browser.msie ) {
		cCddopcao.css({'width':'610px'});		
	}	
	
	cTodosCabecalho.habilitaCampo();
	
	$('#cddopcao','#'+frmCab).focus();
	
	layoutPadrao();
	return false;	
}

function formataCadastro() {
	
	rCdcnae   			= $('label[for="cdcnae"]'  ,'#'+frmCadastro); 
	rTpcnae             = $('label[for="tpcnae"]'  ,'#'+frmCadastro); 
	rDtmvtolt           = $('label[for="dtmvtolt"]','#'+frmCadastro); 
	rDsmotivo           = $('label[for="dsmotivo"]','#'+frmCadastro); 
	rDslicenca           = $('label[for="dslicenca"]','#'+frmCadastro); 
	
	cCdcnae 			= $('#cdcnae'  ,'#'+frmCadastro);
	cDscnae             = $('#dscnae'  ,'#'+frmCadastro);
	cTpcnae             = $('input[name="tpcnae"]' ,'#'+frmCadastro);
	cDtmvtolt           = $('#dtmvtolt','#'+frmCadastro); 
	cDsmotivo           = $('#dsmotivo','#'+frmCadastro); 
	cDslicenca          = $('#dslicenca','#'+frmCadastro); 
	cLupacnae           = $('#lupacnae','#'+frmCadastro); 
	
	cTodosCadastro		= $('input[type="text"],select','#'+frmCadastro);
	
	rCdcnae.css('width','90px');
	rTpcnae.css('width','90px');
	rDtmvtolt.css('width','90px');
	rDsmotivo.css('width','90px');
	rDslicenca.css('width','90px');

	cCdcnae.css('width','100px');
	cDscnae.css('width','443px');
	cTpcnae.css('width','30px');
	cTpcnae.css('margin','5px');
	
	cDtmvtolt.css('width','100px');
	cDsmotivo.css('width','565px');
	cDslicenca.css('width','565px');

	$(".tipocnae").css('width','30px');
	$(".tipocnae").css('margin-right','5px');
	
    $(cCdcnae).mask("0000-0/00");	
	$(cCdcnae).css("text-align","right");

	$(cCdcnae).unbind("blur").bind("blur",function(){     
											$(cCdcnae).mask("0000-0/00");	
											$(cCdcnae).css("text-align","right");
										});

    $(cDtmvtolt).mask("00/00/0000");	
	$(cDtmvtolt).css("text-align","right");

    $('#tpcnae0').attr('checked',true);	
	
	cTodosCadastro.habilitaCampo();

    cDscnae.desabilitaCampo();	
	cDtmvtolt.desabilitaCampo();
	cTpcnae.habilitaCampo();
	
	$('#cdcnae','#'+frmCadastro).focus();
	
	layoutPadrao();
	return false;		
	
}

function formataUpload(){
	
	cUserfile = $('#userfile'  ,'#'+frmArquivo);
	
	layoutPadrao();
	return false;			
}

function formataExporta(){
	cSpMensagem	= $('#spMensagem'  ,'#'+frmExporta);
	
	$('#spMensagem', '#frmExporta').html("<b>Clique em exportar para realizar download do arquivo de CNAEs bloqueados.</b>");
	$('#spMensagem', '#frmExporta').css("width","100%");
	
	
	layoutPadrao();
	return false;				
}

function LiberaCampos() {

	if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda')  ) { return false; }	

	// Desabilita campo opção
	cTodosCabecalho		= $('input[type="text"],select','#frmCab'); 
	cTodosCabecalho.desabilitaCampo();
	
	cTodosCadastro.habilitaCampo();
	
	$('#divBotoes', '#divTela').css({'display':'block'});	
	$("#btSalvar","#divBotoes").show();
	$("#btVoltar","#divBotoes").show();

	//Consulta
	if ( $('#cddopcao','#frmCab').val() == 'C' ){

		//LUPA Pesquisa
		$('#lupacnae','#'+frmCadastro).unbind('click').click(function(){ controlaPesquisa(2) });
	
		// CNAE
		$('#cdcnae','#'+frmCadastro).unbind('keypress').bind('keypress',function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {			
			
			    controlaPesquisa(3);
				return false;
			}		
		});		
	
		$('#frmCadastro').css({'display':'block'});	
		
		$('#cdcnae','#'+frmCadastro).focus();
		
		cTpcnae.desabilitaCampo();
		cDsmotivo.desabilitaCampo();
		cDslicenca.desabilitaCampo();		
		cDtmvtolt.desabilitaCampo();
		cDscnae.desabilitaCampo();
		
		trocaBotao('');
		return false;
	}

	//Inclusao
	if ( $('#cddopcao','#frmCab').val() == 'I' ){
		
		//LUPA Pesquisa
		$('#lupacnae','#'+frmCadastro).unbind('click').click(function(){ controlaPesquisa(1) });
		
		// CNAE
		$('#cdcnae','#'+frmCadastro).unbind('keypress').bind('keypress',function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {			
				procedure	= 'BUSCA_CNAE';
				titulo      = 'CNAE';						
				buscaDescricao('MATRIC',procedure,titulo,'cdcnae','dscnae',$('#cdcnae','#'+frmCadastro).val().replace(/\W/g,''),'dscnae','','frmCadastro');
				return false;
			}		
		});		
	
		$('#frmCadastro').css({'display':'block'});	
		
		$('#cdcnae','#'+frmCadastro).focus();
		
		rDtmvtolt.hide();
		cDtmvtolt.hide();
		cTpcnae.habilitaCampo();
		
		trocaBotao('Incluir');
		return false;
	}

	//Exclusao
	if ( $('#cddopcao','#frmCab').val() == 'E' ){

		//LUPA Pesquisa
		$('#lupacnae','#'+frmCadastro).unbind('click').click(function(){ controlaPesquisa(2) });
	
		// CNAE
		$('#cdcnae','#'+frmCadastro).unbind('keypress').bind('keypress',function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {			
			
			    controlaPesquisa(3);
				return false;
			}		
		});		
	
		$('#frmCadastro').css({'display':'block'});	
		
		$('#cdcnae','#'+frmCadastro).focus();
		
		cTpcnae.desabilitaCampo();
		cDsmotivo.desabilitaCampo();
		cDslicenca.desabilitaCampo();		
		cDtmvtolt.desabilitaCampo();
		cDscnae.desabilitaCampo();
		
		trocaBotao('Excluir');
		return false;
	}
	
	//Importacao de arquivo
	if ( $('#cddopcao','#frmCab').val() == 'M' ){
		$('#frmArquivo').css({'display':'block'});	
		trocaBotao('Importar');
		return false;
	}	
	
	//Exportacao de arquivo
	if ( $('#cddopcao','#frmCab').val() == 'N' ){		
	    $('#frmExporta').css({'display':'block'});	
		trocaBotao('Exportar');
		return false;
	}		
	
	return false;
}

function controlaPesquisa(valor) {

	$("#divCabecalhoPesquisa").css("width","100%");
	$("#divResultadoPesquisa").css("width","100%");

	switch(valor){
		case 1:
			controlaPesquisaCdcnae();
			break;	
		case 2:
			controlaPesquisaCdcnaeBloqueado();
			break;	
		case 3:
			controlaPesquisaDadosCnae();
			break;
	}
	
	return false;
}

function controlaPesquisaCdcnae(){
	
	// Se esta desabilitado o campo contrato
	if ($("#cdcnae","#frmCadastro").prop("disabled") == true)  {
		return false;
	}
	
	
	if ($("#cddopcao","#frmCab").prop("disabled") != true)  {
		return false;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdcnae, titulo_coluna, dscnae;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmCadastro';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdcnae = $('#cdcnae','#'+nomeFormulario).val();	
	dscnae = '';
	
	/**/
	bo			= 'BUSCACNAE'; 
	procedure	= 'BUSCA_CNAE';
	titulo      = 'CNAE';
	qtReg		= '30';
	filtrosPesq = 'Codigo;cdcnae;60px;S;0;;descricao|CNAE;dscnae;200px;S;;;descricao|;flserasa;;N;2;N;;descricao';
	colunas     = 'Codigo;cdcnae;20%;right|CNAE;dscnae;80%;left';			
	mostraPesquisa('MATRIC',procedure,titulo,qtReg,filtrosPesq,colunas,divRotina);
	/**/
/*	
	$("#divPesquisa").css("left","258px");
	$("#divPesquisa").css("top","91px");
	$("#divCabecalhoPesquisa > table").css("width","875px");
	$("#divCabecalhoPesquisa > table").css("float","left");
	$("#divResultadoPesquisa > table").css("width","890px");
	$("#divCabecalhoPesquisa").css("width","890px");
	$("#divResultadoPesquisa").css("width","890px");
*/
	return false;
	
}

function controlaPesquisaCdcnaeBloqueado(){
	
	// Se esta desabilitado o campo contrato
	if ($("#cdcnae","#frmCadastro").prop("disabled") == true)  {
		return false;
	}
	
	
	if ($("#cddopcao","#frmCab").prop("disabled") != true)  {
		return false;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, cdcnae, titulo_coluna, dscnae;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmCadastro';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var cdcnae = $('#cdcnae','#'+nomeFormulario).val();	
	dscnae = '';
	
	/**/
	bo			= 'CADA0004'; 
	procedure	= 'BUSCA_CNAE_BLOQUEADO';
	titulo      = 'CNAE BLOQUEADO';
	qtReg		= '30';
	filtrosPesq = 'Codigo;cdcnae;60px;S;0;;descricao|CNAE;dscnae;200px;S;;;descricao';
	colunas     = 'Codigo;cdcnae;20%;right|CNAE;dscnae;80%;left';			
	mostraPesquisa('COCNAE',procedure,titulo,qtReg,filtrosPesq,colunas,divRotina);
	/**/
/*
	$("#divPesquisa").css("left","258px");
	$("#divPesquisa").css("top","91px");
	$("#divCabecalhoPesquisa > table").css("width","875px");
	$("#divCabecalhoPesquisa > table").css("float","left");
	$("#divResultadoPesquisa > table").css("width","890px");
	$("#divCabecalhoPesquisa").css("width","890px");
	$("#divResultadoPesquisa").css("width","890px");
*/
	return false;
	
}

function controlaPesquisaDadosCnae(){
	
	// Mostra mensagem de aguardo
	cddopcao = cCddopcao.val();
	
	if (cddopcao == "C"){  	   showMsgAguardo("Aguarde, consultando..."); } 
	else if (cddopcao == "I"){ showMsgAguardo("Aguarde, incluindo...");  }	
	else if (cddopcao == "E"){ showMsgAguardo("Aguarde, excluindo...");  }
	else { showMsgAguardo("Aguarde, liberando aplicacao..."); }
	
	var cdcnae = $('#cdcnae','#frmCadastro').val().replace(/\W/g,'');	
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cocnae/busca_dados.php", 
		data: {
			cddopcao: cddopcao,			
			cdcnae: cdcnae,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
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

function preencheDadosTela(cdcnae, dscnae, tpcnae, dsmotivo, dslicenca, dtmvtolt, dtarquivo){
	
	if(cdcnae != ''){
	  cCdcnae.val(cdcnae);
	}
	
	if(dscnae != ''){
	  cDscnae.val(dscnae);
	}
	
    if(tpcnae != ''){		
	  if(tpcnae == '0'){
		  $('#tpcnae0').attr('checked',true);
	  }	else {
		  $('#tpcnae1').attr('checked',true);
	  }
	}

	if(dsmotivo != ''){
	  cDsmotivo.val(dsmotivo);
	}
	
	if(dslicenca != ''){
	  cDslicenca.val(dslicenca);
	}
	
	if(dtmvtolt != ''){
	  cDtmvtolt.val(dtmvtolt);
	}
	/*
	if(dtarquivo != ''){
	  cDtarquivo.val(dtarquivo);
	}*/
	
}

function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>');

	if ( botao != '') {
		$('#divBotoes','#divTela').append('&nbsp;<a href="#" class="botao" id="btContinuar" onClick="btnContinuar(); return false;" >'+botao+'</a>');
	}
	return false;
}

// botoes
function btnVoltar() {	
	estadoInicial();
	return false;
}


function btnContinuar() {

	$('input,select', '#frmCab').removeClass('campoErro');
	
	if( cCddopcao.val() == 'I' || cCddopcao.val() == 'C' || cCddopcao.val() == 'E'){
		if ( cCdcnae.val() == '' ) {
			showError("error","CNAE deve ser informado.","Alerta - Ayllos","focaCampoErro(\'cdcnae\', \'frmCadastro\');",false);
			return false;
		}
	}
	
	// Se chegou até aqui, o cnae é diferente do vazio e é válida, então realizar a operação desejada
	realizaOperacao();
	
	return false;		
}

function importarArquivo(cddopcao, flglimpa){


	// Link para o action do formulario
	var action = UrlSite + 'telas/cocnae/upload_arq_cnae.php';
    var frmEnvia = $('#'+frmArquivo);
   
	// Incluir o campo de login para validação (campo necessario para validar sessao)
	$('#sidlogin', frmEnvia).remove();
	$('#cddopcao', frmEnvia).remove();
	$('#flglimpa', frmEnvia).remove();
	$(frmEnvia).append('<input type="hidden" id="sidlogin" name="sidlogin" />');
	$(frmEnvia).append('<input type="hidden" id="cddopcao" name="cddopcao" value="' + cddopcao + '" />');
	$(frmEnvia).append('<input type="hidden" id="flglimpa" name="flglimpa" value="' + flglimpa + '" />');
	// Seta o valor conforme id do menu
	$('#sidlogin',frmEnvia).val( $('#sidlogin','#frmMenu').val() );
		
	// Configuro o formulário para posteriormente submete-lo
	$(frmEnvia).attr('method','post');
	$(frmEnvia).attr('action',action);		
	$(frmEnvia).attr("target",'frameBlank');			
	
	$(frmEnvia).submit();

}

function downloadArqCnae(){

    $('#btContinuar').hide();
	
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cocnae/exporta_arq_cnae.php", 
		data: {
			cddopcao : cddopcao,			
			redirect : "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
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
	/*
	$('#spMensagem', '#frmExporta').html("<a style='text-decoration:none; color: black; font-weight: bold; width:100%' href='" + UrlSite + "telas/cocnae/download.php' target='blank'> <img src='" + UrlSite + "imagens/geral/ico_download.png' > Arquivo de CNAES Bloqueados Download</img> </a> ");
	$('#spMensagem', '#frmExporta').css("width","100%");
	*/
    return false;
}

function confirmaUploadArquivo(cddopcao){
	showConfirmacao('Deseja limpar a base ao importar o arquivo?'	,'Confirma&ccedil;&atilde;o - COCNAE','importarArquivo("' + cddopcao + '" , "1")','importarArquivo("' + cddopcao + '" , "0")','sim.gif','nao.gif'); return false; 
}

function realizaOperacao() {

	// Mostra mensagem de aguardo
	cddopcao = cCddopcao.val();
	
	if (cddopcao == "C"){  	   showMsgAguardo("Aguarde, consultando..."); } 
	else if (cddopcao == "I"){ showMsgAguardo("Aguarde, incluindo...");  }	
	else if (cddopcao == "E"){ showMsgAguardo("Aguarde, excluindo...");  }
	else if (cddopcao == "M"){ showMsgAguardo("Aguarde, importando...");  confirmaUploadArquivo(cddopcao); return false;} /* interrompe aqui */
	else if (cddopcao == "N"){ showMsgAguardo("Aguarde, exportando..."); downloadArqCnae(); return false; } /* interrompe aqui */
	else { showMsgAguardo("Aguarde, liberando aplicacao..."); }
	
	var cdcnae = $('#cdcnae','#frmCadastro').val().replace(/\W/g,'');	
	var tpcnae = $('input[name="tpcnae"]:checked','#frmCadastro').val();	
	var dsmotivo = removeCaracteresInvalidos( $('#dsmotivo','#frmCadastro').val() );	
	var dslicenca = removeCaracteresInvalidos( $('#dslicenca', '#frmCadastro').val() );
	var dtmvtolt = $('#dtmvtolt','#frmCadastro').val();		
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cocnae/manter_rotina.php", 
		data: {
			cddopcao : cddopcao,			
			cdcnae   : cdcnae,
			tpcnae   : tpcnae,
			dsmotivo : dsmotivo,
			dslicenca: dslicenca,
			dtmvtolt : dtmvtolt,			
			redirect : "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
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

function msgError(tipo,msg,callback){
	showError(tipo,msg,"Alerta - Ayllos",callback);
}
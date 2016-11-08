/*!
 * FONTE        : cocnpj.js
 * CRIAÇÃO      : Tiago Machado          
 * DATA CRIAÇÃO : 08/09/2016
 * OBJETIVO     : Biblioteca de funções da tela COCNPJ
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
var rInpessoa, cInpessoa, rNrcpfcgc, cNrcpfcgc, cDsnome, rDtmvtolt, cDtmvtolt, rDsmotivo, cDsmotivo, cTodosCadastro, cLupacnpj;

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
	
	rInpessoa           = $('label[for="inpessoa"]'  ,'#'+frmCadastro); 
	rNrcpfcgc           = $('label[for="nrcpfcgc"]'  ,'#'+frmCadastro); 
	rDtmvtolt           = $('label[for="dtmvtolt"]','#'+frmCadastro); 
	rDsmotivo           = $('label[for="dsmotivo"]','#'+frmCadastro); 
	
	cInpessoa           = $('input[name="inpessoa"]' ,'#'+frmCadastro);
	cNrcpfcgc 			= $('#nrcpfcgc'  ,'#'+frmCadastro);
	cDsnome             = $('#dsnome'  ,'#'+frmCadastro);
	cDtmvtolt           = $('#dtmvtolt','#'+frmCadastro); 
	cDsmotivo           = $('#dsmotivo','#'+frmCadastro); 
	cLupacnpj           = $('#lupacnpj','#'+frmCadastro); 
	
	cTodosCadastro		= $('input[type="text"],select','#'+frmCadastro);
	
	rInpessoa.css('width','90px');
	rNrcpfcgc.css('width','90px');	
	rDtmvtolt.css('width','90px');
	rDsmotivo.css('width','90px');	

	cInpessoa.css('width','30px');
	cInpessoa.css('margin','5px');
	cNrcpfcgc.css('width','120px');
	cDsnome.css('width','423px');
	cDtmvtolt.css('width','100px');
	cDsmotivo.css('width','565px');

	if( getValueInpessoa() == 1 ){
		$(cNrcpfcgc).mask("000.000.000-00", {reverse:true});	 //CPF
	}	
	else{
		$(cNrcpfcgc).mask("00.000.000/0000-00", {reverse:true});	//CNPJ
	}
	$(cNrcpfcgc).css("text-align","right");
	

	$('input[name=inpessoa]').unbind('change').bind('change', function(){
		if( getValueInpessoa() == 1 ){
			$(cNrcpfcgc).mask("000.000.000-00", {reverse:true});	 //CPF
		}	
		else{
			$(cNrcpfcgc).mask("00.000.000/0000-00", {reverse:true});	//CNPJ
		}
		$(cNrcpfcgc).css("text-align","right"); 
		return false;
	}); 
	
	
	$(cNrcpfcgc).unbind("blur").bind("blur",function(){	
		                                    if( getValueInpessoa() == 1 ){
												$('#nrcpfcgc').mask("000.000.000-00", {reverse:true});	 //CPF
											}	
											else{	
												$('#nrcpfcgc').mask("00.000.000/0000-00", {reverse:true});	//CNPJ
											}
											$('#nrcpfcgc').css("text-align","right"); 
											return false;
										});
										
    $(cDtmvtolt).mask("00/00/0000");	
	$(cDtmvtolt).css("text-align","right");

	$('#inpessoa1').attr('checked',true);	
	
	cTodosCadastro.habilitaCampo();

    cDsnome.desabilitaCampo();	
	cDtmvtolt.desabilitaCampo();
	cInpessoa.habilitaCampo();	
	
	$('#nrcpfcgc','#'+frmCadastro).focus();
	
	layoutPadrao();
	return false;			
}

function getValueInpessoa(){
	return $('input[name=inpessoa]:checked').val();
}

function formataUpload(){
	
	cUserfile = $('#userfile'  ,'#'+frmArquivo);
	
	layoutPadrao();
	return false;			
}

function formataExporta(){
	cSpMensagem	= $('#spMensagem'  ,'#'+frmExporta);
	
	$('#spMensagem', '#frmExporta').html("<b>Clique em exportar para realizar download do arquivo de CNPJs bloqueados.</b>");
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
		$('#lupacnpj','#'+frmCadastro).unbind('click').click(function(){ controlaPesquisa(2) });
	
		// CNPJ
		$('#nrcpfcgc','#'+frmCadastro).unbind('keypress').bind('keypress',function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {			
			
			    controlaPesquisa(3);
				return false;
			}		
		});		
	
		$('#frmCadastro').css({'display':'block'});	
		
		$('#nrcpfcgc','#'+frmCadastro).focus();
		
		cInpessoa.habilitaCampo();
		cDsmotivo.desabilitaCampo();		
		cDtmvtolt.desabilitaCampo();
		cDsnome.desabilitaCampo();
		
		trocaBotao('');
		return false;
	}

	//Inclusao
	if ( $('#cddopcao','#frmCab').val() == 'I' ){
		
		//LUPA Pesquisa
		$('#lupacnpj','#'+frmCadastro).unbind('click').click(function(){ controlaPesquisa(1) });
		
		// CNPJ
		$('#nrcpfcgc','#'+frmCadastro).unbind('keypress').bind('keypress',function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {			
				procedure	= 'BUSCA_CNPJ';
				titulo      = 'CNPJ';						
				buscaDescricao('COCNPJ',procedure,titulo,'nrcpfcgc','dsnome',$('#nrcpfcgc','#'+frmCadastro).val().replace(/\W/g,''),'dsnome','','frmCadastro'); //tiago mudar
				return false;
			}		
		});		
	
		$('#frmCadastro').css({'display':'block'});	
		
		$('#nrcpfcgc','#'+frmCadastro).focus();
		
		rDtmvtolt.hide();
		cDtmvtolt.hide();
        cInpessoa.habilitaCampo();		
		
		trocaBotao('Incluir');
		return false;
	}

	//Exclusao
	if ( $('#cddopcao','#frmCab').val() == 'E' ){

		//LUPA Pesquisa
		$('#lupacnpj','#'+frmCadastro).unbind('click').click(function(){ controlaPesquisa(2) });
	
		// CNPJ
		$('#nrcpfcgc','#'+frmCadastro).unbind('keypress').bind('keypress',function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {			
			
			    controlaPesquisa(3);
				return false;
			}		
		});		
	
		$('#frmCadastro').css({'display':'block'});	
		
		$('#nrcpfcgc','#'+frmCadastro).focus();
		
		cInpessoa.desabilitaCampo();
		cDsmotivo.desabilitaCampo();
		cDtmvtolt.desabilitaCampo();
		cDsnome.desabilitaCampo();
		
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
			controlaPesquisaCdcnpj();
			break;	
		case 2:
			controlaPesquisaCdcnpjBloqueado();
			break;	
		case 3:
			controlaPesquisaDadosCnpj();
			break;
	}
	
	return false;
}

function controlaPesquisaCdcnpj(){
	
	// Se esta desabilitado o campo contrato
	if ($("#nrcpfcgc","#frmCadastro").prop("disabled") == true)  {
		return false;
	}
	
	
	if ($("#cddopcao","#frmCab").prop("disabled") != true)  {
		return false;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, nrcpfcgc, titulo_coluna, dsnome;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmCadastro';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var nrcpfcgc = $('#nrcpfcgc','#'+nomeFormulario).val();	
	dsnome = '';
	
	/**/
	bo			= 'BUSCACNPJ'; 
	procedure	= 'BUSCA_CNPJ';
	titulo      = 'CNPJ';
	qtReg		= '30';
	filtrosPesq = 'CNPJ;nrcpfcgc;60px;S;0;;descricao|Razao Social;dsnome;200px;S;;;descricao|;flserasa;;N;2;N;;descricao';
	colunas     = 'CNPJ;nrcpfcgc;20%;right|Razao Social;dsnome;80%;left';			
	mostraPesquisa('COCNPJ',procedure,titulo,qtReg,filtrosPesq,colunas,divRotina); //tiago era MATRIC
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

function controlaPesquisaCdcnpjBloqueado(){
	
	// Se esta desabilitado o campo contrato
	if ($("#nrcpfcgc","#frmCadastro").prop("disabled") == true)  {
		return false;
	}
	
	
	if ($("#cddopcao","#frmCab").prop("disabled") != true)  {
		return false;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtros, colunas, nrcpfcgc, titulo_coluna, dsnome;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmCadastro';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	var nrcpfcgc = $('#nrcpfcgc','#'+nomeFormulario).val();	
	dsnome = '';
	
	/**/
	bo			= 'CADA0004'; 
	procedure	= 'BUSCA_CNPJ_BLOQUEADO';
	titulo      = 'CNPJ BLOQUEADO';
	qtReg		= '30';
	filtrosPesq = 'CNPJ;nrcpfcgc;60px;S;0;;descricao|Razao Social;dsnome;200px;S;;;descricao';
	colunas     = 'CNPJ;nrcpfcgc;20%;right|Razao Social;dsnome;80%;left';			
	mostraPesquisa('COCNPJ',procedure,titulo,qtReg,filtrosPesq,colunas,divRotina);
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

function controlaPesquisaDadosCnpj(){
	
	// Mostra mensagem de aguardo
	cddopcao = cCddopcao.val();
	
	if (cddopcao == "C"){  	   showMsgAguardo("Aguarde, consultando..."); } 
	else if (cddopcao == "I"){ showMsgAguardo("Aguarde, incluindo...");  }	
	else if (cddopcao == "E"){ showMsgAguardo("Aguarde, excluindo...");  }
	else { showMsgAguardo("Aguarde, liberando aplicacao..."); }
	
	var nrcpfcgc = $('#nrcpfcgc','#frmCadastro').val().replace(/\W/g,'');	
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cocnpj/busca_dados.php", 
		data: {
			cddopcao: cddopcao,			
			nrcpfcgc: nrcpfcgc,
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

function preencheDadosTela(inpessoa, nrcpfcgc, dsnome, dsmotivo, dtmvtolt, dtarquivo){
	
    if(inpessoa != ''){			
	  if(inpessoa == '1'){
		  $('#inpessoa1').attr('checked',true);
	  }	else {
		  $('#inpessoa2').attr('checked',true);
	  }
	}	
	
	if(nrcpfcgc != ''){
	  cNrcpfcgc.val(nrcpfcgc);
	}
	
	if(dsnome != ''){
	  cDsnome.val(dsnome);
	}
	
	if(dsmotivo != ''){
	  cDsmotivo.val(dsmotivo);
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
		if ( cNrcpfcgc.val() == '' ) {
			showError("error","CNPJ deve ser informado.","Alerta - Ayllos","focaCampoErro(\'nrcpfcgc\', \'frmCadastro\');",false);
			return false;
		}
	}
	
	// Se chegou até aqui, o cnpj é diferente do vazio e é válida, então realizar a operação desejada
	realizaOperacao();
	
	return false;		
}

function importarArquivo(cddopcao, flglimpa){

	// Link para o action do formulario
	var action = UrlSite + 'telas/cocnpj/upload_arq_cnpj.php';
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

function downloadArqCnpj(){

    $('#btContinuar').hide();
	
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cocnpj/exporta_arq_cnpj.php", 
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
	$('#spMensagem', '#frmExporta').html("<a style='text-decoration:none; color: black; font-weight: bold; width:100%' href='" + UrlSite + "telas/cocnpj/download.php' target='blank'> <img src='" + UrlSite + "imagens/geral/ico_download.png' > Arquivo de CNPJs Bloqueados Download</img> </a> ");
	$('#spMensagem', '#frmExporta').css("width","100%");
	*/
    return false;
}

function confirmaUploadArquivo(cddopcao){
	showConfirmacao('Deseja limpar a base ao importar o arquivo?'	,'Confirma&ccedil;&atilde;o - COCNPJ','importarArquivo("' + cddopcao + '" , "1")','importarArquivo("' + cddopcao + '" , "0")','sim.gif','nao.gif'); return false; 
}

function realizaOperacao() {

	// Mostra mensagem de aguardo
	cddopcao = cCddopcao.val();
	
	if (cddopcao == "C"){  	   showMsgAguardo("Aguarde, consultando..."); } 
	else if (cddopcao == "I"){ showMsgAguardo("Aguarde, incluindo...");  }	
	else if (cddopcao == "E"){ showMsgAguardo("Aguarde, excluindo...");  }
	else if (cddopcao == "M"){ showMsgAguardo("Aguarde, importando...");  confirmaUploadArquivo(cddopcao); return false;} /* interrompe aqui */
	else if (cddopcao == "N"){ showMsgAguardo("Aguarde, exportando..."); downloadArqCnpj(); return false; } /* interrompe aqui */
	else { showMsgAguardo("Aguarde, liberando aplicacao..."); }
	
	var nrcpfcgc = $('#nrcpfcgc','#frmCadastro').val().replace(/\W/g,'');	
	var inpessoa = getValueInpessoa();
	var dsnome = removeCaracteresInvalidos( $('#dsnome', '#frmCadastro').val() );
	var dsmotivo = removeCaracteresInvalidos( $('#dsmotivo', '#frmCadastro').val() );
	var dtmvtolt = $('#dtmvtolt','#frmCadastro').val();		
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cocnpj/manter_rotina.php", 
		data: {
			cddopcao : cddopcao,	
			inpessoa : inpessoa,
			nrcpfcgc : nrcpfcgc,
			dsnome   : dsnome,
			dsmotivo : dsmotivo,
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
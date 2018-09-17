/*********************************************************************************************
 FONTE        : chqsin.js
 CRIAÇÃO      : Rodrigo Bertelli (RKAM)         
 DATA CRIAÇÃO : Julho/2014
 OBJETIVO     : Biblioteca de funções da tela CHQSIN
 
 Alteração    : 16/10/2015 - (Lucas Ranghetti #326872) - Alteração referente ao projeto melhoria 217, cheques sinistrados fora.
***********************************************************************************************/

// Definição de algumas variáveis globais 
var cddopcao = 'C';

//Formulários
var frmCab   		= 'frmCab';

//Labels/Campos do cabeçalho
var rCddopcao, cCddopcao, cTodosCabecalho, btnCab;

//Labels Formulario
var rCdadmcrd; 
	
var arrayRegLinha = new Array();
var arrayChqFora = new Array();	
	
//Campos Formulario
var cCdadmcrd, strDatExc, strCBancoExc, strCAgenciaExc, strCContaExc,strNrCheque;
strDatExc = '';
strCBanco = '';
strCAgenciaExc = '';
strCContaExc = '';
strNrCheque = '';
	
$(document).ready(function() {
	
	estadoInicial();
	return false;
});

function estadoInicial() {

	arrayRegLinha = new Array();
	arrayChqFora = new Array();

	$('#divTela').fadeTo(0,0.1);

	 $('#frmCab').css({'display':'block'});
	$('#frmChqsin').css({'display':'none'});
	$('#divBotoes').css({'display':'none'});
	$("#divTransacao").css({'display':'none'});
	
	$("#dscmotivo").val('');
	$("#registros").html('');
	
	cddopcao = 'C';

	formataLayout();
	
	cTodosCabecalho.limpaFormulario();
	cTodosCabecalho.habilitaCampo();
	
	cCddopcao.val( cddopcao );
	
	removeOpacidade('divTela');	
	unblockBackground();
	hideMsgAguardo();
	
	$("#btVoltar","#divBotoes").hide();
	
	$('input,select', '#frmCab').removeClass('campoErro');
	$('input,select', '#frmChqsin').removeClass('campoErro');
			
	cCdtipchq.habilitaCampo();
	cCddopcao.show();
	cCdtipchq.focus();
	
	
	highlightObjFocus( $('#frmChqsin') );
	highlightObjFocus( $('#frmInclusao') );
	
	
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
		
	cCddopcao.unbind('change').bind('change', function() {
		cddopcao = $(this).val();
	});	
	
}

function formataLayout() {

	// Cabecalho	
	cTodosCabecalho	 = $('input[type="text"],select','#'+frmCab);
	cTodosFormChqsin = $('input[type="text"],select,textarea','#frmChqsin'); 
	btnCab			 = $('#btOK','#'+frmCab);
	
	cCdtipchq 		 = $('#cdtipchq','#frmCab'); 
	rCdtipchq	     = $('label[for="cdtipchq"]','#frmCab'); 
	
	cCddopcao		 = $('#cddopcao','#'+frmCab); 
	rCddopcao	     = $('label[for="cddopcao"]','#'+frmCab); 
	
	cCdtipchq.css({'width':'460px'});
	rCdtipchq.css('width','44px');
	
	cCddopcao.css({'width':'460px'});
	rCddopcao.css('width','44px');

	// Form Adms
	rCdadmcrd = $('label[for="cdadmcrd"]','#frmChqsin'); 
    rCdadmcrd.css({width:'110px'});
	
	// Campos
    cCdadmcrd = $('#cdadmcrd','#frmChqsin');  
    
	$('#cddopcao','#frmCab').hide();
	
	controlaFoco();	

	layoutPadrao();
	
	$('.clsData').addClass('campo').setMask('DATE','99/99/9999');
	
	return false;	
}

function controlaFoco() {

	cCdtipchq.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			cCddopcao.habilitaCampo();
			cCddopcao.focus();
			return false;
		}	
	});

	cCddopcao.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
			btnCab.focus();
			liberaCampos();
			return false;
		}	
	});
	
	$('#btnOK','#frmCab').unbind('keypress').bind('keypress', function(e) {
		
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			liberaCampos();
			return false;
		}
	});
 }

 function habilitaOpcao() {
	 
	 cCddopcao.habilitaCampo();
	 cCddopcao.focus();
	 $("#divTbChqsin").css({"display":"block"});
	 liberaCampos(); 
}
 
function liberaCampos() {
	
	if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda')  ) {
		return false;
	}	
	
	cCddopcao.desabilitaCampo();
	cCdtipchq.desabilitaCampo();
		
	$('#divBotoes', '#divTela').css({'display':'block'});
	
	$("#btVoltar","#divBotoes").show();
	$("#btSalvar","#divBotoes").hide();
	$("#btExcluir","#divBotoes").hide();
	
    controlaOperacao();

	return false;
}


function controlaOperacao() {
	
	if( cCdtipchq.val() == 'I') {		
		$("#nrcheque","#tbChqsin").css({'display':'none'});
		$("#nrcheque","#registros").css({'display':'none'});
		$('#indice','#registros').css({'display':'none'});
		$("#checkTodos","#tbChqsin").css({'display':'none'});
		$("#nrcheque","#frmChqsin").hide();
		$("#nrchqfim","#frmChqsin").hide();
		$("#nrchqlbl","#frmChqsin").hide();
		$("#nrchqlbl","#divTransacao").hide();
		$("#nrcheqpesq","#divTransacao").hide();
		$("#btExcluir","#divBotoes").hide();
	 }else{		 
		$("#nrcheque","#tbChqsin").css({'display':'block'});
		$("#nrcheque","#registros").css({'display':'block'});
		if(cddopcao == 'E1'){
			$("#checkTodos","#tbChqsin").css({'display':'block'});
			$("#indice","#registros").css({'display':'block'});
		}else{
			$("#checkTodos","#tbChqsin").css({'display':'none'});
			$("#indice","#registros").css({'display':'none'});
		}
		$("#nrcheque","#frmChqsin").show();
		$("#nrchqfim","#frmChqsin").show();
		$("#nrchqlbl","#frmChqsin").show();
		$("#nrchqlbl","#divTransacao").show();
		$("#nrcheqpesq","#divTransacao").show();
	}
	
	if (cddopcao == "C" ||  cddopcao == "E") {
		$("#divTransacao").css({'display':'block'});
		$('input,select', '#divTransacao').val("");
	}
	
	if ( cddopcao == "I" ) {	
		$("#frmChqsin").css({'display':'block'});
		cTodosFormChqsin.val("");
		cTodosFormChqsin.habilitaCampo();
		$("#nombanco , #nomagencia , #nomconta").desabilitaCampo();
		if(cCdtipchq.val() == "O"){
			$("#datinclusao , #dscmotivo").desabilitaCampo();
			$("#codbanco","#frmChqsin").focus();
		}else{
			$("#dscmotivo").habilitaCampo();
		}
		$("#btSalvar","#divBotoes").html('Incluir').css('display','inline');	
		cddopcao = "I1";
	}
	else 
	if (cddopcao == "I1") {
		confirma();
	}	
	else
	if (cddopcao == "E") {
		cddopcao = "E1";
	}
	else 
	if (cddopcao == "E1") {
		confirma();
	}
	
	return false;
					
}

function btnVoltar() {

	if( cddopcao == "C" && $("#nrconta","#frmChqsin").val() != ''){
		$("#divTransacao").css('display','block');
		$("#frmChqsin").css('display','none');
		$("#nrconta","#frmChqsin").val('');
	}else{
		
		estadoInicial();
		return false;
	} 
}

function confirma() {

	var menssagem;
	
	if(cddopcao == "I1") {
		if (!validainsercao()) {
			return;
		}
		menssagem = 'Deseja incluir Cheques Sinistrados?';  		
	}	
	else if (cddopcao == "E1"){
		menssagem = 'Deseja excluir Cheques Sinistrados?';  
	}	
	showConfirmacao(menssagem,'Confirma&ccedil;&atilde;o - Ayllos','realizaOperacao(\'' + cddopcao + '\'); estadoInicial();','','sim.gif','nao.gif');
}

function realizaOperacao(cddopcao) {
	
	var campoData = '';
	var campoBanco = '';
	var campoAgencia = '';
	var campoCheque = '';
	var campoDesc = '';
	var cdtipchq = cCdtipchq.val();
	var nrcheque = '';
	 var nrchqini = $("#nrcheque","#frmChqsin").val();
	 var nrchqfim = $("#nrchqfim","#frmChqsin").val();
	
	if (cddopcao == "E1"){ 
		showMsgAguardo("Aguarde, excluindo cheques..."); 
	}
	else if (cddopcao == "I1"){ 
		showMsgAguardo("Aguarde, incluindo cheques...");  
	}
	else { 
		showMsgAguardo("Aguarde, consultando cheques..."); 
	}
	
	// Mostra mensagem de aguardo	
	if(cddopcao == "E1"){
		campoData = strDatExc;
		campoBanco = strCBanco;
		campoAgencia = strCAgenciaExc;
		campoCheque = strCContaExc;
	}else if (cddopcao == "I1"){
		campoData = $("#datinclusao").val();
		campoBanco = $("#codbanco").val();
		campoAgencia = $("#codagencia").val();
		campoCheque = $("#nrconta").val();
		campoDesc = $("#dscmotivo").val();
	}else{
		return false;
	}
	
	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/chqsin/manter_rotina.php",
		async: false,	
		data: {
			stracao: cddopcao,
			codbanco : campoBanco,
			codagencia : campoAgencia,
			nrconta : campoCheque,
			dscmotivo : campoDesc,
			datinc : campoData,
			cdtipchq: cdtipchq,
			nrcheque: nrcheque,
			nrchqini: nrchqini,
			nrchqfim: nrchqfim,
			redirect: "script_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			hideMsgAguardo();
			try{
				eval(response);
			} catch(error) {
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
			
		}
	});	
}

function carregaBusca(datInclusao,codBanco,codAgencia,nrdconta,dscMotivo,nrCheque){
	
	
	buscaInformacao(cCdtipchq.val(),'codbanco',codBanco);
	buscaInformacao(cCdtipchq.val(),'codagencia',codBanco+";"+codAgencia);
	// Internos
	if(cCdtipchq.val() == 'I'){
		buscaInformacao(cCdtipchq.val(),'nrconta',codAgencia+";"+nrdconta);
	}	
	
	$("#datinclusao").val(datInclusao);
	$("#codbanco").val(codBanco);
	$("#codagencia").val(codAgencia);
	$("#nrconta").val(nrdconta);
	$("#dscmotivo").val(dscMotivo);
	$("#nrcheque","#frmChqsin").val(nrCheque);
	
	fechaRotina( $('#divUsoGenerico') );
	
	strDatExc = datInclusao;
	strCBanco = codBanco;
	strCAgenciaExc = codAgencia;
	strCContaExc = nrdconta;
	strNrCheque = nrCheque;
	
	$("#divTransacao").css('display','none');
	$("#frmChqsin").css('display','block');
	
	if(cddopcao == 'C'){
		cTodosFormChqsin.desabilitaCampo();
	}
	
	if (cddopcao == "E1") {
		$("#btSalvar","#divBotoes").html('Excluir').css('display','inline');	
	}
	
}
function buscaInformacao(tpdbusca,nmdcampo,intCodBusca) {
	var campoBusca = '';
	var campoInput = '';
	var campoInputDig = '';
	var mensagem = '';
	
	if(tpdbusca == "I"){
		if(nmdcampo == "codbanco"){
			intTipoTela = 1;
		}else if(nmdcampo == "codagencia"){
			intTipoTela = 2;
			intCodBusca = intCodBusca.slice(intCodBusca.indexOf(";")+1); //gielow
		}else if(nmdcampo == "nrconta"){
			intTipoTela = 3;
		}
	}else{ // Tipo "O"
		if(nmdcampo == "codbanco"){
			intTipoTela = 1;
		}else if(nmdcampo == "codagencia"){
			intTipoTela = 4;
			
		}else if(nmdcampo == "nrconta"){
			return false;
		}
	}
	
	$("input","#frmChqsin").removeClass('campoErro');
	
	if(intTipoTela == 1){
		campoBusca = 'CDBCCXLT';
		campoInput = 'nombanco';
		campoInputDig = "codbanco";
		$("#codagencia").val('');
		$("#nrconta").val('');
		mensagem = 'ATENÇÃO: Banco do Sinistro não Encontrado.';
	}else if(intTipoTela == 2){
		campoBusca = 'CDAGECTL';
		campoInput = 'nomagencia';
		campoInputDig = "codagencia";
		$("#nrconta").val('');
		mensagem = 'ATENÇÃO: Agência na Central não Encontrada.';
	}else if(intTipoTela == 3){
		campoBusca = 'NRCTACHQ';
		campoInput = 'nomconta';
		campoInputDig = "nrconta";
		mensagem = 'ATENÇÃO: Número da conta não Encontrada.';
	}else if(intTipoTela == 4){
		campoBusca = 'CDAGEBAN';
		campoInput = 'nomagencia';
		campoInputDig = "codagencia";
		mensagem = 'ATENÇÃO: Agência não Encontrada.';
	}
	
	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'text',
		url: UrlSite + 'telas/chqsin/consulta_dados.php', 
		data: {strCampo: campoBusca,
			   tipoBusca: intTipoTela,
			   valorBusca: intCodBusca,
			redirect: 'html_ajax'			
			},
		async: false,		
		error: function(objAjax,responseError,objExcept) {
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			var arrRetorno = response.split('.');
			
			if(arrRetorno[0] == 0){
				$("#"+campoInput).val('');
				$("#"+campoInputDig).val('');
				showError('error',arrRetorno[1] + ".",'Alerta - Ayllos',"unblockBackground()");
				focaCampoErro(campoInputDig ,"frmChqsin");
				hideMsgAguardo();
			}else{
				$("#"+campoInput).val(arrRetorno[1]);
			}
		}				
	});
	return false;	
}
function somenteCaracteresNumericos(intWhich) {
    var objLetra = String.fromCharCode(intWhich);
    var objRegNum = /[0-9]+/;
    if (!objRegNum.test(objLetra)) {
        return false;
    } else {
        return true;
    }
}
function validaDataInput(objElemento){
	var datInput = $(objElemento).val();
		if(!validaData(datInput)){
			$(objElemento).val('');
			$(objElemento).focus();
		}
}

function validainsercao(){
	
	var cdtipchq = cCdtipchq.val();
	var retorno;
	
	$(".clsvalidainclusao").each(function(){
		if(cdtipchq == 'I'){
			if($(this).css("display") != "none" && $(this).val() == ''){
				showError("error","Todos os campos são obrigatórios.","Alerta - Ayllos","unblockBackground()");
				retorno = false;
			}else{
				retorno = true;
			}
		}else{
			if($("#codbanco").val() == ''){
				showError("error","Informe o Banco!","Alerta - Ayllos","unblockBackground();$('#codbanco').focus();");
				retorno = false;
			}else if($("#codagencia").val() == ''){
				showError("error","Informe a Agência!","Alerta - Ayllos","unblockBackground();$('#codagencia').focus();");
				retorno = false;
			}else if($("#nrconta").val() == ''){
				showError("error","Informe a Conta/dv!","Alerta - Ayllos","unblockBackground();$('#nrconta').focus();");
				retorno = false;
			}else if($("#nrcheque","#frmChqsin").val() == ''){
				showError("error","Informe o número de Cheque Inicial!","Alerta - Ayllos","unblockBackground();$('#nrcheque','#frmChqsin').focus();");
				retorno = false;
			}else if($("#nrchqfim","#frmChqsin").val() == ''){
				showError("error","Informe o número de Cheque Final!","Alerta - Ayllos","unblockBackground();$('#nrchqfim','#frmChqsin').focus();");
				retorno = false;
			}else if($("#nrcheque","#frmChqsin").val() > $("#nrchqfim","#frmChqsin").val() ){
				showError("error","Cheque inicial não pode ser maior que final!","Alerta - Ayllos","unblockBackground();$('#nrcheque','#frmChqsin').focus();");
				retorno = false;
			}else{
				retorno = true;
			}
		}
	});
	return retorno;
}
	
function buscaChequesSinistrados( nriniseq , nrregist){
	showMsgAguardo("Aguarde, consultando cheques...");
	var nrBanco = $("#codbancopesq").val();
	var nrAgencia = $("#codagenciapesq").val();
	var nrConta = $("#nrcontapesq").val();
	var dtIncial = $("#datinicial").val();
	var dtFinal = $("#datfinal").val();
	var nrCheque = $("#nrcheqpesq").val();
	var cdtipchq = cCdtipchq.val();
	
	
	if((cdtipchq == 'O') && (cddopcao == 'E1')) {
		$("#btExcluir","#divBotoes").show();
	}
	
	$.ajax({		
			type: 'POST',
			dataType: 'html',
			url: UrlSite + 'telas/chqsin/tabela_chqsin.php', 
			data: {nrbanco: nrBanco,
				   nragencia: nrAgencia,
				   nrdconta : nrConta,
				   dtinicial: dtIncial,
				   dtfinal  : dtFinal,
				   nriniseq : nriniseq,
				   nrregist : nrregist,
				   nrcheque : nrCheque,
				   cdtipchq : cdtipchq,
				   cddopcao : cddopcao,
				   redirect: 'html_ajax'			
				},
			async: true,		
			error: function(objAjax,responseError,objExcept) {
				showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
			},
			success: function(response) {
				hideMsgAguardo();
				$("#divTabelaCheques").html(response);
			}				
	});

}

function excluiChqFora(){
	
	var cdtipchq = cCdtipchq.val();
	var stracao = cCddopcao.val();
	var camposDc = '';
	var dadosDc  = '';
	
	$('input,select', '#diTbChqsin').removeClass('campoErro');
	
	showMsgAguardo("Aguarde, excluindo cheque(s) selecionado(s)...");	
	
	//Adquire as informações das checkbox selecionadas
	$('#indice','#registros').each(function() {	
		if ($(this).prop('checked')) {
			arrayChqFora[arrayChqFora.length] = arrayRegLinha[$(this).val()];
		}
	});
	
	//Verifica se algum cheque foi selecionado
	if (arrayChqFora.length == 0) {
		hideMsgAguardo();
		showError("error","Nenhum cheque foi selecionado.","Alerta - Ayllos","unblockBackground(); $('#btExcluir', '#divBotoes').focus();");
		return false;
	}
	
	camposDc  = retornaCampos( arrayChqFora, '|' );
	dadosDc   = retornaValores( arrayChqFora, ';', '|',camposDc );
	
	$.ajax({
        type: 'POST',
        url: UrlSite + "telas/chqsin/manter_rotina.php",
        dataType: 'html',
        data: {
			stracao : cddopcao,
			cdtipchq: cdtipchq,
			camposDc: camposDc,
			dadosDc	: dadosDc,
			redirect: 'script_ajax'
		},
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response) {
            
			if ( response.indexOf('showError("error"') == -1 && 
				 response.indexOf('XML error:') == -1 && 
				 response.indexOf('#frmErro') == -1 ) {
					 
				try {					
					showError('inform', 'Cheque(s) com Sinistro excluido(s) com sucesso!', 'Alerta - Ayllos', 'hideMsgAguardo();estadoInicial();');
				} catch(error) {
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "hideMsgAguardo();");
				}
			} else {
				try {
					eval(response);
                    return false;						
				} catch(error) {			
					showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'hideMsgAguardo();estadoInicial();');
				}
			}
        }
    });
    return false;
}

function btExcluir(){
	menssagem = 'Deseja excluir Cheques Sinistrados?';  
	showConfirmacao(menssagem,'Confirma&ccedil;&atilde;o - Ayllos','excluiChqFora(); estadoInicial();','return false;','sim.gif','nao.gif');
}

function check(){
	
	// Adiciona função que ao selecionar o checkbox header, marca/desmarca todos os checkboxs da tabela
	$('#checkTodos','#tbChqsin').each(function() {	
		if ($(this).prop('checked')) {
			$('input[type="checkbox"][name="indice[]"]').prop("checked", this.checked );
		}else{
			$('input[type="checkbox"][name="indice[]"]').prop("checked", false );
		}
	});
}
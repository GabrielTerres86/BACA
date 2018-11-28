/*!
 * FONTE        : slip.js
 * CRIAÇÃO      : Alcemir Junior - Mout's
 * DATA CRIAÇÃO : 21/09/2018
 * OBJETIVO     : Biblioteca de funções da tela SLIP
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

// A - Alteracao
// I - Inclusao
// E -Exclusao
var flagaca = '';
var seqSelecionada;
var vltotrat;
var tab_seqslip;
var tab_cdhistor;
var tab_nrctadeb;
var tab_nrctacrd;
var tab_vllanmto;
var tab_cdhistor_padrao;
var tab_dsoperador;
var tab_dslancamento;
var tab_cdrisco_operacional;
var tab_dsrisco_operacional;
var dtmvtolt;
var cdoperad;


$(document).ready(function() {
	// Estado Inicial da tela
	estadoInicial();
	formatarTabelaParam();	
	formatarTabelaGerencial();
	formatarTabelaRisco();
	formatarTabelaHistorico();
	formatarTabelaLanc();
	formatarTabelaGerencialRat();
	formatarTabelaRiscoRat();
	formatarTabelaIncRisco();
	formatarTabelaCtaContabil();	
	
});


function estadoInicial(){
	//Voltar para a tela principal
	
	$("#divTela").fadeTo(0,0.1);

	hideMsgAguardo();
	//Formatação do cabeçalho
	formataCabecalho();

	//Formatacao da tela 

	formatarParametrizacao();

	formataConsultaParam();
	
	formataGerencial();

	formataRisco();

	formataHistorico();

	formataInclusaoLanc();

	formataConsultaLanc();
	
	removeOpacidade("divTela");

	highlightObjFocus( $("#frmCab") );

	//Exibe cabeçalho e define tamanho da tela
	$("#frmCab").css({"display":"block"});
	$("#divTela").css({"width":"700px","padding-bottom":"2px"});
    
    $("#btConcluir","#divBotoes").hide();
	$("#btVoltar","#divBotoes").hide();

	// Esconder div dos formularios
	$("#divParametrizacao").css({"display":"none"});
	$("#divConParametrizacao").css({"display":"none"});
	$("#tabConParametrizacao").css({"display":"none"});
	$("#divGerencial").css({"display":"none"});
	$("#divRisco").css({"display":"none"});
	$("#divSelParam").css({"display":"none"});
    $("#divHistoricos").css({"display":"none"});
    $("#divIncLancamento").css({"display":"none"});
    $('#divResultadoLanc').css({'display':'none'});
    $('#divResultadoLanc').html('');
	//Esconder os botões da tela
	$("#divBotoes").css({"display":"none"});
	
	$('#divInclusaoAlteracao').css({'display':'none'});
	$('#divConLancamento').css({'display':'none'});
	$('#divFiltrosConLanc').css({'display':'none'});
	$('#incRisco').css({'display':'none'});
	$('#fsRisco').css({'display':'block'});
	$('#fsTabincRisco').css({'display':'none'});
			
		
	//Foca o campo da Opção
	$("#cddotipo","#frmCab").focus();



}

function controlaInclusaoRisco(){
	flagaca = 'I';
	$('#fsRisco').css({'display':'none'});
	$('#divTabBotoesRisco').css({'display':'none'});
	$('#incRisco').css({'display':'block'});
	$('#tabIncRisco').css({'display':'block'});
	$('#tabIncRisco').css({'width':'235px'});
	$('#fsTabincRisco').css({'display':'block'});
	$('#cdrisco_operacional','#frmRisco').habilitaCampo();
	limpaTabelaIncRisco();
	formatarTabelaIncRisco();
	limparCamposRisco();
	focarCodRisco();
	
}

function controlaAlteracaoRisco(){
	
	if (tab_cdrisco_operacional){
		flagaca = 'A';
		$('#fsRisco').css({'display':'none'});
		$('#divTabBotoesRisco').css({'display':'none'});
		$('#incRisco').css({'display':'block'});
		$('#tabIncRisco').css({'display':'block'});
		$('#tabIncRisco').css({'width':'235px'});
		$('#fsTabincRisco').css({'display':'block'});
		limpaTabelaIncRisco();
		formatarTabelaIncRisco();	
		//buscar contas contabeis
		popularCamposAlteracaoRisco();
		focarCodRisco();
	}
	
}

function popularCamposAlteracaoRisco(){


	$('#cdrisco_operacional','#frmRisco').val(tab_cdrisco_operacional);
	$('#dsrisco_operacional','#frmRisco').val(tab_dsrisco_operacional);	
	$('#cdrisco_operacional','#frmRisco').desabilitaCampo();
	limpaTabelaIncRisco();
	$('#tbCtaContabil > tbody > tr').each(function(){	
		criarLinhaCtaContabilAlt($("td:eq(0)", $(this)).html());			
					
	});


	formatarTabelaIncRisco();
	

}

function controlaInclusaoLanc(){
	flagaca = 'I';
	$('#tabIncLancamento').css({'display':'none'});
	$('#divInclusaoAlteracao').css({'display':'block'});
	$('#divTabBotoes').css({'display':'none'});	
	$('#cdhistor','#frmIncLancamento').focus();
	habilitaCampoLanc();
	limparCamposlanc();
	limpaTabelaGerencialRat();
	limpaTabelaRiscoRat();
	formatarTabelaGerencialRat();
	//formatarTabelaIncRisco();
	escoderGerRat();	
	esconderRiscoRat();

}

function habilitaCampoLanc(){
	
	$("#cdhistor_padrao","#frmIncLancamento").addClass("inteiro campo").attr("maxlength","5").css({"width":"45px"}).habilitaCampo();	
	$("#nrctadeb","#frmIncLancamento").addClass("inteiro campo").css({"width":"50px"}).attr("maxlength","5").habilitaCampo();		
	$("#nrctacrd","#frmIncLancamento").addClass("inteiro campo").css({"width":"50px"}).attr("maxlength","5").habilitaCampo();

}

function esconderRiscoRat(){
	$('#fsRiscoRat').css({"display":"none"});
}

function escoderGerRat(){
	$('#fsGerencialRat').css({"display":"none"});
}

function controlaAlteracaoLanc(){
	
	if (tab_seqslip){
		flagaca = 'A';
		$('#tabIncLancamento').css({'display':'none'});
		$('#divInclusaoAlteracao').css({'display':'block'});
		$('#divTabBotoes').css({'display':'none'});
		$('#cdhistor','#frmIncLancamento').focus();
		habilitaCampoLanc();
		limparCamposlanc();
		limpaTabelaGerencialRat();
		limpaTabelaRiscoRat();
		formatarTabelaGerencialRat();
		//formatarTabelaIncRisco();
		escoderGerRat();
		esconderRiscoRat();
		//esconderBotoesRat();
		setarLancamentoAlteracao();
		reqBuscaRisco("L");
		reqBuscaGerencial("L");
	}

}


function setarLancamentoAlteracao(){

	// setar cd historico ailos
	$('#cdhistor','#frmIncLancamento').val(tab_cdhistor);	
	// buscar e setar parametro historico
	$('#cdhistor_padrao','#frmIncLancamento').val(tab_cdhistor_padrao);
	$('#nrctadeb','#frmIncLancamento').val(tab_nrctadeb);
	$('#nrctacrd','#frmIncLancamento').val(tab_nrctacrd);
	reqInsereLancamento();
	$('#vllanmto','#frmIncLancamento').val(tab_vllanmto);
	$('#dslancamento','#frmIncLancamento').val(tab_dslancamento);
	$('#dslancamento','#frmIncLancamento').focus();
	//carregar gerenciais e risco;


}

function retMoeda(numero){

    return numero.toLocaleString('pt-BR').replace('.',',');	

}

function controlaExclusaoLanc(){

	
	if (tab_seqslip){
		var valor = retMoeda(tab_vllanmto);

		showConfirmacao('Confirma a Exclusao do lancamento de sequencia: ' + tab_seqslip + ' Valor: ' + valor  + '?','Aimaro - Confim','reqExcluiLancamento();','','sim.gif','nao.gif');
	}
}	

function mostrarRateioGerencial(){

	$('#divRateio').css({'display':'block'});			
	$('#tabRiscoRat').css({'display':'none'});
	$('#tabGerencialRat').css({'display':'block'});
	$('#tabGerencialRat').css({'width':'323px'});		
	$("#fsGerencialRat").css({"display":"block"});
	$("#fsRiscoRat").css({"display":"none"});
	focarRatGer();
	return false;	
	
}

function reqValidaRateioGerencial(){

	//Requisição para validar conta contabil

	
	var mensagem = 'validando Rateio Gerencial...';
		
	var tipvalida = 'LG';

	var nrctadeb = $('#nrctadeb','#frmIncLancamento').val();
	var nrctacrd = $('#nrctacrd','#frmIncLancamento').val();
    

	showMsgAguardo(mensagem);	

	$.ajax({
        type: "POST",
        url: UrlSite + "telas/slip/valida_conta_contabil.php",
        data: {
			tipvalida: tipvalida,
			nrctadeb: nrctadeb,
			nrctacrd: nrctacrd,          					
			redirect:     "script_ajax"
		},
        error: function(objAjax,responseError,objExcept) {
        
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function(response) {
        	
           hideMsgAguardo();
			try {
				
				eval(response);
			} catch (error) {
					
					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
			}
	
		}
    });

    
    return false;

}

function reqValidaRiscoOperacional(){
	
	//Requisição para validar conta contabil
	
	var mensagem = 'validando Conta Contabil...';
	
	var tipvalida = 'LR';

	var nrctadeb = $('#nrctadeb','#frmIncLancamento').val();
	var nrctacrd = $('#nrctacrd','#frmIncLancamento').val();

	showMsgAguardo(mensagem);	

	$.ajax({
        type: "POST",
        url: UrlSite + "telas/slip/valida_conta_contabil.php",
        data: {
			tipvalida: tipvalida,
			nrctadeb: nrctadeb,
			nrctacrd: nrctacrd,        
			redirect:     "script_ajax"
		},
        error: function(objAjax,responseError,objExcept) {
        
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function(response) {
        	
           hideMsgAguardo();
			try {
				
				eval(response);
			} catch (error) {
					
					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
			}
	
		}
    });

    
    return false;

}

function mostrarRiscoOperacional(){
	$('#divRateio').css({'display':'block'});
	$('#tabGerencialRat').css({'display':'none'});	
	$('#tabRiscoRat').css({'display':'block'});	
	$('#tabRiscoRat').css({'width':'265px'});
	$("#fsGerencialRat").css({"display":"none"});
	$("#fsRiscoRat").css({"display":"block"});
	focarRatRisco();
	return false;
}

function formataCabecalho() {
	// rotulo
	$('label[for="cddotipo"]',"#frmCab").addClass("rotulo").css({"width":"45px"}); 
	
	// campo
	$("#cddotipo","#frmCab").css("width","530px").habilitaCampo();
	
	$('input[type="text"],select','#frmCab').limpaFormulario().removeClass('campoErro');
	layoutPadrao();
	
	//Define ação para ENTER e TAB no campo Opção
	$("#cddotipo","#frmCab").unbind('keydown').bind('keydown', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			//Executa função do botão OK
			liberaFormulario();
			return false;
		}
    });	
	
	//Define ação para CLICK no botão de OK
	$("#btnOK","#frmCab").unbind('click').bind('click', function() {
		liberaFormulario();
		return false;
    });	

	return false;		
}

function liberaFormulario(){
	var cddotipo = $("#cddotipo","#frmCab");

	if(cddotipo.prop("disabled")){
		// Se o campo estiver desabilitado, não executa a liberação do formulário pois já existe uma ação sendo executada
		return;
	}

	cddotipo.desabilitaCampo();

	// Validar a opção que foi selecionada na tela
	switch(cddotipo.val()){

		case "I": // Inclusão Lançamentos
			estadoiniciaInclusao();
		break;

		case "P": // Parametrização
			//estadoInicialParametrizacao();			
			estadoInicialParam();
		break;

		case "CP": //Consulta Parametrização
			estadoInicialConParam();			
		break;

		case "PG": //Parametrização Gerencial
			estadoInicialGerencial();			
		break;

		case "PR": //Parametrização Risco
			estadoInicialRisco();			
		break;

		case "C": // Consulta Lançamentos
			estadoInicialConsulta();
		break;

		default: 
			estadoInicial();
		break;
	}
}

function estadoInicialConsulta(){
	
	hideMsgAguardo();
	

	removeOpacidade("divTela");
	
	limpaTabelaLanc();

	$("#divConLancamento").css({"display":"block"});
	$("#divFiltrosConLanc").css({"display":"block"});
	$("#tabIncLancamento").css({"display":"none"});

	

	$("#divBotoes").css({"display":"block"});

	$("#btVoltar","#divBotoes").show();
	$("#btConcluir","#divBotoes").hide();
	$("#vllanmto","#frmConLancamento").setMask("DECIMAL","zzz.zzz.zz9,99",",");
	//$("#divTabBotoes").css({"display":"block"});
		
	//Limpa os campos do formulário e remove o erro dos campos
	$('input[type="text"],select','#frmConLancamento').limpaFormulario().removeClass('campoErro');

	formatarTabelaConLanc();
	formataConsultaLanc();
			

}

function estadoiniciaInclusao(){

	hideMsgAguardo();
	removeOpacidade("divTela");
	limpaTabelaLanc();
	limpaTabelaGerencialRat();
	limpaTabelaRiscoRat();

	$("#divIncLancamento").css({"display":"block"});

	$("#divBotoes").css({"display":"block"});

	$("#btVoltar","#divBotoes").show();
	$("#btConcluir","#divBotoes").show();
	
	//esconderBotoesRat();

	$("#btIncGerencial","#frmIncLancamento").hide();

	$("#btIncRisco","#frmIncLancamento").hide();

	$("#divRateio").css({"display":"none"});
	$("#divInclusaoAlteracao").css({"display":"none"});
	$("#divTabBotoes").css({"display":"block"});
			
	//Limpa os campos do formulário e remove o erro dos campos
	$('input[type="text"],select','#frmIncLancamento').limpaFormulario().removeClass('campoErro');
	//formataSelParam();
	//reqBuscaSeq();

	

	$("#vllanmto","#frmIncLancamento").setMask("DECIMAL","zzz.zzz.zz9,99",",");
    $("#vllanmtoRat","#frmIncLancamento").setMask("DECIMAL","zzz.zzz.zz9,99",",");
		
	buscaLancamentosDia(1,30);
	formatarTabelaLanc();
	formataInclusaoLanc();
	formatarTabelaGerencialRat();
	formatarTabelaRiscoRat();	

				
	dtmvtolt = $("#dtmvtolt","#frmCab").val();	
	cdoperad = $("#cdoperad","#frmCab").val();	
	$("#dtmvtolt","#frmIncLancamento").val(dtmvtolt);
    $("#cdoperad","#frmIncLancamento").val(cdoperad);
	$("#dtmvtolt","#frmIncLancamento").setMask("DATE","99/99/9999","");

		

}	

function getData(){

}

function esconderBotoesRat(){
	$("#btMostrarRat","#frmIncLancamento").hide();
	$("#btMostrarGer","#frmIncLancamento").hide();

}

function reqBuscaSeq(){
	
	$.ajax({
	        type: "POST",
	        url: UrlSite + "telas/slip/busca_seq.php",
	        data: {	            	            
				redirect:     "script_ajax"
			},
	        error: function(objAjax,responseError,objExcept) {
	        
	            hideMsgAguardo();
	            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')) )");
	        },
	        success: function(response) {
	           	
	           hideMsgAguardo();
				try {					
					eval(response);
				} catch (error) {
						
						hideMsgAguardo();
						showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
				}

		
			}
	    });
    
    	return false;	

}

function setSeq(num){	
	seq = num;	
}


function estadoInicialParam(){

	hideMsgAguardo();
	removeOpacidade("divTela");
	
	$("#divSelParam").css({"display":"block"});

	$("#divBotoes").css({"display":"block"});

	$("#btVoltar","#divBotoes").show();
	$("#btConcluir","#divBotoes").hide();
	

	//Limpa os campos do formulário e remove o erro dos campos
	$('input[type="text"],select','#frmSelParam').limpaFormulario().removeClass('campoErro');
	formataSelParam();

}

function formataSelParam(){

	$('label[for="tpparam"]',"#frmSelParam").css({"width":"260px"});
	$("#tpparam","#frmSelParam").css({"width":"120px"}).habilitaCampo();
	
	$('input[type="text"],select','#frmSelParam').limpaFormulario().removeClass('campoErro');
	
	layoutPadrao();

    $("#btnOKParam","#frmSelParam").unbind('click').bind('click', function(e) {
        liberaFormParam();				
		return false;
        			
    });	

}


function estadoInicialParametrizacao(){

	hideMsgAguardo();
	removeOpacidade("divTela");

	//limpar tabela
	limpaTabelaParam();
	

    //mostrar div    
	$("#divParametrizacao").css({"display":"block"});
	    
	//Esconde cadastro e os botões
	$("#divBotoes").css({"display":"block"});

	
	//mostrar botoes		
	$("#btConcluir","#divBotoes").show();
	$("#btVoltar","#divBotoes").show();

	//Limpa os campos do formulário e remove o erro dos campos
	$('input[type="text"],select','#frmParametrizacao').limpaFormulario().removeClass('campoErro');
		
	buscaContasContabeis();
	//focar no input
	focarInputCtaContabil();

}

function estadoInicialConParam(){

	hideMsgAguardo();
	removeOpacidade("divTela");
	
	limpaTabelaParam();

    //mostrar div    
	$("#divConParametrizacao").css({"display":"block"});
	$("#divConParametrizacao").css({"display":"block"});
	
    
	//Esconde cadastro e os botões
	$("#divBotoes").css({"display":"block"});

	
	//mostrar botoes		
	//$("#btConcluir","#divBotoes").show();
	$("#btVoltar","#divBotoes").show();

	//Limpa os campos do formulário e remove o erro dos campos
	$('input[type="text"],select','#frmParametrizacao').limpaFormulario().removeClass('campoErro');
	
	//formatarParametrizacao();
	formataConsultaParam();
	//focar no input
	focarInputCtaContabil();

}

function estadoInicialRisco(){
	
	hideMsgAguardo();
	removeOpacidade("divTela");
	
	limpaTabelaRisco();
	limpaTabelaIncRisco();
	limpaTabelaCtaContabil();


    //mostrar div    
	$("#divRisco").css({"display":"block"});
	//$("#tabRisco").css({"width":"250px"});
    
	//Esconde cadastro e os botões
	$("#divBotoes").css({"display":"block"});
	
	//mostrar botoes		
	$("#btConcluir","#divBotoes").show();
	$("#btVoltar","#divBotoes").show();
	$('#divTabBotoesRisco').css({'display':'block'});
	
	//Limpa os campos do formulário e remove o erro dos campos
	$('input[type="text"],select','#frmRisco').limpaFormulario().removeClass('campoErro');
	
	formataRisco();
	formatarTabelaIncRisco();
	formatarTabelaCtaContabil();
	//busca os riscos;
	reqBuscaRisco();

	focarCodRisco();
	//formatarParametrizacao();
	//formataConsultaParam();
	//focar no input
	//focarInputCtaContabil();
}

function estadoInicialGerencial(){

	hideMsgAguardo();
	removeOpacidade("divTela");
	
	limpaTabelaGerencial();

    //mostrar div    
	$("#divGerencial").css({"display":"block"});
	$("#tabGerencial").css({"width":"250px"});
    
	//Esconde cadastro e os botões
	$("#divBotoes").css({"display":"block"});
	
	//mostrar botoes		
	//$("#btConcluir","#divBotoes").show();
	$("#btVoltar","#divBotoes").show();

	//Limpa os campos do formulário e remove o erro dos campos
	$('input[type="text"],select','#frmGerencial').limpaFormulario().removeClass('campoErro');
	
	formataGerencial();

	//formatarParametrizacao();
	//formataConsultaParam();
	//focar no input
	//focarInputCtaContabil();

}

function estadoInicialHistorico(){

	hideMsgAguardo();
	removeOpacidade("divTela");
	
	limpaTabelaHistoricos();

    //mostrar div    
	$("#divHistoricos").css({"display":"block"});
	$("#tabHistorcos").css({"width":"250px"});
    
	//Esconde cadastro e os botões
	$("#divBotoes").css({"display":"block"});
	
	//mostrar botoes		
	$("#btConcluir","#divBotoes").show();
	$("#btVoltar","#divBotoes").show();

	//Limpa os campos do formulário e remove o erro dos campos
	$('input[type="text"],select','#frmHistoricos').limpaFormulario().removeClass('campoErro');
	
	formataHistorico();
	reqBuscaHistoricos();
	//formatarParametrizacao();
	//formataConsultaParam();
	//focar no input
	focarCodHistorico();

}

function formataInclusaoLanc(){

	$('label[for="dtmvtolt"]',"#frmIncLancamento").css({"width":"35px"});
	$("#dtmvtolt","#frmIncLancamento").desabilitaCampo();
	
	$('label[for="cdhistor"]',"#frmIncLancamento").css({"width":"78px"});
	$("#cdhistor","#frmIncLancamento").addClass("inteiro campo").css({"width":"57px"}).attr("maxlength","5").habilitaCampo();
	
	$('label[for="nrctadeb"]',"#frmIncLancamento").css({"width":"85px"});
	$("#nrctadeb","#frmIncLancamento").addClass("inteiro campo").css({"width":"50px"}).attr("maxlength","5").habilitaCampo();
	
	$('label[for="nrctacrd"]',"#frmIncLancamento").css({"width":"90px"});
	$("#nrctacrd","#frmIncLancamento").addClass("inteiro campo").css({"width":"50px"}).attr("maxlength","5").habilitaCampo();
	
	$('label[for="vllanmto"]',"#frmIncLancamento").css({"width":"65px"});
	$("#vllanmto","#frmIncLancamento").addClass('moneratio').css({"width":"100px"});
		
	$('label[for="cdhistor_padrao"]',"#frmIncLancamento").css({"width":"90px"});
	$("#cdhistor_padrao","#frmIncLancamento").addClass("inteiro campo").attr("maxlength","5").css({"width":"45px"}).habilitaCampo();

	$('label[for="dslancamento"]',"#frmIncLancamento").css({"width":"85px"});
	$("#dslancamento","#frmIncLancamento").addClass("campo").attr("maxlength","240").css({"width":"396px"}).habilitaCampo();

	$('label[for="cdoperad"]',"#frmIncLancamento").css({"width":"61px"});
	$("#cdoperad","#frmIncLancamento").addClass("campoTelaSemBorda").attr("maxlength","15").css({"width":"100px"});

	$('label[for="dslancamentot"]',"#frmIncLancamento").css({"width":"68px"});
	$("#dslancamentot","#frmIncLancamento").addClass("campoTelaSemBorda").attr("maxlength","240").css({"width":"420px"}).desabilitaCampo();
	
	$('label[for="dsoperador"]',"#frmIncLancamento").css({"width":"68px"});
	$("#dsoperador","#frmIncLancamento").addClass("campoTelaSemBorda").attr("maxlength","200").css({"width":"300px"}).desabilitaCampo();
		
	$("#cdrisco_operacionalRat","#frmIncLancamento").addClass("campo").css({"width":"103px"}).attr("maxlength","25").habilitaCampo();
	$("#cdgerencialRat","#frmIncLancamento").addClass("inteiro campo").css({"width":"55px"}).attr("maxlength","5").habilitaCampo();

	$("#vllanmtoRat","#frmIncLancamento").addClass('moneratio').css({"width":"100px"});

	//addClass('monetario');
	
	//highlightObjFocus( $('#frmIncLancamento') );

	//$("#fsRisco").css({"display":"block"});

	layoutPadrao();

	$('input[type="text"],select','#frmIncLancamento').limpaFormulario().removeClass('campoErro');
	
	
    $("#cdhistor","#frmIncLancamento").unbind('keydown').bind('keydown', function(e) {
		
		var tecla = (e.keyCode?e.keyCode:e.which);
                    
        /* verifica se a tecla pressionada foi o ENTER ou TAB*/
        if(tecla == 13 || tecla == 9){
			buscaParamHistorico();
			controlaFoco();
			return false;	
        }     	
	    
		        
	});	
	
	$("#nrctadeb","#frmIncLancamento").unbind('keydown').bind('keydown', function(e) {
		
		var tecla = (e.keyCode?e.keyCode:e.which);
                    
        /* verifica se a tecla pressionada foi o ENTER ou TAB*/
        if(tecla == 13){
        	focarnrctacrd();
			return false;	
        }     	
	    
		        
	});	

	$("#nrctacrd","#frmIncLancamento").unbind('keydown').bind('keydown', function(e) {
		
		var tecla = (e.keyCode?e.keyCode:e.which);
                    
        /* verifica se a tecla pressionada foi o ENTER ou TAB*/
        if(tecla == 13){
        	focarvllanmto();
			return false;	
        }     	
	    
		        
	});	

	$("#vllanmto","#frmIncLancamento").unbind('keydown').bind('keydown', function(e) {
		
		var tecla = (e.keyCode?e.keyCode:e.which);
                    
        /* verifica se a tecla pressionada foi o ENTER ou TAB*/
        if(tecla == 13){
        	focarcdslancamento();
			return false;	
        }     	
	    
		        
	});	

	$("#cdgerencialRat","#frmIncLancamento").unbind('keydown').bind('keydown', function(e) {
		
		var tecla = (e.keyCode?e.keyCode:e.which);
                    
        /* verifica se a tecla pressionada foi o ENTER ou TAB*/
        if(tecla == 13){
        	focarvllanmtoRat();
			return false;	
        }     	
	    
		        
	});	

	$("#vllanmtoRat","#frmIncLancamento").unbind('keydown').bind('keydown', function(e) {
		
		var tecla = (e.keyCode?e.keyCode:e.which);
                    
        /* verifica se a tecla pressionada foi o ENTER ou TAB*/
        if(tecla == 13){
        	focarvllanmtoRat();
			return false;	
        }     	
	    
		        
	});	

	$("#btMostrarGer","#frmIncLancamento").unbind('click').bind('click', function() {
		reqValidaRateioGerencial();	
		return false;        
	});	

	
	$("#btMostrarRat","#frmIncLancamento").unbind('click').bind('click', function() {
		reqValidaRiscoOperacional();
		return false;	        
	});	


    $("#cdhistor","#frmIncLancamento").focus();

    return false;

}


function formataConsultaLanc(){

	$('label[for="dtmvtolt"]',"#frmConLancamento").css({"width":"80px"});
	$("#dtmvtolt","#frmConLancamento").css({"width":"80px"}).attr("maxlength","12").habilitaCampo();;
	
	$('label[for="cdhistor"]',"#frmConLancamento").css({"width":"80px"});
	$("#cdhistor","#frmConLancamento").addClass("inteiro campo").css({"width":"57px"}).attr("maxlength","5").habilitaCampo();
	
	$('label[for="nrctadeb"]',"#frmConLancamento").css({"width":"90px"});
	$("#nrctadeb","#frmConLancamento").addClass("inteiro campo").css({"width":"50px"}).attr("maxlength","5").habilitaCampo();
	
	$('label[for="nrctacrd"]',"#frmConLancamento").css({"width":"90px"});
	$("#nrctacrd","#frmConLancamento").addClass("inteiro campo").css({"width":"50px"}).attr("maxlength","5").habilitaCampo();
	
	$('label[for="vllanmto"]',"#frmConLancamento").css({"width":"80px"});
	$("#vllanmto","#frmConLancamento");
	
	$('label[for="cdhistor_padrao"]',"#frmConLancamento").css({"width":"136px"});
	$("#cdhistor_padrao","#frmConLancamento").addClass("inteiro campo").attr("maxlength","5").css({"width":"45px"}).habilitaCampo();

	$('label[for="dslancamento"]',"#frmConLancamento").css({"width":"80px"});
	$("#dslancamento","#frmConLancamento").addClass("campo").attr("maxlength","240").css({"width":"433px"}).habilitaCampo();

	$('label[for="cdoperad"]',"#frmConLancamento").css({"width":"102px"});
	$("#cdoperad","#frmConLancamento").addClass("campo").attr("maxlength","15").css({"width":"100px"}).habilitaCampo();

	//$("#fsRisco").css({"display":"block"});

	$('input[type="text"],select','#frmConLancamento').limpaFormulario().removeClass('campoErro');
	
	layoutPadrao();
	
	$("#nrctadeb","#frmConLancamento").unbind('keydown').bind('keydown', function(e) {
		
		var tecla = (e.keyCode?e.keyCode:e.which);
                    
        /* verifica se a tecla pressionada foi o ENTER ou TAB*/
        if(tecla == 13){
        	focarnrctacrd();
			return false;	
        }     	
	    
		        
	});	

	$("#nrctacrd","#frmConLancamento").unbind('keydown').bind('keydown', function(e) {
		
		var tecla = (e.keyCode?e.keyCode:e.which);
                    
        /* verifica se a tecla pressionada foi o ENTER ou TAB*/
        if(tecla == 13){
        	focarvllanmto();
			return false;	
        }     	
	    
		        
	});	

	$("#vllanmto","#frmConLancamento").unbind('keydown').bind('keydown', function(e) {
		
		var tecla = (e.keyCode?e.keyCode:e.which);
                    
        /* verifica se a tecla pressionada foi o ENTER ou TAB*/
        if(tecla == 13){
        	focarcdslancamento();
			return false;	
        }     	
	    
		        
	});

	$("#btConLanc","#frmConLancamento").unbind('click').bind('click', function() {				        		    
	    conLanc(1,30);	
		return false;        
	});
	

    $("#dtmvtolt","#frmConLancamento").focus();

    return false;

}

function conLanc(nriniseq,nrregist){

	
	var dtmvtolt = $("#dtmvtolt","#frmConLancamento").val();

	if (dtmvtolt != ''){
			
			var cdhistor = $("#cdhistor","#frmConLancamento").val();
			var nrctadeb =  $("#nrctadeb","#frmConLancamento").val();			
			var nrctacrd = $("#nrctacrd","#frmConLancamento").val();
			var vllanmto = $("#vllanmto","#frmConLancamento").val();
			var cdhistor_padrao = $("#cdhistor_padrao","#frmConLancamento").val();
			var dslancamento = $("#dslancamento","#frmConLancamento").val();				
			var opevlrlan = $("#opevlrlan","#frmConLancamento").val();	
						
			var mensagem = 'Consultando Lancamentos...';			

		
			
			showMsgAguardo(mensagem);
			
			//Requisição para validar conta contabil
			$.ajax({
				type: "POST",		
				url: UrlSite + "telas/slip/consulta_lancamento.php",
				dataType: 'html',
				data: {  
					nriniseq: nriniseq,
					nrregist: nrregist,
					dtmvtolt: dtmvtolt,
					cdhistor: cdhistor,
					nrctadeb: nrctadeb,
					nrctacrd: nrctacrd,
					vllanmto: vllanmto,
					cdhistor_padrao: cdhistor_padrao,
					dslancamento: dslancamento,					
					opevlrlan: opevlrlan,			
					redirect:     "script_ajax"
				},
				error: function(objAjax,responseError,objExcept) {					
					hideMsgAguardo();
					showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')) )");
				},
				success: function(response) {
					try {           	
						
						if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
							try {
								
								$('input,select','#frmConLancamento').removeClass('campoErro');
								$('#divResultadoConLanc').html('');
								$('#divResultadoConLanc').html(response);											
								formatarTabelaConLanc();
								hideMsgAguardo();
								
							} catch(error) {
								hideMsgAguardo();
								showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','');
							}
						} else {
							try {
								
								eval(response);										
								return false;
							} catch(error) {
								hideMsgAguardo();
								showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','estadoInicial();');
							}
						}
					} catch(error) {
						showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
						hideMsgAguardo();
					}
			
				}
			});

			return false;


		//reqConsultaLanc(1,30);	
	}else{
		showError("error","Deve ser informado ao menos a data para poder consultar.","Alerta - Aimaro","");
	}

	return false;
}

function reqConsultaLanc(nriniseq,nrregist){
	
	
	$("#dtmvtolt","#frmConLancamento").val();
	$("#cdhistor","#frmConLancamento").val();
	$("#nrctadeb","#frmConLancamento").val();
	$("#nrctacrd","#frmConLancamento").val();
	$("#vllanmto","#frmConLancamento").val();
	$("#cdhistor_padrao","#frmConLancamento").val();
	$("#dslancamento","#frmConLancamento").val();	
	$("#cdoperad","#frmConLancamento").val();			
	$("#opevlrlan","#frmConLancamento").val();	

	var mensagem = 'Consultando Lancamentos...';
	
	showMsgAguardo(mensagem);
	
	//Requisição para validar conta contabil
	$.ajax({
        type: "POST",		
        url: UrlSite + "telas/slip/consulta_lancamento.php",
		dataType: 'html',
        data: {  
			nriniseq: nriniseq,
			nrregist: nrregist,
			dtmvtolt: dtmvtolt,
			cdhistor: cdhistor,
			nrctadeb: nrctadeb,
			nrctacrd: nrctacrd,
			vllanmto: vllanmto,
			cdhistor_padrao: cdhistor_padrao,
			dslancamento: dslancamento,
			cdoperad: cdoperad,
			opevlrlan: opevlrlan,			
			redirect:     "script_ajax"
		},
         error: function(objAjax,responseError,objExcept) {
        	
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function(response) {
           	try {           	
           		
                if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
                    try {
               			
                        $('input,select','#frmConLancamento').removeClass('campoErro');
						$('#divResultadoConLanc').html('');
						$('#divResultadoConLanc').html(response);											
                        formatarTabelaConLanc();
                        hideMsgAguardo();
						
					} catch(error) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','');
                    }
                } else {
                    try {
						
                        eval(response);										
                        return false;
                    } catch(error) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','estadoInicial();');
                    }
                }
            } catch(error) {
                showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
                hideMsgAguardo();
            }
	
		}
	});

	return false;

}



function focarIncluirRat(){
	$("#btIncluirGerRat","#frmIncLancamento").focus();
}

function focarvllanmtoRat(){
	$("#vllanmtoRat","#frmIncLancamento").focus();
}

function controlaFoco(){

	var nrctadeb = $("#nrctadeb","#frmIncLancamento").val();
	var nrctacrd = $("#nrctacrd","#frmIncLancamento").val();
	
	// controlar foco ao carregar hist. do parametro 
	if (nrctacrd != "" && nrctadeb != ""){
		focarvllanmto();
	}else{
		if (nrctadeb != ""){
			focarnrctacrd();
		}else{
			focarnrctadeb();
		}		
	}


}

function focarnrctadeb(){
	$("#nrctadeb","#frmIncLancamento").focus();
	$("#nrctadeb","#frmConLancamento").focus();
}

function focarnrctacrd(){
	$("#nrctacrd","#frmIncLancamento").focus();
	$("#nrctacrd","#frmConLancamento").focus();
}

function focarvllanmto(){
	$("#vllanmto","#frmIncLancamento").focus();
	$("#vllanmto","#frmConLancamento").focus();
	
}

function focarcdslancamento(){
	$("#dslancamento","#frmIncLancamento").focus();
	$("#dslancamento","#frmConLancamento").focus();
}




function setParaHist(nrctadeb,nrctacrd,cdhistor_padrao,idris,idger){


	if (flagaca != 'A'){
		$("#nrctacrd","#frmIncLancamento").val(nrctacrd);	
		$("#nrctadeb","#frmIncLancamento").val(nrctadeb);	
		$("#cdhistor_padrao","#frmIncLancamento").val(cdhistor_padrao);
	}

	if (nrctacrd != ""){
		$("#nrctacrd","#frmIncLancamento").desabilitaCampo();
	}else{
		$("#nrctacrd","#frmIncLancamento").habilitaCampo();
	}

	if (nrctadeb != ""){
		$("#nrctadeb","#frmIncLancamento").desabilitaCampo();
	}else{
		$("#nrctadeb","#frmIncLancamento").habilitaCampo();
	}

	if (cdhistor_padrao != ""){
		$("#cdhistor_padrao","#frmIncLancamento").desabilitaCampo();
	}else{
		$("#cdhistor_padrao","#frmIncLancamento").habilitaCampo();
	}
/*
	if (idger === 'S'){
		$("#btMostrarGer","#frmIncLancamento").show();
	}else{
		$("#btMostrarGer","#frmIncLancamento").hide();
	}

	if (idris === 'S'){
		$("#btMostrarRat","#frmIncLancamento").show();
	}else{
		$("#btMostrarRat","#frmIncLancamento").hide();
	}*/


}

function reqInsereLancamento(){

	var cdhistor = $("#cdhistor","#frmIncLancamento").val();

	if (cdhistor != "" ){
		$.ajax({
	        type: "POST",
	        url: UrlSite + "telas/slip/busca_hist_param.php",
	        data: {	            
	            cdhistor: cdhistor,		
				redirect:     "script_ajax"
			},
	        error: function(objAjax,responseError,objExcept) {
	        
	            hideMsgAguardo();
	            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')) )");
	        },
	        success: function(response) {
	           	
	           hideMsgAguardo();
				try {					
					eval(response);
				} catch (error) {
						
						hideMsgAguardo();
						showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
				}

		
			}
	    });

    
    	return false;	
	}

	return false;

}

function buscaParamHistorico(){

	var cdhistor = $("#cdhistor","#frmIncLancamento").val();

	if (cdhistor != "" ){
		$.ajax({
	        type: "POST",
	        url: UrlSite + "telas/slip/busca_hist_param.php",
	        data: {	            
	            cdhistor: cdhistor,		
				redirect:     "script_ajax"
			},
	        error: function(objAjax,responseError,objExcept) {
	        
	            hideMsgAguardo();
	            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')) )");
	        },
	        success: function(response) {
	           	
	           hideMsgAguardo();
				try {					
					eval(response);
				} catch (error) {
						
						hideMsgAguardo();
						showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
				}

		
			}
	    });

    
    	return false;	
	}

	return false;

}


function validaInlcusaoLanc(){
	

	var cdrisco_operacional = $("#cdrisco_operacional","#frmRisco").val();
	var dsrisco_operacional = $("#dsrisco_operacional","#frmRisco").val();
	var flgconta = true;

	if (cdrisco_operacional != "" && dsrisco_operacional != ""){
		
		if (flgconta){						
			criarLinhaRisco(cdrisco_operacional,dsrisco_operacional);	
			$("#cdrisco_operacional").val('');
		    $("#dsrisco_operacional").val('');	
		    focarCodRisco();		
		}

	
	}
	
}


function populaCamposParam(linha){	


	// carregar variaveis globais para popular alteração e efetuar exclusão

	tab_seqslip = $('#nrseq_sliph',linha).val();
	tab_cdhistor = $('#cdhistorh',linha).val();
	tab_nrctadeb = $('#nrctadebh',linha).val();
	tab_nrctacrd = $('#nrctacrdh',linha).val();
	tab_vllanmto = $('#vllanmtoh',linha).val();
	tab_cdhistor_padrao = $('#cdhistor_padraoh',linha).val();		
	tab_dsoperador = $('#dsoperadorh',linha).val();
    tab_dslancamento = $('#dslancamentoh',linha).val();
	tab_cdrisco_operacional = $("td:eq(0)", $(linha)).html();
	tab_dsrisco_operacional = $("td:eq(1)", $(linha)).html();
	

	$("#dsoperador","#frmIncLancamento").val(tab_dsoperador);
	$("#dslancamentot","#frmIncLancamento").val(tab_dslancamento);
	$("#dsoperador","#frmConLancamento").val(tab_dsoperador);
	$("#dslancamentot","#frmConLancamento").val(tab_dslancamento);
	

	return false;
}

function formataHistorico(){

	$('label[for="cdhistor"]',"#frmHistoricos").css({"width":"60px"});
	$("#cdhistor","#frmHistoricos").addClass("inteiro campo").css({"width":"50px"}).attr("maxlength","5").habilitaCampo();
	
	$('label[for="nrctadeb"]',"#frmHistoricos").css({"width":"85px"});
	$("#nrctadeb","#frmHistoricos").addClass("inteiro campo").css({"width":"55px"}).attr("maxlength","5").habilitaCampo();
	
	$('label[for="nrctacrd"]',"#frmHistoricos").css({"width":"90px"});
	$("#nrctacrd","#frmHistoricos").addClass("inteiro campo").css({"width":"55px"}).attr("maxlength","5").habilitaCampo();
	
	//$("#fsRisco").css({"display":"block"});

	$('input[type="text"],select','#frmHistoricos').limpaFormulario().removeClass('campoErro');
	
	layoutPadrao();

    $("#btIncluirHist","#frmHistoricos").unbind('click').bind('click', function(e) {
        validaInclusaoHistorico();	
	    formatarTabelaHistorico();				
		return false;
        			
    });	

}

function mostrartabelaConParam(){
	$('#tabConParametrizacao').css({"display":"block"});
}

function incluirCtaRisco(){
	
	var nrconta_contabil = $("#nrconta_contabil","#frmRisco").val();
	
	if (nrconta_contabil != ""){
				
		var flgconta = true;

		if (nrconta_contabil != ""){

			$('#tbIncRisco > tbody > tr').each(function(){
				
				if ($("td:eq(0)", $(this)).html() == nrconta_contabil){
					flgconta = false;
					showError('alert','Conta contabil ja foi incluida.','Alerta - Aimaro','focarCodRisco();');

				}
				
			});

			if (flgconta){
				reqValidaContaContabil('R',nrconta_contabil);
			}
		
		}	

	}
	
}

function reqValidaContaContabil(tipvalida,nrconta_contabil){

	
	//Requisição para validar conta contabil

	
	var mensagem = 'validando Conta Contabil...';
		

	showMsgAguardo(mensagem);	

	$.ajax({
        type: "POST",
        url: UrlSite + "telas/slip/valida_conta_contabil.php",
        data: {
			tipvalida: tipvalida,
            nrconta_contabil: nrconta_contabil,						
			redirect:     "script_ajax"
		},
        error: function(objAjax,responseError,objExcept) {
        
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function(response) {
        	
           hideMsgAguardo();
			try {
				
				eval(response);
			} catch (error) {
					
					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
			}
	
		}
    });

    
    return false;

}

function formataRisco(){
	
	$('label[for="cdrisco_operacional"]',"#frmRisco").css({"width":"283px"});
	$("#cdrisco_operacional","#frmRisco").addClass("campo").css({"width":"150px"}).attr("maxlength","25").habilitaCampo();
	$('label[for="dsrisco_operacional"]',"#frmRisco").css({"width":"283px"});
	$("#dsrisco_operacional","#frmRisco").addClass("campo").css({"width":"270px"}).attr("maxlength","100").habilitaCampo();
	$('label[for="nrconta_contabil"]',"#frmRisco").css({"width":"95px"});
	$("#nrconta_contabil","#frmRisco").css({"width":"55px"}).attr("maxlength","5").habilitaCampo();

	$("#tabIncRisco").css({"diplay":"block"});
	$("#fsRisco").css({"display":"block"});
	$("#fsCtaContabil").css({"display":"block"});

 
	$('input[type="text"],select','#frmRisco').limpaFormulario().removeClass('campoErro');
	
	layoutPadrao();
   
  
}



function formataGerencial(){

	$("#nmrescop","#frmGerencial").habilitaCampo();
	
	$("#fsGerencial").css({"display":"none"});

	$('input[type="text"],select','#frmGerencial').limpaFormulario().removeClass('campoErro');
	layoutPadrao();

	//Define ação para CLICK no botão de OK
	$("#btnCopOK","#frmGerencial").unbind('click').bind('click', function() {
		
		reqBuscaGerencial();	
		mostrarTabelaGerencial();	
		return false;
    });	


	//Define ação para CLICK no botão Incluir
	$("#cdgerencial","#frmGerencial").unbind('keydown').bind('keydown', function(e) {

		var tecla = (e.keyCode?e.keyCode:e.which);
                    
        // verifica se a tecla pressionada foi o ENTER ou TAB
        if(tecla == 13 || tecla == 9){
        	validaInclusaoGerencial();	
			formatarTabelaGerencial();
			$("#cdgerencial").val('');
		    $("#cdgerencial").focus();				
			return false;
        }
		
		
    });	

    
    $("#btIncluirGer","#frmGerencial").unbind('click').bind('click', function(e) {

        validaInclusaoGerencial();	
		formatarTabelaGerencial();
		$("#cdgerencial").val('');
		$("#cdgerencial").focus();				
		return false;
        			
    });	


    

}



function mostrarTabelaGerencial(){
	liberaCadGerencial();		
	formatarTabelaGerencial();
	$("#cdgerencial").val('');
	$("#cdgerencial").focus();
}

function criarLinhaGerencial(){

	var cdgerencial = $("#cdgerencial","#frmGerencial").val();


	$("#tbGerencial > tbody")
		.append($('<tr>') // Linha			
			.append($('<td>') // Coluna: conta contabil						    				
				.append($('<input>')
					.attr('id',"ck".concat(cdgerencial))
					.attr('name','idativo')
				    .attr('type','checkbox')
				    		    				   
				)

			)
			
			.append($('<td>') // Coluna:hist. padrão				
				.text(cdgerencial)
				.attr('id',"id_".concat(cdgerencial))
			)			
					
		);

	document.getElementById("ck".concat(cdgerencial)).checked = true;

}

function criarLinhaGerencialRat(cdgerencial,vllanmto){

	if (cdgerencial && vllanmto){

		$("#tbGerencialRat > tbody")
			.append($('<tr>') // Linha			
				.append($('<td>') // Coluna: conta contabil						    				
					.text(cdgerencial)
					.attr('id',"id_".concat(cdgerencial))

				)
				
				.append($('<td>') // Coluna:hist. padrão				
					.text(vllanmto)				
				)	

				.append($('<td>') // Coluna: Botão para REMOVER				
					.append($('<img onclick="excluirLinhaGerencialRat(this)">')
						.attr('src', UrlImagens + 'geral/btn_excluir.gif')
					)
				)						
				
						
			);

	}

}


function criarLinhaRiscoRat(cdrisco_operacionalRat){

	if (cdrisco_operacionalRat != ""){
		console.log(cdrisco_operacionalRat);
		$("#tbRiscoRat > tbody")
			.append($('<tr>') // Linha			
				.append($('<td>') // Coluna:codigo risco					    				
					.attr('id',"id_".concat(cdrisco_operacionalRat))
					.text(cdrisco_operacionalRat)
				)			
				.append($('<td>') // Coluna: Botão para REMOVER				
				.append($('<img onclick="excluirLinhaRisRat(this)">')
					.attr('src', UrlImagens + 'geral/btn_excluir.gif')
				)
			)		
						
			);
	
	}

}

function excluirLinhaRisRat(linha){
	$(linha).closest('tr').remove();
}

function criarLinhaRisco(cdrisco_operacional,dsrisco_operacional){

	if (cdrisco_operacional != ""){
		$("#tbRisco > tbody")
			.append($('<tr>') // Linha			
				.append($('<td>') // Coluna:codigo risco					    				
					.attr('id',"id_".concat(cdrisco_operacional))
					.text(cdrisco_operacional)
				)			
				.append($('<td>') // Coluna: descircao risco	
					.text(dsrisco_operacional)				
				)			
						
			);
		
	}


}

function criarLinhaCtaContabil(nrconta_contabil){
	
	if (nrconta_contabil != ""){

	
		$("#tbCtaContabil > tbody")
			.append($('<tr>') // Linha			
				.append($('<td>') // Coluna:codigo risco					    				
					.attr('id',"id_".concat(nrconta_contabil))
					.text(nrconta_contabil)
				)													
			);

	}
}

function criarLinhaCtaContabilAlt(nrconta_contabil){
	
	if (nrconta_contabil != ""){

	
		$("#tbIncRisco > tbody")
			.append($('<tr>') // Linha			
				.append($('<td>') // Coluna:codigo risco					    				
					.attr('id',"id_".concat(nrconta_contabil))
					.text(nrconta_contabil)
				)													
				.append($('<td>') // Coluna: Botão para REMOVER				
					.append($('<img onclick="excluirLinhaCtaAlt(this)">')
					.attr('src', UrlImagens + 'geral/btn_excluir.gif')
				)
			));

	}
}


function liberaCadGerencial(){

	var nmrescop = $("#nmrescop","#frmGerencial");
	
	if(nmrescop.prop("disabled")){
		// Se o campo estiver desabilitado, não executa a liberação do formulário pois já existe uma ação sendo executada
		return;
	}

	$('label[for="cdgerencial"]',"#frmGerencial").css({"width":"280px"});
	$("#cdgerencial","#frmGerencial").addClass("inteiro campo").css({"width":"50px"}).attr("maxlength","5").habilitaCampo();
	$("#btConcluir","#divBotoes").show();
	$("#nmrescop").desabilitaCampo();
	$("#fsGerencial").css({"display":"block"});
}


function liberaFormParam(){

	var tpparam = $("#tpparam","#frmSelParam");
	

	if(tpparam.prop("disabled")){
		// Se o campo estiver desabilitado, não executa a liberação do formulário pois já existe uma ação sendo executada
		return;
	}

	// Validar a opção que foi selecionada na tela
	switch(tpparam.val()){

		case "I": // Inclusão Lançamentos
			estadoiniciaInclusao();
		break;

		case "PC": // Parametrização
			//estadoInicialParametrizacao();					
			estadoInicialParametrizacao();
		break;		

		case "PG": //Parametrização Gerencial
			estadoInicialGerencial();			
		break;

		case "PR": //Parametrização Risco
			estadoInicialRisco();			
		break;

		case "PH": //Parametrização Historico
			estadoInicialHistorico();			
		break;

		default: 
			estadoInicial();
		break;
	}

	$("#tpparam").desabilitaCampo();

	return false;
}


function formataConsultaParam(){

 	 // rotulo
	$('label[for="nrconta_contabil"]',"#frmConParametrizacao").css({"width":"50px"});
	$('label[for="cdhistor"]',"#frmConParametrizacao").css({"width":"83px"});	
	$('label[for="idexige_rateio_gerencial"]',"#frmConParametrizacao").css({"width":"130px"});		
	$('label[for="idexige_risco_operacional"]',"#frmConParametrizacao").css({"width":"140px"});	

	// campo
	$("#nrconta_contabil","#frmConParametrizacao").addClass("inteiro campo").css({"width":"50px"}).attr("maxlength","5").habilitaCampo();
	$("#cdhistor","#frmConParametrizacao").addClass("inteiro campo").css({"width":"50px"}).attr("maxlength","5").habilitaCampo();
	$("#idexige_rateio_gerencial","#frmConParametrizacao").css({"width":"50px"}).habilitaCampo();
	$("#idexige_risco_operacional","#frmConParametrizacao").css({"width":"50px"}).habilitaCampo();
	
	limparCamposParam();

	$("#btConsultaOK","#frmConParametrizacao").unbind('click').bind('click', function() {
		buscaContasContabeis();
		return false;
    });	


}

function buscaLancamentosDia(nriniseq,nrregist){

	//Requisição para buscar lancamentos
	var mensagem = 'Buscando Lancamentos...';
	
	showMsgAguardo(mensagem);	


	$.ajax({
        type: "POST",
        url: UrlSite + "telas/slip/busca_lancamentos.php",
        dataType: 'html',
        data: {
           	nriniseq: nriniseq,
           	nrregist: nrregist,           	
			redirect:     "script_ajax"
		},
		
        error: function(objAjax,responseError,objExcept) {
        
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function(response) {
           	try {

           	
           	
                if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
                    try {
               
                        $('input,select','#frmIncLancamento').removeClass('campoErro');
						$('#divResultadoLanc').html('');
						$('#divResultadoLanc').html(response);											
                        formatarTabelaLanc();
                        hideMsgAguardo();
						
					} catch(error) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','');
                    }
                } else {
                    try {
                        eval(response);										
                        return false;
                    } catch(error) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','estadoInicial();');
                    }
                }
            } catch(error) {
                showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
                hideMsgAguardo();
            }
	
		}
    });

    
    return false;


} 

function buscaContasContabeis(){

	//Requisição para buscar contas contabeis
	var mensagem = 'Buscando Contas contabeis...';
	
	showMsgAguardo(mensagem);	


	$.ajax({
        type: "POST",
        url: UrlSite + "telas/slip/busca_contas_contabeis.php",
        data: {            	
			redirect:     "script_ajax"
		},
        error: function(objAjax,responseError,objExcept) {
        
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function(response) {
           	
           hideMsgAguardo();
			try {
				
				eval(response);
			} catch (error) {
					
					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
			}

	
		}
    });

    
    return false;

}


function controlaVoltar(){
	
	if (flagaca == 'I' || flagaca == 'A' || flagaca == 'E'){
		$('#tabIncLancamento').css({'display':'block'});
		$('#divInclusaoAlteracao').css({'display':'none'});
		limparCamposlanc();
		$('#divTabBotoes').css({'display':'block'});
		
		$('#fsTabincRisco').css({'display':'none'});
		$('#fsRisco').css({'display':'block'});
		$('#divTabBotoesRisco').css({'display':'block'});

		limparCamposRisco();
		flagaca = '';	

	}else{
		flagaca = '';
		estadoInicial();	
	}	
	
}

function limparCamposRisco(){

	$("#cdrisco_operacional","#frmConLancamento").val('');
	$("#dsrisco_operacional","#frmConLancamento").val('');
	$("#cdrisco_operacional","#frmRisco").val('');
	$("#dsrisco_operacional","#frmRisco").val('');
	$("#nrconta_contabil","#frmRisco").val('');
	
}

function limparCamposlanc(){

	$("#cdhistor","#frmIncLancamento").val('');
	$("#nrctadeb","#frmIncLancamento").val('');
	$("#nrctacrd","#frmIncLancamento").val('');
	$("#vllanmto","#frmIncLancamento").val('');
	$("#cdhistor_padrao","#frmIncLancamento").val('');
	$("#dslancamento","#frmIncLancamento").val('');	

}

function limparCamposRateio(){

	$('#cdrisco_operacionalRat','#frmIncLancamento').val('');
	$('#vllanmtoRat','#frmIncLancamento').val('');
	$('#cdgerencialRat','#frmIncLancamento').val('');	
}

function focarRatGer(){
	$('#cdgerencialRat','#frmIncLancamento').focus();	
}

function focarRatRisco(){
	$('#cdrisco_operacionalRat','#frmIncLancamento').focus();	
}

function incluirRisRat(){

	validaInclusaoRiscoRat();	
	formatarTabelaRiscoRat();				
	return false;
				

}

function incluirGerRat(){
	
	validaInclusaoGerencialRat();	
	formatarTabelaGerencialRat();				
	return false;
				


}

function formatarParametrizacao(){

//onclick="validaInclusaoContaContabil(); return false;"
	
    // rotulo
	$('label[for="nrconta_contabil"]',"#frmParametrizacao").css({"width":"50px"});
	$('label[for="cdhistor"]',"#frmParametrizacao").css({"width":"83px"});	
	$('label[for="idexige_rateio_gerencial"]',"#frmParametrizacao").css({"width":"130px"});		
	$('label[for="idexige_risco_operacional"]',"#frmParametrizacao").css({"width":"140px"});	

	// campo
	$("#nrconta_contabil","#frmParametrizacao").addClass("inteiro campo").css({"width":"50px"}).attr("maxlength","5").habilitaCampo();
	$("#cdhistor","#frmParametrizacao").addClass("inteiro campo").css({"width":"50px"}).attr("maxlength","5").habilitaCampo();
	$("#idexige_rateio_gerencial","#frmParametrizacao").css({"width":"50px"}).habilitaCampo();
	$("#idexige_risco_operacional","#frmParametrizacao").css({"width":"50px"}).habilitaCampo();
	
	//Define ação para CLICK no botão de OK	
	$("#btIncluirParam","#frmParametrizacao").unbind('click').bind('click', function() {
		validaInclusaoContaContabil();
		return false;
    });	




}


function limpaLinhasTabelaParam(){
	$("#tbParametrizacao > tbody").html("");
	$("#tbConParametrizacao > tbody").html("");
}


function limpaTabelaParam(){
	$("#tbParametrizacao > tbody","#frmParametrizacao").html("");
	$("#tbParametrizacao > thead","#frmParametrizacao").html("");
}

function limpaTabelaGerencial(){
	$("#tbGerencial > tbody").html("");
	$("#tbGerencial > thead").html("");
}

function limpaTabelaGerencialRat(){
	$("#tbGerencialRat > tbody").html("");
	$("#tbGerencialRat > thead").html("");
}


function limpaTabelaIncRisco(){
	$("#tbIncRisco > tbody").html("");
	$("#tbIncRisco > thead").html("");
}


function limpaTabelaRiscoRat(){
	$("#tbRiscoRat > tbody").html("");
	$("#tbRiscoRat > thead").html("");
}

function limpaTabelaRisco(){
	$("#tbRisco > tbody").html("");
	$("#tbRisco > thead").html("");
}

function limpaTabelaCtaContabil(){
	$("#tbCtaContabil > tbody").html("");
	$("#tbCtaContabil > thead").html("");
}

function limpaTabelaLanc(){
	$("#tbLancamento > tbody").html("");
	$("#tbLancamento > thead").html("");
}



function limpaTabelaHistoricos(){
	$("#tbHistoricos > tbody").html("");
	$("#tbHistoricos > thead").html("");
}

function LimpaLinhasTabelaGerencial(){
	$("#tbGerencial > tbody").html("");
}


function formatarTabelaParam(){
	
	// Tabela
	var divRegistro = $("div.divRegistros", "#tabParametrizacao");
	var tabela      = $("table", divRegistro );
	var linha       = $("table > tbody > tr", divRegistro );

    $("#tabParametrizacao").css({"margin-top":"5px"});	
	$("#fsTabIncLancamentot").css({"margin-top":"3px","padding-bottom":"3px","height":"50px"});

	divRegistro.css({"height":"200px","width":"675px","padding-bottom":"2px"});

	var ordemInicial = new Array();

	//Define a largura dos campos
	var arrayLargura = new Array();
    arrayLargura[0] = "";
    arrayLargura[1] = "120px";
    arrayLargura[2] = "70px";
    arrayLargura[3] = "70px";
  

	//Define a posição dos elementos nas células da linha
    var arrayAlinha = new Array();
	arrayAlinha[0] = "center";
	arrayAlinha[1] = "center";
    arrayAlinha[2] = "center";
    arrayAlinha[3] = "center";
    



	//Aplica as informações na tabela
	$(".ordemInicial","#tabParametrizacao").remove();
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);

	return false;

}

function formatarTabelaIncRisco(){
	// Tabela
	var divRegistro = $("div.divRegistros", "#tabIncRisco");
	var tabela      = $("table", divRegistro );
	var linha       = $("table > tbody > tr", divRegistro );

    $("#tabIncRisco").css({"margin-top":"5px","margin-left":"32%"});
    $("#incRisco").css({"vertical-align": "top","height":"27px","margin-top":"5px"});
    
	divRegistro.css({"height":"200px","width":"220px"});

	var ordemInicial = new Array();

	//Define a largura dos campos
	var arrayLargura = new Array();
    arrayLargura[0] = "";
    arrayLargura[1] = "50px";
    
	//Define a posição dos elementos nas células da linha
    var arrayAlinha = new Array();
	arrayAlinha[0] = "center";
	arrayAlinha[1] = "center";
       
	//Aplica as informações na tabela
	$(".ordemInicial","#tabIncRisco").remove();
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);

	return false;

}



function formatarTabelaGerencial(){
	// Tabela
	var divRegistro = $("div.divRegistros", "#tabGerencial");
	var tabela      = $("table", divRegistro );
	var linha       = $("table > tbody > tr", divRegistro );

    $("#tabGerencial").css({"margin-top":"5px","margin-left":"32%"});
    $("#incGerencial").css({"vertical-align": "top","height":"27px","margin-top":"5px"});
    
	divRegistro.css({"height":"250px","width":"250px"});

	var ordemInicial = new Array();

	//Define a largura dos campos
	var arrayLargura = new Array();
    arrayLargura[0] = "80px";
    arrayLargura[1] = "150px";
    
	//Define a posição dos elementos nas células da linha
    var arrayAlinha = new Array();
	arrayAlinha[0] = "center";
	arrayAlinha[1] = "center";
       
	//Aplica as informações na tabela
	$(".ordemInicial","#tabGerencial").remove();
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);

	/* Alinhar checkboxes no meio da coluna */
	$('input[type="checkbox"]','#tbGerencial').attr('style','float: inherit;');

	return false;

}

function formatarTabelaGerencialRat(){

	// Tabela
	var divRegistro = $("div.divRegistros", "#tabGerencialRat");
	var tabela      = $("table", divRegistro );
	var linha       = $("table > tbody > tr", divRegistro );

	$("#tabGerencialRat").css({"margin-top":"5px","margin-left":"27%"});
	$("#incGerencialRat").css({"vertical-align": "top","height":"27px","margin-top":"5px"});	
	divRegistro.css({"height":"250px","width":"323px"});
	
	
	$('label[for="cdgerencialRat"]',"#frmIncLancamento").css({"width":"243px"});
	$('label[for="vllanmtoRat"]',"#frmIncLancamento").css({"width":"37px"});
	var ordemInicial = new Array();

	//Define a largura dos campos
	var arrayLargura = new Array();
    arrayLargura[0] = "90px";
    arrayLargura[1] = "";
	arrayLargura[2] = "75px";
	
	//Define a posição dos elementos nas células da linha
    var arrayAlinha = new Array();
	arrayAlinha[0] = "center";
	arrayAlinha[1] = "center";
	arrayAlinha[2] = "center";
       
	//Aplica as informações na tabela
	$(".ordemInicial","#tabGerencialRat").remove();
	tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);

	return false;

}


function formatarTabelaRiscoRat(){

	// Tabela
	var divRegistro = $("div.divRegistros", "#tabRiscoRat");
	var tabela      = $("table", divRegistro );
	var linha       = $("table > tbody > tr", divRegistro );

	$("#tabRiscoRat").css({"margin-top":"5px","margin-left":"33%"});
	$("#incRiscoRat").css({"vertical-align": "top","height":"27px","margin-top":"5px"});	
	divRegistro.css({"height":"250px","width":"265px"});
		
	$('label[for="cdrisco_operacionalRat"]',"#frmIncLancamento").css({"width":"298px"});	
	
	var ordemInicial = new Array();

	//Define a largura dos campos
	var arrayLargura = new Array();
    arrayLargura[0] = "";
    arrayLargura[1] = "80px";
	
	
	//Define a posição dos elementos nas células da linha
    var arrayAlinha = new Array();
	arrayAlinha[0] = "center";
	arrayAlinha[1] = "center";
	
       
	//Aplica as informações na tabela
	$(".ordemInicial","#tabRiscoRat").remove();
	tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);

	return false;

}



function formatarTabelaHistorico(){

	// Tabela
	var divRegistro = $("div.divRegistros", "#tabHistoricos");
	var tabela      = $("table", divRegistro );
	var linha       = $("table > tbody > tr", divRegistro );

    $("#tabHistoricos").css({"margin-top":"5px"});
	divRegistro.css({"height":"250px","width":"672px","padding-bottom":"2px"});

	var ordemInicial = new Array();

	//Define a largura dos campos
	var arrayLargura = new Array();
    arrayLargura[0] = "";
    arrayLargura[1] = "150px";
    arrayLargura[2] = "150px";
    arrayLargura[3] = "120px";
    

	//Define a posição dos elementos nas células da linha
    var arrayAlinha = new Array();
	arrayAlinha[0] = "center";
	arrayAlinha[1] = "center";
    arrayAlinha[2] = "center";
    arrayAlinha[3] = "center";
    

	//Aplica as informações na tabela
	$(".ordemInicial","#tabHistoricos").remove();
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);

	return false;

}

function formatarTabelaLanc(){

	// Tabela
	var divRegistro = $("div.divRegistros", "#tabIncLancamento");
	var tabela      = $("table", divRegistro );
	var linha       = $("table > tbody > tr", divRegistro );

    $("#tabIncLancamento").css({"margin-top":"5px"});
	divRegistro.css({"height":"200px","width":"687px","padding-bottom":"2px"});
	$('#divRegistrosRodape','#divIncLancamento').formataRodapePesquisa();
	$('#divResultadoLanc').css({'display':'block'});

	var ordemInicial = new Array();
	
	//Define a largura dos campos
	var arrayLargura = new Array();
    arrayLargura[0] = "72px";
    arrayLargura[1] = "100px";
    arrayLargura[2] = "100px";
    arrayLargura[3] = "100px";
    arrayLargura[4] = "100px";
    arrayLargura[5] = "100px";       
	arrayLargura[6] = "";
    arrayLargura[7] = "";    
	arrayLargura[8] = "";  
    
 
	//Define a posição dos elementos nas células da linha
    var arrayAlinha = new Array();
	arrayAlinha[0] = "center";
	arrayAlinha[1] = "center";
    arrayAlinha[2] = "center";
    arrayAlinha[3] = "center";
    arrayAlinha[4] = "center";
	arrayAlinha[5] = "center";    
    arrayAlinha[6] = "center";    	
	arrayAlinha[7] = "center";    	
	arrayAlinha[8] = "center";  

	
	

	

    // seleciona o registro que é focado
	$('table > tbody > tr', '#tabIncLancamento').focus(function() { 
		populaCamposParam($(this)); 
		
	});

	populaCamposParam($("tr:first-child","#tbLancamento"));

	
	//Aplica as informações na tabela
	$(".ordemInicial","#tabIncLancamento").remove();
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);

	$('tbody tr', '#tbLancamento').bind('click',function() {		
		populaCamposParam($(this)); 
	
	});

	
	$('table thead th', '#fsTabIncLancamento').unbind('mouseup');
	$('table thead th', '#fsTabIncLancamento').unbind('mousedown');

	$('table thead th', '#fsTabIncLancamento').unbind('click').bind('click',function(){
		//seleciona primeira linha da tabela
		//$('tbody tr:first-child', '#tbLancamento').addClass('corSelecao');
	});

	return false;

}



function formatarTabelaConLanc(){

	// Tabela
	var divRegistro = $("div.divRegistros", "#tabIncLancamento");
	var tabela      = $("table", divRegistro );
	var linha       = $("table > tbody > tr", divRegistro );

    $("#tabIncLancamento").css({"margin-top":"5px"});
	divRegistro.css({"height":"200px","width":"687px","padding-bottom":"2px"});
	$('#divRegistrosRodape','#divIncLancamento').formataRodapePesquisa();
	$('#divResultadoLanc').css({'display':'block'});

	var ordemInicial = new Array();
	
	//Define a largura dos campos
	var arrayLargura = new Array();
    arrayLargura[0] = "72px";
    arrayLargura[1] = "100px";
    arrayLargura[2] = "100px";
    arrayLargura[3] = "100px";
    arrayLargura[4] = "100px";
    arrayLargura[5] = "100px";       
	arrayLargura[6] = "";
    arrayLargura[7] = "";    
	arrayLargura[8] = "";  
    
 
	//Define a posição dos elementos nas células da linha
    var arrayAlinha = new Array();
	arrayAlinha[0] = "center";
	arrayAlinha[1] = "center";
    arrayAlinha[2] = "center";
    arrayAlinha[3] = "center";
    arrayAlinha[4] = "center";
	arrayAlinha[5] = "center";    
    arrayAlinha[6] = "center";    	
	arrayAlinha[7] = "center";    	
	arrayAlinha[8] = "center";  

	

	$('table > tbody > tr', '#tabIncLancamento').click(function() {		
		populaCamposParam($(this)); 
	
	});

    // seleciona o registro que é focado
	$('table > tbody > tr', '#tabIncLancamento').focus(function() { 
		populaCamposParam($(this)); 
		
	});

	populaCamposParam($("tr:first-child","#tbLancamento"));

	//Aplica as informações na tabela
	$(".ordemInicial","#tabIncLancamento").remove();
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);

	return false;

}


function formatarTabelaRisco(){

	// Tabela
	var divRegistro = $("div.divRegistros", "#tabRisco");
	var tabela      = $("table", divRegistro );
	var linha       = $("table > tbody > tr", divRegistro );

    $("#tabRisco").css({"margin-top":"5px"});	 
    $("#tabListaRisco").css({"display": "block","margin-top":"5px"});    

	divRegistro.css({"height":"253px","width":"491px"});

	var ordemInicial = new Array();

	//Define a largura dos campos
	var arrayLargura = new Array();
    arrayLargura[0] = "170px";
    arrayLargura[1] = "";
    
	//Define a posição dos elementos nas células da linha
    var arrayAlinha = new Array();
	arrayAlinha[0] = "center";
	arrayAlinha[1] = "left";
       
	//Aplica as informações na tabela
	$(".ordemInicial","#tabRisco").remove();
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);


	$('table > tbody > tr', '#tabRisco').click(function() {		
		populaCamposParam($(this)); 
		reqBuscaContaContabil();
	
	});

    // seleciona o registro que é focado
	$('table > tbody > tr', '#tabRisco').focus(function() { 
		populaCamposParam($(this)); 
		reqBuscaContaContabil();
		
	});

	populaCamposParam($("tr:first-child","#tbRisco"));
	reqBuscaContaContabil();


	return false;

}

function reqBuscaContaContabil(){
	

	var mensagem = 'Buscando Contas Contabeis...';	
	
	showMsgAguardo(mensagem);
		
	//Requisição para buscar historicos
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/slip/busca_conta_contabil.php",
        data: {      
			cdrisco_operacional: tab_cdrisco_operacional,
			redirect:     "script_ajax"
		},
        error: function(objAjax,responseError,objExcept) {
        
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function(response) {
        	
           hideMsgAguardo();
			try {			
				eval(response);
			} catch (error) {
					
					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
			}

	
		}
    });
    
    return false;
}


function formatarTabelaCtaContabil(){

	// Tabela
	var divRegistro = $("div.divRegistros", "#tabCtaContabil");
	var tabela      = $("table", divRegistro );
	var linha       = $("table > tbody > tr", divRegistro );

    $("#tabCtaContabil").css({"margin-top":"5px"});
   // $("#incRisco").css({"vertical-align": "top","height":"27px","margin-top":"5px"});    

	divRegistro.css({"height":"230px","width":"160px"});

	var ordemInicial = new Array();

	//Define a largura dos campos
	var arrayLargura = new Array();
    arrayLargura[0] = "100px";
    
    
	//Define a posição dos elementos nas células da linha
    var arrayAlinha = new Array();
	arrayAlinha[0] = "center";	
       
	//Aplica as informações na tabela
	$(".ordemInicial","#tabCtaContabil").remove();
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);

	return false;

}



function excluirLinhaParametro(linha){
	$(linha).closest('tr').remove();
}

function excluirLinhaLanc(linha){
	$(linha).closest('tr').remove();
}


function excluirLinhaHistorico(linha){
	$(linha).closest('tr').remove();
}

function excluirLinhaCtaAlt(linha){
	$(linha).closest('tr').remove();
}



function excluirLinhaGerencialRat(linha){
	$(linha).closest('tr').remove();
}

function criarLinhaLanc(seq,cdhistor,nrctadeb,nrctacrd,vllanmto,cdhistor_padrao,dsoperador,cdoperad,dslancamento){
	


	var tr = $('<tr>') // Linha
			.attr('id',"id_".concat(cdhistor))
			.append($('<td>') // Coluna: conta contabil				
				.text(seq)
			)
			.append($('<td>') // Coluna:hist. padrão				
				.text(cdhistor)
			)
			.append($('<td>') // Coluna: exige gerencial				
				.text(nrctadeb)
			)	
			.append($('<td>') // Coluna: exige risco oper.								
				.text(nrctacrd)
			)				
			.append($('<td>') // Coluna: exige risco oper.				
				.text(vllanmto)
			)	
			.append($('<td>') // Coluna: exige risco oper.				
				.text(cdhistor_padrao)
			)				
			.append($('<input>') // Coluna: exige risco oper.		
				.attr('type','hidden')	
				.attr('id','dslancamentoh')	
				.attr('value',dslancamento)								
		
			)			
			.append($('<input>') // Coluna: exige risco oper.		
				.attr('type','hidden')	
				.attr('id','cdoperadh')	
				.attr('value',cdoperad)							
		
			)
			.append($('<input>') // Coluna: exige risco oper.		
				.attr('type','hidden')	
				.attr('id','dsoperadorh')								
				.attr('value',dsoperador)				
			);						
		
		$("#tbLancamento > tbody").append($(tr));


/*			


    // seleciona o registro que é clicado
	$('table > tbody > tr', divRegistro).click( function() {
		selecionaTabela($(this)); 
	});

    // seleciona o registro que é focado
	$('table > tbody > tr', divRegistro).focus( function() { 
		selecionaTabela($(this));
	});
	


    cdcooper = $('#cdcooper', tr).val();
    dsbccxlt = $('#dsbccxlt', tr).val();
    banco = $('#banco', tr).val();
    nrcheque = $('#nrcheque', tr).val();
    nrdctitg = $('#nrdctitg', tr).val();
	cdbanchq = $('#cdbanchq', tr).val();
    cdagechq = $('#cdagechq', tr).val();
	cddsitua = $('#cddsitua', tr).val();
    nrdrecid = $('#nrdrecid', tr).val();
    vllanmto = $('#vllanmto', tr).val();
    nrctachq = $('#nrctachq', tr).val();
	alinea   = $('#cdalinea', tr).val();
    nmoperad = $('#nmoperad', tr).val();
	nrdconta_tab = $('#nrdconta', tr).val();
    flag     = $('#flag', tr).val();
	dstabela = $('#dstabela', tr).val();
	altalinea = false;*/
    
}

/*

   if (dstransa != ""){

    	mostraTabelasConsulta();

    	let tr = $('<tr>') // Linha
			.attr('id',"id_".concat(cdtransa))
			.append($('<td>') // Coluna: Cód. transacao
				.attr('style','width: 80px; text-align:right')
				.text(cdtransa)
			)
			.append($('<td>') // Coluna: Des. transacao
				.attr('style','text-align:left')
				.text(dstransa)
			)
			.append($('<td>') // Coluna: D/C
				.attr('style','text-align:center')
				.text(indebcre)
			);

			//onclick=

			$(tr).unbind('click').bind('click',function(){
				ConsultaHistoricoAilos(this);
			});



		$("#tbConcon > tbody")
		.append($(tr));

	}else{
		showError('alert','Parametro n&atilde;o encontrado!','Alerta - Aimaro','estadoInicialConsulta()');
	}


	*/

function criarLinhaHistorico(cdhistor,nrctadeb,nrctacrd){
	
/*	var cdhistor = $("#cdhistor","#frmHistoricos").val();
	var nrctadeb = $("#nrctadeb","#frmHistoricos").val();
	var nrctacrd = $("#nrctacrd","#frmHistoricos").val();
*/

	if (cdhistor != ""){

		$("#tbHistoricos > tbody")
		.append($('<tr>') // Linha
			.attr('id',"id_".concat(cdhistor))
			.append($('<td>') // Coluna: historico				
				.text(cdhistor)
			)
			.append($('<td>') // Coluna: conta debito			
				.text(nrctadeb)
			)
			.append($('<td>') // Coluna: conta credito				
				.text(nrctacrd)
			)	
			.append($('<td>') // Coluna: Botão para REMOVER				
				.append($('<img onclick="excluirLinhaHistorico(this)">')
					.attr('src', UrlImagens + 'geral/btn_excluir.gif')
				)
			)	
					
		);

	}
	
	   
}


function criarLinhaConParam(nrconta_contabil,cdhistor,idexige_rateio_gerencial,idexige_risco_operacional){

	if (nrconta_contabil != ""){

		$("#tbParametrizacao > tbody")
			.append($('<tr>') // Linha
				.attr('id',"id_".concat(nrconta_contabil))
				.append($('<td>') // Coluna: conta contabil				
					.text(nrconta_contabil)
				)
				.append($('<td>') // Coluna:hist. padrão				
					.text(cdhistor)
				)
				.append($('<td>') // Coluna: exige gerencial				
					.text(idexige_rateio_gerencial)
				)	
				.append($('<td>') // Coluna: exige risco oper.
					
					.text(idexige_risco_operacional)
				)				
						
			);
	}

}

function criarLinhaBuscaGerencial(cdgerencial,idativo){



	if (cdgerencial != "" && idativo != ""){

		$("#tbGerencial > tbody")
		.append($('<tr>') // Linha			
			.append($('<td>')  // Coluna: conta contabil								
				.append($('<input>')
					.attr('id',"ck".concat(cdgerencial))
					.attr('name','idativo')
				    .attr('type','checkbox')	
				    				   				   		    				 
				)

			)

			
			.append($('<td>') // Coluna:hist. padrão				
				.text(cdgerencial)
				.attr('id',"id_".concat(cdgerencial))
			)			
					
		);

		// setar checkbox
		if (idativo == "S"){
			document.getElementById("ck".concat(cdgerencial)).checked = true;
		}else{
			document.getElementById("ck".concat(cdgerencial)).checked = false;
		}
		
	}


}



function focarInputCtaContabil(){
	$("#nrconta_contabil","#frmParametrizacao").focus();
	$("#nrconta_contabil","#frmConParametrizacao").focus();
}

function focarCtaContabilRisco(){
	$("#nrconta_contabil","#frmRisco").focus();
}

function IncluirContaContabil(){
	

	var nrconta_contabil = $("#nrconta_contabil","#frmParametrizacao").val();
	var idexige_rateio_gerencial = $("#idexige_rateio_gerencial","#frmParametrizacao").val();
	var idexige_risco_operacional = $("#idexige_risco_operacional","#frmParametrizacao").val();
	var cdhistor = $("#cdhistor","#frmParametrizacao").val();



	if (   nrconta_contabil != "" 
		&& cdhistor != "" 
		&& idexige_rateio_gerencial != ""
		&& idexige_risco_operacional != ""){

		validarContaContabil(nrconta_contabil);		
				
	}

}

function limparCamposParam(){

	$("#nrconta_contabil","#frmParametrizacao").val('');
	$("#cdhistor","#frmParametrizacao").val('');
	$("#idexige_rateio_gerencial","#frmParametrizacao").val('S');
	$("#idexige_risco_operacional","#frmParametrizacao").val('S');

	$("#nrconta_contabil","#frmConParametrizacao").val('');
	$("#cdhistor","#frmConParametrizacao").val('');

}

function validaInclusaoContaContabil(){
	
	var nrconta_contabil = $("#nrconta_contabil","#frmParametrizacao").val();
	var flgconta = true;

	if (nrconta_contabil != ""){

		$('#tbParametrizacao > tbody > tr').each(function(){
			
			if ($("td:eq(0)", $(this)).html() == nrconta_contabil){
				flgconta = false;
				showError('alert','Conta contabil ja foi incluida.','Alerta - Aimaro','focarInputCtaContabil();');

			}
			
		});

		if (flgconta){
			IncluirContaContabil();
		}
	
	}
	

}

function focarCampoGerencial(){
	$("#cdgerencial","#frmGerencial").focus();
	
}

function focarCdhistor(){
	$("#cdhistor","#frmIncLancamento").focus();
}

function validaInclusaoGerencial(){
	

	var cdgerencial = $("#cdgerencial","#frmGerencial").val();
	var flgconta = true;

	if (cdgerencial != ""){

		$('#tbGerencial > tbody > tr').each(function(){
			
			if ($("td:eq(1)", $(this)).html() == cdgerencial){
				flgconta = false;
				showError('alert','Gerencial ja Incluido.','Alerta - Aimaro','focarCampoGerencial();');

			}
			
		});

		if (flgconta){
			criarLinhaGerencial();
		}
	
	}
	
}


function validaInclusaoGerencialRat(){
	

	var cdgerencial = $("#cdgerencialRat","#frmIncLancamento").val();
	var flgconta = true;		
	var vllanmto = $("#vllanmtoRat","#frmIncLancamento").val();

	if (cdgerencial != ""){

		$('#tbGerencialRat > tbody > tr').each(function(){
			
			if ($("td:eq(0)", $(this)).html() == cdgerencial){
				flgconta = false;
				showError('alert','Gerencial ja Incluido.','Alerta - Aimaro','focarRatGer();');

			}
			
		});
				
		if (flgconta){
			reqValidaGerencial('L',cdgerencial);
			
		}
	
	}
	
}


function validaInclusaoRisco(){
	

	var cdrisco_operacional = $("#cdrisco_operacional","#frmRisco").val();
	var dsrisco_operacional = $("#dsrisco_operacional","#frmRisco").val();
	var flgconta = true;

	if (cdrisco_operacional != "" && dsrisco_operacional != ""){

		$('#tbRisco > tbody > tr').each(function(){
			
			if ($("td:eq(0)", $(this)).html() == cdrisco_operacional){
				flgconta = false;
				showError('alert','Risco Operacional ja Incluido.','Alerta - Aimaro','focarCodRisco();');

			}
			
		});

		if (flgconta){
			criarLinhaRisco(cdrisco_operacional,dsrisco_operacional);	
			$("#cdrisco_operacional").val('');
		    $("#dsrisco_operacional").val('');	
		    focarCodRisco();		
		}
	
	}
	
}


function validaInclusaoRiscoRat(){
	

	var cdrisco_operacionalRat = $("#cdrisco_operacionalRat","#frmIncLancamento").val();	
	var nrctadeb = $("#nrctadeb","#frmIncLancamento").val();	
	var nrctacrd = $("#nrctacrd","#frmIncLancamento").val();	

	var flgconta = true;


	if (cdrisco_operacionalRat != ""){

		$('#tbRiscoRat > tbody > tr').each(function(){
			
			if ($("td:eq(0)", $(this)).html() == cdrisco_operacionalRat){
				flgconta = false;
				formatarTabelaRiscoRat();
				showError('alert','Risco Operacional ja Incluido.','Alerta - Aimaro','focarRatRisco();');

			}else{
				formatarTabelaRiscoRat();
				showError('alert','Apenas um risco operacional pode ser incluido.','Alerta - Aimaro','focarRatRisco();');
			}
			
			

			
		});

		if (flgconta){			
			reqValidaRisco('L',cdrisco_operacionalRat,nrctadeb,nrctacrd);
		}
	
	}
	
}

function reqValidaRisco(tipvalida,cddrisco,nrctadeb,nrctacrd){
	
	
	//Requisição para validar risco operacional

	
	var mensagem = 'validando Risco operacional...';
	


	showMsgAguardo(mensagem);	

	$.ajax({
        type: "POST",
        url: UrlSite + "telas/slip/valida_risco.php",
        data: {			
            tipvalida: tipvalida,			
			cddrisco: cddrisco,
			nrctadeb: nrctadeb,
			nrctacrd: nrctacrd,
			redirect:     "script_ajax"
		},
        error: function(objAjax,responseError,objExcept) {
        
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function(response) {
        	
           hideMsgAguardo();
			try {
				
				eval(response);
			} catch (error) {
					
					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
			}

	
		}
    });

    
    return false;


}

function reqValidaGerencial(tipvalida,cdgerencial){
	
	
	//Requisição para validar risco operacional

	
	var mensagem = 'validando Risco operacional...';
	
	showMsgAguardo(mensagem);	

	$.ajax({
        type: "POST",
        url: UrlSite + "telas/slip/valida_gerencial.php",
        data: {
            cdgerencial: cdgerencial,
			tipvalida: tipvalida,						
			redirect:     "script_ajax"
		},
        error: function(objAjax,responseError,objExcept) {
        
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function(response) {
        	
           hideMsgAguardo();
			try {
				
				eval(response);
			} catch (error) {
					
					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
			}

	
		}
    });

    
    return false;


}


function validaInclusaoHistorico(){
	

	var cdhistor = $("#cdhistor","#frmHistoricos").val();
	var nrctacrd = $("#nrctacrd","#frmHistoricos").val();
	var nrctadeb = $("#nrctadeb","#frmHistoricos").val();

	var flgconta = true;

	if (cdhistor != ""){

		$('#tbHistoricos > tbody > tr').each(function(){
			
			if ($("td:eq(0)", $(this)).html() == cdhistor){
				flgconta = false;
				showError('alert','Historico ja Incluido.','Alerta - Aimaro','focarCodHistorico();');

			}
			
		});

		if (flgconta){
			criarLinhaHistorico(cdhistor,nrctadeb,nrctacrd);	
			$("#cdhistor","#frmHistoricos").val('');
		    $("#nrctacrd","#frmHistoricos").val('');	
		    $("#nrctadeb","#frmHistoricos").val('');	
		    focarCodHistorico();		
		}
	
	}
	

}


function focarCodRisco(){
	$("#cdrisco_operacional","#frmRisco").focus();	

}


function focarCodHistorico(){
	$("#cdhistor","#frmHistoricos").focus();
}

function criarLinhaParametro(flagOK){

	if (flagOK == "OK"){
		var nrconta_contabil = $("#nrconta_contabil","#frmParametrizacao").val();
	    var idexige_rateio_gerencial = $("#idexige_rateio_gerencial","#frmParametrizacao").val();
	    var idexige_risco_operacional = $("#idexige_risco_operacional","#frmParametrizacao").val();
	    var cdhistor = $("#cdhistor","#frmParametrizacao").val();
		
		criarLinhaConParam(nrconta_contabil,cdhistor,idexige_rateio_gerencial,idexige_risco_operacional);
		formatarTabelaParam();
		limparCamposParam();
		focarInputCtaContabil();
		
	}
}


function validarContaContabil(nrconta_contabil){

	//Requisição para validar conta contabil

	var mensagem = 'validando conta contabil...';
	
	showMsgAguardo(mensagem);	

	$.ajax({
        type: "POST",
        url: UrlSite + "telas/slip/valida_conta_contabil.php",
        data: {			
            nrconta_contabil: nrconta_contabil,			
			redirect:     "script_ajax"
		},
        error: function(objAjax,responseError,objExcept) {
        
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function(response) {
        	
           hideMsgAguardo();
			try {
				
				eval(response);
			} catch (error) {
					
					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
			}

	
		}
    });

    
    return false;

}

function controlaConcluir(){
	
			
	switch($("#cddotipo","#frmCab").val()){
		
		case "P":			
			
			if (flagaca == 'I'){
				showConfirmacao('Confirma a inclus&atilde;o  do Parametro?','Confirma&ccedil;&atilde;o - Aimaro','controlaSelParam();','','sim.gif','nao.gif');		
			}

			else if (flagaca == 'A'){
				showConfirmacao('Confirma a Alteracao do Parametro?','Confirma&ccedil;&atilde;o - Aimaro','controlaSelParam();','','sim.gif','nao.gif');		
			}

			else if (flagaca == 'E'){
				showConfirmacao('Confirma a Exclusao do Parametro?',
					            'Confirma&ccedil;&atilde;o - Aimaro','controlaSelParam();','','sim.gif','nao.gif');		
			}	else{					
			
				showConfirmacao('Confirma a inclus&atilde;o/Alteracoes do(s) Historicos?','Confirma&ccedil;&atilde;o - Aimaro','controlaSelParam();','','sim.gif','nao.gif');
			}
		break;

		case "I":

			if (flagaca == 'I'){
				showConfirmacao('Confirma a inclus&atilde;o  do lancamento?','Confirma&ccedil;&atilde;o - Aimaro','cofirmaInclusaoLanc();','','sim.gif','nao.gif');		
			}

			if (flagaca == 'A'){
				showConfirmacao('Confirma a Alteracao do Lancamento?','Confirma&ccedil;&atilde;o - Aimaro','cofirmaAlteracaoLanc();','','sim.gif','nao.gif');		
			}

			if (flagaca == 'E'){
				showConfirmacao('Confirma a Exclusao do lancamento?',
					            'Confirma&ccedil;&atilde;o - Aimaro','cofirmaEsclusaoLanc();','','sim.gif','nao.gif');		
			}				

		break;
					
	}

}

function cofirmaEsclusaoLanc(){

}

function cofirmaAlteracaoLanc(){

	//Requisição para validar conta contabil	
	var cdhistor = $("#cdhistor","#frmIncLancamento").val();
	var nrctadeb = $("#nrctadeb","#frmIncLancamento").val();
	var nrctacrd = $("#nrctacrd","#frmIncLancamento").val();
	var vllanmto = $("#vllanmto","#frmIncLancamento").val();
	var cdhistor_padrao = $("#cdhistor_padrao","#frmIncLancamento").val();
	var dslancamento = $("#dslancamento","#frmIncLancamento").val();	
	
	
	
    if (cdhistor != "" &&
		nrctadeb != "" &&
		nrctacrd != "" &&
		vllanmto != "" &&
		cdhistor_padrao != "" &&
		dslancamento != "" &&
		tab_seqslip != ""){

	controlaAlteracaoLanc
		lscdgerencial = retLscdgerencial();
		lsvllanmto = retLsvllanmto();
		lscdrisco_operacional = retLscdrisco_operacional();
	
		var mensagem = 'Incluindo Lancamento...';
		
		showMsgAguardo(mensagem);	

		$.ajax({
			type: "POST",
			url: UrlSite + "telas/slip/altera_lancamento.php",
			data: {
				cdhistor: cdhistor,			
				nrctadeb: nrctadeb,
				nrctacrd: nrctacrd,
				vllanmto: vllanmto,
				nrseqlan: tab_seqslip,
				cdhistor_padrao: cdhistor_padrao,
				dslancamento: dslancamento,   
				lscdgerencial: lscdgerencial,
				lsvllanmto: lsvllanmto, // lanc cada gerencial
				lscdrisco_operacional: lscdrisco_operacional,                   
				redirect:     "script_ajax"
			},
			error: function(objAjax,responseError,objExcept) {
			
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')) )");
			},
			success: function(response) {
				
			hideMsgAguardo();
				try {					
					eval(response);
				} catch (error) {
						
						hideMsgAguardo();
						showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
				}

		
			}
		});

		
		return false;

		//req aqui
		// no sucess flagaca = ''
	}

}


function retLscdgerencial(){
	var ret = '';

	$('#tbGerencialRat > tbody > tr').each(function(){	
		
		if (ret == ''){
			ret = $("td:eq(0)", $(this)).html();
		}else{
				ret = ret + ';' + $("td:eq(0)", $(this)).html();
		}
	
	});

	return ret;
}

function retLsvllanmto(){
	
	var ret = '';

	$('#tbGerencialRat > tbody > tr').each(function(){	
		
		if (ret == ''){
			ret = $("td:eq(1)", $(this)).html();
		}else{
				ret = ret + ';' + $("td:eq(1)", $(this)).html();
		}		
	
	});

	return ret;

}

function retLscdrisco_operacional(){
	
	var ret = '';

	$('#tbRiscoRat > tbody > tr').each(function(){	
		
		if (ret == ''){
			ret = $("td:eq(0)", $(this)).html();
		}else{
				ret = ret + ';' + $("td:eq(0)", $(this)).html();
		}
	
	});

	return ret;

}

function cofirmaInclusaoLanc(){


	//Requisição para validar conta contabil	
	var cdhistor = $("#cdhistor","#frmIncLancamento").val();
	var nrctadeb = $("#nrctadeb","#frmIncLancamento").val();
	var nrctacrd = $("#nrctacrd","#frmIncLancamento").val();
	var vllanmto = $("#vllanmto","#frmIncLancamento").val();
	var cdhistor_padrao = $("#cdhistor_padrao","#frmIncLancamento").val();
	var dslancamento = $("#dslancamento","#frmIncLancamento").val();	
	
	
	
    if (
		nrctadeb != "" &&
		nrctacrd != "" &&
		vllanmto != "" &&
		cdhistor_padrao != "" &&
		dslancamento != ""){

	
		lscdgerencial = retLscdgerencial();
		lsvllanmto = retLsvllanmto();
		lscdrisco_operacional = retLscdrisco_operacional();
	
		var mensagem = 'Incluindo Lancamento...';
		
		showMsgAguardo(mensagem);	

		$.ajax({
			type: "POST",
			url: UrlSite + "telas/slip/insere_lancamento.php",
			data: {
				cdhistor: cdhistor,			
				nrctadeb: nrctadeb,
				nrctacrd: nrctacrd,
				vllanmto: vllanmto,
				cdhistor_padrao: cdhistor_padrao,
				dslancamento: dslancamento,   
				lscdgerencial: lscdgerencial,
				lsvllanmto: lsvllanmto, // lanc cada gerencial
				lscdrisco_operacional: lscdrisco_operacional,                   
				redirect:     "script_ajax"
			},
			error: function(objAjax,responseError,objExcept) {
			
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')) )");
			},
			success: function(response) {
				
			hideMsgAguardo();
				try {					
					eval(response);
				} catch (error) {
						
						hideMsgAguardo();
						showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
				}

		
			}
		});

		
		return false;

		//req aqui
		// no sucess flagaca = ''
	}
}

function controlaSelParam(){
			
	
	switch($("#tpparam","#frmSelParam").val()){

		case "PR": // Parametrização Risco
			//Quando for Parametrização, solicita confirmação
			confirmouOperacaoRisco()
		break;

		case "PG": // Parametrização Gerencial
			confirmouOperacaoGerencia();			
		break;

		case "PH": //Parametrização Historico
			confirmouOperacaoHistorico();			
		break;

		case "PC": //Parametrização Conta contabil ...
			confirmouOperacaoParametro();
		break;
					
	}

}

//alterar
function confirmouOperacaoContaContabil(){

	var cdcooper = $("#nmrescop").val();
	var ls = "";
	var lscdgerencial = "";
	

	$('#tbGerencial > tbody > tr').each(function(){
		
		var idativo = 'N';
			
		if (document.getElementById("ck".concat($("td:eq(1)", $(this)).html())).checked) {
			idativo = 'S';
		}

		if (lsidativo == ""){
						
			lsidativo = idativo + ';';
		}else{
			lsidativo = lsidativo + idativo + ';';
		}

		if (lscdgerencial == ""){
			lscdgerencial = $("td:eq(1)", $(this)).html() + ';';
		}else{
			lscdgerencial = lscdgerencial + $("td:eq(1)", $(this)).html() + ';';
		}
		
	});


	if (lsidativo != "" && lscdgerencial != "" && cdcooper != ""){
		// solicitar requisição 
	    reqInsereGerencial(lsidativo,lscdgerencial,cdcooper);
	}

}

function confirmouOperacaoRisco(){

	
	var cdrisco_operacional = $('#cdrisco_operacional','#frmRisco').val();
	var dsrisco_operacional = $('#dsrisco_operacional','#frmRisco').val();
	var lsnrconta_contabil = "";
	

	$('#tbIncRisco > tbody > tr').each(function(){
				
		if (lsnrconta_contabil == ""){
						
			lsnrconta_contabil =  $("td:eq(0)", $(this)).html() + ';';
		}else{
			lsnrconta_contabil = lsnrconta_contabil +  $("td:eq(0)", $(this)).html()  + ';';
		}

		
	});


	if (cdrisco_operacional != "" &&
	    dsrisco_operacional != ""){
		// solicitar requisição 
		reqInsereRisco(flagaca,cdrisco_operacional,dsrisco_operacional,lsnrconta_contabil);
	}
	
	

}


function confirmouOperacaoGerencia(){

	var cdcooper = $("#nmrescop").val();
	var lsidativo = "";
	var lscdgerencial = "";
	

	$('#tbGerencial > tbody > tr').each(function(){
		
		var idativo = 'N';
			
		if (document.getElementById("ck".concat($("td:eq(1)", $(this)).html())).checked) {
			idativo = 'S';
		}

		if (lsidativo == ""){
						
			lsidativo = idativo + ';';
		}else{
			lsidativo = lsidativo + idativo + ';';
		}

		if (lscdgerencial == ""){
			lscdgerencial = $("td:eq(1)", $(this)).html() + ';';
		}else{
			lscdgerencial = lscdgerencial + $("td:eq(1)", $(this)).html() + ';';
		}
		
	});


	if (lsidativo != "" && lscdgerencial != "" && cdcooper != ""){
		// solicitar requisição 
	    reqInsereGerencial(lsidativo,lscdgerencial,cdcooper);
	}

}

function confirmouOperacaoHistorico(){

	
	var lscdhistor = "";
	var lsnrctadeb = "";
	var lsnrctacrd = "";

	$('#tbHistoricos > tbody > tr').each(function(){
		
		
		if (lscdhistor == ""){					
			lscdhistor = $("td:eq(0)", $(this)).html() + ';';
		}else{
			lscdhistor = lscdhistor + $("td:eq(0)", $(this)).html() + ';';
		}

		if (lsnrctadeb == ""){
			lsnrctadeb = $("td:eq(1)", $(this)).html() + ';';
		}else{
			lsnrctadeb = lsnrctadeb + $("td:eq(1)", $(this)).html() + ';';
		}
		
		if (lsnrctacrd == ""){
			lsnrctacrd = $("td:eq(2)", $(this)).html() + ';';
		}else{
			lsnrctacrd = lsnrctacrd + $("td:eq(2)", $(this)).html() + ';';
		}


	});


	if (lscdhistor != "" ){
		// solicitar requisição 
	    reqInsereHistorico(lscdhistor,lsnrctadeb,lsnrctacrd);
	}


}

function reqInsereHistorico(lscdhistor,lsnrctadeb,lsnrctacrd){
	
	var mensagem = 'Atualizando Historicos...';
	
	showMsgAguardo(mensagem);
	
	//Requisição para inserir historico
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/slip/insere_historicos.php",
        data: {
            lscdhistor: lscdhistor,		
            lsnrctadeb: lsnrctadeb,
            lsnrctacrd: lsnrctacrd,            
			redirect:     "script_ajax"
		},
        error: function(objAjax,responseError,objExcept) {
        
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function(response) {
        	
           hideMsgAguardo();
			try {			
				eval(response);
			} catch (error) {
					
					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
			}

	
		}
    });
    
    return false;

}


function reqBuscaRisco(tipbusca){
 	
 	var mensagem = 'Buscando Riscos Operacionais...';
	   
	showMsgAguardo(mensagem);	



	//Requisição para buscar gerencial
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/slip/busca_risco.php",
        data: {   			
			nrseqlan: tab_seqslip,	
			tipbusca: tipbusca,		                         
			redirect:     "script_ajax"
		},
        error: function(objAjax,responseError,objExcept) {
        
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function(response) {
        	
           hideMsgAguardo();
			try {			
				eval(response);
			} catch (error) {
					
					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
			}

	
		}
    });
    
    return false;


}

function reqBuscaHistoricos(){
 	
 	var mensagem = 'Buscando Hisotricos...';
	   
	showMsgAguardo(mensagem);
	
	
	//Requisição para buscar historicos
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/slip/busca_historicos.php",
        data: {                             
			redirect:     "script_ajax"
		},
        error: function(objAjax,responseError,objExcept) {
        
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function(response) {
        	
           hideMsgAguardo();
			try {			
				eval(response);
			} catch (error) {
					
					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
			}

	
		}
    });
    
    return false;


}



function reqBuscaGerencial(tipbusca){
 	
 	var mensagem = 'Buscando Gerenciais...';
	var cdcooper = $('#nmrescop','#frmGerencial').val();
   
	showMsgAguardo(mensagem);

	

	//Requisição para buscar gerencial
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/slip/busca_gerenciais.php",
        data: {       
            cdcooper: cdcooper,  
			nrseqlan: tab_seqslip,
			tipbusca: tipbusca,          
			redirect:     "script_ajax"
		},
        error: function(objAjax,responseError,objExcept) {
        
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function(response) {
        	
           hideMsgAguardo();
			try {			
				eval(response);
			} catch (error) {
					
					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
			}

	
		}
    });
    
    return false;


}

function reqExcluiLancamento(){
 	
 	var mensagem = 'Excluido Lancamento...';

   
	showMsgAguardo(mensagem);
			

	//Requisição para buscar gerencial
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/slip/exclui_lancamento.php",
        data: {                   
			nrseqlan: tab_seqslip,			         
			redirect:     "script_ajax"
		},
        error: function(objAjax,responseError,objExcept) {
        
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function(response) {
        	
           hideMsgAguardo();
			try {			
				eval(response);
			} catch (error) {
					
					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
			}

	
		}
    });
    
    return false;


}



function reqInsereGerencial(lsidativo,lscdgerencial,cdcooper){
 	
 	var mensagem = 'Atualizando Gerenciais...';
	
	showMsgAguardo(mensagem);
	
	//Requisição para inserir gerencial
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/slip/insere_gerenciais.php",
        data: {
            lsidativo: lsidativo,		
            lscdgerencial: lscdgerencial,
            cdcooper: cdcooper,            
			redirect:     "script_ajax"
		},
        error: function(objAjax,responseError,objExcept) {
        
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function(response) {
        	
           hideMsgAguardo();
			try {			
				eval(response);
			} catch (error) {
					
					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
			}

	
		}
    });
    
    return false;

}

function reqInsereRisco(flagaca,cdrisco_operacional,dsrisco_operacional,lsnrconta_contabil){
 	
 	var mensagem = 'Atualizando Riscos...';
	
	showMsgAguardo(mensagem);
	
	if (flagaca == "I"){

		//Requisição para inserir risco
		$.ajax({
			type: "POST",
			url: UrlSite + "telas/slip/insere_risco.php",
			data: {
				cdrisco_operacional: cdrisco_operacional,		
				dsrisco_operacional: dsrisco_operacional,     
				lsnrconta_contabil: lsnrconta_contabil,              
				redirect:     "script_ajax"
			},
			error: function(objAjax,responseError,objExcept) {
			
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')) )");
			},
			success: function(response) {
				
			hideMsgAguardo();
				try {			
					eval(response);
				} catch (error) {
						
						hideMsgAguardo();
						showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
				}

		
			}
		});
	}

	if (flagaca == "A"){

		//Requisição para alterar risco
		$.ajax({
			type: "POST",
			url: UrlSite + "telas/slip/altera_risco.php",
			data: {
				cdrisco_operacional: cdrisco_operacional,		
				dsrisco_operacional: dsrisco_operacional,     
				lsnrconta_contabil: lsnrconta_contabil,                   
				redirect:     "script_ajax"
			},
			error: function(objAjax,responseError,objExcept) {
			
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')) )");
			},
			success: function(response) {
				
			hideMsgAguardo();
				try {			
					eval(response);
				} catch (error) {
						
						hideMsgAguardo();
						showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
				}

		
			}
		});
	}

	
    
    return false;

}



function confirmouOperacaoParametro(){

	var lsnrconta_contabil = "";
	var lsid_rateio_gerencial = "";
	var lsid_risco_operacional = "";
	var lscdhistor = "";

	$('#tbParametrizacao > tbody > tr').each(function(){
		
		if (lsnrconta_contabil == ""){
			lsnrconta_contabil = $("td:eq(0)", $(this)).html() + ';';
		}else{
			lsnrconta_contabil = lsnrconta_contabil + $("td:eq(0)", $(this)).html() + ';';
		}

		if (lscdhistor == ""){
			lscdhistor = $("td:eq(1)", $(this)).html() + ';';
		}else{
			lscdhistor = lscdhistor + $("td:eq(1)", $(this)).html() + ';';
		}

		if (lsid_rateio_gerencial == ""){
			lsid_rateio_gerencial = $("td:eq(2)", $(this)).html() + ';';
		}else{
			lsid_rateio_gerencial = lsid_rateio_gerencial + $("td:eq(2)", $(this)).html() + ';';
		}

		if (lsid_risco_operacional == ""){
			lsid_risco_operacional = $("td:eq(3)", $(this)).html() + ';';
		}else{
			lsid_risco_operacional = lsid_risco_operacional + $("td:eq(3)", $(this)).html() + ';';
		}	

	});


	if (lsnrconta_contabil != ""
		&& lsid_rateio_gerencial != ""
		&& lsid_risco_operacional != ""
		&& lscdhistor != ""){
		// solicitar requisição 
	    reqInsereParam(lsnrconta_contabil,lscdhistor,lsid_rateio_gerencial,lsid_risco_operacional);	
	}

		
}

function reqInsereParam(lsnrconta_contabil,lscdhistor,lsid_rateio_gerencial,lsid_risco_operacional){
    
    var mensagem = 'Inserindo Parametros...';
	
	showMsgAguardo(mensagem);
	
	//Requisição para validar conta contabil
	$.ajax({
        type: "POST",
        url: UrlSite + "telas/slip/insere_parametrizacao.php",
        data: {
            lsnrconta_contabil: lsnrconta_contabil,		
            lscdhistor: lscdhistor,
            lsid_rateio_gerencial: lsid_rateio_gerencial,
            lsid_risco_operacional: lsid_risco_operacional,	
			redirect:     "script_ajax"
		},
        error: function(objAjax,responseError,objExcept) {
        
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function(response) {
        	
           hideMsgAguardo();
			try {
				
				eval(response);
			} catch (error) {
					
					hideMsgAguardo();
					showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Aimaro", "blockBackground(parseInt($('#divUsoGenerico').css('z-index')))");
			}

	
		}
    });
    
    return false;

}




function concluirParam(){
	showError('inform','Parametros inseridos com sucesso!','Alerta - Aimaro','estadoInicial();');
}

function concluirGerencial(){
	showError('inform','Gerenciais Atuaizados com sucesso!','Alerta - Aimaro','estadoInicial();');
}

function concluirHistorico(){
	showError('inform','Historicos Atuaizados com sucesso!','Alerta - Aimaro','estadoInicial();');
}

function concluirRisco(){
	showConfirmacao('Riscos Operacionais Atuaizados com sucesso. Deseja Incluir novo parametro?','Confirma&ccedil;&atilde;o - Aimaro','controlaInclusaoRisco();','estadoInicial();','sim.gif','nao.gif');	
	//showError('inform','Riscos Operacionais Atuaizados com sucesso!','Alerta - Aimaro','estadoInicial();');
}

function concluirBuscaHistorico(cdhistor){
 
   if (cdhistor != 0){
	 showError('inform','Historico nao parametrizado','Alerta - Aimaro','focarCdhistor();');
   }
	

}

function concluirLancamento(){
	flagaca = '';
	showError('inform','Lancamento inlcuido com sucesso','Alerta - Aimaro','estadoiniciaInclusao();');
}

function concluirLancamentoAlteracao(){
	flagaca = '';
	showError('inform','Lancamento Alterado com sucesso','Alerta - Aimaro','estadoiniciaInclusao();');
}

function concluirLancamentoExclusao(){
	flagaca = '';
	showError('inform','Lancamento Excluido com sucesso','Alerta - Aimaro','estadoiniciaInclusao();');
}

function concluirValidacaoRisco(tipvalida){
	
	if (tipvalida == "L"){
		var cddrisco = $('#cdrisco_operacionalRat','#frmIncLancamento').val();		
		criarLinhaRiscoRat(cddrisco);
		formatarTabelaRiscoRat();	
		limparCamposRateio();		    
		focarRatRisco();
	}

}


function concluirValidacaoGerencial(tipvalida){
	
	if (tipvalida == "L"){
		var cdgerencial = $('#cdgerencialRat','#frmIncLancamento').val();
		var vllanmto = $('#vllanmtoRat','#frmIncLancamento').val();
		criarLinhaGerencialRat(cdgerencial,vllanmto);	
		formatarTabelaGerencialRat();
		limparCamposRateio();		    
		focarRatGer();
	}
	
}



				
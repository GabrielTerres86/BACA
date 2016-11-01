/*********************************************************************************************
 Fonte: cldsed.js                                                Última alteração: 05/08/2016
 Autor: Cristian Filipe                                                            
 Data : Novembro/2013  										                       
 
 Alterações: 25/04/2016 - Corrigir passagem do parâmetro cddopcao conforme solicitado no
 						  chamado 430180. (Kelvin) 

         	 06/06/2016 - Limitando a quantidade de caracteres nos campos e desabilitando a lov 
 			              caso não tenha dado dois clicks, conforme solicitado no chamado 461240 
 						  (Kelvin)

             05/08/2016 - Ajuste para gerar o arquivo para impressão de forma correta
					     (Adriano - SD 495725).
             
*********************************************************************************************/

// variavel para a função de seleção de registros da tabela das Opções C e J
 var verificaEntrou = false;
 
// Definição de algumas variáveis globais 
var cddopcao		= 'C';
	
//Formulários
var frmCab   		= 'frmCab';

//Labels/Campos do cabeçalho
var rCddopcao, cCddopcao, cTodosCabecalho;

/*Variaveis Opção C e J*/
/* o CJ ao final da variavel significa as opções a qual ela pertence*/
var cFlextjusCJ, cDtmvtoltCJ, cNmprimtlCJ, cInpessoaCJ, cCdoperadCJ, cOpeenvcfCJ, cCddjustiCJ, 
cDsdjustiCJ, cDsobservCJ, cInfrepcfCJ, cDsobsctrCJ, rFlextjusCJ, rDtmvtoltCJ, rNmprimtlCJ, rInpessoaCJ, 
rCdoperadCJ, rOpeenvcfCJ, rCddjustiCJ, rDsdjustiCJ, rDsobservCJ, rInfrepcfCJ, rDsobsctrCJ, cTodosFrmInfConsultaMovimentacao,
cNrdrowidCJ; // Campo hidden para a procedure Justifica_movimento - Opção J
/*Variaveis Opção C e J*/

/*Variaveis Opção F e X*/
var rFlextjusFX, cDtmvtoltFX, rDtmvtoltFX, cTodosFrmInfFechamento;
/*Variaveis Opção F e X*/

/*Variaveis Opção P*/
var cNrdcontaP, cDtrefiniP, cDtreffimP, cCdstatusP, cCdincoafP, cSaidaP, cDsdjustiP, cInfrepcfP, cDsstatusP,
	rNrdcontaP, rDtrefiniP, rDtreffimP, rCdstatusP, rCdincoafP, rSaidaP, rDsdjustiP, rInfrepcfP, rDsstatusP,
	cTodosFrmInfConsultaDetalheMov;
/*Variaveis Opção P*/
	
/*Variaveis Opção T*/	
var rDtrefiniT, rDtreffimT, rSaidaT, rTpvinculT, rInfrepcfT, rDsstatusT, rCddjustiT, rDsobservT, rDsobsctrT,
	cDtrefiniT, cDtreffimT, cSaidaT, cTpvinculT, cInfrepcfT, cDsstatusT, cCddjustiT, cDsobservT, cDsobsctrT, cTodosFrmInfListaMovimentacoes;
/*Variaveis Opção T*/	
	


$(document).ready(function(){
	
    estadoInicial();
	
	highlightObjFocus( $('#'+frmCab) );
	
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	
	return false;
});

function estadoInicial() {   

	$('#divTela').fadeTo(0,0.1);
	$('#frmCab').css({'display':'block'});
		
	$('#divBotoes').css({'display':'none'});
	$("#btSalvar","#divBotoes").show();
	$("#btVoltar","#divBotoes").show();

	formataCabecalho();
	
	// Remover class campoErro
	$('input,select', '#frmCab').removeClass('campoErro');
	$('input,select', '#frmInfConsultaMovimentacao').removeClass('campoErro');
	$('input,select', '#frmInfFechamento').removeClass('campoErro');
	$('input,select', '#frmInfConsultaDetalheMov').removeClass('campoErro');
	$('input,select', '#frmInfListaMovimentacoes').removeClass('campoErro');
	
	cTodosCabecalho.limpaFormulario();
	if(cddopcao == 'P'){
		$('#cdstatus','#frmInfConsultaDetalheMov').val(1);
		$('#cdincoaf','#frmInfConsultaDetalheMov').val(1);
		$('#saida','#frmInfConsultaDetalheMov').val('T');
	}
	cCddopcao.val( cddopcao );
	
	removeOpacidade('divTela');	
	unblockBackground();
	hideMsgAguardo();
	
	cTodosCabecalho.desabilitaCampo();
	
	$('#cddopcao','#frmCab').habilitaCampo().focus();
	//$('#cddopcao','#frmCab').focus();
	
	$('#frmInfConsultaMovimentacao').css({'display': 'none'});
	$('#fieldMovimentacao', '#frmInfConsultaMovimentacao').css({'display': 'none'});
	$('#divTabMovimentacao', '#fieldMovimentacao3', '#frmInfConsultaMovimentacao').html("");
	$('input[type="text"],selectinput[type="checkbox"]','#frmInfConsultaMovimentacao').limpaFormulario();
	$('#frmInfFechamento').css({'display': 'none'});
	$('input[type="text"],selectinput[type="checkbox"]','#frmInfFechamento').limpaFormulario();
	$('#frmInfConsultaDetalheMov').css({'display': 'none'});
	$('#fieldMovimentacao2', '#frmInfConsultaDetalheMov').css({'display': 'none'});
	$('#divTabMovimentacao2', '#fieldMovimentacao3', '#frmInfConsultaDetalheMov').html("");
	$('input[type="text"],selectinput[type="checkbox"]','#frmInfConsultaDetalheMov').limpaFormulario();
	$('#frmInfListaMovimentacoes').css({'display': 'none'});
	$('#fieldMovimentacao3', '#frmInfListaMovimentacoes').css({'display': 'none'});
	$('#divTabMovimentacao3', '#fieldMovimentacao3', '#frmInfListaMovimentacoes').html("");
	$('input[type="text"],selectinput[type="checkbox"]','#frmInfListaMovimentacoes').limpaFormulario();

	controlaFoco();
}

function formataCabecalho() {

	// Cabecalho
	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab); 
	
	cCddopcao			= $('#cddopcao','#'+frmCab); 
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	btnCab				= $('#btOK','#'+frmCab);
	
	rCddopcao.css('width','44px');
	
	cCddopcao.css({'width':'460px'});
	
	cTodosCabecalho.habilitaCampo();
	
	$('#cddopcao','#'+frmCab).focus();
				
	layoutPadrao();
	return false;	
}

function controlaFoco() {

	$('#cddopcao','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			LiberaFormulario();
			return false;
		}	
	});
	
	$('#btnOK','#frmCab').unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			LiberaFormulario();
			return false;
		}	
	});
}

function formataFrmInfConsultaMovimentacao() {
	rFlextjusCJ = $('label[for="flextjus"]', '#frmInfConsultaMovimentacao');
	rDtmvtoltCJ = $('label[for="dtmvtolt"]', '#frmInfConsultaMovimentacao');
	rNmprimtlCJ = $('label[for="nmprimtl"]', '#frmInfConsultaMovimentacao');
	rInpessoaCJ = $('label[for="inpessoa"]', '#frmInfConsultaMovimentacao');
	rCdoperadCJ = $('label[for="cdoperad"]', '#frmInfConsultaMovimentacao');
	rOpeenvcfCJ = $('label[for="opeenvcf"]', '#frmInfConsultaMovimentacao');
	rCddjustiCJ = $('label[for="cddjusti"]', '#frmInfConsultaMovimentacao');
	rDsdjustiCJ = $('label[for="dsdjusti"]', '#frmInfConsultaMovimentacao');
	rDsobservCJ = $('label[for="dsobserv"]', '#frmInfConsultaMovimentacao');
	rInfrepcfCJ = $('label[for="infrepcf"]', '#frmInfConsultaMovimentacao');
	rDsobsctrCJ = $('label[for="dsobsctr"]', '#frmInfConsultaMovimentacao');

	$('label[for="operacao"]', '#frmInfConsultaMovimentacao' ).css({width:'110px'});
	rFlextjusCJ.css({width:'160px'});
	rDtmvtoltCJ.css({width:'100px'});	
	
	rNmprimtlCJ.css({width:'85px'});	
	rInpessoaCJ.css({width:'85px'});	
	rCdoperadCJ.css({width:'67.5px'});
	rOpeenvcfCJ.css({width:'70px'});
	rCddjustiCJ.css({width:'85px'});
	
	rDsobservCJ.css({width:'85px'});
	rInfrepcfCJ.css({width:'85px'});
	rDsobsctrCJ.css({width:'85px'});
	
	cFlextjusCJ = $('#flextjus', '#frmInfConsultaMovimentacao');
	cDtmvtoltCJ = $('#dtmvtolt', '#frmInfConsultaMovimentacao');
	cNmprimtlCJ = $('#nmprimtl', '#frmInfConsultaMovimentacao');
	cInpessoaCJ = $('#inpessoa', '#frmInfConsultaMovimentacao');
	cCdoperadCJ = $('#cdoperad', '#frmInfConsultaMovimentacao');
	cOpeenvcfCJ = $('#opeenvcf', '#frmInfConsultaMovimentacao');
	cCddjustiCJ = $('#cddjusti', '#frmInfConsultaMovimentacao');
	cDsdjustiCJ = $('#dsdjusti', '#frmInfConsultaMovimentacao');
	cDsobservCJ = $('#dsobserv', '#frmInfConsultaMovimentacao');
	cInfrepcfCJ = $('#infrepcf', '#frmInfConsultaMovimentacao');
	cDsobsctrCJ = $('#dsobsctr', '#frmInfConsultaMovimentacao');
	
	cDtmvtoltCJ.css({width:'80px'}).addClass('data');
	cNmprimtlCJ.css({width:'464px'});
	cInpessoaCJ.css({width:'200px'});
	cCdoperadCJ.css({width:'60px'});
	cOpeenvcfCJ.css({width:'61px'});
	cCddjustiCJ.css({width:'45px'});
	cDsdjustiCJ.css({width:'396px'});
	cDsobservCJ.css({width:'464px'});
	cDsobsctrCJ.css({width:'464px'});
	
	/*Habilita os campos da consulta*/	
	cFlextjusCJ.habilitaCampo();
	cDtmvtoltCJ.habilitaCampo();

	layoutPadrao();
	highlightObjFocus( $('#frmInfConsultaMovimentacao') );
}

function formataFrmFechamento() {
	$('label[for="operacao"]', '#frmInfFechamento').css({width:'120px'});
	
	rFlextjusFX = $('label[for="flextjus"]', '#frmInfFechamento');
	rDtmvtoltFX = $('label[for="dtmvtolt"]', '#frmInfFechamento');
	
	rFlextjusFX.css({width:'170px'});
	rDtmvtoltFX.css({width:'100px'});
	
	cDtmvtoltFX = $('#dtmvtolt', '#frmInfFechamento');
	cDtmvtoltFX.css({width:'80px'});
	layoutPadrao();	
	highlightObjFocus( $('#frmFechamento') );
}

function formataFrmInfConsultaDetalheMov() {
	rNrdcontaP   = $('label[for="nrdconta"]', '#frmInfConsultaDetalheMov');
	rDtrefiniP   = $('label[for="dtrefini"]', '#frmInfConsultaDetalheMov');
	rDtreffimP   = $('label[for="dtreffim"]', '#frmInfConsultaDetalheMov');
	rCdstatusP   = $('label[for="cdstatus"]', '#frmInfConsultaDetalheMov');
	rCdincoafP   = $('label[for="cdincoaf"]', '#frmInfConsultaDetalheMov');
	rSaidaP      = $('label[for="saida"]', '#frmInfConsultaDetalheMov');
	rDsdjustiP   = $('label[for="dsdjusti"]', '#frmInfConsultaDetalheMov');
	rInfrepcfP   = $('label[for="infrepcf"]', '#frmInfConsultaDetalheMov');
	rDsstatusP   = $('label[for="dsstatus"]', '#frmInfConsultaDetalheMov');

	rNrdcontaP.css({width:'85px'});
	rDtrefiniP.css({width:'87px'});
	rDtreffimP.css({width:'110px'}); 
	rCdstatusP.css({width:'85px'}); 
	rCdincoafP.css({width:'60px'}); 
	rSaidaP.css({width:'57px'});    
	rDsdjustiP.css({width:'85px'});
	rInfrepcfP.css({width:'85px'});
	rDsstatusP.css({width:'85px'});

	cNrdcontaP   = $('#nrdconta', '#frmInfConsultaDetalheMov');
	cDtrefiniP   = $('#dtrefini', '#frmInfConsultaDetalheMov');
	cDtreffimP   = $('#dtreffim', '#frmInfConsultaDetalheMov');
	cCdstatusP   = $('#cdstatus', '#frmInfConsultaDetalheMov');
	cCdincoafP   = $('#cdincoaf', '#frmInfConsultaDetalheMov');
	cSaidaP      = $('#saida', '#frmInfConsultaDetalheMov');
	cDsdjustiP   = $('#dsdjusti', '#frmInfConsultaDetalheMov');
	cInfrepcfP   = $('#infrepcf', '#frmInfConsultaDetalheMov');
	cDsstatusP   = $('#dsstatus', '#frmInfConsultaDetalheMov');
	
	cNrdcontaP.addClass('conta').css({width:'100px'});    
	cDtrefiniP.addClass('data').css({width:'80px'});
	cDtreffimP.addClass('data').css({width:'80px'});
	cCdstatusP.css({width:'110px'});
	cCdincoafP.css({width:'120px'});
	cSaidaP.css({width:'110px'});
	cDsdjustiP.css({width:'464px'});
	cInfrepcfP.css({width:'464px'});
	cDsstatusP.css({width:'464px'});	
	
	layoutPadrao();
	highlightObjFocus( $('#frmInfConsultaDetalheMov') );
}

function formataFrmInfListaMovimentacoes() {
	rDtrefiniT = $('label[for="dtrefini"]', '#frmInfListaMovimentacoes');
	rDtreffimT = $('label[for="dtreffim"]', '#frmInfListaMovimentacoes');
	rSaidaT    = $('label[for="saida"]', '#frmInfListaMovimentacoes');
	rTpvinculT = $('label[for="tpvincul"]', '#frmInfListaMovimentacoes');
	rInfrepcfT = $('label[for="infrepcf"]', '#frmInfListaMovimentacoes');
	rDsstatusT = $('label[for="dsstatus"]', '#frmInfListaMovimentacoes');
	rCddjustiT = $('label[for="cddjusti"]', '#frmInfListaMovimentacoes');
	rDsobservT = $('label[for="dsobserv"]', '#frmInfListaMovimentacoes');
	rDsobsctrT = $('label[for="dsobsctr"]', '#frmInfListaMovimentacoes');
	
	rDtrefiniT.css({width:'85px'});
	rDtreffimT.css({width:'94px'});
	rSaidaT.css({width:'100px'});
	rTpvinculT.css({width:'85px'});
	rInfrepcfT.css({width:'100px'});
	rDsstatusT.css({width:'107px'});
	rCddjustiT.css({width:'85px'});
	rDsobservT.css({width:'85px'});
	rDsobsctrT.css({width:'85px'});

	cDtrefiniT = $('#dtrefini', '#frmInfListaMovimentacoes');
	cDtreffimT = $('#dtreffim', '#frmInfListaMovimentacoes');
	cSaidaT    = $('#saida', '#frmInfListaMovimentacoes');
	cTpvinculT = $('#tpvincul', '#frmInfListaMovimentacoes');
	cInfrepcfT = $('#infrepcf', '#frmInfListaMovimentacoes');
	cDsstatusT = $('#dsstatus', '#frmInfListaMovimentacoes');
	cCddjustiT = $('#cddjusti', '#frmInfListaMovimentacoes');
	cDsobservT = $('#dsobserv', '#frmInfListaMovimentacoes');
	cDsobsctrT = $('#dsobsctr', '#frmInfListaMovimentacoes');	
	
	cDtrefiniT.attr('autocomplete','off').addClass('data').css({width:'80px'});
	cDtreffimT.attr('autocomplete','off').addClass('data').css({width:'80px'});
	cSaidaT.css({width:'100px'});
	cTpvinculT.css({width:'40px'});
	cInfrepcfT.css({width:'100px'});
	cDsstatusT.css({width:'106px'});
	cCddjustiT.css({width:'459px'});
	cDsobservT.css({width:'459px'});
	cDsobsctrT.css({width:'459px'});	
	
	layoutPadrao();
	highlightObjFocus( $('#frmInfListaMovimentacoes') );
}

function LiberaFormulario() {

	if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda')  ) { return false; }	

	// Desabilita campo opção
	$('#cddopcao','#frmCab').desabilitaCampo();
	
	cddopcao = cCddopcao.val();
	
	/*Opção C e J*/
	formataFrmInfConsultaMovimentacao();
	cTodosFrmInfConsultaMovimentacao = $('input[type="text"],select, input[type="checkbox"]','#frmInfConsultaMovimentacao');
	cTodosFrmInfConsultaMovimentacao.desabilitaCampo().limpaFormulario();
	$('#tbJustificativa','#frmInfConsultaMovimentacao').removeAttr('onclick');
		
	/*Opção C e J*/
	
	/*Opção F e X*/
	formataFrmFechamento();
	cTodosFrmInfFechamento = $('input[type="text"],select, input[type="checkbox"]','#frmInfFechamento');
	cTodosFrmInfFechamento.desabilitaCampo();
	/*Opção F e X*/
	
	/*Opção P*/
	formataFrmInfConsultaDetalheMov();
	cTodosFrmInfConsultaDetalheMov = $('input[type="text"],select, input[type="checkbox"]','#frmInfConsultaDetalheMov');
	cTodosFrmInfConsultaDetalheMov.desabilitaCampo().limpaFormulario();	
	cDtreffimP.val($('#dtPadrao', '#divCldsed').val());
	/*Opção P*/
	
	/*Opção T*/
	formataFrmInfListaMovimentacoes();
	cTodosFrmInfListaMovimentacoes = $('input[type="text"],select, input[type="checkbox"]','#frmInfListaMovimentacoes');
	cTodosFrmInfListaMovimentacoes.desabilitaCampo();
	cTodosFrmInfListaMovimentacoes.limpaFormulario();
	cDtreffimT.val($('#dtPadrao', '#divCldsed').val());
	/*Opção T*/
	
	if(cddopcao == "C" || cddopcao == "J") {
		$('#frmInfConsultaMovimentacao').css({'display': 'block'});
		$('#divBotoes', '#divTela').css({'display':'block'});
		controlaFocoFrmInfConsultaMovimentacao();
	} else if(cddopcao == "F" || cddopcao == "X") {
		$('#frmInfFechamento').css({'display': 'block'});
		$('#divBotoes', '#divTela').css({'display':'block'});
		controlaFocoFrmInfFechamento();
	} else if(cddopcao == "P") {
		$('#frmInfConsultaDetalheMov').css({'display': 'block'});
		$('#divBotoes', '#divTela').css({'display':'block'});
		controlaFocoFrmInfConsultaDetalheMov();
	} else if(cddopcao == "T") {
		$('#frmInfListaMovimentacoes').css({'display': 'block'});
		$('#divBotoes', '#divTela').css({'display':'block'});
		controlaFocoFrmInfListaMovimentacoes();
	}

	return false;
}

function controlaFocoFrmInfConsultaMovimentacao() {
	cFlextjusCJ.habilitaCampo().focus();
	cDtmvtoltCJ.habilitaCampo();
	
	cFlextjusCJ.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cDtmvtoltCJ.focus();
			return false;
		}	
	});
	
	cDtmvtoltCJ.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {
		//guarda a quantidade de caracteres do campo para validação
		var tamanho = cDtmvtoltCJ.val();
			if(cDtmvtoltCJ.val() == "" || tamanho.length < 8)
			{
				showError("error","Informe uma data!","Alerta - Ayllos","cDtmvtoltCJ.focus()");
			}
			else controlaOperacao();
			return false;
		}	
	});
	
	if(cddopcao == "J"){
		cCddjustiCJ.habilitaCampo().unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				if(cCddjustiCJ.val() == "7") {
					cDsdjustiCJ.val('');
					cDsdjustiCJ.habilitaCampo().focus();
				} else {
					buscaJustificativas('pesquisa');
					cDsdjustiCJ.desabilitaCampo();
					cInfrepcfCJ.focus();
				}
				return false;
			} else if(e.keyCode == 118) {
				controlaPesquisa(1);
			}	
		});
		cDsdjustiCJ.unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				cInfrepcfCJ.focus();
				return false;
			}	
		});	
		cInfrepcfCJ.habilitaCampo().unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				cDsobsctrCJ.focus();
				return false;
			}	
		});	
		cDsobsctrCJ.habilitaCampo().unbind('keypress').bind('keypress', function(e) {
			if ( e.keyCode == 9 || e.keyCode == 13 ) {	
				controlaOperacao();
				return false;
			}	
		});		
	}
}

function controlaFocoFrmInfFechamento() {
	cDtmvtoltFX.habilitaCampo().focus().unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			controlaOperacao();
			return false;
		}	
	});
}

function controlaFocoFrmInfConsultaDetalheMov() {
	cTodosFrmInfConsultaDetalheMov.habilitaCampo();
	cDsdjustiP.desabilitaCampo();
	cInfrepcfP.desabilitaCampo();
	cDsstatusP.desabilitaCampo();
	
	cNrdcontaP.focus().unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cDtrefiniP.focus();
			return false;
		}	
	});	
	cDtrefiniP.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cDtreffimP.focus();
			return false;
		}	
	});	
	cDtreffimP.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cCdstatusP.focus();
			return false;
		}	
	});	
	cCdstatusP.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cCdincoafP.focus();
			return false;
		}	
	});	
	cCdincoafP.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cSaidaP.focus();
			return false;
		}	
	});	
	cSaidaP.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			if(cDtrefiniP.val() == "") {
				showError("error","Informe uma data de Inicio","Alerta - Ayllos","cDtrefiniP.focus()");
			} else {
				controlaOperacao();
			}
			return false;
		}	
	});	
}
function controlaFocoFrmInfListaMovimentacoes() {
	cDtrefiniT.habilitaCampo().focus().unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cDtreffimT.focus();
			return false;
		}	
	});	
	
	cDtreffimT.habilitaCampo().unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cSaidaT.focus();
			return false;
		}	
	});	

	cSaidaT.habilitaCampo().unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			if(cDtrefiniT.val() == "")
			{
				showError("error","Informe uma data de Inicio","Alerta - Ayllos","cDtrefiniT.focus()");
			}else controlaOperacao(); 
			return false;
		}	
	});	
}

function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>');

	if ( botao != '') {
		$('#divBotoes','#divTela').append('&nbsp;<a href="#" class="botao" id="btSalvar" onClick="controlaOperacao(); return false;" >'+botao+'</a>');
	}
	return false;
}

function btnVoltar() {
	estadoInicial();
	return false;
}


function realizaOperacao(opcao,nriniseq, nrregist) {

	if (cFlextjusCJ.is(':checked')) {
		cFlextjusCJ.val('yes');
	} else {
		cFlextjusCJ.val('no');
	}
	// declaração de variaveis para utilizar na função
	var dtmvtolt = "", dtrefini = "", dtreffim = "";
	
	// Verificando opção para informar os valores corretos para as variaveis
	if(opcao == "F" || opcao == "X") {
		dtmvtolt = cDtmvtoltFX.val();
	} else if(opcao == "C" || opcao == "J") {
		dtmvtolt = cDtmvtoltCJ.val();
	}
	
	if(opcao == "T") {
		dtrefini = cDtrefiniT.val();
		dtreffim = cDtreffimT.val();
	} else if (opcao == "P") {
		dtrefini = cDtrefiniP.val();
		dtreffim = cDtreffimP.val();	
	}

	var msg = "Aguarde, liberando aplicacao...";
	switch(opcao){
		case 'C': msg = "Aguarde, consultando ..";break;
		case 'J': msg = "Aguarde, justificando movimento...";break;
		case 'F': msg = "Aguarde, realizando fechamento...";break;
		case 'X': msg = "Aguarde, desfazendo fechamento...";break;
		case 'P': msg = "Aguarde, consultando...";break;
		case 'T': msg = "Aguarde, consultando...";break;
	}
	
	showMsgAguardo(msg)

	// Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cldsed/manter_rotina.php", 
		data: { cddopcao: opcao,
          		opvaljus: cddopcao, //servira apenas para a Validação da opção Js
			    flextjus: cFlextjusCJ.val(),
			    dtmvtolt: dtmvtolt,				// esta variavel dependendo da opção pode ou não ser utilizada como a global
			    nrdrowid: cNrdrowidCJ,
			    cddjusti: cCddjustiCJ.val(),
			    dsdjusti: cDsdjustiCJ.val(),
			    dsobsctr: cDsobsctrCJ.val(),
			    opeenvcf: cOpeenvcfCJ.val(),
			    infrepcf: cInfrepcfCJ.val(),
			    dtrefini: dtrefini,
			    dtreffim: dtreffim,
			    cdincoaf: cCdincoafP.val(),
			    nrdconta: normalizaNumero(cNrdcontaP.val()),
			    cdstatus: cCdstatusP.val(),
			    nriniseq: nriniseq,
                nrregist: nrregist,
			    redirect: "script_ajax" }, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
		    if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {  
				try {
					if(opcao == "C") { 
						$('#divTabMovimentacao', '#fieldMovimentacao', '#frmInfConsultaMovimentacao').html(response);
						
						cTodosFrmInfConsultaMovimentacao.desabilitaCampo();
						$('#fieldMovimentacao', '#frmInfConsultaMovimentacao').css({'display':'block'});
						cddopcao=="C"?$('#btSalvar', '#divBotoes').hide():$('#btSalvar', '#divBotoes').show();
						formataTabConsultaMovimentacao();
						verificaEntrou = false;
						selecionaTabConsultaMovimentacao();
						hideMsgAguardo();
						
					} else if(opcao == "F" || opcao == "X") {
						eval(response);
					} else if(opcao == "P") {						
						$('#divTabMovimentacao2', '#fieldMovimentacao2', '#frmInfConsultaDetalheMov').html(response);
						$('#fieldMovimentacao2', '#frmInfConsultaDetalheMov').css({'display':'block'});
						cTodosFrmInfConsultaDetalheMov.desabilitaCampo();
						
						$('#btSalvar', '#divBotoes').hide();
						formataTabConsultaDetalheMov();
						selecionaTabConsultaDetalheMov();
						hideMsgAguardo();					
					} else if(opcao == "T") {						
						$('#divTabMovimentacao3', '#fieldMovimentacao3', '#frmInfListaMovimentacoes').html(response);
						$('#fieldMovimentacao3', '#frmInfListaMovimentacoes').css({'display':'block'});
						cTodosFrmInfListaMovimentacoes.desabilitaCampo();
						
						$('#btSalvar', '#divBotoes').hide();
						formataTabListaMovimentacoes();
						selecionaTabListaMovimentacoes();
						hideMsgAguardo();					
					} else if (opcao == "J") {
						eval(response);
					}
					return false;
				} catch(error) {
					hideMsgAguardo();
					showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","");
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
}
//função para diversas requisições passando apenas no nome do arquivo e os dados
function validaCoaf() {
	showMsgAguardo('Aguarde, validando ...');

	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cldsed/valida_coaf.php', 
		data: { cddopcao: cddopcao,
			    dtmvtolt: cDtmvtoltFX.val(),
			    redirect: 'html_ajax' }, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			if (response.indexOf('showError("error"') == - 1 && response.indexOf('XML error:') == - 1 && response.indexOf('#frmErro') == - 1) {
				try {
					eval(response);
					return false;
				} catch(error) {
						hideMsgAguardo();
						showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
				}
			}else {
				try {
					eval(response);
				} catch (error) {
					hideMsgAguardo();
						showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
					}
				} 
		}
	});
	return false;
}

function controlaOperacao() {
	if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda')  ) {
		// Valida os campos obrigatorios em caso de alteracao ou incluao.
		if ( (cddopcao == "C") || (cddopcao == "J") ) {
			if($('#dtmvtolt','#frmInfConsultaMovimentacao').hasClass('campoTelaSemBorda') ){
				showConfirmacao("078 - Confirma a opera&ccedil;&atilde;o?","Confirma&ccedil;&atilde;o - Ayllos","realizaOperacao('J','1','30');","showError('error','079 - Opera&ccedil;&atilde;o n&atilde;o realizada.','Alerta - Ayllos','unblockBackground()');","sim.gif","nao.gif");			
			} else {
				realizaOperacao("C", '1', '30');
			}
				
		} else if (cddopcao == "F") {
			showConfirmacao("078 - Confirma a opera&ccedil;&atilde;o?","Confirma&ccedil;&atilde;o - Ayllos","validaCoaf();","showError('error','079 - Opera&ccedil;&atilde;o n&atilde;o realizada.','Alerta - Ayllos','unblockBackground()');","sim.gif","nao.gif");						
		} else if (cddopcao == "X") {
		    showConfirmacao("078 - Confirma a opera&ccedil;&atilde;o?", "Confirma&ccedil;&atilde;o - Ayllos", "realizaOperacao('X','1','30');", "showError('error','079 - Opera&ccedil;&atilde;o n&atilde;o realizada.','Alerta - Ayllos','unblockBackground()');", "sim.gif", "nao.gif");
		} else if (cddopcao == "P") {
			if (cSaidaP.val() == "T") {
				realizaOperacao("P", '1', '30');
			} else if (cSaidaP.val() == "I") {
				imprimeDetalheMov();
			} else if(cSaidaP.val() == "A") {
				geraArquivo('nome_arquivo');
			}
		} else if (cddopcao == "T") {
			if (cSaidaT.val() == "T") {
		    realizaOperacao("T", '1', '30');
			} else if(cSaidaT.val() == "I") {
				imprimeListaMovimentacoes();
			} else if(cSaidaT.val() == "A") {
				showConfirmacao("Deseja gerar arquivo para o EXCEL?  - Ayllos","Confirma&ccedil;&atilde;o - Ayllos","geraArquivo('nome_arquivo','s');","geraArquivo('nome_arquivo','n');;","sim.gif","nao.gif");		
			}			
		}
	}
}

 //Função para seleção de registros nas tabelas da opção J e C
 function selecionaTabConsultaMovimentacao() {
	if ( $('table > tbody > tr', 'div#divInfConsultaMovimentacao div.divRegistros').hasClass('corSelecao') ) {
		$('table > tbody > tr', 'div#divInfConsultaMovimentacao div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				cNmprimtlCJ.val($('#hnmprimtl', $(this)).val());
				cInpessoaCJ.val($('#hinpessoa', $(this)).val());
				cCdoperadCJ.val($('#hcdoperad', $(this)).val());
				cOpeenvcfCJ.val($('#hopeenvcf', $(this)).val());
				cCddjustiCJ.val($('#hcddjusti', $(this)).val());
				cDsdjustiCJ.val($('#hdsdjusti', $(this)).val());
				cDsobservCJ.val($('#hdsobserv', $(this)).val());
				cInfrepcfCJ.val($('#hinfrepcf', $(this)).val());
				cDsobsctrCJ.val($('#hdsobsctr', $(this)).val());
				cNrdrowidCJ  = $('#nrdrowid', $(this)).val();
				
				if(cddopcao == "J" && verificaEntrou == true) {
					cCddjustiCJ.habilitaCampo().focus();
					$('#tbJustificativa','#frmInfConsultaMovimentacao').attr('onClick','controlaPesquisa(1); return false;');
					cInfrepcfCJ.habilitaCampo();
					cDsobsctrCJ.habilitaCampo();
				} else {
					verificaEntrou = true;
				}
			}	
		});
	}
	
	return false;
}	

function formataTabConsultaMovimentacao() {
	var divRegistro = $('div.divRegistros','#divInfConsultaMovimentacao');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
	
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];	
	
	var arrayLargura = new Array();
	arrayLargura[0] = '46px';
	arrayLargura[1] = '81px';
	arrayLargura[2] = '99px';
	arrayLargura[3] = '61px';
	arrayLargura[4] = '115px';
	arrayLargura[5] = '63px';
	
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'right';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'right';
	
	var metodoTabela = 'selecionaTabConsultaMovimentacao();';
			
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );
}

/*tabela de justificativas -- Opção J*/
function buscaJustificativas(tipo) {
	showMsgAguardo('Aguarde, buscando ...');
	
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cldsed/carrega_justificativas.php', 
		data: { cddjusti: cCddjustiCJ.val(),
         		tipoBusca: tipo,
				cddopcao: cddopcao,
		     	redirect: 'script_ajax' }, 
		error: function(objAjax,responseError,objExcept) {
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground();");
		},
		success: function(response) {
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					if(tipo == "modal") {
						$('#divConteudo').html(response);
						exibeRotina($('#divRotina'));
						formataJustificativa();
						return false;
					} else if(tipo == "pesquisa") {
						eval(response);
						hideMsgAguardo();
					}
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

function formataJustificativa() {
	var divRegistro = $('div.divRegistros','#divJustificativas');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	divRegistro.css({'height':'120px','width':'545px'});
	
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];	
	
	var arrayLargura = new Array();
	arrayLargura[0] = '100px';
	arrayLargura[1] = '445px';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'left';
	
	var metodoTabela = 'selecionaJustificativa();';
			
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );
	
	hideMsgAguardo();
	bloqueiaFundo( $('#divRotina') );
	
	return false;
}

function selecionaJustificativa() {
	if ( $('table > tbody > tr', 'div#divJustificativas div.divRegistros').hasClass('corSelecao') ) {
		$('table > tbody > tr', 'div#divJustificativas div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				$('#cddjusti').val($('#hcddjusti', $(this)).val());

				if($('#hcddjusti', $(this)).val() != 7) {
					cDsdjustiCJ.val($('#hdsdjusti', $(this)).val());
					cDsdjustiCJ.desabilitaCampo();
					cInfrepcfCJ.focus();
				} else if($('#hcddjusti', $(this)).val() == 7) {
					cDsdjustiCJ.val('');
					cDsdjustiCJ.habilitaCampo();
					cDsdjustiCJ.focus();
				}
			}
		});
	}
	
	fechaRotina($('#divRotina'));
	return false;
}

//mostra a tabela de justificativas
function mostraJustificativa() {
	showMsgAguardo('Aguarde, buscando ...');

	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cldsed/lista_justificativa.php', 
		data: { redirect: 'html_ajax' }, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			$('#divRotina').html(response);
			buscaJustificativas("modal");
			return false;
		}				
	});
	
	return false;
}
/*Controlar pesqisas*/
function controlaPesquisa(param) {
	if(param == 1) {
		if(cddopcao != "C") {
			mostraJustificativa();
		}
	}
}

function imprimeDetalheMov() {
	
	var dtrefini = cDtrefiniP.val();
	var dtreffim = cDtreffimP.val();
	var cdstatus = cCdstatusP.val();
	var cdincoaf = cCdincoafP.val();
    var saida    = cSaidaP.val();
	
    showMsgAguardo('Aguarde, buscando ...');
    
    $('input,select', '#frmInfConsultaDetalheMov').removeClass('campoErro');

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/cldsed/gera_imprime_arq_pesquisa.php',
        data: {
            nrdconta: normalizaNumero(cNrdcontaP.val()),
            cddopcao: cddopcao,
            dtrefini: dtrefini,
            dtreffim: dtreffim,
            cdstatus: cdstatus,
            cdincoaf: cdincoaf,            
            saida: saida,            
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground()");
        },
        success: function (response) {
            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', "$('#btVoltar','#divBotoes').focus();");
            }
        }
    });

    return false;
}

function Gera_Impressao(nmarqpdf, callback) {

    hideMsgAguardo();

    var action = UrlSite + 'telas/cldsed/imprimir_pdf.php';

    $('#nmarqpdf', '#frmCab').remove();
    $('#sidlogin', '#frmCab').remove();

    $('#frmCab').append('<input type="hidden" id="nmarqpdf" name="nmarqpdf" value="' + nmarqpdf + '" />');
    $('#frmCab').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin', '#frmMenu').val() + '" />');

    carregaImpressaoAyllos("frmCab", action, callback);

}

// OBS: Opção excel só sera utilziada na opção T 
function geraArquivo(pagina, excel) {
	var	dtrefini;
	var	dtreffim;
	var	cdstatus;
	var	cdincoaf;
	var	saida;
		
	if(cddopcao == "P") {
		dtrefini = cDtrefiniP.val();
		dtreffim = cDtreffimP.val();
		cdstatus = cCdstatusP.val();
		cdincoaf = cCdincoafP.val();
		saida = cSaidaP.val();
	} else {
		dtrefini = cDtrefiniT.val();
		dtreffim = cDtreffimT.val();
		saida = cSaidaT.val();
	}
	showMsgAguardo('Aguarde, buscando ...');

	// Executa script de confirmação através de ajax
	$.ajax({		
		type: 'POST',
		dataType: 'html',
		url: UrlSite + 'telas/cldsed/' + pagina + '.php', 
		data: { nrdconta: normalizaNumero(cNrdcontaP.val()),
			    cddopcao: cddopcao,
			    dtrefini: dtrefini,
			    dtreffim: dtreffim,
			    cdstatus: cdstatus,
			    cdincoaf: cdincoaf,
			    nmarquivo: $('#nmarquivo', '#divNomeArquivoImpresssao').val(),
			    saida: saida,
			    excel: excel,
			    redirect: 'html_ajax' }, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();			
			showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
		},
		success: function(response) {
			if(pagina == "nome_arquivo"){
				$('#divRotina').html(response);
				exibeRotina($('#divRotina'));
				hideMsgAguardo();
				blockBackground();
				
				$('#nmarquivo', '#divNomeArquivoImpresssao').focus().unbind('keypress').bind('keypress', function(e) {
					if ( e.keyCode == 9 || e.keyCode == 13 ) {	
					    if (cddopcao == "P") {

					        fechaRotina($('#divRotina'));
					        geraArquivo("gera_imprime_arq_pesquisa");

					    } else if (cddopcao == "T") {

					        fechaRotina($('#divRotina'));
					        geraArquivo("gera_imprime_arq_atividade", excel);

					    }

						return false;

					}	
				});
			}
			
			if (pagina == "gera_imprime_arq_pesquisa" || pagina == "gera_imprime_arq_atividade") {
				hideMsgAguardo();
				
			    try {                    
                    eval(response);
                } catch (error) {
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', "estadoInicial();");
			}
			
			}			
			
		}				
	});
	
	return false;
}
// rotina para formatar a tabela na opção P
function formataTabConsultaDetalheMov() {
	var divRegistro = $('div.divRegistros','#divInfDetalheMov');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
	
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];	
	
	var arrayLargura = new Array();
	arrayLargura[0] = '62px';
	arrayLargura[1] = '100px';
	arrayLargura[2] = '73px';
	arrayLargura[3] = '80px';
	arrayLargura[4] = '81px';
	arrayLargura[5] = '80px';
	
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'right';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'right';

	var metodoTabela = 'selecionaTabConsultaDetalheMov();';
			
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );
}

function selecionaTabConsultaDetalheMov() {
	if ( $('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao') ) {
		$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
			cDsdjustiP.val($('#hdsdjusti', $(this)).val());
			cInfrepcfP.val($('#hinfrepcf', $(this)).val());
			cDsstatusP.val($('#hdsstatus', $(this)).val());
			}
		});
	}
	
	return false;
}	

function formataTabListaMovimentacoes() {
	var divRegistro = $('div.divRegistros','#divTabListaMovimentacoes');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
	
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];	
	
	var arrayLargura = new Array();
	arrayLargura[0] = '62px';
	arrayLargura[1] = '100px';
	arrayLargura[2] = '73px';
	arrayLargura[3] = '80px';
	arrayLargura[4] = '81px';
	arrayLargura[5] = '80px';
	
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'right';

	var metodoTabela = 'selecionaTabListaMovimentacoes();';
			
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );
}

function selecionaTabListaMovimentacoes() {
	if ( $('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao') ) {
		$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				cTpvinculT.val($('#htpvincul', $(this)).val());
				cInfrepcfT.val($('#hinfrepcf', $(this)).val());
				cDsstatusT.val($('#hdsstatus', $(this)).val());
				cCddjustiT.val($('#hcddjusti', $(this)).val());
				cDsobservT.val($('#hdsobserv', $(this)).val());
				cDsobsctrT.val($('#hdsobsctr', $(this)).val());
			}
		});
	}
	return false;
}	

function imprimeListaMovimentacoes(){
	
	var dtrefini = cDtrefiniT.val();
	var dtreffim = cDtreffimT.val();
    var saida    = cSaidaT.val();

    showMsgAguardo('Aguarde, buscando ...');
    
    $('input,select', '#frmInfListaMovimentacoes').removeClass('campoErro');

    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/cldsed/gera_imprime_arq_atividade.php',
        data: {
            cddopcao: cddopcao,
            dtrefini: dtrefini,
            dtreffim: dtreffim,
            saida: saida,            
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground()");
        },
        success: function (response) {
            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', "$('#btVoltar','#divBotoes').focus();");
            }
        }
    });

    return false;
}
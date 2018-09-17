/*********************************************************************************************
 FONTE        : cldmes.js
 CRIAÇÃO      : Cristian Filipe (GATI)         
 DATA CRIAÇÃO : Novembro/2013								Última alteração: 17/12/2014
 OBJETIVO     : Biblioteca de funções da tela CLDMES
 --------------
 REVISÃO      : Michel M. Candido (GATI)
 -------------- 
 
 Alterações: 24/11/2014 - Ajustes para liberação (Adriano).  
             17/12/2014 - Alterado tamanho do campo do PA. (Douglas - Chamado 229676)
				
***********************************************************************************************/

// Definição de algumas variáveis globais 
var cddopcao = 'C';
	
//Formulários
var frmCab  = 'frmCab';

//Campos do cabeçalho
var cTodosCabecalho;

//Campos do form consulta
var cTodosConsulta;

// guardar a data inicial do campo data
var guarda_data; 

$(document).ready(function(){
       
    estadoInicial();
	
	highlightObjFocus( $('#'+frmCab) );
	
	$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
	$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
	guarda_data = $('#tdtmvtol', '#frmInfConsulta').val();
	
	return false;
    
});

function estadoInicial() {   

	$('#divTela').fadeTo(0,0.1);
	$('#frmCab').css({'display':'block'});
	
	$('#frmInfConsulta').css({'display':'none'});
	$('#frmInfFechamento').css({'display':'none'});
	$('#frmInfMovimentacao').css({'display':'none'});
	
	$('#divBotoes').css({'display':'none'});
	$('#btSalvar', '#frmBotoes').show();
	
	formataCabecalho();
	
	// Remover class campoErro
	$('input,select', '#frmCab').removeClass('campoErro');	
	
	cTodosCabecalho.limpaFormulario();
	$('#cddopcao','#'+frmCab).val( cddopcao );
	
	removeOpacidade('divTela');	
	unblockBackground();
	hideMsgAguardo();
	
	cTodosCabecalho.desabilitaCampo();
		
	$('#cddopcao', '#frmCab').habilitaCampo().focus();
	
	controlaFoco();
	
}
function formataCabecalho() {

	// Cabecalho
	var rCddopcao   = $('label[for="cddopcao"]','#'+frmCab); 	
	var cCddopcao	= $('#cddopcao','#'+frmCab); 
	var btnCab		= $('#btOK','#'+frmCab);
	
	cTodosCabecalho	= $('input[type="text"],select','#'+frmCab);
	
	rCddopcao.css('width','44px');
	
	cCddopcao.css({'width':'510px'});
	
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

function LiberaFormulario() {

	if ( $('#cddopcao','#frmCab').hasClass('campoTelaSemBorda')  ) { return false; }	

	// Desabilita campo opção
	$('#cddopcao','#frmCab').desabilitaCampo();
	
	cddopcao = $('#cddopcao','#'+frmCab).val();
	
	cTodosConsulta = $('input[type="text"],select','#frmInfConsulta'); 
	cTodosConsulta.desabilitaCampo();
	cTodosConsulta.limpaFormulario();
	$('#tdtmvtol', '#frmInfConsulta').val(guarda_data);
	
	formataFormularioCldmes();
	
	// Mostra form conforme a opção do usuario
	if(cddopcao == "C") {
		$('#frmInfConsulta').css({'display':'block'});
		$('#frmInfFechamento').css({'display':'none'});
		$('#divBotoes', '#divTela').css({'display':'block'});
		$('#btSalvar', '#divBotoes').show();
		$('#tdtmvtol','#frmInfConsulta').focus();

	}else {
		$('#frmInfConsulta').css({'display':'none'});
		$('#frmInfFechamento').css({'display':'block'});
		// confirmação pra fechamento
		showConfirmacao("078 - Confirma opera&ccedil;&atilde;o?","Confirma&ccedil;&atilde;o - Ayllos","manterRotina(1,30);","showError('error','079 - Opera&ccedil;&atilde;o n&atilde;o realizada.','Alerta - Ayllos','estadoInicial()');","sim.gif","nao.gif");	
		$('#divBotoes', '#divTela').css({'display':'none'});
	}
	
	//Ao clicar no botao btVoltar
	$('#btVoltar','#divBotoes').unbind('click').bind('click', function(){
		
		btnVoltar(1);
		
		return false;						
		
	});
	
	//Ao clicar no botao btSalvar
	$('#btSalvar','#divBotoes').unbind('click').bind('click', function(){
			
		manterRotina(1,30);
		
		return false;
								
	});
    
	return false;

}

function formataFormularioCldmes() {

	cTodosConsulta.habilitaCampo();
	var rTdtmvtol    = $('label[for="tdtmvtol"]', '#frmInfConsulta');
	var rCdagepac	 = $('label[for="cdagepac"]', '#frmInfConsulta');
	
	$('label[for="operacao"]', '#frmInfConsulta').css({width:'160px'})
	rTdtmvtol.css({width:'100px'});	
	rCdagepac.css({width:'100px'});
	
	var cTdtmvtol    = $('#tdtmvtol', '#frmInfConsulta');
	var cCdagepac	 = $('#cdagepac', '#frmInfConsulta');
	
	cTdtmvtol.focus().css({width:'80px'}).addClass('data');
	cCdagepac.css({width:'35px'});
	
	cTdtmvtol.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {	
			cCdagepac.focus();
			return false;
		}	
	});
	
	cCdagepac.unbind('keypress').bind('keypress', function(e) {
		if ( e.keyCode == 9 || e.keyCode == 13 ) {				
			manterRotina(1,30);
			return false;
		}
	}).unbind('keydown').bind('keydown', function(e){
		if(e.keyCode == 118){			
			controlaPesquisa();
			return false;
		}		
	}) ;
	
	highlightObjFocus( $('#frmInfConsulta') );
	
	/*Opcao F*/
	$('label[for="operacao"]', '#frmInfFechamento').css({width:'160px'});
		
	var rTdtmvtol2    = $('label[for="tdtmvtol"]', '#frmInfFechamento');	
	rTdtmvtol2.css({width:'160px'});
	
	var cTdtmvtol2    = $('#tdtmvtol', '#frmInfFechamento');
	cTdtmvtol2.addClass('data').css({width:'80px'}).desabilitaCampo();
	
	layoutPadrao();
}
function manterRotina(nriniseq, nrregist){
	
	$('#tdtmvtol', '#frmInfConsulta').desabilitaCampo();
	$('#cdagepac', '#frmInfConsulta').desabilitaCampo();
	
	var tdtmvtol;
	
    if(cddopcao=="C"){
		showMsgAguardo('Aguarde, buscando movimentações ...');
		tdtmvtol = $('#tdtmvtol', '#frmInfConsulta').val();
	}else{
		showMsgAguardo('Aguarde, efetuando fechamento ...');
		tdtmvtol = $('#tdtmvtol', '#frmInfFechamento').val();
	}
	
    // Executa script de confirmação através de ajax
    $.ajax({        
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cldmes/manter_rotina.php', 
        data: {
            cddopcao: cddopcao,
			tdtmvtol: tdtmvtol,
			cdagepac: $('#cdagepac', '#frmInfConsulta').val(),
			nriniseq: nriniseq,
			nrregist: nrregist,
            redirect: 'html_ajax'           
            }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();           
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
        },
        success: function(response) {
			hideMsgAguardo();
			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					$('#divMovimentacao').html(response);
					return false;
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();$("#nrercben","#divBeneficio").focus();');
				}
			} else {
				try {
					eval( response );						
				} catch(error) {						
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();$("#nrercben","#divBeneficio").focus();');
				}
			}
			 
        }
    });
	
	return false;
	
}

function formataTabelaMovimentacao() {

	var divRegistro = $('div.divRegistros','#divTabMovimentacao');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
			
	
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];	
	
	var arrayLargura = new Array();
	arrayLargura[0] = '26px';
	arrayLargura[1] = '76px';
	arrayLargura[2] = '185px';
	arrayLargura[3] = '81px';
	arrayLargura[4] = '64px';
	arrayLargura[5] = '86px';
	
		
	var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	arrayAlinha[1] = 'center';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'right';
	arrayAlinha[4] = 'right';
	arrayAlinha[5] = 'right';

	var metodoTabela = 'selecionaMovimentacao();';
			
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );
	
	$("#btSalvar","#divBotoes").hide();
	
	layoutPadrao();
	
}

function selecionaMovimentacao() {
	
	if ( $('table > tbody > tr', 'div.divRegistros').hasClass('corSelecao') ) {

		$('table > tbody > tr', 'div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
				
				hnrdconta = $('#hnrdconta', $(this)).val();
				showConfirmacao("Voce deseja Imprimir o Relatorio?","Confirma&ccedil;&atilde;o - Ayllos","imprimirGeraRelatorio();","hideMsgAguardo();","sim.gif","nao.gif");		
				
			}	
		});
	}
	return false;
}

function btnVoltar(controle) {
	
	if(controle == 1){
		
		estadoInicial();
		
	}else{
				
		//Ao clicar no botao btVoltar
		$('#btVoltar','#divBotoes').unbind('click').bind('click', function(){
			
			btnVoltar(1);
			
			return false;						
			
		});		
		
		$('#frmInfConsulta').css({'display':'block'});
		$('#frmInfMovimentacao').css({'display':'none'});
		$('#divBotoes', '#divTela').css({'display':'block'});
		$('#btSalvar', '#divBotoes').show();
		$('#tdtmvtol','#frmInfConsulta').habilitaCampo().focus();
		$('#cdagepac','#frmInfConsulta').habilitaCampo().val('');
	
	}
	
	return false;
}

function imprimirGeraRelatorio(){
	
	var sidlogin = $("#sidlogin","#frmMenu").val();
	var teldtmvtolt = $("#tdtmvtol","#frmInfConsulta").val();
	
	$('#frmImpressao').append('<input type="hidden" id="tdtmvtol" name="tdtmvtol" value="'+teldtmvtolt+'" />');
	$('#frmImpressao').append('<input type="hidden" id="nrdconta" name="nrdconta" value="'+hnrdconta+'" />');
	$('#frmImpressao').append('<input type="hidden" id="cddopcao" name="cddopcao" value="'+cddopcao+'" />');
	$('#frmImpressao').append('<input type="hidden" id="sidlogin" name="sidlogin" value="'+sidlogin+'" />');

	var action = UrlSite + "telas/cldmes/gera_relatorio.php";	
	carregaImpressaoAyllos("frmImpressao",action);	
	
}

function controlaPesquisa() {

	// Se esta desabilitado o campo PA
	if ($("#cdagepac","#frmInfConsulta").prop("disabled") == true)  {
		return;
	}
	
	// Variável local para guardar o elemento anterior
	var campoAnterior = '';
	var bo, procedure, titulo, qtReg, filtrosPesq, colunas;	
	
	// Nome do Formulário que estamos trabalhando
	var nomeFormulario = 'frmInfConsulta';
	
	var divRotina = 'divTela';
	
	//Remove a classe de Erro do form
	$('input,select', '#'+nomeFormulario).removeClass('campoErro');
	
	bo 		    = 'b1wgen0059.p';
	procedure	= 'busca_pac';
	titulo      = 'Agência PA';
	qtReg		= '20';					
	filtrosPesq	= 'Cód. PA;cdagepac;30px;S;0|Agência PA;dsagepac;200px;S;';
	colunas 	= 'Código;cdagepac;20%;right|Descrição;dsagepac;80%;left';	
	mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas,divRotina);			       	    
	
	return false;
	
}
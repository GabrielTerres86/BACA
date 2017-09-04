/*!
 * FONTE        : nacionalidades.js
 * CRIAÇÃO      : Kelvin Souza Ott
 * DATA CRIAÇÃO : 13/05/2016
 * OBJETIVO     : Biblioteca de funções da tela nacionalidades
 * --------------
 * ALTERAÇÕES   : 12/04/2017 - Buscar a nacionalidade com CDNACION. (Jaison/Andrino)
 * --------------
 */

$(document).ready(function(){	
	
	estadoInicial();
	
	/**FEITO PARA CARREGAR A CONSULTA AO ABRIR A MODAL**/
	$('#frmConsultar').css({'display':'block'});
	$('#divConteudo').css({'display':'block'});
	
	//Desabilita campo
	$("#cddopcao","#frmCab").desabilitaCampo();
	
	//Inicia a tela já com as nacionalidades carregadas
	buscarNacionalidades();
	/**************************************************/
		
});

function estadoInicial()
{
	$('#divTela').css({'display':'inline'}).fadeTo(0,0.1);
	
	removeOpacidade('divTela');	
	
	formataCabecalho();
	formatarConsultar();
	
	highlightObjFocus( $('#frmCab') ); 
	$('#frmCab').css({'display':'block'});
	$("#cddopcao","#frmCab").focus();
	bloqueiaFundo($('#divUsoGenerico'));
}
	
function buscarNacionalidades(dsnacion)
{	
	showMsgAguardo( "Aguarde, buscando nacionalidades..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "includes/nacionalidades/buscar_nacionalidades.php", 
        data: {
			dsnacion: dsnacion,
            redirect: "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
			bloqueiaFundo($('#divUsoGenerico'));
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#cddopcao','#frmCab').focus();");
        },
        success: function(response) {
            hideMsgAguardo();
			bloqueiaFundo($('#divUsoGenerico'));
			try {
				eval(response);
			} 
			catch (error) {
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus();");
			}
		}
    });
    return false;
	
}

function incluirNacionalidade(dsnacion){
	showMsgAguardo( "Aguarde, incluindo nacionalidade..." );
	
    //Requisição para processar a opção que foi selecionada
	$.ajax({
        type: "POST",
        url: UrlSite + "includes/nacionalidades/incluir_nacionalidades.php", 
        data: {
			dsnacion: dsnacion,
            redirect: "script_ajax"
        },
        error: function(objAjax,responseError,objExcept) {
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","$('#dsnacion','#frmConsultar').focus();");
        },
        success: function(response) {
			try {
				eval(response);
				buscarNacionalidades();
				showError("inform", "Nacionalidade incluida com sucesso.", "Alerta - Ayllos", "estadoInicial();");
			} 
			catch (error) {
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#dsnacion','#frmConsultar').focus();");
			}
		}
    });
    return false;
	
	
}

function formataTabelaNacionalidade(){
	$('#divConteudo').css({'width':'300px','padding-bottom':'2px','padding-left':'4px'});
	
	var divRegistro = $('div.divRegistros', '#divConteudo');
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );

    divRegistro.css({'height':'150px','width':'300px','padding-bottom':'2px'});
	$('#divRegistrosRodape','#divConteudo').formataRodapePesquisa();	
	
	var ordemInicial = new Array();

	var arrayLargura = new Array();
    arrayLargura[0] = '';
	
	
    var arrayAlinha = new Array();
	arrayAlinha[0] = 'left';
	
	var metodoTabela = 'selecionaNacionalidade();';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela);
	
	return false;
	
}

function formataCabecalho(){
	
	rCddopcao = $('label[for="cddopcao"]',"#frmCab");
	cCddopcao = $("#cddopcao","#frmCab");
	$('.botao').css({'padding':'3px 6px'})
	
	$('#frmCab').css({'display':'block'});
	
	cCddopcao.focus();
	
	// rotulo
	rCddopcao.addClass("rotulo").css({"width":"45px"}); 
	
	// campo
	cCddopcao.css("width","215px").habilitaCampo();
	
	$('input[type="text"],select','#frmCab').limpaFormulario().removeClass('campoErro');
		
	//Define ação para ENTER e TAB no campo Opção
	cCddopcao.unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			
			liberaFormulario();
			
			return false;
			
		}
    });	
	
	//Define ação para CLICK no botão de OK
	$("#btnOK","#frmCab").unbind('click').bind('click', function() {
			
		liberaFormulario();
		
		$(this).unbind('click');			
		
		return false;
    });	
	
	layoutPadrao();
	
	return false;	
}

function liberaFormulario() {
	$('#divConteudo').css({'display':'block'});
	buscarNacionalidades();
	
	switch($("#cddopcao","#frmCab").val()) {
		case "C": // Consultar Nacionalidade
			liberaAcaoConsultarNacionalidade();
		break;
		
		case "I": // Incluir Nacionalidade
			liberaAcaoIncluirNacionalidade();
		break;
	}
}

function formatarConsultar(){
	cDsnacion = $('#dsnacion','#frmConsultar');
	
	// rotulo
	$('label[for="dsnacion"]',"#frmConsultar").addClass("rotulo").css({"width":"100px"}); 
	
	// campo
	$('#dsnacion','#frmConsultar').css({'width':'117px'}).addClass('alphanum campo').habilitaCampo();
	$('input[type="text"],select','#frmConsultar').limpaFormulario().removeClass('campoErro');
	
	//Define ação para ENTER e TAB no campo Opção
	cDsnacion.unbind('keypress').bind('keypress', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			
			//Faz a busca da nacionalidade e gera a grid.
			controlaConcluir();
			return false;	
		}
    });	
	
	//Click no botão
	$("#btnConcluir","#frmConsultar").unbind('click').bind('click', function() {
		//Faz a busca da nacionalidade e gera a grid.
		controlaConcluir();
		return false;
	});
	
	$('#frmConsultar').css({'display':'none'});
	/*$('#divConteudo').css({'display':'none'});*/
	$("#cddopcao","#frmCab").habilitaCampo();
	
	highlightObjFocus( $('#frmConsultar') ); 
	
	layoutPadrao();
	
	return false;
	
}

function liberaAcaoConsultarNacionalidade(){
	//Mostra o form de pesquisa
	$('#frmConsultar').css({'display':'block'});
	
	//Desabilita campo
	$("#cddopcao","#frmCab").desabilitaCampo();

	$("#dsnacion").focus();
	
}

function liberaAcaoIncluirNacionalidade (){
	liberaAcaoConsultarNacionalidade();
}

function controlaConcluir(){
	
	switch($("#cddopcao","#frmCab").val()) {
		case "C": 
			concluirConsultar();
		break;
		
		case "I":
			concluirInclusao();
		break;
	}
}

function concluirConsultar(){
	$('#divConteudo').css({'display':'block'});
	buscarNacionalidades($("#dsnacion","#frmConsultar").val());
}


function controlaVoltar(){
	estadoInicial();
	buscarNacionalidades();
}

function selecionaNacionalidade(){
	if ( $('table > tbody > tr', 'div#divConteudo div.divRegistros').hasClass('corSelecao') ) {
		$('table > tbody > tr', 'div#divConteudo div.divRegistros').each( function() {
			if ( $(this).hasClass('corSelecao') ) {
                if (glb_nomeForm != '') {
                    $("#cdnacion","#" + glb_nomeForm).val($(this).attr('cdnacion'));
                    $("#dsnacion","#" + glb_nomeForm).val($(this).text().trim());
                } else {
                    $("#cdnacion").val($(this).attr('cdnacion'));
				$("#dsnacion").val($(this).text().trim());	
                }
				fechaRotina($('#divUsoGenerico'));
			}
		});
	}
	
	return false;
}

function concluirInclusao(){
	showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','incluirNacionalidade($("#dsnacion","#frmConsultar").val());','$("#dsnacion","#frmConsultar").focus();','sim.gif','nao.gif');
}
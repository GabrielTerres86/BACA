/*!
 * FONTE        : cadret.js
 * CRIAÇÃO      : Jorge I. Hamaguchi
 * DATA CRIAÇÃO : 27/08/2013
 * OBJETIVO     : Biblioteca de funções da tela CADRET
 * --------------
 * ALTERAÇÕES   : 
 * -----------------------------------------------------------------------
 */
 
//Formulários e Tabela
var frmCab   		= 'frmCab';
var frmcadret       = 'frmcadret';

//Labels/Campos do cabeçalho
var rCddopcao, rCdoperac, rNrtabela, rCdretorn, rDsretorn, rCdprodut;
var cCddopcao, cCdoperac, cNrtabela, cCdretorn, cDsretorn, cTodosCabecalho, cCdprodut;


$(document).ready(function() {
	estadoInicial();
});

// seletores
function estadoInicial() {

	$('#divTela').fadeTo(0,0.1);
	
	fechaRotina( $('#divRotina') );
	hideMsgAguardo();		
	formataCabecalho();
	formataFrmcadret();
	controlaNavegacao();
	
	trocaBotao('Prosseguir');
	
	cTodosCabecalho.limpaFormulario().removeClass('campoErro');	

	highlightObjFocus( $('#'+frmCab) );
	highlightObjFocus( $('#'+frmcadret) );
	
	$('#'+frmCab).css({'display':'block'});
	$('#'+frmcadret).css({'display':'none'});
	$('#divRetorno').html('').css({'display':'none'});
	$('#divBotoes').css({ 'display': 'none' });
	
	cCdprodut.habilitaCampo();
	cCddopcao.habilitaCampo();
	cCdoperac.habilitaCampo();
	cNrtabela.habilitaCampo();
	removeOpacidade('divTela');

	$("#cddopcao", "#" + frmCab).val("C").focus();
	$("#cdprodut", "#" + frmCab).val("1");
	
	return false;

}


function formataCabecalho() {

	// Cabecalho
	rCddopcao			= $('label[for="cddopcao"]','#'+frmCab);	
	rCddopcao.addClass('rotulo').css({'width':'60px'});
	cCddopcao			= $('#cddopcao','#'+frmCab);
	cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
	cCddopcao.addClass('campo').css({'width':'450px'});
	layoutPadrao();
	return false;
}


function formataFrmcadret() {
	
	// Cabecalho
    rCdprodut = $('label[for="cdprodut"]', '#' + frmcadret);
	rCdoperac = $('label[for="cdoperac"]','#'+frmcadret);
	rNrtabela = $('label[for="nrtabela"]','#'+frmcadret);
	rCdretorn = $('label[for="cdretorn"]','#'+frmcadret);
	rDsretorn = $('label[for="dsretorn"]','#'+frmcadret);
	
	rCdprodut.addClass('rotulo').css({'width':'75px'});
	rCdoperac.addClass('rotulo').css({'width':'75px'});
	rNrtabela.addClass('rotulo').css({'width':'75px'});
	rCdretorn.addClass('rotulo').css({'width':'75px'});
	rDsretorn.addClass('rotulo').css({'width':'75px'});
	
	cCdprodut = $('#cdprodut', '#' + frmcadret);
	cCdoperac = $('#cdoperac','#'+frmcadret);
	cNrtabela = $('#nrtabela','#'+frmcadret);
	cCdretorn = $('#cdretorn','#'+frmcadret);
	cDsretorn = $('#dsretorn','#'+frmcadret);
	
	cCdprodut.addClass('campo').css({'width':'170px'});
	cCdoperac.addClass('campo').css({'width':'150px'});
	cNrtabela.addClass('campo').css({'width':'150px'});
	cCdretorn.addClass('campo').css({'width':'150px'}).setMask('INTEGER','zz9','','');;
	cDsretorn.addClass('campo').css({'width':'450px'}).attr({"maxlength":"131"}); // Renato(Supero) - alterado de 60 para 131 para ficar igual a coluna da tabela
	
	layoutPadrao();

	return false;
}


// Formata
function controlaNavegacao() {

	cCddopcao.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
		    mostraProduto();
			return false;
		}
	});	
	
	cCdprodut.unbind('keypress').bind('keypress', function (e) {
	    if (divError.css('display') == 'block') { return false; }
	    // Se é a tecla ENTER, 
	    if (e.keyCode == 13) {
			liberaCampos();
			return false;
		}
	});	
	
	cCdoperac.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			cNrtabela.focus();
			return false;
		}
	});
	
	cNrtabela.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			if(cCddopcao.val() != "C"){
				cCdretorn.focus();
			}else{
				btnContinuar();
			}
			return false;
		}
	});
	
	cCdretorn.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			if(cCddopcao.val() == "I"){
				cDsretorn.focus();
			}else{
				btnContinuar();
			}
			return false;
		}
	});
	
	cDsretorn.unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }		
		// Se é a tecla ENTER, 
		if ( e.keyCode == 13 ) {
			btnContinuar();
			return false;
		}
	});
	
	return false;	
	
}

function mostraProduto() {
    var cddopcao = $('#cddopcao', '#' + frmCab);

    if (cddopcao.hasClass('campoTelaSemBorda')) { return false; };

    cddopcao.desabilitaCampo();
    $('#' + frmcadret).css({ 'display': 'block' });
    $('#FS_RETORNO').css({ 'display': 'none' });
    $('#divBotoes').css({ 'display': 'block' });
    trocaBotao('');

    formataFrmcadret();

    cCdprodut.val("1");

    $('input, select', '#' + frmcadret).limpaFormulario().removeClass('campoErro');

    highlightObjFocus($('#' + frmcadret));

    // Setar o foco no campo seguinte
    cCdprodut.focus();

    return false;
}

function liberaCampos() {
    var cddopcao = $('#cddopcao', '#' + frmCab);
    var cdprodut = $('#cdprodut', '#' + frmcadret);

    if (cdprodut.hasClass('campoTelaSemBorda')) { return false; };
	
    cdprodut.desabilitaCampo();

    $('input, select', '#' + frmcadret).limpaFormulario().removeClass('campoErro');
	
    // Verificar regras conforme produto selecionado
    if (cdprodut.val() == 1) {
	
        $('#FS_RETORNO').css({ 'display': 'block' });
        trocaBotao('Prosseguir');

        $("#tr_cdoperac", "#" + frmcadret).show();
        $("#tr_nrtabela", "#" + frmcadret).show();
	
        highlightObjFocus($('#' + frmcadret));
	
        if (cddopcao.val() == "C") {
		$("#tr_cdretorn","#"+frmcadret).hide();
		$("#tr_dsretorn","#"+frmcadret).hide();
		cCdoperac.focus();
	}else if(cddopcao.val() == "I"){
		$("#tr_cdretorn","#"+frmcadret).show();
		$("#tr_dsretorn","#"+frmcadret).show();
		cCdretorn.habilitaCampo();
		cDsretorn.habilitaCampo();
		cCdoperac.focus();
	}else if(cddopcao.val() == "A"){
		$("#tr_cdretorn","#"+frmcadret).show();
		$("#tr_dsretorn","#"+frmcadret).show();
		cCdretorn.habilitaCampo();
		cDsretorn.desabilitaCampo();
		cCdoperac.focus();
	}
    } else if (cdprodut.val() == 3) {

        $("#tr_cdoperac", "#" + frmcadret).hide();
        $("#tr_nrtabela", "#" + frmcadret).hide();
        // Seta os valores para os campos que estão ocultos
        $("#tr_cdoperac", "#" + frmcadret).val("I");
        $("#tr_nrtabela", "#" + frmcadret).val("1");
	
        $("#tr_cdretorn", "#" + frmcadret).show();
        $("#tr_dsretorn", "#" + frmcadret).show();

        if (cddopcao.val() == "C") {
            manter_rotina();
        } else if (cddopcao.val() == "I") {

            $('#FS_RETORNO').css({ 'display': 'block' });
            trocaBotao('Prosseguir');

            cCdretorn.habilitaCampo();
            cDsretorn.habilitaCampo();
            cCdretorn.focus();
        } else if (cddopcao.val() == "A") {

            $('#FS_RETORNO').css({ 'display': 'block' });
            trocaBotao('Prosseguir');

            cCdretorn.habilitaCampo();
            cDsretorn.desabilitaCampo();
            cCdretorn.focus();
        }
        
    } 
	
	return false;

}


// Botoes
function btnVoltar() {
	estadoInicial();
	return false;
}

function btnContinuar() {
	
	var cddopcao = $("#cddopcao","#"+frmCab).val();
	
	//Remove a classe de Erro do form
	$('input,select', '#'+frmcadret).removeClass('campoErro');
	
	if(cddopcao == "A" && cDsretorn.attr('disabled') != "disabled"){
		manter_rotina('A1');
	}else{
		manter_rotina();
	}
	return false;
}


function trocaBotao( botao ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;" >Voltar</a>&nbsp;');
	
	if (botao != '') {
		$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onclick="btnContinuar(); return false;" >' + botao + '</a>');
	}

	return false;
}

function manter_rotina(rotina){
	
	var cddopcao = $('#cddopcao','#'+frmCab).val();
	var cdprodut = $('#cdprodut','#'+frmcadret).val();
	var cdoperac = $('#cdoperac','#'+frmcadret).val();
	var nrtabela = $('#nrtabela','#'+frmcadret).val();
	var cdretorn = $('#cdretorn','#'+frmcadret).val();
	var dsretorn = $('#dsretorn','#'+frmcadret).val();
	
	if(rotina != undefined){
		operacao = rotina;
	}else{
		operacao = cddopcao;
	}
	
	if((cddopcao == "I" || cddopcao == "A") && (cdretorn == "" || cdretorn == "0")){
		showError("error","Código de retorno inválido.","Alerta - Ayllos","hideMsgAguardo();focaCampoErro('cdretorn','frmcadret');");
		return false;
	}
	
	if((cddopcao == "I" || cddopcao == "A1") && dsretorn == ""){
		showError("error","Descrição de retorno inválido.","Alerta - Ayllos","hideMsgAguardo();focaCampoErro('dsretorn','frmcadret');");
		return false;
	}
	
	window.focus();
	
		 if(cddopcao == "C")  msgaguardo = "carregando";
	else if(cddopcao == "I")  msgaguardo = "cadastrando";
	else if(cddopcao == "A")  msgaguardo = "carregando";
	else if(cddopcao == "A1") msgaguardo = "alterando";
	else 					  msgaguardo = "carregando";
	
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, "+msgaguardo+" ...");
	
	$.ajax({		
		type: "POST",
		dataType: "html",
		url: UrlSite + "telas/cadret/manter_rotina.php", 
		data: {
			cddopcao: cddopcao,
		    cdprodut: cdprodut,
			operacao: operacao,
			cdoperac: cdoperac,
			nrtabela: nrtabela,
			cdretorn: cdretorn,
			dsretorn: dsretorn,
			redirect: "html_ajax"
		}, 
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
		success: function(response) {
			try {
				$('#divRetorno').html(response);
				if(cddopcao == "C"){
					layoutConsulta();
				}
			} catch(error) {
				hideMsgAguardo();
				showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}				
	});	
}

function layoutConsulta() {
	
	altura  = '195px';
	largura = '425px';

	// Configurações da tabela
	var divRegistro = $('div.divRegistros');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
		
	divRegistro.css('height','180px');
		
	var ordemInicial = new Array();
	ordemInicial = [[0,0]];
			
	if ( $.browser.msie ) {	
		
		var arrayLargura = new Array();
		arrayLargura[0] = '60px';
		arrayLargura[1] = '';
	} else {
		var arrayLargura = new Array();
		arrayLargura[0] = '60px';
		arrayLargura[1] = '';
	}	
	
	var arrayAlinha = new Array();
		arrayAlinha[0] = 'right';
		arrayAlinha[1] = 'left';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );		
	
	divRotina.css('width',largura);	
	$('#divRotina').css({'height':altura,'width':largura});
	
	layoutPadrao();	
	hideMsgAguardo();
	removeOpacidade('#divRegistros');
}

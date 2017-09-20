//*********************************************************************************************//
//*** Fonte: tab098.js                                                 						***//
//*** Autor: Ricardo Linhares                                          						***//
//*** Data : Dezembro/2016                  Última Alteração: --/--/----  					***//
//***                                                                  						***//
//*** Objetivo  : Biblioteca de funções da tela TAB098                 						***//
//***                                                                  						***//	 
//*** Alterações: 01/08/2017 - Excluir campos para habilitar contigencia e rollout e    	***//	 
//***                           incluir campo para valor limite. PRJ340-NPC (Odirlei-AMcom) ***//	  
//***                           									                        ***//
//*********************************************************************************************//

var cCddopcao;
var cCdcooper;
var frmCab = 'frmCab';
var frmTab098 = 'frmTab098';
var cTodos;
var cddopcao = 'C';
var cTodosCabecalho;

$(document).ready(function() {

    estadoInicial();

    highlightObjFocus($('#frmCab'));

    $('fieldset > legend').css({'font-size': '11px', 'color': '#777', 'margin-left': '5px', 'padding': '0px 2px'});
    $('fieldset').css({'clear': 'both', 'border': '1px solid #777', 'margin': '3px 0px', 'padding': '10px 3px 5px 3px'});

});

function estadoInicial() {

    $('#divTela').fadeTo(0, 0.1);
    $('#frmCab').css({'display': 'block'});
    $('#divMsgAjuda').css('display', 'none');
    $('#divBotao').css('display', 'none');
    $('#divFormulario').html('');

    formataCabecalho();

    cTodosCabecalho.habilitaCampo();

    removeOpacidade('divTela');
    unblockBackground();
    hideMsgAguardo();

    $("#cddopcao", "#frmCab").val('C').focus();
}

function formataCabecalho() {

    cTodosCabecalho = $('input[type="text"],select', '#' + frmCab);

    var cddopcao = $("#cddopcao", "#frmCab").val();

    var rCddopcao = $('label[for="cddopcao"]', '#frmCab');
    var rCdcooper = $('label[for="cdcooper"]', '#frmCab');

    rCddopcao.css('width', '50px').addClass('rotulo');
    rCdcooper.css('width', '80px').addClass('rotulo-linha');

    cCddopcao = $('#cddopcao', '#frmCab');
    cCddopcao.css('width', '330px');

    cCdcooper = $('#cdcooper', '#frmCab');

    var ehCentral = cCdcooper.length > 0;

    if(ehCentral) {
        cCdcooper.html(slcooper);
        cCdcooper.css('width', '125px').attr('maxlength', '2');
    } else {
        cCddopcao.css('width', '565px');
    }

    cCddopcao.unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 13 || e.keyCode == 9 || e.KeyCode == 18) {
            cCdcooper.focus();
            return false;
        }
    });

    cCddopcao.unbind('changed').bind('changed', function(e) {
        cCdcooper.focus();
        return false;
    });

    if(ehCentral) {

        cCdcooper.unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 13) {
                carregarDados();
                return false;
            }
        });

        cCdcooper.unbind('changed').bind('changed', function(e) {
            carregarDados();
            return false;
        });
    }
}


function btnOK() {
    carregarDados();
}

function formataFormulario(cddopcao) {

    cTodosFormulario = $('input[type="text"],input[type="checkbox"],select', '#frmTab098');
    highlightObjFocus($('#frmTab098'));

    $('#frmTab098').css('display', 'block');
    $('#divMsgAjuda').css('display', 'block');
    $('#btVoltar', '#divMsgAjuda').show();

    //opção de alteração
    if(cddopcao == 'A') {
        cTodosFormulario.habilitaCampo();
        $("#btAlterar", "#divMsgAjuda").show();    
    } else {
         cTodosFormulario.desabilitaCampo();
        $("#btAlterar", "#divMsgAjuda").hide();    
    }

    layoutPadrao();

}

// Botao Voltar
function btnVoltar() {
    estadoInicial();
}

function carregarDados() {
	
    var cddopcao = $("#cddopcao", "#frmCab").val();
    var cdcooper = $('#cdcooper', '#frmCab').val();

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        dataType: 'html',
        url: UrlSite + "telas/tab098/obtem_consulta.php",
        data: {
            cddopcao: cddopcao,
            cdcooper: cdcooper,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
        },
        success: function(response) {
            if (response.substr(0, 14) == 'hideMsgAguardo') {
                eval(response);
            } else {
                $('#divFormulario').html(response);
                $('#divPesquisaRodape', '#frmTab098').formataRodapePesquisa();
                hideMsgAguardo();
                formataFormulario(cddopcao);
            }
		}
    });

    return false;

}

function alterarDados() {
    showConfirmacao('Confirma a atualiza&ccedil;&atilde;o dos par&acirc;metros?', 'Tab098', 'grava_dados();', 'voltaDiv();estadoInicial();', 'sim.gif', 'nao.gif');
}

function abreTelAlteracao(dsvalor) {
    $('#hdnvalor', '#frmTab098').val(dsvalor);
    executarAcao('ALT_UFNegDif');
}

function grava_dados() {

    // Campos de parametrizacao
    var cdcooper = $('#cdcooper', '#frmCab').val();
    var vlcontig_cip = $('#vlcontig_cip','#frmTab098').val();    
    var prz_baixa_cip = $('#prz_baixa_cip','#frmTab098').val();
    var vlvrboleto = $('#vlvrboleto','#frmTab098').val();

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, enviando informa&ccedil;&otilde;es ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/tab098/grava_dados.php",
        data: {
            cdcooper                : cdcooper,
            vlcontig_cip            : vlcontig_cip,
            prz_baixa_cip           : prz_baixa_cip,
            vlvrboleto              : vlvrboleto,
            redirect             : "script_ajax" // Tipo de retorno do ajax
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
        },
        success: function(response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
            }
        }
    });
}


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
            if (cCdcooper.length == 1) {
                cCdcooper.focus();
            } else {
                btnOK();
            }
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

    $('label[for="sit_pag_divergente"]', '#frmTab098').css({'width':'309px'}).addClass('rotulo');
    $('#sit_pag_divergente', '#frmTab098').addClass('rotulo-linha').css({'width':'135px'});
    
    $('label[for="pag_a_menor"]', '#frmTab098').css({'width':'309px'}).addClass('rotulo');
    $('#pag_a_menor', '#frmTab098').addClass('rotulo-linha');
    
    $('label[for="pag_a_maior"]', '#frmTab098').css({'width':'309px'}).addClass('rotulo');
    $('#pag_a_maior', '#frmTab098').addClass('rotulo-linha');
    
    $('label[for="tip_tolerancia"]', '#frmTab098').css({'width':'309px'}).addClass('rotulo');
    $('#tip_tolerancia', '#frmTab098').addClass('rotulo-linha').css({'width':'135px'});
    
    $('label[for="vl_tolerancia"]', '#frmTab098').css({'width':'309px'}).addClass('rotulo');
    $('#vl_tolerancia', '#frmTab098').addClass('rotulo-linha');
    
    $("#dtcadast", "#frmTab098").css({'width':'150px'});
    
    let vl_tolerancia = $('#vl_tolerancia', '#frmTab098').val();
    
	  $('#tip_tolerancia', '#frmTab098').unbind('change').bind('change',function() {
        if ($('#tip_tolerancia', '#frmTab098').val() == 1) { // VALOR
            $('#vl_tolerancia', '#frmTab098').removeClass('porcento').addClass('moeda').val('0');
            $('#simbolo_percentual', '#frmTab098').hide();
            layoutPadrao();
        } else { // PERCENTUAL
            $('#vl_tolerancia', '#frmTab098').removeClass('moeda').addClass('porcento').val('0');
            $('#simbolo_percentual', '#frmTab098').show();
            layoutPadrao();
        }
		    return false;
    });
    
    $('#tip_tolerancia', '#frmTab098').trigger('change');
    $('#vl_tolerancia', '#frmTab098').val(vl_tolerancia);
    
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
    var sit_pag_divergente = $('#sit_pag_divergente', '#frmTab098').val() == 1;
    var pag_a_menor = $('#pag_a_menor', '#frmTab098').prop('checked');
    var pag_a_maior = $('#pag_a_maior', '#frmTab098').prop('checked');
    
    if (sit_pag_divergente && !pag_a_menor && !pag_a_maior) {
		showError('error','Selecione pelo menos uma forma de devolu&ccedil;&atilde;o.','Alerta - Ayllos','hideMsgAguardo();');
		return false;
    }
    
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

    var sit_pag_divergente = $('#sit_pag_divergente', '#frmTab098').val();
    var pag_a_menor = $('#pag_a_menor', '#frmTab098').prop('checked') ? 1 : 0 ;
    var pag_a_maior = $('#pag_a_maior', '#frmTab098').prop('checked') ? 1 : 0 ;
    var tip_tolerancia = $('#tip_tolerancia', '#frmTab098').val();
    var vl_tolerancia = $('#vl_tolerancia', '#frmTab098').val();
    
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
            sit_pag_divergente      : sit_pag_divergente,
            pag_a_menor             : pag_a_menor,
            pag_a_maior             : pag_a_maior,
            tip_tolerancia          : tip_tolerancia,
            vl_tolerancia           : vl_tolerancia,
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


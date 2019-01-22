/*
 * FONTE        : cerisc.js
 * CRIAÇÃO      : Douglas Pagel - AMcom
 * DATA CRIAÇÃO : 06/11/2018
 * OBJETIVO     : Biblioteca de funções da tela CERISC
 * ---------------
 * ALTERAÇÕES
 *                
 *
 * ---------------
 */

// Variáveis Globais 
var operacao = '';
var cddopcao = '';

var frmCab = 'frmCab';

var cTodosCabecalho = '';
var cTodosFiltro = '';

var abaAtual = '';

$(document).ready(function() {

    estadoInicial();
});

// Controles
function estadoInicial() {
    // Variáveis Globais
    operacao = '';

    hideMsgAguardo();

    fechaRotina($('#divRotina'));

    // Habilita foco no formulário inicial
    highlightObjFocus($('#frmCab'));
    highlightObjFocus($('#frmCERISC'));

    // Atribuir destaque para a primeira aba
    $('#linkAba0').attr('class','txtBrancoBold');
    $('#imgAbaCen0').css('background-color','#969FA9');

    // Acessar a primeira aba
    acessaAbaParametros();

    $('#cddopcao', '#frmCab').val('C');
}

function formataCabecalho() {

    cTodosCabecalho = $('input[type="text"],select', '#' + frmCab);

    // Cabeçalho
    rCddopcao = $('label[for="cddopcao"]', '#frmCab');

    rCddopcao.css('width', '42px');

    cCddopcao = $('#cddopcao', '#frmCab');

    cCddopcao.css({'width': '350px'});

    cTodosCabecalho.habilitaCampo();

    $('#divBotoes').hide();
    $('#divConteudoOpcao').html('');

    return false;
}

function formataCampos() {
	$('.labelPri', '#frmCERISC').css('width', '480px');
     
	$('#tituloO', '#frmCERISC').css('width', '390px');
	$('#tituloC', '#frmCERISC').css('width', '160px');

    cPercliq = $('#percliq', '#frmCERISC');    
    cPerccob = $('#perccob', '#frmCERISC'); 
    cNivel = $('#nivel', '#frmCERISC');  
    
	
    //Máscara para porcentagem
    cPerccob.css('width', '50px').setMask('DECIMAL','zzz,zz','','');
    cPercliq.css('width', '50px').setMask('DECIMAL', 'zzz,zz', '', '');
    cNivel.css('width', '50px');
    
    cTodosFiltro = $('input[type="text"],select', '#frmCERISC');
    // Limpa formulário
    cTodosFiltro.limpaFormulario();
    cTodosFiltro.habilitaCampo();

    layoutPadrao();
    controlaFoco();
    removeOpacidade('divTela');

    return false;
}

function controlaFoco() {
    $('#cddopcao', '#frmCab').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#btnOK', '#frmCab').focus();
            return false;
        }
    });
   
    $('#btnOK', '#frmCab').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            controlaOperacao();
            return false;
        }
    });
	
}

function controlaOperacao() {
    if ($('#cddopcao', '#frmCab').hasClass('campoTelaSemBorda')) {
        return false;
    }

    cddopcao = $('#cddopcao', '#frmCab').val();
    
    // Desabilita campo opção
    cTodosCabecalho = $('input[type="text"],select', '#frmCab');
    cTodosCabecalho.desabilitaCampo();

    if (abaAtual == 'parametros') {
        if (cddopcao == 'C') {
            mostraConsultaParametros('C');
    } else {
            mostraConsultaParametros('AC');
    }
    } 
             
    return false;
}

function manterRotina(cddopcao) {
    hideMsgAguardo();
	
    var cPercliq = normalizaNumero($('#percliq', '#frmCERISC').val());	
	var cPerccob = normalizaNumero($('#perccob', '#frmCERISC').val());
    var cnivel = $('#nivel'  ,'#frmCERISC').val();
	

    var mensagem = 'Aguarde, efetuando solicitação...';
    showMsgAguardo(mensagem);

    $.ajax({
        type: 'POST',
        async: true,
        url: UrlSite + 'telas/cerisc/manter_rotina.php',
        data: {
            cddopcao  : cddopcao,
            prperliq : cPercliq,
            prpercob : cPerccob,
            prnivelr : cnivel,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Aimaro', 'estadoInicial();');
        },
        success: function(response) {
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    eval(response);
			
                    if (cddopcao == 'C') {
                        liberaCampos();
                        hideMsgAguardo();
                    }
                    else if (cddopcao == 'AC') { // Alteração e Consulta
                        liberaCampos();
                        hideMsgAguardo();
                    }
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Aimaro', 'unblockBackground()');
                }
            } else {
                try {
                    eval(response);

                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Aimaro', 'unblockBackground()');
                }
            }
        }
    });

    return false;
}

function liberaCampos() {
    $('#frmCERISC').show();
    $('#divBotoes').show();

    cTodosFiltro.desabilitaCampo();

    if ($('#cddopcao', '#frmCab').val() == 'A') {
        cTodosFiltro.habilitaCampo();
		
    }

    $('#prtlmult', '#frmCERISC').focus();

    if ($('#cddopcao', '#frmCab').val() == 'C') {
        $("#btContinuar", "#divBotoes").hide();
    } else {
        $("#btContinuar", "#divBotoes").show();
    }

    return false;
}

function alteracaoMensagem() {
    hideMsgAguardo();

    return false;
}

function confirmaOperacao() {   
    if (validarCampos()){
        showConfirmacao('Confirma a Opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'executar();', '', 'sim.gif', 'nao.gif');
    }

    return false;	
}

function validarCampos() {	
	return true;	
}

function executar() {
    var operacao = $('#cddopcao', '#frmCab').val();
    manterRotina(operacao);

    return false;
} 

function controlarAbas(idAba) {

    for (var i = 0; i <= 2; i++) {
        if ($('#linkAba' + idAba).length == false) {
            continue;
        }
                
        if (idAba == i) {   
            // Atribui estilo de destaque para a aba selecionada 
            $('#linkAba'   + idAba).attr('class','txtBrancoBold');
            $('#imgAbaCen' + idAba).css('background-color','#969FA9');
            continue;           
        }
        
        // Remove estilo de destaque das outras abas 
        $('#linkAba'   + i).attr('class','txtNormalBold');
        $('#imgAbaCen' + i).css('background-color','#C6C8CA');
    }
}


function desbloqueia() {
    cTodosCabecalho.habilitaCampo();
    $('#frmTab089').hide();
    $('#divBotoes').hide();

    return false;
}

function acessaAbaParametros(){

    // 0 = aba parametros
    controlarAbas(0);
    abaAtual = 'parametros';
    
    $.ajax({        
        type: "POST",
        url: UrlSite + "telas/cerisc/form_cabecalho_parametros.php", 
        data: {
            redirect: "html_ajax" // Tipo de retorno do ajax
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
        },
        success: function(response) {
            $("#divCabecalho").html(response);
            formataCabecalho();
        }
    });
}

function mostraConsultaParametros(operacao){
    
    $.ajax({        
        type: "POST",
        url: UrlSite + "telas/cerisc/form_cerisc.php", 
        data: {
            redirect: "html_ajax" // Tipo de retorno do ajax
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
        },
        success: function(response) {
            $("#divConteudoOpcao").html(response);
            manterRotina(operacao);
            formataCampos();
        }
    });
}
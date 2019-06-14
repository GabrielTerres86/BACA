/*
 * FONTE        : tab049.js
 * CRIAÇÃO      : Márcio(Mouts)
 * DATA CRIAÇÃO : 08/2018
 * OBJETIVO     : Biblioteca de funções da tela TAB049
 * ---------------
 * ALTERAÇÕES
  * ---------------
 */

// Variáveis Globais 
var operacao = '';

var frmCab = 'frmCab';

var cTodosCabecalho = '';
var cTodosFiltro = '';

$(document).ready(function() {
    cTodosCabecalho = $('input[type="text"],select', '#' + frmCab);
    cTodosFiltro = $('input[type="text"],select', '#frmTab049');

    estadoInicial();
});

// Controles
function estadoInicial() {
    // Variáveis Globais
    operacao = '';

    hideMsgAguardo();

    fechaRotina($('#divRotina'));

    // Limpa formulários
    cTodosCabecalho.limpaFormulario();
    cTodosFiltro.limpaFormulario();

    // Habilita foco no formulário inicial
    highlightObjFocus($('#frmCab'));
    highlightObjFocus($('#frmTab049'));

    // Aplicar Formatação
    controlaLayout();

    $('#cddopcao', '#frmCab').val('C');
}

function controlaLayout() {
    $('#divTela').fadeTo(0, 0.1);
    $('fieldset').css({
        'clear': 'both', 
        'border': '1px solid #777', 
        'margin': '3px 0px', 
        'padding': '10px 3px 5px 3px'
    });
    $('fieldset > legend').css({
        'font-size': '12px', 
        'color': '#333', 
        'margin-left': '5px', 
        'padding': '0px 2px'
    });
    $('#divBotoes').css({
        'text-align': 'center', 
        'padding-top': '5px'
    });

    $('#frmTab049').hide();
    $('#divBotoes').hide();

    formataCabecalho();
    formataCampos();

    layoutPadrao();
    controlaFoco();
    removeOpacidade('divTela');

    $('#cddopcao', '#frmCab').focus();

    return false;
}

function formataCabecalho() {
    // Cabeçalho
    rCddopcao = $('label[for="cddopcao"]', '#frmCab');
    rInpessoa = $('label[for="inpessoa"]', '#frmCab');

    rCddopcao.css('width', '42px');
    rInpessoa.css('width', '100px');

    cCddopcao = $('#cddopcao', '#frmCab');
    cInpessoa = $('#inpessoa', '#frmCab');

    cCddopcao.css({'width': '350px'});
    cInpessoa.css({'width': '80px'});

    btnCab = $('#btOK', '#frmCab');

    cTodosCabecalho.habilitaCampo();

    return false;
}

function formataCampos() {
	$('.labelPri', '#frmTab049').css('width', '250px');
     
	$('#tituloO', '#frmTab049').css('width', '390px');
	$('#tituloC', '#frmTab049').css('width', '160px');
	
    cvalormin = $('#valormin', '#frmTab049'); 
    cvalormax = $('#valormax', '#frmTab049'); 
    cdatadvig = $('#datadvig', '#frmTab049'); 
    cpgtosegu = $('#pgtosegu', '#frmTab049'); 
    cvallidps = $('#vallidps', '#frmTab049'); 
    csubestip = $('#subestip', '#frmTab049'); 
    csglarqui = $('#sglarqui', '#frmTab049'); 
    cnrsequen = $('#nrsequen', '#frmTab049'); 

    //Máscara para moedas (Valor Monetário)
    cvalormin.css('width', '100px').addClass('moeda').setMask('DECIMAL', 'zzz.zzz.zzz,zz', '', ''); 
    cvalormax.css('width', '100px').addClass('moeda').setMask('DECIMAL', 'zzz.zzz.zzz,zz', '', ''); 
    cvallidps.css('width', '100px').addClass('moeda').setMask('DECIMAL', 'zzz.zzz.zzz,zz', '', '');    	
    cpgtosegu.css('width', '100px').css('text-align', 'right').attr('alt', 'p1x0c5a').autoNumeric().trigger('blur');
    
	cdatadvig.css({width:'70px'}).attr('maxlength','10');	
    
	csubestip.css({width:'200px'}).attr('maxlength','25');	
	csglarqui.css({width:'30px'}).attr('maxlength','2');	
	cnrsequen.css('width', '50px').setMask('INTEGER','zzzzz','','');
    
    cTodosFiltro.habilitaCampo();

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

    $('#valormin', '#frmTab049').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {

            $('#valormax', '#frmTab049').focus();
            return false;
        }
    });

    $('#valormax', '#frmTab049').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#datadvig', '#frmTab049').focus();
            return false;
        }
    });

    $('#datadvig', '#frmTab049').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#pgtosegu', '#frmTab049').focus();
            return false;
        }
    });

    $('#pgtosegu', '#frmTab049').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#vallidps', '#frmTab049').focus();
            return false;
        }
    });

    $('#vallidps', '#frmTab049').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#subestip', '#frmTab049').focus();
            return false;
        }
    });


    $('#subestip', '#frmTab049').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#sglarqui', '#frmTab049').focus();
            return false;
        }
    });

    $('#sglarqui', '#frmTab049').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#nrsequen', '#frmTab049').focus();
            return false;
        }
    });

    $('#nrsequen', '#frmTab049').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#valormin', '#frmTab049').focus();
            return false;
        }
    });
	
}

function controlaOperacao() {
    if ($('#cddopcao', '#frmCab').hasClass('campoTelaSemBorda')) {
        return false;
    }

    formataCampos();
    
    // Desabilita campo opção
    cTodosCabecalho = $('input[type="text"],select', '#frmCab');
    cTodosCabecalho.desabilitaCampo();

    // Apenas quando for alteração
    if ($('#cddopcao', '#frmCab').val() == 'C') {
        manterRotina('C');
    } else {
        manterRotina('AC');
    }
             
    return false;
}

function manterRotina(cddopcao) {
    hideMsgAguardo();
    
    var cvalormin = normalizaNumero($('#valormin', '#frmTab049').val());	
    var cvalormax = normalizaNumero($('#valormax', '#frmTab049').val());	
    var cdatadvig = $('#datadvig'  ,'#frmTab049').val();
    var cpgtosegu = normalizaNumero($('#pgtosegu', '#frmTab049').val());	
    var cvallidps = normalizaNumero($('#vallidps', '#frmTab049').val());	
    var csubestip = $('#subestip'  ,'#frmTab049').val();
    var csglarqui = $('#sglarqui'  ,'#frmTab049').val();
    var cnrsequen = $('#nrsequen'  ,'#frmTab049').val();

    var mensagem = 'Aguarde, efetuando solicita&ccedil;&atilde;o...';
    showMsgAguardo(mensagem);

    $.ajax({
        type: 'POST',
        async: true,
        url: UrlSite + 'telas/tab049/manter_rotina.php',
        data: {
            cddopcao  : cddopcao,
            valormin : cvalormin,
            valormax : cvalormax,
            datadvig : cdatadvig,
            pgtosegu : cpgtosegu,
            vallidps : cvallidps,
            subestip : csubestip,
            sglarqui : csglarqui,
            nrsequen : cnrsequen,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
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
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            } else {
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

function liberaCampos() {
    $('#frmTab049').show();
    $('#divBotoes').show();

    cTodosFiltro.desabilitaCampo();

    if ($('#cddopcao', '#frmCab').val() == 'A') {
        cTodosFiltro.habilitaCampo();
    }

    $('#prtlmult', '#frmTab049').focus();

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
    if ($('#valormin', '#frmTab049').val() == null || $('#valormin', '#frmTab049').val() == "") {
         showError('error', 'Valor m&iacute;nimo &eacute; obrigat&oacute;rio!', 'Alerta - Ayllos', '');
	     return false;
    }
	
    if ($('#valormax', '#frmTab049').val() == null || $('#valormax', '#frmTab049').val() == "") {
         showError('error', 'Valor m&aacuteximo &eacute; obrigat&oacute;rio!', 'Alerta - Ayllos', '');
	     return false;
    }
 	
    if ($('#datadvig', '#frmTab049').val() == null || $('#datadvig', '#frmTab049').val() == "") {
         showError('error', 'Data de in&iacute;cio da vig&ecirc;ncia &eacute; obrigat&oacute;ria!', 'Alerta - Ayllos', '');
	     return false;
    }
    if ($('#pgtosegu', '#frmTab049').val() == null || $('#pgtosegu', '#frmTab049').val() == "") {
         showError('error', 'Pagamento seguradora &eacute; obrigat&oacute;rio!', 'Alerta - Ayllos', '');
	     return false;
    }
    if ($('#vallidps', '#frmTab049').val() == null || $('#vallidps', '#frmTab049').val() == "") {
         showError('error', 'Valor limite para impressão DPS &eacute; obrigat&oacute;rio!', 'Alerta - Ayllos', '');
	     return false;
    }
    if ($('#subestip', '#frmTab049').val() == null || $('#subestip', '#frmTab049').val() == "") {
         showError('error', 'Substipulante &eacute; obrigat&oacute;rio!', 'Alerta - Ayllos', '');
	     return false;
    }
    if ($('#sglarqui', '#frmTab049').val() == null || $('#sglarqui', '#frmTab049').val() == "") {
         showError('error', 'Sigla do arquivo &eacute; obrigat&oacute;ria!', 'Alerta - Ayllos', '');
	     return false;
    }
    if ($('#nrsequen', '#frmTab049').val() == null || $('#nrsequen', '#frmTab049').val() == "") {
         showError('error', 'Sequencia &eacute; obrigat&oacute;ria!', 'Alerta - Ayllos', '');
	     return false;
    }

	return true;	
}

function executar() {
    var operacao = $('#cddopcao', '#frmCab').val();
    manterRotina(operacao);

    return false;
} 

function desbloqueia() {
    cTodosCabecalho.habilitaCampo();
    $('#frmTab049').hide();
    $('#divBotoes').hide();

    return false;
}

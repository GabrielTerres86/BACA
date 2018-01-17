/*
 * FONTE        : tab089.js
 * CRIAÇÃO      : Diego Simas/Reginaldo Silva/Letícia Terres - AMcom
 * DATA CRIAÇÃO : 12/01/2018
 * OBJETIVO     : Biblioteca de funções da tela TAB089
 */

// Variáveis Globais 
var operacao = '';
var frmCab = 'frmCab';
var cTodosCabecalho = '';
var cTodosFiltro = '';

$(document).ready(function() {
    cTodosCabecalho = $('input[type="text"],select', '#' + frmCab);
    cTodosFiltro = $('input[type="text"],select', '#frmTab089');

    estadoInicial();
});

// Controles
function estadoInicial() {
    operacao = '';

    hideMsgAguardo();

    fechaRotina($('#divRotina'));

    // Limpa formulários
    cTodosCabecalho.limpaFormulario();
    cTodosFiltro.limpaFormulario();

    // Habilita foco no formulário inicial
    highlightObjFocus($('#frmCab'));
    highlightObjFocus($('#frmTab089'));

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

    $('#frmTab089').hide();
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
    $('label[for="cddopcao"]', '#frmCab')
        .css('width', '42px');

    $('#cddopcao', '#frmCab')
        .css({'width': '350px'});
  
    btnCab = $('#btOK', '#frmCab');

    cTodosCabecalho.habilitaCampo();

    return false;
}

function formataCampos() {
	$('.labelPri', '#frmTab089')
        .css('width', '480px');
     
	$('#tituloO', '#frmTab089')
        .css('width', '390px');
	$('#tituloC', '#frmTab089')
        .css('width', '160px');

    //Máscara para quantidade de dias
    $('#prtlmult, #prestorn, #pzmaxepr, #qtdpaimo, #qtdpaaut, #qtdpaava, ' +
        '#qtdpaapl, #qtdpasem, #qtdibaut, #qtdibapl, #qtdibsem', '#frmTab089')
        .addClass('int_40px_3d');
    $('.int_40px_3d')
        .css('width', '40px')
        .setMask('INTEGER', 'zzz', '', '');
    //Máscara para porcentagem
    $('#pcaltpar', '#frmTab089')
        .css('width', '50px')
        .setMask('DECIMAL','zzz,zz','','');
    //Máscara para moedas (Valor Monetário)
    $('#vlempres, #vlmaxest, #vltolemp', '#frmTab089')
        .addClass('moeda')
        .css('width', '100px')
        .setMask('DECIMAL', 'zzz.zzz.zzz,zz', '', '');        
    
    cTodosFiltro.habilitaCampo();

    return false;
}

function bindKeyPress(elemToWatch, elemToFocus)
{
    elemToWatch.unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            elemToFocus.focus();
            return false;
        }
    });   
}

function controlaFoco() {
    $('#btnOK', '#frmCab').unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            controlaOperacao();
            return false;
        }
    });

    bindKeyPress($('#cddopcao', '#frmCab'), $('#btnOK', '#frmCab'));
    bindKeyPress($('#prtlmult', '#frmTab089'), $('#prestorn', '#frmTab089'));
    bindKeyPress($('#prestorn', '#frmTab089'), $('#prpropos', '#frmTab089'));
    bindKeyPress($('#prpropos', '#frmTab089'), $('#vlempres', '#frmTab089'));
    bindKeyPress($('#vlempres', '#frmTab089'), $('#pzmaxepr', '#frmTab089'));
    bindKeyPress($('#pzmaxepr', '#frmTab089'), $('#vlmaxest', '#frmTab089'));
    bindKeyPress($('#vlmaxest', '#frmTab089'), $('#pcaltpar', '#frmTab089'));
    bindKeyPress($('#pcaltpar', '#frmTab089'), $('#vltolemp', '#frmTab089'));
    bindKeyPress($('#vltolemp', '#frmTab089'), $('#qtdpaimo', '#frmTab089'));
    bindKeyPress($('#qtdpaimo', '#frmTab089'), $('#qtdpaaut', '#frmTab089'));
    bindKeyPress($('#qtdpaaut', '#frmTab089'), $('#qtdpaava', '#frmTab089'));
    bindKeyPress($('#qtdpaava', '#frmTab089'), $('#qtdpaapl', '#frmTab089'));
    bindKeyPress($('#qtdpaapl', '#frmTab089'), $('#qtdpasem', '#frmTab089'));
    bindKeyPress($('#qtdpasem', '#frmTab089'), $('#qtdibaut', '#frmTab089'));
    bindKeyPress($('#qtdibaut', '#frmTab089'), $('#qtdibapl', '#frmTab089'));
    bindKeyPress($('#qtdibapl', '#frmTab089'), $('#qtdibsem', '#frmTab089'));
    bindKeyPress($('#qtdibsem', '#frmTab089'), $('#btContinuar', '#divBotoes'));
}

function controlaOperacao() {
    if ($('#cddopcao', '#frmCab').hasClass('campoTelaSemBorda')) {
        return false;
    }

    formataCampos();
    
    // Desabilita campo opção
    cTodosCabecalho.desabilitaCampo();

    cddopcao = ($('#cddopcao', '#frmCab').val() == 'C') ? 'C' : 'AC';
    manterRotina(cddopcao);
             
    return false;
}

function manterRotina(cddopcao) {
    hideMsgAguardo();
    showMsgAguardo('Aguarde, efetuando solicita&ccedil;&atilde;o...');

    $.ajax({
        type: 'POST',
        async: true,
        url: UrlSite + 'telas/tab089/manter_rotina.php',
        data: montaObjPostData(cddopcao),
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response) {            
            try {
                eval(response);

                if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                    liberaCampos();
                    hideMsgAguardo();
                }
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
            }
        }
    });

    return false;
}

function liberaCampos() {
    $('#frmTab089').show();
    $('#divBotoes').show();

    toggleEdicao($('#cddopcao', '#frmCab').val() == 'A');

    $('#prtlmult', '#frmTab089').focus();

    return false;
}

function toggleEdicao(active)
{
    if (active) {
        cTodosFiltro.habilitaCampo();
        $("#btContinuar", "#divBotoes").show();

        return false;
    } 

    cTodosFiltro.desabilitaCampo();
    $("#btContinuar", "#divBotoes").hide();

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
    manterRotina($('#cddopcao', '#frmCab').val());

    return false;
}

function montaObjPostData(cddopcao) {
    return {
        cddopcao: cddopcao,
        prtlmult: normalizaNumero($('#prtlmult', '#frmTab089').val()),
        prestorn: normalizaNumero($('#prestorn', '#frmTab089').val()),
        prpropos: $('#prpropos', '#frmTab089').val(),
        pzmaxepr: normalizaNumero($('#pzmaxepr', '#frmTab089').val()),
        qtdpaimo: normalizaNumero($('#qtdpaimo', '#frmTab089').val()),
        qtdpaaut: normalizaNumero($('#qtdpaaut', '#frmTab089').val()),
        qtdpaava: normalizaNumero($('#qtdpaava', '#frmTab089').val()),
        qtdpaapl: normalizaNumero($('#qtdpaapl', '#frmTab089').val()),
        qtdpasem: normalizaNumero($('#qtdpasem', '#frmTab089').val()),
        qtdibaut: normalizaNumero($('#qtdibaut', '#frmTab089').val()),
        qtdibapl: normalizaNumero($('#qtdibapl', '#frmTab089').val()),
        qtdibsem: normalizaNumero($('#qtdibsem', '#frmTab089').val()),
        vlempres: normalizaNumero($('#vlempres', '#frmTab089').val()),
        vlmaxest: normalizaNumero($('#vlmaxest', '#frmTab089').val()),
        vltolemp: normalizaNumero($('#vltolemp', '#frmTab089').val()),
        pcaltpar: normalizaNumero($('#pcaltpar', '#frmTab089').val()),
        redirect: 'script_ajax'
    };
}

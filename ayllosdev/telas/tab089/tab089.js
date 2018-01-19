/*
 * FONTE        : tab089.js
 * CRIAÇÃO      : Diego Simas/Reginaldo Silva/Letícia Terres - AMcom
 * DATA CRIAÇÃO : 12/01/2018
 * OBJETIVO     : Biblioteca de funções da tela TAB089
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
    cTodosFiltro = $('input[type="text"],select', '#frmTab089');

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
	$('.labelPri', '#frmTab089').css('width', '480px');
     
	$('#tituloO', '#frmTab089').css('width', '390px');
	$('#tituloC', '#frmTab089').css('width', '160px');

    cPrtlmult = $('#prtlmult', '#frmTab089');    
    cPrestorn = $('#prestorn', '#frmTab089'); 
    cPrpropos = $('#prpropos', '#frmTab089');  
    cPzmaxepr = $('#pzmaxepr', '#frmTab089'); 
    cQtdpaimo = $('#qtdpaimo', '#frmTab089');    
    cQtdpaaut = $('#qtdpaaut', '#frmTab089');    
    cQtdpaava = $('#qtdpaava', '#frmTab089');    
    cQtdpaapl = $('#qtdpaapl', '#frmTab089');    
    cQtdpasem = $('#qtdpasem', '#frmTab089');    
    cQtdibaut = $('#qtdibaut', '#frmTab089'); 
    cQtdibapl = $('#qtdibapl', '#frmTab089'); 
    cQtdibsem = $('#qtdibsem', '#frmTab089'); 
    cVlempres = $('#vlempres', '#frmTab089'); 
    cVlmaxest = $('#vlmaxest', '#frmTab089'); 
    cVltolemp = $('#vltolemp', '#frmTab089'); 
    cPcaltpar = $('#pcaltpar', '#frmTab089'); 

    //Máscara para quantidade de dias
    cPrtlmult.css('width', '40px').setMask('INTEGER','zzz','','');
    cPrestorn.css('width', '40px').setMask('INTEGER','zzz','','');
    cPzmaxepr.css('width', '40px').setMask('INTEGER','zzzz','','');
    cQtdpaimo.css('width', '40px').setMask('INTEGER','zzz','','');
    cQtdpaaut.css('width', '40px').setMask('INTEGER','zzz','','');
    cQtdpaava.css('width', '40px').setMask('INTEGER','zzz','','');
    cQtdpaapl.css('width', '40px').setMask('INTEGER','zzz','','');
    cQtdpasem.css('width', '40px').setMask('INTEGER','zzz','','');
    cQtdibaut.css('width', '40px').setMask('INTEGER','zzz','','');
    cQtdibapl.css('width', '40px').setMask('INTEGER','zzz','','');
    cQtdibsem.css('width', '40px').setMask('INTEGER','zzz','','');
    //Máscara para porcentagem
    cQtdibsem.css('width', '40px').setMask('INTEGER','zzz','','');
    cPcaltpar.css('width', '50px').setMask('DECIMAL','zzz,zz','','');
    //Máscara para moedas (Valor Monetário)
    cVlempres.css('width', '100px').addClass('moeda').setMask('DECIMAL', 'zzz.zzz.zzz,zz', '', ''); 
    cVlmaxest.css('width', '100px').addClass('moeda').setMask('DECIMAL', 'zzz.zzz.zzz,zz', '', ''); 
    cVltolemp.css('width', '100px').addClass('moeda').setMask('DECIMAL', 'zzz.zzz.zzz,zz', '', '');     
    
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

    $('#prtlmult', '#frmTab089').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {

            $('#prestorn', '#frmTab089').focus();
            return false;
        }
    });

    $('#prestorn', '#frmTab089').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#prpropos', '#frmTab089').focus();
            return false;
        }
    });

    $('#prpropos', '#frmTab089').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#vlempres', '#frmTab089').focus();
            return false;
        }
    });

    $('#vlempres', '#frmTab089').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#pzmaxepr', '#frmTab089').focus();
            return false;
        }
    });

    $('#pzmaxepr', '#frmTab089').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#vlmaxest', '#frmTab089').focus();
            return false;
        }
    });


    $('#vlmaxest', '#frmTab089').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#pcaltpar', '#frmTab089').focus();
            return false;
        }
    });

    $('#pcaltpar', '#frmTab089').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#vltolemp', '#frmTab089').focus();
            return false;
        }
    });

    $('#vltolemp', '#frmTab089').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtdpaimo', '#frmTab089').focus();
            return false;
        }
    });


    $('#qtdpaimo', '#frmTab089').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtdpaaut', '#frmTab089').focus();
            return false;
        }
    });

    $('#qtdpaaut', '#frmTab089').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtdpaava', '#frmTab089').focus();
            return false;
        }
    });

    $('#qtdpaava', '#frmTab089').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtdpaapl', '#frmTab089').focus();
            return false;
        }
    });

    $('#qtdpaapl', '#frmTab089').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtdpasem', '#frmTab089').focus();
            return false;
        }
    });

    $('#qtdpasem', '#frmTab089').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtdibaut', '#frmTab089').focus();
            return false;
        }
    });

    $('#qtdibaut', '#frmTab089').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {

            $('#qtdibapl', '#frmTab089').focus();
            return false;
        }
    });
        
    $('#qtdibapl', '#frmTab089').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtdibsem', '#frmTab089').focus();
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
	
    var cPrtlmult = normalizaNumero($('#prtlmult', '#frmTab089').val());	
	var cPrestorn = normalizaNumero($('#prestorn', '#frmTab089').val());
    var cPrpropos = $('#prpropos'  ,'#frmTab089').val();
	var cPzmaxepr = normalizaNumero($('#pzmaxepr', '#frmTab089').val());
    var cQtdpaimo = normalizaNumero($('#qtdpaimo', '#frmTab089').val());
    var cQtdpaaut = normalizaNumero($('#qtdpaaut', '#frmTab089').val());
    var cQtdpaava = normalizaNumero($('#qtdpaava', '#frmTab089').val());
    var cQtdpaapl = normalizaNumero($('#qtdpaapl', '#frmTab089').val());
    var cQtdpasem = normalizaNumero($('#qtdpasem', '#frmTab089').val());
    var cQtdibaut = normalizaNumero($('#qtdibaut', '#frmTab089').val());
    var cQtdibapl = normalizaNumero($('#qtdibapl', '#frmTab089').val());
    var cQtdibsem = normalizaNumero($('#qtdibsem', '#frmTab089').val());
    var cVlempres = normalizaNumero($('#vlempres', '#frmTab089').val());
    var cVlmaxest = normalizaNumero($('#vlmaxest', '#frmTab089').val());
    var cVltolemp = normalizaNumero($('#vltolemp', '#frmTab089').val());
    var cPcaltpar = normalizaNumero($('#pcaltpar', '#frmTab089').val());

    var mensagem = 'Aguarde, efetuando solicita&ccedil;&atilde;o...';
    showMsgAguardo(mensagem);

    $.ajax({
        type: 'POST',
        async: true,
        url: UrlSite + 'telas/tab089/manter_rotina.php',
        data: {
            cddopcao  : cddopcao,
            prtlmult : cPrtlmult,
            prestorn : cPrestorn,
            prpropos : cPrpropos,
            pzmaxepr : cPzmaxepr,
            qtdpaimo : cQtdpaimo,
            qtdpaaut : cQtdpaaut,
            qtdpaava : cQtdpaava,
            qtdpaapl : cQtdpaapl,
            qtdpasem : cQtdpasem,
            qtdibaut : cQtdibaut,
            qtdibapl : cQtdibapl,
            qtdibsem : cQtdibsem,
            vlempres : cVlempres,
            vlmaxest : cVlmaxest,
            vltolemp : cVltolemp,
            pcaltpar : cPcaltpar,
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
    $('#frmTab089').show();
    $('#divBotoes').show();

    cTodosFiltro.desabilitaCampo();

    if ($('#cddopcao', '#frmCab').val() == 'A') {
        cTodosFiltro.habilitaCampo();
    }

    $('#prtlmult', '#frmTab089').focus();

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

function desbloqueia() {
    cTodosCabecalho.habilitaCampo();
    $('#frmTab089').hide();
    $('#divBotoes').hide();

    return false;
}


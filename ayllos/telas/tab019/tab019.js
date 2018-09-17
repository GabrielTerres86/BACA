/*!
 * FONTE        : tab019.js
 * CRIAÇÃO      : Daniel Zimmermann/Odirlei Busana - AMcom
 * DATA CRIAÇÃO : 24/03/2016
 * OBJETIVO     : Biblioteca de funções da tela TAB019 
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */

// Variáveis Globais 
var operacao = '';

var frmCab = 'frmCab';

var cTodosCabecalho = '';
var cTodosFiltro = '';

$(document).ready(function() {

    cTodosCabecalho = $('input[type="text"],select', '#' + frmCab);
    cTodosFiltro = $('input[type="text"],select', '#frmTab019');

    estadoInicial();

});


// Controles
function estadoInicial() {

    // Variaveis Globais
    operacao = '';

    hideMsgAguardo();

    fechaRotina($('#divRotina'));

    // Limpa formularios
    cTodosCabecalho.limpaFormulario();
    cTodosFiltro.limpaFormulario();

    // habilita foco no formulário inicial
    highlightObjFocus($('#frmCab'));
    highlightObjFocus($('#frmTab019'));

    // Aplicar Formatação
    controlaLayout();

    $('#cddopcao', '#frmCab').val('C');

}

function controlaLayout() {

    $('#divTela').fadeTo(0, 0.1);
    $('fieldset').css({'clear': 'both', 'border': '1px solid #777', 'margin': '3px 0px', 'padding': '10px 3px 5px 3px'});
    $('fieldset > legend').css({'font-size': '11px', 'color': '#777', 'margin-left': '5px', 'padding': '0px 2px'});
    $('#divBotoes').css({'text-align': 'center', 'padding-top': '5px'});

    $('#frmTab019').css({'display': 'none'});
    $('#divBotoes').css({'display': 'none'});


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
	
	$('.labelPri', '#frmTab019').css('width', '300px');
	$('#tituloO', '#frmTab019').css('width', '390px');
	$('#tituloC', '#frmTab019').css('width', '160px');
	
    if ( $('#inpessoa', '#frmCab').val() == 1 ){
        document.getElementById("flemiparL").innerHTML = "Verificar se Emitente &eacute; Conjugue do Cooperado:";
        document.getElementById("vlrenlimL").innerHTML = "Renda x Limite Desconto:";
        
    } else{
        document.getElementById("flemiparL").innerHTML = "Verificar se Emitente &eacute; S&oacute;cio do Cooperado:";
        document.getElementById("vlrenlimL").innerHTML = "Faturamento x Limite Desconto:";
    }    

    cVllimite = $('#vllimite', '#frmTab019');
    cVlconchq = $('#vlconchq', '#frmTab019');
    cVlmaxemi = $('#vlmaxemi', '#frmTab019');
    cQtdiavig = $('#qtdiavig', '#frmTab019');
    cQtprzmin = $('#qtprzmin', '#frmTab019');
    cQtprzmax = $('#qtprzmax', '#frmTab019');
    cQtdiasoc = $('#qtdiasoc', '#frmTab019');
    cPcchqemi = $('#pcchqemi', '#frmTab019');
    cQtdevchq = $('#qtdevchq', '#frmTab019');
    cPcchqloc = $('#pcchqloc', '#frmTab019');
    cPctollim = $('#pctollim', '#frmTab019');
    cTxdmulta = $('#txdmulta', '#frmTab019');
    cQtdiasli = $('#qtdiasli', '#frmTab019');
    cHoralimt = $('#horalimt', '#frmTab019');
    cMinlimit = $('#minlimit', '#frmTab019');
    cFlemipar = $('#flemipar', '#frmTab019');
    cFlpjzemi = $('#flpjzemi', '#frmTab019');
    cFlemisol = $('#flemisol', '#frmTab019');
    cPrzmxcmp = $('#przmxcmp', '#frmTab019');  
    cPrcliqui = $('#prcliqui', '#frmTab019');     
    cQtmesliq = $('#qtmesliq', '#frmTab019');  
    cVlrenlim = $('#vlrenlim', '#frmTab019');  
    cQtmxrede = $('#qtmxrede', '#frmTab019');  
    cFldchqdv = $('#fldchqdv', '#frmTab019');  
    cVlmxassi = $('#vlmxassi', '#frmTab019');  
    

    cVllimite.css('width', '100px').addClass('moeda').addClass('editcooper');
    cVlconchq.css('width', '100px').addClass('moeda').addClass('editcooper');
    cVlmaxemi.css('width', '100px').addClass('moeda').addClass('editcooper');    
    cQtdiavig.css('width', '40px').setMask('INTEGER','zzz','','');
    cQtprzmin.css('width', '40px').addClass('editcooper').setMask('INTEGER','zzz','','');
    cQtprzmax.css('width', '40px').addClass('editcooper').setMask('INTEGER','zzz','','');
    cQtdiasoc.css('width', '40px').addClass('editcooper').setMask('INTEGER','zzz','','');
    cPcchqemi.css('width', '40px').addClass('editcooper').setMask('INTEGER','zzz','','');
    cQtdevchq.css('width', '40px').addClass('editcooper').setMask('INTEGER','zzz','','');
    cPcchqloc.css('width', '40px').addClass('editcooper').setMask('INTEGER','zzz','','');
    cPctollim.css('width', '40px').addClass('editcooper').setMask('INTEGER','zzz','','');    
    cTxdmulta.css('width', '80px').addClass('editcooper').css('text-align', 'right').attr('alt', 'p1x0c6a').autoNumeric().trigger('blur');
    
    cQtdiasli.css('width', '20px').addClass('editcooper').setMask('INTEGER','zz','','');
    cHoralimt.css('width', '25px').addClass('editcooper').setMask('INTEGER','zz','','');
    cMinlimit.css('width', '25px').addClass('editcooper').setMask('INTEGER','zz','','');
    
    cPrzmxcmp.addClass('editcooper').css('width', '40px').setMask('INTEGER','zzzz','','');   
    cFlemipar.addClass('editcooper');
    cFlpjzemi.addClass('editcooper');
    cFlemisol.addClass('editcooper');
    cPrcliqui.addClass('editcooper').css('width', '40px').setMask('INTEGER','zzz','','');   
    cQtmesliq.addClass('editcooper').css('width', '40px').setMask('INTEGER','zzz','','');   
    cVlrenlim.addClass('editcooper').css('width', '40px').setMask('INTEGER','zzzz','','');   
    cQtmxrede.addClass('editcooper').css('width', '40px').setMask('INTEGER','zzzz','','');   
    cFldchqdv.addClass('editcooper');   
    cVlmxassi.css('width', '100px').addClass('editcooper').addClass('moeda');              

    cVllimite_c = $('#vllimite_c', '#frmTab019');
    cVlconchq_c = $('#vlconchq_c', '#frmTab019');
    cVlmaxemi_c = $('#vlmaxemi_c', '#frmTab019');
    cQtdiavig_c = $('#qtdiavig_c', '#frmTab019');
    cQtprzmin_c = $('#qtprzmin_c', '#frmTab019');
    cQtprzmax_c = $('#qtprzmax_c', '#frmTab019');
    cQtdiasoc_c = $('#qtdiasoc_c', '#frmTab019');
    cPcchqemi_c = $('#pcchqemi_c', '#frmTab019');
    cQtdevchq_c = $('#qtdevchq_c', '#frmTab019');
    cPcchqloc_c = $('#pcchqloc_c', '#frmTab019');
    cPctollim_c = $('#pctollim_c', '#frmTab019');
    cTxdmulta_c = $('#txdmulta_c', '#frmTab019');
    cQtdiasli_c = $('#qtdiasli_c', '#frmTab019');
    cHoralimt_c = $('#horalimt_c', '#frmTab019');
    cMinlimit_c = $('#minlimit_c', '#frmTab019');
    cFlemipar_c = $('#flemipar_c', '#frmTab019');    
    cPrzmxcmp_c = $('#przmxcmp_c', '#frmTab019'); 
    cFlemipar_c = $('#flemipar_c', '#frmTab019');
    cFlpjzemi_c = $('#flpjzemi_c', '#frmTab019');
    cFlemisol_c = $('#flemisol_c', '#frmTab019');
    cPrcliqui_c = $('#prcliqui_c', '#frmTab019');     
    cQtmesliq_c = $('#qtmesliq_c', '#frmTab019');
    cVlrenlim_c = $('#vlrenlim_c', '#frmTab019');  
    cQtmxrede_c = $('#qtmxrede_c', '#frmTab019');  
    cFldchqdv_c = $('#fldchqdv_c', '#frmTab019');
    cVlmxassi_c = $('#vlmxassi_c', '#frmTab019');
    

    cVllimite_c.css('width', '100px').addClass('moeda').addClass('editcecred');
    cVlconchq_c.css('width', '100px').addClass('moeda');
    cVlmaxemi_c.css('width', '100px').addClass('moeda').addClass('editcecred');
    cQtdiavig_c.css('width', '40px').addClass('editcecred').setMask('INTEGER','zzz','','');
    cQtprzmin_c.css('width', '40px').setMask('INTEGER','zzz','','');
    cQtprzmax_c.css('width', '40px').addClass('editcecred').setMask('INTEGER','zzz','','');
    cQtdiasoc_c.css('width', '40px').setMask('INTEGER','zzz','','');
    cPcchqemi_c.css('width', '40px').setMask('INTEGER','zzz','','');
    cQtdevchq_c.css('width', '40px').setMask('INTEGER','zzz','','');
    cPcchqloc_c.css('width', '40px').setMask('INTEGER','zzz','','');
    cPctollim_c.css('width', '40px').addClass('editcecred').setMask('INTEGER','zzz','','');
    cTxdmulta_c.css('width', '80px').css('text-align', 'right').attr('alt', 'p1x0c6a').autoNumeric().trigger('blur');
    
    cQtdiasli_c.css('width', '20px').addClass('editcecred').setMask('INTEGER','zz','','');
    cHoralimt_c.css('width', '25px').addClass('editcecred').setMask('INTEGER','zz','','');
    cMinlimit_c.css('width', '25px').addClass('editcecred').setMask('INTEGER','zz','','');
    
    cPrzmxcmp_c.addClass('editcecred').css('width', '40px').setMask('INTEGER','zzzz','','');    
    cFlemipar_c.addClass('editcecred');
    cFlpjzemi_c.addClass('editcecred');
    cFlemisol_c.addClass('editcecred');
    cPrcliqui_c.addClass('editcecred').css('width', '40px').setMask('INTEGER','zzz','','');   
    cQtmesliq_c.addClass('editcecred').css('width', '40px').setMask('INTEGER','zzz','',''); 
    cVlrenlim_c.addClass('editcecred').css('width', '40px').setMask('INTEGER','zzzz','','');       
    cQtmxrede_c.addClass('editcecred').css('width', '40px').setMask('INTEGER','zzzz','','');   
    cFldchqdv_c.addClass('editcecred');   
    cVlmxassi_c.css('width', '100px').addClass('editcecred').addClass('moeda');     
    
    cTodosFiltro.habilitaCampo();

    return false;
}



function controlaFoco() {

    $('#cddopcao', '#frmCab').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#inpessoa', '#frmCab').focus();
            return false;
        }
    });

    $('#inpessoa', '#frmCab').unbind('keypress').bind('keypress', function(e) {
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

    $('#vllimite', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {

            $('#vlconchq', '#frmTab019').focus();
            return false;
        }
    });

    $('#vlconchq', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#vlmaxemi', '#frmTab019').focus();
            return false;
        }
    });

    $('#vlmaxemi', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtprzmin', '#frmTab019').focus();
            return false;
        }
    });

    $('#qtprzmin', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtprzmax', '#frmTab019').focus();
            return false;
        }
    });

    $('#qtprzmax', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtdiasoc', '#frmTab019').focus();
            return false;
        }
    });


    $('#qtdiasoc', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#pcchqemi', '#frmTab019').focus();
            return false;
        }
    });

    $('#pcchqemi', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtdevchq', '#frmTab019').focus();
            return false;
        }
    });

    $('#qtdevchq', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#pcchqloc', '#frmTab019').focus();
            return false;
        }
    });


    $('#pcchqloc', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#pctollim', '#frmTab019').focus();
            return false;
        }
    });

    $('#pctollim', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#txdmulta', '#frmTab019').focus();
            return false;
        }
    });

    $('#txdmulta', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtdiasli', '#frmTab019').focus();
            return false;
        }
    });

    $('#qtdiasli', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#horalimt', '#frmTab019').focus();
            return false;
        }
    });

    $('#horalimt', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#minlimit', '#frmTab019').focus();
            return false;
        }
    });

    $('#minlimit', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {

            $('#flemipar', '#frmTab019').focus();
            return false;
        }
    });
        
    $('#flemipar', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#przmxcmp', '#frmTab019').focus();
            return false;
        }
    });
    
    $('#przmxcmp', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#flpjzemi', '#frmTab019').focus();
            return false;
        }
    });
      
    $('#flpjzemi', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#flemisol', '#frmTab019').focus();
            return false;
        }
    });
          
      
    $('#flemisol', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#prcliqui', '#frmTab019').focus();
            return false;
        }
    });
    
    $('#prcliqui', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtmesliq', '#frmTab019').focus();
            return false;
        }
    });
    
    $('#qtmesliq', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#vlrenlim', '#frmTab019').focus();
            return false;
        }
    });
    
    $('#vlrenlim', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtmxrede', '#frmTab019').focus();
            return false;
        }
    });    
      
    $('#qtmxrede', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#fldchqdv', '#frmTab019').focus();
            return false;
        }
    });
      
    $('#fldchqdv', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#vlmxassi', '#frmTab019').focus();
            return false;
        }
    });
    
    $('#vlmxassi', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            confirmaOperacao();
            return false;
        }
    });    

    $('#vllimite_c', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#vlmaxemi_c', '#frmTab019').focus();
            return false;
        }
    });

    $('#vlmaxemi_c', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtdiavig_c', '#frmTab019').focus();
            return false;
        }
    });

    $('#qtdiavig_c', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtprzmax_c', '#frmTab019').focus();
            return false;
        }
    });

    $('#qtprzmax_c', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#pctollim_c', '#frmTab019').focus();
            return false;
        }
    });

    $('#pctollim_c', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtdiasli_c', '#frmTab019').focus();
            return false;
        }
    });

    $('#qtdiasli_c', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#horalimt_c', '#frmTab019').focus();
            return false;
        }
    });

    $('#horalimt_c', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#minlimit_c', '#frmTab019').focus();
            return false;
        }
    });

    $('#minlimit_c', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {

            $('#flemipar_c', '#frmTab019').focus();
            return false;
        }
    });
    
    $('#flemipar_c', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#przmxcmp_c', '#frmTab019').focus();
            return false;
        }
    });
    
    $('#przmxcmp_c', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#flpjzemi_c', '#frmTab019').focus();
            return false;
        }
    });
      
    $('#flpjzemi_c', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#flemisol_c', '#frmTab019').focus();
            return false;
        }
    });
                
    $('#flemisol_c', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#prcliqui_c', '#frmTab019').focus();
            return false;
        }
    });
    
    $('#prcliqui_c', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtmesliq_c', '#frmTab019').focus();
            return false;
        }
    });
    
    $('#qtmesliq_c', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#vlrenlim_c', '#frmTab019').focus();
            return false;
        }
    });
    
    $('#vlrenlim_c', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtmxrede_c', '#frmTab019').focus();
            return false;
        }
    });    
      
    $('#qtmxrede_c', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#fldchqdv_c', '#frmTab019').focus();
            return false;
        }
    });
      
    $('#fldchqdv_c', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#vlmxassi_c', '#frmTab019').focus();
            return false;
        }
    });
    
    $('#vlmxassi_c', '#frmTab019').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            confirmaOperacao();
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

    var mensagem = '';

    hideMsgAguardo();

    var inpessoa = normalizaNumero($('#inpessoa', '#frmCab').val());
	
	var vllimite = normalizaNumero($('#vllimite', '#frmTab019').val());
	
	var qtdiavig_c = normalizaNumero($('#qtdiavig_c', '#frmTab019').val());
	var qtprzmin = normalizaNumero($('#qtprzmin', '#frmTab019').val());
	var qtprzmax = normalizaNumero($('#qtprzmax', '#frmTab019').val());
	
	var txdmulta = normalizaNumero($('#txdmulta', '#frmTab019').val());
	var vlconchq = normalizaNumero($('#vlconchq', '#frmTab019').val());
	var vlmaxemi = normalizaNumero($('#vlmaxemi', '#frmTab019').val());
	
	var pcchqloc = normalizaNumero($('#pcchqloc', '#frmTab019').val());
	var pcchqemi = normalizaNumero($('#pcchqemi', '#frmTab019').val());
	var qtdiasoc = normalizaNumero($('#qtdiasoc', '#frmTab019').val());
	var qtdevchq = normalizaNumero($('#qtdevchq', '#frmTab019').val());
	var pctollim = normalizaNumero($('#pctollim', '#frmTab019').val());
	
	var vllimite_c = normalizaNumero($('#vllimite_c', '#frmTab019').val());
	var vlmaxemi_c = normalizaNumero($('#vlmaxemi_c', '#frmTab019').val());
	var qtprzmax_c = normalizaNumero($('#qtprzmax_c', '#frmTab019').val());
	var pctollim_c = normalizaNumero($('#pctollim_c', '#frmTab019').val());
	var qtdiasli = normalizaNumero($('#qtdiasli', '#frmTab019').val());
	var horalimt = normalizaNumero($('#horalimt', '#frmTab019').val());
	var qtdiasli_c = normalizaNumero($('#qtdiasli_c', '#frmTab019').val());
	var horalimt_c = normalizaNumero($('#horalimt_c', '#frmTab019').val());
	var minlimit = normalizaNumero($('#minlimit', '#frmTab019').val());
	var minlimit_c = normalizaNumero($('#minlimit_c', '#frmTab019').val());
	
    var flemipar   = $('#flemipar'  ,'#frmTab019').val();
    var flemipar_c = $('#flemipar_c','#frmTab019').val();
    var przmxcmp   = normalizaNumero($('#przmxcmp'  ,'#frmTab019').val());
    var przmxcmp_c = normalizaNumero($('#przmxcmp_c','#frmTab019').val());
    var flpjzemi   = $('#flpjzemi'  ,'#frmTab019').val();
    var flpjzemi_c = $('#flpjzemi_c','#frmTab019').val();
    var flemisol   = $('#flemisol'  ,'#frmTab019').val();
    var flemisol_c = $('#flemisol_c','#frmTab019').val();
    var prcliqui   = normalizaNumero($('#prcliqui'  ,'#frmTab019').val());
    var prcliqui_c = normalizaNumero($('#prcliqui_c','#frmTab019').val());
    var qtmesliq   = normalizaNumero($('#qtmesliq'  ,'#frmTab019').val());
    var qtmesliq_c = normalizaNumero($('#qtmesliq_c','#frmTab019').val());
    var vlrenlim   = normalizaNumero($('#vlrenlim'  ,'#frmTab019').val());
    var vlrenlim_c = normalizaNumero($('#vlrenlim_c','#frmTab019').val());
    var qtmxrede   = normalizaNumero($('#qtmxrede'  ,'#frmTab019').val());
    var qtmxrede_c = normalizaNumero($('#qtmxrede_c','#frmTab019').val());
    var fldchqdv   = $('#fldchqdv'  ,'#frmTab019').val();
    var fldchqdv_c = $('#fldchqdv_c','#frmTab019').val();
    var vlmxassi   = normalizaNumero($('#vlmxassi'  ,'#frmTab019').val());
    var vlmxassi_c = normalizaNumero($('#vlmxassi_c','#frmTab019').val());    
	
    mensagem = 'Aguarde, efetuando solicitacao...';
    showMsgAguardo(mensagem);

    $.ajax({
        type: 'POST',
        async: true,
        url: UrlSite + 'telas/tab019/manter_rotina.php',
        data: {
            cddopcao: cddopcao,
            inpessoa: inpessoa,
			vllimite   : vllimite,
			qtdiavig_c : qtdiavig_c,			
			qtprzmin   : qtprzmin,
			qtprzmax   : qtprzmax,
			txdmulta   : txdmulta,
			vlconchq   : vlconchq,
			vlmaxemi   : vlmaxemi,
			pcchqloc   : pcchqloc,
			pcchqemi   : pcchqemi,
			qtdiasoc   : qtdiasoc,
			qtdevchq   : qtdevchq,
			pctollim   : pctollim,
			vllimite_c : vllimite_c,
			vlmaxemi_c : vlmaxemi_c,
			qtprzmax_c : qtprzmax_c,
			pctollim_c : pctollim_c,
			qtdiasli   : qtdiasli,
			horalimt   : horalimt,
			qtdiasli_c : qtdiasli_c,
			horalimt_c : horalimt_c,
			minlimit   : minlimit,
			minlimit_c : minlimit_c,
            flemipar   : flemipar,
            flemipar_c : flemipar_c,
            przmxcmp   : przmxcmp,
            przmxcmp_c : przmxcmp_c,
            flpjzemi   : flpjzemi,
            flpjzemi_c : flpjzemi_c,
            flemisol   : flemisol,
            flemisol_c : flemisol_c,
            prcliqui   : prcliqui,
            prcliqui_c : prcliqui_c,
            qtmesliq   : qtmesliq,
            qtmesliq_c : qtmesliq_c,
            vlrenlim   : vlrenlim,
            vlrenlim_c : vlrenlim_c,
            qtmxrede   : qtmxrede,
            qtmxrede_c : qtmxrede_c,
            fldchqdv   : fldchqdv,
            fldchqdv_c : fldchqdv_c,
            vlmxassi   : vlmxassi,
            vlmxassi_c : vlmxassi_c,
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

                    if (cddopcao == 'AC') { // Alteração Consulta
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
    $('#frmTab019').css({'display': 'block'});
    $('#divBotoes').css({'display': 'block'});

    cTodosFiltro.desabilitaCampo();

    if ($('#cddopcao', '#frmCab').val() == 'A') {
        $("#idctrlab", "#frmTab019").val('COOPER');        
        $('.editcooper', '#frmTab019').habilitaCampo();
    }

    $('#vllimite', '#frmTab019').focus();

    if ($('#cddopcao', '#frmCab').val() == 'C') {
        $("#btContinuar", "#divBotoes").hide();
    } else {
        $("#btContinuar", "#divBotoes").show();
    }

    return false;

}

function liberaCamposCecred() {
    $("#idctrlab", "#frmTab019").val('CECRED')
   
    $('.editcecred', '#frmTab019').habilitaCampo();
    $('.editcooper', '#frmTab019').desabilitaCampo();

    $('#vllimite_c', '#frmTab019').focus();

	document.getElementById('btContinuar').innerText ='Alterar';
	
    return false;
}


function alteracaoMensagem() {
    hideMsgAguardo();
    return false;
}

function confirmaOperacao() {
	
    
    if ($("#idctrlab", "#frmTab019").val() == 'COOPER'){
        
        if (($("#dsdepart", "#frmTab019").val() == 'TI') ||
            ($("#dsdepart", "#frmTab019").val() == 'PRODUTOS') ||
            ($("#dsdepart", "#frmTab019").val() == 'COORD.ADM/FINANCEIRO')) {
            if (validarCampos()){   
                liberaCamposCecred();
            }
        } else {     
            if (validarCampos()){
                showConfirmacao('Confirma a Opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'executar();', '', 'sim.gif', 'nao.gif');
            }
        }
        
        
    } else if ($("#idctrlab", "#frmTab019").val() == 'CECRED'){
        if (validarCampos()){
            showConfirmacao('Confirma a Opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'executar();', '', 'sim.gif', 'nao.gif');
        }
    } 
           
    return false;
	
}

function validarCampos() {
	
	if  ( $('#qtprzmin', '#frmTab019').val() == ''  || $('#qtprzmin', '#frmTab019').val() == 0 ) {
		showError('error','Quantidade deve ser superior a 1 dia.','Alerta - Ayllos',"$(\'#qtprzmin\',\'#frmTab019\').focus();");
		return false;
	}
    
	var qtprzmax = parseFloat($('#qtprzmax', '#frmTab019').val().replace(".","").replace(",","."));	
	if  ( qtprzmax > 360 ) {
		showError('error','Prazo Maximo permitido 360 dias.','Alerta - Ayllos',"$(\'#qtprzmax\',\'#frmTab019\').focus();");
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
    $('#frmTab019').css({'display': 'none'});
    $('#divBotoes').css({'display': 'none'});
    return false;
}

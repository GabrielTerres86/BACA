/*!
 * FONTE        : tab052.js
 * CRIAÇÃO      : Leonardo de Freitas Oliveira - GFT
 * DATA CRIAÇÃO : 25/01/2018
 * OBJETIVO     : Biblioteca de funções da tela TAB052 
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
    cTodosFiltro = $('input[type="text"],select', '#frmTab052');

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
    highlightObjFocus($('#frmTab052'));

    // Aplicar Formatação
    controlaLayout();

    $('#cddopcao', '#frmCab').val('C');
    document.getElementById('btContinuar').innerText ='Prosseguir';
    return false;

}


function controlaLayout() {

    $('#divTela').fadeTo(0, 0.1);
    $('fieldset').css({'clear': 'both', 'border': '1px solid #777', 'margin': '3px 0px', 'padding': '10px 3px 5px 3px'});
    $('fieldset > legend').css({'font-size': '11px', 'color': '#777', 'margin-left': '5px', 'padding': '0px 2px'});
    $('#divBotoes').css({'text-align': 'center', 'padding-top': '5px'});

    $('#frmTab052').css({'display': 'none'});
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
    rTpcobran = $('label[for="tpcobran"]', '#frmCab');
    rInpessoa = $('label[for="inpessoa"]', '#frmCab');
    
    rCddopcao.css('width', '42px');
    rTpcobran.css('width', '100px');
    rInpessoa.css('width', '100px');

    cCddopcao = $('#cddopcao', '#frmCab');
    cTpcobran = $('#tpcobran', '#frmCab');
    cInpessoa = $('#inpessoa', '#frmCab');

    cCddopcao.css({'width': '350px'});
    cTpcobran.css({'width': '100px'});
    cInpessoa.css({'width': '100px'});

    btnCab = $('#btOK', '#frmCab');

    cTodosCabecalho.habilitaCampo();

    return false;
}

function formataCampos() {
	$('.labelPri', '#frmTab052').css('width', '430px');
	$('#tituloO', '#frmTab052').css('width', '515px');
	$('#tituloC', '#frmTab052').css('width', '100px');
    $('#frmCab').css('width', '900px');
 
    cVllimite = $('#vllimite', '#frmTab052');
    cVlconsul = $('#vlconsul', '#frmTab052');
    cVlminsac = $('#vlminsac', '#frmTab052');
    cQtremcrt = $('#qtremcrt', '#frmTab052');
    cQttitprt = $('#qttitprt', '#frmTab052');
    cQtdiavig = $('#qtdiavig', '#frmTab052');
    cQtprzmin = $('#qtprzmin', '#frmTab052');
    cQtprzmax = $('#qtprzmax', '#frmTab052');
    cQtminfil = $('#qtminfil', '#frmTab052');
    cNrmespsq = $('#nrmespsq', '#frmTab052');
    cPctitemi = $('#pctitemi', '#frmTab052');
    cPctolera = $('#pctolera', '#frmTab052');
    cPcdmulta = $('#pcdmulta', '#frmTab052');
    cCardbtit = $('#cardbtit', '#frmTab052');
    cPcnaopag = $('#pcnaopag', '#frmTab052');
    cQtnaopag = $('#qtnaopag', '#frmTab052');
    cQtprotes = $('#qtprotes', '#frmTab052');

    cVlmxassi = $('#vlmxassi', '#frmTab052');
    cFlemipar = $('#flemipar', '#frmTab052');
    cFlpjzemi = $('#flpjzemi', '#frmTab052');
    cFlpdctcp = $('#flpdctcp', '#frmTab052');
    cQttliqcp = $('#qttliqcp', '#frmTab052');
    cVltliqcp = $('#vltliqcp', '#frmTab052');
    cQtmintgc = $('#qtmintgc', '#frmTab052');
    cVlmintgc = $('#vlmintgc', '#frmTab052');

    cQtmitdcl = $('#qtmitdcl', '#frmTab052');
    cVlmintcl = $('#vlmintcl', '#frmTab052');

    cQtmesliq = $('#qtmesliq', '#frmTab052');
    cVlmxprat = $('#vlmxprat', '#frmTab052');
    cpcmxctip = $('#pcmxctip', '#frmTab052');
    cFlcocpfp = $('#flcocpfp', '#frmTab052');
    cQtmxdene = $('#qtmxdene', '#frmTab052');
    cQtdiexbo = $('#qtdiexbo', '#frmTab052');
    cQtmxtbib = $('#qtmxtbib', '#frmTab052');
    //cQtmxtbay = $('#qtmxtbay', '#frmTab052');
    cPctitpag = $('#pctitpag', '#frmTab052');

    cVllimite_c = $('#vllimite_c', '#frmTab052');
    cVlconsul_c = $('#vlconsul_c', '#frmTab052');
    cVlminsac_c = $('#vlminsac_c', '#frmTab052');
    cQtremcrt_c = $('#qtremcrt_c', '#frmTab052');
    cQttitprt_c = $('#qttitprt_c', '#frmTab052');
    cQtdiavig_c = $('#qtdiavig_c', '#frmTab052');
    cQtprzmin_c = $('#qtprzmin_c', '#frmTab052');
    cQtprzmax_c = $('#qtprzmax_c', '#frmTab052');
    cQtminfil_c = $('#qtminfil_c', '#frmTab052');
    cNrmespsq_c = $('#nrmespsq_c', '#frmTab052');
    cPctitemi_c = $('#pctitemi_c', '#frmTab052');
    cPctolera_c = $('#pctolera_c', '#frmTab052');
    cPcdmulta_c = $('#pcdmulta_c', '#frmTab052');
    cCardbtit_c = $('#cardbtit_c', '#frmTab052');
    cPcnaopag_c = $('#pcnaopag_c', '#frmTab052');
    cQtnaopag_c = $('#qtnaopag_c', '#frmTab052');
    cQtprotes_c = $('#qtprotes_c', '#frmTab052');
    
    cVlmxassi_c = $('#vlmxassi_c', '#frmTab052');
    cFlemipar_c = $('#flemipar_c', '#frmTab052');
    cFlpjzemi_c = $('#flpjzemi_c', '#frmTab052');
    cFlpdctcp_c = $('#flpdctcp_c', '#frmTab052');
    cQttliqcp_c = $('#qttliqcp_c', '#frmTab052');
    cVltliqcp_c = $('#vltliqcp_c', '#frmTab052');
    cQtmintgc_c = $('#qtmintgc_c', '#frmTab052');
    cVlmintgc_c = $('#vlmintgc_c', '#frmTab052');

    cQtmitdcl_c = $('#qtmitdcl_C', '#frmTab052');
    cVlmintcl_c = $('#vlmintcl_c', '#frmTab052');

    cQtmesliq_c = $('#qtmesliq_c', '#frmTab052');
    cVlmxprat_c = $('#vlmxprat_c', '#frmTab052');
    cpcmxctip_c = $('#pcmxctip_c', '#frmTab052');
    cFlcocpfp_c = $('#flcocpfp_c', '#frmTab052');
    cQtmxdene_c = $('#qtmxdene_c', '#frmTab052');
    cQtdiexbo_c = $('#qtdiexbo_c', '#frmTab052');
    cQtmxtbib_c = $('#qtmxtbib_c', '#frmTab052');
    //cQtmxtbay_c = $('#qtmxtbay_c', '#frmTab052');
    cPctitpag_c = $('#pctitpag_c', '#frmTab052');

    cVllimite.css('width',  '100px').addClass('moeda').addClass('editcooper');// DECI
    cVlconsul.css('width',  '100px').addClass('moeda').addClass('editcooper');// DECI
    cVlminsac.css('width',  '100px').addClass('moeda').addClass('editcooper');// DECI
    cQtremcrt.css('width', '40px').addClass('editcooper').setMask('INTEGER','zzz','','');// INTE
    cQttitprt.css('width', '40px').addClass('editcooper').setMask('INTEGER','zzz','','');// INTE
    cQtdiavig.css('width', '40px').addClass('editcooper').setMask('INTEGER','zzz','','');// INTE
    cQtprzmin.css('width', '40px').addClass('editcooper').setMask('INTEGER','zzz','','');// INTE
    cQtprzmax.css('width', '40px').addClass('editcooper').setMask('INTEGER','zzz','','');// INTE
    cQtminfil.css('width', '40px').addClass('editcooper').setMask('INTEGER','zzz','','');// INTE    
	cNrmespsq.css('width', '40px').addClass('editcooper').setMask('INTEGER','zzz','','');// INTE 
    cPctitemi.css('width', '40px').addClass('editcooper').setMask('INTEGER','zzz','','');// INTE
    cPctolera.css('width', '40px').addClass('editcooper').setMask('INTEGER','zzz','','');// INTE
    cPcdmulta.css('width', '40px').addClass('editcooper').setMask('INTEGER','zzz','','');// INTE
    cCardbtit.css('width', '40px').addClass('editcooper').setMask('INTEGER','zzz','','');// INTE
    cPcnaopag.css('width', '40px').addClass('editcooper').setMask('INTEGER','zzz','','');// INTE
    cQtnaopag.css('width', '40px').addClass('editcooper').setMask('INTEGER','zzz','','');// INTE
    cQtprotes.css('width', '40px').addClass('editcooper').setMask('INTEGER','zzz','','');// INTE
    
    cVlmxassi.css('width',  '100px').addClass('moeda').addClass('editcooper');// DECI
    cFlemipar.addClass('editcooper');//FLAG
    cFlpjzemi.addClass('editcooper');//FLAG
    cFlpdctcp.addClass('editcooper');//FLAG
    cQttliqcp.css('width', '40px').addClass('editcooper').setMask('INTEGER','zzz','','');// INTE
    cVltliqcp.css('width',  '100px').addClass('moeda').addClass('editcooper');// DECI
    cQtmintgc.css('width', '40px').addClass('editcooper').setMask('INTEGER','zzz','','');// INTE
    cVlmintgc.css('width',  '100px').addClass('moeda').addClass('editcooper');// DECI

    cQtmitdcl.css('width', '40px').addClass('editcooper').setMask('INTEGER','zzz','','');// INTE
    cVlmintcl.css('width',  '100px').addClass('moeda').addClass('editcooper');// DECI

    cQtmesliq.css('width', '40px').addClass('editcooper').setMask('INTEGER','zzz','','');// INTE
    cVlmxprat.css('width',  '100px').addClass('moeda').addClass('editcooper');// DECI
    cpcmxctip.css('width',  '100px').addClass('moeda').addClass('editcooper');// DECI
    cFlcocpfp.addClass('editcooper');
    cQtmxdene.css('width', '40px').addClass('editcooper').setMask('INTEGER','zzz','','');// INTE
    cQtdiexbo.css('width', '40px').addClass('editcooper').setMask('INTEGER','zzz','','');// INTE
    cQtmxtbib.css('width', '40px').addClass('editcooper').setMask('INTEGER','zzz','','');// INTE
    //cQtmxtbay.css('width', '40px').addClass('editcooper').setMask('INTEGER','zzz','','');// INTE
    cPctitpag.css('width', '40px').addClass('editcooper').setMask('INTEGER','zzz','','');// INTE

   

    cVllimite_c.css('width',  '100px').addClass('moeda').addClass('editcecred');// DECI
    cVlconsul_c.css('width',  '100px').addClass('moeda').addClass('editcecred');// DECI
    cVlminsac_c.css('width',  '100px').addClass('moeda').addClass('editcecred');// DECI
    cQtremcrt_c.css('width', '40px').addClass('editcecred').setMask('INTEGER','zzz','','');// INTE
    cQttitprt_c.css('width', '40px').addClass('editcecred').setMask('INTEGER','zzz','','');// INTE
    cQtdiavig_c.css('width', '40px').addClass('editcecred').setMask('INTEGER','zzz','','');// INTE
    cQtprzmin_c.css('width', '40px').addClass('editcecred').setMask('INTEGER','zzz','','');// INTE
    cQtprzmax_c.css('width', '40px').addClass('editcecred').setMask('INTEGER','zzz','','');// INTE
    cQtminfil_c.css('width', '40px').addClass('editcecred').setMask('INTEGER','zzz','','');// INTE    
	cNrmespsq_c.css('width', '40px').addClass('editcecred').setMask('INTEGER','zzz','','');// INTE 
    cPctitemi_c.css('width', '40px').addClass('editcecred').setMask('INTEGER','zzz','','');// INTE
    cPctolera_c.css('width', '40px').addClass('editcecred').setMask('INTEGER','zzz','','');// INTE
    cPcdmulta_c.css('width', '40px').addClass('editcecred').setMask('INTEGER','zzz','','');// INTE
    cCardbtit_c.css('width', '40px').addClass('editcecred').setMask('INTEGER','zzz','','');// INTE
    cPcnaopag_c.css('width', '40px').addClass('editcecred').setMask('INTEGER','zzz','','');// INTE
    cQtnaopag_c.css('width', '40px').addClass('editcecred').setMask('INTEGER','zzz','','');// INTE
    cQtprotes_c.css('width', '40px').addClass('editcecred').setMask('INTEGER','zzz','','');// INTE

    cVlmxassi_c.css('width',  '100px').addClass('moeda').addClass('editcecred');// DECI
    cFlemipar_c.addClass('editcecred');//FLAG
    cFlpjzemi_c.addClass('editcecred');//FLAG
    cFlpdctcp_c.addClass('editcecred');//FLAG
    cQttliqcp_c.css('width', '40px').addClass('editcecred').setMask('INTEGER','zzz','','');// INTE
    cVltliqcp_c.css('width',  '100px').addClass('moeda').addClass('editcecred');// DECI
    cQtmintgc_c.css('width', '40px').addClass('editcecred').setMask('INTEGER','zzz','','');// INTE
    cVlmintgc_c.css('width',  '100px').addClass('moeda').addClass('editcecred');// DECI
    
    cQtmitdcl_c.css('width', '40px').addClass('editcecred').setMask('INTEGER','zzz','','');// INTE
    cVlmintcl_c.css('width',  '100px').addClass('moeda').addClass('editcecred');// DECI

    cQtmesliq_c.css('width', '40px').addClass('editcecred').setMask('INTEGER','zzz','','');// INTE
    cVlmxprat_c.css('width',  '100px').addClass('moeda').addClass('editcecred');// DECI
    cpcmxctip_c.css('width',  '100px').addClass('moeda').addClass('editcecred');// DECI
    cFlcocpfp_c.addClass('editcecred');
    cQtmxdene_c.css('width', '40px').addClass('editcecred').setMask('INTEGER','zzz','','');// INTE
    cQtdiexbo_c.css('width', '40px').addClass('editcecred').setMask('INTEGER','zzz','','');// INTE
    cQtmxtbib_c.css('width', '40px').addClass('editcecred').setMask('INTEGER','zzz','','');// INTE
    //cQtmxtbay_c.css('width', '40px').addClass('editcecred').setMask('INTEGER','zzz','','');// INTE
    cPctitpag_c.css('width', '40px').addClass('editcecred').setMask('INTEGER','zzz','','');// INTE

        
    cTodosFiltro.habilitaCampo();

    return false;
}



function controlaFoco() {

    $('#cddopcao', '#frmCab').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#tpcobran', '#frmCab').focus();
            return false;
        }
    });

    $('#tpcobran', '#frmCab').unbind('keypress').bind('keypress', function(e) {
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

    $('#vllimite', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {

            $('#vlconsul', '#frmTab052').focus();
            return false;
        }
    });

    $('#vlconsul', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#vlminsac', '#frmTab052').focus();
            return false;
        }
    });

    $('#vlminsac', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
    
        if (e.keyCode == 9 || e.keyCode == 13) {
            if(1 == normalizaNumero($('#tpcobran', '#frmCab').val())){
                $('#qtremcrt', '#frmTab052').focus();
                return false;
            }else{
                $('#qtdiavig', '#frmTab052').focus();
                return false;
            }
        }

    });


    /*registerRow*/
    $('#qtremcrt', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qttitprt', '#frmTab052').focus();
            return false;
        }
    });

    /*registerRow*/
    $('#qttitprt', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtdiavig', '#frmTab052').focus();
            return false;
        }
    });

    $('#qtdiavig', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtprzmin', '#frmTab052').focus();
            return false;
        }
    });

    $('#qtprzmin', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtprzmax', '#frmTab052').focus();
            return false;
        }
    });

    $('#qtprzmax', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtminfil', '#frmTab052').focus();
            return false;
        }
    });

    $('#cardbtit', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtminfil', '#frmTab052').focus();
            return false;
        }
    });

    $('#qtminfil', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#nrmespsq', '#frmTab052').focus();
            return false;
        }
    });

    $('#nrmespsq', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#pctitemi', '#frmTab052').focus();
            return false;
        }
    });

    $('#pctitemi', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {

            $('#pctolera', '#frmTab052').focus();
            return false;
        }
    });
        
    $('#pctolera', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#pcdmulta', '#frmTab052').focus();
            return false;
        }
    });
    
    $('#pcdmulta', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#pcnaopag', '#frmTab052').focus();
            return false;
        }
    });
      
    $('#pcnaopag', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtnaopag', '#frmTab052').focus();
            return false;
        }
    });
          
      
    $('#qtnaopag', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            if(1 == normalizaNumero($('#tpcobran', '#frmCab').val())){
                $('#qtprotes', '#frmTab052').focus();
                return false;
            }else{
                $('#vlmxassi', '#frmTab052').focus();
                return false;
            }
        }
    });

    
    /*registerRow*/
    $('#qtprotes', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#vlmxassi', '#frmTab052').focus();
            return false;
            
        }
    });
    
    $('#vlmxassi', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtmxtbib', '#frmTab052').focus();
            return false;
        }
    });


    $('#qtmxtbib', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#flemipar', '#frmTab052').focus();
            return false;
        }
    });

    $('#flemipar', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#flpjzemi', '#frmTab052').focus();
            return false;
        }
    });

    $('#flpjzemi', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#flpdctcp', '#frmTab052').focus();
            return false;
        }
    });

    $('#flpdctcp', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qttliqcp', '#frmTab052').focus();
            return false;
        }
    });


    $('#qttliqcp', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#vltliqcp', '#frmTab052').focus();
            return false;
        }
    });


    $('#vltliqcp', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtmintgc', '#frmTab052').focus();
            return false;
        }
    });


    $('#qtmintgc', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#vlmintgc', '#frmTab052').focus();
            return false;
        }
    });



    $('#vlmintgc', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtmitdcl', '#frmTab052').focus();
            return false;
        }
    });


    $('#qtmitdcl', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#vlmintcl', '#frmTab052').focus();
            return false;
        }
    });

    $('#vlmintcl', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtmesliq', '#frmTab052').focus();
            return false;
        }
    });

    $('#qtmesliq', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#vlmxprat', '#frmTab052').focus();
            return false;
        }
    });

    $('#vlmxprat', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#pcmxctip', '#frmTab052').focus();
            return false;
        }
    });

    $('#pcmxctip', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtmxdene', '#frmTab052').focus();
            return false;
        }
    });


    $('#qtmxdene', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtdiexbo', '#frmTab052').focus();
            return false;
        }
    });


    $('#qtdiexbo', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#pctitpag', '#frmTab052').focus();
            return false;
        }
    });

     $('#pctitpag', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            confirmaOperacao();
            return false;
        }
    });


    $('#vllimite_c', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#vlconsul_c', '#frmTab052').focus();
            return false;
        }
    });

    $('#vlconsul_c', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#vlminsac_c', '#frmTab052').focus();
            return false;
        }
    });

    $('#vlminsac_c', '#frmTab052').unbind('keypress').bind('keypress', function(e) {

        if (e.keyCode == 9 || e.keyCode == 13) {
            if(1 == normalizaNumero($('#tpcobran', '#frmCab').val())){
                $('#qtremcrt_c', '#frmTab052').focus();
                return false;
            }else{
                $('#qtdiavig_c', '#frmTab052').focus();
                return false;
            }
        }
    });


    /*registerRow*/
    $('#qtremcrt_c', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qttitprt_c', '#frmTab052').focus();
            return false;
        }
    });

    /*registerRow*/
    $('#qttitprt_c', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtdiavig_c', '#frmTab052').focus();
            return false;
        }
    });


    $('#qtdiavig_c', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtprzmin_c', '#frmTab052').focus();
            return false;
        }
    });

    $('#qtprzmin_c', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtprzmax_c', '#frmTab052').focus();
            return false;
        }
    });

    $('#qtprzmax_c', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtminfil_c', '#frmTab052').focus();
            return false;
        }
    });

    $('#qtminfil_c', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#cardbtit_c', '#frmTab052').focus();
            return false;
        }
    });

    $('#cardbtit_c', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#nrmespsq_c', '#frmTab052').focus();
            return false;
        }
    });

   

    

    $('#nrmespsq_c', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#pctitemi_c', '#frmTab052').focus();
            return false;
        }
    });

    $('#pctitemi_c', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {

            $('#pctolera_c', '#frmTab052').focus();
            return false;
        }
    });
        
    $('#pctolera_c', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#pcdmulta_c', '#frmTab052').focus();
            return false;
        }
    });
    
    $('#pcdmulta_c', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#pcnaopag_c', '#frmTab052').focus();
            return false;
        }
    });
      
    $('#pcnaopag_c', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtnaopag_c', '#frmTab052').focus();
            return false;
        }
    });

    $('#qtnaopag_c', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            if(1 == normalizaNumero($('#tpcobran', '#frmCab').val())){
                $('#qtprotes_c', '#frmTab052').focus();
                return false;
            }else{
                $('#vlmxassi_c', '#frmTab052').focus();
                return false;
            }
        }
    });
    

    /*registerRow*/
    $('#qtprotes_c', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#vlmxassi_c', '#frmTab052').focus();
            return false;
        }
    });
    
    $('#vlmxassi_c', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtmxtbib_c', '#frmTab052').focus();
            return false;
        }
    });

    $('#qtmxtbib_c', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#flemipar_c', '#frmTab052').focus();
            return false;
        }
    });

    $('#flemipar_c', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#flpjzemi_c', '#frmTab052').focus();
            return false;
        }
    });

    $('#flpjzemi_c', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#flpdctcp_c', '#frmTab052').focus();
            return false;
        }
    });

    $('#flpdctcp_c', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qttliqcp_c', '#frmTab052').focus();
            return false;
        }
    });

    $('#qttliqcp_c', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#vltliqcp_c', '#frmTab052').focus();

            return false;
        }
    });

    $('#vltliqcp_c', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtmintgc_c', '#frmTab052').focus();
            return false;
        }
    });

    $('#qtmintgc_c', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#vlmintgc_c', '#frmTab052').focus();
            return false;
        }
    });

    $('#vlmintgc_c', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtmitdcl_c', '#frmTab052').focus();
            return false;
        }
    });

    $('#qtmitdcl_c', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#vlmintcl_c', '#frmTab052').focus();
            return false;
        }
    });

     $('#vlmintcl_c', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtmesliq_c', '#frmTab052').focus();
            return false;
        }
    });

    $('#qtmesliq_c', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#vlmxprat_c', '#frmTab052').focus();
            return false;
        }
    });

    $('#vlmxprat_c', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#pcmxctip_c', '#frmTab052').focus();
            return false;
        }
    });

    $('#pcmxctip_c', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtmxdene_c', '#frmTab052').focus();
            return false;
        }
    });


    $('#qtmxdene_c', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtdiexbo_c', '#frmTab052').focus();
            return false;
        }
    });


    $('#qtdiexbo_c', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#pctitpag_c', '#frmTab052').focus();
            return false;
        }
    });

    $('#pctitpag_c', '#frmTab052').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            confirmaOperacao();
            return false;
        }
    });

}

//executa apos clicar no botao OK
function controlaOperacao() {

    var tpcobran = normalizaNumero($('#tpcobran', '#frmCab').val());
    var inpessoa = normalizaNumero($('#inpessoa', '#frmCab').val());
    if(tpcobran != 1){
        $('.registerRow', '#frmTab052').css({'display': 'none'});
    }else{
        $('.registerRow', '#frmTab052').css({'display': ''});
    }

    if(inpessoa == 1 ){
        $('.personForm', '#frmTab052').css({'display': 'none'});
        $('.companyForm', '#frmTab052').css({'display': ''});
    }else{
        $('.companyForm', '#frmTab052').css({'display': ''});
        $('.personForm', '#frmTab052').css({'display': 'none'});
    }

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
        $('#cardbtit', '#frmTab052').css({'display': ''});
        $('#cardbtit-label-compl', '#frmTab052').css({'display': ''});
    } else {
        manterRotina('AC');
        $('#cardbtit', '#frmTab052').css({'display': 'none'});
        $('#cardbtit-label-compl', '#frmTab052').css({'display': 'none'});

        
    }
             
    return false;

}


function manterRotina(cddopcao) {

    var mensagem = '';

    hideMsgAguardo();

    var tpcobran = normalizaNumero($('#tpcobran', '#frmCab').val());
    var inpessoa = normalizaNumero($('#inpessoa', '#frmCab').val());
    
    var vllimite = normalizaNumero($('#vllimite', '#frmTab052').val());
    var vlconsul = normalizaNumero($('#vlconsul', '#frmTab052').val());
    var vlminsac = normalizaNumero($('#vlminsac', '#frmTab052').val());
    var qtremcrt = normalizaNumero($('#qtremcrt', '#frmTab052').val());
    var qttitprt = normalizaNumero($('#qttitprt', '#frmTab052').val());
    var qtdiavig = normalizaNumero($('#qtdiavig', '#frmTab052').val());
    var qtprzmin = normalizaNumero($('#qtprzmin', '#frmTab052').val());
    var qtprzmax = normalizaNumero($('#qtprzmax', '#frmTab052').val());
    var cardbtit = normalizaNumero($('#cardbtit', '#frmTab052').val());
    var qtminfil = normalizaNumero($('#qtminfil', '#frmTab052').val());
    var nrmespsq = normalizaNumero($('#nrmespsq', '#frmTab052').val());
    var pctitemi = normalizaNumero($('#pctitemi', '#frmTab052').val());
    var pctolera = normalizaNumero($('#pctolera', '#frmTab052').val());
    var pcdmulta = normalizaNumero($('#pcdmulta', '#frmTab052').val());
    var pcnaopag = normalizaNumero($('#pcnaopag', '#frmTab052').val());
    var qtnaopag = normalizaNumero($('#qtnaopag', '#frmTab052').val());
    var qtprotes = normalizaNumero($('#qtprotes', '#frmTab052').val());

    var vlmxassi = normalizaNumero($('#vlmxassi', '#frmTab052').val());
    var flemipar = normalizaNumero($('#flemipar', '#frmTab052').val());
    var flpjzemi = normalizaNumero($('#flpjzemi', '#frmTab052').val());
    var flpdctcp = normalizaNumero($('#flpdctcp', '#frmTab052').val());
    var qttliqcp = normalizaNumero($('#qttliqcp', '#frmTab052').val());
    var vltliqcp = normalizaNumero($('#vltliqcp', '#frmTab052').val());
    var qtmintgc = normalizaNumero($('#qtmintgc', '#frmTab052').val());
    var vlmintgc = normalizaNumero($('#vlmintgc', '#frmTab052').val());

    var qtmitdcl = normalizaNumero($('#qtmitdcl', '#frmTab052').val());
    var vlmintcl = normalizaNumero($('#vlmintcl', '#frmTab052').val());

    var qtmesliq = normalizaNumero($('#qtmesliq', '#frmTab052').val());
    var vlmxprat = normalizaNumero($('#vlmxprat', '#frmTab052').val());
    var pcmxctip = normalizaNumero($('#pcmxctip', '#frmTab052').val());
    var flcocpfp = normalizaNumero($('#flcocpfp', '#frmTab052').val());
    var qtmxdene = normalizaNumero($('#qtmxdene', '#frmTab052').val());
    var qtdiexbo = normalizaNumero($('#qtdiexbo', '#frmTab052').val());
    var qtmxtbib = normalizaNumero($('#qtmxtbib', '#frmTab052').val());

    //var qtmxtbay = normalizaNumero($('#qtmxtbay', '#frmTab052').val());
    var pctitpag = normalizaNumero($('#pctitpag', '#frmTab052').val());
    

    var vllimite_c = normalizaNumero($('#vllimite_c', '#frmTab052').val());
    var vlconsul_c = normalizaNumero($('#vlconsul_c', '#frmTab052').val());
    var vlminsac_c = normalizaNumero($('#vlminsac_c', '#frmTab052').val());
    var qtremcrt_c = normalizaNumero($('#qtremcrt_c', '#frmTab052').val());
    var qttitprt_c = normalizaNumero($('#qttitprt_c', '#frmTab052').val());
    var qtdiavig_c = normalizaNumero($('#qtdiavig_c', '#frmTab052').val());
    var qtprzmin_c = normalizaNumero($('#qtprzmin_c', '#frmTab052').val());
    var qtprzmax_c = normalizaNumero($('#qtprzmax_c', '#frmTab052').val());
    var cardbtit_c = normalizaNumero($('#cardbtit_c', '#frmTab052').val());
    var qtminfil_c = normalizaNumero($('#qtminfil_c', '#frmTab052').val());
    var nrmespsq_c = normalizaNumero($('#nrmespsq_c', '#frmTab052').val());
    var pctitemi_c = normalizaNumero($('#pctitemi_c', '#frmTab052').val());
    var pctolera_c = normalizaNumero($('#pctolera_c', '#frmTab052').val());
    var pcdmulta_c = normalizaNumero($('#pcdmulta_c', '#frmTab052').val());
    var pcnaopag_c = normalizaNumero($('#pcnaopag_c', '#frmTab052').val());
    var qtnaopag_c = normalizaNumero($('#qtnaopag_c', '#frmTab052').val());
    var qtprotes_c = normalizaNumero($('#qtprotes_c', '#frmTab052').val());

    var vlmxassi_c = normalizaNumero($('#vlmxassi_c', '#frmTab052').val());
    var flemipar_c = normalizaNumero($('#flemipar_c', '#frmTab052').val());
    var flpjzemi_c = normalizaNumero($('#flpjzemi_c', '#frmTab052').val());
    var flpdctcp_c = normalizaNumero($('#flpdctcp_c', '#frmTab052').val());
    var qttliqcp_c = normalizaNumero($('#qttliqcp_c', '#frmTab052').val());
    var vltliqcp_c = normalizaNumero($('#vltliqcp_c', '#frmTab052').val());
    var qtmintgc_c = normalizaNumero($('#qtmintgc_c', '#frmTab052').val());
    var vlmintgc_c = normalizaNumero($('#vlmintgc_c', '#frmTab052').val());

    var qtmitdcl_c = normalizaNumero($('#qtmitdcl_c', '#frmTab052').val());
    var vlmintcl_c = normalizaNumero($('#vlmintcl_c', '#frmTab052').val());

    var qtmesliq_c = normalizaNumero($('#qtmesliq_c', '#frmTab052').val());
    var vlmxprat_c = normalizaNumero($('#vlmxprat_c', '#frmTab052').val());
    var pcmxctip_c = normalizaNumero($('#pcmxctip_c', '#frmTab052').val());
    var flcocpfp_c = normalizaNumero($('#flcocpfp_c', '#frmTab052').val());
    var qtmxdene_c = normalizaNumero($('#qtmxdene_c', '#frmTab052').val());
    var qtdiexbo_c = normalizaNumero($('#qtdiexbo_c', '#frmTab052').val());
    var qtmxtbib_c = normalizaNumero($('#qtmxtbib_c', '#frmTab052').val());
    //var qtmxtbay_c = normalizaNumero($('#qtmxtbay_c', '#frmTab052').val());

    var pctitpag_c = normalizaNumero($('#pctitpag_c', '#frmTab052').val());


    mensagem = 'Aguarde, efetuando solicitacao...';
    showMsgAguardo(mensagem);

    $.ajax({
        type: 'POST',
        async: true,
        url: UrlSite + 'telas/tab052/manter_rotina.php',
        data: {
            cddopcao: cddopcao,
            inpessoa: inpessoa,
            tpcobran: tpcobran,
			vllimite: vllimite,
			vlconsul: vlconsul,
			vlminsac: vlminsac,
			qtremcrt: qtremcrt,
			qttitprt: qttitprt,
			qtdiavig: qtdiavig,
			qtprzmin: qtprzmin,
			qtprzmax: qtprzmax,
			cardbtit: cardbtit,
			qtminfil: qtminfil,
			nrmespsq: nrmespsq,
			pctitemi: pctitemi,
			pctolera: pctolera,
			pcdmulta: pcdmulta,
			pcnaopag: pcnaopag,
			qtnaopag: qtnaopag,
            qtprotes: qtprotes,

            vlmxassi: vlmxassi,
            flemipar: flemipar,
            flpjzemi: flpjzemi,
            flpdctcp: flpdctcp,
            qttliqcp: qttliqcp,
            vltliqcp: vltliqcp,
            qtmintgc: qtmintgc,
            vlmintgc: vlmintgc,

            qtmitdcl: qtmitdcl,
            vlmintcl: vlmintcl,

            qtmesliq: qtmesliq,
            vlmxprat: vlmxprat,
            pcmxctip: pcmxctip,
            flcocpfp: flcocpfp,
            qtmxdene: qtmxdene,
            qtdiexbo: qtdiexbo,
            qtmxtbib: qtmxtbib,
            //qtmxtbay: qtmxtbay,
            pctitpag: pctitpag,

			vllimite_c: vllimite_c,
			vlconsul_c: vlconsul_c,
			vlminsac_c: vlminsac_c,
			qtremcrt_c: qtremcrt_c,
			qttitprt_c: qttitprt_c,
			qtdiavig_c: qtdiavig_c,
			qtprzmin_c: qtprzmin_c,
			qtprzmax_c: qtprzmax_c,
			cardbtit_c: cardbtit_c,
			qtminfil_c: qtminfil_c,
			nrmespsq_c: nrmespsq_c,
			pctitemi_c: pctitemi_c,
			pctolera_c: pctolera_c,
			pcdmulta_c: pcdmulta_c,
			pcnaopag_c: pcnaopag_c,
			qtnaopag_c: qtnaopag_c,
            qtprotes_c: qtprotes_c,
            
            vlmxassi_c: vlmxassi_c,
            flemipar_c: flemipar_c,
            flpjzemi_c: flpjzemi_c,
            flpdctcp_c: flpdctcp_c,
            qttliqcp_c: qttliqcp_c,
            vltliqcp_c: vltliqcp_c,
            qtmintgc_c: qtmintgc_c,
            vlmintgc_c: vlmintgc_c,

            qtmitdcl_c: qtmitdcl_c,
            vlmintcl_c: vlmintcl_c,

            qtmesliq_c: qtmesliq_c,
            vlmxprat_c: vlmxprat_c,
            pcmxctip_c: pcmxctip_c,
            flcocpfp_c: flcocpfp_c,
            qtmxdene_c: qtmxdene_c,
            qtdiexbo_c: qtdiexbo_c,
            qtmxtbib_c: qtmxtbib_c,
            //qtmxtbay_c: qtmxtbay_c,
            pctitpag_c: pctitpag_c,

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
    $('#frmTab052').css({'display': 'block'});
    $('#divBotoes').css({'display': 'block'});

    cTodosFiltro.desabilitaCampo();

    if ($('#cddopcao', '#frmCab').val() == 'A') {
        $("#idctrlab", "#frmTab052").val('COOPER');        
        $('.editcooper', '#frmTab052').habilitaCampo();
    }

    $('#vllimite', '#frmTab052').focus();

    if ($('#cddopcao', '#frmCab').val() == 'C') {
        $("#btContinuar", "#divBotoes").hide();
    } else {
        $("#btContinuar", "#divBotoes").show();
    }

    return false;

}

function liberaCamposCooper(){
    $("#idctrlab", "#frmTab052").val('COOPER')
   
    $('.editcecred', '#frmTab052').desabilitaCampo();
    $('.editcooper', '#frmTab052').habilitaCampo();

    $('#vllimite', '#frmTab052').focus();

    document.getElementById('btContinuar').innerText ='Prosseguir';
    return false;

}

function liberaCamposCecred() {
    $("#idctrlab", "#frmTab052").val('CECRED')
   
    $('.editcecred', '#frmTab052').habilitaCampo();
    $('.editcooper', '#frmTab052').desabilitaCampo();

    $('#vllimite_c', '#frmTab052').focus();

	document.getElementById('btContinuar').innerText ='Alterar';
    return false;
}

function back(){
    if($("#idctrlab", "#frmTab052").val() == 'CECRED'){
        liberaCamposCooper();
        return false;
    }else{
        estadoInicial();
        return false;
    }
}

function alteracaoMensagem() {
    hideMsgAguardo();
    return false;
}

function confirmaOperacao() {
	
    
    if ($("#idctrlab", "#frmTab052").val() == 'COOPER'){
        
        if (($("#dsdepart", "#frmTab052").val() == 'TI') ||
            ($("#dsdepart", "#frmTab052").val() == 'PRODUTOS') ||
            ($("#dsdepart", "#frmTab052").val() == 'COORD.ADM/FINANCEIRO')) {
            if (validarCampos()){   
                liberaCamposCecred();
            }
        } else {     
            if (validarCampos()){
                showConfirmacao('Confirma a Opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'executar();', '', 'sim.gif', 'nao.gif');
            }
        }
        
        
    } else if ($("#idctrlab", "#frmTab052").val() == 'CECRED'){
        if (validarCampos()){
            showConfirmacao('Confirma a Opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'executar();', '', 'sim.gif', 'nao.gif');
        }
    } 
           
    return false;
	
}

function validarCampos() {

    /* qtprzmin > qtprzmax  = Quantidade errada.*/
    if( converteMoedaFloat($('#qtprzmin', '#frmTab052').val()) > converteMoedaFloat($('#qtprzmax', '#frmTab052').val())){
        showError('error','O valor de vig&ecirc;ncia m&iacute;nima deve ser menor ou igual o valor de vig&ecirc;ncia m&aacute;xima','Alerta - Ayllos',"$(\'#qtprzmax\',\'#frmTab052\').focus();");
        return false;
    }

    /* qtprzmin_c > qtprzmax_c  = Quantidade errada.*/
    if( converteMoedaFloat($('#qtprzmin_c', '#frmTab052').val()) > converteMoedaFloat($('#qtprzmax_c', '#frmTab052').val())){
        showError('error','O valor de vig&ecirc;ncia m&iacute;nima da CECRED deve ser menor ou igual o valor de vig&ecirc;ncia m&aacute;xima da CECRED','Alerta - Ayllos',"$(\'#qtprzmax_c\',\'#frmTab052\').focus();");
        return false;
    }

     /* qtprzmax > 360 = Quantidade errada.*/
    if( converteMoedaFloat($('#qtprzmax', '#frmTab052').val()) > 360 ){
        showError('error','O valo de vig&ecirc;ncia m&aacute;xima deve ser menor ou igual que 360','Alerta - Ayllos',"$(\'#qtprzmax\',\'#frmTab052\').focus();");
        return false;
    }

     /* qtprzmax_c > 360 = Quantidade errada.*/
    if( converteMoedaFloat($('#qtprzmax_c', '#frmTab052').val()) > 360 ){
        showError('error','O valo de vig&ecirc;ncia m&aacute;xima da CECRED deve ser menor ou igual que 360','Alerta - Ayllos',"$(\'#qtprzmax_c\',\'#frmTab052\').focus();");
        return false;
    }

    /* vllimite > vllimite_c = O valor deve ser inferior ou igual ao estipulado pela CECRED*/
    if( converteMoedaFloat($('#vllimite', '#frmTab052').val()) > converteMoedaFloat($('#vllimite_c', '#frmTab052').val())  ){
        showError('error','O valor do limite m&aacute;ximo do contrato deve ser inferior ou igual ao estipulado pela CECRED','Alerta - Ayllos',"$(\'#vllimite\',\'#frmTab052\').focus();");
        return false;
    }

    /* qtprzmax > qtprzmax_c = O valor deve ser inferior ou igual ao estipulado pela CECRED*/
    if( converteMoedaFloat($('#qtprzmax', '#frmTab052').val()) > converteMoedaFloat($('#qtprzmax_c', '#frmTab052').val())  ){
        showError('error','O prazo m&aacute;ximo deve ser inferior ou igual ao estipulado pela CECRED','Alerta - Ayllos',"$(\'#qtprzmax\',\'#frmTab052\').focus();");
        return false;
    }

    /* cardbtit > 5 = A quantidade de dias de car&ecirc;ncia de debito de t&iacute;tulo deve ser menor ou igual a 5*/
    if( converteMoedaFloat($('#cardbtit', '#frmTab052').val()) > 5 ){
        showError('error','A quantidade de dias de car&ecirc;ncia de debito de t&iacute;tulo deve ser menor ou igual a 5','Alerta - Ayllos',"$(\'#cardbtit\',\'#frmTab052\').focus();");
        return false;
    }

    /* pctolera > pctolera_c = O valor deve ser inferior ou igual ao estipulado pela CECRED*/
    if( converteMoedaFloat($('#pctolera', '#frmTab052').val()) > converteMoedaFloat($('#pctolera_c', '#frmTab052').val())  ){
        showError('error','A toler$acirc;ncia para limite excedido deve ser inferior ou igual ao estipulado pela CECRED','Alerta - Ayllos',"$(\'#pctolera\',\'#frmTab052\').focus();");
        return false;
    }

    /* pcdmulta > 2 = O valor deve ser inferior ou igual ao estipulado pela CECRED*/
    if( converteMoedaFloat($('#pcdmulta', '#frmTab052').val()) > 2 ){
        showError('error','O percentual de multa nao deve ser superior a 2% (Exig&ecirc;ncia  Legal).','Alerta - Ayllos',"$(\'#pcdmulta\',\'#frmTab052\').focus();");
        return false;
    }

        /* pcdmulta_c > 2 = O valor deve ser inferior ou igual ao estipulado pela CECRED*/
    if( converteMoedaFloat($('#pcdmulta_c', '#frmTab052').val()) > 2 ){
        showError('error','O percentual de multa da CECRED nao deve ser superior a 2% (Exig&ecirc;ncia Legal).','Alerta - Ayllos',"$(\'#pcdmulta_c\',\'#frmTab052\').focus();");
        return false;
    }

    /* qtmxdene > qtmxdene_c o valor deve ser inferior ou igual ao estipulado pela CECRED */
    if( converteMoedaFloat($('#qtmxdene', '#frmTab052').val()) > converteMoedaFloat($('#qtmxdene_c', '#frmTab052').val())  ){
        showError('error','A quantidade m&aacute;ximo de dias deve ser inferior ou igual ao estipulado pela CECRED','Alerta - Ayllos',"$(\'#qtmxdene\',\'#frmTab052\').focus();");
        return false;
    }

    /* qtmxtbib > qtmxtbib_c o valor deve ser inferior ou igual ao estipulado pela CECRED */
    if( converteMoedaFloat($('#qtmxtbib', '#frmTab052').val()) > converteMoedaFloat($('#qtmxtbib_c', '#frmTab052').val())  ){
        showError('error','A quantidade m&aacute;xima de t&iacute;tulos por border&ocirc; IB deve ser inferior ou igual ao estipulado pela CECRED','Alerta - Ayllos',"$(\'#qtmxtbib\',\'#frmTab052\').focus();");
        return false;
    }

    /* qtmxtbay > qtmxtbay_c o valor deve ser inferior ou igual ao estipulado pela CECRED */
    /*
    if( converteMoedaFloat($('#qtmxtbay', '#frmTab052').val()) > converteMoedaFloat($('#qtmxtbay_c', '#frmTab052').val())  ){
        showError('error','A quantidade m&aacute;xima de t&iacute;tulos por border&ocirc; Ayllos deve ser inferior ou igual ao estipulado pela CECRED','Alerta - Ayllos',"$(\'#qtmxtbay\',\'#frmTab052\').focus();");
        return false;
    }
    */
	return true;
	
}

function executar() {
    var operacao = $('#cddopcao', '#frmCab').val();
    manterRotina(operacao);
    return false;
}

function desbloqueia() {
    cTodosCabecalho.habilitaCampo();
    $('#frmTab052').css({'display': 'none'});
    $('#divBotoes').css({'display': 'none'});
    return false;
}

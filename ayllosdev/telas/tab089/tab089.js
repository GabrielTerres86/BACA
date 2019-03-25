/*
 * FONTE        : tab089.js
 * CRIAÇÃO      : Diego Simas/Reginaldo Silva/Letícia Terres - AMcom
 * DATA CRIAÇÃO : 12/01/2018
 * OBJETIVO     : Biblioteca de funções da tela TAB089
 * ---------------
 * ALTERAÇÕES
 *                30/05/2018 - Inclusão de campo de taxa de juros remuneratório de prejuízo (pctaxpre)
 *                             PRJ 450 - Diego Simas (AMcom)
 * 
 *                20/06/2018 - Inclusão do campo Prazo p/ transferência de valor da conta transitória para a CC *
 *                             PRJ 450 - Diego Simas (AMcom)
 * 
 * 10/07/2018 - PJ 438 - Agilidade nas Contratações de Crédito - Márcio (Mouts)
 *
 * 22/08/2018 - PJ 438 - Alterado a tela para o modo abas - Mateus Z (Mouts)
 *                14/09/2018 - Adicionado campo do valor max de estorno para desconto de titulo (Cássia de Oliveira - GFT)
 *
 *                30/10/2018 - PJ 438 - Adicionado 2 novos parametros (avtperda e vlperavt) - Mateus Z (Mouts)
 *
 *                12/12/2018 - PRJ 438 - Adicionado critica quando valor for zero no campo de Alteraçao de Avalista - Bruno Luiz
 *                                       Katzjarowski - Mout's
 * ---------------
 */

// Variáveis Globais 
var operacao = '';
var cddopcao = '';

var frmCab = 'frmCab';

var cTodosCabecalho = '';
var cTodosFiltro = '';

var abaAtual = '';

var glbTabCdmotivo, glbTabDsmotivo, glbTabTpproduto, glbTabInobservacao, glbTabIdativo, 
    glbTabQt_periodicidade, glbTabQt_envio, glbTabDs_assunto, glbTabDs_corpo;

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
    highlightObjFocus($('#frmTab089'));

    // PRJ 438
    // Atribuir destaque para a primeira aba
    $('#linkAba0').attr('class','txtBrancoBold');
    $('#imgAbaCen0').css('background-color','#969FA9');

    // PRJ 438
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
    cQtdictcc = $('#qtdictcc', '#frmTab089');
	
    cVlempres = $('#vlempres', '#frmTab089'); 
    cVlmaxest = $('#vlmaxest', '#frmTab089'); 
    cVltolemp = $('#vltolemp', '#frmTab089'); 
    cPcaltpar = $('#pcaltpar', '#frmTab089'); 
    cPctaxpre = $('#pctaxpre', '#frmTab089');
    cQtdpameq = $('#qtdpameq', '#frmTab089'); //PJ438 - Márcio (Mouts)	
    cQtditava = $('#qtditava', '#frmTab089'); //PJ438 - Márcio (Mouts)	
    cQtditapl = $('#qtditapl', '#frmTab089'); //PJ438 - Márcio (Mouts)	
    cQtditsem = $('#qtditsem', '#frmTab089'); //PJ438 - Márcio (Mouts)	
    cVlmaxdst = $('#vlmaxdst', '#frmTab089');
    cAvtperda = $('#avtperda', '#frmTab089'); // PRJ 438 - Sprint 5 - Mateus
    cVlperavt = $('#vlperavt', '#frmTab089'); // PRJ 438 - Sprint 5 - Mateus	

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
    cQtdictcc.css('width', '40px').setMask('INTEGER', 'zzz', '', '');

    cQtdpameq.css('width', '40px').setMask('INTEGER', 'zzz', '', ''); //PJ438 - Márcio (Mouts)
	cQtditava.css('width', '40px').setMask('INTEGER','zzz','',''); // PJ438 - Márcio (Mouts)
	cQtditapl.css('width', '40px').setMask('INTEGER','zzz','',''); // PJ438 - Márcio (Mouts)
	cQtditsem.css('width', '40px').setMask('INTEGER','zzz','',''); // PJ438 - Márcio (Mouts)
    cAvtperda.css('width', '150px'); // PRJ 438 - Sprint 5 - Mateus
	
    //Máscara para porcentagem
    cQtdibsem.css('width', '40px').setMask('INTEGER','zzz','','');
    cPcaltpar.css('width', '50px').setMask('DECIMAL','zzz,zz','','');
    cPctaxpre.css('width', '50px').setMask('DECIMAL', 'zzz,zz', '', '');
    //Máscara para moedas (Valor Monetário)
    cVlempres.css('width', '100px').addClass('moeda').setMask('DECIMAL', 'zzz.zzz.zzz,zz', '', ''); 
    cVlmaxest.css('width', '100px').addClass('moeda').setMask('DECIMAL', 'zzz.zzz.zzz,zz', '', ''); 
    cVltolemp.css('width', '100px').addClass('moeda').setMask('DECIMAL', 'zzz.zzz.zzz,zz', '', '');     
    cVlmaxdst.css('width', '100px').addClass('moeda').setMask('DECIMAL', 'zzz.zzz.zzz,zz', '', ''); 
    cVlperavt.css('width', '100px').setMask('DECIMAL', 'zzz.zzz.zzz,zz', '', ''); // PRJ 438 - Sprint 5 - Mateus

    cTodosFiltro = $('input[type="text"],select', '#frmTab089');
    // Limpa formulário
    cTodosFiltro.limpaFormulario();
    cTodosFiltro.habilitaCampo();

    cAvtperda.unbind('change').bind('change', function() {

        if(cAvtperda.val() == 0) { // Perde aprovação
            cVlperavt.desabilitaCampo();
            cVlperavt.val('');
        } else if(cAvtperda.val() == 1) { // Não perde aprovação
            cVlperavt.habilitaCampo();
        }

    });

    cAvtperda.unbind('keyup').bind('keyup', function() {

        if(cAvtperda.val() == 0) { // Perde aprovação
            cVlperavt.desabilitaCampo();
            cVlperavt.val('');
        } else if(cAvtperda.val() == 1) { // Não perde aprovação
            cVlperavt.habilitaCampo();
        }

    });

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
            $('#qtdpameq', '#frmTab089').focus(); // PJ438 - Márcio (Mouts)
            return false;
        }
    });

// Início PJ438 - Márcio (Mouts)
    $('#qtdpameq', '#frmTab089').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtdibaut', '#frmTab089').focus();
            return false;
        }
    });
// Fím PJ438 - Márcio (Mouts)

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

    $('#qtdibsem', '#frmTab089').unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#pctaxpre', '#frmTab089').focus();
            return false;
        }
    });

// Início PJ438 - Márcio (Mouts)
    $('#qtdibsem', '#frmTab089').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtditava', '#frmTab089').focus();
            return false;
}
    });
    $('#qtditava', '#frmTab089').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtditapl', '#frmTab089').focus();
            return false;
        }
    })
    $('#qtditapl', '#frmTab089').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtditsem', '#frmTab089').focus();
            return false;
        }
    })	
// Fím PJ438 - Márcio (Mouts)	
	
    $('#qtditsem', '#frmTab089').unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#pctaxpre', '#frmTab089').focus();
            return false;
        }
    });

    $('#pctaxpre', '#frmTab089').unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#qtdictcc', '#frmTab089').focus();
            return false;
        }
    });
	
    $('#qtdictcc', '#frmTab089').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {

            $('#vlmaxdst', '#frmTab089').focus();
            return false;
        }
    });

    $('#vlmaxdst', '#frmTab089').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#btContinuar').focus();
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
    } else if (abaAtual == 'motivos') {
        if (cddopcao == 'C' || cddopcao == 'A') {
            buscaMotivos();
        } else {
            mostraTelaIncluirMotivos();
        }
    } else if (abaAtual == 'email') {
        if (cddopcao == 'C' || cddopcao == 'A') {
            buscaEmails();
        } else {
            mostraTelaIncluirEmails();
        }
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
	var cQtdpameq = normalizaNumero($('#qtdpameq', '#frmTab089').val()); // PJ438 - Márcio (Mouts)
    var cQtdibaut = normalizaNumero($('#qtdibaut', '#frmTab089').val());
    var cQtdibapl = normalizaNumero($('#qtdibapl', '#frmTab089').val());
    var cQtdibsem = normalizaNumero($('#qtdibsem', '#frmTab089').val());
	var cQtditava = normalizaNumero($('#qtditava', '#frmTab089').val()); // PJ438 - Márcio (Mouts)
	var cQtditapl = normalizaNumero($('#qtditapl', '#frmTab089').val()); // PJ438 - Márcio (Mouts)
    var cQtditsem = normalizaNumero($('#qtditsem', '#frmTab089').val()); // PJ438 - Márcio (Mouts)
    var cQtdictcc = normalizaNumero($('#qtdictcc', '#frmTab089').val());
    var cVlempres = normalizaNumero($('#vlempres', '#frmTab089').val());
    var cVlmaxest = normalizaNumero($('#vlmaxest', '#frmTab089').val());
    var cVltolemp = normalizaNumero($('#vltolemp', '#frmTab089').val());
    var cPcaltpar = normalizaNumero($('#pcaltpar', '#frmTab089').val());
    var cPctaxpre = normalizaNumero($('#pctaxpre', '#frmTab089').val());
    var cQtdpameq = normalizaNumero($('#qtdpameq', '#frmTab089').val()); // PJ438 - Márcio (Mouts)
    var cQtditava = normalizaNumero($('#qtditava', '#frmTab089').val()); // PJ438 - Márcio (Mouts)
    var cQtditapl = normalizaNumero($('#qtditapl', '#frmTab089').val()); // PJ438 - Márcio (Mouts)
    var cQtditsem = normalizaNumero($('#qtditsem', '#frmTab089').val()); // PJ438 - Márcio (Mouts)
	var cAvtperda = normalizaNumero($('#avtperda', '#frmTab089').val()); // PJ438 - Sprint 5 - Mateus Z (Mouts)
    var cVlperavt = normalizaNumero($('#vlperavt', '#frmTab089').val()); // PJ438 - Sprint 5 - Mateus Z (Mouts)
    var cVlmaxdst = normalizaNumero($('#vlmaxdst', '#frmTab089').val());

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
			qtdpameq : cQtdpameq, //PJ438 - Márcio (Mouts)
            qtdibaut : cQtdibaut,
            qtdibapl : cQtdibapl,
            qtdibsem : cQtdibsem,
			qtditava : cQtditava, //PJ438 - Márcio (Mouts)
			qtditapl : cQtditapl, //PJ438 - Márcio (Mouts)
			qtditsem : cQtditsem, //PJ438 - Márcio (Mouts)
            qtdictcc : cQtdictcc,
            vlempres : cVlempres,
            vlmaxest : cVlmaxest,
            vltolemp : cVltolemp,
            pcaltpar : cPcaltpar,
            pctaxpre : cPctaxpre,
			vlmaxdst : cVlmaxdst,
	        avtperda : cAvtperda, // PJ438 - Sprint 5 - Mateus Z (Mouts)
            vlperavt : cVlperavt, // PJ438 - Sprint 5 - Mateus Z (Mouts)
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
		
		if(cAvtperda.val() == 0) { // Perde aprovação
            cVlperavt.desabilitaCampo();
            cVlperavt.val('');
        } else if(cAvtperda.val() == 1) { // Não perde aprovação
            cVlperavt.habilitaCampo();
        }
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
    var formTab = '#frmTab089';
    //bruno - prj 438 - validar campo alteracao de avalista
    var vlperavt = $('#vlperavt',formTab);
    var avtperda = $('#avtperda',formTab);

    if($(avtperda).val() == '1'){
        if($(vlperavt).val() == '0' || $(vlperavt).val() == ''){
            showError("error","Favor informar valor para Altera&ccedil;&atilde;o de Avalista.","Alerta - Ayllos","");
            return false;
        }
    }
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
        url: UrlSite + "telas/tab089/form_cabecalho_parametros.php", 
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

function acessaAbaMotivos(){

    // 1 = aba motivos
    controlarAbas(1);
    abaAtual = 'motivos';

    $.ajax({        
        type: "POST",
        url: UrlSite + "telas/tab089/form_cabecalho_motivos.php", 
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

function acessaAbaEmail(){
    
    // 2 = aba email    
    controlarAbas(2);
    abaAtual = 'email';

    $.ajax({        
        type: "POST",
        url: UrlSite + "telas/tab089/form_cabecalho_email.php", 
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
        url: UrlSite + "telas/tab089/form_tab089.php", 
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

function buscaMotivos(){

    showMsgAguardo('Aguarde, buscando motivos...');
        
    $.ajax({        
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/tab089/busca_motivos.php', 
        data: {
            redirect: 'html_ajax'           
            }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();           
            showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"unblockBackground()");
        },
        success: function(response) {
            hideMsgAguardo();
            try{
                $('#divConteudoOpcao').html(response);

                if (cddopcao == 'C'){
                    $("#btProsseguir","#divBotoes").hide();
                }else{
                    $("#btProsseguir","#divBotoes").show();
                }

                formataMotivos();
            } catch(error){
                showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
            }
        }
    });
    
}

function formataMotivos() {
    
    // tabela
    var divRegistro = $('div.divRegistros', '#divConteudoOpcao');
    var tabela = $('table', divRegistro);
        
    divRegistro.css({'height': '207px', 'padding-bottom': '2px'});

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '30px';
    arrayLargura[1] = '205px';
    arrayLargura[2] = '200px';
    arrayLargura[3] = '70px';
    arrayLargura[4] = '30px';
    
    var arrayAlinha = new Array();
    arrayAlinha[0] = 'right';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'center';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');
    
    glbTabCdmotivo     = undefined;
    glbTabDsmotivo     = undefined;
    glbTabTpproduto    = undefined;
    glbTabInobservacao = undefined;
    glbTabIdativo      = undefined;
    
    // seleciona o registro que é clicado
    $('table.tituloRegistros > tbody > tr', divRegistro).click( function() {
        glbTabCdmotivo     = $('#hcdmotivo' ,$(this)).val();
        glbTabDsmotivo     = $('#hdsmotivo' ,$(this)).val();
        glbTabTpproduto    = $('#htpproduto' ,$(this)).val();
        glbTabInobservacao = $('#hinobservacao' ,$(this)).val();
        glbTabIdativo      = $('#hidativo' ,$(this)).val();
    });

    $('table > tbody > tr:eq(0)', divRegistro).click();

    $('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
    $('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
    
    layoutPadrao();
    return false;   
}

function mostraTelaAlterarMotivos() {

    $.ajax({        
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/tab089/form_alterar_motivos.php', 
        data: {
            redirect: 'html_ajax'           
            }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();           
            showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"unblockBackground()");
        },
        success: function(response) {
            hideMsgAguardo();
            try{
                $('#divConteudoOpcao').html(response);
                formataAlterarMotivos();
            } catch(error){
                showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
            }
        }
    });

}

function formataAlterarMotivos() {

    highlightObjFocus( $('#frmAlterarMotivos') );
    
    rCdmotivo     = $('label[for="cdmotivo"]','#frmAlterarMotivos');
    rDsmotivo     = $('label[for="dsmotivo"]','#frmAlterarMotivos');
    rTpproduto    = $('label[for="tpproduto"]','#frmAlterarMotivos');
    rInobservacao = $('label[for="inobservacao"]','#frmAlterarMotivos');
    rIdativo      = $('label[for="idativo"]','#frmAlterarMotivos');

    rCdmotivo.addClass('rotulo').css({'width':'100px'});
    rDsmotivo.addClass('rotulo').css({'width':'100px'});
    rTpproduto.addClass('rotulo').css({'width':'100px'});
    rInobservacao.addClass('rotulo').css({'width':'100px'});
    rIdativo.addClass('rotulo').css({'width':'100px'});

    cCdmotivo     = $('#cdmotivo','#frmAlterarMotivos');
    cDsmotivo     = $('#dsmotivo','#frmAlterarMotivos');
    cTpproduto    = $('#tpproduto','#frmAlterarMotivos');
    cInobservacao = $('#inobservacao','#frmAlterarMotivos');
    cIdativo      = $('#idativo','#frmAlterarMotivos');

    cCdmotivo.addClass('campo inteiro').css({'width':'80px'}).attr('maxlength', '8');
    cDsmotivo.addClass('campo').css({'width':'350px'});
    cTpproduto.addClass('campo');
    cInobservacao.css({'margin': '3px 0px 3px 3px', 'height': '20px'});
    cIdativo.css({'margin': '3px 0px 3px 3px', 'height': '20px'});

    cCdmotivo.val(glbTabCdmotivo);
    cDsmotivo.val(glbTabDsmotivo);
    cTpproduto.val(glbTabTpproduto);
    cInobservacao.prop('checked', (1 == glbTabInobservacao));
    cIdativo.prop('checked', (1 == glbTabIdativo));

    $('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
    $('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
    
    layoutPadrao();
    return false;   
}

function alteraMotivo(){

    showMsgAguardo('Aguarde, alterando motivo ...');
    
    var cdmotivo     = $('#cdmotivo','#frmAlterarMotivos').val();
    var dsmotivo     = $('#dsmotivo','#frmAlterarMotivos').val();
    var tpproduto    = $('#tpproduto','#frmAlterarMotivos').val();
    var inobservacao = $('#inobservacao','#frmAlterarMotivos').is(':checked') ? 1 : 0;
    var idativo      = $('#idativo','#frmAlterarMotivos').is(':checked') ? 1 : 0;

    if (dsmotivo.length == 0){
        hideMsgAguardo();
        showError('error','Informe o nome da fase.','Alerta - Ayllos',"unblockBackground(); $('#dsmotivo','#frmAlterar').focus();");
        return false;
    }

    $.ajax({        
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/tab089/altera_motivo.php', 
        data: {
            cdmotivo: cdmotivo,
            dsmotivo: dsmotivo,
            tpproduto: tpproduto,
            inobservacao: inobservacao,
            idativo: idativo,
            redirect: 'html_ajax'           
            }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();           
            showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"unblockBackground()");
        },
        success: function(response) {
            hideMsgAguardo();
            try{
                eval(response);
            } catch(error){
                showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
            }           
        }
    });
    
}

function mostraTelaIncluirMotivos() {

    $.ajax({        
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/tab089/form_incluir_motivos.php', 
        data: {
            redirect: 'html_ajax'           
            }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();           
            showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"unblockBackground()");
        },
        success: function(response) {
            hideMsgAguardo();
            try{
                $('#divConteudoOpcao').html(response);
                formataIncluirMotivos();
            } catch(error){
                showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
            }
        }
    });

}

function formataIncluirMotivos() {
    
    rDsmotivo     = $('label[for="dsmotivo"]','#frmIncluirMotivos');
    rTpproduto    = $('label[for="tpproduto"]','#frmIncluirMotivos');
    rInobservacao = $('label[for="inobservacao"]','#frmIncluirMotivos');

    rDsmotivo.addClass('rotulo').css({'width':'100px'});
    rTpproduto.addClass('rotulo').css({'width':'100px'});
    rInobservacao.addClass('rotulo').css({'width':'100px'});

    cDsmotivo     = $('#dsmotivo','#frmIncluirMotivos');
    cTpproduto    = $('#tpproduto','#frmIncluirMotivos');
    cInobservacao = $('#inobservacao','#frmIncluirMotivos');

    cDsmotivo.addClass('campo').css({'width':'350px'});
    cTpproduto.addClass('campo');
    cInobservacao.css({'margin': '3px 0px 3px 3px', 'height': '20px'});

    $('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
    $('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});

    $('input, select', '#frmIncluirMotivos').val('');
    
    layoutPadrao();
    return false;
}

function incluiMotivo(){

    showMsgAguardo('Aguarde, incluindo motivo ...');
    
    var dsmotivo     = $('#dsmotivo','#frmIncluirMotivos').val();
    var tpproduto    = $('#tpproduto','#frmIncluirMotivos').val();
    var inobservacao = $('#inobservacao','#frmIncluirMotivos').is(':checked') ? 1 : 0;

    if (dsmotivo.length == 0){
        hideMsgAguardo();
        showError('error','Informe o nome da fase.','Alerta - Ayllos',"unblockBackground(); $('#dsmotivo','#frmAlterar').focus();");
        return false;
    }

    $.ajax({        
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/tab089/inclui_motivo.php', 
        data: {
            dsmotivo: dsmotivo,
            tpproduto: tpproduto,
            inobservacao: inobservacao,
            redirect: 'html_ajax'           
            }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();           
            showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"unblockBackground()");
        },
        success: function(response) {
            hideMsgAguardo();
            try{
                eval(response);
            } catch(error){
                showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
            }           
        }
    });
    
}

function buscaEmails(){

    showMsgAguardo('Aguarde, buscando par&acirc;metros dos e-mails...');
        
    $.ajax({        
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/tab089/busca_emails.php', 
        data: {
            redirect: 'html_ajax'           
            }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();           
            showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"unblockBackground()");
        },
        success: function(response) {
            hideMsgAguardo();
            try{
                $('#divConteudoOpcao').html(response);

                if (cddopcao == 'C'){
                    $("#btProsseguir","#divBotoes").hide();
                    $("#btConsultar","#divBotoes").show();
                }else{
                    $("#btProsseguir","#divBotoes").show();
                    $("#btConsultar","#divBotoes").hide();
                }

                formataEmails();
            } catch(error){
                showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
            }
        }
    });
    
}

function formataEmails() {
    
    // tabela
    var divRegistro = $('div.divRegistros', '#divConteudoOpcao');
    var tabela = $('table', divRegistro);
        
    divRegistro.css({'height': '207px', 'padding-bottom': '2px'});

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '200px';
    arrayLargura[1] = '85px';
    arrayLargura[2] = '65px';
    arrayLargura[3] = '200px';
    
    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'center';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, 'mostraTelaAlterarEmails()');
    
    glbTabTpproduto        = undefined;
    glbTabQt_periodicidade = undefined;
    glbTabQt_envio         = undefined;
    glbTabDs_assunto       = undefined;
    glbTabDs_corpo         = undefined;
    glbTabIdativo          = undefined;
    
    // seleciona o registro que é clicado
    $('table.tituloRegistros > tbody > tr', divRegistro).click( function() {
        glbTabTpproduto        = $('#htpproduto' ,$(this)).val();
        glbTabQt_periodicidade = $('#hqt_periodicidade' ,$(this)).val();
        glbTabQt_envio         = $('#hqt_envio' ,$(this)).val();
        glbTabDs_assunto       = $('#hds_assunto' ,$(this)).val();
        glbTabDs_corpo         = $('#hds_corpo' ,$(this)).val();
        glbTabIdativo          = $('#hidativo' ,$(this)).val();
    });

    $('table > tbody > tr:eq(0)', divRegistro).click();

    $('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
    $('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
    
    layoutPadrao();
    return false;   
}

function mostraTelaAlterarEmails() {

    $.ajax({        
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/tab089/form_alterar_emails.php', 
        data: {
            redirect: 'html_ajax'           
            }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();           
            showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"unblockBackground()");
        },
        success: function(response) {
            hideMsgAguardo();
            try{
                $('#divConteudoOpcao').html(response);
                formataAlterarEmails();
            } catch(error){
                showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
            }
        }
    });

}

function formataAlterarEmails() {

    highlightObjFocus( $('#frmAlterarEmails') );
    
    rTpproduto        = $('label[for="tpproduto"]','#frmAlterarEmails');
    rQt_periodicidade = $('label[for="qt_periodicidade"]','#frmAlterarEmails');
    rQt_envio         = $('label[for="qt_envio"]','#frmAlterarEmails');
    rDs_assunto       = $('label[for="ds_assunto"]','#frmAlterarEmails');
    rDs_corpo         = $('label[for="ds_corpo"]','#frmAlterarEmails');
    rIdativo          = $('label[for="idativo"]','#frmAlterarEmails');

    rTpproduto.addClass('rotulo').css({'width':'130px'});
    rQt_periodicidade.addClass('rotulo').css({'width':'130px'});
    rQt_envio.addClass('rotulo').css({'width':'130px'});
    rDs_assunto.addClass('rotulo').css({'width':'130px'});
    rDs_corpo.addClass('rotulo').css({'width':'130px'});
    rIdativo.addClass('rotulo').css({'width':'130px'});

    cTpproduto        = $('#tpproduto','#frmAlterarEmails');
    cQt_periodicidade = $('#qt_periodicidade','#frmAlterarEmails');
    cQt_envio         = $('#qt_envio','#frmAlterarEmails');
    cDs_assunto       = $('#ds_assunto','#frmAlterarEmails');
    cDs_corpo         = $('#ds_corpo','#frmAlterarEmails');
    cIdativo          = $('#idativo','#frmAlterarEmails');

    cTpproduto.addClass('campo inteiro').css({'width':'200px'});
    cQt_periodicidade.addClass('campo inteiro').css({'width':'50px'}).attr('maxlength', '5');
    cQt_envio.addClass('campo inteiro').css({'width':'50px'}).attr('maxlength', '2');
    cDs_assunto.addClass('campo').css({'width':'455px'}).attr('maxlength', '100');
    cDs_corpo.addClass('campo').css({'overflow-y': 'scroll', 'overflow-x': 'hidden', 'width': '455px', 'height': '152px', 'margin-left': '3px', 'resize': 'none'}).attr('maxlength', '300');
    cIdativo.css({'margin': '3px 0px 3px 3px', 'height': '20px'});

    cTpproduto.val(glbTabTpproduto);
    cQt_periodicidade.val(glbTabQt_periodicidade);
    cQt_envio.val(glbTabQt_envio);
    cDs_assunto.val(glbTabDs_assunto);
    cDs_corpo.val(glbTabDs_corpo);
    cIdativo.prop('checked', (1 == glbTabIdativo));

    // Acessar a tela no modo consulta
    if (cddopcao == 'C') {
        $('input, select, textarea','#frmAlterarEmails').desabilitaCampo();
        $('textarea','#frmAlterarEmails').removeClass('textarea').prop('disabled', true);
        $("#btProsseguir","#divBotoes").hide();
    }

    $('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
    $('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});
    
    layoutPadrao();
    return false;   
}

function alteraEmail(){

    showMsgAguardo('Aguarde, alterando par&acirc;metros email ...');
    
    var tpproduto        = $('#tpproduto','#frmAlterarEmails').val();
    var qt_periodicidade = $('#qt_periodicidade','#frmAlterarEmails').val();
    var qt_envio         = $('#qt_envio','#frmAlterarEmails').val();
    var ds_assunto       = $('#ds_assunto','#frmAlterarEmails').val();
    var ds_corpo         = $('#ds_corpo','#frmAlterarEmails').val();
    var idativo          = $('#idativo','#frmAlterarEmails').is(':checked') ? 1 : 0;

    if (qt_periodicidade.length == 0){
        hideMsgAguardo();
        showError('error','Informe a periodicidade.','Alerta - Ayllos',"unblockBackground(); $('#qt_periodicidade','#frmAlterarEmails').focus();");
        return false;
    }

    if (qt_envio.length == 0){
        hideMsgAguardo();
        showError('error','Informe a quantidade de envio.','Alerta - Ayllos',"unblockBackground(); $('#qt_envio','#frmAlterarEmails').focus();");
        return false;
    }

    if (ds_assunto.length == 0){
        hideMsgAguardo();
        showError('error','Informe o assunto do e-mail.','Alerta - Ayllos',"unblockBackground(); $('#ds_assunto','#frmAlterarEmails').focus();");
        return false;
    }

    if (ds_corpo.length == 0){
        hideMsgAguardo();
        showError('error','Informe o corpo do e-mail.','Alerta - Ayllos',"unblockBackground(); $('#ds_corpo','#frmAlterarEmails').focus();");
        return false;
    }

    $.ajax({        
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/tab089/altera_email.php', 
        data: {
            tpproduto: tpproduto,
            qt_periodicidade: qt_periodicidade,
            qt_envio: qt_envio,
            ds_assunto: ds_assunto,
            ds_corpo: ds_corpo,
            idativo: idativo,
            redirect: 'html_ajax'           
            }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();           
            showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"unblockBackground()");
        },
        success: function(response) {
            hideMsgAguardo();
            try{
                eval(response);
            } catch(error){
                showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
            }           
        }
    });
    
}

function mostraTelaIncluirEmails() {

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/tab089/form_incluir_emails.php',
        data: {
            redirect: 'html_ajax'
            },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();           
            showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"unblockBackground()");
        },
        success: function(response) {
            hideMsgAguardo();
            try{
                $('#divConteudoOpcao').html(response);
                formataIncluirEmails();
            } catch(error){
                showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
            }
        }
    });

}

function formataIncluirEmails() {
    
    rTpproduto        = $('label[for="tpproduto"]','#frmIncluirEmails');
    rQt_periodicidade = $('label[for="qt_periodicidade"]','#frmIncluirEmails');
    rQt_envio         = $('label[for="qt_envio"]','#frmIncluirEmails');
    rDs_assunto       = $('label[for="ds_assunto"]','#frmIncluirEmails');
    rDs_corpo         = $('label[for="ds_corpo"]','#frmIncluirEmails');

    rTpproduto.addClass('rotulo').css({'width':'130px'});
    rQt_periodicidade.addClass('rotulo').css({'width':'130px'});
    rQt_envio.addClass('rotulo').css({'width':'130px'});
    rDs_assunto.addClass('rotulo').css({'width':'130px'});
    rDs_corpo.addClass('rotulo').css({'width':'130px'});

    cTpproduto        = $('#tpproduto','#frmIncluirEmails');
    cQt_periodicidade = $('#qt_periodicidade','#frmIncluirEmails');
    cQt_envio         = $('#qt_envio','#frmIncluirEmails');
    cDs_assunto       = $('#ds_assunto','#frmIncluirEmails');
    cDs_corpo         = $('#ds_corpo','#frmIncluirEmails');

    cTpproduto.addClass('campo inteiro').css({'width':'200px'});
    cQt_periodicidade.addClass('campo inteiro').css({'width':'50px'}).attr('maxlength', '5');
    cQt_envio.addClass('campo inteiro').css({'width':'50px'}).attr('maxlength', '2');
    cDs_assunto.addClass('campo').css({'width':'455px'}).attr('maxlength', '100');
    cDs_corpo.addClass('campo').css({'overflow-y': 'scroll', 'overflow-x': 'hidden', 'width': '455px', 'height': '152px', 'margin-left': '3px', 'resize': 'none'}).attr('maxlength', '300');

    $('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
    $('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});

    $('input, select', '#frmIncluirEmails').val('');
    
    layoutPadrao();
    return false;   
}

function incluiEmail(){

    showMsgAguardo('Aguarde, incluindo e-mail ...');
    
    var tpproduto        = $('#tpproduto','#frmIncluirEmails').val();
    var qt_periodicidade = $('#qt_periodicidade','#frmIncluirEmails').val();
    var qt_envio         = $('#qt_envio','#frmIncluirEmails').val();
    var ds_assunto       = $('#ds_assunto','#frmIncluirEmails').val();
    var ds_corpo         = $('#ds_corpo','#frmIncluirEmails').val();

    if (qt_periodicidade.length == 0){
        hideMsgAguardo();
        showError('error','Informe a periodicidade.','Alerta - Ayllos',"unblockBackground(); $('#qt_periodicidade','#frmIncluirEmails').focus();");
        return false;
    }

    if (qt_envio.length == 0){
        hideMsgAguardo();
        showError('error','Informe a quantidade de envio.','Alerta - Ayllos',"unblockBackground(); $('#qt_envio','#frmIncluirEmails').focus();");
        return false;
    }

    if (ds_assunto.length == 0){
        hideMsgAguardo();
        showError('error','Informe o assunto do e-mail.','Alerta - Ayllos',"unblockBackground(); $('#ds_assunto','#frmIncluirEmails').focus();");
        return false;
    }

    if (ds_corpo.length == 0){
        hideMsgAguardo();
        showError('error','Informe o corpo do e-mail.','Alerta - Ayllos',"unblockBackground(); $('#ds_corpo','#frmIncluirEmails').focus();");
        return false;
    }

    $.ajax({        
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/tab089/inclui_email.php', 
        data: {
            tpproduto: tpproduto,
            qt_periodicidade: qt_periodicidade,
            qt_envio: qt_envio,
            ds_assunto: ds_assunto,
            ds_corpo: ds_corpo,
            redirect: 'html_ajax'           
            }, 
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();           
            showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"unblockBackground()");
        },
        success: function(response) {
            hideMsgAguardo();
            try{
                eval(response);
            } catch(error){
                showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground();');
            }           
        }
    });
    
}
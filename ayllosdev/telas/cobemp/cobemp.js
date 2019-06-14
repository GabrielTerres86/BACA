/*!
 * FONTE        : cobemp.js
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 13/08/2015
 * OBJETIVO     : Biblioteca de funções na rotina COBEMP
 * --------------
 * ALTERAÇÕES   : 04/02/2016 - Ajuste na procedure efetuaGeracaoBoleto para diferenciar
 *                             parcela de quitacao e atraso. (Rafael)
 *
 *                01/03/2017 - Inclusao de indicador se possui avalista, funcionamento de justificativa de baixa,
 *                             geracao de boleto em prejuizo, criacao da opcao Y - Boletagem Massiva. (P210.2 - Jaison/Daniel)
 *                  04/2019 - Ajustes Boleto Consignado P437 S6 - JDB AMcom
 */

//Labels/Campos do cabeçalho
var cCddopcao, cTodosCabecalho, cCdagenci, cTodosFrmManutencao, cTodosFrmContratos, cTodosFrmArquivos;
var glbNrdconta, glbNrctacob, glbNrdocmto, glbNrcnvcob, glbNrctremp, glbTipoVcto, glbTpdescto; /*P437 S6*/
var glbTipoVlr, glbLindigit, glbTpemprst,  glbAvalista, glbInprejuz, glbVlsdprej, glbIdarquivo, glbInsitarq;

// Definição de algumas variáveis globais
var cddopcao = 'C';

//Formulários
var frmCab = 'frmCab';

var nrdconta = 0; // Variável global para armazenar nr. da conta/dv
var nrdctitg = ""; // Variável global para armazenar nr. da conta integração
var inpessoa = ""; // Variável global para armazenar o tipo de pessoa (física/jurídica)
var idseqttl = ""; // Variável global para armazenar nr. da sequencia dos titulares
var cpfprocu = ""; // Variável global para armazenar nr. do cpf dos titulares
var dtdenasc = ""; // Variável global para armazenar a data de nascimento do titular
var cdhabmen = ""; // Variável global para armazenar o tipo de responsabilidade legal
var verrespo = false; //Variável global para indicar se deve validar ou nao os dados dos Resp.Legal na BO55
var permalte = false; // Está variável sera usada para controlar se a "Alteração/Exclusão/Inclusão - Resp. Legal" deverá ser feita somente na tela contas

var nrctremp = 0;
var nrparepr = 0;
var vlpagpar = '';

var arrayFeriados = new Array();


$(document).ready(function() {

    estadoInicial();

    highlightObjFocus($('#' + frmCab));
    highlightObjFocus($('#frmManutencao'));
    highlightObjFocus($('#frmContratos'));
    highlightObjFocus($('#frmArquivos'));

    $('fieldset > legend').css({'font-size': '11px', 'color': '#777', 'margin-left': '5px', 'padding': '0px 2px'});
    $('fieldset').css({'clear': 'both', 'border': '1px solid #777', 'margin': '3px 0px', 'padding': '10px 3px 5px 3px'});

    return false;

});

// seletores
function estadoInicial() {

    glbTipoVlr = 0;
    glbIdarquivo = 0;
    glbInsitarq = 0;

    $('#divTela').fadeTo(0, 0.1);
    $('#frmCab').css({'display': 'block'});

    $('#frmManutencao').css({'display': 'none'});
    $('#divBotoesfrmManutencao').css({'display': 'none'});
    $('#divTabfrmManutencao').html('');

    $('#frmContratos').css({'display': 'none'});
    $('#divBotoesfrmContratos').css({'display': 'none'});
    $('#divTabfrmContratos').html('');

    $('#frmArquivos').css({'display': 'none'});
    $('#divBotoesfrmArquivos').css({'display': 'none'});
    $('#divTabfrmArquivos').html('');

    // Limpa conteudo da divBotoes
    $('#divBotoes', '#divTela').html('');
    $('#divBotoes').css({'display': 'none'});

    // Aplica Layout nos fontes PHP
    formataCabecalho();
    formataFrmManutencao();
    formataFrmContratos();
    formataFrmArquivos();

    // Limpa informações dos Formularios
    cTodosCabecalho.limpaFormulario();
    cTodosFrmManutencao.limpaFormulario();
    cTodosFrmContratos.limpaFormulario();
    cTodosFrmArquivos.limpaFormulario();

    cCddopcao.val(cddopcao);

    removeOpacidade('divTela');
    unblockBackground();
    hideMsgAguardo();

    // Desativa campos do cabeçalho
    cTodosCabecalho.desabilitaCampo();

    controlaFoco();

    $('#cddopcao', '#frmCab').habilitaCampo();
    $('#cddopcao', '#' + frmCab).focus();

}

function formataCabecalho() {

    rCddopcao = $('label[for="cddopcao"]', '#' + frmCab);

    cCddopcao = $('#cddopcao', '#' + frmCab);
    cTodosCabecalho = $('input[type="text"],select', '#' + frmCab);
    btnCab = $('#btOK', '#' + frmCab);

    rCddopcao.css('width', '85px');

    cCddopcao.css({'width': '710px'});

    cTodosCabecalho.habilitaCampo();

    $('#cddopcao', '#' + frmCab).focus();

    layoutPadrao();
    return false;
}

function controlaOpcao() {

    if ($('#cddopcao', '#frmCab').hasClass('campoTelaSemBorda')) {
        return false;
    }

    // Desabilita campo opção
    cTodosCabecalho = $('input[type="text"],select', '#frmCab');
    cTodosCabecalho.desabilitaCampo();

    // M - Manutenção
    if ($('#cddopcao', '#frmCab').val() == 'M') {

        $('#frmManutencao').css({'display': 'block'});
        cCdagenci.focus();

    // Boletagem Massiva
    } else if ($('#cddopcao', '#frmCab').val() == 'Y') {

        $('#dtarqini', '#frmArquivos').val($('#dtarqini', '#frmArquivos').attr('dtini')).focus();
        $('#dtarqfim', '#frmArquivos').val($('#dtarqfim', '#frmArquivos').attr('dtfim'));

        carregaArquivos(1,15);

    // Contratos
    } else {

        $('#frmContratos').css({'display': 'block'});
        $('#nrdconta', '#frmContratos').focus();

    }

    // Se NAO for Boletagem Massiva
    if ($('#cddopcao', '#frmCab').val() != 'Y') {
        divBotoes();
        $('#divBotoes').css({'display': 'block'});
    }

    return false;

}

function formataFrmManutencao() {

    // cabecalho
    rCdagenci = $('label[for="cdagenci"]', '#frmManutencao');
    rNrctremp = $('label[for="nrctremp"]', '#frmManutencao');
    rdtemissi = $('label[for="dtemissi"]', '#frmManutencao');
    rdtemissf = $('label[for="dtemissf"]', '#frmManutencao');
    rNrdconta = $('label[for="nrdconta"]', '#frmManutencao');
    rNmprimtl = $('label[for="nmprimtl"]', '#frmManutencao');
    rdtvencti = $('label[for="dtvencti"]', '#frmManutencao');
    rdtvenctf = $('label[for="dtvenctf"]', '#frmManutencao');
    rdtbaixai = $('label[for="dtbaixai"]', '#frmManutencao');
    rdtbaixaf = $('label[for="dtbaixaf"]', '#frmManutencao');
    rdtpagtoi = $('label[for="dtpagtoi"]', '#frmManutencao');
    rdtpagtof = $('label[for="dtpagtof"]', '#frmManutencao');

    cCdagenci = $('#cdagenci', '#frmManutencao');
    cNrctremp = $('#nrctremp', '#frmManutencao');
    cdtemissi = $('#dtemissi', '#frmManutencao');
    cdtemissf = $('#dtemissf', '#frmManutencao');
    cNrdconta = $('#nrdconta', '#frmManutencao');
    cNmprimtl = $('#nmprimtl', '#frmManutencao');
    cdtvencti = $('#dtvencti', '#frmManutencao');
    cdtvenctf = $('#dtvenctf', '#frmManutencao');
    cdtbaixai = $('#dtbaixai', '#frmManutencao');
    cdtbaixaf = $('#dtbaixaf', '#frmManutencao');
    cdtpagtoi = $('#dtpagtoi', '#frmManutencao');
    cdtpagtof = $('#dtpagtof', '#frmManutencao');

    cTodosFrmManutencao = $('input[type="text"],select', '#frmManutencao');

    rCdagenci.css({'width': '105px'});
    rNrctremp.css({'width': '85px'});
    rdtemissi.css({'width': '105'});
    rdtemissf.css({'width': '28px'});
    rNrdconta.css({'width': '85px'});
    rNmprimtl.css({'width': '40px'});
    rdtvencti.css({'width': '317px'});
    rdtvenctf.css({'width': '28px'});
    rdtbaixai.css({'width': '105px'});
    rdtbaixaf.css({'width': '28px'});
    rdtpagtoi.css({'width': '317px'});
    rdtpagtof.css({'width': '28px'});

    cCdagenci.css({'width': '35px'}).setMask('INTEGER', 'zz9', '', '');
    cNrctremp.css({'width': '85px'}).addClass('contrato');
    cdtemissi.css({'width': '75px'}).setMask('DATE', '', '', '');
    cdtemissf.css({'width': '75px'}).setMask('DATE', '', '', '');
    cNrdconta.css({'width': '85px'}).addClass('conta');
    cNmprimtl.css({'width': '264px'});
    cdtvencti.css({'width': '75px'}).setMask('DATE', '', '', '');
    cdtvenctf.css({'width': '75px'}).setMask('DATE', '', '', '');
    cdtbaixai.css({'width': '75px'}).setMask('DATE', '', '', '');
    cdtbaixaf.css({'width': '75px'}).setMask('DATE', '', '', '');
    cdtpagtoi.css({'width': '75px'}).setMask('DATE', '', '', '');
    cdtpagtof.css({'width': '75px'}).setMask('DATE', '', '', '');

    cTodosFrmManutencao.habilitaCampo();

    cNmprimtl.desabilitaCampo();

    layoutPadrao();
    return false;
}

function formataFrmContratos() {

    // Cabecalho
    rNrdconta = $('label[for="nrdconta"]', '#frmContratos');
    rNmprimtl = $('label[for="nmprimtl"]', '#frmContratos');

    cNrdconta = $('#nrdconta', '#frmContratos');
    cNmprimtl = $('#nmprimtl', '#frmContratos');

    cTodosFrmContratos = $('input[type="text"],select', '#frmContratos');

    rNrdconta.css({'width': '85px'});
    rNmprimtl.css({'width': '40px'});

    cNrdconta.css({'width': '85px'}).addClass('conta');
    cNmprimtl.css({'width': '450px'});

    cTodosFrmContratos.habilitaCampo();

    cNmprimtl.desabilitaCampo();

    layoutPadrao();
    return false;
}

function formataFrmArquivos() {

    // cabecalho
    rDtarqini = $('label[for="dtarqini"]', '#frmArquivos');
    rDtarqfim = $('label[for="dtarqfim"]', '#frmArquivos');
    rNmarquiv = $('label[for="nmarquiv"]', '#frmArquivos');

    cDtarqini = $('#dtarqini', '#frmArquivos');
    cDtarqfim = $('#dtarqfim', '#frmArquivos');
    cNmarquiv = $('#nmarquiv', '#frmArquivos');

    cTodosFrmArquivos = $('input[type="text"],select', '#frmArquivos');

    rDtarqini.css({'width': '105'});
    rDtarqfim.css({'width': '28px'});
    rNmarquiv.css({'width': '200px'});

    cDtarqini.css({'width': '75px'}).setMask('DATE', '', '', '');
    cDtarqfim.css({'width': '75px'}).setMask('DATE', '', '', '');
    cNmarquiv.addClass('alphanum').css({'width': '264px'});

    cTodosFrmArquivos.habilitaCampo();

    layoutPadrao();
    return false;
}

function controlaFoco() {

    // frmCab
    $('#cddopcao', '#frmCab').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#btnOK', '#frmCab').focus();
            return false;
        }
    });

    // frmContratos
    $('#nrdconta', '#frmContratos').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {

            $('#nrdconta', '#frmContratos').removeClass('campoErro');
            if ($('#nrdconta', '#frmContratos').val() != '') {
                buscaAssociado();
                return false;
            } else {
                showError("error", "Numero da Conta deve ser informado.", "Alerta - Ayllos", "$('#nrdconta', '#frmContratos').focus()", false);
                return false;
            }
            // carregaContratos();
        }
    });

    //frmManutencao
    $('#cdagenci', '#frmManutencao').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#nrdconta', '#frmManutencao').focus();
            return false;
        }
    });

    $('#nrdconta', '#frmManutencao').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#nrdconta', '#frmManutencao').removeClass('campoErro');
            if ($('#nrdconta', '#frmManutencao').val() != '') {
                buscaAssociado();
                return false;
            } else {
                $('#nmprimtl', '#frmManutencao').val('');
                $('#nrctremp', '#frmManutencao').focus();
                return false;
            }
        }
    });

    $('#nrdconta', '#frmManutencao').unbind('blur').bind('blur', function(e) {
        if ($('#nrdconta', '#frmManutencao').val() != '') {
            buscaAssociado();
            return false;
        } else {
            $('#nmprimtl', '#frmManutencao').val('');
            $('#nrctremp', '#frmManutencao').focus();
            return false;
        }
    });

    $('#nrctremp', '#frmManutencao').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#dtemissi', '#frmManutencao').focus();
            return false;
        }
    });

    $('#dtemissi', '#frmManutencao').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#dtemissf', '#frmManutencao').focus();
            return false;
        }
    });

    $('#dtemissf', '#frmManutencao').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#dtvencti', '#frmManutencao').focus();
            return false;
        }
    });



    $('#dtvencti', '#frmManutencao').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#dtvenctf', '#frmManutencao').focus();
            return false;
        }
    });

    $('#dtvenctf', '#frmManutencao').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#dtbaixai', '#frmManutencao').focus();
            return false;
        }
    });

    $('#dtbaixai', '#frmManutencao').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#dtbaixaf', '#frmManutencao').focus();
            return false;
        }
    });

    $('#dtbaixaf', '#frmManutencao').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#dtpagtoi', '#frmManutencao').focus();
            return false;
        }
    });

    $('#dtpagtoi', '#frmManutencao').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#dtpagtof', '#frmManutencao').focus();
            return false;
        }
    });

    $('#dtpagtof', '#frmManutencao').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            carregaContratos();
            return false;
        }
    });

    //frmArquivos
    $('#dtarqini', '#frmArquivos').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#dtarqfim', '#frmArquivos').focus();
            return false;
        }
    });

    $('#dtarqfim', '#frmArquivos').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#nmarquiv', '#frmArquivos').focus();
            return false;
        }
    });

    $('#nmarquiv', '#frmArquivos').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            carregaArquivos(1,15);
            return false;
        }
    });

    return false;
}

function controlafrmEnviarSMS() {

    $('#nrdddtfc', '#frmEnviarSMS').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#nrtelefo', '#frmEnviarSMS').focus();
            return false;
        }
    });

    $('#nrtelefo', '#frmEnviarSMS').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#nmpescto', '#frmEnviarSMS').focus();
            return false;
        }
    });

    $('#nmpescto', '#frmEnviarSMS').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            validaEnvioSMS();
            return false;
        }
    });

    return false;

}

function carregaContratos() {

    if (cCddopcao.val() == 'C') {
        if ($('#nrdconta', '#frmContratos').hasClass('campoTelaSemBorda')) {
            return false;
        } else {
            validaBuscaContratos();
        }
    } else {
        if ($('#cdagenci', '#frmManutencao').hasClass('campoTelaSemBorda')) {
            return false;
        } else {
            validaBuscaContratos();

        }
    }

    return false;

}

function validaBuscaContratos() {

    if (cCddopcao.val() == 'M') {
        var nrdconta = normalizaNumero($('#nrdconta', '#frmManutencao').val());
        var nrctremp = normalizaNumero($('#nrctremp', '#frmManutencao').val());

        var dtbaixai = $('#dtbaixai', '#frmManutencao').val();
        //    var dtbaixaf = $('#dtbaixaf', '#frmManutencao').val();
        var dtemissi = $('#dtemissi', '#frmManutencao').val();
        //   var dtemissf = $('#dtemissf', '#frmManutencao').val();
        var dtvencti = $('#dtvencti', '#frmManutencao').val();
        //    var dtvenctf = $('#dtvenctf', '#frmManutencao').val();
        var dtpagtoi = $('#dtpagtoi', '#frmManutencao').val();
        //    var dtpagtof = $('#dtpagtof', '#frmManutencao').val();
    } else {
        var nrdconta = normalizaNumero($('#nrdconta', '#frmContratos').val());
    }

    if (cCddopcao.val() == 'C') {

        if (nrdconta == '') {
            showError("error", "Numero da Conta deve ser informado.", "Alerta - Ayllos", "$('#nrdconta', '#frmContratos').focus()", false);
        } else {
            buscaContratos(1, 15);
        }
    } else {

        if (nrdconta == '') {

            if (nrctremp != '') {
                showError("error", "Numero da Conta deve ser informado.", "Alerta - Ayllos", "$('#nrdconta', '#frmContratos').focus()", false);
            } else {

                if ((dtbaixai == '') && (dtemissi == '') && (dtvencti == '') && (dtpagtoi == '')) {
                    showError("error", "Pelo menos uma opcao de Data deve ser Informada!.", "Alerta - Ayllos", "$('#dtbaixai', '#frmManutencao').focus()", false);
                } else {
                    buscaContratos(1, 15);
                }
            }

        } else {
            buscaContratos(1, 15);
        }

    }

    return false;

}


function buscaContratos(nriniseq, nrregist) {

    var cddopcao = $('#cddopcao', '#frmCab').val();

    var nrdconta = 0;
    var cdagenci = 0;
    var nrctremp = 0;
    var dtbaixai = '';
    var dtbaixaf = '';
    var dtemissi = '';
    var dtemissf = '';
    var dtvencti = '';
    var dtvenctf = '';
    var dtpagtoi = '';
    var dtpagtof = '';

    if (cddopcao == 'M') {

        nrdconta = normalizaNumero($('#nrdconta', '#frmManutencao').val());
        nrctremp = normalizaNumero($('#nrctremp', '#frmManutencao').val());

        cdagenci = $('#cdagenci', '#frmManutencao').val();

        dtbaixai = $('#dtbaixai', '#frmManutencao').val();
        dtbaixaf = $('#dtbaixaf', '#frmManutencao').val();
        dtemissi = $('#dtemissi', '#frmManutencao').val();
        dtemissf = $('#dtemissf', '#frmManutencao').val();
        dtvencti = $('#dtvencti', '#frmManutencao').val();
        dtvenctf = $('#dtvenctf', '#frmManutencao').val();
        dtpagtoi = $('#dtpagtoi', '#frmManutencao').val();
        dtpagtof = $('#dtpagtof', '#frmManutencao').val();

    } else {
        nrdconta = normalizaNumero($('#nrdconta', '#frmContratos').val());
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, efetuando consulta ...");

    // Carrega dados parametro através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobemp/carrega_contratos.php',
        data:
                {
                    cdagenci: cdagenci,
                    cddopcao: cddopcao,
                    nrctremp: nrctremp,
                    nrdconta: nrdconta,
                    dtbaixai: dtbaixai,
                    dtbaixaf: dtbaixaf,
                    dtemissi: dtemissi,
                    dtemissf: dtemissf,
                    dtvencti: dtvencti,
                    dtvenctf: dtvenctf,
                    dtpagtoi: dtpagtoi,
                    dtpagtof: dtpagtof,
                    nriniseq: nriniseq,
                    nrregist: nrregist,
                    redirect: 'script_ajax'
                },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response) {
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {



                    if (cddopcao == 'C') {
                        $('#divTabfrmContratos').html(response);
                        $('#divTabfrmContratos').css({'display': 'block'});
                        $('#divBotoesfrmContratos').css({'display': 'block'});

                        formataContratos();
                        $('#divPesquisaRodape', '#divTabfrmContratos').formataRodapePesquisa();

                        cTodosFrmContratos.desabilitaCampo();

                    } else {
                        $('#divTabfrmManutencao').html(response);
                        $('#divTabfrmManutencao').css({'display': 'block'});
                        $('#divBotoesfrmManutencao').css({'display': 'block'});

                        formataContratosManutencao();
                        $('#divPesquisaRodape', '#divTabfrmManutencao').formataRodapePesquisa();

                        cTodosFrmManutencao.desabilitaCampo();
                    }

                    $('#divBotoes', '#divTela').html('');

                    hideMsgAguardo();
                    return false;
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

function formataContratos() {

    $('#divRotina').css('width', '640px');

    var divRegistro = $('div.divRegistros', '#divTabfrmContratos');
    var tabela = $('table', divRegistro);
//    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({'height': '220px', 'width': '1000px'});

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '35px';
    arrayLargura[1] = '35px';
    arrayLargura[2] = '60px';
    arrayLargura[3] = '130px';
    arrayLargura[4] = '35px'; //tipo cobranca
    arrayLargura[5] = '60px';
    arrayLargura[6] = '80px';
    arrayLargura[7] = '60px';
    arrayLargura[8] = '70px';
    arrayLargura[9] = '55px';
    arrayLargura[10] = '75px';
    arrayLargura[11] = '75px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'center';
	arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'center';
    arrayAlinha[6] = 'right';
    arrayAlinha[7] = 'center';
    arrayAlinha[8] = 'right';
    arrayAlinha[9] = 'right';
    arrayAlinha[10] = 'right';
    arrayAlinha[11] = 'right';
    arrayAlinha[12] = 'right';

    var metodoTabela = '';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

    var divRegistro = $('div.divRegistros', '#divContratos');

    glbNrctremp = '';

    // seleciona o registro que é clicado
    $('table > tbody > tr', divRegistro).click(function() {
        glbNrctremp = $(this).find('#nrctremp').val();
        nrctremp = $(this).find('#nrctremp').val();
        glbTpemprst = $(this).find('#tpemprst').val();
		glbNrcnvcob = $(this).find('#nrcnvcob').val();
        glbNrctacob = $(this).find('#nrctacob').val();
        glbAvalista = $(this).find('#avalista').val();
        glbInprejuz = $(this).find('#inprejuz').val();
        glbVlsdprej = $(this).find('#vlsdprej').val();
        glbTpdescto = $(this).find('#tpdescto').val(); /*P437 S6*/
    });

    glbNrdconta = normalizaNumero($('#nrdconta', '#frmContratos').val());
    nrdconta = normalizaNumero($('#nrdconta', '#frmContratos').val());



    $('table > tbody > tr:eq(0)', divRegistro).click();

    return false;
}

function formataContratosManutencao() {

    $('#divRotina').css('width', '640px');

    var divRegistro = $('div.divRegistros', '#divTabfrmManutencao');
    var tabela = $('table', divRegistro);
//    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({'height': '220px', 'width': '100%'});

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '30px';
    arrayLargura[1] = '75px';
    arrayLargura[2] = '75px';
    arrayLargura[3] = '60px';
    arrayLargura[4] = '90px';
    arrayLargura[5] = '60px';
    arrayLargura[6] = '75px';
    arrayLargura[7] = '60px';
    arrayLargura[8] = '75px';
    arrayLargura[9] = '60px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'right';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'right';
    arrayAlinha[5] = 'center';
    arrayAlinha[6] = 'right';
    arrayAlinha[7] = 'center';
    arrayAlinha[8] = 'right';
    arrayAlinha[9] = 'center';
    arrayAlinha[10] = 'center';

    var metodoTabela = '';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);


    // seleciona o registro que é clicado
    $('table > tbody > tr', divRegistro).click(function() {
        glbNrdconta = $(this).find('#nrdconta > span').text();
        glbNrdocmto = $(this).find('#nrdocmto > span').text();
        glbTpemprst = $(this).find('#tpemprst').val(); /*P437 S6*/
        glbNrcnvcob = $(this).find('#nrcnvcob').val();
        glbNrctacob = $(this).find('#nrctacob').val();
        glbLindigit = $(this).find('#lindigit').val();
        glbNrctremp = $(this).find('#nrctremp').val();
        glbTpdescto = $(this).find('#tpdescto').val(); /*P437 S6*/
    });

    $('table > tbody > tr:eq(0)', divRegistro).click();

    return false;
}

// Botao Voltar
function btnVoltar() {
    estadoInicial();
    return false;
}

// Monta divBotoes
function divBotoes() {

    $('#divBotoes', '#divTela').html('');
    $('#divBotoes', '#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>');
    $('#divBotoes', '#divTela').append('<a href="#" class="botao" onClick="carregaContratos()" return false;" >Consultar</a>');

    return false;
}

function pesquisaAssociados() {

    if (cCddopcao.val() == 'C') {

        if ($('#nrdconta', '#frmContratos').hasClass('campoTelaSemBorda')) {
            return false;
        }

        mostraPesquisaAssociado('nrdconta', 'frmContratos');
    } else {

        if ($('#nrdconta', '#frmManutencao').hasClass('campoTelaSemBorda')) {
            return false;
        }
        mostraPesquisaAssociado('nrdconta', 'frmManutencao');
    }


    return false;
}

function confirmaBaixaBoleto() {

    showConfirmacao('Confirma a Baixa do Boleto: ' + glbNrdocmto + ' ?', 'Confirma&ccedil;&atilde;o - Ayllos', 'abreJustificativaBaixa();', 'return false;', 'sim.gif', 'nao.gif');

}

function abreJustificativaBaixa() {

    showMsgAguardo('Aguarde, carregando rotina para justificativa de baixa...');

    // Executa script através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobemp/enviar_justificativa.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground()");
        },
        success: function(response) {
            $('#divRotina').html(response);
            montarFormJustificativa();
        }
    });

    return false;

}

function montarFormJustificativa() {

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobemp/tab_justificativa.php',
        data: {
            nrdconta: glbNrdconta,
            lindigit: glbLindigit,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground();");
        },
        success: function(response) {

            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divConteudoOpcao').html(response);
                    exibeRotina($('#divRotina'));

                    formataFormJustificativa();

                    hideMsgAguardo();
                    bloqueiaFundo($('#divRotina'));
                    $('#divRotina').setCenterPosition();
                    highlightObjFocus($('#frmJustificativa'));
                    return false;
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            } else {
                try {
                    eval(response);
                    controlaFoco();
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            }
        }
    });
    return false;
}

function formataFormJustificativa() {

    // Ajusta tamanho do form
    $('#divRotina').css('width', '400px');

    var cDsjustifica_baixa = $('#dsjustifica_baixa', '#frmJustificativa');

    cDsjustifica_baixa.addClass('campo alphanum').attr('maxlength', '200').css({'width':'350px', 'height':'70px'});

    layoutPadrao();
    hideMsgAguardo();

    cDsjustifica_baixa.focus();

    return false;
}

function validaFormJustificativa() {

    var dsjustif = $('#dsjustifica_baixa', '#frmJustificativa').val();

    if (dsjustif.length < 5) {
        showError('error', 'Justificativa da Baixa deve ser informada!', 'Alerta - Ayllos', "$('#dsjustifica_baixa', '#frmJustificativa').focus(); bloqueiaFundo($('#divRotina'))");
        return false;
    }

    baixarBoleto();

    return false;
}

function baixarBoleto() {

    showMsgAguardo('Aguarde, carregando rotina de baixa...');

    var dsjustif = $('#dsjustifica_baixa', '#frmJustificativa').val();

    // Executa script através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobemp/controla_operacao.php',
        data: {
            nrdconta: glbNrdconta,
            nrctremp: glbNrctremp,
            nrctacob: glbNrctacob,
            nrcnvcob: glbNrcnvcob,
            nrdocmto: glbNrdocmto,
            dsjustif: dsjustif,
            operacao: 'BAIXA_BOLETO',
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            try {
                hideMsgAguardo();
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });

    return false;

}

// Botão Enviar E-mail
function enviarEmail() {

    showMsgAguardo('Aguarde, carregando rotina para envio de e-mail...');

    // Executa script através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobemp/enviar_email.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground()");
        },
        success: function(response) {
            $('#divRotina').html(response);
            buscarDetalheEnvio();
        }
    });

    return false;

}

function buscarDetalheEnvio() {

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobemp/tab_enviar_email.php',
        data: {
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground();");
        },
        success: function(response) {

            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divConteudoOpcao').html(response);
                    exibeRotina($('#divRotina'));

                    formataEnvioEmail();

                    hideMsgAguardo();
                    bloqueiaFundo($('#divRotina'));
                    $('#divRotina').setCenterPosition();
                    return false;
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            } else {
                try {
                    eval(response);
                    controlaFoco();
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            }
        }
    });
    return false;
}

function formataEnvioEmail() {

    // Ajusta tamanho do form
    $('#divRotina').css('width', '600px');

    var frmEnviarEmail = "frmEnviarEmail";

    // Rotulos
    var rDsdemail = $('label[for="dsdemail"]', '#' + frmEnviarEmail);
    rDsdemail.addClass('rotulo').css('width', '100px');

    // Campos
    var cDsdemail = $('#dsdemail', '#' + frmEnviarEmail);
    cDsdemail.css('width', '380px').attr('maxlength', '60');

    layoutPadrao();
    hideMsgAguardo();

    cDsdemail.focus();

    return false;
}

function confirmaEnvioEmail() {

    if ($('#dsdemail', '#frmEnviarEmail').val() == '') {
        showError('error', 'E-mail deve ser informado!', 'Alerta - Ayllos', "bloqueiaFundo($('#divRotina'))");
        return false;
    } else {
        showConfirmacao('Confirma o Envio do Boleto: ' + glbNrdocmto + ' por E-mail ?', 'Confirma&ccedil;&atilde;o - Ayllos', 'processaEnvioEmail();', 'cancelaConfirmacao();', 'sim.gif', 'nao.gif');
    }
}

function processaEnvioEmail() {

    var dsdemail = $('#dsdemail', '#frmEnviarEmail').val();
    var indretor = 0;

    showMsgAguardo('Aguarde, carregando rotina para envio de email...');

    // Executa script através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobemp/controla_operacao.php',
        data: {
            nrdconta: glbNrdconta,
            nrctacob: glbNrctacob,
            nrdocmto: glbNrdocmto,
            nrcnvcob: glbNrcnvcob,
            nrctremp: glbNrctremp,
            tpdenvio: 1, // Email
            dsdemail: dsdemail,
            indretor: indretor,
            operacao: 'ENVIAR_EMAIL',
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            try {
                hideMsgAguardo();
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });

    return false;
}

function validaEnvioSMS() {

    var nrdddtfc = $('#nrdddtfc', '#frmEnviarSMS').val();
    var nmpescto = $('#nmpescto', '#frmEnviarSMS').val();
    var nrtelefo = $('#nrtelefo', '#frmEnviarSMS').val();

    if (nrdddtfc.length < 2) {
        showError('error', 'DDD deve ser informado!', 'Alerta - Ayllos', "$('#nrdddtfc', '#frmEnviarSMS').focus(); bloqueiaFundo($('#divRotina'))");


        return false;
    }

    if (nrtelefo.length < 8) {
        showError('error', 'Telefone deve ser informado!', 'Alerta - Ayllos', "$('#nrtelefo', '#frmEnviarSMS').focus(); bloqueiaFundo($('#divRotina'))");
        return false;
    }

    if (nmpescto.length < 2) {
        showError('error', 'Nome do Contato deve ser informado!', 'Alerta - Ayllos', "$('#nmpescto', '#frmEnviarSMS').focus(); bloqueiaFundo($('#divRotina'))");
        return false;
    }

    confirmaEnvioSMS();

    return false;
}

function processaEnvioSMS() {

    var nrdddtfc = $('#nrdddtfc', '#frmEnviarSMS').val();
    var nmpescto = $('#nmpescto', '#frmEnviarSMS').val();
    var nrtelefo = $('#nrtelefo', '#frmEnviarSMS').val();
    var textosms;
    var indretor = 0;

    showMsgAguardo('Aguarde, carregando rotina para envio de sms...');

    // Executa script através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobemp/controla_operacao.php',
        data: {
            nrdconta: glbNrdconta,
            nrctacob: glbNrctacob,
            nrdocmto: glbNrdocmto,
            nrcnvcob: glbNrcnvcob,
            nrctremp: glbNrctremp,
            tpdenvio: 2, // SMS
            nmpescto: nmpescto,
            nrdddtfc: nrdddtfc,
            nrtelefo: nrtelefo,
            textosms: textosms,
            indretor: indretor,
            operacao: 'ENVIAR_SMS',
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            try {
                hideMsgAguardo();
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });

    return false;

}

function cancelaConfirmacao() {
    bloqueiaFundo($('#divRotina'));
    return false;
}

function confirmaEnvioSMS() {

    showConfirmacao('Confirma o Envio do Linha Digitavel por SMS ?', 'Confirma&ccedil;&atilde;o - Ayllos', 'processaEnvioSMS();', 'cancelaConfirmacao();', 'sim.gif', 'nao.gif');

}

function confirmaImpressaoBoleto() {

    showConfirmacao('Confirma a Impress&atilde;o do Boleto: ' + glbNrdocmto + ' ?', 'Confirma&ccedil;&atilde;o - Ayllos', 'carregarImpressoBoleto();', '', 'sim.gif', 'nao.gif');

}

// Botão Enviar SMS
function enviarSMS() {

    showMsgAguardo('Aguarde, carregando rotina para envio de e-mail...');

    // Executa script através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobemp/enviar_sms.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground()");
        },
        success: function(response) {
            $('#divRotina').html(response);
            montarFormEnvioSMS();
        }
    });

    return false;

}

function montarFormEnvioSMS() {

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobemp/tab_enviar_sms.php',
        data: {
            nrdconta: glbNrdconta,
            lindigit: glbLindigit,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground();");
        },
        success: function(response) {

            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divConteudoOpcao').html(response);
                    exibeRotina($('#divRotina'));

                    formataFormEnvioSMS();

                    hideMsgAguardo();
                    bloqueiaFundo($('#divRotina'));
                    $('#divRotina').setCenterPosition();
                    return false;
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            } else {
                try {
                    eval(response);
                    controlaFoco();
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            }
        }
    });
    return false;
}

function formataFormEnvioSMS() {

    // Ajusta tamanho do form
    $('#divRotina').css('width', '600px');

    var frmEnviarSMS = "frmEnviarSMS";

    // Rotulos
    var rNrdddtfc = $('label[for="nrdddtfc"]', '#' + frmEnviarSMS);
    var rNrtelefo = $('label[for="nrtelefo"]', '#' + frmEnviarSMS);
    var rNmpescto = $('label[for="nmpescto"]', '#' + frmEnviarSMS);

    rNrdddtfc.addClass('rotulo').css('width', '50px');
    rNrtelefo.addClass('rotulo-linha').css('width', '60px');
    rNmpescto.addClass('rotulo-linha').css('width', '60px');

    // Campos
    var cNrdddtfc = $('#nrdddtfc', '#' + frmEnviarSMS);
    var cNrtelefo = $('#nrtelefo', '#' + frmEnviarSMS);
    var cNmpescto = $('#nmpescto', '#' + frmEnviarSMS);

    cNrdddtfc.addClass('inteiro').attr('maxlength', '3').css('width', '40px');
    cNrtelefo.addClass('inteiro').attr('maxlength', '10').css('width', '97px');
    cNmpescto.addClass('alphanum').attr('maxlength', '30').css('width', '220px');

    layoutPadrao();
    hideMsgAguardo();

    cNrdddtfc.focus();

    return false;
}


// Botão Log
function consultarLog(nriniseq, nrregist) {

    showMsgAguardo('Aguarde, carregando Consulta de Log...');

    // Executa script através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobemp/consultar_log.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground()");
        },
        success: function(response) {
            $('#divRotina').html(response);
            montarFormConsultaLog(nriniseq, nrregist);
        }
    });

    return false;

}

function montarFormConsultaLog(nriniseq, nrregist) {

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobemp/tab_consulta_log.php',
        data: {
            nrdconta: glbNrctacob,
            nrdocmto: glbNrdocmto,
            nrcnvcob: glbNrcnvcob,
            nriniseq: nriniseq,
            nrregist: nrregist,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground();");
        },
        success: function(response) {

            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {

                    $('#divConteudoOpcao').html(response);

                    exibeRotina($('#divRotina'));

                    formataFormConsultaLog();
                    $('#divPesquisaRodape', '#telaConsultaLog').formataRodapePesquisa();

                    hideMsgAguardo();
                    bloqueiaFundo($('#divRotina'));
                    $('#divRotina').setCenterPosition();
                    return false;
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            } else {
                try {
                    eval(response);
                    controlaFoco();
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            }
        }
    });
    return false;
}

function formataFormConsultaLog() {

    $('#divRotina').css('width', '740px');

    var divRegistro = $('div.divRegistros', '#divLogs');
    var tabela = $('table', divRegistro);
//    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({'height': '240px', 'width': '100%'});

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '110px';
    arrayLargura[1] = '430px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'center';

    var metodoTabela = '';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

    return false;
}

// Botão Telefone
function consultarTelefone(nriniseq, nrregist) {

    showMsgAguardo('Aguarde, carregando consulta...');

    // Executa script através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobemp/consultar_telefone.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground()");
        },
        success: function(response) {
            $('#divRotina').html(response);
            montarFormConsultaTelefone(nriniseq, nrregist);
        }
    });

    return false;

}

function montarFormConsultaTelefone(nriniseq, nrregist) {

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobemp/tab_consulta_telefone.php',
        data: {
            nrdconta: glbNrdconta,
            nriniseq: nriniseq,
            nrregist: nrregist,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground();");
        },
        success: function(response) {

            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {

                    $('#divConteudoOpcao').html(response);

                    exibeRotina($('#divRotina'));

                    formataFormConsultaTelefone();
                    $('#divPesquisaRodape', '#telaConsultaLog').formataRodapePesquisa();

                    hideMsgAguardo();
                    bloqueiaFundo($('#divRotina'));

                    $('#btVoltar', '#divBotoesTelefone').focus();

                    $('#divRotina').setCenterPosition();

                    return false;
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            } else {
                try {
                    eval(response);
                    controlaFoco();
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            }
        }
    });
    return false;
}

function formataFormConsultaTelefone() {

    $('#divRotina').css('width', '800px');

    var divRegistro = $('div.divRegistros', '#divTelefone');
    var tabela = $('table', divRegistro);
//    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({'height': '200px', 'width': '100%'});

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '90px';
    arrayLargura[1] = '50px';
    arrayLargura[2] = '100px';
    arrayLargura[3] = '50px';
    arrayLargura[4] = '110px';
    arrayLargura[5] = '90px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'center';
    arrayAlinha[6] = 'center';

    var metodoTabela = '';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

    $('table > tbody > tr', divRegistro).dblclick(function() {

		$('#nrdddtelefo', '#divTelefone').val($(this).find('#nrtelefo').val());
		$('#nrdddtelefo', '#divTelefone').focus();
		$('#nrdddtelefo', '#divTelefone').select();

		document.execCommand('copy');

		showError("inform", "Telefone Copiado para Area de Transferencia!", "Alerta - Ayllos", 'bloqueiaFundo(divRotina)');
    });

    return false;
}


// Botão E-mail
function consultarEmail(nriniseq, nrregist) {

    showMsgAguardo('Aguarde, carregando consulta...');

    // Executa script através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobemp/consultar_email.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground()");
        },
        success: function(response) {
            $('#divRotina').html(response);
            montarFormConsultaEmail(nriniseq, nrregist);
        }
    });

    return false;

}

function montarFormConsultaEmail(nriniseq, nrregist) {

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobemp/tab_consulta_email.php',
        data: {
            nrdconta: glbNrdconta,
            nriniseq: nriniseq,
            nrregist: nrregist,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground();");
        },
        success: function(response) {

            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {

                    $('#divConteudoOpcao').html(response);

                    exibeRotina($('#divRotina'));

                    formataFormConsultaEmail();
                    $('#divPesquisaRodape', '#telaConsultaEmail').formataRodapePesquisa();

                    hideMsgAguardo();
                    bloqueiaFundo($('#divRotina'));

                    $('#btVoltar', '#divBotoesEmail').focus();

                    return false;
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            } else {
                try {
                    eval(response);
                    controlaFoco();
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            }
        }
    });
    return false;
}

function formataFormConsultaEmail() {

    $('#divRotina').css('width', '600px');

    var divRegistro = $('div.divRegistros', '#divEmail');
    var tabela = $('table', divRegistro);
//    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({'height': '200px', 'width': '100%'});

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '300px';
    arrayLargura[1] = '100px';


    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'right';
    arrayAlinha[2] = 'right';

    var metodoTabela = '';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

    return false;
}

function pesquisaEmail() {
    procedure = 'BUSCAR_EMAIL';
    titulo = 'Consulta E-mail';
    qtReg = '20';
    filtrosPesq = 'E-mail;dsdemail;200px;S;;;descricao|Conta;nrdconta;100px;S;' + glbNrdconta + ';N';
    colunas = 'E-mail;dsdemail;100%;center';
    mostraPesquisa('TELA_COBEMP', procedure, titulo, qtReg, filtrosPesq, colunas, $('#divRotina'));
    return false;
}

function pesquisaCelular() {
    procedure = 'BUSCAR_CELULAR';
    titulo = 'Consulta Celular';
    qtReg = '20';
    filtrosPesq = 'DDD;nrdddtfc;200px;S;;N;descricao|Celular;nrtelefo;200px;S;;N;descricao|Contato;nmpescto;200px;S;;;descricao|Conta;nrdconta;100px;S;' + glbNrdconta + ';N';
    colunas = 'DDD;nrdddtfc;20%;center|Celular;nrtelefo;30%;center|Contato;nmpescto;50%;center';
    mostraPesquisa('TELA_COBEMP', procedure, titulo, qtReg, filtrosPesq, colunas, $('#divRotina'));
    return false;
}

function buscaAssociado() {

    var nrdconta;

    hideMsgAguardo();

    if ($('#cddopcao', '#frmCab').val() == 'M') {
        nrdconta = normalizaNumero($('#nrdconta', '#frmManutencao').val());
    } else {
        nrdconta = normalizaNumero($('#nrdconta', '#frmContratos').val());
    }

    var mensagem = 'Aguarde, buscando dados Cooperado ...';
    showMsgAguardo(mensagem);

    //Carrega dados da conta através de ajax
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/cobemp/busca_associado.php',
        data:
                {
                    cddopcao: $('#cddopcao', '#frmCab').val(),
                    nrdconta: nrdconta,
                    redirect: 'script_ajax'
                },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {

            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    hideMsgAguardo();
                    eval(response);
                    if ($('#cddopcao', '#frmCab').val() == 'C') {
                        carregaContratos();
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


function chamaRotinaManutencao() {

    if (glbNrctremp == '') {
        return false;
    }

    cCddopcao.val('M');

    $('#frmManutencao').css({'display': 'block'});
    $('#frmContratos').css({'display': 'none'});
    $('#divBotoesfrmContratos').css({'display': 'none'});

    var conta = $('#nrdconta', '#frmContratos').val();
    var nome = $('#nmprimtl', '#frmContratos').val();

    $('#nrdconta', '#frmManutencao').val(conta);
    $('#nmprimtl', '#frmManutencao').val(nome);
    $('#cdagenci', '#frmManutencao').val(0);
    $('#nrctremp', '#frmManutencao').val(glbNrctremp);

    $('#divTabfrmContratos').html('');

    divBotoes();

    buscaContratos(1, 15);
}

function confirmarGeracaoBoleto() {

    // deve chamar gerarBoleto
    showConfirmacao('Confirma a Geracao do Boleto?', 'Confirma&ccedil;&atilde;o - Ayllos', 'gerarBoleto();', 'return false;', 'sim.gif', 'nao.gif');

}

function validaGerarBoleto() {

	var nrdconta = glbNrdconta;
	var nrctacob = glbNrctacob;
    var nrcnvcob = glbNrcnvcob;
    var nrctremp = glbNrctremp;
    var tpdescto = glbTpdescto; /*P437 S6*/
    var tpemprst = glbTpemprst; /*P437 S6*/

	showMsgAguardo('Aguarde, validando rotina de Geracao de Boleto...');

	// Executa script através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobemp/valida_gerar_boleto.php',
        data: {
			nrdconta : nrdconta,
			nrctacob : nrctacob,
			nrcnvcob : nrcnvcob,
			nrctremp : nrctremp,
            tpdescto : tpdescto,
            tpemprst: tpemprst, /*P437 S6*/
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground()");
        },
        success: function(response) {
            eval(response);
			return false;
        }
    });

	return false;

}

function gerarBoleto() {

    var tpemprst = glbTpemprst;
    var inprejuz = glbInprejuz;
    var tpdescto = glbTpdescto; /*P437 S6*/
    var tpemprst = glbTpemprst; /*P437 S6*/

    // Executa script através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobemp/form_gerar_boleto.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground()");
        },
        success: function(response) {
            $('#divRotina').html(response);

            if (inprejuz == 1) {
                gerarBoletoPrejuizo();
            } else if (tpemprst == 1) {
                gerarBoletoPP();
            } else if (tpemprst == 2) {
                gerarBoletoPOS();
            } else {
                gerarBoletoTR();
            }
        }
    });

    return false;

}

function gerarBoletoTR() {

	$.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobemp/tab_gerar_boleto_tr.php',
        data: {
            avalista: glbAvalista,
            nrdconta: glbNrdconta,
            nrctremp: glbNrctremp,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground();");
        },
        success: function(response) {

            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divGerarBoleto').html(response);
                    exibeRotina($('#divRotina'));

                    formataGerarBoletoTR();

                    hideMsgAguardo();
                    bloqueiaFundo($('#divRotina'));
                    //      $('#divRotina').setCenterPosition();
                    return false;
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            } else {
                try {
                    eval(response);
                    controlaFoco();
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            }
        }
    });
    return false;
}

function formataGerarBoletoTR() {

    // Ajusta tamanho do form
    $('#divRotina').css('width', '500px');

    var frmGerarBoletoTR = "frmGerarBoletoTR";

    // Rotulos
    var rRdvencto = $('label[for="rdvencto"]', '#' + frmGerarBoletoTR);
    rRdvencto.addClass('rotulo').css('width', '120px');

    // Campos
    var cDtvencto  = $('#dtvencto',  '#' + frmGerarBoletoTR);
    var cRdvencto1 = $('#rdvencto1', '#' + frmGerarBoletoTR);
    var cRdvencto2 = $('#rdvencto2', '#' + frmGerarBoletoTR);
    var cRdsacado1 = $('#rdsacado1', '#' + frmGerarBoletoTR);
    var cRdsacado2 = $('#rdsacado2', '#' + frmGerarBoletoTR);
    var cNrcpfava  = $('#nrcpfava',  '#' + frmGerarBoletoTR);

    cDtvencto.css({'width': '75px'}).setMask('DATE', '', '', '');
    cRdvencto1.css({'margin-left': '100px'});
    cRdvencto2.css({'margin-left': '100px'});
    cRdsacado1.css({'margin-left': '100px'});
    cRdsacado2.css({'margin-left': '100px'});
    cNrcpfava.css({'width': '250px'}).addClass('campo').val('').desabilitaCampo();

    cDtvencto.desabilitaCampo();

    $("#dtvencto").datepicker('disable');

    layoutPadrao();
    hideMsgAguardo();

    return false;
}

function mostraValoresTR() {

    var vencimentoChecked = 0;

    if (document.getElementById("rdvencto1").checked == true) {
        vencimentoChecked = 1; // Data Atual
    }

    if (document.getElementById("rdvencto2").checked == true) {

        if ($('#dtvencto', '#frmGerarBoletoTR').val() == '') {
            showError('error', 'Data Futura deve ser Informada!', 'Alerta - Ayllos', "bloqueiaFundo($('#divRotina'))");
            return false;
        } else {
            vencimentoChecked = 2; // Data Futura
        }
    }

    if (vencimentoChecked == 0) {
        showError('error', 'Escolha uma Opcao de Vencimento!', 'Alerta - Ayllos', "bloqueiaFundo($('#divRotina'))");
        return false;
    }

    // Se possuir avalista
    if (glbAvalista == 1) {
        var sacadoChecked = normalizaNumero($('input[name="rdsacado"]:checked').val());

        if (sacadoChecked == 0) {
            showError('error', 'Escolha uma Opcao de Sacado!', 'Alerta - Ayllos', "bloqueiaFundo($('#divRotina'))");
            return false;
        }

        if (sacadoChecked == 2) {
            if ($('#nrcpfava', '#frmGerarBoletoTR').val() == '') {
                showError('error', 'Avalista deve ser Informado!', 'Alerta - Ayllos', "bloqueiaFundo($('#divRotina'))");
                return false;
            }
        }

        $('#rdsacado1, #rdsacado2, #nrcpfava', '#frmGerarBoletoTR').desabilitaCampo();
    }

    glbTipoVcto = vencimentoChecked;

    $('#divValoresTR').css({'display': 'block'});
    $('#divBotoesValoresTR').css({'display': 'block'});

    $('#divBotoesGerarBoletoTR').css({'display': 'none'});

    $('#rdvencto1', '#frmGerarBoletoTR').desabilitaCampo();
    $('#rdvencto2', '#frmGerarBoletoTR').desabilitaCampo();

    buscaValoresTR();

    $('#divValoresTR').css({'border-top': '1px solid #777777'});
    $('#divValoresTR').css({'margin-top': '5px'});
    $('#divValoresTR').css({'text-align': 'left'});


    layoutPadrao();

    $("#dtvencto").datepicker('disable');

    return false;
}


function buscaParcelasPP() {

    var dtvencto = '';

    if (document.getElementById("rdvencto1").checked == true) {
        dtvencto = $('#dtmvtolt', '#frmGerarBoletoPP').val();
    } else {
        dtvencto = $('#dtvencto', '#frmGerarBoletoPP').val();
    }

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobemp/busca_parcelas_pp.php',
        data: {
            nrdconta: glbNrdconta,
            nrctremp: glbNrctremp,
            tpdescto: glbTpdescto, /*P437 S6*/
            tpemprst: glbTpemprst, /*P437 S6*/
            dtvencto: dtvencto,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground();");
        },
        success: function(response) {

            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divParcelas').html(response);
                    controlaLayout('C_PAG_PREST');
                    formataParcelasPP();

                    hideMsgAguardo();
                    bloqueiaFundo($('#divRotina'));
                    return false;
                } catch (error) {
                    hideMsgAguardo();
                    //showError'error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
                    showError('error', error.message, 'Alerta - Ayllos', 'unblockBackground()');
                }
            } else {
                try {
                    eval(response);
                    controlaFoco();
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            }
        }
    });
    return false;
}

function habilitaDataVencimentoTR(valor) {

    if (valor == true) {
        $("#dtvencto").datepicker('enable');
    } else {
        $("#dtvencto").datepicker('disable');
    }

    return false;
}

function habilitaValorParcial(valor) {

    if (valor == 2) {
        $('#vlrpgto2', '#divValoresTR').habilitaCampo();
    } else {
        $('#vlrpgto2', '#divValoresTR').val('').desabilitaCampo();
    }

    glbTipoVlr = valor;

    return false;
}

function habilitaAvalista(valor) {

    if (valor == 2) {
        $('#nrcpfava').habilitaCampo();
    } else {
        $('#nrcpfava').val('').desabilitaCampo();
    }

    return false;
}

function retornaListaFeriados(cdcooper, dtmvtolt) {

    $.ajax({
        type: "POST",
        async: true,
        url: UrlSite + "telas/atenda/emprestimos/busca_feriados.php",
        data: {
            cdcooper: cdcooper,
            dtmvtolt: dtmvtolt,
            redirect: 'script_ajax' // Tipo de retorno do ajax
        },
        error: function(objAjax, responseError, objExcept) {
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "unblockBackground()");
        },
        success: function(response) {
            try {
                eval(response);
                return false;
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
            }
        }
    });

}

function confirmaGeracaoBoletoTR() {

    var dataVencimento;
    var valorBoleto = 0;

    if (glbTipoVcto == 1) { // Nesta Data
        dataVencimento = $('#dtmvtolt', '#frmGerarBoletoTR').val();
    } else {	// Data Futura
        dataVencimento = $('#dtvencto', '#frmGerarBoletoTR').val();
    }

    if (glbTipoVlr == 1) {
        valorBoleto = $('#vlrpgto1', '#divValoresTR').val();
    } else {
        if (glbTipoVlr == 2) {
            valorBoleto = $('#vlrpgto2', '#divValoresTR').val();
        } else {
			if (glbTipoVlr == 3) {
				valorBoleto = $('#vlrpgto3', '#divValoresTR').val();
			}
        }
    }

	if ( glbTipoVlr == 0 ) {
		showError('error', 'Selecione um tipo de pagamento!', 'Alerta - Ayllos', "bloqueiaFundo($('#divRotina'))");
	} else {

		if ( valorBoleto == 0 ){
			showError('error', 'N&atilde;o foram informados valores!', 'Alerta - Ayllos', "bloqueiaFundo($('#divRotina'))");
		} else {
			var msg = 'Sera gerado um boleto no valor de R$ ' + valorBoleto + ' <br/> com vencimento em ' + dataVencimento + '. Confirma Geracao?';
			showConfirmacao(msg, 'Confirma&ccedil;&atilde;o - Ayllos', 'efetuaGeracaoBoleto(\'TR\');', 'cancelaConfirmacao()', 'sim.gif', 'nao.gif')
		}
	}
}

function gerarBoletoPP() {

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobemp/tab_gerar_boleto_pp.php',
        data: {
            avalista: glbAvalista,
            nrdconta: glbNrdconta,
            nrctremp: glbNrctremp,
            tpdescto: glbTpdescto, /*P437 S6*/
            tpemprst: glbTpemprst, /*P437 S6*/
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground();");
        },
        success: function(response) {

            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divGerarBoleto').html(response);
                    exibeRotina($('#divRotina'));
                    /*
                     controlaLayout('C_PAG_PREST');
                     */
                    formataGerarBoletoPP();

                    hideMsgAguardo();
                    bloqueiaFundo($('#divRotina'));
                    $('#divRotina').centralizaRotinaH();
                    return false;
                } catch (error) {
                    hideMsgAguardo();
                    //showError'error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','unblockBackground()');
                    showError('error', error.message, 'Alerta - Ayllos', 'unblockBackground()');
                }
            } else {
                try {
                    eval(response);
                    controlaFoco();
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            }
        }
    });
    return false;
}


function formataGerarBoletoPP() {

    // Ajusta tamanho do form
    $('#divRotina').css('width', '780px');

    var frm = "frmGerarBoletoPP";

    // Rotulos
    var rRdvencto = $('label[for="rdvencto"]', '#' + frm);
    rRdvencto.addClass('rotulo').css('width', '270px');

    // Campos
    var cDtvencto = $('#dtvencto', '#' + frm);
    var cRdvencto1 = $('#rdvencto1', '#' + frm);
    var cRdvencto2 = $('#rdvencto2', '#' + frm);
    var cRdsacado1 = $('#rdsacado1', '#' + frm);
    var cRdsacado2 = $('#rdsacado2', '#' + frm);
    var cNrcpfava  = $('#nrcpfava',  '#' + frm);

    cDtvencto.css({'width': '75px'}).setMask('DATE', '', '', '');
    cRdvencto1.css({'margin-left': '200px'});
    cRdvencto2.css({'margin-left': '200px'});
    cRdsacado1.css({'margin-left': '200px'});
    cRdsacado2.css({'margin-left': '200px'});
    cNrcpfava.css({'width': '250px'}).addClass('campo').val('').desabilitaCampo();
    cDtvencto.desabilitaCampo();

    $("#dtvencto").datepicker('disable');

    layoutPadrao();

    return false;
}

function formataParcelasPP() {

    valorAtraso = 0;
    $("input[type=hidden][name='vlatraso[]']").each(function() {
        // Valor total a atual
        valorAtraso += retiraMascara(this.value);
    });

    $("input[type=hidden][name='vlmtapar[]']").each(function() {
        // Valor total a atual
        valorAtraso += retiraMascara(this.value);
    });

    $("input[type=hidden][name='vlmrapar[]']").each(function() {
        // Valor total a atual
        valorAtraso += retiraMascara(this.value);
    });

    $("input[type=hidden][name='vliofcpl[]']").each(function() {
        // Valor total a atual
        valorAtraso += retiraMascara(this.value);
    });

    var rTotAtras = $('label[for="totatras"]', '#frmVlParc');
    var cTotAtras = $('#totatras', '#frmVlParc');

    rTotAtras.addClass('rotulo').css({'width': '140px', 'padding-top': '3px', 'padding-bottom': '3px'});
    cTotAtras.addClass('campo').css({'width': '70px', 'padding-top': '3px', 'padding-bottom': '3px'});
    cTotAtras.addClass('rotulo moeda').desabilitaCampo();

    $('#totatras', '#frmVlParc').val(valorAtraso.toFixed(2).replace(".", ","));

    var rTotpagto = $('label[for="totpagto"]', '#frmVlParc');
    rTotpagto.addClass('rotulo').css({'margin-left': '355px'});

    layoutPadrao();

    return false;
}


function mostraValoresPP() {

    var checado = 0;

    if (document.getElementById("rdvencto1").checked == true) {
        checado = 1;
    }

    if (document.getElementById("rdvencto2").checked == true) {

        if ($('#dtvencto', '#frmGerarBoletoPP').val() == '') {
            showError('error', 'Data Futura deve ser Informata!', 'Alerta - Ayllos', "bloqueiaFundo($('#divRotina'))");
            return false;
        } else {
            checado = 2;
        }
    }

    if (checado == 0) {
        showError('error', 'Escolha uma Opcao de Vencimento!', 'Alerta - Ayllos', "bloqueiaFundo($('#divRotina'))");
        return false;
    }

    // Se possuir avalista
    if (glbAvalista == 1) {
        var sacadoChecked = normalizaNumero($('input[name="rdsacado"]:checked').val());

        if (sacadoChecked == 0) {
            showError('error', 'Escolha uma Opcao de Sacado!', 'Alerta - Ayllos', "bloqueiaFundo($('#divRotina'))");
            return false;
        }

        if (sacadoChecked == 2) {
            if ($('#nrcpfava', '#frmGerarBoletoPP').val() == '') {
                showError('error', 'Avalista deve ser Informado!', 'Alerta - Ayllos', "bloqueiaFundo($('#divRotina'))");
                return false;
            }
        }

        $('#rdsacado1, #rdsacado2, #nrcpfava', '#frmGerarBoletoPP').desabilitaCampo();
    }

    glbTipoVcto = checado;

    $('#divParcelas').css({'display': 'block'});
    $('#divBotoesGerarBoletoPP').css({'display': 'none'});

    $('#rdvencto1', '#frmGerarBoletoPP').desabilitaCampo();
    $('#rdvencto2', '#frmGerarBoletoPP').desabilitaCampo();

    layoutPadrao();

    $("#dtvencto").datepicker('disable');

    buscaParcelasPP();

    return false;
}

function gerarBoletoPOS() {

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobemp/tab_gerar_boleto_pos.php',
        data: {
            avalista: glbAvalista,
            nrdconta: glbNrdconta,
            nrctremp: glbNrctremp,
            tpemprst: glbTpemprst,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground();");
        },
        success: function(response) {

            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divGerarBoleto').html(response);
                    exibeRotina($('#divRotina'));
                    
                    formataGerarBoletoPOS();

                    hideMsgAguardo();
                    bloqueiaFundo($('#divRotina'));
                    $('#divRotina').centralizaRotinaH();
                    return false;
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', error.message, 'Alerta - Ayllos', 'unblockBackground()');
                }
            } else {
                try {
                    eval(response);
                    controlaFoco();
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            }
        }
    });
    return false;
}


function formataGerarBoletoPOS() {

    // Ajusta tamanho do form
    $('#divRotina').css('width', '780px');

    var frm = "frmGerarBoletoPOS";

    // Rotulos
    var rRdvencto = $('label[for="rdvencto"]', '#' + frm);
    rRdvencto.addClass('rotulo').css('width', '270px');

    // Campos
    var cDtvencto = $('#dtvencto', '#' + frm);
    var cRdvencto1 = $('#rdvencto1', '#' + frm);
    var cRdvencto2 = $('#rdvencto2', '#' + frm);
    var cRdsacado1 = $('#rdsacado1', '#' + frm);
    var cRdsacado2 = $('#rdsacado2', '#' + frm);
    var cNrcpfava  = $('#nrcpfava',  '#' + frm);

    cDtvencto.css({'width': '75px'}).setMask('DATE', '', '', '');
    cRdvencto1.css({'margin-left': '200px'});
    cRdvencto2.css({'margin-left': '200px'});
    cRdsacado1.css({'margin-left': '200px'});
    cRdsacado2.css({'margin-left': '200px'});
    cNrcpfava.css({'width': '250px'}).addClass('campo').val('').desabilitaCampo();
    cDtvencto.desabilitaCampo();

    $("#dtvencto").datepicker('disable');

    layoutPadrao();

    return false;
}

function formataParcelasPOS() {

    valorAtraso = 0;
    $("input[type=hidden][name='vlatraso[]']").each(function() {
        // Valor total a atual
        valorAtraso += retiraMascara(this.value);
    });

    $("input[type=hidden][name='vlmtapar[]']").each(function() {
        // Valor total a atual
        valorAtraso += retiraMascara(this.value);
    });

    $("input[type=hidden][name='vlmrapar[]']").each(function() {
        // Valor total a atual
        valorAtraso += retiraMascara(this.value);
    });

    $("input[type=hidden][name='vliofcpl[]']").each(function() {
        // Valor total a atual
        valorAtraso += retiraMascara(this.value);
    });

    var rTotAtras = $('label[for="totatras"]', '#frmVlParc');
    var cTotAtras = $('#totatras', '#frmVlParc');

    rTotAtras.addClass('rotulo').css({'width': '140px', 'padding-top': '3px', 'padding-bottom': '3px'});
    cTotAtras.addClass('campo').css({'width': '70px', 'padding-top': '3px', 'padding-bottom': '3px'});
    cTotAtras.addClass('rotulo moeda').desabilitaCampo();

    $('#totatras', '#frmVlParc').val(valorAtraso.toFixed(2).replace(".", ","));

    var rTotpagto = $('label[for="totpagto"]', '#frmVlParc');
    rTotpagto.addClass('rotulo').css({'margin-left': '355px'});

    layoutPadrao();

    return false;
}


function mostraValoresPOS() {

    var checado = 0;

    if (document.getElementById("rdvencto1").checked == true) {
        checado = 1;
    }

    if (document.getElementById("rdvencto2").checked == true) {

        if ($('#dtvencto', '#frmGerarBoletoPOS').val() == '') {
            showError('error', 'Data Futura deve ser Informata!', 'Alerta - Ayllos', "bloqueiaFundo($('#divRotina'))");
            return false;
        } else {
            checado = 2;
        }
    }

    if (checado == 0) {
        showError('error', 'Escolha uma Opcao de Vencimento!', 'Alerta - Ayllos', "bloqueiaFundo($('#divRotina'))");
        return false;
    }

    // Se possuir avalista
    if (glbAvalista == 1) {
        var sacadoChecked = normalizaNumero($('input[name="rdsacado"]:checked').val());

        if (sacadoChecked == 0) {
            showError('error', 'Escolha uma Opcao de Sacado!', 'Alerta - Ayllos', "bloqueiaFundo($('#divRotina'))");
            return false;
        }

        if (sacadoChecked == 2) {
            if ($('#nrcpfava', '#frmGerarBoletoPOS').val() == '') {
                showError('error', 'Avalista deve ser Informado!', 'Alerta - Ayllos', "bloqueiaFundo($('#divRotina'))");
                return false;
            }
        }

        $('#rdsacado1, #rdsacado2, #nrcpfava', '#frmGerarBoletoPOS').desabilitaCampo();
    }

    glbTipoVcto = checado;

    $('#divParcelas').css({'display': 'block'});
    $('#divBotoesGerarBoletoPOS').css({'display': 'none'});

    $('#rdvencto1', '#frmGerarBoletoPOS').desabilitaCampo();
    $('#rdvencto2', '#frmGerarBoletoPOS').desabilitaCampo();

    layoutPadrao();

    $("#dtvencto").datepicker('disable');

    buscaParcelasPOS();

    return false;
}

function confirmaGeracaoBoletoPOS() {

    recalculaTotal();

    var dataVencimento;
    var valorBoleto;

    if (document.getElementById("rdvencto1").checked == true) {
        dataVencimento = $('#dtmvtolt', '#frmGerarBoletoPOS').val();
    } else {
        dataVencimento = $('#dtvencto', '#frmGerarBoletoPOS').val();
    }

    valorBoleto = $('#totpagto', '#frmVlParc').val();

    if (valorBoleto == '0,00') {
        showError('error', 'Nenhum valor informado. Total a Pagar Zerado!', 'Alerta - Ayllos', "bloqueiaFundo($('#divRotina'))");
        return false;
    }

    var msg = '<center>Sera gerado um boleto no valor de R$ ' + valorBoleto + ' <br/> com vencimento em ' + dataVencimento + '.<br/>Confirma Geracao?</center>';
    showConfirmacao(msg, 'Confirma&ccedil;&atilde;o - Ayllos', 'efetuaGeracaoBoleto(\'POS\');', 'cancelaConfirmacao()', 'sim.gif', 'nao.gif');

}

function buscaParcelasPOS() {

    var dtvencto = '';

    if (document.getElementById("rdvencto1").checked == true) {
        dtvencto = $('#dtmvtolt', '#frmGerarBoletoPOS').val();
    } else {
        dtvencto = $('#dtvencto', '#frmGerarBoletoPOS').val();
    }

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobemp/busca_parcelas_pos.php',
        data: {
            nrdconta: glbNrdconta,
            nrctremp: glbNrctremp,
            dtvencto: dtvencto,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground();");
        },
        success: function(response) {

            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divParcelas').html(response);
                    controlaLayout('C_PAG_PREST');
                    formataParcelasPP();

                    hideMsgAguardo();
                    bloqueiaFundo($('#divRotina'));
                    return false;
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', error.message, 'Alerta - Ayllos', 'unblockBackground()');
                }
            } else {
                try {
                    eval(response);
                    controlaFoco();
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            }
        }
    });
    return false;
}

function copiarTextoSMS()
{
    $('#textosms', '#frmEnviarSMS').focus();
    $('#textosms', '#frmEnviarSMS').select();

    document.execCommand('copy');

    return false;

}

function carregarImpressoBoleto() {

    var vr_nmform = 'frmImpBoleto';
    var nrdconta = glbNrctacob;
    var nrcnvcob = glbNrcnvcob;
    var nrdocmto = glbNrdocmto;

    fechaRotina($('#divUsoGenerico'), $('#divRotina'));

    $('#sidlogin', '#' + vr_nmform).remove();
    $('#nrcnvcob1', '#' + vr_nmform).remove();
    $('#nrdocmto1', '#' + vr_nmform).remove();
    $('#nrdconta1', '#' + vr_nmform).remove();

    // Insere input do tipo hidden do formulário para enviá-los posteriormente
    $('#' + vr_nmform).append('<input type="text" id="nrcnvcob1" name="nrcnvcob1" />');
    $('#' + vr_nmform).append('<input type="text" id="nrdocmto1" name="nrdocmto1" />');
    $('#' + vr_nmform).append('<input type="text" id="nrdconta1" name="nrdconta1" />');
    $('#' + vr_nmform).append('<input type="text" id="sidlogin" name="sidlogin" />');

    // Agora insiro os devidos valores nos inputs criados
    $('#nrcnvcob1', '#' + vr_nmform).val(nrcnvcob);
    $('#nrdocmto1', '#' + vr_nmform).val(nrdocmto);
    $('#nrdconta1', '#' + vr_nmform).val(nrdconta);
    $('#sidlogin', '#' + vr_nmform).val($('#sidlogin', '#frmMenu').val());


    var action = UrlSite + 'telas/cobemp/imprimir_boleto.php';

    // Variavel para os comandos de controle
    var controle = '';

    carregaImpressaoAyllos(vr_nmform, action, controle);

    return false;
}

function confirmaGeracaoBoletoPP() {

	recalculaTotal();

    var dataVencimento;
    var valorBoleto;

    if (document.getElementById("rdvencto1").checked == true) {
        dataVencimento = $('#dtmvtolt', '#frmGerarBoletoPP').val();
    } else {
        dataVencimento = $('#dtvencto', '#frmGerarBoletoPP').val();
    }

    valorBoleto = $('#totpagto', '#frmVlParc').val();

    if (valorBoleto == '0,00') {
        showError('error', 'Nenhum valor informado. Total a Pagar Zerado!', 'Alerta - Ayllos', "bloqueiaFundo($('#divRotina'))");
        return false;
    }

    var msg = '<center>Sera gerado um boleto no valor de R$ ' + valorBoleto + ' <br/> com vencimento em ' + dataVencimento + '.<br/>Confirma Geracao?</center>';

    showConfirmacao(msg, 'Confirma&ccedil;&atilde;o - Ayllos', 'efetuaGeracaoBoleto(\'PP\');', 'cancelaConfirmacao()', 'sim.gif', 'nao.gif');

}

function efetuaGeracaoBoleto(tpemprst) {

    var dataVencimento;
    var totalPagar = 0;
    var totalAtraso = 0;
    var totalContrato = 0;
    var dsparepr = '';

    var tpparepr; // 1 = Parcela Normal, 2 = Total do atraso 3 = Parcial do atraso 4 = Quitação do contrato;

    if (tpemprst == 'PP') {

        var nrcpfava = normalizaNumero($('#nrcpfava', '#frmGerarBoletoPP').val());

        if (document.getElementById("rdvencto1").checked == true) {
            dataVencimento = $('#dtmvtolt', '#frmGerarBoletoPP').val();
        } else {
            dataVencimento = $('#dtvencto', '#frmGerarBoletoPP').val();
        }

        totalPagar = $('#totpagto', '#frmVlParc').val().toString().replace(".", "");
        totalAtraso = $('#totatras', '#frmVlParc').val().toString().replace(".", "");
        totalContrato = $('#totatual', '#frmVlParc').val().toString().replace(".", "");

        if (parseFloat(totalPagar) == parseFloat(totalContrato)) {
            tpparepr = 4; // 4 = Quitação do contrato
        }

        if (parseFloat(totalPagar) == parseFloat(totalAtraso)) {
            tpparepr = 2; //2 = Total do atraso
        }

        if (parseFloat(totalPagar) < parseFloat(totalAtraso)) {
            tpparepr = 3; // 3 = Parcial do atraso
        }

        if (tpparepr == 4) {
            dsparepr = '';
        } else {

            var parcelasPagas = new Array();
            var nrParcela;

            $("input[type=checkbox][name='checkParcelas[]']:checked").each(function() {
                nrParcela = this.id.split("_")[1];
                parcelasPagas.push(nrParcela);
            });

            dsparepr = parcelasPagas.toString();
        }

    } else if (tpemprst == 'POS') {

        var nrcpfava = normalizaNumero($('#nrcpfava', '#frmGerarBoletoPOS').val());

        if (document.getElementById("rdvencto1").checked == true) {
            dataVencimento = $('#dtmvtolt', '#frmGerarBoletoPOS').val();
        } else {
            dataVencimento = $('#dtvencto', '#frmGerarBoletoPOS').val();
        }

        totalPagar    = $('#totpagto', '#frmVlParc').val().toString().replace(".", "");
        totalAtraso   = $('#totatras', '#frmVlParc').val().toString().replace(".", "");
        totalContrato = $('#totatual', '#frmVlParc').val().toString().replace(".", "");


        if (parseFloat(totalPagar) == parseFloat(totalContrato)) {
            tpparepr = 4; // 4 = Quitação do contrato
        }

        if (parseFloat(totalPagar) == parseFloat(totalAtraso)) {
            tpparepr = 2; //2 = Total do atraso
        }

        if (parseFloat(totalPagar) < parseFloat(totalAtraso)) {
            tpparepr = 3; // 3 = Parcial do atraso
        }


        if (tpparepr == 4) {
            dsparepr = '';
        } else {

            var parcelasPagas = new Array();
            var nrParcela;

            $("input[type=checkbox][name='checkParcelas[]']:checked").each(function() {
                nrParcela = this.id.split("_")[1];
                parcelasPagas.push(nrParcela);
            });

            dsparepr = parcelasPagas.toString();
        }

    } else if (tpemprst == 'TR') {

        var nrcpfava = normalizaNumero($('#nrcpfava', '#frmGerarBoletoTR').val());

        if (document.getElementById("rdvencto1").checked == true) {
            dataVencimento = $('#dtmvtolt', '#frmGerarBoletoTR').val();
        } else {
            dataVencimento = $('#dtvencto', '#frmGerarBoletoTR').val();
        }

        if (document.getElementById("tpvlpgto1").checked == true) {
            totalPagar = $('#vlrpgto1', '#frmGerarBoletoTR').val();
			tpparepr = 2; //2 = Total do atraso
        } else if (document.getElementById("tpvlpgto2").checked == true) {
            totalPagar = $('#vlrpgto2', '#frmGerarBoletoTR').val();
			tpparepr = 3; // 3 = Parcial do atraso
			
			var valoraux1 = $('#vlrpgto1', '#frmGerarBoletoTR').val().replace('.','').replace(',','.').replace(/\s*/g,'')
			var valoraux2 = $('#vlrpgto2', '#frmGerarBoletoTR').val().replace('.','').replace(',','.').replace(/\s*/g,'');
			
			valoraux1 = parseFloat(valoraux1);
			valoraux2 = parseFloat(valoraux2);
	
			if ( valoraux2 >= valoraux1 ) {
				showError("error", "Valor Parcial do Atraso deve ser menor que o Valor do Atraso.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
				return false;
			}
			
			
        } else {
			if (document.getElementById("tpvlpgto3").checked == true) {
				totalPagar = $('#vlrpgto3', '#frmGerarBoletoTR').val();
				if ($('#vlrpgto1', '#frmGerarBoletoTR').val() == $('#vlrpgto3', '#frmGerarBoletoTR').val()) {
				  tpparepr = 2; // 2 = Total do atraso
				} else {
				  tpparepr = 4; // 4 = Quitação do contrato
				}
			}
        }

    } else if (tpemprst == 'PRJZ') { // PREJUIZO

        var nrcpfava = 0;
        var totalPagar = $('#vlquitac', '#frmGerarBoletoTR').val();
        var vldescto = converteMoedaFloat($('#vldescto', '#frmGerarBoletoTR').val());

        if (document.getElementById("tpvlpgto1").checked == true) {
            if (vldescto > 0) {
                tpparepr = 7; // 7 = Saldo Prejuizo Desconto
            } else {
                tpparepr = 5; // 5 = Saldo Prejuizo
            }
        } else if (document.getElementById("tpvlpgto2").checked == true) {
            tpparepr = 6; // 6 = Parcial Prejuizo
        }

        if (document.getElementById("rdvencto1").checked == true) {
            dataVencimento = $('#dtmvtolt', '#frmGerarBoletoTR').val();
        } else {
            dataVencimento = $('#dtvencto', '#frmGerarBoletoTR').val();
        }
    }

    showMsgAguardo('Aguarde, efetuando a geracao do boleto...');

    // Executa script através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobemp/efetua_geracao_boleto.php',
        data: {
            nrdconta: glbNrdconta,
            nrctremp: glbNrctremp,
            tpdescto: glbTpdescto, /*P437 S6*/
            tpparepr: tpparepr,
            dsparepr: dsparepr,
            dtvencto: dataVencimento,
            vlparepr: totalPagar,
            tpemprst: tpemprst,
            nrcpfava: nrcpfava,
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            try {
                hideMsgAguardo();
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });

}

function buscaValoresTR() {

	var dtmvtolt = '';

    showMsgAguardo('Aguarde, consultando contrato...');

	if (document.getElementById("rdvencto1").checked == true) {
        dtmvtolt = $('#dtmvtolt', '#frmGerarBoletoTR').val() ; // Data Atual
    } else {

		dtmvtolt = $('#dtvencto', '#frmGerarBoletoTR').val() ;
    }

    // Executa script através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobemp/busca_valores_tr.php',
        data: {
            nrdconta: glbNrdconta,
            nrctremp: glbNrctremp,
			dtmvtolt: dtmvtolt,
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            try {
                $('#divValoresTR').html(response);

                var cTpvlpgto1 = $('#tpvlpgto1', '#divValoresTR');
                var cTpvlpgto2 = $('#tpvlpgto2', '#divValoresTR');
                var cTpvlpgto3 = $('#tpvlpgto3', '#divValoresTR');

                cTpvlpgto1.css({'margin-left': '30px'});
                cTpvlpgto1.css({'padding-top': '10px'});
                cTpvlpgto2.css({'margin-left': '30px'});
                cTpvlpgto3.css({'margin-left': '30px'});

                $('#vlrpgto1', '#divValoresTR').addClass('moeda').desabilitaCampo();
                $('#vlrpgto2', '#divValoresTR').addClass('moeda').desabilitaCampo();
                $('#vlrpgto3', '#divValoresTR').addClass('moeda').desabilitaCampo();

                $('#divValoresTR').css({'border-top': '1px solid #777777'});
                $('#divValoresTR').css({'margin-top': '5px'});
                $('#divValoresTR').css({'text-align': 'left'});

                layoutPadrao();

                hideMsgAguardo();
                bloqueiaFundo($('#divRotina'));
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });

    return false;

}

function controlaPesquisaPac() {

    var cdagenci = 0;

    procedure = 'BUSCA_LISTA_PA';
    titulo = 'Pesquisa PA';
    qtReg = '999';
    filtrosPesq = 'Cod. PA;cdagenci;30px;S;' + cdagenci + ';S';
    colunas = 'Codigo;cdagenci;20%;right|descricao;nmresage;50%;left';
    mostraPesquisa('TELA_COBEMP', procedure, titulo, qtReg, filtrosPesq, colunas, '');
    return false;

}

function gerarBoletoPrejuizo() {

	$.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobemp/tab_gerar_boleto_prejuizo.php',
        data: {
            nrdconta: glbNrdconta,
            nrctremp: glbNrctremp,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground();");
        },
        success: function(response) {

            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divGerarBoleto').html(response);
                    exibeRotina($('#divRotina'));

                    formataGerarBoletoTR();

                    hideMsgAguardo();
                    bloqueiaFundo($('#divRotina'));
                    return false;
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            } else {
                try {
                    eval(response);
                    controlaFoco();
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            }
        }
    });
    return false;
}

function mostraValoresPrejuizo() {

    var vencimentoChecked = 0;

    if (document.getElementById("rdvencto1").checked == true) {
        vencimentoChecked = 1; // Data Atual
    }

    if (document.getElementById("rdvencto2").checked == true) {

        if ($('#dtvencto', '#frmGerarBoletoTR').val() == '') {
            showError('error', 'Data Futura deve ser Informada!', 'Alerta - Ayllos', "bloqueiaFundo($('#divRotina'))");
            return false;
        } else {
            vencimentoChecked = 2; // Data Futura
        }
    }

    if (vencimentoChecked == 0) {
        showError('error', 'Escolha uma Opcao de Vencimento!', 'Alerta - Ayllos', "bloqueiaFundo($('#divRotina'))");
        return false;
    }

    glbTipoVcto = vencimentoChecked;

    $('#divValoresTR').css({'display': 'block'});
    $('#divBotoesValoresTR').css({'display': 'block'});

    $('#divBotoesGerarBoletoTR').css({'display': 'none'});

    $('#rdvencto1', '#frmGerarBoletoTR').desabilitaCampo();
    $('#rdvencto2', '#frmGerarBoletoTR').desabilitaCampo();

    buscaValoresPrejuizo();

    $('#divValoresTR').css({'border-top': '1px solid #777777'});
    $('#divValoresTR').css({'margin-top': '5px'});
    $('#divValoresTR').css({'text-align': 'left'});


    layoutPadrao();

    $("#dtvencto").datepicker('disable');

    return false;
}

function buscaValoresPrejuizo() {

	var dtmvtolt = '';

    showMsgAguardo('Aguarde, consultando contrato...');

	if (document.getElementById("rdvencto1").checked == true) {
        dtmvtolt = $('#dtmvtolt', '#frmGerarBoletoTR').val() ; // Data Atual
    } else {

		dtmvtolt = $('#dtvencto', '#frmGerarBoletoTR').val() ;
    }

    // Executa script através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobemp/busca_valores_prejuizo.php',
        data: {
            vlsdprej: glbVlsdprej,
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            try {
                $('#divValoresTR').html(response);

                var cTpvlpgto1 = $('#tpvlpgto1', '#divValoresTR');
                var cTpvlpgto2 = $('#tpvlpgto2', '#divValoresTR');

                cTpvlpgto1.css({'margin-left': '30px','padding-top': '10px'}).prop('checked', true);
                cTpvlpgto2.css({'margin-left': '30px'});

                glbTipoVlr = 1;

                $('#vlrpgto1', '#divValoresTR').addClass('moeda').desabilitaCampo();
                $('#vlrpgto2', '#divValoresTR').addClass('moeda').desabilitaCampo();
                $('#vlquitac', '#divValoresTR').addClass('moeda').desabilitaCampo();
                $('#vldescto', '#divValoresTR').addClass('moeda');

                $('#divValoresTR').css({'border-top': '1px solid #777777'});
                $('#divValoresTR').css({'margin-top': '5px'});
                $('#divValoresTR').css({'text-align': 'left'});

                layoutPadrao();

                hideMsgAguardo();
                bloqueiaFundo($('#divRotina'));
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });

    return false;

}

function habilitaValorParcialPrejuizo(valor,permis) {

    if (valor == 2) {
        $('#vlrpgto2', '#divValoresTR').habilitaCampo().focus();
        $('#vldescto', '#divValoresTR').val('0,00').desabilitaCampo();
        $('#vlquitac', '#divValoresTR').val('');
    } else {
        $('#vlrpgto2', '#divValoresTR').val('').desabilitaCampo();
        $('#vlquitac', '#divValoresTR').val($('#vlrpgto1', '#divValoresTR').val());
        if (permis == 1) {
            $('#vldescto', '#divValoresTR').val('0,00').habilitaCampo();
        } else {
            $('#vldescto', '#divValoresTR').val('0,00').desabilitaCampo();
        }
    }

    glbTipoVlr = valor;

    return false;
}

function exibeValorPrejuizo(tipo) {
    var vlquitac;
    if (tipo == 'P') { // Parcial
        vlquitac = $('#vlrpgto2', '#divValoresTR').val();
    } else { // Desconto
        var vltotal  = converteMoedaFloat($('#vlrpgto1', '#divValoresTR').val());
        var vldescto = converteMoedaFloat($('#vldescto', '#divValoresTR').val());
        var descprej = converteMoedaFloat($('#descprej', '#divValoresTR').val());
        if (vldescto <= descprej) {
            vlquitac = vltotal - ((vltotal * vldescto) / 100);
        } else {
            vlquitac = vltotal;
        }
        vlquitac = number_format(vlquitac, 2, ',', '.');
    }
    $('#vlquitac', '#divValoresTR').val(vlquitac);
}

function confirmaGeracaoBoletoPrejuizo() {

    var valorBoleto;
    var dataVencimento;
    var descprej = converteMoedaFloat($('#descprej', '#divValoresTR').val());
    var vldescto = converteMoedaFloat($('#vldescto', '#divValoresTR').val());
    var vlrpgto2 = converteMoedaFloat($('#vlrpgto2', '#divValoresTR').val());

    if (vlrpgto2 > 0) {
        exibeValorPrejuizo('P'); // Parcial
    } else {
        exibeValorPrejuizo('D'); // Desconto
    }

    if (glbTipoVcto == 1) { // Nesta Data
        dataVencimento = $('#dtmvtolt', '#frmGerarBoletoTR').val();
    } else { // Data Futura
        dataVencimento = $('#dtvencto', '#frmGerarBoletoTR').val();
    }

	if ( glbTipoVlr == 0 ) {
		showError('error', 'Selecione um tipo de pagamento!', 'Alerta - Ayllos', "bloqueiaFundo($('#divRotina'))");
	} else {

		// Se percentual informado for maior que o parametrizado na TAB096
        if (vldescto > descprej) {
			showError('error', 'Percentual de Desconto informado superior ao valor permitido!', 'Alerta - Ayllos', "bloqueiaFundo($('#divRotina'))");
		} else {

            valorBoleto = $('#vlquitac', '#divValoresTR').val();

            if ( converteMoedaFloat(valorBoleto) == 0 ) {
                showError('error', 'N&atilde;o foram informados valores!', 'Alerta - Ayllos', "bloqueiaFundo($('#divRotina'))");
            } else {

                var msg = 'Sera gerado um boleto no valor de R$ ' + valorBoleto + ' <br/> com vencimento em ' + dataVencimento + '. ';
                if (vldescto > 0) {
                    msg += 'Confirma Geracao com Desconto?';
                } else {
                    msg += 'Confirma Geracao?';
                }
                showConfirmacao(msg, 'Confirma&ccedil;&atilde;o - Ayllos', 'efetuaGeracaoBoleto(\'PRJZ\');', 'cancelaConfirmacao()', 'sim.gif', 'nao.gif')
            }
		}
	}
}

function carregaArquivos(nriniseq, nrregist) {

    var dtarqini = $('#dtarqini', '#frmArquivos').val();
    var dtarqfim = $('#dtarqfim', '#frmArquivos').val();
    var nmarquiv = $('#nmarquiv', '#frmArquivos').val();

    if (nmarquiv == '') {
        if (dtarqini == '') {
            showError("error", "Informe a Data Inicial.", "Alerta - Ayllos", "$('#dtarqini', '#frmArquivos').focus()", false);
            return false;
        }

        if (dtarqfim == '') {
            showError("error", "Informe a Data Final.", "Alerta - Ayllos", "$('#dtarqfim', '#frmArquivos').focus()", false);
            return false;
        }
    } else {
        if (dtarqini == '' && dtarqfim != '') {
            showError("error", "Informe a Data Inicial.", "Alerta - Ayllos", "$('#dtarqini', '#frmArquivos').focus()", false);
            return false;
        }

        if (dtarqini != '' && dtarqfim == '') {
            showError("error", "Informe a Data Final.", "Alerta - Ayllos", "$('#dtarqfim', '#frmArquivos').focus()", false);
            return false;
        }

        if (nmarquiv.length < 6) {
            showError("error", "Nome do Arquivo Deve ter no Minimo Seis Caracteres.", "Alerta - Ayllos", "$('#nmarquiv', '#frmArquivos').focus()", false);
            return false;
        }
    }

    // Se diferenca for maior que 6 meses
    if (retornaDateDiff('M',dtarqini,dtarqfim) > 6) {
        showError("error", "O intervalo de datas ultrapassou o limite maximo permitido.", "Alerta - Ayllos", "$('#dtarqfim', '#frmArquivos').focus()", false);
        return false;
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, efetuando consulta ...");

    // Carrega dados parametro através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobemp/carrega_arquivos.php',
        data:
                {
                    cddopcao: cCddopcao.val(),
                    dtarqini: dtarqini,
                    dtarqfim: dtarqfim,
                    nmarquiv: nmarquiv,
                    nriniseq: nriniseq,
                    nrregist: nrregist,
                    redirect: 'script_ajax'
                },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response) {
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divTabfrmArquivos').html(response);
                    $('#divTabfrmArquivos').css({'display': 'block'});
                    $('#divBotoesfrmArquivos').css({'display': 'block'});
                    $('#frmArquivos').css({'display': 'block'});
                    $('#dtarqini', '#frmArquivos').focus();

                    formataArquivos();
                    $('#divPesquisaRodape', '#divTabfrmArquivos').formataRodapePesquisa();

                    hideMsgAguardo();
                    return false;
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

}

function formataArquivos() {

    $('#divRotina').css('width', '640px');

    var divRegistro = $('div.divRegistros', '#divTabfrmArquivos');
    var tabela = $('table', divRegistro);

    divRegistro.css({'height': '220px', 'width': '100%'});

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '100px';
    arrayLargura[1] = '80px';
    arrayLargura[2] = '300px';
    arrayLargura[3] = '100px';
    arrayLargura[4] = '100px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'left';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'center';

    var metodoTabela = '';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

    // seleciona o registro que é clicado
    $('table > tbody > tr', divRegistro).click(function() {
        glbIdarquivo = $(this).find('#idarquivo').val();
        glbInsitarq  = $(this).find('#situacaoarq').val();
    });

    $('table > tbody > tr:eq(0)', divRegistro).click();

    return false;
}

function abreImportacao() {

    showMsgAguardo('Aguarde, carregando rotina para importacao...');

    // Executa script através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobemp/enviar_arquivo.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground()");
        },
        success: function(response) {
            $('#divRotina').html(response);
            montarFormImportacao();
        }
    });

    return false;

}

function montarFormImportacao() {

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobemp/tab_arquivo.php',
        data: {
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground();");
        },
        success: function(response) {

            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divConteudoOpcao').html(response);
                    exibeRotina($('#divRotina'));

                    formataFormArquivo();

                    hideMsgAguardo();
                    bloqueiaFundo($('#divRotina'));
                    $('#divRotina').setCenterPosition();
                    highlightObjFocus($('#frmNomArquivo'));
                    return false;
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            } else {
                try {
                    eval(response);
                    controlaFoco();
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            }
        }
    });
    return false;
}

function formataFormArquivo() {

    // Ajusta tamanho do form
    $('#divRotina').css('width', '400px');

    var cNmarquiv = $('#nmarquiv', '#frmNomArquivo');

    cNmarquiv.addClass('alphanum campo').attr('maxlength', '100').css({'width':'350px'});

    layoutPadrao();
    hideMsgAguardo();

    cNmarquiv.focus();

    return false;
}

function importarArquivo() {

    showMsgAguardo('Aguarde, carregando importacao de arquivo...');

    var nmarquiv = $('#nmarquiv', '#frmNomArquivo').val().replace(/[^a-z0-9._]/gi, '');
    var flgreimp = $('#flgreimp', '#frmNomArquivo').val();

    // Executa script através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobemp/controla_operacao.php',
        data: {
            nmarquiv: nmarquiv,
            flgreimp: flgreimp,
            operacao: 'IMPORTAR_ARQUIVO',
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            try {
                hideMsgAguardo();
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });

    return false;

}

function confirmaImportacao() {
    var flgreimp = $('#flgreimp', '#frmNomArquivo').val();
    var nmarquiv = $('#nmarquiv', '#frmNomArquivo').val().replace(/[^a-z0-9._]/gi, '');
	
	if (nmarquiv.length < 18) {
        showError('error', 'Formato do Nome do Arquivo Invalido!', 'Alerta - Ayllos', "$('#nmarquiv', '#frmNomArquivo').focus(); bloqueiaFundo($('#divRotina'))");
        return false;
    } else {
        showConfirmacao('Confirma a ' + (flgreimp == 1 ? 're' : '') + 'importa&ccedil;&atilde;o do arquivo: ' + nmarquiv + ' ?', 'Confirma&ccedil;&atilde;o - Ayllos', 'importarArquivo();', 'cancelarReimportacao();', 'sim.gif', 'nao.gif');
    }
}

function cancelarReimportacao() {
    $('#flgreimp', '#frmNomArquivo').val(0);
    showError("inform","Opera&ccedil;&atilde;o Cancelada.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')));fechaRotina($('#divRotina'));");
}

function formataImprimirRelatorio() {
    // Ajusta tamanho do form
    $('#divRotina').css({'width' : '260px', 'height' : '200px'});
    exibeRotina($('#divRotina'));
    bloqueiaFundo($('#divRotina'));
    $('#divRotina').setCenterPosition();
    highlightObjFocus($('#frmNomArquivo'));
    layoutPadrao();
    return false;
}

//Botao Imprimir
function btnImprimir() {

    if (glbIdarquivo == 0) {
      showError('error', 'Nenhuma Remessa Selecionada.', 'Alerta - Ayllos', "unblockBackground()");
      return false;
    }

    if (glbInsitarq.toUpperCase() == 'PENDENTE') {
      showMsgAguardo('Aguarde, carregando rotina para impressao...');
      // Executa script através de ajax
      $.ajax({
          type: 'POST',
          dataType: 'html',
          url: UrlSite + 'telas/cobemp/form_relatorio.php',
          data: {
              redirect: 'html_ajax'
          },
          error: function(objAjax, responseError, objExcept) {
              hideMsgAguardo();
              showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground()");
          },
          success: function(response) {
              $('#divRotina').html(response);
              formataImprimirRelatorio();
          }
      });

      hideMsgAguardo();
    } else {
      imprimir_relatorio(0);
    }

    return false;

}

// Função para gerar impressão em PDF
function imprimir_relatorio(flgcriti) {

	$("#idarquivo","#frmImprimir").val(glbIdarquivo);
	$("#flgcriti","#frmImprimir").val(flgcriti);

	var action = $("#frmImprimir").attr("action");
	var callafter = "";
  carregaImpressaoAyllos("frmImprimir",action,callafter);

  return false;
}

function btnGerarBoleto() {

  if (glbIdarquivo == 0) {
    showError('error', 'Nenhuma Remessa Selecionada.', 'Alerta - Ayllos', "unblockBackground()");
    return false;
  }
  if (glbInsitarq.toUpperCase() == 'PROCESSADO') {
    showError('error', 'N&atilde;o permitido Gera&ccedil;&atilde;o de Boletos para Remessa j&aacute; Processada.', 'Alerta - Ayllos', "unblockBackground()");
    return false;
  }
  showConfirmacao('Deseja gerar boletos?', 'Confirma&ccedil;&atilde;o - Ayllos', 'gera_boletos();', 'return false;', 'sim.gif', 'nao.gif');

  return false;
}

function gera_boletos() {

  showMsgAguardo('Aguarde, carregando rotina para gera&ccedil;&atilde;o de boletos...');

  // Executa script através de ajax
  $.ajax({
      type: 'POST',
      dataType: 'html',
      url: UrlSite + 'telas/cobemp/gerar_boletos.php',
      data: {
          idarquivo: glbIdarquivo,
          redirect: 'html_ajax'
      },
      error: function(objAjax, responseError, objExcept) {
          hideMsgAguardo();
          showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground()");
      },
      success: function(response) {
          hideMsgAguardo();
          eval(response);
      }
  });

  return false;
}

function btnGerarArquivoParceiro() {

  if (glbIdarquivo == 0) {
    showError('error', 'Nenhuma Remessa Selecionada.', 'Alerta - Ayllos', "unblockBackground()");
    return false;
  }
  if (glbInsitarq.toUpperCase() != 'PROCESSADO') {
    showError('error', 'N&atilde;o permitido Gera&ccedil;&atilde;o de Arquivo para Remessa Pendente.', 'Alerta - Ayllos', "unblockBackground()");
    return false;
  }
  showConfirmacao('Deseja efetuar nova gera&ccedil;&atilde;o do arquivo BPC_AILOS_' + lpad(glbIdarquivo, 6) + '.csv para empresa parceira?', 'Confirma&ccedil;&atilde;o - Ayllos', 'gera_arquivo_parceiro();',
                  'showError("inform", "Opera&ccedil;&atilde;o Cancelada.", "Alerta - Ayllos", "unblockBackground()");', 'sim.gif', 'nao.gif');

  return false;
}

function gera_arquivo_parceiro() {

  showMsgAguardo('Aguarde, carregando rotina para gera&ccedil;&atilde;o de arquivo...');

  // Executa script através de ajax
  $.ajax({
      type: 'POST',
      dataType: 'html',
      url: UrlSite + 'telas/cobemp/gerar_arquivo_parceiro.php',
      data: {
          idarquivo: glbIdarquivo,
          redirect: 'html_ajax'
      },
      error: function(objAjax, responseError, objExcept) {
          hideMsgAguardo();
          showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground()");
      },
      success: function(response) {
          hideMsgAguardo();
          eval(response);
      }
  });

  return false;
}

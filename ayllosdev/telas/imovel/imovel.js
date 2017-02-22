/*!
 * FONTE        : imovel.js
 * CRIA��O      : Renato Darosci (Supero) 
 * DATA CRIA��O : 07/06/2016
 * OBJETIVO     : Biblioteca de fun��es da tela IMOVEL
 * --------------
 * ALTERA��ES   :
 * --------------
 * [  /  /    ]                   : 
 */

//Formul�rios e Tabela
var frmCab = 'frmCab';
var frmOpcao = 'frmOpcao';
var frmPrint = 'frmPrint';
var frmRetorno = 'frmRetorno';

var cddopcao = 'N';

var nrJanelas = 0;
var nriniseq = 1;
var nrregist = 50;
var incontrol = true;

// Campos cabe�alho
var cIdseqbem, cNrdconta, cNrctremp, cContaAux, cNmprimtl, cNrcpfcgc;
// Campos Im�vel
var cNrmatcar, cNrcnscar, cTpimovel, cNrreggar, cDtreggar, cNrgragar, cNrceplgr, cTplograd,
    cDslograd, cNrlograd, cDscmplgr, cDsbairro, cCdcidade, cCdestado, cDtavlimv, cVlavlimv,
    cDtcprimv, cVlcprimv, cTpimpimv, cIncsvimv, cInpdracb, cVlmtrtot, cVlmtrpri, cQtdormit,
    cQtdvagas, cVlmtrter, cVlmtrtes, cIncsvcon, cInpesvdr, cNrdocvdr, cNmvendor, cDscidade;
// Campos inclus�o
var cNrreginc, cDtinclus, cDsjstinc;
// Campos Baixa
var cDtdbaixa, cDsjstbxa;
// Campos Status
var cDsstatus, cDscritic;
// Campos relat�rio
var cCdcooper, cInrelato, cIntiprel, cDtrefere, cCddolote;
// Campos gera��o
var cIntiparq;

var cTodosOpcao;

// Chamar as fun��es de inicia��o para a tela
$(document).ready(function() {
    estadoInicial();
});

// Configura o estado inicial da tela
function estadoInicial() {

    $('#divTela').fadeTo(0, 0.1);

    // retira as mensagens	
    hideMsgAguardo();

    // formulario	
    formataCabecalho();
    cTodosCabecalho.limpaFormulario().removeClass('campoErro');

    $('#' + frmOpcao).remove();
    $('#' + frmPrint).remove();
    $('#' + frmRetorno).remove();
    $('#divBotoes').remove();
    $('#divPesquisaRodape', '#divTela').remove();

    cCddopcao.val(cddopcao);
    cCddopcao.focus();

    removeOpacidade('divTela');
}

// Montar o formul�rio da tela conforme a op��o selecionada
function buscaOpcao() {

    // Vari�veis
    var opcao = 'n';
    
    showMsgAguardo('Aguarde, buscando dados ...');

    // verifica qual o formul�rio que deve ser chamado
    switch (cddopcao) {
        case 'A':
            opcao = 'n';
            break;
        case 'B':
            opcao = 'b';
            break;
        case 'C':
            opcao = 'c';
            break;
        case 'G':
            opcao = 'g';
            break;
        case 'I':
            opcao = 'i';
            break;
        case 'N':
            opcao = 'n';
            break;
        case 'M':
            opcao = 'm';
            break;
        case 'R':
            opcao = 'r';
            break;
        case 'X':
            opcao = 'x';
            break;
    }
    

    // Executa script de confirma��o atrav�s de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/imovel/form_opcao_' + opcao + '.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N�o foi poss�vel concluir a requisi��o.', 'Alerta - Ayllos', "unblockBackground()");
        },
        success: function(response) {
            $('#divTela').html(response);
            
            formataCabecalho();

            cCddopcao.desabilitaCampo();
            cCddopcao.val(cddopcao);

            // limpa formulario
            cTodosOpcao = $('input[type="text"], select', '#' + frmOpcao);
            cTodosOpcao.limpaFormulario().removeClass('campoErro');
            $('#divPesquisaRodape', '#divTela').remove();

            formataOpcao();

            hideMsgAguardo();
            return false;
        }
    });

    return false;

}

// Formatar os campos para o layout da op��o selecionada
function formataOpcao() {

    highlightObjFocus($('#' + frmOpcao));

    switch (cddopcao) {
        case 'N':
        case 'A':
        case 'C':
        case 'X':
            formataEmprestimo();

            // Ocultar fieldset da tela
            $('#FS_IMOVEL').css({ 'display': 'none' });
            $('#FS_VENDEDOR').css({ 'display': 'none' });

            // Se for a tela de consulta deve ocultar mais alguns fieldsets
            if (cddopcao == 'C') {
                $('#FS_STATUS').css({ 'display': 'none' });
                $('#FS_INCLUSAO').css({ 'display': 'none' });
                $('#FS_BAIXA').css({ 'display': 'none' });
            } else {
                if (cddopcao == 'X') {
                    if (isHabilitado(cNrdconta) || cNrdconta.val() == "") {
                        lista_coop();
                    }
                    cCdcooper.habilitaCampo();
                    cCdcooper.attr('tabindex', '0');  // Restaurar a navega��o correta da tela
                }
            }
            
            cNrdconta.habilitaCampo();
            cNrctremp.habilitaCampo();
            cNrdconta.attr('tabindex', '0');  // Restaurar a navega��o correta da tela
            cNrctremp.attr('tabindex', '0');  // Restaurar a navega��o correta da tela

            if (cddopcao == 'X') {
                cCdcooper.focus();
            } else {
                cNrdconta.focus();
            }


                break;

        case 'B':
            formataEmprestimo();

            // Ocultar fieldset da tela
            $('#FS_IMOVEL').css({ 'display': 'none' });
            $('#FS_VENDEDOR').css({ 'display': 'none' });
            $('#FS_BAIXA').css({ 'display': 'none' });

            cNrdconta.habilitaCampo().focus();
            cNrctremp.habilitaCampo();
            cNrdconta.attr('tabindex', '0');  // Restaurar a navega��o correta da tela
            cNrctremp.attr('tabindex', '0');  // Restaurar a navega��o correta da tela
            break;

        case 'M':
            formataEmprestimo();

            // Ocultar fieldset da tela
            $('#FS_IMOVEL').css({ 'display': 'none' });
            $('#FS_VENDEDOR').css({ 'display': 'none' });
            $('#FS_INCLUSAO').css({ 'display': 'none' });

            cNrdconta.habilitaCampo().focus();
            cNrctremp.habilitaCampo();
            cNrdconta.attr('tabindex', '0');  // Restaurar a navega��o correta da tela
            cNrctremp.attr('tabindex', '0');  // Restaurar a navega��o correta da tela
            break;

        case 'I':
            formataRelato();
            break;
        case 'G':
            formataGerar();
            break;
    }
    
    //controlaPesquisas();
    return false;
}

// Formatar o cabecalho
function formataCabecalho() {

    // Label
    rCddopcao = $('label[for="cddopcao"]', '#' + frmCab);
    rCddopcao.css({'width': '80px'}).addClass('rotulo');

    // Input
    cCddopcao = $('#cddopcao', '#' + frmCab);
    cCddopcao.css({'width': '587px'});

    // Outros	
    cTodosCabecalho = $('input[type="text"], select', '#' + frmCab);
    btnOK1 = $('#btnOk1', '#' + frmCab);
    cTodosCabecalho.habilitaCampo();
    cTodosCabecalho.attr('tabindex', '0');  // Restaurar a navega��o correta da tela
    
    // Se clicar no botao OK
    btnOK1.unbind('click').bind('click', function() {

        if (divError.css('display') == 'block') {
            return false;
        }
        if (cCddopcao.hasClass('campoTelaSemBorda')) {
            return false;
        }

        //
        cCddopcao.focus();
        cddopcao = cCddopcao.val();
        cCddopcao.desabilitaCampo();

        //		
        buscaOpcao();
        return false;

    });


    // 
    cCddopcao.unbind('keypress').bind('keypress', function (e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se � a tecla ENTER
        if (e.keyCode == 9 || e.keyCode == 13) {
            btnOK1.click();
            return false;
        }

    });

    layoutPadraoImovel();
    controlaPesquisas();
    return false;
}

// Formatar os campos do fieldset de Emprestimo
function formataEmprestimo() {

    if (cddopcao == 'X') {
        // label
        rCdcooper = $('label[for="cdcooper"]', '#' + frmOpcao);
        rCdcooper.addClass('rotulo').css({ 'width': '75px' });
        // input
        cCdcooper = $('#cdcooper', '#' + frmOpcao);
        cCdcooper.addClass('campo').css({ 'width': '200px' });

        // Configurar enter
        cCdcooper.unbind('keypress').bind('keypress', function (e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                if (cddopcao == 'X') {
                    cNrdconta.focus();
                }
                return false;
            }
        });

    }


    // label
    rNrdconta = $('label[for="nrdconta"]', '#' + frmOpcao);
    rNmprimtl = $('label[for="nmprimtl"]', '#' + frmOpcao);
    rNrctremp = $('label[for="nrctremp"]', '#' + frmOpcao);

    rNrdconta.css({ 'width': '75px' }).addClass('rotulo');
    rNmprimtl.css({ 'width': '60px' }).addClass('rotulo-linha');
    rNrctremp.css({ 'width': '75px' }).addClass('rotulo');

    // input
    cNrdconta = $('#nrdconta', '#' + frmOpcao);
    cContaAux = $('#contaaux', '#' + frmOpcao);
    cNmprimtl = $('#nmprimtl', '#' + frmOpcao);
    cNrctremp = $('#nrctremp', '#' + frmOpcao);

    cNrdconta.css({ 'width': '85px' }).addClass('pesquisa conta');
    cNmprimtl.css({ 'width': '420px' });
    cNrctremp.css({ 'width': '120px' });
    cNrctremp.css({ 'text-align': 'right' });

    cNmprimtl.desabilitaCampo();

    // Mostrar bot�o Prosseguir
    trocaBotao('Prosseguir');

    // conta
    cNrdconta.unbind('keypress').bind('keypress', function (e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        var auxconta = normalizaNumero(cNrdconta.val());

        // Se � a tecla TAB ou ENTER, 
        if ((e.keyCode == 9 || e.keyCode == 13 || typeof e.keyCode == 'undefined')) {
            if (auxconta == 0 || validaCampo('nrdconta', auxconta)) {
                buscar_cooperado_emprestimo();
            }
            //return false;
        }

        return true;

    });

    cNrctremp.unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            btnContinuar();
            return false;
        }
    });

    
    layoutPadraoImovel();
    controlaPesquisas();
    return false;
}

// Formatar os campos do fieldset de Im�veis
function formataImovel() {
    
    // Declara os labels
    rIdseqbem = $('label[for="idseqbem"]', '#' + frmOpcao);
    rNrmatcar = $('label[for="nrmatcar"]', '#' + frmOpcao);
    rNrcnscar = $('label[for="nrcnscar"]', '#' + frmOpcao);
    rTpimovel = $('label[for="tpimovel"]', '#' + frmOpcao);
    rNrreggar = $('label[for="nrreggar"]', '#' + frmOpcao);
    rDtreggar = $('label[for="dtreggar"]', '#' + frmOpcao);
    rNrgragar = $('label[for="nrgragar"]', '#' + frmOpcao);
    rNrceplgr = $('label[for="nrceplgr"]', '#' + frmOpcao);
    rTplograd = $('label[for="tplograd"]', '#' + frmOpcao);
    rDslograd = $('label[for="dslograd"]', '#' + frmOpcao);
    rNrlograd = $('label[for="nrlograd"]', '#' + frmOpcao);
    rDscmplgr = $('label[for="dscmplgr"]', '#' + frmOpcao);
    rDsbairro = $('label[for="dsbairro"]', '#' + frmOpcao);
    rCdestado = $('label[for="cdestado"]', '#' + frmOpcao);
    rCdcidade = $('label[for="cdcidade"]', '#' + frmOpcao);
    rDtavlimv = $('label[for="dtavlimv"]', '#' + frmOpcao);
    rVlavlimv = $('label[for="vlavlimv"]', '#' + frmOpcao);
    rDtcprimv = $('label[for="dtcprimv"]', '#' + frmOpcao);
    rVlcprimv = $('label[for="vlcprimv"]', '#' + frmOpcao);
    rTpimpimv = $('label[for="tpimpimv"]', '#' + frmOpcao);
    rIncsvimv = $('label[for="incsvimv"]', '#' + frmOpcao);
    rInpdracb = $('label[for="inpdracb"]', '#' + frmOpcao);
    rVlmtrtot = $('label[for="vlmtrtot"]', '#' + frmOpcao);
    rVlmtrpri = $('label[for="vlmtrpri"]', '#' + frmOpcao);
    rQtdormit = $('label[for="qtdormit"]', '#' + frmOpcao);
    rQtdvagas = $('label[for="qtdvagas"]', '#' + frmOpcao);
    rVlmtrter = $('label[for="vlmtrter"]', '#' + frmOpcao);
    rVlmtrtes = $('label[for="vlmtrtes"]', '#' + frmOpcao);
    rIncsvcon = $('label[for="incsvcon"]', '#' + frmOpcao);
    rInpesvdr = $('label[for="inpesvdr"]', '#' + frmOpcao);
    rNrdocvdr = $('label[for="nrdocvdr"]', '#' + frmOpcao);
    rNmvendor = $('label[for="nmvendor"]', '#' + frmOpcao);

    // Declara os inputs
    cIdseqbem = $('#idseqbem', '#' + frmOpcao);
    cNrmatcar = $('#nrmatcar', '#' + frmOpcao);
    cNrcnscar = $('#nrcnscar', '#' + frmOpcao);
    cTpimovel = $('#tpimovel', '#' + frmOpcao);
    cNrreggar = $('#nrreggar', '#' + frmOpcao);
    cDtreggar = $('#dtreggar', '#' + frmOpcao);
    cNrgragar = $('#nrgragar', '#' + frmOpcao);
    cNrceplgr = $('#nrceplgr', '#' + frmOpcao);
    cTplograd = $('#tplograd', '#' + frmOpcao);
    cDslograd = $('#dslograd', '#' + frmOpcao);
    cNrlograd = $('#nrlograd', '#' + frmOpcao);
    cDscmplgr = $('#dscmplgr', '#' + frmOpcao);
    cDsbairro = $('#dsbairro', '#' + frmOpcao);
    cCdestado = $('#cdestado', '#' + frmOpcao);
    cCdcidade = $('#cdcidade', '#' + frmOpcao);
    cDscidade = $('#dscidade', '#' + frmOpcao);
    cDtavlimv = $('#dtavlimv', '#' + frmOpcao);
    cVlavlimv = $('#vlavlimv', '#' + frmOpcao);
    cDtcprimv = $('#dtcprimv', '#' + frmOpcao);
    cVlcprimv = $('#vlcprimv', '#' + frmOpcao);
    cTpimpimv = $('#tpimpimv', '#' + frmOpcao);
    cIncsvimv = $('#incsvimv', '#' + frmOpcao);
    cInpdracb = $('#inpdracb', '#' + frmOpcao);
    cVlmtrtot = $('#vlmtrtot', '#' + frmOpcao);
    cVlmtrpri = $('#vlmtrpri', '#' + frmOpcao);
    cQtdormit = $('#qtdormit', '#' + frmOpcao);
    cQtdvagas = $('#qtdvagas', '#' + frmOpcao);
    cVlmtrter = $('#vlmtrter', '#' + frmOpcao);
    cVlmtrtes = $('#vlmtrtes', '#' + frmOpcao);
    cIncsvcon = $('#incsvcon', '#' + frmOpcao);
    cInpesvdr = $('#inpesvdr', '#' + frmOpcao);
    cNrdocvdr = $('#nrdocvdr', '#' + frmOpcao);
    cNmvendor = $('#nmvendor', '#' + frmOpcao);

    // Configura LABELS
    rIdseqbem.addClass('rotulo').css({ 'width': '100px' });
    // Linha 1
    rNrmatcar.addClass('rotulo').css({ 'width': '110px' });
    rNrcnscar.addClass('rotulo-linha').css({ 'width': '145px' });
    rTpimovel.addClass('rotulo-linha').css({ 'width': '145px' });
    // Linha 2
    rNrreggar.addClass('rotulo').css({ 'width': '110px' });
    rDtreggar.addClass('rotulo-linha').css({ 'width': '120px' });
    rNrgragar.addClass('rotulo-linha').css({ 'width': '110px' });
    //Linha 3
    rNrceplgr.addClass('rotulo').css({ 'width': '110px' });
    // Linha 4
    rTplograd.addClass('rotulo').css({ 'width': '110px' });
    rDslograd.addClass('rotulo-linha').css({ 'width': '78px' });
    rNrlograd.addClass('rotulo-linha').css({ 'width': '29px' });
    // Linha 5
    rDscmplgr.addClass('rotulo').css({ 'width': '110px' });
    rDsbairro.addClass('rotulo-linha').css({ 'width': '66px' });
    // Linha 6
    rCdestado.addClass('rotulo').css({ 'width': '110px' });
    rCdcidade.addClass('rotulo-linha').css({ 'width': '100px' });
    // Linha 7
    rDtavlimv.addClass('rotulo').css({ 'width': '110px' });
    rVlavlimv.addClass('rotulo-linha').css({ 'width': '96px' });
    rDtcprimv.addClass('rotulo-linha').css({ 'width': '82px' });
    rVlcprimv.addClass('rotulo-linha').css({ 'width': '87px' });
    // Linha 8
    rTpimpimv.addClass('rotulo').css({ 'width': '110px' });
    rIncsvimv.addClass('rotulo-linha').css({ 'width': '140px' });
    rInpdracb.addClass('rotulo-linha').css({ 'width': '132px' });
    // Linha 9 
    rVlmtrtot.addClass('rotulo').css({ 'width': '110px' });
    rVlmtrpri.addClass('rotulo-linha').css({ 'width': '129px' });
    rQtdormit.addClass('rotulo-linha').css({ 'width': '120px' });
    rQtdvagas.addClass('rotulo-linha').css({ 'width': '130px' });
    // Linha 10 
    rVlmtrter.addClass('rotulo').css({ 'width': '110px' });
    rVlmtrtes.addClass('rotulo-linha').css({ 'width': '129px' });
    rIncsvcon.addClass('rotulo-linha').css({ 'width': '186px' });

    // Fieldset Vendedor
    rInpesvdr.addClass('rotulo').css({ 'width': '155px' });
    rNrdocvdr.addClass('rotulo-linha').css({ 'width': '79px' });
    rNmvendor.addClass('rotulo').css({ 'width': '155px' });

    // Configura INPUTS
    cIdseqbem.css({ 'width': '520px' });
    // Linha 1
    cNrmatcar.css({ 'width': '100px' });
    cNrcnscar.css({ 'width': '80px' }).addClass('inteiro');
    cTpimovel.css({ 'width': '125px' });
    // Linha 2
    cNrreggar.css({ 'width': '115px' });
    cDtreggar.css({ 'width': '72px' }).addClass('data');
    cNrgragar.css({ 'width': '178px' });
    // Linha 3
    cNrceplgr.css({ 'width': '70px' }).addClass('cep pesquisa');
    // Linha 4
    cTplograd.css({ 'width': '90px' });
    cDslograd.css({ 'width': '343px' }).css({ 'text-transform': 'uppercase' });
    cDslograd.setMask("STRING", "60", charPermitido(), "");
    cNrlograd.css({ 'width': '55px' }).addClass('numerocasa');
    // Linha 5
    cDscmplgr.css({ 'width': '325px' }).css({ 'text-transform': 'uppercase' });
    cDscmplgr.setMask("STRING", "30", charPermitido(), "");
    cDsbairro.css({ 'width': '210px' }).css({ 'text-transform': 'uppercase' });
    cDsbairro.setMask("STRING", "20", charPermitido(), "");
    // Linha 6
    cCdestado.css({ 'width': '50px' });
    cCdcidade.css({ 'width': '250px' });
    // Linha 7
    cDtavlimv.css({ 'width': '72px' }).addClass('data');
    cVlavlimv.css({ 'width': '90px' }).addClass('monetario');
    cDtcprimv.css({ 'width': '72px' }).addClass('data');
    cVlcprimv.css({ 'width': '90px' }).addClass('monetario');
    // Linha 8 
    cTpimpimv.css({ 'width': '110px' });
    cIncsvimv.css({ 'width': '125px' });
    cInpdracb.css({ 'width': '90px' });
    // Linha 9
    cVlmtrtot.css({ 'width': '75px' }).addClass('monetario');
    cVlmtrpri.css({ 'width': '75px' }).addClass('monetario');
    cQtdormit.css({ 'width': '30px' }).addClass('inteiro');
    cQtdvagas.css({ 'width': '30px' }).addClass('inteiro');
    // Linha 10 
    cVlmtrter.css({ 'width': '75px' }).addClass('monetario');
    cVlmtrtes.css({ 'width': '75px' }).addClass('monetario');
    cIncsvcon.css({ 'width': '130px' });

    // Fieldset Vendedor
    cInpesvdr.css({ 'width': '190px' });
    cNrdocvdr.css({ 'width': '135px' }).addClass('cpf');
    cNmvendor.css({ 'width': '410px' }).css({ 'text-transform': 'uppercase' });
    cNmvendor.setMask("STRING", "30", charPermitido(), "");
    
    // Quando selecionar o estado
    cCdestado.change(function () {
        carregar_cidades_uf(cCdestado);
    });

    // Outros	
    btnOK2 = $('#btnOk2', '#' + frmOpcao);

    controla_bloqueio_campos_imovel(false);
    
    // Se clicar no botao OK
    btnOK2.unbind('click').bind('click', function() {
        
        if (cIdseqbem.hasClass('campoTelaSemBorda')) {
            return false;
        }

        // Se selecionou algum bem
        if (cIdseqbem.val() > 0) {
            // Buscar os dados do Im�vel
            buscar_dados_imovel();
       } else {
            showError('error', 'N&atilde;o h&aacute; im&oacute;vel selecionado. Verifique!', 'Alerta - Ayllos', 'return false;');
        }

        return false;

    });


    cIdseqbem.unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            // Se selecionou algum bem
            if (cIdseqbem.val() > 0) {
                // Buscar os dados do Im�vel
                buscar_dados_imovel();
            } else {
                showError('error', 'N&atilde;o h&aacute; im&oacute;vel selecionado. Verifique!', 'Alerta - Ayllos', 'cIdseqbem.focus();');
            }
            return false;
        }
    });

    // Quando alterar o campo
    cInpesvdr.change(function () {
        ajusta_pessoa_vendedor();
        cInpesvdr.focus();
    });

    // Ajustar a navega��o do formul�rio de entrada de dados do im�vel
    ajustaNavegacao();

    layoutPadraoImovel();
    controlaPesquisas();
    return false;

}

function navegarDePara(campoOrigem, campoDestino) {
    
    campoOrigem.unbind('keypress').bind('keypress', function (e) {
        
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se � a tecla ENTER
        if (e.keyCode == 13) {
            campoDestino.focus();
            return false;
        }
        
    });
}

// Ajustar a navega��o do formul�rio de entrada de dados do im�vel
function ajustaNavegacao() {
    
    navegarDePara(cNrmatcar,cNrcnscar);
    navegarDePara(cNrcnscar,cNrreggar);
    navegarDePara(cNrreggar,cDtreggar);
    navegarDePara(cDtreggar,cNrgragar);
    navegarDePara(cNrgragar,cNrceplgr);
    navegarDePara(cTplograd,cDslograd);
    navegarDePara(cDslograd,cNrlograd);
    navegarDePara(cNrlograd,cDscmplgr);
    navegarDePara(cDscmplgr,cDsbairro);
    navegarDePara(cDsbairro,cCdestado);
    navegarDePara(cCdestado,cCdcidade);
    navegarDePara(cCdcidade,cDtavlimv);
    navegarDePara(cDtavlimv,cVlavlimv);
    navegarDePara(cVlavlimv,cDtcprimv);
    navegarDePara(cDtcprimv,cVlcprimv);
    navegarDePara(cVlcprimv,cTpimpimv);
    navegarDePara(cTpimpimv,cIncsvimv);
    navegarDePara(cIncsvimv,cInpdracb);
    navegarDePara(cInpdracb,cVlmtrtot);
    navegarDePara(cVlmtrtot,cVlmtrpri);
    navegarDePara(cVlmtrpri,cQtdormit);
    navegarDePara(cQtdormit,cQtdvagas);
    navegarDePara(cQtdvagas,cVlmtrter);
    navegarDePara(cVlmtrter,cVlmtrtes);
    navegarDePara(cVlmtrtes,cIncsvcon);
    navegarDePara(cIncsvcon,cInpesvdr);
    navegarDePara(cInpesvdr, cNrdocvdr);
    /*
    cInpesvdr.unbind('keypress').bind('keypress', function (e) {
        if (divError.css('display') == 'block') { return false;  }

        // Se � a tecla ENTER
        if (e.keyCode == 13) {
            ajusta_pessoa_vendedor();
            cNrdocvdr.focus();
            return false;
        }
    });*/
    
    navegarDePara(cNrdocvdr,cNmvendor);

    return false;

}

// Formatar os campos do fieldset de Inclus�o Manual
function formataInclusao() {

    // Declara os labels
    rNrreginc = $('label[for="nrreginc"]', '#' + frmOpcao);
    rDtinclus = $('label[for="dtinclus"]', '#' + frmOpcao);
    rDsjstinc = $('label[for="dsjstinc"]', '#' + frmOpcao);

    // Declara os inputs
    cNrreginc = $('#nrreginc', '#' + frmOpcao);
    cDtinclus = $('#dtinclus', '#' + frmOpcao);
    cDsjstinc = $('#dsjstinc', '#' + frmOpcao);

    // Configura LABELS
    rNrreginc.addClass('rotulo').css({ 'width': '220px' });
    rDtinclus.addClass('rotulo-linha').css({ 'width': '152px' });
    rDsjstinc.addClass('rotulo').css({ 'width': '220px' });

    // Configura INPUTS
    cNrreginc.css({ 'width': '120px' }).addClass('inteiro');
    cDtinclus.css({ 'width': '72px' }).addClass('data');
    cDsjstinc.addClass('textarea');
    cDsjstinc.css({ 'width': '350px' });
    cDsjstinc.css({ 'height': '60px' });
    cDsjstinc.css({ 'margin': '3px 0px 3px 3px' });
    cDsjstinc.setMask("STRING", "200", charPermitido(), "");

    // Manter desabilitado at� a carga dos dados do im�vel
    cNrreginc.desabilitaCampo();
    cDtinclus.desabilitaCampo();
    cDsjstinc.desabilitaCampo();

    layoutPadraoImovel();
    controlaPesquisas();
    return false;

}

// Formatar os campos do fieldset de Baixa Manual
function formataBaixa() {

    // Declara os labels
    rDtdbaixa = $('label[for="dtdbaixa"]', '#' + frmOpcao);
    rDsjstbxa = $('label[for="dsjstbxa"]', '#' + frmOpcao);

    // Declara os inputs
    cDtdbaixa = $('#dtdbaixa', '#' + frmOpcao);
    cDsjstbxa = $('#dsjstbxa', '#' + frmOpcao);

    // Configura LABELS
    rDtdbaixa.addClass('rotulo').css({ 'width': '220px' });
    rDsjstbxa.addClass('rotulo').css({ 'width': '220px' });

    // Configura INPUTS
    cDtdbaixa.css({ 'width': '72px' }).addClass('data');
    cDsjstbxa.addClass('textarea');
    cDsjstbxa.css({ 'width': '350px' });
    cDsjstbxa.css({ 'height': '60px' });
    cDsjstbxa.css({ 'margin': '3px 0px 3px 3px' });
    cDsjstbxa.setMask("STRING", "200", charPermitido(), "");

    // Manter desabilitado at� a carga dos dados do im�vel
    cDtdbaixa.desabilitaCampo();
    cDsjstbxa.desabilitaCampo();

    layoutPadraoImovel();
    //controlaPesquisas();
    return false;

}

// Formatar os campos do fieldset de Status
function formataStatus() {

    // Declara os labels
    rDsstatus = $('label[for="dsstatus"]', '#' + frmOpcao);
    rDscritic = $('label[for="dscritic"]', '#' + frmOpcao);

    // Declara os inputs
    cDsstatus = $('#dsstatus', '#' + frmOpcao);
    cDscritic = $('#dscritic', '#' + frmOpcao);

    // Configura LABELS
    rDsstatus.addClass('rotulo').css({ 'width': '220px' });
    rDscritic.addClass('rotulo').css({ 'width': '220px' });

    // Configura INPUTS
    cDsstatus.css({ 'width': '400px' });
    cDscritic.css({ 'width': '400px' });
    
    // Ficar� sempre desabilitado
    cDsstatus.desabilitaCampo();
    cDscritic.desabilitaCampo();
    
    // Ocultar o campo critica e exibir apenas em momento oportuno
    $("#divdscritic", '#' + frmOpcao).hide();

    layoutPadraoImovel();
    //controlaPesquisas();
    return false;
}

// Formatar os campos do fieldset de solicita��o de Relat�rio
function formataRelato() {
    
    // Declara os labels
    rInrelato = $('label[for="inrelato"]', '#' + frmOpcao);
    rCdcooper = $('label[for="cdcooper"]', '#' + frmOpcao);
    rIntiprel = $('label[for="intiprel"]', '#' + frmOpcao);
    rDtrefere = $('label[for="dtrefere"]', '#' + frmOpcao);
    rCddolote = $('label[for="cddolote"]', '#' + frmOpcao);

    // Declara os inputs
    cInrelato = $('#inrelato', '#' + frmOpcao);
    cCdcooper = $('#cdcooper', '#' + frmOpcao);
    cIntiprel = $('#intiprel', '#' + frmOpcao);
    cDtrefere = $('#dtrefere', '#' + frmOpcao);
    cCddolote = $('#cddolote', '#' + frmOpcao);

    // Configura LABELS
    rInrelato.addClass('rotulo').css({ 'width': '120px' });
    rCdcooper.addClass('rotulo').css({ 'width': '120px' });
    rIntiprel.addClass('rotulo-linha').css({ 'width': '50px' });
    rDtrefere.addClass('rotulo-linha').css({ 'width': '85px' });
    rCddolote.addClass('rotulo-linha').css({ 'width': '50px' });

    // Configura INPUTS
    cInrelato.addClass('campo').css({ 'width': '570px' });
    cCdcooper.addClass('campo').css({ 'width': '125px' });
    cIntiprel.addClass('campo').css({ 'width': '80px' });
    cDtrefere.addClass('campo').css({ 'width': '72px' }).addClass('data');
    cCddolote.addClass('campo').css({ 'width': '90px' }).addClass('inteiro');

    lista_coop();

    cInrelato.change(function () {
        
        var $option;

        // Limpar os itens do select
        cIntiprel.html("");

        $option = $('<option />').val('T').text('Todas');
        cIntiprel.append($option);
        $option = $('<option />').val('I').text('Inclus�o');
        cIntiprel.append($option);

        if (cInrelato.val() == 1) {
            $option = $('<option />').val('A').text('Altera��o');
            cIntiprel.append($option);
        }

        $option = $('<option />').val('B').text('Baixa');
        cIntiprel.append($option);

        if (cInrelato.val() == 1) {
            $option = $('<option />').val('C').text('Cr�tica');
            cIntiprel.append($option);

            cCddolote.habilitaCampo();
            cCddolote.attr('tabindex', '0');  // Restaurar a navega��o correta da tela
        } else {
            cCddolote.val('');
            cCddolote.desabilitaCampo();
        }

    });

    layoutPadraoImovel();
    //controlaPesquisas();
    return false;

}

// Formatar os campos do fieldset de gera��o dos arquivos 
function formataGerar() {

    // Declara os labels
    rCdcooper = $('label[for="cdcooper"]', '#' + frmOpcao);
    rIntiparq = $('label[for="intiparq"]', '#' + frmOpcao);
    
    // Declara os inputs
    cCdcooper = $('#cdcooper', '#' + frmOpcao);
    cIntiparq = $('#intiparq', '#' + frmOpcao);

    // Configura LABELS
    rCdcooper.addClass('rotulo').css({ 'width': '160px' });
    rIntiparq.addClass('rotulo-linha').css({ 'width': '100px' });
    
    // Configura INPUTS
    cCdcooper.addClass('campo').css({ 'width': '200px' });
    cIntiparq.addClass('campo').css({ 'width': '80px' });
    
    lista_coop();

    layoutPadraoImovel();
    //controlaPesquisas();
    return false;

}

// Fun��o de valida��o do campo de conta
function validaCampo(campo, valor) {

    // conta
    if (campo == 'nrdconta' && !validaNroConta(valor)) {
        showError('error', 'D�gito errado.', 'Alerta - Ayllos', '$(\'#' + campo + '\',\'#frmOpcao\').select();');
        return false;
    } 
    return true;
}

// Fun��o para validar os campos da tela im�vel
function validaCamposImovel() {

    // Remover a classe de campo com erro de todos os campos ao iniciar cada valida��o
    $('input[type="text"], select', '#' + frmOpcao).removeClass('campoErro');
    
    // Se for baixa, ir� validar apenas os campos da mesma, pois os demais n�o permitem altera��o
    if (cddopcao == 'B') {
        // Data da baixa manual
        if (cDtdbaixa.val() == "") {
            showError("error", "Data da Baixa deve ser informada.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cDtdbaixa.attr('name') + "','" + frmOpcao + "');");
            return false;
        }

        // Justificativa da inclus�o manual
        if (cDsjstbxa.val() == "") {
            showError("error", "Justificativa para Baixa Manual deve ser informada.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cDsjstbxa.attr('name') + "','" + frmOpcao + "');");
            return false;
        }

        return true;
    }

    // N�mero da Matr�cula
    if (cNrmatcar.val() == "") {
        showError("error","Matr�cula deve ser informada.","Alerta - Ayllos","hideMsgAguardo();focaCampoErro('" + cNrmatcar.attr('name') + "','" + frmOpcao + "');");
        return false;
    }
    if (cNrmatcar.val() <= 0) {
        showError("error","Matr�cula deve ser maior que zero.","Alerta - Ayllos","hideMsgAguardo();focaCampoErro('" + cNrmatcar.attr('name') + "','" + frmOpcao + "');");
        return false;
    }
     
    // CNS cart�rio
    if (cNrcnscar.val() == "") {
        showError("error", "CNS Cart�rio deve ser informado.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cNrcnscar.attr('name') + "','" + frmOpcao + "');");
        return false;
    }
    if (cNrcnscar.val() <= 0) {
        showError("error", "CNS Cart�rio deve ser maior que zero.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cNrcnscar.attr('name') + "','" + frmOpcao + "');");
        return false;
    }
    
    // N�mero garantia
    if (cNrreggar.val() == "") {
        showError("error", "N�mero Garantia deve ser informado.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cNrreggar.attr('name') + "','" + frmOpcao + "');");
        return false;
    }
    if (cNrreggar.val() <= 0) {
        showError("error", "N�mero Garantia deve ser maior que zero.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cNrreggar.attr('name') + "','" + frmOpcao + "');");
        return false;
    }

    // Data garantia
    if (cDtreggar.val() == "") {
        showError("error", "Data Garantia deve ser informada.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cDtreggar.attr('name') + "','" + frmOpcao + "');");
        return false;
    }

    // Grau de garantia
    var vr_nrgragar = (cNrgragar.prop('selectedIndex') == -1) ? "" : cNrgragar.val();
    if (vr_nrgragar == "") {
        showError("error", "Grau de Garantia deve ser informada.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cNrgragar.attr('name') + "','" + frmOpcao + "');");
        return false;
    }
    
    // CEP
    if (cNrceplgr.val() == "" || cNrceplgr.val() == "0") {
        showError("error", "CEP deve ser informado.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cNrceplgr.attr('name') + "','" + frmOpcao + "');");
        return false;
    }

    // Tipo logradouro
    var vr_tplograd = (cTplograd.prop('selectedIndex') == -1) ? "" : cTplograd.val();
    if (vr_tplograd == "") {
        showError("error", "Tipo Logradouro deve ser informado.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cTplograd.attr('name') + "','" + frmOpcao + "');");
        return false;
    }
   
    // Logradouro
    if (cDslograd.val() == "") {
        showError("error", "Logradouro deve ser informado.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cDslograd.attr('name') + "','" + frmOpcao + "');");
        return false;
    }

    // Logradouro
    if (cDslograd.val() == "") {
        showError("error", "Logradouro deve ser informado.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cDslograd.attr('name') + "','" + frmOpcao + "');");
        return false;
    }

    // verificar o que fazer com cNrlograd
    
    /* Bairro n�o � obrigat�rio. No envio do arquivo deve preencher com SB - Sem Bairro
    if (cDsbairro.val() == "") {
        showError("error", "Bairro deve ser informado.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cDsbairro.attr('name') + "','" + frmOpcao + "');");
        return false;
    }*/

    // Estado -> UF
    if (cCdestado.val() == "") {
        showError("error", "UF deve ser informada.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cCdestado.attr('name') + "','" + frmOpcao + "');");
        return false;
    }

    // Cidade
    var vr_cdcidade = (cCdcidade.prop('selectedIndex') == -1) ? "" : cCdcidade.val();
    if (vr_cdcidade == "") {
        showError("error", "Cidade deve ser informada.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cCdcidade.attr('name') + "','" + frmOpcao + "');");
        return false;
    }

    // Data da avalia��o
    if (cDtavlimv.val() == "") {
        showError("error", "Data Avalia��o deve ser informada.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cDtavlimv.attr('name') + "','" + frmOpcao + "');");
        return false;
    }

    // Valor da avalia��o
    if (cVlavlimv.val() == "") {
        showError("error", "Valor Avalia��o deve ser informada.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cVlavlimv.attr('name') + "','" + frmOpcao + "');");
        return false;
    }
    if (cVlavlimv.val() <= 0) {
        showError("error", "Valor Avalia��o deve ser maior que zero.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cVlavlimv.attr('name') + "','" + frmOpcao + "');");
        return false;
    }

    // Data da compra
    if (cDtcprimv.val() == "") {
        showError("error", "Data Compra deve ser informada.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cDtcprimv.attr('name') + "','" + frmOpcao + "');");
        return false;
    }

    // Valor da compra
    if (cVlcprimv.val() == "") {
        showError("error", "Valor Compra deve ser informada.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cVlcprimv.attr('name') + "','" + frmOpcao + "');");
        return false;
    }
    if (cVlcprimv.val() <= 0) {
        showError("error", "Valor Compra deve ser maior que zero.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cVlcprimv.attr('name') + "','" + frmOpcao + "');");
        return false;
    }

    // Tipo de implanta��o
    var vr_tpimpimv = (cTpimpimv.prop('selectedIndex') == -1) ? "" : cTpimpimv.val();
    if (vr_tpimpimv == "") {
        showError("error", "Tipo Implanta��o deve ser informado.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cTpimpimv.attr('name') + "','" + frmOpcao + "');");
        return false;
    }
    
    // Estado de conserva��o
    var vr_incsvimv = (cIncsvimv.prop('selectedIndex') == -1) ? "" : cIncsvimv.val();
    if (vr_incsvimv == "") {
        showError("error", "Estado Conserva��o deve ser informado.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cIncsvcon.attr('name') + "','" + frmOpcao + "');");
        return false;
    }
    
    // Padr�o Acabamento
    var vr_inpdracb = (cInpdracb.prop('selectedIndex') == -1) ? "" : cInpdracb.val();
    if (vr_inpdracb == "") {
        showError("error", "Padr�o Acabamento deve ser informado.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cInpdracb.attr('name') + "','" + frmOpcao + "');");
        return false;
    }

    // �rea Total
    if (cVlmtrtot.val() == "") {
        showError("error", "�rea Total deve ser informada.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cVlmtrtot.attr('name') + "','" + frmOpcao + "');");
        return false;
    }
    if (cVlmtrtot.val() <= 0) {
        showError("error", "�rea Total deve ser maior que zero.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cVlmtrtot.attr('name') + "','" + frmOpcao + "');");
        return false;
    }

    // �rea Privativa
    if (cVlmtrpri.val() == "") {
        showError("error", "�rea Privativa deve ser informada.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cVlmtrpri.attr('name') + "','" + frmOpcao + "');");
        return false;
    }
    if (cVlmtrpri.val() <= 0) {
        showError("error", "�rea Privativa deve ser maior que zero.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cVlmtrpri.attr('name') + "','" + frmOpcao + "');");
        return false;
    }

    // Dormit�rios
    if (cQtdormit.val() == "") {
        showError("error", "Quantidade de Dormit�rios deve ser informada.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cQtdormit.attr('name') + "','" + frmOpcao + "');");
        return false;
    }

    // Vagas Garagem
    if (cQtdvagas.val() == "") {
        showError("error", "Quantidade de Vagas de Garagem deve ser informada.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cQtdvagas.attr('name') + "','" + frmOpcao + "');");
        return false;
    }

    // Validar terreno apenas se o tipo de implanta��o for igual a 2
    if (cTpimpimv.val() == 2) {
        // �rea Terreno
        if (cVlmtrter.val() == "") {
            showError("error", "�rea Terreno deve ser informada.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cVlmtrter.attr('name') + "','" + frmOpcao + "');");
            return false;
        }
        if (cVlmtrter.val() <= 0) {
            showError("error", "�rea Terreno deve ser maior que zero.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cVlmtrter.attr('name') + "','" + frmOpcao + "');");
            return false;
        }

        // Testada
        if (cVlmtrtes.val() == "") {
            showError("error", "Testada deve ser informada.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cVlmtrtes.attr('name') + "','" + frmOpcao + "');");
            return false;
        }
        if (cVlmtrtes.val() <= 0) {
            showError("error", "Testada deve ser maior que zero.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cVlmtrtes.attr('name') + "','" + frmOpcao + "');");
            return false;
        }
    }
    
    // Conserva��o do Condom�nio
    var vr_incsvcon = (cIncsvcon.prop('selectedIndex') == -1) ? "" : cIncsvcon.val();
    if (vr_incsvcon == "") {
        showError("error", "Conserva��o Condom�nio deve ser informada.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cIncsvcon.attr('name') + "','" + frmOpcao + "');");
        return false;
    }

    // Se algum dos campos do vendedor estiver preenchido - deve validar todos
    if (cInpesvdr.val() != "" || cNrdocvdr.val() != "" || cNmvendor.val() != "") {

        // Natureza Vendedor
        if (cInpesvdr.val() == "") {
            showError("error", "Natureza do vendedor deve ser informada.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cInpesvdr.attr('name') + "','" + frmOpcao + "');");
            return false;
        }

        // CPF/CNPJ
        if (cNrdocvdr.val() == "") {
            showError("error", "Documento do vendedor deve ser informado.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cNrdocvdr.attr('name') + "','" + frmOpcao + "');");
            return false;
        }

        // Nome do vendedor
        if (cNmvendor.val() == "") {
            showError("error", "Nome do vendedor deve ser informado.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cNmvendor.attr('name') + "','" + frmOpcao + "');");
            return false;
        }
    }

    // Se estiver executando a op��o de Inclus�o manual 
    if (cddopcao == 'M') {
        // N�mero do registro
        if (cNrreginc.val() == "") {
            showError("error", "N�mero do Registro deve ser informado.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cNrreginc.attr('name') + "','" + frmOpcao + "');");
            return false;
        }
        if (cNrreginc.val() <= 0) {
            showError("error", "N�mero do Registro deve ser maior que zero.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cNrreginc.attr('name') + "','" + frmOpcao + "');");
            return false;
        }

        // Data da inclus�o manual
        if (cDtinclus.val() == "") {
            showError("error", "Data da Inclus�o deve ser informada.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cDtinclus.attr('name') + "','" + frmOpcao + "');");
            return false;
        }

        // Justificativa da inclus�o manual
        if (cDsjstinc.val() == "") {
            showError("error", "Justificativa para Inclus�o Manual deve ser informada.", "Alerta - Ayllos", "hideMsgAguardo();focaCampoErro('" + cDsjstinc.attr('name') + "','" + frmOpcao + "');");
            return false;
        }

    }
    
    // Retornar true indicando que todos os campos foram validados com sucesso
    return true;
}

// Adiciona o contrato especifico ao campo
function add_contrato_tela(nrctremp) {
    var $option = $('<option />').val(nrctremp).text(number_format(nrctremp, 0, ",", "."));
    cNrctremp.append($option);
}

// Adiciona os im�veis ao campo
function add_imovel_tela(idseqbem, dsbemfin) {

    if (idseqbem == 0) {
        var $option = $('<option />').val("").text("Selecione o im�vel...");
    } else {
        var $option = $('<option />').val(idseqbem).text(dsbemfin);
    }

    cIdseqbem.append($option);
}

// Adiciona as cidades ao campo
function add_cidade_tela(cdcidade, dscidade) {
    var $option = $('<option />').val(cdcidade).text(dscidade);
    cCdcidade.append($option);
}

// Fun��o para carregar as cidades da UF - Se for informado o cdcidade, o valor deve ser setado ap�s a carga
function carregar_cidades_uf(campouf, cdcidade) {

    hideMsgAguardo();

    // Se chegar com valor nulo
    if (campouf.val() == "") {

        cCdcidade.html("");
        add_cidade_tela("", "Selecione a UF...");
        cCdcidade.desabilitaCampo();
        return false;

    }

    showMsgAguardo('Aguarde, carregando cidades ...');

    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/imovel/db_busca_cidades.php',
        data: {
            cddopcao: cddopcao,
            cdestado: campouf.val(),
            dscidade: cDscidade.val(),
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function (response) {
            try {
                eval(response);

                // Se n�o for op��o de consulta
                if (cddopcao != 'C' && cddopcao != 'B' && cddopcao != 'M') {
                    // Habilitar o campo
                    cCdcidade.habilitaCampo();
                    cCdcidade.attr('tabindex', '0');  // Restaurar a navega��o correta da tela
                }

                // Se foi informado c�digo cidade => ATEN��O: Este valor pode ser setado dentro da chamada AJAX tbm...
                if (cdcidade != '') {
                    cCdcidade.val(cdcidade);
                }

                cDscidade.val('');

                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
            }
        }
    });

    return false;

}

// Fun��o para bloquear e desbloquear os campos do im�vel... inbloqueia (true = bloqueia / false = desbloqueia)
function controla_bloqueio_campos_imovel(inbloqueia) {
    // Captura todos os campos
    var cSetImoveis = $('input[type="text"], select', '#FS_IMOVEL');
    var cSetVendedor = $('input[type="text"], select', '#FS_VENDEDOR');

    // Se estiver indicando o bloqueio
    if (inbloqueia) {
        cSetImoveis.desabilitaCampo();
        cSetVendedor.desabilitaCampo(); 
        
        // O campo de im�vel segue a linha contr�ria de racioc�nio
        cIdseqbem.habilitaCampo();
        cIdseqbem.attr('tabindex', '0');  // Restaurar a navega��o correta da tela
    } else {
        cSetImoveis.habilitaCampo();
        cSetImoveis.attr('tabindex', '0');  // Restaurar a navega��o correta da tela

        cSetVendedor.habilitaCampo();
        cSetVendedor.attr('tabindex', '0'); // Restaurar a navega��o correta da tela

        // O campo de im�vel segue a linha contr�ria de racioc�nio
        cIdseqbem.desabilitaCampo();
        // O campo do tipo de im�vel n�o pode ser alterado
        cTpimovel.desabilitaCampo();
    }
}

// Busca a lista de im�veis do contrato selecionado e adiciona no campo da tela para sele��o
function buscar_lista_imoveis_contrato() {

    hideMsgAguardo();

    var cdcooper = 0;
    var nrdconta = normalizaNumero(cNrdconta.val());
    var nrctremp = normalizaNumero(cNrctremp.val());

    // Se for op��o X deve passar a cooperativa selecionada em tela
    if (cddopcao == 'X') {
        cdcooper = cCdcooper.val()
    }

    controla_bloqueio_campos_imovel(true);
    
    showMsgAguardo('Aguarde, buscando im�veis do contrato ...');

    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/imovel/db_busca_imoveis_contrat.php',
        data: {
            cddopcao: cddopcao,
            cdcooptl: cdcooper,
            nrdconta: nrdconta,
            nrctremp: nrctremp,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function (response) {
            try {
                eval(response);
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
            }
        }
    });

    return false;
}

// Buscar os dados do Im�vel selecionado na tela
function buscar_dados_imovel() {

    hideMsgAguardo();

    var cdcooper = 0;
    var nrdconta = normalizaNumero(cNrdconta.val());
    var nrctremp = normalizaNumero(cNrctremp.val());
    var idseqbem = cIdseqbem.val();
    
    // Limpar todos os campos do formul�rio
    var cSetImoveis  = $('input[type="text"], select', '#FS_IMOVEL');
    var cSetVendedor = $('input[type="text"], select', '#FS_VENDEDOR');
    var cSetStatus   = $('input[type="text"], select', '#FS_STATUS');
    var cSetInclusao = $('input[type="text"], select', '#FS_INCLUSAO');
    var cSetBaixa    = $('input[type="text"], select', '#FS_BAIXA');

    cSetImoveis.val("");
    cSetVendedor.val("");
    cSetStatus.val("");
    cSetInclusao.val("");
    cSetBaixa.val("");

    cIdseqbem.val(idseqbem);

    // Se for op��o X deve passar a cooperativa selecionada em tela
    if (cddopcao == 'X') {
        cdcooper = cCdcooper.val()
    }

    showMsgAguardo('Aguarde, buscando do im�vel ...');

    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/imovel/db_busca_dados_imovel.php',
        data: {
            cddopcao: cddopcao,
            cdcooptl: cdcooper,
            nrdconta: nrdconta,
            nrctremp: nrctremp,
            idseqbem: idseqbem,
            cddopcao: cddopcao,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function (response) {
            try {
                // Se n�o encontrar erro
                if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                    try {
                        eval(response);

                        switch (cddopcao) {
                            case 'C':
                                trocaBotao('IMPRIME_IMOVEL');
                                cIdseqbem.focus();
                                break;
                            case 'B':
                                // Desabilita campo im�vel
                                cIdseqbem.desabilitaCampo();
                                // Habilita os campos da baixa
                                cDtdbaixa.habilitaCampo();
                                cDsjstbxa.habilitaCampo();
                                cDtdbaixa.attr('tabindex', '0');  // Restaurar a navega��o correta da tela
                                cDsjstbxa.attr('tabindex', '0');  // Restaurar a navega��o correta da tela

                                cDtdbaixa.focus();

                                trocaBotao('BAIXA_IMOVEL');
                                break;
                            case 'M':
                                // Faz o bloqueio dos campos da tela
                                controla_bloqueio_campos_imovel(false);

                                // Habilita os campos da inclus�o
                                cNrreginc.habilitaCampo();
                                cDtinclus.habilitaCampo();
                                cDsjstinc.habilitaCampo();
                                cNrreginc.attr('tabindex', '0');  // Restaurar a navega��o correta da tela
                                cDtinclus.attr('tabindex', '0');  // Restaurar a navega��o correta da tela
                                cDsjstinc.attr('tabindex', '0');  // Restaurar a navega��o correta da tela


                                // Foco no campo da matr�cula
                                cNrmatcar.focus();

                                trocaBotao('INCLUI_IMOVEL');
                                break;
                            case 'X':
                                // Faz o bloqueio dos campos da tela
                                controla_bloqueio_campos_imovel(false);

                                // N�o deve permitir altera��o porque estes dados s�o utilizados como chaves pelo CETIP
                                cNrmatcar.desabilitaCampo();
                                cNrceplgr.desabilitaCampo();

                                // Foco no campo da matr�cula
                                cNrmatcar.focus();

                                trocaBotao('SALVAR_IMOVEL');
                                break;
                            default:
                                // Faz o bloqueio dos campos da tela
                                controla_bloqueio_campos_imovel(false);

                                // Foco no campo da matr�cula
                                cNrmatcar.focus();

                                trocaBotao('SALVAR_IMOVEL');
                        }

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


                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
            }
        }
    });

    controlaPesquisas();
    hideMsgAguardo();
    return false;
}

// FUN��ES DOS BOT�ES DA TELA
// Controla o bot�o Voltar
function btnVoltar() {

    if ((cddopcao == 'N' || cddopcao == 'A' || cddopcao == 'C' || cddopcao == 'X') && isHabilitado(cNrdconta)) {
        estadoInicial();

    } else if ((cddopcao == 'N' || cddopcao == 'A' || cddopcao == 'C' || cddopcao == 'B' || cddopcao == 'M' || cddopcao == 'X') && !isHabilitado(cNrdconta)) {
        formataOpcao();

        // Limpar todos os campos do formul�rio
        var cSetImoveis = $('input[type="text"], select', '#FS_IMOVEL');
        var cSetVendedor = $('input[type="text"], select', '#FS_VENDEDOR');

        cSetImoveis.val("");
        cSetVendedor.val("");

        // Se a op��o for baixa, trata tamb�m o Field
        if (cddopcao == 'B') {
            var cSetBaixa = $('input[type="text"], textarea', '#FS_BAIXA');
            cSetBaixa.val("");
        }

    } else {
        estadoInicial();
    }

    controlaPesquisas();
    return false;
}

// Controla o bot�o prosseguir
function btnContinuar() {

    if (divError.css('display') == 'block') {
        return false;
    }

    var mensagem = 'Aguarde, buscando dados ...';
    showMsgAguardo(mensagem);

    //if (cddopcao == 'N' || cddopcao == 'A' || cddopcao == 'B' || cddopcao == 'C' || cddopcao == 'M') {

    // Se houve altera��o na conta, mas n�o foi realizada a consulta na base de dados
    if (normalizaNumero(cNrdconta.val()) != cContaAux.val()) {
        cNrdconta.keypress();
        hideMsgAguardo();
        return false; // Retorna... pois apenas deve consultar os contratos
    }

    if (cNrctremp.val() == "" || cNrctremp.val() == null || cNrctremp.val() == 0) {
        hideMsgAguardo();
        showError('error', 'N&atilde;o h&aacute; contrato selecionado. Verifique!', 'Alerta - Ayllos', '');
        return false;
    }

    // Se for op��o X desabilita cooperatova
    if (cddopcao == 'X') {
        cCdcooper.desabilitaCampo();
    }

    // Desabilitar os campos de pesquisa
    cNrdconta.desabilitaCampo();
    cNrctremp.desabilitaCampo();

    // Formata o bloco de informa��es do Imovel
    formataImovel();

    // Buscar a lista de im�veis alienados
    buscar_lista_imoveis_contrato();

    // Ocultar o bot�o prosseguir
    trocaBotao('');

    // Exibir os fieldset de imovel e vendedor
    $('#FS_IMOVEL').css({ 'display': 'block' });
    $('#FS_VENDEDOR').css({ 'display': 'block' });

    switch (cddopcao) {
        case 'B':
            formataBaixa();
            $('#FS_BAIXA').css({ 'display': 'block' });
            break;
        case 'C':
            formataStatus();
            $('#FS_STATUS').css({ 'display': 'block' });

            // Formatar os campos da Inclus�o
            formataInclusao();

            // Formatar os campos da baixa
            formataBaixa();

            break;
        case 'M':
            formataInclusao();
            $('#FS_INCLUSAO').css({ 'display': 'block' });
            break;
    }
    
    controlaPesquisas();
    hideMsgAguardo();

    return false;
}

// Fun��o chamada pelo bot�o salvar para salvar os dados do im�vel informado em tela
function btnSalvarImovel() {

    hideMsgAguardo();
    
    // Validar os itens da tela
    if (!validaCamposImovel()) {
        return false;
    }
    
    var vr_cdcooper = 0;
    var vr_nrdconta = normalizaNumero(cNrdconta.val());
    var vr_nrctremp = normalizaNumero(cNrctremp.val());
    var vr_nrceplgr = normalizaNumero(cNrceplgr.val());
    var vr_nrdocvdr = normalizaNumero(cNrdocvdr.val());

    if (cNrlograd.val() != '') {
        var vr_nrlograd = normalizaNumero(cNrlograd.val());
    } else {
        var vr_nrlograd = '';
    }

    var vr_vlavlimv = normalizaNumero(cVlavlimv.val());
    var vr_vlcprimv = normalizaNumero(cVlcprimv.val());
    var vr_vlmtrtot = normalizaNumero(cVlmtrtot.val());
    var vr_vlmtrpri = normalizaNumero(cVlmtrpri.val());
    var vr_vlmtrter = normalizaNumero(cVlmtrter.val());
    var vr_vlmtrtes = normalizaNumero(cVlmtrtes.val());

    // tratar os campos select
    var vr_nrgragar = (cNrgragar.prop('selectedIndex') == -1) ? '' : cNrgragar.val();
    var vr_tplograd = (cTplograd.prop('selectedIndex') == -1) ? '' : cTplograd.val();
    var vr_cdcidade = (cCdcidade.prop('selectedIndex') == -1) ? '' : cCdcidade.val();
    var vr_tpimpimv = (cTpimpimv.prop('selectedIndex') == -1) ? '' : cTpimpimv.val();
    var vr_incsvimv = (cIncsvimv.prop('selectedIndex') == -1) ? '' : cIncsvimv.val();
    var vr_inpdracb = (cInpdracb.prop('selectedIndex') == -1) ? '' : cInpdracb.val();
    var vr_incsvcon = (cIncsvcon.prop('selectedIndex') == -1) ? '' : cIncsvcon.val();

    // Se for op��o X deve passar a cooperativa selecionada em tela
    if (cddopcao == 'X') {
        vr_cdcooper = cCdcooper.val()
    }


    showMsgAguardo('Aguarde, gravando dados do im�vel ...');

    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/imovel/db_salvar_dados_imovel.php',
        data: {
            cddopcao: cddopcao,
            cdcooptl: vr_cdcooper,
            nrdconta: vr_nrdconta,
            nrctremp: vr_nrctremp,
            idseqbem: cIdseqbem.val(),
            nrmatcar: cNrmatcar.val(),
            nrcnscar: cNrcnscar.val(),
            tpimovel: cTpimovel.val(),
            nrreggar: cNrreggar.val(),
            dtreggar: cDtreggar.val(),
            nrgragar: vr_nrgragar,
            nrceplgr: vr_nrceplgr,
            tplograd: vr_tplograd,
            dslograd: cDslograd.val(),
            nrlograd: vr_nrlograd,
            dscmplgr: cDscmplgr.val(),
            dsbairro: cDsbairro.val(),
            cdcidade: vr_cdcidade,
            dtavlimv: cDtavlimv.val(),
            vlavlimv: vr_vlavlimv,
            dtcprimv: cDtcprimv.val(),
            vlcprimv: vr_vlcprimv,
            tpimpimv: vr_tpimpimv,
            incsvimv: vr_incsvimv,
            inpdracb: vr_inpdracb,
            vlmtrtot: vr_vlmtrtot,
            vlmtrpri: vr_vlmtrpri,
            qtdormit: cQtdormit.val(),
            qtdvagas: cQtdvagas.val(),
            vlmtrter: vr_vlmtrter,
            vlmtrtes: vr_vlmtrtes,
            incsvcon: vr_incsvcon,
            inpesvdr: cInpesvdr.val(),
            nrdocvdr: vr_nrdocvdr,
            nmvendor: cNmvendor.val(),
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '');
        },
        success: function (response) {
            try {
                eval(response);
                // Se n�o encontrar erro
                if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                    try {
                        if (cddopcao == 'X') {
                            showError("inform", "Im&oacute;vel salvo com sucesso!", "Alerta - Ayllos", "btnVoltar();");
                        } else {
                            showConfirmacao('Im&oacute;vel salvo com sucesso! Deseja imprimir os dados?', 'Confirma&ccedil;&atilde;o - Ayllos', 'btnPrintImovel();btnVoltar();', 'btnVoltar();', 'sim.gif', 'nao.gif');
                        }
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

                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
            }
        }
    });

}

// Fun��o chamada pelo bot�o IMPRIMIR da tela de consulta de im�veis
function btnPrintImovel() {
    
    var action = UrlSite + 'telas/imovel/db_imprimir_dados_imovel.php';

    $('#nrdconta', '#' + frmPrint).val(normalizaNumero($('#nrdconta', '#' + frmOpcao).val()));
    $('#nrctremp', '#' + frmPrint).val(normalizaNumero($('#nrctremp', '#' + frmOpcao).val()));
    $('#idseqbem', '#' + frmPrint).val($('#idseqbem', '#' + frmOpcao).val());

    $('#sidlogin', '#' + frmPrint).remove();
    $('#' + frmPrint).append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin', '#frmMenu').val() + '" />');
    $('#cddopcao', '#' + frmPrint).remove();
    $('#' + frmPrint).append('<input type="hidden" id="cddopcao" name="cddopcao" value="' + cddopcao + '" />');

    carregaImpressaoAyllos(frmPrint, action, "");
}

// Fun��o que realizar� a chamada para a impress�o do relat�rio conforme solicitado na tela
function btnRelatorio() {

    var action = UrlSite + 'telas/imovel/db_imprimir_relatorios.php';

    // Enviar a op��o para a rotina
    $('#cddopcao', '#' + frmOpcao).val(cddopcao);

    carregaImpressaoAyllos(frmOpcao, action, "");
}

// Fun��o chamada pelo bot�o de inclus�o manual para salvar os dados do im�vel informado em tela
// => Ir� chamar o fonte de inclus�o das informa��es, passando tamb�m os parametros da inclus�o manual
function btnIncluirImovel() {

    hideMsgAguardo();

    // Validar os itens da tela
    if (!validaCamposImovel()) {
        return false;
    }

    var vr_nrdconta = normalizaNumero(cNrdconta.val());
    var vr_nrctremp = normalizaNumero(cNrctremp.val());
    var vr_nrceplgr = normalizaNumero(cNrceplgr.val());
    var vr_nrdocvdr = normalizaNumero(cNrdocvdr.val());
    var vr_nrlograd = normalizaNumero(cNrlograd.val());
    var vr_vlavlimv = normalizaNumero(cVlavlimv.val());
    var vr_vlcprimv = normalizaNumero(cVlcprimv.val());
    var vr_vlmtrtot = normalizaNumero(cVlmtrtot.val());
    var vr_vlmtrpri = normalizaNumero(cVlmtrpri.val());
    var vr_vlmtrter = normalizaNumero(cVlmtrter.val());
    var vr_vlmtrtes = normalizaNumero(cVlmtrtes.val());

    showMsgAguardo('Aguarde, registrando inclus�o manual ...');

    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/imovel/db_salvar_dados_imovel.php',
        data: {
            cddopcao: cddopcao,
            nrdconta: vr_nrdconta,
            nrctremp: vr_nrctremp,
            idseqbem: cIdseqbem.val(),
            nrmatcar: cNrmatcar.val(),
            nrcnscar: cNrcnscar.val(),
            tpimovel: cTpimovel.val(),
            nrreggar: cNrreggar.val(),
            dtreggar: cDtreggar.val(),
            nrgragar: cNrgragar.val(),
            nrceplgr: vr_nrceplgr,
            tplograd: cTplograd.val(),
            dslograd: cDslograd.val(),
            nrlograd: vr_nrlograd,
            dscmplgr: cDscmplgr.val(),
            dsbairro: cDsbairro.val(),
            cdcidade: cCdcidade.val(),
            dtavlimv: cDtavlimv.val(),
            vlavlimv: vr_vlavlimv,
            dtcprimv: cDtcprimv.val(),
            vlcprimv: vr_vlcprimv,
            tpimpimv: cTpimpimv.val(),
            incsvimv: cIncsvimv.val(),
            inpdracb: cInpdracb.val(),
            vlmtrtot: vr_vlmtrtot,
            vlmtrpri: vr_vlmtrpri,
            qtdormit: cQtdormit.val(),
            qtdvagas: cQtdvagas.val(),
            vlmtrter: vr_vlmtrter,
            vlmtrtes: vr_vlmtrtes,
            incsvcon: cIncsvcon.val(),
            inpesvdr: cInpesvdr.val(),
            nrdocvdr: vr_nrdocvdr,
            nmvendor: cNmvendor.val(),
            nrreginc: cNrreginc.val(),
            dtinclus: cDtinclus.val(),
            dsjstinc: cDsjstinc.val(),
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '');
        },
        success: function (response) {
            try {
                eval(response);
                // Se n�o encontrar erro
                if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                    try {
                        showError("inform", "Inclus�o manual registrada com sucesso!", "Alerta - Ayllos", "");

                        trocaBotao('');

                        // Realizar o bloqueio dos campos
                        controla_bloqueio_campos_imovel(true);

                        cIdseqbem.desabilitaCampo();
                        cNrreginc.desabilitaCampo();
                        cDtinclus.desabilitaCampo();
                        cDsjstinc.desabilitaCampo();

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

                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
            }
        }
    });

}

// Fun��o chamada pelo bot�o de baixa manual para registrar os dados da baixa
function btnBaixarImovel() {

    hideMsgAguardo();

    // Validar os itens da tela
    if (!validaCamposImovel()) {
        return false;
    }

    var nrdconta = normalizaNumero(cNrdconta.val());
    var nrctremp = normalizaNumero(cNrctremp.val());
    var idseqbem = cIdseqbem.val();
    var dtdbaixa = cDtdbaixa.val();
    var dsjstbxa = cDsjstbxa.val();

    showMsgAguardo('Aguarde, registrando baixa manual ...');

    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/imovel/db_baixa_manual_imovel.php',
        data: {
            cddopcao: cddopcao,
            nrdconta: nrdconta,
            nrctremp: nrctremp,
            idseqbem: idseqbem,
            dtdbaixa: dtdbaixa,
            dsjstbxa: dsjstbxa,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '');
        },
        success: function (response) {
            try {
                eval(response);
                // Se n�o encontrar erro
                if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                    try {
                        showError('inform', 'Baixa manual registrada com sucesso!', 'Alerta - Ayllos', '');
                        
                        trocaBotao('');

                        cDtdbaixa.desabilitaCampo();
                        cDsjstbxa.desabilitaCampo();

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

                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
            }
        }
    });

}

// Solicita a confirma��o para a gera��o do arquivo
function btnGerarArquivo() {
    showConfirmacao('Confirma gera&ccedil;&atilde;o do arquivo?', 'Confirma&ccedil;&atilde;o - Ayllos', 'gerarArquivoCetip();', '', 'sim.gif', 'nao.gif');
    return false;
}

// Solicita a confirma��o para o processamento dos arquivos de retorno
function btnRetornoArquivo() {
    showConfirmacao('Confirma processamento dos arquivos de retorno?', 'Confirma&ccedil;&atilde;o - Ayllos', 'receberArquivosCetip();', '', 'sim.gif', 'nao.gif');
    return false;
}

// Realizar o procedimento de processamento dos arquivos retornados pelo Cetip
function receberArquivosCetip() {
    hideMsgAguardo();

    showMsgAguardo('Aguarde, processando arquivos ...');

    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/imovel/db_leitura_arquivo_cetip.php',
        data: {
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function (response) {
            try {
                eval(response);

                // Se n�o encontrar erro
                if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                    try {
                        showError("inform", "Arquivos processados com sucesso!", "Alerta - Ayllos", "estadoInicial();");
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

                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
            }
        }
    });

    return false;
}

// Gerar o arquivo que ser� enviado ao Cetip, conforme par�metros
function gerarArquivoCetip() {
    hideMsgAguardo();
    
    showMsgAguardo('Aguarde, gerando arquivo ...');
    
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/imovel/db_gerar_arquivo_cetip.php',
        data: {
            cddopcao: cddopcao,
            cdcooper: cCdcooper.val(),
            intiparq: cIntiparq.val(),
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function (response) {
            try {
                eval(response);

                // Se n�o encontrar erro
                if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                    try {
                        showError("inform", "Arquivo gerado com sucesso!", "Alerta - Ayllos", "estadoInicial();");
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

                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
            }
        }
    });

    return false;
}

// Ajusta as pesquisas da tela - lupas
function controlaPesquisas() {

    // Atribui a classe lupa para os links e desabilita todos
    $('a', '#' + frmOpcao).addClass('lupa').css('cursor', 'auto');

    // Percorrendo todos os links
    $('a', '#' + frmOpcao).each(function () {
        if (!$(this).prev().hasClass('campoTelaSemBorda')) { $(this).css('cursor', 'pointer'); }
    });

    /*---------------------*/
    /*  CONTROLE CONTA/DV  */
    /*---------------------*/
    var linkConta = $('a[class!="botao"]:eq(0)', '#' + frmOpcao);

    // Verificar se o campo de NRDCONTA est� bloqueado para edi��o
    if ($('#nrdconta', '#' + frmOpcao).hasClass('campoTelaSemBorda')) {
        // Retirar a funcionalidade da LUPA
        linkConta.addClass('lupa').css('cursor', 'auto').unbind('click').bind('click', function () {
            return false;
        });
    } else {
        // Atribuir a funcionalidade � lupa
        linkConta.css('cursor', 'pointer').unbind('click').bind('click', function () {
            mostraPesquisaAssociado('nrdconta', frmOpcao);
        });
    }

    /*---------------------*/
    /*  CONTROLE CEP       */
    /*---------------------*/
    //var camposOrigem = 'nrceplgr;dslograd;nrlograd;;dsbairro;cdestado;dscidade';
    var camposOrigem = 'nrceplgr;dslograd;tplograd;complend;nrcxapst;dsbairro;cdestado;dscidade';
    $('#nrceplgr', '#' + frmOpcao).buscaCEP('frmOpcao', camposOrigem, $('#divTela')); 

    return false;
}

// Ajusta a exibi��o dos campos de status do im�vel, conforme situa��o
function ajusta_status_imovel(cdsituac, tpinclus, tpdbaixa) {

    var situacao;

    // Ocultar o campo critica e exibir apenas se for um imovel processado com cr�tica
    $("#divdscritic", '#' + frmOpcao).hide();

    // Ocultar os dados da inclus�o e da baixa
    $('#FS_INCLUSAO').css({ 'display': 'none' });
    $('#FS_BAIXA').css({ 'display': 'none' });

    // verificar o c�digo da situa��o retornado
    switch (cdsituac) {
        case 0:
            situacao = 'N�O ENVIADO';
            break;
        case 1:
            situacao = 'EM PROCESSAMENTO';
            break;
        case 2:
            // Alterar a legenda do Fieldset
            $('#LG_INCLUSAO').html('Dados da Inclus�o');

            // Exibir os dados da inclus�o 
            $('#FS_INCLUSAO').css({ 'display': 'block' });

            if (tpinclus == 'A') {
                situacao = 'REGISTRADO VIA ARQUIVO';
                $("#divdsjstinc", '#' + frmOpcao).hide();
            } else {
                if (tpinclus == 'M') {
                    situacao = 'REGISTRADO MANUAL';
                    $("#divdsjstinc", '#' + frmOpcao).show();
                }
            }
            break;
        case 3:
            situacao = 'PROCESSADO COM CR�TICA';
            $("#divdscritic", '#' + frmOpcao).show();
            break;
        case 4:
            // Alterar a legenda do Fieldset
            $('#LG_INCLUSAO').html('Dados da Inclus�o');
            $('#LG_BAIXA').html('Dados da Baixa');

            // Exibir os dados da inclus�o e da baixa
            $('#FS_INCLUSAO').css({ 'display': 'block' });
            $('#FS_BAIXA').css({ 'display': 'block' });

            // A situa��o 4 deve tratar a exibi��o da inclus�o
            if (tpinclus == 'A') {
                $("#divdsjstinc", '#' + frmOpcao).hide();
            } else {
                $("#divdsjstinc", '#' + frmOpcao).show();
            }

            if (tpdbaixa == 'A') {
                situacao = 'BAIXADO VIA ARQUIVO';
                $("#divdsjstbxa", '#' + frmOpcao).hide();
            } else {
                if (tpdbaixa == 'M') {
                    situacao = 'BAIXADO MANUAL';
                    $("#divdsjstbxa", '#' + frmOpcao).show();
                }
            }

            break;
        case 5:
            situacao = 'BAIXA COM CR�TICA';
            $("#divdscritic", '#' + frmOpcao).show();
            break;
    }

    // Atribui a situa��o para o campo
    cDsstatus.val(situacao);

}

// Configura o campo de documento do vendedor, conforme a natureza selecionada
function ajusta_pessoa_vendedor() {
    // Limpar o campo com a informa��o do documento do vendedor
    cNrdocvdr.val("");
    
    if (cInpesvdr.val() == 1 || cInpesvdr.val() == 3 || cInpesvdr.val() == 5) {
        cNrdocvdr.removeClass('cnpj');
        cNrdocvdr.addClass('cpf');
    } else {
        cNrdocvdr.removeClass('cpf');
        cNrdocvdr.addClass('cnpj');
    }

    // Reajusta as m�scaras dos campos
    layoutPadraoImovel();
}

// Busca a lista de emprestimos do cooperado informado na tela
function buscar_cooperado_emprestimo() {

    hideMsgAguardo();

    var cdcooper = 0;
    var nrdconta = normalizaNumero($('#nrdconta', '#' + frmOpcao).val());

    if (nrdconta == "") {
        return false;
    }

    // Se for op��o X deve passar a cooperativa selecionada em tela
    if (cddopcao == 'X') {
        cdcooper = cCdcooper.val()
    }

    cTodosOpcao.removeClass('campoErro');
    showMsgAguardo('Aguarde, buscando dados ...');

    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/imovel/db_busca_emprestimos.php',
        data: {
            cddopcao: cddopcao,
            cdcooptl: cdcooper,
            nrdconta: nrdconta,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function (response) {
            try {
                eval(response);
                cNrctremp.focus();
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
            }
        }
    });

    return false;
}

// Fun��o chamada internamente nas rotinas de pesquisa de endere�o
function mtSelecaoEndereco() {

    // For�a a execu��o do processo de change do campo
    carregar_cidades_uf(cCdestado);

    // CAMPOS A SEREM LIMPOS
    // Tipo logradouro 
    cTplograd.val("");
    // N�mero do Logradouro
    cNrlograd.val("");
    // Complemento
    cDscmplgr.val("");

    cNrceplgr.focus();
    
}

// Esta fun��o pode receber por parametro o nome do bot�o ou literal a ser tratado de forma particular
function trocaBotao(botao) {

    $('#divBotoes', '#divTela').html('');
    $('#divBotoes', '#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>');

    switch (botao) {
        case 'SALVAR_IMOVEL':
            $('#divBotoes', '#divTela').append('&nbsp;<a href="#" class="botao" onclick="btnSalvarImovel(); return false;" >Salvar</a>');
            break;
        case 'IMPRIME_IMOVEL':
            $('#divBotoes', '#divTela').append('&nbsp;<a href="#" class="botao" onclick="btnPrintImovel(); return false;" >Imprimir</a>');
            break;
        case 'BAIXA_IMOVEL':
            $('#divBotoes', '#divTela').append('&nbsp;<a href="#" class="botao" onclick="btnBaixarImovel(); return false;" >Registrar Baixa</a>');
            break;
        case 'INCLUI_IMOVEL':
            $('#divBotoes', '#divTela').append('&nbsp;<a href="#" class="botao" onclick="btnIncluirImovel(); return false;" >Registrar Inclus�o</a>');
            break;
        default:
            if (botao != '') {
                $('#divBotoes', '#divTela').append('&nbsp;<a href="#" class="botao" onclick="btnContinuar(); return false;" >' + botao + '</a>');
            }
    }

    return false;
}

// Busca as cooperativas a serem listadas na tela 
function lista_coop() {

    mensagem = 'Aguarde, processando ...';

    // Mostra mensagem de aguardo
    showMsgAguardo(mensagem);

    // Carrega dados da conta atrav�s de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/imovel/db_busca_cooperativa.php",
        data: {
            cddopcao: cddopcao,
            redirect: "html_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "");
        },
        success: function (response) {
            hideMsgAguardo();
            try {
                eval(response);
                hideMsgAguardo();
            } catch (error) {
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "");
            }
        }
    });

}

// Fun��o criada para chamar a fun��o layoutPadrao, porem com altera��o da mascara do campo de classe
// numerocasa, pois a mascara deve permitir deixar o campo em branco.
function layoutPadraoImovel() {

    // Ajustar os padr�es de layout
    layoutPadrao();

    // Alterar a mascara para a classe numero casa, de forma que permita deixar o campo em branco
    $('input.numerocasa').setMask('INTEGER', 'zzz.zzz', '.', '');
}

function fnMsgRegistroEncontrado(nrmatcar) { 
    // Se n�o tem n�mero de matr�cula � porque n�o encontrou registro, nesse caso exibe a mensagem de aviso
    if (nrmatcar == "") {
        showError("inform", "Dados ainda n&atilde;o cadastrados na tela Im&oacute;vel!", "Alerta - Ayllos", "return false;");
    }
}

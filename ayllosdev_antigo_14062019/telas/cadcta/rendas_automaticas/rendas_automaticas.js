/*!
 * FONTE        : rendas_automaticas.js
 * CRIAÇÃO      : Odirlei Busana - AMcom
 * DATA CRIAÇÃO : 02/11/2017
 * OBJETIVO     : Biblioteca de funções na rotina para exibir detalhes 
 *                das rendas automaticas, extraido da tela Contas-> comercial
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */

var nrdrowid = ''; // Chave da Tabela Progress
var cdnvlcgo = ''; // Nível do cargo
var cdturnos = ''; // Cód. Turmo 
var nomeForm = 'frmDadosComercial'; // Nome do Formulário
var operacao = '';
var cddrendi = '';
var vlrdrend = '';
var nmdfield = '';
var otrsrend = '';
var flgContinuar = false;     // Controle botao Continuar	

function acessaOpcaoAba(nrOpcoes, id, opcao) {

    // Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, carregando...');

    // Atribui cor de destaque para aba da opção
    for (var i = 0; i < nrOpcoes; i++) {
        if (!$('#linkAba' + id)) {
            continue;
        }

        if (id == i) { // Atribui estilos para foco da opção
            $('#linkAba' + id).attr('class', 'txtBrancoBold');
            $('#imgAbaEsq' + id).attr('src', UrlImagens + 'background/mnu_sle.gif');
            $('#imgAbaDir' + id).attr('src', UrlImagens + 'background/mnu_sld.gif');
            $('#imgAbaCen' + id).css('background-color', '#969FA9');
            continue;
        }

        $('#linkAba' + i).attr('class', 'txtNormalBold');
        $('#imgAbaEsq' + i).attr('src', UrlImagens + 'background/mnu_nle.gif');
        $('#imgAbaDir' + i).attr('src', UrlImagens + 'background/mnu_nld.gif');
        $('#imgAbaCen' + i).css('background-color', '#C6C8CA');
    }

    // Carrega conteúdo da opção através do Ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cadcta/rendas_automaticas/principal.php',
        data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            flgcadas: flgcadas,
            operacao: '',
            redirect: 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function (response) {
            if (response.indexOf('showError("error"') == -1) {
                $('#divConteudoOpcao').html(response);
            } else {
                eval(response);
                controlaFoco(operacao);
            }
            return false;
        }
    });
}

function controlaFoco(operacao) {
    if (in_array(operacao, [''])) {
        $('#btAlterar', '#divBotoes').focus();
    } else if (operacao == 'CAE') {
        if ((cooperativa == 2 && $('#cdempres', '#' + nomeForm).val() == 88) || $('#cdempres', '#' + nomeForm).val() == 81) {
            $('#nmextemp', '#' + nomeForm).focus();
        } else {
            $('#dsproftl', '#' + nomeForm).focus();
        }
    } else {
        $('#cdnatopc', '#' + nomeForm).focus();
    }
    return false;
}

function retornaContaSelect() {
    return contaSelect;
}

function tabelaReferencia(qtlinhas) {

    $('fieldset').css({ 'clear': 'both', 'border': '1px solid #777', 'margin': '3px 0px', 'padding': '0 3px 5px 3px' });
    $('fieldset > legend').css({ 'font-size': '11px', 'color': '#777', 'margin-left': '5px', 'padding': '0px 2px' });

    var divRegistro = $('#RendasAutomaticas div.divRegistros');
    var tabela = $('table', divRegistro);
    var nrlinhas = qtlinhas - 1;

    divRegistro.css({ 'height': '180px' });

    var ordemInicial = new Array();
    //ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '62px';
    arrayLargura[1] = '210px';
    arrayLargura[2] = '69px';


    var arrayAlinha = new Array();
    arrayAlinha[0] = 'left';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'right';

    var metodoTabela = '';


    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

    //Seleciona o registro que tiver foco
    $('table > tbody > tr', divRegistro).focus(function () {
        selecionaRendimento($(this));

    });

    //Seleciona o registro que é clicado
    $('table > tbody > tr', divRegistro).click(function () {
        selecionaRendimento($(this));

    });

    $('#divReferencia').css('display', 'block');
    $('#divRegistrosRodape', '#divReferencia').formataRodapePesquisa();

    return false;
}


function buscaReferenciaFolha(nrdconta) {
    
    hideMsgAguardo();

    var mensagem = '';

    mensagem = 'Aguarde, buscando ...';

    showMsgAguardo(mensagem);


    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + 'telas/cadcta/rendas_automaticas/busca_rendas_automaticas.php',
        data: {
            nrdconta: nrdconta,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCabCadlng').focus()");
        },
        success: function (response) {
            try {
                hideMsgAguardo();
                //alert(response);
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmPesqti').focus()");
            }
        }
    });

}

function voltarRotina() {
    encerraRotina(false);
    acessaRotina('CONTATOS', 'Contatos', 'contatos_pf');
}

function proximaRotina() {
    hideMsgAguardo();
    acessaOpcaoAbaDados(3, 1, '@');
}
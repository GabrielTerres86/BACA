/*!
 * FONTE        : cadres.js
 * CRIAÇÃO      : André Clemer - Supero
 * DATA CRIAÇÃO : 19/07/2018
 * OBJETIVO     : Biblioteca de funções da tela CADRES
 * --------------
 * ALTERAÇÕES   :
 *
 * --------------
 */

var cddopcao = '';

var rCddopcao, rNmrescop,
    cCddopcao, cNmrescop, cCamposAltera;

var cabecalho;
var fomulario;
var grid;
var filtroGridAlcadas;
var popup;
var pesquisa;


var lstCooperativas = new Array();

var frmCab = 'frmCab';

$(document).ready(function () {

    cabecalho = new Cabecalho();
    grid = new Grid();
    filtroGridAlcadas = new FiltroGridAlcadas();
    popup = new PopupAprovadores();
    pesquisa = new PesquisaAprovadores();

    // cabecalho
    cTodosCabecalho = $('input[type="text"],select', '#' + frmCab);
    rCddopcao = $('label[for="cddopcao"]', '#frmCab');
    rNmrescop = $('label[for="nmrescop"]', '#divCooper');

    cCddopcao = $('#cddopcao', '#frmCab');
    cNmrescop = $('#nmrescop', '#divCooper');

    // Opcao O
    // rFlofesms = $('label[for="flofesms"]', '#frmOpcaoO');
    // rDtiniofe = $('label[for="dtiniofe"]', '#frmOpcaoO');
    // rDtfimofe = $('label[for="dtfimofe"]', '#frmOpcaoO');

    estadoInicial();

});


function Cabecalho() {

    Cabecalho.onChangeOpcao = function (componenteOpcoes) {
        Cabecalho.inicializarComponenteOpcao(componenteOpcoes);
    }

    var ehParaRemoverOpcaoTodas = function (opcaoSelecionada) {

        var opcoesParaCooperativa = ["A", "C", "I"]; //Opções que não devem ter a opção Todas

        for (var i = 0, len = opcoesParaCooperativa.length; i < len; i++) {
            if (opcoesParaCooperativa[i] == opcaoSelecionada)
                return true;
        }
        return false;
    }

    Cabecalho.inicializarComponenteOpcao = function (componenteOpcoes) {

        if (ehParaRemoverOpcaoTodas(componenteOpcoes.value)) {
            removerOpcaoTodas();
        } else {
            if ($("#nmrescop option[value='0']").length == 0) {
                adicionarOpcaoTodas();
                getComponenteCooperativas().val('0');
            }
        }
    }

    this.getOpcaoSelecionada = function () {
        return getComponenteOpcoes().val();
    }

    var removerOpcaoTodas = function () {
        if ($("#nmrescop option[value='0']").length > 0) {
            $("#nmrescop option[value='0']").remove();
        }
    }

    var adicionarOpcaoTodas = function () {
        getComponenteCooperativas().prepend($('<option>', {
            value: 0,
            text: 'Todas'
        }));
    }

    this.desabilitarTodosComponentes = function () {
        getTodosComponentes().desabilitaCampo();
    }

    var getTodosComponentes = function () {
        return $('input[type="text"],select', '#frmCab');
    }

    var getComponenteOpcoes = function () {
        return $('#cddopcao', '#frmCab');
    }

    var getComponenteCooperativas = function () {
        return $('#nmrescop', '#divCooper');
    }

    this.getCooperativaSelecionada = function () {
        return getComponenteCooperativas().val();
    }

    this.inicializar = function () {
        Cabecalho.inicializarComponenteOpcao(getComponenteOpcoes());
    }
}

function Grid() {

    var registroSelecionado;
    var atualizarAlcada = 0;

    this.setAtualizarAlcada = function (flregra) {
        atualizarAlcada = flregra;
    }

    this.getAtualizarAlcada = function () {
        return atualizarAlcada;
    }

    var selecionarRegistro = function (Id) {
        registroSelecionado = Id;
    }

    this.getRegistroSelecionado = function () {
        return registroSelecionado;
    }

    var totalRegistros = function (divRegistro) {
        return $('table > tbody > tr', divRegistro).size();
    }

    var existeRegistros = function (divRegistro) {
        return totalRegistros(divRegistro) > 0;
    }

    var selecionarPrimeiroRegistro = function (divRegistro) {

        if (existeRegistros(divRegistro)) {
            var primeiroRegistro = getTodosRegistros()[0];
            selecionarRegistro(primeiroRegistro.id);
        }
    }

    var getTodosRegistros = function () {
        return $('#divAlcadas > .divRegistros > table > tbody > tr');
    }

    var formatarBotoes = function () {

        if (cabecalho.getOpcaoSelecionada() == "A") {
            $("#btDetalhar", "#divAlcadas").hide();
            $("#btAlterar", "#divAlcadas").show();
        } else {
            $("#btDetalhar", "#divAlcadas").show();
            $("#btAlterar", "#divAlcadas").hide();
        }
    }

    Grid.onClick_Aprovadores = function (cdalcada, flgregra) {

        $.ajax({
            type: "POST",
            async: false,
            dataType: 'html',
            url: UrlSite + "telas/cadres/form_aprovadores.php",
            data: {
                cdcooper: cabecalho.getCooperativaSelecionada(),
                cddopcao: cabecalho.getOpcaoSelecionada(),
                cdalcada: cdalcada,
                flgregra: flgregra,
                redirect: "script_ajax" // Tipo de retorno do ajax
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
            },
            beforeSend: function () {
                showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");
            },
            success: function (response) {
                if (response.substr(0, 16).indexOf("hideMsgAguardo") > -1) {
                    eval(response);
                } else {
                    popup.inicializar(response);
                }
                formatar(cdalcada);
            }
        });
    }

    Grid.onClick_Alterar = function () {

        $.ajax({
            type: "POST",
            async: false,
            dataType: 'html',
            url: UrlSite + "telas/cadres/alterar_pacote.php",
            data: {
                idpacote: grid.getRegistroSelecionado(),
                cdcooper: cabecalho.getCooperativaSelecionada(),
                flgativo: 1,
                redirect: "script_ajax" // Tipo de retorno do ajax
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
            },
            beforeSend: function () {
                showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");
            },
            success: function (response) {
                if (response.substr(0, 14) == 'hideMsgAguardo') {
                    eval(response);
                }
            }
        });
    }

    var formatar = function (cdalcada) {

        var divRegistro = $('div.divRegistros', '#divGrid');
        var tabela = $('table', divRegistro);
        divRegistro.css({
            'height': '160px',
            'width': '640px'
        });

        var tabelaHeader = $('table > thead > tr > th', divRegistro);
        var fonteLinha = $('table > tbody > tr > td', divRegistro);

        tabelaHeader.css({
            'font-size': '11px'
        });
        fonteLinha.css({
            'font-size': '11px'
        });

        var ordemInicial = new Array();

        var arrayLargura = new Array();
        arrayLargura[0] = '150px';
        arrayLargura[1] = '290px';
        if (cabecalho.getOpcaoSelecionada() != 'C' && cdalcada != 1) {
            arrayLargura[2] = '200px';
        }

        var arrayAlinha = new Array();
        arrayAlinha[0] = 'left';
        arrayAlinha[1] = 'left';
        if (cabecalho.getOpcaoSelecionada() != 'C' && cdalcada != 1) {
            arrayAlinha[2] = 'center';
        }

        var metodoTabela = '';

        formatarBotoes();

        tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

        if (existeRegistros(divRegistro)) {
            bindRegistrosGrid(divRegistro);
            selecionarPrimeiroRegistro(divRegistro);

            $('.headerSort').click(function () {
                bindRegistrosGrid(divRegistro);
            })
        }
    }

    var bindRegistrosGrid = function (divRegistro) {
        $('table > tbody > tr', divRegistro).click(function () {
            Grid.onRegistroClick(this);
        });
    }

    Grid.onRegistroClick = function (registro) {
        selecionarRegistro(registro.id);
    }

    Grid.formatar = formatar;

    Grid.carregar = function (cooperativa, flgstatus) {

        $.ajax({
            type: "POST",
            dataType: 'html',
            url: UrlSite + "telas/cadres/manter_rotina.php",
            data: {
                cdcooper: cooperativa,
                cddopcao: cabecalho.getOpcaoSelecionada(),
                redirect: "script_ajax" // Tipo de retorno do ajax
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
            },
            beforeSend: function () {
                showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");
            },
            success: function (response) {
                if (response.substr(0, 14) == 'hideMsgAguardo') {
                    eval(response);
                } else {
                    $('#divAlcadas').css({
                        'display': 'block'
                    });
                    $('#divAlcadas').html(response);
                    formatar();
                    hideMsgAguardo();
                }
            }
        });
    }
}

function PesquisaAprovadores() {
    var nriniseq = 1;
    var nrregist = 25;

    this.inicializar = function () {

    }

    PesquisaAprovadores.onPesquisar = function (cdalcada, cdoperad, nmoperad, pNriniseq, pNrregist) {

        nriniseq = pNriniseq ? pNriniseq : nriniseq;
        nrregist = pNrregist ? pNrregist : nrregist;

        nmoperad = nmoperad ? nmoperad : $('#nmdbusca','#divPesquisa').val();
        cdoperad = cdoperad ? cdoperad : $('#nmdbusca','#divPesquisa').val();

        showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");

        $.ajax({
            type: "POST",
            dataType: 'html',
            url: UrlSite + "telas/cadres/pesquisa_aprovadores_resultado.php",
            data: {
                cdcooper: cabecalho.getCooperativaSelecionada(),
                cdalcada: cdalcada,
                cdoperad: cdoperad,
                nmoperad: nmoperad,
                nriniseq: nriniseq,
                nrregist: nrregist,
                redirect: "script_ajax" // Tipo de retorno do ajax
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
            },
            beforeSend: function () {
                showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");
            },
            success: function (response) {
                fechaRotina($('#divRotina'));
                var $div = $('#divResultadoPesquisaAprovadores');
                $div.html(response);
                //$div.setCenterPosition();
                zebradoLinhaTabela($('#divPesquisaAprovadoresItens > table > tbody > tr'));
                $('#divPesquisaAprovadoresRodape').formataRodapePesquisa();
            }
        });
    }

}

function PopupAprovadores() {

    this.inicializar = function (html) {
        $('#divRotina').html(html);
        exibeRotina($('#divRotina'));
        hideMsgAguardo();
        bloqueiaFundo($('#divRotina'));
        formatar();
        //$('#divRotina').setCenterPosition();
    }

    var formatar = function () {

        // desabilitarCampos();

        var opcaoSelecionada = cabecalho.getOpcaoSelecionada();

        if (opcaoSelecionada == "A") {
            habilitarAlteracoes();
        } else {
            $("#btPopupAlterar").hide();
        }

        $("#qtdsms").setMask('INTEGER', 'zzzzzzzz', '', '');
        //$("#perdesconto").addClass('moeda');
        //$("#perdesconto").setMask('INTEGER', 'zzzzzzzz', '', '');
        $("#perdesconto").setMask('DECIMAL', 'zzz.zzz.zzz.zz9,99', ',', '');

    }

    var habilitarAlteracoes = function () {

        getComponenteBotaoAlterar().show();
        getComponenteFlgStatus().habilitaCampo();

        $("#perdesconto").change(function () {
            calcularTarifa();
        });

        $("#qtdsms").change(function () {
            calcularTarifa();
        });
    }

    var getComponenteBotaoAlterar = function () {
        return $("#btPopupAlterar");
    }

    PopupAprovadores.carregarGridAprovadores = function (cdalcada, fncAfter) {
        
        $.ajax({
            type: "POST",
            dataType: 'html',
            url: UrlSite + "telas/cadres/grid_aprovadores.php",
            data: {
                cdcooper: cabecalho.getCooperativaSelecionada(),
                cddopcao: cabecalho.getOpcaoSelecionada(),
                cdalcada: cdalcada,
                fncAfter: fncAfter,
                redirect: "script_ajax"
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + objExcept.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
            },
            beforeSend: function () {
                showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");
            },
            success: function (response) {
                hideMsgAguardo();
                $('#divGrid').html(response);
                fechaRotina($('#divEmailAprovador'));
                Grid.formatar(cdalcada);
                exibeRotina($('#divRotina'));
                if (fncAfter){
                    eval(fncAfter);
                } else {
                    blockBackground(parseInt($('#divRotina').css('z-index')));
               }
            }
        });
    }

    var calcularTarifa = function () {

        $.ajax({
            type: "POST",
            dataType: 'json',
            url: UrlSite + "telas/cadres/calcular_tarifa.php",
            data: {
                cdcooper: cabecalho.getCooperativaSelecionada(),
                cdtarifa: popup.getIdTarifa(),
                qtdsms: popup.getQuantidadeSMS(),
                perdesconto: popup.getPercentualDesconto(),
                redirect: "script_ajax"
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
            },
            beforeSend: function () {
                showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");
            },
            success: function (response) {
                hideMsgAguardo();
                if (response.erro == undefined) {
                    $("#vlsms").val(response.vlsms);
                    $("#vlsmsad").val(response.vlsmsad);
                    $("#vlpacote").val(response.vlpacote);
                } else {
                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + response.erro + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
                }
            }
        });

    }

    var desabilitarCampos = function () {
        getTodosComponentes().desabilitaCampo();
    }

    var getTodosComponentes = function () {
        return $('input[type="text"],select', '#frmPacote');
    }

    this.getFlgStatusSelecionado = function () {
        return getComponenteFlgStatus().val();
    }

    var getComponenteFlgStatus = function () {
        return $("#flgstatus");
    }

    this.isValid = function () {

        var obj = {
            isValid: true,
            Message: ""
        };

        return obj;

    }

    this.adicionarAprovador = function (cdalcada, cdaprovador, dsemail) {
        var cdmetodo = $('#cdmetodo', '#divEmailAprovador').val();
        var validator = popup.isValid();

        if (!validator.isValid) {
            showError("error", validator.Message, "Alerta - Ayllos", "");
            return;
        }

        $.ajax({
            type: "POST",
            async: false,
            dataType: 'html',
            url: UrlSite + "telas/cadres/manter_rotina.php",
            data: {
                cddopcao: 'AX',
                cdcooper: cabecalho.getCooperativaSelecionada(),
                cdalcada: cdalcada,
                cdaprovador: cdaprovador,
                dsemail: dsemail,
                flregra: grid.getAtualizarAlcada(),
                cdmetodo: cdmetodo,
                redirect: "script_ajax" // Tipo de retorno do ajax
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
            },
            beforeSend: function () {
                showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");
            },
            success: function (response) {
                eval(response);

                // checkbox atual
                var $chk = $('[name=chkalcada]#alcada_'+cdalcada);

                // atualiza contador de registros para alçada
                if (cdmetodo === 'I') {
                    var count = parseInt($chk.data('count'));
                    $chk.data('count', ++count);
                }

                // sobrepoe rotina de fechar para evitar retrocesso na marcação do checkbox
                if ($chk.is(':checked')) {
                    if ($('#tdTitTela a', '#divRotina').length) {
                        $('#tdTitTela a', '#divRotina').attr('onclick', "fechaRotina($('#divRotina')); return false;");
                    }
                    if ($('#btPopupVoltar', '#divRotina').length) {
                        $('#btPopupVoltar', '#divRotina').attr('onclick', "fechaRotina($('#divRotina')); return false;");
                    }
                }
            }
        });
    };

    this.excluirAprovador = function (cdaprovador, cdalcada, fncAfter){
        $.ajax({
            type: "POST",
            asyc: false,
            dataType: 'html',
            url: UrlSite + "telas/cadres/manter_rotina.php",
            data: {
                cddopcao: 'EX',
                cdcooper: cabecalho.getCooperativaSelecionada(),
                cdalcada: cdalcada,
                cdaprovador: cdaprovador,
                fncAfter: fncAfter,
                redirect: "script_ajax" // Tipo de retorno do ajax
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + objExcept.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
            },
            beforeSend: function () {
                showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");
            },
            success: function (response) {
                eval(response);

                var count = parseInt($('[name=chkalcada]#alcada_'+cdalcada).data('count'));
                $('[name=chkalcada]#alcada_'+cdalcada).data('count', --count);
            }
        });
    };

    PopupAprovadores.onClick_Adicionar = function (cdalcada, cdaprovador, nome, email, fromPesquisa) {
        fechaRotina($('#divPesquisa'));
        fechaRotina($('#divRotina'));

        exibeRotina($('#divEmailAprovador'));
        blockBackground(parseInt($('#divEmailAprovador').css('z-index')));

        $('#btVoltar', '#divEmailAprovador').attr('onclick', 'PopupAprovadores.onClick_Voltar('+fromPesquisa+');');

        if (fromPesquisa) {
            $('#cdmetodo', '#divEmailAprovador').val('I');
        } else {
            $('#cdmetodo', '#divEmailAprovador').val('A');
        }

        $('#cdalcada', '#divEmailAprovador').val(cdalcada);
        $('#cdaprovador', '#divEmailAprovador').val(cdaprovador);

        $('#lbnome', '#divEmailAprovador').text(nome);
        $('#dsemail', '#divEmailAprovador').val(email);
        
    }

    PopupAprovadores.onClick_Confirmar = function () {
        var cdalcada = $('#cdalcada', '#divEmailAprovador').val();
        var cdaprovador = $('#cdaprovador', '#divEmailAprovador').val();
        var dsemail = $('#dsemail', '#divEmailAprovador').val();
        
        if (!dsemail.trim()) {
            showError("error", "O preenchimento do campo e-mail &eacute; obrigat&oacute;rio.", "Alerta - Ayllos", "$('#dsemail','#divEmailAprovador').focus();blockBackground(parseInt($('#divEmailAprovador').css('z-index')));");
            return;
        }

        if (!validaEmail(dsemail)) {
            showError("error", "O e-mail informado &eacute; inv&aacute;lido.", "Alerta - Ayllos", "$('#dsemail','#divEmailAprovador').focus();blockBackground(parseInt($('#divEmailAprovador').css('z-index')));");
            return;
        }

        var msg = "Confirma a adi&ccedil;&atilde;o do aprovador?";

        if ($('#cdmetodo', '#divEmailAprovador').val() === 'A') {
            msg = "Confirma a altera&ccedil;&atilde;o do aprovador?";
        }

        showConfirmacao(msg, "Confirma&ccedil;&atilde;o - Ayllos", "popup.adicionarAprovador('"+cdalcada+"', '"+cdaprovador+"', '"+dsemail+"');", "blockBackground(parseInt($('#divPesquisa').css('z-index')));", 'sim.gif','nao.gif');

    }

    PopupAprovadores.onClick_Voltar = function (fromPesquisa) {

        fechaRotina($('#divPesquisa'));
        fechaRotina($('#divEmailAprovador'));

        if (fromPesquisa) {
            exibeRotina($('#divPesquisa'));
        } else {
            exibeRotina($('#divRotina'));
        }

    }

    PopupAprovadores.onClick_Excluir = function (cdaprovador, cdalcada) {

        // verifica se existem mais registros além do atual
        var siblings = $(event.target).parent().parent().siblings().length; // img > td > tr

        if (!siblings && $('[name=chkalcada]#alcada_'+cdalcada).is(':checked')) {
            showConfirmacao("Confirma a remo&ccedil;&atilde;o do aprovador?<br>A al&ccedil;ada ser&aacute; desativada para esta cooperativa.", "Confirma&ccedil;&atilde;o - Ayllos", "popup.excluirAprovador('"+cdaprovador+"', '"+cdalcada+"', 'atualizarAlcada("+cdalcada+", 0);');", "blockBackground(parseInt($('#divRotina').css('z-index')));", 'sim.gif','nao.gif');
        } else {
            showConfirmacao("Confirma a remo&ccedil;&atilde;o do aprovador?", "Confirma&ccedil;&atilde;o - Ayllos", "popup.excluirAprovador('"+cdaprovador+"', '"+cdalcada+"', '');", "blockBackground(parseInt($('#divRotina').css('z-index')));", 'sim.gif','nao.gif');
        }
    }

    PopupAprovadores.onClick_Pesquisar = function (nomePesquisa, cdalcada) {
        //exibeRotina($('#divPesquisa'));
        blockBackground(parseInt($('#divPesquisa').css('z-index')));
        $('#nmdbusca', '#frmPesquisaAprovadores').val(nomePesquisa);
        $('#cdalcada', '#frmPesquisaAprovadores').val(cdalcada);

        //PopupAprovadores.onClick_Voltar();

        PopupAprovadores.onClick_doPesquisar(nomePesquisa, nomePesquisa);
    }

    PopupAprovadores.onClick_doPesquisar = function (cdoperad, nmoperad) {
        var cdalcada = $('#cdalcada', '#frmPesquisaAprovadores').val();

        PesquisaAprovadores.onPesquisar(cdalcada, cdoperad, nmoperad);
    }

    PopupAprovadores.onClick_Registro = function (dsemail) {
        $('#dsemail','.complemento').html(dsemail);
    }

    PopupAprovadores.onDblClick_Registro = function (cdalcada, cdaprovador, nmoperad, dsemail) {
        PopupAprovadores.onClick_Adicionar(cdalcada, cdaprovador, nmoperad, dsemail, false);
    }
}

function FiltroGridAlcadas() {

    this.exibir = function () {
        /*getFormulario().show();
        habilitarFiltro();
        exibirBotoes();*/
        prosseguir();
    }

    var getFormulario = function () {
        return $('#frmFiltroGrid');
    }

    var getFiltroSelecionado = function () {
        return getComponenteFlgstatus().val();
    }

    var getComponenteFlgstatus = function () {
        return getFormulario().find("#flgstatus");
    }

    var exibirBotoes = function () {
        getComponenteBotoes().show();
    }

    var ocultarBotoes = function () {
        getComponenteBotoes().hide();
    }

    var getComponenteBotoes = function () {
        return getFormulario().find("#divBotoes");
    }

    var desabilitarFiltro = function () {
        getComponenteFlgstatus().desabilitaCampo();
    }

    var habilitarFiltro = function () {
        getComponenteFlgstatus().habilitaCampo();
    }

    var prosseguir = function () {
        ocultarBotoes();
        desabilitarFiltro();
        //Grid.carregar(cabecalho.getCooperativaSelecionada(), getFiltroSelecionado());
    }

    FiltroGridAlcadas.onClick_Prosseguir = prosseguir;

}

// seletores
function estadoInicial() {

    cabecalho.inicializar();

    $('#divTela').fadeTo(0, 0.1);

    fechaRotina($('#divRotina'));

    // Limpa formularios
    cTodosCabecalho.limpaFormulario();
    // habilita foco no formulário inicial
    highlightObjFocus($('#frmCab'));

    $('#nmrescop', '#frmFiltros').val(0);

    Cabecalho.inicializarComponenteOpcao($('#cddopcao', '#frmCab')[0]);

    controlaLayout();

    removeOpacidade('divTela');
    $('#cddopcao', '#frmCab').focus();

    return false;

}

function controlaLayout() {

    cCamposAltera = $('#nmrescop,#dtiniope,#dtfimope', '#frmFiltros');

    $('#frmFiltroGrid').css({
        'display': 'none'
    });
    $('#divAlcadas').css({
        'display': 'none'
    });
    formataCabecalho();

    layoutPadrao();
    return false;
}

function formataCabecalho() {

    // Cabeçalho
    $('#cddopcao', '#' + frmCab).focus();

    var btnOK = $('#btnOK', '#frmCab');

    rCddopcao.addClass('rotulo').css({
        'width': '68px'
    });
    cCddopcao.css({
        'width': '330px'
    });

    rNmrescop.css({
        'padding-left': '10px'
    });
    cNmrescop.addClass('rotulo').css('width', '130px');

    cTodosCabecalho.habilitaCampo();
    return false;
}

function FormataOpcaoA() {

    // Centralizar a div
    var larguraRotina = $("#div_opcao_a").innerWidth();
    var larguraObjeto = $('#div_opcao_a').innerWidth();

    var left = larguraRotina - larguraObjeto;
    left = Math.floor(left / 2);

    $('#div_opcao_a').css('margin-left', left.toString());
    $('#div_opcao_a').css('margin-bottom', '10px');

    layoutPadrao();
}

function atualizarAlcada(cdalcada, flregra) {
    $.ajax({
        type: "POST",
        dataType: 'html',
        url: UrlSite + "telas/cadres/manter_rotina.php",
        data: {
            cddopcao: 'FX',
            cdcooper: cabecalho.getCooperativaSelecionada(),
            cdalcada: cdalcada,
            flregra: flregra,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + objExcept.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
        },
        beforeSend: function () {
            showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");
        },
        success: function (response) {
            hideMsgAguardo();
            eval(response);
            fechaRotina($('#divRotina'));
            // caso seja chamado através de outra rotina e não direto da seleção do checkbox da tela
            if (!flregra && $('[name=chkalcada]#alcada_'+cdalcada).is(':checked')){
                $('[name=chkalcada]#alcada_'+cdalcada).prop('checked', false);
            }
        }
    });
}

function formataOpcaoA() {
    filtroGridAlcadas.exibir();
    zebradoLinhaTabela($('#divAlcadas > .divRegistros > table > tbody > tr'));

    $('[name=chkalcada]', '#divAlcadas').click(function (){
        var $el = $(this),
            cdalcada = $el.val(),
            flgregra = $el.is(':checked') ? 1 : 0,
            id = $el.attr('id')
            count = parseInt($el.data('count'));

        if (flgregra && !count) {
            grid.setAtualizarAlcada(1);
            Grid.onClick_Aprovadores(cdalcada, flgregra);
        } else {
            grid.setAtualizarAlcada(0);
            showConfirmacao("A al&ccedil;ada ser&aacute; atualizada, confirma a opera&ccedil;&atilde;o?", "Confirma&ccedil;&atilde;o - Ayllos", "atualizarAlcada('"+cdalcada+"', "+flgregra+");", "$('#"+id+"').prop('checked', "+(!flgregra)+");", 'sim.gif','nao.gif');
        }

    });
}

function formataOpcaoC() {
    filtroGridAlcadas.exibir();
    zebradoLinhaTabela($('#divAlcadas > .divRegistros > table > tbody > tr'));
}

function LiberaCampos() {

    cabecalho.desabilitarTodosComponentes();

    switch (cabecalho.getOpcaoSelecionada()) {
        case 'A':
        case 'C':
            $.ajax({
                type: "POST",
                dataType: 'html',
                url: UrlSite + "telas/cadres/manter_rotina.php",
                data: {
                    cdcooper: cabecalho.getCooperativaSelecionada(),
                    cddopcao: cabecalho.getOpcaoSelecionada(),
                    redirect: "script_ajax" // Tipo de retorno do ajax
                },
                error: function (objAjax, responseError, objExcept) {
                    hideMsgAguardo();
                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
                },
                beforeSend: function () {
                    showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");
                },
                success: function (response) {
                    if (response.substr(0, 14) == 'hideMsgAguardo') {
                        eval(response);
                    } else {
                        $('#divAlcadas').html(response);
                        $('#divAlcadas').css({
                            'display': 'block'
                        });
                        if (cabecalho.getOpcaoSelecionada() == 'A') {
                            formataOpcaoA();
                        } else {
                            formataOpcaoC();
                        }
                        hideMsgAguardo();
                    }
                }
            });
            break;
    }

    $('#divBotoes').css({
        'display': 'block'
    });

    return false;

}

function manterRotina(cddopcao) {

    var dsaguardo = '';
    var dsmensag = '';
    var mensagens = [];
    var lotesReenvio = [];
    hideMsgAguardo();
    var cdcoptel = $('#nmrescop', '#frmCab').val();

    if (cddopcao == 'A') {
        showMsgAguardo('Aguarde, carregando al&ccedil;adas...');
    }

    $.ajax({
        type: 'POST',
        async: true,
        url: UrlSite + 'telas/cadres/manter_rotina.php',
        data: {
            cddopcao: cddopcao,
            cdcoptel: cdcoptel,
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

function confirmaOpcaoA() {
    showConfirmacao('Confirma altera&ccedil;&otilde;es?', 'Confirma&ccedil;&atilde;o - Ayllos', 'manterRotina(\'AX\');', '', 'sim.gif', 'nao.gif');
}

function fechaRotinaValidaAlcada($div, cdalcada) {
    fechaRotina($div);

    // checkbox atual
    var $chk = $('[name=chkalcada]#alcada_'+cdalcada);
    var count = parseInt($chk.data('count'));

    // atualiza contador de registros para alçada
    $chk.prop('checked', !!count);

}
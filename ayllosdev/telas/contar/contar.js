/*!
 * FONTE        : contar.js
 * CRIAÇÃO      : André Clemer - Supero
 * DATA CRIAÇÃO : 19/07/2018
 * OBJETIVO     : Biblioteca de funções da tela CONTAR (Consulta de tarifas)
 * --------------
 * ALTERAÇÕES   : 13/08/2019 - Incluir campos no grid, conforme RITM0011962 (Jose Gracik/Mouts).
 *
 * --------------
 */

var cddopcao = '';

var rCddopcao, cCddopcao, cTodosCabecalho;

var cabecalho,
    fomulario,
    grid,
    filtro,
    popup;

var frmCab = '#frmCab';

$(document).ready(function () {

    cabecalho = new Cabecalho();
    grid = new Grid();
    filtro = new Filtro();
    popup = new Popup();

    // cabecalho
    cTodosCabecalho = $('input[type="text"],select', frmCab);
    rCddopcao = $('label[for="cddopcao"]', frmCab);
    cCddopcao = $('#cddopcao', frmCab);

    estadoInicial();
});

function estadoInicial() {

    cabecalho.inicializar();

    $('#divTela').fadeTo(0, 0.1);

    fechaRotina($('#divRotina'));

    // Limpa formularios
    cTodosCabecalho.limpaFormulario();
    filtro.limpaFormulario();

    // habilita foco no formulário inicial
    highlightObjFocus($(frmCab));

    cabecalho.inicializarComponenteOpcao($('#cddopcao', frmCab)[0]);

    controlaLayout();

    removeOpacidade('divTela');
    $('#cddopcao', frmCab).focus();

    return false;
}

function controlaLayout() {

    $('#frmFiltroGrid').css({
        'display': 'none'
    });
    $('#divGrid').css({
        'display': 'none'
    });
    cabecalho.formatar();

    layoutPadrao();

    // Opção
    $('#cddopcao', '#frmCab').unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            LiberaCampos();
            $('#cddgrupo', '#frmFiltroGrid').focus();
            return false;
        }
    });

    // Botão OK da Opção
    $('#btnOK', '#frmCab').unbind('keypress').bind('keypress', function (e) {
        // se pressionou TAB ou ENTER
        if (e.keyCode == 9 || e.keyCode == 13) {
            // libera os campos para continuar
            LiberaCampos();
            return false;
        }
    });

    // Grupo
    $('#cddgrupo', '#frmFiltroGrid').unbind('keypress').bind('keypress', function (e) {
        // se pressionou TAB ou ENTER
        if (e.keyCode == 9 || e.keyCode == 13) {
            // se grupo esta preenchido
            if ($('#dsdgrupo', '#frmFiltroGrid').val() != '') {
                $('#cdtarifa', '#frmFiltroGrid').focus();
            } else {
                filtro.controlaPesquisa('G');
                return false;
            }
        }
    });

    // Tarifa
    $('#cdtarifa', '#frmFiltroGrid').unbind('keypress').bind('keypress', function (e) {
        // se pressionou TAB ou ENTER
        if (e.keyCode == 9 || e.keyCode == 13) {
            if ($('#dstarifa', '#frmFiltroGrid').val() != '') {
                filtro.onClick_Prosseguir();
            } else {
                filtro.controlaPesquisa('T');
            }
            return false;
        }
    });

    return false;
}

function LiberaCampos() {

    cabecalho.desabilitarTodosComponentes();

    if (cabecalho.getOpcaoSelecionada() == 'C') {
        filtro.exibir();
    }

    return false;
}

function Cabecalho() {

    // private
    var getTodosComponentes = function () {
        return $('input[type="text"],select', frmCab);
    }

    var getComponenteOpcoes = function () {
        return $('#cddopcao', frmCab);
    }

    // public
    this.formatar = function () {

        // Cabeçalho
        $('#cddopcao', frmCab).focus();

        var btnOK = $('#btnOK', frmCab);

        cTodosCabecalho.habilitaCampo();
        return false;
    }

    this.onChangeOpcao = function (componenteOpcoes) {
        this.inicializarComponenteOpcao(componenteOpcoes);
    }

    this.inicializarComponenteOpcao = function (componenteOpcoes) {
        //
    }

    this.getOpcaoSelecionada = function () {
        return getComponenteOpcoes().val();
    }

    this.desabilitarTodosComponentes = function () {
        getTodosComponentes().desabilitaCampo();
    }

    this.getCooperativaSelecionada = function () {
        return getComponenteCooperativas().val();
    }

    this.inicializar = function () {
        this.inicializarComponenteOpcao(getComponenteOpcoes());
    }

}

function Grid() {

    // private
    var registroSelecionado;
    var atualizarAlcada = 0;

    var selecionarRegistro = function (Id) {
        registroSelecionado = Id;
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
        return $('#divGrid > .divRegistros > table > tbody > tr');
    }

    var formatarBotoes = function () {

        // cabecalho.getOpcaoSelecionada()
    }

    var bindRegistrosGrid = function (divRegistro) {
        $('table > tbody > tr', divRegistro).click(function () {
            grid.onRegistroClick(this);
        });
    }

    // public
    this.setAtualizarAlcada = function (flregra) {
        atualizarAlcada = flregra;
    }

    this.getAtualizarAlcada = function () {
        return atualizarAlcada;
    }

    this.getRegistroSelecionado = function () {
        return registroSelecionado;
    }

    this.onRegistroClick = function (registro) {
        selecionarRegistro(registro.id);
    }

    this.formatar = function () {

        var cddgrupo = filtro.getFormulario().find('#cddgrupo').val();

        var divRegistro = $('div.divRegistros', '#divGrid');
        var tabela = $('table', divRegistro);

        var ordemInicial = new Array();

        if (cddgrupo == 3) {
            arrayLargura = ['110px', '50px', '185px', '60px', '50px', '145px', '60px', '60px', '80px', '35px', '35px', '40px'];
            arrayAlinha = ['left', 'center', 'left', 'center', 'center', 'left', 'center', 'right', 'right', 'right', 'right', 'right', 'right'];
        } else {
            arrayLargura = ['120px', '50px', '200px', '160px', '70px', '65px', '80px', '60px', '50px', '55px'];
            arrayAlinha = ['left', 'center', 'left', 'left', 'center', 'right', 'right', 'right', 'right', 'right', 'right'];
        }

        var tabelaHeader = $('table > thead > tr > th', divRegistro);
        var fonteLinha = $('table > tbody > tr > td', divRegistro);

        tabelaHeader.css({
            'font-size': '11px'
        });
        fonteLinha.css({
            'font-size': '11px'
        });

        formatarBotoes();

        tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

        $('#divPesquisaRodape', '#divGrid').formataRodapePesquisa();

        if (existeRegistros(divRegistro)) {
            bindRegistrosGrid(divRegistro);
            selecionarPrimeiroRegistro(divRegistro);

            $('.headerSort').click(function () {
                bindRegistrosGrid(divRegistro);
            })
        }
    }

    this.carregar = function (nrregist, nriniseq) {
        $.ajax({
            type: "POST",
            dataType: 'html',
            url: UrlSite + "telas/contar/consultar_tarifas.php",
            data: {
                cddopcao: cabecalho.getOpcaoSelecionada(),
                cddgrupo: filtro.getFormulario().find('#cddgrupo').val(),
                cdtarifa: filtro.getFormulario().find('#cdtarifa').val(),
                nrconven: filtro.getFormulario().find('#nrconven').val(),
                cdlcremp: filtro.getFormulario().find('#cdlcremp').val(),
                nrregist: nrregist,
                nriniseq: nriniseq,
                redirect: "script_ajax" // Tipo de retorno do ajax
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + objExcept + ".", "Alerta - Ayllos", "$('#cddopcao',frmCab).focus()");
            },
            beforeSend: function () {
                showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");
            },
            success: function (response) {
                if (response.substr(0, 14) == 'hideMsgAguardo') {
                    eval(response);
                } else {
                    $('#divGrid').html(response);
                    $('#divGrid').css({
                        'display': 'block'
                    });
                    grid.formatar();
                }
            }
        });
    }

    this.onClick_Voltar = function () {
        estadoInicial();
        LiberaCampos();
    }
}

function Popup() {

    // private
    var formatar = function () {

        // desabilitarCampos();


    }

    // public
    this.getFormulario = function () {
        return $('#frmPesquisaPopup');
    }

    var habilitarAlteracoes = function () {

        getComponenteBotaoAlterar().show();

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

    var desabilitarCampos = function () {
        getTodosComponentes().desabilitaCampo();
    }

    var getTodosComponentes = function () {
        return $('input[type="text"],select', '#frmPacote');
    }

    // public
    this.inicializar = function (html) {
        $('#divRotina').html(html);
        exibeRotina($('#divRotina'));
        hideMsgAguardo();
        bloqueiaFundo($('#divRotina'));
        //$('#divRotina').setCenterPosition();
    }

    this.isValid = function () {

        var obj = {
            isValid: true,
            Message: ""
        };

        return obj;

    }

    this.onClick_Pesquisar = function (tipo) {
        var data = {},
            url = UrlSite;

        if (tipo == 'C') {
            url += "telas/contar/pesquisa_convenios_resultado.php";
            data = {
                cddopcao: cabecalho.getOpcaoSelecionada(),
                nrconven: popup.getFormulario().find('#nrconven').val(),
                ls_nrconven: filtro.getFormulario().find('#nrconven').val(),
                flgativo: popup.getFormulario().find('#flgativo').val(),
                redirect: "script_ajax"
            };
        } else if (tipo == 'L') {
            url += "telas/contar/pesquisa_linhas_resultado.php";
            data = {
                cddopcao: cabecalho.getOpcaoSelecionada(),
                cdlcremp: popup.getFormulario().find('#cdlcremp').val(),
                ls_cdlcremp: filtro.getFormulario().find('#cdlcremp').val(),
                redirect: "script_ajax"
            };
        }

        $.ajax({
            type: "POST",
            dataType: 'html',
            url: url,
            data: data,
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + objExcept + ".", "Alerta - Ayllos", "$('#cddopcao',frmCab).focus()");
            },
            beforeSend: function () {
                showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");
            },
            success: function (response) {
                if (response.substr(0, 14) == 'hideMsgAguardo') {
                    eval(response);
                } else {
                    $('#divResultadoPesquisaPopup').html(response);
                    formatar();
                }
            }
        });
    }

    this.onClick_Selecionar = function (tipo, valor) {
        fechaRotina($('#divRotina'));

        if (tipo == 'C') {
            var qCampo = '#nrconven';
        } else if (tipo == 'L') {
            var qCampo = '#cdlcremp';
        }

        var lista = filtro.getFormulario().find(qCampo).val();
        lista = ((lista) ? lista.split(',') : []);

        lista.push(valor);
        lista.join(',');

        filtro.getFormulario().find(qCampo).val(lista);
    }
}

function Filtro() {

    // private
    var getComponentes = function () {
        return filtro.getFormulario().find('#cddgrupo,#dsdgrupo,#cdtarifa,#dstarifa,#nrconven,#cdlcremp');
    }

    var exibirBotoes = function () {
        getComponenteBotoes().show();
    }

    var ocultarBotoes = function () {
        getComponenteBotoes().hide();
    }

    var getComponenteBotoes = function () {
        return filtro.getFormulario().find("#divBotoes");
    }

    var desabilitarFiltro = function () {
        getComponentes().desabilitaCampo();
    }

    var habilitarFiltro = function () {
        filtro.getFormulario().find('#cddgrupo,#cdtarifa,#nrconven,#cdlcremp').habilitaCampo();
    }

    // public
    this.getFormulario = function () {
        return $('#frmFiltroGrid');
    }

    this.limpaFormulario = function () {
        getComponentes().limpaFormulario();
    }

    this.controlaPesquisa = function (tipo) {

        if (tipo == 'C') {
            $.ajax({
                type: "POST",
                dataType: 'html',
                url: UrlSite + "telas/contar/pesquisa_convenios.php",
                data: {
                    cddopcao: cabecalho.getOpcaoSelecionada(),
                    nrconven: filtro.getFormulario().find('#nrconven').val(),
                    redirect: "script_ajax" // Tipo de retorno do ajax
                },
                error: function (objAjax, responseError, objExcept) {
                    hideMsgAguardo();
                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + objExcept + ".", "Alerta - Ayllos", "$('#cddopcao',frmCab).focus()");
                },
                beforeSend: function () {
                    showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");
                },
                success: function (response) {
                    if (response.substr(0, 14) == 'hideMsgAguardo') {
                        eval(response);
                    } else {
                        popup.inicializar(response);
                    }
                }
            });

        } else if (tipo == 'L') {
            $.ajax({
                type: "POST",
                dataType: 'html',
                url: UrlSite + "telas/contar/pesquisa_linhas.php",
                data: {
                    cddopcao: cabecalho.getOpcaoSelecionada(),
                    cdlcremp: filtro.getFormulario().find('#cdlcremp').val(),
                    redirect: "script_ajax" // Tipo de retorno do ajax
                },
                error: function (objAjax, responseError, objExcept) {
                    hideMsgAguardo();
                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + objExcept + ".", "Alerta - Ayllos", "$('#cddopcao',frmCab).focus()");
                },
                beforeSend: function () {
                    showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");
                },
                success: function (response) {
                    if (response.substr(0, 14) == 'hideMsgAguardo') {
                        eval(response);
                    } else {
                        popup.inicializar(response);
                    }
                }
            });
        } else if (tipo == 'G') {
            // Nome do Formulário que estamos trabalhando
            var nomeFormulario = 'frmFiltroGrid';

            // Se esta desabilitado o campo 
            if ($("#cddgrupo", '#' + nomeFormulario).prop("disabled") == true) {
                return;
            }

            // Variável local para guardar o elemento anterior
            var campoAnterior = '';
            var bo, procedure, titulo, qtReg, filtros, colunas, cddgrupo, titulo_coluna, cdgrupos, dsdgrupo;

            var divRotina = 'divTela';

            //Remove a classe de Erro do form
            $('input,select', '#' + nomeFormulario).removeClass('campoErro');

            var cddgrupo = $('#cddgrupo', '#' + nomeFormulario).val();
            cdgrupos = cddgrupo;
            dsdgrupo = '';

            titulo_coluna = "Grupos de produto";

            bo = 'b1wgen0153.p';
            procedure = 'lista-grupos';
            titulo = 'Grupos';
            qtReg = '20';
            filtros = 'Codigo;cddgrupo;100px;S;' + cddgrupo + ';S|Descricao;dsdgrupo;300px;S;' + dsdgrupo + ';S';
            colunas = 'Codigo;cddgrupo;20%;right|' + titulo_coluna + ';dsdgrupo;50%;left';
            mostraPesquisa(bo, procedure, titulo, qtReg, filtros, colunas, '', '$(\'#cddgrupo\',\'#frmFiltroGrid\').val();filtro.mostraCampos()');
            $("#divPesquisa").css("top", "91px");
            $("#divPesquisa").css("width", "500px");
            $("#divCabecalhoPesquisa > table").css("width", "470px");
            $("#divCabecalhoPesquisa > table").css("float", "left");
            $("#divResultadoPesquisa > table").css("width", "500px");
            $("#divCabecalhoPesquisa").css("width", "500px");
            $("#divResultadoPesquisa").css("width", "500px");
            $("#divPesquisa").centralizaRotinaH();
        } else if (tipo == 'T') {
            // Nome do Formulário que estamos trabalhando
            var nomeFormulario = 'frmFiltroGrid';

            // Se esta desabilitado o campo 
            if ($("#cdtarifa", '#' + nomeFormulario).prop("disabled") == true) {
                return;
            }

            // Variável local para guardar o elemento anterior
            var campoAnterior = '';
            var bo, procedure, titulo, qtReg, filtros, colunas, cdtarifa, titulo_coluna, cdtarifas, dstarifa, cddgrupo;
            var dsdgrupo, cdsubgru, dssubgru, cdcatego, dscatego, cdinctar, inpessoa, flglaman;

            var divRotina = 'divTela';

            //Remove a classe de Erro do form
            $('input,select', '#' + nomeFormulario).removeClass('campoErro');

            var cdtarifa = $('#cdtarifa', '#' + nomeFormulario).val();
            cdtarifas = cdtarifa;
            dstarifa = '';
            cddgrupo = $("#cddgrupo", "#" + nomeFormulario).val();
            dsdgrupo = '';
            dssubgru = '';
            dscatego = '';
            cdsubgru = $("#cdsubgru", "#" + nomeFormulario).val();
            cdcatego = $("#cdcatego", "#" + nomeFormulario).val();

            titulo_coluna = "Tarifas";

            bo = 'b1wgen0153.p';
            procedure = 'lista-tarifas';
            titulo = 'Tarifas';
            qtReg = '20';
            filtros = 'Grupo;cddgrupo;100px;N;' + cddgrupo + ';N|Desc;dsdgrupo;150px;N;' + dsdgrupo + ';N|'; //GRUPO
            filtros = filtros + 'Subgrupo;cdsubgru;100px;N;' + cdsubgru + ';N|Desc;dssubgru;150px;N;' + dssubgru + ';N|'; //SUBGRUPO
            filtros = filtros + 'Categoria;cdcatego;100px;N;' + cdcatego + ';N|Desc;dscatego;150px;N;' + dssubgru + ';N|'; //CATEGORIA
            filtros = filtros + 'Codigo;cdtarifa;100px;S;' + cdtarifa + ';S|Descricao;dstarifa;300px;S;' + dstarifa + ';S'; //TARIFA
            colunas = 'Cod;cddgrupo;4%;right|Grupo;dsdgrupo;21%;left|' //GRUPO
            colunas = colunas + 'Cod;cdsubgru;4%;right|SubGrupo;dssubgru;21%;left|' //SUBGRUPO
            colunas = colunas + 'Cod;cdcatego;4%;right|Categoria;dscatego;21%;left|' //CATEGORIA
            colunas = colunas + 'Cod;cdtarifa;4%;right|' + titulo_coluna + ';dstarifa;21%;left'; //TARIFA
            mostraPesquisa(bo, procedure, titulo, qtReg, filtros, colunas, '', '$(\'#cdtarifa\',\'#frmFiltroGrid\').val()');
            $("#divPesquisa").css("top", "91px");
            $("#divPesquisa").css("width", "890px");
            $("#divCabecalhoPesquisa > table").css("width", "875px");
            $("#divCabecalhoPesquisa > table").css("float", "left");
            $("#divResultadoPesquisa > table").css("width", "890px");
            $("#divCabecalhoPesquisa").css("width", "890px");
            $("#divResultadoPesquisa").css("width", "890px");
            $("#divPesquisa").centralizaRotinaH();
        }

        return false;
    }

    this.exibir = function () {
        filtro.getFormulario().show();
        habilitarFiltro();
        filtro.escondeCampos();
        exibirBotoes();
        // foca no primeiro campo
        filtro.getFormulario().find('#cddgrupo').focus();

        filtro.getFormulario().find('#cdlcremp,#nrconven').numeric({
            allow: ','
        });
    }

    this.mostraCampos = function () {
        var cddgrupo = filtro.getFormulario().find('#cddgrupo').val();

        if (cddgrupo == 3) {
            $('#linha-convenio').show();
            $('#linha-credito').hide();
        } else if (cddgrupo == 5) {
            $('#linha-convenio').hide();
            $('#linha-credito').show();
        }
    }

    this.escondeCampos = function () {
        $('#linha-credito').hide();
        $('#linha-convenio').hide();
    }

    this.onClick_Prosseguir = function () {
        if (!filtro.getFormulario().find('#cddgrupo').val().trim()) {
            showError("error", "O campo Grupo &eacute; obrigat&oacute;rio.", "Alerta - Ayllos", "$('#cddgrupo','#frmFiltroGrid').focus()");
            return false;
        }
        ocultarBotoes();
        desabilitarFiltro();
        grid.carregar();
    }

}
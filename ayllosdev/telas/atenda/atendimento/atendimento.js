/*************************************************************************
 Fonte: atendimento.js                                            
 Autor: Gabriel - Rkam                                            
 Data : Agosto/2015                   Última Alteração: 
                                                                  
 Objetivo  : Biblioteca de funções da rotina de Atendimento da tela  
             ATENDA  
			 
        	[25/07/2016] Evandro     (RKAM)  : Adicionado função controlaFoco.                                                                 

************************************************************************/

//Variáveis globais para controle das operações de alteração, exclusão
var dtatendimento = '';
var hratendimento = '';
var cdservico = '';
var nmservico = '';
var dsservico_solicitado = '';

// Função para acessar opções da rotina
function acessaOpcaoAba(nrOpcoes, id, opcao) {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando informações ...");

    // Atribui cor de destaque para aba da opção
    $("#linkAba0").attr("class", "txtBrancoBold");
    $("#imgAbaEsq0").attr("src", UrlImagens + "background/mnu_sle.gif");
    $("#imgAbaDir0").attr("src", UrlImagens + "background/mnu_sld.gif");
    $("#imgAbaCen0").css("background-color", "#969FA9");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/atendimento/principal.php",
        data: {
            nrdconta: nrdconta,
            nriniseq: 1,
            nrregist: 30,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divConteudoOpcao").html(response);
            controlaFoco(opcao);
        }
    });
}

// Função para apresentar o formulario de cadastro
function mostraFormServicos(cddopcao) {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando informações ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/atendimento/form_servicos.php",
        data: {
            cddopcao: cddopcao,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divInformacoes").html(response);
        }
    });
}


function controlaFoco(opcao) {
    $("#btVoltar").addClass("FirstInputModal").focus();
    $("#btExcluir").addClass("LastInputModal");

    //Se estiver com foco na classe LastInputModal
    $(".LastInputModal").focus(function () {
        var pressedShift = false;

        $(this).bind('keyup', function (e) {
            if (e.keyCode == 16) {
                pressedShift = false;//Quando tecla shift for solta passa valor false 
            }
        })

        $(this).bind('keydown', function (e) {
            e.stopPropagation();
            e.preventDefault();

            if (e.keyCode == 13) {
                $(".LastInputModal").click();
            }
            if (e.keyCode == 16) {
                pressedShift = true;//Quando tecla shift for pressionada passa valor true 
            }
            if ((e.keyCode == 9) && pressedShift == true) {
                return setFocusCampo($(target), e, false, 0);
            }
            else if (e.keyCode == 9) {
                $(".FirstInputModal").focus();
            }
        });
    });

    $(".FirstInputModal").focus();
}



// Função para buscar registros de serviços
function buscaRegistro(nriniseq, nrregist) {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando informações ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/atendimento/principal.php",
        data: {
            nrdconta: nrdconta,
            nriniseq: nriniseq,
            nrregist: nrregist,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divConteudoOpcao").html(response);
        }
    });
}

// Função para realizar a exclusão/alteração/exclusão de um serviço
function manterRotina(cddopcao) {

    dtatendimento = $('#dtatendimento', '#frmServicos').val();
    hratendimento = $('#hratendimento', '#frmServicos').val();
    cdservico = $('#cdservico', '#frmServicos').val();
    dsservico_solicitado = $('#dsservico_solicitado', '#frmServicos').val();

    //Remove a classe de Erro do form
    $('input,select,textarea', '#divConteudoOpcao').removeClass('campoErro');

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, realizando operação...");

    // Carrega dados da conta através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/atendimento/manter_rotina.php",
        data: {
            cddopcao: cddopcao,
            nrdconta: nrdconta,
            dtatendimento: dtatendimento,
            hratendimento: hratendimento,
            cdservico: cdservico,
            dsservico_solicitado: dsservico_solicitado,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')));$('#btVoltar','#divBotoesServicos').focus()");
        },
        success: function (response) {
            try {

                eval(response);
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')));$('#btVoltar','#divBotoesServicos').focus()");
            }
        }
    });

    return false;

}

function controlaLayout(ope) {

    switch (ope) {

        case "C":

            formataFormularios();

            $('#divTabelaServicos', '#divServicos').css('display', 'none');
            $('#divBotoes', '#divServicos').css('display', 'none');

            $('#divInformacoes', '#divServicos').css('display', 'block');
            $('#frmServicos', '#divInformacoes').css('display', 'block');
            $('#divBotoesServicos', '#divInformacoes').css('display', 'block');
            $('#btConcluir', '#divInformacoes').css('display', 'none');

            $('#dtatendimento', '#frmServicos').val(dtatendimento).desabilitaCampo();
            $('#hratendimento', '#frmServicos').val(hratendimento).desabilitaCampo();
            $('#cdservico', '#frmServicos').val(cdservico).desabilitaCampo();
            $('#nmservico', '#frmServicos').val(nmservico).desabilitaCampo();
            $('#dsservico_solicitado', '#frmServicos').val(dsservico_solicitado).desabilitaCampo();

            break;

        case "A": //Alterar

            formataFormularios();

            $('#divTabelaServicos', '#divServicos').css('display', 'none');
            $('#divBotoes', '#divServicos').css('display', 'none');

            $('#divInformacoes', '#divServicos').css('display', 'block');
            $('#frmServicos', '#divInformacoes').css('display', 'block');
            $('#divBotoesServicos', '#divInformacoes').css('display', 'block');

            $('#dtatendimento', '#frmServicos').val(dtatendimento).desabilitaCampo();
            $('#hratendimento', '#frmServicos').val(hratendimento).desabilitaCampo();
            $('#cdservico', '#frmServicos').val(cdservico).habilitaCampo().focus();
            $('#nmservico', '#frmServicos').val(nmservico).desabilitaCampo();
            $('#dsservico_solicitado', '#frmServicos').val(dsservico_solicitado).habilitaCampo();

            $('#btConcluir', '#divBotoesServicos').unbind('click').bind('click', function () {

                showConfirmacao('Deseja efetuar a altera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Aimaro', 'manterRotina(\'A\')', '$("#btVoltar","#divBotoesServicos").focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));', 'sim.gif', 'nao.gif');

                return false;

            });


            break;

        case "I": //Incluir

            formataFormularios();

            $('#divTabelaServicos', '#divServicos').css('display', 'none');
            $('#divBotoes', '#divServicos').css('display', 'none');
            $('#divInformacoes', '#divServicos').css('display', 'block');
            $('#frmServicos', '#divInformacoes').css('display', 'block');
            $('#divBotoesServicos', '#divInformacoes').css('display', 'block');

            $('input,textarea', '#frmServicos').habilitaCampo();

            $('#btConcluir', '#divBotoesServicos').unbind('click').bind('click', function () {

                showConfirmacao('Deseja efetuar a inclus&atilde;o?', 'Confirma&ccedil;&atilde;o - Aimaro', 'manterRotina(\'I\')', '$("#btVoltar","#divBotoesServicos").focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));', 'sim.gif', 'nao.gif');

                return false;

            });

            $('#dtatendimento', '#frmServicos').focus();
            $('#nmservico', '#frmServicos').desabilitaCampo();


            break;

        case "E": //Excluir

            formataFormularios();

            $('#divTabelaServicos', '#divServicos').css('display', 'none');
            $('#divBotoes', '#divServicos').css('display', 'none');

            $('#divInformacoes', '#divServicos').css('display', 'block');
            $('#frmServicos', '#divInformacoes').css('display', 'block');
            $('#divBotoesServicos', '#divInformacoes').css('display', 'block');

            $('#dtatendimento', '#frmServicos').val(dtatendimento);
            $('#hratendimento', '#frmServicos').val(hratendimento);
            $('#cdservico', '#frmServicos').val(cdservico);
            $('#nmservico', '#frmServicos').val(nmservico);
            $('#dsservico_solicitado', '#frmServicos').val(dsservico_solicitado);

            $('input,textarea', '#frmServicos').desabilitaCampo();

            $('#btConcluir', '#divBotoesServicos').unbind('click').bind('click', function () {

                showConfirmacao('Deseja efetuar a exclus&atilde;o?', 'Confirma&ccedil;&atilde;o - Aimaro', 'manterRotina(\'E\')', '$("#btVoltar","#divBotoesServicos").focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));', 'sim.gif', 'nao.gif');

                return false;

            });


            break;

        case "T": //Formata tabela

            var divRegistro = $('div.divRegistros');
            var tabela = $('table', divRegistro);
            var linha = $('table > tbody > tr', divRegistro);
            var tpdpagto = $("#tpdpagto", "#frmFiltroPesqti").val();

            divRegistro.css({ 'height': '150px' });

            var ordemInicial = new Array();
            ordemInicial = [[0, 1]];

            var arrayLargura = new Array();
            arrayLargura[0] = '140px';
            arrayLargura[1] = '230px';

            var arrayAlinha = new Array();
            arrayAlinha[0] = 'center';
            arrayAlinha[1] = 'left';
            arrayAlinha[2] = 'left';

            var metodoTabela = '';

            tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

            $('table > tbody > tr', divRegistro).focus(function () {
                selecionaServico($(this));

            });

            // seleciona o registro que é clicado
            $('table > tbody > tr', divRegistro).click(function () {
                selecionaServico($(this));

            });

            //Deixa o primeiro registro ja selecionado
            $('table > tbody > tr', divRegistro).each(function (i) {

                if ($(this).hasClass('corSelecao')) {

                    selecionaServico($(this));

                }

            });

            break;

        case "V": //Voltar

            $('#divTabelaServicos', '#divServicos').css('display', 'block');
            $('#divBotoes', '#divServicos').css('display', 'block');

            $('#divInformacoes', '#divServicos').css('display', 'none');
            $('#frmServicos', '#divInformacoes').css('display', 'none');
            $('#divBotoesServicos', '#divInformacoes').css('display', 'none');

            break;

        default:
            return false;
            break;

    }

    $('#btVoltar', '#divBotoesServicos').unbind('click').bind('click', function () {

        if (ope != 'C') {
            showConfirmacao('Deseja cancelar a opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Aimaro', 'controlaLayout(\"V\");blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));', '$(\'#btVoltar\',\'#divBotoesServicos\').focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));', 'sim.gif', 'nao.gif');
            return false;
        }

        controlaLayout("V");
        return false;

    });

    return false;

}

// Função para seleção do serviço
function selecionaServico(tr) {

    dtatendimento = $('#dtatendimento', tr).val();
    hratendimento = $('#hratendimento', tr).val();
    cdservico = $('#cdservico', tr).val();
    nmservico = $('#nmservico', tr).val();
    dsservico_solicitado = $('#dsservico_solicitado', tr).val();

}

function formataFormularios() {

    //Limpa formularios
    $('#frmServicos').limpaFormulario();

    //form titulos - label
    rDtatendimento = $('label[for="dtatendimento"]', '#frmServicos');
    rHratendimento = $('label[for="hratendimento"]', '#frmServicos');
    rCdservico = $('label[for="cdservico"]', '#frmServicos');
    rNmservico = $('label[for="nmservico"]', '#frmServicos');
    rDsservico_solicitado = $('label[for="dsservico_solicitado"]', '#frmServicos');

    rDtatendimento.addClass('rotulo').css({ 'width': '100px' });
    rHratendimento.addClass('rotulo-linha').css({ 'width': '45px' });
    rCdservico.addClass('rotulo-linha').css({ 'width': '60px' });
    rNmservico.addClass('rotulo-linha').css({ 'width': '0px' });
    rDsservico_solicitado.addClass('rotulo').css({ 'width': '100px' });

    //form titulos - campos
    cDtatendimento = $('#dtatendimento', '#frmServicos');
    cHratendimento = $('#hratendimento', '#frmServicos');
    cCdservico = $('#cdservico', '#frmServicos');
    cNmservico = $('#nmservico', '#frmServicos');
    cDsservico_solicitado = $('#dsservico_solicitado', '#frmServicos');

    cDtatendimento.addClass('data').css({ 'width': '75px' });
    cHratendimento.addClass('inteiro').setMask('STRING', '99:99', ':', '');
    cHratendimento.css({ 'width': '60px', 'text-align': 'right' });
    cCdservico.addClass('inteiro').css({ 'width': '50px', 'text-align': 'right' }).attr('maxlength', '5');
    cNmservico.css({ 'width': '250px' }).attr('maxlength', '50').desabilitaCampo();
    cDsservico_solicitado.css({ 'width': '580px', 'height': '150px', 'float': 'left', 'margin': '3px 0px 3px 3px', 'padding-right': '1px' }).attr('maxlength', '500').habilitaCampo().setMask('STRING', '500', charPermitido());

    highlightObjFocus($('#frmServicos'));
    controlaFocoEnter("frmServicos");


    //Ao pressionar o campo Hora
    cHratendimento.unbind('keydown').bind('keydown', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select,textarea').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {
            cCdservico.focus();
            return false;
        }

    });

    //Ao pressionar o campo cdservico
    cCdservico.unbind('keydown').bind('keydown', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select,textarea').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {
            buscaDescricaoServico($(this).val());
            cDsservico_solicitado.focus();
            return false;
        }

    });

    cDsservico_solicitado.unbind('keydown').bind('keydown', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select,textarea').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {
            $("#btConcluir", "#divBotoesServicos").click();
            return false;
        }

    });

    controlaPesquisas();

    layoutPadrao();

    return false;

}

function buscaDescricaoServico(valor) {

    var bo = 'atendimento';
    var procedure = 'LISTASERVICOS';
    var titulo = 'Servi&ccedil;os';
    var nomeFormulario = 'frmServicos';
    buscaDescricao(bo, procedure, titulo, 'cdservico', 'nmservico', valor, 'nmservico', '', nomeFormulario);

    return false;
}

function controlaPesquisas() {

    // Variável local para guardar o elemento anterior
    var campoAnterior = '';
    var bo, procedure, titulo, qtReg, filtros, colunas, cdhiscxa;
    var nomeFormulario = 'frmServicos';

    //Remove a classe de Erro do form
    $('input,select,textarea', '#' + nomeFormulario).removeClass('campoErro');

    // Atribui a classe lupa para os links de desabilita todos
    $('a', '#' + nomeFormulario).addClass('lupa').css('cursor', 'auto');

    // Percorrendo todos os links
    $('a', '#' + nomeFormulario).each(function (i) {

        if (!$(this).prev().hasClass('campoTelaSemBorda')) $(this).css('cursor', 'pointer');

        $(this).unbind('click').bind('click', function () {
            if ($(this).prev().hasClass('campoTelaSemBorda')) {
                return false;
            } else {
                campoAnterior = $(this).prev().attr('name');

                if (campoAnterior == 'cdservico') {
                    bo = 'atendimento';
                    procedure = 'LISTASERVICOS';
                    titulo = 'Servi&ccedil;os';
                    qtReg = '50';
                    filtros = 'C&oacutedigo;cdservico;30px;S;0;S|Descr.;nmservico;200px;S';
                    colunas = 'Cod.;cdservico;20%;right|Descr.;nmservico;67%;left';
                    mostraPesquisa(bo, procedure, titulo, qtReg, filtros, colunas, divRotina, '$(\'#cdservico\',\'#frmServicos\').focus();', nomeFormulario);
                    return false;
                }
            }
        });
    });

    return false;

}




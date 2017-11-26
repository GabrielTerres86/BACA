/*************************************************************************
 Fonte: produtos.js                                            
 Autor: Gabriel - Rkam                                            
 Data : Setembro/2015                   Última Alteração: 
                                                                  
 Objetivo  : Biblioteca de funções da rotina de Produtos da tela  
             ATENDA     
			
			01/10/2015 - Projeto 217 Reformulacao Cadastral
			(Tiago Castro - RKAM).

			11/08/2016 - Adicionado função controlaFoco.
			(Evandro - RKAM).
                                                                  
			26/10/2016 - Chamado 536620 - Modificado as chamadas da funcao acessaRotina que passam pela tela Atenda.
            (Gil Furtado - Mouts)


************************************************************************/

//Variáveis globais para controle das operações de alteração, exclusão
var dtatendimento = '';
var hratendimento = '';
var cdservico = '';
var nmservico = '';
var dsservico_solicitado = '';
var kitBoasVindas = 0;

executandoProdutos = true;

// Função para acessar opções da rotina
function acessaOpcaoAba(nrOpcoes, id, opcao, opeProdutos) {

    //Inicializa variaveis
    posicao = 0;
    produtosTelasServicos = new Array();
    produtosTelasServicosAdicionais = new Array();

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
        url: UrlSite + "includes/produtos/principal.php",
        data: {
            nrdconta: nrdconta,
            nmrotina: nmrotina,
            opeProdutos: opeProdutos,
            atualizarServicos: atualizarServicos,
            flgcadas: flgcadas,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#divConteudoOpcao").html(response);
            controlaFoco();
}
    });

}

//Função para controle de navegação
function controlaFoco() {
    $('#divConteudoOpcao #divServicos').each(function () {
        $(this).find("#frmServicos fieldset #tabelaServicos td> :input[type=checkbox]").addClass("FluxoNavega");
        $(this).find("#frmServicos fieldset #tabelaServicos td> :input[type=checkbox]").first().addClass("FirstInputModal").focus();
        $(this).find("#divBotoes #divBotoesServicos > a").addClass("FluxoNavega");

        $(this).find("#frmServicosAdicionais fieldset #tabelaServicosAdicionais td> :input[type=checkbox]").addClass("FluxoNavega");

        $(this).find("#divBotoes #divBotoesServicosAdicionais > a").addClass("FluxoNavega");
        $(this).find("#divBotoes #divBotoesServicosAdicionais > a").last().addClass("LastInputModal");

        //Se estiver com foco na classe FluxoNavega
        $(".FluxoNavega").focus(function () {
            $(this).bind('keydown', function (e) {
                if (e.keyCode == 13) {
                    $(this).click();
                }
            });
        });

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

    });
    $(".FirstInputModal").focus();
}

function controlaLayout(ope) {

    $('#divConteudoOpcao').css({ 'height': 'auto' });
    $('#divServicos').css({ 'display': 'block', 'height': '100%' });

    $('#frmServicos').css({ 'display': 'block', 'float': 'left', 'width': '40%' });
    $('#frmServicosAdicionais').css({ 'display': 'block', 'float': 'left', 'width': '60%' });

    $('#divBotoes', '#divServicos').css({ 'display': 'block', 'margin-top': '5px', 'margin-bottom': '10px', 'text-align': 'center', 'width': '100%' });
    $('#divBotoesServicos', '#divServicos').css({ 'display': 'none', 'float': 'left', 'width': '40%' });
    $('#divBotoesServicosAdicionais', '#divServicos').css({ 'display': 'none', 'float': 'right', 'width': '60%' });
    $('fieldset', '#divServicos').css({ 'padding': '0px', 'height': '100%', 'width': '95%' });


    // Percorrendo todos os checkbox do frmServicos
    $('input[type="checkbox"]', '#frmServicos').each(function (i) {

        if (flgcadas == 'M') {
            $(this).css({ 'margin-left': '15px' }).prop('checked', true).desabilitaCampo();
        } else {
            $(this).css({ 'margin-left': '15px' }).habilitaCampo().prop('checked', false);
        }

    });

    $('label', '#frmServicos').css('height', '20px');

    // Percorrendo todos os label do frmServicos
    $('label', '#frmServicos').each(function (i) {

        //Se não for o label "Habilitar"
        if (i > 0) {

            $(this).css({ 'width': '200px', 'text-align': 'left' });
        }

    });

    // Percorrendo todos os checkbox do frmServicosAdicionais
    $('input[type="checkbox"]', '#frmServicosAdicionais').each(function (i) {

        $(this).css({ 'margin-left': '15px', 'display': 'none' }).prop('checked', false);

    });

    // Percorrendo todos os checkbox do frmServicosAdicionais
    $('input[type="text"]', '#frmServicosAdicionais').each(function (i) {

        $(this).addClass('data').css({ 'width': '75px', 'display': 'none' }).val('');

    });

    $('label', '#frmServicosAdicionais').css('height', '20px');

    // Percorrendo todos os label do frmServicosAdicionais
    $('label', '#frmServicosAdicionais').each(function (i) {

        if (i < 4) {

        } else {

            $(this).css({ 'width': '200px', 'text-align': 'left' });
        }

    });

    //Ao clicar no botao Continuar Servicos essenciais
    $('#btSalvar', '#divBotoesServicos').unbind('click').bind('click', function () {

        alimtentaTelas(1);

        if (produtosTelasServicos.length == 0) {

            showError("error", "Nenhum servi&ccedil;o foi selecionado.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')));$('#btSalvar','#divBotoesServicos').focus()");
            return false;

        } else {
            $("#divRotina").css({ 'margin-left': '', 'margin-top': '', "visibility": "hidden" });// Restaurar valores
            executandoProdutosServicos = true;
            controlaAtualizacaoServicos(1);
            eval(produtosTelasServicos[0]);
            posicao = posicao + 1;

        }

    });

    //Ao clicar no botao Continuar Servicos adicionais
    $('#btSalvar', '#divBotoesServicosAdicionais').unbind('click').bind('click', function () {

        alimtentaTelas(2);

        executandoProdutosServicosAdicionais = true;

        if (!controlaAtualizacaoServicos(2) && flgcadas == 'M') {

            showError("error", "4 produtos devem ser ofertados ao cooperado!", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')));$('#btSalvar','#divBotoesServicos').focus()");
            return false;

        }

        $("#divRotina").css({ 'margin-left': '', 'margin-top': '', "visibility": "hidden" });// Restaurar valores
        eval(produtosTelasServicosAdicionais[0]);
        posicao = posicao + 1;

    });


    if (ope == '1' || flgcadas != 'M') {

        $('#divBotoesServicos', '#divServicos').css('display', 'block');

        if (flgcadas == 'M') {
            // Percorrendo todos os checkbox do frmServicosAdicionais
            $('input[type="checkbox"]', '#frmServicosAdicionais').each(function (i) {
                $(this).css('display', 'none');
            });
        }

    }

    if (ope == '2' || flgcadas != 'M') {

        $('#divBotoesServicosAdicionais', '#divServicos').css({ 'display': 'block' });

        if (flgcadas == 'M') {
            // Percorrendo todos os checkbox do frmServicos
            $('input[type="checkbox"]', '#frmServicos').each(function (i) {
                $(this).css('display', 'none');
            });
        }

        // Percorrendo todos os checkbox do frmServicosAdicionais
        $('input[type="checkbox"]', '#frmServicosAdicionais').each(function (i) {
            if ($(this).attr('id').indexOf('ofertar') >= 0) {

                var elemento;

                if (flgcadas == 'M') { // Se for 1.ero acesso
                    elemento = $(this);

                    //Ao clicar em ofertar ou habilitar dependendo primeiro acesso
                    $(this).unbind('click').bind('click', function () {

                        if ($(this).prop('checked')) {

                            // Percorrendo todos os elementos do frmServicosAdicionais
                            $('input[name="' + $(this).attr('name') + '"]', '#frmServicosAdicionais').each(function (i) {
                                if ($(this).attr('id').indexOf('ofertar') == -1) {

                                    if ($(this).attr('id') == "outras") {
                                        if ($("#checkadesaoexterna", "#" + $(this).attr('name')).val() == "N") {
                                            $(this).css({ 'display': 'none' });
                                        } else {
                                            $(this).css({ 'display': 'block' }).prop('checked', $("#inadesaoexterna", "#" + $(this).attr('name')).val() == 'S');
                                        }
                                    } else if ($(this).attr('id') == "vencimento") {
                                        if ($("#checkvencto", "#" + $(this).attr('name')).val() == "N") {
                                            $(this).css({ 'display': 'none' });
                                        } else {
                                            $(this).css({ 'display': 'block' }).val($("#dtvencto", "#" + $(this).attr('name')).val());
                                        }
                                    }
                                    else {
                                        if ($(this).attr('type') == 'checkbox') {
                                            $(this).css({ 'display': 'block' }).prop('checked', false);
                                        }
                                        else {
                                            $(this).css({ 'display': 'block' });
                                        }
                                    }
                                }
                            });

                        } else {
                            // Percorrendo todos os checkbox do frmServicosAdicionais
                            $('input[name="' + $(this).attr('name') + '"]', '#frmServicosAdicionais').each(function (i) {
                                if ($(this).attr('id').indexOf('ofertar') == -1) {
                                    if ($(this).attr('type') == 'checkbox') {
                                        $(this).css({ 'display': 'none' }).prop('checked', false);
                                    }
                                    else {
                                        $(this).css({ 'display': 'none' });
                                    }
                                }
                            });
                        }

                    });

                } else {
                    $(this).remove();
                    elemento = $("#habilitar", "#" + $(this).attr('name'));

                    // Percorrendo todos os elementos do frmServicosAdicionais
                    $('input[name="' + $(this).attr('name') + '"]', '#frmServicosAdicionais').each(function (i) {

                        if ($(this).attr('id') == "outras") {

                            if ($("#checkadesaoexterna", "#" + $(this).attr('name')).val() == "N") {
                                $(this).css({ 'display': 'none' });
                            } else {
                                $(this).css({ 'display': 'block' }).prop('checked', $("#inadesaoexterna", "#" + $(this).attr('name')).val() == 'S');
                            }
                        } else if ($(this).attr('id') == "vencimento") {
                            if ($("#checkvencto", "#" + $(this).attr('name')).val() == "N") {
                                $(this).css({ 'display': 'none' });
                            } else {
                                $(this).css({ 'display': 'block' }).val($("#dtvencto", "#" + $(this).attr('name')).val());
                            }
                        } else {
                            if ($(this).attr('type') == 'checkbox') {
                                $(this).css({ 'display': 'block' }).prop('checked', false);
                            }
                            else {
                                $(this).css({ 'display': 'block' });
                            }
                        }
                    });
                }

                elemento.css({ 'display': 'block' });

            }

        });

    }

    if (ope == '3') { // Fim cadastro de produtos essenciais e opcionais

        // Fim cadastro que vem da MATRIC -> CONTAS
        flgcadas = false;

    }

    layoutPadrao();
    return false;

}

function atualizarAdesao(produto, aderido) {

    for (var i = 0; i < atualizarServicos.length; i++) {

        if (atualizarServicos[i].cdproduto == produto) {

            (aderido) ? atualizarServicos[i].inaderido = 'S' : atualizarServicos[i].inaderido = 'N';

        }
    }

    return false;
}

function controlaAtualizacaoServicos(ope) {

    var qtdServicosHabilitados = 0;

    if (ope == 1) {

        atualizarServicos = [];

        $('#tabelaServicos tr:gt(0)').each(function (i) {

            atualizarServicos.push(
			  {
			      cdproduto: $(this).attr('id'),
			      inofertado: 'S',
			      inaderido: '',
			      inadesao_externa: 'N',
			      dtvencimento: ''
			  });

        });

        return false;

    } else {

        atualizarServicos = [];

        $('#tabelaServicosAdicionais tr:gt(0)').each(function (i) {

            if ($('#ofertar', $(this)).prop('checked')) {
                qtdServicosHabilitados++;
            }

            atualizarServicos.push(
			  {
			      cdproduto: $(this).attr('id'),
			      inofertado: ($('#ofertar', $(this)).prop('checked')) ? 'S' : 'N',
			      inaderido: '', //( $('#habilitar', $(this) ).prop('checked') ) ? 'S' : 'N',
			      inadesao_externa: ($('#outras', $(this)).prop('checked')) ? 'S' : 'N',
			      dtvencimento: ($('#vencimento', $(this)).val() != '') ? $('#vencimento', $(this)).val() : ''
			  });


        });

        return (qtdServicosHabilitados > 3); // Pelo menos 4 servicos ofertados

    }

}

function alimtentaTelas(operacao) {

    if (operacao == 1) {

        produtosTelasServicos = new Array();
        var index = 0;

        if (kitBoasVindas == '1') {

            produtosTelasServicos[index] = 'acessaRotina(\'\',\'RELACIONAMENTO\',\'Relacionamento\',\'relacionamento\');';
            index++;
        }

        $('#tabelaServicos tr:gt(0)').each(function (i) {

            if ($('#habilitar', $(this)).prop('checked')) {

                switch ($(this).attr('id')) {

                    //ACESSO A INTERNET
                    case "1":

                        produtosTelasServicos[index] = 'acessaRotina(\'\',\'INTERNET\',\'Internet\',\'internet\');';
                        index++;

                        break;

                        //ACESSO AO TELE SALDO
                    case "2":

                        produtosTelasServicos[index] = 'acessaRotina(\'\',\'TELE ATEN\',\'Tele Atendimento\',\'tele_atendimento\');';
                        index++;

                        break;

                        //APLICACAO
                    case "3":

                        produtosTelasServicos[index] = 'acessaRotina(\'\',\'APLICACOES\',\'Aplica&ccedil;&otilde;es\',\'aplicacoes\');';
                        index++;

                        break;

                        //CARTAO DE CREDITO
                    case "4":

                        produtosTelasServicos[index] = 'acessaRotina(\'\',\'CARTAO CRED\',\'Cart&otilde;es de Cr&eacute;dito\',\'cartao_credito\');'
                        index++;

                        break;

                        //CARTAO MAGNETICO
                    case "5":

                        produtosTelasServicos[index] = 'acessaRotina(\'\',\'MAGNETICO\',\'Cart&otilde;es Magn&eacute;ticos\',\'magneticos\');';
                        index++;

                        break;

                        //COBRANCA BANCARIA
                    case "6":

                        produtosTelasServicos[index] = 'acessaRotina(\'\',\'COBRANCA\',\'Cobran&ccedil;a\',\'cobranca\');';
                        index++;

                        break;

                        //CONSORCIO 
                    case "7":

                        produtosTelasServicos[index] = "showError('error','Para cadastramento de CONS&Oacute;RCIO, utilize o link CECRED CONSORCIOS no portal.','Alerta - Ayllos','showConfirmacao(\"Produto aderido pelo cooperado?\",\"Confirma&ccedil;&atilde;o - Ayllos\",\"atualizarAdesao(7,true);encerraRotina(false);\",\"atualizarAdesao(7,false);encerraRotina(false);\",\"sim.gif\",\"nao.gif\");','','sim.gif','nao.gif');";
                        index++;

                        break;

                        //CONVENIO FOLHA DE PAGAMENTO -> Abrir a tela CADEMP
                    case "8":

                        produtosTelasServicos[index] = "setaParametros('CADEMP','','" + nrdconta + "','" + flgcadas + "'); setaATENDA(); direcionaTela('CADEMP','no'); ";
                        index++;

                        break;

                        //DDA
                    case "9":

                        produtosTelasServicos[index] = 'acessaRotina(\'\',\'DDA\',\'DDA\',\'dda\');';
                        index++;

                        break;

                        //DEBITO AUTOMATICO -> Abrir a tela AUTORI 
                    case "10":

                        produtosTelasServicos[index] = "setaParametros('AUTORI','','" + nrdconta + "','" + flgcadas + "'); setaATENDA(); direcionaTela('AUTORI','no'); ";
                        index++;

                        break;

                        //DOMICILIO BANCARIO 
                    case "11":

                        produtosTelasServicos[index] = "showError('error','Para cadastramento de DOMICILIO BANCARIO, utilize o sistema SISBR ou preencha a proposta.','Alerta - Ayllos','showConfirmacao(\"Produto aderido pelo cooperado?\",\"Confirma&ccedil;&atilde;o - Ayllos\",\"atualizarAdesao(11,true);encerraRotina(false);\",\"atualizarAdesao(11,false);encerraRotina(false);\",\"sim.gif\",\"nao.gif\");','','sim.gif','nao.gif');";
                        index++;

                        break;

                        //INTEGRALIZACAO DO CAPITAL
                    case "12":

                        produtosTelasServicos[index] = 'acessaRotina(\'\',\'CAPITAL\',\'Capital\',\'capital\');';
                        index++;

                        break;

                        //LIMITE DE CREDITO
                    case "13":

                        if (inpessoa == 1) {
                            produtosTelasServicos[index] = 'acessaRotina(\'\',\'LIMITE CRED\',\'Limite de Cr&eacute;dito\',\'limite_credito\');';
                        } else {
                            produtosTelasServicos[index] = 'acessaRotina(\'\',\'LIMITE CRED\',\'Limite Empresarial\',\'limite_credito\');';
                        }
                        index++;

                        break;

                        //LIMITE INTERNET
                    case "14":

                        produtosTelasServicos[index] = 'acessaRotina(\'\',\'INTERNET\',\'Internet\',\'internet\');';
                        index++;

                        break;

                        //PLANO COTAS
                    case "15":

                        produtosTelasServicos[index] = 'acessaRotina(\'\',\'CAPITAL\',\'Capital\',\'capital\');';
                        index++;

                        break;

                        //POUPANCA PROGRAMADA
                    case "16":

                        produtosTelasServicos[index] = 'acessaRotina(\'\',\'POUP. PROG\',\'oupan&ccedil;a Programada\',\'poupanca_programada\');';
                        index++;

                        break;

                        //SEGURO AUTO
                    case "17":

                        produtosTelasServicos[index] = "showError('error','Para cadastramento do SEGURO AUTO, utilize o link CECRED SEGUROS na intranet.','Alerta - Ayllos','showConfirmacao(\"Produto aderido pelo cooperado?\",\"Confirma&ccedil;&atilde;o - Ayllos\",\"atualizarAdesao(17,true);encerraRotina(false);\",\"atualizarAdesao(17,false);encerraRotina(false);\",\"sim.gif\",\"nao.gif\");','','sim.gif','nao.gif');";
                        index++;

                        break;

                        //SEGURO VIDA
                    case "18":

                        produtosTelasServicos[index] = 'acessaRotina(\'\',\'SEGURO\',\'Seguro\',\'seguro\');';
                        index++;

                        break;

                        //SEGURO RESIDENCIA
                    case "19":

                        produtosTelasServicos[index] = 'acessaRotina(\'\',\'SEGURO\',\'Seguro\',\'seguro\');';
                        index++;

                        break;

                        // GUIAS DE BOAS VINDAS
                    case "20":

                        produtosTelasServicos[index] = 'acessaRotina(\'\',\'Relacionamento\',\'Relacionamento\',\'relacionamento\');';
                        index++;

                        break;

                        // CARTAO DE CREDITO CECRED
                    case "21":

                        produtosTelasServicos[index] = "showError('error','Para o cartão de crédito CECRED deve-se primeiramente preencher proposta pré-impressa.','Alerta - Ayllos','showConfirmacao(\"Produto aderido pelo cooperado?\",\"Confirma&ccedil;&atilde;o - Ayllos\",\"atualizarAdesao(21,true);encerraRotina(false);\",\"atualizarAdesao(21,false);encerraRotina(false);\",\"sim.gif\",\"nao.gif\");','','sim.gif','nao.gif');";
                        index++;

                        break;

                    case "22":

                        produtosTelasServicos[index] = "showError('error','Para cadastramento do SEGURO DE VIDA EM GRUPO, utilize o link CECRED SEGUROS na intranet.','Alerta - Ayllos','showConfirmacao(\"Produto aderido pelo cooperado?\",\"Confirma&ccedil;&atilde;o - Ayllos\",\"atualizarAdesao(22,true);encerraRotina(false);\",\"atualizarAdesao(22,false);encerraRotina(false);\",\"sim.gif\",\"nao.gif\");','','sim.gif','nao.gif');";
                        index++;

                        break;

                        // SEGURO EMPRESARIAL
                    case "23":

                        produtosTelasServicos[index] = "showError('error','Para cadastramento do SEGURO EMPRESARIAL deve-se primeiro efetuar preenchimento de proposta.','Alerta - Ayllos','showConfirmacao(\"Produto aderido pelo cooperado?\",\"Confirma&ccedil;&atilde;o - Ayllos\",\"atualizarAdesao(23,true);encerraRotina(false);\",\"atualizarAdesao(23,false);encerraRotina(false);\",\"sim.gif\",\"nao.gif\");','','sim.gif','nao.gif');";
                        index++;

                        break;

                        // CARTAO DE CREDITO EMPRESARIAL
                    case "24":

                        produtosTelasServicos[index] = "showError('error','Para cadastramento do CARTÃO DE CRÉDITO EMPRESARIAL deve-se primeiro efetuar preenchimento de proposta.','Alerta - Ayllos','showConfirmacao(\"Produto aderido pelo cooperado?\",\"Confirma&ccedil;&atilde;o - Ayllos\",\"atualizarAdesao(24,true);encerraRotina(false);\",\"atualizarAdesao(24,false);encerraRotina(false);\",\"sim.gif\",\"nao.gif\");','','sim.gif','nao.gif');";
                        index++;

                        break;

                }


                produtosTelasServicos[index - 1] = 'cdproduto = ' + $(this).attr('id') + ";" + produtosTelasServicos[index - 1];

            }

        });

        if (produtosTelasServicos.length > 0) {
            produtosTelasServicos[index] = 'executandoProdutosServicos = false;acessaRotina(\'\',\'PRODUTOS\',\'Produtos\',\'produtos\',\'2\',atualizarServicos);';
        }

    } else {

        produtosTelasServicosAdicionais = new Array();
        var index = 0;

        $('#tabelaServicosAdicionais tr:gt(0)').each(function (i) {

            if ($('#habilitar', $(this)).prop('checked')) {


                switch ($(this).attr('id')) {

                    //ACESSO A INTERNET
                    case "1":

                        produtosTelasServicosAdicionais[index] = 'acessaRotina(\'\',\'INTERNET\',\'Internet\',\'internet\');';
                        index++;

                        break;

                        //ACESSO AO TELE SALDO
                    case "2":

                        produtosTelasServicosAdicionais[index] = 'acessaRotina(\'\',\'TELE ATEN\',\'Tele Atendimento\',\'tele_atendimento\');';
                        index++;

                        break;

                        //APLICACAO
                    case "3":

                        produtosTelasServicosAdicionais[index] = 'acessaRotina(\'\',\'APLICACOES\',\'Aplica&ccedil;&otilde;es\',\'aplicacoes\');';
                        index++;

                        break;

                        //CARTAO DE CREDITO
                    case "4":

                        produtosTelasServicosAdicionais[index] = 'acessaRotina(\'\',\'CARTAO CRED\',\'Cart&otilde;es de Cr&eacute;dito\',\'cartao_credito\');'
                        index++;

                        break;

                        //CARTAO MAGNETICO
                    case "5":

                        produtosTelasServicosAdicionais[index] = 'acessaRotina(\'\',\'MAGNETICO\',\'Cart&otilde;es Magn&eacute;ticos\',\'magneticos\');';
                        index++;

                        break;

                        //COBRANCA BANCARIA
                    case "6":

                        produtosTelasServicosAdicionais[index] = 'acessaRotina(\'\',\'COBRANCA\',\'Cobran&ccedil;a\',\'cobranca\');';
                        index++;

                        break;

                        //CONSORCIO 
                    case "7":

                        produtosTelasServicosAdicionais[index] = "showError('error','Para cadastramento de CONS&Oacute;RCIO, utilize o link CECRED CONSORCIOS no portal.','Alerta - Ayllos','showConfirmacao(\"Produto aderido pelo cooperado?\",\"Confirma&ccedil;&atilde;o - Ayllos\",\"atualizarAdesao(7,true);encerraRotina(false);\",\"atualizarAdesao(7,false);encerraRotina(false);\",\"sim.gif\",\"nao.gif\");','','sim.gif','nao.gif');";
                        index++;

                        break;

                        //CONVENIO FOLHA DE PAGAMENTO -> Abrir a tela CADEMP
                    case "8":

                        produtosTelasServicosAdicionais[index] = "setaParametros('CADEMP','','" + nrdconta + "','" + flgcadas + "'); setaATENDA(); direcionaTela('CADEMP','no'); ";
                        index++;

                        break;

                        //DDA
                    case "9":

                        produtosTelasServicosAdicionais[index] = 'acessaRotina(\'\',\'DDA\',\'DDA\',\'dda\');';
                        index++;

                        break;

                        //DEBITO AUTOMATICO -> Abrir a tela AUTORI
                    case "10":

                        produtosTelasServicosAdicionais[index] = "setaParametros('AUTORI','','" + nrdconta + "','" + flgcadas + "'); setaATENDA(); direcionaTela('AUTORI','no'); ";
                        index++;

                        break;

                        //DOMICILIO BANCARIO 
                    case "11":

                        produtosTelasServicosAdicionais[index] = "showError('error','Para cadastramento de DOMICILIO BANCARIO, utilize o sistema SISBR ou preencha a proposta.','Alerta - Ayllos','showConfirmacao(\"Produto aderido pelo cooperado?\",\"Confirma&ccedil;&atilde;o - Ayllos\",\"atualizarAdesao(11,true);encerraRotina(false);\",\"atualizarAdesao(11,false);encerraRotina(false);\",\"sim.gif\",\"nao.gif\");','','sim.gif','nao.gif');";
                        index++;

                        break;

                        //INTEGRALIZACAO DO CAPITAL
                    case "12":

                        produtosTelasServicosAdicionais[index] = 'acessaRotina(\'\',\'CAPITAL\',\'Capital\',\'capital\');';
                        index++;

                        break;

                        //LIMITE DE CREDITO
                    case "13":

                        if (inpessoa == 1) {
                            produtosTelasServicosAdicionais[index] = 'acessaRotina(\'\',\'LIMITE CRED\',\'Limite de Cr&eacute;dito\',\'limite_credito\');';
                        } else {
                            produtosTelasServicosAdicionais[index] = 'acessaRotina(\'\',\'LIMITE CRED\',\'Limite Empresarial\',\'limite_credito\');';
}

                        index++;

                        break;

                        //LIMITE PARA INTERNET
                    case "14":

                        produtosTelasServicosAdicionais[index] = 'acessaRotina(\'\', \'INTERNET\',\'Internet\',\'internet\');';
                        index++;

                        break;

                        //PLANMO COTAS
                    case "15":

                        produtosTelasServicosAdicionais[index] = 'acessaRotina(\'\',\'CAPITAL\',\'Capital\',\'capital\');';
                        index++;

                        break;

                        //POUPANCA PROGRAMADA
                    case "16":

                        produtosTelasServicosAdicionais[index] = 'acessaRotina(\'\',\'POUP. PROG\',\'oupan&ccedil;a Programada\',\'poupanca_programada\');';
                        index++;

                        break;

                        //SEGURO AUTO 
                    case "17":

                        produtosTelasServicosAdicionais[index] = "showError('error','Para cadastramento do SEGURO AUTO, utilize o link CECRED SEGUROS na intranet.','Alerta - Ayllos','showConfirmacao(\"Produto aderido pelo cooperado?\",\"Confirma&ccedil;&atilde;o - Ayllos\",\"atualizarAdesao(17,true);encerraRotina(false);\",\"atualizarAdesao(17,false);encerraRotina(false);\",\"sim.gif\",\"nao.gif\");','','sim.gif','nao.gif');";
                        index++;

                        break;

                        //SEGURO VIDA
                    case "18":

                        produtosTelasServicosAdicionais[index] = 'acessaRotina(\'\',\'SEGURO\',\'Seguro\',\'seguro\');';
                        index++;

                        break;

                        //SEGURO RESIDENCIAL 
                    case "19":

                        produtosTelasServicosAdicionais[index] = 'acessaRotina(\'\',\'SEGURO\',\'Seguro\',\'seguro\');';
                        index++;

                        break;

                        // GUIA DE BOAS VINDAS
                    case "20":

                        produtosTelasServicosAdicionais[index] = 'acessaRotina(\'\',\'Relacionamento\',\'Relacionamento\',\'relacionamento\');';
                        index++;

                        break;

                        // CARTAO DE CREDITO CECRED
                    case "21":

                        produtosTelasServicosAdicionais[index] = "showError('error','Para o cartão de crédito CECRED deve-se primeiramente preencher proposta pré-impressa.','Alerta - Ayllos','showConfirmacao(\"Produto aderido pelo cooperado?\",\"Confirma&ccedil;&atilde;o - Ayllos\",\"atualizarAdesao(21,true);encerraRotina(false);\",\"atualizarAdesao(21,false);encerraRotina(false);\",\"sim.gif\",\"nao.gif\");','','sim.gif','nao.gif');";
                        index++;

                        break;

                        // SEGURO VIDA GRUPO	
                    case "22":

                        produtosTelasServicosAdicionais[index] = "showError('error','Para cadastramento do SEGURO DE VIDA EM GRUPO, utilize o link CECRED SEGUROS na intranet.','Alerta - Ayllos','showConfirmacao(\"Produto aderido pelo cooperado?\",\"Confirma&ccedil;&atilde;o - Ayllos\",\"atualizarAdesao(22,true);encerraRotina(false);\",\"atualizarAdesao(22,false);encerraRotina(false);\",\"sim.gif\",\"nao.gif\");','','sim.gif','nao.gif');";
                        index++;

                        break;

                        // SEGURO EMPRESARIAL	
                    case "23":

                        produtosTelasServicosAdicionais[index] = "showError('error','Para cadastramento do SEGURO EMPRESARIAL deve-se primeiro efetuar preenchimento de proposta.','Alerta - Ayllos','showConfirmacao(\"Produto aderido pelo cooperado?\",\"Confirma&ccedil;&atilde;o - Ayllos\",\"atualizarAdesao(23,true);encerraRotina(false);\",\"atualizarAdesao(23,false);encerraRotina(false);\",\"sim.gif\",\"nao.gif\");','','sim.gif','nao.gif');";
                        index++;

                        break;

                        // CARTAO CECRED EMPRESARIAL	
                    case "24":

                        produtosTelasServicosAdicionais[index] = "showError('error','Para cadastramento do CARTÃO DE CRÉDITO EMPRESARIAL deve-se primeiro efetuar preenchimento de proposta.','Alerta - Ayllos','showConfirmacao(\"Produto aderido pelo cooperado?\",\"Confirma&ccedil;&atilde;o - Ayllos\",\"atualizarAdesao(24,true);encerraRotina(false);\",\"atualizarAdesao(24,false);encerraRotina(false);\",\"sim.gif\",\"nao.gif\");','','sim.gif','nao.gif');";
                        index++;

                        break;
}

                produtosTelasServicosAdicionais[index - 1] = 'cdproduto = ' + $(this).attr('id') + ";" + produtosTelasServicosAdicionais[index - 1];

}

        });

        produtosTelasServicosAdicionais[index] = 'executandoProdutosServicosAdicionais = false;acessaRotina(\'\',\'PRODUTOS\',\'Produtos\',\'produtos\',\'3\',atualizarServicos);';


    }

    return false;

}





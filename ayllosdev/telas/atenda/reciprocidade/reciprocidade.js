/***********************************************************************
      Fonte: cobranca.js
      Autor: Gabriel
      Data : Dezembro/2010             Ultima atualizacao : 20/02/2019

      Objetivo  : Biblioteca de funcoes da rotina CONBRANCA tela ATENDA.

      Alteracoes: 19/05/2011 - Incluir Cob. Regis (Guilherme).

				  14/07/2011 - Alterado para layout padrão
							   (Gabriel Capoia - DB1)
                                   
				  26/07/2011 - Incluir opcao de impressao (Gabriel)

				  08/09/2011 - Ajuste para chamada da Lista Negra
							   (Adriano).

				  26/06/2012 - Ajustado para submeter impressao  em funcao  imprimirTermoAdesao()
							   (Jorge)

				  10/05/2013 - Retirado campo de valor maximo do boleto vllbolet
							   Retirado funcao validaDadosTitulares (Jorge)

				  19/09/2013 - Inclusao do campo Convenio Homologado. Criação da function
				               habilitaSetor (Carlos)

				  06/11/2014 - Correção de bug na função "habilitaSetor" que utilizava a função "IndexOf"
							   onde ocasionava erro no navegador IE. Isso tudo para que a fosse possível adicionar
							   o convênio "IMPRESSO PELO SOFTWARE" na tela de cobranças. (Kelvin)

				  28/04/2015 - Incluido campos cooperativa emite e expede e
							   cooperado emite e expede. (Reinert)

				  06/10/2015 - Reformulacao cadastral (Gabriel-RKAM)

                  24/11/2015 - Inclusao do indicador de negativacao pelo Serasa.
                               (Jaison/Andrino)

                  18/02/2016 - PRJ 213 - Reciprocidade. (Jaison/Marcos)

                  27/04/2016 - Ajuste para que departamento CANAIS possa ter acesso
                               a todas as funções da tela, conforme solicitadono
                               chamado 441903. (Kelvin)

                  04/08/2016 - Adicionado campo de forma de envio de arquivo de cobrança. (Reinert)

                  28/04/2016 - PRJ 318 - Ajustes projeto Nova Plataforma de cobrança (Odirlei/AMcom)

                  11/07/2016 - Ajustes para apenas solicitar senha para as alterações
                               de desconto manuais.
                               PRJ213 - Reciprocidade (odirlei-AMcom)


                  18/08/2016  - Adicionado função controlaFoco.(Evandro - RKAM).

                  29/11/2016 - P341-Automatização BACENJUD - Realizar as validações pelo código
				               do departamento ao invés da descrição (Renato Darosci - Supero)

                  19/04/2017 - Ajuste para imprimir o termo corretamente (adesão/cancelamento)
				               (Douglas - Chamado 641198)

				  13/12/2016 - PRJ340 - Nova Plataforma de Cobranca - Fase II. (Jaison/Cechet)

                  20/02/2019 - Novo campo Homologado API (Andrey Formigari - Supero)

                  05/09/2019 - RITM0037203 - Possibilitar Float 0 (Rafael Ferreira - Mouts)

                  05/09/2019 - RITM0037630 - Enviar contrato para Aprovação quando o Float for 0 ou
                                o "Debito reajuste da tarifa" for NÃO
                               (Rafael Ferreira - Mouts)

 ***********************************************************************/

var dsdregis = "";  // Variavel para armazenar os valores dos titulares
var nrconven = 0;   // Variavel para guardar o convenio no inclui-altera.php
var mensagem = "Deseja efetuar impress&atilde;o do termo de ades&atilde;o ?"; // Mensagem de confirmacao de impressao
var callafterCobranca = '';
var gFlginclu = false;

// Numero do convenio que deve ser impresso
var nrconven_imprimir = 0;
// Tipo de Impressao do Termo (1 - Adesão / 2 - Cancelamento)
var tpdtermo_imprimir = 1;

//Lista de Convenios para desconto
var descontoConvenios = [];

// Lista dos descontos das tarifas de instrução
var perdescontos = [];
var atualizacaoDesconto = false;

var nrcnvceb, insitceb, inarqcbr, cddemail, dsdemail, flgcebhm, qtTitulares,
    vtitulares, dsdmesag, flgregon, flgpgdiv, flcooexp, flceeexp, flserasa, qtdfloat,
    flprotes, qtlimmip, qtlimaxp, qtdecprz, idrecipr, inenvcob, flsercco, emails, qtbolcob, flgapihm, nrdconta, cddopcao, qtbolcob;

var cee = false;
var coo = false;
var cDataFimContrato, idcalculo_reciproci, cVldesconto_cee, cVldesconto_coo, cDataFimAdicionalCee, cDataFimAdicionalCoo, cJustificativaDesc;
var incluindoConvenio = false;

var sitflcee, sitflcoo;

function habilitaSetor(setorLogado) {
    // Se o setor logado não for 1-CANAIS, 18-SUPORTE ou 20-TI
    if ((setorLogado != 1) && (setorLogado != 18) && (setorLogado != 20)) {
        $('#flgcebhm', '#frmConsulta').desabilitaCampo();
        $('#flgapihm', '#frmConsulta').desabilitaCampo();
    }
}

// Acessar tela principal da rotina
function acessaOpcaoContratos() {

    document.getElementById('btSair').onclick = function () { encerraRotina(true); return false; }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando os conv&ecirc;nios ...");

    // Carrega conte&uacute;do da op&ccedil;&atilde;o atrav&eacute;s de ajax
    $.ajax({
        dataType: "html",
        type: "POST",
        url: UrlSite + "telas/atenda/reciprocidade/grid_contratos.php",
        data: {
            nrdconta: nrdconta,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function (response) {

            $("#divConteudoOpcao").css('display', 'block');
            $("#divOpcaoConsulta").css('display', 'none');
            $("#divOpcaoIncluiAltera").css('display', 'none');
            $("#pesquisaConvenio").css('display', 'none');
            $("#divTitular").css('display', 'none');
            $("#divOpcaoInternet").css('display', 'none');
            $("#divTestemunhas").css('display', 'none');
            $("#divLogCeb").css('display', 'none');
            $("#divLogNegociacao").css('display', 'none');
            $("#divServSMS").css('display', 'none');
            $("#divHabilita_SMS").css('display', 'none');
            $("#divTrocaPacote_SMS").css('display', 'none');
            $("#tdConteudoTela>table").prop('width', '600');
            $("#divConvenios").css('display', 'none');
            $("#telaAprovacao").css('display', 'none');
            $("#telaRejeicao").css('display', 'none');

            $("#divConteudoOpcao").html(response);
            controlaFoco();
        }
    });
}

// Acessar tela principal da rotina
function acessaOpcaoDescontos(cddopcao) {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando os conv&ecirc;nios ...");

    var idrecipr = 0;
    if (cddopcao == 'A' || cddopcao == 'C') {
        idrecipr = $("#idrecipr", "#divConteudoOpcao").val();
        if (idrecipr == '') {
            hideMsgAguardo();
            showError("error", "Selecione um contrato.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
            return;
        } else if (idrecipr == 0) {
            hideMsgAguardo();
            showError("error", "O contrato selecionado não possui reciprocidade.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
            return;
        }
    }

    // Carrega conte&uacute;do da op&ccedil;&atilde;o atrav&eacute;s de ajax
    $.ajax({
        dataType: "html",
        type: "POST",
        url: UrlSite + "telas/atenda/reciprocidade/form_descontos.php",
        data: {
            nrdconta: nrdconta,
            idcalculo_reciproci: idrecipr,
            cddopcao: cddopcao,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function (response) {

            $("#divConteudoOpcao").css('display', 'block');
            $("#tdConteudoTela>table").prop('width', '350');

            $("#divConteudoOpcao").html(response);

            $('#cddopcao', '#divConteudoOpcao').val(cddopcao);

            controlaFoco();

            novosConvenios = [];

            if (cddopcao == 'C') {
                $('input, select', '.tabelaDesconto').desabilitaCampo();
                $('#btnConveniosCobranca, #gridDescontoConvenios a:last-child, #btnContinuar, #btnAprovacao').remove();
            }
        }
    });
}

function voltarParaDesconto() {
    document.getElementById('btSair').onclick = function () { acessaOpcaoContratos(); }
    $("#divOpcaoConsulta").css('display', 'none');
    $("#divConteudoOpcao").css('display', 'block');
    validaHabilitacaoCamposBtn();
}

//Função para controle de navegação
function controlaFoco() {
    $('#divConteudoOpcao').each(function () {
        $(this).find("#divBotoes > :input[type=image]").addClass("FluxoNavega");
        $(this).find("#divBotoes > :input[type=image]").first().addClass("FirstInputModal").focus();
        $(this).find("#divBotoes > :input[type=image]").last().addClass("LastInputModal");
    });


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

    //Se estiver com foco na classe FluxoNavega
    $(".FluxoNavega").focus(function () {
        $(this).bind('keydown', function (e) {
            if (e.keyCode == 13) {
                e.stopPropagation();
                e.preventDefault();
                $(this).click();
            }
        });
    });

    $(".FirstInputModal").focus();
}

// Destacar convenio selecinado e setar valores do item selecionado
function selecionaConvenio(linha, idrecipr, insitceb, convenios) {
    var insitapr = $(linha).find('#insitapr').val();

    $("#idrecipr", "#divConteudoOpcao").val(idrecipr);
    $("#convenios", "#divConteudoOpcao").val(convenios);
    $("#insitceb", "#divConteudoOpcao").val(insitceb);

    $('#btnAbrirAprovacao').hide();
    $('#btnAbrirRejeicao').hide();

    if (insitceb == '2') {
        $("#btnAlterarConvenio").hide();
    } else if (insitceb == '3') {
        if (!parseInt(insitapr)) {
            $('#btnAbrirAprovacao').show();
            $('#btnAbrirRejeicao').show();
        }
    } else {
        $("#btnAlterarConvenio").show();
    }
}
//Abre modal de desconto de convenios.
function descontoConvenio() {

    var idrecipr = $('#idcalculo_reciproci', '#divConteudoOpcao').val();

    showMsgAguardo("Aguarde, carregando ...");

    // Carrega conte&uacute;do da op&ccedil;&atilde;o atrav&eacute;s de ajax
    $.ajax({
        dataType: "html",
        type: "POST",
        url: UrlSite + "telas/atenda/reciprocidade/desconto_convenio.php",
        data: {
            nrcnvceb: 1,
            nrdconta: nrdconta,
            idrecipr: idrecipr,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },

        success: function (response) {
            $('#divConteudoOpcao').css("display", "none");
            $('#divConvenios').html(response);
            $("#divConvenios").css('display', 'block');
            controlaFoco();
        }
    });


    return false;
}
//Sai da moval de desconto_convenios sem salvar.
function sairDescontoConvenio() {

    // atualiza tabela de convênios
    $('#gridDescontoConvenios').remove();
    $('#divConveniosRegistros').html('<div class="divRegistros"></div>');

    var table = $('<table></table>').attr({ id: "gridDescontoConvenios" });
    var thead = $('<thead></thead>').appendTo(table);
    var tr = $('<tr></tr>').appendTo(thead);

    $('<th>Convênio</th>').appendTo(tr);
    $('<th>&nbsp;</th>').appendTo(tr);

    for (var i = 0, len = descontoConvenios.length; i < len; ++i) {
        var nrconven = descontoConvenios[i].convenio;
        var tipo = descontoConvenios[i].tipo;

        var tr = $('<tr></tr>').appendTo(table);
        tr.attr({ id: 'convenio_' + nrconven });

        // seta valores padrões
        var titExcluir = 'Excluir Conv&ecirc;nio';
        var fncExcluir = 'excluirConvenio(' + nrconven + ', true); return false;';
        var imgExcluir = UrlImagens + 'geral/excluir.gif';

        // convenio ativo e quantidade de boletos emitidos maior que zero
        if (parseInt(descontoConvenios[i].insitceb) === 1 && descontoConvenios[i].qtbolcob > 0) {
            titExcluir = 'Inativar Conv&ecirc;nio';
            fncExcluir = 'inativarConvenio(' + nrconven + ', true); return false;';
        } else if (parseInt(descontoConvenios[i].insitceb) === 2) {
            titExcluir = 'Ativar Conv&ecirc;nio';
            fncExcluir = 'ativarConvenio(' + nrconven + ', true); return false;';
            imgExcluir = UrlImagens + 'geral/btn_excluir.gif';
        }

        $('<td>' + nrconven + ' - ' + tipo + '</td>').appendTo(tr);
        $('<td>' +
            '<a class="imgEditar" title="Editar Conv&ecirc;nio" onclick="editarConvenio(' + nrconven + '); return false;"><img src="' + $('#imgEditar').val() + '" style="margin-right:5px;width:14px;margin-top:1px" /></a>' +
            (($('#cddopcao', '#divConteudoOpcao').val() == 'A' || $('#cddopcao', '#divConteudoOpcao').val() == 'I') ?
			'<a class="imgExcluir" title="' + titExcluir + '" onclick="' + fncExcluir + '"><img src="' + imgExcluir + '" style="width:15px;margin-top:1px" border="0"/></a>'
            : '') +
        '</td>').appendTo(tr);
    }

    table.appendTo("#divConveniosRegistros .divRegistros");

    atualizarDescontos();

    // habilita tooltip
    $('.imgEditar').tooltip();
    $('.imgExcluir').tooltip();

    controlaLayout('divConveniosRegistros');

    $("#divConvenios").css("display", "none");
    $("#divOpcaoConsulta").css("display", "none");
    $("#divConteudoOpcao").css('display', 'block');
    controlaFoco();

    validaHabilitacaoCamposBtn();
    blockBackground(parseInt($("#divRotina").css("z-index")));

    return false;
}

//Salva lista de convenios de desconto.
function salvarDescontoConvenio() {
    var checkboxes = $('#divConvenios input[type="checkbox"]');

    if (checkboxes.length == 0) {
        showError("error", "&Eacute; necess&aacute;rio selecionar pelo menos um conv&ecirc;nio;.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }
    //Valida dois convenios do mesmo tipo ao mesmo tempo.
    foundMesmoTipo = false;
    var checkeds = checkboxes.parent().find(':checked');
    $.each(checkeds, function (idx, elm) {
        $.each(checkeds, function (idx2, elm2) {

            if ($(elm).val() != $(elm2).val() && $(elm).data('tipo') == $(elm2).data('tipo') && $(elm).data('tipo') != "IMPRESSO PELO SOFTWARE") {
                foundMesmoTipo = true;
            }
        });

    });
    if (foundMesmoTipo) {
        showError("error", "N&atilde;o &eacute; poss&iacute;vel selecionar mais de um conv&ecirc;nio de INTERNET.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }


    $.each(checkboxes, function (idx, elm) {
        var $el = $(elm);
        if ($el.is(':checked')) {
            if (retornaIndice(descontoConvenios, 'convenio', $el.val()) == null) {
                descontoConvenios.push({
                    convenio: $el.val(),
                    tipo: $el.data('tipo')
                });
            }
        } else {
            var index = retornaIndice(descontoConvenios, 'convenio', $el.val());
            if (index != null) {
                descontoConvenios.splice(index, 1);
            }
        }
    });

    validaEmiteExpede(true);
    sairDescontoConvenio();
}

function retornaIndice(lista, chave, valor) {
    var index = null;
    $.map(lista, function (a, i) {
        if (a[chave] == valor) {
            index = i;
        }
    });
    return index;
}


// Confirmar a exclusao do convenio CEB
function confirmaExclusao() {

    var flgregis = $("#flgregis", "#divConteudoOpcao").val();

    if (flgregis == 'SIM') {
        showConfirmacao('Confirma a exclus&atilde;o do conv&ecirc;nio ?', 'Confirma&ccedil;&atilde;o - Ayllos', 'confirmaImpressaoCancelamento("SIM")', ' blockBackground(parseInt($("#divRotina").css("z-index")))', 'sim.gif', 'nao.gif');
    } else {
        showConfirmacao('Confirma a exclus&atilde;o do conv&ecirc;nio ?', 'Confirma&ccedil;&atilde;o - Ayllos', 'realizaExclusao(1)', ' blockBackground(parseInt($("#divRotina").css("z-index")))', 'sim.gif', 'nao.gif');
    }
}

// Efetuar a exclusao do convenio CEB
function realizaExclusao(inapurac) {

    var nrconven = $("#nrconven", "#divConteudoOpcao").val();
    var nrcnvceb = $("#nrcnvceb", "#divConteudoOpcao").val();

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, Excluindo o conv&ecirc;nio ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        dataType: "html",
        type: "POST",
        url: UrlSite + "telas/atenda/reciprocidade/realiza_exclusao.php",
        data: {
            inapurac: inapurac,
            nrdconta: nrdconta,
            nrconven: nrconven,
            nrcnvceb: nrcnvceb,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                // Atualizar o convenio e o tipo de termo que deve ser impresso
                nrconven_imprimir = normalizaNumero(nrconven);
                tpdtermo_imprimir = 2; // Termo de cancelamento

                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });

}

// Exibe a opcao de Consulta ou Habilitacao
function consulta(cddopcao, nrconven, dsorgarq, flginclu, flgregis, cddbanco, idaba) {

    gFlginclu = flginclu;

    if (descontoConvenios.length == 0) {
        showError("error", "Selecione ao menos um conv&ecirc;nio.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
        return false;
    }

    // Situacao nao permite alteracao da cobranca
    if (cddopcao == "A" &&
       (insitceb == 4 ||  // Bloqueada
        insitceb == 6)) {  // Nao aprovada
        showError("error", "Situa&ccedil;&atilde;o da cobran&ccedil;a n&atilde;o permite altera&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return;
    }


    if (nrconven == "") {
        if (trim(cddopcao) == "I") {
            nrconven = normalizaNumero($("#nrconven", "#frmConsulta").val());
        } else {
            nrconven = normalizaNumero($("#nrconven", "#divConteudoOpcao").val());
        }
    }

    // if (nrconven == 0 && trim(cddopcao) != "S") {
    //     showError("error", "Selecione algum conv&ecirc;nio.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
    // 	return;
    // }

    if (dsorgarq == "") {
        dsorgarq = $("#dsorgarq", "#divConteudoOpcao").val();
    }

    if (flgregis == "") {
        flgregis = $("#flgregis", "#divConteudoOpcao").val();
    }

    if (trim(cddopcao) != "C") { // Quando for Habilitacao, carregar emails
        emails = $("#emails_titular").val();
    }

    // Rafael Ferreira (Mouts) - INC0020100 - Situac 3
    /*if (flginclu == "true") { // Se esta incluindo , zerar campos
        nrcnvceb = 0;
        insitceb = "1";
        inarqcbr = 0;
        cddemail = 0;
        flgcebhm = "NAO";
        flprotes = "NAO";
        qtlimmip = "";
        qtlimaxp = "";
        qtdfloat = "";
        qtdecprz = "";
        idrecipr = 0;
        flgapihm = "NAO";
    }*/


    if (cddbanco == "") {
        cddbanco = $("#cddbanco", "#divConteudoOpcao").val();
    }

    // Limpar os campos
    nrconven_imprimir = 0;
    tpdtermo_imprimir = 1;

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando ...");

    var index = retornaIndice(descontoConvenios, 'convenio', nrconven);


    if (index != null) {
        var item = descontoConvenios[index];
        cddemail = item.cddemail;
        flceeexp = item.flceeexp;
        flcooexp = item.flcooexp;
        flgcebhm = item.flgcebhm;
        flgpgdiv = item.flgpgdiv;
        flgregon = item.flgregon;
        flprotes = item.flprotes;
        flserasa = item.flserasa;
        inarqcbr = item.inarqcbr;
        inenvcob = item.inenvcob;
        insitceb = item.insitceb;
        qtdecprz = item.qtdecprz;
        qtdfloat = "";
        qtlimaxp = item.qtlimaxp;
        qtlimmip = item.qtlimmip;
        qtbolcob = item.qtbolcob;
        flgapihm = item.flgapihm;
    }

    // Carrega conte&uacute;do da op&ccedil;&atilde;o atrav&eacute;s de ajax
    $.ajax({
        dataType: "html",
        type: "POST",
        url: UrlSite + "telas/atenda/reciprocidade/consulta-habilita.php",
        data: {
            convenios: JSON.stringify(descontoConvenios),
            perdescontos: JSON.stringify(perdescontos),
            dsdmesag: dsdmesag,
            nrcnvceb: nrcnvceb,
            nrconven: nrconven,
            dsorgarq: dsorgarq,
            insitceb: insitceb,
            inarqcbr: inarqcbr,
            cddemail: cddemail,
            flgcebhm: flgcebhm,
            flgregis: flgregis,
            flgregon: flgregon,
            flgpgdiv: flgpgdiv,
            flcooexp: flcooexp,
            flceeexp: flceeexp,
            flserasa: flserasa,
            flgapihm: flgapihm,
            cddbanco: cddbanco,
            qtTitulares: qtTitulares,
            titulares: vtitulares,
            emails: emails,
            cddopcao: cddopcao,
            flsercco: flsercco, /* Indica se Convenio Possui Serasa*/
            qtdfloat: qtdfloat,
            flprotes: flprotes,
            qtlimaxp: qtlimaxp,
            qtlimmip: qtlimmip,
            qtdecprz: qtdecprz,
            idrecipr: idrecipr,
            inenvcob: inenvcob,
            nrdconta: nrdconta,
            inpessoa: inpessoa,
            qtbolcob: qtbolcob,
            idaba: idaba,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function (response) {
            $("#divOpcaoConsulta").html(response);
            hideMsgAguardo();
            blockBackground($("#divRotina"));
            validaHabilitacaoCamposBtn();
        }
    });
}

// Se habilitacao, valida dados primeiro , senao já chama os titulares
function titulares(cddopcao, titulares) {

    if (trim(cddopcao) != "C") { // Se habilitacao, primeiro valida dados da tela
        validaDadosLimites(false, titulares); // Soh valida , nao chama confirmacao
    }
    else { // Se consulta
        chamaTitulares(cddopcao, titulares);
    }
}

// Tela que apresenta os dados dos titulares
function chamaTitulares(cddopcao, titulares) {

    // Carrega conte&uacute;do da op&ccedil;&atilde;o atrav&eacute;s de ajax
    $.ajax({
        dataType: "html",
        type: "POST",
        url: UrlSite + "telas/atenda/reciprocidade/titulares.php",
        data: {
            cddopcao: cddopcao,
            titulares: titulares,

            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function (response) {
            $("#divTitular").html(response);
        }
    });
}

// Chamar a tela de zoom dos convenios
function pesquisaConvenio() {

    var bo = 'b1wgen0059.p';
    var procedure = 'busca_convenios';
    var titulo = 'Conv&ecirc;nios';
    var qtReg = '50';
    var filtro = 'Convenio;nrconven;65px;S;0|Origem;dsorgarq;155px;S;';
    var colunas = 'Convenio;nrconven;15%;right|Origem;dsorgarq;55%;left|Situacao;flgativo;15%;left|Registrada;flgregis;15%;left';

    // Se esta desabilitado o campo do convenio
    if ($("#nrconven", "#frmConsulta").prop("disabled") == true) {
        return;
    }

    mostraPesquisa(bo, procedure, titulo, qtReg, filtro, colunas, divRotina);
    return false;
}

// Verificar se pode ser realizada a inclusao
function validaHabilitacao() {

    var nrconven = retiraCaracteres($("#nrconven", "#frmConsulta").val(), "0123456789", true);
    var dsorgarq = $("#dsorgarq", "#frmConsulta").val();

    if (nrconven == "") {
        showError("error", "O campo do conv&ecirc;nio deve ser prenchido.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, Validando a habilita&ccedil;&atilde;o do conv&ecirc;nio ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        dataType: "html",
        type: "POST",
        url: UrlSite + "telas/atenda/reciprocidade/valida_habilitacao.php",
        data: {
            nrdconta: nrdconta,
            nrconven: nrconven,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

// Validar os dados da habilitacao
function validaDadosLimites(flgconti, titulares, cddopcao) {

    var dsorgarq = $("#dsorgarq", "#divOpcaoConsulta").val();
    var inarqcbr = $("#inarqcbr", "#divOpcaoConsulta").val();
    var cddemail = $("#dsdemail", "#divOpcaoConsulta").val();

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, Validando os dados da habilita&ccedil;&atilde;o do conv&ecirc;nio ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        dataType: "html",
        type: "POST",
        url: UrlSite + "telas/atenda/reciprocidade/valida-dados-limites.php",
        data: {
            nrdconta: nrdconta,
            dsorgarq: dsorgarq,
            inarqcbr: inarqcbr,
            cddemail: cddemail,
            flgconti: flgconti,
            titulares: titulares,
            cddopcao: cddopcao,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

// Confirmar a habilitacao do convenio
function confirmaHabilitacao(cddopcao) {
    var insitceb = $("#insitceb", "#divOpcaoConsulta").val();
    var dsmensagem = insitceb == '1' ? "Confirma a habilita&ccedil;&atilde;o do conv&ecirc;nio?" : "Confirma a inativa&ccedil;&atilde;o do conv&ecirc;nio?";

    nrconven_imprimir = normalizaNumero($("#nrconven", "#divOpcaoConsulta").val());
    // Se o convenio esta ativo, imprimir termo de adesão, caso contrario o termo de cancelamento
    tpdtermo_imprimir = (insitceb == 1) ? 1 : 2;

    //showConfirmacao(dsmensagem, 'Confirma&ccedil;&atilde;o - Ayllos', 'confirmaHabilitacaoSerasa("' + cddopcao + '")', ' blockBackground(parseInt($("#divRotina").css("z-index")))', 'sim.gif', 'nao.gif');
    showConfirmacao(dsmensagem, 'Confirma&ccedil;&atilde;o - Ayllos', 'confirmaInativacaoProtesto("' + cddopcao + '")', ' blockBackground(parseInt($("#divRotina").css("z-index")))', 'sim.gif', 'nao.gif');
}

function confirmaCancelamentoBoletos(cddopcao) {
    confirmaCancelamentoSustacao = false;
    showConfirmacao(
        'Deseja cancelar a instru&ccedil;&atilde;o autom&aacute;tica de protesto<br>dos boletos ativos e ainda n&atilde;o vencidos ou dentro da toler&acirc;ncia?',
        'Confirma&ccedil;&atilde;o - Ayllos',
        'cancelaSustaBoletos(0, "' + cddopcao + '")',
        'confirmaSustacaoBoletos("' + cddopcao + '")',
        'sim.gif', 'nao.gif'
    );
}

function confirmaSustacaoBoletos(cddopcao) {
    var flgregis = $("#flgregis", "#divOpcaoConsulta").val();
    showConfirmacao(
        'Deseja cancelar/sustar o protesto dos boletos?<br>O Cooperado deve ser conscientizado que a susta&ccedil;&atilde;o ocorrer&aacute; mediante aprova&ccedil;&atilde;o do cart&oacute;rio.',
        'Confirma&ccedil;&atilde;o - Ayllos',
        'cancelaSustaBoletos(1, "' + cddopcao + '")',
        'confirmaImpressaoCancelamento("' + flgregis + '", "confirmaHabilitacaoSerasa(\'' + cddopcao + '\')");',
        'sim.gif', 'nao.gif'
    );
}

function cancelaSustaBoletos(fltipo, cddopcao) { // 0 = cancela | 1 = susta

    confirmaCancelamentoSustacao = true;

    var nrconven = normalizaNumero($("#nrconven", "#divOpcaoConsulta").val());

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        dataType: 'html',
        url: UrlSite + "telas/atenda/reciprocidade/cancela_susta_boletos.php",
        data: {
            cddopcao: cddopcao,
            cdcooper: cdcooper,
            nrdconta: nrdconta,
            nrconven: nrconven,
            fltipo: fltipo,
            flgregis: $("#flgregis", "#divOpcaoConsulta").val(),
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o." + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

function confirmaInativacaoProtesto(cddopcao) {
    var blnchecked = $("#flprotes", "#divOpcaoConsulta").prop("checked");
    var flprotes_old = $("#flprotes", "#divConteudoOpcao").val();
    flprotes_old = flprotes_old == '' || gFlginclu ? "NAO" : flprotes_old;
    var flprotes_new = blnchecked ? "SIM" : "NAO";

    // Se foi habilitado/desabilitado o indicador
    if (flprotes_old != flprotes_new && flprotes_old == "SIM" && flprotes_new == "NAO") {

        // Seta como checkbox alterado, utilizado no realiza_habilitacao.php
        $("#flproalt", "#divConteudoOpcao").val(1);

        confirmaCancelamentoBoletos(cddopcao);

    } else {
        confirmaHabilitacaoSerasa(cddopcao);
    }
}

// imprimir
function imprimeRelatorio() {

    if (confirmaCancelamentoSustacao) {
        var nmprimtl = $('#nmprimtl', '#frmCabAtenda').val(),
            cdagenci = $('#cdagenci', '#frmCabAtenda').val(),
            action = UrlSite + 'telas/atenda/reciprocidade/imprimir_relatorio.php';

        $("#nrdconta", "#frmRelatorio").val(nrdconta);
        $("#nmprimtl", "#frmRelatorio").val(nmprimtl);
        $("#cdagenci", "#frmRelatorio").val(cdagenci);

        //carregaImpressaoAyllos("frmRelatorio",action,"bloqueiaFundo(divRotina);");
        carregaImpressaoAyllos("frmRelatorio", action, "");
    }
}

// Confirmar a habilitacao do Serasa
function confirmaHabilitacaoSerasa(cddopcao) {

    var blnchecked = $("#flserasa", "#divOpcaoConsulta").prop("checked");
    var flserasa_old = $("#flserasa", "#divConteudoOpcao").val();
    flserasa_old = flserasa_old == '' ? "NAO" : flserasa_old;
    var flserasa_new = blnchecked ? "SIM" : "NAO";
    var dsmensagem = blnchecked ? "Deseja habilitar a Negativa&ccedil;&atilde;o via Serasa?" : "Deseja cancelar a Negativa&ccedil;&atilde;o via Serasa?";

    // Se foi habilitado/desabilitado o indicador
    if (flserasa_old != flserasa_new) {

        // Seta como checkbox alterado, utilizado no realiza_habilitacao.php
        $("#flseralt", "#divConteudoOpcao").val(1);

        if (trim(cddopcao) == "A") {
            showConfirmacao(dsmensagem, 'Confirma&ccedil;&atilde;o - Ayllos', 'validaHabilitacaoSerasa("' + cddopcao + '")', ' blockBackground(parseInt($("#divRotina").css("z-index")))', 'sim.gif', 'nao.gif');
        } else {
            validaHabilitacaoSerasa(cddopcao);
        }

    } else {
        verificaSenhaCoordenador();
    }

}

// Valida a habilitacao do Serasa
function validaHabilitacaoSerasa(cddopcao) {

    var blnchecked = $("#flserasa", "#divOpcaoConsulta").prop("checked");

    // Foi clicado para habilitar Serasa
    if (blnchecked) {
        // Se nao possuir CNAE cadastrado
        if (parseInt(cdclcnae) < 1) {
            showError("error", "CNAE da conta n&atilde;o informado. Favor verificar.", "Alerta - Ayllos", "bloqueiaFundo(divRotina)");
        } else {

            // Mostra mensagem de aguardo
            showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");

            // Carrega conteúdo da opção através de ajax
            $.ajax({
                type: "POST",
                dataType: 'html',
                url: UrlSite + "telas/atenda/reciprocidade/consulta-cnae-boleto.php",
                data: {
                    cdclcnae: cdclcnae,
                    consulta: 1,
                    redirect: "script_ajax" // Tipo de retorno do ajax
                },
                error: function (objAjax, responseError, objExcept) {
                    hideMsgAguardo();
                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o." + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
                },
                success: function (tbgen_cnae_flserasa) {
                    hideMsgAguardo();
                    bloqueiaFundo($('#divOpcaoIncluiAltera'));
                    if (tbgen_cnae_flserasa == 0) {
                        showError('error', 'N&atilde;o &eacute; permitido habilitar o servi&ccedil;o para este segmento (CNAE).', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
                    } else {
                        verificaSenhaCoordenador();
                    }
                }
            });

        }

    } else { // Foi clicado para desabilitar Serasa

        var nrconven = normalizaNumero($("#nrconven", "#divOpcaoConsulta").val());

        // Mostra mensagem de aguardo
        showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");

        // Carrega conteúdo da opção através de ajax
        $.ajax({
            type: "POST",
            dataType: 'html',
            url: UrlSite + "telas/atenda/reciprocidade/consulta-cnae-boleto.php",
            data: {
                nrdconta: nrdconta,
                nrconven: nrconven,
                consulta: 2,
                redirect: "script_ajax" // Tipo de retorno do ajax
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.." + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
            },
            success: function (flposbol) {
                hideMsgAguardo();
                bloqueiaFundo($('#divOpcaoIncluiAltera'));
                // Se possuir boleto em aberto
                if (flposbol == 1) {
                    showConfirmacao("Deseja cancelar as instru&ccedil;&otilde;es de negativa&ccedil;&atilde;o sobre os boletos em aberto?", 'Confirma&ccedil;&atilde;o - Ayllos', 'setFlgBoleto(\'' + cddopcao + '\', \'1\')', 'setFlgBoleto(\'' + cddopcao + '\', \'0\')', 'sim.gif', 'nao.gif');
                } else {
                    verificaSenhaCoordenador();
                }
            }
        });
    }

}

function setFlgBoleto(cddopcao, flposbol) {
    $("#flposbol", "#divConteudoOpcao").val(flposbol);
    verificaSenhaCoordenador();
}

// Efetuar a inclusao do convenio
function realizaHabilitacao(idrecipr, cddopcao) {

    var insitceb = $("#insitceb", "#divOpcaoConsulta").val();
    var inarqcbr = $("#inarqcbr", "#divOpcaoConsulta").val();
    var cddemail = $("#dsdemail", "#divOpcaoConsulta").val();
    var flgcebhm = $("#flgcebhm", "#divOpcaoConsulta").val();
    var flgregis = $("#flgregis", "#divOpcaoConsulta").val();
    var flserasa = $("#flserasa", "#divOpcaoConsulta").val();
    var flseralt = $("#flseralt", "#divConteudoOpcao").val();
    var flprotes = $("#flprotes", "#divOpcaoConsulta").val();
    var flproalt = $("#flproalt", "#divConteudoOpcao").val();
    var flposbol = $("#flposbol", "#divConteudoOpcao").val();
    var cddbanco = $("#cddbanco", "#divOpcaoConsulta").val();
    var qtdfloat = $('#qtdfloat', '#divConteudoOpcao').val();
    var qtdecprz = $("#qtdecprz", "#divOpcaoConsulta").val();
    var qtlimmip = $("#qtlimmip", "#divOpcaoConsulta").val();
    var insrvprt = $("#insrvprt", "#divOpcaoConsulta").val();
    var qtlimaxp = $("#qtlimaxp", "#divOpcaoConsulta").val();
    var inenvcob = $("#inenvcob", "#divOpcaoConsulta").val();
    var idreciprold = $("#idreciprold", "#divOpcaoConsulta").val();
	var flgapihm = $("#flgapihm", "#divOpcaoConsulta").val();

    nrconven = normalizaNumero(nrconven);
    qtdfloat = normalizaNumero(qtdfloat);
    qtdecprz = normalizaNumero(qtdecprz);
    insrvprt = normalizaNumero(insrvprt);
    qtlimmip = normalizaNumero(qtlimmip);
    qtlimaxp = normalizaNumero(qtlimaxp);

    if ($("#flgregon", "#divOpcaoConsulta").prop("checked") == true) {
        var flgregon = 1;
    } else {
        var flgregon = 0;
    }
    if ($("#flgpgdiv", "#divOpcaoConsulta").prop("checked") == true) {
        var flgpgdiv = 1;
    } else {
        var flgpgdiv = 0;
    }
    if ($("#flcooexp", "#divOpcaoConsulta").prop("checked") == true) {
        var flcooexp = 1;
    } else {
        var flcooexp = 0;
    }
    if ($("#flceeexp", "#divOpcaoConsulta").prop("checked") == true) {
        var flceeexp = 1;
    } else {
        var flceeexp = 0;
    }
    if ($("#flserasa", "#divOpcaoConsulta").prop("checked") == true) {
        var flserasa = 1;
    } else {
        var flserasa = 0;
    }
    if ($("#flprotes", "#divOpcaoConsulta").prop("checked") == true) {
        var flprotes = 1;
    } else {
        var flprotes = 0;
    }
    var nrcpfcgc = $("#nrcpfcgc", "#frmCabAtenda").val().replace(".", "").replace(".", "").replace("-", "").replace("/", "");

    var perdesconto = '';
    $(".clsPerDesconto").each(function (index) {
        if ($(this).is(":visible")) {
            perdesconto += (perdesconto == '' ? '' : '|') + $(this).attr('cdcatego') + '#' + converteMoedaFloat($(this).val());
        }
    });

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, Incluindo a habilita&ccedil;&atilde;o dos conv&ecirc;nios ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        dataType: "html",
        type: "POST",
        url: UrlSite + "telas/atenda/reciprocidade/realiza_habilitacao.php",
        data: {
            nrdconta: nrdconta,
            convenios: JSON.stringify(descontoConvenios),
            insitceb: insitceb,
            inarqcbr: inarqcbr,
            cddemail: cddemail,
            flgcebhm: flgcebhm,
            dsdregis: dsdregis,
            flgregis: flgregis,
            flgregon: flgregon,
            flgpgdiv: flgpgdiv,
            flcooexp: flcooexp,
            flceeexp: flceeexp,
			flgapihm: flgapihm,
            flserasa: flserasa,
            flseralt: flseralt,
            flposbol: flposbol,
            nrcpfcgc: nrcpfcgc,
            cddopcao: cddopcao,
            qtdfloat: qtdfloat,
            flprotes: flprotes,
            flproalt: flproalt,
            insrvprt: insrvprt,
            qtlimaxp: qtlimaxp,
            qtlimmip: qtlimmip,
            qtdecprz: qtdecprz,
            idrecipr: idrecipr,
            inenvcob: inenvcob,
            idreciprold: idreciprold,
            perdesconto: perdesconto,
            executandoProdutos: executandoProdutos,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

function onChangeProtesto() {
    if ($('#flprotes', '#divOpcaoSerasaProtesto').prop("checked")) {
        $('#qtlimmip', '#divOpcaoSerasaProtesto').habilitaCampo();
        $('#qtlimaxp', '#divOpcaoSerasaProtesto').habilitaCampo();

    } else {
        $('#qtlimmip', '#divOpcaoSerasaProtesto').val('').desabilitaCampo();
        $('#qtlimaxp', '#divOpcaoSerasaProtesto').val('').desabilitaCampo();
    }
}

// Perguntar se quer fazer a impressao do termo
function confirmaImpressao(flgregis, dsdtitul) {

    var callafterCobranca = 'blockBackground(parseInt($("#divRotina").css("z-index")));';
    //$("#idrecipr", "#divConteudoOpcao").val(idrecipr);
    var nrconven = $("#convenios", "#divConteudoOpcao").val();
    var insitceb = $("#insitceb", "#divConteudoOpcao").val();

    if (nrconven == "") {
        nrconven = $("#nrconven", "#frmConsulta").val();
        if (nrconven == "") {
            showError("error", "Selecione algum conv&ecirc;nio.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            return;
        }
    }

    // Verificar se situacao permite imprimir termo
    if (insitceb > 2) {
        showError("error", "Situa&ccedil;&atilde;o da cobran&ccedil;a n&atilde;o permite Impress&atilde;o do Termo.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return;
    }

    if (flgregis == "") {
        flgregis = $("#flgregis", "#divConteudoOpcao").val();
    }

    callafterCobranca += (executandoProdutos) ? 'encerraRotina();' : 'acessaOpcaoContratos();';

    if ($("#insitceb", "#divConteudoOpcao").val() == '2') {
        aux_mensagem = "Deseja efetuar impress&atilde;o do termo de cancelamento ?"; // Mensagem de confirmacao de impressao;
    } else {
        aux_mensagem = mensagem;
    }

    // Se cobranca Registrada
    if (flgregis == "SIM") {
        showConfirmacao(aux_mensagem,
						'Confirma&ccedil;&atilde;o - Ayllos',
						'testemunhas("' + flgregis + '");blockBackground(parseInt($("#divRotina").css("z-index")));',
						callafterCobranca,
						'sim.gif',
						'nao.gif');
    }
    else {
        showConfirmacao(aux_mensagem,
					   'Confirma&ccedil;&atilde;o - Ayllos',
					   'imprimirTermoAdesao("' + flgregis + '","' + dsdtitul + '");',
					   callafterCobranca,
					   'sim.gif',
					   'nao.gif');
    }

}

function testemunhas(flgregis) {

    var nmrotina = "imprimirTermoAdesao";

    // Carrega conteúdo da opção através do Ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/dda/testemunhas.php',
        data: {
            nmrotina: nmrotina,
            flgregis: flgregis,
            redirect: 'ajax_html'
        },
        error: function (objAjax, responseError, objExcept) {
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function (response) {
            $("#divOpcaoIncluiAltera").css({ 'display': 'none' });
            $("#divOpcaoConsulta").css({ 'display': 'none' });
            $("#divTestemunhas").html(response);

        }
    });
}


function validaCpf(nmrotina) {

    var idseqttl = 1;
    var nmdtest1 = $("#nmdtest1", "#divTestemunhas").val();
    var cpftest1 = $("#cpftest1", "#divTestemunhas").val();
    var nmdtest2 = $("#nmdtest2", "#divTestemunhas").val();
    var cpftest2 = $("#cpftest2", "#divTestemunhas").val();
    var flgregis = $("#flgregis", "#divTestemunhas").val();

    showMsgAguardo('Aguarde, validando os dados ...');

    // Carrega conteúdo da opção através do Ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/dda/valida_cpf.php',
        data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            nmrotina: nmrotina,
            nmdtest1: nmdtest1,
            cpftest1: cpftest1,
            nmdtest2: nmdtest2,
            cpftest2: cpftest2,
            flgregis: flgregis,
            redirect: 'ajax_html'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

function imprimirTermoCancelamentoProtesto(cddopcao, flgregis, dsdtitul, tpimpres) {
    confirmaHabilitacaoSerasa(cddopcao);
}


// Função para carregar impressao de termo de adesão em PDF
function imprimirTermoAdesao(flgregis, dsdtitul, tpimpres) {

    var nmdtest1 = $("#nmdtest1", "#divTestemunhas").val();
    var cpftest1 = $("#cpftest1", "#divTestemunhas").val();
    var nmdtest2 = $("#nmdtest2", "#divTestemunhas").val();
    var cpftest2 = $("#cpftest2", "#divTestemunhas").val();
    var insitceb = $("#insitceb", "#divConteudoOpcao").val();
    var idrecipr = $("#idrecipr", "#divConteudoOpcao").val();

    var nrconven = normalizaNumero($("#convenios", "#divConteudoOpcao").val());
    nrconven_imprimir = (nrconven_imprimir > 0) ? nrconven_imprimir : nrconven;

    flgregis = (flgregis == "SIM") ? "yes" : "no";

    $("#nrdconta", "#frmTermo").val(nrdconta);
    $("#dsdtitul", "#frmTermo").val(dsdtitul);
    $("#flgregis", "#frmTermo").val(flgregis);
    $("#nmdtest1", "#frmTermo").val(nmdtest1);
    $("#cpftest1", "#frmTermo").val(cpftest1);
    $("#nmdtest2", "#frmTermo").val(nmdtest2);
    $("#cpftest2", "#frmTermo").val(cpftest2);
    $("#nrconven", "#frmTermo").val(nrconven_imprimir);
    $("#idrecipr", "#frmTermo").val(idrecipr);
    $("#tpimpres", "#frmTermo").val(tpdtermo_imprimir);//Atribuir o insitest onde 1-ativo e 2-inativo

    var action = $("#frmTermo").attr("action");
    var callafter = "acessaOpcaoContratos();";

    if (executandoProdutos) {
        callafterCobranca = 'encerraRotina();';
    }

    if (callafterCobranca != '') {
        callafter = callafterCobranca;
    }

    // Zerar as variáveis
    nrconven_imprimir = 0;
    tpdtermo_imprimir = 1;

    carregaImpressaoAyllos("frmTermo", action, callafter);
}

// Limpar campos e deselecionar o convenio
function limpaCampos() {

    var cor = "";
    var qtConvenios = $("#qtconven", "#divConteudoOpcao").val();

    $("#nrconven", "#divConteudoOpcao").val("");
    $("#dsorgarq", "#divConteudoOpcao").val("");

    var nomeForm = 'divResultado';
    var divRegistro = $('div.divRegistros', '#' + nomeForm);
    var tabela = $('table', divRegistro);

    tabela.zebraTabela();

}

function controlaLayout(nomeForm) {

    if (nomeForm == 'frmConsulta') {

        $('#' + nomeForm).addClass('formulario');

        var Lnrconven = $('label[for="nrconven"]', '#' + nomeForm);
        var Ldsorgarq = $('label[for="dsorgarq"]', '#' + nomeForm);
        var Linsitceb = $('label[for="insitceb"]', '#' + nomeForm);
        var Lflgregis = $('label[for="flgregis"]', '#' + nomeForm);
        var Lflgregon = $('label[for="flgregon"]', '#' + nomeForm);
        var Lflgpgdiv = $('label[for="flgpgdiv"]', '#' + nomeForm);
        var Lflcooexp = $('label[for="flcooexp"]', '#' + nomeForm);
        var Lflceeexp = $('label[for="flceeexp"]', '#' + nomeForm);
        var Lflserasa = $('label[for="flserasa"]', '#' + nomeForm);
        var Linarqcbr = $('label[for="inarqcbr"]', '#' + nomeForm);
        var Ldsdemail = $('label[for="dsdemail"]', '#' + nomeForm);
        var Lflgcebhm = $('label[for="flgcebhm"]', '#' + nomeForm);
        var Lflgapihm = $('label[for="flgapihm"]', "#" + nomeForm);
        var Lqtdfloat = $('label[for="qtdfloat"]', '#' + nomeForm);
        var Lflprotes = $('label[for="flprotes"]', '#' + nomeForm);
        var Lqtlimmip = $('label[for="qtlimmip"]', '#' + nomeForm);
        var Lqtdecprz = $('label[for="qtdecprz"]', '#' + nomeForm);
        var Linenvcob = $('label[for="inenvcob"]', '#' + nomeForm);

        var Cnrconven = $('#nrconven', '#' + nomeForm);
        var Cdsorgarq = $('#dsorgarq', '#' + nomeForm);
        var Cinsitceb = $('#insitceb', '#' + nomeForm);
        var Cflgregis = $('#flgregis', '#' + nomeForm);
        var Cinarqcbr = $('#inarqcbr', '#' + nomeForm);
        var Cdsdemail = $('#dsdemail', '#' + nomeForm);
        var Cflgcebhm = $('#flgcebhm', '#' + nomeForm);
        var Cflgapihm = $('#flgapihm', '#' + nomeForm);
        var Ccddopcao = $('#cddopcao', '#' + nomeForm);
        var Cqtdfloat = $('#qtdfloat', '#' + nomeForm);
        var Cqtdecprz = $('#qtdecprz', '#' + nomeForm);
        var Cqtlimmip = $('#qtlimmip', '#' + nomeForm);
        var Cqtlimaxp = $('#qtlimaxp', '#' + nomeForm);
        var Cperdesconto = $('.clsPerDesconto', '#' + nomeForm);
        var Cinenvcob = $('#inenvcob', '#' + nomeForm);

        Lnrconven.addClass('rotulo').css('width', '210px');
        Ldsorgarq.addClass('rotulo').css('width', '210px');
        Linsitceb.addClass('rotulo').css('width', '210px');
        Lflgregis.addClass('rotulo').css('width', '210px');
        Lflgregon.addClass('rotulo').css('width', '210px');
        Lflgpgdiv.addClass('rotulo').css('width', '210px');
        Lflcooexp.addClass('rotulo').css('width', '210px');
        Lflceeexp.addClass('rotulo').css('width', '210px');
        Lflserasa.addClass('rotulo').css('width', '210px');
        Linarqcbr.addClass('rotulo').css('width', '210px');
        Ldsdemail.addClass('rotulo').css('width', '210px');
        Lflgcebhm.addClass('rotulo').css('width', '210px');
        Lflgapihm.addClass('rotulo').css('width', '210px');
        Lqtdfloat.addClass('rotulo').css('width', '210px');
        Lflprotes.addClass('rotulo').css('width', '210px');
        Lqtlimmip.addClass('rotulo').css('width', '210px');
        Lqtdecprz.addClass('rotulo').css('width', '210px');
        Linenvcob.addClass('rotulo').css('width', '210px');

        Cnrconven.css({ 'width': '70px' });
        Cdsorgarq.css({ 'width': '200px' });
        Cflgregis.css({ 'width': '50px' });
        Cinarqcbr.css({ 'width': '155px' });
        Cdsdemail.css({ 'width': '200px' });
        Cflgcebhm.css({ 'width': '50px' });
        Cflgapihm.css({ 'width': '50px' });
        Cqtdfloat.css({ 'width': '70px' });
        Cqtdecprz.css({ 'width': '50px' }).attr('maxlength', '5').setMask("INTEGER", "zzzzz", ".", "");
        Cqtlimmip.css({ 'width': '30px' }).attr('maxlength', '3').setMask("INTEGER", "zzz", ".", "");
        Cqtlimaxp.css({ 'width': '30px' }).attr('maxlength', '3').setMask("INTEGER", "zzz", ".", "");
        Cperdesconto.css({ 'width': '50px' }).setMask('DECIMAL', 'zz9,99', '.', '');
        Cinenvcob.css({ 'width': '155px' });
        if (Cinsitceb.val() == 1) {
            Cinsitceb.habilitaCampo();
        } else {
            Cinsitceb.desabilitaCampo();
        }

    } else if (nomeForm == 'frmHabilita') {

        var Lnrconven = $('label[for="nrconven"]', '#' + nomeForm);
        var Ldsorgarq = $('label[for="dsorgarq"]', '#' + nomeForm);

        var Cnrconven = $('#nrconven', '#' + nomeForm);
        var Cdsorgarq = $('#dsorgarq', '#' + nomeForm);

        $('#' + nomeForm).addClass('formulario');

        Lnrconven.addClass('rotulo').css('width', '210px');
        Ldsorgarq.addClass('rotulo').css('width', '210px');

        Cnrconven.addClass('pesquisa').css({ 'width': '66px' }).attr('maxlength', '8').setMask("INTEGER", "zzzzz.zz9", ".", "");
        Cdsorgarq.css({ 'width': '150px', 'background-color': 'F3F3F3', 'font-size': '11px', 'padding': '2px 4px 1px 4px' });

        Cnrconven.unbind('keydown').bind('keydown', function (e) {
            if (divError.css('display') == 'block') { return false; }
            if (e.keyCode == 118) {
                pesquisaConvenio();
            }
        });


    } else if (nomeForm == 'divConveniosRegistros') {

        var divRegistro = $('div.divRegistros', '#' + nomeForm);
        var tabela = $('table', divRegistro);

        divRegistro.css('min-height', '65px');
        divRegistro.css('height', 'auto');
        divRegistro.css('overflow-y', 'auto');

        var ordemInicial = new Array();

        var arrayLargura = new Array();
        arrayLargura[0] = '330px';


        var arrayAlinha = new Array();
        arrayAlinha[0] = 'left';
        arrayAlinha[1] = 'center';

        tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

        $('tbody > tr', tabela).each(function () {
            if ($(this).hasClass('corSelecao')) {
                $(this).focus();
            }
        });

        ajustarCentralizacao();

    } else if (nomeForm == 'divResultado') {

        var divRegistro = $('div.divRegistros', '#' + nomeForm);
        var tabela = $('table', divRegistro);

        tabela.zebraTabela(0);

        $('#' + nomeForm).css('width', '850px');
        divRegistro.css('height', '365px');

        var ordemInicial = new Array();

        var arrayLargura = new Array();
        arrayLargura[0] = '104px';
        arrayLargura[1] = '104px';
        arrayLargura[2] = '104px';
        arrayLargura[3] = '104px';
        arrayLargura[4] = '104px';
        arrayLargura[5] = '104px';
        arrayLargura[6] = '104px';


        var arrayAlinha = new Array();
        arrayAlinha[0] = 'left';
        arrayAlinha[1] = 'left';
        arrayAlinha[2] = 'center';
        arrayAlinha[3] = 'center';
        arrayAlinha[4] = 'center';
        arrayAlinha[5] = 'center';
        arrayAlinha[6] = 'center';

        tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

        $('tbody > tr', tabela).each(function () {
            if ($(this).hasClass('corSelecao')) {
                $(this).focus();
            }
        });

        // complemento
        var complemento = $('ul.complemento');

        $('li:eq(0)', complemento).addClass('txtNormalBold');
        $('li:eq(1)', complemento).addClass('txtNormal').css({ 'width': '35%' });
        $('li:eq(2)', complemento).addClass('txtNormalBold');
        $('li:eq(3)', complemento).addClass('txtNormal').css({ 'width': '40%' });

        ajustarCentralizacao();

    } else if (nomeForm == 'frmServSMS') {



        var Ltpnommis_razao = $('label[for="tpnommis_razao"]', '#' + nomeForm);
        var Ltpnommis_fansia = $('label[for="tpnommis_fansia"]', '#' + nomeForm);
        var Ltpnommis_outro = $('label[for="tpnommis_outro"]', '#' + nomeForm);
        var Lnmprimtl = $('label[for="nmprimtl"]', '#' + nomeForm);
        var Lnmfansia = $('label[for="nmfansia"]', '#' + nomeForm);
        var Lnmemisms = $('label[for="nmemisms"]', '#' + nomeForm);

        var Ldspacote = $('label[for="dspacote"]', '#' + nomeForm);
        var Ldhadesao = $('label[for="dhadesao"]', '#' + nomeForm);
        var Lidcontrato = $('label[for="idcontrato"]', '#' + nomeForm);
        var Ldssituac = $('label[for="dssituac"]', '#' + nomeForm);
        var Lvltarifa = $('label[for="vltarifa"]', '#' + nomeForm);

        var Ccddopcao = $('#cddopcao', '#' + nomeForm);
        var Ctpnommis_razao = $('#tpnommis_razao', '#' + nomeForm);
        var Ctpnommis_fansia = $('#tpnommis_fansia', '#' + nomeForm);
        var Ctpnommis_outro = $('#tpnommis_outro', '#' + nomeForm);
        var Cnmprimtl = $('#nmprimtl', '#' + nomeForm);
        var Cnmfansia = $('#nmfansia', '#' + nomeForm);
        var Cnmemisms = $('#nmemisms', '#' + nomeForm);

        var Cdspacote = $('#dspacote', '#' + nomeForm);
        var Cdhadesao = $('#dhadesao', '#' + nomeForm);
        var Cidcontrato = $('#idcontrato', '#' + nomeForm);
        var Cvltarifa = $('#vltarifa', '#' + nomeForm);
        var Cdssituac = $('#dssituac', '#' + nomeForm);

        var cqtsmspct = $('#qtsmspct', '#' + nomeForm);
        var cqtsmsusd = $('#qtsmsusd', '#' + nomeForm);

        $('#' + nomeForm).addClass('formulario');

        //Remetente
        Ltpnommis_razao.addClass('rotulo-linha').css('width', '90px');
        Ltpnommis_fansia.addClass('rotulo-linha').css('width', '90px');
        Ltpnommis_outro.addClass('rotulo-linha').css('width', '90px');
        Cnmprimtl.addClass('campo').css('width', '200px').desabilitaCampo();
        Cnmfansia.addClass('campo').css('width', '200px').desabilitaCampo();
        Cnmemisms.addClass('campo').css('width', '200px').setMask("STRING", "15", charPermitido(), "");


        //Pacote
        Ldspacote.addClass('rotulo').css('width', '100');
        Ldhadesao.addClass('rotulo-linha').css('width', '80px');

        Lvltarifa.addClass('rotulo').css('width', '100');
        Lidcontrato.addClass('rotulo-linha').css('width', '60px');
        Ldssituac.addClass('rotulo-linha').css('width', '80px');

        Cdspacote.addClass('campo').css('width', '170px').desabilitaCampo();
        Cdhadesao.addClass('campo').css('width', '70px').desabilitaCampo();
        cqtsmspct.desabilitaCampo();
        cqtsmsusd.desabilitaCampo();

        Cvltarifa.addClass('campo').css('width', '40px').desabilitaCampo();
        Cidcontrato.addClass('campo').css('width', '65px').desabilitaCampo();
        Cdssituac.addClass('campo').css('width', '70px').desabilitaCampo();

        // Se estiver com opcao cancelado ou consultando inativo, desabilitar campos
        if (Ccddopcao.val() == 'CA' ||
            Ccddopcao.val() == 'CI') {

            Ctpnommis_razao.desabilitaCampo();
            Ctpnommis_fansia.desabilitaCampo();
            Ctpnommis_outro.desabilitaCampo();

            $('#btCancelServSMS').trocaClass('botao', 'botaoDesativado').css('cursor', 'default').attr("onClick", "return false;");;
            $('#btImpCtrSMS').trocaClass('botao', 'botaoDesativado').css('cursor', 'default').attr("onClick", "return false;");;
            $('#btnAltRemSMS').trocaClass('botao', 'botaoDesativado').css('cursor', 'default').attr("onClick", "return false;");;

        }

        if (Ctpnommis_outro.prop("checked") == true) {
            Cnmemisms.habilitaCampo();
        } else {
            Cnmemisms.desabilitaCampo();
        }



    } else if (nomeForm == 'frmLogConv') {
        formataLogConv();
    } else if (nomeForm == 'frmLogNegociacao') {
        formataLogNegociacao();
    }

    callafterCobranca = '';
    controlaPesquisas();
    layoutPadrao();
    return false;
}

function controlaPesquisas() {

    /*--------------------*/
    /*  CONTROLE CONVENIO */
    /*--------------------*/
    var linkConvenio = $('#linkLupa', '#frmConsulta');

    if (linkConvenio.prev().hasClass('campoTelaSemBorda')) {
        linkConvenio.addClass('lupa').css('cursor', 'auto').unbind('click').bind('click', function () { return false; });
    } else {
        linkConvenio.css('cursor', 'pointer').unbind('click').bind('click', function () {
            pesquisaConvenio();
        });
    }

    // Convenio
    $('#nrconven', '#frmConsulta').unbind('change').bind('change', function () {
        buscaDescricaoConvenio($(this).attr('name'), $(this).val())
    });

    return false;
}

function buscaDescricaoConvenio(campoCodigo, valorCodigo) {
    var bo = 'b1wgen0059.p';
    var procedure = 'busca_convenios';
    var titulo = 'Conv&ecirc;nios';
    var filtrosDesc = '';
    buscaDescricao(bo, procedure, titulo, campoCodigo, 'dsorgarq', normalizaNumero(valorCodigo), 'dsorgarq', filtrosDesc, 'frmConsulta');
    return false;
}


// Perguntar se quer fazer a impressao do termo
function confirmaImpressaoCancelamento(flgregis, callafterFnc) {

    imprimeRelatorio();

    var callafterCobranca, nmrotina;

    if (!callafterFnc) {
        callafterCobranca = 'blockBackground(parseInt($("#divRotina").css("z-index")));';

        callafterCobranca += (executandoProdutos) ? 'encerraRotina();' : 'realizaExclusao(1);';

        // parametros são recebidos quando é relacionado ao protesto
    } else {
        callafterCobranca = callafterFnc;

        nmrotina = "imprimirTermoCancelamentoProtesto";
    }

    aux_mensagem = "Deseja efetuar impress&atilde;o do termo de cancelamento ?"; // Mensagem de confirmacao de impressao;

    showConfirmacao(aux_mensagem,
					'Confirma&ccedil;&atilde;o - Ayllos',
					'testemunhasCancelamento("' + flgregis + '", "' + nmrotina + '");blockBackground(parseInt($("#divRotina").css("z-index")));',
					callafterCobranca,
					'sim.gif',
					'nao.gif');
}

function testemunhasCancelamento(flgregis, pNmrotina) {

    var nmrotina = pNmrotina ? pNmrotina : "imprimirTermoCancelamento";

    // Carrega conteúdo da opção através do Ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/dda/testemunhas.php',
        data: {
            nmrotina: nmrotina,
            flgregis: flgregis,
            redirect: 'ajax_html'
        },
        error: function (objAjax, responseError, objExcept) {
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function (response) {

            // Numero do convenio e o termo de cancelamento
            nrconven_imprimir = normalizaNumero($("#nrconven", "#divConteudoOpcao").val());
            tpdtermo_imprimir = 2;// Imprimir termo de cancelamento
            if (pNmrotina != "imprimirTermoCancelamento") {
                tpdtermo_imprimir = 3;// Imprimir termo de cancelamento de protesto
            }

            $("#divOpcaoIncluiAltera").css({ 'display': 'none' });
            $("#divOpcaoConsulta").css({ 'display': 'none' });
            $("#divTestemunhas").html(response);

        }
    });
}

// Funcao para acessar opcoes da rotina
function acessaAba(id, cddopcao) {
    // Converte para inteiro
    id = parseInt(id);

    // Esconde as abas
    $('.clsAbas', '#frmConsulta').hide();

    // Mostra a aba
    $("#divAba" + id).show();

    // Mostra botao continuar
    $("#btnContinuar").show();

    var cddbanco = $("#cco_cddbanco", "#frmConsulta").val();
    // Removido esta forma de atribuir pois não funciona com modo de compatibilidade
    //var linkContinuar = 'acessaAba(' + (id + 1) + ',\'' + cddopcao + '\');';
    //var linkContinua2 = 'validaDadosLimites(\'true\',\'\',\'' + cddopcao + '\');';
    //var linkVoltar  = 'acessaOpcaoContratos();';
    //var linkVoltar2 = 'acessaAba(' + (id - 1) + ',\'' + cddopcao + '\');';
    var linkContinuar = 1;
    var linkVoltar = 1;

    // Se foi clicado para acessar a segunda aba
    if (id == 1) {
        linkContinuar = 2;
        linkVoltar = 2;
        regraExibicaoCategoria(cddopcao);
        // Se for consulta
        if (cddopcao == 'C') {
            $("#btnContinuar").hide();
        }
    } else if (cddbanco != 85) { // Se NAO for CECRED NAO vai para a segunda tela
        linkContinuar = 2;
    }

    if (linkContinuar == 1) {
        $("#btnContinuar", "#divOpcaoConsulta").click(function () { atualizarConvenios(cddopcao); });
        document.getElementById("btVoltar").onclick = function () { acessaOpcaoContratos(); }
        document.getElementById('btSair').onclick = function () { acessaOpcaoContratos(); }
    } else if (linkContinuar == 2) {
        $("#btnContinuar", "#divOpcaoConsulta").click(function () { validaDadosLimites('true', '', cddopcao); });
        document.getElementById("btVoltar").onclick = function () { acessaOpcaoContratos(); }
        document.getElementById('btSair').onclick = function () { voltarParaDesconto(); }
    }

    // Removido esta forma de atribuir pois não funciona com modo de compatibilidade
    //$("#btnContinuar").attr("onclick",linkContinuar);
    //$("#btVoltar").attr("onClick",linkVoltar);
    return false;
}


function atualizarConvenios(cddopcao) {
    var flcooexp = ($("#flcooexp", "#frmConsulta").prop("checked") == true) ? 1 : 0;
    var flceeexp = ($("#flceeexp", "#frmConsulta").prop("checked") == true) ? 1 : 0;
    var qtlimmip_val = $("#qtlimmip", "#frmConsulta").val();
    var qtlimaxp_val = $("#qtlimaxp", "#frmConsulta").val();
    var qtbolcob = $("#qtbolcob", "#frmConsulta").val();

    if (flcooexp == 0 && flceeexp == 0) {
        showError("error", "Campo Cooperativa Emite e Expede ou Cooperado Emite e Expede devem ser preenchidos", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')));");
        return false;
    }
    if (parseInt(qtlimaxp_val) < parseInt(qtlimmip_val)) {
        showError("error", "Data maxima de Intervalo de Protesto nao pode ser menor que data minima.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')));");
        return false;
    }

    var nrconven = normalizaNumero($("#nrconven", "#divOpcaoConsulta").val());
    var dsorgarq = $("#dsorgarq", "#divOpcaoConsulta").val();
    var insitceb = $("#insitceb", "#divOpcaoConsulta").val();
    var flgregon = $("#flgregon", "#divOpcaoConsulta").val();
    var flgpgdiv = $("#flgpgdiv", "#divOpcaoConsulta").val();
    var flcooexp = $("#flcooexp", "#divOpcaoConsulta").val();
    var flceeexp = $("#flceeexp", "#divOpcaoConsulta").val();
    var qtdfloat = $("#qtdfloat", "#divOpcaoConsulta").val();
    var flserasa = $("#flserasa", "#divOpcaoConsulta").val();
    var flprotes = $("#flprotes", "#divOpcaoConsulta").val();
    var insrvprt = $("#insrvprt", "#divOpcaoConsulta").val();
    var qtlimmip = $("#qtlimmip", "#divOpcaoConsulta").val();
    var qtlimaxp = $("#qtlimaxp", "#divOpcaoConsulta").val();
    var qtdecprz = $("#qtdecprz", "#divOpcaoConsulta").val();
    var inarqcbr = $("#inarqcbr", "#divOpcaoConsulta").val();
    var inenvcob = $("#inenvcob", "#divOpcaoConsulta").val();
    var cddemail = $("#dsdemail", "#divOpcaoConsulta").val();
    var divCnvHomol = $("#divCnvHomol", "#divOpcaoConsulta").val();
    var flgcebhm = $("#flgcebhm", "#divOpcaoConsulta").val();
    var flgapihm = $("#flgapihm", "#divOpcaoConsulta").val();

    var index = null;

    index = retornaIndice(descontoConvenios, 'convenio', nrconven);

    if (index == null)
        return false;

    if ($("#flgregon", "#divOpcaoConsulta").prop("checked") == true) {
        flgregon = 1;
    } else {
        flgregon = 0;
    }
    if ($("#flgpgdiv", "#divOpcaoConsulta").prop("checked") == true) {
        flgpgdiv = 1;
    } else {
        flgpgdiv = 0;
    }
    if ($("#flcooexp", "#divOpcaoConsulta").prop("checked") == true) {
        flcooexp = 1;
    } else {
        flcooexp = 0;
    }
    if ($("#flceeexp", "#divOpcaoConsulta").prop("checked") == true) {
        flceeexp = 1;
    } else {
        flceeexp = 0;
    }
    if ($("#flserasa", "#divOpcaoConsulta").prop("checked") == true) {
        flserasa = 1;
    } else {
        flserasa = 0;
    }
    if ($("#flprotes", "#divOpcaoConsulta").prop("checked") == true) {
        flprotes = 1;
    } else {
        flprotes = 0;
    }
    if ($("#flgcebhm", "#divOpcaoConsulta").val() == 'yes') {
        flgcebhm = 1;
    } else {
        flgcebhm = 0;
    }
    if ($("#flgapihm", "#divOpcaoConsulta").val() == 'yes') {
        flgapihm = 1;
    } else {
        flgapihm = 0;
    }

    var convenio = {
        convenio: nrconven,
        tipo: dsorgarq,
        insitceb: insitceb,
        flgregon: flgregon,
        flgpgdiv: flgpgdiv,
        flcooexp: flcooexp,
        flceeexp: flceeexp,
        qtdfloat: "",
        flserasa: flserasa,
        flprotes: flprotes,
        insrvprt: insrvprt,
        qtlimmip: qtlimmip,
        qtlimaxp: qtlimaxp,
        qtdecprz: qtdecprz,
        inarqcbr: inarqcbr,
        inenvcob: inenvcob,
        cddemail: cddemail,
        divCnvHomol: divCnvHomol,
        flgcebhm: flgcebhm,
        qtbolcob: qtbolcob,
        flgapihm: flgapihm
    };


    descontoConvenios[index] = convenio;
    validaEmiteExpede(true);
    sairDescontoConvenio();
    calcula_desconto();
}

// Funcao para ocultar/exibir as categorias
function regraExibicaoCategoria(cddopcao) {
    var flcooexp = ($("#flcooexp", "#frmConsulta").prop("checked") == true) ? 1 : 0;
    var flceeexp = ($("#flceeexp", "#frmConsulta").prop("checked") == true) ? 1 : 0;

    $("#tabSgrCat > tbody  > tr").each(function () {
        var dados = $(this).attr("id").split('_');
        var flcatcoo = dados[1];
        var flcatcee = dados[2];
        $('#' + $(this).attr("id")).show(); // Exibe
        if ((flcatcoo == 1 && flcooexp == 0) ||
            (flcatcee == 1 && flceeexp == 0)) {
            $('#' + $(this).attr("id")).hide(); // Oculta
        }
    });

    return false;
}

// Valida o percentual digitado
function validaPerDesconto(ind_lincampo, cco_perdctmx, cat_dscatego) {
    vlr_desconto = converteMoedaFloat($('#perdesconto_' + ind_lincampo, '#frmConsulta').val());
    cco_perdctmx = converteMoedaFloat(cco_perdctmx);
    // Se valor digitado for maior que maximo permitido
    if (vlr_desconto > cco_perdctmx) {
        $('#perdesconto_' + ind_lincampo, '#frmConsulta').val('');
        showError("error", "%Desconto informado para o " + cat_dscatego + " superior ao % M&aacute;ximo permitido no Conv&ecirc;nio! Favor corrigir!", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')));");
        return false;
    }
}

// Chamada de rotina externa de acompanhamento
function abrirReciprocidadeAcompanhamento() {

    showMsgAguardo('Aguarde, carregando ...');

    exibeRotina($('#divUsoGenerico'));

    var nrconven = normalizaNumero($("#nrconven", "#frmConsulta").val());

    // Carrega conteúdo da opção através do Ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/recipr/recipr.php',
        data: {
            glb_nrdconta: nrdconta,
            glb_nrconven: nrconven,
            glb_nmrotina: 'cobranca',
            redirect: 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function (response) {
            $('#divUsoGenerico').html(response);
            layoutPadrao();
            hideMsgAguardo();
            bloqueiaFundo($('#divUsoGenerico'));
            //$("#divUsoGenerico").setCenterPosition();
        }
    });
}

// Chamada de rotina externa de calculo
function abrirReciprocidadeCalculo() {

    showMsgAguardo('Aguarde, carregando ...');

    exibeRotina($('#divUsoGenerico'));

    var cddopcao = $('#cddopcao', '#frmConsulta').val();
    var idrecipr = $('#idrecipr', '#frmConsulta').val();
    var idprmrec = $('#idprmrec', '#frmConsulta').val();

    // Carrega conteúdo da opção através do Ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/simcrp/simcrp.php',
        data: {
            modo: cddopcao,
            nrdconta: nrdconta,
            idcalculo_reciproci: idrecipr,
            idparame_reciproci: idprmrec,
            cp_idcalculo: 'glb_idreciproci',
            cp_totaldesconto: 'glb_perdesconto',
            cp_desmensagem: 'glb_desmensagem',
            executafuncao: 'executaReciprocidadeCalculo();',
            divanterior: 'divRotina',
            redirect: 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function (response) {
            $('#divUsoGenerico').html(response);
            $('#divUsoGenerico').css({ 'left': '340px', 'top': '91px' });
            layoutPadrao();
            hideMsgAguardo();
            bloqueiaFundo($('#divUsoGenerico'));
        }
    });
}

function executaReciprocidadeCalculo() {


    var cddopcao = $('#cddopcao', '#frmConsulta').val();
    var idreciprold = $('#idreciprold', '#frmConsulta').val();
    var glb_idreciproci = normalizaNumero($('#glb_idreciproci', '#frmConsulta').val());
    var glb_perdesconto = converteMoedaFloat($('#glb_perdesconto', '#frmConsulta').val());
    var glb_desmensagem = $('#glb_desmensagem', '#frmConsulta').val(); // OK/NOK

    // Se retornou erro ou sem ID de Reciprocidade
    if (glb_desmensagem != 'OK' || glb_idreciproci == 0) {
        showError("error", "Aten&ccedil;&atilde;o: Erro na chamada da tela! Configura&ccedil;&atilde;o da Reciprocidade n&atilde;o retornada!", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')));");
        return false;
        // Se possuir desconto
    } else if (glb_perdesconto > 0) {

        // Se for Alteracao e ID de Reciprocidade Novo seja diferente do Antigo
        if (cddopcao == 'A' &&
            idreciprold != glb_idreciproci &&
            idreciprold > 0) {

            // Solicitamos confirmação do operador, em caso de cancelamento retornaremos ao calculo antigo.
            showConfirmacao("Aten&ccedil;&atilde;o: Qualquer altera&ccedil;&atilde;o na Reciprocidade acarretar&aacute; no cancelamento do per&iacute;odo de apura&ccedil;&atilde;o atual!", 'Confirma&ccedil;&atilde;o - Ayllos', ' aplicaCalculoReciproci()', ' reverteCalculoOld()', 'continuar.gif', 'cancelar.gif');

        } else {

            // Novo calculo, ou não existia o anterior, então sempre chamaremos a aplicação do calculo
            aplicaCalculoReciproci();
        }

    }

}

// Funcao para aplicar os descontos de reciprocidade calculada
function aplicaCalculoReciproci() {
    // Buscar valores do novo cálculo novamente
    var glb_perdesconto = converteMoedaFloat($('#glb_perdesconto', '#frmConsulta').val());
    var glb_idreciproci = normalizaNumero($('#glb_idreciproci', '#frmConsulta').val());

    // Utilizar somente o valor máximo
    var perdesconto_maximo_recipro = converteMoedaFloat($('#perdesconto_maximo_recipro', '#frmConsulta').val());
    var perdesconto_recipro = (perdesconto_maximo_recipro < glb_perdesconto ? perdesconto_maximo_recipro : glb_perdesconto);

    // Seta o ID da nova Reciprocidade
    $('#idrecipr', '#frmConsulta').val(glb_idreciproci);

    // Acumular total desconto
    var tot_perdesconto = 0;

    // Preencher apenas os campos que possuem CAT.flrecipr = 1
    $(".clsCatFlrecipr1").each(function (index) {
        $(this).val(number_format(perdesconto_recipro, 2, ',', '.'));
        tot_perdesconto = tot_perdesconto + perdesconto_recipro;
    });

    // Guardar o valor total do cálculo atualizando o valor que veio do banco
    $('#tot_percdesc_recipr', '#frmConsulta').val(tot_perdesconto);

}

// Funcao para reverter o calculo não confirmado
function reverteCalculoReciproci() {
    // Retornaremos o id do calculo anterior, pois o operador não confirmou a alteração
    $('#idrecipr', '#frmConsulta').val($('#idreciprold', '#frmConsulta').val());
}

// Funcao de senha do coordenador caso seja necessario
function verificaSenhaCoordenador() {
    var flsolicita = false;
    var flgapvco = normalizaNumero($('#flgapvco', '#frmConsulta').val());

    // Somente se for necessario solicitar aprovação
    if (flgapvco == 1) {
        var tot_percdesc = $('#tot_percdesc', '#frmConsulta').val();
        var tot_percdesc_recipr = $('#tot_percdesc_recipr', '#frmConsulta').val();

        // Acumular categorias conforme reciprocidade ou não
        var tot_percdesc_campo = 0;
        $(".clsCatFlrecipr0").each(function (index) {
            tot_percdesc_campo = tot_percdesc_campo + converteMoedaFloat($(this).val());
        });
        var tot_percdesc_recipr_campo = 0;
        $(".clsCatFlrecipr1").each(function (index) {
            tot_percdesc_recipr_campo = tot_percdesc_recipr_campo + converteMoedaFloat($(this).val());
        });

        // Se foi alterado o valor de descontos manuais ou de Reciprocidade
        if (tot_percdesc_campo != tot_percdesc || tot_percdesc_recipr_campo != tot_percdesc_recipr) {
            flsolicita = true;
        }

    }
    // Se for necessário solicitar senha do coordenador
    if (flsolicita) {
        pedeSenhaCoordenador(2, 'realizaHabilitacao();', 'divRotina');
    } else {
        realizaHabilitacao();
    }
}

function gera_ajuda() {
    showMsgAguardo('Aguarde, gerando ...');
    // Carrega conteúdo da opção através de ajax
    var UrlOperacao = UrlSite + "telas/atenda/reciprocidade/gera_ajuda.php";
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlOperacao,
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            hideMsgAguardo();
            if (response.substr(0, 4) == "hide") {
                eval(response);
            } else {
                geraImpressao(response);
            }
            return false;
        }
    });
}

function geraImpressao(arquivo) {

    $('#nmarquiv', '#frmImprimir').val(arquivo);

    var action = UrlSite + 'telas/atenda/reciprocidade/imprimir_ajuda.php';

    carregaImpressaoAyllos("frmImprimir", action, "bloqueiaFundo(divRotina);");
}

function ativarConvenio(nrconven, confirm) {
    if (confirm) {
        showConfirmacao("Deseja ativar este conv&ecirc;nio?", 'Confirma&ccedil;&atilde;o - Ayllos', 'ativarConvenio(' + nrconven + ', false)', ' blockBackground(parseInt($("#divRotina").css("z-index")))', 'sim.gif', 'nao.gif');
        return;
    }

    var idx = retornaIndice(descontoConvenios, 'convenio', nrconven);

    descontoConvenios[idx].insitceb = 1;

    sairDescontoConvenio();
    return;

    /*var nrconven = $("#nrconven", "#divConteudoOpcao").val();
    var nrcnvceb = $("#nrcnvceb", "#divConteudoOpcao").val();
    var flgregis = $("#flgregis", "#divOpcaoConsulta").val();

	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, Ativando o conv&ecirc;nio ...");

	// Carrega conteúdo da opção através de ajax
	$.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/atenda/reciprocidade/ativar_convenio.php",
		data: {
		  	nrdconta: nrdconta,
			nrconven: nrconven,
			nrcnvceb: nrcnvceb,
            flgregis: flgregis,
			redirect: "script_ajax" // Tipo de retorno do ajax
		},
        error: function (objAjax, responseError, objExcept) {
			hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
			try {
				eval(response);
            } catch (error) {
				hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
			}
		}
	});*/

}

// Abrir tela de log ceb
function carregaLogCeb() {

    var idrecipr = $("#idrecipr", "#divConteudoOpcao").val();
    if (idrecipr == '') {
        hideMsgAguardo();
        showError("error", "Selecione um contrato.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
        return;
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando ...");

    // Carrega log atraves ajax
    $.ajax({

        dataType: "html",
        type: "POST",
        url: UrlSite + "telas/atenda/reciprocidade/log_convenio.php",
        data: {
            idrecipr: idrecipr,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {

            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function (response) {

            $("#divLogCeb").html(response);
            hideMsgAguardo();
            blockBackground($("#divRotina"));
        }
    });

}

// Abrir tela de log de negociaçao
function carregaLogNegociacao() {

    var idrecipr = $("#idrecipr", "#divConteudoOpcao").val();
    if (idrecipr == '') {
        hideMsgAguardo();
        showError("error", "Selecione um contrato.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
        return;
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando ...");

    // Carrega log atraves ajax
    $.ajax({

        dataType: "html",
        type: "POST",
        url: UrlSite + "telas/atenda/reciprocidade/log_negociacao.php",
        data: {
            idrecipr: idrecipr,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {

            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function (response) {

            $("#divLogNegociacao").html(response);
            hideMsgAguardo();
            blockBackground($("#divRotina"));
        }
    });

}

function formataLogConv() {

    var divRegistro = $('div.divRegistros', '#divRegLogCeb');
    var tabela = $('table', divRegistro);
    var tabelaHeader = $('table > thead > tr > th', divRegistro);
    var fonteLinha = $('table > tbody > tr > td', divRegistro);

    tabelaHeader.css({ 'font-size': '11px' });
    fonteLinha.css({ 'font-size': '11px' });

    $('fieldset').css({ 'clear': 'both', 'border': '1px solid #777', 'margin': '3px 0px', 'padding': '10px 3px 5px 3px' });
    $('fieldset > legend').css({ 'font-size': '11px', 'color': '#777', 'margin-left': '5px', 'padding': '0px 2px' });

    divRegistro.css('width', '640px');
    divRegistro.css('height', '250px');

    var ordemInicial = new Array();

    var arrayLargura = new Array();

    arrayLargura[0] = '105px';
    arrayLargura[1] = '434px';
    arrayLargura[2] = '100px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'left';

    var metodoTabela = '';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

    return false;
}

function formataLogNegociacao() {

    var divRegistro = $('div.divRegistros', '#divRegLogNegociacao');
    var tabela = $('table', divRegistro);
    var tabelaHeader = $('table > thead > tr > th', divRegistro);
    var fonteLinha = $('table > tbody > tr > td', divRegistro);

    tabelaHeader.css({ 'font-size': '11px' });
    fonteLinha.css({ 'font-size': '11px' });

    $('fieldset').css({ 'clear': 'both', 'border': '1px solid #777', 'margin': '3px 0px', 'padding': '10px 3px 5px 3px' });
    $('fieldset > legend').css({ 'font-size': '11px', 'color': '#777', 'margin-left': '5px', 'padding': '0px 2px' });

    divRegistro.css('width', '640px');
    divRegistro.css('height', '130px');

    var ordemInicial = new Array();

    var arrayLargura = new Array();

    arrayLargura[0] = '150px';
    arrayLargura[1] = '250px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'left';

    var metodoTabela = '';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

    return false;
}

function consultaServicoSMS(opcao) {


    var idseqttl = $("#idseqttl", "#divServSMS").val();
    var flimpctr = 0;
    var nmemisms = $("#nmemisms", "#divServSMS").val();
    var idcontrato = $("#idcontrato", "#divServSMS").val();
    var tpnmemis = 0;
    var idpacote = 0;

    if (opcao == 'AR') {
        // Mostra mensagem de aguardo
        showMsgAguardo("Aguarde, alterando remetente de envio de SMS ...");

        if ($("#tpnommis_razao", "#divServSMS").prop("checked") == true) {
            tpnmemis = 1;
        } else if ($("#tpnommis_fansia", "#divServSMS").prop("checked") == true) {
            tpnmemis = 2;
        } else if ($("#tpnommis_outro", "#divServSMS").prop("checked") == true) {
            tpnmemis = 3;
        }
    } else if (opcao == 'A') {
        idseqttl = idseqttl_senha_internet;
        if (possui_senha_internet == false) {
            flimpctr = 1;
        }
        if ($("#rdPacote").prop("checked")) {
            idpacote = grid.getRegistroSelecionado();
        }

        // Mostra mensagem de aguardo
        showMsgAguardo("Aguarde, ativando servi&ccedil;o de SMS ...");
    } else if (opcao == 'CA') {
        idseqttl = idseqttl_senha_internet;
        if (possui_senha_internet == false) {
            flimpctr = 1;
        }
        // Mostra mensagem de aguardo
        showMsgAguardo("Aguarde, cancelando servi&ccedil;o de SMS ...");
    } else if (opcao == 'IA') {
        // Mostra mensagem de aguardo
        showMsgAguardo("Aguarde, gerando Impress&atilde;o de contrato de servi&ccedil;o de SMS ...");
    } else {
        // Mostra mensagem de aguardo
        showMsgAguardo("Aguarde, carregando ...");
    }

    // Carrega conteudo da tela atraves de ajax
    $.ajax({
        dataType: "html",
        type: "POST",
        url: UrlSite + "telas/atenda/reciprocidade/consulta_servico_sms.php",
        data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            flimpctr: flimpctr,
            cddopcao: opcao,
            nmemisms: nmemisms,
            tpnmemis: tpnmemis,
            idcontrato: idcontrato,
            inpessoa: inpessoa,
            idpacote: idpacote,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function (response) {
            $("#divHabilita_SMS").hide();
            $("#divServSMS").html(response);
            $("#divServSMS").css("display", "block");
            hideMsgAguardo();
            blockBackground($("#divRotina"));
        }
    });

    return false;
}

function confirmaServSMS() {

    showConfirmacao('Deseja ativar servi&ccedil;o de SMS de Cobran&ccedil;a?', 'Confirma&ccedil;&atilde;o - Ayllos', 'verificaSenhaInternet("habilitarServSMS();", ' + nrdconta + ', 1);', ' acessaOpcaoContratos(); return false;', 'sim.gif', 'nao.gif');
}

function habilitarServSMS() {

    // Verificar se conta possui senha de internet
    if (possui_senha_internet) {
        $("#idseqttl", "#divServSMS").val(idseqttl_senha_internet);
    } else {
        $("#idseqttl", "#divServSMS").val(1);
    }

    consultaServicoSMS('A');
}

// Confirma Cancelamento de Servico
function confirmaCancelServSMS() {
    showConfirmacao('Ser&atilde;o canceladas todas as instru&ccedil;&otilde;es programadas para envio de SMS. Confirma cancelamento do servi&ccedil;o de SMS de Cobran&ccedil;a?', 'Confirma&ccedil;&atilde;o - Ayllos', 'verificaSenhaInternet("CancelarServSMS();", ' + nrdconta + ', 1);', 'return false;', 'sim.gif', 'nao.gif');
}
function CancelarServSMS() {
    consultaServicoSMS('CA');
}

// Função para carregar impressao de servico de SMS em PDF
function imprimirServSMS(cddopcao) {
    showMsgAguardo("Aguarde, gerando impress&atilde;o ...");
    var idcontrato = normalizaNumero($("#idcontrato", "#divServSMS").val());

    $("#nrdconta", "#frmImprimirSMS").val(nrdconta);
    $("#idcontrato", "#frmImprimirSMS").val(idcontrato);
    $("#cddopcao", "#frmImprimirSMS").val(cddopcao);

    var action = $("#frmImprimirSMS").attr("action");
    var callafter = "";

    carregaImpressaoAyllos("frmImprimirSMS", action, callafter);
}

// Confirma alteracao do remetente de envio de SMS
function confirmaAltReme() {

    var nmemisms = $("#nmemisms", "#divServSMS").val();
    var tpnmemis = 3;

    if ($("#tpnommis_razao", "#divServSMS").prop("checked") == true) {
        tpnmemis = 1;
    } else if ($("#tpnommis_fansia", "#divServSMS").prop("checked") == true) {
        tpnmemis = 2;
    } else if ($("#tpnommis_outro", "#divServSMS").prop("checked") == true) {
        tpnmemis = 3;
    }

    if (tpnmemis == 3 && nmemisms == "") {
        showError("error", 'Favor informe o nome para remetente ou marque outra op&ccedil;&atilde;o.', "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
        return false;
    }

    showConfirmacao('Confirma altera&ccedil;&atilde;o do remetente?', 'Confirma&ccedil;&atilde;o - Ayllos', 'consultaServicoSMS("AR")', 'return false;', 'sim.gif', 'nao.gif');
}

function habilitaOutro(flghabit) {
    Cnmemisms = $('#nmemisms', '#frmServSMS');

    if (flghabit == true) {
        Cnmemisms.habilitaCampo();
    } else {
        Cnmemisms.desabilitaCampo();
    }
}

// carrega a tela para habilitar SMS
function confirmarHabilitacaoSmsCobranca() {

    showConfirmacao('Deseja ativar servi&ccedil;o de SMS de Cobran&ccedil;a?'
                   , 'Confirma&ccedil;&atilde;o - Ayllos'
                   , 'exibirHabilitacaoSmsCobranca();'
                   , 'acessaOpcaoContratos();', 'sim.gif', 'nao.gif');
}

function exibirHabilitacaoSmsCobranca() {

    $.ajax({
        dataType: "html",
        type: "POST",
        url: UrlSite + "telas/atenda/reciprocidade/habilita_sms.php",
        data: {
            inpessoa: inpessoa,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function (response) {

            if (response.substr(0, 16).indexOf("hideMsgAguardo") > -1) {
                eval(response);
            } else {
                inicializarHabilitacaoSmsCobranca(response);
            }
        }
    });
}

var grid;
var habilitaSMS;

function inicializarHabilitacaoSmsCobranca(html) {

    $("#divOpcaoIncluiAltera").css("display", "none");
    $("#divTrocaPacote_SMS").css("display", "none");
    $("#divConteudoOpcao").css("display", "none");
    $("#divServSMS").css("display", "none");
    $("#divHabilita_SMS").css("display", "block");
    blockBackground(parseInt($("#divRotina").css("z-index")));
    $("#divHabilita_SMS").html(html);
    hideMsgAguardo();
    blockBackground($("#divRotina"));

    if (grid === undefined) {
        grid = new Grid();
    }

    if (habilitaSMS === undefined) {
        habilitaSMS = new HabilitaSMS();
    }

    //liga o evento
    $('input[type=radio][name=rdTipoPacote]').change(function () {
        if (this.value == 'Individual') {
            $("#gridPacotesHabilitar").css("display", "none");
        }
        else if (this.value == 'Pacote') {
            try {
                Grid.carregar(1);
            }
            catch (err) {
                grid = new Grid();
                Grid.carregar(1);
            }

        }
    });
}

function Grid() {

    var registroSelecionado;

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
        return $('#divPacotes > .divRegistros > table > tbody > tr');
    }

    Grid.formatar = function () {

        var divRegistro = $('div.divRegistros', '#divPacotes');
        var tabela = $('table', divRegistro);
        divRegistro.css({ 'height': '64px', 'width': '100%' });

        var tabelaHeader = $('table > thead > tr > th', divRegistro);
        var fonteLinha = $('table > tbody > tr > td', divRegistro);

        tabelaHeader.css({ 'font-size': '11px' });
        fonteLinha.css({ 'font-size': '11px' });

        var ordemInicial = new Array();
        ordemInicial = [[0, 0]];

        var arrayLargura = new Array();
        arrayLargura[0] = '60px';
        arrayLargura[1] = '200px';
        arrayLargura[2] = '90px';
        arrayLargura[3] = '90px';
        //arrayLargura[4] = '90px';
        /*arrayLargura[5] = '97px';*/

        var arrayAlinha = new Array();
        arrayAlinha[0] = 'center';
        arrayAlinha[1] = 'left';
        arrayAlinha[2] = 'center';
        arrayAlinha[3] = 'center';
        //arrayAlinha[4] = 'center';
        //arrayAlinha[5] = 'center';
        var metodoTabela = '';

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

    Grid.carregar = function (pagina, nmdiv) {

        $.ajax({
            type: "POST",
            async: false,
            dataType: 'html',
            url: UrlSite + "telas/atenda/reciprocidade/grid_pacotes_sms.php",
            data: {
                inpessoa: inpessoa,
                pagina: pagina,
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
                    hideMsgAguardo();
                    $('#divHabilita_SMS #gridPacotesHabilitar').css({ 'display': 'block' });
                    $('#divHabilita_SMS #gridPacotesHabilitar').html(response);
                    Grid.formatar();
                }
            }
        });
    }

}

function HabilitaSMS() {

    this.onContinuarClick = function () {

        var idpacote = 0;

        if ($("#rdPacote").prop("checked")) {
            idpacote = grid.getRegistroSelecionado();
        }

        $.ajax({
            type: "POST",
            async: false,
            dataType: 'html',
            url: UrlSite + "telas/atenda/reciprocidade/valida_contrato_sms.php",
            data: {
                nrdconta: nrdconta,
                idpacote: idpacote,
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
            }
        });
    }
}

function inativarConvenio(nrconven, confirm) {

    if (confirm) {
        showConfirmacao('Existem boletos cadastrados para este convenio CEB. Deseja inativar o conv&ecirc;nio?', 'Confirma&ccedil;&atilde;o - Ayllos', 'inativarConvenio(' + nrconven + ', false)', 'blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")))', 'sim.gif', 'nao.gif');
        return;
    }

    var idx = retornaIndice(descontoConvenios, 'convenio', nrconven);

    descontoConvenios[idx].insitceb = 2;

    blockBackground(parseInt($('#divRotina').css('z-index')));

    sairDescontoConvenio();

    //$('tr#convenio_' + descontoConvenios[idx].convenio);

    /*var idrecipr = $('#idcalculo_reciproci', '#divConteudoOpcao').val();

    $.ajax({
        type: "POST",
        dataType: 'html',
        url: UrlSite + "telas/atenda/reciprocidade/excluir_convenio.php",
        data: {
            nrdconta: nrdconta,
            nrconven: nrconven,
            idrecipr: idrecipr,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
        },
        beforeSend: function() {
            showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");
        },
        success: function(response) {
            eval(response);
        }
    });*/
}

function excluirConvenio(nrconven, confirm) {
    var idx = retornaIndice(descontoConvenios, 'convenio', nrconven);

    if (confirm) {
        showConfirmacao('Confirma a exclus&atilde;o do conv&ecirc;nio?', 'Confirma&ccedil;&atilde;o - Ayllos', 'excluirConvenio(' + nrconven + ', false)', 'blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")))', 'sim.gif', 'nao.gif');
        return;
    }
    // remove do array
    descontoConvenios.splice(idx, 1);

    var idxNovo = novosConvenios.indexOf(nrconven);
    if (i >= 0) {
        novosConvenios.splice(i, 1);
    }

    // remove tooltip
    $('#tooltip').hide();

    validaEmiteExpede(true);
    // atualizar tabela de convenios
    sairDescontoConvenio();
    calcula_desconto();
}

function validaEmiteExpede(limparCampos) {
    var cddopcao = $('#cddopcao').val();
    var vJustificativaDescOld = $('#txtjustificativa_old', '.tabelaDesconto').val();

    cee = false;
    cVldesconto_cee.desabilitaCampo();
    cDataFimAdicionalCee.desabilitaCampo();

    coo = false;
    cVldesconto_coo.desabilitaCampo();
    cDataFimAdicionalCoo.desabilitaCampo();

    cJustificativaDesc.desabilitaCampo();
    if (cddopcao && cddopcao == 'A' && vJustificativaDescOld) {
        cJustificativaDesc.habilitaCampo();
    }

    if (limparCampos) {
        if (sitflcee !== $("#flceeexp", "#divOpcaoConsulta").prop('checked')) {
            cVldesconto_cee.val('0,00');
            cDataFimAdicionalCee.val('');
            cJustificativaDesc.val('');
        }
        if (sitflcoo !== $("#flcooexp", "#divOpcaoConsulta").prop('checked')) {
            cVldesconto_coo.val('0,00');
            cDataFimAdicionalCoo.val('');
            cJustificativaDesc.val('');
        }
    }

    if (cddopcao == 'C')
        return;

    for (var i = 0, len = descontoConvenios.length; i < len; ++i) {
        if (descontoConvenios[i].flcooexp == 1) {
            coo = true;
            cVldesconto_coo.habilitaCampo();
            cDataFimAdicionalCoo.habilitaCampo();
        }
        if (descontoConvenios[i].flceeexp == 1) {
            cee = true;
            cVldesconto_cee.habilitaCampo();
            cDataFimAdicionalCee.habilitaCampo();
        }
    }
}

function converteNumero(numero) {
    return numero.replace('.', '').replace(',', '.');
}

function validaDados(pedeSenha) {
    vDataFimContrato = Number(cDataFimContrato.val());
    vVldesconto_cee = cVldesconto_cee.val();
    vVldesconto_coo = cVldesconto_coo.val();
    vDataFimAdicionalCee = Number(cDataFimAdicionalCee.find('option:selected').text());
    vDataFimAdicionalCoo = Number(cDataFimAdicionalCoo.find('option:selected').text());
    vJustificativaDesc = cJustificativaDesc.val();
    vQtdFloat = $('#qtdfloat', '.tabelaDesconto').val();
    vDebitoReajusteReciproci = $('#debito_reajuste_reciproci', '.tabelaDesconto').val();
    
    // valida se o campo Data fim do contrato está preenchido
    if (!vDataFimContrato) {
        showError("error", "Selecione um valor para a Data fim do contrato.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    if ((cee && vDataFimContrato < vDataFimAdicionalCee) || (coo && vDataFimContrato < vDataFimAdicionalCoo)) {
        showError("error", "Data fim do contrato n&atilde;o pode ser menor que a data do desconto adicional.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    if ((cee && Number(converteNumero(vVldesconto_cee)) && !vDataFimAdicionalCee) || (cee && !Number(converteNumero(vVldesconto_cee)) && vDataFimAdicionalCee)) {
        showError("error", "&Eacute; necess&aacute;rio preencher os dados de desconto adicional CEE.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    if ((coo && Number(converteNumero(vVldesconto_coo)) && !vDataFimAdicionalCoo) || (coo && !Number(converteNumero(vVldesconto_coo)) && vDataFimAdicionalCoo)) {
        showError("error", "&Eacute; necess&aacute;rio preencher os dados de desconto adicional COO.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    if ((vDataFimAdicionalCee || vDataFimAdicionalCoo || atualizacaoDesconto) && !vJustificativaDesc) {
        showError("error", "&Eacute; necess&aacute;rio informar o campo Justificativa desconto adicional.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }


    if ((vQtdFloat == 0 || vDebitoReajusteReciproci == 0) && !vJustificativaDesc) {
        showError("error", "&Eacute; necess&aacute;rio informar o campo Justificativa desconto adicional.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }

    coo = false;
    cee = false;
    ativo = false;

    var conveniosValidados = true;


    for (var i = 0, len = descontoConvenios.length; i < len; ++i) {
        // 'undefined' = novo / 0 = novo, 1 = ativo
        if (typeof descontoConvenios[i].insitceb === 'undefined' || descontoConvenios[i].insitceb == '1' || descontoConvenios[i].insitceb == '3' || descontoConvenios[i].insitceb == '0') {
            ativo = true;
        }
        if (descontoConvenios[i].flcooexp == 1 || descontoConvenios[i].flceeexp == 1) {
            if (descontoConvenios[i].flcooexp == 1) {
                coo = true;
            }
            if (descontoConvenios[i].flceeexp == 1) {
                cee = true;
            }
        } else {
            coo = false;
            cee = false;


            // Rafael Ferreira (Mouts) - INC0020100 - Situac 3
            // Valida se foi Editado e Salvo Todos os Convenios
            if (coo == false && cee == false) {
                if ((typeof descontoConvenios[i].cddemail  == "undefined") && (typeof descontoConvenios[i].qtdecprz == "undefined") ) {
                    conveniosValidados = false;
                }
            }

            break;
        }
    }


    if (descontoConvenios && !ativo) {
        showError("error", "&Eacute; necess&aacute;rio ter pelo menos um conv&ecirc;nio ativo.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }


    if (conveniosValidados == false) {
        showError("error", "Favor Editar e Salvar todos os conv&ecirc;nios.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')));");
        return;
    }

    if (coo == false && cee == false) {
        showError("error", "Campo Cooperativa Emite e Expede ou Cooperado Emite e Expede devem ser preenchidos em todos os conv&ecirc;nios.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')));");
        return;
    }

    // define se houve alteracao nos campos do contrato
    var houveAlteracao = false;
    var qtdaprov = parseInt($('#qtdaprov', '#divConteudoOpcao').val());

    if (idcalculo_reciproci) {
        $('#qtdboletos_liquidados,#valvolume_liquidacao,#qtdfloat,#vlaplicacoes,#vldeposito,#dtfimcontrato,#debito_reajuste_reciproci').each(function (key, elem) {
            var val = $(elem).val(),
                prevVal = $('#' + elem.id + '_old').val();

            if (prevVal != val) {
                houveAlteracao = true;
            }
        });
    }

    if (pedeSenha) {
        pedeSenhaCoordenador(2, 'incluiDesconto(true);', 'divRotina');
    } else {
        var msg = 'Confirma a atualiza&ccedil;&atilde;o do contrato?';
        if (houveAlteracao || !idcalculo_reciproci || novosConvenios.length || (qtdaprov && insitceb == '3')) {
            msg = 'Confirma a inclus&atilde;o do novo contrato?';
        }
        showConfirmacao(msg, 'Confirma&ccedil;&atilde;o - Ayllos', 'incluiDesconto(' + houveAlteracao + ')', 'blockBackground(parseInt($("#divRotina").css("z-index")))', 'sim.gif', 'nao.gif');
    }

}

function incluiDesconto(houveAlteracao) {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, salvando registro...");

    if (houveAlteracao || !idcalculo_reciproci || novosConvenios.length) {
        var url = UrlSite + "telas/atenda/reciprocidade/incluir_desconto.php";
    } else {
        var url = UrlSite + "telas/atenda/reciprocidade/alterar_desconto.php"
    }

    var dtfimadicional_coo = $('#dtfimadicional_coo', '.tabelaDesconto').val();
    var dtfimadicional_cee = $('#dtfimadicional_cee', '.tabelaDesconto').val();

    if (dtfimadicional_coo == "") {
        dtfimadicional_coo = 0;
    }
    if (dtfimadicional_cee == "") {
        dtfimadicional_cee = 0;
    }


    // Estas Validações apagam o campo de Justificativa caso haja alguma coisa escrita e não seja mais
    // necessário aprovar
    var descricaoJustificativaDesconto = vJustificativaDesc;
    if (parseInt($('#vldesconto_cee', '.tabelaDesconto').val() || 0) <= 0 && 
        parseInt($('#vldesconto_coo', '.tabelaDesconto').val() || 0) <= 0 &&
        parseInt($('#qtdfloat', '.tabelaDesconto').val() || 0) > 0 &&
        $('#debito_reajuste_reciproci', '.tabelaDesconto').val() > 0
        ) {
        descricaoJustificativaDesconto = "";
    }

    $.ajax({
        dataType: "html",
        type: "POST",
        url: url,
        data: {
            idcalculo_reciproci: idcalculo_reciproci,
            nrdconta: parseInt($('#nrdconta', '#frmCabAtenda').val().replace(/\W/g, '')),
            convenios: JSON.stringify(descontoConvenios),
            boletos_liquidados: $('#qtdboletos_liquidados', '.tabelaDesconto').val(),
            volume_liquidacao: $('#valvolume_liquidacao', '.tabelaDesconto').val(),
            qtdfloat: $('#qtdfloat', '.tabelaDesconto').val(),
            vlaplicacoes: $('#vlaplicacoes', '.tabelaDesconto').val(),
            vldeposito: $('#vldeposito', '.tabelaDesconto').val(),
            idvinculacao: $('#idvinculacao', '.tabelaDesconto').val(),
            dtfimcontrato: vDataFimContrato,
            flgdebito_reversao: $('#debito_reajuste_reciproci', '.tabelaDesconto').val(),
            vldesconto_coo: $('#vldesconto_coo', '.tabelaDesconto').val(),
            dtfimadicional_coo: parseInt(dtfimadicional_coo),
            vldesconto_cee: $('#vldesconto_cee', '.tabelaDesconto').val(),
            dtfimadicional_cee: parseInt(dtfimadicional_cee),
            txtjustificativa: descricaoJustificativaDesconto,
            perdesconto: JSON.stringify(perdescontos),
            vldescontoconcedido_coo: $('#vldescontoconcedido_coo', '.tabelaDesconto').val(),
            vldescontoconcedido_cee: $('#vldescontoconcedido_cee', '.tabelaDesconto').val(),
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function (response) {
            hideMsgAguardo();
            eval(response);
        }
    });

    return true;
}

function validaHabilitacaoCamposBtn(cddopcao) {
    if (cddopcao && cddopcao == 'C') {
        return;
    }
    var btnContinuar = $('#btnContinuar');
    var btnAprovacao = $('#btnAprovacao');

    var cVldesconto_cee = $('#vldesconto_cee', '.tabelaDesconto');
    var cVldesconto_ceeOld = $('#vldesconto_cee_old', '.tabelaDesconto');
    var cVldesconto_coo = $('#vldesconto_coo', '.tabelaDesconto');
    var cVldesconto_cooOld = $('#vldesconto_coo_old', '.tabelaDesconto');
    var cDataFimAdicionalCee = $('#dtfimadicional_cee', '.tabelaDesconto');
    var cDataFimAdicionalCeeOld = $('#dtfimadicional_cee_old', '.tabelaDesconto');
    var cDataFimAdicionalCoo = $('#dtfimadicional_coo', '.tabelaDesconto');
    var cDataFimAdicionalCooOld = $('#dtfimadicional_coo_old', '.tabelaDesconto');
    var cJustificativaDesc = $('#txtjustificativa', '.tabelaDesconto');
    var cJustificativaDescOld = $('#txtjustificativa_old', '.tabelaDesconto');
    var cQtdFloatOld = $('#qtdfloat_old', '.tabelaDesconto');
    var cQtdFloat = $('#qtdfloat', '.tabelaDesconto');
    var cDebitoReajusteReciprociOld = $('#debito_reajuste_reciproci_old', '.tabelaDesconto');
    var cDebitoReajusteReciproci = $('#debito_reajuste_reciproci', '.tabelaDesconto');

    

    var vVldesconto_cee = Number(converteNumero(cVldesconto_cee.val()));
    var vVldesconto_ceeOld = Number(converteNumero(cVldesconto_ceeOld.val()));
    var vVldesconto_coo = Number(converteNumero(cVldesconto_coo.val()));
    var vVldesconto_cooOld = Number(converteNumero(cVldesconto_cooOld.val()));
    var vDataFimAdicionalCee = cDataFimAdicionalCee.find('option:selected').text();
    var vDataFimAdicionalCeeOld = cDataFimAdicionalCeeOld.val();
    var vDataFimAdicionalCoo = cDataFimAdicionalCoo.find('option:selected').text();
    var vDataFimAdicionalCooOld = cDataFimAdicionalCooOld.val();
    var vJustificativaDesc = cJustificativaDesc.val();
    var vJustificativaDescOld = cJustificativaDescOld.val();
    var vQtdFloatOld = cQtdFloatOld.val();
    var vQtdFloat = cQtdFloat.val();
    var vDebitoReajusteReciprociOld = cDebitoReajusteReciprociOld.val();
    var vDebitoReajusteReciproci = cDebitoReajusteReciproci.val();


    if (!cee && !coo) {
        cJustificativaDesc.desabilitaCampo();
    }

    if (cee) {
        if (!coo) {
            cVldesconto_coo.desabilitaCampo();
            cDataFimAdicionalCoo.desabilitaCampo();
        }
        cVldesconto_cee.habilitaCampo();
        cDataFimAdicionalCee.habilitaCampo();
    }

    if (coo) {
        if (!cee) {
            cVldesconto_cee.desabilitaCampo();
            cDataFimAdicionalCee.desabilitaCampo();
        }
        cVldesconto_coo.habilitaCampo();
        cDataFimAdicionalCoo.habilitaCampo();
    }

    if ((vVldesconto_cee != vVldesconto_ceeOld && vVldesconto_cee) ||
			(vVldesconto_coo != vVldesconto_cooOld && vVldesconto_coo) ||
			(vDataFimAdicionalCee != vDataFimAdicionalCeeOld && vDataFimAdicionalCee) ||
			(vDataFimAdicionalCoo != vDataFimAdicionalCooOld && vDataFimAdicionalCoo) ||
            (vJustificativaDesc != vJustificativaDescOld && vJustificativaDesc && vJustificativaDescOld) ||
            (atualizacaoDesconto) || 
            (vQtdFloat == 0 && (vQtdFloat != vQtdFloatOld) ) ||
            (vDebitoReajusteReciproci == 0 && (vDebitoReajusteReciproci != vDebitoReajusteReciprociOld)) ) {

        btnContinuar.removeClass('botaoDesativado').addClass('botaoDesativado');
        btnContinuar.prop('disabled', true);
        btnContinuar.attr('onclick', 'return false;');

        btnAprovacao.removeClass('botaoDesativado');
        btnAprovacao.prop('disabled', false);
        btnAprovacao.attr('onclick', 'solicitarAprovacao();return false;');

        cJustificativaDesc.habilitaCampo();
    } else {
        btnContinuar.removeClass('botaoDesativado');
        btnContinuar.prop('disabled', false);
        btnContinuar.attr('onclick', 'validaDados(false);return false;');

        btnAprovacao.removeClass('botaoDesativado').addClass('botaoDesativado');
        btnAprovacao.prop('disabled', true);
        btnAprovacao.attr('onclick', 'return false;');

        if (cddopcao && cddopcao == 'A' && vJustificativaDescOld && (vDataFimAdicionalCee || vDataFimAdicionalCoo || vVldesconto_coo || vVldesconto_cee)) {
            cJustificativaDesc.habilitaCampo();
        } else {
            cJustificativaDesc.desabilitaCampo();
        }
    }

}

function solicitarAprovacao() {
    validaDados(true);
}

function editarConvenio(nrconven) {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando ...");

    $.ajax({
        dataType: "json",
        type: "POST",
        url: UrlSite + "telas/atenda/reciprocidade/consulta_convenio.php",
        data: {
            nrconven: nrconven,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function (response) {
            hideMsgAguardo();

            $('#tooltip').hide();

            nrconven = response.nrconven;
            nrcnvceb = response.nrcnvceb;
            dsorgarq = response.dsorgarq;
            insitceb = response.insitceb;
            inarqcbr = response.inarqcbr;
            cddemail = response.cddemail;
            flgcruni = response.flgcruni;
            flgcebhm = response.flgcebhm;
            flgapihm = response.flgapihm;
            qtTitulares = response.qtTitulares;
            titulares = response.titulares;
            dsdmesag = response.dsdmesag;
            flgregon = response.flgregon;
            flgpgdiv = response.flgpgdiv;
            flcooexp = response.flcooexp;
            flceeexp = response.flceeexp;
            flserasa = response.flserasa;
            qtdfloat = response.qtdfloat;
            flprotes = response.flprotes;
            qtlimmip = response.qtlimmip;
            qtlimaxp = response.qtlimaxp;
            qtdecprz = response.qtdecprz;
            idrecipr = response.idrecipr;
            inenvcob = response.inenvcob;
            flsercco = response.flsercco;
            flgregis = response.flgregis;
            cddbanco = response.cddbanco;
            qtbolcob = response.qtbolcob;

            var cddopcao = $('#cddopcao', '#divConteudoOpcao').val();

            consulta(cddopcao, nrconven, dsorgarq, false, flgregis, cddbanco);
        }
    });

    return false;
}

function abrirAprovacao(hideBtnDetalhes) {
    // origem tela Contratos
    var idrecipr = $("#idrecipr", "#divConteudoOpcao").val();
    var cdalcada = $("#cdalcada").val();
    var nvopelib = $("#nvopelib").val();

    // origem tela Descontos
    if (typeof idrecipr === 'undefined') {
        idrecipr = $('#idcalculo_reciproci', '#divConteudoOpcao').val();
    }

    if (idrecipr == '') {
        showError("error", "Selecione um contrato.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
        return;
    }

    if (typeof cdalcada !== 'undefined' && cdalcada
         && typeof nvopelib !== 'undefined' && nvopelib
         && hideBtnDetalhes) {

        aprovarContrato(cdcooper, cdalcada, idrecipr);
        //pedeSenhaCoordenador(nvopelib, 'aprovarContrato('+cdcooper+','+cdalcada+','+idrecipr+')', 'divRotina');
        return false;
    }

    blockBackground(parseInt($("#divRotina").css("z-index")));

    $.ajax({
        type: "POST",
        dataType: 'html',
        url: UrlSite + "telas/cadres/tela_aprovacao.php",
        data: {
            cdcooper: cdcooper,
            idrecipr: idrecipr,
            fnconfirm: "hideMsgAguardo();acessaOpcaoContratos();blockBackground(parseInt($('#divRotina').css('z-index')));",
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
            if (response.substr(0, 14) == 'hideMsgAguardo') {
                eval(response);
            } else {
                var telaAprovacao = $('#telaAprovacao');
                $("#divConteudoOpcao").hide();
                telaAprovacao.html(response);
                telaAprovacao.find('#btVoltar').click(function () {
                    acessaOpcaoContratos();
                    telaAprovacao.html('');
                });
                if (hideBtnDetalhes) {
                    telaAprovacao.find('#btDetalhes').hide();
                } else {
                    telaAprovacao.find('#btDetalhes').click(function () {
                        telaAprovacao.hide();
                        acessaOpcaoDescontos('C');
                    });
                }
            }
        }
    });
}

function abrirRejeicao() {
    // origem tela Contratos
    var idrecipr = $("#idrecipr", "#divConteudoOpcao").val();

    // origem tela Descontos
    if (typeof idrecipr === 'undefined') {
        idrecipr = $('#idcalculo_reciproci', '#divConteudoOpcao').val();
    }

    if (idrecipr == '') {
        showError("error", "Selecione um contrato.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
        return;
    }

    blockBackground(parseInt($("#divRotina").css("z-index")));

    $.ajax({
        type: "POST",
        dataType: 'html',
        url: UrlSite + "telas/cadres/tela_rejeicao.php",
        data: {
            cdcooper: cdcooper,
            idrecipr: idrecipr,
            fnreject: "hideMsgAguardo();acessaOpcaoContratos();blockBackground(parseInt($('#divRotina').css('z-index')));",
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
            if (response.substr(0, 14) == 'hideMsgAguardo') {
                eval(response);
            } else {
                var telaRejeicao = $('#telaRejeicao');
                $("#divConteudoOpcao").hide();
                telaRejeicao.html(response);
                telaRejeicao.find('#btVoltar').click(function () {
                    acessaOpcaoContratos();
                });
            }
        }
    });
}

function carregaCobranca() {
    acessaRotina("#labelRot21", "COBRANCA", "Cobran&ccedil;a", "cobranca", "RECIPROCIDADE");
}

function acessaTarifa(tipo) {
    // tipo == 0 (COO)
    // tipo == 1 (CEE)
    if (descontoConvenios.length == 0) {
        showError("error", "Selecione ao menos um conv&ecirc;nio.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
        return false;
    }

    var convenios = [];
    for (var i = 0, len = descontoConvenios.length; i < len; ++i) {
        convenios.push(descontoConvenios[i].convenio);
    }

    showMsgAguardo("Aguarde, carregando ...");
    // Carrega conte&uacute;do da op&ccedil;&atilde;o atrav&eacute;s de ajax
    $.ajax({
        dataType: "html",
        type: "POST",
        url: UrlSite + "telas/atenda/reciprocidade/desconto_tarifas.php",
        data: {
            inpessoa: inpessoa,
            tipo: tipo,
            convenios: convenios,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function (response) {
            $('#divConteudoOpcao').css("display", "none");
            $('#divConvenios').html(response);
            $("#divConvenios").css('display', 'block');
            controlaFoco();
            controlaLayout("");
            calcula_tarifas(tipo);
        }
    });
}

function calcula_tarifas(tipo) {

    function calculaFormataTipo(elm, vldesconto, vldesconto_adic) {
        vldesconto = converteMoedaFloat(vldesconto) + converteMoedaFloat(vldesconto_adic);
        if (vldesconto > 100) {
            vldesconto = 100;
        }

        for (var i = 0; i < elm.length; ++i) {
            var $elm = $(elm[i]);
            var valor = converteMoedaFloat($elm.find('[class*="clsTarValorOri"]').html()),
                campo = $elm.find('[class*="clsTarValorDes"]');

            var total = (valor - (valor * (vldesconto / 100)));

            campo.html(number_format(total, 2, ',', '.'));
        }
    }

    // COO
    if (tipo == 0) {

        var tipoCoo = $('.clsTarCOO');
        var vldesconto_coo = $('#vldescontoconcedido_coo', '.tabelaDesconto').val();
        var vldesconto_coo_adic = $('#vldesconto_coo', '.tabelaDesconto').val();

        calculaFormataTipo(tipoCoo, vldesconto_coo, vldesconto_coo_adic);

        // CEE    
    } else if (tipo == 1) {

        var tipoCee = $('.clsTarCEE');
        var vldesconto_cee = $('#vldescontoconcedido_cee', '.tabelaDesconto').val();
        var vldesconto_cee_adic = $('#vldesconto_cee', '.tabelaDesconto').val();

        calculaFormataTipo(tipoCee, vldesconto_cee, vldesconto_cee_adic);

    }

}

function calcula_desconto() {
    $('#vldescontoconcedido_cee', '.tabelaDesconto').val(0);
    $('#vldescontoconcedido_coo', '.tabelaDesconto').val(0);

    var idvinculacao = $('#idvinculacao', '.tabelaDesconto').val();

    if (descontoConvenios.length == 0) {
        return false;
    }

    if (typeof idvinculacao == "undefined") {
        return false;
    }

    var convenios = [];
    var cee = 0, coo = 0;
    for (var i = 0, len = descontoConvenios.length; i < len; ++i) {
        convenios.push(descontoConvenios[i].convenio);
        if (descontoConvenios[i].flcooexp == 1) {
            coo = 1;
        }
        if (descontoConvenios[i].flceeexp == 1) {
            cee = 1;
        }
    }

    showMsgAguardo("Aguarde, carregando ...");
    // Carrega conte&uacute;do da op&ccedil;&atilde;o atrav&eacute;s de ajax
    $.ajax({
        dataType: "html",
        type: "POST",
        url: UrlSite + "telas/atenda/reciprocidade/desconto_calculo.php",
        data: {
            convenios: convenios,
            boletos_liquidados: $('#qtdboletos_liquidados', '.tabelaDesconto').val(),
            volume_liquidacao: $('#valvolume_liquidacao', '.tabelaDesconto').val(),
            qtdfloat: $('#qtdfloat', '.tabelaDesconto').val(),
            vlaplicacoes: $('#vlaplicacoes', '.tabelaDesconto').val(),
            vldeposito: $('#vldeposito', '.tabelaDesconto').val(),
            idvinculacao: idvinculacao,
            idcoo: coo,
            idcee: cee,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function (response) {
            eval(response);
        }
    });

    validaHabilitacaoCamposBtn();
}

function atualizarDescontos() {
    var qtdeDescontos = $('#qtdeDescontos', '#frmConsulta').val();
    perdescontos = [];
    atualizacaoDesconto = false;
    for (var i = 0; i < qtdeDescontos; i++) {
        var $item = $('#perdesconto_' + i, "#frmConsulta");
        if ($item.val() != "" && $item.val() != "0,00") {
            if ($item.val() != $item.attr('oldvalue')) {
                atualizacaoDesconto = true;
            }
            perdescontos.push($item.attr('cdcatego') + "#" + $item.val().replace(".", ","));
        }
    }
}

function confirmaCancelarContrato() {

    var idrecipr = $("#idrecipr", "#divConteudoOpcao").val();
    var insitceb = $("#insitceb", "#divConteudoOpcao").val();
    if (idrecipr == '') {
        showError("error", "Selecione um contrato.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
        return;
    }

    if (insitceb != "1") {
        showError("error", "O contrato deve estar ativo para ser cancelado.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
        return;
    }

    showConfirmacao('Confirma o cancelamento do contrato?', 'Confirma&ccedil;&atilde;o - Ayllos', 'cancelarContrato(' + idrecipr + ',' + nrdconta + ')', 'blockBackground(parseInt($("#divRotina").css("z-index")))', 'sim.gif', 'nao.gif');
}

function cancelarContrato(idrecipr, nrdconta) {
    showMsgAguardo("Aguarde, carregando ...");
    $.ajax({
        dataType: "html",
        type: "POST",
        url: UrlSite + "telas/atenda/reciprocidade/cancelar_desconto.php",
        data: {
            idrecipr: idrecipr,
            nrdconta: nrdconta,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function (response) {
            hideMsgAguardo();
            eval(response);
            blockBackground(parseInt($("#divRotina").css("z-index")));
        }
    });
}

var novosConvenios = [];
$('body').delegate('#divConvenios input[type="checkbox"]', 'change', function () {
    var idx = retornaIndice(descontoConvenios, 'convenio', $(this).val());

    var i = novosConvenios.indexOf($(this).val());
    if (idx === null && $(this).is(':checked')) {
        novosConvenios.push($(this).val());
    } else if (!$(this).is(':checked') && i >= 0) {
        novosConvenios.splice(i, 1);
    }
});
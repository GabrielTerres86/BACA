/*!
 * FONTE        : impressoes.js
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 05/04/2010 
 * OBJETIVO     : Biblioteca de funções da rotina IMPRESSÕES da tela de CONTAS
 * --------------
 * ALTERAÇÕES   :
 * 29/06/2012 - Jorge        (CECRED) : Ajuste para novo esquema de impressao.
 * 			 						    Adicionado confirmacao de impressao quando chamada funcao imprime().
 *										Retirado campo "redirect" popup de form de impressao. 
 *
 * 01/08/2013 - Jean Michel  (CECRED) : Ajuste p/ impressão de cartões de assinatura de proc/tit.
 * 02/09/2015 - Projeto Reformulacao cadastral (Tiago Castro - RKAM)
 * 19/10/2015 - Ajuste no layout na div DivConteudoOpcao que estava quebrando. SD 310056 (Kelvin)
 * 03/10/2017 - Projeto 410 - RF 52 / 62 - Tela impressão declaração optante simples nacional (Diogo - Mouts)	
 * 25/04/2018 - Adicionado nova opcao de impresssao Declaracao de FATCA/CRS - PRJ 414 (Mateus Z - Mouts) 
 * --------------
 */

var nrcpfcgc = "";
var nrdctato = "";
var nrdrowid = "";
var operacao = "";



// Função para acessar opções da rotina
function acessaOpcaoAba(nrOpcoes, id, opcao) {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando impress&otilde;es ...");

    // Atribui cor de destaque para aba da opção
    for (var i = 0; i < nrOpcoes; i++) {
        if (!$("#linkAba" + id)) {
            continue;
        }

        if (id == i) { // Atribui estilos para foco da opção
            $("#linkAba" + id).attr("class", "txtBrancoBold");
            $("#imgAbaEsq" + id).attr("src", UrlImagens + "background/mnu_sle.gif");
            $("#imgAbaDir" + id).attr("src", UrlImagens + "background/mnu_sld.gif");
            $("#imgAbaCen" + id).css("background-color", "#969FA9");
            continue;
        }

        $("#linkAba" + i).attr("class", "txtNormalBold");
        $("#imgAbaEsq" + i).attr("src", UrlImagens + "background/mnu_nle.gif");
        $("#imgAbaDir" + i).attr("src", UrlImagens + "background/mnu_nld.gif");
        $("#imgAbaCen" + i).css("background-color", "#C6C8CA");
    }

    // Carrega conteúdo da opção através do Ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/contas/impressoes/principal.php",
        data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            inpessoa: inpessoa,
            tpregtrb: tpregtrb, //vem da contas/obtem_cabecalho
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", bloqueiaFundo(divRotina));
        },
        success: function (response) {
            if (flgcadas == 'M') { // Se vem da MATRIC (Cadastro de nova c/c) abrir a impressao completa automaticamente e vai para a ATENDA
                encerraRotina();
                imprime('completo', 'YES', inpessoa);
                showMsgAguardo('Aguarde, carregando tela ATENDA ...');
                setaParametros('ATENDA', '', nrdconta, flgcadas);

                setTimeout(function () {
                    direcionaTela('ATENDA', 'no');
                }, 5000);

            } else {
                $("#divConteudoOpcao").html(response);
            }
            return false;
        }
    });
}

/*!
 * OBJETIVO : Função que verifica se deve ser mostrada alguma mensagem ao usuário
 * PARÂMETRO: idImpressao [String] -> Nome de qual impressão deseja-se imprimir. Os valores válidos são os "id" das div desta rotina
 */
function verificaMsg(idImpressao, inpessoa) {

    if (idImpressao == 'todos' || idImpressao == 'procurador' || idImpressao == 'titular') {
        impressaoCartaoAssinatura(inpessoa, idImpressao);
    } else if (typeof relatorios[idImpressao] != typeof undefined && relatorios[idImpressao]['msg'] != '') {
        if (relatorios[idImpressao]['flag'] == 'yes') {
            showError("error", relatorios[idImpressao]['msg'], "Alerta - Aimaro", 'bloqueiaFundo(divRotina)');
        } else {
            showError("inform", relatorios[idImpressao]['msg'], "Alerta - Aimaro", 'bloqueiaFundo(divRotina)');
            controlaImpressao(idImpressao, inpessoa);
        }
    } else {
        controlaImpressao(idImpressao, inpessoa);
    }
}

/*!
 * OBJETIVO : Função de controle as impressões da rotina
 * PARÂMETRO: idImpressao [String] -> Nome de qual impressão deseja-se imprimir. Os valores válidos são os "id" das div desta rotina
 */
function controlaImpressao(idImpressao, inpessoa) {

    if (idImpressao == 'ficha_cadastral') {
        showConfirmacao('Deseja visualizar a impress&atilde;o?', 'Confirma&ccedil;&atilde;o - Aimaro', 'imprimeFichaCadastral(divRotina);', 'bloqueiaFundo(divRotina);', 'sim.gif', 'nao.gif');
        return true;
    } else if (idImpressao == 'financeiro') {
        showConfirmacao('Deseja o informativo financeiro preenchido ?', 'Confirma&ccedil;&atilde;o - Aimaro', 'bloqueiaFundo(divRotina);imprime(\'' + idImpressao + '\',\'YES\',\'' + inpessoa + '\');', 'bloqueiaFundo(divRotina);imprime(\'' + idImpressao + '\',\'NO\',\'' + inpessoa + '\');', 'sim.gif', 'nao.gif');
        return true;
    } else if (idImpressao == 'cartao_assinatura') {
        telaCartaoAssinatura(inpessoa);
    } else if (idImpressao == 'declaracao_pep') {
        showConfirmacao('Deseja visualizar a impress&atilde;o da declara&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Aimaro', 'imprimeDeclaracao();', 'bloqueiaFundo(divRotina);', 'sim.gif', 'nao.gif');
        return true;
    } else if (idImpressao == 'declaracao_optante_simples_nacional'){
		showConfirmacao('Deseja visualizar a impress&atilde;o?', 'Confirma&ccedil;&atilde;o - Aimaro', 'imprimeDeclaracaoSimplesNacional(divRotina);', 'bloqueiaFundo(divRotina);', 'sim.gif', 'nao.gif');
        return true;
    } else if (idImpressao == 'declaracao_pj_cooperativa'){
        showConfirmacao('Deseja visualizar a impress&atilde;o?', 'Confirma&ccedil;&atilde;o - Aimaro', 'imprimeDeclaracaoPJCooperativa(divRotina);', 'bloqueiaFundo(divRotina);', 'sim.gif', 'nao.gif');
        return true;
	} else if (idImpressao == 'declaracao_fatca_crs') {
        showConfirmacao('Deseja visualizar a impress&atilde;o?', 'Confirma&ccedil;&atilde;o - Aimaro', 'imprime(\'' + idImpressao + '\',\'YES\',\'' + inpessoa + '\');', 'bloqueiaFundo(divRotina);', 'sim.gif', 'nao.gif');	
    } else if (idImpressao != '') {
        showConfirmacao('Deseja visualizar a impress&atilde;o?', 'Confirma&ccedil;&atilde;o - Aimaro', 'imprime(\'' + idImpressao + '\',\'YES\',\'' + inpessoa + '\');', 'bloqueiaFundo(divRotina);', 'sim.gif', 'nao.gif');
    }
}

function controlaLayout(inpessoa) {

    if (inpessoa == 1) {
        $('#tabelaImpressoes', '#divRotina').css('margin-left', '-108px');
    } else {
        $('#tabelaImpressoes', '#divRotina').css('margin-left', '-32px');
    }

    $("#divConteudoOpcao").fadeTo(0, 0.01);

    if ($("#divImpCartaoAssinatura").length) {
        if (inpessoa == 1) {
            $("#divConteudoOpcao").css("width", "540px");
        } else {
            $("#divConteudoOpcao").css("width", "345px");

        }

        $('div', '#divImpCartaoAssinatura').css({
            'display': 'block',
            'float': 'left',
            'margin': '2px',
            'font-weight': 'bold',
            'border-color': '#949ead',
            'border-style': 'solid',
            'background-color': '#ced3c6',
            'border-width': '1px',
            'cursor': 'auto',
            'padding': '17px 21px'
        });

        if (inpessoa == 1) {
            $('#financeiro', '#divImpCartaoAssinatura').css({ 'display': 'none' });
            $('div', '#divImpCartaoAssinatura').css({ 'padding': '17px 21px' });
        } else {
            $('#financeiro', '#divImpCartaoAssinatura').css({ 'display': 'block' });
            $('div', '#divImpCartaoAssinatura').css({ 'padding': '17px 12px' });
        }

        // Trocando a classe no evento hover
        $('div', '#divImpCartaoAssinatura').hover(
			function () {
			    $(this).css({ 'background-color': '#f7f3f7', 'border-width': '3px', 'cursor': 'pointer' });
			    if (inpessoa == 1) {
			        $(this).css({ 'padding': '15px 19px' });
			    } else {
			        $(this).css({ 'padding': '15px 10px' });
			    }
			},
			function () {
			    $(this).css({ 'background-color': '#ced3c6', 'border-width': '1px', 'cursor': 'auto' });
			    if (inpessoa == 1) {
			        $(this).css({ 'padding': '17px 21px' });
			    } else {
			        $(this).css({ 'padding': '17px 12px' });
			    }
			}
		);

        // Adicionando evento click
        $('div', '#divImpCartaoAssinatura').click(function () {
            if ($(this).attr('id') != 'btVoltar') verificaMsg($(this).attr('id'), $('#inpessoa', '#divImpCartaoAssinatura').val());
        });

    } else {

        if (inpessoa == 1) {
            $("#divConteudoOpcao").css("width", "729px");
        } else {
            $("#divConteudoOpcao").css("width", "590px");
        }

        $('div', '#divImpressoes').css({
            'display': 'block',
            'float': 'left',
            'margin': '2px',
            'font-weight': 'bold',
            'border-color': '#949ead',
            'border-style': 'solid',
            'background-color': '#ced3c6',
            'border-width': '1px',
            'cursor': 'auto',
            'padding': '17px 21px'
        });

        // Diferenciando  a classe hover de acordo com o tipo da pessoa
        if (inpessoa == 1) {
            $('#financeiro', '#divImpressoes').css({ 'display': 'none' });
            $('div', '#divImpressoes').css({ 'padding': '17px 21px' });
        } else {
            $('#financeiro', '#divImpressoes').css({ 'display': 'block' });
            $('div', '#divImpressoes').css({ 'padding': '17px 12px' });
        }

        // Trocando a classe no evento hover
        $('div', '#divImpressoes').hover(
			function () {
			    $(this).css({ 'background-color': '#f7f3f7', 'border-width': '3px', 'cursor': 'pointer' });
			    if (inpessoa == 1) {
			        $(this).css({ 'padding': '15px 19px' });
			    } else {
			        $(this).css({ 'padding': '15px 10px' });
			    }
			},
			function () {
			    $(this).css({ 'background-color': '#ced3c6', 'border-width': '1px', 'cursor': 'auto' });
			    if (inpessoa == 1) {
			        $(this).css({ 'padding': '17px 21px' });
			    } else {
			        $(this).css({ 'padding': '17px 12px' });
			    }
			}
		);

        // Adicionando evento click
        $('div', '#divImpressoes').click(function () {
            if ($(this).attr('id') != 'btVoltar') verificaMsg($(this).attr('id'), $('#inpessoa', '#divImpressoes').val());
        });
    }

    hideMsgAguardo();
    bloqueiaFundo(divRotina);
    removeOpacidade('divConteudoOpcao');
    return false;
}

function imprime(idImpressao, flgpreen, inpessoa) {
	
	var nrCPF = normalizaNumero(cpfprocu);

    $('#tprelato', '#frmCabContas').remove();
    $('#flgpreen', '#frmCabContas').remove();
    $('#inpessoa', '#frmCabContas').remove();
    $('#_nrdconta', '#frmCabContas').remove();
    $('#_idseqttl', '#frmCabContas').remove();
    $('#sidlogin', '#frmCabContas').remove();
	$('#tpregtrb', '#frmCabContas').remove();
	$('#_nrcpfcgc', '#frmCabContas').remove();

    // Insiro input do tipo hidden do formulário para enviá-los posteriormente
    $('#frmCabContas').append('<input type="hidden" id="tprelato" name="tprelato" />');
    $('#frmCabContas').append('<input type="hidden" id="flgpreen" name="flgpreen" />');
    $('#frmCabContas').append('<input type="hidden" id="inpessoa" name="inpessoa" />');
    $('#frmCabContas').append('<input type="hidden" id="_nrdconta" name="_nrdconta" />');
    $('#frmCabContas').append('<input type="hidden" id="_idseqttl" name="_idseqttl" />');
    $('#frmCabContas').append('<input type="hidden" id="sidlogin" name="sidlogin" />');
	$('#frmCabContas').append('<input type="hidden" id="tpregtrb" name="tpregtrb" />');
	$('#frmCabContas').append('<input type="hidden" id="_nrcpfcgc" name="_nrcpfcgc" />');

    // Agora insiro os devidos valores nos inputs criados
    $('#tprelato', '#frmCabContas').val(idImpressao);
    $('#flgpreen', '#frmCabContas').val(flgpreen);
    $('#inpessoa', '#frmCabContas').val(inpessoa);
    $('#_nrdconta', '#frmCabContas').val(normalizaNumero(nrdconta));
    $('#_idseqttl', '#frmCabContas').val(idseqttl);
	$('#tpregtrb', '#frmCabContas').val(tpregtrb);
    $('#sidlogin', '#frmCabContas').val($('#sidlogin', '#frmMenu').val());
	$('#_nrcpfcgc', '#frmCabContas').val(nrCPF);

    var action = UrlSite + 'telas/contas/impressoes/imp_impressoes.php';
    var callafter = "bloqueiaFundo(divRotina);";

    carregaImpressaoAyllos("frmCabContas", action, callafter);

}

function imprimeDeclaracaoSimplesNacional(divBloqueio){
	
    $('#sidlogin', '#frmCabContas').remove();
    $('#tpregist', '#frmCabContas').remove();
	$('#tpregtrb', '#frmCabContas').remove();
	$('#imprimirsodeclaracaosn', '#frmCabContas').remove();

    $('#frmCabContas').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin', '#frmMenu').val() + '" />');
    $('#frmCabContas').append('<input type="hidden" id="tpregist" name="tpregist" value="' + inpessoa + '" />');
	$('#frmCabContas').append('<input type="hidden" id="tpregtrb" name="tpregtrb" value="' + tpregtrb + '" />');
	$('#frmCabContas').append('<input type="hidden" id="imprimirsodeclaracaosn" name="imprimirsodeclaracaosn" value="1" />');

    var action = UrlSite + 'telas/contas/ficha_cadastral/imp_fichacadastral.php';
    var callafter = "";

    if (typeof divBloqueio != "undefined") { callafter = "bloqueiaFundo(" + divBloqueio.attr("id") + ");"; }

    carregaImpressaoAyllos("frmCabContas", action, callafter);
	//Remove para não afetar a rotina de ficha cadastral
	$('#imprimirsodeclaracaosn', '#frmCabContas').remove();	
}

function imprimeDeclaracaoPJCooperativa(divBloqueio){
    $form = $('<form id="frmImpressaoDeclaracaoPJCooperativa" name="frmImpressaoDeclaracaoPJCooperativa" />').appendTo('body');
    $form.append('<input type="hidden" id="nrdconta" name="nrdconta" value="' + normalizaNumero(nrdconta) + '" />')
    $form.append('<input type="hidden" id="nrcpfcgc" name="nrcpfcgc" value="' + normalizaNumero($('#nrcpfcgc', '#frmCabContas').val()) + '" />')
    $form.append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin', '#frmMenu').val() + '" />')
    var action = UrlSite + 'telas/contas/ficha_cadastral/imp_declaracao_pj_cooperativa.php';
    var callafter = "";
    if (typeof divBloqueio != "undefined") { callafter = "bloqueiaFundo(" + divBloqueio.attr("id") + ");"; }
    carregaImpressaoAyllos("frmImpressaoDeclaracaoPJCooperativa", action, callafter);
    //Remove para não afetar a rotina de ficha cadastral
    $form.remove();
}

function telaCartaoAssinatura(inpessoa) {
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/contas/impressoes/cartao_assinatura.php",
        data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            inpessoa: inpessoa,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", bloqueiaFundo(divRotina));
        },
        success: function (response) {
            $("#divConteudoOpcao").html(response);
            return false;
        }
    });
}

function impressaoCartaoAssinatura(inpessoa, tpimpressao) {

    if (tpimpressao == 'todos') {
        imprimirCartaoAssinatura(3);
    } else {
        $.ajax({
            type: "POST",
            dataType: "html",
            url: UrlSite + "telas/contas/impressoes/consulta_impressao.php",
            data: {
                nrdconta: nrdconta,
                idseqttl: idseqttl,
                inpessoa: inpessoa,
                tpimpressao: tpimpressao,
                nrcpfcgc: nrcpfcgc,
                nrdctato: nrdctato,
                nrdrowid: nrdrowid,
                operacao: operacao,
                redirect: "html_ajax"
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", bloqueiaFundo(divRotina));
            },
            success: function (response) {
                $("#divConteudoOpcao").html(response);
                return false;
            }
        });
    }
}

function imprimirCartaoAssinatura(tipoimpr) {

    $('#frmImpressao').empty();
    $('#frmImpressao').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin', '#frmMenu').val() + '" />');

    if (tipoimpr == 1) { /* Titular */

        $('table > tbody > tr', 'div.divRegistros').each(function () {
            if ($(this).hasClass('corSelecao')) {
                nrdconta = $('input[name="nrdconta"]', $(this)).val();
                nrdctato = $('input[name="nrdctato"]', $(this)).val();
                idseqttl = $('input[name="idseqttl"]', $(this)).val();
                nrcpfcgc = $('input[name="nrcpfcgc"]', $(this)).val();
            }
        });

        $('#frmImpressao').append('<input type="hidden" id="nrdconta" name="nrdconta" value="' + nrdconta + '" />');
        $('#frmImpressao').append('<input type="hidden" id="idseqttl" name="idseqttl" value="' + idseqttl + '" />');
        $('#frmImpressao').append('<input type="hidden" id="nrcpfcgc" name="nrcpfcgc" value="' + nrcpfcgc + '" />');
        $('#frmImpressao').append('<input type="hidden" id="nrdctato" name="nrdctato" value="' + nrdctato + '" />');
        $('#frmImpressao').append('<input type="hidden" id="tppessoa" name="tppessoa" value="1" />');

        showConfirmacao('Deseja visualizar a impress&atilde;o?', 'Confirma&ccedil;&atilde;o - Aimaro', 'imprimeCartaoAssinatura(1);', 'bloqueiaFundo(divRotina);', 'sim.gif', 'nao.gif');
    } else if (tipoimpr == 2) { /* Procurador */

        $('table > tbody > tr', 'div.divRegistros').each(function () {
            if ($(this).hasClass('corSelecao')) {
                nrdconta = $('input[name="nrdconta"]', $(this)).val();
                nrcpfcgc = $('input[name="nrcpfcgc"]', $(this)).val();
                nrdctato = $('input[name="nrdctato"]', $(this)).val();
            }
        });

        $('#frmImpressao').append('<input type="hidden" id="nrdconta" name="nrdconta" value="' + nrdconta + '" />');
        $('#frmImpressao').append('<input type="hidden" id="idseqttl" name="idseqttl" value="0" />');
        $('#frmImpressao').append('<input type="hidden" id="nrcpfcgc" name="nrcpfcgc" value="' + nrcpfcgc + '" />');
        $('#frmImpressao').append('<input type="hidden" id="nrdctato" name="nrdctato" value="' + nrdctato + '" />');
        $('#frmImpressao').append('<input type="hidden" id="tppessoa" name="tppessoa" value="2" />');

        showConfirmacao('Deseja visualizar a impress&atilde;o?', 'Confirma&ccedil;&atilde;o - Aimaro', 'imprimeCartaoAssinatura(2);', 'bloqueiaFundo(divRotina);', 'sim.gif', 'nao.gif');
    } else if (tipoimpr == 3) { /* Todos */

        $('#frmImpressao').append('<input type="hidden" id="nrdconta" name="nrdconta" value="' + nrdconta + '" />');
        $('#frmImpressao').append('<input type="hidden" id="idseqttl" name="idseqttl" value="0" />');
        $('#frmImpressao').append('<input type="hidden" id="nrcpfcgc" name="nrcpfcgc" value="0" />');
        $('#frmImpressao').append('<input type="hidden" id="nrdctato" name="nrdctato" value="0" />');
        $('#frmImpressao').append('<input type="hidden" id="tppessoa" name="tppessoa" value="3" />');

        showConfirmacao('Deseja visualizar a impress&atilde;o?', 'Confirma&ccedil;&atilde;o - Aimaro', 'imprimeCartaoAssinatura(3);', 'bloqueiaFundo(divRotina);', 'sim.gif', 'nao.gif');
    }
}

function imprimeCartaoAssinatura(tppessoa) {

    var action = UrlSite + 'telas/contas/impressoes/imprime_cartao_ass.php';
    var callafter = "bloqueiaFundo(divRotina);";

    carregaImpressaoAyllos("frmImpressao", action, callafter);

}

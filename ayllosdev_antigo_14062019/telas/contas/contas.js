/*!
 * FONTE        : contas.js
 * CRIAÇÃO      : Alexandre Scola (DB1)
 * DATA CRIAÇÃO : Janeiro/2010 
 * OBJETIVO     : Biblioteca de funções da tela CONTAS
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 001: [12/02/2010] Rodolpho Telmo     (DB1): Ao alterar titular da conta, mudar o cabeçalho automaticamente
 * 002: [23/03/2010] Rodolpho Telmo     (DB1): [REMOVIDO] Criado comportamento ao prescionar a tecla ESC, ativa o botão voltar corrente da tela
 * 003: [26/03/2010] Rodolpho Telmo     (DB1): [REMOVIDO] Criado comportamento ao prescionar a tecla INSERT, ativa o botão incluir corrente da tela
 * 004: [30/03/2010] Rodolpho Telmo     (DB1): Retirado o MasketInput, e adicionado o dateEntry
 * 006: [01/04/2010] Rodolpho Telmo     (DB1): Criada função formataCabecalho()
 * 007: [07/04/2010] Rodolpho Telmo     (DB1): Criada função imprimeFichaCadastral()
 * 008: [18/01/2011] David (CECRED)          : Inicializar variavel idseqttl no fechamento das rotinas
 * 009: [18/11/2011] David (CECRED)          : Ajustar parâmetro na função obtemCabecalho() para atender atualização do cabeçalho em background
 * 010: [03/07/2012] Jorge Hamaguchi (CECRED): Ajuste do esquema de impressao em funcao imprimeFichaCadastral() e retirado campo "redirect" popup.
 * 011: [24/03/2012] Adriano(CECRED)         : Criado as variáveis glboais cpfprocu, dtdenasc, cdhabmen, verrespo, permalte, arrayFilhos.
 * 012: [11/08/2014] Jonata (Rkam)           : Nova rotina de Prot. ao Credito.
 * 013: [05/01/2015] James Prust Junior      : Incluir o item Liberar/Bloquear
 * 014: [03/08/2015] Gabriel (RKAM)          : Reformulacao cadastral.
 * 015: [19/09/2015] Gabriel (RKAM) Projeto 217: Ajuste para chamada da rotina Produtos.
 * 016: [05/01/2016] Carlos (CECRED)         : #350828 Impressao de declaração de pessoa exposta politicamente.
 * 017: [14/09/2016] Kelvin (CECRED) 		 : Ajuste feito para resolver o problema relatado no chamado 506554.
 * 018: [27/03/2017] Reinert			  	 : Incluido function "dossieDigidoc". (Projeto 357)
 * 019: [11/07/2017] Andrino (MOUTS) 		 : Desenvolvimento da melhoria 364 - Grupo Economico
 * 020: [14/07/2017] Lucas Reinert           : Alteração para o cancelamento manual de produtos. Projeto 364.
 * 021: [17/10/2017] Kelvin (CECRED)         : Adicionando a informacao nmctajur no cabecalho da tela contas (PRJ339).
 * 022: [04/11/2017] Jonata (RKAM)           : Ajuste para inclusão da nova rotina Impedimentos (P364).
 */

var flgAcessoRotina = false; // Flag para validar acesso as rotinas da tela CONTAS
var flgMostraAnota = false; // Flag que indica se anotações devem ser mostradas após as mensagens

var nrdconta = ""; // Variável global para armazenar nr. da conta/dv
var nrdctitg = ""; // Variável global para armazenar nr. da conta integração
var inpessoa = ""; // Variável global para armazenar o tipo de pessoa (física/jurídica)
var idseqttl = ""; // Variável global para armazenar nr. da sequencia dos titulares
var cpfprocu = ""; // Variável global para armazenar nr. do cpf dos titulares
var dtdenasc = ""; // Variável global para armazenar a data de nascimento do titular
var cdhabmen = ""; // Variável global para armazenar o tipo de responsabilidade legal
var verrespo = false; //Variável global para indicar se deve validar ou nao os dados dos Resp.Legal na BO55
var permalte = false; // Está variável sera usada para controlar se a "Alteração/Exclusão/Inclusão - Resp. Legal" deverá ser feita somente na tela contas
var arr_guias_dadosp = [false, true, false, true, true, true, true]; // Array para descobrir em qual guia da rotina Dados pessoias o operador ja passou
var arr_guias_comercial = [false, false, false]; // Array para descobrir em qual guia da rotina Comercial PF o operador ja passou
var arr_guias_contacorrente = [false, false, false, false];// Array para descobrir em qual guia da rotina Conta Corrente o operador ja passou

var arrayFilhos = new Array(); // Variável global para armazenar os responsaveis legais

var contWinAnot = 0; // Para impressão das anotações
var nrJanelas   = 0; // Variável para contagem do número de janelas abertas para impressãosa dajsdj

//Variaveis de controle para uso da rotina Produtos
var produtosTelasServicos = new Array();
var produtosTelasServicosAdicionais = new Array();
var executandoProdutosServicos = false;
var executandoProdutos = false;
var executandoImpedimentos = false;
var executandoProdutosServicosAdicionais = false;
var posicao = 0;
var atualizarServicos = new Array();

$(document).ready(function () {

    var cNrConta = $('#nrdconta', '#frmCabContas');
    var cSeqTitular = $('#idseqttl', '#frmCabContas');

    // ALTERAÇÃO 001
    // Quando alterar o titular, automaticamente carregar os dados deste novo titular selecionado
    cSeqTitular.change(function () {
        flgcadas = 'C';
        obtemCabecalho();
    });

    // Evento onKeyUp no campo "nrdconta"
    cNrConta.bind('keyup', function (e) {
        // Seta máscara ao campo
        if (!$(this).setMaskOnKeyUp("INTEGER", "zzzz.zzz-z", "", e)) {
            return false;
        }
    });

    // Evento onKeyDown no campo "nrdconta"
    cNrConta.bind('keydown', function (e) {
        // Captura código da tecla pressionada
        var keyValue = getKeyValue(e);

        if (keyValue == 118) { // Se for F7
            if ($(this).hasClass('campo')) {
                $('a', '#frmCabContas').first().click();
                return false;
            }
        }

        // Se alguma tecla foi pressionada, seta o idseqttl para 1
        if ((keyValue >= 48 && keyValue <= 57) || (keyValue >= 96 && keyValue <= 105)) {
            cSeqTitular.val('1');
        }

        // Se o botão enter foi pressionado, carrega dados da conta
        if (keyValue == 13) {
            flgcadas = 'C';
            obtemCabecalho();
            return false;
        }

        // Seta máscara ao campo
        return $(this).setMaskOnKeyDown("INTEGER", "zzzz.zzz-z", "", e);
    });

    // Evento onBlur no campo "nrdconta"
    cNrConta.bind('blur', function () {
        if ($(this).val() == '') {
            limparDadosCampos();
            return true;
        }

        // Valida número da conta
        if (!validaNroConta(retiraCaracteres($(this).val(), "0123456789", true))) {
            showError("error", "Conta/dv inválida.", "Alerta - Aimaro", "$('#nrdconta','#frmCabContas').focus()");
            limparDadosCampos();
            return false;
        }

        if (retiraCaracteres($(this).val(), "0123456789", true) != nrdconta) {
            limparDadosCampos();
            return true;
        }

        if (cSeqTitular.val() != idseqttl) {
            obtemCabecalho();
            return true;
        }

        return true;
    });

    formataCabecalho();

    // Controle da pesquisa Assosicado
    controlaPesquisaAssociado('frmCabContas');

    cNrConta.focus();

    // Se foi chamada pela tela MATRIC (inclusao de nova conta), carregar as rotinas para finalizar cadastro
    if (cNrConta.val() != "" && cSeqTitular.val() != "") {
        obtemCabecalho();
    }

});

// Função para setar foco na rotina
function focoRotina(id, flgEvent) {
    if (!flgAcessoRotina || $("#labelRot" + id).html() == "&nbsp;") {
        return false;
    }

    if (flgEvent) { // MouserOver
        $("#labelRot" + id).css({
            backgroundColor: "#FFB4A0",
            cursor: "pointer"
        });
    } else { // MouseOut
        $("#labelRot" + id).css({
            backgroundColor: "#E3E2DD",
            cursor: "default"
        });
    }
}

// Função para fechar div com mensagens de alerta
function encerraMsgsAlerta() {
    // Esconde div
    $("#divMsgsAlerta").css("visibility", "hidden");

    $("#divListaMsgsAlerta").html("&nbsp;");

    if (flgMostraAnota) {
        // Mostra div 
        $("#divAnotacoes").css("visibility", "visible");

        // Bloqueia conteúdo que está átras do div de Anotações
        blockBackground(parseInt($("#divAnotacoes").css("z-index")));

        // Flag para não mostrar a tela de anotações
        flgMostraAnota = false;
    } else {
        // Esconde div de bloqueio
        unblockBackground();
    }
}

// Função para acessar rotinas da tela CONTAS
function acessaRotina(nomeValidar, nomeTitulo, nomeURL, opeProdutos) {

    // Verifica se é uma chamada válida
    if (!flgAcessoRotina) {
        return false;
    }

    // Mostra mensagem de aguardo	
    showMsgAguardo("Aguarde, carregando  " + nomeTitulo + " ...");

    var nomeDaTela = 'CONTAS';
    var url = UrlSite + "telas/contas/" + nomeURL + "/" + nomeURL;

    if (nomeURL == "procuradores" || nomeURL == 'produtos') {

        var urlScript = UrlSite + "includes/" + nomeURL + "/" + nomeURL;

    } else if (executandoProdutos == true || executandoImpedimentos == true) {
        var url = UrlSite + "telas/atenda/" + nomeURL + "/" + nomeURL;
        var urlScript = UrlSite + "telas/atenda/" + nomeURL + "/" + nomeURL;
        var nomeDaTela = 'ATENDA';

    } else {

        var urlScript = UrlSite + "telas/contas/" + nomeURL + "/" + nomeURL;

    }

    verrespo = false;
    permalte = false;

    // Carrega biblioteca javascript da rotina
    // Ao carregar efetua chamada do conteúdo da rotina através de ajax
    $.getScript(urlScript + ".js", function () {

        nmrotina = removeAcentos(nomeTitulo);

        $.ajax({
            type: "POST",
            dataType: "html",
            url: url + ".php",
            data: {
                nrdconta: nrdconta,
                idseqttl: idseqttl,
                inpessoa: inpessoa,
                nmdatela: nomeDaTela,
                nmrotina: nomeValidar,
                flgcadas: flgcadas,
                opeProdutos: opeProdutos,
                redirect: "html_ajax" // Tipo de retorno do ajax
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "Não foi possível concluir a requisição.", "Alerta - Aimaro", "");
            },
            success: function (response) {
                $("#divRotina").html(response);

                $('.fecharRotina').click(function () {
                    idseqttl = $('#idseqttl', '#frmCabContas').val();
                    fechaRotina(divRotina);
					if (executandoImpedimentos){
						sequenciaImpedimentos();
					}
                    return false;
                });
            }
        });
    });
}

function removeAcentos(str) {
    return str.replace(/[àáâãäå]/g, "a").replace(/[ÀÁÂÃÄÅ]/g, "A").replace(/[ÒÓÔÕÖØ]/g, "O").replace(/[òóôõöø]/g, "o").replace(/[ÈÉÊË]/g, "E").replace(/[èéêë]/g, "e").replace(/[Ç]/g, "C").replace(/[ç]/g, "c").replace(/[ÌÍÎÏ]/g, "I").replace(/[ìíîï]/g, "i").replace(/[ÙÚÛÜ]/g, "U").replace(/[ùúûü]/g, "u").replace(/[ÿ]/g, "y").replace(/[Ñ]/g, "N").replace(/[ñ]/g, "n");
}

// Função para visualizar div da rotina
function mostraRotina() {
    $("#divRotina").css("visibility", "visible");
}

// Função para esconder div da rotina e carregar dados da conta novamente
function encerraRotina(flgCabec) {

    $("#divRotina").css("visibility", "hidden");
    $("#divRotina").html("");

    // Para esconder o F2
    nmrotina = ""

    if (executandoProdutos) {

        if (executandoProdutosServicos && (posicao < produtosTelasServicos.length)) {
            eval(produtosTelasServicos[posicao]);
            posicao++;
            return false;

        } else if (executandoProdutosServicosAdicionais && (posicao < produtosTelasServicosAdicionais.length)) {
            eval(produtosTelasServicosAdicionais[posicao]);
            posicao++;
            return false;
        }

    }

    if (flgCabec) {
        obtemCabecalho();
    } else {
        // Retira trava do fundo
        divError.escondeMensagem();
    }
}

function sequenciaImpedimentos() {
    if (executandoImpedimentos) {	
		if (posicao <= produtosCancMContas.length) {
			if (produtosCancMContas[posicao - 1] == '' || produtosCancMContas[posicao - 1] == 'undefined'){
				eval(produtosCancM[posicao - 1]);
				posicao++;
			}else{
				eval(produtosCancMContas[posicao - 1]);
				posicao++;
			}
            return false;
        }else{
			eval(produtosCancM[posicao - 1]);
			posicao++;
			return false;
}
    }
}

// Função para carregar dados da conta informada
function obtemCabecalho(id, opbackgr, assincrono) {
    opbackgr = (typeof opbackgr == 'undefined') ? true : opbackgr;
    assincrono = (typeof assincrono == 'undefined') ? true : assincrono;

    if (opbackgr) showMsgAguardo('Aguarde, carregando dados da conta/dv ...');

    // Armazena conta/dv e seq.contas informadas
    nrdconta = normalizaNumero($("#nrdconta", "#frmCabContas").val());
    idseqttl = (typeof id == 'undefined') ? normalizaNumero($("#idseqttl", "#frmCabContas").val()) : id;

    // Se nenhum dos tipos de conta foi informado
    if (nrdconta == '') {
        hideMsgAguardo();
        showError("error", "Informe o número da Conta/dv.", "Alerta - Aimaro", "$('#nrdconta').focus()");
        limparDadosCampos();
        return false;
    }

    if (!validaNroConta(nrdconta)) {
        hideMsgAguardo();
        showError("error", "Conta/dv inválida.", "Alerta - Aimaro", "$('#nrdconta','#frmCabContas').focus()");
        limparDadosCampos();
        return false;
    }

    // Carrega dados da conta através de ajax
    $.ajax({
        type: "POST",
        async: assincrono,
        url: UrlSite + "telas/contas/obtem_cabecalho.php",
        data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            opbackgr: opbackgr,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "Não foi possível concluir a requisição.", "Alerta - Aimaro", "$('#nrdconta','#frmCabContas').focus()");
        },
        success: function (response) {
            try {
                if (opbackgr) {
                    $("#frmCabContas").fadeTo(1, 0.01);
                    eval(response);
                    formataCabecalho();
                    removeOpacidade('frmCabContas');
                } else {
                    eval(response);
                    formataCabecalho();
                }
                if (flgcadas == 'M') {
                    trataCadastramento();
                }
				if (executandoImpedimentos){
					sequenciaImpedimentos();
				}else if (flgimped){
					retornaImpedimentos();
				}
            } catch (error) {
                hideMsgAguardo();
                showError("error", "Não foi possível concluir a requisição. " + error.message + ".", "Alerta - Aimaro", "$('#nrdconta','#frmCabContas').focus()");
            }
        }
    });
}

// Função para limpar campos com dados da conta
function limparDadosCampos() {
    // Limpa campos com dados pessoais da conta
    for (i = 0; i < document.frmCabContas.length; i++) {
        if (document.frmCabContas.elements[i].name == "nrdconta") continue;

        document.frmCabContas.elements[i].value = "";
    }

    // Limpa campos com saldos da conta
    for (i = 0; i < 24; i++) {
        $("#labelRot" + i).html("&nbsp;").unbind("click");

    }
    $("#idseqttl").html("<option value=\"1\"></option>");

    return true;
}

// Função para carregar os titulares da conta 
function obtemTitular() {

    var nmextttl = $("#nmextttl", "#frmCabContas").val(); // nome do titular

    //popula o combo somente na primeira vez
    if (nmextttl != "") {
        return false;
    }
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando os titulares da conta/dv ...");

    // Armazena conta/dv e seq.contas informadas
    nrdconta = retiraCaracteres($("#nrdconta", "#frmCabContas").val(), "0123456789", true);

    // Se nenhum dos tipos de conta foi informado
    if (nrdconta == "") {
        hideMsgAguardo();
        showError("error", "Informe o número da Conta/dv.", "Alerta - Aimaro", "$('#nrdconta').focus()");
        return false;
    }

    // Se conta/dv foi informada, valida
    if (nrdconta != "") {
        if (!validaNroConta(nrdconta)) {
            hideMsgAguardo();
            showError("error", "Conta/dv inválida.", "Alerta - Aimaro", "$('#nrdconta','#frmCabContas').focus()");
            limparDadosCampos();
            return false;
        }
    }

    // Carrega dados da conta através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/contas/obtem_titulares.php",
        data: {
            nrdconta: nrdconta,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "Não foi possível concluir a requisição.", "Alerta - Aimaro", "$('#nrdconta','#frmCabContas').focus()");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "Não foi possível concluir a requisição. " + error.message + ".", "Alerta - Aimaro", "$('#nrdconta','#frmCabContas').focus()");
            }
        }
    });
}

/*!
 * ALTERAÇÃO : 006
 * OBJETIVO  : Função para formatar os campos do cabeçalho de contas, a fim de limparmos o código do formulário
 */
function formataCabecalho() {

    var grupoEditavel = $('#nrdconta,#idseqttl', '#frmCabContas');
    var grupoAmbos = $('#cdagenci,#nrmatric,#cdtipcta,#nrdctitg', '#frmCabContas');
    var grupoPF = $('#nmextttl,#inpessoa,#nrcpfcgc,#cdsexotl,#cdestcvl,#cdsitdct', '#divRotinaPF');
    var grupoPJ = $('#nmextttl,#nmfansia,#nrcpfcgc,#inpessoa,#cdsitdct', '#divRotinaPJ');

    grupoEditavel.habilitaCampo();
    grupoAmbos.desabilitaCampo();
    grupoPF.habilitaCampo();
    grupoPJ.habilitaCampo();

    $('br', '#frmCabContas').css({ 'clear': 'both' });
    $('a', '#frmCabContas').css({ 'float': 'right', 'font-size': '11px', 'padding-top': '4px' });

    // Rótulos comum a PF e PJ
    $('label[for="nrdconta"]', '#frmCabContas').addClass('rotulo rotulo-60');
    $('label[for="idseqttl"]', '#frmCabContas').css({ 'width': '68px' });
    $('label[for="cdagenci"]', '#frmCabContas').addClass('rotulo rotulo-40');
    $('label[for="nrmatric"]', '#frmCabContas').css({ 'width': '35px' });
    $('label[for="cdtipcta"]', '#frmCabContas').css({ 'width': '45px' });
    $('label[for="nrdctitg"]', '#frmCabContas').css({ 'width': '50px' });

    // Largura dos campos comum a PF e PJ
    $('#nrdconta', '#frmCabContas').css({ 'width': '67px', 'text-align': 'right' });
    $('#idseqttl', '#frmCabContas').css({ 'width': '194px' });
    $('#cdagenci', '#frmCabContas').css({ 'width': '120px' })
    $('#nrmatric', '#frmCabContas').css({ 'width': '50px', 'text-align': 'right' });
    $('#cdtipcta', '#frmCabContas').css({ 'width': '124' });
    $('#nrdctitg', '#frmCabContas').css({ 'width': '69px', 'text-align': 'right' });

    // Hack IE
    if ($.browser.msie) {
        $('#nrdctitg', '#frmCabContas').css({ 'width': '66px' });
        $('hr', '#frmCabContas').css({ 'margin': '25px 0px 0px 0px', ' ': '0px', 'color': '#777', 'display': 'block', 'height': '1px' });
    } else {
        $('hr', '#frmCabContas').css({ 'background-color': '#777', 'height': '1px', 'margin': '24px 0px 2px 0px' });
    }

    if (inpessoa < 2) { // CASO PF
        $('#divRotinaPJ', '#frmCabContas').css('visibility', 'hidden').empty();
        $('#divRotinaPF', '#frmCabContas').css('visibility', 'visible');
        grupoPF.desabilitaCampo();

        // Rótulos para PF
        $('label[for="nmextttl"],label[for="nrcpfcgc"]', '#divRotinaPF').addClass('rotulo rotulo-40');
        $('label[for="inpessoa"],label[for="cdsitdct"]', '#divRotinaPF').addClass('rotulo-30');
        $('label[for="cdsexotl"]', '#divRotinaPF').css({ 'width': '35px' });
        $('label[for="cdestcvl"]', '#divRotinaPF').css({ 'width': '50px' });

        // Largura dos campos para PF
        $('#nmextttl', '#divRotinaPF').css({ 'width': '380px' });
        $('#inpessoa,#cdsitdct', '#divRotinaPF').css({ 'width': '89px' });
        $('#nrcpfcgc', '#divRotinaPF').css({ 'width': '120px' });
        $('#cdsexotl', '#divRotinaPF').css({ 'width': '20px' });
        $('#cdestcvl', '#divRotinaPF').css({ 'width': '149px' });

        // Hack IE
        if ($.browser.msie) {
            $('#inpessoa,#cdsitdct', '#divRotinaPF').css({ 'width': '86px' });
        }

    } else { // CASO PJ
        $('#divRotinaPF', '#frmCabContas').css('visibility', 'hidden').empty();
        $('#divRotinaPJ', '#frmCabContas').css('visibility', 'visible');
        grupoPJ.desabilitaCampo();

        // Rótulos para PJ
        $('label[for="nmextttl"],label[for="nmfansia"]', '#divRotinaPJ').addClass('rotulo rotulo-90');
        $('label[for="nrcpfcgc"]', '#divRotinaPJ').addClass('rotulo rotulo-40');
        $('label[for="inpessoa"],label[for="cdsitdct"]', '#divRotinaPJ').addClass('rotulo-linha');

        // Largura dos campos para PJ
        $('#nmextttl,#nmfansia', '#divRotinaPJ').css({ 'width': '452px' });
        $('#nrcpfcgc', '#divRotinaPJ').css({ 'width': '120px' });
        $('#inpessoa', '#divRotinaPJ').css({ 'width': '110px' });
        $('#cdsitdct', '#divRotinaPJ').css({ 'width': '159px' });

        // Hack IE
        if ($.browser.msie) {
            $('#nmextttl,#nmfansia', '#divRotinaPJ').css({ 'width': '449px' });
            $('#cdsitdct', '#divRotinaPJ').css({ 'width': '157px' });
        }
    }

    layoutPadrao();
}

/*!
 * ALTERAÇÃO : 007
 * OBJETIVO  : Função para abrir um PDF com a ficha cadastral do titular vigente na tela
 */
function imprimeFichaCadastral(divBloqueio) {

    $('#sidlogin', '#frmCabContas').remove();
    $('#tpregist', '#frmCabContas').remove();

    $('#frmCabContas').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin', '#frmMenu').val() + '" />');
    $('#frmCabContas').append('<input type="hidden" id="tpregist" name="tpregist" value="' + inpessoa + '" />');

    var action = UrlSite + 'telas/contas/ficha_cadastral/imp_fichacadastral.php';
    var callafter = "";

    if (typeof divBloqueio != "undefined") { callafter = "bloqueiaFundo(" + divBloqueio.attr("id") + ");"; }

    carregaImpressaoAyllos("frmCabContas", action, callafter);

}


/*!
 * OBJETIVO  : Função para abrir um PDF com a declaracao de pessoa exposta politicamente
 */
function imprimeDeclaracao() {

    $('#sidlogin', '#frmCabContas').remove();
    $('#tpregist', '#frmCabContas').remove();

    $('#frmCabContas').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin', '#frmMenu').val() + '" />');
    $('#frmCabContas').append('<input type="hidden" id="tpregist" name="tpregist" value="' + inpessoa + '" />');

    $('#tpexposto', '#frmCabContas').remove();
    $('#cdocupacao', '#frmCabContas').remove();
    $('#cdrelacionamento', '#frmCabContas').remove();
    $('#dtinicio', '#frmCabContas').remove();
    $('#dttermino', '#frmCabContas').remove();
    $('#nmempresa', '#frmCabContas').remove();
    $('#nrcnpj_empresa', '#frmCabContas').remove();
    $('#nmpolitico', '#frmCabContas').remove();
    $('#nrcpf_politico', '#frmCabContas').remove();
    $('#inpolexp', '#frmCabContas').remove();
    $('#nmextttl', '#frmCabContas').remove();
    $('#nrcpfcgc', '#frmCabContas').remove();
    $('#rsdocupa', '#frmCabContas').remove();
    $('#dsrelacionamento', '#frmCabContas').remove();	
	$('#cidade', '#frmCabContas').remove();

    var url = UrlSite + "telas/contas/ppe/";

    $.ajax({
        type: "POST",
        dataType: "html",
        url: url + "busca_ppe.php",
        data: {
            nrdconta: nrdconta,
            idseqttl: idseqttl,
            nomeform: 'frmCabContas',
            inpessoa: inpessoa,
            flgcadas: flgcadas,
            redirect: "html_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "Não foi possível concluir a requisição.", "Alerta - Aimaro", "");
        },
        success: function (response) {
            $("#divRotina").html(response); //append dos campos em frmCabContas

            hideMsgAguardo();

            var action = UrlSite + 'telas/contas/ppe/imprime_declaracao.php';
            var callafter = "";

            if ($('#inpolexp', '#frmCabContas').val() != 2) {
                carregaImpressaoAyllos("frmCabContas", action, callafter);
            }
        }
    });
}


// Funcao chamada quando for inclusao de uma nova conta (Tela MATRIC)
function trataCadastramento() {

    // Limpar tela anterior
    $("#divMsgsAlerta").css('visibility', 'hidden');

    // Se vem da MATRIC, abrir 1.era rotina dependendo o tipo de pessoa
    if (inpessoa == 1) {
        acessaRotina('Dados Pessoais', 'Dados Pessoais', 'dados_pessoais');
    }
    else {
        acessaRotina('IDENTIFICACAO', 'Identificação', 'identificacao_juridica');
    }

}

function dossieDigdoc(cdproduto){
	
	var mensagem = 'Aguarde, acessando dossie...';
	showMsgAguardo( mensagem );

	// Carrega dados da conta através de ajax
	$.ajax({
		type	: 'POST',
		dataType: 'html',
		url		: UrlSite + 'telas/digdoc.php',
		data    :
				{
					nrdconta	: nrdconta,
					cdproduto   : cdproduto, // Codigo do produto
                    nmdatela    : 'CONTAS',
 					redirect	: 'script_ajax'
				},
		error   : function(objAjax,responseError,objExcept) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','estadoInicial();');
				},
		success : function(response) {
					hideMsgAguardo();
					blockBackground(parseInt($('#divRotina').css('z-index')));
					if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
						try {
							eval( response );
							return false;
						} catch(error) {
							hideMsgAguardo();							
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
						}
					} else {
						try {
							eval( response );							
						} catch(error) {
							hideMsgAguardo();
							showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
						}
					}
				}
	});

	return false;
}

function retornaImpedimentos(){
	
    // Limpar tela anterior
    $("#divMsgsAlerta").css('visibility', 'hidden');

	acessaRotina('IMPEDIMENTOS DESLIGAMENTO', 'Impedimentos', 'impedimentos_desligamento');
}

// Rotina generica para buscar nome da pessoa e validar se poderá ser alterado
function buscaNomePessoa_gen(nrcpfcgc,nmdcampo, nmdoform){

    var nrdocnpj = nrcpfcgc;

    hideMsgAguardo();

    var mensagem = '';

    mensagem = 'Aguarde, buscando nome da pessoa ...';

    showMsgAguardo(mensagem);    

    nrdocnpj = normalizaNumero(nrdocnpj);
    
    // Nao deve buscar nome caso campo esteja zerado/em branco
    if (nrdocnpj == "" || nrdocnpj == "0" ){   
        $('#'+nmdcampo,'#'+nmdoform ).habilitaCampo();     
        hideMsgAguardo();
        return false;
    }
    

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + 'telas/contas/busca_nome_pessoa.php',
        data: {
            nrdocnpj: nrdocnpj,
            nmdcampo: nmdcampo,
            nmdoform: nmdoform,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Aimaro", "$('#cddopcao','#frmCabCadlng').focus()");
        },
        success: function (response) {
            try {
                hideMsgAguardo();
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Aimaro", "$('#cddopcao','#frmPesqti').focus()");
            }
        }
    });
}
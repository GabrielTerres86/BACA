/*!
 * FONTE        : orifol.js
 * CRIAÇÃO      : Christian Grauppe - ENVOLTI
 * DATA CRIAÇÃO : Janeiro/2019
 * OBJETIVO     : Biblioteca de funções da tela CADMOT
 * -------------
 *
 * -------------
 */

/*/ Variaveis
var rCdoriflh, rDsoriflh, rIdvarmes, rCdhisdeb, rCdhsdbcp, rCdhiscre, rCdhscrcp, rFldebemp,
        cCdoriflh, cDsoriflh, cIdvarmes, cCdhisdeb, cCdhsdbcp, cCdhiscre, cCdhscrcp, cFldebfol;
*/

var indrowid;
var	regIdmotivo;
var	regDsmotivo;
var regCdproduto;
var regFlgreserva_sistema;
var regFlgativo;
var regFlgtipo;
var regFlgexibe;
var rFlgtipo;
var rFlgexibe;
var rCdproduto;
var rDsproduto;

var cTodosCabecalho;

var qtdRegis	= 20;

// Tela
$(document).ready(function () {
    estadoInicial();
});

function estadoInicial() {

    // Efeito de inicializacao
    $('#divTela').fadeTo(0, 0.1);

    controlaLayout();

    // Remove Opacidade da Tela
    removeOpacidade('divTela');

    buscaMotivos(1, qtdRegis);
    return false;
}

// Monta a tela Principal
function controlaLayout() {
    // Habilta
    $('#frmCab').css({'display': 'block'});
    $('#divBotoes').css({'display': 'block'});

	indrowid   = "";

    layoutPadrao();
    return false;
}

/* Acessar tela principal da rotina */
function acessaOpcaoAba() {

    /* Monta o conteudo atraves dos botoes de incluir/alterar */

    $.ajax({
        dataType: "html",
        type: "POST",
        url: UrlSite + "telas/cadmot/form_dados.php",
        data: {
            indrowid: indrowid,
			regIdmotivo: regIdmotivo,
			regDsmotivo: regDsmotivo,
			regCdproduto: regCdproduto,
			regFlgreserva_sistema: regFlgreserva_sistema,
			regFlgativo: regFlgativo,
            regFlgtipo: regFlgtipo,
            regFlgexibe: regFlgexibe,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function (response) {
            $("#divConteudoOpcao").html(response);
            atualizaSeletor();
        }
    });
    return false;
}


/*
    Função para concentrar todas operaçãos de inclusão
        
    Autor: David Valente [Envolti]
    Data: 23/04/2019

 */
function novo(){
    
    // Limpa o conteúdo das variáveis
    regIdmotivo  = "";
	regDsmotivo  = "";
	regCdproduto = "";
	regFlgativo  = "";
    regFlgtipo   = "";
    regFlgexibe  = "";
    regFlgreserva_sistema = "";

    return true;
}

/**
 *  Controla os eventos na tabela
 *  Autor: David Valente [Envolti]
 *  Data: 23/04/2019
 */

function controlaEventosDaTabela(){

    var divRegistro = $('div.divRegistros', '#tabMotivo');
    
    // seleciona o registro que é clicado
    $('table > tbody > tr', divRegistro).click(function () {
        selecionaTabela($(this));         
    });

    // seleciona o registro que é clicado
    $('table > tbody > tr', divRegistro).dblclick(function () {
        selecionaTabela($(this));  
        btnAlterar();
    });

    // seleciona o registro que é focado
    $('table > tbody > tr', divRegistro).focus(function () {    
        selecionaTabela($(this));          
    });

}

// Cabecalho Principal
function atualizaSeletor() {

    if ( $('#frmDados').size() > 0) {
         
        /** Formulario Dados **/
        $('label[for="idmotivo"]', '#frmDados').css({width:'180px'});
        $('label[for="dsmotivo"]', '#frmDados').css({width:'180px'});
        $('label[for="cdproduto"]', '#frmDados').css({width:'180px'});	
        $('label[for="flgativo"]', '#frmDados').css({width:'180px'});
        $('label[for="flgtipo"]', '#frmDados').css({width:'180px'});
        $('label[for="flgexibe"]', '#frmDados').css({width:'180px'});	
        $('label[for="flgreserva_sistema"]', '#frmDados').css({width:'180px'});
        
        $('#idmotivo').addClass('campo').css({width:'50px'});
        $('#dsmotivo').addClass('campo').css({width:'250px'});
        $('#cdproduto').addClass('campo').css({width:'250px'});    
        $('#flgativo').addClass('campo');
        $('#flgexibe').addClass('campo');
        $('#flgtipo').addClass('campo');
        $('#flgreserva_sistema').addClass('campo');	

        cTodosCabDados = $('input[type="text"],select,textArea', '#frmDados');

    }
    
    highlightObjFocus($('#frmDados'));

    return false;
}

// Botoes
function btnIncluir() {  
    mostrarTela("I");
    return false;
}

function btnAlterar() {
    mostrarTela("A");
    return false;
}

// Monta Grid Inicial
function buscaMotivos(nriniseq, nrregist) {
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/cadmot/busca_motivos.php",
        data: {
            nriniseq: nriniseq,
            nrregist: nrregist,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "");
        },
        success: function (response) {
            $("#divCab").html(response);
            formataTabela();
        }
    });
    return false;
}

// Formata tabela de dados da remessa
function formataTabela() {

    // Habilita a conteudo da tabela
    $('#divCab').css({'display': 'block'});

    var divRegistro = $('div.divRegistros', '#tabMotivo');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);
    var conteudo = $('#conteudo', linha).val();

	$('#frmCab', '#divTela').css({'margin-top':'10px'});
    $('#tabMotivo').css({'margin-top': '1px'});
    divRegistro.css({'height': '325px', 'padding-bottom': '1px'});

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '60px';
    arrayLargura[1] = '400px';
    arrayLargura[2] = '200px';
    arrayLargura[3] = '90px';
    arrayLargura[4] = '90px';
    arrayLargura[5] = '90px';
    arrayLargura[6] = '90px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'center';
    arrayAlinha[6] = 'center';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

    hideMsgAguardo();

    this.controlaEventosDaTabela();

    return false;
}


/**
 * Função para garantir os dados da linha da tabela em variavies
 * 
 */
function selecionaTabela(tr) {
	
    
    // Pega os valores dos campos hidden e seta nas variáveis    
    regIdmotivo  = $('.idmotivo', tr).val();
	regDsmotivo  = $('.dsmotivo', tr).val();
	regCdproduto = $('.cdproduto', tr).val();	
	regFlgativo  = $('.flgativo', tr).val();
    regFlgtipo   = $('.flgtipo', tr).val();
    regFlgexibe  = $('.flgexibe', tr).val();  
    regFlgreserva_sistema = $('.flgreserva_sistema', tr).val();

    return true;
}

function mostrarTela(opcao) {

    // Alterar Registro
    if (opcao == "A") { 
        
        // Verifica se tem algum registro selecionado
        if ($.find(".corSelecao").length == 0) {

            showError("error", "Selecione um registro antes de alterar.", "Alerta - Ayllos", "");
             return false;
        }  

        // Pega o registro selecionado na tabela
        this.selecionaTabela($("tr.corSelecao"));    

    } else {
          // Inclusão de novo registro
          this.novo();
    } 

    /* Abre nova tela para inclusao/edicao */
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/cadmot/cadastro_motivo.php",
        data: {
			opcao: opcao,
            redirect: "html_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function (response) {
            mostraRotina();
            $("#divRotina").html(response);            
        }
    });
    
    this.controlaEventosDaTabela();
    
    return false;
}

// Função para visualizar div da rotina
function mostraRotina() {
    $("#divRotina").css("visibility", "visible");
    $("#divRotina").centralizaRotinaH();
}

// Função para esconder div da rotina e carregar dados da conta novamente
function encerraRotina(flgCabec) {
    $("#divRotina").css({"width": "545px", "visibility": "hidden"});
    $("#divRotina").html("");

    // Esconde div de bloqueio
    unblockBackground();
    return false;
}

function gravarMotivo() {

    var rowid      = $('#indrowid', '#frmDados').val();
	var idmotivo   = $('#idmotivo', '#frmDados').val();
	var dsmotivo   = $('#dsmotivo', '#frmDados').val();
	var cdproduto  = $('#cdproduto', '#frmDados').val();
	var dsproduto  = $('#cdproduto', '#frmDados').text();
	var flgreserva_sistema = $('#flgreserva_sistema', '#frmDados').val();
	var flgativo   = $('#flgativo', '#frmDados').val();
    var flgtipo    = $('#flgtipo', '#frmDados').val();
    var flgexibe   = $('#flgexibe', '#frmDados').val();
	
    // Verificando qual tipo de gravacao
    if (rowid == "") {
        var descricao = "inserindo";
    } else {
        var descricao = "atualizando";
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, " + descricao + " dados...");

    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/cadmot/gravar_dados.php",
        data: {
            rowid:     rowid,
			idmotivo:  idmotivo,
			dsmotivo:  dsmotivo,
			cdproduto: cdproduto,
			flgreserva_sistema: flgreserva_sistema,
			flgativo:  flgativo,
            flgtipo:   flgtipo,
            flgexibe:  flgexibe,
            redirect: "html_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            cTodosCabDados.removeClass('campoErro');
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });

    return false;
}
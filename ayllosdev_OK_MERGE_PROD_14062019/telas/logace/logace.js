/*!
 * FONTE        : logace.js
 * CRIAÇÃO      : Guilherme Boettcher (Supero)
 * DATA CRIAÇÃO : 14/02/2013
 * OBJETIVO     : Biblioteca de funções da tela LOGACE
 * --------------
 * ALTERAÇÕES   :
 *
 *
 * --------------
 */

// Definição de algumas variáveis globais
var cddopcao		='C';
var nrdconta 		= 0 ;
var tpaplica 		= 0 ;
var nraplica 		= 0 ;
var cddopcao 		= 0 ;
var dsdconta 		= ''; // Armazena o Nome do Associado
var cdcopdet; // Codigo Cooperativa - DETALHE
var dsteldet; // Codigo Tela - DETALHE
var dsoridet; // Codigo Origem - DETALHE

//Formulários
var frmCab   		= 'frmCab';
var tabDados		= 'tabDados';
var tabDetail   	= 'tabDetalhes';

//Labels/Campos do cabeçalho
var rCdcooper, rDsdatela, rIdorigem, rDtiniper, rDtfimper, rCdfiltro,
    cCdcooper, cDsdatela, cIdorigem, cDtiniper, cDtfimper, cCdfiltro, cTodosCabecalho, btnCab;

$(document).ready(function() {

    estadoInicial();

    highlightObjFocus( $('#'+frmCab) );

    //$('fieldset > legend').css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 2px'});
    //$('fieldset').css({'clear':'both','border':'1px solid #777','margin':'3px 0px','padding':'10px 3px 5px 3px'});

    return false;

});

// seletores
function estadoInicial() {

    // Configura Tela
    $('#divTela').fadeTo(0,0.1);

    $('#divDetalhes').html("");
    $('#divResultado').html("");

    $('#frmCab').css({'display':'block'});
    $('#divResultado').css({'display':'none'});
    $('#divDetalhes').css({'display':'none'});


    // // Preparando a Tela
    formataCabecalho();

    // cTodosCabecalho.limpaFormulario();

    removeOpacidade('divTela');
    unblockBackground();
    hideMsgAguardo();

    $('#divBotoes').css({'display':'block'});
    $('#btVoltar'       ,'#divBotoes').hide();
    $('#btnContinuar'   ,'#divBotoes').show();
    $('#btSalvar','#divBotoes').show();

    // Inicia Compos
    setaDatasTela();
    $('#cdcooper','#frmCab').val('99');
    $('#cdfiltro','#frmCab').val('1');
    $('#idorigem','#frmCab').val('0');
	$('#dsdatela','#frmCab').val('');
    $('#DivPeriodo').css({'display':'block'});

    $('#cdcooper','#'+frmCab).focus();

    $('input,select', '#frmCab').removeClass('campoErro');

    controlaFoco();

    //return false;
}

function controlaFoco() {

    $('#cdcooper','#frmCab').unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            $('#dsdatela','#frmCab').focus();
            return false;
        }
    });

    $('#dsdatela','#frmCab').unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            $('#idorigem','#frmCab').focus();
            return false;
        }
    });

    $('#idorigem','#frmCab').unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            $('#cdfiltro','#frmCab').focus();
            return false;
        }
    });


    $('#cdfiltro','#frmCab').unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            if ( cCdfiltro.val() == 3 ) {
                $('#btSalvar','#divBotoes').hide();
                btnContinuar();
            } else {
                $('#dtiniper','#frmCab').focus();
            }
            return false;
        }
    });

    $('#dtiniper','#frmCab').unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            $('#dtfimper','#frmCab').focus();
            return false;
        }
    });

    $('#dtfimper','#frmCab').unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            $('#btSalvar','#divBotoes').hide();
            btnContinuar();
            return false;
        }
    });

    $('#btSalvar','#divBotoes').unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            $('#btSalvar','#divBotoes').hide();
            btnContinuar();
            return false;
        }
    });

}

function formataCabecalho() {

    // Rotulos
    rCdcooper			= $('label[for="cdcooper"]','#'+frmCab);
    rDsdatela			= $('label[for="dsdatela"]','#'+frmCab);
    rIdorigem           = $('label[for="idorigem"]','#'+frmCab);
    rDtiniper			= $('label[for="dtiniper"]','#'+frmCab);
    rDtfimper			= $('label[for="dtfimper"]','#'+frmCab);
    rCdfiltro           = $('label[for="cdfiltro"]','#'+frmCab);

    // Campos
    cCdcooper			= $('#cdcooper','#'+frmCab);
    cDsdatela			= $('#dsdatela','#'+frmCab);
    cIdorigem           = $('#idorigem','#'+frmCab);
    cDtiniper			= $('#dtiniper','#'+frmCab);
    cDtfimper			= $('#dtfimper','#'+frmCab);
    cCdfiltro			= $('#cdfiltro','#'+frmCab);
    cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);

    rCdcooper.addClass('rotulo').css({'width':'200px'});
    rDsdatela.addClass('rotulo').css({'width':'200px'});
    rIdorigem.addClass('rotulo').css({'width':'200px'});
    rDtiniper.addClass('rotulo-linha').css({'width':'200px'});
    rDtfimper.addClass('rotulo-linha').css({'width':'25px'});
    rCdfiltro.addClass('rotulo').css({'width':'200px'});

    cCdcooper.css({'width':'150px'});
    cDsdatela.css({'width':'60px'});
    cDtiniper.addClass('data').css({'width':'90px'});
    cDtfimper.addClass('data').css({'width':'90px'});
    cCdfiltro.css({'width':'220px'});

    if ( $.browser.msie ) {

        rCdcooper.css({'width':'200px'});
        rDsdatela.css({'width':'200px'});
        rIdorigem.css({'width':'200px'});
        rDtiniper.css({'width':'200px'});
        rDtfimper.css({'width': '25px'});
        rCdfiltro.css({'width':'200px'});

        cDsdatela.css({'width':'60px'});
        cDtiniper.css({'width':'90px'});
        cDtfimper.css({'width':'90px'});
    }

    //cTodosCabecalho.habilitaCampo();

    cTodosCabecalho.habilitaCampo().removeClass('campoErro');

    layoutPadrao();
    return false;
}

// Ajusta data
function dataString(vData) {

    var dtArray = vData.split('/');

    switch (dtArray[1]) {
    case "1":
    case "2":
    case "3":
    case "4":
    case "5":
    case "6":
    case "7":
    case "8":
    case "9":
        vMes = "0" + (dtArray[1]);
        break;
    default:
        vMes = dtArray[1];
    }

    return dtArray[0] + "/" + vMes + "/" + dtArray[2];
}

function buscaDia(vDia){

    // Concatena o 1 a 9 com 0 na frente
    if (vDia < 10) {vDia = "0" + vDia}

    return vDia;
}

function focaRegistroSelecionado(valor) {

    var campo = document.getElementById(valor);
    campo.focus();

    //$('#'+valor,'#frmCab').focus();
    //return false;
 }


// Botoes
function btnVoltar() {
    estadoInicial();
    return false;
}

function btnVoltar2(){

    $('#divDetalhes').css({'display':'none'});
    fechaRotina($('#divRotina'));
    operacao = "P"; // RETORNA AO MODO DE PESQUISA
    return false;
}


function setaDatasTela() {

    var dtHoje  = new Date();
    dtIniPer 	=  dataString("01/" + (dtHoje.getMonth() + 1)  + "/" + dtHoje.getFullYear());
    dtFimPer 	=  dataString(buscaDia(dtHoje.getDate()) + "/" + (dtHoje.getMonth() + 1) + "/" + dtHoje.getFullYear());

    $('#dtiniper','#frmCab').val(dtIniPer);
    $('#dtfimper','#frmCab').val(dtFimPer);
    return false;
}

function ocultar(valor) {

    if (valor == "3") { // Telas Nunca Acessadas
        $('#DivPeriodo').css({'display':'none'});
    } else {
        $('#DivPeriodo').css({'display':'block'});
        setaDatasTela(); // Periodos de Datas
    }

    return false;
}


function btnContinuar() {
    
    $('#btVoltar','#divBotoes').show();

    $('#divDetalhes').css({'display':'none'});
    $('#divResultado').css({'display':'none'});
    operacao = "P"; // RETORNA AO MODO DE PESQUISA

    cdcopdet = ''; // Codigo Cooperativa - DETALHE
    dsteldet = ''; // Codigo Tela - DETALHE
    dsoridet = ''; // Codigo Origem - DETALHE

    var dtiniper    = cDtiniper.val();
    var dtfimper    = cDtfimper.val();
    var dtArrIni    = dtiniper.split('/');
    var dtArrFim    = dtfimper.split('/');
    var cmpDtiniper = parseInt(dtArrIni[2] + dtArrIni[1] + dtArrIni[0]);
    var cmpDtfimper = parseInt(dtArrFim[2] + dtArrFim[1] + dtArrFim[0]);

    if (cCdfiltro.val() != "3") {
        if (dtiniper == "") {
            showError('error','Data Inicial deve ser informada para pesquisa!','Alerta - Ayllos','focaCampoErro(\'dtiniper\',\''+ frmCab +'\');');
            return false;
        }
        if ( cmpDtiniper > cmpDtfimper ) {
            showError('error','Data Inicial superior a Data Final!','Alerta - Ayllos','focaCampoErro(\'dtiniper\',\''+ frmCab +'\');');
            return false;
        }
		if (dtfimper == "") {
            showError('error','Data Final deve ser informada para pesquisa!','Alerta - Ayllos','focaCampoErro(\'dtfimper\',\''+ frmCab +'\');');
            return false;
        }
    }

	cTodosCabecalho.desabilitaCampo();
	
    // Se chegou até aqui, a data é diferente do vazio e é válida, então realizar a operação desejada
    executaPesquisa(1,50);
    return false;
}

function executaPesquisa( nriniseq, nrregist) {

    /****************************************
    nriniseq => Seq do registro inicial
    nrregist => Qtde de Registros para exibir
    ****************************************/

    //nrinicio = nriniseq; // Guarda ultimo seq inicial
    //nrsequen = nrregist; // Guarda quantidade de registros

    var operacao = "P"; // MODO DE PESQUISA

    cTodosCabecalho.removeClass('campoErro');

    // Controle de Exibicao de Mensagem
    showMsgAguardo("Aguarde, executando pesquisa...");

    var cdcooper = cCdcooper.val();
    var dsdatela = cDsdatela.val();
    var idorigem = cIdorigem.val();
    var dtiniper = cDtiniper.val();
    var dtfimper = cDtfimper.val();
    var cdfiltro = cCdfiltro.val();

    // Executa script de bloqueio através de ajax
    $.ajax({
        type    : "POST",
        dataType: 'html',
        url     : UrlSite + "telas/logace/manter_rotina.php",
        data    :
                {   cdcooper: cdcooper,
                    dsdatela: dsdatela,
                    idorigem: idorigem,
                    dtiniper: dtiniper,
                    dtfimper: dtfimper,
                    cdfiltro: cdfiltro,
                    nriniseq: nriniseq,
                    nrregist: nrregist,
                    operacao: operacao,
                    redirect: "script_ajax"
                },
        error   : function(objAjax,responseError,objExcept) {
                    hideMsgAguardo();
                    showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
                },
        success : function(response) {
            try {
                if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
                    try {
                            $('#divResultado').html(response);
                            formataTabResultado();
                            return false;
                    } catch(error) {
                            hideMsgAguardo();
                            cTodosCabecalho.habilitaCampo();
                            showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
                    }
                } else {
                    try {
                        eval(response);
                        cTodosCabecalho.habilitaCampo();
                        return false;
                    } catch(error) {
                        hideMsgAguardo();
                        cTodosCabecalho.habilitaCampo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
                    }
                }
                return false;
            } catch(error) {
                hideMsgAguardo();
                showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });

    return false;
}


function executaPesquisaDetalhe( nriniseq, nrregist ) {

    /****************************************
    nriniseq => Seq do registro inicial
    nrregist => Qtde de Registros para exibir
    ****************************************/

    var operacao = "D";

    // Mostra mensagem de aguardo
    cTodosCabecalho.removeClass('campoErro');
    showMsgAguardo("Aguarde, buscando detalhes...");

    var cdcooper = cdcopdet;
    var dsdatela = dsteldet;
    var idorigem = dsoridet;
    var dtiniper = cDtiniper.val();
    var dtfimper = cDtfimper.val();
    var cdfiltro = cCdfiltro.val();

    // Executa script de bloqueio através de ajax
    $.ajax({
        type    : "POST",
        dataType: 'html',
        url     : UrlSite + "telas/logace/manter_rotina.php",
        data    :
                {   cdcooper: cdcooper,
                    dsdatela: dsdatela,
                    idorigem: idorigem,
                    dtiniper: dtiniper,
                    dtfimper: dtfimper,
                    cdfiltro: cdfiltro,
                    nriniseq: nriniseq,
                    nrregist: nrregist,
                    operacao: operacao,
                    redirect: "script_ajax"
                },
        error   : function(objAjax,responseError,objExcept) {
                    hideMsgAguardo();
                    showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
                },
        success : function(response) {
            try {
                if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
                    try {
                        exibeRotina($('#divRotina'));
                        $('#divDetalhes').html(response);
                        $('#btDetalhe','#tabDados').blur();
                        exibeDetalhes();
                        return false;
                    } catch(error) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
                    }
                } else {
                    try {
                        eval(response);
                        return false;
                    } catch(error) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
                    }
                }
            } catch(error) {
                hideMsgAguardo();
                showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });

    return false;
}


function formataTabResultado() {

    $('#divResultado').css({'display':'block'});

    var divRegistro = $('div.divRegistros','#'+tabDados);
    var tabela      = $('table', divRegistro );
    var linha       = $('table > tbody > tr', divRegistro );

    $('#'+tabDados).css({'margin-top':'5px'});
    divRegistro.css({'height':'180px','padding-bottom':'2px'});

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '54px';
    arrayLargura[1] = '95px';
    arrayLargura[2] = '85px';
    arrayLargura[3] = '85px';
    arrayLargura[4] = '85px';
    arrayLargura[5] = '85px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'center';

    var metodoTabela = '';

    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );
    hideMsgAguardo();

    // seleciona o registro que é clicado
    $('table > tbody > tr', divRegistro).live("click", function() {
        cdcopdet = $('#cdcooper', this).val();
        dsteldet = $('#dsdatela', this).val();
        dsoridet = $('#idorigem', this).val();
    });

    $('table > tbody > tr', divRegistro).dblclick(function() {
        ver_detalhes($('#cdcooper', this).val(), $('#dsdatela', this).val(), $('#idorigem', this).val(), 1, 10);
    });

    return false;
}

function ver_detalhes(cooper, tela, origem, nriniseq, qtdregis){

    // Para opcoes Nao Acessadas e Nunca Acessadas, nao tem "Detalhes"
    if (cCdfiltro.val() != 1) {return false;}

    showMsgAguardo("Aguarde, buscando detalhes...");

    // Executa Script de Confirmação Através de Ajax
    $.ajax({
        type    : 'POST',
        dataType: 'html',
        url     : UrlSite + 'telas/logace/frame_resultados.php',
        data    :
                {
                    redirect: 'html_ajax'
                },
        error: function(objAjax,responseError,objExcept) {
                hideMsgAguardo();
                showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
        },
        success: function(response) {
            hideMsgAguardo();
            try {
                if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
                    try {
                            $('#divRotina').html(response);
                            detalheLog(cooper, tela, origem, nriniseq, qtdregis);
                            return false;
                    } catch(error) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
                    }
                } else {
                    try {
                        eval(response);
                        return false;
                    } catch(error) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
                    }
                }
            } catch(error) {
                showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
                hideMsgAguardo();
            }
        }
    });

    return false;
}

function detalheLog(cooper, tela, origem, nriniseq, qtdregis){

    hideMsgAguardo();
    showMsgAguardo("Aguarde, buscando detalhes...");
    operacao = "D"; // MODO DE DETALHES

    var cdcooper = cooper;
    var dsdatela = tela;
    var idorigem = origem;
    var dtiniper = cDtiniper.val();
    var dtfimper = cDtfimper.val();
    var cdfiltro = cCdfiltro.val();
    var nriniseq = 1;
    var nrregist = qtdregis;

    // Executa script de bloqueio através de ajax
    $.ajax({
        type    : "POST",
        dataType: 'html',
        url     : UrlSite + "telas/logace/manter_rotina.php",
        data    :
                {   cdcooper: cdcooper,
                    dsdatela: dsdatela,
                    idorigem: idorigem,
                    dtiniper: dtiniper,
                    dtfimper: dtfimper,
                    cdfiltro: cdfiltro,
                    nriniseq: nriniseq,
                    nrregist: nrregist,
                    operacao: operacao,
                    redirect: "script_ajax"
                },
        error   : function(objAjax,responseError,objExcept) {
                    hideMsgAguardo();
                    showError('error','N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
                },
        success : function(response) {
            try {
                if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
                    try {
                            exibeRotina($('#divRotina'));
                            $('#divDetalhes').html(response);
                            exibeDetalhes();
                            return false;
                        } catch(error) {
                            hideMsgAguardo();
                            showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
                        }
                } else {
                    try {
                        eval(response);
                        return false;
                    } catch(error) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
                    }
                }
            } catch(error) {
                hideMsgAguardo();
                showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });

    return false;
}


function exibeDetalhes() {

    highlightObjFocus($('#tabDetalhes'));

    formataTabDetalhes();
//	$('#btDetalhe','#tabDados').blur();

    $('#divDetalhes').css({'width':'500px', 'height':'280px'});

    // centraliza a divRotina
    $('#divRotina').css({'width':'600px'});
    $('#divDetalhes').css({'width':'600px'});
    $('#divRotina').centralizaRotinaH();

    hideMsgAguardo();
    bloqueiaFundo( $('#divRotina') );

    return false;
}


function formataTabDetalhes() {

    $('#divResultado').css({'display':'block'});

    var divRegistro = $('div.divRegistros','#'+tabDetail);
    var tabela      = $('table', divRegistro );
    var linha       = $('table > tbody > tr', divRegistro );

    $('#'+tabDetail).css({'margin-top':'5px'});
    divRegistro.css({'height':'165px','padding-bottom':'2px'});

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '75px';
    arrayLargura[1] = '330px';
    arrayLargura[2] = '95px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'center';

    var metodoTabela = '';

    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );

    /********************
     FORMATA COMPLEMENTO
    *********************/

    // complemento linha 1
    var linha1  = $('ul.complemento', '#linha1').css({'margin-left':'1px','width':'99.5%'});

        $('li:eq(0)', linha1).addClass('txtNormalBold').css({'width':'12%','text-align':'right'});
        $('li:eq(1)', linha1).addClass('txtNormal').css({'width':'20%'});
        $('#dscooper','.complemento').html( $('#dscooper').val() );

        $('li:eq(2)', linha1).addClass('txtNormalBold').css({'width':'13%','text-align':'right'});
        $('li:eq(3)', linha1).addClass('txtNormal').css({'width':'15%'});
        $('#dsdatela','.complemento').html( $('#dsdatela').val() );

        $('li:eq(4)', linha1).addClass('txtNormalBold').css({'width':'19%','text-align':'right'});
        $('li:eq(5)', linha1).addClass('txtNormal').css({'width':'15%'});
        $('#dsorigem','.complemento').html( $('#dsorigem').val() );

    return false;
}
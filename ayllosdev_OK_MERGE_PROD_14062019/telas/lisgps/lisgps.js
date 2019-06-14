/*!
 * FONTE        : lisgps.js
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Setembro/2015
 * OBJETIVO     : Biblioteca de funções da tela LISGPS
 * --------------
 * ALTERAÇÕES   : 01/09/2016 - Implementar funções referente a Opção S, que está sendo inclusa 
 *                             na tela para atender ao SD 514294. (Renato Darosci - Supero)
 *
 * -----------------------------------------------------------------------
 */

// Variaveis
var rCddopcao, rDtpagmto, rCdagenci, rNrdcaixa, rCdidenti,
    cCddopcao, cDtpagmto, cCdagenci, cNrdcaixa, cCdidenti;

var cTodosCab,cTodosCabDados, btnOK;

// Controle de linha de tabela
var linhaPagto = "";

// Tela
$(document).ready(function() {
    estadoInicial();
});

function estadoInicial() {

    // Efeito de inicializacao
    $('#divTela').fadeTo(0,0.1);

    // Remove Opacidade da Tela
    removeOpacidade('divTela');

    // Habilita Forms
    $('#frmCab').css({'display':'block'});

    // Habilita Div's
    $('#divConsulta').css({ 'display': 'block' });
    $('#divPaCaixa').css({ 'display': 'block' });
    $('#divVisualizar').css({'display':'none'});
    $('#frmConsulta').css({'display':'none'});
    $('#divBotoes').css({'display':'none'});

    // Desabilita Botao de Comprovante
    $('#btExibirCompr','#divBotoes').hide();

    formataCabecalho();

    cCddopcao.habilitaCampo();
    btnOK.habilitaCampo();
    linhaPagto = "";
    cCddopcao.val('C');
    cDtpagmto.val(dtmvtolt);
    cCddopcao.focus();

    return false;
}

// Cabecalho Principal
function formataCabecalho() {

    /* Declaracao dos campos */
    rCddopcao          = $('label[for="cddopcao"]','#frmCab');
    rDtpagmto          = $('label[for="dtpagmto"]','#frmDados');
    rCdagenci          = $('label[for="cdagenci"]','#frmDados');
    rNrdcaixa          = $('label[for="nrdcaixa"]','#frmDados');
    rCdidenti          = $('label[for="cdidenti"]','#frmDados');

    cCddopcao          = $('#cddopcao','#frmCab');
    cDtpagmto          = $('#dtpagmto','#frmDados');
    cCdagenci          = $('#cdagenci','#frmDados');
    cNrdcaixa          = $('#nrdcaixa','#frmDados');
    cCdidenti          = $('#cdidenti','#frmDados');

    btnOK              = $('#btnOK','#frmCab');
    cTodosCab          = $('input[type="text"],select,textArea','#frmCab');
    cTodosCabDados     = $('input[type="text"],select,textArea','#frmDados');

    /* Definicao dos campos na tela */
    rCddopcao.css({'width':'170px'});
    rDtpagmto.css({'width':'150px'});
    rCdagenci.css({'width':'50px'});
    rNrdcaixa.css({'width':'50px'});
    rCdidenti.css({'width':'150px'});

    cCddopcao.addClass('campo').css({'width':'465px','text-align':'right'});
    cDtpagmto.addClass('campo').addClass('data').css({'width':'100px','text-align':'center'});
    cCdagenci.addClass('campo').css({'width':'80px','text-align':'right'}).setMask("INTEGER", "000");
    cNrdcaixa.addClass('campo').css({'width':'80px','text-align':'right'}).setMask("INTEGER", "000");
    cCdidenti.addClass('campo').css({'width':'130px','text-align':'right'}).setMask("INTEGER", "000000000000000000");

    highlightObjFocus( $('#frmCab') );
    highlightObjFocus( $('#frmDados') );
    inicializaCampo();
    controlaFoco();
    return false;
}

// Controla a navegacao dos campos
function controlaFoco() {

    cCddopcao.unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            cCddopcao.desabilitaCampo();

            configuraTela();

            return false;
        }
    });

    btnOK.unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            cCddopcao.desabilitaCampo();

            configuraTela();

            return false;
        }
    });

    btnOK.unbind('click').bind('click', function(){
        cCddopcao.desabilitaCampo();
        btnOK.desabilitaCampo();
        
        configuraTela();

        return false;
    });

    cDtpagmto.unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            if (cCddopcao.val() == "S") {
                cCdidenti.focus();
            } else {
            cCdagenci.focus();
        }
        }
    });

    cCdagenci.focusin(function() { if (cCdagenci.val()==0 || cCdagenci.val()=="") { cCdagenci.val("") } });
    cCdagenci.unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            cNrdcaixa.focus();
        }
    });
    cCdagenci.focusout(function() { if (cCdagenci.val()==0 || cCdagenci.val()=="") { cCdagenci.val(0) }; });

    cNrdcaixa.focusin(function() { if (cNrdcaixa.val()==0 || cNrdcaixa.val()=="") { cNrdcaixa.val("") } });
    cNrdcaixa.unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            if (cCddopcao.val()=="V") {
                cCdidenti.focus();
                return false;
            } else {
                cCddopcao.desabilitaCampo();
                $('#divBotoes', '#divTela').css({'display':'block'});
                cDtpagmto.focus();
                btnProsseguir();
            }
        }
    });
    cNrdcaixa.focusout(function() { if (cNrdcaixa.val()==0 || cNrdcaixa.val()=="") { cNrdcaixa.val(0) }; });

    cCdidenti.focusin(function() { if (cCdidenti.val()==0 || cCdidenti.val()=="") { cCdidenti.val("") } });
    cCdidenti.unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            btnProsseguir();
        }
    });

    layoutPadrao();
    return false;
}

function configuraTela() {

    $('#divBotoes', '#divTela').css({ 'display': 'block' });
    cDtpagmto.focus();

    switch (cCddopcao.val()) {
        case "V":
            $('#divVisualizar').css({ 'display': 'block' });
            break;
        case "S":
            $('#divPaCaixa').css({ 'display': 'none' });
            $('#divVisualizar').css({ 'display': 'block' });
            break;
        default:
            $('#divPaCaixa').css({ 'display': 'block' });
    }
    
}


function btnVoltar() {
    cTodosCabDados.habilitaCampo();
    $('#btProsseguir','#divBotoes').show();
    estadoInicial();
}

function btnProsseguir() {

    if (cCdidenti.val()==0 || cCdidenti.val()=="") { cCdidenti.val(0) };

    switch (cCddopcao.val()) {
        case "C":
            consultaGps(); // Consulta totais de GPS
            break;
        case "V":
            visualizaGps(); // Visualiza os pagamentos GPS
            break;
        case "S":
            salvarXML();  // Realizar o download do(s) arquivo(s) XML conforme parametros informados
            break;
        default:
            break;
    }

}

function consultaGps() {

    var dtpagmto = cDtpagmto.val();
    var cdagenci = cCdagenci.val();
    var nrdcaixa = cNrdcaixa.val();

    // Desabilita
    cTodosCabDados.desabilitaCampo();
    $('#btProsseguir','#divBotoes').hide();

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, buscando dados...");

    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/lisgps/consulta_gps.php",
        data: {
            dtpagmto : dtpagmto,
            cdagenci : cdagenci,
            nrdcaixa : nrdcaixa,
            redirect : "html_ajax" // Tipo de retorno do ajax
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","btnVoltar()");
        },
        success: function(response) {
            cTodosCabDados.removeClass('campoErro');
            hideMsgAguardo();
            try {
                if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
                    try {
                        $('#frmConsulta').css({'display':'block'});
                        $('#divConteudoGps').html(response);
                    } catch(error) {
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"btnVoltar()");
                    }
                } else {
                    try {
                        eval(response);
                    } catch(error) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"btnVoltar()");
                    }
                }
            } catch(error) {
                hideMsgAguardo();
                showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","btnVoltar()");
            }
        }
    });

    return false;
}

function visualizaGps() {

    var dtpagmto = cDtpagmto.val();
    var cdagenci = cCdagenci.val();
    var nrdcaixa = cNrdcaixa.val();
    var cdidenti = cCdidenti.val();

    // Desabilita
    cTodosCabDados.desabilitaCampo();
    $('#btProsseguir','#divBotoes').hide();

    // Habilita Botao de Comprovante
    $('#btExibirCompr','#divBotoes').show();

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, buscando dados...");

    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/lisgps/detalhes_gps.php",
        data: {
            dtpagmto : dtpagmto,
            cdagenci : cdagenci,
            nrdcaixa : nrdcaixa,
            cdidenti : cdidenti,
            redirect : "html_ajax" // Tipo de retorno do ajax
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","btnVoltar()");
        },
        success: function(response) {
            cTodosCabDados.removeClass('campoErro');
            hideMsgAguardo();
            try {
                if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
                    try {
                        $('#frmConsulta').css({'display':'block'});
                        $('#divConteudoGps').html(response);
                        formataTabela();
                    } catch(error) {
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"btnVoltar()");
                    }
                } else {
                    try {
                        eval(response);
                    } catch(error) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos',"btnVoltar()");
                    }
                }
            } catch(error) {
                hideMsgAguardo();
                showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","btnVoltar();");
            }
        }
    });

    return false;
}

// Função chamada para baixar os arquivos solicitados
function salvarXML() {

    var dtpagmto = cDtpagmto.val();
    var cdidenti = cCdidenti.val();
    
    if (dtpagmto == "") {
        //hideMsgAguardo();
        showError("error", "Data Pagamento n&atilde;o informada.", "Alerta - Ayllos", "cDtpagmto.focus()");
        return false;
    }

    if (cdidenti == "" || cdidenti == 0) {
        //hideMsgAguardo();
        showError("error", "Identificador n&atilde;o informado.", "Alerta - Ayllos", "cCdidenti.focus()");
    return false;
}
    
    showMsgAguardo("Aguarde, gerando arquivo ZIP ...");

    // Executa script de consulta através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/lisgps/baixar_arquivo.php',
        data: {
            dtpagmto: dtpagmto,
            cdidenti: cdidenti,
            redirect: 'script_ajax'
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
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });

}


// Formata tabela de dados da remessa
function formataTabela() {

    // Habilita a conteudo da tabela
    $('#divConteudo').css({'display':'block'});

    var divRegistro = $('div.divRegistros', '#tabDados');
    var tabela      = $('table', divRegistro );
    var linha       = $('table > tbody > tr', divRegistro );

    $('#tabDados').css({'margin-top':'5px'});
    divRegistro.css({'height':'75px','padding-bottom':'1px'});

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '90px';
    arrayLargura[1] = '90px';
    arrayLargura[2] = '250px';
    arrayLargura[3] = '80px';
    arrayLargura[4] = '50px';
    arrayLargura[5] = '50px';
    arrayLargura[6] = '80px';
    arrayLargura[7] = '80px';
    arrayLargura[8] = '15px';

    var arrayAlinha = new Array();
        arrayAlinha[0] = 'center';
        arrayAlinha[1] = 'center';
        arrayAlinha[2] = 'left';
        arrayAlinha[3] = 'center';
        arrayAlinha[4] = 'center';
        arrayAlinha[5] = 'center';
        arrayAlinha[6] = 'right';
        arrayAlinha[7] = 'right';

    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

    // complemento linha 1
    var linha1  = $('ul.complemento', '#linha1').css({'margin-left':'1px','width':'99.5%'});

        $('li:eq(0)', linha1).addClass('txtNormalBold').css({'width':'14%','text-align':'right'});
        $('li:eq(1)', linha1).addClass('txtNormal').css({'width':'35%'});
        $('#cdbarras','.complemento').html($('#cdbarras').val());

        $('li:eq(2)', linha1).addClass('txtNormalBold').css({'width':'17%','text-align':'right'});
        $('li:eq(3)', linha1).addClass('txtNormal').css({'width':'30%'});
        $('#tpdpagto','.complemento').html($('#tpdpagto').val());

    // complemento linha 2
    var linha2  = $('ul.complemento', '#linha2').css({'margin-left':'1px','width':'99.5%'});

        $('li:eq(0)', linha2).addClass('txtNormalBold').css({'width':'14%','text-align':'right'});
        $('li:eq(1)', linha2).addClass('txtNormal').css({'width':'20%'});
        $('#nrctapag','.complemento').html($('#nrctapag').val());

        $('li:eq(2)', linha2).addClass('txtNormalBold').css({'width':'5%','text-align':'right'});
        $('li:eq(3)', linha2).addClass('txtNormal').css({'width':'40%'});
        $('#nmprimtl','.complemento').html($('#nmprimtl').val());

    // complemento linha 3
    var linha3  = $('ul.complemento', '#linha3').css({'margin-left':'1px','width':'99.5%'});

        $('li:eq(0)', linha3).addClass('txtNormalBold').css({'width':'14%','text-align':'right'});
        $('li:eq(1)', linha3).addClass('txtNormal').css({'width':'25%'});
        $('#dsidenti','.complemento').html($('#dsidenti').val());

        $('li:eq(2)', linha3).addClass('txtNormalBold').css({'width':'20%','text-align':'right'});
        $('li:eq(3)', linha3).addClass('txtNormal').css({'width':'40%'});
        $('#cddpagto','.complemento').html($('#cddpagto').val());

    // complemento linha 4
    var linha4  = $('ul.complemento', '#linha4').css({'margin-left':'1px','width':'99.5%'});

        $('li:eq(0)', linha4).addClass('txtNormalBold').css({'width':'14%','text-align':'right'});
        $('li:eq(1)', linha4).addClass('txtNormal').css({'width':'25%'});
        $('#mmaacomp','.complemento').html($('#mmaacomp').val());

        $('li:eq(2)', linha4).addClass('txtNormalBold').css({'width':'20%','text-align':'right'});
        $('li:eq(3)', linha4).addClass('txtNormal').css({'width':'40%'});
        $('#dtvencto','.complemento').html($('#dtvencto').val());

    // complemento linha 5
    var linha5  = $('ul.complemento', '#linha5').css({'margin-left':'1px','width':'99.5%'});

        $('li:eq(0)', linha5).addClass('txtNormalBold').css({'width':'14%','text-align':'right'});
        $('li:eq(1)', linha5).addClass('txtNormal').css({'width':'25%'});
        $('#vlrdinss','.complemento').html($('#vlrdinss').val());

        $('li:eq(2)', linha5).addClass('txtNormalBold').css({'width':'20%','text-align':'right'});
        $('li:eq(3)', linha5).addClass('txtNormal').css({'width':'40%'});
        $('#vlrjuros','.complemento').html($('#vlrjuros').val());

    // complemento linha 6
    var linha6  = $('ul.complemento', '#linha6').css({'margin-left':'1px','width':'99.5%'});

        $('li:eq(0)', linha6).addClass('txtNormalBold').css({'width':'14%','text-align':'right'});
        $('li:eq(1)', linha6).addClass('txtNormal').css({'width':'25%'});
        $('#vlrouent','.complemento').html($('#vlrouent').val());

        $('li:eq(2)', linha6).addClass('txtNormalBold').css({'width':'20%','text-align':'right'});
        $('li:eq(3)', linha6).addClass('txtNormal').css({'width':'40%'});
        $('#vlrtotal','.complemento').html($('#vlrtotal').val());

    // complemento linha 7
    var linha7  = $('ul.complemento', '#linha7').css({'margin-left':'1px','width':'99.5%'});

        $('li:eq(0)', linha7).addClass('txtNormalBold').css({'width':'14%','text-align':'right'});
        $('li:eq(1)', linha7).addClass('txtNormal').css({'width':'25%'});
        $('#hrtransa','.complemento').html($('#hrtransa').val());

        $('li:eq(2)', linha7).addClass('txtNormalBold').css({'width':'20%','text-align':'right'});
        $('li:eq(3)', linha7).addClass('txtNormal').css({'width':'40%'});
        $('#nrautdoc','.complemento').html($('#nrautdoc').val());

    // complemento linha 8
    var linha8  = $('ul.complemento', '#linha8').css({'margin-left':'1px','width':'99.5%'});

        $('li:eq(0)', linha8).addClass('txtNormalBold').css({'width':'14%','text-align':'right'});
        $('li:eq(1)', linha8).addClass('txtNormal').css({'width':'25%'});
        $('#inpesgps','.complemento').html($('#inpesgps').val());

        $('li:eq(2)', linha8).addClass('txtNormalBold').css({'width':'20%','text-align':'right'});
        $('li:eq(3)', linha8).addClass('txtNormal').css({'width':'40%'});
        $('#nrseqagp','.complemento').html($('#nrseqagp').val());

    hideMsgAguardo();

    /* Atribuindo o foco para a linha da tabela, pois ao clicar no cabecalho nao retornava
    para linha da tabela, dessa maneira a tela apresentava erro na hora de alterar ou
    excluir o registro selecionado */


    $('table > thead > tr > th', divRegistro).unbind('click').bind('click', function() {
        $('table > tbody > tr > td', divRegistro).focus();
    });

    // seleciona o registro que é clicado
    $('table > tbody > tr', divRegistro).click( function() {
        selecionaTabela($(this));
    });

    // seleciona o registro que é focado
    $('table > tbody > tr', divRegistro).focus( function() {
        selecionaTabela($(this));
    });

    $('table > tbody > tr:eq(0)', divRegistro).click();
    return false;
}

function selecionaTabela(tr) {
    $('#cdcooper','.complemento').html( $('#cdcooper', tr).val() );
    $('#dtmvtolt','.complemento').html( $('#dtmvtolt', tr).val() );
    $('#cdopecxa','.complemento').html( $('#cdopecxa', tr).val() );
    $('#idsicred','.complemento').html( $('#idsicred', tr).val() );
    $('#cdagenci','.complemento').html( $('#cdagenci', tr).val() );
    $('#nrdcaixa','.complemento').html( $('#nrdcaixa', tr).val() );
    $('#nmoperad','.complemento').html( $('#nmoperad', tr).val() );
    $('#nrsequni','.complemento').html( $('#nrsequni', tr).val() );
    $('#cdbccxlt','.complemento').html( $('#cdbccxlt', tr).val() );
    $('#nrdolote','.complemento').html( $('#nrdolote', tr).val() );
    $('#vlrdinss','.complemento').html( $('#vlrdinss', tr).val() );
    $('#vlrtotal','.complemento').html( $('#vlrtotal', tr).val() );
    $('#tpdpagto','.complemento').html( $('#tpdpagto', tr).val() );
    $('#cdbarras','.complemento').html( $('#cdbarras', tr).val() );
    $('#nrctapag','.complemento').html( $('#nrctapag', tr).val() );
    $('#nmprimtl','.complemento').html( $('#nmprimtl', tr).val() );
    $('#dsidenti','.complemento').html( $('#dsidenti', tr).val() );
    $('#cddpagto','.complemento').html( $('#cddpagto', tr).val() );
    $('#mmaacomp','.complemento').html( $('#mmaacomp', tr).val() );
    $('#dtvencto','.complemento').html( $('#dtvencto', tr).val() );
    $('#vlrjuros','.complemento').html( $('#vlrjuros', tr).val() );
    $('#vlrouent','.complemento').html( $('#vlrouent', tr).val() );
    $('#hrtransa','.complemento').html( $('#hrtransa', tr).val() );
    $('#nrautdoc','.complemento').html( $('#nrautdoc', tr).val() );
    $('#inpesgps','.complemento').html( $('#inpesgps', tr).val() );
    $('#nrseqagp','.complemento').html( $('#nrseqagp', tr).val() );
    $('#nrseqdig','.complemento').html( $('#nrseqdig', tr).val() );
    $('#cdidenti','.complemento').html( $('#cdidenti', tr).val() );

    // Para comprovantes que não são de agendamentos (nrseqagp>0)
    // Não irá gerar comprovante

    if ($('#cdagenci', tr).val()== '90') {
        $('#btExibirCompr','#divBotoes').show();
    }else{
    $('#btExibirCompr','#divBotoes').hide();
    }

    // Guarda a linha que será utilizada
    // para gerar o comprovante
    linhaPagto = tr;

    return false;
}

function btnExibirCompr() {

    // Guarda os dados para impressao
    $('#nrdconta','#frmImpressao').val( $('#nrctapag', linhaPagto).val().replace(/\./g,'') );
    $('#nrseqdig','#frmImpressao').val( $('#nrseqdig', linhaPagto).val() );
	$('#dsidenti','#frmImpressao').val( $('#dsidenti', linhaPagto).val() );
	$('#dtmvtolt','#frmImpressao').val( $('#dtmvtolt', linhaPagto).val() );

    var action = UrlSite + 'telas/lisgps/imprimir_dados.php';

    carregaImpressaoAyllos('frmImpressao',action,"");
}

function inicializaCampo() {
     cDtpagmto.val("0");
     cCdagenci.val("0");
     cNrdcaixa.val("0");
     cCdidenti.val("0");
     linhaPagto = "";
    return false;
}

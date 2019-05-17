/*!
 * FONTE        : manprt.js
 * CRIA��O      : Helinton Steffens (DB1) 
 * DATA CRIA��O : 13/03/2018
 * OBJETIVO     : Biblioteca de fun��es da tela MANPRT
 */
/*!
  16/04/2019 - INC0011935 - Melhorias diversas nos layouts de teds e conciliação:
               - modal de conciliação arrastável e correção das colunas para não obstruir as caixas de seleção;
               - aumentadas as alturas das listas de teds e modal de conciliação, reajustes das colunas (Carlos)

*/
//Formul�rios e Tabela
var frmCab = 'frmCab';
var frmOpcao = 'frmOpcao';
var frmTabela = 'frmTabela';

var cddopcao = 'T';
var tpconsul = '';
var flgregis = '';
var inestcri = '';
var consulta = '';
var tprelato = '';

var nrJanelas = 0;
var nriniseq = 1;
var nrregist = 50;
var vrsarqvs = '';
var arquivos = '';
var cTodosFiltroOpS = '';
var ni = 0;
var flgimped = false;

var registro;

$(document).ready(function () {
    estadoInicial();
});

// inicio
function estadoInicial() {

    $('#divFormulario').fadeTo(0, 0.1);

    // retira as mensagens	
    hideMsgAguardo();

    // formulario	
    formataCabecalho();
    cTodosCabecalho.limpaFormulario().removeClass('campoErro');

    fechaRotina($('#divUsoGenerico'));
    fechaRotina($('#divRotina'));

    $('#' + frmOpcao).remove();
    $('#' + frmTabela).remove();
    $('#divBotoes:eq(0)', '#divFormulario').remove();
    $('#divPesquisaRodape', '#divFormulario').remove();

    cCddopcao.val(cddopcao);
    cCddopcao.habilitaCampo().focus();

    removeOpacidade('divFormulario');
}

function realizaoConsultaTed(nriniseq, nrregist) {
    var numregis = nrregist;
    var iniseque = nriniseq;
    var inidtpro = $('#inidtpro', '#' + frmOpcao).val();
    var fimdtpro = $('#fimdtpro', '#' + frmOpcao).val();
    var inivlpro = normalizaNumero($('#inivlpro', '#' + frmOpcao).val());
    var fimvlpro = normalizaNumero($('#fimvlpro', '#' + frmOpcao).val());
    var indconci = $('#indconci', '#' + frmOpcao).val();
    var dscartor = $('#dscartor', '#' + frmOpcao).val();
	
    cTodosOpcao.removeClass('campoErro');

    var mensagem = 'Aguarde, buscando dados ...';
    showMsgAguardo(mensagem);

    // Carrega dados da conta atraves de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/manprt/obtem_consulta_ted.php',
        data:
				{   
                    inidtpro: inidtpro,
                    fimdtpro: fimdtpro,
                    inivlpro: inivlpro,
                    fimvlpro: fimvlpro,
                    indconci: indconci,
                    dscartor: dscartor,
				    nrregist: nrregist,
				    nriniseq: nriniseq,
				    redirect: 'script_ajax'
				},
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function (response) {
            hideMsgAguardo();
            formataCabecalho();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divFormulario').html(response);
                    return false;
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            } else {
                try {
                    eval(response);
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            }
        }
    });

    return false;
}

function realizaoConsultaConciliacao(nriniseq, nrregist) {
    var numregis = nrregist;
    var iniseque = nriniseq;
    var inidtpro = $('#inidtpro', '#' + frmOpcao).val();
    var fimdtpro = $('#fimdtpro', '#' + frmOpcao).val();
    var inivlpro = normalizaNumero($('#inivlpro', '#' + frmOpcao).val());
    var fimvlpro = normalizaNumero($('#fimvlpro', '#' + frmOpcao).val());
    var indconci = $('#indconci', '#' + frmOpcao).val();
    var dscartor = $('#dscartor', '#' + frmOpcao).val();
	
    cTodosOpcao.removeClass('campoErro');

    var mensagem = 'Aguarde, buscando dados ...';
    showMsgAguardo(mensagem);

    // Carrega dados da conta atraves de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/manprt/obtem_consulta_conciliacao.php',
        data:
				{   
                    inidtpro: inidtpro,
                    fimdtpro: fimdtpro,
                    inivlpro: inivlpro,
                    fimvlpro: fimvlpro,
                    indconci: indconci,
                    dscartor: dscartor,
				    nrregist: nrregist,
				    nriniseq: nriniseq,
				    redirect: 'script_ajax'
				},
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function (response) {
            hideMsgAguardo();
            formataCabecalho();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divFormulario').html(response);
                    return false;
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            } else {
                try {
                    eval(response);
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            }
        }
    });

    return false;
}

function realizaoConsultaCustas() {
    //var form = $('#frmOpcao')
    var inidtpro = $('#inidtpro', '#' + frmOpcao).val();
    var fimdtpro = $('#fimdtpro', '#' + frmOpcao).val();
    var cdcooper = $('#nmrescop', '#' + frmOpcao).val();
    var nrdconta = $('#nrdconta', '#' + frmOpcao).val();
    var cduflogr = $('#cduflogr', '#' + frmOpcao).val();
    var dscartor = $('#dscartor', '#' + frmOpcao).val();
    var flcustas = $('#flcustas', '#' + frmOpcao).val();

    var mensagem = 'Aguarde, buscando dados ...';
    showMsgAguardo(mensagem);

    // Carrega dados da conta atraves de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/manprt/obtem_consulta_custas.php',
        data: {   
            inidtpro: inidtpro,
            fimdtpro: fimdtpro,
            cdcooper: cdcooper,
            nrdconta: nrdconta,
            cduflogr: cduflogr,
            dscartor: dscartor,
            flcustas: flcustas,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function (response) {
            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divFormulario').html(response);
                    return false;
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            } else {
                try {
                    eval(response);
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            }
        }
    });

    return false;
}

// cabecalho
function formataCabecalho() {

    // Label
    rCddopcao = $('label[for="cddopcao"]', '#' + frmCab);
    rCddopcao.css({ 'width': '51px' }).addClass('rotulo');

    // Input
    cCddopcao = $('#cddopcao', '#' + frmCab);
    cCddopcao.css({ 'width': '590px' });

    // Outros	
    cTodosCabecalho = $('input[type="text"], select', '#' + frmCab);
    btnOK1 = $('#btnOk1', '#' + frmCab);
    cTodosCabecalho.desabilitaCampo();

    // Se clicar no botao OK
    btnOK1.unbind('click').bind('click', function () {

        if (divError.css('display') == 'block') { return false; }
        if (cCddopcao.hasClass('campoTelaSemBorda')) { return false; }

        trocaBotao('Avan&ccedilar');
        cddopcao = cCddopcao.val();
        buscaOpcao();

        cCddopcao.desabilitaCampo();
        return false;

    });

    // opcao
    cCddopcao.unbind('keydown').bind('keydown', function (e) {
        if (divError.css('display') == 'block') { return false; }
        // Se � a tecla ENTER, 
        if (e.keyCode == 13) {
            btnOK1.click();
            return false;
        }
    });

    layoutPadrao();
    return false;
}


// opcao
function buscaOpcao() {

    showMsgAguardo('Aguarde, buscando dados ...');
    // Executa script de confirma��es atrav�s de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/manprt/form_opcao_' + cddopcao.toLowerCase() + '.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atildeo foi poss&iacute�vel concluir a requisi&ccedil&atildeo.', 'Alerta - Ayllos', "unblockBackground()");
        },
        success: function (response) {
            $('#divFormulario').html(response);

            formataCabecalho();
 
            cCddopcao.desabilitaCampo();
            cCddopcao.val(cddopcao);

            // limpa formulario
            cTodosOpcao = $('input[type="text"], select', '#' + frmOpcao);
            cTodosOpcao.limpaFormulario().removeClass('campoErro');
            $('#divPesquisaRodape', '#divFormulario').remove();

            if (cddopcao == 'T') {
                formataOpcaoT();
            } else if (cddopcao == 'R') {
                formataOpcaoR();
            } else if (cddopcao == 'C') {
                formataOpcaoC();
            } else if (cddopcao == 'E') {
				formataOpcaoE();
            }

			if (flgimped){
				$('#frmOpcao', '#flgregis').val('yes').change();
				$('#frmOpcao', '#tprelato').val('5').change();
				btnContinuar();
			}

            hideMsgAguardo();
            return false;
        }
    });

    return false;

}

// opcao T
function formataOpcaoT() {

    highlightObjFocus($('#frmOpcao'));

    $('#divFiltro').css({ 'border': '1px solid #777', 'padding': '10px', 'min-height': '50px' });

    rInidtpro = $('label[for="inidtpro"]', '#' + frmOpcao);
    rFimdtpro = $('label[for="fimdtpro"]', '#' + frmOpcao);
    rInivlpro = $('label[for="inivlpro"]', '#' + frmOpcao);
    rFimvlpro = $('label[for="fimvlpro"]', '#' + frmOpcao);
    rIndconci = $('label[for="indconci"]', '#' + frmOpcao);
    rDscartor = $('label[for="dscartor"]', '#' + frmOpcao);

    rInidtpro.css({ 'width': '68px' }).addClass('rotulo');
    rFimdtpro.css({ 'width': '65px' }).addClass('rotulo-linha');
    rInivlpro.css({ 'width': '80px', 'margin-left':'50px' }).addClass('rotulo-linha');
    rFimvlpro.css({ 'width': '80px' }).addClass('rotulo-linha');
    rIndconci.css({ 'width': '125px' }).addClass('rotulo-linha');
    rDscartor.css({ 'width': '120px', 'margin-left':'50px' }).addClass('rotulo-linha');

    cInidtpro = $('#inidtpro', '#' + frmOpcao);
    cFimdtpro = $('#fimdtpro', '#' + frmOpcao);
    cInivlpro = $('#inivlpro', '#' + frmOpcao);
    cFimvlpro = $('#fimvlpro', '#' + frmOpcao);
    cIndconci = $('#indconci', '#' + frmOpcao);
    cDscartor = $('#dscartor', '#' + frmOpcao);

    cInidtpro.css({ 'width': '75px' }).addClass('data campo');
    cFimdtpro.css({ 'width': '75px' }).addClass('data campo');
    cInivlpro.css({ 'width': '50px' }).addClass('inteiro campo');
    cFimvlpro.css({ 'width': '50px' }).addClass('inteiro campo');
    cIndconci.css({ 'width': '160px' }).addClass('campo');
    cDscartor.css({ 'width': '130px' }).addClass('campo');
	
	var date = new Date();
    var now = ("0" + date.getDate()).slice(-2) + '/' + ("0" + (date.getMonth() + 1)).slice(-2) + '/' + date.getFullYear();

    if (!cInidtpro.val()) {
        cInidtpro.val(now);
    }

    if (!cFimdtpro.val()) {
        cFimdtpro.val(now);
    }

    layoutPadrao();
    return false;
}

function controlaLayout() {

    $('#divFiltro').css({ 'display': 'block' });

    return false;
}

function formataOpcaoR() {

    var cCdcooper = $('#nmrescop', '#frmOpcao');

    var ehCentral = cCdcooper.length > 0;

    if(ehCentral) {
        cCdcooper.html(slcooper);
        cCdcooper.css('width', '125px').attr('maxlength', '2');
    } else {
        cCddopcao.css('width', '565px');
    }

    highlightObjFocus($('#frmOpcao'));

    $('#divFiltro').css({ 'border': '1px solid #777', 'padding': '10px', 'min-height': '50px' });

    rInidtpro = $('label[for="inidtpro"]', '#' + frmOpcao);
    rFimdtpro = $('label[for="fimdtpro"]', '#' + frmOpcao);
    rNmrescop = $('label[for="nmrescop"]', '#' + frmOpcao);
    rNrdconta = $('label[for="nrdconta"]', '#' + frmOpcao);
    rCduflogr = $('label[for="cduflogr"]', '#' + frmOpcao);
    rDscartor = $('label[for="dscartor"]', '#' + frmOpcao);
    rFlcustas = $('label[for="flcustas"]', '#' + frmOpcao);
    
    rInidtpro.css({ 'width': '68px' }).addClass('rotulo');
    rFimdtpro.css({ 'width': '65px' }).addClass('rotulo-linha'); 
    rNmrescop.css({ 'width': '85px', 'margin-left':'50px' }).addClass('rotulo-linha');
    rNrdconta.css({ 'width': '70px' }).addClass('rotulo-linha');
    rCduflogr.css({ 'margin-left':'43px' }).addClass('rotulo-linha');
    rDscartor.css({ 'width': '120px', 'margin-left':'50px' }).addClass('rotulo-linha');
    rFlcustas.css({ 'width': '135px' }).addClass('rotulo-linha');
        
    cInidtpro = $('#inidtpro', '#' + frmOpcao);
    cFimdtpro = $('#fimdtpro', '#' + frmOpcao);
    cNmrescop = $('#nmrescop', '#' + frmOpcao);
    cNrdconta = $('#nrdconta', '#' + frmOpcao);
    cCduflogr = $('#cduflogr', '#' + frmOpcao);
    cDscartor = $('#dscartor', '#' + frmOpcao);
    cFlcustas = $('#flcustas', '#' + frmOpcao);
    
    cInidtpro.css({ 'width': '75px' }).addClass('data campo');
    cFimdtpro.css({ 'width': '75px' }).addClass('data campo');
    cNmrescop.css({'width': '180px'}).addClass('campo'); 
    cNrdconta.addClass('conta pesquisa campo').css({'width': '80px'});
    cCduflogr.css('width', '25px').attr('maxlength', '2').addClass('campo');
    cDscartor.css({ 'width': '130px' }).addClass('campo');
    cFlcustas.css({ 'width': '180px' }).addClass('campo');

    layoutPadrao();
    return false;
}

function formataOpcaoC() {

    highlightObjFocus($('#frmOpcao'));

    $('#divFiltro').css({ 'border': '1px solid #777', 'padding': '10px', 'min-height': '50px' });

    rInidtpro = $('label[for="inidtpro"]', '#' + frmOpcao);
    rFimdtpro = $('label[for="fimdtpro"]', '#' + frmOpcao);
    rInivlpro = $('label[for="inivlpro"]', '#' + frmOpcao);
    rFimvlpro = $('label[for="fimvlpro"]', '#' + frmOpcao);
    rNmrescop = $('label[for="nmrescop"]', '#' + frmOpcao);
    rNrdconta = $('label[for="nrdconta"]', '#' + frmOpcao);
    rCduflogr = $('label[for="cduflogr"]', '#' + frmOpcao);
    rDscartor = $('label[for="dscartor"]', '#' + frmOpcao);
    
    rInidtpro.css({ 'width': '68px' }).addClass('rotulo');
    rFimdtpro.css({ 'width': '85px' }).addClass('rotulo-linha');
    rInivlpro.css({ 'width': '80px', 'margin-left':'50px' }).addClass('rotulo-linha');
    rFimvlpro.css({ 'width': '80px' }).addClass('rotulo-linha');
    rNmrescop.css({ 'width': '35px' }).addClass('rotulo-linha');
    rNrdconta.css({ 'width': '63px' }).addClass('rotulo-linha');
    rCduflogr.css({ 'margin-left':'43px' }).addClass('rotulo-linha');
    rDscartor.css({ 'width': '120px', 'margin-left':'50px' }).addClass('rotulo-linha');
        
    cInidtpro = $('#inidtpro', '#' + frmOpcao);
    cFimdtpro = $('#fimdtpro', '#' + frmOpcao);
    cInivlpro = $('#inivlpro', '#' + frmOpcao);
    cFimvlpro = $('#fimvlpro', '#' + frmOpcao);
    cNmrescop = $('#nmrescop', '#' + frmOpcao);
    cNrdconta = $('#nrdconta', '#' + frmOpcao);
    cCduflogr = $('#cduflogr', '#' + frmOpcao);
    cDscartor = $('#dscartor', '#' + frmOpcao);
    
    cInidtpro.css({ 'width': '75px' }).addClass('data campo');
    cFimdtpro.css({ 'width': '75px' }).addClass('data campo');
    cInivlpro.css({ 'width': '50px' }).addClass('inteiro campo');
    cFimvlpro.css({ 'width': '50px' }).addClass('inteiro campo');
    cNmrescop.css({'width': '105px'}).addClass('campo'); 
    cNrdconta.addClass('conta pesquisa campo').css({'width': '80px'});
    cCduflogr.css('width', '25px').attr('maxlength', '2').addClass('campo');
    cDscartor.css({ 'width': '130px' }).addClass('campo');

    layoutPadrao();
    return false;
}

function formataOpcaoE() {

    highlightObjFocus($('#frmOpcao'));

    $('#divFiltro').css({ 'border': '1px solid #777', 'padding': '10px', 'min-height': '50px' });

    rInidtpro = $('label[for="dtinimvt"]', '#' + frmOpcao);
    rFimdtpro = $('label[for="dtfimmvt"]', '#' + frmOpcao);
    
    rInidtpro.css({ 'width': '85px' }).addClass('rotulo');
    rFimdtpro.css({ 'width': '85px' }).addClass('rotulo-linha');
        
    cInidtpro = $('#dtinimvt', '#' + frmOpcao);
    cFimdtpro = $('#dtfimmvt', '#' + frmOpcao);
    
    cInidtpro.css({ 'width': '75px' }).addClass('data campo');
    cFimdtpro.css({ 'width': '75px' }).addClass('data campo');

    layoutPadrao();
    return false;
}

// botoes
function btnVoltar() {

	if (flgimped){
		showMsgAguardo('Aguarde, carregando tela ATENDA ...');
		setaParametrosImped('ATENDA','',nrdconta,flgcadas, 'MANPRT');
		setaImped();
		direcionaTela('ATENDA','no');
	}

    estadoInicial();
    return false;
}

function btnContinuar() {

    if (divError.css('display') == 'block') { return false; }

    if (cddopcao == 'T') {
        if (!hasValidPeriod() || !hasValidRange()) {
            return false;
        }
        
        controlaLayout();
        realizaoConsultaTed(nriniseq, nrregist);
    } else if (cddopcao == 'R') {
        controlaLayout();
        realizaoConsultaCustas();
    } else if (cddopcao == 'C') {
        if (!hasValidPeriod() || !hasValidRange()) {
            return false;
        }
        
        controlaLayout();
        realizaoConsultaConciliacao(nriniseq, nrregist);
    }

    return false;
}

function trocaBotao(botao) {

    $('#divBotoes', '#divFormulario').html('');
    $('#divBotoes', '#divFormulario').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>');

    if (botao != '') {
        $('#divBotoes', '#divFormulario').append('&nbsp;<a href="#" class="botao" onclick="btnContinuar(); return false;" >' + botao + '</a>');
    }
    return false;
}

function tipoOptionT() {
    var selopc = ($('#indconci', '#' + frmOpcao)) ? $('#indconci', '#' + frmOpcao).val() : 0;
    if (selopc > 0) {
       $('#indconci', '#' + frmOpcao).val(selopc);
    }

    return false;
}

function controlaOpcao() {

    formataCabecalho();

    if (cddopcao == 'T') {
        $('#divBotoes:eq(0)', '#divFormulario').remove();
        formataTabelaTeds();
        formataOpcaoT();
        controlaLayout();
        $('input, select', '#' + frmOpcao).desabilitaCampo();
        $('#btVoltar', '#divBotoes').focus();
    } else if (cddopcao == 'R') {
        $('#divBotoes:eq(0)', '#divFormulario').remove();
        //formataTabelaCustas();
        formataOpcaoR();
        controlaLayout();
        $('input, select', '#' + frmOpcao).desabilitaCampo();
        $('#btVoltar', '#divBotoes').focus();
    } else if (cddopcao == 'C') {
        $('#divBotoes:eq(0)', '#divFormulario').remove();
        formataTabelaConciliacoes();
        formataOpcaoC();
        controlaLayout();
        $('input, select', '#' + frmOpcao).desabilitaCampo();
        $('#btVoltar', '#divBotoes').focus();
    }

    return false;
}

function formataTabelaConciliacao() {
    var tabela = $('table', '#divRotina .divRegistros');

    var arrayLargura = new Array();
    arrayLargura[0] = '20px';
    arrayLargura[1] = '210px';
    arrayLargura[2] = '120px';
    arrayLargura[3] = '80px';
    arrayLargura[4] = '80px';
    arrayLargura[5] = '65px';
    arrayLargura[6] = '80px';
    arrayLargura[7] = '80px';
    arrayLargura[8] = '80px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'left';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'center';
    arrayAlinha[6] = 'center';
    arrayAlinha[7] = 'right';
    arrayAlinha[8] = 'right';

    tabela.formataTabela([], arrayLargura, arrayAlinha, '');

    return false;
}

function formataTabelaTeds() {

    var divRegistro = $('div.divRegistros', '#' + frmTabela);
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    $('#' + frmTabela).css({ 'margin-top': '10px' });
    divRegistro.css({ 'border': '1px solid #777', 'height': '220px'  });

    var ordemInicial = new Array();
    //ordemInicial = [[0,0]];	

    var arrayLargura = new Array();
    arrayLargura[0] = '210px';
    arrayLargura[1] = '110px';
    arrayLargura[2] = '70px';
    arrayLargura[3] = '80px';
    arrayLargura[4] = '80px';
    arrayLargura[5] = '50px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'left';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'right';


    var metodoTabela = '';
    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

    /********************
	 FORMATA COMPLEMENTO	
	*********************/
    // complemento linha 1
    var linha1 = $('ul.complemento', '#linha1').css({ 'margin-left': '1px', 'width': '99.5%' });

    $('li:eq(0)', linha1).addClass('txtNormalBold').css({ 'width': '18%', 'text-align': 'right' });
    $('li:eq(1)', linha1).addClass('txtNormal').css({ 'width': '48%' });
    $('li:eq(2)', linha1).addClass('txtNormalBold').css({ 'width': '14%', 'text-align': 'right' });
    $('li:eq(3)', linha1).addClass('txtNormal');

    // complemento linha 2
    var linha2 = $('ul.complemento', '#linha2').css({ 'clear': 'both', 'border-top': '0', 'width': '99.5%' });

    $('li:eq(0)', linha2).addClass('txtNormalBold').css({ 'width': '18%', 'text-align': 'right' });
    $('li:eq(1)', linha2).addClass('txtNormal').css({ 'width': '48%' });
    $('li:eq(2)', linha2).addClass('txtNormalBold').css({ 'width': '14%', 'text-align': 'right' });
    $('li:eq(3)', linha2).addClass('txtNormal');

    // complemento linha 3
    var linha3 = $('ul.complemento', '#linha3').css({ 'clear': 'both', 'border-top': '0', 'width': '99.5%' });

    $('li:eq(0)', linha3).addClass('txtNormalBold').css({ 'width': '18%', 'text-align': 'right' });
    $('li:eq(1)', linha3).addClass('txtNormal').css({ 'width': '48%' });
    $('li:eq(2)', linha3).addClass('txtNormalBold').css({ 'width': '14%', 'text-align': 'right' });
    $('li:eq(3)', linha3).addClass('txtNormal');

    // complemento linha 4
    var linha4 = $('ul.complemento', '#linha4').css({ 'clear': 'both', 'border-top': '0', 'width': '99.5%' });

    $('li:eq(0)', linha4).addClass('txtNormalBold').css({ 'width': '18%', 'text-align': 'right' });
    $('li:eq(1)', linha4).addClass('txtNormal').css({ 'width': '48%' });
    $('li:eq(2)', linha4).addClass('txtNormalBold').css({ 'width': '14%', 'text-align': 'right' });
    $('li:eq(3)', linha4).addClass('txtNormal');

    // complemento linha 5
    var linha5 = $('ul.complemento', '#linha5').css({ 'clear': 'both', 'border-top': '0', 'width': '99.5%' });

    $('li:eq(0)', linha5).addClass('txtNormalBold').css({ 'width': '18%', 'text-align': 'right' });
    $('li:eq(1)', linha5).addClass('txtNormal').css({ 'width': '48%' });
    $('li:eq(2)', linha5).addClass('txtNormalBold').css({ 'width': '14%', 'text-align': 'right' });
    $('li:eq(3)', linha5).addClass('txtNormal');

    // seleciona o registro que � clicado
    $('table > tbody > tr', divRegistro).die("click").live("click", function () {
        selecionaTabela($(this));
    });

    // verifica o log do registro com duplo click na linha correspondente
    //$('table > tbody > tr', divRegistro).die("dblclick").live("dblclick", function () {
    //    buscaConsulta('log');
    //});

    //$('table > tbody > tr:eq(0)', divRegistro).click();

    return false;
}

function formataTabelaConciliacoes() {

    var divRegistro = $('div.divRegistros', '#' + frmTabela);
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    $('#' + frmTabela).css({ 'margin-top': '10px' });
    divRegistro.css({ 'border': '1px solid #777', 'height': '130px'  });

    var ordemInicial = new Array();
    //ordemInicial = [[0,0]];	

    var arrayLargura = new Array();
    arrayLargura[0] = '210px';
    arrayLargura[1] = '60px';
    arrayLargura[2] = '50px';
    arrayLargura[3] = '65px';
    arrayLargura[4] = '45px';
    arrayLargura[5] = '70px';
    arrayLargura[6] = '70px';
    arrayLargura[7] = '60px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'right';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'center';
    arrayAlinha[6] = 'right';
    arrayAlinha[7] = 'center';


    var metodoTabela = '';
    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

    /********************
	 FORMATA COMPLEMENTO	
	*********************/
    // complemento linha 1
    var linha1 = $('ul.complemento', '#linha1').css({ 'margin-left': '1px', 'width': '99.5%' });

    $('li:eq(0)', linha1).addClass('txtNormalBold').css({ 'width': '18%', 'text-align': 'right' });
    $('li:eq(1)', linha1).addClass('txtNormal').css({ 'width': '48%' });
    $('li:eq(2)', linha1).addClass('txtNormalBold').css({ 'width': '15%', 'text-align': 'right' });
    $('li:eq(3)', linha1).addClass('txtNormal');

    // complemento linha 2
    var linha2 = $('ul.complemento', '#linha2').css({ 'clear': 'both', 'border-top': '0', 'width': '99.5%' });

    $('li:eq(0)', linha2).addClass('txtNormalBold').css({ 'width': '18%', 'text-align': 'right' });
    $('li:eq(1)', linha2).addClass('txtNormal').css({ 'width': '48%' });
    $('li:eq(2)', linha2).addClass('txtNormalBold').css({ 'width': '15%', 'text-align': 'right' });
    $('li:eq(3)', linha2).addClass('txtNormal');

    // complemento linha 3
    var linha3 = $('ul.complemento', '#linha3').css({ 'clear': 'both', 'border-top': '0', 'width': '99.5%' });

    $('li:eq(0)', linha3).addClass('txtNormalBold').css({ 'width': '18%', 'text-align': 'right' });
    $('li:eq(1)', linha3).addClass('txtNormal').css({ 'width': '48%' });
    $('li:eq(2)', linha3).addClass('txtNormalBold').css({ 'width': '15%', 'text-align': 'right' });
    $('li:eq(3)', linha3).addClass('txtNormal');

    // complemento linha 4
    var linha4 = $('ul.complemento', '#linha4').css({ 'clear': 'both', 'border-top': '0', 'width': '99.5%' });

    $('li:eq(0)', linha4).addClass('txtNormalBold').css({ 'width': '18%', 'text-align': 'right' });
    $('li:eq(1)', linha4).addClass('txtNormal').css({ 'width': '48%' });
    $('li:eq(2)', linha4).addClass('txtNormalBold').css({ 'width': '15%', 'text-align': 'right' });
    $('li:eq(3)', linha4).addClass('txtNormal');

    // complemento linha 5
    var linha5 = $('ul.complemento', '#linha5').css({ 'clear': 'both', 'border-top': '0', 'width': '99.5%' });

    $('li:eq(0)', linha5).addClass('txtNormalBold').css({ 'width': '18%', 'text-align': 'right' });
    $('li:eq(1)', linha5).addClass('txtNormal').css({ 'width': '48%' });
    $('li:eq(2)', linha5).addClass('txtNormalBold').css({ 'width': '15%', 'text-align': 'right' });
    $('li:eq(3)', linha5).addClass('txtNormal');

    var linha6 = $('ul.complemento', '#linha6').css({ 'clear': 'both', 'border-top': '0', 'width': '99.5%' });

    $('li:eq(0)', linha6).addClass('txtNormalBold').css({ 'width': '18%', 'text-align': 'right' });
    $('li:eq(1)', linha6).addClass('txtNormal').css({ 'width': '48%' });
    $('li:eq(2)', linha6).addClass('txtNormalBold').css({ 'width': '15%', 'text-align': 'right' });
    $('li:eq(3)', linha6).addClass('txtNormal');

    // seleciona o registro que � clicado
    $('table > tbody > tr', divRegistro).die("click").live("click", function () {
        selecionaTabela($(this));
    });

    // verifica o log do registro com duplo click na linha correspondente
    //$('table > tbody > tr', divRegistro).die("dblclick").live("dblclick", function () {
    //    buscaConsulta('log');
    //});

    //$('table > tbody > tr:eq(0)', divRegistro).click();

    return false;
}

function hasValidPeriod(){
    var inidtpro = $('#inidtpro', '#' + frmOpcao);
    if(inidtpro.val() == ''){
        showError('error', '375 - O campo deve ser preenchido.', 'Alerta - Ayllos', "inidtpro.focus();");
        return false;
    }
    var fimdtpro = $('#fimdtpro', '#' + frmOpcao);
    if(fimdtpro.val() == ''){
        showError('error', '375 - O campo deve ser preenchido.', 'Alerta - Ayllos', "fimdtpro.focus();");
        return false;
    }

    var dtiniper = inidtpro.val().split("/");
	var dtfimper = fimdtpro.val().split("/");

    var dtini    = new Date(dtiniper[2] + "/" + dtiniper[1] + "/" + dtiniper[0]);
	var dtfim    = new Date(dtfimper[2] + "/" + dtfimper[1] + "/" + dtfimper[0]);

	if (dtfim < dtini) {
		inidtpro.val('');
		fimdtpro.val('');
		showError('error', 'Per&iacute;odo Inv&aacute;lido! Data final maior que data inicial!', 'Alerta - Ayllos', '$(\'#inidtpro\',\'#frmOpcao\').focus();');
		return false;
	}

    return true;
}

function hasValidRange(){
    var inivlpro = normalizaNumero($('#inivlpro', '#' + frmOpcao).val());
    var fimvlpro = normalizaNumero($('#fimvlpro', '#' + frmOpcao).val());
    
    if(fimvlpro < inivlpro){
        $('#inivlpro', '#' + frmOpcao).val('');
		$('#fimvlpro', '#' + frmOpcao).val('');
        showError('error', 'Valor inicial maior do que valor final!', 'Alerta - Ayllos', '$(\'#inivlpro\',\'#frmOpcao\').focus();');
        return false;
    }
    return true;
}

function controlaPesquisa(opcao) {

    if (opcao == 1) {

		if ($('#nrdconta', '#' + frmOpcao).hasClass('campoTelaSemBorda')) {
            return false;
    }

        mostraPesquisaAssociado('nrdconta', frmOpcao);
    } else {
        if (opcao == 2) {

		if ($('#nrdcontx', '#' + frmOpcao).hasClass('campoTelaSemBorda')) {
            return false;
        }

            mostraPesquisaAssociado('nrdcontx', frmOpcao);
    }
    }
    return false;
}

function controlaPesquisaCartorio() {
    if ($('#dscartor ', '#' + frmOpcao).hasClass('campoTelaSemBorda')) {
        return false;
    }
    
    mostraPesquisaCartorio('dscartor', frmOpcao);
    return false;
}

function selecionaTabela(tr) {
    registro = tr;
	
	$('#idlancto', '.complemento').val($('#idlancto', tr).val());
	$('#dscartorio', '.complemento').html($('#nmcartorio', tr).val());
	$('#nmremetente', '.complemento').html($('#nmremetente', tr).val());
	$('#cpfcnpj', '.complemento').html($('#cnpj_cpf', tr).val());
	$('#cdbanpag', '.complemento').html($('#banco', tr).val() + '/' + $('#agencia', tr).val());
	$('#nrconta', '.complemento').html($('#conta', tr).val());
	$('#vlted', '.complemento').html(number_format($('#valor', tr).val(), 2, ',', '.'));
	$('#dtrecebimento', '.complemento').html($('#dtrecebimento', tr).val());
	$('#dsstatus', '.complemento').html($('#status', tr).val());
	$('#cdcidade', '.complemento').html($('#cidade', tr).val());
	$('#cdestado', '.complemento').html($('#estado', tr).val());

	if (cddopcao == 'C')  {
		$('#dscartorio', '.complemento').html($('#cartorio', tr).val());
		$('#cdcoope', '.complemento').html($('#cooperativa', tr).val());
		$('#dtconcilacao', '.complemento').html($('#dataconc', tr).val());
		$('#nrconve', '.complemento').html($('#convenio', tr).val());
		$('#vltitul', '.complemento').html(number_format($('#valortit', tr).val(), 2, ',', '.'));
		$('#dtpagamento', '.complemento').html($('#dtmvtolt', tr).val());
		$('#vlted', '.complemento').html(number_format($('#valorted', tr).val(), 2, ',', '.'));
	}

    return false;
}

function exportarConsultaCSV(){
    if (cddopcao == 'R'){
        formatFormOpcaoR('#frmExportarCSV');
    }

    var action = $('#frmExportarCSV').attr('action');
	carregaImpressaoAyllos("frmExportarCSV", action);
}

function exportarConsultaPDF(){
     if (cddopcao == 'R'){
        formatFormOpcaoR('#frmExportarPDF');
    } else if (cddopcao == 'E') {
		var sDtinimvt = $('#dtinimvt', '#' + frmOpcao).val();
		var sDtfimmvt = $('#dtfimmvt', '#' + frmOpcao).val();
		
		var dtinimvt = new Date(sDtinimvt.split('/').reverse().join('/'));
		var dtfimmvt = new Date(sDtfimmvt.split('/').reverse().join('/'));
		
		if(dtfimmvt < dtinimvt){
			showError('error', 'Data inicial maior do que data final!', 'Alerta - Ayllos', '$(\'#dtinimvt\',\'#frmOpcao\').focus();');
			return false;
		}
		formatFormOpcaoE('#frmExportarPDF');
	}
	

    var action = $('#frmExportarPDF').attr('action');
	carregaImpressaoAyllos("frmExportarPDF", action);
}

function formatFormOpcaoR(form){
    var inidtpro = $('#inidtpro', '#' + frmOpcao).val();
    var fimdtpro = $('#fimdtpro', '#' + frmOpcao).val();
    var cdcooper = $('#nmrescop', '#' + frmOpcao).val();
    var nrdconta = $('#nrdconta', '#' + frmOpcao).val();
    var cduflogr = $('#cduflogr', '#' + frmOpcao).val();
    var dscartor = $('#dscartor', '#' + frmOpcao).val();
    var flcustas = $('#flcustas', '#' + frmOpcao).val();

    $('#inidtpro', form).val(inidtpro);
    $('#fimdtpro', form).val(fimdtpro);
    $('#cdcooper', form).val(cdcooper);
    $('#nrdconta', form).val(nrdconta.replace(/[^\w\s]/gi, ''));
    $('#cduflogr', form).val(cduflogr);
    $('#dscartor', form).val(dscartor);
    $('#flcustas', form).val(flcustas);
}

function formatFormOpcaoE(form){
    var dtinimvt = $('#dtinimvt', '#' + frmOpcao).val();
    var dtfimmvt = $('#dtfimmvt', '#' + frmOpcao).val();

    $('#dtinimvt', form).val(dtinimvt);
    $('#dtfimmvt', form).val(dtfimmvt);
}

function abrirModalConciliacao() {
    showMsgAguardo('Aguarde, obtendo dados ...');	

    var idlancto = $('#idlancto', '.complemento').val();
    var dtinicio = $('#dtrecebimento', '.complemento').html();
    var vlrfinal = $('#vlted', '.complemento').html();
    var cartorio = $('#dscartorio', '.complemento').html();

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/manprt/modal_conciliacao.php',
        data: {
            idlancto: idlancto,
            dtinicio: dtinicio,
            vlrfinal: vlrfinal,
            cartorio: cartorio,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;�vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function (response) {
            hideMsgAguardo();
            $('#divRotina').html(response);
            exibeRotina($('#divRotina'));
            formataTabelaConciliacao();
            verificaCheckbox();
            $('#divRotina').css('left','50%');
            $('#divRotina').css('margin-left','-'+(parseInt($('#divRotina table').css('width'))/2)+'px');
        }
    });

}

function habilitaBotao(botao, opcao) {
    if (opcao == 'D') {
        // Desabilitar
        $("#" + botao).prop("disabled",true).addClass("botaoDesativado").attr("onClick","return false;");
    } else {
        // Habilitar
        $("#" + botao).prop("disabled",false).removeClass("botaoDesativado").attr("onClick","validaConciliacao()");
    }
}

function verificaCheckbox(elem, valorCheckbox) {
    var valorInput = $('#vltitulos').val() ? converteMoedaFloat($('#vltitulos').val()) : 0;
    var totalConc = 0;

    totalConc = $(elem).is(':checked') ? (valorInput + valorCheckbox) : (valorInput - valorCheckbox);
    totalConc = totalConc.toFixed(2);

    $('#vltitulos').val(number_format(totalConc, 2, ',', '.'));

    if (totalConc && totalConc == converteMoedaFloat($('#vltotal').val())) {
        habilitaBotao('btModalConciliar', '');
    } else {
        habilitaBotao('btModalConciliar', 'D');
    }
}

function validaConciliacao() {
    //showConfirmacao('Confirma a concilia&ccedil;&atilde;o?', 'MANPRT', "pedeSenhaCoordenador(2, 'efetuaConciliacao();', 'fechaRotina($(\"#divRotina\"))')", 'estadoInicial();', 'sim.gif', 'nao.gif');
	//pedeSenhaCoordenador(2, 'efetuaConciliacao();', 'fechaRotina($(\"#divRotina\"))')
	showConfirmacao('Confirma a concilia&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', "efetuaConciliacao();", ' blockBackground(parseInt($("#divRotina").css("z-index")))', 'sim.gif', 'nao.gif');

    /* parcial, não será feito, caso, volte, descomentar bloco abaixo: */
    // if (converteMoedaFloat($('#vltitulos').val()) < converteMoedaFloat($('#vltotal').val())) {
    //     var msg = 'O somat&oacute;rio dos valores dos t&iacute;tulos &eacute; inferior ao da TED. A concilia&ccedil;&atilde;o ser&aacute; realizada de forma parcial.<br>Confirma a concilia&ccedil;&atilde;o?';
    //     showConfirmacao(msg, 'MANPRT', "pedeSenhaCoordenador(2, 'alert(\"oi\");fechaRotina($(\"#divRotina\"));', 'divRotina')", 'voltaDiv();', 'sim.gif', 'nao.gif');
    // } else {
    //     showConfirmacao('Confirma a concilia&ccedil;&atilde;o?', 'MANPRT', "pedeSenhaCoordenador(2, 'alert(\"oi\");fechaRotina($(\"#divRotina\"));', 'divRotina')", 'voltaDiv();', 'sim.gif', 'nao.gif');
    // }
}

function efetuaConciliacao() {
    showMsgAguardo('Aguarde, efetuando concilia&ccedil;&atilde;o...');

    var idsTitulo = [];
    var idlancto = $('#idlancto', '.complemento').val();
    $('[name=idsTitulo]:checkbox:checked').each(function(i){
        idsTitulo[i] = $(this).val();
    });

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/manprt/grava_conciliacao.php',
        data: {
            idsTitulo: idsTitulo,
            idlancto: idlancto,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function (response) {
            eval(response);
        }
    });
}

function filtraConciliacao(elem) {
    showMsgAguardo('Aguarde, obtendo dados ...');

    var dtinicio = $('#dtinicio').length && $('#dtinicio').is(':checked') ? $('#dtinicio').val() : '';
    var vlrfinal = $('#vlrfinal').length && $('#vlrfinal').is(':checked') ? $('#vlrfinal').val() : '';
    var cartorio = $('#cartorio').length && $('#cartorio').is(':checked') ? $('#cartorio').val() : '';

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/manprt/tabela_conciliacao.php',
        data: {
            dtinicio: dtinicio,
            vlrfinal: vlrfinal,
            cartorio: cartorio,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function (response) {
            hideMsgAguardo();
            $('.tituloRegistros', '#divRotina').remove();
            $('.tdConteudoTela .divRegistros', '#divRotina').html(response);
            formataTabelaConciliacao();
            verificaCheckbox();
        }
    });
}

function abrirModalDevolverTED() {

    if (registro == null)
        return;

    showMsgAguardo("Aguarde ...");			
	
	$.ajax({		
		type: "POST", 
		dataType: "html",
		url: UrlSite + "telas/manprt/modal_devolver_ted.php",
		data: {
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function (response) {
            hideMsgAguardo();
            $('#divRotina').html(response);
            exibeRotina($('#divRotina'));
            $('#divRotina').css('left','50%');
            $('#divRotina').css('margin-left','-'+(parseInt($('#divRotina table').css('width'))/2)+'px');
        }				
	});
}

function validarCartorioTED() {

    if (registro == null)
        return;

    var idlancto = $('#idlancto', registro).val();

    showMsgAguardo("Aguarde ...");			
	
	$.ajax({		
		type: "POST", 
		dataType: "html",
		url: UrlSite + "telas/manprt/estornar_ted.php",
		data: {
			redirect: "html_ajax",
            acao: "validar_cartorio",
            idlancto: idlancto
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function (response) {
            hideMsgAguardo();
            eval(response);
        }				
	});
}

function retornarTitulo() {

    var cooperativa = $('#cooperativa', '#modalEstorno').val(),
        convenio = $('#convenio', '#modalEstorno').val(),
        conta = $('#nrdconta', '#modalEstorno').val(),
        documento = $('#documento', '#modalEstorno').val();

    showMsgAguardo("Aguarde ...");			
	
	$.ajax({		
		type: "POST", 
		dataType: "html",
		url: UrlSite + "telas/manprt/estornar_ted.php",
		data: {
			redirect: "html_ajax",
            acao: "retornar_titulo",
            cooperativa: cooperativa,
            convenio: convenio,
            conta: conta,
            documento: documento
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function (response) {
            hideMsgAguardo();
            eval(response);
        }				
	});
}

function validarValorTEDCustas() {
    var valorCustas = $('#custas').val(),
        valorTed = $('#valor', registro).val();

    if (valorCustas != valorTed) {
        showError("error","O valor da TED selecionada &eacute; diferente do valor das custas.","Alerta - Ayllos","");
        return false;
    }
    return true;
}

function abrirModalEstornarTED() {

    if (registro == null)
        return;

    showMsgAguardo("Aguarde ...");			
	
	$.ajax({		
		type: "POST", 
		dataType: "html",
		url: UrlSite + "telas/manprt/modal_estornar_ted.php",
		data: {
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function (response) {
            hideMsgAguardo();
            $('#divRotina').html(response);
            exibeRotina($('#divRotina'));
            $('#divRotina').css('left','50%');
            $('#divRotina').css('margin-left','-'+(parseInt($('#divRotina table').css('width'))/2)+'px');
        }				
	});
}

function solicitaEstornoTED() {
    var idretorno = $('#idretorno').val();

    if(!validarValorTEDCustas())
        return;

    if (idretorno == "") {
        showError("error","Favor realizar consulta.","Alerta - Ayllos","");
        return;
    }

    //pedeSenhaCoordenador(2,'estornarTED()','');
	estornarTED();

}

function estornarTED() {

    showMsgAguardo("Aguarde ...");
    
    var idlancto = $('#idlancto', registro).val(),
    idretorno = $('#idretorno').val();

    $.ajax({		
		type: "POST", 
		dataType: "html",
		url: UrlSite + "telas/manprt/estornar_ted.php",
		data: {
			redirect: "html_ajax",
            acao: "estornar_ted",
            idlancto: idlancto,
            idretorno: idretorno
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function (response) {
            hideMsgAguardo();
            eval(response);
        }				
	});
}

function devolverTED() {
    showMsgAguardo("Aguarde ...");
    var idlancto = $('#idlancto', registro).val(),
    motivo = $('#devted_motivo').val(),
    descricao = $('#devted_descricao').val();
	
	$.ajax({		
		type: "POST", 
		dataType: "html",
		url: UrlSite + "telas/manprt/devolver_ted.php",
		data: {
            idlancto: idlancto,
            motivo: motivo,
            descricao: descricao,
			redirect: "html_ajax"
		},		
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","");
		},
		success: function (response) {
            hideMsgAguardo();
			eval(response);
        }				
	});
}
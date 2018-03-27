/*!
 * FONTE        : manprt.js
 * CRIAÇÃO      : Helinton Steffens (DB1) 
 * DATA CRIAÇÃO : 13/03/2018
 * OBJETIVO     : Biblioteca de funções da tela MANPRT
 */

//Formulários e Tabela
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

    $('#divTela').fadeTo(0, 0.1);

    // retira as mensagens	
    hideMsgAguardo();

    // formulario	
    formataCabecalho();
    cTodosCabecalho.limpaFormulario().removeClass('campoErro');

    fechaRotina($('#divUsoGenerico'));
    fechaRotina($('#divRotina'));

    $('#' + frmOpcao).remove();
    $('#' + frmTabela).remove();
    $('#divBotoes:eq(0)', '#divTela').remove();
    $('#divPesquisaRodape', '#divTela').remove();

    cCddopcao.val(cddopcao);
    cCddopcao.habilitaCampo().focus();

    removeOpacidade('divTela');
}


// controla
function controlaOperacao(nriniseq, nrregist) {
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
            showError('error', 'N&atilde;o foi possÃ­vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function (response) {
            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divTela').html(response);
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
    cCddopcao.css({ 'width': '600px' });

    // Outros	
    cTodosCabecalho = $('input[type="text"], select', '#' + frmCab);
    btnOK1 = $('#btnOk1', '#' + frmCab);
    btnOK1.css({'margin-left': '45%'});
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
        // Se é a tecla ENTER, 
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
    // Executa script de confirmações através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/manprt/form_opcao_' + cddopcao.toLowerCase() + '.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atildeo foi poss&iacute­vel concluir a requisi&ccedil&atildeo.', 'Alerta - Ayllos', "unblockBackground()");
        },
        success: function (response) {
            $('#divTela').html(response);

            formataCabecalho();
 
            cCddopcao.desabilitaCampo();
            cCddopcao.val(cddopcao);

            // limpa formulario
            cTodosOpcao = $('input[type="text"], select', '#' + frmOpcao);
            cTodosOpcao.limpaFormulario().removeClass('campoErro');
            $('#divPesquisaRodape', '#divTela').remove();

            if (cddopcao == 'T') {
                formataOpcaoT();
            } else if (cddopcao == 'R') {
                formataOpcaoR();
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

    cInidtpro.css({ 'width': '75px' }).addClass('data');
    cInidtpro.removeClass('campo');
    cFimdtpro.css({ 'width': '75px' }).addClass('data');
    cFimdtpro.removeClass('campo');
    cInivlpro.css({ 'width': '50px' }).addClass('inteiro');
    cFimvlpro.css({ 'width': '50px' }).addClass('inteiro');
    cIndconci.css({ 'width': '160px' });
    cDscartor.css({ 'width': '130px' });

    layoutPadrao();
    return false;
}

function controlaLayout() {

    $('#divFiltro').css({ 'display': 'block' });

    return false;
}

function formataOpcaoR() {

    highlightObjFocus($('#frmOpcao'));

    $('#divFiltro').css({ 'border': '1px solid #777', 'padding': '10px', 'min-height': '50px' });

    rInidtpro = $('label[for="inidtpro"]', '#' + frmOpcao);
    rFimdtpro = $('label[for="fimdtpro"]', '#' + frmOpcao);
    rNmrescop = $('label[for="nmrescop"]', '#' + frmOpcao);
    rNrdconta = $('label[for="nrdconta"]', '#' + frmOpcao);
    rCduflogr = $('label[for="cduflogr"]', '#' + frmOpcao);
    rDscartor = $('label[for="dscartor"]', '#' + frmOpcao);
    
    rInidtpro.css({ 'width': '68px' }).addClass('rotulo');
    rFimdtpro.css({ 'width': '65px' }).addClass('rotulo-linha'); 
    rNmrescop.css({ 'width': '85px', 'margin-left':'50px' }).addClass('rotulo-linha');
    rNrdconta.css({ 'width': '70px' }).addClass('rotulo-linha');
    rCduflogr.css({ 'margin-left':'43px' }).addClass('rotulo-linha');
    rDscartor.css({ 'width': '120px', 'margin-left':'50px' }).addClass('rotulo-linha');
        
    cInidtpro = $('#inidtpro', '#' + frmOpcao);
    cFimdtpro = $('#fimdtpro', '#' + frmOpcao);
    cNmrescop = $('#nmrescop', '#' + frmOpcao);
    cNrdconta = $('#nrdconta', '#' + frmOpcao);
    cCduflogr = $('#cduflogr', '#' + frmOpcao);
    cDscartor = $('#dscartor', '#' + frmOpcao);
    
    cInidtpro.css({ 'width': '75px' }).addClass('data');
    cInidtpro.removeClass('campo');
    cFimdtpro.css({ 'width': '75px' }).addClass('data');
    cFimdtpro.removeClass('campo');
    cNmrescop.css({'width': '180px'}); 
    cNrdconta.addClass('conta pesquisa').css({'width': '80px'});
    cCduflogr.css('width', '25px').attr('maxlength', '2');
    cDscartor.css({ 'width': '130px' });

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
        controlaOperacao(nriniseq, nrregist);
    } else if (cddopcao == 'R') {
        controlaLayout();
    }

    return false;
}

function trocaBotao(botao) {

    $('#divBotoes', '#divTela').html('');
    $('#divBotoes', '#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>');

    if (botao != '') {
        $('#divBotoes', '#divTela').append('&nbsp;<a href="#" class="botao" onclick="btnContinuar(); return false;" >' + botao + '</a>');
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
        $('#divBotoes:eq(0)', '#divTela').remove();
        formataTabelaTeds();
        formataOpcaoT();
        controlaLayout();
        $('input, select', '#' + frmOpcao).desabilitaCampo();
        $('#btVoltar', '#divBotoes').focus();
    }

    return false;
}

function formataTabelaTeds() {

    var divRegistro = $('div.divRegistros', '#' + frmTabela);
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    $('#' + frmTabela).css({ 'margin-top': '10px' });
    divRegistro.css({ 'border': '1px solid #777', 'height': '130px'  });

    var ordemInicial = new Array();
    //ordemInicial = [[0,0]];	

    var arrayLargura = new Array();
    arrayLargura[0] = '210px';
    arrayLargura[1] = '120px';
    arrayLargura[2] = '60px';
    arrayLargura[3] = '65px';
    arrayLargura[4] = '45px';
    arrayLargura[5] = '90px';
    arrayLargura[6] = '50px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
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

    // seleciona o registro que é clicado
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

    $('#dscartorio', '.complemento').html($('#nmcartorio', tr).val());
    $('#nmremetente', '.complemento').html($('#nmremetente', tr).val());
    $('#cpfcnpj', '.complemento').html($('#cnpj_cpf', tr).val());
    $('#cdbanpag', '.complemento').html($('#banco', tr).val() + '/' + $('#agencia', tr).val());
    $('#nrconta', '.complemento').html($('#conta', tr).val());
    $('#vlted', '.complemento').html($('#valor', tr).val());
    $('#dtrecebimento', '.complemento').html($('#dtrecebimento', tr).val());
    $('#dsstatus', '.complemento').html($('#status', tr).val());
    $('#cdcidade', '.complemento').html($('#cidade', tr).val());
    $('#cdestado', '.complemento').html($('#estado', tr).val());

    return false;
}
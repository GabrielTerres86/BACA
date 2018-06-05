/*!
 * FONTE        : cobtit.js
 * CRIAÇÃO      : Luis Fernando (GFT)
 * DATA CRIAÇÃO : 21/05/2018
 * OBJETIVO     : Biblioteca de funções na rotina COBTIT
 * --------------
 */

//Labels/Campos do cabeçalho
var cCddopcao,rCddopcao,cTodosCabecalho,cTodosFrmBorderos,btnCab;

// Definição de algumas variáveis globais
var cddopcao = 'C';
var nrborder = '';
var nrdconta = '';
var flavalis = '';
var nrdocmto = '';
var nrctacob = '';
var nrcnvcob = '';

//Formulários
var frmCab = 'frmCab';
var nomeForm = 'frmCab';

var arrayFeriados = [];

$(document).ready(function() {
    estadoInicial();
    highlightObjFocus($('#' + frmCab));
    highlightObjFocus($('#frmManutencao'));
    highlightObjFocus($('#frmBorderos'));

    $('fieldset > legend').css({'font-size': '11px', 'color': '#777', 'margin-left': '5px', 'padding': '0px 2px'});
    $('fieldset').css({'clear': 'both', 'border': '1px solid #777', 'margin': '3px 0px', 'padding': '10px 3px 5px 3px'});

    $(".navigation").bind("keypress",(function(e) {
        nextField(e,this);
    }));
    return false;
});

/*FUNÇÕES PARA CONTROLE DE NAVEGAÇÃO PADRÃO*/
function nextField(e,obj){
    if(e.keyCode == 13) { 
        var field = $("input.navigation,select.navigation,checkbox.navigation,radio.navigation");
        currentBoxNumber = field.index(obj);
        if (field[currentBoxNumber + 1] != null) {
            nextBox = field[currentBoxNumber + 1];
            if($(nextBox).prop("readonly") || $(nextBox).prop("disabled")){
                nextField(e,nextBox);
            }
            else{
                nextBox.focus();
                nextBox.select();
            }
            return false;
        }
    }
}

function backField(obj){
    var field = $("input.navigation,select.navigation,checkbox.navigation,radio.navigation");
    currentBoxNumber = field.index(obj);
    if (field[currentBoxNumber - 1] != null) {
        nextBox = field[currentBoxNumber - 1];
        if($(nextBox).prop("readonly") || $(nextBox).prop("disabled")){
            backField(nextBox);
        }
        else{
            nextBox.focus();
            nextBox.select();
        }
        return false;
    }
    else{
        estadoInicial();
    }
}

function btnVoltar(){
    backField(document.activeElement);
}

// seletores
function estadoInicial() {
    $('#divTela').fadeTo(0, 0.1);
    $('#frmCab').css({'display': 'block'});

    $('#frmManutencao').css({'display': 'none'});
    $('#divBotoesfrmManutencao').css({'display': 'none'});
    $('#divTabfrmManutencao').html('');

    $('#frmBorderos').css({'display': 'none'});
    $('#divBotoesfrmBorderos').css({'display': 'none'});
    $('#divTabfrmBorderos').html('');

    // Limpa conteudo da divBotoes
    $('#divBotoes', '#divTela').html('');
    $('#divBotoes').css({'display': 'none'});

    // Aplica Layout nos fontes PHP
    formataCabecalho();
    formataFrmManutencao();
    formataFrmBorderos();
    // formataFrmArquivos();

    // Limpa informações dos Formularios
    cTodosCabecalho.limpaFormulario();
    cTodosFrmManutencao.limpaFormulario();
    cTodosFrmBorderos.limpaFormulario();
    // cTodosFrmArquivos.limpaFormulario();

    cCddopcao.val(cddopcao);

    removeOpacidade('divTela');
    unblockBackground();
    hideMsgAguardo();

    // Desativa campos do cabeçalho
    cTodosCabecalho.desabilitaCampo();

    controlaFoco();
    $('#cddopcao', '#frmCab').habilitaCampo();
    $('#cddopcao', '#' + frmCab).focus();
}

function formataCabecalho() {
    rCddopcao = $('label[for="cddopcao"]', '#' + frmCab);
    cCddopcao = $('#cddopcao', '#' + frmCab);
    cTodosCabecalho = $('input[type="text"],select', '#' + frmCab);
    btnCab = $('#btOK', '#' + frmCab);
    rCddopcao.css('width', '85px');
    cCddopcao.css({'width': '710px'});
    cTodosCabecalho.habilitaCampo();
    $('#cddopcao', '#' + frmCab).focus();
    layoutPadrao();
    return false;
}

function controlaOpcao() {
    if ($('#cddopcao', '#frmCab').hasClass('campoTelaSemBorda')) {
        return false;
    }
    var act = '';
    // Desabilita campo opção
    cTodosCabecalho = $('input[type="text"],select', '#frmCab');
    cTodosCabecalho.desabilitaCampo();
    switch($('#cddopcao', '#frmCab').val()){
    	case 'M':
    		nomeForm = 'frmManutencao';
	        $('#'+nomeForm).css({'display': 'block'});
	        cCdagenci.focus();
            act = "continuarM()";
    	break;
    	case 'C':
    		nomeForm = 'frmBorderos';
	        $('#'+nomeForm).css({'display': 'block'});
	        $('#nrdconta', '#'+nomeForm).focus();
            act = "continuarC()";
    	break;
    }
    divBotoes(act);
    $('#divBotoes').css({'display': 'block'});
    return false;
}

// Monta divBotoes
function divBotoes(act) {
    $('#divBotoes', '#divTela').html('');
    $('#divBotoes', '#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>');
    $('#divBotoes', '#divTela').append('<a href="#" class="botao" onClick="'+act+'" return false;" >Consultar</a>');
    return false;
}

function pesquisaAssociados() {
    if ($('#nrdconta', '#frmBorderos').hasClass('campoTelaSemBorda')) {
        return false;
    }
    mostraPesquisaAssociado('nrdconta', frmCab);
}


function formataFrmManutencao() {
    // cabecalho
    rCdagenci = $('label[for="cdagenci"]', '#frmManutencao');
    rNrborder = $('label[for="nrborder"]', '#frmManutencao');
    rdtemissi = $('label[for="dtemissi"]', '#frmManutencao');
    rdtemissf = $('label[for="dtemissf"]', '#frmManutencao');
    rNrdconta = $('label[for="nrdconta"]', '#frmManutencao');
    rNmprimtl = $('label[for="nmprimtl"]', '#frmManutencao');
    rdtvencti = $('label[for="dtvencti"]', '#frmManutencao');
    rdtvenctf = $('label[for="dtvenctf"]', '#frmManutencao');
    rdtbaixai = $('label[for="dtbaixai"]', '#frmManutencao');
    rdtbaixaf = $('label[for="dtbaixaf"]', '#frmManutencao');
    rdtpagtoi = $('label[for="dtpagtoi"]', '#frmManutencao');
    rdtpagtof = $('label[for="dtpagtof"]', '#frmManutencao');

    cCdagenci = $('#cdagenci', '#frmManutencao');
    cNrborder = $('#nrborder', '#frmManutencao');
    cdtemissi = $('#dtemissi', '#frmManutencao');
    cdtemissf = $('#dtemissf', '#frmManutencao');
    cNrdconta = $('#nrdconta', '#frmManutencao');
    cNmprimtl = $('#nmprimtl', '#frmManutencao');
    cdtvencti = $('#dtvencti', '#frmManutencao');
    cdtvenctf = $('#dtvenctf', '#frmManutencao');
    cdtbaixai = $('#dtbaixai', '#frmManutencao');
    cdtbaixaf = $('#dtbaixaf', '#frmManutencao');
    cdtpagtoi = $('#dtpagtoi', '#frmManutencao');
    cdtpagtof = $('#dtpagtof', '#frmManutencao');

    cTodosFrmManutencao = $('input[type="text"],select', '#frmManutencao');

    rCdagenci.css({'width': '105px'});
    rNrborder.css({'width': '85px'});
    rdtemissi.css({'width': '105'});
    rdtemissf.css({'width': '28px'});
    rNrdconta.css({'width': '85px'});
    rNmprimtl.css({'width': '40px'});
    rdtvencti.css({'width': '317px'});
    rdtvenctf.css({'width': '28px'});
    rdtbaixai.css({'width': '105px'});
    rdtbaixaf.css({'width': '28px'});
    rdtpagtoi.css({'width': '317px'});
    rdtpagtof.css({'width': '28px'});

    cCdagenci.css({'width': '35px'}).setMask('INTEGER', 'zz9', '', '');
    cNrborder.css({'width': '85px'}).addClass('contrato');
    cdtemissi.css({'width': '75px'}).setMask('DATE', '', '', '');
    cdtemissf.css({'width': '75px'}).setMask('DATE', '', '', '');
    cNrdconta.css({'width': '85px'}).addClass('conta');
    cNmprimtl.css({'width': '264px'});
    cdtvencti.css({'width': '75px'}).setMask('DATE', '', '', '');
    cdtvenctf.css({'width': '75px'}).setMask('DATE', '', '', '');
    cdtbaixai.css({'width': '75px'}).setMask('DATE', '', '', '');
    cdtbaixaf.css({'width': '75px'}).setMask('DATE', '', '', '');
    cdtpagtoi.css({'width': '75px'}).setMask('DATE', '', '', '');
    cdtpagtof.css({'width': '75px'}).setMask('DATE', '', '', '');

    cTodosFrmManutencao.habilitaCampo();

    cNmprimtl.desabilitaCampo();

    layoutPadrao();
    return false;
}

function formataFrmBorderos() {
    // Cabecalho
    rNrdconta = $('label[for="nrdconta"]', '#frmBorderos');
    rNmprimtl = $('label[for="nmprimtl"]', '#frmBorderos');

    cNrdconta = $('#nrdconta', '#frmBorderos');
    cNmprimtl = $('#nmprimtl', '#frmBorderos');

    cTodosFrmBorderos = $('input[type="text"],select', '#frmBorderos');

    rNrdconta.css({'width': '85px'});
    rNmprimtl.css({'width': '40px'});

    cNrdconta.css({'width': '85px'}).addClass('conta');
    cNmprimtl.css({'width': '450px'});

    cTodosFrmBorderos.habilitaCampo();
    cNmprimtl.desabilitaCampo();

    layoutPadrao();
    return false;
}

function controlaFoco() {
    // frmCab
    $('#cddopcao', '#frmCab').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#btnOK', '#frmCab').focus();
            return false;
        }
    });

    // frmBorderos
    $('#nrdconta', '#frmBorderos').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            continuarC();
        }
    });

    // frmManutencao
    $('#nrdconta', '#frmManutencao').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            nomeforma = "frmManutencao";
            $('#nrdconta', '#frmManutencao').removeClass('campoErro');
            if ($('#nrdconta', '#frmManutencao').val() != '') {
                buscaAssociado(function(){
                    $("#nrborder","#frmManutencao").focus();
                });
                return false;
            }
        }
    });
    $('#dtpagtof', '#frmManutencao').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            continuarM();
        }
    });
    return false;
}

function continuarC(){
    $('#nrdconta', '#frmBorderos').removeClass('campoErro');
    if ($('#nrdconta', '#frmBorderos').val() != '') {
        buscaAssociado(function(){
            buscaBorderos(1,15,function(html){
                $('#divTabfrmBorderos').html(html);
                $('#divTabfrmBorderos').css({'display': 'block'});
                $('#divBotoesfrmBorderos').css({'display': 'block'});
                formataBorderos();
                $('#divPesquisaRodape', '#divTabfrmBorderos').formataRodapePesquisa();
                cTodosFrmBorderos.desabilitaCampo();
                $('#divBotoes').css({'display': 'none'});
            });
        });
        return false;
    } else {
        showError("error", "Numero da Conta deve ser informado.", "Alerta - Ayllos", "$('#nrdconta', '#frmBorderos').focus()", false);
        return false;
    }
}

function continuarM(){
    if (cCddopcao.val() == 'M') {
        var nrdconta = normalizaNumero($('#nrdconta', '#frmManutencao').val());
        var nrctremp = normalizaNumero($('#nrctremp', '#frmManutencao').val());
        var dtbaixai = $('#dtbaixai', '#frmManutencao').val();
        var dtemissi = $('#dtemissi', '#frmManutencao').val();
        var dtvencti = $('#dtvencti', '#frmManutencao').val();
        var dtpagtoi = $('#dtpagtoi', '#frmManutencao').val();
        if (nrdconta == '') {
            if (nrctremp != '') {
                showError("error", "Numero da Conta deve ser informado.", "Alerta - Ayllos", "$('#nrdconta', '#frmContratos').focus()", false);
            } else {
                if ((dtbaixai == '') && (dtemissi == '') && (dtvencti == '') && (dtpagtoi == '')) {
                    showError("error", "Pelo menos uma opcao de Data deve ser Informada!.", "Alerta - Ayllos", "$('#dtbaixai', '#frmManutencao').focus()", false);
                } else {
                    buscaBoletos(1, 15);
                }
            }
        } else {
            buscaBoletos(1, 15);
        }
    }
    return false;

}

function formataContratosManutencao() {

    $('#divRotina').css('width', '640px');

    var divRegistro = $('div.divRegistros', '#divTabfrmManutencao');
    var tabela = $('table', divRegistro);
//    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({'height': '220px', 'width': '100%'});

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '30px';
    arrayLargura[1] = '75px';
    arrayLargura[2] = '50px';
    arrayLargura[3] = '75px';
    arrayLargura[4] = '50px';
    arrayLargura[5] = '75px';
    arrayLargura[6] = '75px';
    arrayLargura[7] = '70px';
    arrayLargura[8] = '75px';
    arrayLargura[9] = '60px';
    arrayLargura[10] = '60px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'right';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'center';
    arrayAlinha[6] = 'center';
    arrayAlinha[7] = 'center';
    arrayAlinha[8] = 'center';
    arrayAlinha[9] = 'center';
    arrayAlinha[10] = 'center';

    var metodoTabela = '';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);


    // seleciona o registro que é clicado
    $('table > tbody > tr', divRegistro).click(function() {
        nrdconta = $(this).find('#nrdconta').val();
        nrborder = $(this).find('#nrborder').val();
        nrdocmto = $(this).find('#nrdocmto').val();
        nrctacob = $(this).find('#nrctacob').val();
        nrcnvcob = $(this).find('#nrcnvcob').val();
    });

    $('table > tbody > tr:eq(0)', divRegistro).click();

    return false;
}

function buscaBoletos(nriniseq, nrregist){
    var cddopcao = $('#cddopcao', '#frmCab').val();

    var nrdconta = 0;
    var cdagenci = 0;
    var nrborder = 0;
    var dtbaixai = '';
    var dtbaixaf = '';
    var dtemissi = '';
    var dtemissf = '';
    var dtvencti = '';
    var dtvenctf = '';
    var dtpagtoi = '';
    var dtpagtof = '';

    if (cddopcao == 'M') {

        nrdconta = normalizaNumero($('#nrdconta', '#frmManutencao').val());
        nrborder = normalizaNumero($('#nrborder', '#frmManutencao').val());

        cdagenci = $('#cdagenci', '#frmManutencao').val();

        dtbaixai = $('#dtbaixai', '#frmManutencao').val();
        dtbaixaf = $('#dtbaixaf', '#frmManutencao').val();
        dtemissi = $('#dtemissi', '#frmManutencao').val();
        dtemissf = $('#dtemissf', '#frmManutencao').val();
        dtvencti = $('#dtvencti', '#frmManutencao').val();
        dtvenctf = $('#dtvenctf', '#frmManutencao').val();
        dtpagtoi = $('#dtpagtoi', '#frmManutencao').val();
        dtpagtof = $('#dtpagtof', '#frmManutencao').val();

    } else {
        nrdconta = normalizaNumero($('#nrdconta', '#frmContratos').val());
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, efetuando consulta ...");

    // Carrega dados parametro através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobtit/manter_rotina.php',
        data:
                {
                    operacao: 'BUSCAR_BOLETOS',
                    cdagenci: cdagenci,
                    cddopcao: cddopcao,
                    nrborder: nrborder,
                    nrdconta: nrdconta,
                    dtbaixai: dtbaixai,
                    dtbaixaf: dtbaixaf,
                    dtemissi: dtemissi,
                    dtemissf: dtemissf,
                    dtvencti: dtvencti,
                    dtvenctf: dtvenctf,
                    dtpagtoi: dtpagtoi,
                    dtpagtof: dtpagtof,
                    nriniseq: nriniseq,
                    nrregist: nrregist,
                    redirect: 'script_ajax'
                },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response) {
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    var r = $.parseJSON(response);
                    $("#divTabfrmManutencao").html(r.html);
                    $('#divTabfrmManutencao').css({'display': 'block'});
                    $('#divBotoesfrmManutencao').css({'display': 'block'});
                    $('#divBotoes').css({'display': 'none'});
                    
                    formataContratosManutencao();

                    $('#divPesquisaRodape', '#divTabfrmManutencao').formataRodapePesquisa();
                     cTodosFrmManutencao.desabilitaCampo();
                    
                    hideMsgAguardo();
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

function buscaAssociado(callback) {
    var nrdconta = normalizaNumero($('#nrdconta', '#' + nomeForm).val());
    var nrcpfcgc = normalizaNumero($('#nrcpfcgc', '#' + nomeForm).val());

    showMsgAguardo('Aguarde, buscando dados ...');
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/cobtit/manter_rotina.php',
        data: {
            operacao: 'BUSCAR_ASSOCIADO',
            nrdconta: nrdconta,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'cNrdconta.focus();');
        },
        success: function(response) {
            try {
            	hideMsgAguardo();
            	var r = $.parseJSON(response);
            	if(r.status=='erro'){
            		showError("error",r.mensagem,'Alerta - Ayllos','cNrdconta.focus();');
                    $("#nrdconta",'#'+nomeForm).val('');
	            	$("#nmprimtl",'#'+nomeForm).val('');
            	}
            	else{
                    $("#nrdconta",'#'+nomeForm).val(r.nrdconta);
                    $("#nmprimtl",'#'+nomeForm).val(r.nmprimtl);
	            	callback();
            	}
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'cNrdconta.focus();');
            }
        }
    });
    return false;
}


function buscaBorderos(ini,qnt,callback) {
    var nrdconta = normalizaNumero($('#nrdconta', '#' + nomeForm).val());
    showMsgAguardo('Aguarde, buscando dados ...');
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/cobtit/manter_rotina.php',
        data: {
            operacao: 'BUSCAR_BORDEROS',
            nrdconta: nrdconta,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'cNrdconta.focus();');
        },
        success: function(response) {
            try {
            	hideMsgAguardo();
            	var r = $.parseJSON(response);
            	if(r.status=='erro'){
            		showError("error",r.mensagem,'Alerta - Ayllos','cNrdconta.focus();');
	            	cNrdconta.focus();
            	}
            	else{
            		callback(r.html);
            	}
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'cNrdconta.focus();');
            }
        }
    });
    return false;
}


function gerarBoleto() {
    // Executa script através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobtit/form_gerar_boleto.php',
        data: {
            nrdconta:nrdconta,
            nrborder:nrborder,
            flavalis:flavalis,
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;atilde;o.', 'Alerta - Ayllos', "unblockBackground()");
        },
        success: function(response) {
            $('#divRotina').html(response);
            $('#divRotina').css('width', '650px');
            exibeRotina($('#divRotina'));
            bloqueiaFundo($('#divRotina'));
        }
    });
    return false;
}

function formataBorderos() {
    $('#divRotina').css('width', '650px');
    var divRegistro = $('div.divRegistros', '#divTabfrmBorderos');
    var tabela = $('table', divRegistro);
    divRegistro.css({'height': '260px', 'width': '1000px'});

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];
    var arrayLargura = new Array();
    arrayLargura[0] = '100px';
    arrayLargura[1] = '100px';
    arrayLargura[2] = '100px';
    arrayLargura[3] = '100px';
    arrayLargura[4] = '100px'; //tipo cobranca
    arrayLargura[5] = '100px';
    arrayLargura[6] = '100px';
    arrayLargura[7] = '';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'center';
	arrayAlinha[4] = 'right';
    arrayAlinha[5] = 'center';
    arrayAlinha[6] = 'right';
    arrayAlinha[7] = 'center';

    var metodoTabela = '';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

    var divRegistro = $('div.divRegistros', '#divBorderos');

    // seleciona o registro que é clicado
    $('table > tbody > tr', divRegistro).click(function() {
        nrborder = $(this).find('#nrborder').val();
        flavalis = $(this).find('#flavalis').val();
    });
    
    nrdconta = normalizaNumero($('#nrdconta', '#frmBorderos').val());

    $('table > tbody > tr:eq(0)', divRegistro).click();

    return false;
}

function retornaListaFeriados(){
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/cobtit/manter_rotina.php',
        data: {
            operacao: 'LISTAR_FERIADOS',
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'cNrdconta.focus();');
        },
        success: function(response) {
            try {
                var r = $.parseJSON(response);
                arrayFeriados = r.feriados;
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'cNrdconta.focus();');
            }
        }
    });
    return false;
}

function habilitaDataVencimentoTR(valor) {
    if (valor == true) {
        $("#dtvencto").datepicker('enable');
    } else {
        $("#dtvencto").datepicker('disable');
    }
    return false;
}

function habilitaAvalista(valor) {
    if (valor == 2) {
        $('#nrcpfava').habilitaCampo();
    } else {
        $('#nrcpfava').desabilitaCampo();
    }
    return false;
}

function listaTitulos(){
    if(!$("#rdvencto1").prop("checked") && !$("#rdvencto2").prop("checked")){
        showError('error', 'Selecione a data de vencimento.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        return false;
    }
    var data = $("#dtmvtolt").val();
    if($("#rdvencto2").prop("checked")){
        if($("#dtvencto").val()==''){
            showError('error', 'Selecione a data de vencimento.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
            return false;
        }
        else{
            data = $("#dtvencto").val();
        }
    }
    showMsgAguardo('Aguarde, buscando dados ...');
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/cobtit/manter_rotina.php',
        data: {
            operacao: 'LISTAR_TITULOS',
            redirect: 'script_ajax',
            nrdconta:nrdconta,
            nrborder:nrborder,
            dtvencto:data
        },
        error: function(objAjax, responseError, objExcept) {
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'cNrdconta.focus();');
        },
        success: function(response) {
            try {
                habilitaDataVencimentoTR(false);
                habilitaAvalista(1);
                $("#frmGerarBoleto input[type='checkbox'],#frmGerarBoleto input[type='radio']").prop("disabled",true);
                $("#frmGerarBoleto input[type='text']").prop("readonly",true);
                $("#divBotoesGerarBoleto").hide();
                var r = $.parseJSON(response);
                $("#divTitulos").html(r.html);
                formataTitulos();
                hideMsgAguardo();
                bloqueiaFundo(divRotina);
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'cNrdconta.focus();');
            }
        }
    });
    return false;
}

function formataTitulos(){
    var divRegistro = $('.divRegistros','#divTitulos');
    var tabela      = $('table', '#divTitulos' );
    var ordemInicial = new Array();
    var arrayLargura = new Array();

    $('#divRotina').css('width','1000');
    tabela.zebraTabela();

    divRegistro.find(".vlpagar").unbind("blur,change").bind("blur",function(){
        var vl = converteMoedaFloat($(this).val());
        var total = converteMoedaFloat($(this).parent().parent().find("input[name='vlpagartotal']").val());
        var id = $(this).attr("id");
        if(vl>total){
            showError("error", "Por favor digite um valor menor ou igual ao valor a pagar.", "Alerta - Ayllos", "bloqueiaFundo(divRotina);$('#"+id+"').focus()", false);
            $(this).val('');
            return false;
        }
    }).bind("change",function(){
        calculaTotal();
    });
    $('#divRotina').centralizaRotinaH();
    layoutPadrao();
}
/*Muda o checkbox e valida regras de seleção*/
function changeCheckbox(obj){
    var tr = $(obj).parent().parent();
    var ch = $(obj).prop("checked");
    var prev = tr.prev("tr.linTitulo");
    var next = tr.next("tr.linTitulo");
    /*Verifica se não é a primeira linha*/
    if(prev.length>0 && ch){
        /*Se esta ativando*/
        /*Verifica se o anterior está checado */
        if(prev.find("input.pagarTitulo").prop("checked")){
            /*Verifica se o valor é completo*/
            var vlanterior = prev.find("input.vlpagar");
            var vl = converteMoedaFloat(vlanterior.val());
            var total = converteMoedaFloat(prev.find("input[name='vlpagartotal']").val());
            if(total>vl){
                showError("error", "O t&iacute;tulo anterior precisa ser pago integralmente para este ser selecionado.", "Alerta - Ayllos", "bloqueiaFundo(divRotina);$('#"+vlanterior.attr("id")+"').focus().select()", false);
                $(obj).prop("checked",false);
                return false;
            }
        }
        else{ // anterior nao selecionado
            showError("error", "Por favor selecione na ordem de data de vencimento.", "Alerta - Ayllos", "bloqueiaFundo(divRotina);", false);
            $(obj).prop("checked",false);
            return false;
        }
    }
    if(next.length>0 && !ch){
        /*Se esta desativando*/
        /*Só deixa desabilitar o último*/
        /*Verifica se possui proxima linha*/
        /*Verifica se a próxima está desabilitada*/
        if(next.find("input.pagarTitulo").prop("checked")){
            showError("error", "Por favor deselecione na ordem de data de vencimento.", "Alerta - Ayllos", "bloqueiaFundo(divRotina);", false);
            $(obj).prop("checked",true);
            return false;
        }
    }
    if(ch){
        if(prev.length>0){
            prev.find("input.vlpagar").prop("readonly",true);
        }
        var pagartotal = tr.find("input[name='vlpagartotal']").val();
        tr.find("input.vlpagar").prop("readonly",false).focus().select().val(pagartotal);
    }
    else{
        if(prev.length>0){
            prev.find("input.vlpagar").prop("readonly",false).focus().select();
        }
        tr.find("input.vlpagar").prop("readonly",true).val(0).blur();
    }
    calculaTotal();
}

function calculaTotal(){
    var totalPagar = 0;
    $.each($("input.pagarTitulo:checked"),function(){
        totalPagar += converteMoedaFloat($(this).parent().parent().find("input.vlpagar").val());
    });
    $("#totpagto").val(number_format(totalPagar,2,',','.'));
}

function checkTodos(){
    $("#divTitulos tr.linTitulo input").prop("checked",$("#checkTodos").prop("checked"));
    var arrTxt = $("#divTitulos tr.linTitulo ");
    var total;
    var pagar;
    if($("#checkTodos").prop("checked")){
        $.each(arrTxt,function(){
            total = $(this).find("input[name='vlpagartotal']");
            pagar = $(this).find("input.vlpagar");
            pagar.val(total.val());
            pagar.prop("readonly",true);
        });
    }
    else{
        $.each(arrTxt,function(){
            pagar = $(this).find("input.vlpagar");
            pagar.val('0,00');
            pagar.prop("readonly",true);
        });
    }
    pagar.prop("readonly",false);
    calculaTotal();
}

function voltarTitulos(){
    $('#divRotina').css('width', '650px').centralizaRotinaH();
    $("#frmGerarBoleto input[type='checkbox'],#frmGerarBoleto input[type='radio']").prop("disabled",false);
    $("#frmGerarBoleto input[type='text']").prop("readonly",false);
    $("#divBotoesGerarBoleto").show();
    $("#divTitulos").html("");
}

function finalizarBoleto(){
    var dt = $("#dtmvtolt").val();
    if($("#rdvencto2").prop("checked")){
        dt = $("#dtvencto").val();
    }
    var msg = 'Sera gerado um boleto no valor de R$ ' + $("#totpagto").val() + ' <br/> com vencimento em ' +  dt + '. Confirma Geracao?';
    showConfirmacao(msg, 'Confirma&ccedil;&atilde;o - Ayllos', 'confirmaGeracaoBoleto();', 'bloqueiaFundo(divRotina)', 'sim.gif', 'nao.gif')
}
function confirmaGeracaoBoleto(){
    // Executa script através de ajax
    var nrtitulo = $("input[name='nrtitulo_selecionado']:checked");
    var vlpagar = $("input[name*='vlpagar['");

    var dt = $("#dtmvtolt").val();
    if($("#rdvencto2").prop("checked")){
        dt = $("#dtvencto").val();
    }
    var nrcpfava = $("#nrcpfava").val();
    var data = {
        sidlogin: $("#sidlogin", "#frmMenu").val(),
        nrdconta:nrdconta,
        operacao:"GERAR_BOLETO",
        nrborder:nrborder,
        nrtitulo: nrtitulo.map(function(){return $(this).val();}).get(),
        redirect: 'html_ajax',
        dtvencto: dt,
        nrcpfava: nrcpfava
    }
    if(nrtitulo.length>0){
        var data = $.param(data)+"&"+vlpagar.serialize();
        $.ajax({
            type: 'POST',
            dataType: 'html',
            url: UrlSite + 'telas/cobtit/manter_rotina.php',
            data: data,
            error: function(objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', "bloqueiaFundo(divRotina)");
            },
            success: function(response) {
                try {
                    hideMsgAguardo();
                    var r = $.parseJSON(response);
                    if(r.status=='erro'){
                        showError("error",r.mensagem,'Alerta - Ayllos','bloqueiaFundo(divRotina)');
                    }
                    else{
                        showError("inform",r.mensagem,'Alerta - Ayllos','carregaManutencao();');
                    }
                    return false;
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
                }
            }
        });
    }
    else{
        showError('error', 'Selecione ao menos um t&iacute;tulo.', 'Alerta - Ayllos', "bloqueiaFundo(divRotina)");
    }
    return false;
}

/*Carrega para o ultimo titulo gerado*/
function carregaManutencao(){
    fechaRotina(divRotina);
}


// Botão Telefone
function consultarTelefone(nriniseq, nrregist) {
    showMsgAguardo('Aguarde, carregando consulta...');
    // Executa script através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobtit/consultas/consultar_telefone.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground()");
        },
        success: function(response) {
            $('#divRotina').html(response);
            montarFormConsultaTelefone(nriniseq, nrregist);
        }
    });
    return false;
}

function montarFormConsultaTelefone(nriniseq, nrregist) {
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobtit/consultas/tab_consulta_telefone.php',
        data: {
            nrdconta: normalizaNumero($('#nrdconta', '#frmBorderos').val()),
            nriniseq: nriniseq,
            nrregist: nrregist,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground();");
        },
        success: function(response) {
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divConteudoOpcao').html(response);
                    exibeRotina($('#divRotina'));
                    formataFormConsultaTelefone();
                    $('#divPesquisaRodape', '#telaConsultaLog').formataRodapePesquisa();
                    hideMsgAguardo();
                    bloqueiaFundo($('#divRotina'));
                    $('#btVoltar', '#divBotoesTelefone').focus();
                    $('#divRotina').centralizaRotinaH();
                    return false;
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            } else {
                try {
                    eval(response);
                    controlaFoco();
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            }
        }
    });
    return false;
}

function formataFormConsultaTelefone() {
    $('#divRotina').css('width', '800px');
    var divRegistro = $('div.divRegistros', '#divTelefone');
    var tabela = $('table', divRegistro);
    divRegistro.css({'height': '200px', 'width': '100%'});

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '90px';
    arrayLargura[1] = '50px';
    arrayLargura[2] = '100px';
    arrayLargura[3] = '50px';
    arrayLargura[4] = '110px';
    arrayLargura[5] = '90px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'center';
    arrayAlinha[6] = 'center';

    var metodoTabela = '';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

    $('table > tbody > tr', divRegistro).dblclick(function() {
        $('#nrdddtelefo', '#divTelefone').val($(this).find('#nrtelefo').val());
        $('#nrdddtelefo', '#divTelefone').focus();
        $('#nrdddtelefo', '#divTelefone').select();
        document.execCommand('copy');

        showError("inform", "Telefone Copiado para Area de Transferencia!", "Alerta - Ayllos", 'bloqueiaFundo(divRotina)');
    });
    return false;
}


// Botão E-mail
function consultarEmail(nriniseq, nrregist) {
    showMsgAguardo('Aguarde, carregando consulta...');
    // Executa script através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobtit/consultas/consultar_email.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground()");
        },
        success: function(response) {
            $('#divRotina').html(response);
            montarFormConsultaEmail(nriniseq, nrregist);
        }
    });
    return false;
}

function montarFormConsultaEmail(nriniseq, nrregist) {
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobtit/consultas/tab_consulta_email.php',
        data: {
            nrdconta: normalizaNumero($('#nrdconta', '#frmBorderos').val()),
            nriniseq: nriniseq,
            nrregist: nrregist,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground();");
        },
        success: function(response) {
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divConteudoOpcao').html(response);
                    exibeRotina($('#divRotina'));
                    formataFormConsultaEmail();
                    $('#divPesquisaRodape', '#telaConsultaEmail').formataRodapePesquisa();
                    hideMsgAguardo();
                    $('#divRotina').centralizaRotinaH();
                    bloqueiaFundo($('#divRotina'));
                    $('#btVoltar', '#divBotoesEmail').focus();
                    return false;
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            } else {
                try {
                    eval(response);
                    controlaFoco();
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            }
        }
    });
    return false;
}

function formataFormConsultaEmail() {
    $('#divRotina').css('width', '600px');
    var divRegistro = $('div.divRegistros', '#divEmail');
    var tabela = $('table', divRegistro);

    divRegistro.css({'height': '200px', 'width': '100%'});
    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '300px';
    arrayLargura[1] = '100px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'right';
    arrayAlinha[2] = 'right';

    var metodoTabela = '';
    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);
    return false;
}

function pesquisaEmail() {
    procedure = 'BUSCAR_EMAIL';
    titulo = 'Consulta E-mail';
    qtReg = '20';
    filtrosPesq = 'E-mail;dsdemail;200px;S;;;descricao|Conta;nrdconta;100px;S;' + normalizaNumero($('#nrdconta', '#frmBorderos').val()) + ';N';
    colunas = 'E-mail;dsdemail;100%;center';
    mostraPesquisa('TELA_COBTIT', procedure, titulo, qtReg, filtrosPesq, colunas, $('#divRotina'));
    return false;
}
/*
function pesquisaCelular() {
    procedure = 'BUSCAR_CELULAR';
    titulo = 'Consulta Celular';
    qtReg = '20';
    filtrosPesq = 'DDD;nrdddtfc;200px;S;;N;descricao|Celular;nrtelefo;200px;S;;N;descricao|Contato;nmpescto;200px;S;;;descricao|Conta;nrdconta;100px;S;' + normalizaNumero($('#nrdconta', '#frmBorderos').val()) + ';N';
    colunas = 'DDD;nrdddtfc;20%;center|Celular;nrtelefo;30%;center|Contato;nmpescto;50%;center';
    mostraPesquisa('TELA_COBTIT', procedure, titulo, qtReg, filtrosPesq, colunas, $('#divRotina'));
    return false;
}*/

function controlaPesquisaPac() {
    var cdagenci = 0;
    procedure = 'COBTIT_BUSCA_LISTA_PA';
    titulo = 'Pesquisa PA';
    qtReg = '999';
    filtrosPesq = 'Cod. PA;cdagenci;30px;S;' + cdagenci + ';S';
    colunas = 'Codigo;cdagenci;20%;right|descricao;nmresage;50%;left';
    mostraPesquisa('COBTIT', procedure, titulo, qtReg, filtrosPesq, colunas, '');
    return false;

}

// Botão Enviar E-mail
function enviarEmail() {

    showMsgAguardo('Aguarde, carregando rotina para envio de e-mail...');

    // Executa script através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobtit/enviar_email.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground()");
        },
        success: function(response) {
            console.log(UrlSite);
            $('#divRotina').html(response);
            buscarDetalheEnvio();
        }
    });
    return false;
}

function buscarDetalheEnvio() {

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobtit/tab_enviar_email.php',
        data: {
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground();");
        },
        success: function(response) {
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divConteudoOpcao').html(response);
                    exibeRotina($('#divRotina'));

                    formataEnvioEmail();

                    hideMsgAguardo();
                    bloqueiaFundo($('#divRotina'));
                    $('#divRotina').setCenterPosition();
                    return false;
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            } else {
                try {
                    eval(response);
                    controlaFoco();
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            }
        }
    });
    return false;
}

function formataEnvioEmail() {

    // Ajusta tamanho do form
    $('#divRotina').css('width', '600px');

    var frmEnviarEmail = "frmEnviarEmail";

    // Rotulos
    var rDsdemail = $('label[for="dsdemail"]', '#' + frmEnviarEmail);
    rDsdemail.addClass('rotulo').css('width', '100px');

    // Campos
    var cDsdemail = $('#dsdemail', '#' + frmEnviarEmail);
    cDsdemail.css('width', '380px').attr('maxlength', '60');

    layoutPadrao();
    hideMsgAguardo();

    cDsdemail.focus();

    return false;
}

function confirmaEnvioEmail() {

    if ($('#dsdemail', '#frmEnviarEmail').val() == '') {
        showError('error', 'E-mail deve ser informado!', 'Alerta - Ayllos', "bloqueiaFundo($('#divRotina'))");
        return false;
    } else {
        showConfirmacao('Confirma o Envio do Boleto: ' + nrdocmto + ' por E-mail ?', 'Confirma&ccedil;&atilde;o - Ayllos', 'processaEnvioEmail();', 'cancelaConfirmacao();', 'sim.gif', 'nao.gif');
    }
}

function processaEnvioEmail() {

    var dsdemail = $('#dsdemail', '#frmEnviarEmail').val();
    var indretor = 0;

    showMsgAguardo('Aguarde, carregando rotina para envio de email...');

    // Executa script através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobtit/manter_rotina.php',
        data: {
            nrdconta: nrdconta,
            nrborder: nrborder,
            nrdocmto: nrdocmto,
            nrctacob: nrctacob,
            nrcnvcob: nrcnvcob,
            tpdenvio: 1, // Email
            dsdemail: dsdemail,
            indretor: indretor,
            operacao: 'ENVIAR_EMAIL',
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            try {
                hideMsgAguardo();
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });

    return false;
}

function confirmaBaixaBoleto() {
    showConfirmacao('Confirma a Baixa do Boleto: ' + nrdocmto + ' ?', 'Confirma&ccedil;&atilde;o - Ayllos', 'abreJustificativaBaixa();', 'return false;', 'sim.gif', 'nao.gif');
}

function abreJustificativaBaixa() {
    showMsgAguardo('Aguarde, carregando rotina para justificativa de baixa...');

    // Executa script através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobtit/enviar_justificativa.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground()");
        },
        success: function(response) {
            $('#divRotina').html(response);
            montarFormJustificativa();
        }
    });

    return false;

}

function montarFormJustificativa() {

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobtit/tab_justificativa.php',
        data: {
            nrdconta: nrdconta,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground();");
        },
        success: function(response) {

            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divConteudoOpcao').html(response);
                    exibeRotina($('#divRotina'));

                    formataFormJustificativa();

                    hideMsgAguardo();
                    bloqueiaFundo($('#divRotina'));
                    $('#divRotina').setCenterPosition();
                    highlightObjFocus($('#frmJustificativa'));
                    return false;
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            } else {
                try {
                    eval(response);
                    controlaFoco();
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            }
        }
    });
    return false;
}

function formataFormJustificativa() {
    // Ajusta tamanho do form
    $('#divRotina').css('width', '400px');
    var cDsjustifica_baixa = $('#dsjustifica_baixa', '#frmJustificativa');
    cDsjustifica_baixa.addClass('campo alphanum').attr('maxlength', '200').css({'width':'350px', 'height':'70px'});

    layoutPadrao();
    hideMsgAguardo();
    cDsjustifica_baixa.focus();

    return false;
}

function validaFormJustificativa() {
    var dsjustif = $('#dsjustifica_baixa', '#frmJustificativa').val();
    if (dsjustif.length < 5) {
        showError('error', 'Justificativa da Baixa deve ser informada!', 'Alerta - Ayllos', "$('#dsjustifica_baixa', '#frmJustificativa').focus(); bloqueiaFundo($('#divRotina'))");
        return false;
    }
    baixarBoleto();

    return false;
}

function baixarBoleto() {
    showMsgAguardo('Aguarde, carregando rotina de baixa...');

    var dsjustif = $('#dsjustifica_baixa', '#frmJustificativa').val();

    // Executa script através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobtit/manter_rotina.php',
        data: {
            nrdconta: nrdconta,
            nrborder: nrborder,
            nrdocmto: nrdocmto,
            nrctacob: nrctacob,
            nrcnvcob: nrcnvcob,
            dsjustif: dsjustif,
            operacao: 'BAIXAR_BOLETO',
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function(response) {
            try {
                hideMsgAguardo();
                var r = $.parseJSON(response);
                if(r.status=='erro'){
                    showError("error",r.mensagem,'Alerta - Ayllos','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));carregaManutencao();fechaRotina($(\'#divRotina\'));');
                }
                else{
                    showError("inform",r.mensagem,'Alerta - Ayllos',"blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));carregaManutencao();fechaRotina($(\'#divRotina\'));");
                }
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
            }
        }
    });

    return false;
}

function confirmaImpressaoBoleto() {
    showConfirmacao('Confirma a Impress&atilde;o do Boleto: ' + nrdocmto + ' ?', 'Confirma&ccedil;&atilde;o - Ayllos', 'carregarImpressoBoleto();', '', 'sim.gif', 'nao.gif');

}

function carregarImpressoBoleto() {

    var vr_nmform = 'frmImpBoleto';

    fechaRotina($('#divUsoGenerico'), $('#divRotina'));

    $('#sidlogin', '#' + vr_nmform).remove();
    $('#nrcnvcob1', '#' + vr_nmform).remove();
    $('#nrdocmto1', '#' + vr_nmform).remove();
    $('#nrdconta1', '#' + vr_nmform).remove();

    // Insere input do tipo hidden do formulário para enviá-los posteriormente
    $('#' + vr_nmform).append('<input type="text" id="nrcnvcob1" name="nrcnvcob1" />');
    $('#' + vr_nmform).append('<input type="text" id="nrdocmto1" name="nrdocmto1" />');
    $('#' + vr_nmform).append('<input type="text" id="nrdconta1" name="nrdconta1" />');
    $('#' + vr_nmform).append('<input type="text" id="sidlogin" name="sidlogin" />');

    // Agora insiro os devidos valores nos inputs criados
    $('#nrcnvcob1', '#' + vr_nmform).val(nrcnvcob);
    $('#nrdocmto1', '#' + vr_nmform).val(nrdocmto);
    $('#nrdconta1', '#' + vr_nmform).val(nrdconta);
    $('#sidlogin', '#' + vr_nmform).val($('#sidlogin', '#frmMenu').val());


    var action = UrlSite + 'telas/cobtit/imprimir_boleto.php';

    // Variavel para os comandos de controle
    var controle = '';

    carregaImpressaoAyllos(vr_nmform, action, controle);

    return false;
}
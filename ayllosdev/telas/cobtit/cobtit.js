/*!
 * FONTE        : cobtit.js
 * CRIAÇÃO      : Luis Fernando (GFT)
 * DATA CRIAÇÃO : 21/05/2018
 * OBJETIVO     : Biblioteca de funções na rotina COBTIT
 * --------------
 */

//Labels/Campos do cabeçalho
var cCddopcao,rCddopcao,cTodosCabecalho,cTodosFrmBorderos,btnCab;

var glbIdarquivo,glbInsitarq;
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
    highlightObjFocus($('#frmArquivos'));

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

    $('#frmArquivos').css({'display': 'none'});
    $('#divBotoesfrmArquivos').css({'display': 'none'});
    $('#divTabfrmArquivos').html('');

    // Limpa conteudo da divBotoes
    $('#divBotoes', '#divTela').html('');
    $('#divBotoes').css({'display': 'none'});

    // Aplica Layout nos fontes PHP
    formataCabecalho();
    formataFrmManutencao();
    formataFrmBorderos();
    formataFrmArquivos();

    // Limpa informações dos Formularios
    cTodosCabecalho.limpaFormulario();
    cTodosFrmManutencao.limpaFormulario();
    cTodosFrmBorderos.limpaFormulario();
    cTodosFrmArquivos.limpaFormulario();

    cCddopcao.val(cddopcao);

    removeOpacidade('divTela');
    bloqueiaFundo(divRotina);
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
            divBotoes(act);
            $('#divBotoes').css({'display': 'block'});
    	break;
    	case 'C':
    		nomeForm = 'frmBorderos';
	        $('#'+nomeForm).css({'display': 'block'});
	        $('#nrdconta', '#'+nomeForm).focus();
            act = "continuarC()";
            divBotoes(act);
            $('#divBotoes').css({'display': 'block'});
    	break;
        case 'Y':
            nomeForm = 'frmArquivos';
            $('#'+nomeForm).css({'display': 'block'});
            $('#dtarqini', '#frmArquivos').val($('#dtarqini', '#frmArquivos').attr('dtini')).focus();
            $('#dtarqfim', '#frmArquivos').val($('#dtarqfim', '#frmArquivos').attr('dtfim'));
            continuarY();
        break;
    }
    return false;
}

// Monta divBotoes
function divBotoes(act) {
    $('#divBotoes', '#divTela').html('');
    $('#divBotoes', '#divTela').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>');
    $('#divBotoes', '#divTela').append('<a href="#" class="botao" onClick="'+act+'" return false;" >Consultar</a>');
    return false;
}

function pesquisaAssociados(tipo) {
    var form;
    
    if (tipo == 'M'){
        form = 'frmManutencao';
    }else if (tipo == 'B'){
        form = 'frmBorderos';
    }
    if ($('#nrdconta', '#frmBorderos').hasClass('campoTelaSemBorda')) {
        return false;
    }
    mostraPesquisaAssociado('nrdconta', form);
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

function formataFrmArquivos() {
    // cabecalho
    rDtarqini = $('label[for="dtarqini"]', '#frmArquivos');
    rDtarqfim = $('label[for="dtarqfim"]', '#frmArquivos');
    rNmarquiv = $('label[for="nmarquiv"]', '#frmArquivos');

    cDtarqini = $('#dtarqini', '#frmArquivos');
    cDtarqfim = $('#dtarqfim', '#frmArquivos');
    cNmarquiv = $('#nmarquiv', '#frmArquivos');

    cTodosFrmArquivos = $('input[type="text"],select', '#frmArquivos');

    rDtarqini.css({'width': '105'});
    rDtarqfim.css({'width': '28px'});
    rNmarquiv.css({'width': '200px'});

    cDtarqini.css({'width': '75px'}).setMask('DATE', '', '', '');
    cDtarqfim.css({'width': '75px'}).setMask('DATE', '', '', '');
    cNmarquiv.addClass('alphanum').css({'width': '264px'});

    cTodosFrmArquivos.habilitaCampo();

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
    }).unbind("change").bind("change",function(){
        if($(this).val()!=''){
            continuarC();
        }
    })
    ;

    // frmManutencao
    $('#nrdconta', '#frmManutencao').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            contaManutencao();
        }
    }).unbind("change").bind("change",function(e){
        contaManutencao();
    });

    $('#dtpagtof', '#frmManutencao').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            continuarM();
        }
    });

    // frmArquivos
    $('#nmarquiv', '#frmArquivos').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            carregaArquivos(1,15);
        }
    });
    return false;
}

function contaManutencao(){
    nomeForm = "frmManutencao";
    $('#nmprimtl', '#' + nomeForm).val('');
    $('#nrdconta', '#frmManutencao').removeClass('campoErro');
    if ($('#nrdconta', '#frmManutencao').val() != '') {
        buscaAssociado(function(){
            $("#nrborder","#frmManutencao").focus();
        });
        return false;
    }
    else{
        $("#nrborder","#frmManutencao").focus();
    }
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
        showError("error", "N&uacute;mero da Conta deve ser informado.", "Alerta - Ayllos", "$('#nrdconta', '#frmBorderos').focus()", false);
        return false;
    }
}

function continuarM(){
    if (cCddopcao.val() == 'M') {
        var nrdconta = normalizaNumero($('#nrdconta', '#frmManutencao').val());
        var nrborder = normalizaNumero($('#nrborder', '#frmManutencao').val());
        var dtbaixai = $('#dtbaixai', '#frmManutencao').val();
        var dtemissi = $('#dtemissi', '#frmManutencao').val();
        var dtvencti = $('#dtvencti', '#frmManutencao').val();
        var dtpagtoi = $('#dtpagtoi', '#frmManutencao').val();
        if (nrdconta == '') {
            if (nrborder != '') {
                showError("error", "N&uacute;mero da Conta deve ser informado.", "Alerta - Ayllos", "$('#nrdconta', '#frmManutencao').focus()", false);
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

function continuarY(){
    // carregaArquivos(1,15);
}

function formataBorderosManutencao() {
    $('#divRotina').css('width','1000');

    var divRegistro = $('div.divRegistros', '#divTabfrmManutencao');
    var tabela = $('table', divRegistro);
//    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({'height': '220px', 'width': '100%'});

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '35px';
    arrayLargura[1] = '75px';
    arrayLargura[2] = '55px';
    arrayLargura[3] = '70px';
    arrayLargura[4] = '60px';
    arrayLargura[5] = '70px';
    arrayLargura[6] = '70px';
    arrayLargura[7] = '70px';
    arrayLargura[8] = '70px';
    arrayLargura[9] = '70px';
    arrayLargura[10] = '';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'center';
    arrayAlinha[6] = 'right';
    arrayAlinha[7] = 'center';
    arrayAlinha[8] = 'right';
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
        lindigit = $(this).find("#lindigit").val();
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
            try {
                var r = $.parseJSON(response);
                if(r.status=='erro'){
                    hideMsgAguardo();
                    showError("error",r.mensagem,'Alerta - Ayllos','$("#nrdconta", "#frmManutencao").focus();');
                    bloqueiaFundo($("#divError"));
                    $("#divTabfrmManutencao").html('');
                }
                else{
                    $("#divTabfrmManutencao").html(r.html);
                    $('#divTabfrmManutencao').css({'display': 'block'});
                    $('#divBotoesfrmManutencao').css({'display': 'block'});
                    $('#divBotoes').css({'display': 'none'});
                    
                    formataBorderosManutencao();

                    $('#divPesquisaRodape', '#divTabfrmManutencao').formataRodapePesquisa();
                     cTodosFrmManutencao.desabilitaCampo();
                    hideMsgAguardo();
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

function buscaAssociado(callback) {
    var cNrdconta = $("#nrdconta",'#'+nomeForm);
    var nrdconta = normalizaNumero(cNrdconta.val());
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
            		showError("error",r.mensagem,'Alerta - Ayllos','$("#nrdconta","#"+nomeForm).focus();');
                    $("#nrdconta",'#'+nomeForm).val('');
	            	$("#nmprimtl",'#'+nomeForm).val('');
            	}
            	else{
                    $("#nrdconta",'#'+nomeForm).val(r.nrdconta).keyup();
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
    showMsgAguardo('Aguarde, buscando dados ...');
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
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;atilde;o.', 'Alerta - Ayllos', "bloqueiaFundo(divRotina)");
        },
        success: function(response) {
            hideMsgAguardo();
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
    arrayLargura[1] = '70px';
    arrayLargura[2] = '70px';
    arrayLargura[3] = '100px';
    arrayLargura[4] = '100px'; //tipo cobranca
    arrayLargura[5] = '100px';
    arrayLargura[6] = '100px';
    arrayLargura[7] = '100px';
    arrayLargura[8] = '';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'center';
	arrayAlinha[4] = 'right';
    arrayAlinha[5] = 'center';
    arrayAlinha[6] = 'center';
    arrayAlinha[7] = 'right';
    arrayAlinha[8] = 'center';

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
    nomeForm = "telaGerarBoleto";
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

    /*Valida se Avalista está selecionado*/
    if($("#rdsacado2").prop("checked")){
        if($('#nrcpfava',"#"+nomeForm).val()==''){
            showError('error', 'Selecione um avalista.', 'Alerta - Ayllos', "bloqueiaFundo(divRotina)");
            return false;
        }
    }
    else if(!$("#rdsacado1").prop("checked")){
        showError('error', 'Selecione um avalista.', 'Alerta - Ayllos', "bloqueiaFundo(divRotina)");
        return false;
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
            showError("error", "Por favor remova a sele&ccedil;&atilde;o na ordem de data de vencimento.", "Alerta - Ayllos", "bloqueiaFundo(divRotina);", false);
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
        showMsgAguardo('Aguarde, gerando t&iacute;tulo...');
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
    chamaRotinaManutencao();
}


// Botão Telefone
function consultarTelefone(nriniseq, nrregist) {
    showMsgAguardo('Aguarde, carregando consulta...');
    // Executa script através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobtit/consultar_telefone.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', "bloqueiaFundo(divRotina)");
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
        url: UrlSite + 'telas/cobtit/tab_consulta_telefone.php',
        data: {
            nrdconta: normalizaNumero(nrdconta),
            nriniseq: nriniseq,
            nrregist: nrregist,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', "bloqueiaFundo(divRotina);");
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
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
                }
            } else {
                try {
                    eval(response);
                    controlaFoco();
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
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
        url: UrlSite + 'telas/cobtit/consultar_email.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', "bloqueiaFundo(divRotina)");
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
        url: UrlSite + 'telas/cobtit/tab_consulta_email.php',
        data: {
            nrdconta: normalizaNumero(nrdconta),
            nriniseq: nriniseq,
            nrregist: nrregist,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', "bloqueiaFundo(divRotina);");
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
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
                }
            } else {
                try {
                    eval(response);
                    controlaFoco();
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
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
    procedure = 'COBTIT_BUSCAR_EMAIL';
    titulo = 'Consulta E-mail';
    qtReg = '20';
    filtrosPesq = 'E-mail;dsdemail;200px;S;;N|Conta;nrdconta;100px;S;' + normalizaNumero(nrdconta) + ';N';
    colunas = 'E-mail;dsdemail;100%;center';
    mostraPesquisa('COBTIT', procedure, titulo, qtReg, filtrosPesq, colunas, $('#divRotina'));
    $('#btPesquisar', '#formPesquisa').parent().hide();
    return false;
}

function pesquisaCelular() {
    procedure = 'COBTIT_BUSCAR_TELEFONE';
    titulo = 'Consulta Celular';
    qtReg = '20';
    filtrosPesq = 'DDD;nrdddtfc;200px;S;;N;descricao|Celular;nrtelefo;200px;S;;N;descricao|Contato;nmpescto;200px;S;;;descricao|Conta;nrdconta;100px;S;' + normalizaNumero(nrdconta) + ';N|ApenasCel;flcelula;100px;S;1;N';
    colunas = 'DDD;nrdddtfc;20%;center|Celular;nrtelefo;30%;center|Contato;nmpescto;50%;center';
    mostraPesquisa('COBTIT', procedure, titulo, qtReg, filtrosPesq, colunas, $('#divRotina'));
    $('#btPesquisar', '#formPesquisa').parent().hide();
    return false;
}

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

function chamaRotinaManutencao(){
    estadoInicial();
    $('#cddopcao', '#frmCab').val("M").habilitaCampo();
    controlaOpcao();
    $("#nrdconta","#"+nomeForm).val(nrdconta);
    $("#nrborder","#"+nomeForm).val(nrborder);
    $("#cdagenci","#"+nomeForm).val(0);
    continuarM();

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
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', "bloqueiaFundo(divRotina)");
        },
        success: function(response) {
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
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', "bloqueiaFundo(divRotina);");
        },
        success: function(response) {
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divConteudoOpcao').html(response);
                    exibeRotina($('#divRotina'));
                    formataEnvioEmail();
                    hideMsgAguardo();
                    bloqueiaFundo($('#divRotina'));
                    $('#divRotina').centralizaRotinaH();
                    return false;
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
                }
            } else {
                try {
                    eval(response);
                    controlaFoco();
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
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
            operacao: 'ENVIAR_BOLETO',
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "bloqueiaFundo(divRotina)");
        },
        success: function(response) {
            try {
                hideMsgAguardo();
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "bloqueiaFundo(divRotina)");
            }
        }
    });

    return false;
}

function validaEnvioSMS() {

    var nrdddtfc = $('#nrdddtfc', '#frmEnviarSMS').val();
    var nmpescto = $('#nmpescto', '#frmEnviarSMS').val();
    var nrtelefo = $('#nrtelefo', '#frmEnviarSMS').val();

    if (nrdddtfc.length < 2) {
        showError('error', 'DDD deve ser informado!', 'Alerta - Ayllos', "$('#nrdddtfc', '#frmEnviarSMS').focus(); bloqueiaFundo($('#divRotina'))");
        return false;
    }

    if (nrtelefo.length < 8) {
        showError('error', 'Telefone deve ser informado!', 'Alerta - Ayllos', "$('#nrtelefo', '#frmEnviarSMS').focus(); bloqueiaFundo($('#divRotina'))");
        return false;
    }

    if (nmpescto.length < 2) {
        showError('error', 'Nome do Contato deve ser informado!', 'Alerta - Ayllos', "$('#nmpescto', '#frmEnviarSMS').focus(); bloqueiaFundo($('#divRotina'))");
        return false;
    }

    confirmaEnvioSMS();

    return false;
}

function processaEnvioSMS() {
    var nrdddtfc = $('#nrdddtfc', '#frmEnviarSMS').val();
    var nmpescto = $('#nmpescto', '#frmEnviarSMS').val();
    var nrtelefo = $('#nrtelefo', '#frmEnviarSMS').val();
    var textosms;
    var indretor = 0;

    showMsgAguardo('Aguarde, carregando rotina para envio de sms...');

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
            tpdenvio: 2, // SMS
            indretor: indretor,
            nmpescto: nmpescto,
            nrdddtfc: nrdddtfc,
            nrtelefo: nrtelefo,
            textosms: textosms,
            operacao: 'ENVIAR_BOLETO',
            redirect: 'html_ajax'

        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "bloqueiaFundo(divRotina)");
        },
        success: function(response) {
            try {
                hideMsgAguardo();
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "bloqueiaFundo(divRotina)");
            }
        }
    });

    return false;
}

function cancelaConfirmacao() {
    bloqueiaFundo($('#divRotina'));
    return false;
}

function confirmaEnvioSMS() {

    showConfirmacao('Confirma o Envio da Linha Digitavel por SMS ?', 'Confirma&ccedil;&atilde;o - Ayllos', 'processaEnvioSMS();', 'cancelaConfirmacao();', 'sim.gif', 'nao.gif');

}
// Botão Enviar SMS
function enviarSMS() {

    showMsgAguardo('Aguarde, carregando rotina para envio de e-mail...');

    // Executa script através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobtit/enviar_sms.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', "bloqueiaFundo(divRotina)");
        },
        success: function(response) {
            $('#divRotina').html(response);
            montarFormEnvioSMS();
        }
    });

    return false;

}

function montarFormEnvioSMS() {
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobtit/tab_enviar_sms.php',
        data: {
            nrdconta: nrdconta,
            lindigit: lindigit,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', "bloqueiaFundo(divRotina);");
        },
        success: function(response) {
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divConteudoOpcao').html(response);
                    exibeRotina($('#divRotina'));
                    formataFormEnvioSMS();
                    hideMsgAguardo();
                    bloqueiaFundo($('#divRotina'));
                    $('#divRotina').centralizaRotinaH();
                    return false;
                } catch (error) {
                    console.log(error);
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
                }
            } else {
                try {
                    eval(response);
                    controlaFoco();
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
                }
            }
        }
    });
    return false;
}

function formataFormEnvioSMS() {

    // Ajusta tamanho do form
    $('#divRotina').css('width', '600px');

    var frmEnviarSMS = "frmEnviarSMS";

    // Rotulos
    var rNrdddtfc = $('label[for="nrdddtfc"]', '#' + frmEnviarSMS);
    var rNrtelefo = $('label[for="nrtelefo"]', '#' + frmEnviarSMS);
    var rNmpescto = $('label[for="nmpescto"]', '#' + frmEnviarSMS);

    rNrdddtfc.addClass('rotulo').css('width', '50px');
    rNrtelefo.addClass('rotulo-linha').css('width', '60px');
    rNmpescto.addClass('rotulo-linha').css('width', '60px');

    // Campos
    var cNrdddtfc = $('#nrdddtfc', '#' + frmEnviarSMS);
    var cNrtelefo = $('#nrtelefo', '#' + frmEnviarSMS);
    var cNmpescto = $('#nmpescto', '#' + frmEnviarSMS);

    cNrdddtfc.addClass('inteiro').attr('maxlength', '3').css('width', '40px');
    cNrtelefo.addClass('inteiro').attr('maxlength', '10').css('width', '97px');
    cNmpescto.addClass('alphanum').attr('maxlength', '30').css('width', '220px');

    layoutPadrao();
    hideMsgAguardo();

    cNrdddtfc.focus();

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
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', "bloqueiaFundo(divRotina)");
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
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', "bloqueiaFundo(divRotina);");
        },
        success: function(response) {
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divConteudoOpcao').html(response);
                    exibeRotina($('#divRotina'));
                    formataFormJustificativa();
                    hideMsgAguardo();
                    bloqueiaFundo($('#divRotina'));
                    $('#divRotina').centralizaRotinaH();
                    return false;
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
                }
            } else {
                try {
                    eval(response);
                    controlaFoco();
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
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
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "bloqueiaFundo(divRotina)");
        },
        success: function(response) {
            try {
                hideMsgAguardo();
                var r = $.parseJSON(response);
                if(r.status=='erro'){
                    showError("error",r.mensagem,'Alerta - Ayllos','bloqueiaFundo(divRotina);carregaManutencao();fechaRotina($(\'#divRotina\'));');
                }
                else{
                    showError("inform",r.mensagem,'Alerta - Ayllos',"bloqueiaFundo(divRotina);continuarM();fechaRotina($(\'#divRotina\'));");
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
    $('#nrdconta1', '#' + vr_nmform).val(nrctacob);
    $('#sidlogin', '#' + vr_nmform).val($('#sidlogin', '#frmMenu').val());


    var action = UrlSite + 'telas/cobtit/imprimir_boleto.php';

    // Variavel para os comandos de controle
    var controle = '';

    carregaImpressaoAyllos(vr_nmform, action, controle);

    return false;
}


function controlafrmEnviarSMS() {
    $("#frmEnviarSMS .navigation").bind("keypress",(function(e) {
        nextField(e,this);
    }));

    $('#nmpescto', '#frmEnviarSMS').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            validaEnvioSMS();
            return false;
        }
    });
    return false;

}

function copiarTextoSMS(){
    $('#textosms', '#frmEnviarSMS').focus();
    $('#textosms', '#frmEnviarSMS').select();
    document.execCommand('copy');
    return false;
}


// Botão Log
function consultarLog(nriniseq, nrregist) {
    showMsgAguardo('Aguarde, carregando Consulta de Log...');
    // Executa script através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobtit/consultar_log.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "bloqueiaFundo(divRotina)");
        },
        success: function(response) {
            $('#divRotina').html(response);
            montarFormConsultaLog(nriniseq, nrregist);
        }
    });
    return false;
}

function montarFormConsultaLog(nriniseq, nrregist) {
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobtit/tab_consulta_log.php',
        data: {
            nrdconta: nrctacob,
            nrborder: nrborder,
            nrdocmto: nrdocmto,
            nrctacob: nrctacob,
            nrcnvcob: nrcnvcob,
            nriniseq: nriniseq,
            nrregist: nrregist,
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "bloqueiaFundo(divRotina);");
        },
        success: function(response) {
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divConteudoOpcao').html(response);
                    exibeRotina($('#divRotina'));
                    formataFormConsultaLog();
                    $('#divPesquisaRodape', '#telaConsultaLog').formataRodapePesquisa();
                    hideMsgAguardo();
                    bloqueiaFundo($('#divRotina'));
                    $('#btVoltar', '#divBotoesLog').focus();
                    $('#divRotina').centralizaRotinaH();
                    return false;
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
                }
            } else {
                try {
                    eval(response);
                    controlaFoco();
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
                }
            }
        }
    });
    return false;
}

function formataFormConsultaLog() {
    $('#divRotina').css('width', '740px');
    var divRegistro = $('div.divRegistros', '#divLogs');
    var tabela = $('table', divRegistro);
    divRegistro.css({'height': '240px', 'width': '100%'});

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '110px';
    arrayLargura[1] = '430px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'center';

    var metodoTabela = '';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

    return false;
}


function carregaArquivos(nriniseq, nrregist) {
    var dtarqini = $('#dtarqini', '#frmArquivos').val();
    var dtarqfim = $('#dtarqfim', '#frmArquivos').val();
    var nmarquiv = $('#nmarquiv', '#frmArquivos').val();
    if (dtarqini == '') {
        showError("error", "Informe a Data Inicial.", "Alerta - Ayllos", "$('#dtarqini', '#frmArquivos').focus()", false);
        return false;
    }
    if (dtarqfim == '') {
        showError("error", "Informe a Data Final.", "Alerta - Ayllos", "$('#dtarqfim', '#frmArquivos').focus()", false);
        return false;
    }
    if (nmarquiv.length < 6 && nmarquiv != '') {
        showError("error", "Nome do Arquivo Deve ter no Minimo Seis Caracteres.", "Alerta - Ayllos", "$('#nmarquiv', '#frmArquivos').focus()", false);
        return false;
    }

    // Se diferenca for maior que 6 meses
    if (retornaDateDiff('M',dtarqini,dtarqfim) > 6) {
        showError("error", "O intervalo de datas ultrapassou o limite m&aacute;ximo permitido de 6 meses.", "Alerta - Ayllos", "$('#dtarqfim', '#frmArquivos').focus()", false);
        return false;
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, efetuando consulta ...");

    // Carrega dados parametro através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobtit/carrega_arquivos.php',
        data:
                {
                    cddopcao: cCddopcao.val(),
                    dtarqini: dtarqini,
                    dtarqfim: dtarqfim,
                    nmarquiv: nmarquiv,
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
                    $('#divTabfrmArquivos').html(response);
                    $('#divTabfrmArquivos').css({'display': 'block'});
                    $('#divBotoesfrmArquivos').css({'display': 'block'});
                    $('#frmArquivos').css({'display': 'block'});
                    $('#dtarqini', '#frmArquivos').focus();

                    formataArquivos();
                    $('#divPesquisaRodape', '#divTabfrmArquivos').formataRodapePesquisa();

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
}

function formataArquivos() {
    $('#divRotina').css('width', '640px');
    var divRegistro = $('div.divRegistros', '#divTabfrmArquivos');
    var tabela = $('table', divRegistro);
    divRegistro.css({'height': '220px', 'width': '100%'});

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '100px';
    arrayLargura[1] = '80px';
    arrayLargura[2] = '300px';
    arrayLargura[3] = '100px';
    arrayLargura[4] = '100px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'left';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'center';

    var metodoTabela = '';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);
    // seleciona o registro que é clicado
    $('table > tbody > tr', divRegistro).click(function() {
        glbIdarquivo = $(this).find('#idarquivo').val();
        glbInsitarq  = $(this).find('#situacaoarq').val();
    });

    $('table > tbody > tr:eq(0)', divRegistro).click();

    return false;
}

function formataImprimirRelatorio() {
    // Ajusta tamanho do form
    $('#divRotina').css({'width' : '260px', 'height' : '200px'});
    exibeRotina($('#divRotina'));
    bloqueiaFundo($('#divRotina'));
    $('#divRotina').setCenterPosition();
    highlightObjFocus($('#frmNomArquivo'));
    layoutPadrao();
    return false;
}

//Botao Imprimir
function btnImprimir() {
    if (glbIdarquivo == 0) {
      showError('error', 'Nenhuma Remessa Selecionada.', 'Alerta - Ayllos', "unblockBackground()");
      return false;
    }
    if (glbInsitarq.toUpperCase() == 'PENDENTE') {
      showMsgAguardo('Aguarde, carregando rotina para impressao...');
      // Executa script através de ajax
      $.ajax({
          type: 'POST',
          dataType: 'html',
          url: UrlSite + 'telas/cobtit/form_relatorio.php',
          data: {
              redirect: 'html_ajax'
          },
          error: function(objAjax, responseError, objExcept) {
              hideMsgAguardo();
              showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground()");
          },
          success: function(response) {
              $('#divRotina').html(response);
              formataImprimirRelatorio();
          }
      });

      hideMsgAguardo();
    } else {
      imprimir_relatorio(0);
    }
    return false;
}

// Função para gerar impressão em PDF
function imprimir_relatorio(flgcriti) {
    $("#idarquivo","#frmImprimir").val(glbIdarquivo);
    $("#flgcriti","#frmImprimir").val(flgcriti);
    var action = $("#frmImprimir").attr("action");
    var callafter = "";
    carregaImpressaoAyllos("frmImprimir",action,callafter);
  return false;
}

function abreImportacao() {
    showMsgAguardo('Aguarde, carregando rotina para importacao...');
    // Executa script através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobtit/enviar_arquivo.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground()");
        },
        success: function(response) {
            $('#divRotina').html(response);
            montarFormImportacao();
        }
    });

    return false;
}

function montarFormImportacao() {
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobtit/tab_importar_arquivo.php',
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
                    formataFormArquivo();
                    hideMsgAguardo();
                    bloqueiaFundo($('#divRotina'));
                    $('#divRotina').setCenterPosition();
                    highlightObjFocus($('#frmNomArquivo'));
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

function formataFormArquivo() {
    // Ajusta tamanho do form
    $('#divRotina').css('width', '400px');

    var cNmarquiv = $('#nmarquiv', '#frmNomArquivo');
    cNmarquiv.addClass('alphanum campo').attr('maxlength', '100').css({'width':'350px'});

    layoutPadrao();
    hideMsgAguardo();

    cNmarquiv.focus();
    return false;
}

function confirmaImportacao() {
    var flgreimp = $('#flgreimp', '#frmNomArquivo').val();
    var nmarquiv = $('#nmarquiv', '#frmNomArquivo').val().replace(/[^a-z0-9._]/gi, '');
    
    if (nmarquiv.length < 18) {
        showError('error', 'Formato do Nome do Arquivo Invalido!', 'Alerta - Ayllos', "$('#nmarquiv', '#frmNomArquivo').focus(); bloqueiaFundo($('#divRotina'))");
        return false;
    } else {
        showConfirmacao('Confirma a ' + (flgreimp == 1 ? 're' : '') + 'importa&ccedil;&atilde;o do arquivo: ' + nmarquiv + ' ?', 'Confirma&ccedil;&atilde;o - Ayllos', 'importarArquivo();', 'bloqueiaFundo(divRotina)', 'sim.gif', 'nao.gif');
    }
}

function importarArquivo() {
    showMsgAguardo('Aguarde, carregando importacao de arquivo...');
    var nmarquiv = $('#nmarquiv', '#frmNomArquivo').val().replace(/[^a-z0-9._]/gi, '');
    var flgreimp = $('#flgreimp', '#frmNomArquivo').val();

    // Executa script através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cobtit/manter_rotina.php',
        data: {
            nmarquiv: nmarquiv,
            flgreimp: flgreimp,
            operacao: 'IMPORTAR_ARQUIVO',
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


function confirmaGerarArquivoParceiro() {
  if (glbIdarquivo == 0) {
    showError('error', 'Nenhuma Remessa Selecionada.', 'Alerta - Ayllos', "unblockBackground()");
    return false;
  }
  if (glbInsitarq.toUpperCase() != 'PROCESSADO') {
    showError('error', 'N&atilde;o permitido Gera&ccedil;&atilde;o de Arquivo para Remessa Pendente.', 'Alerta - Ayllos', "unblockBackground()");
    return false;
  }
  showConfirmacao('Deseja efetuar nova gera&ccedil;&atilde;o do arquivo BPC_CECRED_' + lpad(glbIdarquivo, 6) + '.csv para empresa parceira?', 'Confirma&ccedil;&atilde;o - Ayllos', 'gera_arquivo_parceiro();',
                  'showError("inform", "Opera&ccedil;&atilde;o Cancelada.", "Alerta - Ayllos", "unblockBackground()");', 'sim.gif', 'nao.gif');
  return false;
}

function gera_arquivo_parceiro() {
  showMsgAguardo('Aguarde, carregando rotina para gera&ccedil;&atilde;o de arquivo...');
 // Executa script através de ajax
  $.ajax({
      type: 'POST',
      dataType: 'html',
      url: UrlSite + 'telas/cobtit/gerar_arquivo_parceiro.php',
      data: {
          idarquivo: glbIdarquivo,
          redirect: 'html_ajax'
      },
      error: function(objAjax, responseError, objExcept) {
          hideMsgAguardo();
          showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground()");
      },
      success: function(response) {
          hideMsgAguardo();
          eval(response);
      }
  });
  return false;
}

function confirmaGerarBoleto() {
  if (glbIdarquivo == 0) {
    showError('error', 'Nenhuma Remessa Selecionada.', 'Alerta - Ayllos', "unblockBackground()");
    return false;
  }
  if (glbInsitarq.toUpperCase() == 'PROCESSADO') {
    showError('error', 'N&atilde;o permitido Gera&ccedil;&atilde;o de Boletos para Remessa j&aacute; Processada.', 'Alerta - Ayllos', "");
    return false;
  }
  showConfirmacao('Deseja gerar boletos?', 'Confirma&ccedil;&atilde;o - Ayllos', 'gera_boletos();', '', 'sim.gif', 'nao.gif');
  return false;
}

function gera_boletos() {
  showMsgAguardo('Aguarde, carregando rotina para gera&ccedil;&atilde;o de boletos...');
  // Executa script através de ajax
  $.ajax({
      type: 'POST',
      dataType: 'html',
      url: UrlSite + 'telas/cobtit/gerar_boletos.php',
      data: {
          idarquivo: glbIdarquivo,
          redirect: 'html_ajax'
      },
      error: function(objAjax, responseError, objExcept) {
          hideMsgAguardo();
          showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground()");
      },
      success: function(response) {
          hideMsgAguardo();
          eval(response);
      }
  });
  return false;
}

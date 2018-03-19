/*!
 * FONTE        : cadpcp.js
 * CRIAÇÃO      : Luis Fernando (GFT) 
 * DATA CRIAÇÃO : 15/03/2018
 * OBJETIVO     : Biblioteca de funções da tela CADPCP
 * --------------
 * ALTERAÇÕES   :
 * --------------
 *
 */

//Formulários e Tabela
var frmCab = 'frmCab';
var frmOpcao = 'frmOpcao';

var cddopcao = 'C';

var nrJanelas = 0;
var nriniseq = 1;
var nrregist = 50;

var cTodosOpcao;
var cNrdconta;
var cNmprimtl;
var cNrinssac;
var cNmdsacad;
var cVlpercen;
var btLupaConta;
var btLupaPagador;

$(document).ready(function() {
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

    $('#' + frmOpcao).remove();
    $('#divBotoes').remove();
    $('#divPesquisaRodape', '#divTela').remove();

    cCddopcao.val('C');
    cCddopcao.focus();

    removeOpacidade('divTela');
}


// controla
function controlaOperacao(operacao, nriniseq, nrregist) {

    var nrdconta = normalizaNumero($('#nrdconta', '#' + frmOpcao).val());
    var mensagem = 'Aguarde, buscando dados ...';
    showMsgAguardo(mensagem);

    cTodosOpcao.removeClass('campoErro');

    // Carrega dados da conta através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cadpcp/principal.php',
        data:
                {
                    operacao: operacao,
                    cddopcao: cddopcao,
                    redirect: 'script_ajax'
                },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response) {
            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    hideMsgAguardo();
                    $('#divTela').html(response);
                    return false;
                } catch (error) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground()');
                }
            } else {
                try {
                    hideMsgAguardo();
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


// opcao
function buscaOpcao() {

    showMsgAguardo('Aguarde, buscando dados ...');
    // Executa script de confirmação através de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/cadpcp/form_opcao_' + cddopcao.toLowerCase() + '.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Não foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', "unblockBackground()");
        },
        success: function(response) {
            $('#divTela').html(response);

            formataCabecalho();

            cCddopcao.desabilitaCampo();
            cCddopcao.val(cddopcao);

            // limpa formulario
            cTodosOpcao = $('input[type="text"],input[type="checkbox"], select', '#' + frmOpcao);
            cTodosOpcao.limpaFormulario().removeClass('campoErro');
            $('#divPesquisaRodape', '#divTela').remove();

            formataOpcao();
            hideMsgAguardo();
            return false;
        }
    });

    return false;

}

function mostraPesquisaPagador(){
    procedure = 'CADPCP_PESQUISA_PAGADORES';
    titulo = 'Pagador';
    qtReg = '30';
    filtros = ';nrinssac;;N;;N;;|Nome do Pagador;nmdsacad;280;S;;S;;|Conta;nrdconta;;N;' + normalizaNumero(cNrdconta.val()) + ';N;;|;vlpercen;;N;;N;;';
    colunas = 'CPF/CNPJ;nrinssac;30%;center|Nome;nmdsacad;80%;left;|;nrdconta;;;;N|;vlpercen;;;;N';
    mostraPesquisa('TELA_CADPCP', procedure, titulo, qtReg, filtros, colunas, frmOpcao, 'montaPagador();');
    // $('#formPesquisa').css('display', 'none');
    return false;
}

function montaPagador(){
    if(cNrinssac.val()!=''){
        cNrdconta.blur();
        cNrinssac.desabilitaCampo().desabilitaCampo();
        btnContinuar();
    }
    else{
        cNrinssac.val('').focus();
    }
}

function formataOpcao() {

    highlightObjFocus($('#' + frmOpcao));
    if(cddopcao=='C'){
        formataOpcaoC();
    }
    else if(cddopcao=='A'){
        formataOpcaoA();
    }
    return false;
}

function controlaOpcao() {
    if (cddopcao == 'C') {
        if(isHabilitado(cNrdconta)){
            $('#' + frmOpcao + ' #divPagador').show();
            cNrinssac.habilitaCampo().focus();
            cNrdconta.desabilitaCampo();
        }
        else if(isHabilitado(cNrinssac)){
            montaPagador();
        }
    }
    else if (cddopcao == 'A') {
        if(isHabilitado(cNrdconta)){
            $('#' + frmOpcao + ' #divPagador').show();
            cNrinssac.habilitaCampo().focus();
            cNrdconta.desabilitaCampo();
        }
        else if(isHabilitado(cNrinssac)){
            montaPagador();
        }
    }
}


// associado

// cabecalho
function formataCabecalho() {

    // Label
    rCddopcao = $('label[for="cddopcao"]', '#' + frmCab);
    rCddopcao.css({'width': '50px'}).addClass('rotulo');

    // Input
    cCddopcao = $('#cddopcao', '#' + frmCab);
    cCddopcao.css({'width': '800px'});

    // Outros	
    cTodosCabecalho = $('input[type="text"], select', '#' + frmCab);
    btnOK1 = $('#btnOk1', '#' + frmCab);
    cTodosCabecalho.habilitaCampo();

    // Se clicar no botao OK
    btnOK1.unbind('click').bind('click', function() {

        if (divError.css('display') == 'block') {
            return false;
        }
        if (cCddopcao.hasClass('campoTelaSemBorda')) {
            return false;
        }

        trocaBotao('Prosseguir');

        //
        cCddopcao.desabilitaCampo();
        cddopcao = cCddopcao.val();

        //		
        buscaOpcao();
        return false;

    });


    // 
    cCddopcao.unbind('keydown').bind('keydown', function(e) {
        if (divError.css('display') == 'block') {
            return false;
        }

        // Se é a tecla ENTER
        if (e.keyCode == 13) {
            btnOK1.click();
            return false;
        }

    });
    layoutPadrao();
    // controlaPesquisas();
    return false;
}

/*Busca conta do associado*/
function buscaConta() {
    showMsgAguardo('Aguarde, buscando dados da Conta...');  
    
    nrdconta = normalizaNumero(cNrdconta.val());
            
    $.ajax({        
        type    : 'POST',
        dataType: 'html',
        url     : UrlSite + 'telas/cadpcp/manter_rotina.php', 
        data    : { 
                    operacao: 'BA',
                    nrdconta: nrdconta,   
                    frmOpcao: frmOpcao,
                    redirect: 'script_ajax'

                },
        error   : function(objAjax,responseError,objExcept) {
                    hideMsgAguardo();
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#nrdconta\',\'#frmCab\').focus();');
                },
        success : function(response) { 
                    hideMsgAguardo();
                    eval(response);
                }
    }); 
}

/*Busca pagador da conta*/
function buscaPagador() {
    showMsgAguardo('Aguarde, buscando dados da Conta...');  
    
    nrdconta = normalizaNumero(cNrdconta.val());
    nrinssac = normalizaNumero(cNrinssac.val());
            
    $.ajax({        
        type    : 'POST',
        dataType: 'html',
        url     : UrlSite + 'telas/cadpcp/manter_rotina.php', 
        data    : { 
                    operacao: 'BP',
                    nrdconta: nrdconta,   
                    nrinssac: nrinssac,   
                    frmOpcao: frmOpcao,
                    redirect: 'script_ajax'

                },
        error   : function(objAjax,responseError,objExcept) {
                    hideMsgAguardo();
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#nrinssac\',\''+frmOpcao+'\').focus();');
                },
        success : function(response) { 
                    hideMsgAguardo();
                    eval(response);
                }
    }); 
}

function salvaPagador() {
    showMsgAguardo('Aguarde, buscando dados da Conta...');  
    
    var nrdconta = normalizaNumero(cNrdconta.val());
    var nrinssac = normalizaNumero(cNrinssac.val());
    var vlpercen = normalizaNumero(cVlpercen.val());
            
    $.ajax({        
        type    : 'POST',
        dataType: 'html',
        url     : UrlSite + 'telas/cadpcp/manter_rotina.php', 
        data    : { 
                    operacao: 'AP',
                    nrdconta: nrdconta,   
                    nrinssac: nrinssac,   
                    vlpercen: vlpercen,   
                    frmOpcao: frmOpcao,
                    redirect: 'script_ajax'

                },
        error   : function(objAjax,responseError,objExcept) {
                    hideMsgAguardo();
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','$(\'#vlpercen\',\''+frmOpcao+'\').focus();');
                },
        success : function(response) { 
                    hideMsgAguardo();
                    eval(response);
                }
    }); 
}

// opcao A
function formataOpcaoA() {
    $('#' + frmOpcao + ' #divPagador').hide();
    $('#' + frmOpcao + ' #divPagador #divPorcentagem').hide();

    // // label
    rNrdconta = $('label[for="nrdconta"]', '#' + frmOpcao);
    rNmprimtl = $('label[for="nmprimtl"]', '#' + frmOpcao);
    rNrinssac = $('label[for="nrinssac"]', '#' + frmOpcao);
    rNmdsacad = $('label[for="nmdsacad"]', '#' + frmOpcao);
    rVlpercen = $('label[for="vlpercen"]', '#' + frmOpcao);

    rNrdconta.css({'width': '108px'}).addClass('rotulo');
    rNmprimtl.css({'width': '108px'}).addClass('rotulo-linha');
    rNrinssac.css({'width': '108px'}).addClass('rotulo');
    rNmdsacad.css({'width': '108px'}).addClass('rotulo-linha');
    rVlpercen.css({'width': '108px'}).addClass('rotulo');

    // // input
    cNrdconta = $('#nrdconta', '#' + frmOpcao);
    cNmprimtl = $('#nmprimtl', '#' + frmOpcao);
    cNrinssac = $('#nrinssac', '#' + frmOpcao);
    cNmdsacad = $('#nmdsacad', '#' + frmOpcao);
    cVlpercen = $('#vlpercen', '#' + frmOpcao);

    cNrdconta.css({'width': '75px'}).addClass('pesquisa conta');
    cNmprimtl.css({'width': '480px'});
    cNrinssac.css({'width': '109px'}).addClass('inteiro').attr('maxlength', '14')
    cNmdsacad.css({'width': '480px'});
    cVlpercen.css({'width': '55px'}).addClass('inteiro').attr('maxlength', '4');

    // Outros   
    cTodosOpcao.desabilitaCampo();
    cNrdconta.habilitaCampo().focus();
    cNrdconta.unbind('keypress').bind('keypress', function(e) {
        if (cNrdconta.hasClass('campoTelaSemBorda')) return false;
        if ((e.keyCode == 9 || e.keyCode == 13)) {
            btnContinuar();
            return false;
        }
    });

    $('#btnOK1','#'+frmOpcao).unbind('click').bind('click', function(e) {
        if (cNrdconta.hasClass('campoTelaSemBorda')) return false;
        btnContinuar();
        return false;
    });

    btLupaConta  = $('#btLupaConta','#'+frmOpcao);
    btLupaConta.css('cursor', 'pointer').unbind('click').bind('click', function () {
        if (!isHabilitado(cNrdconta)) return false;
        mostraPesquisaAssociado('nrdconta',frmOpcao);
        return false;
     });    

    btLupaPagador = $('#btLupaPagador','#'+frmOpcao);
    btLupaPagador.css('cursor', 'pointer').unbind('click').bind('click', function () {
        if (!isHabilitado(cNrinssac)) return false;
        mostraPesquisaPagador();
        return false;
     });

    cNrinssac.unbind('keypress').unbind('blur').bind('blur keypress', function(e) {
        if (cNrinssac.hasClass('campoTelaSemBorda')) return false;
        if ((e.keyCode == 9 || e.keyCode == 13)) {
            btnContinuar();
            return false;
        }
    });
    
    cVlpercen.unbind('keypress').unbind('blur').bind('blur keypress', function(e) {
        if (cVlpercen.hasClass('campoTelaSemBorda')) return false;
        if ((e.keyCode == 9 || e.keyCode == 13)) {
            btnContinuar();
            return false;
        }
    });
    layoutPadrao();
    return false;

}

// opcao C
function formataOpcaoC() {
    $('#' + frmOpcao + ' #divPagador').hide();
    $('#' + frmOpcao + ' #divPagador #divPorcentagem').hide();

    // // label
    rNrdconta = $('label[for="nrdconta"]', '#' + frmOpcao);
    rNmprimtl = $('label[for="nmprimtl"]', '#' + frmOpcao);
    rNrinssac = $('label[for="nrinssac"]', '#' + frmOpcao);
    rNmdsacad = $('label[for="nmdsacad"]', '#' + frmOpcao);
    rVlpercen = $('label[for="vlpercen"]', '#' + frmOpcao);

    rNrdconta.css({'width': '108px'}).addClass('rotulo');
    rNmprimtl.css({'width': '108px'}).addClass('rotulo-linha');
    rNrinssac.css({'width': '108px'}).addClass('rotulo');
    rNmdsacad.css({'width': '108px'}).addClass('rotulo-linha');
    rVlpercen.css({'width': '108px'}).addClass('rotulo');

    // // input
    cNrdconta = $('#nrdconta', '#' + frmOpcao);
    cNmprimtl = $('#nmprimtl', '#' + frmOpcao);
    cNrinssac = $('#nrinssac', '#' + frmOpcao);
    cNmdsacad = $('#nmdsacad', '#' + frmOpcao);
    cVlpercen = $('#vlpercen', '#' + frmOpcao);

    cNrdconta.css({'width': '75px'}).addClass('pesquisa conta');
    cNmprimtl.css({'width': '480px'});
    cNrinssac.css({'width': '109px'}).addClass('inteiro').attr('maxlength', '14')
    cNmdsacad.css({'width': '480px'});
    cVlpercen.css({'width': '55px'}).addClass('inteiro').attr('maxlength', '4');

    // Outros   
    cTodosOpcao.desabilitaCampo();
    cNrdconta.habilitaCampo().focus();
    cNrdconta.unbind('keypress').bind('keypress', function(e) {
        if (cNrdconta.hasClass('campoTelaSemBorda')) return false;
        if ((e.keyCode == 9 || e.keyCode == 13)) {
            btnContinuar();
            return false;
        }
    });

    $('#btnOK1','#'+frmOpcao).unbind('click').bind('click', function(e) {
        if (cNrdconta.hasClass('campoTelaSemBorda')) return false;
        btnContinuar();
        return false;
    });

    btLupaConta  = $('#btLupaConta','#'+frmOpcao);
    btLupaConta.css('cursor', 'pointer').unbind('click').bind('click', function () {
        if (!isHabilitado(cNrdconta)) return false;
        mostraPesquisaAssociado('nrdconta',frmOpcao);
        return false;
     });    

    btLupaPagador = $('#btLupaPagador','#'+frmOpcao);
    btLupaPagador.css('cursor', 'pointer').unbind('click').bind('click', function () {
        if (!isHabilitado(cNrinssac)) return false;
        mostraPesquisaPagador();
        return false;
     });

    cNrinssac.unbind('keypress').unbind('blur').bind('blur keypress', function(e) {
        if (cNrinssac.hasClass('campoTelaSemBorda')) return false;
        if ((e.keyCode == 9 || e.keyCode == 13)) {
            btnContinuar();
            return false;
        }
    });
    layoutPadrao();
    return false;

}


function validaCampo(campo, valor) {

    // conta
    if (campo == 'nrdconta' && !validaNroConta(valor)) {
        showError('error', 'Dígito errado.', 'Alerta - Ayllos', '$(\'#' + campo + '\',\'#frmOpcao\').select();');
        return false;
    }

    return true;
}


// botoes
function btnVoltar() {
    if (cddopcao == 'C'){
        if(isHabilitado(cNrdconta)) {
            estadoInicial();
        } else if (isHabilitado(cNrinssac)) {
            cNrdconta.habilitaCampo().focus();
            $('#' + frmOpcao + ' #divPagador').hide();
            cNrinssac.val('').desabilitaCampo();
        } else if (!isHabilitado(cNrinssac)){
            $('#' + frmOpcao + ' #divPagador #divPorcentagem').hide();
            cNrinssac.habilitaCampo().val('').focus();
            cNmdsacad.val('');
            cVlpercen.val('').desabilitaCampo();
        }
    }
    else if (cddopcao == 'A'){
        if(isHabilitado(cNrdconta)) {
            estadoInicial();
        } else if (isHabilitado(cNrinssac)) {
            cNrdconta.habilitaCampo().focus();
            $('#' + frmOpcao + ' #divPagador').hide();
            cNrinssac.val('').desabilitaCampo();
        } else if (!isHabilitado(cNrinssac)){
            $('#' + frmOpcao + ' #divPagador #divPorcentagem').hide();
            cNrinssac.habilitaCampo().val('').focus();
            cNmdsacad.val('');
            cVlpercen.val('').desabilitaCampo();
        }

    } else {
        estadoInicial();
    }


    return false;
}

function btnContinuar() {

    if (divError.css('display') == 'block') {
        return false;
    }
    
    var mensagem = 'Aguarde, buscando dados ...';
    showMsgAguardo(mensagem);

    if(cddopcao == 'C'){
        if (isHabilitado(cNrdconta)) {
            buscaConta();
        }
        else if (isHabilitado(cNrinssac)){
            hideMsgAguardo();
            if(cNrinssac.val()!='' && cNmdsacad.val()=='' && cVlpercen.val()==''){
                buscaPagador();
            }
        }
        else{
            hideMsgAguardo();
            $('#' + frmOpcao + ' #divPagador #divPorcentagem').show();
            cNrinssac.desabilitaCampo().desabilitaCampo();
            trocaBotao('');
        }
    }
    else if(cddopcao == 'A'){
        if (isHabilitado(cNrdconta)) {
            buscaConta();
        }
        else if (isHabilitado(cNrinssac)){
            hideMsgAguardo();
            if(cNrinssac.val()!='' && cNmdsacad.val()=='' && cVlpercen.val()==''){
                buscaPagador();
            }
        }
        else if(isHabilitado(cVlpercen)){
            hideMsgAguardo();
            showConfirmacao('Deseja alterar o percentual?','Confirma&ccedil;&atilde;o - Ayllos','salvaPagador();','return false;','sim.gif','nao.gif');    
        }
        else {
            hideMsgAguardo();
            $('#' + frmOpcao + ' #divPagador #divPorcentagem').show();
            cNrinssac.desabilitaCampo().desabilitaCampo();
            cVlpercen.habilitaCampo().select();
        }
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

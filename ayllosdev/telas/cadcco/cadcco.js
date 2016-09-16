/***********************************************************************
 Fonte: cadcco.js                                                  
 Autor: Jonathan - RKAM
 Data : Marco/2016                Última Alteração:  
                                                                   
 Objetivo  : Cadastro de servicos ofertados na tela CADCCO
                                                                   	 
 Alterações: 
						  
						  
************************************************************************/

var exisbole = 0;
var tarifa = new Object();
var motivo = new Object();


$(document).ready(function () {

    estadoInicial();

});

function estadoInicial() {

    formataCabecalho();

    //Inicializa o array
    tarifa = new Object();

    $('#cddopcao', '#frmCabCadcco').habilitaCampo().focus().val('C');
    $('#frmFiltro').css('display', 'none');
    $('#divBotoesFiltro').css('display', 'none');
    $('#frmCadcco').css('display', 'none');
    $('#divCadcco').html('').css('display', 'none');
    $('#divTarifas').html('');

    layoutPadrao();

}

function formataCabecalho() {

    $('label[for="cddopcao"]', '#frmCabCadcco').css('width', '50px').addClass('rotulo');
    $('#cddopcao', '#frmCabCadcco').css('width', '520px');
    $('#divTela').fadeTo(0, 0.1);
    removeOpacidade('divTela');
    $('#frmCabCadcco').css('display', 'block');

    highlightObjFocus($('#frmCabCadcco'));
    $('#cddopcao', '#frmCabCadcco').focus();

    //Ao pressionar botao cddopcao
    $('#cddopcao', '#frmCabCadcco').unbind('keypress').bind('keypress', function (e) {

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $('#btOK', '#frmCabCadcco').click();
            return false;
        }

    });

    //Ao clicar no botao OK
    $('#btOK', '#frmCabCadcco').unbind('click').bind('click', function () {

        $('input,select').removeClass('campoErro');
        $('#cddopcao', '#frmCabCadcco').desabilitaCampo();

        formataFiltro();

    });

    //Ao pressionar botao OK
    $('#btOK', '#frmCabCadcco').unbind('keypress').bind('keypress', function (e) {

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {


            $('input,select').removeClass('campoErro');
            $('#cddopcao', '#frmCabCadcco').desabilitaCampo();

            formataFiltro();

        }

    });

    return false;

}

function formataFiltro() {

    highlightObjFocus($('#frmFiltro'));

    //Label dos campos
    rNrconven = $('label[for="nrconven"]', '#frmFiltro');

    rNrconven.css('width', '100px');

    //Campos 
    cNrconven = $('#nrconven', '#frmFiltro');

    cNrconven.css({ 'width': '100px', 'text-align': 'right' }).addClass('inteiro').attr('maxlength', '10').habilitaCampo().val('');
    cNrconven.setMask("INTEGER", "zzzzz.zz9", ".", "");

    $('#frmFiltro').css('display', 'block');
    $('#divBotoesFiltro').css('display', 'block');

    //Ao pressionar botao nrconven
    $('#nrconven', '#frmFiltro').unbind('keypress').bind('keypress', function (e) {

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $('#btProsseguir', '#divBotoesFiltro').click();
            return false;
        }

    });

    layoutPadrao();

    cNrconven.focus();

    return false;

}


function formataMotivo() {

    highlightObjFocus($('#frmMotivo'));

    //Label dos campos
    rCdmotivo = $('label[for="cdmotivo"]', '#frmMotivo');
    rDsmotivo = $('label[for="dsmotivo"]', '#frmMotivo');
    rVltarifa = $('label[for="vltarifa"]', '#frmMotivo');
    rCdtarhis = $('label[for="cdtarhis"]', '#frmMotivo');

    rCdmotivo.css('width', '100px').addClass('rotulo');
    rDsmotivo.css('width', '100px').addClass('rotulo');
    rVltarifa.css('width', '100px').addClass('rotulo');
    rCdtarhis.css('width', '100px').addClass('rotulo-linha');

    //Campos 
    cCdmotivo = $('#cdmotivo', '#frmMotivo');
    cDsmotivo = $('#dsmotivo', '#frmMotivo');
    cVltarifa = $('#vltarifa', '#frmMotivo');
    cCdtarhis = $('#cdtarhis', '#frmMotivo');

    cCdmotivo.css('width', '80px').addClass('inteiro').attr('maxlength', '4');
    cDsmotivo.css('width', '345px').addClass('alphanum').attr('maxlength', '38');
    cCdtarhis.css('width', '80px').addClass('inteiro').attr('maxlength', '4');

    $('#frmMotivo').css('display', 'block');
    $('#divBotoesMotivo').css('display', 'block');

    layoutPadrao();

    if ($('#cddopcao', '#frmCabCadcco') == 'C') {

        $('input', '#frmMotivo').desabilitaCampo();
        $('#btVoltar', '#divBotoesMotivo').focus();

    } else {

        $('input', '#frmMotivo').desabilitaCampo();
        cCdmotivo.focus();

    }

    return false;

}

function controlaPesquisa(valor) {

    switch (valor) {

        case 1:
            controlaPesquisaConvenio();
            break;

        case 2:
            controlaPesquisaBanco();
            break;

        case 3:
            controlaPesquisaHistorico();
            break;

        case 4:
            controlaPesquisaBancoCaixa();
            break;

        case 5:
            controlaPesquisaPA();
            break

        case 6:
            controlaPesquisaHistoricoCobranca();
            break;

        case 7:
            controlaPesquisaHistoricoCoop();
            break;

        case 8:
            controlaPesquisaHistoricoInternet();
            break;

        case 9:
            controlaPesquisaHistoricoTaa();
            break;

        case 10:
            controlaPesquisaHistoricoPreImpresso();
            break;

    }

}

function controlaPesquisaConvenio() {

    // Se esta desabilitado o campo 
    if ($("#nrconven", "#frmFiltro").prop("disabled") == true) {
        return;
    }

    /* Remove foco de erro */
    $('input', '#frmFiltro').removeClass('campoErro');

    // Variável local para guardar o elemento anterior
    var campoAnterior = '';
    var bo, procedure, titulo, qtReg, filtrosPesq, colunas;

    var nrconven = normalizaNumero($('#nrconven', '#frmFiltro').val());

    //Definição dos filtros
    var filtros = "Convênios;nrconven;120px;S;;;";

    //Campos que serão exibidos na tela
    var colunas = 'Convênios;nrconven;15%;right|Conta Base;nrdctabb;15%;right|Banco;cddbanco;10%;right;|Situação;flgativo;10%;left;|Origem;dsorgarq;40%;left';

    //Exibir a pesquisa
    mostraPesquisa("zoom0001", "CONSPRMCNVCOB", "Conv&ecirc;nios", "30", filtros, colunas, '', '$(\'#nrconven\',\'#frmFiltro\').focus();', 'frmFiltro');

    $("#divCabecalhoPesquisa > table").css("width", "700px");
    $("#divResultadoPesquisa > table").css("width", "700px");
    $("#divCabecalhoPesquisa").css("width", "700px");
    $("#divResultadoPesquisa").css("width", "700px");
    $('#divPesquisa').centralizaRotinaH();

    return false;

}

//Consulta Banco
function controlaPesquisaBanco() {

    // Se esta desabilitado o campo 
    if ($("#cddbanco", "#frmCadcco").prop("disabled") == true) {
        return;
    }

    /* Remove foco de erro */
    $('input,select', '#frmCadcco').removeClass('campoErro');

    // Variável local para guardar o elemento anterior
    var campoAnterior = '';
    var bo, procedure, titulo, qtReg, filtrosPesq, colunas;

    //Definição dos filtros
    var filtros = 'Cód. Banco;cddbanco;30px;S;0;|Nome Banco;nmextbcc;200px;S;';

    //Campos que serão exibidos na tela
    var colunas = 'Código;cdbccxlt;20%;right|Banco;nmextbcc;80%;left';

    //Exibir a pesquisa
    mostraPesquisa("zoom0001", "CONSBANCOS", "Banco", "30", filtros, colunas, '', '$(\'#cddbanco\',\'#frmCadcco\').focus();', 'frmCadcco');

    return false;

}

// Consulta Histórico
function controlaPesquisaHistorico() {

    // Se esta desabilitado o campo 
    if ($("#cdhistor", "#frmCadcco").prop("disabled") == true) {
        return;
    }

    /* Remove foco de erro */
    $('input,select', '#frmCadcco').removeClass('campoErro');

    // Variável local para guardar o elemento anterior
    var campoAnterior = '';
    var bo, procedure, titulo, qtReg, filtrosPesq, colunas;

    //Definição dos filtros
    var filtros = 'Cód. Hist;cdhistor;30px;S;0;|Histórico;dshistor;200px;S;';

    //Campos que serão exibidos na tela
    var colunas = 'Código;cdhistor;20%;right|Histórico;dshistor;80%;left';

    //Exibir a pesquisa
    mostraPesquisa("zoom0001", "CONSHISTORICOS", "Histórico", "30", filtros, colunas, '', '$(\'#cdhistor\',\'#frmCadcco\').focus();', 'frmCadcco');

    return false;

}

// Consulta Banco Caixa
function controlaPesquisaBancoCaixa() {

    // Se esta desabilitado o campo 
    if ($("#cdbccxlt", "#frmCadcco").prop("disabled") == true) {
        return;
    }

    /* Remove foco de erro */
    $('input,select', '#frmCadcco').removeClass('campoErro');

    // Variável local para guardar o elemento anterior
    var campoAnterior = '';
    var bo, procedure, titulo, qtReg, filtrosPesq, colunas;

    //Definição dos filtros
    var filtros = 'Cód. Hist;cdbccxlt;30px;S;0;|Histórico;nmbcolot;200px;S;';

    //Campos que serão exibidos na tela
    var colunas = 'Código;cdbccxlt;20%;right|Histórico;nmextbcc;80%;left';

    //Exibir a pesquisa
    mostraPesquisa("zoom0001", "CONSBANCOCAIXA", "Banco Caixa", "30", filtros, colunas, '', '$(\'#cdbccxlt\',\'#frmCadcco\').focus();', 'frmCadcco');

    return false;

}

// Consulta PA
function controlaPesquisaPA() {

    // Se esta desabilitado o campo 
    if ($("#cdagenci", "#frmCadcco").prop("disabled") == true) {
        return;
    }

    /* Remove foco de erro */
    $('input,select', '#frmCadcco').removeClass('campoErro');

    // Variável local para guardar o elemento anterior
    var campoAnterior = '';

    //Definição dos filtros
    var filtros = 'Cód. PA;cdagenci;30px;S;0;;codigo;|Agência PA;nmresage;200px;S;;;descricao;';

    //Campos que serão exibidos na tela
    var colunas = 'Código;cdagepac;20%;right|Histórico;dsagepac;80%;left';

    //Exibir a pesquisa
    mostraPesquisa("b1wgen0059.p", "busca_pac", "Agência PA", "30", filtros, colunas, '', '$(\'#cdagenci\',\'#frmCadcco\').focus();', 'frmCadcco');

    return false;

}

// Consulta Histórico Cobrança
function controlaPesquisaHistoricoCobranca() {

    // Se esta desabilitado o campo 
    if ($("#cdtarhis", "#frmCadcco").prop("disabled") == true) {
        return;
    }

    /* Remove foco de erro */
    $('input,select', '#frmCadcco').removeClass('campoErro');

    // Variável local para guardar o elemento anterior
    var campoAnterior = '';
    var bo, procedure, titulo, qtReg, filtrosPesq, colunas;

    //Definição dos filtros
    var filtros = 'Cód. Hist;cdtarhis;30px;S;0;|Histórico;dshistor;200px;S;';

    //Campos que serão exibidos na tela
    var colunas = 'Código;cdhistor;20%;right|Histórico;dshistor;80%;left';

    //Exibir a pesquisa
    mostraPesquisa("zoom0001", "CONSHISTORICOS", "Histórico", "30", filtros, colunas, '', '$(\'#cdtarhis\',\'#frmCadcco\').focus();', 'frmCadcco');

    return false;

}

// Consulta Histórico Cooperativa
function controlaPesquisaHistoricoCoop() {

    // Se esta desabilitado o campo 
    if ($("#cdhiscxa", "#frmCadcco").prop("disabled") == true) {
        return;
    }

    /* Remove foco de erro */
    $('input,select', '#frmCadcco').removeClass('campoErro');

    // Variável local para guardar o elemento anterior
    var campoAnterior = '';
    var bo, procedure, titulo, qtReg, filtrosPesq, colunas;

    //Definição dos filtros
    var filtros = 'Cód. Hist;cdhiscxa;30px;S;0;|Histórico;dshistor;200px;S;';

    //Campos que serão exibidos na tela
    var colunas = 'Código;cdhistor;20%;right|Histórico;dshistor;80%;left';

    //Exibir a pesquisa
    mostraPesquisa("zoom0001", "CONSHISTORICOS", "Histórico", "30", filtros, colunas, '', '$(\'#cdhiscxa\',\'#frmCadcco\').focus();', 'frmCadcco');

    return false;

}

// Consulta Histórico Internet
function controlaPesquisaHistoricoInternet() {

    // Se esta desabilitado o campo 
    if ($("#cdhisnet", "#frmCadcco").prop("disabled") == true) {
        return;
    }

    /* Remove foco de erro */
    $('input,select', '#frmCadcco').removeClass('campoErro');

    // Variável local para guardar o elemento anterior
    var campoAnterior = '';
    var bo, procedure, titulo, qtReg, filtrosPesq, colunas;

    //Definição dos filtros
    var filtros = 'Cód. Hist;cdhisnet;30px;S;0;|Histórico;dshistor;200px;S;';

    //Campos que serão exibidos na tela
    var colunas = 'Código;cdhistor;20%;right|Histórico;dshistor;80%;left';

    //Exibir a pesquisa
    mostraPesquisa("zoom0001", "CONSHISTORICOS", "Histórico", "30", filtros, colunas, '', '$(\'#cdhisnet\',\'#frmCadcco\').focus();', 'frmCadcco');

    return false;

}

// Consulta Histórico TAA
function controlaPesquisaHistoricoTaa() {

    // Se esta desabilitado o campo 
    if ($("#cdhistaa", "#frmCadcco").prop("disabled") == true) {
        return;
    }

    /* Remove foco de erro */
    $('input,select', '#frmCadcco').removeClass('campoErro');

    // Variável local para guardar o elemento anterior
    var campoAnterior = '';
    var bo, procedure, titulo, qtReg, filtrosPesq, colunas;

    //Definição dos filtros
    var filtros = 'Cód. Hist;cdhistaa;30px;S;0;|Histórico;dshistor;200px;S;';

    //Campos que serão exibidos na tela
    var colunas = 'Código;cdhistor;20%;right|Histórico;dshistor;80%;left';

    //Exibir a pesquisa
    mostraPesquisa("zoom0001", "CONSHISTORICOS", "Histórico", "30", filtros, colunas, '', '$(\'#cdhistaa\',\'#frmCadcco\').focus();', 'frmCadcco');

    return false;

}

// Consulta Histórico Pre-Impresso
function controlaPesquisaHistoricoPreImpresso() {

    // Se esta desabilitado o campo 
    if ($("#cdhisblq", "#frmCadcco").prop("disabled") == true) {
        return;
    }

    /* Remove foco de erro */
    $('input,select', '#frmCadcco').removeClass('campoErro');

    // Variável local para guardar o elemento anterior
    var campoAnterior = '';
    var bo, procedure, titulo, qtReg, filtrosPesq, colunas;

    //Definição dos filtros
    var filtros = 'Cód. Hist;cdhisblq;30px;S;0;|Histórico;dshistor;200px;S;';

    //Campos que serão exibidos na tela
    var colunas = 'Código;cdhistor;20%;right|Histórico;dshistor;80%;left';

    //Exibir a pesquisa
    mostraPesquisa("zoom0001", "CONSHISTORICOS", "Histórico", "30", filtros, colunas, '', '$(\'#cdhisblq\',\'#frmCadcco\').focus();', 'frmCadcco');

    return false;

}

function controlaVoltar(tipo) {

    switch (tipo) {

        case '1':

            estadoInicial();

            break;

        case '2':

            $('#divCadcco').html('').css('display', 'none');
            $('#divTarifas').html('').css('display', 'none');
            formataFiltro();

            break;

    }

    return false;

}

function incluirConvenio() {

    var cddopcao = $('#cddopcao', '#frmCabCadcco').val();
    var nrconven = normalizaNumero($('#nrconven', '#frmFiltro').val());
    var cddbanco = $('#cddbanco', '#frmCadcco').val();
    var nrdctabb = normalizaNumero($('#nrdctabb', '#frmCadcco').val());
    var cdbccxlt = $('#cdbccxlt', '#frmCadcco').val();
    var cdagenci = $('#cdagenci', '#frmCadcco').val();
    var nrdolote = normalizaNumero($('#nrdolote', '#frmCadcco').val());
    var cdhistor = normalizaNumero($('#cdhistor', '#frmCadcco').val());
    var vlrtarif = isNaN(parseFloat($('#vlrtarif', '#frmCadcco').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vlrtarif', '#frmCadcco').val().replace(/\./g, "").replace(/\,/g, "."));
    var cdtarhis = normalizaNumero($('#cdtarhis', '#frmCadcco').val());
    var cdhiscxa = normalizaNumero($('#cdhiscxa', '#frmCadcco').val());
    var vlrtarcx = isNaN(parseFloat($('#vlrtarcx', '#frmCadcco').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vlrtarcx', '#frmCadcco').val().replace(/\./g, "").replace(/\,/g, "."));
    var cdhisnet = normalizaNumero($('#cdhisnet', '#frmCadcco').val());
    var vlrtarnt = isNaN(parseFloat($('#vlrtarnt', '#frmCadcco').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vlrtarnt', '#frmCadcco').val().replace(/\./g, "").replace(/\,/g, "."));
    var cdhistaa = normalizaNumero($('#cdhistaa', '#frmCadcco').val());
    var vltrftaa = isNaN(parseFloat($('#vltrftaa', '#frmCadcco').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vltrftaa', '#frmCadcco').val().replace(/\./g, "").replace(/\,/g, "."));
    var nrlotblq = normalizaNumero($('#nrlotblq', '#frmCadcco').val());
    var nrvarcar = $('#nrvarcar', '#frmCadcco').val();
    var cdcartei = $('#cdcartei', '#frmCadcco').val();
    var vlrtrblq = isNaN(parseFloat($('#vlrtrblq', '#frmCadcco').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vlrtrblq', '#frmCadcco').val().replace(/\./g, "").replace(/\,/g, "."));
    var cdhisblq = normalizaNumero($('#cdhisblq', '#frmCadcco').val());
    var nrbloque = normalizaNumero($('#nrbloque', '#frmCadcco').val());
    var dsorgarq = $('#dsorgarq', '#frmCadcco').val();
    var tamannro = $('#tamannro', '#frmCadcco').val();
    var nmdireto = $('#nmdireto', '#frmCadcco').val();
    var nmarquiv = $('#nmarquiv', '#frmCadcco').val();
    var flgutceb = $('#flgcnvcc', '#frmCadcco').val();
    var flcopcob = $('#flcopcob', '#frmCadcco').val();
    var flserasa = $('#flserasa', '#frmCadcco').val();
    var flgativo = $('#flgativo', '#frmCadcco').val();
    var flgregis = $('#flgregis', '#frmCadcco').val();
    var qtdfloat = $('#qtdfloat', '#frmCadcco').val();

    $('input,select', '#frmCadcco').removeClass('campoErro').desabilitaCampo();

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, incluindo conv&ecirc;nio...");

    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/cadcco/incluir_convenio.php",
        data: {
            cddopcao: cddopcao,
            nrconven: nrconven,
            cddbanco: cddbanco,
            nrdctabb: nrdctabb,
            cdbccxlt: cdbccxlt,
            cdagenci: cdagenci,
            nrdolote: nrdolote,
            cdhistor: cdhistor,
            vlrtarif: vlrtarif,
            cdtarhis: cdtarhis,
            cdhiscxa: cdhiscxa,
            vlrtarcx: vlrtarcx,
            cdhisnet: cdhisnet,
            vlrtarnt: vlrtarnt,
            cdhistaa: cdhistaa,
            vltrftaa: vltrftaa,
            nrlotblq: nrlotblq,
            nrvarcar: nrvarcar,
            cdcartei: cdcartei,
            vlrtrblq: vlrtrblq,
            cdhisblq: cdhisblq,
            nrbloque: nrbloque,
            dsorgarq: dsorgarq,
            tamannro: tamannro,
            nmdireto: nmdireto,
            nmarquiv: nmarquiv,
            flgutceb: flgutceb,
            flcopcob: flcopcob,
            flserasa: flserasa,
            flgativo: flgativo,
            flgregis: flgregis,
            qtdfloat: qtdfloat,
            redirect: "html_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '$("#btVoltar","#frmCadcco").focus();');
            }
        }
    });

    return false;
}

function alterarConvenio() {

    var cddopcao = $('#cddopcao', '#frmCabCadcco').val();
    var nrconven = normalizaNumero($('#nrconven', '#frmFiltro').val());
    var cddbanco = $('#cddbanco', '#frmCadcco').val();
    var nrdctabb = normalizaNumero($('#nrdctabb', '#frmCadcco').val());
    var cdbccxlt = $('#cdbccxlt', '#frmCadcco').val();
    var cdagenci = $('#cdagenci', '#frmCadcco').val();
    var nrdolote = normalizaNumero($('#nrdolote', '#frmCadcco').val());
    var cdhistor = normalizaNumero($('#cdhistor', '#frmCadcco').val());
    var vlrtarif = isNaN(parseFloat($('#vlrtarif', '#frmCadcco').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vlrtarif', '#frmCadcco').val().replace(/\./g, "").replace(/\,/g, "."));
    var cdtarhis = normalizaNumero($('#cdtarhis', '#frmCadcco').val());
    var cdhiscxa = normalizaNumero($('#cdhiscxa', '#frmCadcco').val());
    var vlrtarcx = isNaN(parseFloat($('#vlrtarcx', '#frmCadcco').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vlrtarcx', '#frmCadcco').val().replace(/\./g, "").replace(/\,/g, "."));
    var cdhisnet = normalizaNumero($('#cdhisnet', '#frmCadcco').val());
    var vlrtarnt = isNaN(parseFloat($('#vlrtarnt', '#frmCadcco').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vlrtarnt', '#frmCadcco').val().replace(/\./g, "").replace(/\,/g, "."));
    var cdhistaa = normalizaNumero($('#cdhistaa', '#frmCadcco').val());
    var vltrftaa = isNaN(parseFloat($('#vltrftaa', '#frmCadcco').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vltrftaa', '#frmCadcco').val().replace(/\./g, "").replace(/\,/g, "."));
    var nrlotblq = normalizaNumero($('#nrlotblq', '#frmCadcco').val());
    var nrvarcar = $('#nrvarcar', '#frmCadcco').val();
    var cdcartei = $('#cdcartei', '#frmCadcco').val();
    var vlrtrblq = isNaN(parseFloat($('#vlrtrblq', '#frmCadcco').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vlrtrblq', '#frmCadcco').val().replace(/\./g, "").replace(/\,/g, "."));
    var cdhisblq = normalizaNumero($('#cdhisblq', '#frmCadcco').val());
    var nrbloque = normalizaNumero($('#nrbloque', '#frmCadcco').val());
    var dsorgarq = $('#dsorgarq', '#frmCadcco').val();
    var tamannro = $('#tamannro', '#frmCadcco').val();
    var nmdireto = $('#nmdireto', '#frmCadcco').val();
    var nmarquiv = $('#nmarquiv', '#frmCadcco').val();
    var flgutceb = $('#flgcnvcc', '#frmCadcco').val();
    var flcopcob = $('#flcopcob', '#frmCadcco').val();
    var flserasa = $('#flserasa', '#frmCadcco').val();
    var flgativo = $('#flgativo', '#frmCadcco').val();
    var flgregis = $('#flgregis', '#frmCadcco').val();
    var qtdfloat = $('#qtdfloat', '#frmCadcco').val();

    $('input,select', '#frmCadcco').removeClass('campoErro').desabilitaCampo();

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, alterando conv&ecirc;nio...");

    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/cadcco/alterar_convenio.php",
        data: {
            cddopcao: cddopcao,
            nrconven: nrconven,
            cddbanco: cddbanco,
            nrdctabb: nrdctabb,
            cdbccxlt: cdbccxlt,
            cdagenci: cdagenci,
            nrdolote: nrdolote,
            cdhistor: cdhistor,
            vlrtarif: vlrtarif,
            cdtarhis: cdtarhis,
            cdhiscxa: cdhiscxa,
            vlrtarcx: vlrtarcx,
            cdhisnet: cdhisnet,
            vlrtarnt: vlrtarnt,
            cdhistaa: cdhistaa,
            vltrftaa: vltrftaa,
            nrlotblq: nrlotblq,
            nrvarcar: nrvarcar,
            cdcartei: cdcartei,
            vlrtrblq: vlrtrblq,
            cdhisblq: cdhisblq,
            nrbloque: nrbloque,
            dsorgarq: dsorgarq,
            tamannro: tamannro,
            nmdireto: nmdireto,
            nmarquiv: nmarquiv,
            flgutceb: flgutceb,
            flcopcob: flcopcob,
            flserasa: flserasa,
            flgativo: flgativo,
            flgregis: flgregis,
            qtdfloat: qtdfloat,
            redirect: "html_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '$("#btVoltar","#frmCadcco").focus();');
            }
        }
    });

    return false;
}

function consultaParametros() {

    $('input', '#frmFiltro').removeClass('campoErro').desabilitaCampo();

    showMsgAguardo("Aguarde, buscando informa&ccedil;&otilde;es...");

    var cddopcao = $('#cddopcao', '#frmCabCadcco').val();
    var nrconven = normalizaNumero($('#nrconven', '#frmFiltro').val());

    //Inicializa variável sempre que fizer a consulta
    exisbole = 0;

    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/cadcco/principal.php',
        data: {
            cddopcao: cddopcao,
            nrconven: nrconven,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'Nao foi possivel concluir a operacao.', 'Alerta - Ayllos', '$("#nrconven", "#frmFiltro").focus();');
        },
        success: function (response) {
            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {

                    $('#divCadcco').html(response);

                    return false;
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#nrconven','#frmFiltro').focus();");
                }
            } else {
                try {

                    eval(response);
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#nrconven','#frmFiltro').focus();");
                }
            }
        }
    });

    return false;

}

function atualizaArrayTarifa() {

    var divRegistro = $('div.divRegistros', '#frmTarifas');

    $('table > tbody > tr', divRegistro).each(function (i) {

        tarifa[$($(this)).attr('id')]["vltarifa"] = parseFloat($('#vltarifa', $(this)).val().replace(/\./g, "").replace(/\,/g, "."));
        tarifa[$($(this)).attr('id')]["cdtarhis"] = $('#cdtarhis', $(this)).val();

    });

    return false;

}

function atualizaArrayMotivo() {

    var divRegistro = $('div.divRegistros', '#frmMotivos');

    $('table > tbody > tr', divRegistro).each(function (i) {

        motivo[$($(this)).attr('id')]["vltarifa"] = parseFloat($('#vltarifa', $(this)).val().replace(/\./g, "").replace(/\,/g, "."));
        motivo[$($(this)).attr('id')]["cdtarhis"] = $('#cdtarhis', $(this)).val();

    });

    return false;

}

function buscaTarifas(nriniseq, nrregist, nrconven, cddbanco) {

    showMsgAguardo("Aguarde, buscando tarifas...");

    var cddopcao = $('#cddopcao', '#frmCabCadcco').val();

    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/cadcco/busca_tarifas.php',
        data: {
            cddopcao: cddopcao,
            nrconven: nrconven,
            cddbanco: cddbanco,
            nriniseq: nriniseq,
            nrregist: nrregist,
            redirect: 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "Nao foi possivel concluir a operacao.", "Alerta - Ayllos", "$('#btVoltar','#frmCadcco').focus();");
        },
        success: function (response) {
            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {

                    $('#divTarifas').html(response);

                    return false;
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#btVoltar','#frmCadcco').focus();");
                }
            } else {
                try {

                    eval(response);
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#btVoltar','#frmCadcco').focus();");
                }
            }
        }
    });

    return false;

}

function excluirConvenio() {

    var cddopcao = $('#cddopcao', '#frmCabCadcco').val();
    var nrconven = normalizaNumero($('#nrconven', '#frmFiltro').val());

    $('input,select', '#frmCadcco').removeClass('campoErro').desabilitaCampo();

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, excluindo conv&ecirc;nio...");

    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/cadcco/excluir_convenio.php",
        data: {
            cddopcao: cddopcao,
            nrconven: nrconven,
            redirect: "html_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '$("#btVoltar","#frmCadcco").focus();');
            }
        }
    });

    return false;

}

function controlaConcluirTarifa() {

    var divRegistro = $('div.divRegistros', '#frmTarifas');

    $('table > tbody > tr', divRegistro).each(function (i) {

        tarifa[$($(this)).attr('id')]["vltarifa"] = parseFloat($('#vltarifa', $(this)).val().replace(/\./g, "").replace(/\,/g, "."));
        tarifa[$($(this)).attr('id')]["cdtarhis"] = $('#cdtarhis', $(this)).val();

    });

    atualizaTarifa();

    return false;

}

function controlaConcluirMotivo() {

    var divRegistro = $('div.divRegistros', '#frmMotivos');

    $('table > tbody > tr', divRegistro).each(function (i) {

        motivo[$($(this)).attr('id')]["vltarifa"] = parseFloat($('#vltarifa', $(this)).val().replace(/\./g, "").replace(/\,/g, "."));
        motivo[$($(this)).attr('id')]["cdtarhis"] = $('#cdtarhis', $(this)).val();

    });

    atualizaMotivo();

    return false;

}

function atualizaMotivo() {

    var cddopcao = $('#cddopcao', '#frmCabCadcco').val();
    var nrconven = normalizaNumero($('#nrconven', '#frmFiltro').val());

    $('input,select', '#frmCadcco').removeClass('campoErro').desabilitaCampo();

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, gravando informa&ccedil;&otilde;s ...");

    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/cadcco/atualizar_motivo.php",
        data: {
            nrconven: nrconven,
            cddopcao: cddopcao,
            motivo: motivo,
            redirect: "html_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '$("#btVoltar","#frmCadcco").focus();');
            }
        }
    });

    return false;

}

function atualizaTarifa() {

    var cddopcao = $('#cddopcao', '#frmCabCadcco').val();
    var nrconven = normalizaNumero($('#nrconven', '#frmFiltro').val());

    $('input,select', '#frmCadcco').removeClass('campoErro').desabilitaCampo();

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, gravando informa&ccedil;&otilde;s ...");

    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/cadcco/atualiza_tarifa.php",
        data: {
            nrconven: nrconven,
            cddopcao: cddopcao,
            tarifa: tarifa,
            redirect: "html_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '$("#btVoltar","#frmCadcco").focus();');
            }
        }
    });

    return false;

}

function buscaMotivos(nriniseq, nrregist, cddbanco, cdocorre) {

    showMsgAguardo("Aguarde buscan motivos...");

    var cddopcao = $('#cddopcao', '#frmCabCadcco').val();
    var nrconven = normalizaNumero($('#nrconven', '#frmFiltro').val());

    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/cadcco/busca_motivos.php',
        data: {
            cddopcao: cddopcao,
            nrconven: nrconven,
            cddbanco: cddbanco,
            cdocorre: cdocorre,
            nriniseq: nriniseq,
            nrregist: nrregist,
            redirect: 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "Nao foi possivel concluir a operacao.", "Alerta - Ayllos", "$('#btVoltar','#frmCadcco').focus();");
        },
        success: function (response) {
            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {

                    $('#divRotina').html(response);

                    return false;
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#btVoltar','#frmCadcco').focus();");
                }
            } else {
                try {

                    eval(response);
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#btVoltar','#frmCadcco').focus();");
                }
            }
        }
    });

    return false;

}

function formataInformacoes() {

    $('input,select', '#frmCadcco').habilitaCampo();

    //Formata label Inf.Gerais
    var rFlgativo = $('label[for="flgativo"]', '#frmCadcco');
    var rDsorgarq = $('label[for="dsorgarq"]', '#frmCadcco');
    var rNrdctabb = $('label[for="nrdctabb"]', '#frmCadcco');
    var rFlgregis = $('label[for="flgregis"]', '#frmCadcco');
    var rCddbanco = $('label[for="cddbanco"]', '#frmCadcco');
    var rCdbccxlt = $('label[for="cdbccxlt"]', '#frmCadcco');
    var rCdagenci = $('label[for="cdagenci"]', '#frmCadcco');
    var rNrdolote = $('label[for="nrdolote"]', '#frmCadcco');
    var rCdhistor = $('label[for="cdhistor"]', '#frmCadcco');
    var rFlserasa = $('label[for="flserasa"]', '#frmCadcco');
    var rNmarquiv = $('label[for="nmarquiv"]', '#frmCadcco');
    var rFlcopcob = $('label[for="flcopcob"]', '#frmCadcco');
    var rTamannro = $('label[for="tamannro"]', '#frmCadcco');
    var rNmdireto = $('label[for="nmdireto"]', '#frmCadcco');
    var rQtdfloat = $('label[for="qtdfloat"]', '#frmCadcco');
    var rNrbloque = $('label[for="nrbloque"]', '#frmCadcco');
    var rFlgcnvcc = $('label[for="flgcnvcc"]', '#frmCadcco');

    rFlgativo.addClass('rotulo').css('width', '110px');
    rDsorgarq.addClass('rotulo-linha').css('width', '170px');
    rNrdctabb.addClass('rotulo').css('width', '110px');
    rFlgregis.addClass('rotulo-linha').css('width', '170px');
    rCddbanco.addClass('rotulo').css('width', '110px');
    rCdbccxlt.addClass('rotulo').css('width', '110px');
    rCdagenci.addClass('rotulo-linha').css('width', '30px');
    rNrdolote.addClass('rotulo-linha').css('width', '40px');
    rFlserasa.addClass('rotulo').css('width', '110px');
    rCdhistor.addClass('rotulo-linha').css('width', '120px');
    rNmarquiv.addClass('rotulo').css('width', '110px');
    rFlcopcob.addClass('rotulo-linha').css('width', '100px');
    rNmdireto.addClass('rotulo').css('width', '110px');
    rQtdfloat.addClass('rotulo-linha').css('width', '100px');
    rNrbloque.addClass('rotulo').css('width', '110px');
    rFlgcnvcc.addClass('rotulo-linha').css('width', '140px');
    rTamannro.addClass('rotulo-linha').css('width', '90px');

    //Formata Campos Inf. Gerais
    var cFlgativo = $('#flgativo', '#frmCadcco');
    var cDsorgarq = $('#dsorgarq', '#frmCadcco');
    var cNrdctabb = $('#nrdctabb', '#frmCadcco');
    var cCddbanco = $('#cddbanco', '#frmCadcco');
    var cNmextbcc = $('#nmextbcc', '#frmCadcco');
    var cCdbccxlt = $('#cdbccxlt', '#frmCadcco');
    var cCdagenci = $('#cdagenci', '#frmCadcco');
    var cNrdolote = $('#nrdolote', '#frmCadcco');
    var cCdhistor = $('#cdhistor', '#frmCadcco');
    var cFlserasa = $('#flserasa', '#frmCadcco');
    var cFlgregis = $('#flgregis', '#frmCadcco');
    var cNmarquiv = $('#nmarquiv', '#frmCadcco');
    var cFlcopcob = $('#flcopcob', '#frmCadcco');
    var cTamannro = $('#tamannro', '#frmCadcco');
    var cNmdireto = $('#nmdireto', '#frmCadcco');
    var cQtdfloat = $('#qtdfloat', '#frmCadcco');
    var cNrbloque = $('#nrbloque', '#frmCadcco');
    var cFlgcnvcc = $('#flgcnvcc', '#frmCadcco');

    cFlgativo.css('width', '135px');
    cDsorgarq.css('width', '170px');
    cNrdctabb.css('width', '135px').addClass('inteiro').attr('maxlength', '10').setMask("INTEGER", "zzzz.zzz.9", ".", "");
    cCddbanco.css('width', '55px').addClass('inteiro').attr('maxlength', '5').setMask("INTEGER", "z.zz9", ".", "");
    cNmextbcc.css('width', '405px').desabilitaCampo();
    cNrdolote.css('width', '65px').addClass('inteiro').attr('maxlength', '7').setMask("INTEGER", "zzz.zz9", ".", "");
    cNmarquiv.css('width', '315px').addClass('alphanum').attr('maxlength', '38');
    cNmdireto.css('width', '315px').addClass('alphanum').attr('maxlength', '76');
    cQtdfloat.css('width', '60px');
    cCdbccxlt.css('width', '55px').addClass('inteiro').attr('maxlength', '3');
    cCdagenci.css('width', '40px').addClass('inteiro').attr('maxlength', '3');
    cCdhistor.css('width', '50px').addClass('inteiro').attr('maxlength', '4');
    cFlserasa.css('width', '60px');
    cFlgregis.css('width', '60px');
    cFlcopcob.css('width', '60px');
    cNrbloque.css('width', '90px').addClass('inteiro').attr('maxlength', '11').setMask("INTEGER", "zzz.zzz.zz9", ".", "");
    cFlgcnvcc.css('width', '60px');
    cTamannro.css('width', '40px').addClass('inteiro').attr('maxlength', '2').setMask("INTEGER", "z9", ".", "");

    //Formata label tarifas
    var rCdcartei = $('label[for="cdcartei"]', '#frmCadcco');
    var rNrvarcar = $('label[for="nrvarcar"]', '#frmCadcco');
    var rNrlotblq = $('label[for="nrlotblq"]', '#frmCadcco');
    var rLblvalor = $('label[id="lblvalor"]', '#frmCadcco');
    var rLblhisto = $('label[id="lblhisto"]', '#frmCadcco');
    var rVlrtarif = $('label[for="vlrtarif"]', '#frmCadcco');
    var rVlrtarcx = $('label[for="vlrtarcx"]', '#frmCadcco');
    var rVlrtarnt = $('label[for="vlrtarnt"]', '#frmCadcco');
    var rVltrftaa = $('label[for="vltrftaa"]', '#frmCadcco');
    var rVlrtrblq = $('label[for="vlrtrblq"]', '#frmCadcco');
    var rDtmvtolt = $('label[for="dtmvtolt"]', '#frmCadcco');
    var rCdoperad = $('label[for="cdoperad"]', '#frmCadcco');
    var rCdtarhis = $('label[for="cdtarhis"]', '#frmCadcco');
    var rCdhiscxa = $('label[for="cdhiscxa"]', '#frmCadcco');
    var rCdhisnet = $('label[for="cdhisnet"]', '#frmCadcco');
    var rCdhistaa = $('label[for="cdhistaa"]', '#frmCadcco');
    var rCdhisblq = $('label[for="cdhisblq"]', '#frmCadcco');

    rCdcartei.addClass('rotulo').css('width', '170px');
    rNrvarcar.addClass('rotulo-linha').css('width', '14px');
    rNrlotblq.addClass('rotulo-linha').css('width', '170px');
    rLblvalor.addClass('rotulo').css('width', '170px');
    rLblhisto.addClass('rotulo-linha').css('width', '265px');
    rVlrtarif.addClass('rotulo').css('width', '170px');
    rCdtarhis.addClass('rotulo-linha').css('width', '170px');
    rVlrtarcx.addClass('rotulo').css('width', '170px');
    rCdhiscxa.addClass('rotulo-linha').css('width', '170px');
    rVlrtarnt.addClass('rotulo').css('width', '170px');
    rCdhisnet.addClass('rotulo-linha').css('width', '170px');
    rVltrftaa.addClass('rotulo').css('width', '170px');
    rCdhistaa.addClass('rotulo-linha').css('width', '170px');
    rVlrtrblq.addClass('rotulo').css('width', '170px');
    rCdhisblq.addClass('rotulo-linha').css('width', '170px');
    rDtmvtolt.addClass('rotulo').css('width', '170px');
    rCdoperad.addClass('rotulo-linha').css('width', '70px');

    //Formata campo Tarifas
    var cCdcartei = $('#cdcartei', '#frmCadcco');
    var cNrvarcar = $('#nrvarcar', '#frmCadcco');
    var cNrlotblq = $('#nrlotblq', '#frmCadcco');
    var cVlrtarif = $('#vlrtarif', '#frmCadcco');
    var cVlrtarcx = $('#vlrtarcx', '#frmCadcco');
    var cVlrtarnt = $('#vlrtarnt', '#frmCadcco');
    var cVltrftaa = $('#vltrftaa', '#frmCadcco');
    var cVlrtrblq = $('#vlrtrblq', '#frmCadcco');
    var cDtmvtolt = $('#dtmvtolt', '#frmCadcco');
    var cCdoperad = $('#cdoperad', '#frmCadcco');
    var cCdtarhis = $('#cdtarhis', '#frmCadcco');
    var cCdhiscxa = $('#cdhiscxa', '#frmCadcco');
    var cCdhisnet = $('#cdhisnet', '#frmCadcco');
    var cCdhistaa = $('#cdhistaa', '#frmCadcco');
    var cCdhisblq = $('#cdhisblq', '#frmCadcco');

    cCdcartei.css('width', '40px').addClass('inteiro').attr('maxlength', '2').setMask("INTEGER", "z9", ".", "");
    cNrvarcar.css('width', '30px').addClass('inteiro').attr('maxlength', '3').setMask("INTEGER", "zz9", ".", "");
    cVlrtarcx.css('width', '90px').addClass('moeda_6');
    cNrlotblq.css('width', '80px').addClass('inteiro').attr('maxlength', '7').setMask("INTEGER", "zzz.zz9", ".", "");
    cVlrtarif.css('width', '90px').addClass('moeda_6');
    cVlrtarnt.css('width', '90px').addClass('moeda_6');
    cVltrftaa.css('width', '90px').addClass('moeda_6');
    cVlrtrblq.css('width', '90px').addClass('moeda_6');
    cCdtarhis.css('width', '80px').addClass('inteiro').attr('maxlength', '4').setMask("INTEGER", "zzz.zz9", ".", "");
    cCdhiscxa.css('width', '80px').addClass('inteiro').attr('maxlength', '4').setMask("INTEGER", "zzz.zz9", ".", "");
    cCdhisnet.css('width', '80px').addClass('inteiro').attr('maxlength', '4').setMask("INTEGER", "zzz.zz9", ".", "");
    cCdhistaa.css('width', '80px').addClass('inteiro').attr('maxlength', '4').setMask("INTEGER", "zzz.zz9", ".", "");
    cCdhisblq.css('width', '80px').addClass('inteiro').attr('maxlength', '4').setMask("INTEGER", "zzz.zz9", ".", "");
    cDtmvtolt.css('width', '90px').addClass('data').desabilitaCampo();
    cCdoperad.css('width', '260px').desabilitaCampo();


    cFlgativo.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            $(this).nextAll('.campo:first').focus();

            return false;

        }

    });

    cDsorgarq.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            $(this).nextAll('.campo:first').focus();

            return false;

        }

    });

    cNrdctabb.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            $(this).nextAll('.campo:first').focus();

            return false;

        }

    });

    cFlgregis.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            if ($(this).val() == 0) {

                $('#vlrtarif', '#frmCadcco').habilitaCampo();
                $('#cdtarhis', '#frmCadcco').habilitaCampo();

            } else {

                $('#vlrtarif', '#frmCadcco').desabilitaCampo();
                $('#cdtarhis', '#frmCadcco').desabilitaCampo();

            }

            $(this).nextAll('.campo:first').focus();

            return false;

        }

    });

    cFlserasa.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            $(this).nextAll('.campo:first').focus();

            return false;

        }

    });


    cCdbccxlt.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            $(this).nextAll('.campo:first').focus();

            return false;

        }

    });

    // Se pressionar cddbanco
    $('#cddbanco', '#frmCadcco').unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            bo = 'zoom0001';
            procedure = 'CONSBANCOS';
            titulo = 'Banco';
            qtReg = '30';
            colunas = 'Código;cdbccxlt;20%;right|Banco;nmextbcc;80%;left';

            $(this).removeClass('campoErro');
            buscaDescricao(bo, procedure, titulo, 'cdbccxlt', 'nmextbcc', $('#cddbanco', '#frmCadcco').val(), 'nmextbcc', 'nriniseq|1;nrregist|30', 'frmCadcco');

            $('#cdbccxlt', '#frmCadcco').focus();

            return false;

        }

    });

    cCdagenci.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            $(this).nextAll('.campo:first').focus();

            return false;

        }

    });

    cNrdolote.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            $(this).nextAll('.campo:first').focus();

            return false;

        }

    });

    cCdhistor.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            $(this).nextAll('.campo:first').focus();

            return false;

        }

    });


    cCdbccxlt.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            $(this).nextAll('.campo:first').focus();

            return false;

        }

    });

    cNmarquiv.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            $(this).nextAll('.campo:first').focus();

            return false;

        }

    });


    cFlcopcob.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            $(this).nextAll('.campo:first').focus();

            return false;

        }

    });

    cNmdireto.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            $(this).nextAll('.campo:first').focus();

            return false;

        }

    });

    cQtdfloat.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            $(this).nextAll('.campo:first').focus();

            return false;

        }

    });

    cNrbloque.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            $(this).nextAll('.campo:first').focus();

            return false;

        }

    });

    cFlgcnvcc.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            $(this).nextAll('.campo:first').focus();

            return false;

        }

    });

    cTamannro.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            $(this).nextAll('.campo:first').focus();

            return false;

        }

    });

    cCdcartei.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            $(this).nextAll('.campo:first').focus();

            return false;

        }

    });

    cNrvarcar.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            $(this).nextAll('.campo:first').focus();

            return false;

        }

    });

    cNrlotblq.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            $(this).nextAll('.campo:first').focus();

            return false;

        }

    });

    cVlrtarif.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            $(this).nextAll('.campo:first').focus();

            return false;

        }

    });

    cCdtarhis.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            $(this).nextAll('.campo:first').focus();

            return false;

        }

    });

    cVlrtarcx.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            $(this).nextAll('.campo:first').focus();

            return false;

        }

    });

    cVlrtarcx.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            $(this).nextAll('.campo:first').focus();

            return false;

        }

    });

    cCdhiscxa.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            $(this).nextAll('.campo:first').focus();

            return false;

        }

    });

    cVltrftaa.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            $(this).nextAll('.campo:first').focus();

            return false;

        }

    });

    cCdhistaa.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            $(this).nextAll('.campo:first').focus();

            return false;

        }

    });

    cCdhisnet.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            $(this).nextAll('.campo:first').focus();

            return false;

        }

    });

    cVlrtarnt.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            $(this).nextAll('.campo:first').focus();

            return false;

        }

    });

    cCdhisblq.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            $(this).nextAll('.campo:first').focus();

            return false;

        }

    });

    cVlrtrblq.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            $(this).nextAll('.campo:first').focus();

            return false;

        }

    });

    cCdhisblq.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            $('#btConcluir', '#divBotoesCadcco').click();

            return false;

        }

    });

    //Se possuir boletos em aberto para o convênio em questão
    if (exisbole == 1) {

        cDsorgarq.desabilitaCampo();
        cNrdctabb.desabilitaCampo();
        cFlgregis.desabilitaCampo();
        cCddbanco.desabilitaCampo();

        if ($('#cddbanco', '#frmCadcco').val() == 85) {

            cDsorgarq.desabilitaCampo();

        } else {

            cQtdfloat.desabilitaCampo();
            ($('#cddbanco', '#frmCadcco').val() != 1) ? $('#flserasa', '#frmCadcco').habilitaCampo() : $('#flserasa', '#frmCadcco').desabilitaCampo();

        }

    } else {

        if ($('#cddbanco', '#frmCadcco').val() == 85) {

            if (cDsorgarq.val() == "IMPRESSO PELO SOFTWARE" ||
               cDsorgarq.val() == "PRE-IMPRESSO" ||
               cDsorgarq.val() == "INTERNET" ||
               cDsorgarq.val() == "PROTESTO" ||
              $('#cddopcao', '#frmCabCadcco').val() == "I") {

                cDsorgarq.habilitaCampo();

            } else {

                cDsorgarq.desabilitaCampo();
            }

        } else {

            if (cDsorgarq.val() == "IMPRESSO PELO SOFTWARE" ||
                cDsorgarq.val() == "PRE-IMPRESSO" ||
                cDsorgarq.val() == "INTERNET" ||
                cDsorgarq.val() == "PROTESTO" ||
                cDsorgarq.val() == "EMPRESTIMO" ||
               $('#cddopcao', '#frmCabCadcco').val() == "I") {

                cDsorgarq.habilitaCampo();

            } else {

                cDsorgarq.desabilitaCampo();
            }

            ($('#cddbanco', '#frmCadcco').val() != 1) ? $('#flserasa', '#frmCadcco').habilitaCampo() : $('#flserasa', '#frmCadcco').desabilitaCampo();
            
        }
        
    }

    if (cFlgregis.val() == 0) {

        $('#vlrtarif', '#frmCadcco').habilitaCampo();
        $('#cdtarhis', '#frmCadcco').habilitaCampo();

    } else {

        $('#vlrtarif', '#frmCadcco').desabilitaCampo();
        $('#cdtarhis', '#frmCadcco').desabilitaCampo();

    }

    highlightObjFocus($("#frmCadcco"));
    layoutPadrao();
    $('#divCadcco').css('display', 'block');
    $('#frmCadcco').css('display', 'block');

    return false;

}


function formataTabelaTarifas() {

    var divRegistro = $('div.divRegistros');
    var tabela = $('table', divRegistro);

    divRegistro.css({ 'height': '230px', 'width': '100%' });
    divRegistro.css({ 'border-bottom': '1px dotted #777', 'padding-bottom': '2px' });

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '50px';
    arrayLargura[1] = '250px';
    arrayLargura[2] = '80px';
    arrayLargura[3] = '80px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'right';
    arrayAlinha[4] = 'right';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);

    $('input[id="vltarifa"]', '#frmTarifas').each(function (i) {

        $(this).setMask("DECIMAL", "z9,99", "", "");
        ($('#cddopcao', '#frmCabCadcco').val() == 'C') ? $(this).addClass('inteiro').css({ 'width': '55px' }).attr('maxlength', '5').desabilitaCampo() : $(this).css({ 'width': '55px' }).attr('maxlength', '5').habilitaCampo();

    });

    $('input[id="cdtarhis"]', '#frmTarifas').each(function (i) {

        ($('#cddopcao', '#frmCabCadcco').val() == 'C') ? $(this).addClass('inteiro').css({ 'width': '55px' }).attr('maxlength', '4').desabilitaCampo() : $(this).addClass('inteiro').css({ 'width': '55px' }).attr('maxlength', '4').habilitaCampo();

    });

    //Já deixa um registro pré-selecionado
    $('table > tbody > tr', divRegistro).each(function (i) {

        if ($(this).hasClass('corSelecao')) {

            selecionaTarifa($(this));

        }

    });

    //seleciona o lancamento que é clicado
    $('table > tbody > tr', divRegistro).click(function () {

        selecionaTarifa($(this));

    });

    layoutPadrao();

    return false;
}

function formataTabelaMotivos() {

    var divRegistro = $('div.divRegistros', '#divRotina');
    var tabela = $('table', divRegistro);

    $('#divRotina').css('width', '650px');
    divRegistro.css({ 'height': '230px', 'width': '100%' });
    $('#divRotina').centralizaRotinaH();
    divRegistro.css({ 'border-bottom': '1px dotted #777', 'padding-bottom': '2px' });

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '50px';
    arrayLargura[1] = '360px';
    arrayLargura[2] = '80px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'right';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);

    $('input[id="vltarifa"]', '#frmMotivos').each(function (i) {

        $(this).setMask("DECIMAL", "z9,99", "", "");
        ($('#cddopcao', '#frmCabCadcco').val() == 'C') ? $(this).css({ 'width': '55px' }).attr('maxlength', '5').desabilitaCampo() : $(this).css({ 'width': '55px' }).attr('maxlength', '5').habilitaCampo();

    });

    $('input[id="cdtarhis"]', '#frmMotivos').each(function (i) {

        ($('#cddopcao', '#frmCabCadcco').val() == 'C') ? $(this).addClass('inteiro').css({ 'width': '55px' }).attr('maxlength', '4').desabilitaCampo() : $(this).addClass('inteiro').css({ 'width': '55px' }).attr('maxlength', '4').habilitaCampo();

    });

    layoutPadrao();

    return false;
}

function selecionaTarifa(tr) {

    var cddbanco = $('#cddbanco', tr).val();
    var cdocorre = $('#cdocorre', tr).val();

    //Ao clicar no botao Alterar motivo
    $('#btAlteraMotivo', '#divBotoesTarifas').unbind('click').bind('click', function () {

        buscaMotivos('1', '30', cddbanco, cdocorre);

    });

    //Ao clicar no botao Consulta motivo
    $('#btConsultaMotivo', '#divBotoesTarifas').unbind('click').bind('click', function () {

        buscaMotivos('1', '30', cddbanco, cdocorre);

    });

    return false;

}

function confirma() {


    var cddopcao = $('#cddopcao', '#frmCabCadcco').val();

    switch (cddopcao) {


        case 'E':

            showConfirmacao('Deseja confirmar exclus&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'excluirConvenio()', '', 'sim.gif', 'nao.gif');

            break;

        case 'A':

            showConfirmacao('Deseja confirmar altera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'alterarConvenio()', '', 'sim.gif', 'nao.gif');

            break;

        case 'I':

            showConfirmacao('Deseja confirmar a inclus&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'incluirConvenio();', '', 'sim.gif', 'nao.gif');

            break;


    }

}

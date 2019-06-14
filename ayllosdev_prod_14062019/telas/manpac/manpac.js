/*!
 * FONTE        : manpac.js
 * CRIACAO      : Jean Michel
 * DATA CRIACAO : 15/03/2016
 * OBJETIVO     : Biblioteca de funcoes da tela MANPAC
 * --------------
 * ALTERACOES   : 
 *				
 * --------------
 */

// Geral, Consulta e Desativacao
var rCddopcao, rCdpacote, rDspacote, rTppessoa, rVlpacote;
var cCddopcao, cCdpacote, cDspacote, cTppessoa, cVlpacote;

//Campos para habilitar pacote de tarifas
var rTppessoaHab, rCdtarifaHab, rVlpacoteHab, rDtvigencHab;
var cTppessoaHab, cCdtarifaHab, cVlpacoteHab, cDtvigencHab;

//Campos para Desabilitar e Migrar pacote de tarifas
var cTppessoaMig, cCdpacoteMig, cVlpacoteMig, cDspacoteMig;
var rTppessoaMig, rCdpacoteMig, rVlpacoteMig, rDspacoteMig;

var aux_tpbusca;

var btnOK;

var aux_manpac = 0;
var aux_forms = 1;
var aux_pesq = 0;
var aux_codantPct = 0;
var aux_codantMig = 0;

$(document).ready(function () {
    
    estadoInicial();
    
    $('#cddopcao', '#frmCab').unbind('keydown').bind('keydown', function (e) {

        if ($('#cddopcao', '#frmCab').hasClass('campoTelaSemBorda')) { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#btnOK', '#frmCab').focus();
            return false;
        }
    });

    $('#cdpacote', '#frmDados').unbind('keydown').bind('keydown', function (e) {

        if ($('#cdpacote', '#frmDados').hasClass('campoTelaSemBorda')) { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {
            verificaAcao('C');
            return false;
        }
    });
                
});

// seletores
function estadoInicial() {
    aux_manpac = 0;
    $("#divDadosMANPAC").css('display', 'none');
    $("#divDados").hide();
    $("#divDadosHabilitar").hide();
    $("#divHabilitar").hide();
    $("#divNaoHabilitar").hide();    
    $('#divTarifasMigracao').hide();
    $('#divDadosConsulta').css('display', 'none');
    $("#divDadosMigracao").hide();

    $("#pacotesTarifas").remove();
    $("#divDadosConsulta").remove();

    controlaLayout();
}

function controlaLayout() {
    
    btnOK = $('#btnOK', '#frmCab');
    btnOK.prop("disabled", false);
    
    cTodosCabecalho = $('input[type="text"],select', '#frmDados');

    layoutPadrao();

    // Label Cabecalho
    rCddopcao = $('label[for="cddopcao"]', '#frmCab');
    
    //Label Campos
    rCdpacote = $('label[for="cdpacote"]', '#frmDados');
    rDspacote = $('label[for="dspacote"]', '#frmDados');
    rTppessoa = $('label[for="tppessoa"]', '#frmDados');
    rVlpacote = $('label[for="vlpacote"]', '#frmDados');
    
    // Campos Consulta e Desativar
    cCddopcao = $('#cddopcao', '#frmCab');
    cCdpacote = $('#cdpacote', '#frmDados');
    cDspacote = $('#dspacote', '#frmDados');
    cTppessoa = $('#tppessoa', '#frmDados');
    cVlpacote = $('#vlpacote', '#frmDados');
   
    cBtnConcluir = $('#btnConcluir');
    cBtnVoltar = $('#btVoltar');
        
    rCddopcao.addClass('rotulo').css({ 'width': '68px' });
    cCddopcao.css({ 'width': '456px' });

    // Codigo e Descricao do Pacote
    rCdpacote.addClass('rotulo').css({ 'width': '120px' });
    cCdpacote.css({ 'width': '50px' });
    rDspacote.addClass('rotulo').css({ 'width': '120px' });
    cDspacote.css({ 'width': '350px' });    

    // Tipo de Pessoa
    rTppessoa.addClass('rotulo').css({ 'width': '120px' });
    cTppessoa.css({ 'width': '130px' });

    // Codigo e Descricao da Tarifa
    rVlpacote.addClass('rotulo').css({ 'width': '120px' });
    cVlpacote.css({ 'width': '130px' });
    
    $('#divDadosMANPAC').css({ 'display': 'none' });
    $('#divTarifasMigracao').hide();
    $("#divDadosMigracao").hide();

    cCddopcao.habilitaCampo();
    cCdpacote.habilitaCampo();
    cCdpacote.addClass('inteiro');
    cBtnConcluir.hide();
    cBtnVoltar.hide();

    btnOK.habilitaCampo();

    cCddopcao.val("C");
    cCddopcao.focus();

    $('fieldset > input').css({ 'font-size': '12px', 'color': '#000000', 'border': '1px solid #777', 'height': '20px' });
    $('fieldset > select').css({ 'font-size': '12px', 'color': '#000000', 'border': '1px solid #777', 'height': '20px' });

    cTodosCabecalho.limpaFormulario();
    cTppessoa.val(0);
    cBtnConcluir.html("Prosseguir");
}

function controlaLayoutHab() {

    //Label campos habilitar pacotes
    rTppessoaHab = $('label[for="tppessoaHab"]', '#frmDados');
    rCdtarifaHab = $('label[for="cdtarifaHab"]', '#frmDados');
    rVlpacoteHab = $('label[for="vlpacoteHab"]', '#frmDados');
    rDtvigencHab = $('label[for="dtvigencHab"]', '#frmDados');

    // Campos para habilitar pacotes
    cTppessoaHab = $('#tppessoaHab', '#frmDados');
    cCdtarifaHab = $('#cdtarifaHab', '#frmDados');
    cVlpacoteHab = $('#vlpacoteHab', '#frmDados');
    cDtvigencHab = $('#dtvigencHab', '#frmDados');

    //Campos da tela para habilitar pacotes
    rTppessoaHab.addClass('rotulo').css({ 'width': '260px' });
    rCdtarifaHab.addClass('rotulo').css({ 'width': '260px' });
    rVlpacoteHab.addClass('rotulo').css({ 'width': '260px' });
    rDtvigencHab.addClass('rotulo').css({ 'width': '260px' });

    cTppessoaHab.css({ 'width': '100px' });
    cCdtarifaHab.css({ 'width': '50px' });
    cVlpacoteHab.css({ 'width': '100px' });
    cDtvigencHab.css({ 'width': '65px' });

    $('fieldset > input').css({ 'font-size': '12px', 'color': '#000000', 'border': '1px solid #777', 'height': '20px' });
}

function controlaLayoutDes() {

    //Label campos desabilitar pacotes
    rCdpacoteMig = $('label[for="cdpacoteMig"]', '#frmDados');
    rDspacoteMig = $('label[for="dspacoteMig"]', '#frmDados');
    rVlpacoteMig = $('label[for="vlpacoteMig"]', '#frmDados');
    rTppessoaMig = $('label[for="tppessoaMig"]', '#frmDados');

    // Campos para desabilitar pacotes
    cCdpacoteMig = $('#cdpacoteMig', '#frmDados');
    cDspacoteMig = $('#dspacoteMig', '#frmDados');
    cTppessoaMig = $('#tppessoaMig', '#frmDados');
    cVlpacoteMig = $('#vlpacoteMig', '#frmDados');

    //Campos da tela para desabilitar pacotes
    rCdpacoteMig.addClass('rotulo').css({ 'width': '120px' });
    rTppessoaMig.addClass('rotulo').css({ 'width': '120px' });
    rVlpacoteMig.addClass('rotulo').css({ 'width': '120px' });
        
    cCdpacoteMig.css({ 'width': '50px' });
    cDspacoteMig.css({ 'width': '350px' });
    cTppessoaMig.css({ 'width': '130px' });
    cVlpacoteMig.css({ 'width': '130px' });   

    $('fieldset > select').css({ 'font-size': '12px', 'color': '#000000', 'border': '1px solid #777', 'height': '20px' });
    $('fieldset > input', '#divDadosMigracao').css({ 'font-size': '12px', 'color': '#000000', 'border': '1px solid #777', 'height': '20px' });
}

function verificaAcao(strAcao) {

    cBtnVoltar.show();
    btnOK.prop("disabled", true);

    if (strAcao == 'C') {
        if (cCddopcao.val() == 'C') {
            if (!$('#divDadosMANPAC').is(':visible')) {
                $('#divDadosConsulta').show();
                consultaDados();
                cCddopcao.desabilitaCampo();
                cDspacote.desabilitaCampo();
            }
        } else if (cCddopcao.val() == 'D') {
            $("fieldSet.fldPacote legend").text('Serviço Cooperativo Atual');

            $("#divHabilitar").hide();

            if (!$('#divDadosMANPAC').is(':visible')) {
                $("#divDadosMANPAC").css('display', 'block');
                $("#divDados").css('display', 'block');
                $("#divNaoHabilitar").css('display', 'block');
                cCddopcao.desabilitaCampo();
                $("#lupaCons").show();
                cBtnConcluir.show();
                cVlpacote.desabilitaCampo();
                cTppessoa.desabilitaCampo();
                cCdpacote.focus();
            } else {
                
                if (aux_manpac == 0) {
                    $("#lupaCons").show();
                    if (cCdpacote.val() == "" || cCdpacote.val() == 0) {
                        cDspacote.val("");
                        showError("error", "Informe um c&oacute;digo de servi&ccedil;o v&aacute;lido.", "Alerta - Ayllos", "cTodosCabecalho.limpaFormulario();cCdpacote.val(\"\");cCdpacote.focus();");
                        return false;
                    }
                    
                    buscaInformacoesPacote(1);
                    aux_codantPct = cCdpacote.val();
                    aux_pesq = 0;
                    return false;
                    //aux_manpac = 1;
                } else if (aux_manpac == 1) {
                    if (cCdpacote.val() == "" || cCdpacote.val() == 0) {
                        cTodosCabecalho.limpaFormulario();
                        showError("error", "Informe um c&oacute;digo de servi&ccedil;o v&aacute;lido.", "Alerta - Ayllos", "cCdpacote.val(\"\");cCdpacote.focus();");
                        return false;
                    }
                    
                    if ((cCdpacote.val() != aux_codantPct && aux_codantPct != 0) && aux_pesq == 0) {
                        aux_codantPct = cCdpacote.val();
                        buscaInformacoesPacote(1);
                    } else {
                        $("#lupaCons").hide();
                        cCdpacote.desabilitaCampo();
                        consultaTarifasDesativar(1);
                        cCdpacote.desabilitaCampo();
                        cDspacote.desabilitaCampo();
                        cTppessoa.desabilitaCampo();
                        cVlpacote.desabilitaCampo();
                    }
                    aux_pesq = 0;
                    return false;
                    //aux_manpac = 2;
                } else if (aux_manpac == 2) {
                    $("#divDadosMigracao").show();
                    formularioMigracao();
                    aux_pesq = 0;
                    
                    $("#cdpacoteMig").val("");
                    $("#tppessoaMig").val(0);
                    $("#vlpacoteMig").val("");
                    $("#dspacoteMig").val("");
                    return false;
                    //aux_manpac = 3;
                } else if (aux_manpac == 3) {
                    $("#divDadosMigracao").show();
                    if (cCdpacoteMig.val() == "" || cCdpacoteMig.val() == 0) {
                        cDspacoteMig.val("");
                        showError("error", "Informe um c&oacute;digo de servi&ccedil;o v&aacute;lido.", "Alerta - Ayllos", "cCdpacoteMig.val(\"\");cCdpacoteMig.focus();");
                        return false;
                    }                    
                                        
                    buscaInformacoesPacote(2);
                    aux_codantMig = cCdpacoteMig.val();
                    aux_pesq = 0;
                    return false;
                    //aux_manpac = 4;
                } else if (aux_manpac == 4) {
                    if (cCdpacoteMig.val() == cCdpacote.val()) {
                        showError("error", "C&oacute;digo do novo servi&ccedil;o deve ser diferente do servi&ccedil;o atual.", "Alerta - Ayllos", "cCdpacoteMig.val(\"\");cTppessoaMig.val(0);cVlpacoteMig.val(\"\");cDspacoteMig.val(\"\");cCdpacoteMig.focus();");
                        return false;
                    }
                    
                    if (cCdpacoteMig.val() != aux_codantMig && aux_codantMig != 0) {
                        aux_codantMig = cCdpacoteMig.val();
                        $("#divDadosMigracao").show();
                        buscaInformacoesPacote(2);     
                    } else {
                        if (cCdpacoteMig.val() == "" || cCdpacoteMig.val() == 0) {
                            cDspacoteMig.val("");
                            showError("error", "Informe um c&oacute;digo de servi&ccedil;o v&aacute;lido.", "Alerta - Ayllos", "cCdpacoteMig.val(\"\");cCdpacoteMig.focus();");
                            return false;
                        }

                        if (cTppessoa.val() == cTppessoaMig.val()) {
                            $("#lupaMigra").hide();
                            cCdpacoteMig.desabilitaCampo();
                            consultaTarifasDesativar(2);
                        } else {
                            showError("error", "Tipo de pessoa do novo Servi&ccedil;o Cooperativo n&atilde;o confere com o Servi&ccedil;o Cooperativo atual.", "Alerta - Ayllos", "cCdpacoteMig.val(\"\");cTppessoaMig.val(0);cVlpacoteMig.val(\"\");cDspacoteMig.val(\"\");cCdpacoteMig.focus();");
                            return false;
                        }                        
                    }
                    aux_pesq = 0;
                    return false;
                    //aux_manpac = 5;
                } else if (aux_manpac == 5) {
                    validaMigracaoPacote();
                    aux_pesq = 0;
                    return false;
                    //aux_manpac = 6;
                } else if (aux_manpac == 6) {
                    aux_pesq = 0;
                    migracaoPacote();
                    aux_manpac = 6;
                } else if (aux_manpac == 7) {
                    aux_pesq = 0;
                    validaDesativar();
                }
            }
        } else if (cCddopcao.val() == 'H') {

            $("fieldSet.fldPacote legend").text('Serviço Cooperativo');

            if (!$('#divDadosMANPAC').is(':visible')) {
                $('#divDadosConsulta').css('display', 'none');
                $('#divDadosHabilitar').css('display', 'none');

                $("#divDadosMANPAC").css('display', 'block');
                $("#divDados").css('display', 'block');
                $("#divNaoHabilitar").css('display', 'none');
                $("#lupaCons").show();
                cCddopcao.desabilitaCampo();
                cCdpacote.focus();
                cBtnConcluir.show();
            } else if (!$('#divNaoHabilitar').is(':visible') && cBtnConcluir.html() == "Prosseguir") {
                $('#divDadosConsulta').css('display', 'none');
                $('#divDadosHabilitar').css('display', 'none');
                cCdpacote.desabilitaCampo();
                cDspacote.desabilitaCampo();
                $('#lupaCons').hide();
                consultaHabilitar();
            } else if ($('#divHabilitar').is(':visible')) {
                validaHabilitar();
            }         
        }

    } else if (strAcao == 'V') {
        
        if (cCddopcao.val() == 'C') {
            cDspacote.desabilitaCampo();
            $('#divLupaTarifa').show();
		    $('#divConsulta').hide();
		    $('#divDadosConsulta').hide();
            estadoInicial();
        } else if (cCddopcao.val() == 'D') {
            if (aux_manpac == 0) {
                $("#lupaCons").show();
                estadoInicial();
            } else if (aux_manpac == 1) {
                estadoInicial();
            } else if (aux_manpac == 2) {
                $("#lupaCons").show();
                cCdpacote.habilitaCampo();
                aux_manpac = 1;
            } else if (aux_manpac == 3) {
                aux_manpac = 1;
            } else if (aux_manpac == 4) {
                $("#lupaMigra").show();
                cCdpacoteMig.habilitaCampo();
                aux_manpac = 1;
            } else if (aux_manpac == 5) {
                $("#lupaMigra").show();
                cCdpacoteMig.habilitaCampo();
                aux_manpac = 4;
            } else if (aux_manpac == 6) {
                aux_manpac = 5;
            } else if (aux_manpac == 7) {
                $("#lupaCons").show();
                //aux_manpac = 2;
                aux_manpac = 1;
            }

            if ($('#divConsulta').is(':visible') && !$('#divDadosConsulta').is(':visible')) {
                
            } else {                
                if ($('#divTarifasMigracao').is(':visible')) {
                    
                    /*cCdpacoteMig.val("");
                    cTppessoaMig.val(0);
                    cVlpacoteMig.val("");
                    cDspacoteMig.val("");*/
                    $('#divTarifasMigracao').hide();
                    cBtnConcluir.html("Prosseguir");
                } else if ($('#divDadosMigracao').is(':visible')) {
                    cCdpacoteMig.empty();
                    cTppessoaMig.val(0);
                    cVlpacoteMig.empty();
                    cDspacoteMig.empty();
                    
                    $('#divDadosMigracao').hide();
                    $('#divDadosConsulta').hide();
                    $("#lupaCons").show();
                    cCdpacote.habilitaCampo();
                    cBtnConcluir.html("Prosseguir");
                    cCdpacote.focus();
                } else if ($('#divDadosConsulta').is(':visible')) {
                    
                    $('#divDadosConsulta').hide();
                    cCdpacote.habilitaCampo();
                    cBtnConcluir.html("Prosseguir");
                    cCdpacote.focus();

                } else {
                    
                    cCdpacote.habilitaCampo();
                    cCdpacote.focus();
                    aux_teste = 1;
                    if (cCdpacote.val() == "") {
                        estadoInicial();
                    } else if (cCdpacote.val() != "" && cCdpacote.val() != undefined) {
                        if (aux_forms == 1) {
                            estadoInicial();
                        } else {
                            aux_forms = 2;
                            $('#divDadosConsulta').hide();
                            $("#divDadosMigracao").hide();
                            cBtnConcluir.html("Prosseguir");
                            cCdpacote.focus();
                        }
                    } else {
                        estadoInicial();
                    }
                }
            }

        } else if (cCddopcao.val() == 'H') {
	        if ($('#divHabilitar').is(':visible')) {
				$("#divConsulta").hide();
                $("#divHabilitar").css('display', 'none');
                cBtnConcluir.html("Prosseguir");
                $('#lupaCons').show();
                //cTodosCabecalho.limpaFormulario();
                cCdpacote.habilitaCampo();
                cCdpacote.addClass('inteiro');
                cCdpacote.focus();
            } else if ($('#divDados').is(':visible')) {
				$("#divConsulta").hide();
                estadoInicial();
            }
        }
    }
}

// Formata tabela de Pacotes
function formataTabelaPacote() {

    // Tabela
    $('#divDadosConsulta').css({ 'display': 'block' });
    $('#divConsulta').css({ 'display': 'block' });

    //var divRegistro = $('div.divRegistros', '#divDadosConsulta');
    var divRegistro = $('div.divRegistros', '#Pacotes');
    var tabela = $('#tablePacote', divRegistro);
    var linha = $('#tablePacote table > tbody > tr', divRegistro);

    $('#tablePacote').css({ 'margin-top': '5px' });
    divRegistro.css({ 'height': '200px', 'width': '750px', 'padding-bottom': '2px' });

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];
    var arrayLargura = new Array();
    var arrayAlinha = new Array();
    
    arrayLargura[0] = '75px';
    arrayLargura[1] = '275px';
    arrayLargura[2] = '200px';
    arrayLargura[3] = '75px';
        
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'left';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'center';
    
    var metodoTabela = 'verDetalhe(this)';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);
    hideMsgAguardo();

    layoutPadrao();

    return false;
}

// Formata tabela de Pacotes
function formataTabelaPacoteTarifa() {

    // Tabela
    $('#divDadosConsulta').css({ 'display': 'block' });
    $('#divConsulta').css({ 'display': 'block' });

    //var divRegistro = $('div.divRegistros', '#divDadosConsulta');
    var divRegistro = $('div.divRegistros', '#pacotesTarifas');
    var tabela = $('#tablePacoteTarifa', divRegistro);
    var linha = $('#tablePacoteTarifa table > tbody > tr', divRegistro);

    $('#tablePacoteTarifa').css({ 'margin-top': '5px' });
    divRegistro.css({ 'height': '200px', 'width': '750px', 'padding-bottom': '2px' });

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    var arrayAlinha = new Array();
    
    arrayLargura[0] = '75px';
    arrayLargura[1] = '530px';

    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'center';
    
    var metodoTabela = 'verDetalhe(this)';    
    
    tabela.formataTabela('', arrayLargura, arrayAlinha, metodoTabela);
        
    hideMsgAguardo();
    layoutPadrao();

    return false;
}

function formataTabelaPctTarifaDes() {
    // Tabela
    $('#divDadosConsulta').css({ 'display': 'block' });
    $('#divConsulta').css({ 'display': 'block' });

    var divRegistro = $('div.divRegistros', '#divDadosConsulta');
    var tabela = $('#tablePacoteDesativar', divRegistro);
    var linha = $('#tablePacoteDesativar table > tbody > tr', divRegistro);

    $('#tablePacoteDesativar').css({ 'margin-top': '5px' });
    divRegistro.css({ 'height': '200px', 'width': '600px', 'padding-bottom': '2px' });

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    var arrayAlinha = new Array();

    arrayLargura[0] = '40px';
    arrayLargura[1] = '375px';

    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'center';

    var metodoTabela = '';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);
    
    hideMsgAguardo();
    layoutPadrao();

    return false;
}

function formataTabelaPctTarifaMig() {
    // Tabela
    $('#divDadosConsulta').css({ 'display': 'block' });
    $('#divConsulta').css({ 'display': 'block' });

    var divRegistro = $('div.divRegistros', '#divTarifasMig');
    var tabela = $('#tablePacoteMigracao', divRegistro);
    var linha = $('#tablePacoteMigracao table > tbody > tr', divRegistro);

    $('#tablePacoteMigracao').css({ 'margin-top': '5px' });
    divRegistro.css({ 'height': '200px', 'width': '600px', 'padding-bottom': '2px' });

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    var arrayAlinha = new Array();

    arrayLargura[0] = '40px';
    arrayLargura[1] = '375px';

    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'center';

    var metodoTabela = '';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

    hideMsgAguardo();
    layoutPadrao();

    return false;
}

function consultaDados() {

    if (cCddopcao.val() != "C") {
        if (cCddopcao.val() == "D") {
            consultaTarifasDesativar(1);
            return false;
        } else if (cCddopcao.val() == "H") {
            consultaHabilitar();
            return false;
        } else {
            showError("error", "Selecione a op&ccedil;&atilde;o correta.", "Alerta - Ayllos", "estadoInicial();");
            return false;
        }

        if (cCdpacote.val() == "" || cCdpacote.val() == 0) {
            showError("error", "Informe um c&oacute;digo de servi&ccedil;o v&aacute;lido.", "Alerta - Ayllos", "cTodosCabecalho.limpaFormulario();cCdpacote.focus();");
            return false;
        }
    }
    
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, buscando informa&ccedil;&otilde;es ...");

    // Executa script de consulta atrav?de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
				async: false,
        url: UrlSite + "telas/manpac/consulta_dados_pacote.php",
        data: {
            cddopcao: cCddopcao.val(),
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                hideMsgAguardo();
                $("#divDadosMANPAC").show();
                $('#divConsulta').show();
                $('#divConsulta').html(response);
                formataTabelaPacote();
                $('#divCab').css('text-align', 'center');                
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

function buscaInformacoesPacote(tipoBusca) {
    
    var cdpacote = 0;
    
    if (tipoBusca == 1 || tipoBusca == 0 || tipoBusca == 2) {
        aux_tpbusca = tipoBusca;
    }

    if (aux_tpbusca == 1) {
        if (cCdpacote.val() == "") {
            cDspacote.val("");
            return false;
        }
        
        cdpacote = cCdpacote.val();

    } else {
        
        if (cCdpacoteMig.val() == "") {
            cDspacoteMig.val("");
            return false;
        }

        if (cCdpacoteMig.val() != "" && cDspacoteMig.val() != "" && cCddopcao.val() != 'H') {
            consultaDados();
        }

        cdpacote = cCdpacoteMig.val();
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, consultando informa&ccedil;&otilde;es...");

    // Executa script de consulta atrav?de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/manpac/busca_inf_pacote.php",
        data: {
            cddopcao: cCddopcao.val(),
            cdpacote: cdpacote,
            tipoBusca: aux_tpbusca,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            $('#divConsulta').hide();
        },
        success: function (response) {
            try {
                hideMsgAguardo();
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
                $('#divConsulta').hide();
            }
        }
    });

}

function consultaTarifasDesativar(tipoBusca) {
    
    var cdpacote = 0;
    
    if (tipoBusca == 1) {
        if (cCdpacote.val() == "") {
            cDspacote.val("");
            showError("error", "Informe um c&oacute;digo de servi&ccedil;o v&aacute;lido.", "Alerta - Ayllos", "cTodosCabecalho.limpaFormulario();cCdpacote.focus();");
            return false;
        }
        cdpacote = cCdpacote.val();
    } else {
        
        if (cCdpacoteMig.val() == "") {
            cDspacoteMig.val("");
            showError("error", "Informe um c&oacute;digo de servi&ccedil;o v&aacute;lido.", "Alerta - Ayllos", "cCdpacoteMig.focus();");
            return false;
        }
        cdpacote = cCdpacoteMig.val();
    }    
    
    $('#divConsulta').show();

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, consultando informa&ccedil;&otilde;es...");

    // Executa script de consulta atrav?de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/manpac/busca_inf_pct_tarifa.php",
        data: {
            cddopcao: cCddopcao.val(),
            cdpacote: cdpacote,
            tipoBusca: tipoBusca,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            try {
                hideMsgAguardo();
                if (tipoBusca == 1) {
                    $('#divConsulta').html(response);
                    $('#divDadosConsulta').show();
                    formataTabelaPctTarifaDes();
                } else {
                    $('#divTarifasMigracao').show();
                    $('#divTarifasMigracao').html(response);
                    formataTabelaPctTarifaMig();
                    aux_manpac = 5;
                }
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

function validaDesativar() {
    if (cCdpacote.val() == "") {
        showError("error", "Informe um c&oacute;digo de servi&ccedil;o v&aacute;lido.", "Alerta - Ayllos", "estadoInicial();");
        return false;
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, validando informa&ccedil;&otilde;es...");

    // Executa script de consulta atraves de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/manpac/valida_desativar.php",
        data: {
            cddopcao: cCddopcao.val(),
            cdpacote: cCdpacote.val(),
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "estadoInicial();");
        },
        success: function (response) {
            try {
                hideMsgAguardo();
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "estadoInicial();");
            }
        }
    });
}

function efetivaDesativar() {

    if (cCdpacote.val() == 0 || cCdpacote.val() == "") {
        showError("error", "Informe um c&oacute;digo de servi&ccedil;o v&aacute;lido.", "Alerta - Ayllos", "cCdpacote.habilitaCampo();cCdpacote.addClass('inteiro');cTodosCabecalho.limpaFormulario();cCdpacote.focus();");
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, desativando pacote de tarifas...");

    // Executa script de consulta atrav?de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/manpac/desativar_pacote.php",
        data: {
            cddopcao: cCddopcao.val(),
            cdpacote: cCdpacote.val(),
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "estadoInicial();");
        },
        success: function (response) {
            try {
                hideMsgAguardo();
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        }
    });
}

function controlaPesquisaPacote() {
    
    // Variável local para guardar o elemento anterior
    var campoAnterior = '';
    var bo, procedure, titulo, qtReg, filtros, colunas, titulo_coluna;

    // Nome do Formulário que estamos trabalhando
    var nomeFormulario = 'frmDados';
    var divRotina = 'divTela';
    //var aux_close = 'aux_manpac = 0;';
    var aux_close = 'fechaPesquisa();';
    //Remove a classe de Erro do form
    $('input,select', '#' + nomeFormulario).removeClass('campoErro');
    
    dspacote = '';
    titulo_coluna = "Servi&ccedil;os Cooperativos";
    
    bo = 'b1wgen0153.p';
    procedure = 'consulta_pacote_manpac';
    titulo = 'Servi&ccedil;os Cooperativos';
    qtReg = '20';
    aux_pesq = 99;

    if (aux_manpac == 0 || aux_manpac == 1 || aux_manpac == 2) {
        filtros = 'Codigo;cdpacote;50px;S;' + cCdpacote.val() + ';S|Nome;dspacote;250px;S;' + cDspacote.val() + ';S|Tipo Pessoa;tppessoa;0px;S;;N|Tipo Pessoa;dspessoa;0px;S;;N|Data Cancelamento;dtcancelamento;px;S;;N|Cod. Tarifa;cdtarifa_lancamento;0px;S;cdtarifa_lancamento;N|Dstarifa;dstarifa;0px;S;dstarifa;N|Opcao;cddopcao;150px;S;' + cCddopcao.val() + ';N|Valor;vlpacote;150px;S;0;N';
        colunas = 'Codigo;cdpacote;10%;right;;S|Descricao;dspacote;40%;left;;S|COD;tppessoa;25%;left;;N|TIPO DE PESSOA;dspessoa;25%;left;;S|DATA CANCELAMENTO;dtcancelamento;25%;right;;N|COD. TARIFA;cdtarifa_lancamento;25%;left;;N|DESC. TARIFA;dstarifa;25%;left;;N|OPCAO;cddopcao;25%;left;;N|VALOR;vlpacote;25%;left;;N';
        aux_manpac = 1;
        mostraPesquisa(bo, procedure, titulo, qtReg, filtros, colunas, '', aux_close, '', '');
    } else {
        filtros = 'Codigo;cdpacoteMig;50px;S;' + cCdpacoteMig.val() + ';S|Nome;dspacoteMig;250px;S;' + cDspacoteMig.val() + ';S|Tipo Pessoa;tppessoaMig;0px;S;;N|Opcao;cddopcao;150px;S;' + cCddopcao.val() + ';N|Valor;vlpacoteMig;150px;S;0;N';
        colunas = 'Codigo;cdpacote;10%;right;;S|Descricao;dspacote;40%;left;;S|COD;tppessoa;25%;left;;N|OPCAO;cddopcao;25%;left;;N|VALOR;vlpacote;25%;left;;N|TIPO DE PESSOA;dspessoa;25%;left;;S';
        aux_manpac = 4;

        mostraPesquisa(bo, procedure, titulo, qtReg, filtros, colunas, '', '', '', '');
    }
    
    
    $("#divPesquisa").css("left", "258px");
    $("#divPesquisa").css("top", "91px");
    $("#divCabecalhoPesquisa > table").css("width", "690px");
    $("#divCabecalhoPesquisa > table").css("float", "left");
    $("#divResultadoPesquisa > table").css("width", "690px");
    $("#divCabecalhoPesquisa").css("width", "690px");
    $("#divResultadoPesquisa").css("width", "690px");
    
    return false;
}

function consultaHabilitar() {
    if (cCdpacote.val() == 0 || cCdpacote.val() == "") {
        showError("error", "Informe um c&oacute;digo de servi&ccedil;o v&aacute;lido.", "Alerta - Ayllos", "cCdpacote.habilitaCampo();cCdpacote.addClass('inteiro');cTodosCabecalho.limpaFormulario();$('#lupaCons').show();cCdpacote.focus();");
        return false;
    }

    if (cCddopcao.val() != "H") {
        showError("error", "Selecione a op&ccedil;&atilde;o correta.", "Alerta - Ayllos", "estadoInicial();");
        return false;
    }
    
    buscaInformacoesPacote(1);

    cBtnConcluir.html("Concluir");

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, consultando Servi&ccedil;o Cooperativo...");

    // Executa script de consulta atrav?de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/manpac/consulta_habilitar.php",
        data: {
            cddopcao: cCddopcao.val(),
            cdpacote: cCdpacote.val(),
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "estadoInicial();");
        },
        success: function (response) {
            try {
                hideMsgAguardo();
                if (response.indexOf('showError("error"') == -1) {
                    $("#divHabilitar").show();
                    $("#divHabilitar").html(response);
                    $("#divDadosConsulta").show();
                    formataTabelaPctTarifaHab();
                    controlaLayoutHab();
                } else {
                    eval(response);
                }
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "estadoInicial();");
            }
        }
    });
}

function formataTabelaPctTarifaHab() {
    // Tabela
    $('#divDadosConsulta').css({ 'display': 'block' });
    $('#divConsulta').css({ 'display': 'block' });

    var divRegistro = $('div.divRegistros', '#divDadosConsulta');
    var tabela = $('#tablePacoteHabilitar', divRegistro);
    var linha = $('#tablePacoteDesativar table > tbody > tr', divRegistro);

    $('#tablePacoteHabilitar').css({ 'margin-top': '5px' });
    divRegistro.css({ 'height': '200px', 'width': '650px', 'padding-bottom': '2px' });

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    var arrayAlinha = new Array();

    arrayLargura[0] = '100px';
    arrayLargura[1] = '380px';

    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'center';

    var metodoTabela = 'verDetalhe(this)';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

    hideMsgAguardo();
    layoutPadrao();

    return false;
}

function validaHabilitar() {

    if (cDtvigencHab.val() == "") {
        showError("error", "Informe a Data de in&iacute;cio da vig&ecirc;ncia.", "Alerta - Ayllos", "cDtvigencHab.focus();");
        return false;
    }
    
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, validando habilita&ccedil;&atilde;o do Servi&ccedil;o Cooperativo...");

    // Executa script de consulta atrav?de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/manpac/valida_habilitar.php",
        data: {
            cddopcao: cCddopcao.val(),
            cdpacote: cCdpacote.val(),
            dtvigenc: cDtvigencHab.val(),
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "estadoInicial();");
        },
        success: function (response) {
            try {
                hideMsgAguardo();
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "estadoInicial();");
            }
        }
    });

}

function efetivaHabilitar() {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, habilitando Servi&ccedil;o Cooperativo...");

    // Executa script de consulta atrav?de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/manpac/efetiva_habilitar.php",
        data: {
            cddopcao: cCddopcao.val(),
            cdpacote: cCdpacote.val(),
            dtvigenc: cDtvigencHab.val(),
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "estadoInicial();");
        },
        success: function (response) {
            try {
                hideMsgAguardo();
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "estadoInicial();");
            }
        }
    });
}

function mostraTarifas(cdpacote) {
    
	$("#pacotesTarifas").remove();
				
    if (cdpacote == "" || cdpacote == undefined) {		
        return false;
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, habilitando Servi&ccedil;o Cooperativo...");

    // Executa script de consulta atrav?de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/manpac/consulta_dados_tarifa.php",
        data: {
            cddopcao: cCddopcao.val(),
            cdpacote: cdpacote,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "estadoInicial();");
        },
        success: function (response) {
	        hideMsgAguardo();            
	        $('#divConsulta').append(response);							
	        formataTabelaPacoteTarifa();
        }
    });
}

function formularioMigracao() {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, habilitando migra&ccedil;&atilde;o de Servi&ccedil;o Cooperativo...");

    // Executa script de consulta atrav?de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/manpac/migracao_pacote.php",
        data: {
            cddopcao: cCddopcao.val(),
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "estadoInicial();");
        },
        success: function (response) {
            hideMsgAguardo();
            $("#divMigracao").html(response);
            controlaLayoutDes();
            layoutPadrao();
            aux_manpac = 3;
            cCdpacoteMig.focus();            
        }
    });
}

function migracaoPacote() {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, habilitando migra&ccedil;&atilde;o do Servi&ccedil;o Cooperativo...");

    // Executa script de consulta atrav?de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/manpac/efetiva_migracao.php",
        data: {
            cddopcao: cCddopcao.val(),
            cdpctant: cCdpacote.val(),
            cdpctnov: cCdpacoteMig.val(),
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "estadoInicial();");
        },
        success: function (response) {
            hideMsgAguardo();
            eval(response);
        }
    });
}

function validaMigracaoPacote() {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, habilitando migra&ccedil;&atilde;o do Servi&ccedil;o Cooperativo...");

    // Executa script de consulta atrav?de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/manpac/valida_migracao.php",
        data: {
            cddopcao: cCddopcao.val(),
            cdpctant: cCdpacote.val(),
            cdpctnov: cCdpacoteMig.val(),
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "estadoInicial();");
        },
        success: function (response) {
            hideMsgAguardo();
            eval(response);
        }
    });
}

function fechaPesquisa() {
    if (cCdpacote.val() != 0 && cCdpacote.val() != "" && cCdpacote.val() != null) {
        buscaInformacoesPacote(1);
    }else{
        aux_manpac = 0;
    }
}
//************************************************************************************************//
//*** Fonte: altseg.js                               					                       ***//
//*** Autor: Cristian Filipe                                                                   ***//
//*** Data : Novembro/2013  										                           ***//
//*** Alterações: 09/03/2016 - Ajuste feito para que operadores do departamento COORD.PRODUTOS ***//
//***    					   tenham permições para alterar e incluir conforme solicitado no  ***//
//***					       chamado 399940 (Kelvin).			    				           ***//	 
//***					                                                                       ***//	 
//***			  19/10/2017 - Correcao na exibicao do campo Prosseguir na opcao de Alteracao  ***//	 
//***			               SD 770963 (Carlos Rafael Tanholi).                              ***//	 
//*********************************************************************************************//

// Definição de algumas variáveis globais 
var cddopcao = 'C';
var auxiliar;

//Formulários
var frmCab = 'frmCab';

//Labels/Campos do cabeçalho
var rCddopcao, rcddgrupo, cTodosCabecalho, btnCab;

//Label/Campo busca seguradora
var cCdsegura, cNmresseg, cTpseguro, cTpplaseg,
    rCdsegura, rNmresseg, rTpseguro, rTpplaseg, cTodosBuscaSeguradora;

// Label/Campos Formulario planos seguradoras - Prestamista e Vida
var cDsmoradaPV, cVlplasegPV, cDsocupacPV, cNrtabelaPV, cVlmoradaPV, cFlgunicaPV,
    cInplasegPV, cCdsitpsgPV, cDdcancelPV, cDddcortePV, cDdmaxpagPV, cMmpripagPV, cQtdiacarPV, cQtmaxparPV,
    rDsmoradaPV, rVlplasegPV, rDsocupacPV, rNrtabelaPV, rVlmoradaPV, rFlgunicaPV,
    rInplasegPV, rCdsitpsgPV, rDdcancelPV, rDddcortePV, rDdmaxpagPV, rMmpripagPV, rQtdiacarPV, rQtmaxparPV, cTodosPrestamistaVida;

// Label/Campos Formulario planos seguradoras - Prestamista e Vida
var cDsmoradaC, cVlplasegC, cDsocupacC, cNrtabelaC, cFlgunicaC, cInplasegC,
    cCdsitpsgC, cDdcancelC, cDddcorteC, cDdmaxpagC, cMmpripagC, cQtdiacarC, cQtmaxparC,
    rDsmoradaC, rVlplasegC, rDsocupacC, rNrtabelaC, rFlgunicaC, rInplasegC,
    rCdsitpsgC, rDdcancelC, rDddcorteC, rDdmaxpagC, rMmpripagC, rQtdiacarC, rQtmaxparC, cTodosCasa,
	cNrtabela, cVlpercen, cDatdebit, cDatdespr;

$(document).ready(function () {

    estadoInicial();

});

function estadoInicial() {

    /*Esconde formularios e limpa os campos*/
    $('#frmInfSeguradora').css({ 'display': 'none' });
    $('#frmInfAtualiza').css({ 'display': 'none' });
    $('#frmInfPlano').css({ 'display': 'none' });
    $('#frmInfPlanoCasa').css({ 'display': 'none' });
    $('#frmTabGarantia').css({ 'display': 'none' });
    $('#divTabela').css({ 'display': 'none' }).html('');
    $('#tpseguro', '#frmInfSeguradora').val(3);

    $('#divBotoes').css({ 'display': 'none' });
    $('#btSalvar', '#divBotoes').hide();

    /*Esconde formularios e limpa os campos*/
    formataCabecalho();

    // Remover class campoErro
    $('input,select', '#frmCab').removeClass('campoErro');

    cTodosCabecalho.limpaFormulario();
    $('#cddopcao', '#frmCab').val(cddopcao);
    $('#cdsegura', '#frmInfSeguradora').attr('aux', '');

}

function formataCabecalho() {

    $('label[for="cddopcao"]', '#frmCab').css('width', '40px').addClass('rotulo');
    $('#cddopcao', '#frmCab').css('width', '510px');
    $('#divTela').css({ 'display': 'inline' }).fadeTo(0, 0.1);
    removeOpacidade('divTela');
    $('#frmCab').css({ 'display': 'block' });

    cTodosCabecalho = $('input[type="text"],select', '#' + frmCab);
    btnCab = $('#btOK', '#' + frmCab);

    cTodosCabecalho.habilitaCampo();

    $('#cddopcao', '#frmCab').unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) {

            ($(this).val() == 'K') ? LiberaFormularioAtualizar() : LiberaFormulario();

            return false;
        }
    });

    $('#btnOK', '#frmCab').unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) {

            ($(this).val() == 'K') ? LiberaFormularioAtualizar() : LiberaFormulario();
            return false;
        }
    });

    //Ao clicar no botao OK
    $('#btOK', '#frmCab').unbind('click').bind('click', function () {

        ($('#cddopcao', '#frmCab').val() == 'K') ? LiberaFormularioAtualizar() : LiberaFormulario();

    });

    highlightObjFocus($('#' + frmCab));

    $('#cddopcao', '#' + frmCab).focus();

    layoutPadrao();

    return false;

}

function formataCamposBuscaSeguradora() {
    rCdsegura = $('label[for="cdsegura"]', '#frmInfSeguradora');
    rTpseguro = $('label[for="tpseguro"]', '#frmInfSeguradora');
    rTpplaseg = $('label[for="tpplaseg"]', '#frmInfSeguradora');

    rCdsegura.css({ 'width': '94px' });
    rTpseguro.css({ 'width': '94px' });
    rTpplaseg.css({ 'width': '286px' });

    cCdsegura = $('#cdsegura', '#frmInfSeguradora');
    cNmresseg = $('#nmresseg', '#frmInfSeguradora');
    cTpseguro = $('#tpseguro', '#frmInfSeguradora');
    cTpplaseg = $('#tpplaseg', '#frmInfSeguradora');

    cCdsegura.addClass('inteiro').css({ 'width': '80px' }).attr('maxlength', '11').setMask('INTEGER', 'zzz.zzz.zzz', '.', '');
    cNmresseg.css({ 'width': '338px' });
    cTpseguro.css({ 'width': '112px' });
    cTpplaseg.addClass('inteiro').css({ 'width': '40px' }).attr('maxlength', '3');

    highlightObjFocus($('#frmInfSeguradora'));

}

function formataCamposPrestamistaVida() {
    rDsmoradaPV = $('label[for="dsmorada"]', '#frmInfPlano');
    rVlplasegPV = $('label[for="vlplaseg"]', '#frmInfPlano');
    rDsocupacPV = $('label[for="dsocupac"]', '#frmInfPlano');
    rNrtabelaPV = $('label[for="nrtabela"]', '#frmInfPlano');
    rVlmoradaPV = $('label[for="vlmorada"]', '#frmInfPlano');
    rFlgunicaPV = $('label[for="flgunica"]', '#frmInfPlano');
    rInplasegPV = $('label[for="inplaseg"]', '#frmInfPlano');
    rCdsitpsgPV = $('label[for="cdsitpsg"]', '#frmInfPlano');
    rDdcancelPV = $('label[for="ddcancel"]', '#frmInfPlano');
    rDddcortePV = $('label[for="dddcorte"]', '#frmInfPlano');
    rDdmaxpagPV = $('label[for="ddmaxpag"]', '#frmInfPlano');
    rMmpripagPV = $('label[for="mmpripag"]', '#frmInfPlano');
    rQtdiacarPV = $('label[for="qtdiacar"]', '#frmInfPlano');
    rQtmaxparPV = $('label[for="qtmaxpar"]', '#frmInfPlano');

    rDsmoradaPV.css({ 'width': '120px' });
    rVlplasegPV.css({ 'width': '120px' });
    rDsocupacPV.css({ 'width': '120px' });
    rNrtabelaPV.css({ 'width': '120px' });
    rVlmoradaPV.css({ 'width': '120px' });
    rFlgunicaPV.css({ 'width': '120px' });
    rInplasegPV.css({ 'width': '258px' });
    rCdsitpsgPV.css({ 'width': '120px' });
    rDdcancelPV.css({ 'width': '160px' });
    rDddcortePV.css({ 'width': '312px' });
    rDdmaxpagPV.css({ 'width': '160px' });
    rMmpripagPV.css({ 'width': '312px' });
    rQtdiacarPV.css({ 'width': '160px' });
    rQtmaxparPV.css({ 'width': '312px' });

    cDsmoradaPV = $('#dsmorada', '#frmInfPlano');
    cVlplasegPV = $('#vlplaseg', '#frmInfPlano');
    cDsocupacPV = $('#dsocupac', '#frmInfPlano');
    cNrtabelaPV = $('#nrtabela', '#frmInfPlano');
    cVlmoradaPV = $('#vlmorada', '#frmInfPlano');
    cFlgunicaPV = $('#flgunica', '#frmInfPlano');
    cInplasegPV = $('#inplaseg', '#frmInfPlano');
    cCdsitpsgPV = $('#cdsitpsg', '#frmInfPlano');
    cDdcancelPV = $('#ddcancel', '#frmInfPlano');
    cDddcortePV = $('#dddcorte', '#frmInfPlano');
    cDdmaxpagPV = $('#ddmaxpag', '#frmInfPlano');
    cMmpripagPV = $('#mmpripag', '#frmInfPlano');
    cQtdiacarPV = $('#qtdiacar', '#frmInfPlano');
    cQtmaxparPV = $('#qtmaxpar', '#frmInfPlano');

    cDsmoradaPV.css({ 'width': '415px' }).attr('maxlength', '50');
    cVlplasegPV.css({ 'width': '150px', 'text-align': 'right' }).setMask('DECIMAL', 'zzz.zzz.zzz.zz9,99', '.', '');
    cDsocupacPV.css({ 'width': '415px' }).attr('maxlength', '25');
    cNrtabelaPV.css({ 'width': '30px' }).addClass('inteiro').attr('maxlength', '2');
    cVlmoradaPV.css({ 'width': '150px', 'text-align': 'right' }).setMask('DECIMAL', 'zzz.zzz.zzz.zz9,99', '.', '');
    cFlgunicaPV.css({ 'width': '100px' });
    cInplasegPV.css({ 'width': '55px' });
    cCdsitpsgPV.css({ 'width': '100px' });
    cDdcancelPV.css({ 'width': '45px' }).addClass('inteiro').attr('maxlength', '2');
    cDddcortePV.css({ 'width': '45px' }).addClass('inteiro').attr('maxlength', '2');
    cDdmaxpagPV.css({ 'width': '45px' }).addClass('inteiro').attr('maxlength', '2');
    cMmpripagPV.css({ 'width': '45px' }).addClass('inteiro').attr('maxlength', '1');
    cQtdiacarPV.css({ 'width': '45px' }).addClass('inteiro').attr('maxlength', '3');
    cQtmaxparPV.css({ 'width': '45px' }).addClass('inteiro').attr('maxlength', '2');

    cDsmoradaPV.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        if (e.keyCode == 9 || e.keyCode == 13) {
            $(this).removeClass('campoErro');
            cVlplasegPV.focus();
            return false;
        }
    });

    cVlplasegPV.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {
            $(this).removeClass('campoErro');
            cDsocupacPV.focus();
            return false;
        }
    });

    cDsocupacPV.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {
            $(this).removeClass('campoErro');
            cNrtabelaPV.focus();
            return false;
        }
    });

    cNrtabelaPV.unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $(this).removeClass('campoErro');
            cVlmoradaPV.focus();
            return false;
        }
    });

    cVlmoradaPV.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {
            $(this).removeClass('campoErro');
            cFlgunicaPV.focus();
            return false;
        }
    });

    cFlgunicaPV.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {
            $(this).removeClass('campoErro');
            cInplasegPV.focus();
            return false;
        }
    });

    cInplasegPV.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {
            $(this).removeClass('campoErro');
            cCdsitpsgPV.focus();
            return false;
        }
    });

    cCdsitpsgPV.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {
            $(this).removeClass('campoErro');
            cDdcancelPV.focus();
            return false;
        }
    });

    cDdcancelPV.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {
            $(this).removeClass('campoErro');
            cDddcortePV.focus();
            return false;
        }
    });

    cDddcortePV.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {
            $(this).removeClass('campoErro');
            cDdmaxpagPV.focus();
            return false;
        }
    });

    cDdmaxpagPV.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {
            $(this).removeClass('campoErro');
            cMmpripagPV.focus();
            return false;
        }
    });

    cMmpripagPV.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {
            $(this).removeClass('campoErro');
            cQtdiacarPV.focus();
            return false;
        }
    });

    cQtdiacarPV.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {
            $(this).removeClass('campoErro');
            cQtmaxparPV.focus();
            return false;
        }
    });

    cQtmaxparPV.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {
            $(this).removeClass('campoErro');
            controlaOperacao();
            return false;
        }
    });

    highlightObjFocus($('#frmInfPlano'));

}

function formataCamposCasa() {
    rDsmoradaC = $('label[for="dsmorada"]', '#frmInfPlanoCasa');
    rVlplasegC = $('label[for="vlplaseg"]', '#frmInfPlanoCasa');
    rDsocupacC = $('label[for="dsocupac"]', '#frmInfPlanoCasa');
    rNrtabelaC = $('label[for="nrtabela"]', '#frmInfPlanoCasa');
    rFlgunicaC = $('label[for="flgunica"]', '#frmInfPlanoCasa');
    rInplasegC = $('label[for="inplaseg"]', '#frmInfPlanoCasa');
    rCdsitpsgC = $('label[for="cdsitpsg"]', '#frmInfPlanoCasa');
    rDdcancelC = $('label[for="ddcancel"]', '#frmInfPlanoCasa');
    rDddcorteC = $('label[for="dddcorte"]', '#frmInfPlanoCasa');
    rDdmaxpagC = $('label[for="ddmaxpag"]', '#frmInfPlanoCasa');
    rMmpripagC = $('label[for="mmpripag"]', '#frmInfPlanoCasa');
    rQtdiacarC = $('label[for="qtdiacar"]', '#frmInfPlanoCasa');
    rQtmaxparC = $('label[for="qtmaxpar"]', '#frmInfPlanoCasa');

    rDsmoradaC.css({ 'width': '120px' });
    rVlplasegC.css({ 'width': '120px' });
    rDsocupacC.css({ 'width': '120px' });
    rNrtabelaC.css({ 'width': '120px' });
    rFlgunicaC.css({ 'width': '120px' });
    rInplasegC.css({ 'width': '258px' });
    rCdsitpsgC.css({ 'width': '120px' });
    rDdcancelC.css({ 'width': '160px' });
    rDddcorteC.css({ 'width': '312px' });
    rDdmaxpagC.css({ 'width': '160px' });
    rMmpripagC.css({ 'width': '312px' });
    rQtdiacarC.css({ 'width': '160px' });
    rQtmaxparC.css({ 'width': '312px' });

    cDsmoradaC = $('#dsmorada', '#frmInfPlanoCasa');
    cVlplasegC = $('#vlplaseg2', '#frmInfPlanoCasa');
    cDsocupacC = $('#dsocupac', '#frmInfPlanoCasa');
    cNrtabelaC = $('#nrtabela', '#frmInfPlanoCasa');
    cFlgunicaC = $('#flgunica', '#frmInfPlanoCasa');
    cInplasegC = $('#inplaseg', '#frmInfPlanoCasa');
    cCdsitpsgC = $('#cdsitpsg', '#frmInfPlanoCasa');
    cDdcancelC = $('#ddcancel', '#frmInfPlanoCasa');
    cDddcorteC = $('#dddcorte', '#frmInfPlanoCasa');
    cDdmaxpagC = $('#ddmaxpag', '#frmInfPlanoCasa');
    cMmpripagC = $('#mmpripag', '#frmInfPlanoCasa');
    cQtdiacarC = $('#qtdiacar', '#frmInfPlanoCasa');
    cQtmaxparC = $('#qtmaxpar', '#frmInfPlanoCasa');

    cDsmoradaC.css({ 'width': '415px' }).attr('maxlength', '50').addClass('alphanum');
    cVlplasegC.css({ 'width': '150px', 'text-align': 'right' }).addClass('inteiro').setMask('DECIMAL', 'zzz.zzz.zzz.zz9,99', '.', '');
    cDsocupacC.css({ 'width': '415px' }).attr('maxlength', '25').addClass('alphanum');
    cNrtabelaC.css({ 'width': '30px' }).addClass('inteiro').attr('maxlength', '2');
    cFlgunicaC.css({ 'width': '100px' });
    cInplasegC.css({ 'width': '55px' });
    cCdsitpsgC.css({ 'width': '100px' });
    cDdcancelC.css({ 'width': '45px' }).attr('maxlength', '2').addClass('inteiro');
    cDddcorteC.css({ 'width': '45px' }).attr('maxlength', '2').addClass('inteiro');
    cDdmaxpagC.css({ 'width': '45px' }).attr('maxlength', '2').addClass('inteiro');
    cMmpripagC.css({ 'width': '45px' }).attr('maxlength', '1').addClass('inteiro');
    cQtdiacarC.css({ 'width': '45px' }).attr('maxlength', '3').addClass('inteiro');
    cQtmaxparC.css({ 'width': '45px' }).attr('maxlength', '2').addClass('inteiro');

    cDsmoradaC.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {
            cVlplasegC.focus();
            return false;
        }
    });

    cVlplasegC.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {
            $(this).removeClass('campoErro');
            cDsocupacC.focus();
            return false;
        }
    });

    cDsocupacC.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {
            $(this).removeClass('campoErro');
            cNrtabelaC.focus();
            return false;
        }
    });

    cNrtabelaC.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {
            cFlgunicaC.focus();
            return false;
        }
    });

    cFlgunicaC.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {
            $(this).removeClass('campoErro');
            cInplasegC.focus();
            return false;
        }
    });

    cInplasegC.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {
            cCdsitpsgC.focus();
            return false;
        }
    });

    cCdsitpsgC.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {
            $(this).removeClass('campoErro');
            cDdcancelC.focus();
            return false;
        }
    });

    cDdcancelC.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {
            $(this).removeClass('campoErro');
            cDddcorteC.focus();
            return false;
        }
    });

    cDddcorteC.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {
            $(this).removeClass('campoErro');
            cDdmaxpagC.focus();
            return false;
        }
    });

    cDdmaxpagC.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {
            $(this).removeClass('campoErro');
            cMmpripagC.focus();
            return false;
        }
    });

    cMmpripagC.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {
            $(this).removeClass('campoErro');
            cQtdiacarC.focus();
            return false;
        }
    });

    cQtdiacarC.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {
            $(this).removeClass('campoErro');
            cQtmaxparC.focus();
            return false;
        }
    });

    cQtmaxparC.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {
            $(this).removeClass('campoErro');
            controlaOperacao();
            return false;
        }
    });

    highlightObjFocus($('#frmInfPlanoCasa'));

}

function LiberaFormulario() {

    if ($('#cddopcao', '#frmCab').hasClass('campoTelaSemBorda')) {
        return false;
    }

    // Desabilita campo opção
    $('#cddopcao', '#frmCab').desabilitaCampo();

    cddopcao = $('#cddopcao', '#frmCab').val();

    formataCamposBuscaSeguradora();
    cTodosBuscaSeguradora = $('input[type="text"],select, input[type="checkbox"]', '#frmInfSeguradora');
    cTodosBuscaSeguradora.habilitaCampo();
    cNmresseg.desabilitaCampo();
    cTodosBuscaSeguradora.limpaFormulario();

    formataCamposPrestamistaVida();
    cTodosPrestamistaVida = $('input[type="text"],select, input[type="checkbox"]', '#frmInfPlano');
    cTodosPrestamistaVida.desabilitaCampo();
    cTodosPrestamistaVida.limpaFormulario();

    formataCamposCasa();
    cTodosCasa = $('input[type="text"],select, input[type="checkbox"]', '#frmInfPlanoCasa');
    cTodosCasa.desabilitaCampo();
    cTodosCasa.limpaFormulario();

    // Mostra form seguradora
    $('#frmInfSeguradora').css({ 'display': 'block' });

    // Verificar Tratamento botoes.
    $('#divBotoes', '#divTela').css({ 'display': 'block' });

    $("#btSalvar", "#divBotoes").show();
    $("#btVoltar", "#divBotoes").show();

    $('#cdsegura', '#frmInfSeguradora').unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {

            bo = 'b1wgen0033.p';
            procedure = 'Buscar_seguradora';
            titulo = 'Seguradoras';
            colunas = 'Codigo;cdsegura;20%;right|Seguradoras;nmresseg;50%;left';
            divRotina = $('#divTela');

            $(this).removeClass('campoErro');

            buscaDescricao(bo, procedure, titulo, $(this).attr('name'), 'nmresseg', normalizaNumero($(this).val()), 'nmresseg', '', 'frmInfSeguradora');

            return false;
        }
    });

    cTpseguro.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {
            $(this).removeClass('campoErro');
            cTpplaseg.focus();
            return false;
        }
    });

    cTpplaseg.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {
            $(this).removeClass('campoErro');
            controlaOperacao();
            return false;
        }
    }).unbind('keydown').bind('keydown', function (e) {

        if (divError.css('display') == 'block') { return false; }

        if (e.keyCode == 118) {
            $(this).removeClass('campoErro');
            controlaPesquisaTipoPlano();
            return false;
        }
    });

    layoutPadrao();
    cCdsegura.focus();

    return false;

}

function LiberaFormularioAtualizar() {

    if ($('#cddopcao', '#frmCab').hasClass('campoTelaSemBorda')) {
        return false;
    }

    // Desabilita campo opção
    $('#cddopcao', '#frmCab').desabilitaCampo();

    cddopcao = $('#cddopcao', '#frmCab').val();
    $('input', '#frmInfAtualiza').habilitaCampo().limpaFormulario();

    rTpseguro = $('label[for="tpseguro"]', '#frmInfAtualiza');
    rTpplaseg = $('label[for="tpplaseg"]', '#frmInfAtualiza');
    rNrtabela = $('label[for="nrtabela"]', '#frmInfAtualiza');
    rVlpercen = $('label[for="vlpercen"]', '#frmInfAtualiza');
    rDatdebit = $('label[for="datdebit"]', '#frmInfAtualiza');
    rDatdespr = $('label[for="datdespr"]', '#frmInfAtualiza');

    rTpseguro.css({ 'width': '110px' }).addClass('rotulo-linha');
    rTpplaseg.css({ 'width': '79px' }).addClass('rotulo-linha');
    rNrtabela.css({ 'width': '64px' }).addClass('rotulo-linha');
    rVlpercen.css({ 'width': '112px' }).addClass('rotulo');
    rDatdebit.css({ 'width': '80px' }).addClass('rotulo-linha');
    rDatdespr.css({ 'width': '310px' }).addClass('rotulo');

    cTpseguro = $('#tpseguro', '#frmInfAtualiza').css('width', '112px');
    cTpplaseg = $('#tpplaseg', '#frmInfAtualiza').css('width', '90px').addClass('inteiro').attr('maxlength', '3');
    cNrtabela = $('#nrtabela', '#frmInfAtualiza').css('width', '60px').addClass('inteiro').attr('maxlength', '2');
    cVlpercen = $('#vlpercen', '#frmInfAtualiza').css('width', '112px').addClass('porcento_4');
    cDatdebit = $('#datdebit', '#frmInfAtualiza').css('width', '90px').addClass('data');
    cDatdespr = $('#datdespr', '#frmInfAtualiza').css('width', '90px').addClass('data');

    highlightObjFocus($('#frmInfAtualiza'));

    // Mostra form seguradora
    $('#frmInfAtualiza').css({ 'display': 'block' });

    // Verificar Tratamento botoes.

    $('#divBotoes', '#divTela').css({ 'display': 'block' });

    $("#btProsseguir", "#divBotoes").show();

    $("#btVoltar", "#divBotoes").show();

    cTpseguro.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {
            $(this).removeClass('campoErro');
            cTpplaseg.focus();
            return false;
        }
    });

    cTpplaseg.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {
            $(this).removeClass('campoErro');
            cNrtabela.focus();
            return false;
        }
    }).unbind('keydown').bind('keydown', function (e) {

        if (divError.css('display') == 'block') { return false; }

        if (e.keyCode == 118) {
            $(this).removeClass('campoErro');
            controlaPesquisaTipoPlano();
            return false;
        }
    });

    cNrtabela.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {
            $(this).removeClass('campoErro');
            cVlpercen.focus();
            return false;
        }
    });

    cVlpercen.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {
            $(this).removeClass('campoErro');
            cDatdebit.focus();
            return false;
        }
    });

    cDatdebit.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {
            $(this).removeClass('campoErro');
            cDatdespr.focus();
            return false;
        }
    });

    cDatdespr.unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        if (e.keyCode == 9 || e.keyCode == 13) {
            $(this).removeClass('campoErro');
            controlaOperacao();
            return false;
        }
    });

    layoutPadrao();
    cTpplaseg.focus();
    cTpseguro.desabilitaCampo();
    return false;
}

function controlaPesquisaSeguradora() {

    // Se esta desabilitado o campo 
    if ($("#cdsegura", "#frmInfSeguradora").prop("disabled") == true) {
        return;
    }

    $('input,select', '#frmInfSeguradora').removeClass('campoErro');

    // Variável local para guardar o elemento anterior
    var campoAnterior = '';
    var bo, procedure, titulo, qtReg, filtros, colunas;

    //Remove a classe de Erro do form
    $('input,select', '#frmInfSeguradora').removeClass('campoErro');

    var cdsegura = $('#cdsegura', '#frmInfSeguradora').val();

    bo = 'b1wgen0033.p';
    procedure = 'Buscar_seguradora';
    titulo = 'Seguradoras';
    qtReg = '20';
    filtros = 'Codigo;cdsegura;80px;S;' + cdsegura + ';S|Descricao;nmresseg;280px;S;;S';
    colunas = 'Codigo;cdsegura;20%;right|Seguradoras;nmresseg;50%;left';
    mostraPesquisa(bo, procedure, titulo, qtReg, filtros, colunas, $('#divTela'), '$(\'#cdsegura\',\'#frmInfSeguradora\').val()');

    return false;
}

function controlaPesquisaTipoPlano() {

    // Se esta desabilitado o campo 
    if ($("#tpplaseg", "#frmInfSeguradora").prop("disabled") == true) {
        return;
    }

    $('input,select', '#frmInfSeguradora').removeClass('campoErro');

    // Variável local para guardar o elemento anterior
    var campoAnterior = '';
    var bo, procedure, titulo, qtReg, filtros, colunas;

    //Remove a classe de Erro do form
    $('input,select', '#frmInfSeguradora').removeClass('campoErro');

    var cdsegura = $('#cdsegura', '#frmInfSeguradora').val();
    var tpseguro = $('#tpseguro', '#frmInfSeguradora').val();
    var tpplaseg = $('#tpplaseg', '#frmInfSeguradora').val();

    bo = 'b1wgen0033.p';
    procedure = 'buscar_plano_seguro';
    titulo = 'Planos';
    qtReg = '20';
    filtros = 'Plano;tpplaseg;80px;S;' + tpplaseg + ';S|Descricao;dsmorada;280px;S;;S|;vlplaseg;;N;;N|;nrtabela;;N;;N|;cdsegura;;N;' + cdsegura + ';N|;tpseguro;;N;' + tpseguro + ';N';
    colunas = 'Plano;tpplaseg;20%;right|Descricao;dsmorada;50%;left|Premio;vlplaseg;20%;right|Tabela;nrtabela;20%;right';
    mostraPesquisa(bo, procedure, titulo, qtReg, filtros, colunas, $('#divTela'), '$(\'#tpplaseg\',\'#frmInfSeguradora\').val()');

    return false;
}


function consultaPlano() {

    showMsgAguardo('Aguarde, buscando ...');

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/altseg/buscar_plano_seguro.php',
        data: {
            cddopcao: cddopcao,
            cdsegura: normalizaNumero(cCdsegura.val()),
            tpseguro: cTpseguro.val(),
            tpplaseg: cTpplaseg.val(),
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {

            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground();");

        },
        success: function (response) {

            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    cTodosBuscaSeguradora.desabilitaCampo();
                    hideMsgAguardo();
                    if (cTpseguro.val() == "11" && cTpplaseg.val() != "" && cTpplaseg.val() != "0") {
                        eval(response);
                        cTpplaseg.removeClass('campoErro');

                        $('#frmInfPlanoCasa').css({ 'display': 'block' });
                        /*habilita campos para alteração*/
                        if (cddopcao == "A") {
                            cTodosCasa.habilitaCampo();
                        } else {
                            cTodosCasa.desabilitaCampo();
                        }
                        /*habilita campos para alteração*/

                        if (cddopcao == "C") {
                            $('#btSalvar', '#divBotoes').focus();
                        } else {
                            cDsmoradaC.focus();
                            $('#btSalvar', '#divBotoes').show();
                        }

                    } else if (cTpseguro.val() != "11" && cTpplaseg.val() != "" && cTpplaseg.val() != "0") {
                        eval(response);
                        $('#frmInfPlano').css({ 'display': 'block' });
                        cTpplaseg.removeClass('campoErro');
                        /*habilita campos para alteração*/
                        if (cddopcao == "A") {
                            cTodosPrestamistaVida.habilitaCampo();
                        } else {
                            cTodosPrestamistaVida.desabilitaCampo();
                        }
                        /*habilita campos para alteração*/
                        $('#btSalvar', '#divBotoes').hide();
                        if (cddopcao == "A") {
                            cDsmoradaPV.focus();
                            $('#btSalvar', '#divBotoes').show();

                        }

                    } else if (cTpplaseg.val() == "" || cTpplaseg.val() == "0") {
                        $('#btSalvar', '#divBotoes').hide();
                        formataTabPlanoSeguro();
                    } else {
                        eval(response);
                    }
                    return false;
                } catch (error) {
                    hideMsgAguardo();
                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "");
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

function btnVoltar() {
    estadoInicial();
    return false;
}

function controlaOperacao() {

    if (cTpplaseg.hasClass('campoTelaSemBorda')) {

        if (cddopcao == "C" && $('#frmInfPlanoCasa').css('display') == "block") {
            buscarGarantias();
            $('#frmInfPlanoCasa').css({ 'display': 'none' });
            $('#frmTabGarantia').css({ 'display': 'block' });
            $('#btSalvar', '#divBotoes').hide();

        } else if (cddopcao == "A") {
            showConfirmacao("078 - Confirma a opera&ccedil;&atilde;o?", "Confirma&ccedil;&atilde;o - Ayllos", "realizaOperacao();", "", "sim.gif", "nao.gif");
        } else if (cddopcao == "I") {
            showConfirmacao("078 - Confirma a opera&ccedil;&atilde;o?", "Confirma&ccedil;&atilde;o - Ayllos", "realizaOperacao();", "", "sim.gif", "nao.gif");
        } else if (cddopcao == "K") {

            showConfirmacao("Deseja emitir relat&oacute;rio?", "Confirma&ccedil;&atilde;o - Ayllos", "geraRelatorio();", "showConfirmacao(\"Deseja efetuar a atualiza&ccedil;&atilde;o?\", \"Confirma&ccedil;&atilde;o - Ayllos\", \"atualizarValor();\", \"\", \"sim.gif\", \"nao.gif\");", "sim.gif", "nao.gif");
        }
    } else {

        if (cddopcao == "C" || cddopcao == "A") {
            if (cddopcao == "C") {
                showConfirmacao("078 - Confirma a opera&ccedil;&atilde;o?", "Confirma&ccedil;&atilde;o - Ayllos", "consultaPlano();", "", "sim.gif", "nao.gif");
                return false;
            }
            if (cddopcao == "A" && cTpplaseg.val() != "" && cTpplaseg.val() != "0")
                showConfirmacao("078 - Confirma a opera&ccedil;&atilde;o?", "Confirma&ccedil;&atilde;o - Ayllos", "consultaPlano();", "", "sim.gif", "nao.gif");
            else
                showError("error", "Informe um Plano V&aacute;lido", "Alerta - Ayllos", "focaCampoErro('tpplaseg', 'frmInfSeguradora')");
        } else if (cddopcao == "I") {
            showConfirmacao("078 - Confirma a opera&ccedil;&atilde;o?", "Confirma&ccedil;&atilde;o - Ayllos", "validaExistePlanoSeguro();", "", "sim.gif", "nao.gif");

        } else if (cddopcao == "K") {
            showConfirmacao("078 - Confirma a opera&ccedil;&atilde;o?", "Confirma&ccedil;&atilde;o - Ayllos", "atualizarPercentual(1,400);", "", "sim.gif", "nao.gif");

        }

    }

}

function realizaOperacao() {

    // Mostra mensagem de aguardo.
    if (cInplasegC.val() == '1') {
        cInplasegC.val('1');
    } else {
        cInplasegC.val('0');
    }
    if (cInplasegPV.val() == '1') {
        cInplasegPV.val('1');
    } else {
        cInplasegPV.val('0');
    }

    if (cTpseguro.val() == "11") {
        dsmorada = cDsmoradaC.val();
        vlplaseg = cVlplasegC.val();
        dsocupac = cDsocupacC.val();
        nrtabela = cNrtabelaC.val();
        vlmorada = '';
        flgunica = cFlgunicaC.val();
        inplaseg = cInplasegC.val();
        cdsitpsg = cCdsitpsgC.val();
        ddcancel = cDdcancelC.val();
        dddcorte = cDddcorteC.val();
        ddmaxpag = cDdmaxpagC.val();
        mmpripag = cMmpripagC.val();
        qtdiacar = cQtdiacarC.val();
        qtmaxpar = cQtmaxparC.val();
    } else {
        dsmorada = cDsmoradaPV.val();
        vlplaseg = cVlplasegPV.val();
        dsocupac = cDsocupacPV.val();
        nrtabela = cNrtabelaPV.val();
        vlmorada = cVlmoradaPV.val();
        flgunica = cFlgunicaPV.val();
        inplaseg = cInplasegPV.val();
        cdsitpsg = cCdsitpsgPV.val();
        ddcancel = cDdcancelPV.val();
        dddcorte = cDddcortePV.val();
        ddmaxpag = cDdmaxpagPV.val();
        mmpripag = cMmpripagPV.val();
        qtdiacar = cQtdiacarPV.val();
        qtmaxpar = cQtmaxparPV.val();
    }

    if (cTpplaseg.val() == '' || cTpplaseg.val() == 0) {
        hideMsgAguardo();
        showError("error", "Informe o tipo de plano.", "Alerta - Ayllos", "focaCampoErro('tpplaseg', 'frmInfSeguradora')");
        return false;
    }

    if (cddopcao == "I") {
        showMsgAguardo("Aguarde, incluindo plano...");
    }
    else {
        showMsgAguardo("Aguarde, alterando plano...");
    }

    $('input,select', '#frmInfPlano').desabilitaCampo();
    $('input,select', '#frmInfPlanoCasa').desabilitaCampo();

    // Executa script de bloqueio através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/altseg/manter_rotina.php",
        data: {
            cddopcao: cddopcao,
            cdsegura: normalizaNumero(cCdsegura.val()),
            tpseguro: cTpseguro.val(),
            tpplaseg: cTpplaseg.val(),
            dsmorada: dsmorada,
            vlplaseg: vlplaseg,
            dsocupac: dsocupac,
            nrtabela: nrtabela,
            vlmorada: vlmorada,
            flgunica: flgunica,
            inplaseg: inplaseg,
            cdsitpsg: cdsitpsg,
            ddcancel: ddcancel,
            dddcorte: dddcorte,
            ddmaxpag: ddmaxpag,
            mmpripag: mmpripag,
            qtdiacar: qtdiacar,
            qtmaxpar: qtmaxpar,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "");
        },
        success: function (response) {

            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    hideMsgAguardo();
                    eval(response);
                    return false;
                } catch (error) {
                    hideMsgAguardo();
                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "");
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
}

function atualizarPercentual(nriniseq, nrregist) {

    var tpseguro = $('#tpseguro', '#frmInfAtualiza').val();
    var tpplaseg = $('#tpplaseg', '#frmInfAtualiza').val();
    var nrtabela = $('#nrtabela', '#frmInfAtualiza').val();
    var vlpercen = $('#vlpercen', '#frmInfAtualiza').val();
    var datdebit = $('#datdebit', '#frmInfAtualiza').val();
    var datdespr = $('#datdespr', '#frmInfAtualiza').val();

    $('input', '#frmInfAtualiza').desabilitaCampo();

    showMsgAguardo("Aguarde, atualizando...");

    // Executa script de bloqueio através de ajax
    $.ajax({
        type: "POST",
        dataType: 'html',
        url: UrlSite + "telas/altseg/atualizar_percentual.php",
        data: {
            cddopcao: cddopcao,
            tpseguro: tpseguro,
            tpplaseg: tpplaseg,
            nrtabela: nrtabela,
            datdespr: datdespr,
            datdebit: datdebit,
            vlpercen: vlpercen,
            nriniseq: nriniseq,
            nrregist: nrregist,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "");
        },
        success: function (response) {

            hideMsgAguardo();
            $("#divTabela").html(response);

        }
    });
}

function atualizarValor() {

    var tpseguro = $('#tpseguro', '#frmInfAtualiza').val();
    var tpplaseg = $('#tpplaseg', '#frmInfAtualiza').val();
    var nrtabela = $('#nrtabela', '#frmInfAtualiza').val();
    var vlpercen = $('#vlpercen', '#frmInfAtualiza').val();
    var datdebit = $('#datdebit', '#frmInfAtualiza').val();
    var datdespr = $('#datdespr', '#frmInfAtualiza').val();

    $('input', '#frmInfAtualiza').desabilitaCampo();

    showMsgAguardo("Aguarde, atualizando...");

    // Executa script de bloqueio através de ajax
    $.ajax({
        type: "POST",
        dataType: 'html',
        url: UrlSite + "telas/altseg/atualizar_valor_seguro.php",
        data: {
            cddopcao: cddopcao,
            tpseguro: tpseguro,
            tpplaseg: tpplaseg,
            nrtabela: nrtabela,
            datdespr: datdespr,
            datdebit: datdebit,
            vlpercen: vlpercen,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "");
        },
        success: function (response) {

            hideMsgAguardo();
            eval(response);

        }
    });
}

function geraRelatorio() {

    var tpseguro = $('#tpseguro', '#frmInfAtualiza').val();
    var tpplaseg = $('#tpplaseg', '#frmInfAtualiza').val();
    var nrtabela = $('#nrtabela', '#frmInfAtualiza').val();
    var vlpercen = $('#vlpercen', '#frmInfAtualiza').val();
    var datdebit = $('#datdebit', '#frmInfAtualiza').val();
    var datdespr = $('#datdespr', '#frmInfAtualiza').val();

    $('input', '#frmInfAtualiza').desabilitaCampo();

    showMsgAguardo("Aguarde, gerando relat&oacute;rio...");

    // Executa script de bloqueio através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/altseg/imprimir_relatorio.php",
        data: {
            cddopcao: cddopcao,
            tpseguro: tpseguro,
            tpplaseg: tpplaseg,
            nrtabela: nrtabela,
            datdespr: datdespr,
            datdebit: datdebit,
            vlpercen: vlpercen,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "");
        },
        success: function (response) {

            hideMsgAguardo();
            eval(response);

        }
    });
}

function Gera_Impressao(nmarqpdf, callback) {

    hideMsgAguardo();

    var action = UrlSite + 'telas/altseg/imprimir_pdf.php';

    $('#nmarqpdf', '#frmCab').remove();
    $('#sidlogin', '#frmCab').remove();

    $('#frmCab').append('<input type="hidden" id="nmarqpdf" name="nmarqpdf" value="' + nmarqpdf + '" />');
    $('#frmCab').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin', '#frmMenu').val() + '" />');

    carregaImpressaoAyllos("frmCab", action, callback);

}

//formata tabela de planos
function formataTabPlanoSeguro() {

    var divRegistro = $('div.divRegistros', '#divTabPlanosSeguradora');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '119px';
    arrayLargura[1] = '198px';
    arrayLargura[2] = '143px';
    arrayLargura[3] = '105px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'right';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'right';

    var metodoTabela = '';
    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

}

function formataTabAtualizar() {

    var divRegistro = $('div.divRegistros', '#divTabAtualizarPlano');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '70px';
    arrayLargura[1] = '80px';
    arrayLargura[2] = '100px';
    arrayLargura[3] = '100px';
    arrayLargura[4] = '80px';


    var arrayAlinha = new Array();
    arrayAlinha[0] = 'right';
    arrayAlinha[1] = 'right';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'right';
    arrayAlinha[4] = 'right';
    arrayAlinha[5] = 'right';

    var metodoTabela = '';
    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

}

function buscarGarantias() {

    showMsgAguardo("Aguarde, buscando Garantias ...");
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/altseg/buscar_garantias.php",
        data: {
            cddopcao: cddopcao,
            cdsegura: normalizaNumero(cCdsegura.val()),
            tpseguro: cTpseguro.val(),
            tpplaseg: cTpplaseg.val(),
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        success: function (response) {
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    $('#divTabGarantias').html(response);
                    formataTabGarantias();
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

            hideMsgAguardo();
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "$('#nrdconta','#frmCabAtenda').focus()");
        }
    });
}

function formataTabGarantias() {

    var divRegistro = $('div.divRegistros', '#divTabGarantia');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '185px';
    arrayLargura[1] = '100px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'left';
    arrayAlinha[1] = 'right';
    arrayAlinha[2] = 'left';

    var metodoTabela = '';
    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

}

function validaExistePlanoSeguro() {

    showMsgAguardo('Aguarde, buscando ...');

    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/altseg/valida_existe_plano_seguro.php',
        data: {
            cddopcao: cddopcao,
            cdsegura: normalizaNumero(cCdsegura.val()),
            tpseguro: cTpseguro.val(),
            tpplaseg: cTpplaseg.val(),
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {


            showError('error', 'Não foi possível concluir a requisição.', 'Alerta - Ayllos', "unblockBackground();");
        },
        success: function (response) {

            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {
                    cTodosBuscaSeguradora.desabilitaCampo();
                    if (cTpseguro.val() == "11") {
                        $('#frmInfPlanoCasa').css({ 'display': 'block' });
                        hideMsgAguardo();
                        cTodosCasa.habilitaCampo();
                        cDsmoradaC.focus();
                    } else {
                        $('#frmInfPlano').css({ 'display': 'block' });
                        hideMsgAguardo();
                        cTodosPrestamistaVida.habilitaCampo();
                        cDsmoradaPV.focus();
                    }
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

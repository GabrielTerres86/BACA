/***********************************************************************
 Fonte: lcredi.js                                                  
 Autor: Andrei - RKAM
 Data : JULHO/2016                Última Alteração: 10/07/2018
                                                                   
 Objetivo  : Cadastro de servicos ofertados na tela LCREDI
                                                                   	 
 Alterações:  10/08/2016 - Ajuste referente a homologação da área de negócio
                           (Andrei - RKAM)

              27/03/2017 - Inclusao dos campos Produto e Indexador.
                           (Jaison/James - PRJ298)

 			  10/10/2017 - Inclusao do campos % Mínimo Garantia e adicionado opção 4 no campo Modelo. (Lombardi - PRJ404)

              28/05/2018 - Aumentado o limite de 3 para 4 o campo Grupo. (Andrey Formigari- Mout's)
              
              10/07/2018 - sctask0014375 uso da funcao removeCaracteresInvalidos (Carlos)
					  03/2019 - Projeto 437 AMcom JDB

************************************************************************/

var RegLinha = new Object();

$(document).ready(function() {	
	
	estadoInicial();
		
});

function estadoInicial() {
    
    //Inicializa o array
    RegLinha = new Object();

    formataCabecalho();

    $('#cddopcao', '#frmCab').habilitaCampo().focus().val('C');
    $('#divBotoes').css({ 'display': 'none' });
    $('#frmFiltro').css('display', 'none');
    $('#divTabela').html('').css('display','none');
       	
}


function formataCabecalho() {

    // rotulo
    $('label[for="cddopcao"]', "#frmCab").addClass("rotulo").css({ "width": "45px" });

    // campo
    $("#cddopcao", "#frmCab").css("width", "530px").habilitaCampo();

    $('#divTela').css({ 'display': 'block' }).fadeTo(0, 0.1);
    removeOpacidade('divTela');
    $('#frmCab').css({ 'display': 'block' });
    highlightObjFocus($('#frmCab'));

    $('input[type="text"],select', '#frmCab').limpaFormulario().removeClass('campoErro');

    //Define ação para ENTER e TAB no campo Opção
    $("#cddopcao", "#frmCab").unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) {

            montaFormFiltro();

            return false;

        }

    });

    //Define ação para CLICK no botão de OK
    $("#btnOK", "#frmCab").unbind('click').bind('click', function () {

        // Se esta desabilitado o campo 
        if ($("#cddopcao", "#frmCab").prop("disabled") == true) {
            return false;
        }

        montaFormFiltro();

        $(this).unbind('click');

        return false;
        
    });

    layoutPadrao();

    return false;
}

function formataFiltro() {

    // Desabilitar a opção
    $("#cddopcao", "#frmCab").desabilitaCampo();
    
    //rotulo
    $('label[for="cdlcremp"]', "#frmFiltro").addClass("rotulo").css({ "width": "100px" });
   
    // campo
    $('#cdlcremp', '#frmFiltro').addClass('inteiro').css({ 'width': '80px', 'text-align': 'right' }).attr('maxlength', '5').habilitaCampo();
    
    $('#frmFiltro').css({ 'display': 'block' });
    $('#divBotoes').css({ 'display': 'block' });
    $('#btConcluir', '#divBotoes').css({ 'display': 'none' });
    $('#btProsseguir', '#divBotoes').css({ 'display': 'inline' });
    $('#btVoltar', '#divBotoes').css({ 'display': 'inline' });
    
    highlightObjFocus($('#frmFiltro'));   
    
    // Se pressionar cdlcremp
    $('#cdlcremp', '#frmFiltro').unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            $("#btProsseguir", "#divBotoes").click();

            return false;

        }

    });

    //Define ação para CLICK no botão de Concluir
    $("#btProsseguir", "#divBotoes").unbind('click').bind('click', function () {

        consultaLinhaCredito('1','30');

    });

    //Define ação para CLICK no botão de Voltar
    $("#btVoltar", "#divBotoes").unbind('click').bind('click', function () {

        controlaVoltar('1');

        return false;

    });

    $("#cdlcremp", "#frmFiltro").focus();

    layoutPadrao();

}

function formataFormularioConsulta() {

    highlightObjFocus($('#frmConsulta'));  

    //rotulo
    $('label[for="tpprodut"]', "#frmConsulta").addClass("rotulo").css({ "width": "150px" });
    $('label[for="dslcremp"]', "#frmConsulta").addClass("rotulo").css({ "width": "150px" });
    $('label[for="dsoperac"]', "#frmConsulta").addClass("rotulo").css({ "width": "150px" });
    $('label[for="tplcremp"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "70px" });
    $('label[for="tpdescto"]', "#frmConsulta").addClass("rotulo").css({ "width": "150px" });
    $('label[for="tpctrato"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "70px" });
    $('label[for="nrdevias"]', "#frmConsulta").addClass("rotulo").css({ "width": "150px" });
    $('label[for="permingr"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "235px" });
    $('label[for="flgrefin"]', "#frmConsulta").addClass("rotulo").css({ "width": "150px" });
    $('label[for="flgreneg"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "130px" });
    $('label[for="cdusolcr"]', "#frmConsulta").addClass("rotulo").css({ "width": "150px" });
    $('label[for="flgtarif"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "130px" });
    $('label[for="flgtaiof"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "30px" });
    $('label[for="vltrfesp"]', "#frmConsulta").addClass("rotulo").css({ "width": "150px" });
    $('label[for="flgcrcta"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "130px" });
    $('label[for="manterpo"]', "#frmConsulta").addClass("rotulo").css({ "width": "150px" });
    $('label[for="flgimpde"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "130px" });
    $('label[for="dsorgrec"]', "#frmConsulta").addClass("rotulo").css({ "width": "150px" });
	$('label[for="tpmodcon"]', "#frmConsulta").addClass("rotulo").css({ "width": "150px" });
    $('label[for="flglispr"]', "#frmConsulta").addClass("rotulo").css({ "width": "150px" });
    $('label[for="dssitlcr"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "130px" });
    $('label[for="cdmodali"]', "#frmConsulta").addClass("rotulo").css({ "width": "150px" });
    $('label[for="cdsubmod"]', "#frmConsulta").addClass("rotulo").css({ "width": "150px" });

    $('label[for="cddindex"]', "#frmConsulta").addClass("rotulo").css({ "width": "150px" });
    $('label[for="txjurfix"]', "#frmConsulta").addClass("rotulo").css({ "width": "150px" });
    $('label[for="txjurvar"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "180px" });
    $('label[for="txjurvarDesc"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "70px" });
    $('label[for="txpresta"]', "#frmConsulta").addClass("rotulo").css({ "width": "150px" });
    $('label[for="txminima"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "180px" });
    $('label[for="txmaxima"]', "#frmConsulta").addClass("rotulo").css({ "width": "150px" });
    $('label[for="txmensal"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "180px" });
    $('label[for="txdiaria"]', "#frmConsulta").addClass("rotulo").css({ "width": "150px" });
    $('label[for="txbaspre"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "180px" });
    $('label[for="nrgrplcr"]', "#frmConsulta").addClass("rotulo").css({ "width": "150px" });
    $('label[for="qtcarenc"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "180px" });
    $('label[for="perjurmo"]', "#frmConsulta").addClass("rotulo").css({ "width": "150px" });
    $('label[for="vlmaxass"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "180px" });
    $('label[for="consaut"]',  "#frmConsulta").addClass("rotulo").css({ "width": "150px" });
    $('label[for="vlmaxasj"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "180px" });
    $('label[for="nrinipre"]', "#frmConsulta").addClass("rotulo").css({ "width": "150px" });
    $('label[for="nrfimpre"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "20px" });
    $('label[for="qtdcasas"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "65px" });
    $('label[for="qtrecpro"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "140px" });
                                    
    $('label[for="flgdisap"]', "#frmConsulta").addClass("rotulo").css({ "width": "150px" });
    $('label[for="flgcobmu"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "180px" });
    $('label[for="flgsegpr"]', "#frmConsulta").addClass("rotulo").css({ "width": "150px" });
    $('label[for="cdhistor"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "180px" });
        
    $('label[for="cdfinemp"]', "#frmConsulta").addClass("rotulo").css({ width: '150px' });
    $('label[for="dsfinemp"]', "#frmConsulta").addClass("rotulo-linha").css({ width: '200px' });

    // campo
    $("#tpprodut", "#frmConsulta").css({ 'width': '445px' }).desabilitaCampo();
    $("#dslcremp", "#frmConsulta").css({ 'width': '445px', 'text-align': 'left' }).addClass('alphanum').attr('maxlength', '30').desabilitaCampo();
    $('#dsoperac', '#frmConsulta').css({ 'width': '200px', 'text-align': 'left' }).addClass('alphanum').attr('maxlength', '29').desabilitaCampo();
    $('#tplcremp', '#frmConsulta').css({ 'width': '170px', 'text-align': 'left' }).desabilitaCampo(); 
    $('#tpdescto', '#frmConsulta').css({ 'width': '200px', 'text-align': 'left' }).desabilitaCampo(); 
    $('#tpctrato', '#frmConsulta').css({ 'width': '170px', 'text-align': 'left' }).desabilitaCampo(); 
    $('#nrdevias', '#frmConsulta').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '1');
    $('#permingr', '#frmConsulta').css({ 'width': '105px', 'text-align': 'right' }).desabilitaCampo().css('text-align', 'right').setMask('DECIMAL','zz9,99','.','');
    $('#flgrefin', '#frmConsulta').css({ 'width': '100px', 'text-align': 'left' }).desabilitaCampo(); 
    $('#flgreneg', '#frmConsulta').css({ 'width': '100px', 'text-align': 'left' }).desabilitaCampo(); 
    $('#cdusolcr', '#frmConsulta').css({ 'width': '100px', 'text-align': 'left' }).desabilitaCampo(); 
    $('#flgtarif', '#frmConsulta').css({ 'width': '100px', 'text-align': 'left' }).desabilitaCampo(); 
    $('#flgtaiof', '#frmConsulta').css({ 'width': '80px', 'text-align': 'left' }).desabilitaCampo(); 
    $('#vltrfesp', '#frmConsulta').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '10').setMask("DECIMAL", "zzz.zz9,99", "", "");
    $('#flgcrcta', '#frmConsulta').css({ 'width': '100px', 'text-align': 'left' }).desabilitaCampo(); 
    $('#manterpo', '#frmConsulta').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '4'); 
    $('#flgimpde', '#frmConsulta').css({ 'width': '100px', 'text-align': 'left' }).desabilitaCampo();
    $('#dsorgrec', '#frmConsulta').css({ 'width': '335px', 'text-align': 'left' }).desabilitaCampo();
	$('#tpmodcon', '#frmConsulta').css({ 'width': '100px', 'text-align': 'left' }).desabilitaCampo();
    $('#flglispr', '#frmConsulta').css({ 'width': '100px', 'text-align': 'left' }).desabilitaCampo();
    $('#dssitlcr', '#frmConsulta').css({ 'width': '215px', 'text-align': 'left' }).desabilitaCampo();
    $('#cdmodali', '#frmConsulta').css({ 'width': '60px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '5').setMask("INTEGER", "zzzzz", "", "");
    $('#dsmodali', '#frmConsulta').css({ 'width': '370px', 'text-align': 'left' }).addClass('alphanum').attr('maxlength', '50').desabilitaCampo();
    $('#cdsubmod', '#frmConsulta').css({ 'width': '60px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '5').setMask("INTEGER", "zzzzz", "", "");
    $('#dssubmod', '#frmConsulta').css({ 'width': '370px', 'text-align': 'left' }).addClass('alphanum').attr('maxlength', '50').desabilitaCampo();

    $('#cddindex', '#frmConsulta').css({ 'width': '100px' }).desabilitaCampo();
    $('#txjurfix', '#frmConsulta').css({ 'width': '100px', 'text-align': 'right' }).addClass('porcento_n').attr('maxlength', '6').desabilitaCampo();
    $('#txjurvar', '#frmConsulta').css({ 'width': '100px', 'text-align': 'right' }).addClass('porcento_n').attr('maxlength', '6').desabilitaCampo();
    $('#txpresta', '#frmConsulta').css({ 'width': '100px', 'text-align': 'right' }).addClass('porcento_n').attr('maxlength', '6').desabilitaCampo();
    $('#txminima', '#frmConsulta').css({ 'width': '100px', 'text-align': 'right' }).addClass('porcento_n').attr('maxlength', '6').desabilitaCampo();
    $('#txmaxima', '#frmConsulta').css({ 'width': '100px', 'text-align': 'right' }).addClass('porcento_n').attr('maxlength', '6').desabilitaCampo();
    $('#txmensal', '#frmConsulta').css({ 'width': '100px', 'text-align': 'right' }).addClass('porcento_6').attr('maxlength', '10').desabilitaCampo();
    $('#txdiaria', '#frmConsulta').css({ 'width': '100px', 'text-align': 'right' }).addClass('porcento_7').attr('maxlength', '11').desabilitaCampo();
    $('#txbaspre', '#frmConsulta').css({ 'width': '100px', 'text-align': 'right' }).addClass('porcento_n').attr('maxlength', '6').desabilitaCampo();
    $('#nrgrplcr', '#frmConsulta').css({ 'width': '100px', 'text-align': 'right' }).addClass('inteiro').attr('maxlength', '4').desabilitaCampo();
    $('#qtcarenc', '#frmConsulta').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '5').setMask("INTEGER", "zzzzz", "", "");
    $('#perjurmo', '#frmConsulta').css({ 'width': '100px', 'text-align': 'right' }).addClass('porcento_6').attr('maxlength', '10').desabilitaCampo();
    $('#vlmaxass', '#frmConsulta').css({ 'width': '140px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '14').setMask("DECIMAL", "zzz.zzz.zz9,99", "", "");
    $('#consaut',  '#frmConsulta').css({ 'width': '100px', 'text-align': 'left' }).desabilitaCampo();
    $('#vlmaxasj', '#frmConsulta').css({ 'width': '140px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '14').setMask("DECIMAL", "zzz.zzz.zz9,99", "", "");
    $('#nrinipre', '#frmConsulta').css({ 'width': '40px', 'text-align': 'right' }).addClass('inteiro').attr('maxlength', '2').desabilitaCampo();
    $('#nrfimpre', '#frmConsulta').css({ 'width': '60px', 'text-align': 'right' }).addClass('inteiro').attr('maxlength', '3').desabilitaCampo();
    $('#qtdcasas', '#frmConsulta').css({ 'width': '40px', 'text-align': 'right' }).addClass('inteiro').attr('maxlength', '1').desabilitaCampo();
    $('#qtrecpro', '#frmConsulta').css({ 'width': '65px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '6').setMask("DECIMAL", "zz9,99", "", "");
                       
    $('#flgdisap', '#frmConsulta').css({ 'width': '70px', 'text-align': 'left' }).desabilitaCampo(); 
    $('#flgcobmu', '#frmConsulta').css({ 'width': '70px', 'text-align': 'left' }).desabilitaCampo(); 
    $('#flgsegpr', '#frmConsulta').css({ 'width': '70px', 'text-align': 'left' }).desabilitaCampo(); 
    $('#cdhistor', '#frmConsulta').css('width', '50px').addClass('inteiro').attr('maxlength', '4');

    $('#cdfinemp', '#frmConsulta').css({ width: '70px' }).habilitaCampo().addClass('campo pesquisa').setMask('INTEGER', 'zzzzzzzzz9');
    $('#dsfinemp', '#frmConsulta').css({ width: '250px' }).desabilitaCampo().addClass('campo');

    $('#frmConsulta').css({ 'display': 'block' });
    $('#divBotoesConsulta').css('display', 'block');
    $('#btVoltar', '#divBotoesConsulta').css({ 'display': 'inline' });

    //Define ação para o campo tpprodut
    $("#tpprodut", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo dslcremp
    $("#dslcremp", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo dsoperac
    $("#dsoperac", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo tplcremp
    $("#tplcremp", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo tpdescto
    $("#tpdescto", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo tpctrato
    $("#tpctrato", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo tpctrato
    $('#tpctrato', '#frmConsulta').unbind('change').bind('change', function () {

        if ($(this).val() == 4) {
            $("#permingr", "#frmConsulta").val('100,00').habilitaCampo();
        } else {
			$("#permingr", "#frmConsulta").val('0,00').desabilitaCampo();
		}
    });
	
    //Define ação para o campo nrdevias
    $("#nrdevias", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

	//Define ação para o campo permingr
    $("#permingr", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo flgrefin
    $("#flgrefin", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo flgreneg
    $("#flgreneg", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo cdusolcr
    $('#cdusolcr', '#frmConsulta').unbind('change').bind('change', function () {

        if ($(this).val() == 0) {

            $("#flgimpde", "#frmConsulta").desabilitaCampo();
            $("#dsorgrec", "#frmConsulta").desabilitaCampo();            

        } else if ($(this).val() == 1) {

            $("#flgimpde", "#frmConsulta").habilitaCampo();
            $("#dsorgrec", "#frmConsulta").habilitaCampo();

        } else {

            $("#dsorgrec", "#frmConsulta").desabilitaCampo();
            $("#flgimpde", "#frmConsulta").habilitaCampo();

        }
        
    });

    //Define ação para o campo cdusolcr
    $("#cdusolcr", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            if ($(this).val() == 0) {

                $("#flgimpde", "#frmConsulta").desabilitaCampo();
                $("#dsorgrec", "#frmConsulta").desabilitaCampo();

            } else if ($(this).val() == 1) {

                $("#flgimpde", "#frmConsulta").habilitaCampo();
                $("#dsorgrec", "#frmConsulta").habilitaCampo();
               
            } else {

                $("#dsorgrec", "#frmConsulta").desabilitaCampo();
                $("#flgimpde", "#frmConsulta").habilitaCampo();


            }
            
            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo flgtarif
    $("#flgtarif", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo flgtaiof
    $("#flgtaiof", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo vltrfesp
    $("#vltrfesp", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    /*Ao alterar este campo deve ser solicitado a senha de cordenador.*/
    //Define ação para o campo flgcrcta
    $('#flgcrcta', '#frmConsulta').unbind('change').bind('change', function () {

        if ($('#cddopcao', '#frmCab').val() == 'A') {

            pedeSenhaCoordenador(2, "unblockBackground();", '');
		
            //Define ação para CLICK no botão de Concluir
            $("#btConcluir", "#divBotoesConsulta").unbind('click').bind('click', function () {
                                
                pedeSenhaCoordenador(2, 'showConfirmacao(\'Deseja confirmar a opera&ccedil;&atilde;o?\', \'Confirma&ccedil;&atilde;o - Ayllos\', \'alterarLinhaCredito();\', \'\', \'sim.gif\', \'nao.gif\');', '');
                
            });

        }else{
			
            pedeSenhaCoordenador(3, "unblockBackground();", '');
			
		}

        ($(this).val() == 0) ? $('#cdhistor', '#frmConsulta').habilitaCampo() : $('#cdhistor', '#frmConsulta').desabilitaCampo();

    });

    //Define ação para o campo flgcrcta
    $("#flgcrcta", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();
            
            return false;
        }

    });

    //Define ação para o campo manterpo
    $("#manterpo", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });
    //Define ação para o campo flgimpde
    $("#flgimpde", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });
    //Define ação para o campo dsorgrec
    $("#dsorgrec", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });
    //Define ação para o campo flglispr
    $("#flglispr", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo cdmodali
    $("#cdmodali", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });
	
	$("#cdmodali", "#frmConsulta").change(function() {
		if (($('#cdmodali', "#frmConsulta").val() == '02') && ($('#cdsubmod', "#frmConsulta").val() == '02')) {
			$('#tpmodcon', '#frmConsulta').habilitaCampo();
		}else{
			$('#tpmodcon', '#frmConsulta').desabilitaCampo();
			$('#tpmodcon', '#frmConsulta').val('') ;
		}
	});

    // Se pressionar cdmodali
    $('#cdmodali', '#frmConsulta').unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            bo = 'tela_lrotat';
            procedure = 'BUSCAMOD';
            titulo = 'Modalidades';
            qtReg = '30';

            $(this).removeClass('campoErro');
            buscaDescricao(bo, procedure, titulo, 'cdmodali', 'dsmodali', $('#cdmodali', '#frmConsulta').val(), 'dsmodali', 'nriniseq|1;nrregist|30', 'frmConsulta');

            $('#cdmodali', '#frmConsulta').focus();

            return false;

        }

    });
	
    //Define ação para o campo cdsubmod
    $("#cdsubmod", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });
	
	
	$("#cdsubmod", "#frmConsulta").change(function() {
		if (($('#cdmodali', "#frmConsulta").val() == '02') && ($('#cdsubmod', "#frmConsulta").val() == '02')) {
			$('#tpmodcon', '#frmConsulta').habilitaCampo();
		}else{
			$('#tpmodcon', '#frmConsulta').desabilitaCampo();
			$('#tpmodcon', '#frmConsulta').val('') ;
		}
	});

    // Se pressionar cdsubmod
    $('#cdsubmod', '#frmConsulta').unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            bo = 'tela_lrotat';
            procedure = 'BUSCASUBMOD';
            titulo = 'Submodalidades';
            qtReg = '30';
            filtrosDesc = 'cdmodali|' + $('#cdmodali', '#frmConsulta').val() + ';nriniseq|1;nrregist|30';

            $(this).removeClass('campoErro');
            buscaDescricao(bo, procedure, titulo, 'cdsubmod', 'dssubmod', $('#cdsubmod', '#frmConsulta').val(), 'dssubmod', filtrosDesc, 'frmConsulta');
			
			if (($('#cdmodali', "#frmConsulta").val() == '02') && ($('#cdsubmod', "#frmConsulta").val() == '02')) {
				$('#tpmodcon', '#frmConsulta').habilitaCampo();
			}else{
				$('#tpmodcon', '#frmConsulta').desabilitaCampo();
				$('#tpmodcon', '#frmConsulta').val('') ;
			}
			
            $(this).focus();

            return false;

        }

    });

    //Define ação para o campo cddindex
    $("#cddindex", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo txjurfix
    $('#txjurfix', '#frmConsulta').unbind('change').bind('change', function () {

        calculaTaxas($(this).attr('name'));
    });

    //Define ação para o campo txjurfix
    $("#txjurfix", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo txjurvar
    $('#txjurvar', '#frmConsulta').unbind('change').bind('change', function () {

        calculaTaxas($(this).attr('name'));
    });

    //Define ação para o campo txjurvar
    $("#txjurvar", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo txpresta
    $("#txpresta", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo txminima
    $("#txminima", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo txmaxima
    $("#txmaxima", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo txbaspre
    $("#txbaspre", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo nrgrplcr
    $("#nrgrplcr", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo qtcarenc
    $("#qtcarenc", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo perjurmo
    $("#perjurmo", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo vlmaxass
    $("#vlmaxass", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo consaut
    $("#consaut", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo vlmaxasj
    $("#vlmaxasj", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo nrinipre
    $("#nrinipre", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo nrfimpre
    $("#nrfimpre", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo qtdcasas
    $("#qtdcasas", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo qtrecpro
    $("#qtrecpro", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo qtrecpro
    $("#qtrecpro", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });
        
    //Define ação para o campo flgdisap
    $("#flgdisap", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo flgcobmu
    $("#flgcobmu", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo flgsegpr
    $("#flgsegpr", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            ($("#cdhistor", "#frmConsulta").hasClass('campo')) ? $(this).nextAll('.campo:first').focus() : $("#btConcluir", "#divBotoesConsulta").click();
            return false;
        }

    });

    //Define ação para o campo cdhistor
    $("#cdhistor", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $("#btConcluir", "#divBotoesConsulta").click();

            return false;
        }

    });

    // Se pressionar cdfinemp
    $('#cdfinemp', '#frmConsulta').unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            bo = 'zoom0001';
            procedure = 'BUSCAFINEMPR';
            titulo = 'Finalidade do Empr&eacutestimo';
            qtReg = '30';
            filtrosDesc = 'flgstfin|3;nriniseq|1;nrregist|30';

            $(this).removeClass('campoErro');
            buscaDescricao(bo, procedure, titulo, 'cdfinemp', 'dsfinemp', $('#cdfinemp', '#frmConsulta').val(), 'dsfinemp', filtrosDesc, 'frmConsulta');

            $(this).focus();

            return false;

        }

    });

    //Define ação para CLICK no botão de Concluir
    $("#btConcluir", "#divBotoesConsulta").unbind('click').bind('click', function () {

        if ($('#cddopcao', '#frmCab').val() == 'B' || $('#cddopcao', '#frmCab').val() == 'L') {

            showConfirmacao('Deseja confirmar a opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'bloqueiaLiberaLinha();', '$(\'#btVoltar\',\'#divBotoesConsulta\').focus();', 'sim.gif', 'nao.gif');

        } else if ($('#cddopcao', '#frmCab').val() == 'E') {

            showConfirmacao('Deseja confirmar a opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'excluirLinhaCredito();', '$(\'#btVoltar\',\'#divBotoesConsulta\').focus();', 'sim.gif', 'nao.gif');

        } else if ($('#cddopcao', '#frmCab').val() == 'I') {

            // Se for necessário solicitar senha do coordenador
            if ($("#flgcrcta", "#frmConsulta").val() == '0') {
                pedeSenhaCoordenador(3, 'showConfirmacao(\'Deseja confirmar a opera&ccedil;&atilde;o?\', \'Confirma&ccedil;&atilde;o - Ayllos\', \'incluirLinhaCredito();\', \'\', \'sim.gif\', \'nao.gif\');', '');
                
            } else {
                showConfirmacao('Deseja confirmar a opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'incluirLinhaCredito();', '$(\'#btVoltar\',\'#divBotoesConsulta\').focus();', 'sim.gif', 'nao.gif');
               
            }

        } else if ($('#cddopcao', '#frmCab').val() == 'A') {

            showConfirmacao('Deseja confirmar a opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'alterarLinhaCredito();', '$(\'#btVoltar\',\'#divBotoesConsulta\').focus();', 'sim.gif', 'nao.gif');

        } 

    });

    //Define ação para CLICK no botão de Voltar
    $("#btVoltar", "#divBotoesConsulta").unbind('click').bind('click', function () {

        controlaVoltar('2');

        return false;

    });

    
    layoutPadrao();
    exibeFieldIndexador();

    if ($('#cddopcao', '#frmCab').val() == 'C' ||
        $('#cddopcao', '#frmCab').val() == 'F' ||
        $('#cddopcao', '#frmCab').val() == 'P') {

        $('input,select', '#frmConsulta').desabilitaCampo();

        $('#btConcluir', '#divBotoesConsulta').css({ 'display': 'none' });

    } else if ($('#cddopcao', '#frmCab').val() == 'B' ||
               $('#cddopcao', '#frmCab').val() == 'E' ||
               $('#cddopcao', '#frmCab').val() == 'L' ){

        $('input,select', '#frmConsulta').desabilitaCampo();

    } else if ($('#cddopcao', '#frmCab').val() == 'A' ||
               $('#cddopcao', '#frmCab').val() == 'I'){

        $('input,select', '#frmConsulta').habilitaCampo();
        $('#dssitlcr', '#frmConsulta').desabilitaCampo();
        $('#dsmodali', '#frmConsulta').desabilitaCampo();
        $('#dssubmod', '#frmConsulta').desabilitaCampo();
        $('#txmensal', '#frmConsulta').desabilitaCampo();
        $('#txdiaria', '#frmConsulta').desabilitaCampo();
        $('#dsfinemp', '#frmConsulta').desabilitaCampo();
	
		
		if (($('#cdmodali', "#frmConsulta").val() == '02') && ($('#cdsubmod', "#frmConsulta").val() == '02')) {
			$('#tpmodcon', '#frmConsulta').habilitaCampo();
		}else{
			$('#tpmodcon', '#frmConsulta').desabilitaCampo();
			$('#tpmodcon', '#frmConsulta').val('') ;
		}

        ($('#cddopcao', '#frmCab').val() == 'I') ? $("#tpctrato", "#frmConsulta").habilitaCampo() : $("#tpctrato", "#frmConsulta").desabilitaCampo();

		($("#tpctrato", "#frmConsulta").val() == 4) ? $('#permingr', '#frmConsulta').habilitaCampo() : $('#permingr', '#frmConsulta').desabilitaCampo();

        ($('#flgcrcta', '#frmConsulta').val() == 0) ? $('#cdhistor', '#frmConsulta').habilitaCampo() : $('#cdhistor', '#frmConsulta').desabilitaCampo();

        if ($('#cdusolcr', '#frmConsulta').val() == 0) {

            $("#flgimpde", "#frmConsulta").desabilitaCampo();
            $("#dsorgrec", "#frmConsulta").desabilitaCampo();

        } else if ($('#cdusolcr', '#frmConsulta').val() == 1) {

            $("#flgimpde", "#frmConsulta").desabilitaCampo();
            $("#dsorgrec", "#frmConsulta").desabilitaCampo();

        } else {

            $("#dsorgrec", "#frmConsulta").desabilitaCampo();

        }

        $("#tpprodut", "#frmConsulta").focus();

    }

    return false;

}

function exibeFieldIndexador() {
    if ($("#tpprodut","#frmConsulta").val() == 2) { // Se for Pos-Fixado
        $("#divIndexador","#frmConsulta").show();
    } else {
        $("#divIndexador","#frmConsulta").hide();
    }
    carregaCodigoUso();
}

function carregaCodigoUso() {
    var opt = '';
    var cdusolcr = normalizaNumero($("#cdusolcr","#frmConsulta").attr("val_cdusolcr"));

    if ($("#tpprodut","#frmConsulta").val() != 2) { // Se NAO for Pos-Fixado
        opt = '<option value="1">Micro Crédito</option>';
    }

    $("#cdusolcr","#frmConsulta").find('option')
                                 .remove()
                                 .end()
                                 .append('<option value="0">Normal</option>' + opt + '<option value="2">Epr/Boletos</option>')
                                 .val(cdusolcr);
}


function btnInserirFinalidade() {

    var cdfinemp = $('#cdfinemp','#frmConsulta').val();
    var dsfinemp = $('#dsfinemp', '#frmConsulta').val();

    var existe = false;
    for (var i in RegLinha) {
        if (cdfinemp == RegLinha[i]['cdfinemp']) { existe = true; break; }
    }

    if (cdfinemp == '' ||
		existe == true ||
		dsfinemp == '' ||
		dsfinemp == 'NAO ENCONTRADO') {
        $('#cdfinemp', '#frmConsulta').val('').focus();
        $('#dsfinemp', '#frmConsulta').val('');
        return false
    }

    var qtdLinhas = $('#tbRegFinalidades tbody tr').length; // Quantitdade total de linhas da tabela
    var corLinha = (qtdLinhas % 2 === 0) ? 'corImpar' : 'corPar';

    // Criar a linha na tabela
    $("#tbRegFinalidades > tbody")
		.prepend($('<tr>') // Linha
			.attr('id', cdfinemp)
			.attr('class', corLinha)
			.append($('<td>')
				.attr('style', 'width: 35px; text-align:center')
				.append($('<input>')
					.attr('type', 'checkbox')
					.attr('name', 'cdsqelcr')
					.attr('id', 'cdsqelcr')
					.attr('value', cdfinemp)
                    .prop('checked','true')
				)
			)
			.append($('<td>')
				.attr('style', 'width: 127px; text-align:center')
				.text(cdfinemp)
				.append($('<input>')
					.attr('type', 'hidden')
					.attr('name', 'cdfinemp')
					.attr('id', 'cdfinemp')
					.attr('value', cdfinemp)
				)
			)
			.append($('<td>')
				.attr('style', 'text-align:left')
				.text(dsfinemp)
				.append($('<input>')
					.attr('type', 'hidden')
					.attr('name', 'dsfinemp')
					.attr('id', 'dsfinemp')
					.attr('value', dsfinemp)
				)
			)
		);

    var aux = new Object();
    aux['cdfinemp'] = cdfinemp;
    RegLinha[cdfinemp] = aux;

    zebradoLinhaTabela($('#tbRegFinalidades > tbody > tr'));

    $('#nrregistros', '#divPesquisaRodape').html('Exibindo 1 at&eacute ' + (qtdLinhas + 1) + ' de ' + (qtdLinhas + 1));

    $('#cdfinemp', '#frmConsulta').val('').focus();
    $('#dsfinemp', '#frmConsulta').val('');
}


function bloqueiaLiberaLinha() {

    var cdlcremp = $('#cdlcremp', '#frmFiltro').val();
    var cddopcao = $('#cddopcao', '#frmCab').val();

    //Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, atualizando linha ...');
    
    /* Remove foco de erro */
    $('input,select', '#frmFiltro').removeClass('campoErro');

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/lcredi/bloqueia_libera_linha.php',
        data: {
            cdlcremp: cdlcremp,
            cddopcao: cddopcao,
            redirect: 'html_ajax' // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#btVoltar','#divBotoesConsulta').focus();");
        },
        success: function (response) {
            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground();$("#btVoltar","#divBotoesConsulta").focus();');
            }

        }
    });

    return false;
}



function excluirLinhaCredito() {

    var cdlcremp = $('#cdlcremp', '#frmFiltro').val();
    var cddopcao = $('#cddopcao', '#frmCab').val();

    //Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, excluindo linha ...');

    /* Remove foco de erro */
    $('input,select', '#frmFiltro').removeClass('campoErro');

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/lcredi/excluir_linha_credito.php',
        data: {
            cdlcremp: cdlcremp,
            cddopcao: cddopcao,
            redirect: 'html_ajax' // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#btVoltar','#divBotoesConsulta').focus();");
        },
        success: function (response) {
            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground();$("#btVoltar","#divBotoesConsulta").focus();');
            }

        }
    });

    return false;
}

function calculaTaxas(nmdcampo) {

    //Desabilita todos os campos do form
    $('input,select', '#frmConsulta').desabilitaCampo();

    var cddopcao = $('#cddopcao', '#frmCab').val();
    var txjurfix = isNaN(parseFloat($('#txjurfix', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#txjurfix', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."));
    var txjurvar = isNaN(parseFloat($('#txjurvar', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#txjurvar', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."));
    var txminima = isNaN(parseFloat($('#txminima', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#txminima', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."));
    var txmaxima = isNaN(parseFloat($('#txmaxima', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#txmaxima', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."));

    $('input,select', '#frmConsulta').removeClass('campoErro');

    showMsgAguardo("Aguarde, calculando taxas ...");

    //Requisição para processar a opção que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/lcredi/calcula_taxas.php",
        data: {
            cddopcao: cddopcao,
            txjurvar: txjurvar,
            txjurfix: txjurfix,
            txjurvar: txjurvar,
            txjurfix: txjurfix,
            nmdcampo: nmdcampo,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "$('#btVoltar','#divBotoesConsulta').focus();");
        },
        success: function (response) {

            hideMsgAguardo();

            try {

                eval(response);
            } catch (error) {

                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#btVoltar','#divBotoesConsulta').focus();");

            }
        }

    });

    return false;
}

function alterarLinhaCredito() {

    var cdlcremp = $('#cdlcremp', '#frmFiltro').val();
    var cddopcao = $('#cddopcao', '#frmCab').val();
    var dslcremp = removeCaracteresInvalidos($("#dslcremp", "#frmConsulta").val(), true);
    var dsoperac = $('#dsoperac', '#frmConsulta').val();
    var tplcremp = $('#tplcremp', '#frmConsulta').val();
    var tpdescto = $('#tpdescto', '#frmConsulta').val();
    var tpctrato = $('#tpctrato', '#frmConsulta').val();
    var nrdevias = $('#nrdevias', '#frmConsulta').val();
    var permingr = isNaN(parseFloat($('#permingr', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#permingr', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."));
    var flgrefin = $('#flgrefin', '#frmConsulta').val();
    var flgreneg = $('#flgreneg', '#frmConsulta').val();
    var cdusolcr = $('#cdusolcr', '#frmConsulta').val();
    var flgtarif = $('#flgtarif', '#frmConsulta').val();
    var flgtaiof = $('#flgtaiof', '#frmConsulta').val();
    var vltrfesp = isNaN(parseFloat($('#vltrfesp', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vltrfesp', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."));
    var flgcrcta = $('#flgcrcta', '#frmConsulta').val();
    var manterpo = $('#manterpo', '#frmConsulta').val();
    var flgimpde = $('#flgimpde', '#frmConsulta').val();
    var dsorgrec = $('#dsorgrec', '#frmConsulta').val();
	var tpmodcon = $('#tpmodcon', '#frmConsulta').val();
    var flglispr = $('#flglispr', '#frmConsulta').val();    
    var cdmodali = $('#cdmodali', '#frmConsulta').val();    
    var cdsubmod = $('#cdsubmod', '#frmConsulta').val();   
    var txjurfix = isNaN(parseFloat($('#txjurfix', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#txjurfix', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."));
    var txjurvar = isNaN(parseFloat($('#txjurvar', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#txjurvar', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."));
    var txpresta = isNaN(parseFloat($('#txpresta', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#txpresta', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."));
    var txminima = isNaN(parseFloat($('#txminima', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#txminima', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."));
    var txmaxima = isNaN(parseFloat($('#txmaxima', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#txmaxima', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."));
    var txbaspre = isNaN(parseFloat($('#txbaspre', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#txbaspre', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."));
    var nrgrplcr = $('#nrgrplcr', '#frmConsulta').val();
    var qtcarenc = $('#qtcarenc', '#frmConsulta').val();
    var perjurmo = isNaN(parseFloat($('#perjurmo', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#perjurmo', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."));
    var vlmaxass = isNaN(parseFloat($('#vlmaxass', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vlmaxass', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."));
    var consaut  = $('#consaut', '#frmConsulta'). val();
    var vlmaxasj = isNaN(parseFloat($('#vlmaxasj', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vlmaxasj', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."));
    var nrinipre = $('#nrinipre', '#frmConsulta').val();
    var nrfimpre = $('#nrfimpre', '#frmConsulta').val();
    var qtdcasas = $('#qtdcasas', '#frmConsulta').val();
    var qtrecpro = isNaN(parseFloat($('#qtrecpro', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#qtrecpro', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."));
    var flgdisap = $('#flgdisap', '#frmConsulta').val();
    var flgcobmu = $('#flgcobmu', '#frmConsulta').val();
    var flgsegpr = $('#flgsegpr', '#frmConsulta').val();
    var cdhistor = $('#cdhistor', '#frmConsulta').val();
    var tpprodut = $('#tpprodut', '#frmConsulta').val();
    var cddindex = (tpprodut == 1 ? 0 : $('#cddindex', '#frmConsulta').val());

    //Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, alterando linha ...');

    /* Remove foco de erro */
    $('input,select', '#frmConsulta').removeClass('campoErro');

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/lcredi/alterar_linha_credito.php',
        data: {
            cdlcremp: cdlcremp,
            cddopcao: cddopcao,
            dslcremp: dslcremp,
            dsoperac: dsoperac,
            tplcremp: tplcremp,
            tpdescto: tpdescto,
            tpctrato: tpctrato,
            nrdevias: nrdevias,
			permingr: permingr,
            flgrefin: flgrefin,
            flgreneg: flgreneg,
            cdusolcr: cdusolcr,
            flgtarif: flgtarif,
            flgtaiof: flgtaiof,
            vltrfesp: vltrfesp,
            flgcrcta: flgcrcta,
            manterpo: manterpo,
            flgimpde: flgimpde,
            dsorgrec: dsorgrec,
			tpmodcon: tpmodcon,
            flglispr: flglispr,
            cdmodali: cdmodali,
            cdsubmod: cdsubmod,
            txjurfix: txjurfix,
            txjurvar: txjurvar,
            txpresta: txpresta,
            txminima: txminima,
            txmaxima: txmaxima,
            txbaspre: txbaspre,
            nrgrplcr: nrgrplcr,
            qtcarenc: qtcarenc,
            perjurmo: perjurmo,
            vlmaxass: vlmaxass,
            consaut : consaut ,
            vlmaxasj: vlmaxasj,
            nrinipre: nrinipre,
            nrfimpre: nrfimpre,
            qtdcasas: qtdcasas,
            qtrecpro: qtrecpro,
            flgdisap: flgdisap,
            flgcobmu: flgcobmu,
            flgsegpr: flgsegpr,
            cdhistor: cdhistor,
            tpprodut: tpprodut,
            cddindex: cddindex,
            redirect: 'html_ajax' // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#btVoltar','#divBotoesConsulta').focus();");
        },
        success: function (response) {
            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground();$("#btVoltar","#divBotoesConsulta").focus();');
            }

        }
    });

    return false;
}


function incluirLinhaCredito() {

    var cdlcremp = $('#cdlcremp', '#frmFiltro').val();
    var cddopcao = $('#cddopcao', '#frmCab').val();
    var dslcremp = removeCaracteresInvalidos($("#dslcremp", "#frmConsulta").val(), true);
    var dsoperac = $('#dsoperac', '#frmConsulta').val();
    var tplcremp = $('#tplcremp', '#frmConsulta').val();
    var tpdescto = $('#tpdescto', '#frmConsulta').val();
    var tpctrato = $('#tpctrato', '#frmConsulta').val();
    var nrdevias = $('#nrdevias', '#frmConsulta').val();
    var permingr = isNaN(parseFloat($('#permingr', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#permingr', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."));
    var flgrefin = $('#flgrefin', '#frmConsulta').val();
    var flgreneg = $('#flgreneg', '#frmConsulta').val();
    var cdusolcr = $('#cdusolcr', '#frmConsulta').val();
    var flgtarif = $('#flgtarif', '#frmConsulta').val();
    var flgtaiof = $('#flgtaiof', '#frmConsulta').val();
    var vltrfesp = isNaN(parseFloat($('#vltrfesp', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vltrfesp', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."));
    var flgcrcta = $('#flgcrcta', '#frmConsulta').val();
    var manterpo = $('#manterpo', '#frmConsulta').val();
    var flgimpde = $('#flgimpde', '#frmConsulta').val();
    var dsorgrec = $('#dsorgrec', '#frmConsulta').val();
	var tpmodcon = $('#tpmodcon', '#frmConsulta').val();
    var flglispr = $('#flglispr', '#frmConsulta').val();
    var cdmodali = $('#cdmodali', '#frmConsulta').val();
    var cdsubmod = $('#cdsubmod', '#frmConsulta').val();
    var txjurfix = isNaN(parseFloat($('#txjurfix', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#txjurfix', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."));
    var txjurvar = isNaN(parseFloat($('#txjurvar', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#txjurvar', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."));
    var txpresta = isNaN(parseFloat($('#txpresta', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#txpresta', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."));
    var txminima = isNaN(parseFloat($('#txminima', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#txminima', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."));
    var txmaxima = isNaN(parseFloat($('#txmaxima', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#txmaxima', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."));
    var txbaspre = isNaN(parseFloat($('#txbaspre', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#txbaspre', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."));
    var nrgrplcr = $('#nrgrplcr', '#frmConsulta').val();
    var qtcarenc = $('#qtcarenc', '#frmConsulta').val();
    var perjurmo = isNaN(parseFloat($('#perjurmo', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#perjurmo', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."));
    var vlmaxass = isNaN(parseFloat($('#vlmaxass', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vlmaxass', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."));
    var consaut = $('#consaut', '#frmConsulta').val();
    var vlmaxasj = isNaN(parseFloat($('#vlmaxasj', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vlmaxasj', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."));
    var nrinipre = $('#nrinipre', '#frmConsulta').val();
    var nrfimpre = $('#nrfimpre', '#frmConsulta').val();
    var qtdcasas = $('#qtdcasas', '#frmConsulta').val();
    var qtrecpro = isNaN(parseFloat($('#qtrecpro', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#qtrecpro', '#frmConsulta').val().replace(/\./g, "").replace(/\,/g, "."));
    var flgdisap = $('#flgdisap', '#frmConsulta').val();
    var flgcobmu = $('#flgcobmu', '#frmConsulta').val();
    var flgsegpr = $('#flgsegpr', '#frmConsulta').val();
    var cdhistor = $('#cdhistor', '#frmConsulta').val();
    var tpprodut = $('#tpprodut', '#frmConsulta').val();
    var cddindex = (tpprodut == 1 ? 0 : $('#cddindex', '#frmConsulta').val());

    //Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, incluindo linha ...');

    /* Remove foco de erro */
    $('input,select', '#frmConsulta').removeClass('campoErro');

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/lcredi/incluir_linha_credito.php',
        data: {
            cdlcremp: cdlcremp,
            cddopcao: cddopcao,
            dslcremp: dslcremp,
            dsoperac: dsoperac,
            tplcremp: tplcremp,
            tpdescto: tpdescto,
            tpctrato: tpctrato,
            nrdevias: nrdevias,
			permingr: permingr,
            flgrefin: flgrefin,
            flgreneg: flgreneg,
            cdusolcr: cdusolcr,
            flgtarif: flgtarif,
            flgtaiof: flgtaiof,
            vltrfesp: vltrfesp,
            flgcrcta: flgcrcta,
            manterpo: manterpo,
            flgimpde: flgimpde,
            dsorgrec: dsorgrec,
			tpmodcon: tpmodcon,
            flglispr: flglispr,
            cdmodali: cdmodali,
            cdsubmod: cdsubmod,
            txjurfix: txjurfix,
            txjurvar: txjurvar,
            txpresta: txpresta,
            txminima: txminima,
            txmaxima: txmaxima,
            txbaspre: txbaspre,
            nrgrplcr: nrgrplcr,
            qtcarenc: qtcarenc,
            perjurmo: perjurmo,
            vlmaxass: vlmaxass,
            consaut: consaut,
            vlmaxasj: vlmaxasj,
            nrinipre: nrinipre,
            nrfimpre: nrfimpre,
            qtdcasas: qtdcasas,
            qtrecpro: qtrecpro,
            flgdisap: flgdisap,
            flgcobmu: flgcobmu,
            flgsegpr: flgsegpr,
            cdhistor: cdhistor,
            finalidades: RegLinha,
            tpprodut: tpprodut,
            cddindex: cddindex,
            redirect: 'html_ajax' // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#btVoltar','#divBotoesConsulta').focus();");
        },
        success: function (response) {
            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground();$("#btVoltar","#divBotoesConsulta").focus();');
            }

        }
    });

    return false;
}


function controlaPesquisa(valor) {

    switch (valor) {

        case '1':
            controlaPesquisaLinha();
            break;

        case '2':
            controlaPesquisaModalidade();
            break;

        case '3':
            controlaPesquisaSubModalidade();
            break;

        case '4':
            controlaPesquisaHistorico();
            break;

        case '5':
            controlaPesquisaFinalidadeEmpr();
            break;

    }

}


// Consulta Histórico
function controlaPesquisaHistorico() {

    // Se esta desabilitado o campo 
    if ($("#cdhistor", "#frmConsulta").prop("disabled") == true) {
        return;
    }

    /* Remove foco de erro */
    $('input,select', '#frmConsulta').removeClass('campoErro');

    var bo, procedure, titulo, qtReg, filtrosPesq, colunas;

    //Definição dos filtros
    var filtros = 'Cód. Hist;cdhistor;80px;S;0;|Histórico;dshistor;200px;S;|Indicador;inautori;80px;S;0;N;';

    //Campos que serão exibidos na tela
    var colunas = 'Código;cdhistor;20%;right|Histórico;dshistor;80%;left';

    //Exibir a pesquisa
    mostraPesquisa("zoom0001", "CONSHISTORICOS", "Histórico", "30", filtros, colunas, '', '$(\'#cdhistor\',\'#frmConsulta\').focus();', 'frmConsulta');

    $("#divCabecalhoPesquisa > table").css("width", "500px");
    $("#divResultadoPesquisa > table").css("width", "500px");
    $("#divCabecalhoPesquisa").css("width", "500px");
    $("#divResultadoPesquisa").css("width", "500px");
    $('#divPesquisa').centralizaRotinaH();

    return false;

}

// Consulta Finalidades de empréstimo
function controlaPesquisaFinalidadeEmpr() {

    // Se esta desabilitado o campo 
    if ($("#cdfinemp", "#frmConsulta").prop("disabled") == true) {
        return;
    }

    /* Remove foco de erro */
    $('input,select', '#frmConsulta').removeClass('campoErro');

    var bo, procedure, titulo, qtReg, filtrosPesq, colunas;

    //Definição dos filtros
    var filtros = 'Finalidade do Empr.;cdfinemp;30px;S;0|Descri&ccedil&atildeo;dsfinemp;200px;S;|;flgstfin;;;3;N|;tpfinali;;;;N';

    //Campos que serão exibidos na tela
    var colunas = 'C&oacutedigo;cdfinemp;20%;right|Finalidade;dsfinemp;80%;left|Flag;flgstfin;0%;left;;N|Tipo;tpfinali;0%;left;;N';

    //Exibir a pesquisa
    mostraPesquisa("zoom0001", "BUSCAFINEMPR", "Finalidade do Empr&eacutestimo", "30", filtros, colunas, '', '$(\'#cdfinemp\',\'#frmConsulta\').focus();', 'frmConsulta');

    $("#divCabecalhoPesquisa > table").css("width", "500px");
    $("#divResultadoPesquisa > table").css("width", "500px");
    $("#divCabecalhoPesquisa").css("width", "500px");
    $("#divResultadoPesquisa").css("width", "500px");
    $('#divPesquisa').centralizaRotinaH();

    return false;

}

function controlaPesquisaLinha() {

    // Se esta desabilitado o campo 
    if ($("#cdlcremp", "#frmFiltro").prop("disabled") == true) {
        return;
    }

    /* Remove foco de erro */
    $('input', '#frmFiltro').removeClass('campoErro');

    var bo, procedure, titulo, qtReg, filtrosPesq, colunas;

    var nrconven = normalizaNumero($('#cdlcremp', '#frmFiltro').val());

    //Definição dos filtros
    var filtros = "Linhas;cdlcremp;120px;S;;;|Descrição;dslcremp;120px;S;;descricao|;flgstlcr;;;0;N";

    //Campos que serão exibidos na tela
    var colunas = 'Código;cdlcremp;10%;right|Descrição;dslcremp;50%;left|Situação;flgstlcr;20%;left;|Garantia;tpctrato;20%;center';

    //Exibir a pesquisa
    mostraPesquisa("zoom0001", "BUSCALINHASCREDITO", "Linhas de Cr&eacute;dito", "30", filtros, colunas, '', '$(\'#cdlcremp\',\'#frmFiltro\').focus();', 'frmFiltro');

    $("#divCabecalhoPesquisa > table").css("width", "600px");
    $("#divResultadoPesquisa > table").css("width", "600px");
    $("#divCabecalhoPesquisa").css("width", "600px");
    $("#divResultadoPesquisa").css("width", "600px");
    $('#divPesquisa').centralizaRotinaH();

    return false;

}


function controlaPesquisaModalidade() {

    // Se esta desabilitado o campo 
    if ($("#cdmodali", "#frmConsulta").prop("disabled") == true) {
        return;
    }

    /* Remove foco de erro */
    $('input,select', '#frmConsulta').removeClass('campoErro');

    var bo, procedure, titulo, qtReg, filtrosPesq, colunas;

    //Definição dos filtros
    var filtros = "Linhas;cdmodali;20%;S;0;N;|Descrição;dsmodali;50%;S;;N;";

    //Campos que serão exibidos na tela
    var colunas = 'Código;cdmodali;20%;center|Descrição;dsmodali;50%;left';

    //Exibir a pesquisa
    mostraPesquisa("TELA_LCREDI", "CONSMOD", "Modalidades", "30", filtros, colunas, '', '$(\'#cdmodali\',\'#frmConsulta\').val();', 'frmConsulta');

    $("#divCabecalhoPesquisa > table").css("width", "600px");
    $("#divResultadoPesquisa > table").css("width", "600px");
    $("#divCabecalhoPesquisa").css("width", "600px");
    $("#divResultadoPesquisa").css("width", "600px");
    $('#divPesquisa').centralizaRotinaH();

    return false;

}


function controlaPesquisaSubModalidade() {

    // Se esta desabilitado o campo 
    if ($("#cdsubmod", "#frmConsulta").prop("disabled") == true) {
        return;
    }

    /* Remove foco de erro */
    $('input,select', '#frmConsulta').removeClass('campoErro');

    var bo, procedure, titulo, qtReg, filtrosPesq, colunas;

    //Definição dos filtros
    var filtros = 'Cód. Submodalidade;cdsubmod;20%;S;;;codigo;|Descrição;dssubmod;50%;S;;N;|Cód. Modalidade;cdmodali;20%;N;' + $('#cdmodali', '#frmConsulta').val() + ';S;codigo;';

    //Campos que serão exibidos na tela
    var colunas = 'Código;cdsubmod;20%;center|Descrição;dssubmod;50%;left';

    //Exibir a pesquisa
    mostraPesquisa("TELA_LCREDI", "CONSSUBMOD", "Submodalidades", "30", filtros, colunas, '', '$(\'#cdsubmod\',\'#frmConsulta\').val();', 'frmConsulta');

    $("#divCabecalhoPesquisa > table").css("width", "600px");
    $("#divResultadoPesquisa > table").css("width", "600px");
    $("#divCabecalhoPesquisa").css("width", "600px");
    $("#divResultadoPesquisa").css("width", "600px");
    $('#divPesquisa').centralizaRotinaH();

    return false;

}

function controlaVoltar(ope,tpconsul) {
    
    switch (ope) {

        case '1':
            
            estadoInicial();

        break;

        case '2':

            //Limpa formulario
            $('input[type="text"]', '#frmFiltro').limpaFormulario();
            $('#divTabela').html('').css('display', 'none');
            formataFiltro();

        break;

        case '3':

            formataFiltro();

        break;

        case '4':

            if (tpconsul == 'C') {

                $('#nrctrpro', '#frmFiltro').focus();

            } else {
                $('#nrgravam', '#frmFiltro').focus();
            }

            fechaRotina($('#divRotina'));
            $('#divRotina').html(''); 

        break;

    }

    return false;

}


function montaFormFiltro() {

    var cddopcao = $("#cddopcao", "#frmCab").val();

    showMsgAguardo("Aguarde ...");

    //Requisição para montar o form correspondente a opção escolhida
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/lcredi/monta_form_filtro.php",
        data: {
            cddopcao: cddopcao,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "estadoInicial();");
        },
        success: function (response) {

            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {

                    $('#divFiltro').html(response);
                    return false;
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "estadoInicial();");
                }
            } else {
                try {

                    eval(response);
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "estadoInicial();");
                }
            }
        }

    });

    return false;

}

function consultaLinhaCredito(nriniseq, nrregist) {

    var cddopcao = $("#cddopcao", "#frmCab").val();
    var cdlcremp = $("#cdlcremp", "#frmFiltro").val();

    //Inicializa array
    RegLinha = new Object();

    showMsgAguardo("Aguarde, consultando linha de crédito ...");

    $('input,select','#frmFiltro').desabilitaCampo();

    /* Remove foco de erro */
    $('input,select', '#frmFiltro').removeClass('campoErro');

    /* Remove foco de erro */
    $('input,select', '#frmConsulta').removeClass('campoErro').limpaFormulario();

    //Requisição para montar o form correspondente a opção escolhida
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/lcredi/consulta_linha_credito.php",
        data: {
            cddopcao: cddopcao,
            cdlcremp: cdlcremp,
            nriniseq: nriniseq,
            nrregist: nrregist,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "estadoInicial();");
        },
        success: function (response) {

            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {

                    $('#divTabela').html(response);
                    return false;
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "estadoInicial();");
                }
            } else {
                try {

                    eval(response);
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "estadoInicial();");
                }
            }
        }

    });

    return false;

}

function formataTabelaRegistros() {

    var divRegistro = $('div.divRegistros', '#divTabela');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);
    var cddopcao = $('#cddopcao', '#frmCab').val();

    divRegistro.css({ 'height': '250px', 'padding-bottom': '2px' });
    $('#divRegistrosRodape', '#divTabela').formataRodapePesquisa();

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    var arrayAlinha = new Array();

    if (cddopcao == "I") {

        arrayLargura[0] = '35px';
        arrayLargura[1] = '127px';

        arrayAlinha[0] = 'center';
        arrayAlinha[1] = 'center';
        arrayAlinha[2] = 'left';

        tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);

        $("th:eq(0)", tabela).removeClass();
        $("th:eq(0)", tabela).unbind('click');

        // Adiciona função que ao selecionar o checkbox header, marca/desmarca todos os checkboxs da tabela
        $("input[type=checkbox][name='checkTodos']").unbind('click').bind('click', function () {
            var selec = this.checked;
            $("input[type=checkbox][name='cdsqelcr[]']").prop("checked", selec);
        });

    } else {

        arrayLargura[0] = '50px';

        arrayAlinha[0] = 'center';

        ($('#cddopcao', '#frmCab').val() == 'P') ? arrayAlinha[1] = 'center' : arrayAlinha[1] = 'left';

        tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);

    }
    
    
    return false;

}

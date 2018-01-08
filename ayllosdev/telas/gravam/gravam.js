/***********************************************************************
 Fonte: gravam.js                                                  
 Autor: Andrei - RKAM
 Data : Maio/2016                Última Alteração: 11/04/2017
                                                                   
 Objetivo  : Cadastro de servicos ofertados na tela GRAVAM
                                                                   	 
 Alterações: 14/07/2016 - Ajustes para validar o chassi (Andrei - RKAM).
                
			 10/08/2016 - Ajuste para aumentar tamanho dos campos apresentados
                          na tela para que seja possível visualizar toda sua informação
                          (Adriano).

			 24/08/2016 - Validar se pode ser alterado a situação do GRAVAMES.
						  Adicionada validações com a senha do coordenador para 
						  as opções 'M', 'A' e 'B'. Projeto 369 (Lombardi).
						  
             11/04/2017 - Permitir acessar o Ayllos mesmo vindo do CRM. (Jaison/Andrino)
************************************************************************/

var rating = new Object();

$(document).ready(function() {	
	
	estadoInicial();
		
});

function estadoInicial() {
    
    //Inicializa o array
    rating = new Object();

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

    $('#divTela').css({ 'display': 'inline' }).fadeTo(0, 0.1);
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

    // Seta os valores caso tenha vindo do CRM
    if ($("#crm_inacesso","#frmCab").val() == 1) {
        $("#nrdconta","#frmFiltro").val($("#crm_nrdconta","#frmCab").val());
    }
    
    /*##########################################

        Formata os campos da divFiltroConta

      #########################################*/

    //rotulo
    $('label[for="nrdconta"]', "#divFiltroConta").addClass("rotulo").css({ "width": "130px" });
    $('label[for="cdagenci"]', "#divFiltroConta").addClass("rotulo-linha").css({ "width": "35px" });
    $('label[for="nrctrpro"]', "#divFiltroConta").addClass("rotulo-linha").css({ "width": "70px" });
    $('label[for="nrgravam"]', "#divFiltroConta").addClass("rotulo").css({ "width": "130px" });

    // campo
    $("#nrdconta", "#divFiltroConta").css({ 'width': '100px', 'text-align': 'right' }).addClass('conta').attr('maxlength', '10').habilitaCampo();
    $('#cdagenci', '#divFiltroConta').addClass('inteiro').css({ 'width': '50px', 'text-align': 'right' }).attr('maxlength', '4').desabilitaCampo();
    $('#nrctrpro', '#divFiltroConta').addClass('pesquisa').css({ 'width': '100px', 'text-align': 'right' }).attr('maxlength', '7').habilitaCampo().addClass('inteiro');
    $('#nrgravam', '#divFiltroConta').addClass('pesquisa').css({ 'width': '100px', 'text-align': 'right' }).attr('maxlength', '8').habilitaCampo().addClass('inteiro');

    /*##########################################

        Formata os campos da divCancelamento

      #########################################*/

    //rotulo
    $('label[for="tpcancel"]', "#divCancelamento").addClass("rotulo").css({ "width": "150px" });

    // campo
    $('#tpcancel', '#divCancelamento').css({ 'width': '100px', 'text-align': 'left' }).habilitaCampo();

    $('#frmFiltro').css({ 'display': 'block' });
    $('#divBotoes').css({ 'display': 'block' });
    $('#btConcluir', '#divBotoes').css({ 'display': 'none' });
    $('#btProsseguir', '#divBotoes').css({ 'display': 'inline' });
    $('#btVoltar', '#divBotoes').css({ 'display': 'inline' });
    
    highlightObjFocus($('#frmFiltro'));
    
    $('#divFiltroConta').css({ 'display': 'block' });
    
    //Define ação para o campo nrdconta
    $("#nrdconta", "#divFiltroConta").unbind('keypress').bind('keypress', function (e) {

        $(this).removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            buscaPaAssociado();
            return false;
        }

    });

    //Define ação para o campo nrctrpro
    $("#nrctrpro", "#divFiltroConta").unbind('keypress').bind('keypress', function (e) {

        $(this).removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $("#nrgravam", "#divFiltroConta").focus();
            return false;

        }

    });


    /*---------------------*/
    /*  CONTROLE Contratos */
    /*---------------------*/
    var linkOperador = $('a:eq(1)', '#divFiltroConta');

    if (linkOperador.prev().hasClass('campoTelaSemBorda')) {
        linkOperador.addClass('lupa').css('cursor', 'auto').unbind('click').bind('click', function () { return false; });
    } else {
        linkOperador.css('cursor', 'pointer').unbind('click').bind('click', function () {

            buscaContratosGravames(1, 30);

        });
    }

    /*---------------------*/
    /*  CONTROLE Gravames  */
    /*---------------------*/
    var linkOperador = $('a:eq(2)', '#divFiltroConta');

    if (linkOperador.prev().hasClass('campoTelaSemBorda')) {
        linkOperador.addClass('lupa').css('cursor', 'auto').unbind('click').bind('click', function () { return false; });
    } else {
        linkOperador.css('cursor', 'pointer').unbind('click').bind('click', function () {

            buscaGravames(1, 30);

        });
    }

    if ($('#cddopcao', '#frmCab').val() == "X") {

        $('#divCancelamento').css({ 'display': 'block' });
        $('#fsetFiltroCancelamento').css({ 'display': 'block' });

        //Define ação para o campo nrgravam
        $("#nrgravam", "#divFiltroConta").unbind('keypress').bind('keypress', function (e) {

            $(this).removeClass('campoErro');

            // Se é a tecla ENTER, TAB
            if (e.keyCode == 13 || e.keyCode == 9) {

                $("#tpcancel", "#divCancelamento").focus();
                return false;

            }

        });

        //Define ação para o campo nrgravam
        $("#tpcancel", "#divCancelamento").unbind('keypress').bind('keypress', function (e) {

            $(this).removeClass('campoErro');

            // Se é a tecla ENTER, TAB
            if (e.keyCode == 13 || e.keyCode == 9) {

                $("#btProsseguir", "#divBotoes").click();

                return false;

            }

        });

    } else {

        $('#divCancelamento').css({ 'display': 'none' });
        $('#fsetFiltroCancelamento').css({ 'display': 'none' });

        //Define ação para o campo nrgravam
        $("#nrgravam", "#divFiltroConta").unbind('keypress').bind('keypress', function (e) {

            $(this).removeClass('campoErro');

            // Se é a tecla ENTER, TAB
            if (e.keyCode == 13 || e.keyCode == 9) {

                $("#btProsseguir", "#divBotoes").click();

                return false;

            }

        });

    }

    //Define ação para CLICK no botão de Concluir
    $("#btProsseguir", "#divBotoes").unbind('click').bind('click', function () {

        buscaBens(1, 30);

    });

    //Define ação para CLICK no botão de Voltar
    $("#btVoltar", "#divBotoes").unbind('click').bind('click', function () {

        controlaVoltar('1');

        return false;

    });

    $("#nrdconta", "#divFiltroConta").focus();

    layoutPadrao();

}

function formataFiltroImpressao() {

    // Desabilitar a opção
    $("#cddopcao", "#frmCab").desabilitaCampo();

    /*##########################################

        Formata os campos da divFiltroImpressao

      #########################################*/

    //rotulo
    $('label[for="cdcooper"]', "#divFiltroImpressao").addClass("rotulo").css({ "width": "100px" });
    $('label[for="tparquiv"]', "#divFiltroImpressao").addClass("rotulo-linha").css({ "width": "110px" });
    $('label[for="nrseqlot"]', "#divFiltroImpressao").addClass("rotulo").css({ "width": "100px" });
    $('label[for="dtrefere"]', "#divFiltroImpressao").addClass("rotulo-linha").css({ "width": "160px" });

    // campo
    $('#cdcooper', '#divFiltroImpressao').css({ 'width': '150px', 'text-align': 'left' }).habilitaCampo();
    $('#tparquiv', '#divFiltroImpressao').css({ 'width': '150px', 'text-align': 'left' }).habilitaCampo();
    $('#nrseqlot', '#divFiltroImpressao').css({ 'width': '100px', 'text-align': 'right' }).attr('maxlength', '7').habilitaCampo().addClass('inteiro');
    $('#dtrefere', '#divFiltroImpressao').css({ 'width': '100px', 'text-align': 'right' }).habilitaCampo().addClass('data');

    
    $('#frmFiltro').css({ 'display': 'block' });
    $('#divBotoes').css({ 'display': 'block' });
    $('#btConcluir', '#divBotoes').css({ 'display': 'inline' });
    $('#btProsseguir', '#divBotoes').css({ 'display': 'none' });
    $('#btVoltar', '#divBotoes').css({ 'display': 'inline' });
    
    highlightObjFocus($('#frmFiltro'));
    
    $('#divFiltroImpressao').css({ 'display': 'block' });

    //Define ação para o campo cdcooper
    $("#cdcooper", "#divFiltroImpressao").unbind('keypress').bind('keypress', function (e) {

        $(this).removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $("#tparquiv", "#divFiltroImpressao").focus();
            return false;

        }

    });

    //Define ação para o campo tparquiv
    $("#tparquiv", "#divFiltroImpressao").unbind('keypress').bind('keypress', function (e) {

        $(this).removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $("#nrseqlot", "#divFiltroImpressao").focus();
            return false;

        }

    });

    //Define ação para o campo nrseqlot
    $("#nrseqlot", "#divFiltroImpressao").unbind('keypress').bind('keypress', function (e) {

        $(this).removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $("#dtrefere", "#divFiltroImpressao").focus();
            return false;

        }

    });

    //Define ação para o campo dtrefere
    $("#dtrefere", "#divFiltroImpressao").unbind('keypress').bind('keypress', function (e) {

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $("#btConcluir", "#divBotoes").click();

            return false;

        }

    });

    //Define ação para CLICK no botão de Concluir
    $("#btConcluir", "#divBotoes").unbind('click').bind('click', function () {

        showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'gerarRelatorio670();', 'formataFiltroImpressao();', 'sim.gif', 'nao.gif');

        return false;

    });

    //Define ação para CLICK no botão de Voltar
    $("#btVoltar", "#divBotoes").unbind('click').bind('click', function () {

        controlaVoltar('1');

        return false;

    });

    $("#cdcooper", "#divFiltroImpressao").focus();

    layoutPadrao();

}

function formataFiltroArquivo() {

    // Desabilitar a opção
    $("#cddopcao", "#frmCab").desabilitaCampo();

    //Limpa formulario
    $('input[type="text"]', '#frmFiltro').limpaFormulario().removeClass('campoErro');

    /*##########################################

        Formata os campos da divFiltroArq

      #########################################*/

    //rotulo
    $('label[for="cdcooper"]', "#divFiltroArq").addClass("rotulo").css({ "width": "100px" });
    $('label[for="tparquiv"]', "#divFiltroArq").addClass("rotulo-linh").css({ "width": "115px" });

    // campo
    $('#cdcooper', '#divFiltroArq').css({ 'width': '150px', 'text-align': 'left' }).habilitaCampo();
    $('#tparquiv', '#divFiltroArq').css({ 'width': '150px', 'text-align': 'left' }).habilitaCampo();

    $('#frmFiltro').css({ 'display': 'block' });
    $('#divBotoes').css({ 'display': 'block' });
    $('#btConcluir', '#divBotoes').css({ 'display': 'inline' });
    $('#btProsseguir', '#divBotoes').css({ 'display': 'none' });
    $('#btVoltar', '#divBotoes').css({ 'display': 'inline' });
   
    highlightObjFocus($('#frmFiltro'));
        
    $('#divFiltroArq').css({ 'display': 'block' });

    //Define ação para o campo cdcooper
    $("#cdcooper", "#divFiltroArq").unbind('keypress').bind('keypress', function (e) {

        $(this).removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $("#tparquiv", "#divFiltroArq").focus();
            return false;

        }

    });

    //Define ação para o campo tparquiv
    $("#tparquiv", "#divFiltroArq").unbind('keypress').bind('keypress', function (e) {

        $(this).removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $("#btConcluir", "#divBotoes").click();

            return false;

        }

    });

    if ($('#cddopcao', '#frmCab').val() == 'G') {
    
        //Define ação para CLICK no botão de Concluir
        $("#btConcluir", "#divBotoes").unbind('click').bind('click', function () {

            showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'geraArquivo();', 'formataFiltroArquivo();', 'sim.gif', 'nao.gif');

            return false;

        });

    } else {

        //Define ação para CLICK no botão de Concluir
        $("#btConcluir", "#divBotoes").unbind('click').bind('click', function () {

            showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'solicitaProcessamentoArquivoRetorno();', 'formataFiltroArquivo();', 'sim.gif', 'nao.gif');

            return false;

        });

    }
    
    //Define ação para CLICK no botão de Voltar
    $("#btVoltar", "#divBotoes").unbind('click').bind('click', function () {

        controlaVoltar('1');

        return false;

    });

    
    $("#cdcooper", "#divFiltroArq").focus();


    layoutPadrao();

}

function formataFiltroHistorico() {

    // Desabilitar a opção
    $("#cddopcao", "#frmCab").desabilitaCampo();

    // Seta os valores caso tenha vindo do CRM
    if ($("#crm_inacesso","#frmCab").val() == 1) {
        $("#nrdconta","#frmFiltro").val($("#crm_nrdconta","#frmCab").val());
    }
    
    /*##########################################

        Formata os campos da divFiltroHistorico

      #########################################*/

    //rotulo
    $('label[for="cdcooper"]', "#divFiltroHistorico").addClass("rotulo").css({ "width": "95px" });
    $('label[for="nrdconta"]', "#divFiltroHistorico").addClass("rotulo-linha").css({ "width": "50px" });
    $('label[for="nrctrpro"]', "#divFiltroHistorico").addClass("rotulo-linha").css({ "width": "60px" });

    // campo
    $('#cdcooper', '#divFiltroHistorico').css({ 'width': '150px', 'text-align': 'left' }).habilitaCampo();
    $("#nrdconta", "#divFiltroHistorico").css({ 'width': '100px', 'text-align': 'right' }).addClass('conta').attr('maxlength', '10').habilitaCampo();
    $('#nrctrpro', '#divFiltroHistorico').addClass('pesquisa').css({ 'width': '100px', 'text-align': 'right' }).attr('maxlength', '7').habilitaCampo().addClass('inteiro');

    $('#frmFiltro').css({ 'display': 'block' });
    $('#divBotoes').css({ 'display': 'block' });
    $('#btConcluir', '#divBotoes').css({ 'display': 'inline' });
    $('#btProsseguir', '#divBotoes').css({ 'display': 'none' });
    $('#btVoltar', '#divBotoes').css({ 'display': 'inline' });
    
    highlightObjFocus($('#frmFiltro'));
        
    
    $('#divFiltroHistorico').css({ 'display': 'block' });

    //Define ação para o campo cdcooper
    $("#cdcooper", "#divFiltroHistorico").unbind('keypress').bind('keypress', function (e) {

        $(this).removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $("#nrdconta", "#divFiltroHistorico").focus();
            return false;

        }

    });

    //Define ação para o campo nrdconta
    $("#nrdconta", "#divFiltroHistorico").unbind('keypress').bind('keypress', function (e) {

        $(this).removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $("#nrctrpro", "#divFiltroHistorico").focus();
            return false;

        }

    });

    //Define ação para o campo nrctrpro
    $("#nrctrpro", "#divFiltroHistorico").unbind('keypress').bind('keypress', function (e) {

        $(this).removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $("#btConcluir", "#divBotoes").click();

            return false;

        }

    });

    /*---------------------*/
    /*  CONTROLE Contratos */
    /*---------------------*/
    var linkOperador = $('a:eq(1)', '#divFiltroHistorico');

    if (linkOperador.prev().hasClass('campoTelaSemBorda')) {
        linkOperador.addClass('lupa').css('cursor', 'auto').unbind('click').bind('click', function () { return false; });
    } else {
        linkOperador.css('cursor', 'pointer').unbind('click').bind('click', function () {

            buscaContratosGravames(1, 30);

        });
    }

    //Define ação para CLICK no botão de Concluir
    $("#btConcluir", "#divBotoes").unbind('click').bind('click', function () {

        showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'gerarRelatorioHistorico();', 'formataFiltroHistorico();', 'sim.gif', 'nao.gif');

        return false;

    });

    //Define ação para CLICK no botão de Voltar
    $("#btVoltar", "#divBotoes").unbind('click').bind('click', function () {

        controlaVoltar('1');

        return false;

    });

    $("#cdcooper", "#divFiltroHistorico").focus();
        
    layoutPadrao();

}

function formataFormularioBens() {

    highlightObjFocus($('#frmBens'));  

    //rotulo
    $('label[for="dtmvttel"]', "#frmBens").addClass("rotulo").css({ "width": "150px" });
    $('label[for="dsseqbem"]', "#frmBens").addClass("rotulo-linha").css({ "width": "5px" });
    $('label[for="nrgravam"]', "#frmBens").addClass("rotulo").css({ "width": "150px" });
    $('label[for="dssitgrv"]', "#frmBens").addClass("rotulo-linha").css({ "width": "75px" });
    $('label[for="dscatbem"]', "#frmBens").addClass("rotulo").css({ "width": "150px" });
    $('label[for="dsblqjud"]', "#frmBens").addClass("rotulo-linha").css({ "width": "75px" });
    $('label[for="dsbemfin"]', "#frmBens").addClass("rotulo").css({ "width": "150px" });
    $('label[for="dscorbem"]', "#frmBens").addClass("rotulo").css({ "width": "150px" });
    $('label[for="vlmerbem"]', "#frmBens").addClass("rotulo-linha").css({ "width": "115px" });
    $('label[for="dschassi"]', "#frmBens").addClass("rotulo").css({ "width": "150px" });
    $('label[for="tpchassi"]', "#frmBens").addClass("rotulo-linha").css({ "width": "80px" });
    $('label[for="ufdplaca"]', "#frmBens").addClass("rotulo").css({ "width": "150px" });
    $('label[for="nrdplaca"]', "#frmBens").addClass("rotulo-linha").css({ "width": "10px" });
    $('label[for="uflicenc"]', "#frmBens").addClass("rotulo").css({ "width": "150px" });
    $('label[for="nrrenava"]', "#frmBens").addClass("rotulo-linha").css({ "width": "65px" });
    $('label[for="nranobem"]', "#frmBens").addClass("rotulo-linha").css({ "width": "120px" });
    $('label[for="nrmodbem"]', "#frmBens").addClass("rotulo").css({ "width": "150px" });
    $('label[for="dscpfbem"]', "#frmBens").addClass("rotulo-linha").css({ "width": "190px" });
    $('label[for="vlctrgrv"]', "#frmBens").addClass("rotulo").css({ "width": "150px" });
    $('label[for="dtoperac"]', "#frmBens").addClass("rotulo-linha").css({ "width": "140px" });
    $('label[for="dsjustif"]', "#frmBens").addClass("rotulo").css({ "width": "150px" });
    
    // campo
    $('#dtmvttel', '#frmBens').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo(); //.addClass('data');
    $("#dsseqbem", "#frmBens").css({ 'width': '290px', 'text-align': 'left' }).desabilitaCampo();
    $('#nrgravam', '#frmBens').css({ 'width': '100px', 'text-align': 'right' }).addClass('inteiro').attr('maxlength', '9').desabilitaCampo();
    $("#dssitgrv", "#frmBens").css({ 'width': '220px', 'text-align': 'left' }).desabilitaCampo();
    $('#dscatbem', '#frmBens').css({ 'width': '100px', 'text-align': 'left' }).desabilitaCampo();
    $('#dsblqjud', '#frmBens').css({ 'width': '220px', 'text-align': 'left' }).desabilitaCampo();
    $('#dsbemfin', '#frmBens').css({ 'width': '400px', 'text-align': 'left' }).desabilitaCampo();
    $('#dscorbem', '#frmBens').css({ 'width': '150px', 'text-align': 'left' }).desabilitaCampo();
    $('#vlmerbem', '#frmBens').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo();
    $('#dschassi', '#frmBens').css({ 'width': '190px', 'text-align': 'left' }).desabilitaCampo().attr('maxlength', '20').addClass('alphanum');
    $('#tpchassi', '#frmBens').css({ 'width': '45px', 'text-align': 'right' }).desabilitaCampo();
    $('#ufdplaca', '#frmBens').css({ 'width': '45px', 'text-align': 'left' }).desabilitaCampo().attr('maxlength', '2').addClass('alphanum');
    $('#nrdplaca', '#frmBens').css({ 'width': '100px' }).desabilitaCampo().attr('maxlength', '8').addClass('placa');
    $('#uflicenc', '#frmBens').css({ 'width': '45px', 'text-align': 'left' }).desabilitaCampo();
    $('#nrrenava', '#frmBens').css({ 'width': '110px', 'text-align': 'right' }).desabilitaCampo().attr('maxlength', '25').addClass('renavan');
    $('#nranobem', '#frmBens').css({ 'width': '50px', 'text-align': 'right' }).addClass('inteiro').attr('maxlength', '4').desabilitaCampo();
    $('#nrmodbem', '#frmBens').css({ 'width': '50px', 'text-align': 'right' }).addClass('inteiro').attr('maxlength', '4').desabilitaCampo();
    $('#dscpfbem', '#frmBens').css({ 'width': '120px', 'text-align': 'right' }).desabilitaCampo();
    $('#vlctrgrv', '#frmBens').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo();
    $('#dtoperac', '#frmBens').css({ 'width': '80px', 'text-align': 'right' }).desabilitaCampo();
    $('#dsjustif', '#divJustificativa').addClass('alphanum').css('width', '400px').css('overflow-y', 'scroll').css('overflow-x', 'hidden').css('height', '70').css('margin-left', '3').setMask("STRING", "129", charPermitido(), "");
    $('#dsjustif', '#divJustificativa').desabilitaCampo();

    $('#frmBens').css({ 'display': 'block' });    
       
    layoutPadrao();

    if ($('#cddopcao', '#frmCab').val() == 'A') {

        $("#dschassi", "#divBens").unbind('keypress').bind('keypress', function (e) {

            if (divError.css('display') == 'block') { return false; }

            if (e.keyCode == 13) {

                $("#ufdplaca", "#frmBens").focus();

                return false;
            }

        });

        // Se pressionar alguma tecla no campo Chassi/N.Serie, verificar a tecla pressionada e toda a devida ação
        $("#dschassi", "#divBens").unbind('keydown').bind('keydown', function (event) {

            var tecla = event.which || event.keyCode;

            // Se é a tecla "Q" ou "q"
            if (tecla == 81) {
                return false;
            }

            // Se é a tecla "I" ou "i"			
            if (tecla == 73) {
                return false;
            }

            // Se é a tecla "O" ou "o"
            if (tecla == 79) {
                return false;
            }
        });

        //Remover caracteres especiais
        $("#dschassi", "#divBens").unbind('keyup').bind('keyup', function (e) {
            var re = /[^\w\s]/gi;

            if (re.test($("#dschassi", "#divBens").val())) {
                $("#dschassi", "#divBens").val($("#dschassi", "#divBens").val().replace(re, ''));
            }

            re = /[\Q\q\I\i\O\o\_]/g;

            if (re.test($("#dschassi", "#divBens").val())) {
                $("#dschassi", "#divBens").val($("#dschassi", "#divBens").val().replace(re, ''));
            }

            re = / /g;

            if (re.test($("#dschassi", "#divBens").val())) {
                $("#dschassi", "#divBens").val($("#dschassi", "#divBens").val().replace(re, ''));
            }
        });

        $("#dschassi", "#divBens").unbind('blur').bind('blur', function () {
            $("#dschassi", "#divBens").val($("#dschassi", "#divBens").val().replace(/[^\w\s]/gi, ''));
            $("#dschassi", "#divBens").val($("#dschassi", "#divBens").val().replace(/[\Q\q\I\i\O\o\_]/g, ''));
            $("#dschassi", "#divBens").val($("#dschassi", "#divBens").val().replace(/ /g, ''));
        });


        //Define ação para o campo ufdplaca
        $("#ufdplaca", "#frmBens").unbind('keypress').bind('keypress', function (e) {

            $(this).removeClass('campoErro');

            // Se é a tecla ENTER, TAB
            if (e.keyCode == 13 || e.keyCode == 9) {

                $("#nrdplaca", "#frmBens").focus();
                return false;
            }

        });

        //Define ação para o campo nrdplaca
        $("#nrdplaca", "#frmBens").unbind('keypress').bind('keypress', function (e) {

            $(this).removeClass('campoErro');

            // Se é a tecla ENTER, TAB
            if (e.keyCode == 13 || e.keyCode == 9) {

                $("#nrrenava", "#frmBens").focus();
                return false;
            }

        });

        //Define ação para o campo nrrenava
        $("#nrrenava", "#frmBens").unbind('keypress').bind('keypress', function (e) {

            $(this).removeClass('campoErro');

            // Se é a tecla ENTER, TAB
            if (e.keyCode == 13 || e.keyCode == 9) {

                $("#btConcluir", "#divBotoesBens").click();
                return false;
            }

        });

        $("#dschassi", "#divBens").focus();

    } else if ($('#cddopcao', '#frmCab').val() == 'B') {

        $('#dsjustif', '#divJustificativa').habilitaCampo().focus();

    } else if ($('#cddopcao', '#frmCab').val() == 'M') {

        $('#nrgravam', '#frmBens').habilitaCampo();
        $('#dsjustif', '#divJustificativa').habilitaCampo();
        $('#dtmvttel', '#frmBens').habilitaCampo().focus();

        //Define ação para o campo dtmvttel
        $("#dtmvttel", "#frmBens").unbind('keypress').bind('keypress', function (e) {

            $(this).removeClass('campoErro');

            // Se é a tecla ENTER, TAB
            if (e.keyCode == 13 || e.keyCode == 9) {
               
                $("#nrgravam", "#frmBens").focus();                

                return false;
            }

        });

        //Define ação para o campo nrgravam
        $("#nrgravam", "#frmBens").unbind('keypress').bind('keypress', function (e) {

            $(this).removeClass('campoErro');

            // Se é a tecla ENTER, TAB
            if (e.keyCode == 13 || e.keyCode == 9) {

                $("#dsjustif", "#frmBens").focus();
                return false;
            }

        });

        //Define ação para o campo dsjustif
        $("#dsjustif", "#frmBens").unbind('keypress').bind('keypress', function (e) {

            $(this).removeClass('campoErro');

            // Se é a tecla ENTER, TAB
            if (e.keyCode == 13 || e.keyCode == 9) {

                $("#btConcluir", "#divBotoesBens").click();
                return false;
            }

        });

    } else if ($('#cddopcao', '#frmCab').val() == 'S') {

        $("#dschassi", "#divBens").unbind('keypress').bind('keypress', function (e) {

            if (divError.css('display') == 'block') { return false; }

            if (e.keyCode == 13) {

                $("#ufdplaca", "#frmBens").focus();

                return false;
            }

        });

        // Se pressionar alguma tecla no campo Chassi/N.Serie, verificar a tecla pressionada e toda a devida ação
        $("#dschassi", "#divBens").unbind('keydown').bind('keydown', function (event) {

            var tecla = event.which || event.keyCode;

            // Se é a tecla "Q" ou "q"
            if (tecla == 81) {
                return false;
            }

            // Se é a tecla "I" ou "i"			
            if (tecla == 73) {
                return false;
            }

            // Se é a tecla "O" ou "o"
            if (tecla == 79) {
                return false;
            }
        });

        //Remover caracteres especiais
        $("#dschassi", "#divBens").unbind('keyup').bind('keyup', function (e) {
            var re = /[^\w\s]/gi;

            if (re.test($("#dschassi", "#divBens").val())) {
                $("#dschassi", "#divBens").val($("#dschassi", "#divBens").val().replace(re, ''));
            }

            re = /[\Q\q\I\i\O\o\_]/g;

            if (re.test($("#dschassi", "#divBens").val())) {
                $("#dschassi", "#divBens").val($("#dschassi", "#divBens").val().replace(re, ''));
            }

            re = / /g;

            if (re.test($("#dschassi", "#divBens").val())) {
                $("#dschassi", "#divBens").val($("#dschassi", "#divBens").val().replace(re, ''));
            }
        });

        $("#dschassi", "#divBens").unbind('blur').bind('blur', function () {
            $("#dschassi", "#divBens").val($("#dschassi", "#divBens").val().replace(/[^\w\s]/gi, ''));
            $("#dschassi", "#divBens").val($("#dschassi", "#divBens").val().replace(/[\Q\q\I\i\O\o\_]/g, ''));
            $("#dschassi", "#divBens").val($("#dschassi", "#divBens").val().replace(/ /g, ''));
        });


        //Define ação para o campo ufdplaca
        $("#ufdplaca", "#frmBens").unbind('keypress').bind('keypress', function (e) {

            $(this).removeClass('campoErro');

            // Se é a tecla ENTER, TAB
            if (e.keyCode == 13 || e.keyCode == 9) {

                $("#nrdplaca", "#frmBens").focus();
                return false;
            }

        });

        //Define ação para o campo nrdplaca
        $("#nrdplaca", "#frmBens").unbind('keypress').bind('keypress', function (e) {

            $(this).removeClass('campoErro');

            // Se é a tecla ENTER, TAB
            if (e.keyCode == 13 || e.keyCode == 9) {

                $("#nrrenava", "#frmBens").focus();
                return false;
            }

        });

        //Define ação para o campo nrrenava
        $("#nrrenava", "#frmBens").unbind('keypress').bind('keypress', function (e) {

            $(this).removeClass('campoErro');

            // Se é a tecla ENTER, TAB
            if (e.keyCode == 13 || e.keyCode == 9) {

                $("#nranobem", "#frmBens").focus();
                return false;
            }

        });

        //Define ação para o campo nranobem
        $("#nranobem", "#frmBens").unbind('keypress').bind('keypress', function (e) {

            $(this).removeClass('campoErro');

            // Se é a tecla ENTER, TAB
            if (e.keyCode == 13 || e.keyCode == 9) {

                $("#nrmodbem", "#frmBens").focus();
                return false;
            }

        });

        //Define ação para o campo nrmodbem
        $("#nrmodbem", "#frmBens").unbind('keypress').bind('keypress', function (e) {

            $(this).removeClass('campoErro');

            // Se é a tecla ENTER, TAB
            if (e.keyCode == 13 || e.keyCode == 9) {

                $("#btConcluir", "#divBotoesBens").click();
                return false;
            }

        });

        $("#dschassi", "#divBens").focus();

    }

    return false;

}

function controlaCampos(possuictr, cdsitgrv, idseqbem, dsjustif, tpjustif, tpctrpro, tpinclus, permisit) {

    if ($('#cddopcao', '#frmCab').val() == 'A'){
        
        /* alteracoes apenas quando for situacao 
           For contrato efetivado ou
           3 - Proc. com critica */
        if((possuictr == "0" && cdsitgrv != '3')) {

            $('input,select','#frmBens').desabilitaCampo();
            //$('#btConcluir', '#divBotoesBens').css('display', 'none').unbind('click');
            //$('#btVoltar', '#divBotoesBens').focus();
            
        }else{

            $('#dschassi', '#frmBens').habilitaCampo().focus();
            $('#ufdplaca', '#frmBens').habilitaCampo();
            $('#nrdplaca', '#frmBens').habilitaCampo();
            $('#nrrenava', '#frmBens').habilitaCampo();
		
        }
			if (permisit.toUpperCase() == 'S' && $('#dssitgrv', '#frmBens').val() != 1) {
				$('#dssitgrv', '#frmBens').habilitaCampo();
			}

            //Define ação para CLICK no botão de Concluir
            $("#btConcluir", "#divBotoesBens").unbind('click').bind('click', function () {

				chassi_anterior = $('#chassi_anterior','#divBens').val();
				dschassi = $('#dschassi','#divBens').val();
				
				var funcao = '';
				if (chassi_anterior != dschassi && tpinclus.toUpperCase() == 'M')
					funcao = '$(\'html, body\').animate({scrollTop:0}, \'fast\');pedeSenhaCoordenador(2,\'verificaSituacaoGravames(' + idseqbem + ',' + tpctrpro + ');\',\'\');';
				else
					funcao = 'verificaSituacaoGravames(' + idseqbem + ',' + tpctrpro + ');';
				
                showConfirmacao('Deseja confirmar a opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', funcao, '$(\'#btVoltar\',\'#divBotoesBens\').focus();', 'sim.gif', 'nao.gif');

                return false;

            });


    } else if ($('#cddopcao', '#frmCab').val() == 'B') {

        $('#dsjustif', '#divJustificativa').habilitaCampo().focus();
        $('#dsjustif', '#frmBens').val(dsjustif);

        //Define ação para CLICK no botão de Concluir
        $("#btConcluir", "#divBotoesBens").unbind('click').bind('click', function () {

            showConfirmacao('Deseja confirmar a opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'pedeSenhaCoordenador(2,\'baixaManual(' + idseqbem + ',' + tpctrpro + ');\',\'divRotina\');', '$(\'#btVoltar\',\'#divBotoesBens\').focus();', 'sim.gif', 'nao.gif');

            return false;

        });

    } else if ($('#cddopcao', '#frmCab').val() == 'C') {

        $('#dsjustif', '#frmBens').val(dsjustif);
        $('#btVoltar', '#divBotoesBens').focus();

    } else if ($('#cddopcao', '#frmCab').val() == 'X') {

        //Define ação para CLICK no botão de Concluir
        $("#btConcluir", "#divBotoesBens").unbind('click').bind('click', function () {

            showConfirmacao('Deseja cancelar o registro da aliena&ccedil;&atilde;o no Gravames?', 'Confirma&ccedil;&atilde;o - Ayllos', 'cancelarGravame(' + idseqbem + ',' + tpctrpro + ');', '$(\'#btVoltar\',\'#divBotoesBens\').focus();', 'sim.gif', 'nao.gif');

            return false;

        });

    } else if ($('#cddopcao', '#frmCab').val() == 'J') {

        $('#dsjustif', '#frmBens').val(dsjustif);

        //Define ação para CLICK no botão de Concluir
        $("#btConcluir", "#divBotoesBens").unbind('click').bind('click', function () {

            showConfirmacao('Deseja efetuar o bloqueio judicial da aliena&ccedil;&atilde;o do gravame?', 'Confirma&ccedil;&atilde;o - Ayllos', 'blqLibJudicial(' + idseqbem + ',' + tpctrpro + ');', '$(\'#btVoltar\',\'#divBotoesBens\').focus();', 'sim.gif', 'nao.gif');

            return false;

        });

    } else if ($('#cddopcao', '#frmCab').val() == 'L') {

        $('#dsjustif', '#frmBens').val(dsjustif);

        //Define ação para CLICK no botão de Concluir
        $("#btConcluir", "#divBotoesBens").unbind('click').bind('click', function () {

            showConfirmacao('Deseja liberar o bloqueio judicial da aliena&ccedil;&atilde;o do gravame?', 'Confirma&ccedil;&atilde;o - Ayllos', 'blqLibJudicial(' + idseqbem + ',' + tpctrpro + ');', '$(\'#btVoltar\',\'#divBotoesBens\').focus();', 'sim.gif', 'nao.gif');

            return false;

        });

    }else if ($('#cddopcao', '#frmCab').val() == 'M') {

        $('#dsjustif', '#frmBens').val(dsjustif);
       
        //Define ação para CLICK no botão de Concluir
        $("#btConcluir", "#divBotoesBens").unbind('click').bind('click', function () {

            showConfirmacao('Deseja confirmar a opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'pedeSenhaCoordenador(2,\'inclusaoManual(' + idseqbem + ',' + tpctrpro + ');\',\'divRotina\');', '$(\'#btVoltar\',\'#divBotoesBens\').focus();', 'sim.gif', 'nao.gif');

            return false;

        });


    } else if ($('#cddopcao', '#frmCab').val() == 'S') {

        /* alteracoes apenas quando for situacao 
               For contrato efetivado ou
               3 - Proc. com critica */
        if ((possuictr == "0" && cdsitgrv != '3') || (cdsitgrv != 0 && cdsitgrv != 3)) {

            $('input,select', '#frmBens').desabilitaCampo();
            $('#btConcluir', '#divBotoesBens').css('display', 'none').unbind('click');
          

        } else {

            $('#btConcluir', '#divBotoesBens').css('display', 'inline').unbind('click');

            $('#dschassi', '#frmBens').habilitaCampo().focus();
            $('#ufdplaca', '#frmBens').habilitaCampo();
            $('#nrdplaca', '#frmBens').habilitaCampo();
            $('#nrrenava', '#frmBens').habilitaCampo();
            $('#nranobem', '#frmBens').habilitaCampo();
            $('#nrmodbem', '#frmBens').habilitaCampo();

            //Define ação para CLICK no botão de Concluir
            $("#btConcluir", "#divBotoesBens").unbind('click').bind('click', function () {

                showConfirmacao('Deseja confirmar a opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'alterarBensSubAditivo(' + idseqbem + ',' + tpctrpro + ');', '$(\'#btVoltar\',\'#divBotoesBens\').focus();', 'sim.gif', 'nao.gif');

                return false;

            });

        }

    } else {

        $('#btVoltar', '#divBotoesBens').focus();

    }

    if(tpjustif == "2"){
        $('label[for="dsjustif"]', "#frmBens").text('Justificativa da baixa:');
    } else {
        $('label[for="dsjustif"]', "#frmBens").text('Justificativa:');
    }
    

}
    
function verificaSituacaoGravames(idseqbem,tpctrpro) {
	
	situacao_anterior = $('#situacao_anterior','#divBens').val();
	dssitgrv = $('#dssitgrv','#divBens').val();

	if (situacao_anterior != dssitgrv) {
		// Executa script atraves de ajax
		$.ajax({
			type: 'POST',
			dataType: 'html',
			url: UrlSite + 'telas/gravam/form_motivo.php',
			data: {
					idseqbem: idseqbem,
					tpctrpro: tpctrpro,
					dssitgrv: dssitgrv,
					redirect: 'html_ajax'
				  },
			error: function(objAjax,responseError,objExcept) {
				hideMsgAguardo();
				showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
			},
			success: function(response) {
				hideMsgAguardo();
				bloqueiaFundo($('#divRotina'));
				exibeRotina($('#divRotina'));
				$('#divRotina').html(response);
				formataMotivo(idseqbem,tpctrpro,dssitgrv);
			}
		});		
	} else {
		alterarGravame(idseqbem,tpctrpro);
}
	return false;	
}

function formataMotivo (idseqbem,tpctrpro,dssitgrv) {
	
	$('html, body').animate({scrollTop:0}, 'fast');
	
	$('#dsmotivo', '#frmMotivo').css({width:'500px', height:'100px'}).addClass('campo').focus();
	
	//Define ação para CLICK no botão de Concluir
	$('#btContinuarMotivo').unbind('click').bind('click', function () {
		alterarGravame(idseqbem,tpctrpro,dssitgrv,$('#dsmotivo', '#frmMotivo').val());
		return false;
	});
	
	//Define ação para CLICK no botão de Concluir
	$('#btVoltarMotivo').unbind('click').bind('click', function () {
		fechaRotina($('#divRotina'));
		return false;
	});
}

function formataTabelaContratosGravames(tpconsul) {

    var divRegistro = $('div.divRegistros', '#divRotina');

    var tabela = $('table', divRegistro);

    divRegistro.css({ 'height': '200px', 'border-bottom': '1px dotted #777', 'padding-bottom': '2px' });

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '100px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

    $('table > tbody > tr', divRegistro).each(function (i) {

        if ($(this).hasClass('corSelecao')) {

            selecionaContratoGravame($(this),tpconsul);

        }

    });

    // seleciona o registro que é clicado
    $('table > tbody > tr', divRegistro).click(function () {
        selecionaContratoGravame($(this), tpconsul);

        fechaRotina($('#divRotina'));
        $('#divRotina').html('');

    });

    return false;
}

function formataTabelaBens() {

    var divRegistro = $('div.divRegistros', '#divTabela');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({ 'height': '250px'});
    $('#divRegistrosRodape', '#divTabela').formataRodapePesquisa();

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '100px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);

    $('table > tbody > tr', divRegistro).each(function (i) {

        if ($(this).hasClass('corSelecao')) {

            selecionaBens($(this));

        }

    });

    //seleciona o lancamento que é clicado
    $('table > tbody > tr', divRegistro).click(function () {

        selecionaBens($(this));
    });

    return false;

}

function selecionaContratoGravame(tr,tpconsul) {
   
    if (tpconsul == 'C') {       
        $('#nrctrpro', '#frmFiltro').val($('#nrctrpro', tr).val());
    } else {
        $('#nrgravam', '#frmFiltro').val($('#nrgravam', tr).val());
    }   

}

function selecionaBens(tr) {

    $('#dssitgrv', '#divBens').val($('#cdsitgrv', tr).val());
    $('#dsseqbem', '#divBens').val($('#dsseqbem', tr).val());
    $('#nrgravam', '#divBens').val($('#nrgravam', tr).val());
    $('#dsbemfin', '#divBens').val($('#dsbemfin', tr).val());
    $('#vlmerbem', '#divBens').val($('#vlmerbem', tr).val());
    $('#tpchassi', '#divBens').val($('#tpchassi', tr).val());
    $('#nrdplaca', '#divBens').val($('#nrdplaca', tr).val());
    $('#nranobem', '#divBens').val($('#nranobem', tr).val());
    $('#vlctrgrv', '#divBens').val($('#vlctrgrv', tr).val());
    $('#dscpfbem', '#divBens').val($('#dscpfbem', tr).val());
    $('#dtmvttel', '#divBens').val($('#dtmvtolt', tr).val());
    $('#uflicenc', '#divBens').val($('#uflicenc', tr).val());
    $('#dscatbem', '#divBens').val($('#dscatbem', tr).val());
    $('#dscorbem', '#divBens').val($('#dscorbem', tr).val());
    $('#dschassi', '#divBens').val($('#dschassi', tr).val());
    $('#ufdplaca', '#divBens').val($('#ufdplaca', tr).val());
    $('#nrrenava', '#divBens').val($('#nrrenava', tr).val());
    $('#nrmodbem', '#divBens').val($('#nrmodbem', tr).val());
    $('#dtoperac', '#divBens').val($('#dtoperac', tr).val());
    $('#dsblqjud', '#divBens').val($('#dsblqjud', tr).val());
	$('#situacao_anterior', '#divBens').val($('#cdsitgrv', tr).val());
	$('#chassi_anterior', '#divBens').val($('#dschassi', tr).val());

    
    controlaCampos($('#possuictr', tr).val(), $('#cdsitgrv', tr).val(), $('#idseqbem', tr).val(), $('#dsjustif', tr).val(), $('#tpjustif', tr).val(), $('#tpctrpro', tr).val(), $('#tpinclus', tr).val(), $('#permisit', '#divBens').val());
    
}

function controlaPesquisa(valor) {

    switch (valor) {

        case 1:
            controlaPesquisaAssociado();
            break;

        case 2:
            controlaPesquisaAgencia();
            break;

    }

}

function controlaPesquisaAssociado() {

    // Se esta desabilitado o campo 
    if ($("#nrdconta", "#frmFiltro").prop("disabled") == true) {
        return;
    }

    mostraPesquisaAssociado('nrdconta', 'frmFiltro');

    return false;

}

function controlaPesquisaAgencia() {

    // Se esta desabilitado o campo 
    if ($("#cdagenci", "#frmFiltro").prop("disabled") == true) {
        return;
    }

    /* Remove foco de erro */
    $('input', '#frmFiltro').removeClass('campoErro');

    // Variável local para guardar o elemento anterior
    var campoAnterior = '';
    var bo, procedure, titulo, qtReg, filtros, colunas, cdhistor, titulo_coluna, cdgrupos, dshistor;

    // Nome do Formulário que estamos trabalhando
    var nomeFormulario = 'frmFiltro';

    //Remove a classe de Erro do form
    $('input', '#' + nomeFormulario).removeClass('campoErro');

    bo = 'b1wgen0059.p';
    procedure = 'busca_pac';
    titulo = 'Agência PA';
    qtReg = '20';
    filtrosPesq = 'Cód. PA;cdagenci;30px;S;0;;codigo;|Agência PA;nmresage;200px;S;;;descricao;';
    colunas = 'Código;cdagepac;20%;right|Descrição;dsagepac;80%;left';
    mostraPesquisa(bo, procedure, titulo, qtReg, filtrosPesq, colunas);

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
        url: UrlSite + "telas/gravam/monta_form_filtro.php",
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

function Gera_Impressao(nmarqpdf, callback) {

    hideMsgAguardo();

    var action = UrlSite + 'telas/gravam/imprimir_pdf.php';

    $('#nmarqpdf', '#frmFiltro').remove();
    $('#sidlogin', '#frmFiltro').remove();

    $('#frmFiltro').append('<input type="hidden" id="nmarqpdf" name="nmarqpdf" value="' + nmarqpdf + '" />');
    $('#frmFiltro').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin', '#frmMenu').val() + '" />');

    carregaImpressaoAyllos("frmFiltro", action, callback);

}

function gerarRelatorioHistorico() {

    //Desabilita todos os campos do form
    $('input,select', '#frmFiltro').desabilitaCampo();

    var nrdconta = normalizaNumero($('#nrdconta', '#frmFiltro').val());
    var nrctrpro = normalizaNumero($('#nrctrpro', '#frmFiltro').val());
    var cdcooper = $('#cdcooper', '#frmFiltro').val();
    var cddopcao = $('#cddopcao', '#frmCab').val();

    $('input,select', '#frmFiltro').removeClass('campoErro');

    //Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, solicitando relatório...');

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/gravam/gerar_relatorio_historico.php',
        data: {
            nrdconta: nrdconta,
            nrctrpro: nrctrpro,
            cdcooper: cdcooper,
            cddopcao: cddopcao,
            redirect: 'html_ajax' // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cdcooper','#frmFiltro').focus();");
        },
        success: function (response) {
            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground();$("#cdcooper","#frmFiltro").focus();');
            }

        }
    });

    return false;
}

function gerarRelatorio670() {

    //Desabilita todos os campos do form
    $('input,select', '#frmFiltro').desabilitaCampo();

    var cdcooper = $('#cdcooper', '#frmFiltro').val();
    var tparquiv = $('#tparquiv', '#frmFiltro').val();
    var nrseqlot = $('#nrseqlot', '#frmFiltro').val();
    var dtrefere = $('#dtrefere', '#frmFiltro').val();
    var cddopcao = $('#cddopcao', '#frmCab').val();

    $('input,select', '#frmFiltro').removeClass('campoErro');

    //Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, solicitando relatório...');

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/gravam/gerar_relatorio_670.php',
        data: {
            tparquiv: tparquiv,
            cdcooper: cdcooper,
            cddopcao: cddopcao,
            dtrefere: dtrefere,
            nrseqlot: nrseqlot,
            redirect: 'html_ajax' // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cdcooper','#frmFiltro').focus();");
        },
        success: function (response) {
            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground();$("#cdcooper","#frmFiltro").focus();');
            }

        }
    });

    return false;
}

function buscaContratosGravames(nriniseq, nrregist) {

    var cddopcao = $("#cddopcao", "#frmCab").val();
    var nrdconta = normalizaNumero($("#nrdconta", "#frmFiltro").val());

    showMsgAguardo("Aguarde ...");

    //Requisição para montar o form correspondente a opção escolhida
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/gravam/busca_contratos_gravames.php",
        data: {
            cddopcao: cddopcao,
            nrdconta: nrdconta,
            nrregist: nrregist,
            nriniseq: nriniseq,
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

                    $('#divRotina').html(response);
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

function buscaGravames(nriniseq, nrregist) {

    var cddopcao = $("#cddopcao", "#frmCab").val();
    var nrdconta = normalizaNumero($("#nrdconta", "#frmFiltro").val());
    var nrctrpro = normalizaNumero($("#nrctrpro", "#frmFiltro").val());

    showMsgAguardo("Aguarde ...");

    //Requisição para montar o form correspondente a opção escolhida
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/gravam/busca_gravames.php",
        data: {
            cddopcao: cddopcao,
            nrdconta: nrdconta,
            nrctrpro: nrctrpro,
            nrregist: nrregist,
            nriniseq: nriniseq,
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

                    $('#divRotina').html(response);
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

function geraArquivo() {

    //Desabilita todos os campos do form
    $('input,select', '#frmFiltro').desabilitaCampo();

    var cddopcao = $("#cddopcao", "#frmCab").val();
    var cdcooper = $("#cdcooper", "#frmFiltro").val();
    var tparquiv = $("#tparquiv", "#frmFiltro").val();

    $('input,select', '#frmFiltro').removeClass('campoErro');

    showMsgAguardo("Aguarde, gerando arquivo ...");

    //Requisição para processar a opção que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/gravam/gera_arquivo.php",
        data: {
            cddopcao: cddopcao,
            cdcooper: cdcooper,
            tparquiv: tparquiv,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "$('#cdcooper','#frmFiltro').focus();");
        },
        success: function (response) {

            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {

                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#cdcooper','#frmFiltro').focus();");
            }

        }

    });

    return false;

}

function solicitaProcessamentoArquivoRetorno() {

    //Desabilita todos os campos do form
    $('input,select', '#frmFiltro').desabilitaCampo();

    var cddopcao = $("#cddopcao", "#frmCab").val();
    var cdcooper = $("#cdcooper", "#frmFiltro").val();
    var tparquiv = $("#tparquiv", "#frmFiltro").val();

    $('input,select', '#frmFiltro').removeClass('campoErro');

    showMsgAguardo("Aguarde, processando arquivo ...");

    //Requisição para processar a opção que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/gravam/solicita_process_arq_ret.php",
        data: {
            cddopcao: cddopcao,
            cdcooper: cdcooper,
            tparquiv: tparquiv,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "$('#cdcooper','#frmFiltro').focus();");
        },
        success: function (response) {

            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {

                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#cdcooper','#frmFiltro').focus();");
            }

        }

    });

    return false;

}

function buscaPaAssociado() {

    //Desabilita todos os campos do form
    $('input,select', '#frmFiltro').desabilitaCampo();

    var cddopcao = $("#cddopcao", "#frmCab").val();
    var nrdconta = $("#nrdconta", "#frmFiltro").val();

    $('input,select', '#frmFiltro').removeClass('campoErro');

    showMsgAguardo("Aguarde, buscando PA ...");

    //Requisição para processar a opção que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/gravam/busca_pa_associado.php",
        data: {
            cddopcao: cddopcao,
            nrdconta: normalizaNumero(nrdconta),
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "$('#nrdconta','#frmFiltro').focus();");
        },
        success: function (response) {

            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {

                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#nrdconta','#frmFiltro').focus();");
            }

        }

    });

    return false;

}

function alterarBensSubAditivo(idseqbem,tpctrpro) {

    //Desabilita todos os campos do form
    $('input,select', '#frmBens').desabilitaCampo();

    var cddopcao = $("#cddopcao", "#frmCab").val();
    var nrdconta = $("#nrdconta", "#frmFiltro").val();    
    var nrctrpro = $("#nrctrpro", "#frmFiltro").val();
    var dschassi = $("#dschassi", "#frmBens").val();
    var dscatbem = $("#dscatbem", "#frmBens").val();
    var ufdplaca = $("#ufdplaca", "#frmBens").val();
    var nrdplaca = $("#nrdplaca", "#frmBens").val();
    var nrrenava = $("#nrrenava", "#frmBens").val();
    var nranobem = $("#nranobem", "#frmBens").val();
    var nrmodbem = $("#nrmodbem", "#frmBens").val();

    $('input,select', '#frmBens').removeClass('campoErro');

    showMsgAguardo("Aguarde, atualizando ...");

    //Requisição para processar a opção que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/gravam/alterar_bens_sub_aditivo.php",
        data: {
            cddopcao: cddopcao,
            nrdconta: normalizaNumero(nrdconta),
            nrctrpro: normalizaNumero(nrctrpro),
            tpctrpro: tpctrpro,
            dschassi: dschassi,
            dscatbem: dscatbem,
            ufdplaca: ufdplaca,
            nrdplaca: nrdplaca,
            nrrenava: normalizaNumero(nrrenava),
            nranobem: nranobem,
            nrmodbem: nrmodbem,
            idseqbem: idseqbem,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "$('#btVoltar','#divBotoesBens').focus();");
        },
        success: function (response) {

            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {

                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#btVoltar','#divBotoesBens').focus();");
            }

        }

    });

    return false;

}

function alterarGravame(idseqbem,tpctrpro,dssitgrv,dsmotivo) {
	
    //Desabilita todos os campos do form
    //$('input,select', '#frmBens').desabilitaCampo();

    var cddopcao = $("#cddopcao","#frmCab").val();
    var nrdconta = $("#nrdconta","#frmFiltro").val();    
    var nrctrpro = $("#nrctrpro","#frmFiltro").val();
    var dschassi = $("#dschassi","#frmBens").val();
    var dscatbem = $("#dscatbem","#frmBens").val();    
    var ufdplaca = $("#ufdplaca","#frmBens").val();
    var nrdplaca = $("#nrdplaca","#frmBens").val();
    var nrrenava = $("#nrrenava","#frmBens").val();
    var nranobem = $("#nranobem","#frmBens").val();
    var nrmodbem = $("#nrmodbem", "#frmBens").val();
   
    $('input,select', '#frmBens').removeClass('campoErro');

    showMsgAguardo("Aguarde, atualizando ...");

    //Requisição para processar a opção que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/gravam/alterar_gravame.php",
        data: {
            cddopcao: cddopcao,
            nrdconta: normalizaNumero(nrdconta),
            nrctrpro: normalizaNumero(nrctrpro),
            tpctrpro: tpctrpro,
            dschassi: dschassi,
            dscatbem: dscatbem,
            ufdplaca: ufdplaca,
            nrdplaca: nrdplaca,
            nrrenava: normalizaNumero(nrrenava),
            nranobem: nranobem,
            nrmodbem: nrmodbem,
            idseqbem: idseqbem,
            dssitgrv: dssitgrv,
            dsmotivo: dsmotivo,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "$('#btVoltar','#divBotoesBens').focus();");
        },
        success: function (response) {
			hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {

                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#btVoltar','#divBotoesBens').focus();");
            }

        }

    });

    return false;

}

function inclusaoManual(idseqbem, tpctrpro) {

    //Desabilita todos os campos do form
    $('input,select,textarea', '#frmBens').desabilitaCampo();

    var cddopcao = $("#cddopcao", "#frmCab").val();
    var nrdconta = $("#nrdconta", "#frmFiltro").val();
    var nrctrpro = $("#nrctrpro", "#frmFiltro").val();
    var dtmvttel = $("#dtmvttel", "#frmBens").val();
    var nrgravam = $("#nrgravam", "#frmBens").val();
    var dsjustif = $("#dsjustif", "#frmBens").val().replace(/\r\n/g, ' ');

    $('input,select,textarea', '#frmBens').removeClass('campoErro');

    showMsgAguardo("Aguarde, realizando inclus&atilde;o ...");

    //Requisição para processar a opção que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/gravam/inclusao_manual.php",
        data: {
            cddopcao: cddopcao,
            nrdconta: normalizaNumero(nrdconta),
            nrctrpro: normalizaNumero(nrctrpro),
            tpctrpro: tpctrpro,
            dtmvttel: dtmvttel,
            nrgravam: nrgravam,
            dsjustif: dsjustif,
            idseqbem: idseqbem,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "$('#btVoltar','#divBotoesBens').focus();");
        },
        success: function (response) {

            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {

                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#btVoltar','#divBotoesBens').focus();");
            }

        }

    });

    return false;

}

function cancelarGravame(idseqbem, tpctrpro) {

    //Desabilita todos os campos do form
    $('input,select', '#frmBens').desabilitaCampo();

    var cddopcao = $("#cddopcao", "#frmCab").val();
    var nrdconta = $("#nrdconta", "#frmFiltro").val();
    var nrctrpro = $("#nrctrpro", "#frmFiltro").val();
    var tpcancel = $("#tpcancel", "#frmFiltro").val();
    
    $('input,select', '#frmBens').removeClass('campoErro');

    showMsgAguardo("Aguarde, efetuando cancelamento ...");

    //Requisição para processar a opção que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/gravam/cancelar_gravame.php",
        data: {
            cddopcao: cddopcao,
            nrdconta: normalizaNumero(nrdconta),
            nrctrpro: normalizaNumero(nrctrpro),
            tpctrpro: tpctrpro,
            tpcancel: tpcancel,
            idseqbem: idseqbem,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "$('#btVoltar','#divBotoesBens').focus();");
        },
        success: function (response) {

            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {

                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#btVoltar','#divBotoesBens').focus();");
            }

        }

    });

    return false;

}

function blqLibJudicial(idseqbem, tpctrpro) {

    //Desabilita todos os campos do form
    $('input,select', '#frmBens').desabilitaCampo();

    var cddopcao = $("#cddopcao", "#frmCab").val();
    var nrdconta = $("#nrdconta", "#frmFiltro").val();
    var nrctrpro = $("#nrctrpro", "#frmFiltro").val();
    var dsblqjud = $("#dsblqjud", "#frmBens").val();
    var dschassi = $("#dschassi", "#frmBens").val();   
    var ufdplaca = $("#ufdplaca", "#frmBens").val();
    var nrdplaca = $("#nrdplaca", "#frmBens").val();
    var nrrenava = $("#nrrenava", "#frmBens").val();
   
    $('input,select', '#frmBens').removeClass('campoErro');

    showMsgAguardo("Aguarde, efetuando bloqueio ...");

    //Requisição para processar a opção que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/gravam/bloqueio_liberacao_judicial.php",
        data: {
            cddopcao: cddopcao,
            nrdconta: normalizaNumero(nrdconta),
            nrctrpro: normalizaNumero(nrctrpro),
            tpctrpro: tpctrpro,
            dsblqjud: dsblqjud,
            idseqbem: idseqbem,
            dschassi: dschassi,
            ufdplaca: ufdplaca,
            nrdplaca: nrdplaca,
            nrrenava: normalizaNumero(nrrenava),
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "$('#btVoltar','#divBotoesBens').focus();");
        },
        success: function (response) {

            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {

                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#btVoltar','#divBotoesBens').focus();");
            }

        }

    });

    return false;

}

function baixaManual(idseqbem,tpctrpro) {

    //Desabilita todos os campos do form
    $('input,select,textarea', '#frmBens').desabilitaCampo();

    var cddopcao = $("#cddopcao", "#frmCab").val();
    var nrdconta = $("#nrdconta", "#frmFiltro").val();
    var nrctrpro = $("#nrctrpro", "#frmFiltro").val();
    var nrgravam = $("#nrgravam", "#frmBens").val();
    var dsjustif = $("#dsjustif", "#frmBens").val().replace(/\r\n/g, ' ');
    
    $('input,select,textarea', '#frmBens').removeClass('campoErro');

    showMsgAguardo("Aguarde, realizando baixa ...");

    //Requisição para processar a opção que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/gravam/baixa_manual.php",
        data: {
            cddopcao: cddopcao,
            nrdconta: normalizaNumero(nrdconta),
            nrctrpro: normalizaNumero(nrctrpro),
            tpctrpro: tpctrpro,
            idseqbem: idseqbem,
            nrgravam: nrgravam,
            dsjustif: dsjustif,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "$('#btVoltar','#divBotoesBens').focus();");
        },
        success: function (response) {

            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {

                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#btVoltar','#divBotoesBens').focus();");
            }

        }

    });

    return false;

}

function buscaBens(nriniseq, nrregist) {

    //Desabilita todos os campos do form
    $('input,select', '#frmFiltro').desabilitaCampo();

    var cddopcao = $("#cddopcao", "#frmCab").val();
    var nrdconta = $("#nrdconta", "#frmFiltro").val();
    var nrctrpro = $("#nrctrpro", "#frmFiltro").val();
    var nrgravam = $("#nrgravam", "#frmFiltro").val();

    $('input,select', '#frmFiltro').removeClass('campoErro');

    showMsgAguardo("Aguarde, buscando bens ...");

    //Requisição para processar a opção que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/gravam/busca_bens.php",
        data: {
            cddopcao: cddopcao,
            nrdconta: normalizaNumero(nrdconta),
            nrctrpro: normalizaNumero(nrctrpro),
            nrgravam: normalizaNumero(nrgravam),
            nriniseq: nriniseq,
            nrregist: nrregist,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "$('#nrdconta','#frmFiltro').focus();");
        },
        success: function (response) {

            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {

                    $('#divTabela').html(response);
                    return false;
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#nrdconta','#frmFiltro').focus();");
                }
            } else {
                try {

                    eval(response);
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#nrdconta','#frmFiltro').focus();");
                }
            }

        }

    });

    return false;

}


